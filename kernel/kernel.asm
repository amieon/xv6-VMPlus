
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
    80000084:	eb478793          	addi	a5,a5,-332 # 80000f34 <main>
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
    8000010a:	752020ef          	jal	ra,8000285c <either_copyin>
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
    8000017a:	345000ef          	jal	ra,80000cbe <acquire>
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
    800001a4:	21b010ef          	jal	ra,80001bbe <myproc>
    800001a8:	546020ef          	jal	ra,800026ee <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	304020ef          	jal	ra,800024b6 <sleep>
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
    800001ea:	628020ef          	jal	ra,80002812 <either_copyout>
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
    80000202:	355000ef          	jal	ra,80000d56 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	6f450513          	addi	a0,a0,1780 # 80010900 <cons>
    80000214:	343000ef          	jal	ra,80000d56 <release>
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
    80000290:	22f000ef          	jal	ra,80000cbe <acquire>

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
    800002aa:	5fc020ef          	jal	ra,800028a6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	65250513          	addi	a0,a0,1618 # 80010900 <cons>
    800002b6:	2a1000ef          	jal	ra,80000d56 <release>
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
    800003e6:	11c020ef          	jal	ra,80002502 <wakeup>
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
    80000404:	03b000ef          	jal	ra,80000c3e <initlock>

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
    8000053c:	782000ef          	jal	ra,80000cbe <acquire>
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
    80000784:	5d2000ef          	jal	ra,80000d56 <release>
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
    800007de:	460000ef          	jal	ra,80000c3e <initlock>
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
    8000082a:	414000ef          	jal	ra,80000c3e <initlock>
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
    80000858:	466000ef          	jal	ra,80000cbe <acquire>

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
    80000892:	425010ef          	jal	ra,800024b6 <sleep>
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
    800008ba:	49c000ef          	jal	ra,80000d56 <release>
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
    800008fa:	384000ef          	jal	ra,80000c7e <push_off>
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
    8000092a:	3d8000ef          	jal	ra,80000d02 <pop_off>
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
    80000972:	34c000ef          	jal	ra,80000cbe <acquire>
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
    80000988:	3ce000ef          	jal	ra,80000d56 <release>

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
    800009a0:	363010ef          	jal	ra,80002502 <wakeup>
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
    800009d0:	2ee000ef          	jal	ra,80000cbe <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d4:	00010517          	auipc	a0,0x10
    800009d8:	02450513          	addi	a0,a0,36 # 800109f8 <kref>
    800009dc:	80b1                	srli	s1,s1,0xc
    800009de:	0491                	addi	s1,s1,4
    800009e0:	048a                	slli	s1,s1,0x2
    800009e2:	94aa                	add	s1,s1,a0
    800009e4:	4484                	lw	s1,8(s1)
  release(&kref.lock);
    800009e6:	370000ef          	jal	ra,80000d56 <release>
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
    80000a0a:	2b4000ef          	jal	ra,80000cbe <acquire>
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
    80000a2a:	32c000ef          	jal	ra,80000d56 <release>
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
    80000a4e:	270000ef          	jal	ra,80000cbe <acquire>
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
    80000a6e:	2e8000ef          	jal	ra,80000d56 <release>
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
  {extern uint64 kfree_cnt; kfree_cnt++;}
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
    80000acc:	2c6000ef          	jal	ra,80000d92 <memset>
  acquire(&kmem.lock);
    80000ad0:	00010917          	auipc	s2,0x10
    80000ad4:	f0890913          	addi	s2,s2,-248 # 800109d8 <kmem>
    80000ad8:	854a                	mv	a0,s2
    80000ada:	1e4000ef          	jal	ra,80000cbe <acquire>
  r->next = kmem.freelist;
    80000ade:	01893783          	ld	a5,24(s2)
    80000ae2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ae4:	00993c23          	sd	s1,24(s2)
  {extern uint64 kfree_cnt; kfree_cnt++;}
    80000ae8:	00008717          	auipc	a4,0x8
    80000aec:	de870713          	addi	a4,a4,-536 # 800088d0 <kfree_cnt>
    80000af0:	631c                	ld	a5,0(a4)
    80000af2:	0785                	addi	a5,a5,1
    80000af4:	e31c                	sd	a5,0(a4)
  release(&kmem.lock);
    80000af6:	854a                	mv	a0,s2
    80000af8:	25e000ef          	jal	ra,80000d56 <release>
    80000afc:	bf4d                	j	80000aae <kfree+0x30>

0000000080000afe <freerange>:
{
    80000afe:	7139                	addi	sp,sp,-64
    80000b00:	fc06                	sd	ra,56(sp)
    80000b02:	f822                	sd	s0,48(sp)
    80000b04:	f426                	sd	s1,40(sp)
    80000b06:	f04a                	sd	s2,32(sp)
    80000b08:	ec4e                	sd	s3,24(sp)
    80000b0a:	e852                	sd	s4,16(sp)
    80000b0c:	e456                	sd	s5,8(sp)
    80000b0e:	e05a                	sd	s6,0(sp)
    80000b10:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b12:	6785                	lui	a5,0x1
    80000b14:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b18:	9526                	add	a0,a0,s1
    80000b1a:	74fd                	lui	s1,0xfffff
    80000b1c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b1e:	97a6                	add	a5,a5,s1
    80000b20:	02f5ef63          	bltu	a1,a5,80000b5e <freerange+0x60>
    80000b24:	89ae                	mv	s3,a1
    acquire(&kref.lock);
    80000b26:	00010917          	auipc	s2,0x10
    80000b2a:	ed290913          	addi	s2,s2,-302 # 800109f8 <kref>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b2e:	4b05                	li	s6,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b30:	6a85                	lui	s5,0x1
    80000b32:	6a09                	lui	s4,0x2
    acquire(&kref.lock);
    80000b34:	854a                	mv	a0,s2
    80000b36:	188000ef          	jal	ra,80000cbe <acquire>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b3a:	00c4d793          	srli	a5,s1,0xc
    80000b3e:	0791                	addi	a5,a5,4
    80000b40:	078a                	slli	a5,a5,0x2
    80000b42:	97ca                	add	a5,a5,s2
    80000b44:	0167a423          	sw	s6,8(a5)
    release(&kref.lock);
    80000b48:	854a                	mv	a0,s2
    80000b4a:	20c000ef          	jal	ra,80000d56 <release>
    kfree(p);
    80000b4e:	8526                	mv	a0,s1
    80000b50:	f2fff0ef          	jal	ra,80000a7e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b54:	87a6                	mv	a5,s1
    80000b56:	94d6                	add	s1,s1,s5
    80000b58:	97d2                	add	a5,a5,s4
    80000b5a:	fcf9fde3          	bgeu	s3,a5,80000b34 <freerange+0x36>
}
    80000b5e:	70e2                	ld	ra,56(sp)
    80000b60:	7442                	ld	s0,48(sp)
    80000b62:	74a2                	ld	s1,40(sp)
    80000b64:	7902                	ld	s2,32(sp)
    80000b66:	69e2                	ld	s3,24(sp)
    80000b68:	6a42                	ld	s4,16(sp)
    80000b6a:	6aa2                	ld	s5,8(sp)
    80000b6c:	6b02                	ld	s6,0(sp)
    80000b6e:	6121                	addi	sp,sp,64
    80000b70:	8082                	ret

0000000080000b72 <kinit>:
{
    80000b72:	1141                	addi	sp,sp,-16
    80000b74:	e406                	sd	ra,8(sp)
    80000b76:	e022                	sd	s0,0(sp)
    80000b78:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b7a:	00007597          	auipc	a1,0x7
    80000b7e:	4e658593          	addi	a1,a1,1254 # 80008060 <digits+0x28>
    80000b82:	00010517          	auipc	a0,0x10
    80000b86:	e5650513          	addi	a0,a0,-426 # 800109d8 <kmem>
    80000b8a:	0b4000ef          	jal	ra,80000c3e <initlock>
  initlock(&kref.lock, "kref");
    80000b8e:	00007597          	auipc	a1,0x7
    80000b92:	4da58593          	addi	a1,a1,1242 # 80008068 <digits+0x30>
    80000b96:	00010517          	auipc	a0,0x10
    80000b9a:	e6250513          	addi	a0,a0,-414 # 800109f8 <kref>
    80000b9e:	0a0000ef          	jal	ra,80000c3e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ba2:	45c5                	li	a1,17
    80000ba4:	05ee                	slli	a1,a1,0x1b
    80000ba6:	00253517          	auipc	a0,0x253
    80000baa:	65a50513          	addi	a0,a0,1626 # 80254200 <end>
    80000bae:	f51ff0ef          	jal	ra,80000afe <freerange>
}
    80000bb2:	60a2                	ld	ra,8(sp)
    80000bb4:	6402                	ld	s0,0(sp)
    80000bb6:	0141                	addi	sp,sp,16
    80000bb8:	8082                	ret

0000000080000bba <kalloc>:
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.

void *
kalloc(void)
{
    80000bba:	1101                	addi	sp,sp,-32
    80000bbc:	ec06                	sd	ra,24(sp)
    80000bbe:	e822                	sd	s0,16(sp)
    80000bc0:	e426                	sd	s1,8(sp)
    80000bc2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bc4:	00010497          	auipc	s1,0x10
    80000bc8:	e1448493          	addi	s1,s1,-492 # 800109d8 <kmem>
    80000bcc:	8526                	mv	a0,s1
    80000bce:	0f0000ef          	jal	ra,80000cbe <acquire>
  r = kmem.freelist;
    80000bd2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bd4:	ccb1                	beqz	s1,80000c30 <kalloc+0x76>
    kmem.freelist = r->next;
    80000bd6:	609c                	ld	a5,0(s1)
    80000bd8:	00010517          	auipc	a0,0x10
    80000bdc:	e0050513          	addi	a0,a0,-512 # 800109d8 <kmem>
    80000be0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000be2:	174000ef          	jal	ra,80000d56 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000be6:	6605                	lui	a2,0x1
    80000be8:	4595                	li	a1,5
    80000bea:	8526                	mv	a0,s1
    80000bec:	1a6000ef          	jal	ra,80000d92 <memset>
   * 初始化新分配页的引用计数
   * 
   * 新分配的物理页默认引用计数为1，表示被当前调用者拥有
   */
  if(r){
    acquire(&kref.lock);
    80000bf0:	00010517          	auipc	a0,0x10
    80000bf4:	e0850513          	addi	a0,a0,-504 # 800109f8 <kref>
    80000bf8:	0c6000ef          	jal	ra,80000cbe <acquire>
    kref.refcnt[PA2IDX(r)] = 1;
    80000bfc:	00010517          	auipc	a0,0x10
    80000c00:	dfc50513          	addi	a0,a0,-516 # 800109f8 <kref>
    80000c04:	00c4d793          	srli	a5,s1,0xc
    80000c08:	0791                	addi	a5,a5,4
    80000c0a:	078a                	slli	a5,a5,0x2
    80000c0c:	97aa                	add	a5,a5,a0
    80000c0e:	4705                	li	a4,1
    80000c10:	c798                	sw	a4,8(a5)
    release(&kref.lock);
    80000c12:	144000ef          	jal	ra,80000d56 <release>
  }
  extern uint64 kalloc_cnt;
  kalloc_cnt++;
    80000c16:	00008717          	auipc	a4,0x8
    80000c1a:	ce270713          	addi	a4,a4,-798 # 800088f8 <kalloc_cnt>
    80000c1e:	631c                	ld	a5,0(a4)
    80000c20:	0785                	addi	a5,a5,1
    80000c22:	e31c                	sd	a5,0(a4)


  return (void*)r;
}
    80000c24:	8526                	mv	a0,s1
    80000c26:	60e2                	ld	ra,24(sp)
    80000c28:	6442                	ld	s0,16(sp)
    80000c2a:	64a2                	ld	s1,8(sp)
    80000c2c:	6105                	addi	sp,sp,32
    80000c2e:	8082                	ret
  release(&kmem.lock);
    80000c30:	00010517          	auipc	a0,0x10
    80000c34:	da850513          	addi	a0,a0,-600 # 800109d8 <kmem>
    80000c38:	11e000ef          	jal	ra,80000d56 <release>
  if(r){
    80000c3c:	bfe9                	j	80000c16 <kalloc+0x5c>

0000000080000c3e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e422                	sd	s0,8(sp)
    80000c42:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c44:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c46:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c4a:	00053823          	sd	zero,16(a0)
}
    80000c4e:	6422                	ld	s0,8(sp)
    80000c50:	0141                	addi	sp,sp,16
    80000c52:	8082                	ret

0000000080000c54 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c54:	411c                	lw	a5,0(a0)
    80000c56:	e399                	bnez	a5,80000c5c <holding+0x8>
    80000c58:	4501                	li	a0,0
  return r;
}
    80000c5a:	8082                	ret
{
    80000c5c:	1101                	addi	sp,sp,-32
    80000c5e:	ec06                	sd	ra,24(sp)
    80000c60:	e822                	sd	s0,16(sp)
    80000c62:	e426                	sd	s1,8(sp)
    80000c64:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c66:	6904                	ld	s1,16(a0)
    80000c68:	73b000ef          	jal	ra,80001ba2 <mycpu>
    80000c6c:	40a48533          	sub	a0,s1,a0
    80000c70:	00153513          	seqz	a0,a0
}
    80000c74:	60e2                	ld	ra,24(sp)
    80000c76:	6442                	ld	s0,16(sp)
    80000c78:	64a2                	ld	s1,8(sp)
    80000c7a:	6105                	addi	sp,sp,32
    80000c7c:	8082                	ret

0000000080000c7e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c7e:	1101                	addi	sp,sp,-32
    80000c80:	ec06                	sd	ra,24(sp)
    80000c82:	e822                	sd	s0,16(sp)
    80000c84:	e426                	sd	s1,8(sp)
    80000c86:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c88:	100024f3          	csrr	s1,sstatus
    80000c8c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c90:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c92:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c96:	70d000ef          	jal	ra,80001ba2 <mycpu>
    80000c9a:	5d3c                	lw	a5,120(a0)
    80000c9c:	cb99                	beqz	a5,80000cb2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c9e:	705000ef          	jal	ra,80001ba2 <mycpu>
    80000ca2:	5d3c                	lw	a5,120(a0)
    80000ca4:	2785                	addiw	a5,a5,1
    80000ca6:	dd3c                	sw	a5,120(a0)
}
    80000ca8:	60e2                	ld	ra,24(sp)
    80000caa:	6442                	ld	s0,16(sp)
    80000cac:	64a2                	ld	s1,8(sp)
    80000cae:	6105                	addi	sp,sp,32
    80000cb0:	8082                	ret
    mycpu()->intena = old;
    80000cb2:	6f1000ef          	jal	ra,80001ba2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cb6:	8085                	srli	s1,s1,0x1
    80000cb8:	8885                	andi	s1,s1,1
    80000cba:	dd64                	sw	s1,124(a0)
    80000cbc:	b7cd                	j	80000c9e <push_off+0x20>

0000000080000cbe <acquire>:
{
    80000cbe:	1101                	addi	sp,sp,-32
    80000cc0:	ec06                	sd	ra,24(sp)
    80000cc2:	e822                	sd	s0,16(sp)
    80000cc4:	e426                	sd	s1,8(sp)
    80000cc6:	1000                	addi	s0,sp,32
    80000cc8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cca:	fb5ff0ef          	jal	ra,80000c7e <push_off>
  if(holding(lk))
    80000cce:	8526                	mv	a0,s1
    80000cd0:	f85ff0ef          	jal	ra,80000c54 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cd4:	4705                	li	a4,1
  if(holding(lk))
    80000cd6:	e105                	bnez	a0,80000cf6 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cd8:	87ba                	mv	a5,a4
    80000cda:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cde:	2781                	sext.w	a5,a5
    80000ce0:	ffe5                	bnez	a5,80000cd8 <acquire+0x1a>
  __sync_synchronize();
    80000ce2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000ce6:	6bd000ef          	jal	ra,80001ba2 <mycpu>
    80000cea:	e888                	sd	a0,16(s1)
}
    80000cec:	60e2                	ld	ra,24(sp)
    80000cee:	6442                	ld	s0,16(sp)
    80000cf0:	64a2                	ld	s1,8(sp)
    80000cf2:	6105                	addi	sp,sp,32
    80000cf4:	8082                	ret
    panic("acquire");
    80000cf6:	00007517          	auipc	a0,0x7
    80000cfa:	37a50513          	addi	a0,a0,890 # 80008070 <digits+0x38>
    80000cfe:	a8dff0ef          	jal	ra,8000078a <panic>

0000000080000d02 <pop_off>:

void
pop_off(void)
{
    80000d02:	1141                	addi	sp,sp,-16
    80000d04:	e406                	sd	ra,8(sp)
    80000d06:	e022                	sd	s0,0(sp)
    80000d08:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d0a:	699000ef          	jal	ra,80001ba2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d0e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d12:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d14:	e78d                	bnez	a5,80000d3e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d16:	5d3c                	lw	a5,120(a0)
    80000d18:	02f05963          	blez	a5,80000d4a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000d1c:	37fd                	addiw	a5,a5,-1
    80000d1e:	0007871b          	sext.w	a4,a5
    80000d22:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d24:	eb09                	bnez	a4,80000d36 <pop_off+0x34>
    80000d26:	5d7c                	lw	a5,124(a0)
    80000d28:	c799                	beqz	a5,80000d36 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d32:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d36:	60a2                	ld	ra,8(sp)
    80000d38:	6402                	ld	s0,0(sp)
    80000d3a:	0141                	addi	sp,sp,16
    80000d3c:	8082                	ret
    panic("pop_off - interruptible");
    80000d3e:	00007517          	auipc	a0,0x7
    80000d42:	33a50513          	addi	a0,a0,826 # 80008078 <digits+0x40>
    80000d46:	a45ff0ef          	jal	ra,8000078a <panic>
    panic("pop_off");
    80000d4a:	00007517          	auipc	a0,0x7
    80000d4e:	34650513          	addi	a0,a0,838 # 80008090 <digits+0x58>
    80000d52:	a39ff0ef          	jal	ra,8000078a <panic>

0000000080000d56 <release>:
{
    80000d56:	1101                	addi	sp,sp,-32
    80000d58:	ec06                	sd	ra,24(sp)
    80000d5a:	e822                	sd	s0,16(sp)
    80000d5c:	e426                	sd	s1,8(sp)
    80000d5e:	1000                	addi	s0,sp,32
    80000d60:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d62:	ef3ff0ef          	jal	ra,80000c54 <holding>
    80000d66:	c105                	beqz	a0,80000d86 <release+0x30>
  lk->cpu = 0;
    80000d68:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d6c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d70:	0f50000f          	fence	iorw,ow
    80000d74:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d78:	f8bff0ef          	jal	ra,80000d02 <pop_off>
}
    80000d7c:	60e2                	ld	ra,24(sp)
    80000d7e:	6442                	ld	s0,16(sp)
    80000d80:	64a2                	ld	s1,8(sp)
    80000d82:	6105                	addi	sp,sp,32
    80000d84:	8082                	ret
    panic("release");
    80000d86:	00007517          	auipc	a0,0x7
    80000d8a:	31250513          	addi	a0,a0,786 # 80008098 <digits+0x60>
    80000d8e:	9fdff0ef          	jal	ra,8000078a <panic>

0000000080000d92 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e422                	sd	s0,8(sp)
    80000d96:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d98:	ca19                	beqz	a2,80000dae <memset+0x1c>
    80000d9a:	87aa                	mv	a5,a0
    80000d9c:	1602                	slli	a2,a2,0x20
    80000d9e:	9201                	srli	a2,a2,0x20
    80000da0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000da4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000da8:	0785                	addi	a5,a5,1
    80000daa:	fee79de3          	bne	a5,a4,80000da4 <memset+0x12>
  }
  return dst;
}
    80000dae:	6422                	ld	s0,8(sp)
    80000db0:	0141                	addi	sp,sp,16
    80000db2:	8082                	ret

0000000080000db4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e422                	sd	s0,8(sp)
    80000db8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dba:	ca05                	beqz	a2,80000dea <memcmp+0x36>
    80000dbc:	fff6069b          	addiw	a3,a2,-1
    80000dc0:	1682                	slli	a3,a3,0x20
    80000dc2:	9281                	srli	a3,a3,0x20
    80000dc4:	0685                	addi	a3,a3,1
    80000dc6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dc8:	00054783          	lbu	a5,0(a0)
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00e79863          	bne	a5,a4,80000de0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dd4:	0505                	addi	a0,a0,1
    80000dd6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dd8:	fed518e3          	bne	a0,a3,80000dc8 <memcmp+0x14>
  }

  return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a019                	j	80000de4 <memcmp+0x30>
      return *s1 - *s2;
    80000de0:	40e7853b          	subw	a0,a5,a4
}
    80000de4:	6422                	ld	s0,8(sp)
    80000de6:	0141                	addi	sp,sp,16
    80000de8:	8082                	ret
  return 0;
    80000dea:	4501                	li	a0,0
    80000dec:	bfe5                	j	80000de4 <memcmp+0x30>

0000000080000dee <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e422                	sd	s0,8(sp)
    80000df2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000df4:	c205                	beqz	a2,80000e14 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000df6:	02a5e263          	bltu	a1,a0,80000e1a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dfa:	1602                	slli	a2,a2,0x20
    80000dfc:	9201                	srli	a2,a2,0x20
    80000dfe:	00c587b3          	add	a5,a1,a2
{
    80000e02:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e04:	0585                	addi	a1,a1,1
    80000e06:	0705                	addi	a4,a4,1
    80000e08:	fff5c683          	lbu	a3,-1(a1)
    80000e0c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e10:	fef59ae3          	bne	a1,a5,80000e04 <memmove+0x16>

  return dst;
}
    80000e14:	6422                	ld	s0,8(sp)
    80000e16:	0141                	addi	sp,sp,16
    80000e18:	8082                	ret
  if(s < d && s + n > d){
    80000e1a:	02061693          	slli	a3,a2,0x20
    80000e1e:	9281                	srli	a3,a3,0x20
    80000e20:	00d58733          	add	a4,a1,a3
    80000e24:	fce57be3          	bgeu	a0,a4,80000dfa <memmove+0xc>
    d += n;
    80000e28:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e2a:	fff6079b          	addiw	a5,a2,-1
    80000e2e:	1782                	slli	a5,a5,0x20
    80000e30:	9381                	srli	a5,a5,0x20
    80000e32:	fff7c793          	not	a5,a5
    80000e36:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e38:	177d                	addi	a4,a4,-1
    80000e3a:	16fd                	addi	a3,a3,-1
    80000e3c:	00074603          	lbu	a2,0(a4)
    80000e40:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e44:	fee79ae3          	bne	a5,a4,80000e38 <memmove+0x4a>
    80000e48:	b7f1                	j	80000e14 <memmove+0x26>

0000000080000e4a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e4a:	1141                	addi	sp,sp,-16
    80000e4c:	e406                	sd	ra,8(sp)
    80000e4e:	e022                	sd	s0,0(sp)
    80000e50:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e52:	f9dff0ef          	jal	ra,80000dee <memmove>
}
    80000e56:	60a2                	ld	ra,8(sp)
    80000e58:	6402                	ld	s0,0(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret

0000000080000e5e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e422                	sd	s0,8(sp)
    80000e62:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e64:	ce11                	beqz	a2,80000e80 <strncmp+0x22>
    80000e66:	00054783          	lbu	a5,0(a0)
    80000e6a:	cf89                	beqz	a5,80000e84 <strncmp+0x26>
    80000e6c:	0005c703          	lbu	a4,0(a1)
    80000e70:	00f71a63          	bne	a4,a5,80000e84 <strncmp+0x26>
    n--, p++, q++;
    80000e74:	367d                	addiw	a2,a2,-1
    80000e76:	0505                	addi	a0,a0,1
    80000e78:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e7a:	f675                	bnez	a2,80000e66 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e7c:	4501                	li	a0,0
    80000e7e:	a809                	j	80000e90 <strncmp+0x32>
    80000e80:	4501                	li	a0,0
    80000e82:	a039                	j	80000e90 <strncmp+0x32>
  if(n == 0)
    80000e84:	ca09                	beqz	a2,80000e96 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e86:	00054503          	lbu	a0,0(a0)
    80000e8a:	0005c783          	lbu	a5,0(a1)
    80000e8e:	9d1d                	subw	a0,a0,a5
}
    80000e90:	6422                	ld	s0,8(sp)
    80000e92:	0141                	addi	sp,sp,16
    80000e94:	8082                	ret
    return 0;
    80000e96:	4501                	li	a0,0
    80000e98:	bfe5                	j	80000e90 <strncmp+0x32>

0000000080000e9a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e9a:	1141                	addi	sp,sp,-16
    80000e9c:	e422                	sd	s0,8(sp)
    80000e9e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ea0:	872a                	mv	a4,a0
    80000ea2:	8832                	mv	a6,a2
    80000ea4:	367d                	addiw	a2,a2,-1
    80000ea6:	01005963          	blez	a6,80000eb8 <strncpy+0x1e>
    80000eaa:	0705                	addi	a4,a4,1
    80000eac:	0005c783          	lbu	a5,0(a1)
    80000eb0:	fef70fa3          	sb	a5,-1(a4)
    80000eb4:	0585                	addi	a1,a1,1
    80000eb6:	f7f5                	bnez	a5,80000ea2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000eb8:	86ba                	mv	a3,a4
    80000eba:	00c05c63          	blez	a2,80000ed2 <strncpy+0x38>
    *s++ = 0;
    80000ebe:	0685                	addi	a3,a3,1
    80000ec0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ec4:	fff6c793          	not	a5,a3
    80000ec8:	9fb9                	addw	a5,a5,a4
    80000eca:	010787bb          	addw	a5,a5,a6
    80000ece:	fef048e3          	bgtz	a5,80000ebe <strncpy+0x24>
  return os;
}
    80000ed2:	6422                	ld	s0,8(sp)
    80000ed4:	0141                	addi	sp,sp,16
    80000ed6:	8082                	ret

0000000080000ed8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ed8:	1141                	addi	sp,sp,-16
    80000eda:	e422                	sd	s0,8(sp)
    80000edc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ede:	02c05363          	blez	a2,80000f04 <safestrcpy+0x2c>
    80000ee2:	fff6069b          	addiw	a3,a2,-1
    80000ee6:	1682                	slli	a3,a3,0x20
    80000ee8:	9281                	srli	a3,a3,0x20
    80000eea:	96ae                	add	a3,a3,a1
    80000eec:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eee:	00d58963          	beq	a1,a3,80000f00 <safestrcpy+0x28>
    80000ef2:	0585                	addi	a1,a1,1
    80000ef4:	0785                	addi	a5,a5,1
    80000ef6:	fff5c703          	lbu	a4,-1(a1)
    80000efa:	fee78fa3          	sb	a4,-1(a5)
    80000efe:	fb65                	bnez	a4,80000eee <safestrcpy+0x16>
    ;
  *s = 0;
    80000f00:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f04:	6422                	ld	s0,8(sp)
    80000f06:	0141                	addi	sp,sp,16
    80000f08:	8082                	ret

0000000080000f0a <strlen>:

int
strlen(const char *s)
{
    80000f0a:	1141                	addi	sp,sp,-16
    80000f0c:	e422                	sd	s0,8(sp)
    80000f0e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f10:	00054783          	lbu	a5,0(a0)
    80000f14:	cf91                	beqz	a5,80000f30 <strlen+0x26>
    80000f16:	0505                	addi	a0,a0,1
    80000f18:	87aa                	mv	a5,a0
    80000f1a:	4685                	li	a3,1
    80000f1c:	9e89                	subw	a3,a3,a0
    80000f1e:	00f6853b          	addw	a0,a3,a5
    80000f22:	0785                	addi	a5,a5,1
    80000f24:	fff7c703          	lbu	a4,-1(a5)
    80000f28:	fb7d                	bnez	a4,80000f1e <strlen+0x14>
    ;
  return n;
}
    80000f2a:	6422                	ld	s0,8(sp)
    80000f2c:	0141                	addi	sp,sp,16
    80000f2e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f30:	4501                	li	a0,0
    80000f32:	bfe5                	j	80000f2a <strlen+0x20>

0000000080000f34 <main>:
 * - 其他CPU等待初始化完成后启动
 * - 所有CPU最终都进入调度器
 */
void
main()
{
    80000f34:	1141                	addi	sp,sp,-16
    80000f36:	e406                	sd	ra,8(sp)
    80000f38:	e022                	sd	s0,0(sp)
    80000f3a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f3c:	457000ef          	jal	ra,80001b92 <cpuid>
    seminit();

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f40:	00008717          	auipc	a4,0x8
    80000f44:	97070713          	addi	a4,a4,-1680 # 800088b0 <started>
  if(cpuid() == 0){
    80000f48:	c51d                	beqz	a0,80000f76 <main+0x42>
    while(started == 0)
    80000f4a:	431c                	lw	a5,0(a4)
    80000f4c:	2781                	sext.w	a5,a5
    80000f4e:	dff5                	beqz	a5,80000f4a <main+0x16>
      ;
    __sync_synchronize();
    80000f50:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f54:	43f000ef          	jal	ra,80001b92 <cpuid>
    80000f58:	85aa                	mv	a1,a0
    80000f5a:	00007517          	auipc	a0,0x7
    80000f5e:	15e50513          	addi	a0,a0,350 # 800080b8 <digits+0x80>
    80000f62:	d62ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000f66:	08c000ef          	jal	ra,80000ff2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f6a:	26d010ef          	jal	ra,800029d6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f6e:	0f6050ef          	jal	ra,80006064 <plicinithart>
  }

  scheduler();        
    80000f72:	3ac010ef          	jal	ra,8000231e <scheduler>
    consoleinit();
    80000f76:	c76ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000f7a:	84dff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000f7e:	00007517          	auipc	a0,0x7
    80000f82:	14a50513          	addi	a0,a0,330 # 800080c8 <digits+0x90>
    80000f86:	d3eff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000f8a:	00007517          	auipc	a0,0x7
    80000f8e:	11650513          	addi	a0,a0,278 # 800080a0 <digits+0x68>
    80000f92:	d32ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000f96:	00007517          	auipc	a0,0x7
    80000f9a:	13250513          	addi	a0,a0,306 # 800080c8 <digits+0x90>
    80000f9e:	d26ff0ef          	jal	ra,800004c4 <printf>
    vmstatsinit();
    80000fa2:	575050ef          	jal	ra,80006d16 <vmstatsinit>
    kinit();         // physical page allocator
    80000fa6:	bcdff0ef          	jal	ra,80000b72 <kinit>
    kvminit();       // create kernel page table
    80000faa:	2d2000ef          	jal	ra,8000127c <kvminit>
    kvminithart();   // turn on paging
    80000fae:	044000ef          	jal	ra,80000ff2 <kvminithart>
    procinit();      // process table
    80000fb2:	339000ef          	jal	ra,80001aea <procinit>
    trapinit();      // trap vectors
    80000fb6:	1fd010ef          	jal	ra,800029b2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fba:	21d010ef          	jal	ra,800029d6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fbe:	090050ef          	jal	ra,8000604e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fc2:	0a2050ef          	jal	ra,80006064 <plicinithart>
    binit();         // buffer cache
    80000fc6:	7e0020ef          	jal	ra,800037a6 <binit>
    iinit();         // inode table
    80000fca:	555020ef          	jal	ra,80003d1e <iinit>
    fileinit();      // file table
    80000fce:	435030ef          	jal	ra,80004c02 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fd2:	182050ef          	jal	ra,80006154 <virtio_disk_init>
    userinit();      // first user process
    80000fd6:	10c010ef          	jal	ra,800020e2 <userinit>
    shm_init();
    80000fda:	5f2050ef          	jal	ra,800065cc <shm_init>
    seminit();
    80000fde:	2fb050ef          	jal	ra,80006ad8 <seminit>
    __sync_synchronize();
    80000fe2:	0ff0000f          	fence
    started = 1;
    80000fe6:	4785                	li	a5,1
    80000fe8:	00008717          	auipc	a4,0x8
    80000fec:	8cf72423          	sw	a5,-1848(a4) # 800088b0 <started>
    80000ff0:	b749                	j	80000f72 <main+0x3e>

0000000080000ff2 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ff2:	1141                	addi	sp,sp,-16
    80000ff4:	e422                	sd	s0,8(sp)
    80000ff6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ff8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ffc:	00008797          	auipc	a5,0x8
    80001000:	8bc7b783          	ld	a5,-1860(a5) # 800088b8 <kernel_pagetable>
    80001004:	83b1                	srli	a5,a5,0xc
    80001006:	577d                	li	a4,-1
    80001008:	177e                	slli	a4,a4,0x3f
    8000100a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000100c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001010:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001014:	6422                	ld	s0,8(sp)
    80001016:	0141                	addi	sp,sp,16
    80001018:	8082                	ret

000000008000101a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000101a:	7139                	addi	sp,sp,-64
    8000101c:	fc06                	sd	ra,56(sp)
    8000101e:	f822                	sd	s0,48(sp)
    80001020:	f426                	sd	s1,40(sp)
    80001022:	f04a                	sd	s2,32(sp)
    80001024:	ec4e                	sd	s3,24(sp)
    80001026:	e852                	sd	s4,16(sp)
    80001028:	e456                	sd	s5,8(sp)
    8000102a:	e05a                	sd	s6,0(sp)
    8000102c:	0080                	addi	s0,sp,64
    8000102e:	84aa                	mv	s1,a0
    80001030:	89ae                	mv	s3,a1
    80001032:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001034:	57fd                	li	a5,-1
    80001036:	83e9                	srli	a5,a5,0x1a
    80001038:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000103a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000103c:	02b7fc63          	bgeu	a5,a1,80001074 <walk+0x5a>
    panic("walk");
    80001040:	00007517          	auipc	a0,0x7
    80001044:	09050513          	addi	a0,a0,144 # 800080d0 <digits+0x98>
    80001048:	f42ff0ef          	jal	ra,8000078a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000104c:	060a8263          	beqz	s5,800010b0 <walk+0x96>
    80001050:	b6bff0ef          	jal	ra,80000bba <kalloc>
    80001054:	84aa                	mv	s1,a0
    80001056:	c139                	beqz	a0,8000109c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001058:	6605                	lui	a2,0x1
    8000105a:	4581                	li	a1,0
    8000105c:	d37ff0ef          	jal	ra,80000d92 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001060:	00c4d793          	srli	a5,s1,0xc
    80001064:	07aa                	slli	a5,a5,0xa
    80001066:	0017e793          	ori	a5,a5,1
    8000106a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000106e:	3a5d                	addiw	s4,s4,-9
    80001070:	036a0063          	beq	s4,s6,80001090 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001074:	0149d933          	srl	s2,s3,s4
    80001078:	1ff97913          	andi	s2,s2,511
    8000107c:	090e                	slli	s2,s2,0x3
    8000107e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001080:	00093483          	ld	s1,0(s2)
    80001084:	0014f793          	andi	a5,s1,1
    80001088:	d3f1                	beqz	a5,8000104c <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108a:	80a9                	srli	s1,s1,0xa
    8000108c:	04b2                	slli	s1,s1,0xc
    8000108e:	b7c5                	j	8000106e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001090:	00c9d513          	srli	a0,s3,0xc
    80001094:	1ff57513          	andi	a0,a0,511
    80001098:	050e                	slli	a0,a0,0x3
    8000109a:	9526                	add	a0,a0,s1
}
    8000109c:	70e2                	ld	ra,56(sp)
    8000109e:	7442                	ld	s0,48(sp)
    800010a0:	74a2                	ld	s1,40(sp)
    800010a2:	7902                	ld	s2,32(sp)
    800010a4:	69e2                	ld	s3,24(sp)
    800010a6:	6a42                	ld	s4,16(sp)
    800010a8:	6aa2                	ld	s5,8(sp)
    800010aa:	6b02                	ld	s6,0(sp)
    800010ac:	6121                	addi	sp,sp,64
    800010ae:	8082                	ret
        return 0;
    800010b0:	4501                	li	a0,0
    800010b2:	b7ed                	j	8000109c <walk+0x82>

00000000800010b4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b4:	57fd                	li	a5,-1
    800010b6:	83e9                	srli	a5,a5,0x1a
    800010b8:	00b7f463          	bgeu	a5,a1,800010c0 <walkaddr+0xc>
    return 0;
    800010bc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010be:	8082                	ret
{
    800010c0:	1141                	addi	sp,sp,-16
    800010c2:	e406                	sd	ra,8(sp)
    800010c4:	e022                	sd	s0,0(sp)
    800010c6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010c8:	4601                	li	a2,0
    800010ca:	f51ff0ef          	jal	ra,8000101a <walk>
  if(pte == 0)
    800010ce:	c105                	beqz	a0,800010ee <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010d0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d2:	0117f693          	andi	a3,a5,17
    800010d6:	4745                	li	a4,17
    return 0;
    800010d8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010da:	00e68663          	beq	a3,a4,800010e6 <walkaddr+0x32>
}
    800010de:	60a2                	ld	ra,8(sp)
    800010e0:	6402                	ld	s0,0(sp)
    800010e2:	0141                	addi	sp,sp,16
    800010e4:	8082                	ret
  pa = PTE2PA(*pte);
    800010e6:	00a7d513          	srli	a0,a5,0xa
    800010ea:	0532                	slli	a0,a0,0xc
  return pa;
    800010ec:	bfcd                	j	800010de <walkaddr+0x2a>
    return 0;
    800010ee:	4501                	li	a0,0
    800010f0:	b7fd                	j	800010de <walkaddr+0x2a>

00000000800010f2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f2:	715d                	addi	sp,sp,-80
    800010f4:	e486                	sd	ra,72(sp)
    800010f6:	e0a2                	sd	s0,64(sp)
    800010f8:	fc26                	sd	s1,56(sp)
    800010fa:	f84a                	sd	s2,48(sp)
    800010fc:	f44e                	sd	s3,40(sp)
    800010fe:	f052                	sd	s4,32(sp)
    80001100:	ec56                	sd	s5,24(sp)
    80001102:	e85a                	sd	s6,16(sp)
    80001104:	e45e                	sd	s7,8(sp)
    80001106:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001108:	03459793          	slli	a5,a1,0x34
    8000110c:	e7a9                	bnez	a5,80001156 <mappages+0x64>
    8000110e:	8aaa                	mv	s5,a0
    80001110:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001112:	03461793          	slli	a5,a2,0x34
    80001116:	e7b1                	bnez	a5,80001162 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001118:	ca39                	beqz	a2,8000116e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000111a:	79fd                	lui	s3,0xfffff
    8000111c:	964e                	add	a2,a2,s3
    8000111e:	00b609b3          	add	s3,a2,a1
  a = va;
    80001122:	892e                	mv	s2,a1
    80001124:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001128:	6b85                	lui	s7,0x1
    8000112a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000112e:	4605                	li	a2,1
    80001130:	85ca                	mv	a1,s2
    80001132:	8556                	mv	a0,s5
    80001134:	ee7ff0ef          	jal	ra,8000101a <walk>
    80001138:	c539                	beqz	a0,80001186 <mappages+0x94>
    if(*pte & PTE_V)
    8000113a:	611c                	ld	a5,0(a0)
    8000113c:	8b85                	andi	a5,a5,1
    8000113e:	ef95                	bnez	a5,8000117a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001140:	80b1                	srli	s1,s1,0xc
    80001142:	04aa                	slli	s1,s1,0xa
    80001144:	0164e4b3          	or	s1,s1,s6
    80001148:	0014e493          	ori	s1,s1,1
    8000114c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000114e:	05390863          	beq	s2,s3,8000119e <mappages+0xac>
    a += PGSIZE;
    80001152:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001154:	bfd9                	j	8000112a <mappages+0x38>
    panic("mappages: va not aligned");
    80001156:	00007517          	auipc	a0,0x7
    8000115a:	f8250513          	addi	a0,a0,-126 # 800080d8 <digits+0xa0>
    8000115e:	e2cff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size not aligned");
    80001162:	00007517          	auipc	a0,0x7
    80001166:	f9650513          	addi	a0,a0,-106 # 800080f8 <digits+0xc0>
    8000116a:	e20ff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size");
    8000116e:	00007517          	auipc	a0,0x7
    80001172:	faa50513          	addi	a0,a0,-86 # 80008118 <digits+0xe0>
    80001176:	e14ff0ef          	jal	ra,8000078a <panic>
      panic("mappages: remap");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	fae50513          	addi	a0,a0,-82 # 80008128 <digits+0xf0>
    80001182:	e08ff0ef          	jal	ra,8000078a <panic>
      return -1;
    80001186:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001188:	60a6                	ld	ra,72(sp)
    8000118a:	6406                	ld	s0,64(sp)
    8000118c:	74e2                	ld	s1,56(sp)
    8000118e:	7942                	ld	s2,48(sp)
    80001190:	79a2                	ld	s3,40(sp)
    80001192:	7a02                	ld	s4,32(sp)
    80001194:	6ae2                	ld	s5,24(sp)
    80001196:	6b42                	ld	s6,16(sp)
    80001198:	6ba2                	ld	s7,8(sp)
    8000119a:	6161                	addi	sp,sp,80
    8000119c:	8082                	ret
  return 0;
    8000119e:	4501                	li	a0,0
    800011a0:	b7e5                	j	80001188 <mappages+0x96>

00000000800011a2 <kvmmap>:
{
    800011a2:	1141                	addi	sp,sp,-16
    800011a4:	e406                	sd	ra,8(sp)
    800011a6:	e022                	sd	s0,0(sp)
    800011a8:	0800                	addi	s0,sp,16
    800011aa:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011ac:	86b2                	mv	a3,a2
    800011ae:	863e                	mv	a2,a5
    800011b0:	f43ff0ef          	jal	ra,800010f2 <mappages>
    800011b4:	e509                	bnez	a0,800011be <kvmmap+0x1c>
}
    800011b6:	60a2                	ld	ra,8(sp)
    800011b8:	6402                	ld	s0,0(sp)
    800011ba:	0141                	addi	sp,sp,16
    800011bc:	8082                	ret
    panic("kvmmap");
    800011be:	00007517          	auipc	a0,0x7
    800011c2:	f7a50513          	addi	a0,a0,-134 # 80008138 <digits+0x100>
    800011c6:	dc4ff0ef          	jal	ra,8000078a <panic>

00000000800011ca <kvmmake>:
{
    800011ca:	1101                	addi	sp,sp,-32
    800011cc:	ec06                	sd	ra,24(sp)
    800011ce:	e822                	sd	s0,16(sp)
    800011d0:	e426                	sd	s1,8(sp)
    800011d2:	e04a                	sd	s2,0(sp)
    800011d4:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d6:	9e5ff0ef          	jal	ra,80000bba <kalloc>
    800011da:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011dc:	6605                	lui	a2,0x1
    800011de:	4581                	li	a1,0
    800011e0:	bb3ff0ef          	jal	ra,80000d92 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011e4:	4719                	li	a4,6
    800011e6:	6685                	lui	a3,0x1
    800011e8:	10000637          	lui	a2,0x10000
    800011ec:	100005b7          	lui	a1,0x10000
    800011f0:	8526                	mv	a0,s1
    800011f2:	fb1ff0ef          	jal	ra,800011a2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	6685                	lui	a3,0x1
    800011fa:	10001637          	lui	a2,0x10001
    800011fe:	100015b7          	lui	a1,0x10001
    80001202:	8526                	mv	a0,s1
    80001204:	f9fff0ef          	jal	ra,800011a2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	040006b7          	lui	a3,0x4000
    8000120e:	0c000637          	lui	a2,0xc000
    80001212:	0c0005b7          	lui	a1,0xc000
    80001216:	8526                	mv	a0,s1
    80001218:	f8bff0ef          	jal	ra,800011a2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000121c:	00007917          	auipc	s2,0x7
    80001220:	de490913          	addi	s2,s2,-540 # 80008000 <etext>
    80001224:	4729                	li	a4,10
    80001226:	80007697          	auipc	a3,0x80007
    8000122a:	dda68693          	addi	a3,a3,-550 # 8000 <_entry-0x7fff8000>
    8000122e:	4605                	li	a2,1
    80001230:	067e                	slli	a2,a2,0x1f
    80001232:	85b2                	mv	a1,a2
    80001234:	8526                	mv	a0,s1
    80001236:	f6dff0ef          	jal	ra,800011a2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000123a:	4719                	li	a4,6
    8000123c:	46c5                	li	a3,17
    8000123e:	06ee                	slli	a3,a3,0x1b
    80001240:	412686b3          	sub	a3,a3,s2
    80001244:	864a                	mv	a2,s2
    80001246:	85ca                	mv	a1,s2
    80001248:	8526                	mv	a0,s1
    8000124a:	f59ff0ef          	jal	ra,800011a2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000124e:	4729                	li	a4,10
    80001250:	6685                	lui	a3,0x1
    80001252:	00006617          	auipc	a2,0x6
    80001256:	dae60613          	addi	a2,a2,-594 # 80007000 <_trampoline>
    8000125a:	040005b7          	lui	a1,0x4000
    8000125e:	15fd                	addi	a1,a1,-1
    80001260:	05b2                	slli	a1,a1,0xc
    80001262:	8526                	mv	a0,s1
    80001264:	f3fff0ef          	jal	ra,800011a2 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001268:	8526                	mv	a0,s1
    8000126a:	7f6000ef          	jal	ra,80001a60 <proc_mapstacks>
}
    8000126e:	8526                	mv	a0,s1
    80001270:	60e2                	ld	ra,24(sp)
    80001272:	6442                	ld	s0,16(sp)
    80001274:	64a2                	ld	s1,8(sp)
    80001276:	6902                	ld	s2,0(sp)
    80001278:	6105                	addi	sp,sp,32
    8000127a:	8082                	ret

000000008000127c <kvminit>:
{
    8000127c:	1141                	addi	sp,sp,-16
    8000127e:	e406                	sd	ra,8(sp)
    80001280:	e022                	sd	s0,0(sp)
    80001282:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001284:	f47ff0ef          	jal	ra,800011ca <kvmmake>
    80001288:	00007797          	auipc	a5,0x7
    8000128c:	62a7b823          	sd	a0,1584(a5) # 800088b8 <kernel_pagetable>
}
    80001290:	60a2                	ld	ra,8(sp)
    80001292:	6402                	ld	s0,0(sp)
    80001294:	0141                	addi	sp,sp,16
    80001296:	8082                	ret

0000000080001298 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001298:	1101                	addi	sp,sp,-32
    8000129a:	ec06                	sd	ra,24(sp)
    8000129c:	e822                	sd	s0,16(sp)
    8000129e:	e426                	sd	s1,8(sp)
    800012a0:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012a2:	919ff0ef          	jal	ra,80000bba <kalloc>
    800012a6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012a8:	c509                	beqz	a0,800012b2 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012aa:	6605                	lui	a2,0x1
    800012ac:	4581                	li	a1,0
    800012ae:	ae5ff0ef          	jal	ra,80000d92 <memset>
  return pagetable;
}
    800012b2:	8526                	mv	a0,s1
    800012b4:	60e2                	ld	ra,24(sp)
    800012b6:	6442                	ld	s0,16(sp)
    800012b8:	64a2                	ld	s1,8(sp)
    800012ba:	6105                	addi	sp,sp,32
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	7139                	addi	sp,sp,-64
    800012c0:	fc06                	sd	ra,56(sp)
    800012c2:	f822                	sd	s0,48(sp)
    800012c4:	f426                	sd	s1,40(sp)
    800012c6:	f04a                	sd	s2,32(sp)
    800012c8:	ec4e                	sd	s3,24(sp)
    800012ca:	e852                	sd	s4,16(sp)
    800012cc:	e456                	sd	s5,8(sp)
    800012ce:	e05a                	sd	s6,0(sp)
    800012d0:	0080                	addi	s0,sp,64
  
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012d2:	03459793          	slli	a5,a1,0x34
    800012d6:	e785                	bnez	a5,800012fe <uvmunmap+0x40>
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	slli	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    800012e4:	6b05                	lui	s6,0x1
    800012e6:	0335e763          	bltu	a1,s3,80001314 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012ea:	70e2                	ld	ra,56(sp)
    800012ec:	7442                	ld	s0,48(sp)
    800012ee:	74a2                	ld	s1,40(sp)
    800012f0:	7902                	ld	s2,32(sp)
    800012f2:	69e2                	ld	s3,24(sp)
    800012f4:	6a42                	ld	s4,16(sp)
    800012f6:	6aa2                	ld	s5,8(sp)
    800012f8:	6b02                	ld	s6,0(sp)
    800012fa:	6121                	addi	sp,sp,64
    800012fc:	8082                	ret
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	e4250513          	addi	a0,a0,-446 # 80008140 <digits+0x108>
    80001306:	c84ff0ef          	jal	ra,8000078a <panic>
    *pte = 0;
    8000130a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130e:	995a                	add	s2,s2,s6
    80001310:	fd397de3          	bgeu	s2,s3,800012ea <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001314:	4601                	li	a2,0
    80001316:	85ca                	mv	a1,s2
    80001318:	8552                	mv	a0,s4
    8000131a:	d01ff0ef          	jal	ra,8000101a <walk>
    8000131e:	84aa                	mv	s1,a0
    80001320:	d57d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001322:	611c                	ld	a5,0(a0)
    80001324:	0017f713          	andi	a4,a5,1
    80001328:	d37d                	beqz	a4,8000130e <uvmunmap+0x50>
    if(do_free){
    8000132a:	fe0a80e3          	beqz	s5,8000130a <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    8000132e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001330:	00c79513          	slli	a0,a5,0xc
    80001334:	f4aff0ef          	jal	ra,80000a7e <kfree>
    80001338:	bfc9                	j	8000130a <uvmunmap+0x4c>

000000008000133a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001344:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001346:	00b67d63          	bgeu	a2,a1,80001360 <uvmdealloc+0x26>
    8000134a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000134c:	6785                	lui	a5,0x1
    8000134e:	17fd                	addi	a5,a5,-1
    80001350:	00f60733          	add	a4,a2,a5
    80001354:	767d                	lui	a2,0xfffff
    80001356:	8f71                	and	a4,a4,a2
    80001358:	97ae                	add	a5,a5,a1
    8000135a:	8ff1                	and	a5,a5,a2
    8000135c:	00f76863          	bltu	a4,a5,8000136c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001360:	8526                	mv	a0,s1
    80001362:	60e2                	ld	ra,24(sp)
    80001364:	6442                	ld	s0,16(sp)
    80001366:	64a2                	ld	s1,8(sp)
    80001368:	6105                	addi	sp,sp,32
    8000136a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000136c:	8f99                	sub	a5,a5,a4
    8000136e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001370:	4685                	li	a3,1
    80001372:	0007861b          	sext.w	a2,a5
    80001376:	85ba                	mv	a1,a4
    80001378:	f47ff0ef          	jal	ra,800012be <uvmunmap>
    8000137c:	b7d5                	j	80001360 <uvmdealloc+0x26>

000000008000137e <uvmalloc>:
  if(newsz < oldsz)
    8000137e:	08b66963          	bltu	a2,a1,80001410 <uvmalloc+0x92>
{
    80001382:	7139                	addi	sp,sp,-64
    80001384:	fc06                	sd	ra,56(sp)
    80001386:	f822                	sd	s0,48(sp)
    80001388:	f426                	sd	s1,40(sp)
    8000138a:	f04a                	sd	s2,32(sp)
    8000138c:	ec4e                	sd	s3,24(sp)
    8000138e:	e852                	sd	s4,16(sp)
    80001390:	e456                	sd	s5,8(sp)
    80001392:	e05a                	sd	s6,0(sp)
    80001394:	0080                	addi	s0,sp,64
    80001396:	8aaa                	mv	s5,a0
    80001398:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000139a:	6985                	lui	s3,0x1
    8000139c:	19fd                	addi	s3,s3,-1
    8000139e:	95ce                	add	a1,a1,s3
    800013a0:	79fd                	lui	s3,0xfffff
    800013a2:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013a6:	06c9f763          	bgeu	s3,a2,80001414 <uvmalloc+0x96>
    800013aa:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013ac:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013b0:	80bff0ef          	jal	ra,80000bba <kalloc>
    800013b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800013b6:	c11d                	beqz	a0,800013dc <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    800013b8:	6605                	lui	a2,0x1
    800013ba:	4581                	li	a1,0
    800013bc:	9d7ff0ef          	jal	ra,80000d92 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013c0:	875a                	mv	a4,s6
    800013c2:	86a6                	mv	a3,s1
    800013c4:	6605                	lui	a2,0x1
    800013c6:	85ca                	mv	a1,s2
    800013c8:	8556                	mv	a0,s5
    800013ca:	d29ff0ef          	jal	ra,800010f2 <mappages>
    800013ce:	e51d                	bnez	a0,800013fc <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013d0:	6785                	lui	a5,0x1
    800013d2:	993e                	add	s2,s2,a5
    800013d4:	fd496ee3          	bltu	s2,s4,800013b0 <uvmalloc+0x32>
  return newsz;
    800013d8:	8552                	mv	a0,s4
    800013da:	a039                	j	800013e8 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800013dc:	864e                	mv	a2,s3
    800013de:	85ca                	mv	a1,s2
    800013e0:	8556                	mv	a0,s5
    800013e2:	f59ff0ef          	jal	ra,8000133a <uvmdealloc>
      return 0;
    800013e6:	4501                	li	a0,0
}
    800013e8:	70e2                	ld	ra,56(sp)
    800013ea:	7442                	ld	s0,48(sp)
    800013ec:	74a2                	ld	s1,40(sp)
    800013ee:	7902                	ld	s2,32(sp)
    800013f0:	69e2                	ld	s3,24(sp)
    800013f2:	6a42                	ld	s4,16(sp)
    800013f4:	6aa2                	ld	s5,8(sp)
    800013f6:	6b02                	ld	s6,0(sp)
    800013f8:	6121                	addi	sp,sp,64
    800013fa:	8082                	ret
      kfree(mem);
    800013fc:	8526                	mv	a0,s1
    800013fe:	e80ff0ef          	jal	ra,80000a7e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001402:	864e                	mv	a2,s3
    80001404:	85ca                	mv	a1,s2
    80001406:	8556                	mv	a0,s5
    80001408:	f33ff0ef          	jal	ra,8000133a <uvmdealloc>
      return 0;
    8000140c:	4501                	li	a0,0
    8000140e:	bfe9                	j	800013e8 <uvmalloc+0x6a>
    return oldsz;
    80001410:	852e                	mv	a0,a1
}
    80001412:	8082                	ret
  return newsz;
    80001414:	8532                	mv	a0,a2
    80001416:	bfc9                	j	800013e8 <uvmalloc+0x6a>

0000000080001418 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001418:	7179                	addi	sp,sp,-48
    8000141a:	f406                	sd	ra,40(sp)
    8000141c:	f022                	sd	s0,32(sp)
    8000141e:	ec26                	sd	s1,24(sp)
    80001420:	e84a                	sd	s2,16(sp)
    80001422:	e44e                	sd	s3,8(sp)
    80001424:	e052                	sd	s4,0(sp)
    80001426:	1800                	addi	s0,sp,48
    80001428:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000142a:	84aa                	mv	s1,a0
    8000142c:	6905                	lui	s2,0x1
    8000142e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001430:	4985                	li	s3,1
    80001432:	a811                	j	80001446 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001434:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001436:	0532                	slli	a0,a0,0xc
    80001438:	fe1ff0ef          	jal	ra,80001418 <freewalk>
      pagetable[i] = 0;
    8000143c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001440:	04a1                	addi	s1,s1,8
    80001442:	01248f63          	beq	s1,s2,80001460 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001446:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001448:	00f57793          	andi	a5,a0,15
    8000144c:	ff3784e3          	beq	a5,s3,80001434 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001450:	8905                	andi	a0,a0,1
    80001452:	d57d                	beqz	a0,80001440 <freewalk+0x28>
      panic("freewalk: leaf");
    80001454:	00007517          	auipc	a0,0x7
    80001458:	d0450513          	addi	a0,a0,-764 # 80008158 <digits+0x120>
    8000145c:	b2eff0ef          	jal	ra,8000078a <panic>
    }
  }
  kfree((void*)pagetable);
    80001460:	8552                	mv	a0,s4
    80001462:	e1cff0ef          	jal	ra,80000a7e <kfree>
}
    80001466:	70a2                	ld	ra,40(sp)
    80001468:	7402                	ld	s0,32(sp)
    8000146a:	64e2                	ld	s1,24(sp)
    8000146c:	6942                	ld	s2,16(sp)
    8000146e:	69a2                	ld	s3,8(sp)
    80001470:	6a02                	ld	s4,0(sp)
    80001472:	6145                	addi	sp,sp,48
    80001474:	8082                	ret

0000000080001476 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001476:	1101                	addi	sp,sp,-32
    80001478:	ec06                	sd	ra,24(sp)
    8000147a:	e822                	sd	s0,16(sp)
    8000147c:	e426                	sd	s1,8(sp)
    8000147e:	1000                	addi	s0,sp,32
    80001480:	84aa                	mv	s1,a0
  if(sz > 0)
    80001482:	e989                	bnez	a1,80001494 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001484:	8526                	mv	a0,s1
    80001486:	f93ff0ef          	jal	ra,80001418 <freewalk>
}
    8000148a:	60e2                	ld	ra,24(sp)
    8000148c:	6442                	ld	s0,16(sp)
    8000148e:	64a2                	ld	s1,8(sp)
    80001490:	6105                	addi	sp,sp,32
    80001492:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001494:	6605                	lui	a2,0x1
    80001496:	167d                	addi	a2,a2,-1
    80001498:	962e                	add	a2,a2,a1
    8000149a:	4685                	li	a3,1
    8000149c:	8231                	srli	a2,a2,0xc
    8000149e:	4581                	li	a1,0
    800014a0:	e1fff0ef          	jal	ra,800012be <uvmunmap>
    800014a4:	b7c5                	j	80001484 <uvmfree+0xe>

00000000800014a6 <uvmcopy>:
#else
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800014a6:	ca69                	beqz	a2,80001578 <uvmcopy+0xd2>
{
    800014a8:	715d                	addi	sp,sp,-80
    800014aa:	e486                	sd	ra,72(sp)
    800014ac:	e0a2                	sd	s0,64(sp)
    800014ae:	fc26                	sd	s1,56(sp)
    800014b0:	f84a                	sd	s2,48(sp)
    800014b2:	f44e                	sd	s3,40(sp)
    800014b4:	f052                	sd	s4,32(sp)
    800014b6:	ec56                	sd	s5,24(sp)
    800014b8:	e85a                	sd	s6,16(sp)
    800014ba:	e45e                	sd	s7,8(sp)
    800014bc:	e062                	sd	s8,0(sp)
    800014be:	0880                	addi	s0,sp,80
    800014c0:	8a2a                	mv	s4,a0
    800014c2:	8b2e                	mv	s6,a1
    800014c4:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014c6:	4901                	li	s2,0
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
      // 映射失败，回滚引用计数
      kref_dec((void*)pa);
      goto err;
    }
    { extern uint64 fork_share_pages; fork_share_pages++; }
    800014c8:	00007a97          	auipc	s5,0x7
    800014cc:	410a8a93          	addi	s5,s5,1040 # 800088d8 <fork_share_pages>
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014d0:	7bfd                	lui	s7,0xfffff
    800014d2:	002bdb93          	srli	s7,s7,0x2
    800014d6:	a815                	j	8000150a <uvmcopy+0x64>
    pa = PTE2PA(*pte);
    800014d8:	82a9                	srli	a3,a3,0xa
    800014da:	00c69493          	slli	s1,a3,0xc
    kref_inc((void*)pa);
    800014de:	8526                	mv	a0,s1
    800014e0:	d16ff0ef          	jal	ra,800009f6 <kref_inc>
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014e4:	8762                	mv	a4,s8
    800014e6:	86a6                	mv	a3,s1
    800014e8:	6605                	lui	a2,0x1
    800014ea:	85ca                	mv	a1,s2
    800014ec:	855a                	mv	a0,s6
    800014ee:	c05ff0ef          	jal	ra,800010f2 <mappages>
    800014f2:	e931                	bnez	a0,80001546 <uvmcopy+0xa0>
    { extern uint64 fork_share_pages; fork_share_pages++; }
    800014f4:	000ab783          	ld	a5,0(s5)
    800014f8:	0785                	addi	a5,a5,1
    800014fa:	00fab023          	sd	a5,0(s5)
    800014fe:	12000073          	sfence.vma
  for(i = 0; i < sz; i += PGSIZE){
    80001502:	6785                	lui	a5,0x1
    80001504:	993e                	add	s2,s2,a5
    80001506:	05397c63          	bgeu	s2,s3,8000155e <uvmcopy+0xb8>
    pte = walk(old, i, 0);
    8000150a:	4601                	li	a2,0
    8000150c:	85ca                	mv	a1,s2
    8000150e:	8552                	mv	a0,s4
    80001510:	b0bff0ef          	jal	ra,8000101a <walk>
    if(pte == 0)
    80001514:	d57d                	beqz	a0,80001502 <uvmcopy+0x5c>
    if((*pte & PTE_V) == 0)
    80001516:	6114                	ld	a3,0(a0)
    80001518:	0016f793          	andi	a5,a3,1
    8000151c:	d3fd                	beqz	a5,80001502 <uvmcopy+0x5c>
    flags = PTE_FLAGS(*pte);
    8000151e:	0006879b          	sext.w	a5,a3
    if((flags & PTE_U) == 0)
    80001522:	0106f713          	andi	a4,a3,16
    80001526:	df71                	beqz	a4,80001502 <uvmcopy+0x5c>
    flags = PTE_FLAGS(*pte);
    80001528:	3ff7fc13          	andi	s8,a5,1023
    if(flags & PTE_W){
    8000152c:	8b91                	andi	a5,a5,4
    8000152e:	d7cd                	beqz	a5,800014d8 <uvmcopy+0x32>
      flags = (flags & ~PTE_W) | PTE_COW;
    80001530:	efbc7793          	andi	a5,s8,-261
    80001534:	1007ec13          	ori	s8,a5,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001538:	0176f733          	and	a4,a3,s7
    8000153c:	8fd9                	or	a5,a5,a4
    8000153e:	1017e793          	ori	a5,a5,257
    80001542:	e11c                	sd	a5,0(a0)
    80001544:	bf51                	j	800014d8 <uvmcopy+0x32>
      kref_dec((void*)pa);
    80001546:	8526                	mv	a0,s1
    80001548:	cf2ff0ef          	jal	ra,80000a3a <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调用 kfree()，kfree 会自动减少引用计数
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000154c:	4685                	li	a3,1
    8000154e:	00c95613          	srli	a2,s2,0xc
    80001552:	4581                	li	a1,0
    80001554:	855a                	mv	a0,s6
    80001556:	d69ff0ef          	jal	ra,800012be <uvmunmap>
  return -1;
    8000155a:	557d                	li	a0,-1
    8000155c:	a011                	j	80001560 <uvmcopy+0xba>
  return 0;
    8000155e:	4501                	li	a0,0
#endif
}
    80001560:	60a6                	ld	ra,72(sp)
    80001562:	6406                	ld	s0,64(sp)
    80001564:	74e2                	ld	s1,56(sp)
    80001566:	7942                	ld	s2,48(sp)
    80001568:	79a2                	ld	s3,40(sp)
    8000156a:	7a02                	ld	s4,32(sp)
    8000156c:	6ae2                	ld	s5,24(sp)
    8000156e:	6b42                	ld	s6,16(sp)
    80001570:	6ba2                	ld	s7,8(sp)
    80001572:	6c02                	ld	s8,0(sp)
    80001574:	6161                	addi	sp,sp,80
    80001576:	8082                	ret
  return 0;
    80001578:	4501                	li	a0,0
}
    8000157a:	8082                	ret

000000008000157c <cowbreak>:
 *   - 该函数会在页表更新后刷新 TLB，确保更改立即生效
 *   - 当需要复制页面时，会更新 COW 统计信息
 */
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    8000157c:	7179                	addi	sp,sp,-48
    8000157e:	f406                	sd	ra,40(sp)
    80001580:	f022                	sd	s0,32(sp)
    80001582:	ec26                	sd	s1,24(sp)
    80001584:	e84a                	sd	s2,16(sp)
    80001586:	e44e                	sd	s3,8(sp)
    80001588:	e052                	sd	s4,0(sp)
    8000158a:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    8000158c:	4601                	li	a2,0
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8dfd                	and	a1,a1,a5
    80001592:	a89ff0ef          	jal	ra,8000101a <walk>
  if(pte == 0)
    80001596:	cd51                	beqz	a0,80001632 <cowbreak+0xb6>
    80001598:	89aa                	mv	s3,a0
    return -1;                 // 页表项不存在
  if((*pte & PTE_V) == 0)
    8000159a:	6104                	ld	s1,0(a0)
    return -1;                 // 虚拟地址未映射到物理页
  if((*pte & PTE_U) == 0)
    8000159c:	0114f713          	andi	a4,s1,17
    800015a0:	47c5                	li	a5,17
    800015a2:	08f71a63          	bne	a4,a5,80001636 <cowbreak+0xba>
    return -1;                 // 非用户页

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    800015a6:	1044f793          	andi	a5,s1,260
    800015aa:	10000713          	li	a4,256
    800015ae:	08e79663          	bne	a5,a4,8000163a <cowbreak+0xbe>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    800015b2:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    800015b6:	00a4da13          	srli	s4,s1,0xa
    800015ba:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    800015bc:	8552                	mv	a0,s4
    800015be:	bfeff0ef          	jal	ra,800009bc <kref_get>
    800015c2:	4785                	li	a5,1
    800015c4:	04f50663          	beq	a0,a5,80001610 <cowbreak+0x94>
    sfence_vma();              // 刷新 TLB
    return 0;
  }

  // 分配新物理页
  char *mem = kalloc();
    800015c8:	df2ff0ef          	jal	ra,80000bba <kalloc>
    800015cc:	84aa                	mv	s1,a0
  if(mem == 0)
    800015ce:	c925                	beqz	a0,8000163e <cowbreak+0xc2>
    return -1;                 // 内存分配失败

  // 复制旧页内容到新页
  memmove(mem, (void*)pa_old, PGSIZE);
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85d2                	mv	a1,s4
    800015d4:	81bff0ef          	jal	ra,80000dee <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    800015d8:	8552                	mv	a0,s4
    800015da:	c60ff0ef          	jal	ra,80000a3a <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW 标志
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015de:	80b1                	srli	s1,s1,0xc
    800015e0:	04aa                	slli	s1,s1,0xa
    800015e2:	00496913          	ori	s2,s2,4
    800015e6:	eff97913          	andi	s2,s2,-257
    800015ea:	0124e4b3          	or	s1,s1,s2
    800015ee:	0014e493          	ori	s1,s1,1
    800015f2:	0099b023          	sd	s1,0(s3) # fffffffffffff000 <end+0xffffffff7fdaae00>
    800015f6:	12000073          	sfence.vma

  sfence_vma();                // 刷新 TLB
  vmstats_inc_cow();           // 更新 COW 统计信息
    800015fa:	79e050ef          	jal	ra,80006d98 <vmstats_inc_cow>

  return 0;
    800015fe:	4501                	li	a0,0
}
    80001600:	70a2                	ld	ra,40(sp)
    80001602:	7402                	ld	s0,32(sp)
    80001604:	64e2                	ld	s1,24(sp)
    80001606:	6942                	ld	s2,16(sp)
    80001608:	69a2                	ld	s3,8(sp)
    8000160a:	6a02                	ld	s4,0(sp)
    8000160c:	6145                	addi	sp,sp,48
    8000160e:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    80001610:	00496913          	ori	s2,s2,4
    80001614:	eff97913          	andi	s2,s2,-257
    80001618:	77fd                	lui	a5,0xfffff
    8000161a:	8389                	srli	a5,a5,0x2
    8000161c:	8cfd                	and	s1,s1,a5
    8000161e:	00996933          	or	s2,s2,s1
    80001622:	00196913          	ori	s2,s2,1
    80001626:	0129b023          	sd	s2,0(s3)
    8000162a:	12000073          	sfence.vma
    return 0;
    8000162e:	4501                	li	a0,0
    80001630:	bfc1                	j	80001600 <cowbreak+0x84>
    return -1;                 // 页表项不存在
    80001632:	557d                	li	a0,-1
    80001634:	b7f1                	j	80001600 <cowbreak+0x84>
    return -1;                 // 非用户页
    80001636:	557d                	li	a0,-1
    80001638:	b7e1                	j	80001600 <cowbreak+0x84>
    return -1;
    8000163a:	557d                	li	a0,-1
    8000163c:	b7d1                	j	80001600 <cowbreak+0x84>
    return -1;                 // 内存分配失败
    8000163e:	557d                	li	a0,-1
    80001640:	b7c1                	j	80001600 <cowbreak+0x84>

0000000080001642 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001642:	1141                	addi	sp,sp,-16
    80001644:	e406                	sd	ra,8(sp)
    80001646:	e022                	sd	s0,0(sp)
    80001648:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000164a:	4601                	li	a2,0
    8000164c:	9cfff0ef          	jal	ra,8000101a <walk>
  if(pte == 0)
    80001650:	c901                	beqz	a0,80001660 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001652:	611c                	ld	a5,0(a0)
    80001654:	9bbd                	andi	a5,a5,-17
    80001656:	e11c                	sd	a5,0(a0)
}
    80001658:	60a2                	ld	ra,8(sp)
    8000165a:	6402                	ld	s0,0(sp)
    8000165c:	0141                	addi	sp,sp,16
    8000165e:	8082                	ret
    panic("uvmclear");
    80001660:	00007517          	auipc	a0,0x7
    80001664:	b0850513          	addi	a0,a0,-1272 # 80008168 <digits+0x130>
    80001668:	922ff0ef          	jal	ra,8000078a <panic>

000000008000166c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000166c:	c2d5                	beqz	a3,80001710 <copyinstr+0xa4>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	0880                	addi	s0,sp,80
    80001684:	8a2a                	mv	s4,a0
    80001686:	8b2e                	mv	s6,a1
    80001688:	8bb2                	mv	s7,a2
    8000168a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000168c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000168e:	6985                	lui	s3,0x1
    80001690:	a035                	j	800016bc <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001692:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdaae00>
    80001696:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001698:	0017b793          	seqz	a5,a5
    8000169c:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016a0:	60a6                	ld	ra,72(sp)
    800016a2:	6406                	ld	s0,64(sp)
    800016a4:	74e2                	ld	s1,56(sp)
    800016a6:	7942                	ld	s2,48(sp)
    800016a8:	79a2                	ld	s3,40(sp)
    800016aa:	7a02                	ld	s4,32(sp)
    800016ac:	6ae2                	ld	s5,24(sp)
    800016ae:	6b42                	ld	s6,16(sp)
    800016b0:	6ba2                	ld	s7,8(sp)
    800016b2:	6161                	addi	sp,sp,80
    800016b4:	8082                	ret
    srcva = va0 + PGSIZE;
    800016b6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800016ba:	c4b9                	beqz	s1,80001708 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    800016bc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	8552                	mv	a0,s4
    800016c4:	9f1ff0ef          	jal	ra,800010b4 <walkaddr>
    if(pa0 == 0)
    800016c8:	c131                	beqz	a0,8000170c <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    800016ca:	41790833          	sub	a6,s2,s7
    800016ce:	984e                	add	a6,a6,s3
    if(n > max)
    800016d0:	0104f363          	bgeu	s1,a6,800016d6 <copyinstr+0x6a>
    800016d4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016d6:	955e                	add	a0,a0,s7
    800016d8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016dc:	fc080de3          	beqz	a6,800016b6 <copyinstr+0x4a>
    800016e0:	985a                	add	a6,a6,s6
    800016e2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016e4:	41650633          	sub	a2,a0,s6
    800016e8:	14fd                	addi	s1,s1,-1
    800016ea:	9b26                	add	s6,s6,s1
    800016ec:	00f60733          	add	a4,a2,a5
    800016f0:	00074703          	lbu	a4,0(a4)
    800016f4:	df59                	beqz	a4,80001692 <copyinstr+0x26>
        *dst = *p;
    800016f6:	00e78023          	sb	a4,0(a5)
      --max;
    800016fa:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016fe:	0785                	addi	a5,a5,1
    while(n > 0){
    80001700:	ff0796e3          	bne	a5,a6,800016ec <copyinstr+0x80>
      dst++;
    80001704:	8b42                	mv	s6,a6
    80001706:	bf45                	j	800016b6 <copyinstr+0x4a>
    80001708:	4781                	li	a5,0
    8000170a:	b779                	j	80001698 <copyinstr+0x2c>
      return -1;
    8000170c:	557d                	li	a0,-1
    8000170e:	bf49                	j	800016a0 <copyinstr+0x34>
  int got_null = 0;
    80001710:	4781                	li	a5,0
  if(got_null){
    80001712:	0017b793          	seqz	a5,a5
    80001716:	40f00533          	neg	a0,a5
}
    8000171a:	8082                	ret

000000008000171c <ismapped>:
 *   - 仅检查映射存在性，不检查权限
 *   - 用于 vmfault 和其他内存管理函数中的辅助检查
 */
int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000171c:	1141                	addi	sp,sp,-16
    8000171e:	e406                	sd	ra,8(sp)
    80001720:	e022                	sd	s0,0(sp)
    80001722:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001724:	4601                	li	a2,0
    80001726:	8f5ff0ef          	jal	ra,8000101a <walk>
  if (pte == 0) {               // 页表项不存在
    8000172a:	c519                	beqz	a0,80001738 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    8000172c:	6108                	ld	a0,0(a0)
    return 0;
    8000172e:	8905                	andi	a0,a0,1
    return 1;                   // 页表项存在且有效
  }
  return 0;                     // 页表项存在但无效
}
    80001730:	60a2                	ld	ra,8(sp)
    80001732:	6402                	ld	s0,0(sp)
    80001734:	0141                	addi	sp,sp,16
    80001736:	8082                	ret
    return 0;
    80001738:	4501                	li	a0,0
    8000173a:	bfdd                	j	80001730 <ismapped+0x14>

000000008000173c <vmfault>:
{
    8000173c:	7179                	addi	sp,sp,-48
    8000173e:	f406                	sd	ra,40(sp)
    80001740:	f022                	sd	s0,32(sp)
    80001742:	ec26                	sd	s1,24(sp)
    80001744:	e84a                	sd	s2,16(sp)
    80001746:	e44e                	sd	s3,8(sp)
    80001748:	e052                	sd	s4,0(sp)
    8000174a:	1800                	addi	s0,sp,48
    8000174c:	89aa                	mv	s3,a0
    8000174e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001750:	46e000ef          	jal	ra,80001bbe <myproc>
  if (va >= p->sz)              // 检查虚拟地址是否在进程地址空间范围内
    80001754:	653c                	ld	a5,72(a0)
    80001756:	00f4ec63          	bltu	s1,a5,8000176e <vmfault+0x32>
    return 0;
    8000175a:	4981                	li	s3,0
}
    8000175c:	854e                	mv	a0,s3
    8000175e:	70a2                	ld	ra,40(sp)
    80001760:	7402                	ld	s0,32(sp)
    80001762:	64e2                	ld	s1,24(sp)
    80001764:	6942                	ld	s2,16(sp)
    80001766:	69a2                	ld	s3,8(sp)
    80001768:	6a02                	ld	s4,0(sp)
    8000176a:	6145                	addi	sp,sp,48
    8000176c:	8082                	ret
    8000176e:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
    80001770:	75fd                	lui	a1,0xfffff
    80001772:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) { // 检查是否已映射
    80001774:	85a6                	mv	a1,s1
    80001776:	854e                	mv	a0,s3
    80001778:	fa5ff0ef          	jal	ra,8000171c <ismapped>
    return 0;
    8000177c:	4981                	li	s3,0
  if(ismapped(pagetable, va)) { // 检查是否已映射
    8000177e:	fd79                	bnez	a0,8000175c <vmfault+0x20>
  mem = (uint64) kalloc();      // 分配新物理页
    80001780:	c3aff0ef          	jal	ra,80000bba <kalloc>
    80001784:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001786:	d979                	beqz	a0,8000175c <vmfault+0x20>
  mem = (uint64) kalloc();      // 分配新物理页
    80001788:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE); // 初始化为0
    8000178a:	6605                	lui	a2,0x1
    8000178c:	4581                	li	a1,0
    8000178e:	e04ff0ef          	jal	ra,80000d92 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001792:	4759                	li	a4,22
    80001794:	86d2                	mv	a3,s4
    80001796:	6605                	lui	a2,0x1
    80001798:	85a6                	mv	a1,s1
    8000179a:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    8000179e:	955ff0ef          	jal	ra,800010f2 <mappages>
    800017a2:	dd4d                	beqz	a0,8000175c <vmfault+0x20>
    kfree((void *)mem);         // 映射失败，释放物理页
    800017a4:	8552                	mv	a0,s4
    800017a6:	ad8ff0ef          	jal	ra,80000a7e <kfree>
    return 0;
    800017aa:	4981                	li	s3,0
    800017ac:	bf45                	j	8000175c <vmfault+0x20>

00000000800017ae <copyout>:
  while(len > 0){
    800017ae:	cef1                	beqz	a3,8000188a <copyout+0xdc>
{
    800017b0:	7159                	addi	sp,sp,-112
    800017b2:	f486                	sd	ra,104(sp)
    800017b4:	f0a2                	sd	s0,96(sp)
    800017b6:	eca6                	sd	s1,88(sp)
    800017b8:	e8ca                	sd	s2,80(sp)
    800017ba:	e4ce                	sd	s3,72(sp)
    800017bc:	e0d2                	sd	s4,64(sp)
    800017be:	fc56                	sd	s5,56(sp)
    800017c0:	f85a                	sd	s6,48(sp)
    800017c2:	f45e                	sd	s7,40(sp)
    800017c4:	f062                	sd	s8,32(sp)
    800017c6:	ec66                	sd	s9,24(sp)
    800017c8:	e86a                	sd	s10,16(sp)
    800017ca:	e46e                	sd	s11,8(sp)
    800017cc:	1880                	addi	s0,sp,112
    800017ce:	8aaa                	mv	s5,a0
    800017d0:	8b2e                	mv	s6,a1
    800017d2:	8bb2                	mv	s7,a2
    800017d4:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800017d6:	74fd                	lui	s1,0xfffff
    800017d8:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800017da:	57fd                	li	a5,-1
    800017dc:	83e9                	srli	a5,a5,0x1a
    800017de:	0a97e863          	bltu	a5,s1,8000188e <copyout+0xe0>
    800017e2:	6d05                	lui	s10,0x1
    copyout_bytes += n;
    800017e4:	00007c17          	auipc	s8,0x7
    800017e8:	104c0c13          	addi	s8,s8,260 # 800088e8 <copyout_bytes>
    if(va0 >= MAXVA)
    800017ec:	8cbe                	mv	s9,a5
    800017ee:	a091                	j	80001832 <copyout+0x84>
    if((*pte & PTE_W) == 0)
    800017f0:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    800017f4:	8b91                	andi	a5,a5,4
    800017f6:	c7c5                	beqz	a5,8000189e <copyout+0xf0>
    n = PGSIZE - (dstva - va0);
    800017f8:	01a48db3          	add	s11,s1,s10
    800017fc:	416d89b3          	sub	s3,s11,s6
    if(n > len)
    80001800:	013a7363          	bgeu	s4,s3,80001806 <copyout+0x58>
    80001804:	89d2                	mv	s3,s4
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001806:	409b0533          	sub	a0,s6,s1
    8000180a:	0009861b          	sext.w	a2,s3
    8000180e:	85de                	mv	a1,s7
    80001810:	954a                	add	a0,a0,s2
    80001812:	ddcff0ef          	jal	ra,80000dee <memmove>
    len -= n;
    80001816:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000181a:	9bce                	add	s7,s7,s3
    copyout_bytes += n;
    8000181c:	000c3783          	ld	a5,0(s8)
    80001820:	99be                	add	s3,s3,a5
    80001822:	013c3023          	sd	s3,0(s8)
  while(len > 0){
    80001826:	060a0063          	beqz	s4,80001886 <copyout+0xd8>
    if(va0 >= MAXVA)
    8000182a:	07bce463          	bltu	s9,s11,80001892 <copyout+0xe4>
    va0 = PGROUNDDOWN(dstva);
    8000182e:	84ee                	mv	s1,s11
    dstva = va0 + PGSIZE;
    80001830:	8b6e                	mv	s6,s11
    pa0 = walkaddr(pagetable, va0);
    80001832:	85a6                	mv	a1,s1
    80001834:	8556                	mv	a0,s5
    80001836:	87fff0ef          	jal	ra,800010b4 <walkaddr>
    8000183a:	892a                	mv	s2,a0
    if(pa0 == 0) {
    8000183c:	e901                	bnez	a0,8000184c <copyout+0x9e>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000183e:	4601                	li	a2,0
    80001840:	85a6                	mv	a1,s1
    80001842:	8556                	mv	a0,s5
    80001844:	ef9ff0ef          	jal	ra,8000173c <vmfault>
    80001848:	892a                	mv	s2,a0
    8000184a:	c531                	beqz	a0,80001896 <copyout+0xe8>
    pte = walk(pagetable, va0, 0);
    8000184c:	4601                	li	a2,0
    8000184e:	85a6                	mv	a1,s1
    80001850:	8556                	mv	a0,s5
    80001852:	fc8ff0ef          	jal	ra,8000101a <walk>
    80001856:	89aa                	mv	s3,a0
    if(pte && (*pte & PTE_COW)){
    80001858:	dd41                	beqz	a0,800017f0 <copyout+0x42>
    8000185a:	611c                	ld	a5,0(a0)
    8000185c:	1007f793          	andi	a5,a5,256
    80001860:	dbc1                	beqz	a5,800017f0 <copyout+0x42>
      if(cowbreak(pagetable, va0) < 0)
    80001862:	85a6                	mv	a1,s1
    80001864:	8556                	mv	a0,s5
    80001866:	d17ff0ef          	jal	ra,8000157c <cowbreak>
    8000186a:	02054863          	bltz	a0,8000189a <copyout+0xec>
      pte = walk(pagetable, va0, 0);
    8000186e:	4601                	li	a2,0
    80001870:	85a6                	mv	a1,s1
    80001872:	8556                	mv	a0,s5
    80001874:	fa6ff0ef          	jal	ra,8000101a <walk>
    80001878:	89aa                	mv	s3,a0
      pa0 = walkaddr(pagetable, va0);
    8000187a:	85a6                	mv	a1,s1
    8000187c:	8556                	mv	a0,s5
    8000187e:	837ff0ef          	jal	ra,800010b4 <walkaddr>
    80001882:	892a                	mv	s2,a0
    80001884:	b7b5                	j	800017f0 <copyout+0x42>
  return 0;
    80001886:	4501                	li	a0,0
    80001888:	a821                	j	800018a0 <copyout+0xf2>
    8000188a:	4501                	li	a0,0
}
    8000188c:	8082                	ret
      return -1;
    8000188e:	557d                	li	a0,-1
    80001890:	a801                	j	800018a0 <copyout+0xf2>
    80001892:	557d                	li	a0,-1
    80001894:	a031                	j	800018a0 <copyout+0xf2>
        return -1;
    80001896:	557d                	li	a0,-1
    80001898:	a021                	j	800018a0 <copyout+0xf2>
        return -1;
    8000189a:	557d                	li	a0,-1
    8000189c:	a011                	j	800018a0 <copyout+0xf2>
      return -1;
    8000189e:	557d                	li	a0,-1
}
    800018a0:	70a6                	ld	ra,104(sp)
    800018a2:	7406                	ld	s0,96(sp)
    800018a4:	64e6                	ld	s1,88(sp)
    800018a6:	6946                	ld	s2,80(sp)
    800018a8:	69a6                	ld	s3,72(sp)
    800018aa:	6a06                	ld	s4,64(sp)
    800018ac:	7ae2                	ld	s5,56(sp)
    800018ae:	7b42                	ld	s6,48(sp)
    800018b0:	7ba2                	ld	s7,40(sp)
    800018b2:	7c02                	ld	s8,32(sp)
    800018b4:	6ce2                	ld	s9,24(sp)
    800018b6:	6d42                	ld	s10,16(sp)
    800018b8:	6da2                	ld	s11,8(sp)
    800018ba:	6165                	addi	sp,sp,112
    800018bc:	8082                	ret

00000000800018be <copyin>:
  while(len > 0){
    800018be:	c2c5                	beqz	a3,8000195e <copyin+0xa0>
{
    800018c0:	711d                	addi	sp,sp,-96
    800018c2:	ec86                	sd	ra,88(sp)
    800018c4:	e8a2                	sd	s0,80(sp)
    800018c6:	e4a6                	sd	s1,72(sp)
    800018c8:	e0ca                	sd	s2,64(sp)
    800018ca:	fc4e                	sd	s3,56(sp)
    800018cc:	f852                	sd	s4,48(sp)
    800018ce:	f456                	sd	s5,40(sp)
    800018d0:	f05a                	sd	s6,32(sp)
    800018d2:	ec5e                	sd	s7,24(sp)
    800018d4:	e862                	sd	s8,16(sp)
    800018d6:	e466                	sd	s9,8(sp)
    800018d8:	1080                	addi	s0,sp,96
    800018da:	8c2a                	mv	s8,a0
    800018dc:	8aae                	mv	s5,a1
    800018de:	8932                	mv	s2,a2
    800018e0:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800018e2:	7cfd                	lui	s9,0xfffff
    n = PGSIZE - (srcva - va0);
    800018e4:	6b85                	lui	s7,0x1
    copyin_bytes += n; 
    800018e6:	00007b17          	auipc	s6,0x7
    800018ea:	00ab0b13          	addi	s6,s6,10 # 800088f0 <copyin_bytes>
    800018ee:	a81d                	j	80001924 <copyin+0x66>
    n = PGSIZE - (srcva - va0);
    800018f0:	412984b3          	sub	s1,s3,s2
    800018f4:	94de                	add	s1,s1,s7
    if(n > len)
    800018f6:	009a7363          	bgeu	s4,s1,800018fc <copyin+0x3e>
    800018fa:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018fc:	413905b3          	sub	a1,s2,s3
    80001900:	0004861b          	sext.w	a2,s1
    80001904:	95aa                	add	a1,a1,a0
    80001906:	8556                	mv	a0,s5
    80001908:	ce6ff0ef          	jal	ra,80000dee <memmove>
    len -= n;
    8000190c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001910:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001912:	01798933          	add	s2,s3,s7
    copyin_bytes += n; 
    80001916:	000b3783          	ld	a5,0(s6)
    8000191a:	94be                	add	s1,s1,a5
    8000191c:	009b3023          	sd	s1,0(s6)
  while(len > 0){
    80001920:	020a0163          	beqz	s4,80001942 <copyin+0x84>
    va0 = PGROUNDDOWN(srcva);
    80001924:	019979b3          	and	s3,s2,s9
    pa0 = walkaddr(pagetable, va0);
    80001928:	85ce                	mv	a1,s3
    8000192a:	8562                	mv	a0,s8
    8000192c:	f88ff0ef          	jal	ra,800010b4 <walkaddr>
    if(pa0 == 0) {
    80001930:	f161                	bnez	a0,800018f0 <copyin+0x32>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001932:	4601                	li	a2,0
    80001934:	85ce                	mv	a1,s3
    80001936:	8562                	mv	a0,s8
    80001938:	e05ff0ef          	jal	ra,8000173c <vmfault>
    8000193c:	f955                	bnez	a0,800018f0 <copyin+0x32>
        return -1;
    8000193e:	557d                	li	a0,-1
    80001940:	a011                	j	80001944 <copyin+0x86>
  return 0;
    80001942:	4501                	li	a0,0
}
    80001944:	60e6                	ld	ra,88(sp)
    80001946:	6446                	ld	s0,80(sp)
    80001948:	64a6                	ld	s1,72(sp)
    8000194a:	6906                	ld	s2,64(sp)
    8000194c:	79e2                	ld	s3,56(sp)
    8000194e:	7a42                	ld	s4,48(sp)
    80001950:	7aa2                	ld	s5,40(sp)
    80001952:	7b02                	ld	s6,32(sp)
    80001954:	6be2                	ld	s7,24(sp)
    80001956:	6c42                	ld	s8,16(sp)
    80001958:	6ca2                	ld	s9,8(sp)
    8000195a:	6125                	addi	sp,sp,96
    8000195c:	8082                	ret
  return 0;
    8000195e:	4501                	li	a0,0
}
    80001960:	8082                	ret

0000000080001962 <vmafault>:
 *   - 支持匿名映射和共享内存映射两种类型
 *   - 失败时会自动回滚已分配的资源（如物理页）
 */
uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    80001962:	7139                	addi	sp,sp,-64
    80001964:	fc06                	sd	ra,56(sp)
    80001966:	f822                	sd	s0,48(sp)
    80001968:	f426                	sd	s1,40(sp)
    8000196a:	f04a                	sd	s2,32(sp)
    8000196c:	ec4e                	sd	s3,24(sp)
    8000196e:	e852                	sd	s4,16(sp)
    80001970:	e456                	sd	s5,8(sp)
    80001972:	0080                	addi	s0,sp,64
    80001974:	8a2a                	mv	s4,a0
    80001976:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
    80001978:	77fd                	lui	a5,0xfffff
    8000197a:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va); // 查找虚拟地址所属的 VMA
    8000197e:	85ce                	mv	a1,s3
    80001980:	752010ef          	jal	ra,800030d2 <vma_find>
  if(v == 0) return 0;          // 不在任何 VMA 范围内
    80001984:	c961                	beqz	a0,80001a54 <vmafault+0xf2>
    80001986:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001988:	00090663          	beqz	s2,80001994 <vmafault+0x32>
    8000198c:	4d1c                	lw	a5,24(a0)
    8000198e:	8b89                	andi	a5,a5,2
    return 0;
    80001990:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001992:	c789                	beqz	a5,8000199c <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    80001994:	4c9c                	lw	a5,24(s1)
    80001996:	8b85                	andi	a5,a5,1
    return 0;
    80001998:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    8000199a:	eb99                	bnez	a5,800019b0 <vmafault+0x4e>
    else kfree((void*)pa);            // 释放普通物理页
    return 0;
  }
  vmstats_inc_lazy();            // 更新惰性分配统计信息
  return (uint64)pa;             // 返回物理页地址
}
    8000199c:	854a                	mv	a0,s2
    8000199e:	70e2                	ld	ra,56(sp)
    800019a0:	7442                	ld	s0,48(sp)
    800019a2:	74a2                	ld	s1,40(sp)
    800019a4:	7902                	ld	s2,32(sp)
    800019a6:	69e2                	ld	s3,24(sp)
    800019a8:	6a42                	ld	s4,16(sp)
    800019aa:	6aa2                	ld	s5,8(sp)
    800019ac:	6121                	addi	sp,sp,64
    800019ae:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    800019b0:	4601                	li	a2,0
    800019b2:	85ce                	mv	a1,s3
    800019b4:	050a3503          	ld	a0,80(s4) # 2050 <_entry-0x7fffdfb0>
    800019b8:	e62ff0ef          	jal	ra,8000101a <walk>
  if(pte && (*pte & PTE_V)){     // 如果已经映射
    800019bc:	c115                	beqz	a0,800019e0 <vmafault+0x7e>
    800019be:	611c                	ld	a5,0(a0)
    800019c0:	0017f913          	andi	s2,a5,1
    800019c4:	00090e63          	beqz	s2,800019e0 <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    800019c8:	4c98                	lw	a4,24(s1)
    800019ca:	8b09                	andi	a4,a4,2
    800019cc:	c751                	beqz	a4,80001a58 <vmafault+0xf6>
    800019ce:	0047f713          	andi	a4,a5,4
    800019d2:	e749                	bnez	a4,80001a5c <vmafault+0xfa>
      *pte |= PTE_W;
    800019d4:	0047e793          	ori	a5,a5,4
    800019d8:	e11c                	sd	a5,0(a0)
    800019da:	12000073          	sfence.vma
      return 1;                  // 返回成功标志
    800019de:	bf7d                	j	8000199c <vmafault+0x3a>
  if(v->is_shm){                 // 共享内存 VMA
    800019e0:	509c                	lw	a5,32(s1)
    800019e2:	cf91                	beqz	a5,800019fe <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE; // 计算页在 VMA 中的索引
    800019e4:	648c                	ld	a1,8(s1)
    800019e6:	40b985b3          	sub	a1,s3,a1
    800019ea:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx); // 从共享内存对象获取物理页
    800019ec:	2581                	sext.w	a1,a1
    800019ee:	50c8                	lw	a0,36(s1)
    800019f0:	643040ef          	jal	ra,80006832 <shm_getpa>
    800019f4:	892a                	mv	s2,a0
    if(pa == 0) return 0;        // 获取失败
    800019f6:	d15d                	beqz	a0,8000199c <vmafault+0x3a>
    kref_inc((void*)pa);         // 增加共享页的引用计数
    800019f8:	ffffe0ef          	jal	ra,800009f6 <kref_inc>
    800019fc:	a819                	j	80001a12 <vmafault+0xb0>
    char *mem = kalloc();        // 分配新的物理页
    800019fe:	9bcff0ef          	jal	ra,80000bba <kalloc>
    80001a02:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;      // 分配失败
    80001a04:	4901                	li	s2,0
    80001a06:	d959                	beqz	a0,8000199c <vmafault+0x3a>
    memset(mem, 0, PGSIZE);     // 初始化为0
    80001a08:	6605                	lui	a2,0x1
    80001a0a:	4581                	li	a1,0
    80001a0c:	b86ff0ef          	jal	ra,80000d92 <memset>
    pa = (uint64)mem;
    80001a10:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
    80001a12:	4c9c                	lw	a5,24(s1)
    80001a14:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;              // 用户页标志
    80001a18:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
    80001a1a:	c291                	beqz	a3,80001a1e <vmafault+0xbc>
    80001a1c:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W; // 写权限
    80001a1e:	8b89                	andi	a5,a5,2
    80001a20:	c399                	beqz	a5,80001a26 <vmafault+0xc4>
    80001a22:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    80001a26:	86ca                	mv	a3,s2
    80001a28:	6605                	lui	a2,0x1
    80001a2a:	85ce                	mv	a1,s3
    80001a2c:	050a3503          	ld	a0,80(s4)
    80001a30:	ec2ff0ef          	jal	ra,800010f2 <mappages>
    80001a34:	cd09                	beqz	a0,80001a4e <vmafault+0xec>
    if(v->is_shm) kref_dec((void*)pa); // 减少共享页引用计数
    80001a36:	509c                	lw	a5,32(s1)
    80001a38:	c791                	beqz	a5,80001a44 <vmafault+0xe2>
    80001a3a:	854a                	mv	a0,s2
    80001a3c:	ffffe0ef          	jal	ra,80000a3a <kref_dec>
    return 0;
    80001a40:	4901                	li	s2,0
    80001a42:	bfa9                	j	8000199c <vmafault+0x3a>
    else kfree((void*)pa);            // 释放普通物理页
    80001a44:	854a                	mv	a0,s2
    80001a46:	838ff0ef          	jal	ra,80000a7e <kfree>
    return 0;
    80001a4a:	4901                	li	s2,0
    80001a4c:	bf81                	j	8000199c <vmafault+0x3a>
  vmstats_inc_lazy();            // 更新惰性分配统计信息
    80001a4e:	378050ef          	jal	ra,80006dc6 <vmstats_inc_lazy>
  return (uint64)pa;             // 返回物理页地址
    80001a52:	b7a9                	j	8000199c <vmafault+0x3a>
  if(v == 0) return 0;          // 不在任何 VMA 范围内
    80001a54:	4901                	li	s2,0
    80001a56:	b799                	j	8000199c <vmafault+0x3a>
    return 0;
    80001a58:	4901                	li	s2,0
    80001a5a:	b789                	j	8000199c <vmafault+0x3a>
    80001a5c:	4901                	li	s2,0
    80001a5e:	bf3d                	j	8000199c <vmafault+0x3a>

0000000080001a60 <proc_mapstacks>:
 * 参数：
 *   kpgtbl - 内核页表
 */
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a60:	7139                	addi	sp,sp,-64
    80001a62:	fc06                	sd	ra,56(sp)
    80001a64:	f822                	sd	s0,48(sp)
    80001a66:	f426                	sd	s1,40(sp)
    80001a68:	f04a                	sd	s2,32(sp)
    80001a6a:	ec4e                	sd	s3,24(sp)
    80001a6c:	e852                	sd	s4,16(sp)
    80001a6e:	e456                	sd	s5,8(sp)
    80001a70:	e05a                	sd	s6,0(sp)
    80001a72:	0080                	addi	s0,sp,64
    80001a74:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a76:	0022f497          	auipc	s1,0x22f
    80001a7a:	3ca48493          	addi	s1,s1,970 # 80230e40 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a7e:	8b26                	mv	s6,s1
    80001a80:	00006a97          	auipc	s5,0x6
    80001a84:	580a8a93          	addi	s5,s5,1408 # 80008000 <etext>
    80001a88:	04000937          	lui	s2,0x4000
    80001a8c:	197d                	addi	s2,s2,-1
    80001a8e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a90:	0023fa17          	auipc	s4,0x23f
    80001a94:	db0a0a13          	addi	s4,s4,-592 # 80240840 <tickslock>
    char *pa = kalloc();
    80001a98:	922ff0ef          	jal	ra,80000bba <kalloc>
    80001a9c:	862a                	mv	a2,a0
    if(pa == 0)
    80001a9e:	c121                	beqz	a0,80001ade <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001aa0:	416485b3          	sub	a1,s1,s6
    80001aa4:	858d                	srai	a1,a1,0x3
    80001aa6:	000ab783          	ld	a5,0(s5)
    80001aaa:	02f585b3          	mul	a1,a1,a5
    80001aae:	2585                	addiw	a1,a1,1
    80001ab0:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ab4:	4719                	li	a4,6
    80001ab6:	6685                	lui	a3,0x1
    80001ab8:	40b905b3          	sub	a1,s2,a1
    80001abc:	854e                	mv	a0,s3
    80001abe:	ee4ff0ef          	jal	ra,800011a2 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac2:	3e848493          	addi	s1,s1,1000
    80001ac6:	fd4499e3          	bne	s1,s4,80001a98 <proc_mapstacks+0x38>
  }
}
    80001aca:	70e2                	ld	ra,56(sp)
    80001acc:	7442                	ld	s0,48(sp)
    80001ace:	74a2                	ld	s1,40(sp)
    80001ad0:	7902                	ld	s2,32(sp)
    80001ad2:	69e2                	ld	s3,24(sp)
    80001ad4:	6a42                	ld	s4,16(sp)
    80001ad6:	6aa2                	ld	s5,8(sp)
    80001ad8:	6b02                	ld	s6,0(sp)
    80001ada:	6121                	addi	sp,sp,64
    80001adc:	8082                	ret
      panic("kalloc");
    80001ade:	00006517          	auipc	a0,0x6
    80001ae2:	69a50513          	addi	a0,a0,1690 # 80008178 <digits+0x140>
    80001ae6:	ca5fe0ef          	jal	ra,8000078a <panic>

0000000080001aea <procinit>:
 * 2. 为每个进程分配锁并初始化状态为UNUSED
 * 3. 设置每个进程的内核栈地址
 */
void
procinit(void)
{
    80001aea:	7139                	addi	sp,sp,-64
    80001aec:	fc06                	sd	ra,56(sp)
    80001aee:	f822                	sd	s0,48(sp)
    80001af0:	f426                	sd	s1,40(sp)
    80001af2:	f04a                	sd	s2,32(sp)
    80001af4:	ec4e                	sd	s3,24(sp)
    80001af6:	e852                	sd	s4,16(sp)
    80001af8:	e456                	sd	s5,8(sp)
    80001afa:	e05a                	sd	s6,0(sp)
    80001afc:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001afe:	00006597          	auipc	a1,0x6
    80001b02:	68258593          	addi	a1,a1,1666 # 80008180 <digits+0x148>
    80001b06:	0022f517          	auipc	a0,0x22f
    80001b0a:	f0a50513          	addi	a0,a0,-246 # 80230a10 <pid_lock>
    80001b0e:	930ff0ef          	jal	ra,80000c3e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b12:	00006597          	auipc	a1,0x6
    80001b16:	67658593          	addi	a1,a1,1654 # 80008188 <digits+0x150>
    80001b1a:	0022f517          	auipc	a0,0x22f
    80001b1e:	f0e50513          	addi	a0,a0,-242 # 80230a28 <wait_lock>
    80001b22:	91cff0ef          	jal	ra,80000c3e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b26:	0022f497          	auipc	s1,0x22f
    80001b2a:	31a48493          	addi	s1,s1,794 # 80230e40 <proc>
      initlock(&p->lock, "proc");
    80001b2e:	00006b17          	auipc	s6,0x6
    80001b32:	66ab0b13          	addi	s6,s6,1642 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001b36:	8aa6                	mv	s5,s1
    80001b38:	00006a17          	auipc	s4,0x6
    80001b3c:	4c8a0a13          	addi	s4,s4,1224 # 80008000 <etext>
    80001b40:	04000937          	lui	s2,0x4000
    80001b44:	197d                	addi	s2,s2,-1
    80001b46:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b48:	0023f997          	auipc	s3,0x23f
    80001b4c:	cf898993          	addi	s3,s3,-776 # 80240840 <tickslock>
      initlock(&p->lock, "proc");
    80001b50:	85da                	mv	a1,s6
    80001b52:	8526                	mv	a0,s1
    80001b54:	8eaff0ef          	jal	ra,80000c3e <initlock>
      p->state = UNUSED;
    80001b58:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001b5c:	415487b3          	sub	a5,s1,s5
    80001b60:	878d                	srai	a5,a5,0x3
    80001b62:	000a3703          	ld	a4,0(s4)
    80001b66:	02e787b3          	mul	a5,a5,a4
    80001b6a:	2785                	addiw	a5,a5,1
    80001b6c:	00d7979b          	slliw	a5,a5,0xd
    80001b70:	40f907b3          	sub	a5,s2,a5
    80001b74:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b76:	3e848493          	addi	s1,s1,1000
    80001b7a:	fd349be3          	bne	s1,s3,80001b50 <procinit+0x66>
  }
}
    80001b7e:	70e2                	ld	ra,56(sp)
    80001b80:	7442                	ld	s0,48(sp)
    80001b82:	74a2                	ld	s1,40(sp)
    80001b84:	7902                	ld	s2,32(sp)
    80001b86:	69e2                	ld	s3,24(sp)
    80001b88:	6a42                	ld	s4,16(sp)
    80001b8a:	6aa2                	ld	s5,8(sp)
    80001b8c:	6b02                	ld	s6,0(sp)
    80001b8e:	6121                	addi	sp,sp,64
    80001b90:	8082                	ret

0000000080001b92 <cpuid>:
 * 返回值：
 *   当前CPU的ID
 */
int
cpuid()
{
    80001b92:	1141                	addi	sp,sp,-16
    80001b94:	e422                	sd	s0,8(sp)
    80001b96:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b98:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b9a:	2501                	sext.w	a0,a0
    80001b9c:	6422                	ld	s0,8(sp)
    80001b9e:	0141                	addi	sp,sp,16
    80001ba0:	8082                	ret

0000000080001ba2 <mycpu>:
 * 返回值：
 *   当前CPU的cpu结构体指针
 */
struct cpu*
mycpu(void)
{
    80001ba2:	1141                	addi	sp,sp,-16
    80001ba4:	e422                	sd	s0,8(sp)
    80001ba6:	0800                	addi	s0,sp,16
    80001ba8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001baa:	2781                	sext.w	a5,a5
    80001bac:	079e                	slli	a5,a5,0x7
  return c;
}
    80001bae:	0022f517          	auipc	a0,0x22f
    80001bb2:	e9250513          	addi	a0,a0,-366 # 80230a40 <cpus>
    80001bb6:	953e                	add	a0,a0,a5
    80001bb8:	6422                	ld	s0,8(sp)
    80001bba:	0141                	addi	sp,sp,16
    80001bbc:	8082                	ret

0000000080001bbe <myproc>:
 * 返回值：
 *   当前进程的proc结构体指针，如果没有则返回0
 */
struct proc*
myproc(void)
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	1000                	addi	s0,sp,32
  push_off();
    80001bc8:	8b6ff0ef          	jal	ra,80000c7e <push_off>
    80001bcc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001bce:	2781                	sext.w	a5,a5
    80001bd0:	079e                	slli	a5,a5,0x7
    80001bd2:	0022f717          	auipc	a4,0x22f
    80001bd6:	e3e70713          	addi	a4,a4,-450 # 80230a10 <pid_lock>
    80001bda:	97ba                	add	a5,a5,a4
    80001bdc:	7b84                	ld	s1,48(a5)
  pop_off();
    80001bde:	924ff0ef          	jal	ra,80000d02 <pop_off>
  return p;
}
    80001be2:	8526                	mv	a0,s1
    80001be4:	60e2                	ld	ra,24(sp)
    80001be6:	6442                	ld	s0,16(sp)
    80001be8:	64a2                	ld	s1,8(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret

0000000080001bee <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001bee:	7179                	addi	sp,sp,-48
    80001bf0:	f406                	sd	ra,40(sp)
    80001bf2:	f022                	sd	s0,32(sp)
    80001bf4:	ec26                	sd	s1,24(sp)
    80001bf6:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001bf8:	fc7ff0ef          	jal	ra,80001bbe <myproc>
    80001bfc:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001bfe:	958ff0ef          	jal	ra,80000d56 <release>

  if (first) {
    80001c02:	00007797          	auipc	a5,0x7
    80001c06:	c8e7a783          	lw	a5,-882(a5) # 80008890 <first.1>
    80001c0a:	cf8d                	beqz	a5,80001c44 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001c0c:	4505                	li	a0,1
    80001c0e:	5c0020ef          	jal	ra,800041ce <fsinit>

    first = 0;
    80001c12:	00007797          	auipc	a5,0x7
    80001c16:	c607af23          	sw	zero,-898(a5) # 80008890 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001c1a:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001c1e:	00006517          	auipc	a0,0x6
    80001c22:	58250513          	addi	a0,a0,1410 # 800081a0 <digits+0x168>
    80001c26:	fca43823          	sd	a0,-48(s0)
    80001c2a:	fc043c23          	sd	zero,-40(s0)
    80001c2e:	fd040593          	addi	a1,s0,-48
    80001c32:	644030ef          	jal	ra,80005276 <kexec>
    80001c36:	6cbc                	ld	a5,88(s1)
    80001c38:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001c3a:	6cbc                	ld	a5,88(s1)
    80001c3c:	7bb8                	ld	a4,112(a5)
    80001c3e:	57fd                	li	a5,-1
    80001c40:	02f70d63          	beq	a4,a5,80001c7a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001c44:	5ab000ef          	jal	ra,800029ee <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c48:	68a8                	ld	a0,80(s1)
    80001c4a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c4c:	04000737          	lui	a4,0x4000
    80001c50:	00005797          	auipc	a5,0x5
    80001c54:	44c78793          	addi	a5,a5,1100 # 8000709c <userret>
    80001c58:	00005697          	auipc	a3,0x5
    80001c5c:	3a868693          	addi	a3,a3,936 # 80007000 <_trampoline>
    80001c60:	8f95                	sub	a5,a5,a3
    80001c62:	177d                	addi	a4,a4,-1
    80001c64:	0732                	slli	a4,a4,0xc
    80001c66:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c68:	577d                	li	a4,-1
    80001c6a:	177e                	slli	a4,a4,0x3f
    80001c6c:	8d59                	or	a0,a0,a4
    80001c6e:	9782                	jalr	a5
}
    80001c70:	70a2                	ld	ra,40(sp)
    80001c72:	7402                	ld	s0,32(sp)
    80001c74:	64e2                	ld	s1,24(sp)
    80001c76:	6145                	addi	sp,sp,48
    80001c78:	8082                	ret
      panic("exec");
    80001c7a:	00006517          	auipc	a0,0x6
    80001c7e:	52e50513          	addi	a0,a0,1326 # 800081a8 <digits+0x170>
    80001c82:	b09fe0ef          	jal	ra,8000078a <panic>

0000000080001c86 <allocpid>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	e04a                	sd	s2,0(sp)
    80001c90:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c92:	0022f917          	auipc	s2,0x22f
    80001c96:	d7e90913          	addi	s2,s2,-642 # 80230a10 <pid_lock>
    80001c9a:	854a                	mv	a0,s2
    80001c9c:	822ff0ef          	jal	ra,80000cbe <acquire>
  pid = nextpid;
    80001ca0:	00007797          	auipc	a5,0x7
    80001ca4:	bf478793          	addi	a5,a5,-1036 # 80008894 <nextpid>
    80001ca8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001caa:	0014871b          	addiw	a4,s1,1
    80001cae:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001cb0:	854a                	mv	a0,s2
    80001cb2:	8a4ff0ef          	jal	ra,80000d56 <release>
}
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	60e2                	ld	ra,24(sp)
    80001cba:	6442                	ld	s0,16(sp)
    80001cbc:	64a2                	ld	s1,8(sp)
    80001cbe:	6902                	ld	s2,0(sp)
    80001cc0:	6105                	addi	sp,sp,32
    80001cc2:	8082                	ret

0000000080001cc4 <delete_shm_from_vmas>:
delete_shm_from_vmas(struct vma *vmas){
    80001cc4:	7139                	addi	sp,sp,-64
    80001cc6:	fc06                	sd	ra,56(sp)
    80001cc8:	f822                	sd	s0,48(sp)
    80001cca:	f426                	sd	s1,40(sp)
    80001ccc:	f04a                	sd	s2,32(sp)
    80001cce:	ec4e                	sd	s3,24(sp)
    80001cd0:	e852                	sd	s4,16(sp)
    80001cd2:	e456                	sd	s5,8(sp)
    80001cd4:	0080                	addi	s0,sp,64
    80001cd6:	8a2a                	mv	s4,a0
    80001cd8:	84aa                	mv	s1,a0
  for(int i = 0; i < NVMA; i++){
    80001cda:	4901                	li	s2,0
    80001cdc:	02850a93          	addi	s5,a0,40
    80001ce0:	49c1                	li	s3,16
    80001ce2:	a025                	j	80001d0a <delete_shm_from_vmas+0x46>
    for(int j = 0; j < i; j++){
    80001ce4:	02878793          	addi	a5,a5,40
    80001ce8:	00d78a63          	beq	a5,a3,80001cfc <delete_shm_from_vmas+0x38>
      if(vmas[j].used && vmas[j].is_shm && vmas[j].shm_key == key){
    80001cec:	4398                	lw	a4,0(a5)
    80001cee:	db7d                	beqz	a4,80001ce4 <delete_shm_from_vmas+0x20>
    80001cf0:	5398                	lw	a4,32(a5)
    80001cf2:	db6d                	beqz	a4,80001ce4 <delete_shm_from_vmas+0x20>
    80001cf4:	53d8                	lw	a4,36(a5)
    80001cf6:	fea717e3          	bne	a4,a0,80001ce4 <delete_shm_from_vmas+0x20>
    80001cfa:	a019                	j	80001d00 <delete_shm_from_vmas+0x3c>
    shm_put(key);
    80001cfc:	239040ef          	jal	ra,80006734 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d00:	2905                	addiw	s2,s2,1
    80001d02:	02848493          	addi	s1,s1,40
    80001d06:	03390563          	beq	s2,s3,80001d30 <delete_shm_from_vmas+0x6c>
    if(!vmas[i].used || !vmas[i].is_shm) continue;
    80001d0a:	409c                	lw	a5,0(s1)
    80001d0c:	dbf5                	beqz	a5,80001d00 <delete_shm_from_vmas+0x3c>
    80001d0e:	509c                	lw	a5,32(s1)
    80001d10:	dbe5                	beqz	a5,80001d00 <delete_shm_from_vmas+0x3c>
    int key = vmas[i].shm_key;
    80001d12:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d14:	ff2054e3          	blez	s2,80001cfc <delete_shm_from_vmas+0x38>
    80001d18:	fff9069b          	addiw	a3,s2,-1
    80001d1c:	02069793          	slli	a5,a3,0x20
    80001d20:	9381                	srli	a5,a5,0x20
    80001d22:	00279693          	slli	a3,a5,0x2
    80001d26:	96be                	add	a3,a3,a5
    80001d28:	068e                	slli	a3,a3,0x3
    80001d2a:	96d6                	add	a3,a3,s5
    80001d2c:	87d2                	mv	a5,s4
    80001d2e:	bf7d                	j	80001cec <delete_shm_from_vmas+0x28>
}
    80001d30:	70e2                	ld	ra,56(sp)
    80001d32:	7442                	ld	s0,48(sp)
    80001d34:	74a2                	ld	s1,40(sp)
    80001d36:	7902                	ld	s2,32(sp)
    80001d38:	69e2                	ld	s3,24(sp)
    80001d3a:	6a42                	ld	s4,16(sp)
    80001d3c:	6aa2                	ld	s5,8(sp)
    80001d3e:	6121                	addi	sp,sp,64
    80001d40:	8082                	ret

0000000080001d42 <delete_shm_from_proc>:
delete_shm_from_proc(struct proc *p){
    80001d42:	7139                	addi	sp,sp,-64
    80001d44:	fc06                	sd	ra,56(sp)
    80001d46:	f822                	sd	s0,48(sp)
    80001d48:	f426                	sd	s1,40(sp)
    80001d4a:	f04a                	sd	s2,32(sp)
    80001d4c:	ec4e                	sd	s3,24(sp)
    80001d4e:	e852                	sd	s4,16(sp)
    80001d50:	e456                	sd	s5,8(sp)
    80001d52:	0080                	addi	s0,sp,64
  for(int i = 0; i < NVMA; i++){
    80001d54:	16850a93          	addi	s5,a0,360
delete_shm_from_proc(struct proc *p){
    80001d58:	84d6                	mv	s1,s5
  for(int i = 0; i < NVMA; i++){
    80001d5a:	4901                	li	s2,0
    80001d5c:	19050a13          	addi	s4,a0,400
    80001d60:	49c1                	li	s3,16
    80001d62:	a025                	j	80001d8a <delete_shm_from_proc+0x48>
    for(int j = 0; j < i; j++){
    80001d64:	02878793          	addi	a5,a5,40
    80001d68:	00d78a63          	beq	a5,a3,80001d7c <delete_shm_from_proc+0x3a>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001d6c:	4398                	lw	a4,0(a5)
    80001d6e:	db7d                	beqz	a4,80001d64 <delete_shm_from_proc+0x22>
    80001d70:	5398                	lw	a4,32(a5)
    80001d72:	db6d                	beqz	a4,80001d64 <delete_shm_from_proc+0x22>
    80001d74:	53d8                	lw	a4,36(a5)
    80001d76:	fea717e3          	bne	a4,a0,80001d64 <delete_shm_from_proc+0x22>
    80001d7a:	a019                	j	80001d80 <delete_shm_from_proc+0x3e>
    shm_put(key);
    80001d7c:	1b9040ef          	jal	ra,80006734 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d80:	2905                	addiw	s2,s2,1
    80001d82:	02848493          	addi	s1,s1,40
    80001d86:	03390563          	beq	s2,s3,80001db0 <delete_shm_from_proc+0x6e>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001d8a:	409c                	lw	a5,0(s1)
    80001d8c:	dbf5                	beqz	a5,80001d80 <delete_shm_from_proc+0x3e>
    80001d8e:	509c                	lw	a5,32(s1)
    80001d90:	dbe5                	beqz	a5,80001d80 <delete_shm_from_proc+0x3e>
    int key = p->vmas[i].shm_key;
    80001d92:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d94:	ff2054e3          	blez	s2,80001d7c <delete_shm_from_proc+0x3a>
    80001d98:	fff9069b          	addiw	a3,s2,-1
    80001d9c:	02069793          	slli	a5,a3,0x20
    80001da0:	9381                	srli	a5,a5,0x20
    80001da2:	00279693          	slli	a3,a5,0x2
    80001da6:	96be                	add	a3,a3,a5
    80001da8:	068e                	slli	a3,a3,0x3
    80001daa:	96d2                	add	a3,a3,s4
    80001dac:	87d6                	mv	a5,s5
    80001dae:	bf7d                	j	80001d6c <delete_shm_from_proc+0x2a>
}
    80001db0:	70e2                	ld	ra,56(sp)
    80001db2:	7442                	ld	s0,48(sp)
    80001db4:	74a2                	ld	s1,40(sp)
    80001db6:	7902                	ld	s2,32(sp)
    80001db8:	69e2                	ld	s3,24(sp)
    80001dba:	6a42                	ld	s4,16(sp)
    80001dbc:	6aa2                	ld	s5,8(sp)
    80001dbe:	6121                	addi	sp,sp,64
    80001dc0:	8082                	ret

0000000080001dc2 <vma_release_all>:
{
    80001dc2:	7139                	addi	sp,sp,-64
    80001dc4:	fc06                	sd	ra,56(sp)
    80001dc6:	f822                	sd	s0,48(sp)
    80001dc8:	f426                	sd	s1,40(sp)
    80001dca:	f04a                	sd	s2,32(sp)
    80001dcc:	ec4e                	sd	s3,24(sp)
    80001dce:	e852                	sd	s4,16(sp)
    80001dd0:	e456                	sd	s5,8(sp)
    80001dd2:	e05a                	sd	s6,0(sp)
    80001dd4:	0080                	addi	s0,sp,64
    80001dd6:	8b2a                	mv	s6,a0
  for(int i = 0; i < NVMA; i++){
    80001dd8:	16850493          	addi	s1,a0,360
    80001ddc:	3e850a13          	addi	s4,a0,1000
{
    80001de0:	8926                	mv	s2,s1
    80001de2:	a029                	j	80001dec <vma_release_all+0x2a>
  for(int i = 0; i < NVMA; i++){
    80001de4:	02890913          	addi	s2,s2,40
    80001de8:	03490663          	beq	s2,s4,80001e14 <vma_release_all+0x52>
    if(!v->used) continue;
    80001dec:	00092783          	lw	a5,0(s2)
    80001df0:	dbf5                	beqz	a5,80001de4 <vma_release_all+0x22>
    uint64 start = v->start;
    80001df2:	00893583          	ld	a1,8(s2)
    uint64 end   = v->end;
    80001df6:	01093603          	ld	a2,16(s2)
    if(end <= start) continue;
    80001dfa:	fec5f5e3          	bgeu	a1,a2,80001de4 <vma_release_all+0x22>
    int do_free = (v->is_shm ? 0 : 1);
    80001dfe:	02092683          	lw	a3,32(s2)
    uint64 npages = (end - start) / PGSIZE;
    80001e02:	8e0d                	sub	a2,a2,a1
    uvmunmap(p->pagetable, start, npages, do_free);
    80001e04:	0016b693          	seqz	a3,a3
    80001e08:	8231                	srli	a2,a2,0xc
    80001e0a:	050b3503          	ld	a0,80(s6)
    80001e0e:	cb0ff0ef          	jal	ra,800012be <uvmunmap>
    80001e12:	bfc9                	j	80001de4 <vma_release_all+0x22>
    80001e14:	8926                	mv	s2,s1
  for(int i = 0; i < NVMA; i++){
    80001e16:	4981                	li	s3,0
    80001e18:	190b0b13          	addi	s6,s6,400
    80001e1c:	4ac1                	li	s5,16
    80001e1e:	a891                	j	80001e72 <vma_release_all+0xb0>
    for(int j = 0; j < i; j++){
    80001e20:	02878793          	addi	a5,a5,40
    80001e24:	04d78063          	beq	a5,a3,80001e64 <vma_release_all+0xa2>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001e28:	4398                	lw	a4,0(a5)
    80001e2a:	db7d                	beqz	a4,80001e20 <vma_release_all+0x5e>
    80001e2c:	5398                	lw	a4,32(a5)
    80001e2e:	db6d                	beqz	a4,80001e20 <vma_release_all+0x5e>
    80001e30:	53d8                	lw	a4,36(a5)
    80001e32:	fea717e3          	bne	a4,a0,80001e20 <vma_release_all+0x5e>
    80001e36:	a80d                	j	80001e68 <vma_release_all+0xa6>
      p->vmas[i].shm_key = -1;
    80001e38:	577d                	li	a4,-1
    80001e3a:	a029                	j	80001e44 <vma_release_all+0x82>
  for(int i = 0; i < NVMA; i++){
    80001e3c:	02848493          	addi	s1,s1,40
    80001e40:	05448f63          	beq	s1,s4,80001e9e <vma_release_all+0xdc>
    if(p->vmas[i].used){
    80001e44:	409c                	lw	a5,0(s1)
    80001e46:	dbfd                	beqz	a5,80001e3c <vma_release_all+0x7a>
      p->vmas[i].used = 0;
    80001e48:	0004a023          	sw	zero,0(s1)
      p->vmas[i].is_shm = 0;
    80001e4c:	0204a023          	sw	zero,32(s1)
      p->vmas[i].shm_key = -1;
    80001e50:	d0d8                	sw	a4,36(s1)
      p->vmas[i].start = p->vmas[i].end = 0;
    80001e52:	0004b823          	sd	zero,16(s1)
    80001e56:	0004b423          	sd	zero,8(s1)
      p->vmas[i].prot = p->vmas[i].flags = 0;
    80001e5a:	0004ae23          	sw	zero,28(s1)
    80001e5e:	0004ac23          	sw	zero,24(s1)
    80001e62:	bfe9                	j	80001e3c <vma_release_all+0x7a>
    shm_put(key);
    80001e64:	0d1040ef          	jal	ra,80006734 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001e68:	2985                	addiw	s3,s3,1
    80001e6a:	02890913          	addi	s2,s2,40
    80001e6e:	fd5985e3          	beq	s3,s5,80001e38 <vma_release_all+0x76>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001e72:	00092783          	lw	a5,0(s2)
    80001e76:	dbed                	beqz	a5,80001e68 <vma_release_all+0xa6>
    80001e78:	02092783          	lw	a5,32(s2)
    80001e7c:	d7f5                	beqz	a5,80001e68 <vma_release_all+0xa6>
    int key = p->vmas[i].shm_key;
    80001e7e:	02492503          	lw	a0,36(s2)
    for(int j = 0; j < i; j++){
    80001e82:	ff3051e3          	blez	s3,80001e64 <vma_release_all+0xa2>
    80001e86:	fff9869b          	addiw	a3,s3,-1
    80001e8a:	02069793          	slli	a5,a3,0x20
    80001e8e:	9381                	srli	a5,a5,0x20
    80001e90:	00279693          	slli	a3,a5,0x2
    80001e94:	96be                	add	a3,a3,a5
    80001e96:	068e                	slli	a3,a3,0x3
    80001e98:	96da                	add	a3,a3,s6
    80001e9a:	87a6                	mv	a5,s1
    80001e9c:	b771                	j	80001e28 <vma_release_all+0x66>
}
    80001e9e:	70e2                	ld	ra,56(sp)
    80001ea0:	7442                	ld	s0,48(sp)
    80001ea2:	74a2                	ld	s1,40(sp)
    80001ea4:	7902                	ld	s2,32(sp)
    80001ea6:	69e2                	ld	s3,24(sp)
    80001ea8:	6a42                	ld	s4,16(sp)
    80001eaa:	6aa2                	ld	s5,8(sp)
    80001eac:	6b02                	ld	s6,0(sp)
    80001eae:	6121                	addi	sp,sp,64
    80001eb0:	8082                	ret

0000000080001eb2 <proc_pagetable>:
{
    80001eb2:	1101                	addi	sp,sp,-32
    80001eb4:	ec06                	sd	ra,24(sp)
    80001eb6:	e822                	sd	s0,16(sp)
    80001eb8:	e426                	sd	s1,8(sp)
    80001eba:	e04a                	sd	s2,0(sp)
    80001ebc:	1000                	addi	s0,sp,32
    80001ebe:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ec0:	bd8ff0ef          	jal	ra,80001298 <uvmcreate>
    80001ec4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ec6:	cd05                	beqz	a0,80001efe <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ec8:	4729                	li	a4,10
    80001eca:	00005697          	auipc	a3,0x5
    80001ece:	13668693          	addi	a3,a3,310 # 80007000 <_trampoline>
    80001ed2:	6605                	lui	a2,0x1
    80001ed4:	040005b7          	lui	a1,0x4000
    80001ed8:	15fd                	addi	a1,a1,-1
    80001eda:	05b2                	slli	a1,a1,0xc
    80001edc:	a16ff0ef          	jal	ra,800010f2 <mappages>
    80001ee0:	02054663          	bltz	a0,80001f0c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ee4:	4719                	li	a4,6
    80001ee6:	05893683          	ld	a3,88(s2)
    80001eea:	6605                	lui	a2,0x1
    80001eec:	020005b7          	lui	a1,0x2000
    80001ef0:	15fd                	addi	a1,a1,-1
    80001ef2:	05b6                	slli	a1,a1,0xd
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	9fcff0ef          	jal	ra,800010f2 <mappages>
    80001efa:	00054f63          	bltz	a0,80001f18 <proc_pagetable+0x66>
}
    80001efe:	8526                	mv	a0,s1
    80001f00:	60e2                	ld	ra,24(sp)
    80001f02:	6442                	ld	s0,16(sp)
    80001f04:	64a2                	ld	s1,8(sp)
    80001f06:	6902                	ld	s2,0(sp)
    80001f08:	6105                	addi	sp,sp,32
    80001f0a:	8082                	ret
    uvmfree(pagetable, 0);
    80001f0c:	4581                	li	a1,0
    80001f0e:	8526                	mv	a0,s1
    80001f10:	d66ff0ef          	jal	ra,80001476 <uvmfree>
    return 0;
    80001f14:	4481                	li	s1,0
    80001f16:	b7e5                	j	80001efe <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f18:	4681                	li	a3,0
    80001f1a:	4605                	li	a2,1
    80001f1c:	040005b7          	lui	a1,0x4000
    80001f20:	15fd                	addi	a1,a1,-1
    80001f22:	05b2                	slli	a1,a1,0xc
    80001f24:	8526                	mv	a0,s1
    80001f26:	b98ff0ef          	jal	ra,800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001f2a:	4581                	li	a1,0
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	d48ff0ef          	jal	ra,80001476 <uvmfree>
    return 0;
    80001f32:	4481                	li	s1,0
    80001f34:	b7e9                	j	80001efe <proc_pagetable+0x4c>

0000000080001f36 <vma_unmap_pagetable>:
{
    80001f36:	7179                	addi	sp,sp,-48
    80001f38:	f406                	sd	ra,40(sp)
    80001f3a:	f022                	sd	s0,32(sp)
    80001f3c:	ec26                	sd	s1,24(sp)
    80001f3e:	e84a                	sd	s2,16(sp)
    80001f40:	e44e                	sd	s3,8(sp)
    80001f42:	1800                	addi	s0,sp,48
    80001f44:	89aa                	mv	s3,a0
    80001f46:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001f48:	28058913          	addi	s2,a1,640 # 4000280 <_entry-0x7bfffd80>
    80001f4c:	a811                	j	80001f60 <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001f4e:	4685                	li	a3,1
    80001f50:	8231                	srli	a2,a2,0xc
    80001f52:	854e                	mv	a0,s3
    80001f54:	b6aff0ef          	jal	ra,800012be <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001f58:	02848493          	addi	s1,s1,40
    80001f5c:	01248b63          	beq	s1,s2,80001f72 <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001f60:	409c                	lw	a5,0(s1)
    80001f62:	dbfd                	beqz	a5,80001f58 <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001f64:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001f66:	689c                	ld	a5,16(s1)
    80001f68:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001f6c:	feb786e3          	beq	a5,a1,80001f58 <vma_unmap_pagetable+0x22>
    80001f70:	bff9                	j	80001f4e <vma_unmap_pagetable+0x18>
}
    80001f72:	70a2                	ld	ra,40(sp)
    80001f74:	7402                	ld	s0,32(sp)
    80001f76:	64e2                	ld	s1,24(sp)
    80001f78:	6942                	ld	s2,16(sp)
    80001f7a:	69a2                	ld	s3,8(sp)
    80001f7c:	6145                	addi	sp,sp,48
    80001f7e:	8082                	ret

0000000080001f80 <proc_freepagetable>:
{
    80001f80:	1101                	addi	sp,sp,-32
    80001f82:	ec06                	sd	ra,24(sp)
    80001f84:	e822                	sd	s0,16(sp)
    80001f86:	e426                	sd	s1,8(sp)
    80001f88:	e04a                	sd	s2,0(sp)
    80001f8a:	1000                	addi	s0,sp,32
    80001f8c:	84aa                	mv	s1,a0
    80001f8e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f90:	4681                	li	a3,0
    80001f92:	4605                	li	a2,1
    80001f94:	040005b7          	lui	a1,0x4000
    80001f98:	15fd                	addi	a1,a1,-1
    80001f9a:	05b2                	slli	a1,a1,0xc
    80001f9c:	b22ff0ef          	jal	ra,800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001fa0:	4681                	li	a3,0
    80001fa2:	4605                	li	a2,1
    80001fa4:	020005b7          	lui	a1,0x2000
    80001fa8:	15fd                	addi	a1,a1,-1
    80001faa:	05b6                	slli	a1,a1,0xd
    80001fac:	8526                	mv	a0,s1
    80001fae:	b10ff0ef          	jal	ra,800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001fb2:	85ca                	mv	a1,s2
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	cc0ff0ef          	jal	ra,80001476 <uvmfree>
}
    80001fba:	60e2                	ld	ra,24(sp)
    80001fbc:	6442                	ld	s0,16(sp)
    80001fbe:	64a2                	ld	s1,8(sp)
    80001fc0:	6902                	ld	s2,0(sp)
    80001fc2:	6105                	addi	sp,sp,32
    80001fc4:	8082                	ret

0000000080001fc6 <freeproc>:
{
    80001fc6:	1101                	addi	sp,sp,-32
    80001fc8:	ec06                	sd	ra,24(sp)
    80001fca:	e822                	sd	s0,16(sp)
    80001fcc:	e426                	sd	s1,8(sp)
    80001fce:	e04a                	sd	s2,0(sp)
    80001fd0:	1000                	addi	s0,sp,32
    80001fd2:	84aa                	mv	s1,a0
  vma_release_all(p);
    80001fd4:	defff0ef          	jal	ra,80001dc2 <vma_release_all>
  if(p->trapframe)
    80001fd8:	6ca8                	ld	a0,88(s1)
    80001fda:	c119                	beqz	a0,80001fe0 <freeproc+0x1a>
    kfree((void*)p->trapframe);
    80001fdc:	aa3fe0ef          	jal	ra,80000a7e <kfree>
  p->trapframe = 0;
    80001fe0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001fe4:	68a8                	ld	a0,80(s1)
    80001fe6:	c105                	beqz	a0,80002006 <freeproc+0x40>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001fe8:	16848913          	addi	s2,s1,360
    80001fec:	85ca                	mv	a1,s2
    80001fee:	f49ff0ef          	jal	ra,80001f36 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001ff2:	28000613          	li	a2,640
    80001ff6:	4581                	li	a1,0
    80001ff8:	854a                	mv	a0,s2
    80001ffa:	d99fe0ef          	jal	ra,80000d92 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001ffe:	64ac                	ld	a1,72(s1)
    80002000:	68a8                	ld	a0,80(s1)
    80002002:	f7fff0ef          	jal	ra,80001f80 <proc_freepagetable>
  delete_shm_from_proc(p);
    80002006:	8526                	mv	a0,s1
    80002008:	d3bff0ef          	jal	ra,80001d42 <delete_shm_from_proc>
  p->pagetable = 0;
    8000200c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002010:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002014:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002018:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000201c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002020:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002024:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002028:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000202c:	0004ac23          	sw	zero,24(s1)
}
    80002030:	60e2                	ld	ra,24(sp)
    80002032:	6442                	ld	s0,16(sp)
    80002034:	64a2                	ld	s1,8(sp)
    80002036:	6902                	ld	s2,0(sp)
    80002038:	6105                	addi	sp,sp,32
    8000203a:	8082                	ret

000000008000203c <allocproc>:
{
    8000203c:	1101                	addi	sp,sp,-32
    8000203e:	ec06                	sd	ra,24(sp)
    80002040:	e822                	sd	s0,16(sp)
    80002042:	e426                	sd	s1,8(sp)
    80002044:	e04a                	sd	s2,0(sp)
    80002046:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002048:	0022f497          	auipc	s1,0x22f
    8000204c:	df848493          	addi	s1,s1,-520 # 80230e40 <proc>
    80002050:	0023e917          	auipc	s2,0x23e
    80002054:	7f090913          	addi	s2,s2,2032 # 80240840 <tickslock>
    acquire(&p->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	c65fe0ef          	jal	ra,80000cbe <acquire>
    if(p->state == UNUSED) {
    8000205e:	4c9c                	lw	a5,24(s1)
    80002060:	cb91                	beqz	a5,80002074 <allocproc+0x38>
      release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	cf3fe0ef          	jal	ra,80000d56 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002068:	3e848493          	addi	s1,s1,1000
    8000206c:	ff2496e3          	bne	s1,s2,80002058 <allocproc+0x1c>
  return 0;
    80002070:	4481                	li	s1,0
    80002072:	a089                	j	800020b4 <allocproc+0x78>
  p->pid = allocpid();
    80002074:	c13ff0ef          	jal	ra,80001c86 <allocpid>
    80002078:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000207a:	4785                	li	a5,1
    8000207c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000207e:	b3dfe0ef          	jal	ra,80000bba <kalloc>
    80002082:	892a                	mv	s2,a0
    80002084:	eca8                	sd	a0,88(s1)
    80002086:	cd15                	beqz	a0,800020c2 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80002088:	8526                	mv	a0,s1
    8000208a:	e29ff0ef          	jal	ra,80001eb2 <proc_pagetable>
    8000208e:	892a                	mv	s2,a0
    80002090:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002092:	c121                	beqz	a0,800020d2 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80002094:	07000613          	li	a2,112
    80002098:	4581                	li	a1,0
    8000209a:	06048513          	addi	a0,s1,96
    8000209e:	cf5fe0ef          	jal	ra,80000d92 <memset>
  p->context.ra = (uint64)forkret;
    800020a2:	00000797          	auipc	a5,0x0
    800020a6:	b4c78793          	addi	a5,a5,-1204 # 80001bee <forkret>
    800020aa:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800020ac:	60bc                	ld	a5,64(s1)
    800020ae:	6705                	lui	a4,0x1
    800020b0:	97ba                	add	a5,a5,a4
    800020b2:	f4bc                	sd	a5,104(s1)
}
    800020b4:	8526                	mv	a0,s1
    800020b6:	60e2                	ld	ra,24(sp)
    800020b8:	6442                	ld	s0,16(sp)
    800020ba:	64a2                	ld	s1,8(sp)
    800020bc:	6902                	ld	s2,0(sp)
    800020be:	6105                	addi	sp,sp,32
    800020c0:	8082                	ret
    freeproc(p);
    800020c2:	8526                	mv	a0,s1
    800020c4:	f03ff0ef          	jal	ra,80001fc6 <freeproc>
    release(&p->lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	c8dfe0ef          	jal	ra,80000d56 <release>
    return 0;
    800020ce:	84ca                	mv	s1,s2
    800020d0:	b7d5                	j	800020b4 <allocproc+0x78>
    freeproc(p);
    800020d2:	8526                	mv	a0,s1
    800020d4:	ef3ff0ef          	jal	ra,80001fc6 <freeproc>
    release(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	c7dfe0ef          	jal	ra,80000d56 <release>
    return 0;
    800020de:	84ca                	mv	s1,s2
    800020e0:	bfd1                	j	800020b4 <allocproc+0x78>

00000000800020e2 <userinit>:
{
    800020e2:	1101                	addi	sp,sp,-32
    800020e4:	ec06                	sd	ra,24(sp)
    800020e6:	e822                	sd	s0,16(sp)
    800020e8:	e426                	sd	s1,8(sp)
    800020ea:	1000                	addi	s0,sp,32
  p = allocproc();
    800020ec:	f51ff0ef          	jal	ra,8000203c <allocproc>
    800020f0:	84aa                	mv	s1,a0
  initproc = p;
    800020f2:	00006797          	auipc	a5,0x6
    800020f6:	7ca7b723          	sd	a0,1998(a5) # 800088c0 <initproc>
  p->cwd = namei("/");
    800020fa:	00006517          	auipc	a0,0x6
    800020fe:	0b650513          	addi	a0,a0,182 # 800081b0 <digits+0x178>
    80002102:	5ca020ef          	jal	ra,800046cc <namei>
    80002106:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000210a:	478d                	li	a5,3
    8000210c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	c47fe0ef          	jal	ra,80000d56 <release>
}
    80002114:	60e2                	ld	ra,24(sp)
    80002116:	6442                	ld	s0,16(sp)
    80002118:	64a2                	ld	s1,8(sp)
    8000211a:	6105                	addi	sp,sp,32
    8000211c:	8082                	ret

000000008000211e <growproc>:
{
    8000211e:	1101                	addi	sp,sp,-32
    80002120:	ec06                	sd	ra,24(sp)
    80002122:	e822                	sd	s0,16(sp)
    80002124:	e426                	sd	s1,8(sp)
    80002126:	e04a                	sd	s2,0(sp)
    80002128:	1000                	addi	s0,sp,32
    8000212a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000212c:	a93ff0ef          	jal	ra,80001bbe <myproc>
    80002130:	892a                	mv	s2,a0
  sz = p->sz;
    80002132:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002134:	02905963          	blez	s1,80002166 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80002138:	00b48633          	add	a2,s1,a1
    8000213c:	020007b7          	lui	a5,0x2000
    80002140:	17fd                	addi	a5,a5,-1
    80002142:	07b6                	slli	a5,a5,0xd
    80002144:	02c7ea63          	bltu	a5,a2,80002178 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002148:	4691                	li	a3,4
    8000214a:	6928                	ld	a0,80(a0)
    8000214c:	a32ff0ef          	jal	ra,8000137e <uvmalloc>
    80002150:	85aa                	mv	a1,a0
    80002152:	c50d                	beqz	a0,8000217c <growproc+0x5e>
  p->sz = sz;
    80002154:	04b93423          	sd	a1,72(s2)
  return 0;
    80002158:	4501                	li	a0,0
}
    8000215a:	60e2                	ld	ra,24(sp)
    8000215c:	6442                	ld	s0,16(sp)
    8000215e:	64a2                	ld	s1,8(sp)
    80002160:	6902                	ld	s2,0(sp)
    80002162:	6105                	addi	sp,sp,32
    80002164:	8082                	ret
  } else if(n < 0){
    80002166:	fe04d7e3          	bgez	s1,80002154 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000216a:	00b48633          	add	a2,s1,a1
    8000216e:	6928                	ld	a0,80(a0)
    80002170:	9caff0ef          	jal	ra,8000133a <uvmdealloc>
    80002174:	85aa                	mv	a1,a0
    80002176:	bff9                	j	80002154 <growproc+0x36>
      return -1;
    80002178:	557d                	li	a0,-1
    8000217a:	b7c5                	j	8000215a <growproc+0x3c>
      return -1;
    8000217c:	557d                	li	a0,-1
    8000217e:	bff1                	j	8000215a <growproc+0x3c>

0000000080002180 <kfork>:
{
    80002180:	715d                	addi	sp,sp,-80
    80002182:	e486                	sd	ra,72(sp)
    80002184:	e0a2                	sd	s0,64(sp)
    80002186:	fc26                	sd	s1,56(sp)
    80002188:	f84a                	sd	s2,48(sp)
    8000218a:	f44e                	sd	s3,40(sp)
    8000218c:	f052                	sd	s4,32(sp)
    8000218e:	ec56                	sd	s5,24(sp)
    80002190:	e85a                	sd	s6,16(sp)
    80002192:	e45e                	sd	s7,8(sp)
    80002194:	e062                	sd	s8,0(sp)
    80002196:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    80002198:	a27ff0ef          	jal	ra,80001bbe <myproc>
    8000219c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000219e:	e9fff0ef          	jal	ra,8000203c <allocproc>
    800021a2:	12050963          	beqz	a0,800022d4 <kfork+0x154>
    800021a6:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800021a8:	048ab603          	ld	a2,72(s5)
    800021ac:	692c                	ld	a1,80(a0)
    800021ae:	050ab503          	ld	a0,80(s5)
    800021b2:	af4ff0ef          	jal	ra,800014a6 <uvmcopy>
    800021b6:	04054863          	bltz	a0,80002206 <kfork+0x86>
  np->sz = p->sz;
    800021ba:	048ab783          	ld	a5,72(s5)
    800021be:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800021c2:	058ab683          	ld	a3,88(s5)
    800021c6:	87b6                	mv	a5,a3
    800021c8:	0589b703          	ld	a4,88(s3)
    800021cc:	12068693          	addi	a3,a3,288
    800021d0:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    800021d4:	6788                	ld	a0,8(a5)
    800021d6:	6b8c                	ld	a1,16(a5)
    800021d8:	6f90                	ld	a2,24(a5)
    800021da:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800021de:	e708                	sd	a0,8(a4)
    800021e0:	eb0c                	sd	a1,16(a4)
    800021e2:	ef10                	sd	a2,24(a4)
    800021e4:	02078793          	addi	a5,a5,32
    800021e8:	02070713          	addi	a4,a4,32
    800021ec:	fed792e3          	bne	a5,a3,800021d0 <kfork+0x50>
  np->trapframe->a0 = 0;
    800021f0:	0589b783          	ld	a5,88(s3)
    800021f4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800021f8:	0d0a8493          	addi	s1,s5,208
    800021fc:	0d098913          	addi	s2,s3,208
    80002200:	150a8a13          	addi	s4,s5,336
    80002204:	a829                	j	8000221e <kfork+0x9e>
    freeproc(np);
    80002206:	854e                	mv	a0,s3
    80002208:	dbfff0ef          	jal	ra,80001fc6 <freeproc>
    release(&np->lock);
    8000220c:	854e                	mv	a0,s3
    8000220e:	b49fe0ef          	jal	ra,80000d56 <release>
    return -1;
    80002212:	5c7d                	li	s8,-1
    80002214:	a05d                	j	800022ba <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    80002216:	04a1                	addi	s1,s1,8
    80002218:	0921                	addi	s2,s2,8
    8000221a:	01448963          	beq	s1,s4,8000222c <kfork+0xac>
    if(p->ofile[i])
    8000221e:	6088                	ld	a0,0(s1)
    80002220:	d97d                	beqz	a0,80002216 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    80002222:	263020ef          	jal	ra,80004c84 <filedup>
    80002226:	00a93023          	sd	a0,0(s2)
    8000222a:	b7f5                	j	80002216 <kfork+0x96>
  np->cwd = idup(p->cwd);
    8000222c:	150ab503          	ld	a0,336(s5)
    80002230:	479010ef          	jal	ra,80003ea8 <idup>
    80002234:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002238:	4641                	li	a2,16
    8000223a:	158a8593          	addi	a1,s5,344
    8000223e:	15898513          	addi	a0,s3,344
    80002242:	c97fe0ef          	jal	ra,80000ed8 <safestrcpy>
  pid = np->pid;
    80002246:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    8000224a:	854e                	mv	a0,s3
    8000224c:	b0bfe0ef          	jal	ra,80000d56 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    80002250:	16898b13          	addi	s6,s3,360
    80002254:	28000613          	li	a2,640
    80002258:	168a8593          	addi	a1,s5,360
    8000225c:	855a                	mv	a0,s6
    8000225e:	b91fe0ef          	jal	ra,80000dee <memmove>
    80002262:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    80002264:	4901                	li	s2,0
    80002266:	19098b93          	addi	s7,s3,400
    8000226a:	4a41                	li	s4,16
    8000226c:	a069                	j	800022f6 <kfork+0x176>
    for(int j = 0; j < i; j++){
    8000226e:	02878793          	addi	a5,a5,40
    80002272:	06d78363          	beq	a5,a3,800022d8 <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    80002276:	4398                	lw	a4,0(a5)
    80002278:	db7d                	beqz	a4,8000226e <kfork+0xee>
    8000227a:	5398                	lw	a4,32(a5)
    8000227c:	db6d                	beqz	a4,8000226e <kfork+0xee>
    8000227e:	53d8                	lw	a4,36(a5)
    80002280:	fea717e3          	bne	a4,a0,8000226e <kfork+0xee>
    80002284:	a0a5                	j	800022ec <kfork+0x16c>
        freeproc(np);
    80002286:	854e                	mv	a0,s3
    80002288:	d3fff0ef          	jal	ra,80001fc6 <freeproc>
        return -1;
    8000228c:	5c7d                	li	s8,-1
    8000228e:	a035                	j	800022ba <kfork+0x13a>
  acquire(&wait_lock);
    80002290:	0022e497          	auipc	s1,0x22e
    80002294:	79848493          	addi	s1,s1,1944 # 80230a28 <wait_lock>
    80002298:	8526                	mv	a0,s1
    8000229a:	a25fe0ef          	jal	ra,80000cbe <acquire>
  np->parent = p;
    8000229e:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	ab3fe0ef          	jal	ra,80000d56 <release>
  acquire(&np->lock);
    800022a8:	854e                	mv	a0,s3
    800022aa:	a15fe0ef          	jal	ra,80000cbe <acquire>
  np->state = RUNNABLE;
    800022ae:	478d                	li	a5,3
    800022b0:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800022b4:	854e                	mv	a0,s3
    800022b6:	aa1fe0ef          	jal	ra,80000d56 <release>
}
    800022ba:	8562                	mv	a0,s8
    800022bc:	60a6                	ld	ra,72(sp)
    800022be:	6406                	ld	s0,64(sp)
    800022c0:	74e2                	ld	s1,56(sp)
    800022c2:	7942                	ld	s2,48(sp)
    800022c4:	79a2                	ld	s3,40(sp)
    800022c6:	7a02                	ld	s4,32(sp)
    800022c8:	6ae2                	ld	s5,24(sp)
    800022ca:	6b42                	ld	s6,16(sp)
    800022cc:	6ba2                	ld	s7,8(sp)
    800022ce:	6c02                	ld	s8,0(sp)
    800022d0:	6161                	addi	sp,sp,80
    800022d2:	8082                	ret
    return -1;
    800022d4:	5c7d                	li	s8,-1
    800022d6:	b7d5                	j	800022ba <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    800022d8:	699c                	ld	a5,16(a1)
    800022da:	658c                	ld	a1,8(a1)
    800022dc:	40b785b3          	sub	a1,a5,a1
    800022e0:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    800022e2:	2581                	sext.w	a1,a1
    800022e4:	30c040ef          	jal	ra,800065f0 <shm_get>
    800022e8:	f8054fe3          	bltz	a0,80002286 <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    800022ec:	2905                	addiw	s2,s2,1
    800022ee:	02848493          	addi	s1,s1,40
    800022f2:	f9490fe3          	beq	s2,s4,80002290 <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    800022f6:	85a6                	mv	a1,s1
    800022f8:	409c                	lw	a5,0(s1)
    800022fa:	dbed                	beqz	a5,800022ec <kfork+0x16c>
    800022fc:	509c                	lw	a5,32(s1)
    800022fe:	d7fd                	beqz	a5,800022ec <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    80002300:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80002302:	fd205be3          	blez	s2,800022d8 <kfork+0x158>
    80002306:	fff9069b          	addiw	a3,s2,-1
    8000230a:	02069793          	slli	a5,a3,0x20
    8000230e:	9381                	srli	a5,a5,0x20
    80002310:	00279693          	slli	a3,a5,0x2
    80002314:	96be                	add	a3,a3,a5
    80002316:	068e                	slli	a3,a3,0x3
    80002318:	96de                	add	a3,a3,s7
    8000231a:	87da                	mv	a5,s6
    8000231c:	bfa9                	j	80002276 <kfork+0xf6>

000000008000231e <scheduler>:
{
    8000231e:	715d                	addi	sp,sp,-80
    80002320:	e486                	sd	ra,72(sp)
    80002322:	e0a2                	sd	s0,64(sp)
    80002324:	fc26                	sd	s1,56(sp)
    80002326:	f84a                	sd	s2,48(sp)
    80002328:	f44e                	sd	s3,40(sp)
    8000232a:	f052                	sd	s4,32(sp)
    8000232c:	ec56                	sd	s5,24(sp)
    8000232e:	e85a                	sd	s6,16(sp)
    80002330:	e45e                	sd	s7,8(sp)
    80002332:	e062                	sd	s8,0(sp)
    80002334:	0880                	addi	s0,sp,80
    80002336:	8792                	mv	a5,tp
  int id = r_tp();
    80002338:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000233a:	00779b13          	slli	s6,a5,0x7
    8000233e:	0022e717          	auipc	a4,0x22e
    80002342:	6d270713          	addi	a4,a4,1746 # 80230a10 <pid_lock>
    80002346:	975a                	add	a4,a4,s6
    80002348:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000234c:	0022e717          	auipc	a4,0x22e
    80002350:	6fc70713          	addi	a4,a4,1788 # 80230a48 <cpus+0x8>
    80002354:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002356:	4c11                	li	s8,4
        c->proc = p;
    80002358:	079e                	slli	a5,a5,0x7
    8000235a:	0022ea17          	auipc	s4,0x22e
    8000235e:	6b6a0a13          	addi	s4,s4,1718 # 80230a10 <pid_lock>
    80002362:	9a3e                	add	s4,s4,a5
        found = 1;
    80002364:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002366:	0023e997          	auipc	s3,0x23e
    8000236a:	4da98993          	addi	s3,s3,1242 # 80240840 <tickslock>
    8000236e:	a83d                	j	800023ac <scheduler+0x8e>
      release(&p->lock);
    80002370:	8526                	mv	a0,s1
    80002372:	9e5fe0ef          	jal	ra,80000d56 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002376:	3e848493          	addi	s1,s1,1000
    8000237a:	03348563          	beq	s1,s3,800023a4 <scheduler+0x86>
      acquire(&p->lock);
    8000237e:	8526                	mv	a0,s1
    80002380:	93ffe0ef          	jal	ra,80000cbe <acquire>
      if(p->state == RUNNABLE) {
    80002384:	4c9c                	lw	a5,24(s1)
    80002386:	ff2795e3          	bne	a5,s2,80002370 <scheduler+0x52>
        p->state = RUNNING;
    8000238a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000238e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002392:	06048593          	addi	a1,s1,96
    80002396:	855a                	mv	a0,s6
    80002398:	5b0000ef          	jal	ra,80002948 <swtch>
        c->proc = 0;
    8000239c:	020a3823          	sd	zero,48(s4)
        found = 1;
    800023a0:	8ade                	mv	s5,s7
    800023a2:	b7f9                	j	80002370 <scheduler+0x52>
    if(found == 0) {
    800023a4:	000a9463          	bnez	s5,800023ac <scheduler+0x8e>
      asm volatile("wfi");
    800023a8:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023b0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023b4:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023bc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023be:	10079073          	csrw	sstatus,a5
    int found = 0;
    800023c2:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800023c4:	0022f497          	auipc	s1,0x22f
    800023c8:	a7c48493          	addi	s1,s1,-1412 # 80230e40 <proc>
      if(p->state == RUNNABLE) {
    800023cc:	490d                	li	s2,3
    800023ce:	bf45                	j	8000237e <scheduler+0x60>

00000000800023d0 <sched>:
{
    800023d0:	7179                	addi	sp,sp,-48
    800023d2:	f406                	sd	ra,40(sp)
    800023d4:	f022                	sd	s0,32(sp)
    800023d6:	ec26                	sd	s1,24(sp)
    800023d8:	e84a                	sd	s2,16(sp)
    800023da:	e44e                	sd	s3,8(sp)
    800023dc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023de:	fe0ff0ef          	jal	ra,80001bbe <myproc>
    800023e2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023e4:	871fe0ef          	jal	ra,80000c54 <holding>
    800023e8:	c92d                	beqz	a0,8000245a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023ea:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023ec:	2781                	sext.w	a5,a5
    800023ee:	079e                	slli	a5,a5,0x7
    800023f0:	0022e717          	auipc	a4,0x22e
    800023f4:	62070713          	addi	a4,a4,1568 # 80230a10 <pid_lock>
    800023f8:	97ba                	add	a5,a5,a4
    800023fa:	0a87a703          	lw	a4,168(a5)
    800023fe:	4785                	li	a5,1
    80002400:	06f71363          	bne	a4,a5,80002466 <sched+0x96>
  if(p->state == RUNNING)
    80002404:	4c98                	lw	a4,24(s1)
    80002406:	4791                	li	a5,4
    80002408:	06f70563          	beq	a4,a5,80002472 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002410:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002412:	e7b5                	bnez	a5,8000247e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002414:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002416:	0022e917          	auipc	s2,0x22e
    8000241a:	5fa90913          	addi	s2,s2,1530 # 80230a10 <pid_lock>
    8000241e:	2781                	sext.w	a5,a5
    80002420:	079e                	slli	a5,a5,0x7
    80002422:	97ca                	add	a5,a5,s2
    80002424:	0ac7a983          	lw	s3,172(a5)
    80002428:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000242a:	2781                	sext.w	a5,a5
    8000242c:	079e                	slli	a5,a5,0x7
    8000242e:	0022e597          	auipc	a1,0x22e
    80002432:	61a58593          	addi	a1,a1,1562 # 80230a48 <cpus+0x8>
    80002436:	95be                	add	a1,a1,a5
    80002438:	06048513          	addi	a0,s1,96
    8000243c:	50c000ef          	jal	ra,80002948 <swtch>
    80002440:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002442:	2781                	sext.w	a5,a5
    80002444:	079e                	slli	a5,a5,0x7
    80002446:	97ca                	add	a5,a5,s2
    80002448:	0b37a623          	sw	s3,172(a5)
}
    8000244c:	70a2                	ld	ra,40(sp)
    8000244e:	7402                	ld	s0,32(sp)
    80002450:	64e2                	ld	s1,24(sp)
    80002452:	6942                	ld	s2,16(sp)
    80002454:	69a2                	ld	s3,8(sp)
    80002456:	6145                	addi	sp,sp,48
    80002458:	8082                	ret
    panic("sched p->lock");
    8000245a:	00006517          	auipc	a0,0x6
    8000245e:	d5e50513          	addi	a0,a0,-674 # 800081b8 <digits+0x180>
    80002462:	b28fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80002466:	00006517          	auipc	a0,0x6
    8000246a:	d6250513          	addi	a0,a0,-670 # 800081c8 <digits+0x190>
    8000246e:	b1cfe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80002472:	00006517          	auipc	a0,0x6
    80002476:	d6650513          	addi	a0,a0,-666 # 800081d8 <digits+0x1a0>
    8000247a:	b10fe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    8000247e:	00006517          	auipc	a0,0x6
    80002482:	d6a50513          	addi	a0,a0,-662 # 800081e8 <digits+0x1b0>
    80002486:	b04fe0ef          	jal	ra,8000078a <panic>

000000008000248a <yield>:
{
    8000248a:	1101                	addi	sp,sp,-32
    8000248c:	ec06                	sd	ra,24(sp)
    8000248e:	e822                	sd	s0,16(sp)
    80002490:	e426                	sd	s1,8(sp)
    80002492:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002494:	f2aff0ef          	jal	ra,80001bbe <myproc>
    80002498:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000249a:	825fe0ef          	jal	ra,80000cbe <acquire>
  p->state = RUNNABLE;
    8000249e:	478d                	li	a5,3
    800024a0:	cc9c                	sw	a5,24(s1)
  sched();
    800024a2:	f2fff0ef          	jal	ra,800023d0 <sched>
  release(&p->lock);
    800024a6:	8526                	mv	a0,s1
    800024a8:	8affe0ef          	jal	ra,80000d56 <release>
}
    800024ac:	60e2                	ld	ra,24(sp)
    800024ae:	6442                	ld	s0,16(sp)
    800024b0:	64a2                	ld	s1,8(sp)
    800024b2:	6105                	addi	sp,sp,32
    800024b4:	8082                	ret

00000000800024b6 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800024b6:	7179                	addi	sp,sp,-48
    800024b8:	f406                	sd	ra,40(sp)
    800024ba:	f022                	sd	s0,32(sp)
    800024bc:	ec26                	sd	s1,24(sp)
    800024be:	e84a                	sd	s2,16(sp)
    800024c0:	e44e                	sd	s3,8(sp)
    800024c2:	1800                	addi	s0,sp,48
    800024c4:	89aa                	mv	s3,a0
    800024c6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024c8:	ef6ff0ef          	jal	ra,80001bbe <myproc>
    800024cc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800024ce:	ff0fe0ef          	jal	ra,80000cbe <acquire>
  release(lk);
    800024d2:	854a                	mv	a0,s2
    800024d4:	883fe0ef          	jal	ra,80000d56 <release>

  // Go to sleep.
  p->chan = chan;
    800024d8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024dc:	4789                	li	a5,2
    800024de:	cc9c                	sw	a5,24(s1)

  sched();
    800024e0:	ef1ff0ef          	jal	ra,800023d0 <sched>

  // Tidy up.
  p->chan = 0;
    800024e4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024e8:	8526                	mv	a0,s1
    800024ea:	86dfe0ef          	jal	ra,80000d56 <release>
  acquire(lk);
    800024ee:	854a                	mv	a0,s2
    800024f0:	fcefe0ef          	jal	ra,80000cbe <acquire>
}
    800024f4:	70a2                	ld	ra,40(sp)
    800024f6:	7402                	ld	s0,32(sp)
    800024f8:	64e2                	ld	s1,24(sp)
    800024fa:	6942                	ld	s2,16(sp)
    800024fc:	69a2                	ld	s3,8(sp)
    800024fe:	6145                	addi	sp,sp,48
    80002500:	8082                	ret

0000000080002502 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002502:	7139                	addi	sp,sp,-64
    80002504:	fc06                	sd	ra,56(sp)
    80002506:	f822                	sd	s0,48(sp)
    80002508:	f426                	sd	s1,40(sp)
    8000250a:	f04a                	sd	s2,32(sp)
    8000250c:	ec4e                	sd	s3,24(sp)
    8000250e:	e852                	sd	s4,16(sp)
    80002510:	e456                	sd	s5,8(sp)
    80002512:	0080                	addi	s0,sp,64
    80002514:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002516:	0022f497          	auipc	s1,0x22f
    8000251a:	92a48493          	addi	s1,s1,-1750 # 80230e40 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000251e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002520:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002522:	0023e917          	auipc	s2,0x23e
    80002526:	31e90913          	addi	s2,s2,798 # 80240840 <tickslock>
    8000252a:	a801                	j	8000253a <wakeup+0x38>
      }
      release(&p->lock);
    8000252c:	8526                	mv	a0,s1
    8000252e:	829fe0ef          	jal	ra,80000d56 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002532:	3e848493          	addi	s1,s1,1000
    80002536:	03248263          	beq	s1,s2,8000255a <wakeup+0x58>
    if(p != myproc()){
    8000253a:	e84ff0ef          	jal	ra,80001bbe <myproc>
    8000253e:	fea48ae3          	beq	s1,a0,80002532 <wakeup+0x30>
      acquire(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	f7afe0ef          	jal	ra,80000cbe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002548:	4c9c                	lw	a5,24(s1)
    8000254a:	ff3791e3          	bne	a5,s3,8000252c <wakeup+0x2a>
    8000254e:	709c                	ld	a5,32(s1)
    80002550:	fd479ee3          	bne	a5,s4,8000252c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002554:	0154ac23          	sw	s5,24(s1)
    80002558:	bfd1                	j	8000252c <wakeup+0x2a>
    }
  }
}
    8000255a:	70e2                	ld	ra,56(sp)
    8000255c:	7442                	ld	s0,48(sp)
    8000255e:	74a2                	ld	s1,40(sp)
    80002560:	7902                	ld	s2,32(sp)
    80002562:	69e2                	ld	s3,24(sp)
    80002564:	6a42                	ld	s4,16(sp)
    80002566:	6aa2                	ld	s5,8(sp)
    80002568:	6121                	addi	sp,sp,64
    8000256a:	8082                	ret

000000008000256c <reparent>:
{
    8000256c:	7179                	addi	sp,sp,-48
    8000256e:	f406                	sd	ra,40(sp)
    80002570:	f022                	sd	s0,32(sp)
    80002572:	ec26                	sd	s1,24(sp)
    80002574:	e84a                	sd	s2,16(sp)
    80002576:	e44e                	sd	s3,8(sp)
    80002578:	e052                	sd	s4,0(sp)
    8000257a:	1800                	addi	s0,sp,48
    8000257c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000257e:	0022f497          	auipc	s1,0x22f
    80002582:	8c248493          	addi	s1,s1,-1854 # 80230e40 <proc>
      pp->parent = initproc;
    80002586:	00006a17          	auipc	s4,0x6
    8000258a:	33aa0a13          	addi	s4,s4,826 # 800088c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000258e:	0023e997          	auipc	s3,0x23e
    80002592:	2b298993          	addi	s3,s3,690 # 80240840 <tickslock>
    80002596:	a029                	j	800025a0 <reparent+0x34>
    80002598:	3e848493          	addi	s1,s1,1000
    8000259c:	01348b63          	beq	s1,s3,800025b2 <reparent+0x46>
    if(pp->parent == p){
    800025a0:	7c9c                	ld	a5,56(s1)
    800025a2:	ff279be3          	bne	a5,s2,80002598 <reparent+0x2c>
      pp->parent = initproc;
    800025a6:	000a3503          	ld	a0,0(s4)
    800025aa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025ac:	f57ff0ef          	jal	ra,80002502 <wakeup>
    800025b0:	b7e5                	j	80002598 <reparent+0x2c>
}
    800025b2:	70a2                	ld	ra,40(sp)
    800025b4:	7402                	ld	s0,32(sp)
    800025b6:	64e2                	ld	s1,24(sp)
    800025b8:	6942                	ld	s2,16(sp)
    800025ba:	69a2                	ld	s3,8(sp)
    800025bc:	6a02                	ld	s4,0(sp)
    800025be:	6145                	addi	sp,sp,48
    800025c0:	8082                	ret

00000000800025c2 <kexit>:
{
    800025c2:	7179                	addi	sp,sp,-48
    800025c4:	f406                	sd	ra,40(sp)
    800025c6:	f022                	sd	s0,32(sp)
    800025c8:	ec26                	sd	s1,24(sp)
    800025ca:	e84a                	sd	s2,16(sp)
    800025cc:	e44e                	sd	s3,8(sp)
    800025ce:	e052                	sd	s4,0(sp)
    800025d0:	1800                	addi	s0,sp,48
    800025d2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025d4:	deaff0ef          	jal	ra,80001bbe <myproc>
    800025d8:	89aa                	mv	s3,a0
  if(p == initproc)
    800025da:	00006797          	auipc	a5,0x6
    800025de:	2e67b783          	ld	a5,742(a5) # 800088c0 <initproc>
    800025e2:	0d050493          	addi	s1,a0,208
    800025e6:	15050913          	addi	s2,a0,336
    800025ea:	00a79f63          	bne	a5,a0,80002608 <kexit+0x46>
    panic("init exiting");
    800025ee:	00006517          	auipc	a0,0x6
    800025f2:	c1250513          	addi	a0,a0,-1006 # 80008200 <digits+0x1c8>
    800025f6:	994fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    800025fa:	6d0020ef          	jal	ra,80004cca <fileclose>
      p->ofile[fd] = 0;
    800025fe:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002602:	04a1                	addi	s1,s1,8
    80002604:	01248563          	beq	s1,s2,8000260e <kexit+0x4c>
    if(p->ofile[fd]){
    80002608:	6088                	ld	a0,0(s1)
    8000260a:	f965                	bnez	a0,800025fa <kexit+0x38>
    8000260c:	bfdd                	j	80002602 <kexit+0x40>
  begin_op();
    8000260e:	2ae020ef          	jal	ra,800048bc <begin_op>
  iput(p->cwd);
    80002612:	1509b503          	ld	a0,336(s3)
    80002616:	247010ef          	jal	ra,8000405c <iput>
  end_op();
    8000261a:	312020ef          	jal	ra,8000492c <end_op>
  p->cwd = 0;
    8000261e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002622:	0022e497          	auipc	s1,0x22e
    80002626:	40648493          	addi	s1,s1,1030 # 80230a28 <wait_lock>
    8000262a:	8526                	mv	a0,s1
    8000262c:	e92fe0ef          	jal	ra,80000cbe <acquire>
  reparent(p);
    80002630:	854e                	mv	a0,s3
    80002632:	f3bff0ef          	jal	ra,8000256c <reparent>
  wakeup(p->parent);
    80002636:	0389b503          	ld	a0,56(s3)
    8000263a:	ec9ff0ef          	jal	ra,80002502 <wakeup>
  acquire(&p->lock);
    8000263e:	854e                	mv	a0,s3
    80002640:	e7efe0ef          	jal	ra,80000cbe <acquire>
  p->xstate = status;
    80002644:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002648:	4795                	li	a5,5
    8000264a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	f06fe0ef          	jal	ra,80000d56 <release>
  sched();
    80002654:	d7dff0ef          	jal	ra,800023d0 <sched>
  panic("zombie exit");
    80002658:	00006517          	auipc	a0,0x6
    8000265c:	bb850513          	addi	a0,a0,-1096 # 80008210 <digits+0x1d8>
    80002660:	92afe0ef          	jal	ra,8000078a <panic>

0000000080002664 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002664:	7179                	addi	sp,sp,-48
    80002666:	f406                	sd	ra,40(sp)
    80002668:	f022                	sd	s0,32(sp)
    8000266a:	ec26                	sd	s1,24(sp)
    8000266c:	e84a                	sd	s2,16(sp)
    8000266e:	e44e                	sd	s3,8(sp)
    80002670:	1800                	addi	s0,sp,48
    80002672:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002674:	0022e497          	auipc	s1,0x22e
    80002678:	7cc48493          	addi	s1,s1,1996 # 80230e40 <proc>
    8000267c:	0023e997          	auipc	s3,0x23e
    80002680:	1c498993          	addi	s3,s3,452 # 80240840 <tickslock>
    acquire(&p->lock);
    80002684:	8526                	mv	a0,s1
    80002686:	e38fe0ef          	jal	ra,80000cbe <acquire>
    if(p->pid == pid){
    8000268a:	589c                	lw	a5,48(s1)
    8000268c:	01278b63          	beq	a5,s2,800026a2 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002690:	8526                	mv	a0,s1
    80002692:	ec4fe0ef          	jal	ra,80000d56 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002696:	3e848493          	addi	s1,s1,1000
    8000269a:	ff3495e3          	bne	s1,s3,80002684 <kkill+0x20>
  }
  return -1;
    8000269e:	557d                	li	a0,-1
    800026a0:	a819                	j	800026b6 <kkill+0x52>
      p->killed = 1;
    800026a2:	4785                	li	a5,1
    800026a4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800026a6:	4c98                	lw	a4,24(s1)
    800026a8:	4789                	li	a5,2
    800026aa:	00f70d63          	beq	a4,a5,800026c4 <kkill+0x60>
      release(&p->lock);
    800026ae:	8526                	mv	a0,s1
    800026b0:	ea6fe0ef          	jal	ra,80000d56 <release>
      return 0;
    800026b4:	4501                	li	a0,0
}
    800026b6:	70a2                	ld	ra,40(sp)
    800026b8:	7402                	ld	s0,32(sp)
    800026ba:	64e2                	ld	s1,24(sp)
    800026bc:	6942                	ld	s2,16(sp)
    800026be:	69a2                	ld	s3,8(sp)
    800026c0:	6145                	addi	sp,sp,48
    800026c2:	8082                	ret
        p->state = RUNNABLE;
    800026c4:	478d                	li	a5,3
    800026c6:	cc9c                	sw	a5,24(s1)
    800026c8:	b7dd                	j	800026ae <kkill+0x4a>

00000000800026ca <setkilled>:

void
setkilled(struct proc *p)
{
    800026ca:	1101                	addi	sp,sp,-32
    800026cc:	ec06                	sd	ra,24(sp)
    800026ce:	e822                	sd	s0,16(sp)
    800026d0:	e426                	sd	s1,8(sp)
    800026d2:	1000                	addi	s0,sp,32
    800026d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026d6:	de8fe0ef          	jal	ra,80000cbe <acquire>
  p->killed = 1;
    800026da:	4785                	li	a5,1
    800026dc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026de:	8526                	mv	a0,s1
    800026e0:	e76fe0ef          	jal	ra,80000d56 <release>
}
    800026e4:	60e2                	ld	ra,24(sp)
    800026e6:	6442                	ld	s0,16(sp)
    800026e8:	64a2                	ld	s1,8(sp)
    800026ea:	6105                	addi	sp,sp,32
    800026ec:	8082                	ret

00000000800026ee <killed>:

int
killed(struct proc *p)
{
    800026ee:	1101                	addi	sp,sp,-32
    800026f0:	ec06                	sd	ra,24(sp)
    800026f2:	e822                	sd	s0,16(sp)
    800026f4:	e426                	sd	s1,8(sp)
    800026f6:	e04a                	sd	s2,0(sp)
    800026f8:	1000                	addi	s0,sp,32
    800026fa:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800026fc:	dc2fe0ef          	jal	ra,80000cbe <acquire>
  k = p->killed;
    80002700:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002704:	8526                	mv	a0,s1
    80002706:	e50fe0ef          	jal	ra,80000d56 <release>
  return k;
}
    8000270a:	854a                	mv	a0,s2
    8000270c:	60e2                	ld	ra,24(sp)
    8000270e:	6442                	ld	s0,16(sp)
    80002710:	64a2                	ld	s1,8(sp)
    80002712:	6902                	ld	s2,0(sp)
    80002714:	6105                	addi	sp,sp,32
    80002716:	8082                	ret

0000000080002718 <kwait>:
{
    80002718:	715d                	addi	sp,sp,-80
    8000271a:	e486                	sd	ra,72(sp)
    8000271c:	e0a2                	sd	s0,64(sp)
    8000271e:	fc26                	sd	s1,56(sp)
    80002720:	f84a                	sd	s2,48(sp)
    80002722:	f44e                	sd	s3,40(sp)
    80002724:	f052                	sd	s4,32(sp)
    80002726:	ec56                	sd	s5,24(sp)
    80002728:	e85a                	sd	s6,16(sp)
    8000272a:	e45e                	sd	s7,8(sp)
    8000272c:	e062                	sd	s8,0(sp)
    8000272e:	0880                	addi	s0,sp,80
    80002730:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002732:	c8cff0ef          	jal	ra,80001bbe <myproc>
    80002736:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002738:	0022e517          	auipc	a0,0x22e
    8000273c:	2f050513          	addi	a0,a0,752 # 80230a28 <wait_lock>
    80002740:	d7efe0ef          	jal	ra,80000cbe <acquire>
    havekids = 0;
    80002744:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002746:	4a15                	li	s4,5
        havekids = 1;
    80002748:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000274a:	0023e997          	auipc	s3,0x23e
    8000274e:	0f698993          	addi	s3,s3,246 # 80240840 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002752:	0022ec17          	auipc	s8,0x22e
    80002756:	2d6c0c13          	addi	s8,s8,726 # 80230a28 <wait_lock>
    havekids = 0;
    8000275a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000275c:	0022e497          	auipc	s1,0x22e
    80002760:	6e448493          	addi	s1,s1,1764 # 80230e40 <proc>
    80002764:	a899                	j	800027ba <kwait+0xa2>
          pid = pp->pid;
    80002766:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000276a:	000b0c63          	beqz	s6,80002782 <kwait+0x6a>
    8000276e:	4691                	li	a3,4
    80002770:	02c48613          	addi	a2,s1,44
    80002774:	85da                	mv	a1,s6
    80002776:	05093503          	ld	a0,80(s2)
    8000277a:	834ff0ef          	jal	ra,800017ae <copyout>
    8000277e:	00054f63          	bltz	a0,8000279c <kwait+0x84>
          freeproc(pp);
    80002782:	8526                	mv	a0,s1
    80002784:	843ff0ef          	jal	ra,80001fc6 <freeproc>
          release(&pp->lock);
    80002788:	8526                	mv	a0,s1
    8000278a:	dccfe0ef          	jal	ra,80000d56 <release>
          release(&wait_lock);
    8000278e:	0022e517          	auipc	a0,0x22e
    80002792:	29a50513          	addi	a0,a0,666 # 80230a28 <wait_lock>
    80002796:	dc0fe0ef          	jal	ra,80000d56 <release>
          return pid;
    8000279a:	a891                	j	800027ee <kwait+0xd6>
            release(&pp->lock);
    8000279c:	8526                	mv	a0,s1
    8000279e:	db8fe0ef          	jal	ra,80000d56 <release>
            release(&wait_lock);
    800027a2:	0022e517          	auipc	a0,0x22e
    800027a6:	28650513          	addi	a0,a0,646 # 80230a28 <wait_lock>
    800027aa:	dacfe0ef          	jal	ra,80000d56 <release>
            return -1;
    800027ae:	59fd                	li	s3,-1
    800027b0:	a83d                	j	800027ee <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800027b2:	3e848493          	addi	s1,s1,1000
    800027b6:	03348063          	beq	s1,s3,800027d6 <kwait+0xbe>
      if(pp->parent == p){
    800027ba:	7c9c                	ld	a5,56(s1)
    800027bc:	ff279be3          	bne	a5,s2,800027b2 <kwait+0x9a>
        acquire(&pp->lock);
    800027c0:	8526                	mv	a0,s1
    800027c2:	cfcfe0ef          	jal	ra,80000cbe <acquire>
        if(pp->state == ZOMBIE){
    800027c6:	4c9c                	lw	a5,24(s1)
    800027c8:	f9478fe3          	beq	a5,s4,80002766 <kwait+0x4e>
        release(&pp->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	d88fe0ef          	jal	ra,80000d56 <release>
        havekids = 1;
    800027d2:	8756                	mv	a4,s5
    800027d4:	bff9                	j	800027b2 <kwait+0x9a>
    if(!havekids || killed(p)){
    800027d6:	c709                	beqz	a4,800027e0 <kwait+0xc8>
    800027d8:	854a                	mv	a0,s2
    800027da:	f15ff0ef          	jal	ra,800026ee <killed>
    800027de:	c50d                	beqz	a0,80002808 <kwait+0xf0>
      release(&wait_lock);
    800027e0:	0022e517          	auipc	a0,0x22e
    800027e4:	24850513          	addi	a0,a0,584 # 80230a28 <wait_lock>
    800027e8:	d6efe0ef          	jal	ra,80000d56 <release>
      return -1;
    800027ec:	59fd                	li	s3,-1
}
    800027ee:	854e                	mv	a0,s3
    800027f0:	60a6                	ld	ra,72(sp)
    800027f2:	6406                	ld	s0,64(sp)
    800027f4:	74e2                	ld	s1,56(sp)
    800027f6:	7942                	ld	s2,48(sp)
    800027f8:	79a2                	ld	s3,40(sp)
    800027fa:	7a02                	ld	s4,32(sp)
    800027fc:	6ae2                	ld	s5,24(sp)
    800027fe:	6b42                	ld	s6,16(sp)
    80002800:	6ba2                	ld	s7,8(sp)
    80002802:	6c02                	ld	s8,0(sp)
    80002804:	6161                	addi	sp,sp,80
    80002806:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002808:	85e2                	mv	a1,s8
    8000280a:	854a                	mv	a0,s2
    8000280c:	cabff0ef          	jal	ra,800024b6 <sleep>
    havekids = 0;
    80002810:	b7a9                	j	8000275a <kwait+0x42>

0000000080002812 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002812:	7179                	addi	sp,sp,-48
    80002814:	f406                	sd	ra,40(sp)
    80002816:	f022                	sd	s0,32(sp)
    80002818:	ec26                	sd	s1,24(sp)
    8000281a:	e84a                	sd	s2,16(sp)
    8000281c:	e44e                	sd	s3,8(sp)
    8000281e:	e052                	sd	s4,0(sp)
    80002820:	1800                	addi	s0,sp,48
    80002822:	84aa                	mv	s1,a0
    80002824:	892e                	mv	s2,a1
    80002826:	89b2                	mv	s3,a2
    80002828:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000282a:	b94ff0ef          	jal	ra,80001bbe <myproc>
  if(user_dst){
    8000282e:	cc99                	beqz	s1,8000284c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002830:	86d2                	mv	a3,s4
    80002832:	864e                	mv	a2,s3
    80002834:	85ca                	mv	a1,s2
    80002836:	6928                	ld	a0,80(a0)
    80002838:	f77fe0ef          	jal	ra,800017ae <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000283c:	70a2                	ld	ra,40(sp)
    8000283e:	7402                	ld	s0,32(sp)
    80002840:	64e2                	ld	s1,24(sp)
    80002842:	6942                	ld	s2,16(sp)
    80002844:	69a2                	ld	s3,8(sp)
    80002846:	6a02                	ld	s4,0(sp)
    80002848:	6145                	addi	sp,sp,48
    8000284a:	8082                	ret
    memmove((char *)dst, src, len);
    8000284c:	000a061b          	sext.w	a2,s4
    80002850:	85ce                	mv	a1,s3
    80002852:	854a                	mv	a0,s2
    80002854:	d9afe0ef          	jal	ra,80000dee <memmove>
    return 0;
    80002858:	8526                	mv	a0,s1
    8000285a:	b7cd                	j	8000283c <either_copyout+0x2a>

000000008000285c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000285c:	7179                	addi	sp,sp,-48
    8000285e:	f406                	sd	ra,40(sp)
    80002860:	f022                	sd	s0,32(sp)
    80002862:	ec26                	sd	s1,24(sp)
    80002864:	e84a                	sd	s2,16(sp)
    80002866:	e44e                	sd	s3,8(sp)
    80002868:	e052                	sd	s4,0(sp)
    8000286a:	1800                	addi	s0,sp,48
    8000286c:	892a                	mv	s2,a0
    8000286e:	84ae                	mv	s1,a1
    80002870:	89b2                	mv	s3,a2
    80002872:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002874:	b4aff0ef          	jal	ra,80001bbe <myproc>
  if(user_src){
    80002878:	cc99                	beqz	s1,80002896 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000287a:	86d2                	mv	a3,s4
    8000287c:	864e                	mv	a2,s3
    8000287e:	85ca                	mv	a1,s2
    80002880:	6928                	ld	a0,80(a0)
    80002882:	83cff0ef          	jal	ra,800018be <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002886:	70a2                	ld	ra,40(sp)
    80002888:	7402                	ld	s0,32(sp)
    8000288a:	64e2                	ld	s1,24(sp)
    8000288c:	6942                	ld	s2,16(sp)
    8000288e:	69a2                	ld	s3,8(sp)
    80002890:	6a02                	ld	s4,0(sp)
    80002892:	6145                	addi	sp,sp,48
    80002894:	8082                	ret
    memmove(dst, (char*)src, len);
    80002896:	000a061b          	sext.w	a2,s4
    8000289a:	85ce                	mv	a1,s3
    8000289c:	854a                	mv	a0,s2
    8000289e:	d50fe0ef          	jal	ra,80000dee <memmove>
    return 0;
    800028a2:	8526                	mv	a0,s1
    800028a4:	b7cd                	j	80002886 <either_copyin+0x2a>

00000000800028a6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800028a6:	715d                	addi	sp,sp,-80
    800028a8:	e486                	sd	ra,72(sp)
    800028aa:	e0a2                	sd	s0,64(sp)
    800028ac:	fc26                	sd	s1,56(sp)
    800028ae:	f84a                	sd	s2,48(sp)
    800028b0:	f44e                	sd	s3,40(sp)
    800028b2:	f052                	sd	s4,32(sp)
    800028b4:	ec56                	sd	s5,24(sp)
    800028b6:	e85a                	sd	s6,16(sp)
    800028b8:	e45e                	sd	s7,8(sp)
    800028ba:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800028bc:	00006517          	auipc	a0,0x6
    800028c0:	80c50513          	addi	a0,a0,-2036 # 800080c8 <digits+0x90>
    800028c4:	c01fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028c8:	0022e497          	auipc	s1,0x22e
    800028cc:	6d048493          	addi	s1,s1,1744 # 80230f98 <proc+0x158>
    800028d0:	0023e917          	auipc	s2,0x23e
    800028d4:	0c890913          	addi	s2,s2,200 # 80240998 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028d8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800028da:	00006997          	auipc	s3,0x6
    800028de:	94698993          	addi	s3,s3,-1722 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    800028e2:	00006a97          	auipc	s5,0x6
    800028e6:	946a8a93          	addi	s5,s5,-1722 # 80008228 <digits+0x1f0>
    printf("\n");
    800028ea:	00005a17          	auipc	s4,0x5
    800028ee:	7dea0a13          	addi	s4,s4,2014 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028f2:	00006b97          	auipc	s7,0x6
    800028f6:	976b8b93          	addi	s7,s7,-1674 # 80008268 <states.0>
    800028fa:	a829                	j	80002914 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800028fc:	ed86a583          	lw	a1,-296(a3)
    80002900:	8556                	mv	a0,s5
    80002902:	bc3fd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80002906:	8552                	mv	a0,s4
    80002908:	bbdfd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000290c:	3e848493          	addi	s1,s1,1000
    80002910:	03248163          	beq	s1,s2,80002932 <procdump+0x8c>
    if(p->state == UNUSED)
    80002914:	86a6                	mv	a3,s1
    80002916:	ec04a783          	lw	a5,-320(s1)
    8000291a:	dbed                	beqz	a5,8000290c <procdump+0x66>
      state = "???";
    8000291c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000291e:	fcfb6fe3          	bltu	s6,a5,800028fc <procdump+0x56>
    80002922:	1782                	slli	a5,a5,0x20
    80002924:	9381                	srli	a5,a5,0x20
    80002926:	078e                	slli	a5,a5,0x3
    80002928:	97de                	add	a5,a5,s7
    8000292a:	6390                	ld	a2,0(a5)
    8000292c:	fa61                	bnez	a2,800028fc <procdump+0x56>
      state = "???";
    8000292e:	864e                	mv	a2,s3
    80002930:	b7f1                	j	800028fc <procdump+0x56>
  }
}
    80002932:	60a6                	ld	ra,72(sp)
    80002934:	6406                	ld	s0,64(sp)
    80002936:	74e2                	ld	s1,56(sp)
    80002938:	7942                	ld	s2,48(sp)
    8000293a:	79a2                	ld	s3,40(sp)
    8000293c:	7a02                	ld	s4,32(sp)
    8000293e:	6ae2                	ld	s5,24(sp)
    80002940:	6b42                	ld	s6,16(sp)
    80002942:	6ba2                	ld	s7,8(sp)
    80002944:	6161                	addi	sp,sp,80
    80002946:	8082                	ret

0000000080002948 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002948:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000294c:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002950:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002952:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002954:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002958:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000295c:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002960:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002964:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002968:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000296c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002970:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002974:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002978:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000297c:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002980:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002984:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002986:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002988:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000298c:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002990:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002994:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002998:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000299c:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800029a0:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800029a4:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800029a8:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800029ac:	0685bd83          	ld	s11,104(a1)
        
        ret
    800029b0:	8082                	ret

00000000800029b2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029b2:	1141                	addi	sp,sp,-16
    800029b4:	e406                	sd	ra,8(sp)
    800029b6:	e022                	sd	s0,0(sp)
    800029b8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029ba:	00006597          	auipc	a1,0x6
    800029be:	8de58593          	addi	a1,a1,-1826 # 80008298 <states.0+0x30>
    800029c2:	0023e517          	auipc	a0,0x23e
    800029c6:	e7e50513          	addi	a0,a0,-386 # 80240840 <tickslock>
    800029ca:	a74fe0ef          	jal	ra,80000c3e <initlock>
}
    800029ce:	60a2                	ld	ra,8(sp)
    800029d0:	6402                	ld	s0,0(sp)
    800029d2:	0141                	addi	sp,sp,16
    800029d4:	8082                	ret

00000000800029d6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029d6:	1141                	addi	sp,sp,-16
    800029d8:	e422                	sd	s0,8(sp)
    800029da:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029dc:	00003797          	auipc	a5,0x3
    800029e0:	61478793          	addi	a5,a5,1556 # 80005ff0 <kernelvec>
    800029e4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029e8:	6422                	ld	s0,8(sp)
    800029ea:	0141                	addi	sp,sp,16
    800029ec:	8082                	ret

00000000800029ee <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029ee:	1141                	addi	sp,sp,-16
    800029f0:	e406                	sd	ra,8(sp)
    800029f2:	e022                	sd	s0,0(sp)
    800029f4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029f6:	9c8ff0ef          	jal	ra,80001bbe <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029fe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a00:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a04:	04000737          	lui	a4,0x4000
    80002a08:	00004797          	auipc	a5,0x4
    80002a0c:	5f878793          	addi	a5,a5,1528 # 80007000 <_trampoline>
    80002a10:	00004697          	auipc	a3,0x4
    80002a14:	5f068693          	addi	a3,a3,1520 # 80007000 <_trampoline>
    80002a18:	8f95                	sub	a5,a5,a3
    80002a1a:	177d                	addi	a4,a4,-1
    80002a1c:	0732                	slli	a4,a4,0xc
    80002a1e:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a20:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a24:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a26:	18002773          	csrr	a4,satp
    80002a2a:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a2c:	6d38                	ld	a4,88(a0)
    80002a2e:	613c                	ld	a5,64(a0)
    80002a30:	6685                	lui	a3,0x1
    80002a32:	97b6                	add	a5,a5,a3
    80002a34:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a36:	6d3c                	ld	a5,88(a0)
    80002a38:	00000717          	auipc	a4,0x0
    80002a3c:	0f470713          	addi	a4,a4,244 # 80002b2c <usertrap>
    80002a40:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a42:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a44:	8712                	mv	a4,tp
    80002a46:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a48:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a4c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a50:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a54:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a58:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a5a:	6f9c                	ld	a5,24(a5)
    80002a5c:	14179073          	csrw	sepc,a5
}
    80002a60:	60a2                	ld	ra,8(sp)
    80002a62:	6402                	ld	s0,0(sp)
    80002a64:	0141                	addi	sp,sp,16
    80002a66:	8082                	ret

0000000080002a68 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002a72:	920ff0ef          	jal	ra,80001b92 <cpuid>
    80002a76:	cd19                	beqz	a0,80002a94 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a78:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a7c:	000f4737          	lui	a4,0xf4
    80002a80:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a84:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a86:	14d79073          	csrw	0x14d,a5
}
    80002a8a:	60e2                	ld	ra,24(sp)
    80002a8c:	6442                	ld	s0,16(sp)
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret
    acquire(&tickslock);
    80002a94:	0023e497          	auipc	s1,0x23e
    80002a98:	dac48493          	addi	s1,s1,-596 # 80240840 <tickslock>
    80002a9c:	8526                	mv	a0,s1
    80002a9e:	a20fe0ef          	jal	ra,80000cbe <acquire>
    ticks++;
    80002aa2:	00006517          	auipc	a0,0x6
    80002aa6:	e2650513          	addi	a0,a0,-474 # 800088c8 <ticks>
    80002aaa:	411c                	lw	a5,0(a0)
    80002aac:	2785                	addiw	a5,a5,1
    80002aae:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002ab0:	a53ff0ef          	jal	ra,80002502 <wakeup>
    release(&tickslock);
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	aa0fe0ef          	jal	ra,80000d56 <release>
    80002aba:	bf7d                	j	80002a78 <clockintr+0x10>

0000000080002abc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002abc:	1101                	addi	sp,sp,-32
    80002abe:	ec06                	sd	ra,24(sp)
    80002ac0:	e822                	sd	s0,16(sp)
    80002ac2:	e426                	sd	s1,8(sp)
    80002ac4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002aca:	57fd                	li	a5,-1
    80002acc:	17fe                	slli	a5,a5,0x3f
    80002ace:	07a5                	addi	a5,a5,9
    80002ad0:	00f70d63          	beq	a4,a5,80002aea <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002ad4:	57fd                	li	a5,-1
    80002ad6:	17fe                	slli	a5,a5,0x3f
    80002ad8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002ada:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002adc:	04f70463          	beq	a4,a5,80002b24 <devintr+0x68>
  }
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret
    int irq = plic_claim();
    80002aea:	5ae030ef          	jal	ra,80006098 <plic_claim>
    80002aee:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002af0:	47a9                	li	a5,10
    80002af2:	02f50363          	beq	a0,a5,80002b18 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002af6:	4785                	li	a5,1
    80002af8:	02f50363          	beq	a0,a5,80002b1e <devintr+0x62>
    return 1;
    80002afc:	4505                	li	a0,1
    } else if(irq){
    80002afe:	d0ed                	beqz	s1,80002ae0 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b00:	85a6                	mv	a1,s1
    80002b02:	00005517          	auipc	a0,0x5
    80002b06:	79e50513          	addi	a0,a0,1950 # 800082a0 <states.0+0x38>
    80002b0a:	9bbfd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002b0e:	8526                	mv	a0,s1
    80002b10:	5a8030ef          	jal	ra,800060b8 <plic_complete>
    return 1;
    80002b14:	4505                	li	a0,1
    80002b16:	b7e9                	j	80002ae0 <devintr+0x24>
      uartintr();
    80002b18:	e41fd0ef          	jal	ra,80000958 <uartintr>
    80002b1c:	bfcd                	j	80002b0e <devintr+0x52>
      virtio_disk_intr();
    80002b1e:	20b030ef          	jal	ra,80006528 <virtio_disk_intr>
    80002b22:	b7f5                	j	80002b0e <devintr+0x52>
    clockintr();
    80002b24:	f45ff0ef          	jal	ra,80002a68 <clockintr>
    return 2;
    80002b28:	4509                	li	a0,2
    80002b2a:	bf5d                	j	80002ae0 <devintr+0x24>

0000000080002b2c <usertrap>:
{
    80002b2c:	7179                	addi	sp,sp,-48
    80002b2e:	f406                	sd	ra,40(sp)
    80002b30:	f022                	sd	s0,32(sp)
    80002b32:	ec26                	sd	s1,24(sp)
    80002b34:	e84a                	sd	s2,16(sp)
    80002b36:	e44e                	sd	s3,8(sp)
    80002b38:	e052                	sd	s4,0(sp)
    80002b3a:	1800                	addi	s0,sp,48
    80002b3c:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b40:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b44:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b48:	1007f793          	andi	a5,a5,256
    80002b4c:	e3bd                	bnez	a5,80002bb2 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b4e:	00003797          	auipc	a5,0x3
    80002b52:	4a278793          	addi	a5,a5,1186 # 80005ff0 <kernelvec>
    80002b56:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b5a:	864ff0ef          	jal	ra,80001bbe <myproc>
    80002b5e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b60:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b62:	14102773          	csrr	a4,sepc
    80002b66:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b68:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b6c:	47a1                	li	a5,8
    80002b6e:	04f70863          	beq	a4,a5,80002bbe <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002b72:	f4bff0ef          	jal	ra,80002abc <devintr>
    80002b76:	892a                	mv	s2,a0
    80002b78:	0c051e63          	bnez	a0,80002c54 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002b7c:	47b5                	li	a5,13
    80002b7e:	08f98663          	beq	s3,a5,80002c0a <usertrap+0xde>
    80002b82:	47bd                	li	a5,15
    80002b84:	0af99363          	bne	s3,a5,80002c2a <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002b88:	85d2                	mv	a1,s4
    80002b8a:	68a8                	ld	a0,80(s1)
    80002b8c:	9f1fe0ef          	jal	ra,8000157c <cowbreak>
    80002b90:	c531                	beqz	a0,80002bdc <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002b92:	4605                	li	a2,1
    80002b94:	85d2                	mv	a1,s4
    80002b96:	8526                	mv	a0,s1
    80002b98:	dcbfe0ef          	jal	ra,80001962 <vmafault>
    80002b9c:	e121                	bnez	a0,80002bdc <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002b9e:	4601                	li	a2,0
    80002ba0:	85d2                	mv	a1,s4
    80002ba2:	68a8                	ld	a0,80(s1)
    80002ba4:	b99fe0ef          	jal	ra,8000173c <vmfault>
    80002ba8:	e915                	bnez	a0,80002bdc <usertrap+0xb0>
        setkilled(p);
    80002baa:	8526                	mv	a0,s1
    80002bac:	b1fff0ef          	jal	ra,800026ca <setkilled>
    80002bb0:	a035                	j	80002bdc <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002bb2:	00005517          	auipc	a0,0x5
    80002bb6:	70e50513          	addi	a0,a0,1806 # 800082c0 <states.0+0x58>
    80002bba:	bd1fd0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002bbe:	b31ff0ef          	jal	ra,800026ee <killed>
    80002bc2:	e121                	bnez	a0,80002c02 <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002bc4:	6cb8                	ld	a4,88(s1)
    80002bc6:	6f1c                	ld	a5,24(a4)
    80002bc8:	0791                	addi	a5,a5,4
    80002bca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bcc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bd0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bd4:	10079073          	csrw	sstatus,a5
    syscall();
    80002bd8:	27c000ef          	jal	ra,80002e54 <syscall>
  if(killed(p))
    80002bdc:	8526                	mv	a0,s1
    80002bde:	b11ff0ef          	jal	ra,800026ee <killed>
    80002be2:	ed35                	bnez	a0,80002c5e <usertrap+0x132>
  prepare_return();
    80002be4:	e0bff0ef          	jal	ra,800029ee <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002be8:	68a8                	ld	a0,80(s1)
    80002bea:	8131                	srli	a0,a0,0xc
    80002bec:	57fd                	li	a5,-1
    80002bee:	17fe                	slli	a5,a5,0x3f
    80002bf0:	8d5d                	or	a0,a0,a5
}
    80002bf2:	70a2                	ld	ra,40(sp)
    80002bf4:	7402                	ld	s0,32(sp)
    80002bf6:	64e2                	ld	s1,24(sp)
    80002bf8:	6942                	ld	s2,16(sp)
    80002bfa:	69a2                	ld	s3,8(sp)
    80002bfc:	6a02                	ld	s4,0(sp)
    80002bfe:	6145                	addi	sp,sp,48
    80002c00:	8082                	ret
      kexit(-1);
    80002c02:	557d                	li	a0,-1
    80002c04:	9bfff0ef          	jal	ra,800025c2 <kexit>
    80002c08:	bf75                	j	80002bc4 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002c0a:	4601                	li	a2,0
    80002c0c:	85d2                	mv	a1,s4
    80002c0e:	8526                	mv	a0,s1
    80002c10:	d53fe0ef          	jal	ra,80001962 <vmafault>
    80002c14:	f561                	bnez	a0,80002bdc <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002c16:	4605                	li	a2,1
    80002c18:	85d2                	mv	a1,s4
    80002c1a:	68a8                	ld	a0,80(s1)
    80002c1c:	b21fe0ef          	jal	ra,8000173c <vmfault>
    80002c20:	fd55                	bnez	a0,80002bdc <usertrap+0xb0>
        setkilled(p);
    80002c22:	8526                	mv	a0,s1
    80002c24:	aa7ff0ef          	jal	ra,800026ca <setkilled>
    80002c28:	bf55                	j	80002bdc <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002c2a:	5890                	lw	a2,48(s1)
    80002c2c:	85ce                	mv	a1,s3
    80002c2e:	00005517          	auipc	a0,0x5
    80002c32:	6b250513          	addi	a0,a0,1714 # 800082e0 <states.0+0x78>
    80002c36:	88ffd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c3a:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002c3e:	8652                	mv	a2,s4
    80002c40:	00005517          	auipc	a0,0x5
    80002c44:	6d050513          	addi	a0,a0,1744 # 80008310 <states.0+0xa8>
    80002c48:	87dfd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002c4c:	8526                	mv	a0,s1
    80002c4e:	a7dff0ef          	jal	ra,800026ca <setkilled>
    80002c52:	b769                	j	80002bdc <usertrap+0xb0>
  if(killed(p))
    80002c54:	8526                	mv	a0,s1
    80002c56:	a99ff0ef          	jal	ra,800026ee <killed>
    80002c5a:	c511                	beqz	a0,80002c66 <usertrap+0x13a>
    80002c5c:	a011                	j	80002c60 <usertrap+0x134>
    80002c5e:	4901                	li	s2,0
    kexit(-1);
    80002c60:	557d                	li	a0,-1
    80002c62:	961ff0ef          	jal	ra,800025c2 <kexit>
  if(which_dev == 2)
    80002c66:	4789                	li	a5,2
    80002c68:	f6f91ee3          	bne	s2,a5,80002be4 <usertrap+0xb8>
    yield();
    80002c6c:	81fff0ef          	jal	ra,8000248a <yield>
    80002c70:	bf95                	j	80002be4 <usertrap+0xb8>

0000000080002c72 <kerneltrap>:
{
    80002c72:	7179                	addi	sp,sp,-48
    80002c74:	f406                	sd	ra,40(sp)
    80002c76:	f022                	sd	s0,32(sp)
    80002c78:	ec26                	sd	s1,24(sp)
    80002c7a:	e84a                	sd	s2,16(sp)
    80002c7c:	e44e                	sd	s3,8(sp)
    80002c7e:	1800                	addi	s0,sp,48
    80002c80:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c84:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c88:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c8c:	1004f793          	andi	a5,s1,256
    80002c90:	c795                	beqz	a5,80002cbc <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c92:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c96:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c98:	eb85                	bnez	a5,80002cc8 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002c9a:	e23ff0ef          	jal	ra,80002abc <devintr>
    80002c9e:	c91d                	beqz	a0,80002cd4 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002ca0:	4789                	li	a5,2
    80002ca2:	04f50a63          	beq	a0,a5,80002cf6 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ca6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002caa:	10049073          	csrw	sstatus,s1
}
    80002cae:	70a2                	ld	ra,40(sp)
    80002cb0:	7402                	ld	s0,32(sp)
    80002cb2:	64e2                	ld	s1,24(sp)
    80002cb4:	6942                	ld	s2,16(sp)
    80002cb6:	69a2                	ld	s3,8(sp)
    80002cb8:	6145                	addi	sp,sp,48
    80002cba:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cbc:	00005517          	auipc	a0,0x5
    80002cc0:	67c50513          	addi	a0,a0,1660 # 80008338 <states.0+0xd0>
    80002cc4:	ac7fd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002cc8:	00005517          	auipc	a0,0x5
    80002ccc:	69850513          	addi	a0,a0,1688 # 80008360 <states.0+0xf8>
    80002cd0:	abbfd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cd8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002cdc:	85ce                	mv	a1,s3
    80002cde:	00005517          	auipc	a0,0x5
    80002ce2:	6a250513          	addi	a0,a0,1698 # 80008380 <states.0+0x118>
    80002ce6:	fdefd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002cea:	00005517          	auipc	a0,0x5
    80002cee:	6be50513          	addi	a0,a0,1726 # 800083a8 <states.0+0x140>
    80002cf2:	a99fd0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002cf6:	ec9fe0ef          	jal	ra,80001bbe <myproc>
    80002cfa:	d555                	beqz	a0,80002ca6 <kerneltrap+0x34>
    yield();
    80002cfc:	f8eff0ef          	jal	ra,8000248a <yield>
    80002d00:	b75d                	j	80002ca6 <kerneltrap+0x34>

0000000080002d02 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d02:	1101                	addi	sp,sp,-32
    80002d04:	ec06                	sd	ra,24(sp)
    80002d06:	e822                	sd	s0,16(sp)
    80002d08:	e426                	sd	s1,8(sp)
    80002d0a:	1000                	addi	s0,sp,32
    80002d0c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d0e:	eb1fe0ef          	jal	ra,80001bbe <myproc>
  switch (n) {
    80002d12:	4795                	li	a5,5
    80002d14:	0497e163          	bltu	a5,s1,80002d56 <argraw+0x54>
    80002d18:	048a                	slli	s1,s1,0x2
    80002d1a:	00005717          	auipc	a4,0x5
    80002d1e:	6c670713          	addi	a4,a4,1734 # 800083e0 <states.0+0x178>
    80002d22:	94ba                	add	s1,s1,a4
    80002d24:	409c                	lw	a5,0(s1)
    80002d26:	97ba                	add	a5,a5,a4
    80002d28:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d2a:	6d3c                	ld	a5,88(a0)
    80002d2c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d2e:	60e2                	ld	ra,24(sp)
    80002d30:	6442                	ld	s0,16(sp)
    80002d32:	64a2                	ld	s1,8(sp)
    80002d34:	6105                	addi	sp,sp,32
    80002d36:	8082                	ret
    return p->trapframe->a1;
    80002d38:	6d3c                	ld	a5,88(a0)
    80002d3a:	7fa8                	ld	a0,120(a5)
    80002d3c:	bfcd                	j	80002d2e <argraw+0x2c>
    return p->trapframe->a2;
    80002d3e:	6d3c                	ld	a5,88(a0)
    80002d40:	63c8                	ld	a0,128(a5)
    80002d42:	b7f5                	j	80002d2e <argraw+0x2c>
    return p->trapframe->a3;
    80002d44:	6d3c                	ld	a5,88(a0)
    80002d46:	67c8                	ld	a0,136(a5)
    80002d48:	b7dd                	j	80002d2e <argraw+0x2c>
    return p->trapframe->a4;
    80002d4a:	6d3c                	ld	a5,88(a0)
    80002d4c:	6bc8                	ld	a0,144(a5)
    80002d4e:	b7c5                	j	80002d2e <argraw+0x2c>
    return p->trapframe->a5;
    80002d50:	6d3c                	ld	a5,88(a0)
    80002d52:	6fc8                	ld	a0,152(a5)
    80002d54:	bfe9                	j	80002d2e <argraw+0x2c>
  panic("argraw");
    80002d56:	00005517          	auipc	a0,0x5
    80002d5a:	66250513          	addi	a0,a0,1634 # 800083b8 <states.0+0x150>
    80002d5e:	a2dfd0ef          	jal	ra,8000078a <panic>

0000000080002d62 <fetchaddr>:
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	e04a                	sd	s2,0(sp)
    80002d6c:	1000                	addi	s0,sp,32
    80002d6e:	84aa                	mv	s1,a0
    80002d70:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d72:	e4dfe0ef          	jal	ra,80001bbe <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d76:	653c                	ld	a5,72(a0)
    80002d78:	02f4f663          	bgeu	s1,a5,80002da4 <fetchaddr+0x42>
    80002d7c:	00848713          	addi	a4,s1,8
    80002d80:	02e7e463          	bltu	a5,a4,80002da8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d84:	46a1                	li	a3,8
    80002d86:	8626                	mv	a2,s1
    80002d88:	85ca                	mv	a1,s2
    80002d8a:	6928                	ld	a0,80(a0)
    80002d8c:	b33fe0ef          	jal	ra,800018be <copyin>
    80002d90:	00a03533          	snez	a0,a0
    80002d94:	40a00533          	neg	a0,a0
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6902                	ld	s2,0(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret
    return -1;
    80002da4:	557d                	li	a0,-1
    80002da6:	bfcd                	j	80002d98 <fetchaddr+0x36>
    80002da8:	557d                	li	a0,-1
    80002daa:	b7fd                	j	80002d98 <fetchaddr+0x36>

0000000080002dac <fetchstr>:
{
    80002dac:	7179                	addi	sp,sp,-48
    80002dae:	f406                	sd	ra,40(sp)
    80002db0:	f022                	sd	s0,32(sp)
    80002db2:	ec26                	sd	s1,24(sp)
    80002db4:	e84a                	sd	s2,16(sp)
    80002db6:	e44e                	sd	s3,8(sp)
    80002db8:	1800                	addi	s0,sp,48
    80002dba:	892a                	mv	s2,a0
    80002dbc:	84ae                	mv	s1,a1
    80002dbe:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dc0:	dfffe0ef          	jal	ra,80001bbe <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002dc4:	86ce                	mv	a3,s3
    80002dc6:	864a                	mv	a2,s2
    80002dc8:	85a6                	mv	a1,s1
    80002dca:	6928                	ld	a0,80(a0)
    80002dcc:	8a1fe0ef          	jal	ra,8000166c <copyinstr>
    80002dd0:	00054c63          	bltz	a0,80002de8 <fetchstr+0x3c>
  return strlen(buf);
    80002dd4:	8526                	mv	a0,s1
    80002dd6:	934fe0ef          	jal	ra,80000f0a <strlen>
}
    80002dda:	70a2                	ld	ra,40(sp)
    80002ddc:	7402                	ld	s0,32(sp)
    80002dde:	64e2                	ld	s1,24(sp)
    80002de0:	6942                	ld	s2,16(sp)
    80002de2:	69a2                	ld	s3,8(sp)
    80002de4:	6145                	addi	sp,sp,48
    80002de6:	8082                	ret
    return -1;
    80002de8:	557d                	li	a0,-1
    80002dea:	bfc5                	j	80002dda <fetchstr+0x2e>

0000000080002dec <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dec:	1101                	addi	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	e426                	sd	s1,8(sp)
    80002df4:	1000                	addi	s0,sp,32
    80002df6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df8:	f0bff0ef          	jal	ra,80002d02 <argraw>
    80002dfc:	c088                	sw	a0,0(s1)
}
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	64a2                	ld	s1,8(sp)
    80002e04:	6105                	addi	sp,sp,32
    80002e06:	8082                	ret

0000000080002e08 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e08:	1101                	addi	sp,sp,-32
    80002e0a:	ec06                	sd	ra,24(sp)
    80002e0c:	e822                	sd	s0,16(sp)
    80002e0e:	e426                	sd	s1,8(sp)
    80002e10:	1000                	addi	s0,sp,32
    80002e12:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e14:	eefff0ef          	jal	ra,80002d02 <argraw>
    80002e18:	e088                	sd	a0,0(s1)
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	64a2                	ld	s1,8(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e24:	7179                	addi	sp,sp,-48
    80002e26:	f406                	sd	ra,40(sp)
    80002e28:	f022                	sd	s0,32(sp)
    80002e2a:	ec26                	sd	s1,24(sp)
    80002e2c:	e84a                	sd	s2,16(sp)
    80002e2e:	1800                	addi	s0,sp,48
    80002e30:	84ae                	mv	s1,a1
    80002e32:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e34:	fd840593          	addi	a1,s0,-40
    80002e38:	fd1ff0ef          	jal	ra,80002e08 <argaddr>
  return fetchstr(addr, buf, max);
    80002e3c:	864a                	mv	a2,s2
    80002e3e:	85a6                	mv	a1,s1
    80002e40:	fd843503          	ld	a0,-40(s0)
    80002e44:	f69ff0ef          	jal	ra,80002dac <fetchstr>
}
    80002e48:	70a2                	ld	ra,40(sp)
    80002e4a:	7402                	ld	s0,32(sp)
    80002e4c:	64e2                	ld	s1,24(sp)
    80002e4e:	6942                	ld	s2,16(sp)
    80002e50:	6145                	addi	sp,sp,48
    80002e52:	8082                	ret

0000000080002e54 <syscall>:
[SYS_vmstats]    sys_vmstats,
};

void
syscall(void)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	e04a                	sd	s2,0(sp)
    80002e5e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e60:	d5ffe0ef          	jal	ra,80001bbe <myproc>
    80002e64:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e66:	05853903          	ld	s2,88(a0)
    80002e6a:	0a893783          	ld	a5,168(s2)
    80002e6e:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e72:	37fd                	addiw	a5,a5,-1
    80002e74:	4771                	li	a4,28
    80002e76:	00f76f63          	bltu	a4,a5,80002e94 <syscall+0x40>
    80002e7a:	00369713          	slli	a4,a3,0x3
    80002e7e:	00005797          	auipc	a5,0x5
    80002e82:	57a78793          	addi	a5,a5,1402 # 800083f8 <syscalls>
    80002e86:	97ba                	add	a5,a5,a4
    80002e88:	639c                	ld	a5,0(a5)
    80002e8a:	c789                	beqz	a5,80002e94 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e8c:	9782                	jalr	a5
    80002e8e:	06a93823          	sd	a0,112(s2)
    80002e92:	a829                	j	80002eac <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e94:	15848613          	addi	a2,s1,344
    80002e98:	588c                	lw	a1,48(s1)
    80002e9a:	00005517          	auipc	a0,0x5
    80002e9e:	52650513          	addi	a0,a0,1318 # 800083c0 <states.0+0x158>
    80002ea2:	e22fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ea6:	6cbc                	ld	a5,88(s1)
    80002ea8:	577d                	li	a4,-1
    80002eaa:	fbb8                	sd	a4,112(a5)
  }
}
    80002eac:	60e2                	ld	ra,24(sp)
    80002eae:	6442                	ld	s0,16(sp)
    80002eb0:	64a2                	ld	s1,8(sp)
    80002eb2:	6902                	ld	s2,0(sp)
    80002eb4:	6105                	addi	sp,sp,32
    80002eb6:	8082                	ret

0000000080002eb8 <proc_has_shm_key>:
 * 用途：
 *   用于判断进程是否还有其他VMA引用同一个共享内存对象
 */
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002eb8:	1141                	addi	sp,sp,-16
    80002eba:	e422                	sd	s0,8(sp)
    80002ebc:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002ebe:	16850793          	addi	a5,a0,360
    80002ec2:	3e850513          	addi	a0,a0,1000
    80002ec6:	a029                	j	80002ed0 <proc_has_shm_key+0x18>
    80002ec8:	02878793          	addi	a5,a5,40
    80002ecc:	00a78d63          	beq	a5,a0,80002ee6 <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002ed0:	fef60ce3          	beq	a2,a5,80002ec8 <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002ed4:	4398                	lw	a4,0(a5)
    80002ed6:	db6d                	beqz	a4,80002ec8 <proc_has_shm_key+0x10>
    80002ed8:	5398                	lw	a4,32(a5)
    80002eda:	d77d                	beqz	a4,80002ec8 <proc_has_shm_key+0x10>
    80002edc:	53d8                	lw	a4,36(a5)
    80002ede:	feb715e3          	bne	a4,a1,80002ec8 <proc_has_shm_key+0x10>
      return 1;
    80002ee2:	4505                	li	a0,1
    80002ee4:	a011                	j	80002ee8 <proc_has_shm_key+0x30>
  }
  return 0;
    80002ee6:	4501                	li	a0,0
}
    80002ee8:	6422                	ld	s0,8(sp)
    80002eea:	0141                	addi	sp,sp,16
    80002eec:	8082                	ret

0000000080002eee <sys_exit>:
{
    80002eee:	1101                	addi	sp,sp,-32
    80002ef0:	ec06                	sd	ra,24(sp)
    80002ef2:	e822                	sd	s0,16(sp)
    80002ef4:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002ef6:	fec40593          	addi	a1,s0,-20
    80002efa:	4501                	li	a0,0
    80002efc:	ef1ff0ef          	jal	ra,80002dec <argint>
  kexit(n);
    80002f00:	fec42503          	lw	a0,-20(s0)
    80002f04:	ebeff0ef          	jal	ra,800025c2 <kexit>
}
    80002f08:	4501                	li	a0,0
    80002f0a:	60e2                	ld	ra,24(sp)
    80002f0c:	6442                	ld	s0,16(sp)
    80002f0e:	6105                	addi	sp,sp,32
    80002f10:	8082                	ret

0000000080002f12 <sys_getpid>:
{
    80002f12:	1141                	addi	sp,sp,-16
    80002f14:	e406                	sd	ra,8(sp)
    80002f16:	e022                	sd	s0,0(sp)
    80002f18:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f1a:	ca5fe0ef          	jal	ra,80001bbe <myproc>
}
    80002f1e:	5908                	lw	a0,48(a0)
    80002f20:	60a2                	ld	ra,8(sp)
    80002f22:	6402                	ld	s0,0(sp)
    80002f24:	0141                	addi	sp,sp,16
    80002f26:	8082                	ret

0000000080002f28 <sys_fork>:
{
    80002f28:	1141                	addi	sp,sp,-16
    80002f2a:	e406                	sd	ra,8(sp)
    80002f2c:	e022                	sd	s0,0(sp)
    80002f2e:	0800                	addi	s0,sp,16
  return kfork();
    80002f30:	a50ff0ef          	jal	ra,80002180 <kfork>
}
    80002f34:	60a2                	ld	ra,8(sp)
    80002f36:	6402                	ld	s0,0(sp)
    80002f38:	0141                	addi	sp,sp,16
    80002f3a:	8082                	ret

0000000080002f3c <sys_wait>:
{
    80002f3c:	1101                	addi	sp,sp,-32
    80002f3e:	ec06                	sd	ra,24(sp)
    80002f40:	e822                	sd	s0,16(sp)
    80002f42:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002f44:	fe840593          	addi	a1,s0,-24
    80002f48:	4501                	li	a0,0
    80002f4a:	ebfff0ef          	jal	ra,80002e08 <argaddr>
  return kwait(p);
    80002f4e:	fe843503          	ld	a0,-24(s0)
    80002f52:	fc6ff0ef          	jal	ra,80002718 <kwait>
}
    80002f56:	60e2                	ld	ra,24(sp)
    80002f58:	6442                	ld	s0,16(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <sys_sbrk>:
{
    80002f5e:	7179                	addi	sp,sp,-48
    80002f60:	f406                	sd	ra,40(sp)
    80002f62:	f022                	sd	s0,32(sp)
    80002f64:	ec26                	sd	s1,24(sp)
    80002f66:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002f68:	fd840593          	addi	a1,s0,-40
    80002f6c:	4501                	li	a0,0
    80002f6e:	e7fff0ef          	jal	ra,80002dec <argint>
  argint(1, &t);
    80002f72:	fdc40593          	addi	a1,s0,-36
    80002f76:	4505                	li	a0,1
    80002f78:	e75ff0ef          	jal	ra,80002dec <argint>
  addr = myproc()->sz;
    80002f7c:	c43fe0ef          	jal	ra,80001bbe <myproc>
    80002f80:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002f82:	fdc42703          	lw	a4,-36(s0)
    80002f86:	4785                	li	a5,1
    80002f88:	02f70763          	beq	a4,a5,80002fb6 <sys_sbrk+0x58>
    80002f8c:	fd842783          	lw	a5,-40(s0)
    80002f90:	0207c363          	bltz	a5,80002fb6 <sys_sbrk+0x58>
    if(addr + n < addr)
    80002f94:	97a6                	add	a5,a5,s1
    80002f96:	0297ee63          	bltu	a5,s1,80002fd2 <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002f9a:	02000737          	lui	a4,0x2000
    80002f9e:	177d                	addi	a4,a4,-1
    80002fa0:	0736                	slli	a4,a4,0xd
    80002fa2:	02f76a63          	bltu	a4,a5,80002fd6 <sys_sbrk+0x78>
    myproc()->sz += n;
    80002fa6:	c19fe0ef          	jal	ra,80001bbe <myproc>
    80002faa:	fd842703          	lw	a4,-40(s0)
    80002fae:	653c                	ld	a5,72(a0)
    80002fb0:	97ba                	add	a5,a5,a4
    80002fb2:	e53c                	sd	a5,72(a0)
    80002fb4:	a039                	j	80002fc2 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002fb6:	fd842503          	lw	a0,-40(s0)
    80002fba:	964ff0ef          	jal	ra,8000211e <growproc>
    80002fbe:	00054863          	bltz	a0,80002fce <sys_sbrk+0x70>
}
    80002fc2:	8526                	mv	a0,s1
    80002fc4:	70a2                	ld	ra,40(sp)
    80002fc6:	7402                	ld	s0,32(sp)
    80002fc8:	64e2                	ld	s1,24(sp)
    80002fca:	6145                	addi	sp,sp,48
    80002fcc:	8082                	ret
      return -1;
    80002fce:	54fd                	li	s1,-1
    80002fd0:	bfcd                	j	80002fc2 <sys_sbrk+0x64>
      return -1;
    80002fd2:	54fd                	li	s1,-1
    80002fd4:	b7fd                	j	80002fc2 <sys_sbrk+0x64>
      return -1;
    80002fd6:	54fd                	li	s1,-1
    80002fd8:	b7ed                	j	80002fc2 <sys_sbrk+0x64>

0000000080002fda <sys_pause>:
{
    80002fda:	7139                	addi	sp,sp,-64
    80002fdc:	fc06                	sd	ra,56(sp)
    80002fde:	f822                	sd	s0,48(sp)
    80002fe0:	f426                	sd	s1,40(sp)
    80002fe2:	f04a                	sd	s2,32(sp)
    80002fe4:	ec4e                	sd	s3,24(sp)
    80002fe6:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002fe8:	fcc40593          	addi	a1,s0,-52
    80002fec:	4501                	li	a0,0
    80002fee:	dffff0ef          	jal	ra,80002dec <argint>
  if(n < 0)
    80002ff2:	fcc42783          	lw	a5,-52(s0)
    80002ff6:	0607c563          	bltz	a5,80003060 <sys_pause+0x86>
  acquire(&tickslock);
    80002ffa:	0023e517          	auipc	a0,0x23e
    80002ffe:	84650513          	addi	a0,a0,-1978 # 80240840 <tickslock>
    80003002:	cbdfd0ef          	jal	ra,80000cbe <acquire>
  ticks0 = ticks;
    80003006:	00006917          	auipc	s2,0x6
    8000300a:	8c292903          	lw	s2,-1854(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    8000300e:	fcc42783          	lw	a5,-52(s0)
    80003012:	cb8d                	beqz	a5,80003044 <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80003014:	0023e997          	auipc	s3,0x23e
    80003018:	82c98993          	addi	s3,s3,-2004 # 80240840 <tickslock>
    8000301c:	00006497          	auipc	s1,0x6
    80003020:	8ac48493          	addi	s1,s1,-1876 # 800088c8 <ticks>
    if(killed(myproc())){
    80003024:	b9bfe0ef          	jal	ra,80001bbe <myproc>
    80003028:	ec6ff0ef          	jal	ra,800026ee <killed>
    8000302c:	ed0d                	bnez	a0,80003066 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000302e:	85ce                	mv	a1,s3
    80003030:	8526                	mv	a0,s1
    80003032:	c84ff0ef          	jal	ra,800024b6 <sleep>
  while(ticks - ticks0 < n){
    80003036:	409c                	lw	a5,0(s1)
    80003038:	412787bb          	subw	a5,a5,s2
    8000303c:	fcc42703          	lw	a4,-52(s0)
    80003040:	fee7e2e3          	bltu	a5,a4,80003024 <sys_pause+0x4a>
  release(&tickslock);
    80003044:	0023d517          	auipc	a0,0x23d
    80003048:	7fc50513          	addi	a0,a0,2044 # 80240840 <tickslock>
    8000304c:	d0bfd0ef          	jal	ra,80000d56 <release>
  return 0;
    80003050:	4501                	li	a0,0
}
    80003052:	70e2                	ld	ra,56(sp)
    80003054:	7442                	ld	s0,48(sp)
    80003056:	74a2                	ld	s1,40(sp)
    80003058:	7902                	ld	s2,32(sp)
    8000305a:	69e2                	ld	s3,24(sp)
    8000305c:	6121                	addi	sp,sp,64
    8000305e:	8082                	ret
    n = 0;
    80003060:	fc042623          	sw	zero,-52(s0)
    80003064:	bf59                	j	80002ffa <sys_pause+0x20>
      release(&tickslock);
    80003066:	0023d517          	auipc	a0,0x23d
    8000306a:	7da50513          	addi	a0,a0,2010 # 80240840 <tickslock>
    8000306e:	ce9fd0ef          	jal	ra,80000d56 <release>
      return -1;
    80003072:	557d                	li	a0,-1
    80003074:	bff9                	j	80003052 <sys_pause+0x78>

0000000080003076 <sys_kill>:
{
    80003076:	1101                	addi	sp,sp,-32
    80003078:	ec06                	sd	ra,24(sp)
    8000307a:	e822                	sd	s0,16(sp)
    8000307c:	1000                	addi	s0,sp,32
  argint(0, &pid);
    8000307e:	fec40593          	addi	a1,s0,-20
    80003082:	4501                	li	a0,0
    80003084:	d69ff0ef          	jal	ra,80002dec <argint>
  return kkill(pid);
    80003088:	fec42503          	lw	a0,-20(s0)
    8000308c:	dd8ff0ef          	jal	ra,80002664 <kkill>
}
    80003090:	60e2                	ld	ra,24(sp)
    80003092:	6442                	ld	s0,16(sp)
    80003094:	6105                	addi	sp,sp,32
    80003096:	8082                	ret

0000000080003098 <sys_uptime>:
{
    80003098:	1101                	addi	sp,sp,-32
    8000309a:	ec06                	sd	ra,24(sp)
    8000309c:	e822                	sd	s0,16(sp)
    8000309e:	e426                	sd	s1,8(sp)
    800030a0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800030a2:	0023d517          	auipc	a0,0x23d
    800030a6:	79e50513          	addi	a0,a0,1950 # 80240840 <tickslock>
    800030aa:	c15fd0ef          	jal	ra,80000cbe <acquire>
  xticks = ticks;
    800030ae:	00006497          	auipc	s1,0x6
    800030b2:	81a4a483          	lw	s1,-2022(s1) # 800088c8 <ticks>
  release(&tickslock);
    800030b6:	0023d517          	auipc	a0,0x23d
    800030ba:	78a50513          	addi	a0,a0,1930 # 80240840 <tickslock>
    800030be:	c99fd0ef          	jal	ra,80000d56 <release>
}
    800030c2:	02049513          	slli	a0,s1,0x20
    800030c6:	9101                	srli	a0,a0,0x20
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6105                	addi	sp,sp,32
    800030d0:	8082                	ret

00000000800030d2 <vma_find>:
{
    800030d2:	1141                	addi	sp,sp,-16
    800030d4:	e422                	sd	s0,8(sp)
    800030d6:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    800030d8:	16850793          	addi	a5,a0,360
    800030dc:	4701                	li	a4,0
    800030de:	4841                	li	a6,16
    800030e0:	a031                	j	800030ec <vma_find+0x1a>
    800030e2:	2705                	addiw	a4,a4,1
    800030e4:	02878793          	addi	a5,a5,40
    800030e8:	03070263          	beq	a4,a6,8000310c <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    800030ec:	4394                	lw	a3,0(a5)
    800030ee:	daf5                	beqz	a3,800030e2 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    800030f0:	6794                	ld	a3,8(a5)
    800030f2:	fed5e8e3          	bltu	a1,a3,800030e2 <vma_find+0x10>
    800030f6:	6b94                	ld	a3,16(a5)
    800030f8:	fed5f5e3          	bgeu	a1,a3,800030e2 <vma_find+0x10>
      return &p->vmas[i];
    800030fc:	00271793          	slli	a5,a4,0x2
    80003100:	97ba                	add	a5,a5,a4
    80003102:	078e                	slli	a5,a5,0x3
    80003104:	16878793          	addi	a5,a5,360
    80003108:	953e                	add	a0,a0,a5
    8000310a:	a011                	j	8000310e <vma_find+0x3c>
  return 0;  // 没有找到包含该虚拟地址的VMA
    8000310c:	4501                	li	a0,0
}
    8000310e:	6422                	ld	s0,8(sp)
    80003110:	0141                	addi	sp,sp,16
    80003112:	8082                	ret

0000000080003114 <sys_mmap>:

uint64
sys_mmap(void)
{
    80003114:	7119                	addi	sp,sp,-128
    80003116:	fc86                	sd	ra,120(sp)
    80003118:	f8a2                	sd	s0,112(sp)
    8000311a:	f4a6                	sd	s1,104(sp)
    8000311c:	f0ca                	sd	s2,96(sp)
    8000311e:	ecce                	sd	s3,88(sp)
    80003120:	e8d2                	sd	s4,80(sp)
    80003122:	e4d6                	sd	s5,72(sp)
    80003124:	e0da                	sd	s6,64(sp)
    80003126:	fc5e                	sd	s7,56(sp)
    80003128:	f862                	sd	s8,48(sp)
    8000312a:	f466                	sd	s9,40(sp)
    8000312c:	0100                	addi	s0,sp,128
  uint64 addr;
  int len, prot, flags, key = -1;
    8000312e:	57fd                	li	a5,-1
    80003130:	f8f42423          	sw	a5,-120(s0)
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
    80003134:	f9840593          	addi	a1,s0,-104
    80003138:	4501                	li	a0,0
    8000313a:	ccfff0ef          	jal	ra,80002e08 <argaddr>
  argint(1, &len);
    8000313e:	f9440593          	addi	a1,s0,-108
    80003142:	4505                	li	a0,1
    80003144:	ca9ff0ef          	jal	ra,80002dec <argint>
  argint(2, &prot);
    80003148:	f9040593          	addi	a1,s0,-112
    8000314c:	4509                	li	a0,2
    8000314e:	c9fff0ef          	jal	ra,80002dec <argint>
  argint(3, &flags);
    80003152:	f8c40593          	addi	a1,s0,-116
    80003156:	450d                	li	a0,3
    80003158:	c95ff0ef          	jal	ra,80002dec <argint>
  argint(4, &key);
    8000315c:	f8840593          	addi	a1,s0,-120
    80003160:	4511                	li	a0,4
    80003162:	c8bff0ef          	jal	ra,80002dec <argint>

  if(len <= 0) return (uint64)-1;
    80003166:	f9442783          	lw	a5,-108(s0)
    8000316a:	1af05b63          	blez	a5,80003320 <sys_mmap+0x20c>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
    8000316e:	f9042903          	lw	s2,-112(s0)
    80003172:	ffc97913          	andi	s2,s2,-4
    80003176:	54fd                	li	s1,-1
    80003178:	1a091563          	bnez	s2,80003322 <sys_mmap+0x20e>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    8000317c:	f8c42703          	lw	a4,-116(s0)
    80003180:	8b05                	andi	a4,a4,1
    80003182:	1a070063          	beqz	a4,80003322 <sys_mmap+0x20e>
  if(addr != 0) return (uint64)-1;
    80003186:	f9843a03          	ld	s4,-104(s0)
    8000318a:	180a1c63          	bnez	s4,80003322 <sys_mmap+0x20e>
  uint64 plen = PGROUNDUP((uint64)len);
    8000318e:	6985                	lui	s3,0x1
    80003190:	19fd                	addi	s3,s3,-1
    80003192:	99be                	add	s3,s3,a5

  struct proc *p = myproc();
    80003194:	a2bfe0ef          	jal	ra,80001bbe <myproc>
    80003198:	8aaa                	mv	s5,a0

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    8000319a:	f8c42b83          	lw	s7,-116(s0)
    8000319e:	002bfb93          	andi	s7,s7,2
    800031a2:	020b8563          	beqz	s7,800031cc <sys_mmap+0xb8>
    if(key < 0) return (uint64)-1;
    800031a6:	f8842503          	lw	a0,-120(s0)
    800031aa:	16054c63          	bltz	a0,80003322 <sys_mmap+0x20e>
    npages = plen / PGSIZE;
    800031ae:	40c9dc13          	srai	s8,s3,0xc

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
    800031b2:	07f030ef          	jal	ra,80006a30 <shm_is_deleted>
    800031b6:	16051663          	bnez	a0,80003322 <sys_mmap+0x20e>
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
    800031ba:	4601                	li	a2,0
    800031bc:	f8842583          	lw	a1,-120(s0)
    800031c0:	8556                	mv	a0,s5
    800031c2:	cf7ff0ef          	jal	ra,80002eb8 <proc_has_shm_key>
  int need_get = 0;
    800031c6:	00153b93          	seqz	s7,a0
    800031ca:	a011                	j	800031ce <sys_mmap+0xba>
  int npages = 0;
    800031cc:	8c5e                	mv	s8,s7
  for(int i = 0; i < NVMA; i++){
    800031ce:	168a8b13          	addi	s6,s5,360
  int npages = 0;
    800031d2:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800031d4:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    800031d6:	4398                	lw	a4,0(a5)
    800031d8:	cb01                	beqz	a4,800031e8 <sys_mmap+0xd4>
  for(int i = 0; i < NVMA; i++){
    800031da:	2905                	addiw	s2,s2,1
    800031dc:	02878793          	addi	a5,a5,40
    800031e0:	fed91be3          	bne	s2,a3,800031d6 <sys_mmap+0xc2>
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    800031e4:	54fd                	li	s1,-1
    800031e6:	aa35                	j	80003322 <sys_mmap+0x20e>
  uint64 plen = PGROUNDUP((uint64)len);
    800031e8:	74fd                	lui	s1,0xfffff
    800031ea:	0099f9b3          	and	s3,s3,s1
      return &p->vmas[i];
    800031ee:	00291c93          	slli	s9,s2,0x2
    800031f2:	012c8533          	add	a0,s9,s2
    800031f6:	050e                	slli	a0,a0,0x3
    800031f8:	16850513          	addi	a0,a0,360

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
    800031fc:	02800613          	li	a2,40
    80003200:	4581                	li	a1,0
    80003202:	9556                	add	a0,a0,s5
    80003204:	b8ffd0ef          	jal	ra,80000d92 <memset>
  v->shm_key = -1;
    80003208:	012c87b3          	add	a5,s9,s2
    8000320c:	078e                	slli	a5,a5,0x3
    8000320e:	97d6                	add	a5,a5,s5
    80003210:	577d                	li	a4,-1
    80003212:	18e7a623          	sw	a4,396(a5)
  len = PGROUNDUP(len);  // 将长度向上对齐到页边界
    80003216:	6805                	lui	a6,0x1
    80003218:	187d                	addi	a6,a6,-1
    8000321a:	984e                	add	a6,a6,s3
    8000321c:	00987833          	and	a6,a6,s1
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003220:	400005b7          	lui	a1,0x40000
    80003224:	95c2                	add	a1,a1,a6
    80003226:	400004b7          	lui	s1,0x40000
    8000322a:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    8000322e:	6305                	lui	t1,0x1
    80003230:	137d                	addi	t1,t1,-1
    80003232:	7e7d                	lui	t3,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003234:	f3fff8b7          	lui	a7,0xf3fff
    80003238:	08ba                	slli	a7,a7,0xe
    8000323a:	01a8d893          	srli	a7,a7,0x1a
    8000323e:	a81d                	j	80003274 <sys_mmap+0x160>
      if(best == 0 || e < best) best = e;
    80003240:	8536                	mv	a0,a3
  for(int i=0; i<NVMA; i++){
    80003242:	02878793          	addi	a5,a5,40
    80003246:	00c78f63          	beq	a5,a2,80003264 <sys_mmap+0x150>
    if(!p->vmas[i].used) continue;
    8000324a:	4398                	lw	a4,0(a5)
    8000324c:	db7d                	beqz	a4,80003242 <sys_mmap+0x12e>
    uint64 e = p->vmas[i].end;
    8000324e:	6b94                	ld	a3,16(a5)
    if(!(end <= s || start >= e)){
    80003250:	6798                	ld	a4,8(a5)
    80003252:	feb778e3          	bgeu	a4,a1,80003242 <sys_mmap+0x12e>
    80003256:	fed4f6e3          	bgeu	s1,a3,80003242 <sys_mmap+0x12e>
      if(best == 0 || e < best) best = e;
    8000325a:	d17d                	beqz	a0,80003240 <sys_mmap+0x12c>
    8000325c:	fea6f3e3          	bgeu	a3,a0,80003242 <sys_mmap+0x12e>
    80003260:	8536                	mv	a0,a3
    80003262:	b7c5                	j	80003242 <sys_mmap+0x12e>
    if(jump == 0){
    80003264:	c919                	beqz	a0,8000327a <sys_mmap+0x166>
    va = PGROUNDUP(jump);
    80003266:	951a                	add	a0,a0,t1
    80003268:	01c574b3          	and	s1,a0,t3
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    8000326c:	009805b3          	add	a1,a6,s1
    80003270:	06b8ed63          	bltu	a7,a1,800032ea <sys_mmap+0x1d6>
  int npages = 0;
    80003274:	87da                	mv	a5,s6
  uint64 best = 0;
    80003276:	8552                	mv	a0,s4
    80003278:	bfc9                	j	8000324a <sys_mmap+0x136>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;
    8000327a:	400007b7          	lui	a5,0x40000
    8000327e:	06f4e663          	bltu	s1,a5,800032ea <sys_mmap+0x1d6>
    80003282:	99a6                	add	s3,s3,s1
    80003284:	010007b7          	lui	a5,0x1000
    80003288:	17f5                	addi	a5,a5,-3
    8000328a:	07ba                	slli	a5,a5,0xe
    8000328c:	0537ef63          	bltu	a5,s3,800032ea <sys_mmap+0x1d6>

  // 先写入 vma 基本信息
  v->used  = 1;
    80003290:	00291793          	slli	a5,s2,0x2
    80003294:	97ca                	add	a5,a5,s2
    80003296:	078e                	slli	a5,a5,0x3
    80003298:	97d6                	add	a5,a5,s5
    8000329a:	4705                	li	a4,1
    8000329c:	16e7a423          	sw	a4,360(a5) # 1000168 <_entry-0x7efffe98>
  v->start = va;
    800032a0:	1697b823          	sd	s1,368(a5)
  v->end   = va + plen;
    800032a4:	1737bc23          	sd	s3,376(a5)
  v->prot  = prot;
    800032a8:	f9042703          	lw	a4,-112(s0)
    800032ac:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    800032b0:	f8c42703          	lw	a4,-116(s0)
    800032b4:	18e7a223          	sw	a4,388(a5)

  if(flags & MAP_SHARED){
    800032b8:	8b09                	andi	a4,a4,2
    800032ba:	c725                	beqz	a4,80003322 <sys_mmap+0x20e>
    if(need_get){
    800032bc:	020b9063          	bnez	s7,800032dc <sys_mmap+0x1c8>
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    800032c0:	00291793          	slli	a5,s2,0x2
    800032c4:	01278733          	add	a4,a5,s2
    800032c8:	070e                	slli	a4,a4,0x3
    800032ca:	9756                	add	a4,a4,s5
    800032cc:	4685                	li	a3,1
    800032ce:	18d72423          	sw	a3,392(a4) # 2000188 <_entry-0x7dfffe78>
    v->shm_key = key;
    800032d2:	f8842783          	lw	a5,-120(s0)
    800032d6:	18f72623          	sw	a5,396(a4)
    800032da:	a0a1                	j	80003322 <sys_mmap+0x20e>
      if(shm_get(key, npages) < 0)
    800032dc:	85e2                	mv	a1,s8
    800032de:	f8842503          	lw	a0,-120(s0)
    800032e2:	30e030ef          	jal	ra,800065f0 <shm_get>
    800032e6:	fc055de3          	bgez	a0,800032c0 <sys_mmap+0x1ac>
bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    800032ea:	00291713          	slli	a4,s2,0x2
    800032ee:	012707b3          	add	a5,a4,s2
    800032f2:	078e                	slli	a5,a5,0x3
    800032f4:	97d6                	add	a5,a5,s5
    800032f6:	1607a423          	sw	zero,360(a5)
    v->is_shm = 0;
    800032fa:	1807a423          	sw	zero,392(a5)
    v->shm_key = -1;
    800032fe:	56fd                	li	a3,-1
    80003300:	18d7a623          	sw	a3,396(a5)
    v->start = v->end = 0;
    80003304:	1607bc23          	sd	zero,376(a5)
    80003308:	1607b823          	sd	zero,368(a5)
    v->prot = v->flags = 0;
    8000330c:	1807a223          	sw	zero,388(a5)
    80003310:	012707b3          	add	a5,a4,s2
    80003314:	078e                	slli	a5,a5,0x3
    80003316:	9abe                	add	s5,s5,a5
    80003318:	180aa023          	sw	zero,384(s5)
  }
  return (uint64)-1;
    8000331c:	54fd                	li	s1,-1
    8000331e:	a011                	j	80003322 <sys_mmap+0x20e>
  if(len <= 0) return (uint64)-1;
    80003320:	54fd                	li	s1,-1
}
    80003322:	8526                	mv	a0,s1
    80003324:	70e6                	ld	ra,120(sp)
    80003326:	7446                	ld	s0,112(sp)
    80003328:	74a6                	ld	s1,104(sp)
    8000332a:	7906                	ld	s2,96(sp)
    8000332c:	69e6                	ld	s3,88(sp)
    8000332e:	6a46                	ld	s4,80(sp)
    80003330:	6aa6                	ld	s5,72(sp)
    80003332:	6b06                	ld	s6,64(sp)
    80003334:	7be2                	ld	s7,56(sp)
    80003336:	7c42                	ld	s8,48(sp)
    80003338:	7ca2                	ld	s9,40(sp)
    8000333a:	6109                	addi	sp,sp,128
    8000333c:	8082                	ret

000000008000333e <sys_munmap>:
}


uint64
sys_munmap(void)
{
    8000333e:	7159                	addi	sp,sp,-112
    80003340:	f486                	sd	ra,104(sp)
    80003342:	f0a2                	sd	s0,96(sp)
    80003344:	eca6                	sd	s1,88(sp)
    80003346:	e8ca                	sd	s2,80(sp)
    80003348:	e4ce                	sd	s3,72(sp)
    8000334a:	e0d2                	sd	s4,64(sp)
    8000334c:	fc56                	sd	s5,56(sp)
    8000334e:	f85a                	sd	s6,48(sp)
    80003350:	f45e                	sd	s7,40(sp)
    80003352:	f062                	sd	s8,32(sp)
    80003354:	ec66                	sd	s9,24(sp)
    80003356:	e86a                	sd	s10,16(sp)
    80003358:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    8000335a:	865fe0ef          	jal	ra,80001bbe <myproc>
    8000335e:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    80003360:	f9840593          	addi	a1,s0,-104
    80003364:	4501                	li	a0,0
    80003366:	aa3ff0ef          	jal	ra,80002e08 <argaddr>
  argint(1, &len);
    8000336a:	f9440593          	addi	a1,s0,-108
    8000336e:	4505                	li	a0,1
    80003370:	a7dff0ef          	jal	ra,80002dec <argint>

  if(len <= 0) return (uint64)-1;
    80003374:	f9442703          	lw	a4,-108(s0)
    80003378:	2ce05e63          	blez	a4,80003654 <sys_munmap+0x316>


  uint64 a = PGROUNDDOWN(uaddr);
    8000337c:	f9843783          	ld	a5,-104(s0)
    80003380:	76fd                	lui	a3,0xfffff
    80003382:	00d7fa33          	and	s4,a5,a3
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    80003386:	6905                	lui	s2,0x1
    80003388:	197d                	addi	s2,s2,-1
    8000338a:	993e                	add	s2,s2,a5
    8000338c:	993a                	add	s2,s2,a4
    8000338e:	00d97933          	and	s2,s2,a3
  if(b < a) return (uint64)-1;  // 溢出了
    80003392:	557d                	li	a0,-1
    80003394:	17496d63          	bltu	s2,s4,8000350e <sys_munmap+0x1d0>
    80003398:	168a8b13          	addi	s6,s5,360
    8000339c:	3e8a8993          	addi	s3,s5,1000
    800033a0:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    800033a2:	4801                	li	a6,0
    800033a4:	a029                	j	800033ae <sys_munmap+0x70>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    800033a6:	02878793          	addi	a5,a5,40
    800033aa:	01378663          	beq	a5,s3,800033b6 <sys_munmap+0x78>
    800033ae:	4398                	lw	a4,0(a5)
    800033b0:	fb7d                	bnez	a4,800033a6 <sys_munmap+0x68>
    800033b2:	2805                	addiw	a6,a6,1
    800033b4:	bfcd                	j	800033a6 <sys_munmap+0x68>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    800033b6:	8552                	mv	a0,s4
  int need_splits = 0;
    800033b8:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    800033ba:	4881                	li	a7,0
    800033bc:	45c1                	li	a1,16
    800033be:	537d                	li	t1,-1
  while(cur < b){
    800033c0:	072a6163          	bltu	s4,s2,80003422 <sys_munmap+0xe4>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    800033c4:	43f85513          	srai	a0,a6,0x3f
    800033c8:	a299                	j	8000350e <sys_munmap+0x1d0>
  for(int i = 0; i < NVMA; i++){
    800033ca:	2705                	addiw	a4,a4,1
    800033cc:	02878793          	addi	a5,a5,40
    800033d0:	04b70c63          	beq	a4,a1,80003428 <sys_munmap+0xea>
    if(!p->vmas[i].used) continue;
    800033d4:	4394                	lw	a3,0(a5)
    800033d6:	daf5                	beqz	a3,800033ca <sys_munmap+0x8c>
    if(!(b <= s || a >= e))   // 存在地址重叠
    800033d8:	6794                	ld	a3,8(a5)
    800033da:	ff26f8e3          	bgeu	a3,s2,800033ca <sys_munmap+0x8c>
    800033de:	6b94                	ld	a3,16(a5)
    800033e0:	fed575e3          	bgeu	a0,a3,800033ca <sys_munmap+0x8c>
    if(vi < 0){
    800033e4:	04074563          	bltz	a4,8000342e <sys_munmap+0xf0>
    uint64 seg_start = cur > v->start ? cur : v->start;
    800033e8:	00271793          	slli	a5,a4,0x2
    800033ec:	97ba                	add	a5,a5,a4
    800033ee:	078e                	slli	a5,a5,0x3
    800033f0:	97d6                	add	a5,a5,s5
    800033f2:	1707b683          	ld	a3,368(a5)
    800033f6:	8636                	mv	a2,a3
    800033f8:	00a6f363          	bgeu	a3,a0,800033fe <sys_munmap+0xc0>
    800033fc:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800033fe:	00271793          	slli	a5,a4,0x2
    80003402:	97ba                	add	a5,a5,a4
    80003404:	078e                	slli	a5,a5,0x3
    80003406:	97d6                	add	a5,a5,s5
    80003408:	1787b783          	ld	a5,376(a5)
    8000340c:	853e                	mv	a0,a5
    8000340e:	00f97363          	bgeu	s2,a5,80003414 <sys_munmap+0xd6>
    80003412:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    80003414:	00c6f563          	bgeu	a3,a2,8000341e <sys_munmap+0xe0>
    80003418:	00f57363          	bgeu	a0,a5,8000341e <sys_munmap+0xe0>
      need_splits++;
    8000341c:	2e05                	addiw	t3,t3,1
  while(cur < b){
    8000341e:	03257a63          	bgeu	a0,s2,80003452 <sys_munmap+0x114>
  int free_slots = 0;
    80003422:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003424:	8746                	mv	a4,a7
    80003426:	b77d                	j	800033d4 <sys_munmap+0x96>
    80003428:	87da                	mv	a5,s6
    8000342a:	869a                	mv	a3,t1
    8000342c:	a801                	j	8000343c <sys_munmap+0xfe>
    8000342e:	87da                	mv	a5,s6
    80003430:	869a                	mv	a3,t1
    80003432:	a029                	j	8000343c <sys_munmap+0xfe>
  for(int i = 0; i < NVMA; i++){
    80003434:	02878793          	addi	a5,a5,40
    80003438:	01378b63          	beq	a5,s3,8000344e <sys_munmap+0x110>
    if(!p->vmas[i].used) continue;
    8000343c:	4398                	lw	a4,0(a5)
    8000343e:	db7d                	beqz	a4,80003434 <sys_munmap+0xf6>
    uint64 s = p->vmas[i].start;
    80003440:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80003442:	fea769e3          	bltu	a4,a0,80003434 <sys_munmap+0xf6>
    80003446:	fed777e3          	bgeu	a4,a3,80003434 <sys_munmap+0xf6>
    8000344a:	86ba                	mv	a3,a4
    8000344c:	b7e5                	j	80003434 <sys_munmap+0xf6>
      if(ns == (uint64)-1 || ns >= b) break;
    8000344e:	0126e963          	bltu	a3,s2,80003460 <sys_munmap+0x122>
    // 不做任何事，保持一致性
    return (uint64)-1;
    80003452:	557d                	li	a0,-1
  if(need_splits > free_slots){
    80003454:	0bc84d63          	blt	a6,t3,8000350e <sys_munmap+0x1d0>
  for(int i = 0; i < NVMA; i++){
    80003458:	4c01                	li	s8,0
    8000345a:	4bc1                	li	s7,16
    8000345c:	5cfd                	li	s9,-1
    8000345e:	aac5                	j	8000364e <sys_munmap+0x310>
    80003460:	8536                	mv	a0,a3
    80003462:	b7c1                	j	80003422 <sys_munmap+0xe4>
    80003464:	2485                	addiw	s1,s1,1
    80003466:	02878793          	addi	a5,a5,40
    8000346a:	07748c63          	beq	s1,s7,800034e2 <sys_munmap+0x1a4>
    if(!p->vmas[i].used) continue;
    8000346e:	4398                	lw	a4,0(a5)
    80003470:	db75                	beqz	a4,80003464 <sys_munmap+0x126>
    if(!(b <= s || a >= e))   // 存在地址重叠
    80003472:	6798                	ld	a4,8(a5)
    80003474:	ff2778e3          	bgeu	a4,s2,80003464 <sys_munmap+0x126>
    80003478:	6b98                	ld	a4,16(a5)
    8000347a:	feea75e3          	bgeu	s4,a4,80003464 <sys_munmap+0x126>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    8000347e:	0604c563          	bltz	s1,800034e8 <sys_munmap+0x1aa>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    80003482:	00249793          	slli	a5,s1,0x2
    80003486:	97a6                	add	a5,a5,s1
    80003488:	078e                	slli	a5,a5,0x3
    8000348a:	97d6                	add	a5,a5,s5
    8000348c:	1707bd03          	ld	s10,368(a5)
    80003490:	014d7363          	bgeu	s10,s4,80003496 <sys_munmap+0x158>
    80003494:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003496:	00249793          	slli	a5,s1,0x2
    8000349a:	97a6                	add	a5,a5,s1
    8000349c:	078e                	slli	a5,a5,0x3
    8000349e:	97d6                	add	a5,a5,s5
    800034a0:	1787ba03          	ld	s4,376(a5)
    800034a4:	01497363          	bgeu	s2,s4,800034aa <sys_munmap+0x16c>
    800034a8:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    800034aa:	094d6263          	bltu	s10,s4,8000352e <sys_munmap+0x1f0>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    800034ae:	00249793          	slli	a5,s1,0x2
    800034b2:	97a6                	add	a5,a5,s1
    800034b4:	078e                	slli	a5,a5,0x3
    800034b6:	97d6                	add	a5,a5,s5
    800034b8:	1707b783          	ld	a5,368(a5)
    800034bc:	11a7e463          	bltu	a5,s10,800035c4 <sys_munmap+0x286>
    800034c0:	00249793          	slli	a5,s1,0x2
    800034c4:	97a6                	add	a5,a5,s1
    800034c6:	078e                	slli	a5,a5,0x3
    800034c8:	97d6                	add	a5,a5,s5
    800034ca:	1787b783          	ld	a5,376(a5)
    800034ce:	06fa7a63          	bgeu	s4,a5,80003542 <sys_munmap+0x204>
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    800034d2:	00249793          	slli	a5,s1,0x2
    800034d6:	97a6                	add	a5,a5,s1
    800034d8:	078e                	slli	a5,a5,0x3
    800034da:	97d6                	add	a5,a5,s5
    800034dc:	1747b823          	sd	s4,368(a5)
    800034e0:	a2ad                	j	8000364a <sys_munmap+0x30c>
    800034e2:	87da                	mv	a5,s6
    800034e4:	86e6                	mv	a3,s9
    800034e6:	a801                	j	800034f6 <sys_munmap+0x1b8>
    800034e8:	87da                	mv	a5,s6
    800034ea:	86e6                	mv	a3,s9
    800034ec:	a029                	j	800034f6 <sys_munmap+0x1b8>
  for(int i = 0; i < NVMA; i++){
    800034ee:	02878793          	addi	a5,a5,40
    800034f2:	01378b63          	beq	a5,s3,80003508 <sys_munmap+0x1ca>
    if(!p->vmas[i].used) continue;
    800034f6:	4398                	lw	a4,0(a5)
    800034f8:	db7d                	beqz	a4,800034ee <sys_munmap+0x1b0>
    uint64 s = p->vmas[i].start;
    800034fa:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    800034fc:	ff4769e3          	bltu	a4,s4,800034ee <sys_munmap+0x1b0>
    80003500:	fed777e3          	bgeu	a4,a3,800034ee <sys_munmap+0x1b0>
    80003504:	86ba                	mv	a3,a4
    80003506:	b7e5                	j	800034ee <sys_munmap+0x1b0>
      if(ns == (uint64)-1 || ns >= b) break;
    80003508:	0326e163          	bltu	a3,s2,8000352a <sys_munmap+0x1ec>
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
    8000350c:	4501                	li	a0,0
}
    8000350e:	70a6                	ld	ra,104(sp)
    80003510:	7406                	ld	s0,96(sp)
    80003512:	64e6                	ld	s1,88(sp)
    80003514:	6946                	ld	s2,80(sp)
    80003516:	69a6                	ld	s3,72(sp)
    80003518:	6a06                	ld	s4,64(sp)
    8000351a:	7ae2                	ld	s5,56(sp)
    8000351c:	7b42                	ld	s6,48(sp)
    8000351e:	7ba2                	ld	s7,40(sp)
    80003520:	7c02                	ld	s8,32(sp)
    80003522:	6ce2                	ld	s9,24(sp)
    80003524:	6d42                	ld	s10,16(sp)
    80003526:	6165                	addi	sp,sp,112
    80003528:	8082                	ret
    8000352a:	8a36                	mv	s4,a3
    8000352c:	a20d                	j	8000364e <sys_munmap+0x310>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    8000352e:	41aa0633          	sub	a2,s4,s10
    80003532:	4685                	li	a3,1
    80003534:	8231                	srli	a2,a2,0xc
    80003536:	85ea                	mv	a1,s10
    80003538:	050ab503          	ld	a0,80(s5)
    8000353c:	d83fd0ef          	jal	ra,800012be <uvmunmap>
    80003540:	b7bd                	j	800034ae <sys_munmap+0x170>
  if(v->used == 0) return;
    80003542:	00249793          	slli	a5,s1,0x2
    80003546:	97a6                	add	a5,a5,s1
    80003548:	078e                	slli	a5,a5,0x3
    8000354a:	97d6                	add	a5,a5,s5
    8000354c:	1687a783          	lw	a5,360(a5)
    80003550:	0e078d63          	beqz	a5,8000364a <sys_munmap+0x30c>
  if(v->is_shm){
    80003554:	00249793          	slli	a5,s1,0x2
    80003558:	97a6                	add	a5,a5,s1
    8000355a:	078e                	slli	a5,a5,0x3
    8000355c:	97d6                	add	a5,a5,s5
    8000355e:	1887a783          	lw	a5,392(a5)
    80003562:	c785                	beqz	a5,8000358a <sys_munmap+0x24c>
    int key = v->shm_key;
    80003564:	00249793          	slli	a5,s1,0x2
    80003568:	00978733          	add	a4,a5,s1
    8000356c:	070e                	slli	a4,a4,0x3
    8000356e:	9756                	add	a4,a4,s5
    80003570:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    80003574:	00978633          	add	a2,a5,s1
    80003578:	060e                	slli	a2,a2,0x3
    8000357a:	16860613          	addi	a2,a2,360 # 1168 <_entry-0x7fffee98>
    if(!proc_has_shm_key(p, key, v)){
    8000357e:	9656                	add	a2,a2,s5
    80003580:	85ea                	mv	a1,s10
    80003582:	8556                	mv	a0,s5
    80003584:	935ff0ef          	jal	ra,80002eb8 <proc_has_shm_key>
    80003588:	c915                	beqz	a0,800035bc <sys_munmap+0x27e>
  v->used = 0;
    8000358a:	00249713          	slli	a4,s1,0x2
    8000358e:	009707b3          	add	a5,a4,s1
    80003592:	078e                	slli	a5,a5,0x3
    80003594:	97d6                	add	a5,a5,s5
    80003596:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    8000359a:	1607bc23          	sd	zero,376(a5)
    8000359e:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    800035a2:	1807a223          	sw	zero,388(a5)
    800035a6:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    800035aa:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    800035ae:	009707b3          	add	a5,a4,s1
    800035b2:	078e                	slli	a5,a5,0x3
    800035b4:	97d6                	add	a5,a5,s5
    800035b6:	1997a623          	sw	s9,396(a5)
    800035ba:	a841                	j	8000364a <sys_munmap+0x30c>
      shm_put(key);  // 没有其他引用，释放共享内存
    800035bc:	856a                	mv	a0,s10
    800035be:	176030ef          	jal	ra,80006734 <shm_put>
    800035c2:	b7e1                	j	8000358a <sys_munmap+0x24c>
    } else if(seg_start > v->start && seg_end >= v->end){
    800035c4:	00249793          	slli	a5,s1,0x2
    800035c8:	97a6                	add	a5,a5,s1
    800035ca:	078e                	slli	a5,a5,0x3
    800035cc:	97d6                	add	a5,a5,s5
    800035ce:	1787b783          	ld	a5,376(a5)
    800035d2:	00fa6a63          	bltu	s4,a5,800035e6 <sys_munmap+0x2a8>
      v->end = seg_start;
    800035d6:	00249793          	slli	a5,s1,0x2
    800035da:	97a6                	add	a5,a5,s1
    800035dc:	078e                	slli	a5,a5,0x3
    800035de:	97d6                	add	a5,a5,s5
    800035e0:	17a7bc23          	sd	s10,376(a5)
    800035e4:	a09d                	j	8000364a <sys_munmap+0x30c>
    800035e6:	875a                	mv	a4,s6
    800035e8:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    800035ea:	4314                	lw	a3,0(a4)
    800035ec:	c699                	beqz	a3,800035fa <sys_munmap+0x2bc>
  for(int i = 0; i < NVMA; i++){
    800035ee:	2785                	addiw	a5,a5,1
    800035f0:	02870713          	addi	a4,a4,40
    800035f4:	ff779be3          	bne	a5,s7,800035ea <sys_munmap+0x2ac>
  return -1;  // 没有空闲的VMA索引
    800035f8:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    800035fa:	00279593          	slli	a1,a5,0x2
    800035fe:	00f586b3          	add	a3,a1,a5
    80003602:	068e                	slli	a3,a3,0x3
    80003604:	96d6                	add	a3,a3,s5
    80003606:	00249613          	slli	a2,s1,0x2
    8000360a:	00960733          	add	a4,a2,s1
    8000360e:	070e                	slli	a4,a4,0x3
    80003610:	9756                	add	a4,a4,s5
    80003612:	16873303          	ld	t1,360(a4)
    80003616:	17873883          	ld	a7,376(a4)
    8000361a:	18073803          	ld	a6,384(a4)
    8000361e:	18873503          	ld	a0,392(a4)
    80003622:	1666b423          	sd	t1,360(a3) # fffffffffffff168 <end+0xffffffff7fdaaf68>
    80003626:	1716bc23          	sd	a7,376(a3)
    8000362a:	1906b023          	sd	a6,384(a3)
    8000362e:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    80003632:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003636:	17873703          	ld	a4,376(a4)
    8000363a:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    8000363e:	009607b3          	add	a5,a2,s1
    80003642:	078e                	slli	a5,a5,0x3
    80003644:	97d6                	add	a5,a5,s5
    80003646:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    8000364a:	012a7763          	bgeu	s4,s2,80003658 <sys_munmap+0x31a>
  int need_splits = 0;
    8000364e:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003650:	84e2                	mv	s1,s8
    80003652:	bd31                	j	8000346e <sys_munmap+0x130>
  if(len <= 0) return (uint64)-1;
    80003654:	557d                	li	a0,-1
    80003656:	bd65                	j	8000350e <sys_munmap+0x1d0>
  return 0;
    80003658:	4501                	li	a0,0
    8000365a:	bd55                	j	8000350e <sys_munmap+0x1d0>

000000008000365c <sys_shmctl>:

uint64
sys_shmctl(void)
{
    8000365c:	1101                	addi	sp,sp,-32
    8000365e:	ec06                	sd	ra,24(sp)
    80003660:	e822                	sd	s0,16(sp)
    80003662:	1000                	addi	s0,sp,32
  int key, cmd;
  argint(0, &key);
    80003664:	fec40593          	addi	a1,s0,-20
    80003668:	4501                	li	a0,0
    8000366a:	f82ff0ef          	jal	ra,80002dec <argint>
  argint(1, &cmd);
    8000366e:	fe840593          	addi	a1,s0,-24
    80003672:	4505                	li	a0,1
    80003674:	f78ff0ef          	jal	ra,80002dec <argint>
  return shm_ctl(key, cmd);
    80003678:	fe842583          	lw	a1,-24(s0)
    8000367c:	fec42503          	lw	a0,-20(s0)
    80003680:	2a6030ef          	jal	ra,80006926 <shm_ctl>
}
    80003684:	60e2                	ld	ra,24(sp)
    80003686:	6442                	ld	s0,16(sp)
    80003688:	6105                	addi	sp,sp,32
    8000368a:	8082                	ret

000000008000368c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000368c:	7139                	addi	sp,sp,-64
    8000368e:	fc06                	sd	ra,56(sp)
    80003690:	f822                	sd	s0,48(sp)
    80003692:	f426                	sd	s1,40(sp)
    80003694:	f04a                	sd	s2,32(sp)
    80003696:	ec4e                	sd	s3,24(sp)
    80003698:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000369a:	fcc40593          	addi	a1,s0,-52
    8000369e:	4501                	li	a0,0
    800036a0:	f4cff0ef          	jal	ra,80002dec <argint>
  if(n < 0)
    800036a4:	fcc42783          	lw	a5,-52(s0)
    return -1;
    800036a8:	557d                	li	a0,-1
  if(n < 0)
    800036aa:	0407ce63          	bltz	a5,80003706 <sys_sleep+0x7a>

  acquire(&tickslock);
    800036ae:	0023d517          	auipc	a0,0x23d
    800036b2:	19250513          	addi	a0,a0,402 # 80240840 <tickslock>
    800036b6:	e08fd0ef          	jal	ra,80000cbe <acquire>
  ticks0 = ticks;
    800036ba:	00005917          	auipc	s2,0x5
    800036be:	20e92903          	lw	s2,526(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    800036c2:	fcc42783          	lw	a5,-52(s0)
    800036c6:	cb8d                	beqz	a5,800036f8 <sys_sleep+0x6c>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
    800036c8:	0023d997          	auipc	s3,0x23d
    800036cc:	17898993          	addi	s3,s3,376 # 80240840 <tickslock>
    800036d0:	00005497          	auipc	s1,0x5
    800036d4:	1f848493          	addi	s1,s1,504 # 800088c8 <ticks>
    if(killed(myproc())){
    800036d8:	ce6fe0ef          	jal	ra,80001bbe <myproc>
    800036dc:	812ff0ef          	jal	ra,800026ee <killed>
    800036e0:	e915                	bnez	a0,80003714 <sys_sleep+0x88>
    sleep(&ticks, &tickslock);  
    800036e2:	85ce                	mv	a1,s3
    800036e4:	8526                	mv	a0,s1
    800036e6:	dd1fe0ef          	jal	ra,800024b6 <sleep>
  while(ticks - ticks0 < n){
    800036ea:	409c                	lw	a5,0(s1)
    800036ec:	412787bb          	subw	a5,a5,s2
    800036f0:	fcc42703          	lw	a4,-52(s0)
    800036f4:	fee7e2e3          	bltu	a5,a4,800036d8 <sys_sleep+0x4c>
  }
  release(&tickslock);
    800036f8:	0023d517          	auipc	a0,0x23d
    800036fc:	14850513          	addi	a0,a0,328 # 80240840 <tickslock>
    80003700:	e56fd0ef          	jal	ra,80000d56 <release>
  return 0;
    80003704:	4501                	li	a0,0
}
    80003706:	70e2                	ld	ra,56(sp)
    80003708:	7442                	ld	s0,48(sp)
    8000370a:	74a2                	ld	s1,40(sp)
    8000370c:	7902                	ld	s2,32(sp)
    8000370e:	69e2                	ld	s3,24(sp)
    80003710:	6121                	addi	sp,sp,64
    80003712:	8082                	ret
      release(&tickslock);
    80003714:	0023d517          	auipc	a0,0x23d
    80003718:	12c50513          	addi	a0,a0,300 # 80240840 <tickslock>
    8000371c:	e3afd0ef          	jal	ra,80000d56 <release>
      return -1;
    80003720:	557d                	li	a0,-1
    80003722:	b7d5                	j	80003706 <sys_sleep+0x7a>

0000000080003724 <sys_vmstats>:


uint64
sys_vmstats(void)
{
    80003724:	711d                	addi	sp,sp,-96
    80003726:	ec86                	sd	ra,88(sp)
    80003728:	e8a2                	sd	s0,80(sp)
    8000372a:	1080                	addi	s0,sp,96
  uint64 uaddr;
  argaddr(0, &uaddr);
    8000372c:	fe840593          	addi	a1,s0,-24
    80003730:	4501                	li	a0,0
    80003732:	ed6ff0ef          	jal	ra,80002e08 <argaddr>

  struct vmstats_user s;
  vmstats_snapshot(&s);
    80003736:	fa040513          	addi	a0,s0,-96
    8000373a:	600030ef          	jal	ra,80006d3a <vmstats_snapshot>

  extern uint64 kalloc_cnt, copyin_bytes, copyout_bytes, fork_copy_pages, fork_share_pages, kfree_cnt;
  s.kalloc_cnt = kalloc_cnt;
    8000373e:	00005797          	auipc	a5,0x5
    80003742:	1ba7b783          	ld	a5,442(a5) # 800088f8 <kalloc_cnt>
    80003746:	faf43c23          	sd	a5,-72(s0)
  s.copyin_bytes = copyin_bytes;
    8000374a:	00005797          	auipc	a5,0x5
    8000374e:	1a67b783          	ld	a5,422(a5) # 800088f0 <copyin_bytes>
    80003752:	fcf43023          	sd	a5,-64(s0)
  s.copyout_bytes = copyout_bytes;
    80003756:	00005797          	auipc	a5,0x5
    8000375a:	1927b783          	ld	a5,402(a5) # 800088e8 <copyout_bytes>
    8000375e:	fcf43423          	sd	a5,-56(s0)
  s.fork_copy_pages  = fork_copy_pages;   
    80003762:	00005797          	auipc	a5,0x5
    80003766:	17e7b783          	ld	a5,382(a5) # 800088e0 <fork_copy_pages>
    8000376a:	fcf43823          	sd	a5,-48(s0)
  s.fork_share_pages = fork_share_pages;
    8000376e:	00005797          	auipc	a5,0x5
    80003772:	16a7b783          	ld	a5,362(a5) # 800088d8 <fork_share_pages>
    80003776:	fcf43c23          	sd	a5,-40(s0)
  s.kfree_cnt = kfree_cnt;
    8000377a:	00005797          	auipc	a5,0x5
    8000377e:	1567b783          	ld	a5,342(a5) # 800088d0 <kfree_cnt>
    80003782:	fef43023          	sd	a5,-32(s0)

  if(copyout(myproc()->pagetable, uaddr, (char*)&s, sizeof(s)) < 0)
    80003786:	c38fe0ef          	jal	ra,80001bbe <myproc>
    8000378a:	04800693          	li	a3,72
    8000378e:	fa040613          	addi	a2,s0,-96
    80003792:	fe843583          	ld	a1,-24(s0)
    80003796:	6928                	ld	a0,80(a0)
    80003798:	816fe0ef          	jal	ra,800017ae <copyout>
    return -1;
  return 0;
    8000379c:	957d                	srai	a0,a0,0x3f
    8000379e:	60e6                	ld	ra,88(sp)
    800037a0:	6446                	ld	s0,80(sp)
    800037a2:	6125                	addi	sp,sp,96
    800037a4:	8082                	ret

00000000800037a6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800037a6:	7179                	addi	sp,sp,-48
    800037a8:	f406                	sd	ra,40(sp)
    800037aa:	f022                	sd	s0,32(sp)
    800037ac:	ec26                	sd	s1,24(sp)
    800037ae:	e84a                	sd	s2,16(sp)
    800037b0:	e44e                	sd	s3,8(sp)
    800037b2:	e052                	sd	s4,0(sp)
    800037b4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800037b6:	00005597          	auipc	a1,0x5
    800037ba:	d3258593          	addi	a1,a1,-718 # 800084e8 <syscalls+0xf0>
    800037be:	0023d517          	auipc	a0,0x23d
    800037c2:	09a50513          	addi	a0,a0,154 # 80240858 <bcache>
    800037c6:	c78fd0ef          	jal	ra,80000c3e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800037ca:	00245797          	auipc	a5,0x245
    800037ce:	08e78793          	addi	a5,a5,142 # 80248858 <bcache+0x8000>
    800037d2:	00245717          	auipc	a4,0x245
    800037d6:	2ee70713          	addi	a4,a4,750 # 80248ac0 <bcache+0x8268>
    800037da:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800037de:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037e2:	0023d497          	auipc	s1,0x23d
    800037e6:	08e48493          	addi	s1,s1,142 # 80240870 <bcache+0x18>
    b->next = bcache.head.next;
    800037ea:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800037ec:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800037ee:	00005a17          	auipc	s4,0x5
    800037f2:	d02a0a13          	addi	s4,s4,-766 # 800084f0 <syscalls+0xf8>
    b->next = bcache.head.next;
    800037f6:	2b893783          	ld	a5,696(s2)
    800037fa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800037fc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003800:	85d2                	mv	a1,s4
    80003802:	01048513          	addi	a0,s1,16
    80003806:	2fe010ef          	jal	ra,80004b04 <initsleeplock>
    bcache.head.next->prev = b;
    8000380a:	2b893783          	ld	a5,696(s2)
    8000380e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003810:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003814:	45848493          	addi	s1,s1,1112
    80003818:	fd349fe3          	bne	s1,s3,800037f6 <binit+0x50>
  }
}
    8000381c:	70a2                	ld	ra,40(sp)
    8000381e:	7402                	ld	s0,32(sp)
    80003820:	64e2                	ld	s1,24(sp)
    80003822:	6942                	ld	s2,16(sp)
    80003824:	69a2                	ld	s3,8(sp)
    80003826:	6a02                	ld	s4,0(sp)
    80003828:	6145                	addi	sp,sp,48
    8000382a:	8082                	ret

000000008000382c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000382c:	7179                	addi	sp,sp,-48
    8000382e:	f406                	sd	ra,40(sp)
    80003830:	f022                	sd	s0,32(sp)
    80003832:	ec26                	sd	s1,24(sp)
    80003834:	e84a                	sd	s2,16(sp)
    80003836:	e44e                	sd	s3,8(sp)
    80003838:	1800                	addi	s0,sp,48
    8000383a:	892a                	mv	s2,a0
    8000383c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000383e:	0023d517          	auipc	a0,0x23d
    80003842:	01a50513          	addi	a0,a0,26 # 80240858 <bcache>
    80003846:	c78fd0ef          	jal	ra,80000cbe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000384a:	00245497          	auipc	s1,0x245
    8000384e:	2c64b483          	ld	s1,710(s1) # 80248b10 <bcache+0x82b8>
    80003852:	00245797          	auipc	a5,0x245
    80003856:	26e78793          	addi	a5,a5,622 # 80248ac0 <bcache+0x8268>
    8000385a:	02f48b63          	beq	s1,a5,80003890 <bread+0x64>
    8000385e:	873e                	mv	a4,a5
    80003860:	a021                	j	80003868 <bread+0x3c>
    80003862:	68a4                	ld	s1,80(s1)
    80003864:	02e48663          	beq	s1,a4,80003890 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003868:	449c                	lw	a5,8(s1)
    8000386a:	ff279ce3          	bne	a5,s2,80003862 <bread+0x36>
    8000386e:	44dc                	lw	a5,12(s1)
    80003870:	ff3799e3          	bne	a5,s3,80003862 <bread+0x36>
      b->refcnt++;
    80003874:	40bc                	lw	a5,64(s1)
    80003876:	2785                	addiw	a5,a5,1
    80003878:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000387a:	0023d517          	auipc	a0,0x23d
    8000387e:	fde50513          	addi	a0,a0,-34 # 80240858 <bcache>
    80003882:	cd4fd0ef          	jal	ra,80000d56 <release>
      acquiresleep(&b->lock);
    80003886:	01048513          	addi	a0,s1,16
    8000388a:	2b0010ef          	jal	ra,80004b3a <acquiresleep>
      return b;
    8000388e:	a889                	j	800038e0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003890:	00245497          	auipc	s1,0x245
    80003894:	2784b483          	ld	s1,632(s1) # 80248b08 <bcache+0x82b0>
    80003898:	00245797          	auipc	a5,0x245
    8000389c:	22878793          	addi	a5,a5,552 # 80248ac0 <bcache+0x8268>
    800038a0:	00f48863          	beq	s1,a5,800038b0 <bread+0x84>
    800038a4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800038a6:	40bc                	lw	a5,64(s1)
    800038a8:	cb91                	beqz	a5,800038bc <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038aa:	64a4                	ld	s1,72(s1)
    800038ac:	fee49de3          	bne	s1,a4,800038a6 <bread+0x7a>
  panic("bget: no buffers");
    800038b0:	00005517          	auipc	a0,0x5
    800038b4:	c4850513          	addi	a0,a0,-952 # 800084f8 <syscalls+0x100>
    800038b8:	ed3fc0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    800038bc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800038c0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800038c4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800038c8:	4785                	li	a5,1
    800038ca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038cc:	0023d517          	auipc	a0,0x23d
    800038d0:	f8c50513          	addi	a0,a0,-116 # 80240858 <bcache>
    800038d4:	c82fd0ef          	jal	ra,80000d56 <release>
      acquiresleep(&b->lock);
    800038d8:	01048513          	addi	a0,s1,16
    800038dc:	25e010ef          	jal	ra,80004b3a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800038e0:	409c                	lw	a5,0(s1)
    800038e2:	cb89                	beqz	a5,800038f4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800038e4:	8526                	mv	a0,s1
    800038e6:	70a2                	ld	ra,40(sp)
    800038e8:	7402                	ld	s0,32(sp)
    800038ea:	64e2                	ld	s1,24(sp)
    800038ec:	6942                	ld	s2,16(sp)
    800038ee:	69a2                	ld	s3,8(sp)
    800038f0:	6145                	addi	sp,sp,48
    800038f2:	8082                	ret
    virtio_disk_rw(b, 0);
    800038f4:	4581                	li	a1,0
    800038f6:	8526                	mv	a0,s1
    800038f8:	215020ef          	jal	ra,8000630c <virtio_disk_rw>
    b->valid = 1;
    800038fc:	4785                	li	a5,1
    800038fe:	c09c                	sw	a5,0(s1)
  return b;
    80003900:	b7d5                	j	800038e4 <bread+0xb8>

0000000080003902 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003902:	1101                	addi	sp,sp,-32
    80003904:	ec06                	sd	ra,24(sp)
    80003906:	e822                	sd	s0,16(sp)
    80003908:	e426                	sd	s1,8(sp)
    8000390a:	1000                	addi	s0,sp,32
    8000390c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000390e:	0541                	addi	a0,a0,16
    80003910:	2a8010ef          	jal	ra,80004bb8 <holdingsleep>
    80003914:	c911                	beqz	a0,80003928 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003916:	4585                	li	a1,1
    80003918:	8526                	mv	a0,s1
    8000391a:	1f3020ef          	jal	ra,8000630c <virtio_disk_rw>
}
    8000391e:	60e2                	ld	ra,24(sp)
    80003920:	6442                	ld	s0,16(sp)
    80003922:	64a2                	ld	s1,8(sp)
    80003924:	6105                	addi	sp,sp,32
    80003926:	8082                	ret
    panic("bwrite");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	be850513          	addi	a0,a0,-1048 # 80008510 <syscalls+0x118>
    80003930:	e5bfc0ef          	jal	ra,8000078a <panic>

0000000080003934 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003934:	1101                	addi	sp,sp,-32
    80003936:	ec06                	sd	ra,24(sp)
    80003938:	e822                	sd	s0,16(sp)
    8000393a:	e426                	sd	s1,8(sp)
    8000393c:	e04a                	sd	s2,0(sp)
    8000393e:	1000                	addi	s0,sp,32
    80003940:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003942:	01050913          	addi	s2,a0,16
    80003946:	854a                	mv	a0,s2
    80003948:	270010ef          	jal	ra,80004bb8 <holdingsleep>
    8000394c:	c13d                	beqz	a0,800039b2 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000394e:	854a                	mv	a0,s2
    80003950:	230010ef          	jal	ra,80004b80 <releasesleep>

  acquire(&bcache.lock);
    80003954:	0023d517          	auipc	a0,0x23d
    80003958:	f0450513          	addi	a0,a0,-252 # 80240858 <bcache>
    8000395c:	b62fd0ef          	jal	ra,80000cbe <acquire>
  b->refcnt--;
    80003960:	40bc                	lw	a5,64(s1)
    80003962:	37fd                	addiw	a5,a5,-1
    80003964:	0007871b          	sext.w	a4,a5
    80003968:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000396a:	eb05                	bnez	a4,8000399a <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000396c:	68bc                	ld	a5,80(s1)
    8000396e:	64b8                	ld	a4,72(s1)
    80003970:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003972:	64bc                	ld	a5,72(s1)
    80003974:	68b8                	ld	a4,80(s1)
    80003976:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003978:	00245797          	auipc	a5,0x245
    8000397c:	ee078793          	addi	a5,a5,-288 # 80248858 <bcache+0x8000>
    80003980:	2b87b703          	ld	a4,696(a5)
    80003984:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003986:	00245717          	auipc	a4,0x245
    8000398a:	13a70713          	addi	a4,a4,314 # 80248ac0 <bcache+0x8268>
    8000398e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003990:	2b87b703          	ld	a4,696(a5)
    80003994:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003996:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000399a:	0023d517          	auipc	a0,0x23d
    8000399e:	ebe50513          	addi	a0,a0,-322 # 80240858 <bcache>
    800039a2:	bb4fd0ef          	jal	ra,80000d56 <release>
}
    800039a6:	60e2                	ld	ra,24(sp)
    800039a8:	6442                	ld	s0,16(sp)
    800039aa:	64a2                	ld	s1,8(sp)
    800039ac:	6902                	ld	s2,0(sp)
    800039ae:	6105                	addi	sp,sp,32
    800039b0:	8082                	ret
    panic("brelse");
    800039b2:	00005517          	auipc	a0,0x5
    800039b6:	b6650513          	addi	a0,a0,-1178 # 80008518 <syscalls+0x120>
    800039ba:	dd1fc0ef          	jal	ra,8000078a <panic>

00000000800039be <bpin>:

void
bpin(struct buf *b) {
    800039be:	1101                	addi	sp,sp,-32
    800039c0:	ec06                	sd	ra,24(sp)
    800039c2:	e822                	sd	s0,16(sp)
    800039c4:	e426                	sd	s1,8(sp)
    800039c6:	1000                	addi	s0,sp,32
    800039c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039ca:	0023d517          	auipc	a0,0x23d
    800039ce:	e8e50513          	addi	a0,a0,-370 # 80240858 <bcache>
    800039d2:	aecfd0ef          	jal	ra,80000cbe <acquire>
  b->refcnt++;
    800039d6:	40bc                	lw	a5,64(s1)
    800039d8:	2785                	addiw	a5,a5,1
    800039da:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039dc:	0023d517          	auipc	a0,0x23d
    800039e0:	e7c50513          	addi	a0,a0,-388 # 80240858 <bcache>
    800039e4:	b72fd0ef          	jal	ra,80000d56 <release>
}
    800039e8:	60e2                	ld	ra,24(sp)
    800039ea:	6442                	ld	s0,16(sp)
    800039ec:	64a2                	ld	s1,8(sp)
    800039ee:	6105                	addi	sp,sp,32
    800039f0:	8082                	ret

00000000800039f2 <bunpin>:

void
bunpin(struct buf *b) {
    800039f2:	1101                	addi	sp,sp,-32
    800039f4:	ec06                	sd	ra,24(sp)
    800039f6:	e822                	sd	s0,16(sp)
    800039f8:	e426                	sd	s1,8(sp)
    800039fa:	1000                	addi	s0,sp,32
    800039fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039fe:	0023d517          	auipc	a0,0x23d
    80003a02:	e5a50513          	addi	a0,a0,-422 # 80240858 <bcache>
    80003a06:	ab8fd0ef          	jal	ra,80000cbe <acquire>
  b->refcnt--;
    80003a0a:	40bc                	lw	a5,64(s1)
    80003a0c:	37fd                	addiw	a5,a5,-1
    80003a0e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a10:	0023d517          	auipc	a0,0x23d
    80003a14:	e4850513          	addi	a0,a0,-440 # 80240858 <bcache>
    80003a18:	b3efd0ef          	jal	ra,80000d56 <release>
}
    80003a1c:	60e2                	ld	ra,24(sp)
    80003a1e:	6442                	ld	s0,16(sp)
    80003a20:	64a2                	ld	s1,8(sp)
    80003a22:	6105                	addi	sp,sp,32
    80003a24:	8082                	ret

0000000080003a26 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a26:	1101                	addi	sp,sp,-32
    80003a28:	ec06                	sd	ra,24(sp)
    80003a2a:	e822                	sd	s0,16(sp)
    80003a2c:	e426                	sd	s1,8(sp)
    80003a2e:	e04a                	sd	s2,0(sp)
    80003a30:	1000                	addi	s0,sp,32
    80003a32:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a34:	00d5d59b          	srliw	a1,a1,0xd
    80003a38:	00245797          	auipc	a5,0x245
    80003a3c:	4fc7a783          	lw	a5,1276(a5) # 80248f34 <sb+0x1c>
    80003a40:	9dbd                	addw	a1,a1,a5
    80003a42:	debff0ef          	jal	ra,8000382c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a46:	0074f713          	andi	a4,s1,7
    80003a4a:	4785                	li	a5,1
    80003a4c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a50:	14ce                	slli	s1,s1,0x33
    80003a52:	90d9                	srli	s1,s1,0x36
    80003a54:	00950733          	add	a4,a0,s1
    80003a58:	05874703          	lbu	a4,88(a4)
    80003a5c:	00e7f6b3          	and	a3,a5,a4
    80003a60:	c29d                	beqz	a3,80003a86 <bfree+0x60>
    80003a62:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a64:	94aa                	add	s1,s1,a0
    80003a66:	fff7c793          	not	a5,a5
    80003a6a:	8ff9                	and	a5,a5,a4
    80003a6c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003a70:	7d1000ef          	jal	ra,80004a40 <log_write>
  brelse(bp);
    80003a74:	854a                	mv	a0,s2
    80003a76:	ebfff0ef          	jal	ra,80003934 <brelse>
}
    80003a7a:	60e2                	ld	ra,24(sp)
    80003a7c:	6442                	ld	s0,16(sp)
    80003a7e:	64a2                	ld	s1,8(sp)
    80003a80:	6902                	ld	s2,0(sp)
    80003a82:	6105                	addi	sp,sp,32
    80003a84:	8082                	ret
    panic("freeing free block");
    80003a86:	00005517          	auipc	a0,0x5
    80003a8a:	a9a50513          	addi	a0,a0,-1382 # 80008520 <syscalls+0x128>
    80003a8e:	cfdfc0ef          	jal	ra,8000078a <panic>

0000000080003a92 <balloc>:
{
    80003a92:	711d                	addi	sp,sp,-96
    80003a94:	ec86                	sd	ra,88(sp)
    80003a96:	e8a2                	sd	s0,80(sp)
    80003a98:	e4a6                	sd	s1,72(sp)
    80003a9a:	e0ca                	sd	s2,64(sp)
    80003a9c:	fc4e                	sd	s3,56(sp)
    80003a9e:	f852                	sd	s4,48(sp)
    80003aa0:	f456                	sd	s5,40(sp)
    80003aa2:	f05a                	sd	s6,32(sp)
    80003aa4:	ec5e                	sd	s7,24(sp)
    80003aa6:	e862                	sd	s8,16(sp)
    80003aa8:	e466                	sd	s9,8(sp)
    80003aaa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003aac:	00245797          	auipc	a5,0x245
    80003ab0:	4707a783          	lw	a5,1136(a5) # 80248f1c <sb+0x4>
    80003ab4:	0e078163          	beqz	a5,80003b96 <balloc+0x104>
    80003ab8:	8baa                	mv	s7,a0
    80003aba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003abc:	00245b17          	auipc	s6,0x245
    80003ac0:	45cb0b13          	addi	s6,s6,1116 # 80248f18 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ac4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003ac6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ac8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003aca:	6c89                	lui	s9,0x2
    80003acc:	a0b5                	j	80003b38 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003ace:	974a                	add	a4,a4,s2
    80003ad0:	8fd5                	or	a5,a5,a3
    80003ad2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003ad6:	854a                	mv	a0,s2
    80003ad8:	769000ef          	jal	ra,80004a40 <log_write>
        brelse(bp);
    80003adc:	854a                	mv	a0,s2
    80003ade:	e57ff0ef          	jal	ra,80003934 <brelse>
  bp = bread(dev, bno);
    80003ae2:	85a6                	mv	a1,s1
    80003ae4:	855e                	mv	a0,s7
    80003ae6:	d47ff0ef          	jal	ra,8000382c <bread>
    80003aea:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003aec:	40000613          	li	a2,1024
    80003af0:	4581                	li	a1,0
    80003af2:	05850513          	addi	a0,a0,88
    80003af6:	a9cfd0ef          	jal	ra,80000d92 <memset>
  log_write(bp);
    80003afa:	854a                	mv	a0,s2
    80003afc:	745000ef          	jal	ra,80004a40 <log_write>
  brelse(bp);
    80003b00:	854a                	mv	a0,s2
    80003b02:	e33ff0ef          	jal	ra,80003934 <brelse>
}
    80003b06:	8526                	mv	a0,s1
    80003b08:	60e6                	ld	ra,88(sp)
    80003b0a:	6446                	ld	s0,80(sp)
    80003b0c:	64a6                	ld	s1,72(sp)
    80003b0e:	6906                	ld	s2,64(sp)
    80003b10:	79e2                	ld	s3,56(sp)
    80003b12:	7a42                	ld	s4,48(sp)
    80003b14:	7aa2                	ld	s5,40(sp)
    80003b16:	7b02                	ld	s6,32(sp)
    80003b18:	6be2                	ld	s7,24(sp)
    80003b1a:	6c42                	ld	s8,16(sp)
    80003b1c:	6ca2                	ld	s9,8(sp)
    80003b1e:	6125                	addi	sp,sp,96
    80003b20:	8082                	ret
    brelse(bp);
    80003b22:	854a                	mv	a0,s2
    80003b24:	e11ff0ef          	jal	ra,80003934 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003b28:	015c87bb          	addw	a5,s9,s5
    80003b2c:	00078a9b          	sext.w	s5,a5
    80003b30:	004b2703          	lw	a4,4(s6)
    80003b34:	06eaf163          	bgeu	s5,a4,80003b96 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003b38:	41fad79b          	sraiw	a5,s5,0x1f
    80003b3c:	0137d79b          	srliw	a5,a5,0x13
    80003b40:	015787bb          	addw	a5,a5,s5
    80003b44:	40d7d79b          	sraiw	a5,a5,0xd
    80003b48:	01cb2583          	lw	a1,28(s6)
    80003b4c:	9dbd                	addw	a1,a1,a5
    80003b4e:	855e                	mv	a0,s7
    80003b50:	cddff0ef          	jal	ra,8000382c <bread>
    80003b54:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b56:	004b2503          	lw	a0,4(s6)
    80003b5a:	000a849b          	sext.w	s1,s5
    80003b5e:	8662                	mv	a2,s8
    80003b60:	fca4f1e3          	bgeu	s1,a0,80003b22 <balloc+0x90>
      m = 1 << (bi % 8);
    80003b64:	41f6579b          	sraiw	a5,a2,0x1f
    80003b68:	01d7d69b          	srliw	a3,a5,0x1d
    80003b6c:	00c6873b          	addw	a4,a3,a2
    80003b70:	00777793          	andi	a5,a4,7
    80003b74:	9f95                	subw	a5,a5,a3
    80003b76:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b7a:	4037571b          	sraiw	a4,a4,0x3
    80003b7e:	00e906b3          	add	a3,s2,a4
    80003b82:	0586c683          	lbu	a3,88(a3)
    80003b86:	00d7f5b3          	and	a1,a5,a3
    80003b8a:	d1b1                	beqz	a1,80003ace <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b8c:	2605                	addiw	a2,a2,1
    80003b8e:	2485                	addiw	s1,s1,1
    80003b90:	fd4618e3          	bne	a2,s4,80003b60 <balloc+0xce>
    80003b94:	b779                	j	80003b22 <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003b96:	00005517          	auipc	a0,0x5
    80003b9a:	9a250513          	addi	a0,a0,-1630 # 80008538 <syscalls+0x140>
    80003b9e:	927fc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003ba2:	4481                	li	s1,0
    80003ba4:	b78d                	j	80003b06 <balloc+0x74>

0000000080003ba6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ba6:	7179                	addi	sp,sp,-48
    80003ba8:	f406                	sd	ra,40(sp)
    80003baa:	f022                	sd	s0,32(sp)
    80003bac:	ec26                	sd	s1,24(sp)
    80003bae:	e84a                	sd	s2,16(sp)
    80003bb0:	e44e                	sd	s3,8(sp)
    80003bb2:	e052                	sd	s4,0(sp)
    80003bb4:	1800                	addi	s0,sp,48
    80003bb6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003bb8:	47ad                	li	a5,11
    80003bba:	02b7e563          	bltu	a5,a1,80003be4 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003bbe:	02059493          	slli	s1,a1,0x20
    80003bc2:	9081                	srli	s1,s1,0x20
    80003bc4:	048a                	slli	s1,s1,0x2
    80003bc6:	94aa                	add	s1,s1,a0
    80003bc8:	0504a903          	lw	s2,80(s1)
    80003bcc:	06091663          	bnez	s2,80003c38 <bmap+0x92>
      addr = balloc(ip->dev);
    80003bd0:	4108                	lw	a0,0(a0)
    80003bd2:	ec1ff0ef          	jal	ra,80003a92 <balloc>
    80003bd6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bda:	04090f63          	beqz	s2,80003c38 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80003bde:	0524a823          	sw	s2,80(s1)
    80003be2:	a899                	j	80003c38 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003be4:	ff45849b          	addiw	s1,a1,-12
    80003be8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bec:	0ff00793          	li	a5,255
    80003bf0:	06e7eb63          	bltu	a5,a4,80003c66 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003bf4:	08052903          	lw	s2,128(a0)
    80003bf8:	00091b63          	bnez	s2,80003c0e <bmap+0x68>
      addr = balloc(ip->dev);
    80003bfc:	4108                	lw	a0,0(a0)
    80003bfe:	e95ff0ef          	jal	ra,80003a92 <balloc>
    80003c02:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003c06:	02090963          	beqz	s2,80003c38 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003c0a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003c0e:	85ca                	mv	a1,s2
    80003c10:	0009a503          	lw	a0,0(s3)
    80003c14:	c19ff0ef          	jal	ra,8000382c <bread>
    80003c18:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c1a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003c1e:	02049593          	slli	a1,s1,0x20
    80003c22:	9181                	srli	a1,a1,0x20
    80003c24:	058a                	slli	a1,a1,0x2
    80003c26:	00b784b3          	add	s1,a5,a1
    80003c2a:	0004a903          	lw	s2,0(s1)
    80003c2e:	00090e63          	beqz	s2,80003c4a <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003c32:	8552                	mv	a0,s4
    80003c34:	d01ff0ef          	jal	ra,80003934 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c38:	854a                	mv	a0,s2
    80003c3a:	70a2                	ld	ra,40(sp)
    80003c3c:	7402                	ld	s0,32(sp)
    80003c3e:	64e2                	ld	s1,24(sp)
    80003c40:	6942                	ld	s2,16(sp)
    80003c42:	69a2                	ld	s3,8(sp)
    80003c44:	6a02                	ld	s4,0(sp)
    80003c46:	6145                	addi	sp,sp,48
    80003c48:	8082                	ret
      addr = balloc(ip->dev);
    80003c4a:	0009a503          	lw	a0,0(s3)
    80003c4e:	e45ff0ef          	jal	ra,80003a92 <balloc>
    80003c52:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c56:	fc090ee3          	beqz	s2,80003c32 <bmap+0x8c>
        a[bn] = addr;
    80003c5a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c5e:	8552                	mv	a0,s4
    80003c60:	5e1000ef          	jal	ra,80004a40 <log_write>
    80003c64:	b7f9                	j	80003c32 <bmap+0x8c>
  panic("bmap: out of range");
    80003c66:	00005517          	auipc	a0,0x5
    80003c6a:	8ea50513          	addi	a0,a0,-1814 # 80008550 <syscalls+0x158>
    80003c6e:	b1dfc0ef          	jal	ra,8000078a <panic>

0000000080003c72 <iget>:
{
    80003c72:	7179                	addi	sp,sp,-48
    80003c74:	f406                	sd	ra,40(sp)
    80003c76:	f022                	sd	s0,32(sp)
    80003c78:	ec26                	sd	s1,24(sp)
    80003c7a:	e84a                	sd	s2,16(sp)
    80003c7c:	e44e                	sd	s3,8(sp)
    80003c7e:	e052                	sd	s4,0(sp)
    80003c80:	1800                	addi	s0,sp,48
    80003c82:	89aa                	mv	s3,a0
    80003c84:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c86:	00245517          	auipc	a0,0x245
    80003c8a:	2b250513          	addi	a0,a0,690 # 80248f38 <itable>
    80003c8e:	830fd0ef          	jal	ra,80000cbe <acquire>
  empty = 0;
    80003c92:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c94:	00245497          	auipc	s1,0x245
    80003c98:	2bc48493          	addi	s1,s1,700 # 80248f50 <itable+0x18>
    80003c9c:	00247697          	auipc	a3,0x247
    80003ca0:	d4468693          	addi	a3,a3,-700 # 8024a9e0 <log>
    80003ca4:	a039                	j	80003cb2 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ca6:	02090963          	beqz	s2,80003cd8 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003caa:	08848493          	addi	s1,s1,136
    80003cae:	02d48863          	beq	s1,a3,80003cde <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003cb2:	449c                	lw	a5,8(s1)
    80003cb4:	fef059e3          	blez	a5,80003ca6 <iget+0x34>
    80003cb8:	4098                	lw	a4,0(s1)
    80003cba:	ff3716e3          	bne	a4,s3,80003ca6 <iget+0x34>
    80003cbe:	40d8                	lw	a4,4(s1)
    80003cc0:	ff4713e3          	bne	a4,s4,80003ca6 <iget+0x34>
      ip->ref++;
    80003cc4:	2785                	addiw	a5,a5,1
    80003cc6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003cc8:	00245517          	auipc	a0,0x245
    80003ccc:	27050513          	addi	a0,a0,624 # 80248f38 <itable>
    80003cd0:	886fd0ef          	jal	ra,80000d56 <release>
      return ip;
    80003cd4:	8926                	mv	s2,s1
    80003cd6:	a02d                	j	80003d00 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cd8:	fbe9                	bnez	a5,80003caa <iget+0x38>
    80003cda:	8926                	mv	s2,s1
    80003cdc:	b7f9                	j	80003caa <iget+0x38>
  if(empty == 0)
    80003cde:	02090a63          	beqz	s2,80003d12 <iget+0xa0>
  ip->dev = dev;
    80003ce2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ce6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cea:	4785                	li	a5,1
    80003cec:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003cf0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003cf4:	00245517          	auipc	a0,0x245
    80003cf8:	24450513          	addi	a0,a0,580 # 80248f38 <itable>
    80003cfc:	85afd0ef          	jal	ra,80000d56 <release>
}
    80003d00:	854a                	mv	a0,s2
    80003d02:	70a2                	ld	ra,40(sp)
    80003d04:	7402                	ld	s0,32(sp)
    80003d06:	64e2                	ld	s1,24(sp)
    80003d08:	6942                	ld	s2,16(sp)
    80003d0a:	69a2                	ld	s3,8(sp)
    80003d0c:	6a02                	ld	s4,0(sp)
    80003d0e:	6145                	addi	sp,sp,48
    80003d10:	8082                	ret
    panic("iget: no inodes");
    80003d12:	00005517          	auipc	a0,0x5
    80003d16:	85650513          	addi	a0,a0,-1962 # 80008568 <syscalls+0x170>
    80003d1a:	a71fc0ef          	jal	ra,8000078a <panic>

0000000080003d1e <iinit>:
{
    80003d1e:	7179                	addi	sp,sp,-48
    80003d20:	f406                	sd	ra,40(sp)
    80003d22:	f022                	sd	s0,32(sp)
    80003d24:	ec26                	sd	s1,24(sp)
    80003d26:	e84a                	sd	s2,16(sp)
    80003d28:	e44e                	sd	s3,8(sp)
    80003d2a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d2c:	00005597          	auipc	a1,0x5
    80003d30:	84c58593          	addi	a1,a1,-1972 # 80008578 <syscalls+0x180>
    80003d34:	00245517          	auipc	a0,0x245
    80003d38:	20450513          	addi	a0,a0,516 # 80248f38 <itable>
    80003d3c:	f03fc0ef          	jal	ra,80000c3e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d40:	00245497          	auipc	s1,0x245
    80003d44:	22048493          	addi	s1,s1,544 # 80248f60 <itable+0x28>
    80003d48:	00247997          	auipc	s3,0x247
    80003d4c:	ca898993          	addi	s3,s3,-856 # 8024a9f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d50:	00005917          	auipc	s2,0x5
    80003d54:	83090913          	addi	s2,s2,-2000 # 80008580 <syscalls+0x188>
    80003d58:	85ca                	mv	a1,s2
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	5a9000ef          	jal	ra,80004b04 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d60:	08848493          	addi	s1,s1,136
    80003d64:	ff349ae3          	bne	s1,s3,80003d58 <iinit+0x3a>
}
    80003d68:	70a2                	ld	ra,40(sp)
    80003d6a:	7402                	ld	s0,32(sp)
    80003d6c:	64e2                	ld	s1,24(sp)
    80003d6e:	6942                	ld	s2,16(sp)
    80003d70:	69a2                	ld	s3,8(sp)
    80003d72:	6145                	addi	sp,sp,48
    80003d74:	8082                	ret

0000000080003d76 <ialloc>:
{
    80003d76:	715d                	addi	sp,sp,-80
    80003d78:	e486                	sd	ra,72(sp)
    80003d7a:	e0a2                	sd	s0,64(sp)
    80003d7c:	fc26                	sd	s1,56(sp)
    80003d7e:	f84a                	sd	s2,48(sp)
    80003d80:	f44e                	sd	s3,40(sp)
    80003d82:	f052                	sd	s4,32(sp)
    80003d84:	ec56                	sd	s5,24(sp)
    80003d86:	e85a                	sd	s6,16(sp)
    80003d88:	e45e                	sd	s7,8(sp)
    80003d8a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d8c:	00245717          	auipc	a4,0x245
    80003d90:	19872703          	lw	a4,408(a4) # 80248f24 <sb+0xc>
    80003d94:	4785                	li	a5,1
    80003d96:	04e7f663          	bgeu	a5,a4,80003de2 <ialloc+0x6c>
    80003d9a:	8aaa                	mv	s5,a0
    80003d9c:	8bae                	mv	s7,a1
    80003d9e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003da0:	00245a17          	auipc	s4,0x245
    80003da4:	178a0a13          	addi	s4,s4,376 # 80248f18 <sb>
    80003da8:	00048b1b          	sext.w	s6,s1
    80003dac:	0044d793          	srli	a5,s1,0x4
    80003db0:	018a2583          	lw	a1,24(s4)
    80003db4:	9dbd                	addw	a1,a1,a5
    80003db6:	8556                	mv	a0,s5
    80003db8:	a75ff0ef          	jal	ra,8000382c <bread>
    80003dbc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003dbe:	05850993          	addi	s3,a0,88
    80003dc2:	00f4f793          	andi	a5,s1,15
    80003dc6:	079a                	slli	a5,a5,0x6
    80003dc8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003dca:	00099783          	lh	a5,0(s3)
    80003dce:	cf85                	beqz	a5,80003e06 <ialloc+0x90>
    brelse(bp);
    80003dd0:	b65ff0ef          	jal	ra,80003934 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dd4:	0485                	addi	s1,s1,1
    80003dd6:	00ca2703          	lw	a4,12(s4)
    80003dda:	0004879b          	sext.w	a5,s1
    80003dde:	fce7e5e3          	bltu	a5,a4,80003da8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003de2:	00004517          	auipc	a0,0x4
    80003de6:	7a650513          	addi	a0,a0,1958 # 80008588 <syscalls+0x190>
    80003dea:	edafc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003dee:	4501                	li	a0,0
}
    80003df0:	60a6                	ld	ra,72(sp)
    80003df2:	6406                	ld	s0,64(sp)
    80003df4:	74e2                	ld	s1,56(sp)
    80003df6:	7942                	ld	s2,48(sp)
    80003df8:	79a2                	ld	s3,40(sp)
    80003dfa:	7a02                	ld	s4,32(sp)
    80003dfc:	6ae2                	ld	s5,24(sp)
    80003dfe:	6b42                	ld	s6,16(sp)
    80003e00:	6ba2                	ld	s7,8(sp)
    80003e02:	6161                	addi	sp,sp,80
    80003e04:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e06:	04000613          	li	a2,64
    80003e0a:	4581                	li	a1,0
    80003e0c:	854e                	mv	a0,s3
    80003e0e:	f85fc0ef          	jal	ra,80000d92 <memset>
      dip->type = type;
    80003e12:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e16:	854a                	mv	a0,s2
    80003e18:	429000ef          	jal	ra,80004a40 <log_write>
      brelse(bp);
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	b17ff0ef          	jal	ra,80003934 <brelse>
      return iget(dev, inum);
    80003e22:	85da                	mv	a1,s6
    80003e24:	8556                	mv	a0,s5
    80003e26:	e4dff0ef          	jal	ra,80003c72 <iget>
    80003e2a:	b7d9                	j	80003df0 <ialloc+0x7a>

0000000080003e2c <iupdate>:
{
    80003e2c:	1101                	addi	sp,sp,-32
    80003e2e:	ec06                	sd	ra,24(sp)
    80003e30:	e822                	sd	s0,16(sp)
    80003e32:	e426                	sd	s1,8(sp)
    80003e34:	e04a                	sd	s2,0(sp)
    80003e36:	1000                	addi	s0,sp,32
    80003e38:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e3a:	415c                	lw	a5,4(a0)
    80003e3c:	0047d79b          	srliw	a5,a5,0x4
    80003e40:	00245597          	auipc	a1,0x245
    80003e44:	0f05a583          	lw	a1,240(a1) # 80248f30 <sb+0x18>
    80003e48:	9dbd                	addw	a1,a1,a5
    80003e4a:	4108                	lw	a0,0(a0)
    80003e4c:	9e1ff0ef          	jal	ra,8000382c <bread>
    80003e50:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e52:	05850793          	addi	a5,a0,88
    80003e56:	40c8                	lw	a0,4(s1)
    80003e58:	893d                	andi	a0,a0,15
    80003e5a:	051a                	slli	a0,a0,0x6
    80003e5c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e5e:	04449703          	lh	a4,68(s1)
    80003e62:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e66:	04649703          	lh	a4,70(s1)
    80003e6a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e6e:	04849703          	lh	a4,72(s1)
    80003e72:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e76:	04a49703          	lh	a4,74(s1)
    80003e7a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e7e:	44f8                	lw	a4,76(s1)
    80003e80:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e82:	03400613          	li	a2,52
    80003e86:	05048593          	addi	a1,s1,80
    80003e8a:	0531                	addi	a0,a0,12
    80003e8c:	f63fc0ef          	jal	ra,80000dee <memmove>
  log_write(bp);
    80003e90:	854a                	mv	a0,s2
    80003e92:	3af000ef          	jal	ra,80004a40 <log_write>
  brelse(bp);
    80003e96:	854a                	mv	a0,s2
    80003e98:	a9dff0ef          	jal	ra,80003934 <brelse>
}
    80003e9c:	60e2                	ld	ra,24(sp)
    80003e9e:	6442                	ld	s0,16(sp)
    80003ea0:	64a2                	ld	s1,8(sp)
    80003ea2:	6902                	ld	s2,0(sp)
    80003ea4:	6105                	addi	sp,sp,32
    80003ea6:	8082                	ret

0000000080003ea8 <idup>:
{
    80003ea8:	1101                	addi	sp,sp,-32
    80003eaa:	ec06                	sd	ra,24(sp)
    80003eac:	e822                	sd	s0,16(sp)
    80003eae:	e426                	sd	s1,8(sp)
    80003eb0:	1000                	addi	s0,sp,32
    80003eb2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003eb4:	00245517          	auipc	a0,0x245
    80003eb8:	08450513          	addi	a0,a0,132 # 80248f38 <itable>
    80003ebc:	e03fc0ef          	jal	ra,80000cbe <acquire>
  ip->ref++;
    80003ec0:	449c                	lw	a5,8(s1)
    80003ec2:	2785                	addiw	a5,a5,1
    80003ec4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ec6:	00245517          	auipc	a0,0x245
    80003eca:	07250513          	addi	a0,a0,114 # 80248f38 <itable>
    80003ece:	e89fc0ef          	jal	ra,80000d56 <release>
}
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	60e2                	ld	ra,24(sp)
    80003ed6:	6442                	ld	s0,16(sp)
    80003ed8:	64a2                	ld	s1,8(sp)
    80003eda:	6105                	addi	sp,sp,32
    80003edc:	8082                	ret

0000000080003ede <ilock>:
{
    80003ede:	1101                	addi	sp,sp,-32
    80003ee0:	ec06                	sd	ra,24(sp)
    80003ee2:	e822                	sd	s0,16(sp)
    80003ee4:	e426                	sd	s1,8(sp)
    80003ee6:	e04a                	sd	s2,0(sp)
    80003ee8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003eea:	c105                	beqz	a0,80003f0a <ilock+0x2c>
    80003eec:	84aa                	mv	s1,a0
    80003eee:	451c                	lw	a5,8(a0)
    80003ef0:	00f05d63          	blez	a5,80003f0a <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003ef4:	0541                	addi	a0,a0,16
    80003ef6:	445000ef          	jal	ra,80004b3a <acquiresleep>
  if(ip->valid == 0){
    80003efa:	40bc                	lw	a5,64(s1)
    80003efc:	cf89                	beqz	a5,80003f16 <ilock+0x38>
}
    80003efe:	60e2                	ld	ra,24(sp)
    80003f00:	6442                	ld	s0,16(sp)
    80003f02:	64a2                	ld	s1,8(sp)
    80003f04:	6902                	ld	s2,0(sp)
    80003f06:	6105                	addi	sp,sp,32
    80003f08:	8082                	ret
    panic("ilock");
    80003f0a:	00004517          	auipc	a0,0x4
    80003f0e:	69650513          	addi	a0,a0,1686 # 800085a0 <syscalls+0x1a8>
    80003f12:	879fc0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f16:	40dc                	lw	a5,4(s1)
    80003f18:	0047d79b          	srliw	a5,a5,0x4
    80003f1c:	00245597          	auipc	a1,0x245
    80003f20:	0145a583          	lw	a1,20(a1) # 80248f30 <sb+0x18>
    80003f24:	9dbd                	addw	a1,a1,a5
    80003f26:	4088                	lw	a0,0(s1)
    80003f28:	905ff0ef          	jal	ra,8000382c <bread>
    80003f2c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f2e:	05850593          	addi	a1,a0,88
    80003f32:	40dc                	lw	a5,4(s1)
    80003f34:	8bbd                	andi	a5,a5,15
    80003f36:	079a                	slli	a5,a5,0x6
    80003f38:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f3a:	00059783          	lh	a5,0(a1)
    80003f3e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f42:	00259783          	lh	a5,2(a1)
    80003f46:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f4a:	00459783          	lh	a5,4(a1)
    80003f4e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f52:	00659783          	lh	a5,6(a1)
    80003f56:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f5a:	459c                	lw	a5,8(a1)
    80003f5c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f5e:	03400613          	li	a2,52
    80003f62:	05b1                	addi	a1,a1,12
    80003f64:	05048513          	addi	a0,s1,80
    80003f68:	e87fc0ef          	jal	ra,80000dee <memmove>
    brelse(bp);
    80003f6c:	854a                	mv	a0,s2
    80003f6e:	9c7ff0ef          	jal	ra,80003934 <brelse>
    ip->valid = 1;
    80003f72:	4785                	li	a5,1
    80003f74:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f76:	04449783          	lh	a5,68(s1)
    80003f7a:	f3d1                	bnez	a5,80003efe <ilock+0x20>
      panic("ilock: no type");
    80003f7c:	00004517          	auipc	a0,0x4
    80003f80:	62c50513          	addi	a0,a0,1580 # 800085a8 <syscalls+0x1b0>
    80003f84:	807fc0ef          	jal	ra,8000078a <panic>

0000000080003f88 <iunlock>:
{
    80003f88:	1101                	addi	sp,sp,-32
    80003f8a:	ec06                	sd	ra,24(sp)
    80003f8c:	e822                	sd	s0,16(sp)
    80003f8e:	e426                	sd	s1,8(sp)
    80003f90:	e04a                	sd	s2,0(sp)
    80003f92:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f94:	c505                	beqz	a0,80003fbc <iunlock+0x34>
    80003f96:	84aa                	mv	s1,a0
    80003f98:	01050913          	addi	s2,a0,16
    80003f9c:	854a                	mv	a0,s2
    80003f9e:	41b000ef          	jal	ra,80004bb8 <holdingsleep>
    80003fa2:	cd09                	beqz	a0,80003fbc <iunlock+0x34>
    80003fa4:	449c                	lw	a5,8(s1)
    80003fa6:	00f05b63          	blez	a5,80003fbc <iunlock+0x34>
  releasesleep(&ip->lock);
    80003faa:	854a                	mv	a0,s2
    80003fac:	3d5000ef          	jal	ra,80004b80 <releasesleep>
}
    80003fb0:	60e2                	ld	ra,24(sp)
    80003fb2:	6442                	ld	s0,16(sp)
    80003fb4:	64a2                	ld	s1,8(sp)
    80003fb6:	6902                	ld	s2,0(sp)
    80003fb8:	6105                	addi	sp,sp,32
    80003fba:	8082                	ret
    panic("iunlock");
    80003fbc:	00004517          	auipc	a0,0x4
    80003fc0:	5fc50513          	addi	a0,a0,1532 # 800085b8 <syscalls+0x1c0>
    80003fc4:	fc6fc0ef          	jal	ra,8000078a <panic>

0000000080003fc8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fc8:	7179                	addi	sp,sp,-48
    80003fca:	f406                	sd	ra,40(sp)
    80003fcc:	f022                	sd	s0,32(sp)
    80003fce:	ec26                	sd	s1,24(sp)
    80003fd0:	e84a                	sd	s2,16(sp)
    80003fd2:	e44e                	sd	s3,8(sp)
    80003fd4:	e052                	sd	s4,0(sp)
    80003fd6:	1800                	addi	s0,sp,48
    80003fd8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fda:	05050493          	addi	s1,a0,80
    80003fde:	08050913          	addi	s2,a0,128
    80003fe2:	a021                	j	80003fea <itrunc+0x22>
    80003fe4:	0491                	addi	s1,s1,4
    80003fe6:	01248b63          	beq	s1,s2,80003ffc <itrunc+0x34>
    if(ip->addrs[i]){
    80003fea:	408c                	lw	a1,0(s1)
    80003fec:	dde5                	beqz	a1,80003fe4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fee:	0009a503          	lw	a0,0(s3)
    80003ff2:	a35ff0ef          	jal	ra,80003a26 <bfree>
      ip->addrs[i] = 0;
    80003ff6:	0004a023          	sw	zero,0(s1)
    80003ffa:	b7ed                	j	80003fe4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ffc:	0809a583          	lw	a1,128(s3)
    80004000:	ed91                	bnez	a1,8000401c <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004002:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004006:	854e                	mv	a0,s3
    80004008:	e25ff0ef          	jal	ra,80003e2c <iupdate>
}
    8000400c:	70a2                	ld	ra,40(sp)
    8000400e:	7402                	ld	s0,32(sp)
    80004010:	64e2                	ld	s1,24(sp)
    80004012:	6942                	ld	s2,16(sp)
    80004014:	69a2                	ld	s3,8(sp)
    80004016:	6a02                	ld	s4,0(sp)
    80004018:	6145                	addi	sp,sp,48
    8000401a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000401c:	0009a503          	lw	a0,0(s3)
    80004020:	80dff0ef          	jal	ra,8000382c <bread>
    80004024:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004026:	05850493          	addi	s1,a0,88
    8000402a:	45850913          	addi	s2,a0,1112
    8000402e:	a021                	j	80004036 <itrunc+0x6e>
    80004030:	0491                	addi	s1,s1,4
    80004032:	01248963          	beq	s1,s2,80004044 <itrunc+0x7c>
      if(a[j])
    80004036:	408c                	lw	a1,0(s1)
    80004038:	dde5                	beqz	a1,80004030 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    8000403a:	0009a503          	lw	a0,0(s3)
    8000403e:	9e9ff0ef          	jal	ra,80003a26 <bfree>
    80004042:	b7fd                	j	80004030 <itrunc+0x68>
    brelse(bp);
    80004044:	8552                	mv	a0,s4
    80004046:	8efff0ef          	jal	ra,80003934 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000404a:	0809a583          	lw	a1,128(s3)
    8000404e:	0009a503          	lw	a0,0(s3)
    80004052:	9d5ff0ef          	jal	ra,80003a26 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004056:	0809a023          	sw	zero,128(s3)
    8000405a:	b765                	j	80004002 <itrunc+0x3a>

000000008000405c <iput>:
{
    8000405c:	1101                	addi	sp,sp,-32
    8000405e:	ec06                	sd	ra,24(sp)
    80004060:	e822                	sd	s0,16(sp)
    80004062:	e426                	sd	s1,8(sp)
    80004064:	e04a                	sd	s2,0(sp)
    80004066:	1000                	addi	s0,sp,32
    80004068:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000406a:	00245517          	auipc	a0,0x245
    8000406e:	ece50513          	addi	a0,a0,-306 # 80248f38 <itable>
    80004072:	c4dfc0ef          	jal	ra,80000cbe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004076:	4498                	lw	a4,8(s1)
    80004078:	4785                	li	a5,1
    8000407a:	02f70163          	beq	a4,a5,8000409c <iput+0x40>
  ip->ref--;
    8000407e:	449c                	lw	a5,8(s1)
    80004080:	37fd                	addiw	a5,a5,-1
    80004082:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004084:	00245517          	auipc	a0,0x245
    80004088:	eb450513          	addi	a0,a0,-332 # 80248f38 <itable>
    8000408c:	ccbfc0ef          	jal	ra,80000d56 <release>
}
    80004090:	60e2                	ld	ra,24(sp)
    80004092:	6442                	ld	s0,16(sp)
    80004094:	64a2                	ld	s1,8(sp)
    80004096:	6902                	ld	s2,0(sp)
    80004098:	6105                	addi	sp,sp,32
    8000409a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000409c:	40bc                	lw	a5,64(s1)
    8000409e:	d3e5                	beqz	a5,8000407e <iput+0x22>
    800040a0:	04a49783          	lh	a5,74(s1)
    800040a4:	ffe9                	bnez	a5,8000407e <iput+0x22>
    acquiresleep(&ip->lock);
    800040a6:	01048913          	addi	s2,s1,16
    800040aa:	854a                	mv	a0,s2
    800040ac:	28f000ef          	jal	ra,80004b3a <acquiresleep>
    release(&itable.lock);
    800040b0:	00245517          	auipc	a0,0x245
    800040b4:	e8850513          	addi	a0,a0,-376 # 80248f38 <itable>
    800040b8:	c9ffc0ef          	jal	ra,80000d56 <release>
    itrunc(ip);
    800040bc:	8526                	mv	a0,s1
    800040be:	f0bff0ef          	jal	ra,80003fc8 <itrunc>
    ip->type = 0;
    800040c2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040c6:	8526                	mv	a0,s1
    800040c8:	d65ff0ef          	jal	ra,80003e2c <iupdate>
    ip->valid = 0;
    800040cc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040d0:	854a                	mv	a0,s2
    800040d2:	2af000ef          	jal	ra,80004b80 <releasesleep>
    acquire(&itable.lock);
    800040d6:	00245517          	auipc	a0,0x245
    800040da:	e6250513          	addi	a0,a0,-414 # 80248f38 <itable>
    800040de:	be1fc0ef          	jal	ra,80000cbe <acquire>
    800040e2:	bf71                	j	8000407e <iput+0x22>

00000000800040e4 <iunlockput>:
{
    800040e4:	1101                	addi	sp,sp,-32
    800040e6:	ec06                	sd	ra,24(sp)
    800040e8:	e822                	sd	s0,16(sp)
    800040ea:	e426                	sd	s1,8(sp)
    800040ec:	1000                	addi	s0,sp,32
    800040ee:	84aa                	mv	s1,a0
  iunlock(ip);
    800040f0:	e99ff0ef          	jal	ra,80003f88 <iunlock>
  iput(ip);
    800040f4:	8526                	mv	a0,s1
    800040f6:	f67ff0ef          	jal	ra,8000405c <iput>
}
    800040fa:	60e2                	ld	ra,24(sp)
    800040fc:	6442                	ld	s0,16(sp)
    800040fe:	64a2                	ld	s1,8(sp)
    80004100:	6105                	addi	sp,sp,32
    80004102:	8082                	ret

0000000080004104 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004104:	00245717          	auipc	a4,0x245
    80004108:	e2072703          	lw	a4,-480(a4) # 80248f24 <sb+0xc>
    8000410c:	4785                	li	a5,1
    8000410e:	0ae7ff63          	bgeu	a5,a4,800041cc <ireclaim+0xc8>
{
    80004112:	7139                	addi	sp,sp,-64
    80004114:	fc06                	sd	ra,56(sp)
    80004116:	f822                	sd	s0,48(sp)
    80004118:	f426                	sd	s1,40(sp)
    8000411a:	f04a                	sd	s2,32(sp)
    8000411c:	ec4e                	sd	s3,24(sp)
    8000411e:	e852                	sd	s4,16(sp)
    80004120:	e456                	sd	s5,8(sp)
    80004122:	e05a                	sd	s6,0(sp)
    80004124:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004126:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004128:	00050a1b          	sext.w	s4,a0
    8000412c:	00245a97          	auipc	s5,0x245
    80004130:	deca8a93          	addi	s5,s5,-532 # 80248f18 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80004134:	00004b17          	auipc	s6,0x4
    80004138:	48cb0b13          	addi	s6,s6,1164 # 800085c0 <syscalls+0x1c8>
    8000413c:	a099                	j	80004182 <ireclaim+0x7e>
    8000413e:	85ce                	mv	a1,s3
    80004140:	855a                	mv	a0,s6
    80004142:	b82fc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    80004146:	85ce                	mv	a1,s3
    80004148:	8552                	mv	a0,s4
    8000414a:	b29ff0ef          	jal	ra,80003c72 <iget>
    8000414e:	89aa                	mv	s3,a0
    brelse(bp);
    80004150:	854a                	mv	a0,s2
    80004152:	fe2ff0ef          	jal	ra,80003934 <brelse>
    if (ip) {
    80004156:	00098f63          	beqz	s3,80004174 <ireclaim+0x70>
      begin_op();
    8000415a:	762000ef          	jal	ra,800048bc <begin_op>
      ilock(ip);
    8000415e:	854e                	mv	a0,s3
    80004160:	d7fff0ef          	jal	ra,80003ede <ilock>
      iunlock(ip);
    80004164:	854e                	mv	a0,s3
    80004166:	e23ff0ef          	jal	ra,80003f88 <iunlock>
      iput(ip);
    8000416a:	854e                	mv	a0,s3
    8000416c:	ef1ff0ef          	jal	ra,8000405c <iput>
      end_op();
    80004170:	7bc000ef          	jal	ra,8000492c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004174:	0485                	addi	s1,s1,1
    80004176:	00caa703          	lw	a4,12(s5)
    8000417a:	0004879b          	sext.w	a5,s1
    8000417e:	02e7fd63          	bgeu	a5,a4,800041b8 <ireclaim+0xb4>
    80004182:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004186:	0044d793          	srli	a5,s1,0x4
    8000418a:	018aa583          	lw	a1,24(s5)
    8000418e:	9dbd                	addw	a1,a1,a5
    80004190:	8552                	mv	a0,s4
    80004192:	e9aff0ef          	jal	ra,8000382c <bread>
    80004196:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80004198:	05850793          	addi	a5,a0,88
    8000419c:	00f9f713          	andi	a4,s3,15
    800041a0:	071a                	slli	a4,a4,0x6
    800041a2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800041a4:	00079703          	lh	a4,0(a5)
    800041a8:	c701                	beqz	a4,800041b0 <ireclaim+0xac>
    800041aa:	00679783          	lh	a5,6(a5)
    800041ae:	dbc1                	beqz	a5,8000413e <ireclaim+0x3a>
    brelse(bp);
    800041b0:	854a                	mv	a0,s2
    800041b2:	f82ff0ef          	jal	ra,80003934 <brelse>
    if (ip) {
    800041b6:	bf7d                	j	80004174 <ireclaim+0x70>
}
    800041b8:	70e2                	ld	ra,56(sp)
    800041ba:	7442                	ld	s0,48(sp)
    800041bc:	74a2                	ld	s1,40(sp)
    800041be:	7902                	ld	s2,32(sp)
    800041c0:	69e2                	ld	s3,24(sp)
    800041c2:	6a42                	ld	s4,16(sp)
    800041c4:	6aa2                	ld	s5,8(sp)
    800041c6:	6b02                	ld	s6,0(sp)
    800041c8:	6121                	addi	sp,sp,64
    800041ca:	8082                	ret
    800041cc:	8082                	ret

00000000800041ce <fsinit>:
fsinit(int dev) {
    800041ce:	7179                	addi	sp,sp,-48
    800041d0:	f406                	sd	ra,40(sp)
    800041d2:	f022                	sd	s0,32(sp)
    800041d4:	ec26                	sd	s1,24(sp)
    800041d6:	e84a                	sd	s2,16(sp)
    800041d8:	e44e                	sd	s3,8(sp)
    800041da:	1800                	addi	s0,sp,48
    800041dc:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800041de:	4585                	li	a1,1
    800041e0:	e4cff0ef          	jal	ra,8000382c <bread>
    800041e4:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800041e6:	00245997          	auipc	s3,0x245
    800041ea:	d3298993          	addi	s3,s3,-718 # 80248f18 <sb>
    800041ee:	02000613          	li	a2,32
    800041f2:	05850593          	addi	a1,a0,88
    800041f6:	854e                	mv	a0,s3
    800041f8:	bf7fc0ef          	jal	ra,80000dee <memmove>
  brelse(bp);
    800041fc:	854a                	mv	a0,s2
    800041fe:	f36ff0ef          	jal	ra,80003934 <brelse>
  if(sb.magic != FSMAGIC)
    80004202:	0009a703          	lw	a4,0(s3)
    80004206:	102037b7          	lui	a5,0x10203
    8000420a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000420e:	02f71363          	bne	a4,a5,80004234 <fsinit+0x66>
  initlog(dev, &sb);
    80004212:	00245597          	auipc	a1,0x245
    80004216:	d0658593          	addi	a1,a1,-762 # 80248f18 <sb>
    8000421a:	8526                	mv	a0,s1
    8000421c:	616000ef          	jal	ra,80004832 <initlog>
  ireclaim(dev);
    80004220:	8526                	mv	a0,s1
    80004222:	ee3ff0ef          	jal	ra,80004104 <ireclaim>
}
    80004226:	70a2                	ld	ra,40(sp)
    80004228:	7402                	ld	s0,32(sp)
    8000422a:	64e2                	ld	s1,24(sp)
    8000422c:	6942                	ld	s2,16(sp)
    8000422e:	69a2                	ld	s3,8(sp)
    80004230:	6145                	addi	sp,sp,48
    80004232:	8082                	ret
    panic("invalid file system");
    80004234:	00004517          	auipc	a0,0x4
    80004238:	3ac50513          	addi	a0,a0,940 # 800085e0 <syscalls+0x1e8>
    8000423c:	d4efc0ef          	jal	ra,8000078a <panic>

0000000080004240 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004240:	1141                	addi	sp,sp,-16
    80004242:	e422                	sd	s0,8(sp)
    80004244:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004246:	411c                	lw	a5,0(a0)
    80004248:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000424a:	415c                	lw	a5,4(a0)
    8000424c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000424e:	04451783          	lh	a5,68(a0)
    80004252:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004256:	04a51783          	lh	a5,74(a0)
    8000425a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000425e:	04c56783          	lwu	a5,76(a0)
    80004262:	e99c                	sd	a5,16(a1)
}
    80004264:	6422                	ld	s0,8(sp)
    80004266:	0141                	addi	sp,sp,16
    80004268:	8082                	ret

000000008000426a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000426a:	457c                	lw	a5,76(a0)
    8000426c:	0cd7ef63          	bltu	a5,a3,8000434a <readi+0xe0>
{
    80004270:	7159                	addi	sp,sp,-112
    80004272:	f486                	sd	ra,104(sp)
    80004274:	f0a2                	sd	s0,96(sp)
    80004276:	eca6                	sd	s1,88(sp)
    80004278:	e8ca                	sd	s2,80(sp)
    8000427a:	e4ce                	sd	s3,72(sp)
    8000427c:	e0d2                	sd	s4,64(sp)
    8000427e:	fc56                	sd	s5,56(sp)
    80004280:	f85a                	sd	s6,48(sp)
    80004282:	f45e                	sd	s7,40(sp)
    80004284:	f062                	sd	s8,32(sp)
    80004286:	ec66                	sd	s9,24(sp)
    80004288:	e86a                	sd	s10,16(sp)
    8000428a:	e46e                	sd	s11,8(sp)
    8000428c:	1880                	addi	s0,sp,112
    8000428e:	8b2a                	mv	s6,a0
    80004290:	8bae                	mv	s7,a1
    80004292:	8a32                	mv	s4,a2
    80004294:	84b6                	mv	s1,a3
    80004296:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004298:	9f35                	addw	a4,a4,a3
    return 0;
    8000429a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000429c:	08d76663          	bltu	a4,a3,80004328 <readi+0xbe>
  if(off + n > ip->size)
    800042a0:	00e7f463          	bgeu	a5,a4,800042a8 <readi+0x3e>
    n = ip->size - off;
    800042a4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042a8:	080a8f63          	beqz	s5,80004346 <readi+0xdc>
    800042ac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800042ae:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800042b2:	5c7d                	li	s8,-1
    800042b4:	a80d                	j	800042e6 <readi+0x7c>
    800042b6:	020d1d93          	slli	s11,s10,0x20
    800042ba:	020ddd93          	srli	s11,s11,0x20
    800042be:	05890793          	addi	a5,s2,88
    800042c2:	86ee                	mv	a3,s11
    800042c4:	963e                	add	a2,a2,a5
    800042c6:	85d2                	mv	a1,s4
    800042c8:	855e                	mv	a0,s7
    800042ca:	d48fe0ef          	jal	ra,80002812 <either_copyout>
    800042ce:	05850763          	beq	a0,s8,8000431c <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042d2:	854a                	mv	a0,s2
    800042d4:	e60ff0ef          	jal	ra,80003934 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042d8:	013d09bb          	addw	s3,s10,s3
    800042dc:	009d04bb          	addw	s1,s10,s1
    800042e0:	9a6e                	add	s4,s4,s11
    800042e2:	0559f163          	bgeu	s3,s5,80004324 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800042e6:	00a4d59b          	srliw	a1,s1,0xa
    800042ea:	855a                	mv	a0,s6
    800042ec:	8bbff0ef          	jal	ra,80003ba6 <bmap>
    800042f0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042f4:	c985                	beqz	a1,80004324 <readi+0xba>
    bp = bread(ip->dev, addr);
    800042f6:	000b2503          	lw	a0,0(s6)
    800042fa:	d32ff0ef          	jal	ra,8000382c <bread>
    800042fe:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004300:	3ff4f613          	andi	a2,s1,1023
    80004304:	40cc87bb          	subw	a5,s9,a2
    80004308:	413a873b          	subw	a4,s5,s3
    8000430c:	8d3e                	mv	s10,a5
    8000430e:	2781                	sext.w	a5,a5
    80004310:	0007069b          	sext.w	a3,a4
    80004314:	faf6f1e3          	bgeu	a3,a5,800042b6 <readi+0x4c>
    80004318:	8d3a                	mv	s10,a4
    8000431a:	bf71                	j	800042b6 <readi+0x4c>
      brelse(bp);
    8000431c:	854a                	mv	a0,s2
    8000431e:	e16ff0ef          	jal	ra,80003934 <brelse>
      tot = -1;
    80004322:	59fd                	li	s3,-1
  }
  return tot;
    80004324:	0009851b          	sext.w	a0,s3
}
    80004328:	70a6                	ld	ra,104(sp)
    8000432a:	7406                	ld	s0,96(sp)
    8000432c:	64e6                	ld	s1,88(sp)
    8000432e:	6946                	ld	s2,80(sp)
    80004330:	69a6                	ld	s3,72(sp)
    80004332:	6a06                	ld	s4,64(sp)
    80004334:	7ae2                	ld	s5,56(sp)
    80004336:	7b42                	ld	s6,48(sp)
    80004338:	7ba2                	ld	s7,40(sp)
    8000433a:	7c02                	ld	s8,32(sp)
    8000433c:	6ce2                	ld	s9,24(sp)
    8000433e:	6d42                	ld	s10,16(sp)
    80004340:	6da2                	ld	s11,8(sp)
    80004342:	6165                	addi	sp,sp,112
    80004344:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004346:	89d6                	mv	s3,s5
    80004348:	bff1                	j	80004324 <readi+0xba>
    return 0;
    8000434a:	4501                	li	a0,0
}
    8000434c:	8082                	ret

000000008000434e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000434e:	457c                	lw	a5,76(a0)
    80004350:	0ed7ea63          	bltu	a5,a3,80004444 <writei+0xf6>
{
    80004354:	7159                	addi	sp,sp,-112
    80004356:	f486                	sd	ra,104(sp)
    80004358:	f0a2                	sd	s0,96(sp)
    8000435a:	eca6                	sd	s1,88(sp)
    8000435c:	e8ca                	sd	s2,80(sp)
    8000435e:	e4ce                	sd	s3,72(sp)
    80004360:	e0d2                	sd	s4,64(sp)
    80004362:	fc56                	sd	s5,56(sp)
    80004364:	f85a                	sd	s6,48(sp)
    80004366:	f45e                	sd	s7,40(sp)
    80004368:	f062                	sd	s8,32(sp)
    8000436a:	ec66                	sd	s9,24(sp)
    8000436c:	e86a                	sd	s10,16(sp)
    8000436e:	e46e                	sd	s11,8(sp)
    80004370:	1880                	addi	s0,sp,112
    80004372:	8aaa                	mv	s5,a0
    80004374:	8bae                	mv	s7,a1
    80004376:	8a32                	mv	s4,a2
    80004378:	8936                	mv	s2,a3
    8000437a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000437c:	00e687bb          	addw	a5,a3,a4
    80004380:	0cd7e463          	bltu	a5,a3,80004448 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004384:	00043737          	lui	a4,0x43
    80004388:	0cf76263          	bltu	a4,a5,8000444c <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000438c:	0a0b0a63          	beqz	s6,80004440 <writei+0xf2>
    80004390:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004392:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004396:	5c7d                	li	s8,-1
    80004398:	a825                	j	800043d0 <writei+0x82>
    8000439a:	020d1d93          	slli	s11,s10,0x20
    8000439e:	020ddd93          	srli	s11,s11,0x20
    800043a2:	05848793          	addi	a5,s1,88
    800043a6:	86ee                	mv	a3,s11
    800043a8:	8652                	mv	a2,s4
    800043aa:	85de                	mv	a1,s7
    800043ac:	953e                	add	a0,a0,a5
    800043ae:	caefe0ef          	jal	ra,8000285c <either_copyin>
    800043b2:	05850a63          	beq	a0,s8,80004406 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800043b6:	8526                	mv	a0,s1
    800043b8:	688000ef          	jal	ra,80004a40 <log_write>
    brelse(bp);
    800043bc:	8526                	mv	a0,s1
    800043be:	d76ff0ef          	jal	ra,80003934 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043c2:	013d09bb          	addw	s3,s10,s3
    800043c6:	012d093b          	addw	s2,s10,s2
    800043ca:	9a6e                	add	s4,s4,s11
    800043cc:	0569f063          	bgeu	s3,s6,8000440c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800043d0:	00a9559b          	srliw	a1,s2,0xa
    800043d4:	8556                	mv	a0,s5
    800043d6:	fd0ff0ef          	jal	ra,80003ba6 <bmap>
    800043da:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043de:	c59d                	beqz	a1,8000440c <writei+0xbe>
    bp = bread(ip->dev, addr);
    800043e0:	000aa503          	lw	a0,0(s5)
    800043e4:	c48ff0ef          	jal	ra,8000382c <bread>
    800043e8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043ea:	3ff97513          	andi	a0,s2,1023
    800043ee:	40ac87bb          	subw	a5,s9,a0
    800043f2:	413b073b          	subw	a4,s6,s3
    800043f6:	8d3e                	mv	s10,a5
    800043f8:	2781                	sext.w	a5,a5
    800043fa:	0007069b          	sext.w	a3,a4
    800043fe:	f8f6fee3          	bgeu	a3,a5,8000439a <writei+0x4c>
    80004402:	8d3a                	mv	s10,a4
    80004404:	bf59                	j	8000439a <writei+0x4c>
      brelse(bp);
    80004406:	8526                	mv	a0,s1
    80004408:	d2cff0ef          	jal	ra,80003934 <brelse>
  }

  if(off > ip->size)
    8000440c:	04caa783          	lw	a5,76(s5)
    80004410:	0127f463          	bgeu	a5,s2,80004418 <writei+0xca>
    ip->size = off;
    80004414:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004418:	8556                	mv	a0,s5
    8000441a:	a13ff0ef          	jal	ra,80003e2c <iupdate>

  return tot;
    8000441e:	0009851b          	sext.w	a0,s3
}
    80004422:	70a6                	ld	ra,104(sp)
    80004424:	7406                	ld	s0,96(sp)
    80004426:	64e6                	ld	s1,88(sp)
    80004428:	6946                	ld	s2,80(sp)
    8000442a:	69a6                	ld	s3,72(sp)
    8000442c:	6a06                	ld	s4,64(sp)
    8000442e:	7ae2                	ld	s5,56(sp)
    80004430:	7b42                	ld	s6,48(sp)
    80004432:	7ba2                	ld	s7,40(sp)
    80004434:	7c02                	ld	s8,32(sp)
    80004436:	6ce2                	ld	s9,24(sp)
    80004438:	6d42                	ld	s10,16(sp)
    8000443a:	6da2                	ld	s11,8(sp)
    8000443c:	6165                	addi	sp,sp,112
    8000443e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004440:	89da                	mv	s3,s6
    80004442:	bfd9                	j	80004418 <writei+0xca>
    return -1;
    80004444:	557d                	li	a0,-1
}
    80004446:	8082                	ret
    return -1;
    80004448:	557d                	li	a0,-1
    8000444a:	bfe1                	j	80004422 <writei+0xd4>
    return -1;
    8000444c:	557d                	li	a0,-1
    8000444e:	bfd1                	j	80004422 <writei+0xd4>

0000000080004450 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004450:	1141                	addi	sp,sp,-16
    80004452:	e406                	sd	ra,8(sp)
    80004454:	e022                	sd	s0,0(sp)
    80004456:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004458:	4639                	li	a2,14
    8000445a:	a05fc0ef          	jal	ra,80000e5e <strncmp>
}
    8000445e:	60a2                	ld	ra,8(sp)
    80004460:	6402                	ld	s0,0(sp)
    80004462:	0141                	addi	sp,sp,16
    80004464:	8082                	ret

0000000080004466 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004466:	7139                	addi	sp,sp,-64
    80004468:	fc06                	sd	ra,56(sp)
    8000446a:	f822                	sd	s0,48(sp)
    8000446c:	f426                	sd	s1,40(sp)
    8000446e:	f04a                	sd	s2,32(sp)
    80004470:	ec4e                	sd	s3,24(sp)
    80004472:	e852                	sd	s4,16(sp)
    80004474:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004476:	04451703          	lh	a4,68(a0)
    8000447a:	4785                	li	a5,1
    8000447c:	00f71a63          	bne	a4,a5,80004490 <dirlookup+0x2a>
    80004480:	892a                	mv	s2,a0
    80004482:	89ae                	mv	s3,a1
    80004484:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004486:	457c                	lw	a5,76(a0)
    80004488:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000448a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000448c:	e39d                	bnez	a5,800044b2 <dirlookup+0x4c>
    8000448e:	a095                	j	800044f2 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004490:	00004517          	auipc	a0,0x4
    80004494:	16850513          	addi	a0,a0,360 # 800085f8 <syscalls+0x200>
    80004498:	af2fc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    8000449c:	00004517          	auipc	a0,0x4
    800044a0:	17450513          	addi	a0,a0,372 # 80008610 <syscalls+0x218>
    800044a4:	ae6fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044a8:	24c1                	addiw	s1,s1,16
    800044aa:	04c92783          	lw	a5,76(s2)
    800044ae:	04f4f163          	bgeu	s1,a5,800044f0 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044b2:	4741                	li	a4,16
    800044b4:	86a6                	mv	a3,s1
    800044b6:	fc040613          	addi	a2,s0,-64
    800044ba:	4581                	li	a1,0
    800044bc:	854a                	mv	a0,s2
    800044be:	dadff0ef          	jal	ra,8000426a <readi>
    800044c2:	47c1                	li	a5,16
    800044c4:	fcf51ce3          	bne	a0,a5,8000449c <dirlookup+0x36>
    if(de.inum == 0)
    800044c8:	fc045783          	lhu	a5,-64(s0)
    800044cc:	dff1                	beqz	a5,800044a8 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800044ce:	fc240593          	addi	a1,s0,-62
    800044d2:	854e                	mv	a0,s3
    800044d4:	f7dff0ef          	jal	ra,80004450 <namecmp>
    800044d8:	f961                	bnez	a0,800044a8 <dirlookup+0x42>
      if(poff)
    800044da:	000a0463          	beqz	s4,800044e2 <dirlookup+0x7c>
        *poff = off;
    800044de:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800044e2:	fc045583          	lhu	a1,-64(s0)
    800044e6:	00092503          	lw	a0,0(s2)
    800044ea:	f88ff0ef          	jal	ra,80003c72 <iget>
    800044ee:	a011                	j	800044f2 <dirlookup+0x8c>
  return 0;
    800044f0:	4501                	li	a0,0
}
    800044f2:	70e2                	ld	ra,56(sp)
    800044f4:	7442                	ld	s0,48(sp)
    800044f6:	74a2                	ld	s1,40(sp)
    800044f8:	7902                	ld	s2,32(sp)
    800044fa:	69e2                	ld	s3,24(sp)
    800044fc:	6a42                	ld	s4,16(sp)
    800044fe:	6121                	addi	sp,sp,64
    80004500:	8082                	ret

0000000080004502 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004502:	711d                	addi	sp,sp,-96
    80004504:	ec86                	sd	ra,88(sp)
    80004506:	e8a2                	sd	s0,80(sp)
    80004508:	e4a6                	sd	s1,72(sp)
    8000450a:	e0ca                	sd	s2,64(sp)
    8000450c:	fc4e                	sd	s3,56(sp)
    8000450e:	f852                	sd	s4,48(sp)
    80004510:	f456                	sd	s5,40(sp)
    80004512:	f05a                	sd	s6,32(sp)
    80004514:	ec5e                	sd	s7,24(sp)
    80004516:	e862                	sd	s8,16(sp)
    80004518:	e466                	sd	s9,8(sp)
    8000451a:	1080                	addi	s0,sp,96
    8000451c:	84aa                	mv	s1,a0
    8000451e:	8aae                	mv	s5,a1
    80004520:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004522:	00054703          	lbu	a4,0(a0)
    80004526:	02f00793          	li	a5,47
    8000452a:	00f70f63          	beq	a4,a5,80004548 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000452e:	e90fd0ef          	jal	ra,80001bbe <myproc>
    80004532:	15053503          	ld	a0,336(a0)
    80004536:	973ff0ef          	jal	ra,80003ea8 <idup>
    8000453a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000453c:	02f00913          	li	s2,47
  len = path - s;
    80004540:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004542:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004544:	4b85                	li	s7,1
    80004546:	a861                	j	800045de <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80004548:	4585                	li	a1,1
    8000454a:	4505                	li	a0,1
    8000454c:	f26ff0ef          	jal	ra,80003c72 <iget>
    80004550:	89aa                	mv	s3,a0
    80004552:	b7ed                	j	8000453c <namex+0x3a>
      iunlockput(ip);
    80004554:	854e                	mv	a0,s3
    80004556:	b8fff0ef          	jal	ra,800040e4 <iunlockput>
      return 0;
    8000455a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000455c:	854e                	mv	a0,s3
    8000455e:	60e6                	ld	ra,88(sp)
    80004560:	6446                	ld	s0,80(sp)
    80004562:	64a6                	ld	s1,72(sp)
    80004564:	6906                	ld	s2,64(sp)
    80004566:	79e2                	ld	s3,56(sp)
    80004568:	7a42                	ld	s4,48(sp)
    8000456a:	7aa2                	ld	s5,40(sp)
    8000456c:	7b02                	ld	s6,32(sp)
    8000456e:	6be2                	ld	s7,24(sp)
    80004570:	6c42                	ld	s8,16(sp)
    80004572:	6ca2                	ld	s9,8(sp)
    80004574:	6125                	addi	sp,sp,96
    80004576:	8082                	ret
      iunlock(ip);
    80004578:	854e                	mv	a0,s3
    8000457a:	a0fff0ef          	jal	ra,80003f88 <iunlock>
      return ip;
    8000457e:	bff9                	j	8000455c <namex+0x5a>
      iunlockput(ip);
    80004580:	854e                	mv	a0,s3
    80004582:	b63ff0ef          	jal	ra,800040e4 <iunlockput>
      return 0;
    80004586:	89e6                	mv	s3,s9
    80004588:	bfd1                	j	8000455c <namex+0x5a>
  len = path - s;
    8000458a:	40b48633          	sub	a2,s1,a1
    8000458e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004592:	079c5c63          	bge	s8,s9,8000460a <namex+0x108>
    memmove(name, s, DIRSIZ);
    80004596:	4639                	li	a2,14
    80004598:	8552                	mv	a0,s4
    8000459a:	855fc0ef          	jal	ra,80000dee <memmove>
  while(*path == '/')
    8000459e:	0004c783          	lbu	a5,0(s1)
    800045a2:	01279763          	bne	a5,s2,800045b0 <namex+0xae>
    path++;
    800045a6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045a8:	0004c783          	lbu	a5,0(s1)
    800045ac:	ff278de3          	beq	a5,s2,800045a6 <namex+0xa4>
    ilock(ip);
    800045b0:	854e                	mv	a0,s3
    800045b2:	92dff0ef          	jal	ra,80003ede <ilock>
    if(ip->type != T_DIR){
    800045b6:	04499783          	lh	a5,68(s3)
    800045ba:	f9779de3          	bne	a5,s7,80004554 <namex+0x52>
    if(nameiparent && *path == '\0'){
    800045be:	000a8563          	beqz	s5,800045c8 <namex+0xc6>
    800045c2:	0004c783          	lbu	a5,0(s1)
    800045c6:	dbcd                	beqz	a5,80004578 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045c8:	865a                	mv	a2,s6
    800045ca:	85d2                	mv	a1,s4
    800045cc:	854e                	mv	a0,s3
    800045ce:	e99ff0ef          	jal	ra,80004466 <dirlookup>
    800045d2:	8caa                	mv	s9,a0
    800045d4:	d555                	beqz	a0,80004580 <namex+0x7e>
    iunlockput(ip);
    800045d6:	854e                	mv	a0,s3
    800045d8:	b0dff0ef          	jal	ra,800040e4 <iunlockput>
    ip = next;
    800045dc:	89e6                	mv	s3,s9
  while(*path == '/')
    800045de:	0004c783          	lbu	a5,0(s1)
    800045e2:	05279363          	bne	a5,s2,80004628 <namex+0x126>
    path++;
    800045e6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045e8:	0004c783          	lbu	a5,0(s1)
    800045ec:	ff278de3          	beq	a5,s2,800045e6 <namex+0xe4>
  if(*path == 0)
    800045f0:	c78d                	beqz	a5,8000461a <namex+0x118>
    path++;
    800045f2:	85a6                	mv	a1,s1
  len = path - s;
    800045f4:	8cda                	mv	s9,s6
    800045f6:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800045f8:	01278963          	beq	a5,s2,8000460a <namex+0x108>
    800045fc:	d7d9                	beqz	a5,8000458a <namex+0x88>
    path++;
    800045fe:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004600:	0004c783          	lbu	a5,0(s1)
    80004604:	ff279ce3          	bne	a5,s2,800045fc <namex+0xfa>
    80004608:	b749                	j	8000458a <namex+0x88>
    memmove(name, s, len);
    8000460a:	2601                	sext.w	a2,a2
    8000460c:	8552                	mv	a0,s4
    8000460e:	fe0fc0ef          	jal	ra,80000dee <memmove>
    name[len] = 0;
    80004612:	9cd2                	add	s9,s9,s4
    80004614:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004618:	b759                	j	8000459e <namex+0x9c>
  if(nameiparent){
    8000461a:	f40a81e3          	beqz	s5,8000455c <namex+0x5a>
    iput(ip);
    8000461e:	854e                	mv	a0,s3
    80004620:	a3dff0ef          	jal	ra,8000405c <iput>
    return 0;
    80004624:	4981                	li	s3,0
    80004626:	bf1d                	j	8000455c <namex+0x5a>
  if(*path == 0)
    80004628:	dbed                	beqz	a5,8000461a <namex+0x118>
  while(*path != '/' && *path != 0)
    8000462a:	0004c783          	lbu	a5,0(s1)
    8000462e:	85a6                	mv	a1,s1
    80004630:	b7f1                	j	800045fc <namex+0xfa>

0000000080004632 <dirlink>:
{
    80004632:	7139                	addi	sp,sp,-64
    80004634:	fc06                	sd	ra,56(sp)
    80004636:	f822                	sd	s0,48(sp)
    80004638:	f426                	sd	s1,40(sp)
    8000463a:	f04a                	sd	s2,32(sp)
    8000463c:	ec4e                	sd	s3,24(sp)
    8000463e:	e852                	sd	s4,16(sp)
    80004640:	0080                	addi	s0,sp,64
    80004642:	892a                	mv	s2,a0
    80004644:	8a2e                	mv	s4,a1
    80004646:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004648:	4601                	li	a2,0
    8000464a:	e1dff0ef          	jal	ra,80004466 <dirlookup>
    8000464e:	e52d                	bnez	a0,800046b8 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004650:	04c92483          	lw	s1,76(s2)
    80004654:	c48d                	beqz	s1,8000467e <dirlink+0x4c>
    80004656:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004658:	4741                	li	a4,16
    8000465a:	86a6                	mv	a3,s1
    8000465c:	fc040613          	addi	a2,s0,-64
    80004660:	4581                	li	a1,0
    80004662:	854a                	mv	a0,s2
    80004664:	c07ff0ef          	jal	ra,8000426a <readi>
    80004668:	47c1                	li	a5,16
    8000466a:	04f51b63          	bne	a0,a5,800046c0 <dirlink+0x8e>
    if(de.inum == 0)
    8000466e:	fc045783          	lhu	a5,-64(s0)
    80004672:	c791                	beqz	a5,8000467e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004674:	24c1                	addiw	s1,s1,16
    80004676:	04c92783          	lw	a5,76(s2)
    8000467a:	fcf4efe3          	bltu	s1,a5,80004658 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000467e:	4639                	li	a2,14
    80004680:	85d2                	mv	a1,s4
    80004682:	fc240513          	addi	a0,s0,-62
    80004686:	815fc0ef          	jal	ra,80000e9a <strncpy>
  de.inum = inum;
    8000468a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000468e:	4741                	li	a4,16
    80004690:	86a6                	mv	a3,s1
    80004692:	fc040613          	addi	a2,s0,-64
    80004696:	4581                	li	a1,0
    80004698:	854a                	mv	a0,s2
    8000469a:	cb5ff0ef          	jal	ra,8000434e <writei>
    8000469e:	1541                	addi	a0,a0,-16
    800046a0:	00a03533          	snez	a0,a0
    800046a4:	40a00533          	neg	a0,a0
}
    800046a8:	70e2                	ld	ra,56(sp)
    800046aa:	7442                	ld	s0,48(sp)
    800046ac:	74a2                	ld	s1,40(sp)
    800046ae:	7902                	ld	s2,32(sp)
    800046b0:	69e2                	ld	s3,24(sp)
    800046b2:	6a42                	ld	s4,16(sp)
    800046b4:	6121                	addi	sp,sp,64
    800046b6:	8082                	ret
    iput(ip);
    800046b8:	9a5ff0ef          	jal	ra,8000405c <iput>
    return -1;
    800046bc:	557d                	li	a0,-1
    800046be:	b7ed                	j	800046a8 <dirlink+0x76>
      panic("dirlink read");
    800046c0:	00004517          	auipc	a0,0x4
    800046c4:	f6050513          	addi	a0,a0,-160 # 80008620 <syscalls+0x228>
    800046c8:	8c2fc0ef          	jal	ra,8000078a <panic>

00000000800046cc <namei>:

struct inode*
namei(char *path)
{
    800046cc:	1101                	addi	sp,sp,-32
    800046ce:	ec06                	sd	ra,24(sp)
    800046d0:	e822                	sd	s0,16(sp)
    800046d2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800046d4:	fe040613          	addi	a2,s0,-32
    800046d8:	4581                	li	a1,0
    800046da:	e29ff0ef          	jal	ra,80004502 <namex>
}
    800046de:	60e2                	ld	ra,24(sp)
    800046e0:	6442                	ld	s0,16(sp)
    800046e2:	6105                	addi	sp,sp,32
    800046e4:	8082                	ret

00000000800046e6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800046e6:	1141                	addi	sp,sp,-16
    800046e8:	e406                	sd	ra,8(sp)
    800046ea:	e022                	sd	s0,0(sp)
    800046ec:	0800                	addi	s0,sp,16
    800046ee:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800046f0:	4585                	li	a1,1
    800046f2:	e11ff0ef          	jal	ra,80004502 <namex>
}
    800046f6:	60a2                	ld	ra,8(sp)
    800046f8:	6402                	ld	s0,0(sp)
    800046fa:	0141                	addi	sp,sp,16
    800046fc:	8082                	ret

00000000800046fe <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046fe:	1101                	addi	sp,sp,-32
    80004700:	ec06                	sd	ra,24(sp)
    80004702:	e822                	sd	s0,16(sp)
    80004704:	e426                	sd	s1,8(sp)
    80004706:	e04a                	sd	s2,0(sp)
    80004708:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000470a:	00246917          	auipc	s2,0x246
    8000470e:	2d690913          	addi	s2,s2,726 # 8024a9e0 <log>
    80004712:	01892583          	lw	a1,24(s2)
    80004716:	02492503          	lw	a0,36(s2)
    8000471a:	912ff0ef          	jal	ra,8000382c <bread>
    8000471e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004720:	02892683          	lw	a3,40(s2)
    80004724:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004726:	02d05763          	blez	a3,80004754 <write_head+0x56>
    8000472a:	00246797          	auipc	a5,0x246
    8000472e:	2e278793          	addi	a5,a5,738 # 8024aa0c <log+0x2c>
    80004732:	05c50713          	addi	a4,a0,92
    80004736:	36fd                	addiw	a3,a3,-1
    80004738:	1682                	slli	a3,a3,0x20
    8000473a:	9281                	srli	a3,a3,0x20
    8000473c:	068a                	slli	a3,a3,0x2
    8000473e:	00246617          	auipc	a2,0x246
    80004742:	2d260613          	addi	a2,a2,722 # 8024aa10 <log+0x30>
    80004746:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004748:	4390                	lw	a2,0(a5)
    8000474a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000474c:	0791                	addi	a5,a5,4
    8000474e:	0711                	addi	a4,a4,4
    80004750:	fed79ce3          	bne	a5,a3,80004748 <write_head+0x4a>
  }
  bwrite(buf);
    80004754:	8526                	mv	a0,s1
    80004756:	9acff0ef          	jal	ra,80003902 <bwrite>
  brelse(buf);
    8000475a:	8526                	mv	a0,s1
    8000475c:	9d8ff0ef          	jal	ra,80003934 <brelse>
}
    80004760:	60e2                	ld	ra,24(sp)
    80004762:	6442                	ld	s0,16(sp)
    80004764:	64a2                	ld	s1,8(sp)
    80004766:	6902                	ld	s2,0(sp)
    80004768:	6105                	addi	sp,sp,32
    8000476a:	8082                	ret

000000008000476c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000476c:	00246797          	auipc	a5,0x246
    80004770:	29c7a783          	lw	a5,668(a5) # 8024aa08 <log+0x28>
    80004774:	0af05e63          	blez	a5,80004830 <install_trans+0xc4>
{
    80004778:	715d                	addi	sp,sp,-80
    8000477a:	e486                	sd	ra,72(sp)
    8000477c:	e0a2                	sd	s0,64(sp)
    8000477e:	fc26                	sd	s1,56(sp)
    80004780:	f84a                	sd	s2,48(sp)
    80004782:	f44e                	sd	s3,40(sp)
    80004784:	f052                	sd	s4,32(sp)
    80004786:	ec56                	sd	s5,24(sp)
    80004788:	e85a                	sd	s6,16(sp)
    8000478a:	e45e                	sd	s7,8(sp)
    8000478c:	0880                	addi	s0,sp,80
    8000478e:	8b2a                	mv	s6,a0
    80004790:	00246a97          	auipc	s5,0x246
    80004794:	27ca8a93          	addi	s5,s5,636 # 8024aa0c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004798:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000479a:	00004b97          	auipc	s7,0x4
    8000479e:	e96b8b93          	addi	s7,s7,-362 # 80008630 <syscalls+0x238>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047a2:	00246a17          	auipc	s4,0x246
    800047a6:	23ea0a13          	addi	s4,s4,574 # 8024a9e0 <log>
    800047aa:	a025                	j	800047d2 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800047ac:	000aa603          	lw	a2,0(s5)
    800047b0:	85ce                	mv	a1,s3
    800047b2:	855e                	mv	a0,s7
    800047b4:	d11fb0ef          	jal	ra,800004c4 <printf>
    800047b8:	a839                	j	800047d6 <install_trans+0x6a>
    brelse(lbuf);
    800047ba:	854a                	mv	a0,s2
    800047bc:	978ff0ef          	jal	ra,80003934 <brelse>
    brelse(dbuf);
    800047c0:	8526                	mv	a0,s1
    800047c2:	972ff0ef          	jal	ra,80003934 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047c6:	2985                	addiw	s3,s3,1
    800047c8:	0a91                	addi	s5,s5,4
    800047ca:	028a2783          	lw	a5,40(s4)
    800047ce:	04f9d663          	bge	s3,a5,8000481a <install_trans+0xae>
    if(recovering) {
    800047d2:	fc0b1de3          	bnez	s6,800047ac <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047d6:	018a2583          	lw	a1,24(s4)
    800047da:	013585bb          	addw	a1,a1,s3
    800047de:	2585                	addiw	a1,a1,1
    800047e0:	024a2503          	lw	a0,36(s4)
    800047e4:	848ff0ef          	jal	ra,8000382c <bread>
    800047e8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800047ea:	000aa583          	lw	a1,0(s5)
    800047ee:	024a2503          	lw	a0,36(s4)
    800047f2:	83aff0ef          	jal	ra,8000382c <bread>
    800047f6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047f8:	40000613          	li	a2,1024
    800047fc:	05890593          	addi	a1,s2,88
    80004800:	05850513          	addi	a0,a0,88
    80004804:	deafc0ef          	jal	ra,80000dee <memmove>
    bwrite(dbuf);  // write dst to disk
    80004808:	8526                	mv	a0,s1
    8000480a:	8f8ff0ef          	jal	ra,80003902 <bwrite>
    if(recovering == 0)
    8000480e:	fa0b16e3          	bnez	s6,800047ba <install_trans+0x4e>
      bunpin(dbuf);
    80004812:	8526                	mv	a0,s1
    80004814:	9deff0ef          	jal	ra,800039f2 <bunpin>
    80004818:	b74d                	j	800047ba <install_trans+0x4e>
}
    8000481a:	60a6                	ld	ra,72(sp)
    8000481c:	6406                	ld	s0,64(sp)
    8000481e:	74e2                	ld	s1,56(sp)
    80004820:	7942                	ld	s2,48(sp)
    80004822:	79a2                	ld	s3,40(sp)
    80004824:	7a02                	ld	s4,32(sp)
    80004826:	6ae2                	ld	s5,24(sp)
    80004828:	6b42                	ld	s6,16(sp)
    8000482a:	6ba2                	ld	s7,8(sp)
    8000482c:	6161                	addi	sp,sp,80
    8000482e:	8082                	ret
    80004830:	8082                	ret

0000000080004832 <initlog>:
{
    80004832:	7179                	addi	sp,sp,-48
    80004834:	f406                	sd	ra,40(sp)
    80004836:	f022                	sd	s0,32(sp)
    80004838:	ec26                	sd	s1,24(sp)
    8000483a:	e84a                	sd	s2,16(sp)
    8000483c:	e44e                	sd	s3,8(sp)
    8000483e:	1800                	addi	s0,sp,48
    80004840:	892a                	mv	s2,a0
    80004842:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004844:	00246497          	auipc	s1,0x246
    80004848:	19c48493          	addi	s1,s1,412 # 8024a9e0 <log>
    8000484c:	00004597          	auipc	a1,0x4
    80004850:	e0458593          	addi	a1,a1,-508 # 80008650 <syscalls+0x258>
    80004854:	8526                	mv	a0,s1
    80004856:	be8fc0ef          	jal	ra,80000c3e <initlock>
  log.start = sb->logstart;
    8000485a:	0149a583          	lw	a1,20(s3)
    8000485e:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004860:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004864:	854a                	mv	a0,s2
    80004866:	fc7fe0ef          	jal	ra,8000382c <bread>
  log.lh.n = lh->n;
    8000486a:	4d34                	lw	a3,88(a0)
    8000486c:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000486e:	02d05563          	blez	a3,80004898 <initlog+0x66>
    80004872:	05c50793          	addi	a5,a0,92
    80004876:	00246717          	auipc	a4,0x246
    8000487a:	19670713          	addi	a4,a4,406 # 8024aa0c <log+0x2c>
    8000487e:	36fd                	addiw	a3,a3,-1
    80004880:	1682                	slli	a3,a3,0x20
    80004882:	9281                	srli	a3,a3,0x20
    80004884:	068a                	slli	a3,a3,0x2
    80004886:	06050613          	addi	a2,a0,96
    8000488a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000488c:	4390                	lw	a2,0(a5)
    8000488e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004890:	0791                	addi	a5,a5,4
    80004892:	0711                	addi	a4,a4,4
    80004894:	fed79ce3          	bne	a5,a3,8000488c <initlog+0x5a>
  brelse(buf);
    80004898:	89cff0ef          	jal	ra,80003934 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000489c:	4505                	li	a0,1
    8000489e:	ecfff0ef          	jal	ra,8000476c <install_trans>
  log.lh.n = 0;
    800048a2:	00246797          	auipc	a5,0x246
    800048a6:	1607a323          	sw	zero,358(a5) # 8024aa08 <log+0x28>
  write_head(); // clear the log
    800048aa:	e55ff0ef          	jal	ra,800046fe <write_head>
}
    800048ae:	70a2                	ld	ra,40(sp)
    800048b0:	7402                	ld	s0,32(sp)
    800048b2:	64e2                	ld	s1,24(sp)
    800048b4:	6942                	ld	s2,16(sp)
    800048b6:	69a2                	ld	s3,8(sp)
    800048b8:	6145                	addi	sp,sp,48
    800048ba:	8082                	ret

00000000800048bc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800048bc:	1101                	addi	sp,sp,-32
    800048be:	ec06                	sd	ra,24(sp)
    800048c0:	e822                	sd	s0,16(sp)
    800048c2:	e426                	sd	s1,8(sp)
    800048c4:	e04a                	sd	s2,0(sp)
    800048c6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800048c8:	00246517          	auipc	a0,0x246
    800048cc:	11850513          	addi	a0,a0,280 # 8024a9e0 <log>
    800048d0:	beefc0ef          	jal	ra,80000cbe <acquire>
  while(1){
    if(log.committing){
    800048d4:	00246497          	auipc	s1,0x246
    800048d8:	10c48493          	addi	s1,s1,268 # 8024a9e0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800048dc:	4979                	li	s2,30
    800048de:	a029                	j	800048e8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800048e0:	85a6                	mv	a1,s1
    800048e2:	8526                	mv	a0,s1
    800048e4:	bd3fd0ef          	jal	ra,800024b6 <sleep>
    if(log.committing){
    800048e8:	509c                	lw	a5,32(s1)
    800048ea:	fbfd                	bnez	a5,800048e0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800048ec:	4cdc                	lw	a5,28(s1)
    800048ee:	0017871b          	addiw	a4,a5,1
    800048f2:	0007069b          	sext.w	a3,a4
    800048f6:	0027179b          	slliw	a5,a4,0x2
    800048fa:	9fb9                	addw	a5,a5,a4
    800048fc:	0017979b          	slliw	a5,a5,0x1
    80004900:	5498                	lw	a4,40(s1)
    80004902:	9fb9                	addw	a5,a5,a4
    80004904:	00f95763          	bge	s2,a5,80004912 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004908:	85a6                	mv	a1,s1
    8000490a:	8526                	mv	a0,s1
    8000490c:	babfd0ef          	jal	ra,800024b6 <sleep>
    80004910:	bfe1                	j	800048e8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004912:	00246517          	auipc	a0,0x246
    80004916:	0ce50513          	addi	a0,a0,206 # 8024a9e0 <log>
    8000491a:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    8000491c:	c3afc0ef          	jal	ra,80000d56 <release>
      break;
    }
  }
}
    80004920:	60e2                	ld	ra,24(sp)
    80004922:	6442                	ld	s0,16(sp)
    80004924:	64a2                	ld	s1,8(sp)
    80004926:	6902                	ld	s2,0(sp)
    80004928:	6105                	addi	sp,sp,32
    8000492a:	8082                	ret

000000008000492c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000492c:	7139                	addi	sp,sp,-64
    8000492e:	fc06                	sd	ra,56(sp)
    80004930:	f822                	sd	s0,48(sp)
    80004932:	f426                	sd	s1,40(sp)
    80004934:	f04a                	sd	s2,32(sp)
    80004936:	ec4e                	sd	s3,24(sp)
    80004938:	e852                	sd	s4,16(sp)
    8000493a:	e456                	sd	s5,8(sp)
    8000493c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000493e:	00246497          	auipc	s1,0x246
    80004942:	0a248493          	addi	s1,s1,162 # 8024a9e0 <log>
    80004946:	8526                	mv	a0,s1
    80004948:	b76fc0ef          	jal	ra,80000cbe <acquire>
  log.outstanding -= 1;
    8000494c:	4cdc                	lw	a5,28(s1)
    8000494e:	37fd                	addiw	a5,a5,-1
    80004950:	0007891b          	sext.w	s2,a5
    80004954:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004956:	509c                	lw	a5,32(s1)
    80004958:	ef9d                	bnez	a5,80004996 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    8000495a:	04091463          	bnez	s2,800049a2 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000495e:	00246497          	auipc	s1,0x246
    80004962:	08248493          	addi	s1,s1,130 # 8024a9e0 <log>
    80004966:	4785                	li	a5,1
    80004968:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000496a:	8526                	mv	a0,s1
    8000496c:	beafc0ef          	jal	ra,80000d56 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004970:	549c                	lw	a5,40(s1)
    80004972:	04f04b63          	bgtz	a5,800049c8 <end_op+0x9c>
    acquire(&log.lock);
    80004976:	00246497          	auipc	s1,0x246
    8000497a:	06a48493          	addi	s1,s1,106 # 8024a9e0 <log>
    8000497e:	8526                	mv	a0,s1
    80004980:	b3efc0ef          	jal	ra,80000cbe <acquire>
    log.committing = 0;
    80004984:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004988:	8526                	mv	a0,s1
    8000498a:	b79fd0ef          	jal	ra,80002502 <wakeup>
    release(&log.lock);
    8000498e:	8526                	mv	a0,s1
    80004990:	bc6fc0ef          	jal	ra,80000d56 <release>
}
    80004994:	a00d                	j	800049b6 <end_op+0x8a>
    panic("log.committing");
    80004996:	00004517          	auipc	a0,0x4
    8000499a:	cc250513          	addi	a0,a0,-830 # 80008658 <syscalls+0x260>
    8000499e:	dedfb0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    800049a2:	00246497          	auipc	s1,0x246
    800049a6:	03e48493          	addi	s1,s1,62 # 8024a9e0 <log>
    800049aa:	8526                	mv	a0,s1
    800049ac:	b57fd0ef          	jal	ra,80002502 <wakeup>
  release(&log.lock);
    800049b0:	8526                	mv	a0,s1
    800049b2:	ba4fc0ef          	jal	ra,80000d56 <release>
}
    800049b6:	70e2                	ld	ra,56(sp)
    800049b8:	7442                	ld	s0,48(sp)
    800049ba:	74a2                	ld	s1,40(sp)
    800049bc:	7902                	ld	s2,32(sp)
    800049be:	69e2                	ld	s3,24(sp)
    800049c0:	6a42                	ld	s4,16(sp)
    800049c2:	6aa2                	ld	s5,8(sp)
    800049c4:	6121                	addi	sp,sp,64
    800049c6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800049c8:	00246a97          	auipc	s5,0x246
    800049cc:	044a8a93          	addi	s5,s5,68 # 8024aa0c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049d0:	00246a17          	auipc	s4,0x246
    800049d4:	010a0a13          	addi	s4,s4,16 # 8024a9e0 <log>
    800049d8:	018a2583          	lw	a1,24(s4)
    800049dc:	012585bb          	addw	a1,a1,s2
    800049e0:	2585                	addiw	a1,a1,1
    800049e2:	024a2503          	lw	a0,36(s4)
    800049e6:	e47fe0ef          	jal	ra,8000382c <bread>
    800049ea:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049ec:	000aa583          	lw	a1,0(s5)
    800049f0:	024a2503          	lw	a0,36(s4)
    800049f4:	e39fe0ef          	jal	ra,8000382c <bread>
    800049f8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049fa:	40000613          	li	a2,1024
    800049fe:	05850593          	addi	a1,a0,88
    80004a02:	05848513          	addi	a0,s1,88
    80004a06:	be8fc0ef          	jal	ra,80000dee <memmove>
    bwrite(to);  // write the log
    80004a0a:	8526                	mv	a0,s1
    80004a0c:	ef7fe0ef          	jal	ra,80003902 <bwrite>
    brelse(from);
    80004a10:	854e                	mv	a0,s3
    80004a12:	f23fe0ef          	jal	ra,80003934 <brelse>
    brelse(to);
    80004a16:	8526                	mv	a0,s1
    80004a18:	f1dfe0ef          	jal	ra,80003934 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a1c:	2905                	addiw	s2,s2,1
    80004a1e:	0a91                	addi	s5,s5,4
    80004a20:	028a2783          	lw	a5,40(s4)
    80004a24:	faf94ae3          	blt	s2,a5,800049d8 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a28:	cd7ff0ef          	jal	ra,800046fe <write_head>
    install_trans(0); // Now install writes to home locations
    80004a2c:	4501                	li	a0,0
    80004a2e:	d3fff0ef          	jal	ra,8000476c <install_trans>
    log.lh.n = 0;
    80004a32:	00246797          	auipc	a5,0x246
    80004a36:	fc07ab23          	sw	zero,-42(a5) # 8024aa08 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004a3a:	cc5ff0ef          	jal	ra,800046fe <write_head>
    80004a3e:	bf25                	j	80004976 <end_op+0x4a>

0000000080004a40 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a40:	1101                	addi	sp,sp,-32
    80004a42:	ec06                	sd	ra,24(sp)
    80004a44:	e822                	sd	s0,16(sp)
    80004a46:	e426                	sd	s1,8(sp)
    80004a48:	e04a                	sd	s2,0(sp)
    80004a4a:	1000                	addi	s0,sp,32
    80004a4c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a4e:	00246917          	auipc	s2,0x246
    80004a52:	f9290913          	addi	s2,s2,-110 # 8024a9e0 <log>
    80004a56:	854a                	mv	a0,s2
    80004a58:	a66fc0ef          	jal	ra,80000cbe <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004a5c:	02892603          	lw	a2,40(s2)
    80004a60:	47f5                	li	a5,29
    80004a62:	04c7cc63          	blt	a5,a2,80004aba <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a66:	00246797          	auipc	a5,0x246
    80004a6a:	f967a783          	lw	a5,-106(a5) # 8024a9fc <log+0x1c>
    80004a6e:	04f05c63          	blez	a5,80004ac6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a72:	4781                	li	a5,0
    80004a74:	04c05f63          	blez	a2,80004ad2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a78:	44cc                	lw	a1,12(s1)
    80004a7a:	00246717          	auipc	a4,0x246
    80004a7e:	f9270713          	addi	a4,a4,-110 # 8024aa0c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004a82:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a84:	4314                	lw	a3,0(a4)
    80004a86:	04b68663          	beq	a3,a1,80004ad2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004a8a:	2785                	addiw	a5,a5,1
    80004a8c:	0711                	addi	a4,a4,4
    80004a8e:	fef61be3          	bne	a2,a5,80004a84 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a92:	0621                	addi	a2,a2,8
    80004a94:	060a                	slli	a2,a2,0x2
    80004a96:	00246797          	auipc	a5,0x246
    80004a9a:	f4a78793          	addi	a5,a5,-182 # 8024a9e0 <log>
    80004a9e:	963e                	add	a2,a2,a5
    80004aa0:	44dc                	lw	a5,12(s1)
    80004aa2:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004aa4:	8526                	mv	a0,s1
    80004aa6:	f19fe0ef          	jal	ra,800039be <bpin>
    log.lh.n++;
    80004aaa:	00246717          	auipc	a4,0x246
    80004aae:	f3670713          	addi	a4,a4,-202 # 8024a9e0 <log>
    80004ab2:	571c                	lw	a5,40(a4)
    80004ab4:	2785                	addiw	a5,a5,1
    80004ab6:	d71c                	sw	a5,40(a4)
    80004ab8:	a815                	j	80004aec <log_write+0xac>
    panic("too big a transaction");
    80004aba:	00004517          	auipc	a0,0x4
    80004abe:	bae50513          	addi	a0,a0,-1106 # 80008668 <syscalls+0x270>
    80004ac2:	cc9fb0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80004ac6:	00004517          	auipc	a0,0x4
    80004aca:	bba50513          	addi	a0,a0,-1094 # 80008680 <syscalls+0x288>
    80004ace:	cbdfb0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80004ad2:	00878713          	addi	a4,a5,8
    80004ad6:	00271693          	slli	a3,a4,0x2
    80004ada:	00246717          	auipc	a4,0x246
    80004ade:	f0670713          	addi	a4,a4,-250 # 8024a9e0 <log>
    80004ae2:	9736                	add	a4,a4,a3
    80004ae4:	44d4                	lw	a3,12(s1)
    80004ae6:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004ae8:	faf60ee3          	beq	a2,a5,80004aa4 <log_write+0x64>
  }
  release(&log.lock);
    80004aec:	00246517          	auipc	a0,0x246
    80004af0:	ef450513          	addi	a0,a0,-268 # 8024a9e0 <log>
    80004af4:	a62fc0ef          	jal	ra,80000d56 <release>
}
    80004af8:	60e2                	ld	ra,24(sp)
    80004afa:	6442                	ld	s0,16(sp)
    80004afc:	64a2                	ld	s1,8(sp)
    80004afe:	6902                	ld	s2,0(sp)
    80004b00:	6105                	addi	sp,sp,32
    80004b02:	8082                	ret

0000000080004b04 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b04:	1101                	addi	sp,sp,-32
    80004b06:	ec06                	sd	ra,24(sp)
    80004b08:	e822                	sd	s0,16(sp)
    80004b0a:	e426                	sd	s1,8(sp)
    80004b0c:	e04a                	sd	s2,0(sp)
    80004b0e:	1000                	addi	s0,sp,32
    80004b10:	84aa                	mv	s1,a0
    80004b12:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b14:	00004597          	auipc	a1,0x4
    80004b18:	b8c58593          	addi	a1,a1,-1140 # 800086a0 <syscalls+0x2a8>
    80004b1c:	0521                	addi	a0,a0,8
    80004b1e:	920fc0ef          	jal	ra,80000c3e <initlock>
  lk->name = name;
    80004b22:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b26:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b2a:	0204a423          	sw	zero,40(s1)
}
    80004b2e:	60e2                	ld	ra,24(sp)
    80004b30:	6442                	ld	s0,16(sp)
    80004b32:	64a2                	ld	s1,8(sp)
    80004b34:	6902                	ld	s2,0(sp)
    80004b36:	6105                	addi	sp,sp,32
    80004b38:	8082                	ret

0000000080004b3a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
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
    80004b4e:	970fc0ef          	jal	ra,80000cbe <acquire>
  while (lk->locked) {
    80004b52:	409c                	lw	a5,0(s1)
    80004b54:	c799                	beqz	a5,80004b62 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004b56:	85ca                	mv	a1,s2
    80004b58:	8526                	mv	a0,s1
    80004b5a:	95dfd0ef          	jal	ra,800024b6 <sleep>
  while (lk->locked) {
    80004b5e:	409c                	lw	a5,0(s1)
    80004b60:	fbfd                	bnez	a5,80004b56 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004b62:	4785                	li	a5,1
    80004b64:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b66:	858fd0ef          	jal	ra,80001bbe <myproc>
    80004b6a:	591c                	lw	a5,48(a0)
    80004b6c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b6e:	854a                	mv	a0,s2
    80004b70:	9e6fc0ef          	jal	ra,80000d56 <release>
}
    80004b74:	60e2                	ld	ra,24(sp)
    80004b76:	6442                	ld	s0,16(sp)
    80004b78:	64a2                	ld	s1,8(sp)
    80004b7a:	6902                	ld	s2,0(sp)
    80004b7c:	6105                	addi	sp,sp,32
    80004b7e:	8082                	ret

0000000080004b80 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b80:	1101                	addi	sp,sp,-32
    80004b82:	ec06                	sd	ra,24(sp)
    80004b84:	e822                	sd	s0,16(sp)
    80004b86:	e426                	sd	s1,8(sp)
    80004b88:	e04a                	sd	s2,0(sp)
    80004b8a:	1000                	addi	s0,sp,32
    80004b8c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b8e:	00850913          	addi	s2,a0,8
    80004b92:	854a                	mv	a0,s2
    80004b94:	92afc0ef          	jal	ra,80000cbe <acquire>
  lk->locked = 0;
    80004b98:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b9c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	961fd0ef          	jal	ra,80002502 <wakeup>
  release(&lk->lk);
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	9aefc0ef          	jal	ra,80000d56 <release>
}
    80004bac:	60e2                	ld	ra,24(sp)
    80004bae:	6442                	ld	s0,16(sp)
    80004bb0:	64a2                	ld	s1,8(sp)
    80004bb2:	6902                	ld	s2,0(sp)
    80004bb4:	6105                	addi	sp,sp,32
    80004bb6:	8082                	ret

0000000080004bb8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004bb8:	7179                	addi	sp,sp,-48
    80004bba:	f406                	sd	ra,40(sp)
    80004bbc:	f022                	sd	s0,32(sp)
    80004bbe:	ec26                	sd	s1,24(sp)
    80004bc0:	e84a                	sd	s2,16(sp)
    80004bc2:	e44e                	sd	s3,8(sp)
    80004bc4:	1800                	addi	s0,sp,48
    80004bc6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004bc8:	00850913          	addi	s2,a0,8
    80004bcc:	854a                	mv	a0,s2
    80004bce:	8f0fc0ef          	jal	ra,80000cbe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bd2:	409c                	lw	a5,0(s1)
    80004bd4:	ef89                	bnez	a5,80004bee <holdingsleep+0x36>
    80004bd6:	4481                	li	s1,0
  release(&lk->lk);
    80004bd8:	854a                	mv	a0,s2
    80004bda:	97cfc0ef          	jal	ra,80000d56 <release>
  return r;
}
    80004bde:	8526                	mv	a0,s1
    80004be0:	70a2                	ld	ra,40(sp)
    80004be2:	7402                	ld	s0,32(sp)
    80004be4:	64e2                	ld	s1,24(sp)
    80004be6:	6942                	ld	s2,16(sp)
    80004be8:	69a2                	ld	s3,8(sp)
    80004bea:	6145                	addi	sp,sp,48
    80004bec:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bee:	0284a983          	lw	s3,40(s1)
    80004bf2:	fcdfc0ef          	jal	ra,80001bbe <myproc>
    80004bf6:	5904                	lw	s1,48(a0)
    80004bf8:	413484b3          	sub	s1,s1,s3
    80004bfc:	0014b493          	seqz	s1,s1
    80004c00:	bfe1                	j	80004bd8 <holdingsleep+0x20>

0000000080004c02 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c02:	1141                	addi	sp,sp,-16
    80004c04:	e406                	sd	ra,8(sp)
    80004c06:	e022                	sd	s0,0(sp)
    80004c08:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c0a:	00004597          	auipc	a1,0x4
    80004c0e:	aa658593          	addi	a1,a1,-1370 # 800086b0 <syscalls+0x2b8>
    80004c12:	00246517          	auipc	a0,0x246
    80004c16:	f1650513          	addi	a0,a0,-234 # 8024ab28 <ftable>
    80004c1a:	824fc0ef          	jal	ra,80000c3e <initlock>
}
    80004c1e:	60a2                	ld	ra,8(sp)
    80004c20:	6402                	ld	s0,0(sp)
    80004c22:	0141                	addi	sp,sp,16
    80004c24:	8082                	ret

0000000080004c26 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c26:	1101                	addi	sp,sp,-32
    80004c28:	ec06                	sd	ra,24(sp)
    80004c2a:	e822                	sd	s0,16(sp)
    80004c2c:	e426                	sd	s1,8(sp)
    80004c2e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c30:	00246517          	auipc	a0,0x246
    80004c34:	ef850513          	addi	a0,a0,-264 # 8024ab28 <ftable>
    80004c38:	886fc0ef          	jal	ra,80000cbe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c3c:	00246497          	auipc	s1,0x246
    80004c40:	f0448493          	addi	s1,s1,-252 # 8024ab40 <ftable+0x18>
    80004c44:	00247717          	auipc	a4,0x247
    80004c48:	e9c70713          	addi	a4,a4,-356 # 8024bae0 <disk>
    if(f->ref == 0){
    80004c4c:	40dc                	lw	a5,4(s1)
    80004c4e:	cf89                	beqz	a5,80004c68 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c50:	02848493          	addi	s1,s1,40
    80004c54:	fee49ce3          	bne	s1,a4,80004c4c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c58:	00246517          	auipc	a0,0x246
    80004c5c:	ed050513          	addi	a0,a0,-304 # 8024ab28 <ftable>
    80004c60:	8f6fc0ef          	jal	ra,80000d56 <release>
  return 0;
    80004c64:	4481                	li	s1,0
    80004c66:	a809                	j	80004c78 <filealloc+0x52>
      f->ref = 1;
    80004c68:	4785                	li	a5,1
    80004c6a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c6c:	00246517          	auipc	a0,0x246
    80004c70:	ebc50513          	addi	a0,a0,-324 # 8024ab28 <ftable>
    80004c74:	8e2fc0ef          	jal	ra,80000d56 <release>
}
    80004c78:	8526                	mv	a0,s1
    80004c7a:	60e2                	ld	ra,24(sp)
    80004c7c:	6442                	ld	s0,16(sp)
    80004c7e:	64a2                	ld	s1,8(sp)
    80004c80:	6105                	addi	sp,sp,32
    80004c82:	8082                	ret

0000000080004c84 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c84:	1101                	addi	sp,sp,-32
    80004c86:	ec06                	sd	ra,24(sp)
    80004c88:	e822                	sd	s0,16(sp)
    80004c8a:	e426                	sd	s1,8(sp)
    80004c8c:	1000                	addi	s0,sp,32
    80004c8e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c90:	00246517          	auipc	a0,0x246
    80004c94:	e9850513          	addi	a0,a0,-360 # 8024ab28 <ftable>
    80004c98:	826fc0ef          	jal	ra,80000cbe <acquire>
  if(f->ref < 1)
    80004c9c:	40dc                	lw	a5,4(s1)
    80004c9e:	02f05063          	blez	a5,80004cbe <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004ca2:	2785                	addiw	a5,a5,1
    80004ca4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ca6:	00246517          	auipc	a0,0x246
    80004caa:	e8250513          	addi	a0,a0,-382 # 8024ab28 <ftable>
    80004cae:	8a8fc0ef          	jal	ra,80000d56 <release>
  return f;
}
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	60e2                	ld	ra,24(sp)
    80004cb6:	6442                	ld	s0,16(sp)
    80004cb8:	64a2                	ld	s1,8(sp)
    80004cba:	6105                	addi	sp,sp,32
    80004cbc:	8082                	ret
    panic("filedup");
    80004cbe:	00004517          	auipc	a0,0x4
    80004cc2:	9fa50513          	addi	a0,a0,-1542 # 800086b8 <syscalls+0x2c0>
    80004cc6:	ac5fb0ef          	jal	ra,8000078a <panic>

0000000080004cca <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004cca:	7139                	addi	sp,sp,-64
    80004ccc:	fc06                	sd	ra,56(sp)
    80004cce:	f822                	sd	s0,48(sp)
    80004cd0:	f426                	sd	s1,40(sp)
    80004cd2:	f04a                	sd	s2,32(sp)
    80004cd4:	ec4e                	sd	s3,24(sp)
    80004cd6:	e852                	sd	s4,16(sp)
    80004cd8:	e456                	sd	s5,8(sp)
    80004cda:	0080                	addi	s0,sp,64
    80004cdc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004cde:	00246517          	auipc	a0,0x246
    80004ce2:	e4a50513          	addi	a0,a0,-438 # 8024ab28 <ftable>
    80004ce6:	fd9fb0ef          	jal	ra,80000cbe <acquire>
  if(f->ref < 1)
    80004cea:	40dc                	lw	a5,4(s1)
    80004cec:	04f05963          	blez	a5,80004d3e <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004cf0:	37fd                	addiw	a5,a5,-1
    80004cf2:	0007871b          	sext.w	a4,a5
    80004cf6:	c0dc                	sw	a5,4(s1)
    80004cf8:	04e04963          	bgtz	a4,80004d4a <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004cfc:	0004a903          	lw	s2,0(s1)
    80004d00:	0094ca83          	lbu	s5,9(s1)
    80004d04:	0104ba03          	ld	s4,16(s1)
    80004d08:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d0c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d10:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d14:	00246517          	auipc	a0,0x246
    80004d18:	e1450513          	addi	a0,a0,-492 # 8024ab28 <ftable>
    80004d1c:	83afc0ef          	jal	ra,80000d56 <release>

  if(ff.type == FD_PIPE){
    80004d20:	4785                	li	a5,1
    80004d22:	04f90363          	beq	s2,a5,80004d68 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d26:	3979                	addiw	s2,s2,-2
    80004d28:	4785                	li	a5,1
    80004d2a:	0327e663          	bltu	a5,s2,80004d56 <fileclose+0x8c>
    begin_op();
    80004d2e:	b8fff0ef          	jal	ra,800048bc <begin_op>
    iput(ff.ip);
    80004d32:	854e                	mv	a0,s3
    80004d34:	b28ff0ef          	jal	ra,8000405c <iput>
    end_op();
    80004d38:	bf5ff0ef          	jal	ra,8000492c <end_op>
    80004d3c:	a829                	j	80004d56 <fileclose+0x8c>
    panic("fileclose");
    80004d3e:	00004517          	auipc	a0,0x4
    80004d42:	98250513          	addi	a0,a0,-1662 # 800086c0 <syscalls+0x2c8>
    80004d46:	a45fb0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004d4a:	00246517          	auipc	a0,0x246
    80004d4e:	dde50513          	addi	a0,a0,-546 # 8024ab28 <ftable>
    80004d52:	804fc0ef          	jal	ra,80000d56 <release>
  }
}
    80004d56:	70e2                	ld	ra,56(sp)
    80004d58:	7442                	ld	s0,48(sp)
    80004d5a:	74a2                	ld	s1,40(sp)
    80004d5c:	7902                	ld	s2,32(sp)
    80004d5e:	69e2                	ld	s3,24(sp)
    80004d60:	6a42                	ld	s4,16(sp)
    80004d62:	6aa2                	ld	s5,8(sp)
    80004d64:	6121                	addi	sp,sp,64
    80004d66:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d68:	85d6                	mv	a1,s5
    80004d6a:	8552                	mv	a0,s4
    80004d6c:	2ec000ef          	jal	ra,80005058 <pipeclose>
    80004d70:	b7dd                	j	80004d56 <fileclose+0x8c>

0000000080004d72 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d72:	715d                	addi	sp,sp,-80
    80004d74:	e486                	sd	ra,72(sp)
    80004d76:	e0a2                	sd	s0,64(sp)
    80004d78:	fc26                	sd	s1,56(sp)
    80004d7a:	f84a                	sd	s2,48(sp)
    80004d7c:	f44e                	sd	s3,40(sp)
    80004d7e:	0880                	addi	s0,sp,80
    80004d80:	84aa                	mv	s1,a0
    80004d82:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d84:	e3bfc0ef          	jal	ra,80001bbe <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d88:	409c                	lw	a5,0(s1)
    80004d8a:	37f9                	addiw	a5,a5,-2
    80004d8c:	4705                	li	a4,1
    80004d8e:	02f76f63          	bltu	a4,a5,80004dcc <filestat+0x5a>
    80004d92:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d94:	6c88                	ld	a0,24(s1)
    80004d96:	948ff0ef          	jal	ra,80003ede <ilock>
    stati(f->ip, &st);
    80004d9a:	fb840593          	addi	a1,s0,-72
    80004d9e:	6c88                	ld	a0,24(s1)
    80004da0:	ca0ff0ef          	jal	ra,80004240 <stati>
    iunlock(f->ip);
    80004da4:	6c88                	ld	a0,24(s1)
    80004da6:	9e2ff0ef          	jal	ra,80003f88 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004daa:	46e1                	li	a3,24
    80004dac:	fb840613          	addi	a2,s0,-72
    80004db0:	85ce                	mv	a1,s3
    80004db2:	05093503          	ld	a0,80(s2)
    80004db6:	9f9fc0ef          	jal	ra,800017ae <copyout>
    80004dba:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004dbe:	60a6                	ld	ra,72(sp)
    80004dc0:	6406                	ld	s0,64(sp)
    80004dc2:	74e2                	ld	s1,56(sp)
    80004dc4:	7942                	ld	s2,48(sp)
    80004dc6:	79a2                	ld	s3,40(sp)
    80004dc8:	6161                	addi	sp,sp,80
    80004dca:	8082                	ret
  return -1;
    80004dcc:	557d                	li	a0,-1
    80004dce:	bfc5                	j	80004dbe <filestat+0x4c>

0000000080004dd0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004dd0:	7179                	addi	sp,sp,-48
    80004dd2:	f406                	sd	ra,40(sp)
    80004dd4:	f022                	sd	s0,32(sp)
    80004dd6:	ec26                	sd	s1,24(sp)
    80004dd8:	e84a                	sd	s2,16(sp)
    80004dda:	e44e                	sd	s3,8(sp)
    80004ddc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004dde:	00854783          	lbu	a5,8(a0)
    80004de2:	cbc1                	beqz	a5,80004e72 <fileread+0xa2>
    80004de4:	84aa                	mv	s1,a0
    80004de6:	89ae                	mv	s3,a1
    80004de8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dea:	411c                	lw	a5,0(a0)
    80004dec:	4705                	li	a4,1
    80004dee:	04e78363          	beq	a5,a4,80004e34 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004df2:	470d                	li	a4,3
    80004df4:	04e78563          	beq	a5,a4,80004e3e <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004df8:	4709                	li	a4,2
    80004dfa:	06e79663          	bne	a5,a4,80004e66 <fileread+0x96>
    ilock(f->ip);
    80004dfe:	6d08                	ld	a0,24(a0)
    80004e00:	8deff0ef          	jal	ra,80003ede <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e04:	874a                	mv	a4,s2
    80004e06:	5094                	lw	a3,32(s1)
    80004e08:	864e                	mv	a2,s3
    80004e0a:	4585                	li	a1,1
    80004e0c:	6c88                	ld	a0,24(s1)
    80004e0e:	c5cff0ef          	jal	ra,8000426a <readi>
    80004e12:	892a                	mv	s2,a0
    80004e14:	00a05563          	blez	a0,80004e1e <fileread+0x4e>
      f->off += r;
    80004e18:	509c                	lw	a5,32(s1)
    80004e1a:	9fa9                	addw	a5,a5,a0
    80004e1c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e1e:	6c88                	ld	a0,24(s1)
    80004e20:	968ff0ef          	jal	ra,80003f88 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e24:	854a                	mv	a0,s2
    80004e26:	70a2                	ld	ra,40(sp)
    80004e28:	7402                	ld	s0,32(sp)
    80004e2a:	64e2                	ld	s1,24(sp)
    80004e2c:	6942                	ld	s2,16(sp)
    80004e2e:	69a2                	ld	s3,8(sp)
    80004e30:	6145                	addi	sp,sp,48
    80004e32:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e34:	6908                	ld	a0,16(a0)
    80004e36:	34e000ef          	jal	ra,80005184 <piperead>
    80004e3a:	892a                	mv	s2,a0
    80004e3c:	b7e5                	j	80004e24 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e3e:	02451783          	lh	a5,36(a0)
    80004e42:	03079693          	slli	a3,a5,0x30
    80004e46:	92c1                	srli	a3,a3,0x30
    80004e48:	4725                	li	a4,9
    80004e4a:	02d76663          	bltu	a4,a3,80004e76 <fileread+0xa6>
    80004e4e:	0792                	slli	a5,a5,0x4
    80004e50:	00246717          	auipc	a4,0x246
    80004e54:	c3870713          	addi	a4,a4,-968 # 8024aa88 <devsw>
    80004e58:	97ba                	add	a5,a5,a4
    80004e5a:	639c                	ld	a5,0(a5)
    80004e5c:	cf99                	beqz	a5,80004e7a <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004e5e:	4505                	li	a0,1
    80004e60:	9782                	jalr	a5
    80004e62:	892a                	mv	s2,a0
    80004e64:	b7c1                	j	80004e24 <fileread+0x54>
    panic("fileread");
    80004e66:	00004517          	auipc	a0,0x4
    80004e6a:	86a50513          	addi	a0,a0,-1942 # 800086d0 <syscalls+0x2d8>
    80004e6e:	91dfb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004e72:	597d                	li	s2,-1
    80004e74:	bf45                	j	80004e24 <fileread+0x54>
      return -1;
    80004e76:	597d                	li	s2,-1
    80004e78:	b775                	j	80004e24 <fileread+0x54>
    80004e7a:	597d                	li	s2,-1
    80004e7c:	b765                	j	80004e24 <fileread+0x54>

0000000080004e7e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e7e:	715d                	addi	sp,sp,-80
    80004e80:	e486                	sd	ra,72(sp)
    80004e82:	e0a2                	sd	s0,64(sp)
    80004e84:	fc26                	sd	s1,56(sp)
    80004e86:	f84a                	sd	s2,48(sp)
    80004e88:	f44e                	sd	s3,40(sp)
    80004e8a:	f052                	sd	s4,32(sp)
    80004e8c:	ec56                	sd	s5,24(sp)
    80004e8e:	e85a                	sd	s6,16(sp)
    80004e90:	e45e                	sd	s7,8(sp)
    80004e92:	e062                	sd	s8,0(sp)
    80004e94:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e96:	00954783          	lbu	a5,9(a0)
    80004e9a:	0e078863          	beqz	a5,80004f8a <filewrite+0x10c>
    80004e9e:	892a                	mv	s2,a0
    80004ea0:	8aae                	mv	s5,a1
    80004ea2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ea4:	411c                	lw	a5,0(a0)
    80004ea6:	4705                	li	a4,1
    80004ea8:	02e78263          	beq	a5,a4,80004ecc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004eac:	470d                	li	a4,3
    80004eae:	02e78463          	beq	a5,a4,80004ed6 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004eb2:	4709                	li	a4,2
    80004eb4:	0ce79563          	bne	a5,a4,80004f7e <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004eb8:	0ac05163          	blez	a2,80004f5a <filewrite+0xdc>
    int i = 0;
    80004ebc:	4981                	li	s3,0
    80004ebe:	6b05                	lui	s6,0x1
    80004ec0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004ec4:	6b85                	lui	s7,0x1
    80004ec6:	c00b8b9b          	addiw	s7,s7,-1024
    80004eca:	a041                	j	80004f4a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004ecc:	6908                	ld	a0,16(a0)
    80004ece:	1e2000ef          	jal	ra,800050b0 <pipewrite>
    80004ed2:	8a2a                	mv	s4,a0
    80004ed4:	a071                	j	80004f60 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ed6:	02451783          	lh	a5,36(a0)
    80004eda:	03079693          	slli	a3,a5,0x30
    80004ede:	92c1                	srli	a3,a3,0x30
    80004ee0:	4725                	li	a4,9
    80004ee2:	0ad76663          	bltu	a4,a3,80004f8e <filewrite+0x110>
    80004ee6:	0792                	slli	a5,a5,0x4
    80004ee8:	00246717          	auipc	a4,0x246
    80004eec:	ba070713          	addi	a4,a4,-1120 # 8024aa88 <devsw>
    80004ef0:	97ba                	add	a5,a5,a4
    80004ef2:	679c                	ld	a5,8(a5)
    80004ef4:	cfd9                	beqz	a5,80004f92 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004ef6:	4505                	li	a0,1
    80004ef8:	9782                	jalr	a5
    80004efa:	8a2a                	mv	s4,a0
    80004efc:	a095                	j	80004f60 <filewrite+0xe2>
    80004efe:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004f02:	9bbff0ef          	jal	ra,800048bc <begin_op>
      ilock(f->ip);
    80004f06:	01893503          	ld	a0,24(s2)
    80004f0a:	fd5fe0ef          	jal	ra,80003ede <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f0e:	8762                	mv	a4,s8
    80004f10:	02092683          	lw	a3,32(s2)
    80004f14:	01598633          	add	a2,s3,s5
    80004f18:	4585                	li	a1,1
    80004f1a:	01893503          	ld	a0,24(s2)
    80004f1e:	c30ff0ef          	jal	ra,8000434e <writei>
    80004f22:	84aa                	mv	s1,a0
    80004f24:	00a05763          	blez	a0,80004f32 <filewrite+0xb4>
        f->off += r;
    80004f28:	02092783          	lw	a5,32(s2)
    80004f2c:	9fa9                	addw	a5,a5,a0
    80004f2e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f32:	01893503          	ld	a0,24(s2)
    80004f36:	852ff0ef          	jal	ra,80003f88 <iunlock>
      end_op();
    80004f3a:	9f3ff0ef          	jal	ra,8000492c <end_op>

      if(r != n1){
    80004f3e:	009c1f63          	bne	s8,s1,80004f5c <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004f42:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f46:	0149db63          	bge	s3,s4,80004f5c <filewrite+0xde>
      int n1 = n - i;
    80004f4a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004f4e:	84be                	mv	s1,a5
    80004f50:	2781                	sext.w	a5,a5
    80004f52:	fafb56e3          	bge	s6,a5,80004efe <filewrite+0x80>
    80004f56:	84de                	mv	s1,s7
    80004f58:	b75d                	j	80004efe <filewrite+0x80>
    int i = 0;
    80004f5a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f5c:	013a1f63          	bne	s4,s3,80004f7a <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f60:	8552                	mv	a0,s4
    80004f62:	60a6                	ld	ra,72(sp)
    80004f64:	6406                	ld	s0,64(sp)
    80004f66:	74e2                	ld	s1,56(sp)
    80004f68:	7942                	ld	s2,48(sp)
    80004f6a:	79a2                	ld	s3,40(sp)
    80004f6c:	7a02                	ld	s4,32(sp)
    80004f6e:	6ae2                	ld	s5,24(sp)
    80004f70:	6b42                	ld	s6,16(sp)
    80004f72:	6ba2                	ld	s7,8(sp)
    80004f74:	6c02                	ld	s8,0(sp)
    80004f76:	6161                	addi	sp,sp,80
    80004f78:	8082                	ret
    ret = (i == n ? n : -1);
    80004f7a:	5a7d                	li	s4,-1
    80004f7c:	b7d5                	j	80004f60 <filewrite+0xe2>
    panic("filewrite");
    80004f7e:	00003517          	auipc	a0,0x3
    80004f82:	76250513          	addi	a0,a0,1890 # 800086e0 <syscalls+0x2e8>
    80004f86:	805fb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004f8a:	5a7d                	li	s4,-1
    80004f8c:	bfd1                	j	80004f60 <filewrite+0xe2>
      return -1;
    80004f8e:	5a7d                	li	s4,-1
    80004f90:	bfc1                	j	80004f60 <filewrite+0xe2>
    80004f92:	5a7d                	li	s4,-1
    80004f94:	b7f1                	j	80004f60 <filewrite+0xe2>

0000000080004f96 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f96:	7179                	addi	sp,sp,-48
    80004f98:	f406                	sd	ra,40(sp)
    80004f9a:	f022                	sd	s0,32(sp)
    80004f9c:	ec26                	sd	s1,24(sp)
    80004f9e:	e84a                	sd	s2,16(sp)
    80004fa0:	e44e                	sd	s3,8(sp)
    80004fa2:	e052                	sd	s4,0(sp)
    80004fa4:	1800                	addi	s0,sp,48
    80004fa6:	84aa                	mv	s1,a0
    80004fa8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004faa:	0005b023          	sd	zero,0(a1)
    80004fae:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fb2:	c75ff0ef          	jal	ra,80004c26 <filealloc>
    80004fb6:	e088                	sd	a0,0(s1)
    80004fb8:	cd35                	beqz	a0,80005034 <pipealloc+0x9e>
    80004fba:	c6dff0ef          	jal	ra,80004c26 <filealloc>
    80004fbe:	00aa3023          	sd	a0,0(s4)
    80004fc2:	c52d                	beqz	a0,8000502c <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004fc4:	bf7fb0ef          	jal	ra,80000bba <kalloc>
    80004fc8:	892a                	mv	s2,a0
    80004fca:	cd31                	beqz	a0,80005026 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004fcc:	4985                	li	s3,1
    80004fce:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fd2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fd6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fda:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fde:	00003597          	auipc	a1,0x3
    80004fe2:	71258593          	addi	a1,a1,1810 # 800086f0 <syscalls+0x2f8>
    80004fe6:	c59fb0ef          	jal	ra,80000c3e <initlock>
  (*f0)->type = FD_PIPE;
    80004fea:	609c                	ld	a5,0(s1)
    80004fec:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ff0:	609c                	ld	a5,0(s1)
    80004ff2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ff6:	609c                	ld	a5,0(s1)
    80004ff8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ffc:	609c                	ld	a5,0(s1)
    80004ffe:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005002:	000a3783          	ld	a5,0(s4)
    80005006:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000500a:	000a3783          	ld	a5,0(s4)
    8000500e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005012:	000a3783          	ld	a5,0(s4)
    80005016:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000501a:	000a3783          	ld	a5,0(s4)
    8000501e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005022:	4501                	li	a0,0
    80005024:	a005                	j	80005044 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005026:	6088                	ld	a0,0(s1)
    80005028:	e501                	bnez	a0,80005030 <pipealloc+0x9a>
    8000502a:	a029                	j	80005034 <pipealloc+0x9e>
    8000502c:	6088                	ld	a0,0(s1)
    8000502e:	c11d                	beqz	a0,80005054 <pipealloc+0xbe>
    fileclose(*f0);
    80005030:	c9bff0ef          	jal	ra,80004cca <fileclose>
  if(*f1)
    80005034:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005038:	557d                	li	a0,-1
  if(*f1)
    8000503a:	c789                	beqz	a5,80005044 <pipealloc+0xae>
    fileclose(*f1);
    8000503c:	853e                	mv	a0,a5
    8000503e:	c8dff0ef          	jal	ra,80004cca <fileclose>
  return -1;
    80005042:	557d                	li	a0,-1
}
    80005044:	70a2                	ld	ra,40(sp)
    80005046:	7402                	ld	s0,32(sp)
    80005048:	64e2                	ld	s1,24(sp)
    8000504a:	6942                	ld	s2,16(sp)
    8000504c:	69a2                	ld	s3,8(sp)
    8000504e:	6a02                	ld	s4,0(sp)
    80005050:	6145                	addi	sp,sp,48
    80005052:	8082                	ret
  return -1;
    80005054:	557d                	li	a0,-1
    80005056:	b7fd                	j	80005044 <pipealloc+0xae>

0000000080005058 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005058:	1101                	addi	sp,sp,-32
    8000505a:	ec06                	sd	ra,24(sp)
    8000505c:	e822                	sd	s0,16(sp)
    8000505e:	e426                	sd	s1,8(sp)
    80005060:	e04a                	sd	s2,0(sp)
    80005062:	1000                	addi	s0,sp,32
    80005064:	84aa                	mv	s1,a0
    80005066:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005068:	c57fb0ef          	jal	ra,80000cbe <acquire>
  if(writable){
    8000506c:	02090763          	beqz	s2,8000509a <pipeclose+0x42>
    pi->writeopen = 0;
    80005070:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005074:	21848513          	addi	a0,s1,536
    80005078:	c8afd0ef          	jal	ra,80002502 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000507c:	2204b783          	ld	a5,544(s1)
    80005080:	e785                	bnez	a5,800050a8 <pipeclose+0x50>
    release(&pi->lock);
    80005082:	8526                	mv	a0,s1
    80005084:	cd3fb0ef          	jal	ra,80000d56 <release>
    kfree((char*)pi);
    80005088:	8526                	mv	a0,s1
    8000508a:	9f5fb0ef          	jal	ra,80000a7e <kfree>
  } else
    release(&pi->lock);
}
    8000508e:	60e2                	ld	ra,24(sp)
    80005090:	6442                	ld	s0,16(sp)
    80005092:	64a2                	ld	s1,8(sp)
    80005094:	6902                	ld	s2,0(sp)
    80005096:	6105                	addi	sp,sp,32
    80005098:	8082                	ret
    pi->readopen = 0;
    8000509a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000509e:	21c48513          	addi	a0,s1,540
    800050a2:	c60fd0ef          	jal	ra,80002502 <wakeup>
    800050a6:	bfd9                	j	8000507c <pipeclose+0x24>
    release(&pi->lock);
    800050a8:	8526                	mv	a0,s1
    800050aa:	cadfb0ef          	jal	ra,80000d56 <release>
}
    800050ae:	b7c5                	j	8000508e <pipeclose+0x36>

00000000800050b0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800050b0:	711d                	addi	sp,sp,-96
    800050b2:	ec86                	sd	ra,88(sp)
    800050b4:	e8a2                	sd	s0,80(sp)
    800050b6:	e4a6                	sd	s1,72(sp)
    800050b8:	e0ca                	sd	s2,64(sp)
    800050ba:	fc4e                	sd	s3,56(sp)
    800050bc:	f852                	sd	s4,48(sp)
    800050be:	f456                	sd	s5,40(sp)
    800050c0:	f05a                	sd	s6,32(sp)
    800050c2:	ec5e                	sd	s7,24(sp)
    800050c4:	e862                	sd	s8,16(sp)
    800050c6:	1080                	addi	s0,sp,96
    800050c8:	84aa                	mv	s1,a0
    800050ca:	8aae                	mv	s5,a1
    800050cc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050ce:	af1fc0ef          	jal	ra,80001bbe <myproc>
    800050d2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800050d4:	8526                	mv	a0,s1
    800050d6:	be9fb0ef          	jal	ra,80000cbe <acquire>
  while(i < n){
    800050da:	09405c63          	blez	s4,80005172 <pipewrite+0xc2>
  int i = 0;
    800050de:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050e0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800050e2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800050e6:	21c48b93          	addi	s7,s1,540
    800050ea:	a81d                	j	80005120 <pipewrite+0x70>
      release(&pi->lock);
    800050ec:	8526                	mv	a0,s1
    800050ee:	c69fb0ef          	jal	ra,80000d56 <release>
      return -1;
    800050f2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050f4:	854a                	mv	a0,s2
    800050f6:	60e6                	ld	ra,88(sp)
    800050f8:	6446                	ld	s0,80(sp)
    800050fa:	64a6                	ld	s1,72(sp)
    800050fc:	6906                	ld	s2,64(sp)
    800050fe:	79e2                	ld	s3,56(sp)
    80005100:	7a42                	ld	s4,48(sp)
    80005102:	7aa2                	ld	s5,40(sp)
    80005104:	7b02                	ld	s6,32(sp)
    80005106:	6be2                	ld	s7,24(sp)
    80005108:	6c42                	ld	s8,16(sp)
    8000510a:	6125                	addi	sp,sp,96
    8000510c:	8082                	ret
      wakeup(&pi->nread);
    8000510e:	8562                	mv	a0,s8
    80005110:	bf2fd0ef          	jal	ra,80002502 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005114:	85a6                	mv	a1,s1
    80005116:	855e                	mv	a0,s7
    80005118:	b9efd0ef          	jal	ra,800024b6 <sleep>
  while(i < n){
    8000511c:	05495c63          	bge	s2,s4,80005174 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80005120:	2204a783          	lw	a5,544(s1)
    80005124:	d7e1                	beqz	a5,800050ec <pipewrite+0x3c>
    80005126:	854e                	mv	a0,s3
    80005128:	dc6fd0ef          	jal	ra,800026ee <killed>
    8000512c:	f161                	bnez	a0,800050ec <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000512e:	2184a783          	lw	a5,536(s1)
    80005132:	21c4a703          	lw	a4,540(s1)
    80005136:	2007879b          	addiw	a5,a5,512
    8000513a:	fcf70ae3          	beq	a4,a5,8000510e <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000513e:	4685                	li	a3,1
    80005140:	01590633          	add	a2,s2,s5
    80005144:	faf40593          	addi	a1,s0,-81
    80005148:	0509b503          	ld	a0,80(s3)
    8000514c:	f72fc0ef          	jal	ra,800018be <copyin>
    80005150:	03650263          	beq	a0,s6,80005174 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005154:	21c4a783          	lw	a5,540(s1)
    80005158:	0017871b          	addiw	a4,a5,1
    8000515c:	20e4ae23          	sw	a4,540(s1)
    80005160:	1ff7f793          	andi	a5,a5,511
    80005164:	97a6                	add	a5,a5,s1
    80005166:	faf44703          	lbu	a4,-81(s0)
    8000516a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000516e:	2905                	addiw	s2,s2,1
    80005170:	b775                	j	8000511c <pipewrite+0x6c>
  int i = 0;
    80005172:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005174:	21848513          	addi	a0,s1,536
    80005178:	b8afd0ef          	jal	ra,80002502 <wakeup>
  release(&pi->lock);
    8000517c:	8526                	mv	a0,s1
    8000517e:	bd9fb0ef          	jal	ra,80000d56 <release>
  return i;
    80005182:	bf8d                	j	800050f4 <pipewrite+0x44>

0000000080005184 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005184:	715d                	addi	sp,sp,-80
    80005186:	e486                	sd	ra,72(sp)
    80005188:	e0a2                	sd	s0,64(sp)
    8000518a:	fc26                	sd	s1,56(sp)
    8000518c:	f84a                	sd	s2,48(sp)
    8000518e:	f44e                	sd	s3,40(sp)
    80005190:	f052                	sd	s4,32(sp)
    80005192:	ec56                	sd	s5,24(sp)
    80005194:	e85a                	sd	s6,16(sp)
    80005196:	0880                	addi	s0,sp,80
    80005198:	84aa                	mv	s1,a0
    8000519a:	892e                	mv	s2,a1
    8000519c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000519e:	a21fc0ef          	jal	ra,80001bbe <myproc>
    800051a2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051a4:	8526                	mv	a0,s1
    800051a6:	b19fb0ef          	jal	ra,80000cbe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051aa:	2184a703          	lw	a4,536(s1)
    800051ae:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051b2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051b6:	02f71363          	bne	a4,a5,800051dc <piperead+0x58>
    800051ba:	2244a783          	lw	a5,548(s1)
    800051be:	cf99                	beqz	a5,800051dc <piperead+0x58>
    if(killed(pr)){
    800051c0:	8552                	mv	a0,s4
    800051c2:	d2cfd0ef          	jal	ra,800026ee <killed>
    800051c6:	e149                	bnez	a0,80005248 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051c8:	85a6                	mv	a1,s1
    800051ca:	854e                	mv	a0,s3
    800051cc:	aeafd0ef          	jal	ra,800024b6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051d0:	2184a703          	lw	a4,536(s1)
    800051d4:	21c4a783          	lw	a5,540(s1)
    800051d8:	fef701e3          	beq	a4,a5,800051ba <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051dc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800051de:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051e0:	05505263          	blez	s5,80005224 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    800051e4:	2184a783          	lw	a5,536(s1)
    800051e8:	21c4a703          	lw	a4,540(s1)
    800051ec:	02f70c63          	beq	a4,a5,80005224 <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    800051f0:	1ff7f793          	andi	a5,a5,511
    800051f4:	97a6                	add	a5,a5,s1
    800051f6:	0187c783          	lbu	a5,24(a5)
    800051fa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800051fe:	4685                	li	a3,1
    80005200:	fbf40613          	addi	a2,s0,-65
    80005204:	85ca                	mv	a1,s2
    80005206:	050a3503          	ld	a0,80(s4)
    8000520a:	da4fc0ef          	jal	ra,800017ae <copyout>
    8000520e:	05650263          	beq	a0,s6,80005252 <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005212:	2184a783          	lw	a5,536(s1)
    80005216:	2785                	addiw	a5,a5,1
    80005218:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000521c:	2985                	addiw	s3,s3,1
    8000521e:	0905                	addi	s2,s2,1
    80005220:	fd3a92e3          	bne	s5,s3,800051e4 <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005224:	21c48513          	addi	a0,s1,540
    80005228:	adafd0ef          	jal	ra,80002502 <wakeup>
  release(&pi->lock);
    8000522c:	8526                	mv	a0,s1
    8000522e:	b29fb0ef          	jal	ra,80000d56 <release>
  return i;
}
    80005232:	854e                	mv	a0,s3
    80005234:	60a6                	ld	ra,72(sp)
    80005236:	6406                	ld	s0,64(sp)
    80005238:	74e2                	ld	s1,56(sp)
    8000523a:	7942                	ld	s2,48(sp)
    8000523c:	79a2                	ld	s3,40(sp)
    8000523e:	7a02                	ld	s4,32(sp)
    80005240:	6ae2                	ld	s5,24(sp)
    80005242:	6b42                	ld	s6,16(sp)
    80005244:	6161                	addi	sp,sp,80
    80005246:	8082                	ret
      release(&pi->lock);
    80005248:	8526                	mv	a0,s1
    8000524a:	b0dfb0ef          	jal	ra,80000d56 <release>
      return -1;
    8000524e:	59fd                	li	s3,-1
    80005250:	b7cd                	j	80005232 <piperead+0xae>
      if(i == 0)
    80005252:	fc0999e3          	bnez	s3,80005224 <piperead+0xa0>
        i = -1;
    80005256:	89aa                	mv	s3,a0
    80005258:	b7f1                	j	80005224 <piperead+0xa0>

000000008000525a <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000525a:	1141                	addi	sp,sp,-16
    8000525c:	e422                	sd	s0,8(sp)
    8000525e:	0800                	addi	s0,sp,16
    80005260:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005262:	8905                	andi	a0,a0,1
    80005264:	c111                	beqz	a0,80005268 <flags2perm+0xe>
      perm = PTE_X;
    80005266:	4521                	li	a0,8
    if(flags & 0x2)
    80005268:	8b89                	andi	a5,a5,2
    8000526a:	c399                	beqz	a5,80005270 <flags2perm+0x16>
      perm |= PTE_W;
    8000526c:	00456513          	ori	a0,a0,4
    return perm;
}
    80005270:	6422                	ld	s0,8(sp)
    80005272:	0141                	addi	sp,sp,16
    80005274:	8082                	ret

0000000080005276 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005276:	b5010113          	addi	sp,sp,-1200
    8000527a:	4a113423          	sd	ra,1192(sp)
    8000527e:	4a813023          	sd	s0,1184(sp)
    80005282:	48913c23          	sd	s1,1176(sp)
    80005286:	49213823          	sd	s2,1168(sp)
    8000528a:	49313423          	sd	s3,1160(sp)
    8000528e:	49413023          	sd	s4,1152(sp)
    80005292:	47513c23          	sd	s5,1144(sp)
    80005296:	47613823          	sd	s6,1136(sp)
    8000529a:	47713423          	sd	s7,1128(sp)
    8000529e:	47813023          	sd	s8,1120(sp)
    800052a2:	45913c23          	sd	s9,1112(sp)
    800052a6:	45a13823          	sd	s10,1104(sp)
    800052aa:	45b13423          	sd	s11,1096(sp)
    800052ae:	4b010413          	addi	s0,sp,1200
    800052b2:	84aa                	mv	s1,a0
    800052b4:	b6a43023          	sd	a0,-1184(s0)
    800052b8:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800052bc:	903fc0ef          	jal	ra,80001bbe <myproc>
    800052c0:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    800052c4:	df8ff0ef          	jal	ra,800048bc <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800052c8:	8526                	mv	a0,s1
    800052ca:	c02ff0ef          	jal	ra,800046cc <namei>
    800052ce:	cd25                	beqz	a0,80005346 <kexec+0xd0>
    800052d0:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800052d2:	c0dfe0ef          	jal	ra,80003ede <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800052d6:	04000713          	li	a4,64
    800052da:	4681                	li	a3,0
    800052dc:	e5040613          	addi	a2,s0,-432
    800052e0:	4581                	li	a1,0
    800052e2:	8556                	mv	a0,s5
    800052e4:	f87fe0ef          	jal	ra,8000426a <readi>
    800052e8:	04000793          	li	a5,64
    800052ec:	00f51a63          	bne	a0,a5,80005300 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800052f0:	e5042703          	lw	a4,-432(s0)
    800052f4:	464c47b7          	lui	a5,0x464c4
    800052f8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052fc:	04f70963          	beq	a4,a5,8000534e <kexec+0xd8>
    memset(p->vmas, 0, sizeof(p->vmas));
    vma_release_all(p);
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80005300:	8556                	mv	a0,s5
    80005302:	de3fe0ef          	jal	ra,800040e4 <iunlockput>
    end_op();
    80005306:	e26ff0ef          	jal	ra,8000492c <end_op>
  }
  return -1;
    8000530a:	557d                	li	a0,-1
}
    8000530c:	4a813083          	ld	ra,1192(sp)
    80005310:	4a013403          	ld	s0,1184(sp)
    80005314:	49813483          	ld	s1,1176(sp)
    80005318:	49013903          	ld	s2,1168(sp)
    8000531c:	48813983          	ld	s3,1160(sp)
    80005320:	48013a03          	ld	s4,1152(sp)
    80005324:	47813a83          	ld	s5,1144(sp)
    80005328:	47013b03          	ld	s6,1136(sp)
    8000532c:	46813b83          	ld	s7,1128(sp)
    80005330:	46013c03          	ld	s8,1120(sp)
    80005334:	45813c83          	ld	s9,1112(sp)
    80005338:	45013d03          	ld	s10,1104(sp)
    8000533c:	44813d83          	ld	s11,1096(sp)
    80005340:	4b010113          	addi	sp,sp,1200
    80005344:	8082                	ret
    end_op();
    80005346:	de6ff0ef          	jal	ra,8000492c <end_op>
    return -1;
    8000534a:	557d                	li	a0,-1
    8000534c:	b7c1                	j	8000530c <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    8000534e:	b7843503          	ld	a0,-1160(s0)
    80005352:	b61fc0ef          	jal	ra,80001eb2 <proc_pagetable>
    80005356:	8baa                	mv	s7,a0
    80005358:	d545                	beqz	a0,80005300 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000535a:	e7042783          	lw	a5,-400(s0)
    8000535e:	e8845703          	lhu	a4,-376(s0)
    80005362:	0e070d63          	beqz	a4,8000545c <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005366:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000536a:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000536e:	6a05                	lui	s4,0x1
    80005370:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005374:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005378:	6d85                	lui	s11,0x1
    8000537a:	7d7d                	lui	s10,0xfffff
    8000537c:	a09d                	j	800053e2 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000537e:	00003517          	auipc	a0,0x3
    80005382:	37a50513          	addi	a0,a0,890 # 800086f8 <syscalls+0x300>
    80005386:	c04fb0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000538a:	874a                	mv	a4,s2
    8000538c:	009c86bb          	addw	a3,s9,s1
    80005390:	4581                	li	a1,0
    80005392:	8556                	mv	a0,s5
    80005394:	ed7fe0ef          	jal	ra,8000426a <readi>
    80005398:	2501                	sext.w	a0,a0
    8000539a:	0ea91e63          	bne	s2,a0,80005496 <kexec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    8000539e:	009d84bb          	addw	s1,s11,s1
    800053a2:	013d09bb          	addw	s3,s10,s3
    800053a6:	0364f063          	bgeu	s1,s6,800053c6 <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    800053aa:	02049593          	slli	a1,s1,0x20
    800053ae:	9181                	srli	a1,a1,0x20
    800053b0:	95e2                	add	a1,a1,s8
    800053b2:	855e                	mv	a0,s7
    800053b4:	d01fb0ef          	jal	ra,800010b4 <walkaddr>
    800053b8:	862a                	mv	a2,a0
    if(pa == 0)
    800053ba:	d171                	beqz	a0,8000537e <kexec+0x108>
      n = PGSIZE;
    800053bc:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800053be:	fd49f6e3          	bgeu	s3,s4,8000538a <kexec+0x114>
      n = sz - i;
    800053c2:	894e                	mv	s2,s3
    800053c4:	b7d9                	j	8000538a <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053c6:	b8843783          	ld	a5,-1144(s0)
    800053ca:	0017869b          	addiw	a3,a5,1
    800053ce:	b8d43423          	sd	a3,-1144(s0)
    800053d2:	b8043783          	ld	a5,-1152(s0)
    800053d6:	0387879b          	addiw	a5,a5,56
    800053da:	e8845703          	lhu	a4,-376(s0)
    800053de:	08e6d163          	bge	a3,a4,80005460 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053e2:	2781                	sext.w	a5,a5
    800053e4:	b8f43023          	sd	a5,-1152(s0)
    800053e8:	03800713          	li	a4,56
    800053ec:	86be                	mv	a3,a5
    800053ee:	e1840613          	addi	a2,s0,-488
    800053f2:	4581                	li	a1,0
    800053f4:	8556                	mv	a0,s5
    800053f6:	e75fe0ef          	jal	ra,8000426a <readi>
    800053fa:	03800793          	li	a5,56
    800053fe:	08f51c63          	bne	a0,a5,80005496 <kexec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80005402:	e1842783          	lw	a5,-488(s0)
    80005406:	4705                	li	a4,1
    80005408:	fae79fe3          	bne	a5,a4,800053c6 <kexec+0x150>
    if(ph.memsz < ph.filesz)
    8000540c:	e4043483          	ld	s1,-448(s0)
    80005410:	e3843783          	ld	a5,-456(s0)
    80005414:	08f4e163          	bltu	s1,a5,80005496 <kexec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005418:	e2843783          	ld	a5,-472(s0)
    8000541c:	94be                	add	s1,s1,a5
    8000541e:	06f4ec63          	bltu	s1,a5,80005496 <kexec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80005422:	b5843703          	ld	a4,-1192(s0)
    80005426:	8ff9                	and	a5,a5,a4
    80005428:	e7bd                	bnez	a5,80005496 <kexec+0x220>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000542a:	e1c42503          	lw	a0,-484(s0)
    8000542e:	e2dff0ef          	jal	ra,8000525a <flags2perm>
    80005432:	86aa                	mv	a3,a0
    80005434:	8626                	mv	a2,s1
    80005436:	b7043583          	ld	a1,-1168(s0)
    8000543a:	855e                	mv	a0,s7
    8000543c:	f43fb0ef          	jal	ra,8000137e <uvmalloc>
    80005440:	b6a43823          	sd	a0,-1168(s0)
    80005444:	c929                	beqz	a0,80005496 <kexec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005446:	e2843c03          	ld	s8,-472(s0)
    8000544a:	e2042c83          	lw	s9,-480(s0)
    8000544e:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005452:	f60b0ae3          	beqz	s6,800053c6 <kexec+0x150>
    80005456:	89da                	mv	s3,s6
    80005458:	4481                	li	s1,0
    8000545a:	bf81                	j	800053aa <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000545c:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    80005460:	8556                	mv	a0,s5
    80005462:	c83fe0ef          	jal	ra,800040e4 <iunlockput>
  end_op();
    80005466:	cc6ff0ef          	jal	ra,8000492c <end_op>
  p = myproc();
    8000546a:	f54fc0ef          	jal	ra,80001bbe <myproc>
    8000546e:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    80005472:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005476:	6585                	lui	a1,0x1
    80005478:	15fd                	addi	a1,a1,-1
    8000547a:	b7043783          	ld	a5,-1168(s0)
    8000547e:	95be                	add	a1,a1,a5
    80005480:	77fd                	lui	a5,0xfffff
    80005482:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005484:	4691                	li	a3,4
    80005486:	6609                	lui	a2,0x2
    80005488:	962e                	add	a2,a2,a1
    8000548a:	855e                	mv	a0,s7
    8000548c:	ef3fb0ef          	jal	ra,8000137e <uvmalloc>
    80005490:	8b2a                	mv	s6,a0
  ip = 0;
    80005492:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005494:	e121                	bnez	a0,800054d4 <kexec+0x25e>
    delete_shm_from_proc(p);
    80005496:	b7843903          	ld	s2,-1160(s0)
    8000549a:	854a                	mv	a0,s2
    8000549c:	8a7fc0ef          	jal	ra,80001d42 <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    800054a0:	16890493          	addi	s1,s2,360
    800054a4:	85a6                	mv	a1,s1
    800054a6:	05093503          	ld	a0,80(s2)
    800054aa:	a8dfc0ef          	jal	ra,80001f36 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    800054ae:	28000613          	li	a2,640
    800054b2:	4581                	li	a1,0
    800054b4:	8526                	mv	a0,s1
    800054b6:	8ddfb0ef          	jal	ra,80000d92 <memset>
    vma_release_all(p);
    800054ba:	854a                	mv	a0,s2
    800054bc:	907fc0ef          	jal	ra,80001dc2 <vma_release_all>
    proc_freepagetable(p->pagetable, p->sz);
    800054c0:	04893583          	ld	a1,72(s2)
    800054c4:	05093503          	ld	a0,80(s2)
    800054c8:	ab9fc0ef          	jal	ra,80001f80 <proc_freepagetable>
  if(ip){
    800054cc:	e20a9ae3          	bnez	s5,80005300 <kexec+0x8a>
  return -1;
    800054d0:	557d                	li	a0,-1
    800054d2:	bd2d                	j	8000530c <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800054d4:	75f9                	lui	a1,0xffffe
    800054d6:	95aa                	add	a1,a1,a0
    800054d8:	855e                	mv	a0,s7
    800054da:	968fc0ef          	jal	ra,80001642 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800054de:	7c7d                	lui	s8,0xfffff
    800054e0:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800054e2:	b6843783          	ld	a5,-1176(s0)
    800054e6:	6388                	ld	a0,0(a5)
    800054e8:	c125                	beqz	a0,80005548 <kexec+0x2d2>
    800054ea:	e9040993          	addi	s3,s0,-368
    800054ee:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    800054f2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800054f4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054f6:	a15fb0ef          	jal	ra,80000f0a <strlen>
    800054fa:	0015079b          	addiw	a5,a0,1
    800054fe:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005502:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005506:	11896d63          	bltu	s2,s8,80005620 <kexec+0x3aa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000550a:	b6843d03          	ld	s10,-1176(s0)
    8000550e:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdaae00>
    80005512:	8552                	mv	a0,s4
    80005514:	9f7fb0ef          	jal	ra,80000f0a <strlen>
    80005518:	0015069b          	addiw	a3,a0,1
    8000551c:	8652                	mv	a2,s4
    8000551e:	85ca                	mv	a1,s2
    80005520:	855e                	mv	a0,s7
    80005522:	a8cfc0ef          	jal	ra,800017ae <copyout>
    80005526:	0e054f63          	bltz	a0,80005624 <kexec+0x3ae>
    ustack[argc] = sp;
    8000552a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000552e:	0485                	addi	s1,s1,1
    80005530:	008d0793          	addi	a5,s10,8
    80005534:	b6f43423          	sd	a5,-1176(s0)
    80005538:	008d3503          	ld	a0,8(s10)
    8000553c:	c901                	beqz	a0,8000554c <kexec+0x2d6>
    if(argc >= MAXARG)
    8000553e:	09a1                	addi	s3,s3,8
    80005540:	fb599be3          	bne	s3,s5,800054f6 <kexec+0x280>
  ip = 0;
    80005544:	4a81                	li	s5,0
    80005546:	bf81                	j	80005496 <kexec+0x220>
  sp = sz;
    80005548:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000554a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000554c:	00349793          	slli	a5,s1,0x3
    80005550:	f9040713          	addi	a4,s0,-112
    80005554:	97ba                	add	a5,a5,a4
    80005556:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7fdaad00>
  sp -= (argc+1) * sizeof(uint64);
    8000555a:	00148693          	addi	a3,s1,1
    8000555e:	068e                	slli	a3,a3,0x3
    80005560:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005564:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005568:	4a81                	li	s5,0
  if(sp < stackbase)
    8000556a:	f38966e3          	bltu	s2,s8,80005496 <kexec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000556e:	e9040613          	addi	a2,s0,-368
    80005572:	85ca                	mv	a1,s2
    80005574:	855e                	mv	a0,s7
    80005576:	a38fc0ef          	jal	ra,800017ae <copyout>
    8000557a:	0a054763          	bltz	a0,80005628 <kexec+0x3b2>
  p->trapframe->a1 = sp;
    8000557e:	b7843783          	ld	a5,-1160(s0)
    80005582:	6fbc                	ld	a5,88(a5)
    80005584:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005588:	b6043783          	ld	a5,-1184(s0)
    8000558c:	0007c703          	lbu	a4,0(a5)
    80005590:	cf11                	beqz	a4,800055ac <kexec+0x336>
    80005592:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005594:	02f00693          	li	a3,47
    80005598:	a039                	j	800055a6 <kexec+0x330>
      last = s+1;
    8000559a:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    8000559e:	0785                	addi	a5,a5,1
    800055a0:	fff7c703          	lbu	a4,-1(a5)
    800055a4:	c701                	beqz	a4,800055ac <kexec+0x336>
    if(*s == '/')
    800055a6:	fed71ce3          	bne	a4,a3,8000559e <kexec+0x328>
    800055aa:	bfc5                	j	8000559a <kexec+0x324>
  safestrcpy(p->name, last, sizeof(p->name));
    800055ac:	4641                	li	a2,16
    800055ae:	b6043583          	ld	a1,-1184(s0)
    800055b2:	b7843a83          	ld	s5,-1160(s0)
    800055b6:	158a8513          	addi	a0,s5,344
    800055ba:	91ffb0ef          	jal	ra,80000ed8 <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    800055be:	168a8a13          	addi	s4,s5,360
    800055c2:	28000613          	li	a2,640
    800055c6:	85d2                	mv	a1,s4
    800055c8:	b9840513          	addi	a0,s0,-1128
    800055cc:	823fb0ef          	jal	ra,80000dee <memmove>
  oldpagetable = p->pagetable;
    800055d0:	050ab983          	ld	s3,80(s5)
  vma_release_all(p);
    800055d4:	8556                	mv	a0,s5
    800055d6:	fecfc0ef          	jal	ra,80001dc2 <vma_release_all>
  p->pagetable = pagetable;
    800055da:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800055de:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;
    800055e2:	058ab783          	ld	a5,88(s5)
    800055e6:	e6843703          	ld	a4,-408(s0)
    800055ea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800055ec:	058ab783          	ld	a5,88(s5)
    800055f0:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800055f4:	28000613          	li	a2,640
    800055f8:	4581                	li	a1,0
    800055fa:	8552                	mv	a0,s4
    800055fc:	f96fb0ef          	jal	ra,80000d92 <memset>
  delete_shm_from_vmas(oldvmas);
    80005600:	b9840513          	addi	a0,s0,-1128
    80005604:	ec0fc0ef          	jal	ra,80001cc4 <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    80005608:	b9840593          	addi	a1,s0,-1128
    8000560c:	854e                	mv	a0,s3
    8000560e:	929fc0ef          	jal	ra,80001f36 <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    80005612:	85e6                	mv	a1,s9
    80005614:	854e                	mv	a0,s3
    80005616:	96bfc0ef          	jal	ra,80001f80 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000561a:	0004851b          	sext.w	a0,s1
    8000561e:	b1fd                	j	8000530c <kexec+0x96>
  ip = 0;
    80005620:	4a81                	li	s5,0
    80005622:	bd95                	j	80005496 <kexec+0x220>
    80005624:	4a81                	li	s5,0
    80005626:	bd85                	j	80005496 <kexec+0x220>
    80005628:	4a81                	li	s5,0
    8000562a:	b5b5                	j	80005496 <kexec+0x220>

000000008000562c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000562c:	7179                	addi	sp,sp,-48
    8000562e:	f406                	sd	ra,40(sp)
    80005630:	f022                	sd	s0,32(sp)
    80005632:	ec26                	sd	s1,24(sp)
    80005634:	e84a                	sd	s2,16(sp)
    80005636:	1800                	addi	s0,sp,48
    80005638:	892e                	mv	s2,a1
    8000563a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000563c:	fdc40593          	addi	a1,s0,-36
    80005640:	facfd0ef          	jal	ra,80002dec <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005644:	fdc42703          	lw	a4,-36(s0)
    80005648:	47bd                	li	a5,15
    8000564a:	02e7e963          	bltu	a5,a4,8000567c <argfd+0x50>
    8000564e:	d70fc0ef          	jal	ra,80001bbe <myproc>
    80005652:	fdc42703          	lw	a4,-36(s0)
    80005656:	01a70793          	addi	a5,a4,26
    8000565a:	078e                	slli	a5,a5,0x3
    8000565c:	953e                	add	a0,a0,a5
    8000565e:	611c                	ld	a5,0(a0)
    80005660:	c385                	beqz	a5,80005680 <argfd+0x54>
    return -1;
  if(pfd)
    80005662:	00090463          	beqz	s2,8000566a <argfd+0x3e>
    *pfd = fd;
    80005666:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000566a:	4501                	li	a0,0
  if(pf)
    8000566c:	c091                	beqz	s1,80005670 <argfd+0x44>
    *pf = f;
    8000566e:	e09c                	sd	a5,0(s1)
}
    80005670:	70a2                	ld	ra,40(sp)
    80005672:	7402                	ld	s0,32(sp)
    80005674:	64e2                	ld	s1,24(sp)
    80005676:	6942                	ld	s2,16(sp)
    80005678:	6145                	addi	sp,sp,48
    8000567a:	8082                	ret
    return -1;
    8000567c:	557d                	li	a0,-1
    8000567e:	bfcd                	j	80005670 <argfd+0x44>
    80005680:	557d                	li	a0,-1
    80005682:	b7fd                	j	80005670 <argfd+0x44>

0000000080005684 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005684:	1101                	addi	sp,sp,-32
    80005686:	ec06                	sd	ra,24(sp)
    80005688:	e822                	sd	s0,16(sp)
    8000568a:	e426                	sd	s1,8(sp)
    8000568c:	1000                	addi	s0,sp,32
    8000568e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005690:	d2efc0ef          	jal	ra,80001bbe <myproc>
    80005694:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005696:	0d050793          	addi	a5,a0,208
    8000569a:	4501                	li	a0,0
    8000569c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000569e:	6398                	ld	a4,0(a5)
    800056a0:	cb19                	beqz	a4,800056b6 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800056a2:	2505                	addiw	a0,a0,1
    800056a4:	07a1                	addi	a5,a5,8
    800056a6:	fed51ce3          	bne	a0,a3,8000569e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800056aa:	557d                	li	a0,-1
}
    800056ac:	60e2                	ld	ra,24(sp)
    800056ae:	6442                	ld	s0,16(sp)
    800056b0:	64a2                	ld	s1,8(sp)
    800056b2:	6105                	addi	sp,sp,32
    800056b4:	8082                	ret
      p->ofile[fd] = f;
    800056b6:	01a50793          	addi	a5,a0,26
    800056ba:	078e                	slli	a5,a5,0x3
    800056bc:	963e                	add	a2,a2,a5
    800056be:	e204                	sd	s1,0(a2)
      return fd;
    800056c0:	b7f5                	j	800056ac <fdalloc+0x28>

00000000800056c2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056c2:	715d                	addi	sp,sp,-80
    800056c4:	e486                	sd	ra,72(sp)
    800056c6:	e0a2                	sd	s0,64(sp)
    800056c8:	fc26                	sd	s1,56(sp)
    800056ca:	f84a                	sd	s2,48(sp)
    800056cc:	f44e                	sd	s3,40(sp)
    800056ce:	f052                	sd	s4,32(sp)
    800056d0:	ec56                	sd	s5,24(sp)
    800056d2:	e85a                	sd	s6,16(sp)
    800056d4:	0880                	addi	s0,sp,80
    800056d6:	8b2e                	mv	s6,a1
    800056d8:	89b2                	mv	s3,a2
    800056da:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056dc:	fb040593          	addi	a1,s0,-80
    800056e0:	806ff0ef          	jal	ra,800046e6 <nameiparent>
    800056e4:	84aa                	mv	s1,a0
    800056e6:	10050b63          	beqz	a0,800057fc <create+0x13a>
    return 0;

  ilock(dp);
    800056ea:	ff4fe0ef          	jal	ra,80003ede <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056ee:	4601                	li	a2,0
    800056f0:	fb040593          	addi	a1,s0,-80
    800056f4:	8526                	mv	a0,s1
    800056f6:	d71fe0ef          	jal	ra,80004466 <dirlookup>
    800056fa:	8aaa                	mv	s5,a0
    800056fc:	c521                	beqz	a0,80005744 <create+0x82>
    iunlockput(dp);
    800056fe:	8526                	mv	a0,s1
    80005700:	9e5fe0ef          	jal	ra,800040e4 <iunlockput>
    ilock(ip);
    80005704:	8556                	mv	a0,s5
    80005706:	fd8fe0ef          	jal	ra,80003ede <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000570a:	000b059b          	sext.w	a1,s6
    8000570e:	4789                	li	a5,2
    80005710:	02f59563          	bne	a1,a5,8000573a <create+0x78>
    80005714:	044ad783          	lhu	a5,68(s5)
    80005718:	37f9                	addiw	a5,a5,-2
    8000571a:	17c2                	slli	a5,a5,0x30
    8000571c:	93c1                	srli	a5,a5,0x30
    8000571e:	4705                	li	a4,1
    80005720:	00f76d63          	bltu	a4,a5,8000573a <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005724:	8556                	mv	a0,s5
    80005726:	60a6                	ld	ra,72(sp)
    80005728:	6406                	ld	s0,64(sp)
    8000572a:	74e2                	ld	s1,56(sp)
    8000572c:	7942                	ld	s2,48(sp)
    8000572e:	79a2                	ld	s3,40(sp)
    80005730:	7a02                	ld	s4,32(sp)
    80005732:	6ae2                	ld	s5,24(sp)
    80005734:	6b42                	ld	s6,16(sp)
    80005736:	6161                	addi	sp,sp,80
    80005738:	8082                	ret
    iunlockput(ip);
    8000573a:	8556                	mv	a0,s5
    8000573c:	9a9fe0ef          	jal	ra,800040e4 <iunlockput>
    return 0;
    80005740:	4a81                	li	s5,0
    80005742:	b7cd                	j	80005724 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005744:	85da                	mv	a1,s6
    80005746:	4088                	lw	a0,0(s1)
    80005748:	e2efe0ef          	jal	ra,80003d76 <ialloc>
    8000574c:	8a2a                	mv	s4,a0
    8000574e:	cd1d                	beqz	a0,8000578c <create+0xca>
  ilock(ip);
    80005750:	f8efe0ef          	jal	ra,80003ede <ilock>
  ip->major = major;
    80005754:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005758:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000575c:	4905                	li	s2,1
    8000575e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005762:	8552                	mv	a0,s4
    80005764:	ec8fe0ef          	jal	ra,80003e2c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005768:	000b059b          	sext.w	a1,s6
    8000576c:	03258563          	beq	a1,s2,80005796 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005770:	004a2603          	lw	a2,4(s4)
    80005774:	fb040593          	addi	a1,s0,-80
    80005778:	8526                	mv	a0,s1
    8000577a:	eb9fe0ef          	jal	ra,80004632 <dirlink>
    8000577e:	06054363          	bltz	a0,800057e4 <create+0x122>
  iunlockput(dp);
    80005782:	8526                	mv	a0,s1
    80005784:	961fe0ef          	jal	ra,800040e4 <iunlockput>
  return ip;
    80005788:	8ad2                	mv	s5,s4
    8000578a:	bf69                	j	80005724 <create+0x62>
    iunlockput(dp);
    8000578c:	8526                	mv	a0,s1
    8000578e:	957fe0ef          	jal	ra,800040e4 <iunlockput>
    return 0;
    80005792:	8ad2                	mv	s5,s4
    80005794:	bf41                	j	80005724 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005796:	004a2603          	lw	a2,4(s4)
    8000579a:	00003597          	auipc	a1,0x3
    8000579e:	f7e58593          	addi	a1,a1,-130 # 80008718 <syscalls+0x320>
    800057a2:	8552                	mv	a0,s4
    800057a4:	e8ffe0ef          	jal	ra,80004632 <dirlink>
    800057a8:	02054e63          	bltz	a0,800057e4 <create+0x122>
    800057ac:	40d0                	lw	a2,4(s1)
    800057ae:	00003597          	auipc	a1,0x3
    800057b2:	f7258593          	addi	a1,a1,-142 # 80008720 <syscalls+0x328>
    800057b6:	8552                	mv	a0,s4
    800057b8:	e7bfe0ef          	jal	ra,80004632 <dirlink>
    800057bc:	02054463          	bltz	a0,800057e4 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    800057c0:	004a2603          	lw	a2,4(s4)
    800057c4:	fb040593          	addi	a1,s0,-80
    800057c8:	8526                	mv	a0,s1
    800057ca:	e69fe0ef          	jal	ra,80004632 <dirlink>
    800057ce:	00054b63          	bltz	a0,800057e4 <create+0x122>
    dp->nlink++;  // for ".."
    800057d2:	04a4d783          	lhu	a5,74(s1)
    800057d6:	2785                	addiw	a5,a5,1
    800057d8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057dc:	8526                	mv	a0,s1
    800057de:	e4efe0ef          	jal	ra,80003e2c <iupdate>
    800057e2:	b745                	j	80005782 <create+0xc0>
  ip->nlink = 0;
    800057e4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057e8:	8552                	mv	a0,s4
    800057ea:	e42fe0ef          	jal	ra,80003e2c <iupdate>
  iunlockput(ip);
    800057ee:	8552                	mv	a0,s4
    800057f0:	8f5fe0ef          	jal	ra,800040e4 <iunlockput>
  iunlockput(dp);
    800057f4:	8526                	mv	a0,s1
    800057f6:	8effe0ef          	jal	ra,800040e4 <iunlockput>
  return 0;
    800057fa:	b72d                	j	80005724 <create+0x62>
    return 0;
    800057fc:	8aaa                	mv	s5,a0
    800057fe:	b71d                	j	80005724 <create+0x62>

0000000080005800 <sys_dup>:
{
    80005800:	7179                	addi	sp,sp,-48
    80005802:	f406                	sd	ra,40(sp)
    80005804:	f022                	sd	s0,32(sp)
    80005806:	ec26                	sd	s1,24(sp)
    80005808:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000580a:	fd840613          	addi	a2,s0,-40
    8000580e:	4581                	li	a1,0
    80005810:	4501                	li	a0,0
    80005812:	e1bff0ef          	jal	ra,8000562c <argfd>
    return -1;
    80005816:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005818:	00054f63          	bltz	a0,80005836 <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    8000581c:	fd843503          	ld	a0,-40(s0)
    80005820:	e65ff0ef          	jal	ra,80005684 <fdalloc>
    80005824:	84aa                	mv	s1,a0
    return -1;
    80005826:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005828:	00054763          	bltz	a0,80005836 <sys_dup+0x36>
  filedup(f);
    8000582c:	fd843503          	ld	a0,-40(s0)
    80005830:	c54ff0ef          	jal	ra,80004c84 <filedup>
  return fd;
    80005834:	87a6                	mv	a5,s1
}
    80005836:	853e                	mv	a0,a5
    80005838:	70a2                	ld	ra,40(sp)
    8000583a:	7402                	ld	s0,32(sp)
    8000583c:	64e2                	ld	s1,24(sp)
    8000583e:	6145                	addi	sp,sp,48
    80005840:	8082                	ret

0000000080005842 <sys_read>:
{
    80005842:	7179                	addi	sp,sp,-48
    80005844:	f406                	sd	ra,40(sp)
    80005846:	f022                	sd	s0,32(sp)
    80005848:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000584a:	fd840593          	addi	a1,s0,-40
    8000584e:	4505                	li	a0,1
    80005850:	db8fd0ef          	jal	ra,80002e08 <argaddr>
  argint(2, &n);
    80005854:	fe440593          	addi	a1,s0,-28
    80005858:	4509                	li	a0,2
    8000585a:	d92fd0ef          	jal	ra,80002dec <argint>
  if(argfd(0, 0, &f) < 0)
    8000585e:	fe840613          	addi	a2,s0,-24
    80005862:	4581                	li	a1,0
    80005864:	4501                	li	a0,0
    80005866:	dc7ff0ef          	jal	ra,8000562c <argfd>
    8000586a:	87aa                	mv	a5,a0
    return -1;
    8000586c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000586e:	0007ca63          	bltz	a5,80005882 <sys_read+0x40>
  return fileread(f, p, n);
    80005872:	fe442603          	lw	a2,-28(s0)
    80005876:	fd843583          	ld	a1,-40(s0)
    8000587a:	fe843503          	ld	a0,-24(s0)
    8000587e:	d52ff0ef          	jal	ra,80004dd0 <fileread>
}
    80005882:	70a2                	ld	ra,40(sp)
    80005884:	7402                	ld	s0,32(sp)
    80005886:	6145                	addi	sp,sp,48
    80005888:	8082                	ret

000000008000588a <sys_write>:
{
    8000588a:	7179                	addi	sp,sp,-48
    8000588c:	f406                	sd	ra,40(sp)
    8000588e:	f022                	sd	s0,32(sp)
    80005890:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005892:	fd840593          	addi	a1,s0,-40
    80005896:	4505                	li	a0,1
    80005898:	d70fd0ef          	jal	ra,80002e08 <argaddr>
  argint(2, &n);
    8000589c:	fe440593          	addi	a1,s0,-28
    800058a0:	4509                	li	a0,2
    800058a2:	d4afd0ef          	jal	ra,80002dec <argint>
  if(argfd(0, 0, &f) < 0)
    800058a6:	fe840613          	addi	a2,s0,-24
    800058aa:	4581                	li	a1,0
    800058ac:	4501                	li	a0,0
    800058ae:	d7fff0ef          	jal	ra,8000562c <argfd>
    800058b2:	87aa                	mv	a5,a0
    return -1;
    800058b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058b6:	0007ca63          	bltz	a5,800058ca <sys_write+0x40>
  return filewrite(f, p, n);
    800058ba:	fe442603          	lw	a2,-28(s0)
    800058be:	fd843583          	ld	a1,-40(s0)
    800058c2:	fe843503          	ld	a0,-24(s0)
    800058c6:	db8ff0ef          	jal	ra,80004e7e <filewrite>
}
    800058ca:	70a2                	ld	ra,40(sp)
    800058cc:	7402                	ld	s0,32(sp)
    800058ce:	6145                	addi	sp,sp,48
    800058d0:	8082                	ret

00000000800058d2 <sys_close>:
{
    800058d2:	1101                	addi	sp,sp,-32
    800058d4:	ec06                	sd	ra,24(sp)
    800058d6:	e822                	sd	s0,16(sp)
    800058d8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058da:	fe040613          	addi	a2,s0,-32
    800058de:	fec40593          	addi	a1,s0,-20
    800058e2:	4501                	li	a0,0
    800058e4:	d49ff0ef          	jal	ra,8000562c <argfd>
    return -1;
    800058e8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058ea:	02054063          	bltz	a0,8000590a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800058ee:	ad0fc0ef          	jal	ra,80001bbe <myproc>
    800058f2:	fec42783          	lw	a5,-20(s0)
    800058f6:	07e9                	addi	a5,a5,26
    800058f8:	078e                	slli	a5,a5,0x3
    800058fa:	97aa                	add	a5,a5,a0
    800058fc:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005900:	fe043503          	ld	a0,-32(s0)
    80005904:	bc6ff0ef          	jal	ra,80004cca <fileclose>
  return 0;
    80005908:	4781                	li	a5,0
}
    8000590a:	853e                	mv	a0,a5
    8000590c:	60e2                	ld	ra,24(sp)
    8000590e:	6442                	ld	s0,16(sp)
    80005910:	6105                	addi	sp,sp,32
    80005912:	8082                	ret

0000000080005914 <sys_fstat>:
{
    80005914:	1101                	addi	sp,sp,-32
    80005916:	ec06                	sd	ra,24(sp)
    80005918:	e822                	sd	s0,16(sp)
    8000591a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000591c:	fe040593          	addi	a1,s0,-32
    80005920:	4505                	li	a0,1
    80005922:	ce6fd0ef          	jal	ra,80002e08 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005926:	fe840613          	addi	a2,s0,-24
    8000592a:	4581                	li	a1,0
    8000592c:	4501                	li	a0,0
    8000592e:	cffff0ef          	jal	ra,8000562c <argfd>
    80005932:	87aa                	mv	a5,a0
    return -1;
    80005934:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005936:	0007c863          	bltz	a5,80005946 <sys_fstat+0x32>
  return filestat(f, st);
    8000593a:	fe043583          	ld	a1,-32(s0)
    8000593e:	fe843503          	ld	a0,-24(s0)
    80005942:	c30ff0ef          	jal	ra,80004d72 <filestat>
}
    80005946:	60e2                	ld	ra,24(sp)
    80005948:	6442                	ld	s0,16(sp)
    8000594a:	6105                	addi	sp,sp,32
    8000594c:	8082                	ret

000000008000594e <sys_link>:
{
    8000594e:	7169                	addi	sp,sp,-304
    80005950:	f606                	sd	ra,296(sp)
    80005952:	f222                	sd	s0,288(sp)
    80005954:	ee26                	sd	s1,280(sp)
    80005956:	ea4a                	sd	s2,272(sp)
    80005958:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000595a:	08000613          	li	a2,128
    8000595e:	ed040593          	addi	a1,s0,-304
    80005962:	4501                	li	a0,0
    80005964:	cc0fd0ef          	jal	ra,80002e24 <argstr>
    return -1;
    80005968:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000596a:	0c054663          	bltz	a0,80005a36 <sys_link+0xe8>
    8000596e:	08000613          	li	a2,128
    80005972:	f5040593          	addi	a1,s0,-176
    80005976:	4505                	li	a0,1
    80005978:	cacfd0ef          	jal	ra,80002e24 <argstr>
    return -1;
    8000597c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000597e:	0a054c63          	bltz	a0,80005a36 <sys_link+0xe8>
  begin_op();
    80005982:	f3bfe0ef          	jal	ra,800048bc <begin_op>
  if((ip = namei(old)) == 0){
    80005986:	ed040513          	addi	a0,s0,-304
    8000598a:	d43fe0ef          	jal	ra,800046cc <namei>
    8000598e:	84aa                	mv	s1,a0
    80005990:	c525                	beqz	a0,800059f8 <sys_link+0xaa>
  ilock(ip);
    80005992:	d4cfe0ef          	jal	ra,80003ede <ilock>
  if(ip->type == T_DIR){
    80005996:	04449703          	lh	a4,68(s1)
    8000599a:	4785                	li	a5,1
    8000599c:	06f70263          	beq	a4,a5,80005a00 <sys_link+0xb2>
  ip->nlink++;
    800059a0:	04a4d783          	lhu	a5,74(s1)
    800059a4:	2785                	addiw	a5,a5,1
    800059a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059aa:	8526                	mv	a0,s1
    800059ac:	c80fe0ef          	jal	ra,80003e2c <iupdate>
  iunlock(ip);
    800059b0:	8526                	mv	a0,s1
    800059b2:	dd6fe0ef          	jal	ra,80003f88 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059b6:	fd040593          	addi	a1,s0,-48
    800059ba:	f5040513          	addi	a0,s0,-176
    800059be:	d29fe0ef          	jal	ra,800046e6 <nameiparent>
    800059c2:	892a                	mv	s2,a0
    800059c4:	c921                	beqz	a0,80005a14 <sys_link+0xc6>
  ilock(dp);
    800059c6:	d18fe0ef          	jal	ra,80003ede <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059ca:	00092703          	lw	a4,0(s2)
    800059ce:	409c                	lw	a5,0(s1)
    800059d0:	02f71f63          	bne	a4,a5,80005a0e <sys_link+0xc0>
    800059d4:	40d0                	lw	a2,4(s1)
    800059d6:	fd040593          	addi	a1,s0,-48
    800059da:	854a                	mv	a0,s2
    800059dc:	c57fe0ef          	jal	ra,80004632 <dirlink>
    800059e0:	02054763          	bltz	a0,80005a0e <sys_link+0xc0>
  iunlockput(dp);
    800059e4:	854a                	mv	a0,s2
    800059e6:	efefe0ef          	jal	ra,800040e4 <iunlockput>
  iput(ip);
    800059ea:	8526                	mv	a0,s1
    800059ec:	e70fe0ef          	jal	ra,8000405c <iput>
  end_op();
    800059f0:	f3dfe0ef          	jal	ra,8000492c <end_op>
  return 0;
    800059f4:	4781                	li	a5,0
    800059f6:	a081                	j	80005a36 <sys_link+0xe8>
    end_op();
    800059f8:	f35fe0ef          	jal	ra,8000492c <end_op>
    return -1;
    800059fc:	57fd                	li	a5,-1
    800059fe:	a825                	j	80005a36 <sys_link+0xe8>
    iunlockput(ip);
    80005a00:	8526                	mv	a0,s1
    80005a02:	ee2fe0ef          	jal	ra,800040e4 <iunlockput>
    end_op();
    80005a06:	f27fe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005a0a:	57fd                	li	a5,-1
    80005a0c:	a02d                	j	80005a36 <sys_link+0xe8>
    iunlockput(dp);
    80005a0e:	854a                	mv	a0,s2
    80005a10:	ed4fe0ef          	jal	ra,800040e4 <iunlockput>
  ilock(ip);
    80005a14:	8526                	mv	a0,s1
    80005a16:	cc8fe0ef          	jal	ra,80003ede <ilock>
  ip->nlink--;
    80005a1a:	04a4d783          	lhu	a5,74(s1)
    80005a1e:	37fd                	addiw	a5,a5,-1
    80005a20:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a24:	8526                	mv	a0,s1
    80005a26:	c06fe0ef          	jal	ra,80003e2c <iupdate>
  iunlockput(ip);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	eb8fe0ef          	jal	ra,800040e4 <iunlockput>
  end_op();
    80005a30:	efdfe0ef          	jal	ra,8000492c <end_op>
  return -1;
    80005a34:	57fd                	li	a5,-1
}
    80005a36:	853e                	mv	a0,a5
    80005a38:	70b2                	ld	ra,296(sp)
    80005a3a:	7412                	ld	s0,288(sp)
    80005a3c:	64f2                	ld	s1,280(sp)
    80005a3e:	6952                	ld	s2,272(sp)
    80005a40:	6155                	addi	sp,sp,304
    80005a42:	8082                	ret

0000000080005a44 <sys_unlink>:
{
    80005a44:	7151                	addi	sp,sp,-240
    80005a46:	f586                	sd	ra,232(sp)
    80005a48:	f1a2                	sd	s0,224(sp)
    80005a4a:	eda6                	sd	s1,216(sp)
    80005a4c:	e9ca                	sd	s2,208(sp)
    80005a4e:	e5ce                	sd	s3,200(sp)
    80005a50:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a52:	08000613          	li	a2,128
    80005a56:	f3040593          	addi	a1,s0,-208
    80005a5a:	4501                	li	a0,0
    80005a5c:	bc8fd0ef          	jal	ra,80002e24 <argstr>
    80005a60:	12054b63          	bltz	a0,80005b96 <sys_unlink+0x152>
  begin_op();
    80005a64:	e59fe0ef          	jal	ra,800048bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a68:	fb040593          	addi	a1,s0,-80
    80005a6c:	f3040513          	addi	a0,s0,-208
    80005a70:	c77fe0ef          	jal	ra,800046e6 <nameiparent>
    80005a74:	84aa                	mv	s1,a0
    80005a76:	c54d                	beqz	a0,80005b20 <sys_unlink+0xdc>
  ilock(dp);
    80005a78:	c66fe0ef          	jal	ra,80003ede <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a7c:	00003597          	auipc	a1,0x3
    80005a80:	c9c58593          	addi	a1,a1,-868 # 80008718 <syscalls+0x320>
    80005a84:	fb040513          	addi	a0,s0,-80
    80005a88:	9c9fe0ef          	jal	ra,80004450 <namecmp>
    80005a8c:	10050a63          	beqz	a0,80005ba0 <sys_unlink+0x15c>
    80005a90:	00003597          	auipc	a1,0x3
    80005a94:	c9058593          	addi	a1,a1,-880 # 80008720 <syscalls+0x328>
    80005a98:	fb040513          	addi	a0,s0,-80
    80005a9c:	9b5fe0ef          	jal	ra,80004450 <namecmp>
    80005aa0:	10050063          	beqz	a0,80005ba0 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005aa4:	f2c40613          	addi	a2,s0,-212
    80005aa8:	fb040593          	addi	a1,s0,-80
    80005aac:	8526                	mv	a0,s1
    80005aae:	9b9fe0ef          	jal	ra,80004466 <dirlookup>
    80005ab2:	892a                	mv	s2,a0
    80005ab4:	0e050663          	beqz	a0,80005ba0 <sys_unlink+0x15c>
  ilock(ip);
    80005ab8:	c26fe0ef          	jal	ra,80003ede <ilock>
  if(ip->nlink < 1)
    80005abc:	04a91783          	lh	a5,74(s2)
    80005ac0:	06f05463          	blez	a5,80005b28 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ac4:	04491703          	lh	a4,68(s2)
    80005ac8:	4785                	li	a5,1
    80005aca:	06f70563          	beq	a4,a5,80005b34 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80005ace:	4641                	li	a2,16
    80005ad0:	4581                	li	a1,0
    80005ad2:	fc040513          	addi	a0,s0,-64
    80005ad6:	abcfb0ef          	jal	ra,80000d92 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ada:	4741                	li	a4,16
    80005adc:	f2c42683          	lw	a3,-212(s0)
    80005ae0:	fc040613          	addi	a2,s0,-64
    80005ae4:	4581                	li	a1,0
    80005ae6:	8526                	mv	a0,s1
    80005ae8:	867fe0ef          	jal	ra,8000434e <writei>
    80005aec:	47c1                	li	a5,16
    80005aee:	08f51563          	bne	a0,a5,80005b78 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005af2:	04491703          	lh	a4,68(s2)
    80005af6:	4785                	li	a5,1
    80005af8:	08f70663          	beq	a4,a5,80005b84 <sys_unlink+0x140>
  iunlockput(dp);
    80005afc:	8526                	mv	a0,s1
    80005afe:	de6fe0ef          	jal	ra,800040e4 <iunlockput>
  ip->nlink--;
    80005b02:	04a95783          	lhu	a5,74(s2)
    80005b06:	37fd                	addiw	a5,a5,-1
    80005b08:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b0c:	854a                	mv	a0,s2
    80005b0e:	b1efe0ef          	jal	ra,80003e2c <iupdate>
  iunlockput(ip);
    80005b12:	854a                	mv	a0,s2
    80005b14:	dd0fe0ef          	jal	ra,800040e4 <iunlockput>
  end_op();
    80005b18:	e15fe0ef          	jal	ra,8000492c <end_op>
  return 0;
    80005b1c:	4501                	li	a0,0
    80005b1e:	a079                	j	80005bac <sys_unlink+0x168>
    end_op();
    80005b20:	e0dfe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005b24:	557d                	li	a0,-1
    80005b26:	a059                	j	80005bac <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005b28:	00003517          	auipc	a0,0x3
    80005b2c:	c0050513          	addi	a0,a0,-1024 # 80008728 <syscalls+0x330>
    80005b30:	c5bfa0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b34:	04c92703          	lw	a4,76(s2)
    80005b38:	02000793          	li	a5,32
    80005b3c:	f8e7f9e3          	bgeu	a5,a4,80005ace <sys_unlink+0x8a>
    80005b40:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b44:	4741                	li	a4,16
    80005b46:	86ce                	mv	a3,s3
    80005b48:	f1840613          	addi	a2,s0,-232
    80005b4c:	4581                	li	a1,0
    80005b4e:	854a                	mv	a0,s2
    80005b50:	f1afe0ef          	jal	ra,8000426a <readi>
    80005b54:	47c1                	li	a5,16
    80005b56:	00f51b63          	bne	a0,a5,80005b6c <sys_unlink+0x128>
    if(de.inum != 0)
    80005b5a:	f1845783          	lhu	a5,-232(s0)
    80005b5e:	ef95                	bnez	a5,80005b9a <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b60:	29c1                	addiw	s3,s3,16
    80005b62:	04c92783          	lw	a5,76(s2)
    80005b66:	fcf9efe3          	bltu	s3,a5,80005b44 <sys_unlink+0x100>
    80005b6a:	b795                	j	80005ace <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005b6c:	00003517          	auipc	a0,0x3
    80005b70:	bd450513          	addi	a0,a0,-1068 # 80008740 <syscalls+0x348>
    80005b74:	c17fa0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80005b78:	00003517          	auipc	a0,0x3
    80005b7c:	be050513          	addi	a0,a0,-1056 # 80008758 <syscalls+0x360>
    80005b80:	c0bfa0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80005b84:	04a4d783          	lhu	a5,74(s1)
    80005b88:	37fd                	addiw	a5,a5,-1
    80005b8a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	a9cfe0ef          	jal	ra,80003e2c <iupdate>
    80005b94:	b7a5                	j	80005afc <sys_unlink+0xb8>
    return -1;
    80005b96:	557d                	li	a0,-1
    80005b98:	a811                	j	80005bac <sys_unlink+0x168>
    iunlockput(ip);
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	d48fe0ef          	jal	ra,800040e4 <iunlockput>
  iunlockput(dp);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	d42fe0ef          	jal	ra,800040e4 <iunlockput>
  end_op();
    80005ba6:	d87fe0ef          	jal	ra,8000492c <end_op>
  return -1;
    80005baa:	557d                	li	a0,-1
}
    80005bac:	70ae                	ld	ra,232(sp)
    80005bae:	740e                	ld	s0,224(sp)
    80005bb0:	64ee                	ld	s1,216(sp)
    80005bb2:	694e                	ld	s2,208(sp)
    80005bb4:	69ae                	ld	s3,200(sp)
    80005bb6:	616d                	addi	sp,sp,240
    80005bb8:	8082                	ret

0000000080005bba <sys_open>:

uint64
sys_open(void)
{
    80005bba:	7131                	addi	sp,sp,-192
    80005bbc:	fd06                	sd	ra,184(sp)
    80005bbe:	f922                	sd	s0,176(sp)
    80005bc0:	f526                	sd	s1,168(sp)
    80005bc2:	f14a                	sd	s2,160(sp)
    80005bc4:	ed4e                	sd	s3,152(sp)
    80005bc6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bc8:	f4c40593          	addi	a1,s0,-180
    80005bcc:	4505                	li	a0,1
    80005bce:	a1efd0ef          	jal	ra,80002dec <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bd2:	08000613          	li	a2,128
    80005bd6:	f5040593          	addi	a1,s0,-176
    80005bda:	4501                	li	a0,0
    80005bdc:	a48fd0ef          	jal	ra,80002e24 <argstr>
    80005be0:	87aa                	mv	a5,a0
    return -1;
    80005be2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005be4:	0807cd63          	bltz	a5,80005c7e <sys_open+0xc4>

  begin_op();
    80005be8:	cd5fe0ef          	jal	ra,800048bc <begin_op>

  if(omode & O_CREATE){
    80005bec:	f4c42783          	lw	a5,-180(s0)
    80005bf0:	2007f793          	andi	a5,a5,512
    80005bf4:	c3c5                	beqz	a5,80005c94 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005bf6:	4681                	li	a3,0
    80005bf8:	4601                	li	a2,0
    80005bfa:	4589                	li	a1,2
    80005bfc:	f5040513          	addi	a0,s0,-176
    80005c00:	ac3ff0ef          	jal	ra,800056c2 <create>
    80005c04:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c06:	c159                	beqz	a0,80005c8c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c08:	04449703          	lh	a4,68(s1)
    80005c0c:	478d                	li	a5,3
    80005c0e:	00f71763          	bne	a4,a5,80005c1c <sys_open+0x62>
    80005c12:	0464d703          	lhu	a4,70(s1)
    80005c16:	47a5                	li	a5,9
    80005c18:	0ae7e963          	bltu	a5,a4,80005cca <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c1c:	80aff0ef          	jal	ra,80004c26 <filealloc>
    80005c20:	89aa                	mv	s3,a0
    80005c22:	0c050963          	beqz	a0,80005cf4 <sys_open+0x13a>
    80005c26:	a5fff0ef          	jal	ra,80005684 <fdalloc>
    80005c2a:	892a                	mv	s2,a0
    80005c2c:	0c054163          	bltz	a0,80005cee <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c30:	04449703          	lh	a4,68(s1)
    80005c34:	478d                	li	a5,3
    80005c36:	0af70163          	beq	a4,a5,80005cd8 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c3a:	4789                	li	a5,2
    80005c3c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c40:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c44:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c48:	f4c42783          	lw	a5,-180(s0)
    80005c4c:	0017c713          	xori	a4,a5,1
    80005c50:	8b05                	andi	a4,a4,1
    80005c52:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c56:	0037f713          	andi	a4,a5,3
    80005c5a:	00e03733          	snez	a4,a4
    80005c5e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c62:	4007f793          	andi	a5,a5,1024
    80005c66:	c791                	beqz	a5,80005c72 <sys_open+0xb8>
    80005c68:	04449703          	lh	a4,68(s1)
    80005c6c:	4789                	li	a5,2
    80005c6e:	06f70c63          	beq	a4,a5,80005ce6 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c72:	8526                	mv	a0,s1
    80005c74:	b14fe0ef          	jal	ra,80003f88 <iunlock>
  end_op();
    80005c78:	cb5fe0ef          	jal	ra,8000492c <end_op>

  return fd;
    80005c7c:	854a                	mv	a0,s2
}
    80005c7e:	70ea                	ld	ra,184(sp)
    80005c80:	744a                	ld	s0,176(sp)
    80005c82:	74aa                	ld	s1,168(sp)
    80005c84:	790a                	ld	s2,160(sp)
    80005c86:	69ea                	ld	s3,152(sp)
    80005c88:	6129                	addi	sp,sp,192
    80005c8a:	8082                	ret
      end_op();
    80005c8c:	ca1fe0ef          	jal	ra,8000492c <end_op>
      return -1;
    80005c90:	557d                	li	a0,-1
    80005c92:	b7f5                	j	80005c7e <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005c94:	f5040513          	addi	a0,s0,-176
    80005c98:	a35fe0ef          	jal	ra,800046cc <namei>
    80005c9c:	84aa                	mv	s1,a0
    80005c9e:	c115                	beqz	a0,80005cc2 <sys_open+0x108>
    ilock(ip);
    80005ca0:	a3efe0ef          	jal	ra,80003ede <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ca4:	04449703          	lh	a4,68(s1)
    80005ca8:	4785                	li	a5,1
    80005caa:	f4f71fe3          	bne	a4,a5,80005c08 <sys_open+0x4e>
    80005cae:	f4c42783          	lw	a5,-180(s0)
    80005cb2:	d7ad                	beqz	a5,80005c1c <sys_open+0x62>
      iunlockput(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	c2efe0ef          	jal	ra,800040e4 <iunlockput>
      end_op();
    80005cba:	c73fe0ef          	jal	ra,8000492c <end_op>
      return -1;
    80005cbe:	557d                	li	a0,-1
    80005cc0:	bf7d                	j	80005c7e <sys_open+0xc4>
      end_op();
    80005cc2:	c6bfe0ef          	jal	ra,8000492c <end_op>
      return -1;
    80005cc6:	557d                	li	a0,-1
    80005cc8:	bf5d                	j	80005c7e <sys_open+0xc4>
    iunlockput(ip);
    80005cca:	8526                	mv	a0,s1
    80005ccc:	c18fe0ef          	jal	ra,800040e4 <iunlockput>
    end_op();
    80005cd0:	c5dfe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005cd4:	557d                	li	a0,-1
    80005cd6:	b765                	j	80005c7e <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005cd8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cdc:	04649783          	lh	a5,70(s1)
    80005ce0:	02f99223          	sh	a5,36(s3)
    80005ce4:	b785                	j	80005c44 <sys_open+0x8a>
    itrunc(ip);
    80005ce6:	8526                	mv	a0,s1
    80005ce8:	ae0fe0ef          	jal	ra,80003fc8 <itrunc>
    80005cec:	b759                	j	80005c72 <sys_open+0xb8>
      fileclose(f);
    80005cee:	854e                	mv	a0,s3
    80005cf0:	fdbfe0ef          	jal	ra,80004cca <fileclose>
    iunlockput(ip);
    80005cf4:	8526                	mv	a0,s1
    80005cf6:	beefe0ef          	jal	ra,800040e4 <iunlockput>
    end_op();
    80005cfa:	c33fe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005cfe:	557d                	li	a0,-1
    80005d00:	bfbd                	j	80005c7e <sys_open+0xc4>

0000000080005d02 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d02:	7175                	addi	sp,sp,-144
    80005d04:	e506                	sd	ra,136(sp)
    80005d06:	e122                	sd	s0,128(sp)
    80005d08:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d0a:	bb3fe0ef          	jal	ra,800048bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d0e:	08000613          	li	a2,128
    80005d12:	f7040593          	addi	a1,s0,-144
    80005d16:	4501                	li	a0,0
    80005d18:	90cfd0ef          	jal	ra,80002e24 <argstr>
    80005d1c:	02054363          	bltz	a0,80005d42 <sys_mkdir+0x40>
    80005d20:	4681                	li	a3,0
    80005d22:	4601                	li	a2,0
    80005d24:	4585                	li	a1,1
    80005d26:	f7040513          	addi	a0,s0,-144
    80005d2a:	999ff0ef          	jal	ra,800056c2 <create>
    80005d2e:	c911                	beqz	a0,80005d42 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d30:	bb4fe0ef          	jal	ra,800040e4 <iunlockput>
  end_op();
    80005d34:	bf9fe0ef          	jal	ra,8000492c <end_op>
  return 0;
    80005d38:	4501                	li	a0,0
}
    80005d3a:	60aa                	ld	ra,136(sp)
    80005d3c:	640a                	ld	s0,128(sp)
    80005d3e:	6149                	addi	sp,sp,144
    80005d40:	8082                	ret
    end_op();
    80005d42:	bebfe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005d46:	557d                	li	a0,-1
    80005d48:	bfcd                	j	80005d3a <sys_mkdir+0x38>

0000000080005d4a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d4a:	7135                	addi	sp,sp,-160
    80005d4c:	ed06                	sd	ra,152(sp)
    80005d4e:	e922                	sd	s0,144(sp)
    80005d50:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d52:	b6bfe0ef          	jal	ra,800048bc <begin_op>
  argint(1, &major);
    80005d56:	f6c40593          	addi	a1,s0,-148
    80005d5a:	4505                	li	a0,1
    80005d5c:	890fd0ef          	jal	ra,80002dec <argint>
  argint(2, &minor);
    80005d60:	f6840593          	addi	a1,s0,-152
    80005d64:	4509                	li	a0,2
    80005d66:	886fd0ef          	jal	ra,80002dec <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d6a:	08000613          	li	a2,128
    80005d6e:	f7040593          	addi	a1,s0,-144
    80005d72:	4501                	li	a0,0
    80005d74:	8b0fd0ef          	jal	ra,80002e24 <argstr>
    80005d78:	02054563          	bltz	a0,80005da2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d7c:	f6841683          	lh	a3,-152(s0)
    80005d80:	f6c41603          	lh	a2,-148(s0)
    80005d84:	458d                	li	a1,3
    80005d86:	f7040513          	addi	a0,s0,-144
    80005d8a:	939ff0ef          	jal	ra,800056c2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d8e:	c911                	beqz	a0,80005da2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d90:	b54fe0ef          	jal	ra,800040e4 <iunlockput>
  end_op();
    80005d94:	b99fe0ef          	jal	ra,8000492c <end_op>
  return 0;
    80005d98:	4501                	li	a0,0
}
    80005d9a:	60ea                	ld	ra,152(sp)
    80005d9c:	644a                	ld	s0,144(sp)
    80005d9e:	610d                	addi	sp,sp,160
    80005da0:	8082                	ret
    end_op();
    80005da2:	b8bfe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005da6:	557d                	li	a0,-1
    80005da8:	bfcd                	j	80005d9a <sys_mknod+0x50>

0000000080005daa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005daa:	7135                	addi	sp,sp,-160
    80005dac:	ed06                	sd	ra,152(sp)
    80005dae:	e922                	sd	s0,144(sp)
    80005db0:	e526                	sd	s1,136(sp)
    80005db2:	e14a                	sd	s2,128(sp)
    80005db4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005db6:	e09fb0ef          	jal	ra,80001bbe <myproc>
    80005dba:	892a                	mv	s2,a0
  
  begin_op();
    80005dbc:	b01fe0ef          	jal	ra,800048bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005dc0:	08000613          	li	a2,128
    80005dc4:	f6040593          	addi	a1,s0,-160
    80005dc8:	4501                	li	a0,0
    80005dca:	85afd0ef          	jal	ra,80002e24 <argstr>
    80005dce:	04054163          	bltz	a0,80005e10 <sys_chdir+0x66>
    80005dd2:	f6040513          	addi	a0,s0,-160
    80005dd6:	8f7fe0ef          	jal	ra,800046cc <namei>
    80005dda:	84aa                	mv	s1,a0
    80005ddc:	c915                	beqz	a0,80005e10 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dde:	900fe0ef          	jal	ra,80003ede <ilock>
  if(ip->type != T_DIR){
    80005de2:	04449703          	lh	a4,68(s1)
    80005de6:	4785                	li	a5,1
    80005de8:	02f71863          	bne	a4,a5,80005e18 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005dec:	8526                	mv	a0,s1
    80005dee:	99afe0ef          	jal	ra,80003f88 <iunlock>
  iput(p->cwd);
    80005df2:	15093503          	ld	a0,336(s2)
    80005df6:	a66fe0ef          	jal	ra,8000405c <iput>
  end_op();
    80005dfa:	b33fe0ef          	jal	ra,8000492c <end_op>
  p->cwd = ip;
    80005dfe:	14993823          	sd	s1,336(s2)
  return 0;
    80005e02:	4501                	li	a0,0
}
    80005e04:	60ea                	ld	ra,152(sp)
    80005e06:	644a                	ld	s0,144(sp)
    80005e08:	64aa                	ld	s1,136(sp)
    80005e0a:	690a                	ld	s2,128(sp)
    80005e0c:	610d                	addi	sp,sp,160
    80005e0e:	8082                	ret
    end_op();
    80005e10:	b1dfe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005e14:	557d                	li	a0,-1
    80005e16:	b7fd                	j	80005e04 <sys_chdir+0x5a>
    iunlockput(ip);
    80005e18:	8526                	mv	a0,s1
    80005e1a:	acafe0ef          	jal	ra,800040e4 <iunlockput>
    end_op();
    80005e1e:	b0ffe0ef          	jal	ra,8000492c <end_op>
    return -1;
    80005e22:	557d                	li	a0,-1
    80005e24:	b7c5                	j	80005e04 <sys_chdir+0x5a>

0000000080005e26 <sys_exec>:

uint64
sys_exec(void)
{
    80005e26:	7145                	addi	sp,sp,-464
    80005e28:	e786                	sd	ra,456(sp)
    80005e2a:	e3a2                	sd	s0,448(sp)
    80005e2c:	ff26                	sd	s1,440(sp)
    80005e2e:	fb4a                	sd	s2,432(sp)
    80005e30:	f74e                	sd	s3,424(sp)
    80005e32:	f352                	sd	s4,416(sp)
    80005e34:	ef56                	sd	s5,408(sp)
    80005e36:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e38:	e3840593          	addi	a1,s0,-456
    80005e3c:	4505                	li	a0,1
    80005e3e:	fcbfc0ef          	jal	ra,80002e08 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e42:	08000613          	li	a2,128
    80005e46:	f4040593          	addi	a1,s0,-192
    80005e4a:	4501                	li	a0,0
    80005e4c:	fd9fc0ef          	jal	ra,80002e24 <argstr>
    80005e50:	87aa                	mv	a5,a0
    return -1;
    80005e52:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e54:	0a07c463          	bltz	a5,80005efc <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005e58:	10000613          	li	a2,256
    80005e5c:	4581                	li	a1,0
    80005e5e:	e4040513          	addi	a0,s0,-448
    80005e62:	f31fa0ef          	jal	ra,80000d92 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e66:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e6a:	89a6                	mv	s3,s1
    80005e6c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e6e:	02000a13          	li	s4,32
    80005e72:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e76:	00391793          	slli	a5,s2,0x3
    80005e7a:	e3040593          	addi	a1,s0,-464
    80005e7e:	e3843503          	ld	a0,-456(s0)
    80005e82:	953e                	add	a0,a0,a5
    80005e84:	edffc0ef          	jal	ra,80002d62 <fetchaddr>
    80005e88:	02054663          	bltz	a0,80005eb4 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005e8c:	e3043783          	ld	a5,-464(s0)
    80005e90:	cf8d                	beqz	a5,80005eca <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e92:	d29fa0ef          	jal	ra,80000bba <kalloc>
    80005e96:	85aa                	mv	a1,a0
    80005e98:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e9c:	cd01                	beqz	a0,80005eb4 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e9e:	6605                	lui	a2,0x1
    80005ea0:	e3043503          	ld	a0,-464(s0)
    80005ea4:	f09fc0ef          	jal	ra,80002dac <fetchstr>
    80005ea8:	00054663          	bltz	a0,80005eb4 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005eac:	0905                	addi	s2,s2,1
    80005eae:	09a1                	addi	s3,s3,8
    80005eb0:	fd4911e3          	bne	s2,s4,80005e72 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb4:	10048913          	addi	s2,s1,256
    80005eb8:	6088                	ld	a0,0(s1)
    80005eba:	c121                	beqz	a0,80005efa <sys_exec+0xd4>
    kfree(argv[i]);
    80005ebc:	bc3fa0ef          	jal	ra,80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ec0:	04a1                	addi	s1,s1,8
    80005ec2:	ff249be3          	bne	s1,s2,80005eb8 <sys_exec+0x92>
  return -1;
    80005ec6:	557d                	li	a0,-1
    80005ec8:	a815                	j	80005efc <sys_exec+0xd6>
      argv[i] = 0;
    80005eca:	0a8e                	slli	s5,s5,0x3
    80005ecc:	fc040793          	addi	a5,s0,-64
    80005ed0:	9abe                	add	s5,s5,a5
    80005ed2:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005ed6:	e4040593          	addi	a1,s0,-448
    80005eda:	f4040513          	addi	a0,s0,-192
    80005ede:	b98ff0ef          	jal	ra,80005276 <kexec>
    80005ee2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ee4:	10048993          	addi	s3,s1,256
    80005ee8:	6088                	ld	a0,0(s1)
    80005eea:	c511                	beqz	a0,80005ef6 <sys_exec+0xd0>
    kfree(argv[i]);
    80005eec:	b93fa0ef          	jal	ra,80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ef0:	04a1                	addi	s1,s1,8
    80005ef2:	ff349be3          	bne	s1,s3,80005ee8 <sys_exec+0xc2>
  return ret;
    80005ef6:	854a                	mv	a0,s2
    80005ef8:	a011                	j	80005efc <sys_exec+0xd6>
  return -1;
    80005efa:	557d                	li	a0,-1
}
    80005efc:	60be                	ld	ra,456(sp)
    80005efe:	641e                	ld	s0,448(sp)
    80005f00:	74fa                	ld	s1,440(sp)
    80005f02:	795a                	ld	s2,432(sp)
    80005f04:	79ba                	ld	s3,424(sp)
    80005f06:	7a1a                	ld	s4,416(sp)
    80005f08:	6afa                	ld	s5,408(sp)
    80005f0a:	6179                	addi	sp,sp,464
    80005f0c:	8082                	ret

0000000080005f0e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f0e:	7139                	addi	sp,sp,-64
    80005f10:	fc06                	sd	ra,56(sp)
    80005f12:	f822                	sd	s0,48(sp)
    80005f14:	f426                	sd	s1,40(sp)
    80005f16:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f18:	ca7fb0ef          	jal	ra,80001bbe <myproc>
    80005f1c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f1e:	fd840593          	addi	a1,s0,-40
    80005f22:	4501                	li	a0,0
    80005f24:	ee5fc0ef          	jal	ra,80002e08 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f28:	fc840593          	addi	a1,s0,-56
    80005f2c:	fd040513          	addi	a0,s0,-48
    80005f30:	866ff0ef          	jal	ra,80004f96 <pipealloc>
    return -1;
    80005f34:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f36:	0a054463          	bltz	a0,80005fde <sys_pipe+0xd0>
  fd0 = -1;
    80005f3a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f3e:	fd043503          	ld	a0,-48(s0)
    80005f42:	f42ff0ef          	jal	ra,80005684 <fdalloc>
    80005f46:	fca42223          	sw	a0,-60(s0)
    80005f4a:	08054163          	bltz	a0,80005fcc <sys_pipe+0xbe>
    80005f4e:	fc843503          	ld	a0,-56(s0)
    80005f52:	f32ff0ef          	jal	ra,80005684 <fdalloc>
    80005f56:	fca42023          	sw	a0,-64(s0)
    80005f5a:	06054063          	bltz	a0,80005fba <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f5e:	4691                	li	a3,4
    80005f60:	fc440613          	addi	a2,s0,-60
    80005f64:	fd843583          	ld	a1,-40(s0)
    80005f68:	68a8                	ld	a0,80(s1)
    80005f6a:	845fb0ef          	jal	ra,800017ae <copyout>
    80005f6e:	00054e63          	bltz	a0,80005f8a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f72:	4691                	li	a3,4
    80005f74:	fc040613          	addi	a2,s0,-64
    80005f78:	fd843583          	ld	a1,-40(s0)
    80005f7c:	0591                	addi	a1,a1,4
    80005f7e:	68a8                	ld	a0,80(s1)
    80005f80:	82ffb0ef          	jal	ra,800017ae <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f84:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f86:	04055c63          	bgez	a0,80005fde <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005f8a:	fc442783          	lw	a5,-60(s0)
    80005f8e:	07e9                	addi	a5,a5,26
    80005f90:	078e                	slli	a5,a5,0x3
    80005f92:	97a6                	add	a5,a5,s1
    80005f94:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f98:	fc042503          	lw	a0,-64(s0)
    80005f9c:	0569                	addi	a0,a0,26
    80005f9e:	050e                	slli	a0,a0,0x3
    80005fa0:	94aa                	add	s1,s1,a0
    80005fa2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fa6:	fd043503          	ld	a0,-48(s0)
    80005faa:	d21fe0ef          	jal	ra,80004cca <fileclose>
    fileclose(wf);
    80005fae:	fc843503          	ld	a0,-56(s0)
    80005fb2:	d19fe0ef          	jal	ra,80004cca <fileclose>
    return -1;
    80005fb6:	57fd                	li	a5,-1
    80005fb8:	a01d                	j	80005fde <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005fba:	fc442783          	lw	a5,-60(s0)
    80005fbe:	0007c763          	bltz	a5,80005fcc <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005fc2:	07e9                	addi	a5,a5,26
    80005fc4:	078e                	slli	a5,a5,0x3
    80005fc6:	94be                	add	s1,s1,a5
    80005fc8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fcc:	fd043503          	ld	a0,-48(s0)
    80005fd0:	cfbfe0ef          	jal	ra,80004cca <fileclose>
    fileclose(wf);
    80005fd4:	fc843503          	ld	a0,-56(s0)
    80005fd8:	cf3fe0ef          	jal	ra,80004cca <fileclose>
    return -1;
    80005fdc:	57fd                	li	a5,-1
}
    80005fde:	853e                	mv	a0,a5
    80005fe0:	70e2                	ld	ra,56(sp)
    80005fe2:	7442                	ld	s0,48(sp)
    80005fe4:	74a2                	ld	s1,40(sp)
    80005fe6:	6121                	addi	sp,sp,64
    80005fe8:	8082                	ret
    80005fea:	0000                	unimp
    80005fec:	0000                	unimp
	...

0000000080005ff0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005ff0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005ff2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005ff4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005ff6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005ff8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005ffa:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005ffc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005ffe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006000:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006002:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006004:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006006:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006008:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000600a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000600c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000600e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006010:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006012:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006014:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006016:	c5dfc0ef          	jal	ra,80002c72 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000601a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000601c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000601e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006020:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006022:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006024:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006026:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006028:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000602a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000602c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000602e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006030:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006032:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006034:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006036:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006038:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000603a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000603c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000603e:	10200073          	sret
	...

000000008000604e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000604e:	1141                	addi	sp,sp,-16
    80006050:	e422                	sd	s0,8(sp)
    80006052:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006054:	0c0007b7          	lui	a5,0xc000
    80006058:	4705                	li	a4,1
    8000605a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000605c:	c3d8                	sw	a4,4(a5)
}
    8000605e:	6422                	ld	s0,8(sp)
    80006060:	0141                	addi	sp,sp,16
    80006062:	8082                	ret

0000000080006064 <plicinithart>:

void
plicinithart(void)
{
    80006064:	1141                	addi	sp,sp,-16
    80006066:	e406                	sd	ra,8(sp)
    80006068:	e022                	sd	s0,0(sp)
    8000606a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000606c:	b27fb0ef          	jal	ra,80001b92 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006070:	0085171b          	slliw	a4,a0,0x8
    80006074:	0c0027b7          	lui	a5,0xc002
    80006078:	97ba                	add	a5,a5,a4
    8000607a:	40200713          	li	a4,1026
    8000607e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006082:	00d5151b          	slliw	a0,a0,0xd
    80006086:	0c2017b7          	lui	a5,0xc201
    8000608a:	953e                	add	a0,a0,a5
    8000608c:	00052023          	sw	zero,0(a0)
}
    80006090:	60a2                	ld	ra,8(sp)
    80006092:	6402                	ld	s0,0(sp)
    80006094:	0141                	addi	sp,sp,16
    80006096:	8082                	ret

0000000080006098 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006098:	1141                	addi	sp,sp,-16
    8000609a:	e406                	sd	ra,8(sp)
    8000609c:	e022                	sd	s0,0(sp)
    8000609e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060a0:	af3fb0ef          	jal	ra,80001b92 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060a4:	00d5179b          	slliw	a5,a0,0xd
    800060a8:	0c201537          	lui	a0,0xc201
    800060ac:	953e                	add	a0,a0,a5
  return irq;
}
    800060ae:	4148                	lw	a0,4(a0)
    800060b0:	60a2                	ld	ra,8(sp)
    800060b2:	6402                	ld	s0,0(sp)
    800060b4:	0141                	addi	sp,sp,16
    800060b6:	8082                	ret

00000000800060b8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060b8:	1101                	addi	sp,sp,-32
    800060ba:	ec06                	sd	ra,24(sp)
    800060bc:	e822                	sd	s0,16(sp)
    800060be:	e426                	sd	s1,8(sp)
    800060c0:	1000                	addi	s0,sp,32
    800060c2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060c4:	acffb0ef          	jal	ra,80001b92 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c8:	00d5151b          	slliw	a0,a0,0xd
    800060cc:	0c2017b7          	lui	a5,0xc201
    800060d0:	97aa                	add	a5,a5,a0
    800060d2:	c3c4                	sw	s1,4(a5)
}
    800060d4:	60e2                	ld	ra,24(sp)
    800060d6:	6442                	ld	s0,16(sp)
    800060d8:	64a2                	ld	s1,8(sp)
    800060da:	6105                	addi	sp,sp,32
    800060dc:	8082                	ret

00000000800060de <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060de:	1141                	addi	sp,sp,-16
    800060e0:	e406                	sd	ra,8(sp)
    800060e2:	e022                	sd	s0,0(sp)
    800060e4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060e6:	479d                	li	a5,7
    800060e8:	04a7ca63          	blt	a5,a0,8000613c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800060ec:	00246797          	auipc	a5,0x246
    800060f0:	9f478793          	addi	a5,a5,-1548 # 8024bae0 <disk>
    800060f4:	97aa                	add	a5,a5,a0
    800060f6:	0187c783          	lbu	a5,24(a5)
    800060fa:	e7b9                	bnez	a5,80006148 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060fc:	00451613          	slli	a2,a0,0x4
    80006100:	00246797          	auipc	a5,0x246
    80006104:	9e078793          	addi	a5,a5,-1568 # 8024bae0 <disk>
    80006108:	6394                	ld	a3,0(a5)
    8000610a:	96b2                	add	a3,a3,a2
    8000610c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006110:	6398                	ld	a4,0(a5)
    80006112:	9732                	add	a4,a4,a2
    80006114:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006118:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000611c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006120:	953e                	add	a0,a0,a5
    80006122:	4785                	li	a5,1
    80006124:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006128:	00246517          	auipc	a0,0x246
    8000612c:	9d050513          	addi	a0,a0,-1584 # 8024baf8 <disk+0x18>
    80006130:	bd2fc0ef          	jal	ra,80002502 <wakeup>
}
    80006134:	60a2                	ld	ra,8(sp)
    80006136:	6402                	ld	s0,0(sp)
    80006138:	0141                	addi	sp,sp,16
    8000613a:	8082                	ret
    panic("free_desc 1");
    8000613c:	00002517          	auipc	a0,0x2
    80006140:	62c50513          	addi	a0,a0,1580 # 80008768 <syscalls+0x370>
    80006144:	e46fa0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80006148:	00002517          	auipc	a0,0x2
    8000614c:	63050513          	addi	a0,a0,1584 # 80008778 <syscalls+0x380>
    80006150:	e3afa0ef          	jal	ra,8000078a <panic>

0000000080006154 <virtio_disk_init>:
{
    80006154:	1101                	addi	sp,sp,-32
    80006156:	ec06                	sd	ra,24(sp)
    80006158:	e822                	sd	s0,16(sp)
    8000615a:	e426                	sd	s1,8(sp)
    8000615c:	e04a                	sd	s2,0(sp)
    8000615e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006160:	00002597          	auipc	a1,0x2
    80006164:	62858593          	addi	a1,a1,1576 # 80008788 <syscalls+0x390>
    80006168:	00246517          	auipc	a0,0x246
    8000616c:	aa050513          	addi	a0,a0,-1376 # 8024bc08 <disk+0x128>
    80006170:	acffa0ef          	jal	ra,80000c3e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006174:	100017b7          	lui	a5,0x10001
    80006178:	4398                	lw	a4,0(a5)
    8000617a:	2701                	sext.w	a4,a4
    8000617c:	747277b7          	lui	a5,0x74727
    80006180:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006184:	14f71063          	bne	a4,a5,800062c4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006188:	100017b7          	lui	a5,0x10001
    8000618c:	43dc                	lw	a5,4(a5)
    8000618e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006190:	4709                	li	a4,2
    80006192:	12e79963          	bne	a5,a4,800062c4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006196:	100017b7          	lui	a5,0x10001
    8000619a:	479c                	lw	a5,8(a5)
    8000619c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000619e:	12e79363          	bne	a5,a4,800062c4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061a2:	100017b7          	lui	a5,0x10001
    800061a6:	47d8                	lw	a4,12(a5)
    800061a8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061aa:	554d47b7          	lui	a5,0x554d4
    800061ae:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061b2:	10f71963          	bne	a4,a5,800062c4 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061b6:	100017b7          	lui	a5,0x10001
    800061ba:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061be:	4705                	li	a4,1
    800061c0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c2:	470d                	li	a4,3
    800061c4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061c6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061c8:	c7ffe737          	lui	a4,0xc7ffe
    800061cc:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47daa55f>
    800061d0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061d2:	2701                	sext.w	a4,a4
    800061d4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d6:	472d                	li	a4,11
    800061d8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800061da:	5bbc                	lw	a5,112(a5)
    800061dc:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061e0:	8ba1                	andi	a5,a5,8
    800061e2:	0e078763          	beqz	a5,800062d0 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061e6:	100017b7          	lui	a5,0x10001
    800061ea:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061ee:	43fc                	lw	a5,68(a5)
    800061f0:	2781                	sext.w	a5,a5
    800061f2:	0e079563          	bnez	a5,800062dc <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061f6:	100017b7          	lui	a5,0x10001
    800061fa:	5bdc                	lw	a5,52(a5)
    800061fc:	2781                	sext.w	a5,a5
  if(max == 0)
    800061fe:	0e078563          	beqz	a5,800062e8 <virtio_disk_init+0x194>
  if(max < NUM)
    80006202:	471d                	li	a4,7
    80006204:	0ef77863          	bgeu	a4,a5,800062f4 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80006208:	9b3fa0ef          	jal	ra,80000bba <kalloc>
    8000620c:	00246497          	auipc	s1,0x246
    80006210:	8d448493          	addi	s1,s1,-1836 # 8024bae0 <disk>
    80006214:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006216:	9a5fa0ef          	jal	ra,80000bba <kalloc>
    8000621a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000621c:	99ffa0ef          	jal	ra,80000bba <kalloc>
    80006220:	87aa                	mv	a5,a0
    80006222:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006224:	6088                	ld	a0,0(s1)
    80006226:	cd69                	beqz	a0,80006300 <virtio_disk_init+0x1ac>
    80006228:	00246717          	auipc	a4,0x246
    8000622c:	8c073703          	ld	a4,-1856(a4) # 8024bae8 <disk+0x8>
    80006230:	cb61                	beqz	a4,80006300 <virtio_disk_init+0x1ac>
    80006232:	c7f9                	beqz	a5,80006300 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80006234:	6605                	lui	a2,0x1
    80006236:	4581                	li	a1,0
    80006238:	b5bfa0ef          	jal	ra,80000d92 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000623c:	00246497          	auipc	s1,0x246
    80006240:	8a448493          	addi	s1,s1,-1884 # 8024bae0 <disk>
    80006244:	6605                	lui	a2,0x1
    80006246:	4581                	li	a1,0
    80006248:	6488                	ld	a0,8(s1)
    8000624a:	b49fa0ef          	jal	ra,80000d92 <memset>
  memset(disk.used, 0, PGSIZE);
    8000624e:	6605                	lui	a2,0x1
    80006250:	4581                	li	a1,0
    80006252:	6888                	ld	a0,16(s1)
    80006254:	b3ffa0ef          	jal	ra,80000d92 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006258:	100017b7          	lui	a5,0x10001
    8000625c:	4721                	li	a4,8
    8000625e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006260:	4098                	lw	a4,0(s1)
    80006262:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006266:	40d8                	lw	a4,4(s1)
    80006268:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000626c:	6498                	ld	a4,8(s1)
    8000626e:	0007069b          	sext.w	a3,a4
    80006272:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006276:	9701                	srai	a4,a4,0x20
    80006278:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000627c:	6898                	ld	a4,16(s1)
    8000627e:	0007069b          	sext.w	a3,a4
    80006282:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006286:	9701                	srai	a4,a4,0x20
    80006288:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000628c:	4705                	li	a4,1
    8000628e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006290:	00e48c23          	sb	a4,24(s1)
    80006294:	00e48ca3          	sb	a4,25(s1)
    80006298:	00e48d23          	sb	a4,26(s1)
    8000629c:	00e48da3          	sb	a4,27(s1)
    800062a0:	00e48e23          	sb	a4,28(s1)
    800062a4:	00e48ea3          	sb	a4,29(s1)
    800062a8:	00e48f23          	sb	a4,30(s1)
    800062ac:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800062b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800062b4:	0727a823          	sw	s2,112(a5)
}
    800062b8:	60e2                	ld	ra,24(sp)
    800062ba:	6442                	ld	s0,16(sp)
    800062bc:	64a2                	ld	s1,8(sp)
    800062be:	6902                	ld	s2,0(sp)
    800062c0:	6105                	addi	sp,sp,32
    800062c2:	8082                	ret
    panic("could not find virtio disk");
    800062c4:	00002517          	auipc	a0,0x2
    800062c8:	4d450513          	addi	a0,a0,1236 # 80008798 <syscalls+0x3a0>
    800062cc:	cbefa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    800062d0:	00002517          	auipc	a0,0x2
    800062d4:	4e850513          	addi	a0,a0,1256 # 800087b8 <syscalls+0x3c0>
    800062d8:	cb2fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    800062dc:	00002517          	auipc	a0,0x2
    800062e0:	4fc50513          	addi	a0,a0,1276 # 800087d8 <syscalls+0x3e0>
    800062e4:	ca6fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    800062e8:	00002517          	auipc	a0,0x2
    800062ec:	51050513          	addi	a0,a0,1296 # 800087f8 <syscalls+0x400>
    800062f0:	c9afa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    800062f4:	00002517          	auipc	a0,0x2
    800062f8:	52450513          	addi	a0,a0,1316 # 80008818 <syscalls+0x420>
    800062fc:	c8efa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80006300:	00002517          	auipc	a0,0x2
    80006304:	53850513          	addi	a0,a0,1336 # 80008838 <syscalls+0x440>
    80006308:	c82fa0ef          	jal	ra,8000078a <panic>

000000008000630c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000630c:	7119                	addi	sp,sp,-128
    8000630e:	fc86                	sd	ra,120(sp)
    80006310:	f8a2                	sd	s0,112(sp)
    80006312:	f4a6                	sd	s1,104(sp)
    80006314:	f0ca                	sd	s2,96(sp)
    80006316:	ecce                	sd	s3,88(sp)
    80006318:	e8d2                	sd	s4,80(sp)
    8000631a:	e4d6                	sd	s5,72(sp)
    8000631c:	e0da                	sd	s6,64(sp)
    8000631e:	fc5e                	sd	s7,56(sp)
    80006320:	f862                	sd	s8,48(sp)
    80006322:	f466                	sd	s9,40(sp)
    80006324:	f06a                	sd	s10,32(sp)
    80006326:	ec6e                	sd	s11,24(sp)
    80006328:	0100                	addi	s0,sp,128
    8000632a:	8aaa                	mv	s5,a0
    8000632c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000632e:	00c52d03          	lw	s10,12(a0)
    80006332:	001d1d1b          	slliw	s10,s10,0x1
    80006336:	1d02                	slli	s10,s10,0x20
    80006338:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000633c:	00246517          	auipc	a0,0x246
    80006340:	8cc50513          	addi	a0,a0,-1844 # 8024bc08 <disk+0x128>
    80006344:	97bfa0ef          	jal	ra,80000cbe <acquire>
  for(int i = 0; i < 3; i++){
    80006348:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000634a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000634c:	00245b97          	auipc	s7,0x245
    80006350:	794b8b93          	addi	s7,s7,1940 # 8024bae0 <disk>
  for(int i = 0; i < 3; i++){
    80006354:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006356:	00246c97          	auipc	s9,0x246
    8000635a:	8b2c8c93          	addi	s9,s9,-1870 # 8024bc08 <disk+0x128>
    8000635e:	a8a9                	j	800063b8 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006360:	00fb8733          	add	a4,s7,a5
    80006364:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006368:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000636a:	0207c563          	bltz	a5,80006394 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000636e:	2905                	addiw	s2,s2,1
    80006370:	0611                	addi	a2,a2,4
    80006372:	05690863          	beq	s2,s6,800063c2 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006376:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006378:	00245717          	auipc	a4,0x245
    8000637c:	76870713          	addi	a4,a4,1896 # 8024bae0 <disk>
    80006380:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006382:	01874683          	lbu	a3,24(a4)
    80006386:	fee9                	bnez	a3,80006360 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006388:	2785                	addiw	a5,a5,1
    8000638a:	0705                	addi	a4,a4,1
    8000638c:	fe979be3          	bne	a5,s1,80006382 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006390:	57fd                	li	a5,-1
    80006392:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006394:	01205b63          	blez	s2,800063aa <virtio_disk_rw+0x9e>
    80006398:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000639a:	000a2503          	lw	a0,0(s4)
    8000639e:	d41ff0ef          	jal	ra,800060de <free_desc>
      for(int j = 0; j < i; j++)
    800063a2:	2d85                	addiw	s11,s11,1
    800063a4:	0a11                	addi	s4,s4,4
    800063a6:	ffb91ae3          	bne	s2,s11,8000639a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063aa:	85e6                	mv	a1,s9
    800063ac:	00245517          	auipc	a0,0x245
    800063b0:	74c50513          	addi	a0,a0,1868 # 8024baf8 <disk+0x18>
    800063b4:	902fc0ef          	jal	ra,800024b6 <sleep>
  for(int i = 0; i < 3; i++){
    800063b8:	f8040a13          	addi	s4,s0,-128
{
    800063bc:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800063be:	894e                	mv	s2,s3
    800063c0:	bf5d                	j	80006376 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063c2:	f8042583          	lw	a1,-128(s0)
    800063c6:	00a58793          	addi	a5,a1,10
    800063ca:	0792                	slli	a5,a5,0x4

  if(write)
    800063cc:	00245617          	auipc	a2,0x245
    800063d0:	71460613          	addi	a2,a2,1812 # 8024bae0 <disk>
    800063d4:	00f60733          	add	a4,a2,a5
    800063d8:	018036b3          	snez	a3,s8
    800063dc:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063de:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063e2:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063e6:	f6078693          	addi	a3,a5,-160
    800063ea:	6218                	ld	a4,0(a2)
    800063ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063ee:	00878513          	addi	a0,a5,8
    800063f2:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063f4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063f6:	6208                	ld	a0,0(a2)
    800063f8:	96aa                	add	a3,a3,a0
    800063fa:	4741                	li	a4,16
    800063fc:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063fe:	4705                	li	a4,1
    80006400:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006404:	f8442703          	lw	a4,-124(s0)
    80006408:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000640c:	0712                	slli	a4,a4,0x4
    8000640e:	953a                	add	a0,a0,a4
    80006410:	058a8693          	addi	a3,s5,88
    80006414:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80006416:	6208                	ld	a0,0(a2)
    80006418:	972a                	add	a4,a4,a0
    8000641a:	40000693          	li	a3,1024
    8000641e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006420:	001c3c13          	seqz	s8,s8
    80006424:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006426:	001c6c13          	ori	s8,s8,1
    8000642a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000642e:	f8842603          	lw	a2,-120(s0)
    80006432:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006436:	00245697          	auipc	a3,0x245
    8000643a:	6aa68693          	addi	a3,a3,1706 # 8024bae0 <disk>
    8000643e:	00258713          	addi	a4,a1,2
    80006442:	0712                	slli	a4,a4,0x4
    80006444:	9736                	add	a4,a4,a3
    80006446:	587d                	li	a6,-1
    80006448:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000644c:	0612                	slli	a2,a2,0x4
    8000644e:	9532                	add	a0,a0,a2
    80006450:	f9078793          	addi	a5,a5,-112
    80006454:	97b6                	add	a5,a5,a3
    80006456:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80006458:	629c                	ld	a5,0(a3)
    8000645a:	97b2                	add	a5,a5,a2
    8000645c:	4605                	li	a2,1
    8000645e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006460:	4509                	li	a0,2
    80006462:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80006466:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000646a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000646e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006472:	6698                	ld	a4,8(a3)
    80006474:	00275783          	lhu	a5,2(a4)
    80006478:	8b9d                	andi	a5,a5,7
    8000647a:	0786                	slli	a5,a5,0x1
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006482:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006486:	6698                	ld	a4,8(a3)
    80006488:	00275783          	lhu	a5,2(a4)
    8000648c:	2785                	addiw	a5,a5,1
    8000648e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006492:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006496:	100017b7          	lui	a5,0x10001
    8000649a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000649e:	004aa783          	lw	a5,4(s5)
    800064a2:	00c79f63          	bne	a5,a2,800064c0 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800064a6:	00245917          	auipc	s2,0x245
    800064aa:	76290913          	addi	s2,s2,1890 # 8024bc08 <disk+0x128>
  while(b->disk == 1) {
    800064ae:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800064b0:	85ca                	mv	a1,s2
    800064b2:	8556                	mv	a0,s5
    800064b4:	802fc0ef          	jal	ra,800024b6 <sleep>
  while(b->disk == 1) {
    800064b8:	004aa783          	lw	a5,4(s5)
    800064bc:	fe978ae3          	beq	a5,s1,800064b0 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800064c0:	f8042903          	lw	s2,-128(s0)
    800064c4:	00290793          	addi	a5,s2,2
    800064c8:	00479713          	slli	a4,a5,0x4
    800064cc:	00245797          	auipc	a5,0x245
    800064d0:	61478793          	addi	a5,a5,1556 # 8024bae0 <disk>
    800064d4:	97ba                	add	a5,a5,a4
    800064d6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064da:	00245997          	auipc	s3,0x245
    800064de:	60698993          	addi	s3,s3,1542 # 8024bae0 <disk>
    800064e2:	00491713          	slli	a4,s2,0x4
    800064e6:	0009b783          	ld	a5,0(s3)
    800064ea:	97ba                	add	a5,a5,a4
    800064ec:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064f0:	854a                	mv	a0,s2
    800064f2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064f6:	be9ff0ef          	jal	ra,800060de <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064fa:	8885                	andi	s1,s1,1
    800064fc:	f0fd                	bnez	s1,800064e2 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064fe:	00245517          	auipc	a0,0x245
    80006502:	70a50513          	addi	a0,a0,1802 # 8024bc08 <disk+0x128>
    80006506:	851fa0ef          	jal	ra,80000d56 <release>
}
    8000650a:	70e6                	ld	ra,120(sp)
    8000650c:	7446                	ld	s0,112(sp)
    8000650e:	74a6                	ld	s1,104(sp)
    80006510:	7906                	ld	s2,96(sp)
    80006512:	69e6                	ld	s3,88(sp)
    80006514:	6a46                	ld	s4,80(sp)
    80006516:	6aa6                	ld	s5,72(sp)
    80006518:	6b06                	ld	s6,64(sp)
    8000651a:	7be2                	ld	s7,56(sp)
    8000651c:	7c42                	ld	s8,48(sp)
    8000651e:	7ca2                	ld	s9,40(sp)
    80006520:	7d02                	ld	s10,32(sp)
    80006522:	6de2                	ld	s11,24(sp)
    80006524:	6109                	addi	sp,sp,128
    80006526:	8082                	ret

0000000080006528 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006528:	1101                	addi	sp,sp,-32
    8000652a:	ec06                	sd	ra,24(sp)
    8000652c:	e822                	sd	s0,16(sp)
    8000652e:	e426                	sd	s1,8(sp)
    80006530:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006532:	00245497          	auipc	s1,0x245
    80006536:	5ae48493          	addi	s1,s1,1454 # 8024bae0 <disk>
    8000653a:	00245517          	auipc	a0,0x245
    8000653e:	6ce50513          	addi	a0,a0,1742 # 8024bc08 <disk+0x128>
    80006542:	f7cfa0ef          	jal	ra,80000cbe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006546:	10001737          	lui	a4,0x10001
    8000654a:	533c                	lw	a5,96(a4)
    8000654c:	8b8d                	andi	a5,a5,3
    8000654e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006550:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006554:	689c                	ld	a5,16(s1)
    80006556:	0204d703          	lhu	a4,32(s1)
    8000655a:	0027d783          	lhu	a5,2(a5)
    8000655e:	04f70663          	beq	a4,a5,800065aa <virtio_disk_intr+0x82>
    __sync_synchronize();
    80006562:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006566:	6898                	ld	a4,16(s1)
    80006568:	0204d783          	lhu	a5,32(s1)
    8000656c:	8b9d                	andi	a5,a5,7
    8000656e:	078e                	slli	a5,a5,0x3
    80006570:	97ba                	add	a5,a5,a4
    80006572:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006574:	00278713          	addi	a4,a5,2
    80006578:	0712                	slli	a4,a4,0x4
    8000657a:	9726                	add	a4,a4,s1
    8000657c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006580:	e321                	bnez	a4,800065c0 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006582:	0789                	addi	a5,a5,2
    80006584:	0792                	slli	a5,a5,0x4
    80006586:	97a6                	add	a5,a5,s1
    80006588:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000658a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000658e:	f75fb0ef          	jal	ra,80002502 <wakeup>

    disk.used_idx += 1;
    80006592:	0204d783          	lhu	a5,32(s1)
    80006596:	2785                	addiw	a5,a5,1
    80006598:	17c2                	slli	a5,a5,0x30
    8000659a:	93c1                	srli	a5,a5,0x30
    8000659c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065a0:	6898                	ld	a4,16(s1)
    800065a2:	00275703          	lhu	a4,2(a4)
    800065a6:	faf71ee3          	bne	a4,a5,80006562 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800065aa:	00245517          	auipc	a0,0x245
    800065ae:	65e50513          	addi	a0,a0,1630 # 8024bc08 <disk+0x128>
    800065b2:	fa4fa0ef          	jal	ra,80000d56 <release>
}
    800065b6:	60e2                	ld	ra,24(sp)
    800065b8:	6442                	ld	s0,16(sp)
    800065ba:	64a2                	ld	s1,8(sp)
    800065bc:	6105                	addi	sp,sp,32
    800065be:	8082                	ret
      panic("virtio_disk_intr status");
    800065c0:	00002517          	auipc	a0,0x2
    800065c4:	29050513          	addi	a0,a0,656 # 80008850 <syscalls+0x458>
    800065c8:	9c2fa0ef          	jal	ra,8000078a <panic>

00000000800065cc <shm_init>:
 * 
 * 创建并初始化保护共享内存对象的自旋锁。
 */
void
shm_init(void)
{
    800065cc:	1141                	addi	sp,sp,-16
    800065ce:	e406                	sd	ra,8(sp)
    800065d0:	e022                	sd	s0,0(sp)
    800065d2:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    800065d4:	00002597          	auipc	a1,0x2
    800065d8:	29458593          	addi	a1,a1,660 # 80008868 <syscalls+0x470>
    800065dc:	00245517          	auipc	a0,0x245
    800065e0:	64450513          	addi	a0,a0,1604 # 8024bc20 <shmt>
    800065e4:	e5afa0ef          	jal	ra,80000c3e <initlock>
}
    800065e8:	60a2                	ld	ra,8(sp)
    800065ea:	6402                	ld	s0,0(sp)
    800065ec:	0141                	addi	sp,sp,16
    800065ee:	8082                	ret

00000000800065f0 <shm_get>:
 *   2. 如果找到且满足条件，增加引用计数并返回
 *   3. 如果没找到，创建一个新的共享内存对象
 */
int
shm_get(int key, int npages)
{
    800065f0:	7179                	addi	sp,sp,-48
    800065f2:	f406                	sd	ra,40(sp)
    800065f4:	f022                	sd	s0,32(sp)
    800065f6:	ec26                	sd	s1,24(sp)
    800065f8:	e84a                	sd	s2,16(sp)
    800065fa:	e44e                	sd	s3,8(sp)
    800065fc:	1800                	addi	s0,sp,48
    800065fe:	892a                	mv	s2,a0
    80006600:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    80006602:	00245517          	auipc	a0,0x245
    80006606:	61e50513          	addi	a0,a0,1566 # 8024bc20 <shmt>
    8000660a:	eb4fa0ef          	jal	ra,80000cbe <acquire>

  // 先查找已有的共享内存对象
  for(int i=0;i<NSHM;i++){
    8000660e:	00245697          	auipc	a3,0x245
    80006612:	62a68693          	addi	a3,a3,1578 # 8024bc38 <shmt+0x18>
  acquire(&shmt.lock);
    80006616:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    80006618:	4481                	li	s1,0
    8000661a:	6605                	lui	a2,0x1
    8000661c:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006620:	4841                	li	a6,16
    80006622:	a015                	j	80006646 <shm_get+0x56>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查对象是否已被标记删除
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
    80006624:	00245517          	auipc	a0,0x245
    80006628:	5fc50513          	addi	a0,a0,1532 # 8024bc20 <shmt>
    8000662c:	f2afa0ef          	jal	ra,80000d56 <release>
        return -1;
    80006630:	54fd                	li	s1,-1
    80006632:	a879                	j	800066d0 <shm_get+0xe0>
      }
      // 检查请求的页数是否超过对象的总页数
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    80006634:	853a                	mv	a0,a4
    80006636:	f20fa0ef          	jal	ra,80000d56 <release>
        return -1;
    8000663a:	54fd                	li	s1,-1
    8000663c:	a851                	j	800066d0 <shm_get+0xe0>
  for(int i=0;i<NSHM;i++){
    8000663e:	2485                	addiw	s1,s1,1
    80006640:	97b2                	add	a5,a5,a2
    80006642:	07048563          	beq	s1,a6,800066ac <shm_get+0xbc>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006646:	4398                	lw	a4,0(a5)
    80006648:	db7d                	beqz	a4,8000663e <shm_get+0x4e>
    8000664a:	43d8                	lw	a4,4(a5)
    8000664c:	ff2719e3          	bne	a4,s2,8000663e <shm_get+0x4e>
      if(shmt.obj[i].deleted){
    80006650:	6785                	lui	a5,0x1
    80006652:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006656:	02e486b3          	mul	a3,s1,a4
    8000665a:	00245717          	auipc	a4,0x245
    8000665e:	5c670713          	addi	a4,a4,1478 # 8024bc20 <shmt>
    80006662:	9736                	add	a4,a4,a3
    80006664:	97ba                	add	a5,a5,a4
    80006666:	82c7a783          	lw	a5,-2004(a5)
    8000666a:	ffcd                	bnez	a5,80006624 <shm_get+0x34>
      if(npages > shmt.obj[i].npages){
    8000666c:	6785                	lui	a5,0x1
    8000666e:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006672:	02f487b3          	mul	a5,s1,a5
    80006676:	00245717          	auipc	a4,0x245
    8000667a:	5aa70713          	addi	a4,a4,1450 # 8024bc20 <shmt>
    8000667e:	97ba                	add	a5,a5,a4
    80006680:	539c                	lw	a5,32(a5)
    80006682:	fb37c9e3          	blt	a5,s3,80006634 <shm_get+0x44>
      }
      // 增加引用计数
      shmt.obj[i].refcnt++;
    80006686:	00245517          	auipc	a0,0x245
    8000668a:	59a50513          	addi	a0,a0,1434 # 8024bc20 <shmt>
    8000668e:	6785                	lui	a5,0x1
    80006690:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006694:	02e48733          	mul	a4,s1,a4
    80006698:	972a                	add	a4,a4,a0
    8000669a:	97ba                	add	a5,a5,a4
    8000669c:	8287a703          	lw	a4,-2008(a5)
    800066a0:	2705                	addiw	a4,a4,1
    800066a2:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    800066a6:	eb0fa0ef          	jal	ra,80000d56 <release>
      return i;
    800066aa:	a01d                	j	800066d0 <shm_get+0xe0>
    }
  }

  // 如果没有找到，创建一个新的共享内存对象
  for(int i=0;i<NSHM;i++){
    800066ac:	4481                	li	s1,0
    800066ae:	6705                	lui	a4,0x1
    800066b0:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    800066b4:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    800066b6:	429c                	lw	a5,0(a3)
    800066b8:	c785                	beqz	a5,800066e0 <shm_get+0xf0>
  for(int i=0;i<NSHM;i++){
    800066ba:	2485                	addiw	s1,s1,1
    800066bc:	96ba                	add	a3,a3,a4
    800066be:	fec49ce3          	bne	s1,a2,800066b6 <shm_get+0xc6>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    800066c2:	00245517          	auipc	a0,0x245
    800066c6:	55e50513          	addi	a0,a0,1374 # 8024bc20 <shmt>
    800066ca:	e8cfa0ef          	jal	ra,80000d56 <release>
  return -1;  // 没有空闲的共享内存对象槽位
    800066ce:	54fd                	li	s1,-1
}
    800066d0:	8526                	mv	a0,s1
    800066d2:	70a2                	ld	ra,40(sp)
    800066d4:	7402                	ld	s0,32(sp)
    800066d6:	64e2                	ld	s1,24(sp)
    800066d8:	6942                	ld	s2,16(sp)
    800066da:	69a2                	ld	s3,8(sp)
    800066dc:	6145                	addi	sp,sp,48
    800066de:	8082                	ret
      shmt.obj[i].deleted = 0;
    800066e0:	00245617          	auipc	a2,0x245
    800066e4:	54060613          	addi	a2,a2,1344 # 8024bc20 <shmt>
    800066e8:	6785                	lui	a5,0x1
    800066ea:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800066ee:	02e486b3          	mul	a3,s1,a4
    800066f2:	00d60733          	add	a4,a2,a3
    800066f6:	97ba                	add	a5,a5,a4
    800066f8:	8207a623          	sw	zero,-2004(a5)
      shmt.obj[i].used = 1;
    800066fc:	4585                	li	a1,1
    800066fe:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    80006700:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    80006704:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    80006708:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    8000670c:	02868793          	addi	a5,a3,40
    80006710:	97b2                	add	a5,a5,a2
    80006712:	00246717          	auipc	a4,0x246
    80006716:	d3670713          	addi	a4,a4,-714 # 8024c448 <shmt+0x828>
    8000671a:	9736                	add	a4,a4,a3
    8000671c:	0007b023          	sd	zero,0(a5)
    80006720:	07a1                	addi	a5,a5,8
    80006722:	fee79de3          	bne	a5,a4,8000671c <shm_get+0x12c>
      release(&shmt.lock);
    80006726:	00245517          	auipc	a0,0x245
    8000672a:	4fa50513          	addi	a0,a0,1274 # 8024bc20 <shmt>
    8000672e:	e28fa0ef          	jal	ra,80000d56 <release>
      return i;
    80006732:	bf79                	j	800066d0 <shm_get+0xe0>

0000000080006734 <shm_put>:
 *   - 使用 kfree 释放物理页，kfree 会正确处理页的引用计数
 *   - 如果对象已被标记删除，当引用计数为 0 时也会被完全释放
 */
void
shm_put(int key)
{
    80006734:	7179                	addi	sp,sp,-48
    80006736:	f406                	sd	ra,40(sp)
    80006738:	f022                	sd	s0,32(sp)
    8000673a:	ec26                	sd	s1,24(sp)
    8000673c:	e84a                	sd	s2,16(sp)
    8000673e:	e44e                	sd	s3,8(sp)
    80006740:	e052                	sd	s4,0(sp)
    80006742:	1800                	addi	s0,sp,48
    80006744:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    80006746:	00245517          	auipc	a0,0x245
    8000674a:	4da50513          	addi	a0,a0,1242 # 8024bc20 <shmt>
    8000674e:	d70fa0ef          	jal	ra,80000cbe <acquire>
  for(int i=0;i<NSHM;i++){
    80006752:	00245797          	auipc	a5,0x245
    80006756:	4e678793          	addi	a5,a5,1254 # 8024bc38 <shmt+0x18>
    8000675a:	4481                	li	s1,0
    8000675c:	6685                	lui	a3,0x1
    8000675e:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006762:	4641                	li	a2,16
    80006764:	a0b5                	j	800067d0 <shm_put+0x9c>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查引用计数的有效性
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006766:	00002517          	auipc	a0,0x2
    8000676a:	10a50513          	addi	a0,a0,266 # 80008870 <syscalls+0x478>
    8000676e:	81cfa0ef          	jal	ra,8000078a <panic>
      shmt.obj[i].refcnt--;
      
      // 如果引用计数为 0，释放所有资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j=0;j<shmt.obj[i].npages;j++){
    80006772:	2985                	addiw	s3,s3,1
    80006774:	0921                	addi	s2,s2,8
    80006776:	020a2783          	lw	a5,32(s4)
    8000677a:	00f9da63          	bge	s3,a5,8000678e <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000677e:	00093503          	ld	a0,0(s2)
    80006782:	d965                	beqz	a0,80006772 <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    80006784:	afafa0ef          	jal	ra,80000a7e <kfree>
            shmt.obj[i].pa[j] = 0;
    80006788:	00093023          	sd	zero,0(s2)
    8000678c:	b7dd                	j	80006772 <shm_put+0x3e>
          }
        }
        // 重置对象状态
        shmt.obj[i].used = 0;
    8000678e:	6785                	lui	a5,0x1
    80006790:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006794:	02e484b3          	mul	s1,s1,a4
    80006798:	00245717          	auipc	a4,0x245
    8000679c:	48870713          	addi	a4,a4,1160 # 8024bc20 <shmt>
    800067a0:	94ba                	add	s1,s1,a4
    800067a2:	0004ac23          	sw	zero,24(s1)
        shmt.obj[i].deleted = 0;
    800067a6:	97a6                	add	a5,a5,s1
    800067a8:	8207a623          	sw	zero,-2004(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    800067ac:	00245517          	auipc	a0,0x245
    800067b0:	47450513          	addi	a0,a0,1140 # 8024bc20 <shmt>
    800067b4:	da2fa0ef          	jal	ra,80000d56 <release>
}
    800067b8:	70a2                	ld	ra,40(sp)
    800067ba:	7402                	ld	s0,32(sp)
    800067bc:	64e2                	ld	s1,24(sp)
    800067be:	6942                	ld	s2,16(sp)
    800067c0:	69a2                	ld	s3,8(sp)
    800067c2:	6a02                	ld	s4,0(sp)
    800067c4:	6145                	addi	sp,sp,48
    800067c6:	8082                	ret
  for(int i=0;i<NSHM;i++){
    800067c8:	2485                	addiw	s1,s1,1
    800067ca:	97b6                	add	a5,a5,a3
    800067cc:	fec480e3          	beq	s1,a2,800067ac <shm_put+0x78>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800067d0:	4398                	lw	a4,0(a5)
    800067d2:	db7d                	beqz	a4,800067c8 <shm_put+0x94>
    800067d4:	43d8                	lw	a4,4(a5)
    800067d6:	ff2719e3          	bne	a4,s2,800067c8 <shm_put+0x94>
      if(shmt.obj[i].refcnt < 1)
    800067da:	6785                	lui	a5,0x1
    800067dc:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800067e0:	02e486b3          	mul	a3,s1,a4
    800067e4:	00245717          	auipc	a4,0x245
    800067e8:	43c70713          	addi	a4,a4,1084 # 8024bc20 <shmt>
    800067ec:	9736                	add	a4,a4,a3
    800067ee:	97ba                	add	a5,a5,a4
    800067f0:	8287a783          	lw	a5,-2008(a5)
    800067f4:	f6f059e3          	blez	a5,80006766 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    800067f8:	37fd                	addiw	a5,a5,-1
    800067fa:	0007899b          	sext.w	s3,a5
    800067fe:	6705                	lui	a4,0x1
    80006800:	81870693          	addi	a3,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006804:	02d48633          	mul	a2,s1,a3
    80006808:	00245697          	auipc	a3,0x245
    8000680c:	41868693          	addi	a3,a3,1048 # 8024bc20 <shmt>
    80006810:	96b2                	add	a3,a3,a2
    80006812:	9736                	add	a4,a4,a3
    80006814:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    80006818:	f8099ae3          	bnez	s3,800067ac <shm_put+0x78>
        for(int j=0;j<shmt.obj[i].npages;j++){
    8000681c:	529c                	lw	a5,32(a3)
    8000681e:	f6f058e3          	blez	a5,8000678e <shm_put+0x5a>
    80006822:	00245797          	auipc	a5,0x245
    80006826:	42678793          	addi	a5,a5,1062 # 8024bc48 <shmt+0x28>
    8000682a:	00f60933          	add	s2,a2,a5
    8000682e:	8a36                	mv	s4,a3
    80006830:	b7b9                	j	8000677e <shm_put+0x4a>

0000000080006832 <shm_getpa>:
 *   3. 如果该页尚未分配，分配一个新的物理页并初始化为0
 *   4. 返回该页的物理地址
 */
uint64
shm_getpa(int key, int page_index)
{
    80006832:	7179                	addi	sp,sp,-48
    80006834:	f406                	sd	ra,40(sp)
    80006836:	f022                	sd	s0,32(sp)
    80006838:	ec26                	sd	s1,24(sp)
    8000683a:	e84a                	sd	s2,16(sp)
    8000683c:	e44e                	sd	s3,8(sp)
    8000683e:	e052                	sd	s4,0(sp)
    80006840:	1800                	addi	s0,sp,48
    80006842:	892a                	mv	s2,a0
    80006844:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    80006846:	00245517          	auipc	a0,0x245
    8000684a:	3da50513          	addi	a0,a0,986 # 8024bc20 <shmt>
    8000684e:	c70fa0ef          	jal	ra,80000cbe <acquire>

  for(int i=0;i<NSHM;i++){
    80006852:	00245797          	auipc	a5,0x245
    80006856:	3e678793          	addi	a5,a5,998 # 8024bc38 <shmt+0x18>
    8000685a:	4481                	li	s1,0
    8000685c:	6685                	lui	a3,0x1
    8000685e:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006862:	4641                	li	a2,16
    80006864:	a82d                	j	8000689e <shm_getpa+0x6c>
        break;
      }
      
      // 如果该页尚未分配，执行惰性分配
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    80006866:	b54fa0ef          	jal	ra,80000bba <kalloc>
    8000686a:	8a2a                	mv	s4,a0
        if(mem == 0){
    8000686c:	cd41                	beqz	a0,80006904 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        // 初始化新分配的物理页为0
        memset(mem, 0, PGSIZE);
    8000686e:	6605                	lui	a2,0x1
    80006870:	4581                	li	a1,0
    80006872:	d20fa0ef          	jal	ra,80000d92 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    80006876:	00649793          	slli	a5,s1,0x6
    8000687a:	97a6                	add	a5,a5,s1
    8000687c:	078a                	slli	a5,a5,0x2
    8000687e:	8f85                	sub	a5,a5,s1
    80006880:	97ce                	add	a5,a5,s3
    80006882:	0791                	addi	a5,a5,4
    80006884:	078e                	slli	a5,a5,0x3
    80006886:	00245717          	auipc	a4,0x245
    8000688a:	39a70713          	addi	a4,a4,922 # 8024bc20 <shmt>
    8000688e:	97ba                	add	a5,a5,a4
    80006890:	0147b423          	sd	s4,8(a5)
    80006894:	a0b9                	j	800068e2 <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    80006896:	2485                	addiw	s1,s1,1
    80006898:	97b6                	add	a5,a5,a3
    8000689a:	06c48463          	beq	s1,a2,80006902 <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000689e:	4398                	lw	a4,0(a5)
    800068a0:	db7d                	beqz	a4,80006896 <shm_getpa+0x64>
    800068a2:	43d8                	lw	a4,4(a5)
    800068a4:	ff2719e3          	bne	a4,s2,80006896 <shm_getpa+0x64>
        pa = 0;
    800068a8:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    800068aa:	0409cd63          	bltz	s3,80006904 <shm_getpa+0xd2>
    800068ae:	6785                	lui	a5,0x1
    800068b0:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800068b4:	02f487b3          	mul	a5,s1,a5
    800068b8:	00245717          	auipc	a4,0x245
    800068bc:	36870713          	addi	a4,a4,872 # 8024bc20 <shmt>
    800068c0:	97ba                	add	a5,a5,a4
    800068c2:	539c                	lw	a5,32(a5)
    800068c4:	04f9d063          	bge	s3,a5,80006904 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    800068c8:	00649793          	slli	a5,s1,0x6
    800068cc:	97a6                	add	a5,a5,s1
    800068ce:	078a                	slli	a5,a5,0x2
    800068d0:	8f85                	sub	a5,a5,s1
    800068d2:	97ce                	add	a5,a5,s3
    800068d4:	0791                	addi	a5,a5,4
    800068d6:	078e                	slli	a5,a5,0x3
    800068d8:	97ba                	add	a5,a5,a4
    800068da:	0087b903          	ld	s2,8(a5)
    800068de:	f80904e3          	beqz	s2,80006866 <shm_getpa+0x34>
      }
      
      pa = shmt.obj[i].pa[page_index];
    800068e2:	00649793          	slli	a5,s1,0x6
    800068e6:	97a6                	add	a5,a5,s1
    800068e8:	078a                	slli	a5,a5,0x2
    800068ea:	8f85                	sub	a5,a5,s1
    800068ec:	97ce                	add	a5,a5,s3
    800068ee:	0791                	addi	a5,a5,4
    800068f0:	078e                	slli	a5,a5,0x3
    800068f2:	00245717          	auipc	a4,0x245
    800068f6:	32e70713          	addi	a4,a4,814 # 8024bc20 <shmt>
    800068fa:	97ba                	add	a5,a5,a4
    800068fc:	0087b903          	ld	s2,8(a5)
      break;
    80006900:	a011                	j	80006904 <shm_getpa+0xd2>
  uint64 pa = 0;
    80006902:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    80006904:	00245517          	auipc	a0,0x245
    80006908:	31c50513          	addi	a0,a0,796 # 8024bc20 <shmt>
    8000690c:	c4afa0ef          	jal	ra,80000d56 <release>
  vmstats_inc_shm();  // 更新共享内存统计信息
    80006910:	4e4000ef          	jal	ra,80006df4 <vmstats_inc_shm>

  return pa;
}
    80006914:	854a                	mv	a0,s2
    80006916:	70a2                	ld	ra,40(sp)
    80006918:	7402                	ld	s0,32(sp)
    8000691a:	64e2                	ld	s1,24(sp)
    8000691c:	6942                	ld	s2,16(sp)
    8000691e:	69a2                	ld	s3,8(sp)
    80006920:	6a02                	ld	s4,0(sp)
    80006922:	6145                	addi	sp,sp,48
    80006924:	8082                	ret

0000000080006926 <shm_ctl>:
 */
int
shm_ctl(int key, int cmd)
{
  // 目前仅支持 IPC_RMID 命令
  if(cmd != IPC_RMID)
    80006926:	10059363          	bnez	a1,80006a2c <shm_ctl+0x106>
{
    8000692a:	7139                	addi	sp,sp,-64
    8000692c:	fc06                	sd	ra,56(sp)
    8000692e:	f822                	sd	s0,48(sp)
    80006930:	f426                	sd	s1,40(sp)
    80006932:	f04a                	sd	s2,32(sp)
    80006934:	ec4e                	sd	s3,24(sp)
    80006936:	e852                	sd	s4,16(sp)
    80006938:	e456                	sd	s5,8(sp)
    8000693a:	0080                	addi	s0,sp,64
    8000693c:	892a                	mv	s2,a0
    8000693e:	89ae                	mv	s3,a1
    return -1;

  acquire(&shmt.lock);
    80006940:	00245517          	auipc	a0,0x245
    80006944:	2e050513          	addi	a0,a0,736 # 8024bc20 <shmt>
    80006948:	b76fa0ef          	jal	ra,80000cbe <acquire>

  for(int i = 0; i < NSHM; i++){
    8000694c:	00245797          	auipc	a5,0x245
    80006950:	2ec78793          	addi	a5,a5,748 # 8024bc38 <shmt+0x18>
    80006954:	84ce                	mv	s1,s3
    80006956:	6685                	lui	a3,0x1
    80006958:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000695c:	4641                	li	a2,16
    8000695e:	a8b1                	j	800069ba <shm_ctl+0x94>
      // 如果当前没有任何进程引用，立即释放资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    80006960:	91efa0ef          	jal	ra,80000a7e <kfree>
            shmt.obj[i].pa[j] = 0;
    80006964:	00093023          	sd	zero,0(s2)
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006968:	2a05                	addiw	s4,s4,1
    8000696a:	0921                	addi	s2,s2,8
    8000696c:	020aa783          	lw	a5,32(s5)
    80006970:	00fa5663          	bge	s4,a5,8000697c <shm_ctl+0x56>
          if(shmt.obj[i].pa[j]){
    80006974:	00093503          	ld	a0,0(s2)
    80006978:	d965                	beqz	a0,80006968 <shm_ctl+0x42>
    8000697a:	b7dd                	j	80006960 <shm_ctl+0x3a>
          }
        }
        // 完全重置对象状态
        shmt.obj[i].used = 0;
    8000697c:	6705                	lui	a4,0x1
    8000697e:	81870793          	addi	a5,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006982:	02f484b3          	mul	s1,s1,a5
    80006986:	00245797          	auipc	a5,0x245
    8000698a:	29a78793          	addi	a5,a5,666 # 8024bc20 <shmt>
    8000698e:	94be                	add	s1,s1,a5
    80006990:	0004ac23          	sw	zero,24(s1)
        shmt.obj[i].deleted = 0;
    80006994:	9726                	add	a4,a4,s1
    80006996:	82072623          	sw	zero,-2004(a4)
        shmt.obj[i].key = 0;     
    8000699a:	0004ae23          	sw	zero,28(s1)
        shmt.obj[i].npages = 0;  
    8000699e:	0204a023          	sw	zero,32(s1)
      }

      release(&shmt.lock);
    800069a2:	00245517          	auipc	a0,0x245
    800069a6:	27e50513          	addi	a0,a0,638 # 8024bc20 <shmt>
    800069aa:	bacfa0ef          	jal	ra,80000d56 <release>
      return 0;
    800069ae:	854e                	mv	a0,s3
    800069b0:	a0ad                	j	80006a1a <shm_ctl+0xf4>
  for(int i = 0; i < NSHM; i++){
    800069b2:	2485                	addiw	s1,s1,1
    800069b4:	97b6                	add	a5,a5,a3
    800069b6:	04c48b63          	beq	s1,a2,80006a0c <shm_ctl+0xe6>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800069ba:	4398                	lw	a4,0(a5)
    800069bc:	db7d                	beqz	a4,800069b2 <shm_ctl+0x8c>
    800069be:	43d8                	lw	a4,4(a5)
    800069c0:	ff2719e3          	bne	a4,s2,800069b2 <shm_ctl+0x8c>
      shmt.obj[i].deleted = 1;
    800069c4:	6785                	lui	a5,0x1
    800069c6:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800069ca:	02e486b3          	mul	a3,s1,a4
    800069ce:	00245717          	auipc	a4,0x245
    800069d2:	25270713          	addi	a4,a4,594 # 8024bc20 <shmt>
    800069d6:	9736                	add	a4,a4,a3
    800069d8:	97ba                	add	a5,a5,a4
    800069da:	4705                	li	a4,1
    800069dc:	82e7a623          	sw	a4,-2004(a5)
      if(shmt.obj[i].refcnt == 0){
    800069e0:	8287aa03          	lw	s4,-2008(a5)
    800069e4:	fa0a1fe3          	bnez	s4,800069a2 <shm_ctl+0x7c>
        for(int j = 0; j < shmt.obj[i].npages; j++){
    800069e8:	00245717          	auipc	a4,0x245
    800069ec:	23870713          	addi	a4,a4,568 # 8024bc20 <shmt>
    800069f0:	00d707b3          	add	a5,a4,a3
    800069f4:	539c                	lw	a5,32(a5)
    800069f6:	f8f053e3          	blez	a5,8000697c <shm_ctl+0x56>
    800069fa:	00245797          	auipc	a5,0x245
    800069fe:	24e78793          	addi	a5,a5,590 # 8024bc48 <shmt+0x28>
    80006a02:	00f68933          	add	s2,a3,a5
    80006a06:	00d70ab3          	add	s5,a4,a3
    80006a0a:	b7ad                	j	80006974 <shm_ctl+0x4e>
    }
  }

  release(&shmt.lock);
    80006a0c:	00245517          	auipc	a0,0x245
    80006a10:	21450513          	addi	a0,a0,532 # 8024bc20 <shmt>
    80006a14:	b42fa0ef          	jal	ra,80000d56 <release>
  return -1; // key 对应的共享内存对象不存在
    80006a18:	557d                	li	a0,-1
}
    80006a1a:	70e2                	ld	ra,56(sp)
    80006a1c:	7442                	ld	s0,48(sp)
    80006a1e:	74a2                	ld	s1,40(sp)
    80006a20:	7902                	ld	s2,32(sp)
    80006a22:	69e2                	ld	s3,24(sp)
    80006a24:	6a42                	ld	s4,16(sp)
    80006a26:	6aa2                	ld	s5,8(sp)
    80006a28:	6121                	addi	sp,sp,64
    80006a2a:	8082                	ret
    return -1;
    80006a2c:	557d                	li	a0,-1
}
    80006a2e:	8082                	ret

0000000080006a30 <shm_is_deleted>:
 *   - 如果对象不存在，默认返回 0（允许创建新对象）
 *   - 用于在 shm_get 时检查是否可以创建或访问共享内存对象
 */
int
shm_is_deleted(int key)
{
    80006a30:	1101                	addi	sp,sp,-32
    80006a32:	ec06                	sd	ra,24(sp)
    80006a34:	e822                	sd	s0,16(sp)
    80006a36:	e426                	sd	s1,8(sp)
    80006a38:	1000                	addi	s0,sp,32
    80006a3a:	84aa                	mv	s1,a0
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
    80006a3c:	00245517          	auipc	a0,0x245
    80006a40:	1e450513          	addi	a0,a0,484 # 8024bc20 <shmt>
    80006a44:	a7afa0ef          	jal	ra,80000cbe <acquire>
  for(int i=0;i<NSHM;i++){
    80006a48:	00245797          	auipc	a5,0x245
    80006a4c:	1f078793          	addi	a5,a5,496 # 8024bc38 <shmt+0x18>
    80006a50:	4701                	li	a4,0
    80006a52:	6605                	lui	a2,0x1
    80006a54:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006a58:	45c1                	li	a1,16
    80006a5a:	a029                	j	80006a64 <shm_is_deleted+0x34>
    80006a5c:	2705                	addiw	a4,a4,1
    80006a5e:	97b2                	add	a5,a5,a2
    80006a60:	02b70563          	beq	a4,a1,80006a8a <shm_is_deleted+0x5a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006a64:	4394                	lw	a3,0(a5)
    80006a66:	dafd                	beqz	a3,80006a5c <shm_is_deleted+0x2c>
    80006a68:	43d4                	lw	a3,4(a5)
    80006a6a:	fe9699e3          	bne	a3,s1,80006a5c <shm_is_deleted+0x2c>
      del = shmt.obj[i].deleted;
    80006a6e:	6785                	lui	a5,0x1
    80006a70:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006a74:	02d70733          	mul	a4,a4,a3
    80006a78:	00245697          	auipc	a3,0x245
    80006a7c:	1a868693          	addi	a3,a3,424 # 8024bc20 <shmt>
    80006a80:	9736                	add	a4,a4,a3
    80006a82:	97ba                	add	a5,a5,a4
    80006a84:	82c7a483          	lw	s1,-2004(a5)
      break;
    80006a88:	a011                	j	80006a8c <shm_is_deleted+0x5c>
  int del = 0; // 默认0,不存在就允许创建
    80006a8a:	4481                	li	s1,0
    }
  }
  release(&shmt.lock);
    80006a8c:	00245517          	auipc	a0,0x245
    80006a90:	19450513          	addi	a0,a0,404 # 8024bc20 <shmt>
    80006a94:	ac2fa0ef          	jal	ra,80000d56 <release>
  //shm_dump(key);
  return del;
}
    80006a98:	8526                	mv	a0,s1
    80006a9a:	60e2                	ld	ra,24(sp)
    80006a9c:	6442                	ld	s0,16(sp)
    80006a9e:	64a2                	ld	s1,8(sp)
    80006aa0:	6105                	addi	sp,sp,32
    80006aa2:	8082                	ret

0000000080006aa4 <sem_lookup>:
}

// 找到 key 对应 sem；不存在返回 -1
static int
sem_lookup(int key)
{
    80006aa4:	1141                	addi	sp,sp,-16
    80006aa6:	e422                	sd	s0,8(sp)
    80006aa8:	0800                	addi	s0,sp,16
    80006aaa:	862a                	mv	a2,a0
  for(int i = 0; i < NSEM; i++){
    80006aac:	0024d797          	auipc	a5,0x24d
    80006ab0:	32478793          	addi	a5,a5,804 # 80253dd0 <semt+0x18>
    80006ab4:	4501                	li	a0,0
    80006ab6:	04000693          	li	a3,64
    80006aba:	a029                	j	80006ac4 <sem_lookup+0x20>
    80006abc:	2505                	addiw	a0,a0,1
    80006abe:	07c1                	addi	a5,a5,16
    80006ac0:	00d50a63          	beq	a0,a3,80006ad4 <sem_lookup+0x30>
    if(semt.s[i].used && semt.s[i].key == key)
    80006ac4:	4398                	lw	a4,0(a5)
    80006ac6:	db7d                	beqz	a4,80006abc <sem_lookup+0x18>
    80006ac8:	43d8                	lw	a4,4(a5)
    80006aca:	fec719e3          	bne	a4,a2,80006abc <sem_lookup+0x18>
      return i;
  }
  return -1;
}
    80006ace:	6422                	ld	s0,8(sp)
    80006ad0:	0141                	addi	sp,sp,16
    80006ad2:	8082                	ret
  return -1;
    80006ad4:	557d                	li	a0,-1
    80006ad6:	bfe5                	j	80006ace <sem_lookup+0x2a>

0000000080006ad8 <seminit>:
{
    80006ad8:	1141                	addi	sp,sp,-16
    80006ada:	e406                	sd	ra,8(sp)
    80006adc:	e022                	sd	s0,0(sp)
    80006ade:	0800                	addi	s0,sp,16
  initlock(&semt.lock, "semt");
    80006ae0:	00002597          	auipc	a1,0x2
    80006ae4:	da058593          	addi	a1,a1,-608 # 80008880 <syscalls+0x488>
    80006ae8:	0024d517          	auipc	a0,0x24d
    80006aec:	2d050513          	addi	a0,a0,720 # 80253db8 <semt>
    80006af0:	94efa0ef          	jal	ra,80000c3e <initlock>
}
    80006af4:	60a2                	ld	ra,8(sp)
    80006af6:	6402                	ld	s0,0(sp)
    80006af8:	0141                	addi	sp,sp,16
    80006afa:	8082                	ret

0000000080006afc <sem_open>:

// 创建或返回已有
int
sem_open(int key, int init)
{
    80006afc:	7179                	addi	sp,sp,-48
    80006afe:	f406                	sd	ra,40(sp)
    80006b00:	f022                	sd	s0,32(sp)
    80006b02:	ec26                	sd	s1,24(sp)
    80006b04:	e84a                	sd	s2,16(sp)
    80006b06:	e44e                	sd	s3,8(sp)
    80006b08:	1800                	addi	s0,sp,48
    80006b0a:	892a                	mv	s2,a0
    80006b0c:	89ae                	mv	s3,a1
  acquire(&semt.lock);
    80006b0e:	0024d517          	auipc	a0,0x24d
    80006b12:	2aa50513          	addi	a0,a0,682 # 80253db8 <semt>
    80006b16:	9a8fa0ef          	jal	ra,80000cbe <acquire>

  int idx = sem_lookup(key);
    80006b1a:	854a                	mv	a0,s2
    80006b1c:	f89ff0ef          	jal	ra,80006aa4 <sem_lookup>
  if(idx >= 0){
    80006b20:	0024d717          	auipc	a4,0x24d
    80006b24:	2b070713          	addi	a4,a4,688 # 80253dd0 <semt+0x18>
    release(&semt.lock);
    return 0;  // 已存在，直接成功
  }

  for(int i = 0; i < NSEM; i++){
    80006b28:	4781                	li	a5,0
    80006b2a:	04000693          	li	a3,64
  if(idx >= 0){
    80006b2e:	02055063          	bgez	a0,80006b4e <sem_open+0x52>
    if(!semt.s[i].used){
    80006b32:	4304                	lw	s1,0(a4)
    80006b34:	c48d                	beqz	s1,80006b5e <sem_open+0x62>
  for(int i = 0; i < NSEM; i++){
    80006b36:	2785                	addiw	a5,a5,1
    80006b38:	0741                	addi	a4,a4,16
    80006b3a:	fed79ce3          	bne	a5,a3,80006b32 <sem_open+0x36>
      release(&semt.lock);
      return 0;
    }
  }

  release(&semt.lock);
    80006b3e:	0024d517          	auipc	a0,0x24d
    80006b42:	27a50513          	addi	a0,a0,634 # 80253db8 <semt>
    80006b46:	a10fa0ef          	jal	ra,80000d56 <release>
  return -1;
    80006b4a:	54fd                	li	s1,-1
    80006b4c:	a815                	j	80006b80 <sem_open+0x84>
    release(&semt.lock);
    80006b4e:	0024d517          	auipc	a0,0x24d
    80006b52:	26a50513          	addi	a0,a0,618 # 80253db8 <semt>
    80006b56:	a00fa0ef          	jal	ra,80000d56 <release>
    return 0;  // 已存在，直接成功
    80006b5a:	4481                	li	s1,0
    80006b5c:	a015                	j	80006b80 <sem_open+0x84>
      semt.s[i].used = 1;
    80006b5e:	0024d517          	auipc	a0,0x24d
    80006b62:	25a50513          	addi	a0,a0,602 # 80253db8 <semt>
    80006b66:	0785                	addi	a5,a5,1
    80006b68:	0792                	slli	a5,a5,0x4
    80006b6a:	97aa                	add	a5,a5,a0
    80006b6c:	4705                	li	a4,1
    80006b6e:	c798                	sw	a4,8(a5)
      semt.s[i].key = key;
    80006b70:	0127a623          	sw	s2,12(a5)
      semt.s[i].val = init;
    80006b74:	0137a823          	sw	s3,16(a5)
      semt.s[i].waiters = 0;
    80006b78:	0007aa23          	sw	zero,20(a5)
      release(&semt.lock);
    80006b7c:	9dafa0ef          	jal	ra,80000d56 <release>
}
    80006b80:	8526                	mv	a0,s1
    80006b82:	70a2                	ld	ra,40(sp)
    80006b84:	7402                	ld	s0,32(sp)
    80006b86:	64e2                	ld	s1,24(sp)
    80006b88:	6942                	ld	s2,16(sp)
    80006b8a:	69a2                	ld	s3,8(sp)
    80006b8c:	6145                	addi	sp,sp,48
    80006b8e:	8082                	ret

0000000080006b90 <sem_wait>:

int
sem_wait(int key)
{
    80006b90:	7179                	addi	sp,sp,-48
    80006b92:	f406                	sd	ra,40(sp)
    80006b94:	f022                	sd	s0,32(sp)
    80006b96:	ec26                	sd	s1,24(sp)
    80006b98:	e84a                	sd	s2,16(sp)
    80006b9a:	e44e                	sd	s3,8(sp)
    80006b9c:	e052                	sd	s4,0(sp)
    80006b9e:	1800                	addi	s0,sp,48
    80006ba0:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006ba2:	0024d517          	auipc	a0,0x24d
    80006ba6:	21650513          	addi	a0,a0,534 # 80253db8 <semt>
    80006baa:	914fa0ef          	jal	ra,80000cbe <acquire>

  int idx = sem_lookup(key);
    80006bae:	8526                	mv	a0,s1
    80006bb0:	ef5ff0ef          	jal	ra,80006aa4 <sem_lookup>
  if(idx < 0){
    80006bb4:	06054e63          	bltz	a0,80006c30 <sem_wait+0xa0>
    80006bb8:	892a                	mv	s2,a0
    release(&semt.lock);
    return -1;
  }

  // while(val==0) sleep
  while(semt.s[idx].val == 0){
    80006bba:	00150793          	addi	a5,a0,1
    80006bbe:	00479713          	slli	a4,a5,0x4
    80006bc2:	0024d797          	auipc	a5,0x24d
    80006bc6:	1f678793          	addi	a5,a5,502 # 80253db8 <semt>
    80006bca:	97ba                	add	a5,a5,a4
    80006bcc:	4b9c                	lw	a5,16(a5)
    80006bce:	ef85                	bnez	a5,80006c06 <sem_wait+0x76>
    semt.s[idx].waiters++;
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006bd0:	00451993          	slli	s3,a0,0x4
    80006bd4:	0024d797          	auipc	a5,0x24d
    80006bd8:	1fc78793          	addi	a5,a5,508 # 80253dd0 <semt+0x18>
    80006bdc:	99be                	add	s3,s3,a5
    semt.s[idx].waiters++;
    80006bde:	0024da17          	auipc	s4,0x24d
    80006be2:	1daa0a13          	addi	s4,s4,474 # 80253db8 <semt>
    80006be6:	00150493          	addi	s1,a0,1
    80006bea:	0492                	slli	s1,s1,0x4
    80006bec:	94d2                	add	s1,s1,s4
    80006bee:	48dc                	lw	a5,20(s1)
    80006bf0:	2785                	addiw	a5,a5,1
    80006bf2:	c8dc                	sw	a5,20(s1)
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006bf4:	85d2                	mv	a1,s4
    80006bf6:	854e                	mv	a0,s3
    80006bf8:	8bffb0ef          	jal	ra,800024b6 <sleep>
    semt.s[idx].waiters--;
    80006bfc:	48dc                	lw	a5,20(s1)
    80006bfe:	37fd                	addiw	a5,a5,-1
    80006c00:	c8dc                	sw	a5,20(s1)
  while(semt.s[idx].val == 0){
    80006c02:	489c                	lw	a5,16(s1)
    80006c04:	d7ed                	beqz	a5,80006bee <sem_wait+0x5e>
  }

  semt.s[idx].val--;
    80006c06:	0024d517          	auipc	a0,0x24d
    80006c0a:	1b250513          	addi	a0,a0,434 # 80253db8 <semt>
    80006c0e:	0905                	addi	s2,s2,1
    80006c10:	0912                	slli	s2,s2,0x4
    80006c12:	992a                	add	s2,s2,a0
    80006c14:	37fd                	addiw	a5,a5,-1
    80006c16:	00f92823          	sw	a5,16(s2)
  release(&semt.lock);
    80006c1a:	93cfa0ef          	jal	ra,80000d56 <release>
  return 0;
    80006c1e:	4501                	li	a0,0
}
    80006c20:	70a2                	ld	ra,40(sp)
    80006c22:	7402                	ld	s0,32(sp)
    80006c24:	64e2                	ld	s1,24(sp)
    80006c26:	6942                	ld	s2,16(sp)
    80006c28:	69a2                	ld	s3,8(sp)
    80006c2a:	6a02                	ld	s4,0(sp)
    80006c2c:	6145                	addi	sp,sp,48
    80006c2e:	8082                	ret
    release(&semt.lock);
    80006c30:	0024d517          	auipc	a0,0x24d
    80006c34:	18850513          	addi	a0,a0,392 # 80253db8 <semt>
    80006c38:	91efa0ef          	jal	ra,80000d56 <release>
    return -1;
    80006c3c:	557d                	li	a0,-1
    80006c3e:	b7cd                	j	80006c20 <sem_wait+0x90>

0000000080006c40 <sem_post>:

int
sem_post(int key)
{
    80006c40:	1101                	addi	sp,sp,-32
    80006c42:	ec06                	sd	ra,24(sp)
    80006c44:	e822                	sd	s0,16(sp)
    80006c46:	e426                	sd	s1,8(sp)
    80006c48:	1000                	addi	s0,sp,32
    80006c4a:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006c4c:	0024d517          	auipc	a0,0x24d
    80006c50:	16c50513          	addi	a0,a0,364 # 80253db8 <semt>
    80006c54:	86afa0ef          	jal	ra,80000cbe <acquire>

  int idx = sem_lookup(key);
    80006c58:	8526                	mv	a0,s1
    80006c5a:	e4bff0ef          	jal	ra,80006aa4 <sem_lookup>
  if(idx < 0){
    80006c5e:	02054a63          	bltz	a0,80006c92 <sem_post+0x52>
    release(&semt.lock);
    return -1;
  }

  semt.s[idx].val++;
    80006c62:	0024d497          	auipc	s1,0x24d
    80006c66:	15648493          	addi	s1,s1,342 # 80253db8 <semt>
    80006c6a:	0505                	addi	a0,a0,1
    80006c6c:	0512                	slli	a0,a0,0x4
    80006c6e:	00a48733          	add	a4,s1,a0
    80006c72:	4b1c                	lw	a5,16(a4)
    80006c74:	2785                	addiw	a5,a5,1
    80006c76:	cb1c                	sw	a5,16(a4)

  // 唤醒一个或全部：先做全部更简单也正确
  wakeup(&semt.s[idx]);
    80006c78:	0521                	addi	a0,a0,8
    80006c7a:	9526                	add	a0,a0,s1
    80006c7c:	887fb0ef          	jal	ra,80002502 <wakeup>

  release(&semt.lock);
    80006c80:	8526                	mv	a0,s1
    80006c82:	8d4fa0ef          	jal	ra,80000d56 <release>
  return 0;
    80006c86:	4501                	li	a0,0
}
    80006c88:	60e2                	ld	ra,24(sp)
    80006c8a:	6442                	ld	s0,16(sp)
    80006c8c:	64a2                	ld	s1,8(sp)
    80006c8e:	6105                	addi	sp,sp,32
    80006c90:	8082                	ret
    release(&semt.lock);
    80006c92:	0024d517          	auipc	a0,0x24d
    80006c96:	12650513          	addi	a0,a0,294 # 80253db8 <semt>
    80006c9a:	8bcfa0ef          	jal	ra,80000d56 <release>
    return -1;
    80006c9e:	557d                	li	a0,-1
    80006ca0:	b7e5                	j	80006c88 <sem_post+0x48>

0000000080006ca2 <sys_sem_open>:
#include "defs.h"


uint64
sys_sem_open(void)
{
    80006ca2:	1101                	addi	sp,sp,-32
    80006ca4:	ec06                	sd	ra,24(sp)
    80006ca6:	e822                	sd	s0,16(sp)
    80006ca8:	1000                	addi	s0,sp,32
  int key, init;
  argint(0, &key);
    80006caa:	fec40593          	addi	a1,s0,-20
    80006cae:	4501                	li	a0,0
    80006cb0:	93cfc0ef          	jal	ra,80002dec <argint>
  argint(1, &init);
    80006cb4:	fe840593          	addi	a1,s0,-24
    80006cb8:	4505                	li	a0,1
    80006cba:	932fc0ef          	jal	ra,80002dec <argint>
  return sem_open(key, init);
    80006cbe:	fe842583          	lw	a1,-24(s0)
    80006cc2:	fec42503          	lw	a0,-20(s0)
    80006cc6:	e37ff0ef          	jal	ra,80006afc <sem_open>
}
    80006cca:	60e2                	ld	ra,24(sp)
    80006ccc:	6442                	ld	s0,16(sp)
    80006cce:	6105                	addi	sp,sp,32
    80006cd0:	8082                	ret

0000000080006cd2 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80006cd2:	1101                	addi	sp,sp,-32
    80006cd4:	ec06                	sd	ra,24(sp)
    80006cd6:	e822                	sd	s0,16(sp)
    80006cd8:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006cda:	fec40593          	addi	a1,s0,-20
    80006cde:	4501                	li	a0,0
    80006ce0:	90cfc0ef          	jal	ra,80002dec <argint>
  return sem_wait(key);
    80006ce4:	fec42503          	lw	a0,-20(s0)
    80006ce8:	ea9ff0ef          	jal	ra,80006b90 <sem_wait>
}
    80006cec:	60e2                	ld	ra,24(sp)
    80006cee:	6442                	ld	s0,16(sp)
    80006cf0:	6105                	addi	sp,sp,32
    80006cf2:	8082                	ret

0000000080006cf4 <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80006cf4:	1101                	addi	sp,sp,-32
    80006cf6:	ec06                	sd	ra,24(sp)
    80006cf8:	e822                	sd	s0,16(sp)
    80006cfa:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006cfc:	fec40593          	addi	a1,s0,-20
    80006d00:	4501                	li	a0,0
    80006d02:	8eafc0ef          	jal	ra,80002dec <argint>
  return sem_post(key);
    80006d06:	fec42503          	lw	a0,-20(s0)
    80006d0a:	f37ff0ef          	jal	ra,80006c40 <sem_post>
}
    80006d0e:	60e2                	ld	ra,24(sp)
    80006d10:	6442                	ld	s0,16(sp)
    80006d12:	6105                	addi	sp,sp,32
    80006d14:	8082                	ret

0000000080006d16 <vmstatsinit>:
  uint64 shm_faults;
} vmstats;

void
vmstatsinit(void)
{
    80006d16:	1141                	addi	sp,sp,-16
    80006d18:	e406                	sd	ra,8(sp)
    80006d1a:	e022                	sd	s0,0(sp)
    80006d1c:	0800                	addi	s0,sp,16
  initlock(&vmstats.lock, "vmstats");
    80006d1e:	00002597          	auipc	a1,0x2
    80006d22:	b6a58593          	addi	a1,a1,-1174 # 80008888 <syscalls+0x490>
    80006d26:	0024d517          	auipc	a0,0x24d
    80006d2a:	4aa50513          	addi	a0,a0,1194 # 802541d0 <vmstats>
    80006d2e:	f11f90ef          	jal	ra,80000c3e <initlock>
}
    80006d32:	60a2                	ld	ra,8(sp)
    80006d34:	6402                	ld	s0,0(sp)
    80006d36:	0141                	addi	sp,sp,16
    80006d38:	8082                	ret

0000000080006d3a <vmstats_snapshot>:

// 给 sys_vmstats 用：读出一份快照
void
vmstats_snapshot(struct vmstats_user *out)
{
    80006d3a:	1101                	addi	sp,sp,-32
    80006d3c:	ec06                	sd	ra,24(sp)
    80006d3e:	e822                	sd	s0,16(sp)
    80006d40:	e426                	sd	s1,8(sp)
    80006d42:	e04a                	sd	s2,0(sp)
    80006d44:	1000                	addi	s0,sp,32
    80006d46:	84aa                	mv	s1,a0
  acquire(&vmstats.lock);
    80006d48:	0024d917          	auipc	s2,0x24d
    80006d4c:	48890913          	addi	s2,s2,1160 # 802541d0 <vmstats>
    80006d50:	854a                	mv	a0,s2
    80006d52:	f6df90ef          	jal	ra,80000cbe <acquire>
  out->cow_faults  = vmstats.cow_faults;
    80006d56:	01893783          	ld	a5,24(s2)
    80006d5a:	e09c                	sd	a5,0(s1)
  out->lazy_faults = vmstats.lazy_faults;
    80006d5c:	02093783          	ld	a5,32(s2)
    80006d60:	e49c                	sd	a5,8(s1)
  out->shm_faults  = vmstats.shm_faults;
    80006d62:	02893783          	ld	a5,40(s2)
    80006d66:	e89c                	sd	a5,16(s1)
  release(&vmstats.lock);
    80006d68:	854a                	mv	a0,s2
    80006d6a:	fedf90ef          	jal	ra,80000d56 <release>

  out->kalloc_cnt = kalloc_cnt;
    80006d6e:	00002797          	auipc	a5,0x2
    80006d72:	b8a7b783          	ld	a5,-1142(a5) # 800088f8 <kalloc_cnt>
    80006d76:	ec9c                	sd	a5,24(s1)
  out->copyin_bytes = copyin_bytes;
    80006d78:	00002797          	auipc	a5,0x2
    80006d7c:	b787b783          	ld	a5,-1160(a5) # 800088f0 <copyin_bytes>
    80006d80:	f09c                	sd	a5,32(s1)
  out->copyout_bytes = copyout_bytes;
    80006d82:	00002797          	auipc	a5,0x2
    80006d86:	b667b783          	ld	a5,-1178(a5) # 800088e8 <copyout_bytes>
    80006d8a:	f49c                	sd	a5,40(s1)
}
    80006d8c:	60e2                	ld	ra,24(sp)
    80006d8e:	6442                	ld	s0,16(sp)
    80006d90:	64a2                	ld	s1,8(sp)
    80006d92:	6902                	ld	s2,0(sp)
    80006d94:	6105                	addi	sp,sp,32
    80006d96:	8082                	ret

0000000080006d98 <vmstats_inc_cow>:




// 给其他模块做计数：不追求绝对精确可以不加锁
void vmstats_inc_cow(void)  { acquire(&vmstats.lock); vmstats.cow_faults++;  release(&vmstats.lock); }
    80006d98:	1101                	addi	sp,sp,-32
    80006d9a:	ec06                	sd	ra,24(sp)
    80006d9c:	e822                	sd	s0,16(sp)
    80006d9e:	e426                	sd	s1,8(sp)
    80006da0:	1000                	addi	s0,sp,32
    80006da2:	0024d497          	auipc	s1,0x24d
    80006da6:	42e48493          	addi	s1,s1,1070 # 802541d0 <vmstats>
    80006daa:	8526                	mv	a0,s1
    80006dac:	f13f90ef          	jal	ra,80000cbe <acquire>
    80006db0:	6c9c                	ld	a5,24(s1)
    80006db2:	0785                	addi	a5,a5,1
    80006db4:	ec9c                	sd	a5,24(s1)
    80006db6:	8526                	mv	a0,s1
    80006db8:	f9ff90ef          	jal	ra,80000d56 <release>
    80006dbc:	60e2                	ld	ra,24(sp)
    80006dbe:	6442                	ld	s0,16(sp)
    80006dc0:	64a2                	ld	s1,8(sp)
    80006dc2:	6105                	addi	sp,sp,32
    80006dc4:	8082                	ret

0000000080006dc6 <vmstats_inc_lazy>:
void vmstats_inc_lazy(void) { acquire(&vmstats.lock); vmstats.lazy_faults++; release(&vmstats.lock); }
    80006dc6:	1101                	addi	sp,sp,-32
    80006dc8:	ec06                	sd	ra,24(sp)
    80006dca:	e822                	sd	s0,16(sp)
    80006dcc:	e426                	sd	s1,8(sp)
    80006dce:	1000                	addi	s0,sp,32
    80006dd0:	0024d497          	auipc	s1,0x24d
    80006dd4:	40048493          	addi	s1,s1,1024 # 802541d0 <vmstats>
    80006dd8:	8526                	mv	a0,s1
    80006dda:	ee5f90ef          	jal	ra,80000cbe <acquire>
    80006dde:	709c                	ld	a5,32(s1)
    80006de0:	0785                	addi	a5,a5,1
    80006de2:	f09c                	sd	a5,32(s1)
    80006de4:	8526                	mv	a0,s1
    80006de6:	f71f90ef          	jal	ra,80000d56 <release>
    80006dea:	60e2                	ld	ra,24(sp)
    80006dec:	6442                	ld	s0,16(sp)
    80006dee:	64a2                	ld	s1,8(sp)
    80006df0:	6105                	addi	sp,sp,32
    80006df2:	8082                	ret

0000000080006df4 <vmstats_inc_shm>:
void vmstats_inc_shm(void)  { acquire(&vmstats.lock); vmstats.shm_faults++;  release(&vmstats.lock); }
    80006df4:	1101                	addi	sp,sp,-32
    80006df6:	ec06                	sd	ra,24(sp)
    80006df8:	e822                	sd	s0,16(sp)
    80006dfa:	e426                	sd	s1,8(sp)
    80006dfc:	1000                	addi	s0,sp,32
    80006dfe:	0024d497          	auipc	s1,0x24d
    80006e02:	3d248493          	addi	s1,s1,978 # 802541d0 <vmstats>
    80006e06:	8526                	mv	a0,s1
    80006e08:	eb7f90ef          	jal	ra,80000cbe <acquire>
    80006e0c:	749c                	ld	a5,40(s1)
    80006e0e:	0785                	addi	a5,a5,1
    80006e10:	f49c                	sd	a5,40(s1)
    80006e12:	8526                	mv	a0,s1
    80006e14:	f43f90ef          	jal	ra,80000d56 <release>
    80006e18:	60e2                	ld	ra,24(sp)
    80006e1a:	6442                	ld	s0,16(sp)
    80006e1c:	64a2                	ld	s1,8(sp)
    80006e1e:	6105                	addi	sp,sp,32
    80006e20:	8082                	ret
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
