
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
    8000010a:	40c020ef          	jal	ra,80002516 <either_copyin>
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
    800001a4:	15f010ef          	jal	ra,80001b02 <myproc>
    800001a8:	200020ef          	jal	ra,800023a8 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	7bf010ef          	jal	ra,80002170 <sleep>
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
    800001ea:	2e2020ef          	jal	ra,800024cc <either_copyout>
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
    800002aa:	2b6020ef          	jal	ra,80002560 <procdump>
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
    800003e6:	5d7010ef          	jal	ra,800021bc <wakeup>
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
    80000892:	0df010ef          	jal	ra,80002170 <sleep>
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
    8000099c:	021010ef          	jal	ra,800021bc <wakeup>
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
    80000c4a:	69d000ef          	jal	ra,80001ae6 <mycpu>
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
    80000c78:	66f000ef          	jal	ra,80001ae6 <mycpu>
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	cb99                	beqz	a5,80000c94 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c80:	667000ef          	jal	ra,80001ae6 <mycpu>
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
    80000c94:	653000ef          	jal	ra,80001ae6 <mycpu>
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
    80000cc8:	61f000ef          	jal	ra,80001ae6 <mycpu>
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
    80000cec:	5fb000ef          	jal	ra,80001ae6 <mycpu>
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
    80000f1e:	3b9000ef          	jal	ra,80001ad6 <cpuid>
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
    80000f36:	3a1000ef          	jal	ra,80001ad6 <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17c50513          	addi	a0,a0,380 # 800070b8 <digits+0x80>
    80000f44:	d7eff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f48:	080000ef          	jal	ra,80000fc8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	746010ef          	jal	ra,80002692 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	105040ef          	jal	ra,80005854 <plicinithart>
  }

  scheduler();        
    80000f54:	084010ef          	jal	ra,80001fd8 <scheduler>
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
    80000f90:	29f000ef          	jal	ra,80001a2e <procinit>
    trapinit();      // trap vectors
    80000f94:	6da010ef          	jal	ra,8000266e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	6fa010ef          	jal	ra,80002692 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	0a3040ef          	jal	ra,8000583e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	0b5040ef          	jal	ra,80005854 <plicinithart>
    binit();         // buffer cache
    80000fa4:	7fd010ef          	jal	ra,80002fa0 <binit>
    iinit();         // inode table
    80000fa8:	56c020ef          	jal	ra,80003514 <iinit>
    fileinit();      // file table
    80000fac:	454030ef          	jal	ra,80004400 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	195040ef          	jal	ra,80005944 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	67b000ef          	jal	ra,80001e2e <userinit>
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
    80001240:	764000ef          	jal	ra,800019a4 <proc_mapstacks>
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
    80001700:	402000ef          	jal	ra,80001b02 <myproc>
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
    800018ee:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va);
    800018f2:	85ce                	mv	a1,s3
    800018f4:	464010ef          	jal	ra,80002d58 <vma_find>
  if(v == 0) return 0;
    800018f8:	c145                	beqz	a0,80001998 <vmafault+0xc2>
    800018fa:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    800018fc:	00090663          	beqz	s2,80001908 <vmafault+0x32>
    80001900:	4d1c                	lw	a5,24(a0)
    80001902:	8b89                	andi	a5,a5,2
    return 0;
    80001904:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001906:	c789                	beqz	a5,80001910 <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0)
    80001908:	4c9c                	lw	a5,24(s1)
    8000190a:	8b85                	andi	a5,a5,1
    return 0;
    8000190c:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0)
    8000190e:	eb99                	bnez	a5,80001924 <vmafault+0x4e>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, perm) != 0){
    kfree(mem);
    return 0;
  }
  return (uint64)mem;
}
    80001910:	854a                	mv	a0,s2
    80001912:	70e2                	ld	ra,56(sp)
    80001914:	7442                	ld	s0,48(sp)
    80001916:	74a2                	ld	s1,40(sp)
    80001918:	7902                	ld	s2,32(sp)
    8000191a:	69e2                	ld	s3,24(sp)
    8000191c:	6a42                	ld	s4,16(sp)
    8000191e:	6aa2                	ld	s5,8(sp)
    80001920:	6121                	addi	sp,sp,64
    80001922:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    80001924:	4601                	li	a2,0
    80001926:	85ce                	mv	a1,s3
    80001928:	050a3503          	ld	a0,80(s4)
    8000192c:	ec4ff0ef          	jal	ra,80000ff0 <walk>
  if(pte && (*pte & PTE_V)){
    80001930:	c115                	beqz	a0,80001954 <vmafault+0x7e>
    80001932:	611c                	ld	a5,0(a0)
    80001934:	0017f913          	andi	s2,a5,1
    80001938:	00090e63          	beqz	s2,80001954 <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    8000193c:	4c98                	lw	a4,24(s1)
    8000193e:	8b09                	andi	a4,a4,2
    80001940:	cf31                	beqz	a4,8000199c <vmafault+0xc6>
    80001942:	0047f713          	andi	a4,a5,4
    80001946:	ef29                	bnez	a4,800019a0 <vmafault+0xca>
      *pte |= PTE_W;
    80001948:	0047e793          	ori	a5,a5,4
    8000194c:	e11c                	sd	a5,0(a0)
    8000194e:	12000073          	sfence.vma
      return 1;
    80001952:	bf7d                	j	80001910 <vmafault+0x3a>
  if(v->prot & PROT_READ)  perm |= PTE_R;
    80001954:	4c9c                	lw	a5,24(s1)
    80001956:	0017f713          	andi	a4,a5,1
  int perm = PTE_U;
    8000195a:	4ac1                	li	s5,16
  if(v->prot & PROT_READ)  perm |= PTE_R;
    8000195c:	c311                	beqz	a4,80001960 <vmafault+0x8a>
    8000195e:	4ac9                	li	s5,18
  if(v->prot & PROT_WRITE) perm |= PTE_W;
    80001960:	8b89                	andi	a5,a5,2
    80001962:	c399                	beqz	a5,80001968 <vmafault+0x92>
    80001964:	004aea93          	ori	s5,s5,4
  char *mem = kalloc();
    80001968:	a42ff0ef          	jal	ra,80000baa <kalloc>
    8000196c:	84aa                	mv	s1,a0
  if(mem == 0) return 0;
    8000196e:	4901                	li	s2,0
    80001970:	d145                	beqz	a0,80001910 <vmafault+0x3a>
  memset(mem, 0, PGSIZE);
    80001972:	6605                	lui	a2,0x1
    80001974:	4581                	li	a1,0
    80001976:	bfeff0ef          	jal	ra,80000d74 <memset>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, perm) != 0){
    8000197a:	8926                	mv	s2,s1
    8000197c:	8756                	mv	a4,s5
    8000197e:	86a6                	mv	a3,s1
    80001980:	6605                	lui	a2,0x1
    80001982:	85ce                	mv	a1,s3
    80001984:	050a3503          	ld	a0,80(s4)
    80001988:	f40ff0ef          	jal	ra,800010c8 <mappages>
    8000198c:	d151                	beqz	a0,80001910 <vmafault+0x3a>
    kfree(mem);
    8000198e:	8526                	mv	a0,s1
    80001990:	8eaff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    80001994:	4901                	li	s2,0
    80001996:	bfad                	j	80001910 <vmafault+0x3a>
  if(v == 0) return 0;
    80001998:	4901                	li	s2,0
    8000199a:	bf9d                	j	80001910 <vmafault+0x3a>
    return 0;
    8000199c:	4901                	li	s2,0
    8000199e:	bf8d                	j	80001910 <vmafault+0x3a>
    800019a0:	4901                	li	s2,0
    800019a2:	b7bd                	j	80001910 <vmafault+0x3a>

00000000800019a4 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800019a4:	7139                	addi	sp,sp,-64
    800019a6:	fc06                	sd	ra,56(sp)
    800019a8:	f822                	sd	s0,48(sp)
    800019aa:	f426                	sd	s1,40(sp)
    800019ac:	f04a                	sd	s2,32(sp)
    800019ae:	ec4e                	sd	s3,24(sp)
    800019b0:	e852                	sd	s4,16(sp)
    800019b2:	e456                	sd	s5,8(sp)
    800019b4:	e05a                	sd	s6,0(sp)
    800019b6:	0080                	addi	s0,sp,64
    800019b8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ba:	0022e497          	auipc	s1,0x22e
    800019be:	42648493          	addi	s1,s1,1062 # 8022fde0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800019c2:	8b26                	mv	s6,s1
    800019c4:	00005a97          	auipc	s5,0x5
    800019c8:	63ca8a93          	addi	s5,s5,1596 # 80007000 <etext>
    800019cc:	04000937          	lui	s2,0x4000
    800019d0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	0023ca17          	auipc	s4,0x23c
    800019d8:	e0ca0a13          	addi	s4,s4,-500 # 8023d7e0 <tickslock>
    char *pa = kalloc();
    800019dc:	9ceff0ef          	jal	ra,80000baa <kalloc>
    800019e0:	862a                	mv	a2,a0
    if(pa == 0)
    800019e2:	c121                	beqz	a0,80001a22 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800019e4:	416485b3          	sub	a1,s1,s6
    800019e8:	858d                	srai	a1,a1,0x3
    800019ea:	000ab783          	ld	a5,0(s5)
    800019ee:	02f585b3          	mul	a1,a1,a5
    800019f2:	2585                	addiw	a1,a1,1
    800019f4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019f8:	4719                	li	a4,6
    800019fa:	6685                	lui	a3,0x1
    800019fc:	40b905b3          	sub	a1,s2,a1
    80001a00:	854e                	mv	a0,s3
    80001a02:	f76ff0ef          	jal	ra,80001178 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a06:	36848493          	addi	s1,s1,872
    80001a0a:	fd4499e3          	bne	s1,s4,800019dc <proc_mapstacks+0x38>
  }
}
    80001a0e:	70e2                	ld	ra,56(sp)
    80001a10:	7442                	ld	s0,48(sp)
    80001a12:	74a2                	ld	s1,40(sp)
    80001a14:	7902                	ld	s2,32(sp)
    80001a16:	69e2                	ld	s3,24(sp)
    80001a18:	6a42                	ld	s4,16(sp)
    80001a1a:	6aa2                	ld	s5,8(sp)
    80001a1c:	6b02                	ld	s6,0(sp)
    80001a1e:	6121                	addi	sp,sp,64
    80001a20:	8082                	ret
      panic("kalloc");
    80001a22:	00005517          	auipc	a0,0x5
    80001a26:	75650513          	addi	a0,a0,1878 # 80007178 <digits+0x140>
    80001a2a:	d5ffe0ef          	jal	ra,80000788 <panic>

0000000080001a2e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a2e:	7139                	addi	sp,sp,-64
    80001a30:	fc06                	sd	ra,56(sp)
    80001a32:	f822                	sd	s0,48(sp)
    80001a34:	f426                	sd	s1,40(sp)
    80001a36:	f04a                	sd	s2,32(sp)
    80001a38:	ec4e                	sd	s3,24(sp)
    80001a3a:	e852                	sd	s4,16(sp)
    80001a3c:	e456                	sd	s5,8(sp)
    80001a3e:	e05a                	sd	s6,0(sp)
    80001a40:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a42:	00005597          	auipc	a1,0x5
    80001a46:	73e58593          	addi	a1,a1,1854 # 80007180 <digits+0x148>
    80001a4a:	0022e517          	auipc	a0,0x22e
    80001a4e:	f6650513          	addi	a0,a0,-154 # 8022f9b0 <pid_lock>
    80001a52:	9ceff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a56:	00005597          	auipc	a1,0x5
    80001a5a:	73258593          	addi	a1,a1,1842 # 80007188 <digits+0x150>
    80001a5e:	0022e517          	auipc	a0,0x22e
    80001a62:	f6a50513          	addi	a0,a0,-150 # 8022f9c8 <wait_lock>
    80001a66:	9baff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a6a:	0022e497          	auipc	s1,0x22e
    80001a6e:	37648493          	addi	s1,s1,886 # 8022fde0 <proc>
      initlock(&p->lock, "proc");
    80001a72:	00005b17          	auipc	s6,0x5
    80001a76:	726b0b13          	addi	s6,s6,1830 # 80007198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001a7a:	8aa6                	mv	s5,s1
    80001a7c:	00005a17          	auipc	s4,0x5
    80001a80:	584a0a13          	addi	s4,s4,1412 # 80007000 <etext>
    80001a84:	04000937          	lui	s2,0x4000
    80001a88:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a8a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a8c:	0023c997          	auipc	s3,0x23c
    80001a90:	d5498993          	addi	s3,s3,-684 # 8023d7e0 <tickslock>
      initlock(&p->lock, "proc");
    80001a94:	85da                	mv	a1,s6
    80001a96:	8526                	mv	a0,s1
    80001a98:	988ff0ef          	jal	ra,80000c20 <initlock>
      p->state = UNUSED;
    80001a9c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001aa0:	415487b3          	sub	a5,s1,s5
    80001aa4:	878d                	srai	a5,a5,0x3
    80001aa6:	000a3703          	ld	a4,0(s4)
    80001aaa:	02e787b3          	mul	a5,a5,a4
    80001aae:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdb6441>
    80001ab0:	00d7979b          	slliw	a5,a5,0xd
    80001ab4:	40f907b3          	sub	a5,s2,a5
    80001ab8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aba:	36848493          	addi	s1,s1,872
    80001abe:	fd349be3          	bne	s1,s3,80001a94 <procinit+0x66>
  }
}
    80001ac2:	70e2                	ld	ra,56(sp)
    80001ac4:	7442                	ld	s0,48(sp)
    80001ac6:	74a2                	ld	s1,40(sp)
    80001ac8:	7902                	ld	s2,32(sp)
    80001aca:	69e2                	ld	s3,24(sp)
    80001acc:	6a42                	ld	s4,16(sp)
    80001ace:	6aa2                	ld	s5,8(sp)
    80001ad0:	6b02                	ld	s6,0(sp)
    80001ad2:	6121                	addi	sp,sp,64
    80001ad4:	8082                	ret

0000000080001ad6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001ad6:	1141                	addi	sp,sp,-16
    80001ad8:	e422                	sd	s0,8(sp)
    80001ada:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001adc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ade:	2501                	sext.w	a0,a0
    80001ae0:	6422                	ld	s0,8(sp)
    80001ae2:	0141                	addi	sp,sp,16
    80001ae4:	8082                	ret

0000000080001ae6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001ae6:	1141                	addi	sp,sp,-16
    80001ae8:	e422                	sd	s0,8(sp)
    80001aea:	0800                	addi	s0,sp,16
    80001aec:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001aee:	2781                	sext.w	a5,a5
    80001af0:	079e                	slli	a5,a5,0x7
  return c;
}
    80001af2:	0022e517          	auipc	a0,0x22e
    80001af6:	eee50513          	addi	a0,a0,-274 # 8022f9e0 <cpus>
    80001afa:	953e                	add	a0,a0,a5
    80001afc:	6422                	ld	s0,8(sp)
    80001afe:	0141                	addi	sp,sp,16
    80001b00:	8082                	ret

0000000080001b02 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	1000                	addi	s0,sp,32
  push_off();
    80001b0c:	954ff0ef          	jal	ra,80000c60 <push_off>
    80001b10:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b12:	2781                	sext.w	a5,a5
    80001b14:	079e                	slli	a5,a5,0x7
    80001b16:	0022e717          	auipc	a4,0x22e
    80001b1a:	e9a70713          	addi	a4,a4,-358 # 8022f9b0 <pid_lock>
    80001b1e:	97ba                	add	a5,a5,a4
    80001b20:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b22:	9c2ff0ef          	jal	ra,80000ce4 <pop_off>
  return p;
}
    80001b26:	8526                	mv	a0,s1
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret

0000000080001b32 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b32:	7179                	addi	sp,sp,-48
    80001b34:	f406                	sd	ra,40(sp)
    80001b36:	f022                	sd	s0,32(sp)
    80001b38:	ec26                	sd	s1,24(sp)
    80001b3a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b3c:	fc7ff0ef          	jal	ra,80001b02 <myproc>
    80001b40:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b42:	9f6ff0ef          	jal	ra,80000d38 <release>

  if (first) {
    80001b46:	00006797          	auipc	a5,0x6
    80001b4a:	cfa7a783          	lw	a5,-774(a5) # 80007840 <first.1>
    80001b4e:	cf8d                	beqz	a5,80001b88 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b50:	4505                	li	a0,1
    80001b52:	675010ef          	jal	ra,800039c6 <fsinit>

    first = 0;
    80001b56:	00006797          	auipc	a5,0x6
    80001b5a:	ce07a523          	sw	zero,-790(a5) # 80007840 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b5e:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b62:	00005517          	auipc	a0,0x5
    80001b66:	63e50513          	addi	a0,a0,1598 # 800071a0 <digits+0x168>
    80001b6a:	fca43823          	sd	a0,-48(s0)
    80001b6e:	fc043c23          	sd	zero,-40(s0)
    80001b72:	fd040593          	addi	a1,s0,-48
    80001b76:	6ff020ef          	jal	ra,80004a74 <kexec>
    80001b7a:	6cbc                	ld	a5,88(s1)
    80001b7c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b7e:	6cbc                	ld	a5,88(s1)
    80001b80:	7bb8                	ld	a4,112(a5)
    80001b82:	57fd                	li	a5,-1
    80001b84:	02f70d63          	beq	a4,a5,80001bbe <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b88:	323000ef          	jal	ra,800026aa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b8c:	68a8                	ld	a0,80(s1)
    80001b8e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b90:	04000737          	lui	a4,0x4000
    80001b94:	00004797          	auipc	a5,0x4
    80001b98:	50878793          	addi	a5,a5,1288 # 8000609c <userret>
    80001b9c:	00004697          	auipc	a3,0x4
    80001ba0:	46468693          	addi	a3,a3,1124 # 80006000 <_trampoline>
    80001ba4:	8f95                	sub	a5,a5,a3
    80001ba6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001ba8:	0732                	slli	a4,a4,0xc
    80001baa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001bac:	577d                	li	a4,-1
    80001bae:	177e                	slli	a4,a4,0x3f
    80001bb0:	8d59                	or	a0,a0,a4
    80001bb2:	9782                	jalr	a5
}
    80001bb4:	70a2                	ld	ra,40(sp)
    80001bb6:	7402                	ld	s0,32(sp)
    80001bb8:	64e2                	ld	s1,24(sp)
    80001bba:	6145                	addi	sp,sp,48
    80001bbc:	8082                	ret
      panic("exec");
    80001bbe:	00005517          	auipc	a0,0x5
    80001bc2:	5ea50513          	addi	a0,a0,1514 # 800071a8 <digits+0x170>
    80001bc6:	bc3fe0ef          	jal	ra,80000788 <panic>

0000000080001bca <allocpid>:
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	e04a                	sd	s2,0(sp)
    80001bd4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bd6:	0022e917          	auipc	s2,0x22e
    80001bda:	dda90913          	addi	s2,s2,-550 # 8022f9b0 <pid_lock>
    80001bde:	854a                	mv	a0,s2
    80001be0:	8c0ff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001be4:	00006797          	auipc	a5,0x6
    80001be8:	c6078793          	addi	a5,a5,-928 # 80007844 <nextpid>
    80001bec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bee:	0014871b          	addiw	a4,s1,1
    80001bf2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bf4:	854a                	mv	a0,s2
    80001bf6:	942ff0ef          	jal	ra,80000d38 <release>
}
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	60e2                	ld	ra,24(sp)
    80001bfe:	6442                	ld	s0,16(sp)
    80001c00:	64a2                	ld	s1,8(sp)
    80001c02:	6902                	ld	s2,0(sp)
    80001c04:	6105                	addi	sp,sp,32
    80001c06:	8082                	ret

0000000080001c08 <proc_pagetable>:
{
    80001c08:	1101                	addi	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	e04a                	sd	s2,0(sp)
    80001c12:	1000                	addi	s0,sp,32
    80001c14:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c16:	e58ff0ef          	jal	ra,8000126e <uvmcreate>
    80001c1a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c1c:	cd05                	beqz	a0,80001c54 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c1e:	4729                	li	a4,10
    80001c20:	00004697          	auipc	a3,0x4
    80001c24:	3e068693          	addi	a3,a3,992 # 80006000 <_trampoline>
    80001c28:	6605                	lui	a2,0x1
    80001c2a:	040005b7          	lui	a1,0x4000
    80001c2e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c30:	05b2                	slli	a1,a1,0xc
    80001c32:	c96ff0ef          	jal	ra,800010c8 <mappages>
    80001c36:	02054663          	bltz	a0,80001c62 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c3a:	4719                	li	a4,6
    80001c3c:	05893683          	ld	a3,88(s2)
    80001c40:	6605                	lui	a2,0x1
    80001c42:	020005b7          	lui	a1,0x2000
    80001c46:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c48:	05b6                	slli	a1,a1,0xd
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	c7cff0ef          	jal	ra,800010c8 <mappages>
    80001c50:	00054f63          	bltz	a0,80001c6e <proc_pagetable+0x66>
}
    80001c54:	8526                	mv	a0,s1
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret
    uvmfree(pagetable, 0);
    80001c62:	4581                	li	a1,0
    80001c64:	8526                	mv	a0,s1
    80001c66:	fe8ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001c6a:	4481                	li	s1,0
    80001c6c:	b7e5                	j	80001c54 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c6e:	4681                	li	a3,0
    80001c70:	4605                	li	a2,1
    80001c72:	040005b7          	lui	a1,0x4000
    80001c76:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c78:	05b2                	slli	a1,a1,0xc
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	e18ff0ef          	jal	ra,80001294 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c80:	4581                	li	a1,0
    80001c82:	8526                	mv	a0,s1
    80001c84:	fcaff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001c88:	4481                	li	s1,0
    80001c8a:	b7e9                	j	80001c54 <proc_pagetable+0x4c>

0000000080001c8c <vma_unmap_pagetable>:
{
    80001c8c:	7179                	addi	sp,sp,-48
    80001c8e:	f406                	sd	ra,40(sp)
    80001c90:	f022                	sd	s0,32(sp)
    80001c92:	ec26                	sd	s1,24(sp)
    80001c94:	e84a                	sd	s2,16(sp)
    80001c96:	e44e                	sd	s3,8(sp)
    80001c98:	1800                	addi	s0,sp,48
    80001c9a:	89aa                	mv	s3,a0
    80001c9c:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001c9e:	20058913          	addi	s2,a1,512
    80001ca2:	a811                	j	80001cb6 <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001ca4:	4685                	li	a3,1
    80001ca6:	8231                	srli	a2,a2,0xc
    80001ca8:	854e                	mv	a0,s3
    80001caa:	deaff0ef          	jal	ra,80001294 <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001cae:	02048493          	addi	s1,s1,32
    80001cb2:	01248b63          	beq	s1,s2,80001cc8 <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001cb6:	409c                	lw	a5,0(s1)
    80001cb8:	dbfd                	beqz	a5,80001cae <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001cba:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001cbc:	689c                	ld	a5,16(s1)
    80001cbe:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001cc2:	feb786e3          	beq	a5,a1,80001cae <vma_unmap_pagetable+0x22>
    80001cc6:	bff9                	j	80001ca4 <vma_unmap_pagetable+0x18>
}
    80001cc8:	70a2                	ld	ra,40(sp)
    80001cca:	7402                	ld	s0,32(sp)
    80001ccc:	64e2                	ld	s1,24(sp)
    80001cce:	6942                	ld	s2,16(sp)
    80001cd0:	69a2                	ld	s3,8(sp)
    80001cd2:	6145                	addi	sp,sp,48
    80001cd4:	8082                	ret

0000000080001cd6 <proc_freepagetable>:
{
    80001cd6:	1101                	addi	sp,sp,-32
    80001cd8:	ec06                	sd	ra,24(sp)
    80001cda:	e822                	sd	s0,16(sp)
    80001cdc:	e426                	sd	s1,8(sp)
    80001cde:	e04a                	sd	s2,0(sp)
    80001ce0:	1000                	addi	s0,sp,32
    80001ce2:	84aa                	mv	s1,a0
    80001ce4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ce6:	4681                	li	a3,0
    80001ce8:	4605                	li	a2,1
    80001cea:	040005b7          	lui	a1,0x4000
    80001cee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cf0:	05b2                	slli	a1,a1,0xc
    80001cf2:	da2ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cf6:	4681                	li	a3,0
    80001cf8:	4605                	li	a2,1
    80001cfa:	020005b7          	lui	a1,0x2000
    80001cfe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d00:	05b6                	slli	a1,a1,0xd
    80001d02:	8526                	mv	a0,s1
    80001d04:	d90ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d08:	85ca                	mv	a1,s2
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	f42ff0ef          	jal	ra,8000144e <uvmfree>
}
    80001d10:	60e2                	ld	ra,24(sp)
    80001d12:	6442                	ld	s0,16(sp)
    80001d14:	64a2                	ld	s1,8(sp)
    80001d16:	6902                	ld	s2,0(sp)
    80001d18:	6105                	addi	sp,sp,32
    80001d1a:	8082                	ret

0000000080001d1c <freeproc>:
{
    80001d1c:	1101                	addi	sp,sp,-32
    80001d1e:	ec06                	sd	ra,24(sp)
    80001d20:	e822                	sd	s0,16(sp)
    80001d22:	e426                	sd	s1,8(sp)
    80001d24:	e04a                	sd	s2,0(sp)
    80001d26:	1000                	addi	s0,sp,32
    80001d28:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d2a:	6d28                	ld	a0,88(a0)
    80001d2c:	c119                	beqz	a0,80001d32 <freeproc+0x16>
    kfree((void*)p->trapframe);
    80001d2e:	d4dfe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001d32:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001d36:	68a8                	ld	a0,80(s1)
    80001d38:	c105                	beqz	a0,80001d58 <freeproc+0x3c>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001d3a:	16848913          	addi	s2,s1,360
    80001d3e:	85ca                	mv	a1,s2
    80001d40:	f4dff0ef          	jal	ra,80001c8c <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001d44:	20000613          	li	a2,512
    80001d48:	4581                	li	a1,0
    80001d4a:	854a                	mv	a0,s2
    80001d4c:	828ff0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001d50:	64ac                	ld	a1,72(s1)
    80001d52:	68a8                	ld	a0,80(s1)
    80001d54:	f83ff0ef          	jal	ra,80001cd6 <proc_freepagetable>
  p->pagetable = 0;
    80001d58:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d5c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d60:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d64:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d68:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d6c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d70:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d74:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d78:	0004ac23          	sw	zero,24(s1)
}
    80001d7c:	60e2                	ld	ra,24(sp)
    80001d7e:	6442                	ld	s0,16(sp)
    80001d80:	64a2                	ld	s1,8(sp)
    80001d82:	6902                	ld	s2,0(sp)
    80001d84:	6105                	addi	sp,sp,32
    80001d86:	8082                	ret

0000000080001d88 <allocproc>:
{
    80001d88:	1101                	addi	sp,sp,-32
    80001d8a:	ec06                	sd	ra,24(sp)
    80001d8c:	e822                	sd	s0,16(sp)
    80001d8e:	e426                	sd	s1,8(sp)
    80001d90:	e04a                	sd	s2,0(sp)
    80001d92:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d94:	0022e497          	auipc	s1,0x22e
    80001d98:	04c48493          	addi	s1,s1,76 # 8022fde0 <proc>
    80001d9c:	0023c917          	auipc	s2,0x23c
    80001da0:	a4490913          	addi	s2,s2,-1468 # 8023d7e0 <tickslock>
    acquire(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	efbfe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001daa:	4c9c                	lw	a5,24(s1)
    80001dac:	cb91                	beqz	a5,80001dc0 <allocproc+0x38>
      release(&p->lock);
    80001dae:	8526                	mv	a0,s1
    80001db0:	f89fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001db4:	36848493          	addi	s1,s1,872
    80001db8:	ff2496e3          	bne	s1,s2,80001da4 <allocproc+0x1c>
  return 0;
    80001dbc:	4481                	li	s1,0
    80001dbe:	a089                	j	80001e00 <allocproc+0x78>
  p->pid = allocpid();
    80001dc0:	e0bff0ef          	jal	ra,80001bca <allocpid>
    80001dc4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001dc6:	4785                	li	a5,1
    80001dc8:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001dca:	de1fe0ef          	jal	ra,80000baa <kalloc>
    80001dce:	892a                	mv	s2,a0
    80001dd0:	eca8                	sd	a0,88(s1)
    80001dd2:	cd15                	beqz	a0,80001e0e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	e33ff0ef          	jal	ra,80001c08 <proc_pagetable>
    80001dda:	892a                	mv	s2,a0
    80001ddc:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001dde:	c121                	beqz	a0,80001e1e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001de0:	07000613          	li	a2,112
    80001de4:	4581                	li	a1,0
    80001de6:	06048513          	addi	a0,s1,96
    80001dea:	f8bfe0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001dee:	00000797          	auipc	a5,0x0
    80001df2:	d4478793          	addi	a5,a5,-700 # 80001b32 <forkret>
    80001df6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001df8:	60bc                	ld	a5,64(s1)
    80001dfa:	6705                	lui	a4,0x1
    80001dfc:	97ba                	add	a5,a5,a4
    80001dfe:	f4bc                	sd	a5,104(s1)
}
    80001e00:	8526                	mv	a0,s1
    80001e02:	60e2                	ld	ra,24(sp)
    80001e04:	6442                	ld	s0,16(sp)
    80001e06:	64a2                	ld	s1,8(sp)
    80001e08:	6902                	ld	s2,0(sp)
    80001e0a:	6105                	addi	sp,sp,32
    80001e0c:	8082                	ret
    freeproc(p);
    80001e0e:	8526                	mv	a0,s1
    80001e10:	f0dff0ef          	jal	ra,80001d1c <freeproc>
    release(&p->lock);
    80001e14:	8526                	mv	a0,s1
    80001e16:	f23fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001e1a:	84ca                	mv	s1,s2
    80001e1c:	b7d5                	j	80001e00 <allocproc+0x78>
    freeproc(p);
    80001e1e:	8526                	mv	a0,s1
    80001e20:	efdff0ef          	jal	ra,80001d1c <freeproc>
    release(&p->lock);
    80001e24:	8526                	mv	a0,s1
    80001e26:	f13fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001e2a:	84ca                	mv	s1,s2
    80001e2c:	bfd1                	j	80001e00 <allocproc+0x78>

0000000080001e2e <userinit>:
{
    80001e2e:	1101                	addi	sp,sp,-32
    80001e30:	ec06                	sd	ra,24(sp)
    80001e32:	e822                	sd	s0,16(sp)
    80001e34:	e426                	sd	s1,8(sp)
    80001e36:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e38:	f51ff0ef          	jal	ra,80001d88 <allocproc>
    80001e3c:	84aa                	mv	s1,a0
  initproc = p;
    80001e3e:	00006797          	auipc	a5,0x6
    80001e42:	a4a7b923          	sd	a0,-1454(a5) # 80007890 <initproc>
  p->cwd = namei("/");
    80001e46:	00005517          	auipc	a0,0x5
    80001e4a:	36a50513          	addi	a0,a0,874 # 800071b0 <digits+0x178>
    80001e4e:	07c020ef          	jal	ra,80003eca <namei>
    80001e52:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e56:	478d                	li	a5,3
    80001e58:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	eddfe0ef          	jal	ra,80000d38 <release>
}
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6105                	addi	sp,sp,32
    80001e68:	8082                	ret

0000000080001e6a <growproc>:
{
    80001e6a:	1101                	addi	sp,sp,-32
    80001e6c:	ec06                	sd	ra,24(sp)
    80001e6e:	e822                	sd	s0,16(sp)
    80001e70:	e426                	sd	s1,8(sp)
    80001e72:	e04a                	sd	s2,0(sp)
    80001e74:	1000                	addi	s0,sp,32
    80001e76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e78:	c8bff0ef          	jal	ra,80001b02 <myproc>
    80001e7c:	892a                	mv	s2,a0
  sz = p->sz;
    80001e7e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e80:	02905963          	blez	s1,80001eb2 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001e84:	00b48633          	add	a2,s1,a1
    80001e88:	020007b7          	lui	a5,0x2000
    80001e8c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001e8e:	07b6                	slli	a5,a5,0xd
    80001e90:	02c7ea63          	bltu	a5,a2,80001ec4 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e94:	4691                	li	a3,4
    80001e96:	6928                	ld	a0,80(a0)
    80001e98:	cbcff0ef          	jal	ra,80001354 <uvmalloc>
    80001e9c:	85aa                	mv	a1,a0
    80001e9e:	c50d                	beqz	a0,80001ec8 <growproc+0x5e>
  p->sz = sz;
    80001ea0:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ea4:	4501                	li	a0,0
}
    80001ea6:	60e2                	ld	ra,24(sp)
    80001ea8:	6442                	ld	s0,16(sp)
    80001eaa:	64a2                	ld	s1,8(sp)
    80001eac:	6902                	ld	s2,0(sp)
    80001eae:	6105                	addi	sp,sp,32
    80001eb0:	8082                	ret
  } else if(n < 0){
    80001eb2:	fe04d7e3          	bgez	s1,80001ea0 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eb6:	00b48633          	add	a2,s1,a1
    80001eba:	6928                	ld	a0,80(a0)
    80001ebc:	c54ff0ef          	jal	ra,80001310 <uvmdealloc>
    80001ec0:	85aa                	mv	a1,a0
    80001ec2:	bff9                	j	80001ea0 <growproc+0x36>
      return -1;
    80001ec4:	557d                	li	a0,-1
    80001ec6:	b7c5                	j	80001ea6 <growproc+0x3c>
      return -1;
    80001ec8:	557d                	li	a0,-1
    80001eca:	bff1                	j	80001ea6 <growproc+0x3c>

0000000080001ecc <kfork>:
{
    80001ecc:	7139                	addi	sp,sp,-64
    80001ece:	fc06                	sd	ra,56(sp)
    80001ed0:	f822                	sd	s0,48(sp)
    80001ed2:	f426                	sd	s1,40(sp)
    80001ed4:	f04a                	sd	s2,32(sp)
    80001ed6:	ec4e                	sd	s3,24(sp)
    80001ed8:	e852                	sd	s4,16(sp)
    80001eda:	e456                	sd	s5,8(sp)
    80001edc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ede:	c25ff0ef          	jal	ra,80001b02 <myproc>
    80001ee2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ee4:	ea5ff0ef          	jal	ra,80001d88 <allocproc>
    80001ee8:	0e050663          	beqz	a0,80001fd4 <kfork+0x108>
    80001eec:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eee:	048ab603          	ld	a2,72(s5)
    80001ef2:	692c                	ld	a1,80(a0)
    80001ef4:	050ab503          	ld	a0,80(s5)
    80001ef8:	d88ff0ef          	jal	ra,80001480 <uvmcopy>
    80001efc:	04054863          	bltz	a0,80001f4c <kfork+0x80>
  np->sz = p->sz;
    80001f00:	048ab783          	ld	a5,72(s5)
    80001f04:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f08:	058ab683          	ld	a3,88(s5)
    80001f0c:	87b6                	mv	a5,a3
    80001f0e:	058a3703          	ld	a4,88(s4)
    80001f12:	12068693          	addi	a3,a3,288
    80001f16:	0007b803          	ld	a6,0(a5)
    80001f1a:	6788                	ld	a0,8(a5)
    80001f1c:	6b8c                	ld	a1,16(a5)
    80001f1e:	6f90                	ld	a2,24(a5)
    80001f20:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001f24:	e708                	sd	a0,8(a4)
    80001f26:	eb0c                	sd	a1,16(a4)
    80001f28:	ef10                	sd	a2,24(a4)
    80001f2a:	02078793          	addi	a5,a5,32
    80001f2e:	02070713          	addi	a4,a4,32
    80001f32:	fed792e3          	bne	a5,a3,80001f16 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001f36:	058a3783          	ld	a5,88(s4)
    80001f3a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f3e:	0d0a8493          	addi	s1,s5,208
    80001f42:	0d0a0913          	addi	s2,s4,208
    80001f46:	150a8993          	addi	s3,s5,336
    80001f4a:	a829                	j	80001f64 <kfork+0x98>
    freeproc(np);
    80001f4c:	8552                	mv	a0,s4
    80001f4e:	dcfff0ef          	jal	ra,80001d1c <freeproc>
    release(&np->lock);
    80001f52:	8552                	mv	a0,s4
    80001f54:	de5fe0ef          	jal	ra,80000d38 <release>
    return -1;
    80001f58:	597d                	li	s2,-1
    80001f5a:	a09d                	j	80001fc0 <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001f5c:	04a1                	addi	s1,s1,8
    80001f5e:	0921                	addi	s2,s2,8
    80001f60:	01348963          	beq	s1,s3,80001f72 <kfork+0xa6>
    if(p->ofile[i])
    80001f64:	6088                	ld	a0,0(s1)
    80001f66:	d97d                	beqz	a0,80001f5c <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f68:	51a020ef          	jal	ra,80004482 <filedup>
    80001f6c:	00a93023          	sd	a0,0(s2)
    80001f70:	b7f5                	j	80001f5c <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001f72:	150ab503          	ld	a0,336(s5)
    80001f76:	72a010ef          	jal	ra,800036a0 <idup>
    80001f7a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f7e:	4641                	li	a2,16
    80001f80:	158a8593          	addi	a1,s5,344
    80001f84:	158a0513          	addi	a0,s4,344
    80001f88:	f33fe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    80001f8c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f90:	8552                	mv	a0,s4
    80001f92:	da7fe0ef          	jal	ra,80000d38 <release>
  acquire(&wait_lock);
    80001f96:	0022e497          	auipc	s1,0x22e
    80001f9a:	a3248493          	addi	s1,s1,-1486 # 8022f9c8 <wait_lock>
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	d01fe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    80001fa4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	d8ffe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    80001fae:	8552                	mv	a0,s4
    80001fb0:	cf1fe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    80001fb4:	478d                	li	a5,3
    80001fb6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001fba:	8552                	mv	a0,s4
    80001fbc:	d7dfe0ef          	jal	ra,80000d38 <release>
}
    80001fc0:	854a                	mv	a0,s2
    80001fc2:	70e2                	ld	ra,56(sp)
    80001fc4:	7442                	ld	s0,48(sp)
    80001fc6:	74a2                	ld	s1,40(sp)
    80001fc8:	7902                	ld	s2,32(sp)
    80001fca:	69e2                	ld	s3,24(sp)
    80001fcc:	6a42                	ld	s4,16(sp)
    80001fce:	6aa2                	ld	s5,8(sp)
    80001fd0:	6121                	addi	sp,sp,64
    80001fd2:	8082                	ret
    return -1;
    80001fd4:	597d                	li	s2,-1
    80001fd6:	b7ed                	j	80001fc0 <kfork+0xf4>

0000000080001fd8 <scheduler>:
{
    80001fd8:	715d                	addi	sp,sp,-80
    80001fda:	e486                	sd	ra,72(sp)
    80001fdc:	e0a2                	sd	s0,64(sp)
    80001fde:	fc26                	sd	s1,56(sp)
    80001fe0:	f84a                	sd	s2,48(sp)
    80001fe2:	f44e                	sd	s3,40(sp)
    80001fe4:	f052                	sd	s4,32(sp)
    80001fe6:	ec56                	sd	s5,24(sp)
    80001fe8:	e85a                	sd	s6,16(sp)
    80001fea:	e45e                	sd	s7,8(sp)
    80001fec:	e062                	sd	s8,0(sp)
    80001fee:	0880                	addi	s0,sp,80
    80001ff0:	8792                	mv	a5,tp
  int id = r_tp();
    80001ff2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ff4:	00779b13          	slli	s6,a5,0x7
    80001ff8:	0022e717          	auipc	a4,0x22e
    80001ffc:	9b870713          	addi	a4,a4,-1608 # 8022f9b0 <pid_lock>
    80002000:	975a                	add	a4,a4,s6
    80002002:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002006:	0022e717          	auipc	a4,0x22e
    8000200a:	9e270713          	addi	a4,a4,-1566 # 8022f9e8 <cpus+0x8>
    8000200e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002010:	4c11                	li	s8,4
        c->proc = p;
    80002012:	079e                	slli	a5,a5,0x7
    80002014:	0022ea17          	auipc	s4,0x22e
    80002018:	99ca0a13          	addi	s4,s4,-1636 # 8022f9b0 <pid_lock>
    8000201c:	9a3e                	add	s4,s4,a5
        found = 1;
    8000201e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002020:	0023b997          	auipc	s3,0x23b
    80002024:	7c098993          	addi	s3,s3,1984 # 8023d7e0 <tickslock>
    80002028:	a83d                	j	80002066 <scheduler+0x8e>
      release(&p->lock);
    8000202a:	8526                	mv	a0,s1
    8000202c:	d0dfe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002030:	36848493          	addi	s1,s1,872
    80002034:	03348563          	beq	s1,s3,8000205e <scheduler+0x86>
      acquire(&p->lock);
    80002038:	8526                	mv	a0,s1
    8000203a:	c67fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    8000203e:	4c9c                	lw	a5,24(s1)
    80002040:	ff2795e3          	bne	a5,s2,8000202a <scheduler+0x52>
        p->state = RUNNING;
    80002044:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002048:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000204c:	06048593          	addi	a1,s1,96
    80002050:	855a                	mv	a0,s6
    80002052:	5b2000ef          	jal	ra,80002604 <swtch>
        c->proc = 0;
    80002056:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000205a:	8ade                	mv	s5,s7
    8000205c:	b7f9                	j	8000202a <scheduler+0x52>
    if(found == 0) {
    8000205e:	000a9463          	bnez	s5,80002066 <scheduler+0x8e>
      asm volatile("wfi");
    80002062:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002066:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000206a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000206e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002072:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002076:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002078:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000207c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000207e:	0022e497          	auipc	s1,0x22e
    80002082:	d6248493          	addi	s1,s1,-670 # 8022fde0 <proc>
      if(p->state == RUNNABLE) {
    80002086:	490d                	li	s2,3
    80002088:	bf45                	j	80002038 <scheduler+0x60>

000000008000208a <sched>:
{
    8000208a:	7179                	addi	sp,sp,-48
    8000208c:	f406                	sd	ra,40(sp)
    8000208e:	f022                	sd	s0,32(sp)
    80002090:	ec26                	sd	s1,24(sp)
    80002092:	e84a                	sd	s2,16(sp)
    80002094:	e44e                	sd	s3,8(sp)
    80002096:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002098:	a6bff0ef          	jal	ra,80001b02 <myproc>
    8000209c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000209e:	b99fe0ef          	jal	ra,80000c36 <holding>
    800020a2:	c92d                	beqz	a0,80002114 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020a6:	2781                	sext.w	a5,a5
    800020a8:	079e                	slli	a5,a5,0x7
    800020aa:	0022e717          	auipc	a4,0x22e
    800020ae:	90670713          	addi	a4,a4,-1786 # 8022f9b0 <pid_lock>
    800020b2:	97ba                	add	a5,a5,a4
    800020b4:	0a87a703          	lw	a4,168(a5)
    800020b8:	4785                	li	a5,1
    800020ba:	06f71363          	bne	a4,a5,80002120 <sched+0x96>
  if(p->state == RUNNING)
    800020be:	4c98                	lw	a4,24(s1)
    800020c0:	4791                	li	a5,4
    800020c2:	06f70563          	beq	a4,a5,8000212c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020c6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020ca:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020cc:	e7b5                	bnez	a5,80002138 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ce:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020d0:	0022e917          	auipc	s2,0x22e
    800020d4:	8e090913          	addi	s2,s2,-1824 # 8022f9b0 <pid_lock>
    800020d8:	2781                	sext.w	a5,a5
    800020da:	079e                	slli	a5,a5,0x7
    800020dc:	97ca                	add	a5,a5,s2
    800020de:	0ac7a983          	lw	s3,172(a5)
    800020e2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020e4:	2781                	sext.w	a5,a5
    800020e6:	079e                	slli	a5,a5,0x7
    800020e8:	0022e597          	auipc	a1,0x22e
    800020ec:	90058593          	addi	a1,a1,-1792 # 8022f9e8 <cpus+0x8>
    800020f0:	95be                	add	a1,a1,a5
    800020f2:	06048513          	addi	a0,s1,96
    800020f6:	50e000ef          	jal	ra,80002604 <swtch>
    800020fa:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020fc:	2781                	sext.w	a5,a5
    800020fe:	079e                	slli	a5,a5,0x7
    80002100:	993e                	add	s2,s2,a5
    80002102:	0b392623          	sw	s3,172(s2)
}
    80002106:	70a2                	ld	ra,40(sp)
    80002108:	7402                	ld	s0,32(sp)
    8000210a:	64e2                	ld	s1,24(sp)
    8000210c:	6942                	ld	s2,16(sp)
    8000210e:	69a2                	ld	s3,8(sp)
    80002110:	6145                	addi	sp,sp,48
    80002112:	8082                	ret
    panic("sched p->lock");
    80002114:	00005517          	auipc	a0,0x5
    80002118:	0a450513          	addi	a0,a0,164 # 800071b8 <digits+0x180>
    8000211c:	e6cfe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    80002120:	00005517          	auipc	a0,0x5
    80002124:	0a850513          	addi	a0,a0,168 # 800071c8 <digits+0x190>
    80002128:	e60fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    8000212c:	00005517          	auipc	a0,0x5
    80002130:	0ac50513          	addi	a0,a0,172 # 800071d8 <digits+0x1a0>
    80002134:	e54fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80002138:	00005517          	auipc	a0,0x5
    8000213c:	0b050513          	addi	a0,a0,176 # 800071e8 <digits+0x1b0>
    80002140:	e48fe0ef          	jal	ra,80000788 <panic>

0000000080002144 <yield>:
{
    80002144:	1101                	addi	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000214e:	9b5ff0ef          	jal	ra,80001b02 <myproc>
    80002152:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002154:	b4dfe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    80002158:	478d                	li	a5,3
    8000215a:	cc9c                	sw	a5,24(s1)
  sched();
    8000215c:	f2fff0ef          	jal	ra,8000208a <sched>
  release(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	bd7fe0ef          	jal	ra,80000d38 <release>
}
    80002166:	60e2                	ld	ra,24(sp)
    80002168:	6442                	ld	s0,16(sp)
    8000216a:	64a2                	ld	s1,8(sp)
    8000216c:	6105                	addi	sp,sp,32
    8000216e:	8082                	ret

0000000080002170 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002170:	7179                	addi	sp,sp,-48
    80002172:	f406                	sd	ra,40(sp)
    80002174:	f022                	sd	s0,32(sp)
    80002176:	ec26                	sd	s1,24(sp)
    80002178:	e84a                	sd	s2,16(sp)
    8000217a:	e44e                	sd	s3,8(sp)
    8000217c:	1800                	addi	s0,sp,48
    8000217e:	89aa                	mv	s3,a0
    80002180:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002182:	981ff0ef          	jal	ra,80001b02 <myproc>
    80002186:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002188:	b19fe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    8000218c:	854a                	mv	a0,s2
    8000218e:	babfe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    80002192:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002196:	4789                	li	a5,2
    80002198:	cc9c                	sw	a5,24(s1)

  sched();
    8000219a:	ef1ff0ef          	jal	ra,8000208a <sched>

  // Tidy up.
  p->chan = 0;
    8000219e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	b95fe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    800021a8:	854a                	mv	a0,s2
    800021aa:	af7fe0ef          	jal	ra,80000ca0 <acquire>
}
    800021ae:	70a2                	ld	ra,40(sp)
    800021b0:	7402                	ld	s0,32(sp)
    800021b2:	64e2                	ld	s1,24(sp)
    800021b4:	6942                	ld	s2,16(sp)
    800021b6:	69a2                	ld	s3,8(sp)
    800021b8:	6145                	addi	sp,sp,48
    800021ba:	8082                	ret

00000000800021bc <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800021bc:	7139                	addi	sp,sp,-64
    800021be:	fc06                	sd	ra,56(sp)
    800021c0:	f822                	sd	s0,48(sp)
    800021c2:	f426                	sd	s1,40(sp)
    800021c4:	f04a                	sd	s2,32(sp)
    800021c6:	ec4e                	sd	s3,24(sp)
    800021c8:	e852                	sd	s4,16(sp)
    800021ca:	e456                	sd	s5,8(sp)
    800021cc:	0080                	addi	s0,sp,64
    800021ce:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021d0:	0022e497          	auipc	s1,0x22e
    800021d4:	c1048493          	addi	s1,s1,-1008 # 8022fde0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021d8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021da:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021dc:	0023b917          	auipc	s2,0x23b
    800021e0:	60490913          	addi	s2,s2,1540 # 8023d7e0 <tickslock>
    800021e4:	a801                	j	800021f4 <wakeup+0x38>
      }
      release(&p->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	b51fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021ec:	36848493          	addi	s1,s1,872
    800021f0:	03248263          	beq	s1,s2,80002214 <wakeup+0x58>
    if(p != myproc()){
    800021f4:	90fff0ef          	jal	ra,80001b02 <myproc>
    800021f8:	fea48ae3          	beq	s1,a0,800021ec <wakeup+0x30>
      acquire(&p->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	aa3fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002202:	4c9c                	lw	a5,24(s1)
    80002204:	ff3791e3          	bne	a5,s3,800021e6 <wakeup+0x2a>
    80002208:	709c                	ld	a5,32(s1)
    8000220a:	fd479ee3          	bne	a5,s4,800021e6 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000220e:	0154ac23          	sw	s5,24(s1)
    80002212:	bfd1                	j	800021e6 <wakeup+0x2a>
    }
  }
}
    80002214:	70e2                	ld	ra,56(sp)
    80002216:	7442                	ld	s0,48(sp)
    80002218:	74a2                	ld	s1,40(sp)
    8000221a:	7902                	ld	s2,32(sp)
    8000221c:	69e2                	ld	s3,24(sp)
    8000221e:	6a42                	ld	s4,16(sp)
    80002220:	6aa2                	ld	s5,8(sp)
    80002222:	6121                	addi	sp,sp,64
    80002224:	8082                	ret

0000000080002226 <reparent>:
{
    80002226:	7179                	addi	sp,sp,-48
    80002228:	f406                	sd	ra,40(sp)
    8000222a:	f022                	sd	s0,32(sp)
    8000222c:	ec26                	sd	s1,24(sp)
    8000222e:	e84a                	sd	s2,16(sp)
    80002230:	e44e                	sd	s3,8(sp)
    80002232:	e052                	sd	s4,0(sp)
    80002234:	1800                	addi	s0,sp,48
    80002236:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002238:	0022e497          	auipc	s1,0x22e
    8000223c:	ba848493          	addi	s1,s1,-1112 # 8022fde0 <proc>
      pp->parent = initproc;
    80002240:	00005a17          	auipc	s4,0x5
    80002244:	650a0a13          	addi	s4,s4,1616 # 80007890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002248:	0023b997          	auipc	s3,0x23b
    8000224c:	59898993          	addi	s3,s3,1432 # 8023d7e0 <tickslock>
    80002250:	a029                	j	8000225a <reparent+0x34>
    80002252:	36848493          	addi	s1,s1,872
    80002256:	01348b63          	beq	s1,s3,8000226c <reparent+0x46>
    if(pp->parent == p){
    8000225a:	7c9c                	ld	a5,56(s1)
    8000225c:	ff279be3          	bne	a5,s2,80002252 <reparent+0x2c>
      pp->parent = initproc;
    80002260:	000a3503          	ld	a0,0(s4)
    80002264:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002266:	f57ff0ef          	jal	ra,800021bc <wakeup>
    8000226a:	b7e5                	j	80002252 <reparent+0x2c>
}
    8000226c:	70a2                	ld	ra,40(sp)
    8000226e:	7402                	ld	s0,32(sp)
    80002270:	64e2                	ld	s1,24(sp)
    80002272:	6942                	ld	s2,16(sp)
    80002274:	69a2                	ld	s3,8(sp)
    80002276:	6a02                	ld	s4,0(sp)
    80002278:	6145                	addi	sp,sp,48
    8000227a:	8082                	ret

000000008000227c <kexit>:
{
    8000227c:	7179                	addi	sp,sp,-48
    8000227e:	f406                	sd	ra,40(sp)
    80002280:	f022                	sd	s0,32(sp)
    80002282:	ec26                	sd	s1,24(sp)
    80002284:	e84a                	sd	s2,16(sp)
    80002286:	e44e                	sd	s3,8(sp)
    80002288:	e052                	sd	s4,0(sp)
    8000228a:	1800                	addi	s0,sp,48
    8000228c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000228e:	875ff0ef          	jal	ra,80001b02 <myproc>
    80002292:	89aa                	mv	s3,a0
  if(p == initproc)
    80002294:	00005797          	auipc	a5,0x5
    80002298:	5fc7b783          	ld	a5,1532(a5) # 80007890 <initproc>
    8000229c:	0d050493          	addi	s1,a0,208
    800022a0:	15050913          	addi	s2,a0,336
    800022a4:	00a79f63          	bne	a5,a0,800022c2 <kexit+0x46>
    panic("init exiting");
    800022a8:	00005517          	auipc	a0,0x5
    800022ac:	f5850513          	addi	a0,a0,-168 # 80007200 <digits+0x1c8>
    800022b0:	cd8fe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    800022b4:	214020ef          	jal	ra,800044c8 <fileclose>
      p->ofile[fd] = 0;
    800022b8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022bc:	04a1                	addi	s1,s1,8
    800022be:	01248563          	beq	s1,s2,800022c8 <kexit+0x4c>
    if(p->ofile[fd]){
    800022c2:	6088                	ld	a0,0(s1)
    800022c4:	f965                	bnez	a0,800022b4 <kexit+0x38>
    800022c6:	bfdd                	j	800022bc <kexit+0x40>
  begin_op();
    800022c8:	5f7010ef          	jal	ra,800040be <begin_op>
  iput(p->cwd);
    800022cc:	1509b503          	ld	a0,336(s3)
    800022d0:	584010ef          	jal	ra,80003854 <iput>
  end_op();
    800022d4:	659010ef          	jal	ra,8000412c <end_op>
  p->cwd = 0;
    800022d8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022dc:	0022d497          	auipc	s1,0x22d
    800022e0:	6ec48493          	addi	s1,s1,1772 # 8022f9c8 <wait_lock>
    800022e4:	8526                	mv	a0,s1
    800022e6:	9bbfe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    800022ea:	854e                	mv	a0,s3
    800022ec:	f3bff0ef          	jal	ra,80002226 <reparent>
  wakeup(p->parent);
    800022f0:	0389b503          	ld	a0,56(s3)
    800022f4:	ec9ff0ef          	jal	ra,800021bc <wakeup>
  acquire(&p->lock);
    800022f8:	854e                	mv	a0,s3
    800022fa:	9a7fe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    800022fe:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002302:	4795                	li	a5,5
    80002304:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	a2ffe0ef          	jal	ra,80000d38 <release>
  sched();
    8000230e:	d7dff0ef          	jal	ra,8000208a <sched>
  panic("zombie exit");
    80002312:	00005517          	auipc	a0,0x5
    80002316:	efe50513          	addi	a0,a0,-258 # 80007210 <digits+0x1d8>
    8000231a:	c6efe0ef          	jal	ra,80000788 <panic>

000000008000231e <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000231e:	7179                	addi	sp,sp,-48
    80002320:	f406                	sd	ra,40(sp)
    80002322:	f022                	sd	s0,32(sp)
    80002324:	ec26                	sd	s1,24(sp)
    80002326:	e84a                	sd	s2,16(sp)
    80002328:	e44e                	sd	s3,8(sp)
    8000232a:	1800                	addi	s0,sp,48
    8000232c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000232e:	0022e497          	auipc	s1,0x22e
    80002332:	ab248493          	addi	s1,s1,-1358 # 8022fde0 <proc>
    80002336:	0023b997          	auipc	s3,0x23b
    8000233a:	4aa98993          	addi	s3,s3,1194 # 8023d7e0 <tickslock>
    acquire(&p->lock);
    8000233e:	8526                	mv	a0,s1
    80002340:	961fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    80002344:	589c                	lw	a5,48(s1)
    80002346:	01278b63          	beq	a5,s2,8000235c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	9edfe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002350:	36848493          	addi	s1,s1,872
    80002354:	ff3495e3          	bne	s1,s3,8000233e <kkill+0x20>
  }
  return -1;
    80002358:	557d                	li	a0,-1
    8000235a:	a819                	j	80002370 <kkill+0x52>
      p->killed = 1;
    8000235c:	4785                	li	a5,1
    8000235e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002360:	4c98                	lw	a4,24(s1)
    80002362:	4789                	li	a5,2
    80002364:	00f70d63          	beq	a4,a5,8000237e <kkill+0x60>
      release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	9cffe0ef          	jal	ra,80000d38 <release>
      return 0;
    8000236e:	4501                	li	a0,0
}
    80002370:	70a2                	ld	ra,40(sp)
    80002372:	7402                	ld	s0,32(sp)
    80002374:	64e2                	ld	s1,24(sp)
    80002376:	6942                	ld	s2,16(sp)
    80002378:	69a2                	ld	s3,8(sp)
    8000237a:	6145                	addi	sp,sp,48
    8000237c:	8082                	ret
        p->state = RUNNABLE;
    8000237e:	478d                	li	a5,3
    80002380:	cc9c                	sw	a5,24(s1)
    80002382:	b7dd                	j	80002368 <kkill+0x4a>

0000000080002384 <setkilled>:

void
setkilled(struct proc *p)
{
    80002384:	1101                	addi	sp,sp,-32
    80002386:	ec06                	sd	ra,24(sp)
    80002388:	e822                	sd	s0,16(sp)
    8000238a:	e426                	sd	s1,8(sp)
    8000238c:	1000                	addi	s0,sp,32
    8000238e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002390:	911fe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    80002394:	4785                	li	a5,1
    80002396:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002398:	8526                	mv	a0,s1
    8000239a:	99ffe0ef          	jal	ra,80000d38 <release>
}
    8000239e:	60e2                	ld	ra,24(sp)
    800023a0:	6442                	ld	s0,16(sp)
    800023a2:	64a2                	ld	s1,8(sp)
    800023a4:	6105                	addi	sp,sp,32
    800023a6:	8082                	ret

00000000800023a8 <killed>:

int
killed(struct proc *p)
{
    800023a8:	1101                	addi	sp,sp,-32
    800023aa:	ec06                	sd	ra,24(sp)
    800023ac:	e822                	sd	s0,16(sp)
    800023ae:	e426                	sd	s1,8(sp)
    800023b0:	e04a                	sd	s2,0(sp)
    800023b2:	1000                	addi	s0,sp,32
    800023b4:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023b6:	8ebfe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    800023ba:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	979fe0ef          	jal	ra,80000d38 <release>
  return k;
}
    800023c4:	854a                	mv	a0,s2
    800023c6:	60e2                	ld	ra,24(sp)
    800023c8:	6442                	ld	s0,16(sp)
    800023ca:	64a2                	ld	s1,8(sp)
    800023cc:	6902                	ld	s2,0(sp)
    800023ce:	6105                	addi	sp,sp,32
    800023d0:	8082                	ret

00000000800023d2 <kwait>:
{
    800023d2:	715d                	addi	sp,sp,-80
    800023d4:	e486                	sd	ra,72(sp)
    800023d6:	e0a2                	sd	s0,64(sp)
    800023d8:	fc26                	sd	s1,56(sp)
    800023da:	f84a                	sd	s2,48(sp)
    800023dc:	f44e                	sd	s3,40(sp)
    800023de:	f052                	sd	s4,32(sp)
    800023e0:	ec56                	sd	s5,24(sp)
    800023e2:	e85a                	sd	s6,16(sp)
    800023e4:	e45e                	sd	s7,8(sp)
    800023e6:	e062                	sd	s8,0(sp)
    800023e8:	0880                	addi	s0,sp,80
    800023ea:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ec:	f16ff0ef          	jal	ra,80001b02 <myproc>
    800023f0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023f2:	0022d517          	auipc	a0,0x22d
    800023f6:	5d650513          	addi	a0,a0,1494 # 8022f9c8 <wait_lock>
    800023fa:	8a7fe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    800023fe:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002400:	4a15                	li	s4,5
        havekids = 1;
    80002402:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002404:	0023b997          	auipc	s3,0x23b
    80002408:	3dc98993          	addi	s3,s3,988 # 8023d7e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000240c:	0022dc17          	auipc	s8,0x22d
    80002410:	5bcc0c13          	addi	s8,s8,1468 # 8022f9c8 <wait_lock>
    havekids = 0;
    80002414:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002416:	0022e497          	auipc	s1,0x22e
    8000241a:	9ca48493          	addi	s1,s1,-1590 # 8022fde0 <proc>
    8000241e:	a899                	j	80002474 <kwait+0xa2>
          pid = pp->pid;
    80002420:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002424:	000b0c63          	beqz	s6,8000243c <kwait+0x6a>
    80002428:	4691                	li	a3,4
    8000242a:	02c48613          	addi	a2,s1,44
    8000242e:	85da                	mv	a1,s6
    80002430:	05093503          	ld	a0,80(s2)
    80002434:	b2aff0ef          	jal	ra,8000175e <copyout>
    80002438:	00054f63          	bltz	a0,80002456 <kwait+0x84>
          freeproc(pp);
    8000243c:	8526                	mv	a0,s1
    8000243e:	8dfff0ef          	jal	ra,80001d1c <freeproc>
          release(&pp->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	8f5fe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    80002448:	0022d517          	auipc	a0,0x22d
    8000244c:	58050513          	addi	a0,a0,1408 # 8022f9c8 <wait_lock>
    80002450:	8e9fe0ef          	jal	ra,80000d38 <release>
          return pid;
    80002454:	a891                	j	800024a8 <kwait+0xd6>
            release(&pp->lock);
    80002456:	8526                	mv	a0,s1
    80002458:	8e1fe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    8000245c:	0022d517          	auipc	a0,0x22d
    80002460:	56c50513          	addi	a0,a0,1388 # 8022f9c8 <wait_lock>
    80002464:	8d5fe0ef          	jal	ra,80000d38 <release>
            return -1;
    80002468:	59fd                	li	s3,-1
    8000246a:	a83d                	j	800024a8 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000246c:	36848493          	addi	s1,s1,872
    80002470:	03348063          	beq	s1,s3,80002490 <kwait+0xbe>
      if(pp->parent == p){
    80002474:	7c9c                	ld	a5,56(s1)
    80002476:	ff279be3          	bne	a5,s2,8000246c <kwait+0x9a>
        acquire(&pp->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	825fe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    80002480:	4c9c                	lw	a5,24(s1)
    80002482:	f9478fe3          	beq	a5,s4,80002420 <kwait+0x4e>
        release(&pp->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	8b1fe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    8000248c:	8756                	mv	a4,s5
    8000248e:	bff9                	j	8000246c <kwait+0x9a>
    if(!havekids || killed(p)){
    80002490:	c709                	beqz	a4,8000249a <kwait+0xc8>
    80002492:	854a                	mv	a0,s2
    80002494:	f15ff0ef          	jal	ra,800023a8 <killed>
    80002498:	c50d                	beqz	a0,800024c2 <kwait+0xf0>
      release(&wait_lock);
    8000249a:	0022d517          	auipc	a0,0x22d
    8000249e:	52e50513          	addi	a0,a0,1326 # 8022f9c8 <wait_lock>
    800024a2:	897fe0ef          	jal	ra,80000d38 <release>
      return -1;
    800024a6:	59fd                	li	s3,-1
}
    800024a8:	854e                	mv	a0,s3
    800024aa:	60a6                	ld	ra,72(sp)
    800024ac:	6406                	ld	s0,64(sp)
    800024ae:	74e2                	ld	s1,56(sp)
    800024b0:	7942                	ld	s2,48(sp)
    800024b2:	79a2                	ld	s3,40(sp)
    800024b4:	7a02                	ld	s4,32(sp)
    800024b6:	6ae2                	ld	s5,24(sp)
    800024b8:	6b42                	ld	s6,16(sp)
    800024ba:	6ba2                	ld	s7,8(sp)
    800024bc:	6c02                	ld	s8,0(sp)
    800024be:	6161                	addi	sp,sp,80
    800024c0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024c2:	85e2                	mv	a1,s8
    800024c4:	854a                	mv	a0,s2
    800024c6:	cabff0ef          	jal	ra,80002170 <sleep>
    havekids = 0;
    800024ca:	b7a9                	j	80002414 <kwait+0x42>

00000000800024cc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024cc:	7179                	addi	sp,sp,-48
    800024ce:	f406                	sd	ra,40(sp)
    800024d0:	f022                	sd	s0,32(sp)
    800024d2:	ec26                	sd	s1,24(sp)
    800024d4:	e84a                	sd	s2,16(sp)
    800024d6:	e44e                	sd	s3,8(sp)
    800024d8:	e052                	sd	s4,0(sp)
    800024da:	1800                	addi	s0,sp,48
    800024dc:	84aa                	mv	s1,a0
    800024de:	892e                	mv	s2,a1
    800024e0:	89b2                	mv	s3,a2
    800024e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e4:	e1eff0ef          	jal	ra,80001b02 <myproc>
  if(user_dst){
    800024e8:	cc99                	beqz	s1,80002506 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024ea:	86d2                	mv	a3,s4
    800024ec:	864e                	mv	a2,s3
    800024ee:	85ca                	mv	a1,s2
    800024f0:	6928                	ld	a0,80(a0)
    800024f2:	a6cff0ef          	jal	ra,8000175e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6a02                	ld	s4,0(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret
    memmove((char *)dst, src, len);
    80002506:	000a061b          	sext.w	a2,s4
    8000250a:	85ce                	mv	a1,s3
    8000250c:	854a                	mv	a0,s2
    8000250e:	8c3fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    80002512:	8526                	mv	a0,s1
    80002514:	b7cd                	j	800024f6 <either_copyout+0x2a>

0000000080002516 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002516:	7179                	addi	sp,sp,-48
    80002518:	f406                	sd	ra,40(sp)
    8000251a:	f022                	sd	s0,32(sp)
    8000251c:	ec26                	sd	s1,24(sp)
    8000251e:	e84a                	sd	s2,16(sp)
    80002520:	e44e                	sd	s3,8(sp)
    80002522:	e052                	sd	s4,0(sp)
    80002524:	1800                	addi	s0,sp,48
    80002526:	892a                	mv	s2,a0
    80002528:	84ae                	mv	s1,a1
    8000252a:	89b2                	mv	s3,a2
    8000252c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000252e:	dd4ff0ef          	jal	ra,80001b02 <myproc>
  if(user_src){
    80002532:	cc99                	beqz	s1,80002550 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002534:	86d2                	mv	a3,s4
    80002536:	864e                	mv	a2,s3
    80002538:	85ca                	mv	a1,s2
    8000253a:	6928                	ld	a0,80(a0)
    8000253c:	b0cff0ef          	jal	ra,80001848 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002540:	70a2                	ld	ra,40(sp)
    80002542:	7402                	ld	s0,32(sp)
    80002544:	64e2                	ld	s1,24(sp)
    80002546:	6942                	ld	s2,16(sp)
    80002548:	69a2                	ld	s3,8(sp)
    8000254a:	6a02                	ld	s4,0(sp)
    8000254c:	6145                	addi	sp,sp,48
    8000254e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002550:	000a061b          	sext.w	a2,s4
    80002554:	85ce                	mv	a1,s3
    80002556:	854a                	mv	a0,s2
    80002558:	879fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    8000255c:	8526                	mv	a0,s1
    8000255e:	b7cd                	j	80002540 <either_copyin+0x2a>

0000000080002560 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002560:	715d                	addi	sp,sp,-80
    80002562:	e486                	sd	ra,72(sp)
    80002564:	e0a2                	sd	s0,64(sp)
    80002566:	fc26                	sd	s1,56(sp)
    80002568:	f84a                	sd	s2,48(sp)
    8000256a:	f44e                	sd	s3,40(sp)
    8000256c:	f052                	sd	s4,32(sp)
    8000256e:	ec56                	sd	s5,24(sp)
    80002570:	e85a                	sd	s6,16(sp)
    80002572:	e45e                	sd	s7,8(sp)
    80002574:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002576:	00005517          	auipc	a0,0x5
    8000257a:	b5250513          	addi	a0,a0,-1198 # 800070c8 <digits+0x90>
    8000257e:	f45fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002582:	0022e497          	auipc	s1,0x22e
    80002586:	9b648493          	addi	s1,s1,-1610 # 8022ff38 <proc+0x158>
    8000258a:	0023b917          	auipc	s2,0x23b
    8000258e:	3ae90913          	addi	s2,s2,942 # 8023d938 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002592:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002594:	00005997          	auipc	s3,0x5
    80002598:	c8c98993          	addi	s3,s3,-884 # 80007220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    8000259c:	00005a97          	auipc	s5,0x5
    800025a0:	c8ca8a93          	addi	s5,s5,-884 # 80007228 <digits+0x1f0>
    printf("\n");
    800025a4:	00005a17          	auipc	s4,0x5
    800025a8:	b24a0a13          	addi	s4,s4,-1244 # 800070c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ac:	00005b97          	auipc	s7,0x5
    800025b0:	cbcb8b93          	addi	s7,s7,-836 # 80007268 <states.0>
    800025b4:	a829                	j	800025ce <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800025b6:	ed86a583          	lw	a1,-296(a3)
    800025ba:	8556                	mv	a0,s5
    800025bc:	f07fd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    800025c0:	8552                	mv	a0,s4
    800025c2:	f01fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025c6:	36848493          	addi	s1,s1,872
    800025ca:	03248263          	beq	s1,s2,800025ee <procdump+0x8e>
    if(p->state == UNUSED)
    800025ce:	86a6                	mv	a3,s1
    800025d0:	ec04a783          	lw	a5,-320(s1)
    800025d4:	dbed                	beqz	a5,800025c6 <procdump+0x66>
      state = "???";
    800025d6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d8:	fcfb6fe3          	bltu	s6,a5,800025b6 <procdump+0x56>
    800025dc:	02079713          	slli	a4,a5,0x20
    800025e0:	01d75793          	srli	a5,a4,0x1d
    800025e4:	97de                	add	a5,a5,s7
    800025e6:	6390                	ld	a2,0(a5)
    800025e8:	f679                	bnez	a2,800025b6 <procdump+0x56>
      state = "???";
    800025ea:	864e                	mv	a2,s3
    800025ec:	b7e9                	j	800025b6 <procdump+0x56>
  }
}
    800025ee:	60a6                	ld	ra,72(sp)
    800025f0:	6406                	ld	s0,64(sp)
    800025f2:	74e2                	ld	s1,56(sp)
    800025f4:	7942                	ld	s2,48(sp)
    800025f6:	79a2                	ld	s3,40(sp)
    800025f8:	7a02                	ld	s4,32(sp)
    800025fa:	6ae2                	ld	s5,24(sp)
    800025fc:	6b42                	ld	s6,16(sp)
    800025fe:	6ba2                	ld	s7,8(sp)
    80002600:	6161                	addi	sp,sp,80
    80002602:	8082                	ret

0000000080002604 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002604:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002608:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000260c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000260e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002610:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002614:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002618:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000261c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002620:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002624:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002628:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000262c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002630:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002634:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002638:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000263c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002640:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002642:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002644:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002648:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000264c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002650:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002654:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002658:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000265c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002660:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002664:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002668:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000266c:	8082                	ret

000000008000266e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000266e:	1141                	addi	sp,sp,-16
    80002670:	e406                	sd	ra,8(sp)
    80002672:	e022                	sd	s0,0(sp)
    80002674:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002676:	00005597          	auipc	a1,0x5
    8000267a:	c2258593          	addi	a1,a1,-990 # 80007298 <states.0+0x30>
    8000267e:	0023b517          	auipc	a0,0x23b
    80002682:	16250513          	addi	a0,a0,354 # 8023d7e0 <tickslock>
    80002686:	d9afe0ef          	jal	ra,80000c20 <initlock>
}
    8000268a:	60a2                	ld	ra,8(sp)
    8000268c:	6402                	ld	s0,0(sp)
    8000268e:	0141                	addi	sp,sp,16
    80002690:	8082                	ret

0000000080002692 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002692:	1141                	addi	sp,sp,-16
    80002694:	e422                	sd	s0,8(sp)
    80002696:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002698:	00003797          	auipc	a5,0x3
    8000269c:	14878793          	addi	a5,a5,328 # 800057e0 <kernelvec>
    800026a0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026a4:	6422                	ld	s0,8(sp)
    800026a6:	0141                	addi	sp,sp,16
    800026a8:	8082                	ret

00000000800026aa <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800026aa:	1141                	addi	sp,sp,-16
    800026ac:	e406                	sd	ra,8(sp)
    800026ae:	e022                	sd	s0,0(sp)
    800026b0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026b2:	c50ff0ef          	jal	ra,80001b02 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026ba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026bc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026c0:	04000737          	lui	a4,0x4000
    800026c4:	00004797          	auipc	a5,0x4
    800026c8:	93c78793          	addi	a5,a5,-1732 # 80006000 <_trampoline>
    800026cc:	00004697          	auipc	a3,0x4
    800026d0:	93468693          	addi	a3,a3,-1740 # 80006000 <_trampoline>
    800026d4:	8f95                	sub	a5,a5,a3
    800026d6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800026d8:	0732                	slli	a4,a4,0xc
    800026da:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026dc:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026e2:	18002773          	csrr	a4,satp
    800026e6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026e8:	6d38                	ld	a4,88(a0)
    800026ea:	613c                	ld	a5,64(a0)
    800026ec:	6685                	lui	a3,0x1
    800026ee:	97b6                	add	a5,a5,a3
    800026f0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026f2:	6d3c                	ld	a5,88(a0)
    800026f4:	00000717          	auipc	a4,0x0
    800026f8:	0f470713          	addi	a4,a4,244 # 800027e8 <usertrap>
    800026fc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026fe:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002700:	8712                	mv	a4,tp
    80002702:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002704:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002708:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000270c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002710:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002714:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002716:	6f9c                	ld	a5,24(a5)
    80002718:	14179073          	csrw	sepc,a5
}
    8000271c:	60a2                	ld	ra,8(sp)
    8000271e:	6402                	ld	s0,0(sp)
    80002720:	0141                	addi	sp,sp,16
    80002722:	8082                	ret

0000000080002724 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002724:	1101                	addi	sp,sp,-32
    80002726:	ec06                	sd	ra,24(sp)
    80002728:	e822                	sd	s0,16(sp)
    8000272a:	e426                	sd	s1,8(sp)
    8000272c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000272e:	ba8ff0ef          	jal	ra,80001ad6 <cpuid>
    80002732:	cd19                	beqz	a0,80002750 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002734:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002738:	000f4737          	lui	a4,0xf4
    8000273c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002740:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002742:	14d79073          	csrw	0x14d,a5
}
    80002746:	60e2                	ld	ra,24(sp)
    80002748:	6442                	ld	s0,16(sp)
    8000274a:	64a2                	ld	s1,8(sp)
    8000274c:	6105                	addi	sp,sp,32
    8000274e:	8082                	ret
    acquire(&tickslock);
    80002750:	0023b497          	auipc	s1,0x23b
    80002754:	09048493          	addi	s1,s1,144 # 8023d7e0 <tickslock>
    80002758:	8526                	mv	a0,s1
    8000275a:	d46fe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    8000275e:	00005517          	auipc	a0,0x5
    80002762:	13a50513          	addi	a0,a0,314 # 80007898 <ticks>
    80002766:	411c                	lw	a5,0(a0)
    80002768:	2785                	addiw	a5,a5,1
    8000276a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000276c:	a51ff0ef          	jal	ra,800021bc <wakeup>
    release(&tickslock);
    80002770:	8526                	mv	a0,s1
    80002772:	dc6fe0ef          	jal	ra,80000d38 <release>
    80002776:	bf7d                	j	80002734 <clockintr+0x10>

0000000080002778 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002778:	1101                	addi	sp,sp,-32
    8000277a:	ec06                	sd	ra,24(sp)
    8000277c:	e822                	sd	s0,16(sp)
    8000277e:	e426                	sd	s1,8(sp)
    80002780:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002782:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002786:	57fd                	li	a5,-1
    80002788:	17fe                	slli	a5,a5,0x3f
    8000278a:	07a5                	addi	a5,a5,9
    8000278c:	00f70d63          	beq	a4,a5,800027a6 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002790:	57fd                	li	a5,-1
    80002792:	17fe                	slli	a5,a5,0x3f
    80002794:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002796:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002798:	04f70463          	beq	a4,a5,800027e0 <devintr+0x68>
  }
}
    8000279c:	60e2                	ld	ra,24(sp)
    8000279e:	6442                	ld	s0,16(sp)
    800027a0:	64a2                	ld	s1,8(sp)
    800027a2:	6105                	addi	sp,sp,32
    800027a4:	8082                	ret
    int irq = plic_claim();
    800027a6:	0e2030ef          	jal	ra,80005888 <plic_claim>
    800027aa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027ac:	47a9                	li	a5,10
    800027ae:	02f50363          	beq	a0,a5,800027d4 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    800027b2:	4785                	li	a5,1
    800027b4:	02f50363          	beq	a0,a5,800027da <devintr+0x62>
    return 1;
    800027b8:	4505                	li	a0,1
    } else if(irq){
    800027ba:	d0ed                	beqz	s1,8000279c <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    800027bc:	85a6                	mv	a1,s1
    800027be:	00005517          	auipc	a0,0x5
    800027c2:	ae250513          	addi	a0,a0,-1310 # 800072a0 <states.0+0x38>
    800027c6:	cfdfd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    800027ca:	8526                	mv	a0,s1
    800027cc:	0dc030ef          	jal	ra,800058a8 <plic_complete>
    return 1;
    800027d0:	4505                	li	a0,1
    800027d2:	b7e9                	j	8000279c <devintr+0x24>
      uartintr();
    800027d4:	980fe0ef          	jal	ra,80000954 <uartintr>
    800027d8:	bfcd                	j	800027ca <devintr+0x52>
      virtio_disk_intr();
    800027da:	53a030ef          	jal	ra,80005d14 <virtio_disk_intr>
    800027de:	b7f5                	j	800027ca <devintr+0x52>
    clockintr();
    800027e0:	f45ff0ef          	jal	ra,80002724 <clockintr>
    return 2;
    800027e4:	4509                	li	a0,2
    800027e6:	bf5d                	j	8000279c <devintr+0x24>

00000000800027e8 <usertrap>:
{
    800027e8:	7179                	addi	sp,sp,-48
    800027ea:	f406                	sd	ra,40(sp)
    800027ec:	f022                	sd	s0,32(sp)
    800027ee:	ec26                	sd	s1,24(sp)
    800027f0:	e84a                	sd	s2,16(sp)
    800027f2:	e44e                	sd	s3,8(sp)
    800027f4:	e052                	sd	s4,0(sp)
    800027f6:	1800                	addi	s0,sp,48
    800027f8:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027fc:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002800:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002804:	1007f793          	andi	a5,a5,256
    80002808:	e3bd                	bnez	a5,8000286e <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000280a:	00003797          	auipc	a5,0x3
    8000280e:	fd678793          	addi	a5,a5,-42 # 800057e0 <kernelvec>
    80002812:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002816:	aecff0ef          	jal	ra,80001b02 <myproc>
    8000281a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000281c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000281e:	14102773          	csrr	a4,sepc
    80002822:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002824:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002828:	47a1                	li	a5,8
    8000282a:	04f70863          	beq	a4,a5,8000287a <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    8000282e:	f4bff0ef          	jal	ra,80002778 <devintr>
    80002832:	892a                	mv	s2,a0
    80002834:	0c051e63          	bnez	a0,80002910 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002838:	47b5                	li	a5,13
    8000283a:	08f98663          	beq	s3,a5,800028c6 <usertrap+0xde>
    8000283e:	47bd                	li	a5,15
    80002840:	0af99363          	bne	s3,a5,800028e6 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002844:	85d2                	mv	a1,s4
    80002846:	68a8                	ld	a0,80(s1)
    80002848:	cedfe0ef          	jal	ra,80001534 <cowbreak>
    8000284c:	c531                	beqz	a0,80002898 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    8000284e:	4605                	li	a2,1
    80002850:	85d2                	mv	a1,s4
    80002852:	8526                	mv	a0,s1
    80002854:	882ff0ef          	jal	ra,800018d6 <vmafault>
    80002858:	e121                	bnez	a0,80002898 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    8000285a:	4601                	li	a2,0
    8000285c:	85d2                	mv	a1,s4
    8000285e:	68a8                	ld	a0,80(s1)
    80002860:	e8dfe0ef          	jal	ra,800016ec <vmfault>
    80002864:	e915                	bnez	a0,80002898 <usertrap+0xb0>
        setkilled(p);
    80002866:	8526                	mv	a0,s1
    80002868:	b1dff0ef          	jal	ra,80002384 <setkilled>
    8000286c:	a035                	j	80002898 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    8000286e:	00005517          	auipc	a0,0x5
    80002872:	a5250513          	addi	a0,a0,-1454 # 800072c0 <states.0+0x58>
    80002876:	f13fd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    8000287a:	b2fff0ef          	jal	ra,800023a8 <killed>
    8000287e:	e121                	bnez	a0,800028be <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002880:	6cb8                	ld	a4,88(s1)
    80002882:	6f1c                	ld	a5,24(a4)
    80002884:	0791                	addi	a5,a5,4
    80002886:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002888:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000288c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002890:	10079073          	csrw	sstatus,a5
    syscall();
    80002894:	27c000ef          	jal	ra,80002b10 <syscall>
  if(killed(p))
    80002898:	8526                	mv	a0,s1
    8000289a:	b0fff0ef          	jal	ra,800023a8 <killed>
    8000289e:	ed35                	bnez	a0,8000291a <usertrap+0x132>
  prepare_return();
    800028a0:	e0bff0ef          	jal	ra,800026aa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028a4:	68a8                	ld	a0,80(s1)
    800028a6:	8131                	srli	a0,a0,0xc
    800028a8:	57fd                	li	a5,-1
    800028aa:	17fe                	slli	a5,a5,0x3f
    800028ac:	8d5d                	or	a0,a0,a5
}
    800028ae:	70a2                	ld	ra,40(sp)
    800028b0:	7402                	ld	s0,32(sp)
    800028b2:	64e2                	ld	s1,24(sp)
    800028b4:	6942                	ld	s2,16(sp)
    800028b6:	69a2                	ld	s3,8(sp)
    800028b8:	6a02                	ld	s4,0(sp)
    800028ba:	6145                	addi	sp,sp,48
    800028bc:	8082                	ret
      kexit(-1);
    800028be:	557d                	li	a0,-1
    800028c0:	9bdff0ef          	jal	ra,8000227c <kexit>
    800028c4:	bf75                	j	80002880 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    800028c6:	4601                	li	a2,0
    800028c8:	85d2                	mv	a1,s4
    800028ca:	8526                	mv	a0,s1
    800028cc:	80aff0ef          	jal	ra,800018d6 <vmafault>
    800028d0:	f561                	bnez	a0,80002898 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    800028d2:	4605                	li	a2,1
    800028d4:	85d2                	mv	a1,s4
    800028d6:	68a8                	ld	a0,80(s1)
    800028d8:	e15fe0ef          	jal	ra,800016ec <vmfault>
    800028dc:	fd55                	bnez	a0,80002898 <usertrap+0xb0>
        setkilled(p);
    800028de:	8526                	mv	a0,s1
    800028e0:	aa5ff0ef          	jal	ra,80002384 <setkilled>
    800028e4:	bf55                	j	80002898 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    800028e6:	5890                	lw	a2,48(s1)
    800028e8:	85ce                	mv	a1,s3
    800028ea:	00005517          	auipc	a0,0x5
    800028ee:	9f650513          	addi	a0,a0,-1546 # 800072e0 <states.0+0x78>
    800028f2:	bd1fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028f6:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    800028fa:	8652                	mv	a2,s4
    800028fc:	00005517          	auipc	a0,0x5
    80002900:	a1450513          	addi	a0,a0,-1516 # 80007310 <states.0+0xa8>
    80002904:	bbffd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002908:	8526                	mv	a0,s1
    8000290a:	a7bff0ef          	jal	ra,80002384 <setkilled>
    8000290e:	b769                	j	80002898 <usertrap+0xb0>
  if(killed(p))
    80002910:	8526                	mv	a0,s1
    80002912:	a97ff0ef          	jal	ra,800023a8 <killed>
    80002916:	c511                	beqz	a0,80002922 <usertrap+0x13a>
    80002918:	a011                	j	8000291c <usertrap+0x134>
    8000291a:	4901                	li	s2,0
    kexit(-1);
    8000291c:	557d                	li	a0,-1
    8000291e:	95fff0ef          	jal	ra,8000227c <kexit>
  if(which_dev == 2)
    80002922:	4789                	li	a5,2
    80002924:	f6f91ee3          	bne	s2,a5,800028a0 <usertrap+0xb8>
    yield();
    80002928:	81dff0ef          	jal	ra,80002144 <yield>
    8000292c:	bf95                	j	800028a0 <usertrap+0xb8>

000000008000292e <kerneltrap>:
{
    8000292e:	7179                	addi	sp,sp,-48
    80002930:	f406                	sd	ra,40(sp)
    80002932:	f022                	sd	s0,32(sp)
    80002934:	ec26                	sd	s1,24(sp)
    80002936:	e84a                	sd	s2,16(sp)
    80002938:	e44e                	sd	s3,8(sp)
    8000293a:	1800                	addi	s0,sp,48
    8000293c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002940:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002944:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002948:	1004f793          	andi	a5,s1,256
    8000294c:	c795                	beqz	a5,80002978 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002952:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002954:	eb85                	bnez	a5,80002984 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002956:	e23ff0ef          	jal	ra,80002778 <devintr>
    8000295a:	c91d                	beqz	a0,80002990 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000295c:	4789                	li	a5,2
    8000295e:	04f50a63          	beq	a0,a5,800029b2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002962:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002966:	10049073          	csrw	sstatus,s1
}
    8000296a:	70a2                	ld	ra,40(sp)
    8000296c:	7402                	ld	s0,32(sp)
    8000296e:	64e2                	ld	s1,24(sp)
    80002970:	6942                	ld	s2,16(sp)
    80002972:	69a2                	ld	s3,8(sp)
    80002974:	6145                	addi	sp,sp,48
    80002976:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002978:	00005517          	auipc	a0,0x5
    8000297c:	9c050513          	addi	a0,a0,-1600 # 80007338 <states.0+0xd0>
    80002980:	e09fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002984:	00005517          	auipc	a0,0x5
    80002988:	9dc50513          	addi	a0,a0,-1572 # 80007360 <states.0+0xf8>
    8000298c:	dfdfd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002990:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002994:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002998:	85ce                	mv	a1,s3
    8000299a:	00005517          	auipc	a0,0x5
    8000299e:	9e650513          	addi	a0,a0,-1562 # 80007380 <states.0+0x118>
    800029a2:	b21fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    800029a6:	00005517          	auipc	a0,0x5
    800029aa:	a0250513          	addi	a0,a0,-1534 # 800073a8 <states.0+0x140>
    800029ae:	ddbfd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    800029b2:	950ff0ef          	jal	ra,80001b02 <myproc>
    800029b6:	d555                	beqz	a0,80002962 <kerneltrap+0x34>
    yield();
    800029b8:	f8cff0ef          	jal	ra,80002144 <yield>
    800029bc:	b75d                	j	80002962 <kerneltrap+0x34>

00000000800029be <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029be:	1101                	addi	sp,sp,-32
    800029c0:	ec06                	sd	ra,24(sp)
    800029c2:	e822                	sd	s0,16(sp)
    800029c4:	e426                	sd	s1,8(sp)
    800029c6:	1000                	addi	s0,sp,32
    800029c8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029ca:	938ff0ef          	jal	ra,80001b02 <myproc>
  switch (n) {
    800029ce:	4795                	li	a5,5
    800029d0:	0497e163          	bltu	a5,s1,80002a12 <argraw+0x54>
    800029d4:	048a                	slli	s1,s1,0x2
    800029d6:	00005717          	auipc	a4,0x5
    800029da:	a0a70713          	addi	a4,a4,-1526 # 800073e0 <states.0+0x178>
    800029de:	94ba                	add	s1,s1,a4
    800029e0:	409c                	lw	a5,0(s1)
    800029e2:	97ba                	add	a5,a5,a4
    800029e4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029e6:	6d3c                	ld	a5,88(a0)
    800029e8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret
    return p->trapframe->a1;
    800029f4:	6d3c                	ld	a5,88(a0)
    800029f6:	7fa8                	ld	a0,120(a5)
    800029f8:	bfcd                	j	800029ea <argraw+0x2c>
    return p->trapframe->a2;
    800029fa:	6d3c                	ld	a5,88(a0)
    800029fc:	63c8                	ld	a0,128(a5)
    800029fe:	b7f5                	j	800029ea <argraw+0x2c>
    return p->trapframe->a3;
    80002a00:	6d3c                	ld	a5,88(a0)
    80002a02:	67c8                	ld	a0,136(a5)
    80002a04:	b7dd                	j	800029ea <argraw+0x2c>
    return p->trapframe->a4;
    80002a06:	6d3c                	ld	a5,88(a0)
    80002a08:	6bc8                	ld	a0,144(a5)
    80002a0a:	b7c5                	j	800029ea <argraw+0x2c>
    return p->trapframe->a5;
    80002a0c:	6d3c                	ld	a5,88(a0)
    80002a0e:	6fc8                	ld	a0,152(a5)
    80002a10:	bfe9                	j	800029ea <argraw+0x2c>
  panic("argraw");
    80002a12:	00005517          	auipc	a0,0x5
    80002a16:	9a650513          	addi	a0,a0,-1626 # 800073b8 <states.0+0x150>
    80002a1a:	d6ffd0ef          	jal	ra,80000788 <panic>

0000000080002a1e <fetchaddr>:
{
    80002a1e:	1101                	addi	sp,sp,-32
    80002a20:	ec06                	sd	ra,24(sp)
    80002a22:	e822                	sd	s0,16(sp)
    80002a24:	e426                	sd	s1,8(sp)
    80002a26:	e04a                	sd	s2,0(sp)
    80002a28:	1000                	addi	s0,sp,32
    80002a2a:	84aa                	mv	s1,a0
    80002a2c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a2e:	8d4ff0ef          	jal	ra,80001b02 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a32:	653c                	ld	a5,72(a0)
    80002a34:	02f4f663          	bgeu	s1,a5,80002a60 <fetchaddr+0x42>
    80002a38:	00848713          	addi	a4,s1,8
    80002a3c:	02e7e463          	bltu	a5,a4,80002a64 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a40:	46a1                	li	a3,8
    80002a42:	8626                	mv	a2,s1
    80002a44:	85ca                	mv	a1,s2
    80002a46:	6928                	ld	a0,80(a0)
    80002a48:	e01fe0ef          	jal	ra,80001848 <copyin>
    80002a4c:	00a03533          	snez	a0,a0
    80002a50:	40a00533          	neg	a0,a0
}
    80002a54:	60e2                	ld	ra,24(sp)
    80002a56:	6442                	ld	s0,16(sp)
    80002a58:	64a2                	ld	s1,8(sp)
    80002a5a:	6902                	ld	s2,0(sp)
    80002a5c:	6105                	addi	sp,sp,32
    80002a5e:	8082                	ret
    return -1;
    80002a60:	557d                	li	a0,-1
    80002a62:	bfcd                	j	80002a54 <fetchaddr+0x36>
    80002a64:	557d                	li	a0,-1
    80002a66:	b7fd                	j	80002a54 <fetchaddr+0x36>

0000000080002a68 <fetchstr>:
{
    80002a68:	7179                	addi	sp,sp,-48
    80002a6a:	f406                	sd	ra,40(sp)
    80002a6c:	f022                	sd	s0,32(sp)
    80002a6e:	ec26                	sd	s1,24(sp)
    80002a70:	e84a                	sd	s2,16(sp)
    80002a72:	e44e                	sd	s3,8(sp)
    80002a74:	1800                	addi	s0,sp,48
    80002a76:	892a                	mv	s2,a0
    80002a78:	84ae                	mv	s1,a1
    80002a7a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a7c:	886ff0ef          	jal	ra,80001b02 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a80:	86ce                	mv	a3,s3
    80002a82:	864a                	mv	a2,s2
    80002a84:	85a6                	mv	a1,s1
    80002a86:	6928                	ld	a0,80(a0)
    80002a88:	b99fe0ef          	jal	ra,80001620 <copyinstr>
    80002a8c:	00054c63          	bltz	a0,80002aa4 <fetchstr+0x3c>
  return strlen(buf);
    80002a90:	8526                	mv	a0,s1
    80002a92:	c5afe0ef          	jal	ra,80000eec <strlen>
}
    80002a96:	70a2                	ld	ra,40(sp)
    80002a98:	7402                	ld	s0,32(sp)
    80002a9a:	64e2                	ld	s1,24(sp)
    80002a9c:	6942                	ld	s2,16(sp)
    80002a9e:	69a2                	ld	s3,8(sp)
    80002aa0:	6145                	addi	sp,sp,48
    80002aa2:	8082                	ret
    return -1;
    80002aa4:	557d                	li	a0,-1
    80002aa6:	bfc5                	j	80002a96 <fetchstr+0x2e>

0000000080002aa8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002aa8:	1101                	addi	sp,sp,-32
    80002aaa:	ec06                	sd	ra,24(sp)
    80002aac:	e822                	sd	s0,16(sp)
    80002aae:	e426                	sd	s1,8(sp)
    80002ab0:	1000                	addi	s0,sp,32
    80002ab2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ab4:	f0bff0ef          	jal	ra,800029be <argraw>
    80002ab8:	c088                	sw	a0,0(s1)
}
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6105                	addi	sp,sp,32
    80002ac2:	8082                	ret

0000000080002ac4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	1000                	addi	s0,sp,32
    80002ace:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad0:	eefff0ef          	jal	ra,800029be <argraw>
    80002ad4:	e088                	sd	a0,0(s1)
}
    80002ad6:	60e2                	ld	ra,24(sp)
    80002ad8:	6442                	ld	s0,16(sp)
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	6105                	addi	sp,sp,32
    80002ade:	8082                	ret

0000000080002ae0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ae0:	7179                	addi	sp,sp,-48
    80002ae2:	f406                	sd	ra,40(sp)
    80002ae4:	f022                	sd	s0,32(sp)
    80002ae6:	ec26                	sd	s1,24(sp)
    80002ae8:	e84a                	sd	s2,16(sp)
    80002aea:	1800                	addi	s0,sp,48
    80002aec:	84ae                	mv	s1,a1
    80002aee:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002af0:	fd840593          	addi	a1,s0,-40
    80002af4:	fd1ff0ef          	jal	ra,80002ac4 <argaddr>
  return fetchstr(addr, buf, max);
    80002af8:	864a                	mv	a2,s2
    80002afa:	85a6                	mv	a1,s1
    80002afc:	fd843503          	ld	a0,-40(s0)
    80002b00:	f69ff0ef          	jal	ra,80002a68 <fetchstr>
}
    80002b04:	70a2                	ld	ra,40(sp)
    80002b06:	7402                	ld	s0,32(sp)
    80002b08:	64e2                	ld	s1,24(sp)
    80002b0a:	6942                	ld	s2,16(sp)
    80002b0c:	6145                	addi	sp,sp,48
    80002b0e:	8082                	ret

0000000080002b10 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	e04a                	sd	s2,0(sp)
    80002b1a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b1c:	fe7fe0ef          	jal	ra,80001b02 <myproc>
    80002b20:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b22:	05853903          	ld	s2,88(a0)
    80002b26:	0a893783          	ld	a5,168(s2)
    80002b2a:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b2e:	37fd                	addiw	a5,a5,-1
    80002b30:	4759                	li	a4,22
    80002b32:	00f76f63          	bltu	a4,a5,80002b50 <syscall+0x40>
    80002b36:	00369713          	slli	a4,a3,0x3
    80002b3a:	00005797          	auipc	a5,0x5
    80002b3e:	8be78793          	addi	a5,a5,-1858 # 800073f8 <syscalls>
    80002b42:	97ba                	add	a5,a5,a4
    80002b44:	639c                	ld	a5,0(a5)
    80002b46:	c789                	beqz	a5,80002b50 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b48:	9782                	jalr	a5
    80002b4a:	06a93823          	sd	a0,112(s2)
    80002b4e:	a829                	j	80002b68 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b50:	15848613          	addi	a2,s1,344
    80002b54:	588c                	lw	a1,48(s1)
    80002b56:	00005517          	auipc	a0,0x5
    80002b5a:	86a50513          	addi	a0,a0,-1942 # 800073c0 <states.0+0x158>
    80002b5e:	965fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b62:	6cbc                	ld	a5,88(s1)
    80002b64:	577d                	li	a4,-1
    80002b66:	fbb8                	sd	a4,112(a5)
  }
}
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	64a2                	ld	s1,8(sp)
    80002b6e:	6902                	ld	s2,0(sp)
    80002b70:	6105                	addi	sp,sp,32
    80002b72:	8082                	ret

0000000080002b74 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b7c:	fec40593          	addi	a1,s0,-20
    80002b80:	4501                	li	a0,0
    80002b82:	f27ff0ef          	jal	ra,80002aa8 <argint>
  kexit(n);
    80002b86:	fec42503          	lw	a0,-20(s0)
    80002b8a:	ef2ff0ef          	jal	ra,8000227c <kexit>
  return 0;  // not reached
}
    80002b8e:	4501                	li	a0,0
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	6105                	addi	sp,sp,32
    80002b96:	8082                	ret

0000000080002b98 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b98:	1141                	addi	sp,sp,-16
    80002b9a:	e406                	sd	ra,8(sp)
    80002b9c:	e022                	sd	s0,0(sp)
    80002b9e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ba0:	f63fe0ef          	jal	ra,80001b02 <myproc>
}
    80002ba4:	5908                	lw	a0,48(a0)
    80002ba6:	60a2                	ld	ra,8(sp)
    80002ba8:	6402                	ld	s0,0(sp)
    80002baa:	0141                	addi	sp,sp,16
    80002bac:	8082                	ret

0000000080002bae <sys_fork>:

uint64
sys_fork(void)
{
    80002bae:	1141                	addi	sp,sp,-16
    80002bb0:	e406                	sd	ra,8(sp)
    80002bb2:	e022                	sd	s0,0(sp)
    80002bb4:	0800                	addi	s0,sp,16
  return kfork();
    80002bb6:	b16ff0ef          	jal	ra,80001ecc <kfork>
}
    80002bba:	60a2                	ld	ra,8(sp)
    80002bbc:	6402                	ld	s0,0(sp)
    80002bbe:	0141                	addi	sp,sp,16
    80002bc0:	8082                	ret

0000000080002bc2 <sys_wait>:

uint64
sys_wait(void)
{
    80002bc2:	1101                	addi	sp,sp,-32
    80002bc4:	ec06                	sd	ra,24(sp)
    80002bc6:	e822                	sd	s0,16(sp)
    80002bc8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002bca:	fe840593          	addi	a1,s0,-24
    80002bce:	4501                	li	a0,0
    80002bd0:	ef5ff0ef          	jal	ra,80002ac4 <argaddr>
  return kwait(p);
    80002bd4:	fe843503          	ld	a0,-24(s0)
    80002bd8:	ffaff0ef          	jal	ra,800023d2 <kwait>
}
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	6105                	addi	sp,sp,32
    80002be2:	8082                	ret

0000000080002be4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002be4:	7179                	addi	sp,sp,-48
    80002be6:	f406                	sd	ra,40(sp)
    80002be8:	f022                	sd	s0,32(sp)
    80002bea:	ec26                	sd	s1,24(sp)
    80002bec:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002bee:	fd840593          	addi	a1,s0,-40
    80002bf2:	4501                	li	a0,0
    80002bf4:	eb5ff0ef          	jal	ra,80002aa8 <argint>
  argint(1, &t);
    80002bf8:	fdc40593          	addi	a1,s0,-36
    80002bfc:	4505                	li	a0,1
    80002bfe:	eabff0ef          	jal	ra,80002aa8 <argint>
  addr = myproc()->sz;
    80002c02:	f01fe0ef          	jal	ra,80001b02 <myproc>
    80002c06:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002c08:	fdc42703          	lw	a4,-36(s0)
    80002c0c:	4785                	li	a5,1
    80002c0e:	02f70763          	beq	a4,a5,80002c3c <sys_sbrk+0x58>
    80002c12:	fd842783          	lw	a5,-40(s0)
    80002c16:	0207c363          	bltz	a5,80002c3c <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002c1a:	97a6                	add	a5,a5,s1
    80002c1c:	0297ee63          	bltu	a5,s1,80002c58 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002c20:	02000737          	lui	a4,0x2000
    80002c24:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002c26:	0736                	slli	a4,a4,0xd
    80002c28:	02f76a63          	bltu	a4,a5,80002c5c <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002c2c:	ed7fe0ef          	jal	ra,80001b02 <myproc>
    80002c30:	fd842703          	lw	a4,-40(s0)
    80002c34:	653c                	ld	a5,72(a0)
    80002c36:	97ba                	add	a5,a5,a4
    80002c38:	e53c                	sd	a5,72(a0)
    80002c3a:	a039                	j	80002c48 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002c3c:	fd842503          	lw	a0,-40(s0)
    80002c40:	a2aff0ef          	jal	ra,80001e6a <growproc>
    80002c44:	00054863          	bltz	a0,80002c54 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c48:	8526                	mv	a0,s1
    80002c4a:	70a2                	ld	ra,40(sp)
    80002c4c:	7402                	ld	s0,32(sp)
    80002c4e:	64e2                	ld	s1,24(sp)
    80002c50:	6145                	addi	sp,sp,48
    80002c52:	8082                	ret
      return -1;
    80002c54:	54fd                	li	s1,-1
    80002c56:	bfcd                	j	80002c48 <sys_sbrk+0x64>
      return -1;
    80002c58:	54fd                	li	s1,-1
    80002c5a:	b7fd                	j	80002c48 <sys_sbrk+0x64>
      return -1;
    80002c5c:	54fd                	li	s1,-1
    80002c5e:	b7ed                	j	80002c48 <sys_sbrk+0x64>

0000000080002c60 <sys_pause>:

uint64
sys_pause(void)
{
    80002c60:	7139                	addi	sp,sp,-64
    80002c62:	fc06                	sd	ra,56(sp)
    80002c64:	f822                	sd	s0,48(sp)
    80002c66:	f426                	sd	s1,40(sp)
    80002c68:	f04a                	sd	s2,32(sp)
    80002c6a:	ec4e                	sd	s3,24(sp)
    80002c6c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c6e:	fcc40593          	addi	a1,s0,-52
    80002c72:	4501                	li	a0,0
    80002c74:	e35ff0ef          	jal	ra,80002aa8 <argint>
  if(n < 0)
    80002c78:	fcc42783          	lw	a5,-52(s0)
    80002c7c:	0607c563          	bltz	a5,80002ce6 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c80:	0023b517          	auipc	a0,0x23b
    80002c84:	b6050513          	addi	a0,a0,-1184 # 8023d7e0 <tickslock>
    80002c88:	818fe0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002c8c:	00005917          	auipc	s2,0x5
    80002c90:	c0c92903          	lw	s2,-1012(s2) # 80007898 <ticks>
  while(ticks - ticks0 < n){
    80002c94:	fcc42783          	lw	a5,-52(s0)
    80002c98:	cb8d                	beqz	a5,80002cca <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c9a:	0023b997          	auipc	s3,0x23b
    80002c9e:	b4698993          	addi	s3,s3,-1210 # 8023d7e0 <tickslock>
    80002ca2:	00005497          	auipc	s1,0x5
    80002ca6:	bf648493          	addi	s1,s1,-1034 # 80007898 <ticks>
    if(killed(myproc())){
    80002caa:	e59fe0ef          	jal	ra,80001b02 <myproc>
    80002cae:	efaff0ef          	jal	ra,800023a8 <killed>
    80002cb2:	ed0d                	bnez	a0,80002cec <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002cb4:	85ce                	mv	a1,s3
    80002cb6:	8526                	mv	a0,s1
    80002cb8:	cb8ff0ef          	jal	ra,80002170 <sleep>
  while(ticks - ticks0 < n){
    80002cbc:	409c                	lw	a5,0(s1)
    80002cbe:	412787bb          	subw	a5,a5,s2
    80002cc2:	fcc42703          	lw	a4,-52(s0)
    80002cc6:	fee7e2e3          	bltu	a5,a4,80002caa <sys_pause+0x4a>
  }
  release(&tickslock);
    80002cca:	0023b517          	auipc	a0,0x23b
    80002cce:	b1650513          	addi	a0,a0,-1258 # 8023d7e0 <tickslock>
    80002cd2:	866fe0ef          	jal	ra,80000d38 <release>
  return 0;
    80002cd6:	4501                	li	a0,0
}
    80002cd8:	70e2                	ld	ra,56(sp)
    80002cda:	7442                	ld	s0,48(sp)
    80002cdc:	74a2                	ld	s1,40(sp)
    80002cde:	7902                	ld	s2,32(sp)
    80002ce0:	69e2                	ld	s3,24(sp)
    80002ce2:	6121                	addi	sp,sp,64
    80002ce4:	8082                	ret
    n = 0;
    80002ce6:	fc042623          	sw	zero,-52(s0)
    80002cea:	bf59                	j	80002c80 <sys_pause+0x20>
      release(&tickslock);
    80002cec:	0023b517          	auipc	a0,0x23b
    80002cf0:	af450513          	addi	a0,a0,-1292 # 8023d7e0 <tickslock>
    80002cf4:	844fe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002cf8:	557d                	li	a0,-1
    80002cfa:	bff9                	j	80002cd8 <sys_pause+0x78>

0000000080002cfc <sys_kill>:

uint64
sys_kill(void)
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d04:	fec40593          	addi	a1,s0,-20
    80002d08:	4501                	li	a0,0
    80002d0a:	d9fff0ef          	jal	ra,80002aa8 <argint>
  return kkill(pid);
    80002d0e:	fec42503          	lw	a0,-20(s0)
    80002d12:	e0cff0ef          	jal	ra,8000231e <kkill>
}
    80002d16:	60e2                	ld	ra,24(sp)
    80002d18:	6442                	ld	s0,16(sp)
    80002d1a:	6105                	addi	sp,sp,32
    80002d1c:	8082                	ret

0000000080002d1e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d1e:	1101                	addi	sp,sp,-32
    80002d20:	ec06                	sd	ra,24(sp)
    80002d22:	e822                	sd	s0,16(sp)
    80002d24:	e426                	sd	s1,8(sp)
    80002d26:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d28:	0023b517          	auipc	a0,0x23b
    80002d2c:	ab850513          	addi	a0,a0,-1352 # 8023d7e0 <tickslock>
    80002d30:	f71fd0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002d34:	00005497          	auipc	s1,0x5
    80002d38:	b644a483          	lw	s1,-1180(s1) # 80007898 <ticks>
  release(&tickslock);
    80002d3c:	0023b517          	auipc	a0,0x23b
    80002d40:	aa450513          	addi	a0,a0,-1372 # 8023d7e0 <tickslock>
    80002d44:	ff5fd0ef          	jal	ra,80000d38 <release>
  return xticks;
}
    80002d48:	02049513          	slli	a0,s1,0x20
    80002d4c:	9101                	srli	a0,a0,0x20
    80002d4e:	60e2                	ld	ra,24(sp)
    80002d50:	6442                	ld	s0,16(sp)
    80002d52:	64a2                	ld	s1,8(sp)
    80002d54:	6105                	addi	sp,sp,32
    80002d56:	8082                	ret

0000000080002d58 <vma_find>:
  return 0;
}

struct vma*
vma_find(struct proc *p, uint64 va)
{
    80002d58:	1141                	addi	sp,sp,-16
    80002d5a:	e422                	sd	s0,8(sp)
    80002d5c:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002d5e:	16850793          	addi	a5,a0,360
    80002d62:	4701                	li	a4,0
    80002d64:	4841                	li	a6,16
    80002d66:	a031                	j	80002d72 <vma_find+0x1a>
    80002d68:	2705                	addiw	a4,a4,1
    80002d6a:	02078793          	addi	a5,a5,32
    80002d6e:	01070f63          	beq	a4,a6,80002d8c <vma_find+0x34>
    if(!p->vmas[i].used) continue;
    80002d72:	4394                	lw	a3,0(a5)
    80002d74:	daf5                	beqz	a3,80002d68 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    80002d76:	6794                	ld	a3,8(a5)
    80002d78:	fed5e8e3          	bltu	a1,a3,80002d68 <vma_find+0x10>
    80002d7c:	6b94                	ld	a3,16(a5)
    80002d7e:	fed5f5e3          	bgeu	a1,a3,80002d68 <vma_find+0x10>
      return &p->vmas[i];
    80002d82:	0716                	slli	a4,a4,0x5
    80002d84:	16870713          	addi	a4,a4,360
    80002d88:	953a                	add	a0,a0,a4
    80002d8a:	a011                	j	80002d8e <vma_find+0x36>
  }
  return 0;
    80002d8c:	4501                	li	a0,0
}
    80002d8e:	6422                	ld	s0,8(sp)
    80002d90:	0141                	addi	sp,sp,16
    80002d92:	8082                	ret

0000000080002d94 <sys_mmap>:

uint64
sys_mmap(void)
{
    80002d94:	715d                	addi	sp,sp,-80
    80002d96:	e486                	sd	ra,72(sp)
    80002d98:	e0a2                	sd	s0,64(sp)
    80002d9a:	fc26                	sd	s1,56(sp)
    80002d9c:	f84a                	sd	s2,48(sp)
    80002d9e:	f44e                	sd	s3,40(sp)
    80002da0:	0880                	addi	s0,sp,80
  uint64 addr;
  int len, prot, flags;

  argaddr(0, &addr);
    80002da2:	fc840593          	addi	a1,s0,-56
    80002da6:	4501                	li	a0,0
    80002da8:	d1dff0ef          	jal	ra,80002ac4 <argaddr>
  argint(1, &len);
    80002dac:	fc440593          	addi	a1,s0,-60
    80002db0:	4505                	li	a0,1
    80002db2:	cf7ff0ef          	jal	ra,80002aa8 <argint>
  argint(2, &prot);
    80002db6:	fc040593          	addi	a1,s0,-64
    80002dba:	4509                	li	a0,2
    80002dbc:	cedff0ef          	jal	ra,80002aa8 <argint>
  argint(3, &flags);
    80002dc0:	fbc40593          	addi	a1,s0,-68
    80002dc4:	450d                	li	a0,3
    80002dc6:	ce3ff0ef          	jal	ra,80002aa8 <argint>


  if(len <= 0) return -1;
    80002dca:	fc442983          	lw	s3,-60(s0)
    80002dce:	0f305763          	blez	s3,80002ebc <sys_mmap+0x128>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return -1;                
  if(plen > (MMAPTOP - MMAPBASE)) return -1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return -1;  
    80002dd2:	fc042483          	lw	s1,-64(s0)
    80002dd6:	98f1                	andi	s1,s1,-4
    80002dd8:	557d                	li	a0,-1
    80002dda:	e0f5                	bnez	s1,80002ebe <sys_mmap+0x12a>
  if((flags & MAP_ANON) == 0) return -1;
    80002ddc:	fbc42783          	lw	a5,-68(s0)
    80002de0:	8b85                	andi	a5,a5,1
    80002de2:	cff1                	beqz	a5,80002ebe <sys_mmap+0x12a>
  if(addr != 0) return -1;            
    80002de4:	fc843903          	ld	s2,-56(s0)
    80002de8:	0c091b63          	bnez	s2,80002ebe <sys_mmap+0x12a>

  struct proc *p = myproc();
    80002dec:	d17fe0ef          	jal	ra,80001b02 <myproc>
    80002df0:	8eaa                	mv	t4,a0
  for(int i = 0; i < NVMA; i++){
    80002df2:	16850f13          	addi	t5,a0,360
  struct proc *p = myproc();
    80002df6:	87fa                	mv	a5,t5
  for(int i = 0; i < NVMA; i++){
    80002df8:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80002dfa:	4398                	lw	a4,0(a5)
    80002dfc:	cb01                	beqz	a4,80002e0c <sys_mmap+0x78>
  for(int i = 0; i < NVMA; i++){
    80002dfe:	2485                	addiw	s1,s1,1
    80002e00:	02078793          	addi	a5,a5,32
    80002e04:	fed49be3          	bne	s1,a3,80002dfa <sys_mmap+0x66>

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80002e08:	557d                	li	a0,-1
    80002e0a:	a855                	j	80002ebe <sys_mmap+0x12a>
  uint64 plen = PGROUNDUP((uint64)len);
    80002e0c:	6785                	lui	a5,0x1
    80002e0e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002e10:	00f988b3          	add	a7,s3,a5
    80002e14:	777d                	lui	a4,0xfffff
    80002e16:	00e8f8b3          	and	a7,a7,a4
  len = PGROUNDUP(len);
    80002e1a:	97c6                	add	a5,a5,a7
    80002e1c:	00e7f333          	and	t1,a5,a4
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80002e20:	400005b7          	lui	a1,0x40000
    80002e24:	959a                	add	a1,a1,t1
    80002e26:	40000537          	lui	a0,0x40000
    80002e2a:	368e8613          	addi	a2,t4,872
    va = PGROUNDUP(jump);
    80002e2e:	6f85                	lui	t6,0x1
    80002e30:	1ffd                	addi	t6,t6,-1 # fff <_entry-0x7ffff001>
    80002e32:	72fd                	lui	t0,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80002e34:	f3fffe37          	lui	t3,0xf3fff
    80002e38:	0e3a                	slli	t3,t3,0xe
    80002e3a:	01ae5e13          	srli	t3,t3,0x1a
    80002e3e:	a82d                	j	80002e78 <sys_mmap+0xe4>
      if(best == 0 || e < best) best = e;
    80002e40:	883a                	mv	a6,a4
  for(int i=0;i<NVMA;i++){
    80002e42:	02078793          	addi	a5,a5,32
    80002e46:	02c78063          	beq	a5,a2,80002e66 <sys_mmap+0xd2>
    if(!p->vmas[i].used) continue;
    80002e4a:	4398                	lw	a4,0(a5)
    80002e4c:	db7d                	beqz	a4,80002e42 <sys_mmap+0xae>
    if(!(end <= s || start >= e)){
    80002e4e:	6798                	ld	a4,8(a5)
    80002e50:	feb779e3          	bgeu	a4,a1,80002e42 <sys_mmap+0xae>
    uint64 e = p->vmas[i].end;
    80002e54:	6b98                	ld	a4,16(a5)
    if(!(end <= s || start >= e)){
    80002e56:	fee576e3          	bgeu	a0,a4,80002e42 <sys_mmap+0xae>
      if(best == 0 || e < best) best = e;
    80002e5a:	fe0803e3          	beqz	a6,80002e40 <sys_mmap+0xac>
    80002e5e:	ff0772e3          	bgeu	a4,a6,80002e42 <sys_mmap+0xae>
    80002e62:	883a                	mv	a6,a4
    80002e64:	bff9                	j	80002e42 <sys_mmap+0xae>
    if(jump == 0){
    80002e66:	00080c63          	beqz	a6,80002e7e <sys_mmap+0xea>
    va = PGROUNDUP(jump);
    80002e6a:	987e                	add	a6,a6,t6
    80002e6c:	00587533          	and	a0,a6,t0
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80002e70:	00a305b3          	add	a1,t1,a0
    80002e74:	04be6c63          	bltu	t3,a1,80002ecc <sys_mmap+0x138>
  struct proc *p = myproc();
    80002e78:	87fa                	mv	a5,t5
  uint64 best = 0;
    80002e7a:	884a                	mv	a6,s2
    80002e7c:	b7f9                	j	80002e4a <sys_mmap+0xb6>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;
    80002e7e:	c929                	beqz	a0,80002ed0 <sys_mmap+0x13c>
  
  v->used = 1;
    80002e80:	0496                	slli	s1,s1,0x5
    80002e82:	9ea6                	add	t4,t4,s1
    80002e84:	4785                	li	a5,1
    80002e86:	16fea423          	sw	a5,360(t4)
  v->start = va;
    80002e8a:	16aeb823          	sd	a0,368(t4)
  v->end = va + plen;
    80002e8e:	98aa                	add	a7,a7,a0
    80002e90:	171ebc23          	sd	a7,376(t4)
  v->prot = prot;
    80002e94:	fc042783          	lw	a5,-64(s0)
    80002e98:	18fea023          	sw	a5,384(t4)
  v->flags = flags;
    80002e9c:	fbc42783          	lw	a5,-68(s0)
    80002ea0:	18fea223          	sw	a5,388(t4)

  if(va < MMAPBASE || va + plen > MMAPTOP) return -1;
    80002ea4:	400007b7          	lui	a5,0x40000
    80002ea8:	02f56663          	bltu	a0,a5,80002ed4 <sys_mmap+0x140>
    80002eac:	010007b7          	lui	a5,0x1000
    80002eb0:	17f5                	addi	a5,a5,-3 # fffffd <_entry-0x7f000003>
    80002eb2:	07ba                	slli	a5,a5,0xe
    80002eb4:	0117f563          	bgeu	a5,a7,80002ebe <sys_mmap+0x12a>
    80002eb8:	557d                	li	a0,-1
    80002eba:	a011                	j	80002ebe <sys_mmap+0x12a>
  if(len <= 0) return -1;
    80002ebc:	557d                	li	a0,-1

  return va;
}
    80002ebe:	60a6                	ld	ra,72(sp)
    80002ec0:	6406                	ld	s0,64(sp)
    80002ec2:	74e2                	ld	s1,56(sp)
    80002ec4:	7942                	ld	s2,48(sp)
    80002ec6:	79a2                	ld	s3,40(sp)
    80002ec8:	6161                	addi	sp,sp,80
    80002eca:	8082                	ret
  if(va == 0) return (uint64)-1;
    80002ecc:	557d                	li	a0,-1
    80002ece:	bfc5                	j	80002ebe <sys_mmap+0x12a>
    80002ed0:	557d                	li	a0,-1
    80002ed2:	b7f5                	j	80002ebe <sys_mmap+0x12a>
  if(va < MMAPBASE || va + plen > MMAPTOP) return -1;
    80002ed4:	557d                	li	a0,-1
    80002ed6:	b7e5                	j	80002ebe <sys_mmap+0x12a>

0000000080002ed8 <sys_munmap>:

uint64
sys_munmap(void)
{
    80002ed8:	7139                	addi	sp,sp,-64
    80002eda:	fc06                	sd	ra,56(sp)
    80002edc:	f822                	sd	s0,48(sp)
    80002ede:	f426                	sd	s1,40(sp)
    80002ee0:	f04a                	sd	s2,32(sp)
    80002ee2:	ec4e                	sd	s3,24(sp)
    80002ee4:	e852                	sd	s4,16(sp)
    80002ee6:	0080                	addi	s0,sp,64
  uint64 addr;
  int len;

  argaddr(0, &addr);
    80002ee8:	fc840593          	addi	a1,s0,-56
    80002eec:	4501                	li	a0,0
    80002eee:	bd7ff0ef          	jal	ra,80002ac4 <argaddr>
  argint(1, &len);
    80002ef2:	fc440593          	addi	a1,s0,-60
    80002ef6:	4505                	li	a0,1
    80002ef8:	bb1ff0ef          	jal	ra,80002aa8 <argint>

  if(addr % PGSIZE != 0) return (uint64)-1;   // 要求页对齐
    80002efc:	fc843783          	ld	a5,-56(s0)
    80002f00:	17d2                	slli	a5,a5,0x34
    80002f02:	59fd                	li	s3,-1
    80002f04:	e3a5                	bnez	a5,80002f64 <sys_munmap+0x8c>
    80002f06:	0347d993          	srli	s3,a5,0x34
  if(len <= 0) return (uint64)-1;
    80002f0a:	fc442783          	lw	a5,-60(s0)
    80002f0e:	08f05763          	blez	a5,80002f9c <sys_munmap+0xc4>

  struct proc *p = myproc();
    80002f12:	bf1fe0ef          	jal	ra,80001b02 <myproc>
    80002f16:	892a                	mv	s2,a0
  uint64 plen = PGROUNDUP((uint64)len);
    80002f18:	fc442783          	lw	a5,-60(s0)
    80002f1c:	6705                	lui	a4,0x1
    80002f1e:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002f20:	97ba                	add	a5,a5,a4
    80002f22:	777d                	lui	a4,0xfffff
    80002f24:	00e7f533          	and	a0,a5,a4
  // 找到起点匹配的 vma
  struct vma *v = 0;
  for(int i = 0; i < NVMA; i++){
    if(p->vmas[i].used && p->vmas[i].start == addr){
    80002f28:	fc843603          	ld	a2,-56(s0)
    80002f2c:	16890793          	addi	a5,s2,360
  for(int i = 0; i < NVMA; i++){
    80002f30:	4481                	li	s1,0
    80002f32:	46c1                	li	a3,16
    80002f34:	a031                	j	80002f40 <sys_munmap+0x68>
    80002f36:	2485                	addiw	s1,s1,1
    80002f38:	02078793          	addi	a5,a5,32
    80002f3c:	02d48363          	beq	s1,a3,80002f62 <sys_munmap+0x8a>
    if(p->vmas[i].used && p->vmas[i].start == addr){
    80002f40:	4398                	lw	a4,0(a5)
    80002f42:	db75                	beqz	a4,80002f36 <sys_munmap+0x5e>
    80002f44:	6798                	ld	a4,8(a5)
    80002f46:	fec718e3          	bne	a4,a2,80002f36 <sys_munmap+0x5e>
      v = &p->vmas[i];
      break;
    }
  }
  if(v == 0) return (uint64)-1;
  if(plen != (v->end - v->start)) return (uint64)-1;
    80002f4a:	00549a13          	slli	s4,s1,0x5
    80002f4e:	9a4a                	add	s4,s4,s2
    80002f50:	170a3583          	ld	a1,368(s4)
    80002f54:	178a3603          	ld	a2,376(s4)
    80002f58:	8e0d                	sub	a2,a2,a1
    80002f5a:	00a60e63          	beq	a2,a0,80002f76 <sys_munmap+0x9e>
    80002f5e:	59fd                	li	s3,-1
    80002f60:	a011                	j	80002f64 <sys_munmap+0x8c>
  if(v == 0) return (uint64)-1;
    80002f62:	59fd                	li	s3,-1
  v->used = 0;
  v->start = v->end = 0;
  v->prot = v->flags = 0;

  return 0;
}
    80002f64:	854e                	mv	a0,s3
    80002f66:	70e2                	ld	ra,56(sp)
    80002f68:	7442                	ld	s0,48(sp)
    80002f6a:	74a2                	ld	s1,40(sp)
    80002f6c:	7902                	ld	s2,32(sp)
    80002f6e:	69e2                	ld	s3,24(sp)
    80002f70:	6a42                	ld	s4,16(sp)
    80002f72:	6121                	addi	sp,sp,64
    80002f74:	8082                	ret
  uvmunmap(p->pagetable, v->start, l/PGSIZE, 1);
    80002f76:	4685                	li	a3,1
    80002f78:	8231                	srli	a2,a2,0xc
    80002f7a:	05093503          	ld	a0,80(s2)
    80002f7e:	b16fe0ef          	jal	ra,80001294 <uvmunmap>
  v->used = 0;
    80002f82:	160a2423          	sw	zero,360(s4)
  v->start = v->end = 0;
    80002f86:	0496                	slli	s1,s1,0x5
    80002f88:	9926                	add	s2,s2,s1
    80002f8a:	16093c23          	sd	zero,376(s2)
    80002f8e:	160a3823          	sd	zero,368(s4)
  v->prot = v->flags = 0;
    80002f92:	18092223          	sw	zero,388(s2)
    80002f96:	18092023          	sw	zero,384(s2)
  return 0;
    80002f9a:	b7e9                	j	80002f64 <sys_munmap+0x8c>
  if(len <= 0) return (uint64)-1;
    80002f9c:	59fd                	li	s3,-1
    80002f9e:	b7d9                	j	80002f64 <sys_munmap+0x8c>

0000000080002fa0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fa0:	7179                	addi	sp,sp,-48
    80002fa2:	f406                	sd	ra,40(sp)
    80002fa4:	f022                	sd	s0,32(sp)
    80002fa6:	ec26                	sd	s1,24(sp)
    80002fa8:	e84a                	sd	s2,16(sp)
    80002faa:	e44e                	sd	s3,8(sp)
    80002fac:	e052                	sd	s4,0(sp)
    80002fae:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fb0:	00004597          	auipc	a1,0x4
    80002fb4:	50858593          	addi	a1,a1,1288 # 800074b8 <syscalls+0xc0>
    80002fb8:	0023b517          	auipc	a0,0x23b
    80002fbc:	84050513          	addi	a0,a0,-1984 # 8023d7f8 <bcache>
    80002fc0:	c61fd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fc4:	00243797          	auipc	a5,0x243
    80002fc8:	83478793          	addi	a5,a5,-1996 # 802457f8 <bcache+0x8000>
    80002fcc:	00243717          	auipc	a4,0x243
    80002fd0:	a9470713          	addi	a4,a4,-1388 # 80245a60 <bcache+0x8268>
    80002fd4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fd8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fdc:	0023b497          	auipc	s1,0x23b
    80002fe0:	83448493          	addi	s1,s1,-1996 # 8023d810 <bcache+0x18>
    b->next = bcache.head.next;
    80002fe4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fe6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fe8:	00004a17          	auipc	s4,0x4
    80002fec:	4d8a0a13          	addi	s4,s4,1240 # 800074c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002ff0:	2b893783          	ld	a5,696(s2)
    80002ff4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ff6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ffa:	85d2                	mv	a1,s4
    80002ffc:	01048513          	addi	a0,s1,16
    80003000:	302010ef          	jal	ra,80004302 <initsleeplock>
    bcache.head.next->prev = b;
    80003004:	2b893783          	ld	a5,696(s2)
    80003008:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000300a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000300e:	45848493          	addi	s1,s1,1112
    80003012:	fd349fe3          	bne	s1,s3,80002ff0 <binit+0x50>
  }
}
    80003016:	70a2                	ld	ra,40(sp)
    80003018:	7402                	ld	s0,32(sp)
    8000301a:	64e2                	ld	s1,24(sp)
    8000301c:	6942                	ld	s2,16(sp)
    8000301e:	69a2                	ld	s3,8(sp)
    80003020:	6a02                	ld	s4,0(sp)
    80003022:	6145                	addi	sp,sp,48
    80003024:	8082                	ret

0000000080003026 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003026:	7179                	addi	sp,sp,-48
    80003028:	f406                	sd	ra,40(sp)
    8000302a:	f022                	sd	s0,32(sp)
    8000302c:	ec26                	sd	s1,24(sp)
    8000302e:	e84a                	sd	s2,16(sp)
    80003030:	e44e                	sd	s3,8(sp)
    80003032:	1800                	addi	s0,sp,48
    80003034:	892a                	mv	s2,a0
    80003036:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003038:	0023a517          	auipc	a0,0x23a
    8000303c:	7c050513          	addi	a0,a0,1984 # 8023d7f8 <bcache>
    80003040:	c61fd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003044:	00243497          	auipc	s1,0x243
    80003048:	a6c4b483          	ld	s1,-1428(s1) # 80245ab0 <bcache+0x82b8>
    8000304c:	00243797          	auipc	a5,0x243
    80003050:	a1478793          	addi	a5,a5,-1516 # 80245a60 <bcache+0x8268>
    80003054:	02f48b63          	beq	s1,a5,8000308a <bread+0x64>
    80003058:	873e                	mv	a4,a5
    8000305a:	a021                	j	80003062 <bread+0x3c>
    8000305c:	68a4                	ld	s1,80(s1)
    8000305e:	02e48663          	beq	s1,a4,8000308a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003062:	449c                	lw	a5,8(s1)
    80003064:	ff279ce3          	bne	a5,s2,8000305c <bread+0x36>
    80003068:	44dc                	lw	a5,12(s1)
    8000306a:	ff3799e3          	bne	a5,s3,8000305c <bread+0x36>
      b->refcnt++;
    8000306e:	40bc                	lw	a5,64(s1)
    80003070:	2785                	addiw	a5,a5,1
    80003072:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003074:	0023a517          	auipc	a0,0x23a
    80003078:	78450513          	addi	a0,a0,1924 # 8023d7f8 <bcache>
    8000307c:	cbdfd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003080:	01048513          	addi	a0,s1,16
    80003084:	2b4010ef          	jal	ra,80004338 <acquiresleep>
      return b;
    80003088:	a889                	j	800030da <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000308a:	00243497          	auipc	s1,0x243
    8000308e:	a1e4b483          	ld	s1,-1506(s1) # 80245aa8 <bcache+0x82b0>
    80003092:	00243797          	auipc	a5,0x243
    80003096:	9ce78793          	addi	a5,a5,-1586 # 80245a60 <bcache+0x8268>
    8000309a:	00f48863          	beq	s1,a5,800030aa <bread+0x84>
    8000309e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030a0:	40bc                	lw	a5,64(s1)
    800030a2:	cb91                	beqz	a5,800030b6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030a4:	64a4                	ld	s1,72(s1)
    800030a6:	fee49de3          	bne	s1,a4,800030a0 <bread+0x7a>
  panic("bget: no buffers");
    800030aa:	00004517          	auipc	a0,0x4
    800030ae:	41e50513          	addi	a0,a0,1054 # 800074c8 <syscalls+0xd0>
    800030b2:	ed6fd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    800030b6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030ba:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030be:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030c2:	4785                	li	a5,1
    800030c4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030c6:	0023a517          	auipc	a0,0x23a
    800030ca:	73250513          	addi	a0,a0,1842 # 8023d7f8 <bcache>
    800030ce:	c6bfd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    800030d2:	01048513          	addi	a0,s1,16
    800030d6:	262010ef          	jal	ra,80004338 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030da:	409c                	lw	a5,0(s1)
    800030dc:	cb89                	beqz	a5,800030ee <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030de:	8526                	mv	a0,s1
    800030e0:	70a2                	ld	ra,40(sp)
    800030e2:	7402                	ld	s0,32(sp)
    800030e4:	64e2                	ld	s1,24(sp)
    800030e6:	6942                	ld	s2,16(sp)
    800030e8:	69a2                	ld	s3,8(sp)
    800030ea:	6145                	addi	sp,sp,48
    800030ec:	8082                	ret
    virtio_disk_rw(b, 0);
    800030ee:	4581                	li	a1,0
    800030f0:	8526                	mv	a0,s1
    800030f2:	209020ef          	jal	ra,80005afa <virtio_disk_rw>
    b->valid = 1;
    800030f6:	4785                	li	a5,1
    800030f8:	c09c                	sw	a5,0(s1)
  return b;
    800030fa:	b7d5                	j	800030de <bread+0xb8>

00000000800030fc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030fc:	1101                	addi	sp,sp,-32
    800030fe:	ec06                	sd	ra,24(sp)
    80003100:	e822                	sd	s0,16(sp)
    80003102:	e426                	sd	s1,8(sp)
    80003104:	1000                	addi	s0,sp,32
    80003106:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003108:	0541                	addi	a0,a0,16
    8000310a:	2ac010ef          	jal	ra,800043b6 <holdingsleep>
    8000310e:	c911                	beqz	a0,80003122 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003110:	4585                	li	a1,1
    80003112:	8526                	mv	a0,s1
    80003114:	1e7020ef          	jal	ra,80005afa <virtio_disk_rw>
}
    80003118:	60e2                	ld	ra,24(sp)
    8000311a:	6442                	ld	s0,16(sp)
    8000311c:	64a2                	ld	s1,8(sp)
    8000311e:	6105                	addi	sp,sp,32
    80003120:	8082                	ret
    panic("bwrite");
    80003122:	00004517          	auipc	a0,0x4
    80003126:	3be50513          	addi	a0,a0,958 # 800074e0 <syscalls+0xe8>
    8000312a:	e5efd0ef          	jal	ra,80000788 <panic>

000000008000312e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000312e:	1101                	addi	sp,sp,-32
    80003130:	ec06                	sd	ra,24(sp)
    80003132:	e822                	sd	s0,16(sp)
    80003134:	e426                	sd	s1,8(sp)
    80003136:	e04a                	sd	s2,0(sp)
    80003138:	1000                	addi	s0,sp,32
    8000313a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000313c:	01050913          	addi	s2,a0,16
    80003140:	854a                	mv	a0,s2
    80003142:	274010ef          	jal	ra,800043b6 <holdingsleep>
    80003146:	c13d                	beqz	a0,800031ac <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003148:	854a                	mv	a0,s2
    8000314a:	234010ef          	jal	ra,8000437e <releasesleep>

  acquire(&bcache.lock);
    8000314e:	0023a517          	auipc	a0,0x23a
    80003152:	6aa50513          	addi	a0,a0,1706 # 8023d7f8 <bcache>
    80003156:	b4bfd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    8000315a:	40bc                	lw	a5,64(s1)
    8000315c:	37fd                	addiw	a5,a5,-1
    8000315e:	0007871b          	sext.w	a4,a5
    80003162:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003164:	eb05                	bnez	a4,80003194 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003166:	68bc                	ld	a5,80(s1)
    80003168:	64b8                	ld	a4,72(s1)
    8000316a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000316c:	64bc                	ld	a5,72(s1)
    8000316e:	68b8                	ld	a4,80(s1)
    80003170:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003172:	00242797          	auipc	a5,0x242
    80003176:	68678793          	addi	a5,a5,1670 # 802457f8 <bcache+0x8000>
    8000317a:	2b87b703          	ld	a4,696(a5)
    8000317e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003180:	00243717          	auipc	a4,0x243
    80003184:	8e070713          	addi	a4,a4,-1824 # 80245a60 <bcache+0x8268>
    80003188:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000318a:	2b87b703          	ld	a4,696(a5)
    8000318e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003190:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003194:	0023a517          	auipc	a0,0x23a
    80003198:	66450513          	addi	a0,a0,1636 # 8023d7f8 <bcache>
    8000319c:	b9dfd0ef          	jal	ra,80000d38 <release>
}
    800031a0:	60e2                	ld	ra,24(sp)
    800031a2:	6442                	ld	s0,16(sp)
    800031a4:	64a2                	ld	s1,8(sp)
    800031a6:	6902                	ld	s2,0(sp)
    800031a8:	6105                	addi	sp,sp,32
    800031aa:	8082                	ret
    panic("brelse");
    800031ac:	00004517          	auipc	a0,0x4
    800031b0:	33c50513          	addi	a0,a0,828 # 800074e8 <syscalls+0xf0>
    800031b4:	dd4fd0ef          	jal	ra,80000788 <panic>

00000000800031b8 <bpin>:

void
bpin(struct buf *b) {
    800031b8:	1101                	addi	sp,sp,-32
    800031ba:	ec06                	sd	ra,24(sp)
    800031bc:	e822                	sd	s0,16(sp)
    800031be:	e426                	sd	s1,8(sp)
    800031c0:	1000                	addi	s0,sp,32
    800031c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031c4:	0023a517          	auipc	a0,0x23a
    800031c8:	63450513          	addi	a0,a0,1588 # 8023d7f8 <bcache>
    800031cc:	ad5fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    800031d0:	40bc                	lw	a5,64(s1)
    800031d2:	2785                	addiw	a5,a5,1
    800031d4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031d6:	0023a517          	auipc	a0,0x23a
    800031da:	62250513          	addi	a0,a0,1570 # 8023d7f8 <bcache>
    800031de:	b5bfd0ef          	jal	ra,80000d38 <release>
}
    800031e2:	60e2                	ld	ra,24(sp)
    800031e4:	6442                	ld	s0,16(sp)
    800031e6:	64a2                	ld	s1,8(sp)
    800031e8:	6105                	addi	sp,sp,32
    800031ea:	8082                	ret

00000000800031ec <bunpin>:

void
bunpin(struct buf *b) {
    800031ec:	1101                	addi	sp,sp,-32
    800031ee:	ec06                	sd	ra,24(sp)
    800031f0:	e822                	sd	s0,16(sp)
    800031f2:	e426                	sd	s1,8(sp)
    800031f4:	1000                	addi	s0,sp,32
    800031f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031f8:	0023a517          	auipc	a0,0x23a
    800031fc:	60050513          	addi	a0,a0,1536 # 8023d7f8 <bcache>
    80003200:	aa1fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80003204:	40bc                	lw	a5,64(s1)
    80003206:	37fd                	addiw	a5,a5,-1
    80003208:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000320a:	0023a517          	auipc	a0,0x23a
    8000320e:	5ee50513          	addi	a0,a0,1518 # 8023d7f8 <bcache>
    80003212:	b27fd0ef          	jal	ra,80000d38 <release>
}
    80003216:	60e2                	ld	ra,24(sp)
    80003218:	6442                	ld	s0,16(sp)
    8000321a:	64a2                	ld	s1,8(sp)
    8000321c:	6105                	addi	sp,sp,32
    8000321e:	8082                	ret

0000000080003220 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003220:	1101                	addi	sp,sp,-32
    80003222:	ec06                	sd	ra,24(sp)
    80003224:	e822                	sd	s0,16(sp)
    80003226:	e426                	sd	s1,8(sp)
    80003228:	e04a                	sd	s2,0(sp)
    8000322a:	1000                	addi	s0,sp,32
    8000322c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000322e:	00d5d59b          	srliw	a1,a1,0xd
    80003232:	00243797          	auipc	a5,0x243
    80003236:	ca27a783          	lw	a5,-862(a5) # 80245ed4 <sb+0x1c>
    8000323a:	9dbd                	addw	a1,a1,a5
    8000323c:	debff0ef          	jal	ra,80003026 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003240:	0074f713          	andi	a4,s1,7
    80003244:	4785                	li	a5,1
    80003246:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000324a:	14ce                	slli	s1,s1,0x33
    8000324c:	90d9                	srli	s1,s1,0x36
    8000324e:	00950733          	add	a4,a0,s1
    80003252:	05874703          	lbu	a4,88(a4)
    80003256:	00e7f6b3          	and	a3,a5,a4
    8000325a:	c29d                	beqz	a3,80003280 <bfree+0x60>
    8000325c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000325e:	94aa                	add	s1,s1,a0
    80003260:	fff7c793          	not	a5,a5
    80003264:	8f7d                	and	a4,a4,a5
    80003266:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000326a:	7d7000ef          	jal	ra,80004240 <log_write>
  brelse(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	ebfff0ef          	jal	ra,8000312e <brelse>
}
    80003274:	60e2                	ld	ra,24(sp)
    80003276:	6442                	ld	s0,16(sp)
    80003278:	64a2                	ld	s1,8(sp)
    8000327a:	6902                	ld	s2,0(sp)
    8000327c:	6105                	addi	sp,sp,32
    8000327e:	8082                	ret
    panic("freeing free block");
    80003280:	00004517          	auipc	a0,0x4
    80003284:	27050513          	addi	a0,a0,624 # 800074f0 <syscalls+0xf8>
    80003288:	d00fd0ef          	jal	ra,80000788 <panic>

000000008000328c <balloc>:
{
    8000328c:	711d                	addi	sp,sp,-96
    8000328e:	ec86                	sd	ra,88(sp)
    80003290:	e8a2                	sd	s0,80(sp)
    80003292:	e4a6                	sd	s1,72(sp)
    80003294:	e0ca                	sd	s2,64(sp)
    80003296:	fc4e                	sd	s3,56(sp)
    80003298:	f852                	sd	s4,48(sp)
    8000329a:	f456                	sd	s5,40(sp)
    8000329c:	f05a                	sd	s6,32(sp)
    8000329e:	ec5e                	sd	s7,24(sp)
    800032a0:	e862                	sd	s8,16(sp)
    800032a2:	e466                	sd	s9,8(sp)
    800032a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032a6:	00243797          	auipc	a5,0x243
    800032aa:	c167a783          	lw	a5,-1002(a5) # 80245ebc <sb+0x4>
    800032ae:	cff1                	beqz	a5,8000338a <balloc+0xfe>
    800032b0:	8baa                	mv	s7,a0
    800032b2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032b4:	00243b17          	auipc	s6,0x243
    800032b8:	c04b0b13          	addi	s6,s6,-1020 # 80245eb8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032bc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032be:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032c2:	6c89                	lui	s9,0x2
    800032c4:	a0b5                	j	80003330 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032c6:	97ca                	add	a5,a5,s2
    800032c8:	8e55                	or	a2,a2,a3
    800032ca:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032ce:	854a                	mv	a0,s2
    800032d0:	771000ef          	jal	ra,80004240 <log_write>
        brelse(bp);
    800032d4:	854a                	mv	a0,s2
    800032d6:	e59ff0ef          	jal	ra,8000312e <brelse>
  bp = bread(dev, bno);
    800032da:	85a6                	mv	a1,s1
    800032dc:	855e                	mv	a0,s7
    800032de:	d49ff0ef          	jal	ra,80003026 <bread>
    800032e2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032e4:	40000613          	li	a2,1024
    800032e8:	4581                	li	a1,0
    800032ea:	05850513          	addi	a0,a0,88
    800032ee:	a87fd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    800032f2:	854a                	mv	a0,s2
    800032f4:	74d000ef          	jal	ra,80004240 <log_write>
  brelse(bp);
    800032f8:	854a                	mv	a0,s2
    800032fa:	e35ff0ef          	jal	ra,8000312e <brelse>
}
    800032fe:	8526                	mv	a0,s1
    80003300:	60e6                	ld	ra,88(sp)
    80003302:	6446                	ld	s0,80(sp)
    80003304:	64a6                	ld	s1,72(sp)
    80003306:	6906                	ld	s2,64(sp)
    80003308:	79e2                	ld	s3,56(sp)
    8000330a:	7a42                	ld	s4,48(sp)
    8000330c:	7aa2                	ld	s5,40(sp)
    8000330e:	7b02                	ld	s6,32(sp)
    80003310:	6be2                	ld	s7,24(sp)
    80003312:	6c42                	ld	s8,16(sp)
    80003314:	6ca2                	ld	s9,8(sp)
    80003316:	6125                	addi	sp,sp,96
    80003318:	8082                	ret
    brelse(bp);
    8000331a:	854a                	mv	a0,s2
    8000331c:	e13ff0ef          	jal	ra,8000312e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003320:	015c87bb          	addw	a5,s9,s5
    80003324:	00078a9b          	sext.w	s5,a5
    80003328:	004b2703          	lw	a4,4(s6)
    8000332c:	04eaff63          	bgeu	s5,a4,8000338a <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80003330:	41fad79b          	sraiw	a5,s5,0x1f
    80003334:	0137d79b          	srliw	a5,a5,0x13
    80003338:	015787bb          	addw	a5,a5,s5
    8000333c:	40d7d79b          	sraiw	a5,a5,0xd
    80003340:	01cb2583          	lw	a1,28(s6)
    80003344:	9dbd                	addw	a1,a1,a5
    80003346:	855e                	mv	a0,s7
    80003348:	cdfff0ef          	jal	ra,80003026 <bread>
    8000334c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000334e:	004b2503          	lw	a0,4(s6)
    80003352:	000a849b          	sext.w	s1,s5
    80003356:	8762                	mv	a4,s8
    80003358:	fca4f1e3          	bgeu	s1,a0,8000331a <balloc+0x8e>
      m = 1 << (bi % 8);
    8000335c:	00777693          	andi	a3,a4,7
    80003360:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003364:	41f7579b          	sraiw	a5,a4,0x1f
    80003368:	01d7d79b          	srliw	a5,a5,0x1d
    8000336c:	9fb9                	addw	a5,a5,a4
    8000336e:	4037d79b          	sraiw	a5,a5,0x3
    80003372:	00f90633          	add	a2,s2,a5
    80003376:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000337a:	00c6f5b3          	and	a1,a3,a2
    8000337e:	d5a1                	beqz	a1,800032c6 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003380:	2705                	addiw	a4,a4,1
    80003382:	2485                	addiw	s1,s1,1
    80003384:	fd471ae3          	bne	a4,s4,80003358 <balloc+0xcc>
    80003388:	bf49                	j	8000331a <balloc+0x8e>
  printf("balloc: out of blocks\n");
    8000338a:	00004517          	auipc	a0,0x4
    8000338e:	17e50513          	addi	a0,a0,382 # 80007508 <syscalls+0x110>
    80003392:	930fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003396:	4481                	li	s1,0
    80003398:	b79d                	j	800032fe <balloc+0x72>

000000008000339a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000339a:	7179                	addi	sp,sp,-48
    8000339c:	f406                	sd	ra,40(sp)
    8000339e:	f022                	sd	s0,32(sp)
    800033a0:	ec26                	sd	s1,24(sp)
    800033a2:	e84a                	sd	s2,16(sp)
    800033a4:	e44e                	sd	s3,8(sp)
    800033a6:	e052                	sd	s4,0(sp)
    800033a8:	1800                	addi	s0,sp,48
    800033aa:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033ac:	47ad                	li	a5,11
    800033ae:	02b7e663          	bltu	a5,a1,800033da <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    800033b2:	02059793          	slli	a5,a1,0x20
    800033b6:	01e7d593          	srli	a1,a5,0x1e
    800033ba:	00b504b3          	add	s1,a0,a1
    800033be:	0504a903          	lw	s2,80(s1)
    800033c2:	06091663          	bnez	s2,8000342e <bmap+0x94>
      addr = balloc(ip->dev);
    800033c6:	4108                	lw	a0,0(a0)
    800033c8:	ec5ff0ef          	jal	ra,8000328c <balloc>
    800033cc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033d0:	04090f63          	beqz	s2,8000342e <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    800033d4:	0524a823          	sw	s2,80(s1)
    800033d8:	a899                	j	8000342e <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033da:	ff45849b          	addiw	s1,a1,-12
    800033de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033e2:	0ff00793          	li	a5,255
    800033e6:	06e7eb63          	bltu	a5,a4,8000345c <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033ea:	08052903          	lw	s2,128(a0)
    800033ee:	00091b63          	bnez	s2,80003404 <bmap+0x6a>
      addr = balloc(ip->dev);
    800033f2:	4108                	lw	a0,0(a0)
    800033f4:	e99ff0ef          	jal	ra,8000328c <balloc>
    800033f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033fc:	02090963          	beqz	s2,8000342e <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003400:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003404:	85ca                	mv	a1,s2
    80003406:	0009a503          	lw	a0,0(s3)
    8000340a:	c1dff0ef          	jal	ra,80003026 <bread>
    8000340e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003410:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003414:	02049713          	slli	a4,s1,0x20
    80003418:	01e75593          	srli	a1,a4,0x1e
    8000341c:	00b784b3          	add	s1,a5,a1
    80003420:	0004a903          	lw	s2,0(s1)
    80003424:	00090e63          	beqz	s2,80003440 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003428:	8552                	mv	a0,s4
    8000342a:	d05ff0ef          	jal	ra,8000312e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000342e:	854a                	mv	a0,s2
    80003430:	70a2                	ld	ra,40(sp)
    80003432:	7402                	ld	s0,32(sp)
    80003434:	64e2                	ld	s1,24(sp)
    80003436:	6942                	ld	s2,16(sp)
    80003438:	69a2                	ld	s3,8(sp)
    8000343a:	6a02                	ld	s4,0(sp)
    8000343c:	6145                	addi	sp,sp,48
    8000343e:	8082                	ret
      addr = balloc(ip->dev);
    80003440:	0009a503          	lw	a0,0(s3)
    80003444:	e49ff0ef          	jal	ra,8000328c <balloc>
    80003448:	0005091b          	sext.w	s2,a0
      if(addr){
    8000344c:	fc090ee3          	beqz	s2,80003428 <bmap+0x8e>
        a[bn] = addr;
    80003450:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003454:	8552                	mv	a0,s4
    80003456:	5eb000ef          	jal	ra,80004240 <log_write>
    8000345a:	b7f9                	j	80003428 <bmap+0x8e>
  panic("bmap: out of range");
    8000345c:	00004517          	auipc	a0,0x4
    80003460:	0c450513          	addi	a0,a0,196 # 80007520 <syscalls+0x128>
    80003464:	b24fd0ef          	jal	ra,80000788 <panic>

0000000080003468 <iget>:
{
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	e052                	sd	s4,0(sp)
    80003476:	1800                	addi	s0,sp,48
    80003478:	89aa                	mv	s3,a0
    8000347a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000347c:	00243517          	auipc	a0,0x243
    80003480:	a5c50513          	addi	a0,a0,-1444 # 80245ed8 <itable>
    80003484:	81dfd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003488:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000348a:	00243497          	auipc	s1,0x243
    8000348e:	a6648493          	addi	s1,s1,-1434 # 80245ef0 <itable+0x18>
    80003492:	00244697          	auipc	a3,0x244
    80003496:	4ee68693          	addi	a3,a3,1262 # 80247980 <log>
    8000349a:	a039                	j	800034a8 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000349c:	02090963          	beqz	s2,800034ce <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034a0:	08848493          	addi	s1,s1,136
    800034a4:	02d48863          	beq	s1,a3,800034d4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034a8:	449c                	lw	a5,8(s1)
    800034aa:	fef059e3          	blez	a5,8000349c <iget+0x34>
    800034ae:	4098                	lw	a4,0(s1)
    800034b0:	ff3716e3          	bne	a4,s3,8000349c <iget+0x34>
    800034b4:	40d8                	lw	a4,4(s1)
    800034b6:	ff4713e3          	bne	a4,s4,8000349c <iget+0x34>
      ip->ref++;
    800034ba:	2785                	addiw	a5,a5,1
    800034bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034be:	00243517          	auipc	a0,0x243
    800034c2:	a1a50513          	addi	a0,a0,-1510 # 80245ed8 <itable>
    800034c6:	873fd0ef          	jal	ra,80000d38 <release>
      return ip;
    800034ca:	8926                	mv	s2,s1
    800034cc:	a02d                	j	800034f6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ce:	fbe9                	bnez	a5,800034a0 <iget+0x38>
    800034d0:	8926                	mv	s2,s1
    800034d2:	b7f9                	j	800034a0 <iget+0x38>
  if(empty == 0)
    800034d4:	02090a63          	beqz	s2,80003508 <iget+0xa0>
  ip->dev = dev;
    800034d8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034dc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034e0:	4785                	li	a5,1
    800034e2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034e6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034ea:	00243517          	auipc	a0,0x243
    800034ee:	9ee50513          	addi	a0,a0,-1554 # 80245ed8 <itable>
    800034f2:	847fd0ef          	jal	ra,80000d38 <release>
}
    800034f6:	854a                	mv	a0,s2
    800034f8:	70a2                	ld	ra,40(sp)
    800034fa:	7402                	ld	s0,32(sp)
    800034fc:	64e2                	ld	s1,24(sp)
    800034fe:	6942                	ld	s2,16(sp)
    80003500:	69a2                	ld	s3,8(sp)
    80003502:	6a02                	ld	s4,0(sp)
    80003504:	6145                	addi	sp,sp,48
    80003506:	8082                	ret
    panic("iget: no inodes");
    80003508:	00004517          	auipc	a0,0x4
    8000350c:	03050513          	addi	a0,a0,48 # 80007538 <syscalls+0x140>
    80003510:	a78fd0ef          	jal	ra,80000788 <panic>

0000000080003514 <iinit>:
{
    80003514:	7179                	addi	sp,sp,-48
    80003516:	f406                	sd	ra,40(sp)
    80003518:	f022                	sd	s0,32(sp)
    8000351a:	ec26                	sd	s1,24(sp)
    8000351c:	e84a                	sd	s2,16(sp)
    8000351e:	e44e                	sd	s3,8(sp)
    80003520:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003522:	00004597          	auipc	a1,0x4
    80003526:	02658593          	addi	a1,a1,38 # 80007548 <syscalls+0x150>
    8000352a:	00243517          	auipc	a0,0x243
    8000352e:	9ae50513          	addi	a0,a0,-1618 # 80245ed8 <itable>
    80003532:	eeefd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003536:	00243497          	auipc	s1,0x243
    8000353a:	9ca48493          	addi	s1,s1,-1590 # 80245f00 <itable+0x28>
    8000353e:	00244997          	auipc	s3,0x244
    80003542:	45298993          	addi	s3,s3,1106 # 80247990 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003546:	00004917          	auipc	s2,0x4
    8000354a:	00a90913          	addi	s2,s2,10 # 80007550 <syscalls+0x158>
    8000354e:	85ca                	mv	a1,s2
    80003550:	8526                	mv	a0,s1
    80003552:	5b1000ef          	jal	ra,80004302 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003556:	08848493          	addi	s1,s1,136
    8000355a:	ff349ae3          	bne	s1,s3,8000354e <iinit+0x3a>
}
    8000355e:	70a2                	ld	ra,40(sp)
    80003560:	7402                	ld	s0,32(sp)
    80003562:	64e2                	ld	s1,24(sp)
    80003564:	6942                	ld	s2,16(sp)
    80003566:	69a2                	ld	s3,8(sp)
    80003568:	6145                	addi	sp,sp,48
    8000356a:	8082                	ret

000000008000356c <ialloc>:
{
    8000356c:	715d                	addi	sp,sp,-80
    8000356e:	e486                	sd	ra,72(sp)
    80003570:	e0a2                	sd	s0,64(sp)
    80003572:	fc26                	sd	s1,56(sp)
    80003574:	f84a                	sd	s2,48(sp)
    80003576:	f44e                	sd	s3,40(sp)
    80003578:	f052                	sd	s4,32(sp)
    8000357a:	ec56                	sd	s5,24(sp)
    8000357c:	e85a                	sd	s6,16(sp)
    8000357e:	e45e                	sd	s7,8(sp)
    80003580:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003582:	00243717          	auipc	a4,0x243
    80003586:	94272703          	lw	a4,-1726(a4) # 80245ec4 <sb+0xc>
    8000358a:	4785                	li	a5,1
    8000358c:	04e7f663          	bgeu	a5,a4,800035d8 <ialloc+0x6c>
    80003590:	8aaa                	mv	s5,a0
    80003592:	8bae                	mv	s7,a1
    80003594:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003596:	00243a17          	auipc	s4,0x243
    8000359a:	922a0a13          	addi	s4,s4,-1758 # 80245eb8 <sb>
    8000359e:	00048b1b          	sext.w	s6,s1
    800035a2:	0044d593          	srli	a1,s1,0x4
    800035a6:	018a2783          	lw	a5,24(s4)
    800035aa:	9dbd                	addw	a1,a1,a5
    800035ac:	8556                	mv	a0,s5
    800035ae:	a79ff0ef          	jal	ra,80003026 <bread>
    800035b2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035b4:	05850993          	addi	s3,a0,88
    800035b8:	00f4f793          	andi	a5,s1,15
    800035bc:	079a                	slli	a5,a5,0x6
    800035be:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035c0:	00099783          	lh	a5,0(s3)
    800035c4:	cf85                	beqz	a5,800035fc <ialloc+0x90>
    brelse(bp);
    800035c6:	b69ff0ef          	jal	ra,8000312e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ca:	0485                	addi	s1,s1,1
    800035cc:	00ca2703          	lw	a4,12(s4)
    800035d0:	0004879b          	sext.w	a5,s1
    800035d4:	fce7e5e3          	bltu	a5,a4,8000359e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800035d8:	00004517          	auipc	a0,0x4
    800035dc:	f8050513          	addi	a0,a0,-128 # 80007558 <syscalls+0x160>
    800035e0:	ee3fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    800035e4:	4501                	li	a0,0
}
    800035e6:	60a6                	ld	ra,72(sp)
    800035e8:	6406                	ld	s0,64(sp)
    800035ea:	74e2                	ld	s1,56(sp)
    800035ec:	7942                	ld	s2,48(sp)
    800035ee:	79a2                	ld	s3,40(sp)
    800035f0:	7a02                	ld	s4,32(sp)
    800035f2:	6ae2                	ld	s5,24(sp)
    800035f4:	6b42                	ld	s6,16(sp)
    800035f6:	6ba2                	ld	s7,8(sp)
    800035f8:	6161                	addi	sp,sp,80
    800035fa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035fc:	04000613          	li	a2,64
    80003600:	4581                	li	a1,0
    80003602:	854e                	mv	a0,s3
    80003604:	f70fd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    80003608:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000360c:	854a                	mv	a0,s2
    8000360e:	433000ef          	jal	ra,80004240 <log_write>
      brelse(bp);
    80003612:	854a                	mv	a0,s2
    80003614:	b1bff0ef          	jal	ra,8000312e <brelse>
      return iget(dev, inum);
    80003618:	85da                	mv	a1,s6
    8000361a:	8556                	mv	a0,s5
    8000361c:	e4dff0ef          	jal	ra,80003468 <iget>
    80003620:	b7d9                	j	800035e6 <ialloc+0x7a>

0000000080003622 <iupdate>:
{
    80003622:	1101                	addi	sp,sp,-32
    80003624:	ec06                	sd	ra,24(sp)
    80003626:	e822                	sd	s0,16(sp)
    80003628:	e426                	sd	s1,8(sp)
    8000362a:	e04a                	sd	s2,0(sp)
    8000362c:	1000                	addi	s0,sp,32
    8000362e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003630:	415c                	lw	a5,4(a0)
    80003632:	0047d79b          	srliw	a5,a5,0x4
    80003636:	00243597          	auipc	a1,0x243
    8000363a:	89a5a583          	lw	a1,-1894(a1) # 80245ed0 <sb+0x18>
    8000363e:	9dbd                	addw	a1,a1,a5
    80003640:	4108                	lw	a0,0(a0)
    80003642:	9e5ff0ef          	jal	ra,80003026 <bread>
    80003646:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003648:	05850793          	addi	a5,a0,88
    8000364c:	40d8                	lw	a4,4(s1)
    8000364e:	8b3d                	andi	a4,a4,15
    80003650:	071a                	slli	a4,a4,0x6
    80003652:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003654:	04449703          	lh	a4,68(s1)
    80003658:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000365c:	04649703          	lh	a4,70(s1)
    80003660:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003664:	04849703          	lh	a4,72(s1)
    80003668:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000366c:	04a49703          	lh	a4,74(s1)
    80003670:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003674:	44f8                	lw	a4,76(s1)
    80003676:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003678:	03400613          	li	a2,52
    8000367c:	05048593          	addi	a1,s1,80
    80003680:	00c78513          	addi	a0,a5,12
    80003684:	f4cfd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003688:	854a                	mv	a0,s2
    8000368a:	3b7000ef          	jal	ra,80004240 <log_write>
  brelse(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	a9fff0ef          	jal	ra,8000312e <brelse>
}
    80003694:	60e2                	ld	ra,24(sp)
    80003696:	6442                	ld	s0,16(sp)
    80003698:	64a2                	ld	s1,8(sp)
    8000369a:	6902                	ld	s2,0(sp)
    8000369c:	6105                	addi	sp,sp,32
    8000369e:	8082                	ret

00000000800036a0 <idup>:
{
    800036a0:	1101                	addi	sp,sp,-32
    800036a2:	ec06                	sd	ra,24(sp)
    800036a4:	e822                	sd	s0,16(sp)
    800036a6:	e426                	sd	s1,8(sp)
    800036a8:	1000                	addi	s0,sp,32
    800036aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036ac:	00243517          	auipc	a0,0x243
    800036b0:	82c50513          	addi	a0,a0,-2004 # 80245ed8 <itable>
    800036b4:	decfd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    800036b8:	449c                	lw	a5,8(s1)
    800036ba:	2785                	addiw	a5,a5,1
    800036bc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036be:	00243517          	auipc	a0,0x243
    800036c2:	81a50513          	addi	a0,a0,-2022 # 80245ed8 <itable>
    800036c6:	e72fd0ef          	jal	ra,80000d38 <release>
}
    800036ca:	8526                	mv	a0,s1
    800036cc:	60e2                	ld	ra,24(sp)
    800036ce:	6442                	ld	s0,16(sp)
    800036d0:	64a2                	ld	s1,8(sp)
    800036d2:	6105                	addi	sp,sp,32
    800036d4:	8082                	ret

00000000800036d6 <ilock>:
{
    800036d6:	1101                	addi	sp,sp,-32
    800036d8:	ec06                	sd	ra,24(sp)
    800036da:	e822                	sd	s0,16(sp)
    800036dc:	e426                	sd	s1,8(sp)
    800036de:	e04a                	sd	s2,0(sp)
    800036e0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036e2:	c105                	beqz	a0,80003702 <ilock+0x2c>
    800036e4:	84aa                	mv	s1,a0
    800036e6:	451c                	lw	a5,8(a0)
    800036e8:	00f05d63          	blez	a5,80003702 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800036ec:	0541                	addi	a0,a0,16
    800036ee:	44b000ef          	jal	ra,80004338 <acquiresleep>
  if(ip->valid == 0){
    800036f2:	40bc                	lw	a5,64(s1)
    800036f4:	cf89                	beqz	a5,8000370e <ilock+0x38>
}
    800036f6:	60e2                	ld	ra,24(sp)
    800036f8:	6442                	ld	s0,16(sp)
    800036fa:	64a2                	ld	s1,8(sp)
    800036fc:	6902                	ld	s2,0(sp)
    800036fe:	6105                	addi	sp,sp,32
    80003700:	8082                	ret
    panic("ilock");
    80003702:	00004517          	auipc	a0,0x4
    80003706:	e6e50513          	addi	a0,a0,-402 # 80007570 <syscalls+0x178>
    8000370a:	87efd0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000370e:	40dc                	lw	a5,4(s1)
    80003710:	0047d79b          	srliw	a5,a5,0x4
    80003714:	00242597          	auipc	a1,0x242
    80003718:	7bc5a583          	lw	a1,1980(a1) # 80245ed0 <sb+0x18>
    8000371c:	9dbd                	addw	a1,a1,a5
    8000371e:	4088                	lw	a0,0(s1)
    80003720:	907ff0ef          	jal	ra,80003026 <bread>
    80003724:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003726:	05850593          	addi	a1,a0,88
    8000372a:	40dc                	lw	a5,4(s1)
    8000372c:	8bbd                	andi	a5,a5,15
    8000372e:	079a                	slli	a5,a5,0x6
    80003730:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003732:	00059783          	lh	a5,0(a1)
    80003736:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000373a:	00259783          	lh	a5,2(a1)
    8000373e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003742:	00459783          	lh	a5,4(a1)
    80003746:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000374a:	00659783          	lh	a5,6(a1)
    8000374e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003752:	459c                	lw	a5,8(a1)
    80003754:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003756:	03400613          	li	a2,52
    8000375a:	05b1                	addi	a1,a1,12
    8000375c:	05048513          	addi	a0,s1,80
    80003760:	e70fd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    80003764:	854a                	mv	a0,s2
    80003766:	9c9ff0ef          	jal	ra,8000312e <brelse>
    ip->valid = 1;
    8000376a:	4785                	li	a5,1
    8000376c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000376e:	04449783          	lh	a5,68(s1)
    80003772:	f3d1                	bnez	a5,800036f6 <ilock+0x20>
      panic("ilock: no type");
    80003774:	00004517          	auipc	a0,0x4
    80003778:	e0450513          	addi	a0,a0,-508 # 80007578 <syscalls+0x180>
    8000377c:	80cfd0ef          	jal	ra,80000788 <panic>

0000000080003780 <iunlock>:
{
    80003780:	1101                	addi	sp,sp,-32
    80003782:	ec06                	sd	ra,24(sp)
    80003784:	e822                	sd	s0,16(sp)
    80003786:	e426                	sd	s1,8(sp)
    80003788:	e04a                	sd	s2,0(sp)
    8000378a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000378c:	c505                	beqz	a0,800037b4 <iunlock+0x34>
    8000378e:	84aa                	mv	s1,a0
    80003790:	01050913          	addi	s2,a0,16
    80003794:	854a                	mv	a0,s2
    80003796:	421000ef          	jal	ra,800043b6 <holdingsleep>
    8000379a:	cd09                	beqz	a0,800037b4 <iunlock+0x34>
    8000379c:	449c                	lw	a5,8(s1)
    8000379e:	00f05b63          	blez	a5,800037b4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800037a2:	854a                	mv	a0,s2
    800037a4:	3db000ef          	jal	ra,8000437e <releasesleep>
}
    800037a8:	60e2                	ld	ra,24(sp)
    800037aa:	6442                	ld	s0,16(sp)
    800037ac:	64a2                	ld	s1,8(sp)
    800037ae:	6902                	ld	s2,0(sp)
    800037b0:	6105                	addi	sp,sp,32
    800037b2:	8082                	ret
    panic("iunlock");
    800037b4:	00004517          	auipc	a0,0x4
    800037b8:	dd450513          	addi	a0,a0,-556 # 80007588 <syscalls+0x190>
    800037bc:	fcdfc0ef          	jal	ra,80000788 <panic>

00000000800037c0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037c0:	7179                	addi	sp,sp,-48
    800037c2:	f406                	sd	ra,40(sp)
    800037c4:	f022                	sd	s0,32(sp)
    800037c6:	ec26                	sd	s1,24(sp)
    800037c8:	e84a                	sd	s2,16(sp)
    800037ca:	e44e                	sd	s3,8(sp)
    800037cc:	e052                	sd	s4,0(sp)
    800037ce:	1800                	addi	s0,sp,48
    800037d0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037d2:	05050493          	addi	s1,a0,80
    800037d6:	08050913          	addi	s2,a0,128
    800037da:	a021                	j	800037e2 <itrunc+0x22>
    800037dc:	0491                	addi	s1,s1,4
    800037de:	01248b63          	beq	s1,s2,800037f4 <itrunc+0x34>
    if(ip->addrs[i]){
    800037e2:	408c                	lw	a1,0(s1)
    800037e4:	dde5                	beqz	a1,800037dc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037e6:	0009a503          	lw	a0,0(s3)
    800037ea:	a37ff0ef          	jal	ra,80003220 <bfree>
      ip->addrs[i] = 0;
    800037ee:	0004a023          	sw	zero,0(s1)
    800037f2:	b7ed                	j	800037dc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037f4:	0809a583          	lw	a1,128(s3)
    800037f8:	ed91                	bnez	a1,80003814 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037fa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037fe:	854e                	mv	a0,s3
    80003800:	e23ff0ef          	jal	ra,80003622 <iupdate>
}
    80003804:	70a2                	ld	ra,40(sp)
    80003806:	7402                	ld	s0,32(sp)
    80003808:	64e2                	ld	s1,24(sp)
    8000380a:	6942                	ld	s2,16(sp)
    8000380c:	69a2                	ld	s3,8(sp)
    8000380e:	6a02                	ld	s4,0(sp)
    80003810:	6145                	addi	sp,sp,48
    80003812:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003814:	0009a503          	lw	a0,0(s3)
    80003818:	80fff0ef          	jal	ra,80003026 <bread>
    8000381c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000381e:	05850493          	addi	s1,a0,88
    80003822:	45850913          	addi	s2,a0,1112
    80003826:	a021                	j	8000382e <itrunc+0x6e>
    80003828:	0491                	addi	s1,s1,4
    8000382a:	01248963          	beq	s1,s2,8000383c <itrunc+0x7c>
      if(a[j])
    8000382e:	408c                	lw	a1,0(s1)
    80003830:	dde5                	beqz	a1,80003828 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003832:	0009a503          	lw	a0,0(s3)
    80003836:	9ebff0ef          	jal	ra,80003220 <bfree>
    8000383a:	b7fd                	j	80003828 <itrunc+0x68>
    brelse(bp);
    8000383c:	8552                	mv	a0,s4
    8000383e:	8f1ff0ef          	jal	ra,8000312e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003842:	0809a583          	lw	a1,128(s3)
    80003846:	0009a503          	lw	a0,0(s3)
    8000384a:	9d7ff0ef          	jal	ra,80003220 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000384e:	0809a023          	sw	zero,128(s3)
    80003852:	b765                	j	800037fa <itrunc+0x3a>

0000000080003854 <iput>:
{
    80003854:	1101                	addi	sp,sp,-32
    80003856:	ec06                	sd	ra,24(sp)
    80003858:	e822                	sd	s0,16(sp)
    8000385a:	e426                	sd	s1,8(sp)
    8000385c:	e04a                	sd	s2,0(sp)
    8000385e:	1000                	addi	s0,sp,32
    80003860:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003862:	00242517          	auipc	a0,0x242
    80003866:	67650513          	addi	a0,a0,1654 # 80245ed8 <itable>
    8000386a:	c36fd0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000386e:	4498                	lw	a4,8(s1)
    80003870:	4785                	li	a5,1
    80003872:	02f70163          	beq	a4,a5,80003894 <iput+0x40>
  ip->ref--;
    80003876:	449c                	lw	a5,8(s1)
    80003878:	37fd                	addiw	a5,a5,-1
    8000387a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000387c:	00242517          	auipc	a0,0x242
    80003880:	65c50513          	addi	a0,a0,1628 # 80245ed8 <itable>
    80003884:	cb4fd0ef          	jal	ra,80000d38 <release>
}
    80003888:	60e2                	ld	ra,24(sp)
    8000388a:	6442                	ld	s0,16(sp)
    8000388c:	64a2                	ld	s1,8(sp)
    8000388e:	6902                	ld	s2,0(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003894:	40bc                	lw	a5,64(s1)
    80003896:	d3e5                	beqz	a5,80003876 <iput+0x22>
    80003898:	04a49783          	lh	a5,74(s1)
    8000389c:	ffe9                	bnez	a5,80003876 <iput+0x22>
    acquiresleep(&ip->lock);
    8000389e:	01048913          	addi	s2,s1,16
    800038a2:	854a                	mv	a0,s2
    800038a4:	295000ef          	jal	ra,80004338 <acquiresleep>
    release(&itable.lock);
    800038a8:	00242517          	auipc	a0,0x242
    800038ac:	63050513          	addi	a0,a0,1584 # 80245ed8 <itable>
    800038b0:	c88fd0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    800038b4:	8526                	mv	a0,s1
    800038b6:	f0bff0ef          	jal	ra,800037c0 <itrunc>
    ip->type = 0;
    800038ba:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038be:	8526                	mv	a0,s1
    800038c0:	d63ff0ef          	jal	ra,80003622 <iupdate>
    ip->valid = 0;
    800038c4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038c8:	854a                	mv	a0,s2
    800038ca:	2b5000ef          	jal	ra,8000437e <releasesleep>
    acquire(&itable.lock);
    800038ce:	00242517          	auipc	a0,0x242
    800038d2:	60a50513          	addi	a0,a0,1546 # 80245ed8 <itable>
    800038d6:	bcafd0ef          	jal	ra,80000ca0 <acquire>
    800038da:	bf71                	j	80003876 <iput+0x22>

00000000800038dc <iunlockput>:
{
    800038dc:	1101                	addi	sp,sp,-32
    800038de:	ec06                	sd	ra,24(sp)
    800038e0:	e822                	sd	s0,16(sp)
    800038e2:	e426                	sd	s1,8(sp)
    800038e4:	1000                	addi	s0,sp,32
    800038e6:	84aa                	mv	s1,a0
  iunlock(ip);
    800038e8:	e99ff0ef          	jal	ra,80003780 <iunlock>
  iput(ip);
    800038ec:	8526                	mv	a0,s1
    800038ee:	f67ff0ef          	jal	ra,80003854 <iput>
}
    800038f2:	60e2                	ld	ra,24(sp)
    800038f4:	6442                	ld	s0,16(sp)
    800038f6:	64a2                	ld	s1,8(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret

00000000800038fc <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800038fc:	00242717          	auipc	a4,0x242
    80003900:	5c872703          	lw	a4,1480(a4) # 80245ec4 <sb+0xc>
    80003904:	4785                	li	a5,1
    80003906:	0ae7ff63          	bgeu	a5,a4,800039c4 <ireclaim+0xc8>
{
    8000390a:	7139                	addi	sp,sp,-64
    8000390c:	fc06                	sd	ra,56(sp)
    8000390e:	f822                	sd	s0,48(sp)
    80003910:	f426                	sd	s1,40(sp)
    80003912:	f04a                	sd	s2,32(sp)
    80003914:	ec4e                	sd	s3,24(sp)
    80003916:	e852                	sd	s4,16(sp)
    80003918:	e456                	sd	s5,8(sp)
    8000391a:	e05a                	sd	s6,0(sp)
    8000391c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000391e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003920:	00050a1b          	sext.w	s4,a0
    80003924:	00242a97          	auipc	s5,0x242
    80003928:	594a8a93          	addi	s5,s5,1428 # 80245eb8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000392c:	00004b17          	auipc	s6,0x4
    80003930:	c64b0b13          	addi	s6,s6,-924 # 80007590 <syscalls+0x198>
    80003934:	a099                	j	8000397a <ireclaim+0x7e>
    80003936:	85ce                	mv	a1,s3
    80003938:	855a                	mv	a0,s6
    8000393a:	b89fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    8000393e:	85ce                	mv	a1,s3
    80003940:	8552                	mv	a0,s4
    80003942:	b27ff0ef          	jal	ra,80003468 <iget>
    80003946:	89aa                	mv	s3,a0
    brelse(bp);
    80003948:	854a                	mv	a0,s2
    8000394a:	fe4ff0ef          	jal	ra,8000312e <brelse>
    if (ip) {
    8000394e:	00098f63          	beqz	s3,8000396c <ireclaim+0x70>
      begin_op();
    80003952:	76c000ef          	jal	ra,800040be <begin_op>
      ilock(ip);
    80003956:	854e                	mv	a0,s3
    80003958:	d7fff0ef          	jal	ra,800036d6 <ilock>
      iunlock(ip);
    8000395c:	854e                	mv	a0,s3
    8000395e:	e23ff0ef          	jal	ra,80003780 <iunlock>
      iput(ip);
    80003962:	854e                	mv	a0,s3
    80003964:	ef1ff0ef          	jal	ra,80003854 <iput>
      end_op();
    80003968:	7c4000ef          	jal	ra,8000412c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000396c:	0485                	addi	s1,s1,1
    8000396e:	00caa703          	lw	a4,12(s5)
    80003972:	0004879b          	sext.w	a5,s1
    80003976:	02e7fd63          	bgeu	a5,a4,800039b0 <ireclaim+0xb4>
    8000397a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000397e:	0044d593          	srli	a1,s1,0x4
    80003982:	018aa783          	lw	a5,24(s5)
    80003986:	9dbd                	addw	a1,a1,a5
    80003988:	8552                	mv	a0,s4
    8000398a:	e9cff0ef          	jal	ra,80003026 <bread>
    8000398e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003990:	05850793          	addi	a5,a0,88
    80003994:	00f9f713          	andi	a4,s3,15
    80003998:	071a                	slli	a4,a4,0x6
    8000399a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000399c:	00079703          	lh	a4,0(a5)
    800039a0:	c701                	beqz	a4,800039a8 <ireclaim+0xac>
    800039a2:	00679783          	lh	a5,6(a5)
    800039a6:	dbc1                	beqz	a5,80003936 <ireclaim+0x3a>
    brelse(bp);
    800039a8:	854a                	mv	a0,s2
    800039aa:	f84ff0ef          	jal	ra,8000312e <brelse>
    if (ip) {
    800039ae:	bf7d                	j	8000396c <ireclaim+0x70>
}
    800039b0:	70e2                	ld	ra,56(sp)
    800039b2:	7442                	ld	s0,48(sp)
    800039b4:	74a2                	ld	s1,40(sp)
    800039b6:	7902                	ld	s2,32(sp)
    800039b8:	69e2                	ld	s3,24(sp)
    800039ba:	6a42                	ld	s4,16(sp)
    800039bc:	6aa2                	ld	s5,8(sp)
    800039be:	6b02                	ld	s6,0(sp)
    800039c0:	6121                	addi	sp,sp,64
    800039c2:	8082                	ret
    800039c4:	8082                	ret

00000000800039c6 <fsinit>:
fsinit(int dev) {
    800039c6:	7179                	addi	sp,sp,-48
    800039c8:	f406                	sd	ra,40(sp)
    800039ca:	f022                	sd	s0,32(sp)
    800039cc:	ec26                	sd	s1,24(sp)
    800039ce:	e84a                	sd	s2,16(sp)
    800039d0:	e44e                	sd	s3,8(sp)
    800039d2:	1800                	addi	s0,sp,48
    800039d4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800039d6:	4585                	li	a1,1
    800039d8:	e4eff0ef          	jal	ra,80003026 <bread>
    800039dc:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039de:	00242997          	auipc	s3,0x242
    800039e2:	4da98993          	addi	s3,s3,1242 # 80245eb8 <sb>
    800039e6:	02000613          	li	a2,32
    800039ea:	05850593          	addi	a1,a0,88
    800039ee:	854e                	mv	a0,s3
    800039f0:	be0fd0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    800039f4:	854a                	mv	a0,s2
    800039f6:	f38ff0ef          	jal	ra,8000312e <brelse>
  if(sb.magic != FSMAGIC)
    800039fa:	0009a703          	lw	a4,0(s3)
    800039fe:	102037b7          	lui	a5,0x10203
    80003a02:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a06:	02f71363          	bne	a4,a5,80003a2c <fsinit+0x66>
  initlog(dev, &sb);
    80003a0a:	00242597          	auipc	a1,0x242
    80003a0e:	4ae58593          	addi	a1,a1,1198 # 80245eb8 <sb>
    80003a12:	8526                	mv	a0,s1
    80003a14:	61e000ef          	jal	ra,80004032 <initlog>
  ireclaim(dev);
    80003a18:	8526                	mv	a0,s1
    80003a1a:	ee3ff0ef          	jal	ra,800038fc <ireclaim>
}
    80003a1e:	70a2                	ld	ra,40(sp)
    80003a20:	7402                	ld	s0,32(sp)
    80003a22:	64e2                	ld	s1,24(sp)
    80003a24:	6942                	ld	s2,16(sp)
    80003a26:	69a2                	ld	s3,8(sp)
    80003a28:	6145                	addi	sp,sp,48
    80003a2a:	8082                	ret
    panic("invalid file system");
    80003a2c:	00004517          	auipc	a0,0x4
    80003a30:	b8450513          	addi	a0,a0,-1148 # 800075b0 <syscalls+0x1b8>
    80003a34:	d55fc0ef          	jal	ra,80000788 <panic>

0000000080003a38 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a38:	1141                	addi	sp,sp,-16
    80003a3a:	e422                	sd	s0,8(sp)
    80003a3c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a3e:	411c                	lw	a5,0(a0)
    80003a40:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a42:	415c                	lw	a5,4(a0)
    80003a44:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a46:	04451783          	lh	a5,68(a0)
    80003a4a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a4e:	04a51783          	lh	a5,74(a0)
    80003a52:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a56:	04c56783          	lwu	a5,76(a0)
    80003a5a:	e99c                	sd	a5,16(a1)
}
    80003a5c:	6422                	ld	s0,8(sp)
    80003a5e:	0141                	addi	sp,sp,16
    80003a60:	8082                	ret

0000000080003a62 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a62:	457c                	lw	a5,76(a0)
    80003a64:	0cd7ef63          	bltu	a5,a3,80003b42 <readi+0xe0>
{
    80003a68:	7159                	addi	sp,sp,-112
    80003a6a:	f486                	sd	ra,104(sp)
    80003a6c:	f0a2                	sd	s0,96(sp)
    80003a6e:	eca6                	sd	s1,88(sp)
    80003a70:	e8ca                	sd	s2,80(sp)
    80003a72:	e4ce                	sd	s3,72(sp)
    80003a74:	e0d2                	sd	s4,64(sp)
    80003a76:	fc56                	sd	s5,56(sp)
    80003a78:	f85a                	sd	s6,48(sp)
    80003a7a:	f45e                	sd	s7,40(sp)
    80003a7c:	f062                	sd	s8,32(sp)
    80003a7e:	ec66                	sd	s9,24(sp)
    80003a80:	e86a                	sd	s10,16(sp)
    80003a82:	e46e                	sd	s11,8(sp)
    80003a84:	1880                	addi	s0,sp,112
    80003a86:	8b2a                	mv	s6,a0
    80003a88:	8bae                	mv	s7,a1
    80003a8a:	8a32                	mv	s4,a2
    80003a8c:	84b6                	mv	s1,a3
    80003a8e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a90:	9f35                	addw	a4,a4,a3
    return 0;
    80003a92:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a94:	08d76663          	bltu	a4,a3,80003b20 <readi+0xbe>
  if(off + n > ip->size)
    80003a98:	00e7f463          	bgeu	a5,a4,80003aa0 <readi+0x3e>
    n = ip->size - off;
    80003a9c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa0:	080a8f63          	beqz	s5,80003b3e <readi+0xdc>
    80003aa4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aa6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003aaa:	5c7d                	li	s8,-1
    80003aac:	a80d                	j	80003ade <readi+0x7c>
    80003aae:	020d1d93          	slli	s11,s10,0x20
    80003ab2:	020ddd93          	srli	s11,s11,0x20
    80003ab6:	05890613          	addi	a2,s2,88
    80003aba:	86ee                	mv	a3,s11
    80003abc:	963a                	add	a2,a2,a4
    80003abe:	85d2                	mv	a1,s4
    80003ac0:	855e                	mv	a0,s7
    80003ac2:	a0bfe0ef          	jal	ra,800024cc <either_copyout>
    80003ac6:	05850763          	beq	a0,s8,80003b14 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003aca:	854a                	mv	a0,s2
    80003acc:	e62ff0ef          	jal	ra,8000312e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ad0:	013d09bb          	addw	s3,s10,s3
    80003ad4:	009d04bb          	addw	s1,s10,s1
    80003ad8:	9a6e                	add	s4,s4,s11
    80003ada:	0559f163          	bgeu	s3,s5,80003b1c <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003ade:	00a4d59b          	srliw	a1,s1,0xa
    80003ae2:	855a                	mv	a0,s6
    80003ae4:	8b7ff0ef          	jal	ra,8000339a <bmap>
    80003ae8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003aec:	c985                	beqz	a1,80003b1c <readi+0xba>
    bp = bread(ip->dev, addr);
    80003aee:	000b2503          	lw	a0,0(s6)
    80003af2:	d34ff0ef          	jal	ra,80003026 <bread>
    80003af6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af8:	3ff4f713          	andi	a4,s1,1023
    80003afc:	40ec87bb          	subw	a5,s9,a4
    80003b00:	413a86bb          	subw	a3,s5,s3
    80003b04:	8d3e                	mv	s10,a5
    80003b06:	2781                	sext.w	a5,a5
    80003b08:	0006861b          	sext.w	a2,a3
    80003b0c:	faf671e3          	bgeu	a2,a5,80003aae <readi+0x4c>
    80003b10:	8d36                	mv	s10,a3
    80003b12:	bf71                	j	80003aae <readi+0x4c>
      brelse(bp);
    80003b14:	854a                	mv	a0,s2
    80003b16:	e18ff0ef          	jal	ra,8000312e <brelse>
      tot = -1;
    80003b1a:	59fd                	li	s3,-1
  }
  return tot;
    80003b1c:	0009851b          	sext.w	a0,s3
}
    80003b20:	70a6                	ld	ra,104(sp)
    80003b22:	7406                	ld	s0,96(sp)
    80003b24:	64e6                	ld	s1,88(sp)
    80003b26:	6946                	ld	s2,80(sp)
    80003b28:	69a6                	ld	s3,72(sp)
    80003b2a:	6a06                	ld	s4,64(sp)
    80003b2c:	7ae2                	ld	s5,56(sp)
    80003b2e:	7b42                	ld	s6,48(sp)
    80003b30:	7ba2                	ld	s7,40(sp)
    80003b32:	7c02                	ld	s8,32(sp)
    80003b34:	6ce2                	ld	s9,24(sp)
    80003b36:	6d42                	ld	s10,16(sp)
    80003b38:	6da2                	ld	s11,8(sp)
    80003b3a:	6165                	addi	sp,sp,112
    80003b3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b3e:	89d6                	mv	s3,s5
    80003b40:	bff1                	j	80003b1c <readi+0xba>
    return 0;
    80003b42:	4501                	li	a0,0
}
    80003b44:	8082                	ret

0000000080003b46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b46:	457c                	lw	a5,76(a0)
    80003b48:	0ed7ea63          	bltu	a5,a3,80003c3c <writei+0xf6>
{
    80003b4c:	7159                	addi	sp,sp,-112
    80003b4e:	f486                	sd	ra,104(sp)
    80003b50:	f0a2                	sd	s0,96(sp)
    80003b52:	eca6                	sd	s1,88(sp)
    80003b54:	e8ca                	sd	s2,80(sp)
    80003b56:	e4ce                	sd	s3,72(sp)
    80003b58:	e0d2                	sd	s4,64(sp)
    80003b5a:	fc56                	sd	s5,56(sp)
    80003b5c:	f85a                	sd	s6,48(sp)
    80003b5e:	f45e                	sd	s7,40(sp)
    80003b60:	f062                	sd	s8,32(sp)
    80003b62:	ec66                	sd	s9,24(sp)
    80003b64:	e86a                	sd	s10,16(sp)
    80003b66:	e46e                	sd	s11,8(sp)
    80003b68:	1880                	addi	s0,sp,112
    80003b6a:	8aaa                	mv	s5,a0
    80003b6c:	8bae                	mv	s7,a1
    80003b6e:	8a32                	mv	s4,a2
    80003b70:	8936                	mv	s2,a3
    80003b72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b74:	00e687bb          	addw	a5,a3,a4
    80003b78:	0cd7e463          	bltu	a5,a3,80003c40 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b7c:	00043737          	lui	a4,0x43
    80003b80:	0cf76263          	bltu	a4,a5,80003c44 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b84:	0a0b0a63          	beqz	s6,80003c38 <writei+0xf2>
    80003b88:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b8a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b8e:	5c7d                	li	s8,-1
    80003b90:	a825                	j	80003bc8 <writei+0x82>
    80003b92:	020d1d93          	slli	s11,s10,0x20
    80003b96:	020ddd93          	srli	s11,s11,0x20
    80003b9a:	05848513          	addi	a0,s1,88
    80003b9e:	86ee                	mv	a3,s11
    80003ba0:	8652                	mv	a2,s4
    80003ba2:	85de                	mv	a1,s7
    80003ba4:	953a                	add	a0,a0,a4
    80003ba6:	971fe0ef          	jal	ra,80002516 <either_copyin>
    80003baa:	05850a63          	beq	a0,s8,80003bfe <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bae:	8526                	mv	a0,s1
    80003bb0:	690000ef          	jal	ra,80004240 <log_write>
    brelse(bp);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	d78ff0ef          	jal	ra,8000312e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bba:	013d09bb          	addw	s3,s10,s3
    80003bbe:	012d093b          	addw	s2,s10,s2
    80003bc2:	9a6e                	add	s4,s4,s11
    80003bc4:	0569f063          	bgeu	s3,s6,80003c04 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003bc8:	00a9559b          	srliw	a1,s2,0xa
    80003bcc:	8556                	mv	a0,s5
    80003bce:	fccff0ef          	jal	ra,8000339a <bmap>
    80003bd2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bd6:	c59d                	beqz	a1,80003c04 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003bd8:	000aa503          	lw	a0,0(s5)
    80003bdc:	c4aff0ef          	jal	ra,80003026 <bread>
    80003be0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be2:	3ff97713          	andi	a4,s2,1023
    80003be6:	40ec87bb          	subw	a5,s9,a4
    80003bea:	413b06bb          	subw	a3,s6,s3
    80003bee:	8d3e                	mv	s10,a5
    80003bf0:	2781                	sext.w	a5,a5
    80003bf2:	0006861b          	sext.w	a2,a3
    80003bf6:	f8f67ee3          	bgeu	a2,a5,80003b92 <writei+0x4c>
    80003bfa:	8d36                	mv	s10,a3
    80003bfc:	bf59                	j	80003b92 <writei+0x4c>
      brelse(bp);
    80003bfe:	8526                	mv	a0,s1
    80003c00:	d2eff0ef          	jal	ra,8000312e <brelse>
  }

  if(off > ip->size)
    80003c04:	04caa783          	lw	a5,76(s5)
    80003c08:	0127f463          	bgeu	a5,s2,80003c10 <writei+0xca>
    ip->size = off;
    80003c0c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c10:	8556                	mv	a0,s5
    80003c12:	a11ff0ef          	jal	ra,80003622 <iupdate>

  return tot;
    80003c16:	0009851b          	sext.w	a0,s3
}
    80003c1a:	70a6                	ld	ra,104(sp)
    80003c1c:	7406                	ld	s0,96(sp)
    80003c1e:	64e6                	ld	s1,88(sp)
    80003c20:	6946                	ld	s2,80(sp)
    80003c22:	69a6                	ld	s3,72(sp)
    80003c24:	6a06                	ld	s4,64(sp)
    80003c26:	7ae2                	ld	s5,56(sp)
    80003c28:	7b42                	ld	s6,48(sp)
    80003c2a:	7ba2                	ld	s7,40(sp)
    80003c2c:	7c02                	ld	s8,32(sp)
    80003c2e:	6ce2                	ld	s9,24(sp)
    80003c30:	6d42                	ld	s10,16(sp)
    80003c32:	6da2                	ld	s11,8(sp)
    80003c34:	6165                	addi	sp,sp,112
    80003c36:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c38:	89da                	mv	s3,s6
    80003c3a:	bfd9                	j	80003c10 <writei+0xca>
    return -1;
    80003c3c:	557d                	li	a0,-1
}
    80003c3e:	8082                	ret
    return -1;
    80003c40:	557d                	li	a0,-1
    80003c42:	bfe1                	j	80003c1a <writei+0xd4>
    return -1;
    80003c44:	557d                	li	a0,-1
    80003c46:	bfd1                	j	80003c1a <writei+0xd4>

0000000080003c48 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c48:	1141                	addi	sp,sp,-16
    80003c4a:	e406                	sd	ra,8(sp)
    80003c4c:	e022                	sd	s0,0(sp)
    80003c4e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c50:	4639                	li	a2,14
    80003c52:	9eefd0ef          	jal	ra,80000e40 <strncmp>
}
    80003c56:	60a2                	ld	ra,8(sp)
    80003c58:	6402                	ld	s0,0(sp)
    80003c5a:	0141                	addi	sp,sp,16
    80003c5c:	8082                	ret

0000000080003c5e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c5e:	7139                	addi	sp,sp,-64
    80003c60:	fc06                	sd	ra,56(sp)
    80003c62:	f822                	sd	s0,48(sp)
    80003c64:	f426                	sd	s1,40(sp)
    80003c66:	f04a                	sd	s2,32(sp)
    80003c68:	ec4e                	sd	s3,24(sp)
    80003c6a:	e852                	sd	s4,16(sp)
    80003c6c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c6e:	04451703          	lh	a4,68(a0)
    80003c72:	4785                	li	a5,1
    80003c74:	00f71a63          	bne	a4,a5,80003c88 <dirlookup+0x2a>
    80003c78:	892a                	mv	s2,a0
    80003c7a:	89ae                	mv	s3,a1
    80003c7c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c7e:	457c                	lw	a5,76(a0)
    80003c80:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c82:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c84:	e39d                	bnez	a5,80003caa <dirlookup+0x4c>
    80003c86:	a095                	j	80003cea <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003c88:	00004517          	auipc	a0,0x4
    80003c8c:	94050513          	addi	a0,a0,-1728 # 800075c8 <syscalls+0x1d0>
    80003c90:	af9fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80003c94:	00004517          	auipc	a0,0x4
    80003c98:	94c50513          	addi	a0,a0,-1716 # 800075e0 <syscalls+0x1e8>
    80003c9c:	aedfc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ca0:	24c1                	addiw	s1,s1,16
    80003ca2:	04c92783          	lw	a5,76(s2)
    80003ca6:	04f4f163          	bgeu	s1,a5,80003ce8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003caa:	4741                	li	a4,16
    80003cac:	86a6                	mv	a3,s1
    80003cae:	fc040613          	addi	a2,s0,-64
    80003cb2:	4581                	li	a1,0
    80003cb4:	854a                	mv	a0,s2
    80003cb6:	dadff0ef          	jal	ra,80003a62 <readi>
    80003cba:	47c1                	li	a5,16
    80003cbc:	fcf51ce3          	bne	a0,a5,80003c94 <dirlookup+0x36>
    if(de.inum == 0)
    80003cc0:	fc045783          	lhu	a5,-64(s0)
    80003cc4:	dff1                	beqz	a5,80003ca0 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003cc6:	fc240593          	addi	a1,s0,-62
    80003cca:	854e                	mv	a0,s3
    80003ccc:	f7dff0ef          	jal	ra,80003c48 <namecmp>
    80003cd0:	f961                	bnez	a0,80003ca0 <dirlookup+0x42>
      if(poff)
    80003cd2:	000a0463          	beqz	s4,80003cda <dirlookup+0x7c>
        *poff = off;
    80003cd6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cda:	fc045583          	lhu	a1,-64(s0)
    80003cde:	00092503          	lw	a0,0(s2)
    80003ce2:	f86ff0ef          	jal	ra,80003468 <iget>
    80003ce6:	a011                	j	80003cea <dirlookup+0x8c>
  return 0;
    80003ce8:	4501                	li	a0,0
}
    80003cea:	70e2                	ld	ra,56(sp)
    80003cec:	7442                	ld	s0,48(sp)
    80003cee:	74a2                	ld	s1,40(sp)
    80003cf0:	7902                	ld	s2,32(sp)
    80003cf2:	69e2                	ld	s3,24(sp)
    80003cf4:	6a42                	ld	s4,16(sp)
    80003cf6:	6121                	addi	sp,sp,64
    80003cf8:	8082                	ret

0000000080003cfa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cfa:	711d                	addi	sp,sp,-96
    80003cfc:	ec86                	sd	ra,88(sp)
    80003cfe:	e8a2                	sd	s0,80(sp)
    80003d00:	e4a6                	sd	s1,72(sp)
    80003d02:	e0ca                	sd	s2,64(sp)
    80003d04:	fc4e                	sd	s3,56(sp)
    80003d06:	f852                	sd	s4,48(sp)
    80003d08:	f456                	sd	s5,40(sp)
    80003d0a:	f05a                	sd	s6,32(sp)
    80003d0c:	ec5e                	sd	s7,24(sp)
    80003d0e:	e862                	sd	s8,16(sp)
    80003d10:	e466                	sd	s9,8(sp)
    80003d12:	e06a                	sd	s10,0(sp)
    80003d14:	1080                	addi	s0,sp,96
    80003d16:	84aa                	mv	s1,a0
    80003d18:	8b2e                	mv	s6,a1
    80003d1a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d1c:	00054703          	lbu	a4,0(a0)
    80003d20:	02f00793          	li	a5,47
    80003d24:	00f70f63          	beq	a4,a5,80003d42 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d28:	ddbfd0ef          	jal	ra,80001b02 <myproc>
    80003d2c:	15053503          	ld	a0,336(a0)
    80003d30:	971ff0ef          	jal	ra,800036a0 <idup>
    80003d34:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d36:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d3a:	4cb5                	li	s9,13
  len = path - s;
    80003d3c:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d3e:	4c05                	li	s8,1
    80003d40:	a879                	j	80003dde <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003d42:	4585                	li	a1,1
    80003d44:	4505                	li	a0,1
    80003d46:	f22ff0ef          	jal	ra,80003468 <iget>
    80003d4a:	8a2a                	mv	s4,a0
    80003d4c:	b7ed                	j	80003d36 <namex+0x3c>
      iunlockput(ip);
    80003d4e:	8552                	mv	a0,s4
    80003d50:	b8dff0ef          	jal	ra,800038dc <iunlockput>
      return 0;
    80003d54:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d56:	8552                	mv	a0,s4
    80003d58:	60e6                	ld	ra,88(sp)
    80003d5a:	6446                	ld	s0,80(sp)
    80003d5c:	64a6                	ld	s1,72(sp)
    80003d5e:	6906                	ld	s2,64(sp)
    80003d60:	79e2                	ld	s3,56(sp)
    80003d62:	7a42                	ld	s4,48(sp)
    80003d64:	7aa2                	ld	s5,40(sp)
    80003d66:	7b02                	ld	s6,32(sp)
    80003d68:	6be2                	ld	s7,24(sp)
    80003d6a:	6c42                	ld	s8,16(sp)
    80003d6c:	6ca2                	ld	s9,8(sp)
    80003d6e:	6d02                	ld	s10,0(sp)
    80003d70:	6125                	addi	sp,sp,96
    80003d72:	8082                	ret
      iunlock(ip);
    80003d74:	8552                	mv	a0,s4
    80003d76:	a0bff0ef          	jal	ra,80003780 <iunlock>
      return ip;
    80003d7a:	bff1                	j	80003d56 <namex+0x5c>
      iunlockput(ip);
    80003d7c:	8552                	mv	a0,s4
    80003d7e:	b5fff0ef          	jal	ra,800038dc <iunlockput>
      return 0;
    80003d82:	8a4e                	mv	s4,s3
    80003d84:	bfc9                	j	80003d56 <namex+0x5c>
  len = path - s;
    80003d86:	40998633          	sub	a2,s3,s1
    80003d8a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d8e:	09acd063          	bge	s9,s10,80003e0e <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003d92:	4639                	li	a2,14
    80003d94:	85a6                	mv	a1,s1
    80003d96:	8556                	mv	a0,s5
    80003d98:	838fd0ef          	jal	ra,80000dd0 <memmove>
    80003d9c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d9e:	0004c783          	lbu	a5,0(s1)
    80003da2:	01279763          	bne	a5,s2,80003db0 <namex+0xb6>
    path++;
    80003da6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da8:	0004c783          	lbu	a5,0(s1)
    80003dac:	ff278de3          	beq	a5,s2,80003da6 <namex+0xac>
    ilock(ip);
    80003db0:	8552                	mv	a0,s4
    80003db2:	925ff0ef          	jal	ra,800036d6 <ilock>
    if(ip->type != T_DIR){
    80003db6:	044a1783          	lh	a5,68(s4)
    80003dba:	f9879ae3          	bne	a5,s8,80003d4e <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003dbe:	000b0563          	beqz	s6,80003dc8 <namex+0xce>
    80003dc2:	0004c783          	lbu	a5,0(s1)
    80003dc6:	d7dd                	beqz	a5,80003d74 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dc8:	865e                	mv	a2,s7
    80003dca:	85d6                	mv	a1,s5
    80003dcc:	8552                	mv	a0,s4
    80003dce:	e91ff0ef          	jal	ra,80003c5e <dirlookup>
    80003dd2:	89aa                	mv	s3,a0
    80003dd4:	d545                	beqz	a0,80003d7c <namex+0x82>
    iunlockput(ip);
    80003dd6:	8552                	mv	a0,s4
    80003dd8:	b05ff0ef          	jal	ra,800038dc <iunlockput>
    ip = next;
    80003ddc:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003dde:	0004c783          	lbu	a5,0(s1)
    80003de2:	01279763          	bne	a5,s2,80003df0 <namex+0xf6>
    path++;
    80003de6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003de8:	0004c783          	lbu	a5,0(s1)
    80003dec:	ff278de3          	beq	a5,s2,80003de6 <namex+0xec>
  if(*path == 0)
    80003df0:	cb8d                	beqz	a5,80003e22 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003df2:	0004c783          	lbu	a5,0(s1)
    80003df6:	89a6                	mv	s3,s1
  len = path - s;
    80003df8:	8d5e                	mv	s10,s7
    80003dfa:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003dfc:	01278963          	beq	a5,s2,80003e0e <namex+0x114>
    80003e00:	d3d9                	beqz	a5,80003d86 <namex+0x8c>
    path++;
    80003e02:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e04:	0009c783          	lbu	a5,0(s3)
    80003e08:	ff279ce3          	bne	a5,s2,80003e00 <namex+0x106>
    80003e0c:	bfad                	j	80003d86 <namex+0x8c>
    memmove(name, s, len);
    80003e0e:	2601                	sext.w	a2,a2
    80003e10:	85a6                	mv	a1,s1
    80003e12:	8556                	mv	a0,s5
    80003e14:	fbdfc0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    80003e18:	9d56                	add	s10,s10,s5
    80003e1a:	000d0023          	sb	zero,0(s10)
    80003e1e:	84ce                	mv	s1,s3
    80003e20:	bfbd                	j	80003d9e <namex+0xa4>
  if(nameiparent){
    80003e22:	f20b0ae3          	beqz	s6,80003d56 <namex+0x5c>
    iput(ip);
    80003e26:	8552                	mv	a0,s4
    80003e28:	a2dff0ef          	jal	ra,80003854 <iput>
    return 0;
    80003e2c:	4a01                	li	s4,0
    80003e2e:	b725                	j	80003d56 <namex+0x5c>

0000000080003e30 <dirlink>:
{
    80003e30:	7139                	addi	sp,sp,-64
    80003e32:	fc06                	sd	ra,56(sp)
    80003e34:	f822                	sd	s0,48(sp)
    80003e36:	f426                	sd	s1,40(sp)
    80003e38:	f04a                	sd	s2,32(sp)
    80003e3a:	ec4e                	sd	s3,24(sp)
    80003e3c:	e852                	sd	s4,16(sp)
    80003e3e:	0080                	addi	s0,sp,64
    80003e40:	892a                	mv	s2,a0
    80003e42:	8a2e                	mv	s4,a1
    80003e44:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e46:	4601                	li	a2,0
    80003e48:	e17ff0ef          	jal	ra,80003c5e <dirlookup>
    80003e4c:	e52d                	bnez	a0,80003eb6 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e4e:	04c92483          	lw	s1,76(s2)
    80003e52:	c48d                	beqz	s1,80003e7c <dirlink+0x4c>
    80003e54:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e56:	4741                	li	a4,16
    80003e58:	86a6                	mv	a3,s1
    80003e5a:	fc040613          	addi	a2,s0,-64
    80003e5e:	4581                	li	a1,0
    80003e60:	854a                	mv	a0,s2
    80003e62:	c01ff0ef          	jal	ra,80003a62 <readi>
    80003e66:	47c1                	li	a5,16
    80003e68:	04f51b63          	bne	a0,a5,80003ebe <dirlink+0x8e>
    if(de.inum == 0)
    80003e6c:	fc045783          	lhu	a5,-64(s0)
    80003e70:	c791                	beqz	a5,80003e7c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e72:	24c1                	addiw	s1,s1,16
    80003e74:	04c92783          	lw	a5,76(s2)
    80003e78:	fcf4efe3          	bltu	s1,a5,80003e56 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003e7c:	4639                	li	a2,14
    80003e7e:	85d2                	mv	a1,s4
    80003e80:	fc240513          	addi	a0,s0,-62
    80003e84:	ff9fc0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80003e88:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e8c:	4741                	li	a4,16
    80003e8e:	86a6                	mv	a3,s1
    80003e90:	fc040613          	addi	a2,s0,-64
    80003e94:	4581                	li	a1,0
    80003e96:	854a                	mv	a0,s2
    80003e98:	cafff0ef          	jal	ra,80003b46 <writei>
    80003e9c:	1541                	addi	a0,a0,-16
    80003e9e:	00a03533          	snez	a0,a0
    80003ea2:	40a00533          	neg	a0,a0
}
    80003ea6:	70e2                	ld	ra,56(sp)
    80003ea8:	7442                	ld	s0,48(sp)
    80003eaa:	74a2                	ld	s1,40(sp)
    80003eac:	7902                	ld	s2,32(sp)
    80003eae:	69e2                	ld	s3,24(sp)
    80003eb0:	6a42                	ld	s4,16(sp)
    80003eb2:	6121                	addi	sp,sp,64
    80003eb4:	8082                	ret
    iput(ip);
    80003eb6:	99fff0ef          	jal	ra,80003854 <iput>
    return -1;
    80003eba:	557d                	li	a0,-1
    80003ebc:	b7ed                	j	80003ea6 <dirlink+0x76>
      panic("dirlink read");
    80003ebe:	00003517          	auipc	a0,0x3
    80003ec2:	73250513          	addi	a0,a0,1842 # 800075f0 <syscalls+0x1f8>
    80003ec6:	8c3fc0ef          	jal	ra,80000788 <panic>

0000000080003eca <namei>:

struct inode*
namei(char *path)
{
    80003eca:	1101                	addi	sp,sp,-32
    80003ecc:	ec06                	sd	ra,24(sp)
    80003ece:	e822                	sd	s0,16(sp)
    80003ed0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ed2:	fe040613          	addi	a2,s0,-32
    80003ed6:	4581                	li	a1,0
    80003ed8:	e23ff0ef          	jal	ra,80003cfa <namex>
}
    80003edc:	60e2                	ld	ra,24(sp)
    80003ede:	6442                	ld	s0,16(sp)
    80003ee0:	6105                	addi	sp,sp,32
    80003ee2:	8082                	ret

0000000080003ee4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ee4:	1141                	addi	sp,sp,-16
    80003ee6:	e406                	sd	ra,8(sp)
    80003ee8:	e022                	sd	s0,0(sp)
    80003eea:	0800                	addi	s0,sp,16
    80003eec:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003eee:	4585                	li	a1,1
    80003ef0:	e0bff0ef          	jal	ra,80003cfa <namex>
}
    80003ef4:	60a2                	ld	ra,8(sp)
    80003ef6:	6402                	ld	s0,0(sp)
    80003ef8:	0141                	addi	sp,sp,16
    80003efa:	8082                	ret

0000000080003efc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	e426                	sd	s1,8(sp)
    80003f04:	e04a                	sd	s2,0(sp)
    80003f06:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f08:	00244917          	auipc	s2,0x244
    80003f0c:	a7890913          	addi	s2,s2,-1416 # 80247980 <log>
    80003f10:	01892583          	lw	a1,24(s2)
    80003f14:	02492503          	lw	a0,36(s2)
    80003f18:	90eff0ef          	jal	ra,80003026 <bread>
    80003f1c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f1e:	02892683          	lw	a3,40(s2)
    80003f22:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f24:	02d05863          	blez	a3,80003f54 <write_head+0x58>
    80003f28:	00244797          	auipc	a5,0x244
    80003f2c:	a8478793          	addi	a5,a5,-1404 # 802479ac <log+0x2c>
    80003f30:	05c50713          	addi	a4,a0,92
    80003f34:	36fd                	addiw	a3,a3,-1
    80003f36:	02069613          	slli	a2,a3,0x20
    80003f3a:	01e65693          	srli	a3,a2,0x1e
    80003f3e:	00244617          	auipc	a2,0x244
    80003f42:	a7260613          	addi	a2,a2,-1422 # 802479b0 <log+0x30>
    80003f46:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f48:	4390                	lw	a2,0(a5)
    80003f4a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f4c:	0791                	addi	a5,a5,4
    80003f4e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003f50:	fed79ce3          	bne	a5,a3,80003f48 <write_head+0x4c>
  }
  bwrite(buf);
    80003f54:	8526                	mv	a0,s1
    80003f56:	9a6ff0ef          	jal	ra,800030fc <bwrite>
  brelse(buf);
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	9d2ff0ef          	jal	ra,8000312e <brelse>
}
    80003f60:	60e2                	ld	ra,24(sp)
    80003f62:	6442                	ld	s0,16(sp)
    80003f64:	64a2                	ld	s1,8(sp)
    80003f66:	6902                	ld	s2,0(sp)
    80003f68:	6105                	addi	sp,sp,32
    80003f6a:	8082                	ret

0000000080003f6c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f6c:	00244797          	auipc	a5,0x244
    80003f70:	a3c7a783          	lw	a5,-1476(a5) # 802479a8 <log+0x28>
    80003f74:	0af05e63          	blez	a5,80004030 <install_trans+0xc4>
{
    80003f78:	715d                	addi	sp,sp,-80
    80003f7a:	e486                	sd	ra,72(sp)
    80003f7c:	e0a2                	sd	s0,64(sp)
    80003f7e:	fc26                	sd	s1,56(sp)
    80003f80:	f84a                	sd	s2,48(sp)
    80003f82:	f44e                	sd	s3,40(sp)
    80003f84:	f052                	sd	s4,32(sp)
    80003f86:	ec56                	sd	s5,24(sp)
    80003f88:	e85a                	sd	s6,16(sp)
    80003f8a:	e45e                	sd	s7,8(sp)
    80003f8c:	0880                	addi	s0,sp,80
    80003f8e:	8b2a                	mv	s6,a0
    80003f90:	00244a97          	auipc	s5,0x244
    80003f94:	a1ca8a93          	addi	s5,s5,-1508 # 802479ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f98:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f9a:	00003b97          	auipc	s7,0x3
    80003f9e:	666b8b93          	addi	s7,s7,1638 # 80007600 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fa2:	00244a17          	auipc	s4,0x244
    80003fa6:	9dea0a13          	addi	s4,s4,-1570 # 80247980 <log>
    80003faa:	a025                	j	80003fd2 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003fac:	000aa603          	lw	a2,0(s5)
    80003fb0:	85ce                	mv	a1,s3
    80003fb2:	855e                	mv	a0,s7
    80003fb4:	d0efc0ef          	jal	ra,800004c2 <printf>
    80003fb8:	a839                	j	80003fd6 <install_trans+0x6a>
    brelse(lbuf);
    80003fba:	854a                	mv	a0,s2
    80003fbc:	972ff0ef          	jal	ra,8000312e <brelse>
    brelse(dbuf);
    80003fc0:	8526                	mv	a0,s1
    80003fc2:	96cff0ef          	jal	ra,8000312e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc6:	2985                	addiw	s3,s3,1
    80003fc8:	0a91                	addi	s5,s5,4
    80003fca:	028a2783          	lw	a5,40(s4)
    80003fce:	04f9d663          	bge	s3,a5,8000401a <install_trans+0xae>
    if(recovering) {
    80003fd2:	fc0b1de3          	bnez	s6,80003fac <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fd6:	018a2583          	lw	a1,24(s4)
    80003fda:	013585bb          	addw	a1,a1,s3
    80003fde:	2585                	addiw	a1,a1,1
    80003fe0:	024a2503          	lw	a0,36(s4)
    80003fe4:	842ff0ef          	jal	ra,80003026 <bread>
    80003fe8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fea:	000aa583          	lw	a1,0(s5)
    80003fee:	024a2503          	lw	a0,36(s4)
    80003ff2:	834ff0ef          	jal	ra,80003026 <bread>
    80003ff6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ff8:	40000613          	li	a2,1024
    80003ffc:	05890593          	addi	a1,s2,88
    80004000:	05850513          	addi	a0,a0,88
    80004004:	dcdfc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004008:	8526                	mv	a0,s1
    8000400a:	8f2ff0ef          	jal	ra,800030fc <bwrite>
    if(recovering == 0)
    8000400e:	fa0b16e3          	bnez	s6,80003fba <install_trans+0x4e>
      bunpin(dbuf);
    80004012:	8526                	mv	a0,s1
    80004014:	9d8ff0ef          	jal	ra,800031ec <bunpin>
    80004018:	b74d                	j	80003fba <install_trans+0x4e>
}
    8000401a:	60a6                	ld	ra,72(sp)
    8000401c:	6406                	ld	s0,64(sp)
    8000401e:	74e2                	ld	s1,56(sp)
    80004020:	7942                	ld	s2,48(sp)
    80004022:	79a2                	ld	s3,40(sp)
    80004024:	7a02                	ld	s4,32(sp)
    80004026:	6ae2                	ld	s5,24(sp)
    80004028:	6b42                	ld	s6,16(sp)
    8000402a:	6ba2                	ld	s7,8(sp)
    8000402c:	6161                	addi	sp,sp,80
    8000402e:	8082                	ret
    80004030:	8082                	ret

0000000080004032 <initlog>:
{
    80004032:	7179                	addi	sp,sp,-48
    80004034:	f406                	sd	ra,40(sp)
    80004036:	f022                	sd	s0,32(sp)
    80004038:	ec26                	sd	s1,24(sp)
    8000403a:	e84a                	sd	s2,16(sp)
    8000403c:	e44e                	sd	s3,8(sp)
    8000403e:	1800                	addi	s0,sp,48
    80004040:	892a                	mv	s2,a0
    80004042:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004044:	00244497          	auipc	s1,0x244
    80004048:	93c48493          	addi	s1,s1,-1732 # 80247980 <log>
    8000404c:	00003597          	auipc	a1,0x3
    80004050:	5d458593          	addi	a1,a1,1492 # 80007620 <syscalls+0x228>
    80004054:	8526                	mv	a0,s1
    80004056:	bcbfc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    8000405a:	0149a583          	lw	a1,20(s3)
    8000405e:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004060:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004064:	854a                	mv	a0,s2
    80004066:	fc1fe0ef          	jal	ra,80003026 <bread>
  log.lh.n = lh->n;
    8000406a:	4d34                	lw	a3,88(a0)
    8000406c:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000406e:	02d05663          	blez	a3,8000409a <initlog+0x68>
    80004072:	05c50793          	addi	a5,a0,92
    80004076:	00244717          	auipc	a4,0x244
    8000407a:	93670713          	addi	a4,a4,-1738 # 802479ac <log+0x2c>
    8000407e:	36fd                	addiw	a3,a3,-1
    80004080:	02069613          	slli	a2,a3,0x20
    80004084:	01e65693          	srli	a3,a2,0x1e
    80004088:	06050613          	addi	a2,a0,96
    8000408c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000408e:	4390                	lw	a2,0(a5)
    80004090:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004092:	0791                	addi	a5,a5,4
    80004094:	0711                	addi	a4,a4,4
    80004096:	fed79ce3          	bne	a5,a3,8000408e <initlog+0x5c>
  brelse(buf);
    8000409a:	894ff0ef          	jal	ra,8000312e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000409e:	4505                	li	a0,1
    800040a0:	ecdff0ef          	jal	ra,80003f6c <install_trans>
  log.lh.n = 0;
    800040a4:	00244797          	auipc	a5,0x244
    800040a8:	9007a223          	sw	zero,-1788(a5) # 802479a8 <log+0x28>
  write_head(); // clear the log
    800040ac:	e51ff0ef          	jal	ra,80003efc <write_head>
}
    800040b0:	70a2                	ld	ra,40(sp)
    800040b2:	7402                	ld	s0,32(sp)
    800040b4:	64e2                	ld	s1,24(sp)
    800040b6:	6942                	ld	s2,16(sp)
    800040b8:	69a2                	ld	s3,8(sp)
    800040ba:	6145                	addi	sp,sp,48
    800040bc:	8082                	ret

00000000800040be <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040be:	1101                	addi	sp,sp,-32
    800040c0:	ec06                	sd	ra,24(sp)
    800040c2:	e822                	sd	s0,16(sp)
    800040c4:	e426                	sd	s1,8(sp)
    800040c6:	e04a                	sd	s2,0(sp)
    800040c8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040ca:	00244517          	auipc	a0,0x244
    800040ce:	8b650513          	addi	a0,a0,-1866 # 80247980 <log>
    800040d2:	bcffc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    800040d6:	00244497          	auipc	s1,0x244
    800040da:	8aa48493          	addi	s1,s1,-1878 # 80247980 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800040de:	4979                	li	s2,30
    800040e0:	a029                	j	800040ea <begin_op+0x2c>
      sleep(&log, &log.lock);
    800040e2:	85a6                	mv	a1,s1
    800040e4:	8526                	mv	a0,s1
    800040e6:	88afe0ef          	jal	ra,80002170 <sleep>
    if(log.committing){
    800040ea:	509c                	lw	a5,32(s1)
    800040ec:	fbfd                	bnez	a5,800040e2 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800040ee:	4cd8                	lw	a4,28(s1)
    800040f0:	2705                	addiw	a4,a4,1
    800040f2:	0007069b          	sext.w	a3,a4
    800040f6:	0027179b          	slliw	a5,a4,0x2
    800040fa:	9fb9                	addw	a5,a5,a4
    800040fc:	0017979b          	slliw	a5,a5,0x1
    80004100:	5498                	lw	a4,40(s1)
    80004102:	9fb9                	addw	a5,a5,a4
    80004104:	00f95763          	bge	s2,a5,80004112 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004108:	85a6                	mv	a1,s1
    8000410a:	8526                	mv	a0,s1
    8000410c:	864fe0ef          	jal	ra,80002170 <sleep>
    80004110:	bfe9                	j	800040ea <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004112:	00244517          	auipc	a0,0x244
    80004116:	86e50513          	addi	a0,a0,-1938 # 80247980 <log>
    8000411a:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    8000411c:	c1dfc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	64a2                	ld	s1,8(sp)
    80004126:	6902                	ld	s2,0(sp)
    80004128:	6105                	addi	sp,sp,32
    8000412a:	8082                	ret

000000008000412c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000412c:	7139                	addi	sp,sp,-64
    8000412e:	fc06                	sd	ra,56(sp)
    80004130:	f822                	sd	s0,48(sp)
    80004132:	f426                	sd	s1,40(sp)
    80004134:	f04a                	sd	s2,32(sp)
    80004136:	ec4e                	sd	s3,24(sp)
    80004138:	e852                	sd	s4,16(sp)
    8000413a:	e456                	sd	s5,8(sp)
    8000413c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000413e:	00244497          	auipc	s1,0x244
    80004142:	84248493          	addi	s1,s1,-1982 # 80247980 <log>
    80004146:	8526                	mv	a0,s1
    80004148:	b59fc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    8000414c:	4cdc                	lw	a5,28(s1)
    8000414e:	37fd                	addiw	a5,a5,-1
    80004150:	0007891b          	sext.w	s2,a5
    80004154:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004156:	509c                	lw	a5,32(s1)
    80004158:	ef9d                	bnez	a5,80004196 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    8000415a:	04091463          	bnez	s2,800041a2 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000415e:	00244497          	auipc	s1,0x244
    80004162:	82248493          	addi	s1,s1,-2014 # 80247980 <log>
    80004166:	4785                	li	a5,1
    80004168:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000416a:	8526                	mv	a0,s1
    8000416c:	bcdfc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004170:	549c                	lw	a5,40(s1)
    80004172:	04f04b63          	bgtz	a5,800041c8 <end_op+0x9c>
    acquire(&log.lock);
    80004176:	00244497          	auipc	s1,0x244
    8000417a:	80a48493          	addi	s1,s1,-2038 # 80247980 <log>
    8000417e:	8526                	mv	a0,s1
    80004180:	b21fc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    80004184:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004188:	8526                	mv	a0,s1
    8000418a:	832fe0ef          	jal	ra,800021bc <wakeup>
    release(&log.lock);
    8000418e:	8526                	mv	a0,s1
    80004190:	ba9fc0ef          	jal	ra,80000d38 <release>
}
    80004194:	a00d                	j	800041b6 <end_op+0x8a>
    panic("log.committing");
    80004196:	00003517          	auipc	a0,0x3
    8000419a:	49250513          	addi	a0,a0,1170 # 80007628 <syscalls+0x230>
    8000419e:	deafc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    800041a2:	00243497          	auipc	s1,0x243
    800041a6:	7de48493          	addi	s1,s1,2014 # 80247980 <log>
    800041aa:	8526                	mv	a0,s1
    800041ac:	810fe0ef          	jal	ra,800021bc <wakeup>
  release(&log.lock);
    800041b0:	8526                	mv	a0,s1
    800041b2:	b87fc0ef          	jal	ra,80000d38 <release>
}
    800041b6:	70e2                	ld	ra,56(sp)
    800041b8:	7442                	ld	s0,48(sp)
    800041ba:	74a2                	ld	s1,40(sp)
    800041bc:	7902                	ld	s2,32(sp)
    800041be:	69e2                	ld	s3,24(sp)
    800041c0:	6a42                	ld	s4,16(sp)
    800041c2:	6aa2                	ld	s5,8(sp)
    800041c4:	6121                	addi	sp,sp,64
    800041c6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c8:	00243a97          	auipc	s5,0x243
    800041cc:	7e4a8a93          	addi	s5,s5,2020 # 802479ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041d0:	00243a17          	auipc	s4,0x243
    800041d4:	7b0a0a13          	addi	s4,s4,1968 # 80247980 <log>
    800041d8:	018a2583          	lw	a1,24(s4)
    800041dc:	012585bb          	addw	a1,a1,s2
    800041e0:	2585                	addiw	a1,a1,1
    800041e2:	024a2503          	lw	a0,36(s4)
    800041e6:	e41fe0ef          	jal	ra,80003026 <bread>
    800041ea:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041ec:	000aa583          	lw	a1,0(s5)
    800041f0:	024a2503          	lw	a0,36(s4)
    800041f4:	e33fe0ef          	jal	ra,80003026 <bread>
    800041f8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041fa:	40000613          	li	a2,1024
    800041fe:	05850593          	addi	a1,a0,88
    80004202:	05848513          	addi	a0,s1,88
    80004206:	bcbfc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    8000420a:	8526                	mv	a0,s1
    8000420c:	ef1fe0ef          	jal	ra,800030fc <bwrite>
    brelse(from);
    80004210:	854e                	mv	a0,s3
    80004212:	f1dfe0ef          	jal	ra,8000312e <brelse>
    brelse(to);
    80004216:	8526                	mv	a0,s1
    80004218:	f17fe0ef          	jal	ra,8000312e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421c:	2905                	addiw	s2,s2,1
    8000421e:	0a91                	addi	s5,s5,4
    80004220:	028a2783          	lw	a5,40(s4)
    80004224:	faf94ae3          	blt	s2,a5,800041d8 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004228:	cd5ff0ef          	jal	ra,80003efc <write_head>
    install_trans(0); // Now install writes to home locations
    8000422c:	4501                	li	a0,0
    8000422e:	d3fff0ef          	jal	ra,80003f6c <install_trans>
    log.lh.n = 0;
    80004232:	00243797          	auipc	a5,0x243
    80004236:	7607ab23          	sw	zero,1910(a5) # 802479a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000423a:	cc3ff0ef          	jal	ra,80003efc <write_head>
    8000423e:	bf25                	j	80004176 <end_op+0x4a>

0000000080004240 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004240:	1101                	addi	sp,sp,-32
    80004242:	ec06                	sd	ra,24(sp)
    80004244:	e822                	sd	s0,16(sp)
    80004246:	e426                	sd	s1,8(sp)
    80004248:	e04a                	sd	s2,0(sp)
    8000424a:	1000                	addi	s0,sp,32
    8000424c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000424e:	00243917          	auipc	s2,0x243
    80004252:	73290913          	addi	s2,s2,1842 # 80247980 <log>
    80004256:	854a                	mv	a0,s2
    80004258:	a49fc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000425c:	02892603          	lw	a2,40(s2)
    80004260:	47f5                	li	a5,29
    80004262:	04c7cc63          	blt	a5,a2,800042ba <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004266:	00243797          	auipc	a5,0x243
    8000426a:	7367a783          	lw	a5,1846(a5) # 8024799c <log+0x1c>
    8000426e:	04f05c63          	blez	a5,800042c6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004272:	4781                	li	a5,0
    80004274:	04c05f63          	blez	a2,800042d2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004278:	44cc                	lw	a1,12(s1)
    8000427a:	00243717          	auipc	a4,0x243
    8000427e:	73270713          	addi	a4,a4,1842 # 802479ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004282:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004284:	4314                	lw	a3,0(a4)
    80004286:	04b68663          	beq	a3,a1,800042d2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000428a:	2785                	addiw	a5,a5,1
    8000428c:	0711                	addi	a4,a4,4
    8000428e:	fef61be3          	bne	a2,a5,80004284 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004292:	0621                	addi	a2,a2,8
    80004294:	060a                	slli	a2,a2,0x2
    80004296:	00243797          	auipc	a5,0x243
    8000429a:	6ea78793          	addi	a5,a5,1770 # 80247980 <log>
    8000429e:	97b2                	add	a5,a5,a2
    800042a0:	44d8                	lw	a4,12(s1)
    800042a2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042a4:	8526                	mv	a0,s1
    800042a6:	f13fe0ef          	jal	ra,800031b8 <bpin>
    log.lh.n++;
    800042aa:	00243717          	auipc	a4,0x243
    800042ae:	6d670713          	addi	a4,a4,1750 # 80247980 <log>
    800042b2:	571c                	lw	a5,40(a4)
    800042b4:	2785                	addiw	a5,a5,1
    800042b6:	d71c                	sw	a5,40(a4)
    800042b8:	a80d                	j	800042ea <log_write+0xaa>
    panic("too big a transaction");
    800042ba:	00003517          	auipc	a0,0x3
    800042be:	37e50513          	addi	a0,a0,894 # 80007638 <syscalls+0x240>
    800042c2:	cc6fc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    800042c6:	00003517          	auipc	a0,0x3
    800042ca:	38a50513          	addi	a0,a0,906 # 80007650 <syscalls+0x258>
    800042ce:	cbafc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    800042d2:	00878693          	addi	a3,a5,8
    800042d6:	068a                	slli	a3,a3,0x2
    800042d8:	00243717          	auipc	a4,0x243
    800042dc:	6a870713          	addi	a4,a4,1704 # 80247980 <log>
    800042e0:	9736                	add	a4,a4,a3
    800042e2:	44d4                	lw	a3,12(s1)
    800042e4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042e6:	faf60fe3          	beq	a2,a5,800042a4 <log_write+0x64>
  }
  release(&log.lock);
    800042ea:	00243517          	auipc	a0,0x243
    800042ee:	69650513          	addi	a0,a0,1686 # 80247980 <log>
    800042f2:	a47fc0ef          	jal	ra,80000d38 <release>
}
    800042f6:	60e2                	ld	ra,24(sp)
    800042f8:	6442                	ld	s0,16(sp)
    800042fa:	64a2                	ld	s1,8(sp)
    800042fc:	6902                	ld	s2,0(sp)
    800042fe:	6105                	addi	sp,sp,32
    80004300:	8082                	ret

0000000080004302 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004302:	1101                	addi	sp,sp,-32
    80004304:	ec06                	sd	ra,24(sp)
    80004306:	e822                	sd	s0,16(sp)
    80004308:	e426                	sd	s1,8(sp)
    8000430a:	e04a                	sd	s2,0(sp)
    8000430c:	1000                	addi	s0,sp,32
    8000430e:	84aa                	mv	s1,a0
    80004310:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004312:	00003597          	auipc	a1,0x3
    80004316:	35e58593          	addi	a1,a1,862 # 80007670 <syscalls+0x278>
    8000431a:	0521                	addi	a0,a0,8
    8000431c:	905fc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    80004320:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004324:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004328:	0204a423          	sw	zero,40(s1)
}
    8000432c:	60e2                	ld	ra,24(sp)
    8000432e:	6442                	ld	s0,16(sp)
    80004330:	64a2                	ld	s1,8(sp)
    80004332:	6902                	ld	s2,0(sp)
    80004334:	6105                	addi	sp,sp,32
    80004336:	8082                	ret

0000000080004338 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004338:	1101                	addi	sp,sp,-32
    8000433a:	ec06                	sd	ra,24(sp)
    8000433c:	e822                	sd	s0,16(sp)
    8000433e:	e426                	sd	s1,8(sp)
    80004340:	e04a                	sd	s2,0(sp)
    80004342:	1000                	addi	s0,sp,32
    80004344:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004346:	00850913          	addi	s2,a0,8
    8000434a:	854a                	mv	a0,s2
    8000434c:	955fc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    80004350:	409c                	lw	a5,0(s1)
    80004352:	c799                	beqz	a5,80004360 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004354:	85ca                	mv	a1,s2
    80004356:	8526                	mv	a0,s1
    80004358:	e19fd0ef          	jal	ra,80002170 <sleep>
  while (lk->locked) {
    8000435c:	409c                	lw	a5,0(s1)
    8000435e:	fbfd                	bnez	a5,80004354 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004360:	4785                	li	a5,1
    80004362:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004364:	f9efd0ef          	jal	ra,80001b02 <myproc>
    80004368:	591c                	lw	a5,48(a0)
    8000436a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000436c:	854a                	mv	a0,s2
    8000436e:	9cbfc0ef          	jal	ra,80000d38 <release>
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	64a2                	ld	s1,8(sp)
    80004378:	6902                	ld	s2,0(sp)
    8000437a:	6105                	addi	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	e04a                	sd	s2,0(sp)
    80004388:	1000                	addi	s0,sp,32
    8000438a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000438c:	00850913          	addi	s2,a0,8
    80004390:	854a                	mv	a0,s2
    80004392:	90ffc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    80004396:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000439a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000439e:	8526                	mv	a0,s1
    800043a0:	e1dfd0ef          	jal	ra,800021bc <wakeup>
  release(&lk->lk);
    800043a4:	854a                	mv	a0,s2
    800043a6:	993fc0ef          	jal	ra,80000d38 <release>
}
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6902                	ld	s2,0(sp)
    800043b2:	6105                	addi	sp,sp,32
    800043b4:	8082                	ret

00000000800043b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043b6:	7179                	addi	sp,sp,-48
    800043b8:	f406                	sd	ra,40(sp)
    800043ba:	f022                	sd	s0,32(sp)
    800043bc:	ec26                	sd	s1,24(sp)
    800043be:	e84a                	sd	s2,16(sp)
    800043c0:	e44e                	sd	s3,8(sp)
    800043c2:	1800                	addi	s0,sp,48
    800043c4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043c6:	00850913          	addi	s2,a0,8
    800043ca:	854a                	mv	a0,s2
    800043cc:	8d5fc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043d0:	409c                	lw	a5,0(s1)
    800043d2:	ef89                	bnez	a5,800043ec <holdingsleep+0x36>
    800043d4:	4481                	li	s1,0
  release(&lk->lk);
    800043d6:	854a                	mv	a0,s2
    800043d8:	961fc0ef          	jal	ra,80000d38 <release>
  return r;
}
    800043dc:	8526                	mv	a0,s1
    800043de:	70a2                	ld	ra,40(sp)
    800043e0:	7402                	ld	s0,32(sp)
    800043e2:	64e2                	ld	s1,24(sp)
    800043e4:	6942                	ld	s2,16(sp)
    800043e6:	69a2                	ld	s3,8(sp)
    800043e8:	6145                	addi	sp,sp,48
    800043ea:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ec:	0284a983          	lw	s3,40(s1)
    800043f0:	f12fd0ef          	jal	ra,80001b02 <myproc>
    800043f4:	5904                	lw	s1,48(a0)
    800043f6:	413484b3          	sub	s1,s1,s3
    800043fa:	0014b493          	seqz	s1,s1
    800043fe:	bfe1                	j	800043d6 <holdingsleep+0x20>

0000000080004400 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004400:	1141                	addi	sp,sp,-16
    80004402:	e406                	sd	ra,8(sp)
    80004404:	e022                	sd	s0,0(sp)
    80004406:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004408:	00003597          	auipc	a1,0x3
    8000440c:	27858593          	addi	a1,a1,632 # 80007680 <syscalls+0x288>
    80004410:	00243517          	auipc	a0,0x243
    80004414:	6b850513          	addi	a0,a0,1720 # 80247ac8 <ftable>
    80004418:	809fc0ef          	jal	ra,80000c20 <initlock>
}
    8000441c:	60a2                	ld	ra,8(sp)
    8000441e:	6402                	ld	s0,0(sp)
    80004420:	0141                	addi	sp,sp,16
    80004422:	8082                	ret

0000000080004424 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004424:	1101                	addi	sp,sp,-32
    80004426:	ec06                	sd	ra,24(sp)
    80004428:	e822                	sd	s0,16(sp)
    8000442a:	e426                	sd	s1,8(sp)
    8000442c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000442e:	00243517          	auipc	a0,0x243
    80004432:	69a50513          	addi	a0,a0,1690 # 80247ac8 <ftable>
    80004436:	86bfc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000443a:	00243497          	auipc	s1,0x243
    8000443e:	6a648493          	addi	s1,s1,1702 # 80247ae0 <ftable+0x18>
    80004442:	00244717          	auipc	a4,0x244
    80004446:	63e70713          	addi	a4,a4,1598 # 80248a80 <disk>
    if(f->ref == 0){
    8000444a:	40dc                	lw	a5,4(s1)
    8000444c:	cf89                	beqz	a5,80004466 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000444e:	02848493          	addi	s1,s1,40
    80004452:	fee49ce3          	bne	s1,a4,8000444a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004456:	00243517          	auipc	a0,0x243
    8000445a:	67250513          	addi	a0,a0,1650 # 80247ac8 <ftable>
    8000445e:	8dbfc0ef          	jal	ra,80000d38 <release>
  return 0;
    80004462:	4481                	li	s1,0
    80004464:	a809                	j	80004476 <filealloc+0x52>
      f->ref = 1;
    80004466:	4785                	li	a5,1
    80004468:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000446a:	00243517          	auipc	a0,0x243
    8000446e:	65e50513          	addi	a0,a0,1630 # 80247ac8 <ftable>
    80004472:	8c7fc0ef          	jal	ra,80000d38 <release>
}
    80004476:	8526                	mv	a0,s1
    80004478:	60e2                	ld	ra,24(sp)
    8000447a:	6442                	ld	s0,16(sp)
    8000447c:	64a2                	ld	s1,8(sp)
    8000447e:	6105                	addi	sp,sp,32
    80004480:	8082                	ret

0000000080004482 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004482:	1101                	addi	sp,sp,-32
    80004484:	ec06                	sd	ra,24(sp)
    80004486:	e822                	sd	s0,16(sp)
    80004488:	e426                	sd	s1,8(sp)
    8000448a:	1000                	addi	s0,sp,32
    8000448c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000448e:	00243517          	auipc	a0,0x243
    80004492:	63a50513          	addi	a0,a0,1594 # 80247ac8 <ftable>
    80004496:	80bfc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    8000449a:	40dc                	lw	a5,4(s1)
    8000449c:	02f05063          	blez	a5,800044bc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800044a0:	2785                	addiw	a5,a5,1
    800044a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044a4:	00243517          	auipc	a0,0x243
    800044a8:	62450513          	addi	a0,a0,1572 # 80247ac8 <ftable>
    800044ac:	88dfc0ef          	jal	ra,80000d38 <release>
  return f;
}
    800044b0:	8526                	mv	a0,s1
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	64a2                	ld	s1,8(sp)
    800044b8:	6105                	addi	sp,sp,32
    800044ba:	8082                	ret
    panic("filedup");
    800044bc:	00003517          	auipc	a0,0x3
    800044c0:	1cc50513          	addi	a0,a0,460 # 80007688 <syscalls+0x290>
    800044c4:	ac4fc0ef          	jal	ra,80000788 <panic>

00000000800044c8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044c8:	7139                	addi	sp,sp,-64
    800044ca:	fc06                	sd	ra,56(sp)
    800044cc:	f822                	sd	s0,48(sp)
    800044ce:	f426                	sd	s1,40(sp)
    800044d0:	f04a                	sd	s2,32(sp)
    800044d2:	ec4e                	sd	s3,24(sp)
    800044d4:	e852                	sd	s4,16(sp)
    800044d6:	e456                	sd	s5,8(sp)
    800044d8:	0080                	addi	s0,sp,64
    800044da:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044dc:	00243517          	auipc	a0,0x243
    800044e0:	5ec50513          	addi	a0,a0,1516 # 80247ac8 <ftable>
    800044e4:	fbcfc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    800044e8:	40dc                	lw	a5,4(s1)
    800044ea:	04f05963          	blez	a5,8000453c <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800044ee:	37fd                	addiw	a5,a5,-1
    800044f0:	0007871b          	sext.w	a4,a5
    800044f4:	c0dc                	sw	a5,4(s1)
    800044f6:	04e04963          	bgtz	a4,80004548 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044fa:	0004a903          	lw	s2,0(s1)
    800044fe:	0094ca83          	lbu	s5,9(s1)
    80004502:	0104ba03          	ld	s4,16(s1)
    80004506:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000450a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000450e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004512:	00243517          	auipc	a0,0x243
    80004516:	5b650513          	addi	a0,a0,1462 # 80247ac8 <ftable>
    8000451a:	81ffc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    8000451e:	4785                	li	a5,1
    80004520:	04f90363          	beq	s2,a5,80004566 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004524:	3979                	addiw	s2,s2,-2
    80004526:	4785                	li	a5,1
    80004528:	0327e663          	bltu	a5,s2,80004554 <fileclose+0x8c>
    begin_op();
    8000452c:	b93ff0ef          	jal	ra,800040be <begin_op>
    iput(ff.ip);
    80004530:	854e                	mv	a0,s3
    80004532:	b22ff0ef          	jal	ra,80003854 <iput>
    end_op();
    80004536:	bf7ff0ef          	jal	ra,8000412c <end_op>
    8000453a:	a829                	j	80004554 <fileclose+0x8c>
    panic("fileclose");
    8000453c:	00003517          	auipc	a0,0x3
    80004540:	15450513          	addi	a0,a0,340 # 80007690 <syscalls+0x298>
    80004544:	a44fc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80004548:	00243517          	auipc	a0,0x243
    8000454c:	58050513          	addi	a0,a0,1408 # 80247ac8 <ftable>
    80004550:	fe8fc0ef          	jal	ra,80000d38 <release>
  }
}
    80004554:	70e2                	ld	ra,56(sp)
    80004556:	7442                	ld	s0,48(sp)
    80004558:	74a2                	ld	s1,40(sp)
    8000455a:	7902                	ld	s2,32(sp)
    8000455c:	69e2                	ld	s3,24(sp)
    8000455e:	6a42                	ld	s4,16(sp)
    80004560:	6aa2                	ld	s5,8(sp)
    80004562:	6121                	addi	sp,sp,64
    80004564:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004566:	85d6                	mv	a1,s5
    80004568:	8552                	mv	a0,s4
    8000456a:	2ec000ef          	jal	ra,80004856 <pipeclose>
    8000456e:	b7dd                	j	80004554 <fileclose+0x8c>

0000000080004570 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004570:	715d                	addi	sp,sp,-80
    80004572:	e486                	sd	ra,72(sp)
    80004574:	e0a2                	sd	s0,64(sp)
    80004576:	fc26                	sd	s1,56(sp)
    80004578:	f84a                	sd	s2,48(sp)
    8000457a:	f44e                	sd	s3,40(sp)
    8000457c:	0880                	addi	s0,sp,80
    8000457e:	84aa                	mv	s1,a0
    80004580:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004582:	d80fd0ef          	jal	ra,80001b02 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004586:	409c                	lw	a5,0(s1)
    80004588:	37f9                	addiw	a5,a5,-2
    8000458a:	4705                	li	a4,1
    8000458c:	02f76f63          	bltu	a4,a5,800045ca <filestat+0x5a>
    80004590:	892a                	mv	s2,a0
    ilock(f->ip);
    80004592:	6c88                	ld	a0,24(s1)
    80004594:	942ff0ef          	jal	ra,800036d6 <ilock>
    stati(f->ip, &st);
    80004598:	fb840593          	addi	a1,s0,-72
    8000459c:	6c88                	ld	a0,24(s1)
    8000459e:	c9aff0ef          	jal	ra,80003a38 <stati>
    iunlock(f->ip);
    800045a2:	6c88                	ld	a0,24(s1)
    800045a4:	9dcff0ef          	jal	ra,80003780 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045a8:	46e1                	li	a3,24
    800045aa:	fb840613          	addi	a2,s0,-72
    800045ae:	85ce                	mv	a1,s3
    800045b0:	05093503          	ld	a0,80(s2)
    800045b4:	9aafd0ef          	jal	ra,8000175e <copyout>
    800045b8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045bc:	60a6                	ld	ra,72(sp)
    800045be:	6406                	ld	s0,64(sp)
    800045c0:	74e2                	ld	s1,56(sp)
    800045c2:	7942                	ld	s2,48(sp)
    800045c4:	79a2                	ld	s3,40(sp)
    800045c6:	6161                	addi	sp,sp,80
    800045c8:	8082                	ret
  return -1;
    800045ca:	557d                	li	a0,-1
    800045cc:	bfc5                	j	800045bc <filestat+0x4c>

00000000800045ce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045ce:	7179                	addi	sp,sp,-48
    800045d0:	f406                	sd	ra,40(sp)
    800045d2:	f022                	sd	s0,32(sp)
    800045d4:	ec26                	sd	s1,24(sp)
    800045d6:	e84a                	sd	s2,16(sp)
    800045d8:	e44e                	sd	s3,8(sp)
    800045da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045dc:	00854783          	lbu	a5,8(a0)
    800045e0:	cbc1                	beqz	a5,80004670 <fileread+0xa2>
    800045e2:	84aa                	mv	s1,a0
    800045e4:	89ae                	mv	s3,a1
    800045e6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045e8:	411c                	lw	a5,0(a0)
    800045ea:	4705                	li	a4,1
    800045ec:	04e78363          	beq	a5,a4,80004632 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045f0:	470d                	li	a4,3
    800045f2:	04e78563          	beq	a5,a4,8000463c <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045f6:	4709                	li	a4,2
    800045f8:	06e79663          	bne	a5,a4,80004664 <fileread+0x96>
    ilock(f->ip);
    800045fc:	6d08                	ld	a0,24(a0)
    800045fe:	8d8ff0ef          	jal	ra,800036d6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004602:	874a                	mv	a4,s2
    80004604:	5094                	lw	a3,32(s1)
    80004606:	864e                	mv	a2,s3
    80004608:	4585                	li	a1,1
    8000460a:	6c88                	ld	a0,24(s1)
    8000460c:	c56ff0ef          	jal	ra,80003a62 <readi>
    80004610:	892a                	mv	s2,a0
    80004612:	00a05563          	blez	a0,8000461c <fileread+0x4e>
      f->off += r;
    80004616:	509c                	lw	a5,32(s1)
    80004618:	9fa9                	addw	a5,a5,a0
    8000461a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000461c:	6c88                	ld	a0,24(s1)
    8000461e:	962ff0ef          	jal	ra,80003780 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004622:	854a                	mv	a0,s2
    80004624:	70a2                	ld	ra,40(sp)
    80004626:	7402                	ld	s0,32(sp)
    80004628:	64e2                	ld	s1,24(sp)
    8000462a:	6942                	ld	s2,16(sp)
    8000462c:	69a2                	ld	s3,8(sp)
    8000462e:	6145                	addi	sp,sp,48
    80004630:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004632:	6908                	ld	a0,16(a0)
    80004634:	34e000ef          	jal	ra,80004982 <piperead>
    80004638:	892a                	mv	s2,a0
    8000463a:	b7e5                	j	80004622 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000463c:	02451783          	lh	a5,36(a0)
    80004640:	03079693          	slli	a3,a5,0x30
    80004644:	92c1                	srli	a3,a3,0x30
    80004646:	4725                	li	a4,9
    80004648:	02d76663          	bltu	a4,a3,80004674 <fileread+0xa6>
    8000464c:	0792                	slli	a5,a5,0x4
    8000464e:	00243717          	auipc	a4,0x243
    80004652:	3da70713          	addi	a4,a4,986 # 80247a28 <devsw>
    80004656:	97ba                	add	a5,a5,a4
    80004658:	639c                	ld	a5,0(a5)
    8000465a:	cf99                	beqz	a5,80004678 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    8000465c:	4505                	li	a0,1
    8000465e:	9782                	jalr	a5
    80004660:	892a                	mv	s2,a0
    80004662:	b7c1                	j	80004622 <fileread+0x54>
    panic("fileread");
    80004664:	00003517          	auipc	a0,0x3
    80004668:	03c50513          	addi	a0,a0,60 # 800076a0 <syscalls+0x2a8>
    8000466c:	91cfc0ef          	jal	ra,80000788 <panic>
    return -1;
    80004670:	597d                	li	s2,-1
    80004672:	bf45                	j	80004622 <fileread+0x54>
      return -1;
    80004674:	597d                	li	s2,-1
    80004676:	b775                	j	80004622 <fileread+0x54>
    80004678:	597d                	li	s2,-1
    8000467a:	b765                	j	80004622 <fileread+0x54>

000000008000467c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000467c:	715d                	addi	sp,sp,-80
    8000467e:	e486                	sd	ra,72(sp)
    80004680:	e0a2                	sd	s0,64(sp)
    80004682:	fc26                	sd	s1,56(sp)
    80004684:	f84a                	sd	s2,48(sp)
    80004686:	f44e                	sd	s3,40(sp)
    80004688:	f052                	sd	s4,32(sp)
    8000468a:	ec56                	sd	s5,24(sp)
    8000468c:	e85a                	sd	s6,16(sp)
    8000468e:	e45e                	sd	s7,8(sp)
    80004690:	e062                	sd	s8,0(sp)
    80004692:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004694:	00954783          	lbu	a5,9(a0)
    80004698:	0e078863          	beqz	a5,80004788 <filewrite+0x10c>
    8000469c:	892a                	mv	s2,a0
    8000469e:	8b2e                	mv	s6,a1
    800046a0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046a2:	411c                	lw	a5,0(a0)
    800046a4:	4705                	li	a4,1
    800046a6:	02e78263          	beq	a5,a4,800046ca <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046aa:	470d                	li	a4,3
    800046ac:	02e78463          	beq	a5,a4,800046d4 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046b0:	4709                	li	a4,2
    800046b2:	0ce79563          	bne	a5,a4,8000477c <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046b6:	0ac05163          	blez	a2,80004758 <filewrite+0xdc>
    int i = 0;
    800046ba:	4981                	li	s3,0
    800046bc:	6b85                	lui	s7,0x1
    800046be:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800046c2:	6c05                	lui	s8,0x1
    800046c4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800046c8:	a041                	j	80004748 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800046ca:	6908                	ld	a0,16(a0)
    800046cc:	1e2000ef          	jal	ra,800048ae <pipewrite>
    800046d0:	8a2a                	mv	s4,a0
    800046d2:	a071                	j	8000475e <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046d4:	02451783          	lh	a5,36(a0)
    800046d8:	03079693          	slli	a3,a5,0x30
    800046dc:	92c1                	srli	a3,a3,0x30
    800046de:	4725                	li	a4,9
    800046e0:	0ad76663          	bltu	a4,a3,8000478c <filewrite+0x110>
    800046e4:	0792                	slli	a5,a5,0x4
    800046e6:	00243717          	auipc	a4,0x243
    800046ea:	34270713          	addi	a4,a4,834 # 80247a28 <devsw>
    800046ee:	97ba                	add	a5,a5,a4
    800046f0:	679c                	ld	a5,8(a5)
    800046f2:	cfd9                	beqz	a5,80004790 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800046f4:	4505                	li	a0,1
    800046f6:	9782                	jalr	a5
    800046f8:	8a2a                	mv	s4,a0
    800046fa:	a095                	j	8000475e <filewrite+0xe2>
    800046fc:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004700:	9bfff0ef          	jal	ra,800040be <begin_op>
      ilock(f->ip);
    80004704:	01893503          	ld	a0,24(s2)
    80004708:	fcffe0ef          	jal	ra,800036d6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000470c:	8756                	mv	a4,s5
    8000470e:	02092683          	lw	a3,32(s2)
    80004712:	01698633          	add	a2,s3,s6
    80004716:	4585                	li	a1,1
    80004718:	01893503          	ld	a0,24(s2)
    8000471c:	c2aff0ef          	jal	ra,80003b46 <writei>
    80004720:	84aa                	mv	s1,a0
    80004722:	00a05763          	blez	a0,80004730 <filewrite+0xb4>
        f->off += r;
    80004726:	02092783          	lw	a5,32(s2)
    8000472a:	9fa9                	addw	a5,a5,a0
    8000472c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004730:	01893503          	ld	a0,24(s2)
    80004734:	84cff0ef          	jal	ra,80003780 <iunlock>
      end_op();
    80004738:	9f5ff0ef          	jal	ra,8000412c <end_op>

      if(r != n1){
    8000473c:	009a9f63          	bne	s5,s1,8000475a <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004740:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004744:	0149db63          	bge	s3,s4,8000475a <filewrite+0xde>
      int n1 = n - i;
    80004748:	413a04bb          	subw	s1,s4,s3
    8000474c:	0004879b          	sext.w	a5,s1
    80004750:	fafbd6e3          	bge	s7,a5,800046fc <filewrite+0x80>
    80004754:	84e2                	mv	s1,s8
    80004756:	b75d                	j	800046fc <filewrite+0x80>
    int i = 0;
    80004758:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000475a:	013a1f63          	bne	s4,s3,80004778 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000475e:	8552                	mv	a0,s4
    80004760:	60a6                	ld	ra,72(sp)
    80004762:	6406                	ld	s0,64(sp)
    80004764:	74e2                	ld	s1,56(sp)
    80004766:	7942                	ld	s2,48(sp)
    80004768:	79a2                	ld	s3,40(sp)
    8000476a:	7a02                	ld	s4,32(sp)
    8000476c:	6ae2                	ld	s5,24(sp)
    8000476e:	6b42                	ld	s6,16(sp)
    80004770:	6ba2                	ld	s7,8(sp)
    80004772:	6c02                	ld	s8,0(sp)
    80004774:	6161                	addi	sp,sp,80
    80004776:	8082                	ret
    ret = (i == n ? n : -1);
    80004778:	5a7d                	li	s4,-1
    8000477a:	b7d5                	j	8000475e <filewrite+0xe2>
    panic("filewrite");
    8000477c:	00003517          	auipc	a0,0x3
    80004780:	f3450513          	addi	a0,a0,-204 # 800076b0 <syscalls+0x2b8>
    80004784:	804fc0ef          	jal	ra,80000788 <panic>
    return -1;
    80004788:	5a7d                	li	s4,-1
    8000478a:	bfd1                	j	8000475e <filewrite+0xe2>
      return -1;
    8000478c:	5a7d                	li	s4,-1
    8000478e:	bfc1                	j	8000475e <filewrite+0xe2>
    80004790:	5a7d                	li	s4,-1
    80004792:	b7f1                	j	8000475e <filewrite+0xe2>

0000000080004794 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004794:	7179                	addi	sp,sp,-48
    80004796:	f406                	sd	ra,40(sp)
    80004798:	f022                	sd	s0,32(sp)
    8000479a:	ec26                	sd	s1,24(sp)
    8000479c:	e84a                	sd	s2,16(sp)
    8000479e:	e44e                	sd	s3,8(sp)
    800047a0:	e052                	sd	s4,0(sp)
    800047a2:	1800                	addi	s0,sp,48
    800047a4:	84aa                	mv	s1,a0
    800047a6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047a8:	0005b023          	sd	zero,0(a1)
    800047ac:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047b0:	c75ff0ef          	jal	ra,80004424 <filealloc>
    800047b4:	e088                	sd	a0,0(s1)
    800047b6:	cd35                	beqz	a0,80004832 <pipealloc+0x9e>
    800047b8:	c6dff0ef          	jal	ra,80004424 <filealloc>
    800047bc:	00aa3023          	sd	a0,0(s4)
    800047c0:	c52d                	beqz	a0,8000482a <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800047c2:	be8fc0ef          	jal	ra,80000baa <kalloc>
    800047c6:	892a                	mv	s2,a0
    800047c8:	cd31                	beqz	a0,80004824 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800047ca:	4985                	li	s3,1
    800047cc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800047d0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800047d4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800047d8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800047dc:	00003597          	auipc	a1,0x3
    800047e0:	ee458593          	addi	a1,a1,-284 # 800076c0 <syscalls+0x2c8>
    800047e4:	c3cfc0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    800047e8:	609c                	ld	a5,0(s1)
    800047ea:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800047ee:	609c                	ld	a5,0(s1)
    800047f0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800047f4:	609c                	ld	a5,0(s1)
    800047f6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800047fa:	609c                	ld	a5,0(s1)
    800047fc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004800:	000a3783          	ld	a5,0(s4)
    80004804:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004808:	000a3783          	ld	a5,0(s4)
    8000480c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004810:	000a3783          	ld	a5,0(s4)
    80004814:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004818:	000a3783          	ld	a5,0(s4)
    8000481c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004820:	4501                	li	a0,0
    80004822:	a005                	j	80004842 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004824:	6088                	ld	a0,0(s1)
    80004826:	e501                	bnez	a0,8000482e <pipealloc+0x9a>
    80004828:	a029                	j	80004832 <pipealloc+0x9e>
    8000482a:	6088                	ld	a0,0(s1)
    8000482c:	c11d                	beqz	a0,80004852 <pipealloc+0xbe>
    fileclose(*f0);
    8000482e:	c9bff0ef          	jal	ra,800044c8 <fileclose>
  if(*f1)
    80004832:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004836:	557d                	li	a0,-1
  if(*f1)
    80004838:	c789                	beqz	a5,80004842 <pipealloc+0xae>
    fileclose(*f1);
    8000483a:	853e                	mv	a0,a5
    8000483c:	c8dff0ef          	jal	ra,800044c8 <fileclose>
  return -1;
    80004840:	557d                	li	a0,-1
}
    80004842:	70a2                	ld	ra,40(sp)
    80004844:	7402                	ld	s0,32(sp)
    80004846:	64e2                	ld	s1,24(sp)
    80004848:	6942                	ld	s2,16(sp)
    8000484a:	69a2                	ld	s3,8(sp)
    8000484c:	6a02                	ld	s4,0(sp)
    8000484e:	6145                	addi	sp,sp,48
    80004850:	8082                	ret
  return -1;
    80004852:	557d                	li	a0,-1
    80004854:	b7fd                	j	80004842 <pipealloc+0xae>

0000000080004856 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec06                	sd	ra,24(sp)
    8000485a:	e822                	sd	s0,16(sp)
    8000485c:	e426                	sd	s1,8(sp)
    8000485e:	e04a                	sd	s2,0(sp)
    80004860:	1000                	addi	s0,sp,32
    80004862:	84aa                	mv	s1,a0
    80004864:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004866:	c3afc0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    8000486a:	02090763          	beqz	s2,80004898 <pipeclose+0x42>
    pi->writeopen = 0;
    8000486e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004872:	21848513          	addi	a0,s1,536
    80004876:	947fd0ef          	jal	ra,800021bc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000487a:	2204b783          	ld	a5,544(s1)
    8000487e:	e785                	bnez	a5,800048a6 <pipeclose+0x50>
    release(&pi->lock);
    80004880:	8526                	mv	a0,s1
    80004882:	cb6fc0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004886:	8526                	mv	a0,s1
    80004888:	9f2fc0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    8000488c:	60e2                	ld	ra,24(sp)
    8000488e:	6442                	ld	s0,16(sp)
    80004890:	64a2                	ld	s1,8(sp)
    80004892:	6902                	ld	s2,0(sp)
    80004894:	6105                	addi	sp,sp,32
    80004896:	8082                	ret
    pi->readopen = 0;
    80004898:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000489c:	21c48513          	addi	a0,s1,540
    800048a0:	91dfd0ef          	jal	ra,800021bc <wakeup>
    800048a4:	bfd9                	j	8000487a <pipeclose+0x24>
    release(&pi->lock);
    800048a6:	8526                	mv	a0,s1
    800048a8:	c90fc0ef          	jal	ra,80000d38 <release>
}
    800048ac:	b7c5                	j	8000488c <pipeclose+0x36>

00000000800048ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800048ae:	711d                	addi	sp,sp,-96
    800048b0:	ec86                	sd	ra,88(sp)
    800048b2:	e8a2                	sd	s0,80(sp)
    800048b4:	e4a6                	sd	s1,72(sp)
    800048b6:	e0ca                	sd	s2,64(sp)
    800048b8:	fc4e                	sd	s3,56(sp)
    800048ba:	f852                	sd	s4,48(sp)
    800048bc:	f456                	sd	s5,40(sp)
    800048be:	f05a                	sd	s6,32(sp)
    800048c0:	ec5e                	sd	s7,24(sp)
    800048c2:	e862                	sd	s8,16(sp)
    800048c4:	1080                	addi	s0,sp,96
    800048c6:	84aa                	mv	s1,a0
    800048c8:	8aae                	mv	s5,a1
    800048ca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800048cc:	a36fd0ef          	jal	ra,80001b02 <myproc>
    800048d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800048d2:	8526                	mv	a0,s1
    800048d4:	bccfc0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    800048d8:	09405c63          	blez	s4,80004970 <pipewrite+0xc2>
  int i = 0;
    800048dc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048de:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800048e0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800048e4:	21c48b93          	addi	s7,s1,540
    800048e8:	a81d                	j	8000491e <pipewrite+0x70>
      release(&pi->lock);
    800048ea:	8526                	mv	a0,s1
    800048ec:	c4cfc0ef          	jal	ra,80000d38 <release>
      return -1;
    800048f0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800048f2:	854a                	mv	a0,s2
    800048f4:	60e6                	ld	ra,88(sp)
    800048f6:	6446                	ld	s0,80(sp)
    800048f8:	64a6                	ld	s1,72(sp)
    800048fa:	6906                	ld	s2,64(sp)
    800048fc:	79e2                	ld	s3,56(sp)
    800048fe:	7a42                	ld	s4,48(sp)
    80004900:	7aa2                	ld	s5,40(sp)
    80004902:	7b02                	ld	s6,32(sp)
    80004904:	6be2                	ld	s7,24(sp)
    80004906:	6c42                	ld	s8,16(sp)
    80004908:	6125                	addi	sp,sp,96
    8000490a:	8082                	ret
      wakeup(&pi->nread);
    8000490c:	8562                	mv	a0,s8
    8000490e:	8affd0ef          	jal	ra,800021bc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004912:	85a6                	mv	a1,s1
    80004914:	855e                	mv	a0,s7
    80004916:	85bfd0ef          	jal	ra,80002170 <sleep>
  while(i < n){
    8000491a:	05495c63          	bge	s2,s4,80004972 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    8000491e:	2204a783          	lw	a5,544(s1)
    80004922:	d7e1                	beqz	a5,800048ea <pipewrite+0x3c>
    80004924:	854e                	mv	a0,s3
    80004926:	a83fd0ef          	jal	ra,800023a8 <killed>
    8000492a:	f161                	bnez	a0,800048ea <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000492c:	2184a783          	lw	a5,536(s1)
    80004930:	21c4a703          	lw	a4,540(s1)
    80004934:	2007879b          	addiw	a5,a5,512
    80004938:	fcf70ae3          	beq	a4,a5,8000490c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000493c:	4685                	li	a3,1
    8000493e:	01590633          	add	a2,s2,s5
    80004942:	faf40593          	addi	a1,s0,-81
    80004946:	0509b503          	ld	a0,80(s3)
    8000494a:	efffc0ef          	jal	ra,80001848 <copyin>
    8000494e:	03650263          	beq	a0,s6,80004972 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004952:	21c4a783          	lw	a5,540(s1)
    80004956:	0017871b          	addiw	a4,a5,1
    8000495a:	20e4ae23          	sw	a4,540(s1)
    8000495e:	1ff7f793          	andi	a5,a5,511
    80004962:	97a6                	add	a5,a5,s1
    80004964:	faf44703          	lbu	a4,-81(s0)
    80004968:	00e78c23          	sb	a4,24(a5)
      i++;
    8000496c:	2905                	addiw	s2,s2,1
    8000496e:	b775                	j	8000491a <pipewrite+0x6c>
  int i = 0;
    80004970:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004972:	21848513          	addi	a0,s1,536
    80004976:	847fd0ef          	jal	ra,800021bc <wakeup>
  release(&pi->lock);
    8000497a:	8526                	mv	a0,s1
    8000497c:	bbcfc0ef          	jal	ra,80000d38 <release>
  return i;
    80004980:	bf8d                	j	800048f2 <pipewrite+0x44>

0000000080004982 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004982:	715d                	addi	sp,sp,-80
    80004984:	e486                	sd	ra,72(sp)
    80004986:	e0a2                	sd	s0,64(sp)
    80004988:	fc26                	sd	s1,56(sp)
    8000498a:	f84a                	sd	s2,48(sp)
    8000498c:	f44e                	sd	s3,40(sp)
    8000498e:	f052                	sd	s4,32(sp)
    80004990:	ec56                	sd	s5,24(sp)
    80004992:	e85a                	sd	s6,16(sp)
    80004994:	0880                	addi	s0,sp,80
    80004996:	84aa                	mv	s1,a0
    80004998:	892e                	mv	s2,a1
    8000499a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000499c:	966fd0ef          	jal	ra,80001b02 <myproc>
    800049a0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800049a2:	8526                	mv	a0,s1
    800049a4:	afcfc0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049a8:	2184a703          	lw	a4,536(s1)
    800049ac:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049b0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049b4:	02f71363          	bne	a4,a5,800049da <piperead+0x58>
    800049b8:	2244a783          	lw	a5,548(s1)
    800049bc:	cf99                	beqz	a5,800049da <piperead+0x58>
    if(killed(pr)){
    800049be:	8552                	mv	a0,s4
    800049c0:	9e9fd0ef          	jal	ra,800023a8 <killed>
    800049c4:	e151                	bnez	a0,80004a48 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049c6:	85a6                	mv	a1,s1
    800049c8:	854e                	mv	a0,s3
    800049ca:	fa6fd0ef          	jal	ra,80002170 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049ce:	2184a703          	lw	a4,536(s1)
    800049d2:	21c4a783          	lw	a5,540(s1)
    800049d6:	fef701e3          	beq	a4,a5,800049b8 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049da:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800049dc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049de:	05505363          	blez	s5,80004a24 <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    800049e2:	2184a783          	lw	a5,536(s1)
    800049e6:	21c4a703          	lw	a4,540(s1)
    800049ea:	02f70d63          	beq	a4,a5,80004a24 <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    800049ee:	1ff7f793          	andi	a5,a5,511
    800049f2:	97a6                	add	a5,a5,s1
    800049f4:	0187c783          	lbu	a5,24(a5)
    800049f8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800049fc:	4685                	li	a3,1
    800049fe:	fbf40613          	addi	a2,s0,-65
    80004a02:	85ca                	mv	a1,s2
    80004a04:	050a3503          	ld	a0,80(s4)
    80004a08:	d57fc0ef          	jal	ra,8000175e <copyout>
    80004a0c:	05650363          	beq	a0,s6,80004a52 <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004a10:	2184a783          	lw	a5,536(s1)
    80004a14:	2785                	addiw	a5,a5,1
    80004a16:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a1a:	2985                	addiw	s3,s3,1
    80004a1c:	0905                	addi	s2,s2,1
    80004a1e:	fd3a92e3          	bne	s5,s3,800049e2 <piperead+0x60>
    80004a22:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a24:	21c48513          	addi	a0,s1,540
    80004a28:	f94fd0ef          	jal	ra,800021bc <wakeup>
  release(&pi->lock);
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	b0afc0ef          	jal	ra,80000d38 <release>
  return i;
}
    80004a32:	854e                	mv	a0,s3
    80004a34:	60a6                	ld	ra,72(sp)
    80004a36:	6406                	ld	s0,64(sp)
    80004a38:	74e2                	ld	s1,56(sp)
    80004a3a:	7942                	ld	s2,48(sp)
    80004a3c:	79a2                	ld	s3,40(sp)
    80004a3e:	7a02                	ld	s4,32(sp)
    80004a40:	6ae2                	ld	s5,24(sp)
    80004a42:	6b42                	ld	s6,16(sp)
    80004a44:	6161                	addi	sp,sp,80
    80004a46:	8082                	ret
      release(&pi->lock);
    80004a48:	8526                	mv	a0,s1
    80004a4a:	aeefc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004a4e:	59fd                	li	s3,-1
    80004a50:	b7cd                	j	80004a32 <piperead+0xb0>
      if(i == 0)
    80004a52:	fc0999e3          	bnez	s3,80004a24 <piperead+0xa2>
        i = -1;
    80004a56:	89aa                	mv	s3,a0
    80004a58:	b7f1                	j	80004a24 <piperead+0xa2>

0000000080004a5a <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004a5a:	1141                	addi	sp,sp,-16
    80004a5c:	e422                	sd	s0,8(sp)
    80004a5e:	0800                	addi	s0,sp,16
    80004a60:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004a62:	8905                	andi	a0,a0,1
    80004a64:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004a66:	8b89                	andi	a5,a5,2
    80004a68:	c399                	beqz	a5,80004a6e <flags2perm+0x14>
      perm |= PTE_W;
    80004a6a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a6e:	6422                	ld	s0,8(sp)
    80004a70:	0141                	addi	sp,sp,16
    80004a72:	8082                	ret

0000000080004a74 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004a74:	bd010113          	addi	sp,sp,-1072
    80004a78:	42113423          	sd	ra,1064(sp)
    80004a7c:	42813023          	sd	s0,1056(sp)
    80004a80:	40913c23          	sd	s1,1048(sp)
    80004a84:	41213823          	sd	s2,1040(sp)
    80004a88:	41313423          	sd	s3,1032(sp)
    80004a8c:	41413023          	sd	s4,1024(sp)
    80004a90:	3f513c23          	sd	s5,1016(sp)
    80004a94:	3f613823          	sd	s6,1008(sp)
    80004a98:	3f713423          	sd	s7,1000(sp)
    80004a9c:	3f813023          	sd	s8,992(sp)
    80004aa0:	3d913c23          	sd	s9,984(sp)
    80004aa4:	3da13823          	sd	s10,976(sp)
    80004aa8:	3db13423          	sd	s11,968(sp)
    80004aac:	43010413          	addi	s0,sp,1072
    80004ab0:	84aa                	mv	s1,a0
    80004ab2:	bea43023          	sd	a0,-1056(s0)
    80004ab6:	beb43423          	sd	a1,-1048(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004aba:	848fd0ef          	jal	ra,80001b02 <myproc>
    80004abe:	bea43c23          	sd	a0,-1032(s0)

  begin_op();
    80004ac2:	dfcff0ef          	jal	ra,800040be <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	c02ff0ef          	jal	ra,80003eca <namei>
    80004acc:	cd25                	beqz	a0,80004b44 <kexec+0xd0>
    80004ace:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ad0:	c07fe0ef          	jal	ra,800036d6 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ad4:	04000713          	li	a4,64
    80004ad8:	4681                	li	a3,0
    80004ada:	e5040613          	addi	a2,s0,-432
    80004ade:	4581                	li	a1,0
    80004ae0:	8556                	mv	a0,s5
    80004ae2:	f81fe0ef          	jal	ra,80003a62 <readi>
    80004ae6:	04000793          	li	a5,64
    80004aea:	00f51a63          	bne	a0,a5,80004afe <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004aee:	e5042703          	lw	a4,-432(s0)
    80004af2:	464c47b7          	lui	a5,0x464c4
    80004af6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004afa:	04f70963          	beq	a4,a5,80004b4c <kexec+0xd8>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    memset(p->vmas, 0, sizeof(p->vmas));
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80004afe:	8556                	mv	a0,s5
    80004b00:	dddfe0ef          	jal	ra,800038dc <iunlockput>
    end_op();
    80004b04:	e28ff0ef          	jal	ra,8000412c <end_op>
  }
  return -1;
    80004b08:	557d                	li	a0,-1
}
    80004b0a:	42813083          	ld	ra,1064(sp)
    80004b0e:	42013403          	ld	s0,1056(sp)
    80004b12:	41813483          	ld	s1,1048(sp)
    80004b16:	41013903          	ld	s2,1040(sp)
    80004b1a:	40813983          	ld	s3,1032(sp)
    80004b1e:	40013a03          	ld	s4,1024(sp)
    80004b22:	3f813a83          	ld	s5,1016(sp)
    80004b26:	3f013b03          	ld	s6,1008(sp)
    80004b2a:	3e813b83          	ld	s7,1000(sp)
    80004b2e:	3e013c03          	ld	s8,992(sp)
    80004b32:	3d813c83          	ld	s9,984(sp)
    80004b36:	3d013d03          	ld	s10,976(sp)
    80004b3a:	3c813d83          	ld	s11,968(sp)
    80004b3e:	43010113          	addi	sp,sp,1072
    80004b42:	8082                	ret
    end_op();
    80004b44:	de8ff0ef          	jal	ra,8000412c <end_op>
    return -1;
    80004b48:	557d                	li	a0,-1
    80004b4a:	b7c1                	j	80004b0a <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80004b4c:	bf843503          	ld	a0,-1032(s0)
    80004b50:	8b8fd0ef          	jal	ra,80001c08 <proc_pagetable>
    80004b54:	8baa                	mv	s7,a0
    80004b56:	d545                	beqz	a0,80004afe <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b58:	e7042783          	lw	a5,-400(s0)
    80004b5c:	e8845703          	lhu	a4,-376(s0)
    80004b60:	0e070d63          	beqz	a4,80004c5a <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b64:	be043823          	sd	zero,-1040(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b68:	c0043423          	sd	zero,-1016(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004b6c:	6a05                	lui	s4,0x1
    80004b6e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004b72:	bce43c23          	sd	a4,-1064(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004b76:	6d85                	lui	s11,0x1
    80004b78:	7d7d                	lui	s10,0xfffff
    80004b7a:	a09d                	j	80004be0 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004b7c:	00003517          	auipc	a0,0x3
    80004b80:	b4c50513          	addi	a0,a0,-1204 # 800076c8 <syscalls+0x2d0>
    80004b84:	c05fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004b88:	874a                	mv	a4,s2
    80004b8a:	009c86bb          	addw	a3,s9,s1
    80004b8e:	4581                	li	a1,0
    80004b90:	8556                	mv	a0,s5
    80004b92:	ed1fe0ef          	jal	ra,80003a62 <readi>
    80004b96:	2501                	sext.w	a0,a0
    80004b98:	0ea91f63          	bne	s2,a0,80004c96 <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    80004b9c:	009d84bb          	addw	s1,s11,s1
    80004ba0:	013d09bb          	addw	s3,s10,s3
    80004ba4:	0364f063          	bgeu	s1,s6,80004bc4 <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004ba8:	02049593          	slli	a1,s1,0x20
    80004bac:	9181                	srli	a1,a1,0x20
    80004bae:	95e2                	add	a1,a1,s8
    80004bb0:	855e                	mv	a0,s7
    80004bb2:	cd8fc0ef          	jal	ra,8000108a <walkaddr>
    80004bb6:	862a                	mv	a2,a0
    if(pa == 0)
    80004bb8:	d171                	beqz	a0,80004b7c <kexec+0x108>
      n = PGSIZE;
    80004bba:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004bbc:	fd49f6e3          	bgeu	s3,s4,80004b88 <kexec+0x114>
      n = sz - i;
    80004bc0:	894e                	mv	s2,s3
    80004bc2:	b7d9                	j	80004b88 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bc4:	c0843783          	ld	a5,-1016(s0)
    80004bc8:	0017869b          	addiw	a3,a5,1
    80004bcc:	c0d43423          	sd	a3,-1016(s0)
    80004bd0:	c0043783          	ld	a5,-1024(s0)
    80004bd4:	0387879b          	addiw	a5,a5,56
    80004bd8:	e8845703          	lhu	a4,-376(s0)
    80004bdc:	08e6d163          	bge	a3,a4,80004c5e <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004be0:	2781                	sext.w	a5,a5
    80004be2:	c0f43023          	sd	a5,-1024(s0)
    80004be6:	03800713          	li	a4,56
    80004bea:	86be                	mv	a3,a5
    80004bec:	e1840613          	addi	a2,s0,-488
    80004bf0:	4581                	li	a1,0
    80004bf2:	8556                	mv	a0,s5
    80004bf4:	e6ffe0ef          	jal	ra,80003a62 <readi>
    80004bf8:	03800793          	li	a5,56
    80004bfc:	08f51d63          	bne	a0,a5,80004c96 <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80004c00:	e1842783          	lw	a5,-488(s0)
    80004c04:	4705                	li	a4,1
    80004c06:	fae79fe3          	bne	a5,a4,80004bc4 <kexec+0x150>
    if(ph.memsz < ph.filesz)
    80004c0a:	e4043483          	ld	s1,-448(s0)
    80004c0e:	e3843783          	ld	a5,-456(s0)
    80004c12:	08f4e263          	bltu	s1,a5,80004c96 <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004c16:	e2843783          	ld	a5,-472(s0)
    80004c1a:	94be                	add	s1,s1,a5
    80004c1c:	06f4ed63          	bltu	s1,a5,80004c96 <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80004c20:	bd843703          	ld	a4,-1064(s0)
    80004c24:	8ff9                	and	a5,a5,a4
    80004c26:	eba5                	bnez	a5,80004c96 <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004c28:	e1c42503          	lw	a0,-484(s0)
    80004c2c:	e2fff0ef          	jal	ra,80004a5a <flags2perm>
    80004c30:	86aa                	mv	a3,a0
    80004c32:	8626                	mv	a2,s1
    80004c34:	bf043583          	ld	a1,-1040(s0)
    80004c38:	855e                	mv	a0,s7
    80004c3a:	f1afc0ef          	jal	ra,80001354 <uvmalloc>
    80004c3e:	bea43823          	sd	a0,-1040(s0)
    80004c42:	c931                	beqz	a0,80004c96 <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004c44:	e2843c03          	ld	s8,-472(s0)
    80004c48:	e2042c83          	lw	s9,-480(s0)
    80004c4c:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004c50:	f60b0ae3          	beqz	s6,80004bc4 <kexec+0x150>
    80004c54:	89da                	mv	s3,s6
    80004c56:	4481                	li	s1,0
    80004c58:	bf81                	j	80004ba8 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c5a:	be043823          	sd	zero,-1040(s0)
  iunlockput(ip);
    80004c5e:	8556                	mv	a0,s5
    80004c60:	c7dfe0ef          	jal	ra,800038dc <iunlockput>
  end_op();
    80004c64:	cc8ff0ef          	jal	ra,8000412c <end_op>
  p = myproc();
    80004c68:	e9bfc0ef          	jal	ra,80001b02 <myproc>
    80004c6c:	bea43c23          	sd	a0,-1032(s0)
  uint64 oldsz = p->sz;
    80004c70:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004c74:	6785                	lui	a5,0x1
    80004c76:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004c78:	bf043703          	ld	a4,-1040(s0)
    80004c7c:	00f705b3          	add	a1,a4,a5
    80004c80:	77fd                	lui	a5,0xfffff
    80004c82:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004c84:	4691                	li	a3,4
    80004c86:	6609                	lui	a2,0x2
    80004c88:	962e                	add	a2,a2,a1
    80004c8a:	855e                	mv	a0,s7
    80004c8c:	ec8fc0ef          	jal	ra,80001354 <uvmalloc>
    80004c90:	8b2a                	mv	s6,a0
  ip = 0;
    80004c92:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004c94:	e915                	bnez	a0,80004cc8 <kexec+0x254>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80004c96:	bf843903          	ld	s2,-1032(s0)
    80004c9a:	16890493          	addi	s1,s2,360
    80004c9e:	85a6                	mv	a1,s1
    80004ca0:	05093503          	ld	a0,80(s2)
    80004ca4:	fe9fc0ef          	jal	ra,80001c8c <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80004ca8:	20000613          	li	a2,512
    80004cac:	4581                	li	a1,0
    80004cae:	8526                	mv	a0,s1
    80004cb0:	8c4fc0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80004cb4:	04893583          	ld	a1,72(s2)
    80004cb8:	05093503          	ld	a0,80(s2)
    80004cbc:	81afd0ef          	jal	ra,80001cd6 <proc_freepagetable>
  if(ip){
    80004cc0:	e20a9fe3          	bnez	s5,80004afe <kexec+0x8a>
  return -1;
    80004cc4:	557d                	li	a0,-1
    80004cc6:	b591                	j	80004b0a <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004cc8:	75f9                	lui	a1,0xffffe
    80004cca:	95aa                	add	a1,a1,a0
    80004ccc:	855e                	mv	a0,s7
    80004cce:	929fc0ef          	jal	ra,800015f6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004cd2:	7c7d                	lui	s8,0xfffff
    80004cd4:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004cd6:	be843783          	ld	a5,-1048(s0)
    80004cda:	6388                	ld	a0,0(a5)
    80004cdc:	c125                	beqz	a0,80004d3c <kexec+0x2c8>
    80004cde:	e9040993          	addi	s3,s0,-368
    80004ce2:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    80004ce6:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ce8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004cea:	a02fc0ef          	jal	ra,80000eec <strlen>
    80004cee:	0015079b          	addiw	a5,a0,1
    80004cf2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004cf6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004cfa:	11896563          	bltu	s2,s8,80004e04 <kexec+0x390>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004cfe:	be843d03          	ld	s10,-1048(s0)
    80004d02:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdb6440>
    80004d06:	8552                	mv	a0,s4
    80004d08:	9e4fc0ef          	jal	ra,80000eec <strlen>
    80004d0c:	0015069b          	addiw	a3,a0,1
    80004d10:	8652                	mv	a2,s4
    80004d12:	85ca                	mv	a1,s2
    80004d14:	855e                	mv	a0,s7
    80004d16:	a49fc0ef          	jal	ra,8000175e <copyout>
    80004d1a:	0e054763          	bltz	a0,80004e08 <kexec+0x394>
    ustack[argc] = sp;
    80004d1e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d22:	0485                	addi	s1,s1,1
    80004d24:	008d0793          	addi	a5,s10,8
    80004d28:	bef43423          	sd	a5,-1048(s0)
    80004d2c:	008d3503          	ld	a0,8(s10)
    80004d30:	c901                	beqz	a0,80004d40 <kexec+0x2cc>
    if(argc >= MAXARG)
    80004d32:	09a1                	addi	s3,s3,8
    80004d34:	fb599be3          	bne	s3,s5,80004cea <kexec+0x276>
  ip = 0;
    80004d38:	4a81                	li	s5,0
    80004d3a:	bfb1                	j	80004c96 <kexec+0x222>
  sp = sz;
    80004d3c:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004d3e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d40:	00349793          	slli	a5,s1,0x3
    80004d44:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdb63d0>
    80004d48:	97a2                	add	a5,a5,s0
    80004d4a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004d4e:	00148693          	addi	a3,s1,1
    80004d52:	068e                	slli	a3,a3,0x3
    80004d54:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d58:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80004d5c:	4a81                	li	s5,0
  if(sp < stackbase)
    80004d5e:	f3896ce3          	bltu	s2,s8,80004c96 <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d62:	e9040613          	addi	a2,s0,-368
    80004d66:	85ca                	mv	a1,s2
    80004d68:	855e                	mv	a0,s7
    80004d6a:	9f5fc0ef          	jal	ra,8000175e <copyout>
    80004d6e:	08054f63          	bltz	a0,80004e0c <kexec+0x398>
  p->trapframe->a1 = sp;
    80004d72:	bf843783          	ld	a5,-1032(s0)
    80004d76:	6fbc                	ld	a5,88(a5)
    80004d78:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004d7c:	be043783          	ld	a5,-1056(s0)
    80004d80:	0007c703          	lbu	a4,0(a5)
    80004d84:	cf11                	beqz	a4,80004da0 <kexec+0x32c>
    80004d86:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d88:	02f00693          	li	a3,47
    80004d8c:	a039                	j	80004d9a <kexec+0x326>
      last = s+1;
    80004d8e:	bef43023          	sd	a5,-1056(s0)
  for(last=s=path; *s; s++)
    80004d92:	0785                	addi	a5,a5,1
    80004d94:	fff7c703          	lbu	a4,-1(a5)
    80004d98:	c701                	beqz	a4,80004da0 <kexec+0x32c>
    if(*s == '/')
    80004d9a:	fed71ce3          	bne	a4,a3,80004d92 <kexec+0x31e>
    80004d9e:	bfc5                	j	80004d8e <kexec+0x31a>
  safestrcpy(p->name, last, sizeof(p->name));
    80004da0:	4641                	li	a2,16
    80004da2:	be043583          	ld	a1,-1056(s0)
    80004da6:	bf843983          	ld	s3,-1032(s0)
    80004daa:	15898513          	addi	a0,s3,344
    80004dae:	90cfc0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    80004db2:	16898a13          	addi	s4,s3,360
    80004db6:	20000613          	li	a2,512
    80004dba:	85d2                	mv	a1,s4
    80004dbc:	c1840513          	addi	a0,s0,-1000
    80004dc0:	810fc0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    80004dc4:	86ce                	mv	a3,s3
    80004dc6:	0509b983          	ld	s3,80(s3)
  p->pagetable = pagetable;
    80004dca:	0576b823          	sd	s7,80(a3)
  p->sz = sz;
    80004dce:	0566b423          	sd	s6,72(a3)
  p->trapframe->epc = elf.entry;
    80004dd2:	6ebc                	ld	a5,88(a3)
    80004dd4:	e6843703          	ld	a4,-408(s0)
    80004dd8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    80004dda:	6ebc                	ld	a5,88(a3)
    80004ddc:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    80004de0:	20000613          	li	a2,512
    80004de4:	4581                	li	a1,0
    80004de6:	8552                	mv	a0,s4
    80004de8:	f8dfb0ef          	jal	ra,80000d74 <memset>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    80004dec:	c1840593          	addi	a1,s0,-1000
    80004df0:	854e                	mv	a0,s3
    80004df2:	e9bfc0ef          	jal	ra,80001c8c <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    80004df6:	85e6                	mv	a1,s9
    80004df8:	854e                	mv	a0,s3
    80004dfa:	eddfc0ef          	jal	ra,80001cd6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004dfe:	0004851b          	sext.w	a0,s1
    80004e02:	b321                	j	80004b0a <kexec+0x96>
  ip = 0;
    80004e04:	4a81                	li	s5,0
    80004e06:	bd41                	j	80004c96 <kexec+0x222>
    80004e08:	4a81                	li	s5,0
    80004e0a:	b571                	j	80004c96 <kexec+0x222>
    80004e0c:	4a81                	li	s5,0
    80004e0e:	b561                	j	80004c96 <kexec+0x222>

0000000080004e10 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004e10:	7179                	addi	sp,sp,-48
    80004e12:	f406                	sd	ra,40(sp)
    80004e14:	f022                	sd	s0,32(sp)
    80004e16:	ec26                	sd	s1,24(sp)
    80004e18:	e84a                	sd	s2,16(sp)
    80004e1a:	1800                	addi	s0,sp,48
    80004e1c:	892e                	mv	s2,a1
    80004e1e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004e20:	fdc40593          	addi	a1,s0,-36
    80004e24:	c85fd0ef          	jal	ra,80002aa8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004e28:	fdc42703          	lw	a4,-36(s0)
    80004e2c:	47bd                	li	a5,15
    80004e2e:	02e7e963          	bltu	a5,a4,80004e60 <argfd+0x50>
    80004e32:	cd1fc0ef          	jal	ra,80001b02 <myproc>
    80004e36:	fdc42703          	lw	a4,-36(s0)
    80004e3a:	01a70793          	addi	a5,a4,26
    80004e3e:	078e                	slli	a5,a5,0x3
    80004e40:	953e                	add	a0,a0,a5
    80004e42:	611c                	ld	a5,0(a0)
    80004e44:	c385                	beqz	a5,80004e64 <argfd+0x54>
    return -1;
  if(pfd)
    80004e46:	00090463          	beqz	s2,80004e4e <argfd+0x3e>
    *pfd = fd;
    80004e4a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004e4e:	4501                	li	a0,0
  if(pf)
    80004e50:	c091                	beqz	s1,80004e54 <argfd+0x44>
    *pf = f;
    80004e52:	e09c                	sd	a5,0(s1)
}
    80004e54:	70a2                	ld	ra,40(sp)
    80004e56:	7402                	ld	s0,32(sp)
    80004e58:	64e2                	ld	s1,24(sp)
    80004e5a:	6942                	ld	s2,16(sp)
    80004e5c:	6145                	addi	sp,sp,48
    80004e5e:	8082                	ret
    return -1;
    80004e60:	557d                	li	a0,-1
    80004e62:	bfcd                	j	80004e54 <argfd+0x44>
    80004e64:	557d                	li	a0,-1
    80004e66:	b7fd                	j	80004e54 <argfd+0x44>

0000000080004e68 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004e68:	1101                	addi	sp,sp,-32
    80004e6a:	ec06                	sd	ra,24(sp)
    80004e6c:	e822                	sd	s0,16(sp)
    80004e6e:	e426                	sd	s1,8(sp)
    80004e70:	1000                	addi	s0,sp,32
    80004e72:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004e74:	c8ffc0ef          	jal	ra,80001b02 <myproc>
    80004e78:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004e7a:	0d050793          	addi	a5,a0,208
    80004e7e:	4501                	li	a0,0
    80004e80:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004e82:	6398                	ld	a4,0(a5)
    80004e84:	cb19                	beqz	a4,80004e9a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004e86:	2505                	addiw	a0,a0,1
    80004e88:	07a1                	addi	a5,a5,8
    80004e8a:	fed51ce3          	bne	a0,a3,80004e82 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e8e:	557d                	li	a0,-1
}
    80004e90:	60e2                	ld	ra,24(sp)
    80004e92:	6442                	ld	s0,16(sp)
    80004e94:	64a2                	ld	s1,8(sp)
    80004e96:	6105                	addi	sp,sp,32
    80004e98:	8082                	ret
      p->ofile[fd] = f;
    80004e9a:	01a50793          	addi	a5,a0,26
    80004e9e:	078e                	slli	a5,a5,0x3
    80004ea0:	963e                	add	a2,a2,a5
    80004ea2:	e204                	sd	s1,0(a2)
      return fd;
    80004ea4:	b7f5                	j	80004e90 <fdalloc+0x28>

0000000080004ea6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ea6:	715d                	addi	sp,sp,-80
    80004ea8:	e486                	sd	ra,72(sp)
    80004eaa:	e0a2                	sd	s0,64(sp)
    80004eac:	fc26                	sd	s1,56(sp)
    80004eae:	f84a                	sd	s2,48(sp)
    80004eb0:	f44e                	sd	s3,40(sp)
    80004eb2:	f052                	sd	s4,32(sp)
    80004eb4:	ec56                	sd	s5,24(sp)
    80004eb6:	e85a                	sd	s6,16(sp)
    80004eb8:	0880                	addi	s0,sp,80
    80004eba:	8b2e                	mv	s6,a1
    80004ebc:	89b2                	mv	s3,a2
    80004ebe:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ec0:	fb040593          	addi	a1,s0,-80
    80004ec4:	820ff0ef          	jal	ra,80003ee4 <nameiparent>
    80004ec8:	84aa                	mv	s1,a0
    80004eca:	10050b63          	beqz	a0,80004fe0 <create+0x13a>
    return 0;

  ilock(dp);
    80004ece:	809fe0ef          	jal	ra,800036d6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ed2:	4601                	li	a2,0
    80004ed4:	fb040593          	addi	a1,s0,-80
    80004ed8:	8526                	mv	a0,s1
    80004eda:	d85fe0ef          	jal	ra,80003c5e <dirlookup>
    80004ede:	8aaa                	mv	s5,a0
    80004ee0:	c521                	beqz	a0,80004f28 <create+0x82>
    iunlockput(dp);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	9f9fe0ef          	jal	ra,800038dc <iunlockput>
    ilock(ip);
    80004ee8:	8556                	mv	a0,s5
    80004eea:	fecfe0ef          	jal	ra,800036d6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004eee:	000b059b          	sext.w	a1,s6
    80004ef2:	4789                	li	a5,2
    80004ef4:	02f59563          	bne	a1,a5,80004f1e <create+0x78>
    80004ef8:	044ad783          	lhu	a5,68(s5)
    80004efc:	37f9                	addiw	a5,a5,-2
    80004efe:	17c2                	slli	a5,a5,0x30
    80004f00:	93c1                	srli	a5,a5,0x30
    80004f02:	4705                	li	a4,1
    80004f04:	00f76d63          	bltu	a4,a5,80004f1e <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004f08:	8556                	mv	a0,s5
    80004f0a:	60a6                	ld	ra,72(sp)
    80004f0c:	6406                	ld	s0,64(sp)
    80004f0e:	74e2                	ld	s1,56(sp)
    80004f10:	7942                	ld	s2,48(sp)
    80004f12:	79a2                	ld	s3,40(sp)
    80004f14:	7a02                	ld	s4,32(sp)
    80004f16:	6ae2                	ld	s5,24(sp)
    80004f18:	6b42                	ld	s6,16(sp)
    80004f1a:	6161                	addi	sp,sp,80
    80004f1c:	8082                	ret
    iunlockput(ip);
    80004f1e:	8556                	mv	a0,s5
    80004f20:	9bdfe0ef          	jal	ra,800038dc <iunlockput>
    return 0;
    80004f24:	4a81                	li	s5,0
    80004f26:	b7cd                	j	80004f08 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004f28:	85da                	mv	a1,s6
    80004f2a:	4088                	lw	a0,0(s1)
    80004f2c:	e40fe0ef          	jal	ra,8000356c <ialloc>
    80004f30:	8a2a                	mv	s4,a0
    80004f32:	cd1d                	beqz	a0,80004f70 <create+0xca>
  ilock(ip);
    80004f34:	fa2fe0ef          	jal	ra,800036d6 <ilock>
  ip->major = major;
    80004f38:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004f3c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004f40:	4905                	li	s2,1
    80004f42:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004f46:	8552                	mv	a0,s4
    80004f48:	edafe0ef          	jal	ra,80003622 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004f4c:	000b059b          	sext.w	a1,s6
    80004f50:	03258563          	beq	a1,s2,80004f7a <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f54:	004a2603          	lw	a2,4(s4)
    80004f58:	fb040593          	addi	a1,s0,-80
    80004f5c:	8526                	mv	a0,s1
    80004f5e:	ed3fe0ef          	jal	ra,80003e30 <dirlink>
    80004f62:	06054363          	bltz	a0,80004fc8 <create+0x122>
  iunlockput(dp);
    80004f66:	8526                	mv	a0,s1
    80004f68:	975fe0ef          	jal	ra,800038dc <iunlockput>
  return ip;
    80004f6c:	8ad2                	mv	s5,s4
    80004f6e:	bf69                	j	80004f08 <create+0x62>
    iunlockput(dp);
    80004f70:	8526                	mv	a0,s1
    80004f72:	96bfe0ef          	jal	ra,800038dc <iunlockput>
    return 0;
    80004f76:	8ad2                	mv	s5,s4
    80004f78:	bf41                	j	80004f08 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f7a:	004a2603          	lw	a2,4(s4)
    80004f7e:	00002597          	auipc	a1,0x2
    80004f82:	76a58593          	addi	a1,a1,1898 # 800076e8 <syscalls+0x2f0>
    80004f86:	8552                	mv	a0,s4
    80004f88:	ea9fe0ef          	jal	ra,80003e30 <dirlink>
    80004f8c:	02054e63          	bltz	a0,80004fc8 <create+0x122>
    80004f90:	40d0                	lw	a2,4(s1)
    80004f92:	00002597          	auipc	a1,0x2
    80004f96:	75e58593          	addi	a1,a1,1886 # 800076f0 <syscalls+0x2f8>
    80004f9a:	8552                	mv	a0,s4
    80004f9c:	e95fe0ef          	jal	ra,80003e30 <dirlink>
    80004fa0:	02054463          	bltz	a0,80004fc8 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004fa4:	004a2603          	lw	a2,4(s4)
    80004fa8:	fb040593          	addi	a1,s0,-80
    80004fac:	8526                	mv	a0,s1
    80004fae:	e83fe0ef          	jal	ra,80003e30 <dirlink>
    80004fb2:	00054b63          	bltz	a0,80004fc8 <create+0x122>
    dp->nlink++;  // for ".."
    80004fb6:	04a4d783          	lhu	a5,74(s1)
    80004fba:	2785                	addiw	a5,a5,1
    80004fbc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fc0:	8526                	mv	a0,s1
    80004fc2:	e60fe0ef          	jal	ra,80003622 <iupdate>
    80004fc6:	b745                	j	80004f66 <create+0xc0>
  ip->nlink = 0;
    80004fc8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004fcc:	8552                	mv	a0,s4
    80004fce:	e54fe0ef          	jal	ra,80003622 <iupdate>
  iunlockput(ip);
    80004fd2:	8552                	mv	a0,s4
    80004fd4:	909fe0ef          	jal	ra,800038dc <iunlockput>
  iunlockput(dp);
    80004fd8:	8526                	mv	a0,s1
    80004fda:	903fe0ef          	jal	ra,800038dc <iunlockput>
  return 0;
    80004fde:	b72d                	j	80004f08 <create+0x62>
    return 0;
    80004fe0:	8aaa                	mv	s5,a0
    80004fe2:	b71d                	j	80004f08 <create+0x62>

0000000080004fe4 <sys_dup>:
{
    80004fe4:	7179                	addi	sp,sp,-48
    80004fe6:	f406                	sd	ra,40(sp)
    80004fe8:	f022                	sd	s0,32(sp)
    80004fea:	ec26                	sd	s1,24(sp)
    80004fec:	e84a                	sd	s2,16(sp)
    80004fee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ff0:	fd840613          	addi	a2,s0,-40
    80004ff4:	4581                	li	a1,0
    80004ff6:	4501                	li	a0,0
    80004ff8:	e19ff0ef          	jal	ra,80004e10 <argfd>
    return -1;
    80004ffc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004ffe:	00054f63          	bltz	a0,8000501c <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80005002:	fd843903          	ld	s2,-40(s0)
    80005006:	854a                	mv	a0,s2
    80005008:	e61ff0ef          	jal	ra,80004e68 <fdalloc>
    8000500c:	84aa                	mv	s1,a0
    return -1;
    8000500e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005010:	00054663          	bltz	a0,8000501c <sys_dup+0x38>
  filedup(f);
    80005014:	854a                	mv	a0,s2
    80005016:	c6cff0ef          	jal	ra,80004482 <filedup>
  return fd;
    8000501a:	87a6                	mv	a5,s1
}
    8000501c:	853e                	mv	a0,a5
    8000501e:	70a2                	ld	ra,40(sp)
    80005020:	7402                	ld	s0,32(sp)
    80005022:	64e2                	ld	s1,24(sp)
    80005024:	6942                	ld	s2,16(sp)
    80005026:	6145                	addi	sp,sp,48
    80005028:	8082                	ret

000000008000502a <sys_read>:
{
    8000502a:	7179                	addi	sp,sp,-48
    8000502c:	f406                	sd	ra,40(sp)
    8000502e:	f022                	sd	s0,32(sp)
    80005030:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005032:	fd840593          	addi	a1,s0,-40
    80005036:	4505                	li	a0,1
    80005038:	a8dfd0ef          	jal	ra,80002ac4 <argaddr>
  argint(2, &n);
    8000503c:	fe440593          	addi	a1,s0,-28
    80005040:	4509                	li	a0,2
    80005042:	a67fd0ef          	jal	ra,80002aa8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005046:	fe840613          	addi	a2,s0,-24
    8000504a:	4581                	li	a1,0
    8000504c:	4501                	li	a0,0
    8000504e:	dc3ff0ef          	jal	ra,80004e10 <argfd>
    80005052:	87aa                	mv	a5,a0
    return -1;
    80005054:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005056:	0007ca63          	bltz	a5,8000506a <sys_read+0x40>
  return fileread(f, p, n);
    8000505a:	fe442603          	lw	a2,-28(s0)
    8000505e:	fd843583          	ld	a1,-40(s0)
    80005062:	fe843503          	ld	a0,-24(s0)
    80005066:	d68ff0ef          	jal	ra,800045ce <fileread>
}
    8000506a:	70a2                	ld	ra,40(sp)
    8000506c:	7402                	ld	s0,32(sp)
    8000506e:	6145                	addi	sp,sp,48
    80005070:	8082                	ret

0000000080005072 <sys_write>:
{
    80005072:	7179                	addi	sp,sp,-48
    80005074:	f406                	sd	ra,40(sp)
    80005076:	f022                	sd	s0,32(sp)
    80005078:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000507a:	fd840593          	addi	a1,s0,-40
    8000507e:	4505                	li	a0,1
    80005080:	a45fd0ef          	jal	ra,80002ac4 <argaddr>
  argint(2, &n);
    80005084:	fe440593          	addi	a1,s0,-28
    80005088:	4509                	li	a0,2
    8000508a:	a1ffd0ef          	jal	ra,80002aa8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000508e:	fe840613          	addi	a2,s0,-24
    80005092:	4581                	li	a1,0
    80005094:	4501                	li	a0,0
    80005096:	d7bff0ef          	jal	ra,80004e10 <argfd>
    8000509a:	87aa                	mv	a5,a0
    return -1;
    8000509c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000509e:	0007ca63          	bltz	a5,800050b2 <sys_write+0x40>
  return filewrite(f, p, n);
    800050a2:	fe442603          	lw	a2,-28(s0)
    800050a6:	fd843583          	ld	a1,-40(s0)
    800050aa:	fe843503          	ld	a0,-24(s0)
    800050ae:	dceff0ef          	jal	ra,8000467c <filewrite>
}
    800050b2:	70a2                	ld	ra,40(sp)
    800050b4:	7402                	ld	s0,32(sp)
    800050b6:	6145                	addi	sp,sp,48
    800050b8:	8082                	ret

00000000800050ba <sys_close>:
{
    800050ba:	1101                	addi	sp,sp,-32
    800050bc:	ec06                	sd	ra,24(sp)
    800050be:	e822                	sd	s0,16(sp)
    800050c0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800050c2:	fe040613          	addi	a2,s0,-32
    800050c6:	fec40593          	addi	a1,s0,-20
    800050ca:	4501                	li	a0,0
    800050cc:	d45ff0ef          	jal	ra,80004e10 <argfd>
    return -1;
    800050d0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800050d2:	02054063          	bltz	a0,800050f2 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800050d6:	a2dfc0ef          	jal	ra,80001b02 <myproc>
    800050da:	fec42783          	lw	a5,-20(s0)
    800050de:	07e9                	addi	a5,a5,26
    800050e0:	078e                	slli	a5,a5,0x3
    800050e2:	953e                	add	a0,a0,a5
    800050e4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800050e8:	fe043503          	ld	a0,-32(s0)
    800050ec:	bdcff0ef          	jal	ra,800044c8 <fileclose>
  return 0;
    800050f0:	4781                	li	a5,0
}
    800050f2:	853e                	mv	a0,a5
    800050f4:	60e2                	ld	ra,24(sp)
    800050f6:	6442                	ld	s0,16(sp)
    800050f8:	6105                	addi	sp,sp,32
    800050fa:	8082                	ret

00000000800050fc <sys_fstat>:
{
    800050fc:	1101                	addi	sp,sp,-32
    800050fe:	ec06                	sd	ra,24(sp)
    80005100:	e822                	sd	s0,16(sp)
    80005102:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005104:	fe040593          	addi	a1,s0,-32
    80005108:	4505                	li	a0,1
    8000510a:	9bbfd0ef          	jal	ra,80002ac4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000510e:	fe840613          	addi	a2,s0,-24
    80005112:	4581                	li	a1,0
    80005114:	4501                	li	a0,0
    80005116:	cfbff0ef          	jal	ra,80004e10 <argfd>
    8000511a:	87aa                	mv	a5,a0
    return -1;
    8000511c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000511e:	0007c863          	bltz	a5,8000512e <sys_fstat+0x32>
  return filestat(f, st);
    80005122:	fe043583          	ld	a1,-32(s0)
    80005126:	fe843503          	ld	a0,-24(s0)
    8000512a:	c46ff0ef          	jal	ra,80004570 <filestat>
}
    8000512e:	60e2                	ld	ra,24(sp)
    80005130:	6442                	ld	s0,16(sp)
    80005132:	6105                	addi	sp,sp,32
    80005134:	8082                	ret

0000000080005136 <sys_link>:
{
    80005136:	7169                	addi	sp,sp,-304
    80005138:	f606                	sd	ra,296(sp)
    8000513a:	f222                	sd	s0,288(sp)
    8000513c:	ee26                	sd	s1,280(sp)
    8000513e:	ea4a                	sd	s2,272(sp)
    80005140:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005142:	08000613          	li	a2,128
    80005146:	ed040593          	addi	a1,s0,-304
    8000514a:	4501                	li	a0,0
    8000514c:	995fd0ef          	jal	ra,80002ae0 <argstr>
    return -1;
    80005150:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005152:	0c054663          	bltz	a0,8000521e <sys_link+0xe8>
    80005156:	08000613          	li	a2,128
    8000515a:	f5040593          	addi	a1,s0,-176
    8000515e:	4505                	li	a0,1
    80005160:	981fd0ef          	jal	ra,80002ae0 <argstr>
    return -1;
    80005164:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005166:	0a054c63          	bltz	a0,8000521e <sys_link+0xe8>
  begin_op();
    8000516a:	f55fe0ef          	jal	ra,800040be <begin_op>
  if((ip = namei(old)) == 0){
    8000516e:	ed040513          	addi	a0,s0,-304
    80005172:	d59fe0ef          	jal	ra,80003eca <namei>
    80005176:	84aa                	mv	s1,a0
    80005178:	c525                	beqz	a0,800051e0 <sys_link+0xaa>
  ilock(ip);
    8000517a:	d5cfe0ef          	jal	ra,800036d6 <ilock>
  if(ip->type == T_DIR){
    8000517e:	04449703          	lh	a4,68(s1)
    80005182:	4785                	li	a5,1
    80005184:	06f70263          	beq	a4,a5,800051e8 <sys_link+0xb2>
  ip->nlink++;
    80005188:	04a4d783          	lhu	a5,74(s1)
    8000518c:	2785                	addiw	a5,a5,1
    8000518e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005192:	8526                	mv	a0,s1
    80005194:	c8efe0ef          	jal	ra,80003622 <iupdate>
  iunlock(ip);
    80005198:	8526                	mv	a0,s1
    8000519a:	de6fe0ef          	jal	ra,80003780 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000519e:	fd040593          	addi	a1,s0,-48
    800051a2:	f5040513          	addi	a0,s0,-176
    800051a6:	d3ffe0ef          	jal	ra,80003ee4 <nameiparent>
    800051aa:	892a                	mv	s2,a0
    800051ac:	c921                	beqz	a0,800051fc <sys_link+0xc6>
  ilock(dp);
    800051ae:	d28fe0ef          	jal	ra,800036d6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800051b2:	00092703          	lw	a4,0(s2)
    800051b6:	409c                	lw	a5,0(s1)
    800051b8:	02f71f63          	bne	a4,a5,800051f6 <sys_link+0xc0>
    800051bc:	40d0                	lw	a2,4(s1)
    800051be:	fd040593          	addi	a1,s0,-48
    800051c2:	854a                	mv	a0,s2
    800051c4:	c6dfe0ef          	jal	ra,80003e30 <dirlink>
    800051c8:	02054763          	bltz	a0,800051f6 <sys_link+0xc0>
  iunlockput(dp);
    800051cc:	854a                	mv	a0,s2
    800051ce:	f0efe0ef          	jal	ra,800038dc <iunlockput>
  iput(ip);
    800051d2:	8526                	mv	a0,s1
    800051d4:	e80fe0ef          	jal	ra,80003854 <iput>
  end_op();
    800051d8:	f55fe0ef          	jal	ra,8000412c <end_op>
  return 0;
    800051dc:	4781                	li	a5,0
    800051de:	a081                	j	8000521e <sys_link+0xe8>
    end_op();
    800051e0:	f4dfe0ef          	jal	ra,8000412c <end_op>
    return -1;
    800051e4:	57fd                	li	a5,-1
    800051e6:	a825                	j	8000521e <sys_link+0xe8>
    iunlockput(ip);
    800051e8:	8526                	mv	a0,s1
    800051ea:	ef2fe0ef          	jal	ra,800038dc <iunlockput>
    end_op();
    800051ee:	f3ffe0ef          	jal	ra,8000412c <end_op>
    return -1;
    800051f2:	57fd                	li	a5,-1
    800051f4:	a02d                	j	8000521e <sys_link+0xe8>
    iunlockput(dp);
    800051f6:	854a                	mv	a0,s2
    800051f8:	ee4fe0ef          	jal	ra,800038dc <iunlockput>
  ilock(ip);
    800051fc:	8526                	mv	a0,s1
    800051fe:	cd8fe0ef          	jal	ra,800036d6 <ilock>
  ip->nlink--;
    80005202:	04a4d783          	lhu	a5,74(s1)
    80005206:	37fd                	addiw	a5,a5,-1
    80005208:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000520c:	8526                	mv	a0,s1
    8000520e:	c14fe0ef          	jal	ra,80003622 <iupdate>
  iunlockput(ip);
    80005212:	8526                	mv	a0,s1
    80005214:	ec8fe0ef          	jal	ra,800038dc <iunlockput>
  end_op();
    80005218:	f15fe0ef          	jal	ra,8000412c <end_op>
  return -1;
    8000521c:	57fd                	li	a5,-1
}
    8000521e:	853e                	mv	a0,a5
    80005220:	70b2                	ld	ra,296(sp)
    80005222:	7412                	ld	s0,288(sp)
    80005224:	64f2                	ld	s1,280(sp)
    80005226:	6952                	ld	s2,272(sp)
    80005228:	6155                	addi	sp,sp,304
    8000522a:	8082                	ret

000000008000522c <sys_unlink>:
{
    8000522c:	7151                	addi	sp,sp,-240
    8000522e:	f586                	sd	ra,232(sp)
    80005230:	f1a2                	sd	s0,224(sp)
    80005232:	eda6                	sd	s1,216(sp)
    80005234:	e9ca                	sd	s2,208(sp)
    80005236:	e5ce                	sd	s3,200(sp)
    80005238:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000523a:	08000613          	li	a2,128
    8000523e:	f3040593          	addi	a1,s0,-208
    80005242:	4501                	li	a0,0
    80005244:	89dfd0ef          	jal	ra,80002ae0 <argstr>
    80005248:	12054b63          	bltz	a0,8000537e <sys_unlink+0x152>
  begin_op();
    8000524c:	e73fe0ef          	jal	ra,800040be <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005250:	fb040593          	addi	a1,s0,-80
    80005254:	f3040513          	addi	a0,s0,-208
    80005258:	c8dfe0ef          	jal	ra,80003ee4 <nameiparent>
    8000525c:	84aa                	mv	s1,a0
    8000525e:	c54d                	beqz	a0,80005308 <sys_unlink+0xdc>
  ilock(dp);
    80005260:	c76fe0ef          	jal	ra,800036d6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005264:	00002597          	auipc	a1,0x2
    80005268:	48458593          	addi	a1,a1,1156 # 800076e8 <syscalls+0x2f0>
    8000526c:	fb040513          	addi	a0,s0,-80
    80005270:	9d9fe0ef          	jal	ra,80003c48 <namecmp>
    80005274:	10050a63          	beqz	a0,80005388 <sys_unlink+0x15c>
    80005278:	00002597          	auipc	a1,0x2
    8000527c:	47858593          	addi	a1,a1,1144 # 800076f0 <syscalls+0x2f8>
    80005280:	fb040513          	addi	a0,s0,-80
    80005284:	9c5fe0ef          	jal	ra,80003c48 <namecmp>
    80005288:	10050063          	beqz	a0,80005388 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000528c:	f2c40613          	addi	a2,s0,-212
    80005290:	fb040593          	addi	a1,s0,-80
    80005294:	8526                	mv	a0,s1
    80005296:	9c9fe0ef          	jal	ra,80003c5e <dirlookup>
    8000529a:	892a                	mv	s2,a0
    8000529c:	0e050663          	beqz	a0,80005388 <sys_unlink+0x15c>
  ilock(ip);
    800052a0:	c36fe0ef          	jal	ra,800036d6 <ilock>
  if(ip->nlink < 1)
    800052a4:	04a91783          	lh	a5,74(s2)
    800052a8:	06f05463          	blez	a5,80005310 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800052ac:	04491703          	lh	a4,68(s2)
    800052b0:	4785                	li	a5,1
    800052b2:	06f70563          	beq	a4,a5,8000531c <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800052b6:	4641                	li	a2,16
    800052b8:	4581                	li	a1,0
    800052ba:	fc040513          	addi	a0,s0,-64
    800052be:	ab7fb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052c2:	4741                	li	a4,16
    800052c4:	f2c42683          	lw	a3,-212(s0)
    800052c8:	fc040613          	addi	a2,s0,-64
    800052cc:	4581                	li	a1,0
    800052ce:	8526                	mv	a0,s1
    800052d0:	877fe0ef          	jal	ra,80003b46 <writei>
    800052d4:	47c1                	li	a5,16
    800052d6:	08f51563          	bne	a0,a5,80005360 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800052da:	04491703          	lh	a4,68(s2)
    800052de:	4785                	li	a5,1
    800052e0:	08f70663          	beq	a4,a5,8000536c <sys_unlink+0x140>
  iunlockput(dp);
    800052e4:	8526                	mv	a0,s1
    800052e6:	df6fe0ef          	jal	ra,800038dc <iunlockput>
  ip->nlink--;
    800052ea:	04a95783          	lhu	a5,74(s2)
    800052ee:	37fd                	addiw	a5,a5,-1
    800052f0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800052f4:	854a                	mv	a0,s2
    800052f6:	b2cfe0ef          	jal	ra,80003622 <iupdate>
  iunlockput(ip);
    800052fa:	854a                	mv	a0,s2
    800052fc:	de0fe0ef          	jal	ra,800038dc <iunlockput>
  end_op();
    80005300:	e2dfe0ef          	jal	ra,8000412c <end_op>
  return 0;
    80005304:	4501                	li	a0,0
    80005306:	a079                	j	80005394 <sys_unlink+0x168>
    end_op();
    80005308:	e25fe0ef          	jal	ra,8000412c <end_op>
    return -1;
    8000530c:	557d                	li	a0,-1
    8000530e:	a059                	j	80005394 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005310:	00002517          	auipc	a0,0x2
    80005314:	3e850513          	addi	a0,a0,1000 # 800076f8 <syscalls+0x300>
    80005318:	c70fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000531c:	04c92703          	lw	a4,76(s2)
    80005320:	02000793          	li	a5,32
    80005324:	f8e7f9e3          	bgeu	a5,a4,800052b6 <sys_unlink+0x8a>
    80005328:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000532c:	4741                	li	a4,16
    8000532e:	86ce                	mv	a3,s3
    80005330:	f1840613          	addi	a2,s0,-232
    80005334:	4581                	li	a1,0
    80005336:	854a                	mv	a0,s2
    80005338:	f2afe0ef          	jal	ra,80003a62 <readi>
    8000533c:	47c1                	li	a5,16
    8000533e:	00f51b63          	bne	a0,a5,80005354 <sys_unlink+0x128>
    if(de.inum != 0)
    80005342:	f1845783          	lhu	a5,-232(s0)
    80005346:	ef95                	bnez	a5,80005382 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005348:	29c1                	addiw	s3,s3,16
    8000534a:	04c92783          	lw	a5,76(s2)
    8000534e:	fcf9efe3          	bltu	s3,a5,8000532c <sys_unlink+0x100>
    80005352:	b795                	j	800052b6 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005354:	00002517          	auipc	a0,0x2
    80005358:	3bc50513          	addi	a0,a0,956 # 80007710 <syscalls+0x318>
    8000535c:	c2cfb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80005360:	00002517          	auipc	a0,0x2
    80005364:	3c850513          	addi	a0,a0,968 # 80007728 <syscalls+0x330>
    80005368:	c20fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    8000536c:	04a4d783          	lhu	a5,74(s1)
    80005370:	37fd                	addiw	a5,a5,-1
    80005372:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005376:	8526                	mv	a0,s1
    80005378:	aaafe0ef          	jal	ra,80003622 <iupdate>
    8000537c:	b7a5                	j	800052e4 <sys_unlink+0xb8>
    return -1;
    8000537e:	557d                	li	a0,-1
    80005380:	a811                	j	80005394 <sys_unlink+0x168>
    iunlockput(ip);
    80005382:	854a                	mv	a0,s2
    80005384:	d58fe0ef          	jal	ra,800038dc <iunlockput>
  iunlockput(dp);
    80005388:	8526                	mv	a0,s1
    8000538a:	d52fe0ef          	jal	ra,800038dc <iunlockput>
  end_op();
    8000538e:	d9ffe0ef          	jal	ra,8000412c <end_op>
  return -1;
    80005392:	557d                	li	a0,-1
}
    80005394:	70ae                	ld	ra,232(sp)
    80005396:	740e                	ld	s0,224(sp)
    80005398:	64ee                	ld	s1,216(sp)
    8000539a:	694e                	ld	s2,208(sp)
    8000539c:	69ae                	ld	s3,200(sp)
    8000539e:	616d                	addi	sp,sp,240
    800053a0:	8082                	ret

00000000800053a2 <sys_open>:

uint64
sys_open(void)
{
    800053a2:	7131                	addi	sp,sp,-192
    800053a4:	fd06                	sd	ra,184(sp)
    800053a6:	f922                	sd	s0,176(sp)
    800053a8:	f526                	sd	s1,168(sp)
    800053aa:	f14a                	sd	s2,160(sp)
    800053ac:	ed4e                	sd	s3,152(sp)
    800053ae:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800053b0:	f4c40593          	addi	a1,s0,-180
    800053b4:	4505                	li	a0,1
    800053b6:	ef2fd0ef          	jal	ra,80002aa8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800053ba:	08000613          	li	a2,128
    800053be:	f5040593          	addi	a1,s0,-176
    800053c2:	4501                	li	a0,0
    800053c4:	f1cfd0ef          	jal	ra,80002ae0 <argstr>
    800053c8:	87aa                	mv	a5,a0
    return -1;
    800053ca:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800053cc:	0807cd63          	bltz	a5,80005466 <sys_open+0xc4>

  begin_op();
    800053d0:	ceffe0ef          	jal	ra,800040be <begin_op>

  if(omode & O_CREATE){
    800053d4:	f4c42783          	lw	a5,-180(s0)
    800053d8:	2007f793          	andi	a5,a5,512
    800053dc:	c3c5                	beqz	a5,8000547c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800053de:	4681                	li	a3,0
    800053e0:	4601                	li	a2,0
    800053e2:	4589                	li	a1,2
    800053e4:	f5040513          	addi	a0,s0,-176
    800053e8:	abfff0ef          	jal	ra,80004ea6 <create>
    800053ec:	84aa                	mv	s1,a0
    if(ip == 0){
    800053ee:	c159                	beqz	a0,80005474 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800053f0:	04449703          	lh	a4,68(s1)
    800053f4:	478d                	li	a5,3
    800053f6:	00f71763          	bne	a4,a5,80005404 <sys_open+0x62>
    800053fa:	0464d703          	lhu	a4,70(s1)
    800053fe:	47a5                	li	a5,9
    80005400:	0ae7e963          	bltu	a5,a4,800054b2 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005404:	820ff0ef          	jal	ra,80004424 <filealloc>
    80005408:	89aa                	mv	s3,a0
    8000540a:	0c050963          	beqz	a0,800054dc <sys_open+0x13a>
    8000540e:	a5bff0ef          	jal	ra,80004e68 <fdalloc>
    80005412:	892a                	mv	s2,a0
    80005414:	0c054163          	bltz	a0,800054d6 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005418:	04449703          	lh	a4,68(s1)
    8000541c:	478d                	li	a5,3
    8000541e:	0af70163          	beq	a4,a5,800054c0 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005422:	4789                	li	a5,2
    80005424:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005428:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000542c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005430:	f4c42783          	lw	a5,-180(s0)
    80005434:	0017c713          	xori	a4,a5,1
    80005438:	8b05                	andi	a4,a4,1
    8000543a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000543e:	0037f713          	andi	a4,a5,3
    80005442:	00e03733          	snez	a4,a4
    80005446:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000544a:	4007f793          	andi	a5,a5,1024
    8000544e:	c791                	beqz	a5,8000545a <sys_open+0xb8>
    80005450:	04449703          	lh	a4,68(s1)
    80005454:	4789                	li	a5,2
    80005456:	06f70c63          	beq	a4,a5,800054ce <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000545a:	8526                	mv	a0,s1
    8000545c:	b24fe0ef          	jal	ra,80003780 <iunlock>
  end_op();
    80005460:	ccdfe0ef          	jal	ra,8000412c <end_op>

  return fd;
    80005464:	854a                	mv	a0,s2
}
    80005466:	70ea                	ld	ra,184(sp)
    80005468:	744a                	ld	s0,176(sp)
    8000546a:	74aa                	ld	s1,168(sp)
    8000546c:	790a                	ld	s2,160(sp)
    8000546e:	69ea                	ld	s3,152(sp)
    80005470:	6129                	addi	sp,sp,192
    80005472:	8082                	ret
      end_op();
    80005474:	cb9fe0ef          	jal	ra,8000412c <end_op>
      return -1;
    80005478:	557d                	li	a0,-1
    8000547a:	b7f5                	j	80005466 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    8000547c:	f5040513          	addi	a0,s0,-176
    80005480:	a4bfe0ef          	jal	ra,80003eca <namei>
    80005484:	84aa                	mv	s1,a0
    80005486:	c115                	beqz	a0,800054aa <sys_open+0x108>
    ilock(ip);
    80005488:	a4efe0ef          	jal	ra,800036d6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000548c:	04449703          	lh	a4,68(s1)
    80005490:	4785                	li	a5,1
    80005492:	f4f71fe3          	bne	a4,a5,800053f0 <sys_open+0x4e>
    80005496:	f4c42783          	lw	a5,-180(s0)
    8000549a:	d7ad                	beqz	a5,80005404 <sys_open+0x62>
      iunlockput(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	c3efe0ef          	jal	ra,800038dc <iunlockput>
      end_op();
    800054a2:	c8bfe0ef          	jal	ra,8000412c <end_op>
      return -1;
    800054a6:	557d                	li	a0,-1
    800054a8:	bf7d                	j	80005466 <sys_open+0xc4>
      end_op();
    800054aa:	c83fe0ef          	jal	ra,8000412c <end_op>
      return -1;
    800054ae:	557d                	li	a0,-1
    800054b0:	bf5d                	j	80005466 <sys_open+0xc4>
    iunlockput(ip);
    800054b2:	8526                	mv	a0,s1
    800054b4:	c28fe0ef          	jal	ra,800038dc <iunlockput>
    end_op();
    800054b8:	c75fe0ef          	jal	ra,8000412c <end_op>
    return -1;
    800054bc:	557d                	li	a0,-1
    800054be:	b765                	j	80005466 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800054c0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800054c4:	04649783          	lh	a5,70(s1)
    800054c8:	02f99223          	sh	a5,36(s3)
    800054cc:	b785                	j	8000542c <sys_open+0x8a>
    itrunc(ip);
    800054ce:	8526                	mv	a0,s1
    800054d0:	af0fe0ef          	jal	ra,800037c0 <itrunc>
    800054d4:	b759                	j	8000545a <sys_open+0xb8>
      fileclose(f);
    800054d6:	854e                	mv	a0,s3
    800054d8:	ff1fe0ef          	jal	ra,800044c8 <fileclose>
    iunlockput(ip);
    800054dc:	8526                	mv	a0,s1
    800054de:	bfefe0ef          	jal	ra,800038dc <iunlockput>
    end_op();
    800054e2:	c4bfe0ef          	jal	ra,8000412c <end_op>
    return -1;
    800054e6:	557d                	li	a0,-1
    800054e8:	bfbd                	j	80005466 <sys_open+0xc4>

00000000800054ea <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800054ea:	7175                	addi	sp,sp,-144
    800054ec:	e506                	sd	ra,136(sp)
    800054ee:	e122                	sd	s0,128(sp)
    800054f0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800054f2:	bcdfe0ef          	jal	ra,800040be <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800054f6:	08000613          	li	a2,128
    800054fa:	f7040593          	addi	a1,s0,-144
    800054fe:	4501                	li	a0,0
    80005500:	de0fd0ef          	jal	ra,80002ae0 <argstr>
    80005504:	02054363          	bltz	a0,8000552a <sys_mkdir+0x40>
    80005508:	4681                	li	a3,0
    8000550a:	4601                	li	a2,0
    8000550c:	4585                	li	a1,1
    8000550e:	f7040513          	addi	a0,s0,-144
    80005512:	995ff0ef          	jal	ra,80004ea6 <create>
    80005516:	c911                	beqz	a0,8000552a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005518:	bc4fe0ef          	jal	ra,800038dc <iunlockput>
  end_op();
    8000551c:	c11fe0ef          	jal	ra,8000412c <end_op>
  return 0;
    80005520:	4501                	li	a0,0
}
    80005522:	60aa                	ld	ra,136(sp)
    80005524:	640a                	ld	s0,128(sp)
    80005526:	6149                	addi	sp,sp,144
    80005528:	8082                	ret
    end_op();
    8000552a:	c03fe0ef          	jal	ra,8000412c <end_op>
    return -1;
    8000552e:	557d                	li	a0,-1
    80005530:	bfcd                	j	80005522 <sys_mkdir+0x38>

0000000080005532 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005532:	7135                	addi	sp,sp,-160
    80005534:	ed06                	sd	ra,152(sp)
    80005536:	e922                	sd	s0,144(sp)
    80005538:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000553a:	b85fe0ef          	jal	ra,800040be <begin_op>
  argint(1, &major);
    8000553e:	f6c40593          	addi	a1,s0,-148
    80005542:	4505                	li	a0,1
    80005544:	d64fd0ef          	jal	ra,80002aa8 <argint>
  argint(2, &minor);
    80005548:	f6840593          	addi	a1,s0,-152
    8000554c:	4509                	li	a0,2
    8000554e:	d5afd0ef          	jal	ra,80002aa8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005552:	08000613          	li	a2,128
    80005556:	f7040593          	addi	a1,s0,-144
    8000555a:	4501                	li	a0,0
    8000555c:	d84fd0ef          	jal	ra,80002ae0 <argstr>
    80005560:	02054563          	bltz	a0,8000558a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005564:	f6841683          	lh	a3,-152(s0)
    80005568:	f6c41603          	lh	a2,-148(s0)
    8000556c:	458d                	li	a1,3
    8000556e:	f7040513          	addi	a0,s0,-144
    80005572:	935ff0ef          	jal	ra,80004ea6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005576:	c911                	beqz	a0,8000558a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005578:	b64fe0ef          	jal	ra,800038dc <iunlockput>
  end_op();
    8000557c:	bb1fe0ef          	jal	ra,8000412c <end_op>
  return 0;
    80005580:	4501                	li	a0,0
}
    80005582:	60ea                	ld	ra,152(sp)
    80005584:	644a                	ld	s0,144(sp)
    80005586:	610d                	addi	sp,sp,160
    80005588:	8082                	ret
    end_op();
    8000558a:	ba3fe0ef          	jal	ra,8000412c <end_op>
    return -1;
    8000558e:	557d                	li	a0,-1
    80005590:	bfcd                	j	80005582 <sys_mknod+0x50>

0000000080005592 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005592:	7135                	addi	sp,sp,-160
    80005594:	ed06                	sd	ra,152(sp)
    80005596:	e922                	sd	s0,144(sp)
    80005598:	e526                	sd	s1,136(sp)
    8000559a:	e14a                	sd	s2,128(sp)
    8000559c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000559e:	d64fc0ef          	jal	ra,80001b02 <myproc>
    800055a2:	892a                	mv	s2,a0
  
  begin_op();
    800055a4:	b1bfe0ef          	jal	ra,800040be <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800055a8:	08000613          	li	a2,128
    800055ac:	f6040593          	addi	a1,s0,-160
    800055b0:	4501                	li	a0,0
    800055b2:	d2efd0ef          	jal	ra,80002ae0 <argstr>
    800055b6:	04054163          	bltz	a0,800055f8 <sys_chdir+0x66>
    800055ba:	f6040513          	addi	a0,s0,-160
    800055be:	90dfe0ef          	jal	ra,80003eca <namei>
    800055c2:	84aa                	mv	s1,a0
    800055c4:	c915                	beqz	a0,800055f8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800055c6:	910fe0ef          	jal	ra,800036d6 <ilock>
  if(ip->type != T_DIR){
    800055ca:	04449703          	lh	a4,68(s1)
    800055ce:	4785                	li	a5,1
    800055d0:	02f71863          	bne	a4,a5,80005600 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800055d4:	8526                	mv	a0,s1
    800055d6:	9aafe0ef          	jal	ra,80003780 <iunlock>
  iput(p->cwd);
    800055da:	15093503          	ld	a0,336(s2)
    800055de:	a76fe0ef          	jal	ra,80003854 <iput>
  end_op();
    800055e2:	b4bfe0ef          	jal	ra,8000412c <end_op>
  p->cwd = ip;
    800055e6:	14993823          	sd	s1,336(s2)
  return 0;
    800055ea:	4501                	li	a0,0
}
    800055ec:	60ea                	ld	ra,152(sp)
    800055ee:	644a                	ld	s0,144(sp)
    800055f0:	64aa                	ld	s1,136(sp)
    800055f2:	690a                	ld	s2,128(sp)
    800055f4:	610d                	addi	sp,sp,160
    800055f6:	8082                	ret
    end_op();
    800055f8:	b35fe0ef          	jal	ra,8000412c <end_op>
    return -1;
    800055fc:	557d                	li	a0,-1
    800055fe:	b7fd                	j	800055ec <sys_chdir+0x5a>
    iunlockput(ip);
    80005600:	8526                	mv	a0,s1
    80005602:	adafe0ef          	jal	ra,800038dc <iunlockput>
    end_op();
    80005606:	b27fe0ef          	jal	ra,8000412c <end_op>
    return -1;
    8000560a:	557d                	li	a0,-1
    8000560c:	b7c5                	j	800055ec <sys_chdir+0x5a>

000000008000560e <sys_exec>:

uint64
sys_exec(void)
{
    8000560e:	7145                	addi	sp,sp,-464
    80005610:	e786                	sd	ra,456(sp)
    80005612:	e3a2                	sd	s0,448(sp)
    80005614:	ff26                	sd	s1,440(sp)
    80005616:	fb4a                	sd	s2,432(sp)
    80005618:	f74e                	sd	s3,424(sp)
    8000561a:	f352                	sd	s4,416(sp)
    8000561c:	ef56                	sd	s5,408(sp)
    8000561e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005620:	e3840593          	addi	a1,s0,-456
    80005624:	4505                	li	a0,1
    80005626:	c9efd0ef          	jal	ra,80002ac4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000562a:	08000613          	li	a2,128
    8000562e:	f4040593          	addi	a1,s0,-192
    80005632:	4501                	li	a0,0
    80005634:	cacfd0ef          	jal	ra,80002ae0 <argstr>
    80005638:	87aa                	mv	a5,a0
    return -1;
    8000563a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000563c:	0a07c563          	bltz	a5,800056e6 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005640:	10000613          	li	a2,256
    80005644:	4581                	li	a1,0
    80005646:	e4040513          	addi	a0,s0,-448
    8000564a:	f2afb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000564e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005652:	89a6                	mv	s3,s1
    80005654:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005656:	02000a13          	li	s4,32
    8000565a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000565e:	00391513          	slli	a0,s2,0x3
    80005662:	e3040593          	addi	a1,s0,-464
    80005666:	e3843783          	ld	a5,-456(s0)
    8000566a:	953e                	add	a0,a0,a5
    8000566c:	bb2fd0ef          	jal	ra,80002a1e <fetchaddr>
    80005670:	02054663          	bltz	a0,8000569c <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005674:	e3043783          	ld	a5,-464(s0)
    80005678:	cf8d                	beqz	a5,800056b2 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000567a:	d30fb0ef          	jal	ra,80000baa <kalloc>
    8000567e:	85aa                	mv	a1,a0
    80005680:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005684:	cd01                	beqz	a0,8000569c <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005686:	6605                	lui	a2,0x1
    80005688:	e3043503          	ld	a0,-464(s0)
    8000568c:	bdcfd0ef          	jal	ra,80002a68 <fetchstr>
    80005690:	00054663          	bltz	a0,8000569c <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005694:	0905                	addi	s2,s2,1
    80005696:	09a1                	addi	s3,s3,8
    80005698:	fd4911e3          	bne	s2,s4,8000565a <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000569c:	f4040913          	addi	s2,s0,-192
    800056a0:	6088                	ld	a0,0(s1)
    800056a2:	c129                	beqz	a0,800056e4 <sys_exec+0xd6>
    kfree(argv[i]);
    800056a4:	bd6fb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056a8:	04a1                	addi	s1,s1,8
    800056aa:	ff249be3          	bne	s1,s2,800056a0 <sys_exec+0x92>
  return -1;
    800056ae:	557d                	li	a0,-1
    800056b0:	a81d                	j	800056e6 <sys_exec+0xd8>
      argv[i] = 0;
    800056b2:	0a8e                	slli	s5,s5,0x3
    800056b4:	fc0a8793          	addi	a5,s5,-64
    800056b8:	00878ab3          	add	s5,a5,s0
    800056bc:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    800056c0:	e4040593          	addi	a1,s0,-448
    800056c4:	f4040513          	addi	a0,s0,-192
    800056c8:	bacff0ef          	jal	ra,80004a74 <kexec>
    800056cc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056ce:	f4040993          	addi	s3,s0,-192
    800056d2:	6088                	ld	a0,0(s1)
    800056d4:	c511                	beqz	a0,800056e0 <sys_exec+0xd2>
    kfree(argv[i]);
    800056d6:	ba4fb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056da:	04a1                	addi	s1,s1,8
    800056dc:	ff349be3          	bne	s1,s3,800056d2 <sys_exec+0xc4>
  return ret;
    800056e0:	854a                	mv	a0,s2
    800056e2:	a011                	j	800056e6 <sys_exec+0xd8>
  return -1;
    800056e4:	557d                	li	a0,-1
}
    800056e6:	60be                	ld	ra,456(sp)
    800056e8:	641e                	ld	s0,448(sp)
    800056ea:	74fa                	ld	s1,440(sp)
    800056ec:	795a                	ld	s2,432(sp)
    800056ee:	79ba                	ld	s3,424(sp)
    800056f0:	7a1a                	ld	s4,416(sp)
    800056f2:	6afa                	ld	s5,408(sp)
    800056f4:	6179                	addi	sp,sp,464
    800056f6:	8082                	ret

00000000800056f8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800056f8:	7139                	addi	sp,sp,-64
    800056fa:	fc06                	sd	ra,56(sp)
    800056fc:	f822                	sd	s0,48(sp)
    800056fe:	f426                	sd	s1,40(sp)
    80005700:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005702:	c00fc0ef          	jal	ra,80001b02 <myproc>
    80005706:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005708:	fd840593          	addi	a1,s0,-40
    8000570c:	4501                	li	a0,0
    8000570e:	bb6fd0ef          	jal	ra,80002ac4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005712:	fc840593          	addi	a1,s0,-56
    80005716:	fd040513          	addi	a0,s0,-48
    8000571a:	87aff0ef          	jal	ra,80004794 <pipealloc>
    return -1;
    8000571e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005720:	0a054463          	bltz	a0,800057c8 <sys_pipe+0xd0>
  fd0 = -1;
    80005724:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005728:	fd043503          	ld	a0,-48(s0)
    8000572c:	f3cff0ef          	jal	ra,80004e68 <fdalloc>
    80005730:	fca42223          	sw	a0,-60(s0)
    80005734:	08054163          	bltz	a0,800057b6 <sys_pipe+0xbe>
    80005738:	fc843503          	ld	a0,-56(s0)
    8000573c:	f2cff0ef          	jal	ra,80004e68 <fdalloc>
    80005740:	fca42023          	sw	a0,-64(s0)
    80005744:	06054063          	bltz	a0,800057a4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005748:	4691                	li	a3,4
    8000574a:	fc440613          	addi	a2,s0,-60
    8000574e:	fd843583          	ld	a1,-40(s0)
    80005752:	68a8                	ld	a0,80(s1)
    80005754:	80afc0ef          	jal	ra,8000175e <copyout>
    80005758:	00054e63          	bltz	a0,80005774 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000575c:	4691                	li	a3,4
    8000575e:	fc040613          	addi	a2,s0,-64
    80005762:	fd843583          	ld	a1,-40(s0)
    80005766:	0591                	addi	a1,a1,4
    80005768:	68a8                	ld	a0,80(s1)
    8000576a:	ff5fb0ef          	jal	ra,8000175e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000576e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005770:	04055c63          	bgez	a0,800057c8 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005774:	fc442783          	lw	a5,-60(s0)
    80005778:	07e9                	addi	a5,a5,26
    8000577a:	078e                	slli	a5,a5,0x3
    8000577c:	97a6                	add	a5,a5,s1
    8000577e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005782:	fc042783          	lw	a5,-64(s0)
    80005786:	07e9                	addi	a5,a5,26
    80005788:	078e                	slli	a5,a5,0x3
    8000578a:	94be                	add	s1,s1,a5
    8000578c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005790:	fd043503          	ld	a0,-48(s0)
    80005794:	d35fe0ef          	jal	ra,800044c8 <fileclose>
    fileclose(wf);
    80005798:	fc843503          	ld	a0,-56(s0)
    8000579c:	d2dfe0ef          	jal	ra,800044c8 <fileclose>
    return -1;
    800057a0:	57fd                	li	a5,-1
    800057a2:	a01d                	j	800057c8 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800057a4:	fc442783          	lw	a5,-60(s0)
    800057a8:	0007c763          	bltz	a5,800057b6 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800057ac:	07e9                	addi	a5,a5,26
    800057ae:	078e                	slli	a5,a5,0x3
    800057b0:	97a6                	add	a5,a5,s1
    800057b2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800057b6:	fd043503          	ld	a0,-48(s0)
    800057ba:	d0ffe0ef          	jal	ra,800044c8 <fileclose>
    fileclose(wf);
    800057be:	fc843503          	ld	a0,-56(s0)
    800057c2:	d07fe0ef          	jal	ra,800044c8 <fileclose>
    return -1;
    800057c6:	57fd                	li	a5,-1
}
    800057c8:	853e                	mv	a0,a5
    800057ca:	70e2                	ld	ra,56(sp)
    800057cc:	7442                	ld	s0,48(sp)
    800057ce:	74a2                	ld	s1,40(sp)
    800057d0:	6121                	addi	sp,sp,64
    800057d2:	8082                	ret
	...

00000000800057e0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057e0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057e2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057e4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800057e6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800057e8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057ea:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057ec:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057ee:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057f0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057f2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057f4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057f6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057f8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057fa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057fc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057fe:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005800:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005802:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005804:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005806:	928fd0ef          	jal	ra,8000292e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000580a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000580c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000580e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005810:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005812:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005814:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005816:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005818:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000581a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000581c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000581e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005820:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005822:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005824:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005826:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005828:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000582a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000582c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000582e:	10200073          	sret
	...

000000008000583e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000583e:	1141                	addi	sp,sp,-16
    80005840:	e422                	sd	s0,8(sp)
    80005842:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005844:	0c0007b7          	lui	a5,0xc000
    80005848:	4705                	li	a4,1
    8000584a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000584c:	c3d8                	sw	a4,4(a5)
}
    8000584e:	6422                	ld	s0,8(sp)
    80005850:	0141                	addi	sp,sp,16
    80005852:	8082                	ret

0000000080005854 <plicinithart>:

void
plicinithart(void)
{
    80005854:	1141                	addi	sp,sp,-16
    80005856:	e406                	sd	ra,8(sp)
    80005858:	e022                	sd	s0,0(sp)
    8000585a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000585c:	a7afc0ef          	jal	ra,80001ad6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005860:	0085171b          	slliw	a4,a0,0x8
    80005864:	0c0027b7          	lui	a5,0xc002
    80005868:	97ba                	add	a5,a5,a4
    8000586a:	40200713          	li	a4,1026
    8000586e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005872:	00d5151b          	slliw	a0,a0,0xd
    80005876:	0c2017b7          	lui	a5,0xc201
    8000587a:	97aa                	add	a5,a5,a0
    8000587c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005880:	60a2                	ld	ra,8(sp)
    80005882:	6402                	ld	s0,0(sp)
    80005884:	0141                	addi	sp,sp,16
    80005886:	8082                	ret

0000000080005888 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005888:	1141                	addi	sp,sp,-16
    8000588a:	e406                	sd	ra,8(sp)
    8000588c:	e022                	sd	s0,0(sp)
    8000588e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005890:	a46fc0ef          	jal	ra,80001ad6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005894:	00d5151b          	slliw	a0,a0,0xd
    80005898:	0c2017b7          	lui	a5,0xc201
    8000589c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000589e:	43c8                	lw	a0,4(a5)
    800058a0:	60a2                	ld	ra,8(sp)
    800058a2:	6402                	ld	s0,0(sp)
    800058a4:	0141                	addi	sp,sp,16
    800058a6:	8082                	ret

00000000800058a8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800058a8:	1101                	addi	sp,sp,-32
    800058aa:	ec06                	sd	ra,24(sp)
    800058ac:	e822                	sd	s0,16(sp)
    800058ae:	e426                	sd	s1,8(sp)
    800058b0:	1000                	addi	s0,sp,32
    800058b2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800058b4:	a22fc0ef          	jal	ra,80001ad6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800058b8:	00d5151b          	slliw	a0,a0,0xd
    800058bc:	0c2017b7          	lui	a5,0xc201
    800058c0:	97aa                	add	a5,a5,a0
    800058c2:	c3c4                	sw	s1,4(a5)
}
    800058c4:	60e2                	ld	ra,24(sp)
    800058c6:	6442                	ld	s0,16(sp)
    800058c8:	64a2                	ld	s1,8(sp)
    800058ca:	6105                	addi	sp,sp,32
    800058cc:	8082                	ret

00000000800058ce <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058ce:	1141                	addi	sp,sp,-16
    800058d0:	e406                	sd	ra,8(sp)
    800058d2:	e022                	sd	s0,0(sp)
    800058d4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800058d6:	479d                	li	a5,7
    800058d8:	04a7ca63          	blt	a5,a0,8000592c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800058dc:	00243797          	auipc	a5,0x243
    800058e0:	1a478793          	addi	a5,a5,420 # 80248a80 <disk>
    800058e4:	97aa                	add	a5,a5,a0
    800058e6:	0187c783          	lbu	a5,24(a5)
    800058ea:	e7b9                	bnez	a5,80005938 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058ec:	00451693          	slli	a3,a0,0x4
    800058f0:	00243797          	auipc	a5,0x243
    800058f4:	19078793          	addi	a5,a5,400 # 80248a80 <disk>
    800058f8:	6398                	ld	a4,0(a5)
    800058fa:	9736                	add	a4,a4,a3
    800058fc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005900:	6398                	ld	a4,0(a5)
    80005902:	9736                	add	a4,a4,a3
    80005904:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005908:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000590c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005910:	97aa                	add	a5,a5,a0
    80005912:	4705                	li	a4,1
    80005914:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005918:	00243517          	auipc	a0,0x243
    8000591c:	18050513          	addi	a0,a0,384 # 80248a98 <disk+0x18>
    80005920:	89dfc0ef          	jal	ra,800021bc <wakeup>
}
    80005924:	60a2                	ld	ra,8(sp)
    80005926:	6402                	ld	s0,0(sp)
    80005928:	0141                	addi	sp,sp,16
    8000592a:	8082                	ret
    panic("free_desc 1");
    8000592c:	00002517          	auipc	a0,0x2
    80005930:	e0c50513          	addi	a0,a0,-500 # 80007738 <syscalls+0x340>
    80005934:	e55fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005938:	00002517          	auipc	a0,0x2
    8000593c:	e1050513          	addi	a0,a0,-496 # 80007748 <syscalls+0x350>
    80005940:	e49fa0ef          	jal	ra,80000788 <panic>

0000000080005944 <virtio_disk_init>:
{
    80005944:	1101                	addi	sp,sp,-32
    80005946:	ec06                	sd	ra,24(sp)
    80005948:	e822                	sd	s0,16(sp)
    8000594a:	e426                	sd	s1,8(sp)
    8000594c:	e04a                	sd	s2,0(sp)
    8000594e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005950:	00002597          	auipc	a1,0x2
    80005954:	e0858593          	addi	a1,a1,-504 # 80007758 <syscalls+0x360>
    80005958:	00243517          	auipc	a0,0x243
    8000595c:	25050513          	addi	a0,a0,592 # 80248ba8 <disk+0x128>
    80005960:	ac0fb0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005964:	100017b7          	lui	a5,0x10001
    80005968:	4398                	lw	a4,0(a5)
    8000596a:	2701                	sext.w	a4,a4
    8000596c:	747277b7          	lui	a5,0x74727
    80005970:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005974:	12f71f63          	bne	a4,a5,80005ab2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005978:	100017b7          	lui	a5,0x10001
    8000597c:	43dc                	lw	a5,4(a5)
    8000597e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005980:	4709                	li	a4,2
    80005982:	12e79863          	bne	a5,a4,80005ab2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005986:	100017b7          	lui	a5,0x10001
    8000598a:	479c                	lw	a5,8(a5)
    8000598c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000598e:	12e79263          	bne	a5,a4,80005ab2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005992:	100017b7          	lui	a5,0x10001
    80005996:	47d8                	lw	a4,12(a5)
    80005998:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000599a:	554d47b7          	lui	a5,0x554d4
    8000599e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800059a2:	10f71863          	bne	a4,a5,80005ab2 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a6:	100017b7          	lui	a5,0x10001
    800059aa:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059ae:	4705                	li	a4,1
    800059b0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059b2:	470d                	li	a4,3
    800059b4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800059b6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800059b8:	c7ffe6b7          	lui	a3,0xc7ffe
    800059bc:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db5b9f>
    800059c0:	8f75                	and	a4,a4,a3
    800059c2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c4:	472d                	li	a4,11
    800059c6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800059c8:	5bbc                	lw	a5,112(a5)
    800059ca:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059ce:	8ba1                	andi	a5,a5,8
    800059d0:	0e078763          	beqz	a5,80005abe <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059d4:	100017b7          	lui	a5,0x10001
    800059d8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800059dc:	43fc                	lw	a5,68(a5)
    800059de:	2781                	sext.w	a5,a5
    800059e0:	0e079563          	bnez	a5,80005aca <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059e4:	100017b7          	lui	a5,0x10001
    800059e8:	5bdc                	lw	a5,52(a5)
    800059ea:	2781                	sext.w	a5,a5
  if(max == 0)
    800059ec:	0e078563          	beqz	a5,80005ad6 <virtio_disk_init+0x192>
  if(max < NUM)
    800059f0:	471d                	li	a4,7
    800059f2:	0ef77863          	bgeu	a4,a5,80005ae2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800059f6:	9b4fb0ef          	jal	ra,80000baa <kalloc>
    800059fa:	00243497          	auipc	s1,0x243
    800059fe:	08648493          	addi	s1,s1,134 # 80248a80 <disk>
    80005a02:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005a04:	9a6fb0ef          	jal	ra,80000baa <kalloc>
    80005a08:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005a0a:	9a0fb0ef          	jal	ra,80000baa <kalloc>
    80005a0e:	87aa                	mv	a5,a0
    80005a10:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005a12:	6088                	ld	a0,0(s1)
    80005a14:	cd69                	beqz	a0,80005aee <virtio_disk_init+0x1aa>
    80005a16:	00243717          	auipc	a4,0x243
    80005a1a:	07273703          	ld	a4,114(a4) # 80248a88 <disk+0x8>
    80005a1e:	cb61                	beqz	a4,80005aee <virtio_disk_init+0x1aa>
    80005a20:	c7f9                	beqz	a5,80005aee <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005a22:	6605                	lui	a2,0x1
    80005a24:	4581                	li	a1,0
    80005a26:	b4efb0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a2a:	00243497          	auipc	s1,0x243
    80005a2e:	05648493          	addi	s1,s1,86 # 80248a80 <disk>
    80005a32:	6605                	lui	a2,0x1
    80005a34:	4581                	li	a1,0
    80005a36:	6488                	ld	a0,8(s1)
    80005a38:	b3cfb0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a3c:	6605                	lui	a2,0x1
    80005a3e:	4581                	li	a1,0
    80005a40:	6888                	ld	a0,16(s1)
    80005a42:	b32fb0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a46:	100017b7          	lui	a5,0x10001
    80005a4a:	4721                	li	a4,8
    80005a4c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a4e:	4098                	lw	a4,0(s1)
    80005a50:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a54:	40d8                	lw	a4,4(s1)
    80005a56:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a5a:	6498                	ld	a4,8(s1)
    80005a5c:	0007069b          	sext.w	a3,a4
    80005a60:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a64:	9701                	srai	a4,a4,0x20
    80005a66:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a6a:	6898                	ld	a4,16(s1)
    80005a6c:	0007069b          	sext.w	a3,a4
    80005a70:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a74:	9701                	srai	a4,a4,0x20
    80005a76:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a7a:	4705                	li	a4,1
    80005a7c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005a7e:	00e48c23          	sb	a4,24(s1)
    80005a82:	00e48ca3          	sb	a4,25(s1)
    80005a86:	00e48d23          	sb	a4,26(s1)
    80005a8a:	00e48da3          	sb	a4,27(s1)
    80005a8e:	00e48e23          	sb	a4,28(s1)
    80005a92:	00e48ea3          	sb	a4,29(s1)
    80005a96:	00e48f23          	sb	a4,30(s1)
    80005a9a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a9e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005aa2:	0727a823          	sw	s2,112(a5)
}
    80005aa6:	60e2                	ld	ra,24(sp)
    80005aa8:	6442                	ld	s0,16(sp)
    80005aaa:	64a2                	ld	s1,8(sp)
    80005aac:	6902                	ld	s2,0(sp)
    80005aae:	6105                	addi	sp,sp,32
    80005ab0:	8082                	ret
    panic("could not find virtio disk");
    80005ab2:	00002517          	auipc	a0,0x2
    80005ab6:	cb650513          	addi	a0,a0,-842 # 80007768 <syscalls+0x370>
    80005aba:	ccffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005abe:	00002517          	auipc	a0,0x2
    80005ac2:	cca50513          	addi	a0,a0,-822 # 80007788 <syscalls+0x390>
    80005ac6:	cc3fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    80005aca:	00002517          	auipc	a0,0x2
    80005ace:	cde50513          	addi	a0,a0,-802 # 800077a8 <syscalls+0x3b0>
    80005ad2:	cb7fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005ad6:	00002517          	auipc	a0,0x2
    80005ada:	cf250513          	addi	a0,a0,-782 # 800077c8 <syscalls+0x3d0>
    80005ade:	cabfa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005ae2:	00002517          	auipc	a0,0x2
    80005ae6:	d0650513          	addi	a0,a0,-762 # 800077e8 <syscalls+0x3f0>
    80005aea:	c9ffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    80005aee:	00002517          	auipc	a0,0x2
    80005af2:	d1a50513          	addi	a0,a0,-742 # 80007808 <syscalls+0x410>
    80005af6:	c93fa0ef          	jal	ra,80000788 <panic>

0000000080005afa <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005afa:	7119                	addi	sp,sp,-128
    80005afc:	fc86                	sd	ra,120(sp)
    80005afe:	f8a2                	sd	s0,112(sp)
    80005b00:	f4a6                	sd	s1,104(sp)
    80005b02:	f0ca                	sd	s2,96(sp)
    80005b04:	ecce                	sd	s3,88(sp)
    80005b06:	e8d2                	sd	s4,80(sp)
    80005b08:	e4d6                	sd	s5,72(sp)
    80005b0a:	e0da                	sd	s6,64(sp)
    80005b0c:	fc5e                	sd	s7,56(sp)
    80005b0e:	f862                	sd	s8,48(sp)
    80005b10:	f466                	sd	s9,40(sp)
    80005b12:	f06a                	sd	s10,32(sp)
    80005b14:	ec6e                	sd	s11,24(sp)
    80005b16:	0100                	addi	s0,sp,128
    80005b18:	8aaa                	mv	s5,a0
    80005b1a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b1c:	00c52d03          	lw	s10,12(a0)
    80005b20:	001d1d1b          	slliw	s10,s10,0x1
    80005b24:	1d02                	slli	s10,s10,0x20
    80005b26:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005b2a:	00243517          	auipc	a0,0x243
    80005b2e:	07e50513          	addi	a0,a0,126 # 80248ba8 <disk+0x128>
    80005b32:	96efb0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80005b36:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005b38:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b3a:	00243b97          	auipc	s7,0x243
    80005b3e:	f46b8b93          	addi	s7,s7,-186 # 80248a80 <disk>
  for(int i = 0; i < 3; i++){
    80005b42:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b44:	00243c97          	auipc	s9,0x243
    80005b48:	064c8c93          	addi	s9,s9,100 # 80248ba8 <disk+0x128>
    80005b4c:	a8a9                	j	80005ba6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005b4e:	00fb8733          	add	a4,s7,a5
    80005b52:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b56:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005b58:	0207c563          	bltz	a5,80005b82 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005b5c:	2905                	addiw	s2,s2,1
    80005b5e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b60:	05690863          	beq	s2,s6,80005bb0 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005b64:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005b66:	00243717          	auipc	a4,0x243
    80005b6a:	f1a70713          	addi	a4,a4,-230 # 80248a80 <disk>
    80005b6e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005b70:	01874683          	lbu	a3,24(a4)
    80005b74:	fee9                	bnez	a3,80005b4e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005b76:	2785                	addiw	a5,a5,1
    80005b78:	0705                	addi	a4,a4,1
    80005b7a:	fe979be3          	bne	a5,s1,80005b70 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005b7e:	57fd                	li	a5,-1
    80005b80:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005b82:	01205b63          	blez	s2,80005b98 <virtio_disk_rw+0x9e>
    80005b86:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005b88:	000a2503          	lw	a0,0(s4)
    80005b8c:	d43ff0ef          	jal	ra,800058ce <free_desc>
      for(int j = 0; j < i; j++)
    80005b90:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80005b92:	0a11                	addi	s4,s4,4
    80005b94:	ff2d9ae3          	bne	s11,s2,80005b88 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b98:	85e6                	mv	a1,s9
    80005b9a:	00243517          	auipc	a0,0x243
    80005b9e:	efe50513          	addi	a0,a0,-258 # 80248a98 <disk+0x18>
    80005ba2:	dcefc0ef          	jal	ra,80002170 <sleep>
  for(int i = 0; i < 3; i++){
    80005ba6:	f8040a13          	addi	s4,s0,-128
{
    80005baa:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005bac:	894e                	mv	s2,s3
    80005bae:	bf5d                	j	80005b64 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bb0:	f8042503          	lw	a0,-128(s0)
    80005bb4:	00a50713          	addi	a4,a0,10
    80005bb8:	0712                	slli	a4,a4,0x4

  if(write)
    80005bba:	00243797          	auipc	a5,0x243
    80005bbe:	ec678793          	addi	a5,a5,-314 # 80248a80 <disk>
    80005bc2:	00e786b3          	add	a3,a5,a4
    80005bc6:	01803633          	snez	a2,s8
    80005bca:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bcc:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005bd0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bd4:	f6070613          	addi	a2,a4,-160
    80005bd8:	6394                	ld	a3,0(a5)
    80005bda:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bdc:	00870593          	addi	a1,a4,8
    80005be0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005be2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005be4:	0007b803          	ld	a6,0(a5)
    80005be8:	9642                	add	a2,a2,a6
    80005bea:	46c1                	li	a3,16
    80005bec:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bee:	4585                	li	a1,1
    80005bf0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005bf4:	f8442683          	lw	a3,-124(s0)
    80005bf8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005bfc:	0692                	slli	a3,a3,0x4
    80005bfe:	9836                	add	a6,a6,a3
    80005c00:	058a8613          	addi	a2,s5,88
    80005c04:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005c08:	0007b803          	ld	a6,0(a5)
    80005c0c:	96c2                	add	a3,a3,a6
    80005c0e:	40000613          	li	a2,1024
    80005c12:	c690                	sw	a2,8(a3)
  if(write)
    80005c14:	001c3613          	seqz	a2,s8
    80005c18:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c1c:	00166613          	ori	a2,a2,1
    80005c20:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005c24:	f8842603          	lw	a2,-120(s0)
    80005c28:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c2c:	00250693          	addi	a3,a0,2
    80005c30:	0692                	slli	a3,a3,0x4
    80005c32:	96be                	add	a3,a3,a5
    80005c34:	58fd                	li	a7,-1
    80005c36:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005c3a:	0612                	slli	a2,a2,0x4
    80005c3c:	9832                	add	a6,a6,a2
    80005c3e:	f9070713          	addi	a4,a4,-112
    80005c42:	973e                	add	a4,a4,a5
    80005c44:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005c48:	6398                	ld	a4,0(a5)
    80005c4a:	9732                	add	a4,a4,a2
    80005c4c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c4e:	4609                	li	a2,2
    80005c50:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c54:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c58:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005c5c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c60:	6794                	ld	a3,8(a5)
    80005c62:	0026d703          	lhu	a4,2(a3)
    80005c66:	8b1d                	andi	a4,a4,7
    80005c68:	0706                	slli	a4,a4,0x1
    80005c6a:	96ba                	add	a3,a3,a4
    80005c6c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c70:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c74:	6798                	ld	a4,8(a5)
    80005c76:	00275783          	lhu	a5,2(a4)
    80005c7a:	2785                	addiw	a5,a5,1
    80005c7c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c80:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c84:	100017b7          	lui	a5,0x10001
    80005c88:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c8c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005c90:	00243917          	auipc	s2,0x243
    80005c94:	f1890913          	addi	s2,s2,-232 # 80248ba8 <disk+0x128>
  while(b->disk == 1) {
    80005c98:	4485                	li	s1,1
    80005c9a:	00b79a63          	bne	a5,a1,80005cae <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005c9e:	85ca                	mv	a1,s2
    80005ca0:	8556                	mv	a0,s5
    80005ca2:	ccefc0ef          	jal	ra,80002170 <sleep>
  while(b->disk == 1) {
    80005ca6:	004aa783          	lw	a5,4(s5)
    80005caa:	fe978ae3          	beq	a5,s1,80005c9e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005cae:	f8042903          	lw	s2,-128(s0)
    80005cb2:	00290713          	addi	a4,s2,2
    80005cb6:	0712                	slli	a4,a4,0x4
    80005cb8:	00243797          	auipc	a5,0x243
    80005cbc:	dc878793          	addi	a5,a5,-568 # 80248a80 <disk>
    80005cc0:	97ba                	add	a5,a5,a4
    80005cc2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005cc6:	00243997          	auipc	s3,0x243
    80005cca:	dba98993          	addi	s3,s3,-582 # 80248a80 <disk>
    80005cce:	00491713          	slli	a4,s2,0x4
    80005cd2:	0009b783          	ld	a5,0(s3)
    80005cd6:	97ba                	add	a5,a5,a4
    80005cd8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cdc:	854a                	mv	a0,s2
    80005cde:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005ce2:	bedff0ef          	jal	ra,800058ce <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005ce6:	8885                	andi	s1,s1,1
    80005ce8:	f0fd                	bnez	s1,80005cce <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005cea:	00243517          	auipc	a0,0x243
    80005cee:	ebe50513          	addi	a0,a0,-322 # 80248ba8 <disk+0x128>
    80005cf2:	846fb0ef          	jal	ra,80000d38 <release>
}
    80005cf6:	70e6                	ld	ra,120(sp)
    80005cf8:	7446                	ld	s0,112(sp)
    80005cfa:	74a6                	ld	s1,104(sp)
    80005cfc:	7906                	ld	s2,96(sp)
    80005cfe:	69e6                	ld	s3,88(sp)
    80005d00:	6a46                	ld	s4,80(sp)
    80005d02:	6aa6                	ld	s5,72(sp)
    80005d04:	6b06                	ld	s6,64(sp)
    80005d06:	7be2                	ld	s7,56(sp)
    80005d08:	7c42                	ld	s8,48(sp)
    80005d0a:	7ca2                	ld	s9,40(sp)
    80005d0c:	7d02                	ld	s10,32(sp)
    80005d0e:	6de2                	ld	s11,24(sp)
    80005d10:	6109                	addi	sp,sp,128
    80005d12:	8082                	ret

0000000080005d14 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d14:	1101                	addi	sp,sp,-32
    80005d16:	ec06                	sd	ra,24(sp)
    80005d18:	e822                	sd	s0,16(sp)
    80005d1a:	e426                	sd	s1,8(sp)
    80005d1c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d1e:	00243497          	auipc	s1,0x243
    80005d22:	d6248493          	addi	s1,s1,-670 # 80248a80 <disk>
    80005d26:	00243517          	auipc	a0,0x243
    80005d2a:	e8250513          	addi	a0,a0,-382 # 80248ba8 <disk+0x128>
    80005d2e:	f73fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d32:	10001737          	lui	a4,0x10001
    80005d36:	533c                	lw	a5,96(a4)
    80005d38:	8b8d                	andi	a5,a5,3
    80005d3a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005d3c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005d40:	689c                	ld	a5,16(s1)
    80005d42:	0204d703          	lhu	a4,32(s1)
    80005d46:	0027d783          	lhu	a5,2(a5)
    80005d4a:	04f70663          	beq	a4,a5,80005d96 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005d4e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d52:	6898                	ld	a4,16(s1)
    80005d54:	0204d783          	lhu	a5,32(s1)
    80005d58:	8b9d                	andi	a5,a5,7
    80005d5a:	078e                	slli	a5,a5,0x3
    80005d5c:	97ba                	add	a5,a5,a4
    80005d5e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d60:	00278713          	addi	a4,a5,2
    80005d64:	0712                	slli	a4,a4,0x4
    80005d66:	9726                	add	a4,a4,s1
    80005d68:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005d6c:	e321                	bnez	a4,80005dac <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d6e:	0789                	addi	a5,a5,2
    80005d70:	0792                	slli	a5,a5,0x4
    80005d72:	97a6                	add	a5,a5,s1
    80005d74:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d76:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d7a:	c42fc0ef          	jal	ra,800021bc <wakeup>

    disk.used_idx += 1;
    80005d7e:	0204d783          	lhu	a5,32(s1)
    80005d82:	2785                	addiw	a5,a5,1
    80005d84:	17c2                	slli	a5,a5,0x30
    80005d86:	93c1                	srli	a5,a5,0x30
    80005d88:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d8c:	6898                	ld	a4,16(s1)
    80005d8e:	00275703          	lhu	a4,2(a4)
    80005d92:	faf71ee3          	bne	a4,a5,80005d4e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005d96:	00243517          	auipc	a0,0x243
    80005d9a:	e1250513          	addi	a0,a0,-494 # 80248ba8 <disk+0x128>
    80005d9e:	f9bfa0ef          	jal	ra,80000d38 <release>
}
    80005da2:	60e2                	ld	ra,24(sp)
    80005da4:	6442                	ld	s0,16(sp)
    80005da6:	64a2                	ld	s1,8(sp)
    80005da8:	6105                	addi	sp,sp,32
    80005daa:	8082                	ret
      panic("virtio_disk_intr status");
    80005dac:	00002517          	auipc	a0,0x2
    80005db0:	a7450513          	addi	a0,a0,-1420 # 80007820 <syscalls+0x428>
    80005db4:	9d5fa0ef          	jal	ra,80000788 <panic>
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
