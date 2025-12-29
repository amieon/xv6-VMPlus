
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
    8000010a:	376020ef          	jal	ra,80002480 <either_copyin>
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
    800001a8:	16a020ef          	jal	ra,80002312 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	729010ef          	jal	ra,800020da <sleep>
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
    800001ea:	24c020ef          	jal	ra,80002436 <either_copyout>
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
    800002aa:	220020ef          	jal	ra,800024ca <procdump>
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
    800003e6:	541010ef          	jal	ra,80002126 <wakeup>
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
    80000892:	049010ef          	jal	ra,800020da <sleep>
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
    8000099c:	78a010ef          	jal	ra,80002126 <wakeup>
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
    80000f4c:	6b0010ef          	jal	ra,800025fc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	7e4040ef          	jal	ra,80005734 <plicinithart>
  }

  scheduler();        
    80000f54:	7ef000ef          	jal	ra,80001f42 <scheduler>
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
    80000f94:	644010ef          	jal	ra,800025d8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	664010ef          	jal	ra,800025fc <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	782040ef          	jal	ra,8000571e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	794040ef          	jal	ra,80005734 <plicinithart>
    binit();         // buffer cache
    80000fa4:	72f010ef          	jal	ra,80002ed2 <binit>
    iinit();         // inode table
    80000fa8:	49e020ef          	jal	ra,80003446 <iinit>
    fileinit();      // file table
    80000fac:	386030ef          	jal	ra,80004332 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	075040ef          	jal	ra,80005824 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	5e5000ef          	jal	ra,80001d98 <userinit>
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
    800018f4:	3ce010ef          	jal	ra,80002cc2 <vma_find>
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
    80001b22:	5d7010ef          	jal	ra,800038f8 <fsinit>

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
    80001b46:	661020ef          	jal	ra,800049a6 <kexec>
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
    80001b58:	2bd000ef          	jal	ra,80002614 <prepare_return>
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

0000000080001c5c <proc_freepagetable>:
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	e04a                	sd	s2,0(sp)
    80001c66:	1000                	addi	s0,sp,32
    80001c68:	84aa                	mv	s1,a0
    80001c6a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c6c:	4681                	li	a3,0
    80001c6e:	4605                	li	a2,1
    80001c70:	040005b7          	lui	a1,0x4000
    80001c74:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c76:	05b2                	slli	a1,a1,0xc
    80001c78:	e1cff0ef          	jal	ra,80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c7c:	4681                	li	a3,0
    80001c7e:	4605                	li	a2,1
    80001c80:	020005b7          	lui	a1,0x2000
    80001c84:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c86:	05b6                	slli	a1,a1,0xd
    80001c88:	8526                	mv	a0,s1
    80001c8a:	e0aff0ef          	jal	ra,80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c8e:	85ca                	mv	a1,s2
    80001c90:	8526                	mv	a0,s1
    80001c92:	fbcff0ef          	jal	ra,8000144e <uvmfree>
}
    80001c96:	60e2                	ld	ra,24(sp)
    80001c98:	6442                	ld	s0,16(sp)
    80001c9a:	64a2                	ld	s1,8(sp)
    80001c9c:	6902                	ld	s2,0(sp)
    80001c9e:	6105                	addi	sp,sp,32
    80001ca0:	8082                	ret

0000000080001ca2 <freeproc>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	1000                	addi	s0,sp,32
    80001cac:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cae:	6d28                	ld	a0,88(a0)
    80001cb0:	c119                	beqz	a0,80001cb6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001cb2:	dc9fe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001cb6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cba:	68a8                	ld	a0,80(s1)
    80001cbc:	c501                	beqz	a0,80001cc4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001cbe:	64ac                	ld	a1,72(s1)
    80001cc0:	f9dff0ef          	jal	ra,80001c5c <proc_freepagetable>
  p->pagetable = 0;
    80001cc4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cc8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ccc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cd0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cd4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cd8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cdc:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ce0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ce4:	0004ac23          	sw	zero,24(s1)
}
    80001ce8:	60e2                	ld	ra,24(sp)
    80001cea:	6442                	ld	s0,16(sp)
    80001cec:	64a2                	ld	s1,8(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret

0000000080001cf2 <allocproc>:
{
    80001cf2:	1101                	addi	sp,sp,-32
    80001cf4:	ec06                	sd	ra,24(sp)
    80001cf6:	e822                	sd	s0,16(sp)
    80001cf8:	e426                	sd	s1,8(sp)
    80001cfa:	e04a                	sd	s2,0(sp)
    80001cfc:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cfe:	0022e497          	auipc	s1,0x22e
    80001d02:	0e248493          	addi	s1,s1,226 # 8022fde0 <proc>
    80001d06:	0023c917          	auipc	s2,0x23c
    80001d0a:	ada90913          	addi	s2,s2,-1318 # 8023d7e0 <tickslock>
    acquire(&p->lock);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	f91fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001d14:	4c9c                	lw	a5,24(s1)
    80001d16:	cb91                	beqz	a5,80001d2a <allocproc+0x38>
      release(&p->lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	81eff0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d1e:	36848493          	addi	s1,s1,872
    80001d22:	ff2496e3          	bne	s1,s2,80001d0e <allocproc+0x1c>
  return 0;
    80001d26:	4481                	li	s1,0
    80001d28:	a089                	j	80001d6a <allocproc+0x78>
  p->pid = allocpid();
    80001d2a:	e71ff0ef          	jal	ra,80001b9a <allocpid>
    80001d2e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d30:	4785                	li	a5,1
    80001d32:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d34:	e77fe0ef          	jal	ra,80000baa <kalloc>
    80001d38:	892a                	mv	s2,a0
    80001d3a:	eca8                	sd	a0,88(s1)
    80001d3c:	cd15                	beqz	a0,80001d78 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	e99ff0ef          	jal	ra,80001bd8 <proc_pagetable>
    80001d44:	892a                	mv	s2,a0
    80001d46:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d48:	c121                	beqz	a0,80001d88 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001d4a:	07000613          	li	a2,112
    80001d4e:	4581                	li	a1,0
    80001d50:	06048513          	addi	a0,s1,96
    80001d54:	820ff0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001d58:	00000797          	auipc	a5,0x0
    80001d5c:	daa78793          	addi	a5,a5,-598 # 80001b02 <forkret>
    80001d60:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d62:	60bc                	ld	a5,64(s1)
    80001d64:	6705                	lui	a4,0x1
    80001d66:	97ba                	add	a5,a5,a4
    80001d68:	f4bc                	sd	a5,104(s1)
}
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	60e2                	ld	ra,24(sp)
    80001d6e:	6442                	ld	s0,16(sp)
    80001d70:	64a2                	ld	s1,8(sp)
    80001d72:	6902                	ld	s2,0(sp)
    80001d74:	6105                	addi	sp,sp,32
    80001d76:	8082                	ret
    freeproc(p);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	f29ff0ef          	jal	ra,80001ca2 <freeproc>
    release(&p->lock);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fb9fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001d84:	84ca                	mv	s1,s2
    80001d86:	b7d5                	j	80001d6a <allocproc+0x78>
    freeproc(p);
    80001d88:	8526                	mv	a0,s1
    80001d8a:	f19ff0ef          	jal	ra,80001ca2 <freeproc>
    release(&p->lock);
    80001d8e:	8526                	mv	a0,s1
    80001d90:	fa9fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001d94:	84ca                	mv	s1,s2
    80001d96:	bfd1                	j	80001d6a <allocproc+0x78>

0000000080001d98 <userinit>:
{
    80001d98:	1101                	addi	sp,sp,-32
    80001d9a:	ec06                	sd	ra,24(sp)
    80001d9c:	e822                	sd	s0,16(sp)
    80001d9e:	e426                	sd	s1,8(sp)
    80001da0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001da2:	f51ff0ef          	jal	ra,80001cf2 <allocproc>
    80001da6:	84aa                	mv	s1,a0
  initproc = p;
    80001da8:	00006797          	auipc	a5,0x6
    80001dac:	aea7b423          	sd	a0,-1304(a5) # 80007890 <initproc>
  p->cwd = namei("/");
    80001db0:	00005517          	auipc	a0,0x5
    80001db4:	40050513          	addi	a0,a0,1024 # 800071b0 <digits+0x178>
    80001db8:	044020ef          	jal	ra,80003dfc <namei>
    80001dbc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dc0:	478d                	li	a5,3
    80001dc2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	f73fe0ef          	jal	ra,80000d38 <release>
}
    80001dca:	60e2                	ld	ra,24(sp)
    80001dcc:	6442                	ld	s0,16(sp)
    80001dce:	64a2                	ld	s1,8(sp)
    80001dd0:	6105                	addi	sp,sp,32
    80001dd2:	8082                	ret

0000000080001dd4 <growproc>:
{
    80001dd4:	1101                	addi	sp,sp,-32
    80001dd6:	ec06                	sd	ra,24(sp)
    80001dd8:	e822                	sd	s0,16(sp)
    80001dda:	e426                	sd	s1,8(sp)
    80001ddc:	e04a                	sd	s2,0(sp)
    80001dde:	1000                	addi	s0,sp,32
    80001de0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001de2:	cf1ff0ef          	jal	ra,80001ad2 <myproc>
    80001de6:	892a                	mv	s2,a0
  sz = p->sz;
    80001de8:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dea:	02905963          	blez	s1,80001e1c <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001dee:	00b48633          	add	a2,s1,a1
    80001df2:	020007b7          	lui	a5,0x2000
    80001df6:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001df8:	07b6                	slli	a5,a5,0xd
    80001dfa:	02c7ea63          	bltu	a5,a2,80001e2e <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dfe:	4691                	li	a3,4
    80001e00:	6928                	ld	a0,80(a0)
    80001e02:	d52ff0ef          	jal	ra,80001354 <uvmalloc>
    80001e06:	85aa                	mv	a1,a0
    80001e08:	c50d                	beqz	a0,80001e32 <growproc+0x5e>
  p->sz = sz;
    80001e0a:	04b93423          	sd	a1,72(s2)
  return 0;
    80001e0e:	4501                	li	a0,0
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6902                	ld	s2,0(sp)
    80001e18:	6105                	addi	sp,sp,32
    80001e1a:	8082                	ret
  } else if(n < 0){
    80001e1c:	fe04d7e3          	bgez	s1,80001e0a <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e20:	00b48633          	add	a2,s1,a1
    80001e24:	6928                	ld	a0,80(a0)
    80001e26:	ceaff0ef          	jal	ra,80001310 <uvmdealloc>
    80001e2a:	85aa                	mv	a1,a0
    80001e2c:	bff9                	j	80001e0a <growproc+0x36>
      return -1;
    80001e2e:	557d                	li	a0,-1
    80001e30:	b7c5                	j	80001e10 <growproc+0x3c>
      return -1;
    80001e32:	557d                	li	a0,-1
    80001e34:	bff1                	j	80001e10 <growproc+0x3c>

0000000080001e36 <kfork>:
{
    80001e36:	7139                	addi	sp,sp,-64
    80001e38:	fc06                	sd	ra,56(sp)
    80001e3a:	f822                	sd	s0,48(sp)
    80001e3c:	f426                	sd	s1,40(sp)
    80001e3e:	f04a                	sd	s2,32(sp)
    80001e40:	ec4e                	sd	s3,24(sp)
    80001e42:	e852                	sd	s4,16(sp)
    80001e44:	e456                	sd	s5,8(sp)
    80001e46:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e48:	c8bff0ef          	jal	ra,80001ad2 <myproc>
    80001e4c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e4e:	ea5ff0ef          	jal	ra,80001cf2 <allocproc>
    80001e52:	0e050663          	beqz	a0,80001f3e <kfork+0x108>
    80001e56:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e58:	048ab603          	ld	a2,72(s5)
    80001e5c:	692c                	ld	a1,80(a0)
    80001e5e:	050ab503          	ld	a0,80(s5)
    80001e62:	e1eff0ef          	jal	ra,80001480 <uvmcopy>
    80001e66:	04054863          	bltz	a0,80001eb6 <kfork+0x80>
  np->sz = p->sz;
    80001e6a:	048ab783          	ld	a5,72(s5)
    80001e6e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e72:	058ab683          	ld	a3,88(s5)
    80001e76:	87b6                	mv	a5,a3
    80001e78:	058a3703          	ld	a4,88(s4)
    80001e7c:	12068693          	addi	a3,a3,288
    80001e80:	0007b803          	ld	a6,0(a5)
    80001e84:	6788                	ld	a0,8(a5)
    80001e86:	6b8c                	ld	a1,16(a5)
    80001e88:	6f90                	ld	a2,24(a5)
    80001e8a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001e8e:	e708                	sd	a0,8(a4)
    80001e90:	eb0c                	sd	a1,16(a4)
    80001e92:	ef10                	sd	a2,24(a4)
    80001e94:	02078793          	addi	a5,a5,32
    80001e98:	02070713          	addi	a4,a4,32
    80001e9c:	fed792e3          	bne	a5,a3,80001e80 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001ea0:	058a3783          	ld	a5,88(s4)
    80001ea4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ea8:	0d0a8493          	addi	s1,s5,208
    80001eac:	0d0a0913          	addi	s2,s4,208
    80001eb0:	150a8993          	addi	s3,s5,336
    80001eb4:	a829                	j	80001ece <kfork+0x98>
    freeproc(np);
    80001eb6:	8552                	mv	a0,s4
    80001eb8:	debff0ef          	jal	ra,80001ca2 <freeproc>
    release(&np->lock);
    80001ebc:	8552                	mv	a0,s4
    80001ebe:	e7bfe0ef          	jal	ra,80000d38 <release>
    return -1;
    80001ec2:	597d                	li	s2,-1
    80001ec4:	a09d                	j	80001f2a <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001ec6:	04a1                	addi	s1,s1,8
    80001ec8:	0921                	addi	s2,s2,8
    80001eca:	01348963          	beq	s1,s3,80001edc <kfork+0xa6>
    if(p->ofile[i])
    80001ece:	6088                	ld	a0,0(s1)
    80001ed0:	d97d                	beqz	a0,80001ec6 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ed2:	4e2020ef          	jal	ra,800043b4 <filedup>
    80001ed6:	00a93023          	sd	a0,0(s2)
    80001eda:	b7f5                	j	80001ec6 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001edc:	150ab503          	ld	a0,336(s5)
    80001ee0:	6f2010ef          	jal	ra,800035d2 <idup>
    80001ee4:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ee8:	4641                	li	a2,16
    80001eea:	158a8593          	addi	a1,s5,344
    80001eee:	158a0513          	addi	a0,s4,344
    80001ef2:	fc9fe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    80001ef6:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001efa:	8552                	mv	a0,s4
    80001efc:	e3dfe0ef          	jal	ra,80000d38 <release>
  acquire(&wait_lock);
    80001f00:	0022e497          	auipc	s1,0x22e
    80001f04:	ac848493          	addi	s1,s1,-1336 # 8022f9c8 <wait_lock>
    80001f08:	8526                	mv	a0,s1
    80001f0a:	d97fe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    80001f0e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	e25fe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    80001f18:	8552                	mv	a0,s4
    80001f1a:	d87fe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    80001f1e:	478d                	li	a5,3
    80001f20:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f24:	8552                	mv	a0,s4
    80001f26:	e13fe0ef          	jal	ra,80000d38 <release>
}
    80001f2a:	854a                	mv	a0,s2
    80001f2c:	70e2                	ld	ra,56(sp)
    80001f2e:	7442                	ld	s0,48(sp)
    80001f30:	74a2                	ld	s1,40(sp)
    80001f32:	7902                	ld	s2,32(sp)
    80001f34:	69e2                	ld	s3,24(sp)
    80001f36:	6a42                	ld	s4,16(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	addi	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	b7ed                	j	80001f2a <kfork+0xf4>

0000000080001f42 <scheduler>:
{
    80001f42:	715d                	addi	sp,sp,-80
    80001f44:	e486                	sd	ra,72(sp)
    80001f46:	e0a2                	sd	s0,64(sp)
    80001f48:	fc26                	sd	s1,56(sp)
    80001f4a:	f84a                	sd	s2,48(sp)
    80001f4c:	f44e                	sd	s3,40(sp)
    80001f4e:	f052                	sd	s4,32(sp)
    80001f50:	ec56                	sd	s5,24(sp)
    80001f52:	e85a                	sd	s6,16(sp)
    80001f54:	e45e                	sd	s7,8(sp)
    80001f56:	e062                	sd	s8,0(sp)
    80001f58:	0880                	addi	s0,sp,80
    80001f5a:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5e:	00779b13          	slli	s6,a5,0x7
    80001f62:	0022e717          	auipc	a4,0x22e
    80001f66:	a4e70713          	addi	a4,a4,-1458 # 8022f9b0 <pid_lock>
    80001f6a:	975a                	add	a4,a4,s6
    80001f6c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f70:	0022e717          	auipc	a4,0x22e
    80001f74:	a7870713          	addi	a4,a4,-1416 # 8022f9e8 <cpus+0x8>
    80001f78:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f7a:	4c11                	li	s8,4
        c->proc = p;
    80001f7c:	079e                	slli	a5,a5,0x7
    80001f7e:	0022ea17          	auipc	s4,0x22e
    80001f82:	a32a0a13          	addi	s4,s4,-1486 # 8022f9b0 <pid_lock>
    80001f86:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f88:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f8a:	0023c997          	auipc	s3,0x23c
    80001f8e:	85698993          	addi	s3,s3,-1962 # 8023d7e0 <tickslock>
    80001f92:	a83d                	j	80001fd0 <scheduler+0x8e>
      release(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	da3fe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9a:	36848493          	addi	s1,s1,872
    80001f9e:	03348563          	beq	s1,s3,80001fc8 <scheduler+0x86>
      acquire(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	cfdfe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    80001fa8:	4c9c                	lw	a5,24(s1)
    80001faa:	ff2795e3          	bne	a5,s2,80001f94 <scheduler+0x52>
        p->state = RUNNING;
    80001fae:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fb2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fb6:	06048593          	addi	a1,s1,96
    80001fba:	855a                	mv	a0,s6
    80001fbc:	5b2000ef          	jal	ra,8000256e <swtch>
        c->proc = 0;
    80001fc0:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001fc4:	8ade                	mv	s5,s7
    80001fc6:	b7f9                	j	80001f94 <scheduler+0x52>
    if(found == 0) {
    80001fc8:	000a9463          	bnez	s5,80001fd0 <scheduler+0x8e>
      asm volatile("wfi");
    80001fcc:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fd4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd8:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fdc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001fe0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe2:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fe6:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe8:	0022e497          	auipc	s1,0x22e
    80001fec:	df848493          	addi	s1,s1,-520 # 8022fde0 <proc>
      if(p->state == RUNNABLE) {
    80001ff0:	490d                	li	s2,3
    80001ff2:	bf45                	j	80001fa2 <scheduler+0x60>

0000000080001ff4 <sched>:
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002002:	ad1ff0ef          	jal	ra,80001ad2 <myproc>
    80002006:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002008:	c2ffe0ef          	jal	ra,80000c36 <holding>
    8000200c:	c92d                	beqz	a0,8000207e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002010:	2781                	sext.w	a5,a5
    80002012:	079e                	slli	a5,a5,0x7
    80002014:	0022e717          	auipc	a4,0x22e
    80002018:	99c70713          	addi	a4,a4,-1636 # 8022f9b0 <pid_lock>
    8000201c:	97ba                	add	a5,a5,a4
    8000201e:	0a87a703          	lw	a4,168(a5)
    80002022:	4785                	li	a5,1
    80002024:	06f71363          	bne	a4,a5,8000208a <sched+0x96>
  if(p->state == RUNNING)
    80002028:	4c98                	lw	a4,24(s1)
    8000202a:	4791                	li	a5,4
    8000202c:	06f70563          	beq	a4,a5,80002096 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002030:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002034:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002036:	e7b5                	bnez	a5,800020a2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002038:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000203a:	0022e917          	auipc	s2,0x22e
    8000203e:	97690913          	addi	s2,s2,-1674 # 8022f9b0 <pid_lock>
    80002042:	2781                	sext.w	a5,a5
    80002044:	079e                	slli	a5,a5,0x7
    80002046:	97ca                	add	a5,a5,s2
    80002048:	0ac7a983          	lw	s3,172(a5)
    8000204c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204e:	2781                	sext.w	a5,a5
    80002050:	079e                	slli	a5,a5,0x7
    80002052:	0022e597          	auipc	a1,0x22e
    80002056:	99658593          	addi	a1,a1,-1642 # 8022f9e8 <cpus+0x8>
    8000205a:	95be                	add	a1,a1,a5
    8000205c:	06048513          	addi	a0,s1,96
    80002060:	50e000ef          	jal	ra,8000256e <swtch>
    80002064:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	993e                	add	s2,s2,a5
    8000206c:	0b392623          	sw	s3,172(s2)
}
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6942                	ld	s2,16(sp)
    80002078:	69a2                	ld	s3,8(sp)
    8000207a:	6145                	addi	sp,sp,48
    8000207c:	8082                	ret
    panic("sched p->lock");
    8000207e:	00005517          	auipc	a0,0x5
    80002082:	13a50513          	addi	a0,a0,314 # 800071b8 <digits+0x180>
    80002086:	f02fe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    8000208a:	00005517          	auipc	a0,0x5
    8000208e:	13e50513          	addi	a0,a0,318 # 800071c8 <digits+0x190>
    80002092:	ef6fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    80002096:	00005517          	auipc	a0,0x5
    8000209a:	14250513          	addi	a0,a0,322 # 800071d8 <digits+0x1a0>
    8000209e:	eeafe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    800020a2:	00005517          	auipc	a0,0x5
    800020a6:	14650513          	addi	a0,a0,326 # 800071e8 <digits+0x1b0>
    800020aa:	edefe0ef          	jal	ra,80000788 <panic>

00000000800020ae <yield>:
{
    800020ae:	1101                	addi	sp,sp,-32
    800020b0:	ec06                	sd	ra,24(sp)
    800020b2:	e822                	sd	s0,16(sp)
    800020b4:	e426                	sd	s1,8(sp)
    800020b6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020b8:	a1bff0ef          	jal	ra,80001ad2 <myproc>
    800020bc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020be:	be3fe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    800020c2:	478d                	li	a5,3
    800020c4:	cc9c                	sw	a5,24(s1)
  sched();
    800020c6:	f2fff0ef          	jal	ra,80001ff4 <sched>
  release(&p->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	c6dfe0ef          	jal	ra,80000d38 <release>
}
    800020d0:	60e2                	ld	ra,24(sp)
    800020d2:	6442                	ld	s0,16(sp)
    800020d4:	64a2                	ld	s1,8(sp)
    800020d6:	6105                	addi	sp,sp,32
    800020d8:	8082                	ret

00000000800020da <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020da:	7179                	addi	sp,sp,-48
    800020dc:	f406                	sd	ra,40(sp)
    800020de:	f022                	sd	s0,32(sp)
    800020e0:	ec26                	sd	s1,24(sp)
    800020e2:	e84a                	sd	s2,16(sp)
    800020e4:	e44e                	sd	s3,8(sp)
    800020e6:	1800                	addi	s0,sp,48
    800020e8:	89aa                	mv	s3,a0
    800020ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ec:	9e7ff0ef          	jal	ra,80001ad2 <myproc>
    800020f0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020f2:	baffe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    800020f6:	854a                	mv	a0,s2
    800020f8:	c41fe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    800020fc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002100:	4789                	li	a5,2
    80002102:	cc9c                	sw	a5,24(s1)

  sched();
    80002104:	ef1ff0ef          	jal	ra,80001ff4 <sched>

  // Tidy up.
  p->chan = 0;
    80002108:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	c2bfe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    80002112:	854a                	mv	a0,s2
    80002114:	b8dfe0ef          	jal	ra,80000ca0 <acquire>
}
    80002118:	70a2                	ld	ra,40(sp)
    8000211a:	7402                	ld	s0,32(sp)
    8000211c:	64e2                	ld	s1,24(sp)
    8000211e:	6942                	ld	s2,16(sp)
    80002120:	69a2                	ld	s3,8(sp)
    80002122:	6145                	addi	sp,sp,48
    80002124:	8082                	ret

0000000080002126 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002126:	7139                	addi	sp,sp,-64
    80002128:	fc06                	sd	ra,56(sp)
    8000212a:	f822                	sd	s0,48(sp)
    8000212c:	f426                	sd	s1,40(sp)
    8000212e:	f04a                	sd	s2,32(sp)
    80002130:	ec4e                	sd	s3,24(sp)
    80002132:	e852                	sd	s4,16(sp)
    80002134:	e456                	sd	s5,8(sp)
    80002136:	0080                	addi	s0,sp,64
    80002138:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000213a:	0022e497          	auipc	s1,0x22e
    8000213e:	ca648493          	addi	s1,s1,-858 # 8022fde0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002142:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002144:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002146:	0023b917          	auipc	s2,0x23b
    8000214a:	69a90913          	addi	s2,s2,1690 # 8023d7e0 <tickslock>
    8000214e:	a801                	j	8000215e <wakeup+0x38>
      }
      release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	be7fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002156:	36848493          	addi	s1,s1,872
    8000215a:	03248263          	beq	s1,s2,8000217e <wakeup+0x58>
    if(p != myproc()){
    8000215e:	975ff0ef          	jal	ra,80001ad2 <myproc>
    80002162:	fea48ae3          	beq	s1,a0,80002156 <wakeup+0x30>
      acquire(&p->lock);
    80002166:	8526                	mv	a0,s1
    80002168:	b39fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000216c:	4c9c                	lw	a5,24(s1)
    8000216e:	ff3791e3          	bne	a5,s3,80002150 <wakeup+0x2a>
    80002172:	709c                	ld	a5,32(s1)
    80002174:	fd479ee3          	bne	a5,s4,80002150 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002178:	0154ac23          	sw	s5,24(s1)
    8000217c:	bfd1                	j	80002150 <wakeup+0x2a>
    }
  }
}
    8000217e:	70e2                	ld	ra,56(sp)
    80002180:	7442                	ld	s0,48(sp)
    80002182:	74a2                	ld	s1,40(sp)
    80002184:	7902                	ld	s2,32(sp)
    80002186:	69e2                	ld	s3,24(sp)
    80002188:	6a42                	ld	s4,16(sp)
    8000218a:	6aa2                	ld	s5,8(sp)
    8000218c:	6121                	addi	sp,sp,64
    8000218e:	8082                	ret

0000000080002190 <reparent>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a2:	0022e497          	auipc	s1,0x22e
    800021a6:	c3e48493          	addi	s1,s1,-962 # 8022fde0 <proc>
      pp->parent = initproc;
    800021aa:	00005a17          	auipc	s4,0x5
    800021ae:	6e6a0a13          	addi	s4,s4,1766 # 80007890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b2:	0023b997          	auipc	s3,0x23b
    800021b6:	62e98993          	addi	s3,s3,1582 # 8023d7e0 <tickslock>
    800021ba:	a029                	j	800021c4 <reparent+0x34>
    800021bc:	36848493          	addi	s1,s1,872
    800021c0:	01348b63          	beq	s1,s3,800021d6 <reparent+0x46>
    if(pp->parent == p){
    800021c4:	7c9c                	ld	a5,56(s1)
    800021c6:	ff279be3          	bne	a5,s2,800021bc <reparent+0x2c>
      pp->parent = initproc;
    800021ca:	000a3503          	ld	a0,0(s4)
    800021ce:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021d0:	f57ff0ef          	jal	ra,80002126 <wakeup>
    800021d4:	b7e5                	j	800021bc <reparent+0x2c>
}
    800021d6:	70a2                	ld	ra,40(sp)
    800021d8:	7402                	ld	s0,32(sp)
    800021da:	64e2                	ld	s1,24(sp)
    800021dc:	6942                	ld	s2,16(sp)
    800021de:	69a2                	ld	s3,8(sp)
    800021e0:	6a02                	ld	s4,0(sp)
    800021e2:	6145                	addi	sp,sp,48
    800021e4:	8082                	ret

00000000800021e6 <kexit>:
{
    800021e6:	7179                	addi	sp,sp,-48
    800021e8:	f406                	sd	ra,40(sp)
    800021ea:	f022                	sd	s0,32(sp)
    800021ec:	ec26                	sd	s1,24(sp)
    800021ee:	e84a                	sd	s2,16(sp)
    800021f0:	e44e                	sd	s3,8(sp)
    800021f2:	e052                	sd	s4,0(sp)
    800021f4:	1800                	addi	s0,sp,48
    800021f6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021f8:	8dbff0ef          	jal	ra,80001ad2 <myproc>
    800021fc:	89aa                	mv	s3,a0
  if(p == initproc)
    800021fe:	00005797          	auipc	a5,0x5
    80002202:	6927b783          	ld	a5,1682(a5) # 80007890 <initproc>
    80002206:	0d050493          	addi	s1,a0,208
    8000220a:	15050913          	addi	s2,a0,336
    8000220e:	00a79f63          	bne	a5,a0,8000222c <kexit+0x46>
    panic("init exiting");
    80002212:	00005517          	auipc	a0,0x5
    80002216:	fee50513          	addi	a0,a0,-18 # 80007200 <digits+0x1c8>
    8000221a:	d6efe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    8000221e:	1dc020ef          	jal	ra,800043fa <fileclose>
      p->ofile[fd] = 0;
    80002222:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002226:	04a1                	addi	s1,s1,8
    80002228:	01248563          	beq	s1,s2,80002232 <kexit+0x4c>
    if(p->ofile[fd]){
    8000222c:	6088                	ld	a0,0(s1)
    8000222e:	f965                	bnez	a0,8000221e <kexit+0x38>
    80002230:	bfdd                	j	80002226 <kexit+0x40>
  begin_op();
    80002232:	5bf010ef          	jal	ra,80003ff0 <begin_op>
  iput(p->cwd);
    80002236:	1509b503          	ld	a0,336(s3)
    8000223a:	54c010ef          	jal	ra,80003786 <iput>
  end_op();
    8000223e:	621010ef          	jal	ra,8000405e <end_op>
  p->cwd = 0;
    80002242:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002246:	0022d497          	auipc	s1,0x22d
    8000224a:	78248493          	addi	s1,s1,1922 # 8022f9c8 <wait_lock>
    8000224e:	8526                	mv	a0,s1
    80002250:	a51fe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    80002254:	854e                	mv	a0,s3
    80002256:	f3bff0ef          	jal	ra,80002190 <reparent>
  wakeup(p->parent);
    8000225a:	0389b503          	ld	a0,56(s3)
    8000225e:	ec9ff0ef          	jal	ra,80002126 <wakeup>
  acquire(&p->lock);
    80002262:	854e                	mv	a0,s3
    80002264:	a3dfe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    80002268:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000226c:	4795                	li	a5,5
    8000226e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002272:	8526                	mv	a0,s1
    80002274:	ac5fe0ef          	jal	ra,80000d38 <release>
  sched();
    80002278:	d7dff0ef          	jal	ra,80001ff4 <sched>
  panic("zombie exit");
    8000227c:	00005517          	auipc	a0,0x5
    80002280:	f9450513          	addi	a0,a0,-108 # 80007210 <digits+0x1d8>
    80002284:	d04fe0ef          	jal	ra,80000788 <panic>

0000000080002288 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	1800                	addi	s0,sp,48
    80002296:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002298:	0022e497          	auipc	s1,0x22e
    8000229c:	b4848493          	addi	s1,s1,-1208 # 8022fde0 <proc>
    800022a0:	0023b997          	auipc	s3,0x23b
    800022a4:	54098993          	addi	s3,s3,1344 # 8023d7e0 <tickslock>
    acquire(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	9f7fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    800022ae:	589c                	lw	a5,48(s1)
    800022b0:	01278b63          	beq	a5,s2,800022c6 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	a83fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ba:	36848493          	addi	s1,s1,872
    800022be:	ff3495e3          	bne	s1,s3,800022a8 <kkill+0x20>
  }
  return -1;
    800022c2:	557d                	li	a0,-1
    800022c4:	a819                	j	800022da <kkill+0x52>
      p->killed = 1;
    800022c6:	4785                	li	a5,1
    800022c8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022ca:	4c98                	lw	a4,24(s1)
    800022cc:	4789                	li	a5,2
    800022ce:	00f70d63          	beq	a4,a5,800022e8 <kkill+0x60>
      release(&p->lock);
    800022d2:	8526                	mv	a0,s1
    800022d4:	a65fe0ef          	jal	ra,80000d38 <release>
      return 0;
    800022d8:	4501                	li	a0,0
}
    800022da:	70a2                	ld	ra,40(sp)
    800022dc:	7402                	ld	s0,32(sp)
    800022de:	64e2                	ld	s1,24(sp)
    800022e0:	6942                	ld	s2,16(sp)
    800022e2:	69a2                	ld	s3,8(sp)
    800022e4:	6145                	addi	sp,sp,48
    800022e6:	8082                	ret
        p->state = RUNNABLE;
    800022e8:	478d                	li	a5,3
    800022ea:	cc9c                	sw	a5,24(s1)
    800022ec:	b7dd                	j	800022d2 <kkill+0x4a>

00000000800022ee <setkilled>:

void
setkilled(struct proc *p)
{
    800022ee:	1101                	addi	sp,sp,-32
    800022f0:	ec06                	sd	ra,24(sp)
    800022f2:	e822                	sd	s0,16(sp)
    800022f4:	e426                	sd	s1,8(sp)
    800022f6:	1000                	addi	s0,sp,32
    800022f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022fa:	9a7fe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    800022fe:	4785                	li	a5,1
    80002300:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	a35fe0ef          	jal	ra,80000d38 <release>
}
    80002308:	60e2                	ld	ra,24(sp)
    8000230a:	6442                	ld	s0,16(sp)
    8000230c:	64a2                	ld	s1,8(sp)
    8000230e:	6105                	addi	sp,sp,32
    80002310:	8082                	ret

0000000080002312 <killed>:

int
killed(struct proc *p)
{
    80002312:	1101                	addi	sp,sp,-32
    80002314:	ec06                	sd	ra,24(sp)
    80002316:	e822                	sd	s0,16(sp)
    80002318:	e426                	sd	s1,8(sp)
    8000231a:	e04a                	sd	s2,0(sp)
    8000231c:	1000                	addi	s0,sp,32
    8000231e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002320:	981fe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    80002324:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	a0ffe0ef          	jal	ra,80000d38 <release>
  return k;
}
    8000232e:	854a                	mv	a0,s2
    80002330:	60e2                	ld	ra,24(sp)
    80002332:	6442                	ld	s0,16(sp)
    80002334:	64a2                	ld	s1,8(sp)
    80002336:	6902                	ld	s2,0(sp)
    80002338:	6105                	addi	sp,sp,32
    8000233a:	8082                	ret

000000008000233c <kwait>:
{
    8000233c:	715d                	addi	sp,sp,-80
    8000233e:	e486                	sd	ra,72(sp)
    80002340:	e0a2                	sd	s0,64(sp)
    80002342:	fc26                	sd	s1,56(sp)
    80002344:	f84a                	sd	s2,48(sp)
    80002346:	f44e                	sd	s3,40(sp)
    80002348:	f052                	sd	s4,32(sp)
    8000234a:	ec56                	sd	s5,24(sp)
    8000234c:	e85a                	sd	s6,16(sp)
    8000234e:	e45e                	sd	s7,8(sp)
    80002350:	e062                	sd	s8,0(sp)
    80002352:	0880                	addi	s0,sp,80
    80002354:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002356:	f7cff0ef          	jal	ra,80001ad2 <myproc>
    8000235a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000235c:	0022d517          	auipc	a0,0x22d
    80002360:	66c50513          	addi	a0,a0,1644 # 8022f9c8 <wait_lock>
    80002364:	93dfe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    80002368:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000236a:	4a15                	li	s4,5
        havekids = 1;
    8000236c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000236e:	0023b997          	auipc	s3,0x23b
    80002372:	47298993          	addi	s3,s3,1138 # 8023d7e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002376:	0022dc17          	auipc	s8,0x22d
    8000237a:	652c0c13          	addi	s8,s8,1618 # 8022f9c8 <wait_lock>
    havekids = 0;
    8000237e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002380:	0022e497          	auipc	s1,0x22e
    80002384:	a6048493          	addi	s1,s1,-1440 # 8022fde0 <proc>
    80002388:	a899                	j	800023de <kwait+0xa2>
          pid = pp->pid;
    8000238a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000238e:	000b0c63          	beqz	s6,800023a6 <kwait+0x6a>
    80002392:	4691                	li	a3,4
    80002394:	02c48613          	addi	a2,s1,44
    80002398:	85da                	mv	a1,s6
    8000239a:	05093503          	ld	a0,80(s2)
    8000239e:	bc0ff0ef          	jal	ra,8000175e <copyout>
    800023a2:	00054f63          	bltz	a0,800023c0 <kwait+0x84>
          freeproc(pp);
    800023a6:	8526                	mv	a0,s1
    800023a8:	8fbff0ef          	jal	ra,80001ca2 <freeproc>
          release(&pp->lock);
    800023ac:	8526                	mv	a0,s1
    800023ae:	98bfe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    800023b2:	0022d517          	auipc	a0,0x22d
    800023b6:	61650513          	addi	a0,a0,1558 # 8022f9c8 <wait_lock>
    800023ba:	97ffe0ef          	jal	ra,80000d38 <release>
          return pid;
    800023be:	a891                	j	80002412 <kwait+0xd6>
            release(&pp->lock);
    800023c0:	8526                	mv	a0,s1
    800023c2:	977fe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    800023c6:	0022d517          	auipc	a0,0x22d
    800023ca:	60250513          	addi	a0,a0,1538 # 8022f9c8 <wait_lock>
    800023ce:	96bfe0ef          	jal	ra,80000d38 <release>
            return -1;
    800023d2:	59fd                	li	s3,-1
    800023d4:	a83d                	j	80002412 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d6:	36848493          	addi	s1,s1,872
    800023da:	03348063          	beq	s1,s3,800023fa <kwait+0xbe>
      if(pp->parent == p){
    800023de:	7c9c                	ld	a5,56(s1)
    800023e0:	ff279be3          	bne	a5,s2,800023d6 <kwait+0x9a>
        acquire(&pp->lock);
    800023e4:	8526                	mv	a0,s1
    800023e6:	8bbfe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    800023ea:	4c9c                	lw	a5,24(s1)
    800023ec:	f9478fe3          	beq	a5,s4,8000238a <kwait+0x4e>
        release(&pp->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	947fe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    800023f6:	8756                	mv	a4,s5
    800023f8:	bff9                	j	800023d6 <kwait+0x9a>
    if(!havekids || killed(p)){
    800023fa:	c709                	beqz	a4,80002404 <kwait+0xc8>
    800023fc:	854a                	mv	a0,s2
    800023fe:	f15ff0ef          	jal	ra,80002312 <killed>
    80002402:	c50d                	beqz	a0,8000242c <kwait+0xf0>
      release(&wait_lock);
    80002404:	0022d517          	auipc	a0,0x22d
    80002408:	5c450513          	addi	a0,a0,1476 # 8022f9c8 <wait_lock>
    8000240c:	92dfe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002410:	59fd                	li	s3,-1
}
    80002412:	854e                	mv	a0,s3
    80002414:	60a6                	ld	ra,72(sp)
    80002416:	6406                	ld	s0,64(sp)
    80002418:	74e2                	ld	s1,56(sp)
    8000241a:	7942                	ld	s2,48(sp)
    8000241c:	79a2                	ld	s3,40(sp)
    8000241e:	7a02                	ld	s4,32(sp)
    80002420:	6ae2                	ld	s5,24(sp)
    80002422:	6b42                	ld	s6,16(sp)
    80002424:	6ba2                	ld	s7,8(sp)
    80002426:	6c02                	ld	s8,0(sp)
    80002428:	6161                	addi	sp,sp,80
    8000242a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000242c:	85e2                	mv	a1,s8
    8000242e:	854a                	mv	a0,s2
    80002430:	cabff0ef          	jal	ra,800020da <sleep>
    havekids = 0;
    80002434:	b7a9                	j	8000237e <kwait+0x42>

0000000080002436 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002436:	7179                	addi	sp,sp,-48
    80002438:	f406                	sd	ra,40(sp)
    8000243a:	f022                	sd	s0,32(sp)
    8000243c:	ec26                	sd	s1,24(sp)
    8000243e:	e84a                	sd	s2,16(sp)
    80002440:	e44e                	sd	s3,8(sp)
    80002442:	e052                	sd	s4,0(sp)
    80002444:	1800                	addi	s0,sp,48
    80002446:	84aa                	mv	s1,a0
    80002448:	892e                	mv	s2,a1
    8000244a:	89b2                	mv	s3,a2
    8000244c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000244e:	e84ff0ef          	jal	ra,80001ad2 <myproc>
  if(user_dst){
    80002452:	cc99                	beqz	s1,80002470 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002454:	86d2                	mv	a3,s4
    80002456:	864e                	mv	a2,s3
    80002458:	85ca                	mv	a1,s2
    8000245a:	6928                	ld	a0,80(a0)
    8000245c:	b02ff0ef          	jal	ra,8000175e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002460:	70a2                	ld	ra,40(sp)
    80002462:	7402                	ld	s0,32(sp)
    80002464:	64e2                	ld	s1,24(sp)
    80002466:	6942                	ld	s2,16(sp)
    80002468:	69a2                	ld	s3,8(sp)
    8000246a:	6a02                	ld	s4,0(sp)
    8000246c:	6145                	addi	sp,sp,48
    8000246e:	8082                	ret
    memmove((char *)dst, src, len);
    80002470:	000a061b          	sext.w	a2,s4
    80002474:	85ce                	mv	a1,s3
    80002476:	854a                	mv	a0,s2
    80002478:	959fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    8000247c:	8526                	mv	a0,s1
    8000247e:	b7cd                	j	80002460 <either_copyout+0x2a>

0000000080002480 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002480:	7179                	addi	sp,sp,-48
    80002482:	f406                	sd	ra,40(sp)
    80002484:	f022                	sd	s0,32(sp)
    80002486:	ec26                	sd	s1,24(sp)
    80002488:	e84a                	sd	s2,16(sp)
    8000248a:	e44e                	sd	s3,8(sp)
    8000248c:	e052                	sd	s4,0(sp)
    8000248e:	1800                	addi	s0,sp,48
    80002490:	892a                	mv	s2,a0
    80002492:	84ae                	mv	s1,a1
    80002494:	89b2                	mv	s3,a2
    80002496:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002498:	e3aff0ef          	jal	ra,80001ad2 <myproc>
  if(user_src){
    8000249c:	cc99                	beqz	s1,800024ba <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000249e:	86d2                	mv	a3,s4
    800024a0:	864e                	mv	a2,s3
    800024a2:	85ca                	mv	a1,s2
    800024a4:	6928                	ld	a0,80(a0)
    800024a6:	ba2ff0ef          	jal	ra,80001848 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024aa:	70a2                	ld	ra,40(sp)
    800024ac:	7402                	ld	s0,32(sp)
    800024ae:	64e2                	ld	s1,24(sp)
    800024b0:	6942                	ld	s2,16(sp)
    800024b2:	69a2                	ld	s3,8(sp)
    800024b4:	6a02                	ld	s4,0(sp)
    800024b6:	6145                	addi	sp,sp,48
    800024b8:	8082                	ret
    memmove(dst, (char*)src, len);
    800024ba:	000a061b          	sext.w	a2,s4
    800024be:	85ce                	mv	a1,s3
    800024c0:	854a                	mv	a0,s2
    800024c2:	90ffe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800024c6:	8526                	mv	a0,s1
    800024c8:	b7cd                	j	800024aa <either_copyin+0x2a>

00000000800024ca <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024ca:	715d                	addi	sp,sp,-80
    800024cc:	e486                	sd	ra,72(sp)
    800024ce:	e0a2                	sd	s0,64(sp)
    800024d0:	fc26                	sd	s1,56(sp)
    800024d2:	f84a                	sd	s2,48(sp)
    800024d4:	f44e                	sd	s3,40(sp)
    800024d6:	f052                	sd	s4,32(sp)
    800024d8:	ec56                	sd	s5,24(sp)
    800024da:	e85a                	sd	s6,16(sp)
    800024dc:	e45e                	sd	s7,8(sp)
    800024de:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024e0:	00005517          	auipc	a0,0x5
    800024e4:	be850513          	addi	a0,a0,-1048 # 800070c8 <digits+0x90>
    800024e8:	fdbfd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024ec:	0022e497          	auipc	s1,0x22e
    800024f0:	a4c48493          	addi	s1,s1,-1460 # 8022ff38 <proc+0x158>
    800024f4:	0023b917          	auipc	s2,0x23b
    800024f8:	44490913          	addi	s2,s2,1092 # 8023d938 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024fc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024fe:	00005997          	auipc	s3,0x5
    80002502:	d2298993          	addi	s3,s3,-734 # 80007220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    80002506:	00005a97          	auipc	s5,0x5
    8000250a:	d22a8a93          	addi	s5,s5,-734 # 80007228 <digits+0x1f0>
    printf("\n");
    8000250e:	00005a17          	auipc	s4,0x5
    80002512:	bbaa0a13          	addi	s4,s4,-1094 # 800070c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002516:	00005b97          	auipc	s7,0x5
    8000251a:	d52b8b93          	addi	s7,s7,-686 # 80007268 <states.0>
    8000251e:	a829                	j	80002538 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002520:	ed86a583          	lw	a1,-296(a3)
    80002524:	8556                	mv	a0,s5
    80002526:	f9dfd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    8000252a:	8552                	mv	a0,s4
    8000252c:	f97fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002530:	36848493          	addi	s1,s1,872
    80002534:	03248263          	beq	s1,s2,80002558 <procdump+0x8e>
    if(p->state == UNUSED)
    80002538:	86a6                	mv	a3,s1
    8000253a:	ec04a783          	lw	a5,-320(s1)
    8000253e:	dbed                	beqz	a5,80002530 <procdump+0x66>
      state = "???";
    80002540:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002542:	fcfb6fe3          	bltu	s6,a5,80002520 <procdump+0x56>
    80002546:	02079713          	slli	a4,a5,0x20
    8000254a:	01d75793          	srli	a5,a4,0x1d
    8000254e:	97de                	add	a5,a5,s7
    80002550:	6390                	ld	a2,0(a5)
    80002552:	f679                	bnez	a2,80002520 <procdump+0x56>
      state = "???";
    80002554:	864e                	mv	a2,s3
    80002556:	b7e9                	j	80002520 <procdump+0x56>
  }
}
    80002558:	60a6                	ld	ra,72(sp)
    8000255a:	6406                	ld	s0,64(sp)
    8000255c:	74e2                	ld	s1,56(sp)
    8000255e:	7942                	ld	s2,48(sp)
    80002560:	79a2                	ld	s3,40(sp)
    80002562:	7a02                	ld	s4,32(sp)
    80002564:	6ae2                	ld	s5,24(sp)
    80002566:	6b42                	ld	s6,16(sp)
    80002568:	6ba2                	ld	s7,8(sp)
    8000256a:	6161                	addi	sp,sp,80
    8000256c:	8082                	ret

000000008000256e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000256e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002572:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002576:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002578:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000257a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000257e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002582:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002586:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000258a:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000258e:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002592:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002596:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000259a:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000259e:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025a2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025a6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025aa:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025ac:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025ae:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025b2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025b6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025ba:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025be:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025c2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025c6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800025ca:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800025ce:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800025d2:	0685bd83          	ld	s11,104(a1)
        
        ret
    800025d6:	8082                	ret

00000000800025d8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025d8:	1141                	addi	sp,sp,-16
    800025da:	e406                	sd	ra,8(sp)
    800025dc:	e022                	sd	s0,0(sp)
    800025de:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025e0:	00005597          	auipc	a1,0x5
    800025e4:	cb858593          	addi	a1,a1,-840 # 80007298 <states.0+0x30>
    800025e8:	0023b517          	auipc	a0,0x23b
    800025ec:	1f850513          	addi	a0,a0,504 # 8023d7e0 <tickslock>
    800025f0:	e30fe0ef          	jal	ra,80000c20 <initlock>
}
    800025f4:	60a2                	ld	ra,8(sp)
    800025f6:	6402                	ld	s0,0(sp)
    800025f8:	0141                	addi	sp,sp,16
    800025fa:	8082                	ret

00000000800025fc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025fc:	1141                	addi	sp,sp,-16
    800025fe:	e422                	sd	s0,8(sp)
    80002600:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002602:	00003797          	auipc	a5,0x3
    80002606:	0be78793          	addi	a5,a5,190 # 800056c0 <kernelvec>
    8000260a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000260e:	6422                	ld	s0,8(sp)
    80002610:	0141                	addi	sp,sp,16
    80002612:	8082                	ret

0000000080002614 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002614:	1141                	addi	sp,sp,-16
    80002616:	e406                	sd	ra,8(sp)
    80002618:	e022                	sd	s0,0(sp)
    8000261a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000261c:	cb6ff0ef          	jal	ra,80001ad2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002620:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002624:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002626:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000262a:	04000737          	lui	a4,0x4000
    8000262e:	00004797          	auipc	a5,0x4
    80002632:	9d278793          	addi	a5,a5,-1582 # 80006000 <_trampoline>
    80002636:	00004697          	auipc	a3,0x4
    8000263a:	9ca68693          	addi	a3,a3,-1590 # 80006000 <_trampoline>
    8000263e:	8f95                	sub	a5,a5,a3
    80002640:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002642:	0732                	slli	a4,a4,0xc
    80002644:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002646:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000264a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000264c:	18002773          	csrr	a4,satp
    80002650:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002652:	6d38                	ld	a4,88(a0)
    80002654:	613c                	ld	a5,64(a0)
    80002656:	6685                	lui	a3,0x1
    80002658:	97b6                	add	a5,a5,a3
    8000265a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000265c:	6d3c                	ld	a5,88(a0)
    8000265e:	00000717          	auipc	a4,0x0
    80002662:	0f470713          	addi	a4,a4,244 # 80002752 <usertrap>
    80002666:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002668:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000266a:	8712                	mv	a4,tp
    8000266c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002672:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002676:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267a:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000267e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002680:	6f9c                	ld	a5,24(a5)
    80002682:	14179073          	csrw	sepc,a5
}
    80002686:	60a2                	ld	ra,8(sp)
    80002688:	6402                	ld	s0,0(sp)
    8000268a:	0141                	addi	sp,sp,16
    8000268c:	8082                	ret

000000008000268e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000268e:	1101                	addi	sp,sp,-32
    80002690:	ec06                	sd	ra,24(sp)
    80002692:	e822                	sd	s0,16(sp)
    80002694:	e426                	sd	s1,8(sp)
    80002696:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002698:	c0eff0ef          	jal	ra,80001aa6 <cpuid>
    8000269c:	cd19                	beqz	a0,800026ba <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000269e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026a2:	000f4737          	lui	a4,0xf4
    800026a6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026aa:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026ac:	14d79073          	csrw	0x14d,a5
}
    800026b0:	60e2                	ld	ra,24(sp)
    800026b2:	6442                	ld	s0,16(sp)
    800026b4:	64a2                	ld	s1,8(sp)
    800026b6:	6105                	addi	sp,sp,32
    800026b8:	8082                	ret
    acquire(&tickslock);
    800026ba:	0023b497          	auipc	s1,0x23b
    800026be:	12648493          	addi	s1,s1,294 # 8023d7e0 <tickslock>
    800026c2:	8526                	mv	a0,s1
    800026c4:	ddcfe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    800026c8:	00005517          	auipc	a0,0x5
    800026cc:	1d050513          	addi	a0,a0,464 # 80007898 <ticks>
    800026d0:	411c                	lw	a5,0(a0)
    800026d2:	2785                	addiw	a5,a5,1
    800026d4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800026d6:	a51ff0ef          	jal	ra,80002126 <wakeup>
    release(&tickslock);
    800026da:	8526                	mv	a0,s1
    800026dc:	e5cfe0ef          	jal	ra,80000d38 <release>
    800026e0:	bf7d                	j	8000269e <clockintr+0x10>

00000000800026e2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026e2:	1101                	addi	sp,sp,-32
    800026e4:	ec06                	sd	ra,24(sp)
    800026e6:	e822                	sd	s0,16(sp)
    800026e8:	e426                	sd	s1,8(sp)
    800026ea:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ec:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800026f0:	57fd                	li	a5,-1
    800026f2:	17fe                	slli	a5,a5,0x3f
    800026f4:	07a5                	addi	a5,a5,9
    800026f6:	00f70d63          	beq	a4,a5,80002710 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800026fa:	57fd                	li	a5,-1
    800026fc:	17fe                	slli	a5,a5,0x3f
    800026fe:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002700:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002702:	04f70463          	beq	a4,a5,8000274a <devintr+0x68>
  }
}
    80002706:	60e2                	ld	ra,24(sp)
    80002708:	6442                	ld	s0,16(sp)
    8000270a:	64a2                	ld	s1,8(sp)
    8000270c:	6105                	addi	sp,sp,32
    8000270e:	8082                	ret
    int irq = plic_claim();
    80002710:	058030ef          	jal	ra,80005768 <plic_claim>
    80002714:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002716:	47a9                	li	a5,10
    80002718:	02f50363          	beq	a0,a5,8000273e <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000271c:	4785                	li	a5,1
    8000271e:	02f50363          	beq	a0,a5,80002744 <devintr+0x62>
    return 1;
    80002722:	4505                	li	a0,1
    } else if(irq){
    80002724:	d0ed                	beqz	s1,80002706 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002726:	85a6                	mv	a1,s1
    80002728:	00005517          	auipc	a0,0x5
    8000272c:	b7850513          	addi	a0,a0,-1160 # 800072a0 <states.0+0x38>
    80002730:	d93fd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    80002734:	8526                	mv	a0,s1
    80002736:	052030ef          	jal	ra,80005788 <plic_complete>
    return 1;
    8000273a:	4505                	li	a0,1
    8000273c:	b7e9                	j	80002706 <devintr+0x24>
      uartintr();
    8000273e:	a16fe0ef          	jal	ra,80000954 <uartintr>
    80002742:	bfcd                	j	80002734 <devintr+0x52>
      virtio_disk_intr();
    80002744:	4b0030ef          	jal	ra,80005bf4 <virtio_disk_intr>
    80002748:	b7f5                	j	80002734 <devintr+0x52>
    clockintr();
    8000274a:	f45ff0ef          	jal	ra,8000268e <clockintr>
    return 2;
    8000274e:	4509                	li	a0,2
    80002750:	bf5d                	j	80002706 <devintr+0x24>

0000000080002752 <usertrap>:
{
    80002752:	7179                	addi	sp,sp,-48
    80002754:	f406                	sd	ra,40(sp)
    80002756:	f022                	sd	s0,32(sp)
    80002758:	ec26                	sd	s1,24(sp)
    8000275a:	e84a                	sd	s2,16(sp)
    8000275c:	e44e                	sd	s3,8(sp)
    8000275e:	e052                	sd	s4,0(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002766:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000276e:	1007f793          	andi	a5,a5,256
    80002772:	e3bd                	bnez	a5,800027d8 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002774:	00003797          	auipc	a5,0x3
    80002778:	f4c78793          	addi	a5,a5,-180 # 800056c0 <kernelvec>
    8000277c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002780:	b52ff0ef          	jal	ra,80001ad2 <myproc>
    80002784:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002786:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002788:	14102773          	csrr	a4,sepc
    8000278c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000278e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002792:	47a1                	li	a5,8
    80002794:	04f70863          	beq	a4,a5,800027e4 <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002798:	f4bff0ef          	jal	ra,800026e2 <devintr>
    8000279c:	892a                	mv	s2,a0
    8000279e:	0c051e63          	bnez	a0,8000287a <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    800027a2:	47b5                	li	a5,13
    800027a4:	08f98663          	beq	s3,a5,80002830 <usertrap+0xde>
    800027a8:	47bd                	li	a5,15
    800027aa:	0af99363          	bne	s3,a5,80002850 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    800027ae:	85d2                	mv	a1,s4
    800027b0:	68a8                	ld	a0,80(s1)
    800027b2:	d83fe0ef          	jal	ra,80001534 <cowbreak>
    800027b6:	c531                	beqz	a0,80002802 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    800027b8:	4605                	li	a2,1
    800027ba:	85d2                	mv	a1,s4
    800027bc:	8526                	mv	a0,s1
    800027be:	918ff0ef          	jal	ra,800018d6 <vmafault>
    800027c2:	e121                	bnez	a0,80002802 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    800027c4:	4601                	li	a2,0
    800027c6:	85d2                	mv	a1,s4
    800027c8:	68a8                	ld	a0,80(s1)
    800027ca:	f23fe0ef          	jal	ra,800016ec <vmfault>
    800027ce:	e915                	bnez	a0,80002802 <usertrap+0xb0>
        setkilled(p);
    800027d0:	8526                	mv	a0,s1
    800027d2:	b1dff0ef          	jal	ra,800022ee <setkilled>
    800027d6:	a035                	j	80002802 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    800027d8:	00005517          	auipc	a0,0x5
    800027dc:	ae850513          	addi	a0,a0,-1304 # 800072c0 <states.0+0x58>
    800027e0:	fa9fd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    800027e4:	b2fff0ef          	jal	ra,80002312 <killed>
    800027e8:	e121                	bnez	a0,80002828 <usertrap+0xd6>
    p->trapframe->epc += 4;
    800027ea:	6cb8                	ld	a4,88(s1)
    800027ec:	6f1c                	ld	a5,24(a4)
    800027ee:	0791                	addi	a5,a5,4
    800027f0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027fa:	10079073          	csrw	sstatus,a5
    syscall();
    800027fe:	27c000ef          	jal	ra,80002a7a <syscall>
  if(killed(p))
    80002802:	8526                	mv	a0,s1
    80002804:	b0fff0ef          	jal	ra,80002312 <killed>
    80002808:	ed35                	bnez	a0,80002884 <usertrap+0x132>
  prepare_return();
    8000280a:	e0bff0ef          	jal	ra,80002614 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000280e:	68a8                	ld	a0,80(s1)
    80002810:	8131                	srli	a0,a0,0xc
    80002812:	57fd                	li	a5,-1
    80002814:	17fe                	slli	a5,a5,0x3f
    80002816:	8d5d                	or	a0,a0,a5
}
    80002818:	70a2                	ld	ra,40(sp)
    8000281a:	7402                	ld	s0,32(sp)
    8000281c:	64e2                	ld	s1,24(sp)
    8000281e:	6942                	ld	s2,16(sp)
    80002820:	69a2                	ld	s3,8(sp)
    80002822:	6a02                	ld	s4,0(sp)
    80002824:	6145                	addi	sp,sp,48
    80002826:	8082                	ret
      kexit(-1);
    80002828:	557d                	li	a0,-1
    8000282a:	9bdff0ef          	jal	ra,800021e6 <kexit>
    8000282e:	bf75                	j	800027ea <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002830:	4601                	li	a2,0
    80002832:	85d2                	mv	a1,s4
    80002834:	8526                	mv	a0,s1
    80002836:	8a0ff0ef          	jal	ra,800018d6 <vmafault>
    8000283a:	f561                	bnez	a0,80002802 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    8000283c:	4605                	li	a2,1
    8000283e:	85d2                	mv	a1,s4
    80002840:	68a8                	ld	a0,80(s1)
    80002842:	eabfe0ef          	jal	ra,800016ec <vmfault>
    80002846:	fd55                	bnez	a0,80002802 <usertrap+0xb0>
        setkilled(p);
    80002848:	8526                	mv	a0,s1
    8000284a:	aa5ff0ef          	jal	ra,800022ee <setkilled>
    8000284e:	bf55                	j	80002802 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002850:	5890                	lw	a2,48(s1)
    80002852:	85ce                	mv	a1,s3
    80002854:	00005517          	auipc	a0,0x5
    80002858:	a8c50513          	addi	a0,a0,-1396 # 800072e0 <states.0+0x78>
    8000285c:	c67fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002860:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002864:	8652                	mv	a2,s4
    80002866:	00005517          	auipc	a0,0x5
    8000286a:	aaa50513          	addi	a0,a0,-1366 # 80007310 <states.0+0xa8>
    8000286e:	c55fd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002872:	8526                	mv	a0,s1
    80002874:	a7bff0ef          	jal	ra,800022ee <setkilled>
    80002878:	b769                	j	80002802 <usertrap+0xb0>
  if(killed(p))
    8000287a:	8526                	mv	a0,s1
    8000287c:	a97ff0ef          	jal	ra,80002312 <killed>
    80002880:	c511                	beqz	a0,8000288c <usertrap+0x13a>
    80002882:	a011                	j	80002886 <usertrap+0x134>
    80002884:	4901                	li	s2,0
    kexit(-1);
    80002886:	557d                	li	a0,-1
    80002888:	95fff0ef          	jal	ra,800021e6 <kexit>
  if(which_dev == 2)
    8000288c:	4789                	li	a5,2
    8000288e:	f6f91ee3          	bne	s2,a5,8000280a <usertrap+0xb8>
    yield();
    80002892:	81dff0ef          	jal	ra,800020ae <yield>
    80002896:	bf95                	j	8000280a <usertrap+0xb8>

0000000080002898 <kerneltrap>:
{
    80002898:	7179                	addi	sp,sp,-48
    8000289a:	f406                	sd	ra,40(sp)
    8000289c:	f022                	sd	s0,32(sp)
    8000289e:	ec26                	sd	s1,24(sp)
    800028a0:	e84a                	sd	s2,16(sp)
    800028a2:	e44e                	sd	s3,8(sp)
    800028a4:	1800                	addi	s0,sp,48
    800028a6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028aa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ae:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028b2:	1004f793          	andi	a5,s1,256
    800028b6:	c795                	beqz	a5,800028e2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028bc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028be:	eb85                	bnez	a5,800028ee <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800028c0:	e23ff0ef          	jal	ra,800026e2 <devintr>
    800028c4:	c91d                	beqz	a0,800028fa <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800028c6:	4789                	li	a5,2
    800028c8:	04f50a63          	beq	a0,a5,8000291c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028cc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d0:	10049073          	csrw	sstatus,s1
}
    800028d4:	70a2                	ld	ra,40(sp)
    800028d6:	7402                	ld	s0,32(sp)
    800028d8:	64e2                	ld	s1,24(sp)
    800028da:	6942                	ld	s2,16(sp)
    800028dc:	69a2                	ld	s3,8(sp)
    800028de:	6145                	addi	sp,sp,48
    800028e0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028e2:	00005517          	auipc	a0,0x5
    800028e6:	a5650513          	addi	a0,a0,-1450 # 80007338 <states.0+0xd0>
    800028ea:	e9ffd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    800028ee:	00005517          	auipc	a0,0x5
    800028f2:	a7250513          	addi	a0,a0,-1422 # 80007360 <states.0+0xf8>
    800028f6:	e93fd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fa:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028fe:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002902:	85ce                	mv	a1,s3
    80002904:	00005517          	auipc	a0,0x5
    80002908:	a7c50513          	addi	a0,a0,-1412 # 80007380 <states.0+0x118>
    8000290c:	bb7fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002910:	00005517          	auipc	a0,0x5
    80002914:	a9850513          	addi	a0,a0,-1384 # 800073a8 <states.0+0x140>
    80002918:	e71fd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000291c:	9b6ff0ef          	jal	ra,80001ad2 <myproc>
    80002920:	d555                	beqz	a0,800028cc <kerneltrap+0x34>
    yield();
    80002922:	f8cff0ef          	jal	ra,800020ae <yield>
    80002926:	b75d                	j	800028cc <kerneltrap+0x34>

0000000080002928 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002928:	1101                	addi	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	1000                	addi	s0,sp,32
    80002932:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002934:	99eff0ef          	jal	ra,80001ad2 <myproc>
  switch (n) {
    80002938:	4795                	li	a5,5
    8000293a:	0497e163          	bltu	a5,s1,8000297c <argraw+0x54>
    8000293e:	048a                	slli	s1,s1,0x2
    80002940:	00005717          	auipc	a4,0x5
    80002944:	aa070713          	addi	a4,a4,-1376 # 800073e0 <states.0+0x178>
    80002948:	94ba                	add	s1,s1,a4
    8000294a:	409c                	lw	a5,0(s1)
    8000294c:	97ba                	add	a5,a5,a4
    8000294e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002950:	6d3c                	ld	a5,88(a0)
    80002952:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002954:	60e2                	ld	ra,24(sp)
    80002956:	6442                	ld	s0,16(sp)
    80002958:	64a2                	ld	s1,8(sp)
    8000295a:	6105                	addi	sp,sp,32
    8000295c:	8082                	ret
    return p->trapframe->a1;
    8000295e:	6d3c                	ld	a5,88(a0)
    80002960:	7fa8                	ld	a0,120(a5)
    80002962:	bfcd                	j	80002954 <argraw+0x2c>
    return p->trapframe->a2;
    80002964:	6d3c                	ld	a5,88(a0)
    80002966:	63c8                	ld	a0,128(a5)
    80002968:	b7f5                	j	80002954 <argraw+0x2c>
    return p->trapframe->a3;
    8000296a:	6d3c                	ld	a5,88(a0)
    8000296c:	67c8                	ld	a0,136(a5)
    8000296e:	b7dd                	j	80002954 <argraw+0x2c>
    return p->trapframe->a4;
    80002970:	6d3c                	ld	a5,88(a0)
    80002972:	6bc8                	ld	a0,144(a5)
    80002974:	b7c5                	j	80002954 <argraw+0x2c>
    return p->trapframe->a5;
    80002976:	6d3c                	ld	a5,88(a0)
    80002978:	6fc8                	ld	a0,152(a5)
    8000297a:	bfe9                	j	80002954 <argraw+0x2c>
  panic("argraw");
    8000297c:	00005517          	auipc	a0,0x5
    80002980:	a3c50513          	addi	a0,a0,-1476 # 800073b8 <states.0+0x150>
    80002984:	e05fd0ef          	jal	ra,80000788 <panic>

0000000080002988 <fetchaddr>:
{
    80002988:	1101                	addi	sp,sp,-32
    8000298a:	ec06                	sd	ra,24(sp)
    8000298c:	e822                	sd	s0,16(sp)
    8000298e:	e426                	sd	s1,8(sp)
    80002990:	e04a                	sd	s2,0(sp)
    80002992:	1000                	addi	s0,sp,32
    80002994:	84aa                	mv	s1,a0
    80002996:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002998:	93aff0ef          	jal	ra,80001ad2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000299c:	653c                	ld	a5,72(a0)
    8000299e:	02f4f663          	bgeu	s1,a5,800029ca <fetchaddr+0x42>
    800029a2:	00848713          	addi	a4,s1,8
    800029a6:	02e7e463          	bltu	a5,a4,800029ce <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029aa:	46a1                	li	a3,8
    800029ac:	8626                	mv	a2,s1
    800029ae:	85ca                	mv	a1,s2
    800029b0:	6928                	ld	a0,80(a0)
    800029b2:	e97fe0ef          	jal	ra,80001848 <copyin>
    800029b6:	00a03533          	snez	a0,a0
    800029ba:	40a00533          	neg	a0,a0
}
    800029be:	60e2                	ld	ra,24(sp)
    800029c0:	6442                	ld	s0,16(sp)
    800029c2:	64a2                	ld	s1,8(sp)
    800029c4:	6902                	ld	s2,0(sp)
    800029c6:	6105                	addi	sp,sp,32
    800029c8:	8082                	ret
    return -1;
    800029ca:	557d                	li	a0,-1
    800029cc:	bfcd                	j	800029be <fetchaddr+0x36>
    800029ce:	557d                	li	a0,-1
    800029d0:	b7fd                	j	800029be <fetchaddr+0x36>

00000000800029d2 <fetchstr>:
{
    800029d2:	7179                	addi	sp,sp,-48
    800029d4:	f406                	sd	ra,40(sp)
    800029d6:	f022                	sd	s0,32(sp)
    800029d8:	ec26                	sd	s1,24(sp)
    800029da:	e84a                	sd	s2,16(sp)
    800029dc:	e44e                	sd	s3,8(sp)
    800029de:	1800                	addi	s0,sp,48
    800029e0:	892a                	mv	s2,a0
    800029e2:	84ae                	mv	s1,a1
    800029e4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029e6:	8ecff0ef          	jal	ra,80001ad2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029ea:	86ce                	mv	a3,s3
    800029ec:	864a                	mv	a2,s2
    800029ee:	85a6                	mv	a1,s1
    800029f0:	6928                	ld	a0,80(a0)
    800029f2:	c2ffe0ef          	jal	ra,80001620 <copyinstr>
    800029f6:	00054c63          	bltz	a0,80002a0e <fetchstr+0x3c>
  return strlen(buf);
    800029fa:	8526                	mv	a0,s1
    800029fc:	cf0fe0ef          	jal	ra,80000eec <strlen>
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6145                	addi	sp,sp,48
    80002a0c:	8082                	ret
    return -1;
    80002a0e:	557d                	li	a0,-1
    80002a10:	bfc5                	j	80002a00 <fetchstr+0x2e>

0000000080002a12 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a12:	1101                	addi	sp,sp,-32
    80002a14:	ec06                	sd	ra,24(sp)
    80002a16:	e822                	sd	s0,16(sp)
    80002a18:	e426                	sd	s1,8(sp)
    80002a1a:	1000                	addi	s0,sp,32
    80002a1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a1e:	f0bff0ef          	jal	ra,80002928 <argraw>
    80002a22:	c088                	sw	a0,0(s1)
}
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	64a2                	ld	s1,8(sp)
    80002a2a:	6105                	addi	sp,sp,32
    80002a2c:	8082                	ret

0000000080002a2e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a2e:	1101                	addi	sp,sp,-32
    80002a30:	ec06                	sd	ra,24(sp)
    80002a32:	e822                	sd	s0,16(sp)
    80002a34:	e426                	sd	s1,8(sp)
    80002a36:	1000                	addi	s0,sp,32
    80002a38:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a3a:	eefff0ef          	jal	ra,80002928 <argraw>
    80002a3e:	e088                	sd	a0,0(s1)
}
    80002a40:	60e2                	ld	ra,24(sp)
    80002a42:	6442                	ld	s0,16(sp)
    80002a44:	64a2                	ld	s1,8(sp)
    80002a46:	6105                	addi	sp,sp,32
    80002a48:	8082                	ret

0000000080002a4a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a4a:	7179                	addi	sp,sp,-48
    80002a4c:	f406                	sd	ra,40(sp)
    80002a4e:	f022                	sd	s0,32(sp)
    80002a50:	ec26                	sd	s1,24(sp)
    80002a52:	e84a                	sd	s2,16(sp)
    80002a54:	1800                	addi	s0,sp,48
    80002a56:	84ae                	mv	s1,a1
    80002a58:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a5a:	fd840593          	addi	a1,s0,-40
    80002a5e:	fd1ff0ef          	jal	ra,80002a2e <argaddr>
  return fetchstr(addr, buf, max);
    80002a62:	864a                	mv	a2,s2
    80002a64:	85a6                	mv	a1,s1
    80002a66:	fd843503          	ld	a0,-40(s0)
    80002a6a:	f69ff0ef          	jal	ra,800029d2 <fetchstr>
}
    80002a6e:	70a2                	ld	ra,40(sp)
    80002a70:	7402                	ld	s0,32(sp)
    80002a72:	64e2                	ld	s1,24(sp)
    80002a74:	6942                	ld	s2,16(sp)
    80002a76:	6145                	addi	sp,sp,48
    80002a78:	8082                	ret

0000000080002a7a <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002a7a:	1101                	addi	sp,sp,-32
    80002a7c:	ec06                	sd	ra,24(sp)
    80002a7e:	e822                	sd	s0,16(sp)
    80002a80:	e426                	sd	s1,8(sp)
    80002a82:	e04a                	sd	s2,0(sp)
    80002a84:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a86:	84cff0ef          	jal	ra,80001ad2 <myproc>
    80002a8a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a8c:	05853903          	ld	s2,88(a0)
    80002a90:	0a893783          	ld	a5,168(s2)
    80002a94:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a98:	37fd                	addiw	a5,a5,-1
    80002a9a:	4759                	li	a4,22
    80002a9c:	00f76f63          	bltu	a4,a5,80002aba <syscall+0x40>
    80002aa0:	00369713          	slli	a4,a3,0x3
    80002aa4:	00005797          	auipc	a5,0x5
    80002aa8:	95478793          	addi	a5,a5,-1708 # 800073f8 <syscalls>
    80002aac:	97ba                	add	a5,a5,a4
    80002aae:	639c                	ld	a5,0(a5)
    80002ab0:	c789                	beqz	a5,80002aba <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ab2:	9782                	jalr	a5
    80002ab4:	06a93823          	sd	a0,112(s2)
    80002ab8:	a829                	j	80002ad2 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002aba:	15848613          	addi	a2,s1,344
    80002abe:	588c                	lw	a1,48(s1)
    80002ac0:	00005517          	auipc	a0,0x5
    80002ac4:	90050513          	addi	a0,a0,-1792 # 800073c0 <states.0+0x158>
    80002ac8:	9fbfd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002acc:	6cbc                	ld	a5,88(s1)
    80002ace:	577d                	li	a4,-1
    80002ad0:	fbb8                	sd	a4,112(a5)
  }
}
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6902                	ld	s2,0(sp)
    80002ada:	6105                	addi	sp,sp,32
    80002adc:	8082                	ret

0000000080002ade <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002ade:	1101                	addi	sp,sp,-32
    80002ae0:	ec06                	sd	ra,24(sp)
    80002ae2:	e822                	sd	s0,16(sp)
    80002ae4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ae6:	fec40593          	addi	a1,s0,-20
    80002aea:	4501                	li	a0,0
    80002aec:	f27ff0ef          	jal	ra,80002a12 <argint>
  kexit(n);
    80002af0:	fec42503          	lw	a0,-20(s0)
    80002af4:	ef2ff0ef          	jal	ra,800021e6 <kexit>
  return 0;  // not reached
}
    80002af8:	4501                	li	a0,0
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret

0000000080002b02 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b02:	1141                	addi	sp,sp,-16
    80002b04:	e406                	sd	ra,8(sp)
    80002b06:	e022                	sd	s0,0(sp)
    80002b08:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b0a:	fc9fe0ef          	jal	ra,80001ad2 <myproc>
}
    80002b0e:	5908                	lw	a0,48(a0)
    80002b10:	60a2                	ld	ra,8(sp)
    80002b12:	6402                	ld	s0,0(sp)
    80002b14:	0141                	addi	sp,sp,16
    80002b16:	8082                	ret

0000000080002b18 <sys_fork>:

uint64
sys_fork(void)
{
    80002b18:	1141                	addi	sp,sp,-16
    80002b1a:	e406                	sd	ra,8(sp)
    80002b1c:	e022                	sd	s0,0(sp)
    80002b1e:	0800                	addi	s0,sp,16
  return kfork();
    80002b20:	b16ff0ef          	jal	ra,80001e36 <kfork>
}
    80002b24:	60a2                	ld	ra,8(sp)
    80002b26:	6402                	ld	s0,0(sp)
    80002b28:	0141                	addi	sp,sp,16
    80002b2a:	8082                	ret

0000000080002b2c <sys_wait>:

uint64
sys_wait(void)
{
    80002b2c:	1101                	addi	sp,sp,-32
    80002b2e:	ec06                	sd	ra,24(sp)
    80002b30:	e822                	sd	s0,16(sp)
    80002b32:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b34:	fe840593          	addi	a1,s0,-24
    80002b38:	4501                	li	a0,0
    80002b3a:	ef5ff0ef          	jal	ra,80002a2e <argaddr>
  return kwait(p);
    80002b3e:	fe843503          	ld	a0,-24(s0)
    80002b42:	ffaff0ef          	jal	ra,8000233c <kwait>
}
    80002b46:	60e2                	ld	ra,24(sp)
    80002b48:	6442                	ld	s0,16(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret

0000000080002b4e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b4e:	7179                	addi	sp,sp,-48
    80002b50:	f406                	sd	ra,40(sp)
    80002b52:	f022                	sd	s0,32(sp)
    80002b54:	ec26                	sd	s1,24(sp)
    80002b56:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b58:	fd840593          	addi	a1,s0,-40
    80002b5c:	4501                	li	a0,0
    80002b5e:	eb5ff0ef          	jal	ra,80002a12 <argint>
  argint(1, &t);
    80002b62:	fdc40593          	addi	a1,s0,-36
    80002b66:	4505                	li	a0,1
    80002b68:	eabff0ef          	jal	ra,80002a12 <argint>
  addr = myproc()->sz;
    80002b6c:	f67fe0ef          	jal	ra,80001ad2 <myproc>
    80002b70:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002b72:	fdc42703          	lw	a4,-36(s0)
    80002b76:	4785                	li	a5,1
    80002b78:	02f70763          	beq	a4,a5,80002ba6 <sys_sbrk+0x58>
    80002b7c:	fd842783          	lw	a5,-40(s0)
    80002b80:	0207c363          	bltz	a5,80002ba6 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002b84:	97a6                	add	a5,a5,s1
    80002b86:	0297ee63          	bltu	a5,s1,80002bc2 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002b8a:	02000737          	lui	a4,0x2000
    80002b8e:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b90:	0736                	slli	a4,a4,0xd
    80002b92:	02f76a63          	bltu	a4,a5,80002bc6 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002b96:	f3dfe0ef          	jal	ra,80001ad2 <myproc>
    80002b9a:	fd842703          	lw	a4,-40(s0)
    80002b9e:	653c                	ld	a5,72(a0)
    80002ba0:	97ba                	add	a5,a5,a4
    80002ba2:	e53c                	sd	a5,72(a0)
    80002ba4:	a039                	j	80002bb2 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002ba6:	fd842503          	lw	a0,-40(s0)
    80002baa:	a2aff0ef          	jal	ra,80001dd4 <growproc>
    80002bae:	00054863          	bltz	a0,80002bbe <sys_sbrk+0x70>
  }
  return addr;
}
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	70a2                	ld	ra,40(sp)
    80002bb6:	7402                	ld	s0,32(sp)
    80002bb8:	64e2                	ld	s1,24(sp)
    80002bba:	6145                	addi	sp,sp,48
    80002bbc:	8082                	ret
      return -1;
    80002bbe:	54fd                	li	s1,-1
    80002bc0:	bfcd                	j	80002bb2 <sys_sbrk+0x64>
      return -1;
    80002bc2:	54fd                	li	s1,-1
    80002bc4:	b7fd                	j	80002bb2 <sys_sbrk+0x64>
      return -1;
    80002bc6:	54fd                	li	s1,-1
    80002bc8:	b7ed                	j	80002bb2 <sys_sbrk+0x64>

0000000080002bca <sys_pause>:

uint64
sys_pause(void)
{
    80002bca:	7139                	addi	sp,sp,-64
    80002bcc:	fc06                	sd	ra,56(sp)
    80002bce:	f822                	sd	s0,48(sp)
    80002bd0:	f426                	sd	s1,40(sp)
    80002bd2:	f04a                	sd	s2,32(sp)
    80002bd4:	ec4e                	sd	s3,24(sp)
    80002bd6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bd8:	fcc40593          	addi	a1,s0,-52
    80002bdc:	4501                	li	a0,0
    80002bde:	e35ff0ef          	jal	ra,80002a12 <argint>
  if(n < 0)
    80002be2:	fcc42783          	lw	a5,-52(s0)
    80002be6:	0607c563          	bltz	a5,80002c50 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002bea:	0023b517          	auipc	a0,0x23b
    80002bee:	bf650513          	addi	a0,a0,-1034 # 8023d7e0 <tickslock>
    80002bf2:	8aefe0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002bf6:	00005917          	auipc	s2,0x5
    80002bfa:	ca292903          	lw	s2,-862(s2) # 80007898 <ticks>
  while(ticks - ticks0 < n){
    80002bfe:	fcc42783          	lw	a5,-52(s0)
    80002c02:	cb8d                	beqz	a5,80002c34 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c04:	0023b997          	auipc	s3,0x23b
    80002c08:	bdc98993          	addi	s3,s3,-1060 # 8023d7e0 <tickslock>
    80002c0c:	00005497          	auipc	s1,0x5
    80002c10:	c8c48493          	addi	s1,s1,-884 # 80007898 <ticks>
    if(killed(myproc())){
    80002c14:	ebffe0ef          	jal	ra,80001ad2 <myproc>
    80002c18:	efaff0ef          	jal	ra,80002312 <killed>
    80002c1c:	ed0d                	bnez	a0,80002c56 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c1e:	85ce                	mv	a1,s3
    80002c20:	8526                	mv	a0,s1
    80002c22:	cb8ff0ef          	jal	ra,800020da <sleep>
  while(ticks - ticks0 < n){
    80002c26:	409c                	lw	a5,0(s1)
    80002c28:	412787bb          	subw	a5,a5,s2
    80002c2c:	fcc42703          	lw	a4,-52(s0)
    80002c30:	fee7e2e3          	bltu	a5,a4,80002c14 <sys_pause+0x4a>
  }
  release(&tickslock);
    80002c34:	0023b517          	auipc	a0,0x23b
    80002c38:	bac50513          	addi	a0,a0,-1108 # 8023d7e0 <tickslock>
    80002c3c:	8fcfe0ef          	jal	ra,80000d38 <release>
  return 0;
    80002c40:	4501                	li	a0,0
}
    80002c42:	70e2                	ld	ra,56(sp)
    80002c44:	7442                	ld	s0,48(sp)
    80002c46:	74a2                	ld	s1,40(sp)
    80002c48:	7902                	ld	s2,32(sp)
    80002c4a:	69e2                	ld	s3,24(sp)
    80002c4c:	6121                	addi	sp,sp,64
    80002c4e:	8082                	ret
    n = 0;
    80002c50:	fc042623          	sw	zero,-52(s0)
    80002c54:	bf59                	j	80002bea <sys_pause+0x20>
      release(&tickslock);
    80002c56:	0023b517          	auipc	a0,0x23b
    80002c5a:	b8a50513          	addi	a0,a0,-1142 # 8023d7e0 <tickslock>
    80002c5e:	8dafe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002c62:	557d                	li	a0,-1
    80002c64:	bff9                	j	80002c42 <sys_pause+0x78>

0000000080002c66 <sys_kill>:

uint64
sys_kill(void)
{
    80002c66:	1101                	addi	sp,sp,-32
    80002c68:	ec06                	sd	ra,24(sp)
    80002c6a:	e822                	sd	s0,16(sp)
    80002c6c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c6e:	fec40593          	addi	a1,s0,-20
    80002c72:	4501                	li	a0,0
    80002c74:	d9fff0ef          	jal	ra,80002a12 <argint>
  return kkill(pid);
    80002c78:	fec42503          	lw	a0,-20(s0)
    80002c7c:	e0cff0ef          	jal	ra,80002288 <kkill>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	6105                	addi	sp,sp,32
    80002c86:	8082                	ret

0000000080002c88 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c88:	1101                	addi	sp,sp,-32
    80002c8a:	ec06                	sd	ra,24(sp)
    80002c8c:	e822                	sd	s0,16(sp)
    80002c8e:	e426                	sd	s1,8(sp)
    80002c90:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c92:	0023b517          	auipc	a0,0x23b
    80002c96:	b4e50513          	addi	a0,a0,-1202 # 8023d7e0 <tickslock>
    80002c9a:	806fe0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002c9e:	00005497          	auipc	s1,0x5
    80002ca2:	bfa4a483          	lw	s1,-1030(s1) # 80007898 <ticks>
  release(&tickslock);
    80002ca6:	0023b517          	auipc	a0,0x23b
    80002caa:	b3a50513          	addi	a0,a0,-1222 # 8023d7e0 <tickslock>
    80002cae:	88afe0ef          	jal	ra,80000d38 <release>
  return xticks;
}
    80002cb2:	02049513          	slli	a0,s1,0x20
    80002cb6:	9101                	srli	a0,a0,0x20
    80002cb8:	60e2                	ld	ra,24(sp)
    80002cba:	6442                	ld	s0,16(sp)
    80002cbc:	64a2                	ld	s1,8(sp)
    80002cbe:	6105                	addi	sp,sp,32
    80002cc0:	8082                	ret

0000000080002cc2 <vma_find>:
  return 0;
}

struct vma*
vma_find(struct proc *p, uint64 va)
{
    80002cc2:	1141                	addi	sp,sp,-16
    80002cc4:	e422                	sd	s0,8(sp)
    80002cc6:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002cc8:	16850793          	addi	a5,a0,360
    80002ccc:	4701                	li	a4,0
    80002cce:	4841                	li	a6,16
    80002cd0:	a031                	j	80002cdc <vma_find+0x1a>
    80002cd2:	2705                	addiw	a4,a4,1
    80002cd4:	02078793          	addi	a5,a5,32
    80002cd8:	01070f63          	beq	a4,a6,80002cf6 <vma_find+0x34>
    if(!p->vmas[i].used) continue;
    80002cdc:	4394                	lw	a3,0(a5)
    80002cde:	daf5                	beqz	a3,80002cd2 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    80002ce0:	6794                	ld	a3,8(a5)
    80002ce2:	fed5e8e3          	bltu	a1,a3,80002cd2 <vma_find+0x10>
    80002ce6:	6b94                	ld	a3,16(a5)
    80002ce8:	fed5f5e3          	bgeu	a1,a3,80002cd2 <vma_find+0x10>
      return &p->vmas[i];
    80002cec:	0716                	slli	a4,a4,0x5
    80002cee:	16870713          	addi	a4,a4,360
    80002cf2:	953a                	add	a0,a0,a4
    80002cf4:	a011                	j	80002cf8 <vma_find+0x36>
  }
  return 0;
    80002cf6:	4501                	li	a0,0
}
    80002cf8:	6422                	ld	s0,8(sp)
    80002cfa:	0141                	addi	sp,sp,16
    80002cfc:	8082                	ret

0000000080002cfe <sys_mmap>:

uint64
sys_mmap(void)
{
    80002cfe:	7179                	addi	sp,sp,-48
    80002d00:	f406                	sd	ra,40(sp)
    80002d02:	f022                	sd	s0,32(sp)
    80002d04:	1800                	addi	s0,sp,48
  uint64 addr;
  int len, prot, flags;

  argaddr(0, &addr);
    80002d06:	fe840593          	addi	a1,s0,-24
    80002d0a:	4501                	li	a0,0
    80002d0c:	d23ff0ef          	jal	ra,80002a2e <argaddr>
  argint(1, &len);
    80002d10:	fe440593          	addi	a1,s0,-28
    80002d14:	4505                	li	a0,1
    80002d16:	cfdff0ef          	jal	ra,80002a12 <argint>
  argint(2, &prot);
    80002d1a:	fe040593          	addi	a1,s0,-32
    80002d1e:	4509                	li	a0,2
    80002d20:	cf3ff0ef          	jal	ra,80002a12 <argint>
  argint(3, &flags);
    80002d24:	fdc40593          	addi	a1,s0,-36
    80002d28:	450d                	li	a0,3
    80002d2a:	ce9ff0ef          	jal	ra,80002a12 <argint>

  if(addr != 0) return (uint64)-1;
    80002d2e:	fe843783          	ld	a5,-24(s0)
    80002d32:	557d                	li	a0,-1
    80002d34:	e7f9                	bnez	a5,80002e02 <sys_mmap+0x104>
  if(len <= 0) return (uint64)-1;
    80002d36:	fe442783          	lw	a5,-28(s0)
    80002d3a:	08f05663          	blez	a5,80002dc6 <sys_mmap+0xc8>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    80002d3e:	fdc42783          	lw	a5,-36(s0)
    80002d42:	8b85                	andi	a5,a5,1
    80002d44:	cfdd                	beqz	a5,80002e02 <sys_mmap+0x104>
  if((prot & PROT_READ) == 0) return (uint64)-1; // 最小版：至少可读
    80002d46:	fe042783          	lw	a5,-32(s0)
    80002d4a:	8b85                	andi	a5,a5,1
    80002d4c:	cbdd                	beqz	a5,80002e02 <sys_mmap+0x104>

  struct proc *p = myproc();
    80002d4e:	d85fe0ef          	jal	ra,80001ad2 <myproc>
    80002d52:	8f2a                	mv	t5,a0
  uint64 plen = PGROUNDUP((uint64)len);
    80002d54:	fe442303          	lw	t1,-28(s0)
    80002d58:	6785                	lui	a5,0x1
    80002d5a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002d5c:	933e                	add	t1,t1,a5
    80002d5e:	77fd                	lui	a5,0xfffff
    80002d60:	00f37333          	and	t1,t1,a5
  for(int i = 0; i < NVMA; i++){
    80002d64:	16850e93          	addi	t4,a0,360
  uint64 plen = PGROUNDUP((uint64)len);
    80002d68:	87f6                	mv	a5,t4
  for(int i = 0; i < NVMA; i++){
    80002d6a:	4801                	li	a6,0
    80002d6c:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80002d6e:	4398                	lw	a4,0(a5)
    80002d70:	cb01                	beqz	a4,80002d80 <sys_mmap+0x82>
  for(int i = 0; i < NVMA; i++){
    80002d72:	2805                	addiw	a6,a6,1
    80002d74:	02078793          	addi	a5,a5,32 # fffffffffffff020 <end+0xffffffff7fdb6460>
    80002d78:	fed81be3          	bne	a6,a3,80002d6e <sys_mmap+0x70>

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80002d7c:	557d                	li	a0,-1
    80002d7e:	a051                	j	80002e02 <sys_mmap+0x104>
    uint64 end   = va + len;
    80002d80:	400005b7          	lui	a1,0x40000
    80002d84:	959a                	add	a1,a1,t1
    if(end >= MAXVA) return 0;
    80002d86:	57fd                	li	a5,-1
    80002d88:	83e9                	srli	a5,a5,0x1a
    80002d8a:	04b7e063          	bltu	a5,a1,80002dca <sys_mmap+0xcc>
    80002d8e:	40000537          	lui	a0,0x40000
    80002d92:	6885                	lui	a7,0x1
    80002d94:	368f0613          	addi	a2,t5,872
    80002d98:	8e3e                	mv	t3,a5
    80002d9a:	a025                	j	80002dc2 <sys_mmap+0xc4>
  for(int i = 0; i < NVMA; i++){
    80002d9c:	02078793          	addi	a5,a5,32
    80002da0:	02c78d63          	beq	a5,a2,80002dda <sys_mmap+0xdc>
    if(!p->vmas[i].used) continue;
    80002da4:	4398                	lw	a4,0(a5)
    80002da6:	db7d                	beqz	a4,80002d9c <sys_mmap+0x9e>
    if(!(end <= s || start >= e))
    80002da8:	6798                	ld	a4,8(a5)
    80002daa:	feb779e3          	bgeu	a4,a1,80002d9c <sys_mmap+0x9e>
    80002dae:	6b98                	ld	a4,16(a5)
    80002db0:	fee576e3          	bgeu	a0,a4,80002d9c <sys_mmap+0x9e>
  for(int tries = 0; tries < 4096; tries++){
    80002db4:	38fd                	addiw	a7,a7,-1 # fff <_entry-0x7ffff001>
    80002db6:	02088063          	beqz	a7,80002dd6 <sys_mmap+0xd8>
    uint64 end   = va + len;
    80002dba:	959a                	add	a1,a1,t1
    if(end >= MAXVA) return 0;
    80002dbc:	951a                	add	a0,a0,t1
    80002dbe:	00be6863          	bltu	t3,a1,80002dce <sys_mmap+0xd0>
    80002dc2:	87f6                	mv	a5,t4
    80002dc4:	b7c5                	j	80002da4 <sys_mmap+0xa6>
  if(len <= 0) return (uint64)-1;
    80002dc6:	557d                	li	a0,-1
    80002dc8:	a82d                	j	80002e02 <sys_mmap+0x104>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;
    80002dca:	557d                	li	a0,-1
    80002dcc:	a81d                	j	80002e02 <sys_mmap+0x104>
    80002dce:	557d                	li	a0,-1
    80002dd0:	a80d                	j	80002e02 <sys_mmap+0x104>
    80002dd2:	557d                	li	a0,-1
    80002dd4:	a03d                	j	80002e02 <sys_mmap+0x104>
    80002dd6:	557d                	li	a0,-1
    80002dd8:	a02d                	j	80002e02 <sys_mmap+0x104>
    80002dda:	dd65                	beqz	a0,80002dd2 <sys_mmap+0xd4>

  v->used = 1;
    80002ddc:	00581793          	slli	a5,a6,0x5
    80002de0:	97fa                	add	a5,a5,t5
    80002de2:	4705                	li	a4,1
    80002de4:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    80002de8:	16a7b823          	sd	a0,368(a5)
  v->end = va + plen;
    80002dec:	932a                	add	t1,t1,a0
    80002dee:	1667bc23          	sd	t1,376(a5)
  v->prot = prot;
    80002df2:	fe042703          	lw	a4,-32(s0)
    80002df6:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    80002dfa:	fdc42703          	lw	a4,-36(s0)
    80002dfe:	18e7a223          	sw	a4,388(a5)

  return va;
}
    80002e02:	70a2                	ld	ra,40(sp)
    80002e04:	7402                	ld	s0,32(sp)
    80002e06:	6145                	addi	sp,sp,48
    80002e08:	8082                	ret

0000000080002e0a <sys_munmap>:

uint64
sys_munmap(void)
{
    80002e0a:	7139                	addi	sp,sp,-64
    80002e0c:	fc06                	sd	ra,56(sp)
    80002e0e:	f822                	sd	s0,48(sp)
    80002e10:	f426                	sd	s1,40(sp)
    80002e12:	f04a                	sd	s2,32(sp)
    80002e14:	ec4e                	sd	s3,24(sp)
    80002e16:	e852                	sd	s4,16(sp)
    80002e18:	0080                	addi	s0,sp,64
  uint64 addr;
  int len;

  argaddr(0, &addr);
    80002e1a:	fc840593          	addi	a1,s0,-56
    80002e1e:	4501                	li	a0,0
    80002e20:	c0fff0ef          	jal	ra,80002a2e <argaddr>
  argint(1, &len);
    80002e24:	fc440593          	addi	a1,s0,-60
    80002e28:	4505                	li	a0,1
    80002e2a:	be9ff0ef          	jal	ra,80002a12 <argint>

  if(addr % PGSIZE != 0) return (uint64)-1;   // 要求页对齐
    80002e2e:	fc843783          	ld	a5,-56(s0)
    80002e32:	17d2                	slli	a5,a5,0x34
    80002e34:	59fd                	li	s3,-1
    80002e36:	e3a5                	bnez	a5,80002e96 <sys_munmap+0x8c>
    80002e38:	0347d993          	srli	s3,a5,0x34
  if(len <= 0) return (uint64)-1;
    80002e3c:	fc442783          	lw	a5,-60(s0)
    80002e40:	08f05763          	blez	a5,80002ece <sys_munmap+0xc4>

  struct proc *p = myproc();
    80002e44:	c8ffe0ef          	jal	ra,80001ad2 <myproc>
    80002e48:	892a                	mv	s2,a0
  uint64 plen = PGROUNDUP((uint64)len);
    80002e4a:	fc442603          	lw	a2,-60(s0)
    80002e4e:	6785                	lui	a5,0x1
    80002e50:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002e52:	963e                	add	a2,a2,a5
    80002e54:	77fd                	lui	a5,0xfffff
    80002e56:	00f67533          	and	a0,a2,a5
  // 找到起点匹配的 vma
  struct vma *v = 0;
  for(int i = 0; i < NVMA; i++){
    if(p->vmas[i].used && p->vmas[i].start == addr){
    80002e5a:	fc843583          	ld	a1,-56(s0)
    80002e5e:	16890793          	addi	a5,s2,360
  for(int i = 0; i < NVMA; i++){
    80002e62:	4481                	li	s1,0
    80002e64:	46c1                	li	a3,16
    80002e66:	a031                	j	80002e72 <sys_munmap+0x68>
    80002e68:	2485                	addiw	s1,s1,1
    80002e6a:	02078793          	addi	a5,a5,32 # fffffffffffff020 <end+0xffffffff7fdb6460>
    80002e6e:	02d48363          	beq	s1,a3,80002e94 <sys_munmap+0x8a>
    if(p->vmas[i].used && p->vmas[i].start == addr){
    80002e72:	4398                	lw	a4,0(a5)
    80002e74:	db75                	beqz	a4,80002e68 <sys_munmap+0x5e>
    80002e76:	6798                	ld	a4,8(a5)
    80002e78:	feb718e3          	bne	a4,a1,80002e68 <sys_munmap+0x5e>
      v = &p->vmas[i];
      break;
    }
  }
  if(v == 0) return (uint64)-1;
  if(plen != (v->end - v->start)) return (uint64)-1;
    80002e7c:	00549a13          	slli	s4,s1,0x5
    80002e80:	9a4a                	add	s4,s4,s2
    80002e82:	170a3583          	ld	a1,368(s4)
    80002e86:	178a3783          	ld	a5,376(s4)
    80002e8a:	8f8d                	sub	a5,a5,a1
    80002e8c:	00a78e63          	beq	a5,a0,80002ea8 <sys_munmap+0x9e>
    80002e90:	59fd                	li	s3,-1
    80002e92:	a011                	j	80002e96 <sys_munmap+0x8c>
  if(v == 0) return (uint64)-1;
    80002e94:	59fd                	li	s3,-1
  v->used = 0;
  v->start = v->end = 0;
  v->prot = v->flags = 0;

  return 0;
}
    80002e96:	854e                	mv	a0,s3
    80002e98:	70e2                	ld	ra,56(sp)
    80002e9a:	7442                	ld	s0,48(sp)
    80002e9c:	74a2                	ld	s1,40(sp)
    80002e9e:	7902                	ld	s2,32(sp)
    80002ea0:	69e2                	ld	s3,24(sp)
    80002ea2:	6a42                	ld	s4,16(sp)
    80002ea4:	6121                	addi	sp,sp,64
    80002ea6:	8082                	ret
  uvmunmap(p->pagetable, v->start, plen/PGSIZE, 1);
    80002ea8:	4685                	li	a3,1
    80002eaa:	8231                	srli	a2,a2,0xc
    80002eac:	05093503          	ld	a0,80(s2)
    80002eb0:	be4fe0ef          	jal	ra,80001294 <uvmunmap>
  v->used = 0;
    80002eb4:	160a2423          	sw	zero,360(s4)
  v->start = v->end = 0;
    80002eb8:	0496                	slli	s1,s1,0x5
    80002eba:	9926                	add	s2,s2,s1
    80002ebc:	16093c23          	sd	zero,376(s2)
    80002ec0:	160a3823          	sd	zero,368(s4)
  v->prot = v->flags = 0;
    80002ec4:	18092223          	sw	zero,388(s2)
    80002ec8:	18092023          	sw	zero,384(s2)
  return 0;
    80002ecc:	b7e9                	j	80002e96 <sys_munmap+0x8c>
  if(len <= 0) return (uint64)-1;
    80002ece:	59fd                	li	s3,-1
    80002ed0:	b7d9                	j	80002e96 <sys_munmap+0x8c>

0000000080002ed2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ed2:	7179                	addi	sp,sp,-48
    80002ed4:	f406                	sd	ra,40(sp)
    80002ed6:	f022                	sd	s0,32(sp)
    80002ed8:	ec26                	sd	s1,24(sp)
    80002eda:	e84a                	sd	s2,16(sp)
    80002edc:	e44e                	sd	s3,8(sp)
    80002ede:	e052                	sd	s4,0(sp)
    80002ee0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ee2:	00004597          	auipc	a1,0x4
    80002ee6:	5d658593          	addi	a1,a1,1494 # 800074b8 <syscalls+0xc0>
    80002eea:	0023b517          	auipc	a0,0x23b
    80002eee:	90e50513          	addi	a0,a0,-1778 # 8023d7f8 <bcache>
    80002ef2:	d2ffd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ef6:	00243797          	auipc	a5,0x243
    80002efa:	90278793          	addi	a5,a5,-1790 # 802457f8 <bcache+0x8000>
    80002efe:	00243717          	auipc	a4,0x243
    80002f02:	b6270713          	addi	a4,a4,-1182 # 80245a60 <bcache+0x8268>
    80002f06:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f0a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f0e:	0023b497          	auipc	s1,0x23b
    80002f12:	90248493          	addi	s1,s1,-1790 # 8023d810 <bcache+0x18>
    b->next = bcache.head.next;
    80002f16:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f18:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f1a:	00004a17          	auipc	s4,0x4
    80002f1e:	5a6a0a13          	addi	s4,s4,1446 # 800074c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f22:	2b893783          	ld	a5,696(s2)
    80002f26:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f28:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f2c:	85d2                	mv	a1,s4
    80002f2e:	01048513          	addi	a0,s1,16
    80002f32:	302010ef          	jal	ra,80004234 <initsleeplock>
    bcache.head.next->prev = b;
    80002f36:	2b893783          	ld	a5,696(s2)
    80002f3a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f3c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f40:	45848493          	addi	s1,s1,1112
    80002f44:	fd349fe3          	bne	s1,s3,80002f22 <binit+0x50>
  }
}
    80002f48:	70a2                	ld	ra,40(sp)
    80002f4a:	7402                	ld	s0,32(sp)
    80002f4c:	64e2                	ld	s1,24(sp)
    80002f4e:	6942                	ld	s2,16(sp)
    80002f50:	69a2                	ld	s3,8(sp)
    80002f52:	6a02                	ld	s4,0(sp)
    80002f54:	6145                	addi	sp,sp,48
    80002f56:	8082                	ret

0000000080002f58 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f58:	7179                	addi	sp,sp,-48
    80002f5a:	f406                	sd	ra,40(sp)
    80002f5c:	f022                	sd	s0,32(sp)
    80002f5e:	ec26                	sd	s1,24(sp)
    80002f60:	e84a                	sd	s2,16(sp)
    80002f62:	e44e                	sd	s3,8(sp)
    80002f64:	1800                	addi	s0,sp,48
    80002f66:	892a                	mv	s2,a0
    80002f68:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f6a:	0023b517          	auipc	a0,0x23b
    80002f6e:	88e50513          	addi	a0,a0,-1906 # 8023d7f8 <bcache>
    80002f72:	d2ffd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f76:	00243497          	auipc	s1,0x243
    80002f7a:	b3a4b483          	ld	s1,-1222(s1) # 80245ab0 <bcache+0x82b8>
    80002f7e:	00243797          	auipc	a5,0x243
    80002f82:	ae278793          	addi	a5,a5,-1310 # 80245a60 <bcache+0x8268>
    80002f86:	02f48b63          	beq	s1,a5,80002fbc <bread+0x64>
    80002f8a:	873e                	mv	a4,a5
    80002f8c:	a021                	j	80002f94 <bread+0x3c>
    80002f8e:	68a4                	ld	s1,80(s1)
    80002f90:	02e48663          	beq	s1,a4,80002fbc <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002f94:	449c                	lw	a5,8(s1)
    80002f96:	ff279ce3          	bne	a5,s2,80002f8e <bread+0x36>
    80002f9a:	44dc                	lw	a5,12(s1)
    80002f9c:	ff3799e3          	bne	a5,s3,80002f8e <bread+0x36>
      b->refcnt++;
    80002fa0:	40bc                	lw	a5,64(s1)
    80002fa2:	2785                	addiw	a5,a5,1
    80002fa4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fa6:	0023b517          	auipc	a0,0x23b
    80002faa:	85250513          	addi	a0,a0,-1966 # 8023d7f8 <bcache>
    80002fae:	d8bfd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80002fb2:	01048513          	addi	a0,s1,16
    80002fb6:	2b4010ef          	jal	ra,8000426a <acquiresleep>
      return b;
    80002fba:	a889                	j	8000300c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fbc:	00243497          	auipc	s1,0x243
    80002fc0:	aec4b483          	ld	s1,-1300(s1) # 80245aa8 <bcache+0x82b0>
    80002fc4:	00243797          	auipc	a5,0x243
    80002fc8:	a9c78793          	addi	a5,a5,-1380 # 80245a60 <bcache+0x8268>
    80002fcc:	00f48863          	beq	s1,a5,80002fdc <bread+0x84>
    80002fd0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fd2:	40bc                	lw	a5,64(s1)
    80002fd4:	cb91                	beqz	a5,80002fe8 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fd6:	64a4                	ld	s1,72(s1)
    80002fd8:	fee49de3          	bne	s1,a4,80002fd2 <bread+0x7a>
  panic("bget: no buffers");
    80002fdc:	00004517          	auipc	a0,0x4
    80002fe0:	4ec50513          	addi	a0,a0,1260 # 800074c8 <syscalls+0xd0>
    80002fe4:	fa4fd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80002fe8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fec:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ff0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ff4:	4785                	li	a5,1
    80002ff6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ff8:	0023b517          	auipc	a0,0x23b
    80002ffc:	80050513          	addi	a0,a0,-2048 # 8023d7f8 <bcache>
    80003000:	d39fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003004:	01048513          	addi	a0,s1,16
    80003008:	262010ef          	jal	ra,8000426a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000300c:	409c                	lw	a5,0(s1)
    8000300e:	cb89                	beqz	a5,80003020 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003010:	8526                	mv	a0,s1
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6942                	ld	s2,16(sp)
    8000301a:	69a2                	ld	s3,8(sp)
    8000301c:	6145                	addi	sp,sp,48
    8000301e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003020:	4581                	li	a1,0
    80003022:	8526                	mv	a0,s1
    80003024:	1b7020ef          	jal	ra,800059da <virtio_disk_rw>
    b->valid = 1;
    80003028:	4785                	li	a5,1
    8000302a:	c09c                	sw	a5,0(s1)
  return b;
    8000302c:	b7d5                	j	80003010 <bread+0xb8>

000000008000302e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	e426                	sd	s1,8(sp)
    80003036:	1000                	addi	s0,sp,32
    80003038:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000303a:	0541                	addi	a0,a0,16
    8000303c:	2ac010ef          	jal	ra,800042e8 <holdingsleep>
    80003040:	c911                	beqz	a0,80003054 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003042:	4585                	li	a1,1
    80003044:	8526                	mv	a0,s1
    80003046:	195020ef          	jal	ra,800059da <virtio_disk_rw>
}
    8000304a:	60e2                	ld	ra,24(sp)
    8000304c:	6442                	ld	s0,16(sp)
    8000304e:	64a2                	ld	s1,8(sp)
    80003050:	6105                	addi	sp,sp,32
    80003052:	8082                	ret
    panic("bwrite");
    80003054:	00004517          	auipc	a0,0x4
    80003058:	48c50513          	addi	a0,a0,1164 # 800074e0 <syscalls+0xe8>
    8000305c:	f2cfd0ef          	jal	ra,80000788 <panic>

0000000080003060 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003060:	1101                	addi	sp,sp,-32
    80003062:	ec06                	sd	ra,24(sp)
    80003064:	e822                	sd	s0,16(sp)
    80003066:	e426                	sd	s1,8(sp)
    80003068:	e04a                	sd	s2,0(sp)
    8000306a:	1000                	addi	s0,sp,32
    8000306c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306e:	01050913          	addi	s2,a0,16
    80003072:	854a                	mv	a0,s2
    80003074:	274010ef          	jal	ra,800042e8 <holdingsleep>
    80003078:	c13d                	beqz	a0,800030de <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000307a:	854a                	mv	a0,s2
    8000307c:	234010ef          	jal	ra,800042b0 <releasesleep>

  acquire(&bcache.lock);
    80003080:	0023a517          	auipc	a0,0x23a
    80003084:	77850513          	addi	a0,a0,1912 # 8023d7f8 <bcache>
    80003088:	c19fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    8000308c:	40bc                	lw	a5,64(s1)
    8000308e:	37fd                	addiw	a5,a5,-1
    80003090:	0007871b          	sext.w	a4,a5
    80003094:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003096:	eb05                	bnez	a4,800030c6 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003098:	68bc                	ld	a5,80(s1)
    8000309a:	64b8                	ld	a4,72(s1)
    8000309c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000309e:	64bc                	ld	a5,72(s1)
    800030a0:	68b8                	ld	a4,80(s1)
    800030a2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030a4:	00242797          	auipc	a5,0x242
    800030a8:	75478793          	addi	a5,a5,1876 # 802457f8 <bcache+0x8000>
    800030ac:	2b87b703          	ld	a4,696(a5)
    800030b0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030b2:	00243717          	auipc	a4,0x243
    800030b6:	9ae70713          	addi	a4,a4,-1618 # 80245a60 <bcache+0x8268>
    800030ba:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030bc:	2b87b703          	ld	a4,696(a5)
    800030c0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030c2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030c6:	0023a517          	auipc	a0,0x23a
    800030ca:	73250513          	addi	a0,a0,1842 # 8023d7f8 <bcache>
    800030ce:	c6bfd0ef          	jal	ra,80000d38 <release>
}
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	64a2                	ld	s1,8(sp)
    800030d8:	6902                	ld	s2,0(sp)
    800030da:	6105                	addi	sp,sp,32
    800030dc:	8082                	ret
    panic("brelse");
    800030de:	00004517          	auipc	a0,0x4
    800030e2:	40a50513          	addi	a0,a0,1034 # 800074e8 <syscalls+0xf0>
    800030e6:	ea2fd0ef          	jal	ra,80000788 <panic>

00000000800030ea <bpin>:

void
bpin(struct buf *b) {
    800030ea:	1101                	addi	sp,sp,-32
    800030ec:	ec06                	sd	ra,24(sp)
    800030ee:	e822                	sd	s0,16(sp)
    800030f0:	e426                	sd	s1,8(sp)
    800030f2:	1000                	addi	s0,sp,32
    800030f4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030f6:	0023a517          	auipc	a0,0x23a
    800030fa:	70250513          	addi	a0,a0,1794 # 8023d7f8 <bcache>
    800030fe:	ba3fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    80003102:	40bc                	lw	a5,64(s1)
    80003104:	2785                	addiw	a5,a5,1
    80003106:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003108:	0023a517          	auipc	a0,0x23a
    8000310c:	6f050513          	addi	a0,a0,1776 # 8023d7f8 <bcache>
    80003110:	c29fd0ef          	jal	ra,80000d38 <release>
}
    80003114:	60e2                	ld	ra,24(sp)
    80003116:	6442                	ld	s0,16(sp)
    80003118:	64a2                	ld	s1,8(sp)
    8000311a:	6105                	addi	sp,sp,32
    8000311c:	8082                	ret

000000008000311e <bunpin>:

void
bunpin(struct buf *b) {
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	1000                	addi	s0,sp,32
    80003128:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000312a:	0023a517          	auipc	a0,0x23a
    8000312e:	6ce50513          	addi	a0,a0,1742 # 8023d7f8 <bcache>
    80003132:	b6ffd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80003136:	40bc                	lw	a5,64(s1)
    80003138:	37fd                	addiw	a5,a5,-1
    8000313a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000313c:	0023a517          	auipc	a0,0x23a
    80003140:	6bc50513          	addi	a0,a0,1724 # 8023d7f8 <bcache>
    80003144:	bf5fd0ef          	jal	ra,80000d38 <release>
}
    80003148:	60e2                	ld	ra,24(sp)
    8000314a:	6442                	ld	s0,16(sp)
    8000314c:	64a2                	ld	s1,8(sp)
    8000314e:	6105                	addi	sp,sp,32
    80003150:	8082                	ret

0000000080003152 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003152:	1101                	addi	sp,sp,-32
    80003154:	ec06                	sd	ra,24(sp)
    80003156:	e822                	sd	s0,16(sp)
    80003158:	e426                	sd	s1,8(sp)
    8000315a:	e04a                	sd	s2,0(sp)
    8000315c:	1000                	addi	s0,sp,32
    8000315e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003160:	00d5d59b          	srliw	a1,a1,0xd
    80003164:	00243797          	auipc	a5,0x243
    80003168:	d707a783          	lw	a5,-656(a5) # 80245ed4 <sb+0x1c>
    8000316c:	9dbd                	addw	a1,a1,a5
    8000316e:	debff0ef          	jal	ra,80002f58 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003172:	0074f713          	andi	a4,s1,7
    80003176:	4785                	li	a5,1
    80003178:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000317c:	14ce                	slli	s1,s1,0x33
    8000317e:	90d9                	srli	s1,s1,0x36
    80003180:	00950733          	add	a4,a0,s1
    80003184:	05874703          	lbu	a4,88(a4)
    80003188:	00e7f6b3          	and	a3,a5,a4
    8000318c:	c29d                	beqz	a3,800031b2 <bfree+0x60>
    8000318e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003190:	94aa                	add	s1,s1,a0
    80003192:	fff7c793          	not	a5,a5
    80003196:	8f7d                	and	a4,a4,a5
    80003198:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000319c:	7d7000ef          	jal	ra,80004172 <log_write>
  brelse(bp);
    800031a0:	854a                	mv	a0,s2
    800031a2:	ebfff0ef          	jal	ra,80003060 <brelse>
}
    800031a6:	60e2                	ld	ra,24(sp)
    800031a8:	6442                	ld	s0,16(sp)
    800031aa:	64a2                	ld	s1,8(sp)
    800031ac:	6902                	ld	s2,0(sp)
    800031ae:	6105                	addi	sp,sp,32
    800031b0:	8082                	ret
    panic("freeing free block");
    800031b2:	00004517          	auipc	a0,0x4
    800031b6:	33e50513          	addi	a0,a0,830 # 800074f0 <syscalls+0xf8>
    800031ba:	dcefd0ef          	jal	ra,80000788 <panic>

00000000800031be <balloc>:
{
    800031be:	711d                	addi	sp,sp,-96
    800031c0:	ec86                	sd	ra,88(sp)
    800031c2:	e8a2                	sd	s0,80(sp)
    800031c4:	e4a6                	sd	s1,72(sp)
    800031c6:	e0ca                	sd	s2,64(sp)
    800031c8:	fc4e                	sd	s3,56(sp)
    800031ca:	f852                	sd	s4,48(sp)
    800031cc:	f456                	sd	s5,40(sp)
    800031ce:	f05a                	sd	s6,32(sp)
    800031d0:	ec5e                	sd	s7,24(sp)
    800031d2:	e862                	sd	s8,16(sp)
    800031d4:	e466                	sd	s9,8(sp)
    800031d6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031d8:	00243797          	auipc	a5,0x243
    800031dc:	ce47a783          	lw	a5,-796(a5) # 80245ebc <sb+0x4>
    800031e0:	cff1                	beqz	a5,800032bc <balloc+0xfe>
    800031e2:	8baa                	mv	s7,a0
    800031e4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031e6:	00243b17          	auipc	s6,0x243
    800031ea:	cd2b0b13          	addi	s6,s6,-814 # 80245eb8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ee:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031f0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031f2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031f4:	6c89                	lui	s9,0x2
    800031f6:	a0b5                	j	80003262 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031f8:	97ca                	add	a5,a5,s2
    800031fa:	8e55                	or	a2,a2,a3
    800031fc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003200:	854a                	mv	a0,s2
    80003202:	771000ef          	jal	ra,80004172 <log_write>
        brelse(bp);
    80003206:	854a                	mv	a0,s2
    80003208:	e59ff0ef          	jal	ra,80003060 <brelse>
  bp = bread(dev, bno);
    8000320c:	85a6                	mv	a1,s1
    8000320e:	855e                	mv	a0,s7
    80003210:	d49ff0ef          	jal	ra,80002f58 <bread>
    80003214:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003216:	40000613          	li	a2,1024
    8000321a:	4581                	li	a1,0
    8000321c:	05850513          	addi	a0,a0,88
    80003220:	b55fd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    80003224:	854a                	mv	a0,s2
    80003226:	74d000ef          	jal	ra,80004172 <log_write>
  brelse(bp);
    8000322a:	854a                	mv	a0,s2
    8000322c:	e35ff0ef          	jal	ra,80003060 <brelse>
}
    80003230:	8526                	mv	a0,s1
    80003232:	60e6                	ld	ra,88(sp)
    80003234:	6446                	ld	s0,80(sp)
    80003236:	64a6                	ld	s1,72(sp)
    80003238:	6906                	ld	s2,64(sp)
    8000323a:	79e2                	ld	s3,56(sp)
    8000323c:	7a42                	ld	s4,48(sp)
    8000323e:	7aa2                	ld	s5,40(sp)
    80003240:	7b02                	ld	s6,32(sp)
    80003242:	6be2                	ld	s7,24(sp)
    80003244:	6c42                	ld	s8,16(sp)
    80003246:	6ca2                	ld	s9,8(sp)
    80003248:	6125                	addi	sp,sp,96
    8000324a:	8082                	ret
    brelse(bp);
    8000324c:	854a                	mv	a0,s2
    8000324e:	e13ff0ef          	jal	ra,80003060 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003252:	015c87bb          	addw	a5,s9,s5
    80003256:	00078a9b          	sext.w	s5,a5
    8000325a:	004b2703          	lw	a4,4(s6)
    8000325e:	04eaff63          	bgeu	s5,a4,800032bc <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80003262:	41fad79b          	sraiw	a5,s5,0x1f
    80003266:	0137d79b          	srliw	a5,a5,0x13
    8000326a:	015787bb          	addw	a5,a5,s5
    8000326e:	40d7d79b          	sraiw	a5,a5,0xd
    80003272:	01cb2583          	lw	a1,28(s6)
    80003276:	9dbd                	addw	a1,a1,a5
    80003278:	855e                	mv	a0,s7
    8000327a:	cdfff0ef          	jal	ra,80002f58 <bread>
    8000327e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003280:	004b2503          	lw	a0,4(s6)
    80003284:	000a849b          	sext.w	s1,s5
    80003288:	8762                	mv	a4,s8
    8000328a:	fca4f1e3          	bgeu	s1,a0,8000324c <balloc+0x8e>
      m = 1 << (bi % 8);
    8000328e:	00777693          	andi	a3,a4,7
    80003292:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003296:	41f7579b          	sraiw	a5,a4,0x1f
    8000329a:	01d7d79b          	srliw	a5,a5,0x1d
    8000329e:	9fb9                	addw	a5,a5,a4
    800032a0:	4037d79b          	sraiw	a5,a5,0x3
    800032a4:	00f90633          	add	a2,s2,a5
    800032a8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800032ac:	00c6f5b3          	and	a1,a3,a2
    800032b0:	d5a1                	beqz	a1,800031f8 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b2:	2705                	addiw	a4,a4,1
    800032b4:	2485                	addiw	s1,s1,1
    800032b6:	fd471ae3          	bne	a4,s4,8000328a <balloc+0xcc>
    800032ba:	bf49                	j	8000324c <balloc+0x8e>
  printf("balloc: out of blocks\n");
    800032bc:	00004517          	auipc	a0,0x4
    800032c0:	24c50513          	addi	a0,a0,588 # 80007508 <syscalls+0x110>
    800032c4:	9fefd0ef          	jal	ra,800004c2 <printf>
  return 0;
    800032c8:	4481                	li	s1,0
    800032ca:	b79d                	j	80003230 <balloc+0x72>

00000000800032cc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032cc:	7179                	addi	sp,sp,-48
    800032ce:	f406                	sd	ra,40(sp)
    800032d0:	f022                	sd	s0,32(sp)
    800032d2:	ec26                	sd	s1,24(sp)
    800032d4:	e84a                	sd	s2,16(sp)
    800032d6:	e44e                	sd	s3,8(sp)
    800032d8:	e052                	sd	s4,0(sp)
    800032da:	1800                	addi	s0,sp,48
    800032dc:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032de:	47ad                	li	a5,11
    800032e0:	02b7e663          	bltu	a5,a1,8000330c <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    800032e4:	02059793          	slli	a5,a1,0x20
    800032e8:	01e7d593          	srli	a1,a5,0x1e
    800032ec:	00b504b3          	add	s1,a0,a1
    800032f0:	0504a903          	lw	s2,80(s1)
    800032f4:	06091663          	bnez	s2,80003360 <bmap+0x94>
      addr = balloc(ip->dev);
    800032f8:	4108                	lw	a0,0(a0)
    800032fa:	ec5ff0ef          	jal	ra,800031be <balloc>
    800032fe:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003302:	04090f63          	beqz	s2,80003360 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80003306:	0524a823          	sw	s2,80(s1)
    8000330a:	a899                	j	80003360 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000330c:	ff45849b          	addiw	s1,a1,-12
    80003310:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003314:	0ff00793          	li	a5,255
    80003318:	06e7eb63          	bltu	a5,a4,8000338e <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000331c:	08052903          	lw	s2,128(a0)
    80003320:	00091b63          	bnez	s2,80003336 <bmap+0x6a>
      addr = balloc(ip->dev);
    80003324:	4108                	lw	a0,0(a0)
    80003326:	e99ff0ef          	jal	ra,800031be <balloc>
    8000332a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000332e:	02090963          	beqz	s2,80003360 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003332:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003336:	85ca                	mv	a1,s2
    80003338:	0009a503          	lw	a0,0(s3)
    8000333c:	c1dff0ef          	jal	ra,80002f58 <bread>
    80003340:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003342:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003346:	02049713          	slli	a4,s1,0x20
    8000334a:	01e75593          	srli	a1,a4,0x1e
    8000334e:	00b784b3          	add	s1,a5,a1
    80003352:	0004a903          	lw	s2,0(s1)
    80003356:	00090e63          	beqz	s2,80003372 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000335a:	8552                	mv	a0,s4
    8000335c:	d05ff0ef          	jal	ra,80003060 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003360:	854a                	mv	a0,s2
    80003362:	70a2                	ld	ra,40(sp)
    80003364:	7402                	ld	s0,32(sp)
    80003366:	64e2                	ld	s1,24(sp)
    80003368:	6942                	ld	s2,16(sp)
    8000336a:	69a2                	ld	s3,8(sp)
    8000336c:	6a02                	ld	s4,0(sp)
    8000336e:	6145                	addi	sp,sp,48
    80003370:	8082                	ret
      addr = balloc(ip->dev);
    80003372:	0009a503          	lw	a0,0(s3)
    80003376:	e49ff0ef          	jal	ra,800031be <balloc>
    8000337a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000337e:	fc090ee3          	beqz	s2,8000335a <bmap+0x8e>
        a[bn] = addr;
    80003382:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003386:	8552                	mv	a0,s4
    80003388:	5eb000ef          	jal	ra,80004172 <log_write>
    8000338c:	b7f9                	j	8000335a <bmap+0x8e>
  panic("bmap: out of range");
    8000338e:	00004517          	auipc	a0,0x4
    80003392:	19250513          	addi	a0,a0,402 # 80007520 <syscalls+0x128>
    80003396:	bf2fd0ef          	jal	ra,80000788 <panic>

000000008000339a <iget>:
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
    800033ac:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033ae:	00243517          	auipc	a0,0x243
    800033b2:	b2a50513          	addi	a0,a0,-1238 # 80245ed8 <itable>
    800033b6:	8ebfd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    800033ba:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033bc:	00243497          	auipc	s1,0x243
    800033c0:	b3448493          	addi	s1,s1,-1228 # 80245ef0 <itable+0x18>
    800033c4:	00244697          	auipc	a3,0x244
    800033c8:	5bc68693          	addi	a3,a3,1468 # 80247980 <log>
    800033cc:	a039                	j	800033da <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ce:	02090963          	beqz	s2,80003400 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033d2:	08848493          	addi	s1,s1,136
    800033d6:	02d48863          	beq	s1,a3,80003406 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033da:	449c                	lw	a5,8(s1)
    800033dc:	fef059e3          	blez	a5,800033ce <iget+0x34>
    800033e0:	4098                	lw	a4,0(s1)
    800033e2:	ff3716e3          	bne	a4,s3,800033ce <iget+0x34>
    800033e6:	40d8                	lw	a4,4(s1)
    800033e8:	ff4713e3          	bne	a4,s4,800033ce <iget+0x34>
      ip->ref++;
    800033ec:	2785                	addiw	a5,a5,1
    800033ee:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033f0:	00243517          	auipc	a0,0x243
    800033f4:	ae850513          	addi	a0,a0,-1304 # 80245ed8 <itable>
    800033f8:	941fd0ef          	jal	ra,80000d38 <release>
      return ip;
    800033fc:	8926                	mv	s2,s1
    800033fe:	a02d                	j	80003428 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003400:	fbe9                	bnez	a5,800033d2 <iget+0x38>
    80003402:	8926                	mv	s2,s1
    80003404:	b7f9                	j	800033d2 <iget+0x38>
  if(empty == 0)
    80003406:	02090a63          	beqz	s2,8000343a <iget+0xa0>
  ip->dev = dev;
    8000340a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000340e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003412:	4785                	li	a5,1
    80003414:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003418:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000341c:	00243517          	auipc	a0,0x243
    80003420:	abc50513          	addi	a0,a0,-1348 # 80245ed8 <itable>
    80003424:	915fd0ef          	jal	ra,80000d38 <release>
}
    80003428:	854a                	mv	a0,s2
    8000342a:	70a2                	ld	ra,40(sp)
    8000342c:	7402                	ld	s0,32(sp)
    8000342e:	64e2                	ld	s1,24(sp)
    80003430:	6942                	ld	s2,16(sp)
    80003432:	69a2                	ld	s3,8(sp)
    80003434:	6a02                	ld	s4,0(sp)
    80003436:	6145                	addi	sp,sp,48
    80003438:	8082                	ret
    panic("iget: no inodes");
    8000343a:	00004517          	auipc	a0,0x4
    8000343e:	0fe50513          	addi	a0,a0,254 # 80007538 <syscalls+0x140>
    80003442:	b46fd0ef          	jal	ra,80000788 <panic>

0000000080003446 <iinit>:
{
    80003446:	7179                	addi	sp,sp,-48
    80003448:	f406                	sd	ra,40(sp)
    8000344a:	f022                	sd	s0,32(sp)
    8000344c:	ec26                	sd	s1,24(sp)
    8000344e:	e84a                	sd	s2,16(sp)
    80003450:	e44e                	sd	s3,8(sp)
    80003452:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003454:	00004597          	auipc	a1,0x4
    80003458:	0f458593          	addi	a1,a1,244 # 80007548 <syscalls+0x150>
    8000345c:	00243517          	auipc	a0,0x243
    80003460:	a7c50513          	addi	a0,a0,-1412 # 80245ed8 <itable>
    80003464:	fbcfd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003468:	00243497          	auipc	s1,0x243
    8000346c:	a9848493          	addi	s1,s1,-1384 # 80245f00 <itable+0x28>
    80003470:	00244997          	auipc	s3,0x244
    80003474:	52098993          	addi	s3,s3,1312 # 80247990 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003478:	00004917          	auipc	s2,0x4
    8000347c:	0d890913          	addi	s2,s2,216 # 80007550 <syscalls+0x158>
    80003480:	85ca                	mv	a1,s2
    80003482:	8526                	mv	a0,s1
    80003484:	5b1000ef          	jal	ra,80004234 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003488:	08848493          	addi	s1,s1,136
    8000348c:	ff349ae3          	bne	s1,s3,80003480 <iinit+0x3a>
}
    80003490:	70a2                	ld	ra,40(sp)
    80003492:	7402                	ld	s0,32(sp)
    80003494:	64e2                	ld	s1,24(sp)
    80003496:	6942                	ld	s2,16(sp)
    80003498:	69a2                	ld	s3,8(sp)
    8000349a:	6145                	addi	sp,sp,48
    8000349c:	8082                	ret

000000008000349e <ialloc>:
{
    8000349e:	715d                	addi	sp,sp,-80
    800034a0:	e486                	sd	ra,72(sp)
    800034a2:	e0a2                	sd	s0,64(sp)
    800034a4:	fc26                	sd	s1,56(sp)
    800034a6:	f84a                	sd	s2,48(sp)
    800034a8:	f44e                	sd	s3,40(sp)
    800034aa:	f052                	sd	s4,32(sp)
    800034ac:	ec56                	sd	s5,24(sp)
    800034ae:	e85a                	sd	s6,16(sp)
    800034b0:	e45e                	sd	s7,8(sp)
    800034b2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800034b4:	00243717          	auipc	a4,0x243
    800034b8:	a1072703          	lw	a4,-1520(a4) # 80245ec4 <sb+0xc>
    800034bc:	4785                	li	a5,1
    800034be:	04e7f663          	bgeu	a5,a4,8000350a <ialloc+0x6c>
    800034c2:	8aaa                	mv	s5,a0
    800034c4:	8bae                	mv	s7,a1
    800034c6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034c8:	00243a17          	auipc	s4,0x243
    800034cc:	9f0a0a13          	addi	s4,s4,-1552 # 80245eb8 <sb>
    800034d0:	00048b1b          	sext.w	s6,s1
    800034d4:	0044d593          	srli	a1,s1,0x4
    800034d8:	018a2783          	lw	a5,24(s4)
    800034dc:	9dbd                	addw	a1,a1,a5
    800034de:	8556                	mv	a0,s5
    800034e0:	a79ff0ef          	jal	ra,80002f58 <bread>
    800034e4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034e6:	05850993          	addi	s3,a0,88
    800034ea:	00f4f793          	andi	a5,s1,15
    800034ee:	079a                	slli	a5,a5,0x6
    800034f0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034f2:	00099783          	lh	a5,0(s3)
    800034f6:	cf85                	beqz	a5,8000352e <ialloc+0x90>
    brelse(bp);
    800034f8:	b69ff0ef          	jal	ra,80003060 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034fc:	0485                	addi	s1,s1,1
    800034fe:	00ca2703          	lw	a4,12(s4)
    80003502:	0004879b          	sext.w	a5,s1
    80003506:	fce7e5e3          	bltu	a5,a4,800034d0 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000350a:	00004517          	auipc	a0,0x4
    8000350e:	04e50513          	addi	a0,a0,78 # 80007558 <syscalls+0x160>
    80003512:	fb1fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003516:	4501                	li	a0,0
}
    80003518:	60a6                	ld	ra,72(sp)
    8000351a:	6406                	ld	s0,64(sp)
    8000351c:	74e2                	ld	s1,56(sp)
    8000351e:	7942                	ld	s2,48(sp)
    80003520:	79a2                	ld	s3,40(sp)
    80003522:	7a02                	ld	s4,32(sp)
    80003524:	6ae2                	ld	s5,24(sp)
    80003526:	6b42                	ld	s6,16(sp)
    80003528:	6ba2                	ld	s7,8(sp)
    8000352a:	6161                	addi	sp,sp,80
    8000352c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000352e:	04000613          	li	a2,64
    80003532:	4581                	li	a1,0
    80003534:	854e                	mv	a0,s3
    80003536:	83ffd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    8000353a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000353e:	854a                	mv	a0,s2
    80003540:	433000ef          	jal	ra,80004172 <log_write>
      brelse(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	b1bff0ef          	jal	ra,80003060 <brelse>
      return iget(dev, inum);
    8000354a:	85da                	mv	a1,s6
    8000354c:	8556                	mv	a0,s5
    8000354e:	e4dff0ef          	jal	ra,8000339a <iget>
    80003552:	b7d9                	j	80003518 <ialloc+0x7a>

0000000080003554 <iupdate>:
{
    80003554:	1101                	addi	sp,sp,-32
    80003556:	ec06                	sd	ra,24(sp)
    80003558:	e822                	sd	s0,16(sp)
    8000355a:	e426                	sd	s1,8(sp)
    8000355c:	e04a                	sd	s2,0(sp)
    8000355e:	1000                	addi	s0,sp,32
    80003560:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003562:	415c                	lw	a5,4(a0)
    80003564:	0047d79b          	srliw	a5,a5,0x4
    80003568:	00243597          	auipc	a1,0x243
    8000356c:	9685a583          	lw	a1,-1688(a1) # 80245ed0 <sb+0x18>
    80003570:	9dbd                	addw	a1,a1,a5
    80003572:	4108                	lw	a0,0(a0)
    80003574:	9e5ff0ef          	jal	ra,80002f58 <bread>
    80003578:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000357a:	05850793          	addi	a5,a0,88
    8000357e:	40d8                	lw	a4,4(s1)
    80003580:	8b3d                	andi	a4,a4,15
    80003582:	071a                	slli	a4,a4,0x6
    80003584:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003586:	04449703          	lh	a4,68(s1)
    8000358a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000358e:	04649703          	lh	a4,70(s1)
    80003592:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003596:	04849703          	lh	a4,72(s1)
    8000359a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000359e:	04a49703          	lh	a4,74(s1)
    800035a2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035a6:	44f8                	lw	a4,76(s1)
    800035a8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035aa:	03400613          	li	a2,52
    800035ae:	05048593          	addi	a1,s1,80
    800035b2:	00c78513          	addi	a0,a5,12
    800035b6:	81bfd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    800035ba:	854a                	mv	a0,s2
    800035bc:	3b7000ef          	jal	ra,80004172 <log_write>
  brelse(bp);
    800035c0:	854a                	mv	a0,s2
    800035c2:	a9fff0ef          	jal	ra,80003060 <brelse>
}
    800035c6:	60e2                	ld	ra,24(sp)
    800035c8:	6442                	ld	s0,16(sp)
    800035ca:	64a2                	ld	s1,8(sp)
    800035cc:	6902                	ld	s2,0(sp)
    800035ce:	6105                	addi	sp,sp,32
    800035d0:	8082                	ret

00000000800035d2 <idup>:
{
    800035d2:	1101                	addi	sp,sp,-32
    800035d4:	ec06                	sd	ra,24(sp)
    800035d6:	e822                	sd	s0,16(sp)
    800035d8:	e426                	sd	s1,8(sp)
    800035da:	1000                	addi	s0,sp,32
    800035dc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035de:	00243517          	auipc	a0,0x243
    800035e2:	8fa50513          	addi	a0,a0,-1798 # 80245ed8 <itable>
    800035e6:	ebafd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    800035ea:	449c                	lw	a5,8(s1)
    800035ec:	2785                	addiw	a5,a5,1
    800035ee:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035f0:	00243517          	auipc	a0,0x243
    800035f4:	8e850513          	addi	a0,a0,-1816 # 80245ed8 <itable>
    800035f8:	f40fd0ef          	jal	ra,80000d38 <release>
}
    800035fc:	8526                	mv	a0,s1
    800035fe:	60e2                	ld	ra,24(sp)
    80003600:	6442                	ld	s0,16(sp)
    80003602:	64a2                	ld	s1,8(sp)
    80003604:	6105                	addi	sp,sp,32
    80003606:	8082                	ret

0000000080003608 <ilock>:
{
    80003608:	1101                	addi	sp,sp,-32
    8000360a:	ec06                	sd	ra,24(sp)
    8000360c:	e822                	sd	s0,16(sp)
    8000360e:	e426                	sd	s1,8(sp)
    80003610:	e04a                	sd	s2,0(sp)
    80003612:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003614:	c105                	beqz	a0,80003634 <ilock+0x2c>
    80003616:	84aa                	mv	s1,a0
    80003618:	451c                	lw	a5,8(a0)
    8000361a:	00f05d63          	blez	a5,80003634 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000361e:	0541                	addi	a0,a0,16
    80003620:	44b000ef          	jal	ra,8000426a <acquiresleep>
  if(ip->valid == 0){
    80003624:	40bc                	lw	a5,64(s1)
    80003626:	cf89                	beqz	a5,80003640 <ilock+0x38>
}
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	64a2                	ld	s1,8(sp)
    8000362e:	6902                	ld	s2,0(sp)
    80003630:	6105                	addi	sp,sp,32
    80003632:	8082                	ret
    panic("ilock");
    80003634:	00004517          	auipc	a0,0x4
    80003638:	f3c50513          	addi	a0,a0,-196 # 80007570 <syscalls+0x178>
    8000363c:	94cfd0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003640:	40dc                	lw	a5,4(s1)
    80003642:	0047d79b          	srliw	a5,a5,0x4
    80003646:	00243597          	auipc	a1,0x243
    8000364a:	88a5a583          	lw	a1,-1910(a1) # 80245ed0 <sb+0x18>
    8000364e:	9dbd                	addw	a1,a1,a5
    80003650:	4088                	lw	a0,0(s1)
    80003652:	907ff0ef          	jal	ra,80002f58 <bread>
    80003656:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003658:	05850593          	addi	a1,a0,88
    8000365c:	40dc                	lw	a5,4(s1)
    8000365e:	8bbd                	andi	a5,a5,15
    80003660:	079a                	slli	a5,a5,0x6
    80003662:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003664:	00059783          	lh	a5,0(a1)
    80003668:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000366c:	00259783          	lh	a5,2(a1)
    80003670:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003674:	00459783          	lh	a5,4(a1)
    80003678:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000367c:	00659783          	lh	a5,6(a1)
    80003680:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003684:	459c                	lw	a5,8(a1)
    80003686:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003688:	03400613          	li	a2,52
    8000368c:	05b1                	addi	a1,a1,12
    8000368e:	05048513          	addi	a0,s1,80
    80003692:	f3efd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	9c9ff0ef          	jal	ra,80003060 <brelse>
    ip->valid = 1;
    8000369c:	4785                	li	a5,1
    8000369e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036a0:	04449783          	lh	a5,68(s1)
    800036a4:	f3d1                	bnez	a5,80003628 <ilock+0x20>
      panic("ilock: no type");
    800036a6:	00004517          	auipc	a0,0x4
    800036aa:	ed250513          	addi	a0,a0,-302 # 80007578 <syscalls+0x180>
    800036ae:	8dafd0ef          	jal	ra,80000788 <panic>

00000000800036b2 <iunlock>:
{
    800036b2:	1101                	addi	sp,sp,-32
    800036b4:	ec06                	sd	ra,24(sp)
    800036b6:	e822                	sd	s0,16(sp)
    800036b8:	e426                	sd	s1,8(sp)
    800036ba:	e04a                	sd	s2,0(sp)
    800036bc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800036be:	c505                	beqz	a0,800036e6 <iunlock+0x34>
    800036c0:	84aa                	mv	s1,a0
    800036c2:	01050913          	addi	s2,a0,16
    800036c6:	854a                	mv	a0,s2
    800036c8:	421000ef          	jal	ra,800042e8 <holdingsleep>
    800036cc:	cd09                	beqz	a0,800036e6 <iunlock+0x34>
    800036ce:	449c                	lw	a5,8(s1)
    800036d0:	00f05b63          	blez	a5,800036e6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800036d4:	854a                	mv	a0,s2
    800036d6:	3db000ef          	jal	ra,800042b0 <releasesleep>
}
    800036da:	60e2                	ld	ra,24(sp)
    800036dc:	6442                	ld	s0,16(sp)
    800036de:	64a2                	ld	s1,8(sp)
    800036e0:	6902                	ld	s2,0(sp)
    800036e2:	6105                	addi	sp,sp,32
    800036e4:	8082                	ret
    panic("iunlock");
    800036e6:	00004517          	auipc	a0,0x4
    800036ea:	ea250513          	addi	a0,a0,-350 # 80007588 <syscalls+0x190>
    800036ee:	89afd0ef          	jal	ra,80000788 <panic>

00000000800036f2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036f2:	7179                	addi	sp,sp,-48
    800036f4:	f406                	sd	ra,40(sp)
    800036f6:	f022                	sd	s0,32(sp)
    800036f8:	ec26                	sd	s1,24(sp)
    800036fa:	e84a                	sd	s2,16(sp)
    800036fc:	e44e                	sd	s3,8(sp)
    800036fe:	e052                	sd	s4,0(sp)
    80003700:	1800                	addi	s0,sp,48
    80003702:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003704:	05050493          	addi	s1,a0,80
    80003708:	08050913          	addi	s2,a0,128
    8000370c:	a021                	j	80003714 <itrunc+0x22>
    8000370e:	0491                	addi	s1,s1,4
    80003710:	01248b63          	beq	s1,s2,80003726 <itrunc+0x34>
    if(ip->addrs[i]){
    80003714:	408c                	lw	a1,0(s1)
    80003716:	dde5                	beqz	a1,8000370e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003718:	0009a503          	lw	a0,0(s3)
    8000371c:	a37ff0ef          	jal	ra,80003152 <bfree>
      ip->addrs[i] = 0;
    80003720:	0004a023          	sw	zero,0(s1)
    80003724:	b7ed                	j	8000370e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003726:	0809a583          	lw	a1,128(s3)
    8000372a:	ed91                	bnez	a1,80003746 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000372c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003730:	854e                	mv	a0,s3
    80003732:	e23ff0ef          	jal	ra,80003554 <iupdate>
}
    80003736:	70a2                	ld	ra,40(sp)
    80003738:	7402                	ld	s0,32(sp)
    8000373a:	64e2                	ld	s1,24(sp)
    8000373c:	6942                	ld	s2,16(sp)
    8000373e:	69a2                	ld	s3,8(sp)
    80003740:	6a02                	ld	s4,0(sp)
    80003742:	6145                	addi	sp,sp,48
    80003744:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003746:	0009a503          	lw	a0,0(s3)
    8000374a:	80fff0ef          	jal	ra,80002f58 <bread>
    8000374e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003750:	05850493          	addi	s1,a0,88
    80003754:	45850913          	addi	s2,a0,1112
    80003758:	a021                	j	80003760 <itrunc+0x6e>
    8000375a:	0491                	addi	s1,s1,4
    8000375c:	01248963          	beq	s1,s2,8000376e <itrunc+0x7c>
      if(a[j])
    80003760:	408c                	lw	a1,0(s1)
    80003762:	dde5                	beqz	a1,8000375a <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003764:	0009a503          	lw	a0,0(s3)
    80003768:	9ebff0ef          	jal	ra,80003152 <bfree>
    8000376c:	b7fd                	j	8000375a <itrunc+0x68>
    brelse(bp);
    8000376e:	8552                	mv	a0,s4
    80003770:	8f1ff0ef          	jal	ra,80003060 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003774:	0809a583          	lw	a1,128(s3)
    80003778:	0009a503          	lw	a0,0(s3)
    8000377c:	9d7ff0ef          	jal	ra,80003152 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003780:	0809a023          	sw	zero,128(s3)
    80003784:	b765                	j	8000372c <itrunc+0x3a>

0000000080003786 <iput>:
{
    80003786:	1101                	addi	sp,sp,-32
    80003788:	ec06                	sd	ra,24(sp)
    8000378a:	e822                	sd	s0,16(sp)
    8000378c:	e426                	sd	s1,8(sp)
    8000378e:	e04a                	sd	s2,0(sp)
    80003790:	1000                	addi	s0,sp,32
    80003792:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003794:	00242517          	auipc	a0,0x242
    80003798:	74450513          	addi	a0,a0,1860 # 80245ed8 <itable>
    8000379c:	d04fd0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037a0:	4498                	lw	a4,8(s1)
    800037a2:	4785                	li	a5,1
    800037a4:	02f70163          	beq	a4,a5,800037c6 <iput+0x40>
  ip->ref--;
    800037a8:	449c                	lw	a5,8(s1)
    800037aa:	37fd                	addiw	a5,a5,-1
    800037ac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037ae:	00242517          	auipc	a0,0x242
    800037b2:	72a50513          	addi	a0,a0,1834 # 80245ed8 <itable>
    800037b6:	d82fd0ef          	jal	ra,80000d38 <release>
}
    800037ba:	60e2                	ld	ra,24(sp)
    800037bc:	6442                	ld	s0,16(sp)
    800037be:	64a2                	ld	s1,8(sp)
    800037c0:	6902                	ld	s2,0(sp)
    800037c2:	6105                	addi	sp,sp,32
    800037c4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037c6:	40bc                	lw	a5,64(s1)
    800037c8:	d3e5                	beqz	a5,800037a8 <iput+0x22>
    800037ca:	04a49783          	lh	a5,74(s1)
    800037ce:	ffe9                	bnez	a5,800037a8 <iput+0x22>
    acquiresleep(&ip->lock);
    800037d0:	01048913          	addi	s2,s1,16
    800037d4:	854a                	mv	a0,s2
    800037d6:	295000ef          	jal	ra,8000426a <acquiresleep>
    release(&itable.lock);
    800037da:	00242517          	auipc	a0,0x242
    800037de:	6fe50513          	addi	a0,a0,1790 # 80245ed8 <itable>
    800037e2:	d56fd0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    800037e6:	8526                	mv	a0,s1
    800037e8:	f0bff0ef          	jal	ra,800036f2 <itrunc>
    ip->type = 0;
    800037ec:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800037f0:	8526                	mv	a0,s1
    800037f2:	d63ff0ef          	jal	ra,80003554 <iupdate>
    ip->valid = 0;
    800037f6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037fa:	854a                	mv	a0,s2
    800037fc:	2b5000ef          	jal	ra,800042b0 <releasesleep>
    acquire(&itable.lock);
    80003800:	00242517          	auipc	a0,0x242
    80003804:	6d850513          	addi	a0,a0,1752 # 80245ed8 <itable>
    80003808:	c98fd0ef          	jal	ra,80000ca0 <acquire>
    8000380c:	bf71                	j	800037a8 <iput+0x22>

000000008000380e <iunlockput>:
{
    8000380e:	1101                	addi	sp,sp,-32
    80003810:	ec06                	sd	ra,24(sp)
    80003812:	e822                	sd	s0,16(sp)
    80003814:	e426                	sd	s1,8(sp)
    80003816:	1000                	addi	s0,sp,32
    80003818:	84aa                	mv	s1,a0
  iunlock(ip);
    8000381a:	e99ff0ef          	jal	ra,800036b2 <iunlock>
  iput(ip);
    8000381e:	8526                	mv	a0,s1
    80003820:	f67ff0ef          	jal	ra,80003786 <iput>
}
    80003824:	60e2                	ld	ra,24(sp)
    80003826:	6442                	ld	s0,16(sp)
    80003828:	64a2                	ld	s1,8(sp)
    8000382a:	6105                	addi	sp,sp,32
    8000382c:	8082                	ret

000000008000382e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000382e:	00242717          	auipc	a4,0x242
    80003832:	69672703          	lw	a4,1686(a4) # 80245ec4 <sb+0xc>
    80003836:	4785                	li	a5,1
    80003838:	0ae7ff63          	bgeu	a5,a4,800038f6 <ireclaim+0xc8>
{
    8000383c:	7139                	addi	sp,sp,-64
    8000383e:	fc06                	sd	ra,56(sp)
    80003840:	f822                	sd	s0,48(sp)
    80003842:	f426                	sd	s1,40(sp)
    80003844:	f04a                	sd	s2,32(sp)
    80003846:	ec4e                	sd	s3,24(sp)
    80003848:	e852                	sd	s4,16(sp)
    8000384a:	e456                	sd	s5,8(sp)
    8000384c:	e05a                	sd	s6,0(sp)
    8000384e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003850:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003852:	00050a1b          	sext.w	s4,a0
    80003856:	00242a97          	auipc	s5,0x242
    8000385a:	662a8a93          	addi	s5,s5,1634 # 80245eb8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000385e:	00004b17          	auipc	s6,0x4
    80003862:	d32b0b13          	addi	s6,s6,-718 # 80007590 <syscalls+0x198>
    80003866:	a099                	j	800038ac <ireclaim+0x7e>
    80003868:	85ce                	mv	a1,s3
    8000386a:	855a                	mv	a0,s6
    8000386c:	c57fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80003870:	85ce                	mv	a1,s3
    80003872:	8552                	mv	a0,s4
    80003874:	b27ff0ef          	jal	ra,8000339a <iget>
    80003878:	89aa                	mv	s3,a0
    brelse(bp);
    8000387a:	854a                	mv	a0,s2
    8000387c:	fe4ff0ef          	jal	ra,80003060 <brelse>
    if (ip) {
    80003880:	00098f63          	beqz	s3,8000389e <ireclaim+0x70>
      begin_op();
    80003884:	76c000ef          	jal	ra,80003ff0 <begin_op>
      ilock(ip);
    80003888:	854e                	mv	a0,s3
    8000388a:	d7fff0ef          	jal	ra,80003608 <ilock>
      iunlock(ip);
    8000388e:	854e                	mv	a0,s3
    80003890:	e23ff0ef          	jal	ra,800036b2 <iunlock>
      iput(ip);
    80003894:	854e                	mv	a0,s3
    80003896:	ef1ff0ef          	jal	ra,80003786 <iput>
      end_op();
    8000389a:	7c4000ef          	jal	ra,8000405e <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000389e:	0485                	addi	s1,s1,1
    800038a0:	00caa703          	lw	a4,12(s5)
    800038a4:	0004879b          	sext.w	a5,s1
    800038a8:	02e7fd63          	bgeu	a5,a4,800038e2 <ireclaim+0xb4>
    800038ac:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800038b0:	0044d593          	srli	a1,s1,0x4
    800038b4:	018aa783          	lw	a5,24(s5)
    800038b8:	9dbd                	addw	a1,a1,a5
    800038ba:	8552                	mv	a0,s4
    800038bc:	e9cff0ef          	jal	ra,80002f58 <bread>
    800038c0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800038c2:	05850793          	addi	a5,a0,88
    800038c6:	00f9f713          	andi	a4,s3,15
    800038ca:	071a                	slli	a4,a4,0x6
    800038cc:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800038ce:	00079703          	lh	a4,0(a5)
    800038d2:	c701                	beqz	a4,800038da <ireclaim+0xac>
    800038d4:	00679783          	lh	a5,6(a5)
    800038d8:	dbc1                	beqz	a5,80003868 <ireclaim+0x3a>
    brelse(bp);
    800038da:	854a                	mv	a0,s2
    800038dc:	f84ff0ef          	jal	ra,80003060 <brelse>
    if (ip) {
    800038e0:	bf7d                	j	8000389e <ireclaim+0x70>
}
    800038e2:	70e2                	ld	ra,56(sp)
    800038e4:	7442                	ld	s0,48(sp)
    800038e6:	74a2                	ld	s1,40(sp)
    800038e8:	7902                	ld	s2,32(sp)
    800038ea:	69e2                	ld	s3,24(sp)
    800038ec:	6a42                	ld	s4,16(sp)
    800038ee:	6aa2                	ld	s5,8(sp)
    800038f0:	6b02                	ld	s6,0(sp)
    800038f2:	6121                	addi	sp,sp,64
    800038f4:	8082                	ret
    800038f6:	8082                	ret

00000000800038f8 <fsinit>:
fsinit(int dev) {
    800038f8:	7179                	addi	sp,sp,-48
    800038fa:	f406                	sd	ra,40(sp)
    800038fc:	f022                	sd	s0,32(sp)
    800038fe:	ec26                	sd	s1,24(sp)
    80003900:	e84a                	sd	s2,16(sp)
    80003902:	e44e                	sd	s3,8(sp)
    80003904:	1800                	addi	s0,sp,48
    80003906:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003908:	4585                	li	a1,1
    8000390a:	e4eff0ef          	jal	ra,80002f58 <bread>
    8000390e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003910:	00242997          	auipc	s3,0x242
    80003914:	5a898993          	addi	s3,s3,1448 # 80245eb8 <sb>
    80003918:	02000613          	li	a2,32
    8000391c:	05850593          	addi	a1,a0,88
    80003920:	854e                	mv	a0,s3
    80003922:	caefd0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    80003926:	854a                	mv	a0,s2
    80003928:	f38ff0ef          	jal	ra,80003060 <brelse>
  if(sb.magic != FSMAGIC)
    8000392c:	0009a703          	lw	a4,0(s3)
    80003930:	102037b7          	lui	a5,0x10203
    80003934:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003938:	02f71363          	bne	a4,a5,8000395e <fsinit+0x66>
  initlog(dev, &sb);
    8000393c:	00242597          	auipc	a1,0x242
    80003940:	57c58593          	addi	a1,a1,1404 # 80245eb8 <sb>
    80003944:	8526                	mv	a0,s1
    80003946:	61e000ef          	jal	ra,80003f64 <initlog>
  ireclaim(dev);
    8000394a:	8526                	mv	a0,s1
    8000394c:	ee3ff0ef          	jal	ra,8000382e <ireclaim>
}
    80003950:	70a2                	ld	ra,40(sp)
    80003952:	7402                	ld	s0,32(sp)
    80003954:	64e2                	ld	s1,24(sp)
    80003956:	6942                	ld	s2,16(sp)
    80003958:	69a2                	ld	s3,8(sp)
    8000395a:	6145                	addi	sp,sp,48
    8000395c:	8082                	ret
    panic("invalid file system");
    8000395e:	00004517          	auipc	a0,0x4
    80003962:	c5250513          	addi	a0,a0,-942 # 800075b0 <syscalls+0x1b8>
    80003966:	e23fc0ef          	jal	ra,80000788 <panic>

000000008000396a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000396a:	1141                	addi	sp,sp,-16
    8000396c:	e422                	sd	s0,8(sp)
    8000396e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003970:	411c                	lw	a5,0(a0)
    80003972:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003974:	415c                	lw	a5,4(a0)
    80003976:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003978:	04451783          	lh	a5,68(a0)
    8000397c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003980:	04a51783          	lh	a5,74(a0)
    80003984:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003988:	04c56783          	lwu	a5,76(a0)
    8000398c:	e99c                	sd	a5,16(a1)
}
    8000398e:	6422                	ld	s0,8(sp)
    80003990:	0141                	addi	sp,sp,16
    80003992:	8082                	ret

0000000080003994 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003994:	457c                	lw	a5,76(a0)
    80003996:	0cd7ef63          	bltu	a5,a3,80003a74 <readi+0xe0>
{
    8000399a:	7159                	addi	sp,sp,-112
    8000399c:	f486                	sd	ra,104(sp)
    8000399e:	f0a2                	sd	s0,96(sp)
    800039a0:	eca6                	sd	s1,88(sp)
    800039a2:	e8ca                	sd	s2,80(sp)
    800039a4:	e4ce                	sd	s3,72(sp)
    800039a6:	e0d2                	sd	s4,64(sp)
    800039a8:	fc56                	sd	s5,56(sp)
    800039aa:	f85a                	sd	s6,48(sp)
    800039ac:	f45e                	sd	s7,40(sp)
    800039ae:	f062                	sd	s8,32(sp)
    800039b0:	ec66                	sd	s9,24(sp)
    800039b2:	e86a                	sd	s10,16(sp)
    800039b4:	e46e                	sd	s11,8(sp)
    800039b6:	1880                	addi	s0,sp,112
    800039b8:	8b2a                	mv	s6,a0
    800039ba:	8bae                	mv	s7,a1
    800039bc:	8a32                	mv	s4,a2
    800039be:	84b6                	mv	s1,a3
    800039c0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039c2:	9f35                	addw	a4,a4,a3
    return 0;
    800039c4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039c6:	08d76663          	bltu	a4,a3,80003a52 <readi+0xbe>
  if(off + n > ip->size)
    800039ca:	00e7f463          	bgeu	a5,a4,800039d2 <readi+0x3e>
    n = ip->size - off;
    800039ce:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039d2:	080a8f63          	beqz	s5,80003a70 <readi+0xdc>
    800039d6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039d8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039dc:	5c7d                	li	s8,-1
    800039de:	a80d                	j	80003a10 <readi+0x7c>
    800039e0:	020d1d93          	slli	s11,s10,0x20
    800039e4:	020ddd93          	srli	s11,s11,0x20
    800039e8:	05890613          	addi	a2,s2,88
    800039ec:	86ee                	mv	a3,s11
    800039ee:	963a                	add	a2,a2,a4
    800039f0:	85d2                	mv	a1,s4
    800039f2:	855e                	mv	a0,s7
    800039f4:	a43fe0ef          	jal	ra,80002436 <either_copyout>
    800039f8:	05850763          	beq	a0,s8,80003a46 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039fc:	854a                	mv	a0,s2
    800039fe:	e62ff0ef          	jal	ra,80003060 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a02:	013d09bb          	addw	s3,s10,s3
    80003a06:	009d04bb          	addw	s1,s10,s1
    80003a0a:	9a6e                	add	s4,s4,s11
    80003a0c:	0559f163          	bgeu	s3,s5,80003a4e <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003a10:	00a4d59b          	srliw	a1,s1,0xa
    80003a14:	855a                	mv	a0,s6
    80003a16:	8b7ff0ef          	jal	ra,800032cc <bmap>
    80003a1a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a1e:	c985                	beqz	a1,80003a4e <readi+0xba>
    bp = bread(ip->dev, addr);
    80003a20:	000b2503          	lw	a0,0(s6)
    80003a24:	d34ff0ef          	jal	ra,80002f58 <bread>
    80003a28:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a2a:	3ff4f713          	andi	a4,s1,1023
    80003a2e:	40ec87bb          	subw	a5,s9,a4
    80003a32:	413a86bb          	subw	a3,s5,s3
    80003a36:	8d3e                	mv	s10,a5
    80003a38:	2781                	sext.w	a5,a5
    80003a3a:	0006861b          	sext.w	a2,a3
    80003a3e:	faf671e3          	bgeu	a2,a5,800039e0 <readi+0x4c>
    80003a42:	8d36                	mv	s10,a3
    80003a44:	bf71                	j	800039e0 <readi+0x4c>
      brelse(bp);
    80003a46:	854a                	mv	a0,s2
    80003a48:	e18ff0ef          	jal	ra,80003060 <brelse>
      tot = -1;
    80003a4c:	59fd                	li	s3,-1
  }
  return tot;
    80003a4e:	0009851b          	sext.w	a0,s3
}
    80003a52:	70a6                	ld	ra,104(sp)
    80003a54:	7406                	ld	s0,96(sp)
    80003a56:	64e6                	ld	s1,88(sp)
    80003a58:	6946                	ld	s2,80(sp)
    80003a5a:	69a6                	ld	s3,72(sp)
    80003a5c:	6a06                	ld	s4,64(sp)
    80003a5e:	7ae2                	ld	s5,56(sp)
    80003a60:	7b42                	ld	s6,48(sp)
    80003a62:	7ba2                	ld	s7,40(sp)
    80003a64:	7c02                	ld	s8,32(sp)
    80003a66:	6ce2                	ld	s9,24(sp)
    80003a68:	6d42                	ld	s10,16(sp)
    80003a6a:	6da2                	ld	s11,8(sp)
    80003a6c:	6165                	addi	sp,sp,112
    80003a6e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a70:	89d6                	mv	s3,s5
    80003a72:	bff1                	j	80003a4e <readi+0xba>
    return 0;
    80003a74:	4501                	li	a0,0
}
    80003a76:	8082                	ret

0000000080003a78 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a78:	457c                	lw	a5,76(a0)
    80003a7a:	0ed7ea63          	bltu	a5,a3,80003b6e <writei+0xf6>
{
    80003a7e:	7159                	addi	sp,sp,-112
    80003a80:	f486                	sd	ra,104(sp)
    80003a82:	f0a2                	sd	s0,96(sp)
    80003a84:	eca6                	sd	s1,88(sp)
    80003a86:	e8ca                	sd	s2,80(sp)
    80003a88:	e4ce                	sd	s3,72(sp)
    80003a8a:	e0d2                	sd	s4,64(sp)
    80003a8c:	fc56                	sd	s5,56(sp)
    80003a8e:	f85a                	sd	s6,48(sp)
    80003a90:	f45e                	sd	s7,40(sp)
    80003a92:	f062                	sd	s8,32(sp)
    80003a94:	ec66                	sd	s9,24(sp)
    80003a96:	e86a                	sd	s10,16(sp)
    80003a98:	e46e                	sd	s11,8(sp)
    80003a9a:	1880                	addi	s0,sp,112
    80003a9c:	8aaa                	mv	s5,a0
    80003a9e:	8bae                	mv	s7,a1
    80003aa0:	8a32                	mv	s4,a2
    80003aa2:	8936                	mv	s2,a3
    80003aa4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003aa6:	00e687bb          	addw	a5,a3,a4
    80003aaa:	0cd7e463          	bltu	a5,a3,80003b72 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003aae:	00043737          	lui	a4,0x43
    80003ab2:	0cf76263          	bltu	a4,a5,80003b76 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ab6:	0a0b0a63          	beqz	s6,80003b6a <writei+0xf2>
    80003aba:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003abc:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ac0:	5c7d                	li	s8,-1
    80003ac2:	a825                	j	80003afa <writei+0x82>
    80003ac4:	020d1d93          	slli	s11,s10,0x20
    80003ac8:	020ddd93          	srli	s11,s11,0x20
    80003acc:	05848513          	addi	a0,s1,88
    80003ad0:	86ee                	mv	a3,s11
    80003ad2:	8652                	mv	a2,s4
    80003ad4:	85de                	mv	a1,s7
    80003ad6:	953a                	add	a0,a0,a4
    80003ad8:	9a9fe0ef          	jal	ra,80002480 <either_copyin>
    80003adc:	05850a63          	beq	a0,s8,80003b30 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ae0:	8526                	mv	a0,s1
    80003ae2:	690000ef          	jal	ra,80004172 <log_write>
    brelse(bp);
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	d78ff0ef          	jal	ra,80003060 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aec:	013d09bb          	addw	s3,s10,s3
    80003af0:	012d093b          	addw	s2,s10,s2
    80003af4:	9a6e                	add	s4,s4,s11
    80003af6:	0569f063          	bgeu	s3,s6,80003b36 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003afa:	00a9559b          	srliw	a1,s2,0xa
    80003afe:	8556                	mv	a0,s5
    80003b00:	fccff0ef          	jal	ra,800032cc <bmap>
    80003b04:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b08:	c59d                	beqz	a1,80003b36 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003b0a:	000aa503          	lw	a0,0(s5)
    80003b0e:	c4aff0ef          	jal	ra,80002f58 <bread>
    80003b12:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b14:	3ff97713          	andi	a4,s2,1023
    80003b18:	40ec87bb          	subw	a5,s9,a4
    80003b1c:	413b06bb          	subw	a3,s6,s3
    80003b20:	8d3e                	mv	s10,a5
    80003b22:	2781                	sext.w	a5,a5
    80003b24:	0006861b          	sext.w	a2,a3
    80003b28:	f8f67ee3          	bgeu	a2,a5,80003ac4 <writei+0x4c>
    80003b2c:	8d36                	mv	s10,a3
    80003b2e:	bf59                	j	80003ac4 <writei+0x4c>
      brelse(bp);
    80003b30:	8526                	mv	a0,s1
    80003b32:	d2eff0ef          	jal	ra,80003060 <brelse>
  }

  if(off > ip->size)
    80003b36:	04caa783          	lw	a5,76(s5)
    80003b3a:	0127f463          	bgeu	a5,s2,80003b42 <writei+0xca>
    ip->size = off;
    80003b3e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b42:	8556                	mv	a0,s5
    80003b44:	a11ff0ef          	jal	ra,80003554 <iupdate>

  return tot;
    80003b48:	0009851b          	sext.w	a0,s3
}
    80003b4c:	70a6                	ld	ra,104(sp)
    80003b4e:	7406                	ld	s0,96(sp)
    80003b50:	64e6                	ld	s1,88(sp)
    80003b52:	6946                	ld	s2,80(sp)
    80003b54:	69a6                	ld	s3,72(sp)
    80003b56:	6a06                	ld	s4,64(sp)
    80003b58:	7ae2                	ld	s5,56(sp)
    80003b5a:	7b42                	ld	s6,48(sp)
    80003b5c:	7ba2                	ld	s7,40(sp)
    80003b5e:	7c02                	ld	s8,32(sp)
    80003b60:	6ce2                	ld	s9,24(sp)
    80003b62:	6d42                	ld	s10,16(sp)
    80003b64:	6da2                	ld	s11,8(sp)
    80003b66:	6165                	addi	sp,sp,112
    80003b68:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6a:	89da                	mv	s3,s6
    80003b6c:	bfd9                	j	80003b42 <writei+0xca>
    return -1;
    80003b6e:	557d                	li	a0,-1
}
    80003b70:	8082                	ret
    return -1;
    80003b72:	557d                	li	a0,-1
    80003b74:	bfe1                	j	80003b4c <writei+0xd4>
    return -1;
    80003b76:	557d                	li	a0,-1
    80003b78:	bfd1                	j	80003b4c <writei+0xd4>

0000000080003b7a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b7a:	1141                	addi	sp,sp,-16
    80003b7c:	e406                	sd	ra,8(sp)
    80003b7e:	e022                	sd	s0,0(sp)
    80003b80:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b82:	4639                	li	a2,14
    80003b84:	abcfd0ef          	jal	ra,80000e40 <strncmp>
}
    80003b88:	60a2                	ld	ra,8(sp)
    80003b8a:	6402                	ld	s0,0(sp)
    80003b8c:	0141                	addi	sp,sp,16
    80003b8e:	8082                	ret

0000000080003b90 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b90:	7139                	addi	sp,sp,-64
    80003b92:	fc06                	sd	ra,56(sp)
    80003b94:	f822                	sd	s0,48(sp)
    80003b96:	f426                	sd	s1,40(sp)
    80003b98:	f04a                	sd	s2,32(sp)
    80003b9a:	ec4e                	sd	s3,24(sp)
    80003b9c:	e852                	sd	s4,16(sp)
    80003b9e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ba0:	04451703          	lh	a4,68(a0)
    80003ba4:	4785                	li	a5,1
    80003ba6:	00f71a63          	bne	a4,a5,80003bba <dirlookup+0x2a>
    80003baa:	892a                	mv	s2,a0
    80003bac:	89ae                	mv	s3,a1
    80003bae:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb0:	457c                	lw	a5,76(a0)
    80003bb2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bb4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb6:	e39d                	bnez	a5,80003bdc <dirlookup+0x4c>
    80003bb8:	a095                	j	80003c1c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003bba:	00004517          	auipc	a0,0x4
    80003bbe:	a0e50513          	addi	a0,a0,-1522 # 800075c8 <syscalls+0x1d0>
    80003bc2:	bc7fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80003bc6:	00004517          	auipc	a0,0x4
    80003bca:	a1a50513          	addi	a0,a0,-1510 # 800075e0 <syscalls+0x1e8>
    80003bce:	bbbfc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bd2:	24c1                	addiw	s1,s1,16
    80003bd4:	04c92783          	lw	a5,76(s2)
    80003bd8:	04f4f163          	bgeu	s1,a5,80003c1a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bdc:	4741                	li	a4,16
    80003bde:	86a6                	mv	a3,s1
    80003be0:	fc040613          	addi	a2,s0,-64
    80003be4:	4581                	li	a1,0
    80003be6:	854a                	mv	a0,s2
    80003be8:	dadff0ef          	jal	ra,80003994 <readi>
    80003bec:	47c1                	li	a5,16
    80003bee:	fcf51ce3          	bne	a0,a5,80003bc6 <dirlookup+0x36>
    if(de.inum == 0)
    80003bf2:	fc045783          	lhu	a5,-64(s0)
    80003bf6:	dff1                	beqz	a5,80003bd2 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003bf8:	fc240593          	addi	a1,s0,-62
    80003bfc:	854e                	mv	a0,s3
    80003bfe:	f7dff0ef          	jal	ra,80003b7a <namecmp>
    80003c02:	f961                	bnez	a0,80003bd2 <dirlookup+0x42>
      if(poff)
    80003c04:	000a0463          	beqz	s4,80003c0c <dirlookup+0x7c>
        *poff = off;
    80003c08:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c0c:	fc045583          	lhu	a1,-64(s0)
    80003c10:	00092503          	lw	a0,0(s2)
    80003c14:	f86ff0ef          	jal	ra,8000339a <iget>
    80003c18:	a011                	j	80003c1c <dirlookup+0x8c>
  return 0;
    80003c1a:	4501                	li	a0,0
}
    80003c1c:	70e2                	ld	ra,56(sp)
    80003c1e:	7442                	ld	s0,48(sp)
    80003c20:	74a2                	ld	s1,40(sp)
    80003c22:	7902                	ld	s2,32(sp)
    80003c24:	69e2                	ld	s3,24(sp)
    80003c26:	6a42                	ld	s4,16(sp)
    80003c28:	6121                	addi	sp,sp,64
    80003c2a:	8082                	ret

0000000080003c2c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c2c:	711d                	addi	sp,sp,-96
    80003c2e:	ec86                	sd	ra,88(sp)
    80003c30:	e8a2                	sd	s0,80(sp)
    80003c32:	e4a6                	sd	s1,72(sp)
    80003c34:	e0ca                	sd	s2,64(sp)
    80003c36:	fc4e                	sd	s3,56(sp)
    80003c38:	f852                	sd	s4,48(sp)
    80003c3a:	f456                	sd	s5,40(sp)
    80003c3c:	f05a                	sd	s6,32(sp)
    80003c3e:	ec5e                	sd	s7,24(sp)
    80003c40:	e862                	sd	s8,16(sp)
    80003c42:	e466                	sd	s9,8(sp)
    80003c44:	e06a                	sd	s10,0(sp)
    80003c46:	1080                	addi	s0,sp,96
    80003c48:	84aa                	mv	s1,a0
    80003c4a:	8b2e                	mv	s6,a1
    80003c4c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c4e:	00054703          	lbu	a4,0(a0)
    80003c52:	02f00793          	li	a5,47
    80003c56:	00f70f63          	beq	a4,a5,80003c74 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c5a:	e79fd0ef          	jal	ra,80001ad2 <myproc>
    80003c5e:	15053503          	ld	a0,336(a0)
    80003c62:	971ff0ef          	jal	ra,800035d2 <idup>
    80003c66:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c68:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c6c:	4cb5                	li	s9,13
  len = path - s;
    80003c6e:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c70:	4c05                	li	s8,1
    80003c72:	a879                	j	80003d10 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003c74:	4585                	li	a1,1
    80003c76:	4505                	li	a0,1
    80003c78:	f22ff0ef          	jal	ra,8000339a <iget>
    80003c7c:	8a2a                	mv	s4,a0
    80003c7e:	b7ed                	j	80003c68 <namex+0x3c>
      iunlockput(ip);
    80003c80:	8552                	mv	a0,s4
    80003c82:	b8dff0ef          	jal	ra,8000380e <iunlockput>
      return 0;
    80003c86:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c88:	8552                	mv	a0,s4
    80003c8a:	60e6                	ld	ra,88(sp)
    80003c8c:	6446                	ld	s0,80(sp)
    80003c8e:	64a6                	ld	s1,72(sp)
    80003c90:	6906                	ld	s2,64(sp)
    80003c92:	79e2                	ld	s3,56(sp)
    80003c94:	7a42                	ld	s4,48(sp)
    80003c96:	7aa2                	ld	s5,40(sp)
    80003c98:	7b02                	ld	s6,32(sp)
    80003c9a:	6be2                	ld	s7,24(sp)
    80003c9c:	6c42                	ld	s8,16(sp)
    80003c9e:	6ca2                	ld	s9,8(sp)
    80003ca0:	6d02                	ld	s10,0(sp)
    80003ca2:	6125                	addi	sp,sp,96
    80003ca4:	8082                	ret
      iunlock(ip);
    80003ca6:	8552                	mv	a0,s4
    80003ca8:	a0bff0ef          	jal	ra,800036b2 <iunlock>
      return ip;
    80003cac:	bff1                	j	80003c88 <namex+0x5c>
      iunlockput(ip);
    80003cae:	8552                	mv	a0,s4
    80003cb0:	b5fff0ef          	jal	ra,8000380e <iunlockput>
      return 0;
    80003cb4:	8a4e                	mv	s4,s3
    80003cb6:	bfc9                	j	80003c88 <namex+0x5c>
  len = path - s;
    80003cb8:	40998633          	sub	a2,s3,s1
    80003cbc:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003cc0:	09acd063          	bge	s9,s10,80003d40 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003cc4:	4639                	li	a2,14
    80003cc6:	85a6                	mv	a1,s1
    80003cc8:	8556                	mv	a0,s5
    80003cca:	906fd0ef          	jal	ra,80000dd0 <memmove>
    80003cce:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cd0:	0004c783          	lbu	a5,0(s1)
    80003cd4:	01279763          	bne	a5,s2,80003ce2 <namex+0xb6>
    path++;
    80003cd8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cda:	0004c783          	lbu	a5,0(s1)
    80003cde:	ff278de3          	beq	a5,s2,80003cd8 <namex+0xac>
    ilock(ip);
    80003ce2:	8552                	mv	a0,s4
    80003ce4:	925ff0ef          	jal	ra,80003608 <ilock>
    if(ip->type != T_DIR){
    80003ce8:	044a1783          	lh	a5,68(s4)
    80003cec:	f9879ae3          	bne	a5,s8,80003c80 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003cf0:	000b0563          	beqz	s6,80003cfa <namex+0xce>
    80003cf4:	0004c783          	lbu	a5,0(s1)
    80003cf8:	d7dd                	beqz	a5,80003ca6 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cfa:	865e                	mv	a2,s7
    80003cfc:	85d6                	mv	a1,s5
    80003cfe:	8552                	mv	a0,s4
    80003d00:	e91ff0ef          	jal	ra,80003b90 <dirlookup>
    80003d04:	89aa                	mv	s3,a0
    80003d06:	d545                	beqz	a0,80003cae <namex+0x82>
    iunlockput(ip);
    80003d08:	8552                	mv	a0,s4
    80003d0a:	b05ff0ef          	jal	ra,8000380e <iunlockput>
    ip = next;
    80003d0e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d10:	0004c783          	lbu	a5,0(s1)
    80003d14:	01279763          	bne	a5,s2,80003d22 <namex+0xf6>
    path++;
    80003d18:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d1a:	0004c783          	lbu	a5,0(s1)
    80003d1e:	ff278de3          	beq	a5,s2,80003d18 <namex+0xec>
  if(*path == 0)
    80003d22:	cb8d                	beqz	a5,80003d54 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003d24:	0004c783          	lbu	a5,0(s1)
    80003d28:	89a6                	mv	s3,s1
  len = path - s;
    80003d2a:	8d5e                	mv	s10,s7
    80003d2c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d2e:	01278963          	beq	a5,s2,80003d40 <namex+0x114>
    80003d32:	d3d9                	beqz	a5,80003cb8 <namex+0x8c>
    path++;
    80003d34:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d36:	0009c783          	lbu	a5,0(s3)
    80003d3a:	ff279ce3          	bne	a5,s2,80003d32 <namex+0x106>
    80003d3e:	bfad                	j	80003cb8 <namex+0x8c>
    memmove(name, s, len);
    80003d40:	2601                	sext.w	a2,a2
    80003d42:	85a6                	mv	a1,s1
    80003d44:	8556                	mv	a0,s5
    80003d46:	88afd0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    80003d4a:	9d56                	add	s10,s10,s5
    80003d4c:	000d0023          	sb	zero,0(s10)
    80003d50:	84ce                	mv	s1,s3
    80003d52:	bfbd                	j	80003cd0 <namex+0xa4>
  if(nameiparent){
    80003d54:	f20b0ae3          	beqz	s6,80003c88 <namex+0x5c>
    iput(ip);
    80003d58:	8552                	mv	a0,s4
    80003d5a:	a2dff0ef          	jal	ra,80003786 <iput>
    return 0;
    80003d5e:	4a01                	li	s4,0
    80003d60:	b725                	j	80003c88 <namex+0x5c>

0000000080003d62 <dirlink>:
{
    80003d62:	7139                	addi	sp,sp,-64
    80003d64:	fc06                	sd	ra,56(sp)
    80003d66:	f822                	sd	s0,48(sp)
    80003d68:	f426                	sd	s1,40(sp)
    80003d6a:	f04a                	sd	s2,32(sp)
    80003d6c:	ec4e                	sd	s3,24(sp)
    80003d6e:	e852                	sd	s4,16(sp)
    80003d70:	0080                	addi	s0,sp,64
    80003d72:	892a                	mv	s2,a0
    80003d74:	8a2e                	mv	s4,a1
    80003d76:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d78:	4601                	li	a2,0
    80003d7a:	e17ff0ef          	jal	ra,80003b90 <dirlookup>
    80003d7e:	e52d                	bnez	a0,80003de8 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d80:	04c92483          	lw	s1,76(s2)
    80003d84:	c48d                	beqz	s1,80003dae <dirlink+0x4c>
    80003d86:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d88:	4741                	li	a4,16
    80003d8a:	86a6                	mv	a3,s1
    80003d8c:	fc040613          	addi	a2,s0,-64
    80003d90:	4581                	li	a1,0
    80003d92:	854a                	mv	a0,s2
    80003d94:	c01ff0ef          	jal	ra,80003994 <readi>
    80003d98:	47c1                	li	a5,16
    80003d9a:	04f51b63          	bne	a0,a5,80003df0 <dirlink+0x8e>
    if(de.inum == 0)
    80003d9e:	fc045783          	lhu	a5,-64(s0)
    80003da2:	c791                	beqz	a5,80003dae <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da4:	24c1                	addiw	s1,s1,16
    80003da6:	04c92783          	lw	a5,76(s2)
    80003daa:	fcf4efe3          	bltu	s1,a5,80003d88 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003dae:	4639                	li	a2,14
    80003db0:	85d2                	mv	a1,s4
    80003db2:	fc240513          	addi	a0,s0,-62
    80003db6:	8c6fd0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80003dba:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dbe:	4741                	li	a4,16
    80003dc0:	86a6                	mv	a3,s1
    80003dc2:	fc040613          	addi	a2,s0,-64
    80003dc6:	4581                	li	a1,0
    80003dc8:	854a                	mv	a0,s2
    80003dca:	cafff0ef          	jal	ra,80003a78 <writei>
    80003dce:	1541                	addi	a0,a0,-16
    80003dd0:	00a03533          	snez	a0,a0
    80003dd4:	40a00533          	neg	a0,a0
}
    80003dd8:	70e2                	ld	ra,56(sp)
    80003dda:	7442                	ld	s0,48(sp)
    80003ddc:	74a2                	ld	s1,40(sp)
    80003dde:	7902                	ld	s2,32(sp)
    80003de0:	69e2                	ld	s3,24(sp)
    80003de2:	6a42                	ld	s4,16(sp)
    80003de4:	6121                	addi	sp,sp,64
    80003de6:	8082                	ret
    iput(ip);
    80003de8:	99fff0ef          	jal	ra,80003786 <iput>
    return -1;
    80003dec:	557d                	li	a0,-1
    80003dee:	b7ed                	j	80003dd8 <dirlink+0x76>
      panic("dirlink read");
    80003df0:	00004517          	auipc	a0,0x4
    80003df4:	80050513          	addi	a0,a0,-2048 # 800075f0 <syscalls+0x1f8>
    80003df8:	991fc0ef          	jal	ra,80000788 <panic>

0000000080003dfc <namei>:

struct inode*
namei(char *path)
{
    80003dfc:	1101                	addi	sp,sp,-32
    80003dfe:	ec06                	sd	ra,24(sp)
    80003e00:	e822                	sd	s0,16(sp)
    80003e02:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e04:	fe040613          	addi	a2,s0,-32
    80003e08:	4581                	li	a1,0
    80003e0a:	e23ff0ef          	jal	ra,80003c2c <namex>
}
    80003e0e:	60e2                	ld	ra,24(sp)
    80003e10:	6442                	ld	s0,16(sp)
    80003e12:	6105                	addi	sp,sp,32
    80003e14:	8082                	ret

0000000080003e16 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e16:	1141                	addi	sp,sp,-16
    80003e18:	e406                	sd	ra,8(sp)
    80003e1a:	e022                	sd	s0,0(sp)
    80003e1c:	0800                	addi	s0,sp,16
    80003e1e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e20:	4585                	li	a1,1
    80003e22:	e0bff0ef          	jal	ra,80003c2c <namex>
}
    80003e26:	60a2                	ld	ra,8(sp)
    80003e28:	6402                	ld	s0,0(sp)
    80003e2a:	0141                	addi	sp,sp,16
    80003e2c:	8082                	ret

0000000080003e2e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e2e:	1101                	addi	sp,sp,-32
    80003e30:	ec06                	sd	ra,24(sp)
    80003e32:	e822                	sd	s0,16(sp)
    80003e34:	e426                	sd	s1,8(sp)
    80003e36:	e04a                	sd	s2,0(sp)
    80003e38:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e3a:	00244917          	auipc	s2,0x244
    80003e3e:	b4690913          	addi	s2,s2,-1210 # 80247980 <log>
    80003e42:	01892583          	lw	a1,24(s2)
    80003e46:	02492503          	lw	a0,36(s2)
    80003e4a:	90eff0ef          	jal	ra,80002f58 <bread>
    80003e4e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e50:	02892683          	lw	a3,40(s2)
    80003e54:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e56:	02d05863          	blez	a3,80003e86 <write_head+0x58>
    80003e5a:	00244797          	auipc	a5,0x244
    80003e5e:	b5278793          	addi	a5,a5,-1198 # 802479ac <log+0x2c>
    80003e62:	05c50713          	addi	a4,a0,92
    80003e66:	36fd                	addiw	a3,a3,-1
    80003e68:	02069613          	slli	a2,a3,0x20
    80003e6c:	01e65693          	srli	a3,a2,0x1e
    80003e70:	00244617          	auipc	a2,0x244
    80003e74:	b4060613          	addi	a2,a2,-1216 # 802479b0 <log+0x30>
    80003e78:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e7a:	4390                	lw	a2,0(a5)
    80003e7c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e7e:	0791                	addi	a5,a5,4
    80003e80:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003e82:	fed79ce3          	bne	a5,a3,80003e7a <write_head+0x4c>
  }
  bwrite(buf);
    80003e86:	8526                	mv	a0,s1
    80003e88:	9a6ff0ef          	jal	ra,8000302e <bwrite>
  brelse(buf);
    80003e8c:	8526                	mv	a0,s1
    80003e8e:	9d2ff0ef          	jal	ra,80003060 <brelse>
}
    80003e92:	60e2                	ld	ra,24(sp)
    80003e94:	6442                	ld	s0,16(sp)
    80003e96:	64a2                	ld	s1,8(sp)
    80003e98:	6902                	ld	s2,0(sp)
    80003e9a:	6105                	addi	sp,sp,32
    80003e9c:	8082                	ret

0000000080003e9e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e9e:	00244797          	auipc	a5,0x244
    80003ea2:	b0a7a783          	lw	a5,-1270(a5) # 802479a8 <log+0x28>
    80003ea6:	0af05e63          	blez	a5,80003f62 <install_trans+0xc4>
{
    80003eaa:	715d                	addi	sp,sp,-80
    80003eac:	e486                	sd	ra,72(sp)
    80003eae:	e0a2                	sd	s0,64(sp)
    80003eb0:	fc26                	sd	s1,56(sp)
    80003eb2:	f84a                	sd	s2,48(sp)
    80003eb4:	f44e                	sd	s3,40(sp)
    80003eb6:	f052                	sd	s4,32(sp)
    80003eb8:	ec56                	sd	s5,24(sp)
    80003eba:	e85a                	sd	s6,16(sp)
    80003ebc:	e45e                	sd	s7,8(sp)
    80003ebe:	0880                	addi	s0,sp,80
    80003ec0:	8b2a                	mv	s6,a0
    80003ec2:	00244a97          	auipc	s5,0x244
    80003ec6:	aeaa8a93          	addi	s5,s5,-1302 # 802479ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eca:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ecc:	00003b97          	auipc	s7,0x3
    80003ed0:	734b8b93          	addi	s7,s7,1844 # 80007600 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ed4:	00244a17          	auipc	s4,0x244
    80003ed8:	aaca0a13          	addi	s4,s4,-1364 # 80247980 <log>
    80003edc:	a025                	j	80003f04 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ede:	000aa603          	lw	a2,0(s5)
    80003ee2:	85ce                	mv	a1,s3
    80003ee4:	855e                	mv	a0,s7
    80003ee6:	ddcfc0ef          	jal	ra,800004c2 <printf>
    80003eea:	a839                	j	80003f08 <install_trans+0x6a>
    brelse(lbuf);
    80003eec:	854a                	mv	a0,s2
    80003eee:	972ff0ef          	jal	ra,80003060 <brelse>
    brelse(dbuf);
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	96cff0ef          	jal	ra,80003060 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef8:	2985                	addiw	s3,s3,1
    80003efa:	0a91                	addi	s5,s5,4
    80003efc:	028a2783          	lw	a5,40(s4)
    80003f00:	04f9d663          	bge	s3,a5,80003f4c <install_trans+0xae>
    if(recovering) {
    80003f04:	fc0b1de3          	bnez	s6,80003ede <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f08:	018a2583          	lw	a1,24(s4)
    80003f0c:	013585bb          	addw	a1,a1,s3
    80003f10:	2585                	addiw	a1,a1,1
    80003f12:	024a2503          	lw	a0,36(s4)
    80003f16:	842ff0ef          	jal	ra,80002f58 <bread>
    80003f1a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f1c:	000aa583          	lw	a1,0(s5)
    80003f20:	024a2503          	lw	a0,36(s4)
    80003f24:	834ff0ef          	jal	ra,80002f58 <bread>
    80003f28:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f2a:	40000613          	li	a2,1024
    80003f2e:	05890593          	addi	a1,s2,88
    80003f32:	05850513          	addi	a0,a0,88
    80003f36:	e9bfc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	8f2ff0ef          	jal	ra,8000302e <bwrite>
    if(recovering == 0)
    80003f40:	fa0b16e3          	bnez	s6,80003eec <install_trans+0x4e>
      bunpin(dbuf);
    80003f44:	8526                	mv	a0,s1
    80003f46:	9d8ff0ef          	jal	ra,8000311e <bunpin>
    80003f4a:	b74d                	j	80003eec <install_trans+0x4e>
}
    80003f4c:	60a6                	ld	ra,72(sp)
    80003f4e:	6406                	ld	s0,64(sp)
    80003f50:	74e2                	ld	s1,56(sp)
    80003f52:	7942                	ld	s2,48(sp)
    80003f54:	79a2                	ld	s3,40(sp)
    80003f56:	7a02                	ld	s4,32(sp)
    80003f58:	6ae2                	ld	s5,24(sp)
    80003f5a:	6b42                	ld	s6,16(sp)
    80003f5c:	6ba2                	ld	s7,8(sp)
    80003f5e:	6161                	addi	sp,sp,80
    80003f60:	8082                	ret
    80003f62:	8082                	ret

0000000080003f64 <initlog>:
{
    80003f64:	7179                	addi	sp,sp,-48
    80003f66:	f406                	sd	ra,40(sp)
    80003f68:	f022                	sd	s0,32(sp)
    80003f6a:	ec26                	sd	s1,24(sp)
    80003f6c:	e84a                	sd	s2,16(sp)
    80003f6e:	e44e                	sd	s3,8(sp)
    80003f70:	1800                	addi	s0,sp,48
    80003f72:	892a                	mv	s2,a0
    80003f74:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f76:	00244497          	auipc	s1,0x244
    80003f7a:	a0a48493          	addi	s1,s1,-1526 # 80247980 <log>
    80003f7e:	00003597          	auipc	a1,0x3
    80003f82:	6a258593          	addi	a1,a1,1698 # 80007620 <syscalls+0x228>
    80003f86:	8526                	mv	a0,s1
    80003f88:	c99fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80003f8c:	0149a583          	lw	a1,20(s3)
    80003f90:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003f92:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f96:	854a                	mv	a0,s2
    80003f98:	fc1fe0ef          	jal	ra,80002f58 <bread>
  log.lh.n = lh->n;
    80003f9c:	4d34                	lw	a3,88(a0)
    80003f9e:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fa0:	02d05663          	blez	a3,80003fcc <initlog+0x68>
    80003fa4:	05c50793          	addi	a5,a0,92
    80003fa8:	00244717          	auipc	a4,0x244
    80003fac:	a0470713          	addi	a4,a4,-1532 # 802479ac <log+0x2c>
    80003fb0:	36fd                	addiw	a3,a3,-1
    80003fb2:	02069613          	slli	a2,a3,0x20
    80003fb6:	01e65693          	srli	a3,a2,0x1e
    80003fba:	06050613          	addi	a2,a0,96
    80003fbe:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003fc0:	4390                	lw	a2,0(a5)
    80003fc2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fc4:	0791                	addi	a5,a5,4
    80003fc6:	0711                	addi	a4,a4,4
    80003fc8:	fed79ce3          	bne	a5,a3,80003fc0 <initlog+0x5c>
  brelse(buf);
    80003fcc:	894ff0ef          	jal	ra,80003060 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fd0:	4505                	li	a0,1
    80003fd2:	ecdff0ef          	jal	ra,80003e9e <install_trans>
  log.lh.n = 0;
    80003fd6:	00244797          	auipc	a5,0x244
    80003fda:	9c07a923          	sw	zero,-1582(a5) # 802479a8 <log+0x28>
  write_head(); // clear the log
    80003fde:	e51ff0ef          	jal	ra,80003e2e <write_head>
}
    80003fe2:	70a2                	ld	ra,40(sp)
    80003fe4:	7402                	ld	s0,32(sp)
    80003fe6:	64e2                	ld	s1,24(sp)
    80003fe8:	6942                	ld	s2,16(sp)
    80003fea:	69a2                	ld	s3,8(sp)
    80003fec:	6145                	addi	sp,sp,48
    80003fee:	8082                	ret

0000000080003ff0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ff0:	1101                	addi	sp,sp,-32
    80003ff2:	ec06                	sd	ra,24(sp)
    80003ff4:	e822                	sd	s0,16(sp)
    80003ff6:	e426                	sd	s1,8(sp)
    80003ff8:	e04a                	sd	s2,0(sp)
    80003ffa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ffc:	00244517          	auipc	a0,0x244
    80004000:	98450513          	addi	a0,a0,-1660 # 80247980 <log>
    80004004:	c9dfc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    80004008:	00244497          	auipc	s1,0x244
    8000400c:	97848493          	addi	s1,s1,-1672 # 80247980 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004010:	4979                	li	s2,30
    80004012:	a029                	j	8000401c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004014:	85a6                	mv	a1,s1
    80004016:	8526                	mv	a0,s1
    80004018:	8c2fe0ef          	jal	ra,800020da <sleep>
    if(log.committing){
    8000401c:	509c                	lw	a5,32(s1)
    8000401e:	fbfd                	bnez	a5,80004014 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004020:	4cd8                	lw	a4,28(s1)
    80004022:	2705                	addiw	a4,a4,1
    80004024:	0007069b          	sext.w	a3,a4
    80004028:	0027179b          	slliw	a5,a4,0x2
    8000402c:	9fb9                	addw	a5,a5,a4
    8000402e:	0017979b          	slliw	a5,a5,0x1
    80004032:	5498                	lw	a4,40(s1)
    80004034:	9fb9                	addw	a5,a5,a4
    80004036:	00f95763          	bge	s2,a5,80004044 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000403a:	85a6                	mv	a1,s1
    8000403c:	8526                	mv	a0,s1
    8000403e:	89cfe0ef          	jal	ra,800020da <sleep>
    80004042:	bfe9                	j	8000401c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004044:	00244517          	auipc	a0,0x244
    80004048:	93c50513          	addi	a0,a0,-1732 # 80247980 <log>
    8000404c:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    8000404e:	cebfc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    80004052:	60e2                	ld	ra,24(sp)
    80004054:	6442                	ld	s0,16(sp)
    80004056:	64a2                	ld	s1,8(sp)
    80004058:	6902                	ld	s2,0(sp)
    8000405a:	6105                	addi	sp,sp,32
    8000405c:	8082                	ret

000000008000405e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000405e:	7139                	addi	sp,sp,-64
    80004060:	fc06                	sd	ra,56(sp)
    80004062:	f822                	sd	s0,48(sp)
    80004064:	f426                	sd	s1,40(sp)
    80004066:	f04a                	sd	s2,32(sp)
    80004068:	ec4e                	sd	s3,24(sp)
    8000406a:	e852                	sd	s4,16(sp)
    8000406c:	e456                	sd	s5,8(sp)
    8000406e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004070:	00244497          	auipc	s1,0x244
    80004074:	91048493          	addi	s1,s1,-1776 # 80247980 <log>
    80004078:	8526                	mv	a0,s1
    8000407a:	c27fc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    8000407e:	4cdc                	lw	a5,28(s1)
    80004080:	37fd                	addiw	a5,a5,-1
    80004082:	0007891b          	sext.w	s2,a5
    80004086:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004088:	509c                	lw	a5,32(s1)
    8000408a:	ef9d                	bnez	a5,800040c8 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    8000408c:	04091463          	bnez	s2,800040d4 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004090:	00244497          	auipc	s1,0x244
    80004094:	8f048493          	addi	s1,s1,-1808 # 80247980 <log>
    80004098:	4785                	li	a5,1
    8000409a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000409c:	8526                	mv	a0,s1
    8000409e:	c9bfc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040a2:	549c                	lw	a5,40(s1)
    800040a4:	04f04b63          	bgtz	a5,800040fa <end_op+0x9c>
    acquire(&log.lock);
    800040a8:	00244497          	auipc	s1,0x244
    800040ac:	8d848493          	addi	s1,s1,-1832 # 80247980 <log>
    800040b0:	8526                	mv	a0,s1
    800040b2:	beffc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    800040b6:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800040ba:	8526                	mv	a0,s1
    800040bc:	86afe0ef          	jal	ra,80002126 <wakeup>
    release(&log.lock);
    800040c0:	8526                	mv	a0,s1
    800040c2:	c77fc0ef          	jal	ra,80000d38 <release>
}
    800040c6:	a00d                	j	800040e8 <end_op+0x8a>
    panic("log.committing");
    800040c8:	00003517          	auipc	a0,0x3
    800040cc:	56050513          	addi	a0,a0,1376 # 80007628 <syscalls+0x230>
    800040d0:	eb8fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    800040d4:	00244497          	auipc	s1,0x244
    800040d8:	8ac48493          	addi	s1,s1,-1876 # 80247980 <log>
    800040dc:	8526                	mv	a0,s1
    800040de:	848fe0ef          	jal	ra,80002126 <wakeup>
  release(&log.lock);
    800040e2:	8526                	mv	a0,s1
    800040e4:	c55fc0ef          	jal	ra,80000d38 <release>
}
    800040e8:	70e2                	ld	ra,56(sp)
    800040ea:	7442                	ld	s0,48(sp)
    800040ec:	74a2                	ld	s1,40(sp)
    800040ee:	7902                	ld	s2,32(sp)
    800040f0:	69e2                	ld	s3,24(sp)
    800040f2:	6a42                	ld	s4,16(sp)
    800040f4:	6aa2                	ld	s5,8(sp)
    800040f6:	6121                	addi	sp,sp,64
    800040f8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fa:	00244a97          	auipc	s5,0x244
    800040fe:	8b2a8a93          	addi	s5,s5,-1870 # 802479ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004102:	00244a17          	auipc	s4,0x244
    80004106:	87ea0a13          	addi	s4,s4,-1922 # 80247980 <log>
    8000410a:	018a2583          	lw	a1,24(s4)
    8000410e:	012585bb          	addw	a1,a1,s2
    80004112:	2585                	addiw	a1,a1,1
    80004114:	024a2503          	lw	a0,36(s4)
    80004118:	e41fe0ef          	jal	ra,80002f58 <bread>
    8000411c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000411e:	000aa583          	lw	a1,0(s5)
    80004122:	024a2503          	lw	a0,36(s4)
    80004126:	e33fe0ef          	jal	ra,80002f58 <bread>
    8000412a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000412c:	40000613          	li	a2,1024
    80004130:	05850593          	addi	a1,a0,88
    80004134:	05848513          	addi	a0,s1,88
    80004138:	c99fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    8000413c:	8526                	mv	a0,s1
    8000413e:	ef1fe0ef          	jal	ra,8000302e <bwrite>
    brelse(from);
    80004142:	854e                	mv	a0,s3
    80004144:	f1dfe0ef          	jal	ra,80003060 <brelse>
    brelse(to);
    80004148:	8526                	mv	a0,s1
    8000414a:	f17fe0ef          	jal	ra,80003060 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000414e:	2905                	addiw	s2,s2,1
    80004150:	0a91                	addi	s5,s5,4
    80004152:	028a2783          	lw	a5,40(s4)
    80004156:	faf94ae3          	blt	s2,a5,8000410a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000415a:	cd5ff0ef          	jal	ra,80003e2e <write_head>
    install_trans(0); // Now install writes to home locations
    8000415e:	4501                	li	a0,0
    80004160:	d3fff0ef          	jal	ra,80003e9e <install_trans>
    log.lh.n = 0;
    80004164:	00244797          	auipc	a5,0x244
    80004168:	8407a223          	sw	zero,-1980(a5) # 802479a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000416c:	cc3ff0ef          	jal	ra,80003e2e <write_head>
    80004170:	bf25                	j	800040a8 <end_op+0x4a>

0000000080004172 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004172:	1101                	addi	sp,sp,-32
    80004174:	ec06                	sd	ra,24(sp)
    80004176:	e822                	sd	s0,16(sp)
    80004178:	e426                	sd	s1,8(sp)
    8000417a:	e04a                	sd	s2,0(sp)
    8000417c:	1000                	addi	s0,sp,32
    8000417e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004180:	00244917          	auipc	s2,0x244
    80004184:	80090913          	addi	s2,s2,-2048 # 80247980 <log>
    80004188:	854a                	mv	a0,s2
    8000418a:	b17fc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000418e:	02892603          	lw	a2,40(s2)
    80004192:	47f5                	li	a5,29
    80004194:	04c7cc63          	blt	a5,a2,800041ec <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004198:	00244797          	auipc	a5,0x244
    8000419c:	8047a783          	lw	a5,-2044(a5) # 8024799c <log+0x1c>
    800041a0:	04f05c63          	blez	a5,800041f8 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041a4:	4781                	li	a5,0
    800041a6:	04c05f63          	blez	a2,80004204 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041aa:	44cc                	lw	a1,12(s1)
    800041ac:	00244717          	auipc	a4,0x244
    800041b0:	80070713          	addi	a4,a4,-2048 # 802479ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800041b4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041b6:	4314                	lw	a3,0(a4)
    800041b8:	04b68663          	beq	a3,a1,80004204 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800041bc:	2785                	addiw	a5,a5,1
    800041be:	0711                	addi	a4,a4,4
    800041c0:	fef61be3          	bne	a2,a5,800041b6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041c4:	0621                	addi	a2,a2,8
    800041c6:	060a                	slli	a2,a2,0x2
    800041c8:	00243797          	auipc	a5,0x243
    800041cc:	7b878793          	addi	a5,a5,1976 # 80247980 <log>
    800041d0:	97b2                	add	a5,a5,a2
    800041d2:	44d8                	lw	a4,12(s1)
    800041d4:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800041d6:	8526                	mv	a0,s1
    800041d8:	f13fe0ef          	jal	ra,800030ea <bpin>
    log.lh.n++;
    800041dc:	00243717          	auipc	a4,0x243
    800041e0:	7a470713          	addi	a4,a4,1956 # 80247980 <log>
    800041e4:	571c                	lw	a5,40(a4)
    800041e6:	2785                	addiw	a5,a5,1
    800041e8:	d71c                	sw	a5,40(a4)
    800041ea:	a80d                	j	8000421c <log_write+0xaa>
    panic("too big a transaction");
    800041ec:	00003517          	auipc	a0,0x3
    800041f0:	44c50513          	addi	a0,a0,1100 # 80007638 <syscalls+0x240>
    800041f4:	d94fc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    800041f8:	00003517          	auipc	a0,0x3
    800041fc:	45850513          	addi	a0,a0,1112 # 80007650 <syscalls+0x258>
    80004200:	d88fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    80004204:	00878693          	addi	a3,a5,8
    80004208:	068a                	slli	a3,a3,0x2
    8000420a:	00243717          	auipc	a4,0x243
    8000420e:	77670713          	addi	a4,a4,1910 # 80247980 <log>
    80004212:	9736                	add	a4,a4,a3
    80004214:	44d4                	lw	a3,12(s1)
    80004216:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004218:	faf60fe3          	beq	a2,a5,800041d6 <log_write+0x64>
  }
  release(&log.lock);
    8000421c:	00243517          	auipc	a0,0x243
    80004220:	76450513          	addi	a0,a0,1892 # 80247980 <log>
    80004224:	b15fc0ef          	jal	ra,80000d38 <release>
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	e04a                	sd	s2,0(sp)
    8000423e:	1000                	addi	s0,sp,32
    80004240:	84aa                	mv	s1,a0
    80004242:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004244:	00003597          	auipc	a1,0x3
    80004248:	42c58593          	addi	a1,a1,1068 # 80007670 <syscalls+0x278>
    8000424c:	0521                	addi	a0,a0,8
    8000424e:	9d3fc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    80004252:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004256:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000425a:	0204a423          	sw	zero,40(s1)
}
    8000425e:	60e2                	ld	ra,24(sp)
    80004260:	6442                	ld	s0,16(sp)
    80004262:	64a2                	ld	s1,8(sp)
    80004264:	6902                	ld	s2,0(sp)
    80004266:	6105                	addi	sp,sp,32
    80004268:	8082                	ret

000000008000426a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000426a:	1101                	addi	sp,sp,-32
    8000426c:	ec06                	sd	ra,24(sp)
    8000426e:	e822                	sd	s0,16(sp)
    80004270:	e426                	sd	s1,8(sp)
    80004272:	e04a                	sd	s2,0(sp)
    80004274:	1000                	addi	s0,sp,32
    80004276:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004278:	00850913          	addi	s2,a0,8
    8000427c:	854a                	mv	a0,s2
    8000427e:	a23fc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    80004282:	409c                	lw	a5,0(s1)
    80004284:	c799                	beqz	a5,80004292 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004286:	85ca                	mv	a1,s2
    80004288:	8526                	mv	a0,s1
    8000428a:	e51fd0ef          	jal	ra,800020da <sleep>
  while (lk->locked) {
    8000428e:	409c                	lw	a5,0(s1)
    80004290:	fbfd                	bnez	a5,80004286 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004292:	4785                	li	a5,1
    80004294:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004296:	83dfd0ef          	jal	ra,80001ad2 <myproc>
    8000429a:	591c                	lw	a5,48(a0)
    8000429c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000429e:	854a                	mv	a0,s2
    800042a0:	a99fc0ef          	jal	ra,80000d38 <release>
}
    800042a4:	60e2                	ld	ra,24(sp)
    800042a6:	6442                	ld	s0,16(sp)
    800042a8:	64a2                	ld	s1,8(sp)
    800042aa:	6902                	ld	s2,0(sp)
    800042ac:	6105                	addi	sp,sp,32
    800042ae:	8082                	ret

00000000800042b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800042b0:	1101                	addi	sp,sp,-32
    800042b2:	ec06                	sd	ra,24(sp)
    800042b4:	e822                	sd	s0,16(sp)
    800042b6:	e426                	sd	s1,8(sp)
    800042b8:	e04a                	sd	s2,0(sp)
    800042ba:	1000                	addi	s0,sp,32
    800042bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042be:	00850913          	addi	s2,a0,8
    800042c2:	854a                	mv	a0,s2
    800042c4:	9ddfc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    800042c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042cc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042d0:	8526                	mv	a0,s1
    800042d2:	e55fd0ef          	jal	ra,80002126 <wakeup>
  release(&lk->lk);
    800042d6:	854a                	mv	a0,s2
    800042d8:	a61fc0ef          	jal	ra,80000d38 <release>
}
    800042dc:	60e2                	ld	ra,24(sp)
    800042de:	6442                	ld	s0,16(sp)
    800042e0:	64a2                	ld	s1,8(sp)
    800042e2:	6902                	ld	s2,0(sp)
    800042e4:	6105                	addi	sp,sp,32
    800042e6:	8082                	ret

00000000800042e8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042e8:	7179                	addi	sp,sp,-48
    800042ea:	f406                	sd	ra,40(sp)
    800042ec:	f022                	sd	s0,32(sp)
    800042ee:	ec26                	sd	s1,24(sp)
    800042f0:	e84a                	sd	s2,16(sp)
    800042f2:	e44e                	sd	s3,8(sp)
    800042f4:	1800                	addi	s0,sp,48
    800042f6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042f8:	00850913          	addi	s2,a0,8
    800042fc:	854a                	mv	a0,s2
    800042fe:	9a3fc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004302:	409c                	lw	a5,0(s1)
    80004304:	ef89                	bnez	a5,8000431e <holdingsleep+0x36>
    80004306:	4481                	li	s1,0
  release(&lk->lk);
    80004308:	854a                	mv	a0,s2
    8000430a:	a2ffc0ef          	jal	ra,80000d38 <release>
  return r;
}
    8000430e:	8526                	mv	a0,s1
    80004310:	70a2                	ld	ra,40(sp)
    80004312:	7402                	ld	s0,32(sp)
    80004314:	64e2                	ld	s1,24(sp)
    80004316:	6942                	ld	s2,16(sp)
    80004318:	69a2                	ld	s3,8(sp)
    8000431a:	6145                	addi	sp,sp,48
    8000431c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000431e:	0284a983          	lw	s3,40(s1)
    80004322:	fb0fd0ef          	jal	ra,80001ad2 <myproc>
    80004326:	5904                	lw	s1,48(a0)
    80004328:	413484b3          	sub	s1,s1,s3
    8000432c:	0014b493          	seqz	s1,s1
    80004330:	bfe1                	j	80004308 <holdingsleep+0x20>

0000000080004332 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004332:	1141                	addi	sp,sp,-16
    80004334:	e406                	sd	ra,8(sp)
    80004336:	e022                	sd	s0,0(sp)
    80004338:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000433a:	00003597          	auipc	a1,0x3
    8000433e:	34658593          	addi	a1,a1,838 # 80007680 <syscalls+0x288>
    80004342:	00243517          	auipc	a0,0x243
    80004346:	78650513          	addi	a0,a0,1926 # 80247ac8 <ftable>
    8000434a:	8d7fc0ef          	jal	ra,80000c20 <initlock>
}
    8000434e:	60a2                	ld	ra,8(sp)
    80004350:	6402                	ld	s0,0(sp)
    80004352:	0141                	addi	sp,sp,16
    80004354:	8082                	ret

0000000080004356 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004356:	1101                	addi	sp,sp,-32
    80004358:	ec06                	sd	ra,24(sp)
    8000435a:	e822                	sd	s0,16(sp)
    8000435c:	e426                	sd	s1,8(sp)
    8000435e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004360:	00243517          	auipc	a0,0x243
    80004364:	76850513          	addi	a0,a0,1896 # 80247ac8 <ftable>
    80004368:	939fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000436c:	00243497          	auipc	s1,0x243
    80004370:	77448493          	addi	s1,s1,1908 # 80247ae0 <ftable+0x18>
    80004374:	00244717          	auipc	a4,0x244
    80004378:	70c70713          	addi	a4,a4,1804 # 80248a80 <disk>
    if(f->ref == 0){
    8000437c:	40dc                	lw	a5,4(s1)
    8000437e:	cf89                	beqz	a5,80004398 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004380:	02848493          	addi	s1,s1,40
    80004384:	fee49ce3          	bne	s1,a4,8000437c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004388:	00243517          	auipc	a0,0x243
    8000438c:	74050513          	addi	a0,a0,1856 # 80247ac8 <ftable>
    80004390:	9a9fc0ef          	jal	ra,80000d38 <release>
  return 0;
    80004394:	4481                	li	s1,0
    80004396:	a809                	j	800043a8 <filealloc+0x52>
      f->ref = 1;
    80004398:	4785                	li	a5,1
    8000439a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000439c:	00243517          	auipc	a0,0x243
    800043a0:	72c50513          	addi	a0,a0,1836 # 80247ac8 <ftable>
    800043a4:	995fc0ef          	jal	ra,80000d38 <release>
}
    800043a8:	8526                	mv	a0,s1
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6105                	addi	sp,sp,32
    800043b2:	8082                	ret

00000000800043b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800043b4:	1101                	addi	sp,sp,-32
    800043b6:	ec06                	sd	ra,24(sp)
    800043b8:	e822                	sd	s0,16(sp)
    800043ba:	e426                	sd	s1,8(sp)
    800043bc:	1000                	addi	s0,sp,32
    800043be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800043c0:	00243517          	auipc	a0,0x243
    800043c4:	70850513          	addi	a0,a0,1800 # 80247ac8 <ftable>
    800043c8:	8d9fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    800043cc:	40dc                	lw	a5,4(s1)
    800043ce:	02f05063          	blez	a5,800043ee <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800043d2:	2785                	addiw	a5,a5,1
    800043d4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043d6:	00243517          	auipc	a0,0x243
    800043da:	6f250513          	addi	a0,a0,1778 # 80247ac8 <ftable>
    800043de:	95bfc0ef          	jal	ra,80000d38 <release>
  return f;
}
    800043e2:	8526                	mv	a0,s1
    800043e4:	60e2                	ld	ra,24(sp)
    800043e6:	6442                	ld	s0,16(sp)
    800043e8:	64a2                	ld	s1,8(sp)
    800043ea:	6105                	addi	sp,sp,32
    800043ec:	8082                	ret
    panic("filedup");
    800043ee:	00003517          	auipc	a0,0x3
    800043f2:	29a50513          	addi	a0,a0,666 # 80007688 <syscalls+0x290>
    800043f6:	b92fc0ef          	jal	ra,80000788 <panic>

00000000800043fa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043fa:	7139                	addi	sp,sp,-64
    800043fc:	fc06                	sd	ra,56(sp)
    800043fe:	f822                	sd	s0,48(sp)
    80004400:	f426                	sd	s1,40(sp)
    80004402:	f04a                	sd	s2,32(sp)
    80004404:	ec4e                	sd	s3,24(sp)
    80004406:	e852                	sd	s4,16(sp)
    80004408:	e456                	sd	s5,8(sp)
    8000440a:	0080                	addi	s0,sp,64
    8000440c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000440e:	00243517          	auipc	a0,0x243
    80004412:	6ba50513          	addi	a0,a0,1722 # 80247ac8 <ftable>
    80004416:	88bfc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    8000441a:	40dc                	lw	a5,4(s1)
    8000441c:	04f05963          	blez	a5,8000446e <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004420:	37fd                	addiw	a5,a5,-1
    80004422:	0007871b          	sext.w	a4,a5
    80004426:	c0dc                	sw	a5,4(s1)
    80004428:	04e04963          	bgtz	a4,8000447a <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000442c:	0004a903          	lw	s2,0(s1)
    80004430:	0094ca83          	lbu	s5,9(s1)
    80004434:	0104ba03          	ld	s4,16(s1)
    80004438:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000443c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004440:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004444:	00243517          	auipc	a0,0x243
    80004448:	68450513          	addi	a0,a0,1668 # 80247ac8 <ftable>
    8000444c:	8edfc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    80004450:	4785                	li	a5,1
    80004452:	04f90363          	beq	s2,a5,80004498 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004456:	3979                	addiw	s2,s2,-2
    80004458:	4785                	li	a5,1
    8000445a:	0327e663          	bltu	a5,s2,80004486 <fileclose+0x8c>
    begin_op();
    8000445e:	b93ff0ef          	jal	ra,80003ff0 <begin_op>
    iput(ff.ip);
    80004462:	854e                	mv	a0,s3
    80004464:	b22ff0ef          	jal	ra,80003786 <iput>
    end_op();
    80004468:	bf7ff0ef          	jal	ra,8000405e <end_op>
    8000446c:	a829                	j	80004486 <fileclose+0x8c>
    panic("fileclose");
    8000446e:	00003517          	auipc	a0,0x3
    80004472:	22250513          	addi	a0,a0,546 # 80007690 <syscalls+0x298>
    80004476:	b12fc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    8000447a:	00243517          	auipc	a0,0x243
    8000447e:	64e50513          	addi	a0,a0,1614 # 80247ac8 <ftable>
    80004482:	8b7fc0ef          	jal	ra,80000d38 <release>
  }
}
    80004486:	70e2                	ld	ra,56(sp)
    80004488:	7442                	ld	s0,48(sp)
    8000448a:	74a2                	ld	s1,40(sp)
    8000448c:	7902                	ld	s2,32(sp)
    8000448e:	69e2                	ld	s3,24(sp)
    80004490:	6a42                	ld	s4,16(sp)
    80004492:	6aa2                	ld	s5,8(sp)
    80004494:	6121                	addi	sp,sp,64
    80004496:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004498:	85d6                	mv	a1,s5
    8000449a:	8552                	mv	a0,s4
    8000449c:	2ec000ef          	jal	ra,80004788 <pipeclose>
    800044a0:	b7dd                	j	80004486 <fileclose+0x8c>

00000000800044a2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800044a2:	715d                	addi	sp,sp,-80
    800044a4:	e486                	sd	ra,72(sp)
    800044a6:	e0a2                	sd	s0,64(sp)
    800044a8:	fc26                	sd	s1,56(sp)
    800044aa:	f84a                	sd	s2,48(sp)
    800044ac:	f44e                	sd	s3,40(sp)
    800044ae:	0880                	addi	s0,sp,80
    800044b0:	84aa                	mv	s1,a0
    800044b2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800044b4:	e1efd0ef          	jal	ra,80001ad2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800044b8:	409c                	lw	a5,0(s1)
    800044ba:	37f9                	addiw	a5,a5,-2
    800044bc:	4705                	li	a4,1
    800044be:	02f76f63          	bltu	a4,a5,800044fc <filestat+0x5a>
    800044c2:	892a                	mv	s2,a0
    ilock(f->ip);
    800044c4:	6c88                	ld	a0,24(s1)
    800044c6:	942ff0ef          	jal	ra,80003608 <ilock>
    stati(f->ip, &st);
    800044ca:	fb840593          	addi	a1,s0,-72
    800044ce:	6c88                	ld	a0,24(s1)
    800044d0:	c9aff0ef          	jal	ra,8000396a <stati>
    iunlock(f->ip);
    800044d4:	6c88                	ld	a0,24(s1)
    800044d6:	9dcff0ef          	jal	ra,800036b2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044da:	46e1                	li	a3,24
    800044dc:	fb840613          	addi	a2,s0,-72
    800044e0:	85ce                	mv	a1,s3
    800044e2:	05093503          	ld	a0,80(s2)
    800044e6:	a78fd0ef          	jal	ra,8000175e <copyout>
    800044ea:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800044ee:	60a6                	ld	ra,72(sp)
    800044f0:	6406                	ld	s0,64(sp)
    800044f2:	74e2                	ld	s1,56(sp)
    800044f4:	7942                	ld	s2,48(sp)
    800044f6:	79a2                	ld	s3,40(sp)
    800044f8:	6161                	addi	sp,sp,80
    800044fa:	8082                	ret
  return -1;
    800044fc:	557d                	li	a0,-1
    800044fe:	bfc5                	j	800044ee <filestat+0x4c>

0000000080004500 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004500:	7179                	addi	sp,sp,-48
    80004502:	f406                	sd	ra,40(sp)
    80004504:	f022                	sd	s0,32(sp)
    80004506:	ec26                	sd	s1,24(sp)
    80004508:	e84a                	sd	s2,16(sp)
    8000450a:	e44e                	sd	s3,8(sp)
    8000450c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000450e:	00854783          	lbu	a5,8(a0)
    80004512:	cbc1                	beqz	a5,800045a2 <fileread+0xa2>
    80004514:	84aa                	mv	s1,a0
    80004516:	89ae                	mv	s3,a1
    80004518:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000451a:	411c                	lw	a5,0(a0)
    8000451c:	4705                	li	a4,1
    8000451e:	04e78363          	beq	a5,a4,80004564 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004522:	470d                	li	a4,3
    80004524:	04e78563          	beq	a5,a4,8000456e <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004528:	4709                	li	a4,2
    8000452a:	06e79663          	bne	a5,a4,80004596 <fileread+0x96>
    ilock(f->ip);
    8000452e:	6d08                	ld	a0,24(a0)
    80004530:	8d8ff0ef          	jal	ra,80003608 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004534:	874a                	mv	a4,s2
    80004536:	5094                	lw	a3,32(s1)
    80004538:	864e                	mv	a2,s3
    8000453a:	4585                	li	a1,1
    8000453c:	6c88                	ld	a0,24(s1)
    8000453e:	c56ff0ef          	jal	ra,80003994 <readi>
    80004542:	892a                	mv	s2,a0
    80004544:	00a05563          	blez	a0,8000454e <fileread+0x4e>
      f->off += r;
    80004548:	509c                	lw	a5,32(s1)
    8000454a:	9fa9                	addw	a5,a5,a0
    8000454c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000454e:	6c88                	ld	a0,24(s1)
    80004550:	962ff0ef          	jal	ra,800036b2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004554:	854a                	mv	a0,s2
    80004556:	70a2                	ld	ra,40(sp)
    80004558:	7402                	ld	s0,32(sp)
    8000455a:	64e2                	ld	s1,24(sp)
    8000455c:	6942                	ld	s2,16(sp)
    8000455e:	69a2                	ld	s3,8(sp)
    80004560:	6145                	addi	sp,sp,48
    80004562:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004564:	6908                	ld	a0,16(a0)
    80004566:	34e000ef          	jal	ra,800048b4 <piperead>
    8000456a:	892a                	mv	s2,a0
    8000456c:	b7e5                	j	80004554 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000456e:	02451783          	lh	a5,36(a0)
    80004572:	03079693          	slli	a3,a5,0x30
    80004576:	92c1                	srli	a3,a3,0x30
    80004578:	4725                	li	a4,9
    8000457a:	02d76663          	bltu	a4,a3,800045a6 <fileread+0xa6>
    8000457e:	0792                	slli	a5,a5,0x4
    80004580:	00243717          	auipc	a4,0x243
    80004584:	4a870713          	addi	a4,a4,1192 # 80247a28 <devsw>
    80004588:	97ba                	add	a5,a5,a4
    8000458a:	639c                	ld	a5,0(a5)
    8000458c:	cf99                	beqz	a5,800045aa <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    8000458e:	4505                	li	a0,1
    80004590:	9782                	jalr	a5
    80004592:	892a                	mv	s2,a0
    80004594:	b7c1                	j	80004554 <fileread+0x54>
    panic("fileread");
    80004596:	00003517          	auipc	a0,0x3
    8000459a:	10a50513          	addi	a0,a0,266 # 800076a0 <syscalls+0x2a8>
    8000459e:	9eafc0ef          	jal	ra,80000788 <panic>
    return -1;
    800045a2:	597d                	li	s2,-1
    800045a4:	bf45                	j	80004554 <fileread+0x54>
      return -1;
    800045a6:	597d                	li	s2,-1
    800045a8:	b775                	j	80004554 <fileread+0x54>
    800045aa:	597d                	li	s2,-1
    800045ac:	b765                	j	80004554 <fileread+0x54>

00000000800045ae <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800045ae:	715d                	addi	sp,sp,-80
    800045b0:	e486                	sd	ra,72(sp)
    800045b2:	e0a2                	sd	s0,64(sp)
    800045b4:	fc26                	sd	s1,56(sp)
    800045b6:	f84a                	sd	s2,48(sp)
    800045b8:	f44e                	sd	s3,40(sp)
    800045ba:	f052                	sd	s4,32(sp)
    800045bc:	ec56                	sd	s5,24(sp)
    800045be:	e85a                	sd	s6,16(sp)
    800045c0:	e45e                	sd	s7,8(sp)
    800045c2:	e062                	sd	s8,0(sp)
    800045c4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800045c6:	00954783          	lbu	a5,9(a0)
    800045ca:	0e078863          	beqz	a5,800046ba <filewrite+0x10c>
    800045ce:	892a                	mv	s2,a0
    800045d0:	8b2e                	mv	s6,a1
    800045d2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800045d4:	411c                	lw	a5,0(a0)
    800045d6:	4705                	li	a4,1
    800045d8:	02e78263          	beq	a5,a4,800045fc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045dc:	470d                	li	a4,3
    800045de:	02e78463          	beq	a5,a4,80004606 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800045e2:	4709                	li	a4,2
    800045e4:	0ce79563          	bne	a5,a4,800046ae <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800045e8:	0ac05163          	blez	a2,8000468a <filewrite+0xdc>
    int i = 0;
    800045ec:	4981                	li	s3,0
    800045ee:	6b85                	lui	s7,0x1
    800045f0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800045f4:	6c05                	lui	s8,0x1
    800045f6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800045fa:	a041                	j	8000467a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800045fc:	6908                	ld	a0,16(a0)
    800045fe:	1e2000ef          	jal	ra,800047e0 <pipewrite>
    80004602:	8a2a                	mv	s4,a0
    80004604:	a071                	j	80004690 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004606:	02451783          	lh	a5,36(a0)
    8000460a:	03079693          	slli	a3,a5,0x30
    8000460e:	92c1                	srli	a3,a3,0x30
    80004610:	4725                	li	a4,9
    80004612:	0ad76663          	bltu	a4,a3,800046be <filewrite+0x110>
    80004616:	0792                	slli	a5,a5,0x4
    80004618:	00243717          	auipc	a4,0x243
    8000461c:	41070713          	addi	a4,a4,1040 # 80247a28 <devsw>
    80004620:	97ba                	add	a5,a5,a4
    80004622:	679c                	ld	a5,8(a5)
    80004624:	cfd9                	beqz	a5,800046c2 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004626:	4505                	li	a0,1
    80004628:	9782                	jalr	a5
    8000462a:	8a2a                	mv	s4,a0
    8000462c:	a095                	j	80004690 <filewrite+0xe2>
    8000462e:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004632:	9bfff0ef          	jal	ra,80003ff0 <begin_op>
      ilock(f->ip);
    80004636:	01893503          	ld	a0,24(s2)
    8000463a:	fcffe0ef          	jal	ra,80003608 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000463e:	8756                	mv	a4,s5
    80004640:	02092683          	lw	a3,32(s2)
    80004644:	01698633          	add	a2,s3,s6
    80004648:	4585                	li	a1,1
    8000464a:	01893503          	ld	a0,24(s2)
    8000464e:	c2aff0ef          	jal	ra,80003a78 <writei>
    80004652:	84aa                	mv	s1,a0
    80004654:	00a05763          	blez	a0,80004662 <filewrite+0xb4>
        f->off += r;
    80004658:	02092783          	lw	a5,32(s2)
    8000465c:	9fa9                	addw	a5,a5,a0
    8000465e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004662:	01893503          	ld	a0,24(s2)
    80004666:	84cff0ef          	jal	ra,800036b2 <iunlock>
      end_op();
    8000466a:	9f5ff0ef          	jal	ra,8000405e <end_op>

      if(r != n1){
    8000466e:	009a9f63          	bne	s5,s1,8000468c <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004672:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004676:	0149db63          	bge	s3,s4,8000468c <filewrite+0xde>
      int n1 = n - i;
    8000467a:	413a04bb          	subw	s1,s4,s3
    8000467e:	0004879b          	sext.w	a5,s1
    80004682:	fafbd6e3          	bge	s7,a5,8000462e <filewrite+0x80>
    80004686:	84e2                	mv	s1,s8
    80004688:	b75d                	j	8000462e <filewrite+0x80>
    int i = 0;
    8000468a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000468c:	013a1f63          	bne	s4,s3,800046aa <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004690:	8552                	mv	a0,s4
    80004692:	60a6                	ld	ra,72(sp)
    80004694:	6406                	ld	s0,64(sp)
    80004696:	74e2                	ld	s1,56(sp)
    80004698:	7942                	ld	s2,48(sp)
    8000469a:	79a2                	ld	s3,40(sp)
    8000469c:	7a02                	ld	s4,32(sp)
    8000469e:	6ae2                	ld	s5,24(sp)
    800046a0:	6b42                	ld	s6,16(sp)
    800046a2:	6ba2                	ld	s7,8(sp)
    800046a4:	6c02                	ld	s8,0(sp)
    800046a6:	6161                	addi	sp,sp,80
    800046a8:	8082                	ret
    ret = (i == n ? n : -1);
    800046aa:	5a7d                	li	s4,-1
    800046ac:	b7d5                	j	80004690 <filewrite+0xe2>
    panic("filewrite");
    800046ae:	00003517          	auipc	a0,0x3
    800046b2:	00250513          	addi	a0,a0,2 # 800076b0 <syscalls+0x2b8>
    800046b6:	8d2fc0ef          	jal	ra,80000788 <panic>
    return -1;
    800046ba:	5a7d                	li	s4,-1
    800046bc:	bfd1                	j	80004690 <filewrite+0xe2>
      return -1;
    800046be:	5a7d                	li	s4,-1
    800046c0:	bfc1                	j	80004690 <filewrite+0xe2>
    800046c2:	5a7d                	li	s4,-1
    800046c4:	b7f1                	j	80004690 <filewrite+0xe2>

00000000800046c6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800046c6:	7179                	addi	sp,sp,-48
    800046c8:	f406                	sd	ra,40(sp)
    800046ca:	f022                	sd	s0,32(sp)
    800046cc:	ec26                	sd	s1,24(sp)
    800046ce:	e84a                	sd	s2,16(sp)
    800046d0:	e44e                	sd	s3,8(sp)
    800046d2:	e052                	sd	s4,0(sp)
    800046d4:	1800                	addi	s0,sp,48
    800046d6:	84aa                	mv	s1,a0
    800046d8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800046da:	0005b023          	sd	zero,0(a1)
    800046de:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800046e2:	c75ff0ef          	jal	ra,80004356 <filealloc>
    800046e6:	e088                	sd	a0,0(s1)
    800046e8:	cd35                	beqz	a0,80004764 <pipealloc+0x9e>
    800046ea:	c6dff0ef          	jal	ra,80004356 <filealloc>
    800046ee:	00aa3023          	sd	a0,0(s4)
    800046f2:	c52d                	beqz	a0,8000475c <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800046f4:	cb6fc0ef          	jal	ra,80000baa <kalloc>
    800046f8:	892a                	mv	s2,a0
    800046fa:	cd31                	beqz	a0,80004756 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800046fc:	4985                	li	s3,1
    800046fe:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004702:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004706:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000470a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000470e:	00003597          	auipc	a1,0x3
    80004712:	fb258593          	addi	a1,a1,-78 # 800076c0 <syscalls+0x2c8>
    80004716:	d0afc0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    8000471a:	609c                	ld	a5,0(s1)
    8000471c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004720:	609c                	ld	a5,0(s1)
    80004722:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004726:	609c                	ld	a5,0(s1)
    80004728:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000472c:	609c                	ld	a5,0(s1)
    8000472e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004732:	000a3783          	ld	a5,0(s4)
    80004736:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000473a:	000a3783          	ld	a5,0(s4)
    8000473e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004742:	000a3783          	ld	a5,0(s4)
    80004746:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000474a:	000a3783          	ld	a5,0(s4)
    8000474e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004752:	4501                	li	a0,0
    80004754:	a005                	j	80004774 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004756:	6088                	ld	a0,0(s1)
    80004758:	e501                	bnez	a0,80004760 <pipealloc+0x9a>
    8000475a:	a029                	j	80004764 <pipealloc+0x9e>
    8000475c:	6088                	ld	a0,0(s1)
    8000475e:	c11d                	beqz	a0,80004784 <pipealloc+0xbe>
    fileclose(*f0);
    80004760:	c9bff0ef          	jal	ra,800043fa <fileclose>
  if(*f1)
    80004764:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004768:	557d                	li	a0,-1
  if(*f1)
    8000476a:	c789                	beqz	a5,80004774 <pipealloc+0xae>
    fileclose(*f1);
    8000476c:	853e                	mv	a0,a5
    8000476e:	c8dff0ef          	jal	ra,800043fa <fileclose>
  return -1;
    80004772:	557d                	li	a0,-1
}
    80004774:	70a2                	ld	ra,40(sp)
    80004776:	7402                	ld	s0,32(sp)
    80004778:	64e2                	ld	s1,24(sp)
    8000477a:	6942                	ld	s2,16(sp)
    8000477c:	69a2                	ld	s3,8(sp)
    8000477e:	6a02                	ld	s4,0(sp)
    80004780:	6145                	addi	sp,sp,48
    80004782:	8082                	ret
  return -1;
    80004784:	557d                	li	a0,-1
    80004786:	b7fd                	j	80004774 <pipealloc+0xae>

0000000080004788 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004788:	1101                	addi	sp,sp,-32
    8000478a:	ec06                	sd	ra,24(sp)
    8000478c:	e822                	sd	s0,16(sp)
    8000478e:	e426                	sd	s1,8(sp)
    80004790:	e04a                	sd	s2,0(sp)
    80004792:	1000                	addi	s0,sp,32
    80004794:	84aa                	mv	s1,a0
    80004796:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004798:	d08fc0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    8000479c:	02090763          	beqz	s2,800047ca <pipeclose+0x42>
    pi->writeopen = 0;
    800047a0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800047a4:	21848513          	addi	a0,s1,536
    800047a8:	97ffd0ef          	jal	ra,80002126 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800047ac:	2204b783          	ld	a5,544(s1)
    800047b0:	e785                	bnez	a5,800047d8 <pipeclose+0x50>
    release(&pi->lock);
    800047b2:	8526                	mv	a0,s1
    800047b4:	d84fc0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    800047b8:	8526                	mv	a0,s1
    800047ba:	ac0fc0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    800047be:	60e2                	ld	ra,24(sp)
    800047c0:	6442                	ld	s0,16(sp)
    800047c2:	64a2                	ld	s1,8(sp)
    800047c4:	6902                	ld	s2,0(sp)
    800047c6:	6105                	addi	sp,sp,32
    800047c8:	8082                	ret
    pi->readopen = 0;
    800047ca:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800047ce:	21c48513          	addi	a0,s1,540
    800047d2:	955fd0ef          	jal	ra,80002126 <wakeup>
    800047d6:	bfd9                	j	800047ac <pipeclose+0x24>
    release(&pi->lock);
    800047d8:	8526                	mv	a0,s1
    800047da:	d5efc0ef          	jal	ra,80000d38 <release>
}
    800047de:	b7c5                	j	800047be <pipeclose+0x36>

00000000800047e0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047e0:	711d                	addi	sp,sp,-96
    800047e2:	ec86                	sd	ra,88(sp)
    800047e4:	e8a2                	sd	s0,80(sp)
    800047e6:	e4a6                	sd	s1,72(sp)
    800047e8:	e0ca                	sd	s2,64(sp)
    800047ea:	fc4e                	sd	s3,56(sp)
    800047ec:	f852                	sd	s4,48(sp)
    800047ee:	f456                	sd	s5,40(sp)
    800047f0:	f05a                	sd	s6,32(sp)
    800047f2:	ec5e                	sd	s7,24(sp)
    800047f4:	e862                	sd	s8,16(sp)
    800047f6:	1080                	addi	s0,sp,96
    800047f8:	84aa                	mv	s1,a0
    800047fa:	8aae                	mv	s5,a1
    800047fc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800047fe:	ad4fd0ef          	jal	ra,80001ad2 <myproc>
    80004802:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004804:	8526                	mv	a0,s1
    80004806:	c9afc0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    8000480a:	09405c63          	blez	s4,800048a2 <pipewrite+0xc2>
  int i = 0;
    8000480e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004810:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004812:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004816:	21c48b93          	addi	s7,s1,540
    8000481a:	a81d                	j	80004850 <pipewrite+0x70>
      release(&pi->lock);
    8000481c:	8526                	mv	a0,s1
    8000481e:	d1afc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004822:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004824:	854a                	mv	a0,s2
    80004826:	60e6                	ld	ra,88(sp)
    80004828:	6446                	ld	s0,80(sp)
    8000482a:	64a6                	ld	s1,72(sp)
    8000482c:	6906                	ld	s2,64(sp)
    8000482e:	79e2                	ld	s3,56(sp)
    80004830:	7a42                	ld	s4,48(sp)
    80004832:	7aa2                	ld	s5,40(sp)
    80004834:	7b02                	ld	s6,32(sp)
    80004836:	6be2                	ld	s7,24(sp)
    80004838:	6c42                	ld	s8,16(sp)
    8000483a:	6125                	addi	sp,sp,96
    8000483c:	8082                	ret
      wakeup(&pi->nread);
    8000483e:	8562                	mv	a0,s8
    80004840:	8e7fd0ef          	jal	ra,80002126 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004844:	85a6                	mv	a1,s1
    80004846:	855e                	mv	a0,s7
    80004848:	893fd0ef          	jal	ra,800020da <sleep>
  while(i < n){
    8000484c:	05495c63          	bge	s2,s4,800048a4 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004850:	2204a783          	lw	a5,544(s1)
    80004854:	d7e1                	beqz	a5,8000481c <pipewrite+0x3c>
    80004856:	854e                	mv	a0,s3
    80004858:	abbfd0ef          	jal	ra,80002312 <killed>
    8000485c:	f161                	bnez	a0,8000481c <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000485e:	2184a783          	lw	a5,536(s1)
    80004862:	21c4a703          	lw	a4,540(s1)
    80004866:	2007879b          	addiw	a5,a5,512
    8000486a:	fcf70ae3          	beq	a4,a5,8000483e <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000486e:	4685                	li	a3,1
    80004870:	01590633          	add	a2,s2,s5
    80004874:	faf40593          	addi	a1,s0,-81
    80004878:	0509b503          	ld	a0,80(s3)
    8000487c:	fcdfc0ef          	jal	ra,80001848 <copyin>
    80004880:	03650263          	beq	a0,s6,800048a4 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004884:	21c4a783          	lw	a5,540(s1)
    80004888:	0017871b          	addiw	a4,a5,1
    8000488c:	20e4ae23          	sw	a4,540(s1)
    80004890:	1ff7f793          	andi	a5,a5,511
    80004894:	97a6                	add	a5,a5,s1
    80004896:	faf44703          	lbu	a4,-81(s0)
    8000489a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000489e:	2905                	addiw	s2,s2,1
    800048a0:	b775                	j	8000484c <pipewrite+0x6c>
  int i = 0;
    800048a2:	4901                	li	s2,0
  wakeup(&pi->nread);
    800048a4:	21848513          	addi	a0,s1,536
    800048a8:	87ffd0ef          	jal	ra,80002126 <wakeup>
  release(&pi->lock);
    800048ac:	8526                	mv	a0,s1
    800048ae:	c8afc0ef          	jal	ra,80000d38 <release>
  return i;
    800048b2:	bf8d                	j	80004824 <pipewrite+0x44>

00000000800048b4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048b4:	715d                	addi	sp,sp,-80
    800048b6:	e486                	sd	ra,72(sp)
    800048b8:	e0a2                	sd	s0,64(sp)
    800048ba:	fc26                	sd	s1,56(sp)
    800048bc:	f84a                	sd	s2,48(sp)
    800048be:	f44e                	sd	s3,40(sp)
    800048c0:	f052                	sd	s4,32(sp)
    800048c2:	ec56                	sd	s5,24(sp)
    800048c4:	e85a                	sd	s6,16(sp)
    800048c6:	0880                	addi	s0,sp,80
    800048c8:	84aa                	mv	s1,a0
    800048ca:	892e                	mv	s2,a1
    800048cc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048ce:	a04fd0ef          	jal	ra,80001ad2 <myproc>
    800048d2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800048d4:	8526                	mv	a0,s1
    800048d6:	bcafc0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800048da:	2184a703          	lw	a4,536(s1)
    800048de:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800048e2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800048e6:	02f71363          	bne	a4,a5,8000490c <piperead+0x58>
    800048ea:	2244a783          	lw	a5,548(s1)
    800048ee:	cf99                	beqz	a5,8000490c <piperead+0x58>
    if(killed(pr)){
    800048f0:	8552                	mv	a0,s4
    800048f2:	a21fd0ef          	jal	ra,80002312 <killed>
    800048f6:	e151                	bnez	a0,8000497a <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800048f8:	85a6                	mv	a1,s1
    800048fa:	854e                	mv	a0,s3
    800048fc:	fdefd0ef          	jal	ra,800020da <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004900:	2184a703          	lw	a4,536(s1)
    80004904:	21c4a783          	lw	a5,540(s1)
    80004908:	fef701e3          	beq	a4,a5,800048ea <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000490c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000490e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004910:	05505363          	blez	s5,80004956 <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    80004914:	2184a783          	lw	a5,536(s1)
    80004918:	21c4a703          	lw	a4,540(s1)
    8000491c:	02f70d63          	beq	a4,a5,80004956 <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004920:	1ff7f793          	andi	a5,a5,511
    80004924:	97a6                	add	a5,a5,s1
    80004926:	0187c783          	lbu	a5,24(a5)
    8000492a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000492e:	4685                	li	a3,1
    80004930:	fbf40613          	addi	a2,s0,-65
    80004934:	85ca                	mv	a1,s2
    80004936:	050a3503          	ld	a0,80(s4)
    8000493a:	e25fc0ef          	jal	ra,8000175e <copyout>
    8000493e:	05650363          	beq	a0,s6,80004984 <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004942:	2184a783          	lw	a5,536(s1)
    80004946:	2785                	addiw	a5,a5,1
    80004948:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000494c:	2985                	addiw	s3,s3,1
    8000494e:	0905                	addi	s2,s2,1
    80004950:	fd3a92e3          	bne	s5,s3,80004914 <piperead+0x60>
    80004954:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004956:	21c48513          	addi	a0,s1,540
    8000495a:	fccfd0ef          	jal	ra,80002126 <wakeup>
  release(&pi->lock);
    8000495e:	8526                	mv	a0,s1
    80004960:	bd8fc0ef          	jal	ra,80000d38 <release>
  return i;
}
    80004964:	854e                	mv	a0,s3
    80004966:	60a6                	ld	ra,72(sp)
    80004968:	6406                	ld	s0,64(sp)
    8000496a:	74e2                	ld	s1,56(sp)
    8000496c:	7942                	ld	s2,48(sp)
    8000496e:	79a2                	ld	s3,40(sp)
    80004970:	7a02                	ld	s4,32(sp)
    80004972:	6ae2                	ld	s5,24(sp)
    80004974:	6b42                	ld	s6,16(sp)
    80004976:	6161                	addi	sp,sp,80
    80004978:	8082                	ret
      release(&pi->lock);
    8000497a:	8526                	mv	a0,s1
    8000497c:	bbcfc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004980:	59fd                	li	s3,-1
    80004982:	b7cd                	j	80004964 <piperead+0xb0>
      if(i == 0)
    80004984:	fc0999e3          	bnez	s3,80004956 <piperead+0xa2>
        i = -1;
    80004988:	89aa                	mv	s3,a0
    8000498a:	b7f1                	j	80004956 <piperead+0xa2>

000000008000498c <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000498c:	1141                	addi	sp,sp,-16
    8000498e:	e422                	sd	s0,8(sp)
    80004990:	0800                	addi	s0,sp,16
    80004992:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004994:	8905                	andi	a0,a0,1
    80004996:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004998:	8b89                	andi	a5,a5,2
    8000499a:	c399                	beqz	a5,800049a0 <flags2perm+0x14>
      perm |= PTE_W;
    8000499c:	00456513          	ori	a0,a0,4
    return perm;
}
    800049a0:	6422                	ld	s0,8(sp)
    800049a2:	0141                	addi	sp,sp,16
    800049a4:	8082                	ret

00000000800049a6 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049a6:	de010113          	addi	sp,sp,-544
    800049aa:	20113c23          	sd	ra,536(sp)
    800049ae:	20813823          	sd	s0,528(sp)
    800049b2:	20913423          	sd	s1,520(sp)
    800049b6:	21213023          	sd	s2,512(sp)
    800049ba:	ffce                	sd	s3,504(sp)
    800049bc:	fbd2                	sd	s4,496(sp)
    800049be:	f7d6                	sd	s5,488(sp)
    800049c0:	f3da                	sd	s6,480(sp)
    800049c2:	efde                	sd	s7,472(sp)
    800049c4:	ebe2                	sd	s8,464(sp)
    800049c6:	e7e6                	sd	s9,456(sp)
    800049c8:	e3ea                	sd	s10,448(sp)
    800049ca:	ff6e                	sd	s11,440(sp)
    800049cc:	1400                	addi	s0,sp,544
    800049ce:	892a                	mv	s2,a0
    800049d0:	dea43423          	sd	a0,-536(s0)
    800049d4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049d8:	8fafd0ef          	jal	ra,80001ad2 <myproc>
    800049dc:	84aa                	mv	s1,a0

  begin_op();
    800049de:	e12ff0ef          	jal	ra,80003ff0 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800049e2:	854a                	mv	a0,s2
    800049e4:	c18ff0ef          	jal	ra,80003dfc <namei>
    800049e8:	c13d                	beqz	a0,80004a4e <kexec+0xa8>
    800049ea:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049ec:	c1dfe0ef          	jal	ra,80003608 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049f0:	04000713          	li	a4,64
    800049f4:	4681                	li	a3,0
    800049f6:	e5040613          	addi	a2,s0,-432
    800049fa:	4581                	li	a1,0
    800049fc:	8556                	mv	a0,s5
    800049fe:	f97fe0ef          	jal	ra,80003994 <readi>
    80004a02:	04000793          	li	a5,64
    80004a06:	00f51a63          	bne	a0,a5,80004a1a <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004a0a:	e5042703          	lw	a4,-432(s0)
    80004a0e:	464c47b7          	lui	a5,0x464c4
    80004a12:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a16:	04f70063          	beq	a4,a5,80004a56 <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a1a:	8556                	mv	a0,s5
    80004a1c:	df3fe0ef          	jal	ra,8000380e <iunlockput>
    end_op();
    80004a20:	e3eff0ef          	jal	ra,8000405e <end_op>
  }
  return -1;
    80004a24:	557d                	li	a0,-1
}
    80004a26:	21813083          	ld	ra,536(sp)
    80004a2a:	21013403          	ld	s0,528(sp)
    80004a2e:	20813483          	ld	s1,520(sp)
    80004a32:	20013903          	ld	s2,512(sp)
    80004a36:	79fe                	ld	s3,504(sp)
    80004a38:	7a5e                	ld	s4,496(sp)
    80004a3a:	7abe                	ld	s5,488(sp)
    80004a3c:	7b1e                	ld	s6,480(sp)
    80004a3e:	6bfe                	ld	s7,472(sp)
    80004a40:	6c5e                	ld	s8,464(sp)
    80004a42:	6cbe                	ld	s9,456(sp)
    80004a44:	6d1e                	ld	s10,448(sp)
    80004a46:	7dfa                	ld	s11,440(sp)
    80004a48:	22010113          	addi	sp,sp,544
    80004a4c:	8082                	ret
    end_op();
    80004a4e:	e10ff0ef          	jal	ra,8000405e <end_op>
    return -1;
    80004a52:	557d                	li	a0,-1
    80004a54:	bfc9                	j	80004a26 <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80004a56:	8526                	mv	a0,s1
    80004a58:	980fd0ef          	jal	ra,80001bd8 <proc_pagetable>
    80004a5c:	8b2a                	mv	s6,a0
    80004a5e:	dd55                	beqz	a0,80004a1a <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a60:	e7042783          	lw	a5,-400(s0)
    80004a64:	e8845703          	lhu	a4,-376(s0)
    80004a68:	c325                	beqz	a4,80004ac8 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a6a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a6c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004a70:	6a05                	lui	s4,0x1
    80004a72:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004a76:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004a7a:	6d85                	lui	s11,0x1
    80004a7c:	7d7d                	lui	s10,0xfffff
    80004a7e:	a409                	j	80004c80 <kexec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004a80:	00003517          	auipc	a0,0x3
    80004a84:	c4850513          	addi	a0,a0,-952 # 800076c8 <syscalls+0x2d0>
    80004a88:	d01fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a8c:	874a                	mv	a4,s2
    80004a8e:	009c86bb          	addw	a3,s9,s1
    80004a92:	4581                	li	a1,0
    80004a94:	8556                	mv	a0,s5
    80004a96:	efffe0ef          	jal	ra,80003994 <readi>
    80004a9a:	2501                	sext.w	a0,a0
    80004a9c:	18a91163          	bne	s2,a0,80004c1e <kexec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80004aa0:	009d84bb          	addw	s1,s11,s1
    80004aa4:	013d09bb          	addw	s3,s10,s3
    80004aa8:	1b74fc63          	bgeu	s1,s7,80004c60 <kexec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80004aac:	02049593          	slli	a1,s1,0x20
    80004ab0:	9181                	srli	a1,a1,0x20
    80004ab2:	95e2                	add	a1,a1,s8
    80004ab4:	855a                	mv	a0,s6
    80004ab6:	dd4fc0ef          	jal	ra,8000108a <walkaddr>
    80004aba:	862a                	mv	a2,a0
    if(pa == 0)
    80004abc:	d171                	beqz	a0,80004a80 <kexec+0xda>
      n = PGSIZE;
    80004abe:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004ac0:	fd49f6e3          	bgeu	s3,s4,80004a8c <kexec+0xe6>
      n = sz - i;
    80004ac4:	894e                	mv	s2,s3
    80004ac6:	b7d9                	j	80004a8c <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ac8:	4901                	li	s2,0
  iunlockput(ip);
    80004aca:	8556                	mv	a0,s5
    80004acc:	d43fe0ef          	jal	ra,8000380e <iunlockput>
  end_op();
    80004ad0:	d8eff0ef          	jal	ra,8000405e <end_op>
  p = myproc();
    80004ad4:	ffffc0ef          	jal	ra,80001ad2 <myproc>
    80004ad8:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ada:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004ade:	6785                	lui	a5,0x1
    80004ae0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004ae2:	97ca                	add	a5,a5,s2
    80004ae4:	777d                	lui	a4,0xfffff
    80004ae6:	8ff9                	and	a5,a5,a4
    80004ae8:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004aec:	4691                	li	a3,4
    80004aee:	6609                	lui	a2,0x2
    80004af0:	963e                	add	a2,a2,a5
    80004af2:	85be                	mv	a1,a5
    80004af4:	855a                	mv	a0,s6
    80004af6:	85ffc0ef          	jal	ra,80001354 <uvmalloc>
    80004afa:	8c2a                	mv	s8,a0
  ip = 0;
    80004afc:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004afe:	12050063          	beqz	a0,80004c1e <kexec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b02:	75f9                	lui	a1,0xffffe
    80004b04:	95aa                	add	a1,a1,a0
    80004b06:	855a                	mv	a0,s6
    80004b08:	aeffc0ef          	jal	ra,800015f6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b0c:	7afd                	lui	s5,0xfffff
    80004b0e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004b10:	df043783          	ld	a5,-528(s0)
    80004b14:	6388                	ld	a0,0(a5)
    80004b16:	c135                	beqz	a0,80004b7a <kexec+0x1d4>
    80004b18:	e9040993          	addi	s3,s0,-368
    80004b1c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004b20:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004b22:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004b24:	bc8fc0ef          	jal	ra,80000eec <strlen>
    80004b28:	0015079b          	addiw	a5,a0,1
    80004b2c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b30:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b34:	11596a63          	bltu	s2,s5,80004c48 <kexec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b38:	df043d83          	ld	s11,-528(s0)
    80004b3c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004b40:	8552                	mv	a0,s4
    80004b42:	baafc0ef          	jal	ra,80000eec <strlen>
    80004b46:	0015069b          	addiw	a3,a0,1
    80004b4a:	8652                	mv	a2,s4
    80004b4c:	85ca                	mv	a1,s2
    80004b4e:	855a                	mv	a0,s6
    80004b50:	c0ffc0ef          	jal	ra,8000175e <copyout>
    80004b54:	0e054e63          	bltz	a0,80004c50 <kexec+0x2aa>
    ustack[argc] = sp;
    80004b58:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004b5c:	0485                	addi	s1,s1,1
    80004b5e:	008d8793          	addi	a5,s11,8
    80004b62:	def43823          	sd	a5,-528(s0)
    80004b66:	008db503          	ld	a0,8(s11)
    80004b6a:	c911                	beqz	a0,80004b7e <kexec+0x1d8>
    if(argc >= MAXARG)
    80004b6c:	09a1                	addi	s3,s3,8
    80004b6e:	fb3c9be3          	bne	s9,s3,80004b24 <kexec+0x17e>
  sz = sz1;
    80004b72:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004b76:	4a81                	li	s5,0
    80004b78:	a05d                	j	80004c1e <kexec+0x278>
  sp = sz;
    80004b7a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004b7c:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b7e:	00349793          	slli	a5,s1,0x3
    80004b82:	f9078793          	addi	a5,a5,-112
    80004b86:	97a2                	add	a5,a5,s0
    80004b88:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b8c:	00148693          	addi	a3,s1,1
    80004b90:	068e                	slli	a3,a3,0x3
    80004b92:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b96:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004b9a:	01597663          	bgeu	s2,s5,80004ba6 <kexec+0x200>
  sz = sz1;
    80004b9e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ba2:	4a81                	li	s5,0
    80004ba4:	a8ad                	j	80004c1e <kexec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ba6:	e9040613          	addi	a2,s0,-368
    80004baa:	85ca                	mv	a1,s2
    80004bac:	855a                	mv	a0,s6
    80004bae:	bb1fc0ef          	jal	ra,8000175e <copyout>
    80004bb2:	0a054363          	bltz	a0,80004c58 <kexec+0x2b2>
  p->trapframe->a1 = sp;
    80004bb6:	058bb783          	ld	a5,88(s7)
    80004bba:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004bbe:	de843783          	ld	a5,-536(s0)
    80004bc2:	0007c703          	lbu	a4,0(a5)
    80004bc6:	cf11                	beqz	a4,80004be2 <kexec+0x23c>
    80004bc8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004bca:	02f00693          	li	a3,47
    80004bce:	a039                	j	80004bdc <kexec+0x236>
      last = s+1;
    80004bd0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004bd4:	0785                	addi	a5,a5,1
    80004bd6:	fff7c703          	lbu	a4,-1(a5)
    80004bda:	c701                	beqz	a4,80004be2 <kexec+0x23c>
    if(*s == '/')
    80004bdc:	fed71ce3          	bne	a4,a3,80004bd4 <kexec+0x22e>
    80004be0:	bfc5                	j	80004bd0 <kexec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80004be2:	4641                	li	a2,16
    80004be4:	de843583          	ld	a1,-536(s0)
    80004be8:	158b8513          	addi	a0,s7,344
    80004bec:	acefc0ef          	jal	ra,80000eba <safestrcpy>
  oldpagetable = p->pagetable;
    80004bf0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004bf4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004bf8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004bfc:	058bb783          	ld	a5,88(s7)
    80004c00:	e6843703          	ld	a4,-408(s0)
    80004c04:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c06:	058bb783          	ld	a5,88(s7)
    80004c0a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c0e:	85ea                	mv	a1,s10
    80004c10:	84cfd0ef          	jal	ra,80001c5c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c14:	0004851b          	sext.w	a0,s1
    80004c18:	b539                	j	80004a26 <kexec+0x80>
    80004c1a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c1e:	df843583          	ld	a1,-520(s0)
    80004c22:	855a                	mv	a0,s6
    80004c24:	838fd0ef          	jal	ra,80001c5c <proc_freepagetable>
  if(ip){
    80004c28:	de0a99e3          	bnez	s5,80004a1a <kexec+0x74>
  return -1;
    80004c2c:	557d                	li	a0,-1
    80004c2e:	bbe5                	j	80004a26 <kexec+0x80>
    80004c30:	df243c23          	sd	s2,-520(s0)
    80004c34:	b7ed                	j	80004c1e <kexec+0x278>
    80004c36:	df243c23          	sd	s2,-520(s0)
    80004c3a:	b7d5                	j	80004c1e <kexec+0x278>
    80004c3c:	df243c23          	sd	s2,-520(s0)
    80004c40:	bff9                	j	80004c1e <kexec+0x278>
    80004c42:	df243c23          	sd	s2,-520(s0)
    80004c46:	bfe1                	j	80004c1e <kexec+0x278>
  sz = sz1;
    80004c48:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004c4c:	4a81                	li	s5,0
    80004c4e:	bfc1                	j	80004c1e <kexec+0x278>
  sz = sz1;
    80004c50:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004c54:	4a81                	li	s5,0
    80004c56:	b7e1                	j	80004c1e <kexec+0x278>
  sz = sz1;
    80004c58:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004c5c:	4a81                	li	s5,0
    80004c5e:	b7c1                	j	80004c1e <kexec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004c60:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c64:	e0843783          	ld	a5,-504(s0)
    80004c68:	0017869b          	addiw	a3,a5,1
    80004c6c:	e0d43423          	sd	a3,-504(s0)
    80004c70:	e0043783          	ld	a5,-512(s0)
    80004c74:	0387879b          	addiw	a5,a5,56
    80004c78:	e8845703          	lhu	a4,-376(s0)
    80004c7c:	e4e6d7e3          	bge	a3,a4,80004aca <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c80:	2781                	sext.w	a5,a5
    80004c82:	e0f43023          	sd	a5,-512(s0)
    80004c86:	03800713          	li	a4,56
    80004c8a:	86be                	mv	a3,a5
    80004c8c:	e1840613          	addi	a2,s0,-488
    80004c90:	4581                	li	a1,0
    80004c92:	8556                	mv	a0,s5
    80004c94:	d01fe0ef          	jal	ra,80003994 <readi>
    80004c98:	03800793          	li	a5,56
    80004c9c:	f6f51fe3          	bne	a0,a5,80004c1a <kexec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80004ca0:	e1842783          	lw	a5,-488(s0)
    80004ca4:	4705                	li	a4,1
    80004ca6:	fae79fe3          	bne	a5,a4,80004c64 <kexec+0x2be>
    if(ph.memsz < ph.filesz)
    80004caa:	e4043483          	ld	s1,-448(s0)
    80004cae:	e3843783          	ld	a5,-456(s0)
    80004cb2:	f6f4efe3          	bltu	s1,a5,80004c30 <kexec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004cb6:	e2843783          	ld	a5,-472(s0)
    80004cba:	94be                	add	s1,s1,a5
    80004cbc:	f6f4ede3          	bltu	s1,a5,80004c36 <kexec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80004cc0:	de043703          	ld	a4,-544(s0)
    80004cc4:	8ff9                	and	a5,a5,a4
    80004cc6:	fbbd                	bnez	a5,80004c3c <kexec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004cc8:	e1c42503          	lw	a0,-484(s0)
    80004ccc:	cc1ff0ef          	jal	ra,8000498c <flags2perm>
    80004cd0:	86aa                	mv	a3,a0
    80004cd2:	8626                	mv	a2,s1
    80004cd4:	85ca                	mv	a1,s2
    80004cd6:	855a                	mv	a0,s6
    80004cd8:	e7cfc0ef          	jal	ra,80001354 <uvmalloc>
    80004cdc:	dea43c23          	sd	a0,-520(s0)
    80004ce0:	d12d                	beqz	a0,80004c42 <kexec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ce2:	e2843c03          	ld	s8,-472(s0)
    80004ce6:	e2042c83          	lw	s9,-480(s0)
    80004cea:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004cee:	f60b89e3          	beqz	s7,80004c60 <kexec+0x2ba>
    80004cf2:	89de                	mv	s3,s7
    80004cf4:	4481                	li	s1,0
    80004cf6:	bb5d                	j	80004aac <kexec+0x106>

0000000080004cf8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004cf8:	7179                	addi	sp,sp,-48
    80004cfa:	f406                	sd	ra,40(sp)
    80004cfc:	f022                	sd	s0,32(sp)
    80004cfe:	ec26                	sd	s1,24(sp)
    80004d00:	e84a                	sd	s2,16(sp)
    80004d02:	1800                	addi	s0,sp,48
    80004d04:	892e                	mv	s2,a1
    80004d06:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d08:	fdc40593          	addi	a1,s0,-36
    80004d0c:	d07fd0ef          	jal	ra,80002a12 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d10:	fdc42703          	lw	a4,-36(s0)
    80004d14:	47bd                	li	a5,15
    80004d16:	02e7e963          	bltu	a5,a4,80004d48 <argfd+0x50>
    80004d1a:	db9fc0ef          	jal	ra,80001ad2 <myproc>
    80004d1e:	fdc42703          	lw	a4,-36(s0)
    80004d22:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdb645a>
    80004d26:	078e                	slli	a5,a5,0x3
    80004d28:	953e                	add	a0,a0,a5
    80004d2a:	611c                	ld	a5,0(a0)
    80004d2c:	c385                	beqz	a5,80004d4c <argfd+0x54>
    return -1;
  if(pfd)
    80004d2e:	00090463          	beqz	s2,80004d36 <argfd+0x3e>
    *pfd = fd;
    80004d32:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004d36:	4501                	li	a0,0
  if(pf)
    80004d38:	c091                	beqz	s1,80004d3c <argfd+0x44>
    *pf = f;
    80004d3a:	e09c                	sd	a5,0(s1)
}
    80004d3c:	70a2                	ld	ra,40(sp)
    80004d3e:	7402                	ld	s0,32(sp)
    80004d40:	64e2                	ld	s1,24(sp)
    80004d42:	6942                	ld	s2,16(sp)
    80004d44:	6145                	addi	sp,sp,48
    80004d46:	8082                	ret
    return -1;
    80004d48:	557d                	li	a0,-1
    80004d4a:	bfcd                	j	80004d3c <argfd+0x44>
    80004d4c:	557d                	li	a0,-1
    80004d4e:	b7fd                	j	80004d3c <argfd+0x44>

0000000080004d50 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d50:	1101                	addi	sp,sp,-32
    80004d52:	ec06                	sd	ra,24(sp)
    80004d54:	e822                	sd	s0,16(sp)
    80004d56:	e426                	sd	s1,8(sp)
    80004d58:	1000                	addi	s0,sp,32
    80004d5a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d5c:	d77fc0ef          	jal	ra,80001ad2 <myproc>
    80004d60:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d62:	0d050793          	addi	a5,a0,208
    80004d66:	4501                	li	a0,0
    80004d68:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d6a:	6398                	ld	a4,0(a5)
    80004d6c:	cb19                	beqz	a4,80004d82 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d6e:	2505                	addiw	a0,a0,1
    80004d70:	07a1                	addi	a5,a5,8
    80004d72:	fed51ce3          	bne	a0,a3,80004d6a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d76:	557d                	li	a0,-1
}
    80004d78:	60e2                	ld	ra,24(sp)
    80004d7a:	6442                	ld	s0,16(sp)
    80004d7c:	64a2                	ld	s1,8(sp)
    80004d7e:	6105                	addi	sp,sp,32
    80004d80:	8082                	ret
      p->ofile[fd] = f;
    80004d82:	01a50793          	addi	a5,a0,26
    80004d86:	078e                	slli	a5,a5,0x3
    80004d88:	963e                	add	a2,a2,a5
    80004d8a:	e204                	sd	s1,0(a2)
      return fd;
    80004d8c:	b7f5                	j	80004d78 <fdalloc+0x28>

0000000080004d8e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d8e:	715d                	addi	sp,sp,-80
    80004d90:	e486                	sd	ra,72(sp)
    80004d92:	e0a2                	sd	s0,64(sp)
    80004d94:	fc26                	sd	s1,56(sp)
    80004d96:	f84a                	sd	s2,48(sp)
    80004d98:	f44e                	sd	s3,40(sp)
    80004d9a:	f052                	sd	s4,32(sp)
    80004d9c:	ec56                	sd	s5,24(sp)
    80004d9e:	e85a                	sd	s6,16(sp)
    80004da0:	0880                	addi	s0,sp,80
    80004da2:	8b2e                	mv	s6,a1
    80004da4:	89b2                	mv	s3,a2
    80004da6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004da8:	fb040593          	addi	a1,s0,-80
    80004dac:	86aff0ef          	jal	ra,80003e16 <nameiparent>
    80004db0:	84aa                	mv	s1,a0
    80004db2:	10050b63          	beqz	a0,80004ec8 <create+0x13a>
    return 0;

  ilock(dp);
    80004db6:	853fe0ef          	jal	ra,80003608 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004dba:	4601                	li	a2,0
    80004dbc:	fb040593          	addi	a1,s0,-80
    80004dc0:	8526                	mv	a0,s1
    80004dc2:	dcffe0ef          	jal	ra,80003b90 <dirlookup>
    80004dc6:	8aaa                	mv	s5,a0
    80004dc8:	c521                	beqz	a0,80004e10 <create+0x82>
    iunlockput(dp);
    80004dca:	8526                	mv	a0,s1
    80004dcc:	a43fe0ef          	jal	ra,8000380e <iunlockput>
    ilock(ip);
    80004dd0:	8556                	mv	a0,s5
    80004dd2:	837fe0ef          	jal	ra,80003608 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004dd6:	000b059b          	sext.w	a1,s6
    80004dda:	4789                	li	a5,2
    80004ddc:	02f59563          	bne	a1,a5,80004e06 <create+0x78>
    80004de0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdb6484>
    80004de4:	37f9                	addiw	a5,a5,-2
    80004de6:	17c2                	slli	a5,a5,0x30
    80004de8:	93c1                	srli	a5,a5,0x30
    80004dea:	4705                	li	a4,1
    80004dec:	00f76d63          	bltu	a4,a5,80004e06 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004df0:	8556                	mv	a0,s5
    80004df2:	60a6                	ld	ra,72(sp)
    80004df4:	6406                	ld	s0,64(sp)
    80004df6:	74e2                	ld	s1,56(sp)
    80004df8:	7942                	ld	s2,48(sp)
    80004dfa:	79a2                	ld	s3,40(sp)
    80004dfc:	7a02                	ld	s4,32(sp)
    80004dfe:	6ae2                	ld	s5,24(sp)
    80004e00:	6b42                	ld	s6,16(sp)
    80004e02:	6161                	addi	sp,sp,80
    80004e04:	8082                	ret
    iunlockput(ip);
    80004e06:	8556                	mv	a0,s5
    80004e08:	a07fe0ef          	jal	ra,8000380e <iunlockput>
    return 0;
    80004e0c:	4a81                	li	s5,0
    80004e0e:	b7cd                	j	80004df0 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e10:	85da                	mv	a1,s6
    80004e12:	4088                	lw	a0,0(s1)
    80004e14:	e8afe0ef          	jal	ra,8000349e <ialloc>
    80004e18:	8a2a                	mv	s4,a0
    80004e1a:	cd1d                	beqz	a0,80004e58 <create+0xca>
  ilock(ip);
    80004e1c:	fecfe0ef          	jal	ra,80003608 <ilock>
  ip->major = major;
    80004e20:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004e24:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004e28:	4905                	li	s2,1
    80004e2a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004e2e:	8552                	mv	a0,s4
    80004e30:	f24fe0ef          	jal	ra,80003554 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004e34:	000b059b          	sext.w	a1,s6
    80004e38:	03258563          	beq	a1,s2,80004e62 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e3c:	004a2603          	lw	a2,4(s4)
    80004e40:	fb040593          	addi	a1,s0,-80
    80004e44:	8526                	mv	a0,s1
    80004e46:	f1dfe0ef          	jal	ra,80003d62 <dirlink>
    80004e4a:	06054363          	bltz	a0,80004eb0 <create+0x122>
  iunlockput(dp);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	9bffe0ef          	jal	ra,8000380e <iunlockput>
  return ip;
    80004e54:	8ad2                	mv	s5,s4
    80004e56:	bf69                	j	80004df0 <create+0x62>
    iunlockput(dp);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	9b5fe0ef          	jal	ra,8000380e <iunlockput>
    return 0;
    80004e5e:	8ad2                	mv	s5,s4
    80004e60:	bf41                	j	80004df0 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e62:	004a2603          	lw	a2,4(s4)
    80004e66:	00003597          	auipc	a1,0x3
    80004e6a:	88258593          	addi	a1,a1,-1918 # 800076e8 <syscalls+0x2f0>
    80004e6e:	8552                	mv	a0,s4
    80004e70:	ef3fe0ef          	jal	ra,80003d62 <dirlink>
    80004e74:	02054e63          	bltz	a0,80004eb0 <create+0x122>
    80004e78:	40d0                	lw	a2,4(s1)
    80004e7a:	00003597          	auipc	a1,0x3
    80004e7e:	87658593          	addi	a1,a1,-1930 # 800076f0 <syscalls+0x2f8>
    80004e82:	8552                	mv	a0,s4
    80004e84:	edffe0ef          	jal	ra,80003d62 <dirlink>
    80004e88:	02054463          	bltz	a0,80004eb0 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e8c:	004a2603          	lw	a2,4(s4)
    80004e90:	fb040593          	addi	a1,s0,-80
    80004e94:	8526                	mv	a0,s1
    80004e96:	ecdfe0ef          	jal	ra,80003d62 <dirlink>
    80004e9a:	00054b63          	bltz	a0,80004eb0 <create+0x122>
    dp->nlink++;  // for ".."
    80004e9e:	04a4d783          	lhu	a5,74(s1)
    80004ea2:	2785                	addiw	a5,a5,1
    80004ea4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	eaafe0ef          	jal	ra,80003554 <iupdate>
    80004eae:	b745                	j	80004e4e <create+0xc0>
  ip->nlink = 0;
    80004eb0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004eb4:	8552                	mv	a0,s4
    80004eb6:	e9efe0ef          	jal	ra,80003554 <iupdate>
  iunlockput(ip);
    80004eba:	8552                	mv	a0,s4
    80004ebc:	953fe0ef          	jal	ra,8000380e <iunlockput>
  iunlockput(dp);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	94dfe0ef          	jal	ra,8000380e <iunlockput>
  return 0;
    80004ec6:	b72d                	j	80004df0 <create+0x62>
    return 0;
    80004ec8:	8aaa                	mv	s5,a0
    80004eca:	b71d                	j	80004df0 <create+0x62>

0000000080004ecc <sys_dup>:
{
    80004ecc:	7179                	addi	sp,sp,-48
    80004ece:	f406                	sd	ra,40(sp)
    80004ed0:	f022                	sd	s0,32(sp)
    80004ed2:	ec26                	sd	s1,24(sp)
    80004ed4:	e84a                	sd	s2,16(sp)
    80004ed6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ed8:	fd840613          	addi	a2,s0,-40
    80004edc:	4581                	li	a1,0
    80004ede:	4501                	li	a0,0
    80004ee0:	e19ff0ef          	jal	ra,80004cf8 <argfd>
    return -1;
    80004ee4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004ee6:	00054f63          	bltz	a0,80004f04 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80004eea:	fd843903          	ld	s2,-40(s0)
    80004eee:	854a                	mv	a0,s2
    80004ef0:	e61ff0ef          	jal	ra,80004d50 <fdalloc>
    80004ef4:	84aa                	mv	s1,a0
    return -1;
    80004ef6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004ef8:	00054663          	bltz	a0,80004f04 <sys_dup+0x38>
  filedup(f);
    80004efc:	854a                	mv	a0,s2
    80004efe:	cb6ff0ef          	jal	ra,800043b4 <filedup>
  return fd;
    80004f02:	87a6                	mv	a5,s1
}
    80004f04:	853e                	mv	a0,a5
    80004f06:	70a2                	ld	ra,40(sp)
    80004f08:	7402                	ld	s0,32(sp)
    80004f0a:	64e2                	ld	s1,24(sp)
    80004f0c:	6942                	ld	s2,16(sp)
    80004f0e:	6145                	addi	sp,sp,48
    80004f10:	8082                	ret

0000000080004f12 <sys_read>:
{
    80004f12:	7179                	addi	sp,sp,-48
    80004f14:	f406                	sd	ra,40(sp)
    80004f16:	f022                	sd	s0,32(sp)
    80004f18:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f1a:	fd840593          	addi	a1,s0,-40
    80004f1e:	4505                	li	a0,1
    80004f20:	b0ffd0ef          	jal	ra,80002a2e <argaddr>
  argint(2, &n);
    80004f24:	fe440593          	addi	a1,s0,-28
    80004f28:	4509                	li	a0,2
    80004f2a:	ae9fd0ef          	jal	ra,80002a12 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f2e:	fe840613          	addi	a2,s0,-24
    80004f32:	4581                	li	a1,0
    80004f34:	4501                	li	a0,0
    80004f36:	dc3ff0ef          	jal	ra,80004cf8 <argfd>
    80004f3a:	87aa                	mv	a5,a0
    return -1;
    80004f3c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f3e:	0007ca63          	bltz	a5,80004f52 <sys_read+0x40>
  return fileread(f, p, n);
    80004f42:	fe442603          	lw	a2,-28(s0)
    80004f46:	fd843583          	ld	a1,-40(s0)
    80004f4a:	fe843503          	ld	a0,-24(s0)
    80004f4e:	db2ff0ef          	jal	ra,80004500 <fileread>
}
    80004f52:	70a2                	ld	ra,40(sp)
    80004f54:	7402                	ld	s0,32(sp)
    80004f56:	6145                	addi	sp,sp,48
    80004f58:	8082                	ret

0000000080004f5a <sys_write>:
{
    80004f5a:	7179                	addi	sp,sp,-48
    80004f5c:	f406                	sd	ra,40(sp)
    80004f5e:	f022                	sd	s0,32(sp)
    80004f60:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f62:	fd840593          	addi	a1,s0,-40
    80004f66:	4505                	li	a0,1
    80004f68:	ac7fd0ef          	jal	ra,80002a2e <argaddr>
  argint(2, &n);
    80004f6c:	fe440593          	addi	a1,s0,-28
    80004f70:	4509                	li	a0,2
    80004f72:	aa1fd0ef          	jal	ra,80002a12 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f76:	fe840613          	addi	a2,s0,-24
    80004f7a:	4581                	li	a1,0
    80004f7c:	4501                	li	a0,0
    80004f7e:	d7bff0ef          	jal	ra,80004cf8 <argfd>
    80004f82:	87aa                	mv	a5,a0
    return -1;
    80004f84:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f86:	0007ca63          	bltz	a5,80004f9a <sys_write+0x40>
  return filewrite(f, p, n);
    80004f8a:	fe442603          	lw	a2,-28(s0)
    80004f8e:	fd843583          	ld	a1,-40(s0)
    80004f92:	fe843503          	ld	a0,-24(s0)
    80004f96:	e18ff0ef          	jal	ra,800045ae <filewrite>
}
    80004f9a:	70a2                	ld	ra,40(sp)
    80004f9c:	7402                	ld	s0,32(sp)
    80004f9e:	6145                	addi	sp,sp,48
    80004fa0:	8082                	ret

0000000080004fa2 <sys_close>:
{
    80004fa2:	1101                	addi	sp,sp,-32
    80004fa4:	ec06                	sd	ra,24(sp)
    80004fa6:	e822                	sd	s0,16(sp)
    80004fa8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004faa:	fe040613          	addi	a2,s0,-32
    80004fae:	fec40593          	addi	a1,s0,-20
    80004fb2:	4501                	li	a0,0
    80004fb4:	d45ff0ef          	jal	ra,80004cf8 <argfd>
    return -1;
    80004fb8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004fba:	02054063          	bltz	a0,80004fda <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004fbe:	b15fc0ef          	jal	ra,80001ad2 <myproc>
    80004fc2:	fec42783          	lw	a5,-20(s0)
    80004fc6:	07e9                	addi	a5,a5,26
    80004fc8:	078e                	slli	a5,a5,0x3
    80004fca:	953e                	add	a0,a0,a5
    80004fcc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004fd0:	fe043503          	ld	a0,-32(s0)
    80004fd4:	c26ff0ef          	jal	ra,800043fa <fileclose>
  return 0;
    80004fd8:	4781                	li	a5,0
}
    80004fda:	853e                	mv	a0,a5
    80004fdc:	60e2                	ld	ra,24(sp)
    80004fde:	6442                	ld	s0,16(sp)
    80004fe0:	6105                	addi	sp,sp,32
    80004fe2:	8082                	ret

0000000080004fe4 <sys_fstat>:
{
    80004fe4:	1101                	addi	sp,sp,-32
    80004fe6:	ec06                	sd	ra,24(sp)
    80004fe8:	e822                	sd	s0,16(sp)
    80004fea:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004fec:	fe040593          	addi	a1,s0,-32
    80004ff0:	4505                	li	a0,1
    80004ff2:	a3dfd0ef          	jal	ra,80002a2e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ff6:	fe840613          	addi	a2,s0,-24
    80004ffa:	4581                	li	a1,0
    80004ffc:	4501                	li	a0,0
    80004ffe:	cfbff0ef          	jal	ra,80004cf8 <argfd>
    80005002:	87aa                	mv	a5,a0
    return -1;
    80005004:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005006:	0007c863          	bltz	a5,80005016 <sys_fstat+0x32>
  return filestat(f, st);
    8000500a:	fe043583          	ld	a1,-32(s0)
    8000500e:	fe843503          	ld	a0,-24(s0)
    80005012:	c90ff0ef          	jal	ra,800044a2 <filestat>
}
    80005016:	60e2                	ld	ra,24(sp)
    80005018:	6442                	ld	s0,16(sp)
    8000501a:	6105                	addi	sp,sp,32
    8000501c:	8082                	ret

000000008000501e <sys_link>:
{
    8000501e:	7169                	addi	sp,sp,-304
    80005020:	f606                	sd	ra,296(sp)
    80005022:	f222                	sd	s0,288(sp)
    80005024:	ee26                	sd	s1,280(sp)
    80005026:	ea4a                	sd	s2,272(sp)
    80005028:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000502a:	08000613          	li	a2,128
    8000502e:	ed040593          	addi	a1,s0,-304
    80005032:	4501                	li	a0,0
    80005034:	a17fd0ef          	jal	ra,80002a4a <argstr>
    return -1;
    80005038:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000503a:	0c054663          	bltz	a0,80005106 <sys_link+0xe8>
    8000503e:	08000613          	li	a2,128
    80005042:	f5040593          	addi	a1,s0,-176
    80005046:	4505                	li	a0,1
    80005048:	a03fd0ef          	jal	ra,80002a4a <argstr>
    return -1;
    8000504c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000504e:	0a054c63          	bltz	a0,80005106 <sys_link+0xe8>
  begin_op();
    80005052:	f9ffe0ef          	jal	ra,80003ff0 <begin_op>
  if((ip = namei(old)) == 0){
    80005056:	ed040513          	addi	a0,s0,-304
    8000505a:	da3fe0ef          	jal	ra,80003dfc <namei>
    8000505e:	84aa                	mv	s1,a0
    80005060:	c525                	beqz	a0,800050c8 <sys_link+0xaa>
  ilock(ip);
    80005062:	da6fe0ef          	jal	ra,80003608 <ilock>
  if(ip->type == T_DIR){
    80005066:	04449703          	lh	a4,68(s1)
    8000506a:	4785                	li	a5,1
    8000506c:	06f70263          	beq	a4,a5,800050d0 <sys_link+0xb2>
  ip->nlink++;
    80005070:	04a4d783          	lhu	a5,74(s1)
    80005074:	2785                	addiw	a5,a5,1
    80005076:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000507a:	8526                	mv	a0,s1
    8000507c:	cd8fe0ef          	jal	ra,80003554 <iupdate>
  iunlock(ip);
    80005080:	8526                	mv	a0,s1
    80005082:	e30fe0ef          	jal	ra,800036b2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005086:	fd040593          	addi	a1,s0,-48
    8000508a:	f5040513          	addi	a0,s0,-176
    8000508e:	d89fe0ef          	jal	ra,80003e16 <nameiparent>
    80005092:	892a                	mv	s2,a0
    80005094:	c921                	beqz	a0,800050e4 <sys_link+0xc6>
  ilock(dp);
    80005096:	d72fe0ef          	jal	ra,80003608 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000509a:	00092703          	lw	a4,0(s2)
    8000509e:	409c                	lw	a5,0(s1)
    800050a0:	02f71f63          	bne	a4,a5,800050de <sys_link+0xc0>
    800050a4:	40d0                	lw	a2,4(s1)
    800050a6:	fd040593          	addi	a1,s0,-48
    800050aa:	854a                	mv	a0,s2
    800050ac:	cb7fe0ef          	jal	ra,80003d62 <dirlink>
    800050b0:	02054763          	bltz	a0,800050de <sys_link+0xc0>
  iunlockput(dp);
    800050b4:	854a                	mv	a0,s2
    800050b6:	f58fe0ef          	jal	ra,8000380e <iunlockput>
  iput(ip);
    800050ba:	8526                	mv	a0,s1
    800050bc:	ecafe0ef          	jal	ra,80003786 <iput>
  end_op();
    800050c0:	f9ffe0ef          	jal	ra,8000405e <end_op>
  return 0;
    800050c4:	4781                	li	a5,0
    800050c6:	a081                	j	80005106 <sys_link+0xe8>
    end_op();
    800050c8:	f97fe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800050cc:	57fd                	li	a5,-1
    800050ce:	a825                	j	80005106 <sys_link+0xe8>
    iunlockput(ip);
    800050d0:	8526                	mv	a0,s1
    800050d2:	f3cfe0ef          	jal	ra,8000380e <iunlockput>
    end_op();
    800050d6:	f89fe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800050da:	57fd                	li	a5,-1
    800050dc:	a02d                	j	80005106 <sys_link+0xe8>
    iunlockput(dp);
    800050de:	854a                	mv	a0,s2
    800050e0:	f2efe0ef          	jal	ra,8000380e <iunlockput>
  ilock(ip);
    800050e4:	8526                	mv	a0,s1
    800050e6:	d22fe0ef          	jal	ra,80003608 <ilock>
  ip->nlink--;
    800050ea:	04a4d783          	lhu	a5,74(s1)
    800050ee:	37fd                	addiw	a5,a5,-1
    800050f0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050f4:	8526                	mv	a0,s1
    800050f6:	c5efe0ef          	jal	ra,80003554 <iupdate>
  iunlockput(ip);
    800050fa:	8526                	mv	a0,s1
    800050fc:	f12fe0ef          	jal	ra,8000380e <iunlockput>
  end_op();
    80005100:	f5ffe0ef          	jal	ra,8000405e <end_op>
  return -1;
    80005104:	57fd                	li	a5,-1
}
    80005106:	853e                	mv	a0,a5
    80005108:	70b2                	ld	ra,296(sp)
    8000510a:	7412                	ld	s0,288(sp)
    8000510c:	64f2                	ld	s1,280(sp)
    8000510e:	6952                	ld	s2,272(sp)
    80005110:	6155                	addi	sp,sp,304
    80005112:	8082                	ret

0000000080005114 <sys_unlink>:
{
    80005114:	7151                	addi	sp,sp,-240
    80005116:	f586                	sd	ra,232(sp)
    80005118:	f1a2                	sd	s0,224(sp)
    8000511a:	eda6                	sd	s1,216(sp)
    8000511c:	e9ca                	sd	s2,208(sp)
    8000511e:	e5ce                	sd	s3,200(sp)
    80005120:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005122:	08000613          	li	a2,128
    80005126:	f3040593          	addi	a1,s0,-208
    8000512a:	4501                	li	a0,0
    8000512c:	91ffd0ef          	jal	ra,80002a4a <argstr>
    80005130:	12054b63          	bltz	a0,80005266 <sys_unlink+0x152>
  begin_op();
    80005134:	ebdfe0ef          	jal	ra,80003ff0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005138:	fb040593          	addi	a1,s0,-80
    8000513c:	f3040513          	addi	a0,s0,-208
    80005140:	cd7fe0ef          	jal	ra,80003e16 <nameiparent>
    80005144:	84aa                	mv	s1,a0
    80005146:	c54d                	beqz	a0,800051f0 <sys_unlink+0xdc>
  ilock(dp);
    80005148:	cc0fe0ef          	jal	ra,80003608 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000514c:	00002597          	auipc	a1,0x2
    80005150:	59c58593          	addi	a1,a1,1436 # 800076e8 <syscalls+0x2f0>
    80005154:	fb040513          	addi	a0,s0,-80
    80005158:	a23fe0ef          	jal	ra,80003b7a <namecmp>
    8000515c:	10050a63          	beqz	a0,80005270 <sys_unlink+0x15c>
    80005160:	00002597          	auipc	a1,0x2
    80005164:	59058593          	addi	a1,a1,1424 # 800076f0 <syscalls+0x2f8>
    80005168:	fb040513          	addi	a0,s0,-80
    8000516c:	a0ffe0ef          	jal	ra,80003b7a <namecmp>
    80005170:	10050063          	beqz	a0,80005270 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005174:	f2c40613          	addi	a2,s0,-212
    80005178:	fb040593          	addi	a1,s0,-80
    8000517c:	8526                	mv	a0,s1
    8000517e:	a13fe0ef          	jal	ra,80003b90 <dirlookup>
    80005182:	892a                	mv	s2,a0
    80005184:	0e050663          	beqz	a0,80005270 <sys_unlink+0x15c>
  ilock(ip);
    80005188:	c80fe0ef          	jal	ra,80003608 <ilock>
  if(ip->nlink < 1)
    8000518c:	04a91783          	lh	a5,74(s2)
    80005190:	06f05463          	blez	a5,800051f8 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005194:	04491703          	lh	a4,68(s2)
    80005198:	4785                	li	a5,1
    8000519a:	06f70563          	beq	a4,a5,80005204 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    8000519e:	4641                	li	a2,16
    800051a0:	4581                	li	a1,0
    800051a2:	fc040513          	addi	a0,s0,-64
    800051a6:	bcffb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051aa:	4741                	li	a4,16
    800051ac:	f2c42683          	lw	a3,-212(s0)
    800051b0:	fc040613          	addi	a2,s0,-64
    800051b4:	4581                	li	a1,0
    800051b6:	8526                	mv	a0,s1
    800051b8:	8c1fe0ef          	jal	ra,80003a78 <writei>
    800051bc:	47c1                	li	a5,16
    800051be:	08f51563          	bne	a0,a5,80005248 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800051c2:	04491703          	lh	a4,68(s2)
    800051c6:	4785                	li	a5,1
    800051c8:	08f70663          	beq	a4,a5,80005254 <sys_unlink+0x140>
  iunlockput(dp);
    800051cc:	8526                	mv	a0,s1
    800051ce:	e40fe0ef          	jal	ra,8000380e <iunlockput>
  ip->nlink--;
    800051d2:	04a95783          	lhu	a5,74(s2)
    800051d6:	37fd                	addiw	a5,a5,-1
    800051d8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051dc:	854a                	mv	a0,s2
    800051de:	b76fe0ef          	jal	ra,80003554 <iupdate>
  iunlockput(ip);
    800051e2:	854a                	mv	a0,s2
    800051e4:	e2afe0ef          	jal	ra,8000380e <iunlockput>
  end_op();
    800051e8:	e77fe0ef          	jal	ra,8000405e <end_op>
  return 0;
    800051ec:	4501                	li	a0,0
    800051ee:	a079                	j	8000527c <sys_unlink+0x168>
    end_op();
    800051f0:	e6ffe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800051f4:	557d                	li	a0,-1
    800051f6:	a059                	j	8000527c <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051f8:	00002517          	auipc	a0,0x2
    800051fc:	50050513          	addi	a0,a0,1280 # 800076f8 <syscalls+0x300>
    80005200:	d88fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005204:	04c92703          	lw	a4,76(s2)
    80005208:	02000793          	li	a5,32
    8000520c:	f8e7f9e3          	bgeu	a5,a4,8000519e <sys_unlink+0x8a>
    80005210:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005214:	4741                	li	a4,16
    80005216:	86ce                	mv	a3,s3
    80005218:	f1840613          	addi	a2,s0,-232
    8000521c:	4581                	li	a1,0
    8000521e:	854a                	mv	a0,s2
    80005220:	f74fe0ef          	jal	ra,80003994 <readi>
    80005224:	47c1                	li	a5,16
    80005226:	00f51b63          	bne	a0,a5,8000523c <sys_unlink+0x128>
    if(de.inum != 0)
    8000522a:	f1845783          	lhu	a5,-232(s0)
    8000522e:	ef95                	bnez	a5,8000526a <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005230:	29c1                	addiw	s3,s3,16
    80005232:	04c92783          	lw	a5,76(s2)
    80005236:	fcf9efe3          	bltu	s3,a5,80005214 <sys_unlink+0x100>
    8000523a:	b795                	j	8000519e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000523c:	00002517          	auipc	a0,0x2
    80005240:	4d450513          	addi	a0,a0,1236 # 80007710 <syscalls+0x318>
    80005244:	d44fb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80005248:	00002517          	auipc	a0,0x2
    8000524c:	4e050513          	addi	a0,a0,1248 # 80007728 <syscalls+0x330>
    80005250:	d38fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005254:	04a4d783          	lhu	a5,74(s1)
    80005258:	37fd                	addiw	a5,a5,-1
    8000525a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000525e:	8526                	mv	a0,s1
    80005260:	af4fe0ef          	jal	ra,80003554 <iupdate>
    80005264:	b7a5                	j	800051cc <sys_unlink+0xb8>
    return -1;
    80005266:	557d                	li	a0,-1
    80005268:	a811                	j	8000527c <sys_unlink+0x168>
    iunlockput(ip);
    8000526a:	854a                	mv	a0,s2
    8000526c:	da2fe0ef          	jal	ra,8000380e <iunlockput>
  iunlockput(dp);
    80005270:	8526                	mv	a0,s1
    80005272:	d9cfe0ef          	jal	ra,8000380e <iunlockput>
  end_op();
    80005276:	de9fe0ef          	jal	ra,8000405e <end_op>
  return -1;
    8000527a:	557d                	li	a0,-1
}
    8000527c:	70ae                	ld	ra,232(sp)
    8000527e:	740e                	ld	s0,224(sp)
    80005280:	64ee                	ld	s1,216(sp)
    80005282:	694e                	ld	s2,208(sp)
    80005284:	69ae                	ld	s3,200(sp)
    80005286:	616d                	addi	sp,sp,240
    80005288:	8082                	ret

000000008000528a <sys_open>:

uint64
sys_open(void)
{
    8000528a:	7131                	addi	sp,sp,-192
    8000528c:	fd06                	sd	ra,184(sp)
    8000528e:	f922                	sd	s0,176(sp)
    80005290:	f526                	sd	s1,168(sp)
    80005292:	f14a                	sd	s2,160(sp)
    80005294:	ed4e                	sd	s3,152(sp)
    80005296:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005298:	f4c40593          	addi	a1,s0,-180
    8000529c:	4505                	li	a0,1
    8000529e:	f74fd0ef          	jal	ra,80002a12 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800052a2:	08000613          	li	a2,128
    800052a6:	f5040593          	addi	a1,s0,-176
    800052aa:	4501                	li	a0,0
    800052ac:	f9efd0ef          	jal	ra,80002a4a <argstr>
    800052b0:	87aa                	mv	a5,a0
    return -1;
    800052b2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800052b4:	0807cd63          	bltz	a5,8000534e <sys_open+0xc4>

  begin_op();
    800052b8:	d39fe0ef          	jal	ra,80003ff0 <begin_op>

  if(omode & O_CREATE){
    800052bc:	f4c42783          	lw	a5,-180(s0)
    800052c0:	2007f793          	andi	a5,a5,512
    800052c4:	c3c5                	beqz	a5,80005364 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800052c6:	4681                	li	a3,0
    800052c8:	4601                	li	a2,0
    800052ca:	4589                	li	a1,2
    800052cc:	f5040513          	addi	a0,s0,-176
    800052d0:	abfff0ef          	jal	ra,80004d8e <create>
    800052d4:	84aa                	mv	s1,a0
    if(ip == 0){
    800052d6:	c159                	beqz	a0,8000535c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800052d8:	04449703          	lh	a4,68(s1)
    800052dc:	478d                	li	a5,3
    800052de:	00f71763          	bne	a4,a5,800052ec <sys_open+0x62>
    800052e2:	0464d703          	lhu	a4,70(s1)
    800052e6:	47a5                	li	a5,9
    800052e8:	0ae7e963          	bltu	a5,a4,8000539a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800052ec:	86aff0ef          	jal	ra,80004356 <filealloc>
    800052f0:	89aa                	mv	s3,a0
    800052f2:	0c050963          	beqz	a0,800053c4 <sys_open+0x13a>
    800052f6:	a5bff0ef          	jal	ra,80004d50 <fdalloc>
    800052fa:	892a                	mv	s2,a0
    800052fc:	0c054163          	bltz	a0,800053be <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005300:	04449703          	lh	a4,68(s1)
    80005304:	478d                	li	a5,3
    80005306:	0af70163          	beq	a4,a5,800053a8 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000530a:	4789                	li	a5,2
    8000530c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005310:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005314:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005318:	f4c42783          	lw	a5,-180(s0)
    8000531c:	0017c713          	xori	a4,a5,1
    80005320:	8b05                	andi	a4,a4,1
    80005322:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005326:	0037f713          	andi	a4,a5,3
    8000532a:	00e03733          	snez	a4,a4
    8000532e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005332:	4007f793          	andi	a5,a5,1024
    80005336:	c791                	beqz	a5,80005342 <sys_open+0xb8>
    80005338:	04449703          	lh	a4,68(s1)
    8000533c:	4789                	li	a5,2
    8000533e:	06f70c63          	beq	a4,a5,800053b6 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005342:	8526                	mv	a0,s1
    80005344:	b6efe0ef          	jal	ra,800036b2 <iunlock>
  end_op();
    80005348:	d17fe0ef          	jal	ra,8000405e <end_op>

  return fd;
    8000534c:	854a                	mv	a0,s2
}
    8000534e:	70ea                	ld	ra,184(sp)
    80005350:	744a                	ld	s0,176(sp)
    80005352:	74aa                	ld	s1,168(sp)
    80005354:	790a                	ld	s2,160(sp)
    80005356:	69ea                	ld	s3,152(sp)
    80005358:	6129                	addi	sp,sp,192
    8000535a:	8082                	ret
      end_op();
    8000535c:	d03fe0ef          	jal	ra,8000405e <end_op>
      return -1;
    80005360:	557d                	li	a0,-1
    80005362:	b7f5                	j	8000534e <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005364:	f5040513          	addi	a0,s0,-176
    80005368:	a95fe0ef          	jal	ra,80003dfc <namei>
    8000536c:	84aa                	mv	s1,a0
    8000536e:	c115                	beqz	a0,80005392 <sys_open+0x108>
    ilock(ip);
    80005370:	a98fe0ef          	jal	ra,80003608 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005374:	04449703          	lh	a4,68(s1)
    80005378:	4785                	li	a5,1
    8000537a:	f4f71fe3          	bne	a4,a5,800052d8 <sys_open+0x4e>
    8000537e:	f4c42783          	lw	a5,-180(s0)
    80005382:	d7ad                	beqz	a5,800052ec <sys_open+0x62>
      iunlockput(ip);
    80005384:	8526                	mv	a0,s1
    80005386:	c88fe0ef          	jal	ra,8000380e <iunlockput>
      end_op();
    8000538a:	cd5fe0ef          	jal	ra,8000405e <end_op>
      return -1;
    8000538e:	557d                	li	a0,-1
    80005390:	bf7d                	j	8000534e <sys_open+0xc4>
      end_op();
    80005392:	ccdfe0ef          	jal	ra,8000405e <end_op>
      return -1;
    80005396:	557d                	li	a0,-1
    80005398:	bf5d                	j	8000534e <sys_open+0xc4>
    iunlockput(ip);
    8000539a:	8526                	mv	a0,s1
    8000539c:	c72fe0ef          	jal	ra,8000380e <iunlockput>
    end_op();
    800053a0:	cbffe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800053a4:	557d                	li	a0,-1
    800053a6:	b765                	j	8000534e <sys_open+0xc4>
    f->type = FD_DEVICE;
    800053a8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800053ac:	04649783          	lh	a5,70(s1)
    800053b0:	02f99223          	sh	a5,36(s3)
    800053b4:	b785                	j	80005314 <sys_open+0x8a>
    itrunc(ip);
    800053b6:	8526                	mv	a0,s1
    800053b8:	b3afe0ef          	jal	ra,800036f2 <itrunc>
    800053bc:	b759                	j	80005342 <sys_open+0xb8>
      fileclose(f);
    800053be:	854e                	mv	a0,s3
    800053c0:	83aff0ef          	jal	ra,800043fa <fileclose>
    iunlockput(ip);
    800053c4:	8526                	mv	a0,s1
    800053c6:	c48fe0ef          	jal	ra,8000380e <iunlockput>
    end_op();
    800053ca:	c95fe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800053ce:	557d                	li	a0,-1
    800053d0:	bfbd                	j	8000534e <sys_open+0xc4>

00000000800053d2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053d2:	7175                	addi	sp,sp,-144
    800053d4:	e506                	sd	ra,136(sp)
    800053d6:	e122                	sd	s0,128(sp)
    800053d8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053da:	c17fe0ef          	jal	ra,80003ff0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800053de:	08000613          	li	a2,128
    800053e2:	f7040593          	addi	a1,s0,-144
    800053e6:	4501                	li	a0,0
    800053e8:	e62fd0ef          	jal	ra,80002a4a <argstr>
    800053ec:	02054363          	bltz	a0,80005412 <sys_mkdir+0x40>
    800053f0:	4681                	li	a3,0
    800053f2:	4601                	li	a2,0
    800053f4:	4585                	li	a1,1
    800053f6:	f7040513          	addi	a0,s0,-144
    800053fa:	995ff0ef          	jal	ra,80004d8e <create>
    800053fe:	c911                	beqz	a0,80005412 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005400:	c0efe0ef          	jal	ra,8000380e <iunlockput>
  end_op();
    80005404:	c5bfe0ef          	jal	ra,8000405e <end_op>
  return 0;
    80005408:	4501                	li	a0,0
}
    8000540a:	60aa                	ld	ra,136(sp)
    8000540c:	640a                	ld	s0,128(sp)
    8000540e:	6149                	addi	sp,sp,144
    80005410:	8082                	ret
    end_op();
    80005412:	c4dfe0ef          	jal	ra,8000405e <end_op>
    return -1;
    80005416:	557d                	li	a0,-1
    80005418:	bfcd                	j	8000540a <sys_mkdir+0x38>

000000008000541a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000541a:	7135                	addi	sp,sp,-160
    8000541c:	ed06                	sd	ra,152(sp)
    8000541e:	e922                	sd	s0,144(sp)
    80005420:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005422:	bcffe0ef          	jal	ra,80003ff0 <begin_op>
  argint(1, &major);
    80005426:	f6c40593          	addi	a1,s0,-148
    8000542a:	4505                	li	a0,1
    8000542c:	de6fd0ef          	jal	ra,80002a12 <argint>
  argint(2, &minor);
    80005430:	f6840593          	addi	a1,s0,-152
    80005434:	4509                	li	a0,2
    80005436:	ddcfd0ef          	jal	ra,80002a12 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000543a:	08000613          	li	a2,128
    8000543e:	f7040593          	addi	a1,s0,-144
    80005442:	4501                	li	a0,0
    80005444:	e06fd0ef          	jal	ra,80002a4a <argstr>
    80005448:	02054563          	bltz	a0,80005472 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000544c:	f6841683          	lh	a3,-152(s0)
    80005450:	f6c41603          	lh	a2,-148(s0)
    80005454:	458d                	li	a1,3
    80005456:	f7040513          	addi	a0,s0,-144
    8000545a:	935ff0ef          	jal	ra,80004d8e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000545e:	c911                	beqz	a0,80005472 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005460:	baefe0ef          	jal	ra,8000380e <iunlockput>
  end_op();
    80005464:	bfbfe0ef          	jal	ra,8000405e <end_op>
  return 0;
    80005468:	4501                	li	a0,0
}
    8000546a:	60ea                	ld	ra,152(sp)
    8000546c:	644a                	ld	s0,144(sp)
    8000546e:	610d                	addi	sp,sp,160
    80005470:	8082                	ret
    end_op();
    80005472:	bedfe0ef          	jal	ra,8000405e <end_op>
    return -1;
    80005476:	557d                	li	a0,-1
    80005478:	bfcd                	j	8000546a <sys_mknod+0x50>

000000008000547a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000547a:	7135                	addi	sp,sp,-160
    8000547c:	ed06                	sd	ra,152(sp)
    8000547e:	e922                	sd	s0,144(sp)
    80005480:	e526                	sd	s1,136(sp)
    80005482:	e14a                	sd	s2,128(sp)
    80005484:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005486:	e4cfc0ef          	jal	ra,80001ad2 <myproc>
    8000548a:	892a                	mv	s2,a0
  
  begin_op();
    8000548c:	b65fe0ef          	jal	ra,80003ff0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005490:	08000613          	li	a2,128
    80005494:	f6040593          	addi	a1,s0,-160
    80005498:	4501                	li	a0,0
    8000549a:	db0fd0ef          	jal	ra,80002a4a <argstr>
    8000549e:	04054163          	bltz	a0,800054e0 <sys_chdir+0x66>
    800054a2:	f6040513          	addi	a0,s0,-160
    800054a6:	957fe0ef          	jal	ra,80003dfc <namei>
    800054aa:	84aa                	mv	s1,a0
    800054ac:	c915                	beqz	a0,800054e0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800054ae:	95afe0ef          	jal	ra,80003608 <ilock>
  if(ip->type != T_DIR){
    800054b2:	04449703          	lh	a4,68(s1)
    800054b6:	4785                	li	a5,1
    800054b8:	02f71863          	bne	a4,a5,800054e8 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054bc:	8526                	mv	a0,s1
    800054be:	9f4fe0ef          	jal	ra,800036b2 <iunlock>
  iput(p->cwd);
    800054c2:	15093503          	ld	a0,336(s2)
    800054c6:	ac0fe0ef          	jal	ra,80003786 <iput>
  end_op();
    800054ca:	b95fe0ef          	jal	ra,8000405e <end_op>
  p->cwd = ip;
    800054ce:	14993823          	sd	s1,336(s2)
  return 0;
    800054d2:	4501                	li	a0,0
}
    800054d4:	60ea                	ld	ra,152(sp)
    800054d6:	644a                	ld	s0,144(sp)
    800054d8:	64aa                	ld	s1,136(sp)
    800054da:	690a                	ld	s2,128(sp)
    800054dc:	610d                	addi	sp,sp,160
    800054de:	8082                	ret
    end_op();
    800054e0:	b7ffe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800054e4:	557d                	li	a0,-1
    800054e6:	b7fd                	j	800054d4 <sys_chdir+0x5a>
    iunlockput(ip);
    800054e8:	8526                	mv	a0,s1
    800054ea:	b24fe0ef          	jal	ra,8000380e <iunlockput>
    end_op();
    800054ee:	b71fe0ef          	jal	ra,8000405e <end_op>
    return -1;
    800054f2:	557d                	li	a0,-1
    800054f4:	b7c5                	j	800054d4 <sys_chdir+0x5a>

00000000800054f6 <sys_exec>:

uint64
sys_exec(void)
{
    800054f6:	7145                	addi	sp,sp,-464
    800054f8:	e786                	sd	ra,456(sp)
    800054fa:	e3a2                	sd	s0,448(sp)
    800054fc:	ff26                	sd	s1,440(sp)
    800054fe:	fb4a                	sd	s2,432(sp)
    80005500:	f74e                	sd	s3,424(sp)
    80005502:	f352                	sd	s4,416(sp)
    80005504:	ef56                	sd	s5,408(sp)
    80005506:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005508:	e3840593          	addi	a1,s0,-456
    8000550c:	4505                	li	a0,1
    8000550e:	d20fd0ef          	jal	ra,80002a2e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005512:	08000613          	li	a2,128
    80005516:	f4040593          	addi	a1,s0,-192
    8000551a:	4501                	li	a0,0
    8000551c:	d2efd0ef          	jal	ra,80002a4a <argstr>
    80005520:	87aa                	mv	a5,a0
    return -1;
    80005522:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005524:	0a07c563          	bltz	a5,800055ce <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005528:	10000613          	li	a2,256
    8000552c:	4581                	li	a1,0
    8000552e:	e4040513          	addi	a0,s0,-448
    80005532:	843fb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005536:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000553a:	89a6                	mv	s3,s1
    8000553c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000553e:	02000a13          	li	s4,32
    80005542:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005546:	00391513          	slli	a0,s2,0x3
    8000554a:	e3040593          	addi	a1,s0,-464
    8000554e:	e3843783          	ld	a5,-456(s0)
    80005552:	953e                	add	a0,a0,a5
    80005554:	c34fd0ef          	jal	ra,80002988 <fetchaddr>
    80005558:	02054663          	bltz	a0,80005584 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000555c:	e3043783          	ld	a5,-464(s0)
    80005560:	cf8d                	beqz	a5,8000559a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005562:	e48fb0ef          	jal	ra,80000baa <kalloc>
    80005566:	85aa                	mv	a1,a0
    80005568:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000556c:	cd01                	beqz	a0,80005584 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000556e:	6605                	lui	a2,0x1
    80005570:	e3043503          	ld	a0,-464(s0)
    80005574:	c5efd0ef          	jal	ra,800029d2 <fetchstr>
    80005578:	00054663          	bltz	a0,80005584 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    8000557c:	0905                	addi	s2,s2,1
    8000557e:	09a1                	addi	s3,s3,8
    80005580:	fd4911e3          	bne	s2,s4,80005542 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005584:	f4040913          	addi	s2,s0,-192
    80005588:	6088                	ld	a0,0(s1)
    8000558a:	c129                	beqz	a0,800055cc <sys_exec+0xd6>
    kfree(argv[i]);
    8000558c:	ceefb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005590:	04a1                	addi	s1,s1,8
    80005592:	ff249be3          	bne	s1,s2,80005588 <sys_exec+0x92>
  return -1;
    80005596:	557d                	li	a0,-1
    80005598:	a81d                	j	800055ce <sys_exec+0xd8>
      argv[i] = 0;
    8000559a:	0a8e                	slli	s5,s5,0x3
    8000559c:	fc0a8793          	addi	a5,s5,-64
    800055a0:	00878ab3          	add	s5,a5,s0
    800055a4:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    800055a8:	e4040593          	addi	a1,s0,-448
    800055ac:	f4040513          	addi	a0,s0,-192
    800055b0:	bf6ff0ef          	jal	ra,800049a6 <kexec>
    800055b4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055b6:	f4040993          	addi	s3,s0,-192
    800055ba:	6088                	ld	a0,0(s1)
    800055bc:	c511                	beqz	a0,800055c8 <sys_exec+0xd2>
    kfree(argv[i]);
    800055be:	cbcfb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055c2:	04a1                	addi	s1,s1,8
    800055c4:	ff349be3          	bne	s1,s3,800055ba <sys_exec+0xc4>
  return ret;
    800055c8:	854a                	mv	a0,s2
    800055ca:	a011                	j	800055ce <sys_exec+0xd8>
  return -1;
    800055cc:	557d                	li	a0,-1
}
    800055ce:	60be                	ld	ra,456(sp)
    800055d0:	641e                	ld	s0,448(sp)
    800055d2:	74fa                	ld	s1,440(sp)
    800055d4:	795a                	ld	s2,432(sp)
    800055d6:	79ba                	ld	s3,424(sp)
    800055d8:	7a1a                	ld	s4,416(sp)
    800055da:	6afa                	ld	s5,408(sp)
    800055dc:	6179                	addi	sp,sp,464
    800055de:	8082                	ret

00000000800055e0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055e0:	7139                	addi	sp,sp,-64
    800055e2:	fc06                	sd	ra,56(sp)
    800055e4:	f822                	sd	s0,48(sp)
    800055e6:	f426                	sd	s1,40(sp)
    800055e8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055ea:	ce8fc0ef          	jal	ra,80001ad2 <myproc>
    800055ee:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055f0:	fd840593          	addi	a1,s0,-40
    800055f4:	4501                	li	a0,0
    800055f6:	c38fd0ef          	jal	ra,80002a2e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800055fa:	fc840593          	addi	a1,s0,-56
    800055fe:	fd040513          	addi	a0,s0,-48
    80005602:	8c4ff0ef          	jal	ra,800046c6 <pipealloc>
    return -1;
    80005606:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005608:	0a054463          	bltz	a0,800056b0 <sys_pipe+0xd0>
  fd0 = -1;
    8000560c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005610:	fd043503          	ld	a0,-48(s0)
    80005614:	f3cff0ef          	jal	ra,80004d50 <fdalloc>
    80005618:	fca42223          	sw	a0,-60(s0)
    8000561c:	08054163          	bltz	a0,8000569e <sys_pipe+0xbe>
    80005620:	fc843503          	ld	a0,-56(s0)
    80005624:	f2cff0ef          	jal	ra,80004d50 <fdalloc>
    80005628:	fca42023          	sw	a0,-64(s0)
    8000562c:	06054063          	bltz	a0,8000568c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005630:	4691                	li	a3,4
    80005632:	fc440613          	addi	a2,s0,-60
    80005636:	fd843583          	ld	a1,-40(s0)
    8000563a:	68a8                	ld	a0,80(s1)
    8000563c:	922fc0ef          	jal	ra,8000175e <copyout>
    80005640:	00054e63          	bltz	a0,8000565c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005644:	4691                	li	a3,4
    80005646:	fc040613          	addi	a2,s0,-64
    8000564a:	fd843583          	ld	a1,-40(s0)
    8000564e:	0591                	addi	a1,a1,4
    80005650:	68a8                	ld	a0,80(s1)
    80005652:	90cfc0ef          	jal	ra,8000175e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005656:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005658:	04055c63          	bgez	a0,800056b0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000565c:	fc442783          	lw	a5,-60(s0)
    80005660:	07e9                	addi	a5,a5,26
    80005662:	078e                	slli	a5,a5,0x3
    80005664:	97a6                	add	a5,a5,s1
    80005666:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000566a:	fc042783          	lw	a5,-64(s0)
    8000566e:	07e9                	addi	a5,a5,26
    80005670:	078e                	slli	a5,a5,0x3
    80005672:	94be                	add	s1,s1,a5
    80005674:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005678:	fd043503          	ld	a0,-48(s0)
    8000567c:	d7ffe0ef          	jal	ra,800043fa <fileclose>
    fileclose(wf);
    80005680:	fc843503          	ld	a0,-56(s0)
    80005684:	d77fe0ef          	jal	ra,800043fa <fileclose>
    return -1;
    80005688:	57fd                	li	a5,-1
    8000568a:	a01d                	j	800056b0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000568c:	fc442783          	lw	a5,-60(s0)
    80005690:	0007c763          	bltz	a5,8000569e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005694:	07e9                	addi	a5,a5,26
    80005696:	078e                	slli	a5,a5,0x3
    80005698:	97a6                	add	a5,a5,s1
    8000569a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000569e:	fd043503          	ld	a0,-48(s0)
    800056a2:	d59fe0ef          	jal	ra,800043fa <fileclose>
    fileclose(wf);
    800056a6:	fc843503          	ld	a0,-56(s0)
    800056aa:	d51fe0ef          	jal	ra,800043fa <fileclose>
    return -1;
    800056ae:	57fd                	li	a5,-1
}
    800056b0:	853e                	mv	a0,a5
    800056b2:	70e2                	ld	ra,56(sp)
    800056b4:	7442                	ld	s0,48(sp)
    800056b6:	74a2                	ld	s1,40(sp)
    800056b8:	6121                	addi	sp,sp,64
    800056ba:	8082                	ret
    800056bc:	0000                	unimp
	...

00000000800056c0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056c0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056c2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056c4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800056c6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800056c8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056ca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056cc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056ce:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056d0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800056d2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800056d4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800056d6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800056d8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800056da:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800056dc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800056de:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800056e0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800056e2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800056e4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800056e6:	9b2fd0ef          	jal	ra,80002898 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800056ea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800056ec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800056ee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800056f0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800056f2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800056f4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800056f6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800056f8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800056fa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800056fc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800056fe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005700:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005702:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005704:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005706:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005708:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000570a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000570c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000570e:	10200073          	sret
	...

000000008000571e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000571e:	1141                	addi	sp,sp,-16
    80005720:	e422                	sd	s0,8(sp)
    80005722:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005724:	0c0007b7          	lui	a5,0xc000
    80005728:	4705                	li	a4,1
    8000572a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000572c:	c3d8                	sw	a4,4(a5)
}
    8000572e:	6422                	ld	s0,8(sp)
    80005730:	0141                	addi	sp,sp,16
    80005732:	8082                	ret

0000000080005734 <plicinithart>:

void
plicinithart(void)
{
    80005734:	1141                	addi	sp,sp,-16
    80005736:	e406                	sd	ra,8(sp)
    80005738:	e022                	sd	s0,0(sp)
    8000573a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000573c:	b6afc0ef          	jal	ra,80001aa6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005740:	0085171b          	slliw	a4,a0,0x8
    80005744:	0c0027b7          	lui	a5,0xc002
    80005748:	97ba                	add	a5,a5,a4
    8000574a:	40200713          	li	a4,1026
    8000574e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005752:	00d5151b          	slliw	a0,a0,0xd
    80005756:	0c2017b7          	lui	a5,0xc201
    8000575a:	97aa                	add	a5,a5,a0
    8000575c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005760:	60a2                	ld	ra,8(sp)
    80005762:	6402                	ld	s0,0(sp)
    80005764:	0141                	addi	sp,sp,16
    80005766:	8082                	ret

0000000080005768 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005768:	1141                	addi	sp,sp,-16
    8000576a:	e406                	sd	ra,8(sp)
    8000576c:	e022                	sd	s0,0(sp)
    8000576e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005770:	b36fc0ef          	jal	ra,80001aa6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005774:	00d5151b          	slliw	a0,a0,0xd
    80005778:	0c2017b7          	lui	a5,0xc201
    8000577c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000577e:	43c8                	lw	a0,4(a5)
    80005780:	60a2                	ld	ra,8(sp)
    80005782:	6402                	ld	s0,0(sp)
    80005784:	0141                	addi	sp,sp,16
    80005786:	8082                	ret

0000000080005788 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005788:	1101                	addi	sp,sp,-32
    8000578a:	ec06                	sd	ra,24(sp)
    8000578c:	e822                	sd	s0,16(sp)
    8000578e:	e426                	sd	s1,8(sp)
    80005790:	1000                	addi	s0,sp,32
    80005792:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005794:	b12fc0ef          	jal	ra,80001aa6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005798:	00d5151b          	slliw	a0,a0,0xd
    8000579c:	0c2017b7          	lui	a5,0xc201
    800057a0:	97aa                	add	a5,a5,a0
    800057a2:	c3c4                	sw	s1,4(a5)
}
    800057a4:	60e2                	ld	ra,24(sp)
    800057a6:	6442                	ld	s0,16(sp)
    800057a8:	64a2                	ld	s1,8(sp)
    800057aa:	6105                	addi	sp,sp,32
    800057ac:	8082                	ret

00000000800057ae <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057ae:	1141                	addi	sp,sp,-16
    800057b0:	e406                	sd	ra,8(sp)
    800057b2:	e022                	sd	s0,0(sp)
    800057b4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800057b6:	479d                	li	a5,7
    800057b8:	04a7ca63          	blt	a5,a0,8000580c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800057bc:	00243797          	auipc	a5,0x243
    800057c0:	2c478793          	addi	a5,a5,708 # 80248a80 <disk>
    800057c4:	97aa                	add	a5,a5,a0
    800057c6:	0187c783          	lbu	a5,24(a5)
    800057ca:	e7b9                	bnez	a5,80005818 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057cc:	00451693          	slli	a3,a0,0x4
    800057d0:	00243797          	auipc	a5,0x243
    800057d4:	2b078793          	addi	a5,a5,688 # 80248a80 <disk>
    800057d8:	6398                	ld	a4,0(a5)
    800057da:	9736                	add	a4,a4,a3
    800057dc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800057e0:	6398                	ld	a4,0(a5)
    800057e2:	9736                	add	a4,a4,a3
    800057e4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057e8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057ec:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057f0:	97aa                	add	a5,a5,a0
    800057f2:	4705                	li	a4,1
    800057f4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057f8:	00243517          	auipc	a0,0x243
    800057fc:	2a050513          	addi	a0,a0,672 # 80248a98 <disk+0x18>
    80005800:	927fc0ef          	jal	ra,80002126 <wakeup>
}
    80005804:	60a2                	ld	ra,8(sp)
    80005806:	6402                	ld	s0,0(sp)
    80005808:	0141                	addi	sp,sp,16
    8000580a:	8082                	ret
    panic("free_desc 1");
    8000580c:	00002517          	auipc	a0,0x2
    80005810:	f2c50513          	addi	a0,a0,-212 # 80007738 <syscalls+0x340>
    80005814:	f75fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005818:	00002517          	auipc	a0,0x2
    8000581c:	f3050513          	addi	a0,a0,-208 # 80007748 <syscalls+0x350>
    80005820:	f69fa0ef          	jal	ra,80000788 <panic>

0000000080005824 <virtio_disk_init>:
{
    80005824:	1101                	addi	sp,sp,-32
    80005826:	ec06                	sd	ra,24(sp)
    80005828:	e822                	sd	s0,16(sp)
    8000582a:	e426                	sd	s1,8(sp)
    8000582c:	e04a                	sd	s2,0(sp)
    8000582e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005830:	00002597          	auipc	a1,0x2
    80005834:	f2858593          	addi	a1,a1,-216 # 80007758 <syscalls+0x360>
    80005838:	00243517          	auipc	a0,0x243
    8000583c:	37050513          	addi	a0,a0,880 # 80248ba8 <disk+0x128>
    80005840:	be0fb0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005844:	100017b7          	lui	a5,0x10001
    80005848:	4398                	lw	a4,0(a5)
    8000584a:	2701                	sext.w	a4,a4
    8000584c:	747277b7          	lui	a5,0x74727
    80005850:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005854:	12f71f63          	bne	a4,a5,80005992 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005858:	100017b7          	lui	a5,0x10001
    8000585c:	43dc                	lw	a5,4(a5)
    8000585e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005860:	4709                	li	a4,2
    80005862:	12e79863          	bne	a5,a4,80005992 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005866:	100017b7          	lui	a5,0x10001
    8000586a:	479c                	lw	a5,8(a5)
    8000586c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000586e:	12e79263          	bne	a5,a4,80005992 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005872:	100017b7          	lui	a5,0x10001
    80005876:	47d8                	lw	a4,12(a5)
    80005878:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000587a:	554d47b7          	lui	a5,0x554d4
    8000587e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005882:	10f71863          	bne	a4,a5,80005992 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005886:	100017b7          	lui	a5,0x10001
    8000588a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000588e:	4705                	li	a4,1
    80005890:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005892:	470d                	li	a4,3
    80005894:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005896:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005898:	c7ffe6b7          	lui	a3,0xc7ffe
    8000589c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db5b9f>
    800058a0:	8f75                	and	a4,a4,a3
    800058a2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058a4:	472d                	li	a4,11
    800058a6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800058a8:	5bbc                	lw	a5,112(a5)
    800058aa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058ae:	8ba1                	andi	a5,a5,8
    800058b0:	0e078763          	beqz	a5,8000599e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058b4:	100017b7          	lui	a5,0x10001
    800058b8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800058bc:	43fc                	lw	a5,68(a5)
    800058be:	2781                	sext.w	a5,a5
    800058c0:	0e079563          	bnez	a5,800059aa <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058c4:	100017b7          	lui	a5,0x10001
    800058c8:	5bdc                	lw	a5,52(a5)
    800058ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800058cc:	0e078563          	beqz	a5,800059b6 <virtio_disk_init+0x192>
  if(max < NUM)
    800058d0:	471d                	li	a4,7
    800058d2:	0ef77863          	bgeu	a4,a5,800059c2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800058d6:	ad4fb0ef          	jal	ra,80000baa <kalloc>
    800058da:	00243497          	auipc	s1,0x243
    800058de:	1a648493          	addi	s1,s1,422 # 80248a80 <disk>
    800058e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058e4:	ac6fb0ef          	jal	ra,80000baa <kalloc>
    800058e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058ea:	ac0fb0ef          	jal	ra,80000baa <kalloc>
    800058ee:	87aa                	mv	a5,a0
    800058f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800058f2:	6088                	ld	a0,0(s1)
    800058f4:	cd69                	beqz	a0,800059ce <virtio_disk_init+0x1aa>
    800058f6:	00243717          	auipc	a4,0x243
    800058fa:	19273703          	ld	a4,402(a4) # 80248a88 <disk+0x8>
    800058fe:	cb61                	beqz	a4,800059ce <virtio_disk_init+0x1aa>
    80005900:	c7f9                	beqz	a5,800059ce <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005902:	6605                	lui	a2,0x1
    80005904:	4581                	li	a1,0
    80005906:	c6efb0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000590a:	00243497          	auipc	s1,0x243
    8000590e:	17648493          	addi	s1,s1,374 # 80248a80 <disk>
    80005912:	6605                	lui	a2,0x1
    80005914:	4581                	li	a1,0
    80005916:	6488                	ld	a0,8(s1)
    80005918:	c5cfb0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    8000591c:	6605                	lui	a2,0x1
    8000591e:	4581                	li	a1,0
    80005920:	6888                	ld	a0,16(s1)
    80005922:	c52fb0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005926:	100017b7          	lui	a5,0x10001
    8000592a:	4721                	li	a4,8
    8000592c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000592e:	4098                	lw	a4,0(s1)
    80005930:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005934:	40d8                	lw	a4,4(s1)
    80005936:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000593a:	6498                	ld	a4,8(s1)
    8000593c:	0007069b          	sext.w	a3,a4
    80005940:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005944:	9701                	srai	a4,a4,0x20
    80005946:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000594a:	6898                	ld	a4,16(s1)
    8000594c:	0007069b          	sext.w	a3,a4
    80005950:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005954:	9701                	srai	a4,a4,0x20
    80005956:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000595a:	4705                	li	a4,1
    8000595c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000595e:	00e48c23          	sb	a4,24(s1)
    80005962:	00e48ca3          	sb	a4,25(s1)
    80005966:	00e48d23          	sb	a4,26(s1)
    8000596a:	00e48da3          	sb	a4,27(s1)
    8000596e:	00e48e23          	sb	a4,28(s1)
    80005972:	00e48ea3          	sb	a4,29(s1)
    80005976:	00e48f23          	sb	a4,30(s1)
    8000597a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000597e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005982:	0727a823          	sw	s2,112(a5)
}
    80005986:	60e2                	ld	ra,24(sp)
    80005988:	6442                	ld	s0,16(sp)
    8000598a:	64a2                	ld	s1,8(sp)
    8000598c:	6902                	ld	s2,0(sp)
    8000598e:	6105                	addi	sp,sp,32
    80005990:	8082                	ret
    panic("could not find virtio disk");
    80005992:	00002517          	auipc	a0,0x2
    80005996:	dd650513          	addi	a0,a0,-554 # 80007768 <syscalls+0x370>
    8000599a:	deffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000599e:	00002517          	auipc	a0,0x2
    800059a2:	dea50513          	addi	a0,a0,-534 # 80007788 <syscalls+0x390>
    800059a6:	de3fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    800059aa:	00002517          	auipc	a0,0x2
    800059ae:	dfe50513          	addi	a0,a0,-514 # 800077a8 <syscalls+0x3b0>
    800059b2:	dd7fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    800059b6:	00002517          	auipc	a0,0x2
    800059ba:	e1250513          	addi	a0,a0,-494 # 800077c8 <syscalls+0x3d0>
    800059be:	dcbfa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    800059c2:	00002517          	auipc	a0,0x2
    800059c6:	e2650513          	addi	a0,a0,-474 # 800077e8 <syscalls+0x3f0>
    800059ca:	dbffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    800059ce:	00002517          	auipc	a0,0x2
    800059d2:	e3a50513          	addi	a0,a0,-454 # 80007808 <syscalls+0x410>
    800059d6:	db3fa0ef          	jal	ra,80000788 <panic>

00000000800059da <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059da:	7119                	addi	sp,sp,-128
    800059dc:	fc86                	sd	ra,120(sp)
    800059de:	f8a2                	sd	s0,112(sp)
    800059e0:	f4a6                	sd	s1,104(sp)
    800059e2:	f0ca                	sd	s2,96(sp)
    800059e4:	ecce                	sd	s3,88(sp)
    800059e6:	e8d2                	sd	s4,80(sp)
    800059e8:	e4d6                	sd	s5,72(sp)
    800059ea:	e0da                	sd	s6,64(sp)
    800059ec:	fc5e                	sd	s7,56(sp)
    800059ee:	f862                	sd	s8,48(sp)
    800059f0:	f466                	sd	s9,40(sp)
    800059f2:	f06a                	sd	s10,32(sp)
    800059f4:	ec6e                	sd	s11,24(sp)
    800059f6:	0100                	addi	s0,sp,128
    800059f8:	8aaa                	mv	s5,a0
    800059fa:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800059fc:	00c52d03          	lw	s10,12(a0)
    80005a00:	001d1d1b          	slliw	s10,s10,0x1
    80005a04:	1d02                	slli	s10,s10,0x20
    80005a06:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005a0a:	00243517          	auipc	a0,0x243
    80005a0e:	19e50513          	addi	a0,a0,414 # 80248ba8 <disk+0x128>
    80005a12:	a8efb0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80005a16:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005a18:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a1a:	00243b97          	auipc	s7,0x243
    80005a1e:	066b8b93          	addi	s7,s7,102 # 80248a80 <disk>
  for(int i = 0; i < 3; i++){
    80005a22:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a24:	00243c97          	auipc	s9,0x243
    80005a28:	184c8c93          	addi	s9,s9,388 # 80248ba8 <disk+0x128>
    80005a2c:	a8a9                	j	80005a86 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005a2e:	00fb8733          	add	a4,s7,a5
    80005a32:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a36:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a38:	0207c563          	bltz	a5,80005a62 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005a3c:	2905                	addiw	s2,s2,1
    80005a3e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a40:	05690863          	beq	s2,s6,80005a90 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005a44:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a46:	00243717          	auipc	a4,0x243
    80005a4a:	03a70713          	addi	a4,a4,58 # 80248a80 <disk>
    80005a4e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005a50:	01874683          	lbu	a3,24(a4)
    80005a54:	fee9                	bnez	a3,80005a2e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005a56:	2785                	addiw	a5,a5,1
    80005a58:	0705                	addi	a4,a4,1
    80005a5a:	fe979be3          	bne	a5,s1,80005a50 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005a5e:	57fd                	li	a5,-1
    80005a60:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005a62:	01205b63          	blez	s2,80005a78 <virtio_disk_rw+0x9e>
    80005a66:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005a68:	000a2503          	lw	a0,0(s4)
    80005a6c:	d43ff0ef          	jal	ra,800057ae <free_desc>
      for(int j = 0; j < i; j++)
    80005a70:	2d85                	addiw	s11,s11,1
    80005a72:	0a11                	addi	s4,s4,4
    80005a74:	ff2d9ae3          	bne	s11,s2,80005a68 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a78:	85e6                	mv	a1,s9
    80005a7a:	00243517          	auipc	a0,0x243
    80005a7e:	01e50513          	addi	a0,a0,30 # 80248a98 <disk+0x18>
    80005a82:	e58fc0ef          	jal	ra,800020da <sleep>
  for(int i = 0; i < 3; i++){
    80005a86:	f8040a13          	addi	s4,s0,-128
{
    80005a8a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005a8c:	894e                	mv	s2,s3
    80005a8e:	bf5d                	j	80005a44 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a90:	f8042503          	lw	a0,-128(s0)
    80005a94:	00a50713          	addi	a4,a0,10
    80005a98:	0712                	slli	a4,a4,0x4

  if(write)
    80005a9a:	00243797          	auipc	a5,0x243
    80005a9e:	fe678793          	addi	a5,a5,-26 # 80248a80 <disk>
    80005aa2:	00e786b3          	add	a3,a5,a4
    80005aa6:	01803633          	snez	a2,s8
    80005aaa:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005aac:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005ab0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ab4:	f6070613          	addi	a2,a4,-160
    80005ab8:	6394                	ld	a3,0(a5)
    80005aba:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005abc:	00870593          	addi	a1,a4,8
    80005ac0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ac2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ac4:	0007b803          	ld	a6,0(a5)
    80005ac8:	9642                	add	a2,a2,a6
    80005aca:	46c1                	li	a3,16
    80005acc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ace:	4585                	li	a1,1
    80005ad0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005ad4:	f8442683          	lw	a3,-124(s0)
    80005ad8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005adc:	0692                	slli	a3,a3,0x4
    80005ade:	9836                	add	a6,a6,a3
    80005ae0:	058a8613          	addi	a2,s5,88
    80005ae4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005ae8:	0007b803          	ld	a6,0(a5)
    80005aec:	96c2                	add	a3,a3,a6
    80005aee:	40000613          	li	a2,1024
    80005af2:	c690                	sw	a2,8(a3)
  if(write)
    80005af4:	001c3613          	seqz	a2,s8
    80005af8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005afc:	00166613          	ori	a2,a2,1
    80005b00:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005b04:	f8842603          	lw	a2,-120(s0)
    80005b08:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b0c:	00250693          	addi	a3,a0,2
    80005b10:	0692                	slli	a3,a3,0x4
    80005b12:	96be                	add	a3,a3,a5
    80005b14:	58fd                	li	a7,-1
    80005b16:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b1a:	0612                	slli	a2,a2,0x4
    80005b1c:	9832                	add	a6,a6,a2
    80005b1e:	f9070713          	addi	a4,a4,-112
    80005b22:	973e                	add	a4,a4,a5
    80005b24:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005b28:	6398                	ld	a4,0(a5)
    80005b2a:	9732                	add	a4,a4,a2
    80005b2c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b2e:	4609                	li	a2,2
    80005b30:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b34:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b38:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005b3c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b40:	6794                	ld	a3,8(a5)
    80005b42:	0026d703          	lhu	a4,2(a3)
    80005b46:	8b1d                	andi	a4,a4,7
    80005b48:	0706                	slli	a4,a4,0x1
    80005b4a:	96ba                	add	a3,a3,a4
    80005b4c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b50:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b54:	6798                	ld	a4,8(a5)
    80005b56:	00275783          	lhu	a5,2(a4)
    80005b5a:	2785                	addiw	a5,a5,1
    80005b5c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b60:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b64:	100017b7          	lui	a5,0x10001
    80005b68:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b6c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005b70:	00243917          	auipc	s2,0x243
    80005b74:	03890913          	addi	s2,s2,56 # 80248ba8 <disk+0x128>
  while(b->disk == 1) {
    80005b78:	4485                	li	s1,1
    80005b7a:	00b79a63          	bne	a5,a1,80005b8e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005b7e:	85ca                	mv	a1,s2
    80005b80:	8556                	mv	a0,s5
    80005b82:	d58fc0ef          	jal	ra,800020da <sleep>
  while(b->disk == 1) {
    80005b86:	004aa783          	lw	a5,4(s5)
    80005b8a:	fe978ae3          	beq	a5,s1,80005b7e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005b8e:	f8042903          	lw	s2,-128(s0)
    80005b92:	00290713          	addi	a4,s2,2
    80005b96:	0712                	slli	a4,a4,0x4
    80005b98:	00243797          	auipc	a5,0x243
    80005b9c:	ee878793          	addi	a5,a5,-280 # 80248a80 <disk>
    80005ba0:	97ba                	add	a5,a5,a4
    80005ba2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ba6:	00243997          	auipc	s3,0x243
    80005baa:	eda98993          	addi	s3,s3,-294 # 80248a80 <disk>
    80005bae:	00491713          	slli	a4,s2,0x4
    80005bb2:	0009b783          	ld	a5,0(s3)
    80005bb6:	97ba                	add	a5,a5,a4
    80005bb8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005bbc:	854a                	mv	a0,s2
    80005bbe:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005bc2:	bedff0ef          	jal	ra,800057ae <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005bc6:	8885                	andi	s1,s1,1
    80005bc8:	f0fd                	bnez	s1,80005bae <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bca:	00243517          	auipc	a0,0x243
    80005bce:	fde50513          	addi	a0,a0,-34 # 80248ba8 <disk+0x128>
    80005bd2:	966fb0ef          	jal	ra,80000d38 <release>
}
    80005bd6:	70e6                	ld	ra,120(sp)
    80005bd8:	7446                	ld	s0,112(sp)
    80005bda:	74a6                	ld	s1,104(sp)
    80005bdc:	7906                	ld	s2,96(sp)
    80005bde:	69e6                	ld	s3,88(sp)
    80005be0:	6a46                	ld	s4,80(sp)
    80005be2:	6aa6                	ld	s5,72(sp)
    80005be4:	6b06                	ld	s6,64(sp)
    80005be6:	7be2                	ld	s7,56(sp)
    80005be8:	7c42                	ld	s8,48(sp)
    80005bea:	7ca2                	ld	s9,40(sp)
    80005bec:	7d02                	ld	s10,32(sp)
    80005bee:	6de2                	ld	s11,24(sp)
    80005bf0:	6109                	addi	sp,sp,128
    80005bf2:	8082                	ret

0000000080005bf4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005bf4:	1101                	addi	sp,sp,-32
    80005bf6:	ec06                	sd	ra,24(sp)
    80005bf8:	e822                	sd	s0,16(sp)
    80005bfa:	e426                	sd	s1,8(sp)
    80005bfc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005bfe:	00243497          	auipc	s1,0x243
    80005c02:	e8248493          	addi	s1,s1,-382 # 80248a80 <disk>
    80005c06:	00243517          	auipc	a0,0x243
    80005c0a:	fa250513          	addi	a0,a0,-94 # 80248ba8 <disk+0x128>
    80005c0e:	892fb0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c12:	10001737          	lui	a4,0x10001
    80005c16:	533c                	lw	a5,96(a4)
    80005c18:	8b8d                	andi	a5,a5,3
    80005c1a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005c1c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c20:	689c                	ld	a5,16(s1)
    80005c22:	0204d703          	lhu	a4,32(s1)
    80005c26:	0027d783          	lhu	a5,2(a5)
    80005c2a:	04f70663          	beq	a4,a5,80005c76 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005c2e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c32:	6898                	ld	a4,16(s1)
    80005c34:	0204d783          	lhu	a5,32(s1)
    80005c38:	8b9d                	andi	a5,a5,7
    80005c3a:	078e                	slli	a5,a5,0x3
    80005c3c:	97ba                	add	a5,a5,a4
    80005c3e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005c40:	00278713          	addi	a4,a5,2
    80005c44:	0712                	slli	a4,a4,0x4
    80005c46:	9726                	add	a4,a4,s1
    80005c48:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005c4c:	e321                	bnez	a4,80005c8c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c4e:	0789                	addi	a5,a5,2
    80005c50:	0792                	slli	a5,a5,0x4
    80005c52:	97a6                	add	a5,a5,s1
    80005c54:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c56:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c5a:	cccfc0ef          	jal	ra,80002126 <wakeup>

    disk.used_idx += 1;
    80005c5e:	0204d783          	lhu	a5,32(s1)
    80005c62:	2785                	addiw	a5,a5,1
    80005c64:	17c2                	slli	a5,a5,0x30
    80005c66:	93c1                	srli	a5,a5,0x30
    80005c68:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c6c:	6898                	ld	a4,16(s1)
    80005c6e:	00275703          	lhu	a4,2(a4)
    80005c72:	faf71ee3          	bne	a4,a5,80005c2e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005c76:	00243517          	auipc	a0,0x243
    80005c7a:	f3250513          	addi	a0,a0,-206 # 80248ba8 <disk+0x128>
    80005c7e:	8bafb0ef          	jal	ra,80000d38 <release>
}
    80005c82:	60e2                	ld	ra,24(sp)
    80005c84:	6442                	ld	s0,16(sp)
    80005c86:	64a2                	ld	s1,8(sp)
    80005c88:	6105                	addi	sp,sp,32
    80005c8a:	8082                	ret
      panic("virtio_disk_intr status");
    80005c8c:	00002517          	auipc	a0,0x2
    80005c90:	b9450513          	addi	a0,a0,-1132 # 80007820 <syscalls+0x428>
    80005c94:	af5fa0ef          	jal	ra,80000788 <panic>
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
