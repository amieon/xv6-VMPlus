
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
    80000004:	83813103          	ld	sp,-1992(sp) # 80007838 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc77>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d6078793          	addi	a5,a5,-672 # 80000de0 <main>
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
    8000010a:	0a6020ef          	jal	ra,800021b0 <either_copyin>
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
    80000176:	70e50513          	addi	a0,a0,1806 # 8000f880 <cons>
    8000017a:	1f1000ef          	jal	ra,80000b6a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	70248493          	addi	s1,s1,1794 # 8000f880 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	0000f917          	auipc	s2,0xf
    8000018a:	79290913          	addi	s2,s2,1938 # 8000f918 <cons+0x98>
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
    800001a4:	65e010ef          	jal	ra,80001802 <myproc>
    800001a8:	69b010ef          	jal	ra,80002042 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	459010ef          	jal	ra,80001e0a <sleep>
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
    800001ea:	77d010ef          	jal	ra,80002166 <either_copyout>
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
    800001fe:	68650513          	addi	a0,a0,1670 # 8000f880 <cons>
    80000202:	201000ef          	jal	ra,80000c02 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	67450513          	addi	a0,a0,1652 # 8000f880 <cons>
    80000214:	1ef000ef          	jal	ra,80000c02 <release>
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
    80000242:	6cf72d23          	sw	a5,1754(a4) # 8000f918 <cons+0x98>
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
    8000028c:	5f850513          	addi	a0,a0,1528 # 8000f880 <cons>
    80000290:	0db000ef          	jal	ra,80000b6a <acquire>

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
    800002aa:	751010ef          	jal	ra,800021fa <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	5d250513          	addi	a0,a0,1490 # 8000f880 <cons>
    800002b6:	14d000ef          	jal	ra,80000c02 <release>
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
    800002d2:	5b270713          	addi	a4,a4,1458 # 8000f880 <cons>
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
    800002f8:	58c78793          	addi	a5,a5,1420 # 8000f880 <cons>
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
    80000326:	5f67a783          	lw	a5,1526(a5) # 8000f918 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	54a70713          	addi	a4,a4,1354 # 8000f880 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	53a48493          	addi	s1,s1,1338 # 8000f880 <cons>
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
    80000382:	50270713          	addi	a4,a4,1282 # 8000f880 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	58f72623          	sw	a5,1420(a4) # 8000f920 <cons+0xa0>
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
    800003b6:	4ce78793          	addi	a5,a5,1230 # 8000f880 <cons>
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
    800003da:	54c7a323          	sw	a2,1350(a5) # 8000f91c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	53a50513          	addi	a0,a0,1338 # 8000f918 <cons+0x98>
    800003e6:	271010ef          	jal	ra,80001e56 <wakeup>
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
    80000400:	48450513          	addi	a0,a0,1156 # 8000f880 <cons>
    80000404:	6e6000ef          	jal	ra,80000aea <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	5e478793          	addi	a5,a5,1508 # 8001f9f0 <devsw>
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
    800004f8:	3607a783          	lw	a5,864(a5) # 80007854 <panicking>
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
    80000536:	3f650513          	addi	a0,a0,1014 # 8000f928 <pr>
    8000053a:	630000ef          	jal	ra,80000b6a <acquire>
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
    80000754:	1047a783          	lw	a5,260(a5) # 80007854 <panicking>
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
    8000077e:	1ae50513          	addi	a0,a0,430 # 8000f928 <pr>
    80000782:	480000ef          	jal	ra,80000c02 <release>
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
    8000079c:	0b27ae23          	sw	s2,188(a5) # 80007854 <panicking>
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
    800007be:	0927ab23          	sw	s2,150(a5) # 80007850 <panicked>
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
    800007d8:	15450513          	addi	a0,a0,340 # 8000f928 <pr>
    800007dc:	30e000ef          	jal	ra,80000aea <initlock>
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
    80000824:	12050513          	addi	a0,a0,288 # 8000f940 <tx_lock>
    80000828:	2c2000ef          	jal	ra,80000aea <initlock>
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
    80000852:	0f250513          	addi	a0,a0,242 # 8000f940 <tx_lock>
    80000856:	314000ef          	jal	ra,80000b6a <acquire>

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
    80000872:	fee48493          	addi	s1,s1,-18 # 8000785c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	0ca98993          	addi	s3,s3,202 # 8000f940 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	fda90913          	addi	s2,s2,-38 # 80007858 <tx_chan>
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
    80000892:	578010ef          	jal	ra,80001e0a <sleep>
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
    800008b6:	08e50513          	addi	a0,a0,142 # 8000f940 <tx_lock>
    800008ba:	348000ef          	jal	ra,80000c02 <release>
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
    800008e4:	f747a783          	lw	a5,-140(a5) # 80007854 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	f667a783          	lw	a5,-154(a5) # 80007850 <panicked>
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
    800008fa:	230000ef          	jal	ra,80000b2a <push_off>
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
    8000091a:	f3e7a783          	lw	a5,-194(a5) # 80007854 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	284000ef          	jal	ra,80000bae <pop_off>
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
    8000096a:	fda50513          	addi	a0,a0,-38 # 8000f940 <tx_lock>
    8000096e:	1fc000ef          	jal	ra,80000b6a <acquire>
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
    80000980:	fc450513          	addi	a0,a0,-60 # 8000f940 <tx_lock>
    80000984:	27e000ef          	jal	ra,80000c02 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00007797          	auipc	a5,0x7
    80000990:	ec07a823          	sw	zero,-304(a5) # 8000785c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00007517          	auipc	a0,0x7
    80000998:	ec450513          	addi	a0,a0,-316 # 80007858 <tx_chan>
    8000099c:	4ba010ef          	jal	ra,80001e56 <wakeup>
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

00000000800009b8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009b8:	1101                	addi	sp,sp,-32
    800009ba:	ec06                	sd	ra,24(sp)
    800009bc:	e822                	sd	s0,16(sp)
    800009be:	e426                	sd	s1,8(sp)
    800009c0:	e04a                	sd	s2,0(sp)
    800009c2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009c4:	03451793          	slli	a5,a0,0x34
    800009c8:	e7a9                	bnez	a5,80000a12 <kfree+0x5a>
    800009ca:	84aa                	mv	s1,a0
    800009cc:	00020797          	auipc	a5,0x20
    800009d0:	1bc78793          	addi	a5,a5,444 # 80020b88 <end>
    800009d4:	02f56f63          	bltu	a0,a5,80000a12 <kfree+0x5a>
    800009d8:	47c5                	li	a5,17
    800009da:	07ee                	slli	a5,a5,0x1b
    800009dc:	02f57b63          	bgeu	a0,a5,80000a12 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009e0:	6605                	lui	a2,0x1
    800009e2:	4585                	li	a1,1
    800009e4:	25a000ef          	jal	ra,80000c3e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800009e8:	0000f917          	auipc	s2,0xf
    800009ec:	f7090913          	addi	s2,s2,-144 # 8000f958 <kmem>
    800009f0:	854a                	mv	a0,s2
    800009f2:	178000ef          	jal	ra,80000b6a <acquire>
  r->next = kmem.freelist;
    800009f6:	01893783          	ld	a5,24(s2)
    800009fa:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800009fc:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a00:	854a                	mv	a0,s2
    80000a02:	200000ef          	jal	ra,80000c02 <release>
}
    80000a06:	60e2                	ld	ra,24(sp)
    80000a08:	6442                	ld	s0,16(sp)
    80000a0a:	64a2                	ld	s1,8(sp)
    80000a0c:	6902                	ld	s2,0(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret
    panic("kfree");
    80000a12:	00006517          	auipc	a0,0x6
    80000a16:	64650513          	addi	a0,a0,1606 # 80007058 <digits+0x20>
    80000a1a:	d6fff0ef          	jal	ra,80000788 <panic>

0000000080000a1e <freerange>:
{
    80000a1e:	7179                	addi	sp,sp,-48
    80000a20:	f406                	sd	ra,40(sp)
    80000a22:	f022                	sd	s0,32(sp)
    80000a24:	ec26                	sd	s1,24(sp)
    80000a26:	e84a                	sd	s2,16(sp)
    80000a28:	e44e                	sd	s3,8(sp)
    80000a2a:	e052                	sd	s4,0(sp)
    80000a2c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a2e:	6785                	lui	a5,0x1
    80000a30:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a34:	00e504b3          	add	s1,a0,a4
    80000a38:	777d                	lui	a4,0xfffff
    80000a3a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a3c:	94be                	add	s1,s1,a5
    80000a3e:	0095ec63          	bltu	a1,s1,80000a56 <freerange+0x38>
    80000a42:	892e                	mv	s2,a1
    kfree(p);
    80000a44:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a46:	6985                	lui	s3,0x1
    kfree(p);
    80000a48:	01448533          	add	a0,s1,s4
    80000a4c:	f6dff0ef          	jal	ra,800009b8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a50:	94ce                	add	s1,s1,s3
    80000a52:	fe997be3          	bgeu	s2,s1,80000a48 <freerange+0x2a>
}
    80000a56:	70a2                	ld	ra,40(sp)
    80000a58:	7402                	ld	s0,32(sp)
    80000a5a:	64e2                	ld	s1,24(sp)
    80000a5c:	6942                	ld	s2,16(sp)
    80000a5e:	69a2                	ld	s3,8(sp)
    80000a60:	6a02                	ld	s4,0(sp)
    80000a62:	6145                	addi	sp,sp,48
    80000a64:	8082                	ret

0000000080000a66 <kinit>:
{
    80000a66:	1141                	addi	sp,sp,-16
    80000a68:	e406                	sd	ra,8(sp)
    80000a6a:	e022                	sd	s0,0(sp)
    80000a6c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a6e:	00006597          	auipc	a1,0x6
    80000a72:	5f258593          	addi	a1,a1,1522 # 80007060 <digits+0x28>
    80000a76:	0000f517          	auipc	a0,0xf
    80000a7a:	ee250513          	addi	a0,a0,-286 # 8000f958 <kmem>
    80000a7e:	06c000ef          	jal	ra,80000aea <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a82:	45c5                	li	a1,17
    80000a84:	05ee                	slli	a1,a1,0x1b
    80000a86:	00020517          	auipc	a0,0x20
    80000a8a:	10250513          	addi	a0,a0,258 # 80020b88 <end>
    80000a8e:	f91ff0ef          	jal	ra,80000a1e <freerange>
}
    80000a92:	60a2                	ld	ra,8(sp)
    80000a94:	6402                	ld	s0,0(sp)
    80000a96:	0141                	addi	sp,sp,16
    80000a98:	8082                	ret

0000000080000a9a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a9a:	1101                	addi	sp,sp,-32
    80000a9c:	ec06                	sd	ra,24(sp)
    80000a9e:	e822                	sd	s0,16(sp)
    80000aa0:	e426                	sd	s1,8(sp)
    80000aa2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aa4:	0000f497          	auipc	s1,0xf
    80000aa8:	eb448493          	addi	s1,s1,-332 # 8000f958 <kmem>
    80000aac:	8526                	mv	a0,s1
    80000aae:	0bc000ef          	jal	ra,80000b6a <acquire>
  r = kmem.freelist;
    80000ab2:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab4:	c485                	beqz	s1,80000adc <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab6:	609c                	ld	a5,0(s1)
    80000ab8:	0000f517          	auipc	a0,0xf
    80000abc:	ea050513          	addi	a0,a0,-352 # 8000f958 <kmem>
    80000ac0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ac2:	140000ef          	jal	ra,80000c02 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ac6:	6605                	lui	a2,0x1
    80000ac8:	4595                	li	a1,5
    80000aca:	8526                	mv	a0,s1
    80000acc:	172000ef          	jal	ra,80000c3e <memset>
  return (void*)r;
}
    80000ad0:	8526                	mv	a0,s1
    80000ad2:	60e2                	ld	ra,24(sp)
    80000ad4:	6442                	ld	s0,16(sp)
    80000ad6:	64a2                	ld	s1,8(sp)
    80000ad8:	6105                	addi	sp,sp,32
    80000ada:	8082                	ret
  release(&kmem.lock);
    80000adc:	0000f517          	auipc	a0,0xf
    80000ae0:	e7c50513          	addi	a0,a0,-388 # 8000f958 <kmem>
    80000ae4:	11e000ef          	jal	ra,80000c02 <release>
  if(r)
    80000ae8:	b7e5                	j	80000ad0 <kalloc+0x36>

0000000080000aea <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000aea:	1141                	addi	sp,sp,-16
    80000aec:	e422                	sd	s0,8(sp)
    80000aee:	0800                	addi	s0,sp,16
  lk->name = name;
    80000af0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000af2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000af6:	00053823          	sd	zero,16(a0)
}
    80000afa:	6422                	ld	s0,8(sp)
    80000afc:	0141                	addi	sp,sp,16
    80000afe:	8082                	ret

0000000080000b00 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b00:	411c                	lw	a5,0(a0)
    80000b02:	e399                	bnez	a5,80000b08 <holding+0x8>
    80000b04:	4501                	li	a0,0
  return r;
}
    80000b06:	8082                	ret
{
    80000b08:	1101                	addi	sp,sp,-32
    80000b0a:	ec06                	sd	ra,24(sp)
    80000b0c:	e822                	sd	s0,16(sp)
    80000b0e:	e426                	sd	s1,8(sp)
    80000b10:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b12:	6904                	ld	s1,16(a0)
    80000b14:	4d3000ef          	jal	ra,800017e6 <mycpu>
    80000b18:	40a48533          	sub	a0,s1,a0
    80000b1c:	00153513          	seqz	a0,a0
}
    80000b20:	60e2                	ld	ra,24(sp)
    80000b22:	6442                	ld	s0,16(sp)
    80000b24:	64a2                	ld	s1,8(sp)
    80000b26:	6105                	addi	sp,sp,32
    80000b28:	8082                	ret

0000000080000b2a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b34:	100024f3          	csrr	s1,sstatus
    80000b38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b3c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b3e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000b42:	4a5000ef          	jal	ra,800017e6 <mycpu>
    80000b46:	5d3c                	lw	a5,120(a0)
    80000b48:	cb99                	beqz	a5,80000b5e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4a:	49d000ef          	jal	ra,800017e6 <mycpu>
    80000b4e:	5d3c                	lw	a5,120(a0)
    80000b50:	2785                	addiw	a5,a5,1
    80000b52:	dd3c                	sw	a5,120(a0)
}
    80000b54:	60e2                	ld	ra,24(sp)
    80000b56:	6442                	ld	s0,16(sp)
    80000b58:	64a2                	ld	s1,8(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret
    mycpu()->intena = old;
    80000b5e:	489000ef          	jal	ra,800017e6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b62:	8085                	srli	s1,s1,0x1
    80000b64:	8885                	andi	s1,s1,1
    80000b66:	dd64                	sw	s1,124(a0)
    80000b68:	b7cd                	j	80000b4a <push_off+0x20>

0000000080000b6a <acquire>:
{
    80000b6a:	1101                	addi	sp,sp,-32
    80000b6c:	ec06                	sd	ra,24(sp)
    80000b6e:	e822                	sd	s0,16(sp)
    80000b70:	e426                	sd	s1,8(sp)
    80000b72:	1000                	addi	s0,sp,32
    80000b74:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b76:	fb5ff0ef          	jal	ra,80000b2a <push_off>
  if(holding(lk))
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	f85ff0ef          	jal	ra,80000b00 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b80:	4705                	li	a4,1
  if(holding(lk))
    80000b82:	e105                	bnez	a0,80000ba2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b84:	87ba                	mv	a5,a4
    80000b86:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b8a:	2781                	sext.w	a5,a5
    80000b8c:	ffe5                	bnez	a5,80000b84 <acquire+0x1a>
  __sync_synchronize();
    80000b8e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b92:	455000ef          	jal	ra,800017e6 <mycpu>
    80000b96:	e888                	sd	a0,16(s1)
}
    80000b98:	60e2                	ld	ra,24(sp)
    80000b9a:	6442                	ld	s0,16(sp)
    80000b9c:	64a2                	ld	s1,8(sp)
    80000b9e:	6105                	addi	sp,sp,32
    80000ba0:	8082                	ret
    panic("acquire");
    80000ba2:	00006517          	auipc	a0,0x6
    80000ba6:	4c650513          	addi	a0,a0,1222 # 80007068 <digits+0x30>
    80000baa:	bdfff0ef          	jal	ra,80000788 <panic>

0000000080000bae <pop_off>:

void
pop_off(void)
{
    80000bae:	1141                	addi	sp,sp,-16
    80000bb0:	e406                	sd	ra,8(sp)
    80000bb2:	e022                	sd	s0,0(sp)
    80000bb4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bb6:	431000ef          	jal	ra,800017e6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bbe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bc0:	e78d                	bnez	a5,80000bea <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bc2:	5d3c                	lw	a5,120(a0)
    80000bc4:	02f05963          	blez	a5,80000bf6 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bc8:	37fd                	addiw	a5,a5,-1
    80000bca:	0007871b          	sext.w	a4,a5
    80000bce:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000bd0:	eb09                	bnez	a4,80000be2 <pop_off+0x34>
    80000bd2:	5d7c                	lw	a5,124(a0)
    80000bd4:	c799                	beqz	a5,80000be2 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bda:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bde:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000be2:	60a2                	ld	ra,8(sp)
    80000be4:	6402                	ld	s0,0(sp)
    80000be6:	0141                	addi	sp,sp,16
    80000be8:	8082                	ret
    panic("pop_off - interruptible");
    80000bea:	00006517          	auipc	a0,0x6
    80000bee:	48650513          	addi	a0,a0,1158 # 80007070 <digits+0x38>
    80000bf2:	b97ff0ef          	jal	ra,80000788 <panic>
    panic("pop_off");
    80000bf6:	00006517          	auipc	a0,0x6
    80000bfa:	49250513          	addi	a0,a0,1170 # 80007088 <digits+0x50>
    80000bfe:	b8bff0ef          	jal	ra,80000788 <panic>

0000000080000c02 <release>:
{
    80000c02:	1101                	addi	sp,sp,-32
    80000c04:	ec06                	sd	ra,24(sp)
    80000c06:	e822                	sd	s0,16(sp)
    80000c08:	e426                	sd	s1,8(sp)
    80000c0a:	1000                	addi	s0,sp,32
    80000c0c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c0e:	ef3ff0ef          	jal	ra,80000b00 <holding>
    80000c12:	c105                	beqz	a0,80000c32 <release+0x30>
  lk->cpu = 0;
    80000c14:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c1c:	0f50000f          	fence	iorw,ow
    80000c20:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c24:	f8bff0ef          	jal	ra,80000bae <pop_off>
}
    80000c28:	60e2                	ld	ra,24(sp)
    80000c2a:	6442                	ld	s0,16(sp)
    80000c2c:	64a2                	ld	s1,8(sp)
    80000c2e:	6105                	addi	sp,sp,32
    80000c30:	8082                	ret
    panic("release");
    80000c32:	00006517          	auipc	a0,0x6
    80000c36:	45e50513          	addi	a0,a0,1118 # 80007090 <digits+0x58>
    80000c3a:	b4fff0ef          	jal	ra,80000788 <panic>

0000000080000c3e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e422                	sd	s0,8(sp)
    80000c42:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c44:	ca19                	beqz	a2,80000c5a <memset+0x1c>
    80000c46:	87aa                	mv	a5,a0
    80000c48:	1602                	slli	a2,a2,0x20
    80000c4a:	9201                	srli	a2,a2,0x20
    80000c4c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c50:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c54:	0785                	addi	a5,a5,1
    80000c56:	fee79de3          	bne	a5,a4,80000c50 <memset+0x12>
  }
  return dst;
}
    80000c5a:	6422                	ld	s0,8(sp)
    80000c5c:	0141                	addi	sp,sp,16
    80000c5e:	8082                	ret

0000000080000c60 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c60:	1141                	addi	sp,sp,-16
    80000c62:	e422                	sd	s0,8(sp)
    80000c64:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c66:	ca05                	beqz	a2,80000c96 <memcmp+0x36>
    80000c68:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c6c:	1682                	slli	a3,a3,0x20
    80000c6e:	9281                	srli	a3,a3,0x20
    80000c70:	0685                	addi	a3,a3,1
    80000c72:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c74:	00054783          	lbu	a5,0(a0)
    80000c78:	0005c703          	lbu	a4,0(a1)
    80000c7c:	00e79863          	bne	a5,a4,80000c8c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c80:	0505                	addi	a0,a0,1
    80000c82:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c84:	fed518e3          	bne	a0,a3,80000c74 <memcmp+0x14>
  }

  return 0;
    80000c88:	4501                	li	a0,0
    80000c8a:	a019                	j	80000c90 <memcmp+0x30>
      return *s1 - *s2;
    80000c8c:	40e7853b          	subw	a0,a5,a4
}
    80000c90:	6422                	ld	s0,8(sp)
    80000c92:	0141                	addi	sp,sp,16
    80000c94:	8082                	ret
  return 0;
    80000c96:	4501                	li	a0,0
    80000c98:	bfe5                	j	80000c90 <memcmp+0x30>

0000000080000c9a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000c9a:	1141                	addi	sp,sp,-16
    80000c9c:	e422                	sd	s0,8(sp)
    80000c9e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ca0:	c205                	beqz	a2,80000cc0 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ca2:	02a5e263          	bltu	a1,a0,80000cc6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ca6:	1602                	slli	a2,a2,0x20
    80000ca8:	9201                	srli	a2,a2,0x20
    80000caa:	00c587b3          	add	a5,a1,a2
{
    80000cae:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cb0:	0585                	addi	a1,a1,1
    80000cb2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde479>
    80000cb4:	fff5c683          	lbu	a3,-1(a1)
    80000cb8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cbc:	fef59ae3          	bne	a1,a5,80000cb0 <memmove+0x16>

  return dst;
}
    80000cc0:	6422                	ld	s0,8(sp)
    80000cc2:	0141                	addi	sp,sp,16
    80000cc4:	8082                	ret
  if(s < d && s + n > d){
    80000cc6:	02061693          	slli	a3,a2,0x20
    80000cca:	9281                	srli	a3,a3,0x20
    80000ccc:	00d58733          	add	a4,a1,a3
    80000cd0:	fce57be3          	bgeu	a0,a4,80000ca6 <memmove+0xc>
    d += n;
    80000cd4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cd6:	fff6079b          	addiw	a5,a2,-1
    80000cda:	1782                	slli	a5,a5,0x20
    80000cdc:	9381                	srli	a5,a5,0x20
    80000cde:	fff7c793          	not	a5,a5
    80000ce2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ce4:	177d                	addi	a4,a4,-1
    80000ce6:	16fd                	addi	a3,a3,-1
    80000ce8:	00074603          	lbu	a2,0(a4)
    80000cec:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000cf0:	fee79ae3          	bne	a5,a4,80000ce4 <memmove+0x4a>
    80000cf4:	b7f1                	j	80000cc0 <memmove+0x26>

0000000080000cf6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000cf6:	1141                	addi	sp,sp,-16
    80000cf8:	e406                	sd	ra,8(sp)
    80000cfa:	e022                	sd	s0,0(sp)
    80000cfc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000cfe:	f9dff0ef          	jal	ra,80000c9a <memmove>
}
    80000d02:	60a2                	ld	ra,8(sp)
    80000d04:	6402                	ld	s0,0(sp)
    80000d06:	0141                	addi	sp,sp,16
    80000d08:	8082                	ret

0000000080000d0a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d0a:	1141                	addi	sp,sp,-16
    80000d0c:	e422                	sd	s0,8(sp)
    80000d0e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d10:	ce11                	beqz	a2,80000d2c <strncmp+0x22>
    80000d12:	00054783          	lbu	a5,0(a0)
    80000d16:	cf89                	beqz	a5,80000d30 <strncmp+0x26>
    80000d18:	0005c703          	lbu	a4,0(a1)
    80000d1c:	00f71a63          	bne	a4,a5,80000d30 <strncmp+0x26>
    n--, p++, q++;
    80000d20:	367d                	addiw	a2,a2,-1
    80000d22:	0505                	addi	a0,a0,1
    80000d24:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d26:	f675                	bnez	a2,80000d12 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d28:	4501                	li	a0,0
    80000d2a:	a809                	j	80000d3c <strncmp+0x32>
    80000d2c:	4501                	li	a0,0
    80000d2e:	a039                	j	80000d3c <strncmp+0x32>
  if(n == 0)
    80000d30:	ca09                	beqz	a2,80000d42 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d32:	00054503          	lbu	a0,0(a0)
    80000d36:	0005c783          	lbu	a5,0(a1)
    80000d3a:	9d1d                	subw	a0,a0,a5
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
    return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <strncmp+0x32>

0000000080000d46 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d4c:	872a                	mv	a4,a0
    80000d4e:	8832                	mv	a6,a2
    80000d50:	367d                	addiw	a2,a2,-1
    80000d52:	01005963          	blez	a6,80000d64 <strncpy+0x1e>
    80000d56:	0705                	addi	a4,a4,1
    80000d58:	0005c783          	lbu	a5,0(a1)
    80000d5c:	fef70fa3          	sb	a5,-1(a4)
    80000d60:	0585                	addi	a1,a1,1
    80000d62:	f7f5                	bnez	a5,80000d4e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d64:	86ba                	mv	a3,a4
    80000d66:	00c05c63          	blez	a2,80000d7e <strncpy+0x38>
    *s++ = 0;
    80000d6a:	0685                	addi	a3,a3,1
    80000d6c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d70:	40d707bb          	subw	a5,a4,a3
    80000d74:	37fd                	addiw	a5,a5,-1
    80000d76:	010787bb          	addw	a5,a5,a6
    80000d7a:	fef048e3          	bgtz	a5,80000d6a <strncpy+0x24>
  return os;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret

0000000080000d84 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e422                	sd	s0,8(sp)
    80000d88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d8a:	02c05363          	blez	a2,80000db0 <safestrcpy+0x2c>
    80000d8e:	fff6069b          	addiw	a3,a2,-1
    80000d92:	1682                	slli	a3,a3,0x20
    80000d94:	9281                	srli	a3,a3,0x20
    80000d96:	96ae                	add	a3,a3,a1
    80000d98:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d9a:	00d58963          	beq	a1,a3,80000dac <safestrcpy+0x28>
    80000d9e:	0585                	addi	a1,a1,1
    80000da0:	0785                	addi	a5,a5,1
    80000da2:	fff5c703          	lbu	a4,-1(a1)
    80000da6:	fee78fa3          	sb	a4,-1(a5)
    80000daa:	fb65                	bnez	a4,80000d9a <safestrcpy+0x16>
    ;
  *s = 0;
    80000dac:	00078023          	sb	zero,0(a5)
  return os;
}
    80000db0:	6422                	ld	s0,8(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <strlen>:

int
strlen(const char *s)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e422                	sd	s0,8(sp)
    80000dba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dbc:	00054783          	lbu	a5,0(a0)
    80000dc0:	cf91                	beqz	a5,80000ddc <strlen+0x26>
    80000dc2:	0505                	addi	a0,a0,1
    80000dc4:	87aa                	mv	a5,a0
    80000dc6:	4685                	li	a3,1
    80000dc8:	9e89                	subw	a3,a3,a0
    80000dca:	00f6853b          	addw	a0,a3,a5
    80000dce:	0785                	addi	a5,a5,1
    80000dd0:	fff7c703          	lbu	a4,-1(a5)
    80000dd4:	fb7d                	bnez	a4,80000dca <strlen+0x14>
    ;
  return n;
}
    80000dd6:	6422                	ld	s0,8(sp)
    80000dd8:	0141                	addi	sp,sp,16
    80000dda:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ddc:	4501                	li	a0,0
    80000dde:	bfe5                	j	80000dd6 <strlen+0x20>

0000000080000de0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e406                	sd	ra,8(sp)
    80000de4:	e022                	sd	s0,0(sp)
    80000de6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000de8:	1ef000ef          	jal	ra,800017d6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dec:	00007717          	auipc	a4,0x7
    80000df0:	a7470713          	addi	a4,a4,-1420 # 80007860 <started>
  if(cpuid() == 0){
    80000df4:	c51d                	beqz	a0,80000e22 <main+0x42>
    while(started == 0)
    80000df6:	431c                	lw	a5,0(a4)
    80000df8:	2781                	sext.w	a5,a5
    80000dfa:	dff5                	beqz	a5,80000df6 <main+0x16>
      ;
    __sync_synchronize();
    80000dfc:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e00:	1d7000ef          	jal	ra,800017d6 <cpuid>
    80000e04:	85aa                	mv	a1,a0
    80000e06:	00006517          	auipc	a0,0x6
    80000e0a:	2aa50513          	addi	a0,a0,682 # 800070b0 <digits+0x78>
    80000e0e:	eb4ff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000e12:	080000ef          	jal	ra,80000e92 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e16:	516010ef          	jal	ra,8000232c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1a:	40a040ef          	jal	ra,80005224 <plicinithart>
  }

  scheduler();        
    80000e1e:	655000ef          	jal	ra,80001c72 <scheduler>
    consoleinit();
    80000e22:	dcaff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e26:	99fff0ef          	jal	ra,800007c4 <printfinit>
    printf("\n");
    80000e2a:	00006517          	auipc	a0,0x6
    80000e2e:	29650513          	addi	a0,a0,662 # 800070c0 <digits+0x88>
    80000e32:	e90ff0ef          	jal	ra,800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000e36:	00006517          	auipc	a0,0x6
    80000e3a:	26250513          	addi	a0,a0,610 # 80007098 <digits+0x60>
    80000e3e:	e84ff0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80000e42:	00006517          	auipc	a0,0x6
    80000e46:	27e50513          	addi	a0,a0,638 # 800070c0 <digits+0x88>
    80000e4a:	e78ff0ef          	jal	ra,800004c2 <printf>
    kinit();         // physical page allocator
    80000e4e:	c19ff0ef          	jal	ra,80000a66 <kinit>
    kvminit();       // create kernel page table
    80000e52:	2ca000ef          	jal	ra,8000111c <kvminit>
    kvminithart();   // turn on paging
    80000e56:	03c000ef          	jal	ra,80000e92 <kvminithart>
    procinit();      // process table
    80000e5a:	0d5000ef          	jal	ra,8000172e <procinit>
    trapinit();      // trap vectors
    80000e5e:	4aa010ef          	jal	ra,80002308 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e62:	4ca010ef          	jal	ra,8000232c <trapinithart>
    plicinit();      // set up interrupt controller
    80000e66:	3a8040ef          	jal	ra,8000520e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6a:	3ba040ef          	jal	ra,80005224 <plicinithart>
    binit();         // buffer cache
    80000e6e:	34d010ef          	jal	ra,800029ba <binit>
    iinit();         // inode table
    80000e72:	0bc020ef          	jal	ra,80002f2e <iinit>
    fileinit();      // file table
    80000e76:	7a5020ef          	jal	ra,80003e1a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7a:	49a040ef          	jal	ra,80005314 <virtio_disk_init>
    userinit();      // first user process
    80000e7e:	44b000ef          	jal	ra,80001ac8 <userinit>
    __sync_synchronize();
    80000e82:	0ff0000f          	fence
    started = 1;
    80000e86:	4785                	li	a5,1
    80000e88:	00007717          	auipc	a4,0x7
    80000e8c:	9cf72c23          	sw	a5,-1576(a4) # 80007860 <started>
    80000e90:	b779                	j	80000e1e <main+0x3e>

0000000080000e92 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000e98:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000e9c:	00007797          	auipc	a5,0x7
    80000ea0:	9cc7b783          	ld	a5,-1588(a5) # 80007868 <kernel_pagetable>
    80000ea4:	83b1                	srli	a5,a5,0xc
    80000ea6:	577d                	li	a4,-1
    80000ea8:	177e                	slli	a4,a4,0x3f
    80000eaa:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000eac:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000eb0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000eb4:	6422                	ld	s0,8(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret

0000000080000eba <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000eba:	7139                	addi	sp,sp,-64
    80000ebc:	fc06                	sd	ra,56(sp)
    80000ebe:	f822                	sd	s0,48(sp)
    80000ec0:	f426                	sd	s1,40(sp)
    80000ec2:	f04a                	sd	s2,32(sp)
    80000ec4:	ec4e                	sd	s3,24(sp)
    80000ec6:	e852                	sd	s4,16(sp)
    80000ec8:	e456                	sd	s5,8(sp)
    80000eca:	e05a                	sd	s6,0(sp)
    80000ecc:	0080                	addi	s0,sp,64
    80000ece:	84aa                	mv	s1,a0
    80000ed0:	89ae                	mv	s3,a1
    80000ed2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ed4:	57fd                	li	a5,-1
    80000ed6:	83e9                	srli	a5,a5,0x1a
    80000ed8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000eda:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000edc:	02b7fc63          	bgeu	a5,a1,80000f14 <walk+0x5a>
    panic("walk");
    80000ee0:	00006517          	auipc	a0,0x6
    80000ee4:	1e850513          	addi	a0,a0,488 # 800070c8 <digits+0x90>
    80000ee8:	8a1ff0ef          	jal	ra,80000788 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000eec:	060a8263          	beqz	s5,80000f50 <walk+0x96>
    80000ef0:	babff0ef          	jal	ra,80000a9a <kalloc>
    80000ef4:	84aa                	mv	s1,a0
    80000ef6:	c139                	beqz	a0,80000f3c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ef8:	6605                	lui	a2,0x1
    80000efa:	4581                	li	a1,0
    80000efc:	d43ff0ef          	jal	ra,80000c3e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f00:	00c4d793          	srli	a5,s1,0xc
    80000f04:	07aa                	slli	a5,a5,0xa
    80000f06:	0017e793          	ori	a5,a5,1
    80000f0a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f0e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde46f>
    80000f10:	036a0063          	beq	s4,s6,80000f30 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f14:	0149d933          	srl	s2,s3,s4
    80000f18:	1ff97913          	andi	s2,s2,511
    80000f1c:	090e                	slli	s2,s2,0x3
    80000f1e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f20:	00093483          	ld	s1,0(s2)
    80000f24:	0014f793          	andi	a5,s1,1
    80000f28:	d3f1                	beqz	a5,80000eec <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f2a:	80a9                	srli	s1,s1,0xa
    80000f2c:	04b2                	slli	s1,s1,0xc
    80000f2e:	b7c5                	j	80000f0e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f30:	00c9d513          	srli	a0,s3,0xc
    80000f34:	1ff57513          	andi	a0,a0,511
    80000f38:	050e                	slli	a0,a0,0x3
    80000f3a:	9526                	add	a0,a0,s1
}
    80000f3c:	70e2                	ld	ra,56(sp)
    80000f3e:	7442                	ld	s0,48(sp)
    80000f40:	74a2                	ld	s1,40(sp)
    80000f42:	7902                	ld	s2,32(sp)
    80000f44:	69e2                	ld	s3,24(sp)
    80000f46:	6a42                	ld	s4,16(sp)
    80000f48:	6aa2                	ld	s5,8(sp)
    80000f4a:	6b02                	ld	s6,0(sp)
    80000f4c:	6121                	addi	sp,sp,64
    80000f4e:	8082                	ret
        return 0;
    80000f50:	4501                	li	a0,0
    80000f52:	b7ed                	j	80000f3c <walk+0x82>

0000000080000f54 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f54:	57fd                	li	a5,-1
    80000f56:	83e9                	srli	a5,a5,0x1a
    80000f58:	00b7f463          	bgeu	a5,a1,80000f60 <walkaddr+0xc>
    return 0;
    80000f5c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f5e:	8082                	ret
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f68:	4601                	li	a2,0
    80000f6a:	f51ff0ef          	jal	ra,80000eba <walk>
  if(pte == 0)
    80000f6e:	c105                	beqz	a0,80000f8e <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f70:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f72:	0117f693          	andi	a3,a5,17
    80000f76:	4745                	li	a4,17
    return 0;
    80000f78:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f7a:	00e68663          	beq	a3,a4,80000f86 <walkaddr+0x32>
}
    80000f7e:	60a2                	ld	ra,8(sp)
    80000f80:	6402                	ld	s0,0(sp)
    80000f82:	0141                	addi	sp,sp,16
    80000f84:	8082                	ret
  pa = PTE2PA(*pte);
    80000f86:	83a9                	srli	a5,a5,0xa
    80000f88:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000f8c:	bfcd                	j	80000f7e <walkaddr+0x2a>
    return 0;
    80000f8e:	4501                	li	a0,0
    80000f90:	b7fd                	j	80000f7e <walkaddr+0x2a>

0000000080000f92 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000f92:	715d                	addi	sp,sp,-80
    80000f94:	e486                	sd	ra,72(sp)
    80000f96:	e0a2                	sd	s0,64(sp)
    80000f98:	fc26                	sd	s1,56(sp)
    80000f9a:	f84a                	sd	s2,48(sp)
    80000f9c:	f44e                	sd	s3,40(sp)
    80000f9e:	f052                	sd	s4,32(sp)
    80000fa0:	ec56                	sd	s5,24(sp)
    80000fa2:	e85a                	sd	s6,16(sp)
    80000fa4:	e45e                	sd	s7,8(sp)
    80000fa6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000fa8:	03459793          	slli	a5,a1,0x34
    80000fac:	e7a9                	bnez	a5,80000ff6 <mappages+0x64>
    80000fae:	8aaa                	mv	s5,a0
    80000fb0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fb2:	03461793          	slli	a5,a2,0x34
    80000fb6:	e7b1                	bnez	a5,80001002 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fb8:	ca39                	beqz	a2,8000100e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fba:	77fd                	lui	a5,0xfffff
    80000fbc:	963e                	add	a2,a2,a5
    80000fbe:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fc2:	892e                	mv	s2,a1
    80000fc4:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000fc8:	6b85                	lui	s7,0x1
    80000fca:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000fce:	4605                	li	a2,1
    80000fd0:	85ca                	mv	a1,s2
    80000fd2:	8556                	mv	a0,s5
    80000fd4:	ee7ff0ef          	jal	ra,80000eba <walk>
    80000fd8:	c539                	beqz	a0,80001026 <mappages+0x94>
    if(*pte & PTE_V)
    80000fda:	611c                	ld	a5,0(a0)
    80000fdc:	8b85                	andi	a5,a5,1
    80000fde:	ef95                	bnez	a5,8000101a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000fe0:	80b1                	srli	s1,s1,0xc
    80000fe2:	04aa                	slli	s1,s1,0xa
    80000fe4:	0164e4b3          	or	s1,s1,s6
    80000fe8:	0014e493          	ori	s1,s1,1
    80000fec:	e104                	sd	s1,0(a0)
    if(a == last)
    80000fee:	05390863          	beq	s2,s3,8000103e <mappages+0xac>
    a += PGSIZE;
    80000ff2:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ff4:	bfd9                	j	80000fca <mappages+0x38>
    panic("mappages: va not aligned");
    80000ff6:	00006517          	auipc	a0,0x6
    80000ffa:	0da50513          	addi	a0,a0,218 # 800070d0 <digits+0x98>
    80000ffe:	f8aff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size not aligned");
    80001002:	00006517          	auipc	a0,0x6
    80001006:	0ee50513          	addi	a0,a0,238 # 800070f0 <digits+0xb8>
    8000100a:	f7eff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size");
    8000100e:	00006517          	auipc	a0,0x6
    80001012:	10250513          	addi	a0,a0,258 # 80007110 <digits+0xd8>
    80001016:	f72ff0ef          	jal	ra,80000788 <panic>
      panic("mappages: remap");
    8000101a:	00006517          	auipc	a0,0x6
    8000101e:	10650513          	addi	a0,a0,262 # 80007120 <digits+0xe8>
    80001022:	f66ff0ef          	jal	ra,80000788 <panic>
      return -1;
    80001026:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001028:	60a6                	ld	ra,72(sp)
    8000102a:	6406                	ld	s0,64(sp)
    8000102c:	74e2                	ld	s1,56(sp)
    8000102e:	7942                	ld	s2,48(sp)
    80001030:	79a2                	ld	s3,40(sp)
    80001032:	7a02                	ld	s4,32(sp)
    80001034:	6ae2                	ld	s5,24(sp)
    80001036:	6b42                	ld	s6,16(sp)
    80001038:	6ba2                	ld	s7,8(sp)
    8000103a:	6161                	addi	sp,sp,80
    8000103c:	8082                	ret
  return 0;
    8000103e:	4501                	li	a0,0
    80001040:	b7e5                	j	80001028 <mappages+0x96>

0000000080001042 <kvmmap>:
{
    80001042:	1141                	addi	sp,sp,-16
    80001044:	e406                	sd	ra,8(sp)
    80001046:	e022                	sd	s0,0(sp)
    80001048:	0800                	addi	s0,sp,16
    8000104a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000104c:	86b2                	mv	a3,a2
    8000104e:	863e                	mv	a2,a5
    80001050:	f43ff0ef          	jal	ra,80000f92 <mappages>
    80001054:	e509                	bnez	a0,8000105e <kvmmap+0x1c>
}
    80001056:	60a2                	ld	ra,8(sp)
    80001058:	6402                	ld	s0,0(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret
    panic("kvmmap");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	0d250513          	addi	a0,a0,210 # 80007130 <digits+0xf8>
    80001066:	f22ff0ef          	jal	ra,80000788 <panic>

000000008000106a <kvmmake>:
{
    8000106a:	1101                	addi	sp,sp,-32
    8000106c:	ec06                	sd	ra,24(sp)
    8000106e:	e822                	sd	s0,16(sp)
    80001070:	e426                	sd	s1,8(sp)
    80001072:	e04a                	sd	s2,0(sp)
    80001074:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001076:	a25ff0ef          	jal	ra,80000a9a <kalloc>
    8000107a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000107c:	6605                	lui	a2,0x1
    8000107e:	4581                	li	a1,0
    80001080:	bbfff0ef          	jal	ra,80000c3e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001084:	4719                	li	a4,6
    80001086:	6685                	lui	a3,0x1
    80001088:	10000637          	lui	a2,0x10000
    8000108c:	100005b7          	lui	a1,0x10000
    80001090:	8526                	mv	a0,s1
    80001092:	fb1ff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001096:	4719                	li	a4,6
    80001098:	6685                	lui	a3,0x1
    8000109a:	10001637          	lui	a2,0x10001
    8000109e:	100015b7          	lui	a1,0x10001
    800010a2:	8526                	mv	a0,s1
    800010a4:	f9fff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010a8:	4719                	li	a4,6
    800010aa:	040006b7          	lui	a3,0x4000
    800010ae:	0c000637          	lui	a2,0xc000
    800010b2:	0c0005b7          	lui	a1,0xc000
    800010b6:	8526                	mv	a0,s1
    800010b8:	f8bff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010bc:	00006917          	auipc	s2,0x6
    800010c0:	f4490913          	addi	s2,s2,-188 # 80007000 <etext>
    800010c4:	4729                	li	a4,10
    800010c6:	80006697          	auipc	a3,0x80006
    800010ca:	f3a68693          	addi	a3,a3,-198 # 7000 <_entry-0x7fff9000>
    800010ce:	4605                	li	a2,1
    800010d0:	067e                	slli	a2,a2,0x1f
    800010d2:	85b2                	mv	a1,a2
    800010d4:	8526                	mv	a0,s1
    800010d6:	f6dff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800010da:	4719                	li	a4,6
    800010dc:	46c5                	li	a3,17
    800010de:	06ee                	slli	a3,a3,0x1b
    800010e0:	412686b3          	sub	a3,a3,s2
    800010e4:	864a                	mv	a2,s2
    800010e6:	85ca                	mv	a1,s2
    800010e8:	8526                	mv	a0,s1
    800010ea:	f59ff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010ee:	4729                	li	a4,10
    800010f0:	6685                	lui	a3,0x1
    800010f2:	00005617          	auipc	a2,0x5
    800010f6:	f0e60613          	addi	a2,a2,-242 # 80006000 <_trampoline>
    800010fa:	040005b7          	lui	a1,0x4000
    800010fe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001100:	05b2                	slli	a1,a1,0xc
    80001102:	8526                	mv	a0,s1
    80001104:	f3fff0ef          	jal	ra,80001042 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001108:	8526                	mv	a0,s1
    8000110a:	59a000ef          	jal	ra,800016a4 <proc_mapstacks>
}
    8000110e:	8526                	mv	a0,s1
    80001110:	60e2                	ld	ra,24(sp)
    80001112:	6442                	ld	s0,16(sp)
    80001114:	64a2                	ld	s1,8(sp)
    80001116:	6902                	ld	s2,0(sp)
    80001118:	6105                	addi	sp,sp,32
    8000111a:	8082                	ret

000000008000111c <kvminit>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001124:	f47ff0ef          	jal	ra,8000106a <kvmmake>
    80001128:	00006797          	auipc	a5,0x6
    8000112c:	74a7b023          	sd	a0,1856(a5) # 80007868 <kernel_pagetable>
}
    80001130:	60a2                	ld	ra,8(sp)
    80001132:	6402                	ld	s0,0(sp)
    80001134:	0141                	addi	sp,sp,16
    80001136:	8082                	ret

0000000080001138 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001138:	1101                	addi	sp,sp,-32
    8000113a:	ec06                	sd	ra,24(sp)
    8000113c:	e822                	sd	s0,16(sp)
    8000113e:	e426                	sd	s1,8(sp)
    80001140:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001142:	959ff0ef          	jal	ra,80000a9a <kalloc>
    80001146:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001148:	c509                	beqz	a0,80001152 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000114a:	6605                	lui	a2,0x1
    8000114c:	4581                	li	a1,0
    8000114e:	af1ff0ef          	jal	ra,80000c3e <memset>
  return pagetable;
}
    80001152:	8526                	mv	a0,s1
    80001154:	60e2                	ld	ra,24(sp)
    80001156:	6442                	ld	s0,16(sp)
    80001158:	64a2                	ld	s1,8(sp)
    8000115a:	6105                	addi	sp,sp,32
    8000115c:	8082                	ret

000000008000115e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000115e:	7139                	addi	sp,sp,-64
    80001160:	fc06                	sd	ra,56(sp)
    80001162:	f822                	sd	s0,48(sp)
    80001164:	f426                	sd	s1,40(sp)
    80001166:	f04a                	sd	s2,32(sp)
    80001168:	ec4e                	sd	s3,24(sp)
    8000116a:	e852                	sd	s4,16(sp)
    8000116c:	e456                	sd	s5,8(sp)
    8000116e:	e05a                	sd	s6,0(sp)
    80001170:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001172:	03459793          	slli	a5,a1,0x34
    80001176:	e785                	bnez	a5,8000119e <uvmunmap+0x40>
    80001178:	8a2a                	mv	s4,a0
    8000117a:	892e                	mv	s2,a1
    8000117c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000117e:	0632                	slli	a2,a2,0xc
    80001180:	00b609b3          	add	s3,a2,a1
    80001184:	6b05                	lui	s6,0x1
    80001186:	0335e763          	bltu	a1,s3,800011b4 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000118a:	70e2                	ld	ra,56(sp)
    8000118c:	7442                	ld	s0,48(sp)
    8000118e:	74a2                	ld	s1,40(sp)
    80001190:	7902                	ld	s2,32(sp)
    80001192:	69e2                	ld	s3,24(sp)
    80001194:	6a42                	ld	s4,16(sp)
    80001196:	6aa2                	ld	s5,8(sp)
    80001198:	6b02                	ld	s6,0(sp)
    8000119a:	6121                	addi	sp,sp,64
    8000119c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000119e:	00006517          	auipc	a0,0x6
    800011a2:	f9a50513          	addi	a0,a0,-102 # 80007138 <digits+0x100>
    800011a6:	de2ff0ef          	jal	ra,80000788 <panic>
    *pte = 0;
    800011aa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011ae:	995a                	add	s2,s2,s6
    800011b0:	fd397de3          	bgeu	s2,s3,8000118a <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011b4:	4601                	li	a2,0
    800011b6:	85ca                	mv	a1,s2
    800011b8:	8552                	mv	a0,s4
    800011ba:	d01ff0ef          	jal	ra,80000eba <walk>
    800011be:	84aa                	mv	s1,a0
    800011c0:	d57d                	beqz	a0,800011ae <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800011c2:	611c                	ld	a5,0(a0)
    800011c4:	0017f713          	andi	a4,a5,1
    800011c8:	d37d                	beqz	a4,800011ae <uvmunmap+0x50>
    if(do_free){
    800011ca:	fe0a80e3          	beqz	s5,800011aa <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    800011ce:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800011d0:	00c79513          	slli	a0,a5,0xc
    800011d4:	fe4ff0ef          	jal	ra,800009b8 <kfree>
    800011d8:	bfc9                	j	800011aa <uvmunmap+0x4c>

00000000800011da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011da:	1101                	addi	sp,sp,-32
    800011dc:	ec06                	sd	ra,24(sp)
    800011de:	e822                	sd	s0,16(sp)
    800011e0:	e426                	sd	s1,8(sp)
    800011e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800011e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800011e6:	00b67d63          	bgeu	a2,a1,80001200 <uvmdealloc+0x26>
    800011ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800011ec:	6785                	lui	a5,0x1
    800011ee:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800011f0:	00f60733          	add	a4,a2,a5
    800011f4:	76fd                	lui	a3,0xfffff
    800011f6:	8f75                	and	a4,a4,a3
    800011f8:	97ae                	add	a5,a5,a1
    800011fa:	8ff5                	and	a5,a5,a3
    800011fc:	00f76863          	bltu	a4,a5,8000120c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001200:	8526                	mv	a0,s1
    80001202:	60e2                	ld	ra,24(sp)
    80001204:	6442                	ld	s0,16(sp)
    80001206:	64a2                	ld	s1,8(sp)
    80001208:	6105                	addi	sp,sp,32
    8000120a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000120c:	8f99                	sub	a5,a5,a4
    8000120e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001210:	4685                	li	a3,1
    80001212:	0007861b          	sext.w	a2,a5
    80001216:	85ba                	mv	a1,a4
    80001218:	f47ff0ef          	jal	ra,8000115e <uvmunmap>
    8000121c:	b7d5                	j	80001200 <uvmdealloc+0x26>

000000008000121e <uvmalloc>:
  if(newsz < oldsz)
    8000121e:	08b66963          	bltu	a2,a1,800012b0 <uvmalloc+0x92>
{
    80001222:	7139                	addi	sp,sp,-64
    80001224:	fc06                	sd	ra,56(sp)
    80001226:	f822                	sd	s0,48(sp)
    80001228:	f426                	sd	s1,40(sp)
    8000122a:	f04a                	sd	s2,32(sp)
    8000122c:	ec4e                	sd	s3,24(sp)
    8000122e:	e852                	sd	s4,16(sp)
    80001230:	e456                	sd	s5,8(sp)
    80001232:	e05a                	sd	s6,0(sp)
    80001234:	0080                	addi	s0,sp,64
    80001236:	8aaa                	mv	s5,a0
    80001238:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000123a:	6785                	lui	a5,0x1
    8000123c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000123e:	95be                	add	a1,a1,a5
    80001240:	77fd                	lui	a5,0xfffff
    80001242:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001246:	06c9f763          	bgeu	s3,a2,800012b4 <uvmalloc+0x96>
    8000124a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000124c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001250:	84bff0ef          	jal	ra,80000a9a <kalloc>
    80001254:	84aa                	mv	s1,a0
    if(mem == 0){
    80001256:	c11d                	beqz	a0,8000127c <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    80001258:	6605                	lui	a2,0x1
    8000125a:	4581                	li	a1,0
    8000125c:	9e3ff0ef          	jal	ra,80000c3e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001260:	875a                	mv	a4,s6
    80001262:	86a6                	mv	a3,s1
    80001264:	6605                	lui	a2,0x1
    80001266:	85ca                	mv	a1,s2
    80001268:	8556                	mv	a0,s5
    8000126a:	d29ff0ef          	jal	ra,80000f92 <mappages>
    8000126e:	e51d                	bnez	a0,8000129c <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001270:	6785                	lui	a5,0x1
    80001272:	993e                	add	s2,s2,a5
    80001274:	fd496ee3          	bltu	s2,s4,80001250 <uvmalloc+0x32>
  return newsz;
    80001278:	8552                	mv	a0,s4
    8000127a:	a039                	j	80001288 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    8000127c:	864e                	mv	a2,s3
    8000127e:	85ca                	mv	a1,s2
    80001280:	8556                	mv	a0,s5
    80001282:	f59ff0ef          	jal	ra,800011da <uvmdealloc>
      return 0;
    80001286:	4501                	li	a0,0
}
    80001288:	70e2                	ld	ra,56(sp)
    8000128a:	7442                	ld	s0,48(sp)
    8000128c:	74a2                	ld	s1,40(sp)
    8000128e:	7902                	ld	s2,32(sp)
    80001290:	69e2                	ld	s3,24(sp)
    80001292:	6a42                	ld	s4,16(sp)
    80001294:	6aa2                	ld	s5,8(sp)
    80001296:	6b02                	ld	s6,0(sp)
    80001298:	6121                	addi	sp,sp,64
    8000129a:	8082                	ret
      kfree(mem);
    8000129c:	8526                	mv	a0,s1
    8000129e:	f1aff0ef          	jal	ra,800009b8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012a2:	864e                	mv	a2,s3
    800012a4:	85ca                	mv	a1,s2
    800012a6:	8556                	mv	a0,s5
    800012a8:	f33ff0ef          	jal	ra,800011da <uvmdealloc>
      return 0;
    800012ac:	4501                	li	a0,0
    800012ae:	bfe9                	j	80001288 <uvmalloc+0x6a>
    return oldsz;
    800012b0:	852e                	mv	a0,a1
}
    800012b2:	8082                	ret
  return newsz;
    800012b4:	8532                	mv	a0,a2
    800012b6:	bfc9                	j	80001288 <uvmalloc+0x6a>

00000000800012b8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012b8:	7179                	addi	sp,sp,-48
    800012ba:	f406                	sd	ra,40(sp)
    800012bc:	f022                	sd	s0,32(sp)
    800012be:	ec26                	sd	s1,24(sp)
    800012c0:	e84a                	sd	s2,16(sp)
    800012c2:	e44e                	sd	s3,8(sp)
    800012c4:	e052                	sd	s4,0(sp)
    800012c6:	1800                	addi	s0,sp,48
    800012c8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012ca:	84aa                	mv	s1,a0
    800012cc:	6905                	lui	s2,0x1
    800012ce:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012d0:	4985                	li	s3,1
    800012d2:	a819                	j	800012e8 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800012d6:	00c79513          	slli	a0,a5,0xc
    800012da:	fdfff0ef          	jal	ra,800012b8 <freewalk>
      pagetable[i] = 0;
    800012de:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012e2:	04a1                	addi	s1,s1,8
    800012e4:	01248f63          	beq	s1,s2,80001302 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800012e8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012ea:	00f7f713          	andi	a4,a5,15
    800012ee:	ff3703e3          	beq	a4,s3,800012d4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800012f2:	8b85                	andi	a5,a5,1
    800012f4:	d7fd                	beqz	a5,800012e2 <freewalk+0x2a>
      panic("freewalk: leaf");
    800012f6:	00006517          	auipc	a0,0x6
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80007150 <digits+0x118>
    800012fe:	c8aff0ef          	jal	ra,80000788 <panic>
    }
  }
  kfree((void*)pagetable);
    80001302:	8552                	mv	a0,s4
    80001304:	eb4ff0ef          	jal	ra,800009b8 <kfree>
}
    80001308:	70a2                	ld	ra,40(sp)
    8000130a:	7402                	ld	s0,32(sp)
    8000130c:	64e2                	ld	s1,24(sp)
    8000130e:	6942                	ld	s2,16(sp)
    80001310:	69a2                	ld	s3,8(sp)
    80001312:	6a02                	ld	s4,0(sp)
    80001314:	6145                	addi	sp,sp,48
    80001316:	8082                	ret

0000000080001318 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001318:	1101                	addi	sp,sp,-32
    8000131a:	ec06                	sd	ra,24(sp)
    8000131c:	e822                	sd	s0,16(sp)
    8000131e:	e426                	sd	s1,8(sp)
    80001320:	1000                	addi	s0,sp,32
    80001322:	84aa                	mv	s1,a0
  if(sz > 0)
    80001324:	e989                	bnez	a1,80001336 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001326:	8526                	mv	a0,s1
    80001328:	f91ff0ef          	jal	ra,800012b8 <freewalk>
}
    8000132c:	60e2                	ld	ra,24(sp)
    8000132e:	6442                	ld	s0,16(sp)
    80001330:	64a2                	ld	s1,8(sp)
    80001332:	6105                	addi	sp,sp,32
    80001334:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001336:	6785                	lui	a5,0x1
    80001338:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000133a:	95be                	add	a1,a1,a5
    8000133c:	4685                	li	a3,1
    8000133e:	00c5d613          	srli	a2,a1,0xc
    80001342:	4581                	li	a1,0
    80001344:	e1bff0ef          	jal	ra,8000115e <uvmunmap>
    80001348:	bff9                	j	80001326 <uvmfree+0xe>

000000008000134a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000134a:	ce49                	beqz	a2,800013e4 <uvmcopy+0x9a>
{
    8000134c:	715d                	addi	sp,sp,-80
    8000134e:	e486                	sd	ra,72(sp)
    80001350:	e0a2                	sd	s0,64(sp)
    80001352:	fc26                	sd	s1,56(sp)
    80001354:	f84a                	sd	s2,48(sp)
    80001356:	f44e                	sd	s3,40(sp)
    80001358:	f052                	sd	s4,32(sp)
    8000135a:	ec56                	sd	s5,24(sp)
    8000135c:	e85a                	sd	s6,16(sp)
    8000135e:	e45e                	sd	s7,8(sp)
    80001360:	0880                	addi	s0,sp,80
    80001362:	8aaa                	mv	s5,a0
    80001364:	8b2e                	mv	s6,a1
    80001366:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001368:	4481                	li	s1,0
    8000136a:	a029                	j	80001374 <uvmcopy+0x2a>
    8000136c:	6785                	lui	a5,0x1
    8000136e:	94be                	add	s1,s1,a5
    80001370:	0544fe63          	bgeu	s1,s4,800013cc <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001374:	4601                	li	a2,0
    80001376:	85a6                	mv	a1,s1
    80001378:	8556                	mv	a0,s5
    8000137a:	b41ff0ef          	jal	ra,80000eba <walk>
    8000137e:	d57d                	beqz	a0,8000136c <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001380:	6118                	ld	a4,0(a0)
    80001382:	00177793          	andi	a5,a4,1
    80001386:	d3fd                	beqz	a5,8000136c <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001388:	00a75593          	srli	a1,a4,0xa
    8000138c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001390:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001394:	f06ff0ef          	jal	ra,80000a9a <kalloc>
    80001398:	89aa                	mv	s3,a0
    8000139a:	c105                	beqz	a0,800013ba <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000139c:	6605                	lui	a2,0x1
    8000139e:	85de                	mv	a1,s7
    800013a0:	8fbff0ef          	jal	ra,80000c9a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800013a4:	874a                	mv	a4,s2
    800013a6:	86ce                	mv	a3,s3
    800013a8:	6605                	lui	a2,0x1
    800013aa:	85a6                	mv	a1,s1
    800013ac:	855a                	mv	a0,s6
    800013ae:	be5ff0ef          	jal	ra,80000f92 <mappages>
    800013b2:	dd4d                	beqz	a0,8000136c <uvmcopy+0x22>
      kfree(mem);
    800013b4:	854e                	mv	a0,s3
    800013b6:	e02ff0ef          	jal	ra,800009b8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013ba:	4685                	li	a3,1
    800013bc:	00c4d613          	srli	a2,s1,0xc
    800013c0:	4581                	li	a1,0
    800013c2:	855a                	mv	a0,s6
    800013c4:	d9bff0ef          	jal	ra,8000115e <uvmunmap>
  return -1;
    800013c8:	557d                	li	a0,-1
    800013ca:	a011                	j	800013ce <uvmcopy+0x84>
  return 0;
    800013cc:	4501                	li	a0,0
}
    800013ce:	60a6                	ld	ra,72(sp)
    800013d0:	6406                	ld	s0,64(sp)
    800013d2:	74e2                	ld	s1,56(sp)
    800013d4:	7942                	ld	s2,48(sp)
    800013d6:	79a2                	ld	s3,40(sp)
    800013d8:	7a02                	ld	s4,32(sp)
    800013da:	6ae2                	ld	s5,24(sp)
    800013dc:	6b42                	ld	s6,16(sp)
    800013de:	6ba2                	ld	s7,8(sp)
    800013e0:	6161                	addi	sp,sp,80
    800013e2:	8082                	ret
  return 0;
    800013e4:	4501                	li	a0,0
}
    800013e6:	8082                	ret

00000000800013e8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800013e8:	1141                	addi	sp,sp,-16
    800013ea:	e406                	sd	ra,8(sp)
    800013ec:	e022                	sd	s0,0(sp)
    800013ee:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800013f0:	4601                	li	a2,0
    800013f2:	ac9ff0ef          	jal	ra,80000eba <walk>
  if(pte == 0)
    800013f6:	c901                	beqz	a0,80001406 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800013f8:	611c                	ld	a5,0(a0)
    800013fa:	9bbd                	andi	a5,a5,-17
    800013fc:	e11c                	sd	a5,0(a0)
}
    800013fe:	60a2                	ld	ra,8(sp)
    80001400:	6402                	ld	s0,0(sp)
    80001402:	0141                	addi	sp,sp,16
    80001404:	8082                	ret
    panic("uvmclear");
    80001406:	00006517          	auipc	a0,0x6
    8000140a:	d5a50513          	addi	a0,a0,-678 # 80007160 <digits+0x128>
    8000140e:	b7aff0ef          	jal	ra,80000788 <panic>

0000000080001412 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001412:	c2cd                	beqz	a3,800014b4 <copyinstr+0xa2>
{
    80001414:	715d                	addi	sp,sp,-80
    80001416:	e486                	sd	ra,72(sp)
    80001418:	e0a2                	sd	s0,64(sp)
    8000141a:	fc26                	sd	s1,56(sp)
    8000141c:	f84a                	sd	s2,48(sp)
    8000141e:	f44e                	sd	s3,40(sp)
    80001420:	f052                	sd	s4,32(sp)
    80001422:	ec56                	sd	s5,24(sp)
    80001424:	e85a                	sd	s6,16(sp)
    80001426:	e45e                	sd	s7,8(sp)
    80001428:	0880                	addi	s0,sp,80
    8000142a:	8a2a                	mv	s4,a0
    8000142c:	8b2e                	mv	s6,a1
    8000142e:	8bb2                	mv	s7,a2
    80001430:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001432:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001434:	6985                	lui	s3,0x1
    80001436:	a02d                	j	80001460 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001438:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000143c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000143e:	37fd                	addiw	a5,a5,-1
    80001440:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
    srcva = va0 + PGSIZE;
    8000145a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000145e:	c4b9                	beqz	s1,800014ac <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80001460:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001464:	85ca                	mv	a1,s2
    80001466:	8552                	mv	a0,s4
    80001468:	aedff0ef          	jal	ra,80000f54 <walkaddr>
    if(pa0 == 0)
    8000146c:	c131                	beqz	a0,800014b0 <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    8000146e:	417906b3          	sub	a3,s2,s7
    80001472:	96ce                	add	a3,a3,s3
    80001474:	00d4f363          	bgeu	s1,a3,8000147a <copyinstr+0x68>
    80001478:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000147a:	955e                	add	a0,a0,s7
    8000147c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001480:	dee9                	beqz	a3,8000145a <copyinstr+0x48>
    80001482:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001484:	41650633          	sub	a2,a0,s6
    80001488:	fff48593          	addi	a1,s1,-1
    8000148c:	95da                	add	a1,a1,s6
    while(n > 0){
    8000148e:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001490:	00f60733          	add	a4,a2,a5
    80001494:	00074703          	lbu	a4,0(a4)
    80001498:	d345                	beqz	a4,80001438 <copyinstr+0x26>
        *dst = *p;
    8000149a:	00e78023          	sb	a4,0(a5)
      --max;
    8000149e:	40f584b3          	sub	s1,a1,a5
      dst++;
    800014a2:	0785                	addi	a5,a5,1
    while(n > 0){
    800014a4:	fed796e3          	bne	a5,a3,80001490 <copyinstr+0x7e>
      dst++;
    800014a8:	8b3e                	mv	s6,a5
    800014aa:	bf45                	j	8000145a <copyinstr+0x48>
    800014ac:	4781                	li	a5,0
    800014ae:	bf41                	j	8000143e <copyinstr+0x2c>
      return -1;
    800014b0:	557d                	li	a0,-1
    800014b2:	bf49                	j	80001444 <copyinstr+0x32>
  int got_null = 0;
    800014b4:	4781                	li	a5,0
  if(got_null){
    800014b6:	37fd                	addiw	a5,a5,-1
    800014b8:	0007851b          	sext.w	a0,a5
}
    800014bc:	8082                	ret

00000000800014be <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014be:	1141                	addi	sp,sp,-16
    800014c0:	e406                	sd	ra,8(sp)
    800014c2:	e022                	sd	s0,0(sp)
    800014c4:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014c6:	4601                	li	a2,0
    800014c8:	9f3ff0ef          	jal	ra,80000eba <walk>
  if (pte == 0) {
    800014cc:	c519                	beqz	a0,800014da <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800014ce:	6108                	ld	a0,0(a0)
    return 0;
    800014d0:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014d2:	60a2                	ld	ra,8(sp)
    800014d4:	6402                	ld	s0,0(sp)
    800014d6:	0141                	addi	sp,sp,16
    800014d8:	8082                	ret
    return 0;
    800014da:	4501                	li	a0,0
    800014dc:	bfdd                	j	800014d2 <ismapped+0x14>

00000000800014de <vmfault>:
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	89aa                	mv	s3,a0
    800014f0:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800014f2:	310000ef          	jal	ra,80001802 <myproc>
  if (va >= p->sz)
    800014f6:	653c                	ld	a5,72(a0)
    800014f8:	00f4ec63          	bltu	s1,a5,80001510 <vmfault+0x32>
    return 0;
    800014fc:	4981                	li	s3,0
}
    800014fe:	854e                	mv	a0,s3
    80001500:	70a2                	ld	ra,40(sp)
    80001502:	7402                	ld	s0,32(sp)
    80001504:	64e2                	ld	s1,24(sp)
    80001506:	6942                	ld	s2,16(sp)
    80001508:	69a2                	ld	s3,8(sp)
    8000150a:	6a02                	ld	s4,0(sp)
    8000150c:	6145                	addi	sp,sp,48
    8000150e:	8082                	ret
    80001510:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001512:	77fd                	lui	a5,0xfffff
    80001514:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001516:	85a6                	mv	a1,s1
    80001518:	854e                	mv	a0,s3
    8000151a:	fa5ff0ef          	jal	ra,800014be <ismapped>
    return 0;
    8000151e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001520:	fd79                	bnez	a0,800014fe <vmfault+0x20>
  mem = (uint64) kalloc();
    80001522:	d78ff0ef          	jal	ra,80000a9a <kalloc>
    80001526:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001528:	d979                	beqz	a0,800014fe <vmfault+0x20>
  mem = (uint64) kalloc();
    8000152a:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000152c:	6605                	lui	a2,0x1
    8000152e:	4581                	li	a1,0
    80001530:	f0eff0ef          	jal	ra,80000c3e <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001534:	4759                	li	a4,22
    80001536:	86d2                	mv	a3,s4
    80001538:	6605                	lui	a2,0x1
    8000153a:	85a6                	mv	a1,s1
    8000153c:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001540:	a53ff0ef          	jal	ra,80000f92 <mappages>
    80001544:	dd4d                	beqz	a0,800014fe <vmfault+0x20>
    kfree((void *)mem);
    80001546:	8552                	mv	a0,s4
    80001548:	c70ff0ef          	jal	ra,800009b8 <kfree>
    return 0;
    8000154c:	4981                	li	s3,0
    8000154e:	bf45                	j	800014fe <vmfault+0x20>

0000000080001550 <copyout>:
  while(len > 0){
    80001550:	cec1                	beqz	a3,800015e8 <copyout+0x98>
{
    80001552:	711d                	addi	sp,sp,-96
    80001554:	ec86                	sd	ra,88(sp)
    80001556:	e8a2                	sd	s0,80(sp)
    80001558:	e4a6                	sd	s1,72(sp)
    8000155a:	e0ca                	sd	s2,64(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f852                	sd	s4,48(sp)
    80001560:	f456                	sd	s5,40(sp)
    80001562:	f05a                	sd	s6,32(sp)
    80001564:	ec5e                	sd	s7,24(sp)
    80001566:	e862                	sd	s8,16(sp)
    80001568:	e466                	sd	s9,8(sp)
    8000156a:	e06a                	sd	s10,0(sp)
    8000156c:	1080                	addi	s0,sp,96
    8000156e:	8c2a                	mv	s8,a0
    80001570:	8b2e                	mv	s6,a1
    80001572:	8bb2                	mv	s7,a2
    80001574:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001576:	74fd                	lui	s1,0xfffff
    80001578:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000157a:	57fd                	li	a5,-1
    8000157c:	83e9                	srli	a5,a5,0x1a
    8000157e:	0697e763          	bltu	a5,s1,800015ec <copyout+0x9c>
    80001582:	6d05                	lui	s10,0x1
    80001584:	8cbe                	mv	s9,a5
    80001586:	a015                	j	800015aa <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001588:	409b0533          	sub	a0,s6,s1
    8000158c:	0009861b          	sext.w	a2,s3
    80001590:	85de                	mv	a1,s7
    80001592:	954a                	add	a0,a0,s2
    80001594:	f06ff0ef          	jal	ra,80000c9a <memmove>
    len -= n;
    80001598:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000159c:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000159e:	040a0363          	beqz	s4,800015e4 <copyout+0x94>
    if(va0 >= MAXVA)
    800015a2:	055ce763          	bltu	s9,s5,800015f0 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800015a6:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800015a8:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800015aa:	85a6                	mv	a1,s1
    800015ac:	8562                	mv	a0,s8
    800015ae:	9a7ff0ef          	jal	ra,80000f54 <walkaddr>
    800015b2:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800015b4:	e901                	bnez	a0,800015c4 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800015b6:	4601                	li	a2,0
    800015b8:	85a6                	mv	a1,s1
    800015ba:	8562                	mv	a0,s8
    800015bc:	f23ff0ef          	jal	ra,800014de <vmfault>
    800015c0:	892a                	mv	s2,a0
    800015c2:	c90d                	beqz	a0,800015f4 <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800015c4:	4601                	li	a2,0
    800015c6:	85a6                	mv	a1,s1
    800015c8:	8562                	mv	a0,s8
    800015ca:	8f1ff0ef          	jal	ra,80000eba <walk>
    if((*pte & PTE_W) == 0)
    800015ce:	611c                	ld	a5,0(a0)
    800015d0:	8b91                	andi	a5,a5,4
    800015d2:	c39d                	beqz	a5,800015f8 <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800015d4:	01a48ab3          	add	s5,s1,s10
    800015d8:	416a89b3          	sub	s3,s5,s6
    800015dc:	fb3a76e3          	bgeu	s4,s3,80001588 <copyout+0x38>
    800015e0:	89d2                	mv	s3,s4
    800015e2:	b75d                	j	80001588 <copyout+0x38>
  return 0;
    800015e4:	4501                	li	a0,0
    800015e6:	a811                	j	800015fa <copyout+0xaa>
    800015e8:	4501                	li	a0,0
}
    800015ea:	8082                	ret
      return -1;
    800015ec:	557d                	li	a0,-1
    800015ee:	a031                	j	800015fa <copyout+0xaa>
    800015f0:	557d                	li	a0,-1
    800015f2:	a021                	j	800015fa <copyout+0xaa>
        return -1;
    800015f4:	557d                	li	a0,-1
    800015f6:	a011                	j	800015fa <copyout+0xaa>
      return -1;
    800015f8:	557d                	li	a0,-1
}
    800015fa:	60e6                	ld	ra,88(sp)
    800015fc:	6446                	ld	s0,80(sp)
    800015fe:	64a6                	ld	s1,72(sp)
    80001600:	6906                	ld	s2,64(sp)
    80001602:	79e2                	ld	s3,56(sp)
    80001604:	7a42                	ld	s4,48(sp)
    80001606:	7aa2                	ld	s5,40(sp)
    80001608:	7b02                	ld	s6,32(sp)
    8000160a:	6be2                	ld	s7,24(sp)
    8000160c:	6c42                	ld	s8,16(sp)
    8000160e:	6ca2                	ld	s9,8(sp)
    80001610:	6d02                	ld	s10,0(sp)
    80001612:	6125                	addi	sp,sp,96
    80001614:	8082                	ret

0000000080001616 <copyin>:
  while(len > 0){
    80001616:	c6c9                	beqz	a3,800016a0 <copyin+0x8a>
{
    80001618:	715d                	addi	sp,sp,-80
    8000161a:	e486                	sd	ra,72(sp)
    8000161c:	e0a2                	sd	s0,64(sp)
    8000161e:	fc26                	sd	s1,56(sp)
    80001620:	f84a                	sd	s2,48(sp)
    80001622:	f44e                	sd	s3,40(sp)
    80001624:	f052                	sd	s4,32(sp)
    80001626:	ec56                	sd	s5,24(sp)
    80001628:	e85a                	sd	s6,16(sp)
    8000162a:	e45e                	sd	s7,8(sp)
    8000162c:	e062                	sd	s8,0(sp)
    8000162e:	0880                	addi	s0,sp,80
    80001630:	8baa                	mv	s7,a0
    80001632:	8aae                	mv	s5,a1
    80001634:	8932                	mv	s2,a2
    80001636:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001638:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000163a:	6b05                	lui	s6,0x1
    8000163c:	a035                	j	80001668 <copyin+0x52>
    8000163e:	412984b3          	sub	s1,s3,s2
    80001642:	94da                	add	s1,s1,s6
    80001644:	009a7363          	bgeu	s4,s1,8000164a <copyin+0x34>
    80001648:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000164a:	413905b3          	sub	a1,s2,s3
    8000164e:	0004861b          	sext.w	a2,s1
    80001652:	95aa                	add	a1,a1,a0
    80001654:	8556                	mv	a0,s5
    80001656:	e44ff0ef          	jal	ra,80000c9a <memmove>
    len -= n;
    8000165a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000165e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001660:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001664:	020a0163          	beqz	s4,80001686 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001668:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000166c:	85ce                	mv	a1,s3
    8000166e:	855e                	mv	a0,s7
    80001670:	8e5ff0ef          	jal	ra,80000f54 <walkaddr>
    if(pa0 == 0) {
    80001674:	f569                	bnez	a0,8000163e <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001676:	4601                	li	a2,0
    80001678:	85ce                	mv	a1,s3
    8000167a:	855e                	mv	a0,s7
    8000167c:	e63ff0ef          	jal	ra,800014de <vmfault>
    80001680:	fd5d                	bnez	a0,8000163e <copyin+0x28>
        return -1;
    80001682:	557d                	li	a0,-1
    80001684:	a011                	j	80001688 <copyin+0x72>
  return 0;
    80001686:	4501                	li	a0,0
}
    80001688:	60a6                	ld	ra,72(sp)
    8000168a:	6406                	ld	s0,64(sp)
    8000168c:	74e2                	ld	s1,56(sp)
    8000168e:	7942                	ld	s2,48(sp)
    80001690:	79a2                	ld	s3,40(sp)
    80001692:	7a02                	ld	s4,32(sp)
    80001694:	6ae2                	ld	s5,24(sp)
    80001696:	6b42                	ld	s6,16(sp)
    80001698:	6ba2                	ld	s7,8(sp)
    8000169a:	6c02                	ld	s8,0(sp)
    8000169c:	6161                	addi	sp,sp,80
    8000169e:	8082                	ret
  return 0;
    800016a0:	4501                	li	a0,0
}
    800016a2:	8082                	ret

00000000800016a4 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016a4:	7139                	addi	sp,sp,-64
    800016a6:	fc06                	sd	ra,56(sp)
    800016a8:	f822                	sd	s0,48(sp)
    800016aa:	f426                	sd	s1,40(sp)
    800016ac:	f04a                	sd	s2,32(sp)
    800016ae:	ec4e                	sd	s3,24(sp)
    800016b0:	e852                	sd	s4,16(sp)
    800016b2:	e456                	sd	s5,8(sp)
    800016b4:	e05a                	sd	s6,0(sp)
    800016b6:	0080                	addi	s0,sp,64
    800016b8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016ba:	0000e497          	auipc	s1,0xe
    800016be:	6ee48493          	addi	s1,s1,1774 # 8000fda8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016c2:	8b26                	mv	s6,s1
    800016c4:	00006a97          	auipc	s5,0x6
    800016c8:	93ca8a93          	addi	s5,s5,-1732 # 80007000 <etext>
    800016cc:	04000937          	lui	s2,0x4000
    800016d0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800016d2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016d4:	00014a17          	auipc	s4,0x14
    800016d8:	0d4a0a13          	addi	s4,s4,212 # 800157a8 <tickslock>
    char *pa = kalloc();
    800016dc:	bbeff0ef          	jal	ra,80000a9a <kalloc>
    800016e0:	862a                	mv	a2,a0
    if(pa == 0)
    800016e2:	c121                	beqz	a0,80001722 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016e4:	416485b3          	sub	a1,s1,s6
    800016e8:	858d                	srai	a1,a1,0x3
    800016ea:	000ab783          	ld	a5,0(s5)
    800016ee:	02f585b3          	mul	a1,a1,a5
    800016f2:	2585                	addiw	a1,a1,1
    800016f4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800016f8:	4719                	li	a4,6
    800016fa:	6685                	lui	a3,0x1
    800016fc:	40b905b3          	sub	a1,s2,a1
    80001700:	854e                	mv	a0,s3
    80001702:	941ff0ef          	jal	ra,80001042 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001706:	16848493          	addi	s1,s1,360
    8000170a:	fd4499e3          	bne	s1,s4,800016dc <proc_mapstacks+0x38>
  }
}
    8000170e:	70e2                	ld	ra,56(sp)
    80001710:	7442                	ld	s0,48(sp)
    80001712:	74a2                	ld	s1,40(sp)
    80001714:	7902                	ld	s2,32(sp)
    80001716:	69e2                	ld	s3,24(sp)
    80001718:	6a42                	ld	s4,16(sp)
    8000171a:	6aa2                	ld	s5,8(sp)
    8000171c:	6b02                	ld	s6,0(sp)
    8000171e:	6121                	addi	sp,sp,64
    80001720:	8082                	ret
      panic("kalloc");
    80001722:	00006517          	auipc	a0,0x6
    80001726:	a4e50513          	addi	a0,a0,-1458 # 80007170 <digits+0x138>
    8000172a:	85eff0ef          	jal	ra,80000788 <panic>

000000008000172e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000172e:	7139                	addi	sp,sp,-64
    80001730:	fc06                	sd	ra,56(sp)
    80001732:	f822                	sd	s0,48(sp)
    80001734:	f426                	sd	s1,40(sp)
    80001736:	f04a                	sd	s2,32(sp)
    80001738:	ec4e                	sd	s3,24(sp)
    8000173a:	e852                	sd	s4,16(sp)
    8000173c:	e456                	sd	s5,8(sp)
    8000173e:	e05a                	sd	s6,0(sp)
    80001740:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001742:	00006597          	auipc	a1,0x6
    80001746:	a3658593          	addi	a1,a1,-1482 # 80007178 <digits+0x140>
    8000174a:	0000e517          	auipc	a0,0xe
    8000174e:	22e50513          	addi	a0,a0,558 # 8000f978 <pid_lock>
    80001752:	b98ff0ef          	jal	ra,80000aea <initlock>
  initlock(&wait_lock, "wait_lock");
    80001756:	00006597          	auipc	a1,0x6
    8000175a:	a2a58593          	addi	a1,a1,-1494 # 80007180 <digits+0x148>
    8000175e:	0000e517          	auipc	a0,0xe
    80001762:	23250513          	addi	a0,a0,562 # 8000f990 <wait_lock>
    80001766:	b84ff0ef          	jal	ra,80000aea <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	0000e497          	auipc	s1,0xe
    8000176e:	63e48493          	addi	s1,s1,1598 # 8000fda8 <proc>
      initlock(&p->lock, "proc");
    80001772:	00006b17          	auipc	s6,0x6
    80001776:	a1eb0b13          	addi	s6,s6,-1506 # 80007190 <digits+0x158>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000177a:	8aa6                	mv	s5,s1
    8000177c:	00006a17          	auipc	s4,0x6
    80001780:	884a0a13          	addi	s4,s4,-1916 # 80007000 <etext>
    80001784:	04000937          	lui	s2,0x4000
    80001788:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000178a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000178c:	00014997          	auipc	s3,0x14
    80001790:	01c98993          	addi	s3,s3,28 # 800157a8 <tickslock>
      initlock(&p->lock, "proc");
    80001794:	85da                	mv	a1,s6
    80001796:	8526                	mv	a0,s1
    80001798:	b52ff0ef          	jal	ra,80000aea <initlock>
      p->state = UNUSED;
    8000179c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017a0:	415487b3          	sub	a5,s1,s5
    800017a4:	878d                	srai	a5,a5,0x3
    800017a6:	000a3703          	ld	a4,0(s4)
    800017aa:	02e787b3          	mul	a5,a5,a4
    800017ae:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde479>
    800017b0:	00d7979b          	slliw	a5,a5,0xd
    800017b4:	40f907b3          	sub	a5,s2,a5
    800017b8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	16848493          	addi	s1,s1,360
    800017be:	fd349be3          	bne	s1,s3,80001794 <procinit+0x66>
  }
}
    800017c2:	70e2                	ld	ra,56(sp)
    800017c4:	7442                	ld	s0,48(sp)
    800017c6:	74a2                	ld	s1,40(sp)
    800017c8:	7902                	ld	s2,32(sp)
    800017ca:	69e2                	ld	s3,24(sp)
    800017cc:	6a42                	ld	s4,16(sp)
    800017ce:	6aa2                	ld	s5,8(sp)
    800017d0:	6b02                	ld	s6,0(sp)
    800017d2:	6121                	addi	sp,sp,64
    800017d4:	8082                	ret

00000000800017d6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017d6:	1141                	addi	sp,sp,-16
    800017d8:	e422                	sd	s0,8(sp)
    800017da:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017dc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017de:	2501                	sext.w	a0,a0
    800017e0:	6422                	ld	s0,8(sp)
    800017e2:	0141                	addi	sp,sp,16
    800017e4:	8082                	ret

00000000800017e6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017e6:	1141                	addi	sp,sp,-16
    800017e8:	e422                	sd	s0,8(sp)
    800017ea:	0800                	addi	s0,sp,16
    800017ec:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800017ee:	2781                	sext.w	a5,a5
    800017f0:	079e                	slli	a5,a5,0x7
  return c;
}
    800017f2:	0000e517          	auipc	a0,0xe
    800017f6:	1b650513          	addi	a0,a0,438 # 8000f9a8 <cpus>
    800017fa:	953e                	add	a0,a0,a5
    800017fc:	6422                	ld	s0,8(sp)
    800017fe:	0141                	addi	sp,sp,16
    80001800:	8082                	ret

0000000080001802 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001802:	1101                	addi	sp,sp,-32
    80001804:	ec06                	sd	ra,24(sp)
    80001806:	e822                	sd	s0,16(sp)
    80001808:	e426                	sd	s1,8(sp)
    8000180a:	1000                	addi	s0,sp,32
  push_off();
    8000180c:	b1eff0ef          	jal	ra,80000b2a <push_off>
    80001810:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001812:	2781                	sext.w	a5,a5
    80001814:	079e                	slli	a5,a5,0x7
    80001816:	0000e717          	auipc	a4,0xe
    8000181a:	16270713          	addi	a4,a4,354 # 8000f978 <pid_lock>
    8000181e:	97ba                	add	a5,a5,a4
    80001820:	7b84                	ld	s1,48(a5)
  pop_off();
    80001822:	b8cff0ef          	jal	ra,80000bae <pop_off>
  return p;
}
    80001826:	8526                	mv	a0,s1
    80001828:	60e2                	ld	ra,24(sp)
    8000182a:	6442                	ld	s0,16(sp)
    8000182c:	64a2                	ld	s1,8(sp)
    8000182e:	6105                	addi	sp,sp,32
    80001830:	8082                	ret

0000000080001832 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001832:	7179                	addi	sp,sp,-48
    80001834:	f406                	sd	ra,40(sp)
    80001836:	f022                	sd	s0,32(sp)
    80001838:	ec26                	sd	s1,24(sp)
    8000183a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000183c:	fc7ff0ef          	jal	ra,80001802 <myproc>
    80001840:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001842:	bc0ff0ef          	jal	ra,80000c02 <release>

  if (first) {
    80001846:	00006797          	auipc	a5,0x6
    8000184a:	fda7a783          	lw	a5,-38(a5) # 80007820 <first.1>
    8000184e:	cf8d                	beqz	a5,80001888 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001850:	4505                	li	a0,1
    80001852:	38f010ef          	jal	ra,800033e0 <fsinit>

    first = 0;
    80001856:	00006797          	auipc	a5,0x6
    8000185a:	fc07a523          	sw	zero,-54(a5) # 80007820 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000185e:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001862:	00006517          	auipc	a0,0x6
    80001866:	93650513          	addi	a0,a0,-1738 # 80007198 <digits+0x160>
    8000186a:	fca43823          	sd	a0,-48(s0)
    8000186e:	fc043c23          	sd	zero,-40(s0)
    80001872:	fd040593          	addi	a1,s0,-48
    80001876:	419020ef          	jal	ra,8000448e <kexec>
    8000187a:	6cbc                	ld	a5,88(s1)
    8000187c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000187e:	6cbc                	ld	a5,88(s1)
    80001880:	7bb8                	ld	a4,112(a5)
    80001882:	57fd                	li	a5,-1
    80001884:	02f70d63          	beq	a4,a5,800018be <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001888:	2bd000ef          	jal	ra,80002344 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000188c:	68a8                	ld	a0,80(s1)
    8000188e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001890:	04000737          	lui	a4,0x4000
    80001894:	00005797          	auipc	a5,0x5
    80001898:	80878793          	addi	a5,a5,-2040 # 8000609c <userret>
    8000189c:	00004697          	auipc	a3,0x4
    800018a0:	76468693          	addi	a3,a3,1892 # 80006000 <_trampoline>
    800018a4:	8f95                	sub	a5,a5,a3
    800018a6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800018a8:	0732                	slli	a4,a4,0xc
    800018aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018ac:	577d                	li	a4,-1
    800018ae:	177e                	slli	a4,a4,0x3f
    800018b0:	8d59                	or	a0,a0,a4
    800018b2:	9782                	jalr	a5
}
    800018b4:	70a2                	ld	ra,40(sp)
    800018b6:	7402                	ld	s0,32(sp)
    800018b8:	64e2                	ld	s1,24(sp)
    800018ba:	6145                	addi	sp,sp,48
    800018bc:	8082                	ret
      panic("exec");
    800018be:	00006517          	auipc	a0,0x6
    800018c2:	8e250513          	addi	a0,a0,-1822 # 800071a0 <digits+0x168>
    800018c6:	ec3fe0ef          	jal	ra,80000788 <panic>

00000000800018ca <allocpid>:
{
    800018ca:	1101                	addi	sp,sp,-32
    800018cc:	ec06                	sd	ra,24(sp)
    800018ce:	e822                	sd	s0,16(sp)
    800018d0:	e426                	sd	s1,8(sp)
    800018d2:	e04a                	sd	s2,0(sp)
    800018d4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018d6:	0000e917          	auipc	s2,0xe
    800018da:	0a290913          	addi	s2,s2,162 # 8000f978 <pid_lock>
    800018de:	854a                	mv	a0,s2
    800018e0:	a8aff0ef          	jal	ra,80000b6a <acquire>
  pid = nextpid;
    800018e4:	00006797          	auipc	a5,0x6
    800018e8:	f4078793          	addi	a5,a5,-192 # 80007824 <nextpid>
    800018ec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018ee:	0014871b          	addiw	a4,s1,1
    800018f2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018f4:	854a                	mv	a0,s2
    800018f6:	b0cff0ef          	jal	ra,80000c02 <release>
}
    800018fa:	8526                	mv	a0,s1
    800018fc:	60e2                	ld	ra,24(sp)
    800018fe:	6442                	ld	s0,16(sp)
    80001900:	64a2                	ld	s1,8(sp)
    80001902:	6902                	ld	s2,0(sp)
    80001904:	6105                	addi	sp,sp,32
    80001906:	8082                	ret

0000000080001908 <proc_pagetable>:
{
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	e426                	sd	s1,8(sp)
    80001910:	e04a                	sd	s2,0(sp)
    80001912:	1000                	addi	s0,sp,32
    80001914:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001916:	823ff0ef          	jal	ra,80001138 <uvmcreate>
    8000191a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000191c:	cd05                	beqz	a0,80001954 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000191e:	4729                	li	a4,10
    80001920:	00004697          	auipc	a3,0x4
    80001924:	6e068693          	addi	a3,a3,1760 # 80006000 <_trampoline>
    80001928:	6605                	lui	a2,0x1
    8000192a:	040005b7          	lui	a1,0x4000
    8000192e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	05b2                	slli	a1,a1,0xc
    80001932:	e60ff0ef          	jal	ra,80000f92 <mappages>
    80001936:	02054663          	bltz	a0,80001962 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    8000193a:	4719                	li	a4,6
    8000193c:	05893683          	ld	a3,88(s2)
    80001940:	6605                	lui	a2,0x1
    80001942:	020005b7          	lui	a1,0x2000
    80001946:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001948:	05b6                	slli	a1,a1,0xd
    8000194a:	8526                	mv	a0,s1
    8000194c:	e46ff0ef          	jal	ra,80000f92 <mappages>
    80001950:	00054f63          	bltz	a0,8000196e <proc_pagetable+0x66>
}
    80001954:	8526                	mv	a0,s1
    80001956:	60e2                	ld	ra,24(sp)
    80001958:	6442                	ld	s0,16(sp)
    8000195a:	64a2                	ld	s1,8(sp)
    8000195c:	6902                	ld	s2,0(sp)
    8000195e:	6105                	addi	sp,sp,32
    80001960:	8082                	ret
    uvmfree(pagetable, 0);
    80001962:	4581                	li	a1,0
    80001964:	8526                	mv	a0,s1
    80001966:	9b3ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000196a:	4481                	li	s1,0
    8000196c:	b7e5                	j	80001954 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000196e:	4681                	li	a3,0
    80001970:	4605                	li	a2,1
    80001972:	040005b7          	lui	a1,0x4000
    80001976:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001978:	05b2                	slli	a1,a1,0xc
    8000197a:	8526                	mv	a0,s1
    8000197c:	fe2ff0ef          	jal	ra,8000115e <uvmunmap>
    uvmfree(pagetable, 0);
    80001980:	4581                	li	a1,0
    80001982:	8526                	mv	a0,s1
    80001984:	995ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001988:	4481                	li	s1,0
    8000198a:	b7e9                	j	80001954 <proc_pagetable+0x4c>

000000008000198c <proc_freepagetable>:
{
    8000198c:	1101                	addi	sp,sp,-32
    8000198e:	ec06                	sd	ra,24(sp)
    80001990:	e822                	sd	s0,16(sp)
    80001992:	e426                	sd	s1,8(sp)
    80001994:	e04a                	sd	s2,0(sp)
    80001996:	1000                	addi	s0,sp,32
    80001998:	84aa                	mv	s1,a0
    8000199a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000199c:	4681                	li	a3,0
    8000199e:	4605                	li	a2,1
    800019a0:	040005b7          	lui	a1,0x4000
    800019a4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019a6:	05b2                	slli	a1,a1,0xc
    800019a8:	fb6ff0ef          	jal	ra,8000115e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019ac:	4681                	li	a3,0
    800019ae:	4605                	li	a2,1
    800019b0:	020005b7          	lui	a1,0x2000
    800019b4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019b6:	05b6                	slli	a1,a1,0xd
    800019b8:	8526                	mv	a0,s1
    800019ba:	fa4ff0ef          	jal	ra,8000115e <uvmunmap>
  uvmfree(pagetable, sz);
    800019be:	85ca                	mv	a1,s2
    800019c0:	8526                	mv	a0,s1
    800019c2:	957ff0ef          	jal	ra,80001318 <uvmfree>
}
    800019c6:	60e2                	ld	ra,24(sp)
    800019c8:	6442                	ld	s0,16(sp)
    800019ca:	64a2                	ld	s1,8(sp)
    800019cc:	6902                	ld	s2,0(sp)
    800019ce:	6105                	addi	sp,sp,32
    800019d0:	8082                	ret

00000000800019d2 <freeproc>:
{
    800019d2:	1101                	addi	sp,sp,-32
    800019d4:	ec06                	sd	ra,24(sp)
    800019d6:	e822                	sd	s0,16(sp)
    800019d8:	e426                	sd	s1,8(sp)
    800019da:	1000                	addi	s0,sp,32
    800019dc:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019de:	6d28                	ld	a0,88(a0)
    800019e0:	c119                	beqz	a0,800019e6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019e2:	fd7fe0ef          	jal	ra,800009b8 <kfree>
  p->trapframe = 0;
    800019e6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019ea:	68a8                	ld	a0,80(s1)
    800019ec:	c501                	beqz	a0,800019f4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019ee:	64ac                	ld	a1,72(s1)
    800019f0:	f9dff0ef          	jal	ra,8000198c <proc_freepagetable>
  p->pagetable = 0;
    800019f4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800019f8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800019fc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a00:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a04:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a08:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a0c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a10:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a14:	0004ac23          	sw	zero,24(s1)
}
    80001a18:	60e2                	ld	ra,24(sp)
    80001a1a:	6442                	ld	s0,16(sp)
    80001a1c:	64a2                	ld	s1,8(sp)
    80001a1e:	6105                	addi	sp,sp,32
    80001a20:	8082                	ret

0000000080001a22 <allocproc>:
{
    80001a22:	1101                	addi	sp,sp,-32
    80001a24:	ec06                	sd	ra,24(sp)
    80001a26:	e822                	sd	s0,16(sp)
    80001a28:	e426                	sd	s1,8(sp)
    80001a2a:	e04a                	sd	s2,0(sp)
    80001a2c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a2e:	0000e497          	auipc	s1,0xe
    80001a32:	37a48493          	addi	s1,s1,890 # 8000fda8 <proc>
    80001a36:	00014917          	auipc	s2,0x14
    80001a3a:	d7290913          	addi	s2,s2,-654 # 800157a8 <tickslock>
    acquire(&p->lock);
    80001a3e:	8526                	mv	a0,s1
    80001a40:	92aff0ef          	jal	ra,80000b6a <acquire>
    if(p->state == UNUSED) {
    80001a44:	4c9c                	lw	a5,24(s1)
    80001a46:	cb91                	beqz	a5,80001a5a <allocproc+0x38>
      release(&p->lock);
    80001a48:	8526                	mv	a0,s1
    80001a4a:	9b8ff0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a4e:	16848493          	addi	s1,s1,360
    80001a52:	ff2496e3          	bne	s1,s2,80001a3e <allocproc+0x1c>
  return 0;
    80001a56:	4481                	li	s1,0
    80001a58:	a089                	j	80001a9a <allocproc+0x78>
  p->pid = allocpid();
    80001a5a:	e71ff0ef          	jal	ra,800018ca <allocpid>
    80001a5e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a60:	4785                	li	a5,1
    80001a62:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a64:	836ff0ef          	jal	ra,80000a9a <kalloc>
    80001a68:	892a                	mv	s2,a0
    80001a6a:	eca8                	sd	a0,88(s1)
    80001a6c:	cd15                	beqz	a0,80001aa8 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001a6e:	8526                	mv	a0,s1
    80001a70:	e99ff0ef          	jal	ra,80001908 <proc_pagetable>
    80001a74:	892a                	mv	s2,a0
    80001a76:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a78:	c121                	beqz	a0,80001ab8 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001a7a:	07000613          	li	a2,112
    80001a7e:	4581                	li	a1,0
    80001a80:	06048513          	addi	a0,s1,96
    80001a84:	9baff0ef          	jal	ra,80000c3e <memset>
  p->context.ra = (uint64)forkret;
    80001a88:	00000797          	auipc	a5,0x0
    80001a8c:	daa78793          	addi	a5,a5,-598 # 80001832 <forkret>
    80001a90:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001a92:	60bc                	ld	a5,64(s1)
    80001a94:	6705                	lui	a4,0x1
    80001a96:	97ba                	add	a5,a5,a4
    80001a98:	f4bc                	sd	a5,104(s1)
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6902                	ld	s2,0(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    freeproc(p);
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	f29ff0ef          	jal	ra,800019d2 <freeproc>
    release(&p->lock);
    80001aae:	8526                	mv	a0,s1
    80001ab0:	952ff0ef          	jal	ra,80000c02 <release>
    return 0;
    80001ab4:	84ca                	mv	s1,s2
    80001ab6:	b7d5                	j	80001a9a <allocproc+0x78>
    freeproc(p);
    80001ab8:	8526                	mv	a0,s1
    80001aba:	f19ff0ef          	jal	ra,800019d2 <freeproc>
    release(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	942ff0ef          	jal	ra,80000c02 <release>
    return 0;
    80001ac4:	84ca                	mv	s1,s2
    80001ac6:	bfd1                	j	80001a9a <allocproc+0x78>

0000000080001ac8 <userinit>:
{
    80001ac8:	1101                	addi	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ad2:	f51ff0ef          	jal	ra,80001a22 <allocproc>
    80001ad6:	84aa                	mv	s1,a0
  initproc = p;
    80001ad8:	00006797          	auipc	a5,0x6
    80001adc:	d8a7bc23          	sd	a0,-616(a5) # 80007870 <initproc>
  p->cwd = namei("/");
    80001ae0:	00005517          	auipc	a0,0x5
    80001ae4:	6c850513          	addi	a0,a0,1736 # 800071a8 <digits+0x170>
    80001ae8:	5fd010ef          	jal	ra,800038e4 <namei>
    80001aec:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001af0:	478d                	li	a5,3
    80001af2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001af4:	8526                	mv	a0,s1
    80001af6:	90cff0ef          	jal	ra,80000c02 <release>
}
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6105                	addi	sp,sp,32
    80001b02:	8082                	ret

0000000080001b04 <growproc>:
{
    80001b04:	1101                	addi	sp,sp,-32
    80001b06:	ec06                	sd	ra,24(sp)
    80001b08:	e822                	sd	s0,16(sp)
    80001b0a:	e426                	sd	s1,8(sp)
    80001b0c:	e04a                	sd	s2,0(sp)
    80001b0e:	1000                	addi	s0,sp,32
    80001b10:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b12:	cf1ff0ef          	jal	ra,80001802 <myproc>
    80001b16:	892a                	mv	s2,a0
  sz = p->sz;
    80001b18:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b1a:	02905963          	blez	s1,80001b4c <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001b1e:	00b48633          	add	a2,s1,a1
    80001b22:	020007b7          	lui	a5,0x2000
    80001b26:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001b28:	07b6                	slli	a5,a5,0xd
    80001b2a:	02c7ea63          	bltu	a5,a2,80001b5e <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b2e:	4691                	li	a3,4
    80001b30:	6928                	ld	a0,80(a0)
    80001b32:	eecff0ef          	jal	ra,8000121e <uvmalloc>
    80001b36:	85aa                	mv	a1,a0
    80001b38:	c50d                	beqz	a0,80001b62 <growproc+0x5e>
  p->sz = sz;
    80001b3a:	04b93423          	sd	a1,72(s2)
  return 0;
    80001b3e:	4501                	li	a0,0
}
    80001b40:	60e2                	ld	ra,24(sp)
    80001b42:	6442                	ld	s0,16(sp)
    80001b44:	64a2                	ld	s1,8(sp)
    80001b46:	6902                	ld	s2,0(sp)
    80001b48:	6105                	addi	sp,sp,32
    80001b4a:	8082                	ret
  } else if(n < 0){
    80001b4c:	fe04d7e3          	bgez	s1,80001b3a <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b50:	00b48633          	add	a2,s1,a1
    80001b54:	6928                	ld	a0,80(a0)
    80001b56:	e84ff0ef          	jal	ra,800011da <uvmdealloc>
    80001b5a:	85aa                	mv	a1,a0
    80001b5c:	bff9                	j	80001b3a <growproc+0x36>
      return -1;
    80001b5e:	557d                	li	a0,-1
    80001b60:	b7c5                	j	80001b40 <growproc+0x3c>
      return -1;
    80001b62:	557d                	li	a0,-1
    80001b64:	bff1                	j	80001b40 <growproc+0x3c>

0000000080001b66 <kfork>:
{
    80001b66:	7139                	addi	sp,sp,-64
    80001b68:	fc06                	sd	ra,56(sp)
    80001b6a:	f822                	sd	s0,48(sp)
    80001b6c:	f426                	sd	s1,40(sp)
    80001b6e:	f04a                	sd	s2,32(sp)
    80001b70:	ec4e                	sd	s3,24(sp)
    80001b72:	e852                	sd	s4,16(sp)
    80001b74:	e456                	sd	s5,8(sp)
    80001b76:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b78:	c8bff0ef          	jal	ra,80001802 <myproc>
    80001b7c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b7e:	ea5ff0ef          	jal	ra,80001a22 <allocproc>
    80001b82:	0e050663          	beqz	a0,80001c6e <kfork+0x108>
    80001b86:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001b88:	048ab603          	ld	a2,72(s5)
    80001b8c:	692c                	ld	a1,80(a0)
    80001b8e:	050ab503          	ld	a0,80(s5)
    80001b92:	fb8ff0ef          	jal	ra,8000134a <uvmcopy>
    80001b96:	04054863          	bltz	a0,80001be6 <kfork+0x80>
  np->sz = p->sz;
    80001b9a:	048ab783          	ld	a5,72(s5)
    80001b9e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ba2:	058ab683          	ld	a3,88(s5)
    80001ba6:	87b6                	mv	a5,a3
    80001ba8:	058a3703          	ld	a4,88(s4)
    80001bac:	12068693          	addi	a3,a3,288
    80001bb0:	0007b803          	ld	a6,0(a5)
    80001bb4:	6788                	ld	a0,8(a5)
    80001bb6:	6b8c                	ld	a1,16(a5)
    80001bb8:	6f90                	ld	a2,24(a5)
    80001bba:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001bbe:	e708                	sd	a0,8(a4)
    80001bc0:	eb0c                	sd	a1,16(a4)
    80001bc2:	ef10                	sd	a2,24(a4)
    80001bc4:	02078793          	addi	a5,a5,32
    80001bc8:	02070713          	addi	a4,a4,32
    80001bcc:	fed792e3          	bne	a5,a3,80001bb0 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001bd0:	058a3783          	ld	a5,88(s4)
    80001bd4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001bd8:	0d0a8493          	addi	s1,s5,208
    80001bdc:	0d0a0913          	addi	s2,s4,208
    80001be0:	150a8993          	addi	s3,s5,336
    80001be4:	a829                	j	80001bfe <kfork+0x98>
    freeproc(np);
    80001be6:	8552                	mv	a0,s4
    80001be8:	debff0ef          	jal	ra,800019d2 <freeproc>
    release(&np->lock);
    80001bec:	8552                	mv	a0,s4
    80001bee:	814ff0ef          	jal	ra,80000c02 <release>
    return -1;
    80001bf2:	597d                	li	s2,-1
    80001bf4:	a09d                	j	80001c5a <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001bf6:	04a1                	addi	s1,s1,8
    80001bf8:	0921                	addi	s2,s2,8
    80001bfa:	01348963          	beq	s1,s3,80001c0c <kfork+0xa6>
    if(p->ofile[i])
    80001bfe:	6088                	ld	a0,0(s1)
    80001c00:	d97d                	beqz	a0,80001bf6 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c02:	29a020ef          	jal	ra,80003e9c <filedup>
    80001c06:	00a93023          	sd	a0,0(s2)
    80001c0a:	b7f5                	j	80001bf6 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001c0c:	150ab503          	ld	a0,336(s5)
    80001c10:	4aa010ef          	jal	ra,800030ba <idup>
    80001c14:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c18:	4641                	li	a2,16
    80001c1a:	158a8593          	addi	a1,s5,344
    80001c1e:	158a0513          	addi	a0,s4,344
    80001c22:	962ff0ef          	jal	ra,80000d84 <safestrcpy>
  pid = np->pid;
    80001c26:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c2a:	8552                	mv	a0,s4
    80001c2c:	fd7fe0ef          	jal	ra,80000c02 <release>
  acquire(&wait_lock);
    80001c30:	0000e497          	auipc	s1,0xe
    80001c34:	d6048493          	addi	s1,s1,-672 # 8000f990 <wait_lock>
    80001c38:	8526                	mv	a0,s1
    80001c3a:	f31fe0ef          	jal	ra,80000b6a <acquire>
  np->parent = p;
    80001c3e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c42:	8526                	mv	a0,s1
    80001c44:	fbffe0ef          	jal	ra,80000c02 <release>
  acquire(&np->lock);
    80001c48:	8552                	mv	a0,s4
    80001c4a:	f21fe0ef          	jal	ra,80000b6a <acquire>
  np->state = RUNNABLE;
    80001c4e:	478d                	li	a5,3
    80001c50:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c54:	8552                	mv	a0,s4
    80001c56:	fadfe0ef          	jal	ra,80000c02 <release>
}
    80001c5a:	854a                	mv	a0,s2
    80001c5c:	70e2                	ld	ra,56(sp)
    80001c5e:	7442                	ld	s0,48(sp)
    80001c60:	74a2                	ld	s1,40(sp)
    80001c62:	7902                	ld	s2,32(sp)
    80001c64:	69e2                	ld	s3,24(sp)
    80001c66:	6a42                	ld	s4,16(sp)
    80001c68:	6aa2                	ld	s5,8(sp)
    80001c6a:	6121                	addi	sp,sp,64
    80001c6c:	8082                	ret
    return -1;
    80001c6e:	597d                	li	s2,-1
    80001c70:	b7ed                	j	80001c5a <kfork+0xf4>

0000000080001c72 <scheduler>:
{
    80001c72:	715d                	addi	sp,sp,-80
    80001c74:	e486                	sd	ra,72(sp)
    80001c76:	e0a2                	sd	s0,64(sp)
    80001c78:	fc26                	sd	s1,56(sp)
    80001c7a:	f84a                	sd	s2,48(sp)
    80001c7c:	f44e                	sd	s3,40(sp)
    80001c7e:	f052                	sd	s4,32(sp)
    80001c80:	ec56                	sd	s5,24(sp)
    80001c82:	e85a                	sd	s6,16(sp)
    80001c84:	e45e                	sd	s7,8(sp)
    80001c86:	e062                	sd	s8,0(sp)
    80001c88:	0880                	addi	s0,sp,80
    80001c8a:	8792                	mv	a5,tp
  int id = r_tp();
    80001c8c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c8e:	00779b13          	slli	s6,a5,0x7
    80001c92:	0000e717          	auipc	a4,0xe
    80001c96:	ce670713          	addi	a4,a4,-794 # 8000f978 <pid_lock>
    80001c9a:	975a                	add	a4,a4,s6
    80001c9c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ca0:	0000e717          	auipc	a4,0xe
    80001ca4:	d1070713          	addi	a4,a4,-752 # 8000f9b0 <cpus+0x8>
    80001ca8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001caa:	4c11                	li	s8,4
        c->proc = p;
    80001cac:	079e                	slli	a5,a5,0x7
    80001cae:	0000ea17          	auipc	s4,0xe
    80001cb2:	ccaa0a13          	addi	s4,s4,-822 # 8000f978 <pid_lock>
    80001cb6:	9a3e                	add	s4,s4,a5
        found = 1;
    80001cb8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cba:	00014997          	auipc	s3,0x14
    80001cbe:	aee98993          	addi	s3,s3,-1298 # 800157a8 <tickslock>
    80001cc2:	a83d                	j	80001d00 <scheduler+0x8e>
      release(&p->lock);
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	f3dfe0ef          	jal	ra,80000c02 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cca:	16848493          	addi	s1,s1,360
    80001cce:	03348563          	beq	s1,s3,80001cf8 <scheduler+0x86>
      acquire(&p->lock);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	e97fe0ef          	jal	ra,80000b6a <acquire>
      if(p->state == RUNNABLE) {
    80001cd8:	4c9c                	lw	a5,24(s1)
    80001cda:	ff2795e3          	bne	a5,s2,80001cc4 <scheduler+0x52>
        p->state = RUNNING;
    80001cde:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ce2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001ce6:	06048593          	addi	a1,s1,96
    80001cea:	855a                	mv	a0,s6
    80001cec:	5b2000ef          	jal	ra,8000229e <swtch>
        c->proc = 0;
    80001cf0:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001cf4:	8ade                	mv	s5,s7
    80001cf6:	b7f9                	j	80001cc4 <scheduler+0x52>
    if(found == 0) {
    80001cf8:	000a9463          	bnez	s5,80001d00 <scheduler+0x8e>
      asm volatile("wfi");
    80001cfc:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d04:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d08:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001d10:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d12:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001d16:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d18:	0000e497          	auipc	s1,0xe
    80001d1c:	09048493          	addi	s1,s1,144 # 8000fda8 <proc>
      if(p->state == RUNNABLE) {
    80001d20:	490d                	li	s2,3
    80001d22:	bf45                	j	80001cd2 <scheduler+0x60>

0000000080001d24 <sched>:
{
    80001d24:	7179                	addi	sp,sp,-48
    80001d26:	f406                	sd	ra,40(sp)
    80001d28:	f022                	sd	s0,32(sp)
    80001d2a:	ec26                	sd	s1,24(sp)
    80001d2c:	e84a                	sd	s2,16(sp)
    80001d2e:	e44e                	sd	s3,8(sp)
    80001d30:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d32:	ad1ff0ef          	jal	ra,80001802 <myproc>
    80001d36:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d38:	dc9fe0ef          	jal	ra,80000b00 <holding>
    80001d3c:	c92d                	beqz	a0,80001dae <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d3e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d40:	2781                	sext.w	a5,a5
    80001d42:	079e                	slli	a5,a5,0x7
    80001d44:	0000e717          	auipc	a4,0xe
    80001d48:	c3470713          	addi	a4,a4,-972 # 8000f978 <pid_lock>
    80001d4c:	97ba                	add	a5,a5,a4
    80001d4e:	0a87a703          	lw	a4,168(a5)
    80001d52:	4785                	li	a5,1
    80001d54:	06f71363          	bne	a4,a5,80001dba <sched+0x96>
  if(p->state == RUNNING)
    80001d58:	4c98                	lw	a4,24(s1)
    80001d5a:	4791                	li	a5,4
    80001d5c:	06f70563          	beq	a4,a5,80001dc6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d60:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d64:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d66:	e7b5                	bnez	a5,80001dd2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d68:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d6a:	0000e917          	auipc	s2,0xe
    80001d6e:	c0e90913          	addi	s2,s2,-1010 # 8000f978 <pid_lock>
    80001d72:	2781                	sext.w	a5,a5
    80001d74:	079e                	slli	a5,a5,0x7
    80001d76:	97ca                	add	a5,a5,s2
    80001d78:	0ac7a983          	lw	s3,172(a5)
    80001d7c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001d7e:	2781                	sext.w	a5,a5
    80001d80:	079e                	slli	a5,a5,0x7
    80001d82:	0000e597          	auipc	a1,0xe
    80001d86:	c2e58593          	addi	a1,a1,-978 # 8000f9b0 <cpus+0x8>
    80001d8a:	95be                	add	a1,a1,a5
    80001d8c:	06048513          	addi	a0,s1,96
    80001d90:	50e000ef          	jal	ra,8000229e <swtch>
    80001d94:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001d96:	2781                	sext.w	a5,a5
    80001d98:	079e                	slli	a5,a5,0x7
    80001d9a:	993e                	add	s2,s2,a5
    80001d9c:	0b392623          	sw	s3,172(s2)
}
    80001da0:	70a2                	ld	ra,40(sp)
    80001da2:	7402                	ld	s0,32(sp)
    80001da4:	64e2                	ld	s1,24(sp)
    80001da6:	6942                	ld	s2,16(sp)
    80001da8:	69a2                	ld	s3,8(sp)
    80001daa:	6145                	addi	sp,sp,48
    80001dac:	8082                	ret
    panic("sched p->lock");
    80001dae:	00005517          	auipc	a0,0x5
    80001db2:	40250513          	addi	a0,a0,1026 # 800071b0 <digits+0x178>
    80001db6:	9d3fe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    80001dba:	00005517          	auipc	a0,0x5
    80001dbe:	40650513          	addi	a0,a0,1030 # 800071c0 <digits+0x188>
    80001dc2:	9c7fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    80001dc6:	00005517          	auipc	a0,0x5
    80001dca:	40a50513          	addi	a0,a0,1034 # 800071d0 <digits+0x198>
    80001dce:	9bbfe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80001dd2:	00005517          	auipc	a0,0x5
    80001dd6:	40e50513          	addi	a0,a0,1038 # 800071e0 <digits+0x1a8>
    80001dda:	9affe0ef          	jal	ra,80000788 <panic>

0000000080001dde <yield>:
{
    80001dde:	1101                	addi	sp,sp,-32
    80001de0:	ec06                	sd	ra,24(sp)
    80001de2:	e822                	sd	s0,16(sp)
    80001de4:	e426                	sd	s1,8(sp)
    80001de6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001de8:	a1bff0ef          	jal	ra,80001802 <myproc>
    80001dec:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001dee:	d7dfe0ef          	jal	ra,80000b6a <acquire>
  p->state = RUNNABLE;
    80001df2:	478d                	li	a5,3
    80001df4:	cc9c                	sw	a5,24(s1)
  sched();
    80001df6:	f2fff0ef          	jal	ra,80001d24 <sched>
  release(&p->lock);
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	e07fe0ef          	jal	ra,80000c02 <release>
}
    80001e00:	60e2                	ld	ra,24(sp)
    80001e02:	6442                	ld	s0,16(sp)
    80001e04:	64a2                	ld	s1,8(sp)
    80001e06:	6105                	addi	sp,sp,32
    80001e08:	8082                	ret

0000000080001e0a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001e0a:	7179                	addi	sp,sp,-48
    80001e0c:	f406                	sd	ra,40(sp)
    80001e0e:	f022                	sd	s0,32(sp)
    80001e10:	ec26                	sd	s1,24(sp)
    80001e12:	e84a                	sd	s2,16(sp)
    80001e14:	e44e                	sd	s3,8(sp)
    80001e16:	1800                	addi	s0,sp,48
    80001e18:	89aa                	mv	s3,a0
    80001e1a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e1c:	9e7ff0ef          	jal	ra,80001802 <myproc>
    80001e20:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e22:	d49fe0ef          	jal	ra,80000b6a <acquire>
  release(lk);
    80001e26:	854a                	mv	a0,s2
    80001e28:	ddbfe0ef          	jal	ra,80000c02 <release>

  // Go to sleep.
  p->chan = chan;
    80001e2c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e30:	4789                	li	a5,2
    80001e32:	cc9c                	sw	a5,24(s1)

  sched();
    80001e34:	ef1ff0ef          	jal	ra,80001d24 <sched>

  // Tidy up.
  p->chan = 0;
    80001e38:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	dc5fe0ef          	jal	ra,80000c02 <release>
  acquire(lk);
    80001e42:	854a                	mv	a0,s2
    80001e44:	d27fe0ef          	jal	ra,80000b6a <acquire>
}
    80001e48:	70a2                	ld	ra,40(sp)
    80001e4a:	7402                	ld	s0,32(sp)
    80001e4c:	64e2                	ld	s1,24(sp)
    80001e4e:	6942                	ld	s2,16(sp)
    80001e50:	69a2                	ld	s3,8(sp)
    80001e52:	6145                	addi	sp,sp,48
    80001e54:	8082                	ret

0000000080001e56 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001e56:	7139                	addi	sp,sp,-64
    80001e58:	fc06                	sd	ra,56(sp)
    80001e5a:	f822                	sd	s0,48(sp)
    80001e5c:	f426                	sd	s1,40(sp)
    80001e5e:	f04a                	sd	s2,32(sp)
    80001e60:	ec4e                	sd	s3,24(sp)
    80001e62:	e852                	sd	s4,16(sp)
    80001e64:	e456                	sd	s5,8(sp)
    80001e66:	0080                	addi	s0,sp,64
    80001e68:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001e6a:	0000e497          	auipc	s1,0xe
    80001e6e:	f3e48493          	addi	s1,s1,-194 # 8000fda8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001e72:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001e74:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e76:	00014917          	auipc	s2,0x14
    80001e7a:	93290913          	addi	s2,s2,-1742 # 800157a8 <tickslock>
    80001e7e:	a801                	j	80001e8e <wakeup+0x38>
      }
      release(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	d81fe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e86:	16848493          	addi	s1,s1,360
    80001e8a:	03248263          	beq	s1,s2,80001eae <wakeup+0x58>
    if(p != myproc()){
    80001e8e:	975ff0ef          	jal	ra,80001802 <myproc>
    80001e92:	fea48ae3          	beq	s1,a0,80001e86 <wakeup+0x30>
      acquire(&p->lock);
    80001e96:	8526                	mv	a0,s1
    80001e98:	cd3fe0ef          	jal	ra,80000b6a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001e9c:	4c9c                	lw	a5,24(s1)
    80001e9e:	ff3791e3          	bne	a5,s3,80001e80 <wakeup+0x2a>
    80001ea2:	709c                	ld	a5,32(s1)
    80001ea4:	fd479ee3          	bne	a5,s4,80001e80 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001ea8:	0154ac23          	sw	s5,24(s1)
    80001eac:	bfd1                	j	80001e80 <wakeup+0x2a>
    }
  }
}
    80001eae:	70e2                	ld	ra,56(sp)
    80001eb0:	7442                	ld	s0,48(sp)
    80001eb2:	74a2                	ld	s1,40(sp)
    80001eb4:	7902                	ld	s2,32(sp)
    80001eb6:	69e2                	ld	s3,24(sp)
    80001eb8:	6a42                	ld	s4,16(sp)
    80001eba:	6aa2                	ld	s5,8(sp)
    80001ebc:	6121                	addi	sp,sp,64
    80001ebe:	8082                	ret

0000000080001ec0 <reparent>:
{
    80001ec0:	7179                	addi	sp,sp,-48
    80001ec2:	f406                	sd	ra,40(sp)
    80001ec4:	f022                	sd	s0,32(sp)
    80001ec6:	ec26                	sd	s1,24(sp)
    80001ec8:	e84a                	sd	s2,16(sp)
    80001eca:	e44e                	sd	s3,8(sp)
    80001ecc:	e052                	sd	s4,0(sp)
    80001ece:	1800                	addi	s0,sp,48
    80001ed0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ed2:	0000e497          	auipc	s1,0xe
    80001ed6:	ed648493          	addi	s1,s1,-298 # 8000fda8 <proc>
      pp->parent = initproc;
    80001eda:	00006a17          	auipc	s4,0x6
    80001ede:	996a0a13          	addi	s4,s4,-1642 # 80007870 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ee2:	00014997          	auipc	s3,0x14
    80001ee6:	8c698993          	addi	s3,s3,-1850 # 800157a8 <tickslock>
    80001eea:	a029                	j	80001ef4 <reparent+0x34>
    80001eec:	16848493          	addi	s1,s1,360
    80001ef0:	01348b63          	beq	s1,s3,80001f06 <reparent+0x46>
    if(pp->parent == p){
    80001ef4:	7c9c                	ld	a5,56(s1)
    80001ef6:	ff279be3          	bne	a5,s2,80001eec <reparent+0x2c>
      pp->parent = initproc;
    80001efa:	000a3503          	ld	a0,0(s4)
    80001efe:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001f00:	f57ff0ef          	jal	ra,80001e56 <wakeup>
    80001f04:	b7e5                	j	80001eec <reparent+0x2c>
}
    80001f06:	70a2                	ld	ra,40(sp)
    80001f08:	7402                	ld	s0,32(sp)
    80001f0a:	64e2                	ld	s1,24(sp)
    80001f0c:	6942                	ld	s2,16(sp)
    80001f0e:	69a2                	ld	s3,8(sp)
    80001f10:	6a02                	ld	s4,0(sp)
    80001f12:	6145                	addi	sp,sp,48
    80001f14:	8082                	ret

0000000080001f16 <kexit>:
{
    80001f16:	7179                	addi	sp,sp,-48
    80001f18:	f406                	sd	ra,40(sp)
    80001f1a:	f022                	sd	s0,32(sp)
    80001f1c:	ec26                	sd	s1,24(sp)
    80001f1e:	e84a                	sd	s2,16(sp)
    80001f20:	e44e                	sd	s3,8(sp)
    80001f22:	e052                	sd	s4,0(sp)
    80001f24:	1800                	addi	s0,sp,48
    80001f26:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f28:	8dbff0ef          	jal	ra,80001802 <myproc>
    80001f2c:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f2e:	00006797          	auipc	a5,0x6
    80001f32:	9427b783          	ld	a5,-1726(a5) # 80007870 <initproc>
    80001f36:	0d050493          	addi	s1,a0,208
    80001f3a:	15050913          	addi	s2,a0,336
    80001f3e:	00a79f63          	bne	a5,a0,80001f5c <kexit+0x46>
    panic("init exiting");
    80001f42:	00005517          	auipc	a0,0x5
    80001f46:	2b650513          	addi	a0,a0,694 # 800071f8 <digits+0x1c0>
    80001f4a:	83ffe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80001f4e:	795010ef          	jal	ra,80003ee2 <fileclose>
      p->ofile[fd] = 0;
    80001f52:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f56:	04a1                	addi	s1,s1,8
    80001f58:	01248563          	beq	s1,s2,80001f62 <kexit+0x4c>
    if(p->ofile[fd]){
    80001f5c:	6088                	ld	a0,0(s1)
    80001f5e:	f965                	bnez	a0,80001f4e <kexit+0x38>
    80001f60:	bfdd                	j	80001f56 <kexit+0x40>
  begin_op();
    80001f62:	377010ef          	jal	ra,80003ad8 <begin_op>
  iput(p->cwd);
    80001f66:	1509b503          	ld	a0,336(s3)
    80001f6a:	304010ef          	jal	ra,8000326e <iput>
  end_op();
    80001f6e:	3d9010ef          	jal	ra,80003b46 <end_op>
  p->cwd = 0;
    80001f72:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001f76:	0000e497          	auipc	s1,0xe
    80001f7a:	a1a48493          	addi	s1,s1,-1510 # 8000f990 <wait_lock>
    80001f7e:	8526                	mv	a0,s1
    80001f80:	bebfe0ef          	jal	ra,80000b6a <acquire>
  reparent(p);
    80001f84:	854e                	mv	a0,s3
    80001f86:	f3bff0ef          	jal	ra,80001ec0 <reparent>
  wakeup(p->parent);
    80001f8a:	0389b503          	ld	a0,56(s3)
    80001f8e:	ec9ff0ef          	jal	ra,80001e56 <wakeup>
  acquire(&p->lock);
    80001f92:	854e                	mv	a0,s3
    80001f94:	bd7fe0ef          	jal	ra,80000b6a <acquire>
  p->xstate = status;
    80001f98:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001f9c:	4795                	li	a5,5
    80001f9e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	c5ffe0ef          	jal	ra,80000c02 <release>
  sched();
    80001fa8:	d7dff0ef          	jal	ra,80001d24 <sched>
  panic("zombie exit");
    80001fac:	00005517          	auipc	a0,0x5
    80001fb0:	25c50513          	addi	a0,a0,604 # 80007208 <digits+0x1d0>
    80001fb4:	fd4fe0ef          	jal	ra,80000788 <panic>

0000000080001fb8 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80001fb8:	7179                	addi	sp,sp,-48
    80001fba:	f406                	sd	ra,40(sp)
    80001fbc:	f022                	sd	s0,32(sp)
    80001fbe:	ec26                	sd	s1,24(sp)
    80001fc0:	e84a                	sd	s2,16(sp)
    80001fc2:	e44e                	sd	s3,8(sp)
    80001fc4:	1800                	addi	s0,sp,48
    80001fc6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001fc8:	0000e497          	auipc	s1,0xe
    80001fcc:	de048493          	addi	s1,s1,-544 # 8000fda8 <proc>
    80001fd0:	00013997          	auipc	s3,0x13
    80001fd4:	7d898993          	addi	s3,s3,2008 # 800157a8 <tickslock>
    acquire(&p->lock);
    80001fd8:	8526                	mv	a0,s1
    80001fda:	b91fe0ef          	jal	ra,80000b6a <acquire>
    if(p->pid == pid){
    80001fde:	589c                	lw	a5,48(s1)
    80001fe0:	01278b63          	beq	a5,s2,80001ff6 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001fe4:	8526                	mv	a0,s1
    80001fe6:	c1dfe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001fea:	16848493          	addi	s1,s1,360
    80001fee:	ff3495e3          	bne	s1,s3,80001fd8 <kkill+0x20>
  }
  return -1;
    80001ff2:	557d                	li	a0,-1
    80001ff4:	a819                	j	8000200a <kkill+0x52>
      p->killed = 1;
    80001ff6:	4785                	li	a5,1
    80001ff8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001ffa:	4c98                	lw	a4,24(s1)
    80001ffc:	4789                	li	a5,2
    80001ffe:	00f70d63          	beq	a4,a5,80002018 <kkill+0x60>
      release(&p->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	bfffe0ef          	jal	ra,80000c02 <release>
      return 0;
    80002008:	4501                	li	a0,0
}
    8000200a:	70a2                	ld	ra,40(sp)
    8000200c:	7402                	ld	s0,32(sp)
    8000200e:	64e2                	ld	s1,24(sp)
    80002010:	6942                	ld	s2,16(sp)
    80002012:	69a2                	ld	s3,8(sp)
    80002014:	6145                	addi	sp,sp,48
    80002016:	8082                	ret
        p->state = RUNNABLE;
    80002018:	478d                	li	a5,3
    8000201a:	cc9c                	sw	a5,24(s1)
    8000201c:	b7dd                	j	80002002 <kkill+0x4a>

000000008000201e <setkilled>:

void
setkilled(struct proc *p)
{
    8000201e:	1101                	addi	sp,sp,-32
    80002020:	ec06                	sd	ra,24(sp)
    80002022:	e822                	sd	s0,16(sp)
    80002024:	e426                	sd	s1,8(sp)
    80002026:	1000                	addi	s0,sp,32
    80002028:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000202a:	b41fe0ef          	jal	ra,80000b6a <acquire>
  p->killed = 1;
    8000202e:	4785                	li	a5,1
    80002030:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002032:	8526                	mv	a0,s1
    80002034:	bcffe0ef          	jal	ra,80000c02 <release>
}
    80002038:	60e2                	ld	ra,24(sp)
    8000203a:	6442                	ld	s0,16(sp)
    8000203c:	64a2                	ld	s1,8(sp)
    8000203e:	6105                	addi	sp,sp,32
    80002040:	8082                	ret

0000000080002042 <killed>:

int
killed(struct proc *p)
{
    80002042:	1101                	addi	sp,sp,-32
    80002044:	ec06                	sd	ra,24(sp)
    80002046:	e822                	sd	s0,16(sp)
    80002048:	e426                	sd	s1,8(sp)
    8000204a:	e04a                	sd	s2,0(sp)
    8000204c:	1000                	addi	s0,sp,32
    8000204e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002050:	b1bfe0ef          	jal	ra,80000b6a <acquire>
  k = p->killed;
    80002054:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	ba9fe0ef          	jal	ra,80000c02 <release>
  return k;
}
    8000205e:	854a                	mv	a0,s2
    80002060:	60e2                	ld	ra,24(sp)
    80002062:	6442                	ld	s0,16(sp)
    80002064:	64a2                	ld	s1,8(sp)
    80002066:	6902                	ld	s2,0(sp)
    80002068:	6105                	addi	sp,sp,32
    8000206a:	8082                	ret

000000008000206c <kwait>:
{
    8000206c:	715d                	addi	sp,sp,-80
    8000206e:	e486                	sd	ra,72(sp)
    80002070:	e0a2                	sd	s0,64(sp)
    80002072:	fc26                	sd	s1,56(sp)
    80002074:	f84a                	sd	s2,48(sp)
    80002076:	f44e                	sd	s3,40(sp)
    80002078:	f052                	sd	s4,32(sp)
    8000207a:	ec56                	sd	s5,24(sp)
    8000207c:	e85a                	sd	s6,16(sp)
    8000207e:	e45e                	sd	s7,8(sp)
    80002080:	e062                	sd	s8,0(sp)
    80002082:	0880                	addi	s0,sp,80
    80002084:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002086:	f7cff0ef          	jal	ra,80001802 <myproc>
    8000208a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000208c:	0000e517          	auipc	a0,0xe
    80002090:	90450513          	addi	a0,a0,-1788 # 8000f990 <wait_lock>
    80002094:	ad7fe0ef          	jal	ra,80000b6a <acquire>
    havekids = 0;
    80002098:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000209a:	4a15                	li	s4,5
        havekids = 1;
    8000209c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000209e:	00013997          	auipc	s3,0x13
    800020a2:	70a98993          	addi	s3,s3,1802 # 800157a8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800020a6:	0000ec17          	auipc	s8,0xe
    800020aa:	8eac0c13          	addi	s8,s8,-1814 # 8000f990 <wait_lock>
    havekids = 0;
    800020ae:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020b0:	0000e497          	auipc	s1,0xe
    800020b4:	cf848493          	addi	s1,s1,-776 # 8000fda8 <proc>
    800020b8:	a899                	j	8000210e <kwait+0xa2>
          pid = pp->pid;
    800020ba:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800020be:	000b0c63          	beqz	s6,800020d6 <kwait+0x6a>
    800020c2:	4691                	li	a3,4
    800020c4:	02c48613          	addi	a2,s1,44
    800020c8:	85da                	mv	a1,s6
    800020ca:	05093503          	ld	a0,80(s2)
    800020ce:	c82ff0ef          	jal	ra,80001550 <copyout>
    800020d2:	00054f63          	bltz	a0,800020f0 <kwait+0x84>
          freeproc(pp);
    800020d6:	8526                	mv	a0,s1
    800020d8:	8fbff0ef          	jal	ra,800019d2 <freeproc>
          release(&pp->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	b25fe0ef          	jal	ra,80000c02 <release>
          release(&wait_lock);
    800020e2:	0000e517          	auipc	a0,0xe
    800020e6:	8ae50513          	addi	a0,a0,-1874 # 8000f990 <wait_lock>
    800020ea:	b19fe0ef          	jal	ra,80000c02 <release>
          return pid;
    800020ee:	a891                	j	80002142 <kwait+0xd6>
            release(&pp->lock);
    800020f0:	8526                	mv	a0,s1
    800020f2:	b11fe0ef          	jal	ra,80000c02 <release>
            release(&wait_lock);
    800020f6:	0000e517          	auipc	a0,0xe
    800020fa:	89a50513          	addi	a0,a0,-1894 # 8000f990 <wait_lock>
    800020fe:	b05fe0ef          	jal	ra,80000c02 <release>
            return -1;
    80002102:	59fd                	li	s3,-1
    80002104:	a83d                	j	80002142 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002106:	16848493          	addi	s1,s1,360
    8000210a:	03348063          	beq	s1,s3,8000212a <kwait+0xbe>
      if(pp->parent == p){
    8000210e:	7c9c                	ld	a5,56(s1)
    80002110:	ff279be3          	bne	a5,s2,80002106 <kwait+0x9a>
        acquire(&pp->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	a55fe0ef          	jal	ra,80000b6a <acquire>
        if(pp->state == ZOMBIE){
    8000211a:	4c9c                	lw	a5,24(s1)
    8000211c:	f9478fe3          	beq	a5,s4,800020ba <kwait+0x4e>
        release(&pp->lock);
    80002120:	8526                	mv	a0,s1
    80002122:	ae1fe0ef          	jal	ra,80000c02 <release>
        havekids = 1;
    80002126:	8756                	mv	a4,s5
    80002128:	bff9                	j	80002106 <kwait+0x9a>
    if(!havekids || killed(p)){
    8000212a:	c709                	beqz	a4,80002134 <kwait+0xc8>
    8000212c:	854a                	mv	a0,s2
    8000212e:	f15ff0ef          	jal	ra,80002042 <killed>
    80002132:	c50d                	beqz	a0,8000215c <kwait+0xf0>
      release(&wait_lock);
    80002134:	0000e517          	auipc	a0,0xe
    80002138:	85c50513          	addi	a0,a0,-1956 # 8000f990 <wait_lock>
    8000213c:	ac7fe0ef          	jal	ra,80000c02 <release>
      return -1;
    80002140:	59fd                	li	s3,-1
}
    80002142:	854e                	mv	a0,s3
    80002144:	60a6                	ld	ra,72(sp)
    80002146:	6406                	ld	s0,64(sp)
    80002148:	74e2                	ld	s1,56(sp)
    8000214a:	7942                	ld	s2,48(sp)
    8000214c:	79a2                	ld	s3,40(sp)
    8000214e:	7a02                	ld	s4,32(sp)
    80002150:	6ae2                	ld	s5,24(sp)
    80002152:	6b42                	ld	s6,16(sp)
    80002154:	6ba2                	ld	s7,8(sp)
    80002156:	6c02                	ld	s8,0(sp)
    80002158:	6161                	addi	sp,sp,80
    8000215a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000215c:	85e2                	mv	a1,s8
    8000215e:	854a                	mv	a0,s2
    80002160:	cabff0ef          	jal	ra,80001e0a <sleep>
    havekids = 0;
    80002164:	b7a9                	j	800020ae <kwait+0x42>

0000000080002166 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002166:	7179                	addi	sp,sp,-48
    80002168:	f406                	sd	ra,40(sp)
    8000216a:	f022                	sd	s0,32(sp)
    8000216c:	ec26                	sd	s1,24(sp)
    8000216e:	e84a                	sd	s2,16(sp)
    80002170:	e44e                	sd	s3,8(sp)
    80002172:	e052                	sd	s4,0(sp)
    80002174:	1800                	addi	s0,sp,48
    80002176:	84aa                	mv	s1,a0
    80002178:	892e                	mv	s2,a1
    8000217a:	89b2                	mv	s3,a2
    8000217c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000217e:	e84ff0ef          	jal	ra,80001802 <myproc>
  if(user_dst){
    80002182:	cc99                	beqz	s1,800021a0 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002184:	86d2                	mv	a3,s4
    80002186:	864e                	mv	a2,s3
    80002188:	85ca                	mv	a1,s2
    8000218a:	6928                	ld	a0,80(a0)
    8000218c:	bc4ff0ef          	jal	ra,80001550 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002190:	70a2                	ld	ra,40(sp)
    80002192:	7402                	ld	s0,32(sp)
    80002194:	64e2                	ld	s1,24(sp)
    80002196:	6942                	ld	s2,16(sp)
    80002198:	69a2                	ld	s3,8(sp)
    8000219a:	6a02                	ld	s4,0(sp)
    8000219c:	6145                	addi	sp,sp,48
    8000219e:	8082                	ret
    memmove((char *)dst, src, len);
    800021a0:	000a061b          	sext.w	a2,s4
    800021a4:	85ce                	mv	a1,s3
    800021a6:	854a                	mv	a0,s2
    800021a8:	af3fe0ef          	jal	ra,80000c9a <memmove>
    return 0;
    800021ac:	8526                	mv	a0,s1
    800021ae:	b7cd                	j	80002190 <either_copyout+0x2a>

00000000800021b0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800021b0:	7179                	addi	sp,sp,-48
    800021b2:	f406                	sd	ra,40(sp)
    800021b4:	f022                	sd	s0,32(sp)
    800021b6:	ec26                	sd	s1,24(sp)
    800021b8:	e84a                	sd	s2,16(sp)
    800021ba:	e44e                	sd	s3,8(sp)
    800021bc:	e052                	sd	s4,0(sp)
    800021be:	1800                	addi	s0,sp,48
    800021c0:	892a                	mv	s2,a0
    800021c2:	84ae                	mv	s1,a1
    800021c4:	89b2                	mv	s3,a2
    800021c6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021c8:	e3aff0ef          	jal	ra,80001802 <myproc>
  if(user_src){
    800021cc:	cc99                	beqz	s1,800021ea <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800021ce:	86d2                	mv	a3,s4
    800021d0:	864e                	mv	a2,s3
    800021d2:	85ca                	mv	a1,s2
    800021d4:	6928                	ld	a0,80(a0)
    800021d6:	c40ff0ef          	jal	ra,80001616 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800021da:	70a2                	ld	ra,40(sp)
    800021dc:	7402                	ld	s0,32(sp)
    800021de:	64e2                	ld	s1,24(sp)
    800021e0:	6942                	ld	s2,16(sp)
    800021e2:	69a2                	ld	s3,8(sp)
    800021e4:	6a02                	ld	s4,0(sp)
    800021e6:	6145                	addi	sp,sp,48
    800021e8:	8082                	ret
    memmove(dst, (char*)src, len);
    800021ea:	000a061b          	sext.w	a2,s4
    800021ee:	85ce                	mv	a1,s3
    800021f0:	854a                	mv	a0,s2
    800021f2:	aa9fe0ef          	jal	ra,80000c9a <memmove>
    return 0;
    800021f6:	8526                	mv	a0,s1
    800021f8:	b7cd                	j	800021da <either_copyin+0x2a>

00000000800021fa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800021fa:	715d                	addi	sp,sp,-80
    800021fc:	e486                	sd	ra,72(sp)
    800021fe:	e0a2                	sd	s0,64(sp)
    80002200:	fc26                	sd	s1,56(sp)
    80002202:	f84a                	sd	s2,48(sp)
    80002204:	f44e                	sd	s3,40(sp)
    80002206:	f052                	sd	s4,32(sp)
    80002208:	ec56                	sd	s5,24(sp)
    8000220a:	e85a                	sd	s6,16(sp)
    8000220c:	e45e                	sd	s7,8(sp)
    8000220e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002210:	00005517          	auipc	a0,0x5
    80002214:	eb050513          	addi	a0,a0,-336 # 800070c0 <digits+0x88>
    80002218:	aaafe0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000221c:	0000e497          	auipc	s1,0xe
    80002220:	ce448493          	addi	s1,s1,-796 # 8000ff00 <proc+0x158>
    80002224:	00013917          	auipc	s2,0x13
    80002228:	6dc90913          	addi	s2,s2,1756 # 80015900 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000222c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000222e:	00005997          	auipc	s3,0x5
    80002232:	fea98993          	addi	s3,s3,-22 # 80007218 <digits+0x1e0>
    printf("%d %s %s", p->pid, state, p->name);
    80002236:	00005a97          	auipc	s5,0x5
    8000223a:	feaa8a93          	addi	s5,s5,-22 # 80007220 <digits+0x1e8>
    printf("\n");
    8000223e:	00005a17          	auipc	s4,0x5
    80002242:	e82a0a13          	addi	s4,s4,-382 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002246:	00005b97          	auipc	s7,0x5
    8000224a:	01ab8b93          	addi	s7,s7,26 # 80007260 <states.0>
    8000224e:	a829                	j	80002268 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002250:	ed86a583          	lw	a1,-296(a3)
    80002254:	8556                	mv	a0,s5
    80002256:	a6cfe0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    8000225a:	8552                	mv	a0,s4
    8000225c:	a66fe0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002260:	16848493          	addi	s1,s1,360
    80002264:	03248263          	beq	s1,s2,80002288 <procdump+0x8e>
    if(p->state == UNUSED)
    80002268:	86a6                	mv	a3,s1
    8000226a:	ec04a783          	lw	a5,-320(s1)
    8000226e:	dbed                	beqz	a5,80002260 <procdump+0x66>
      state = "???";
    80002270:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002272:	fcfb6fe3          	bltu	s6,a5,80002250 <procdump+0x56>
    80002276:	02079713          	slli	a4,a5,0x20
    8000227a:	01d75793          	srli	a5,a4,0x1d
    8000227e:	97de                	add	a5,a5,s7
    80002280:	6390                	ld	a2,0(a5)
    80002282:	f679                	bnez	a2,80002250 <procdump+0x56>
      state = "???";
    80002284:	864e                	mv	a2,s3
    80002286:	b7e9                	j	80002250 <procdump+0x56>
  }
}
    80002288:	60a6                	ld	ra,72(sp)
    8000228a:	6406                	ld	s0,64(sp)
    8000228c:	74e2                	ld	s1,56(sp)
    8000228e:	7942                	ld	s2,48(sp)
    80002290:	79a2                	ld	s3,40(sp)
    80002292:	7a02                	ld	s4,32(sp)
    80002294:	6ae2                	ld	s5,24(sp)
    80002296:	6b42                	ld	s6,16(sp)
    80002298:	6ba2                	ld	s7,8(sp)
    8000229a:	6161                	addi	sp,sp,80
    8000229c:	8082                	ret

000000008000229e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000229e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800022a2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800022a6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800022a8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800022aa:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800022ae:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800022b2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800022b6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800022ba:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800022be:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800022c2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800022c6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800022ca:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800022ce:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800022d2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800022d6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800022da:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800022dc:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800022de:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800022e2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800022e6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800022ea:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800022ee:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800022f2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800022f6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800022fa:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800022fe:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002302:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002306:	8082                	ret

0000000080002308 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002308:	1141                	addi	sp,sp,-16
    8000230a:	e406                	sd	ra,8(sp)
    8000230c:	e022                	sd	s0,0(sp)
    8000230e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002310:	00005597          	auipc	a1,0x5
    80002314:	f8058593          	addi	a1,a1,-128 # 80007290 <states.0+0x30>
    80002318:	00013517          	auipc	a0,0x13
    8000231c:	49050513          	addi	a0,a0,1168 # 800157a8 <tickslock>
    80002320:	fcafe0ef          	jal	ra,80000aea <initlock>
}
    80002324:	60a2                	ld	ra,8(sp)
    80002326:	6402                	ld	s0,0(sp)
    80002328:	0141                	addi	sp,sp,16
    8000232a:	8082                	ret

000000008000232c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000232c:	1141                	addi	sp,sp,-16
    8000232e:	e422                	sd	s0,8(sp)
    80002330:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002332:	00003797          	auipc	a5,0x3
    80002336:	e7e78793          	addi	a5,a5,-386 # 800051b0 <kernelvec>
    8000233a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000233e:	6422                	ld	s0,8(sp)
    80002340:	0141                	addi	sp,sp,16
    80002342:	8082                	ret

0000000080002344 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002344:	1141                	addi	sp,sp,-16
    80002346:	e406                	sd	ra,8(sp)
    80002348:	e022                	sd	s0,0(sp)
    8000234a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000234c:	cb6ff0ef          	jal	ra,80001802 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002350:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002354:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002356:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000235a:	04000737          	lui	a4,0x4000
    8000235e:	00004797          	auipc	a5,0x4
    80002362:	ca278793          	addi	a5,a5,-862 # 80006000 <_trampoline>
    80002366:	00004697          	auipc	a3,0x4
    8000236a:	c9a68693          	addi	a3,a3,-870 # 80006000 <_trampoline>
    8000236e:	8f95                	sub	a5,a5,a3
    80002370:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002372:	0732                	slli	a4,a4,0xc
    80002374:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002376:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000237a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000237c:	18002773          	csrr	a4,satp
    80002380:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002382:	6d38                	ld	a4,88(a0)
    80002384:	613c                	ld	a5,64(a0)
    80002386:	6685                	lui	a3,0x1
    80002388:	97b6                	add	a5,a5,a3
    8000238a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000238c:	6d3c                	ld	a5,88(a0)
    8000238e:	00000717          	auipc	a4,0x0
    80002392:	0f470713          	addi	a4,a4,244 # 80002482 <usertrap>
    80002396:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002398:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000239a:	8712                	mv	a4,tp
    8000239c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000239e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800023a2:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800023a6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023aa:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800023ae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800023b0:	6f9c                	ld	a5,24(a5)
    800023b2:	14179073          	csrw	sepc,a5
}
    800023b6:	60a2                	ld	ra,8(sp)
    800023b8:	6402                	ld	s0,0(sp)
    800023ba:	0141                	addi	sp,sp,16
    800023bc:	8082                	ret

00000000800023be <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800023be:	1101                	addi	sp,sp,-32
    800023c0:	ec06                	sd	ra,24(sp)
    800023c2:	e822                	sd	s0,16(sp)
    800023c4:	e426                	sd	s1,8(sp)
    800023c6:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800023c8:	c0eff0ef          	jal	ra,800017d6 <cpuid>
    800023cc:	cd19                	beqz	a0,800023ea <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800023ce:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800023d2:	000f4737          	lui	a4,0xf4
    800023d6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800023da:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800023dc:	14d79073          	csrw	0x14d,a5
}
    800023e0:	60e2                	ld	ra,24(sp)
    800023e2:	6442                	ld	s0,16(sp)
    800023e4:	64a2                	ld	s1,8(sp)
    800023e6:	6105                	addi	sp,sp,32
    800023e8:	8082                	ret
    acquire(&tickslock);
    800023ea:	00013497          	auipc	s1,0x13
    800023ee:	3be48493          	addi	s1,s1,958 # 800157a8 <tickslock>
    800023f2:	8526                	mv	a0,s1
    800023f4:	f76fe0ef          	jal	ra,80000b6a <acquire>
    ticks++;
    800023f8:	00005517          	auipc	a0,0x5
    800023fc:	48050513          	addi	a0,a0,1152 # 80007878 <ticks>
    80002400:	411c                	lw	a5,0(a0)
    80002402:	2785                	addiw	a5,a5,1
    80002404:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002406:	a51ff0ef          	jal	ra,80001e56 <wakeup>
    release(&tickslock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	ff6fe0ef          	jal	ra,80000c02 <release>
    80002410:	bf7d                	j	800023ce <clockintr+0x10>

0000000080002412 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002412:	1101                	addi	sp,sp,-32
    80002414:	ec06                	sd	ra,24(sp)
    80002416:	e822                	sd	s0,16(sp)
    80002418:	e426                	sd	s1,8(sp)
    8000241a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000241c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002420:	57fd                	li	a5,-1
    80002422:	17fe                	slli	a5,a5,0x3f
    80002424:	07a5                	addi	a5,a5,9
    80002426:	00f70d63          	beq	a4,a5,80002440 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000242a:	57fd                	li	a5,-1
    8000242c:	17fe                	slli	a5,a5,0x3f
    8000242e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002430:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002432:	04f70463          	beq	a4,a5,8000247a <devintr+0x68>
  }
}
    80002436:	60e2                	ld	ra,24(sp)
    80002438:	6442                	ld	s0,16(sp)
    8000243a:	64a2                	ld	s1,8(sp)
    8000243c:	6105                	addi	sp,sp,32
    8000243e:	8082                	ret
    int irq = plic_claim();
    80002440:	619020ef          	jal	ra,80005258 <plic_claim>
    80002444:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002446:	47a9                	li	a5,10
    80002448:	02f50363          	beq	a0,a5,8000246e <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000244c:	4785                	li	a5,1
    8000244e:	02f50363          	beq	a0,a5,80002474 <devintr+0x62>
    return 1;
    80002452:	4505                	li	a0,1
    } else if(irq){
    80002454:	d0ed                	beqz	s1,80002436 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002456:	85a6                	mv	a1,s1
    80002458:	00005517          	auipc	a0,0x5
    8000245c:	e4050513          	addi	a0,a0,-448 # 80007298 <states.0+0x38>
    80002460:	862fe0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    80002464:	8526                	mv	a0,s1
    80002466:	613020ef          	jal	ra,80005278 <plic_complete>
    return 1;
    8000246a:	4505                	li	a0,1
    8000246c:	b7e9                	j	80002436 <devintr+0x24>
      uartintr();
    8000246e:	ce6fe0ef          	jal	ra,80000954 <uartintr>
    80002472:	bfcd                	j	80002464 <devintr+0x52>
      virtio_disk_intr();
    80002474:	270030ef          	jal	ra,800056e4 <virtio_disk_intr>
    80002478:	b7f5                	j	80002464 <devintr+0x52>
    clockintr();
    8000247a:	f45ff0ef          	jal	ra,800023be <clockintr>
    return 2;
    8000247e:	4509                	li	a0,2
    80002480:	bf5d                	j	80002436 <devintr+0x24>

0000000080002482 <usertrap>:
{
    80002482:	1101                	addi	sp,sp,-32
    80002484:	ec06                	sd	ra,24(sp)
    80002486:	e822                	sd	s0,16(sp)
    80002488:	e426                	sd	s1,8(sp)
    8000248a:	e04a                	sd	s2,0(sp)
    8000248c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000248e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002492:	1007f793          	andi	a5,a5,256
    80002496:	eba5                	bnez	a5,80002506 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002498:	00003797          	auipc	a5,0x3
    8000249c:	d1878793          	addi	a5,a5,-744 # 800051b0 <kernelvec>
    800024a0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800024a4:	b5eff0ef          	jal	ra,80001802 <myproc>
    800024a8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800024aa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800024ac:	14102773          	csrr	a4,sepc
    800024b0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024b2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800024b6:	47a1                	li	a5,8
    800024b8:	04f70d63          	beq	a4,a5,80002512 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800024bc:	f57ff0ef          	jal	ra,80002412 <devintr>
    800024c0:	892a                	mv	s2,a0
    800024c2:	e945                	bnez	a0,80002572 <usertrap+0xf0>
    800024c4:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800024c8:	47bd                	li	a5,15
    800024ca:	08f70863          	beq	a4,a5,8000255a <usertrap+0xd8>
    800024ce:	14202773          	csrr	a4,scause
    800024d2:	47b5                	li	a5,13
    800024d4:	08f70363          	beq	a4,a5,8000255a <usertrap+0xd8>
    800024d8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800024dc:	5890                	lw	a2,48(s1)
    800024de:	00005517          	auipc	a0,0x5
    800024e2:	dfa50513          	addi	a0,a0,-518 # 800072d8 <states.0+0x78>
    800024e6:	fddfd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800024ea:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800024ee:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800024f2:	00005517          	auipc	a0,0x5
    800024f6:	e1650513          	addi	a0,a0,-490 # 80007308 <states.0+0xa8>
    800024fa:	fc9fd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    800024fe:	8526                	mv	a0,s1
    80002500:	b1fff0ef          	jal	ra,8000201e <setkilled>
    80002504:	a035                	j	80002530 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002506:	00005517          	auipc	a0,0x5
    8000250a:	db250513          	addi	a0,a0,-590 # 800072b8 <states.0+0x58>
    8000250e:	a7afe0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002512:	b31ff0ef          	jal	ra,80002042 <killed>
    80002516:	ed15                	bnez	a0,80002552 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002518:	6cb8                	ld	a4,88(s1)
    8000251a:	6f1c                	ld	a5,24(a4)
    8000251c:	0791                	addi	a5,a5,4
    8000251e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002520:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002524:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002528:	10079073          	csrw	sstatus,a5
    syscall();
    8000252c:	246000ef          	jal	ra,80002772 <syscall>
  if(killed(p))
    80002530:	8526                	mv	a0,s1
    80002532:	b11ff0ef          	jal	ra,80002042 <killed>
    80002536:	e139                	bnez	a0,8000257c <usertrap+0xfa>
  prepare_return();
    80002538:	e0dff0ef          	jal	ra,80002344 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000253c:	68a8                	ld	a0,80(s1)
    8000253e:	8131                	srli	a0,a0,0xc
    80002540:	57fd                	li	a5,-1
    80002542:	17fe                	slli	a5,a5,0x3f
    80002544:	8d5d                	or	a0,a0,a5
}
    80002546:	60e2                	ld	ra,24(sp)
    80002548:	6442                	ld	s0,16(sp)
    8000254a:	64a2                	ld	s1,8(sp)
    8000254c:	6902                	ld	s2,0(sp)
    8000254e:	6105                	addi	sp,sp,32
    80002550:	8082                	ret
      kexit(-1);
    80002552:	557d                	li	a0,-1
    80002554:	9c3ff0ef          	jal	ra,80001f16 <kexit>
    80002558:	b7c1                	j	80002518 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000255a:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000255e:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002562:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002564:	00163613          	seqz	a2,a2
    80002568:	68a8                	ld	a0,80(s1)
    8000256a:	f75fe0ef          	jal	ra,800014de <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000256e:	f169                	bnez	a0,80002530 <usertrap+0xae>
    80002570:	b7a5                	j	800024d8 <usertrap+0x56>
  if(killed(p))
    80002572:	8526                	mv	a0,s1
    80002574:	acfff0ef          	jal	ra,80002042 <killed>
    80002578:	c511                	beqz	a0,80002584 <usertrap+0x102>
    8000257a:	a011                	j	8000257e <usertrap+0xfc>
    8000257c:	4901                	li	s2,0
    kexit(-1);
    8000257e:	557d                	li	a0,-1
    80002580:	997ff0ef          	jal	ra,80001f16 <kexit>
  if(which_dev == 2)
    80002584:	4789                	li	a5,2
    80002586:	faf919e3          	bne	s2,a5,80002538 <usertrap+0xb6>
    yield();
    8000258a:	855ff0ef          	jal	ra,80001dde <yield>
    8000258e:	b76d                	j	80002538 <usertrap+0xb6>

0000000080002590 <kerneltrap>:
{
    80002590:	7179                	addi	sp,sp,-48
    80002592:	f406                	sd	ra,40(sp)
    80002594:	f022                	sd	s0,32(sp)
    80002596:	ec26                	sd	s1,24(sp)
    80002598:	e84a                	sd	s2,16(sp)
    8000259a:	e44e                	sd	s3,8(sp)
    8000259c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000259e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025a6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800025aa:	1004f793          	andi	a5,s1,256
    800025ae:	c795                	beqz	a5,800025da <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025b0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025b4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800025b6:	eb85                	bnez	a5,800025e6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800025b8:	e5bff0ef          	jal	ra,80002412 <devintr>
    800025bc:	c91d                	beqz	a0,800025f2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800025be:	4789                	li	a5,2
    800025c0:	04f50a63          	beq	a0,a5,80002614 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025c4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025c8:	10049073          	csrw	sstatus,s1
}
    800025cc:	70a2                	ld	ra,40(sp)
    800025ce:	7402                	ld	s0,32(sp)
    800025d0:	64e2                	ld	s1,24(sp)
    800025d2:	6942                	ld	s2,16(sp)
    800025d4:	69a2                	ld	s3,8(sp)
    800025d6:	6145                	addi	sp,sp,48
    800025d8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800025da:	00005517          	auipc	a0,0x5
    800025de:	d5650513          	addi	a0,a0,-682 # 80007330 <states.0+0xd0>
    800025e2:	9a6fe0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    800025e6:	00005517          	auipc	a0,0x5
    800025ea:	d7250513          	addi	a0,a0,-654 # 80007358 <states.0+0xf8>
    800025ee:	99afe0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025f6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800025fa:	85ce                	mv	a1,s3
    800025fc:	00005517          	auipc	a0,0x5
    80002600:	d7c50513          	addi	a0,a0,-644 # 80007378 <states.0+0x118>
    80002604:	ebffd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002608:	00005517          	auipc	a0,0x5
    8000260c:	d9850513          	addi	a0,a0,-616 # 800073a0 <states.0+0x140>
    80002610:	978fe0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002614:	9eeff0ef          	jal	ra,80001802 <myproc>
    80002618:	d555                	beqz	a0,800025c4 <kerneltrap+0x34>
    yield();
    8000261a:	fc4ff0ef          	jal	ra,80001dde <yield>
    8000261e:	b75d                	j	800025c4 <kerneltrap+0x34>

0000000080002620 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002620:	1101                	addi	sp,sp,-32
    80002622:	ec06                	sd	ra,24(sp)
    80002624:	e822                	sd	s0,16(sp)
    80002626:	e426                	sd	s1,8(sp)
    80002628:	1000                	addi	s0,sp,32
    8000262a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000262c:	9d6ff0ef          	jal	ra,80001802 <myproc>
  switch (n) {
    80002630:	4795                	li	a5,5
    80002632:	0497e163          	bltu	a5,s1,80002674 <argraw+0x54>
    80002636:	048a                	slli	s1,s1,0x2
    80002638:	00005717          	auipc	a4,0x5
    8000263c:	da070713          	addi	a4,a4,-608 # 800073d8 <states.0+0x178>
    80002640:	94ba                	add	s1,s1,a4
    80002642:	409c                	lw	a5,0(s1)
    80002644:	97ba                	add	a5,a5,a4
    80002646:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002648:	6d3c                	ld	a5,88(a0)
    8000264a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000264c:	60e2                	ld	ra,24(sp)
    8000264e:	6442                	ld	s0,16(sp)
    80002650:	64a2                	ld	s1,8(sp)
    80002652:	6105                	addi	sp,sp,32
    80002654:	8082                	ret
    return p->trapframe->a1;
    80002656:	6d3c                	ld	a5,88(a0)
    80002658:	7fa8                	ld	a0,120(a5)
    8000265a:	bfcd                	j	8000264c <argraw+0x2c>
    return p->trapframe->a2;
    8000265c:	6d3c                	ld	a5,88(a0)
    8000265e:	63c8                	ld	a0,128(a5)
    80002660:	b7f5                	j	8000264c <argraw+0x2c>
    return p->trapframe->a3;
    80002662:	6d3c                	ld	a5,88(a0)
    80002664:	67c8                	ld	a0,136(a5)
    80002666:	b7dd                	j	8000264c <argraw+0x2c>
    return p->trapframe->a4;
    80002668:	6d3c                	ld	a5,88(a0)
    8000266a:	6bc8                	ld	a0,144(a5)
    8000266c:	b7c5                	j	8000264c <argraw+0x2c>
    return p->trapframe->a5;
    8000266e:	6d3c                	ld	a5,88(a0)
    80002670:	6fc8                	ld	a0,152(a5)
    80002672:	bfe9                	j	8000264c <argraw+0x2c>
  panic("argraw");
    80002674:	00005517          	auipc	a0,0x5
    80002678:	d3c50513          	addi	a0,a0,-708 # 800073b0 <states.0+0x150>
    8000267c:	90cfe0ef          	jal	ra,80000788 <panic>

0000000080002680 <fetchaddr>:
{
    80002680:	1101                	addi	sp,sp,-32
    80002682:	ec06                	sd	ra,24(sp)
    80002684:	e822                	sd	s0,16(sp)
    80002686:	e426                	sd	s1,8(sp)
    80002688:	e04a                	sd	s2,0(sp)
    8000268a:	1000                	addi	s0,sp,32
    8000268c:	84aa                	mv	s1,a0
    8000268e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002690:	972ff0ef          	jal	ra,80001802 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002694:	653c                	ld	a5,72(a0)
    80002696:	02f4f663          	bgeu	s1,a5,800026c2 <fetchaddr+0x42>
    8000269a:	00848713          	addi	a4,s1,8
    8000269e:	02e7e463          	bltu	a5,a4,800026c6 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800026a2:	46a1                	li	a3,8
    800026a4:	8626                	mv	a2,s1
    800026a6:	85ca                	mv	a1,s2
    800026a8:	6928                	ld	a0,80(a0)
    800026aa:	f6dfe0ef          	jal	ra,80001616 <copyin>
    800026ae:	00a03533          	snez	a0,a0
    800026b2:	40a00533          	neg	a0,a0
}
    800026b6:	60e2                	ld	ra,24(sp)
    800026b8:	6442                	ld	s0,16(sp)
    800026ba:	64a2                	ld	s1,8(sp)
    800026bc:	6902                	ld	s2,0(sp)
    800026be:	6105                	addi	sp,sp,32
    800026c0:	8082                	ret
    return -1;
    800026c2:	557d                	li	a0,-1
    800026c4:	bfcd                	j	800026b6 <fetchaddr+0x36>
    800026c6:	557d                	li	a0,-1
    800026c8:	b7fd                	j	800026b6 <fetchaddr+0x36>

00000000800026ca <fetchstr>:
{
    800026ca:	7179                	addi	sp,sp,-48
    800026cc:	f406                	sd	ra,40(sp)
    800026ce:	f022                	sd	s0,32(sp)
    800026d0:	ec26                	sd	s1,24(sp)
    800026d2:	e84a                	sd	s2,16(sp)
    800026d4:	e44e                	sd	s3,8(sp)
    800026d6:	1800                	addi	s0,sp,48
    800026d8:	892a                	mv	s2,a0
    800026da:	84ae                	mv	s1,a1
    800026dc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800026de:	924ff0ef          	jal	ra,80001802 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800026e2:	86ce                	mv	a3,s3
    800026e4:	864a                	mv	a2,s2
    800026e6:	85a6                	mv	a1,s1
    800026e8:	6928                	ld	a0,80(a0)
    800026ea:	d29fe0ef          	jal	ra,80001412 <copyinstr>
    800026ee:	00054c63          	bltz	a0,80002706 <fetchstr+0x3c>
  return strlen(buf);
    800026f2:	8526                	mv	a0,s1
    800026f4:	ec2fe0ef          	jal	ra,80000db6 <strlen>
}
    800026f8:	70a2                	ld	ra,40(sp)
    800026fa:	7402                	ld	s0,32(sp)
    800026fc:	64e2                	ld	s1,24(sp)
    800026fe:	6942                	ld	s2,16(sp)
    80002700:	69a2                	ld	s3,8(sp)
    80002702:	6145                	addi	sp,sp,48
    80002704:	8082                	ret
    return -1;
    80002706:	557d                	li	a0,-1
    80002708:	bfc5                	j	800026f8 <fetchstr+0x2e>

000000008000270a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000270a:	1101                	addi	sp,sp,-32
    8000270c:	ec06                	sd	ra,24(sp)
    8000270e:	e822                	sd	s0,16(sp)
    80002710:	e426                	sd	s1,8(sp)
    80002712:	1000                	addi	s0,sp,32
    80002714:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002716:	f0bff0ef          	jal	ra,80002620 <argraw>
    8000271a:	c088                	sw	a0,0(s1)
}
    8000271c:	60e2                	ld	ra,24(sp)
    8000271e:	6442                	ld	s0,16(sp)
    80002720:	64a2                	ld	s1,8(sp)
    80002722:	6105                	addi	sp,sp,32
    80002724:	8082                	ret

0000000080002726 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	1000                	addi	s0,sp,32
    80002730:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002732:	eefff0ef          	jal	ra,80002620 <argraw>
    80002736:	e088                	sd	a0,0(s1)
}
    80002738:	60e2                	ld	ra,24(sp)
    8000273a:	6442                	ld	s0,16(sp)
    8000273c:	64a2                	ld	s1,8(sp)
    8000273e:	6105                	addi	sp,sp,32
    80002740:	8082                	ret

0000000080002742 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002742:	7179                	addi	sp,sp,-48
    80002744:	f406                	sd	ra,40(sp)
    80002746:	f022                	sd	s0,32(sp)
    80002748:	ec26                	sd	s1,24(sp)
    8000274a:	e84a                	sd	s2,16(sp)
    8000274c:	1800                	addi	s0,sp,48
    8000274e:	84ae                	mv	s1,a1
    80002750:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002752:	fd840593          	addi	a1,s0,-40
    80002756:	fd1ff0ef          	jal	ra,80002726 <argaddr>
  return fetchstr(addr, buf, max);
    8000275a:	864a                	mv	a2,s2
    8000275c:	85a6                	mv	a1,s1
    8000275e:	fd843503          	ld	a0,-40(s0)
    80002762:	f69ff0ef          	jal	ra,800026ca <fetchstr>
}
    80002766:	70a2                	ld	ra,40(sp)
    80002768:	7402                	ld	s0,32(sp)
    8000276a:	64e2                	ld	s1,24(sp)
    8000276c:	6942                	ld	s2,16(sp)
    8000276e:	6145                	addi	sp,sp,48
    80002770:	8082                	ret

0000000080002772 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002772:	1101                	addi	sp,sp,-32
    80002774:	ec06                	sd	ra,24(sp)
    80002776:	e822                	sd	s0,16(sp)
    80002778:	e426                	sd	s1,8(sp)
    8000277a:	e04a                	sd	s2,0(sp)
    8000277c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000277e:	884ff0ef          	jal	ra,80001802 <myproc>
    80002782:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002784:	05853903          	ld	s2,88(a0)
    80002788:	0a893783          	ld	a5,168(s2)
    8000278c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002790:	37fd                	addiw	a5,a5,-1
    80002792:	4751                	li	a4,20
    80002794:	00f76f63          	bltu	a4,a5,800027b2 <syscall+0x40>
    80002798:	00369713          	slli	a4,a3,0x3
    8000279c:	00005797          	auipc	a5,0x5
    800027a0:	c5478793          	addi	a5,a5,-940 # 800073f0 <syscalls>
    800027a4:	97ba                	add	a5,a5,a4
    800027a6:	639c                	ld	a5,0(a5)
    800027a8:	c789                	beqz	a5,800027b2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800027aa:	9782                	jalr	a5
    800027ac:	06a93823          	sd	a0,112(s2)
    800027b0:	a829                	j	800027ca <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800027b2:	15848613          	addi	a2,s1,344
    800027b6:	588c                	lw	a1,48(s1)
    800027b8:	00005517          	auipc	a0,0x5
    800027bc:	c0050513          	addi	a0,a0,-1024 # 800073b8 <states.0+0x158>
    800027c0:	d03fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800027c4:	6cbc                	ld	a5,88(s1)
    800027c6:	577d                	li	a4,-1
    800027c8:	fbb8                	sd	a4,112(a5)
  }
}
    800027ca:	60e2                	ld	ra,24(sp)
    800027cc:	6442                	ld	s0,16(sp)
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6902                	ld	s2,0(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret

00000000800027d6 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800027d6:	1101                	addi	sp,sp,-32
    800027d8:	ec06                	sd	ra,24(sp)
    800027da:	e822                	sd	s0,16(sp)
    800027dc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800027de:	fec40593          	addi	a1,s0,-20
    800027e2:	4501                	li	a0,0
    800027e4:	f27ff0ef          	jal	ra,8000270a <argint>
  kexit(n);
    800027e8:	fec42503          	lw	a0,-20(s0)
    800027ec:	f2aff0ef          	jal	ra,80001f16 <kexit>
  return 0;  // not reached
}
    800027f0:	4501                	li	a0,0
    800027f2:	60e2                	ld	ra,24(sp)
    800027f4:	6442                	ld	s0,16(sp)
    800027f6:	6105                	addi	sp,sp,32
    800027f8:	8082                	ret

00000000800027fa <sys_getpid>:

uint64
sys_getpid(void)
{
    800027fa:	1141                	addi	sp,sp,-16
    800027fc:	e406                	sd	ra,8(sp)
    800027fe:	e022                	sd	s0,0(sp)
    80002800:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002802:	800ff0ef          	jal	ra,80001802 <myproc>
}
    80002806:	5908                	lw	a0,48(a0)
    80002808:	60a2                	ld	ra,8(sp)
    8000280a:	6402                	ld	s0,0(sp)
    8000280c:	0141                	addi	sp,sp,16
    8000280e:	8082                	ret

0000000080002810 <sys_fork>:

uint64
sys_fork(void)
{
    80002810:	1141                	addi	sp,sp,-16
    80002812:	e406                	sd	ra,8(sp)
    80002814:	e022                	sd	s0,0(sp)
    80002816:	0800                	addi	s0,sp,16
  return kfork();
    80002818:	b4eff0ef          	jal	ra,80001b66 <kfork>
}
    8000281c:	60a2                	ld	ra,8(sp)
    8000281e:	6402                	ld	s0,0(sp)
    80002820:	0141                	addi	sp,sp,16
    80002822:	8082                	ret

0000000080002824 <sys_wait>:

uint64
sys_wait(void)
{
    80002824:	1101                	addi	sp,sp,-32
    80002826:	ec06                	sd	ra,24(sp)
    80002828:	e822                	sd	s0,16(sp)
    8000282a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000282c:	fe840593          	addi	a1,s0,-24
    80002830:	4501                	li	a0,0
    80002832:	ef5ff0ef          	jal	ra,80002726 <argaddr>
  return kwait(p);
    80002836:	fe843503          	ld	a0,-24(s0)
    8000283a:	833ff0ef          	jal	ra,8000206c <kwait>
}
    8000283e:	60e2                	ld	ra,24(sp)
    80002840:	6442                	ld	s0,16(sp)
    80002842:	6105                	addi	sp,sp,32
    80002844:	8082                	ret

0000000080002846 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002846:	7179                	addi	sp,sp,-48
    80002848:	f406                	sd	ra,40(sp)
    8000284a:	f022                	sd	s0,32(sp)
    8000284c:	ec26                	sd	s1,24(sp)
    8000284e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002850:	fd840593          	addi	a1,s0,-40
    80002854:	4501                	li	a0,0
    80002856:	eb5ff0ef          	jal	ra,8000270a <argint>
  argint(1, &t);
    8000285a:	fdc40593          	addi	a1,s0,-36
    8000285e:	4505                	li	a0,1
    80002860:	eabff0ef          	jal	ra,8000270a <argint>
  addr = myproc()->sz;
    80002864:	f9ffe0ef          	jal	ra,80001802 <myproc>
    80002868:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000286a:	fdc42703          	lw	a4,-36(s0)
    8000286e:	4785                	li	a5,1
    80002870:	02f70763          	beq	a4,a5,8000289e <sys_sbrk+0x58>
    80002874:	fd842783          	lw	a5,-40(s0)
    80002878:	0207c363          	bltz	a5,8000289e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000287c:	97a6                	add	a5,a5,s1
    8000287e:	0297ee63          	bltu	a5,s1,800028ba <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002882:	02000737          	lui	a4,0x2000
    80002886:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002888:	0736                	slli	a4,a4,0xd
    8000288a:	02f76a63          	bltu	a4,a5,800028be <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    8000288e:	f75fe0ef          	jal	ra,80001802 <myproc>
    80002892:	fd842703          	lw	a4,-40(s0)
    80002896:	653c                	ld	a5,72(a0)
    80002898:	97ba                	add	a5,a5,a4
    8000289a:	e53c                	sd	a5,72(a0)
    8000289c:	a039                	j	800028aa <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000289e:	fd842503          	lw	a0,-40(s0)
    800028a2:	a62ff0ef          	jal	ra,80001b04 <growproc>
    800028a6:	00054863          	bltz	a0,800028b6 <sys_sbrk+0x70>
  }
  return addr;
}
    800028aa:	8526                	mv	a0,s1
    800028ac:	70a2                	ld	ra,40(sp)
    800028ae:	7402                	ld	s0,32(sp)
    800028b0:	64e2                	ld	s1,24(sp)
    800028b2:	6145                	addi	sp,sp,48
    800028b4:	8082                	ret
      return -1;
    800028b6:	54fd                	li	s1,-1
    800028b8:	bfcd                	j	800028aa <sys_sbrk+0x64>
      return -1;
    800028ba:	54fd                	li	s1,-1
    800028bc:	b7fd                	j	800028aa <sys_sbrk+0x64>
      return -1;
    800028be:	54fd                	li	s1,-1
    800028c0:	b7ed                	j	800028aa <sys_sbrk+0x64>

00000000800028c2 <sys_pause>:

uint64
sys_pause(void)
{
    800028c2:	7139                	addi	sp,sp,-64
    800028c4:	fc06                	sd	ra,56(sp)
    800028c6:	f822                	sd	s0,48(sp)
    800028c8:	f426                	sd	s1,40(sp)
    800028ca:	f04a                	sd	s2,32(sp)
    800028cc:	ec4e                	sd	s3,24(sp)
    800028ce:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800028d0:	fcc40593          	addi	a1,s0,-52
    800028d4:	4501                	li	a0,0
    800028d6:	e35ff0ef          	jal	ra,8000270a <argint>
  if(n < 0)
    800028da:	fcc42783          	lw	a5,-52(s0)
    800028de:	0607c563          	bltz	a5,80002948 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800028e2:	00013517          	auipc	a0,0x13
    800028e6:	ec650513          	addi	a0,a0,-314 # 800157a8 <tickslock>
    800028ea:	a80fe0ef          	jal	ra,80000b6a <acquire>
  ticks0 = ticks;
    800028ee:	00005917          	auipc	s2,0x5
    800028f2:	f8a92903          	lw	s2,-118(s2) # 80007878 <ticks>
  while(ticks - ticks0 < n){
    800028f6:	fcc42783          	lw	a5,-52(s0)
    800028fa:	cb8d                	beqz	a5,8000292c <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800028fc:	00013997          	auipc	s3,0x13
    80002900:	eac98993          	addi	s3,s3,-340 # 800157a8 <tickslock>
    80002904:	00005497          	auipc	s1,0x5
    80002908:	f7448493          	addi	s1,s1,-140 # 80007878 <ticks>
    if(killed(myproc())){
    8000290c:	ef7fe0ef          	jal	ra,80001802 <myproc>
    80002910:	f32ff0ef          	jal	ra,80002042 <killed>
    80002914:	ed0d                	bnez	a0,8000294e <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002916:	85ce                	mv	a1,s3
    80002918:	8526                	mv	a0,s1
    8000291a:	cf0ff0ef          	jal	ra,80001e0a <sleep>
  while(ticks - ticks0 < n){
    8000291e:	409c                	lw	a5,0(s1)
    80002920:	412787bb          	subw	a5,a5,s2
    80002924:	fcc42703          	lw	a4,-52(s0)
    80002928:	fee7e2e3          	bltu	a5,a4,8000290c <sys_pause+0x4a>
  }
  release(&tickslock);
    8000292c:	00013517          	auipc	a0,0x13
    80002930:	e7c50513          	addi	a0,a0,-388 # 800157a8 <tickslock>
    80002934:	acefe0ef          	jal	ra,80000c02 <release>
  return 0;
    80002938:	4501                	li	a0,0
}
    8000293a:	70e2                	ld	ra,56(sp)
    8000293c:	7442                	ld	s0,48(sp)
    8000293e:	74a2                	ld	s1,40(sp)
    80002940:	7902                	ld	s2,32(sp)
    80002942:	69e2                	ld	s3,24(sp)
    80002944:	6121                	addi	sp,sp,64
    80002946:	8082                	ret
    n = 0;
    80002948:	fc042623          	sw	zero,-52(s0)
    8000294c:	bf59                	j	800028e2 <sys_pause+0x20>
      release(&tickslock);
    8000294e:	00013517          	auipc	a0,0x13
    80002952:	e5a50513          	addi	a0,a0,-422 # 800157a8 <tickslock>
    80002956:	aacfe0ef          	jal	ra,80000c02 <release>
      return -1;
    8000295a:	557d                	li	a0,-1
    8000295c:	bff9                	j	8000293a <sys_pause+0x78>

000000008000295e <sys_kill>:

uint64
sys_kill(void)
{
    8000295e:	1101                	addi	sp,sp,-32
    80002960:	ec06                	sd	ra,24(sp)
    80002962:	e822                	sd	s0,16(sp)
    80002964:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002966:	fec40593          	addi	a1,s0,-20
    8000296a:	4501                	li	a0,0
    8000296c:	d9fff0ef          	jal	ra,8000270a <argint>
  return kkill(pid);
    80002970:	fec42503          	lw	a0,-20(s0)
    80002974:	e44ff0ef          	jal	ra,80001fb8 <kkill>
}
    80002978:	60e2                	ld	ra,24(sp)
    8000297a:	6442                	ld	s0,16(sp)
    8000297c:	6105                	addi	sp,sp,32
    8000297e:	8082                	ret

0000000080002980 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002980:	1101                	addi	sp,sp,-32
    80002982:	ec06                	sd	ra,24(sp)
    80002984:	e822                	sd	s0,16(sp)
    80002986:	e426                	sd	s1,8(sp)
    80002988:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000298a:	00013517          	auipc	a0,0x13
    8000298e:	e1e50513          	addi	a0,a0,-482 # 800157a8 <tickslock>
    80002992:	9d8fe0ef          	jal	ra,80000b6a <acquire>
  xticks = ticks;
    80002996:	00005497          	auipc	s1,0x5
    8000299a:	ee24a483          	lw	s1,-286(s1) # 80007878 <ticks>
  release(&tickslock);
    8000299e:	00013517          	auipc	a0,0x13
    800029a2:	e0a50513          	addi	a0,a0,-502 # 800157a8 <tickslock>
    800029a6:	a5cfe0ef          	jal	ra,80000c02 <release>
  return xticks;
}
    800029aa:	02049513          	slli	a0,s1,0x20
    800029ae:	9101                	srli	a0,a0,0x20
    800029b0:	60e2                	ld	ra,24(sp)
    800029b2:	6442                	ld	s0,16(sp)
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800029ba:	7179                	addi	sp,sp,-48
    800029bc:	f406                	sd	ra,40(sp)
    800029be:	f022                	sd	s0,32(sp)
    800029c0:	ec26                	sd	s1,24(sp)
    800029c2:	e84a                	sd	s2,16(sp)
    800029c4:	e44e                	sd	s3,8(sp)
    800029c6:	e052                	sd	s4,0(sp)
    800029c8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800029ca:	00005597          	auipc	a1,0x5
    800029ce:	ad658593          	addi	a1,a1,-1322 # 800074a0 <syscalls+0xb0>
    800029d2:	00013517          	auipc	a0,0x13
    800029d6:	dee50513          	addi	a0,a0,-530 # 800157c0 <bcache>
    800029da:	910fe0ef          	jal	ra,80000aea <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800029de:	0001b797          	auipc	a5,0x1b
    800029e2:	de278793          	addi	a5,a5,-542 # 8001d7c0 <bcache+0x8000>
    800029e6:	0001b717          	auipc	a4,0x1b
    800029ea:	04270713          	addi	a4,a4,66 # 8001da28 <bcache+0x8268>
    800029ee:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800029f2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800029f6:	00013497          	auipc	s1,0x13
    800029fa:	de248493          	addi	s1,s1,-542 # 800157d8 <bcache+0x18>
    b->next = bcache.head.next;
    800029fe:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002a00:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002a02:	00005a17          	auipc	s4,0x5
    80002a06:	aa6a0a13          	addi	s4,s4,-1370 # 800074a8 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002a0a:	2b893783          	ld	a5,696(s2)
    80002a0e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002a10:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002a14:	85d2                	mv	a1,s4
    80002a16:	01048513          	addi	a0,s1,16
    80002a1a:	302010ef          	jal	ra,80003d1c <initsleeplock>
    bcache.head.next->prev = b;
    80002a1e:	2b893783          	ld	a5,696(s2)
    80002a22:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002a24:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a28:	45848493          	addi	s1,s1,1112
    80002a2c:	fd349fe3          	bne	s1,s3,80002a0a <binit+0x50>
  }
}
    80002a30:	70a2                	ld	ra,40(sp)
    80002a32:	7402                	ld	s0,32(sp)
    80002a34:	64e2                	ld	s1,24(sp)
    80002a36:	6942                	ld	s2,16(sp)
    80002a38:	69a2                	ld	s3,8(sp)
    80002a3a:	6a02                	ld	s4,0(sp)
    80002a3c:	6145                	addi	sp,sp,48
    80002a3e:	8082                	ret

0000000080002a40 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002a40:	7179                	addi	sp,sp,-48
    80002a42:	f406                	sd	ra,40(sp)
    80002a44:	f022                	sd	s0,32(sp)
    80002a46:	ec26                	sd	s1,24(sp)
    80002a48:	e84a                	sd	s2,16(sp)
    80002a4a:	e44e                	sd	s3,8(sp)
    80002a4c:	1800                	addi	s0,sp,48
    80002a4e:	892a                	mv	s2,a0
    80002a50:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002a52:	00013517          	auipc	a0,0x13
    80002a56:	d6e50513          	addi	a0,a0,-658 # 800157c0 <bcache>
    80002a5a:	910fe0ef          	jal	ra,80000b6a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002a5e:	0001b497          	auipc	s1,0x1b
    80002a62:	01a4b483          	ld	s1,26(s1) # 8001da78 <bcache+0x82b8>
    80002a66:	0001b797          	auipc	a5,0x1b
    80002a6a:	fc278793          	addi	a5,a5,-62 # 8001da28 <bcache+0x8268>
    80002a6e:	02f48b63          	beq	s1,a5,80002aa4 <bread+0x64>
    80002a72:	873e                	mv	a4,a5
    80002a74:	a021                	j	80002a7c <bread+0x3c>
    80002a76:	68a4                	ld	s1,80(s1)
    80002a78:	02e48663          	beq	s1,a4,80002aa4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002a7c:	449c                	lw	a5,8(s1)
    80002a7e:	ff279ce3          	bne	a5,s2,80002a76 <bread+0x36>
    80002a82:	44dc                	lw	a5,12(s1)
    80002a84:	ff3799e3          	bne	a5,s3,80002a76 <bread+0x36>
      b->refcnt++;
    80002a88:	40bc                	lw	a5,64(s1)
    80002a8a:	2785                	addiw	a5,a5,1
    80002a8c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a8e:	00013517          	auipc	a0,0x13
    80002a92:	d3250513          	addi	a0,a0,-718 # 800157c0 <bcache>
    80002a96:	96cfe0ef          	jal	ra,80000c02 <release>
      acquiresleep(&b->lock);
    80002a9a:	01048513          	addi	a0,s1,16
    80002a9e:	2b4010ef          	jal	ra,80003d52 <acquiresleep>
      return b;
    80002aa2:	a889                	j	80002af4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002aa4:	0001b497          	auipc	s1,0x1b
    80002aa8:	fcc4b483          	ld	s1,-52(s1) # 8001da70 <bcache+0x82b0>
    80002aac:	0001b797          	auipc	a5,0x1b
    80002ab0:	f7c78793          	addi	a5,a5,-132 # 8001da28 <bcache+0x8268>
    80002ab4:	00f48863          	beq	s1,a5,80002ac4 <bread+0x84>
    80002ab8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002aba:	40bc                	lw	a5,64(s1)
    80002abc:	cb91                	beqz	a5,80002ad0 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002abe:	64a4                	ld	s1,72(s1)
    80002ac0:	fee49de3          	bne	s1,a4,80002aba <bread+0x7a>
  panic("bget: no buffers");
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	9ec50513          	addi	a0,a0,-1556 # 800074b0 <syscalls+0xc0>
    80002acc:	cbdfd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80002ad0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ad4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ad8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002adc:	4785                	li	a5,1
    80002ade:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ae0:	00013517          	auipc	a0,0x13
    80002ae4:	ce050513          	addi	a0,a0,-800 # 800157c0 <bcache>
    80002ae8:	91afe0ef          	jal	ra,80000c02 <release>
      acquiresleep(&b->lock);
    80002aec:	01048513          	addi	a0,s1,16
    80002af0:	262010ef          	jal	ra,80003d52 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002af4:	409c                	lw	a5,0(s1)
    80002af6:	cb89                	beqz	a5,80002b08 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002af8:	8526                	mv	a0,s1
    80002afa:	70a2                	ld	ra,40(sp)
    80002afc:	7402                	ld	s0,32(sp)
    80002afe:	64e2                	ld	s1,24(sp)
    80002b00:	6942                	ld	s2,16(sp)
    80002b02:	69a2                	ld	s3,8(sp)
    80002b04:	6145                	addi	sp,sp,48
    80002b06:	8082                	ret
    virtio_disk_rw(b, 0);
    80002b08:	4581                	li	a1,0
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	1bf020ef          	jal	ra,800054ca <virtio_disk_rw>
    b->valid = 1;
    80002b10:	4785                	li	a5,1
    80002b12:	c09c                	sw	a5,0(s1)
  return b;
    80002b14:	b7d5                	j	80002af8 <bread+0xb8>

0000000080002b16 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002b16:	1101                	addi	sp,sp,-32
    80002b18:	ec06                	sd	ra,24(sp)
    80002b1a:	e822                	sd	s0,16(sp)
    80002b1c:	e426                	sd	s1,8(sp)
    80002b1e:	1000                	addi	s0,sp,32
    80002b20:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b22:	0541                	addi	a0,a0,16
    80002b24:	2ac010ef          	jal	ra,80003dd0 <holdingsleep>
    80002b28:	c911                	beqz	a0,80002b3c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002b2a:	4585                	li	a1,1
    80002b2c:	8526                	mv	a0,s1
    80002b2e:	19d020ef          	jal	ra,800054ca <virtio_disk_rw>
}
    80002b32:	60e2                	ld	ra,24(sp)
    80002b34:	6442                	ld	s0,16(sp)
    80002b36:	64a2                	ld	s1,8(sp)
    80002b38:	6105                	addi	sp,sp,32
    80002b3a:	8082                	ret
    panic("bwrite");
    80002b3c:	00005517          	auipc	a0,0x5
    80002b40:	98c50513          	addi	a0,a0,-1652 # 800074c8 <syscalls+0xd8>
    80002b44:	c45fd0ef          	jal	ra,80000788 <panic>

0000000080002b48 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	e04a                	sd	s2,0(sp)
    80002b52:	1000                	addi	s0,sp,32
    80002b54:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b56:	01050913          	addi	s2,a0,16
    80002b5a:	854a                	mv	a0,s2
    80002b5c:	274010ef          	jal	ra,80003dd0 <holdingsleep>
    80002b60:	c13d                	beqz	a0,80002bc6 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002b62:	854a                	mv	a0,s2
    80002b64:	234010ef          	jal	ra,80003d98 <releasesleep>

  acquire(&bcache.lock);
    80002b68:	00013517          	auipc	a0,0x13
    80002b6c:	c5850513          	addi	a0,a0,-936 # 800157c0 <bcache>
    80002b70:	ffbfd0ef          	jal	ra,80000b6a <acquire>
  b->refcnt--;
    80002b74:	40bc                	lw	a5,64(s1)
    80002b76:	37fd                	addiw	a5,a5,-1
    80002b78:	0007871b          	sext.w	a4,a5
    80002b7c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002b7e:	eb05                	bnez	a4,80002bae <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002b80:	68bc                	ld	a5,80(s1)
    80002b82:	64b8                	ld	a4,72(s1)
    80002b84:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002b86:	64bc                	ld	a5,72(s1)
    80002b88:	68b8                	ld	a4,80(s1)
    80002b8a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002b8c:	0001b797          	auipc	a5,0x1b
    80002b90:	c3478793          	addi	a5,a5,-972 # 8001d7c0 <bcache+0x8000>
    80002b94:	2b87b703          	ld	a4,696(a5)
    80002b98:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002b9a:	0001b717          	auipc	a4,0x1b
    80002b9e:	e8e70713          	addi	a4,a4,-370 # 8001da28 <bcache+0x8268>
    80002ba2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ba4:	2b87b703          	ld	a4,696(a5)
    80002ba8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002baa:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002bae:	00013517          	auipc	a0,0x13
    80002bb2:	c1250513          	addi	a0,a0,-1006 # 800157c0 <bcache>
    80002bb6:	84cfe0ef          	jal	ra,80000c02 <release>
}
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6902                	ld	s2,0(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret
    panic("brelse");
    80002bc6:	00005517          	auipc	a0,0x5
    80002bca:	90a50513          	addi	a0,a0,-1782 # 800074d0 <syscalls+0xe0>
    80002bce:	bbbfd0ef          	jal	ra,80000788 <panic>

0000000080002bd2 <bpin>:

void
bpin(struct buf *b) {
    80002bd2:	1101                	addi	sp,sp,-32
    80002bd4:	ec06                	sd	ra,24(sp)
    80002bd6:	e822                	sd	s0,16(sp)
    80002bd8:	e426                	sd	s1,8(sp)
    80002bda:	1000                	addi	s0,sp,32
    80002bdc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002bde:	00013517          	auipc	a0,0x13
    80002be2:	be250513          	addi	a0,a0,-1054 # 800157c0 <bcache>
    80002be6:	f85fd0ef          	jal	ra,80000b6a <acquire>
  b->refcnt++;
    80002bea:	40bc                	lw	a5,64(s1)
    80002bec:	2785                	addiw	a5,a5,1
    80002bee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002bf0:	00013517          	auipc	a0,0x13
    80002bf4:	bd050513          	addi	a0,a0,-1072 # 800157c0 <bcache>
    80002bf8:	80afe0ef          	jal	ra,80000c02 <release>
}
    80002bfc:	60e2                	ld	ra,24(sp)
    80002bfe:	6442                	ld	s0,16(sp)
    80002c00:	64a2                	ld	s1,8(sp)
    80002c02:	6105                	addi	sp,sp,32
    80002c04:	8082                	ret

0000000080002c06 <bunpin>:

void
bunpin(struct buf *b) {
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	1000                	addi	s0,sp,32
    80002c10:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c12:	00013517          	auipc	a0,0x13
    80002c16:	bae50513          	addi	a0,a0,-1106 # 800157c0 <bcache>
    80002c1a:	f51fd0ef          	jal	ra,80000b6a <acquire>
  b->refcnt--;
    80002c1e:	40bc                	lw	a5,64(s1)
    80002c20:	37fd                	addiw	a5,a5,-1
    80002c22:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c24:	00013517          	auipc	a0,0x13
    80002c28:	b9c50513          	addi	a0,a0,-1124 # 800157c0 <bcache>
    80002c2c:	fd7fd0ef          	jal	ra,80000c02 <release>
}
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	64a2                	ld	s1,8(sp)
    80002c36:	6105                	addi	sp,sp,32
    80002c38:	8082                	ret

0000000080002c3a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	e04a                	sd	s2,0(sp)
    80002c44:	1000                	addi	s0,sp,32
    80002c46:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002c48:	00d5d59b          	srliw	a1,a1,0xd
    80002c4c:	0001b797          	auipc	a5,0x1b
    80002c50:	2507a783          	lw	a5,592(a5) # 8001de9c <sb+0x1c>
    80002c54:	9dbd                	addw	a1,a1,a5
    80002c56:	debff0ef          	jal	ra,80002a40 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002c5a:	0074f713          	andi	a4,s1,7
    80002c5e:	4785                	li	a5,1
    80002c60:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002c64:	14ce                	slli	s1,s1,0x33
    80002c66:	90d9                	srli	s1,s1,0x36
    80002c68:	00950733          	add	a4,a0,s1
    80002c6c:	05874703          	lbu	a4,88(a4)
    80002c70:	00e7f6b3          	and	a3,a5,a4
    80002c74:	c29d                	beqz	a3,80002c9a <bfree+0x60>
    80002c76:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002c78:	94aa                	add	s1,s1,a0
    80002c7a:	fff7c793          	not	a5,a5
    80002c7e:	8f7d                	and	a4,a4,a5
    80002c80:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002c84:	7d7000ef          	jal	ra,80003c5a <log_write>
  brelse(bp);
    80002c88:	854a                	mv	a0,s2
    80002c8a:	ebfff0ef          	jal	ra,80002b48 <brelse>
}
    80002c8e:	60e2                	ld	ra,24(sp)
    80002c90:	6442                	ld	s0,16(sp)
    80002c92:	64a2                	ld	s1,8(sp)
    80002c94:	6902                	ld	s2,0(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret
    panic("freeing free block");
    80002c9a:	00005517          	auipc	a0,0x5
    80002c9e:	83e50513          	addi	a0,a0,-1986 # 800074d8 <syscalls+0xe8>
    80002ca2:	ae7fd0ef          	jal	ra,80000788 <panic>

0000000080002ca6 <balloc>:
{
    80002ca6:	711d                	addi	sp,sp,-96
    80002ca8:	ec86                	sd	ra,88(sp)
    80002caa:	e8a2                	sd	s0,80(sp)
    80002cac:	e4a6                	sd	s1,72(sp)
    80002cae:	e0ca                	sd	s2,64(sp)
    80002cb0:	fc4e                	sd	s3,56(sp)
    80002cb2:	f852                	sd	s4,48(sp)
    80002cb4:	f456                	sd	s5,40(sp)
    80002cb6:	f05a                	sd	s6,32(sp)
    80002cb8:	ec5e                	sd	s7,24(sp)
    80002cba:	e862                	sd	s8,16(sp)
    80002cbc:	e466                	sd	s9,8(sp)
    80002cbe:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002cc0:	0001b797          	auipc	a5,0x1b
    80002cc4:	1c47a783          	lw	a5,452(a5) # 8001de84 <sb+0x4>
    80002cc8:	cff1                	beqz	a5,80002da4 <balloc+0xfe>
    80002cca:	8baa                	mv	s7,a0
    80002ccc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002cce:	0001bb17          	auipc	s6,0x1b
    80002cd2:	1b2b0b13          	addi	s6,s6,434 # 8001de80 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002cd6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002cd8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002cda:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002cdc:	6c89                	lui	s9,0x2
    80002cde:	a0b5                	j	80002d4a <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ce0:	97ca                	add	a5,a5,s2
    80002ce2:	8e55                	or	a2,a2,a3
    80002ce4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ce8:	854a                	mv	a0,s2
    80002cea:	771000ef          	jal	ra,80003c5a <log_write>
        brelse(bp);
    80002cee:	854a                	mv	a0,s2
    80002cf0:	e59ff0ef          	jal	ra,80002b48 <brelse>
  bp = bread(dev, bno);
    80002cf4:	85a6                	mv	a1,s1
    80002cf6:	855e                	mv	a0,s7
    80002cf8:	d49ff0ef          	jal	ra,80002a40 <bread>
    80002cfc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002cfe:	40000613          	li	a2,1024
    80002d02:	4581                	li	a1,0
    80002d04:	05850513          	addi	a0,a0,88
    80002d08:	f37fd0ef          	jal	ra,80000c3e <memset>
  log_write(bp);
    80002d0c:	854a                	mv	a0,s2
    80002d0e:	74d000ef          	jal	ra,80003c5a <log_write>
  brelse(bp);
    80002d12:	854a                	mv	a0,s2
    80002d14:	e35ff0ef          	jal	ra,80002b48 <brelse>
}
    80002d18:	8526                	mv	a0,s1
    80002d1a:	60e6                	ld	ra,88(sp)
    80002d1c:	6446                	ld	s0,80(sp)
    80002d1e:	64a6                	ld	s1,72(sp)
    80002d20:	6906                	ld	s2,64(sp)
    80002d22:	79e2                	ld	s3,56(sp)
    80002d24:	7a42                	ld	s4,48(sp)
    80002d26:	7aa2                	ld	s5,40(sp)
    80002d28:	7b02                	ld	s6,32(sp)
    80002d2a:	6be2                	ld	s7,24(sp)
    80002d2c:	6c42                	ld	s8,16(sp)
    80002d2e:	6ca2                	ld	s9,8(sp)
    80002d30:	6125                	addi	sp,sp,96
    80002d32:	8082                	ret
    brelse(bp);
    80002d34:	854a                	mv	a0,s2
    80002d36:	e13ff0ef          	jal	ra,80002b48 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002d3a:	015c87bb          	addw	a5,s9,s5
    80002d3e:	00078a9b          	sext.w	s5,a5
    80002d42:	004b2703          	lw	a4,4(s6)
    80002d46:	04eaff63          	bgeu	s5,a4,80002da4 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002d4a:	41fad79b          	sraiw	a5,s5,0x1f
    80002d4e:	0137d79b          	srliw	a5,a5,0x13
    80002d52:	015787bb          	addw	a5,a5,s5
    80002d56:	40d7d79b          	sraiw	a5,a5,0xd
    80002d5a:	01cb2583          	lw	a1,28(s6)
    80002d5e:	9dbd                	addw	a1,a1,a5
    80002d60:	855e                	mv	a0,s7
    80002d62:	cdfff0ef          	jal	ra,80002a40 <bread>
    80002d66:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d68:	004b2503          	lw	a0,4(s6)
    80002d6c:	000a849b          	sext.w	s1,s5
    80002d70:	8762                	mv	a4,s8
    80002d72:	fca4f1e3          	bgeu	s1,a0,80002d34 <balloc+0x8e>
      m = 1 << (bi % 8);
    80002d76:	00777693          	andi	a3,a4,7
    80002d7a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002d7e:	41f7579b          	sraiw	a5,a4,0x1f
    80002d82:	01d7d79b          	srliw	a5,a5,0x1d
    80002d86:	9fb9                	addw	a5,a5,a4
    80002d88:	4037d79b          	sraiw	a5,a5,0x3
    80002d8c:	00f90633          	add	a2,s2,a5
    80002d90:	05864603          	lbu	a2,88(a2)
    80002d94:	00c6f5b3          	and	a1,a3,a2
    80002d98:	d5a1                	beqz	a1,80002ce0 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d9a:	2705                	addiw	a4,a4,1
    80002d9c:	2485                	addiw	s1,s1,1
    80002d9e:	fd471ae3          	bne	a4,s4,80002d72 <balloc+0xcc>
    80002da2:	bf49                	j	80002d34 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80002da4:	00004517          	auipc	a0,0x4
    80002da8:	74c50513          	addi	a0,a0,1868 # 800074f0 <syscalls+0x100>
    80002dac:	f16fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    80002db0:	4481                	li	s1,0
    80002db2:	b79d                	j	80002d18 <balloc+0x72>

0000000080002db4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002db4:	7179                	addi	sp,sp,-48
    80002db6:	f406                	sd	ra,40(sp)
    80002db8:	f022                	sd	s0,32(sp)
    80002dba:	ec26                	sd	s1,24(sp)
    80002dbc:	e84a                	sd	s2,16(sp)
    80002dbe:	e44e                	sd	s3,8(sp)
    80002dc0:	e052                	sd	s4,0(sp)
    80002dc2:	1800                	addi	s0,sp,48
    80002dc4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002dc6:	47ad                	li	a5,11
    80002dc8:	02b7e663          	bltu	a5,a1,80002df4 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80002dcc:	02059793          	slli	a5,a1,0x20
    80002dd0:	01e7d593          	srli	a1,a5,0x1e
    80002dd4:	00b504b3          	add	s1,a0,a1
    80002dd8:	0504a903          	lw	s2,80(s1)
    80002ddc:	06091663          	bnez	s2,80002e48 <bmap+0x94>
      addr = balloc(ip->dev);
    80002de0:	4108                	lw	a0,0(a0)
    80002de2:	ec5ff0ef          	jal	ra,80002ca6 <balloc>
    80002de6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002dea:	04090f63          	beqz	s2,80002e48 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80002dee:	0524a823          	sw	s2,80(s1)
    80002df2:	a899                	j	80002e48 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002df4:	ff45849b          	addiw	s1,a1,-12
    80002df8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002dfc:	0ff00793          	li	a5,255
    80002e00:	06e7eb63          	bltu	a5,a4,80002e76 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002e04:	08052903          	lw	s2,128(a0)
    80002e08:	00091b63          	bnez	s2,80002e1e <bmap+0x6a>
      addr = balloc(ip->dev);
    80002e0c:	4108                	lw	a0,0(a0)
    80002e0e:	e99ff0ef          	jal	ra,80002ca6 <balloc>
    80002e12:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e16:	02090963          	beqz	s2,80002e48 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002e1a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002e1e:	85ca                	mv	a1,s2
    80002e20:	0009a503          	lw	a0,0(s3)
    80002e24:	c1dff0ef          	jal	ra,80002a40 <bread>
    80002e28:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002e2a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002e2e:	02049713          	slli	a4,s1,0x20
    80002e32:	01e75593          	srli	a1,a4,0x1e
    80002e36:	00b784b3          	add	s1,a5,a1
    80002e3a:	0004a903          	lw	s2,0(s1)
    80002e3e:	00090e63          	beqz	s2,80002e5a <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002e42:	8552                	mv	a0,s4
    80002e44:	d05ff0ef          	jal	ra,80002b48 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002e48:	854a                	mv	a0,s2
    80002e4a:	70a2                	ld	ra,40(sp)
    80002e4c:	7402                	ld	s0,32(sp)
    80002e4e:	64e2                	ld	s1,24(sp)
    80002e50:	6942                	ld	s2,16(sp)
    80002e52:	69a2                	ld	s3,8(sp)
    80002e54:	6a02                	ld	s4,0(sp)
    80002e56:	6145                	addi	sp,sp,48
    80002e58:	8082                	ret
      addr = balloc(ip->dev);
    80002e5a:	0009a503          	lw	a0,0(s3)
    80002e5e:	e49ff0ef          	jal	ra,80002ca6 <balloc>
    80002e62:	0005091b          	sext.w	s2,a0
      if(addr){
    80002e66:	fc090ee3          	beqz	s2,80002e42 <bmap+0x8e>
        a[bn] = addr;
    80002e6a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002e6e:	8552                	mv	a0,s4
    80002e70:	5eb000ef          	jal	ra,80003c5a <log_write>
    80002e74:	b7f9                	j	80002e42 <bmap+0x8e>
  panic("bmap: out of range");
    80002e76:	00004517          	auipc	a0,0x4
    80002e7a:	69250513          	addi	a0,a0,1682 # 80007508 <syscalls+0x118>
    80002e7e:	90bfd0ef          	jal	ra,80000788 <panic>

0000000080002e82 <iget>:
{
    80002e82:	7179                	addi	sp,sp,-48
    80002e84:	f406                	sd	ra,40(sp)
    80002e86:	f022                	sd	s0,32(sp)
    80002e88:	ec26                	sd	s1,24(sp)
    80002e8a:	e84a                	sd	s2,16(sp)
    80002e8c:	e44e                	sd	s3,8(sp)
    80002e8e:	e052                	sd	s4,0(sp)
    80002e90:	1800                	addi	s0,sp,48
    80002e92:	89aa                	mv	s3,a0
    80002e94:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002e96:	0001b517          	auipc	a0,0x1b
    80002e9a:	00a50513          	addi	a0,a0,10 # 8001dea0 <itable>
    80002e9e:	ccdfd0ef          	jal	ra,80000b6a <acquire>
  empty = 0;
    80002ea2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002ea4:	0001b497          	auipc	s1,0x1b
    80002ea8:	01448493          	addi	s1,s1,20 # 8001deb8 <itable+0x18>
    80002eac:	0001d697          	auipc	a3,0x1d
    80002eb0:	a9c68693          	addi	a3,a3,-1380 # 8001f948 <log>
    80002eb4:	a039                	j	80002ec2 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002eb6:	02090963          	beqz	s2,80002ee8 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002eba:	08848493          	addi	s1,s1,136
    80002ebe:	02d48863          	beq	s1,a3,80002eee <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002ec2:	449c                	lw	a5,8(s1)
    80002ec4:	fef059e3          	blez	a5,80002eb6 <iget+0x34>
    80002ec8:	4098                	lw	a4,0(s1)
    80002eca:	ff3716e3          	bne	a4,s3,80002eb6 <iget+0x34>
    80002ece:	40d8                	lw	a4,4(s1)
    80002ed0:	ff4713e3          	bne	a4,s4,80002eb6 <iget+0x34>
      ip->ref++;
    80002ed4:	2785                	addiw	a5,a5,1
    80002ed6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ed8:	0001b517          	auipc	a0,0x1b
    80002edc:	fc850513          	addi	a0,a0,-56 # 8001dea0 <itable>
    80002ee0:	d23fd0ef          	jal	ra,80000c02 <release>
      return ip;
    80002ee4:	8926                	mv	s2,s1
    80002ee6:	a02d                	j	80002f10 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ee8:	fbe9                	bnez	a5,80002eba <iget+0x38>
    80002eea:	8926                	mv	s2,s1
    80002eec:	b7f9                	j	80002eba <iget+0x38>
  if(empty == 0)
    80002eee:	02090a63          	beqz	s2,80002f22 <iget+0xa0>
  ip->dev = dev;
    80002ef2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002ef6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002efa:	4785                	li	a5,1
    80002efc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002f00:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002f04:	0001b517          	auipc	a0,0x1b
    80002f08:	f9c50513          	addi	a0,a0,-100 # 8001dea0 <itable>
    80002f0c:	cf7fd0ef          	jal	ra,80000c02 <release>
}
    80002f10:	854a                	mv	a0,s2
    80002f12:	70a2                	ld	ra,40(sp)
    80002f14:	7402                	ld	s0,32(sp)
    80002f16:	64e2                	ld	s1,24(sp)
    80002f18:	6942                	ld	s2,16(sp)
    80002f1a:	69a2                	ld	s3,8(sp)
    80002f1c:	6a02                	ld	s4,0(sp)
    80002f1e:	6145                	addi	sp,sp,48
    80002f20:	8082                	ret
    panic("iget: no inodes");
    80002f22:	00004517          	auipc	a0,0x4
    80002f26:	5fe50513          	addi	a0,a0,1534 # 80007520 <syscalls+0x130>
    80002f2a:	85ffd0ef          	jal	ra,80000788 <panic>

0000000080002f2e <iinit>:
{
    80002f2e:	7179                	addi	sp,sp,-48
    80002f30:	f406                	sd	ra,40(sp)
    80002f32:	f022                	sd	s0,32(sp)
    80002f34:	ec26                	sd	s1,24(sp)
    80002f36:	e84a                	sd	s2,16(sp)
    80002f38:	e44e                	sd	s3,8(sp)
    80002f3a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002f3c:	00004597          	auipc	a1,0x4
    80002f40:	5f458593          	addi	a1,a1,1524 # 80007530 <syscalls+0x140>
    80002f44:	0001b517          	auipc	a0,0x1b
    80002f48:	f5c50513          	addi	a0,a0,-164 # 8001dea0 <itable>
    80002f4c:	b9ffd0ef          	jal	ra,80000aea <initlock>
  for(i = 0; i < NINODE; i++) {
    80002f50:	0001b497          	auipc	s1,0x1b
    80002f54:	f7848493          	addi	s1,s1,-136 # 8001dec8 <itable+0x28>
    80002f58:	0001d997          	auipc	s3,0x1d
    80002f5c:	a0098993          	addi	s3,s3,-1536 # 8001f958 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002f60:	00004917          	auipc	s2,0x4
    80002f64:	5d890913          	addi	s2,s2,1496 # 80007538 <syscalls+0x148>
    80002f68:	85ca                	mv	a1,s2
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	5b1000ef          	jal	ra,80003d1c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002f70:	08848493          	addi	s1,s1,136
    80002f74:	ff349ae3          	bne	s1,s3,80002f68 <iinit+0x3a>
}
    80002f78:	70a2                	ld	ra,40(sp)
    80002f7a:	7402                	ld	s0,32(sp)
    80002f7c:	64e2                	ld	s1,24(sp)
    80002f7e:	6942                	ld	s2,16(sp)
    80002f80:	69a2                	ld	s3,8(sp)
    80002f82:	6145                	addi	sp,sp,48
    80002f84:	8082                	ret

0000000080002f86 <ialloc>:
{
    80002f86:	715d                	addi	sp,sp,-80
    80002f88:	e486                	sd	ra,72(sp)
    80002f8a:	e0a2                	sd	s0,64(sp)
    80002f8c:	fc26                	sd	s1,56(sp)
    80002f8e:	f84a                	sd	s2,48(sp)
    80002f90:	f44e                	sd	s3,40(sp)
    80002f92:	f052                	sd	s4,32(sp)
    80002f94:	ec56                	sd	s5,24(sp)
    80002f96:	e85a                	sd	s6,16(sp)
    80002f98:	e45e                	sd	s7,8(sp)
    80002f9a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002f9c:	0001b717          	auipc	a4,0x1b
    80002fa0:	ef072703          	lw	a4,-272(a4) # 8001de8c <sb+0xc>
    80002fa4:	4785                	li	a5,1
    80002fa6:	04e7f663          	bgeu	a5,a4,80002ff2 <ialloc+0x6c>
    80002faa:	8aaa                	mv	s5,a0
    80002fac:	8bae                	mv	s7,a1
    80002fae:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002fb0:	0001ba17          	auipc	s4,0x1b
    80002fb4:	ed0a0a13          	addi	s4,s4,-304 # 8001de80 <sb>
    80002fb8:	00048b1b          	sext.w	s6,s1
    80002fbc:	0044d593          	srli	a1,s1,0x4
    80002fc0:	018a2783          	lw	a5,24(s4)
    80002fc4:	9dbd                	addw	a1,a1,a5
    80002fc6:	8556                	mv	a0,s5
    80002fc8:	a79ff0ef          	jal	ra,80002a40 <bread>
    80002fcc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002fce:	05850993          	addi	s3,a0,88
    80002fd2:	00f4f793          	andi	a5,s1,15
    80002fd6:	079a                	slli	a5,a5,0x6
    80002fd8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002fda:	00099783          	lh	a5,0(s3)
    80002fde:	cf85                	beqz	a5,80003016 <ialloc+0x90>
    brelse(bp);
    80002fe0:	b69ff0ef          	jal	ra,80002b48 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002fe4:	0485                	addi	s1,s1,1
    80002fe6:	00ca2703          	lw	a4,12(s4)
    80002fea:	0004879b          	sext.w	a5,s1
    80002fee:	fce7e5e3          	bltu	a5,a4,80002fb8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002ff2:	00004517          	auipc	a0,0x4
    80002ff6:	54e50513          	addi	a0,a0,1358 # 80007540 <syscalls+0x150>
    80002ffa:	cc8fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    80002ffe:	4501                	li	a0,0
}
    80003000:	60a6                	ld	ra,72(sp)
    80003002:	6406                	ld	s0,64(sp)
    80003004:	74e2                	ld	s1,56(sp)
    80003006:	7942                	ld	s2,48(sp)
    80003008:	79a2                	ld	s3,40(sp)
    8000300a:	7a02                	ld	s4,32(sp)
    8000300c:	6ae2                	ld	s5,24(sp)
    8000300e:	6b42                	ld	s6,16(sp)
    80003010:	6ba2                	ld	s7,8(sp)
    80003012:	6161                	addi	sp,sp,80
    80003014:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003016:	04000613          	li	a2,64
    8000301a:	4581                	li	a1,0
    8000301c:	854e                	mv	a0,s3
    8000301e:	c21fd0ef          	jal	ra,80000c3e <memset>
      dip->type = type;
    80003022:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003026:	854a                	mv	a0,s2
    80003028:	433000ef          	jal	ra,80003c5a <log_write>
      brelse(bp);
    8000302c:	854a                	mv	a0,s2
    8000302e:	b1bff0ef          	jal	ra,80002b48 <brelse>
      return iget(dev, inum);
    80003032:	85da                	mv	a1,s6
    80003034:	8556                	mv	a0,s5
    80003036:	e4dff0ef          	jal	ra,80002e82 <iget>
    8000303a:	b7d9                	j	80003000 <ialloc+0x7a>

000000008000303c <iupdate>:
{
    8000303c:	1101                	addi	sp,sp,-32
    8000303e:	ec06                	sd	ra,24(sp)
    80003040:	e822                	sd	s0,16(sp)
    80003042:	e426                	sd	s1,8(sp)
    80003044:	e04a                	sd	s2,0(sp)
    80003046:	1000                	addi	s0,sp,32
    80003048:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000304a:	415c                	lw	a5,4(a0)
    8000304c:	0047d79b          	srliw	a5,a5,0x4
    80003050:	0001b597          	auipc	a1,0x1b
    80003054:	e485a583          	lw	a1,-440(a1) # 8001de98 <sb+0x18>
    80003058:	9dbd                	addw	a1,a1,a5
    8000305a:	4108                	lw	a0,0(a0)
    8000305c:	9e5ff0ef          	jal	ra,80002a40 <bread>
    80003060:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003062:	05850793          	addi	a5,a0,88
    80003066:	40d8                	lw	a4,4(s1)
    80003068:	8b3d                	andi	a4,a4,15
    8000306a:	071a                	slli	a4,a4,0x6
    8000306c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000306e:	04449703          	lh	a4,68(s1)
    80003072:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003076:	04649703          	lh	a4,70(s1)
    8000307a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000307e:	04849703          	lh	a4,72(s1)
    80003082:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003086:	04a49703          	lh	a4,74(s1)
    8000308a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000308e:	44f8                	lw	a4,76(s1)
    80003090:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003092:	03400613          	li	a2,52
    80003096:	05048593          	addi	a1,s1,80
    8000309a:	00c78513          	addi	a0,a5,12
    8000309e:	bfdfd0ef          	jal	ra,80000c9a <memmove>
  log_write(bp);
    800030a2:	854a                	mv	a0,s2
    800030a4:	3b7000ef          	jal	ra,80003c5a <log_write>
  brelse(bp);
    800030a8:	854a                	mv	a0,s2
    800030aa:	a9fff0ef          	jal	ra,80002b48 <brelse>
}
    800030ae:	60e2                	ld	ra,24(sp)
    800030b0:	6442                	ld	s0,16(sp)
    800030b2:	64a2                	ld	s1,8(sp)
    800030b4:	6902                	ld	s2,0(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret

00000000800030ba <idup>:
{
    800030ba:	1101                	addi	sp,sp,-32
    800030bc:	ec06                	sd	ra,24(sp)
    800030be:	e822                	sd	s0,16(sp)
    800030c0:	e426                	sd	s1,8(sp)
    800030c2:	1000                	addi	s0,sp,32
    800030c4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800030c6:	0001b517          	auipc	a0,0x1b
    800030ca:	dda50513          	addi	a0,a0,-550 # 8001dea0 <itable>
    800030ce:	a9dfd0ef          	jal	ra,80000b6a <acquire>
  ip->ref++;
    800030d2:	449c                	lw	a5,8(s1)
    800030d4:	2785                	addiw	a5,a5,1
    800030d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800030d8:	0001b517          	auipc	a0,0x1b
    800030dc:	dc850513          	addi	a0,a0,-568 # 8001dea0 <itable>
    800030e0:	b23fd0ef          	jal	ra,80000c02 <release>
}
    800030e4:	8526                	mv	a0,s1
    800030e6:	60e2                	ld	ra,24(sp)
    800030e8:	6442                	ld	s0,16(sp)
    800030ea:	64a2                	ld	s1,8(sp)
    800030ec:	6105                	addi	sp,sp,32
    800030ee:	8082                	ret

00000000800030f0 <ilock>:
{
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	e426                	sd	s1,8(sp)
    800030f8:	e04a                	sd	s2,0(sp)
    800030fa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800030fc:	c105                	beqz	a0,8000311c <ilock+0x2c>
    800030fe:	84aa                	mv	s1,a0
    80003100:	451c                	lw	a5,8(a0)
    80003102:	00f05d63          	blez	a5,8000311c <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003106:	0541                	addi	a0,a0,16
    80003108:	44b000ef          	jal	ra,80003d52 <acquiresleep>
  if(ip->valid == 0){
    8000310c:	40bc                	lw	a5,64(s1)
    8000310e:	cf89                	beqz	a5,80003128 <ilock+0x38>
}
    80003110:	60e2                	ld	ra,24(sp)
    80003112:	6442                	ld	s0,16(sp)
    80003114:	64a2                	ld	s1,8(sp)
    80003116:	6902                	ld	s2,0(sp)
    80003118:	6105                	addi	sp,sp,32
    8000311a:	8082                	ret
    panic("ilock");
    8000311c:	00004517          	auipc	a0,0x4
    80003120:	43c50513          	addi	a0,a0,1084 # 80007558 <syscalls+0x168>
    80003124:	e64fd0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003128:	40dc                	lw	a5,4(s1)
    8000312a:	0047d79b          	srliw	a5,a5,0x4
    8000312e:	0001b597          	auipc	a1,0x1b
    80003132:	d6a5a583          	lw	a1,-662(a1) # 8001de98 <sb+0x18>
    80003136:	9dbd                	addw	a1,a1,a5
    80003138:	4088                	lw	a0,0(s1)
    8000313a:	907ff0ef          	jal	ra,80002a40 <bread>
    8000313e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003140:	05850593          	addi	a1,a0,88
    80003144:	40dc                	lw	a5,4(s1)
    80003146:	8bbd                	andi	a5,a5,15
    80003148:	079a                	slli	a5,a5,0x6
    8000314a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000314c:	00059783          	lh	a5,0(a1)
    80003150:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003154:	00259783          	lh	a5,2(a1)
    80003158:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000315c:	00459783          	lh	a5,4(a1)
    80003160:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003164:	00659783          	lh	a5,6(a1)
    80003168:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000316c:	459c                	lw	a5,8(a1)
    8000316e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003170:	03400613          	li	a2,52
    80003174:	05b1                	addi	a1,a1,12
    80003176:	05048513          	addi	a0,s1,80
    8000317a:	b21fd0ef          	jal	ra,80000c9a <memmove>
    brelse(bp);
    8000317e:	854a                	mv	a0,s2
    80003180:	9c9ff0ef          	jal	ra,80002b48 <brelse>
    ip->valid = 1;
    80003184:	4785                	li	a5,1
    80003186:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003188:	04449783          	lh	a5,68(s1)
    8000318c:	f3d1                	bnez	a5,80003110 <ilock+0x20>
      panic("ilock: no type");
    8000318e:	00004517          	auipc	a0,0x4
    80003192:	3d250513          	addi	a0,a0,978 # 80007560 <syscalls+0x170>
    80003196:	df2fd0ef          	jal	ra,80000788 <panic>

000000008000319a <iunlock>:
{
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	e426                	sd	s1,8(sp)
    800031a2:	e04a                	sd	s2,0(sp)
    800031a4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800031a6:	c505                	beqz	a0,800031ce <iunlock+0x34>
    800031a8:	84aa                	mv	s1,a0
    800031aa:	01050913          	addi	s2,a0,16
    800031ae:	854a                	mv	a0,s2
    800031b0:	421000ef          	jal	ra,80003dd0 <holdingsleep>
    800031b4:	cd09                	beqz	a0,800031ce <iunlock+0x34>
    800031b6:	449c                	lw	a5,8(s1)
    800031b8:	00f05b63          	blez	a5,800031ce <iunlock+0x34>
  releasesleep(&ip->lock);
    800031bc:	854a                	mv	a0,s2
    800031be:	3db000ef          	jal	ra,80003d98 <releasesleep>
}
    800031c2:	60e2                	ld	ra,24(sp)
    800031c4:	6442                	ld	s0,16(sp)
    800031c6:	64a2                	ld	s1,8(sp)
    800031c8:	6902                	ld	s2,0(sp)
    800031ca:	6105                	addi	sp,sp,32
    800031cc:	8082                	ret
    panic("iunlock");
    800031ce:	00004517          	auipc	a0,0x4
    800031d2:	3a250513          	addi	a0,a0,930 # 80007570 <syscalls+0x180>
    800031d6:	db2fd0ef          	jal	ra,80000788 <panic>

00000000800031da <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800031da:	7179                	addi	sp,sp,-48
    800031dc:	f406                	sd	ra,40(sp)
    800031de:	f022                	sd	s0,32(sp)
    800031e0:	ec26                	sd	s1,24(sp)
    800031e2:	e84a                	sd	s2,16(sp)
    800031e4:	e44e                	sd	s3,8(sp)
    800031e6:	e052                	sd	s4,0(sp)
    800031e8:	1800                	addi	s0,sp,48
    800031ea:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800031ec:	05050493          	addi	s1,a0,80
    800031f0:	08050913          	addi	s2,a0,128
    800031f4:	a021                	j	800031fc <itrunc+0x22>
    800031f6:	0491                	addi	s1,s1,4
    800031f8:	01248b63          	beq	s1,s2,8000320e <itrunc+0x34>
    if(ip->addrs[i]){
    800031fc:	408c                	lw	a1,0(s1)
    800031fe:	dde5                	beqz	a1,800031f6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003200:	0009a503          	lw	a0,0(s3)
    80003204:	a37ff0ef          	jal	ra,80002c3a <bfree>
      ip->addrs[i] = 0;
    80003208:	0004a023          	sw	zero,0(s1)
    8000320c:	b7ed                	j	800031f6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000320e:	0809a583          	lw	a1,128(s3)
    80003212:	ed91                	bnez	a1,8000322e <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003214:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003218:	854e                	mv	a0,s3
    8000321a:	e23ff0ef          	jal	ra,8000303c <iupdate>
}
    8000321e:	70a2                	ld	ra,40(sp)
    80003220:	7402                	ld	s0,32(sp)
    80003222:	64e2                	ld	s1,24(sp)
    80003224:	6942                	ld	s2,16(sp)
    80003226:	69a2                	ld	s3,8(sp)
    80003228:	6a02                	ld	s4,0(sp)
    8000322a:	6145                	addi	sp,sp,48
    8000322c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000322e:	0009a503          	lw	a0,0(s3)
    80003232:	80fff0ef          	jal	ra,80002a40 <bread>
    80003236:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003238:	05850493          	addi	s1,a0,88
    8000323c:	45850913          	addi	s2,a0,1112
    80003240:	a021                	j	80003248 <itrunc+0x6e>
    80003242:	0491                	addi	s1,s1,4
    80003244:	01248963          	beq	s1,s2,80003256 <itrunc+0x7c>
      if(a[j])
    80003248:	408c                	lw	a1,0(s1)
    8000324a:	dde5                	beqz	a1,80003242 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    8000324c:	0009a503          	lw	a0,0(s3)
    80003250:	9ebff0ef          	jal	ra,80002c3a <bfree>
    80003254:	b7fd                	j	80003242 <itrunc+0x68>
    brelse(bp);
    80003256:	8552                	mv	a0,s4
    80003258:	8f1ff0ef          	jal	ra,80002b48 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000325c:	0809a583          	lw	a1,128(s3)
    80003260:	0009a503          	lw	a0,0(s3)
    80003264:	9d7ff0ef          	jal	ra,80002c3a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003268:	0809a023          	sw	zero,128(s3)
    8000326c:	b765                	j	80003214 <itrunc+0x3a>

000000008000326e <iput>:
{
    8000326e:	1101                	addi	sp,sp,-32
    80003270:	ec06                	sd	ra,24(sp)
    80003272:	e822                	sd	s0,16(sp)
    80003274:	e426                	sd	s1,8(sp)
    80003276:	e04a                	sd	s2,0(sp)
    80003278:	1000                	addi	s0,sp,32
    8000327a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000327c:	0001b517          	auipc	a0,0x1b
    80003280:	c2450513          	addi	a0,a0,-988 # 8001dea0 <itable>
    80003284:	8e7fd0ef          	jal	ra,80000b6a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003288:	4498                	lw	a4,8(s1)
    8000328a:	4785                	li	a5,1
    8000328c:	02f70163          	beq	a4,a5,800032ae <iput+0x40>
  ip->ref--;
    80003290:	449c                	lw	a5,8(s1)
    80003292:	37fd                	addiw	a5,a5,-1
    80003294:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003296:	0001b517          	auipc	a0,0x1b
    8000329a:	c0a50513          	addi	a0,a0,-1014 # 8001dea0 <itable>
    8000329e:	965fd0ef          	jal	ra,80000c02 <release>
}
    800032a2:	60e2                	ld	ra,24(sp)
    800032a4:	6442                	ld	s0,16(sp)
    800032a6:	64a2                	ld	s1,8(sp)
    800032a8:	6902                	ld	s2,0(sp)
    800032aa:	6105                	addi	sp,sp,32
    800032ac:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800032ae:	40bc                	lw	a5,64(s1)
    800032b0:	d3e5                	beqz	a5,80003290 <iput+0x22>
    800032b2:	04a49783          	lh	a5,74(s1)
    800032b6:	ffe9                	bnez	a5,80003290 <iput+0x22>
    acquiresleep(&ip->lock);
    800032b8:	01048913          	addi	s2,s1,16
    800032bc:	854a                	mv	a0,s2
    800032be:	295000ef          	jal	ra,80003d52 <acquiresleep>
    release(&itable.lock);
    800032c2:	0001b517          	auipc	a0,0x1b
    800032c6:	bde50513          	addi	a0,a0,-1058 # 8001dea0 <itable>
    800032ca:	939fd0ef          	jal	ra,80000c02 <release>
    itrunc(ip);
    800032ce:	8526                	mv	a0,s1
    800032d0:	f0bff0ef          	jal	ra,800031da <itrunc>
    ip->type = 0;
    800032d4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800032d8:	8526                	mv	a0,s1
    800032da:	d63ff0ef          	jal	ra,8000303c <iupdate>
    ip->valid = 0;
    800032de:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800032e2:	854a                	mv	a0,s2
    800032e4:	2b5000ef          	jal	ra,80003d98 <releasesleep>
    acquire(&itable.lock);
    800032e8:	0001b517          	auipc	a0,0x1b
    800032ec:	bb850513          	addi	a0,a0,-1096 # 8001dea0 <itable>
    800032f0:	87bfd0ef          	jal	ra,80000b6a <acquire>
    800032f4:	bf71                	j	80003290 <iput+0x22>

00000000800032f6 <iunlockput>:
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	e426                	sd	s1,8(sp)
    800032fe:	1000                	addi	s0,sp,32
    80003300:	84aa                	mv	s1,a0
  iunlock(ip);
    80003302:	e99ff0ef          	jal	ra,8000319a <iunlock>
  iput(ip);
    80003306:	8526                	mv	a0,s1
    80003308:	f67ff0ef          	jal	ra,8000326e <iput>
}
    8000330c:	60e2                	ld	ra,24(sp)
    8000330e:	6442                	ld	s0,16(sp)
    80003310:	64a2                	ld	s1,8(sp)
    80003312:	6105                	addi	sp,sp,32
    80003314:	8082                	ret

0000000080003316 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003316:	0001b717          	auipc	a4,0x1b
    8000331a:	b7672703          	lw	a4,-1162(a4) # 8001de8c <sb+0xc>
    8000331e:	4785                	li	a5,1
    80003320:	0ae7ff63          	bgeu	a5,a4,800033de <ireclaim+0xc8>
{
    80003324:	7139                	addi	sp,sp,-64
    80003326:	fc06                	sd	ra,56(sp)
    80003328:	f822                	sd	s0,48(sp)
    8000332a:	f426                	sd	s1,40(sp)
    8000332c:	f04a                	sd	s2,32(sp)
    8000332e:	ec4e                	sd	s3,24(sp)
    80003330:	e852                	sd	s4,16(sp)
    80003332:	e456                	sd	s5,8(sp)
    80003334:	e05a                	sd	s6,0(sp)
    80003336:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003338:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000333a:	00050a1b          	sext.w	s4,a0
    8000333e:	0001ba97          	auipc	s5,0x1b
    80003342:	b42a8a93          	addi	s5,s5,-1214 # 8001de80 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003346:	00004b17          	auipc	s6,0x4
    8000334a:	232b0b13          	addi	s6,s6,562 # 80007578 <syscalls+0x188>
    8000334e:	a099                	j	80003394 <ireclaim+0x7e>
    80003350:	85ce                	mv	a1,s3
    80003352:	855a                	mv	a0,s6
    80003354:	96efd0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80003358:	85ce                	mv	a1,s3
    8000335a:	8552                	mv	a0,s4
    8000335c:	b27ff0ef          	jal	ra,80002e82 <iget>
    80003360:	89aa                	mv	s3,a0
    brelse(bp);
    80003362:	854a                	mv	a0,s2
    80003364:	fe4ff0ef          	jal	ra,80002b48 <brelse>
    if (ip) {
    80003368:	00098f63          	beqz	s3,80003386 <ireclaim+0x70>
      begin_op();
    8000336c:	76c000ef          	jal	ra,80003ad8 <begin_op>
      ilock(ip);
    80003370:	854e                	mv	a0,s3
    80003372:	d7fff0ef          	jal	ra,800030f0 <ilock>
      iunlock(ip);
    80003376:	854e                	mv	a0,s3
    80003378:	e23ff0ef          	jal	ra,8000319a <iunlock>
      iput(ip);
    8000337c:	854e                	mv	a0,s3
    8000337e:	ef1ff0ef          	jal	ra,8000326e <iput>
      end_op();
    80003382:	7c4000ef          	jal	ra,80003b46 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003386:	0485                	addi	s1,s1,1
    80003388:	00caa703          	lw	a4,12(s5)
    8000338c:	0004879b          	sext.w	a5,s1
    80003390:	02e7fd63          	bgeu	a5,a4,800033ca <ireclaim+0xb4>
    80003394:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003398:	0044d593          	srli	a1,s1,0x4
    8000339c:	018aa783          	lw	a5,24(s5)
    800033a0:	9dbd                	addw	a1,a1,a5
    800033a2:	8552                	mv	a0,s4
    800033a4:	e9cff0ef          	jal	ra,80002a40 <bread>
    800033a8:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800033aa:	05850793          	addi	a5,a0,88
    800033ae:	00f9f713          	andi	a4,s3,15
    800033b2:	071a                	slli	a4,a4,0x6
    800033b4:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800033b6:	00079703          	lh	a4,0(a5)
    800033ba:	c701                	beqz	a4,800033c2 <ireclaim+0xac>
    800033bc:	00679783          	lh	a5,6(a5)
    800033c0:	dbc1                	beqz	a5,80003350 <ireclaim+0x3a>
    brelse(bp);
    800033c2:	854a                	mv	a0,s2
    800033c4:	f84ff0ef          	jal	ra,80002b48 <brelse>
    if (ip) {
    800033c8:	bf7d                	j	80003386 <ireclaim+0x70>
}
    800033ca:	70e2                	ld	ra,56(sp)
    800033cc:	7442                	ld	s0,48(sp)
    800033ce:	74a2                	ld	s1,40(sp)
    800033d0:	7902                	ld	s2,32(sp)
    800033d2:	69e2                	ld	s3,24(sp)
    800033d4:	6a42                	ld	s4,16(sp)
    800033d6:	6aa2                	ld	s5,8(sp)
    800033d8:	6b02                	ld	s6,0(sp)
    800033da:	6121                	addi	sp,sp,64
    800033dc:	8082                	ret
    800033de:	8082                	ret

00000000800033e0 <fsinit>:
fsinit(int dev) {
    800033e0:	7179                	addi	sp,sp,-48
    800033e2:	f406                	sd	ra,40(sp)
    800033e4:	f022                	sd	s0,32(sp)
    800033e6:	ec26                	sd	s1,24(sp)
    800033e8:	e84a                	sd	s2,16(sp)
    800033ea:	e44e                	sd	s3,8(sp)
    800033ec:	1800                	addi	s0,sp,48
    800033ee:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800033f0:	4585                	li	a1,1
    800033f2:	e4eff0ef          	jal	ra,80002a40 <bread>
    800033f6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033f8:	0001b997          	auipc	s3,0x1b
    800033fc:	a8898993          	addi	s3,s3,-1400 # 8001de80 <sb>
    80003400:	02000613          	li	a2,32
    80003404:	05850593          	addi	a1,a0,88
    80003408:	854e                	mv	a0,s3
    8000340a:	891fd0ef          	jal	ra,80000c9a <memmove>
  brelse(bp);
    8000340e:	854a                	mv	a0,s2
    80003410:	f38ff0ef          	jal	ra,80002b48 <brelse>
  if(sb.magic != FSMAGIC)
    80003414:	0009a703          	lw	a4,0(s3)
    80003418:	102037b7          	lui	a5,0x10203
    8000341c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003420:	02f71363          	bne	a4,a5,80003446 <fsinit+0x66>
  initlog(dev, &sb);
    80003424:	0001b597          	auipc	a1,0x1b
    80003428:	a5c58593          	addi	a1,a1,-1444 # 8001de80 <sb>
    8000342c:	8526                	mv	a0,s1
    8000342e:	61e000ef          	jal	ra,80003a4c <initlog>
  ireclaim(dev);
    80003432:	8526                	mv	a0,s1
    80003434:	ee3ff0ef          	jal	ra,80003316 <ireclaim>
}
    80003438:	70a2                	ld	ra,40(sp)
    8000343a:	7402                	ld	s0,32(sp)
    8000343c:	64e2                	ld	s1,24(sp)
    8000343e:	6942                	ld	s2,16(sp)
    80003440:	69a2                	ld	s3,8(sp)
    80003442:	6145                	addi	sp,sp,48
    80003444:	8082                	ret
    panic("invalid file system");
    80003446:	00004517          	auipc	a0,0x4
    8000344a:	15250513          	addi	a0,a0,338 # 80007598 <syscalls+0x1a8>
    8000344e:	b3afd0ef          	jal	ra,80000788 <panic>

0000000080003452 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003452:	1141                	addi	sp,sp,-16
    80003454:	e422                	sd	s0,8(sp)
    80003456:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003458:	411c                	lw	a5,0(a0)
    8000345a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000345c:	415c                	lw	a5,4(a0)
    8000345e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003460:	04451783          	lh	a5,68(a0)
    80003464:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003468:	04a51783          	lh	a5,74(a0)
    8000346c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003470:	04c56783          	lwu	a5,76(a0)
    80003474:	e99c                	sd	a5,16(a1)
}
    80003476:	6422                	ld	s0,8(sp)
    80003478:	0141                	addi	sp,sp,16
    8000347a:	8082                	ret

000000008000347c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000347c:	457c                	lw	a5,76(a0)
    8000347e:	0cd7ef63          	bltu	a5,a3,8000355c <readi+0xe0>
{
    80003482:	7159                	addi	sp,sp,-112
    80003484:	f486                	sd	ra,104(sp)
    80003486:	f0a2                	sd	s0,96(sp)
    80003488:	eca6                	sd	s1,88(sp)
    8000348a:	e8ca                	sd	s2,80(sp)
    8000348c:	e4ce                	sd	s3,72(sp)
    8000348e:	e0d2                	sd	s4,64(sp)
    80003490:	fc56                	sd	s5,56(sp)
    80003492:	f85a                	sd	s6,48(sp)
    80003494:	f45e                	sd	s7,40(sp)
    80003496:	f062                	sd	s8,32(sp)
    80003498:	ec66                	sd	s9,24(sp)
    8000349a:	e86a                	sd	s10,16(sp)
    8000349c:	e46e                	sd	s11,8(sp)
    8000349e:	1880                	addi	s0,sp,112
    800034a0:	8b2a                	mv	s6,a0
    800034a2:	8bae                	mv	s7,a1
    800034a4:	8a32                	mv	s4,a2
    800034a6:	84b6                	mv	s1,a3
    800034a8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800034aa:	9f35                	addw	a4,a4,a3
    return 0;
    800034ac:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800034ae:	08d76663          	bltu	a4,a3,8000353a <readi+0xbe>
  if(off + n > ip->size)
    800034b2:	00e7f463          	bgeu	a5,a4,800034ba <readi+0x3e>
    n = ip->size - off;
    800034b6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034ba:	080a8f63          	beqz	s5,80003558 <readi+0xdc>
    800034be:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034c0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034c4:	5c7d                	li	s8,-1
    800034c6:	a80d                	j	800034f8 <readi+0x7c>
    800034c8:	020d1d93          	slli	s11,s10,0x20
    800034cc:	020ddd93          	srli	s11,s11,0x20
    800034d0:	05890613          	addi	a2,s2,88
    800034d4:	86ee                	mv	a3,s11
    800034d6:	963a                	add	a2,a2,a4
    800034d8:	85d2                	mv	a1,s4
    800034da:	855e                	mv	a0,s7
    800034dc:	c8bfe0ef          	jal	ra,80002166 <either_copyout>
    800034e0:	05850763          	beq	a0,s8,8000352e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800034e4:	854a                	mv	a0,s2
    800034e6:	e62ff0ef          	jal	ra,80002b48 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034ea:	013d09bb          	addw	s3,s10,s3
    800034ee:	009d04bb          	addw	s1,s10,s1
    800034f2:	9a6e                	add	s4,s4,s11
    800034f4:	0559f163          	bgeu	s3,s5,80003536 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800034f8:	00a4d59b          	srliw	a1,s1,0xa
    800034fc:	855a                	mv	a0,s6
    800034fe:	8b7ff0ef          	jal	ra,80002db4 <bmap>
    80003502:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003506:	c985                	beqz	a1,80003536 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003508:	000b2503          	lw	a0,0(s6)
    8000350c:	d34ff0ef          	jal	ra,80002a40 <bread>
    80003510:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003512:	3ff4f713          	andi	a4,s1,1023
    80003516:	40ec87bb          	subw	a5,s9,a4
    8000351a:	413a86bb          	subw	a3,s5,s3
    8000351e:	8d3e                	mv	s10,a5
    80003520:	2781                	sext.w	a5,a5
    80003522:	0006861b          	sext.w	a2,a3
    80003526:	faf671e3          	bgeu	a2,a5,800034c8 <readi+0x4c>
    8000352a:	8d36                	mv	s10,a3
    8000352c:	bf71                	j	800034c8 <readi+0x4c>
      brelse(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	e18ff0ef          	jal	ra,80002b48 <brelse>
      tot = -1;
    80003534:	59fd                	li	s3,-1
  }
  return tot;
    80003536:	0009851b          	sext.w	a0,s3
}
    8000353a:	70a6                	ld	ra,104(sp)
    8000353c:	7406                	ld	s0,96(sp)
    8000353e:	64e6                	ld	s1,88(sp)
    80003540:	6946                	ld	s2,80(sp)
    80003542:	69a6                	ld	s3,72(sp)
    80003544:	6a06                	ld	s4,64(sp)
    80003546:	7ae2                	ld	s5,56(sp)
    80003548:	7b42                	ld	s6,48(sp)
    8000354a:	7ba2                	ld	s7,40(sp)
    8000354c:	7c02                	ld	s8,32(sp)
    8000354e:	6ce2                	ld	s9,24(sp)
    80003550:	6d42                	ld	s10,16(sp)
    80003552:	6da2                	ld	s11,8(sp)
    80003554:	6165                	addi	sp,sp,112
    80003556:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003558:	89d6                	mv	s3,s5
    8000355a:	bff1                	j	80003536 <readi+0xba>
    return 0;
    8000355c:	4501                	li	a0,0
}
    8000355e:	8082                	ret

0000000080003560 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003560:	457c                	lw	a5,76(a0)
    80003562:	0ed7ea63          	bltu	a5,a3,80003656 <writei+0xf6>
{
    80003566:	7159                	addi	sp,sp,-112
    80003568:	f486                	sd	ra,104(sp)
    8000356a:	f0a2                	sd	s0,96(sp)
    8000356c:	eca6                	sd	s1,88(sp)
    8000356e:	e8ca                	sd	s2,80(sp)
    80003570:	e4ce                	sd	s3,72(sp)
    80003572:	e0d2                	sd	s4,64(sp)
    80003574:	fc56                	sd	s5,56(sp)
    80003576:	f85a                	sd	s6,48(sp)
    80003578:	f45e                	sd	s7,40(sp)
    8000357a:	f062                	sd	s8,32(sp)
    8000357c:	ec66                	sd	s9,24(sp)
    8000357e:	e86a                	sd	s10,16(sp)
    80003580:	e46e                	sd	s11,8(sp)
    80003582:	1880                	addi	s0,sp,112
    80003584:	8aaa                	mv	s5,a0
    80003586:	8bae                	mv	s7,a1
    80003588:	8a32                	mv	s4,a2
    8000358a:	8936                	mv	s2,a3
    8000358c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000358e:	00e687bb          	addw	a5,a3,a4
    80003592:	0cd7e463          	bltu	a5,a3,8000365a <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003596:	00043737          	lui	a4,0x43
    8000359a:	0cf76263          	bltu	a4,a5,8000365e <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000359e:	0a0b0a63          	beqz	s6,80003652 <writei+0xf2>
    800035a2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035a4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800035a8:	5c7d                	li	s8,-1
    800035aa:	a825                	j	800035e2 <writei+0x82>
    800035ac:	020d1d93          	slli	s11,s10,0x20
    800035b0:	020ddd93          	srli	s11,s11,0x20
    800035b4:	05848513          	addi	a0,s1,88
    800035b8:	86ee                	mv	a3,s11
    800035ba:	8652                	mv	a2,s4
    800035bc:	85de                	mv	a1,s7
    800035be:	953a                	add	a0,a0,a4
    800035c0:	bf1fe0ef          	jal	ra,800021b0 <either_copyin>
    800035c4:	05850a63          	beq	a0,s8,80003618 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800035c8:	8526                	mv	a0,s1
    800035ca:	690000ef          	jal	ra,80003c5a <log_write>
    brelse(bp);
    800035ce:	8526                	mv	a0,s1
    800035d0:	d78ff0ef          	jal	ra,80002b48 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035d4:	013d09bb          	addw	s3,s10,s3
    800035d8:	012d093b          	addw	s2,s10,s2
    800035dc:	9a6e                	add	s4,s4,s11
    800035de:	0569f063          	bgeu	s3,s6,8000361e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035e2:	00a9559b          	srliw	a1,s2,0xa
    800035e6:	8556                	mv	a0,s5
    800035e8:	fccff0ef          	jal	ra,80002db4 <bmap>
    800035ec:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035f0:	c59d                	beqz	a1,8000361e <writei+0xbe>
    bp = bread(ip->dev, addr);
    800035f2:	000aa503          	lw	a0,0(s5)
    800035f6:	c4aff0ef          	jal	ra,80002a40 <bread>
    800035fa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035fc:	3ff97713          	andi	a4,s2,1023
    80003600:	40ec87bb          	subw	a5,s9,a4
    80003604:	413b06bb          	subw	a3,s6,s3
    80003608:	8d3e                	mv	s10,a5
    8000360a:	2781                	sext.w	a5,a5
    8000360c:	0006861b          	sext.w	a2,a3
    80003610:	f8f67ee3          	bgeu	a2,a5,800035ac <writei+0x4c>
    80003614:	8d36                	mv	s10,a3
    80003616:	bf59                	j	800035ac <writei+0x4c>
      brelse(bp);
    80003618:	8526                	mv	a0,s1
    8000361a:	d2eff0ef          	jal	ra,80002b48 <brelse>
  }

  if(off > ip->size)
    8000361e:	04caa783          	lw	a5,76(s5)
    80003622:	0127f463          	bgeu	a5,s2,8000362a <writei+0xca>
    ip->size = off;
    80003626:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000362a:	8556                	mv	a0,s5
    8000362c:	a11ff0ef          	jal	ra,8000303c <iupdate>

  return tot;
    80003630:	0009851b          	sext.w	a0,s3
}
    80003634:	70a6                	ld	ra,104(sp)
    80003636:	7406                	ld	s0,96(sp)
    80003638:	64e6                	ld	s1,88(sp)
    8000363a:	6946                	ld	s2,80(sp)
    8000363c:	69a6                	ld	s3,72(sp)
    8000363e:	6a06                	ld	s4,64(sp)
    80003640:	7ae2                	ld	s5,56(sp)
    80003642:	7b42                	ld	s6,48(sp)
    80003644:	7ba2                	ld	s7,40(sp)
    80003646:	7c02                	ld	s8,32(sp)
    80003648:	6ce2                	ld	s9,24(sp)
    8000364a:	6d42                	ld	s10,16(sp)
    8000364c:	6da2                	ld	s11,8(sp)
    8000364e:	6165                	addi	sp,sp,112
    80003650:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003652:	89da                	mv	s3,s6
    80003654:	bfd9                	j	8000362a <writei+0xca>
    return -1;
    80003656:	557d                	li	a0,-1
}
    80003658:	8082                	ret
    return -1;
    8000365a:	557d                	li	a0,-1
    8000365c:	bfe1                	j	80003634 <writei+0xd4>
    return -1;
    8000365e:	557d                	li	a0,-1
    80003660:	bfd1                	j	80003634 <writei+0xd4>

0000000080003662 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003662:	1141                	addi	sp,sp,-16
    80003664:	e406                	sd	ra,8(sp)
    80003666:	e022                	sd	s0,0(sp)
    80003668:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000366a:	4639                	li	a2,14
    8000366c:	e9efd0ef          	jal	ra,80000d0a <strncmp>
}
    80003670:	60a2                	ld	ra,8(sp)
    80003672:	6402                	ld	s0,0(sp)
    80003674:	0141                	addi	sp,sp,16
    80003676:	8082                	ret

0000000080003678 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003678:	7139                	addi	sp,sp,-64
    8000367a:	fc06                	sd	ra,56(sp)
    8000367c:	f822                	sd	s0,48(sp)
    8000367e:	f426                	sd	s1,40(sp)
    80003680:	f04a                	sd	s2,32(sp)
    80003682:	ec4e                	sd	s3,24(sp)
    80003684:	e852                	sd	s4,16(sp)
    80003686:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003688:	04451703          	lh	a4,68(a0)
    8000368c:	4785                	li	a5,1
    8000368e:	00f71a63          	bne	a4,a5,800036a2 <dirlookup+0x2a>
    80003692:	892a                	mv	s2,a0
    80003694:	89ae                	mv	s3,a1
    80003696:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003698:	457c                	lw	a5,76(a0)
    8000369a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000369c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000369e:	e39d                	bnez	a5,800036c4 <dirlookup+0x4c>
    800036a0:	a095                	j	80003704 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800036a2:	00004517          	auipc	a0,0x4
    800036a6:	f0e50513          	addi	a0,a0,-242 # 800075b0 <syscalls+0x1c0>
    800036aa:	8defd0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    800036ae:	00004517          	auipc	a0,0x4
    800036b2:	f1a50513          	addi	a0,a0,-230 # 800075c8 <syscalls+0x1d8>
    800036b6:	8d2fd0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036ba:	24c1                	addiw	s1,s1,16
    800036bc:	04c92783          	lw	a5,76(s2)
    800036c0:	04f4f163          	bgeu	s1,a5,80003702 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036c4:	4741                	li	a4,16
    800036c6:	86a6                	mv	a3,s1
    800036c8:	fc040613          	addi	a2,s0,-64
    800036cc:	4581                	li	a1,0
    800036ce:	854a                	mv	a0,s2
    800036d0:	dadff0ef          	jal	ra,8000347c <readi>
    800036d4:	47c1                	li	a5,16
    800036d6:	fcf51ce3          	bne	a0,a5,800036ae <dirlookup+0x36>
    if(de.inum == 0)
    800036da:	fc045783          	lhu	a5,-64(s0)
    800036de:	dff1                	beqz	a5,800036ba <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800036e0:	fc240593          	addi	a1,s0,-62
    800036e4:	854e                	mv	a0,s3
    800036e6:	f7dff0ef          	jal	ra,80003662 <namecmp>
    800036ea:	f961                	bnez	a0,800036ba <dirlookup+0x42>
      if(poff)
    800036ec:	000a0463          	beqz	s4,800036f4 <dirlookup+0x7c>
        *poff = off;
    800036f0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800036f4:	fc045583          	lhu	a1,-64(s0)
    800036f8:	00092503          	lw	a0,0(s2)
    800036fc:	f86ff0ef          	jal	ra,80002e82 <iget>
    80003700:	a011                	j	80003704 <dirlookup+0x8c>
  return 0;
    80003702:	4501                	li	a0,0
}
    80003704:	70e2                	ld	ra,56(sp)
    80003706:	7442                	ld	s0,48(sp)
    80003708:	74a2                	ld	s1,40(sp)
    8000370a:	7902                	ld	s2,32(sp)
    8000370c:	69e2                	ld	s3,24(sp)
    8000370e:	6a42                	ld	s4,16(sp)
    80003710:	6121                	addi	sp,sp,64
    80003712:	8082                	ret

0000000080003714 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003714:	711d                	addi	sp,sp,-96
    80003716:	ec86                	sd	ra,88(sp)
    80003718:	e8a2                	sd	s0,80(sp)
    8000371a:	e4a6                	sd	s1,72(sp)
    8000371c:	e0ca                	sd	s2,64(sp)
    8000371e:	fc4e                	sd	s3,56(sp)
    80003720:	f852                	sd	s4,48(sp)
    80003722:	f456                	sd	s5,40(sp)
    80003724:	f05a                	sd	s6,32(sp)
    80003726:	ec5e                	sd	s7,24(sp)
    80003728:	e862                	sd	s8,16(sp)
    8000372a:	e466                	sd	s9,8(sp)
    8000372c:	e06a                	sd	s10,0(sp)
    8000372e:	1080                	addi	s0,sp,96
    80003730:	84aa                	mv	s1,a0
    80003732:	8b2e                	mv	s6,a1
    80003734:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003736:	00054703          	lbu	a4,0(a0)
    8000373a:	02f00793          	li	a5,47
    8000373e:	00f70f63          	beq	a4,a5,8000375c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003742:	8c0fe0ef          	jal	ra,80001802 <myproc>
    80003746:	15053503          	ld	a0,336(a0)
    8000374a:	971ff0ef          	jal	ra,800030ba <idup>
    8000374e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003750:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003754:	4cb5                	li	s9,13
  len = path - s;
    80003756:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003758:	4c05                	li	s8,1
    8000375a:	a879                	j	800037f8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000375c:	4585                	li	a1,1
    8000375e:	4505                	li	a0,1
    80003760:	f22ff0ef          	jal	ra,80002e82 <iget>
    80003764:	8a2a                	mv	s4,a0
    80003766:	b7ed                	j	80003750 <namex+0x3c>
      iunlockput(ip);
    80003768:	8552                	mv	a0,s4
    8000376a:	b8dff0ef          	jal	ra,800032f6 <iunlockput>
      return 0;
    8000376e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003770:	8552                	mv	a0,s4
    80003772:	60e6                	ld	ra,88(sp)
    80003774:	6446                	ld	s0,80(sp)
    80003776:	64a6                	ld	s1,72(sp)
    80003778:	6906                	ld	s2,64(sp)
    8000377a:	79e2                	ld	s3,56(sp)
    8000377c:	7a42                	ld	s4,48(sp)
    8000377e:	7aa2                	ld	s5,40(sp)
    80003780:	7b02                	ld	s6,32(sp)
    80003782:	6be2                	ld	s7,24(sp)
    80003784:	6c42                	ld	s8,16(sp)
    80003786:	6ca2                	ld	s9,8(sp)
    80003788:	6d02                	ld	s10,0(sp)
    8000378a:	6125                	addi	sp,sp,96
    8000378c:	8082                	ret
      iunlock(ip);
    8000378e:	8552                	mv	a0,s4
    80003790:	a0bff0ef          	jal	ra,8000319a <iunlock>
      return ip;
    80003794:	bff1                	j	80003770 <namex+0x5c>
      iunlockput(ip);
    80003796:	8552                	mv	a0,s4
    80003798:	b5fff0ef          	jal	ra,800032f6 <iunlockput>
      return 0;
    8000379c:	8a4e                	mv	s4,s3
    8000379e:	bfc9                	j	80003770 <namex+0x5c>
  len = path - s;
    800037a0:	40998633          	sub	a2,s3,s1
    800037a4:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800037a8:	09acd063          	bge	s9,s10,80003828 <namex+0x114>
    memmove(name, s, DIRSIZ);
    800037ac:	4639                	li	a2,14
    800037ae:	85a6                	mv	a1,s1
    800037b0:	8556                	mv	a0,s5
    800037b2:	ce8fd0ef          	jal	ra,80000c9a <memmove>
    800037b6:	84ce                	mv	s1,s3
  while(*path == '/')
    800037b8:	0004c783          	lbu	a5,0(s1)
    800037bc:	01279763          	bne	a5,s2,800037ca <namex+0xb6>
    path++;
    800037c0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037c2:	0004c783          	lbu	a5,0(s1)
    800037c6:	ff278de3          	beq	a5,s2,800037c0 <namex+0xac>
    ilock(ip);
    800037ca:	8552                	mv	a0,s4
    800037cc:	925ff0ef          	jal	ra,800030f0 <ilock>
    if(ip->type != T_DIR){
    800037d0:	044a1783          	lh	a5,68(s4)
    800037d4:	f9879ae3          	bne	a5,s8,80003768 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800037d8:	000b0563          	beqz	s6,800037e2 <namex+0xce>
    800037dc:	0004c783          	lbu	a5,0(s1)
    800037e0:	d7dd                	beqz	a5,8000378e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800037e2:	865e                	mv	a2,s7
    800037e4:	85d6                	mv	a1,s5
    800037e6:	8552                	mv	a0,s4
    800037e8:	e91ff0ef          	jal	ra,80003678 <dirlookup>
    800037ec:	89aa                	mv	s3,a0
    800037ee:	d545                	beqz	a0,80003796 <namex+0x82>
    iunlockput(ip);
    800037f0:	8552                	mv	a0,s4
    800037f2:	b05ff0ef          	jal	ra,800032f6 <iunlockput>
    ip = next;
    800037f6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800037f8:	0004c783          	lbu	a5,0(s1)
    800037fc:	01279763          	bne	a5,s2,8000380a <namex+0xf6>
    path++;
    80003800:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003802:	0004c783          	lbu	a5,0(s1)
    80003806:	ff278de3          	beq	a5,s2,80003800 <namex+0xec>
  if(*path == 0)
    8000380a:	cb8d                	beqz	a5,8000383c <namex+0x128>
  while(*path != '/' && *path != 0)
    8000380c:	0004c783          	lbu	a5,0(s1)
    80003810:	89a6                	mv	s3,s1
  len = path - s;
    80003812:	8d5e                	mv	s10,s7
    80003814:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003816:	01278963          	beq	a5,s2,80003828 <namex+0x114>
    8000381a:	d3d9                	beqz	a5,800037a0 <namex+0x8c>
    path++;
    8000381c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000381e:	0009c783          	lbu	a5,0(s3)
    80003822:	ff279ce3          	bne	a5,s2,8000381a <namex+0x106>
    80003826:	bfad                	j	800037a0 <namex+0x8c>
    memmove(name, s, len);
    80003828:	2601                	sext.w	a2,a2
    8000382a:	85a6                	mv	a1,s1
    8000382c:	8556                	mv	a0,s5
    8000382e:	c6cfd0ef          	jal	ra,80000c9a <memmove>
    name[len] = 0;
    80003832:	9d56                	add	s10,s10,s5
    80003834:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    80003838:	84ce                	mv	s1,s3
    8000383a:	bfbd                	j	800037b8 <namex+0xa4>
  if(nameiparent){
    8000383c:	f20b0ae3          	beqz	s6,80003770 <namex+0x5c>
    iput(ip);
    80003840:	8552                	mv	a0,s4
    80003842:	a2dff0ef          	jal	ra,8000326e <iput>
    return 0;
    80003846:	4a01                	li	s4,0
    80003848:	b725                	j	80003770 <namex+0x5c>

000000008000384a <dirlink>:
{
    8000384a:	7139                	addi	sp,sp,-64
    8000384c:	fc06                	sd	ra,56(sp)
    8000384e:	f822                	sd	s0,48(sp)
    80003850:	f426                	sd	s1,40(sp)
    80003852:	f04a                	sd	s2,32(sp)
    80003854:	ec4e                	sd	s3,24(sp)
    80003856:	e852                	sd	s4,16(sp)
    80003858:	0080                	addi	s0,sp,64
    8000385a:	892a                	mv	s2,a0
    8000385c:	8a2e                	mv	s4,a1
    8000385e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003860:	4601                	li	a2,0
    80003862:	e17ff0ef          	jal	ra,80003678 <dirlookup>
    80003866:	e52d                	bnez	a0,800038d0 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003868:	04c92483          	lw	s1,76(s2)
    8000386c:	c48d                	beqz	s1,80003896 <dirlink+0x4c>
    8000386e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003870:	4741                	li	a4,16
    80003872:	86a6                	mv	a3,s1
    80003874:	fc040613          	addi	a2,s0,-64
    80003878:	4581                	li	a1,0
    8000387a:	854a                	mv	a0,s2
    8000387c:	c01ff0ef          	jal	ra,8000347c <readi>
    80003880:	47c1                	li	a5,16
    80003882:	04f51b63          	bne	a0,a5,800038d8 <dirlink+0x8e>
    if(de.inum == 0)
    80003886:	fc045783          	lhu	a5,-64(s0)
    8000388a:	c791                	beqz	a5,80003896 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000388c:	24c1                	addiw	s1,s1,16
    8000388e:	04c92783          	lw	a5,76(s2)
    80003892:	fcf4efe3          	bltu	s1,a5,80003870 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003896:	4639                	li	a2,14
    80003898:	85d2                	mv	a1,s4
    8000389a:	fc240513          	addi	a0,s0,-62
    8000389e:	ca8fd0ef          	jal	ra,80000d46 <strncpy>
  de.inum = inum;
    800038a2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038a6:	4741                	li	a4,16
    800038a8:	86a6                	mv	a3,s1
    800038aa:	fc040613          	addi	a2,s0,-64
    800038ae:	4581                	li	a1,0
    800038b0:	854a                	mv	a0,s2
    800038b2:	cafff0ef          	jal	ra,80003560 <writei>
    800038b6:	1541                	addi	a0,a0,-16
    800038b8:	00a03533          	snez	a0,a0
    800038bc:	40a00533          	neg	a0,a0
}
    800038c0:	70e2                	ld	ra,56(sp)
    800038c2:	7442                	ld	s0,48(sp)
    800038c4:	74a2                	ld	s1,40(sp)
    800038c6:	7902                	ld	s2,32(sp)
    800038c8:	69e2                	ld	s3,24(sp)
    800038ca:	6a42                	ld	s4,16(sp)
    800038cc:	6121                	addi	sp,sp,64
    800038ce:	8082                	ret
    iput(ip);
    800038d0:	99fff0ef          	jal	ra,8000326e <iput>
    return -1;
    800038d4:	557d                	li	a0,-1
    800038d6:	b7ed                	j	800038c0 <dirlink+0x76>
      panic("dirlink read");
    800038d8:	00004517          	auipc	a0,0x4
    800038dc:	d0050513          	addi	a0,a0,-768 # 800075d8 <syscalls+0x1e8>
    800038e0:	ea9fc0ef          	jal	ra,80000788 <panic>

00000000800038e4 <namei>:

struct inode*
namei(char *path)
{
    800038e4:	1101                	addi	sp,sp,-32
    800038e6:	ec06                	sd	ra,24(sp)
    800038e8:	e822                	sd	s0,16(sp)
    800038ea:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800038ec:	fe040613          	addi	a2,s0,-32
    800038f0:	4581                	li	a1,0
    800038f2:	e23ff0ef          	jal	ra,80003714 <namex>
}
    800038f6:	60e2                	ld	ra,24(sp)
    800038f8:	6442                	ld	s0,16(sp)
    800038fa:	6105                	addi	sp,sp,32
    800038fc:	8082                	ret

00000000800038fe <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800038fe:	1141                	addi	sp,sp,-16
    80003900:	e406                	sd	ra,8(sp)
    80003902:	e022                	sd	s0,0(sp)
    80003904:	0800                	addi	s0,sp,16
    80003906:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003908:	4585                	li	a1,1
    8000390a:	e0bff0ef          	jal	ra,80003714 <namex>
}
    8000390e:	60a2                	ld	ra,8(sp)
    80003910:	6402                	ld	s0,0(sp)
    80003912:	0141                	addi	sp,sp,16
    80003914:	8082                	ret

0000000080003916 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003916:	1101                	addi	sp,sp,-32
    80003918:	ec06                	sd	ra,24(sp)
    8000391a:	e822                	sd	s0,16(sp)
    8000391c:	e426                	sd	s1,8(sp)
    8000391e:	e04a                	sd	s2,0(sp)
    80003920:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003922:	0001c917          	auipc	s2,0x1c
    80003926:	02690913          	addi	s2,s2,38 # 8001f948 <log>
    8000392a:	01892583          	lw	a1,24(s2)
    8000392e:	02492503          	lw	a0,36(s2)
    80003932:	90eff0ef          	jal	ra,80002a40 <bread>
    80003936:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003938:	02892683          	lw	a3,40(s2)
    8000393c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000393e:	02d05863          	blez	a3,8000396e <write_head+0x58>
    80003942:	0001c797          	auipc	a5,0x1c
    80003946:	03278793          	addi	a5,a5,50 # 8001f974 <log+0x2c>
    8000394a:	05c50713          	addi	a4,a0,92
    8000394e:	36fd                	addiw	a3,a3,-1
    80003950:	02069613          	slli	a2,a3,0x20
    80003954:	01e65693          	srli	a3,a2,0x1e
    80003958:	0001c617          	auipc	a2,0x1c
    8000395c:	02060613          	addi	a2,a2,32 # 8001f978 <log+0x30>
    80003960:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003962:	4390                	lw	a2,0(a5)
    80003964:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003966:	0791                	addi	a5,a5,4
    80003968:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000396a:	fed79ce3          	bne	a5,a3,80003962 <write_head+0x4c>
  }
  bwrite(buf);
    8000396e:	8526                	mv	a0,s1
    80003970:	9a6ff0ef          	jal	ra,80002b16 <bwrite>
  brelse(buf);
    80003974:	8526                	mv	a0,s1
    80003976:	9d2ff0ef          	jal	ra,80002b48 <brelse>
}
    8000397a:	60e2                	ld	ra,24(sp)
    8000397c:	6442                	ld	s0,16(sp)
    8000397e:	64a2                	ld	s1,8(sp)
    80003980:	6902                	ld	s2,0(sp)
    80003982:	6105                	addi	sp,sp,32
    80003984:	8082                	ret

0000000080003986 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003986:	0001c797          	auipc	a5,0x1c
    8000398a:	fea7a783          	lw	a5,-22(a5) # 8001f970 <log+0x28>
    8000398e:	0af05e63          	blez	a5,80003a4a <install_trans+0xc4>
{
    80003992:	715d                	addi	sp,sp,-80
    80003994:	e486                	sd	ra,72(sp)
    80003996:	e0a2                	sd	s0,64(sp)
    80003998:	fc26                	sd	s1,56(sp)
    8000399a:	f84a                	sd	s2,48(sp)
    8000399c:	f44e                	sd	s3,40(sp)
    8000399e:	f052                	sd	s4,32(sp)
    800039a0:	ec56                	sd	s5,24(sp)
    800039a2:	e85a                	sd	s6,16(sp)
    800039a4:	e45e                	sd	s7,8(sp)
    800039a6:	0880                	addi	s0,sp,80
    800039a8:	8b2a                	mv	s6,a0
    800039aa:	0001ca97          	auipc	s5,0x1c
    800039ae:	fcaa8a93          	addi	s5,s5,-54 # 8001f974 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039b2:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800039b4:	00004b97          	auipc	s7,0x4
    800039b8:	c34b8b93          	addi	s7,s7,-972 # 800075e8 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039bc:	0001ca17          	auipc	s4,0x1c
    800039c0:	f8ca0a13          	addi	s4,s4,-116 # 8001f948 <log>
    800039c4:	a025                	j	800039ec <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800039c6:	000aa603          	lw	a2,0(s5)
    800039ca:	85ce                	mv	a1,s3
    800039cc:	855e                	mv	a0,s7
    800039ce:	af5fc0ef          	jal	ra,800004c2 <printf>
    800039d2:	a839                	j	800039f0 <install_trans+0x6a>
    brelse(lbuf);
    800039d4:	854a                	mv	a0,s2
    800039d6:	972ff0ef          	jal	ra,80002b48 <brelse>
    brelse(dbuf);
    800039da:	8526                	mv	a0,s1
    800039dc:	96cff0ef          	jal	ra,80002b48 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039e0:	2985                	addiw	s3,s3,1
    800039e2:	0a91                	addi	s5,s5,4
    800039e4:	028a2783          	lw	a5,40(s4)
    800039e8:	04f9d663          	bge	s3,a5,80003a34 <install_trans+0xae>
    if(recovering) {
    800039ec:	fc0b1de3          	bnez	s6,800039c6 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039f0:	018a2583          	lw	a1,24(s4)
    800039f4:	013585bb          	addw	a1,a1,s3
    800039f8:	2585                	addiw	a1,a1,1
    800039fa:	024a2503          	lw	a0,36(s4)
    800039fe:	842ff0ef          	jal	ra,80002a40 <bread>
    80003a02:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a04:	000aa583          	lw	a1,0(s5)
    80003a08:	024a2503          	lw	a0,36(s4)
    80003a0c:	834ff0ef          	jal	ra,80002a40 <bread>
    80003a10:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a12:	40000613          	li	a2,1024
    80003a16:	05890593          	addi	a1,s2,88
    80003a1a:	05850513          	addi	a0,a0,88
    80003a1e:	a7cfd0ef          	jal	ra,80000c9a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a22:	8526                	mv	a0,s1
    80003a24:	8f2ff0ef          	jal	ra,80002b16 <bwrite>
    if(recovering == 0)
    80003a28:	fa0b16e3          	bnez	s6,800039d4 <install_trans+0x4e>
      bunpin(dbuf);
    80003a2c:	8526                	mv	a0,s1
    80003a2e:	9d8ff0ef          	jal	ra,80002c06 <bunpin>
    80003a32:	b74d                	j	800039d4 <install_trans+0x4e>
}
    80003a34:	60a6                	ld	ra,72(sp)
    80003a36:	6406                	ld	s0,64(sp)
    80003a38:	74e2                	ld	s1,56(sp)
    80003a3a:	7942                	ld	s2,48(sp)
    80003a3c:	79a2                	ld	s3,40(sp)
    80003a3e:	7a02                	ld	s4,32(sp)
    80003a40:	6ae2                	ld	s5,24(sp)
    80003a42:	6b42                	ld	s6,16(sp)
    80003a44:	6ba2                	ld	s7,8(sp)
    80003a46:	6161                	addi	sp,sp,80
    80003a48:	8082                	ret
    80003a4a:	8082                	ret

0000000080003a4c <initlog>:
{
    80003a4c:	7179                	addi	sp,sp,-48
    80003a4e:	f406                	sd	ra,40(sp)
    80003a50:	f022                	sd	s0,32(sp)
    80003a52:	ec26                	sd	s1,24(sp)
    80003a54:	e84a                	sd	s2,16(sp)
    80003a56:	e44e                	sd	s3,8(sp)
    80003a58:	1800                	addi	s0,sp,48
    80003a5a:	892a                	mv	s2,a0
    80003a5c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a5e:	0001c497          	auipc	s1,0x1c
    80003a62:	eea48493          	addi	s1,s1,-278 # 8001f948 <log>
    80003a66:	00004597          	auipc	a1,0x4
    80003a6a:	ba258593          	addi	a1,a1,-1118 # 80007608 <syscalls+0x218>
    80003a6e:	8526                	mv	a0,s1
    80003a70:	87afd0ef          	jal	ra,80000aea <initlock>
  log.start = sb->logstart;
    80003a74:	0149a583          	lw	a1,20(s3)
    80003a78:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003a7a:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a7e:	854a                	mv	a0,s2
    80003a80:	fc1fe0ef          	jal	ra,80002a40 <bread>
  log.lh.n = lh->n;
    80003a84:	4d34                	lw	a3,88(a0)
    80003a86:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a88:	02d05663          	blez	a3,80003ab4 <initlog+0x68>
    80003a8c:	05c50793          	addi	a5,a0,92
    80003a90:	0001c717          	auipc	a4,0x1c
    80003a94:	ee470713          	addi	a4,a4,-284 # 8001f974 <log+0x2c>
    80003a98:	36fd                	addiw	a3,a3,-1
    80003a9a:	02069613          	slli	a2,a3,0x20
    80003a9e:	01e65693          	srli	a3,a2,0x1e
    80003aa2:	06050613          	addi	a2,a0,96
    80003aa6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003aa8:	4390                	lw	a2,0(a5)
    80003aaa:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003aac:	0791                	addi	a5,a5,4
    80003aae:	0711                	addi	a4,a4,4
    80003ab0:	fed79ce3          	bne	a5,a3,80003aa8 <initlog+0x5c>
  brelse(buf);
    80003ab4:	894ff0ef          	jal	ra,80002b48 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ab8:	4505                	li	a0,1
    80003aba:	ecdff0ef          	jal	ra,80003986 <install_trans>
  log.lh.n = 0;
    80003abe:	0001c797          	auipc	a5,0x1c
    80003ac2:	ea07a923          	sw	zero,-334(a5) # 8001f970 <log+0x28>
  write_head(); // clear the log
    80003ac6:	e51ff0ef          	jal	ra,80003916 <write_head>
}
    80003aca:	70a2                	ld	ra,40(sp)
    80003acc:	7402                	ld	s0,32(sp)
    80003ace:	64e2                	ld	s1,24(sp)
    80003ad0:	6942                	ld	s2,16(sp)
    80003ad2:	69a2                	ld	s3,8(sp)
    80003ad4:	6145                	addi	sp,sp,48
    80003ad6:	8082                	ret

0000000080003ad8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	e04a                	sd	s2,0(sp)
    80003ae2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ae4:	0001c517          	auipc	a0,0x1c
    80003ae8:	e6450513          	addi	a0,a0,-412 # 8001f948 <log>
    80003aec:	87efd0ef          	jal	ra,80000b6a <acquire>
  while(1){
    if(log.committing){
    80003af0:	0001c497          	auipc	s1,0x1c
    80003af4:	e5848493          	addi	s1,s1,-424 # 8001f948 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003af8:	4979                	li	s2,30
    80003afa:	a029                	j	80003b04 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003afc:	85a6                	mv	a1,s1
    80003afe:	8526                	mv	a0,s1
    80003b00:	b0afe0ef          	jal	ra,80001e0a <sleep>
    if(log.committing){
    80003b04:	509c                	lw	a5,32(s1)
    80003b06:	fbfd                	bnez	a5,80003afc <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003b08:	4cd8                	lw	a4,28(s1)
    80003b0a:	2705                	addiw	a4,a4,1
    80003b0c:	0007069b          	sext.w	a3,a4
    80003b10:	0027179b          	slliw	a5,a4,0x2
    80003b14:	9fb9                	addw	a5,a5,a4
    80003b16:	0017979b          	slliw	a5,a5,0x1
    80003b1a:	5498                	lw	a4,40(s1)
    80003b1c:	9fb9                	addw	a5,a5,a4
    80003b1e:	00f95763          	bge	s2,a5,80003b2c <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b22:	85a6                	mv	a1,s1
    80003b24:	8526                	mv	a0,s1
    80003b26:	ae4fe0ef          	jal	ra,80001e0a <sleep>
    80003b2a:	bfe9                	j	80003b04 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b2c:	0001c517          	auipc	a0,0x1c
    80003b30:	e1c50513          	addi	a0,a0,-484 # 8001f948 <log>
    80003b34:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003b36:	8ccfd0ef          	jal	ra,80000c02 <release>
      break;
    }
  }
}
    80003b3a:	60e2                	ld	ra,24(sp)
    80003b3c:	6442                	ld	s0,16(sp)
    80003b3e:	64a2                	ld	s1,8(sp)
    80003b40:	6902                	ld	s2,0(sp)
    80003b42:	6105                	addi	sp,sp,32
    80003b44:	8082                	ret

0000000080003b46 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b46:	7139                	addi	sp,sp,-64
    80003b48:	fc06                	sd	ra,56(sp)
    80003b4a:	f822                	sd	s0,48(sp)
    80003b4c:	f426                	sd	s1,40(sp)
    80003b4e:	f04a                	sd	s2,32(sp)
    80003b50:	ec4e                	sd	s3,24(sp)
    80003b52:	e852                	sd	s4,16(sp)
    80003b54:	e456                	sd	s5,8(sp)
    80003b56:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b58:	0001c497          	auipc	s1,0x1c
    80003b5c:	df048493          	addi	s1,s1,-528 # 8001f948 <log>
    80003b60:	8526                	mv	a0,s1
    80003b62:	808fd0ef          	jal	ra,80000b6a <acquire>
  log.outstanding -= 1;
    80003b66:	4cdc                	lw	a5,28(s1)
    80003b68:	37fd                	addiw	a5,a5,-1
    80003b6a:	0007891b          	sext.w	s2,a5
    80003b6e:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003b70:	509c                	lw	a5,32(s1)
    80003b72:	ef9d                	bnez	a5,80003bb0 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b74:	04091463          	bnez	s2,80003bbc <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b78:	0001c497          	auipc	s1,0x1c
    80003b7c:	dd048493          	addi	s1,s1,-560 # 8001f948 <log>
    80003b80:	4785                	li	a5,1
    80003b82:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b84:	8526                	mv	a0,s1
    80003b86:	87cfd0ef          	jal	ra,80000c02 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b8a:	549c                	lw	a5,40(s1)
    80003b8c:	04f04b63          	bgtz	a5,80003be2 <end_op+0x9c>
    acquire(&log.lock);
    80003b90:	0001c497          	auipc	s1,0x1c
    80003b94:	db848493          	addi	s1,s1,-584 # 8001f948 <log>
    80003b98:	8526                	mv	a0,s1
    80003b9a:	fd1fc0ef          	jal	ra,80000b6a <acquire>
    log.committing = 0;
    80003b9e:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	ab2fe0ef          	jal	ra,80001e56 <wakeup>
    release(&log.lock);
    80003ba8:	8526                	mv	a0,s1
    80003baa:	858fd0ef          	jal	ra,80000c02 <release>
}
    80003bae:	a00d                	j	80003bd0 <end_op+0x8a>
    panic("log.committing");
    80003bb0:	00004517          	auipc	a0,0x4
    80003bb4:	a6050513          	addi	a0,a0,-1440 # 80007610 <syscalls+0x220>
    80003bb8:	bd1fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    80003bbc:	0001c497          	auipc	s1,0x1c
    80003bc0:	d8c48493          	addi	s1,s1,-628 # 8001f948 <log>
    80003bc4:	8526                	mv	a0,s1
    80003bc6:	a90fe0ef          	jal	ra,80001e56 <wakeup>
  release(&log.lock);
    80003bca:	8526                	mv	a0,s1
    80003bcc:	836fd0ef          	jal	ra,80000c02 <release>
}
    80003bd0:	70e2                	ld	ra,56(sp)
    80003bd2:	7442                	ld	s0,48(sp)
    80003bd4:	74a2                	ld	s1,40(sp)
    80003bd6:	7902                	ld	s2,32(sp)
    80003bd8:	69e2                	ld	s3,24(sp)
    80003bda:	6a42                	ld	s4,16(sp)
    80003bdc:	6aa2                	ld	s5,8(sp)
    80003bde:	6121                	addi	sp,sp,64
    80003be0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003be2:	0001ca97          	auipc	s5,0x1c
    80003be6:	d92a8a93          	addi	s5,s5,-622 # 8001f974 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bea:	0001ca17          	auipc	s4,0x1c
    80003bee:	d5ea0a13          	addi	s4,s4,-674 # 8001f948 <log>
    80003bf2:	018a2583          	lw	a1,24(s4)
    80003bf6:	012585bb          	addw	a1,a1,s2
    80003bfa:	2585                	addiw	a1,a1,1
    80003bfc:	024a2503          	lw	a0,36(s4)
    80003c00:	e41fe0ef          	jal	ra,80002a40 <bread>
    80003c04:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c06:	000aa583          	lw	a1,0(s5)
    80003c0a:	024a2503          	lw	a0,36(s4)
    80003c0e:	e33fe0ef          	jal	ra,80002a40 <bread>
    80003c12:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c14:	40000613          	li	a2,1024
    80003c18:	05850593          	addi	a1,a0,88
    80003c1c:	05848513          	addi	a0,s1,88
    80003c20:	87afd0ef          	jal	ra,80000c9a <memmove>
    bwrite(to);  // write the log
    80003c24:	8526                	mv	a0,s1
    80003c26:	ef1fe0ef          	jal	ra,80002b16 <bwrite>
    brelse(from);
    80003c2a:	854e                	mv	a0,s3
    80003c2c:	f1dfe0ef          	jal	ra,80002b48 <brelse>
    brelse(to);
    80003c30:	8526                	mv	a0,s1
    80003c32:	f17fe0ef          	jal	ra,80002b48 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c36:	2905                	addiw	s2,s2,1
    80003c38:	0a91                	addi	s5,s5,4
    80003c3a:	028a2783          	lw	a5,40(s4)
    80003c3e:	faf94ae3          	blt	s2,a5,80003bf2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c42:	cd5ff0ef          	jal	ra,80003916 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c46:	4501                	li	a0,0
    80003c48:	d3fff0ef          	jal	ra,80003986 <install_trans>
    log.lh.n = 0;
    80003c4c:	0001c797          	auipc	a5,0x1c
    80003c50:	d207a223          	sw	zero,-732(a5) # 8001f970 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003c54:	cc3ff0ef          	jal	ra,80003916 <write_head>
    80003c58:	bf25                	j	80003b90 <end_op+0x4a>

0000000080003c5a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c5a:	1101                	addi	sp,sp,-32
    80003c5c:	ec06                	sd	ra,24(sp)
    80003c5e:	e822                	sd	s0,16(sp)
    80003c60:	e426                	sd	s1,8(sp)
    80003c62:	e04a                	sd	s2,0(sp)
    80003c64:	1000                	addi	s0,sp,32
    80003c66:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c68:	0001c917          	auipc	s2,0x1c
    80003c6c:	ce090913          	addi	s2,s2,-800 # 8001f948 <log>
    80003c70:	854a                	mv	a0,s2
    80003c72:	ef9fc0ef          	jal	ra,80000b6a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003c76:	02892603          	lw	a2,40(s2)
    80003c7a:	47f5                	li	a5,29
    80003c7c:	04c7cc63          	blt	a5,a2,80003cd4 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c80:	0001c797          	auipc	a5,0x1c
    80003c84:	ce47a783          	lw	a5,-796(a5) # 8001f964 <log+0x1c>
    80003c88:	04f05c63          	blez	a5,80003ce0 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c8c:	4781                	li	a5,0
    80003c8e:	04c05f63          	blez	a2,80003cec <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c92:	44cc                	lw	a1,12(s1)
    80003c94:	0001c717          	auipc	a4,0x1c
    80003c98:	ce070713          	addi	a4,a4,-800 # 8001f974 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003c9c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c9e:	4314                	lw	a3,0(a4)
    80003ca0:	04b68663          	beq	a3,a1,80003cec <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003ca4:	2785                	addiw	a5,a5,1
    80003ca6:	0711                	addi	a4,a4,4
    80003ca8:	fef61be3          	bne	a2,a5,80003c9e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003cac:	0621                	addi	a2,a2,8
    80003cae:	060a                	slli	a2,a2,0x2
    80003cb0:	0001c797          	auipc	a5,0x1c
    80003cb4:	c9878793          	addi	a5,a5,-872 # 8001f948 <log>
    80003cb8:	97b2                	add	a5,a5,a2
    80003cba:	44d8                	lw	a4,12(s1)
    80003cbc:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	f13fe0ef          	jal	ra,80002bd2 <bpin>
    log.lh.n++;
    80003cc4:	0001c717          	auipc	a4,0x1c
    80003cc8:	c8470713          	addi	a4,a4,-892 # 8001f948 <log>
    80003ccc:	571c                	lw	a5,40(a4)
    80003cce:	2785                	addiw	a5,a5,1
    80003cd0:	d71c                	sw	a5,40(a4)
    80003cd2:	a80d                	j	80003d04 <log_write+0xaa>
    panic("too big a transaction");
    80003cd4:	00004517          	auipc	a0,0x4
    80003cd8:	94c50513          	addi	a0,a0,-1716 # 80007620 <syscalls+0x230>
    80003cdc:	aadfc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    80003ce0:	00004517          	auipc	a0,0x4
    80003ce4:	95850513          	addi	a0,a0,-1704 # 80007638 <syscalls+0x248>
    80003ce8:	aa1fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    80003cec:	00878693          	addi	a3,a5,8
    80003cf0:	068a                	slli	a3,a3,0x2
    80003cf2:	0001c717          	auipc	a4,0x1c
    80003cf6:	c5670713          	addi	a4,a4,-938 # 8001f948 <log>
    80003cfa:	9736                	add	a4,a4,a3
    80003cfc:	44d4                	lw	a3,12(s1)
    80003cfe:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d00:	faf60fe3          	beq	a2,a5,80003cbe <log_write+0x64>
  }
  release(&log.lock);
    80003d04:	0001c517          	auipc	a0,0x1c
    80003d08:	c4450513          	addi	a0,a0,-956 # 8001f948 <log>
    80003d0c:	ef7fc0ef          	jal	ra,80000c02 <release>
}
    80003d10:	60e2                	ld	ra,24(sp)
    80003d12:	6442                	ld	s0,16(sp)
    80003d14:	64a2                	ld	s1,8(sp)
    80003d16:	6902                	ld	s2,0(sp)
    80003d18:	6105                	addi	sp,sp,32
    80003d1a:	8082                	ret

0000000080003d1c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d1c:	1101                	addi	sp,sp,-32
    80003d1e:	ec06                	sd	ra,24(sp)
    80003d20:	e822                	sd	s0,16(sp)
    80003d22:	e426                	sd	s1,8(sp)
    80003d24:	e04a                	sd	s2,0(sp)
    80003d26:	1000                	addi	s0,sp,32
    80003d28:	84aa                	mv	s1,a0
    80003d2a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d2c:	00004597          	auipc	a1,0x4
    80003d30:	92c58593          	addi	a1,a1,-1748 # 80007658 <syscalls+0x268>
    80003d34:	0521                	addi	a0,a0,8
    80003d36:	db5fc0ef          	jal	ra,80000aea <initlock>
  lk->name = name;
    80003d3a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d3e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d42:	0204a423          	sw	zero,40(s1)
}
    80003d46:	60e2                	ld	ra,24(sp)
    80003d48:	6442                	ld	s0,16(sp)
    80003d4a:	64a2                	ld	s1,8(sp)
    80003d4c:	6902                	ld	s2,0(sp)
    80003d4e:	6105                	addi	sp,sp,32
    80003d50:	8082                	ret

0000000080003d52 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d52:	1101                	addi	sp,sp,-32
    80003d54:	ec06                	sd	ra,24(sp)
    80003d56:	e822                	sd	s0,16(sp)
    80003d58:	e426                	sd	s1,8(sp)
    80003d5a:	e04a                	sd	s2,0(sp)
    80003d5c:	1000                	addi	s0,sp,32
    80003d5e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d60:	00850913          	addi	s2,a0,8
    80003d64:	854a                	mv	a0,s2
    80003d66:	e05fc0ef          	jal	ra,80000b6a <acquire>
  while (lk->locked) {
    80003d6a:	409c                	lw	a5,0(s1)
    80003d6c:	c799                	beqz	a5,80003d7a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d6e:	85ca                	mv	a1,s2
    80003d70:	8526                	mv	a0,s1
    80003d72:	898fe0ef          	jal	ra,80001e0a <sleep>
  while (lk->locked) {
    80003d76:	409c                	lw	a5,0(s1)
    80003d78:	fbfd                	bnez	a5,80003d6e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d7a:	4785                	li	a5,1
    80003d7c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d7e:	a85fd0ef          	jal	ra,80001802 <myproc>
    80003d82:	591c                	lw	a5,48(a0)
    80003d84:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d86:	854a                	mv	a0,s2
    80003d88:	e7bfc0ef          	jal	ra,80000c02 <release>
}
    80003d8c:	60e2                	ld	ra,24(sp)
    80003d8e:	6442                	ld	s0,16(sp)
    80003d90:	64a2                	ld	s1,8(sp)
    80003d92:	6902                	ld	s2,0(sp)
    80003d94:	6105                	addi	sp,sp,32
    80003d96:	8082                	ret

0000000080003d98 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003d98:	1101                	addi	sp,sp,-32
    80003d9a:	ec06                	sd	ra,24(sp)
    80003d9c:	e822                	sd	s0,16(sp)
    80003d9e:	e426                	sd	s1,8(sp)
    80003da0:	e04a                	sd	s2,0(sp)
    80003da2:	1000                	addi	s0,sp,32
    80003da4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003da6:	00850913          	addi	s2,a0,8
    80003daa:	854a                	mv	a0,s2
    80003dac:	dbffc0ef          	jal	ra,80000b6a <acquire>
  lk->locked = 0;
    80003db0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003db4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003db8:	8526                	mv	a0,s1
    80003dba:	89cfe0ef          	jal	ra,80001e56 <wakeup>
  release(&lk->lk);
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	e43fc0ef          	jal	ra,80000c02 <release>
}
    80003dc4:	60e2                	ld	ra,24(sp)
    80003dc6:	6442                	ld	s0,16(sp)
    80003dc8:	64a2                	ld	s1,8(sp)
    80003dca:	6902                	ld	s2,0(sp)
    80003dcc:	6105                	addi	sp,sp,32
    80003dce:	8082                	ret

0000000080003dd0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003dd0:	7179                	addi	sp,sp,-48
    80003dd2:	f406                	sd	ra,40(sp)
    80003dd4:	f022                	sd	s0,32(sp)
    80003dd6:	ec26                	sd	s1,24(sp)
    80003dd8:	e84a                	sd	s2,16(sp)
    80003dda:	e44e                	sd	s3,8(sp)
    80003ddc:	1800                	addi	s0,sp,48
    80003dde:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003de0:	00850913          	addi	s2,a0,8
    80003de4:	854a                	mv	a0,s2
    80003de6:	d85fc0ef          	jal	ra,80000b6a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003dea:	409c                	lw	a5,0(s1)
    80003dec:	ef89                	bnez	a5,80003e06 <holdingsleep+0x36>
    80003dee:	4481                	li	s1,0
  release(&lk->lk);
    80003df0:	854a                	mv	a0,s2
    80003df2:	e11fc0ef          	jal	ra,80000c02 <release>
  return r;
}
    80003df6:	8526                	mv	a0,s1
    80003df8:	70a2                	ld	ra,40(sp)
    80003dfa:	7402                	ld	s0,32(sp)
    80003dfc:	64e2                	ld	s1,24(sp)
    80003dfe:	6942                	ld	s2,16(sp)
    80003e00:	69a2                	ld	s3,8(sp)
    80003e02:	6145                	addi	sp,sp,48
    80003e04:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e06:	0284a983          	lw	s3,40(s1)
    80003e0a:	9f9fd0ef          	jal	ra,80001802 <myproc>
    80003e0e:	5904                	lw	s1,48(a0)
    80003e10:	413484b3          	sub	s1,s1,s3
    80003e14:	0014b493          	seqz	s1,s1
    80003e18:	bfe1                	j	80003df0 <holdingsleep+0x20>

0000000080003e1a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e1a:	1141                	addi	sp,sp,-16
    80003e1c:	e406                	sd	ra,8(sp)
    80003e1e:	e022                	sd	s0,0(sp)
    80003e20:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e22:	00004597          	auipc	a1,0x4
    80003e26:	84658593          	addi	a1,a1,-1978 # 80007668 <syscalls+0x278>
    80003e2a:	0001c517          	auipc	a0,0x1c
    80003e2e:	c6650513          	addi	a0,a0,-922 # 8001fa90 <ftable>
    80003e32:	cb9fc0ef          	jal	ra,80000aea <initlock>
}
    80003e36:	60a2                	ld	ra,8(sp)
    80003e38:	6402                	ld	s0,0(sp)
    80003e3a:	0141                	addi	sp,sp,16
    80003e3c:	8082                	ret

0000000080003e3e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	e426                	sd	s1,8(sp)
    80003e46:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e48:	0001c517          	auipc	a0,0x1c
    80003e4c:	c4850513          	addi	a0,a0,-952 # 8001fa90 <ftable>
    80003e50:	d1bfc0ef          	jal	ra,80000b6a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e54:	0001c497          	auipc	s1,0x1c
    80003e58:	c5448493          	addi	s1,s1,-940 # 8001faa8 <ftable+0x18>
    80003e5c:	0001d717          	auipc	a4,0x1d
    80003e60:	bec70713          	addi	a4,a4,-1044 # 80020a48 <disk>
    if(f->ref == 0){
    80003e64:	40dc                	lw	a5,4(s1)
    80003e66:	cf89                	beqz	a5,80003e80 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e68:	02848493          	addi	s1,s1,40
    80003e6c:	fee49ce3          	bne	s1,a4,80003e64 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e70:	0001c517          	auipc	a0,0x1c
    80003e74:	c2050513          	addi	a0,a0,-992 # 8001fa90 <ftable>
    80003e78:	d8bfc0ef          	jal	ra,80000c02 <release>
  return 0;
    80003e7c:	4481                	li	s1,0
    80003e7e:	a809                	j	80003e90 <filealloc+0x52>
      f->ref = 1;
    80003e80:	4785                	li	a5,1
    80003e82:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e84:	0001c517          	auipc	a0,0x1c
    80003e88:	c0c50513          	addi	a0,a0,-1012 # 8001fa90 <ftable>
    80003e8c:	d77fc0ef          	jal	ra,80000c02 <release>
}
    80003e90:	8526                	mv	a0,s1
    80003e92:	60e2                	ld	ra,24(sp)
    80003e94:	6442                	ld	s0,16(sp)
    80003e96:	64a2                	ld	s1,8(sp)
    80003e98:	6105                	addi	sp,sp,32
    80003e9a:	8082                	ret

0000000080003e9c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003e9c:	1101                	addi	sp,sp,-32
    80003e9e:	ec06                	sd	ra,24(sp)
    80003ea0:	e822                	sd	s0,16(sp)
    80003ea2:	e426                	sd	s1,8(sp)
    80003ea4:	1000                	addi	s0,sp,32
    80003ea6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ea8:	0001c517          	auipc	a0,0x1c
    80003eac:	be850513          	addi	a0,a0,-1048 # 8001fa90 <ftable>
    80003eb0:	cbbfc0ef          	jal	ra,80000b6a <acquire>
  if(f->ref < 1)
    80003eb4:	40dc                	lw	a5,4(s1)
    80003eb6:	02f05063          	blez	a5,80003ed6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003eba:	2785                	addiw	a5,a5,1
    80003ebc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ebe:	0001c517          	auipc	a0,0x1c
    80003ec2:	bd250513          	addi	a0,a0,-1070 # 8001fa90 <ftable>
    80003ec6:	d3dfc0ef          	jal	ra,80000c02 <release>
  return f;
}
    80003eca:	8526                	mv	a0,s1
    80003ecc:	60e2                	ld	ra,24(sp)
    80003ece:	6442                	ld	s0,16(sp)
    80003ed0:	64a2                	ld	s1,8(sp)
    80003ed2:	6105                	addi	sp,sp,32
    80003ed4:	8082                	ret
    panic("filedup");
    80003ed6:	00003517          	auipc	a0,0x3
    80003eda:	79a50513          	addi	a0,a0,1946 # 80007670 <syscalls+0x280>
    80003ede:	8abfc0ef          	jal	ra,80000788 <panic>

0000000080003ee2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003ee2:	7139                	addi	sp,sp,-64
    80003ee4:	fc06                	sd	ra,56(sp)
    80003ee6:	f822                	sd	s0,48(sp)
    80003ee8:	f426                	sd	s1,40(sp)
    80003eea:	f04a                	sd	s2,32(sp)
    80003eec:	ec4e                	sd	s3,24(sp)
    80003eee:	e852                	sd	s4,16(sp)
    80003ef0:	e456                	sd	s5,8(sp)
    80003ef2:	0080                	addi	s0,sp,64
    80003ef4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003ef6:	0001c517          	auipc	a0,0x1c
    80003efa:	b9a50513          	addi	a0,a0,-1126 # 8001fa90 <ftable>
    80003efe:	c6dfc0ef          	jal	ra,80000b6a <acquire>
  if(f->ref < 1)
    80003f02:	40dc                	lw	a5,4(s1)
    80003f04:	04f05963          	blez	a5,80003f56 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003f08:	37fd                	addiw	a5,a5,-1
    80003f0a:	0007871b          	sext.w	a4,a5
    80003f0e:	c0dc                	sw	a5,4(s1)
    80003f10:	04e04963          	bgtz	a4,80003f62 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f14:	0004a903          	lw	s2,0(s1)
    80003f18:	0094ca83          	lbu	s5,9(s1)
    80003f1c:	0104ba03          	ld	s4,16(s1)
    80003f20:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f24:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f28:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f2c:	0001c517          	auipc	a0,0x1c
    80003f30:	b6450513          	addi	a0,a0,-1180 # 8001fa90 <ftable>
    80003f34:	ccffc0ef          	jal	ra,80000c02 <release>

  if(ff.type == FD_PIPE){
    80003f38:	4785                	li	a5,1
    80003f3a:	04f90363          	beq	s2,a5,80003f80 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f3e:	3979                	addiw	s2,s2,-2
    80003f40:	4785                	li	a5,1
    80003f42:	0327e663          	bltu	a5,s2,80003f6e <fileclose+0x8c>
    begin_op();
    80003f46:	b93ff0ef          	jal	ra,80003ad8 <begin_op>
    iput(ff.ip);
    80003f4a:	854e                	mv	a0,s3
    80003f4c:	b22ff0ef          	jal	ra,8000326e <iput>
    end_op();
    80003f50:	bf7ff0ef          	jal	ra,80003b46 <end_op>
    80003f54:	a829                	j	80003f6e <fileclose+0x8c>
    panic("fileclose");
    80003f56:	00003517          	auipc	a0,0x3
    80003f5a:	72250513          	addi	a0,a0,1826 # 80007678 <syscalls+0x288>
    80003f5e:	82bfc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80003f62:	0001c517          	auipc	a0,0x1c
    80003f66:	b2e50513          	addi	a0,a0,-1234 # 8001fa90 <ftable>
    80003f6a:	c99fc0ef          	jal	ra,80000c02 <release>
  }
}
    80003f6e:	70e2                	ld	ra,56(sp)
    80003f70:	7442                	ld	s0,48(sp)
    80003f72:	74a2                	ld	s1,40(sp)
    80003f74:	7902                	ld	s2,32(sp)
    80003f76:	69e2                	ld	s3,24(sp)
    80003f78:	6a42                	ld	s4,16(sp)
    80003f7a:	6aa2                	ld	s5,8(sp)
    80003f7c:	6121                	addi	sp,sp,64
    80003f7e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f80:	85d6                	mv	a1,s5
    80003f82:	8552                	mv	a0,s4
    80003f84:	2ec000ef          	jal	ra,80004270 <pipeclose>
    80003f88:	b7dd                	j	80003f6e <fileclose+0x8c>

0000000080003f8a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003f8a:	715d                	addi	sp,sp,-80
    80003f8c:	e486                	sd	ra,72(sp)
    80003f8e:	e0a2                	sd	s0,64(sp)
    80003f90:	fc26                	sd	s1,56(sp)
    80003f92:	f84a                	sd	s2,48(sp)
    80003f94:	f44e                	sd	s3,40(sp)
    80003f96:	0880                	addi	s0,sp,80
    80003f98:	84aa                	mv	s1,a0
    80003f9a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003f9c:	867fd0ef          	jal	ra,80001802 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003fa0:	409c                	lw	a5,0(s1)
    80003fa2:	37f9                	addiw	a5,a5,-2
    80003fa4:	4705                	li	a4,1
    80003fa6:	02f76f63          	bltu	a4,a5,80003fe4 <filestat+0x5a>
    80003faa:	892a                	mv	s2,a0
    ilock(f->ip);
    80003fac:	6c88                	ld	a0,24(s1)
    80003fae:	942ff0ef          	jal	ra,800030f0 <ilock>
    stati(f->ip, &st);
    80003fb2:	fb840593          	addi	a1,s0,-72
    80003fb6:	6c88                	ld	a0,24(s1)
    80003fb8:	c9aff0ef          	jal	ra,80003452 <stati>
    iunlock(f->ip);
    80003fbc:	6c88                	ld	a0,24(s1)
    80003fbe:	9dcff0ef          	jal	ra,8000319a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003fc2:	46e1                	li	a3,24
    80003fc4:	fb840613          	addi	a2,s0,-72
    80003fc8:	85ce                	mv	a1,s3
    80003fca:	05093503          	ld	a0,80(s2)
    80003fce:	d82fd0ef          	jal	ra,80001550 <copyout>
    80003fd2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003fd6:	60a6                	ld	ra,72(sp)
    80003fd8:	6406                	ld	s0,64(sp)
    80003fda:	74e2                	ld	s1,56(sp)
    80003fdc:	7942                	ld	s2,48(sp)
    80003fde:	79a2                	ld	s3,40(sp)
    80003fe0:	6161                	addi	sp,sp,80
    80003fe2:	8082                	ret
  return -1;
    80003fe4:	557d                	li	a0,-1
    80003fe6:	bfc5                	j	80003fd6 <filestat+0x4c>

0000000080003fe8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003fe8:	7179                	addi	sp,sp,-48
    80003fea:	f406                	sd	ra,40(sp)
    80003fec:	f022                	sd	s0,32(sp)
    80003fee:	ec26                	sd	s1,24(sp)
    80003ff0:	e84a                	sd	s2,16(sp)
    80003ff2:	e44e                	sd	s3,8(sp)
    80003ff4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003ff6:	00854783          	lbu	a5,8(a0)
    80003ffa:	cbc1                	beqz	a5,8000408a <fileread+0xa2>
    80003ffc:	84aa                	mv	s1,a0
    80003ffe:	89ae                	mv	s3,a1
    80004000:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004002:	411c                	lw	a5,0(a0)
    80004004:	4705                	li	a4,1
    80004006:	04e78363          	beq	a5,a4,8000404c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000400a:	470d                	li	a4,3
    8000400c:	04e78563          	beq	a5,a4,80004056 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004010:	4709                	li	a4,2
    80004012:	06e79663          	bne	a5,a4,8000407e <fileread+0x96>
    ilock(f->ip);
    80004016:	6d08                	ld	a0,24(a0)
    80004018:	8d8ff0ef          	jal	ra,800030f0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000401c:	874a                	mv	a4,s2
    8000401e:	5094                	lw	a3,32(s1)
    80004020:	864e                	mv	a2,s3
    80004022:	4585                	li	a1,1
    80004024:	6c88                	ld	a0,24(s1)
    80004026:	c56ff0ef          	jal	ra,8000347c <readi>
    8000402a:	892a                	mv	s2,a0
    8000402c:	00a05563          	blez	a0,80004036 <fileread+0x4e>
      f->off += r;
    80004030:	509c                	lw	a5,32(s1)
    80004032:	9fa9                	addw	a5,a5,a0
    80004034:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004036:	6c88                	ld	a0,24(s1)
    80004038:	962ff0ef          	jal	ra,8000319a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000403c:	854a                	mv	a0,s2
    8000403e:	70a2                	ld	ra,40(sp)
    80004040:	7402                	ld	s0,32(sp)
    80004042:	64e2                	ld	s1,24(sp)
    80004044:	6942                	ld	s2,16(sp)
    80004046:	69a2                	ld	s3,8(sp)
    80004048:	6145                	addi	sp,sp,48
    8000404a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000404c:	6908                	ld	a0,16(a0)
    8000404e:	34e000ef          	jal	ra,8000439c <piperead>
    80004052:	892a                	mv	s2,a0
    80004054:	b7e5                	j	8000403c <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004056:	02451783          	lh	a5,36(a0)
    8000405a:	03079693          	slli	a3,a5,0x30
    8000405e:	92c1                	srli	a3,a3,0x30
    80004060:	4725                	li	a4,9
    80004062:	02d76663          	bltu	a4,a3,8000408e <fileread+0xa6>
    80004066:	0792                	slli	a5,a5,0x4
    80004068:	0001c717          	auipc	a4,0x1c
    8000406c:	98870713          	addi	a4,a4,-1656 # 8001f9f0 <devsw>
    80004070:	97ba                	add	a5,a5,a4
    80004072:	639c                	ld	a5,0(a5)
    80004074:	cf99                	beqz	a5,80004092 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004076:	4505                	li	a0,1
    80004078:	9782                	jalr	a5
    8000407a:	892a                	mv	s2,a0
    8000407c:	b7c1                	j	8000403c <fileread+0x54>
    panic("fileread");
    8000407e:	00003517          	auipc	a0,0x3
    80004082:	60a50513          	addi	a0,a0,1546 # 80007688 <syscalls+0x298>
    80004086:	f02fc0ef          	jal	ra,80000788 <panic>
    return -1;
    8000408a:	597d                	li	s2,-1
    8000408c:	bf45                	j	8000403c <fileread+0x54>
      return -1;
    8000408e:	597d                	li	s2,-1
    80004090:	b775                	j	8000403c <fileread+0x54>
    80004092:	597d                	li	s2,-1
    80004094:	b765                	j	8000403c <fileread+0x54>

0000000080004096 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004096:	715d                	addi	sp,sp,-80
    80004098:	e486                	sd	ra,72(sp)
    8000409a:	e0a2                	sd	s0,64(sp)
    8000409c:	fc26                	sd	s1,56(sp)
    8000409e:	f84a                	sd	s2,48(sp)
    800040a0:	f44e                	sd	s3,40(sp)
    800040a2:	f052                	sd	s4,32(sp)
    800040a4:	ec56                	sd	s5,24(sp)
    800040a6:	e85a                	sd	s6,16(sp)
    800040a8:	e45e                	sd	s7,8(sp)
    800040aa:	e062                	sd	s8,0(sp)
    800040ac:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800040ae:	00954783          	lbu	a5,9(a0)
    800040b2:	0e078863          	beqz	a5,800041a2 <filewrite+0x10c>
    800040b6:	892a                	mv	s2,a0
    800040b8:	8b2e                	mv	s6,a1
    800040ba:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800040bc:	411c                	lw	a5,0(a0)
    800040be:	4705                	li	a4,1
    800040c0:	02e78263          	beq	a5,a4,800040e4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040c4:	470d                	li	a4,3
    800040c6:	02e78463          	beq	a5,a4,800040ee <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800040ca:	4709                	li	a4,2
    800040cc:	0ce79563          	bne	a5,a4,80004196 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800040d0:	0ac05163          	blez	a2,80004172 <filewrite+0xdc>
    int i = 0;
    800040d4:	4981                	li	s3,0
    800040d6:	6b85                	lui	s7,0x1
    800040d8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800040dc:	6c05                	lui	s8,0x1
    800040de:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800040e2:	a041                	j	80004162 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800040e4:	6908                	ld	a0,16(a0)
    800040e6:	1e2000ef          	jal	ra,800042c8 <pipewrite>
    800040ea:	8a2a                	mv	s4,a0
    800040ec:	a071                	j	80004178 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800040ee:	02451783          	lh	a5,36(a0)
    800040f2:	03079693          	slli	a3,a5,0x30
    800040f6:	92c1                	srli	a3,a3,0x30
    800040f8:	4725                	li	a4,9
    800040fa:	0ad76663          	bltu	a4,a3,800041a6 <filewrite+0x110>
    800040fe:	0792                	slli	a5,a5,0x4
    80004100:	0001c717          	auipc	a4,0x1c
    80004104:	8f070713          	addi	a4,a4,-1808 # 8001f9f0 <devsw>
    80004108:	97ba                	add	a5,a5,a4
    8000410a:	679c                	ld	a5,8(a5)
    8000410c:	cfd9                	beqz	a5,800041aa <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000410e:	4505                	li	a0,1
    80004110:	9782                	jalr	a5
    80004112:	8a2a                	mv	s4,a0
    80004114:	a095                	j	80004178 <filewrite+0xe2>
    80004116:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000411a:	9bfff0ef          	jal	ra,80003ad8 <begin_op>
      ilock(f->ip);
    8000411e:	01893503          	ld	a0,24(s2)
    80004122:	fcffe0ef          	jal	ra,800030f0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004126:	8756                	mv	a4,s5
    80004128:	02092683          	lw	a3,32(s2)
    8000412c:	01698633          	add	a2,s3,s6
    80004130:	4585                	li	a1,1
    80004132:	01893503          	ld	a0,24(s2)
    80004136:	c2aff0ef          	jal	ra,80003560 <writei>
    8000413a:	84aa                	mv	s1,a0
    8000413c:	00a05763          	blez	a0,8000414a <filewrite+0xb4>
        f->off += r;
    80004140:	02092783          	lw	a5,32(s2)
    80004144:	9fa9                	addw	a5,a5,a0
    80004146:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000414a:	01893503          	ld	a0,24(s2)
    8000414e:	84cff0ef          	jal	ra,8000319a <iunlock>
      end_op();
    80004152:	9f5ff0ef          	jal	ra,80003b46 <end_op>

      if(r != n1){
    80004156:	009a9f63          	bne	s5,s1,80004174 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    8000415a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000415e:	0149db63          	bge	s3,s4,80004174 <filewrite+0xde>
      int n1 = n - i;
    80004162:	413a04bb          	subw	s1,s4,s3
    80004166:	0004879b          	sext.w	a5,s1
    8000416a:	fafbd6e3          	bge	s7,a5,80004116 <filewrite+0x80>
    8000416e:	84e2                	mv	s1,s8
    80004170:	b75d                	j	80004116 <filewrite+0x80>
    int i = 0;
    80004172:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004174:	013a1f63          	bne	s4,s3,80004192 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004178:	8552                	mv	a0,s4
    8000417a:	60a6                	ld	ra,72(sp)
    8000417c:	6406                	ld	s0,64(sp)
    8000417e:	74e2                	ld	s1,56(sp)
    80004180:	7942                	ld	s2,48(sp)
    80004182:	79a2                	ld	s3,40(sp)
    80004184:	7a02                	ld	s4,32(sp)
    80004186:	6ae2                	ld	s5,24(sp)
    80004188:	6b42                	ld	s6,16(sp)
    8000418a:	6ba2                	ld	s7,8(sp)
    8000418c:	6c02                	ld	s8,0(sp)
    8000418e:	6161                	addi	sp,sp,80
    80004190:	8082                	ret
    ret = (i == n ? n : -1);
    80004192:	5a7d                	li	s4,-1
    80004194:	b7d5                	j	80004178 <filewrite+0xe2>
    panic("filewrite");
    80004196:	00003517          	auipc	a0,0x3
    8000419a:	50250513          	addi	a0,a0,1282 # 80007698 <syscalls+0x2a8>
    8000419e:	deafc0ef          	jal	ra,80000788 <panic>
    return -1;
    800041a2:	5a7d                	li	s4,-1
    800041a4:	bfd1                	j	80004178 <filewrite+0xe2>
      return -1;
    800041a6:	5a7d                	li	s4,-1
    800041a8:	bfc1                	j	80004178 <filewrite+0xe2>
    800041aa:	5a7d                	li	s4,-1
    800041ac:	b7f1                	j	80004178 <filewrite+0xe2>

00000000800041ae <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800041ae:	7179                	addi	sp,sp,-48
    800041b0:	f406                	sd	ra,40(sp)
    800041b2:	f022                	sd	s0,32(sp)
    800041b4:	ec26                	sd	s1,24(sp)
    800041b6:	e84a                	sd	s2,16(sp)
    800041b8:	e44e                	sd	s3,8(sp)
    800041ba:	e052                	sd	s4,0(sp)
    800041bc:	1800                	addi	s0,sp,48
    800041be:	84aa                	mv	s1,a0
    800041c0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800041c2:	0005b023          	sd	zero,0(a1)
    800041c6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800041ca:	c75ff0ef          	jal	ra,80003e3e <filealloc>
    800041ce:	e088                	sd	a0,0(s1)
    800041d0:	cd35                	beqz	a0,8000424c <pipealloc+0x9e>
    800041d2:	c6dff0ef          	jal	ra,80003e3e <filealloc>
    800041d6:	00aa3023          	sd	a0,0(s4)
    800041da:	c52d                	beqz	a0,80004244 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800041dc:	8bffc0ef          	jal	ra,80000a9a <kalloc>
    800041e0:	892a                	mv	s2,a0
    800041e2:	cd31                	beqz	a0,8000423e <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800041e4:	4985                	li	s3,1
    800041e6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800041ea:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800041ee:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800041f2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800041f6:	00003597          	auipc	a1,0x3
    800041fa:	4b258593          	addi	a1,a1,1202 # 800076a8 <syscalls+0x2b8>
    800041fe:	8edfc0ef          	jal	ra,80000aea <initlock>
  (*f0)->type = FD_PIPE;
    80004202:	609c                	ld	a5,0(s1)
    80004204:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004208:	609c                	ld	a5,0(s1)
    8000420a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000420e:	609c                	ld	a5,0(s1)
    80004210:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004214:	609c                	ld	a5,0(s1)
    80004216:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000421a:	000a3783          	ld	a5,0(s4)
    8000421e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004222:	000a3783          	ld	a5,0(s4)
    80004226:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000422a:	000a3783          	ld	a5,0(s4)
    8000422e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004232:	000a3783          	ld	a5,0(s4)
    80004236:	0127b823          	sd	s2,16(a5)
  return 0;
    8000423a:	4501                	li	a0,0
    8000423c:	a005                	j	8000425c <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000423e:	6088                	ld	a0,0(s1)
    80004240:	e501                	bnez	a0,80004248 <pipealloc+0x9a>
    80004242:	a029                	j	8000424c <pipealloc+0x9e>
    80004244:	6088                	ld	a0,0(s1)
    80004246:	c11d                	beqz	a0,8000426c <pipealloc+0xbe>
    fileclose(*f0);
    80004248:	c9bff0ef          	jal	ra,80003ee2 <fileclose>
  if(*f1)
    8000424c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004250:	557d                	li	a0,-1
  if(*f1)
    80004252:	c789                	beqz	a5,8000425c <pipealloc+0xae>
    fileclose(*f1);
    80004254:	853e                	mv	a0,a5
    80004256:	c8dff0ef          	jal	ra,80003ee2 <fileclose>
  return -1;
    8000425a:	557d                	li	a0,-1
}
    8000425c:	70a2                	ld	ra,40(sp)
    8000425e:	7402                	ld	s0,32(sp)
    80004260:	64e2                	ld	s1,24(sp)
    80004262:	6942                	ld	s2,16(sp)
    80004264:	69a2                	ld	s3,8(sp)
    80004266:	6a02                	ld	s4,0(sp)
    80004268:	6145                	addi	sp,sp,48
    8000426a:	8082                	ret
  return -1;
    8000426c:	557d                	li	a0,-1
    8000426e:	b7fd                	j	8000425c <pipealloc+0xae>

0000000080004270 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004270:	1101                	addi	sp,sp,-32
    80004272:	ec06                	sd	ra,24(sp)
    80004274:	e822                	sd	s0,16(sp)
    80004276:	e426                	sd	s1,8(sp)
    80004278:	e04a                	sd	s2,0(sp)
    8000427a:	1000                	addi	s0,sp,32
    8000427c:	84aa                	mv	s1,a0
    8000427e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004280:	8ebfc0ef          	jal	ra,80000b6a <acquire>
  if(writable){
    80004284:	02090763          	beqz	s2,800042b2 <pipeclose+0x42>
    pi->writeopen = 0;
    80004288:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000428c:	21848513          	addi	a0,s1,536
    80004290:	bc7fd0ef          	jal	ra,80001e56 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004294:	2204b783          	ld	a5,544(s1)
    80004298:	e785                	bnez	a5,800042c0 <pipeclose+0x50>
    release(&pi->lock);
    8000429a:	8526                	mv	a0,s1
    8000429c:	967fc0ef          	jal	ra,80000c02 <release>
    kfree((char*)pi);
    800042a0:	8526                	mv	a0,s1
    800042a2:	f16fc0ef          	jal	ra,800009b8 <kfree>
  } else
    release(&pi->lock);
}
    800042a6:	60e2                	ld	ra,24(sp)
    800042a8:	6442                	ld	s0,16(sp)
    800042aa:	64a2                	ld	s1,8(sp)
    800042ac:	6902                	ld	s2,0(sp)
    800042ae:	6105                	addi	sp,sp,32
    800042b0:	8082                	ret
    pi->readopen = 0;
    800042b2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800042b6:	21c48513          	addi	a0,s1,540
    800042ba:	b9dfd0ef          	jal	ra,80001e56 <wakeup>
    800042be:	bfd9                	j	80004294 <pipeclose+0x24>
    release(&pi->lock);
    800042c0:	8526                	mv	a0,s1
    800042c2:	941fc0ef          	jal	ra,80000c02 <release>
}
    800042c6:	b7c5                	j	800042a6 <pipeclose+0x36>

00000000800042c8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800042c8:	711d                	addi	sp,sp,-96
    800042ca:	ec86                	sd	ra,88(sp)
    800042cc:	e8a2                	sd	s0,80(sp)
    800042ce:	e4a6                	sd	s1,72(sp)
    800042d0:	e0ca                	sd	s2,64(sp)
    800042d2:	fc4e                	sd	s3,56(sp)
    800042d4:	f852                	sd	s4,48(sp)
    800042d6:	f456                	sd	s5,40(sp)
    800042d8:	f05a                	sd	s6,32(sp)
    800042da:	ec5e                	sd	s7,24(sp)
    800042dc:	e862                	sd	s8,16(sp)
    800042de:	1080                	addi	s0,sp,96
    800042e0:	84aa                	mv	s1,a0
    800042e2:	8aae                	mv	s5,a1
    800042e4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800042e6:	d1cfd0ef          	jal	ra,80001802 <myproc>
    800042ea:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800042ec:	8526                	mv	a0,s1
    800042ee:	87dfc0ef          	jal	ra,80000b6a <acquire>
  while(i < n){
    800042f2:	09405c63          	blez	s4,8000438a <pipewrite+0xc2>
  int i = 0;
    800042f6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800042f8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800042fa:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800042fe:	21c48b93          	addi	s7,s1,540
    80004302:	a81d                	j	80004338 <pipewrite+0x70>
      release(&pi->lock);
    80004304:	8526                	mv	a0,s1
    80004306:	8fdfc0ef          	jal	ra,80000c02 <release>
      return -1;
    8000430a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000430c:	854a                	mv	a0,s2
    8000430e:	60e6                	ld	ra,88(sp)
    80004310:	6446                	ld	s0,80(sp)
    80004312:	64a6                	ld	s1,72(sp)
    80004314:	6906                	ld	s2,64(sp)
    80004316:	79e2                	ld	s3,56(sp)
    80004318:	7a42                	ld	s4,48(sp)
    8000431a:	7aa2                	ld	s5,40(sp)
    8000431c:	7b02                	ld	s6,32(sp)
    8000431e:	6be2                	ld	s7,24(sp)
    80004320:	6c42                	ld	s8,16(sp)
    80004322:	6125                	addi	sp,sp,96
    80004324:	8082                	ret
      wakeup(&pi->nread);
    80004326:	8562                	mv	a0,s8
    80004328:	b2ffd0ef          	jal	ra,80001e56 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000432c:	85a6                	mv	a1,s1
    8000432e:	855e                	mv	a0,s7
    80004330:	adbfd0ef          	jal	ra,80001e0a <sleep>
  while(i < n){
    80004334:	05495c63          	bge	s2,s4,8000438c <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004338:	2204a783          	lw	a5,544(s1)
    8000433c:	d7e1                	beqz	a5,80004304 <pipewrite+0x3c>
    8000433e:	854e                	mv	a0,s3
    80004340:	d03fd0ef          	jal	ra,80002042 <killed>
    80004344:	f161                	bnez	a0,80004304 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004346:	2184a783          	lw	a5,536(s1)
    8000434a:	21c4a703          	lw	a4,540(s1)
    8000434e:	2007879b          	addiw	a5,a5,512
    80004352:	fcf70ae3          	beq	a4,a5,80004326 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004356:	4685                	li	a3,1
    80004358:	01590633          	add	a2,s2,s5
    8000435c:	faf40593          	addi	a1,s0,-81
    80004360:	0509b503          	ld	a0,80(s3)
    80004364:	ab2fd0ef          	jal	ra,80001616 <copyin>
    80004368:	03650263          	beq	a0,s6,8000438c <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000436c:	21c4a783          	lw	a5,540(s1)
    80004370:	0017871b          	addiw	a4,a5,1
    80004374:	20e4ae23          	sw	a4,540(s1)
    80004378:	1ff7f793          	andi	a5,a5,511
    8000437c:	97a6                	add	a5,a5,s1
    8000437e:	faf44703          	lbu	a4,-81(s0)
    80004382:	00e78c23          	sb	a4,24(a5)
      i++;
    80004386:	2905                	addiw	s2,s2,1
    80004388:	b775                	j	80004334 <pipewrite+0x6c>
  int i = 0;
    8000438a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000438c:	21848513          	addi	a0,s1,536
    80004390:	ac7fd0ef          	jal	ra,80001e56 <wakeup>
  release(&pi->lock);
    80004394:	8526                	mv	a0,s1
    80004396:	86dfc0ef          	jal	ra,80000c02 <release>
  return i;
    8000439a:	bf8d                	j	8000430c <pipewrite+0x44>

000000008000439c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000439c:	715d                	addi	sp,sp,-80
    8000439e:	e486                	sd	ra,72(sp)
    800043a0:	e0a2                	sd	s0,64(sp)
    800043a2:	fc26                	sd	s1,56(sp)
    800043a4:	f84a                	sd	s2,48(sp)
    800043a6:	f44e                	sd	s3,40(sp)
    800043a8:	f052                	sd	s4,32(sp)
    800043aa:	ec56                	sd	s5,24(sp)
    800043ac:	e85a                	sd	s6,16(sp)
    800043ae:	0880                	addi	s0,sp,80
    800043b0:	84aa                	mv	s1,a0
    800043b2:	892e                	mv	s2,a1
    800043b4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800043b6:	c4cfd0ef          	jal	ra,80001802 <myproc>
    800043ba:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800043bc:	8526                	mv	a0,s1
    800043be:	facfc0ef          	jal	ra,80000b6a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043c2:	2184a703          	lw	a4,536(s1)
    800043c6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043ca:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043ce:	02f71363          	bne	a4,a5,800043f4 <piperead+0x58>
    800043d2:	2244a783          	lw	a5,548(s1)
    800043d6:	cf99                	beqz	a5,800043f4 <piperead+0x58>
    if(killed(pr)){
    800043d8:	8552                	mv	a0,s4
    800043da:	c69fd0ef          	jal	ra,80002042 <killed>
    800043de:	e151                	bnez	a0,80004462 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043e0:	85a6                	mv	a1,s1
    800043e2:	854e                	mv	a0,s3
    800043e4:	a27fd0ef          	jal	ra,80001e0a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043e8:	2184a703          	lw	a4,536(s1)
    800043ec:	21c4a783          	lw	a5,540(s1)
    800043f0:	fef701e3          	beq	a4,a5,800043d2 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043f4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800043f6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043f8:	05505363          	blez	s5,8000443e <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    800043fc:	2184a783          	lw	a5,536(s1)
    80004400:	21c4a703          	lw	a4,540(s1)
    80004404:	02f70d63          	beq	a4,a5,8000443e <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004408:	1ff7f793          	andi	a5,a5,511
    8000440c:	97a6                	add	a5,a5,s1
    8000440e:	0187c783          	lbu	a5,24(a5)
    80004412:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004416:	4685                	li	a3,1
    80004418:	fbf40613          	addi	a2,s0,-65
    8000441c:	85ca                	mv	a1,s2
    8000441e:	050a3503          	ld	a0,80(s4)
    80004422:	92efd0ef          	jal	ra,80001550 <copyout>
    80004426:	05650363          	beq	a0,s6,8000446c <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000442a:	2184a783          	lw	a5,536(s1)
    8000442e:	2785                	addiw	a5,a5,1
    80004430:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004434:	2985                	addiw	s3,s3,1
    80004436:	0905                	addi	s2,s2,1
    80004438:	fd3a92e3          	bne	s5,s3,800043fc <piperead+0x60>
    8000443c:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000443e:	21c48513          	addi	a0,s1,540
    80004442:	a15fd0ef          	jal	ra,80001e56 <wakeup>
  release(&pi->lock);
    80004446:	8526                	mv	a0,s1
    80004448:	fbafc0ef          	jal	ra,80000c02 <release>
  return i;
}
    8000444c:	854e                	mv	a0,s3
    8000444e:	60a6                	ld	ra,72(sp)
    80004450:	6406                	ld	s0,64(sp)
    80004452:	74e2                	ld	s1,56(sp)
    80004454:	7942                	ld	s2,48(sp)
    80004456:	79a2                	ld	s3,40(sp)
    80004458:	7a02                	ld	s4,32(sp)
    8000445a:	6ae2                	ld	s5,24(sp)
    8000445c:	6b42                	ld	s6,16(sp)
    8000445e:	6161                	addi	sp,sp,80
    80004460:	8082                	ret
      release(&pi->lock);
    80004462:	8526                	mv	a0,s1
    80004464:	f9efc0ef          	jal	ra,80000c02 <release>
      return -1;
    80004468:	59fd                	li	s3,-1
    8000446a:	b7cd                	j	8000444c <piperead+0xb0>
      if(i == 0)
    8000446c:	fc0999e3          	bnez	s3,8000443e <piperead+0xa2>
        i = -1;
    80004470:	89aa                	mv	s3,a0
    80004472:	b7f1                	j	8000443e <piperead+0xa2>

0000000080004474 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004474:	1141                	addi	sp,sp,-16
    80004476:	e422                	sd	s0,8(sp)
    80004478:	0800                	addi	s0,sp,16
    8000447a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000447c:	8905                	andi	a0,a0,1
    8000447e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004480:	8b89                	andi	a5,a5,2
    80004482:	c399                	beqz	a5,80004488 <flags2perm+0x14>
      perm |= PTE_W;
    80004484:	00456513          	ori	a0,a0,4
    return perm;
}
    80004488:	6422                	ld	s0,8(sp)
    8000448a:	0141                	addi	sp,sp,16
    8000448c:	8082                	ret

000000008000448e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000448e:	de010113          	addi	sp,sp,-544
    80004492:	20113c23          	sd	ra,536(sp)
    80004496:	20813823          	sd	s0,528(sp)
    8000449a:	20913423          	sd	s1,520(sp)
    8000449e:	21213023          	sd	s2,512(sp)
    800044a2:	ffce                	sd	s3,504(sp)
    800044a4:	fbd2                	sd	s4,496(sp)
    800044a6:	f7d6                	sd	s5,488(sp)
    800044a8:	f3da                	sd	s6,480(sp)
    800044aa:	efde                	sd	s7,472(sp)
    800044ac:	ebe2                	sd	s8,464(sp)
    800044ae:	e7e6                	sd	s9,456(sp)
    800044b0:	e3ea                	sd	s10,448(sp)
    800044b2:	ff6e                	sd	s11,440(sp)
    800044b4:	1400                	addi	s0,sp,544
    800044b6:	892a                	mv	s2,a0
    800044b8:	dea43423          	sd	a0,-536(s0)
    800044bc:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800044c0:	b42fd0ef          	jal	ra,80001802 <myproc>
    800044c4:	84aa                	mv	s1,a0

  begin_op();
    800044c6:	e12ff0ef          	jal	ra,80003ad8 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800044ca:	854a                	mv	a0,s2
    800044cc:	c18ff0ef          	jal	ra,800038e4 <namei>
    800044d0:	c13d                	beqz	a0,80004536 <kexec+0xa8>
    800044d2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800044d4:	c1dfe0ef          	jal	ra,800030f0 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800044d8:	04000713          	li	a4,64
    800044dc:	4681                	li	a3,0
    800044de:	e5040613          	addi	a2,s0,-432
    800044e2:	4581                	li	a1,0
    800044e4:	8556                	mv	a0,s5
    800044e6:	f97fe0ef          	jal	ra,8000347c <readi>
    800044ea:	04000793          	li	a5,64
    800044ee:	00f51a63          	bne	a0,a5,80004502 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800044f2:	e5042703          	lw	a4,-432(s0)
    800044f6:	464c47b7          	lui	a5,0x464c4
    800044fa:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800044fe:	04f70063          	beq	a4,a5,8000453e <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004502:	8556                	mv	a0,s5
    80004504:	df3fe0ef          	jal	ra,800032f6 <iunlockput>
    end_op();
    80004508:	e3eff0ef          	jal	ra,80003b46 <end_op>
  }
  return -1;
    8000450c:	557d                	li	a0,-1
}
    8000450e:	21813083          	ld	ra,536(sp)
    80004512:	21013403          	ld	s0,528(sp)
    80004516:	20813483          	ld	s1,520(sp)
    8000451a:	20013903          	ld	s2,512(sp)
    8000451e:	79fe                	ld	s3,504(sp)
    80004520:	7a5e                	ld	s4,496(sp)
    80004522:	7abe                	ld	s5,488(sp)
    80004524:	7b1e                	ld	s6,480(sp)
    80004526:	6bfe                	ld	s7,472(sp)
    80004528:	6c5e                	ld	s8,464(sp)
    8000452a:	6cbe                	ld	s9,456(sp)
    8000452c:	6d1e                	ld	s10,448(sp)
    8000452e:	7dfa                	ld	s11,440(sp)
    80004530:	22010113          	addi	sp,sp,544
    80004534:	8082                	ret
    end_op();
    80004536:	e10ff0ef          	jal	ra,80003b46 <end_op>
    return -1;
    8000453a:	557d                	li	a0,-1
    8000453c:	bfc9                	j	8000450e <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    8000453e:	8526                	mv	a0,s1
    80004540:	bc8fd0ef          	jal	ra,80001908 <proc_pagetable>
    80004544:	8b2a                	mv	s6,a0
    80004546:	dd55                	beqz	a0,80004502 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004548:	e7042783          	lw	a5,-400(s0)
    8000454c:	e8845703          	lhu	a4,-376(s0)
    80004550:	c325                	beqz	a4,800045b0 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004552:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004554:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004558:	6a05                	lui	s4,0x1
    8000455a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000455e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004562:	6d85                	lui	s11,0x1
    80004564:	7d7d                	lui	s10,0xfffff
    80004566:	a409                	j	80004768 <kexec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004568:	00003517          	auipc	a0,0x3
    8000456c:	14850513          	addi	a0,a0,328 # 800076b0 <syscalls+0x2c0>
    80004570:	a18fc0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004574:	874a                	mv	a4,s2
    80004576:	009c86bb          	addw	a3,s9,s1
    8000457a:	4581                	li	a1,0
    8000457c:	8556                	mv	a0,s5
    8000457e:	efffe0ef          	jal	ra,8000347c <readi>
    80004582:	2501                	sext.w	a0,a0
    80004584:	18a91163          	bne	s2,a0,80004706 <kexec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80004588:	009d84bb          	addw	s1,s11,s1
    8000458c:	013d09bb          	addw	s3,s10,s3
    80004590:	1b74fc63          	bgeu	s1,s7,80004748 <kexec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80004594:	02049593          	slli	a1,s1,0x20
    80004598:	9181                	srli	a1,a1,0x20
    8000459a:	95e2                	add	a1,a1,s8
    8000459c:	855a                	mv	a0,s6
    8000459e:	9b7fc0ef          	jal	ra,80000f54 <walkaddr>
    800045a2:	862a                	mv	a2,a0
    if(pa == 0)
    800045a4:	d171                	beqz	a0,80004568 <kexec+0xda>
      n = PGSIZE;
    800045a6:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800045a8:	fd49f6e3          	bgeu	s3,s4,80004574 <kexec+0xe6>
      n = sz - i;
    800045ac:	894e                	mv	s2,s3
    800045ae:	b7d9                	j	80004574 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045b0:	4901                	li	s2,0
  iunlockput(ip);
    800045b2:	8556                	mv	a0,s5
    800045b4:	d43fe0ef          	jal	ra,800032f6 <iunlockput>
  end_op();
    800045b8:	d8eff0ef          	jal	ra,80003b46 <end_op>
  p = myproc();
    800045bc:	a46fd0ef          	jal	ra,80001802 <myproc>
    800045c0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800045c2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800045c6:	6785                	lui	a5,0x1
    800045c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800045ca:	97ca                	add	a5,a5,s2
    800045cc:	777d                	lui	a4,0xfffff
    800045ce:	8ff9                	and	a5,a5,a4
    800045d0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800045d4:	4691                	li	a3,4
    800045d6:	6609                	lui	a2,0x2
    800045d8:	963e                	add	a2,a2,a5
    800045da:	85be                	mv	a1,a5
    800045dc:	855a                	mv	a0,s6
    800045de:	c41fc0ef          	jal	ra,8000121e <uvmalloc>
    800045e2:	8c2a                	mv	s8,a0
  ip = 0;
    800045e4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800045e6:	12050063          	beqz	a0,80004706 <kexec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800045ea:	75f9                	lui	a1,0xffffe
    800045ec:	95aa                	add	a1,a1,a0
    800045ee:	855a                	mv	a0,s6
    800045f0:	df9fc0ef          	jal	ra,800013e8 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800045f4:	7afd                	lui	s5,0xfffff
    800045f6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800045f8:	df043783          	ld	a5,-528(s0)
    800045fc:	6388                	ld	a0,0(a5)
    800045fe:	c135                	beqz	a0,80004662 <kexec+0x1d4>
    80004600:	e9040993          	addi	s3,s0,-368
    80004604:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004608:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000460a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000460c:	faafc0ef          	jal	ra,80000db6 <strlen>
    80004610:	0015079b          	addiw	a5,a0,1
    80004614:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004618:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000461c:	11596a63          	bltu	s2,s5,80004730 <kexec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004620:	df043d83          	ld	s11,-528(s0)
    80004624:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004628:	8552                	mv	a0,s4
    8000462a:	f8cfc0ef          	jal	ra,80000db6 <strlen>
    8000462e:	0015069b          	addiw	a3,a0,1
    80004632:	8652                	mv	a2,s4
    80004634:	85ca                	mv	a1,s2
    80004636:	855a                	mv	a0,s6
    80004638:	f19fc0ef          	jal	ra,80001550 <copyout>
    8000463c:	0e054e63          	bltz	a0,80004738 <kexec+0x2aa>
    ustack[argc] = sp;
    80004640:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004644:	0485                	addi	s1,s1,1
    80004646:	008d8793          	addi	a5,s11,8
    8000464a:	def43823          	sd	a5,-528(s0)
    8000464e:	008db503          	ld	a0,8(s11)
    80004652:	c911                	beqz	a0,80004666 <kexec+0x1d8>
    if(argc >= MAXARG)
    80004654:	09a1                	addi	s3,s3,8
    80004656:	fb3c9be3          	bne	s9,s3,8000460c <kexec+0x17e>
  sz = sz1;
    8000465a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000465e:	4a81                	li	s5,0
    80004660:	a05d                	j	80004706 <kexec+0x278>
  sp = sz;
    80004662:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004664:	4481                	li	s1,0
  ustack[argc] = 0;
    80004666:	00349793          	slli	a5,s1,0x3
    8000466a:	f9078793          	addi	a5,a5,-112
    8000466e:	97a2                	add	a5,a5,s0
    80004670:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004674:	00148693          	addi	a3,s1,1
    80004678:	068e                	slli	a3,a3,0x3
    8000467a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000467e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004682:	01597663          	bgeu	s2,s5,8000468e <kexec+0x200>
  sz = sz1;
    80004686:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000468a:	4a81                	li	s5,0
    8000468c:	a8ad                	j	80004706 <kexec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000468e:	e9040613          	addi	a2,s0,-368
    80004692:	85ca                	mv	a1,s2
    80004694:	855a                	mv	a0,s6
    80004696:	ebbfc0ef          	jal	ra,80001550 <copyout>
    8000469a:	0a054363          	bltz	a0,80004740 <kexec+0x2b2>
  p->trapframe->a1 = sp;
    8000469e:	058bb783          	ld	a5,88(s7)
    800046a2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800046a6:	de843783          	ld	a5,-536(s0)
    800046aa:	0007c703          	lbu	a4,0(a5)
    800046ae:	cf11                	beqz	a4,800046ca <kexec+0x23c>
    800046b0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800046b2:	02f00693          	li	a3,47
    800046b6:	a039                	j	800046c4 <kexec+0x236>
      last = s+1;
    800046b8:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800046bc:	0785                	addi	a5,a5,1
    800046be:	fff7c703          	lbu	a4,-1(a5)
    800046c2:	c701                	beqz	a4,800046ca <kexec+0x23c>
    if(*s == '/')
    800046c4:	fed71ce3          	bne	a4,a3,800046bc <kexec+0x22e>
    800046c8:	bfc5                	j	800046b8 <kexec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    800046ca:	4641                	li	a2,16
    800046cc:	de843583          	ld	a1,-536(s0)
    800046d0:	158b8513          	addi	a0,s7,344
    800046d4:	eb0fc0ef          	jal	ra,80000d84 <safestrcpy>
  oldpagetable = p->pagetable;
    800046d8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800046dc:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800046e0:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800046e4:	058bb783          	ld	a5,88(s7)
    800046e8:	e6843703          	ld	a4,-408(s0)
    800046ec:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800046ee:	058bb783          	ld	a5,88(s7)
    800046f2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800046f6:	85ea                	mv	a1,s10
    800046f8:	a94fd0ef          	jal	ra,8000198c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800046fc:	0004851b          	sext.w	a0,s1
    80004700:	b539                	j	8000450e <kexec+0x80>
    80004702:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004706:	df843583          	ld	a1,-520(s0)
    8000470a:	855a                	mv	a0,s6
    8000470c:	a80fd0ef          	jal	ra,8000198c <proc_freepagetable>
  if(ip){
    80004710:	de0a99e3          	bnez	s5,80004502 <kexec+0x74>
  return -1;
    80004714:	557d                	li	a0,-1
    80004716:	bbe5                	j	8000450e <kexec+0x80>
    80004718:	df243c23          	sd	s2,-520(s0)
    8000471c:	b7ed                	j	80004706 <kexec+0x278>
    8000471e:	df243c23          	sd	s2,-520(s0)
    80004722:	b7d5                	j	80004706 <kexec+0x278>
    80004724:	df243c23          	sd	s2,-520(s0)
    80004728:	bff9                	j	80004706 <kexec+0x278>
    8000472a:	df243c23          	sd	s2,-520(s0)
    8000472e:	bfe1                	j	80004706 <kexec+0x278>
  sz = sz1;
    80004730:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004734:	4a81                	li	s5,0
    80004736:	bfc1                	j	80004706 <kexec+0x278>
  sz = sz1;
    80004738:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000473c:	4a81                	li	s5,0
    8000473e:	b7e1                	j	80004706 <kexec+0x278>
  sz = sz1;
    80004740:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004744:	4a81                	li	s5,0
    80004746:	b7c1                	j	80004706 <kexec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004748:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000474c:	e0843783          	ld	a5,-504(s0)
    80004750:	0017869b          	addiw	a3,a5,1
    80004754:	e0d43423          	sd	a3,-504(s0)
    80004758:	e0043783          	ld	a5,-512(s0)
    8000475c:	0387879b          	addiw	a5,a5,56
    80004760:	e8845703          	lhu	a4,-376(s0)
    80004764:	e4e6d7e3          	bge	a3,a4,800045b2 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004768:	2781                	sext.w	a5,a5
    8000476a:	e0f43023          	sd	a5,-512(s0)
    8000476e:	03800713          	li	a4,56
    80004772:	86be                	mv	a3,a5
    80004774:	e1840613          	addi	a2,s0,-488
    80004778:	4581                	li	a1,0
    8000477a:	8556                	mv	a0,s5
    8000477c:	d01fe0ef          	jal	ra,8000347c <readi>
    80004780:	03800793          	li	a5,56
    80004784:	f6f51fe3          	bne	a0,a5,80004702 <kexec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80004788:	e1842783          	lw	a5,-488(s0)
    8000478c:	4705                	li	a4,1
    8000478e:	fae79fe3          	bne	a5,a4,8000474c <kexec+0x2be>
    if(ph.memsz < ph.filesz)
    80004792:	e4043483          	ld	s1,-448(s0)
    80004796:	e3843783          	ld	a5,-456(s0)
    8000479a:	f6f4efe3          	bltu	s1,a5,80004718 <kexec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000479e:	e2843783          	ld	a5,-472(s0)
    800047a2:	94be                	add	s1,s1,a5
    800047a4:	f6f4ede3          	bltu	s1,a5,8000471e <kexec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    800047a8:	de043703          	ld	a4,-544(s0)
    800047ac:	8ff9                	and	a5,a5,a4
    800047ae:	fbbd                	bnez	a5,80004724 <kexec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800047b0:	e1c42503          	lw	a0,-484(s0)
    800047b4:	cc1ff0ef          	jal	ra,80004474 <flags2perm>
    800047b8:	86aa                	mv	a3,a0
    800047ba:	8626                	mv	a2,s1
    800047bc:	85ca                	mv	a1,s2
    800047be:	855a                	mv	a0,s6
    800047c0:	a5ffc0ef          	jal	ra,8000121e <uvmalloc>
    800047c4:	dea43c23          	sd	a0,-520(s0)
    800047c8:	d12d                	beqz	a0,8000472a <kexec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047ca:	e2843c03          	ld	s8,-472(s0)
    800047ce:	e2042c83          	lw	s9,-480(s0)
    800047d2:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047d6:	f60b89e3          	beqz	s7,80004748 <kexec+0x2ba>
    800047da:	89de                	mv	s3,s7
    800047dc:	4481                	li	s1,0
    800047de:	bb5d                	j	80004594 <kexec+0x106>

00000000800047e0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800047e0:	7179                	addi	sp,sp,-48
    800047e2:	f406                	sd	ra,40(sp)
    800047e4:	f022                	sd	s0,32(sp)
    800047e6:	ec26                	sd	s1,24(sp)
    800047e8:	e84a                	sd	s2,16(sp)
    800047ea:	1800                	addi	s0,sp,48
    800047ec:	892e                	mv	s2,a1
    800047ee:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800047f0:	fdc40593          	addi	a1,s0,-36
    800047f4:	f17fd0ef          	jal	ra,8000270a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800047f8:	fdc42703          	lw	a4,-36(s0)
    800047fc:	47bd                	li	a5,15
    800047fe:	02e7e963          	bltu	a5,a4,80004830 <argfd+0x50>
    80004802:	800fd0ef          	jal	ra,80001802 <myproc>
    80004806:	fdc42703          	lw	a4,-36(s0)
    8000480a:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde492>
    8000480e:	078e                	slli	a5,a5,0x3
    80004810:	953e                	add	a0,a0,a5
    80004812:	611c                	ld	a5,0(a0)
    80004814:	c385                	beqz	a5,80004834 <argfd+0x54>
    return -1;
  if(pfd)
    80004816:	00090463          	beqz	s2,8000481e <argfd+0x3e>
    *pfd = fd;
    8000481a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000481e:	4501                	li	a0,0
  if(pf)
    80004820:	c091                	beqz	s1,80004824 <argfd+0x44>
    *pf = f;
    80004822:	e09c                	sd	a5,0(s1)
}
    80004824:	70a2                	ld	ra,40(sp)
    80004826:	7402                	ld	s0,32(sp)
    80004828:	64e2                	ld	s1,24(sp)
    8000482a:	6942                	ld	s2,16(sp)
    8000482c:	6145                	addi	sp,sp,48
    8000482e:	8082                	ret
    return -1;
    80004830:	557d                	li	a0,-1
    80004832:	bfcd                	j	80004824 <argfd+0x44>
    80004834:	557d                	li	a0,-1
    80004836:	b7fd                	j	80004824 <argfd+0x44>

0000000080004838 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004838:	1101                	addi	sp,sp,-32
    8000483a:	ec06                	sd	ra,24(sp)
    8000483c:	e822                	sd	s0,16(sp)
    8000483e:	e426                	sd	s1,8(sp)
    80004840:	1000                	addi	s0,sp,32
    80004842:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004844:	fbffc0ef          	jal	ra,80001802 <myproc>
    80004848:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000484a:	0d050793          	addi	a5,a0,208
    8000484e:	4501                	li	a0,0
    80004850:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004852:	6398                	ld	a4,0(a5)
    80004854:	cb19                	beqz	a4,8000486a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004856:	2505                	addiw	a0,a0,1
    80004858:	07a1                	addi	a5,a5,8
    8000485a:	fed51ce3          	bne	a0,a3,80004852 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000485e:	557d                	li	a0,-1
}
    80004860:	60e2                	ld	ra,24(sp)
    80004862:	6442                	ld	s0,16(sp)
    80004864:	64a2                	ld	s1,8(sp)
    80004866:	6105                	addi	sp,sp,32
    80004868:	8082                	ret
      p->ofile[fd] = f;
    8000486a:	01a50793          	addi	a5,a0,26
    8000486e:	078e                	slli	a5,a5,0x3
    80004870:	963e                	add	a2,a2,a5
    80004872:	e204                	sd	s1,0(a2)
      return fd;
    80004874:	b7f5                	j	80004860 <fdalloc+0x28>

0000000080004876 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004876:	715d                	addi	sp,sp,-80
    80004878:	e486                	sd	ra,72(sp)
    8000487a:	e0a2                	sd	s0,64(sp)
    8000487c:	fc26                	sd	s1,56(sp)
    8000487e:	f84a                	sd	s2,48(sp)
    80004880:	f44e                	sd	s3,40(sp)
    80004882:	f052                	sd	s4,32(sp)
    80004884:	ec56                	sd	s5,24(sp)
    80004886:	e85a                	sd	s6,16(sp)
    80004888:	0880                	addi	s0,sp,80
    8000488a:	8b2e                	mv	s6,a1
    8000488c:	89b2                	mv	s3,a2
    8000488e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004890:	fb040593          	addi	a1,s0,-80
    80004894:	86aff0ef          	jal	ra,800038fe <nameiparent>
    80004898:	84aa                	mv	s1,a0
    8000489a:	10050b63          	beqz	a0,800049b0 <create+0x13a>
    return 0;

  ilock(dp);
    8000489e:	853fe0ef          	jal	ra,800030f0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800048a2:	4601                	li	a2,0
    800048a4:	fb040593          	addi	a1,s0,-80
    800048a8:	8526                	mv	a0,s1
    800048aa:	dcffe0ef          	jal	ra,80003678 <dirlookup>
    800048ae:	8aaa                	mv	s5,a0
    800048b0:	c521                	beqz	a0,800048f8 <create+0x82>
    iunlockput(dp);
    800048b2:	8526                	mv	a0,s1
    800048b4:	a43fe0ef          	jal	ra,800032f6 <iunlockput>
    ilock(ip);
    800048b8:	8556                	mv	a0,s5
    800048ba:	837fe0ef          	jal	ra,800030f0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800048be:	000b059b          	sext.w	a1,s6
    800048c2:	4789                	li	a5,2
    800048c4:	02f59563          	bne	a1,a5,800048ee <create+0x78>
    800048c8:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde4bc>
    800048cc:	37f9                	addiw	a5,a5,-2
    800048ce:	17c2                	slli	a5,a5,0x30
    800048d0:	93c1                	srli	a5,a5,0x30
    800048d2:	4705                	li	a4,1
    800048d4:	00f76d63          	bltu	a4,a5,800048ee <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800048d8:	8556                	mv	a0,s5
    800048da:	60a6                	ld	ra,72(sp)
    800048dc:	6406                	ld	s0,64(sp)
    800048de:	74e2                	ld	s1,56(sp)
    800048e0:	7942                	ld	s2,48(sp)
    800048e2:	79a2                	ld	s3,40(sp)
    800048e4:	7a02                	ld	s4,32(sp)
    800048e6:	6ae2                	ld	s5,24(sp)
    800048e8:	6b42                	ld	s6,16(sp)
    800048ea:	6161                	addi	sp,sp,80
    800048ec:	8082                	ret
    iunlockput(ip);
    800048ee:	8556                	mv	a0,s5
    800048f0:	a07fe0ef          	jal	ra,800032f6 <iunlockput>
    return 0;
    800048f4:	4a81                	li	s5,0
    800048f6:	b7cd                	j	800048d8 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    800048f8:	85da                	mv	a1,s6
    800048fa:	4088                	lw	a0,0(s1)
    800048fc:	e8afe0ef          	jal	ra,80002f86 <ialloc>
    80004900:	8a2a                	mv	s4,a0
    80004902:	cd1d                	beqz	a0,80004940 <create+0xca>
  ilock(ip);
    80004904:	fecfe0ef          	jal	ra,800030f0 <ilock>
  ip->major = major;
    80004908:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000490c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004910:	4905                	li	s2,1
    80004912:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004916:	8552                	mv	a0,s4
    80004918:	f24fe0ef          	jal	ra,8000303c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000491c:	000b059b          	sext.w	a1,s6
    80004920:	03258563          	beq	a1,s2,8000494a <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004924:	004a2603          	lw	a2,4(s4)
    80004928:	fb040593          	addi	a1,s0,-80
    8000492c:	8526                	mv	a0,s1
    8000492e:	f1dfe0ef          	jal	ra,8000384a <dirlink>
    80004932:	06054363          	bltz	a0,80004998 <create+0x122>
  iunlockput(dp);
    80004936:	8526                	mv	a0,s1
    80004938:	9bffe0ef          	jal	ra,800032f6 <iunlockput>
  return ip;
    8000493c:	8ad2                	mv	s5,s4
    8000493e:	bf69                	j	800048d8 <create+0x62>
    iunlockput(dp);
    80004940:	8526                	mv	a0,s1
    80004942:	9b5fe0ef          	jal	ra,800032f6 <iunlockput>
    return 0;
    80004946:	8ad2                	mv	s5,s4
    80004948:	bf41                	j	800048d8 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000494a:	004a2603          	lw	a2,4(s4)
    8000494e:	00003597          	auipc	a1,0x3
    80004952:	d8258593          	addi	a1,a1,-638 # 800076d0 <syscalls+0x2e0>
    80004956:	8552                	mv	a0,s4
    80004958:	ef3fe0ef          	jal	ra,8000384a <dirlink>
    8000495c:	02054e63          	bltz	a0,80004998 <create+0x122>
    80004960:	40d0                	lw	a2,4(s1)
    80004962:	00003597          	auipc	a1,0x3
    80004966:	d7658593          	addi	a1,a1,-650 # 800076d8 <syscalls+0x2e8>
    8000496a:	8552                	mv	a0,s4
    8000496c:	edffe0ef          	jal	ra,8000384a <dirlink>
    80004970:	02054463          	bltz	a0,80004998 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004974:	004a2603          	lw	a2,4(s4)
    80004978:	fb040593          	addi	a1,s0,-80
    8000497c:	8526                	mv	a0,s1
    8000497e:	ecdfe0ef          	jal	ra,8000384a <dirlink>
    80004982:	00054b63          	bltz	a0,80004998 <create+0x122>
    dp->nlink++;  // for ".."
    80004986:	04a4d783          	lhu	a5,74(s1)
    8000498a:	2785                	addiw	a5,a5,1
    8000498c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004990:	8526                	mv	a0,s1
    80004992:	eaafe0ef          	jal	ra,8000303c <iupdate>
    80004996:	b745                	j	80004936 <create+0xc0>
  ip->nlink = 0;
    80004998:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000499c:	8552                	mv	a0,s4
    8000499e:	e9efe0ef          	jal	ra,8000303c <iupdate>
  iunlockput(ip);
    800049a2:	8552                	mv	a0,s4
    800049a4:	953fe0ef          	jal	ra,800032f6 <iunlockput>
  iunlockput(dp);
    800049a8:	8526                	mv	a0,s1
    800049aa:	94dfe0ef          	jal	ra,800032f6 <iunlockput>
  return 0;
    800049ae:	b72d                	j	800048d8 <create+0x62>
    return 0;
    800049b0:	8aaa                	mv	s5,a0
    800049b2:	b71d                	j	800048d8 <create+0x62>

00000000800049b4 <sys_dup>:
{
    800049b4:	7179                	addi	sp,sp,-48
    800049b6:	f406                	sd	ra,40(sp)
    800049b8:	f022                	sd	s0,32(sp)
    800049ba:	ec26                	sd	s1,24(sp)
    800049bc:	e84a                	sd	s2,16(sp)
    800049be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800049c0:	fd840613          	addi	a2,s0,-40
    800049c4:	4581                	li	a1,0
    800049c6:	4501                	li	a0,0
    800049c8:	e19ff0ef          	jal	ra,800047e0 <argfd>
    return -1;
    800049cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800049ce:	00054f63          	bltz	a0,800049ec <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    800049d2:	fd843903          	ld	s2,-40(s0)
    800049d6:	854a                	mv	a0,s2
    800049d8:	e61ff0ef          	jal	ra,80004838 <fdalloc>
    800049dc:	84aa                	mv	s1,a0
    return -1;
    800049de:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800049e0:	00054663          	bltz	a0,800049ec <sys_dup+0x38>
  filedup(f);
    800049e4:	854a                	mv	a0,s2
    800049e6:	cb6ff0ef          	jal	ra,80003e9c <filedup>
  return fd;
    800049ea:	87a6                	mv	a5,s1
}
    800049ec:	853e                	mv	a0,a5
    800049ee:	70a2                	ld	ra,40(sp)
    800049f0:	7402                	ld	s0,32(sp)
    800049f2:	64e2                	ld	s1,24(sp)
    800049f4:	6942                	ld	s2,16(sp)
    800049f6:	6145                	addi	sp,sp,48
    800049f8:	8082                	ret

00000000800049fa <sys_read>:
{
    800049fa:	7179                	addi	sp,sp,-48
    800049fc:	f406                	sd	ra,40(sp)
    800049fe:	f022                	sd	s0,32(sp)
    80004a00:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a02:	fd840593          	addi	a1,s0,-40
    80004a06:	4505                	li	a0,1
    80004a08:	d1ffd0ef          	jal	ra,80002726 <argaddr>
  argint(2, &n);
    80004a0c:	fe440593          	addi	a1,s0,-28
    80004a10:	4509                	li	a0,2
    80004a12:	cf9fd0ef          	jal	ra,8000270a <argint>
  if(argfd(0, 0, &f) < 0)
    80004a16:	fe840613          	addi	a2,s0,-24
    80004a1a:	4581                	li	a1,0
    80004a1c:	4501                	li	a0,0
    80004a1e:	dc3ff0ef          	jal	ra,800047e0 <argfd>
    80004a22:	87aa                	mv	a5,a0
    return -1;
    80004a24:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a26:	0007ca63          	bltz	a5,80004a3a <sys_read+0x40>
  return fileread(f, p, n);
    80004a2a:	fe442603          	lw	a2,-28(s0)
    80004a2e:	fd843583          	ld	a1,-40(s0)
    80004a32:	fe843503          	ld	a0,-24(s0)
    80004a36:	db2ff0ef          	jal	ra,80003fe8 <fileread>
}
    80004a3a:	70a2                	ld	ra,40(sp)
    80004a3c:	7402                	ld	s0,32(sp)
    80004a3e:	6145                	addi	sp,sp,48
    80004a40:	8082                	ret

0000000080004a42 <sys_write>:
{
    80004a42:	7179                	addi	sp,sp,-48
    80004a44:	f406                	sd	ra,40(sp)
    80004a46:	f022                	sd	s0,32(sp)
    80004a48:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a4a:	fd840593          	addi	a1,s0,-40
    80004a4e:	4505                	li	a0,1
    80004a50:	cd7fd0ef          	jal	ra,80002726 <argaddr>
  argint(2, &n);
    80004a54:	fe440593          	addi	a1,s0,-28
    80004a58:	4509                	li	a0,2
    80004a5a:	cb1fd0ef          	jal	ra,8000270a <argint>
  if(argfd(0, 0, &f) < 0)
    80004a5e:	fe840613          	addi	a2,s0,-24
    80004a62:	4581                	li	a1,0
    80004a64:	4501                	li	a0,0
    80004a66:	d7bff0ef          	jal	ra,800047e0 <argfd>
    80004a6a:	87aa                	mv	a5,a0
    return -1;
    80004a6c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a6e:	0007ca63          	bltz	a5,80004a82 <sys_write+0x40>
  return filewrite(f, p, n);
    80004a72:	fe442603          	lw	a2,-28(s0)
    80004a76:	fd843583          	ld	a1,-40(s0)
    80004a7a:	fe843503          	ld	a0,-24(s0)
    80004a7e:	e18ff0ef          	jal	ra,80004096 <filewrite>
}
    80004a82:	70a2                	ld	ra,40(sp)
    80004a84:	7402                	ld	s0,32(sp)
    80004a86:	6145                	addi	sp,sp,48
    80004a88:	8082                	ret

0000000080004a8a <sys_close>:
{
    80004a8a:	1101                	addi	sp,sp,-32
    80004a8c:	ec06                	sd	ra,24(sp)
    80004a8e:	e822                	sd	s0,16(sp)
    80004a90:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004a92:	fe040613          	addi	a2,s0,-32
    80004a96:	fec40593          	addi	a1,s0,-20
    80004a9a:	4501                	li	a0,0
    80004a9c:	d45ff0ef          	jal	ra,800047e0 <argfd>
    return -1;
    80004aa0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004aa2:	02054063          	bltz	a0,80004ac2 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004aa6:	d5dfc0ef          	jal	ra,80001802 <myproc>
    80004aaa:	fec42783          	lw	a5,-20(s0)
    80004aae:	07e9                	addi	a5,a5,26
    80004ab0:	078e                	slli	a5,a5,0x3
    80004ab2:	953e                	add	a0,a0,a5
    80004ab4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ab8:	fe043503          	ld	a0,-32(s0)
    80004abc:	c26ff0ef          	jal	ra,80003ee2 <fileclose>
  return 0;
    80004ac0:	4781                	li	a5,0
}
    80004ac2:	853e                	mv	a0,a5
    80004ac4:	60e2                	ld	ra,24(sp)
    80004ac6:	6442                	ld	s0,16(sp)
    80004ac8:	6105                	addi	sp,sp,32
    80004aca:	8082                	ret

0000000080004acc <sys_fstat>:
{
    80004acc:	1101                	addi	sp,sp,-32
    80004ace:	ec06                	sd	ra,24(sp)
    80004ad0:	e822                	sd	s0,16(sp)
    80004ad2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ad4:	fe040593          	addi	a1,s0,-32
    80004ad8:	4505                	li	a0,1
    80004ada:	c4dfd0ef          	jal	ra,80002726 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ade:	fe840613          	addi	a2,s0,-24
    80004ae2:	4581                	li	a1,0
    80004ae4:	4501                	li	a0,0
    80004ae6:	cfbff0ef          	jal	ra,800047e0 <argfd>
    80004aea:	87aa                	mv	a5,a0
    return -1;
    80004aec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004aee:	0007c863          	bltz	a5,80004afe <sys_fstat+0x32>
  return filestat(f, st);
    80004af2:	fe043583          	ld	a1,-32(s0)
    80004af6:	fe843503          	ld	a0,-24(s0)
    80004afa:	c90ff0ef          	jal	ra,80003f8a <filestat>
}
    80004afe:	60e2                	ld	ra,24(sp)
    80004b00:	6442                	ld	s0,16(sp)
    80004b02:	6105                	addi	sp,sp,32
    80004b04:	8082                	ret

0000000080004b06 <sys_link>:
{
    80004b06:	7169                	addi	sp,sp,-304
    80004b08:	f606                	sd	ra,296(sp)
    80004b0a:	f222                	sd	s0,288(sp)
    80004b0c:	ee26                	sd	s1,280(sp)
    80004b0e:	ea4a                	sd	s2,272(sp)
    80004b10:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b12:	08000613          	li	a2,128
    80004b16:	ed040593          	addi	a1,s0,-304
    80004b1a:	4501                	li	a0,0
    80004b1c:	c27fd0ef          	jal	ra,80002742 <argstr>
    return -1;
    80004b20:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b22:	0c054663          	bltz	a0,80004bee <sys_link+0xe8>
    80004b26:	08000613          	li	a2,128
    80004b2a:	f5040593          	addi	a1,s0,-176
    80004b2e:	4505                	li	a0,1
    80004b30:	c13fd0ef          	jal	ra,80002742 <argstr>
    return -1;
    80004b34:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b36:	0a054c63          	bltz	a0,80004bee <sys_link+0xe8>
  begin_op();
    80004b3a:	f9ffe0ef          	jal	ra,80003ad8 <begin_op>
  if((ip = namei(old)) == 0){
    80004b3e:	ed040513          	addi	a0,s0,-304
    80004b42:	da3fe0ef          	jal	ra,800038e4 <namei>
    80004b46:	84aa                	mv	s1,a0
    80004b48:	c525                	beqz	a0,80004bb0 <sys_link+0xaa>
  ilock(ip);
    80004b4a:	da6fe0ef          	jal	ra,800030f0 <ilock>
  if(ip->type == T_DIR){
    80004b4e:	04449703          	lh	a4,68(s1)
    80004b52:	4785                	li	a5,1
    80004b54:	06f70263          	beq	a4,a5,80004bb8 <sys_link+0xb2>
  ip->nlink++;
    80004b58:	04a4d783          	lhu	a5,74(s1)
    80004b5c:	2785                	addiw	a5,a5,1
    80004b5e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b62:	8526                	mv	a0,s1
    80004b64:	cd8fe0ef          	jal	ra,8000303c <iupdate>
  iunlock(ip);
    80004b68:	8526                	mv	a0,s1
    80004b6a:	e30fe0ef          	jal	ra,8000319a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004b6e:	fd040593          	addi	a1,s0,-48
    80004b72:	f5040513          	addi	a0,s0,-176
    80004b76:	d89fe0ef          	jal	ra,800038fe <nameiparent>
    80004b7a:	892a                	mv	s2,a0
    80004b7c:	c921                	beqz	a0,80004bcc <sys_link+0xc6>
  ilock(dp);
    80004b7e:	d72fe0ef          	jal	ra,800030f0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004b82:	00092703          	lw	a4,0(s2)
    80004b86:	409c                	lw	a5,0(s1)
    80004b88:	02f71f63          	bne	a4,a5,80004bc6 <sys_link+0xc0>
    80004b8c:	40d0                	lw	a2,4(s1)
    80004b8e:	fd040593          	addi	a1,s0,-48
    80004b92:	854a                	mv	a0,s2
    80004b94:	cb7fe0ef          	jal	ra,8000384a <dirlink>
    80004b98:	02054763          	bltz	a0,80004bc6 <sys_link+0xc0>
  iunlockput(dp);
    80004b9c:	854a                	mv	a0,s2
    80004b9e:	f58fe0ef          	jal	ra,800032f6 <iunlockput>
  iput(ip);
    80004ba2:	8526                	mv	a0,s1
    80004ba4:	ecafe0ef          	jal	ra,8000326e <iput>
  end_op();
    80004ba8:	f9ffe0ef          	jal	ra,80003b46 <end_op>
  return 0;
    80004bac:	4781                	li	a5,0
    80004bae:	a081                	j	80004bee <sys_link+0xe8>
    end_op();
    80004bb0:	f97fe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004bb4:	57fd                	li	a5,-1
    80004bb6:	a825                	j	80004bee <sys_link+0xe8>
    iunlockput(ip);
    80004bb8:	8526                	mv	a0,s1
    80004bba:	f3cfe0ef          	jal	ra,800032f6 <iunlockput>
    end_op();
    80004bbe:	f89fe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004bc2:	57fd                	li	a5,-1
    80004bc4:	a02d                	j	80004bee <sys_link+0xe8>
    iunlockput(dp);
    80004bc6:	854a                	mv	a0,s2
    80004bc8:	f2efe0ef          	jal	ra,800032f6 <iunlockput>
  ilock(ip);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	d22fe0ef          	jal	ra,800030f0 <ilock>
  ip->nlink--;
    80004bd2:	04a4d783          	lhu	a5,74(s1)
    80004bd6:	37fd                	addiw	a5,a5,-1
    80004bd8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004bdc:	8526                	mv	a0,s1
    80004bde:	c5efe0ef          	jal	ra,8000303c <iupdate>
  iunlockput(ip);
    80004be2:	8526                	mv	a0,s1
    80004be4:	f12fe0ef          	jal	ra,800032f6 <iunlockput>
  end_op();
    80004be8:	f5ffe0ef          	jal	ra,80003b46 <end_op>
  return -1;
    80004bec:	57fd                	li	a5,-1
}
    80004bee:	853e                	mv	a0,a5
    80004bf0:	70b2                	ld	ra,296(sp)
    80004bf2:	7412                	ld	s0,288(sp)
    80004bf4:	64f2                	ld	s1,280(sp)
    80004bf6:	6952                	ld	s2,272(sp)
    80004bf8:	6155                	addi	sp,sp,304
    80004bfa:	8082                	ret

0000000080004bfc <sys_unlink>:
{
    80004bfc:	7151                	addi	sp,sp,-240
    80004bfe:	f586                	sd	ra,232(sp)
    80004c00:	f1a2                	sd	s0,224(sp)
    80004c02:	eda6                	sd	s1,216(sp)
    80004c04:	e9ca                	sd	s2,208(sp)
    80004c06:	e5ce                	sd	s3,200(sp)
    80004c08:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c0a:	08000613          	li	a2,128
    80004c0e:	f3040593          	addi	a1,s0,-208
    80004c12:	4501                	li	a0,0
    80004c14:	b2ffd0ef          	jal	ra,80002742 <argstr>
    80004c18:	12054b63          	bltz	a0,80004d4e <sys_unlink+0x152>
  begin_op();
    80004c1c:	ebdfe0ef          	jal	ra,80003ad8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004c20:	fb040593          	addi	a1,s0,-80
    80004c24:	f3040513          	addi	a0,s0,-208
    80004c28:	cd7fe0ef          	jal	ra,800038fe <nameiparent>
    80004c2c:	84aa                	mv	s1,a0
    80004c2e:	c54d                	beqz	a0,80004cd8 <sys_unlink+0xdc>
  ilock(dp);
    80004c30:	cc0fe0ef          	jal	ra,800030f0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c34:	00003597          	auipc	a1,0x3
    80004c38:	a9c58593          	addi	a1,a1,-1380 # 800076d0 <syscalls+0x2e0>
    80004c3c:	fb040513          	addi	a0,s0,-80
    80004c40:	a23fe0ef          	jal	ra,80003662 <namecmp>
    80004c44:	10050a63          	beqz	a0,80004d58 <sys_unlink+0x15c>
    80004c48:	00003597          	auipc	a1,0x3
    80004c4c:	a9058593          	addi	a1,a1,-1392 # 800076d8 <syscalls+0x2e8>
    80004c50:	fb040513          	addi	a0,s0,-80
    80004c54:	a0ffe0ef          	jal	ra,80003662 <namecmp>
    80004c58:	10050063          	beqz	a0,80004d58 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004c5c:	f2c40613          	addi	a2,s0,-212
    80004c60:	fb040593          	addi	a1,s0,-80
    80004c64:	8526                	mv	a0,s1
    80004c66:	a13fe0ef          	jal	ra,80003678 <dirlookup>
    80004c6a:	892a                	mv	s2,a0
    80004c6c:	0e050663          	beqz	a0,80004d58 <sys_unlink+0x15c>
  ilock(ip);
    80004c70:	c80fe0ef          	jal	ra,800030f0 <ilock>
  if(ip->nlink < 1)
    80004c74:	04a91783          	lh	a5,74(s2)
    80004c78:	06f05463          	blez	a5,80004ce0 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c7c:	04491703          	lh	a4,68(s2)
    80004c80:	4785                	li	a5,1
    80004c82:	06f70563          	beq	a4,a5,80004cec <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004c86:	4641                	li	a2,16
    80004c88:	4581                	li	a1,0
    80004c8a:	fc040513          	addi	a0,s0,-64
    80004c8e:	fb1fb0ef          	jal	ra,80000c3e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c92:	4741                	li	a4,16
    80004c94:	f2c42683          	lw	a3,-212(s0)
    80004c98:	fc040613          	addi	a2,s0,-64
    80004c9c:	4581                	li	a1,0
    80004c9e:	8526                	mv	a0,s1
    80004ca0:	8c1fe0ef          	jal	ra,80003560 <writei>
    80004ca4:	47c1                	li	a5,16
    80004ca6:	08f51563          	bne	a0,a5,80004d30 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004caa:	04491703          	lh	a4,68(s2)
    80004cae:	4785                	li	a5,1
    80004cb0:	08f70663          	beq	a4,a5,80004d3c <sys_unlink+0x140>
  iunlockput(dp);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	e40fe0ef          	jal	ra,800032f6 <iunlockput>
  ip->nlink--;
    80004cba:	04a95783          	lhu	a5,74(s2)
    80004cbe:	37fd                	addiw	a5,a5,-1
    80004cc0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004cc4:	854a                	mv	a0,s2
    80004cc6:	b76fe0ef          	jal	ra,8000303c <iupdate>
  iunlockput(ip);
    80004cca:	854a                	mv	a0,s2
    80004ccc:	e2afe0ef          	jal	ra,800032f6 <iunlockput>
  end_op();
    80004cd0:	e77fe0ef          	jal	ra,80003b46 <end_op>
  return 0;
    80004cd4:	4501                	li	a0,0
    80004cd6:	a079                	j	80004d64 <sys_unlink+0x168>
    end_op();
    80004cd8:	e6ffe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004cdc:	557d                	li	a0,-1
    80004cde:	a059                	j	80004d64 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004ce0:	00003517          	auipc	a0,0x3
    80004ce4:	a0050513          	addi	a0,a0,-1536 # 800076e0 <syscalls+0x2f0>
    80004ce8:	aa1fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004cec:	04c92703          	lw	a4,76(s2)
    80004cf0:	02000793          	li	a5,32
    80004cf4:	f8e7f9e3          	bgeu	a5,a4,80004c86 <sys_unlink+0x8a>
    80004cf8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cfc:	4741                	li	a4,16
    80004cfe:	86ce                	mv	a3,s3
    80004d00:	f1840613          	addi	a2,s0,-232
    80004d04:	4581                	li	a1,0
    80004d06:	854a                	mv	a0,s2
    80004d08:	f74fe0ef          	jal	ra,8000347c <readi>
    80004d0c:	47c1                	li	a5,16
    80004d0e:	00f51b63          	bne	a0,a5,80004d24 <sys_unlink+0x128>
    if(de.inum != 0)
    80004d12:	f1845783          	lhu	a5,-232(s0)
    80004d16:	ef95                	bnez	a5,80004d52 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d18:	29c1                	addiw	s3,s3,16
    80004d1a:	04c92783          	lw	a5,76(s2)
    80004d1e:	fcf9efe3          	bltu	s3,a5,80004cfc <sys_unlink+0x100>
    80004d22:	b795                	j	80004c86 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004d24:	00003517          	auipc	a0,0x3
    80004d28:	9d450513          	addi	a0,a0,-1580 # 800076f8 <syscalls+0x308>
    80004d2c:	a5dfb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80004d30:	00003517          	auipc	a0,0x3
    80004d34:	9e050513          	addi	a0,a0,-1568 # 80007710 <syscalls+0x320>
    80004d38:	a51fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80004d3c:	04a4d783          	lhu	a5,74(s1)
    80004d40:	37fd                	addiw	a5,a5,-1
    80004d42:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d46:	8526                	mv	a0,s1
    80004d48:	af4fe0ef          	jal	ra,8000303c <iupdate>
    80004d4c:	b7a5                	j	80004cb4 <sys_unlink+0xb8>
    return -1;
    80004d4e:	557d                	li	a0,-1
    80004d50:	a811                	j	80004d64 <sys_unlink+0x168>
    iunlockput(ip);
    80004d52:	854a                	mv	a0,s2
    80004d54:	da2fe0ef          	jal	ra,800032f6 <iunlockput>
  iunlockput(dp);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	d9cfe0ef          	jal	ra,800032f6 <iunlockput>
  end_op();
    80004d5e:	de9fe0ef          	jal	ra,80003b46 <end_op>
  return -1;
    80004d62:	557d                	li	a0,-1
}
    80004d64:	70ae                	ld	ra,232(sp)
    80004d66:	740e                	ld	s0,224(sp)
    80004d68:	64ee                	ld	s1,216(sp)
    80004d6a:	694e                	ld	s2,208(sp)
    80004d6c:	69ae                	ld	s3,200(sp)
    80004d6e:	616d                	addi	sp,sp,240
    80004d70:	8082                	ret

0000000080004d72 <sys_open>:

uint64
sys_open(void)
{
    80004d72:	7131                	addi	sp,sp,-192
    80004d74:	fd06                	sd	ra,184(sp)
    80004d76:	f922                	sd	s0,176(sp)
    80004d78:	f526                	sd	s1,168(sp)
    80004d7a:	f14a                	sd	s2,160(sp)
    80004d7c:	ed4e                	sd	s3,152(sp)
    80004d7e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004d80:	f4c40593          	addi	a1,s0,-180
    80004d84:	4505                	li	a0,1
    80004d86:	985fd0ef          	jal	ra,8000270a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d8a:	08000613          	li	a2,128
    80004d8e:	f5040593          	addi	a1,s0,-176
    80004d92:	4501                	li	a0,0
    80004d94:	9affd0ef          	jal	ra,80002742 <argstr>
    80004d98:	87aa                	mv	a5,a0
    return -1;
    80004d9a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d9c:	0807cd63          	bltz	a5,80004e36 <sys_open+0xc4>

  begin_op();
    80004da0:	d39fe0ef          	jal	ra,80003ad8 <begin_op>

  if(omode & O_CREATE){
    80004da4:	f4c42783          	lw	a5,-180(s0)
    80004da8:	2007f793          	andi	a5,a5,512
    80004dac:	c3c5                	beqz	a5,80004e4c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004dae:	4681                	li	a3,0
    80004db0:	4601                	li	a2,0
    80004db2:	4589                	li	a1,2
    80004db4:	f5040513          	addi	a0,s0,-176
    80004db8:	abfff0ef          	jal	ra,80004876 <create>
    80004dbc:	84aa                	mv	s1,a0
    if(ip == 0){
    80004dbe:	c159                	beqz	a0,80004e44 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004dc0:	04449703          	lh	a4,68(s1)
    80004dc4:	478d                	li	a5,3
    80004dc6:	00f71763          	bne	a4,a5,80004dd4 <sys_open+0x62>
    80004dca:	0464d703          	lhu	a4,70(s1)
    80004dce:	47a5                	li	a5,9
    80004dd0:	0ae7e963          	bltu	a5,a4,80004e82 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004dd4:	86aff0ef          	jal	ra,80003e3e <filealloc>
    80004dd8:	89aa                	mv	s3,a0
    80004dda:	0c050963          	beqz	a0,80004eac <sys_open+0x13a>
    80004dde:	a5bff0ef          	jal	ra,80004838 <fdalloc>
    80004de2:	892a                	mv	s2,a0
    80004de4:	0c054163          	bltz	a0,80004ea6 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004de8:	04449703          	lh	a4,68(s1)
    80004dec:	478d                	li	a5,3
    80004dee:	0af70163          	beq	a4,a5,80004e90 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004df2:	4789                	li	a5,2
    80004df4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004df8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004dfc:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004e00:	f4c42783          	lw	a5,-180(s0)
    80004e04:	0017c713          	xori	a4,a5,1
    80004e08:	8b05                	andi	a4,a4,1
    80004e0a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e0e:	0037f713          	andi	a4,a5,3
    80004e12:	00e03733          	snez	a4,a4
    80004e16:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e1a:	4007f793          	andi	a5,a5,1024
    80004e1e:	c791                	beqz	a5,80004e2a <sys_open+0xb8>
    80004e20:	04449703          	lh	a4,68(s1)
    80004e24:	4789                	li	a5,2
    80004e26:	06f70c63          	beq	a4,a5,80004e9e <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	b6efe0ef          	jal	ra,8000319a <iunlock>
  end_op();
    80004e30:	d17fe0ef          	jal	ra,80003b46 <end_op>

  return fd;
    80004e34:	854a                	mv	a0,s2
}
    80004e36:	70ea                	ld	ra,184(sp)
    80004e38:	744a                	ld	s0,176(sp)
    80004e3a:	74aa                	ld	s1,168(sp)
    80004e3c:	790a                	ld	s2,160(sp)
    80004e3e:	69ea                	ld	s3,152(sp)
    80004e40:	6129                	addi	sp,sp,192
    80004e42:	8082                	ret
      end_op();
    80004e44:	d03fe0ef          	jal	ra,80003b46 <end_op>
      return -1;
    80004e48:	557d                	li	a0,-1
    80004e4a:	b7f5                	j	80004e36 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004e4c:	f5040513          	addi	a0,s0,-176
    80004e50:	a95fe0ef          	jal	ra,800038e4 <namei>
    80004e54:	84aa                	mv	s1,a0
    80004e56:	c115                	beqz	a0,80004e7a <sys_open+0x108>
    ilock(ip);
    80004e58:	a98fe0ef          	jal	ra,800030f0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e5c:	04449703          	lh	a4,68(s1)
    80004e60:	4785                	li	a5,1
    80004e62:	f4f71fe3          	bne	a4,a5,80004dc0 <sys_open+0x4e>
    80004e66:	f4c42783          	lw	a5,-180(s0)
    80004e6a:	d7ad                	beqz	a5,80004dd4 <sys_open+0x62>
      iunlockput(ip);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	c88fe0ef          	jal	ra,800032f6 <iunlockput>
      end_op();
    80004e72:	cd5fe0ef          	jal	ra,80003b46 <end_op>
      return -1;
    80004e76:	557d                	li	a0,-1
    80004e78:	bf7d                	j	80004e36 <sys_open+0xc4>
      end_op();
    80004e7a:	ccdfe0ef          	jal	ra,80003b46 <end_op>
      return -1;
    80004e7e:	557d                	li	a0,-1
    80004e80:	bf5d                	j	80004e36 <sys_open+0xc4>
    iunlockput(ip);
    80004e82:	8526                	mv	a0,s1
    80004e84:	c72fe0ef          	jal	ra,800032f6 <iunlockput>
    end_op();
    80004e88:	cbffe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004e8c:	557d                	li	a0,-1
    80004e8e:	b765                	j	80004e36 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004e90:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004e94:	04649783          	lh	a5,70(s1)
    80004e98:	02f99223          	sh	a5,36(s3)
    80004e9c:	b785                	j	80004dfc <sys_open+0x8a>
    itrunc(ip);
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	b3afe0ef          	jal	ra,800031da <itrunc>
    80004ea4:	b759                	j	80004e2a <sys_open+0xb8>
      fileclose(f);
    80004ea6:	854e                	mv	a0,s3
    80004ea8:	83aff0ef          	jal	ra,80003ee2 <fileclose>
    iunlockput(ip);
    80004eac:	8526                	mv	a0,s1
    80004eae:	c48fe0ef          	jal	ra,800032f6 <iunlockput>
    end_op();
    80004eb2:	c95fe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004eb6:	557d                	li	a0,-1
    80004eb8:	bfbd                	j	80004e36 <sys_open+0xc4>

0000000080004eba <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004eba:	7175                	addi	sp,sp,-144
    80004ebc:	e506                	sd	ra,136(sp)
    80004ebe:	e122                	sd	s0,128(sp)
    80004ec0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004ec2:	c17fe0ef          	jal	ra,80003ad8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004ec6:	08000613          	li	a2,128
    80004eca:	f7040593          	addi	a1,s0,-144
    80004ece:	4501                	li	a0,0
    80004ed0:	873fd0ef          	jal	ra,80002742 <argstr>
    80004ed4:	02054363          	bltz	a0,80004efa <sys_mkdir+0x40>
    80004ed8:	4681                	li	a3,0
    80004eda:	4601                	li	a2,0
    80004edc:	4585                	li	a1,1
    80004ede:	f7040513          	addi	a0,s0,-144
    80004ee2:	995ff0ef          	jal	ra,80004876 <create>
    80004ee6:	c911                	beqz	a0,80004efa <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004ee8:	c0efe0ef          	jal	ra,800032f6 <iunlockput>
  end_op();
    80004eec:	c5bfe0ef          	jal	ra,80003b46 <end_op>
  return 0;
    80004ef0:	4501                	li	a0,0
}
    80004ef2:	60aa                	ld	ra,136(sp)
    80004ef4:	640a                	ld	s0,128(sp)
    80004ef6:	6149                	addi	sp,sp,144
    80004ef8:	8082                	ret
    end_op();
    80004efa:	c4dfe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004efe:	557d                	li	a0,-1
    80004f00:	bfcd                	j	80004ef2 <sys_mkdir+0x38>

0000000080004f02 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f02:	7135                	addi	sp,sp,-160
    80004f04:	ed06                	sd	ra,152(sp)
    80004f06:	e922                	sd	s0,144(sp)
    80004f08:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f0a:	bcffe0ef          	jal	ra,80003ad8 <begin_op>
  argint(1, &major);
    80004f0e:	f6c40593          	addi	a1,s0,-148
    80004f12:	4505                	li	a0,1
    80004f14:	ff6fd0ef          	jal	ra,8000270a <argint>
  argint(2, &minor);
    80004f18:	f6840593          	addi	a1,s0,-152
    80004f1c:	4509                	li	a0,2
    80004f1e:	fecfd0ef          	jal	ra,8000270a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f22:	08000613          	li	a2,128
    80004f26:	f7040593          	addi	a1,s0,-144
    80004f2a:	4501                	li	a0,0
    80004f2c:	817fd0ef          	jal	ra,80002742 <argstr>
    80004f30:	02054563          	bltz	a0,80004f5a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f34:	f6841683          	lh	a3,-152(s0)
    80004f38:	f6c41603          	lh	a2,-148(s0)
    80004f3c:	458d                	li	a1,3
    80004f3e:	f7040513          	addi	a0,s0,-144
    80004f42:	935ff0ef          	jal	ra,80004876 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f46:	c911                	beqz	a0,80004f5a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f48:	baefe0ef          	jal	ra,800032f6 <iunlockput>
  end_op();
    80004f4c:	bfbfe0ef          	jal	ra,80003b46 <end_op>
  return 0;
    80004f50:	4501                	li	a0,0
}
    80004f52:	60ea                	ld	ra,152(sp)
    80004f54:	644a                	ld	s0,144(sp)
    80004f56:	610d                	addi	sp,sp,160
    80004f58:	8082                	ret
    end_op();
    80004f5a:	bedfe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004f5e:	557d                	li	a0,-1
    80004f60:	bfcd                	j	80004f52 <sys_mknod+0x50>

0000000080004f62 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004f62:	7135                	addi	sp,sp,-160
    80004f64:	ed06                	sd	ra,152(sp)
    80004f66:	e922                	sd	s0,144(sp)
    80004f68:	e526                	sd	s1,136(sp)
    80004f6a:	e14a                	sd	s2,128(sp)
    80004f6c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004f6e:	895fc0ef          	jal	ra,80001802 <myproc>
    80004f72:	892a                	mv	s2,a0
  
  begin_op();
    80004f74:	b65fe0ef          	jal	ra,80003ad8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004f78:	08000613          	li	a2,128
    80004f7c:	f6040593          	addi	a1,s0,-160
    80004f80:	4501                	li	a0,0
    80004f82:	fc0fd0ef          	jal	ra,80002742 <argstr>
    80004f86:	04054163          	bltz	a0,80004fc8 <sys_chdir+0x66>
    80004f8a:	f6040513          	addi	a0,s0,-160
    80004f8e:	957fe0ef          	jal	ra,800038e4 <namei>
    80004f92:	84aa                	mv	s1,a0
    80004f94:	c915                	beqz	a0,80004fc8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004f96:	95afe0ef          	jal	ra,800030f0 <ilock>
  if(ip->type != T_DIR){
    80004f9a:	04449703          	lh	a4,68(s1)
    80004f9e:	4785                	li	a5,1
    80004fa0:	02f71863          	bne	a4,a5,80004fd0 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	9f4fe0ef          	jal	ra,8000319a <iunlock>
  iput(p->cwd);
    80004faa:	15093503          	ld	a0,336(s2)
    80004fae:	ac0fe0ef          	jal	ra,8000326e <iput>
  end_op();
    80004fb2:	b95fe0ef          	jal	ra,80003b46 <end_op>
  p->cwd = ip;
    80004fb6:	14993823          	sd	s1,336(s2)
  return 0;
    80004fba:	4501                	li	a0,0
}
    80004fbc:	60ea                	ld	ra,152(sp)
    80004fbe:	644a                	ld	s0,144(sp)
    80004fc0:	64aa                	ld	s1,136(sp)
    80004fc2:	690a                	ld	s2,128(sp)
    80004fc4:	610d                	addi	sp,sp,160
    80004fc6:	8082                	ret
    end_op();
    80004fc8:	b7ffe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004fcc:	557d                	li	a0,-1
    80004fce:	b7fd                	j	80004fbc <sys_chdir+0x5a>
    iunlockput(ip);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	b24fe0ef          	jal	ra,800032f6 <iunlockput>
    end_op();
    80004fd6:	b71fe0ef          	jal	ra,80003b46 <end_op>
    return -1;
    80004fda:	557d                	li	a0,-1
    80004fdc:	b7c5                	j	80004fbc <sys_chdir+0x5a>

0000000080004fde <sys_exec>:

uint64
sys_exec(void)
{
    80004fde:	7145                	addi	sp,sp,-464
    80004fe0:	e786                	sd	ra,456(sp)
    80004fe2:	e3a2                	sd	s0,448(sp)
    80004fe4:	ff26                	sd	s1,440(sp)
    80004fe6:	fb4a                	sd	s2,432(sp)
    80004fe8:	f74e                	sd	s3,424(sp)
    80004fea:	f352                	sd	s4,416(sp)
    80004fec:	ef56                	sd	s5,408(sp)
    80004fee:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004ff0:	e3840593          	addi	a1,s0,-456
    80004ff4:	4505                	li	a0,1
    80004ff6:	f30fd0ef          	jal	ra,80002726 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004ffa:	08000613          	li	a2,128
    80004ffe:	f4040593          	addi	a1,s0,-192
    80005002:	4501                	li	a0,0
    80005004:	f3efd0ef          	jal	ra,80002742 <argstr>
    80005008:	87aa                	mv	a5,a0
    return -1;
    8000500a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000500c:	0a07c563          	bltz	a5,800050b6 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005010:	10000613          	li	a2,256
    80005014:	4581                	li	a1,0
    80005016:	e4040513          	addi	a0,s0,-448
    8000501a:	c25fb0ef          	jal	ra,80000c3e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000501e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005022:	89a6                	mv	s3,s1
    80005024:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005026:	02000a13          	li	s4,32
    8000502a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000502e:	00391513          	slli	a0,s2,0x3
    80005032:	e3040593          	addi	a1,s0,-464
    80005036:	e3843783          	ld	a5,-456(s0)
    8000503a:	953e                	add	a0,a0,a5
    8000503c:	e44fd0ef          	jal	ra,80002680 <fetchaddr>
    80005040:	02054663          	bltz	a0,8000506c <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005044:	e3043783          	ld	a5,-464(s0)
    80005048:	cf8d                	beqz	a5,80005082 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000504a:	a51fb0ef          	jal	ra,80000a9a <kalloc>
    8000504e:	85aa                	mv	a1,a0
    80005050:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005054:	cd01                	beqz	a0,8000506c <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005056:	6605                	lui	a2,0x1
    80005058:	e3043503          	ld	a0,-464(s0)
    8000505c:	e6efd0ef          	jal	ra,800026ca <fetchstr>
    80005060:	00054663          	bltz	a0,8000506c <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005064:	0905                	addi	s2,s2,1
    80005066:	09a1                	addi	s3,s3,8
    80005068:	fd4911e3          	bne	s2,s4,8000502a <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000506c:	f4040913          	addi	s2,s0,-192
    80005070:	6088                	ld	a0,0(s1)
    80005072:	c129                	beqz	a0,800050b4 <sys_exec+0xd6>
    kfree(argv[i]);
    80005074:	945fb0ef          	jal	ra,800009b8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005078:	04a1                	addi	s1,s1,8
    8000507a:	ff249be3          	bne	s1,s2,80005070 <sys_exec+0x92>
  return -1;
    8000507e:	557d                	li	a0,-1
    80005080:	a81d                	j	800050b6 <sys_exec+0xd8>
      argv[i] = 0;
    80005082:	0a8e                	slli	s5,s5,0x3
    80005084:	fc0a8793          	addi	a5,s5,-64
    80005088:	00878ab3          	add	s5,a5,s0
    8000508c:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005090:	e4040593          	addi	a1,s0,-448
    80005094:	f4040513          	addi	a0,s0,-192
    80005098:	bf6ff0ef          	jal	ra,8000448e <kexec>
    8000509c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000509e:	f4040993          	addi	s3,s0,-192
    800050a2:	6088                	ld	a0,0(s1)
    800050a4:	c511                	beqz	a0,800050b0 <sys_exec+0xd2>
    kfree(argv[i]);
    800050a6:	913fb0ef          	jal	ra,800009b8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050aa:	04a1                	addi	s1,s1,8
    800050ac:	ff349be3          	bne	s1,s3,800050a2 <sys_exec+0xc4>
  return ret;
    800050b0:	854a                	mv	a0,s2
    800050b2:	a011                	j	800050b6 <sys_exec+0xd8>
  return -1;
    800050b4:	557d                	li	a0,-1
}
    800050b6:	60be                	ld	ra,456(sp)
    800050b8:	641e                	ld	s0,448(sp)
    800050ba:	74fa                	ld	s1,440(sp)
    800050bc:	795a                	ld	s2,432(sp)
    800050be:	79ba                	ld	s3,424(sp)
    800050c0:	7a1a                	ld	s4,416(sp)
    800050c2:	6afa                	ld	s5,408(sp)
    800050c4:	6179                	addi	sp,sp,464
    800050c6:	8082                	ret

00000000800050c8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800050c8:	7139                	addi	sp,sp,-64
    800050ca:	fc06                	sd	ra,56(sp)
    800050cc:	f822                	sd	s0,48(sp)
    800050ce:	f426                	sd	s1,40(sp)
    800050d0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800050d2:	f30fc0ef          	jal	ra,80001802 <myproc>
    800050d6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800050d8:	fd840593          	addi	a1,s0,-40
    800050dc:	4501                	li	a0,0
    800050de:	e48fd0ef          	jal	ra,80002726 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800050e2:	fc840593          	addi	a1,s0,-56
    800050e6:	fd040513          	addi	a0,s0,-48
    800050ea:	8c4ff0ef          	jal	ra,800041ae <pipealloc>
    return -1;
    800050ee:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800050f0:	0a054463          	bltz	a0,80005198 <sys_pipe+0xd0>
  fd0 = -1;
    800050f4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800050f8:	fd043503          	ld	a0,-48(s0)
    800050fc:	f3cff0ef          	jal	ra,80004838 <fdalloc>
    80005100:	fca42223          	sw	a0,-60(s0)
    80005104:	08054163          	bltz	a0,80005186 <sys_pipe+0xbe>
    80005108:	fc843503          	ld	a0,-56(s0)
    8000510c:	f2cff0ef          	jal	ra,80004838 <fdalloc>
    80005110:	fca42023          	sw	a0,-64(s0)
    80005114:	06054063          	bltz	a0,80005174 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005118:	4691                	li	a3,4
    8000511a:	fc440613          	addi	a2,s0,-60
    8000511e:	fd843583          	ld	a1,-40(s0)
    80005122:	68a8                	ld	a0,80(s1)
    80005124:	c2cfc0ef          	jal	ra,80001550 <copyout>
    80005128:	00054e63          	bltz	a0,80005144 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000512c:	4691                	li	a3,4
    8000512e:	fc040613          	addi	a2,s0,-64
    80005132:	fd843583          	ld	a1,-40(s0)
    80005136:	0591                	addi	a1,a1,4
    80005138:	68a8                	ld	a0,80(s1)
    8000513a:	c16fc0ef          	jal	ra,80001550 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000513e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005140:	04055c63          	bgez	a0,80005198 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005144:	fc442783          	lw	a5,-60(s0)
    80005148:	07e9                	addi	a5,a5,26
    8000514a:	078e                	slli	a5,a5,0x3
    8000514c:	97a6                	add	a5,a5,s1
    8000514e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005152:	fc042783          	lw	a5,-64(s0)
    80005156:	07e9                	addi	a5,a5,26
    80005158:	078e                	slli	a5,a5,0x3
    8000515a:	94be                	add	s1,s1,a5
    8000515c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005160:	fd043503          	ld	a0,-48(s0)
    80005164:	d7ffe0ef          	jal	ra,80003ee2 <fileclose>
    fileclose(wf);
    80005168:	fc843503          	ld	a0,-56(s0)
    8000516c:	d77fe0ef          	jal	ra,80003ee2 <fileclose>
    return -1;
    80005170:	57fd                	li	a5,-1
    80005172:	a01d                	j	80005198 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005174:	fc442783          	lw	a5,-60(s0)
    80005178:	0007c763          	bltz	a5,80005186 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000517c:	07e9                	addi	a5,a5,26
    8000517e:	078e                	slli	a5,a5,0x3
    80005180:	97a6                	add	a5,a5,s1
    80005182:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005186:	fd043503          	ld	a0,-48(s0)
    8000518a:	d59fe0ef          	jal	ra,80003ee2 <fileclose>
    fileclose(wf);
    8000518e:	fc843503          	ld	a0,-56(s0)
    80005192:	d51fe0ef          	jal	ra,80003ee2 <fileclose>
    return -1;
    80005196:	57fd                	li	a5,-1
}
    80005198:	853e                	mv	a0,a5
    8000519a:	70e2                	ld	ra,56(sp)
    8000519c:	7442                	ld	s0,48(sp)
    8000519e:	74a2                	ld	s1,40(sp)
    800051a0:	6121                	addi	sp,sp,64
    800051a2:	8082                	ret
	...

00000000800051b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800051b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800051b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800051b4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800051b6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800051b8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800051ba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800051bc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800051be:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800051c0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800051c2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800051c4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800051c6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800051c8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800051ca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800051cc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800051ce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800051d0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800051d2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800051d4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800051d6:	bbafd0ef          	jal	ra,80002590 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800051da:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800051dc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800051de:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800051e0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800051e2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800051e4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800051e6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800051e8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800051ea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800051ec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800051ee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800051f0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800051f2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800051f4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800051f6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800051f8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800051fa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800051fc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800051fe:	10200073          	sret
	...

000000008000520e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000520e:	1141                	addi	sp,sp,-16
    80005210:	e422                	sd	s0,8(sp)
    80005212:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005214:	0c0007b7          	lui	a5,0xc000
    80005218:	4705                	li	a4,1
    8000521a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000521c:	c3d8                	sw	a4,4(a5)
}
    8000521e:	6422                	ld	s0,8(sp)
    80005220:	0141                	addi	sp,sp,16
    80005222:	8082                	ret

0000000080005224 <plicinithart>:

void
plicinithart(void)
{
    80005224:	1141                	addi	sp,sp,-16
    80005226:	e406                	sd	ra,8(sp)
    80005228:	e022                	sd	s0,0(sp)
    8000522a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000522c:	daafc0ef          	jal	ra,800017d6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005230:	0085171b          	slliw	a4,a0,0x8
    80005234:	0c0027b7          	lui	a5,0xc002
    80005238:	97ba                	add	a5,a5,a4
    8000523a:	40200713          	li	a4,1026
    8000523e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005242:	00d5151b          	slliw	a0,a0,0xd
    80005246:	0c2017b7          	lui	a5,0xc201
    8000524a:	97aa                	add	a5,a5,a0
    8000524c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005250:	60a2                	ld	ra,8(sp)
    80005252:	6402                	ld	s0,0(sp)
    80005254:	0141                	addi	sp,sp,16
    80005256:	8082                	ret

0000000080005258 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005258:	1141                	addi	sp,sp,-16
    8000525a:	e406                	sd	ra,8(sp)
    8000525c:	e022                	sd	s0,0(sp)
    8000525e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005260:	d76fc0ef          	jal	ra,800017d6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005264:	00d5151b          	slliw	a0,a0,0xd
    80005268:	0c2017b7          	lui	a5,0xc201
    8000526c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000526e:	43c8                	lw	a0,4(a5)
    80005270:	60a2                	ld	ra,8(sp)
    80005272:	6402                	ld	s0,0(sp)
    80005274:	0141                	addi	sp,sp,16
    80005276:	8082                	ret

0000000080005278 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005278:	1101                	addi	sp,sp,-32
    8000527a:	ec06                	sd	ra,24(sp)
    8000527c:	e822                	sd	s0,16(sp)
    8000527e:	e426                	sd	s1,8(sp)
    80005280:	1000                	addi	s0,sp,32
    80005282:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005284:	d52fc0ef          	jal	ra,800017d6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005288:	00d5151b          	slliw	a0,a0,0xd
    8000528c:	0c2017b7          	lui	a5,0xc201
    80005290:	97aa                	add	a5,a5,a0
    80005292:	c3c4                	sw	s1,4(a5)
}
    80005294:	60e2                	ld	ra,24(sp)
    80005296:	6442                	ld	s0,16(sp)
    80005298:	64a2                	ld	s1,8(sp)
    8000529a:	6105                	addi	sp,sp,32
    8000529c:	8082                	ret

000000008000529e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000529e:	1141                	addi	sp,sp,-16
    800052a0:	e406                	sd	ra,8(sp)
    800052a2:	e022                	sd	s0,0(sp)
    800052a4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800052a6:	479d                	li	a5,7
    800052a8:	04a7ca63          	blt	a5,a0,800052fc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800052ac:	0001b797          	auipc	a5,0x1b
    800052b0:	79c78793          	addi	a5,a5,1948 # 80020a48 <disk>
    800052b4:	97aa                	add	a5,a5,a0
    800052b6:	0187c783          	lbu	a5,24(a5)
    800052ba:	e7b9                	bnez	a5,80005308 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800052bc:	00451693          	slli	a3,a0,0x4
    800052c0:	0001b797          	auipc	a5,0x1b
    800052c4:	78878793          	addi	a5,a5,1928 # 80020a48 <disk>
    800052c8:	6398                	ld	a4,0(a5)
    800052ca:	9736                	add	a4,a4,a3
    800052cc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800052d0:	6398                	ld	a4,0(a5)
    800052d2:	9736                	add	a4,a4,a3
    800052d4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800052d8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800052dc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800052e0:	97aa                	add	a5,a5,a0
    800052e2:	4705                	li	a4,1
    800052e4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800052e8:	0001b517          	auipc	a0,0x1b
    800052ec:	77850513          	addi	a0,a0,1912 # 80020a60 <disk+0x18>
    800052f0:	b67fc0ef          	jal	ra,80001e56 <wakeup>
}
    800052f4:	60a2                	ld	ra,8(sp)
    800052f6:	6402                	ld	s0,0(sp)
    800052f8:	0141                	addi	sp,sp,16
    800052fa:	8082                	ret
    panic("free_desc 1");
    800052fc:	00002517          	auipc	a0,0x2
    80005300:	42450513          	addi	a0,a0,1060 # 80007720 <syscalls+0x330>
    80005304:	c84fb0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005308:	00002517          	auipc	a0,0x2
    8000530c:	42850513          	addi	a0,a0,1064 # 80007730 <syscalls+0x340>
    80005310:	c78fb0ef          	jal	ra,80000788 <panic>

0000000080005314 <virtio_disk_init>:
{
    80005314:	1101                	addi	sp,sp,-32
    80005316:	ec06                	sd	ra,24(sp)
    80005318:	e822                	sd	s0,16(sp)
    8000531a:	e426                	sd	s1,8(sp)
    8000531c:	e04a                	sd	s2,0(sp)
    8000531e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005320:	00002597          	auipc	a1,0x2
    80005324:	42058593          	addi	a1,a1,1056 # 80007740 <syscalls+0x350>
    80005328:	0001c517          	auipc	a0,0x1c
    8000532c:	84850513          	addi	a0,a0,-1976 # 80020b70 <disk+0x128>
    80005330:	fbafb0ef          	jal	ra,80000aea <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005334:	100017b7          	lui	a5,0x10001
    80005338:	4398                	lw	a4,0(a5)
    8000533a:	2701                	sext.w	a4,a4
    8000533c:	747277b7          	lui	a5,0x74727
    80005340:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005344:	12f71f63          	bne	a4,a5,80005482 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005348:	100017b7          	lui	a5,0x10001
    8000534c:	43dc                	lw	a5,4(a5)
    8000534e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005350:	4709                	li	a4,2
    80005352:	12e79863          	bne	a5,a4,80005482 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005356:	100017b7          	lui	a5,0x10001
    8000535a:	479c                	lw	a5,8(a5)
    8000535c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000535e:	12e79263          	bne	a5,a4,80005482 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005362:	100017b7          	lui	a5,0x10001
    80005366:	47d8                	lw	a4,12(a5)
    80005368:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000536a:	554d47b7          	lui	a5,0x554d4
    8000536e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005372:	10f71863          	bne	a4,a5,80005482 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005376:	100017b7          	lui	a5,0x10001
    8000537a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000537e:	4705                	li	a4,1
    80005380:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005382:	470d                	li	a4,3
    80005384:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005386:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005388:	c7ffe6b7          	lui	a3,0xc7ffe
    8000538c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fddbd7>
    80005390:	8f75                	and	a4,a4,a3
    80005392:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005394:	472d                	li	a4,11
    80005396:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005398:	5bbc                	lw	a5,112(a5)
    8000539a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000539e:	8ba1                	andi	a5,a5,8
    800053a0:	0e078763          	beqz	a5,8000548e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800053a4:	100017b7          	lui	a5,0x10001
    800053a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800053ac:	43fc                	lw	a5,68(a5)
    800053ae:	2781                	sext.w	a5,a5
    800053b0:	0e079563          	bnez	a5,8000549a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800053b4:	100017b7          	lui	a5,0x10001
    800053b8:	5bdc                	lw	a5,52(a5)
    800053ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800053bc:	0e078563          	beqz	a5,800054a6 <virtio_disk_init+0x192>
  if(max < NUM)
    800053c0:	471d                	li	a4,7
    800053c2:	0ef77863          	bgeu	a4,a5,800054b2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800053c6:	ed4fb0ef          	jal	ra,80000a9a <kalloc>
    800053ca:	0001b497          	auipc	s1,0x1b
    800053ce:	67e48493          	addi	s1,s1,1662 # 80020a48 <disk>
    800053d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800053d4:	ec6fb0ef          	jal	ra,80000a9a <kalloc>
    800053d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800053da:	ec0fb0ef          	jal	ra,80000a9a <kalloc>
    800053de:	87aa                	mv	a5,a0
    800053e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800053e2:	6088                	ld	a0,0(s1)
    800053e4:	cd69                	beqz	a0,800054be <virtio_disk_init+0x1aa>
    800053e6:	0001b717          	auipc	a4,0x1b
    800053ea:	66a73703          	ld	a4,1642(a4) # 80020a50 <disk+0x8>
    800053ee:	cb61                	beqz	a4,800054be <virtio_disk_init+0x1aa>
    800053f0:	c7f9                	beqz	a5,800054be <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    800053f2:	6605                	lui	a2,0x1
    800053f4:	4581                	li	a1,0
    800053f6:	849fb0ef          	jal	ra,80000c3e <memset>
  memset(disk.avail, 0, PGSIZE);
    800053fa:	0001b497          	auipc	s1,0x1b
    800053fe:	64e48493          	addi	s1,s1,1614 # 80020a48 <disk>
    80005402:	6605                	lui	a2,0x1
    80005404:	4581                	li	a1,0
    80005406:	6488                	ld	a0,8(s1)
    80005408:	837fb0ef          	jal	ra,80000c3e <memset>
  memset(disk.used, 0, PGSIZE);
    8000540c:	6605                	lui	a2,0x1
    8000540e:	4581                	li	a1,0
    80005410:	6888                	ld	a0,16(s1)
    80005412:	82dfb0ef          	jal	ra,80000c3e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005416:	100017b7          	lui	a5,0x10001
    8000541a:	4721                	li	a4,8
    8000541c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000541e:	4098                	lw	a4,0(s1)
    80005420:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005424:	40d8                	lw	a4,4(s1)
    80005426:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000542a:	6498                	ld	a4,8(s1)
    8000542c:	0007069b          	sext.w	a3,a4
    80005430:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005434:	9701                	srai	a4,a4,0x20
    80005436:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000543a:	6898                	ld	a4,16(s1)
    8000543c:	0007069b          	sext.w	a3,a4
    80005440:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005444:	9701                	srai	a4,a4,0x20
    80005446:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000544a:	4705                	li	a4,1
    8000544c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000544e:	00e48c23          	sb	a4,24(s1)
    80005452:	00e48ca3          	sb	a4,25(s1)
    80005456:	00e48d23          	sb	a4,26(s1)
    8000545a:	00e48da3          	sb	a4,27(s1)
    8000545e:	00e48e23          	sb	a4,28(s1)
    80005462:	00e48ea3          	sb	a4,29(s1)
    80005466:	00e48f23          	sb	a4,30(s1)
    8000546a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000546e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005472:	0727a823          	sw	s2,112(a5)
}
    80005476:	60e2                	ld	ra,24(sp)
    80005478:	6442                	ld	s0,16(sp)
    8000547a:	64a2                	ld	s1,8(sp)
    8000547c:	6902                	ld	s2,0(sp)
    8000547e:	6105                	addi	sp,sp,32
    80005480:	8082                	ret
    panic("could not find virtio disk");
    80005482:	00002517          	auipc	a0,0x2
    80005486:	2ce50513          	addi	a0,a0,718 # 80007750 <syscalls+0x360>
    8000548a:	afefb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000548e:	00002517          	auipc	a0,0x2
    80005492:	2e250513          	addi	a0,a0,738 # 80007770 <syscalls+0x380>
    80005496:	af2fb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    8000549a:	00002517          	auipc	a0,0x2
    8000549e:	2f650513          	addi	a0,a0,758 # 80007790 <syscalls+0x3a0>
    800054a2:	ae6fb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    800054a6:	00002517          	auipc	a0,0x2
    800054aa:	30a50513          	addi	a0,a0,778 # 800077b0 <syscalls+0x3c0>
    800054ae:	adafb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    800054b2:	00002517          	auipc	a0,0x2
    800054b6:	31e50513          	addi	a0,a0,798 # 800077d0 <syscalls+0x3e0>
    800054ba:	acefb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    800054be:	00002517          	auipc	a0,0x2
    800054c2:	33250513          	addi	a0,a0,818 # 800077f0 <syscalls+0x400>
    800054c6:	ac2fb0ef          	jal	ra,80000788 <panic>

00000000800054ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800054ca:	7119                	addi	sp,sp,-128
    800054cc:	fc86                	sd	ra,120(sp)
    800054ce:	f8a2                	sd	s0,112(sp)
    800054d0:	f4a6                	sd	s1,104(sp)
    800054d2:	f0ca                	sd	s2,96(sp)
    800054d4:	ecce                	sd	s3,88(sp)
    800054d6:	e8d2                	sd	s4,80(sp)
    800054d8:	e4d6                	sd	s5,72(sp)
    800054da:	e0da                	sd	s6,64(sp)
    800054dc:	fc5e                	sd	s7,56(sp)
    800054de:	f862                	sd	s8,48(sp)
    800054e0:	f466                	sd	s9,40(sp)
    800054e2:	f06a                	sd	s10,32(sp)
    800054e4:	ec6e                	sd	s11,24(sp)
    800054e6:	0100                	addi	s0,sp,128
    800054e8:	8aaa                	mv	s5,a0
    800054ea:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800054ec:	00c52d03          	lw	s10,12(a0)
    800054f0:	001d1d1b          	slliw	s10,s10,0x1
    800054f4:	1d02                	slli	s10,s10,0x20
    800054f6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800054fa:	0001b517          	auipc	a0,0x1b
    800054fe:	67650513          	addi	a0,a0,1654 # 80020b70 <disk+0x128>
    80005502:	e68fb0ef          	jal	ra,80000b6a <acquire>
  for(int i = 0; i < 3; i++){
    80005506:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005508:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000550a:	0001bb97          	auipc	s7,0x1b
    8000550e:	53eb8b93          	addi	s7,s7,1342 # 80020a48 <disk>
  for(int i = 0; i < 3; i++){
    80005512:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005514:	0001bc97          	auipc	s9,0x1b
    80005518:	65cc8c93          	addi	s9,s9,1628 # 80020b70 <disk+0x128>
    8000551c:	a8a9                	j	80005576 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000551e:	00fb8733          	add	a4,s7,a5
    80005522:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005526:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005528:	0207c563          	bltz	a5,80005552 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000552c:	2905                	addiw	s2,s2,1
    8000552e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005530:	05690863          	beq	s2,s6,80005580 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005534:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005536:	0001b717          	auipc	a4,0x1b
    8000553a:	51270713          	addi	a4,a4,1298 # 80020a48 <disk>
    8000553e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005540:	01874683          	lbu	a3,24(a4)
    80005544:	fee9                	bnez	a3,8000551e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005546:	2785                	addiw	a5,a5,1
    80005548:	0705                	addi	a4,a4,1
    8000554a:	fe979be3          	bne	a5,s1,80005540 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000554e:	57fd                	li	a5,-1
    80005550:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005552:	01205b63          	blez	s2,80005568 <virtio_disk_rw+0x9e>
    80005556:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005558:	000a2503          	lw	a0,0(s4)
    8000555c:	d43ff0ef          	jal	ra,8000529e <free_desc>
      for(int j = 0; j < i; j++)
    80005560:	2d85                	addiw	s11,s11,1
    80005562:	0a11                	addi	s4,s4,4
    80005564:	ff2d9ae3          	bne	s11,s2,80005558 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005568:	85e6                	mv	a1,s9
    8000556a:	0001b517          	auipc	a0,0x1b
    8000556e:	4f650513          	addi	a0,a0,1270 # 80020a60 <disk+0x18>
    80005572:	899fc0ef          	jal	ra,80001e0a <sleep>
  for(int i = 0; i < 3; i++){
    80005576:	f8040a13          	addi	s4,s0,-128
{
    8000557a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000557c:	894e                	mv	s2,s3
    8000557e:	bf5d                	j	80005534 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005580:	f8042503          	lw	a0,-128(s0)
    80005584:	00a50713          	addi	a4,a0,10
    80005588:	0712                	slli	a4,a4,0x4

  if(write)
    8000558a:	0001b797          	auipc	a5,0x1b
    8000558e:	4be78793          	addi	a5,a5,1214 # 80020a48 <disk>
    80005592:	00e786b3          	add	a3,a5,a4
    80005596:	01803633          	snez	a2,s8
    8000559a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000559c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800055a0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800055a4:	f6070613          	addi	a2,a4,-160
    800055a8:	6394                	ld	a3,0(a5)
    800055aa:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800055ac:	00870593          	addi	a1,a4,8
    800055b0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800055b2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800055b4:	0007b803          	ld	a6,0(a5)
    800055b8:	9642                	add	a2,a2,a6
    800055ba:	46c1                	li	a3,16
    800055bc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800055be:	4585                	li	a1,1
    800055c0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800055c4:	f8442683          	lw	a3,-124(s0)
    800055c8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800055cc:	0692                	slli	a3,a3,0x4
    800055ce:	9836                	add	a6,a6,a3
    800055d0:	058a8613          	addi	a2,s5,88
    800055d4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800055d8:	0007b803          	ld	a6,0(a5)
    800055dc:	96c2                	add	a3,a3,a6
    800055de:	40000613          	li	a2,1024
    800055e2:	c690                	sw	a2,8(a3)
  if(write)
    800055e4:	001c3613          	seqz	a2,s8
    800055e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800055ec:	00166613          	ori	a2,a2,1
    800055f0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800055f4:	f8842603          	lw	a2,-120(s0)
    800055f8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800055fc:	00250693          	addi	a3,a0,2
    80005600:	0692                	slli	a3,a3,0x4
    80005602:	96be                	add	a3,a3,a5
    80005604:	58fd                	li	a7,-1
    80005606:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000560a:	0612                	slli	a2,a2,0x4
    8000560c:	9832                	add	a6,a6,a2
    8000560e:	f9070713          	addi	a4,a4,-112
    80005612:	973e                	add	a4,a4,a5
    80005614:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005618:	6398                	ld	a4,0(a5)
    8000561a:	9732                	add	a4,a4,a2
    8000561c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000561e:	4609                	li	a2,2
    80005620:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005624:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005628:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000562c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005630:	6794                	ld	a3,8(a5)
    80005632:	0026d703          	lhu	a4,2(a3)
    80005636:	8b1d                	andi	a4,a4,7
    80005638:	0706                	slli	a4,a4,0x1
    8000563a:	96ba                	add	a3,a3,a4
    8000563c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005640:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005644:	6798                	ld	a4,8(a5)
    80005646:	00275783          	lhu	a5,2(a4)
    8000564a:	2785                	addiw	a5,a5,1
    8000564c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005650:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005654:	100017b7          	lui	a5,0x10001
    80005658:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000565c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005660:	0001b917          	auipc	s2,0x1b
    80005664:	51090913          	addi	s2,s2,1296 # 80020b70 <disk+0x128>
  while(b->disk == 1) {
    80005668:	4485                	li	s1,1
    8000566a:	00b79a63          	bne	a5,a1,8000567e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    8000566e:	85ca                	mv	a1,s2
    80005670:	8556                	mv	a0,s5
    80005672:	f98fc0ef          	jal	ra,80001e0a <sleep>
  while(b->disk == 1) {
    80005676:	004aa783          	lw	a5,4(s5)
    8000567a:	fe978ae3          	beq	a5,s1,8000566e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    8000567e:	f8042903          	lw	s2,-128(s0)
    80005682:	00290713          	addi	a4,s2,2
    80005686:	0712                	slli	a4,a4,0x4
    80005688:	0001b797          	auipc	a5,0x1b
    8000568c:	3c078793          	addi	a5,a5,960 # 80020a48 <disk>
    80005690:	97ba                	add	a5,a5,a4
    80005692:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005696:	0001b997          	auipc	s3,0x1b
    8000569a:	3b298993          	addi	s3,s3,946 # 80020a48 <disk>
    8000569e:	00491713          	slli	a4,s2,0x4
    800056a2:	0009b783          	ld	a5,0(s3)
    800056a6:	97ba                	add	a5,a5,a4
    800056a8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800056ac:	854a                	mv	a0,s2
    800056ae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800056b2:	bedff0ef          	jal	ra,8000529e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800056b6:	8885                	andi	s1,s1,1
    800056b8:	f0fd                	bnez	s1,8000569e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800056ba:	0001b517          	auipc	a0,0x1b
    800056be:	4b650513          	addi	a0,a0,1206 # 80020b70 <disk+0x128>
    800056c2:	d40fb0ef          	jal	ra,80000c02 <release>
}
    800056c6:	70e6                	ld	ra,120(sp)
    800056c8:	7446                	ld	s0,112(sp)
    800056ca:	74a6                	ld	s1,104(sp)
    800056cc:	7906                	ld	s2,96(sp)
    800056ce:	69e6                	ld	s3,88(sp)
    800056d0:	6a46                	ld	s4,80(sp)
    800056d2:	6aa6                	ld	s5,72(sp)
    800056d4:	6b06                	ld	s6,64(sp)
    800056d6:	7be2                	ld	s7,56(sp)
    800056d8:	7c42                	ld	s8,48(sp)
    800056da:	7ca2                	ld	s9,40(sp)
    800056dc:	7d02                	ld	s10,32(sp)
    800056de:	6de2                	ld	s11,24(sp)
    800056e0:	6109                	addi	sp,sp,128
    800056e2:	8082                	ret

00000000800056e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800056e4:	1101                	addi	sp,sp,-32
    800056e6:	ec06                	sd	ra,24(sp)
    800056e8:	e822                	sd	s0,16(sp)
    800056ea:	e426                	sd	s1,8(sp)
    800056ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800056ee:	0001b497          	auipc	s1,0x1b
    800056f2:	35a48493          	addi	s1,s1,858 # 80020a48 <disk>
    800056f6:	0001b517          	auipc	a0,0x1b
    800056fa:	47a50513          	addi	a0,a0,1146 # 80020b70 <disk+0x128>
    800056fe:	c6cfb0ef          	jal	ra,80000b6a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005702:	10001737          	lui	a4,0x10001
    80005706:	533c                	lw	a5,96(a4)
    80005708:	8b8d                	andi	a5,a5,3
    8000570a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000570c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005710:	689c                	ld	a5,16(s1)
    80005712:	0204d703          	lhu	a4,32(s1)
    80005716:	0027d783          	lhu	a5,2(a5)
    8000571a:	04f70663          	beq	a4,a5,80005766 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000571e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005722:	6898                	ld	a4,16(s1)
    80005724:	0204d783          	lhu	a5,32(s1)
    80005728:	8b9d                	andi	a5,a5,7
    8000572a:	078e                	slli	a5,a5,0x3
    8000572c:	97ba                	add	a5,a5,a4
    8000572e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005730:	00278713          	addi	a4,a5,2
    80005734:	0712                	slli	a4,a4,0x4
    80005736:	9726                	add	a4,a4,s1
    80005738:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000573c:	e321                	bnez	a4,8000577c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000573e:	0789                	addi	a5,a5,2
    80005740:	0792                	slli	a5,a5,0x4
    80005742:	97a6                	add	a5,a5,s1
    80005744:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005746:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000574a:	f0cfc0ef          	jal	ra,80001e56 <wakeup>

    disk.used_idx += 1;
    8000574e:	0204d783          	lhu	a5,32(s1)
    80005752:	2785                	addiw	a5,a5,1
    80005754:	17c2                	slli	a5,a5,0x30
    80005756:	93c1                	srli	a5,a5,0x30
    80005758:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000575c:	6898                	ld	a4,16(s1)
    8000575e:	00275703          	lhu	a4,2(a4)
    80005762:	faf71ee3          	bne	a4,a5,8000571e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005766:	0001b517          	auipc	a0,0x1b
    8000576a:	40a50513          	addi	a0,a0,1034 # 80020b70 <disk+0x128>
    8000576e:	c94fb0ef          	jal	ra,80000c02 <release>
}
    80005772:	60e2                	ld	ra,24(sp)
    80005774:	6442                	ld	s0,16(sp)
    80005776:	64a2                	ld	s1,8(sp)
    80005778:	6105                	addi	sp,sp,32
    8000577a:	8082                	ret
      panic("virtio_disk_intr status");
    8000577c:	00002517          	auipc	a0,0x2
    80005780:	08c50513          	addi	a0,a0,140 # 80007808 <syscalls+0x418>
    80005784:	804fb0ef          	jal	ra,80000788 <panic>
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
