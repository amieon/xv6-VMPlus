
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	85813103          	ld	sp,-1960(sp) # 80007858 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb5c3f>
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
    8000010a:	3dc020ef          	jal	ra,800024e6 <either_copyin>
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
    80000172:	0000f517          	auipc	a0,0xf
    80000176:	72e50513          	addi	a0,a0,1838 # 8000f8a0 <cons>
    8000017a:	327000ef          	jal	ra,80000ca0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	72248493          	addi	s1,s1,1826 # 8000f8a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	0000f917          	auipc	s2,0xf
    8000018a:	7b290913          	addi	s2,s2,1970 # 8000f938 <cons+0x98>
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
    800001a4:	12f010ef          	jal	ra,80001ad2 <myproc>
    800001a8:	1d0020ef          	jal	ra,80002378 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	78f010ef          	jal	ra,80002140 <sleep>
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
    800001ea:	2b2020ef          	jal	ra,8000249c <either_copyout>
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
    800001fa:	0000f517          	auipc	a0,0xf
    800001fe:	6a650513          	addi	a0,a0,1702 # 8000f8a0 <cons>
    80000202:	337000ef          	jal	ra,80000d38 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	69450513          	addi	a0,a0,1684 # 8000f8a0 <cons>
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
    8000023e:	0000f717          	auipc	a4,0xf
    80000242:	6ef72d23          	sw	a5,1786(a4) # 8000f938 <cons+0x98>
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
    80000288:	0000f517          	auipc	a0,0xf
    8000028c:	61850513          	addi	a0,a0,1560 # 8000f8a0 <cons>
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
    800002aa:	286020ef          	jal	ra,80002530 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	5f250513          	addi	a0,a0,1522 # 8000f8a0 <cons>
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
    800002ce:	0000f717          	auipc	a4,0xf
    800002d2:	5d270713          	addi	a4,a4,1490 # 8000f8a0 <cons>
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
    800002f4:	0000f797          	auipc	a5,0xf
    800002f8:	5ac78793          	addi	a5,a5,1452 # 8000f8a0 <cons>
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
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	6167a783          	lw	a5,1558(a5) # 8000f938 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	56a70713          	addi	a4,a4,1386 # 8000f8a0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	55a48493          	addi	s1,s1,1370 # 8000f8a0 <cons>
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
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	52270713          	addi	a4,a4,1314 # 8000f8a0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	5af72623          	sw	a5,1452(a4) # 8000f940 <cons+0xa0>
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
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	4ee78793          	addi	a5,a5,1262 # 8000f8a0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	56c7a323          	sw	a2,1382(a5) # 8000f93c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	55a50513          	addi	a0,a0,1370 # 8000f938 <cons+0x98>
    800003e6:	5a7010ef          	jal	ra,8000218c <wakeup>
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
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80007010 <etext+0x10>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	4a450513          	addi	a0,a0,1188 # 8000f8a0 <cons>
    80000404:	01d000ef          	jal	ra,80000c20 <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00247797          	auipc	a5,0x247
    80000410:	61c78793          	addi	a5,a5,1564 # 80247a28 <devsw>
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
    8000044a:	00007617          	auipc	a2,0x7
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80007038 <digits>
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
    800004f4:	00007797          	auipc	a5,0x7
    800004f8:	3807a783          	lw	a5,896(a5) # 80007874 <panicking>
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
    80000528:	00007b97          	auipc	s7,0x7
    8000052c:	b10b8b93          	addi	s7,s7,-1264 # 80007038 <digits>
    80000530:	a01d                	j	80000556 <printf+0x94>
    acquire(&pr.lock);
    80000532:	0000f517          	auipc	a0,0xf
    80000536:	41650513          	addi	a0,a0,1046 # 8000f948 <pr>
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
    80000742:	00007917          	auipc	s2,0x7
    80000746:	8d690913          	addi	s2,s2,-1834 # 80007018 <etext+0x18>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000750:	00007797          	auipc	a5,0x7
    80000754:	1247a783          	lw	a5,292(a5) # 80007874 <panicking>
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
    8000077a:	0000f517          	auipc	a0,0xf
    8000077e:	1ce50513          	addi	a0,a0,462 # 8000f948 <pr>
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
    80000798:	00007797          	auipc	a5,0x7
    8000079c:	0d27ae23          	sw	s2,220(a5) # 80007874 <panicking>
  printf("panic: ");
    800007a0:	00007517          	auipc	a0,0x7
    800007a4:	88050513          	addi	a0,a0,-1920 # 80007020 <etext+0x20>
    800007a8:	d1bff0ef          	jal	ra,800004c2 <printf>
  printf("%s\n", s);
    800007ac:	85a6                	mv	a1,s1
    800007ae:	00007517          	auipc	a0,0x7
    800007b2:	87a50513          	addi	a0,a0,-1926 # 80007028 <etext+0x28>
    800007b6:	d0dff0ef          	jal	ra,800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007ba:	00007797          	auipc	a5,0x7
    800007be:	0b27ab23          	sw	s2,182(a5) # 80007870 <panicked>
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
    800007cc:	00007597          	auipc	a1,0x7
    800007d0:	86458593          	addi	a1,a1,-1948 # 80007030 <etext+0x30>
    800007d4:	0000f517          	auipc	a0,0xf
    800007d8:	17450513          	addi	a0,a0,372 # 8000f948 <pr>
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
    80000818:	00007597          	auipc	a1,0x7
    8000081c:	83858593          	addi	a1,a1,-1992 # 80007050 <digits+0x18>
    80000820:	0000f517          	auipc	a0,0xf
    80000824:	14050513          	addi	a0,a0,320 # 8000f960 <tx_lock>
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
    8000084e:	0000f517          	auipc	a0,0xf
    80000852:	11250513          	addi	a0,a0,274 # 8000f960 <tx_lock>
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
    8000086e:	00007497          	auipc	s1,0x7
    80000872:	00e48493          	addi	s1,s1,14 # 8000787c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	0ea98993          	addi	s3,s3,234 # 8000f960 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	ffa90913          	addi	s2,s2,-6 # 80007878 <tx_chan>
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
    80000892:	0af010ef          	jal	ra,80002140 <sleep>
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
    800008b2:	0000f517          	auipc	a0,0xf
    800008b6:	0ae50513          	addi	a0,a0,174 # 8000f960 <tx_lock>
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
    800008e0:	00007797          	auipc	a5,0x7
    800008e4:	f947a783          	lw	a5,-108(a5) # 80007874 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	f867a783          	lw	a5,-122(a5) # 80007870 <panicked>
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
    80000916:	00007797          	auipc	a5,0x7
    8000091a:	f5e7a783          	lw	a5,-162(a5) # 80007874 <panicking>
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
    80000966:	0000f517          	auipc	a0,0xf
    8000096a:	ffa50513          	addi	a0,a0,-6 # 8000f960 <tx_lock>
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
    8000097c:	0000f517          	auipc	a0,0xf
    80000980:	fe450513          	addi	a0,a0,-28 # 8000f960 <tx_lock>
    80000984:	3b4000ef          	jal	ra,80000d38 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00007797          	auipc	a5,0x7
    80000990:	ee07a823          	sw	zero,-272(a5) # 8000787c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00007517          	auipc	a0,0x7
    80000998:	ee450513          	addi	a0,a0,-284 # 80007878 <tx_chan>
    8000099c:	7f0010ef          	jal	ra,8000218c <wakeup>
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
    800009c4:	0000f517          	auipc	a0,0xf
    800009c8:	fd450513          	addi	a0,a0,-44 # 8000f998 <kref>
    800009cc:	2d4000ef          	jal	ra,80000ca0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	0000f517          	auipc	a0,0xf
    800009d4:	fc850513          	addi	a0,a0,-56 # 8000f998 <kref>
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
    800009fe:	0000f517          	auipc	a0,0xf
    80000a02:	f9a50513          	addi	a0,a0,-102 # 8000f998 <kref>
    80000a06:	29a000ef          	jal	ra,80000ca0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	0000f517          	auipc	a0,0xf
    80000a12:	f8a50513          	addi	a0,a0,-118 # 8000f998 <kref>
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
    80000a42:	0000f517          	auipc	a0,0xf
    80000a46:	f5650513          	addi	a0,a0,-170 # 8000f998 <kref>
    80000a4a:	256000ef          	jal	ra,80000ca0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	0000f517          	auipc	a0,0xf
    80000a56:	f4650513          	addi	a0,a0,-186 # 8000f998 <kref>
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
    80000a8e:	00248797          	auipc	a5,0x248
    80000a92:	13278793          	addi	a5,a5,306 # 80248bc0 <end>
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
    80000ab6:	00006517          	auipc	a0,0x6
    80000aba:	5a250513          	addi	a0,a0,1442 # 80007058 <digits+0x20>
    80000abe:	ccbff0ef          	jal	ra,80000788 <panic>
  memset(pa, 1, PGSIZE);
    80000ac2:	6605                	lui	a2,0x1
    80000ac4:	4585                	li	a1,1
    80000ac6:	8526                	mv	a0,s1
    80000ac8:	2ac000ef          	jal	ra,80000d74 <memset>
  acquire(&kmem.lock);
    80000acc:	0000f917          	auipc	s2,0xf
    80000ad0:	eac90913          	addi	s2,s2,-340 # 8000f978 <kmem>
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
    80000b16:	0000f917          	auipc	s2,0xf
    80000b1a:	e8290913          	addi	s2,s2,-382 # 8000f998 <kref>
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
    80000b6a:	00006597          	auipc	a1,0x6
    80000b6e:	4f658593          	addi	a1,a1,1270 # 80007060 <digits+0x28>
    80000b72:	0000f517          	auipc	a0,0xf
    80000b76:	e0650513          	addi	a0,a0,-506 # 8000f978 <kmem>
    80000b7a:	0a6000ef          	jal	ra,80000c20 <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00006597          	auipc	a1,0x6
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80007068 <digits+0x30>
    80000b86:	0000f517          	auipc	a0,0xf
    80000b8a:	e1250513          	addi	a0,a0,-494 # 8000f998 <kref>
    80000b8e:	092000ef          	jal	ra,80000c20 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00248517          	auipc	a0,0x248
    80000b9a:	02a50513          	addi	a0,a0,42 # 80248bc0 <end>
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
    80000bb4:	0000f497          	auipc	s1,0xf
    80000bb8:	dc448493          	addi	s1,s1,-572 # 8000f978 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0e2000ef          	jal	ra,80000ca0 <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	c4b9                	beqz	s1,80000c12 <kalloc+0x68>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	0000f517          	auipc	a0,0xf
    80000bcc:	db050513          	addi	a0,a0,-592 # 8000f978 <kmem>
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
    80000be0:	0000f517          	auipc	a0,0xf
    80000be4:	db850513          	addi	a0,a0,-584 # 8000f998 <kref>
    80000be8:	0b8000ef          	jal	ra,80000ca0 <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	0000f517          	auipc	a0,0xf
    80000bf0:	dac50513          	addi	a0,a0,-596 # 8000f998 <kref>
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
    80000c12:	0000f517          	auipc	a0,0xf
    80000c16:	d6650513          	addi	a0,a0,-666 # 8000f978 <kmem>
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
    80000c4a:	66d000ef          	jal	ra,80001ab6 <mycpu>
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
    80000c78:	63f000ef          	jal	ra,80001ab6 <mycpu>
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	cb99                	beqz	a5,80000c94 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c80:	637000ef          	jal	ra,80001ab6 <mycpu>
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
    80000c94:	623000ef          	jal	ra,80001ab6 <mycpu>
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
    80000cc8:	5ef000ef          	jal	ra,80001ab6 <mycpu>
    80000ccc:	e888                	sd	a0,16(s1)
}
    80000cce:	60e2                	ld	ra,24(sp)
    80000cd0:	6442                	ld	s0,16(sp)
    80000cd2:	64a2                	ld	s1,8(sp)
    80000cd4:	6105                	addi	sp,sp,32
    80000cd6:	8082                	ret
    panic("acquire");
    80000cd8:	00006517          	auipc	a0,0x6
    80000cdc:	39850513          	addi	a0,a0,920 # 80007070 <digits+0x38>
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
    80000cec:	5cb000ef          	jal	ra,80001ab6 <mycpu>
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
    80000d20:	00006517          	auipc	a0,0x6
    80000d24:	35850513          	addi	a0,a0,856 # 80007078 <digits+0x40>
    80000d28:	a61ff0ef          	jal	ra,80000788 <panic>
    panic("pop_off");
    80000d2c:	00006517          	auipc	a0,0x6
    80000d30:	36450513          	addi	a0,a0,868 # 80007090 <digits+0x58>
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
    80000d68:	00006517          	auipc	a0,0x6
    80000d6c:	33050513          	addi	a0,a0,816 # 80007098 <digits+0x60>
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
    80000de8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fdb6441>
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
    80000f1e:	389000ef          	jal	ra,80001aa6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f22:	00007717          	auipc	a4,0x7
    80000f26:	95e70713          	addi	a4,a4,-1698 # 80007880 <started>
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
    80000f36:	371000ef          	jal	ra,80001aa6 <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17c50513          	addi	a0,a0,380 # 800070b8 <digits+0x80>
    80000f44:	d7eff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f48:	080000ef          	jal	ra,80000fc8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	716010ef          	jal	ra,80002662 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	095040ef          	jal	ra,800057e4 <plicinithart>
  }

  scheduler();        
    80000f54:	054010ef          	jal	ra,80001fa8 <scheduler>
    consoleinit();
    80000f58:	c94ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000f5c:	869ff0ef          	jal	ra,800007c4 <printfinit>
    printf("\n");
    80000f60:	00006517          	auipc	a0,0x6
    80000f64:	16850513          	addi	a0,a0,360 # 800070c8 <digits+0x90>
    80000f68:	d5aff0ef          	jal	ra,800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000f6c:	00006517          	auipc	a0,0x6
    80000f70:	13450513          	addi	a0,a0,308 # 800070a0 <digits+0x68>
    80000f74:	d4eff0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80000f78:	00006517          	auipc	a0,0x6
    80000f7c:	15050513          	addi	a0,a0,336 # 800070c8 <digits+0x90>
    80000f80:	d42ff0ef          	jal	ra,800004c2 <printf>
    kinit();         // physical page allocator
    80000f84:	bdfff0ef          	jal	ra,80000b62 <kinit>
    kvminit();       // create kernel page table
    80000f88:	2ca000ef          	jal	ra,80001252 <kvminit>
    kvminithart();   // turn on paging
    80000f8c:	03c000ef          	jal	ra,80000fc8 <kvminithart>
    procinit();      // process table
    80000f90:	26f000ef          	jal	ra,800019fe <procinit>
    trapinit();      // trap vectors
    80000f94:	6aa010ef          	jal	ra,8000263e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	6ca010ef          	jal	ra,80002662 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	033040ef          	jal	ra,800057ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	045040ef          	jal	ra,800057e4 <plicinithart>
    binit();         // buffer cache
    80000fa4:	795010ef          	jal	ra,80002f38 <binit>
    iinit();         // inode table
    80000fa8:	504020ef          	jal	ra,800034ac <iinit>
    fileinit();      // file table
    80000fac:	3ec030ef          	jal	ra,80004398 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	125040ef          	jal	ra,800058d4 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	64b000ef          	jal	ra,80001dfe <userinit>
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    started = 1;
    80000fbc:	4785                	li	a5,1
    80000fbe:	00007717          	auipc	a4,0x7
    80000fc2:	8cf72123          	sw	a5,-1854(a4) # 80007880 <started>
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
    80000fd2:	00007797          	auipc	a5,0x7
    80000fd6:	8b67b783          	ld	a5,-1866(a5) # 80007888 <kernel_pagetable>
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
    80001016:	00006517          	auipc	a0,0x6
    8000101a:	0ba50513          	addi	a0,a0,186 # 800070d0 <digits+0x98>
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
    8000112c:	00006517          	auipc	a0,0x6
    80001130:	fac50513          	addi	a0,a0,-84 # 800070d8 <digits+0xa0>
    80001134:	e54ff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size not aligned");
    80001138:	00006517          	auipc	a0,0x6
    8000113c:	fc050513          	addi	a0,a0,-64 # 800070f8 <digits+0xc0>
    80001140:	e48ff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size");
    80001144:	00006517          	auipc	a0,0x6
    80001148:	fd450513          	addi	a0,a0,-44 # 80007118 <digits+0xe0>
    8000114c:	e3cff0ef          	jal	ra,80000788 <panic>
      panic("mappages: remap");
    80001150:	00006517          	auipc	a0,0x6
    80001154:	fd850513          	addi	a0,a0,-40 # 80007128 <digits+0xf0>
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
    80001194:	00006517          	auipc	a0,0x6
    80001198:	fa450513          	addi	a0,a0,-92 # 80007138 <digits+0x100>
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
    800011f2:	00006917          	auipc	s2,0x6
    800011f6:	e0e90913          	addi	s2,s2,-498 # 80007000 <etext>
    800011fa:	4729                	li	a4,10
    800011fc:	80006697          	auipc	a3,0x80006
    80001200:	e0468693          	addi	a3,a3,-508 # 7000 <_entry-0x7fff9000>
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
    80001228:	00005617          	auipc	a2,0x5
    8000122c:	dd860613          	addi	a2,a2,-552 # 80006000 <_trampoline>
    80001230:	040005b7          	lui	a1,0x4000
    80001234:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001236:	05b2                	slli	a1,a1,0xc
    80001238:	8526                	mv	a0,s1
    8000123a:	f3fff0ef          	jal	ra,80001178 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	734000ef          	jal	ra,80001974 <proc_mapstacks>
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
    8000125e:	00006797          	auipc	a5,0x6
    80001262:	62a7b523          	sd	a0,1578(a5) # 80007888 <kernel_pagetable>
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
    800012d4:	00006517          	auipc	a0,0x6
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80007140 <digits+0x108>
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
    8000142c:	00006517          	auipc	a0,0x6
    80001430:	d2c50513          	addi	a0,a0,-724 # 80007158 <digits+0x120>
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
    80001480:	ca45                	beqz	a2,80001530 <uvmcopy+0xb0>
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
    8000149e:	4481                	li	s1,0
    if(flags & PTE_W){
      // 子进程和父进程映射要只读 + COW
      flags = (flags & ~PTE_W) | PTE_COW;

      // 父进程也要
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014a0:	7b7d                	lui	s6,0xfffff
    800014a2:	002b5b13          	srli	s6,s6,0x2
    800014a6:	a005                	j	800014c6 <uvmcopy+0x46>
    }

    // 共享同一物理页：引用计数 +1
    kref_inc((void*)pa);
    800014a8:	854a                	mv	a0,s2
    800014aa:	d48ff0ef          	jal	ra,800009f2 <kref_inc>

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014ae:	875e                	mv	a4,s7
    800014b0:	86ca                	mv	a3,s2
    800014b2:	6605                	lui	a2,0x1
    800014b4:	85a6                	mv	a1,s1
    800014b6:	8556                	mv	a0,s5
    800014b8:	c11ff0ef          	jal	ra,800010c8 <mappages>
    800014bc:	e131                	bnez	a0,80001500 <uvmcopy+0x80>
  for(i = 0; i < sz; i += PGSIZE){
    800014be:	6785                	lui	a5,0x1
    800014c0:	94be                	add	s1,s1,a5
    800014c2:	0534fb63          	bgeu	s1,s3,80001518 <uvmcopy+0x98>
    pte = walk(old, i, 0);
    800014c6:	4601                	li	a2,0
    800014c8:	85a6                	mv	a1,s1
    800014ca:	8552                	mv	a0,s4
    800014cc:	b25ff0ef          	jal	ra,80000ff0 <walk>
    if(pte == 0)
    800014d0:	d57d                	beqz	a0,800014be <uvmcopy+0x3e>
    if((*pte & PTE_V) == 0)
    800014d2:	611c                	ld	a5,0(a0)
    800014d4:	0017f713          	andi	a4,a5,1
    800014d8:	d37d                	beqz	a4,800014be <uvmcopy+0x3e>
    pa = PTE2PA(*pte);
    800014da:	00a7d913          	srli	s2,a5,0xa
    800014de:	0932                	slli	s2,s2,0xc
    flags = PTE_FLAGS(*pte);
    800014e0:	3ff7fb93          	andi	s7,a5,1023
    if(flags & PTE_W){
    800014e4:	0047f713          	andi	a4,a5,4
    800014e8:	d361                	beqz	a4,800014a8 <uvmcopy+0x28>
      flags = (flags & ~PTE_W) | PTE_COW;
    800014ea:	efbbf713          	andi	a4,s7,-261
    800014ee:	10076b93          	ori	s7,a4,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014f2:	0167f7b3          	and	a5,a5,s6
    800014f6:	8f5d                	or	a4,a4,a5
    800014f8:	10176713          	ori	a4,a4,257
    800014fc:	e118                	sd	a4,0(a0)
    800014fe:	b76d                	j	800014a8 <uvmcopy+0x28>
      // map 失败要回滚 refcnt
      kref_dec((void*)pa);
    80001500:	854a                	mv	a0,s2
    80001502:	d34ff0ef          	jal	ra,80000a36 <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调 kfree()， kfree 再对 refcnt--。
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001506:	4685                	li	a3,1
    80001508:	00c4d613          	srli	a2,s1,0xc
    8000150c:	4581                	li	a1,0
    8000150e:	8556                	mv	a0,s5
    80001510:	d85ff0ef          	jal	ra,80001294 <uvmunmap>
  return -1;
    80001514:	557d                	li	a0,-1
    80001516:	a011                	j	8000151a <uvmcopy+0x9a>
  return 0;
    80001518:	4501                	li	a0,0
}
    8000151a:	60a6                	ld	ra,72(sp)
    8000151c:	6406                	ld	s0,64(sp)
    8000151e:	74e2                	ld	s1,56(sp)
    80001520:	7942                	ld	s2,48(sp)
    80001522:	79a2                	ld	s3,40(sp)
    80001524:	7a02                	ld	s4,32(sp)
    80001526:	6ae2                	ld	s5,24(sp)
    80001528:	6b42                	ld	s6,16(sp)
    8000152a:	6ba2                	ld	s7,8(sp)
    8000152c:	6161                	addi	sp,sp,80
    8000152e:	8082                	ret
  return 0;
    80001530:	4501                	li	a0,0
}
    80001532:	8082                	ret

0000000080001534 <cowbreak>:
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    80001534:	7179                	addi	sp,sp,-48
    80001536:	f406                	sd	ra,40(sp)
    80001538:	f022                	sd	s0,32(sp)
    8000153a:	ec26                	sd	s1,24(sp)
    8000153c:	e84a                	sd	s2,16(sp)
    8000153e:	e44e                	sd	s3,8(sp)
    80001540:	e052                	sd	s4,0(sp)
    80001542:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    80001544:	4601                	li	a2,0
    80001546:	77fd                	lui	a5,0xfffff
    80001548:	8dfd                	and	a1,a1,a5
    8000154a:	aa7ff0ef          	jal	ra,80000ff0 <walk>
  if(pte == 0)
    8000154e:	cd41                	beqz	a0,800015e6 <cowbreak+0xb2>
    80001550:	89aa                	mv	s3,a0
    return -1;
  if((*pte & PTE_V) == 0)
    80001552:	6104                	ld	s1,0(a0)
    return -1;
  if((*pte & PTE_U) == 0)
    80001554:	0114f713          	andi	a4,s1,17
    80001558:	47c5                	li	a5,17
    8000155a:	08f71863          	bne	a4,a5,800015ea <cowbreak+0xb6>
    return -1;

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    8000155e:	1044f793          	andi	a5,s1,260
    80001562:	10000713          	li	a4,256
    80001566:	08e79463          	bne	a5,a4,800015ee <cowbreak+0xba>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    8000156a:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    8000156e:	00a4da13          	srli	s4,s1,0xa
    80001572:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    80001574:	8552                	mv	a0,s4
    80001576:	c42ff0ef          	jal	ra,800009b8 <kref_get>
    8000157a:	4785                	li	a5,1
    8000157c:	04f50463          	beq	a0,a5,800015c4 <cowbreak+0x90>
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    sfence_vma();
    return 0;
  }

  char *mem = kalloc();
    80001580:	e2aff0ef          	jal	ra,80000baa <kalloc>
    80001584:	84aa                	mv	s1,a0
  if(mem == 0)
    80001586:	c535                	beqz	a0,800015f2 <cowbreak+0xbe>
    return -1;

  memmove(mem, (void*)pa_old, PGSIZE);
    80001588:	6605                	lui	a2,0x1
    8000158a:	85d2                	mv	a1,s4
    8000158c:	845ff0ef          	jal	ra,80000dd0 <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    80001590:	8552                	mv	a0,s4
    80001592:	ca4ff0ef          	jal	ra,80000a36 <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    80001596:	80b1                	srli	s1,s1,0xc
    80001598:	04aa                	slli	s1,s1,0xa
    8000159a:	00496913          	ori	s2,s2,4
    8000159e:	eff97913          	andi	s2,s2,-257
    800015a2:	0124e4b3          	or	s1,s1,s2
    800015a6:	0014e493          	ori	s1,s1,1
    800015aa:	0099b023          	sd	s1,0(s3)
    800015ae:	12000073          	sfence.vma

  sfence_vma();
  return 0;
    800015b2:	4501                	li	a0,0
}
    800015b4:	70a2                	ld	ra,40(sp)
    800015b6:	7402                	ld	s0,32(sp)
    800015b8:	64e2                	ld	s1,24(sp)
    800015ba:	6942                	ld	s2,16(sp)
    800015bc:	69a2                	ld	s3,8(sp)
    800015be:	6a02                	ld	s4,0(sp)
    800015c0:	6145                	addi	sp,sp,48
    800015c2:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015c4:	00496913          	ori	s2,s2,4
    800015c8:	eff97913          	andi	s2,s2,-257
    800015cc:	77fd                	lui	a5,0xfffff
    800015ce:	8389                	srli	a5,a5,0x2
    800015d0:	8cfd                	and	s1,s1,a5
    800015d2:	00996933          	or	s2,s2,s1
    800015d6:	00196913          	ori	s2,s2,1
    800015da:	0129b023          	sd	s2,0(s3)
    800015de:	12000073          	sfence.vma
    return 0;
    800015e2:	4501                	li	a0,0
    800015e4:	bfc1                	j	800015b4 <cowbreak+0x80>
    return -1;
    800015e6:	557d                	li	a0,-1
    800015e8:	b7f1                	j	800015b4 <cowbreak+0x80>
    return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	b7e1                	j	800015b4 <cowbreak+0x80>
    return -1;
    800015ee:	557d                	li	a0,-1
    800015f0:	b7d1                	j	800015b4 <cowbreak+0x80>
    return -1;
    800015f2:	557d                	li	a0,-1
    800015f4:	b7c1                	j	800015b4 <cowbreak+0x80>

00000000800015f6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800015f6:	1141                	addi	sp,sp,-16
    800015f8:	e406                	sd	ra,8(sp)
    800015fa:	e022                	sd	s0,0(sp)
    800015fc:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800015fe:	4601                	li	a2,0
    80001600:	9f1ff0ef          	jal	ra,80000ff0 <walk>
  if(pte == 0)
    80001604:	c901                	beqz	a0,80001614 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001606:	611c                	ld	a5,0(a0)
    80001608:	9bbd                	andi	a5,a5,-17
    8000160a:	e11c                	sd	a5,0(a0)
}
    8000160c:	60a2                	ld	ra,8(sp)
    8000160e:	6402                	ld	s0,0(sp)
    80001610:	0141                	addi	sp,sp,16
    80001612:	8082                	ret
    panic("uvmclear");
    80001614:	00006517          	auipc	a0,0x6
    80001618:	b5450513          	addi	a0,a0,-1196 # 80007168 <digits+0x130>
    8000161c:	96cff0ef          	jal	ra,80000788 <panic>

0000000080001620 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001620:	c2cd                	beqz	a3,800016c2 <copyinstr+0xa2>
{
    80001622:	715d                	addi	sp,sp,-80
    80001624:	e486                	sd	ra,72(sp)
    80001626:	e0a2                	sd	s0,64(sp)
    80001628:	fc26                	sd	s1,56(sp)
    8000162a:	f84a                	sd	s2,48(sp)
    8000162c:	f44e                	sd	s3,40(sp)
    8000162e:	f052                	sd	s4,32(sp)
    80001630:	ec56                	sd	s5,24(sp)
    80001632:	e85a                	sd	s6,16(sp)
    80001634:	e45e                	sd	s7,8(sp)
    80001636:	0880                	addi	s0,sp,80
    80001638:	8a2a                	mv	s4,a0
    8000163a:	8b2e                	mv	s6,a1
    8000163c:	8bb2                	mv	s7,a2
    8000163e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001640:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001642:	6985                	lui	s3,0x1
    80001644:	a02d                	j	8000166e <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001646:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdb6440>
    8000164a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000164c:	37fd                	addiw	a5,a5,-1
    8000164e:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001652:	60a6                	ld	ra,72(sp)
    80001654:	6406                	ld	s0,64(sp)
    80001656:	74e2                	ld	s1,56(sp)
    80001658:	7942                	ld	s2,48(sp)
    8000165a:	79a2                	ld	s3,40(sp)
    8000165c:	7a02                	ld	s4,32(sp)
    8000165e:	6ae2                	ld	s5,24(sp)
    80001660:	6b42                	ld	s6,16(sp)
    80001662:	6ba2                	ld	s7,8(sp)
    80001664:	6161                	addi	sp,sp,80
    80001666:	8082                	ret
    srcva = va0 + PGSIZE;
    80001668:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000166c:	c4b9                	beqz	s1,800016ba <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    8000166e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001672:	85ca                	mv	a1,s2
    80001674:	8552                	mv	a0,s4
    80001676:	a15ff0ef          	jal	ra,8000108a <walkaddr>
    if(pa0 == 0)
    8000167a:	c131                	beqz	a0,800016be <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    8000167c:	417906b3          	sub	a3,s2,s7
    80001680:	96ce                	add	a3,a3,s3
    80001682:	00d4f363          	bgeu	s1,a3,80001688 <copyinstr+0x68>
    80001686:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001688:	955e                	add	a0,a0,s7
    8000168a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000168e:	dee9                	beqz	a3,80001668 <copyinstr+0x48>
    80001690:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001692:	41650633          	sub	a2,a0,s6
    80001696:	fff48593          	addi	a1,s1,-1
    8000169a:	95da                	add	a1,a1,s6
    while(n > 0){
    8000169c:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    8000169e:	00f60733          	add	a4,a2,a5
    800016a2:	00074703          	lbu	a4,0(a4)
    800016a6:	d345                	beqz	a4,80001646 <copyinstr+0x26>
        *dst = *p;
    800016a8:	00e78023          	sb	a4,0(a5)
      --max;
    800016ac:	40f584b3          	sub	s1,a1,a5
      dst++;
    800016b0:	0785                	addi	a5,a5,1
    while(n > 0){
    800016b2:	fed796e3          	bne	a5,a3,8000169e <copyinstr+0x7e>
      dst++;
    800016b6:	8b3e                	mv	s6,a5
    800016b8:	bf45                	j	80001668 <copyinstr+0x48>
    800016ba:	4781                	li	a5,0
    800016bc:	bf41                	j	8000164c <copyinstr+0x2c>
      return -1;
    800016be:	557d                	li	a0,-1
    800016c0:	bf49                	j	80001652 <copyinstr+0x32>
  int got_null = 0;
    800016c2:	4781                	li	a5,0
  if(got_null){
    800016c4:	37fd                	addiw	a5,a5,-1
    800016c6:	0007851b          	sext.w	a0,a5
}
    800016ca:	8082                	ret

00000000800016cc <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800016cc:	1141                	addi	sp,sp,-16
    800016ce:	e406                	sd	ra,8(sp)
    800016d0:	e022                	sd	s0,0(sp)
    800016d2:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800016d4:	4601                	li	a2,0
    800016d6:	91bff0ef          	jal	ra,80000ff0 <walk>
  if (pte == 0) {
    800016da:	c519                	beqz	a0,800016e8 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800016dc:	6108                	ld	a0,0(a0)
    return 0;
    800016de:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800016e0:	60a2                	ld	ra,8(sp)
    800016e2:	6402                	ld	s0,0(sp)
    800016e4:	0141                	addi	sp,sp,16
    800016e6:	8082                	ret
    return 0;
    800016e8:	4501                	li	a0,0
    800016ea:	bfdd                	j	800016e0 <ismapped+0x14>

00000000800016ec <vmfault>:
{
    800016ec:	7179                	addi	sp,sp,-48
    800016ee:	f406                	sd	ra,40(sp)
    800016f0:	f022                	sd	s0,32(sp)
    800016f2:	ec26                	sd	s1,24(sp)
    800016f4:	e84a                	sd	s2,16(sp)
    800016f6:	e44e                	sd	s3,8(sp)
    800016f8:	e052                	sd	s4,0(sp)
    800016fa:	1800                	addi	s0,sp,48
    800016fc:	89aa                	mv	s3,a0
    800016fe:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001700:	3d2000ef          	jal	ra,80001ad2 <myproc>
  if (va >= p->sz)
    80001704:	653c                	ld	a5,72(a0)
    80001706:	00f4ec63          	bltu	s1,a5,8000171e <vmfault+0x32>
    return 0;
    8000170a:	4981                	li	s3,0
}
    8000170c:	854e                	mv	a0,s3
    8000170e:	70a2                	ld	ra,40(sp)
    80001710:	7402                	ld	s0,32(sp)
    80001712:	64e2                	ld	s1,24(sp)
    80001714:	6942                	ld	s2,16(sp)
    80001716:	69a2                	ld	s3,8(sp)
    80001718:	6a02                	ld	s4,0(sp)
    8000171a:	6145                	addi	sp,sp,48
    8000171c:	8082                	ret
    8000171e:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001720:	77fd                	lui	a5,0xfffff
    80001722:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001724:	85a6                	mv	a1,s1
    80001726:	854e                	mv	a0,s3
    80001728:	fa5ff0ef          	jal	ra,800016cc <ismapped>
    return 0;
    8000172c:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000172e:	fd79                	bnez	a0,8000170c <vmfault+0x20>
  mem = (uint64) kalloc();
    80001730:	c7aff0ef          	jal	ra,80000baa <kalloc>
    80001734:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001736:	d979                	beqz	a0,8000170c <vmfault+0x20>
  mem = (uint64) kalloc();
    80001738:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000173a:	6605                	lui	a2,0x1
    8000173c:	4581                	li	a1,0
    8000173e:	e36ff0ef          	jal	ra,80000d74 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001742:	4759                	li	a4,22
    80001744:	86d2                	mv	a3,s4
    80001746:	6605                	lui	a2,0x1
    80001748:	85a6                	mv	a1,s1
    8000174a:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    8000174e:	97bff0ef          	jal	ra,800010c8 <mappages>
    80001752:	dd4d                	beqz	a0,8000170c <vmfault+0x20>
    kfree((void *)mem);
    80001754:	8552                	mv	a0,s4
    80001756:	b24ff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    8000175a:	4981                	li	s3,0
    8000175c:	bf45                	j	8000170c <vmfault+0x20>

000000008000175e <copyout>:
  while(len > 0){
    8000175e:	cec5                	beqz	a3,80001816 <copyout+0xb8>
{
    80001760:	711d                	addi	sp,sp,-96
    80001762:	ec86                	sd	ra,88(sp)
    80001764:	e8a2                	sd	s0,80(sp)
    80001766:	e4a6                	sd	s1,72(sp)
    80001768:	e0ca                	sd	s2,64(sp)
    8000176a:	fc4e                	sd	s3,56(sp)
    8000176c:	f852                	sd	s4,48(sp)
    8000176e:	f456                	sd	s5,40(sp)
    80001770:	f05a                	sd	s6,32(sp)
    80001772:	ec5e                	sd	s7,24(sp)
    80001774:	e862                	sd	s8,16(sp)
    80001776:	e466                	sd	s9,8(sp)
    80001778:	e06a                	sd	s10,0(sp)
    8000177a:	1080                	addi	s0,sp,96
    8000177c:	8a2a                	mv	s4,a0
    8000177e:	8aae                	mv	s5,a1
    80001780:	8b32                	mv	s6,a2
    80001782:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001784:	74fd                	lui	s1,0xfffff
    80001786:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001788:	57fd                	li	a5,-1
    8000178a:	83e9                	srli	a5,a5,0x1a
    8000178c:	0897e763          	bltu	a5,s1,8000181a <copyout+0xbc>
    80001790:	6c05                	lui	s8,0x1
    80001792:	8bbe                	mv	s7,a5
    80001794:	a825                	j	800017cc <copyout+0x6e>
    if((*pte & PTE_W) == 0)
    80001796:	611c                	ld	a5,0(a0)
    80001798:	8b91                	andi	a5,a5,4
    8000179a:	cbc1                	beqz	a5,8000182a <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    8000179c:	01848d33          	add	s10,s1,s8
    800017a0:	415d0cb3          	sub	s9,s10,s5
    800017a4:	0199f363          	bgeu	s3,s9,800017aa <copyout+0x4c>
    800017a8:	8cce                	mv	s9,s3
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017aa:	409a8533          	sub	a0,s5,s1
    800017ae:	000c861b          	sext.w	a2,s9
    800017b2:	85da                	mv	a1,s6
    800017b4:	954a                	add	a0,a0,s2
    800017b6:	e1aff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    800017ba:	419989b3          	sub	s3,s3,s9
    src += n;
    800017be:	9b66                	add	s6,s6,s9
  while(len > 0){
    800017c0:	04098963          	beqz	s3,80001812 <copyout+0xb4>
    if(va0 >= MAXVA)
    800017c4:	05abed63          	bltu	s7,s10,8000181e <copyout+0xc0>
    va0 = PGROUNDDOWN(dstva);
    800017c8:	84ea                	mv	s1,s10
    dstva = va0 + PGSIZE;
    800017ca:	8aea                	mv	s5,s10
    pa0 = walkaddr(pagetable, va0);
    800017cc:	85a6                	mv	a1,s1
    800017ce:	8552                	mv	a0,s4
    800017d0:	8bbff0ef          	jal	ra,8000108a <walkaddr>
    800017d4:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800017d6:	e901                	bnez	a0,800017e6 <copyout+0x88>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017d8:	4601                	li	a2,0
    800017da:	85a6                	mv	a1,s1
    800017dc:	8552                	mv	a0,s4
    800017de:	f0fff0ef          	jal	ra,800016ec <vmfault>
    800017e2:	892a                	mv	s2,a0
    800017e4:	cd1d                	beqz	a0,80001822 <copyout+0xc4>
    pte = walk(pagetable, va0, 0);
    800017e6:	4601                	li	a2,0
    800017e8:	85a6                	mv	a1,s1
    800017ea:	8552                	mv	a0,s4
    800017ec:	805ff0ef          	jal	ra,80000ff0 <walk>
    if(pte && (*pte & PTE_COW)){
    800017f0:	d15d                	beqz	a0,80001796 <copyout+0x38>
    800017f2:	611c                	ld	a5,0(a0)
    800017f4:	1007f793          	andi	a5,a5,256
    800017f8:	dfd9                	beqz	a5,80001796 <copyout+0x38>
      if(cowbreak(pagetable, va0) < 0)
    800017fa:	85a6                	mv	a1,s1
    800017fc:	8552                	mv	a0,s4
    800017fe:	d37ff0ef          	jal	ra,80001534 <cowbreak>
    80001802:	02054263          	bltz	a0,80001826 <copyout+0xc8>
      pte = walk(pagetable, va0, 0);
    80001806:	4601                	li	a2,0
    80001808:	85a6                	mv	a1,s1
    8000180a:	8552                	mv	a0,s4
    8000180c:	fe4ff0ef          	jal	ra,80000ff0 <walk>
    80001810:	b759                	j	80001796 <copyout+0x38>
  return 0;
    80001812:	4501                	li	a0,0
    80001814:	a821                	j	8000182c <copyout+0xce>
    80001816:	4501                	li	a0,0
}
    80001818:	8082                	ret
      return -1;
    8000181a:	557d                	li	a0,-1
    8000181c:	a801                	j	8000182c <copyout+0xce>
    8000181e:	557d                	li	a0,-1
    80001820:	a031                	j	8000182c <copyout+0xce>
        return -1;
    80001822:	557d                	li	a0,-1
    80001824:	a021                	j	8000182c <copyout+0xce>
        return -1;
    80001826:	557d                	li	a0,-1
    80001828:	a011                	j	8000182c <copyout+0xce>
      return -1;
    8000182a:	557d                	li	a0,-1
}
    8000182c:	60e6                	ld	ra,88(sp)
    8000182e:	6446                	ld	s0,80(sp)
    80001830:	64a6                	ld	s1,72(sp)
    80001832:	6906                	ld	s2,64(sp)
    80001834:	79e2                	ld	s3,56(sp)
    80001836:	7a42                	ld	s4,48(sp)
    80001838:	7aa2                	ld	s5,40(sp)
    8000183a:	7b02                	ld	s6,32(sp)
    8000183c:	6be2                	ld	s7,24(sp)
    8000183e:	6c42                	ld	s8,16(sp)
    80001840:	6ca2                	ld	s9,8(sp)
    80001842:	6d02                	ld	s10,0(sp)
    80001844:	6125                	addi	sp,sp,96
    80001846:	8082                	ret

0000000080001848 <copyin>:
  while(len > 0){
    80001848:	c6c9                	beqz	a3,800018d2 <copyin+0x8a>
{
    8000184a:	715d                	addi	sp,sp,-80
    8000184c:	e486                	sd	ra,72(sp)
    8000184e:	e0a2                	sd	s0,64(sp)
    80001850:	fc26                	sd	s1,56(sp)
    80001852:	f84a                	sd	s2,48(sp)
    80001854:	f44e                	sd	s3,40(sp)
    80001856:	f052                	sd	s4,32(sp)
    80001858:	ec56                	sd	s5,24(sp)
    8000185a:	e85a                	sd	s6,16(sp)
    8000185c:	e45e                	sd	s7,8(sp)
    8000185e:	e062                	sd	s8,0(sp)
    80001860:	0880                	addi	s0,sp,80
    80001862:	8baa                	mv	s7,a0
    80001864:	8aae                	mv	s5,a1
    80001866:	8932                	mv	s2,a2
    80001868:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000186a:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000186c:	6b05                	lui	s6,0x1
    8000186e:	a035                	j	8000189a <copyin+0x52>
    80001870:	412984b3          	sub	s1,s3,s2
    80001874:	94da                	add	s1,s1,s6
    80001876:	009a7363          	bgeu	s4,s1,8000187c <copyin+0x34>
    8000187a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000187c:	413905b3          	sub	a1,s2,s3
    80001880:	0004861b          	sext.w	a2,s1
    80001884:	95aa                	add	a1,a1,a0
    80001886:	8556                	mv	a0,s5
    80001888:	d48ff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    8000188c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001890:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001892:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001896:	020a0163          	beqz	s4,800018b8 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000189a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000189e:	85ce                	mv	a1,s3
    800018a0:	855e                	mv	a0,s7
    800018a2:	fe8ff0ef          	jal	ra,8000108a <walkaddr>
    if(pa0 == 0) {
    800018a6:	f569                	bnez	a0,80001870 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018a8:	4601                	li	a2,0
    800018aa:	85ce                	mv	a1,s3
    800018ac:	855e                	mv	a0,s7
    800018ae:	e3fff0ef          	jal	ra,800016ec <vmfault>
    800018b2:	fd5d                	bnez	a0,80001870 <copyin+0x28>
        return -1;
    800018b4:	557d                	li	a0,-1
    800018b6:	a011                	j	800018ba <copyin+0x72>
  return 0;
    800018b8:	4501                	li	a0,0
}
    800018ba:	60a6                	ld	ra,72(sp)
    800018bc:	6406                	ld	s0,64(sp)
    800018be:	74e2                	ld	s1,56(sp)
    800018c0:	7942                	ld	s2,48(sp)
    800018c2:	79a2                	ld	s3,40(sp)
    800018c4:	7a02                	ld	s4,32(sp)
    800018c6:	6ae2                	ld	s5,24(sp)
    800018c8:	6b42                	ld	s6,16(sp)
    800018ca:	6ba2                	ld	s7,8(sp)
    800018cc:	6c02                	ld	s8,0(sp)
    800018ce:	6161                	addi	sp,sp,80
    800018d0:	8082                	ret
  return 0;
    800018d2:	4501                	li	a0,0
}
    800018d4:	8082                	ret

00000000800018d6 <vmafault>:


uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    800018d6:	7139                	addi	sp,sp,-64
    800018d8:	fc06                	sd	ra,56(sp)
    800018da:	f822                	sd	s0,48(sp)
    800018dc:	f426                	sd	s1,40(sp)
    800018de:	f04a                	sd	s2,32(sp)
    800018e0:	ec4e                	sd	s3,24(sp)
    800018e2:	e852                	sd	s4,16(sp)
    800018e4:	e456                	sd	s5,8(sp)
    800018e6:	0080                	addi	s0,sp,64
    800018e8:	8a2a                	mv	s4,a0
    800018ea:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);
    800018ec:	77fd                	lui	a5,0xfffff
    800018ee:	00f5f4b3          	and	s1,a1,a5

  struct vma *v = vma_find(p, va);
    800018f2:	85a6                	mv	a1,s1
    800018f4:	434010ef          	jal	ra,80002d28 <vma_find>
  if(v == 0) return 0;
    800018f8:	c11d                	beqz	a0,8000191e <vmafault+0x48>

  // 权限检查
  if((v->prot & PROT_READ) == 0) return 0;
    800018fa:	4d1c                	lw	a5,24(a0)
    800018fc:	0017f713          	andi	a4,a5,1
    80001900:	4981                	li	s3,0
    80001902:	cf19                	beqz	a4,80001920 <vmafault+0x4a>
  if(iswrite && ((v->prot & PROT_WRITE) == 0)) return 0;
    80001904:	02090863          	beqz	s2,80001934 <vmafault+0x5e>
    80001908:	8b89                	andi	a5,a5,2
    8000190a:	cb99                	beqz	a5,80001920 <vmafault+0x4a>

  if(ismapped(p->pagetable, va))
    8000190c:	85a6                	mv	a1,s1
    8000190e:	050a3503          	ld	a0,80(s4)
    80001912:	dbbff0ef          	jal	ra,800016cc <ismapped>
    return 0;
    80001916:	4981                	li	s3,0

  int perm = PTE_U | PTE_R;
  if(iswrite) perm |= PTE_W;
    80001918:	4ad9                	li	s5,22
  if(ismapped(p->pagetable, va))
    8000191a:	c50d                	beqz	a0,80001944 <vmafault+0x6e>
    8000191c:	a011                	j	80001920 <vmafault+0x4a>
  if(v == 0) return 0;
    8000191e:	4981                	li	s3,0
    kfree(mem);
    return 0;
  }

  return (uint64)mem;
}
    80001920:	854e                	mv	a0,s3
    80001922:	70e2                	ld	ra,56(sp)
    80001924:	7442                	ld	s0,48(sp)
    80001926:	74a2                	ld	s1,40(sp)
    80001928:	7902                	ld	s2,32(sp)
    8000192a:	69e2                	ld	s3,24(sp)
    8000192c:	6a42                	ld	s4,16(sp)
    8000192e:	6aa2                	ld	s5,8(sp)
    80001930:	6121                	addi	sp,sp,64
    80001932:	8082                	ret
  if(ismapped(p->pagetable, va))
    80001934:	85a6                	mv	a1,s1
    80001936:	050a3503          	ld	a0,80(s4)
    8000193a:	d93ff0ef          	jal	ra,800016cc <ismapped>
    return 0;
    8000193e:	4981                	li	s3,0
  int perm = PTE_U | PTE_R;
    80001940:	4ac9                	li	s5,18
  if(ismapped(p->pagetable, va))
    80001942:	fd79                	bnez	a0,80001920 <vmafault+0x4a>
  char *mem = kalloc();
    80001944:	a66ff0ef          	jal	ra,80000baa <kalloc>
    80001948:	892a                	mv	s2,a0
  if(mem == 0) return 0;
    8000194a:	4981                	li	s3,0
    8000194c:	d971                	beqz	a0,80001920 <vmafault+0x4a>
  memset(mem, 0, PGSIZE);
    8000194e:	6605                	lui	a2,0x1
    80001950:	4581                	li	a1,0
    80001952:	c22ff0ef          	jal	ra,80000d74 <memset>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, perm) != 0){
    80001956:	89ca                	mv	s3,s2
    80001958:	8756                	mv	a4,s5
    8000195a:	86ca                	mv	a3,s2
    8000195c:	6605                	lui	a2,0x1
    8000195e:	85a6                	mv	a1,s1
    80001960:	050a3503          	ld	a0,80(s4)
    80001964:	f64ff0ef          	jal	ra,800010c8 <mappages>
    80001968:	dd45                	beqz	a0,80001920 <vmafault+0x4a>
    kfree(mem);
    8000196a:	854a                	mv	a0,s2
    8000196c:	90eff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    80001970:	4981                	li	s3,0
    80001972:	b77d                	j	80001920 <vmafault+0x4a>

0000000080001974 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001974:	7139                	addi	sp,sp,-64
    80001976:	fc06                	sd	ra,56(sp)
    80001978:	f822                	sd	s0,48(sp)
    8000197a:	f426                	sd	s1,40(sp)
    8000197c:	f04a                	sd	s2,32(sp)
    8000197e:	ec4e                	sd	s3,24(sp)
    80001980:	e852                	sd	s4,16(sp)
    80001982:	e456                	sd	s5,8(sp)
    80001984:	e05a                	sd	s6,0(sp)
    80001986:	0080                	addi	s0,sp,64
    80001988:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198a:	0022e497          	auipc	s1,0x22e
    8000198e:	45648493          	addi	s1,s1,1110 # 8022fde0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001992:	8b26                	mv	s6,s1
    80001994:	00005a97          	auipc	s5,0x5
    80001998:	66ca8a93          	addi	s5,s5,1644 # 80007000 <etext>
    8000199c:	04000937          	lui	s2,0x4000
    800019a0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019a2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a4:	0023ca17          	auipc	s4,0x23c
    800019a8:	e3ca0a13          	addi	s4,s4,-452 # 8023d7e0 <tickslock>
    char *pa = kalloc();
    800019ac:	9feff0ef          	jal	ra,80000baa <kalloc>
    800019b0:	862a                	mv	a2,a0
    if(pa == 0)
    800019b2:	c121                	beqz	a0,800019f2 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800019b4:	416485b3          	sub	a1,s1,s6
    800019b8:	858d                	srai	a1,a1,0x3
    800019ba:	000ab783          	ld	a5,0(s5)
    800019be:	02f585b3          	mul	a1,a1,a5
    800019c2:	2585                	addiw	a1,a1,1
    800019c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019c8:	4719                	li	a4,6
    800019ca:	6685                	lui	a3,0x1
    800019cc:	40b905b3          	sub	a1,s2,a1
    800019d0:	854e                	mv	a0,s3
    800019d2:	fa6ff0ef          	jal	ra,80001178 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d6:	36848493          	addi	s1,s1,872
    800019da:	fd4499e3          	bne	s1,s4,800019ac <proc_mapstacks+0x38>
  }
}
    800019de:	70e2                	ld	ra,56(sp)
    800019e0:	7442                	ld	s0,48(sp)
    800019e2:	74a2                	ld	s1,40(sp)
    800019e4:	7902                	ld	s2,32(sp)
    800019e6:	69e2                	ld	s3,24(sp)
    800019e8:	6a42                	ld	s4,16(sp)
    800019ea:	6aa2                	ld	s5,8(sp)
    800019ec:	6b02                	ld	s6,0(sp)
    800019ee:	6121                	addi	sp,sp,64
    800019f0:	8082                	ret
      panic("kalloc");
    800019f2:	00005517          	auipc	a0,0x5
    800019f6:	78650513          	addi	a0,a0,1926 # 80007178 <digits+0x140>
    800019fa:	d8ffe0ef          	jal	ra,80000788 <panic>

00000000800019fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800019fe:	7139                	addi	sp,sp,-64
    80001a00:	fc06                	sd	ra,56(sp)
    80001a02:	f822                	sd	s0,48(sp)
    80001a04:	f426                	sd	s1,40(sp)
    80001a06:	f04a                	sd	s2,32(sp)
    80001a08:	ec4e                	sd	s3,24(sp)
    80001a0a:	e852                	sd	s4,16(sp)
    80001a0c:	e456                	sd	s5,8(sp)
    80001a0e:	e05a                	sd	s6,0(sp)
    80001a10:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a12:	00005597          	auipc	a1,0x5
    80001a16:	76e58593          	addi	a1,a1,1902 # 80007180 <digits+0x148>
    80001a1a:	0022e517          	auipc	a0,0x22e
    80001a1e:	f9650513          	addi	a0,a0,-106 # 8022f9b0 <pid_lock>
    80001a22:	9feff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a26:	00005597          	auipc	a1,0x5
    80001a2a:	76258593          	addi	a1,a1,1890 # 80007188 <digits+0x150>
    80001a2e:	0022e517          	auipc	a0,0x22e
    80001a32:	f9a50513          	addi	a0,a0,-102 # 8022f9c8 <wait_lock>
    80001a36:	9eaff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a3a:	0022e497          	auipc	s1,0x22e
    80001a3e:	3a648493          	addi	s1,s1,934 # 8022fde0 <proc>
      initlock(&p->lock, "proc");
    80001a42:	00005b17          	auipc	s6,0x5
    80001a46:	756b0b13          	addi	s6,s6,1878 # 80007198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001a4a:	8aa6                	mv	s5,s1
    80001a4c:	00005a17          	auipc	s4,0x5
    80001a50:	5b4a0a13          	addi	s4,s4,1460 # 80007000 <etext>
    80001a54:	04000937          	lui	s2,0x4000
    80001a58:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a5a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a5c:	0023c997          	auipc	s3,0x23c
    80001a60:	d8498993          	addi	s3,s3,-636 # 8023d7e0 <tickslock>
      initlock(&p->lock, "proc");
    80001a64:	85da                	mv	a1,s6
    80001a66:	8526                	mv	a0,s1
    80001a68:	9b8ff0ef          	jal	ra,80000c20 <initlock>
      p->state = UNUSED;
    80001a6c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a70:	415487b3          	sub	a5,s1,s5
    80001a74:	878d                	srai	a5,a5,0x3
    80001a76:	000a3703          	ld	a4,0(s4)
    80001a7a:	02e787b3          	mul	a5,a5,a4
    80001a7e:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdb6441>
    80001a80:	00d7979b          	slliw	a5,a5,0xd
    80001a84:	40f907b3          	sub	a5,s2,a5
    80001a88:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a8a:	36848493          	addi	s1,s1,872
    80001a8e:	fd349be3          	bne	s1,s3,80001a64 <procinit+0x66>
  }
}
    80001a92:	70e2                	ld	ra,56(sp)
    80001a94:	7442                	ld	s0,48(sp)
    80001a96:	74a2                	ld	s1,40(sp)
    80001a98:	7902                	ld	s2,32(sp)
    80001a9a:	69e2                	ld	s3,24(sp)
    80001a9c:	6a42                	ld	s4,16(sp)
    80001a9e:	6aa2                	ld	s5,8(sp)
    80001aa0:	6b02                	ld	s6,0(sp)
    80001aa2:	6121                	addi	sp,sp,64
    80001aa4:	8082                	ret

0000000080001aa6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001aa6:	1141                	addi	sp,sp,-16
    80001aa8:	e422                	sd	s0,8(sp)
    80001aaa:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aac:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001aae:	2501                	sext.w	a0,a0
    80001ab0:	6422                	ld	s0,8(sp)
    80001ab2:	0141                	addi	sp,sp,16
    80001ab4:	8082                	ret

0000000080001ab6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001ab6:	1141                	addi	sp,sp,-16
    80001ab8:	e422                	sd	s0,8(sp)
    80001aba:	0800                	addi	s0,sp,16
    80001abc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001abe:	2781                	sext.w	a5,a5
    80001ac0:	079e                	slli	a5,a5,0x7
  return c;
}
    80001ac2:	0022e517          	auipc	a0,0x22e
    80001ac6:	f1e50513          	addi	a0,a0,-226 # 8022f9e0 <cpus>
    80001aca:	953e                	add	a0,a0,a5
    80001acc:	6422                	ld	s0,8(sp)
    80001ace:	0141                	addi	sp,sp,16
    80001ad0:	8082                	ret

0000000080001ad2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001ad2:	1101                	addi	sp,sp,-32
    80001ad4:	ec06                	sd	ra,24(sp)
    80001ad6:	e822                	sd	s0,16(sp)
    80001ad8:	e426                	sd	s1,8(sp)
    80001ada:	1000                	addi	s0,sp,32
  push_off();
    80001adc:	984ff0ef          	jal	ra,80000c60 <push_off>
    80001ae0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ae2:	2781                	sext.w	a5,a5
    80001ae4:	079e                	slli	a5,a5,0x7
    80001ae6:	0022e717          	auipc	a4,0x22e
    80001aea:	eca70713          	addi	a4,a4,-310 # 8022f9b0 <pid_lock>
    80001aee:	97ba                	add	a5,a5,a4
    80001af0:	7b84                	ld	s1,48(a5)
  pop_off();
    80001af2:	9f2ff0ef          	jal	ra,80000ce4 <pop_off>
  return p;
}
    80001af6:	8526                	mv	a0,s1
    80001af8:	60e2                	ld	ra,24(sp)
    80001afa:	6442                	ld	s0,16(sp)
    80001afc:	64a2                	ld	s1,8(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b02:	7179                	addi	sp,sp,-48
    80001b04:	f406                	sd	ra,40(sp)
    80001b06:	f022                	sd	s0,32(sp)
    80001b08:	ec26                	sd	s1,24(sp)
    80001b0a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b0c:	fc7ff0ef          	jal	ra,80001ad2 <myproc>
    80001b10:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b12:	a26ff0ef          	jal	ra,80000d38 <release>

  if (first) {
    80001b16:	00006797          	auipc	a5,0x6
    80001b1a:	d2a7a783          	lw	a5,-726(a5) # 80007840 <first.1>
    80001b1e:	cf8d                	beqz	a5,80001b58 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b20:	4505                	li	a0,1
    80001b22:	63d010ef          	jal	ra,8000395e <fsinit>

    first = 0;
    80001b26:	00006797          	auipc	a5,0x6
    80001b2a:	d007ad23          	sw	zero,-742(a5) # 80007840 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b2e:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b32:	00005517          	auipc	a0,0x5
    80001b36:	66e50513          	addi	a0,a0,1646 # 800071a0 <digits+0x168>
    80001b3a:	fca43823          	sd	a0,-48(s0)
    80001b3e:	fc043c23          	sd	zero,-40(s0)
    80001b42:	fd040593          	addi	a1,s0,-48
    80001b46:	6c7020ef          	jal	ra,80004a0c <kexec>
    80001b4a:	6cbc                	ld	a5,88(s1)
    80001b4c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b4e:	6cbc                	ld	a5,88(s1)
    80001b50:	7bb8                	ld	a4,112(a5)
    80001b52:	57fd                	li	a5,-1
    80001b54:	02f70d63          	beq	a4,a5,80001b8e <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b58:	323000ef          	jal	ra,8000267a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b5c:	68a8                	ld	a0,80(s1)
    80001b5e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b60:	04000737          	lui	a4,0x4000
    80001b64:	00004797          	auipc	a5,0x4
    80001b68:	53878793          	addi	a5,a5,1336 # 8000609c <userret>
    80001b6c:	00004697          	auipc	a3,0x4
    80001b70:	49468693          	addi	a3,a3,1172 # 80006000 <_trampoline>
    80001b74:	8f95                	sub	a5,a5,a3
    80001b76:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b78:	0732                	slli	a4,a4,0xc
    80001b7a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b7c:	577d                	li	a4,-1
    80001b7e:	177e                	slli	a4,a4,0x3f
    80001b80:	8d59                	or	a0,a0,a4
    80001b82:	9782                	jalr	a5
}
    80001b84:	70a2                	ld	ra,40(sp)
    80001b86:	7402                	ld	s0,32(sp)
    80001b88:	64e2                	ld	s1,24(sp)
    80001b8a:	6145                	addi	sp,sp,48
    80001b8c:	8082                	ret
      panic("exec");
    80001b8e:	00005517          	auipc	a0,0x5
    80001b92:	61a50513          	addi	a0,a0,1562 # 800071a8 <digits+0x170>
    80001b96:	bf3fe0ef          	jal	ra,80000788 <panic>

0000000080001b9a <allocpid>:
{
    80001b9a:	1101                	addi	sp,sp,-32
    80001b9c:	ec06                	sd	ra,24(sp)
    80001b9e:	e822                	sd	s0,16(sp)
    80001ba0:	e426                	sd	s1,8(sp)
    80001ba2:	e04a                	sd	s2,0(sp)
    80001ba4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ba6:	0022e917          	auipc	s2,0x22e
    80001baa:	e0a90913          	addi	s2,s2,-502 # 8022f9b0 <pid_lock>
    80001bae:	854a                	mv	a0,s2
    80001bb0:	8f0ff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001bb4:	00006797          	auipc	a5,0x6
    80001bb8:	c9078793          	addi	a5,a5,-880 # 80007844 <nextpid>
    80001bbc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bbe:	0014871b          	addiw	a4,s1,1
    80001bc2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bc4:	854a                	mv	a0,s2
    80001bc6:	972ff0ef          	jal	ra,80000d38 <release>
}
    80001bca:	8526                	mv	a0,s1
    80001bcc:	60e2                	ld	ra,24(sp)
    80001bce:	6442                	ld	s0,16(sp)
    80001bd0:	64a2                	ld	s1,8(sp)
    80001bd2:	6902                	ld	s2,0(sp)
    80001bd4:	6105                	addi	sp,sp,32
    80001bd6:	8082                	ret

0000000080001bd8 <proc_pagetable>:
{
    80001bd8:	1101                	addi	sp,sp,-32
    80001bda:	ec06                	sd	ra,24(sp)
    80001bdc:	e822                	sd	s0,16(sp)
    80001bde:	e426                	sd	s1,8(sp)
    80001be0:	e04a                	sd	s2,0(sp)
    80001be2:	1000                	addi	s0,sp,32
    80001be4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001be6:	e88ff0ef          	jal	ra,8000126e <uvmcreate>
    80001bea:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bec:	cd05                	beqz	a0,80001c24 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bee:	4729                	li	a4,10
    80001bf0:	00004697          	auipc	a3,0x4
    80001bf4:	41068693          	addi	a3,a3,1040 # 80006000 <_trampoline>
    80001bf8:	6605                	lui	a2,0x1
    80001bfa:	040005b7          	lui	a1,0x4000
    80001bfe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c00:	05b2                	slli	a1,a1,0xc
    80001c02:	cc6ff0ef          	jal	ra,800010c8 <mappages>
    80001c06:	02054663          	bltz	a0,80001c32 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c0a:	4719                	li	a4,6
    80001c0c:	05893683          	ld	a3,88(s2)
    80001c10:	6605                	lui	a2,0x1
    80001c12:	020005b7          	lui	a1,0x2000
    80001c16:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c18:	05b6                	slli	a1,a1,0xd
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	cacff0ef          	jal	ra,800010c8 <mappages>
    80001c20:	00054f63          	bltz	a0,80001c3e <proc_pagetable+0x66>
}
    80001c24:	8526                	mv	a0,s1
    80001c26:	60e2                	ld	ra,24(sp)
    80001c28:	6442                	ld	s0,16(sp)
    80001c2a:	64a2                	ld	s1,8(sp)
    80001c2c:	6902                	ld	s2,0(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret
    uvmfree(pagetable, 0);
    80001c32:	4581                	li	a1,0
    80001c34:	8526                	mv	a0,s1
    80001c36:	819ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001c3a:	4481                	li	s1,0
    80001c3c:	b7e5                	j	80001c24 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c3e:	4681                	li	a3,0
    80001c40:	4605                	li	a2,1
    80001c42:	040005b7          	lui	a1,0x4000
    80001c46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c48:	05b2                	slli	a1,a1,0xc
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	e48ff0ef          	jal	ra,80001294 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c50:	4581                	li	a1,0
    80001c52:	8526                	mv	a0,s1
    80001c54:	ffaff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001c58:	4481                	li	s1,0
    80001c5a:	b7e9                	j	80001c24 <proc_pagetable+0x4c>

0000000080001c5c <vma_unmap_pagetable>:
{
    80001c5c:	7179                	addi	sp,sp,-48
    80001c5e:	f406                	sd	ra,40(sp)
    80001c60:	f022                	sd	s0,32(sp)
    80001c62:	ec26                	sd	s1,24(sp)
    80001c64:	e84a                	sd	s2,16(sp)
    80001c66:	e44e                	sd	s3,8(sp)
    80001c68:	1800                	addi	s0,sp,48
    80001c6a:	89aa                	mv	s3,a0
    80001c6c:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001c6e:	20058913          	addi	s2,a1,512
    80001c72:	a811                	j	80001c86 <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001c74:	4685                	li	a3,1
    80001c76:	8231                	srli	a2,a2,0xc
    80001c78:	854e                	mv	a0,s3
    80001c7a:	e1aff0ef          	jal	ra,80001294 <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001c7e:	02048493          	addi	s1,s1,32
    80001c82:	01248b63          	beq	s1,s2,80001c98 <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001c86:	409c                	lw	a5,0(s1)
    80001c88:	dbfd                	beqz	a5,80001c7e <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001c8a:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001c8c:	689c                	ld	a5,16(s1)
    80001c8e:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001c92:	feb786e3          	beq	a5,a1,80001c7e <vma_unmap_pagetable+0x22>
    80001c96:	bff9                	j	80001c74 <vma_unmap_pagetable+0x18>
}
    80001c98:	70a2                	ld	ra,40(sp)
    80001c9a:	7402                	ld	s0,32(sp)
    80001c9c:	64e2                	ld	s1,24(sp)
    80001c9e:	6942                	ld	s2,16(sp)
    80001ca0:	69a2                	ld	s3,8(sp)
    80001ca2:	6145                	addi	sp,sp,48
    80001ca4:	8082                	ret

0000000080001ca6 <proc_freepagetable>:
{
    80001ca6:	1101                	addi	sp,sp,-32
    80001ca8:	ec06                	sd	ra,24(sp)
    80001caa:	e822                	sd	s0,16(sp)
    80001cac:	e426                	sd	s1,8(sp)
    80001cae:	e04a                	sd	s2,0(sp)
    80001cb0:	1000                	addi	s0,sp,32
    80001cb2:	84aa                	mv	s1,a0
    80001cb4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cb6:	4681                	li	a3,0
    80001cb8:	4605                	li	a2,1
    80001cba:	040005b7          	lui	a1,0x4000
    80001cbe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cc0:	05b2                	slli	a1,a1,0xc
    80001cc2:	dd2ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cc6:	4681                	li	a3,0
    80001cc8:	4605                	li	a2,1
    80001cca:	020005b7          	lui	a1,0x2000
    80001cce:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cd0:	05b6                	slli	a1,a1,0xd
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	dc0ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cd8:	85ca                	mv	a1,s2
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f72ff0ef          	jal	ra,8000144e <uvmfree>
}
    80001ce0:	60e2                	ld	ra,24(sp)
    80001ce2:	6442                	ld	s0,16(sp)
    80001ce4:	64a2                	ld	s1,8(sp)
    80001ce6:	6902                	ld	s2,0(sp)
    80001ce8:	6105                	addi	sp,sp,32
    80001cea:	8082                	ret

0000000080001cec <freeproc>:
{
    80001cec:	1101                	addi	sp,sp,-32
    80001cee:	ec06                	sd	ra,24(sp)
    80001cf0:	e822                	sd	s0,16(sp)
    80001cf2:	e426                	sd	s1,8(sp)
    80001cf4:	e04a                	sd	s2,0(sp)
    80001cf6:	1000                	addi	s0,sp,32
    80001cf8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cfa:	6d28                	ld	a0,88(a0)
    80001cfc:	c119                	beqz	a0,80001d02 <freeproc+0x16>
    kfree((void*)p->trapframe);
    80001cfe:	d7dfe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001d02:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001d06:	68a8                	ld	a0,80(s1)
    80001d08:	c105                	beqz	a0,80001d28 <freeproc+0x3c>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001d0a:	16848913          	addi	s2,s1,360
    80001d0e:	85ca                	mv	a1,s2
    80001d10:	f4dff0ef          	jal	ra,80001c5c <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001d14:	20000613          	li	a2,512
    80001d18:	4581                	li	a1,0
    80001d1a:	854a                	mv	a0,s2
    80001d1c:	858ff0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001d20:	64ac                	ld	a1,72(s1)
    80001d22:	68a8                	ld	a0,80(s1)
    80001d24:	f83ff0ef          	jal	ra,80001ca6 <proc_freepagetable>
  p->pagetable = 0;
    80001d28:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d2c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d30:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d34:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d38:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d3c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d40:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d44:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d48:	0004ac23          	sw	zero,24(s1)
}
    80001d4c:	60e2                	ld	ra,24(sp)
    80001d4e:	6442                	ld	s0,16(sp)
    80001d50:	64a2                	ld	s1,8(sp)
    80001d52:	6902                	ld	s2,0(sp)
    80001d54:	6105                	addi	sp,sp,32
    80001d56:	8082                	ret

0000000080001d58 <allocproc>:
{
    80001d58:	1101                	addi	sp,sp,-32
    80001d5a:	ec06                	sd	ra,24(sp)
    80001d5c:	e822                	sd	s0,16(sp)
    80001d5e:	e426                	sd	s1,8(sp)
    80001d60:	e04a                	sd	s2,0(sp)
    80001d62:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d64:	0022e497          	auipc	s1,0x22e
    80001d68:	07c48493          	addi	s1,s1,124 # 8022fde0 <proc>
    80001d6c:	0023c917          	auipc	s2,0x23c
    80001d70:	a7490913          	addi	s2,s2,-1420 # 8023d7e0 <tickslock>
    acquire(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	f2bfe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001d7a:	4c9c                	lw	a5,24(s1)
    80001d7c:	cb91                	beqz	a5,80001d90 <allocproc+0x38>
      release(&p->lock);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fb9fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d84:	36848493          	addi	s1,s1,872
    80001d88:	ff2496e3          	bne	s1,s2,80001d74 <allocproc+0x1c>
  return 0;
    80001d8c:	4481                	li	s1,0
    80001d8e:	a089                	j	80001dd0 <allocproc+0x78>
  p->pid = allocpid();
    80001d90:	e0bff0ef          	jal	ra,80001b9a <allocpid>
    80001d94:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d96:	4785                	li	a5,1
    80001d98:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d9a:	e11fe0ef          	jal	ra,80000baa <kalloc>
    80001d9e:	892a                	mv	s2,a0
    80001da0:	eca8                	sd	a0,88(s1)
    80001da2:	cd15                	beqz	a0,80001dde <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001da4:	8526                	mv	a0,s1
    80001da6:	e33ff0ef          	jal	ra,80001bd8 <proc_pagetable>
    80001daa:	892a                	mv	s2,a0
    80001dac:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001dae:	c121                	beqz	a0,80001dee <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001db0:	07000613          	li	a2,112
    80001db4:	4581                	li	a1,0
    80001db6:	06048513          	addi	a0,s1,96
    80001dba:	fbbfe0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001dbe:	00000797          	auipc	a5,0x0
    80001dc2:	d4478793          	addi	a5,a5,-700 # 80001b02 <forkret>
    80001dc6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dc8:	60bc                	ld	a5,64(s1)
    80001dca:	6705                	lui	a4,0x1
    80001dcc:	97ba                	add	a5,a5,a4
    80001dce:	f4bc                	sd	a5,104(s1)
}
    80001dd0:	8526                	mv	a0,s1
    80001dd2:	60e2                	ld	ra,24(sp)
    80001dd4:	6442                	ld	s0,16(sp)
    80001dd6:	64a2                	ld	s1,8(sp)
    80001dd8:	6902                	ld	s2,0(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret
    freeproc(p);
    80001dde:	8526                	mv	a0,s1
    80001de0:	f0dff0ef          	jal	ra,80001cec <freeproc>
    release(&p->lock);
    80001de4:	8526                	mv	a0,s1
    80001de6:	f53fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001dea:	84ca                	mv	s1,s2
    80001dec:	b7d5                	j	80001dd0 <allocproc+0x78>
    freeproc(p);
    80001dee:	8526                	mv	a0,s1
    80001df0:	efdff0ef          	jal	ra,80001cec <freeproc>
    release(&p->lock);
    80001df4:	8526                	mv	a0,s1
    80001df6:	f43fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001dfa:	84ca                	mv	s1,s2
    80001dfc:	bfd1                	j	80001dd0 <allocproc+0x78>

0000000080001dfe <userinit>:
{
    80001dfe:	1101                	addi	sp,sp,-32
    80001e00:	ec06                	sd	ra,24(sp)
    80001e02:	e822                	sd	s0,16(sp)
    80001e04:	e426                	sd	s1,8(sp)
    80001e06:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e08:	f51ff0ef          	jal	ra,80001d58 <allocproc>
    80001e0c:	84aa                	mv	s1,a0
  initproc = p;
    80001e0e:	00006797          	auipc	a5,0x6
    80001e12:	a8a7b123          	sd	a0,-1406(a5) # 80007890 <initproc>
  p->cwd = namei("/");
    80001e16:	00005517          	auipc	a0,0x5
    80001e1a:	39a50513          	addi	a0,a0,922 # 800071b0 <digits+0x178>
    80001e1e:	044020ef          	jal	ra,80003e62 <namei>
    80001e22:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e26:	478d                	li	a5,3
    80001e28:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e2a:	8526                	mv	a0,s1
    80001e2c:	f0dfe0ef          	jal	ra,80000d38 <release>
}
    80001e30:	60e2                	ld	ra,24(sp)
    80001e32:	6442                	ld	s0,16(sp)
    80001e34:	64a2                	ld	s1,8(sp)
    80001e36:	6105                	addi	sp,sp,32
    80001e38:	8082                	ret

0000000080001e3a <growproc>:
{
    80001e3a:	1101                	addi	sp,sp,-32
    80001e3c:	ec06                	sd	ra,24(sp)
    80001e3e:	e822                	sd	s0,16(sp)
    80001e40:	e426                	sd	s1,8(sp)
    80001e42:	e04a                	sd	s2,0(sp)
    80001e44:	1000                	addi	s0,sp,32
    80001e46:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e48:	c8bff0ef          	jal	ra,80001ad2 <myproc>
    80001e4c:	892a                	mv	s2,a0
  sz = p->sz;
    80001e4e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e50:	02905963          	blez	s1,80001e82 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001e54:	00b48633          	add	a2,s1,a1
    80001e58:	020007b7          	lui	a5,0x2000
    80001e5c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001e5e:	07b6                	slli	a5,a5,0xd
    80001e60:	02c7ea63          	bltu	a5,a2,80001e94 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e64:	4691                	li	a3,4
    80001e66:	6928                	ld	a0,80(a0)
    80001e68:	cecff0ef          	jal	ra,80001354 <uvmalloc>
    80001e6c:	85aa                	mv	a1,a0
    80001e6e:	c50d                	beqz	a0,80001e98 <growproc+0x5e>
  p->sz = sz;
    80001e70:	04b93423          	sd	a1,72(s2)
  return 0;
    80001e74:	4501                	li	a0,0
}
    80001e76:	60e2                	ld	ra,24(sp)
    80001e78:	6442                	ld	s0,16(sp)
    80001e7a:	64a2                	ld	s1,8(sp)
    80001e7c:	6902                	ld	s2,0(sp)
    80001e7e:	6105                	addi	sp,sp,32
    80001e80:	8082                	ret
  } else if(n < 0){
    80001e82:	fe04d7e3          	bgez	s1,80001e70 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e86:	00b48633          	add	a2,s1,a1
    80001e8a:	6928                	ld	a0,80(a0)
    80001e8c:	c84ff0ef          	jal	ra,80001310 <uvmdealloc>
    80001e90:	85aa                	mv	a1,a0
    80001e92:	bff9                	j	80001e70 <growproc+0x36>
      return -1;
    80001e94:	557d                	li	a0,-1
    80001e96:	b7c5                	j	80001e76 <growproc+0x3c>
      return -1;
    80001e98:	557d                	li	a0,-1
    80001e9a:	bff1                	j	80001e76 <growproc+0x3c>

0000000080001e9c <kfork>:
{
    80001e9c:	7139                	addi	sp,sp,-64
    80001e9e:	fc06                	sd	ra,56(sp)
    80001ea0:	f822                	sd	s0,48(sp)
    80001ea2:	f426                	sd	s1,40(sp)
    80001ea4:	f04a                	sd	s2,32(sp)
    80001ea6:	ec4e                	sd	s3,24(sp)
    80001ea8:	e852                	sd	s4,16(sp)
    80001eaa:	e456                	sd	s5,8(sp)
    80001eac:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001eae:	c25ff0ef          	jal	ra,80001ad2 <myproc>
    80001eb2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001eb4:	ea5ff0ef          	jal	ra,80001d58 <allocproc>
    80001eb8:	0e050663          	beqz	a0,80001fa4 <kfork+0x108>
    80001ebc:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ebe:	048ab603          	ld	a2,72(s5)
    80001ec2:	692c                	ld	a1,80(a0)
    80001ec4:	050ab503          	ld	a0,80(s5)
    80001ec8:	db8ff0ef          	jal	ra,80001480 <uvmcopy>
    80001ecc:	04054863          	bltz	a0,80001f1c <kfork+0x80>
  np->sz = p->sz;
    80001ed0:	048ab783          	ld	a5,72(s5)
    80001ed4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ed8:	058ab683          	ld	a3,88(s5)
    80001edc:	87b6                	mv	a5,a3
    80001ede:	058a3703          	ld	a4,88(s4)
    80001ee2:	12068693          	addi	a3,a3,288
    80001ee6:	0007b803          	ld	a6,0(a5)
    80001eea:	6788                	ld	a0,8(a5)
    80001eec:	6b8c                	ld	a1,16(a5)
    80001eee:	6f90                	ld	a2,24(a5)
    80001ef0:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001ef4:	e708                	sd	a0,8(a4)
    80001ef6:	eb0c                	sd	a1,16(a4)
    80001ef8:	ef10                	sd	a2,24(a4)
    80001efa:	02078793          	addi	a5,a5,32
    80001efe:	02070713          	addi	a4,a4,32
    80001f02:	fed792e3          	bne	a5,a3,80001ee6 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001f06:	058a3783          	ld	a5,88(s4)
    80001f0a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f0e:	0d0a8493          	addi	s1,s5,208
    80001f12:	0d0a0913          	addi	s2,s4,208
    80001f16:	150a8993          	addi	s3,s5,336
    80001f1a:	a829                	j	80001f34 <kfork+0x98>
    freeproc(np);
    80001f1c:	8552                	mv	a0,s4
    80001f1e:	dcfff0ef          	jal	ra,80001cec <freeproc>
    release(&np->lock);
    80001f22:	8552                	mv	a0,s4
    80001f24:	e15fe0ef          	jal	ra,80000d38 <release>
    return -1;
    80001f28:	597d                	li	s2,-1
    80001f2a:	a09d                	j	80001f90 <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001f2c:	04a1                	addi	s1,s1,8
    80001f2e:	0921                	addi	s2,s2,8
    80001f30:	01348963          	beq	s1,s3,80001f42 <kfork+0xa6>
    if(p->ofile[i])
    80001f34:	6088                	ld	a0,0(s1)
    80001f36:	d97d                	beqz	a0,80001f2c <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f38:	4e2020ef          	jal	ra,8000441a <filedup>
    80001f3c:	00a93023          	sd	a0,0(s2)
    80001f40:	b7f5                	j	80001f2c <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001f42:	150ab503          	ld	a0,336(s5)
    80001f46:	6f2010ef          	jal	ra,80003638 <idup>
    80001f4a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f4e:	4641                	li	a2,16
    80001f50:	158a8593          	addi	a1,s5,344
    80001f54:	158a0513          	addi	a0,s4,344
    80001f58:	f63fe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    80001f5c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f60:	8552                	mv	a0,s4
    80001f62:	dd7fe0ef          	jal	ra,80000d38 <release>
  acquire(&wait_lock);
    80001f66:	0022e497          	auipc	s1,0x22e
    80001f6a:	a6248493          	addi	s1,s1,-1438 # 8022f9c8 <wait_lock>
    80001f6e:	8526                	mv	a0,s1
    80001f70:	d31fe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    80001f74:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f78:	8526                	mv	a0,s1
    80001f7a:	dbffe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    80001f7e:	8552                	mv	a0,s4
    80001f80:	d21fe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    80001f84:	478d                	li	a5,3
    80001f86:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f8a:	8552                	mv	a0,s4
    80001f8c:	dadfe0ef          	jal	ra,80000d38 <release>
}
    80001f90:	854a                	mv	a0,s2
    80001f92:	70e2                	ld	ra,56(sp)
    80001f94:	7442                	ld	s0,48(sp)
    80001f96:	74a2                	ld	s1,40(sp)
    80001f98:	7902                	ld	s2,32(sp)
    80001f9a:	69e2                	ld	s3,24(sp)
    80001f9c:	6a42                	ld	s4,16(sp)
    80001f9e:	6aa2                	ld	s5,8(sp)
    80001fa0:	6121                	addi	sp,sp,64
    80001fa2:	8082                	ret
    return -1;
    80001fa4:	597d                	li	s2,-1
    80001fa6:	b7ed                	j	80001f90 <kfork+0xf4>

0000000080001fa8 <scheduler>:
{
    80001fa8:	715d                	addi	sp,sp,-80
    80001faa:	e486                	sd	ra,72(sp)
    80001fac:	e0a2                	sd	s0,64(sp)
    80001fae:	fc26                	sd	s1,56(sp)
    80001fb0:	f84a                	sd	s2,48(sp)
    80001fb2:	f44e                	sd	s3,40(sp)
    80001fb4:	f052                	sd	s4,32(sp)
    80001fb6:	ec56                	sd	s5,24(sp)
    80001fb8:	e85a                	sd	s6,16(sp)
    80001fba:	e45e                	sd	s7,8(sp)
    80001fbc:	e062                	sd	s8,0(sp)
    80001fbe:	0880                	addi	s0,sp,80
    80001fc0:	8792                	mv	a5,tp
  int id = r_tp();
    80001fc2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fc4:	00779b13          	slli	s6,a5,0x7
    80001fc8:	0022e717          	auipc	a4,0x22e
    80001fcc:	9e870713          	addi	a4,a4,-1560 # 8022f9b0 <pid_lock>
    80001fd0:	975a                	add	a4,a4,s6
    80001fd2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fd6:	0022e717          	auipc	a4,0x22e
    80001fda:	a1270713          	addi	a4,a4,-1518 # 8022f9e8 <cpus+0x8>
    80001fde:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fe0:	4c11                	li	s8,4
        c->proc = p;
    80001fe2:	079e                	slli	a5,a5,0x7
    80001fe4:	0022ea17          	auipc	s4,0x22e
    80001fe8:	9cca0a13          	addi	s4,s4,-1588 # 8022f9b0 <pid_lock>
    80001fec:	9a3e                	add	s4,s4,a5
        found = 1;
    80001fee:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff0:	0023b997          	auipc	s3,0x23b
    80001ff4:	7f098993          	addi	s3,s3,2032 # 8023d7e0 <tickslock>
    80001ff8:	a83d                	j	80002036 <scheduler+0x8e>
      release(&p->lock);
    80001ffa:	8526                	mv	a0,s1
    80001ffc:	d3dfe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002000:	36848493          	addi	s1,s1,872
    80002004:	03348563          	beq	s1,s3,8000202e <scheduler+0x86>
      acquire(&p->lock);
    80002008:	8526                	mv	a0,s1
    8000200a:	c97fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    8000200e:	4c9c                	lw	a5,24(s1)
    80002010:	ff2795e3          	bne	a5,s2,80001ffa <scheduler+0x52>
        p->state = RUNNING;
    80002014:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002018:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000201c:	06048593          	addi	a1,s1,96
    80002020:	855a                	mv	a0,s6
    80002022:	5b2000ef          	jal	ra,800025d4 <swtch>
        c->proc = 0;
    80002026:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000202a:	8ade                	mv	s5,s7
    8000202c:	b7f9                	j	80001ffa <scheduler+0x52>
    if(found == 0) {
    8000202e:	000a9463          	bnez	s5,80002036 <scheduler+0x8e>
      asm volatile("wfi");
    80002032:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002036:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000203a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000203e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002042:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002046:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002048:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000204c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000204e:	0022e497          	auipc	s1,0x22e
    80002052:	d9248493          	addi	s1,s1,-622 # 8022fde0 <proc>
      if(p->state == RUNNABLE) {
    80002056:	490d                	li	s2,3
    80002058:	bf45                	j	80002008 <scheduler+0x60>

000000008000205a <sched>:
{
    8000205a:	7179                	addi	sp,sp,-48
    8000205c:	f406                	sd	ra,40(sp)
    8000205e:	f022                	sd	s0,32(sp)
    80002060:	ec26                	sd	s1,24(sp)
    80002062:	e84a                	sd	s2,16(sp)
    80002064:	e44e                	sd	s3,8(sp)
    80002066:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002068:	a6bff0ef          	jal	ra,80001ad2 <myproc>
    8000206c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000206e:	bc9fe0ef          	jal	ra,80000c36 <holding>
    80002072:	c92d                	beqz	a0,800020e4 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002074:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	0022e717          	auipc	a4,0x22e
    8000207e:	93670713          	addi	a4,a4,-1738 # 8022f9b0 <pid_lock>
    80002082:	97ba                	add	a5,a5,a4
    80002084:	0a87a703          	lw	a4,168(a5)
    80002088:	4785                	li	a5,1
    8000208a:	06f71363          	bne	a4,a5,800020f0 <sched+0x96>
  if(p->state == RUNNING)
    8000208e:	4c98                	lw	a4,24(s1)
    80002090:	4791                	li	a5,4
    80002092:	06f70563          	beq	a4,a5,800020fc <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002096:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000209a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000209c:	e7b5                	bnez	a5,80002108 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000209e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020a0:	0022e917          	auipc	s2,0x22e
    800020a4:	91090913          	addi	s2,s2,-1776 # 8022f9b0 <pid_lock>
    800020a8:	2781                	sext.w	a5,a5
    800020aa:	079e                	slli	a5,a5,0x7
    800020ac:	97ca                	add	a5,a5,s2
    800020ae:	0ac7a983          	lw	s3,172(a5)
    800020b2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020b4:	2781                	sext.w	a5,a5
    800020b6:	079e                	slli	a5,a5,0x7
    800020b8:	0022e597          	auipc	a1,0x22e
    800020bc:	93058593          	addi	a1,a1,-1744 # 8022f9e8 <cpus+0x8>
    800020c0:	95be                	add	a1,a1,a5
    800020c2:	06048513          	addi	a0,s1,96
    800020c6:	50e000ef          	jal	ra,800025d4 <swtch>
    800020ca:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020cc:	2781                	sext.w	a5,a5
    800020ce:	079e                	slli	a5,a5,0x7
    800020d0:	993e                	add	s2,s2,a5
    800020d2:	0b392623          	sw	s3,172(s2)
}
    800020d6:	70a2                	ld	ra,40(sp)
    800020d8:	7402                	ld	s0,32(sp)
    800020da:	64e2                	ld	s1,24(sp)
    800020dc:	6942                	ld	s2,16(sp)
    800020de:	69a2                	ld	s3,8(sp)
    800020e0:	6145                	addi	sp,sp,48
    800020e2:	8082                	ret
    panic("sched p->lock");
    800020e4:	00005517          	auipc	a0,0x5
    800020e8:	0d450513          	addi	a0,a0,212 # 800071b8 <digits+0x180>
    800020ec:	e9cfe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    800020f0:	00005517          	auipc	a0,0x5
    800020f4:	0d850513          	addi	a0,a0,216 # 800071c8 <digits+0x190>
    800020f8:	e90fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    800020fc:	00005517          	auipc	a0,0x5
    80002100:	0dc50513          	addi	a0,a0,220 # 800071d8 <digits+0x1a0>
    80002104:	e84fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80002108:	00005517          	auipc	a0,0x5
    8000210c:	0e050513          	addi	a0,a0,224 # 800071e8 <digits+0x1b0>
    80002110:	e78fe0ef          	jal	ra,80000788 <panic>

0000000080002114 <yield>:
{
    80002114:	1101                	addi	sp,sp,-32
    80002116:	ec06                	sd	ra,24(sp)
    80002118:	e822                	sd	s0,16(sp)
    8000211a:	e426                	sd	s1,8(sp)
    8000211c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000211e:	9b5ff0ef          	jal	ra,80001ad2 <myproc>
    80002122:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002124:	b7dfe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    80002128:	478d                	li	a5,3
    8000212a:	cc9c                	sw	a5,24(s1)
  sched();
    8000212c:	f2fff0ef          	jal	ra,8000205a <sched>
  release(&p->lock);
    80002130:	8526                	mv	a0,s1
    80002132:	c07fe0ef          	jal	ra,80000d38 <release>
}
    80002136:	60e2                	ld	ra,24(sp)
    80002138:	6442                	ld	s0,16(sp)
    8000213a:	64a2                	ld	s1,8(sp)
    8000213c:	6105                	addi	sp,sp,32
    8000213e:	8082                	ret

0000000080002140 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002140:	7179                	addi	sp,sp,-48
    80002142:	f406                	sd	ra,40(sp)
    80002144:	f022                	sd	s0,32(sp)
    80002146:	ec26                	sd	s1,24(sp)
    80002148:	e84a                	sd	s2,16(sp)
    8000214a:	e44e                	sd	s3,8(sp)
    8000214c:	1800                	addi	s0,sp,48
    8000214e:	89aa                	mv	s3,a0
    80002150:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002152:	981ff0ef          	jal	ra,80001ad2 <myproc>
    80002156:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002158:	b49fe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    8000215c:	854a                	mv	a0,s2
    8000215e:	bdbfe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    80002162:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002166:	4789                	li	a5,2
    80002168:	cc9c                	sw	a5,24(s1)

  sched();
    8000216a:	ef1ff0ef          	jal	ra,8000205a <sched>

  // Tidy up.
  p->chan = 0;
    8000216e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002172:	8526                	mv	a0,s1
    80002174:	bc5fe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    80002178:	854a                	mv	a0,s2
    8000217a:	b27fe0ef          	jal	ra,80000ca0 <acquire>
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6145                	addi	sp,sp,48
    8000218a:	8082                	ret

000000008000218c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000218c:	7139                	addi	sp,sp,-64
    8000218e:	fc06                	sd	ra,56(sp)
    80002190:	f822                	sd	s0,48(sp)
    80002192:	f426                	sd	s1,40(sp)
    80002194:	f04a                	sd	s2,32(sp)
    80002196:	ec4e                	sd	s3,24(sp)
    80002198:	e852                	sd	s4,16(sp)
    8000219a:	e456                	sd	s5,8(sp)
    8000219c:	0080                	addi	s0,sp,64
    8000219e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021a0:	0022e497          	auipc	s1,0x22e
    800021a4:	c4048493          	addi	s1,s1,-960 # 8022fde0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021a8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021aa:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021ac:	0023b917          	auipc	s2,0x23b
    800021b0:	63490913          	addi	s2,s2,1588 # 8023d7e0 <tickslock>
    800021b4:	a801                	j	800021c4 <wakeup+0x38>
      }
      release(&p->lock);
    800021b6:	8526                	mv	a0,s1
    800021b8:	b81fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021bc:	36848493          	addi	s1,s1,872
    800021c0:	03248263          	beq	s1,s2,800021e4 <wakeup+0x58>
    if(p != myproc()){
    800021c4:	90fff0ef          	jal	ra,80001ad2 <myproc>
    800021c8:	fea48ae3          	beq	s1,a0,800021bc <wakeup+0x30>
      acquire(&p->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	ad3fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021d2:	4c9c                	lw	a5,24(s1)
    800021d4:	ff3791e3          	bne	a5,s3,800021b6 <wakeup+0x2a>
    800021d8:	709c                	ld	a5,32(s1)
    800021da:	fd479ee3          	bne	a5,s4,800021b6 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021de:	0154ac23          	sw	s5,24(s1)
    800021e2:	bfd1                	j	800021b6 <wakeup+0x2a>
    }
  }
}
    800021e4:	70e2                	ld	ra,56(sp)
    800021e6:	7442                	ld	s0,48(sp)
    800021e8:	74a2                	ld	s1,40(sp)
    800021ea:	7902                	ld	s2,32(sp)
    800021ec:	69e2                	ld	s3,24(sp)
    800021ee:	6a42                	ld	s4,16(sp)
    800021f0:	6aa2                	ld	s5,8(sp)
    800021f2:	6121                	addi	sp,sp,64
    800021f4:	8082                	ret

00000000800021f6 <reparent>:
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	e052                	sd	s4,0(sp)
    80002204:	1800                	addi	s0,sp,48
    80002206:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002208:	0022e497          	auipc	s1,0x22e
    8000220c:	bd848493          	addi	s1,s1,-1064 # 8022fde0 <proc>
      pp->parent = initproc;
    80002210:	00005a17          	auipc	s4,0x5
    80002214:	680a0a13          	addi	s4,s4,1664 # 80007890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002218:	0023b997          	auipc	s3,0x23b
    8000221c:	5c898993          	addi	s3,s3,1480 # 8023d7e0 <tickslock>
    80002220:	a029                	j	8000222a <reparent+0x34>
    80002222:	36848493          	addi	s1,s1,872
    80002226:	01348b63          	beq	s1,s3,8000223c <reparent+0x46>
    if(pp->parent == p){
    8000222a:	7c9c                	ld	a5,56(s1)
    8000222c:	ff279be3          	bne	a5,s2,80002222 <reparent+0x2c>
      pp->parent = initproc;
    80002230:	000a3503          	ld	a0,0(s4)
    80002234:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002236:	f57ff0ef          	jal	ra,8000218c <wakeup>
    8000223a:	b7e5                	j	80002222 <reparent+0x2c>
}
    8000223c:	70a2                	ld	ra,40(sp)
    8000223e:	7402                	ld	s0,32(sp)
    80002240:	64e2                	ld	s1,24(sp)
    80002242:	6942                	ld	s2,16(sp)
    80002244:	69a2                	ld	s3,8(sp)
    80002246:	6a02                	ld	s4,0(sp)
    80002248:	6145                	addi	sp,sp,48
    8000224a:	8082                	ret

000000008000224c <kexit>:
{
    8000224c:	7179                	addi	sp,sp,-48
    8000224e:	f406                	sd	ra,40(sp)
    80002250:	f022                	sd	s0,32(sp)
    80002252:	ec26                	sd	s1,24(sp)
    80002254:	e84a                	sd	s2,16(sp)
    80002256:	e44e                	sd	s3,8(sp)
    80002258:	e052                	sd	s4,0(sp)
    8000225a:	1800                	addi	s0,sp,48
    8000225c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000225e:	875ff0ef          	jal	ra,80001ad2 <myproc>
    80002262:	89aa                	mv	s3,a0
  if(p == initproc)
    80002264:	00005797          	auipc	a5,0x5
    80002268:	62c7b783          	ld	a5,1580(a5) # 80007890 <initproc>
    8000226c:	0d050493          	addi	s1,a0,208
    80002270:	15050913          	addi	s2,a0,336
    80002274:	00a79f63          	bne	a5,a0,80002292 <kexit+0x46>
    panic("init exiting");
    80002278:	00005517          	auipc	a0,0x5
    8000227c:	f8850513          	addi	a0,a0,-120 # 80007200 <digits+0x1c8>
    80002280:	d08fe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80002284:	1dc020ef          	jal	ra,80004460 <fileclose>
      p->ofile[fd] = 0;
    80002288:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000228c:	04a1                	addi	s1,s1,8
    8000228e:	01248563          	beq	s1,s2,80002298 <kexit+0x4c>
    if(p->ofile[fd]){
    80002292:	6088                	ld	a0,0(s1)
    80002294:	f965                	bnez	a0,80002284 <kexit+0x38>
    80002296:	bfdd                	j	8000228c <kexit+0x40>
  begin_op();
    80002298:	5bf010ef          	jal	ra,80004056 <begin_op>
  iput(p->cwd);
    8000229c:	1509b503          	ld	a0,336(s3)
    800022a0:	54c010ef          	jal	ra,800037ec <iput>
  end_op();
    800022a4:	621010ef          	jal	ra,800040c4 <end_op>
  p->cwd = 0;
    800022a8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022ac:	0022d497          	auipc	s1,0x22d
    800022b0:	71c48493          	addi	s1,s1,1820 # 8022f9c8 <wait_lock>
    800022b4:	8526                	mv	a0,s1
    800022b6:	9ebfe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    800022ba:	854e                	mv	a0,s3
    800022bc:	f3bff0ef          	jal	ra,800021f6 <reparent>
  wakeup(p->parent);
    800022c0:	0389b503          	ld	a0,56(s3)
    800022c4:	ec9ff0ef          	jal	ra,8000218c <wakeup>
  acquire(&p->lock);
    800022c8:	854e                	mv	a0,s3
    800022ca:	9d7fe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    800022ce:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022d2:	4795                	li	a5,5
    800022d4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	a5ffe0ef          	jal	ra,80000d38 <release>
  sched();
    800022de:	d7dff0ef          	jal	ra,8000205a <sched>
  panic("zombie exit");
    800022e2:	00005517          	auipc	a0,0x5
    800022e6:	f2e50513          	addi	a0,a0,-210 # 80007210 <digits+0x1d8>
    800022ea:	c9efe0ef          	jal	ra,80000788 <panic>

00000000800022ee <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800022ee:	7179                	addi	sp,sp,-48
    800022f0:	f406                	sd	ra,40(sp)
    800022f2:	f022                	sd	s0,32(sp)
    800022f4:	ec26                	sd	s1,24(sp)
    800022f6:	e84a                	sd	s2,16(sp)
    800022f8:	e44e                	sd	s3,8(sp)
    800022fa:	1800                	addi	s0,sp,48
    800022fc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022fe:	0022e497          	auipc	s1,0x22e
    80002302:	ae248493          	addi	s1,s1,-1310 # 8022fde0 <proc>
    80002306:	0023b997          	auipc	s3,0x23b
    8000230a:	4da98993          	addi	s3,s3,1242 # 8023d7e0 <tickslock>
    acquire(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	991fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    80002314:	589c                	lw	a5,48(s1)
    80002316:	01278b63          	beq	a5,s2,8000232c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	a1dfe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002320:	36848493          	addi	s1,s1,872
    80002324:	ff3495e3          	bne	s1,s3,8000230e <kkill+0x20>
  }
  return -1;
    80002328:	557d                	li	a0,-1
    8000232a:	a819                	j	80002340 <kkill+0x52>
      p->killed = 1;
    8000232c:	4785                	li	a5,1
    8000232e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002330:	4c98                	lw	a4,24(s1)
    80002332:	4789                	li	a5,2
    80002334:	00f70d63          	beq	a4,a5,8000234e <kkill+0x60>
      release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	9fffe0ef          	jal	ra,80000d38 <release>
      return 0;
    8000233e:	4501                	li	a0,0
}
    80002340:	70a2                	ld	ra,40(sp)
    80002342:	7402                	ld	s0,32(sp)
    80002344:	64e2                	ld	s1,24(sp)
    80002346:	6942                	ld	s2,16(sp)
    80002348:	69a2                	ld	s3,8(sp)
    8000234a:	6145                	addi	sp,sp,48
    8000234c:	8082                	ret
        p->state = RUNNABLE;
    8000234e:	478d                	li	a5,3
    80002350:	cc9c                	sw	a5,24(s1)
    80002352:	b7dd                	j	80002338 <kkill+0x4a>

0000000080002354 <setkilled>:

void
setkilled(struct proc *p)
{
    80002354:	1101                	addi	sp,sp,-32
    80002356:	ec06                	sd	ra,24(sp)
    80002358:	e822                	sd	s0,16(sp)
    8000235a:	e426                	sd	s1,8(sp)
    8000235c:	1000                	addi	s0,sp,32
    8000235e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002360:	941fe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    80002364:	4785                	li	a5,1
    80002366:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	9cffe0ef          	jal	ra,80000d38 <release>
}
    8000236e:	60e2                	ld	ra,24(sp)
    80002370:	6442                	ld	s0,16(sp)
    80002372:	64a2                	ld	s1,8(sp)
    80002374:	6105                	addi	sp,sp,32
    80002376:	8082                	ret

0000000080002378 <killed>:

int
killed(struct proc *p)
{
    80002378:	1101                	addi	sp,sp,-32
    8000237a:	ec06                	sd	ra,24(sp)
    8000237c:	e822                	sd	s0,16(sp)
    8000237e:	e426                	sd	s1,8(sp)
    80002380:	e04a                	sd	s2,0(sp)
    80002382:	1000                	addi	s0,sp,32
    80002384:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002386:	91bfe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    8000238a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	9a9fe0ef          	jal	ra,80000d38 <release>
  return k;
}
    80002394:	854a                	mv	a0,s2
    80002396:	60e2                	ld	ra,24(sp)
    80002398:	6442                	ld	s0,16(sp)
    8000239a:	64a2                	ld	s1,8(sp)
    8000239c:	6902                	ld	s2,0(sp)
    8000239e:	6105                	addi	sp,sp,32
    800023a0:	8082                	ret

00000000800023a2 <kwait>:
{
    800023a2:	715d                	addi	sp,sp,-80
    800023a4:	e486                	sd	ra,72(sp)
    800023a6:	e0a2                	sd	s0,64(sp)
    800023a8:	fc26                	sd	s1,56(sp)
    800023aa:	f84a                	sd	s2,48(sp)
    800023ac:	f44e                	sd	s3,40(sp)
    800023ae:	f052                	sd	s4,32(sp)
    800023b0:	ec56                	sd	s5,24(sp)
    800023b2:	e85a                	sd	s6,16(sp)
    800023b4:	e45e                	sd	s7,8(sp)
    800023b6:	e062                	sd	s8,0(sp)
    800023b8:	0880                	addi	s0,sp,80
    800023ba:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023bc:	f16ff0ef          	jal	ra,80001ad2 <myproc>
    800023c0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023c2:	0022d517          	auipc	a0,0x22d
    800023c6:	60650513          	addi	a0,a0,1542 # 8022f9c8 <wait_lock>
    800023ca:	8d7fe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    800023ce:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023d0:	4a15                	li	s4,5
        havekids = 1;
    800023d2:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d4:	0023b997          	auipc	s3,0x23b
    800023d8:	40c98993          	addi	s3,s3,1036 # 8023d7e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023dc:	0022dc17          	auipc	s8,0x22d
    800023e0:	5ecc0c13          	addi	s8,s8,1516 # 8022f9c8 <wait_lock>
    havekids = 0;
    800023e4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e6:	0022e497          	auipc	s1,0x22e
    800023ea:	9fa48493          	addi	s1,s1,-1542 # 8022fde0 <proc>
    800023ee:	a899                	j	80002444 <kwait+0xa2>
          pid = pp->pid;
    800023f0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023f4:	000b0c63          	beqz	s6,8000240c <kwait+0x6a>
    800023f8:	4691                	li	a3,4
    800023fa:	02c48613          	addi	a2,s1,44
    800023fe:	85da                	mv	a1,s6
    80002400:	05093503          	ld	a0,80(s2)
    80002404:	b5aff0ef          	jal	ra,8000175e <copyout>
    80002408:	00054f63          	bltz	a0,80002426 <kwait+0x84>
          freeproc(pp);
    8000240c:	8526                	mv	a0,s1
    8000240e:	8dfff0ef          	jal	ra,80001cec <freeproc>
          release(&pp->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	925fe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    80002418:	0022d517          	auipc	a0,0x22d
    8000241c:	5b050513          	addi	a0,a0,1456 # 8022f9c8 <wait_lock>
    80002420:	919fe0ef          	jal	ra,80000d38 <release>
          return pid;
    80002424:	a891                	j	80002478 <kwait+0xd6>
            release(&pp->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	911fe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    8000242c:	0022d517          	auipc	a0,0x22d
    80002430:	59c50513          	addi	a0,a0,1436 # 8022f9c8 <wait_lock>
    80002434:	905fe0ef          	jal	ra,80000d38 <release>
            return -1;
    80002438:	59fd                	li	s3,-1
    8000243a:	a83d                	j	80002478 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000243c:	36848493          	addi	s1,s1,872
    80002440:	03348063          	beq	s1,s3,80002460 <kwait+0xbe>
      if(pp->parent == p){
    80002444:	7c9c                	ld	a5,56(s1)
    80002446:	ff279be3          	bne	a5,s2,8000243c <kwait+0x9a>
        acquire(&pp->lock);
    8000244a:	8526                	mv	a0,s1
    8000244c:	855fe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    80002450:	4c9c                	lw	a5,24(s1)
    80002452:	f9478fe3          	beq	a5,s4,800023f0 <kwait+0x4e>
        release(&pp->lock);
    80002456:	8526                	mv	a0,s1
    80002458:	8e1fe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    8000245c:	8756                	mv	a4,s5
    8000245e:	bff9                	j	8000243c <kwait+0x9a>
    if(!havekids || killed(p)){
    80002460:	c709                	beqz	a4,8000246a <kwait+0xc8>
    80002462:	854a                	mv	a0,s2
    80002464:	f15ff0ef          	jal	ra,80002378 <killed>
    80002468:	c50d                	beqz	a0,80002492 <kwait+0xf0>
      release(&wait_lock);
    8000246a:	0022d517          	auipc	a0,0x22d
    8000246e:	55e50513          	addi	a0,a0,1374 # 8022f9c8 <wait_lock>
    80002472:	8c7fe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002476:	59fd                	li	s3,-1
}
    80002478:	854e                	mv	a0,s3
    8000247a:	60a6                	ld	ra,72(sp)
    8000247c:	6406                	ld	s0,64(sp)
    8000247e:	74e2                	ld	s1,56(sp)
    80002480:	7942                	ld	s2,48(sp)
    80002482:	79a2                	ld	s3,40(sp)
    80002484:	7a02                	ld	s4,32(sp)
    80002486:	6ae2                	ld	s5,24(sp)
    80002488:	6b42                	ld	s6,16(sp)
    8000248a:	6ba2                	ld	s7,8(sp)
    8000248c:	6c02                	ld	s8,0(sp)
    8000248e:	6161                	addi	sp,sp,80
    80002490:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002492:	85e2                	mv	a1,s8
    80002494:	854a                	mv	a0,s2
    80002496:	cabff0ef          	jal	ra,80002140 <sleep>
    havekids = 0;
    8000249a:	b7a9                	j	800023e4 <kwait+0x42>

000000008000249c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000249c:	7179                	addi	sp,sp,-48
    8000249e:	f406                	sd	ra,40(sp)
    800024a0:	f022                	sd	s0,32(sp)
    800024a2:	ec26                	sd	s1,24(sp)
    800024a4:	e84a                	sd	s2,16(sp)
    800024a6:	e44e                	sd	s3,8(sp)
    800024a8:	e052                	sd	s4,0(sp)
    800024aa:	1800                	addi	s0,sp,48
    800024ac:	84aa                	mv	s1,a0
    800024ae:	892e                	mv	s2,a1
    800024b0:	89b2                	mv	s3,a2
    800024b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b4:	e1eff0ef          	jal	ra,80001ad2 <myproc>
  if(user_dst){
    800024b8:	cc99                	beqz	s1,800024d6 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024ba:	86d2                	mv	a3,s4
    800024bc:	864e                	mv	a2,s3
    800024be:	85ca                	mv	a1,s2
    800024c0:	6928                	ld	a0,80(a0)
    800024c2:	a9cff0ef          	jal	ra,8000175e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024c6:	70a2                	ld	ra,40(sp)
    800024c8:	7402                	ld	s0,32(sp)
    800024ca:	64e2                	ld	s1,24(sp)
    800024cc:	6942                	ld	s2,16(sp)
    800024ce:	69a2                	ld	s3,8(sp)
    800024d0:	6a02                	ld	s4,0(sp)
    800024d2:	6145                	addi	sp,sp,48
    800024d4:	8082                	ret
    memmove((char *)dst, src, len);
    800024d6:	000a061b          	sext.w	a2,s4
    800024da:	85ce                	mv	a1,s3
    800024dc:	854a                	mv	a0,s2
    800024de:	8f3fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800024e2:	8526                	mv	a0,s1
    800024e4:	b7cd                	j	800024c6 <either_copyout+0x2a>

00000000800024e6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024e6:	7179                	addi	sp,sp,-48
    800024e8:	f406                	sd	ra,40(sp)
    800024ea:	f022                	sd	s0,32(sp)
    800024ec:	ec26                	sd	s1,24(sp)
    800024ee:	e84a                	sd	s2,16(sp)
    800024f0:	e44e                	sd	s3,8(sp)
    800024f2:	e052                	sd	s4,0(sp)
    800024f4:	1800                	addi	s0,sp,48
    800024f6:	892a                	mv	s2,a0
    800024f8:	84ae                	mv	s1,a1
    800024fa:	89b2                	mv	s3,a2
    800024fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024fe:	dd4ff0ef          	jal	ra,80001ad2 <myproc>
  if(user_src){
    80002502:	cc99                	beqz	s1,80002520 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002504:	86d2                	mv	a3,s4
    80002506:	864e                	mv	a2,s3
    80002508:	85ca                	mv	a1,s2
    8000250a:	6928                	ld	a0,80(a0)
    8000250c:	b3cff0ef          	jal	ra,80001848 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002510:	70a2                	ld	ra,40(sp)
    80002512:	7402                	ld	s0,32(sp)
    80002514:	64e2                	ld	s1,24(sp)
    80002516:	6942                	ld	s2,16(sp)
    80002518:	69a2                	ld	s3,8(sp)
    8000251a:	6a02                	ld	s4,0(sp)
    8000251c:	6145                	addi	sp,sp,48
    8000251e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002520:	000a061b          	sext.w	a2,s4
    80002524:	85ce                	mv	a1,s3
    80002526:	854a                	mv	a0,s2
    80002528:	8a9fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    8000252c:	8526                	mv	a0,s1
    8000252e:	b7cd                	j	80002510 <either_copyin+0x2a>

0000000080002530 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002530:	715d                	addi	sp,sp,-80
    80002532:	e486                	sd	ra,72(sp)
    80002534:	e0a2                	sd	s0,64(sp)
    80002536:	fc26                	sd	s1,56(sp)
    80002538:	f84a                	sd	s2,48(sp)
    8000253a:	f44e                	sd	s3,40(sp)
    8000253c:	f052                	sd	s4,32(sp)
    8000253e:	ec56                	sd	s5,24(sp)
    80002540:	e85a                	sd	s6,16(sp)
    80002542:	e45e                	sd	s7,8(sp)
    80002544:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002546:	00005517          	auipc	a0,0x5
    8000254a:	b8250513          	addi	a0,a0,-1150 # 800070c8 <digits+0x90>
    8000254e:	f75fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002552:	0022e497          	auipc	s1,0x22e
    80002556:	9e648493          	addi	s1,s1,-1562 # 8022ff38 <proc+0x158>
    8000255a:	0023b917          	auipc	s2,0x23b
    8000255e:	3de90913          	addi	s2,s2,990 # 8023d938 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002562:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002564:	00005997          	auipc	s3,0x5
    80002568:	cbc98993          	addi	s3,s3,-836 # 80007220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    8000256c:	00005a97          	auipc	s5,0x5
    80002570:	cbca8a93          	addi	s5,s5,-836 # 80007228 <digits+0x1f0>
    printf("\n");
    80002574:	00005a17          	auipc	s4,0x5
    80002578:	b54a0a13          	addi	s4,s4,-1196 # 800070c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257c:	00005b97          	auipc	s7,0x5
    80002580:	cecb8b93          	addi	s7,s7,-788 # 80007268 <states.0>
    80002584:	a829                	j	8000259e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002586:	ed86a583          	lw	a1,-296(a3)
    8000258a:	8556                	mv	a0,s5
    8000258c:	f37fd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80002590:	8552                	mv	a0,s4
    80002592:	f31fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002596:	36848493          	addi	s1,s1,872
    8000259a:	03248263          	beq	s1,s2,800025be <procdump+0x8e>
    if(p->state == UNUSED)
    8000259e:	86a6                	mv	a3,s1
    800025a0:	ec04a783          	lw	a5,-320(s1)
    800025a4:	dbed                	beqz	a5,80002596 <procdump+0x66>
      state = "???";
    800025a6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a8:	fcfb6fe3          	bltu	s6,a5,80002586 <procdump+0x56>
    800025ac:	02079713          	slli	a4,a5,0x20
    800025b0:	01d75793          	srli	a5,a4,0x1d
    800025b4:	97de                	add	a5,a5,s7
    800025b6:	6390                	ld	a2,0(a5)
    800025b8:	f679                	bnez	a2,80002586 <procdump+0x56>
      state = "???";
    800025ba:	864e                	mv	a2,s3
    800025bc:	b7e9                	j	80002586 <procdump+0x56>
  }
}
    800025be:	60a6                	ld	ra,72(sp)
    800025c0:	6406                	ld	s0,64(sp)
    800025c2:	74e2                	ld	s1,56(sp)
    800025c4:	7942                	ld	s2,48(sp)
    800025c6:	79a2                	ld	s3,40(sp)
    800025c8:	7a02                	ld	s4,32(sp)
    800025ca:	6ae2                	ld	s5,24(sp)
    800025cc:	6b42                	ld	s6,16(sp)
    800025ce:	6ba2                	ld	s7,8(sp)
    800025d0:	6161                	addi	sp,sp,80
    800025d2:	8082                	ret

00000000800025d4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025d4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025d8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025dc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025de:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025e0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025e4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025e8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025ec:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025f0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025f4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025f8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025fc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002600:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002604:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002608:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000260c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002610:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002612:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002614:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002618:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000261c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002620:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002624:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002628:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000262c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002630:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002634:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002638:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000263c:	8082                	ret

000000008000263e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000263e:	1141                	addi	sp,sp,-16
    80002640:	e406                	sd	ra,8(sp)
    80002642:	e022                	sd	s0,0(sp)
    80002644:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002646:	00005597          	auipc	a1,0x5
    8000264a:	c5258593          	addi	a1,a1,-942 # 80007298 <states.0+0x30>
    8000264e:	0023b517          	auipc	a0,0x23b
    80002652:	19250513          	addi	a0,a0,402 # 8023d7e0 <tickslock>
    80002656:	dcafe0ef          	jal	ra,80000c20 <initlock>
}
    8000265a:	60a2                	ld	ra,8(sp)
    8000265c:	6402                	ld	s0,0(sp)
    8000265e:	0141                	addi	sp,sp,16
    80002660:	8082                	ret

0000000080002662 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002662:	1141                	addi	sp,sp,-16
    80002664:	e422                	sd	s0,8(sp)
    80002666:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002668:	00003797          	auipc	a5,0x3
    8000266c:	10878793          	addi	a5,a5,264 # 80005770 <kernelvec>
    80002670:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002674:	6422                	ld	s0,8(sp)
    80002676:	0141                	addi	sp,sp,16
    80002678:	8082                	ret

000000008000267a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000267a:	1141                	addi	sp,sp,-16
    8000267c:	e406                	sd	ra,8(sp)
    8000267e:	e022                	sd	s0,0(sp)
    80002680:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002682:	c50ff0ef          	jal	ra,80001ad2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002686:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000268a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000268c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002690:	04000737          	lui	a4,0x4000
    80002694:	00004797          	auipc	a5,0x4
    80002698:	96c78793          	addi	a5,a5,-1684 # 80006000 <_trampoline>
    8000269c:	00004697          	auipc	a3,0x4
    800026a0:	96468693          	addi	a3,a3,-1692 # 80006000 <_trampoline>
    800026a4:	8f95                	sub	a5,a5,a3
    800026a6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800026a8:	0732                	slli	a4,a4,0xc
    800026aa:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ac:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026b2:	18002773          	csrr	a4,satp
    800026b6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b8:	6d38                	ld	a4,88(a0)
    800026ba:	613c                	ld	a5,64(a0)
    800026bc:	6685                	lui	a3,0x1
    800026be:	97b6                	add	a5,a5,a3
    800026c0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026c2:	6d3c                	ld	a5,88(a0)
    800026c4:	00000717          	auipc	a4,0x0
    800026c8:	0f470713          	addi	a4,a4,244 # 800027b8 <usertrap>
    800026cc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026ce:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026d0:	8712                	mv	a4,tp
    800026d2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026dc:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e6:	6f9c                	ld	a5,24(a5)
    800026e8:	14179073          	csrw	sepc,a5
}
    800026ec:	60a2                	ld	ra,8(sp)
    800026ee:	6402                	ld	s0,0(sp)
    800026f0:	0141                	addi	sp,sp,16
    800026f2:	8082                	ret

00000000800026f4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026f4:	1101                	addi	sp,sp,-32
    800026f6:	ec06                	sd	ra,24(sp)
    800026f8:	e822                	sd	s0,16(sp)
    800026fa:	e426                	sd	s1,8(sp)
    800026fc:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026fe:	ba8ff0ef          	jal	ra,80001aa6 <cpuid>
    80002702:	cd19                	beqz	a0,80002720 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002704:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002708:	000f4737          	lui	a4,0xf4
    8000270c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002710:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002712:	14d79073          	csrw	0x14d,a5
}
    80002716:	60e2                	ld	ra,24(sp)
    80002718:	6442                	ld	s0,16(sp)
    8000271a:	64a2                	ld	s1,8(sp)
    8000271c:	6105                	addi	sp,sp,32
    8000271e:	8082                	ret
    acquire(&tickslock);
    80002720:	0023b497          	auipc	s1,0x23b
    80002724:	0c048493          	addi	s1,s1,192 # 8023d7e0 <tickslock>
    80002728:	8526                	mv	a0,s1
    8000272a:	d76fe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    8000272e:	00005517          	auipc	a0,0x5
    80002732:	16a50513          	addi	a0,a0,362 # 80007898 <ticks>
    80002736:	411c                	lw	a5,0(a0)
    80002738:	2785                	addiw	a5,a5,1
    8000273a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000273c:	a51ff0ef          	jal	ra,8000218c <wakeup>
    release(&tickslock);
    80002740:	8526                	mv	a0,s1
    80002742:	df6fe0ef          	jal	ra,80000d38 <release>
    80002746:	bf7d                	j	80002704 <clockintr+0x10>

0000000080002748 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002748:	1101                	addi	sp,sp,-32
    8000274a:	ec06                	sd	ra,24(sp)
    8000274c:	e822                	sd	s0,16(sp)
    8000274e:	e426                	sd	s1,8(sp)
    80002750:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002752:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002756:	57fd                	li	a5,-1
    80002758:	17fe                	slli	a5,a5,0x3f
    8000275a:	07a5                	addi	a5,a5,9
    8000275c:	00f70d63          	beq	a4,a5,80002776 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002760:	57fd                	li	a5,-1
    80002762:	17fe                	slli	a5,a5,0x3f
    80002764:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002766:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002768:	04f70463          	beq	a4,a5,800027b0 <devintr+0x68>
  }
}
    8000276c:	60e2                	ld	ra,24(sp)
    8000276e:	6442                	ld	s0,16(sp)
    80002770:	64a2                	ld	s1,8(sp)
    80002772:	6105                	addi	sp,sp,32
    80002774:	8082                	ret
    int irq = plic_claim();
    80002776:	0a2030ef          	jal	ra,80005818 <plic_claim>
    8000277a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000277c:	47a9                	li	a5,10
    8000277e:	02f50363          	beq	a0,a5,800027a4 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002782:	4785                	li	a5,1
    80002784:	02f50363          	beq	a0,a5,800027aa <devintr+0x62>
    return 1;
    80002788:	4505                	li	a0,1
    } else if(irq){
    8000278a:	d0ed                	beqz	s1,8000276c <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000278c:	85a6                	mv	a1,s1
    8000278e:	00005517          	auipc	a0,0x5
    80002792:	b1250513          	addi	a0,a0,-1262 # 800072a0 <states.0+0x38>
    80002796:	d2dfd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    8000279a:	8526                	mv	a0,s1
    8000279c:	09c030ef          	jal	ra,80005838 <plic_complete>
    return 1;
    800027a0:	4505                	li	a0,1
    800027a2:	b7e9                	j	8000276c <devintr+0x24>
      uartintr();
    800027a4:	9b0fe0ef          	jal	ra,80000954 <uartintr>
    800027a8:	bfcd                	j	8000279a <devintr+0x52>
      virtio_disk_intr();
    800027aa:	4fa030ef          	jal	ra,80005ca4 <virtio_disk_intr>
    800027ae:	b7f5                	j	8000279a <devintr+0x52>
    clockintr();
    800027b0:	f45ff0ef          	jal	ra,800026f4 <clockintr>
    return 2;
    800027b4:	4509                	li	a0,2
    800027b6:	bf5d                	j	8000276c <devintr+0x24>

00000000800027b8 <usertrap>:
{
    800027b8:	7179                	addi	sp,sp,-48
    800027ba:	f406                	sd	ra,40(sp)
    800027bc:	f022                	sd	s0,32(sp)
    800027be:	ec26                	sd	s1,24(sp)
    800027c0:	e84a                	sd	s2,16(sp)
    800027c2:	e44e                	sd	s3,8(sp)
    800027c4:	e052                	sd	s4,0(sp)
    800027c6:	1800                	addi	s0,sp,48
    800027c8:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027cc:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027d4:	1007f793          	andi	a5,a5,256
    800027d8:	e3bd                	bnez	a5,8000283e <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027da:	00003797          	auipc	a5,0x3
    800027de:	f9678793          	addi	a5,a5,-106 # 80005770 <kernelvec>
    800027e2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027e6:	aecff0ef          	jal	ra,80001ad2 <myproc>
    800027ea:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027ec:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ee:	14102773          	csrr	a4,sepc
    800027f2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027f8:	47a1                	li	a5,8
    800027fa:	04f70863          	beq	a4,a5,8000284a <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    800027fe:	f4bff0ef          	jal	ra,80002748 <devintr>
    80002802:	892a                	mv	s2,a0
    80002804:	0c051e63          	bnez	a0,800028e0 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002808:	47b5                	li	a5,13
    8000280a:	08f98663          	beq	s3,a5,80002896 <usertrap+0xde>
    8000280e:	47bd                	li	a5,15
    80002810:	0af99363          	bne	s3,a5,800028b6 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002814:	85d2                	mv	a1,s4
    80002816:	68a8                	ld	a0,80(s1)
    80002818:	d1dfe0ef          	jal	ra,80001534 <cowbreak>
    8000281c:	c531                	beqz	a0,80002868 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    8000281e:	4605                	li	a2,1
    80002820:	85d2                	mv	a1,s4
    80002822:	8526                	mv	a0,s1
    80002824:	8b2ff0ef          	jal	ra,800018d6 <vmafault>
    80002828:	e121                	bnez	a0,80002868 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    8000282a:	4601                	li	a2,0
    8000282c:	85d2                	mv	a1,s4
    8000282e:	68a8                	ld	a0,80(s1)
    80002830:	ebdfe0ef          	jal	ra,800016ec <vmfault>
    80002834:	e915                	bnez	a0,80002868 <usertrap+0xb0>
        setkilled(p);
    80002836:	8526                	mv	a0,s1
    80002838:	b1dff0ef          	jal	ra,80002354 <setkilled>
    8000283c:	a035                	j	80002868 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	a8250513          	addi	a0,a0,-1406 # 800072c0 <states.0+0x58>
    80002846:	f43fd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    8000284a:	b2fff0ef          	jal	ra,80002378 <killed>
    8000284e:	e121                	bnez	a0,8000288e <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002850:	6cb8                	ld	a4,88(s1)
    80002852:	6f1c                	ld	a5,24(a4)
    80002854:	0791                	addi	a5,a5,4
    80002856:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002858:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000285c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002860:	10079073          	csrw	sstatus,a5
    syscall();
    80002864:	27c000ef          	jal	ra,80002ae0 <syscall>
  if(killed(p))
    80002868:	8526                	mv	a0,s1
    8000286a:	b0fff0ef          	jal	ra,80002378 <killed>
    8000286e:	ed35                	bnez	a0,800028ea <usertrap+0x132>
  prepare_return();
    80002870:	e0bff0ef          	jal	ra,8000267a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002874:	68a8                	ld	a0,80(s1)
    80002876:	8131                	srli	a0,a0,0xc
    80002878:	57fd                	li	a5,-1
    8000287a:	17fe                	slli	a5,a5,0x3f
    8000287c:	8d5d                	or	a0,a0,a5
}
    8000287e:	70a2                	ld	ra,40(sp)
    80002880:	7402                	ld	s0,32(sp)
    80002882:	64e2                	ld	s1,24(sp)
    80002884:	6942                	ld	s2,16(sp)
    80002886:	69a2                	ld	s3,8(sp)
    80002888:	6a02                	ld	s4,0(sp)
    8000288a:	6145                	addi	sp,sp,48
    8000288c:	8082                	ret
      kexit(-1);
    8000288e:	557d                	li	a0,-1
    80002890:	9bdff0ef          	jal	ra,8000224c <kexit>
    80002894:	bf75                	j	80002850 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002896:	4601                	li	a2,0
    80002898:	85d2                	mv	a1,s4
    8000289a:	8526                	mv	a0,s1
    8000289c:	83aff0ef          	jal	ra,800018d6 <vmafault>
    800028a0:	f561                	bnez	a0,80002868 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    800028a2:	4605                	li	a2,1
    800028a4:	85d2                	mv	a1,s4
    800028a6:	68a8                	ld	a0,80(s1)
    800028a8:	e45fe0ef          	jal	ra,800016ec <vmfault>
    800028ac:	fd55                	bnez	a0,80002868 <usertrap+0xb0>
        setkilled(p);
    800028ae:	8526                	mv	a0,s1
    800028b0:	aa5ff0ef          	jal	ra,80002354 <setkilled>
    800028b4:	bf55                	j	80002868 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    800028b6:	5890                	lw	a2,48(s1)
    800028b8:	85ce                	mv	a1,s3
    800028ba:	00005517          	auipc	a0,0x5
    800028be:	a2650513          	addi	a0,a0,-1498 # 800072e0 <states.0+0x78>
    800028c2:	c01fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c6:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    800028ca:	8652                	mv	a2,s4
    800028cc:	00005517          	auipc	a0,0x5
    800028d0:	a4450513          	addi	a0,a0,-1468 # 80007310 <states.0+0xa8>
    800028d4:	beffd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    800028d8:	8526                	mv	a0,s1
    800028da:	a7bff0ef          	jal	ra,80002354 <setkilled>
    800028de:	b769                	j	80002868 <usertrap+0xb0>
  if(killed(p))
    800028e0:	8526                	mv	a0,s1
    800028e2:	a97ff0ef          	jal	ra,80002378 <killed>
    800028e6:	c511                	beqz	a0,800028f2 <usertrap+0x13a>
    800028e8:	a011                	j	800028ec <usertrap+0x134>
    800028ea:	4901                	li	s2,0
    kexit(-1);
    800028ec:	557d                	li	a0,-1
    800028ee:	95fff0ef          	jal	ra,8000224c <kexit>
  if(which_dev == 2)
    800028f2:	4789                	li	a5,2
    800028f4:	f6f91ee3          	bne	s2,a5,80002870 <usertrap+0xb8>
    yield();
    800028f8:	81dff0ef          	jal	ra,80002114 <yield>
    800028fc:	bf95                	j	80002870 <usertrap+0xb8>

00000000800028fe <kerneltrap>:
{
    800028fe:	7179                	addi	sp,sp,-48
    80002900:	f406                	sd	ra,40(sp)
    80002902:	f022                	sd	s0,32(sp)
    80002904:	ec26                	sd	s1,24(sp)
    80002906:	e84a                	sd	s2,16(sp)
    80002908:	e44e                	sd	s3,8(sp)
    8000290a:	1800                	addi	s0,sp,48
    8000290c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002910:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002914:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002918:	1004f793          	andi	a5,s1,256
    8000291c:	c795                	beqz	a5,80002948 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002922:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002924:	eb85                	bnez	a5,80002954 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002926:	e23ff0ef          	jal	ra,80002748 <devintr>
    8000292a:	c91d                	beqz	a0,80002960 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000292c:	4789                	li	a5,2
    8000292e:	04f50a63          	beq	a0,a5,80002982 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002932:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002936:	10049073          	csrw	sstatus,s1
}
    8000293a:	70a2                	ld	ra,40(sp)
    8000293c:	7402                	ld	s0,32(sp)
    8000293e:	64e2                	ld	s1,24(sp)
    80002940:	6942                	ld	s2,16(sp)
    80002942:	69a2                	ld	s3,8(sp)
    80002944:	6145                	addi	sp,sp,48
    80002946:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002948:	00005517          	auipc	a0,0x5
    8000294c:	9f050513          	addi	a0,a0,-1552 # 80007338 <states.0+0xd0>
    80002950:	e39fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002954:	00005517          	auipc	a0,0x5
    80002958:	a0c50513          	addi	a0,a0,-1524 # 80007360 <states.0+0xf8>
    8000295c:	e2dfd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002960:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002964:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002968:	85ce                	mv	a1,s3
    8000296a:	00005517          	auipc	a0,0x5
    8000296e:	a1650513          	addi	a0,a0,-1514 # 80007380 <states.0+0x118>
    80002972:	b51fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002976:	00005517          	auipc	a0,0x5
    8000297a:	a3250513          	addi	a0,a0,-1486 # 800073a8 <states.0+0x140>
    8000297e:	e0bfd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002982:	950ff0ef          	jal	ra,80001ad2 <myproc>
    80002986:	d555                	beqz	a0,80002932 <kerneltrap+0x34>
    yield();
    80002988:	f8cff0ef          	jal	ra,80002114 <yield>
    8000298c:	b75d                	j	80002932 <kerneltrap+0x34>

000000008000298e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000298e:	1101                	addi	sp,sp,-32
    80002990:	ec06                	sd	ra,24(sp)
    80002992:	e822                	sd	s0,16(sp)
    80002994:	e426                	sd	s1,8(sp)
    80002996:	1000                	addi	s0,sp,32
    80002998:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000299a:	938ff0ef          	jal	ra,80001ad2 <myproc>
  switch (n) {
    8000299e:	4795                	li	a5,5
    800029a0:	0497e163          	bltu	a5,s1,800029e2 <argraw+0x54>
    800029a4:	048a                	slli	s1,s1,0x2
    800029a6:	00005717          	auipc	a4,0x5
    800029aa:	a3a70713          	addi	a4,a4,-1478 # 800073e0 <states.0+0x178>
    800029ae:	94ba                	add	s1,s1,a4
    800029b0:	409c                	lw	a5,0(s1)
    800029b2:	97ba                	add	a5,a5,a4
    800029b4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029b6:	6d3c                	ld	a5,88(a0)
    800029b8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029ba:	60e2                	ld	ra,24(sp)
    800029bc:	6442                	ld	s0,16(sp)
    800029be:	64a2                	ld	s1,8(sp)
    800029c0:	6105                	addi	sp,sp,32
    800029c2:	8082                	ret
    return p->trapframe->a1;
    800029c4:	6d3c                	ld	a5,88(a0)
    800029c6:	7fa8                	ld	a0,120(a5)
    800029c8:	bfcd                	j	800029ba <argraw+0x2c>
    return p->trapframe->a2;
    800029ca:	6d3c                	ld	a5,88(a0)
    800029cc:	63c8                	ld	a0,128(a5)
    800029ce:	b7f5                	j	800029ba <argraw+0x2c>
    return p->trapframe->a3;
    800029d0:	6d3c                	ld	a5,88(a0)
    800029d2:	67c8                	ld	a0,136(a5)
    800029d4:	b7dd                	j	800029ba <argraw+0x2c>
    return p->trapframe->a4;
    800029d6:	6d3c                	ld	a5,88(a0)
    800029d8:	6bc8                	ld	a0,144(a5)
    800029da:	b7c5                	j	800029ba <argraw+0x2c>
    return p->trapframe->a5;
    800029dc:	6d3c                	ld	a5,88(a0)
    800029de:	6fc8                	ld	a0,152(a5)
    800029e0:	bfe9                	j	800029ba <argraw+0x2c>
  panic("argraw");
    800029e2:	00005517          	auipc	a0,0x5
    800029e6:	9d650513          	addi	a0,a0,-1578 # 800073b8 <states.0+0x150>
    800029ea:	d9ffd0ef          	jal	ra,80000788 <panic>

00000000800029ee <fetchaddr>:
{
    800029ee:	1101                	addi	sp,sp,-32
    800029f0:	ec06                	sd	ra,24(sp)
    800029f2:	e822                	sd	s0,16(sp)
    800029f4:	e426                	sd	s1,8(sp)
    800029f6:	e04a                	sd	s2,0(sp)
    800029f8:	1000                	addi	s0,sp,32
    800029fa:	84aa                	mv	s1,a0
    800029fc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029fe:	8d4ff0ef          	jal	ra,80001ad2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a02:	653c                	ld	a5,72(a0)
    80002a04:	02f4f663          	bgeu	s1,a5,80002a30 <fetchaddr+0x42>
    80002a08:	00848713          	addi	a4,s1,8
    80002a0c:	02e7e463          	bltu	a5,a4,80002a34 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a10:	46a1                	li	a3,8
    80002a12:	8626                	mv	a2,s1
    80002a14:	85ca                	mv	a1,s2
    80002a16:	6928                	ld	a0,80(a0)
    80002a18:	e31fe0ef          	jal	ra,80001848 <copyin>
    80002a1c:	00a03533          	snez	a0,a0
    80002a20:	40a00533          	neg	a0,a0
}
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	64a2                	ld	s1,8(sp)
    80002a2a:	6902                	ld	s2,0(sp)
    80002a2c:	6105                	addi	sp,sp,32
    80002a2e:	8082                	ret
    return -1;
    80002a30:	557d                	li	a0,-1
    80002a32:	bfcd                	j	80002a24 <fetchaddr+0x36>
    80002a34:	557d                	li	a0,-1
    80002a36:	b7fd                	j	80002a24 <fetchaddr+0x36>

0000000080002a38 <fetchstr>:
{
    80002a38:	7179                	addi	sp,sp,-48
    80002a3a:	f406                	sd	ra,40(sp)
    80002a3c:	f022                	sd	s0,32(sp)
    80002a3e:	ec26                	sd	s1,24(sp)
    80002a40:	e84a                	sd	s2,16(sp)
    80002a42:	e44e                	sd	s3,8(sp)
    80002a44:	1800                	addi	s0,sp,48
    80002a46:	892a                	mv	s2,a0
    80002a48:	84ae                	mv	s1,a1
    80002a4a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a4c:	886ff0ef          	jal	ra,80001ad2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a50:	86ce                	mv	a3,s3
    80002a52:	864a                	mv	a2,s2
    80002a54:	85a6                	mv	a1,s1
    80002a56:	6928                	ld	a0,80(a0)
    80002a58:	bc9fe0ef          	jal	ra,80001620 <copyinstr>
    80002a5c:	00054c63          	bltz	a0,80002a74 <fetchstr+0x3c>
  return strlen(buf);
    80002a60:	8526                	mv	a0,s1
    80002a62:	c8afe0ef          	jal	ra,80000eec <strlen>
}
    80002a66:	70a2                	ld	ra,40(sp)
    80002a68:	7402                	ld	s0,32(sp)
    80002a6a:	64e2                	ld	s1,24(sp)
    80002a6c:	6942                	ld	s2,16(sp)
    80002a6e:	69a2                	ld	s3,8(sp)
    80002a70:	6145                	addi	sp,sp,48
    80002a72:	8082                	ret
    return -1;
    80002a74:	557d                	li	a0,-1
    80002a76:	bfc5                	j	80002a66 <fetchstr+0x2e>

0000000080002a78 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	1000                	addi	s0,sp,32
    80002a82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a84:	f0bff0ef          	jal	ra,8000298e <argraw>
    80002a88:	c088                	sw	a0,0(s1)
}
    80002a8a:	60e2                	ld	ra,24(sp)
    80002a8c:	6442                	ld	s0,16(sp)
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret

0000000080002a94 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a94:	1101                	addi	sp,sp,-32
    80002a96:	ec06                	sd	ra,24(sp)
    80002a98:	e822                	sd	s0,16(sp)
    80002a9a:	e426                	sd	s1,8(sp)
    80002a9c:	1000                	addi	s0,sp,32
    80002a9e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aa0:	eefff0ef          	jal	ra,8000298e <argraw>
    80002aa4:	e088                	sd	a0,0(s1)
}
    80002aa6:	60e2                	ld	ra,24(sp)
    80002aa8:	6442                	ld	s0,16(sp)
    80002aaa:	64a2                	ld	s1,8(sp)
    80002aac:	6105                	addi	sp,sp,32
    80002aae:	8082                	ret

0000000080002ab0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ab0:	7179                	addi	sp,sp,-48
    80002ab2:	f406                	sd	ra,40(sp)
    80002ab4:	f022                	sd	s0,32(sp)
    80002ab6:	ec26                	sd	s1,24(sp)
    80002ab8:	e84a                	sd	s2,16(sp)
    80002aba:	1800                	addi	s0,sp,48
    80002abc:	84ae                	mv	s1,a1
    80002abe:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ac0:	fd840593          	addi	a1,s0,-40
    80002ac4:	fd1ff0ef          	jal	ra,80002a94 <argaddr>
  return fetchstr(addr, buf, max);
    80002ac8:	864a                	mv	a2,s2
    80002aca:	85a6                	mv	a1,s1
    80002acc:	fd843503          	ld	a0,-40(s0)
    80002ad0:	f69ff0ef          	jal	ra,80002a38 <fetchstr>
}
    80002ad4:	70a2                	ld	ra,40(sp)
    80002ad6:	7402                	ld	s0,32(sp)
    80002ad8:	64e2                	ld	s1,24(sp)
    80002ada:	6942                	ld	s2,16(sp)
    80002adc:	6145                	addi	sp,sp,48
    80002ade:	8082                	ret

0000000080002ae0 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002ae0:	1101                	addi	sp,sp,-32
    80002ae2:	ec06                	sd	ra,24(sp)
    80002ae4:	e822                	sd	s0,16(sp)
    80002ae6:	e426                	sd	s1,8(sp)
    80002ae8:	e04a                	sd	s2,0(sp)
    80002aea:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002aec:	fe7fe0ef          	jal	ra,80001ad2 <myproc>
    80002af0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002af2:	05853903          	ld	s2,88(a0)
    80002af6:	0a893783          	ld	a5,168(s2)
    80002afa:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002afe:	37fd                	addiw	a5,a5,-1
    80002b00:	4759                	li	a4,22
    80002b02:	00f76f63          	bltu	a4,a5,80002b20 <syscall+0x40>
    80002b06:	00369713          	slli	a4,a3,0x3
    80002b0a:	00005797          	auipc	a5,0x5
    80002b0e:	8ee78793          	addi	a5,a5,-1810 # 800073f8 <syscalls>
    80002b12:	97ba                	add	a5,a5,a4
    80002b14:	639c                	ld	a5,0(a5)
    80002b16:	c789                	beqz	a5,80002b20 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b18:	9782                	jalr	a5
    80002b1a:	06a93823          	sd	a0,112(s2)
    80002b1e:	a829                	j	80002b38 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b20:	15848613          	addi	a2,s1,344
    80002b24:	588c                	lw	a1,48(s1)
    80002b26:	00005517          	auipc	a0,0x5
    80002b2a:	89a50513          	addi	a0,a0,-1894 # 800073c0 <states.0+0x158>
    80002b2e:	995fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b32:	6cbc                	ld	a5,88(s1)
    80002b34:	577d                	li	a4,-1
    80002b36:	fbb8                	sd	a4,112(a5)
  }
}
    80002b38:	60e2                	ld	ra,24(sp)
    80002b3a:	6442                	ld	s0,16(sp)
    80002b3c:	64a2                	ld	s1,8(sp)
    80002b3e:	6902                	ld	s2,0(sp)
    80002b40:	6105                	addi	sp,sp,32
    80002b42:	8082                	ret

0000000080002b44 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b44:	1101                	addi	sp,sp,-32
    80002b46:	ec06                	sd	ra,24(sp)
    80002b48:	e822                	sd	s0,16(sp)
    80002b4a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b4c:	fec40593          	addi	a1,s0,-20
    80002b50:	4501                	li	a0,0
    80002b52:	f27ff0ef          	jal	ra,80002a78 <argint>
  kexit(n);
    80002b56:	fec42503          	lw	a0,-20(s0)
    80002b5a:	ef2ff0ef          	jal	ra,8000224c <kexit>
  return 0;  // not reached
}
    80002b5e:	4501                	li	a0,0
    80002b60:	60e2                	ld	ra,24(sp)
    80002b62:	6442                	ld	s0,16(sp)
    80002b64:	6105                	addi	sp,sp,32
    80002b66:	8082                	ret

0000000080002b68 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b68:	1141                	addi	sp,sp,-16
    80002b6a:	e406                	sd	ra,8(sp)
    80002b6c:	e022                	sd	s0,0(sp)
    80002b6e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b70:	f63fe0ef          	jal	ra,80001ad2 <myproc>
}
    80002b74:	5908                	lw	a0,48(a0)
    80002b76:	60a2                	ld	ra,8(sp)
    80002b78:	6402                	ld	s0,0(sp)
    80002b7a:	0141                	addi	sp,sp,16
    80002b7c:	8082                	ret

0000000080002b7e <sys_fork>:

uint64
sys_fork(void)
{
    80002b7e:	1141                	addi	sp,sp,-16
    80002b80:	e406                	sd	ra,8(sp)
    80002b82:	e022                	sd	s0,0(sp)
    80002b84:	0800                	addi	s0,sp,16
  return kfork();
    80002b86:	b16ff0ef          	jal	ra,80001e9c <kfork>
}
    80002b8a:	60a2                	ld	ra,8(sp)
    80002b8c:	6402                	ld	s0,0(sp)
    80002b8e:	0141                	addi	sp,sp,16
    80002b90:	8082                	ret

0000000080002b92 <sys_wait>:

uint64
sys_wait(void)
{
    80002b92:	1101                	addi	sp,sp,-32
    80002b94:	ec06                	sd	ra,24(sp)
    80002b96:	e822                	sd	s0,16(sp)
    80002b98:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b9a:	fe840593          	addi	a1,s0,-24
    80002b9e:	4501                	li	a0,0
    80002ba0:	ef5ff0ef          	jal	ra,80002a94 <argaddr>
  return kwait(p);
    80002ba4:	fe843503          	ld	a0,-24(s0)
    80002ba8:	ffaff0ef          	jal	ra,800023a2 <kwait>
}
    80002bac:	60e2                	ld	ra,24(sp)
    80002bae:	6442                	ld	s0,16(sp)
    80002bb0:	6105                	addi	sp,sp,32
    80002bb2:	8082                	ret

0000000080002bb4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bb4:	7179                	addi	sp,sp,-48
    80002bb6:	f406                	sd	ra,40(sp)
    80002bb8:	f022                	sd	s0,32(sp)
    80002bba:	ec26                	sd	s1,24(sp)
    80002bbc:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002bbe:	fd840593          	addi	a1,s0,-40
    80002bc2:	4501                	li	a0,0
    80002bc4:	eb5ff0ef          	jal	ra,80002a78 <argint>
  argint(1, &t);
    80002bc8:	fdc40593          	addi	a1,s0,-36
    80002bcc:	4505                	li	a0,1
    80002bce:	eabff0ef          	jal	ra,80002a78 <argint>
  addr = myproc()->sz;
    80002bd2:	f01fe0ef          	jal	ra,80001ad2 <myproc>
    80002bd6:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002bd8:	fdc42703          	lw	a4,-36(s0)
    80002bdc:	4785                	li	a5,1
    80002bde:	02f70763          	beq	a4,a5,80002c0c <sys_sbrk+0x58>
    80002be2:	fd842783          	lw	a5,-40(s0)
    80002be6:	0207c363          	bltz	a5,80002c0c <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bea:	97a6                	add	a5,a5,s1
    80002bec:	0297ee63          	bltu	a5,s1,80002c28 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002bf0:	02000737          	lui	a4,0x2000
    80002bf4:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bf6:	0736                	slli	a4,a4,0xd
    80002bf8:	02f76a63          	bltu	a4,a5,80002c2c <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002bfc:	ed7fe0ef          	jal	ra,80001ad2 <myproc>
    80002c00:	fd842703          	lw	a4,-40(s0)
    80002c04:	653c                	ld	a5,72(a0)
    80002c06:	97ba                	add	a5,a5,a4
    80002c08:	e53c                	sd	a5,72(a0)
    80002c0a:	a039                	j	80002c18 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002c0c:	fd842503          	lw	a0,-40(s0)
    80002c10:	a2aff0ef          	jal	ra,80001e3a <growproc>
    80002c14:	00054863          	bltz	a0,80002c24 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c18:	8526                	mv	a0,s1
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6145                	addi	sp,sp,48
    80002c22:	8082                	ret
      return -1;
    80002c24:	54fd                	li	s1,-1
    80002c26:	bfcd                	j	80002c18 <sys_sbrk+0x64>
      return -1;
    80002c28:	54fd                	li	s1,-1
    80002c2a:	b7fd                	j	80002c18 <sys_sbrk+0x64>
      return -1;
    80002c2c:	54fd                	li	s1,-1
    80002c2e:	b7ed                	j	80002c18 <sys_sbrk+0x64>

0000000080002c30 <sys_pause>:

uint64
sys_pause(void)
{
    80002c30:	7139                	addi	sp,sp,-64
    80002c32:	fc06                	sd	ra,56(sp)
    80002c34:	f822                	sd	s0,48(sp)
    80002c36:	f426                	sd	s1,40(sp)
    80002c38:	f04a                	sd	s2,32(sp)
    80002c3a:	ec4e                	sd	s3,24(sp)
    80002c3c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c3e:	fcc40593          	addi	a1,s0,-52
    80002c42:	4501                	li	a0,0
    80002c44:	e35ff0ef          	jal	ra,80002a78 <argint>
  if(n < 0)
    80002c48:	fcc42783          	lw	a5,-52(s0)
    80002c4c:	0607c563          	bltz	a5,80002cb6 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c50:	0023b517          	auipc	a0,0x23b
    80002c54:	b9050513          	addi	a0,a0,-1136 # 8023d7e0 <tickslock>
    80002c58:	848fe0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002c5c:	00005917          	auipc	s2,0x5
    80002c60:	c3c92903          	lw	s2,-964(s2) # 80007898 <ticks>
  while(ticks - ticks0 < n){
    80002c64:	fcc42783          	lw	a5,-52(s0)
    80002c68:	cb8d                	beqz	a5,80002c9a <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c6a:	0023b997          	auipc	s3,0x23b
    80002c6e:	b7698993          	addi	s3,s3,-1162 # 8023d7e0 <tickslock>
    80002c72:	00005497          	auipc	s1,0x5
    80002c76:	c2648493          	addi	s1,s1,-986 # 80007898 <ticks>
    if(killed(myproc())){
    80002c7a:	e59fe0ef          	jal	ra,80001ad2 <myproc>
    80002c7e:	efaff0ef          	jal	ra,80002378 <killed>
    80002c82:	ed0d                	bnez	a0,80002cbc <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c84:	85ce                	mv	a1,s3
    80002c86:	8526                	mv	a0,s1
    80002c88:	cb8ff0ef          	jal	ra,80002140 <sleep>
  while(ticks - ticks0 < n){
    80002c8c:	409c                	lw	a5,0(s1)
    80002c8e:	412787bb          	subw	a5,a5,s2
    80002c92:	fcc42703          	lw	a4,-52(s0)
    80002c96:	fee7e2e3          	bltu	a5,a4,80002c7a <sys_pause+0x4a>
  }
  release(&tickslock);
    80002c9a:	0023b517          	auipc	a0,0x23b
    80002c9e:	b4650513          	addi	a0,a0,-1210 # 8023d7e0 <tickslock>
    80002ca2:	896fe0ef          	jal	ra,80000d38 <release>
  return 0;
    80002ca6:	4501                	li	a0,0
}
    80002ca8:	70e2                	ld	ra,56(sp)
    80002caa:	7442                	ld	s0,48(sp)
    80002cac:	74a2                	ld	s1,40(sp)
    80002cae:	7902                	ld	s2,32(sp)
    80002cb0:	69e2                	ld	s3,24(sp)
    80002cb2:	6121                	addi	sp,sp,64
    80002cb4:	8082                	ret
    n = 0;
    80002cb6:	fc042623          	sw	zero,-52(s0)
    80002cba:	bf59                	j	80002c50 <sys_pause+0x20>
      release(&tickslock);
    80002cbc:	0023b517          	auipc	a0,0x23b
    80002cc0:	b2450513          	addi	a0,a0,-1244 # 8023d7e0 <tickslock>
    80002cc4:	874fe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002cc8:	557d                	li	a0,-1
    80002cca:	bff9                	j	80002ca8 <sys_pause+0x78>

0000000080002ccc <sys_kill>:

uint64
sys_kill(void)
{
    80002ccc:	1101                	addi	sp,sp,-32
    80002cce:	ec06                	sd	ra,24(sp)
    80002cd0:	e822                	sd	s0,16(sp)
    80002cd2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cd4:	fec40593          	addi	a1,s0,-20
    80002cd8:	4501                	li	a0,0
    80002cda:	d9fff0ef          	jal	ra,80002a78 <argint>
  return kkill(pid);
    80002cde:	fec42503          	lw	a0,-20(s0)
    80002ce2:	e0cff0ef          	jal	ra,800022ee <kkill>
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	6105                	addi	sp,sp,32
    80002cec:	8082                	ret

0000000080002cee <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cf8:	0023b517          	auipc	a0,0x23b
    80002cfc:	ae850513          	addi	a0,a0,-1304 # 8023d7e0 <tickslock>
    80002d00:	fa1fd0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002d04:	00005497          	auipc	s1,0x5
    80002d08:	b944a483          	lw	s1,-1132(s1) # 80007898 <ticks>
  release(&tickslock);
    80002d0c:	0023b517          	auipc	a0,0x23b
    80002d10:	ad450513          	addi	a0,a0,-1324 # 8023d7e0 <tickslock>
    80002d14:	824fe0ef          	jal	ra,80000d38 <release>
  return xticks;
}
    80002d18:	02049513          	slli	a0,s1,0x20
    80002d1c:	9101                	srli	a0,a0,0x20
    80002d1e:	60e2                	ld	ra,24(sp)
    80002d20:	6442                	ld	s0,16(sp)
    80002d22:	64a2                	ld	s1,8(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret

0000000080002d28 <vma_find>:
  return 0;
}

struct vma*
vma_find(struct proc *p, uint64 va)
{
    80002d28:	1141                	addi	sp,sp,-16
    80002d2a:	e422                	sd	s0,8(sp)
    80002d2c:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002d2e:	16850793          	addi	a5,a0,360
    80002d32:	4701                	li	a4,0
    80002d34:	4841                	li	a6,16
    80002d36:	a031                	j	80002d42 <vma_find+0x1a>
    80002d38:	2705                	addiw	a4,a4,1
    80002d3a:	02078793          	addi	a5,a5,32
    80002d3e:	01070f63          	beq	a4,a6,80002d5c <vma_find+0x34>
    if(!p->vmas[i].used) continue;
    80002d42:	4394                	lw	a3,0(a5)
    80002d44:	daf5                	beqz	a3,80002d38 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    80002d46:	6794                	ld	a3,8(a5)
    80002d48:	fed5e8e3          	bltu	a1,a3,80002d38 <vma_find+0x10>
    80002d4c:	6b94                	ld	a3,16(a5)
    80002d4e:	fed5f5e3          	bgeu	a1,a3,80002d38 <vma_find+0x10>
      return &p->vmas[i];
    80002d52:	0716                	slli	a4,a4,0x5
    80002d54:	16870713          	addi	a4,a4,360
    80002d58:	953a                	add	a0,a0,a4
    80002d5a:	a011                	j	80002d5e <vma_find+0x36>
  }
  return 0;
    80002d5c:	4501                	li	a0,0
}
    80002d5e:	6422                	ld	s0,8(sp)
    80002d60:	0141                	addi	sp,sp,16
    80002d62:	8082                	ret

0000000080002d64 <sys_mmap>:

uint64
sys_mmap(void)
{
    80002d64:	7179                	addi	sp,sp,-48
    80002d66:	f406                	sd	ra,40(sp)
    80002d68:	f022                	sd	s0,32(sp)
    80002d6a:	1800                	addi	s0,sp,48
  uint64 addr;
  int len, prot, flags;

  argaddr(0, &addr);
    80002d6c:	fe840593          	addi	a1,s0,-24
    80002d70:	4501                	li	a0,0
    80002d72:	d23ff0ef          	jal	ra,80002a94 <argaddr>
  argint(1, &len);
    80002d76:	fe440593          	addi	a1,s0,-28
    80002d7a:	4505                	li	a0,1
    80002d7c:	cfdff0ef          	jal	ra,80002a78 <argint>
  argint(2, &prot);
    80002d80:	fe040593          	addi	a1,s0,-32
    80002d84:	4509                	li	a0,2
    80002d86:	cf3ff0ef          	jal	ra,80002a78 <argint>
  argint(3, &flags);
    80002d8a:	fdc40593          	addi	a1,s0,-36
    80002d8e:	450d                	li	a0,3
    80002d90:	ce9ff0ef          	jal	ra,80002a78 <argint>

  if(addr != 0) return (uint64)-1;
    80002d94:	fe843783          	ld	a5,-24(s0)
    80002d98:	557d                	li	a0,-1
    80002d9a:	e7f9                	bnez	a5,80002e68 <sys_mmap+0x104>
  if(len <= 0) return (uint64)-1;
    80002d9c:	fe442783          	lw	a5,-28(s0)
    80002da0:	08f05663          	blez	a5,80002e2c <sys_mmap+0xc8>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    80002da4:	fdc42783          	lw	a5,-36(s0)
    80002da8:	8b85                	andi	a5,a5,1
    80002daa:	cfdd                	beqz	a5,80002e68 <sys_mmap+0x104>
  if((prot & PROT_READ) == 0) return (uint64)-1; // 最小版：至少可读
    80002dac:	fe042783          	lw	a5,-32(s0)
    80002db0:	8b85                	andi	a5,a5,1
    80002db2:	cbdd                	beqz	a5,80002e68 <sys_mmap+0x104>

  struct proc *p = myproc();
    80002db4:	d1ffe0ef          	jal	ra,80001ad2 <myproc>
    80002db8:	8f2a                	mv	t5,a0
  uint64 plen = PGROUNDUP((uint64)len);
    80002dba:	fe442303          	lw	t1,-28(s0)
    80002dbe:	6785                	lui	a5,0x1
    80002dc0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002dc2:	933e                	add	t1,t1,a5
    80002dc4:	77fd                	lui	a5,0xfffff
    80002dc6:	00f37333          	and	t1,t1,a5
  for(int i = 0; i < NVMA; i++){
    80002dca:	16850e93          	addi	t4,a0,360
  uint64 plen = PGROUNDUP((uint64)len);
    80002dce:	87f6                	mv	a5,t4
  for(int i = 0; i < NVMA; i++){
    80002dd0:	4801                	li	a6,0
    80002dd2:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80002dd4:	4398                	lw	a4,0(a5)
    80002dd6:	cb01                	beqz	a4,80002de6 <sys_mmap+0x82>
  for(int i = 0; i < NVMA; i++){
    80002dd8:	2805                	addiw	a6,a6,1
    80002dda:	02078793          	addi	a5,a5,32 # fffffffffffff020 <end+0xffffffff7fdb6460>
    80002dde:	fed81be3          	bne	a6,a3,80002dd4 <sys_mmap+0x70>

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80002de2:	557d                	li	a0,-1
    80002de4:	a051                	j	80002e68 <sys_mmap+0x104>
    uint64 end   = va + len;
    80002de6:	400005b7          	lui	a1,0x40000
    80002dea:	959a                	add	a1,a1,t1
    if(end >= MAXVA) return 0;
    80002dec:	57fd                	li	a5,-1
    80002dee:	83e9                	srli	a5,a5,0x1a
    80002df0:	04b7e063          	bltu	a5,a1,80002e30 <sys_mmap+0xcc>
    80002df4:	40000537          	lui	a0,0x40000
    80002df8:	6885                	lui	a7,0x1
    80002dfa:	368f0613          	addi	a2,t5,872
    80002dfe:	8e3e                	mv	t3,a5
    80002e00:	a025                	j	80002e28 <sys_mmap+0xc4>
  for(int i = 0; i < NVMA; i++){
    80002e02:	02078793          	addi	a5,a5,32
    80002e06:	02c78d63          	beq	a5,a2,80002e40 <sys_mmap+0xdc>
    if(!p->vmas[i].used) continue;
    80002e0a:	4398                	lw	a4,0(a5)
    80002e0c:	db7d                	beqz	a4,80002e02 <sys_mmap+0x9e>
    if(!(end <= s || start >= e))
    80002e0e:	6798                	ld	a4,8(a5)
    80002e10:	feb779e3          	bgeu	a4,a1,80002e02 <sys_mmap+0x9e>
    80002e14:	6b98                	ld	a4,16(a5)
    80002e16:	fee576e3          	bgeu	a0,a4,80002e02 <sys_mmap+0x9e>
  for(int tries = 0; tries < 4096; tries++){
    80002e1a:	38fd                	addiw	a7,a7,-1 # fff <_entry-0x7ffff001>
    80002e1c:	02088063          	beqz	a7,80002e3c <sys_mmap+0xd8>
    uint64 end   = va + len;
    80002e20:	959a                	add	a1,a1,t1
    if(end >= MAXVA) return 0;
    80002e22:	951a                	add	a0,a0,t1
    80002e24:	00be6863          	bltu	t3,a1,80002e34 <sys_mmap+0xd0>
    80002e28:	87f6                	mv	a5,t4
    80002e2a:	b7c5                	j	80002e0a <sys_mmap+0xa6>
  if(len <= 0) return (uint64)-1;
    80002e2c:	557d                	li	a0,-1
    80002e2e:	a82d                	j	80002e68 <sys_mmap+0x104>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;
    80002e30:	557d                	li	a0,-1
    80002e32:	a81d                	j	80002e68 <sys_mmap+0x104>
    80002e34:	557d                	li	a0,-1
    80002e36:	a80d                	j	80002e68 <sys_mmap+0x104>
    80002e38:	557d                	li	a0,-1
    80002e3a:	a03d                	j	80002e68 <sys_mmap+0x104>
    80002e3c:	557d                	li	a0,-1
    80002e3e:	a02d                	j	80002e68 <sys_mmap+0x104>
    80002e40:	dd65                	beqz	a0,80002e38 <sys_mmap+0xd4>

  v->used = 1;
    80002e42:	00581793          	slli	a5,a6,0x5
    80002e46:	97fa                	add	a5,a5,t5
    80002e48:	4705                	li	a4,1
    80002e4a:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    80002e4e:	16a7b823          	sd	a0,368(a5)
  v->end = va + plen;
    80002e52:	932a                	add	t1,t1,a0
    80002e54:	1667bc23          	sd	t1,376(a5)
  v->prot = prot;
    80002e58:	fe042703          	lw	a4,-32(s0)
    80002e5c:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    80002e60:	fdc42703          	lw	a4,-36(s0)
    80002e64:	18e7a223          	sw	a4,388(a5)

  return va;
}
    80002e68:	70a2                	ld	ra,40(sp)
    80002e6a:	7402                	ld	s0,32(sp)
    80002e6c:	6145                	addi	sp,sp,48
    80002e6e:	8082                	ret

0000000080002e70 <sys_munmap>:

uint64
sys_munmap(void)
{
    80002e70:	7139                	addi	sp,sp,-64
    80002e72:	fc06                	sd	ra,56(sp)
    80002e74:	f822                	sd	s0,48(sp)
    80002e76:	f426                	sd	s1,40(sp)
    80002e78:	f04a                	sd	s2,32(sp)
    80002e7a:	ec4e                	sd	s3,24(sp)
    80002e7c:	e852                	sd	s4,16(sp)
    80002e7e:	0080                	addi	s0,sp,64
  uint64 addr;
  int len;

  argaddr(0, &addr);
    80002e80:	fc840593          	addi	a1,s0,-56
    80002e84:	4501                	li	a0,0
    80002e86:	c0fff0ef          	jal	ra,80002a94 <argaddr>
  argint(1, &len);
    80002e8a:	fc440593          	addi	a1,s0,-60
    80002e8e:	4505                	li	a0,1
    80002e90:	be9ff0ef          	jal	ra,80002a78 <argint>

  if(addr % PGSIZE != 0) return (uint64)-1;   // 要求页对齐
    80002e94:	fc843783          	ld	a5,-56(s0)
    80002e98:	17d2                	slli	a5,a5,0x34
    80002e9a:	59fd                	li	s3,-1
    80002e9c:	e3a5                	bnez	a5,80002efc <sys_munmap+0x8c>
    80002e9e:	0347d993          	srli	s3,a5,0x34
  if(len <= 0) return (uint64)-1;
    80002ea2:	fc442783          	lw	a5,-60(s0)
    80002ea6:	08f05763          	blez	a5,80002f34 <sys_munmap+0xc4>

  struct proc *p = myproc();
    80002eaa:	c29fe0ef          	jal	ra,80001ad2 <myproc>
    80002eae:	892a                	mv	s2,a0
  uint64 plen = PGROUNDUP((uint64)len);
    80002eb0:	fc442603          	lw	a2,-60(s0)
    80002eb4:	6785                	lui	a5,0x1
    80002eb6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002eb8:	963e                	add	a2,a2,a5
    80002eba:	77fd                	lui	a5,0xfffff
    80002ebc:	00f67533          	and	a0,a2,a5
  // 找到起点匹配的 vma
  struct vma *v = 0;
  for(int i = 0; i < NVMA; i++){
    if(p->vmas[i].used && p->vmas[i].start == addr){
    80002ec0:	fc843583          	ld	a1,-56(s0)
    80002ec4:	16890793          	addi	a5,s2,360
  for(int i = 0; i < NVMA; i++){
    80002ec8:	4481                	li	s1,0
    80002eca:	46c1                	li	a3,16
    80002ecc:	a031                	j	80002ed8 <sys_munmap+0x68>
    80002ece:	2485                	addiw	s1,s1,1
    80002ed0:	02078793          	addi	a5,a5,32 # fffffffffffff020 <end+0xffffffff7fdb6460>
    80002ed4:	02d48363          	beq	s1,a3,80002efa <sys_munmap+0x8a>
    if(p->vmas[i].used && p->vmas[i].start == addr){
    80002ed8:	4398                	lw	a4,0(a5)
    80002eda:	db75                	beqz	a4,80002ece <sys_munmap+0x5e>
    80002edc:	6798                	ld	a4,8(a5)
    80002ede:	feb718e3          	bne	a4,a1,80002ece <sys_munmap+0x5e>
      v = &p->vmas[i];
      break;
    }
  }
  if(v == 0) return (uint64)-1;
  if(plen != (v->end - v->start)) return (uint64)-1;
    80002ee2:	00549a13          	slli	s4,s1,0x5
    80002ee6:	9a4a                	add	s4,s4,s2
    80002ee8:	170a3583          	ld	a1,368(s4)
    80002eec:	178a3783          	ld	a5,376(s4)
    80002ef0:	8f8d                	sub	a5,a5,a1
    80002ef2:	00a78e63          	beq	a5,a0,80002f0e <sys_munmap+0x9e>
    80002ef6:	59fd                	li	s3,-1
    80002ef8:	a011                	j	80002efc <sys_munmap+0x8c>
  if(v == 0) return (uint64)-1;
    80002efa:	59fd                	li	s3,-1
  v->used = 0;
  v->start = v->end = 0;
  v->prot = v->flags = 0;

  return 0;
}
    80002efc:	854e                	mv	a0,s3
    80002efe:	70e2                	ld	ra,56(sp)
    80002f00:	7442                	ld	s0,48(sp)
    80002f02:	74a2                	ld	s1,40(sp)
    80002f04:	7902                	ld	s2,32(sp)
    80002f06:	69e2                	ld	s3,24(sp)
    80002f08:	6a42                	ld	s4,16(sp)
    80002f0a:	6121                	addi	sp,sp,64
    80002f0c:	8082                	ret
  uvmunmap(p->pagetable, v->start, plen/PGSIZE, 1);
    80002f0e:	4685                	li	a3,1
    80002f10:	8231                	srli	a2,a2,0xc
    80002f12:	05093503          	ld	a0,80(s2)
    80002f16:	b7efe0ef          	jal	ra,80001294 <uvmunmap>
  v->used = 0;
    80002f1a:	160a2423          	sw	zero,360(s4)
  v->start = v->end = 0;
    80002f1e:	0496                	slli	s1,s1,0x5
    80002f20:	9926                	add	s2,s2,s1
    80002f22:	16093c23          	sd	zero,376(s2)
    80002f26:	160a3823          	sd	zero,368(s4)
  v->prot = v->flags = 0;
    80002f2a:	18092223          	sw	zero,388(s2)
    80002f2e:	18092023          	sw	zero,384(s2)
  return 0;
    80002f32:	b7e9                	j	80002efc <sys_munmap+0x8c>
  if(len <= 0) return (uint64)-1;
    80002f34:	59fd                	li	s3,-1
    80002f36:	b7d9                	j	80002efc <sys_munmap+0x8c>

0000000080002f38 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f38:	7179                	addi	sp,sp,-48
    80002f3a:	f406                	sd	ra,40(sp)
    80002f3c:	f022                	sd	s0,32(sp)
    80002f3e:	ec26                	sd	s1,24(sp)
    80002f40:	e84a                	sd	s2,16(sp)
    80002f42:	e44e                	sd	s3,8(sp)
    80002f44:	e052                	sd	s4,0(sp)
    80002f46:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f48:	00004597          	auipc	a1,0x4
    80002f4c:	57058593          	addi	a1,a1,1392 # 800074b8 <syscalls+0xc0>
    80002f50:	0023b517          	auipc	a0,0x23b
    80002f54:	8a850513          	addi	a0,a0,-1880 # 8023d7f8 <bcache>
    80002f58:	cc9fd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f5c:	00243797          	auipc	a5,0x243
    80002f60:	89c78793          	addi	a5,a5,-1892 # 802457f8 <bcache+0x8000>
    80002f64:	00243717          	auipc	a4,0x243
    80002f68:	afc70713          	addi	a4,a4,-1284 # 80245a60 <bcache+0x8268>
    80002f6c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f70:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f74:	0023b497          	auipc	s1,0x23b
    80002f78:	89c48493          	addi	s1,s1,-1892 # 8023d810 <bcache+0x18>
    b->next = bcache.head.next;
    80002f7c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f7e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f80:	00004a17          	auipc	s4,0x4
    80002f84:	540a0a13          	addi	s4,s4,1344 # 800074c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f88:	2b893783          	ld	a5,696(s2)
    80002f8c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f8e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f92:	85d2                	mv	a1,s4
    80002f94:	01048513          	addi	a0,s1,16
    80002f98:	302010ef          	jal	ra,8000429a <initsleeplock>
    bcache.head.next->prev = b;
    80002f9c:	2b893783          	ld	a5,696(s2)
    80002fa0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002fa2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fa6:	45848493          	addi	s1,s1,1112
    80002faa:	fd349fe3          	bne	s1,s3,80002f88 <binit+0x50>
  }
}
    80002fae:	70a2                	ld	ra,40(sp)
    80002fb0:	7402                	ld	s0,32(sp)
    80002fb2:	64e2                	ld	s1,24(sp)
    80002fb4:	6942                	ld	s2,16(sp)
    80002fb6:	69a2                	ld	s3,8(sp)
    80002fb8:	6a02                	ld	s4,0(sp)
    80002fba:	6145                	addi	sp,sp,48
    80002fbc:	8082                	ret

0000000080002fbe <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fbe:	7179                	addi	sp,sp,-48
    80002fc0:	f406                	sd	ra,40(sp)
    80002fc2:	f022                	sd	s0,32(sp)
    80002fc4:	ec26                	sd	s1,24(sp)
    80002fc6:	e84a                	sd	s2,16(sp)
    80002fc8:	e44e                	sd	s3,8(sp)
    80002fca:	1800                	addi	s0,sp,48
    80002fcc:	892a                	mv	s2,a0
    80002fce:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fd0:	0023b517          	auipc	a0,0x23b
    80002fd4:	82850513          	addi	a0,a0,-2008 # 8023d7f8 <bcache>
    80002fd8:	cc9fd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fdc:	00243497          	auipc	s1,0x243
    80002fe0:	ad44b483          	ld	s1,-1324(s1) # 80245ab0 <bcache+0x82b8>
    80002fe4:	00243797          	auipc	a5,0x243
    80002fe8:	a7c78793          	addi	a5,a5,-1412 # 80245a60 <bcache+0x8268>
    80002fec:	02f48b63          	beq	s1,a5,80003022 <bread+0x64>
    80002ff0:	873e                	mv	a4,a5
    80002ff2:	a021                	j	80002ffa <bread+0x3c>
    80002ff4:	68a4                	ld	s1,80(s1)
    80002ff6:	02e48663          	beq	s1,a4,80003022 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ffa:	449c                	lw	a5,8(s1)
    80002ffc:	ff279ce3          	bne	a5,s2,80002ff4 <bread+0x36>
    80003000:	44dc                	lw	a5,12(s1)
    80003002:	ff3799e3          	bne	a5,s3,80002ff4 <bread+0x36>
      b->refcnt++;
    80003006:	40bc                	lw	a5,64(s1)
    80003008:	2785                	addiw	a5,a5,1
    8000300a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000300c:	0023a517          	auipc	a0,0x23a
    80003010:	7ec50513          	addi	a0,a0,2028 # 8023d7f8 <bcache>
    80003014:	d25fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003018:	01048513          	addi	a0,s1,16
    8000301c:	2b4010ef          	jal	ra,800042d0 <acquiresleep>
      return b;
    80003020:	a889                	j	80003072 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003022:	00243497          	auipc	s1,0x243
    80003026:	a864b483          	ld	s1,-1402(s1) # 80245aa8 <bcache+0x82b0>
    8000302a:	00243797          	auipc	a5,0x243
    8000302e:	a3678793          	addi	a5,a5,-1482 # 80245a60 <bcache+0x8268>
    80003032:	00f48863          	beq	s1,a5,80003042 <bread+0x84>
    80003036:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003038:	40bc                	lw	a5,64(s1)
    8000303a:	cb91                	beqz	a5,8000304e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000303c:	64a4                	ld	s1,72(s1)
    8000303e:	fee49de3          	bne	s1,a4,80003038 <bread+0x7a>
  panic("bget: no buffers");
    80003042:	00004517          	auipc	a0,0x4
    80003046:	48650513          	addi	a0,a0,1158 # 800074c8 <syscalls+0xd0>
    8000304a:	f3efd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    8000304e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003052:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003056:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000305a:	4785                	li	a5,1
    8000305c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000305e:	0023a517          	auipc	a0,0x23a
    80003062:	79a50513          	addi	a0,a0,1946 # 8023d7f8 <bcache>
    80003066:	cd3fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    8000306a:	01048513          	addi	a0,s1,16
    8000306e:	262010ef          	jal	ra,800042d0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003072:	409c                	lw	a5,0(s1)
    80003074:	cb89                	beqz	a5,80003086 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003076:	8526                	mv	a0,s1
    80003078:	70a2                	ld	ra,40(sp)
    8000307a:	7402                	ld	s0,32(sp)
    8000307c:	64e2                	ld	s1,24(sp)
    8000307e:	6942                	ld	s2,16(sp)
    80003080:	69a2                	ld	s3,8(sp)
    80003082:	6145                	addi	sp,sp,48
    80003084:	8082                	ret
    virtio_disk_rw(b, 0);
    80003086:	4581                	li	a1,0
    80003088:	8526                	mv	a0,s1
    8000308a:	201020ef          	jal	ra,80005a8a <virtio_disk_rw>
    b->valid = 1;
    8000308e:	4785                	li	a5,1
    80003090:	c09c                	sw	a5,0(s1)
  return b;
    80003092:	b7d5                	j	80003076 <bread+0xb8>

0000000080003094 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003094:	1101                	addi	sp,sp,-32
    80003096:	ec06                	sd	ra,24(sp)
    80003098:	e822                	sd	s0,16(sp)
    8000309a:	e426                	sd	s1,8(sp)
    8000309c:	1000                	addi	s0,sp,32
    8000309e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030a0:	0541                	addi	a0,a0,16
    800030a2:	2ac010ef          	jal	ra,8000434e <holdingsleep>
    800030a6:	c911                	beqz	a0,800030ba <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030a8:	4585                	li	a1,1
    800030aa:	8526                	mv	a0,s1
    800030ac:	1df020ef          	jal	ra,80005a8a <virtio_disk_rw>
}
    800030b0:	60e2                	ld	ra,24(sp)
    800030b2:	6442                	ld	s0,16(sp)
    800030b4:	64a2                	ld	s1,8(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret
    panic("bwrite");
    800030ba:	00004517          	auipc	a0,0x4
    800030be:	42650513          	addi	a0,a0,1062 # 800074e0 <syscalls+0xe8>
    800030c2:	ec6fd0ef          	jal	ra,80000788 <panic>

00000000800030c6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030c6:	1101                	addi	sp,sp,-32
    800030c8:	ec06                	sd	ra,24(sp)
    800030ca:	e822                	sd	s0,16(sp)
    800030cc:	e426                	sd	s1,8(sp)
    800030ce:	e04a                	sd	s2,0(sp)
    800030d0:	1000                	addi	s0,sp,32
    800030d2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030d4:	01050913          	addi	s2,a0,16
    800030d8:	854a                	mv	a0,s2
    800030da:	274010ef          	jal	ra,8000434e <holdingsleep>
    800030de:	c13d                	beqz	a0,80003144 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800030e0:	854a                	mv	a0,s2
    800030e2:	234010ef          	jal	ra,80004316 <releasesleep>

  acquire(&bcache.lock);
    800030e6:	0023a517          	auipc	a0,0x23a
    800030ea:	71250513          	addi	a0,a0,1810 # 8023d7f8 <bcache>
    800030ee:	bb3fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    800030f2:	40bc                	lw	a5,64(s1)
    800030f4:	37fd                	addiw	a5,a5,-1
    800030f6:	0007871b          	sext.w	a4,a5
    800030fa:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030fc:	eb05                	bnez	a4,8000312c <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030fe:	68bc                	ld	a5,80(s1)
    80003100:	64b8                	ld	a4,72(s1)
    80003102:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003104:	64bc                	ld	a5,72(s1)
    80003106:	68b8                	ld	a4,80(s1)
    80003108:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000310a:	00242797          	auipc	a5,0x242
    8000310e:	6ee78793          	addi	a5,a5,1774 # 802457f8 <bcache+0x8000>
    80003112:	2b87b703          	ld	a4,696(a5)
    80003116:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003118:	00243717          	auipc	a4,0x243
    8000311c:	94870713          	addi	a4,a4,-1720 # 80245a60 <bcache+0x8268>
    80003120:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003122:	2b87b703          	ld	a4,696(a5)
    80003126:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003128:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000312c:	0023a517          	auipc	a0,0x23a
    80003130:	6cc50513          	addi	a0,a0,1740 # 8023d7f8 <bcache>
    80003134:	c05fd0ef          	jal	ra,80000d38 <release>
}
    80003138:	60e2                	ld	ra,24(sp)
    8000313a:	6442                	ld	s0,16(sp)
    8000313c:	64a2                	ld	s1,8(sp)
    8000313e:	6902                	ld	s2,0(sp)
    80003140:	6105                	addi	sp,sp,32
    80003142:	8082                	ret
    panic("brelse");
    80003144:	00004517          	auipc	a0,0x4
    80003148:	3a450513          	addi	a0,a0,932 # 800074e8 <syscalls+0xf0>
    8000314c:	e3cfd0ef          	jal	ra,80000788 <panic>

0000000080003150 <bpin>:

void
bpin(struct buf *b) {
    80003150:	1101                	addi	sp,sp,-32
    80003152:	ec06                	sd	ra,24(sp)
    80003154:	e822                	sd	s0,16(sp)
    80003156:	e426                	sd	s1,8(sp)
    80003158:	1000                	addi	s0,sp,32
    8000315a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000315c:	0023a517          	auipc	a0,0x23a
    80003160:	69c50513          	addi	a0,a0,1692 # 8023d7f8 <bcache>
    80003164:	b3dfd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    80003168:	40bc                	lw	a5,64(s1)
    8000316a:	2785                	addiw	a5,a5,1
    8000316c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316e:	0023a517          	auipc	a0,0x23a
    80003172:	68a50513          	addi	a0,a0,1674 # 8023d7f8 <bcache>
    80003176:	bc3fd0ef          	jal	ra,80000d38 <release>
}
    8000317a:	60e2                	ld	ra,24(sp)
    8000317c:	6442                	ld	s0,16(sp)
    8000317e:	64a2                	ld	s1,8(sp)
    80003180:	6105                	addi	sp,sp,32
    80003182:	8082                	ret

0000000080003184 <bunpin>:

void
bunpin(struct buf *b) {
    80003184:	1101                	addi	sp,sp,-32
    80003186:	ec06                	sd	ra,24(sp)
    80003188:	e822                	sd	s0,16(sp)
    8000318a:	e426                	sd	s1,8(sp)
    8000318c:	1000                	addi	s0,sp,32
    8000318e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003190:	0023a517          	auipc	a0,0x23a
    80003194:	66850513          	addi	a0,a0,1640 # 8023d7f8 <bcache>
    80003198:	b09fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    8000319c:	40bc                	lw	a5,64(s1)
    8000319e:	37fd                	addiw	a5,a5,-1
    800031a0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031a2:	0023a517          	auipc	a0,0x23a
    800031a6:	65650513          	addi	a0,a0,1622 # 8023d7f8 <bcache>
    800031aa:	b8ffd0ef          	jal	ra,80000d38 <release>
}
    800031ae:	60e2                	ld	ra,24(sp)
    800031b0:	6442                	ld	s0,16(sp)
    800031b2:	64a2                	ld	s1,8(sp)
    800031b4:	6105                	addi	sp,sp,32
    800031b6:	8082                	ret

00000000800031b8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031b8:	1101                	addi	sp,sp,-32
    800031ba:	ec06                	sd	ra,24(sp)
    800031bc:	e822                	sd	s0,16(sp)
    800031be:	e426                	sd	s1,8(sp)
    800031c0:	e04a                	sd	s2,0(sp)
    800031c2:	1000                	addi	s0,sp,32
    800031c4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031c6:	00d5d59b          	srliw	a1,a1,0xd
    800031ca:	00243797          	auipc	a5,0x243
    800031ce:	d0a7a783          	lw	a5,-758(a5) # 80245ed4 <sb+0x1c>
    800031d2:	9dbd                	addw	a1,a1,a5
    800031d4:	debff0ef          	jal	ra,80002fbe <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031d8:	0074f713          	andi	a4,s1,7
    800031dc:	4785                	li	a5,1
    800031de:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031e2:	14ce                	slli	s1,s1,0x33
    800031e4:	90d9                	srli	s1,s1,0x36
    800031e6:	00950733          	add	a4,a0,s1
    800031ea:	05874703          	lbu	a4,88(a4)
    800031ee:	00e7f6b3          	and	a3,a5,a4
    800031f2:	c29d                	beqz	a3,80003218 <bfree+0x60>
    800031f4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031f6:	94aa                	add	s1,s1,a0
    800031f8:	fff7c793          	not	a5,a5
    800031fc:	8f7d                	and	a4,a4,a5
    800031fe:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003202:	7d7000ef          	jal	ra,800041d8 <log_write>
  brelse(bp);
    80003206:	854a                	mv	a0,s2
    80003208:	ebfff0ef          	jal	ra,800030c6 <brelse>
}
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6902                	ld	s2,0(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret
    panic("freeing free block");
    80003218:	00004517          	auipc	a0,0x4
    8000321c:	2d850513          	addi	a0,a0,728 # 800074f0 <syscalls+0xf8>
    80003220:	d68fd0ef          	jal	ra,80000788 <panic>

0000000080003224 <balloc>:
{
    80003224:	711d                	addi	sp,sp,-96
    80003226:	ec86                	sd	ra,88(sp)
    80003228:	e8a2                	sd	s0,80(sp)
    8000322a:	e4a6                	sd	s1,72(sp)
    8000322c:	e0ca                	sd	s2,64(sp)
    8000322e:	fc4e                	sd	s3,56(sp)
    80003230:	f852                	sd	s4,48(sp)
    80003232:	f456                	sd	s5,40(sp)
    80003234:	f05a                	sd	s6,32(sp)
    80003236:	ec5e                	sd	s7,24(sp)
    80003238:	e862                	sd	s8,16(sp)
    8000323a:	e466                	sd	s9,8(sp)
    8000323c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000323e:	00243797          	auipc	a5,0x243
    80003242:	c7e7a783          	lw	a5,-898(a5) # 80245ebc <sb+0x4>
    80003246:	cff1                	beqz	a5,80003322 <balloc+0xfe>
    80003248:	8baa                	mv	s7,a0
    8000324a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000324c:	00243b17          	auipc	s6,0x243
    80003250:	c6cb0b13          	addi	s6,s6,-916 # 80245eb8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003254:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003256:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003258:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000325a:	6c89                	lui	s9,0x2
    8000325c:	a0b5                	j	800032c8 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000325e:	97ca                	add	a5,a5,s2
    80003260:	8e55                	or	a2,a2,a3
    80003262:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003266:	854a                	mv	a0,s2
    80003268:	771000ef          	jal	ra,800041d8 <log_write>
        brelse(bp);
    8000326c:	854a                	mv	a0,s2
    8000326e:	e59ff0ef          	jal	ra,800030c6 <brelse>
  bp = bread(dev, bno);
    80003272:	85a6                	mv	a1,s1
    80003274:	855e                	mv	a0,s7
    80003276:	d49ff0ef          	jal	ra,80002fbe <bread>
    8000327a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000327c:	40000613          	li	a2,1024
    80003280:	4581                	li	a1,0
    80003282:	05850513          	addi	a0,a0,88
    80003286:	aeffd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    8000328a:	854a                	mv	a0,s2
    8000328c:	74d000ef          	jal	ra,800041d8 <log_write>
  brelse(bp);
    80003290:	854a                	mv	a0,s2
    80003292:	e35ff0ef          	jal	ra,800030c6 <brelse>
}
    80003296:	8526                	mv	a0,s1
    80003298:	60e6                	ld	ra,88(sp)
    8000329a:	6446                	ld	s0,80(sp)
    8000329c:	64a6                	ld	s1,72(sp)
    8000329e:	6906                	ld	s2,64(sp)
    800032a0:	79e2                	ld	s3,56(sp)
    800032a2:	7a42                	ld	s4,48(sp)
    800032a4:	7aa2                	ld	s5,40(sp)
    800032a6:	7b02                	ld	s6,32(sp)
    800032a8:	6be2                	ld	s7,24(sp)
    800032aa:	6c42                	ld	s8,16(sp)
    800032ac:	6ca2                	ld	s9,8(sp)
    800032ae:	6125                	addi	sp,sp,96
    800032b0:	8082                	ret
    brelse(bp);
    800032b2:	854a                	mv	a0,s2
    800032b4:	e13ff0ef          	jal	ra,800030c6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032b8:	015c87bb          	addw	a5,s9,s5
    800032bc:	00078a9b          	sext.w	s5,a5
    800032c0:	004b2703          	lw	a4,4(s6)
    800032c4:	04eaff63          	bgeu	s5,a4,80003322 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    800032c8:	41fad79b          	sraiw	a5,s5,0x1f
    800032cc:	0137d79b          	srliw	a5,a5,0x13
    800032d0:	015787bb          	addw	a5,a5,s5
    800032d4:	40d7d79b          	sraiw	a5,a5,0xd
    800032d8:	01cb2583          	lw	a1,28(s6)
    800032dc:	9dbd                	addw	a1,a1,a5
    800032de:	855e                	mv	a0,s7
    800032e0:	cdfff0ef          	jal	ra,80002fbe <bread>
    800032e4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e6:	004b2503          	lw	a0,4(s6)
    800032ea:	000a849b          	sext.w	s1,s5
    800032ee:	8762                	mv	a4,s8
    800032f0:	fca4f1e3          	bgeu	s1,a0,800032b2 <balloc+0x8e>
      m = 1 << (bi % 8);
    800032f4:	00777693          	andi	a3,a4,7
    800032f8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032fc:	41f7579b          	sraiw	a5,a4,0x1f
    80003300:	01d7d79b          	srliw	a5,a5,0x1d
    80003304:	9fb9                	addw	a5,a5,a4
    80003306:	4037d79b          	sraiw	a5,a5,0x3
    8000330a:	00f90633          	add	a2,s2,a5
    8000330e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003312:	00c6f5b3          	and	a1,a3,a2
    80003316:	d5a1                	beqz	a1,8000325e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003318:	2705                	addiw	a4,a4,1
    8000331a:	2485                	addiw	s1,s1,1
    8000331c:	fd471ae3          	bne	a4,s4,800032f0 <balloc+0xcc>
    80003320:	bf49                	j	800032b2 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003322:	00004517          	auipc	a0,0x4
    80003326:	1e650513          	addi	a0,a0,486 # 80007508 <syscalls+0x110>
    8000332a:	998fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    8000332e:	4481                	li	s1,0
    80003330:	b79d                	j	80003296 <balloc+0x72>

0000000080003332 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003332:	7179                	addi	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	e052                	sd	s4,0(sp)
    80003340:	1800                	addi	s0,sp,48
    80003342:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003344:	47ad                	li	a5,11
    80003346:	02b7e663          	bltu	a5,a1,80003372 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000334a:	02059793          	slli	a5,a1,0x20
    8000334e:	01e7d593          	srli	a1,a5,0x1e
    80003352:	00b504b3          	add	s1,a0,a1
    80003356:	0504a903          	lw	s2,80(s1)
    8000335a:	06091663          	bnez	s2,800033c6 <bmap+0x94>
      addr = balloc(ip->dev);
    8000335e:	4108                	lw	a0,0(a0)
    80003360:	ec5ff0ef          	jal	ra,80003224 <balloc>
    80003364:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003368:	04090f63          	beqz	s2,800033c6 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    8000336c:	0524a823          	sw	s2,80(s1)
    80003370:	a899                	j	800033c6 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003372:	ff45849b          	addiw	s1,a1,-12
    80003376:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000337a:	0ff00793          	li	a5,255
    8000337e:	06e7eb63          	bltu	a5,a4,800033f4 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003382:	08052903          	lw	s2,128(a0)
    80003386:	00091b63          	bnez	s2,8000339c <bmap+0x6a>
      addr = balloc(ip->dev);
    8000338a:	4108                	lw	a0,0(a0)
    8000338c:	e99ff0ef          	jal	ra,80003224 <balloc>
    80003390:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003394:	02090963          	beqz	s2,800033c6 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003398:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000339c:	85ca                	mv	a1,s2
    8000339e:	0009a503          	lw	a0,0(s3)
    800033a2:	c1dff0ef          	jal	ra,80002fbe <bread>
    800033a6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033a8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033ac:	02049713          	slli	a4,s1,0x20
    800033b0:	01e75593          	srli	a1,a4,0x1e
    800033b4:	00b784b3          	add	s1,a5,a1
    800033b8:	0004a903          	lw	s2,0(s1)
    800033bc:	00090e63          	beqz	s2,800033d8 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033c0:	8552                	mv	a0,s4
    800033c2:	d05ff0ef          	jal	ra,800030c6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033c6:	854a                	mv	a0,s2
    800033c8:	70a2                	ld	ra,40(sp)
    800033ca:	7402                	ld	s0,32(sp)
    800033cc:	64e2                	ld	s1,24(sp)
    800033ce:	6942                	ld	s2,16(sp)
    800033d0:	69a2                	ld	s3,8(sp)
    800033d2:	6a02                	ld	s4,0(sp)
    800033d4:	6145                	addi	sp,sp,48
    800033d6:	8082                	ret
      addr = balloc(ip->dev);
    800033d8:	0009a503          	lw	a0,0(s3)
    800033dc:	e49ff0ef          	jal	ra,80003224 <balloc>
    800033e0:	0005091b          	sext.w	s2,a0
      if(addr){
    800033e4:	fc090ee3          	beqz	s2,800033c0 <bmap+0x8e>
        a[bn] = addr;
    800033e8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033ec:	8552                	mv	a0,s4
    800033ee:	5eb000ef          	jal	ra,800041d8 <log_write>
    800033f2:	b7f9                	j	800033c0 <bmap+0x8e>
  panic("bmap: out of range");
    800033f4:	00004517          	auipc	a0,0x4
    800033f8:	12c50513          	addi	a0,a0,300 # 80007520 <syscalls+0x128>
    800033fc:	b8cfd0ef          	jal	ra,80000788 <panic>

0000000080003400 <iget>:
{
    80003400:	7179                	addi	sp,sp,-48
    80003402:	f406                	sd	ra,40(sp)
    80003404:	f022                	sd	s0,32(sp)
    80003406:	ec26                	sd	s1,24(sp)
    80003408:	e84a                	sd	s2,16(sp)
    8000340a:	e44e                	sd	s3,8(sp)
    8000340c:	e052                	sd	s4,0(sp)
    8000340e:	1800                	addi	s0,sp,48
    80003410:	89aa                	mv	s3,a0
    80003412:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003414:	00243517          	auipc	a0,0x243
    80003418:	ac450513          	addi	a0,a0,-1340 # 80245ed8 <itable>
    8000341c:	885fd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003420:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003422:	00243497          	auipc	s1,0x243
    80003426:	ace48493          	addi	s1,s1,-1330 # 80245ef0 <itable+0x18>
    8000342a:	00244697          	auipc	a3,0x244
    8000342e:	55668693          	addi	a3,a3,1366 # 80247980 <log>
    80003432:	a039                	j	80003440 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003434:	02090963          	beqz	s2,80003466 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003438:	08848493          	addi	s1,s1,136
    8000343c:	02d48863          	beq	s1,a3,8000346c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003440:	449c                	lw	a5,8(s1)
    80003442:	fef059e3          	blez	a5,80003434 <iget+0x34>
    80003446:	4098                	lw	a4,0(s1)
    80003448:	ff3716e3          	bne	a4,s3,80003434 <iget+0x34>
    8000344c:	40d8                	lw	a4,4(s1)
    8000344e:	ff4713e3          	bne	a4,s4,80003434 <iget+0x34>
      ip->ref++;
    80003452:	2785                	addiw	a5,a5,1
    80003454:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003456:	00243517          	auipc	a0,0x243
    8000345a:	a8250513          	addi	a0,a0,-1406 # 80245ed8 <itable>
    8000345e:	8dbfd0ef          	jal	ra,80000d38 <release>
      return ip;
    80003462:	8926                	mv	s2,s1
    80003464:	a02d                	j	8000348e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003466:	fbe9                	bnez	a5,80003438 <iget+0x38>
    80003468:	8926                	mv	s2,s1
    8000346a:	b7f9                	j	80003438 <iget+0x38>
  if(empty == 0)
    8000346c:	02090a63          	beqz	s2,800034a0 <iget+0xa0>
  ip->dev = dev;
    80003470:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003474:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003478:	4785                	li	a5,1
    8000347a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000347e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003482:	00243517          	auipc	a0,0x243
    80003486:	a5650513          	addi	a0,a0,-1450 # 80245ed8 <itable>
    8000348a:	8affd0ef          	jal	ra,80000d38 <release>
}
    8000348e:	854a                	mv	a0,s2
    80003490:	70a2                	ld	ra,40(sp)
    80003492:	7402                	ld	s0,32(sp)
    80003494:	64e2                	ld	s1,24(sp)
    80003496:	6942                	ld	s2,16(sp)
    80003498:	69a2                	ld	s3,8(sp)
    8000349a:	6a02                	ld	s4,0(sp)
    8000349c:	6145                	addi	sp,sp,48
    8000349e:	8082                	ret
    panic("iget: no inodes");
    800034a0:	00004517          	auipc	a0,0x4
    800034a4:	09850513          	addi	a0,a0,152 # 80007538 <syscalls+0x140>
    800034a8:	ae0fd0ef          	jal	ra,80000788 <panic>

00000000800034ac <iinit>:
{
    800034ac:	7179                	addi	sp,sp,-48
    800034ae:	f406                	sd	ra,40(sp)
    800034b0:	f022                	sd	s0,32(sp)
    800034b2:	ec26                	sd	s1,24(sp)
    800034b4:	e84a                	sd	s2,16(sp)
    800034b6:	e44e                	sd	s3,8(sp)
    800034b8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034ba:	00004597          	auipc	a1,0x4
    800034be:	08e58593          	addi	a1,a1,142 # 80007548 <syscalls+0x150>
    800034c2:	00243517          	auipc	a0,0x243
    800034c6:	a1650513          	addi	a0,a0,-1514 # 80245ed8 <itable>
    800034ca:	f56fd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034ce:	00243497          	auipc	s1,0x243
    800034d2:	a3248493          	addi	s1,s1,-1486 # 80245f00 <itable+0x28>
    800034d6:	00244997          	auipc	s3,0x244
    800034da:	4ba98993          	addi	s3,s3,1210 # 80247990 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034de:	00004917          	auipc	s2,0x4
    800034e2:	07290913          	addi	s2,s2,114 # 80007550 <syscalls+0x158>
    800034e6:	85ca                	mv	a1,s2
    800034e8:	8526                	mv	a0,s1
    800034ea:	5b1000ef          	jal	ra,8000429a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034ee:	08848493          	addi	s1,s1,136
    800034f2:	ff349ae3          	bne	s1,s3,800034e6 <iinit+0x3a>
}
    800034f6:	70a2                	ld	ra,40(sp)
    800034f8:	7402                	ld	s0,32(sp)
    800034fa:	64e2                	ld	s1,24(sp)
    800034fc:	6942                	ld	s2,16(sp)
    800034fe:	69a2                	ld	s3,8(sp)
    80003500:	6145                	addi	sp,sp,48
    80003502:	8082                	ret

0000000080003504 <ialloc>:
{
    80003504:	715d                	addi	sp,sp,-80
    80003506:	e486                	sd	ra,72(sp)
    80003508:	e0a2                	sd	s0,64(sp)
    8000350a:	fc26                	sd	s1,56(sp)
    8000350c:	f84a                	sd	s2,48(sp)
    8000350e:	f44e                	sd	s3,40(sp)
    80003510:	f052                	sd	s4,32(sp)
    80003512:	ec56                	sd	s5,24(sp)
    80003514:	e85a                	sd	s6,16(sp)
    80003516:	e45e                	sd	s7,8(sp)
    80003518:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000351a:	00243717          	auipc	a4,0x243
    8000351e:	9aa72703          	lw	a4,-1622(a4) # 80245ec4 <sb+0xc>
    80003522:	4785                	li	a5,1
    80003524:	04e7f663          	bgeu	a5,a4,80003570 <ialloc+0x6c>
    80003528:	8aaa                	mv	s5,a0
    8000352a:	8bae                	mv	s7,a1
    8000352c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000352e:	00243a17          	auipc	s4,0x243
    80003532:	98aa0a13          	addi	s4,s4,-1654 # 80245eb8 <sb>
    80003536:	00048b1b          	sext.w	s6,s1
    8000353a:	0044d593          	srli	a1,s1,0x4
    8000353e:	018a2783          	lw	a5,24(s4)
    80003542:	9dbd                	addw	a1,a1,a5
    80003544:	8556                	mv	a0,s5
    80003546:	a79ff0ef          	jal	ra,80002fbe <bread>
    8000354a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000354c:	05850993          	addi	s3,a0,88
    80003550:	00f4f793          	andi	a5,s1,15
    80003554:	079a                	slli	a5,a5,0x6
    80003556:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003558:	00099783          	lh	a5,0(s3)
    8000355c:	cf85                	beqz	a5,80003594 <ialloc+0x90>
    brelse(bp);
    8000355e:	b69ff0ef          	jal	ra,800030c6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003562:	0485                	addi	s1,s1,1
    80003564:	00ca2703          	lw	a4,12(s4)
    80003568:	0004879b          	sext.w	a5,s1
    8000356c:	fce7e5e3          	bltu	a5,a4,80003536 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003570:	00004517          	auipc	a0,0x4
    80003574:	fe850513          	addi	a0,a0,-24 # 80007558 <syscalls+0x160>
    80003578:	f4bfc0ef          	jal	ra,800004c2 <printf>
  return 0;
    8000357c:	4501                	li	a0,0
}
    8000357e:	60a6                	ld	ra,72(sp)
    80003580:	6406                	ld	s0,64(sp)
    80003582:	74e2                	ld	s1,56(sp)
    80003584:	7942                	ld	s2,48(sp)
    80003586:	79a2                	ld	s3,40(sp)
    80003588:	7a02                	ld	s4,32(sp)
    8000358a:	6ae2                	ld	s5,24(sp)
    8000358c:	6b42                	ld	s6,16(sp)
    8000358e:	6ba2                	ld	s7,8(sp)
    80003590:	6161                	addi	sp,sp,80
    80003592:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003594:	04000613          	li	a2,64
    80003598:	4581                	li	a1,0
    8000359a:	854e                	mv	a0,s3
    8000359c:	fd8fd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    800035a0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035a4:	854a                	mv	a0,s2
    800035a6:	433000ef          	jal	ra,800041d8 <log_write>
      brelse(bp);
    800035aa:	854a                	mv	a0,s2
    800035ac:	b1bff0ef          	jal	ra,800030c6 <brelse>
      return iget(dev, inum);
    800035b0:	85da                	mv	a1,s6
    800035b2:	8556                	mv	a0,s5
    800035b4:	e4dff0ef          	jal	ra,80003400 <iget>
    800035b8:	b7d9                	j	8000357e <ialloc+0x7a>

00000000800035ba <iupdate>:
{
    800035ba:	1101                	addi	sp,sp,-32
    800035bc:	ec06                	sd	ra,24(sp)
    800035be:	e822                	sd	s0,16(sp)
    800035c0:	e426                	sd	s1,8(sp)
    800035c2:	e04a                	sd	s2,0(sp)
    800035c4:	1000                	addi	s0,sp,32
    800035c6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035c8:	415c                	lw	a5,4(a0)
    800035ca:	0047d79b          	srliw	a5,a5,0x4
    800035ce:	00243597          	auipc	a1,0x243
    800035d2:	9025a583          	lw	a1,-1790(a1) # 80245ed0 <sb+0x18>
    800035d6:	9dbd                	addw	a1,a1,a5
    800035d8:	4108                	lw	a0,0(a0)
    800035da:	9e5ff0ef          	jal	ra,80002fbe <bread>
    800035de:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035e0:	05850793          	addi	a5,a0,88
    800035e4:	40d8                	lw	a4,4(s1)
    800035e6:	8b3d                	andi	a4,a4,15
    800035e8:	071a                	slli	a4,a4,0x6
    800035ea:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035ec:	04449703          	lh	a4,68(s1)
    800035f0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035f4:	04649703          	lh	a4,70(s1)
    800035f8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035fc:	04849703          	lh	a4,72(s1)
    80003600:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003604:	04a49703          	lh	a4,74(s1)
    80003608:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000360c:	44f8                	lw	a4,76(s1)
    8000360e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003610:	03400613          	li	a2,52
    80003614:	05048593          	addi	a1,s1,80
    80003618:	00c78513          	addi	a0,a5,12
    8000361c:	fb4fd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003620:	854a                	mv	a0,s2
    80003622:	3b7000ef          	jal	ra,800041d8 <log_write>
  brelse(bp);
    80003626:	854a                	mv	a0,s2
    80003628:	a9fff0ef          	jal	ra,800030c6 <brelse>
}
    8000362c:	60e2                	ld	ra,24(sp)
    8000362e:	6442                	ld	s0,16(sp)
    80003630:	64a2                	ld	s1,8(sp)
    80003632:	6902                	ld	s2,0(sp)
    80003634:	6105                	addi	sp,sp,32
    80003636:	8082                	ret

0000000080003638 <idup>:
{
    80003638:	1101                	addi	sp,sp,-32
    8000363a:	ec06                	sd	ra,24(sp)
    8000363c:	e822                	sd	s0,16(sp)
    8000363e:	e426                	sd	s1,8(sp)
    80003640:	1000                	addi	s0,sp,32
    80003642:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003644:	00243517          	auipc	a0,0x243
    80003648:	89450513          	addi	a0,a0,-1900 # 80245ed8 <itable>
    8000364c:	e54fd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003650:	449c                	lw	a5,8(s1)
    80003652:	2785                	addiw	a5,a5,1
    80003654:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003656:	00243517          	auipc	a0,0x243
    8000365a:	88250513          	addi	a0,a0,-1918 # 80245ed8 <itable>
    8000365e:	edafd0ef          	jal	ra,80000d38 <release>
}
    80003662:	8526                	mv	a0,s1
    80003664:	60e2                	ld	ra,24(sp)
    80003666:	6442                	ld	s0,16(sp)
    80003668:	64a2                	ld	s1,8(sp)
    8000366a:	6105                	addi	sp,sp,32
    8000366c:	8082                	ret

000000008000366e <ilock>:
{
    8000366e:	1101                	addi	sp,sp,-32
    80003670:	ec06                	sd	ra,24(sp)
    80003672:	e822                	sd	s0,16(sp)
    80003674:	e426                	sd	s1,8(sp)
    80003676:	e04a                	sd	s2,0(sp)
    80003678:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000367a:	c105                	beqz	a0,8000369a <ilock+0x2c>
    8000367c:	84aa                	mv	s1,a0
    8000367e:	451c                	lw	a5,8(a0)
    80003680:	00f05d63          	blez	a5,8000369a <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003684:	0541                	addi	a0,a0,16
    80003686:	44b000ef          	jal	ra,800042d0 <acquiresleep>
  if(ip->valid == 0){
    8000368a:	40bc                	lw	a5,64(s1)
    8000368c:	cf89                	beqz	a5,800036a6 <ilock+0x38>
}
    8000368e:	60e2                	ld	ra,24(sp)
    80003690:	6442                	ld	s0,16(sp)
    80003692:	64a2                	ld	s1,8(sp)
    80003694:	6902                	ld	s2,0(sp)
    80003696:	6105                	addi	sp,sp,32
    80003698:	8082                	ret
    panic("ilock");
    8000369a:	00004517          	auipc	a0,0x4
    8000369e:	ed650513          	addi	a0,a0,-298 # 80007570 <syscalls+0x178>
    800036a2:	8e6fd0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036a6:	40dc                	lw	a5,4(s1)
    800036a8:	0047d79b          	srliw	a5,a5,0x4
    800036ac:	00243597          	auipc	a1,0x243
    800036b0:	8245a583          	lw	a1,-2012(a1) # 80245ed0 <sb+0x18>
    800036b4:	9dbd                	addw	a1,a1,a5
    800036b6:	4088                	lw	a0,0(s1)
    800036b8:	907ff0ef          	jal	ra,80002fbe <bread>
    800036bc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036be:	05850593          	addi	a1,a0,88
    800036c2:	40dc                	lw	a5,4(s1)
    800036c4:	8bbd                	andi	a5,a5,15
    800036c6:	079a                	slli	a5,a5,0x6
    800036c8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036ca:	00059783          	lh	a5,0(a1)
    800036ce:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036d2:	00259783          	lh	a5,2(a1)
    800036d6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036da:	00459783          	lh	a5,4(a1)
    800036de:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036e2:	00659783          	lh	a5,6(a1)
    800036e6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036ea:	459c                	lw	a5,8(a1)
    800036ec:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036ee:	03400613          	li	a2,52
    800036f2:	05b1                	addi	a1,a1,12
    800036f4:	05048513          	addi	a0,s1,80
    800036f8:	ed8fd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    800036fc:	854a                	mv	a0,s2
    800036fe:	9c9ff0ef          	jal	ra,800030c6 <brelse>
    ip->valid = 1;
    80003702:	4785                	li	a5,1
    80003704:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003706:	04449783          	lh	a5,68(s1)
    8000370a:	f3d1                	bnez	a5,8000368e <ilock+0x20>
      panic("ilock: no type");
    8000370c:	00004517          	auipc	a0,0x4
    80003710:	e6c50513          	addi	a0,a0,-404 # 80007578 <syscalls+0x180>
    80003714:	874fd0ef          	jal	ra,80000788 <panic>

0000000080003718 <iunlock>:
{
    80003718:	1101                	addi	sp,sp,-32
    8000371a:	ec06                	sd	ra,24(sp)
    8000371c:	e822                	sd	s0,16(sp)
    8000371e:	e426                	sd	s1,8(sp)
    80003720:	e04a                	sd	s2,0(sp)
    80003722:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003724:	c505                	beqz	a0,8000374c <iunlock+0x34>
    80003726:	84aa                	mv	s1,a0
    80003728:	01050913          	addi	s2,a0,16
    8000372c:	854a                	mv	a0,s2
    8000372e:	421000ef          	jal	ra,8000434e <holdingsleep>
    80003732:	cd09                	beqz	a0,8000374c <iunlock+0x34>
    80003734:	449c                	lw	a5,8(s1)
    80003736:	00f05b63          	blez	a5,8000374c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000373a:	854a                	mv	a0,s2
    8000373c:	3db000ef          	jal	ra,80004316 <releasesleep>
}
    80003740:	60e2                	ld	ra,24(sp)
    80003742:	6442                	ld	s0,16(sp)
    80003744:	64a2                	ld	s1,8(sp)
    80003746:	6902                	ld	s2,0(sp)
    80003748:	6105                	addi	sp,sp,32
    8000374a:	8082                	ret
    panic("iunlock");
    8000374c:	00004517          	auipc	a0,0x4
    80003750:	e3c50513          	addi	a0,a0,-452 # 80007588 <syscalls+0x190>
    80003754:	834fd0ef          	jal	ra,80000788 <panic>

0000000080003758 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003758:	7179                	addi	sp,sp,-48
    8000375a:	f406                	sd	ra,40(sp)
    8000375c:	f022                	sd	s0,32(sp)
    8000375e:	ec26                	sd	s1,24(sp)
    80003760:	e84a                	sd	s2,16(sp)
    80003762:	e44e                	sd	s3,8(sp)
    80003764:	e052                	sd	s4,0(sp)
    80003766:	1800                	addi	s0,sp,48
    80003768:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000376a:	05050493          	addi	s1,a0,80
    8000376e:	08050913          	addi	s2,a0,128
    80003772:	a021                	j	8000377a <itrunc+0x22>
    80003774:	0491                	addi	s1,s1,4
    80003776:	01248b63          	beq	s1,s2,8000378c <itrunc+0x34>
    if(ip->addrs[i]){
    8000377a:	408c                	lw	a1,0(s1)
    8000377c:	dde5                	beqz	a1,80003774 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000377e:	0009a503          	lw	a0,0(s3)
    80003782:	a37ff0ef          	jal	ra,800031b8 <bfree>
      ip->addrs[i] = 0;
    80003786:	0004a023          	sw	zero,0(s1)
    8000378a:	b7ed                	j	80003774 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000378c:	0809a583          	lw	a1,128(s3)
    80003790:	ed91                	bnez	a1,800037ac <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003792:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003796:	854e                	mv	a0,s3
    80003798:	e23ff0ef          	jal	ra,800035ba <iupdate>
}
    8000379c:	70a2                	ld	ra,40(sp)
    8000379e:	7402                	ld	s0,32(sp)
    800037a0:	64e2                	ld	s1,24(sp)
    800037a2:	6942                	ld	s2,16(sp)
    800037a4:	69a2                	ld	s3,8(sp)
    800037a6:	6a02                	ld	s4,0(sp)
    800037a8:	6145                	addi	sp,sp,48
    800037aa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037ac:	0009a503          	lw	a0,0(s3)
    800037b0:	80fff0ef          	jal	ra,80002fbe <bread>
    800037b4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037b6:	05850493          	addi	s1,a0,88
    800037ba:	45850913          	addi	s2,a0,1112
    800037be:	a021                	j	800037c6 <itrunc+0x6e>
    800037c0:	0491                	addi	s1,s1,4
    800037c2:	01248963          	beq	s1,s2,800037d4 <itrunc+0x7c>
      if(a[j])
    800037c6:	408c                	lw	a1,0(s1)
    800037c8:	dde5                	beqz	a1,800037c0 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800037ca:	0009a503          	lw	a0,0(s3)
    800037ce:	9ebff0ef          	jal	ra,800031b8 <bfree>
    800037d2:	b7fd                	j	800037c0 <itrunc+0x68>
    brelse(bp);
    800037d4:	8552                	mv	a0,s4
    800037d6:	8f1ff0ef          	jal	ra,800030c6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037da:	0809a583          	lw	a1,128(s3)
    800037de:	0009a503          	lw	a0,0(s3)
    800037e2:	9d7ff0ef          	jal	ra,800031b8 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037e6:	0809a023          	sw	zero,128(s3)
    800037ea:	b765                	j	80003792 <itrunc+0x3a>

00000000800037ec <iput>:
{
    800037ec:	1101                	addi	sp,sp,-32
    800037ee:	ec06                	sd	ra,24(sp)
    800037f0:	e822                	sd	s0,16(sp)
    800037f2:	e426                	sd	s1,8(sp)
    800037f4:	e04a                	sd	s2,0(sp)
    800037f6:	1000                	addi	s0,sp,32
    800037f8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037fa:	00242517          	auipc	a0,0x242
    800037fe:	6de50513          	addi	a0,a0,1758 # 80245ed8 <itable>
    80003802:	c9efd0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003806:	4498                	lw	a4,8(s1)
    80003808:	4785                	li	a5,1
    8000380a:	02f70163          	beq	a4,a5,8000382c <iput+0x40>
  ip->ref--;
    8000380e:	449c                	lw	a5,8(s1)
    80003810:	37fd                	addiw	a5,a5,-1
    80003812:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003814:	00242517          	auipc	a0,0x242
    80003818:	6c450513          	addi	a0,a0,1732 # 80245ed8 <itable>
    8000381c:	d1cfd0ef          	jal	ra,80000d38 <release>
}
    80003820:	60e2                	ld	ra,24(sp)
    80003822:	6442                	ld	s0,16(sp)
    80003824:	64a2                	ld	s1,8(sp)
    80003826:	6902                	ld	s2,0(sp)
    80003828:	6105                	addi	sp,sp,32
    8000382a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000382c:	40bc                	lw	a5,64(s1)
    8000382e:	d3e5                	beqz	a5,8000380e <iput+0x22>
    80003830:	04a49783          	lh	a5,74(s1)
    80003834:	ffe9                	bnez	a5,8000380e <iput+0x22>
    acquiresleep(&ip->lock);
    80003836:	01048913          	addi	s2,s1,16
    8000383a:	854a                	mv	a0,s2
    8000383c:	295000ef          	jal	ra,800042d0 <acquiresleep>
    release(&itable.lock);
    80003840:	00242517          	auipc	a0,0x242
    80003844:	69850513          	addi	a0,a0,1688 # 80245ed8 <itable>
    80003848:	cf0fd0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    8000384c:	8526                	mv	a0,s1
    8000384e:	f0bff0ef          	jal	ra,80003758 <itrunc>
    ip->type = 0;
    80003852:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003856:	8526                	mv	a0,s1
    80003858:	d63ff0ef          	jal	ra,800035ba <iupdate>
    ip->valid = 0;
    8000385c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003860:	854a                	mv	a0,s2
    80003862:	2b5000ef          	jal	ra,80004316 <releasesleep>
    acquire(&itable.lock);
    80003866:	00242517          	auipc	a0,0x242
    8000386a:	67250513          	addi	a0,a0,1650 # 80245ed8 <itable>
    8000386e:	c32fd0ef          	jal	ra,80000ca0 <acquire>
    80003872:	bf71                	j	8000380e <iput+0x22>

0000000080003874 <iunlockput>:
{
    80003874:	1101                	addi	sp,sp,-32
    80003876:	ec06                	sd	ra,24(sp)
    80003878:	e822                	sd	s0,16(sp)
    8000387a:	e426                	sd	s1,8(sp)
    8000387c:	1000                	addi	s0,sp,32
    8000387e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003880:	e99ff0ef          	jal	ra,80003718 <iunlock>
  iput(ip);
    80003884:	8526                	mv	a0,s1
    80003886:	f67ff0ef          	jal	ra,800037ec <iput>
}
    8000388a:	60e2                	ld	ra,24(sp)
    8000388c:	6442                	ld	s0,16(sp)
    8000388e:	64a2                	ld	s1,8(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret

0000000080003894 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003894:	00242717          	auipc	a4,0x242
    80003898:	63072703          	lw	a4,1584(a4) # 80245ec4 <sb+0xc>
    8000389c:	4785                	li	a5,1
    8000389e:	0ae7ff63          	bgeu	a5,a4,8000395c <ireclaim+0xc8>
{
    800038a2:	7139                	addi	sp,sp,-64
    800038a4:	fc06                	sd	ra,56(sp)
    800038a6:	f822                	sd	s0,48(sp)
    800038a8:	f426                	sd	s1,40(sp)
    800038aa:	f04a                	sd	s2,32(sp)
    800038ac:	ec4e                	sd	s3,24(sp)
    800038ae:	e852                	sd	s4,16(sp)
    800038b0:	e456                	sd	s5,8(sp)
    800038b2:	e05a                	sd	s6,0(sp)
    800038b4:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800038b6:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800038b8:	00050a1b          	sext.w	s4,a0
    800038bc:	00242a97          	auipc	s5,0x242
    800038c0:	5fca8a93          	addi	s5,s5,1532 # 80245eb8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800038c4:	00004b17          	auipc	s6,0x4
    800038c8:	cccb0b13          	addi	s6,s6,-820 # 80007590 <syscalls+0x198>
    800038cc:	a099                	j	80003912 <ireclaim+0x7e>
    800038ce:	85ce                	mv	a1,s3
    800038d0:	855a                	mv	a0,s6
    800038d2:	bf1fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    800038d6:	85ce                	mv	a1,s3
    800038d8:	8552                	mv	a0,s4
    800038da:	b27ff0ef          	jal	ra,80003400 <iget>
    800038de:	89aa                	mv	s3,a0
    brelse(bp);
    800038e0:	854a                	mv	a0,s2
    800038e2:	fe4ff0ef          	jal	ra,800030c6 <brelse>
    if (ip) {
    800038e6:	00098f63          	beqz	s3,80003904 <ireclaim+0x70>
      begin_op();
    800038ea:	76c000ef          	jal	ra,80004056 <begin_op>
      ilock(ip);
    800038ee:	854e                	mv	a0,s3
    800038f0:	d7fff0ef          	jal	ra,8000366e <ilock>
      iunlock(ip);
    800038f4:	854e                	mv	a0,s3
    800038f6:	e23ff0ef          	jal	ra,80003718 <iunlock>
      iput(ip);
    800038fa:	854e                	mv	a0,s3
    800038fc:	ef1ff0ef          	jal	ra,800037ec <iput>
      end_op();
    80003900:	7c4000ef          	jal	ra,800040c4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003904:	0485                	addi	s1,s1,1
    80003906:	00caa703          	lw	a4,12(s5)
    8000390a:	0004879b          	sext.w	a5,s1
    8000390e:	02e7fd63          	bgeu	a5,a4,80003948 <ireclaim+0xb4>
    80003912:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003916:	0044d593          	srli	a1,s1,0x4
    8000391a:	018aa783          	lw	a5,24(s5)
    8000391e:	9dbd                	addw	a1,a1,a5
    80003920:	8552                	mv	a0,s4
    80003922:	e9cff0ef          	jal	ra,80002fbe <bread>
    80003926:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003928:	05850793          	addi	a5,a0,88
    8000392c:	00f9f713          	andi	a4,s3,15
    80003930:	071a                	slli	a4,a4,0x6
    80003932:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003934:	00079703          	lh	a4,0(a5)
    80003938:	c701                	beqz	a4,80003940 <ireclaim+0xac>
    8000393a:	00679783          	lh	a5,6(a5)
    8000393e:	dbc1                	beqz	a5,800038ce <ireclaim+0x3a>
    brelse(bp);
    80003940:	854a                	mv	a0,s2
    80003942:	f84ff0ef          	jal	ra,800030c6 <brelse>
    if (ip) {
    80003946:	bf7d                	j	80003904 <ireclaim+0x70>
}
    80003948:	70e2                	ld	ra,56(sp)
    8000394a:	7442                	ld	s0,48(sp)
    8000394c:	74a2                	ld	s1,40(sp)
    8000394e:	7902                	ld	s2,32(sp)
    80003950:	69e2                	ld	s3,24(sp)
    80003952:	6a42                	ld	s4,16(sp)
    80003954:	6aa2                	ld	s5,8(sp)
    80003956:	6b02                	ld	s6,0(sp)
    80003958:	6121                	addi	sp,sp,64
    8000395a:	8082                	ret
    8000395c:	8082                	ret

000000008000395e <fsinit>:
fsinit(int dev) {
    8000395e:	7179                	addi	sp,sp,-48
    80003960:	f406                	sd	ra,40(sp)
    80003962:	f022                	sd	s0,32(sp)
    80003964:	ec26                	sd	s1,24(sp)
    80003966:	e84a                	sd	s2,16(sp)
    80003968:	e44e                	sd	s3,8(sp)
    8000396a:	1800                	addi	s0,sp,48
    8000396c:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000396e:	4585                	li	a1,1
    80003970:	e4eff0ef          	jal	ra,80002fbe <bread>
    80003974:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003976:	00242997          	auipc	s3,0x242
    8000397a:	54298993          	addi	s3,s3,1346 # 80245eb8 <sb>
    8000397e:	02000613          	li	a2,32
    80003982:	05850593          	addi	a1,a0,88
    80003986:	854e                	mv	a0,s3
    80003988:	c48fd0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    8000398c:	854a                	mv	a0,s2
    8000398e:	f38ff0ef          	jal	ra,800030c6 <brelse>
  if(sb.magic != FSMAGIC)
    80003992:	0009a703          	lw	a4,0(s3)
    80003996:	102037b7          	lui	a5,0x10203
    8000399a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000399e:	02f71363          	bne	a4,a5,800039c4 <fsinit+0x66>
  initlog(dev, &sb);
    800039a2:	00242597          	auipc	a1,0x242
    800039a6:	51658593          	addi	a1,a1,1302 # 80245eb8 <sb>
    800039aa:	8526                	mv	a0,s1
    800039ac:	61e000ef          	jal	ra,80003fca <initlog>
  ireclaim(dev);
    800039b0:	8526                	mv	a0,s1
    800039b2:	ee3ff0ef          	jal	ra,80003894 <ireclaim>
}
    800039b6:	70a2                	ld	ra,40(sp)
    800039b8:	7402                	ld	s0,32(sp)
    800039ba:	64e2                	ld	s1,24(sp)
    800039bc:	6942                	ld	s2,16(sp)
    800039be:	69a2                	ld	s3,8(sp)
    800039c0:	6145                	addi	sp,sp,48
    800039c2:	8082                	ret
    panic("invalid file system");
    800039c4:	00004517          	auipc	a0,0x4
    800039c8:	bec50513          	addi	a0,a0,-1044 # 800075b0 <syscalls+0x1b8>
    800039cc:	dbdfc0ef          	jal	ra,80000788 <panic>

00000000800039d0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039d0:	1141                	addi	sp,sp,-16
    800039d2:	e422                	sd	s0,8(sp)
    800039d4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039d6:	411c                	lw	a5,0(a0)
    800039d8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039da:	415c                	lw	a5,4(a0)
    800039dc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039de:	04451783          	lh	a5,68(a0)
    800039e2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039e6:	04a51783          	lh	a5,74(a0)
    800039ea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039ee:	04c56783          	lwu	a5,76(a0)
    800039f2:	e99c                	sd	a5,16(a1)
}
    800039f4:	6422                	ld	s0,8(sp)
    800039f6:	0141                	addi	sp,sp,16
    800039f8:	8082                	ret

00000000800039fa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039fa:	457c                	lw	a5,76(a0)
    800039fc:	0cd7ef63          	bltu	a5,a3,80003ada <readi+0xe0>
{
    80003a00:	7159                	addi	sp,sp,-112
    80003a02:	f486                	sd	ra,104(sp)
    80003a04:	f0a2                	sd	s0,96(sp)
    80003a06:	eca6                	sd	s1,88(sp)
    80003a08:	e8ca                	sd	s2,80(sp)
    80003a0a:	e4ce                	sd	s3,72(sp)
    80003a0c:	e0d2                	sd	s4,64(sp)
    80003a0e:	fc56                	sd	s5,56(sp)
    80003a10:	f85a                	sd	s6,48(sp)
    80003a12:	f45e                	sd	s7,40(sp)
    80003a14:	f062                	sd	s8,32(sp)
    80003a16:	ec66                	sd	s9,24(sp)
    80003a18:	e86a                	sd	s10,16(sp)
    80003a1a:	e46e                	sd	s11,8(sp)
    80003a1c:	1880                	addi	s0,sp,112
    80003a1e:	8b2a                	mv	s6,a0
    80003a20:	8bae                	mv	s7,a1
    80003a22:	8a32                	mv	s4,a2
    80003a24:	84b6                	mv	s1,a3
    80003a26:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a28:	9f35                	addw	a4,a4,a3
    return 0;
    80003a2a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a2c:	08d76663          	bltu	a4,a3,80003ab8 <readi+0xbe>
  if(off + n > ip->size)
    80003a30:	00e7f463          	bgeu	a5,a4,80003a38 <readi+0x3e>
    n = ip->size - off;
    80003a34:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a38:	080a8f63          	beqz	s5,80003ad6 <readi+0xdc>
    80003a3c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a42:	5c7d                	li	s8,-1
    80003a44:	a80d                	j	80003a76 <readi+0x7c>
    80003a46:	020d1d93          	slli	s11,s10,0x20
    80003a4a:	020ddd93          	srli	s11,s11,0x20
    80003a4e:	05890613          	addi	a2,s2,88
    80003a52:	86ee                	mv	a3,s11
    80003a54:	963a                	add	a2,a2,a4
    80003a56:	85d2                	mv	a1,s4
    80003a58:	855e                	mv	a0,s7
    80003a5a:	a43fe0ef          	jal	ra,8000249c <either_copyout>
    80003a5e:	05850763          	beq	a0,s8,80003aac <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a62:	854a                	mv	a0,s2
    80003a64:	e62ff0ef          	jal	ra,800030c6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a68:	013d09bb          	addw	s3,s10,s3
    80003a6c:	009d04bb          	addw	s1,s10,s1
    80003a70:	9a6e                	add	s4,s4,s11
    80003a72:	0559f163          	bgeu	s3,s5,80003ab4 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003a76:	00a4d59b          	srliw	a1,s1,0xa
    80003a7a:	855a                	mv	a0,s6
    80003a7c:	8b7ff0ef          	jal	ra,80003332 <bmap>
    80003a80:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a84:	c985                	beqz	a1,80003ab4 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003a86:	000b2503          	lw	a0,0(s6)
    80003a8a:	d34ff0ef          	jal	ra,80002fbe <bread>
    80003a8e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a90:	3ff4f713          	andi	a4,s1,1023
    80003a94:	40ec87bb          	subw	a5,s9,a4
    80003a98:	413a86bb          	subw	a3,s5,s3
    80003a9c:	8d3e                	mv	s10,a5
    80003a9e:	2781                	sext.w	a5,a5
    80003aa0:	0006861b          	sext.w	a2,a3
    80003aa4:	faf671e3          	bgeu	a2,a5,80003a46 <readi+0x4c>
    80003aa8:	8d36                	mv	s10,a3
    80003aaa:	bf71                	j	80003a46 <readi+0x4c>
      brelse(bp);
    80003aac:	854a                	mv	a0,s2
    80003aae:	e18ff0ef          	jal	ra,800030c6 <brelse>
      tot = -1;
    80003ab2:	59fd                	li	s3,-1
  }
  return tot;
    80003ab4:	0009851b          	sext.w	a0,s3
}
    80003ab8:	70a6                	ld	ra,104(sp)
    80003aba:	7406                	ld	s0,96(sp)
    80003abc:	64e6                	ld	s1,88(sp)
    80003abe:	6946                	ld	s2,80(sp)
    80003ac0:	69a6                	ld	s3,72(sp)
    80003ac2:	6a06                	ld	s4,64(sp)
    80003ac4:	7ae2                	ld	s5,56(sp)
    80003ac6:	7b42                	ld	s6,48(sp)
    80003ac8:	7ba2                	ld	s7,40(sp)
    80003aca:	7c02                	ld	s8,32(sp)
    80003acc:	6ce2                	ld	s9,24(sp)
    80003ace:	6d42                	ld	s10,16(sp)
    80003ad0:	6da2                	ld	s11,8(sp)
    80003ad2:	6165                	addi	sp,sp,112
    80003ad4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ad6:	89d6                	mv	s3,s5
    80003ad8:	bff1                	j	80003ab4 <readi+0xba>
    return 0;
    80003ada:	4501                	li	a0,0
}
    80003adc:	8082                	ret

0000000080003ade <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ade:	457c                	lw	a5,76(a0)
    80003ae0:	0ed7ea63          	bltu	a5,a3,80003bd4 <writei+0xf6>
{
    80003ae4:	7159                	addi	sp,sp,-112
    80003ae6:	f486                	sd	ra,104(sp)
    80003ae8:	f0a2                	sd	s0,96(sp)
    80003aea:	eca6                	sd	s1,88(sp)
    80003aec:	e8ca                	sd	s2,80(sp)
    80003aee:	e4ce                	sd	s3,72(sp)
    80003af0:	e0d2                	sd	s4,64(sp)
    80003af2:	fc56                	sd	s5,56(sp)
    80003af4:	f85a                	sd	s6,48(sp)
    80003af6:	f45e                	sd	s7,40(sp)
    80003af8:	f062                	sd	s8,32(sp)
    80003afa:	ec66                	sd	s9,24(sp)
    80003afc:	e86a                	sd	s10,16(sp)
    80003afe:	e46e                	sd	s11,8(sp)
    80003b00:	1880                	addi	s0,sp,112
    80003b02:	8aaa                	mv	s5,a0
    80003b04:	8bae                	mv	s7,a1
    80003b06:	8a32                	mv	s4,a2
    80003b08:	8936                	mv	s2,a3
    80003b0a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b0c:	00e687bb          	addw	a5,a3,a4
    80003b10:	0cd7e463          	bltu	a5,a3,80003bd8 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b14:	00043737          	lui	a4,0x43
    80003b18:	0cf76263          	bltu	a4,a5,80003bdc <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b1c:	0a0b0a63          	beqz	s6,80003bd0 <writei+0xf2>
    80003b20:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b22:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b26:	5c7d                	li	s8,-1
    80003b28:	a825                	j	80003b60 <writei+0x82>
    80003b2a:	020d1d93          	slli	s11,s10,0x20
    80003b2e:	020ddd93          	srli	s11,s11,0x20
    80003b32:	05848513          	addi	a0,s1,88
    80003b36:	86ee                	mv	a3,s11
    80003b38:	8652                	mv	a2,s4
    80003b3a:	85de                	mv	a1,s7
    80003b3c:	953a                	add	a0,a0,a4
    80003b3e:	9a9fe0ef          	jal	ra,800024e6 <either_copyin>
    80003b42:	05850a63          	beq	a0,s8,80003b96 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b46:	8526                	mv	a0,s1
    80003b48:	690000ef          	jal	ra,800041d8 <log_write>
    brelse(bp);
    80003b4c:	8526                	mv	a0,s1
    80003b4e:	d78ff0ef          	jal	ra,800030c6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b52:	013d09bb          	addw	s3,s10,s3
    80003b56:	012d093b          	addw	s2,s10,s2
    80003b5a:	9a6e                	add	s4,s4,s11
    80003b5c:	0569f063          	bgeu	s3,s6,80003b9c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003b60:	00a9559b          	srliw	a1,s2,0xa
    80003b64:	8556                	mv	a0,s5
    80003b66:	fccff0ef          	jal	ra,80003332 <bmap>
    80003b6a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b6e:	c59d                	beqz	a1,80003b9c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003b70:	000aa503          	lw	a0,0(s5)
    80003b74:	c4aff0ef          	jal	ra,80002fbe <bread>
    80003b78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7a:	3ff97713          	andi	a4,s2,1023
    80003b7e:	40ec87bb          	subw	a5,s9,a4
    80003b82:	413b06bb          	subw	a3,s6,s3
    80003b86:	8d3e                	mv	s10,a5
    80003b88:	2781                	sext.w	a5,a5
    80003b8a:	0006861b          	sext.w	a2,a3
    80003b8e:	f8f67ee3          	bgeu	a2,a5,80003b2a <writei+0x4c>
    80003b92:	8d36                	mv	s10,a3
    80003b94:	bf59                	j	80003b2a <writei+0x4c>
      brelse(bp);
    80003b96:	8526                	mv	a0,s1
    80003b98:	d2eff0ef          	jal	ra,800030c6 <brelse>
  }

  if(off > ip->size)
    80003b9c:	04caa783          	lw	a5,76(s5)
    80003ba0:	0127f463          	bgeu	a5,s2,80003ba8 <writei+0xca>
    ip->size = off;
    80003ba4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ba8:	8556                	mv	a0,s5
    80003baa:	a11ff0ef          	jal	ra,800035ba <iupdate>

  return tot;
    80003bae:	0009851b          	sext.w	a0,s3
}
    80003bb2:	70a6                	ld	ra,104(sp)
    80003bb4:	7406                	ld	s0,96(sp)
    80003bb6:	64e6                	ld	s1,88(sp)
    80003bb8:	6946                	ld	s2,80(sp)
    80003bba:	69a6                	ld	s3,72(sp)
    80003bbc:	6a06                	ld	s4,64(sp)
    80003bbe:	7ae2                	ld	s5,56(sp)
    80003bc0:	7b42                	ld	s6,48(sp)
    80003bc2:	7ba2                	ld	s7,40(sp)
    80003bc4:	7c02                	ld	s8,32(sp)
    80003bc6:	6ce2                	ld	s9,24(sp)
    80003bc8:	6d42                	ld	s10,16(sp)
    80003bca:	6da2                	ld	s11,8(sp)
    80003bcc:	6165                	addi	sp,sp,112
    80003bce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd0:	89da                	mv	s3,s6
    80003bd2:	bfd9                	j	80003ba8 <writei+0xca>
    return -1;
    80003bd4:	557d                	li	a0,-1
}
    80003bd6:	8082                	ret
    return -1;
    80003bd8:	557d                	li	a0,-1
    80003bda:	bfe1                	j	80003bb2 <writei+0xd4>
    return -1;
    80003bdc:	557d                	li	a0,-1
    80003bde:	bfd1                	j	80003bb2 <writei+0xd4>

0000000080003be0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003be0:	1141                	addi	sp,sp,-16
    80003be2:	e406                	sd	ra,8(sp)
    80003be4:	e022                	sd	s0,0(sp)
    80003be6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003be8:	4639                	li	a2,14
    80003bea:	a56fd0ef          	jal	ra,80000e40 <strncmp>
}
    80003bee:	60a2                	ld	ra,8(sp)
    80003bf0:	6402                	ld	s0,0(sp)
    80003bf2:	0141                	addi	sp,sp,16
    80003bf4:	8082                	ret

0000000080003bf6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bf6:	7139                	addi	sp,sp,-64
    80003bf8:	fc06                	sd	ra,56(sp)
    80003bfa:	f822                	sd	s0,48(sp)
    80003bfc:	f426                	sd	s1,40(sp)
    80003bfe:	f04a                	sd	s2,32(sp)
    80003c00:	ec4e                	sd	s3,24(sp)
    80003c02:	e852                	sd	s4,16(sp)
    80003c04:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c06:	04451703          	lh	a4,68(a0)
    80003c0a:	4785                	li	a5,1
    80003c0c:	00f71a63          	bne	a4,a5,80003c20 <dirlookup+0x2a>
    80003c10:	892a                	mv	s2,a0
    80003c12:	89ae                	mv	s3,a1
    80003c14:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c16:	457c                	lw	a5,76(a0)
    80003c18:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c1a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c1c:	e39d                	bnez	a5,80003c42 <dirlookup+0x4c>
    80003c1e:	a095                	j	80003c82 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003c20:	00004517          	auipc	a0,0x4
    80003c24:	9a850513          	addi	a0,a0,-1624 # 800075c8 <syscalls+0x1d0>
    80003c28:	b61fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80003c2c:	00004517          	auipc	a0,0x4
    80003c30:	9b450513          	addi	a0,a0,-1612 # 800075e0 <syscalls+0x1e8>
    80003c34:	b55fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c38:	24c1                	addiw	s1,s1,16
    80003c3a:	04c92783          	lw	a5,76(s2)
    80003c3e:	04f4f163          	bgeu	s1,a5,80003c80 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c42:	4741                	li	a4,16
    80003c44:	86a6                	mv	a3,s1
    80003c46:	fc040613          	addi	a2,s0,-64
    80003c4a:	4581                	li	a1,0
    80003c4c:	854a                	mv	a0,s2
    80003c4e:	dadff0ef          	jal	ra,800039fa <readi>
    80003c52:	47c1                	li	a5,16
    80003c54:	fcf51ce3          	bne	a0,a5,80003c2c <dirlookup+0x36>
    if(de.inum == 0)
    80003c58:	fc045783          	lhu	a5,-64(s0)
    80003c5c:	dff1                	beqz	a5,80003c38 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003c5e:	fc240593          	addi	a1,s0,-62
    80003c62:	854e                	mv	a0,s3
    80003c64:	f7dff0ef          	jal	ra,80003be0 <namecmp>
    80003c68:	f961                	bnez	a0,80003c38 <dirlookup+0x42>
      if(poff)
    80003c6a:	000a0463          	beqz	s4,80003c72 <dirlookup+0x7c>
        *poff = off;
    80003c6e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c72:	fc045583          	lhu	a1,-64(s0)
    80003c76:	00092503          	lw	a0,0(s2)
    80003c7a:	f86ff0ef          	jal	ra,80003400 <iget>
    80003c7e:	a011                	j	80003c82 <dirlookup+0x8c>
  return 0;
    80003c80:	4501                	li	a0,0
}
    80003c82:	70e2                	ld	ra,56(sp)
    80003c84:	7442                	ld	s0,48(sp)
    80003c86:	74a2                	ld	s1,40(sp)
    80003c88:	7902                	ld	s2,32(sp)
    80003c8a:	69e2                	ld	s3,24(sp)
    80003c8c:	6a42                	ld	s4,16(sp)
    80003c8e:	6121                	addi	sp,sp,64
    80003c90:	8082                	ret

0000000080003c92 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c92:	711d                	addi	sp,sp,-96
    80003c94:	ec86                	sd	ra,88(sp)
    80003c96:	e8a2                	sd	s0,80(sp)
    80003c98:	e4a6                	sd	s1,72(sp)
    80003c9a:	e0ca                	sd	s2,64(sp)
    80003c9c:	fc4e                	sd	s3,56(sp)
    80003c9e:	f852                	sd	s4,48(sp)
    80003ca0:	f456                	sd	s5,40(sp)
    80003ca2:	f05a                	sd	s6,32(sp)
    80003ca4:	ec5e                	sd	s7,24(sp)
    80003ca6:	e862                	sd	s8,16(sp)
    80003ca8:	e466                	sd	s9,8(sp)
    80003caa:	e06a                	sd	s10,0(sp)
    80003cac:	1080                	addi	s0,sp,96
    80003cae:	84aa                	mv	s1,a0
    80003cb0:	8b2e                	mv	s6,a1
    80003cb2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cb4:	00054703          	lbu	a4,0(a0)
    80003cb8:	02f00793          	li	a5,47
    80003cbc:	00f70f63          	beq	a4,a5,80003cda <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cc0:	e13fd0ef          	jal	ra,80001ad2 <myproc>
    80003cc4:	15053503          	ld	a0,336(a0)
    80003cc8:	971ff0ef          	jal	ra,80003638 <idup>
    80003ccc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cce:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cd2:	4cb5                	li	s9,13
  len = path - s;
    80003cd4:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cd6:	4c05                	li	s8,1
    80003cd8:	a879                	j	80003d76 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003cda:	4585                	li	a1,1
    80003cdc:	4505                	li	a0,1
    80003cde:	f22ff0ef          	jal	ra,80003400 <iget>
    80003ce2:	8a2a                	mv	s4,a0
    80003ce4:	b7ed                	j	80003cce <namex+0x3c>
      iunlockput(ip);
    80003ce6:	8552                	mv	a0,s4
    80003ce8:	b8dff0ef          	jal	ra,80003874 <iunlockput>
      return 0;
    80003cec:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cee:	8552                	mv	a0,s4
    80003cf0:	60e6                	ld	ra,88(sp)
    80003cf2:	6446                	ld	s0,80(sp)
    80003cf4:	64a6                	ld	s1,72(sp)
    80003cf6:	6906                	ld	s2,64(sp)
    80003cf8:	79e2                	ld	s3,56(sp)
    80003cfa:	7a42                	ld	s4,48(sp)
    80003cfc:	7aa2                	ld	s5,40(sp)
    80003cfe:	7b02                	ld	s6,32(sp)
    80003d00:	6be2                	ld	s7,24(sp)
    80003d02:	6c42                	ld	s8,16(sp)
    80003d04:	6ca2                	ld	s9,8(sp)
    80003d06:	6d02                	ld	s10,0(sp)
    80003d08:	6125                	addi	sp,sp,96
    80003d0a:	8082                	ret
      iunlock(ip);
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	a0bff0ef          	jal	ra,80003718 <iunlock>
      return ip;
    80003d12:	bff1                	j	80003cee <namex+0x5c>
      iunlockput(ip);
    80003d14:	8552                	mv	a0,s4
    80003d16:	b5fff0ef          	jal	ra,80003874 <iunlockput>
      return 0;
    80003d1a:	8a4e                	mv	s4,s3
    80003d1c:	bfc9                	j	80003cee <namex+0x5c>
  len = path - s;
    80003d1e:	40998633          	sub	a2,s3,s1
    80003d22:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d26:	09acd063          	bge	s9,s10,80003da6 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003d2a:	4639                	li	a2,14
    80003d2c:	85a6                	mv	a1,s1
    80003d2e:	8556                	mv	a0,s5
    80003d30:	8a0fd0ef          	jal	ra,80000dd0 <memmove>
    80003d34:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d36:	0004c783          	lbu	a5,0(s1)
    80003d3a:	01279763          	bne	a5,s2,80003d48 <namex+0xb6>
    path++;
    80003d3e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d40:	0004c783          	lbu	a5,0(s1)
    80003d44:	ff278de3          	beq	a5,s2,80003d3e <namex+0xac>
    ilock(ip);
    80003d48:	8552                	mv	a0,s4
    80003d4a:	925ff0ef          	jal	ra,8000366e <ilock>
    if(ip->type != T_DIR){
    80003d4e:	044a1783          	lh	a5,68(s4)
    80003d52:	f9879ae3          	bne	a5,s8,80003ce6 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003d56:	000b0563          	beqz	s6,80003d60 <namex+0xce>
    80003d5a:	0004c783          	lbu	a5,0(s1)
    80003d5e:	d7dd                	beqz	a5,80003d0c <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d60:	865e                	mv	a2,s7
    80003d62:	85d6                	mv	a1,s5
    80003d64:	8552                	mv	a0,s4
    80003d66:	e91ff0ef          	jal	ra,80003bf6 <dirlookup>
    80003d6a:	89aa                	mv	s3,a0
    80003d6c:	d545                	beqz	a0,80003d14 <namex+0x82>
    iunlockput(ip);
    80003d6e:	8552                	mv	a0,s4
    80003d70:	b05ff0ef          	jal	ra,80003874 <iunlockput>
    ip = next;
    80003d74:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d76:	0004c783          	lbu	a5,0(s1)
    80003d7a:	01279763          	bne	a5,s2,80003d88 <namex+0xf6>
    path++;
    80003d7e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d80:	0004c783          	lbu	a5,0(s1)
    80003d84:	ff278de3          	beq	a5,s2,80003d7e <namex+0xec>
  if(*path == 0)
    80003d88:	cb8d                	beqz	a5,80003dba <namex+0x128>
  while(*path != '/' && *path != 0)
    80003d8a:	0004c783          	lbu	a5,0(s1)
    80003d8e:	89a6                	mv	s3,s1
  len = path - s;
    80003d90:	8d5e                	mv	s10,s7
    80003d92:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d94:	01278963          	beq	a5,s2,80003da6 <namex+0x114>
    80003d98:	d3d9                	beqz	a5,80003d1e <namex+0x8c>
    path++;
    80003d9a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d9c:	0009c783          	lbu	a5,0(s3)
    80003da0:	ff279ce3          	bne	a5,s2,80003d98 <namex+0x106>
    80003da4:	bfad                	j	80003d1e <namex+0x8c>
    memmove(name, s, len);
    80003da6:	2601                	sext.w	a2,a2
    80003da8:	85a6                	mv	a1,s1
    80003daa:	8556                	mv	a0,s5
    80003dac:	824fd0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    80003db0:	9d56                	add	s10,s10,s5
    80003db2:	000d0023          	sb	zero,0(s10)
    80003db6:	84ce                	mv	s1,s3
    80003db8:	bfbd                	j	80003d36 <namex+0xa4>
  if(nameiparent){
    80003dba:	f20b0ae3          	beqz	s6,80003cee <namex+0x5c>
    iput(ip);
    80003dbe:	8552                	mv	a0,s4
    80003dc0:	a2dff0ef          	jal	ra,800037ec <iput>
    return 0;
    80003dc4:	4a01                	li	s4,0
    80003dc6:	b725                	j	80003cee <namex+0x5c>

0000000080003dc8 <dirlink>:
{
    80003dc8:	7139                	addi	sp,sp,-64
    80003dca:	fc06                	sd	ra,56(sp)
    80003dcc:	f822                	sd	s0,48(sp)
    80003dce:	f426                	sd	s1,40(sp)
    80003dd0:	f04a                	sd	s2,32(sp)
    80003dd2:	ec4e                	sd	s3,24(sp)
    80003dd4:	e852                	sd	s4,16(sp)
    80003dd6:	0080                	addi	s0,sp,64
    80003dd8:	892a                	mv	s2,a0
    80003dda:	8a2e                	mv	s4,a1
    80003ddc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dde:	4601                	li	a2,0
    80003de0:	e17ff0ef          	jal	ra,80003bf6 <dirlookup>
    80003de4:	e52d                	bnez	a0,80003e4e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de6:	04c92483          	lw	s1,76(s2)
    80003dea:	c48d                	beqz	s1,80003e14 <dirlink+0x4c>
    80003dec:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dee:	4741                	li	a4,16
    80003df0:	86a6                	mv	a3,s1
    80003df2:	fc040613          	addi	a2,s0,-64
    80003df6:	4581                	li	a1,0
    80003df8:	854a                	mv	a0,s2
    80003dfa:	c01ff0ef          	jal	ra,800039fa <readi>
    80003dfe:	47c1                	li	a5,16
    80003e00:	04f51b63          	bne	a0,a5,80003e56 <dirlink+0x8e>
    if(de.inum == 0)
    80003e04:	fc045783          	lhu	a5,-64(s0)
    80003e08:	c791                	beqz	a5,80003e14 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e0a:	24c1                	addiw	s1,s1,16
    80003e0c:	04c92783          	lw	a5,76(s2)
    80003e10:	fcf4efe3          	bltu	s1,a5,80003dee <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003e14:	4639                	li	a2,14
    80003e16:	85d2                	mv	a1,s4
    80003e18:	fc240513          	addi	a0,s0,-62
    80003e1c:	860fd0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80003e20:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e24:	4741                	li	a4,16
    80003e26:	86a6                	mv	a3,s1
    80003e28:	fc040613          	addi	a2,s0,-64
    80003e2c:	4581                	li	a1,0
    80003e2e:	854a                	mv	a0,s2
    80003e30:	cafff0ef          	jal	ra,80003ade <writei>
    80003e34:	1541                	addi	a0,a0,-16
    80003e36:	00a03533          	snez	a0,a0
    80003e3a:	40a00533          	neg	a0,a0
}
    80003e3e:	70e2                	ld	ra,56(sp)
    80003e40:	7442                	ld	s0,48(sp)
    80003e42:	74a2                	ld	s1,40(sp)
    80003e44:	7902                	ld	s2,32(sp)
    80003e46:	69e2                	ld	s3,24(sp)
    80003e48:	6a42                	ld	s4,16(sp)
    80003e4a:	6121                	addi	sp,sp,64
    80003e4c:	8082                	ret
    iput(ip);
    80003e4e:	99fff0ef          	jal	ra,800037ec <iput>
    return -1;
    80003e52:	557d                	li	a0,-1
    80003e54:	b7ed                	j	80003e3e <dirlink+0x76>
      panic("dirlink read");
    80003e56:	00003517          	auipc	a0,0x3
    80003e5a:	79a50513          	addi	a0,a0,1946 # 800075f0 <syscalls+0x1f8>
    80003e5e:	92bfc0ef          	jal	ra,80000788 <panic>

0000000080003e62 <namei>:

struct inode*
namei(char *path)
{
    80003e62:	1101                	addi	sp,sp,-32
    80003e64:	ec06                	sd	ra,24(sp)
    80003e66:	e822                	sd	s0,16(sp)
    80003e68:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e6a:	fe040613          	addi	a2,s0,-32
    80003e6e:	4581                	li	a1,0
    80003e70:	e23ff0ef          	jal	ra,80003c92 <namex>
}
    80003e74:	60e2                	ld	ra,24(sp)
    80003e76:	6442                	ld	s0,16(sp)
    80003e78:	6105                	addi	sp,sp,32
    80003e7a:	8082                	ret

0000000080003e7c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e7c:	1141                	addi	sp,sp,-16
    80003e7e:	e406                	sd	ra,8(sp)
    80003e80:	e022                	sd	s0,0(sp)
    80003e82:	0800                	addi	s0,sp,16
    80003e84:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e86:	4585                	li	a1,1
    80003e88:	e0bff0ef          	jal	ra,80003c92 <namex>
}
    80003e8c:	60a2                	ld	ra,8(sp)
    80003e8e:	6402                	ld	s0,0(sp)
    80003e90:	0141                	addi	sp,sp,16
    80003e92:	8082                	ret

0000000080003e94 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e94:	1101                	addi	sp,sp,-32
    80003e96:	ec06                	sd	ra,24(sp)
    80003e98:	e822                	sd	s0,16(sp)
    80003e9a:	e426                	sd	s1,8(sp)
    80003e9c:	e04a                	sd	s2,0(sp)
    80003e9e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ea0:	00244917          	auipc	s2,0x244
    80003ea4:	ae090913          	addi	s2,s2,-1312 # 80247980 <log>
    80003ea8:	01892583          	lw	a1,24(s2)
    80003eac:	02492503          	lw	a0,36(s2)
    80003eb0:	90eff0ef          	jal	ra,80002fbe <bread>
    80003eb4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003eb6:	02892683          	lw	a3,40(s2)
    80003eba:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ebc:	02d05863          	blez	a3,80003eec <write_head+0x58>
    80003ec0:	00244797          	auipc	a5,0x244
    80003ec4:	aec78793          	addi	a5,a5,-1300 # 802479ac <log+0x2c>
    80003ec8:	05c50713          	addi	a4,a0,92
    80003ecc:	36fd                	addiw	a3,a3,-1
    80003ece:	02069613          	slli	a2,a3,0x20
    80003ed2:	01e65693          	srli	a3,a2,0x1e
    80003ed6:	00244617          	auipc	a2,0x244
    80003eda:	ada60613          	addi	a2,a2,-1318 # 802479b0 <log+0x30>
    80003ede:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ee0:	4390                	lw	a2,0(a5)
    80003ee2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ee4:	0791                	addi	a5,a5,4
    80003ee6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003ee8:	fed79ce3          	bne	a5,a3,80003ee0 <write_head+0x4c>
  }
  bwrite(buf);
    80003eec:	8526                	mv	a0,s1
    80003eee:	9a6ff0ef          	jal	ra,80003094 <bwrite>
  brelse(buf);
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	9d2ff0ef          	jal	ra,800030c6 <brelse>
}
    80003ef8:	60e2                	ld	ra,24(sp)
    80003efa:	6442                	ld	s0,16(sp)
    80003efc:	64a2                	ld	s1,8(sp)
    80003efe:	6902                	ld	s2,0(sp)
    80003f00:	6105                	addi	sp,sp,32
    80003f02:	8082                	ret

0000000080003f04 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f04:	00244797          	auipc	a5,0x244
    80003f08:	aa47a783          	lw	a5,-1372(a5) # 802479a8 <log+0x28>
    80003f0c:	0af05e63          	blez	a5,80003fc8 <install_trans+0xc4>
{
    80003f10:	715d                	addi	sp,sp,-80
    80003f12:	e486                	sd	ra,72(sp)
    80003f14:	e0a2                	sd	s0,64(sp)
    80003f16:	fc26                	sd	s1,56(sp)
    80003f18:	f84a                	sd	s2,48(sp)
    80003f1a:	f44e                	sd	s3,40(sp)
    80003f1c:	f052                	sd	s4,32(sp)
    80003f1e:	ec56                	sd	s5,24(sp)
    80003f20:	e85a                	sd	s6,16(sp)
    80003f22:	e45e                	sd	s7,8(sp)
    80003f24:	0880                	addi	s0,sp,80
    80003f26:	8b2a                	mv	s6,a0
    80003f28:	00244a97          	auipc	s5,0x244
    80003f2c:	a84a8a93          	addi	s5,s5,-1404 # 802479ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f30:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f32:	00003b97          	auipc	s7,0x3
    80003f36:	6ceb8b93          	addi	s7,s7,1742 # 80007600 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f3a:	00244a17          	auipc	s4,0x244
    80003f3e:	a46a0a13          	addi	s4,s4,-1466 # 80247980 <log>
    80003f42:	a025                	j	80003f6a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f44:	000aa603          	lw	a2,0(s5)
    80003f48:	85ce                	mv	a1,s3
    80003f4a:	855e                	mv	a0,s7
    80003f4c:	d76fc0ef          	jal	ra,800004c2 <printf>
    80003f50:	a839                	j	80003f6e <install_trans+0x6a>
    brelse(lbuf);
    80003f52:	854a                	mv	a0,s2
    80003f54:	972ff0ef          	jal	ra,800030c6 <brelse>
    brelse(dbuf);
    80003f58:	8526                	mv	a0,s1
    80003f5a:	96cff0ef          	jal	ra,800030c6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f5e:	2985                	addiw	s3,s3,1
    80003f60:	0a91                	addi	s5,s5,4
    80003f62:	028a2783          	lw	a5,40(s4)
    80003f66:	04f9d663          	bge	s3,a5,80003fb2 <install_trans+0xae>
    if(recovering) {
    80003f6a:	fc0b1de3          	bnez	s6,80003f44 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f6e:	018a2583          	lw	a1,24(s4)
    80003f72:	013585bb          	addw	a1,a1,s3
    80003f76:	2585                	addiw	a1,a1,1
    80003f78:	024a2503          	lw	a0,36(s4)
    80003f7c:	842ff0ef          	jal	ra,80002fbe <bread>
    80003f80:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f82:	000aa583          	lw	a1,0(s5)
    80003f86:	024a2503          	lw	a0,36(s4)
    80003f8a:	834ff0ef          	jal	ra,80002fbe <bread>
    80003f8e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f90:	40000613          	li	a2,1024
    80003f94:	05890593          	addi	a1,s2,88
    80003f98:	05850513          	addi	a0,a0,88
    80003f9c:	e35fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fa0:	8526                	mv	a0,s1
    80003fa2:	8f2ff0ef          	jal	ra,80003094 <bwrite>
    if(recovering == 0)
    80003fa6:	fa0b16e3          	bnez	s6,80003f52 <install_trans+0x4e>
      bunpin(dbuf);
    80003faa:	8526                	mv	a0,s1
    80003fac:	9d8ff0ef          	jal	ra,80003184 <bunpin>
    80003fb0:	b74d                	j	80003f52 <install_trans+0x4e>
}
    80003fb2:	60a6                	ld	ra,72(sp)
    80003fb4:	6406                	ld	s0,64(sp)
    80003fb6:	74e2                	ld	s1,56(sp)
    80003fb8:	7942                	ld	s2,48(sp)
    80003fba:	79a2                	ld	s3,40(sp)
    80003fbc:	7a02                	ld	s4,32(sp)
    80003fbe:	6ae2                	ld	s5,24(sp)
    80003fc0:	6b42                	ld	s6,16(sp)
    80003fc2:	6ba2                	ld	s7,8(sp)
    80003fc4:	6161                	addi	sp,sp,80
    80003fc6:	8082                	ret
    80003fc8:	8082                	ret

0000000080003fca <initlog>:
{
    80003fca:	7179                	addi	sp,sp,-48
    80003fcc:	f406                	sd	ra,40(sp)
    80003fce:	f022                	sd	s0,32(sp)
    80003fd0:	ec26                	sd	s1,24(sp)
    80003fd2:	e84a                	sd	s2,16(sp)
    80003fd4:	e44e                	sd	s3,8(sp)
    80003fd6:	1800                	addi	s0,sp,48
    80003fd8:	892a                	mv	s2,a0
    80003fda:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fdc:	00244497          	auipc	s1,0x244
    80003fe0:	9a448493          	addi	s1,s1,-1628 # 80247980 <log>
    80003fe4:	00003597          	auipc	a1,0x3
    80003fe8:	63c58593          	addi	a1,a1,1596 # 80007620 <syscalls+0x228>
    80003fec:	8526                	mv	a0,s1
    80003fee:	c33fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80003ff2:	0149a583          	lw	a1,20(s3)
    80003ff6:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003ff8:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	fc1fe0ef          	jal	ra,80002fbe <bread>
  log.lh.n = lh->n;
    80004002:	4d34                	lw	a3,88(a0)
    80004004:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004006:	02d05663          	blez	a3,80004032 <initlog+0x68>
    8000400a:	05c50793          	addi	a5,a0,92
    8000400e:	00244717          	auipc	a4,0x244
    80004012:	99e70713          	addi	a4,a4,-1634 # 802479ac <log+0x2c>
    80004016:	36fd                	addiw	a3,a3,-1
    80004018:	02069613          	slli	a2,a3,0x20
    8000401c:	01e65693          	srli	a3,a2,0x1e
    80004020:	06050613          	addi	a2,a0,96
    80004024:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004026:	4390                	lw	a2,0(a5)
    80004028:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000402a:	0791                	addi	a5,a5,4
    8000402c:	0711                	addi	a4,a4,4
    8000402e:	fed79ce3          	bne	a5,a3,80004026 <initlog+0x5c>
  brelse(buf);
    80004032:	894ff0ef          	jal	ra,800030c6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004036:	4505                	li	a0,1
    80004038:	ecdff0ef          	jal	ra,80003f04 <install_trans>
  log.lh.n = 0;
    8000403c:	00244797          	auipc	a5,0x244
    80004040:	9607a623          	sw	zero,-1684(a5) # 802479a8 <log+0x28>
  write_head(); // clear the log
    80004044:	e51ff0ef          	jal	ra,80003e94 <write_head>
}
    80004048:	70a2                	ld	ra,40(sp)
    8000404a:	7402                	ld	s0,32(sp)
    8000404c:	64e2                	ld	s1,24(sp)
    8000404e:	6942                	ld	s2,16(sp)
    80004050:	69a2                	ld	s3,8(sp)
    80004052:	6145                	addi	sp,sp,48
    80004054:	8082                	ret

0000000080004056 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004056:	1101                	addi	sp,sp,-32
    80004058:	ec06                	sd	ra,24(sp)
    8000405a:	e822                	sd	s0,16(sp)
    8000405c:	e426                	sd	s1,8(sp)
    8000405e:	e04a                	sd	s2,0(sp)
    80004060:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004062:	00244517          	auipc	a0,0x244
    80004066:	91e50513          	addi	a0,a0,-1762 # 80247980 <log>
    8000406a:	c37fc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    8000406e:	00244497          	auipc	s1,0x244
    80004072:	91248493          	addi	s1,s1,-1774 # 80247980 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004076:	4979                	li	s2,30
    80004078:	a029                	j	80004082 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000407a:	85a6                	mv	a1,s1
    8000407c:	8526                	mv	a0,s1
    8000407e:	8c2fe0ef          	jal	ra,80002140 <sleep>
    if(log.committing){
    80004082:	509c                	lw	a5,32(s1)
    80004084:	fbfd                	bnez	a5,8000407a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004086:	4cd8                	lw	a4,28(s1)
    80004088:	2705                	addiw	a4,a4,1
    8000408a:	0007069b          	sext.w	a3,a4
    8000408e:	0027179b          	slliw	a5,a4,0x2
    80004092:	9fb9                	addw	a5,a5,a4
    80004094:	0017979b          	slliw	a5,a5,0x1
    80004098:	5498                	lw	a4,40(s1)
    8000409a:	9fb9                	addw	a5,a5,a4
    8000409c:	00f95763          	bge	s2,a5,800040aa <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040a0:	85a6                	mv	a1,s1
    800040a2:	8526                	mv	a0,s1
    800040a4:	89cfe0ef          	jal	ra,80002140 <sleep>
    800040a8:	bfe9                	j	80004082 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800040aa:	00244517          	auipc	a0,0x244
    800040ae:	8d650513          	addi	a0,a0,-1834 # 80247980 <log>
    800040b2:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800040b4:	c85fc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    800040b8:	60e2                	ld	ra,24(sp)
    800040ba:	6442                	ld	s0,16(sp)
    800040bc:	64a2                	ld	s1,8(sp)
    800040be:	6902                	ld	s2,0(sp)
    800040c0:	6105                	addi	sp,sp,32
    800040c2:	8082                	ret

00000000800040c4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040c4:	7139                	addi	sp,sp,-64
    800040c6:	fc06                	sd	ra,56(sp)
    800040c8:	f822                	sd	s0,48(sp)
    800040ca:	f426                	sd	s1,40(sp)
    800040cc:	f04a                	sd	s2,32(sp)
    800040ce:	ec4e                	sd	s3,24(sp)
    800040d0:	e852                	sd	s4,16(sp)
    800040d2:	e456                	sd	s5,8(sp)
    800040d4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040d6:	00244497          	auipc	s1,0x244
    800040da:	8aa48493          	addi	s1,s1,-1878 # 80247980 <log>
    800040de:	8526                	mv	a0,s1
    800040e0:	bc1fc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    800040e4:	4cdc                	lw	a5,28(s1)
    800040e6:	37fd                	addiw	a5,a5,-1
    800040e8:	0007891b          	sext.w	s2,a5
    800040ec:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800040ee:	509c                	lw	a5,32(s1)
    800040f0:	ef9d                	bnez	a5,8000412e <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    800040f2:	04091463          	bnez	s2,8000413a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800040f6:	00244497          	auipc	s1,0x244
    800040fa:	88a48493          	addi	s1,s1,-1910 # 80247980 <log>
    800040fe:	4785                	li	a5,1
    80004100:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004102:	8526                	mv	a0,s1
    80004104:	c35fc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004108:	549c                	lw	a5,40(s1)
    8000410a:	04f04b63          	bgtz	a5,80004160 <end_op+0x9c>
    acquire(&log.lock);
    8000410e:	00244497          	auipc	s1,0x244
    80004112:	87248493          	addi	s1,s1,-1934 # 80247980 <log>
    80004116:	8526                	mv	a0,s1
    80004118:	b89fc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    8000411c:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004120:	8526                	mv	a0,s1
    80004122:	86afe0ef          	jal	ra,8000218c <wakeup>
    release(&log.lock);
    80004126:	8526                	mv	a0,s1
    80004128:	c11fc0ef          	jal	ra,80000d38 <release>
}
    8000412c:	a00d                	j	8000414e <end_op+0x8a>
    panic("log.committing");
    8000412e:	00003517          	auipc	a0,0x3
    80004132:	4fa50513          	addi	a0,a0,1274 # 80007628 <syscalls+0x230>
    80004136:	e52fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    8000413a:	00244497          	auipc	s1,0x244
    8000413e:	84648493          	addi	s1,s1,-1978 # 80247980 <log>
    80004142:	8526                	mv	a0,s1
    80004144:	848fe0ef          	jal	ra,8000218c <wakeup>
  release(&log.lock);
    80004148:	8526                	mv	a0,s1
    8000414a:	beffc0ef          	jal	ra,80000d38 <release>
}
    8000414e:	70e2                	ld	ra,56(sp)
    80004150:	7442                	ld	s0,48(sp)
    80004152:	74a2                	ld	s1,40(sp)
    80004154:	7902                	ld	s2,32(sp)
    80004156:	69e2                	ld	s3,24(sp)
    80004158:	6a42                	ld	s4,16(sp)
    8000415a:	6aa2                	ld	s5,8(sp)
    8000415c:	6121                	addi	sp,sp,64
    8000415e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004160:	00244a97          	auipc	s5,0x244
    80004164:	84ca8a93          	addi	s5,s5,-1972 # 802479ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004168:	00244a17          	auipc	s4,0x244
    8000416c:	818a0a13          	addi	s4,s4,-2024 # 80247980 <log>
    80004170:	018a2583          	lw	a1,24(s4)
    80004174:	012585bb          	addw	a1,a1,s2
    80004178:	2585                	addiw	a1,a1,1
    8000417a:	024a2503          	lw	a0,36(s4)
    8000417e:	e41fe0ef          	jal	ra,80002fbe <bread>
    80004182:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004184:	000aa583          	lw	a1,0(s5)
    80004188:	024a2503          	lw	a0,36(s4)
    8000418c:	e33fe0ef          	jal	ra,80002fbe <bread>
    80004190:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004192:	40000613          	li	a2,1024
    80004196:	05850593          	addi	a1,a0,88
    8000419a:	05848513          	addi	a0,s1,88
    8000419e:	c33fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    800041a2:	8526                	mv	a0,s1
    800041a4:	ef1fe0ef          	jal	ra,80003094 <bwrite>
    brelse(from);
    800041a8:	854e                	mv	a0,s3
    800041aa:	f1dfe0ef          	jal	ra,800030c6 <brelse>
    brelse(to);
    800041ae:	8526                	mv	a0,s1
    800041b0:	f17fe0ef          	jal	ra,800030c6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b4:	2905                	addiw	s2,s2,1
    800041b6:	0a91                	addi	s5,s5,4
    800041b8:	028a2783          	lw	a5,40(s4)
    800041bc:	faf94ae3          	blt	s2,a5,80004170 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041c0:	cd5ff0ef          	jal	ra,80003e94 <write_head>
    install_trans(0); // Now install writes to home locations
    800041c4:	4501                	li	a0,0
    800041c6:	d3fff0ef          	jal	ra,80003f04 <install_trans>
    log.lh.n = 0;
    800041ca:	00243797          	auipc	a5,0x243
    800041ce:	7c07af23          	sw	zero,2014(a5) # 802479a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800041d2:	cc3ff0ef          	jal	ra,80003e94 <write_head>
    800041d6:	bf25                	j	8000410e <end_op+0x4a>

00000000800041d8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041d8:	1101                	addi	sp,sp,-32
    800041da:	ec06                	sd	ra,24(sp)
    800041dc:	e822                	sd	s0,16(sp)
    800041de:	e426                	sd	s1,8(sp)
    800041e0:	e04a                	sd	s2,0(sp)
    800041e2:	1000                	addi	s0,sp,32
    800041e4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041e6:	00243917          	auipc	s2,0x243
    800041ea:	79a90913          	addi	s2,s2,1946 # 80247980 <log>
    800041ee:	854a                	mv	a0,s2
    800041f0:	ab1fc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800041f4:	02892603          	lw	a2,40(s2)
    800041f8:	47f5                	li	a5,29
    800041fa:	04c7cc63          	blt	a5,a2,80004252 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041fe:	00243797          	auipc	a5,0x243
    80004202:	79e7a783          	lw	a5,1950(a5) # 8024799c <log+0x1c>
    80004206:	04f05c63          	blez	a5,8000425e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000420a:	4781                	li	a5,0
    8000420c:	04c05f63          	blez	a2,8000426a <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004210:	44cc                	lw	a1,12(s1)
    80004212:	00243717          	auipc	a4,0x243
    80004216:	79a70713          	addi	a4,a4,1946 # 802479ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000421a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000421c:	4314                	lw	a3,0(a4)
    8000421e:	04b68663          	beq	a3,a1,8000426a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004222:	2785                	addiw	a5,a5,1
    80004224:	0711                	addi	a4,a4,4
    80004226:	fef61be3          	bne	a2,a5,8000421c <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000422a:	0621                	addi	a2,a2,8
    8000422c:	060a                	slli	a2,a2,0x2
    8000422e:	00243797          	auipc	a5,0x243
    80004232:	75278793          	addi	a5,a5,1874 # 80247980 <log>
    80004236:	97b2                	add	a5,a5,a2
    80004238:	44d8                	lw	a4,12(s1)
    8000423a:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000423c:	8526                	mv	a0,s1
    8000423e:	f13fe0ef          	jal	ra,80003150 <bpin>
    log.lh.n++;
    80004242:	00243717          	auipc	a4,0x243
    80004246:	73e70713          	addi	a4,a4,1854 # 80247980 <log>
    8000424a:	571c                	lw	a5,40(a4)
    8000424c:	2785                	addiw	a5,a5,1
    8000424e:	d71c                	sw	a5,40(a4)
    80004250:	a80d                	j	80004282 <log_write+0xaa>
    panic("too big a transaction");
    80004252:	00003517          	auipc	a0,0x3
    80004256:	3e650513          	addi	a0,a0,998 # 80007638 <syscalls+0x240>
    8000425a:	d2efc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    8000425e:	00003517          	auipc	a0,0x3
    80004262:	3f250513          	addi	a0,a0,1010 # 80007650 <syscalls+0x258>
    80004266:	d22fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    8000426a:	00878693          	addi	a3,a5,8
    8000426e:	068a                	slli	a3,a3,0x2
    80004270:	00243717          	auipc	a4,0x243
    80004274:	71070713          	addi	a4,a4,1808 # 80247980 <log>
    80004278:	9736                	add	a4,a4,a3
    8000427a:	44d4                	lw	a3,12(s1)
    8000427c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000427e:	faf60fe3          	beq	a2,a5,8000423c <log_write+0x64>
  }
  release(&log.lock);
    80004282:	00243517          	auipc	a0,0x243
    80004286:	6fe50513          	addi	a0,a0,1790 # 80247980 <log>
    8000428a:	aaffc0ef          	jal	ra,80000d38 <release>
}
    8000428e:	60e2                	ld	ra,24(sp)
    80004290:	6442                	ld	s0,16(sp)
    80004292:	64a2                	ld	s1,8(sp)
    80004294:	6902                	ld	s2,0(sp)
    80004296:	6105                	addi	sp,sp,32
    80004298:	8082                	ret

000000008000429a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	e426                	sd	s1,8(sp)
    800042a2:	e04a                	sd	s2,0(sp)
    800042a4:	1000                	addi	s0,sp,32
    800042a6:	84aa                	mv	s1,a0
    800042a8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042aa:	00003597          	auipc	a1,0x3
    800042ae:	3c658593          	addi	a1,a1,966 # 80007670 <syscalls+0x278>
    800042b2:	0521                	addi	a0,a0,8
    800042b4:	96dfc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    800042b8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042c0:	0204a423          	sw	zero,40(s1)
}
    800042c4:	60e2                	ld	ra,24(sp)
    800042c6:	6442                	ld	s0,16(sp)
    800042c8:	64a2                	ld	s1,8(sp)
    800042ca:	6902                	ld	s2,0(sp)
    800042cc:	6105                	addi	sp,sp,32
    800042ce:	8082                	ret

00000000800042d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042d0:	1101                	addi	sp,sp,-32
    800042d2:	ec06                	sd	ra,24(sp)
    800042d4:	e822                	sd	s0,16(sp)
    800042d6:	e426                	sd	s1,8(sp)
    800042d8:	e04a                	sd	s2,0(sp)
    800042da:	1000                	addi	s0,sp,32
    800042dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042de:	00850913          	addi	s2,a0,8
    800042e2:	854a                	mv	a0,s2
    800042e4:	9bdfc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    800042e8:	409c                	lw	a5,0(s1)
    800042ea:	c799                	beqz	a5,800042f8 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800042ec:	85ca                	mv	a1,s2
    800042ee:	8526                	mv	a0,s1
    800042f0:	e51fd0ef          	jal	ra,80002140 <sleep>
  while (lk->locked) {
    800042f4:	409c                	lw	a5,0(s1)
    800042f6:	fbfd                	bnez	a5,800042ec <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800042f8:	4785                	li	a5,1
    800042fa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042fc:	fd6fd0ef          	jal	ra,80001ad2 <myproc>
    80004300:	591c                	lw	a5,48(a0)
    80004302:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004304:	854a                	mv	a0,s2
    80004306:	a33fc0ef          	jal	ra,80000d38 <release>
}
    8000430a:	60e2                	ld	ra,24(sp)
    8000430c:	6442                	ld	s0,16(sp)
    8000430e:	64a2                	ld	s1,8(sp)
    80004310:	6902                	ld	s2,0(sp)
    80004312:	6105                	addi	sp,sp,32
    80004314:	8082                	ret

0000000080004316 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004316:	1101                	addi	sp,sp,-32
    80004318:	ec06                	sd	ra,24(sp)
    8000431a:	e822                	sd	s0,16(sp)
    8000431c:	e426                	sd	s1,8(sp)
    8000431e:	e04a                	sd	s2,0(sp)
    80004320:	1000                	addi	s0,sp,32
    80004322:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004324:	00850913          	addi	s2,a0,8
    80004328:	854a                	mv	a0,s2
    8000432a:	977fc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    8000432e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004332:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004336:	8526                	mv	a0,s1
    80004338:	e55fd0ef          	jal	ra,8000218c <wakeup>
  release(&lk->lk);
    8000433c:	854a                	mv	a0,s2
    8000433e:	9fbfc0ef          	jal	ra,80000d38 <release>
}
    80004342:	60e2                	ld	ra,24(sp)
    80004344:	6442                	ld	s0,16(sp)
    80004346:	64a2                	ld	s1,8(sp)
    80004348:	6902                	ld	s2,0(sp)
    8000434a:	6105                	addi	sp,sp,32
    8000434c:	8082                	ret

000000008000434e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000434e:	7179                	addi	sp,sp,-48
    80004350:	f406                	sd	ra,40(sp)
    80004352:	f022                	sd	s0,32(sp)
    80004354:	ec26                	sd	s1,24(sp)
    80004356:	e84a                	sd	s2,16(sp)
    80004358:	e44e                	sd	s3,8(sp)
    8000435a:	1800                	addi	s0,sp,48
    8000435c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000435e:	00850913          	addi	s2,a0,8
    80004362:	854a                	mv	a0,s2
    80004364:	93dfc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004368:	409c                	lw	a5,0(s1)
    8000436a:	ef89                	bnez	a5,80004384 <holdingsleep+0x36>
    8000436c:	4481                	li	s1,0
  release(&lk->lk);
    8000436e:	854a                	mv	a0,s2
    80004370:	9c9fc0ef          	jal	ra,80000d38 <release>
  return r;
}
    80004374:	8526                	mv	a0,s1
    80004376:	70a2                	ld	ra,40(sp)
    80004378:	7402                	ld	s0,32(sp)
    8000437a:	64e2                	ld	s1,24(sp)
    8000437c:	6942                	ld	s2,16(sp)
    8000437e:	69a2                	ld	s3,8(sp)
    80004380:	6145                	addi	sp,sp,48
    80004382:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004384:	0284a983          	lw	s3,40(s1)
    80004388:	f4afd0ef          	jal	ra,80001ad2 <myproc>
    8000438c:	5904                	lw	s1,48(a0)
    8000438e:	413484b3          	sub	s1,s1,s3
    80004392:	0014b493          	seqz	s1,s1
    80004396:	bfe1                	j	8000436e <holdingsleep+0x20>

0000000080004398 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004398:	1141                	addi	sp,sp,-16
    8000439a:	e406                	sd	ra,8(sp)
    8000439c:	e022                	sd	s0,0(sp)
    8000439e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043a0:	00003597          	auipc	a1,0x3
    800043a4:	2e058593          	addi	a1,a1,736 # 80007680 <syscalls+0x288>
    800043a8:	00243517          	auipc	a0,0x243
    800043ac:	72050513          	addi	a0,a0,1824 # 80247ac8 <ftable>
    800043b0:	871fc0ef          	jal	ra,80000c20 <initlock>
}
    800043b4:	60a2                	ld	ra,8(sp)
    800043b6:	6402                	ld	s0,0(sp)
    800043b8:	0141                	addi	sp,sp,16
    800043ba:	8082                	ret

00000000800043bc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043bc:	1101                	addi	sp,sp,-32
    800043be:	ec06                	sd	ra,24(sp)
    800043c0:	e822                	sd	s0,16(sp)
    800043c2:	e426                	sd	s1,8(sp)
    800043c4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043c6:	00243517          	auipc	a0,0x243
    800043ca:	70250513          	addi	a0,a0,1794 # 80247ac8 <ftable>
    800043ce:	8d3fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043d2:	00243497          	auipc	s1,0x243
    800043d6:	70e48493          	addi	s1,s1,1806 # 80247ae0 <ftable+0x18>
    800043da:	00244717          	auipc	a4,0x244
    800043de:	6a670713          	addi	a4,a4,1702 # 80248a80 <disk>
    if(f->ref == 0){
    800043e2:	40dc                	lw	a5,4(s1)
    800043e4:	cf89                	beqz	a5,800043fe <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043e6:	02848493          	addi	s1,s1,40
    800043ea:	fee49ce3          	bne	s1,a4,800043e2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800043ee:	00243517          	auipc	a0,0x243
    800043f2:	6da50513          	addi	a0,a0,1754 # 80247ac8 <ftable>
    800043f6:	943fc0ef          	jal	ra,80000d38 <release>
  return 0;
    800043fa:	4481                	li	s1,0
    800043fc:	a809                	j	8000440e <filealloc+0x52>
      f->ref = 1;
    800043fe:	4785                	li	a5,1
    80004400:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004402:	00243517          	auipc	a0,0x243
    80004406:	6c650513          	addi	a0,a0,1734 # 80247ac8 <ftable>
    8000440a:	92ffc0ef          	jal	ra,80000d38 <release>
}
    8000440e:	8526                	mv	a0,s1
    80004410:	60e2                	ld	ra,24(sp)
    80004412:	6442                	ld	s0,16(sp)
    80004414:	64a2                	ld	s1,8(sp)
    80004416:	6105                	addi	sp,sp,32
    80004418:	8082                	ret

000000008000441a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000441a:	1101                	addi	sp,sp,-32
    8000441c:	ec06                	sd	ra,24(sp)
    8000441e:	e822                	sd	s0,16(sp)
    80004420:	e426                	sd	s1,8(sp)
    80004422:	1000                	addi	s0,sp,32
    80004424:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004426:	00243517          	auipc	a0,0x243
    8000442a:	6a250513          	addi	a0,a0,1698 # 80247ac8 <ftable>
    8000442e:	873fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004432:	40dc                	lw	a5,4(s1)
    80004434:	02f05063          	blez	a5,80004454 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004438:	2785                	addiw	a5,a5,1
    8000443a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000443c:	00243517          	auipc	a0,0x243
    80004440:	68c50513          	addi	a0,a0,1676 # 80247ac8 <ftable>
    80004444:	8f5fc0ef          	jal	ra,80000d38 <release>
  return f;
}
    80004448:	8526                	mv	a0,s1
    8000444a:	60e2                	ld	ra,24(sp)
    8000444c:	6442                	ld	s0,16(sp)
    8000444e:	64a2                	ld	s1,8(sp)
    80004450:	6105                	addi	sp,sp,32
    80004452:	8082                	ret
    panic("filedup");
    80004454:	00003517          	auipc	a0,0x3
    80004458:	23450513          	addi	a0,a0,564 # 80007688 <syscalls+0x290>
    8000445c:	b2cfc0ef          	jal	ra,80000788 <panic>

0000000080004460 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004460:	7139                	addi	sp,sp,-64
    80004462:	fc06                	sd	ra,56(sp)
    80004464:	f822                	sd	s0,48(sp)
    80004466:	f426                	sd	s1,40(sp)
    80004468:	f04a                	sd	s2,32(sp)
    8000446a:	ec4e                	sd	s3,24(sp)
    8000446c:	e852                	sd	s4,16(sp)
    8000446e:	e456                	sd	s5,8(sp)
    80004470:	0080                	addi	s0,sp,64
    80004472:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004474:	00243517          	auipc	a0,0x243
    80004478:	65450513          	addi	a0,a0,1620 # 80247ac8 <ftable>
    8000447c:	825fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004480:	40dc                	lw	a5,4(s1)
    80004482:	04f05963          	blez	a5,800044d4 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004486:	37fd                	addiw	a5,a5,-1
    80004488:	0007871b          	sext.w	a4,a5
    8000448c:	c0dc                	sw	a5,4(s1)
    8000448e:	04e04963          	bgtz	a4,800044e0 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004492:	0004a903          	lw	s2,0(s1)
    80004496:	0094ca83          	lbu	s5,9(s1)
    8000449a:	0104ba03          	ld	s4,16(s1)
    8000449e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044a2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044a6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044aa:	00243517          	auipc	a0,0x243
    800044ae:	61e50513          	addi	a0,a0,1566 # 80247ac8 <ftable>
    800044b2:	887fc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    800044b6:	4785                	li	a5,1
    800044b8:	04f90363          	beq	s2,a5,800044fe <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044bc:	3979                	addiw	s2,s2,-2
    800044be:	4785                	li	a5,1
    800044c0:	0327e663          	bltu	a5,s2,800044ec <fileclose+0x8c>
    begin_op();
    800044c4:	b93ff0ef          	jal	ra,80004056 <begin_op>
    iput(ff.ip);
    800044c8:	854e                	mv	a0,s3
    800044ca:	b22ff0ef          	jal	ra,800037ec <iput>
    end_op();
    800044ce:	bf7ff0ef          	jal	ra,800040c4 <end_op>
    800044d2:	a829                	j	800044ec <fileclose+0x8c>
    panic("fileclose");
    800044d4:	00003517          	auipc	a0,0x3
    800044d8:	1bc50513          	addi	a0,a0,444 # 80007690 <syscalls+0x298>
    800044dc:	aacfc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    800044e0:	00243517          	auipc	a0,0x243
    800044e4:	5e850513          	addi	a0,a0,1512 # 80247ac8 <ftable>
    800044e8:	851fc0ef          	jal	ra,80000d38 <release>
  }
}
    800044ec:	70e2                	ld	ra,56(sp)
    800044ee:	7442                	ld	s0,48(sp)
    800044f0:	74a2                	ld	s1,40(sp)
    800044f2:	7902                	ld	s2,32(sp)
    800044f4:	69e2                	ld	s3,24(sp)
    800044f6:	6a42                	ld	s4,16(sp)
    800044f8:	6aa2                	ld	s5,8(sp)
    800044fa:	6121                	addi	sp,sp,64
    800044fc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800044fe:	85d6                	mv	a1,s5
    80004500:	8552                	mv	a0,s4
    80004502:	2ec000ef          	jal	ra,800047ee <pipeclose>
    80004506:	b7dd                	j	800044ec <fileclose+0x8c>

0000000080004508 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004508:	715d                	addi	sp,sp,-80
    8000450a:	e486                	sd	ra,72(sp)
    8000450c:	e0a2                	sd	s0,64(sp)
    8000450e:	fc26                	sd	s1,56(sp)
    80004510:	f84a                	sd	s2,48(sp)
    80004512:	f44e                	sd	s3,40(sp)
    80004514:	0880                	addi	s0,sp,80
    80004516:	84aa                	mv	s1,a0
    80004518:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000451a:	db8fd0ef          	jal	ra,80001ad2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000451e:	409c                	lw	a5,0(s1)
    80004520:	37f9                	addiw	a5,a5,-2
    80004522:	4705                	li	a4,1
    80004524:	02f76f63          	bltu	a4,a5,80004562 <filestat+0x5a>
    80004528:	892a                	mv	s2,a0
    ilock(f->ip);
    8000452a:	6c88                	ld	a0,24(s1)
    8000452c:	942ff0ef          	jal	ra,8000366e <ilock>
    stati(f->ip, &st);
    80004530:	fb840593          	addi	a1,s0,-72
    80004534:	6c88                	ld	a0,24(s1)
    80004536:	c9aff0ef          	jal	ra,800039d0 <stati>
    iunlock(f->ip);
    8000453a:	6c88                	ld	a0,24(s1)
    8000453c:	9dcff0ef          	jal	ra,80003718 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004540:	46e1                	li	a3,24
    80004542:	fb840613          	addi	a2,s0,-72
    80004546:	85ce                	mv	a1,s3
    80004548:	05093503          	ld	a0,80(s2)
    8000454c:	a12fd0ef          	jal	ra,8000175e <copyout>
    80004550:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004554:	60a6                	ld	ra,72(sp)
    80004556:	6406                	ld	s0,64(sp)
    80004558:	74e2                	ld	s1,56(sp)
    8000455a:	7942                	ld	s2,48(sp)
    8000455c:	79a2                	ld	s3,40(sp)
    8000455e:	6161                	addi	sp,sp,80
    80004560:	8082                	ret
  return -1;
    80004562:	557d                	li	a0,-1
    80004564:	bfc5                	j	80004554 <filestat+0x4c>

0000000080004566 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004566:	7179                	addi	sp,sp,-48
    80004568:	f406                	sd	ra,40(sp)
    8000456a:	f022                	sd	s0,32(sp)
    8000456c:	ec26                	sd	s1,24(sp)
    8000456e:	e84a                	sd	s2,16(sp)
    80004570:	e44e                	sd	s3,8(sp)
    80004572:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004574:	00854783          	lbu	a5,8(a0)
    80004578:	cbc1                	beqz	a5,80004608 <fileread+0xa2>
    8000457a:	84aa                	mv	s1,a0
    8000457c:	89ae                	mv	s3,a1
    8000457e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004580:	411c                	lw	a5,0(a0)
    80004582:	4705                	li	a4,1
    80004584:	04e78363          	beq	a5,a4,800045ca <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004588:	470d                	li	a4,3
    8000458a:	04e78563          	beq	a5,a4,800045d4 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000458e:	4709                	li	a4,2
    80004590:	06e79663          	bne	a5,a4,800045fc <fileread+0x96>
    ilock(f->ip);
    80004594:	6d08                	ld	a0,24(a0)
    80004596:	8d8ff0ef          	jal	ra,8000366e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000459a:	874a                	mv	a4,s2
    8000459c:	5094                	lw	a3,32(s1)
    8000459e:	864e                	mv	a2,s3
    800045a0:	4585                	li	a1,1
    800045a2:	6c88                	ld	a0,24(s1)
    800045a4:	c56ff0ef          	jal	ra,800039fa <readi>
    800045a8:	892a                	mv	s2,a0
    800045aa:	00a05563          	blez	a0,800045b4 <fileread+0x4e>
      f->off += r;
    800045ae:	509c                	lw	a5,32(s1)
    800045b0:	9fa9                	addw	a5,a5,a0
    800045b2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800045b4:	6c88                	ld	a0,24(s1)
    800045b6:	962ff0ef          	jal	ra,80003718 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800045ba:	854a                	mv	a0,s2
    800045bc:	70a2                	ld	ra,40(sp)
    800045be:	7402                	ld	s0,32(sp)
    800045c0:	64e2                	ld	s1,24(sp)
    800045c2:	6942                	ld	s2,16(sp)
    800045c4:	69a2                	ld	s3,8(sp)
    800045c6:	6145                	addi	sp,sp,48
    800045c8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800045ca:	6908                	ld	a0,16(a0)
    800045cc:	34e000ef          	jal	ra,8000491a <piperead>
    800045d0:	892a                	mv	s2,a0
    800045d2:	b7e5                	j	800045ba <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800045d4:	02451783          	lh	a5,36(a0)
    800045d8:	03079693          	slli	a3,a5,0x30
    800045dc:	92c1                	srli	a3,a3,0x30
    800045de:	4725                	li	a4,9
    800045e0:	02d76663          	bltu	a4,a3,8000460c <fileread+0xa6>
    800045e4:	0792                	slli	a5,a5,0x4
    800045e6:	00243717          	auipc	a4,0x243
    800045ea:	44270713          	addi	a4,a4,1090 # 80247a28 <devsw>
    800045ee:	97ba                	add	a5,a5,a4
    800045f0:	639c                	ld	a5,0(a5)
    800045f2:	cf99                	beqz	a5,80004610 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800045f4:	4505                	li	a0,1
    800045f6:	9782                	jalr	a5
    800045f8:	892a                	mv	s2,a0
    800045fa:	b7c1                	j	800045ba <fileread+0x54>
    panic("fileread");
    800045fc:	00003517          	auipc	a0,0x3
    80004600:	0a450513          	addi	a0,a0,164 # 800076a0 <syscalls+0x2a8>
    80004604:	984fc0ef          	jal	ra,80000788 <panic>
    return -1;
    80004608:	597d                	li	s2,-1
    8000460a:	bf45                	j	800045ba <fileread+0x54>
      return -1;
    8000460c:	597d                	li	s2,-1
    8000460e:	b775                	j	800045ba <fileread+0x54>
    80004610:	597d                	li	s2,-1
    80004612:	b765                	j	800045ba <fileread+0x54>

0000000080004614 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004614:	715d                	addi	sp,sp,-80
    80004616:	e486                	sd	ra,72(sp)
    80004618:	e0a2                	sd	s0,64(sp)
    8000461a:	fc26                	sd	s1,56(sp)
    8000461c:	f84a                	sd	s2,48(sp)
    8000461e:	f44e                	sd	s3,40(sp)
    80004620:	f052                	sd	s4,32(sp)
    80004622:	ec56                	sd	s5,24(sp)
    80004624:	e85a                	sd	s6,16(sp)
    80004626:	e45e                	sd	s7,8(sp)
    80004628:	e062                	sd	s8,0(sp)
    8000462a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000462c:	00954783          	lbu	a5,9(a0)
    80004630:	0e078863          	beqz	a5,80004720 <filewrite+0x10c>
    80004634:	892a                	mv	s2,a0
    80004636:	8b2e                	mv	s6,a1
    80004638:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000463a:	411c                	lw	a5,0(a0)
    8000463c:	4705                	li	a4,1
    8000463e:	02e78263          	beq	a5,a4,80004662 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004642:	470d                	li	a4,3
    80004644:	02e78463          	beq	a5,a4,8000466c <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004648:	4709                	li	a4,2
    8000464a:	0ce79563          	bne	a5,a4,80004714 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000464e:	0ac05163          	blez	a2,800046f0 <filewrite+0xdc>
    int i = 0;
    80004652:	4981                	li	s3,0
    80004654:	6b85                	lui	s7,0x1
    80004656:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000465a:	6c05                	lui	s8,0x1
    8000465c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004660:	a041                	j	800046e0 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004662:	6908                	ld	a0,16(a0)
    80004664:	1e2000ef          	jal	ra,80004846 <pipewrite>
    80004668:	8a2a                	mv	s4,a0
    8000466a:	a071                	j	800046f6 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000466c:	02451783          	lh	a5,36(a0)
    80004670:	03079693          	slli	a3,a5,0x30
    80004674:	92c1                	srli	a3,a3,0x30
    80004676:	4725                	li	a4,9
    80004678:	0ad76663          	bltu	a4,a3,80004724 <filewrite+0x110>
    8000467c:	0792                	slli	a5,a5,0x4
    8000467e:	00243717          	auipc	a4,0x243
    80004682:	3aa70713          	addi	a4,a4,938 # 80247a28 <devsw>
    80004686:	97ba                	add	a5,a5,a4
    80004688:	679c                	ld	a5,8(a5)
    8000468a:	cfd9                	beqz	a5,80004728 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000468c:	4505                	li	a0,1
    8000468e:	9782                	jalr	a5
    80004690:	8a2a                	mv	s4,a0
    80004692:	a095                	j	800046f6 <filewrite+0xe2>
    80004694:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004698:	9bfff0ef          	jal	ra,80004056 <begin_op>
      ilock(f->ip);
    8000469c:	01893503          	ld	a0,24(s2)
    800046a0:	fcffe0ef          	jal	ra,8000366e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800046a4:	8756                	mv	a4,s5
    800046a6:	02092683          	lw	a3,32(s2)
    800046aa:	01698633          	add	a2,s3,s6
    800046ae:	4585                	li	a1,1
    800046b0:	01893503          	ld	a0,24(s2)
    800046b4:	c2aff0ef          	jal	ra,80003ade <writei>
    800046b8:	84aa                	mv	s1,a0
    800046ba:	00a05763          	blez	a0,800046c8 <filewrite+0xb4>
        f->off += r;
    800046be:	02092783          	lw	a5,32(s2)
    800046c2:	9fa9                	addw	a5,a5,a0
    800046c4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800046c8:	01893503          	ld	a0,24(s2)
    800046cc:	84cff0ef          	jal	ra,80003718 <iunlock>
      end_op();
    800046d0:	9f5ff0ef          	jal	ra,800040c4 <end_op>

      if(r != n1){
    800046d4:	009a9f63          	bne	s5,s1,800046f2 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800046d8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800046dc:	0149db63          	bge	s3,s4,800046f2 <filewrite+0xde>
      int n1 = n - i;
    800046e0:	413a04bb          	subw	s1,s4,s3
    800046e4:	0004879b          	sext.w	a5,s1
    800046e8:	fafbd6e3          	bge	s7,a5,80004694 <filewrite+0x80>
    800046ec:	84e2                	mv	s1,s8
    800046ee:	b75d                	j	80004694 <filewrite+0x80>
    int i = 0;
    800046f0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800046f2:	013a1f63          	bne	s4,s3,80004710 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800046f6:	8552                	mv	a0,s4
    800046f8:	60a6                	ld	ra,72(sp)
    800046fa:	6406                	ld	s0,64(sp)
    800046fc:	74e2                	ld	s1,56(sp)
    800046fe:	7942                	ld	s2,48(sp)
    80004700:	79a2                	ld	s3,40(sp)
    80004702:	7a02                	ld	s4,32(sp)
    80004704:	6ae2                	ld	s5,24(sp)
    80004706:	6b42                	ld	s6,16(sp)
    80004708:	6ba2                	ld	s7,8(sp)
    8000470a:	6c02                	ld	s8,0(sp)
    8000470c:	6161                	addi	sp,sp,80
    8000470e:	8082                	ret
    ret = (i == n ? n : -1);
    80004710:	5a7d                	li	s4,-1
    80004712:	b7d5                	j	800046f6 <filewrite+0xe2>
    panic("filewrite");
    80004714:	00003517          	auipc	a0,0x3
    80004718:	f9c50513          	addi	a0,a0,-100 # 800076b0 <syscalls+0x2b8>
    8000471c:	86cfc0ef          	jal	ra,80000788 <panic>
    return -1;
    80004720:	5a7d                	li	s4,-1
    80004722:	bfd1                	j	800046f6 <filewrite+0xe2>
      return -1;
    80004724:	5a7d                	li	s4,-1
    80004726:	bfc1                	j	800046f6 <filewrite+0xe2>
    80004728:	5a7d                	li	s4,-1
    8000472a:	b7f1                	j	800046f6 <filewrite+0xe2>

000000008000472c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000472c:	7179                	addi	sp,sp,-48
    8000472e:	f406                	sd	ra,40(sp)
    80004730:	f022                	sd	s0,32(sp)
    80004732:	ec26                	sd	s1,24(sp)
    80004734:	e84a                	sd	s2,16(sp)
    80004736:	e44e                	sd	s3,8(sp)
    80004738:	e052                	sd	s4,0(sp)
    8000473a:	1800                	addi	s0,sp,48
    8000473c:	84aa                	mv	s1,a0
    8000473e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004740:	0005b023          	sd	zero,0(a1)
    80004744:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004748:	c75ff0ef          	jal	ra,800043bc <filealloc>
    8000474c:	e088                	sd	a0,0(s1)
    8000474e:	cd35                	beqz	a0,800047ca <pipealloc+0x9e>
    80004750:	c6dff0ef          	jal	ra,800043bc <filealloc>
    80004754:	00aa3023          	sd	a0,0(s4)
    80004758:	c52d                	beqz	a0,800047c2 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000475a:	c50fc0ef          	jal	ra,80000baa <kalloc>
    8000475e:	892a                	mv	s2,a0
    80004760:	cd31                	beqz	a0,800047bc <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004762:	4985                	li	s3,1
    80004764:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004768:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000476c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004770:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004774:	00003597          	auipc	a1,0x3
    80004778:	f4c58593          	addi	a1,a1,-180 # 800076c0 <syscalls+0x2c8>
    8000477c:	ca4fc0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004780:	609c                	ld	a5,0(s1)
    80004782:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004786:	609c                	ld	a5,0(s1)
    80004788:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000478c:	609c                	ld	a5,0(s1)
    8000478e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004792:	609c                	ld	a5,0(s1)
    80004794:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004798:	000a3783          	ld	a5,0(s4)
    8000479c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800047a0:	000a3783          	ld	a5,0(s4)
    800047a4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800047a8:	000a3783          	ld	a5,0(s4)
    800047ac:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800047b0:	000a3783          	ld	a5,0(s4)
    800047b4:	0127b823          	sd	s2,16(a5)
  return 0;
    800047b8:	4501                	li	a0,0
    800047ba:	a005                	j	800047da <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800047bc:	6088                	ld	a0,0(s1)
    800047be:	e501                	bnez	a0,800047c6 <pipealloc+0x9a>
    800047c0:	a029                	j	800047ca <pipealloc+0x9e>
    800047c2:	6088                	ld	a0,0(s1)
    800047c4:	c11d                	beqz	a0,800047ea <pipealloc+0xbe>
    fileclose(*f0);
    800047c6:	c9bff0ef          	jal	ra,80004460 <fileclose>
  if(*f1)
    800047ca:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800047ce:	557d                	li	a0,-1
  if(*f1)
    800047d0:	c789                	beqz	a5,800047da <pipealloc+0xae>
    fileclose(*f1);
    800047d2:	853e                	mv	a0,a5
    800047d4:	c8dff0ef          	jal	ra,80004460 <fileclose>
  return -1;
    800047d8:	557d                	li	a0,-1
}
    800047da:	70a2                	ld	ra,40(sp)
    800047dc:	7402                	ld	s0,32(sp)
    800047de:	64e2                	ld	s1,24(sp)
    800047e0:	6942                	ld	s2,16(sp)
    800047e2:	69a2                	ld	s3,8(sp)
    800047e4:	6a02                	ld	s4,0(sp)
    800047e6:	6145                	addi	sp,sp,48
    800047e8:	8082                	ret
  return -1;
    800047ea:	557d                	li	a0,-1
    800047ec:	b7fd                	j	800047da <pipealloc+0xae>

00000000800047ee <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800047ee:	1101                	addi	sp,sp,-32
    800047f0:	ec06                	sd	ra,24(sp)
    800047f2:	e822                	sd	s0,16(sp)
    800047f4:	e426                	sd	s1,8(sp)
    800047f6:	e04a                	sd	s2,0(sp)
    800047f8:	1000                	addi	s0,sp,32
    800047fa:	84aa                	mv	s1,a0
    800047fc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047fe:	ca2fc0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    80004802:	02090763          	beqz	s2,80004830 <pipeclose+0x42>
    pi->writeopen = 0;
    80004806:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000480a:	21848513          	addi	a0,s1,536
    8000480e:	97ffd0ef          	jal	ra,8000218c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004812:	2204b783          	ld	a5,544(s1)
    80004816:	e785                	bnez	a5,8000483e <pipeclose+0x50>
    release(&pi->lock);
    80004818:	8526                	mv	a0,s1
    8000481a:	d1efc0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    8000481e:	8526                	mv	a0,s1
    80004820:	a5afc0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004824:	60e2                	ld	ra,24(sp)
    80004826:	6442                	ld	s0,16(sp)
    80004828:	64a2                	ld	s1,8(sp)
    8000482a:	6902                	ld	s2,0(sp)
    8000482c:	6105                	addi	sp,sp,32
    8000482e:	8082                	ret
    pi->readopen = 0;
    80004830:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004834:	21c48513          	addi	a0,s1,540
    80004838:	955fd0ef          	jal	ra,8000218c <wakeup>
    8000483c:	bfd9                	j	80004812 <pipeclose+0x24>
    release(&pi->lock);
    8000483e:	8526                	mv	a0,s1
    80004840:	cf8fc0ef          	jal	ra,80000d38 <release>
}
    80004844:	b7c5                	j	80004824 <pipeclose+0x36>

0000000080004846 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004846:	711d                	addi	sp,sp,-96
    80004848:	ec86                	sd	ra,88(sp)
    8000484a:	e8a2                	sd	s0,80(sp)
    8000484c:	e4a6                	sd	s1,72(sp)
    8000484e:	e0ca                	sd	s2,64(sp)
    80004850:	fc4e                	sd	s3,56(sp)
    80004852:	f852                	sd	s4,48(sp)
    80004854:	f456                	sd	s5,40(sp)
    80004856:	f05a                	sd	s6,32(sp)
    80004858:	ec5e                	sd	s7,24(sp)
    8000485a:	e862                	sd	s8,16(sp)
    8000485c:	1080                	addi	s0,sp,96
    8000485e:	84aa                	mv	s1,a0
    80004860:	8aae                	mv	s5,a1
    80004862:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004864:	a6efd0ef          	jal	ra,80001ad2 <myproc>
    80004868:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000486a:	8526                	mv	a0,s1
    8000486c:	c34fc0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004870:	09405c63          	blez	s4,80004908 <pipewrite+0xc2>
  int i = 0;
    80004874:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004876:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004878:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000487c:	21c48b93          	addi	s7,s1,540
    80004880:	a81d                	j	800048b6 <pipewrite+0x70>
      release(&pi->lock);
    80004882:	8526                	mv	a0,s1
    80004884:	cb4fc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004888:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000488a:	854a                	mv	a0,s2
    8000488c:	60e6                	ld	ra,88(sp)
    8000488e:	6446                	ld	s0,80(sp)
    80004890:	64a6                	ld	s1,72(sp)
    80004892:	6906                	ld	s2,64(sp)
    80004894:	79e2                	ld	s3,56(sp)
    80004896:	7a42                	ld	s4,48(sp)
    80004898:	7aa2                	ld	s5,40(sp)
    8000489a:	7b02                	ld	s6,32(sp)
    8000489c:	6be2                	ld	s7,24(sp)
    8000489e:	6c42                	ld	s8,16(sp)
    800048a0:	6125                	addi	sp,sp,96
    800048a2:	8082                	ret
      wakeup(&pi->nread);
    800048a4:	8562                	mv	a0,s8
    800048a6:	8e7fd0ef          	jal	ra,8000218c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800048aa:	85a6                	mv	a1,s1
    800048ac:	855e                	mv	a0,s7
    800048ae:	893fd0ef          	jal	ra,80002140 <sleep>
  while(i < n){
    800048b2:	05495c63          	bge	s2,s4,8000490a <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800048b6:	2204a783          	lw	a5,544(s1)
    800048ba:	d7e1                	beqz	a5,80004882 <pipewrite+0x3c>
    800048bc:	854e                	mv	a0,s3
    800048be:	abbfd0ef          	jal	ra,80002378 <killed>
    800048c2:	f161                	bnez	a0,80004882 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800048c4:	2184a783          	lw	a5,536(s1)
    800048c8:	21c4a703          	lw	a4,540(s1)
    800048cc:	2007879b          	addiw	a5,a5,512
    800048d0:	fcf70ae3          	beq	a4,a5,800048a4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048d4:	4685                	li	a3,1
    800048d6:	01590633          	add	a2,s2,s5
    800048da:	faf40593          	addi	a1,s0,-81
    800048de:	0509b503          	ld	a0,80(s3)
    800048e2:	f67fc0ef          	jal	ra,80001848 <copyin>
    800048e6:	03650263          	beq	a0,s6,8000490a <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800048ea:	21c4a783          	lw	a5,540(s1)
    800048ee:	0017871b          	addiw	a4,a5,1
    800048f2:	20e4ae23          	sw	a4,540(s1)
    800048f6:	1ff7f793          	andi	a5,a5,511
    800048fa:	97a6                	add	a5,a5,s1
    800048fc:	faf44703          	lbu	a4,-81(s0)
    80004900:	00e78c23          	sb	a4,24(a5)
      i++;
    80004904:	2905                	addiw	s2,s2,1
    80004906:	b775                	j	800048b2 <pipewrite+0x6c>
  int i = 0;
    80004908:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000490a:	21848513          	addi	a0,s1,536
    8000490e:	87ffd0ef          	jal	ra,8000218c <wakeup>
  release(&pi->lock);
    80004912:	8526                	mv	a0,s1
    80004914:	c24fc0ef          	jal	ra,80000d38 <release>
  return i;
    80004918:	bf8d                	j	8000488a <pipewrite+0x44>

000000008000491a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000491a:	715d                	addi	sp,sp,-80
    8000491c:	e486                	sd	ra,72(sp)
    8000491e:	e0a2                	sd	s0,64(sp)
    80004920:	fc26                	sd	s1,56(sp)
    80004922:	f84a                	sd	s2,48(sp)
    80004924:	f44e                	sd	s3,40(sp)
    80004926:	f052                	sd	s4,32(sp)
    80004928:	ec56                	sd	s5,24(sp)
    8000492a:	e85a                	sd	s6,16(sp)
    8000492c:	0880                	addi	s0,sp,80
    8000492e:	84aa                	mv	s1,a0
    80004930:	892e                	mv	s2,a1
    80004932:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004934:	99efd0ef          	jal	ra,80001ad2 <myproc>
    80004938:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000493a:	8526                	mv	a0,s1
    8000493c:	b64fc0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004940:	2184a703          	lw	a4,536(s1)
    80004944:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004948:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000494c:	02f71363          	bne	a4,a5,80004972 <piperead+0x58>
    80004950:	2244a783          	lw	a5,548(s1)
    80004954:	cf99                	beqz	a5,80004972 <piperead+0x58>
    if(killed(pr)){
    80004956:	8552                	mv	a0,s4
    80004958:	a21fd0ef          	jal	ra,80002378 <killed>
    8000495c:	e151                	bnez	a0,800049e0 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000495e:	85a6                	mv	a1,s1
    80004960:	854e                	mv	a0,s3
    80004962:	fdefd0ef          	jal	ra,80002140 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004966:	2184a703          	lw	a4,536(s1)
    8000496a:	21c4a783          	lw	a5,540(s1)
    8000496e:	fef701e3          	beq	a4,a5,80004950 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004972:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004974:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004976:	05505363          	blez	s5,800049bc <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    8000497a:	2184a783          	lw	a5,536(s1)
    8000497e:	21c4a703          	lw	a4,540(s1)
    80004982:	02f70d63          	beq	a4,a5,800049bc <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004986:	1ff7f793          	andi	a5,a5,511
    8000498a:	97a6                	add	a5,a5,s1
    8000498c:	0187c783          	lbu	a5,24(a5)
    80004990:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004994:	4685                	li	a3,1
    80004996:	fbf40613          	addi	a2,s0,-65
    8000499a:	85ca                	mv	a1,s2
    8000499c:	050a3503          	ld	a0,80(s4)
    800049a0:	dbffc0ef          	jal	ra,8000175e <copyout>
    800049a4:	05650363          	beq	a0,s6,800049ea <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800049a8:	2184a783          	lw	a5,536(s1)
    800049ac:	2785                	addiw	a5,a5,1
    800049ae:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049b2:	2985                	addiw	s3,s3,1
    800049b4:	0905                	addi	s2,s2,1
    800049b6:	fd3a92e3          	bne	s5,s3,8000497a <piperead+0x60>
    800049ba:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800049bc:	21c48513          	addi	a0,s1,540
    800049c0:	fccfd0ef          	jal	ra,8000218c <wakeup>
  release(&pi->lock);
    800049c4:	8526                	mv	a0,s1
    800049c6:	b72fc0ef          	jal	ra,80000d38 <release>
  return i;
}
    800049ca:	854e                	mv	a0,s3
    800049cc:	60a6                	ld	ra,72(sp)
    800049ce:	6406                	ld	s0,64(sp)
    800049d0:	74e2                	ld	s1,56(sp)
    800049d2:	7942                	ld	s2,48(sp)
    800049d4:	79a2                	ld	s3,40(sp)
    800049d6:	7a02                	ld	s4,32(sp)
    800049d8:	6ae2                	ld	s5,24(sp)
    800049da:	6b42                	ld	s6,16(sp)
    800049dc:	6161                	addi	sp,sp,80
    800049de:	8082                	ret
      release(&pi->lock);
    800049e0:	8526                	mv	a0,s1
    800049e2:	b56fc0ef          	jal	ra,80000d38 <release>
      return -1;
    800049e6:	59fd                	li	s3,-1
    800049e8:	b7cd                	j	800049ca <piperead+0xb0>
      if(i == 0)
    800049ea:	fc0999e3          	bnez	s3,800049bc <piperead+0xa2>
        i = -1;
    800049ee:	89aa                	mv	s3,a0
    800049f0:	b7f1                	j	800049bc <piperead+0xa2>

00000000800049f2 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800049f2:	1141                	addi	sp,sp,-16
    800049f4:	e422                	sd	s0,8(sp)
    800049f6:	0800                	addi	s0,sp,16
    800049f8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800049fa:	8905                	andi	a0,a0,1
    800049fc:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800049fe:	8b89                	andi	a5,a5,2
    80004a00:	c399                	beqz	a5,80004a06 <flags2perm+0x14>
      perm |= PTE_W;
    80004a02:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a06:	6422                	ld	s0,8(sp)
    80004a08:	0141                	addi	sp,sp,16
    80004a0a:	8082                	ret

0000000080004a0c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004a0c:	bd010113          	addi	sp,sp,-1072
    80004a10:	42113423          	sd	ra,1064(sp)
    80004a14:	42813023          	sd	s0,1056(sp)
    80004a18:	40913c23          	sd	s1,1048(sp)
    80004a1c:	41213823          	sd	s2,1040(sp)
    80004a20:	41313423          	sd	s3,1032(sp)
    80004a24:	41413023          	sd	s4,1024(sp)
    80004a28:	3f513c23          	sd	s5,1016(sp)
    80004a2c:	3f613823          	sd	s6,1008(sp)
    80004a30:	3f713423          	sd	s7,1000(sp)
    80004a34:	3f813023          	sd	s8,992(sp)
    80004a38:	3d913c23          	sd	s9,984(sp)
    80004a3c:	3da13823          	sd	s10,976(sp)
    80004a40:	3db13423          	sd	s11,968(sp)
    80004a44:	43010413          	addi	s0,sp,1072
    80004a48:	84aa                	mv	s1,a0
    80004a4a:	bea43023          	sd	a0,-1056(s0)
    80004a4e:	beb43423          	sd	a1,-1048(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a52:	880fd0ef          	jal	ra,80001ad2 <myproc>
    80004a56:	bea43c23          	sd	a0,-1032(s0)

  begin_op();
    80004a5a:	dfcff0ef          	jal	ra,80004056 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004a5e:	8526                	mv	a0,s1
    80004a60:	c02ff0ef          	jal	ra,80003e62 <namei>
    80004a64:	cd25                	beqz	a0,80004adc <kexec+0xd0>
    80004a66:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a68:	c07fe0ef          	jal	ra,8000366e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a6c:	04000713          	li	a4,64
    80004a70:	4681                	li	a3,0
    80004a72:	e5040613          	addi	a2,s0,-432
    80004a76:	4581                	li	a1,0
    80004a78:	8556                	mv	a0,s5
    80004a7a:	f81fe0ef          	jal	ra,800039fa <readi>
    80004a7e:	04000793          	li	a5,64
    80004a82:	00f51a63          	bne	a0,a5,80004a96 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004a86:	e5042703          	lw	a4,-432(s0)
    80004a8a:	464c47b7          	lui	a5,0x464c4
    80004a8e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a92:	04f70963          	beq	a4,a5,80004ae4 <kexec+0xd8>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    memset(p->vmas, 0, sizeof(p->vmas));
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80004a96:	8556                	mv	a0,s5
    80004a98:	dddfe0ef          	jal	ra,80003874 <iunlockput>
    end_op();
    80004a9c:	e28ff0ef          	jal	ra,800040c4 <end_op>
  }
  return -1;
    80004aa0:	557d                	li	a0,-1
}
    80004aa2:	42813083          	ld	ra,1064(sp)
    80004aa6:	42013403          	ld	s0,1056(sp)
    80004aaa:	41813483          	ld	s1,1048(sp)
    80004aae:	41013903          	ld	s2,1040(sp)
    80004ab2:	40813983          	ld	s3,1032(sp)
    80004ab6:	40013a03          	ld	s4,1024(sp)
    80004aba:	3f813a83          	ld	s5,1016(sp)
    80004abe:	3f013b03          	ld	s6,1008(sp)
    80004ac2:	3e813b83          	ld	s7,1000(sp)
    80004ac6:	3e013c03          	ld	s8,992(sp)
    80004aca:	3d813c83          	ld	s9,984(sp)
    80004ace:	3d013d03          	ld	s10,976(sp)
    80004ad2:	3c813d83          	ld	s11,968(sp)
    80004ad6:	43010113          	addi	sp,sp,1072
    80004ada:	8082                	ret
    end_op();
    80004adc:	de8ff0ef          	jal	ra,800040c4 <end_op>
    return -1;
    80004ae0:	557d                	li	a0,-1
    80004ae2:	b7c1                	j	80004aa2 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ae4:	bf843503          	ld	a0,-1032(s0)
    80004ae8:	8f0fd0ef          	jal	ra,80001bd8 <proc_pagetable>
    80004aec:	8baa                	mv	s7,a0
    80004aee:	d545                	beqz	a0,80004a96 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004af0:	e7042783          	lw	a5,-400(s0)
    80004af4:	e8845703          	lhu	a4,-376(s0)
    80004af8:	0e070d63          	beqz	a4,80004bf2 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004afc:	be043823          	sd	zero,-1040(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b00:	c0043423          	sd	zero,-1016(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004b04:	6a05                	lui	s4,0x1
    80004b06:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004b0a:	bce43c23          	sd	a4,-1064(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004b0e:	6d85                	lui	s11,0x1
    80004b10:	7d7d                	lui	s10,0xfffff
    80004b12:	a09d                	j	80004b78 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004b14:	00003517          	auipc	a0,0x3
    80004b18:	bb450513          	addi	a0,a0,-1100 # 800076c8 <syscalls+0x2d0>
    80004b1c:	c6dfb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004b20:	874a                	mv	a4,s2
    80004b22:	009c86bb          	addw	a3,s9,s1
    80004b26:	4581                	li	a1,0
    80004b28:	8556                	mv	a0,s5
    80004b2a:	ed1fe0ef          	jal	ra,800039fa <readi>
    80004b2e:	2501                	sext.w	a0,a0
    80004b30:	0ea91f63          	bne	s2,a0,80004c2e <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    80004b34:	009d84bb          	addw	s1,s11,s1
    80004b38:	013d09bb          	addw	s3,s10,s3
    80004b3c:	0364f063          	bgeu	s1,s6,80004b5c <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004b40:	02049593          	slli	a1,s1,0x20
    80004b44:	9181                	srli	a1,a1,0x20
    80004b46:	95e2                	add	a1,a1,s8
    80004b48:	855e                	mv	a0,s7
    80004b4a:	d40fc0ef          	jal	ra,8000108a <walkaddr>
    80004b4e:	862a                	mv	a2,a0
    if(pa == 0)
    80004b50:	d171                	beqz	a0,80004b14 <kexec+0x108>
      n = PGSIZE;
    80004b52:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004b54:	fd49f6e3          	bgeu	s3,s4,80004b20 <kexec+0x114>
      n = sz - i;
    80004b58:	894e                	mv	s2,s3
    80004b5a:	b7d9                	j	80004b20 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b5c:	c0843783          	ld	a5,-1016(s0)
    80004b60:	0017869b          	addiw	a3,a5,1
    80004b64:	c0d43423          	sd	a3,-1016(s0)
    80004b68:	c0043783          	ld	a5,-1024(s0)
    80004b6c:	0387879b          	addiw	a5,a5,56
    80004b70:	e8845703          	lhu	a4,-376(s0)
    80004b74:	08e6d163          	bge	a3,a4,80004bf6 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b78:	2781                	sext.w	a5,a5
    80004b7a:	c0f43023          	sd	a5,-1024(s0)
    80004b7e:	03800713          	li	a4,56
    80004b82:	86be                	mv	a3,a5
    80004b84:	e1840613          	addi	a2,s0,-488
    80004b88:	4581                	li	a1,0
    80004b8a:	8556                	mv	a0,s5
    80004b8c:	e6ffe0ef          	jal	ra,800039fa <readi>
    80004b90:	03800793          	li	a5,56
    80004b94:	08f51d63          	bne	a0,a5,80004c2e <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80004b98:	e1842783          	lw	a5,-488(s0)
    80004b9c:	4705                	li	a4,1
    80004b9e:	fae79fe3          	bne	a5,a4,80004b5c <kexec+0x150>
    if(ph.memsz < ph.filesz)
    80004ba2:	e4043483          	ld	s1,-448(s0)
    80004ba6:	e3843783          	ld	a5,-456(s0)
    80004baa:	08f4e263          	bltu	s1,a5,80004c2e <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004bae:	e2843783          	ld	a5,-472(s0)
    80004bb2:	94be                	add	s1,s1,a5
    80004bb4:	06f4ed63          	bltu	s1,a5,80004c2e <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80004bb8:	bd843703          	ld	a4,-1064(s0)
    80004bbc:	8ff9                	and	a5,a5,a4
    80004bbe:	eba5                	bnez	a5,80004c2e <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004bc0:	e1c42503          	lw	a0,-484(s0)
    80004bc4:	e2fff0ef          	jal	ra,800049f2 <flags2perm>
    80004bc8:	86aa                	mv	a3,a0
    80004bca:	8626                	mv	a2,s1
    80004bcc:	bf043583          	ld	a1,-1040(s0)
    80004bd0:	855e                	mv	a0,s7
    80004bd2:	f82fc0ef          	jal	ra,80001354 <uvmalloc>
    80004bd6:	bea43823          	sd	a0,-1040(s0)
    80004bda:	c931                	beqz	a0,80004c2e <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004bdc:	e2843c03          	ld	s8,-472(s0)
    80004be0:	e2042c83          	lw	s9,-480(s0)
    80004be4:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004be8:	f60b0ae3          	beqz	s6,80004b5c <kexec+0x150>
    80004bec:	89da                	mv	s3,s6
    80004bee:	4481                	li	s1,0
    80004bf0:	bf81                	j	80004b40 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bf2:	be043823          	sd	zero,-1040(s0)
  iunlockput(ip);
    80004bf6:	8556                	mv	a0,s5
    80004bf8:	c7dfe0ef          	jal	ra,80003874 <iunlockput>
  end_op();
    80004bfc:	cc8ff0ef          	jal	ra,800040c4 <end_op>
  p = myproc();
    80004c00:	ed3fc0ef          	jal	ra,80001ad2 <myproc>
    80004c04:	bea43c23          	sd	a0,-1032(s0)
  uint64 oldsz = p->sz;
    80004c08:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004c0c:	6785                	lui	a5,0x1
    80004c0e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004c10:	bf043703          	ld	a4,-1040(s0)
    80004c14:	00f705b3          	add	a1,a4,a5
    80004c18:	77fd                	lui	a5,0xfffff
    80004c1a:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004c1c:	4691                	li	a3,4
    80004c1e:	6609                	lui	a2,0x2
    80004c20:	962e                	add	a2,a2,a1
    80004c22:	855e                	mv	a0,s7
    80004c24:	f30fc0ef          	jal	ra,80001354 <uvmalloc>
    80004c28:	8b2a                	mv	s6,a0
  ip = 0;
    80004c2a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004c2c:	e915                	bnez	a0,80004c60 <kexec+0x254>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80004c2e:	bf843903          	ld	s2,-1032(s0)
    80004c32:	16890493          	addi	s1,s2,360
    80004c36:	85a6                	mv	a1,s1
    80004c38:	05093503          	ld	a0,80(s2)
    80004c3c:	820fd0ef          	jal	ra,80001c5c <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80004c40:	20000613          	li	a2,512
    80004c44:	4581                	li	a1,0
    80004c46:	8526                	mv	a0,s1
    80004c48:	92cfc0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80004c4c:	04893583          	ld	a1,72(s2)
    80004c50:	05093503          	ld	a0,80(s2)
    80004c54:	852fd0ef          	jal	ra,80001ca6 <proc_freepagetable>
  if(ip){
    80004c58:	e20a9fe3          	bnez	s5,80004a96 <kexec+0x8a>
  return -1;
    80004c5c:	557d                	li	a0,-1
    80004c5e:	b591                	j	80004aa2 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004c60:	75f9                	lui	a1,0xffffe
    80004c62:	95aa                	add	a1,a1,a0
    80004c64:	855e                	mv	a0,s7
    80004c66:	991fc0ef          	jal	ra,800015f6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004c6a:	7c7d                	lui	s8,0xfffff
    80004c6c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004c6e:	be843783          	ld	a5,-1048(s0)
    80004c72:	6388                	ld	a0,0(a5)
    80004c74:	c125                	beqz	a0,80004cd4 <kexec+0x2c8>
    80004c76:	e9040993          	addi	s3,s0,-368
    80004c7a:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    80004c7e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004c80:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004c82:	a6afc0ef          	jal	ra,80000eec <strlen>
    80004c86:	0015079b          	addiw	a5,a0,1
    80004c8a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c8e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004c92:	11896563          	bltu	s2,s8,80004d9c <kexec+0x390>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c96:	be843d03          	ld	s10,-1048(s0)
    80004c9a:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdb6440>
    80004c9e:	8552                	mv	a0,s4
    80004ca0:	a4cfc0ef          	jal	ra,80000eec <strlen>
    80004ca4:	0015069b          	addiw	a3,a0,1
    80004ca8:	8652                	mv	a2,s4
    80004caa:	85ca                	mv	a1,s2
    80004cac:	855e                	mv	a0,s7
    80004cae:	ab1fc0ef          	jal	ra,8000175e <copyout>
    80004cb2:	0e054763          	bltz	a0,80004da0 <kexec+0x394>
    ustack[argc] = sp;
    80004cb6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004cba:	0485                	addi	s1,s1,1
    80004cbc:	008d0793          	addi	a5,s10,8
    80004cc0:	bef43423          	sd	a5,-1048(s0)
    80004cc4:	008d3503          	ld	a0,8(s10)
    80004cc8:	c901                	beqz	a0,80004cd8 <kexec+0x2cc>
    if(argc >= MAXARG)
    80004cca:	09a1                	addi	s3,s3,8
    80004ccc:	fb599be3          	bne	s3,s5,80004c82 <kexec+0x276>
  ip = 0;
    80004cd0:	4a81                	li	s5,0
    80004cd2:	bfb1                	j	80004c2e <kexec+0x222>
  sp = sz;
    80004cd4:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004cd6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004cd8:	00349793          	slli	a5,s1,0x3
    80004cdc:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdb63d0>
    80004ce0:	97a2                	add	a5,a5,s0
    80004ce2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ce6:	00148693          	addi	a3,s1,1
    80004cea:	068e                	slli	a3,a3,0x3
    80004cec:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004cf0:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80004cf4:	4a81                	li	s5,0
  if(sp < stackbase)
    80004cf6:	f3896ce3          	bltu	s2,s8,80004c2e <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004cfa:	e9040613          	addi	a2,s0,-368
    80004cfe:	85ca                	mv	a1,s2
    80004d00:	855e                	mv	a0,s7
    80004d02:	a5dfc0ef          	jal	ra,8000175e <copyout>
    80004d06:	08054f63          	bltz	a0,80004da4 <kexec+0x398>
  p->trapframe->a1 = sp;
    80004d0a:	bf843783          	ld	a5,-1032(s0)
    80004d0e:	6fbc                	ld	a5,88(a5)
    80004d10:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004d14:	be043783          	ld	a5,-1056(s0)
    80004d18:	0007c703          	lbu	a4,0(a5)
    80004d1c:	cf11                	beqz	a4,80004d38 <kexec+0x32c>
    80004d1e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d20:	02f00693          	li	a3,47
    80004d24:	a039                	j	80004d32 <kexec+0x326>
      last = s+1;
    80004d26:	bef43023          	sd	a5,-1056(s0)
  for(last=s=path; *s; s++)
    80004d2a:	0785                	addi	a5,a5,1
    80004d2c:	fff7c703          	lbu	a4,-1(a5)
    80004d30:	c701                	beqz	a4,80004d38 <kexec+0x32c>
    if(*s == '/')
    80004d32:	fed71ce3          	bne	a4,a3,80004d2a <kexec+0x31e>
    80004d36:	bfc5                	j	80004d26 <kexec+0x31a>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d38:	4641                	li	a2,16
    80004d3a:	be043583          	ld	a1,-1056(s0)
    80004d3e:	bf843983          	ld	s3,-1032(s0)
    80004d42:	15898513          	addi	a0,s3,344
    80004d46:	974fc0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    80004d4a:	16898a13          	addi	s4,s3,360
    80004d4e:	20000613          	li	a2,512
    80004d52:	85d2                	mv	a1,s4
    80004d54:	c1840513          	addi	a0,s0,-1000
    80004d58:	878fc0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    80004d5c:	86ce                	mv	a3,s3
    80004d5e:	0509b983          	ld	s3,80(s3)
  p->pagetable = pagetable;
    80004d62:	0576b823          	sd	s7,80(a3)
  p->sz = sz;
    80004d66:	0566b423          	sd	s6,72(a3)
  p->trapframe->epc = elf.entry;
    80004d6a:	6ebc                	ld	a5,88(a3)
    80004d6c:	e6843703          	ld	a4,-408(s0)
    80004d70:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    80004d72:	6ebc                	ld	a5,88(a3)
    80004d74:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    80004d78:	20000613          	li	a2,512
    80004d7c:	4581                	li	a1,0
    80004d7e:	8552                	mv	a0,s4
    80004d80:	ff5fb0ef          	jal	ra,80000d74 <memset>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    80004d84:	c1840593          	addi	a1,s0,-1000
    80004d88:	854e                	mv	a0,s3
    80004d8a:	ed3fc0ef          	jal	ra,80001c5c <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    80004d8e:	85e6                	mv	a1,s9
    80004d90:	854e                	mv	a0,s3
    80004d92:	f15fc0ef          	jal	ra,80001ca6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d96:	0004851b          	sext.w	a0,s1
    80004d9a:	b321                	j	80004aa2 <kexec+0x96>
  ip = 0;
    80004d9c:	4a81                	li	s5,0
    80004d9e:	bd41                	j	80004c2e <kexec+0x222>
    80004da0:	4a81                	li	s5,0
    80004da2:	b571                	j	80004c2e <kexec+0x222>
    80004da4:	4a81                	li	s5,0
    80004da6:	b561                	j	80004c2e <kexec+0x222>

0000000080004da8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004da8:	7179                	addi	sp,sp,-48
    80004daa:	f406                	sd	ra,40(sp)
    80004dac:	f022                	sd	s0,32(sp)
    80004dae:	ec26                	sd	s1,24(sp)
    80004db0:	e84a                	sd	s2,16(sp)
    80004db2:	1800                	addi	s0,sp,48
    80004db4:	892e                	mv	s2,a1
    80004db6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004db8:	fdc40593          	addi	a1,s0,-36
    80004dbc:	cbdfd0ef          	jal	ra,80002a78 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004dc0:	fdc42703          	lw	a4,-36(s0)
    80004dc4:	47bd                	li	a5,15
    80004dc6:	02e7e963          	bltu	a5,a4,80004df8 <argfd+0x50>
    80004dca:	d09fc0ef          	jal	ra,80001ad2 <myproc>
    80004dce:	fdc42703          	lw	a4,-36(s0)
    80004dd2:	01a70793          	addi	a5,a4,26
    80004dd6:	078e                	slli	a5,a5,0x3
    80004dd8:	953e                	add	a0,a0,a5
    80004dda:	611c                	ld	a5,0(a0)
    80004ddc:	c385                	beqz	a5,80004dfc <argfd+0x54>
    return -1;
  if(pfd)
    80004dde:	00090463          	beqz	s2,80004de6 <argfd+0x3e>
    *pfd = fd;
    80004de2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004de6:	4501                	li	a0,0
  if(pf)
    80004de8:	c091                	beqz	s1,80004dec <argfd+0x44>
    *pf = f;
    80004dea:	e09c                	sd	a5,0(s1)
}
    80004dec:	70a2                	ld	ra,40(sp)
    80004dee:	7402                	ld	s0,32(sp)
    80004df0:	64e2                	ld	s1,24(sp)
    80004df2:	6942                	ld	s2,16(sp)
    80004df4:	6145                	addi	sp,sp,48
    80004df6:	8082                	ret
    return -1;
    80004df8:	557d                	li	a0,-1
    80004dfa:	bfcd                	j	80004dec <argfd+0x44>
    80004dfc:	557d                	li	a0,-1
    80004dfe:	b7fd                	j	80004dec <argfd+0x44>

0000000080004e00 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004e00:	1101                	addi	sp,sp,-32
    80004e02:	ec06                	sd	ra,24(sp)
    80004e04:	e822                	sd	s0,16(sp)
    80004e06:	e426                	sd	s1,8(sp)
    80004e08:	1000                	addi	s0,sp,32
    80004e0a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004e0c:	cc7fc0ef          	jal	ra,80001ad2 <myproc>
    80004e10:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004e12:	0d050793          	addi	a5,a0,208
    80004e16:	4501                	li	a0,0
    80004e18:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004e1a:	6398                	ld	a4,0(a5)
    80004e1c:	cb19                	beqz	a4,80004e32 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004e1e:	2505                	addiw	a0,a0,1
    80004e20:	07a1                	addi	a5,a5,8
    80004e22:	fed51ce3          	bne	a0,a3,80004e1a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e26:	557d                	li	a0,-1
}
    80004e28:	60e2                	ld	ra,24(sp)
    80004e2a:	6442                	ld	s0,16(sp)
    80004e2c:	64a2                	ld	s1,8(sp)
    80004e2e:	6105                	addi	sp,sp,32
    80004e30:	8082                	ret
      p->ofile[fd] = f;
    80004e32:	01a50793          	addi	a5,a0,26
    80004e36:	078e                	slli	a5,a5,0x3
    80004e38:	963e                	add	a2,a2,a5
    80004e3a:	e204                	sd	s1,0(a2)
      return fd;
    80004e3c:	b7f5                	j	80004e28 <fdalloc+0x28>

0000000080004e3e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004e3e:	715d                	addi	sp,sp,-80
    80004e40:	e486                	sd	ra,72(sp)
    80004e42:	e0a2                	sd	s0,64(sp)
    80004e44:	fc26                	sd	s1,56(sp)
    80004e46:	f84a                	sd	s2,48(sp)
    80004e48:	f44e                	sd	s3,40(sp)
    80004e4a:	f052                	sd	s4,32(sp)
    80004e4c:	ec56                	sd	s5,24(sp)
    80004e4e:	e85a                	sd	s6,16(sp)
    80004e50:	0880                	addi	s0,sp,80
    80004e52:	8b2e                	mv	s6,a1
    80004e54:	89b2                	mv	s3,a2
    80004e56:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e58:	fb040593          	addi	a1,s0,-80
    80004e5c:	820ff0ef          	jal	ra,80003e7c <nameiparent>
    80004e60:	84aa                	mv	s1,a0
    80004e62:	10050b63          	beqz	a0,80004f78 <create+0x13a>
    return 0;

  ilock(dp);
    80004e66:	809fe0ef          	jal	ra,8000366e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e6a:	4601                	li	a2,0
    80004e6c:	fb040593          	addi	a1,s0,-80
    80004e70:	8526                	mv	a0,s1
    80004e72:	d85fe0ef          	jal	ra,80003bf6 <dirlookup>
    80004e76:	8aaa                	mv	s5,a0
    80004e78:	c521                	beqz	a0,80004ec0 <create+0x82>
    iunlockput(dp);
    80004e7a:	8526                	mv	a0,s1
    80004e7c:	9f9fe0ef          	jal	ra,80003874 <iunlockput>
    ilock(ip);
    80004e80:	8556                	mv	a0,s5
    80004e82:	fecfe0ef          	jal	ra,8000366e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e86:	000b059b          	sext.w	a1,s6
    80004e8a:	4789                	li	a5,2
    80004e8c:	02f59563          	bne	a1,a5,80004eb6 <create+0x78>
    80004e90:	044ad783          	lhu	a5,68(s5)
    80004e94:	37f9                	addiw	a5,a5,-2
    80004e96:	17c2                	slli	a5,a5,0x30
    80004e98:	93c1                	srli	a5,a5,0x30
    80004e9a:	4705                	li	a4,1
    80004e9c:	00f76d63          	bltu	a4,a5,80004eb6 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ea0:	8556                	mv	a0,s5
    80004ea2:	60a6                	ld	ra,72(sp)
    80004ea4:	6406                	ld	s0,64(sp)
    80004ea6:	74e2                	ld	s1,56(sp)
    80004ea8:	7942                	ld	s2,48(sp)
    80004eaa:	79a2                	ld	s3,40(sp)
    80004eac:	7a02                	ld	s4,32(sp)
    80004eae:	6ae2                	ld	s5,24(sp)
    80004eb0:	6b42                	ld	s6,16(sp)
    80004eb2:	6161                	addi	sp,sp,80
    80004eb4:	8082                	ret
    iunlockput(ip);
    80004eb6:	8556                	mv	a0,s5
    80004eb8:	9bdfe0ef          	jal	ra,80003874 <iunlockput>
    return 0;
    80004ebc:	4a81                	li	s5,0
    80004ebe:	b7cd                	j	80004ea0 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004ec0:	85da                	mv	a1,s6
    80004ec2:	4088                	lw	a0,0(s1)
    80004ec4:	e40fe0ef          	jal	ra,80003504 <ialloc>
    80004ec8:	8a2a                	mv	s4,a0
    80004eca:	cd1d                	beqz	a0,80004f08 <create+0xca>
  ilock(ip);
    80004ecc:	fa2fe0ef          	jal	ra,8000366e <ilock>
  ip->major = major;
    80004ed0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ed4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004ed8:	4905                	li	s2,1
    80004eda:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004ede:	8552                	mv	a0,s4
    80004ee0:	edafe0ef          	jal	ra,800035ba <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ee4:	000b059b          	sext.w	a1,s6
    80004ee8:	03258563          	beq	a1,s2,80004f12 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004eec:	004a2603          	lw	a2,4(s4)
    80004ef0:	fb040593          	addi	a1,s0,-80
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	ed3fe0ef          	jal	ra,80003dc8 <dirlink>
    80004efa:	06054363          	bltz	a0,80004f60 <create+0x122>
  iunlockput(dp);
    80004efe:	8526                	mv	a0,s1
    80004f00:	975fe0ef          	jal	ra,80003874 <iunlockput>
  return ip;
    80004f04:	8ad2                	mv	s5,s4
    80004f06:	bf69                	j	80004ea0 <create+0x62>
    iunlockput(dp);
    80004f08:	8526                	mv	a0,s1
    80004f0a:	96bfe0ef          	jal	ra,80003874 <iunlockput>
    return 0;
    80004f0e:	8ad2                	mv	s5,s4
    80004f10:	bf41                	j	80004ea0 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f12:	004a2603          	lw	a2,4(s4)
    80004f16:	00002597          	auipc	a1,0x2
    80004f1a:	7d258593          	addi	a1,a1,2002 # 800076e8 <syscalls+0x2f0>
    80004f1e:	8552                	mv	a0,s4
    80004f20:	ea9fe0ef          	jal	ra,80003dc8 <dirlink>
    80004f24:	02054e63          	bltz	a0,80004f60 <create+0x122>
    80004f28:	40d0                	lw	a2,4(s1)
    80004f2a:	00002597          	auipc	a1,0x2
    80004f2e:	7c658593          	addi	a1,a1,1990 # 800076f0 <syscalls+0x2f8>
    80004f32:	8552                	mv	a0,s4
    80004f34:	e95fe0ef          	jal	ra,80003dc8 <dirlink>
    80004f38:	02054463          	bltz	a0,80004f60 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f3c:	004a2603          	lw	a2,4(s4)
    80004f40:	fb040593          	addi	a1,s0,-80
    80004f44:	8526                	mv	a0,s1
    80004f46:	e83fe0ef          	jal	ra,80003dc8 <dirlink>
    80004f4a:	00054b63          	bltz	a0,80004f60 <create+0x122>
    dp->nlink++;  // for ".."
    80004f4e:	04a4d783          	lhu	a5,74(s1)
    80004f52:	2785                	addiw	a5,a5,1
    80004f54:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f58:	8526                	mv	a0,s1
    80004f5a:	e60fe0ef          	jal	ra,800035ba <iupdate>
    80004f5e:	b745                	j	80004efe <create+0xc0>
  ip->nlink = 0;
    80004f60:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004f64:	8552                	mv	a0,s4
    80004f66:	e54fe0ef          	jal	ra,800035ba <iupdate>
  iunlockput(ip);
    80004f6a:	8552                	mv	a0,s4
    80004f6c:	909fe0ef          	jal	ra,80003874 <iunlockput>
  iunlockput(dp);
    80004f70:	8526                	mv	a0,s1
    80004f72:	903fe0ef          	jal	ra,80003874 <iunlockput>
  return 0;
    80004f76:	b72d                	j	80004ea0 <create+0x62>
    return 0;
    80004f78:	8aaa                	mv	s5,a0
    80004f7a:	b71d                	j	80004ea0 <create+0x62>

0000000080004f7c <sys_dup>:
{
    80004f7c:	7179                	addi	sp,sp,-48
    80004f7e:	f406                	sd	ra,40(sp)
    80004f80:	f022                	sd	s0,32(sp)
    80004f82:	ec26                	sd	s1,24(sp)
    80004f84:	e84a                	sd	s2,16(sp)
    80004f86:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f88:	fd840613          	addi	a2,s0,-40
    80004f8c:	4581                	li	a1,0
    80004f8e:	4501                	li	a0,0
    80004f90:	e19ff0ef          	jal	ra,80004da8 <argfd>
    return -1;
    80004f94:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f96:	00054f63          	bltz	a0,80004fb4 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80004f9a:	fd843903          	ld	s2,-40(s0)
    80004f9e:	854a                	mv	a0,s2
    80004fa0:	e61ff0ef          	jal	ra,80004e00 <fdalloc>
    80004fa4:	84aa                	mv	s1,a0
    return -1;
    80004fa6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004fa8:	00054663          	bltz	a0,80004fb4 <sys_dup+0x38>
  filedup(f);
    80004fac:	854a                	mv	a0,s2
    80004fae:	c6cff0ef          	jal	ra,8000441a <filedup>
  return fd;
    80004fb2:	87a6                	mv	a5,s1
}
    80004fb4:	853e                	mv	a0,a5
    80004fb6:	70a2                	ld	ra,40(sp)
    80004fb8:	7402                	ld	s0,32(sp)
    80004fba:	64e2                	ld	s1,24(sp)
    80004fbc:	6942                	ld	s2,16(sp)
    80004fbe:	6145                	addi	sp,sp,48
    80004fc0:	8082                	ret

0000000080004fc2 <sys_read>:
{
    80004fc2:	7179                	addi	sp,sp,-48
    80004fc4:	f406                	sd	ra,40(sp)
    80004fc6:	f022                	sd	s0,32(sp)
    80004fc8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fca:	fd840593          	addi	a1,s0,-40
    80004fce:	4505                	li	a0,1
    80004fd0:	ac5fd0ef          	jal	ra,80002a94 <argaddr>
  argint(2, &n);
    80004fd4:	fe440593          	addi	a1,s0,-28
    80004fd8:	4509                	li	a0,2
    80004fda:	a9ffd0ef          	jal	ra,80002a78 <argint>
  if(argfd(0, 0, &f) < 0)
    80004fde:	fe840613          	addi	a2,s0,-24
    80004fe2:	4581                	li	a1,0
    80004fe4:	4501                	li	a0,0
    80004fe6:	dc3ff0ef          	jal	ra,80004da8 <argfd>
    80004fea:	87aa                	mv	a5,a0
    return -1;
    80004fec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fee:	0007ca63          	bltz	a5,80005002 <sys_read+0x40>
  return fileread(f, p, n);
    80004ff2:	fe442603          	lw	a2,-28(s0)
    80004ff6:	fd843583          	ld	a1,-40(s0)
    80004ffa:	fe843503          	ld	a0,-24(s0)
    80004ffe:	d68ff0ef          	jal	ra,80004566 <fileread>
}
    80005002:	70a2                	ld	ra,40(sp)
    80005004:	7402                	ld	s0,32(sp)
    80005006:	6145                	addi	sp,sp,48
    80005008:	8082                	ret

000000008000500a <sys_write>:
{
    8000500a:	7179                	addi	sp,sp,-48
    8000500c:	f406                	sd	ra,40(sp)
    8000500e:	f022                	sd	s0,32(sp)
    80005010:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005012:	fd840593          	addi	a1,s0,-40
    80005016:	4505                	li	a0,1
    80005018:	a7dfd0ef          	jal	ra,80002a94 <argaddr>
  argint(2, &n);
    8000501c:	fe440593          	addi	a1,s0,-28
    80005020:	4509                	li	a0,2
    80005022:	a57fd0ef          	jal	ra,80002a78 <argint>
  if(argfd(0, 0, &f) < 0)
    80005026:	fe840613          	addi	a2,s0,-24
    8000502a:	4581                	li	a1,0
    8000502c:	4501                	li	a0,0
    8000502e:	d7bff0ef          	jal	ra,80004da8 <argfd>
    80005032:	87aa                	mv	a5,a0
    return -1;
    80005034:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005036:	0007ca63          	bltz	a5,8000504a <sys_write+0x40>
  return filewrite(f, p, n);
    8000503a:	fe442603          	lw	a2,-28(s0)
    8000503e:	fd843583          	ld	a1,-40(s0)
    80005042:	fe843503          	ld	a0,-24(s0)
    80005046:	dceff0ef          	jal	ra,80004614 <filewrite>
}
    8000504a:	70a2                	ld	ra,40(sp)
    8000504c:	7402                	ld	s0,32(sp)
    8000504e:	6145                	addi	sp,sp,48
    80005050:	8082                	ret

0000000080005052 <sys_close>:
{
    80005052:	1101                	addi	sp,sp,-32
    80005054:	ec06                	sd	ra,24(sp)
    80005056:	e822                	sd	s0,16(sp)
    80005058:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000505a:	fe040613          	addi	a2,s0,-32
    8000505e:	fec40593          	addi	a1,s0,-20
    80005062:	4501                	li	a0,0
    80005064:	d45ff0ef          	jal	ra,80004da8 <argfd>
    return -1;
    80005068:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000506a:	02054063          	bltz	a0,8000508a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000506e:	a65fc0ef          	jal	ra,80001ad2 <myproc>
    80005072:	fec42783          	lw	a5,-20(s0)
    80005076:	07e9                	addi	a5,a5,26
    80005078:	078e                	slli	a5,a5,0x3
    8000507a:	953e                	add	a0,a0,a5
    8000507c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005080:	fe043503          	ld	a0,-32(s0)
    80005084:	bdcff0ef          	jal	ra,80004460 <fileclose>
  return 0;
    80005088:	4781                	li	a5,0
}
    8000508a:	853e                	mv	a0,a5
    8000508c:	60e2                	ld	ra,24(sp)
    8000508e:	6442                	ld	s0,16(sp)
    80005090:	6105                	addi	sp,sp,32
    80005092:	8082                	ret

0000000080005094 <sys_fstat>:
{
    80005094:	1101                	addi	sp,sp,-32
    80005096:	ec06                	sd	ra,24(sp)
    80005098:	e822                	sd	s0,16(sp)
    8000509a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000509c:	fe040593          	addi	a1,s0,-32
    800050a0:	4505                	li	a0,1
    800050a2:	9f3fd0ef          	jal	ra,80002a94 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800050a6:	fe840613          	addi	a2,s0,-24
    800050aa:	4581                	li	a1,0
    800050ac:	4501                	li	a0,0
    800050ae:	cfbff0ef          	jal	ra,80004da8 <argfd>
    800050b2:	87aa                	mv	a5,a0
    return -1;
    800050b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800050b6:	0007c863          	bltz	a5,800050c6 <sys_fstat+0x32>
  return filestat(f, st);
    800050ba:	fe043583          	ld	a1,-32(s0)
    800050be:	fe843503          	ld	a0,-24(s0)
    800050c2:	c46ff0ef          	jal	ra,80004508 <filestat>
}
    800050c6:	60e2                	ld	ra,24(sp)
    800050c8:	6442                	ld	s0,16(sp)
    800050ca:	6105                	addi	sp,sp,32
    800050cc:	8082                	ret

00000000800050ce <sys_link>:
{
    800050ce:	7169                	addi	sp,sp,-304
    800050d0:	f606                	sd	ra,296(sp)
    800050d2:	f222                	sd	s0,288(sp)
    800050d4:	ee26                	sd	s1,280(sp)
    800050d6:	ea4a                	sd	s2,272(sp)
    800050d8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050da:	08000613          	li	a2,128
    800050de:	ed040593          	addi	a1,s0,-304
    800050e2:	4501                	li	a0,0
    800050e4:	9cdfd0ef          	jal	ra,80002ab0 <argstr>
    return -1;
    800050e8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050ea:	0c054663          	bltz	a0,800051b6 <sys_link+0xe8>
    800050ee:	08000613          	li	a2,128
    800050f2:	f5040593          	addi	a1,s0,-176
    800050f6:	4505                	li	a0,1
    800050f8:	9b9fd0ef          	jal	ra,80002ab0 <argstr>
    return -1;
    800050fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050fe:	0a054c63          	bltz	a0,800051b6 <sys_link+0xe8>
  begin_op();
    80005102:	f55fe0ef          	jal	ra,80004056 <begin_op>
  if((ip = namei(old)) == 0){
    80005106:	ed040513          	addi	a0,s0,-304
    8000510a:	d59fe0ef          	jal	ra,80003e62 <namei>
    8000510e:	84aa                	mv	s1,a0
    80005110:	c525                	beqz	a0,80005178 <sys_link+0xaa>
  ilock(ip);
    80005112:	d5cfe0ef          	jal	ra,8000366e <ilock>
  if(ip->type == T_DIR){
    80005116:	04449703          	lh	a4,68(s1)
    8000511a:	4785                	li	a5,1
    8000511c:	06f70263          	beq	a4,a5,80005180 <sys_link+0xb2>
  ip->nlink++;
    80005120:	04a4d783          	lhu	a5,74(s1)
    80005124:	2785                	addiw	a5,a5,1
    80005126:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000512a:	8526                	mv	a0,s1
    8000512c:	c8efe0ef          	jal	ra,800035ba <iupdate>
  iunlock(ip);
    80005130:	8526                	mv	a0,s1
    80005132:	de6fe0ef          	jal	ra,80003718 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005136:	fd040593          	addi	a1,s0,-48
    8000513a:	f5040513          	addi	a0,s0,-176
    8000513e:	d3ffe0ef          	jal	ra,80003e7c <nameiparent>
    80005142:	892a                	mv	s2,a0
    80005144:	c921                	beqz	a0,80005194 <sys_link+0xc6>
  ilock(dp);
    80005146:	d28fe0ef          	jal	ra,8000366e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000514a:	00092703          	lw	a4,0(s2)
    8000514e:	409c                	lw	a5,0(s1)
    80005150:	02f71f63          	bne	a4,a5,8000518e <sys_link+0xc0>
    80005154:	40d0                	lw	a2,4(s1)
    80005156:	fd040593          	addi	a1,s0,-48
    8000515a:	854a                	mv	a0,s2
    8000515c:	c6dfe0ef          	jal	ra,80003dc8 <dirlink>
    80005160:	02054763          	bltz	a0,8000518e <sys_link+0xc0>
  iunlockput(dp);
    80005164:	854a                	mv	a0,s2
    80005166:	f0efe0ef          	jal	ra,80003874 <iunlockput>
  iput(ip);
    8000516a:	8526                	mv	a0,s1
    8000516c:	e80fe0ef          	jal	ra,800037ec <iput>
  end_op();
    80005170:	f55fe0ef          	jal	ra,800040c4 <end_op>
  return 0;
    80005174:	4781                	li	a5,0
    80005176:	a081                	j	800051b6 <sys_link+0xe8>
    end_op();
    80005178:	f4dfe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    8000517c:	57fd                	li	a5,-1
    8000517e:	a825                	j	800051b6 <sys_link+0xe8>
    iunlockput(ip);
    80005180:	8526                	mv	a0,s1
    80005182:	ef2fe0ef          	jal	ra,80003874 <iunlockput>
    end_op();
    80005186:	f3ffe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    8000518a:	57fd                	li	a5,-1
    8000518c:	a02d                	j	800051b6 <sys_link+0xe8>
    iunlockput(dp);
    8000518e:	854a                	mv	a0,s2
    80005190:	ee4fe0ef          	jal	ra,80003874 <iunlockput>
  ilock(ip);
    80005194:	8526                	mv	a0,s1
    80005196:	cd8fe0ef          	jal	ra,8000366e <ilock>
  ip->nlink--;
    8000519a:	04a4d783          	lhu	a5,74(s1)
    8000519e:	37fd                	addiw	a5,a5,-1
    800051a0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051a4:	8526                	mv	a0,s1
    800051a6:	c14fe0ef          	jal	ra,800035ba <iupdate>
  iunlockput(ip);
    800051aa:	8526                	mv	a0,s1
    800051ac:	ec8fe0ef          	jal	ra,80003874 <iunlockput>
  end_op();
    800051b0:	f15fe0ef          	jal	ra,800040c4 <end_op>
  return -1;
    800051b4:	57fd                	li	a5,-1
}
    800051b6:	853e                	mv	a0,a5
    800051b8:	70b2                	ld	ra,296(sp)
    800051ba:	7412                	ld	s0,288(sp)
    800051bc:	64f2                	ld	s1,280(sp)
    800051be:	6952                	ld	s2,272(sp)
    800051c0:	6155                	addi	sp,sp,304
    800051c2:	8082                	ret

00000000800051c4 <sys_unlink>:
{
    800051c4:	7151                	addi	sp,sp,-240
    800051c6:	f586                	sd	ra,232(sp)
    800051c8:	f1a2                	sd	s0,224(sp)
    800051ca:	eda6                	sd	s1,216(sp)
    800051cc:	e9ca                	sd	s2,208(sp)
    800051ce:	e5ce                	sd	s3,200(sp)
    800051d0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800051d2:	08000613          	li	a2,128
    800051d6:	f3040593          	addi	a1,s0,-208
    800051da:	4501                	li	a0,0
    800051dc:	8d5fd0ef          	jal	ra,80002ab0 <argstr>
    800051e0:	12054b63          	bltz	a0,80005316 <sys_unlink+0x152>
  begin_op();
    800051e4:	e73fe0ef          	jal	ra,80004056 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800051e8:	fb040593          	addi	a1,s0,-80
    800051ec:	f3040513          	addi	a0,s0,-208
    800051f0:	c8dfe0ef          	jal	ra,80003e7c <nameiparent>
    800051f4:	84aa                	mv	s1,a0
    800051f6:	c54d                	beqz	a0,800052a0 <sys_unlink+0xdc>
  ilock(dp);
    800051f8:	c76fe0ef          	jal	ra,8000366e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051fc:	00002597          	auipc	a1,0x2
    80005200:	4ec58593          	addi	a1,a1,1260 # 800076e8 <syscalls+0x2f0>
    80005204:	fb040513          	addi	a0,s0,-80
    80005208:	9d9fe0ef          	jal	ra,80003be0 <namecmp>
    8000520c:	10050a63          	beqz	a0,80005320 <sys_unlink+0x15c>
    80005210:	00002597          	auipc	a1,0x2
    80005214:	4e058593          	addi	a1,a1,1248 # 800076f0 <syscalls+0x2f8>
    80005218:	fb040513          	addi	a0,s0,-80
    8000521c:	9c5fe0ef          	jal	ra,80003be0 <namecmp>
    80005220:	10050063          	beqz	a0,80005320 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005224:	f2c40613          	addi	a2,s0,-212
    80005228:	fb040593          	addi	a1,s0,-80
    8000522c:	8526                	mv	a0,s1
    8000522e:	9c9fe0ef          	jal	ra,80003bf6 <dirlookup>
    80005232:	892a                	mv	s2,a0
    80005234:	0e050663          	beqz	a0,80005320 <sys_unlink+0x15c>
  ilock(ip);
    80005238:	c36fe0ef          	jal	ra,8000366e <ilock>
  if(ip->nlink < 1)
    8000523c:	04a91783          	lh	a5,74(s2)
    80005240:	06f05463          	blez	a5,800052a8 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005244:	04491703          	lh	a4,68(s2)
    80005248:	4785                	li	a5,1
    8000524a:	06f70563          	beq	a4,a5,800052b4 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    8000524e:	4641                	li	a2,16
    80005250:	4581                	li	a1,0
    80005252:	fc040513          	addi	a0,s0,-64
    80005256:	b1ffb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000525a:	4741                	li	a4,16
    8000525c:	f2c42683          	lw	a3,-212(s0)
    80005260:	fc040613          	addi	a2,s0,-64
    80005264:	4581                	li	a1,0
    80005266:	8526                	mv	a0,s1
    80005268:	877fe0ef          	jal	ra,80003ade <writei>
    8000526c:	47c1                	li	a5,16
    8000526e:	08f51563          	bne	a0,a5,800052f8 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005272:	04491703          	lh	a4,68(s2)
    80005276:	4785                	li	a5,1
    80005278:	08f70663          	beq	a4,a5,80005304 <sys_unlink+0x140>
  iunlockput(dp);
    8000527c:	8526                	mv	a0,s1
    8000527e:	df6fe0ef          	jal	ra,80003874 <iunlockput>
  ip->nlink--;
    80005282:	04a95783          	lhu	a5,74(s2)
    80005286:	37fd                	addiw	a5,a5,-1
    80005288:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000528c:	854a                	mv	a0,s2
    8000528e:	b2cfe0ef          	jal	ra,800035ba <iupdate>
  iunlockput(ip);
    80005292:	854a                	mv	a0,s2
    80005294:	de0fe0ef          	jal	ra,80003874 <iunlockput>
  end_op();
    80005298:	e2dfe0ef          	jal	ra,800040c4 <end_op>
  return 0;
    8000529c:	4501                	li	a0,0
    8000529e:	a079                	j	8000532c <sys_unlink+0x168>
    end_op();
    800052a0:	e25fe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    800052a4:	557d                	li	a0,-1
    800052a6:	a059                	j	8000532c <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800052a8:	00002517          	auipc	a0,0x2
    800052ac:	45050513          	addi	a0,a0,1104 # 800076f8 <syscalls+0x300>
    800052b0:	cd8fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052b4:	04c92703          	lw	a4,76(s2)
    800052b8:	02000793          	li	a5,32
    800052bc:	f8e7f9e3          	bgeu	a5,a4,8000524e <sys_unlink+0x8a>
    800052c0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052c4:	4741                	li	a4,16
    800052c6:	86ce                	mv	a3,s3
    800052c8:	f1840613          	addi	a2,s0,-232
    800052cc:	4581                	li	a1,0
    800052ce:	854a                	mv	a0,s2
    800052d0:	f2afe0ef          	jal	ra,800039fa <readi>
    800052d4:	47c1                	li	a5,16
    800052d6:	00f51b63          	bne	a0,a5,800052ec <sys_unlink+0x128>
    if(de.inum != 0)
    800052da:	f1845783          	lhu	a5,-232(s0)
    800052de:	ef95                	bnez	a5,8000531a <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052e0:	29c1                	addiw	s3,s3,16
    800052e2:	04c92783          	lw	a5,76(s2)
    800052e6:	fcf9efe3          	bltu	s3,a5,800052c4 <sys_unlink+0x100>
    800052ea:	b795                	j	8000524e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052ec:	00002517          	auipc	a0,0x2
    800052f0:	42450513          	addi	a0,a0,1060 # 80007710 <syscalls+0x318>
    800052f4:	c94fb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    800052f8:	00002517          	auipc	a0,0x2
    800052fc:	43050513          	addi	a0,a0,1072 # 80007728 <syscalls+0x330>
    80005300:	c88fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005304:	04a4d783          	lhu	a5,74(s1)
    80005308:	37fd                	addiw	a5,a5,-1
    8000530a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000530e:	8526                	mv	a0,s1
    80005310:	aaafe0ef          	jal	ra,800035ba <iupdate>
    80005314:	b7a5                	j	8000527c <sys_unlink+0xb8>
    return -1;
    80005316:	557d                	li	a0,-1
    80005318:	a811                	j	8000532c <sys_unlink+0x168>
    iunlockput(ip);
    8000531a:	854a                	mv	a0,s2
    8000531c:	d58fe0ef          	jal	ra,80003874 <iunlockput>
  iunlockput(dp);
    80005320:	8526                	mv	a0,s1
    80005322:	d52fe0ef          	jal	ra,80003874 <iunlockput>
  end_op();
    80005326:	d9ffe0ef          	jal	ra,800040c4 <end_op>
  return -1;
    8000532a:	557d                	li	a0,-1
}
    8000532c:	70ae                	ld	ra,232(sp)
    8000532e:	740e                	ld	s0,224(sp)
    80005330:	64ee                	ld	s1,216(sp)
    80005332:	694e                	ld	s2,208(sp)
    80005334:	69ae                	ld	s3,200(sp)
    80005336:	616d                	addi	sp,sp,240
    80005338:	8082                	ret

000000008000533a <sys_open>:

uint64
sys_open(void)
{
    8000533a:	7131                	addi	sp,sp,-192
    8000533c:	fd06                	sd	ra,184(sp)
    8000533e:	f922                	sd	s0,176(sp)
    80005340:	f526                	sd	s1,168(sp)
    80005342:	f14a                	sd	s2,160(sp)
    80005344:	ed4e                	sd	s3,152(sp)
    80005346:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005348:	f4c40593          	addi	a1,s0,-180
    8000534c:	4505                	li	a0,1
    8000534e:	f2afd0ef          	jal	ra,80002a78 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005352:	08000613          	li	a2,128
    80005356:	f5040593          	addi	a1,s0,-176
    8000535a:	4501                	li	a0,0
    8000535c:	f54fd0ef          	jal	ra,80002ab0 <argstr>
    80005360:	87aa                	mv	a5,a0
    return -1;
    80005362:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005364:	0807cd63          	bltz	a5,800053fe <sys_open+0xc4>

  begin_op();
    80005368:	ceffe0ef          	jal	ra,80004056 <begin_op>

  if(omode & O_CREATE){
    8000536c:	f4c42783          	lw	a5,-180(s0)
    80005370:	2007f793          	andi	a5,a5,512
    80005374:	c3c5                	beqz	a5,80005414 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005376:	4681                	li	a3,0
    80005378:	4601                	li	a2,0
    8000537a:	4589                	li	a1,2
    8000537c:	f5040513          	addi	a0,s0,-176
    80005380:	abfff0ef          	jal	ra,80004e3e <create>
    80005384:	84aa                	mv	s1,a0
    if(ip == 0){
    80005386:	c159                	beqz	a0,8000540c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005388:	04449703          	lh	a4,68(s1)
    8000538c:	478d                	li	a5,3
    8000538e:	00f71763          	bne	a4,a5,8000539c <sys_open+0x62>
    80005392:	0464d703          	lhu	a4,70(s1)
    80005396:	47a5                	li	a5,9
    80005398:	0ae7e963          	bltu	a5,a4,8000544a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000539c:	820ff0ef          	jal	ra,800043bc <filealloc>
    800053a0:	89aa                	mv	s3,a0
    800053a2:	0c050963          	beqz	a0,80005474 <sys_open+0x13a>
    800053a6:	a5bff0ef          	jal	ra,80004e00 <fdalloc>
    800053aa:	892a                	mv	s2,a0
    800053ac:	0c054163          	bltz	a0,8000546e <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800053b0:	04449703          	lh	a4,68(s1)
    800053b4:	478d                	li	a5,3
    800053b6:	0af70163          	beq	a4,a5,80005458 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053ba:	4789                	li	a5,2
    800053bc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800053c0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800053c4:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800053c8:	f4c42783          	lw	a5,-180(s0)
    800053cc:	0017c713          	xori	a4,a5,1
    800053d0:	8b05                	andi	a4,a4,1
    800053d2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053d6:	0037f713          	andi	a4,a5,3
    800053da:	00e03733          	snez	a4,a4
    800053de:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800053e2:	4007f793          	andi	a5,a5,1024
    800053e6:	c791                	beqz	a5,800053f2 <sys_open+0xb8>
    800053e8:	04449703          	lh	a4,68(s1)
    800053ec:	4789                	li	a5,2
    800053ee:	06f70c63          	beq	a4,a5,80005466 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    800053f2:	8526                	mv	a0,s1
    800053f4:	b24fe0ef          	jal	ra,80003718 <iunlock>
  end_op();
    800053f8:	ccdfe0ef          	jal	ra,800040c4 <end_op>

  return fd;
    800053fc:	854a                	mv	a0,s2
}
    800053fe:	70ea                	ld	ra,184(sp)
    80005400:	744a                	ld	s0,176(sp)
    80005402:	74aa                	ld	s1,168(sp)
    80005404:	790a                	ld	s2,160(sp)
    80005406:	69ea                	ld	s3,152(sp)
    80005408:	6129                	addi	sp,sp,192
    8000540a:	8082                	ret
      end_op();
    8000540c:	cb9fe0ef          	jal	ra,800040c4 <end_op>
      return -1;
    80005410:	557d                	li	a0,-1
    80005412:	b7f5                	j	800053fe <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005414:	f5040513          	addi	a0,s0,-176
    80005418:	a4bfe0ef          	jal	ra,80003e62 <namei>
    8000541c:	84aa                	mv	s1,a0
    8000541e:	c115                	beqz	a0,80005442 <sys_open+0x108>
    ilock(ip);
    80005420:	a4efe0ef          	jal	ra,8000366e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005424:	04449703          	lh	a4,68(s1)
    80005428:	4785                	li	a5,1
    8000542a:	f4f71fe3          	bne	a4,a5,80005388 <sys_open+0x4e>
    8000542e:	f4c42783          	lw	a5,-180(s0)
    80005432:	d7ad                	beqz	a5,8000539c <sys_open+0x62>
      iunlockput(ip);
    80005434:	8526                	mv	a0,s1
    80005436:	c3efe0ef          	jal	ra,80003874 <iunlockput>
      end_op();
    8000543a:	c8bfe0ef          	jal	ra,800040c4 <end_op>
      return -1;
    8000543e:	557d                	li	a0,-1
    80005440:	bf7d                	j	800053fe <sys_open+0xc4>
      end_op();
    80005442:	c83fe0ef          	jal	ra,800040c4 <end_op>
      return -1;
    80005446:	557d                	li	a0,-1
    80005448:	bf5d                	j	800053fe <sys_open+0xc4>
    iunlockput(ip);
    8000544a:	8526                	mv	a0,s1
    8000544c:	c28fe0ef          	jal	ra,80003874 <iunlockput>
    end_op();
    80005450:	c75fe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    80005454:	557d                	li	a0,-1
    80005456:	b765                	j	800053fe <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005458:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000545c:	04649783          	lh	a5,70(s1)
    80005460:	02f99223          	sh	a5,36(s3)
    80005464:	b785                	j	800053c4 <sys_open+0x8a>
    itrunc(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	af0fe0ef          	jal	ra,80003758 <itrunc>
    8000546c:	b759                	j	800053f2 <sys_open+0xb8>
      fileclose(f);
    8000546e:	854e                	mv	a0,s3
    80005470:	ff1fe0ef          	jal	ra,80004460 <fileclose>
    iunlockput(ip);
    80005474:	8526                	mv	a0,s1
    80005476:	bfefe0ef          	jal	ra,80003874 <iunlockput>
    end_op();
    8000547a:	c4bfe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    8000547e:	557d                	li	a0,-1
    80005480:	bfbd                	j	800053fe <sys_open+0xc4>

0000000080005482 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005482:	7175                	addi	sp,sp,-144
    80005484:	e506                	sd	ra,136(sp)
    80005486:	e122                	sd	s0,128(sp)
    80005488:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000548a:	bcdfe0ef          	jal	ra,80004056 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000548e:	08000613          	li	a2,128
    80005492:	f7040593          	addi	a1,s0,-144
    80005496:	4501                	li	a0,0
    80005498:	e18fd0ef          	jal	ra,80002ab0 <argstr>
    8000549c:	02054363          	bltz	a0,800054c2 <sys_mkdir+0x40>
    800054a0:	4681                	li	a3,0
    800054a2:	4601                	li	a2,0
    800054a4:	4585                	li	a1,1
    800054a6:	f7040513          	addi	a0,s0,-144
    800054aa:	995ff0ef          	jal	ra,80004e3e <create>
    800054ae:	c911                	beqz	a0,800054c2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054b0:	bc4fe0ef          	jal	ra,80003874 <iunlockput>
  end_op();
    800054b4:	c11fe0ef          	jal	ra,800040c4 <end_op>
  return 0;
    800054b8:	4501                	li	a0,0
}
    800054ba:	60aa                	ld	ra,136(sp)
    800054bc:	640a                	ld	s0,128(sp)
    800054be:	6149                	addi	sp,sp,144
    800054c0:	8082                	ret
    end_op();
    800054c2:	c03fe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    800054c6:	557d                	li	a0,-1
    800054c8:	bfcd                	j	800054ba <sys_mkdir+0x38>

00000000800054ca <sys_mknod>:

uint64
sys_mknod(void)
{
    800054ca:	7135                	addi	sp,sp,-160
    800054cc:	ed06                	sd	ra,152(sp)
    800054ce:	e922                	sd	s0,144(sp)
    800054d0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054d2:	b85fe0ef          	jal	ra,80004056 <begin_op>
  argint(1, &major);
    800054d6:	f6c40593          	addi	a1,s0,-148
    800054da:	4505                	li	a0,1
    800054dc:	d9cfd0ef          	jal	ra,80002a78 <argint>
  argint(2, &minor);
    800054e0:	f6840593          	addi	a1,s0,-152
    800054e4:	4509                	li	a0,2
    800054e6:	d92fd0ef          	jal	ra,80002a78 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054ea:	08000613          	li	a2,128
    800054ee:	f7040593          	addi	a1,s0,-144
    800054f2:	4501                	li	a0,0
    800054f4:	dbcfd0ef          	jal	ra,80002ab0 <argstr>
    800054f8:	02054563          	bltz	a0,80005522 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800054fc:	f6841683          	lh	a3,-152(s0)
    80005500:	f6c41603          	lh	a2,-148(s0)
    80005504:	458d                	li	a1,3
    80005506:	f7040513          	addi	a0,s0,-144
    8000550a:	935ff0ef          	jal	ra,80004e3e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000550e:	c911                	beqz	a0,80005522 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005510:	b64fe0ef          	jal	ra,80003874 <iunlockput>
  end_op();
    80005514:	bb1fe0ef          	jal	ra,800040c4 <end_op>
  return 0;
    80005518:	4501                	li	a0,0
}
    8000551a:	60ea                	ld	ra,152(sp)
    8000551c:	644a                	ld	s0,144(sp)
    8000551e:	610d                	addi	sp,sp,160
    80005520:	8082                	ret
    end_op();
    80005522:	ba3fe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    80005526:	557d                	li	a0,-1
    80005528:	bfcd                	j	8000551a <sys_mknod+0x50>

000000008000552a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000552a:	7135                	addi	sp,sp,-160
    8000552c:	ed06                	sd	ra,152(sp)
    8000552e:	e922                	sd	s0,144(sp)
    80005530:	e526                	sd	s1,136(sp)
    80005532:	e14a                	sd	s2,128(sp)
    80005534:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005536:	d9cfc0ef          	jal	ra,80001ad2 <myproc>
    8000553a:	892a                	mv	s2,a0
  
  begin_op();
    8000553c:	b1bfe0ef          	jal	ra,80004056 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005540:	08000613          	li	a2,128
    80005544:	f6040593          	addi	a1,s0,-160
    80005548:	4501                	li	a0,0
    8000554a:	d66fd0ef          	jal	ra,80002ab0 <argstr>
    8000554e:	04054163          	bltz	a0,80005590 <sys_chdir+0x66>
    80005552:	f6040513          	addi	a0,s0,-160
    80005556:	90dfe0ef          	jal	ra,80003e62 <namei>
    8000555a:	84aa                	mv	s1,a0
    8000555c:	c915                	beqz	a0,80005590 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000555e:	910fe0ef          	jal	ra,8000366e <ilock>
  if(ip->type != T_DIR){
    80005562:	04449703          	lh	a4,68(s1)
    80005566:	4785                	li	a5,1
    80005568:	02f71863          	bne	a4,a5,80005598 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000556c:	8526                	mv	a0,s1
    8000556e:	9aafe0ef          	jal	ra,80003718 <iunlock>
  iput(p->cwd);
    80005572:	15093503          	ld	a0,336(s2)
    80005576:	a76fe0ef          	jal	ra,800037ec <iput>
  end_op();
    8000557a:	b4bfe0ef          	jal	ra,800040c4 <end_op>
  p->cwd = ip;
    8000557e:	14993823          	sd	s1,336(s2)
  return 0;
    80005582:	4501                	li	a0,0
}
    80005584:	60ea                	ld	ra,152(sp)
    80005586:	644a                	ld	s0,144(sp)
    80005588:	64aa                	ld	s1,136(sp)
    8000558a:	690a                	ld	s2,128(sp)
    8000558c:	610d                	addi	sp,sp,160
    8000558e:	8082                	ret
    end_op();
    80005590:	b35fe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    80005594:	557d                	li	a0,-1
    80005596:	b7fd                	j	80005584 <sys_chdir+0x5a>
    iunlockput(ip);
    80005598:	8526                	mv	a0,s1
    8000559a:	adafe0ef          	jal	ra,80003874 <iunlockput>
    end_op();
    8000559e:	b27fe0ef          	jal	ra,800040c4 <end_op>
    return -1;
    800055a2:	557d                	li	a0,-1
    800055a4:	b7c5                	j	80005584 <sys_chdir+0x5a>

00000000800055a6 <sys_exec>:

uint64
sys_exec(void)
{
    800055a6:	7145                	addi	sp,sp,-464
    800055a8:	e786                	sd	ra,456(sp)
    800055aa:	e3a2                	sd	s0,448(sp)
    800055ac:	ff26                	sd	s1,440(sp)
    800055ae:	fb4a                	sd	s2,432(sp)
    800055b0:	f74e                	sd	s3,424(sp)
    800055b2:	f352                	sd	s4,416(sp)
    800055b4:	ef56                	sd	s5,408(sp)
    800055b6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055b8:	e3840593          	addi	a1,s0,-456
    800055bc:	4505                	li	a0,1
    800055be:	cd6fd0ef          	jal	ra,80002a94 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800055c2:	08000613          	li	a2,128
    800055c6:	f4040593          	addi	a1,s0,-192
    800055ca:	4501                	li	a0,0
    800055cc:	ce4fd0ef          	jal	ra,80002ab0 <argstr>
    800055d0:	87aa                	mv	a5,a0
    return -1;
    800055d2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800055d4:	0a07c563          	bltz	a5,8000567e <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    800055d8:	10000613          	li	a2,256
    800055dc:	4581                	li	a1,0
    800055de:	e4040513          	addi	a0,s0,-448
    800055e2:	f92fb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800055e6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800055ea:	89a6                	mv	s3,s1
    800055ec:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800055ee:	02000a13          	li	s4,32
    800055f2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055f6:	00391513          	slli	a0,s2,0x3
    800055fa:	e3040593          	addi	a1,s0,-464
    800055fe:	e3843783          	ld	a5,-456(s0)
    80005602:	953e                	add	a0,a0,a5
    80005604:	beafd0ef          	jal	ra,800029ee <fetchaddr>
    80005608:	02054663          	bltz	a0,80005634 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000560c:	e3043783          	ld	a5,-464(s0)
    80005610:	cf8d                	beqz	a5,8000564a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005612:	d98fb0ef          	jal	ra,80000baa <kalloc>
    80005616:	85aa                	mv	a1,a0
    80005618:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000561c:	cd01                	beqz	a0,80005634 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000561e:	6605                	lui	a2,0x1
    80005620:	e3043503          	ld	a0,-464(s0)
    80005624:	c14fd0ef          	jal	ra,80002a38 <fetchstr>
    80005628:	00054663          	bltz	a0,80005634 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    8000562c:	0905                	addi	s2,s2,1
    8000562e:	09a1                	addi	s3,s3,8
    80005630:	fd4911e3          	bne	s2,s4,800055f2 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005634:	f4040913          	addi	s2,s0,-192
    80005638:	6088                	ld	a0,0(s1)
    8000563a:	c129                	beqz	a0,8000567c <sys_exec+0xd6>
    kfree(argv[i]);
    8000563c:	c3efb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005640:	04a1                	addi	s1,s1,8
    80005642:	ff249be3          	bne	s1,s2,80005638 <sys_exec+0x92>
  return -1;
    80005646:	557d                	li	a0,-1
    80005648:	a81d                	j	8000567e <sys_exec+0xd8>
      argv[i] = 0;
    8000564a:	0a8e                	slli	s5,s5,0x3
    8000564c:	fc0a8793          	addi	a5,s5,-64
    80005650:	00878ab3          	add	s5,a5,s0
    80005654:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005658:	e4040593          	addi	a1,s0,-448
    8000565c:	f4040513          	addi	a0,s0,-192
    80005660:	bacff0ef          	jal	ra,80004a0c <kexec>
    80005664:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005666:	f4040993          	addi	s3,s0,-192
    8000566a:	6088                	ld	a0,0(s1)
    8000566c:	c511                	beqz	a0,80005678 <sys_exec+0xd2>
    kfree(argv[i]);
    8000566e:	c0cfb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005672:	04a1                	addi	s1,s1,8
    80005674:	ff349be3          	bne	s1,s3,8000566a <sys_exec+0xc4>
  return ret;
    80005678:	854a                	mv	a0,s2
    8000567a:	a011                	j	8000567e <sys_exec+0xd8>
  return -1;
    8000567c:	557d                	li	a0,-1
}
    8000567e:	60be                	ld	ra,456(sp)
    80005680:	641e                	ld	s0,448(sp)
    80005682:	74fa                	ld	s1,440(sp)
    80005684:	795a                	ld	s2,432(sp)
    80005686:	79ba                	ld	s3,424(sp)
    80005688:	7a1a                	ld	s4,416(sp)
    8000568a:	6afa                	ld	s5,408(sp)
    8000568c:	6179                	addi	sp,sp,464
    8000568e:	8082                	ret

0000000080005690 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005690:	7139                	addi	sp,sp,-64
    80005692:	fc06                	sd	ra,56(sp)
    80005694:	f822                	sd	s0,48(sp)
    80005696:	f426                	sd	s1,40(sp)
    80005698:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000569a:	c38fc0ef          	jal	ra,80001ad2 <myproc>
    8000569e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056a0:	fd840593          	addi	a1,s0,-40
    800056a4:	4501                	li	a0,0
    800056a6:	beefd0ef          	jal	ra,80002a94 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800056aa:	fc840593          	addi	a1,s0,-56
    800056ae:	fd040513          	addi	a0,s0,-48
    800056b2:	87aff0ef          	jal	ra,8000472c <pipealloc>
    return -1;
    800056b6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800056b8:	0a054463          	bltz	a0,80005760 <sys_pipe+0xd0>
  fd0 = -1;
    800056bc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800056c0:	fd043503          	ld	a0,-48(s0)
    800056c4:	f3cff0ef          	jal	ra,80004e00 <fdalloc>
    800056c8:	fca42223          	sw	a0,-60(s0)
    800056cc:	08054163          	bltz	a0,8000574e <sys_pipe+0xbe>
    800056d0:	fc843503          	ld	a0,-56(s0)
    800056d4:	f2cff0ef          	jal	ra,80004e00 <fdalloc>
    800056d8:	fca42023          	sw	a0,-64(s0)
    800056dc:	06054063          	bltz	a0,8000573c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056e0:	4691                	li	a3,4
    800056e2:	fc440613          	addi	a2,s0,-60
    800056e6:	fd843583          	ld	a1,-40(s0)
    800056ea:	68a8                	ld	a0,80(s1)
    800056ec:	872fc0ef          	jal	ra,8000175e <copyout>
    800056f0:	00054e63          	bltz	a0,8000570c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800056f4:	4691                	li	a3,4
    800056f6:	fc040613          	addi	a2,s0,-64
    800056fa:	fd843583          	ld	a1,-40(s0)
    800056fe:	0591                	addi	a1,a1,4
    80005700:	68a8                	ld	a0,80(s1)
    80005702:	85cfc0ef          	jal	ra,8000175e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005706:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005708:	04055c63          	bgez	a0,80005760 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000570c:	fc442783          	lw	a5,-60(s0)
    80005710:	07e9                	addi	a5,a5,26
    80005712:	078e                	slli	a5,a5,0x3
    80005714:	97a6                	add	a5,a5,s1
    80005716:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000571a:	fc042783          	lw	a5,-64(s0)
    8000571e:	07e9                	addi	a5,a5,26
    80005720:	078e                	slli	a5,a5,0x3
    80005722:	94be                	add	s1,s1,a5
    80005724:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005728:	fd043503          	ld	a0,-48(s0)
    8000572c:	d35fe0ef          	jal	ra,80004460 <fileclose>
    fileclose(wf);
    80005730:	fc843503          	ld	a0,-56(s0)
    80005734:	d2dfe0ef          	jal	ra,80004460 <fileclose>
    return -1;
    80005738:	57fd                	li	a5,-1
    8000573a:	a01d                	j	80005760 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000573c:	fc442783          	lw	a5,-60(s0)
    80005740:	0007c763          	bltz	a5,8000574e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005744:	07e9                	addi	a5,a5,26
    80005746:	078e                	slli	a5,a5,0x3
    80005748:	97a6                	add	a5,a5,s1
    8000574a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000574e:	fd043503          	ld	a0,-48(s0)
    80005752:	d0ffe0ef          	jal	ra,80004460 <fileclose>
    fileclose(wf);
    80005756:	fc843503          	ld	a0,-56(s0)
    8000575a:	d07fe0ef          	jal	ra,80004460 <fileclose>
    return -1;
    8000575e:	57fd                	li	a5,-1
}
    80005760:	853e                	mv	a0,a5
    80005762:	70e2                	ld	ra,56(sp)
    80005764:	7442                	ld	s0,48(sp)
    80005766:	74a2                	ld	s1,40(sp)
    80005768:	6121                	addi	sp,sp,64
    8000576a:	8082                	ret
    8000576c:	0000                	unimp
	...

0000000080005770 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005770:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005772:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005774:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005776:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005778:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000577a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000577c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000577e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005780:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005782:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005784:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005786:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005788:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000578a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000578c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000578e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005790:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005792:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005794:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005796:	968fd0ef          	jal	ra,800028fe <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000579a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000579c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000579e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800057b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800057b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800057b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800057b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800057b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800057ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800057bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800057be:	10200073          	sret
	...

00000000800057ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057ce:	1141                	addi	sp,sp,-16
    800057d0:	e422                	sd	s0,8(sp)
    800057d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800057d4:	0c0007b7          	lui	a5,0xc000
    800057d8:	4705                	li	a4,1
    800057da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800057dc:	c3d8                	sw	a4,4(a5)
}
    800057de:	6422                	ld	s0,8(sp)
    800057e0:	0141                	addi	sp,sp,16
    800057e2:	8082                	ret

00000000800057e4 <plicinithart>:

void
plicinithart(void)
{
    800057e4:	1141                	addi	sp,sp,-16
    800057e6:	e406                	sd	ra,8(sp)
    800057e8:	e022                	sd	s0,0(sp)
    800057ea:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057ec:	abafc0ef          	jal	ra,80001aa6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800057f0:	0085171b          	slliw	a4,a0,0x8
    800057f4:	0c0027b7          	lui	a5,0xc002
    800057f8:	97ba                	add	a5,a5,a4
    800057fa:	40200713          	li	a4,1026
    800057fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005802:	00d5151b          	slliw	a0,a0,0xd
    80005806:	0c2017b7          	lui	a5,0xc201
    8000580a:	97aa                	add	a5,a5,a0
    8000580c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005810:	60a2                	ld	ra,8(sp)
    80005812:	6402                	ld	s0,0(sp)
    80005814:	0141                	addi	sp,sp,16
    80005816:	8082                	ret

0000000080005818 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005818:	1141                	addi	sp,sp,-16
    8000581a:	e406                	sd	ra,8(sp)
    8000581c:	e022                	sd	s0,0(sp)
    8000581e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005820:	a86fc0ef          	jal	ra,80001aa6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005824:	00d5151b          	slliw	a0,a0,0xd
    80005828:	0c2017b7          	lui	a5,0xc201
    8000582c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000582e:	43c8                	lw	a0,4(a5)
    80005830:	60a2                	ld	ra,8(sp)
    80005832:	6402                	ld	s0,0(sp)
    80005834:	0141                	addi	sp,sp,16
    80005836:	8082                	ret

0000000080005838 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005838:	1101                	addi	sp,sp,-32
    8000583a:	ec06                	sd	ra,24(sp)
    8000583c:	e822                	sd	s0,16(sp)
    8000583e:	e426                	sd	s1,8(sp)
    80005840:	1000                	addi	s0,sp,32
    80005842:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005844:	a62fc0ef          	jal	ra,80001aa6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005848:	00d5151b          	slliw	a0,a0,0xd
    8000584c:	0c2017b7          	lui	a5,0xc201
    80005850:	97aa                	add	a5,a5,a0
    80005852:	c3c4                	sw	s1,4(a5)
}
    80005854:	60e2                	ld	ra,24(sp)
    80005856:	6442                	ld	s0,16(sp)
    80005858:	64a2                	ld	s1,8(sp)
    8000585a:	6105                	addi	sp,sp,32
    8000585c:	8082                	ret

000000008000585e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000585e:	1141                	addi	sp,sp,-16
    80005860:	e406                	sd	ra,8(sp)
    80005862:	e022                	sd	s0,0(sp)
    80005864:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005866:	479d                	li	a5,7
    80005868:	04a7ca63          	blt	a5,a0,800058bc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000586c:	00243797          	auipc	a5,0x243
    80005870:	21478793          	addi	a5,a5,532 # 80248a80 <disk>
    80005874:	97aa                	add	a5,a5,a0
    80005876:	0187c783          	lbu	a5,24(a5)
    8000587a:	e7b9                	bnez	a5,800058c8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000587c:	00451693          	slli	a3,a0,0x4
    80005880:	00243797          	auipc	a5,0x243
    80005884:	20078793          	addi	a5,a5,512 # 80248a80 <disk>
    80005888:	6398                	ld	a4,0(a5)
    8000588a:	9736                	add	a4,a4,a3
    8000588c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005890:	6398                	ld	a4,0(a5)
    80005892:	9736                	add	a4,a4,a3
    80005894:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005898:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000589c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058a0:	97aa                	add	a5,a5,a0
    800058a2:	4705                	li	a4,1
    800058a4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058a8:	00243517          	auipc	a0,0x243
    800058ac:	1f050513          	addi	a0,a0,496 # 80248a98 <disk+0x18>
    800058b0:	8ddfc0ef          	jal	ra,8000218c <wakeup>
}
    800058b4:	60a2                	ld	ra,8(sp)
    800058b6:	6402                	ld	s0,0(sp)
    800058b8:	0141                	addi	sp,sp,16
    800058ba:	8082                	ret
    panic("free_desc 1");
    800058bc:	00002517          	auipc	a0,0x2
    800058c0:	e7c50513          	addi	a0,a0,-388 # 80007738 <syscalls+0x340>
    800058c4:	ec5fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    800058c8:	00002517          	auipc	a0,0x2
    800058cc:	e8050513          	addi	a0,a0,-384 # 80007748 <syscalls+0x350>
    800058d0:	eb9fa0ef          	jal	ra,80000788 <panic>

00000000800058d4 <virtio_disk_init>:
{
    800058d4:	1101                	addi	sp,sp,-32
    800058d6:	ec06                	sd	ra,24(sp)
    800058d8:	e822                	sd	s0,16(sp)
    800058da:	e426                	sd	s1,8(sp)
    800058dc:	e04a                	sd	s2,0(sp)
    800058de:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058e0:	00002597          	auipc	a1,0x2
    800058e4:	e7858593          	addi	a1,a1,-392 # 80007758 <syscalls+0x360>
    800058e8:	00243517          	auipc	a0,0x243
    800058ec:	2c050513          	addi	a0,a0,704 # 80248ba8 <disk+0x128>
    800058f0:	b30fb0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058f4:	100017b7          	lui	a5,0x10001
    800058f8:	4398                	lw	a4,0(a5)
    800058fa:	2701                	sext.w	a4,a4
    800058fc:	747277b7          	lui	a5,0x74727
    80005900:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005904:	12f71f63          	bne	a4,a5,80005a42 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005908:	100017b7          	lui	a5,0x10001
    8000590c:	43dc                	lw	a5,4(a5)
    8000590e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005910:	4709                	li	a4,2
    80005912:	12e79863          	bne	a5,a4,80005a42 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005916:	100017b7          	lui	a5,0x10001
    8000591a:	479c                	lw	a5,8(a5)
    8000591c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000591e:	12e79263          	bne	a5,a4,80005a42 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005922:	100017b7          	lui	a5,0x10001
    80005926:	47d8                	lw	a4,12(a5)
    80005928:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000592a:	554d47b7          	lui	a5,0x554d4
    8000592e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005932:	10f71863          	bne	a4,a5,80005a42 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005936:	100017b7          	lui	a5,0x10001
    8000593a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000593e:	4705                	li	a4,1
    80005940:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005942:	470d                	li	a4,3
    80005944:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005946:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005948:	c7ffe6b7          	lui	a3,0xc7ffe
    8000594c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db5b9f>
    80005950:	8f75                	and	a4,a4,a3
    80005952:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005954:	472d                	li	a4,11
    80005956:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005958:	5bbc                	lw	a5,112(a5)
    8000595a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000595e:	8ba1                	andi	a5,a5,8
    80005960:	0e078763          	beqz	a5,80005a4e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005964:	100017b7          	lui	a5,0x10001
    80005968:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000596c:	43fc                	lw	a5,68(a5)
    8000596e:	2781                	sext.w	a5,a5
    80005970:	0e079563          	bnez	a5,80005a5a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005974:	100017b7          	lui	a5,0x10001
    80005978:	5bdc                	lw	a5,52(a5)
    8000597a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000597c:	0e078563          	beqz	a5,80005a66 <virtio_disk_init+0x192>
  if(max < NUM)
    80005980:	471d                	li	a4,7
    80005982:	0ef77863          	bgeu	a4,a5,80005a72 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80005986:	a24fb0ef          	jal	ra,80000baa <kalloc>
    8000598a:	00243497          	auipc	s1,0x243
    8000598e:	0f648493          	addi	s1,s1,246 # 80248a80 <disk>
    80005992:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005994:	a16fb0ef          	jal	ra,80000baa <kalloc>
    80005998:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000599a:	a10fb0ef          	jal	ra,80000baa <kalloc>
    8000599e:	87aa                	mv	a5,a0
    800059a0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800059a2:	6088                	ld	a0,0(s1)
    800059a4:	cd69                	beqz	a0,80005a7e <virtio_disk_init+0x1aa>
    800059a6:	00243717          	auipc	a4,0x243
    800059aa:	0e273703          	ld	a4,226(a4) # 80248a88 <disk+0x8>
    800059ae:	cb61                	beqz	a4,80005a7e <virtio_disk_init+0x1aa>
    800059b0:	c7f9                	beqz	a5,80005a7e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    800059b2:	6605                	lui	a2,0x1
    800059b4:	4581                	li	a1,0
    800059b6:	bbefb0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059ba:	00243497          	auipc	s1,0x243
    800059be:	0c648493          	addi	s1,s1,198 # 80248a80 <disk>
    800059c2:	6605                	lui	a2,0x1
    800059c4:	4581                	li	a1,0
    800059c6:	6488                	ld	a0,8(s1)
    800059c8:	bacfb0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    800059cc:	6605                	lui	a2,0x1
    800059ce:	4581                	li	a1,0
    800059d0:	6888                	ld	a0,16(s1)
    800059d2:	ba2fb0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059d6:	100017b7          	lui	a5,0x10001
    800059da:	4721                	li	a4,8
    800059dc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059de:	4098                	lw	a4,0(s1)
    800059e0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059e4:	40d8                	lw	a4,4(s1)
    800059e6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059ea:	6498                	ld	a4,8(s1)
    800059ec:	0007069b          	sext.w	a3,a4
    800059f0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059f4:	9701                	srai	a4,a4,0x20
    800059f6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059fa:	6898                	ld	a4,16(s1)
    800059fc:	0007069b          	sext.w	a3,a4
    80005a00:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a04:	9701                	srai	a4,a4,0x20
    80005a06:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a0a:	4705                	li	a4,1
    80005a0c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005a0e:	00e48c23          	sb	a4,24(s1)
    80005a12:	00e48ca3          	sb	a4,25(s1)
    80005a16:	00e48d23          	sb	a4,26(s1)
    80005a1a:	00e48da3          	sb	a4,27(s1)
    80005a1e:	00e48e23          	sb	a4,28(s1)
    80005a22:	00e48ea3          	sb	a4,29(s1)
    80005a26:	00e48f23          	sb	a4,30(s1)
    80005a2a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a2e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a32:	0727a823          	sw	s2,112(a5)
}
    80005a36:	60e2                	ld	ra,24(sp)
    80005a38:	6442                	ld	s0,16(sp)
    80005a3a:	64a2                	ld	s1,8(sp)
    80005a3c:	6902                	ld	s2,0(sp)
    80005a3e:	6105                	addi	sp,sp,32
    80005a40:	8082                	ret
    panic("could not find virtio disk");
    80005a42:	00002517          	auipc	a0,0x2
    80005a46:	d2650513          	addi	a0,a0,-730 # 80007768 <syscalls+0x370>
    80005a4a:	d3ffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a4e:	00002517          	auipc	a0,0x2
    80005a52:	d3a50513          	addi	a0,a0,-710 # 80007788 <syscalls+0x390>
    80005a56:	d33fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    80005a5a:	00002517          	auipc	a0,0x2
    80005a5e:	d4e50513          	addi	a0,a0,-690 # 800077a8 <syscalls+0x3b0>
    80005a62:	d27fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005a66:	00002517          	auipc	a0,0x2
    80005a6a:	d6250513          	addi	a0,a0,-670 # 800077c8 <syscalls+0x3d0>
    80005a6e:	d1bfa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005a72:	00002517          	auipc	a0,0x2
    80005a76:	d7650513          	addi	a0,a0,-650 # 800077e8 <syscalls+0x3f0>
    80005a7a:	d0ffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    80005a7e:	00002517          	auipc	a0,0x2
    80005a82:	d8a50513          	addi	a0,a0,-630 # 80007808 <syscalls+0x410>
    80005a86:	d03fa0ef          	jal	ra,80000788 <panic>

0000000080005a8a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a8a:	7119                	addi	sp,sp,-128
    80005a8c:	fc86                	sd	ra,120(sp)
    80005a8e:	f8a2                	sd	s0,112(sp)
    80005a90:	f4a6                	sd	s1,104(sp)
    80005a92:	f0ca                	sd	s2,96(sp)
    80005a94:	ecce                	sd	s3,88(sp)
    80005a96:	e8d2                	sd	s4,80(sp)
    80005a98:	e4d6                	sd	s5,72(sp)
    80005a9a:	e0da                	sd	s6,64(sp)
    80005a9c:	fc5e                	sd	s7,56(sp)
    80005a9e:	f862                	sd	s8,48(sp)
    80005aa0:	f466                	sd	s9,40(sp)
    80005aa2:	f06a                	sd	s10,32(sp)
    80005aa4:	ec6e                	sd	s11,24(sp)
    80005aa6:	0100                	addi	s0,sp,128
    80005aa8:	8aaa                	mv	s5,a0
    80005aaa:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005aac:	00c52d03          	lw	s10,12(a0)
    80005ab0:	001d1d1b          	slliw	s10,s10,0x1
    80005ab4:	1d02                	slli	s10,s10,0x20
    80005ab6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005aba:	00243517          	auipc	a0,0x243
    80005abe:	0ee50513          	addi	a0,a0,238 # 80248ba8 <disk+0x128>
    80005ac2:	9defb0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80005ac6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005ac8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005aca:	00243b97          	auipc	s7,0x243
    80005ace:	fb6b8b93          	addi	s7,s7,-74 # 80248a80 <disk>
  for(int i = 0; i < 3; i++){
    80005ad2:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ad4:	00243c97          	auipc	s9,0x243
    80005ad8:	0d4c8c93          	addi	s9,s9,212 # 80248ba8 <disk+0x128>
    80005adc:	a8a9                	j	80005b36 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005ade:	00fb8733          	add	a4,s7,a5
    80005ae2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ae6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ae8:	0207c563          	bltz	a5,80005b12 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005aec:	2905                	addiw	s2,s2,1
    80005aee:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005af0:	05690863          	beq	s2,s6,80005b40 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005af4:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005af6:	00243717          	auipc	a4,0x243
    80005afa:	f8a70713          	addi	a4,a4,-118 # 80248a80 <disk>
    80005afe:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005b00:	01874683          	lbu	a3,24(a4)
    80005b04:	fee9                	bnez	a3,80005ade <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005b06:	2785                	addiw	a5,a5,1
    80005b08:	0705                	addi	a4,a4,1
    80005b0a:	fe979be3          	bne	a5,s1,80005b00 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005b0e:	57fd                	li	a5,-1
    80005b10:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005b12:	01205b63          	blez	s2,80005b28 <virtio_disk_rw+0x9e>
    80005b16:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005b18:	000a2503          	lw	a0,0(s4)
    80005b1c:	d43ff0ef          	jal	ra,8000585e <free_desc>
      for(int j = 0; j < i; j++)
    80005b20:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80005b22:	0a11                	addi	s4,s4,4
    80005b24:	ff2d9ae3          	bne	s11,s2,80005b18 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b28:	85e6                	mv	a1,s9
    80005b2a:	00243517          	auipc	a0,0x243
    80005b2e:	f6e50513          	addi	a0,a0,-146 # 80248a98 <disk+0x18>
    80005b32:	e0efc0ef          	jal	ra,80002140 <sleep>
  for(int i = 0; i < 3; i++){
    80005b36:	f8040a13          	addi	s4,s0,-128
{
    80005b3a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005b3c:	894e                	mv	s2,s3
    80005b3e:	bf5d                	j	80005af4 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b40:	f8042503          	lw	a0,-128(s0)
    80005b44:	00a50713          	addi	a4,a0,10
    80005b48:	0712                	slli	a4,a4,0x4

  if(write)
    80005b4a:	00243797          	auipc	a5,0x243
    80005b4e:	f3678793          	addi	a5,a5,-202 # 80248a80 <disk>
    80005b52:	00e786b3          	add	a3,a5,a4
    80005b56:	01803633          	snez	a2,s8
    80005b5a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b5c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005b60:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b64:	f6070613          	addi	a2,a4,-160
    80005b68:	6394                	ld	a3,0(a5)
    80005b6a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b6c:	00870593          	addi	a1,a4,8
    80005b70:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b72:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b74:	0007b803          	ld	a6,0(a5)
    80005b78:	9642                	add	a2,a2,a6
    80005b7a:	46c1                	li	a3,16
    80005b7c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b7e:	4585                	li	a1,1
    80005b80:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005b84:	f8442683          	lw	a3,-124(s0)
    80005b88:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b8c:	0692                	slli	a3,a3,0x4
    80005b8e:	9836                	add	a6,a6,a3
    80005b90:	058a8613          	addi	a2,s5,88
    80005b94:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005b98:	0007b803          	ld	a6,0(a5)
    80005b9c:	96c2                	add	a3,a3,a6
    80005b9e:	40000613          	li	a2,1024
    80005ba2:	c690                	sw	a2,8(a3)
  if(write)
    80005ba4:	001c3613          	seqz	a2,s8
    80005ba8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bac:	00166613          	ori	a2,a2,1
    80005bb0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005bb4:	f8842603          	lw	a2,-120(s0)
    80005bb8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bbc:	00250693          	addi	a3,a0,2
    80005bc0:	0692                	slli	a3,a3,0x4
    80005bc2:	96be                	add	a3,a3,a5
    80005bc4:	58fd                	li	a7,-1
    80005bc6:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005bca:	0612                	slli	a2,a2,0x4
    80005bcc:	9832                	add	a6,a6,a2
    80005bce:	f9070713          	addi	a4,a4,-112
    80005bd2:	973e                	add	a4,a4,a5
    80005bd4:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005bd8:	6398                	ld	a4,0(a5)
    80005bda:	9732                	add	a4,a4,a2
    80005bdc:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005bde:	4609                	li	a2,2
    80005be0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005be4:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005be8:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005bec:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005bf0:	6794                	ld	a3,8(a5)
    80005bf2:	0026d703          	lhu	a4,2(a3)
    80005bf6:	8b1d                	andi	a4,a4,7
    80005bf8:	0706                	slli	a4,a4,0x1
    80005bfa:	96ba                	add	a3,a3,a4
    80005bfc:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c00:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c04:	6798                	ld	a4,8(a5)
    80005c06:	00275783          	lhu	a5,2(a4)
    80005c0a:	2785                	addiw	a5,a5,1
    80005c0c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c10:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c14:	100017b7          	lui	a5,0x10001
    80005c18:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c1c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005c20:	00243917          	auipc	s2,0x243
    80005c24:	f8890913          	addi	s2,s2,-120 # 80248ba8 <disk+0x128>
  while(b->disk == 1) {
    80005c28:	4485                	li	s1,1
    80005c2a:	00b79a63          	bne	a5,a1,80005c3e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005c2e:	85ca                	mv	a1,s2
    80005c30:	8556                	mv	a0,s5
    80005c32:	d0efc0ef          	jal	ra,80002140 <sleep>
  while(b->disk == 1) {
    80005c36:	004aa783          	lw	a5,4(s5)
    80005c3a:	fe978ae3          	beq	a5,s1,80005c2e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005c3e:	f8042903          	lw	s2,-128(s0)
    80005c42:	00290713          	addi	a4,s2,2
    80005c46:	0712                	slli	a4,a4,0x4
    80005c48:	00243797          	auipc	a5,0x243
    80005c4c:	e3878793          	addi	a5,a5,-456 # 80248a80 <disk>
    80005c50:	97ba                	add	a5,a5,a4
    80005c52:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c56:	00243997          	auipc	s3,0x243
    80005c5a:	e2a98993          	addi	s3,s3,-470 # 80248a80 <disk>
    80005c5e:	00491713          	slli	a4,s2,0x4
    80005c62:	0009b783          	ld	a5,0(s3)
    80005c66:	97ba                	add	a5,a5,a4
    80005c68:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c6c:	854a                	mv	a0,s2
    80005c6e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c72:	bedff0ef          	jal	ra,8000585e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c76:	8885                	andi	s1,s1,1
    80005c78:	f0fd                	bnez	s1,80005c5e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c7a:	00243517          	auipc	a0,0x243
    80005c7e:	f2e50513          	addi	a0,a0,-210 # 80248ba8 <disk+0x128>
    80005c82:	8b6fb0ef          	jal	ra,80000d38 <release>
}
    80005c86:	70e6                	ld	ra,120(sp)
    80005c88:	7446                	ld	s0,112(sp)
    80005c8a:	74a6                	ld	s1,104(sp)
    80005c8c:	7906                	ld	s2,96(sp)
    80005c8e:	69e6                	ld	s3,88(sp)
    80005c90:	6a46                	ld	s4,80(sp)
    80005c92:	6aa6                	ld	s5,72(sp)
    80005c94:	6b06                	ld	s6,64(sp)
    80005c96:	7be2                	ld	s7,56(sp)
    80005c98:	7c42                	ld	s8,48(sp)
    80005c9a:	7ca2                	ld	s9,40(sp)
    80005c9c:	7d02                	ld	s10,32(sp)
    80005c9e:	6de2                	ld	s11,24(sp)
    80005ca0:	6109                	addi	sp,sp,128
    80005ca2:	8082                	ret

0000000080005ca4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ca4:	1101                	addi	sp,sp,-32
    80005ca6:	ec06                	sd	ra,24(sp)
    80005ca8:	e822                	sd	s0,16(sp)
    80005caa:	e426                	sd	s1,8(sp)
    80005cac:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005cae:	00243497          	auipc	s1,0x243
    80005cb2:	dd248493          	addi	s1,s1,-558 # 80248a80 <disk>
    80005cb6:	00243517          	auipc	a0,0x243
    80005cba:	ef250513          	addi	a0,a0,-270 # 80248ba8 <disk+0x128>
    80005cbe:	fe3fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005cc2:	10001737          	lui	a4,0x10001
    80005cc6:	533c                	lw	a5,96(a4)
    80005cc8:	8b8d                	andi	a5,a5,3
    80005cca:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005ccc:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005cd0:	689c                	ld	a5,16(s1)
    80005cd2:	0204d703          	lhu	a4,32(s1)
    80005cd6:	0027d783          	lhu	a5,2(a5)
    80005cda:	04f70663          	beq	a4,a5,80005d26 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005cde:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ce2:	6898                	ld	a4,16(s1)
    80005ce4:	0204d783          	lhu	a5,32(s1)
    80005ce8:	8b9d                	andi	a5,a5,7
    80005cea:	078e                	slli	a5,a5,0x3
    80005cec:	97ba                	add	a5,a5,a4
    80005cee:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005cf0:	00278713          	addi	a4,a5,2
    80005cf4:	0712                	slli	a4,a4,0x4
    80005cf6:	9726                	add	a4,a4,s1
    80005cf8:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005cfc:	e321                	bnez	a4,80005d3c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cfe:	0789                	addi	a5,a5,2
    80005d00:	0792                	slli	a5,a5,0x4
    80005d02:	97a6                	add	a5,a5,s1
    80005d04:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d06:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d0a:	c82fc0ef          	jal	ra,8000218c <wakeup>

    disk.used_idx += 1;
    80005d0e:	0204d783          	lhu	a5,32(s1)
    80005d12:	2785                	addiw	a5,a5,1
    80005d14:	17c2                	slli	a5,a5,0x30
    80005d16:	93c1                	srli	a5,a5,0x30
    80005d18:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d1c:	6898                	ld	a4,16(s1)
    80005d1e:	00275703          	lhu	a4,2(a4)
    80005d22:	faf71ee3          	bne	a4,a5,80005cde <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005d26:	00243517          	auipc	a0,0x243
    80005d2a:	e8250513          	addi	a0,a0,-382 # 80248ba8 <disk+0x128>
    80005d2e:	80afb0ef          	jal	ra,80000d38 <release>
}
    80005d32:	60e2                	ld	ra,24(sp)
    80005d34:	6442                	ld	s0,16(sp)
    80005d36:	64a2                	ld	s1,8(sp)
    80005d38:	6105                	addi	sp,sp,32
    80005d3a:	8082                	ret
      panic("virtio_disk_intr status");
    80005d3c:	00002517          	auipc	a0,0x2
    80005d40:	ae450513          	addi	a0,a0,-1308 # 80007820 <syscalls+0x428>
    80005d44:	a45fa0ef          	jal	ra,80000788 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
