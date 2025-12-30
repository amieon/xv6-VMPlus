
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
    80000f50:	2a5040ef          	jal	ra,800059f4 <plicinithart>
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
    80000f9c:	243040ef          	jal	ra,800059de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	255040ef          	jal	ra,800059f4 <plicinithart>
    binit();         // buffer cache
    80000fa4:	1a4020ef          	jal	ra,80003148 <binit>
    iinit();         // inode table
    80000fa8:	714020ef          	jal	ra,800036bc <iinit>
    fileinit();      // file table
    80000fac:	5fc030ef          	jal	ra,800045a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	335040ef          	jal	ra,80005ae4 <virtio_disk_init>
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
    80001b52:	01c020ef          	jal	ra,80003b6e <fsinit>

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
    80001b76:	0a6030ef          	jal	ra,80004c1c <kexec>
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
    80001e4e:	224020ef          	jal	ra,80004072 <namei>
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
    80001f68:	6c2020ef          	jal	ra,8000462a <filedup>
    80001f6c:	00a93023          	sd	a0,0(s2)
    80001f70:	b7f5                	j	80001f5c <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001f72:	150ab503          	ld	a0,336(s5)
    80001f76:	0d3010ef          	jal	ra,80003848 <idup>
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
    800022b4:	3bc020ef          	jal	ra,80004670 <fileclose>
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
    800022c8:	79f010ef          	jal	ra,80004266 <begin_op>
  iput(p->cwd);
    800022cc:	1509b503          	ld	a0,336(s3)
    800022d0:	72c010ef          	jal	ra,800039fc <iput>
  end_op();
    800022d4:	000020ef          	jal	ra,800042d4 <end_op>
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
    8000269c:	2e878793          	addi	a5,a5,744 # 80005980 <kernelvec>
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
    800027a6:	282030ef          	jal	ra,80005a28 <plic_claim>
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
    800027cc:	27c030ef          	jal	ra,80005a48 <plic_complete>
    return 1;
    800027d0:	4505                	li	a0,1
    800027d2:	b7e9                	j	8000279c <devintr+0x24>
      uartintr();
    800027d4:	980fe0ef          	jal	ra,80000954 <uartintr>
    800027d8:	bfcd                	j	800027ca <devintr+0x52>
      virtio_disk_intr();
    800027da:	6da030ef          	jal	ra,80005eb4 <virtio_disk_intr>
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
    8000280e:	17678793          	addi	a5,a5,374 # 80005980 <kernelvec>
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
  return best;
}

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
    80002ed8:	7119                	addi	sp,sp,-128
    80002eda:	fc86                	sd	ra,120(sp)
    80002edc:	f8a2                	sd	s0,112(sp)
    80002ede:	f4a6                	sd	s1,104(sp)
    80002ee0:	f0ca                	sd	s2,96(sp)
    80002ee2:	ecce                	sd	s3,88(sp)
    80002ee4:	e8d2                	sd	s4,80(sp)
    80002ee6:	e4d6                	sd	s5,72(sp)
    80002ee8:	e0da                	sd	s6,64(sp)
    80002eea:	fc5e                	sd	s7,56(sp)
    80002eec:	f862                	sd	s8,48(sp)
    80002eee:	f466                	sd	s9,40(sp)
    80002ef0:	f06a                	sd	s10,32(sp)
    80002ef2:	ec6e                	sd	s11,24(sp)
    80002ef4:	0100                	addi	s0,sp,128
  struct proc *p = myproc();
    80002ef6:	c0dfe0ef          	jal	ra,80001b02 <myproc>
    80002efa:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    80002efc:	f8840593          	addi	a1,s0,-120
    80002f00:	4501                	li	a0,0
    80002f02:	bc3ff0ef          	jal	ra,80002ac4 <argaddr>
  argint(1, &len);
    80002f06:	f8440593          	addi	a1,s0,-124
    80002f0a:	4505                	li	a0,1
    80002f0c:	b9dff0ef          	jal	ra,80002aa8 <argint>

  if(len <= 0) return (uint64)-1;
    80002f10:	f8442683          	lw	a3,-124(s0)
    80002f14:	22d05663          	blez	a3,80003140 <sys_munmap+0x268>


  uint64 a = PGROUNDDOWN(uaddr);
    80002f18:	f8843783          	ld	a5,-120(s0)
    80002f1c:	767d                	lui	a2,0xfffff
    80002f1e:	00c7fa33          	and	s4,a5,a2
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    80002f22:	6705                	lui	a4,0x1
    80002f24:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002f26:	00e78933          	add	s2,a5,a4
    80002f2a:	9936                	add	s2,s2,a3
    80002f2c:	00c97933          	and	s2,s2,a2
  if(b < a) return (uint64)-1;  // 溢出了
    80002f30:	557d                	li	a0,-1
    80002f32:	17496363          	bltu	s2,s4,80003098 <sys_munmap+0x1c0>
    80002f36:	168a8b13          	addi	s6,s5,360
    80002f3a:	368a8993          	addi	s3,s5,872
    80002f3e:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    80002f40:	4801                	li	a6,0
    80002f42:	a029                	j	80002f4c <sys_munmap+0x74>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    80002f44:	02078793          	addi	a5,a5,32
    80002f48:	01378663          	beq	a5,s3,80002f54 <sys_munmap+0x7c>
    80002f4c:	4398                	lw	a4,0(a5)
    80002f4e:	fb7d                	bnez	a4,80002f44 <sys_munmap+0x6c>
    80002f50:	2805                	addiw	a6,a6,1
    80002f52:	bfcd                	j	80002f44 <sys_munmap+0x6c>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    80002f54:	8552                	mv	a0,s4
  int need_splits = 0;
    80002f56:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    80002f58:	4881                	li	a7,0
    80002f5a:	45c1                	li	a1,16
    80002f5c:	537d                	li	t1,-1
  while(cur < b){
    80002f5e:	052a6c63          	bltu	s4,s2,80002fb6 <sys_munmap+0xde>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    80002f62:	43f85513          	srai	a0,a6,0x3f
    80002f66:	aa0d                	j	80003098 <sys_munmap+0x1c0>
  for(int i = 0; i < NVMA; i++){
    80002f68:	2705                	addiw	a4,a4,1
    80002f6a:	02078793          	addi	a5,a5,32
    80002f6e:	04b70763          	beq	a4,a1,80002fbc <sys_munmap+0xe4>
    if(!p->vmas[i].used) continue;
    80002f72:	4394                	lw	a3,0(a5)
    80002f74:	daf5                	beqz	a3,80002f68 <sys_munmap+0x90>
    if(!(b <= s || a >= e))   // overlap
    80002f76:	6794                	ld	a3,8(a5)
    80002f78:	ff26f8e3          	bgeu	a3,s2,80002f68 <sys_munmap+0x90>
    80002f7c:	6b94                	ld	a3,16(a5)
    80002f7e:	fed575e3          	bgeu	a0,a3,80002f68 <sys_munmap+0x90>
    if(vi < 0){
    80002f82:	04074063          	bltz	a4,80002fc2 <sys_munmap+0xea>
    uint64 seg_start = cur > v->start ? cur : v->start;
    80002f86:	00b70793          	addi	a5,a4,11
    80002f8a:	0796                	slli	a5,a5,0x5
    80002f8c:	97d6                	add	a5,a5,s5
    80002f8e:	6b9c                	ld	a5,16(a5)
    80002f90:	86be                	mv	a3,a5
    80002f92:	00a7f363          	bgeu	a5,a0,80002f98 <sys_munmap+0xc0>
    80002f96:	86aa                	mv	a3,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80002f98:	0716                	slli	a4,a4,0x5
    80002f9a:	9756                	add	a4,a4,s5
    80002f9c:	17873703          	ld	a4,376(a4)
    80002fa0:	853a                	mv	a0,a4
    80002fa2:	00e97363          	bgeu	s2,a4,80002fa8 <sys_munmap+0xd0>
    80002fa6:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    80002fa8:	00d7f563          	bgeu	a5,a3,80002fb2 <sys_munmap+0xda>
    80002fac:	00e57363          	bgeu	a0,a4,80002fb2 <sys_munmap+0xda>
      need_splits++;
    80002fb0:	2e05                	addiw	t3,t3,1 # fffffffff3fff001 <end+0xffffffff73db6441>
  while(cur < b){
    80002fb2:	03257a63          	bgeu	a0,s2,80002fe6 <sys_munmap+0x10e>
  int free_slots = 0;
    80002fb6:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80002fb8:	8746                	mv	a4,a7
    80002fba:	bf65                	j	80002f72 <sys_munmap+0x9a>
    80002fbc:	87da                	mv	a5,s6
    80002fbe:	869a                	mv	a3,t1
    80002fc0:	a801                	j	80002fd0 <sys_munmap+0xf8>
    80002fc2:	87da                	mv	a5,s6
    80002fc4:	869a                	mv	a3,t1
    80002fc6:	a029                	j	80002fd0 <sys_munmap+0xf8>
  for(int i = 0; i < NVMA; i++){
    80002fc8:	02078793          	addi	a5,a5,32
    80002fcc:	01378b63          	beq	a5,s3,80002fe2 <sys_munmap+0x10a>
    if(!p->vmas[i].used) continue;
    80002fd0:	4398                	lw	a4,0(a5)
    80002fd2:	db7d                	beqz	a4,80002fc8 <sys_munmap+0xf0>
    uint64 s = p->vmas[i].start;
    80002fd4:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80002fd6:	fea769e3          	bltu	a4,a0,80002fc8 <sys_munmap+0xf0>
    80002fda:	fed777e3          	bgeu	a4,a3,80002fc8 <sys_munmap+0xf0>
    80002fde:	86ba                	mv	a3,a4
    80002fe0:	b7e5                	j	80002fc8 <sys_munmap+0xf0>
      if(ns == (uint64)-1 || ns >= b) break;
    80002fe2:	0126e963          	bltu	a3,s2,80002ff4 <sys_munmap+0x11c>
    // 不做任何事，保持一致性
    return (uint64)-1;
    80002fe6:	557d                	li	a0,-1
  if(need_splits > free_slots){
    80002fe8:	0bc84863          	blt	a6,t3,80003098 <sys_munmap+0x1c0>
  for(int i = 0; i < NVMA; i++){
    80002fec:	4c01                	li	s8,0
    80002fee:	4bc1                	li	s7,16
    80002ff0:	5cfd                	li	s9,-1
    80002ff2:	a2a1                	j	8000313a <sys_munmap+0x262>
    80002ff4:	8536                	mv	a0,a3
    80002ff6:	b7c1                	j	80002fb6 <sys_munmap+0xde>
    80002ff8:	2485                	addiw	s1,s1,1
    80002ffa:	02078793          	addi	a5,a5,32
    80002ffe:	07748763          	beq	s1,s7,8000306c <sys_munmap+0x194>
    if(!p->vmas[i].used) continue;
    80003002:	4398                	lw	a4,0(a5)
    80003004:	db75                	beqz	a4,80002ff8 <sys_munmap+0x120>
    if(!(b <= s || a >= e))   // overlap
    80003006:	6798                	ld	a4,8(a5)
    80003008:	ff2778e3          	bgeu	a4,s2,80002ff8 <sys_munmap+0x120>
    8000300c:	6b98                	ld	a4,16(a5)
    8000300e:	feea75e3          	bgeu	s4,a4,80002ff8 <sys_munmap+0x120>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    80003012:	0604c063          	bltz	s1,80003072 <sys_munmap+0x19a>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    80003016:	00549d93          	slli	s11,s1,0x5
    8000301a:	9dd6                	add	s11,s11,s5
    8000301c:	170dbd03          	ld	s10,368(s11)
    80003020:	014d7363          	bgeu	s10,s4,80003026 <sys_munmap+0x14e>
    80003024:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003026:	00549793          	slli	a5,s1,0x5
    8000302a:	97d6                	add	a5,a5,s5
    8000302c:	1787ba03          	ld	s4,376(a5)
    80003030:	01497363          	bgeu	s2,s4,80003036 <sys_munmap+0x15e>
    80003034:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    80003036:	094d6263          	bltu	s10,s4,800030ba <sys_munmap+0x1e2>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新 VMA（四种情况）
    if(seg_start <= v->start && seg_end >= v->end){
    8000303a:	170db783          	ld	a5,368(s11)
    8000303e:	09a7eb63          	bltu	a5,s10,800030d4 <sys_munmap+0x1fc>
    80003042:	00549793          	slli	a5,s1,0x5
    80003046:	97d6                	add	a5,a5,s5
    80003048:	1787b783          	ld	a5,376(a5)
    8000304c:	08fa6163          	bltu	s4,a5,800030ce <sys_munmap+0x1f6>
      // 覆盖整条 VMA：删除
      v->used = 0;
    80003050:	160da423          	sw	zero,360(s11)
      v->start = v->end = 0;
    80003054:	00549793          	slli	a5,s1,0x5
    80003058:	97d6                	add	a5,a5,s5
    8000305a:	1607bc23          	sd	zero,376(a5)
    8000305e:	160db823          	sd	zero,368(s11)
      v->prot = v->flags = 0;
    80003062:	1807a223          	sw	zero,388(a5)
    80003066:	1807a023          	sw	zero,384(a5)
    8000306a:	a0f1                	j	80003136 <sys_munmap+0x25e>
    8000306c:	87da                	mv	a5,s6
    8000306e:	86e6                	mv	a3,s9
    80003070:	a801                	j	80003080 <sys_munmap+0x1a8>
    80003072:	87da                	mv	a5,s6
    80003074:	86e6                	mv	a3,s9
    80003076:	a029                	j	80003080 <sys_munmap+0x1a8>
  for(int i = 0; i < NVMA; i++){
    80003078:	02078793          	addi	a5,a5,32
    8000307c:	01378b63          	beq	a5,s3,80003092 <sys_munmap+0x1ba>
    if(!p->vmas[i].used) continue;
    80003080:	4398                	lw	a4,0(a5)
    80003082:	db7d                	beqz	a4,80003078 <sys_munmap+0x1a0>
    uint64 s = p->vmas[i].start;
    80003084:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80003086:	ff4769e3          	bltu	a4,s4,80003078 <sys_munmap+0x1a0>
    8000308a:	fed777e3          	bgeu	a4,a3,80003078 <sys_munmap+0x1a0>
    8000308e:	86ba                	mv	a3,a4
    80003090:	b7e5                	j	80003078 <sys_munmap+0x1a0>
      if(ns == (uint64)-1 || ns >= b) break;
    80003092:	0326e263          	bltu	a3,s2,800030b6 <sys_munmap+0x1de>
    }

    cur = seg_end;
  }

  return 0;
    80003096:	4501                	li	a0,0
}
    80003098:	70e6                	ld	ra,120(sp)
    8000309a:	7446                	ld	s0,112(sp)
    8000309c:	74a6                	ld	s1,104(sp)
    8000309e:	7906                	ld	s2,96(sp)
    800030a0:	69e6                	ld	s3,88(sp)
    800030a2:	6a46                	ld	s4,80(sp)
    800030a4:	6aa6                	ld	s5,72(sp)
    800030a6:	6b06                	ld	s6,64(sp)
    800030a8:	7be2                	ld	s7,56(sp)
    800030aa:	7c42                	ld	s8,48(sp)
    800030ac:	7ca2                	ld	s9,40(sp)
    800030ae:	7d02                	ld	s10,32(sp)
    800030b0:	6de2                	ld	s11,24(sp)
    800030b2:	6109                	addi	sp,sp,128
    800030b4:	8082                	ret
    800030b6:	8a36                	mv	s4,a3
    800030b8:	a049                	j	8000313a <sys_munmap+0x262>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    800030ba:	41aa0633          	sub	a2,s4,s10
    800030be:	4685                	li	a3,1
    800030c0:	8231                	srli	a2,a2,0xc
    800030c2:	85ea                	mv	a1,s10
    800030c4:	050ab503          	ld	a0,80(s5)
    800030c8:	9ccfe0ef          	jal	ra,80001294 <uvmunmap>
    800030cc:	b7bd                	j	8000303a <sys_munmap+0x162>
      v->start = seg_end;
    800030ce:	174db823          	sd	s4,368(s11)
    800030d2:	a095                	j	80003136 <sys_munmap+0x25e>
    } else if(seg_start > v->start && seg_end >= v->end){
    800030d4:	00549793          	slli	a5,s1,0x5
    800030d8:	97d6                	add	a5,a5,s5
    800030da:	1787b783          	ld	a5,376(a5)
    800030de:	00fa6863          	bltu	s4,a5,800030ee <sys_munmap+0x216>
      v->end = seg_start;
    800030e2:	00549793          	slli	a5,s1,0x5
    800030e6:	97d6                	add	a5,a5,s5
    800030e8:	17a7bc23          	sd	s10,376(a5)
    800030ec:	a0a9                	j	80003136 <sys_munmap+0x25e>
    800030ee:	875a                	mv	a4,s6
    800030f0:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    800030f2:	4314                	lw	a3,0(a4)
    800030f4:	c699                	beqz	a3,80003102 <sys_munmap+0x22a>
  for(int i = 0; i < NVMA; i++){
    800030f6:	2785                	addiw	a5,a5,1
    800030f8:	02070713          	addi	a4,a4,32
    800030fc:	ff779be3          	bne	a5,s7,800030f2 <sys_munmap+0x21a>
  return -1;
    80003100:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    80003102:	0796                	slli	a5,a5,0x5
    80003104:	97d6                	add	a5,a5,s5
    80003106:	00b48713          	addi	a4,s1,11
    8000310a:	0716                	slli	a4,a4,0x5
    8000310c:	9756                	add	a4,a4,s5
    8000310e:	6710                	ld	a2,8(a4)
    80003110:	6f14                	ld	a3,24(a4)
    80003112:	7318                	ld	a4,32(a4)
    80003114:	16c7b423          	sd	a2,360(a5)
    80003118:	16d7bc23          	sd	a3,376(a5)
    8000311c:	18e7b023          	sd	a4,384(a5)
      p->vmas[ni].start = seg_end;
    80003120:	1747b823          	sd	s4,368(a5)
      p->vmas[ni].end   = v->end;
    80003124:	00549713          	slli	a4,s1,0x5
    80003128:	9756                	add	a4,a4,s5
    8000312a:	17873683          	ld	a3,376(a4)
    8000312e:	16d7bc23          	sd	a3,376(a5)
      v->end = seg_start;
    80003132:	17a73c23          	sd	s10,376(a4)
  while(cur < b){
    80003136:	012a7763          	bgeu	s4,s2,80003144 <sys_munmap+0x26c>
  int need_splits = 0;
    8000313a:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    8000313c:	84e2                	mv	s1,s8
    8000313e:	b5d1                	j	80003002 <sys_munmap+0x12a>
  if(len <= 0) return (uint64)-1;
    80003140:	557d                	li	a0,-1
    80003142:	bf99                	j	80003098 <sys_munmap+0x1c0>
  return 0;
    80003144:	4501                	li	a0,0
    80003146:	bf89                	j	80003098 <sys_munmap+0x1c0>

0000000080003148 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003148:	7179                	addi	sp,sp,-48
    8000314a:	f406                	sd	ra,40(sp)
    8000314c:	f022                	sd	s0,32(sp)
    8000314e:	ec26                	sd	s1,24(sp)
    80003150:	e84a                	sd	s2,16(sp)
    80003152:	e44e                	sd	s3,8(sp)
    80003154:	e052                	sd	s4,0(sp)
    80003156:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003158:	00004597          	auipc	a1,0x4
    8000315c:	36058593          	addi	a1,a1,864 # 800074b8 <syscalls+0xc0>
    80003160:	0023a517          	auipc	a0,0x23a
    80003164:	69850513          	addi	a0,a0,1688 # 8023d7f8 <bcache>
    80003168:	ab9fd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000316c:	00242797          	auipc	a5,0x242
    80003170:	68c78793          	addi	a5,a5,1676 # 802457f8 <bcache+0x8000>
    80003174:	00243717          	auipc	a4,0x243
    80003178:	8ec70713          	addi	a4,a4,-1812 # 80245a60 <bcache+0x8268>
    8000317c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003180:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003184:	0023a497          	auipc	s1,0x23a
    80003188:	68c48493          	addi	s1,s1,1676 # 8023d810 <bcache+0x18>
    b->next = bcache.head.next;
    8000318c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000318e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003190:	00004a17          	auipc	s4,0x4
    80003194:	330a0a13          	addi	s4,s4,816 # 800074c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003198:	2b893783          	ld	a5,696(s2)
    8000319c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000319e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031a2:	85d2                	mv	a1,s4
    800031a4:	01048513          	addi	a0,s1,16
    800031a8:	302010ef          	jal	ra,800044aa <initsleeplock>
    bcache.head.next->prev = b;
    800031ac:	2b893783          	ld	a5,696(s2)
    800031b0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031b2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031b6:	45848493          	addi	s1,s1,1112
    800031ba:	fd349fe3          	bne	s1,s3,80003198 <binit+0x50>
  }
}
    800031be:	70a2                	ld	ra,40(sp)
    800031c0:	7402                	ld	s0,32(sp)
    800031c2:	64e2                	ld	s1,24(sp)
    800031c4:	6942                	ld	s2,16(sp)
    800031c6:	69a2                	ld	s3,8(sp)
    800031c8:	6a02                	ld	s4,0(sp)
    800031ca:	6145                	addi	sp,sp,48
    800031cc:	8082                	ret

00000000800031ce <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031ce:	7179                	addi	sp,sp,-48
    800031d0:	f406                	sd	ra,40(sp)
    800031d2:	f022                	sd	s0,32(sp)
    800031d4:	ec26                	sd	s1,24(sp)
    800031d6:	e84a                	sd	s2,16(sp)
    800031d8:	e44e                	sd	s3,8(sp)
    800031da:	1800                	addi	s0,sp,48
    800031dc:	892a                	mv	s2,a0
    800031de:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031e0:	0023a517          	auipc	a0,0x23a
    800031e4:	61850513          	addi	a0,a0,1560 # 8023d7f8 <bcache>
    800031e8:	ab9fd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031ec:	00243497          	auipc	s1,0x243
    800031f0:	8c44b483          	ld	s1,-1852(s1) # 80245ab0 <bcache+0x82b8>
    800031f4:	00243797          	auipc	a5,0x243
    800031f8:	86c78793          	addi	a5,a5,-1940 # 80245a60 <bcache+0x8268>
    800031fc:	02f48b63          	beq	s1,a5,80003232 <bread+0x64>
    80003200:	873e                	mv	a4,a5
    80003202:	a021                	j	8000320a <bread+0x3c>
    80003204:	68a4                	ld	s1,80(s1)
    80003206:	02e48663          	beq	s1,a4,80003232 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000320a:	449c                	lw	a5,8(s1)
    8000320c:	ff279ce3          	bne	a5,s2,80003204 <bread+0x36>
    80003210:	44dc                	lw	a5,12(s1)
    80003212:	ff3799e3          	bne	a5,s3,80003204 <bread+0x36>
      b->refcnt++;
    80003216:	40bc                	lw	a5,64(s1)
    80003218:	2785                	addiw	a5,a5,1
    8000321a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000321c:	0023a517          	auipc	a0,0x23a
    80003220:	5dc50513          	addi	a0,a0,1500 # 8023d7f8 <bcache>
    80003224:	b15fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003228:	01048513          	addi	a0,s1,16
    8000322c:	2b4010ef          	jal	ra,800044e0 <acquiresleep>
      return b;
    80003230:	a889                	j	80003282 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003232:	00243497          	auipc	s1,0x243
    80003236:	8764b483          	ld	s1,-1930(s1) # 80245aa8 <bcache+0x82b0>
    8000323a:	00243797          	auipc	a5,0x243
    8000323e:	82678793          	addi	a5,a5,-2010 # 80245a60 <bcache+0x8268>
    80003242:	00f48863          	beq	s1,a5,80003252 <bread+0x84>
    80003246:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003248:	40bc                	lw	a5,64(s1)
    8000324a:	cb91                	beqz	a5,8000325e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000324c:	64a4                	ld	s1,72(s1)
    8000324e:	fee49de3          	bne	s1,a4,80003248 <bread+0x7a>
  panic("bget: no buffers");
    80003252:	00004517          	auipc	a0,0x4
    80003256:	27650513          	addi	a0,a0,630 # 800074c8 <syscalls+0xd0>
    8000325a:	d2efd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    8000325e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003262:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003266:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000326a:	4785                	li	a5,1
    8000326c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000326e:	0023a517          	auipc	a0,0x23a
    80003272:	58a50513          	addi	a0,a0,1418 # 8023d7f8 <bcache>
    80003276:	ac3fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    8000327a:	01048513          	addi	a0,s1,16
    8000327e:	262010ef          	jal	ra,800044e0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003282:	409c                	lw	a5,0(s1)
    80003284:	cb89                	beqz	a5,80003296 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003286:	8526                	mv	a0,s1
    80003288:	70a2                	ld	ra,40(sp)
    8000328a:	7402                	ld	s0,32(sp)
    8000328c:	64e2                	ld	s1,24(sp)
    8000328e:	6942                	ld	s2,16(sp)
    80003290:	69a2                	ld	s3,8(sp)
    80003292:	6145                	addi	sp,sp,48
    80003294:	8082                	ret
    virtio_disk_rw(b, 0);
    80003296:	4581                	li	a1,0
    80003298:	8526                	mv	a0,s1
    8000329a:	201020ef          	jal	ra,80005c9a <virtio_disk_rw>
    b->valid = 1;
    8000329e:	4785                	li	a5,1
    800032a0:	c09c                	sw	a5,0(s1)
  return b;
    800032a2:	b7d5                	j	80003286 <bread+0xb8>

00000000800032a4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032a4:	1101                	addi	sp,sp,-32
    800032a6:	ec06                	sd	ra,24(sp)
    800032a8:	e822                	sd	s0,16(sp)
    800032aa:	e426                	sd	s1,8(sp)
    800032ac:	1000                	addi	s0,sp,32
    800032ae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032b0:	0541                	addi	a0,a0,16
    800032b2:	2ac010ef          	jal	ra,8000455e <holdingsleep>
    800032b6:	c911                	beqz	a0,800032ca <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032b8:	4585                	li	a1,1
    800032ba:	8526                	mv	a0,s1
    800032bc:	1df020ef          	jal	ra,80005c9a <virtio_disk_rw>
}
    800032c0:	60e2                	ld	ra,24(sp)
    800032c2:	6442                	ld	s0,16(sp)
    800032c4:	64a2                	ld	s1,8(sp)
    800032c6:	6105                	addi	sp,sp,32
    800032c8:	8082                	ret
    panic("bwrite");
    800032ca:	00004517          	auipc	a0,0x4
    800032ce:	21650513          	addi	a0,a0,534 # 800074e0 <syscalls+0xe8>
    800032d2:	cb6fd0ef          	jal	ra,80000788 <panic>

00000000800032d6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	e426                	sd	s1,8(sp)
    800032de:	e04a                	sd	s2,0(sp)
    800032e0:	1000                	addi	s0,sp,32
    800032e2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032e4:	01050913          	addi	s2,a0,16
    800032e8:	854a                	mv	a0,s2
    800032ea:	274010ef          	jal	ra,8000455e <holdingsleep>
    800032ee:	c13d                	beqz	a0,80003354 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800032f0:	854a                	mv	a0,s2
    800032f2:	234010ef          	jal	ra,80004526 <releasesleep>

  acquire(&bcache.lock);
    800032f6:	0023a517          	auipc	a0,0x23a
    800032fa:	50250513          	addi	a0,a0,1282 # 8023d7f8 <bcache>
    800032fe:	9a3fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80003302:	40bc                	lw	a5,64(s1)
    80003304:	37fd                	addiw	a5,a5,-1
    80003306:	0007871b          	sext.w	a4,a5
    8000330a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000330c:	eb05                	bnez	a4,8000333c <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000330e:	68bc                	ld	a5,80(s1)
    80003310:	64b8                	ld	a4,72(s1)
    80003312:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003314:	64bc                	ld	a5,72(s1)
    80003316:	68b8                	ld	a4,80(s1)
    80003318:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000331a:	00242797          	auipc	a5,0x242
    8000331e:	4de78793          	addi	a5,a5,1246 # 802457f8 <bcache+0x8000>
    80003322:	2b87b703          	ld	a4,696(a5)
    80003326:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003328:	00242717          	auipc	a4,0x242
    8000332c:	73870713          	addi	a4,a4,1848 # 80245a60 <bcache+0x8268>
    80003330:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003332:	2b87b703          	ld	a4,696(a5)
    80003336:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003338:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000333c:	0023a517          	auipc	a0,0x23a
    80003340:	4bc50513          	addi	a0,a0,1212 # 8023d7f8 <bcache>
    80003344:	9f5fd0ef          	jal	ra,80000d38 <release>
}
    80003348:	60e2                	ld	ra,24(sp)
    8000334a:	6442                	ld	s0,16(sp)
    8000334c:	64a2                	ld	s1,8(sp)
    8000334e:	6902                	ld	s2,0(sp)
    80003350:	6105                	addi	sp,sp,32
    80003352:	8082                	ret
    panic("brelse");
    80003354:	00004517          	auipc	a0,0x4
    80003358:	19450513          	addi	a0,a0,404 # 800074e8 <syscalls+0xf0>
    8000335c:	c2cfd0ef          	jal	ra,80000788 <panic>

0000000080003360 <bpin>:

void
bpin(struct buf *b) {
    80003360:	1101                	addi	sp,sp,-32
    80003362:	ec06                	sd	ra,24(sp)
    80003364:	e822                	sd	s0,16(sp)
    80003366:	e426                	sd	s1,8(sp)
    80003368:	1000                	addi	s0,sp,32
    8000336a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000336c:	0023a517          	auipc	a0,0x23a
    80003370:	48c50513          	addi	a0,a0,1164 # 8023d7f8 <bcache>
    80003374:	92dfd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    80003378:	40bc                	lw	a5,64(s1)
    8000337a:	2785                	addiw	a5,a5,1
    8000337c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000337e:	0023a517          	auipc	a0,0x23a
    80003382:	47a50513          	addi	a0,a0,1146 # 8023d7f8 <bcache>
    80003386:	9b3fd0ef          	jal	ra,80000d38 <release>
}
    8000338a:	60e2                	ld	ra,24(sp)
    8000338c:	6442                	ld	s0,16(sp)
    8000338e:	64a2                	ld	s1,8(sp)
    80003390:	6105                	addi	sp,sp,32
    80003392:	8082                	ret

0000000080003394 <bunpin>:

void
bunpin(struct buf *b) {
    80003394:	1101                	addi	sp,sp,-32
    80003396:	ec06                	sd	ra,24(sp)
    80003398:	e822                	sd	s0,16(sp)
    8000339a:	e426                	sd	s1,8(sp)
    8000339c:	1000                	addi	s0,sp,32
    8000339e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033a0:	0023a517          	auipc	a0,0x23a
    800033a4:	45850513          	addi	a0,a0,1112 # 8023d7f8 <bcache>
    800033a8:	8f9fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    800033ac:	40bc                	lw	a5,64(s1)
    800033ae:	37fd                	addiw	a5,a5,-1
    800033b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033b2:	0023a517          	auipc	a0,0x23a
    800033b6:	44650513          	addi	a0,a0,1094 # 8023d7f8 <bcache>
    800033ba:	97ffd0ef          	jal	ra,80000d38 <release>
}
    800033be:	60e2                	ld	ra,24(sp)
    800033c0:	6442                	ld	s0,16(sp)
    800033c2:	64a2                	ld	s1,8(sp)
    800033c4:	6105                	addi	sp,sp,32
    800033c6:	8082                	ret

00000000800033c8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033c8:	1101                	addi	sp,sp,-32
    800033ca:	ec06                	sd	ra,24(sp)
    800033cc:	e822                	sd	s0,16(sp)
    800033ce:	e426                	sd	s1,8(sp)
    800033d0:	e04a                	sd	s2,0(sp)
    800033d2:	1000                	addi	s0,sp,32
    800033d4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033d6:	00d5d59b          	srliw	a1,a1,0xd
    800033da:	00243797          	auipc	a5,0x243
    800033de:	afa7a783          	lw	a5,-1286(a5) # 80245ed4 <sb+0x1c>
    800033e2:	9dbd                	addw	a1,a1,a5
    800033e4:	debff0ef          	jal	ra,800031ce <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033e8:	0074f713          	andi	a4,s1,7
    800033ec:	4785                	li	a5,1
    800033ee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033f2:	14ce                	slli	s1,s1,0x33
    800033f4:	90d9                	srli	s1,s1,0x36
    800033f6:	00950733          	add	a4,a0,s1
    800033fa:	05874703          	lbu	a4,88(a4)
    800033fe:	00e7f6b3          	and	a3,a5,a4
    80003402:	c29d                	beqz	a3,80003428 <bfree+0x60>
    80003404:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003406:	94aa                	add	s1,s1,a0
    80003408:	fff7c793          	not	a5,a5
    8000340c:	8f7d                	and	a4,a4,a5
    8000340e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003412:	7d7000ef          	jal	ra,800043e8 <log_write>
  brelse(bp);
    80003416:	854a                	mv	a0,s2
    80003418:	ebfff0ef          	jal	ra,800032d6 <brelse>
}
    8000341c:	60e2                	ld	ra,24(sp)
    8000341e:	6442                	ld	s0,16(sp)
    80003420:	64a2                	ld	s1,8(sp)
    80003422:	6902                	ld	s2,0(sp)
    80003424:	6105                	addi	sp,sp,32
    80003426:	8082                	ret
    panic("freeing free block");
    80003428:	00004517          	auipc	a0,0x4
    8000342c:	0c850513          	addi	a0,a0,200 # 800074f0 <syscalls+0xf8>
    80003430:	b58fd0ef          	jal	ra,80000788 <panic>

0000000080003434 <balloc>:
{
    80003434:	711d                	addi	sp,sp,-96
    80003436:	ec86                	sd	ra,88(sp)
    80003438:	e8a2                	sd	s0,80(sp)
    8000343a:	e4a6                	sd	s1,72(sp)
    8000343c:	e0ca                	sd	s2,64(sp)
    8000343e:	fc4e                	sd	s3,56(sp)
    80003440:	f852                	sd	s4,48(sp)
    80003442:	f456                	sd	s5,40(sp)
    80003444:	f05a                	sd	s6,32(sp)
    80003446:	ec5e                	sd	s7,24(sp)
    80003448:	e862                	sd	s8,16(sp)
    8000344a:	e466                	sd	s9,8(sp)
    8000344c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000344e:	00243797          	auipc	a5,0x243
    80003452:	a6e7a783          	lw	a5,-1426(a5) # 80245ebc <sb+0x4>
    80003456:	cff1                	beqz	a5,80003532 <balloc+0xfe>
    80003458:	8baa                	mv	s7,a0
    8000345a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000345c:	00243b17          	auipc	s6,0x243
    80003460:	a5cb0b13          	addi	s6,s6,-1444 # 80245eb8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003464:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003466:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003468:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000346a:	6c89                	lui	s9,0x2
    8000346c:	a0b5                	j	800034d8 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000346e:	97ca                	add	a5,a5,s2
    80003470:	8e55                	or	a2,a2,a3
    80003472:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003476:	854a                	mv	a0,s2
    80003478:	771000ef          	jal	ra,800043e8 <log_write>
        brelse(bp);
    8000347c:	854a                	mv	a0,s2
    8000347e:	e59ff0ef          	jal	ra,800032d6 <brelse>
  bp = bread(dev, bno);
    80003482:	85a6                	mv	a1,s1
    80003484:	855e                	mv	a0,s7
    80003486:	d49ff0ef          	jal	ra,800031ce <bread>
    8000348a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000348c:	40000613          	li	a2,1024
    80003490:	4581                	li	a1,0
    80003492:	05850513          	addi	a0,a0,88
    80003496:	8dffd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    8000349a:	854a                	mv	a0,s2
    8000349c:	74d000ef          	jal	ra,800043e8 <log_write>
  brelse(bp);
    800034a0:	854a                	mv	a0,s2
    800034a2:	e35ff0ef          	jal	ra,800032d6 <brelse>
}
    800034a6:	8526                	mv	a0,s1
    800034a8:	60e6                	ld	ra,88(sp)
    800034aa:	6446                	ld	s0,80(sp)
    800034ac:	64a6                	ld	s1,72(sp)
    800034ae:	6906                	ld	s2,64(sp)
    800034b0:	79e2                	ld	s3,56(sp)
    800034b2:	7a42                	ld	s4,48(sp)
    800034b4:	7aa2                	ld	s5,40(sp)
    800034b6:	7b02                	ld	s6,32(sp)
    800034b8:	6be2                	ld	s7,24(sp)
    800034ba:	6c42                	ld	s8,16(sp)
    800034bc:	6ca2                	ld	s9,8(sp)
    800034be:	6125                	addi	sp,sp,96
    800034c0:	8082                	ret
    brelse(bp);
    800034c2:	854a                	mv	a0,s2
    800034c4:	e13ff0ef          	jal	ra,800032d6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034c8:	015c87bb          	addw	a5,s9,s5
    800034cc:	00078a9b          	sext.w	s5,a5
    800034d0:	004b2703          	lw	a4,4(s6)
    800034d4:	04eaff63          	bgeu	s5,a4,80003532 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    800034d8:	41fad79b          	sraiw	a5,s5,0x1f
    800034dc:	0137d79b          	srliw	a5,a5,0x13
    800034e0:	015787bb          	addw	a5,a5,s5
    800034e4:	40d7d79b          	sraiw	a5,a5,0xd
    800034e8:	01cb2583          	lw	a1,28(s6)
    800034ec:	9dbd                	addw	a1,a1,a5
    800034ee:	855e                	mv	a0,s7
    800034f0:	cdfff0ef          	jal	ra,800031ce <bread>
    800034f4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034f6:	004b2503          	lw	a0,4(s6)
    800034fa:	000a849b          	sext.w	s1,s5
    800034fe:	8762                	mv	a4,s8
    80003500:	fca4f1e3          	bgeu	s1,a0,800034c2 <balloc+0x8e>
      m = 1 << (bi % 8);
    80003504:	00777693          	andi	a3,a4,7
    80003508:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000350c:	41f7579b          	sraiw	a5,a4,0x1f
    80003510:	01d7d79b          	srliw	a5,a5,0x1d
    80003514:	9fb9                	addw	a5,a5,a4
    80003516:	4037d79b          	sraiw	a5,a5,0x3
    8000351a:	00f90633          	add	a2,s2,a5
    8000351e:	05864603          	lbu	a2,88(a2) # fffffffffffff058 <end+0xffffffff7fdb6498>
    80003522:	00c6f5b3          	and	a1,a3,a2
    80003526:	d5a1                	beqz	a1,8000346e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003528:	2705                	addiw	a4,a4,1
    8000352a:	2485                	addiw	s1,s1,1
    8000352c:	fd471ae3          	bne	a4,s4,80003500 <balloc+0xcc>
    80003530:	bf49                	j	800034c2 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003532:	00004517          	auipc	a0,0x4
    80003536:	fd650513          	addi	a0,a0,-42 # 80007508 <syscalls+0x110>
    8000353a:	f89fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    8000353e:	4481                	li	s1,0
    80003540:	b79d                	j	800034a6 <balloc+0x72>

0000000080003542 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003542:	7179                	addi	sp,sp,-48
    80003544:	f406                	sd	ra,40(sp)
    80003546:	f022                	sd	s0,32(sp)
    80003548:	ec26                	sd	s1,24(sp)
    8000354a:	e84a                	sd	s2,16(sp)
    8000354c:	e44e                	sd	s3,8(sp)
    8000354e:	e052                	sd	s4,0(sp)
    80003550:	1800                	addi	s0,sp,48
    80003552:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003554:	47ad                	li	a5,11
    80003556:	02b7e663          	bltu	a5,a1,80003582 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000355a:	02059793          	slli	a5,a1,0x20
    8000355e:	01e7d593          	srli	a1,a5,0x1e
    80003562:	00b504b3          	add	s1,a0,a1
    80003566:	0504a903          	lw	s2,80(s1)
    8000356a:	06091663          	bnez	s2,800035d6 <bmap+0x94>
      addr = balloc(ip->dev);
    8000356e:	4108                	lw	a0,0(a0)
    80003570:	ec5ff0ef          	jal	ra,80003434 <balloc>
    80003574:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003578:	04090f63          	beqz	s2,800035d6 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    8000357c:	0524a823          	sw	s2,80(s1)
    80003580:	a899                	j	800035d6 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003582:	ff45849b          	addiw	s1,a1,-12
    80003586:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000358a:	0ff00793          	li	a5,255
    8000358e:	06e7eb63          	bltu	a5,a4,80003604 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003592:	08052903          	lw	s2,128(a0)
    80003596:	00091b63          	bnez	s2,800035ac <bmap+0x6a>
      addr = balloc(ip->dev);
    8000359a:	4108                	lw	a0,0(a0)
    8000359c:	e99ff0ef          	jal	ra,80003434 <balloc>
    800035a0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035a4:	02090963          	beqz	s2,800035d6 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035a8:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800035ac:	85ca                	mv	a1,s2
    800035ae:	0009a503          	lw	a0,0(s3)
    800035b2:	c1dff0ef          	jal	ra,800031ce <bread>
    800035b6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035b8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035bc:	02049713          	slli	a4,s1,0x20
    800035c0:	01e75593          	srli	a1,a4,0x1e
    800035c4:	00b784b3          	add	s1,a5,a1
    800035c8:	0004a903          	lw	s2,0(s1)
    800035cc:	00090e63          	beqz	s2,800035e8 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035d0:	8552                	mv	a0,s4
    800035d2:	d05ff0ef          	jal	ra,800032d6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035d6:	854a                	mv	a0,s2
    800035d8:	70a2                	ld	ra,40(sp)
    800035da:	7402                	ld	s0,32(sp)
    800035dc:	64e2                	ld	s1,24(sp)
    800035de:	6942                	ld	s2,16(sp)
    800035e0:	69a2                	ld	s3,8(sp)
    800035e2:	6a02                	ld	s4,0(sp)
    800035e4:	6145                	addi	sp,sp,48
    800035e6:	8082                	ret
      addr = balloc(ip->dev);
    800035e8:	0009a503          	lw	a0,0(s3)
    800035ec:	e49ff0ef          	jal	ra,80003434 <balloc>
    800035f0:	0005091b          	sext.w	s2,a0
      if(addr){
    800035f4:	fc090ee3          	beqz	s2,800035d0 <bmap+0x8e>
        a[bn] = addr;
    800035f8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035fc:	8552                	mv	a0,s4
    800035fe:	5eb000ef          	jal	ra,800043e8 <log_write>
    80003602:	b7f9                	j	800035d0 <bmap+0x8e>
  panic("bmap: out of range");
    80003604:	00004517          	auipc	a0,0x4
    80003608:	f1c50513          	addi	a0,a0,-228 # 80007520 <syscalls+0x128>
    8000360c:	97cfd0ef          	jal	ra,80000788 <panic>

0000000080003610 <iget>:
{
    80003610:	7179                	addi	sp,sp,-48
    80003612:	f406                	sd	ra,40(sp)
    80003614:	f022                	sd	s0,32(sp)
    80003616:	ec26                	sd	s1,24(sp)
    80003618:	e84a                	sd	s2,16(sp)
    8000361a:	e44e                	sd	s3,8(sp)
    8000361c:	e052                	sd	s4,0(sp)
    8000361e:	1800                	addi	s0,sp,48
    80003620:	89aa                	mv	s3,a0
    80003622:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003624:	00243517          	auipc	a0,0x243
    80003628:	8b450513          	addi	a0,a0,-1868 # 80245ed8 <itable>
    8000362c:	e74fd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003630:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003632:	00243497          	auipc	s1,0x243
    80003636:	8be48493          	addi	s1,s1,-1858 # 80245ef0 <itable+0x18>
    8000363a:	00244697          	auipc	a3,0x244
    8000363e:	34668693          	addi	a3,a3,838 # 80247980 <log>
    80003642:	a039                	j	80003650 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003644:	02090963          	beqz	s2,80003676 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003648:	08848493          	addi	s1,s1,136
    8000364c:	02d48863          	beq	s1,a3,8000367c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003650:	449c                	lw	a5,8(s1)
    80003652:	fef059e3          	blez	a5,80003644 <iget+0x34>
    80003656:	4098                	lw	a4,0(s1)
    80003658:	ff3716e3          	bne	a4,s3,80003644 <iget+0x34>
    8000365c:	40d8                	lw	a4,4(s1)
    8000365e:	ff4713e3          	bne	a4,s4,80003644 <iget+0x34>
      ip->ref++;
    80003662:	2785                	addiw	a5,a5,1
    80003664:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003666:	00243517          	auipc	a0,0x243
    8000366a:	87250513          	addi	a0,a0,-1934 # 80245ed8 <itable>
    8000366e:	ecafd0ef          	jal	ra,80000d38 <release>
      return ip;
    80003672:	8926                	mv	s2,s1
    80003674:	a02d                	j	8000369e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003676:	fbe9                	bnez	a5,80003648 <iget+0x38>
    80003678:	8926                	mv	s2,s1
    8000367a:	b7f9                	j	80003648 <iget+0x38>
  if(empty == 0)
    8000367c:	02090a63          	beqz	s2,800036b0 <iget+0xa0>
  ip->dev = dev;
    80003680:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003684:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003688:	4785                	li	a5,1
    8000368a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000368e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003692:	00243517          	auipc	a0,0x243
    80003696:	84650513          	addi	a0,a0,-1978 # 80245ed8 <itable>
    8000369a:	e9efd0ef          	jal	ra,80000d38 <release>
}
    8000369e:	854a                	mv	a0,s2
    800036a0:	70a2                	ld	ra,40(sp)
    800036a2:	7402                	ld	s0,32(sp)
    800036a4:	64e2                	ld	s1,24(sp)
    800036a6:	6942                	ld	s2,16(sp)
    800036a8:	69a2                	ld	s3,8(sp)
    800036aa:	6a02                	ld	s4,0(sp)
    800036ac:	6145                	addi	sp,sp,48
    800036ae:	8082                	ret
    panic("iget: no inodes");
    800036b0:	00004517          	auipc	a0,0x4
    800036b4:	e8850513          	addi	a0,a0,-376 # 80007538 <syscalls+0x140>
    800036b8:	8d0fd0ef          	jal	ra,80000788 <panic>

00000000800036bc <iinit>:
{
    800036bc:	7179                	addi	sp,sp,-48
    800036be:	f406                	sd	ra,40(sp)
    800036c0:	f022                	sd	s0,32(sp)
    800036c2:	ec26                	sd	s1,24(sp)
    800036c4:	e84a                	sd	s2,16(sp)
    800036c6:	e44e                	sd	s3,8(sp)
    800036c8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036ca:	00004597          	auipc	a1,0x4
    800036ce:	e7e58593          	addi	a1,a1,-386 # 80007548 <syscalls+0x150>
    800036d2:	00243517          	auipc	a0,0x243
    800036d6:	80650513          	addi	a0,a0,-2042 # 80245ed8 <itable>
    800036da:	d46fd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036de:	00243497          	auipc	s1,0x243
    800036e2:	82248493          	addi	s1,s1,-2014 # 80245f00 <itable+0x28>
    800036e6:	00244997          	auipc	s3,0x244
    800036ea:	2aa98993          	addi	s3,s3,682 # 80247990 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036ee:	00004917          	auipc	s2,0x4
    800036f2:	e6290913          	addi	s2,s2,-414 # 80007550 <syscalls+0x158>
    800036f6:	85ca                	mv	a1,s2
    800036f8:	8526                	mv	a0,s1
    800036fa:	5b1000ef          	jal	ra,800044aa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036fe:	08848493          	addi	s1,s1,136
    80003702:	ff349ae3          	bne	s1,s3,800036f6 <iinit+0x3a>
}
    80003706:	70a2                	ld	ra,40(sp)
    80003708:	7402                	ld	s0,32(sp)
    8000370a:	64e2                	ld	s1,24(sp)
    8000370c:	6942                	ld	s2,16(sp)
    8000370e:	69a2                	ld	s3,8(sp)
    80003710:	6145                	addi	sp,sp,48
    80003712:	8082                	ret

0000000080003714 <ialloc>:
{
    80003714:	715d                	addi	sp,sp,-80
    80003716:	e486                	sd	ra,72(sp)
    80003718:	e0a2                	sd	s0,64(sp)
    8000371a:	fc26                	sd	s1,56(sp)
    8000371c:	f84a                	sd	s2,48(sp)
    8000371e:	f44e                	sd	s3,40(sp)
    80003720:	f052                	sd	s4,32(sp)
    80003722:	ec56                	sd	s5,24(sp)
    80003724:	e85a                	sd	s6,16(sp)
    80003726:	e45e                	sd	s7,8(sp)
    80003728:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000372a:	00242717          	auipc	a4,0x242
    8000372e:	79a72703          	lw	a4,1946(a4) # 80245ec4 <sb+0xc>
    80003732:	4785                	li	a5,1
    80003734:	04e7f663          	bgeu	a5,a4,80003780 <ialloc+0x6c>
    80003738:	8aaa                	mv	s5,a0
    8000373a:	8bae                	mv	s7,a1
    8000373c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000373e:	00242a17          	auipc	s4,0x242
    80003742:	77aa0a13          	addi	s4,s4,1914 # 80245eb8 <sb>
    80003746:	00048b1b          	sext.w	s6,s1
    8000374a:	0044d593          	srli	a1,s1,0x4
    8000374e:	018a2783          	lw	a5,24(s4)
    80003752:	9dbd                	addw	a1,a1,a5
    80003754:	8556                	mv	a0,s5
    80003756:	a79ff0ef          	jal	ra,800031ce <bread>
    8000375a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000375c:	05850993          	addi	s3,a0,88
    80003760:	00f4f793          	andi	a5,s1,15
    80003764:	079a                	slli	a5,a5,0x6
    80003766:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003768:	00099783          	lh	a5,0(s3)
    8000376c:	cf85                	beqz	a5,800037a4 <ialloc+0x90>
    brelse(bp);
    8000376e:	b69ff0ef          	jal	ra,800032d6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003772:	0485                	addi	s1,s1,1
    80003774:	00ca2703          	lw	a4,12(s4)
    80003778:	0004879b          	sext.w	a5,s1
    8000377c:	fce7e5e3          	bltu	a5,a4,80003746 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003780:	00004517          	auipc	a0,0x4
    80003784:	dd850513          	addi	a0,a0,-552 # 80007558 <syscalls+0x160>
    80003788:	d3bfc0ef          	jal	ra,800004c2 <printf>
  return 0;
    8000378c:	4501                	li	a0,0
}
    8000378e:	60a6                	ld	ra,72(sp)
    80003790:	6406                	ld	s0,64(sp)
    80003792:	74e2                	ld	s1,56(sp)
    80003794:	7942                	ld	s2,48(sp)
    80003796:	79a2                	ld	s3,40(sp)
    80003798:	7a02                	ld	s4,32(sp)
    8000379a:	6ae2                	ld	s5,24(sp)
    8000379c:	6b42                	ld	s6,16(sp)
    8000379e:	6ba2                	ld	s7,8(sp)
    800037a0:	6161                	addi	sp,sp,80
    800037a2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037a4:	04000613          	li	a2,64
    800037a8:	4581                	li	a1,0
    800037aa:	854e                	mv	a0,s3
    800037ac:	dc8fd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    800037b0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037b4:	854a                	mv	a0,s2
    800037b6:	433000ef          	jal	ra,800043e8 <log_write>
      brelse(bp);
    800037ba:	854a                	mv	a0,s2
    800037bc:	b1bff0ef          	jal	ra,800032d6 <brelse>
      return iget(dev, inum);
    800037c0:	85da                	mv	a1,s6
    800037c2:	8556                	mv	a0,s5
    800037c4:	e4dff0ef          	jal	ra,80003610 <iget>
    800037c8:	b7d9                	j	8000378e <ialloc+0x7a>

00000000800037ca <iupdate>:
{
    800037ca:	1101                	addi	sp,sp,-32
    800037cc:	ec06                	sd	ra,24(sp)
    800037ce:	e822                	sd	s0,16(sp)
    800037d0:	e426                	sd	s1,8(sp)
    800037d2:	e04a                	sd	s2,0(sp)
    800037d4:	1000                	addi	s0,sp,32
    800037d6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037d8:	415c                	lw	a5,4(a0)
    800037da:	0047d79b          	srliw	a5,a5,0x4
    800037de:	00242597          	auipc	a1,0x242
    800037e2:	6f25a583          	lw	a1,1778(a1) # 80245ed0 <sb+0x18>
    800037e6:	9dbd                	addw	a1,a1,a5
    800037e8:	4108                	lw	a0,0(a0)
    800037ea:	9e5ff0ef          	jal	ra,800031ce <bread>
    800037ee:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037f0:	05850793          	addi	a5,a0,88
    800037f4:	40d8                	lw	a4,4(s1)
    800037f6:	8b3d                	andi	a4,a4,15
    800037f8:	071a                	slli	a4,a4,0x6
    800037fa:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037fc:	04449703          	lh	a4,68(s1)
    80003800:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003804:	04649703          	lh	a4,70(s1)
    80003808:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000380c:	04849703          	lh	a4,72(s1)
    80003810:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003814:	04a49703          	lh	a4,74(s1)
    80003818:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000381c:	44f8                	lw	a4,76(s1)
    8000381e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003820:	03400613          	li	a2,52
    80003824:	05048593          	addi	a1,s1,80
    80003828:	00c78513          	addi	a0,a5,12
    8000382c:	da4fd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003830:	854a                	mv	a0,s2
    80003832:	3b7000ef          	jal	ra,800043e8 <log_write>
  brelse(bp);
    80003836:	854a                	mv	a0,s2
    80003838:	a9fff0ef          	jal	ra,800032d6 <brelse>
}
    8000383c:	60e2                	ld	ra,24(sp)
    8000383e:	6442                	ld	s0,16(sp)
    80003840:	64a2                	ld	s1,8(sp)
    80003842:	6902                	ld	s2,0(sp)
    80003844:	6105                	addi	sp,sp,32
    80003846:	8082                	ret

0000000080003848 <idup>:
{
    80003848:	1101                	addi	sp,sp,-32
    8000384a:	ec06                	sd	ra,24(sp)
    8000384c:	e822                	sd	s0,16(sp)
    8000384e:	e426                	sd	s1,8(sp)
    80003850:	1000                	addi	s0,sp,32
    80003852:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003854:	00242517          	auipc	a0,0x242
    80003858:	68450513          	addi	a0,a0,1668 # 80245ed8 <itable>
    8000385c:	c44fd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003860:	449c                	lw	a5,8(s1)
    80003862:	2785                	addiw	a5,a5,1
    80003864:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003866:	00242517          	auipc	a0,0x242
    8000386a:	67250513          	addi	a0,a0,1650 # 80245ed8 <itable>
    8000386e:	ccafd0ef          	jal	ra,80000d38 <release>
}
    80003872:	8526                	mv	a0,s1
    80003874:	60e2                	ld	ra,24(sp)
    80003876:	6442                	ld	s0,16(sp)
    80003878:	64a2                	ld	s1,8(sp)
    8000387a:	6105                	addi	sp,sp,32
    8000387c:	8082                	ret

000000008000387e <ilock>:
{
    8000387e:	1101                	addi	sp,sp,-32
    80003880:	ec06                	sd	ra,24(sp)
    80003882:	e822                	sd	s0,16(sp)
    80003884:	e426                	sd	s1,8(sp)
    80003886:	e04a                	sd	s2,0(sp)
    80003888:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000388a:	c105                	beqz	a0,800038aa <ilock+0x2c>
    8000388c:	84aa                	mv	s1,a0
    8000388e:	451c                	lw	a5,8(a0)
    80003890:	00f05d63          	blez	a5,800038aa <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003894:	0541                	addi	a0,a0,16
    80003896:	44b000ef          	jal	ra,800044e0 <acquiresleep>
  if(ip->valid == 0){
    8000389a:	40bc                	lw	a5,64(s1)
    8000389c:	cf89                	beqz	a5,800038b6 <ilock+0x38>
}
    8000389e:	60e2                	ld	ra,24(sp)
    800038a0:	6442                	ld	s0,16(sp)
    800038a2:	64a2                	ld	s1,8(sp)
    800038a4:	6902                	ld	s2,0(sp)
    800038a6:	6105                	addi	sp,sp,32
    800038a8:	8082                	ret
    panic("ilock");
    800038aa:	00004517          	auipc	a0,0x4
    800038ae:	cc650513          	addi	a0,a0,-826 # 80007570 <syscalls+0x178>
    800038b2:	ed7fc0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038b6:	40dc                	lw	a5,4(s1)
    800038b8:	0047d79b          	srliw	a5,a5,0x4
    800038bc:	00242597          	auipc	a1,0x242
    800038c0:	6145a583          	lw	a1,1556(a1) # 80245ed0 <sb+0x18>
    800038c4:	9dbd                	addw	a1,a1,a5
    800038c6:	4088                	lw	a0,0(s1)
    800038c8:	907ff0ef          	jal	ra,800031ce <bread>
    800038cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038ce:	05850593          	addi	a1,a0,88
    800038d2:	40dc                	lw	a5,4(s1)
    800038d4:	8bbd                	andi	a5,a5,15
    800038d6:	079a                	slli	a5,a5,0x6
    800038d8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038da:	00059783          	lh	a5,0(a1)
    800038de:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038e2:	00259783          	lh	a5,2(a1)
    800038e6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038ea:	00459783          	lh	a5,4(a1)
    800038ee:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038f2:	00659783          	lh	a5,6(a1)
    800038f6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038fa:	459c                	lw	a5,8(a1)
    800038fc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038fe:	03400613          	li	a2,52
    80003902:	05b1                	addi	a1,a1,12
    80003904:	05048513          	addi	a0,s1,80
    80003908:	cc8fd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    8000390c:	854a                	mv	a0,s2
    8000390e:	9c9ff0ef          	jal	ra,800032d6 <brelse>
    ip->valid = 1;
    80003912:	4785                	li	a5,1
    80003914:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003916:	04449783          	lh	a5,68(s1)
    8000391a:	f3d1                	bnez	a5,8000389e <ilock+0x20>
      panic("ilock: no type");
    8000391c:	00004517          	auipc	a0,0x4
    80003920:	c5c50513          	addi	a0,a0,-932 # 80007578 <syscalls+0x180>
    80003924:	e65fc0ef          	jal	ra,80000788 <panic>

0000000080003928 <iunlock>:
{
    80003928:	1101                	addi	sp,sp,-32
    8000392a:	ec06                	sd	ra,24(sp)
    8000392c:	e822                	sd	s0,16(sp)
    8000392e:	e426                	sd	s1,8(sp)
    80003930:	e04a                	sd	s2,0(sp)
    80003932:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003934:	c505                	beqz	a0,8000395c <iunlock+0x34>
    80003936:	84aa                	mv	s1,a0
    80003938:	01050913          	addi	s2,a0,16
    8000393c:	854a                	mv	a0,s2
    8000393e:	421000ef          	jal	ra,8000455e <holdingsleep>
    80003942:	cd09                	beqz	a0,8000395c <iunlock+0x34>
    80003944:	449c                	lw	a5,8(s1)
    80003946:	00f05b63          	blez	a5,8000395c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000394a:	854a                	mv	a0,s2
    8000394c:	3db000ef          	jal	ra,80004526 <releasesleep>
}
    80003950:	60e2                	ld	ra,24(sp)
    80003952:	6442                	ld	s0,16(sp)
    80003954:	64a2                	ld	s1,8(sp)
    80003956:	6902                	ld	s2,0(sp)
    80003958:	6105                	addi	sp,sp,32
    8000395a:	8082                	ret
    panic("iunlock");
    8000395c:	00004517          	auipc	a0,0x4
    80003960:	c2c50513          	addi	a0,a0,-980 # 80007588 <syscalls+0x190>
    80003964:	e25fc0ef          	jal	ra,80000788 <panic>

0000000080003968 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003968:	7179                	addi	sp,sp,-48
    8000396a:	f406                	sd	ra,40(sp)
    8000396c:	f022                	sd	s0,32(sp)
    8000396e:	ec26                	sd	s1,24(sp)
    80003970:	e84a                	sd	s2,16(sp)
    80003972:	e44e                	sd	s3,8(sp)
    80003974:	e052                	sd	s4,0(sp)
    80003976:	1800                	addi	s0,sp,48
    80003978:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000397a:	05050493          	addi	s1,a0,80
    8000397e:	08050913          	addi	s2,a0,128
    80003982:	a021                	j	8000398a <itrunc+0x22>
    80003984:	0491                	addi	s1,s1,4
    80003986:	01248b63          	beq	s1,s2,8000399c <itrunc+0x34>
    if(ip->addrs[i]){
    8000398a:	408c                	lw	a1,0(s1)
    8000398c:	dde5                	beqz	a1,80003984 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000398e:	0009a503          	lw	a0,0(s3)
    80003992:	a37ff0ef          	jal	ra,800033c8 <bfree>
      ip->addrs[i] = 0;
    80003996:	0004a023          	sw	zero,0(s1)
    8000399a:	b7ed                	j	80003984 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000399c:	0809a583          	lw	a1,128(s3)
    800039a0:	ed91                	bnez	a1,800039bc <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039a2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039a6:	854e                	mv	a0,s3
    800039a8:	e23ff0ef          	jal	ra,800037ca <iupdate>
}
    800039ac:	70a2                	ld	ra,40(sp)
    800039ae:	7402                	ld	s0,32(sp)
    800039b0:	64e2                	ld	s1,24(sp)
    800039b2:	6942                	ld	s2,16(sp)
    800039b4:	69a2                	ld	s3,8(sp)
    800039b6:	6a02                	ld	s4,0(sp)
    800039b8:	6145                	addi	sp,sp,48
    800039ba:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039bc:	0009a503          	lw	a0,0(s3)
    800039c0:	80fff0ef          	jal	ra,800031ce <bread>
    800039c4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039c6:	05850493          	addi	s1,a0,88
    800039ca:	45850913          	addi	s2,a0,1112
    800039ce:	a021                	j	800039d6 <itrunc+0x6e>
    800039d0:	0491                	addi	s1,s1,4
    800039d2:	01248963          	beq	s1,s2,800039e4 <itrunc+0x7c>
      if(a[j])
    800039d6:	408c                	lw	a1,0(s1)
    800039d8:	dde5                	beqz	a1,800039d0 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800039da:	0009a503          	lw	a0,0(s3)
    800039de:	9ebff0ef          	jal	ra,800033c8 <bfree>
    800039e2:	b7fd                	j	800039d0 <itrunc+0x68>
    brelse(bp);
    800039e4:	8552                	mv	a0,s4
    800039e6:	8f1ff0ef          	jal	ra,800032d6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800039ea:	0809a583          	lw	a1,128(s3)
    800039ee:	0009a503          	lw	a0,0(s3)
    800039f2:	9d7ff0ef          	jal	ra,800033c8 <bfree>
    ip->addrs[NDIRECT] = 0;
    800039f6:	0809a023          	sw	zero,128(s3)
    800039fa:	b765                	j	800039a2 <itrunc+0x3a>

00000000800039fc <iput>:
{
    800039fc:	1101                	addi	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	e04a                	sd	s2,0(sp)
    80003a06:	1000                	addi	s0,sp,32
    80003a08:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a0a:	00242517          	auipc	a0,0x242
    80003a0e:	4ce50513          	addi	a0,a0,1230 # 80245ed8 <itable>
    80003a12:	a8efd0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a16:	4498                	lw	a4,8(s1)
    80003a18:	4785                	li	a5,1
    80003a1a:	02f70163          	beq	a4,a5,80003a3c <iput+0x40>
  ip->ref--;
    80003a1e:	449c                	lw	a5,8(s1)
    80003a20:	37fd                	addiw	a5,a5,-1
    80003a22:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a24:	00242517          	auipc	a0,0x242
    80003a28:	4b450513          	addi	a0,a0,1204 # 80245ed8 <itable>
    80003a2c:	b0cfd0ef          	jal	ra,80000d38 <release>
}
    80003a30:	60e2                	ld	ra,24(sp)
    80003a32:	6442                	ld	s0,16(sp)
    80003a34:	64a2                	ld	s1,8(sp)
    80003a36:	6902                	ld	s2,0(sp)
    80003a38:	6105                	addi	sp,sp,32
    80003a3a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a3c:	40bc                	lw	a5,64(s1)
    80003a3e:	d3e5                	beqz	a5,80003a1e <iput+0x22>
    80003a40:	04a49783          	lh	a5,74(s1)
    80003a44:	ffe9                	bnez	a5,80003a1e <iput+0x22>
    acquiresleep(&ip->lock);
    80003a46:	01048913          	addi	s2,s1,16
    80003a4a:	854a                	mv	a0,s2
    80003a4c:	295000ef          	jal	ra,800044e0 <acquiresleep>
    release(&itable.lock);
    80003a50:	00242517          	auipc	a0,0x242
    80003a54:	48850513          	addi	a0,a0,1160 # 80245ed8 <itable>
    80003a58:	ae0fd0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    80003a5c:	8526                	mv	a0,s1
    80003a5e:	f0bff0ef          	jal	ra,80003968 <itrunc>
    ip->type = 0;
    80003a62:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a66:	8526                	mv	a0,s1
    80003a68:	d63ff0ef          	jal	ra,800037ca <iupdate>
    ip->valid = 0;
    80003a6c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a70:	854a                	mv	a0,s2
    80003a72:	2b5000ef          	jal	ra,80004526 <releasesleep>
    acquire(&itable.lock);
    80003a76:	00242517          	auipc	a0,0x242
    80003a7a:	46250513          	addi	a0,a0,1122 # 80245ed8 <itable>
    80003a7e:	a22fd0ef          	jal	ra,80000ca0 <acquire>
    80003a82:	bf71                	j	80003a1e <iput+0x22>

0000000080003a84 <iunlockput>:
{
    80003a84:	1101                	addi	sp,sp,-32
    80003a86:	ec06                	sd	ra,24(sp)
    80003a88:	e822                	sd	s0,16(sp)
    80003a8a:	e426                	sd	s1,8(sp)
    80003a8c:	1000                	addi	s0,sp,32
    80003a8e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a90:	e99ff0ef          	jal	ra,80003928 <iunlock>
  iput(ip);
    80003a94:	8526                	mv	a0,s1
    80003a96:	f67ff0ef          	jal	ra,800039fc <iput>
}
    80003a9a:	60e2                	ld	ra,24(sp)
    80003a9c:	6442                	ld	s0,16(sp)
    80003a9e:	64a2                	ld	s1,8(sp)
    80003aa0:	6105                	addi	sp,sp,32
    80003aa2:	8082                	ret

0000000080003aa4 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003aa4:	00242717          	auipc	a4,0x242
    80003aa8:	42072703          	lw	a4,1056(a4) # 80245ec4 <sb+0xc>
    80003aac:	4785                	li	a5,1
    80003aae:	0ae7ff63          	bgeu	a5,a4,80003b6c <ireclaim+0xc8>
{
    80003ab2:	7139                	addi	sp,sp,-64
    80003ab4:	fc06                	sd	ra,56(sp)
    80003ab6:	f822                	sd	s0,48(sp)
    80003ab8:	f426                	sd	s1,40(sp)
    80003aba:	f04a                	sd	s2,32(sp)
    80003abc:	ec4e                	sd	s3,24(sp)
    80003abe:	e852                	sd	s4,16(sp)
    80003ac0:	e456                	sd	s5,8(sp)
    80003ac2:	e05a                	sd	s6,0(sp)
    80003ac4:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ac6:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ac8:	00050a1b          	sext.w	s4,a0
    80003acc:	00242a97          	auipc	s5,0x242
    80003ad0:	3eca8a93          	addi	s5,s5,1004 # 80245eb8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003ad4:	00004b17          	auipc	s6,0x4
    80003ad8:	abcb0b13          	addi	s6,s6,-1348 # 80007590 <syscalls+0x198>
    80003adc:	a099                	j	80003b22 <ireclaim+0x7e>
    80003ade:	85ce                	mv	a1,s3
    80003ae0:	855a                	mv	a0,s6
    80003ae2:	9e1fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80003ae6:	85ce                	mv	a1,s3
    80003ae8:	8552                	mv	a0,s4
    80003aea:	b27ff0ef          	jal	ra,80003610 <iget>
    80003aee:	89aa                	mv	s3,a0
    brelse(bp);
    80003af0:	854a                	mv	a0,s2
    80003af2:	fe4ff0ef          	jal	ra,800032d6 <brelse>
    if (ip) {
    80003af6:	00098f63          	beqz	s3,80003b14 <ireclaim+0x70>
      begin_op();
    80003afa:	76c000ef          	jal	ra,80004266 <begin_op>
      ilock(ip);
    80003afe:	854e                	mv	a0,s3
    80003b00:	d7fff0ef          	jal	ra,8000387e <ilock>
      iunlock(ip);
    80003b04:	854e                	mv	a0,s3
    80003b06:	e23ff0ef          	jal	ra,80003928 <iunlock>
      iput(ip);
    80003b0a:	854e                	mv	a0,s3
    80003b0c:	ef1ff0ef          	jal	ra,800039fc <iput>
      end_op();
    80003b10:	7c4000ef          	jal	ra,800042d4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b14:	0485                	addi	s1,s1,1
    80003b16:	00caa703          	lw	a4,12(s5)
    80003b1a:	0004879b          	sext.w	a5,s1
    80003b1e:	02e7fd63          	bgeu	a5,a4,80003b58 <ireclaim+0xb4>
    80003b22:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003b26:	0044d593          	srli	a1,s1,0x4
    80003b2a:	018aa783          	lw	a5,24(s5)
    80003b2e:	9dbd                	addw	a1,a1,a5
    80003b30:	8552                	mv	a0,s4
    80003b32:	e9cff0ef          	jal	ra,800031ce <bread>
    80003b36:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003b38:	05850793          	addi	a5,a0,88
    80003b3c:	00f9f713          	andi	a4,s3,15
    80003b40:	071a                	slli	a4,a4,0x6
    80003b42:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003b44:	00079703          	lh	a4,0(a5)
    80003b48:	c701                	beqz	a4,80003b50 <ireclaim+0xac>
    80003b4a:	00679783          	lh	a5,6(a5)
    80003b4e:	dbc1                	beqz	a5,80003ade <ireclaim+0x3a>
    brelse(bp);
    80003b50:	854a                	mv	a0,s2
    80003b52:	f84ff0ef          	jal	ra,800032d6 <brelse>
    if (ip) {
    80003b56:	bf7d                	j	80003b14 <ireclaim+0x70>
}
    80003b58:	70e2                	ld	ra,56(sp)
    80003b5a:	7442                	ld	s0,48(sp)
    80003b5c:	74a2                	ld	s1,40(sp)
    80003b5e:	7902                	ld	s2,32(sp)
    80003b60:	69e2                	ld	s3,24(sp)
    80003b62:	6a42                	ld	s4,16(sp)
    80003b64:	6aa2                	ld	s5,8(sp)
    80003b66:	6b02                	ld	s6,0(sp)
    80003b68:	6121                	addi	sp,sp,64
    80003b6a:	8082                	ret
    80003b6c:	8082                	ret

0000000080003b6e <fsinit>:
fsinit(int dev) {
    80003b6e:	7179                	addi	sp,sp,-48
    80003b70:	f406                	sd	ra,40(sp)
    80003b72:	f022                	sd	s0,32(sp)
    80003b74:	ec26                	sd	s1,24(sp)
    80003b76:	e84a                	sd	s2,16(sp)
    80003b78:	e44e                	sd	s3,8(sp)
    80003b7a:	1800                	addi	s0,sp,48
    80003b7c:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003b7e:	4585                	li	a1,1
    80003b80:	e4eff0ef          	jal	ra,800031ce <bread>
    80003b84:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b86:	00242997          	auipc	s3,0x242
    80003b8a:	33298993          	addi	s3,s3,818 # 80245eb8 <sb>
    80003b8e:	02000613          	li	a2,32
    80003b92:	05850593          	addi	a1,a0,88
    80003b96:	854e                	mv	a0,s3
    80003b98:	a38fd0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    80003b9c:	854a                	mv	a0,s2
    80003b9e:	f38ff0ef          	jal	ra,800032d6 <brelse>
  if(sb.magic != FSMAGIC)
    80003ba2:	0009a703          	lw	a4,0(s3)
    80003ba6:	102037b7          	lui	a5,0x10203
    80003baa:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003bae:	02f71363          	bne	a4,a5,80003bd4 <fsinit+0x66>
  initlog(dev, &sb);
    80003bb2:	00242597          	auipc	a1,0x242
    80003bb6:	30658593          	addi	a1,a1,774 # 80245eb8 <sb>
    80003bba:	8526                	mv	a0,s1
    80003bbc:	61e000ef          	jal	ra,800041da <initlog>
  ireclaim(dev);
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	ee3ff0ef          	jal	ra,80003aa4 <ireclaim>
}
    80003bc6:	70a2                	ld	ra,40(sp)
    80003bc8:	7402                	ld	s0,32(sp)
    80003bca:	64e2                	ld	s1,24(sp)
    80003bcc:	6942                	ld	s2,16(sp)
    80003bce:	69a2                	ld	s3,8(sp)
    80003bd0:	6145                	addi	sp,sp,48
    80003bd2:	8082                	ret
    panic("invalid file system");
    80003bd4:	00004517          	auipc	a0,0x4
    80003bd8:	9dc50513          	addi	a0,a0,-1572 # 800075b0 <syscalls+0x1b8>
    80003bdc:	badfc0ef          	jal	ra,80000788 <panic>

0000000080003be0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003be0:	1141                	addi	sp,sp,-16
    80003be2:	e422                	sd	s0,8(sp)
    80003be4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003be6:	411c                	lw	a5,0(a0)
    80003be8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bea:	415c                	lw	a5,4(a0)
    80003bec:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bee:	04451783          	lh	a5,68(a0)
    80003bf2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bf6:	04a51783          	lh	a5,74(a0)
    80003bfa:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bfe:	04c56783          	lwu	a5,76(a0)
    80003c02:	e99c                	sd	a5,16(a1)
}
    80003c04:	6422                	ld	s0,8(sp)
    80003c06:	0141                	addi	sp,sp,16
    80003c08:	8082                	ret

0000000080003c0a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c0a:	457c                	lw	a5,76(a0)
    80003c0c:	0cd7ef63          	bltu	a5,a3,80003cea <readi+0xe0>
{
    80003c10:	7159                	addi	sp,sp,-112
    80003c12:	f486                	sd	ra,104(sp)
    80003c14:	f0a2                	sd	s0,96(sp)
    80003c16:	eca6                	sd	s1,88(sp)
    80003c18:	e8ca                	sd	s2,80(sp)
    80003c1a:	e4ce                	sd	s3,72(sp)
    80003c1c:	e0d2                	sd	s4,64(sp)
    80003c1e:	fc56                	sd	s5,56(sp)
    80003c20:	f85a                	sd	s6,48(sp)
    80003c22:	f45e                	sd	s7,40(sp)
    80003c24:	f062                	sd	s8,32(sp)
    80003c26:	ec66                	sd	s9,24(sp)
    80003c28:	e86a                	sd	s10,16(sp)
    80003c2a:	e46e                	sd	s11,8(sp)
    80003c2c:	1880                	addi	s0,sp,112
    80003c2e:	8b2a                	mv	s6,a0
    80003c30:	8bae                	mv	s7,a1
    80003c32:	8a32                	mv	s4,a2
    80003c34:	84b6                	mv	s1,a3
    80003c36:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c38:	9f35                	addw	a4,a4,a3
    return 0;
    80003c3a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c3c:	08d76663          	bltu	a4,a3,80003cc8 <readi+0xbe>
  if(off + n > ip->size)
    80003c40:	00e7f463          	bgeu	a5,a4,80003c48 <readi+0x3e>
    n = ip->size - off;
    80003c44:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c48:	080a8f63          	beqz	s5,80003ce6 <readi+0xdc>
    80003c4c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c4e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c52:	5c7d                	li	s8,-1
    80003c54:	a80d                	j	80003c86 <readi+0x7c>
    80003c56:	020d1d93          	slli	s11,s10,0x20
    80003c5a:	020ddd93          	srli	s11,s11,0x20
    80003c5e:	05890613          	addi	a2,s2,88
    80003c62:	86ee                	mv	a3,s11
    80003c64:	963a                	add	a2,a2,a4
    80003c66:	85d2                	mv	a1,s4
    80003c68:	855e                	mv	a0,s7
    80003c6a:	863fe0ef          	jal	ra,800024cc <either_copyout>
    80003c6e:	05850763          	beq	a0,s8,80003cbc <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c72:	854a                	mv	a0,s2
    80003c74:	e62ff0ef          	jal	ra,800032d6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c78:	013d09bb          	addw	s3,s10,s3
    80003c7c:	009d04bb          	addw	s1,s10,s1
    80003c80:	9a6e                	add	s4,s4,s11
    80003c82:	0559f163          	bgeu	s3,s5,80003cc4 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003c86:	00a4d59b          	srliw	a1,s1,0xa
    80003c8a:	855a                	mv	a0,s6
    80003c8c:	8b7ff0ef          	jal	ra,80003542 <bmap>
    80003c90:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c94:	c985                	beqz	a1,80003cc4 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003c96:	000b2503          	lw	a0,0(s6)
    80003c9a:	d34ff0ef          	jal	ra,800031ce <bread>
    80003c9e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ca0:	3ff4f713          	andi	a4,s1,1023
    80003ca4:	40ec87bb          	subw	a5,s9,a4
    80003ca8:	413a86bb          	subw	a3,s5,s3
    80003cac:	8d3e                	mv	s10,a5
    80003cae:	2781                	sext.w	a5,a5
    80003cb0:	0006861b          	sext.w	a2,a3
    80003cb4:	faf671e3          	bgeu	a2,a5,80003c56 <readi+0x4c>
    80003cb8:	8d36                	mv	s10,a3
    80003cba:	bf71                	j	80003c56 <readi+0x4c>
      brelse(bp);
    80003cbc:	854a                	mv	a0,s2
    80003cbe:	e18ff0ef          	jal	ra,800032d6 <brelse>
      tot = -1;
    80003cc2:	59fd                	li	s3,-1
  }
  return tot;
    80003cc4:	0009851b          	sext.w	a0,s3
}
    80003cc8:	70a6                	ld	ra,104(sp)
    80003cca:	7406                	ld	s0,96(sp)
    80003ccc:	64e6                	ld	s1,88(sp)
    80003cce:	6946                	ld	s2,80(sp)
    80003cd0:	69a6                	ld	s3,72(sp)
    80003cd2:	6a06                	ld	s4,64(sp)
    80003cd4:	7ae2                	ld	s5,56(sp)
    80003cd6:	7b42                	ld	s6,48(sp)
    80003cd8:	7ba2                	ld	s7,40(sp)
    80003cda:	7c02                	ld	s8,32(sp)
    80003cdc:	6ce2                	ld	s9,24(sp)
    80003cde:	6d42                	ld	s10,16(sp)
    80003ce0:	6da2                	ld	s11,8(sp)
    80003ce2:	6165                	addi	sp,sp,112
    80003ce4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce6:	89d6                	mv	s3,s5
    80003ce8:	bff1                	j	80003cc4 <readi+0xba>
    return 0;
    80003cea:	4501                	li	a0,0
}
    80003cec:	8082                	ret

0000000080003cee <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cee:	457c                	lw	a5,76(a0)
    80003cf0:	0ed7ea63          	bltu	a5,a3,80003de4 <writei+0xf6>
{
    80003cf4:	7159                	addi	sp,sp,-112
    80003cf6:	f486                	sd	ra,104(sp)
    80003cf8:	f0a2                	sd	s0,96(sp)
    80003cfa:	eca6                	sd	s1,88(sp)
    80003cfc:	e8ca                	sd	s2,80(sp)
    80003cfe:	e4ce                	sd	s3,72(sp)
    80003d00:	e0d2                	sd	s4,64(sp)
    80003d02:	fc56                	sd	s5,56(sp)
    80003d04:	f85a                	sd	s6,48(sp)
    80003d06:	f45e                	sd	s7,40(sp)
    80003d08:	f062                	sd	s8,32(sp)
    80003d0a:	ec66                	sd	s9,24(sp)
    80003d0c:	e86a                	sd	s10,16(sp)
    80003d0e:	e46e                	sd	s11,8(sp)
    80003d10:	1880                	addi	s0,sp,112
    80003d12:	8aaa                	mv	s5,a0
    80003d14:	8bae                	mv	s7,a1
    80003d16:	8a32                	mv	s4,a2
    80003d18:	8936                	mv	s2,a3
    80003d1a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d1c:	00e687bb          	addw	a5,a3,a4
    80003d20:	0cd7e463          	bltu	a5,a3,80003de8 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d24:	00043737          	lui	a4,0x43
    80003d28:	0cf76263          	bltu	a4,a5,80003dec <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d2c:	0a0b0a63          	beqz	s6,80003de0 <writei+0xf2>
    80003d30:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d32:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d36:	5c7d                	li	s8,-1
    80003d38:	a825                	j	80003d70 <writei+0x82>
    80003d3a:	020d1d93          	slli	s11,s10,0x20
    80003d3e:	020ddd93          	srli	s11,s11,0x20
    80003d42:	05848513          	addi	a0,s1,88
    80003d46:	86ee                	mv	a3,s11
    80003d48:	8652                	mv	a2,s4
    80003d4a:	85de                	mv	a1,s7
    80003d4c:	953a                	add	a0,a0,a4
    80003d4e:	fc8fe0ef          	jal	ra,80002516 <either_copyin>
    80003d52:	05850a63          	beq	a0,s8,80003da6 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d56:	8526                	mv	a0,s1
    80003d58:	690000ef          	jal	ra,800043e8 <log_write>
    brelse(bp);
    80003d5c:	8526                	mv	a0,s1
    80003d5e:	d78ff0ef          	jal	ra,800032d6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d62:	013d09bb          	addw	s3,s10,s3
    80003d66:	012d093b          	addw	s2,s10,s2
    80003d6a:	9a6e                	add	s4,s4,s11
    80003d6c:	0569f063          	bgeu	s3,s6,80003dac <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003d70:	00a9559b          	srliw	a1,s2,0xa
    80003d74:	8556                	mv	a0,s5
    80003d76:	fccff0ef          	jal	ra,80003542 <bmap>
    80003d7a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d7e:	c59d                	beqz	a1,80003dac <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003d80:	000aa503          	lw	a0,0(s5)
    80003d84:	c4aff0ef          	jal	ra,800031ce <bread>
    80003d88:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d8a:	3ff97713          	andi	a4,s2,1023
    80003d8e:	40ec87bb          	subw	a5,s9,a4
    80003d92:	413b06bb          	subw	a3,s6,s3
    80003d96:	8d3e                	mv	s10,a5
    80003d98:	2781                	sext.w	a5,a5
    80003d9a:	0006861b          	sext.w	a2,a3
    80003d9e:	f8f67ee3          	bgeu	a2,a5,80003d3a <writei+0x4c>
    80003da2:	8d36                	mv	s10,a3
    80003da4:	bf59                	j	80003d3a <writei+0x4c>
      brelse(bp);
    80003da6:	8526                	mv	a0,s1
    80003da8:	d2eff0ef          	jal	ra,800032d6 <brelse>
  }

  if(off > ip->size)
    80003dac:	04caa783          	lw	a5,76(s5)
    80003db0:	0127f463          	bgeu	a5,s2,80003db8 <writei+0xca>
    ip->size = off;
    80003db4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003db8:	8556                	mv	a0,s5
    80003dba:	a11ff0ef          	jal	ra,800037ca <iupdate>

  return tot;
    80003dbe:	0009851b          	sext.w	a0,s3
}
    80003dc2:	70a6                	ld	ra,104(sp)
    80003dc4:	7406                	ld	s0,96(sp)
    80003dc6:	64e6                	ld	s1,88(sp)
    80003dc8:	6946                	ld	s2,80(sp)
    80003dca:	69a6                	ld	s3,72(sp)
    80003dcc:	6a06                	ld	s4,64(sp)
    80003dce:	7ae2                	ld	s5,56(sp)
    80003dd0:	7b42                	ld	s6,48(sp)
    80003dd2:	7ba2                	ld	s7,40(sp)
    80003dd4:	7c02                	ld	s8,32(sp)
    80003dd6:	6ce2                	ld	s9,24(sp)
    80003dd8:	6d42                	ld	s10,16(sp)
    80003dda:	6da2                	ld	s11,8(sp)
    80003ddc:	6165                	addi	sp,sp,112
    80003dde:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de0:	89da                	mv	s3,s6
    80003de2:	bfd9                	j	80003db8 <writei+0xca>
    return -1;
    80003de4:	557d                	li	a0,-1
}
    80003de6:	8082                	ret
    return -1;
    80003de8:	557d                	li	a0,-1
    80003dea:	bfe1                	j	80003dc2 <writei+0xd4>
    return -1;
    80003dec:	557d                	li	a0,-1
    80003dee:	bfd1                	j	80003dc2 <writei+0xd4>

0000000080003df0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003df0:	1141                	addi	sp,sp,-16
    80003df2:	e406                	sd	ra,8(sp)
    80003df4:	e022                	sd	s0,0(sp)
    80003df6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003df8:	4639                	li	a2,14
    80003dfa:	846fd0ef          	jal	ra,80000e40 <strncmp>
}
    80003dfe:	60a2                	ld	ra,8(sp)
    80003e00:	6402                	ld	s0,0(sp)
    80003e02:	0141                	addi	sp,sp,16
    80003e04:	8082                	ret

0000000080003e06 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e06:	7139                	addi	sp,sp,-64
    80003e08:	fc06                	sd	ra,56(sp)
    80003e0a:	f822                	sd	s0,48(sp)
    80003e0c:	f426                	sd	s1,40(sp)
    80003e0e:	f04a                	sd	s2,32(sp)
    80003e10:	ec4e                	sd	s3,24(sp)
    80003e12:	e852                	sd	s4,16(sp)
    80003e14:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e16:	04451703          	lh	a4,68(a0)
    80003e1a:	4785                	li	a5,1
    80003e1c:	00f71a63          	bne	a4,a5,80003e30 <dirlookup+0x2a>
    80003e20:	892a                	mv	s2,a0
    80003e22:	89ae                	mv	s3,a1
    80003e24:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e26:	457c                	lw	a5,76(a0)
    80003e28:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e2a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2c:	e39d                	bnez	a5,80003e52 <dirlookup+0x4c>
    80003e2e:	a095                	j	80003e92 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003e30:	00003517          	auipc	a0,0x3
    80003e34:	79850513          	addi	a0,a0,1944 # 800075c8 <syscalls+0x1d0>
    80003e38:	951fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80003e3c:	00003517          	auipc	a0,0x3
    80003e40:	7a450513          	addi	a0,a0,1956 # 800075e0 <syscalls+0x1e8>
    80003e44:	945fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e48:	24c1                	addiw	s1,s1,16
    80003e4a:	04c92783          	lw	a5,76(s2)
    80003e4e:	04f4f163          	bgeu	s1,a5,80003e90 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e52:	4741                	li	a4,16
    80003e54:	86a6                	mv	a3,s1
    80003e56:	fc040613          	addi	a2,s0,-64
    80003e5a:	4581                	li	a1,0
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	dadff0ef          	jal	ra,80003c0a <readi>
    80003e62:	47c1                	li	a5,16
    80003e64:	fcf51ce3          	bne	a0,a5,80003e3c <dirlookup+0x36>
    if(de.inum == 0)
    80003e68:	fc045783          	lhu	a5,-64(s0)
    80003e6c:	dff1                	beqz	a5,80003e48 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003e6e:	fc240593          	addi	a1,s0,-62
    80003e72:	854e                	mv	a0,s3
    80003e74:	f7dff0ef          	jal	ra,80003df0 <namecmp>
    80003e78:	f961                	bnez	a0,80003e48 <dirlookup+0x42>
      if(poff)
    80003e7a:	000a0463          	beqz	s4,80003e82 <dirlookup+0x7c>
        *poff = off;
    80003e7e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e82:	fc045583          	lhu	a1,-64(s0)
    80003e86:	00092503          	lw	a0,0(s2)
    80003e8a:	f86ff0ef          	jal	ra,80003610 <iget>
    80003e8e:	a011                	j	80003e92 <dirlookup+0x8c>
  return 0;
    80003e90:	4501                	li	a0,0
}
    80003e92:	70e2                	ld	ra,56(sp)
    80003e94:	7442                	ld	s0,48(sp)
    80003e96:	74a2                	ld	s1,40(sp)
    80003e98:	7902                	ld	s2,32(sp)
    80003e9a:	69e2                	ld	s3,24(sp)
    80003e9c:	6a42                	ld	s4,16(sp)
    80003e9e:	6121                	addi	sp,sp,64
    80003ea0:	8082                	ret

0000000080003ea2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ea2:	711d                	addi	sp,sp,-96
    80003ea4:	ec86                	sd	ra,88(sp)
    80003ea6:	e8a2                	sd	s0,80(sp)
    80003ea8:	e4a6                	sd	s1,72(sp)
    80003eaa:	e0ca                	sd	s2,64(sp)
    80003eac:	fc4e                	sd	s3,56(sp)
    80003eae:	f852                	sd	s4,48(sp)
    80003eb0:	f456                	sd	s5,40(sp)
    80003eb2:	f05a                	sd	s6,32(sp)
    80003eb4:	ec5e                	sd	s7,24(sp)
    80003eb6:	e862                	sd	s8,16(sp)
    80003eb8:	e466                	sd	s9,8(sp)
    80003eba:	e06a                	sd	s10,0(sp)
    80003ebc:	1080                	addi	s0,sp,96
    80003ebe:	84aa                	mv	s1,a0
    80003ec0:	8b2e                	mv	s6,a1
    80003ec2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ec4:	00054703          	lbu	a4,0(a0)
    80003ec8:	02f00793          	li	a5,47
    80003ecc:	00f70f63          	beq	a4,a5,80003eea <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ed0:	c33fd0ef          	jal	ra,80001b02 <myproc>
    80003ed4:	15053503          	ld	a0,336(a0)
    80003ed8:	971ff0ef          	jal	ra,80003848 <idup>
    80003edc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ede:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ee2:	4cb5                	li	s9,13
  len = path - s;
    80003ee4:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ee6:	4c05                	li	s8,1
    80003ee8:	a879                	j	80003f86 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003eea:	4585                	li	a1,1
    80003eec:	4505                	li	a0,1
    80003eee:	f22ff0ef          	jal	ra,80003610 <iget>
    80003ef2:	8a2a                	mv	s4,a0
    80003ef4:	b7ed                	j	80003ede <namex+0x3c>
      iunlockput(ip);
    80003ef6:	8552                	mv	a0,s4
    80003ef8:	b8dff0ef          	jal	ra,80003a84 <iunlockput>
      return 0;
    80003efc:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003efe:	8552                	mv	a0,s4
    80003f00:	60e6                	ld	ra,88(sp)
    80003f02:	6446                	ld	s0,80(sp)
    80003f04:	64a6                	ld	s1,72(sp)
    80003f06:	6906                	ld	s2,64(sp)
    80003f08:	79e2                	ld	s3,56(sp)
    80003f0a:	7a42                	ld	s4,48(sp)
    80003f0c:	7aa2                	ld	s5,40(sp)
    80003f0e:	7b02                	ld	s6,32(sp)
    80003f10:	6be2                	ld	s7,24(sp)
    80003f12:	6c42                	ld	s8,16(sp)
    80003f14:	6ca2                	ld	s9,8(sp)
    80003f16:	6d02                	ld	s10,0(sp)
    80003f18:	6125                	addi	sp,sp,96
    80003f1a:	8082                	ret
      iunlock(ip);
    80003f1c:	8552                	mv	a0,s4
    80003f1e:	a0bff0ef          	jal	ra,80003928 <iunlock>
      return ip;
    80003f22:	bff1                	j	80003efe <namex+0x5c>
      iunlockput(ip);
    80003f24:	8552                	mv	a0,s4
    80003f26:	b5fff0ef          	jal	ra,80003a84 <iunlockput>
      return 0;
    80003f2a:	8a4e                	mv	s4,s3
    80003f2c:	bfc9                	j	80003efe <namex+0x5c>
  len = path - s;
    80003f2e:	40998633          	sub	a2,s3,s1
    80003f32:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f36:	09acd063          	bge	s9,s10,80003fb6 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003f3a:	4639                	li	a2,14
    80003f3c:	85a6                	mv	a1,s1
    80003f3e:	8556                	mv	a0,s5
    80003f40:	e91fc0ef          	jal	ra,80000dd0 <memmove>
    80003f44:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f46:	0004c783          	lbu	a5,0(s1)
    80003f4a:	01279763          	bne	a5,s2,80003f58 <namex+0xb6>
    path++;
    80003f4e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f50:	0004c783          	lbu	a5,0(s1)
    80003f54:	ff278de3          	beq	a5,s2,80003f4e <namex+0xac>
    ilock(ip);
    80003f58:	8552                	mv	a0,s4
    80003f5a:	925ff0ef          	jal	ra,8000387e <ilock>
    if(ip->type != T_DIR){
    80003f5e:	044a1783          	lh	a5,68(s4)
    80003f62:	f9879ae3          	bne	a5,s8,80003ef6 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003f66:	000b0563          	beqz	s6,80003f70 <namex+0xce>
    80003f6a:	0004c783          	lbu	a5,0(s1)
    80003f6e:	d7dd                	beqz	a5,80003f1c <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f70:	865e                	mv	a2,s7
    80003f72:	85d6                	mv	a1,s5
    80003f74:	8552                	mv	a0,s4
    80003f76:	e91ff0ef          	jal	ra,80003e06 <dirlookup>
    80003f7a:	89aa                	mv	s3,a0
    80003f7c:	d545                	beqz	a0,80003f24 <namex+0x82>
    iunlockput(ip);
    80003f7e:	8552                	mv	a0,s4
    80003f80:	b05ff0ef          	jal	ra,80003a84 <iunlockput>
    ip = next;
    80003f84:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f86:	0004c783          	lbu	a5,0(s1)
    80003f8a:	01279763          	bne	a5,s2,80003f98 <namex+0xf6>
    path++;
    80003f8e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f90:	0004c783          	lbu	a5,0(s1)
    80003f94:	ff278de3          	beq	a5,s2,80003f8e <namex+0xec>
  if(*path == 0)
    80003f98:	cb8d                	beqz	a5,80003fca <namex+0x128>
  while(*path != '/' && *path != 0)
    80003f9a:	0004c783          	lbu	a5,0(s1)
    80003f9e:	89a6                	mv	s3,s1
  len = path - s;
    80003fa0:	8d5e                	mv	s10,s7
    80003fa2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fa4:	01278963          	beq	a5,s2,80003fb6 <namex+0x114>
    80003fa8:	d3d9                	beqz	a5,80003f2e <namex+0x8c>
    path++;
    80003faa:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003fac:	0009c783          	lbu	a5,0(s3)
    80003fb0:	ff279ce3          	bne	a5,s2,80003fa8 <namex+0x106>
    80003fb4:	bfad                	j	80003f2e <namex+0x8c>
    memmove(name, s, len);
    80003fb6:	2601                	sext.w	a2,a2
    80003fb8:	85a6                	mv	a1,s1
    80003fba:	8556                	mv	a0,s5
    80003fbc:	e15fc0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    80003fc0:	9d56                	add	s10,s10,s5
    80003fc2:	000d0023          	sb	zero,0(s10)
    80003fc6:	84ce                	mv	s1,s3
    80003fc8:	bfbd                	j	80003f46 <namex+0xa4>
  if(nameiparent){
    80003fca:	f20b0ae3          	beqz	s6,80003efe <namex+0x5c>
    iput(ip);
    80003fce:	8552                	mv	a0,s4
    80003fd0:	a2dff0ef          	jal	ra,800039fc <iput>
    return 0;
    80003fd4:	4a01                	li	s4,0
    80003fd6:	b725                	j	80003efe <namex+0x5c>

0000000080003fd8 <dirlink>:
{
    80003fd8:	7139                	addi	sp,sp,-64
    80003fda:	fc06                	sd	ra,56(sp)
    80003fdc:	f822                	sd	s0,48(sp)
    80003fde:	f426                	sd	s1,40(sp)
    80003fe0:	f04a                	sd	s2,32(sp)
    80003fe2:	ec4e                	sd	s3,24(sp)
    80003fe4:	e852                	sd	s4,16(sp)
    80003fe6:	0080                	addi	s0,sp,64
    80003fe8:	892a                	mv	s2,a0
    80003fea:	8a2e                	mv	s4,a1
    80003fec:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fee:	4601                	li	a2,0
    80003ff0:	e17ff0ef          	jal	ra,80003e06 <dirlookup>
    80003ff4:	e52d                	bnez	a0,8000405e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ff6:	04c92483          	lw	s1,76(s2)
    80003ffa:	c48d                	beqz	s1,80004024 <dirlink+0x4c>
    80003ffc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ffe:	4741                	li	a4,16
    80004000:	86a6                	mv	a3,s1
    80004002:	fc040613          	addi	a2,s0,-64
    80004006:	4581                	li	a1,0
    80004008:	854a                	mv	a0,s2
    8000400a:	c01ff0ef          	jal	ra,80003c0a <readi>
    8000400e:	47c1                	li	a5,16
    80004010:	04f51b63          	bne	a0,a5,80004066 <dirlink+0x8e>
    if(de.inum == 0)
    80004014:	fc045783          	lhu	a5,-64(s0)
    80004018:	c791                	beqz	a5,80004024 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000401a:	24c1                	addiw	s1,s1,16
    8000401c:	04c92783          	lw	a5,76(s2)
    80004020:	fcf4efe3          	bltu	s1,a5,80003ffe <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004024:	4639                	li	a2,14
    80004026:	85d2                	mv	a1,s4
    80004028:	fc240513          	addi	a0,s0,-62
    8000402c:	e51fc0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80004030:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004034:	4741                	li	a4,16
    80004036:	86a6                	mv	a3,s1
    80004038:	fc040613          	addi	a2,s0,-64
    8000403c:	4581                	li	a1,0
    8000403e:	854a                	mv	a0,s2
    80004040:	cafff0ef          	jal	ra,80003cee <writei>
    80004044:	1541                	addi	a0,a0,-16
    80004046:	00a03533          	snez	a0,a0
    8000404a:	40a00533          	neg	a0,a0
}
    8000404e:	70e2                	ld	ra,56(sp)
    80004050:	7442                	ld	s0,48(sp)
    80004052:	74a2                	ld	s1,40(sp)
    80004054:	7902                	ld	s2,32(sp)
    80004056:	69e2                	ld	s3,24(sp)
    80004058:	6a42                	ld	s4,16(sp)
    8000405a:	6121                	addi	sp,sp,64
    8000405c:	8082                	ret
    iput(ip);
    8000405e:	99fff0ef          	jal	ra,800039fc <iput>
    return -1;
    80004062:	557d                	li	a0,-1
    80004064:	b7ed                	j	8000404e <dirlink+0x76>
      panic("dirlink read");
    80004066:	00003517          	auipc	a0,0x3
    8000406a:	58a50513          	addi	a0,a0,1418 # 800075f0 <syscalls+0x1f8>
    8000406e:	f1afc0ef          	jal	ra,80000788 <panic>

0000000080004072 <namei>:

struct inode*
namei(char *path)
{
    80004072:	1101                	addi	sp,sp,-32
    80004074:	ec06                	sd	ra,24(sp)
    80004076:	e822                	sd	s0,16(sp)
    80004078:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000407a:	fe040613          	addi	a2,s0,-32
    8000407e:	4581                	li	a1,0
    80004080:	e23ff0ef          	jal	ra,80003ea2 <namex>
}
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	6105                	addi	sp,sp,32
    8000408a:	8082                	ret

000000008000408c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000408c:	1141                	addi	sp,sp,-16
    8000408e:	e406                	sd	ra,8(sp)
    80004090:	e022                	sd	s0,0(sp)
    80004092:	0800                	addi	s0,sp,16
    80004094:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004096:	4585                	li	a1,1
    80004098:	e0bff0ef          	jal	ra,80003ea2 <namex>
}
    8000409c:	60a2                	ld	ra,8(sp)
    8000409e:	6402                	ld	s0,0(sp)
    800040a0:	0141                	addi	sp,sp,16
    800040a2:	8082                	ret

00000000800040a4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040a4:	1101                	addi	sp,sp,-32
    800040a6:	ec06                	sd	ra,24(sp)
    800040a8:	e822                	sd	s0,16(sp)
    800040aa:	e426                	sd	s1,8(sp)
    800040ac:	e04a                	sd	s2,0(sp)
    800040ae:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040b0:	00244917          	auipc	s2,0x244
    800040b4:	8d090913          	addi	s2,s2,-1840 # 80247980 <log>
    800040b8:	01892583          	lw	a1,24(s2)
    800040bc:	02492503          	lw	a0,36(s2)
    800040c0:	90eff0ef          	jal	ra,800031ce <bread>
    800040c4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040c6:	02892683          	lw	a3,40(s2)
    800040ca:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040cc:	02d05863          	blez	a3,800040fc <write_head+0x58>
    800040d0:	00244797          	auipc	a5,0x244
    800040d4:	8dc78793          	addi	a5,a5,-1828 # 802479ac <log+0x2c>
    800040d8:	05c50713          	addi	a4,a0,92
    800040dc:	36fd                	addiw	a3,a3,-1
    800040de:	02069613          	slli	a2,a3,0x20
    800040e2:	01e65693          	srli	a3,a2,0x1e
    800040e6:	00244617          	auipc	a2,0x244
    800040ea:	8ca60613          	addi	a2,a2,-1846 # 802479b0 <log+0x30>
    800040ee:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040f0:	4390                	lw	a2,0(a5)
    800040f2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040f4:	0791                	addi	a5,a5,4
    800040f6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800040f8:	fed79ce3          	bne	a5,a3,800040f0 <write_head+0x4c>
  }
  bwrite(buf);
    800040fc:	8526                	mv	a0,s1
    800040fe:	9a6ff0ef          	jal	ra,800032a4 <bwrite>
  brelse(buf);
    80004102:	8526                	mv	a0,s1
    80004104:	9d2ff0ef          	jal	ra,800032d6 <brelse>
}
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	64a2                	ld	s1,8(sp)
    8000410e:	6902                	ld	s2,0(sp)
    80004110:	6105                	addi	sp,sp,32
    80004112:	8082                	ret

0000000080004114 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004114:	00244797          	auipc	a5,0x244
    80004118:	8947a783          	lw	a5,-1900(a5) # 802479a8 <log+0x28>
    8000411c:	0af05e63          	blez	a5,800041d8 <install_trans+0xc4>
{
    80004120:	715d                	addi	sp,sp,-80
    80004122:	e486                	sd	ra,72(sp)
    80004124:	e0a2                	sd	s0,64(sp)
    80004126:	fc26                	sd	s1,56(sp)
    80004128:	f84a                	sd	s2,48(sp)
    8000412a:	f44e                	sd	s3,40(sp)
    8000412c:	f052                	sd	s4,32(sp)
    8000412e:	ec56                	sd	s5,24(sp)
    80004130:	e85a                	sd	s6,16(sp)
    80004132:	e45e                	sd	s7,8(sp)
    80004134:	0880                	addi	s0,sp,80
    80004136:	8b2a                	mv	s6,a0
    80004138:	00244a97          	auipc	s5,0x244
    8000413c:	874a8a93          	addi	s5,s5,-1932 # 802479ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004140:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004142:	00003b97          	auipc	s7,0x3
    80004146:	4beb8b93          	addi	s7,s7,1214 # 80007600 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000414a:	00244a17          	auipc	s4,0x244
    8000414e:	836a0a13          	addi	s4,s4,-1994 # 80247980 <log>
    80004152:	a025                	j	8000417a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004154:	000aa603          	lw	a2,0(s5)
    80004158:	85ce                	mv	a1,s3
    8000415a:	855e                	mv	a0,s7
    8000415c:	b66fc0ef          	jal	ra,800004c2 <printf>
    80004160:	a839                	j	8000417e <install_trans+0x6a>
    brelse(lbuf);
    80004162:	854a                	mv	a0,s2
    80004164:	972ff0ef          	jal	ra,800032d6 <brelse>
    brelse(dbuf);
    80004168:	8526                	mv	a0,s1
    8000416a:	96cff0ef          	jal	ra,800032d6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416e:	2985                	addiw	s3,s3,1
    80004170:	0a91                	addi	s5,s5,4
    80004172:	028a2783          	lw	a5,40(s4)
    80004176:	04f9d663          	bge	s3,a5,800041c2 <install_trans+0xae>
    if(recovering) {
    8000417a:	fc0b1de3          	bnez	s6,80004154 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000417e:	018a2583          	lw	a1,24(s4)
    80004182:	013585bb          	addw	a1,a1,s3
    80004186:	2585                	addiw	a1,a1,1
    80004188:	024a2503          	lw	a0,36(s4)
    8000418c:	842ff0ef          	jal	ra,800031ce <bread>
    80004190:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004192:	000aa583          	lw	a1,0(s5)
    80004196:	024a2503          	lw	a0,36(s4)
    8000419a:	834ff0ef          	jal	ra,800031ce <bread>
    8000419e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041a0:	40000613          	li	a2,1024
    800041a4:	05890593          	addi	a1,s2,88
    800041a8:	05850513          	addi	a0,a0,88
    800041ac:	c25fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041b0:	8526                	mv	a0,s1
    800041b2:	8f2ff0ef          	jal	ra,800032a4 <bwrite>
    if(recovering == 0)
    800041b6:	fa0b16e3          	bnez	s6,80004162 <install_trans+0x4e>
      bunpin(dbuf);
    800041ba:	8526                	mv	a0,s1
    800041bc:	9d8ff0ef          	jal	ra,80003394 <bunpin>
    800041c0:	b74d                	j	80004162 <install_trans+0x4e>
}
    800041c2:	60a6                	ld	ra,72(sp)
    800041c4:	6406                	ld	s0,64(sp)
    800041c6:	74e2                	ld	s1,56(sp)
    800041c8:	7942                	ld	s2,48(sp)
    800041ca:	79a2                	ld	s3,40(sp)
    800041cc:	7a02                	ld	s4,32(sp)
    800041ce:	6ae2                	ld	s5,24(sp)
    800041d0:	6b42                	ld	s6,16(sp)
    800041d2:	6ba2                	ld	s7,8(sp)
    800041d4:	6161                	addi	sp,sp,80
    800041d6:	8082                	ret
    800041d8:	8082                	ret

00000000800041da <initlog>:
{
    800041da:	7179                	addi	sp,sp,-48
    800041dc:	f406                	sd	ra,40(sp)
    800041de:	f022                	sd	s0,32(sp)
    800041e0:	ec26                	sd	s1,24(sp)
    800041e2:	e84a                	sd	s2,16(sp)
    800041e4:	e44e                	sd	s3,8(sp)
    800041e6:	1800                	addi	s0,sp,48
    800041e8:	892a                	mv	s2,a0
    800041ea:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041ec:	00243497          	auipc	s1,0x243
    800041f0:	79448493          	addi	s1,s1,1940 # 80247980 <log>
    800041f4:	00003597          	auipc	a1,0x3
    800041f8:	42c58593          	addi	a1,a1,1068 # 80007620 <syscalls+0x228>
    800041fc:	8526                	mv	a0,s1
    800041fe:	a23fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80004202:	0149a583          	lw	a1,20(s3)
    80004206:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004208:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000420c:	854a                	mv	a0,s2
    8000420e:	fc1fe0ef          	jal	ra,800031ce <bread>
  log.lh.n = lh->n;
    80004212:	4d34                	lw	a3,88(a0)
    80004214:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004216:	02d05663          	blez	a3,80004242 <initlog+0x68>
    8000421a:	05c50793          	addi	a5,a0,92
    8000421e:	00243717          	auipc	a4,0x243
    80004222:	78e70713          	addi	a4,a4,1934 # 802479ac <log+0x2c>
    80004226:	36fd                	addiw	a3,a3,-1
    80004228:	02069613          	slli	a2,a3,0x20
    8000422c:	01e65693          	srli	a3,a2,0x1e
    80004230:	06050613          	addi	a2,a0,96
    80004234:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004236:	4390                	lw	a2,0(a5)
    80004238:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000423a:	0791                	addi	a5,a5,4
    8000423c:	0711                	addi	a4,a4,4
    8000423e:	fed79ce3          	bne	a5,a3,80004236 <initlog+0x5c>
  brelse(buf);
    80004242:	894ff0ef          	jal	ra,800032d6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004246:	4505                	li	a0,1
    80004248:	ecdff0ef          	jal	ra,80004114 <install_trans>
  log.lh.n = 0;
    8000424c:	00243797          	auipc	a5,0x243
    80004250:	7407ae23          	sw	zero,1884(a5) # 802479a8 <log+0x28>
  write_head(); // clear the log
    80004254:	e51ff0ef          	jal	ra,800040a4 <write_head>
}
    80004258:	70a2                	ld	ra,40(sp)
    8000425a:	7402                	ld	s0,32(sp)
    8000425c:	64e2                	ld	s1,24(sp)
    8000425e:	6942                	ld	s2,16(sp)
    80004260:	69a2                	ld	s3,8(sp)
    80004262:	6145                	addi	sp,sp,48
    80004264:	8082                	ret

0000000080004266 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004266:	1101                	addi	sp,sp,-32
    80004268:	ec06                	sd	ra,24(sp)
    8000426a:	e822                	sd	s0,16(sp)
    8000426c:	e426                	sd	s1,8(sp)
    8000426e:	e04a                	sd	s2,0(sp)
    80004270:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004272:	00243517          	auipc	a0,0x243
    80004276:	70e50513          	addi	a0,a0,1806 # 80247980 <log>
    8000427a:	a27fc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    8000427e:	00243497          	auipc	s1,0x243
    80004282:	70248493          	addi	s1,s1,1794 # 80247980 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004286:	4979                	li	s2,30
    80004288:	a029                	j	80004292 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000428a:	85a6                	mv	a1,s1
    8000428c:	8526                	mv	a0,s1
    8000428e:	ee3fd0ef          	jal	ra,80002170 <sleep>
    if(log.committing){
    80004292:	509c                	lw	a5,32(s1)
    80004294:	fbfd                	bnez	a5,8000428a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004296:	4cd8                	lw	a4,28(s1)
    80004298:	2705                	addiw	a4,a4,1
    8000429a:	0007069b          	sext.w	a3,a4
    8000429e:	0027179b          	slliw	a5,a4,0x2
    800042a2:	9fb9                	addw	a5,a5,a4
    800042a4:	0017979b          	slliw	a5,a5,0x1
    800042a8:	5498                	lw	a4,40(s1)
    800042aa:	9fb9                	addw	a5,a5,a4
    800042ac:	00f95763          	bge	s2,a5,800042ba <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042b0:	85a6                	mv	a1,s1
    800042b2:	8526                	mv	a0,s1
    800042b4:	ebdfd0ef          	jal	ra,80002170 <sleep>
    800042b8:	bfe9                	j	80004292 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800042ba:	00243517          	auipc	a0,0x243
    800042be:	6c650513          	addi	a0,a0,1734 # 80247980 <log>
    800042c2:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800042c4:	a75fc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    800042c8:	60e2                	ld	ra,24(sp)
    800042ca:	6442                	ld	s0,16(sp)
    800042cc:	64a2                	ld	s1,8(sp)
    800042ce:	6902                	ld	s2,0(sp)
    800042d0:	6105                	addi	sp,sp,32
    800042d2:	8082                	ret

00000000800042d4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042d4:	7139                	addi	sp,sp,-64
    800042d6:	fc06                	sd	ra,56(sp)
    800042d8:	f822                	sd	s0,48(sp)
    800042da:	f426                	sd	s1,40(sp)
    800042dc:	f04a                	sd	s2,32(sp)
    800042de:	ec4e                	sd	s3,24(sp)
    800042e0:	e852                	sd	s4,16(sp)
    800042e2:	e456                	sd	s5,8(sp)
    800042e4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042e6:	00243497          	auipc	s1,0x243
    800042ea:	69a48493          	addi	s1,s1,1690 # 80247980 <log>
    800042ee:	8526                	mv	a0,s1
    800042f0:	9b1fc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    800042f4:	4cdc                	lw	a5,28(s1)
    800042f6:	37fd                	addiw	a5,a5,-1
    800042f8:	0007891b          	sext.w	s2,a5
    800042fc:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800042fe:	509c                	lw	a5,32(s1)
    80004300:	ef9d                	bnez	a5,8000433e <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004302:	04091463          	bnez	s2,8000434a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004306:	00243497          	auipc	s1,0x243
    8000430a:	67a48493          	addi	s1,s1,1658 # 80247980 <log>
    8000430e:	4785                	li	a5,1
    80004310:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004312:	8526                	mv	a0,s1
    80004314:	a25fc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004318:	549c                	lw	a5,40(s1)
    8000431a:	04f04b63          	bgtz	a5,80004370 <end_op+0x9c>
    acquire(&log.lock);
    8000431e:	00243497          	auipc	s1,0x243
    80004322:	66248493          	addi	s1,s1,1634 # 80247980 <log>
    80004326:	8526                	mv	a0,s1
    80004328:	979fc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    8000432c:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004330:	8526                	mv	a0,s1
    80004332:	e8bfd0ef          	jal	ra,800021bc <wakeup>
    release(&log.lock);
    80004336:	8526                	mv	a0,s1
    80004338:	a01fc0ef          	jal	ra,80000d38 <release>
}
    8000433c:	a00d                	j	8000435e <end_op+0x8a>
    panic("log.committing");
    8000433e:	00003517          	auipc	a0,0x3
    80004342:	2ea50513          	addi	a0,a0,746 # 80007628 <syscalls+0x230>
    80004346:	c42fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    8000434a:	00243497          	auipc	s1,0x243
    8000434e:	63648493          	addi	s1,s1,1590 # 80247980 <log>
    80004352:	8526                	mv	a0,s1
    80004354:	e69fd0ef          	jal	ra,800021bc <wakeup>
  release(&log.lock);
    80004358:	8526                	mv	a0,s1
    8000435a:	9dffc0ef          	jal	ra,80000d38 <release>
}
    8000435e:	70e2                	ld	ra,56(sp)
    80004360:	7442                	ld	s0,48(sp)
    80004362:	74a2                	ld	s1,40(sp)
    80004364:	7902                	ld	s2,32(sp)
    80004366:	69e2                	ld	s3,24(sp)
    80004368:	6a42                	ld	s4,16(sp)
    8000436a:	6aa2                	ld	s5,8(sp)
    8000436c:	6121                	addi	sp,sp,64
    8000436e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004370:	00243a97          	auipc	s5,0x243
    80004374:	63ca8a93          	addi	s5,s5,1596 # 802479ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004378:	00243a17          	auipc	s4,0x243
    8000437c:	608a0a13          	addi	s4,s4,1544 # 80247980 <log>
    80004380:	018a2583          	lw	a1,24(s4)
    80004384:	012585bb          	addw	a1,a1,s2
    80004388:	2585                	addiw	a1,a1,1
    8000438a:	024a2503          	lw	a0,36(s4)
    8000438e:	e41fe0ef          	jal	ra,800031ce <bread>
    80004392:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004394:	000aa583          	lw	a1,0(s5)
    80004398:	024a2503          	lw	a0,36(s4)
    8000439c:	e33fe0ef          	jal	ra,800031ce <bread>
    800043a0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043a2:	40000613          	li	a2,1024
    800043a6:	05850593          	addi	a1,a0,88
    800043aa:	05848513          	addi	a0,s1,88
    800043ae:	a23fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    800043b2:	8526                	mv	a0,s1
    800043b4:	ef1fe0ef          	jal	ra,800032a4 <bwrite>
    brelse(from);
    800043b8:	854e                	mv	a0,s3
    800043ba:	f1dfe0ef          	jal	ra,800032d6 <brelse>
    brelse(to);
    800043be:	8526                	mv	a0,s1
    800043c0:	f17fe0ef          	jal	ra,800032d6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043c4:	2905                	addiw	s2,s2,1
    800043c6:	0a91                	addi	s5,s5,4
    800043c8:	028a2783          	lw	a5,40(s4)
    800043cc:	faf94ae3          	blt	s2,a5,80004380 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043d0:	cd5ff0ef          	jal	ra,800040a4 <write_head>
    install_trans(0); // Now install writes to home locations
    800043d4:	4501                	li	a0,0
    800043d6:	d3fff0ef          	jal	ra,80004114 <install_trans>
    log.lh.n = 0;
    800043da:	00243797          	auipc	a5,0x243
    800043de:	5c07a723          	sw	zero,1486(a5) # 802479a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800043e2:	cc3ff0ef          	jal	ra,800040a4 <write_head>
    800043e6:	bf25                	j	8000431e <end_op+0x4a>

00000000800043e8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043e8:	1101                	addi	sp,sp,-32
    800043ea:	ec06                	sd	ra,24(sp)
    800043ec:	e822                	sd	s0,16(sp)
    800043ee:	e426                	sd	s1,8(sp)
    800043f0:	e04a                	sd	s2,0(sp)
    800043f2:	1000                	addi	s0,sp,32
    800043f4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043f6:	00243917          	auipc	s2,0x243
    800043fa:	58a90913          	addi	s2,s2,1418 # 80247980 <log>
    800043fe:	854a                	mv	a0,s2
    80004400:	8a1fc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004404:	02892603          	lw	a2,40(s2)
    80004408:	47f5                	li	a5,29
    8000440a:	04c7cc63          	blt	a5,a2,80004462 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000440e:	00243797          	auipc	a5,0x243
    80004412:	58e7a783          	lw	a5,1422(a5) # 8024799c <log+0x1c>
    80004416:	04f05c63          	blez	a5,8000446e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000441a:	4781                	li	a5,0
    8000441c:	04c05f63          	blez	a2,8000447a <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004420:	44cc                	lw	a1,12(s1)
    80004422:	00243717          	auipc	a4,0x243
    80004426:	58a70713          	addi	a4,a4,1418 # 802479ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000442a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000442c:	4314                	lw	a3,0(a4)
    8000442e:	04b68663          	beq	a3,a1,8000447a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004432:	2785                	addiw	a5,a5,1
    80004434:	0711                	addi	a4,a4,4
    80004436:	fef61be3          	bne	a2,a5,8000442c <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000443a:	0621                	addi	a2,a2,8
    8000443c:	060a                	slli	a2,a2,0x2
    8000443e:	00243797          	auipc	a5,0x243
    80004442:	54278793          	addi	a5,a5,1346 # 80247980 <log>
    80004446:	97b2                	add	a5,a5,a2
    80004448:	44d8                	lw	a4,12(s1)
    8000444a:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000444c:	8526                	mv	a0,s1
    8000444e:	f13fe0ef          	jal	ra,80003360 <bpin>
    log.lh.n++;
    80004452:	00243717          	auipc	a4,0x243
    80004456:	52e70713          	addi	a4,a4,1326 # 80247980 <log>
    8000445a:	571c                	lw	a5,40(a4)
    8000445c:	2785                	addiw	a5,a5,1
    8000445e:	d71c                	sw	a5,40(a4)
    80004460:	a80d                	j	80004492 <log_write+0xaa>
    panic("too big a transaction");
    80004462:	00003517          	auipc	a0,0x3
    80004466:	1d650513          	addi	a0,a0,470 # 80007638 <syscalls+0x240>
    8000446a:	b1efc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    8000446e:	00003517          	auipc	a0,0x3
    80004472:	1e250513          	addi	a0,a0,482 # 80007650 <syscalls+0x258>
    80004476:	b12fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    8000447a:	00878693          	addi	a3,a5,8
    8000447e:	068a                	slli	a3,a3,0x2
    80004480:	00243717          	auipc	a4,0x243
    80004484:	50070713          	addi	a4,a4,1280 # 80247980 <log>
    80004488:	9736                	add	a4,a4,a3
    8000448a:	44d4                	lw	a3,12(s1)
    8000448c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000448e:	faf60fe3          	beq	a2,a5,8000444c <log_write+0x64>
  }
  release(&log.lock);
    80004492:	00243517          	auipc	a0,0x243
    80004496:	4ee50513          	addi	a0,a0,1262 # 80247980 <log>
    8000449a:	89ffc0ef          	jal	ra,80000d38 <release>
}
    8000449e:	60e2                	ld	ra,24(sp)
    800044a0:	6442                	ld	s0,16(sp)
    800044a2:	64a2                	ld	s1,8(sp)
    800044a4:	6902                	ld	s2,0(sp)
    800044a6:	6105                	addi	sp,sp,32
    800044a8:	8082                	ret

00000000800044aa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044aa:	1101                	addi	sp,sp,-32
    800044ac:	ec06                	sd	ra,24(sp)
    800044ae:	e822                	sd	s0,16(sp)
    800044b0:	e426                	sd	s1,8(sp)
    800044b2:	e04a                	sd	s2,0(sp)
    800044b4:	1000                	addi	s0,sp,32
    800044b6:	84aa                	mv	s1,a0
    800044b8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044ba:	00003597          	auipc	a1,0x3
    800044be:	1b658593          	addi	a1,a1,438 # 80007670 <syscalls+0x278>
    800044c2:	0521                	addi	a0,a0,8
    800044c4:	f5cfc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    800044c8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044cc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044d0:	0204a423          	sw	zero,40(s1)
}
    800044d4:	60e2                	ld	ra,24(sp)
    800044d6:	6442                	ld	s0,16(sp)
    800044d8:	64a2                	ld	s1,8(sp)
    800044da:	6902                	ld	s2,0(sp)
    800044dc:	6105                	addi	sp,sp,32
    800044de:	8082                	ret

00000000800044e0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044e0:	1101                	addi	sp,sp,-32
    800044e2:	ec06                	sd	ra,24(sp)
    800044e4:	e822                	sd	s0,16(sp)
    800044e6:	e426                	sd	s1,8(sp)
    800044e8:	e04a                	sd	s2,0(sp)
    800044ea:	1000                	addi	s0,sp,32
    800044ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044ee:	00850913          	addi	s2,a0,8
    800044f2:	854a                	mv	a0,s2
    800044f4:	facfc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    800044f8:	409c                	lw	a5,0(s1)
    800044fa:	c799                	beqz	a5,80004508 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800044fc:	85ca                	mv	a1,s2
    800044fe:	8526                	mv	a0,s1
    80004500:	c71fd0ef          	jal	ra,80002170 <sleep>
  while (lk->locked) {
    80004504:	409c                	lw	a5,0(s1)
    80004506:	fbfd                	bnez	a5,800044fc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004508:	4785                	li	a5,1
    8000450a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000450c:	df6fd0ef          	jal	ra,80001b02 <myproc>
    80004510:	591c                	lw	a5,48(a0)
    80004512:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004514:	854a                	mv	a0,s2
    80004516:	823fc0ef          	jal	ra,80000d38 <release>
}
    8000451a:	60e2                	ld	ra,24(sp)
    8000451c:	6442                	ld	s0,16(sp)
    8000451e:	64a2                	ld	s1,8(sp)
    80004520:	6902                	ld	s2,0(sp)
    80004522:	6105                	addi	sp,sp,32
    80004524:	8082                	ret

0000000080004526 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004526:	1101                	addi	sp,sp,-32
    80004528:	ec06                	sd	ra,24(sp)
    8000452a:	e822                	sd	s0,16(sp)
    8000452c:	e426                	sd	s1,8(sp)
    8000452e:	e04a                	sd	s2,0(sp)
    80004530:	1000                	addi	s0,sp,32
    80004532:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004534:	00850913          	addi	s2,a0,8
    80004538:	854a                	mv	a0,s2
    8000453a:	f66fc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    8000453e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004542:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004546:	8526                	mv	a0,s1
    80004548:	c75fd0ef          	jal	ra,800021bc <wakeup>
  release(&lk->lk);
    8000454c:	854a                	mv	a0,s2
    8000454e:	feafc0ef          	jal	ra,80000d38 <release>
}
    80004552:	60e2                	ld	ra,24(sp)
    80004554:	6442                	ld	s0,16(sp)
    80004556:	64a2                	ld	s1,8(sp)
    80004558:	6902                	ld	s2,0(sp)
    8000455a:	6105                	addi	sp,sp,32
    8000455c:	8082                	ret

000000008000455e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000455e:	7179                	addi	sp,sp,-48
    80004560:	f406                	sd	ra,40(sp)
    80004562:	f022                	sd	s0,32(sp)
    80004564:	ec26                	sd	s1,24(sp)
    80004566:	e84a                	sd	s2,16(sp)
    80004568:	e44e                	sd	s3,8(sp)
    8000456a:	1800                	addi	s0,sp,48
    8000456c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000456e:	00850913          	addi	s2,a0,8
    80004572:	854a                	mv	a0,s2
    80004574:	f2cfc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004578:	409c                	lw	a5,0(s1)
    8000457a:	ef89                	bnez	a5,80004594 <holdingsleep+0x36>
    8000457c:	4481                	li	s1,0
  release(&lk->lk);
    8000457e:	854a                	mv	a0,s2
    80004580:	fb8fc0ef          	jal	ra,80000d38 <release>
  return r;
}
    80004584:	8526                	mv	a0,s1
    80004586:	70a2                	ld	ra,40(sp)
    80004588:	7402                	ld	s0,32(sp)
    8000458a:	64e2                	ld	s1,24(sp)
    8000458c:	6942                	ld	s2,16(sp)
    8000458e:	69a2                	ld	s3,8(sp)
    80004590:	6145                	addi	sp,sp,48
    80004592:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004594:	0284a983          	lw	s3,40(s1)
    80004598:	d6afd0ef          	jal	ra,80001b02 <myproc>
    8000459c:	5904                	lw	s1,48(a0)
    8000459e:	413484b3          	sub	s1,s1,s3
    800045a2:	0014b493          	seqz	s1,s1
    800045a6:	bfe1                	j	8000457e <holdingsleep+0x20>

00000000800045a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045a8:	1141                	addi	sp,sp,-16
    800045aa:	e406                	sd	ra,8(sp)
    800045ac:	e022                	sd	s0,0(sp)
    800045ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045b0:	00003597          	auipc	a1,0x3
    800045b4:	0d058593          	addi	a1,a1,208 # 80007680 <syscalls+0x288>
    800045b8:	00243517          	auipc	a0,0x243
    800045bc:	51050513          	addi	a0,a0,1296 # 80247ac8 <ftable>
    800045c0:	e60fc0ef          	jal	ra,80000c20 <initlock>
}
    800045c4:	60a2                	ld	ra,8(sp)
    800045c6:	6402                	ld	s0,0(sp)
    800045c8:	0141                	addi	sp,sp,16
    800045ca:	8082                	ret

00000000800045cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045cc:	1101                	addi	sp,sp,-32
    800045ce:	ec06                	sd	ra,24(sp)
    800045d0:	e822                	sd	s0,16(sp)
    800045d2:	e426                	sd	s1,8(sp)
    800045d4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045d6:	00243517          	auipc	a0,0x243
    800045da:	4f250513          	addi	a0,a0,1266 # 80247ac8 <ftable>
    800045de:	ec2fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045e2:	00243497          	auipc	s1,0x243
    800045e6:	4fe48493          	addi	s1,s1,1278 # 80247ae0 <ftable+0x18>
    800045ea:	00244717          	auipc	a4,0x244
    800045ee:	49670713          	addi	a4,a4,1174 # 80248a80 <disk>
    if(f->ref == 0){
    800045f2:	40dc                	lw	a5,4(s1)
    800045f4:	cf89                	beqz	a5,8000460e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045f6:	02848493          	addi	s1,s1,40
    800045fa:	fee49ce3          	bne	s1,a4,800045f2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045fe:	00243517          	auipc	a0,0x243
    80004602:	4ca50513          	addi	a0,a0,1226 # 80247ac8 <ftable>
    80004606:	f32fc0ef          	jal	ra,80000d38 <release>
  return 0;
    8000460a:	4481                	li	s1,0
    8000460c:	a809                	j	8000461e <filealloc+0x52>
      f->ref = 1;
    8000460e:	4785                	li	a5,1
    80004610:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004612:	00243517          	auipc	a0,0x243
    80004616:	4b650513          	addi	a0,a0,1206 # 80247ac8 <ftable>
    8000461a:	f1efc0ef          	jal	ra,80000d38 <release>
}
    8000461e:	8526                	mv	a0,s1
    80004620:	60e2                	ld	ra,24(sp)
    80004622:	6442                	ld	s0,16(sp)
    80004624:	64a2                	ld	s1,8(sp)
    80004626:	6105                	addi	sp,sp,32
    80004628:	8082                	ret

000000008000462a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000462a:	1101                	addi	sp,sp,-32
    8000462c:	ec06                	sd	ra,24(sp)
    8000462e:	e822                	sd	s0,16(sp)
    80004630:	e426                	sd	s1,8(sp)
    80004632:	1000                	addi	s0,sp,32
    80004634:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004636:	00243517          	auipc	a0,0x243
    8000463a:	49250513          	addi	a0,a0,1170 # 80247ac8 <ftable>
    8000463e:	e62fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004642:	40dc                	lw	a5,4(s1)
    80004644:	02f05063          	blez	a5,80004664 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004648:	2785                	addiw	a5,a5,1
    8000464a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000464c:	00243517          	auipc	a0,0x243
    80004650:	47c50513          	addi	a0,a0,1148 # 80247ac8 <ftable>
    80004654:	ee4fc0ef          	jal	ra,80000d38 <release>
  return f;
}
    80004658:	8526                	mv	a0,s1
    8000465a:	60e2                	ld	ra,24(sp)
    8000465c:	6442                	ld	s0,16(sp)
    8000465e:	64a2                	ld	s1,8(sp)
    80004660:	6105                	addi	sp,sp,32
    80004662:	8082                	ret
    panic("filedup");
    80004664:	00003517          	auipc	a0,0x3
    80004668:	02450513          	addi	a0,a0,36 # 80007688 <syscalls+0x290>
    8000466c:	91cfc0ef          	jal	ra,80000788 <panic>

0000000080004670 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004670:	7139                	addi	sp,sp,-64
    80004672:	fc06                	sd	ra,56(sp)
    80004674:	f822                	sd	s0,48(sp)
    80004676:	f426                	sd	s1,40(sp)
    80004678:	f04a                	sd	s2,32(sp)
    8000467a:	ec4e                	sd	s3,24(sp)
    8000467c:	e852                	sd	s4,16(sp)
    8000467e:	e456                	sd	s5,8(sp)
    80004680:	0080                	addi	s0,sp,64
    80004682:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004684:	00243517          	auipc	a0,0x243
    80004688:	44450513          	addi	a0,a0,1092 # 80247ac8 <ftable>
    8000468c:	e14fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004690:	40dc                	lw	a5,4(s1)
    80004692:	04f05963          	blez	a5,800046e4 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004696:	37fd                	addiw	a5,a5,-1
    80004698:	0007871b          	sext.w	a4,a5
    8000469c:	c0dc                	sw	a5,4(s1)
    8000469e:	04e04963          	bgtz	a4,800046f0 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046a2:	0004a903          	lw	s2,0(s1)
    800046a6:	0094ca83          	lbu	s5,9(s1)
    800046aa:	0104ba03          	ld	s4,16(s1)
    800046ae:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046b2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046b6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046ba:	00243517          	auipc	a0,0x243
    800046be:	40e50513          	addi	a0,a0,1038 # 80247ac8 <ftable>
    800046c2:	e76fc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    800046c6:	4785                	li	a5,1
    800046c8:	04f90363          	beq	s2,a5,8000470e <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046cc:	3979                	addiw	s2,s2,-2
    800046ce:	4785                	li	a5,1
    800046d0:	0327e663          	bltu	a5,s2,800046fc <fileclose+0x8c>
    begin_op();
    800046d4:	b93ff0ef          	jal	ra,80004266 <begin_op>
    iput(ff.ip);
    800046d8:	854e                	mv	a0,s3
    800046da:	b22ff0ef          	jal	ra,800039fc <iput>
    end_op();
    800046de:	bf7ff0ef          	jal	ra,800042d4 <end_op>
    800046e2:	a829                	j	800046fc <fileclose+0x8c>
    panic("fileclose");
    800046e4:	00003517          	auipc	a0,0x3
    800046e8:	fac50513          	addi	a0,a0,-84 # 80007690 <syscalls+0x298>
    800046ec:	89cfc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    800046f0:	00243517          	auipc	a0,0x243
    800046f4:	3d850513          	addi	a0,a0,984 # 80247ac8 <ftable>
    800046f8:	e40fc0ef          	jal	ra,80000d38 <release>
  }
}
    800046fc:	70e2                	ld	ra,56(sp)
    800046fe:	7442                	ld	s0,48(sp)
    80004700:	74a2                	ld	s1,40(sp)
    80004702:	7902                	ld	s2,32(sp)
    80004704:	69e2                	ld	s3,24(sp)
    80004706:	6a42                	ld	s4,16(sp)
    80004708:	6aa2                	ld	s5,8(sp)
    8000470a:	6121                	addi	sp,sp,64
    8000470c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000470e:	85d6                	mv	a1,s5
    80004710:	8552                	mv	a0,s4
    80004712:	2ec000ef          	jal	ra,800049fe <pipeclose>
    80004716:	b7dd                	j	800046fc <fileclose+0x8c>

0000000080004718 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004718:	715d                	addi	sp,sp,-80
    8000471a:	e486                	sd	ra,72(sp)
    8000471c:	e0a2                	sd	s0,64(sp)
    8000471e:	fc26                	sd	s1,56(sp)
    80004720:	f84a                	sd	s2,48(sp)
    80004722:	f44e                	sd	s3,40(sp)
    80004724:	0880                	addi	s0,sp,80
    80004726:	84aa                	mv	s1,a0
    80004728:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000472a:	bd8fd0ef          	jal	ra,80001b02 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000472e:	409c                	lw	a5,0(s1)
    80004730:	37f9                	addiw	a5,a5,-2
    80004732:	4705                	li	a4,1
    80004734:	02f76f63          	bltu	a4,a5,80004772 <filestat+0x5a>
    80004738:	892a                	mv	s2,a0
    ilock(f->ip);
    8000473a:	6c88                	ld	a0,24(s1)
    8000473c:	942ff0ef          	jal	ra,8000387e <ilock>
    stati(f->ip, &st);
    80004740:	fb840593          	addi	a1,s0,-72
    80004744:	6c88                	ld	a0,24(s1)
    80004746:	c9aff0ef          	jal	ra,80003be0 <stati>
    iunlock(f->ip);
    8000474a:	6c88                	ld	a0,24(s1)
    8000474c:	9dcff0ef          	jal	ra,80003928 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004750:	46e1                	li	a3,24
    80004752:	fb840613          	addi	a2,s0,-72
    80004756:	85ce                	mv	a1,s3
    80004758:	05093503          	ld	a0,80(s2)
    8000475c:	802fd0ef          	jal	ra,8000175e <copyout>
    80004760:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004764:	60a6                	ld	ra,72(sp)
    80004766:	6406                	ld	s0,64(sp)
    80004768:	74e2                	ld	s1,56(sp)
    8000476a:	7942                	ld	s2,48(sp)
    8000476c:	79a2                	ld	s3,40(sp)
    8000476e:	6161                	addi	sp,sp,80
    80004770:	8082                	ret
  return -1;
    80004772:	557d                	li	a0,-1
    80004774:	bfc5                	j	80004764 <filestat+0x4c>

0000000080004776 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004776:	7179                	addi	sp,sp,-48
    80004778:	f406                	sd	ra,40(sp)
    8000477a:	f022                	sd	s0,32(sp)
    8000477c:	ec26                	sd	s1,24(sp)
    8000477e:	e84a                	sd	s2,16(sp)
    80004780:	e44e                	sd	s3,8(sp)
    80004782:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004784:	00854783          	lbu	a5,8(a0)
    80004788:	cbc1                	beqz	a5,80004818 <fileread+0xa2>
    8000478a:	84aa                	mv	s1,a0
    8000478c:	89ae                	mv	s3,a1
    8000478e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004790:	411c                	lw	a5,0(a0)
    80004792:	4705                	li	a4,1
    80004794:	04e78363          	beq	a5,a4,800047da <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004798:	470d                	li	a4,3
    8000479a:	04e78563          	beq	a5,a4,800047e4 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000479e:	4709                	li	a4,2
    800047a0:	06e79663          	bne	a5,a4,8000480c <fileread+0x96>
    ilock(f->ip);
    800047a4:	6d08                	ld	a0,24(a0)
    800047a6:	8d8ff0ef          	jal	ra,8000387e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047aa:	874a                	mv	a4,s2
    800047ac:	5094                	lw	a3,32(s1)
    800047ae:	864e                	mv	a2,s3
    800047b0:	4585                	li	a1,1
    800047b2:	6c88                	ld	a0,24(s1)
    800047b4:	c56ff0ef          	jal	ra,80003c0a <readi>
    800047b8:	892a                	mv	s2,a0
    800047ba:	00a05563          	blez	a0,800047c4 <fileread+0x4e>
      f->off += r;
    800047be:	509c                	lw	a5,32(s1)
    800047c0:	9fa9                	addw	a5,a5,a0
    800047c2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047c4:	6c88                	ld	a0,24(s1)
    800047c6:	962ff0ef          	jal	ra,80003928 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047ca:	854a                	mv	a0,s2
    800047cc:	70a2                	ld	ra,40(sp)
    800047ce:	7402                	ld	s0,32(sp)
    800047d0:	64e2                	ld	s1,24(sp)
    800047d2:	6942                	ld	s2,16(sp)
    800047d4:	69a2                	ld	s3,8(sp)
    800047d6:	6145                	addi	sp,sp,48
    800047d8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047da:	6908                	ld	a0,16(a0)
    800047dc:	34e000ef          	jal	ra,80004b2a <piperead>
    800047e0:	892a                	mv	s2,a0
    800047e2:	b7e5                	j	800047ca <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047e4:	02451783          	lh	a5,36(a0)
    800047e8:	03079693          	slli	a3,a5,0x30
    800047ec:	92c1                	srli	a3,a3,0x30
    800047ee:	4725                	li	a4,9
    800047f0:	02d76663          	bltu	a4,a3,8000481c <fileread+0xa6>
    800047f4:	0792                	slli	a5,a5,0x4
    800047f6:	00243717          	auipc	a4,0x243
    800047fa:	23270713          	addi	a4,a4,562 # 80247a28 <devsw>
    800047fe:	97ba                	add	a5,a5,a4
    80004800:	639c                	ld	a5,0(a5)
    80004802:	cf99                	beqz	a5,80004820 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004804:	4505                	li	a0,1
    80004806:	9782                	jalr	a5
    80004808:	892a                	mv	s2,a0
    8000480a:	b7c1                	j	800047ca <fileread+0x54>
    panic("fileread");
    8000480c:	00003517          	auipc	a0,0x3
    80004810:	e9450513          	addi	a0,a0,-364 # 800076a0 <syscalls+0x2a8>
    80004814:	f75fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004818:	597d                	li	s2,-1
    8000481a:	bf45                	j	800047ca <fileread+0x54>
      return -1;
    8000481c:	597d                	li	s2,-1
    8000481e:	b775                	j	800047ca <fileread+0x54>
    80004820:	597d                	li	s2,-1
    80004822:	b765                	j	800047ca <fileread+0x54>

0000000080004824 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004824:	715d                	addi	sp,sp,-80
    80004826:	e486                	sd	ra,72(sp)
    80004828:	e0a2                	sd	s0,64(sp)
    8000482a:	fc26                	sd	s1,56(sp)
    8000482c:	f84a                	sd	s2,48(sp)
    8000482e:	f44e                	sd	s3,40(sp)
    80004830:	f052                	sd	s4,32(sp)
    80004832:	ec56                	sd	s5,24(sp)
    80004834:	e85a                	sd	s6,16(sp)
    80004836:	e45e                	sd	s7,8(sp)
    80004838:	e062                	sd	s8,0(sp)
    8000483a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000483c:	00954783          	lbu	a5,9(a0)
    80004840:	0e078863          	beqz	a5,80004930 <filewrite+0x10c>
    80004844:	892a                	mv	s2,a0
    80004846:	8b2e                	mv	s6,a1
    80004848:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000484a:	411c                	lw	a5,0(a0)
    8000484c:	4705                	li	a4,1
    8000484e:	02e78263          	beq	a5,a4,80004872 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004852:	470d                	li	a4,3
    80004854:	02e78463          	beq	a5,a4,8000487c <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004858:	4709                	li	a4,2
    8000485a:	0ce79563          	bne	a5,a4,80004924 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000485e:	0ac05163          	blez	a2,80004900 <filewrite+0xdc>
    int i = 0;
    80004862:	4981                	li	s3,0
    80004864:	6b85                	lui	s7,0x1
    80004866:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000486a:	6c05                	lui	s8,0x1
    8000486c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004870:	a041                	j	800048f0 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004872:	6908                	ld	a0,16(a0)
    80004874:	1e2000ef          	jal	ra,80004a56 <pipewrite>
    80004878:	8a2a                	mv	s4,a0
    8000487a:	a071                	j	80004906 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000487c:	02451783          	lh	a5,36(a0)
    80004880:	03079693          	slli	a3,a5,0x30
    80004884:	92c1                	srli	a3,a3,0x30
    80004886:	4725                	li	a4,9
    80004888:	0ad76663          	bltu	a4,a3,80004934 <filewrite+0x110>
    8000488c:	0792                	slli	a5,a5,0x4
    8000488e:	00243717          	auipc	a4,0x243
    80004892:	19a70713          	addi	a4,a4,410 # 80247a28 <devsw>
    80004896:	97ba                	add	a5,a5,a4
    80004898:	679c                	ld	a5,8(a5)
    8000489a:	cfd9                	beqz	a5,80004938 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000489c:	4505                	li	a0,1
    8000489e:	9782                	jalr	a5
    800048a0:	8a2a                	mv	s4,a0
    800048a2:	a095                	j	80004906 <filewrite+0xe2>
    800048a4:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800048a8:	9bfff0ef          	jal	ra,80004266 <begin_op>
      ilock(f->ip);
    800048ac:	01893503          	ld	a0,24(s2)
    800048b0:	fcffe0ef          	jal	ra,8000387e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048b4:	8756                	mv	a4,s5
    800048b6:	02092683          	lw	a3,32(s2)
    800048ba:	01698633          	add	a2,s3,s6
    800048be:	4585                	li	a1,1
    800048c0:	01893503          	ld	a0,24(s2)
    800048c4:	c2aff0ef          	jal	ra,80003cee <writei>
    800048c8:	84aa                	mv	s1,a0
    800048ca:	00a05763          	blez	a0,800048d8 <filewrite+0xb4>
        f->off += r;
    800048ce:	02092783          	lw	a5,32(s2)
    800048d2:	9fa9                	addw	a5,a5,a0
    800048d4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048d8:	01893503          	ld	a0,24(s2)
    800048dc:	84cff0ef          	jal	ra,80003928 <iunlock>
      end_op();
    800048e0:	9f5ff0ef          	jal	ra,800042d4 <end_op>

      if(r != n1){
    800048e4:	009a9f63          	bne	s5,s1,80004902 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800048e8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048ec:	0149db63          	bge	s3,s4,80004902 <filewrite+0xde>
      int n1 = n - i;
    800048f0:	413a04bb          	subw	s1,s4,s3
    800048f4:	0004879b          	sext.w	a5,s1
    800048f8:	fafbd6e3          	bge	s7,a5,800048a4 <filewrite+0x80>
    800048fc:	84e2                	mv	s1,s8
    800048fe:	b75d                	j	800048a4 <filewrite+0x80>
    int i = 0;
    80004900:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004902:	013a1f63          	bne	s4,s3,80004920 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004906:	8552                	mv	a0,s4
    80004908:	60a6                	ld	ra,72(sp)
    8000490a:	6406                	ld	s0,64(sp)
    8000490c:	74e2                	ld	s1,56(sp)
    8000490e:	7942                	ld	s2,48(sp)
    80004910:	79a2                	ld	s3,40(sp)
    80004912:	7a02                	ld	s4,32(sp)
    80004914:	6ae2                	ld	s5,24(sp)
    80004916:	6b42                	ld	s6,16(sp)
    80004918:	6ba2                	ld	s7,8(sp)
    8000491a:	6c02                	ld	s8,0(sp)
    8000491c:	6161                	addi	sp,sp,80
    8000491e:	8082                	ret
    ret = (i == n ? n : -1);
    80004920:	5a7d                	li	s4,-1
    80004922:	b7d5                	j	80004906 <filewrite+0xe2>
    panic("filewrite");
    80004924:	00003517          	auipc	a0,0x3
    80004928:	d8c50513          	addi	a0,a0,-628 # 800076b0 <syscalls+0x2b8>
    8000492c:	e5dfb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004930:	5a7d                	li	s4,-1
    80004932:	bfd1                	j	80004906 <filewrite+0xe2>
      return -1;
    80004934:	5a7d                	li	s4,-1
    80004936:	bfc1                	j	80004906 <filewrite+0xe2>
    80004938:	5a7d                	li	s4,-1
    8000493a:	b7f1                	j	80004906 <filewrite+0xe2>

000000008000493c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000493c:	7179                	addi	sp,sp,-48
    8000493e:	f406                	sd	ra,40(sp)
    80004940:	f022                	sd	s0,32(sp)
    80004942:	ec26                	sd	s1,24(sp)
    80004944:	e84a                	sd	s2,16(sp)
    80004946:	e44e                	sd	s3,8(sp)
    80004948:	e052                	sd	s4,0(sp)
    8000494a:	1800                	addi	s0,sp,48
    8000494c:	84aa                	mv	s1,a0
    8000494e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004950:	0005b023          	sd	zero,0(a1)
    80004954:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004958:	c75ff0ef          	jal	ra,800045cc <filealloc>
    8000495c:	e088                	sd	a0,0(s1)
    8000495e:	cd35                	beqz	a0,800049da <pipealloc+0x9e>
    80004960:	c6dff0ef          	jal	ra,800045cc <filealloc>
    80004964:	00aa3023          	sd	a0,0(s4)
    80004968:	c52d                	beqz	a0,800049d2 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000496a:	a40fc0ef          	jal	ra,80000baa <kalloc>
    8000496e:	892a                	mv	s2,a0
    80004970:	cd31                	beqz	a0,800049cc <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004972:	4985                	li	s3,1
    80004974:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004978:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000497c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004980:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004984:	00003597          	auipc	a1,0x3
    80004988:	d3c58593          	addi	a1,a1,-708 # 800076c0 <syscalls+0x2c8>
    8000498c:	a94fc0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004990:	609c                	ld	a5,0(s1)
    80004992:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004996:	609c                	ld	a5,0(s1)
    80004998:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000499c:	609c                	ld	a5,0(s1)
    8000499e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049a2:	609c                	ld	a5,0(s1)
    800049a4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049a8:	000a3783          	ld	a5,0(s4)
    800049ac:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049b0:	000a3783          	ld	a5,0(s4)
    800049b4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049b8:	000a3783          	ld	a5,0(s4)
    800049bc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049c0:	000a3783          	ld	a5,0(s4)
    800049c4:	0127b823          	sd	s2,16(a5)
  return 0;
    800049c8:	4501                	li	a0,0
    800049ca:	a005                	j	800049ea <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049cc:	6088                	ld	a0,0(s1)
    800049ce:	e501                	bnez	a0,800049d6 <pipealloc+0x9a>
    800049d0:	a029                	j	800049da <pipealloc+0x9e>
    800049d2:	6088                	ld	a0,0(s1)
    800049d4:	c11d                	beqz	a0,800049fa <pipealloc+0xbe>
    fileclose(*f0);
    800049d6:	c9bff0ef          	jal	ra,80004670 <fileclose>
  if(*f1)
    800049da:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049de:	557d                	li	a0,-1
  if(*f1)
    800049e0:	c789                	beqz	a5,800049ea <pipealloc+0xae>
    fileclose(*f1);
    800049e2:	853e                	mv	a0,a5
    800049e4:	c8dff0ef          	jal	ra,80004670 <fileclose>
  return -1;
    800049e8:	557d                	li	a0,-1
}
    800049ea:	70a2                	ld	ra,40(sp)
    800049ec:	7402                	ld	s0,32(sp)
    800049ee:	64e2                	ld	s1,24(sp)
    800049f0:	6942                	ld	s2,16(sp)
    800049f2:	69a2                	ld	s3,8(sp)
    800049f4:	6a02                	ld	s4,0(sp)
    800049f6:	6145                	addi	sp,sp,48
    800049f8:	8082                	ret
  return -1;
    800049fa:	557d                	li	a0,-1
    800049fc:	b7fd                	j	800049ea <pipealloc+0xae>

00000000800049fe <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049fe:	1101                	addi	sp,sp,-32
    80004a00:	ec06                	sd	ra,24(sp)
    80004a02:	e822                	sd	s0,16(sp)
    80004a04:	e426                	sd	s1,8(sp)
    80004a06:	e04a                	sd	s2,0(sp)
    80004a08:	1000                	addi	s0,sp,32
    80004a0a:	84aa                	mv	s1,a0
    80004a0c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a0e:	a92fc0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    80004a12:	02090763          	beqz	s2,80004a40 <pipeclose+0x42>
    pi->writeopen = 0;
    80004a16:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a1a:	21848513          	addi	a0,s1,536
    80004a1e:	f9efd0ef          	jal	ra,800021bc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a22:	2204b783          	ld	a5,544(s1)
    80004a26:	e785                	bnez	a5,80004a4e <pipeclose+0x50>
    release(&pi->lock);
    80004a28:	8526                	mv	a0,s1
    80004a2a:	b0efc0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004a2e:	8526                	mv	a0,s1
    80004a30:	84afc0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004a34:	60e2                	ld	ra,24(sp)
    80004a36:	6442                	ld	s0,16(sp)
    80004a38:	64a2                	ld	s1,8(sp)
    80004a3a:	6902                	ld	s2,0(sp)
    80004a3c:	6105                	addi	sp,sp,32
    80004a3e:	8082                	ret
    pi->readopen = 0;
    80004a40:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a44:	21c48513          	addi	a0,s1,540
    80004a48:	f74fd0ef          	jal	ra,800021bc <wakeup>
    80004a4c:	bfd9                	j	80004a22 <pipeclose+0x24>
    release(&pi->lock);
    80004a4e:	8526                	mv	a0,s1
    80004a50:	ae8fc0ef          	jal	ra,80000d38 <release>
}
    80004a54:	b7c5                	j	80004a34 <pipeclose+0x36>

0000000080004a56 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a56:	711d                	addi	sp,sp,-96
    80004a58:	ec86                	sd	ra,88(sp)
    80004a5a:	e8a2                	sd	s0,80(sp)
    80004a5c:	e4a6                	sd	s1,72(sp)
    80004a5e:	e0ca                	sd	s2,64(sp)
    80004a60:	fc4e                	sd	s3,56(sp)
    80004a62:	f852                	sd	s4,48(sp)
    80004a64:	f456                	sd	s5,40(sp)
    80004a66:	f05a                	sd	s6,32(sp)
    80004a68:	ec5e                	sd	s7,24(sp)
    80004a6a:	e862                	sd	s8,16(sp)
    80004a6c:	1080                	addi	s0,sp,96
    80004a6e:	84aa                	mv	s1,a0
    80004a70:	8aae                	mv	s5,a1
    80004a72:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a74:	88efd0ef          	jal	ra,80001b02 <myproc>
    80004a78:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	a24fc0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004a80:	09405c63          	blez	s4,80004b18 <pipewrite+0xc2>
  int i = 0;
    80004a84:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a86:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a88:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a8c:	21c48b93          	addi	s7,s1,540
    80004a90:	a81d                	j	80004ac6 <pipewrite+0x70>
      release(&pi->lock);
    80004a92:	8526                	mv	a0,s1
    80004a94:	aa4fc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004a98:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	60e6                	ld	ra,88(sp)
    80004a9e:	6446                	ld	s0,80(sp)
    80004aa0:	64a6                	ld	s1,72(sp)
    80004aa2:	6906                	ld	s2,64(sp)
    80004aa4:	79e2                	ld	s3,56(sp)
    80004aa6:	7a42                	ld	s4,48(sp)
    80004aa8:	7aa2                	ld	s5,40(sp)
    80004aaa:	7b02                	ld	s6,32(sp)
    80004aac:	6be2                	ld	s7,24(sp)
    80004aae:	6c42                	ld	s8,16(sp)
    80004ab0:	6125                	addi	sp,sp,96
    80004ab2:	8082                	ret
      wakeup(&pi->nread);
    80004ab4:	8562                	mv	a0,s8
    80004ab6:	f06fd0ef          	jal	ra,800021bc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004aba:	85a6                	mv	a1,s1
    80004abc:	855e                	mv	a0,s7
    80004abe:	eb2fd0ef          	jal	ra,80002170 <sleep>
  while(i < n){
    80004ac2:	05495c63          	bge	s2,s4,80004b1a <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004ac6:	2204a783          	lw	a5,544(s1)
    80004aca:	d7e1                	beqz	a5,80004a92 <pipewrite+0x3c>
    80004acc:	854e                	mv	a0,s3
    80004ace:	8dbfd0ef          	jal	ra,800023a8 <killed>
    80004ad2:	f161                	bnez	a0,80004a92 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ad4:	2184a783          	lw	a5,536(s1)
    80004ad8:	21c4a703          	lw	a4,540(s1)
    80004adc:	2007879b          	addiw	a5,a5,512
    80004ae0:	fcf70ae3          	beq	a4,a5,80004ab4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ae4:	4685                	li	a3,1
    80004ae6:	01590633          	add	a2,s2,s5
    80004aea:	faf40593          	addi	a1,s0,-81
    80004aee:	0509b503          	ld	a0,80(s3)
    80004af2:	d57fc0ef          	jal	ra,80001848 <copyin>
    80004af6:	03650263          	beq	a0,s6,80004b1a <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004afa:	21c4a783          	lw	a5,540(s1)
    80004afe:	0017871b          	addiw	a4,a5,1
    80004b02:	20e4ae23          	sw	a4,540(s1)
    80004b06:	1ff7f793          	andi	a5,a5,511
    80004b0a:	97a6                	add	a5,a5,s1
    80004b0c:	faf44703          	lbu	a4,-81(s0)
    80004b10:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b14:	2905                	addiw	s2,s2,1
    80004b16:	b775                	j	80004ac2 <pipewrite+0x6c>
  int i = 0;
    80004b18:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b1a:	21848513          	addi	a0,s1,536
    80004b1e:	e9efd0ef          	jal	ra,800021bc <wakeup>
  release(&pi->lock);
    80004b22:	8526                	mv	a0,s1
    80004b24:	a14fc0ef          	jal	ra,80000d38 <release>
  return i;
    80004b28:	bf8d                	j	80004a9a <pipewrite+0x44>

0000000080004b2a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b2a:	715d                	addi	sp,sp,-80
    80004b2c:	e486                	sd	ra,72(sp)
    80004b2e:	e0a2                	sd	s0,64(sp)
    80004b30:	fc26                	sd	s1,56(sp)
    80004b32:	f84a                	sd	s2,48(sp)
    80004b34:	f44e                	sd	s3,40(sp)
    80004b36:	f052                	sd	s4,32(sp)
    80004b38:	ec56                	sd	s5,24(sp)
    80004b3a:	e85a                	sd	s6,16(sp)
    80004b3c:	0880                	addi	s0,sp,80
    80004b3e:	84aa                	mv	s1,a0
    80004b40:	892e                	mv	s2,a1
    80004b42:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b44:	fbffc0ef          	jal	ra,80001b02 <myproc>
    80004b48:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	954fc0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b50:	2184a703          	lw	a4,536(s1)
    80004b54:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b58:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b5c:	02f71363          	bne	a4,a5,80004b82 <piperead+0x58>
    80004b60:	2244a783          	lw	a5,548(s1)
    80004b64:	cf99                	beqz	a5,80004b82 <piperead+0x58>
    if(killed(pr)){
    80004b66:	8552                	mv	a0,s4
    80004b68:	841fd0ef          	jal	ra,800023a8 <killed>
    80004b6c:	e151                	bnez	a0,80004bf0 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b6e:	85a6                	mv	a1,s1
    80004b70:	854e                	mv	a0,s3
    80004b72:	dfefd0ef          	jal	ra,80002170 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b76:	2184a703          	lw	a4,536(s1)
    80004b7a:	21c4a783          	lw	a5,540(s1)
    80004b7e:	fef701e3          	beq	a4,a5,80004b60 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b82:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b84:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b86:	05505363          	blez	s5,80004bcc <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    80004b8a:	2184a783          	lw	a5,536(s1)
    80004b8e:	21c4a703          	lw	a4,540(s1)
    80004b92:	02f70d63          	beq	a4,a5,80004bcc <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004b96:	1ff7f793          	andi	a5,a5,511
    80004b9a:	97a6                	add	a5,a5,s1
    80004b9c:	0187c783          	lbu	a5,24(a5)
    80004ba0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004ba4:	4685                	li	a3,1
    80004ba6:	fbf40613          	addi	a2,s0,-65
    80004baa:	85ca                	mv	a1,s2
    80004bac:	050a3503          	ld	a0,80(s4)
    80004bb0:	baffc0ef          	jal	ra,8000175e <copyout>
    80004bb4:	05650363          	beq	a0,s6,80004bfa <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004bb8:	2184a783          	lw	a5,536(s1)
    80004bbc:	2785                	addiw	a5,a5,1
    80004bbe:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bc2:	2985                	addiw	s3,s3,1
    80004bc4:	0905                	addi	s2,s2,1
    80004bc6:	fd3a92e3          	bne	s5,s3,80004b8a <piperead+0x60>
    80004bca:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bcc:	21c48513          	addi	a0,s1,540
    80004bd0:	decfd0ef          	jal	ra,800021bc <wakeup>
  release(&pi->lock);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	962fc0ef          	jal	ra,80000d38 <release>
  return i;
}
    80004bda:	854e                	mv	a0,s3
    80004bdc:	60a6                	ld	ra,72(sp)
    80004bde:	6406                	ld	s0,64(sp)
    80004be0:	74e2                	ld	s1,56(sp)
    80004be2:	7942                	ld	s2,48(sp)
    80004be4:	79a2                	ld	s3,40(sp)
    80004be6:	7a02                	ld	s4,32(sp)
    80004be8:	6ae2                	ld	s5,24(sp)
    80004bea:	6b42                	ld	s6,16(sp)
    80004bec:	6161                	addi	sp,sp,80
    80004bee:	8082                	ret
      release(&pi->lock);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	946fc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004bf6:	59fd                	li	s3,-1
    80004bf8:	b7cd                	j	80004bda <piperead+0xb0>
      if(i == 0)
    80004bfa:	fc0999e3          	bnez	s3,80004bcc <piperead+0xa2>
        i = -1;
    80004bfe:	89aa                	mv	s3,a0
    80004c00:	b7f1                	j	80004bcc <piperead+0xa2>

0000000080004c02 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004c02:	1141                	addi	sp,sp,-16
    80004c04:	e422                	sd	s0,8(sp)
    80004c06:	0800                	addi	s0,sp,16
    80004c08:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c0a:	8905                	andi	a0,a0,1
    80004c0c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c0e:	8b89                	andi	a5,a5,2
    80004c10:	c399                	beqz	a5,80004c16 <flags2perm+0x14>
      perm |= PTE_W;
    80004c12:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c16:	6422                	ld	s0,8(sp)
    80004c18:	0141                	addi	sp,sp,16
    80004c1a:	8082                	ret

0000000080004c1c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004c1c:	bd010113          	addi	sp,sp,-1072
    80004c20:	42113423          	sd	ra,1064(sp)
    80004c24:	42813023          	sd	s0,1056(sp)
    80004c28:	40913c23          	sd	s1,1048(sp)
    80004c2c:	41213823          	sd	s2,1040(sp)
    80004c30:	41313423          	sd	s3,1032(sp)
    80004c34:	41413023          	sd	s4,1024(sp)
    80004c38:	3f513c23          	sd	s5,1016(sp)
    80004c3c:	3f613823          	sd	s6,1008(sp)
    80004c40:	3f713423          	sd	s7,1000(sp)
    80004c44:	3f813023          	sd	s8,992(sp)
    80004c48:	3d913c23          	sd	s9,984(sp)
    80004c4c:	3da13823          	sd	s10,976(sp)
    80004c50:	3db13423          	sd	s11,968(sp)
    80004c54:	43010413          	addi	s0,sp,1072
    80004c58:	84aa                	mv	s1,a0
    80004c5a:	bea43023          	sd	a0,-1056(s0)
    80004c5e:	beb43423          	sd	a1,-1048(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c62:	ea1fc0ef          	jal	ra,80001b02 <myproc>
    80004c66:	bea43c23          	sd	a0,-1032(s0)

  begin_op();
    80004c6a:	dfcff0ef          	jal	ra,80004266 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004c6e:	8526                	mv	a0,s1
    80004c70:	c02ff0ef          	jal	ra,80004072 <namei>
    80004c74:	cd25                	beqz	a0,80004cec <kexec+0xd0>
    80004c76:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c78:	c07fe0ef          	jal	ra,8000387e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c7c:	04000713          	li	a4,64
    80004c80:	4681                	li	a3,0
    80004c82:	e5040613          	addi	a2,s0,-432
    80004c86:	4581                	li	a1,0
    80004c88:	8556                	mv	a0,s5
    80004c8a:	f81fe0ef          	jal	ra,80003c0a <readi>
    80004c8e:	04000793          	li	a5,64
    80004c92:	00f51a63          	bne	a0,a5,80004ca6 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004c96:	e5042703          	lw	a4,-432(s0)
    80004c9a:	464c47b7          	lui	a5,0x464c4
    80004c9e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ca2:	04f70963          	beq	a4,a5,80004cf4 <kexec+0xd8>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    memset(p->vmas, 0, sizeof(p->vmas));
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80004ca6:	8556                	mv	a0,s5
    80004ca8:	dddfe0ef          	jal	ra,80003a84 <iunlockput>
    end_op();
    80004cac:	e28ff0ef          	jal	ra,800042d4 <end_op>
  }
  return -1;
    80004cb0:	557d                	li	a0,-1
}
    80004cb2:	42813083          	ld	ra,1064(sp)
    80004cb6:	42013403          	ld	s0,1056(sp)
    80004cba:	41813483          	ld	s1,1048(sp)
    80004cbe:	41013903          	ld	s2,1040(sp)
    80004cc2:	40813983          	ld	s3,1032(sp)
    80004cc6:	40013a03          	ld	s4,1024(sp)
    80004cca:	3f813a83          	ld	s5,1016(sp)
    80004cce:	3f013b03          	ld	s6,1008(sp)
    80004cd2:	3e813b83          	ld	s7,1000(sp)
    80004cd6:	3e013c03          	ld	s8,992(sp)
    80004cda:	3d813c83          	ld	s9,984(sp)
    80004cde:	3d013d03          	ld	s10,976(sp)
    80004ce2:	3c813d83          	ld	s11,968(sp)
    80004ce6:	43010113          	addi	sp,sp,1072
    80004cea:	8082                	ret
    end_op();
    80004cec:	de8ff0ef          	jal	ra,800042d4 <end_op>
    return -1;
    80004cf0:	557d                	li	a0,-1
    80004cf2:	b7c1                	j	80004cb2 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80004cf4:	bf843503          	ld	a0,-1032(s0)
    80004cf8:	f11fc0ef          	jal	ra,80001c08 <proc_pagetable>
    80004cfc:	8baa                	mv	s7,a0
    80004cfe:	d545                	beqz	a0,80004ca6 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d00:	e7042783          	lw	a5,-400(s0)
    80004d04:	e8845703          	lhu	a4,-376(s0)
    80004d08:	0e070d63          	beqz	a4,80004e02 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d0c:	be043823          	sd	zero,-1040(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d10:	c0043423          	sd	zero,-1016(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004d14:	6a05                	lui	s4,0x1
    80004d16:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d1a:	bce43c23          	sd	a4,-1064(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004d1e:	6d85                	lui	s11,0x1
    80004d20:	7d7d                	lui	s10,0xfffff
    80004d22:	a09d                	j	80004d88 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d24:	00003517          	auipc	a0,0x3
    80004d28:	9a450513          	addi	a0,a0,-1628 # 800076c8 <syscalls+0x2d0>
    80004d2c:	a5dfb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d30:	874a                	mv	a4,s2
    80004d32:	009c86bb          	addw	a3,s9,s1
    80004d36:	4581                	li	a1,0
    80004d38:	8556                	mv	a0,s5
    80004d3a:	ed1fe0ef          	jal	ra,80003c0a <readi>
    80004d3e:	2501                	sext.w	a0,a0
    80004d40:	0ea91f63          	bne	s2,a0,80004e3e <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    80004d44:	009d84bb          	addw	s1,s11,s1
    80004d48:	013d09bb          	addw	s3,s10,s3
    80004d4c:	0364f063          	bgeu	s1,s6,80004d6c <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004d50:	02049593          	slli	a1,s1,0x20
    80004d54:	9181                	srli	a1,a1,0x20
    80004d56:	95e2                	add	a1,a1,s8
    80004d58:	855e                	mv	a0,s7
    80004d5a:	b30fc0ef          	jal	ra,8000108a <walkaddr>
    80004d5e:	862a                	mv	a2,a0
    if(pa == 0)
    80004d60:	d171                	beqz	a0,80004d24 <kexec+0x108>
      n = PGSIZE;
    80004d62:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d64:	fd49f6e3          	bgeu	s3,s4,80004d30 <kexec+0x114>
      n = sz - i;
    80004d68:	894e                	mv	s2,s3
    80004d6a:	b7d9                	j	80004d30 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d6c:	c0843783          	ld	a5,-1016(s0)
    80004d70:	0017869b          	addiw	a3,a5,1
    80004d74:	c0d43423          	sd	a3,-1016(s0)
    80004d78:	c0043783          	ld	a5,-1024(s0)
    80004d7c:	0387879b          	addiw	a5,a5,56
    80004d80:	e8845703          	lhu	a4,-376(s0)
    80004d84:	08e6d163          	bge	a3,a4,80004e06 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d88:	2781                	sext.w	a5,a5
    80004d8a:	c0f43023          	sd	a5,-1024(s0)
    80004d8e:	03800713          	li	a4,56
    80004d92:	86be                	mv	a3,a5
    80004d94:	e1840613          	addi	a2,s0,-488
    80004d98:	4581                	li	a1,0
    80004d9a:	8556                	mv	a0,s5
    80004d9c:	e6ffe0ef          	jal	ra,80003c0a <readi>
    80004da0:	03800793          	li	a5,56
    80004da4:	08f51d63          	bne	a0,a5,80004e3e <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80004da8:	e1842783          	lw	a5,-488(s0)
    80004dac:	4705                	li	a4,1
    80004dae:	fae79fe3          	bne	a5,a4,80004d6c <kexec+0x150>
    if(ph.memsz < ph.filesz)
    80004db2:	e4043483          	ld	s1,-448(s0)
    80004db6:	e3843783          	ld	a5,-456(s0)
    80004dba:	08f4e263          	bltu	s1,a5,80004e3e <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004dbe:	e2843783          	ld	a5,-472(s0)
    80004dc2:	94be                	add	s1,s1,a5
    80004dc4:	06f4ed63          	bltu	s1,a5,80004e3e <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80004dc8:	bd843703          	ld	a4,-1064(s0)
    80004dcc:	8ff9                	and	a5,a5,a4
    80004dce:	eba5                	bnez	a5,80004e3e <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dd0:	e1c42503          	lw	a0,-484(s0)
    80004dd4:	e2fff0ef          	jal	ra,80004c02 <flags2perm>
    80004dd8:	86aa                	mv	a3,a0
    80004dda:	8626                	mv	a2,s1
    80004ddc:	bf043583          	ld	a1,-1040(s0)
    80004de0:	855e                	mv	a0,s7
    80004de2:	d72fc0ef          	jal	ra,80001354 <uvmalloc>
    80004de6:	bea43823          	sd	a0,-1040(s0)
    80004dea:	c931                	beqz	a0,80004e3e <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004dec:	e2843c03          	ld	s8,-472(s0)
    80004df0:	e2042c83          	lw	s9,-480(s0)
    80004df4:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004df8:	f60b0ae3          	beqz	s6,80004d6c <kexec+0x150>
    80004dfc:	89da                	mv	s3,s6
    80004dfe:	4481                	li	s1,0
    80004e00:	bf81                	j	80004d50 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e02:	be043823          	sd	zero,-1040(s0)
  iunlockput(ip);
    80004e06:	8556                	mv	a0,s5
    80004e08:	c7dfe0ef          	jal	ra,80003a84 <iunlockput>
  end_op();
    80004e0c:	cc8ff0ef          	jal	ra,800042d4 <end_op>
  p = myproc();
    80004e10:	cf3fc0ef          	jal	ra,80001b02 <myproc>
    80004e14:	bea43c23          	sd	a0,-1032(s0)
  uint64 oldsz = p->sz;
    80004e18:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e1c:	6785                	lui	a5,0x1
    80004e1e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004e20:	bf043703          	ld	a4,-1040(s0)
    80004e24:	00f705b3          	add	a1,a4,a5
    80004e28:	77fd                	lui	a5,0xfffff
    80004e2a:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004e2c:	4691                	li	a3,4
    80004e2e:	6609                	lui	a2,0x2
    80004e30:	962e                	add	a2,a2,a1
    80004e32:	855e                	mv	a0,s7
    80004e34:	d20fc0ef          	jal	ra,80001354 <uvmalloc>
    80004e38:	8b2a                	mv	s6,a0
  ip = 0;
    80004e3a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004e3c:	e915                	bnez	a0,80004e70 <kexec+0x254>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80004e3e:	bf843903          	ld	s2,-1032(s0)
    80004e42:	16890493          	addi	s1,s2,360
    80004e46:	85a6                	mv	a1,s1
    80004e48:	05093503          	ld	a0,80(s2)
    80004e4c:	e41fc0ef          	jal	ra,80001c8c <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80004e50:	20000613          	li	a2,512
    80004e54:	4581                	li	a1,0
    80004e56:	8526                	mv	a0,s1
    80004e58:	f1dfb0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80004e5c:	04893583          	ld	a1,72(s2)
    80004e60:	05093503          	ld	a0,80(s2)
    80004e64:	e73fc0ef          	jal	ra,80001cd6 <proc_freepagetable>
  if(ip){
    80004e68:	e20a9fe3          	bnez	s5,80004ca6 <kexec+0x8a>
  return -1;
    80004e6c:	557d                	li	a0,-1
    80004e6e:	b591                	j	80004cb2 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004e70:	75f9                	lui	a1,0xffffe
    80004e72:	95aa                	add	a1,a1,a0
    80004e74:	855e                	mv	a0,s7
    80004e76:	f80fc0ef          	jal	ra,800015f6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004e7a:	7c7d                	lui	s8,0xfffff
    80004e7c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e7e:	be843783          	ld	a5,-1048(s0)
    80004e82:	6388                	ld	a0,0(a5)
    80004e84:	c125                	beqz	a0,80004ee4 <kexec+0x2c8>
    80004e86:	e9040993          	addi	s3,s0,-368
    80004e8a:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    80004e8e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e90:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e92:	85afc0ef          	jal	ra,80000eec <strlen>
    80004e96:	0015079b          	addiw	a5,a0,1
    80004e9a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e9e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ea2:	11896563          	bltu	s2,s8,80004fac <kexec+0x390>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ea6:	be843d03          	ld	s10,-1048(s0)
    80004eaa:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdb6440>
    80004eae:	8552                	mv	a0,s4
    80004eb0:	83cfc0ef          	jal	ra,80000eec <strlen>
    80004eb4:	0015069b          	addiw	a3,a0,1
    80004eb8:	8652                	mv	a2,s4
    80004eba:	85ca                	mv	a1,s2
    80004ebc:	855e                	mv	a0,s7
    80004ebe:	8a1fc0ef          	jal	ra,8000175e <copyout>
    80004ec2:	0e054763          	bltz	a0,80004fb0 <kexec+0x394>
    ustack[argc] = sp;
    80004ec6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004eca:	0485                	addi	s1,s1,1
    80004ecc:	008d0793          	addi	a5,s10,8
    80004ed0:	bef43423          	sd	a5,-1048(s0)
    80004ed4:	008d3503          	ld	a0,8(s10)
    80004ed8:	c901                	beqz	a0,80004ee8 <kexec+0x2cc>
    if(argc >= MAXARG)
    80004eda:	09a1                	addi	s3,s3,8
    80004edc:	fb599be3          	bne	s3,s5,80004e92 <kexec+0x276>
  ip = 0;
    80004ee0:	4a81                	li	s5,0
    80004ee2:	bfb1                	j	80004e3e <kexec+0x222>
  sp = sz;
    80004ee4:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ee6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004ee8:	00349793          	slli	a5,s1,0x3
    80004eec:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdb63d0>
    80004ef0:	97a2                	add	a5,a5,s0
    80004ef2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ef6:	00148693          	addi	a3,s1,1
    80004efa:	068e                	slli	a3,a3,0x3
    80004efc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f00:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80004f04:	4a81                	li	s5,0
  if(sp < stackbase)
    80004f06:	f3896ce3          	bltu	s2,s8,80004e3e <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f0a:	e9040613          	addi	a2,s0,-368
    80004f0e:	85ca                	mv	a1,s2
    80004f10:	855e                	mv	a0,s7
    80004f12:	84dfc0ef          	jal	ra,8000175e <copyout>
    80004f16:	08054f63          	bltz	a0,80004fb4 <kexec+0x398>
  p->trapframe->a1 = sp;
    80004f1a:	bf843783          	ld	a5,-1032(s0)
    80004f1e:	6fbc                	ld	a5,88(a5)
    80004f20:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f24:	be043783          	ld	a5,-1056(s0)
    80004f28:	0007c703          	lbu	a4,0(a5)
    80004f2c:	cf11                	beqz	a4,80004f48 <kexec+0x32c>
    80004f2e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f30:	02f00693          	li	a3,47
    80004f34:	a039                	j	80004f42 <kexec+0x326>
      last = s+1;
    80004f36:	bef43023          	sd	a5,-1056(s0)
  for(last=s=path; *s; s++)
    80004f3a:	0785                	addi	a5,a5,1
    80004f3c:	fff7c703          	lbu	a4,-1(a5)
    80004f40:	c701                	beqz	a4,80004f48 <kexec+0x32c>
    if(*s == '/')
    80004f42:	fed71ce3          	bne	a4,a3,80004f3a <kexec+0x31e>
    80004f46:	bfc5                	j	80004f36 <kexec+0x31a>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f48:	4641                	li	a2,16
    80004f4a:	be043583          	ld	a1,-1056(s0)
    80004f4e:	bf843983          	ld	s3,-1032(s0)
    80004f52:	15898513          	addi	a0,s3,344
    80004f56:	f65fb0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    80004f5a:	16898a13          	addi	s4,s3,360
    80004f5e:	20000613          	li	a2,512
    80004f62:	85d2                	mv	a1,s4
    80004f64:	c1840513          	addi	a0,s0,-1000
    80004f68:	e69fb0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    80004f6c:	86ce                	mv	a3,s3
    80004f6e:	0509b983          	ld	s3,80(s3)
  p->pagetable = pagetable;
    80004f72:	0576b823          	sd	s7,80(a3)
  p->sz = sz;
    80004f76:	0566b423          	sd	s6,72(a3)
  p->trapframe->epc = elf.entry;
    80004f7a:	6ebc                	ld	a5,88(a3)
    80004f7c:	e6843703          	ld	a4,-408(s0)
    80004f80:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    80004f82:	6ebc                	ld	a5,88(a3)
    80004f84:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    80004f88:	20000613          	li	a2,512
    80004f8c:	4581                	li	a1,0
    80004f8e:	8552                	mv	a0,s4
    80004f90:	de5fb0ef          	jal	ra,80000d74 <memset>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    80004f94:	c1840593          	addi	a1,s0,-1000
    80004f98:	854e                	mv	a0,s3
    80004f9a:	cf3fc0ef          	jal	ra,80001c8c <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    80004f9e:	85e6                	mv	a1,s9
    80004fa0:	854e                	mv	a0,s3
    80004fa2:	d35fc0ef          	jal	ra,80001cd6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fa6:	0004851b          	sext.w	a0,s1
    80004faa:	b321                	j	80004cb2 <kexec+0x96>
  ip = 0;
    80004fac:	4a81                	li	s5,0
    80004fae:	bd41                	j	80004e3e <kexec+0x222>
    80004fb0:	4a81                	li	s5,0
    80004fb2:	b571                	j	80004e3e <kexec+0x222>
    80004fb4:	4a81                	li	s5,0
    80004fb6:	b561                	j	80004e3e <kexec+0x222>

0000000080004fb8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fb8:	7179                	addi	sp,sp,-48
    80004fba:	f406                	sd	ra,40(sp)
    80004fbc:	f022                	sd	s0,32(sp)
    80004fbe:	ec26                	sd	s1,24(sp)
    80004fc0:	e84a                	sd	s2,16(sp)
    80004fc2:	1800                	addi	s0,sp,48
    80004fc4:	892e                	mv	s2,a1
    80004fc6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fc8:	fdc40593          	addi	a1,s0,-36
    80004fcc:	addfd0ef          	jal	ra,80002aa8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fd0:	fdc42703          	lw	a4,-36(s0)
    80004fd4:	47bd                	li	a5,15
    80004fd6:	02e7e963          	bltu	a5,a4,80005008 <argfd+0x50>
    80004fda:	b29fc0ef          	jal	ra,80001b02 <myproc>
    80004fde:	fdc42703          	lw	a4,-36(s0)
    80004fe2:	01a70793          	addi	a5,a4,26
    80004fe6:	078e                	slli	a5,a5,0x3
    80004fe8:	953e                	add	a0,a0,a5
    80004fea:	611c                	ld	a5,0(a0)
    80004fec:	c385                	beqz	a5,8000500c <argfd+0x54>
    return -1;
  if(pfd)
    80004fee:	00090463          	beqz	s2,80004ff6 <argfd+0x3e>
    *pfd = fd;
    80004ff2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ff6:	4501                	li	a0,0
  if(pf)
    80004ff8:	c091                	beqz	s1,80004ffc <argfd+0x44>
    *pf = f;
    80004ffa:	e09c                	sd	a5,0(s1)
}
    80004ffc:	70a2                	ld	ra,40(sp)
    80004ffe:	7402                	ld	s0,32(sp)
    80005000:	64e2                	ld	s1,24(sp)
    80005002:	6942                	ld	s2,16(sp)
    80005004:	6145                	addi	sp,sp,48
    80005006:	8082                	ret
    return -1;
    80005008:	557d                	li	a0,-1
    8000500a:	bfcd                	j	80004ffc <argfd+0x44>
    8000500c:	557d                	li	a0,-1
    8000500e:	b7fd                	j	80004ffc <argfd+0x44>

0000000080005010 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005010:	1101                	addi	sp,sp,-32
    80005012:	ec06                	sd	ra,24(sp)
    80005014:	e822                	sd	s0,16(sp)
    80005016:	e426                	sd	s1,8(sp)
    80005018:	1000                	addi	s0,sp,32
    8000501a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000501c:	ae7fc0ef          	jal	ra,80001b02 <myproc>
    80005020:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005022:	0d050793          	addi	a5,a0,208
    80005026:	4501                	li	a0,0
    80005028:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000502a:	6398                	ld	a4,0(a5)
    8000502c:	cb19                	beqz	a4,80005042 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000502e:	2505                	addiw	a0,a0,1
    80005030:	07a1                	addi	a5,a5,8
    80005032:	fed51ce3          	bne	a0,a3,8000502a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005036:	557d                	li	a0,-1
}
    80005038:	60e2                	ld	ra,24(sp)
    8000503a:	6442                	ld	s0,16(sp)
    8000503c:	64a2                	ld	s1,8(sp)
    8000503e:	6105                	addi	sp,sp,32
    80005040:	8082                	ret
      p->ofile[fd] = f;
    80005042:	01a50793          	addi	a5,a0,26
    80005046:	078e                	slli	a5,a5,0x3
    80005048:	963e                	add	a2,a2,a5
    8000504a:	e204                	sd	s1,0(a2)
      return fd;
    8000504c:	b7f5                	j	80005038 <fdalloc+0x28>

000000008000504e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000504e:	715d                	addi	sp,sp,-80
    80005050:	e486                	sd	ra,72(sp)
    80005052:	e0a2                	sd	s0,64(sp)
    80005054:	fc26                	sd	s1,56(sp)
    80005056:	f84a                	sd	s2,48(sp)
    80005058:	f44e                	sd	s3,40(sp)
    8000505a:	f052                	sd	s4,32(sp)
    8000505c:	ec56                	sd	s5,24(sp)
    8000505e:	e85a                	sd	s6,16(sp)
    80005060:	0880                	addi	s0,sp,80
    80005062:	8b2e                	mv	s6,a1
    80005064:	89b2                	mv	s3,a2
    80005066:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005068:	fb040593          	addi	a1,s0,-80
    8000506c:	820ff0ef          	jal	ra,8000408c <nameiparent>
    80005070:	84aa                	mv	s1,a0
    80005072:	10050b63          	beqz	a0,80005188 <create+0x13a>
    return 0;

  ilock(dp);
    80005076:	809fe0ef          	jal	ra,8000387e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000507a:	4601                	li	a2,0
    8000507c:	fb040593          	addi	a1,s0,-80
    80005080:	8526                	mv	a0,s1
    80005082:	d85fe0ef          	jal	ra,80003e06 <dirlookup>
    80005086:	8aaa                	mv	s5,a0
    80005088:	c521                	beqz	a0,800050d0 <create+0x82>
    iunlockput(dp);
    8000508a:	8526                	mv	a0,s1
    8000508c:	9f9fe0ef          	jal	ra,80003a84 <iunlockput>
    ilock(ip);
    80005090:	8556                	mv	a0,s5
    80005092:	fecfe0ef          	jal	ra,8000387e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005096:	000b059b          	sext.w	a1,s6
    8000509a:	4789                	li	a5,2
    8000509c:	02f59563          	bne	a1,a5,800050c6 <create+0x78>
    800050a0:	044ad783          	lhu	a5,68(s5)
    800050a4:	37f9                	addiw	a5,a5,-2
    800050a6:	17c2                	slli	a5,a5,0x30
    800050a8:	93c1                	srli	a5,a5,0x30
    800050aa:	4705                	li	a4,1
    800050ac:	00f76d63          	bltu	a4,a5,800050c6 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050b0:	8556                	mv	a0,s5
    800050b2:	60a6                	ld	ra,72(sp)
    800050b4:	6406                	ld	s0,64(sp)
    800050b6:	74e2                	ld	s1,56(sp)
    800050b8:	7942                	ld	s2,48(sp)
    800050ba:	79a2                	ld	s3,40(sp)
    800050bc:	7a02                	ld	s4,32(sp)
    800050be:	6ae2                	ld	s5,24(sp)
    800050c0:	6b42                	ld	s6,16(sp)
    800050c2:	6161                	addi	sp,sp,80
    800050c4:	8082                	ret
    iunlockput(ip);
    800050c6:	8556                	mv	a0,s5
    800050c8:	9bdfe0ef          	jal	ra,80003a84 <iunlockput>
    return 0;
    800050cc:	4a81                	li	s5,0
    800050ce:	b7cd                	j	800050b0 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050d0:	85da                	mv	a1,s6
    800050d2:	4088                	lw	a0,0(s1)
    800050d4:	e40fe0ef          	jal	ra,80003714 <ialloc>
    800050d8:	8a2a                	mv	s4,a0
    800050da:	cd1d                	beqz	a0,80005118 <create+0xca>
  ilock(ip);
    800050dc:	fa2fe0ef          	jal	ra,8000387e <ilock>
  ip->major = major;
    800050e0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800050e4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050e8:	4905                	li	s2,1
    800050ea:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050ee:	8552                	mv	a0,s4
    800050f0:	edafe0ef          	jal	ra,800037ca <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050f4:	000b059b          	sext.w	a1,s6
    800050f8:	03258563          	beq	a1,s2,80005122 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    800050fc:	004a2603          	lw	a2,4(s4)
    80005100:	fb040593          	addi	a1,s0,-80
    80005104:	8526                	mv	a0,s1
    80005106:	ed3fe0ef          	jal	ra,80003fd8 <dirlink>
    8000510a:	06054363          	bltz	a0,80005170 <create+0x122>
  iunlockput(dp);
    8000510e:	8526                	mv	a0,s1
    80005110:	975fe0ef          	jal	ra,80003a84 <iunlockput>
  return ip;
    80005114:	8ad2                	mv	s5,s4
    80005116:	bf69                	j	800050b0 <create+0x62>
    iunlockput(dp);
    80005118:	8526                	mv	a0,s1
    8000511a:	96bfe0ef          	jal	ra,80003a84 <iunlockput>
    return 0;
    8000511e:	8ad2                	mv	s5,s4
    80005120:	bf41                	j	800050b0 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005122:	004a2603          	lw	a2,4(s4)
    80005126:	00002597          	auipc	a1,0x2
    8000512a:	5c258593          	addi	a1,a1,1474 # 800076e8 <syscalls+0x2f0>
    8000512e:	8552                	mv	a0,s4
    80005130:	ea9fe0ef          	jal	ra,80003fd8 <dirlink>
    80005134:	02054e63          	bltz	a0,80005170 <create+0x122>
    80005138:	40d0                	lw	a2,4(s1)
    8000513a:	00002597          	auipc	a1,0x2
    8000513e:	5b658593          	addi	a1,a1,1462 # 800076f0 <syscalls+0x2f8>
    80005142:	8552                	mv	a0,s4
    80005144:	e95fe0ef          	jal	ra,80003fd8 <dirlink>
    80005148:	02054463          	bltz	a0,80005170 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    8000514c:	004a2603          	lw	a2,4(s4)
    80005150:	fb040593          	addi	a1,s0,-80
    80005154:	8526                	mv	a0,s1
    80005156:	e83fe0ef          	jal	ra,80003fd8 <dirlink>
    8000515a:	00054b63          	bltz	a0,80005170 <create+0x122>
    dp->nlink++;  // for ".."
    8000515e:	04a4d783          	lhu	a5,74(s1)
    80005162:	2785                	addiw	a5,a5,1
    80005164:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005168:	8526                	mv	a0,s1
    8000516a:	e60fe0ef          	jal	ra,800037ca <iupdate>
    8000516e:	b745                	j	8000510e <create+0xc0>
  ip->nlink = 0;
    80005170:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005174:	8552                	mv	a0,s4
    80005176:	e54fe0ef          	jal	ra,800037ca <iupdate>
  iunlockput(ip);
    8000517a:	8552                	mv	a0,s4
    8000517c:	909fe0ef          	jal	ra,80003a84 <iunlockput>
  iunlockput(dp);
    80005180:	8526                	mv	a0,s1
    80005182:	903fe0ef          	jal	ra,80003a84 <iunlockput>
  return 0;
    80005186:	b72d                	j	800050b0 <create+0x62>
    return 0;
    80005188:	8aaa                	mv	s5,a0
    8000518a:	b71d                	j	800050b0 <create+0x62>

000000008000518c <sys_dup>:
{
    8000518c:	7179                	addi	sp,sp,-48
    8000518e:	f406                	sd	ra,40(sp)
    80005190:	f022                	sd	s0,32(sp)
    80005192:	ec26                	sd	s1,24(sp)
    80005194:	e84a                	sd	s2,16(sp)
    80005196:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005198:	fd840613          	addi	a2,s0,-40
    8000519c:	4581                	li	a1,0
    8000519e:	4501                	li	a0,0
    800051a0:	e19ff0ef          	jal	ra,80004fb8 <argfd>
    return -1;
    800051a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051a6:	00054f63          	bltz	a0,800051c4 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    800051aa:	fd843903          	ld	s2,-40(s0)
    800051ae:	854a                	mv	a0,s2
    800051b0:	e61ff0ef          	jal	ra,80005010 <fdalloc>
    800051b4:	84aa                	mv	s1,a0
    return -1;
    800051b6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051b8:	00054663          	bltz	a0,800051c4 <sys_dup+0x38>
  filedup(f);
    800051bc:	854a                	mv	a0,s2
    800051be:	c6cff0ef          	jal	ra,8000462a <filedup>
  return fd;
    800051c2:	87a6                	mv	a5,s1
}
    800051c4:	853e                	mv	a0,a5
    800051c6:	70a2                	ld	ra,40(sp)
    800051c8:	7402                	ld	s0,32(sp)
    800051ca:	64e2                	ld	s1,24(sp)
    800051cc:	6942                	ld	s2,16(sp)
    800051ce:	6145                	addi	sp,sp,48
    800051d0:	8082                	ret

00000000800051d2 <sys_read>:
{
    800051d2:	7179                	addi	sp,sp,-48
    800051d4:	f406                	sd	ra,40(sp)
    800051d6:	f022                	sd	s0,32(sp)
    800051d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051da:	fd840593          	addi	a1,s0,-40
    800051de:	4505                	li	a0,1
    800051e0:	8e5fd0ef          	jal	ra,80002ac4 <argaddr>
  argint(2, &n);
    800051e4:	fe440593          	addi	a1,s0,-28
    800051e8:	4509                	li	a0,2
    800051ea:	8bffd0ef          	jal	ra,80002aa8 <argint>
  if(argfd(0, 0, &f) < 0)
    800051ee:	fe840613          	addi	a2,s0,-24
    800051f2:	4581                	li	a1,0
    800051f4:	4501                	li	a0,0
    800051f6:	dc3ff0ef          	jal	ra,80004fb8 <argfd>
    800051fa:	87aa                	mv	a5,a0
    return -1;
    800051fc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051fe:	0007ca63          	bltz	a5,80005212 <sys_read+0x40>
  return fileread(f, p, n);
    80005202:	fe442603          	lw	a2,-28(s0)
    80005206:	fd843583          	ld	a1,-40(s0)
    8000520a:	fe843503          	ld	a0,-24(s0)
    8000520e:	d68ff0ef          	jal	ra,80004776 <fileread>
}
    80005212:	70a2                	ld	ra,40(sp)
    80005214:	7402                	ld	s0,32(sp)
    80005216:	6145                	addi	sp,sp,48
    80005218:	8082                	ret

000000008000521a <sys_write>:
{
    8000521a:	7179                	addi	sp,sp,-48
    8000521c:	f406                	sd	ra,40(sp)
    8000521e:	f022                	sd	s0,32(sp)
    80005220:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005222:	fd840593          	addi	a1,s0,-40
    80005226:	4505                	li	a0,1
    80005228:	89dfd0ef          	jal	ra,80002ac4 <argaddr>
  argint(2, &n);
    8000522c:	fe440593          	addi	a1,s0,-28
    80005230:	4509                	li	a0,2
    80005232:	877fd0ef          	jal	ra,80002aa8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005236:	fe840613          	addi	a2,s0,-24
    8000523a:	4581                	li	a1,0
    8000523c:	4501                	li	a0,0
    8000523e:	d7bff0ef          	jal	ra,80004fb8 <argfd>
    80005242:	87aa                	mv	a5,a0
    return -1;
    80005244:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005246:	0007ca63          	bltz	a5,8000525a <sys_write+0x40>
  return filewrite(f, p, n);
    8000524a:	fe442603          	lw	a2,-28(s0)
    8000524e:	fd843583          	ld	a1,-40(s0)
    80005252:	fe843503          	ld	a0,-24(s0)
    80005256:	dceff0ef          	jal	ra,80004824 <filewrite>
}
    8000525a:	70a2                	ld	ra,40(sp)
    8000525c:	7402                	ld	s0,32(sp)
    8000525e:	6145                	addi	sp,sp,48
    80005260:	8082                	ret

0000000080005262 <sys_close>:
{
    80005262:	1101                	addi	sp,sp,-32
    80005264:	ec06                	sd	ra,24(sp)
    80005266:	e822                	sd	s0,16(sp)
    80005268:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000526a:	fe040613          	addi	a2,s0,-32
    8000526e:	fec40593          	addi	a1,s0,-20
    80005272:	4501                	li	a0,0
    80005274:	d45ff0ef          	jal	ra,80004fb8 <argfd>
    return -1;
    80005278:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000527a:	02054063          	bltz	a0,8000529a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000527e:	885fc0ef          	jal	ra,80001b02 <myproc>
    80005282:	fec42783          	lw	a5,-20(s0)
    80005286:	07e9                	addi	a5,a5,26
    80005288:	078e                	slli	a5,a5,0x3
    8000528a:	953e                	add	a0,a0,a5
    8000528c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005290:	fe043503          	ld	a0,-32(s0)
    80005294:	bdcff0ef          	jal	ra,80004670 <fileclose>
  return 0;
    80005298:	4781                	li	a5,0
}
    8000529a:	853e                	mv	a0,a5
    8000529c:	60e2                	ld	ra,24(sp)
    8000529e:	6442                	ld	s0,16(sp)
    800052a0:	6105                	addi	sp,sp,32
    800052a2:	8082                	ret

00000000800052a4 <sys_fstat>:
{
    800052a4:	1101                	addi	sp,sp,-32
    800052a6:	ec06                	sd	ra,24(sp)
    800052a8:	e822                	sd	s0,16(sp)
    800052aa:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052ac:	fe040593          	addi	a1,s0,-32
    800052b0:	4505                	li	a0,1
    800052b2:	813fd0ef          	jal	ra,80002ac4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052b6:	fe840613          	addi	a2,s0,-24
    800052ba:	4581                	li	a1,0
    800052bc:	4501                	li	a0,0
    800052be:	cfbff0ef          	jal	ra,80004fb8 <argfd>
    800052c2:	87aa                	mv	a5,a0
    return -1;
    800052c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c6:	0007c863          	bltz	a5,800052d6 <sys_fstat+0x32>
  return filestat(f, st);
    800052ca:	fe043583          	ld	a1,-32(s0)
    800052ce:	fe843503          	ld	a0,-24(s0)
    800052d2:	c46ff0ef          	jal	ra,80004718 <filestat>
}
    800052d6:	60e2                	ld	ra,24(sp)
    800052d8:	6442                	ld	s0,16(sp)
    800052da:	6105                	addi	sp,sp,32
    800052dc:	8082                	ret

00000000800052de <sys_link>:
{
    800052de:	7169                	addi	sp,sp,-304
    800052e0:	f606                	sd	ra,296(sp)
    800052e2:	f222                	sd	s0,288(sp)
    800052e4:	ee26                	sd	s1,280(sp)
    800052e6:	ea4a                	sd	s2,272(sp)
    800052e8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052ea:	08000613          	li	a2,128
    800052ee:	ed040593          	addi	a1,s0,-304
    800052f2:	4501                	li	a0,0
    800052f4:	fecfd0ef          	jal	ra,80002ae0 <argstr>
    return -1;
    800052f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052fa:	0c054663          	bltz	a0,800053c6 <sys_link+0xe8>
    800052fe:	08000613          	li	a2,128
    80005302:	f5040593          	addi	a1,s0,-176
    80005306:	4505                	li	a0,1
    80005308:	fd8fd0ef          	jal	ra,80002ae0 <argstr>
    return -1;
    8000530c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000530e:	0a054c63          	bltz	a0,800053c6 <sys_link+0xe8>
  begin_op();
    80005312:	f55fe0ef          	jal	ra,80004266 <begin_op>
  if((ip = namei(old)) == 0){
    80005316:	ed040513          	addi	a0,s0,-304
    8000531a:	d59fe0ef          	jal	ra,80004072 <namei>
    8000531e:	84aa                	mv	s1,a0
    80005320:	c525                	beqz	a0,80005388 <sys_link+0xaa>
  ilock(ip);
    80005322:	d5cfe0ef          	jal	ra,8000387e <ilock>
  if(ip->type == T_DIR){
    80005326:	04449703          	lh	a4,68(s1)
    8000532a:	4785                	li	a5,1
    8000532c:	06f70263          	beq	a4,a5,80005390 <sys_link+0xb2>
  ip->nlink++;
    80005330:	04a4d783          	lhu	a5,74(s1)
    80005334:	2785                	addiw	a5,a5,1
    80005336:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000533a:	8526                	mv	a0,s1
    8000533c:	c8efe0ef          	jal	ra,800037ca <iupdate>
  iunlock(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	de6fe0ef          	jal	ra,80003928 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005346:	fd040593          	addi	a1,s0,-48
    8000534a:	f5040513          	addi	a0,s0,-176
    8000534e:	d3ffe0ef          	jal	ra,8000408c <nameiparent>
    80005352:	892a                	mv	s2,a0
    80005354:	c921                	beqz	a0,800053a4 <sys_link+0xc6>
  ilock(dp);
    80005356:	d28fe0ef          	jal	ra,8000387e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000535a:	00092703          	lw	a4,0(s2)
    8000535e:	409c                	lw	a5,0(s1)
    80005360:	02f71f63          	bne	a4,a5,8000539e <sys_link+0xc0>
    80005364:	40d0                	lw	a2,4(s1)
    80005366:	fd040593          	addi	a1,s0,-48
    8000536a:	854a                	mv	a0,s2
    8000536c:	c6dfe0ef          	jal	ra,80003fd8 <dirlink>
    80005370:	02054763          	bltz	a0,8000539e <sys_link+0xc0>
  iunlockput(dp);
    80005374:	854a                	mv	a0,s2
    80005376:	f0efe0ef          	jal	ra,80003a84 <iunlockput>
  iput(ip);
    8000537a:	8526                	mv	a0,s1
    8000537c:	e80fe0ef          	jal	ra,800039fc <iput>
  end_op();
    80005380:	f55fe0ef          	jal	ra,800042d4 <end_op>
  return 0;
    80005384:	4781                	li	a5,0
    80005386:	a081                	j	800053c6 <sys_link+0xe8>
    end_op();
    80005388:	f4dfe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    8000538c:	57fd                	li	a5,-1
    8000538e:	a825                	j	800053c6 <sys_link+0xe8>
    iunlockput(ip);
    80005390:	8526                	mv	a0,s1
    80005392:	ef2fe0ef          	jal	ra,80003a84 <iunlockput>
    end_op();
    80005396:	f3ffe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    8000539a:	57fd                	li	a5,-1
    8000539c:	a02d                	j	800053c6 <sys_link+0xe8>
    iunlockput(dp);
    8000539e:	854a                	mv	a0,s2
    800053a0:	ee4fe0ef          	jal	ra,80003a84 <iunlockput>
  ilock(ip);
    800053a4:	8526                	mv	a0,s1
    800053a6:	cd8fe0ef          	jal	ra,8000387e <ilock>
  ip->nlink--;
    800053aa:	04a4d783          	lhu	a5,74(s1)
    800053ae:	37fd                	addiw	a5,a5,-1
    800053b0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	c14fe0ef          	jal	ra,800037ca <iupdate>
  iunlockput(ip);
    800053ba:	8526                	mv	a0,s1
    800053bc:	ec8fe0ef          	jal	ra,80003a84 <iunlockput>
  end_op();
    800053c0:	f15fe0ef          	jal	ra,800042d4 <end_op>
  return -1;
    800053c4:	57fd                	li	a5,-1
}
    800053c6:	853e                	mv	a0,a5
    800053c8:	70b2                	ld	ra,296(sp)
    800053ca:	7412                	ld	s0,288(sp)
    800053cc:	64f2                	ld	s1,280(sp)
    800053ce:	6952                	ld	s2,272(sp)
    800053d0:	6155                	addi	sp,sp,304
    800053d2:	8082                	ret

00000000800053d4 <sys_unlink>:
{
    800053d4:	7151                	addi	sp,sp,-240
    800053d6:	f586                	sd	ra,232(sp)
    800053d8:	f1a2                	sd	s0,224(sp)
    800053da:	eda6                	sd	s1,216(sp)
    800053dc:	e9ca                	sd	s2,208(sp)
    800053de:	e5ce                	sd	s3,200(sp)
    800053e0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053e2:	08000613          	li	a2,128
    800053e6:	f3040593          	addi	a1,s0,-208
    800053ea:	4501                	li	a0,0
    800053ec:	ef4fd0ef          	jal	ra,80002ae0 <argstr>
    800053f0:	12054b63          	bltz	a0,80005526 <sys_unlink+0x152>
  begin_op();
    800053f4:	e73fe0ef          	jal	ra,80004266 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053f8:	fb040593          	addi	a1,s0,-80
    800053fc:	f3040513          	addi	a0,s0,-208
    80005400:	c8dfe0ef          	jal	ra,8000408c <nameiparent>
    80005404:	84aa                	mv	s1,a0
    80005406:	c54d                	beqz	a0,800054b0 <sys_unlink+0xdc>
  ilock(dp);
    80005408:	c76fe0ef          	jal	ra,8000387e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000540c:	00002597          	auipc	a1,0x2
    80005410:	2dc58593          	addi	a1,a1,732 # 800076e8 <syscalls+0x2f0>
    80005414:	fb040513          	addi	a0,s0,-80
    80005418:	9d9fe0ef          	jal	ra,80003df0 <namecmp>
    8000541c:	10050a63          	beqz	a0,80005530 <sys_unlink+0x15c>
    80005420:	00002597          	auipc	a1,0x2
    80005424:	2d058593          	addi	a1,a1,720 # 800076f0 <syscalls+0x2f8>
    80005428:	fb040513          	addi	a0,s0,-80
    8000542c:	9c5fe0ef          	jal	ra,80003df0 <namecmp>
    80005430:	10050063          	beqz	a0,80005530 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005434:	f2c40613          	addi	a2,s0,-212
    80005438:	fb040593          	addi	a1,s0,-80
    8000543c:	8526                	mv	a0,s1
    8000543e:	9c9fe0ef          	jal	ra,80003e06 <dirlookup>
    80005442:	892a                	mv	s2,a0
    80005444:	0e050663          	beqz	a0,80005530 <sys_unlink+0x15c>
  ilock(ip);
    80005448:	c36fe0ef          	jal	ra,8000387e <ilock>
  if(ip->nlink < 1)
    8000544c:	04a91783          	lh	a5,74(s2)
    80005450:	06f05463          	blez	a5,800054b8 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005454:	04491703          	lh	a4,68(s2)
    80005458:	4785                	li	a5,1
    8000545a:	06f70563          	beq	a4,a5,800054c4 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    8000545e:	4641                	li	a2,16
    80005460:	4581                	li	a1,0
    80005462:	fc040513          	addi	a0,s0,-64
    80005466:	90ffb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000546a:	4741                	li	a4,16
    8000546c:	f2c42683          	lw	a3,-212(s0)
    80005470:	fc040613          	addi	a2,s0,-64
    80005474:	4581                	li	a1,0
    80005476:	8526                	mv	a0,s1
    80005478:	877fe0ef          	jal	ra,80003cee <writei>
    8000547c:	47c1                	li	a5,16
    8000547e:	08f51563          	bne	a0,a5,80005508 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005482:	04491703          	lh	a4,68(s2)
    80005486:	4785                	li	a5,1
    80005488:	08f70663          	beq	a4,a5,80005514 <sys_unlink+0x140>
  iunlockput(dp);
    8000548c:	8526                	mv	a0,s1
    8000548e:	df6fe0ef          	jal	ra,80003a84 <iunlockput>
  ip->nlink--;
    80005492:	04a95783          	lhu	a5,74(s2)
    80005496:	37fd                	addiw	a5,a5,-1
    80005498:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000549c:	854a                	mv	a0,s2
    8000549e:	b2cfe0ef          	jal	ra,800037ca <iupdate>
  iunlockput(ip);
    800054a2:	854a                	mv	a0,s2
    800054a4:	de0fe0ef          	jal	ra,80003a84 <iunlockput>
  end_op();
    800054a8:	e2dfe0ef          	jal	ra,800042d4 <end_op>
  return 0;
    800054ac:	4501                	li	a0,0
    800054ae:	a079                	j	8000553c <sys_unlink+0x168>
    end_op();
    800054b0:	e25fe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    800054b4:	557d                	li	a0,-1
    800054b6:	a059                	j	8000553c <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800054b8:	00002517          	auipc	a0,0x2
    800054bc:	24050513          	addi	a0,a0,576 # 800076f8 <syscalls+0x300>
    800054c0:	ac8fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054c4:	04c92703          	lw	a4,76(s2)
    800054c8:	02000793          	li	a5,32
    800054cc:	f8e7f9e3          	bgeu	a5,a4,8000545e <sys_unlink+0x8a>
    800054d0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054d4:	4741                	li	a4,16
    800054d6:	86ce                	mv	a3,s3
    800054d8:	f1840613          	addi	a2,s0,-232
    800054dc:	4581                	li	a1,0
    800054de:	854a                	mv	a0,s2
    800054e0:	f2afe0ef          	jal	ra,80003c0a <readi>
    800054e4:	47c1                	li	a5,16
    800054e6:	00f51b63          	bne	a0,a5,800054fc <sys_unlink+0x128>
    if(de.inum != 0)
    800054ea:	f1845783          	lhu	a5,-232(s0)
    800054ee:	ef95                	bnez	a5,8000552a <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054f0:	29c1                	addiw	s3,s3,16
    800054f2:	04c92783          	lw	a5,76(s2)
    800054f6:	fcf9efe3          	bltu	s3,a5,800054d4 <sys_unlink+0x100>
    800054fa:	b795                	j	8000545e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800054fc:	00002517          	auipc	a0,0x2
    80005500:	21450513          	addi	a0,a0,532 # 80007710 <syscalls+0x318>
    80005504:	a84fb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80005508:	00002517          	auipc	a0,0x2
    8000550c:	22050513          	addi	a0,a0,544 # 80007728 <syscalls+0x330>
    80005510:	a78fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005514:	04a4d783          	lhu	a5,74(s1)
    80005518:	37fd                	addiw	a5,a5,-1
    8000551a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000551e:	8526                	mv	a0,s1
    80005520:	aaafe0ef          	jal	ra,800037ca <iupdate>
    80005524:	b7a5                	j	8000548c <sys_unlink+0xb8>
    return -1;
    80005526:	557d                	li	a0,-1
    80005528:	a811                	j	8000553c <sys_unlink+0x168>
    iunlockput(ip);
    8000552a:	854a                	mv	a0,s2
    8000552c:	d58fe0ef          	jal	ra,80003a84 <iunlockput>
  iunlockput(dp);
    80005530:	8526                	mv	a0,s1
    80005532:	d52fe0ef          	jal	ra,80003a84 <iunlockput>
  end_op();
    80005536:	d9ffe0ef          	jal	ra,800042d4 <end_op>
  return -1;
    8000553a:	557d                	li	a0,-1
}
    8000553c:	70ae                	ld	ra,232(sp)
    8000553e:	740e                	ld	s0,224(sp)
    80005540:	64ee                	ld	s1,216(sp)
    80005542:	694e                	ld	s2,208(sp)
    80005544:	69ae                	ld	s3,200(sp)
    80005546:	616d                	addi	sp,sp,240
    80005548:	8082                	ret

000000008000554a <sys_open>:

uint64
sys_open(void)
{
    8000554a:	7131                	addi	sp,sp,-192
    8000554c:	fd06                	sd	ra,184(sp)
    8000554e:	f922                	sd	s0,176(sp)
    80005550:	f526                	sd	s1,168(sp)
    80005552:	f14a                	sd	s2,160(sp)
    80005554:	ed4e                	sd	s3,152(sp)
    80005556:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005558:	f4c40593          	addi	a1,s0,-180
    8000555c:	4505                	li	a0,1
    8000555e:	d4afd0ef          	jal	ra,80002aa8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005562:	08000613          	li	a2,128
    80005566:	f5040593          	addi	a1,s0,-176
    8000556a:	4501                	li	a0,0
    8000556c:	d74fd0ef          	jal	ra,80002ae0 <argstr>
    80005570:	87aa                	mv	a5,a0
    return -1;
    80005572:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005574:	0807cd63          	bltz	a5,8000560e <sys_open+0xc4>

  begin_op();
    80005578:	ceffe0ef          	jal	ra,80004266 <begin_op>

  if(omode & O_CREATE){
    8000557c:	f4c42783          	lw	a5,-180(s0)
    80005580:	2007f793          	andi	a5,a5,512
    80005584:	c3c5                	beqz	a5,80005624 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005586:	4681                	li	a3,0
    80005588:	4601                	li	a2,0
    8000558a:	4589                	li	a1,2
    8000558c:	f5040513          	addi	a0,s0,-176
    80005590:	abfff0ef          	jal	ra,8000504e <create>
    80005594:	84aa                	mv	s1,a0
    if(ip == 0){
    80005596:	c159                	beqz	a0,8000561c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005598:	04449703          	lh	a4,68(s1)
    8000559c:	478d                	li	a5,3
    8000559e:	00f71763          	bne	a4,a5,800055ac <sys_open+0x62>
    800055a2:	0464d703          	lhu	a4,70(s1)
    800055a6:	47a5                	li	a5,9
    800055a8:	0ae7e963          	bltu	a5,a4,8000565a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055ac:	820ff0ef          	jal	ra,800045cc <filealloc>
    800055b0:	89aa                	mv	s3,a0
    800055b2:	0c050963          	beqz	a0,80005684 <sys_open+0x13a>
    800055b6:	a5bff0ef          	jal	ra,80005010 <fdalloc>
    800055ba:	892a                	mv	s2,a0
    800055bc:	0c054163          	bltz	a0,8000567e <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055c0:	04449703          	lh	a4,68(s1)
    800055c4:	478d                	li	a5,3
    800055c6:	0af70163          	beq	a4,a5,80005668 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800055ca:	4789                	li	a5,2
    800055cc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800055d0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800055d4:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800055d8:	f4c42783          	lw	a5,-180(s0)
    800055dc:	0017c713          	xori	a4,a5,1
    800055e0:	8b05                	andi	a4,a4,1
    800055e2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055e6:	0037f713          	andi	a4,a5,3
    800055ea:	00e03733          	snez	a4,a4
    800055ee:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800055f2:	4007f793          	andi	a5,a5,1024
    800055f6:	c791                	beqz	a5,80005602 <sys_open+0xb8>
    800055f8:	04449703          	lh	a4,68(s1)
    800055fc:	4789                	li	a5,2
    800055fe:	06f70c63          	beq	a4,a5,80005676 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005602:	8526                	mv	a0,s1
    80005604:	b24fe0ef          	jal	ra,80003928 <iunlock>
  end_op();
    80005608:	ccdfe0ef          	jal	ra,800042d4 <end_op>

  return fd;
    8000560c:	854a                	mv	a0,s2
}
    8000560e:	70ea                	ld	ra,184(sp)
    80005610:	744a                	ld	s0,176(sp)
    80005612:	74aa                	ld	s1,168(sp)
    80005614:	790a                	ld	s2,160(sp)
    80005616:	69ea                	ld	s3,152(sp)
    80005618:	6129                	addi	sp,sp,192
    8000561a:	8082                	ret
      end_op();
    8000561c:	cb9fe0ef          	jal	ra,800042d4 <end_op>
      return -1;
    80005620:	557d                	li	a0,-1
    80005622:	b7f5                	j	8000560e <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005624:	f5040513          	addi	a0,s0,-176
    80005628:	a4bfe0ef          	jal	ra,80004072 <namei>
    8000562c:	84aa                	mv	s1,a0
    8000562e:	c115                	beqz	a0,80005652 <sys_open+0x108>
    ilock(ip);
    80005630:	a4efe0ef          	jal	ra,8000387e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005634:	04449703          	lh	a4,68(s1)
    80005638:	4785                	li	a5,1
    8000563a:	f4f71fe3          	bne	a4,a5,80005598 <sys_open+0x4e>
    8000563e:	f4c42783          	lw	a5,-180(s0)
    80005642:	d7ad                	beqz	a5,800055ac <sys_open+0x62>
      iunlockput(ip);
    80005644:	8526                	mv	a0,s1
    80005646:	c3efe0ef          	jal	ra,80003a84 <iunlockput>
      end_op();
    8000564a:	c8bfe0ef          	jal	ra,800042d4 <end_op>
      return -1;
    8000564e:	557d                	li	a0,-1
    80005650:	bf7d                	j	8000560e <sys_open+0xc4>
      end_op();
    80005652:	c83fe0ef          	jal	ra,800042d4 <end_op>
      return -1;
    80005656:	557d                	li	a0,-1
    80005658:	bf5d                	j	8000560e <sys_open+0xc4>
    iunlockput(ip);
    8000565a:	8526                	mv	a0,s1
    8000565c:	c28fe0ef          	jal	ra,80003a84 <iunlockput>
    end_op();
    80005660:	c75fe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    80005664:	557d                	li	a0,-1
    80005666:	b765                	j	8000560e <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005668:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000566c:	04649783          	lh	a5,70(s1)
    80005670:	02f99223          	sh	a5,36(s3)
    80005674:	b785                	j	800055d4 <sys_open+0x8a>
    itrunc(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	af0fe0ef          	jal	ra,80003968 <itrunc>
    8000567c:	b759                	j	80005602 <sys_open+0xb8>
      fileclose(f);
    8000567e:	854e                	mv	a0,s3
    80005680:	ff1fe0ef          	jal	ra,80004670 <fileclose>
    iunlockput(ip);
    80005684:	8526                	mv	a0,s1
    80005686:	bfefe0ef          	jal	ra,80003a84 <iunlockput>
    end_op();
    8000568a:	c4bfe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    8000568e:	557d                	li	a0,-1
    80005690:	bfbd                	j	8000560e <sys_open+0xc4>

0000000080005692 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005692:	7175                	addi	sp,sp,-144
    80005694:	e506                	sd	ra,136(sp)
    80005696:	e122                	sd	s0,128(sp)
    80005698:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000569a:	bcdfe0ef          	jal	ra,80004266 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000569e:	08000613          	li	a2,128
    800056a2:	f7040593          	addi	a1,s0,-144
    800056a6:	4501                	li	a0,0
    800056a8:	c38fd0ef          	jal	ra,80002ae0 <argstr>
    800056ac:	02054363          	bltz	a0,800056d2 <sys_mkdir+0x40>
    800056b0:	4681                	li	a3,0
    800056b2:	4601                	li	a2,0
    800056b4:	4585                	li	a1,1
    800056b6:	f7040513          	addi	a0,s0,-144
    800056ba:	995ff0ef          	jal	ra,8000504e <create>
    800056be:	c911                	beqz	a0,800056d2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056c0:	bc4fe0ef          	jal	ra,80003a84 <iunlockput>
  end_op();
    800056c4:	c11fe0ef          	jal	ra,800042d4 <end_op>
  return 0;
    800056c8:	4501                	li	a0,0
}
    800056ca:	60aa                	ld	ra,136(sp)
    800056cc:	640a                	ld	s0,128(sp)
    800056ce:	6149                	addi	sp,sp,144
    800056d0:	8082                	ret
    end_op();
    800056d2:	c03fe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    800056d6:	557d                	li	a0,-1
    800056d8:	bfcd                	j	800056ca <sys_mkdir+0x38>

00000000800056da <sys_mknod>:

uint64
sys_mknod(void)
{
    800056da:	7135                	addi	sp,sp,-160
    800056dc:	ed06                	sd	ra,152(sp)
    800056de:	e922                	sd	s0,144(sp)
    800056e0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800056e2:	b85fe0ef          	jal	ra,80004266 <begin_op>
  argint(1, &major);
    800056e6:	f6c40593          	addi	a1,s0,-148
    800056ea:	4505                	li	a0,1
    800056ec:	bbcfd0ef          	jal	ra,80002aa8 <argint>
  argint(2, &minor);
    800056f0:	f6840593          	addi	a1,s0,-152
    800056f4:	4509                	li	a0,2
    800056f6:	bb2fd0ef          	jal	ra,80002aa8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056fa:	08000613          	li	a2,128
    800056fe:	f7040593          	addi	a1,s0,-144
    80005702:	4501                	li	a0,0
    80005704:	bdcfd0ef          	jal	ra,80002ae0 <argstr>
    80005708:	02054563          	bltz	a0,80005732 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000570c:	f6841683          	lh	a3,-152(s0)
    80005710:	f6c41603          	lh	a2,-148(s0)
    80005714:	458d                	li	a1,3
    80005716:	f7040513          	addi	a0,s0,-144
    8000571a:	935ff0ef          	jal	ra,8000504e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000571e:	c911                	beqz	a0,80005732 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005720:	b64fe0ef          	jal	ra,80003a84 <iunlockput>
  end_op();
    80005724:	bb1fe0ef          	jal	ra,800042d4 <end_op>
  return 0;
    80005728:	4501                	li	a0,0
}
    8000572a:	60ea                	ld	ra,152(sp)
    8000572c:	644a                	ld	s0,144(sp)
    8000572e:	610d                	addi	sp,sp,160
    80005730:	8082                	ret
    end_op();
    80005732:	ba3fe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    80005736:	557d                	li	a0,-1
    80005738:	bfcd                	j	8000572a <sys_mknod+0x50>

000000008000573a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000573a:	7135                	addi	sp,sp,-160
    8000573c:	ed06                	sd	ra,152(sp)
    8000573e:	e922                	sd	s0,144(sp)
    80005740:	e526                	sd	s1,136(sp)
    80005742:	e14a                	sd	s2,128(sp)
    80005744:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005746:	bbcfc0ef          	jal	ra,80001b02 <myproc>
    8000574a:	892a                	mv	s2,a0
  
  begin_op();
    8000574c:	b1bfe0ef          	jal	ra,80004266 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005750:	08000613          	li	a2,128
    80005754:	f6040593          	addi	a1,s0,-160
    80005758:	4501                	li	a0,0
    8000575a:	b86fd0ef          	jal	ra,80002ae0 <argstr>
    8000575e:	04054163          	bltz	a0,800057a0 <sys_chdir+0x66>
    80005762:	f6040513          	addi	a0,s0,-160
    80005766:	90dfe0ef          	jal	ra,80004072 <namei>
    8000576a:	84aa                	mv	s1,a0
    8000576c:	c915                	beqz	a0,800057a0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000576e:	910fe0ef          	jal	ra,8000387e <ilock>
  if(ip->type != T_DIR){
    80005772:	04449703          	lh	a4,68(s1)
    80005776:	4785                	li	a5,1
    80005778:	02f71863          	bne	a4,a5,800057a8 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000577c:	8526                	mv	a0,s1
    8000577e:	9aafe0ef          	jal	ra,80003928 <iunlock>
  iput(p->cwd);
    80005782:	15093503          	ld	a0,336(s2)
    80005786:	a76fe0ef          	jal	ra,800039fc <iput>
  end_op();
    8000578a:	b4bfe0ef          	jal	ra,800042d4 <end_op>
  p->cwd = ip;
    8000578e:	14993823          	sd	s1,336(s2)
  return 0;
    80005792:	4501                	li	a0,0
}
    80005794:	60ea                	ld	ra,152(sp)
    80005796:	644a                	ld	s0,144(sp)
    80005798:	64aa                	ld	s1,136(sp)
    8000579a:	690a                	ld	s2,128(sp)
    8000579c:	610d                	addi	sp,sp,160
    8000579e:	8082                	ret
    end_op();
    800057a0:	b35fe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    800057a4:	557d                	li	a0,-1
    800057a6:	b7fd                	j	80005794 <sys_chdir+0x5a>
    iunlockput(ip);
    800057a8:	8526                	mv	a0,s1
    800057aa:	adafe0ef          	jal	ra,80003a84 <iunlockput>
    end_op();
    800057ae:	b27fe0ef          	jal	ra,800042d4 <end_op>
    return -1;
    800057b2:	557d                	li	a0,-1
    800057b4:	b7c5                	j	80005794 <sys_chdir+0x5a>

00000000800057b6 <sys_exec>:

uint64
sys_exec(void)
{
    800057b6:	7145                	addi	sp,sp,-464
    800057b8:	e786                	sd	ra,456(sp)
    800057ba:	e3a2                	sd	s0,448(sp)
    800057bc:	ff26                	sd	s1,440(sp)
    800057be:	fb4a                	sd	s2,432(sp)
    800057c0:	f74e                	sd	s3,424(sp)
    800057c2:	f352                	sd	s4,416(sp)
    800057c4:	ef56                	sd	s5,408(sp)
    800057c6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800057c8:	e3840593          	addi	a1,s0,-456
    800057cc:	4505                	li	a0,1
    800057ce:	af6fd0ef          	jal	ra,80002ac4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800057d2:	08000613          	li	a2,128
    800057d6:	f4040593          	addi	a1,s0,-192
    800057da:	4501                	li	a0,0
    800057dc:	b04fd0ef          	jal	ra,80002ae0 <argstr>
    800057e0:	87aa                	mv	a5,a0
    return -1;
    800057e2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800057e4:	0a07c563          	bltz	a5,8000588e <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    800057e8:	10000613          	li	a2,256
    800057ec:	4581                	li	a1,0
    800057ee:	e4040513          	addi	a0,s0,-448
    800057f2:	d82fb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800057f6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800057fa:	89a6                	mv	s3,s1
    800057fc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800057fe:	02000a13          	li	s4,32
    80005802:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005806:	00391513          	slli	a0,s2,0x3
    8000580a:	e3040593          	addi	a1,s0,-464
    8000580e:	e3843783          	ld	a5,-456(s0)
    80005812:	953e                	add	a0,a0,a5
    80005814:	a0afd0ef          	jal	ra,80002a1e <fetchaddr>
    80005818:	02054663          	bltz	a0,80005844 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000581c:	e3043783          	ld	a5,-464(s0)
    80005820:	cf8d                	beqz	a5,8000585a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005822:	b88fb0ef          	jal	ra,80000baa <kalloc>
    80005826:	85aa                	mv	a1,a0
    80005828:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000582c:	cd01                	beqz	a0,80005844 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000582e:	6605                	lui	a2,0x1
    80005830:	e3043503          	ld	a0,-464(s0)
    80005834:	a34fd0ef          	jal	ra,80002a68 <fetchstr>
    80005838:	00054663          	bltz	a0,80005844 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    8000583c:	0905                	addi	s2,s2,1
    8000583e:	09a1                	addi	s3,s3,8
    80005840:	fd4911e3          	bne	s2,s4,80005802 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005844:	f4040913          	addi	s2,s0,-192
    80005848:	6088                	ld	a0,0(s1)
    8000584a:	c129                	beqz	a0,8000588c <sys_exec+0xd6>
    kfree(argv[i]);
    8000584c:	a2efb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005850:	04a1                	addi	s1,s1,8
    80005852:	ff249be3          	bne	s1,s2,80005848 <sys_exec+0x92>
  return -1;
    80005856:	557d                	li	a0,-1
    80005858:	a81d                	j	8000588e <sys_exec+0xd8>
      argv[i] = 0;
    8000585a:	0a8e                	slli	s5,s5,0x3
    8000585c:	fc0a8793          	addi	a5,s5,-64
    80005860:	00878ab3          	add	s5,a5,s0
    80005864:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005868:	e4040593          	addi	a1,s0,-448
    8000586c:	f4040513          	addi	a0,s0,-192
    80005870:	bacff0ef          	jal	ra,80004c1c <kexec>
    80005874:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005876:	f4040993          	addi	s3,s0,-192
    8000587a:	6088                	ld	a0,0(s1)
    8000587c:	c511                	beqz	a0,80005888 <sys_exec+0xd2>
    kfree(argv[i]);
    8000587e:	9fcfb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005882:	04a1                	addi	s1,s1,8
    80005884:	ff349be3          	bne	s1,s3,8000587a <sys_exec+0xc4>
  return ret;
    80005888:	854a                	mv	a0,s2
    8000588a:	a011                	j	8000588e <sys_exec+0xd8>
  return -1;
    8000588c:	557d                	li	a0,-1
}
    8000588e:	60be                	ld	ra,456(sp)
    80005890:	641e                	ld	s0,448(sp)
    80005892:	74fa                	ld	s1,440(sp)
    80005894:	795a                	ld	s2,432(sp)
    80005896:	79ba                	ld	s3,424(sp)
    80005898:	7a1a                	ld	s4,416(sp)
    8000589a:	6afa                	ld	s5,408(sp)
    8000589c:	6179                	addi	sp,sp,464
    8000589e:	8082                	ret

00000000800058a0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800058a0:	7139                	addi	sp,sp,-64
    800058a2:	fc06                	sd	ra,56(sp)
    800058a4:	f822                	sd	s0,48(sp)
    800058a6:	f426                	sd	s1,40(sp)
    800058a8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800058aa:	a58fc0ef          	jal	ra,80001b02 <myproc>
    800058ae:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800058b0:	fd840593          	addi	a1,s0,-40
    800058b4:	4501                	li	a0,0
    800058b6:	a0efd0ef          	jal	ra,80002ac4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800058ba:	fc840593          	addi	a1,s0,-56
    800058be:	fd040513          	addi	a0,s0,-48
    800058c2:	87aff0ef          	jal	ra,8000493c <pipealloc>
    return -1;
    800058c6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800058c8:	0a054463          	bltz	a0,80005970 <sys_pipe+0xd0>
  fd0 = -1;
    800058cc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800058d0:	fd043503          	ld	a0,-48(s0)
    800058d4:	f3cff0ef          	jal	ra,80005010 <fdalloc>
    800058d8:	fca42223          	sw	a0,-60(s0)
    800058dc:	08054163          	bltz	a0,8000595e <sys_pipe+0xbe>
    800058e0:	fc843503          	ld	a0,-56(s0)
    800058e4:	f2cff0ef          	jal	ra,80005010 <fdalloc>
    800058e8:	fca42023          	sw	a0,-64(s0)
    800058ec:	06054063          	bltz	a0,8000594c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800058f0:	4691                	li	a3,4
    800058f2:	fc440613          	addi	a2,s0,-60
    800058f6:	fd843583          	ld	a1,-40(s0)
    800058fa:	68a8                	ld	a0,80(s1)
    800058fc:	e63fb0ef          	jal	ra,8000175e <copyout>
    80005900:	00054e63          	bltz	a0,8000591c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005904:	4691                	li	a3,4
    80005906:	fc040613          	addi	a2,s0,-64
    8000590a:	fd843583          	ld	a1,-40(s0)
    8000590e:	0591                	addi	a1,a1,4
    80005910:	68a8                	ld	a0,80(s1)
    80005912:	e4dfb0ef          	jal	ra,8000175e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005916:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005918:	04055c63          	bgez	a0,80005970 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000591c:	fc442783          	lw	a5,-60(s0)
    80005920:	07e9                	addi	a5,a5,26
    80005922:	078e                	slli	a5,a5,0x3
    80005924:	97a6                	add	a5,a5,s1
    80005926:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000592a:	fc042783          	lw	a5,-64(s0)
    8000592e:	07e9                	addi	a5,a5,26
    80005930:	078e                	slli	a5,a5,0x3
    80005932:	94be                	add	s1,s1,a5
    80005934:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005938:	fd043503          	ld	a0,-48(s0)
    8000593c:	d35fe0ef          	jal	ra,80004670 <fileclose>
    fileclose(wf);
    80005940:	fc843503          	ld	a0,-56(s0)
    80005944:	d2dfe0ef          	jal	ra,80004670 <fileclose>
    return -1;
    80005948:	57fd                	li	a5,-1
    8000594a:	a01d                	j	80005970 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000594c:	fc442783          	lw	a5,-60(s0)
    80005950:	0007c763          	bltz	a5,8000595e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005954:	07e9                	addi	a5,a5,26
    80005956:	078e                	slli	a5,a5,0x3
    80005958:	97a6                	add	a5,a5,s1
    8000595a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000595e:	fd043503          	ld	a0,-48(s0)
    80005962:	d0ffe0ef          	jal	ra,80004670 <fileclose>
    fileclose(wf);
    80005966:	fc843503          	ld	a0,-56(s0)
    8000596a:	d07fe0ef          	jal	ra,80004670 <fileclose>
    return -1;
    8000596e:	57fd                	li	a5,-1
}
    80005970:	853e                	mv	a0,a5
    80005972:	70e2                	ld	ra,56(sp)
    80005974:	7442                	ld	s0,48(sp)
    80005976:	74a2                	ld	s1,40(sp)
    80005978:	6121                	addi	sp,sp,64
    8000597a:	8082                	ret
    8000597c:	0000                	unimp
	...

0000000080005980 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005980:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005982:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005984:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005986:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005988:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000598a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000598c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000598e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005990:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005992:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005994:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005996:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005998:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000599a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000599c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000599e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800059a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800059a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800059a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800059a6:	f89fc0ef          	jal	ra,8000292e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800059aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800059ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800059ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800059b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059ce:	10200073          	sret
	...

00000000800059de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059de:	1141                	addi	sp,sp,-16
    800059e0:	e422                	sd	s0,8(sp)
    800059e2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800059e4:	0c0007b7          	lui	a5,0xc000
    800059e8:	4705                	li	a4,1
    800059ea:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800059ec:	c3d8                	sw	a4,4(a5)
}
    800059ee:	6422                	ld	s0,8(sp)
    800059f0:	0141                	addi	sp,sp,16
    800059f2:	8082                	ret

00000000800059f4 <plicinithart>:

void
plicinithart(void)
{
    800059f4:	1141                	addi	sp,sp,-16
    800059f6:	e406                	sd	ra,8(sp)
    800059f8:	e022                	sd	s0,0(sp)
    800059fa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059fc:	8dafc0ef          	jal	ra,80001ad6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005a00:	0085171b          	slliw	a4,a0,0x8
    80005a04:	0c0027b7          	lui	a5,0xc002
    80005a08:	97ba                	add	a5,a5,a4
    80005a0a:	40200713          	li	a4,1026
    80005a0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005a12:	00d5151b          	slliw	a0,a0,0xd
    80005a16:	0c2017b7          	lui	a5,0xc201
    80005a1a:	97aa                	add	a5,a5,a0
    80005a1c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005a20:	60a2                	ld	ra,8(sp)
    80005a22:	6402                	ld	s0,0(sp)
    80005a24:	0141                	addi	sp,sp,16
    80005a26:	8082                	ret

0000000080005a28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a28:	1141                	addi	sp,sp,-16
    80005a2a:	e406                	sd	ra,8(sp)
    80005a2c:	e022                	sd	s0,0(sp)
    80005a2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a30:	8a6fc0ef          	jal	ra,80001ad6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005a34:	00d5151b          	slliw	a0,a0,0xd
    80005a38:	0c2017b7          	lui	a5,0xc201
    80005a3c:	97aa                	add	a5,a5,a0
  return irq;
}
    80005a3e:	43c8                	lw	a0,4(a5)
    80005a40:	60a2                	ld	ra,8(sp)
    80005a42:	6402                	ld	s0,0(sp)
    80005a44:	0141                	addi	sp,sp,16
    80005a46:	8082                	ret

0000000080005a48 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a48:	1101                	addi	sp,sp,-32
    80005a4a:	ec06                	sd	ra,24(sp)
    80005a4c:	e822                	sd	s0,16(sp)
    80005a4e:	e426                	sd	s1,8(sp)
    80005a50:	1000                	addi	s0,sp,32
    80005a52:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a54:	882fc0ef          	jal	ra,80001ad6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005a58:	00d5151b          	slliw	a0,a0,0xd
    80005a5c:	0c2017b7          	lui	a5,0xc201
    80005a60:	97aa                	add	a5,a5,a0
    80005a62:	c3c4                	sw	s1,4(a5)
}
    80005a64:	60e2                	ld	ra,24(sp)
    80005a66:	6442                	ld	s0,16(sp)
    80005a68:	64a2                	ld	s1,8(sp)
    80005a6a:	6105                	addi	sp,sp,32
    80005a6c:	8082                	ret

0000000080005a6e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a6e:	1141                	addi	sp,sp,-16
    80005a70:	e406                	sd	ra,8(sp)
    80005a72:	e022                	sd	s0,0(sp)
    80005a74:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005a76:	479d                	li	a5,7
    80005a78:	04a7ca63          	blt	a5,a0,80005acc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005a7c:	00243797          	auipc	a5,0x243
    80005a80:	00478793          	addi	a5,a5,4 # 80248a80 <disk>
    80005a84:	97aa                	add	a5,a5,a0
    80005a86:	0187c783          	lbu	a5,24(a5)
    80005a8a:	e7b9                	bnez	a5,80005ad8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a8c:	00451693          	slli	a3,a0,0x4
    80005a90:	00243797          	auipc	a5,0x243
    80005a94:	ff078793          	addi	a5,a5,-16 # 80248a80 <disk>
    80005a98:	6398                	ld	a4,0(a5)
    80005a9a:	9736                	add	a4,a4,a3
    80005a9c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005aa0:	6398                	ld	a4,0(a5)
    80005aa2:	9736                	add	a4,a4,a3
    80005aa4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005aa8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005aac:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ab0:	97aa                	add	a5,a5,a0
    80005ab2:	4705                	li	a4,1
    80005ab4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005ab8:	00243517          	auipc	a0,0x243
    80005abc:	fe050513          	addi	a0,a0,-32 # 80248a98 <disk+0x18>
    80005ac0:	efcfc0ef          	jal	ra,800021bc <wakeup>
}
    80005ac4:	60a2                	ld	ra,8(sp)
    80005ac6:	6402                	ld	s0,0(sp)
    80005ac8:	0141                	addi	sp,sp,16
    80005aca:	8082                	ret
    panic("free_desc 1");
    80005acc:	00002517          	auipc	a0,0x2
    80005ad0:	c6c50513          	addi	a0,a0,-916 # 80007738 <syscalls+0x340>
    80005ad4:	cb5fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005ad8:	00002517          	auipc	a0,0x2
    80005adc:	c7050513          	addi	a0,a0,-912 # 80007748 <syscalls+0x350>
    80005ae0:	ca9fa0ef          	jal	ra,80000788 <panic>

0000000080005ae4 <virtio_disk_init>:
{
    80005ae4:	1101                	addi	sp,sp,-32
    80005ae6:	ec06                	sd	ra,24(sp)
    80005ae8:	e822                	sd	s0,16(sp)
    80005aea:	e426                	sd	s1,8(sp)
    80005aec:	e04a                	sd	s2,0(sp)
    80005aee:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005af0:	00002597          	auipc	a1,0x2
    80005af4:	c6858593          	addi	a1,a1,-920 # 80007758 <syscalls+0x360>
    80005af8:	00243517          	auipc	a0,0x243
    80005afc:	0b050513          	addi	a0,a0,176 # 80248ba8 <disk+0x128>
    80005b00:	920fb0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b04:	100017b7          	lui	a5,0x10001
    80005b08:	4398                	lw	a4,0(a5)
    80005b0a:	2701                	sext.w	a4,a4
    80005b0c:	747277b7          	lui	a5,0x74727
    80005b10:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b14:	12f71f63          	bne	a4,a5,80005c52 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b18:	100017b7          	lui	a5,0x10001
    80005b1c:	43dc                	lw	a5,4(a5)
    80005b1e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b20:	4709                	li	a4,2
    80005b22:	12e79863          	bne	a5,a4,80005c52 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b26:	100017b7          	lui	a5,0x10001
    80005b2a:	479c                	lw	a5,8(a5)
    80005b2c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b2e:	12e79263          	bne	a5,a4,80005c52 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005b32:	100017b7          	lui	a5,0x10001
    80005b36:	47d8                	lw	a4,12(a5)
    80005b38:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b3a:	554d47b7          	lui	a5,0x554d4
    80005b3e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b42:	10f71863          	bne	a4,a5,80005c52 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b46:	100017b7          	lui	a5,0x10001
    80005b4a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b4e:	4705                	li	a4,1
    80005b50:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b52:	470d                	li	a4,3
    80005b54:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b56:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b58:	c7ffe6b7          	lui	a3,0xc7ffe
    80005b5c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db5b9f>
    80005b60:	8f75                	and	a4,a4,a3
    80005b62:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b64:	472d                	li	a4,11
    80005b66:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005b68:	5bbc                	lw	a5,112(a5)
    80005b6a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b6e:	8ba1                	andi	a5,a5,8
    80005b70:	0e078763          	beqz	a5,80005c5e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b74:	100017b7          	lui	a5,0x10001
    80005b78:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005b7c:	43fc                	lw	a5,68(a5)
    80005b7e:	2781                	sext.w	a5,a5
    80005b80:	0e079563          	bnez	a5,80005c6a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b84:	100017b7          	lui	a5,0x10001
    80005b88:	5bdc                	lw	a5,52(a5)
    80005b8a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005b8c:	0e078563          	beqz	a5,80005c76 <virtio_disk_init+0x192>
  if(max < NUM)
    80005b90:	471d                	li	a4,7
    80005b92:	0ef77863          	bgeu	a4,a5,80005c82 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80005b96:	814fb0ef          	jal	ra,80000baa <kalloc>
    80005b9a:	00243497          	auipc	s1,0x243
    80005b9e:	ee648493          	addi	s1,s1,-282 # 80248a80 <disk>
    80005ba2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ba4:	806fb0ef          	jal	ra,80000baa <kalloc>
    80005ba8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005baa:	800fb0ef          	jal	ra,80000baa <kalloc>
    80005bae:	87aa                	mv	a5,a0
    80005bb0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005bb2:	6088                	ld	a0,0(s1)
    80005bb4:	cd69                	beqz	a0,80005c8e <virtio_disk_init+0x1aa>
    80005bb6:	00243717          	auipc	a4,0x243
    80005bba:	ed273703          	ld	a4,-302(a4) # 80248a88 <disk+0x8>
    80005bbe:	cb61                	beqz	a4,80005c8e <virtio_disk_init+0x1aa>
    80005bc0:	c7f9                	beqz	a5,80005c8e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005bc2:	6605                	lui	a2,0x1
    80005bc4:	4581                	li	a1,0
    80005bc6:	9aefb0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005bca:	00243497          	auipc	s1,0x243
    80005bce:	eb648493          	addi	s1,s1,-330 # 80248a80 <disk>
    80005bd2:	6605                	lui	a2,0x1
    80005bd4:	4581                	li	a1,0
    80005bd6:	6488                	ld	a0,8(s1)
    80005bd8:	99cfb0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    80005bdc:	6605                	lui	a2,0x1
    80005bde:	4581                	li	a1,0
    80005be0:	6888                	ld	a0,16(s1)
    80005be2:	992fb0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005be6:	100017b7          	lui	a5,0x10001
    80005bea:	4721                	li	a4,8
    80005bec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005bee:	4098                	lw	a4,0(s1)
    80005bf0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005bf4:	40d8                	lw	a4,4(s1)
    80005bf6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005bfa:	6498                	ld	a4,8(s1)
    80005bfc:	0007069b          	sext.w	a3,a4
    80005c00:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c04:	9701                	srai	a4,a4,0x20
    80005c06:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c0a:	6898                	ld	a4,16(s1)
    80005c0c:	0007069b          	sext.w	a3,a4
    80005c10:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c14:	9701                	srai	a4,a4,0x20
    80005c16:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c1a:	4705                	li	a4,1
    80005c1c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005c1e:	00e48c23          	sb	a4,24(s1)
    80005c22:	00e48ca3          	sb	a4,25(s1)
    80005c26:	00e48d23          	sb	a4,26(s1)
    80005c2a:	00e48da3          	sb	a4,27(s1)
    80005c2e:	00e48e23          	sb	a4,28(s1)
    80005c32:	00e48ea3          	sb	a4,29(s1)
    80005c36:	00e48f23          	sb	a4,30(s1)
    80005c3a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c3e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c42:	0727a823          	sw	s2,112(a5)
}
    80005c46:	60e2                	ld	ra,24(sp)
    80005c48:	6442                	ld	s0,16(sp)
    80005c4a:	64a2                	ld	s1,8(sp)
    80005c4c:	6902                	ld	s2,0(sp)
    80005c4e:	6105                	addi	sp,sp,32
    80005c50:	8082                	ret
    panic("could not find virtio disk");
    80005c52:	00002517          	auipc	a0,0x2
    80005c56:	b1650513          	addi	a0,a0,-1258 # 80007768 <syscalls+0x370>
    80005c5a:	b2ffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c5e:	00002517          	auipc	a0,0x2
    80005c62:	b2a50513          	addi	a0,a0,-1238 # 80007788 <syscalls+0x390>
    80005c66:	b23fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    80005c6a:	00002517          	auipc	a0,0x2
    80005c6e:	b3e50513          	addi	a0,a0,-1218 # 800077a8 <syscalls+0x3b0>
    80005c72:	b17fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005c76:	00002517          	auipc	a0,0x2
    80005c7a:	b5250513          	addi	a0,a0,-1198 # 800077c8 <syscalls+0x3d0>
    80005c7e:	b0bfa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005c82:	00002517          	auipc	a0,0x2
    80005c86:	b6650513          	addi	a0,a0,-1178 # 800077e8 <syscalls+0x3f0>
    80005c8a:	afffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    80005c8e:	00002517          	auipc	a0,0x2
    80005c92:	b7a50513          	addi	a0,a0,-1158 # 80007808 <syscalls+0x410>
    80005c96:	af3fa0ef          	jal	ra,80000788 <panic>

0000000080005c9a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005c9a:	7119                	addi	sp,sp,-128
    80005c9c:	fc86                	sd	ra,120(sp)
    80005c9e:	f8a2                	sd	s0,112(sp)
    80005ca0:	f4a6                	sd	s1,104(sp)
    80005ca2:	f0ca                	sd	s2,96(sp)
    80005ca4:	ecce                	sd	s3,88(sp)
    80005ca6:	e8d2                	sd	s4,80(sp)
    80005ca8:	e4d6                	sd	s5,72(sp)
    80005caa:	e0da                	sd	s6,64(sp)
    80005cac:	fc5e                	sd	s7,56(sp)
    80005cae:	f862                	sd	s8,48(sp)
    80005cb0:	f466                	sd	s9,40(sp)
    80005cb2:	f06a                	sd	s10,32(sp)
    80005cb4:	ec6e                	sd	s11,24(sp)
    80005cb6:	0100                	addi	s0,sp,128
    80005cb8:	8aaa                	mv	s5,a0
    80005cba:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cbc:	00c52d03          	lw	s10,12(a0)
    80005cc0:	001d1d1b          	slliw	s10,s10,0x1
    80005cc4:	1d02                	slli	s10,s10,0x20
    80005cc6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005cca:	00243517          	auipc	a0,0x243
    80005cce:	ede50513          	addi	a0,a0,-290 # 80248ba8 <disk+0x128>
    80005cd2:	fcffa0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80005cd6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005cd8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005cda:	00243b97          	auipc	s7,0x243
    80005cde:	da6b8b93          	addi	s7,s7,-602 # 80248a80 <disk>
  for(int i = 0; i < 3; i++){
    80005ce2:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ce4:	00243c97          	auipc	s9,0x243
    80005ce8:	ec4c8c93          	addi	s9,s9,-316 # 80248ba8 <disk+0x128>
    80005cec:	a8a9                	j	80005d46 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005cee:	00fb8733          	add	a4,s7,a5
    80005cf2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005cf6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005cf8:	0207c563          	bltz	a5,80005d22 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005cfc:	2905                	addiw	s2,s2,1
    80005cfe:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d00:	05690863          	beq	s2,s6,80005d50 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005d04:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005d06:	00243717          	auipc	a4,0x243
    80005d0a:	d7a70713          	addi	a4,a4,-646 # 80248a80 <disk>
    80005d0e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005d10:	01874683          	lbu	a3,24(a4)
    80005d14:	fee9                	bnez	a3,80005cee <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005d16:	2785                	addiw	a5,a5,1
    80005d18:	0705                	addi	a4,a4,1
    80005d1a:	fe979be3          	bne	a5,s1,80005d10 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005d1e:	57fd                	li	a5,-1
    80005d20:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005d22:	01205b63          	blez	s2,80005d38 <virtio_disk_rw+0x9e>
    80005d26:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005d28:	000a2503          	lw	a0,0(s4)
    80005d2c:	d43ff0ef          	jal	ra,80005a6e <free_desc>
      for(int j = 0; j < i; j++)
    80005d30:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80005d32:	0a11                	addi	s4,s4,4
    80005d34:	ff2d9ae3          	bne	s11,s2,80005d28 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d38:	85e6                	mv	a1,s9
    80005d3a:	00243517          	auipc	a0,0x243
    80005d3e:	d5e50513          	addi	a0,a0,-674 # 80248a98 <disk+0x18>
    80005d42:	c2efc0ef          	jal	ra,80002170 <sleep>
  for(int i = 0; i < 3; i++){
    80005d46:	f8040a13          	addi	s4,s0,-128
{
    80005d4a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005d4c:	894e                	mv	s2,s3
    80005d4e:	bf5d                	j	80005d04 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d50:	f8042503          	lw	a0,-128(s0)
    80005d54:	00a50713          	addi	a4,a0,10
    80005d58:	0712                	slli	a4,a4,0x4

  if(write)
    80005d5a:	00243797          	auipc	a5,0x243
    80005d5e:	d2678793          	addi	a5,a5,-730 # 80248a80 <disk>
    80005d62:	00e786b3          	add	a3,a5,a4
    80005d66:	01803633          	snez	a2,s8
    80005d6a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d6c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005d70:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005d74:	f6070613          	addi	a2,a4,-160
    80005d78:	6394                	ld	a3,0(a5)
    80005d7a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d7c:	00870593          	addi	a1,a4,8
    80005d80:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005d82:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005d84:	0007b803          	ld	a6,0(a5)
    80005d88:	9642                	add	a2,a2,a6
    80005d8a:	46c1                	li	a3,16
    80005d8c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005d8e:	4585                	li	a1,1
    80005d90:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005d94:	f8442683          	lw	a3,-124(s0)
    80005d98:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005d9c:	0692                	slli	a3,a3,0x4
    80005d9e:	9836                	add	a6,a6,a3
    80005da0:	058a8613          	addi	a2,s5,88
    80005da4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005da8:	0007b803          	ld	a6,0(a5)
    80005dac:	96c2                	add	a3,a3,a6
    80005dae:	40000613          	li	a2,1024
    80005db2:	c690                	sw	a2,8(a3)
  if(write)
    80005db4:	001c3613          	seqz	a2,s8
    80005db8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dbc:	00166613          	ori	a2,a2,1
    80005dc0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005dc4:	f8842603          	lw	a2,-120(s0)
    80005dc8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005dcc:	00250693          	addi	a3,a0,2
    80005dd0:	0692                	slli	a3,a3,0x4
    80005dd2:	96be                	add	a3,a3,a5
    80005dd4:	58fd                	li	a7,-1
    80005dd6:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005dda:	0612                	slli	a2,a2,0x4
    80005ddc:	9832                	add	a6,a6,a2
    80005dde:	f9070713          	addi	a4,a4,-112
    80005de2:	973e                	add	a4,a4,a5
    80005de4:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005de8:	6398                	ld	a4,0(a5)
    80005dea:	9732                	add	a4,a4,a2
    80005dec:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005dee:	4609                	li	a2,2
    80005df0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005df4:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005df8:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005dfc:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e00:	6794                	ld	a3,8(a5)
    80005e02:	0026d703          	lhu	a4,2(a3)
    80005e06:	8b1d                	andi	a4,a4,7
    80005e08:	0706                	slli	a4,a4,0x1
    80005e0a:	96ba                	add	a3,a3,a4
    80005e0c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005e10:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e14:	6798                	ld	a4,8(a5)
    80005e16:	00275783          	lhu	a5,2(a4)
    80005e1a:	2785                	addiw	a5,a5,1
    80005e1c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005e20:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e24:	100017b7          	lui	a5,0x10001
    80005e28:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005e2c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005e30:	00243917          	auipc	s2,0x243
    80005e34:	d7890913          	addi	s2,s2,-648 # 80248ba8 <disk+0x128>
  while(b->disk == 1) {
    80005e38:	4485                	li	s1,1
    80005e3a:	00b79a63          	bne	a5,a1,80005e4e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005e3e:	85ca                	mv	a1,s2
    80005e40:	8556                	mv	a0,s5
    80005e42:	b2efc0ef          	jal	ra,80002170 <sleep>
  while(b->disk == 1) {
    80005e46:	004aa783          	lw	a5,4(s5)
    80005e4a:	fe978ae3          	beq	a5,s1,80005e3e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005e4e:	f8042903          	lw	s2,-128(s0)
    80005e52:	00290713          	addi	a4,s2,2
    80005e56:	0712                	slli	a4,a4,0x4
    80005e58:	00243797          	auipc	a5,0x243
    80005e5c:	c2878793          	addi	a5,a5,-984 # 80248a80 <disk>
    80005e60:	97ba                	add	a5,a5,a4
    80005e62:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e66:	00243997          	auipc	s3,0x243
    80005e6a:	c1a98993          	addi	s3,s3,-998 # 80248a80 <disk>
    80005e6e:	00491713          	slli	a4,s2,0x4
    80005e72:	0009b783          	ld	a5,0(s3)
    80005e76:	97ba                	add	a5,a5,a4
    80005e78:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005e7c:	854a                	mv	a0,s2
    80005e7e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005e82:	bedff0ef          	jal	ra,80005a6e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005e86:	8885                	andi	s1,s1,1
    80005e88:	f0fd                	bnez	s1,80005e6e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005e8a:	00243517          	auipc	a0,0x243
    80005e8e:	d1e50513          	addi	a0,a0,-738 # 80248ba8 <disk+0x128>
    80005e92:	ea7fa0ef          	jal	ra,80000d38 <release>
}
    80005e96:	70e6                	ld	ra,120(sp)
    80005e98:	7446                	ld	s0,112(sp)
    80005e9a:	74a6                	ld	s1,104(sp)
    80005e9c:	7906                	ld	s2,96(sp)
    80005e9e:	69e6                	ld	s3,88(sp)
    80005ea0:	6a46                	ld	s4,80(sp)
    80005ea2:	6aa6                	ld	s5,72(sp)
    80005ea4:	6b06                	ld	s6,64(sp)
    80005ea6:	7be2                	ld	s7,56(sp)
    80005ea8:	7c42                	ld	s8,48(sp)
    80005eaa:	7ca2                	ld	s9,40(sp)
    80005eac:	7d02                	ld	s10,32(sp)
    80005eae:	6de2                	ld	s11,24(sp)
    80005eb0:	6109                	addi	sp,sp,128
    80005eb2:	8082                	ret

0000000080005eb4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005eb4:	1101                	addi	sp,sp,-32
    80005eb6:	ec06                	sd	ra,24(sp)
    80005eb8:	e822                	sd	s0,16(sp)
    80005eba:	e426                	sd	s1,8(sp)
    80005ebc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ebe:	00243497          	auipc	s1,0x243
    80005ec2:	bc248493          	addi	s1,s1,-1086 # 80248a80 <disk>
    80005ec6:	00243517          	auipc	a0,0x243
    80005eca:	ce250513          	addi	a0,a0,-798 # 80248ba8 <disk+0x128>
    80005ece:	dd3fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ed2:	10001737          	lui	a4,0x10001
    80005ed6:	533c                	lw	a5,96(a4)
    80005ed8:	8b8d                	andi	a5,a5,3
    80005eda:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005edc:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ee0:	689c                	ld	a5,16(s1)
    80005ee2:	0204d703          	lhu	a4,32(s1)
    80005ee6:	0027d783          	lhu	a5,2(a5)
    80005eea:	04f70663          	beq	a4,a5,80005f36 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005eee:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ef2:	6898                	ld	a4,16(s1)
    80005ef4:	0204d783          	lhu	a5,32(s1)
    80005ef8:	8b9d                	andi	a5,a5,7
    80005efa:	078e                	slli	a5,a5,0x3
    80005efc:	97ba                	add	a5,a5,a4
    80005efe:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005f00:	00278713          	addi	a4,a5,2
    80005f04:	0712                	slli	a4,a4,0x4
    80005f06:	9726                	add	a4,a4,s1
    80005f08:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005f0c:	e321                	bnez	a4,80005f4c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f0e:	0789                	addi	a5,a5,2
    80005f10:	0792                	slli	a5,a5,0x4
    80005f12:	97a6                	add	a5,a5,s1
    80005f14:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005f16:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f1a:	aa2fc0ef          	jal	ra,800021bc <wakeup>

    disk.used_idx += 1;
    80005f1e:	0204d783          	lhu	a5,32(s1)
    80005f22:	2785                	addiw	a5,a5,1
    80005f24:	17c2                	slli	a5,a5,0x30
    80005f26:	93c1                	srli	a5,a5,0x30
    80005f28:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005f2c:	6898                	ld	a4,16(s1)
    80005f2e:	00275703          	lhu	a4,2(a4)
    80005f32:	faf71ee3          	bne	a4,a5,80005eee <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005f36:	00243517          	auipc	a0,0x243
    80005f3a:	c7250513          	addi	a0,a0,-910 # 80248ba8 <disk+0x128>
    80005f3e:	dfbfa0ef          	jal	ra,80000d38 <release>
}
    80005f42:	60e2                	ld	ra,24(sp)
    80005f44:	6442                	ld	s0,16(sp)
    80005f46:	64a2                	ld	s1,8(sp)
    80005f48:	6105                	addi	sp,sp,32
    80005f4a:	8082                	ret
      panic("virtio_disk_intr status");
    80005f4c:	00002517          	auipc	a0,0x2
    80005f50:	8d450513          	addi	a0,a0,-1836 # 80007820 <syscalls+0x428>
    80005f54:	835fa0ef          	jal	ra,80000788 <panic>
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
