
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
    80000004:	86813103          	ld	sp,-1944(sp) # 80007868 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdbdc2f>
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
    8000010a:	2d8020ef          	jal	ra,800023e2 <either_copyin>
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
    80000176:	73e50513          	addi	a0,a0,1854 # 8000f8b0 <cons>
    8000017a:	327000ef          	jal	ra,80000ca0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	73248493          	addi	s1,s1,1842 # 8000f8b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	0000f917          	auipc	s2,0xf
    8000018a:	7c290913          	addi	s2,s2,1986 # 8000f948 <cons+0x98>
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
    800001a4:	091010ef          	jal	ra,80001a34 <myproc>
    800001a8:	0cc020ef          	jal	ra,80002274 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	68b010ef          	jal	ra,8000203c <sleep>
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
    800001ea:	1ae020ef          	jal	ra,80002398 <either_copyout>
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
    800001fe:	6b650513          	addi	a0,a0,1718 # 8000f8b0 <cons>
    80000202:	337000ef          	jal	ra,80000d38 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	6a450513          	addi	a0,a0,1700 # 8000f8b0 <cons>
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
    80000242:	70f72523          	sw	a5,1802(a4) # 8000f948 <cons+0x98>
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
    8000028c:	62850513          	addi	a0,a0,1576 # 8000f8b0 <cons>
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
    800002aa:	182020ef          	jal	ra,8000242c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	60250513          	addi	a0,a0,1538 # 8000f8b0 <cons>
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
    800002d2:	5e270713          	addi	a4,a4,1506 # 8000f8b0 <cons>
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
    800002f8:	5bc78793          	addi	a5,a5,1468 # 8000f8b0 <cons>
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
    80000326:	6267a783          	lw	a5,1574(a5) # 8000f948 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	57a70713          	addi	a4,a4,1402 # 8000f8b0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	56a48493          	addi	s1,s1,1386 # 8000f8b0 <cons>
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
    80000382:	53270713          	addi	a4,a4,1330 # 8000f8b0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	5af72e23          	sw	a5,1468(a4) # 8000f950 <cons+0xa0>
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
    800003b6:	4fe78793          	addi	a5,a5,1278 # 8000f8b0 <cons>
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
    800003da:	56c7ab23          	sw	a2,1398(a5) # 8000f94c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	56a50513          	addi	a0,a0,1386 # 8000f948 <cons+0x98>
    800003e6:	4a3010ef          	jal	ra,80002088 <wakeup>
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
    80000400:	4b450513          	addi	a0,a0,1204 # 8000f8b0 <cons>
    80000404:	01d000ef          	jal	ra,80000c20 <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0023f797          	auipc	a5,0x23f
    80000410:	62c78793          	addi	a5,a5,1580 # 8023fa38 <devsw>
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
    800004f8:	3907a783          	lw	a5,912(a5) # 80007884 <panicking>
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
    80000536:	42650513          	addi	a0,a0,1062 # 8000f958 <pr>
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
    80000754:	1347a783          	lw	a5,308(a5) # 80007884 <panicking>
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
    8000077e:	1de50513          	addi	a0,a0,478 # 8000f958 <pr>
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
    8000079c:	0f27a623          	sw	s2,236(a5) # 80007884 <panicking>
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
    800007be:	0d27a323          	sw	s2,198(a5) # 80007880 <panicked>
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
    800007d8:	18450513          	addi	a0,a0,388 # 8000f958 <pr>
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
    80000824:	15050513          	addi	a0,a0,336 # 8000f970 <tx_lock>
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
    80000852:	12250513          	addi	a0,a0,290 # 8000f970 <tx_lock>
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
    80000872:	01e48493          	addi	s1,s1,30 # 8000788c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	0fa98993          	addi	s3,s3,250 # 8000f970 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	00a90913          	addi	s2,s2,10 # 80007888 <tx_chan>
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
    80000892:	7aa010ef          	jal	ra,8000203c <sleep>
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
    800008b6:	0be50513          	addi	a0,a0,190 # 8000f970 <tx_lock>
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
    800008e4:	fa47a783          	lw	a5,-92(a5) # 80007884 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	f967a783          	lw	a5,-106(a5) # 80007880 <panicked>
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
    8000091a:	f6e7a783          	lw	a5,-146(a5) # 80007884 <panicking>
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
    8000096a:	00a50513          	addi	a0,a0,10 # 8000f970 <tx_lock>
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
    80000980:	ff450513          	addi	a0,a0,-12 # 8000f970 <tx_lock>
    80000984:	3b4000ef          	jal	ra,80000d38 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00007797          	auipc	a5,0x7
    80000990:	f007a023          	sw	zero,-256(a5) # 8000788c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00007517          	auipc	a0,0x7
    80000998:	ef450513          	addi	a0,a0,-268 # 80007888 <tx_chan>
    8000099c:	6ec010ef          	jal	ra,80002088 <wakeup>
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
    800009c8:	fe450513          	addi	a0,a0,-28 # 8000f9a8 <kref>
    800009cc:	2d4000ef          	jal	ra,80000ca0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	0000f517          	auipc	a0,0xf
    800009d4:	fd850513          	addi	a0,a0,-40 # 8000f9a8 <kref>
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
    80000a02:	faa50513          	addi	a0,a0,-86 # 8000f9a8 <kref>
    80000a06:	29a000ef          	jal	ra,80000ca0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	0000f517          	auipc	a0,0xf
    80000a12:	f9a50513          	addi	a0,a0,-102 # 8000f9a8 <kref>
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
    80000a46:	f6650513          	addi	a0,a0,-154 # 8000f9a8 <kref>
    80000a4a:	256000ef          	jal	ra,80000ca0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	0000f517          	auipc	a0,0xf
    80000a56:	f5650513          	addi	a0,a0,-170 # 8000f9a8 <kref>
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
    80000a8e:	00240797          	auipc	a5,0x240
    80000a92:	14278793          	addi	a5,a5,322 # 80240bd0 <end>
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
    80000ad0:	ebc90913          	addi	s2,s2,-324 # 8000f988 <kmem>
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
    80000b1a:	e9290913          	addi	s2,s2,-366 # 8000f9a8 <kref>
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
    80000b76:	e1650513          	addi	a0,a0,-490 # 8000f988 <kmem>
    80000b7a:	0a6000ef          	jal	ra,80000c20 <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00006597          	auipc	a1,0x6
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80007068 <digits+0x30>
    80000b86:	0000f517          	auipc	a0,0xf
    80000b8a:	e2250513          	addi	a0,a0,-478 # 8000f9a8 <kref>
    80000b8e:	092000ef          	jal	ra,80000c20 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00240517          	auipc	a0,0x240
    80000b9a:	03a50513          	addi	a0,a0,58 # 80240bd0 <end>
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
    80000bb8:	dd448493          	addi	s1,s1,-556 # 8000f988 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0e2000ef          	jal	ra,80000ca0 <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	c4b9                	beqz	s1,80000c12 <kalloc+0x68>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	0000f517          	auipc	a0,0xf
    80000bcc:	dc050513          	addi	a0,a0,-576 # 8000f988 <kmem>
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
    80000be4:	dc850513          	addi	a0,a0,-568 # 8000f9a8 <kref>
    80000be8:	0b8000ef          	jal	ra,80000ca0 <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	0000f517          	auipc	a0,0xf
    80000bf0:	dbc50513          	addi	a0,a0,-580 # 8000f9a8 <kref>
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
    80000c16:	d7650513          	addi	a0,a0,-650 # 8000f988 <kmem>
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
    80000c4a:	5cf000ef          	jal	ra,80001a18 <mycpu>
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
    80000c78:	5a1000ef          	jal	ra,80001a18 <mycpu>
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	cb99                	beqz	a5,80000c94 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c80:	599000ef          	jal	ra,80001a18 <mycpu>
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
    80000c94:	585000ef          	jal	ra,80001a18 <mycpu>
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
    80000cc8:	551000ef          	jal	ra,80001a18 <mycpu>
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
    80000cec:	52d000ef          	jal	ra,80001a18 <mycpu>
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
    80000de8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fdbe431>
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
    80000f1e:	2eb000ef          	jal	ra,80001a08 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f22:	00007717          	auipc	a4,0x7
    80000f26:	96e70713          	addi	a4,a4,-1682 # 80007890 <started>
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
    80000f36:	2d3000ef          	jal	ra,80001a08 <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17c50513          	addi	a0,a0,380 # 800070b8 <digits+0x80>
    80000f44:	d7eff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f48:	080000ef          	jal	ra,80000fc8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	612010ef          	jal	ra,8000255e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	534040ef          	jal	ra,80005484 <plicinithart>
  }

  scheduler();        
    80000f54:	751000ef          	jal	ra,80001ea4 <scheduler>
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
    80000f90:	1d1000ef          	jal	ra,80001960 <procinit>
    trapinit();      // trap vectors
    80000f94:	5a6010ef          	jal	ra,8000253a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	5c6010ef          	jal	ra,8000255e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	4d2040ef          	jal	ra,8000546e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	4e4040ef          	jal	ra,80005484 <plicinithart>
    binit();         // buffer cache
    80000fa4:	477010ef          	jal	ra,80002c1a <binit>
    iinit();         // inode table
    80000fa8:	1e6020ef          	jal	ra,8000318e <iinit>
    fileinit();      // file table
    80000fac:	0ce030ef          	jal	ra,8000407a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	5c4040ef          	jal	ra,80005574 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	547000ef          	jal	ra,80001cfa <userinit>
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    started = 1;
    80000fbc:	4785                	li	a5,1
    80000fbe:	00007717          	auipc	a4,0x7
    80000fc2:	8cf72923          	sw	a5,-1838(a4) # 80007890 <started>
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
    80000fd6:	8c67b783          	ld	a5,-1850(a5) # 80007898 <kernel_pagetable>
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
    80001240:	696000ef          	jal	ra,800018d6 <proc_mapstacks>
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
    80001262:	62a7bd23          	sd	a0,1594(a5) # 80007898 <kernel_pagetable>
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
    80001646:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdbe430>
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
    80001700:	334000ef          	jal	ra,80001a34 <myproc>
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

00000000800018d6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018d6:	7139                	addi	sp,sp,-64
    800018d8:	fc06                	sd	ra,56(sp)
    800018da:	f822                	sd	s0,48(sp)
    800018dc:	f426                	sd	s1,40(sp)
    800018de:	f04a                	sd	s2,32(sp)
    800018e0:	ec4e                	sd	s3,24(sp)
    800018e2:	e852                	sd	s4,16(sp)
    800018e4:	e456                	sd	s5,8(sp)
    800018e6:	e05a                	sd	s6,0(sp)
    800018e8:	0080                	addi	s0,sp,64
    800018ea:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ec:	0022e497          	auipc	s1,0x22e
    800018f0:	50448493          	addi	s1,s1,1284 # 8022fdf0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018f4:	8b26                	mv	s6,s1
    800018f6:	00005a97          	auipc	s5,0x5
    800018fa:	70aa8a93          	addi	s5,s5,1802 # 80007000 <etext>
    800018fe:	04000937          	lui	s2,0x4000
    80001902:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001904:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001906:	00234a17          	auipc	s4,0x234
    8000190a:	eeaa0a13          	addi	s4,s4,-278 # 802357f0 <tickslock>
    char *pa = kalloc();
    8000190e:	a9cff0ef          	jal	ra,80000baa <kalloc>
    80001912:	862a                	mv	a2,a0
    if(pa == 0)
    80001914:	c121                	beqz	a0,80001954 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001916:	416485b3          	sub	a1,s1,s6
    8000191a:	858d                	srai	a1,a1,0x3
    8000191c:	000ab783          	ld	a5,0(s5)
    80001920:	02f585b3          	mul	a1,a1,a5
    80001924:	2585                	addiw	a1,a1,1
    80001926:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000192a:	4719                	li	a4,6
    8000192c:	6685                	lui	a3,0x1
    8000192e:	40b905b3          	sub	a1,s2,a1
    80001932:	854e                	mv	a0,s3
    80001934:	845ff0ef          	jal	ra,80001178 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001938:	16848493          	addi	s1,s1,360
    8000193c:	fd4499e3          	bne	s1,s4,8000190e <proc_mapstacks+0x38>
  }
}
    80001940:	70e2                	ld	ra,56(sp)
    80001942:	7442                	ld	s0,48(sp)
    80001944:	74a2                	ld	s1,40(sp)
    80001946:	7902                	ld	s2,32(sp)
    80001948:	69e2                	ld	s3,24(sp)
    8000194a:	6a42                	ld	s4,16(sp)
    8000194c:	6aa2                	ld	s5,8(sp)
    8000194e:	6b02                	ld	s6,0(sp)
    80001950:	6121                	addi	sp,sp,64
    80001952:	8082                	ret
      panic("kalloc");
    80001954:	00006517          	auipc	a0,0x6
    80001958:	82450513          	addi	a0,a0,-2012 # 80007178 <digits+0x140>
    8000195c:	e2dfe0ef          	jal	ra,80000788 <panic>

0000000080001960 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001960:	7139                	addi	sp,sp,-64
    80001962:	fc06                	sd	ra,56(sp)
    80001964:	f822                	sd	s0,48(sp)
    80001966:	f426                	sd	s1,40(sp)
    80001968:	f04a                	sd	s2,32(sp)
    8000196a:	ec4e                	sd	s3,24(sp)
    8000196c:	e852                	sd	s4,16(sp)
    8000196e:	e456                	sd	s5,8(sp)
    80001970:	e05a                	sd	s6,0(sp)
    80001972:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001974:	00006597          	auipc	a1,0x6
    80001978:	80c58593          	addi	a1,a1,-2036 # 80007180 <digits+0x148>
    8000197c:	0022e517          	auipc	a0,0x22e
    80001980:	04450513          	addi	a0,a0,68 # 8022f9c0 <pid_lock>
    80001984:	a9cff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00006597          	auipc	a1,0x6
    8000198c:	80058593          	addi	a1,a1,-2048 # 80007188 <digits+0x150>
    80001990:	0022e517          	auipc	a0,0x22e
    80001994:	04850513          	addi	a0,a0,72 # 8022f9d8 <wait_lock>
    80001998:	a88ff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199c:	0022e497          	auipc	s1,0x22e
    800019a0:	45448493          	addi	s1,s1,1108 # 8022fdf0 <proc>
      initlock(&p->lock, "proc");
    800019a4:	00005b17          	auipc	s6,0x5
    800019a8:	7f4b0b13          	addi	s6,s6,2036 # 80007198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019ac:	8aa6                	mv	s5,s1
    800019ae:	00005a17          	auipc	s4,0x5
    800019b2:	652a0a13          	addi	s4,s4,1618 # 80007000 <etext>
    800019b6:	04000937          	lui	s2,0x4000
    800019ba:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019bc:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019be:	00234997          	auipc	s3,0x234
    800019c2:	e3298993          	addi	s3,s3,-462 # 802357f0 <tickslock>
      initlock(&p->lock, "proc");
    800019c6:	85da                	mv	a1,s6
    800019c8:	8526                	mv	a0,s1
    800019ca:	a56ff0ef          	jal	ra,80000c20 <initlock>
      p->state = UNUSED;
    800019ce:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019d2:	415487b3          	sub	a5,s1,s5
    800019d6:	878d                	srai	a5,a5,0x3
    800019d8:	000a3703          	ld	a4,0(s4)
    800019dc:	02e787b3          	mul	a5,a5,a4
    800019e0:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdbe431>
    800019e2:	00d7979b          	slliw	a5,a5,0xd
    800019e6:	40f907b3          	sub	a5,s2,a5
    800019ea:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ec:	16848493          	addi	s1,s1,360
    800019f0:	fd349be3          	bne	s1,s3,800019c6 <procinit+0x66>
  }
}
    800019f4:	70e2                	ld	ra,56(sp)
    800019f6:	7442                	ld	s0,48(sp)
    800019f8:	74a2                	ld	s1,40(sp)
    800019fa:	7902                	ld	s2,32(sp)
    800019fc:	69e2                	ld	s3,24(sp)
    800019fe:	6a42                	ld	s4,16(sp)
    80001a00:	6aa2                	ld	s5,8(sp)
    80001a02:	6b02                	ld	s6,0(sp)
    80001a04:	6121                	addi	sp,sp,64
    80001a06:	8082                	ret

0000000080001a08 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a08:	1141                	addi	sp,sp,-16
    80001a0a:	e422                	sd	s0,8(sp)
    80001a0c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a0e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a10:	2501                	sext.w	a0,a0
    80001a12:	6422                	ld	s0,8(sp)
    80001a14:	0141                	addi	sp,sp,16
    80001a16:	8082                	ret

0000000080001a18 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a18:	1141                	addi	sp,sp,-16
    80001a1a:	e422                	sd	s0,8(sp)
    80001a1c:	0800                	addi	s0,sp,16
    80001a1e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a20:	2781                	sext.w	a5,a5
    80001a22:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a24:	0022e517          	auipc	a0,0x22e
    80001a28:	fcc50513          	addi	a0,a0,-52 # 8022f9f0 <cpus>
    80001a2c:	953e                	add	a0,a0,a5
    80001a2e:	6422                	ld	s0,8(sp)
    80001a30:	0141                	addi	sp,sp,16
    80001a32:	8082                	ret

0000000080001a34 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a34:	1101                	addi	sp,sp,-32
    80001a36:	ec06                	sd	ra,24(sp)
    80001a38:	e822                	sd	s0,16(sp)
    80001a3a:	e426                	sd	s1,8(sp)
    80001a3c:	1000                	addi	s0,sp,32
  push_off();
    80001a3e:	a22ff0ef          	jal	ra,80000c60 <push_off>
    80001a42:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a44:	2781                	sext.w	a5,a5
    80001a46:	079e                	slli	a5,a5,0x7
    80001a48:	0022e717          	auipc	a4,0x22e
    80001a4c:	f7870713          	addi	a4,a4,-136 # 8022f9c0 <pid_lock>
    80001a50:	97ba                	add	a5,a5,a4
    80001a52:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a54:	a90ff0ef          	jal	ra,80000ce4 <pop_off>
  return p;
}
    80001a58:	8526                	mv	a0,s1
    80001a5a:	60e2                	ld	ra,24(sp)
    80001a5c:	6442                	ld	s0,16(sp)
    80001a5e:	64a2                	ld	s1,8(sp)
    80001a60:	6105                	addi	sp,sp,32
    80001a62:	8082                	ret

0000000080001a64 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a64:	7179                	addi	sp,sp,-48
    80001a66:	f406                	sd	ra,40(sp)
    80001a68:	f022                	sd	s0,32(sp)
    80001a6a:	ec26                	sd	s1,24(sp)
    80001a6c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001a6e:	fc7ff0ef          	jal	ra,80001a34 <myproc>
    80001a72:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001a74:	ac4ff0ef          	jal	ra,80000d38 <release>

  if (first) {
    80001a78:	00006797          	auipc	a5,0x6
    80001a7c:	dd87a783          	lw	a5,-552(a5) # 80007850 <first.1>
    80001a80:	cf8d                	beqz	a5,80001aba <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001a82:	4505                	li	a0,1
    80001a84:	3bd010ef          	jal	ra,80003640 <fsinit>

    first = 0;
    80001a88:	00006797          	auipc	a5,0x6
    80001a8c:	dc07a423          	sw	zero,-568(a5) # 80007850 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001a90:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001a94:	00005517          	auipc	a0,0x5
    80001a98:	70c50513          	addi	a0,a0,1804 # 800071a0 <digits+0x168>
    80001a9c:	fca43823          	sd	a0,-48(s0)
    80001aa0:	fc043c23          	sd	zero,-40(s0)
    80001aa4:	fd040593          	addi	a1,s0,-48
    80001aa8:	447020ef          	jal	ra,800046ee <kexec>
    80001aac:	6cbc                	ld	a5,88(s1)
    80001aae:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001ab0:	6cbc                	ld	a5,88(s1)
    80001ab2:	7bb8                	ld	a4,112(a5)
    80001ab4:	57fd                	li	a5,-1
    80001ab6:	02f70d63          	beq	a4,a5,80001af0 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001aba:	2bd000ef          	jal	ra,80002576 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001abe:	68a8                	ld	a0,80(s1)
    80001ac0:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001ac2:	04000737          	lui	a4,0x4000
    80001ac6:	00004797          	auipc	a5,0x4
    80001aca:	5d678793          	addi	a5,a5,1494 # 8000609c <userret>
    80001ace:	00004697          	auipc	a3,0x4
    80001ad2:	53268693          	addi	a3,a3,1330 # 80006000 <_trampoline>
    80001ad6:	8f95                	sub	a5,a5,a3
    80001ad8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001ada:	0732                	slli	a4,a4,0xc
    80001adc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ade:	577d                	li	a4,-1
    80001ae0:	177e                	slli	a4,a4,0x3f
    80001ae2:	8d59                	or	a0,a0,a4
    80001ae4:	9782                	jalr	a5
}
    80001ae6:	70a2                	ld	ra,40(sp)
    80001ae8:	7402                	ld	s0,32(sp)
    80001aea:	64e2                	ld	s1,24(sp)
    80001aec:	6145                	addi	sp,sp,48
    80001aee:	8082                	ret
      panic("exec");
    80001af0:	00005517          	auipc	a0,0x5
    80001af4:	6b850513          	addi	a0,a0,1720 # 800071a8 <digits+0x170>
    80001af8:	c91fe0ef          	jal	ra,80000788 <panic>

0000000080001afc <allocpid>:
{
    80001afc:	1101                	addi	sp,sp,-32
    80001afe:	ec06                	sd	ra,24(sp)
    80001b00:	e822                	sd	s0,16(sp)
    80001b02:	e426                	sd	s1,8(sp)
    80001b04:	e04a                	sd	s2,0(sp)
    80001b06:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b08:	0022e917          	auipc	s2,0x22e
    80001b0c:	eb890913          	addi	s2,s2,-328 # 8022f9c0 <pid_lock>
    80001b10:	854a                	mv	a0,s2
    80001b12:	98eff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001b16:	00006797          	auipc	a5,0x6
    80001b1a:	d3e78793          	addi	a5,a5,-706 # 80007854 <nextpid>
    80001b1e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b20:	0014871b          	addiw	a4,s1,1
    80001b24:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b26:	854a                	mv	a0,s2
    80001b28:	a10ff0ef          	jal	ra,80000d38 <release>
}
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	60e2                	ld	ra,24(sp)
    80001b30:	6442                	ld	s0,16(sp)
    80001b32:	64a2                	ld	s1,8(sp)
    80001b34:	6902                	ld	s2,0(sp)
    80001b36:	6105                	addi	sp,sp,32
    80001b38:	8082                	ret

0000000080001b3a <proc_pagetable>:
{
    80001b3a:	1101                	addi	sp,sp,-32
    80001b3c:	ec06                	sd	ra,24(sp)
    80001b3e:	e822                	sd	s0,16(sp)
    80001b40:	e426                	sd	s1,8(sp)
    80001b42:	e04a                	sd	s2,0(sp)
    80001b44:	1000                	addi	s0,sp,32
    80001b46:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b48:	f26ff0ef          	jal	ra,8000126e <uvmcreate>
    80001b4c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b4e:	cd05                	beqz	a0,80001b86 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b50:	4729                	li	a4,10
    80001b52:	00004697          	auipc	a3,0x4
    80001b56:	4ae68693          	addi	a3,a3,1198 # 80006000 <_trampoline>
    80001b5a:	6605                	lui	a2,0x1
    80001b5c:	040005b7          	lui	a1,0x4000
    80001b60:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b62:	05b2                	slli	a1,a1,0xc
    80001b64:	d64ff0ef          	jal	ra,800010c8 <mappages>
    80001b68:	02054663          	bltz	a0,80001b94 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b6c:	4719                	li	a4,6
    80001b6e:	05893683          	ld	a3,88(s2)
    80001b72:	6605                	lui	a2,0x1
    80001b74:	020005b7          	lui	a1,0x2000
    80001b78:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b7a:	05b6                	slli	a1,a1,0xd
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	d4aff0ef          	jal	ra,800010c8 <mappages>
    80001b82:	00054f63          	bltz	a0,80001ba0 <proc_pagetable+0x66>
}
    80001b86:	8526                	mv	a0,s1
    80001b88:	60e2                	ld	ra,24(sp)
    80001b8a:	6442                	ld	s0,16(sp)
    80001b8c:	64a2                	ld	s1,8(sp)
    80001b8e:	6902                	ld	s2,0(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret
    uvmfree(pagetable, 0);
    80001b94:	4581                	li	a1,0
    80001b96:	8526                	mv	a0,s1
    80001b98:	8b7ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001b9c:	4481                	li	s1,0
    80001b9e:	b7e5                	j	80001b86 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba0:	4681                	li	a3,0
    80001ba2:	4605                	li	a2,1
    80001ba4:	040005b7          	lui	a1,0x4000
    80001ba8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001baa:	05b2                	slli	a1,a1,0xc
    80001bac:	8526                	mv	a0,s1
    80001bae:	ee6ff0ef          	jal	ra,80001294 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bb2:	4581                	li	a1,0
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	899ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001bba:	4481                	li	s1,0
    80001bbc:	b7e9                	j	80001b86 <proc_pagetable+0x4c>

0000000080001bbe <proc_freepagetable>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
    80001bca:	84aa                	mv	s1,a0
    80001bcc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	040005b7          	lui	a1,0x4000
    80001bd6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bd8:	05b2                	slli	a1,a1,0xc
    80001bda:	ebaff0ef          	jal	ra,80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bde:	4681                	li	a3,0
    80001be0:	4605                	li	a2,1
    80001be2:	020005b7          	lui	a1,0x2000
    80001be6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001be8:	05b6                	slli	a1,a1,0xd
    80001bea:	8526                	mv	a0,s1
    80001bec:	ea8ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bf0:	85ca                	mv	a1,s2
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	85bff0ef          	jal	ra,8000144e <uvmfree>
}
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6902                	ld	s2,0(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret

0000000080001c04 <freeproc>:
{
    80001c04:	1101                	addi	sp,sp,-32
    80001c06:	ec06                	sd	ra,24(sp)
    80001c08:	e822                	sd	s0,16(sp)
    80001c0a:	e426                	sd	s1,8(sp)
    80001c0c:	1000                	addi	s0,sp,32
    80001c0e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c10:	6d28                	ld	a0,88(a0)
    80001c12:	c119                	beqz	a0,80001c18 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001c14:	e67fe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001c18:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c1c:	68a8                	ld	a0,80(s1)
    80001c1e:	c501                	beqz	a0,80001c26 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001c20:	64ac                	ld	a1,72(s1)
    80001c22:	f9dff0ef          	jal	ra,80001bbe <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	0022e497          	auipc	s1,0x22e
    80001c64:	19048493          	addi	s1,s1,400 # 8022fdf0 <proc>
    80001c68:	00234917          	auipc	s2,0x234
    80001c6c:	b8890913          	addi	s2,s2,-1144 # 802357f0 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	82eff0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001c76:	4c9c                	lw	a5,24(s1)
    80001c78:	cb91                	beqz	a5,80001c8c <allocproc+0x38>
      release(&p->lock);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	8bcff0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c80:	16848493          	addi	s1,s1,360
    80001c84:	ff2496e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c88:	4481                	li	s1,0
    80001c8a:	a089                	j	80001ccc <allocproc+0x78>
  p->pid = allocpid();
    80001c8c:	e71ff0ef          	jal	ra,80001afc <allocpid>
    80001c90:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c92:	4785                	li	a5,1
    80001c94:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c96:	f15fe0ef          	jal	ra,80000baa <kalloc>
    80001c9a:	892a                	mv	s2,a0
    80001c9c:	eca8                	sd	a0,88(s1)
    80001c9e:	cd15                	beqz	a0,80001cda <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	e99ff0ef          	jal	ra,80001b3a <proc_pagetable>
    80001ca6:	892a                	mv	s2,a0
    80001ca8:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001caa:	c121                	beqz	a0,80001cea <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001cac:	07000613          	li	a2,112
    80001cb0:	4581                	li	a1,0
    80001cb2:	06048513          	addi	a0,s1,96
    80001cb6:	8beff0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001cba:	00000797          	auipc	a5,0x0
    80001cbe:	daa78793          	addi	a5,a5,-598 # 80001a64 <forkret>
    80001cc2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cc4:	60bc                	ld	a5,64(s1)
    80001cc6:	6705                	lui	a4,0x1
    80001cc8:	97ba                	add	a5,a5,a4
    80001cca:	f4bc                	sd	a5,104(s1)
}
    80001ccc:	8526                	mv	a0,s1
    80001cce:	60e2                	ld	ra,24(sp)
    80001cd0:	6442                	ld	s0,16(sp)
    80001cd2:	64a2                	ld	s1,8(sp)
    80001cd4:	6902                	ld	s2,0(sp)
    80001cd6:	6105                	addi	sp,sp,32
    80001cd8:	8082                	ret
    freeproc(p);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f29ff0ef          	jal	ra,80001c04 <freeproc>
    release(&p->lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	856ff0ef          	jal	ra,80000d38 <release>
    return 0;
    80001ce6:	84ca                	mv	s1,s2
    80001ce8:	b7d5                	j	80001ccc <allocproc+0x78>
    freeproc(p);
    80001cea:	8526                	mv	a0,s1
    80001cec:	f19ff0ef          	jal	ra,80001c04 <freeproc>
    release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	846ff0ef          	jal	ra,80000d38 <release>
    return 0;
    80001cf6:	84ca                	mv	s1,s2
    80001cf8:	bfd1                	j	80001ccc <allocproc+0x78>

0000000080001cfa <userinit>:
{
    80001cfa:	1101                	addi	sp,sp,-32
    80001cfc:	ec06                	sd	ra,24(sp)
    80001cfe:	e822                	sd	s0,16(sp)
    80001d00:	e426                	sd	s1,8(sp)
    80001d02:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d04:	f51ff0ef          	jal	ra,80001c54 <allocproc>
    80001d08:	84aa                	mv	s1,a0
  initproc = p;
    80001d0a:	00006797          	auipc	a5,0x6
    80001d0e:	b8a7bb23          	sd	a0,-1130(a5) # 800078a0 <initproc>
  p->cwd = namei("/");
    80001d12:	00005517          	auipc	a0,0x5
    80001d16:	49e50513          	addi	a0,a0,1182 # 800071b0 <digits+0x178>
    80001d1a:	62b010ef          	jal	ra,80003b44 <namei>
    80001d1e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d22:	478d                	li	a5,3
    80001d24:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d26:	8526                	mv	a0,s1
    80001d28:	810ff0ef          	jal	ra,80000d38 <release>
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6105                	addi	sp,sp,32
    80001d34:	8082                	ret

0000000080001d36 <growproc>:
{
    80001d36:	1101                	addi	sp,sp,-32
    80001d38:	ec06                	sd	ra,24(sp)
    80001d3a:	e822                	sd	s0,16(sp)
    80001d3c:	e426                	sd	s1,8(sp)
    80001d3e:	e04a                	sd	s2,0(sp)
    80001d40:	1000                	addi	s0,sp,32
    80001d42:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d44:	cf1ff0ef          	jal	ra,80001a34 <myproc>
    80001d48:	892a                	mv	s2,a0
  sz = p->sz;
    80001d4a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d4c:	02905963          	blez	s1,80001d7e <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001d50:	00b48633          	add	a2,s1,a1
    80001d54:	020007b7          	lui	a5,0x2000
    80001d58:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001d5a:	07b6                	slli	a5,a5,0xd
    80001d5c:	02c7ea63          	bltu	a5,a2,80001d90 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d60:	4691                	li	a3,4
    80001d62:	6928                	ld	a0,80(a0)
    80001d64:	df0ff0ef          	jal	ra,80001354 <uvmalloc>
    80001d68:	85aa                	mv	a1,a0
    80001d6a:	c50d                	beqz	a0,80001d94 <growproc+0x5e>
  p->sz = sz;
    80001d6c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d70:	4501                	li	a0,0
}
    80001d72:	60e2                	ld	ra,24(sp)
    80001d74:	6442                	ld	s0,16(sp)
    80001d76:	64a2                	ld	s1,8(sp)
    80001d78:	6902                	ld	s2,0(sp)
    80001d7a:	6105                	addi	sp,sp,32
    80001d7c:	8082                	ret
  } else if(n < 0){
    80001d7e:	fe04d7e3          	bgez	s1,80001d6c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d82:	00b48633          	add	a2,s1,a1
    80001d86:	6928                	ld	a0,80(a0)
    80001d88:	d88ff0ef          	jal	ra,80001310 <uvmdealloc>
    80001d8c:	85aa                	mv	a1,a0
    80001d8e:	bff9                	j	80001d6c <growproc+0x36>
      return -1;
    80001d90:	557d                	li	a0,-1
    80001d92:	b7c5                	j	80001d72 <growproc+0x3c>
      return -1;
    80001d94:	557d                	li	a0,-1
    80001d96:	bff1                	j	80001d72 <growproc+0x3c>

0000000080001d98 <kfork>:
{
    80001d98:	7139                	addi	sp,sp,-64
    80001d9a:	fc06                	sd	ra,56(sp)
    80001d9c:	f822                	sd	s0,48(sp)
    80001d9e:	f426                	sd	s1,40(sp)
    80001da0:	f04a                	sd	s2,32(sp)
    80001da2:	ec4e                	sd	s3,24(sp)
    80001da4:	e852                	sd	s4,16(sp)
    80001da6:	e456                	sd	s5,8(sp)
    80001da8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001daa:	c8bff0ef          	jal	ra,80001a34 <myproc>
    80001dae:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001db0:	ea5ff0ef          	jal	ra,80001c54 <allocproc>
    80001db4:	0e050663          	beqz	a0,80001ea0 <kfork+0x108>
    80001db8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dba:	048ab603          	ld	a2,72(s5)
    80001dbe:	692c                	ld	a1,80(a0)
    80001dc0:	050ab503          	ld	a0,80(s5)
    80001dc4:	ebcff0ef          	jal	ra,80001480 <uvmcopy>
    80001dc8:	04054863          	bltz	a0,80001e18 <kfork+0x80>
  np->sz = p->sz;
    80001dcc:	048ab783          	ld	a5,72(s5)
    80001dd0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dd4:	058ab683          	ld	a3,88(s5)
    80001dd8:	87b6                	mv	a5,a3
    80001dda:	058a3703          	ld	a4,88(s4)
    80001dde:	12068693          	addi	a3,a3,288
    80001de2:	0007b803          	ld	a6,0(a5)
    80001de6:	6788                	ld	a0,8(a5)
    80001de8:	6b8c                	ld	a1,16(a5)
    80001dea:	6f90                	ld	a2,24(a5)
    80001dec:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001df0:	e708                	sd	a0,8(a4)
    80001df2:	eb0c                	sd	a1,16(a4)
    80001df4:	ef10                	sd	a2,24(a4)
    80001df6:	02078793          	addi	a5,a5,32
    80001dfa:	02070713          	addi	a4,a4,32
    80001dfe:	fed792e3          	bne	a5,a3,80001de2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e02:	058a3783          	ld	a5,88(s4)
    80001e06:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e0a:	0d0a8493          	addi	s1,s5,208
    80001e0e:	0d0a0913          	addi	s2,s4,208
    80001e12:	150a8993          	addi	s3,s5,336
    80001e16:	a829                	j	80001e30 <kfork+0x98>
    freeproc(np);
    80001e18:	8552                	mv	a0,s4
    80001e1a:	debff0ef          	jal	ra,80001c04 <freeproc>
    release(&np->lock);
    80001e1e:	8552                	mv	a0,s4
    80001e20:	f19fe0ef          	jal	ra,80000d38 <release>
    return -1;
    80001e24:	597d                	li	s2,-1
    80001e26:	a09d                	j	80001e8c <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001e28:	04a1                	addi	s1,s1,8
    80001e2a:	0921                	addi	s2,s2,8
    80001e2c:	01348963          	beq	s1,s3,80001e3e <kfork+0xa6>
    if(p->ofile[i])
    80001e30:	6088                	ld	a0,0(s1)
    80001e32:	d97d                	beqz	a0,80001e28 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e34:	2c8020ef          	jal	ra,800040fc <filedup>
    80001e38:	00a93023          	sd	a0,0(s2)
    80001e3c:	b7f5                	j	80001e28 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001e3e:	150ab503          	ld	a0,336(s5)
    80001e42:	4d8010ef          	jal	ra,8000331a <idup>
    80001e46:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4a:	4641                	li	a2,16
    80001e4c:	158a8593          	addi	a1,s5,344
    80001e50:	158a0513          	addi	a0,s4,344
    80001e54:	866ff0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    80001e58:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e5c:	8552                	mv	a0,s4
    80001e5e:	edbfe0ef          	jal	ra,80000d38 <release>
  acquire(&wait_lock);
    80001e62:	0022e497          	auipc	s1,0x22e
    80001e66:	b7648493          	addi	s1,s1,-1162 # 8022f9d8 <wait_lock>
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	e35fe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    80001e70:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e74:	8526                	mv	a0,s1
    80001e76:	ec3fe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	e25fe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    80001e80:	478d                	li	a5,3
    80001e82:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e86:	8552                	mv	a0,s4
    80001e88:	eb1fe0ef          	jal	ra,80000d38 <release>
}
    80001e8c:	854a                	mv	a0,s2
    80001e8e:	70e2                	ld	ra,56(sp)
    80001e90:	7442                	ld	s0,48(sp)
    80001e92:	74a2                	ld	s1,40(sp)
    80001e94:	7902                	ld	s2,32(sp)
    80001e96:	69e2                	ld	s3,24(sp)
    80001e98:	6a42                	ld	s4,16(sp)
    80001e9a:	6aa2                	ld	s5,8(sp)
    80001e9c:	6121                	addi	sp,sp,64
    80001e9e:	8082                	ret
    return -1;
    80001ea0:	597d                	li	s2,-1
    80001ea2:	b7ed                	j	80001e8c <kfork+0xf4>

0000000080001ea4 <scheduler>:
{
    80001ea4:	715d                	addi	sp,sp,-80
    80001ea6:	e486                	sd	ra,72(sp)
    80001ea8:	e0a2                	sd	s0,64(sp)
    80001eaa:	fc26                	sd	s1,56(sp)
    80001eac:	f84a                	sd	s2,48(sp)
    80001eae:	f44e                	sd	s3,40(sp)
    80001eb0:	f052                	sd	s4,32(sp)
    80001eb2:	ec56                	sd	s5,24(sp)
    80001eb4:	e85a                	sd	s6,16(sp)
    80001eb6:	e45e                	sd	s7,8(sp)
    80001eb8:	e062                	sd	s8,0(sp)
    80001eba:	0880                	addi	s0,sp,80
    80001ebc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ebe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec0:	00779b13          	slli	s6,a5,0x7
    80001ec4:	0022e717          	auipc	a4,0x22e
    80001ec8:	afc70713          	addi	a4,a4,-1284 # 8022f9c0 <pid_lock>
    80001ecc:	975a                	add	a4,a4,s6
    80001ece:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed2:	0022e717          	auipc	a4,0x22e
    80001ed6:	b2670713          	addi	a4,a4,-1242 # 8022f9f8 <cpus+0x8>
    80001eda:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001edc:	4c11                	li	s8,4
        c->proc = p;
    80001ede:	079e                	slli	a5,a5,0x7
    80001ee0:	0022ea17          	auipc	s4,0x22e
    80001ee4:	ae0a0a13          	addi	s4,s4,-1312 # 8022f9c0 <pid_lock>
    80001ee8:	9a3e                	add	s4,s4,a5
        found = 1;
    80001eea:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eec:	00234997          	auipc	s3,0x234
    80001ef0:	90498993          	addi	s3,s3,-1788 # 802357f0 <tickslock>
    80001ef4:	a83d                	j	80001f32 <scheduler+0x8e>
      release(&p->lock);
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	e41fe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001efc:	16848493          	addi	s1,s1,360
    80001f00:	03348563          	beq	s1,s3,80001f2a <scheduler+0x86>
      acquire(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	d9bfe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    80001f0a:	4c9c                	lw	a5,24(s1)
    80001f0c:	ff2795e3          	bne	a5,s2,80001ef6 <scheduler+0x52>
        p->state = RUNNING;
    80001f10:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f14:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f18:	06048593          	addi	a1,s1,96
    80001f1c:	855a                	mv	a0,s6
    80001f1e:	5b2000ef          	jal	ra,800024d0 <swtch>
        c->proc = 0;
    80001f22:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001f26:	8ade                	mv	s5,s7
    80001f28:	b7f9                	j	80001ef6 <scheduler+0x52>
    if(found == 0) {
    80001f2a:	000a9463          	bnez	s5,80001f32 <scheduler+0x8e>
      asm volatile("wfi");
    80001f2e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f32:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f36:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f3a:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f3e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001f42:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f44:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001f48:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f4a:	0022e497          	auipc	s1,0x22e
    80001f4e:	ea648493          	addi	s1,s1,-346 # 8022fdf0 <proc>
      if(p->state == RUNNABLE) {
    80001f52:	490d                	li	s2,3
    80001f54:	bf45                	j	80001f04 <scheduler+0x60>

0000000080001f56 <sched>:
{
    80001f56:	7179                	addi	sp,sp,-48
    80001f58:	f406                	sd	ra,40(sp)
    80001f5a:	f022                	sd	s0,32(sp)
    80001f5c:	ec26                	sd	s1,24(sp)
    80001f5e:	e84a                	sd	s2,16(sp)
    80001f60:	e44e                	sd	s3,8(sp)
    80001f62:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f64:	ad1ff0ef          	jal	ra,80001a34 <myproc>
    80001f68:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f6a:	ccdfe0ef          	jal	ra,80000c36 <holding>
    80001f6e:	c92d                	beqz	a0,80001fe0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f70:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f72:	2781                	sext.w	a5,a5
    80001f74:	079e                	slli	a5,a5,0x7
    80001f76:	0022e717          	auipc	a4,0x22e
    80001f7a:	a4a70713          	addi	a4,a4,-1462 # 8022f9c0 <pid_lock>
    80001f7e:	97ba                	add	a5,a5,a4
    80001f80:	0a87a703          	lw	a4,168(a5)
    80001f84:	4785                	li	a5,1
    80001f86:	06f71363          	bne	a4,a5,80001fec <sched+0x96>
  if(p->state == RUNNING)
    80001f8a:	4c98                	lw	a4,24(s1)
    80001f8c:	4791                	li	a5,4
    80001f8e:	06f70563          	beq	a4,a5,80001ff8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f92:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f96:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f98:	e7b5                	bnez	a5,80002004 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f9a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f9c:	0022e917          	auipc	s2,0x22e
    80001fa0:	a2490913          	addi	s2,s2,-1500 # 8022f9c0 <pid_lock>
    80001fa4:	2781                	sext.w	a5,a5
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	97ca                	add	a5,a5,s2
    80001faa:	0ac7a983          	lw	s3,172(a5)
    80001fae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fb0:	2781                	sext.w	a5,a5
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	0022e597          	auipc	a1,0x22e
    80001fb8:	a4458593          	addi	a1,a1,-1468 # 8022f9f8 <cpus+0x8>
    80001fbc:	95be                	add	a1,a1,a5
    80001fbe:	06048513          	addi	a0,s1,96
    80001fc2:	50e000ef          	jal	ra,800024d0 <swtch>
    80001fc6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc8:	2781                	sext.w	a5,a5
    80001fca:	079e                	slli	a5,a5,0x7
    80001fcc:	993e                	add	s2,s2,a5
    80001fce:	0b392623          	sw	s3,172(s2)
}
    80001fd2:	70a2                	ld	ra,40(sp)
    80001fd4:	7402                	ld	s0,32(sp)
    80001fd6:	64e2                	ld	s1,24(sp)
    80001fd8:	6942                	ld	s2,16(sp)
    80001fda:	69a2                	ld	s3,8(sp)
    80001fdc:	6145                	addi	sp,sp,48
    80001fde:	8082                	ret
    panic("sched p->lock");
    80001fe0:	00005517          	auipc	a0,0x5
    80001fe4:	1d850513          	addi	a0,a0,472 # 800071b8 <digits+0x180>
    80001fe8:	fa0fe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    80001fec:	00005517          	auipc	a0,0x5
    80001ff0:	1dc50513          	addi	a0,a0,476 # 800071c8 <digits+0x190>
    80001ff4:	f94fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    80001ff8:	00005517          	auipc	a0,0x5
    80001ffc:	1e050513          	addi	a0,a0,480 # 800071d8 <digits+0x1a0>
    80002000:	f88fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80002004:	00005517          	auipc	a0,0x5
    80002008:	1e450513          	addi	a0,a0,484 # 800071e8 <digits+0x1b0>
    8000200c:	f7cfe0ef          	jal	ra,80000788 <panic>

0000000080002010 <yield>:
{
    80002010:	1101                	addi	sp,sp,-32
    80002012:	ec06                	sd	ra,24(sp)
    80002014:	e822                	sd	s0,16(sp)
    80002016:	e426                	sd	s1,8(sp)
    80002018:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000201a:	a1bff0ef          	jal	ra,80001a34 <myproc>
    8000201e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002020:	c81fe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    80002024:	478d                	li	a5,3
    80002026:	cc9c                	sw	a5,24(s1)
  sched();
    80002028:	f2fff0ef          	jal	ra,80001f56 <sched>
  release(&p->lock);
    8000202c:	8526                	mv	a0,s1
    8000202e:	d0bfe0ef          	jal	ra,80000d38 <release>
}
    80002032:	60e2                	ld	ra,24(sp)
    80002034:	6442                	ld	s0,16(sp)
    80002036:	64a2                	ld	s1,8(sp)
    80002038:	6105                	addi	sp,sp,32
    8000203a:	8082                	ret

000000008000203c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000203c:	7179                	addi	sp,sp,-48
    8000203e:	f406                	sd	ra,40(sp)
    80002040:	f022                	sd	s0,32(sp)
    80002042:	ec26                	sd	s1,24(sp)
    80002044:	e84a                	sd	s2,16(sp)
    80002046:	e44e                	sd	s3,8(sp)
    80002048:	1800                	addi	s0,sp,48
    8000204a:	89aa                	mv	s3,a0
    8000204c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000204e:	9e7ff0ef          	jal	ra,80001a34 <myproc>
    80002052:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002054:	c4dfe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    80002058:	854a                	mv	a0,s2
    8000205a:	cdffe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    8000205e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002062:	4789                	li	a5,2
    80002064:	cc9c                	sw	a5,24(s1)

  sched();
    80002066:	ef1ff0ef          	jal	ra,80001f56 <sched>

  // Tidy up.
  p->chan = 0;
    8000206a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000206e:	8526                	mv	a0,s1
    80002070:	cc9fe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    80002074:	854a                	mv	a0,s2
    80002076:	c2bfe0ef          	jal	ra,80000ca0 <acquire>
}
    8000207a:	70a2                	ld	ra,40(sp)
    8000207c:	7402                	ld	s0,32(sp)
    8000207e:	64e2                	ld	s1,24(sp)
    80002080:	6942                	ld	s2,16(sp)
    80002082:	69a2                	ld	s3,8(sp)
    80002084:	6145                	addi	sp,sp,48
    80002086:	8082                	ret

0000000080002088 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002088:	7139                	addi	sp,sp,-64
    8000208a:	fc06                	sd	ra,56(sp)
    8000208c:	f822                	sd	s0,48(sp)
    8000208e:	f426                	sd	s1,40(sp)
    80002090:	f04a                	sd	s2,32(sp)
    80002092:	ec4e                	sd	s3,24(sp)
    80002094:	e852                	sd	s4,16(sp)
    80002096:	e456                	sd	s5,8(sp)
    80002098:	0080                	addi	s0,sp,64
    8000209a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000209c:	0022e497          	auipc	s1,0x22e
    800020a0:	d5448493          	addi	s1,s1,-684 # 8022fdf0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020a4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020a6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020a8:	00233917          	auipc	s2,0x233
    800020ac:	74890913          	addi	s2,s2,1864 # 802357f0 <tickslock>
    800020b0:	a801                	j	800020c0 <wakeup+0x38>
      }
      release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	c85fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020b8:	16848493          	addi	s1,s1,360
    800020bc:	03248263          	beq	s1,s2,800020e0 <wakeup+0x58>
    if(p != myproc()){
    800020c0:	975ff0ef          	jal	ra,80001a34 <myproc>
    800020c4:	fea48ae3          	beq	s1,a0,800020b8 <wakeup+0x30>
      acquire(&p->lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	bd7fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800020ce:	4c9c                	lw	a5,24(s1)
    800020d0:	ff3791e3          	bne	a5,s3,800020b2 <wakeup+0x2a>
    800020d4:	709c                	ld	a5,32(s1)
    800020d6:	fd479ee3          	bne	a5,s4,800020b2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800020da:	0154ac23          	sw	s5,24(s1)
    800020de:	bfd1                	j	800020b2 <wakeup+0x2a>
    }
  }
}
    800020e0:	70e2                	ld	ra,56(sp)
    800020e2:	7442                	ld	s0,48(sp)
    800020e4:	74a2                	ld	s1,40(sp)
    800020e6:	7902                	ld	s2,32(sp)
    800020e8:	69e2                	ld	s3,24(sp)
    800020ea:	6a42                	ld	s4,16(sp)
    800020ec:	6aa2                	ld	s5,8(sp)
    800020ee:	6121                	addi	sp,sp,64
    800020f0:	8082                	ret

00000000800020f2 <reparent>:
{
    800020f2:	7179                	addi	sp,sp,-48
    800020f4:	f406                	sd	ra,40(sp)
    800020f6:	f022                	sd	s0,32(sp)
    800020f8:	ec26                	sd	s1,24(sp)
    800020fa:	e84a                	sd	s2,16(sp)
    800020fc:	e44e                	sd	s3,8(sp)
    800020fe:	e052                	sd	s4,0(sp)
    80002100:	1800                	addi	s0,sp,48
    80002102:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002104:	0022e497          	auipc	s1,0x22e
    80002108:	cec48493          	addi	s1,s1,-788 # 8022fdf0 <proc>
      pp->parent = initproc;
    8000210c:	00005a17          	auipc	s4,0x5
    80002110:	794a0a13          	addi	s4,s4,1940 # 800078a0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002114:	00233997          	auipc	s3,0x233
    80002118:	6dc98993          	addi	s3,s3,1756 # 802357f0 <tickslock>
    8000211c:	a029                	j	80002126 <reparent+0x34>
    8000211e:	16848493          	addi	s1,s1,360
    80002122:	01348b63          	beq	s1,s3,80002138 <reparent+0x46>
    if(pp->parent == p){
    80002126:	7c9c                	ld	a5,56(s1)
    80002128:	ff279be3          	bne	a5,s2,8000211e <reparent+0x2c>
      pp->parent = initproc;
    8000212c:	000a3503          	ld	a0,0(s4)
    80002130:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002132:	f57ff0ef          	jal	ra,80002088 <wakeup>
    80002136:	b7e5                	j	8000211e <reparent+0x2c>
}
    80002138:	70a2                	ld	ra,40(sp)
    8000213a:	7402                	ld	s0,32(sp)
    8000213c:	64e2                	ld	s1,24(sp)
    8000213e:	6942                	ld	s2,16(sp)
    80002140:	69a2                	ld	s3,8(sp)
    80002142:	6a02                	ld	s4,0(sp)
    80002144:	6145                	addi	sp,sp,48
    80002146:	8082                	ret

0000000080002148 <kexit>:
{
    80002148:	7179                	addi	sp,sp,-48
    8000214a:	f406                	sd	ra,40(sp)
    8000214c:	f022                	sd	s0,32(sp)
    8000214e:	ec26                	sd	s1,24(sp)
    80002150:	e84a                	sd	s2,16(sp)
    80002152:	e44e                	sd	s3,8(sp)
    80002154:	e052                	sd	s4,0(sp)
    80002156:	1800                	addi	s0,sp,48
    80002158:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000215a:	8dbff0ef          	jal	ra,80001a34 <myproc>
    8000215e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002160:	00005797          	auipc	a5,0x5
    80002164:	7407b783          	ld	a5,1856(a5) # 800078a0 <initproc>
    80002168:	0d050493          	addi	s1,a0,208
    8000216c:	15050913          	addi	s2,a0,336
    80002170:	00a79f63          	bne	a5,a0,8000218e <kexit+0x46>
    panic("init exiting");
    80002174:	00005517          	auipc	a0,0x5
    80002178:	08c50513          	addi	a0,a0,140 # 80007200 <digits+0x1c8>
    8000217c:	e0cfe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80002180:	7c3010ef          	jal	ra,80004142 <fileclose>
      p->ofile[fd] = 0;
    80002184:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002188:	04a1                	addi	s1,s1,8
    8000218a:	01248563          	beq	s1,s2,80002194 <kexit+0x4c>
    if(p->ofile[fd]){
    8000218e:	6088                	ld	a0,0(s1)
    80002190:	f965                	bnez	a0,80002180 <kexit+0x38>
    80002192:	bfdd                	j	80002188 <kexit+0x40>
  begin_op();
    80002194:	3a5010ef          	jal	ra,80003d38 <begin_op>
  iput(p->cwd);
    80002198:	1509b503          	ld	a0,336(s3)
    8000219c:	332010ef          	jal	ra,800034ce <iput>
  end_op();
    800021a0:	407010ef          	jal	ra,80003da6 <end_op>
  p->cwd = 0;
    800021a4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021a8:	0022e497          	auipc	s1,0x22e
    800021ac:	83048493          	addi	s1,s1,-2000 # 8022f9d8 <wait_lock>
    800021b0:	8526                	mv	a0,s1
    800021b2:	aeffe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    800021b6:	854e                	mv	a0,s3
    800021b8:	f3bff0ef          	jal	ra,800020f2 <reparent>
  wakeup(p->parent);
    800021bc:	0389b503          	ld	a0,56(s3)
    800021c0:	ec9ff0ef          	jal	ra,80002088 <wakeup>
  acquire(&p->lock);
    800021c4:	854e                	mv	a0,s3
    800021c6:	adbfe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    800021ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021ce:	4795                	li	a5,5
    800021d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	b63fe0ef          	jal	ra,80000d38 <release>
  sched();
    800021da:	d7dff0ef          	jal	ra,80001f56 <sched>
  panic("zombie exit");
    800021de:	00005517          	auipc	a0,0x5
    800021e2:	03250513          	addi	a0,a0,50 # 80007210 <digits+0x1d8>
    800021e6:	da2fe0ef          	jal	ra,80000788 <panic>

00000000800021ea <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800021ea:	7179                	addi	sp,sp,-48
    800021ec:	f406                	sd	ra,40(sp)
    800021ee:	f022                	sd	s0,32(sp)
    800021f0:	ec26                	sd	s1,24(sp)
    800021f2:	e84a                	sd	s2,16(sp)
    800021f4:	e44e                	sd	s3,8(sp)
    800021f6:	1800                	addi	s0,sp,48
    800021f8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800021fa:	0022e497          	auipc	s1,0x22e
    800021fe:	bf648493          	addi	s1,s1,-1034 # 8022fdf0 <proc>
    80002202:	00233997          	auipc	s3,0x233
    80002206:	5ee98993          	addi	s3,s3,1518 # 802357f0 <tickslock>
    acquire(&p->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	a95fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    80002210:	589c                	lw	a5,48(s1)
    80002212:	01278b63          	beq	a5,s2,80002228 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002216:	8526                	mv	a0,s1
    80002218:	b21fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000221c:	16848493          	addi	s1,s1,360
    80002220:	ff3495e3          	bne	s1,s3,8000220a <kkill+0x20>
  }
  return -1;
    80002224:	557d                	li	a0,-1
    80002226:	a819                	j	8000223c <kkill+0x52>
      p->killed = 1;
    80002228:	4785                	li	a5,1
    8000222a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000222c:	4c98                	lw	a4,24(s1)
    8000222e:	4789                	li	a5,2
    80002230:	00f70d63          	beq	a4,a5,8000224a <kkill+0x60>
      release(&p->lock);
    80002234:	8526                	mv	a0,s1
    80002236:	b03fe0ef          	jal	ra,80000d38 <release>
      return 0;
    8000223a:	4501                	li	a0,0
}
    8000223c:	70a2                	ld	ra,40(sp)
    8000223e:	7402                	ld	s0,32(sp)
    80002240:	64e2                	ld	s1,24(sp)
    80002242:	6942                	ld	s2,16(sp)
    80002244:	69a2                	ld	s3,8(sp)
    80002246:	6145                	addi	sp,sp,48
    80002248:	8082                	ret
        p->state = RUNNABLE;
    8000224a:	478d                	li	a5,3
    8000224c:	cc9c                	sw	a5,24(s1)
    8000224e:	b7dd                	j	80002234 <kkill+0x4a>

0000000080002250 <setkilled>:

void
setkilled(struct proc *p)
{
    80002250:	1101                	addi	sp,sp,-32
    80002252:	ec06                	sd	ra,24(sp)
    80002254:	e822                	sd	s0,16(sp)
    80002256:	e426                	sd	s1,8(sp)
    80002258:	1000                	addi	s0,sp,32
    8000225a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000225c:	a45fe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    80002260:	4785                	li	a5,1
    80002262:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	ad3fe0ef          	jal	ra,80000d38 <release>
}
    8000226a:	60e2                	ld	ra,24(sp)
    8000226c:	6442                	ld	s0,16(sp)
    8000226e:	64a2                	ld	s1,8(sp)
    80002270:	6105                	addi	sp,sp,32
    80002272:	8082                	ret

0000000080002274 <killed>:

int
killed(struct proc *p)
{
    80002274:	1101                	addi	sp,sp,-32
    80002276:	ec06                	sd	ra,24(sp)
    80002278:	e822                	sd	s0,16(sp)
    8000227a:	e426                	sd	s1,8(sp)
    8000227c:	e04a                	sd	s2,0(sp)
    8000227e:	1000                	addi	s0,sp,32
    80002280:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002282:	a1ffe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    80002286:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000228a:	8526                	mv	a0,s1
    8000228c:	aadfe0ef          	jal	ra,80000d38 <release>
  return k;
}
    80002290:	854a                	mv	a0,s2
    80002292:	60e2                	ld	ra,24(sp)
    80002294:	6442                	ld	s0,16(sp)
    80002296:	64a2                	ld	s1,8(sp)
    80002298:	6902                	ld	s2,0(sp)
    8000229a:	6105                	addi	sp,sp,32
    8000229c:	8082                	ret

000000008000229e <kwait>:
{
    8000229e:	715d                	addi	sp,sp,-80
    800022a0:	e486                	sd	ra,72(sp)
    800022a2:	e0a2                	sd	s0,64(sp)
    800022a4:	fc26                	sd	s1,56(sp)
    800022a6:	f84a                	sd	s2,48(sp)
    800022a8:	f44e                	sd	s3,40(sp)
    800022aa:	f052                	sd	s4,32(sp)
    800022ac:	ec56                	sd	s5,24(sp)
    800022ae:	e85a                	sd	s6,16(sp)
    800022b0:	e45e                	sd	s7,8(sp)
    800022b2:	e062                	sd	s8,0(sp)
    800022b4:	0880                	addi	s0,sp,80
    800022b6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022b8:	f7cff0ef          	jal	ra,80001a34 <myproc>
    800022bc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022be:	0022d517          	auipc	a0,0x22d
    800022c2:	71a50513          	addi	a0,a0,1818 # 8022f9d8 <wait_lock>
    800022c6:	9dbfe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    800022ca:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800022cc:	4a15                	li	s4,5
        havekids = 1;
    800022ce:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022d0:	00233997          	auipc	s3,0x233
    800022d4:	52098993          	addi	s3,s3,1312 # 802357f0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022d8:	0022dc17          	auipc	s8,0x22d
    800022dc:	700c0c13          	addi	s8,s8,1792 # 8022f9d8 <wait_lock>
    havekids = 0;
    800022e0:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022e2:	0022e497          	auipc	s1,0x22e
    800022e6:	b0e48493          	addi	s1,s1,-1266 # 8022fdf0 <proc>
    800022ea:	a899                	j	80002340 <kwait+0xa2>
          pid = pp->pid;
    800022ec:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800022f0:	000b0c63          	beqz	s6,80002308 <kwait+0x6a>
    800022f4:	4691                	li	a3,4
    800022f6:	02c48613          	addi	a2,s1,44
    800022fa:	85da                	mv	a1,s6
    800022fc:	05093503          	ld	a0,80(s2)
    80002300:	c5eff0ef          	jal	ra,8000175e <copyout>
    80002304:	00054f63          	bltz	a0,80002322 <kwait+0x84>
          freeproc(pp);
    80002308:	8526                	mv	a0,s1
    8000230a:	8fbff0ef          	jal	ra,80001c04 <freeproc>
          release(&pp->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	a29fe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    80002314:	0022d517          	auipc	a0,0x22d
    80002318:	6c450513          	addi	a0,a0,1732 # 8022f9d8 <wait_lock>
    8000231c:	a1dfe0ef          	jal	ra,80000d38 <release>
          return pid;
    80002320:	a891                	j	80002374 <kwait+0xd6>
            release(&pp->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	a15fe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    80002328:	0022d517          	auipc	a0,0x22d
    8000232c:	6b050513          	addi	a0,a0,1712 # 8022f9d8 <wait_lock>
    80002330:	a09fe0ef          	jal	ra,80000d38 <release>
            return -1;
    80002334:	59fd                	li	s3,-1
    80002336:	a83d                	j	80002374 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002338:	16848493          	addi	s1,s1,360
    8000233c:	03348063          	beq	s1,s3,8000235c <kwait+0xbe>
      if(pp->parent == p){
    80002340:	7c9c                	ld	a5,56(s1)
    80002342:	ff279be3          	bne	a5,s2,80002338 <kwait+0x9a>
        acquire(&pp->lock);
    80002346:	8526                	mv	a0,s1
    80002348:	959fe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    8000234c:	4c9c                	lw	a5,24(s1)
    8000234e:	f9478fe3          	beq	a5,s4,800022ec <kwait+0x4e>
        release(&pp->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	9e5fe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    80002358:	8756                	mv	a4,s5
    8000235a:	bff9                	j	80002338 <kwait+0x9a>
    if(!havekids || killed(p)){
    8000235c:	c709                	beqz	a4,80002366 <kwait+0xc8>
    8000235e:	854a                	mv	a0,s2
    80002360:	f15ff0ef          	jal	ra,80002274 <killed>
    80002364:	c50d                	beqz	a0,8000238e <kwait+0xf0>
      release(&wait_lock);
    80002366:	0022d517          	auipc	a0,0x22d
    8000236a:	67250513          	addi	a0,a0,1650 # 8022f9d8 <wait_lock>
    8000236e:	9cbfe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002372:	59fd                	li	s3,-1
}
    80002374:	854e                	mv	a0,s3
    80002376:	60a6                	ld	ra,72(sp)
    80002378:	6406                	ld	s0,64(sp)
    8000237a:	74e2                	ld	s1,56(sp)
    8000237c:	7942                	ld	s2,48(sp)
    8000237e:	79a2                	ld	s3,40(sp)
    80002380:	7a02                	ld	s4,32(sp)
    80002382:	6ae2                	ld	s5,24(sp)
    80002384:	6b42                	ld	s6,16(sp)
    80002386:	6ba2                	ld	s7,8(sp)
    80002388:	6c02                	ld	s8,0(sp)
    8000238a:	6161                	addi	sp,sp,80
    8000238c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000238e:	85e2                	mv	a1,s8
    80002390:	854a                	mv	a0,s2
    80002392:	cabff0ef          	jal	ra,8000203c <sleep>
    havekids = 0;
    80002396:	b7a9                	j	800022e0 <kwait+0x42>

0000000080002398 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002398:	7179                	addi	sp,sp,-48
    8000239a:	f406                	sd	ra,40(sp)
    8000239c:	f022                	sd	s0,32(sp)
    8000239e:	ec26                	sd	s1,24(sp)
    800023a0:	e84a                	sd	s2,16(sp)
    800023a2:	e44e                	sd	s3,8(sp)
    800023a4:	e052                	sd	s4,0(sp)
    800023a6:	1800                	addi	s0,sp,48
    800023a8:	84aa                	mv	s1,a0
    800023aa:	892e                	mv	s2,a1
    800023ac:	89b2                	mv	s3,a2
    800023ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023b0:	e84ff0ef          	jal	ra,80001a34 <myproc>
  if(user_dst){
    800023b4:	cc99                	beqz	s1,800023d2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800023b6:	86d2                	mv	a3,s4
    800023b8:	864e                	mv	a2,s3
    800023ba:	85ca                	mv	a1,s2
    800023bc:	6928                	ld	a0,80(a0)
    800023be:	ba0ff0ef          	jal	ra,8000175e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6a02                	ld	s4,0(sp)
    800023ce:	6145                	addi	sp,sp,48
    800023d0:	8082                	ret
    memmove((char *)dst, src, len);
    800023d2:	000a061b          	sext.w	a2,s4
    800023d6:	85ce                	mv	a1,s3
    800023d8:	854a                	mv	a0,s2
    800023da:	9f7fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800023de:	8526                	mv	a0,s1
    800023e0:	b7cd                	j	800023c2 <either_copyout+0x2a>

00000000800023e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023e2:	7179                	addi	sp,sp,-48
    800023e4:	f406                	sd	ra,40(sp)
    800023e6:	f022                	sd	s0,32(sp)
    800023e8:	ec26                	sd	s1,24(sp)
    800023ea:	e84a                	sd	s2,16(sp)
    800023ec:	e44e                	sd	s3,8(sp)
    800023ee:	e052                	sd	s4,0(sp)
    800023f0:	1800                	addi	s0,sp,48
    800023f2:	892a                	mv	s2,a0
    800023f4:	84ae                	mv	s1,a1
    800023f6:	89b2                	mv	s3,a2
    800023f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023fa:	e3aff0ef          	jal	ra,80001a34 <myproc>
  if(user_src){
    800023fe:	cc99                	beqz	s1,8000241c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002400:	86d2                	mv	a3,s4
    80002402:	864e                	mv	a2,s3
    80002404:	85ca                	mv	a1,s2
    80002406:	6928                	ld	a0,80(a0)
    80002408:	c40ff0ef          	jal	ra,80001848 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000240c:	70a2                	ld	ra,40(sp)
    8000240e:	7402                	ld	s0,32(sp)
    80002410:	64e2                	ld	s1,24(sp)
    80002412:	6942                	ld	s2,16(sp)
    80002414:	69a2                	ld	s3,8(sp)
    80002416:	6a02                	ld	s4,0(sp)
    80002418:	6145                	addi	sp,sp,48
    8000241a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000241c:	000a061b          	sext.w	a2,s4
    80002420:	85ce                	mv	a1,s3
    80002422:	854a                	mv	a0,s2
    80002424:	9adfe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    80002428:	8526                	mv	a0,s1
    8000242a:	b7cd                	j	8000240c <either_copyin+0x2a>

000000008000242c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000242c:	715d                	addi	sp,sp,-80
    8000242e:	e486                	sd	ra,72(sp)
    80002430:	e0a2                	sd	s0,64(sp)
    80002432:	fc26                	sd	s1,56(sp)
    80002434:	f84a                	sd	s2,48(sp)
    80002436:	f44e                	sd	s3,40(sp)
    80002438:	f052                	sd	s4,32(sp)
    8000243a:	ec56                	sd	s5,24(sp)
    8000243c:	e85a                	sd	s6,16(sp)
    8000243e:	e45e                	sd	s7,8(sp)
    80002440:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002442:	00005517          	auipc	a0,0x5
    80002446:	c8650513          	addi	a0,a0,-890 # 800070c8 <digits+0x90>
    8000244a:	878fe0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000244e:	0022e497          	auipc	s1,0x22e
    80002452:	afa48493          	addi	s1,s1,-1286 # 8022ff48 <proc+0x158>
    80002456:	00233917          	auipc	s2,0x233
    8000245a:	4f290913          	addi	s2,s2,1266 # 80235948 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000245e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002460:	00005997          	auipc	s3,0x5
    80002464:	dc098993          	addi	s3,s3,-576 # 80007220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    80002468:	00005a97          	auipc	s5,0x5
    8000246c:	dc0a8a93          	addi	s5,s5,-576 # 80007228 <digits+0x1f0>
    printf("\n");
    80002470:	00005a17          	auipc	s4,0x5
    80002474:	c58a0a13          	addi	s4,s4,-936 # 800070c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002478:	00005b97          	auipc	s7,0x5
    8000247c:	df0b8b93          	addi	s7,s7,-528 # 80007268 <states.0>
    80002480:	a829                	j	8000249a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002482:	ed86a583          	lw	a1,-296(a3)
    80002486:	8556                	mv	a0,s5
    80002488:	83afe0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    8000248c:	8552                	mv	a0,s4
    8000248e:	834fe0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002492:	16848493          	addi	s1,s1,360
    80002496:	03248263          	beq	s1,s2,800024ba <procdump+0x8e>
    if(p->state == UNUSED)
    8000249a:	86a6                	mv	a3,s1
    8000249c:	ec04a783          	lw	a5,-320(s1)
    800024a0:	dbed                	beqz	a5,80002492 <procdump+0x66>
      state = "???";
    800024a2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024a4:	fcfb6fe3          	bltu	s6,a5,80002482 <procdump+0x56>
    800024a8:	02079713          	slli	a4,a5,0x20
    800024ac:	01d75793          	srli	a5,a4,0x1d
    800024b0:	97de                	add	a5,a5,s7
    800024b2:	6390                	ld	a2,0(a5)
    800024b4:	f679                	bnez	a2,80002482 <procdump+0x56>
      state = "???";
    800024b6:	864e                	mv	a2,s3
    800024b8:	b7e9                	j	80002482 <procdump+0x56>
  }
}
    800024ba:	60a6                	ld	ra,72(sp)
    800024bc:	6406                	ld	s0,64(sp)
    800024be:	74e2                	ld	s1,56(sp)
    800024c0:	7942                	ld	s2,48(sp)
    800024c2:	79a2                	ld	s3,40(sp)
    800024c4:	7a02                	ld	s4,32(sp)
    800024c6:	6ae2                	ld	s5,24(sp)
    800024c8:	6b42                	ld	s6,16(sp)
    800024ca:	6ba2                	ld	s7,8(sp)
    800024cc:	6161                	addi	sp,sp,80
    800024ce:	8082                	ret

00000000800024d0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024d0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024d4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024d8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024da:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024dc:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024e0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024e4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024e8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024ec:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024f0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024f4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024f8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024fc:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002500:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002504:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002508:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000250c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000250e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002510:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002514:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002518:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000251c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002520:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002524:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002528:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000252c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002530:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002534:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002538:	8082                	ret

000000008000253a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000253a:	1141                	addi	sp,sp,-16
    8000253c:	e406                	sd	ra,8(sp)
    8000253e:	e022                	sd	s0,0(sp)
    80002540:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002542:	00005597          	auipc	a1,0x5
    80002546:	d5658593          	addi	a1,a1,-682 # 80007298 <states.0+0x30>
    8000254a:	00233517          	auipc	a0,0x233
    8000254e:	2a650513          	addi	a0,a0,678 # 802357f0 <tickslock>
    80002552:	ecefe0ef          	jal	ra,80000c20 <initlock>
}
    80002556:	60a2                	ld	ra,8(sp)
    80002558:	6402                	ld	s0,0(sp)
    8000255a:	0141                	addi	sp,sp,16
    8000255c:	8082                	ret

000000008000255e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000255e:	1141                	addi	sp,sp,-16
    80002560:	e422                	sd	s0,8(sp)
    80002562:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002564:	00003797          	auipc	a5,0x3
    80002568:	eac78793          	addi	a5,a5,-340 # 80005410 <kernelvec>
    8000256c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002570:	6422                	ld	s0,8(sp)
    80002572:	0141                	addi	sp,sp,16
    80002574:	8082                	ret

0000000080002576 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002576:	1141                	addi	sp,sp,-16
    80002578:	e406                	sd	ra,8(sp)
    8000257a:	e022                	sd	s0,0(sp)
    8000257c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000257e:	cb6ff0ef          	jal	ra,80001a34 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002582:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002586:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002588:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000258c:	04000737          	lui	a4,0x4000
    80002590:	00004797          	auipc	a5,0x4
    80002594:	a7078793          	addi	a5,a5,-1424 # 80006000 <_trampoline>
    80002598:	00004697          	auipc	a3,0x4
    8000259c:	a6868693          	addi	a3,a3,-1432 # 80006000 <_trampoline>
    800025a0:	8f95                	sub	a5,a5,a3
    800025a2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800025a4:	0732                	slli	a4,a4,0xc
    800025a6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025a8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800025ae:	18002773          	csrr	a4,satp
    800025b2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025b4:	6d38                	ld	a4,88(a0)
    800025b6:	613c                	ld	a5,64(a0)
    800025b8:	6685                	lui	a3,0x1
    800025ba:	97b6                	add	a5,a5,a3
    800025bc:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025be:	6d3c                	ld	a5,88(a0)
    800025c0:	00000717          	auipc	a4,0x0
    800025c4:	0f470713          	addi	a4,a4,244 # 800026b4 <usertrap>
    800025c8:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800025ca:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800025cc:	8712                	mv	a4,tp
    800025ce:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025d4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025d8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025dc:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025e2:	6f9c                	ld	a5,24(a5)
    800025e4:	14179073          	csrw	sepc,a5
}
    800025e8:	60a2                	ld	ra,8(sp)
    800025ea:	6402                	ld	s0,0(sp)
    800025ec:	0141                	addi	sp,sp,16
    800025ee:	8082                	ret

00000000800025f0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025f0:	1101                	addi	sp,sp,-32
    800025f2:	ec06                	sd	ra,24(sp)
    800025f4:	e822                	sd	s0,16(sp)
    800025f6:	e426                	sd	s1,8(sp)
    800025f8:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800025fa:	c0eff0ef          	jal	ra,80001a08 <cpuid>
    800025fe:	cd19                	beqz	a0,8000261c <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002600:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002604:	000f4737          	lui	a4,0xf4
    80002608:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000260c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000260e:	14d79073          	csrw	0x14d,a5
}
    80002612:	60e2                	ld	ra,24(sp)
    80002614:	6442                	ld	s0,16(sp)
    80002616:	64a2                	ld	s1,8(sp)
    80002618:	6105                	addi	sp,sp,32
    8000261a:	8082                	ret
    acquire(&tickslock);
    8000261c:	00233497          	auipc	s1,0x233
    80002620:	1d448493          	addi	s1,s1,468 # 802357f0 <tickslock>
    80002624:	8526                	mv	a0,s1
    80002626:	e7afe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    8000262a:	00005517          	auipc	a0,0x5
    8000262e:	27e50513          	addi	a0,a0,638 # 800078a8 <ticks>
    80002632:	411c                	lw	a5,0(a0)
    80002634:	2785                	addiw	a5,a5,1
    80002636:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002638:	a51ff0ef          	jal	ra,80002088 <wakeup>
    release(&tickslock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	efafe0ef          	jal	ra,80000d38 <release>
    80002642:	bf7d                	j	80002600 <clockintr+0x10>

0000000080002644 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002644:	1101                	addi	sp,sp,-32
    80002646:	ec06                	sd	ra,24(sp)
    80002648:	e822                	sd	s0,16(sp)
    8000264a:	e426                	sd	s1,8(sp)
    8000264c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000264e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002652:	57fd                	li	a5,-1
    80002654:	17fe                	slli	a5,a5,0x3f
    80002656:	07a5                	addi	a5,a5,9
    80002658:	00f70d63          	beq	a4,a5,80002672 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000265c:	57fd                	li	a5,-1
    8000265e:	17fe                	slli	a5,a5,0x3f
    80002660:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002662:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002664:	04f70463          	beq	a4,a5,800026ac <devintr+0x68>
  }
}
    80002668:	60e2                	ld	ra,24(sp)
    8000266a:	6442                	ld	s0,16(sp)
    8000266c:	64a2                	ld	s1,8(sp)
    8000266e:	6105                	addi	sp,sp,32
    80002670:	8082                	ret
    int irq = plic_claim();
    80002672:	647020ef          	jal	ra,800054b8 <plic_claim>
    80002676:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002678:	47a9                	li	a5,10
    8000267a:	02f50363          	beq	a0,a5,800026a0 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000267e:	4785                	li	a5,1
    80002680:	02f50363          	beq	a0,a5,800026a6 <devintr+0x62>
    return 1;
    80002684:	4505                	li	a0,1
    } else if(irq){
    80002686:	d0ed                	beqz	s1,80002668 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002688:	85a6                	mv	a1,s1
    8000268a:	00005517          	auipc	a0,0x5
    8000268e:	c1650513          	addi	a0,a0,-1002 # 800072a0 <states.0+0x38>
    80002692:	e31fd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    80002696:	8526                	mv	a0,s1
    80002698:	641020ef          	jal	ra,800054d8 <plic_complete>
    return 1;
    8000269c:	4505                	li	a0,1
    8000269e:	b7e9                	j	80002668 <devintr+0x24>
      uartintr();
    800026a0:	ab4fe0ef          	jal	ra,80000954 <uartintr>
    800026a4:	bfcd                	j	80002696 <devintr+0x52>
      virtio_disk_intr();
    800026a6:	29e030ef          	jal	ra,80005944 <virtio_disk_intr>
    800026aa:	b7f5                	j	80002696 <devintr+0x52>
    clockintr();
    800026ac:	f45ff0ef          	jal	ra,800025f0 <clockintr>
    return 2;
    800026b0:	4509                	li	a0,2
    800026b2:	bf5d                	j	80002668 <devintr+0x24>

00000000800026b4 <usertrap>:
{
    800026b4:	7179                	addi	sp,sp,-48
    800026b6:	f406                	sd	ra,40(sp)
    800026b8:	f022                	sd	s0,32(sp)
    800026ba:	ec26                	sd	s1,24(sp)
    800026bc:	e84a                	sd	s2,16(sp)
    800026be:	e44e                	sd	s3,8(sp)
    800026c0:	e052                	sd	s4,0(sp)
    800026c2:	1800                	addi	s0,sp,48
    800026c4:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026c8:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026cc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800026d0:	1007f793          	andi	a5,a5,256
    800026d4:	e7a5                	bnez	a5,8000273c <usertrap+0x88>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026d6:	00003797          	auipc	a5,0x3
    800026da:	d3a78793          	addi	a5,a5,-710 # 80005410 <kernelvec>
    800026de:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026e2:	b52ff0ef          	jal	ra,80001a34 <myproc>
    800026e6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026e8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ea:	14102773          	csrr	a4,sepc
    800026ee:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026f0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800026f4:	47a1                	li	a5,8
    800026f6:	04f70963          	beq	a4,a5,80002748 <usertrap+0x94>
  } else if((which_dev = devintr()) != 0){
    800026fa:	f4bff0ef          	jal	ra,80002644 <devintr>
    800026fe:	892a                	mv	s2,a0
    80002700:	ed5d                	bnez	a0,800027be <usertrap+0x10a>
} else if(sc == 13 || sc == 15) {
    80002702:	47b5                	li	a5,13
    80002704:	0cf98c63          	beq	s3,a5,800027dc <usertrap+0x128>
    80002708:	47bd                	li	a5,15
    8000270a:	08f99563          	bne	s3,a5,80002794 <usertrap+0xe0>
  if(vmfault(p->pagetable, va, sc == 13) != 0){
    8000270e:	4601                	li	a2,0
    80002710:	85d2                	mv	a1,s4
    80002712:	68a8                	ld	a0,80(s1)
    80002714:	fd9fe0ef          	jal	ra,800016ec <vmfault>
    80002718:	e539                	bnez	a0,80002766 <usertrap+0xb2>
    if(cowbreak(p->pagetable, va) == 0){
    8000271a:	85d2                	mv	a1,s4
    8000271c:	68a8                	ld	a0,80(s1)
    8000271e:	e17fe0ef          	jal	ra,80001534 <cowbreak>
    80002722:	c131                	beqz	a0,80002766 <usertrap+0xb2>
      printf("COW fail: pid=%d va=0x%lx pte?\n", p->pid, va);
    80002724:	8652                	mv	a2,s4
    80002726:	588c                	lw	a1,48(s1)
    80002728:	00005517          	auipc	a0,0x5
    8000272c:	bb850513          	addi	a0,a0,-1096 # 800072e0 <states.0+0x78>
    80002730:	d93fd0ef          	jal	ra,800004c2 <printf>
      setkilled(p);
    80002734:	8526                	mv	a0,s1
    80002736:	b1bff0ef          	jal	ra,80002250 <setkilled>
    8000273a:	a035                	j	80002766 <usertrap+0xb2>
    panic("usertrap: not from user mode");
    8000273c:	00005517          	auipc	a0,0x5
    80002740:	b8450513          	addi	a0,a0,-1148 # 800072c0 <states.0+0x58>
    80002744:	844fe0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002748:	b2dff0ef          	jal	ra,80002274 <killed>
    8000274c:	e121                	bnez	a0,8000278c <usertrap+0xd8>
    p->trapframe->epc += 4;
    8000274e:	6cb8                	ld	a4,88(s1)
    80002750:	6f1c                	ld	a5,24(a4)
    80002752:	0791                	addi	a5,a5,4
    80002754:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002756:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000275a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000275e:	10079073          	csrw	sstatus,a5
    syscall();
    80002762:	270000ef          	jal	ra,800029d2 <syscall>
  if(killed(p))
    80002766:	8526                	mv	a0,s1
    80002768:	b0dff0ef          	jal	ra,80002274 <killed>
    8000276c:	ed31                	bnez	a0,800027c8 <usertrap+0x114>
  prepare_return();
    8000276e:	e09ff0ef          	jal	ra,80002576 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002772:	68a8                	ld	a0,80(s1)
    80002774:	8131                	srli	a0,a0,0xc
    80002776:	57fd                	li	a5,-1
    80002778:	17fe                	slli	a5,a5,0x3f
    8000277a:	8d5d                	or	a0,a0,a5
}
    8000277c:	70a2                	ld	ra,40(sp)
    8000277e:	7402                	ld	s0,32(sp)
    80002780:	64e2                	ld	s1,24(sp)
    80002782:	6942                	ld	s2,16(sp)
    80002784:	69a2                	ld	s3,8(sp)
    80002786:	6a02                	ld	s4,0(sp)
    80002788:	6145                	addi	sp,sp,48
    8000278a:	8082                	ret
      kexit(-1);
    8000278c:	557d                	li	a0,-1
    8000278e:	9bbff0ef          	jal	ra,80002148 <kexit>
    80002792:	bf75                	j	8000274e <usertrap+0x9a>
  printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002794:	5890                	lw	a2,48(s1)
    80002796:	85ce                	mv	a1,s3
    80002798:	00005517          	auipc	a0,0x5
    8000279c:	b6850513          	addi	a0,a0,-1176 # 80007300 <states.0+0x98>
    800027a0:	d23fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027a4:	141025f3          	csrr	a1,sepc
  printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    800027a8:	8652                	mv	a2,s4
    800027aa:	00005517          	auipc	a0,0x5
    800027ae:	b8650513          	addi	a0,a0,-1146 # 80007330 <states.0+0xc8>
    800027b2:	d11fd0ef          	jal	ra,800004c2 <printf>
  setkilled(p);
    800027b6:	8526                	mv	a0,s1
    800027b8:	a99ff0ef          	jal	ra,80002250 <setkilled>
    800027bc:	b76d                	j	80002766 <usertrap+0xb2>
  if(killed(p))
    800027be:	8526                	mv	a0,s1
    800027c0:	ab5ff0ef          	jal	ra,80002274 <killed>
    800027c4:	c511                	beqz	a0,800027d0 <usertrap+0x11c>
    800027c6:	a011                	j	800027ca <usertrap+0x116>
    800027c8:	4901                	li	s2,0
    kexit(-1);
    800027ca:	557d                	li	a0,-1
    800027cc:	97dff0ef          	jal	ra,80002148 <kexit>
  if(which_dev == 2)
    800027d0:	4789                	li	a5,2
    800027d2:	f8f91ee3          	bne	s2,a5,8000276e <usertrap+0xba>
    yield();
    800027d6:	83bff0ef          	jal	ra,80002010 <yield>
    800027da:	bf51                	j	8000276e <usertrap+0xba>
  if(vmfault(p->pagetable, va, sc == 13) != 0){
    800027dc:	4605                	li	a2,1
    800027de:	85d2                	mv	a1,s4
    800027e0:	68a8                	ld	a0,80(s1)
    800027e2:	f0bfe0ef          	jal	ra,800016ec <vmfault>
    800027e6:	f141                	bnez	a0,80002766 <usertrap+0xb2>
    setkilled(p);
    800027e8:	8526                	mv	a0,s1
    800027ea:	a67ff0ef          	jal	ra,80002250 <setkilled>
    800027ee:	bfa5                	j	80002766 <usertrap+0xb2>

00000000800027f0 <kerneltrap>:
{
    800027f0:	7179                	addi	sp,sp,-48
    800027f2:	f406                	sd	ra,40(sp)
    800027f4:	f022                	sd	s0,32(sp)
    800027f6:	ec26                	sd	s1,24(sp)
    800027f8:	e84a                	sd	s2,16(sp)
    800027fa:	e44e                	sd	s3,8(sp)
    800027fc:	1800                	addi	s0,sp,48
    800027fe:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002802:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002806:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000280a:	1004f793          	andi	a5,s1,256
    8000280e:	c795                	beqz	a5,8000283a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002810:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002814:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002816:	eb85                	bnez	a5,80002846 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002818:	e2dff0ef          	jal	ra,80002644 <devintr>
    8000281c:	c91d                	beqz	a0,80002852 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000281e:	4789                	li	a5,2
    80002820:	04f50a63          	beq	a0,a5,80002874 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002824:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002828:	10049073          	csrw	sstatus,s1
}
    8000282c:	70a2                	ld	ra,40(sp)
    8000282e:	7402                	ld	s0,32(sp)
    80002830:	64e2                	ld	s1,24(sp)
    80002832:	6942                	ld	s2,16(sp)
    80002834:	69a2                	ld	s3,8(sp)
    80002836:	6145                	addi	sp,sp,48
    80002838:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000283a:	00005517          	auipc	a0,0x5
    8000283e:	b1e50513          	addi	a0,a0,-1250 # 80007358 <states.0+0xf0>
    80002842:	f47fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002846:	00005517          	auipc	a0,0x5
    8000284a:	b3a50513          	addi	a0,a0,-1222 # 80007380 <states.0+0x118>
    8000284e:	f3bfd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002852:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002856:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000285a:	85ce                	mv	a1,s3
    8000285c:	00005517          	auipc	a0,0x5
    80002860:	b4450513          	addi	a0,a0,-1212 # 800073a0 <states.0+0x138>
    80002864:	c5ffd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002868:	00005517          	auipc	a0,0x5
    8000286c:	b6050513          	addi	a0,a0,-1184 # 800073c8 <states.0+0x160>
    80002870:	f19fd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002874:	9c0ff0ef          	jal	ra,80001a34 <myproc>
    80002878:	d555                	beqz	a0,80002824 <kerneltrap+0x34>
    yield();
    8000287a:	f96ff0ef          	jal	ra,80002010 <yield>
    8000287e:	b75d                	j	80002824 <kerneltrap+0x34>

0000000080002880 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002880:	1101                	addi	sp,sp,-32
    80002882:	ec06                	sd	ra,24(sp)
    80002884:	e822                	sd	s0,16(sp)
    80002886:	e426                	sd	s1,8(sp)
    80002888:	1000                	addi	s0,sp,32
    8000288a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000288c:	9a8ff0ef          	jal	ra,80001a34 <myproc>
  switch (n) {
    80002890:	4795                	li	a5,5
    80002892:	0497e163          	bltu	a5,s1,800028d4 <argraw+0x54>
    80002896:	048a                	slli	s1,s1,0x2
    80002898:	00005717          	auipc	a4,0x5
    8000289c:	b6870713          	addi	a4,a4,-1176 # 80007400 <states.0+0x198>
    800028a0:	94ba                	add	s1,s1,a4
    800028a2:	409c                	lw	a5,0(s1)
    800028a4:	97ba                	add	a5,a5,a4
    800028a6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800028a8:	6d3c                	ld	a5,88(a0)
    800028aa:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800028ac:	60e2                	ld	ra,24(sp)
    800028ae:	6442                	ld	s0,16(sp)
    800028b0:	64a2                	ld	s1,8(sp)
    800028b2:	6105                	addi	sp,sp,32
    800028b4:	8082                	ret
    return p->trapframe->a1;
    800028b6:	6d3c                	ld	a5,88(a0)
    800028b8:	7fa8                	ld	a0,120(a5)
    800028ba:	bfcd                	j	800028ac <argraw+0x2c>
    return p->trapframe->a2;
    800028bc:	6d3c                	ld	a5,88(a0)
    800028be:	63c8                	ld	a0,128(a5)
    800028c0:	b7f5                	j	800028ac <argraw+0x2c>
    return p->trapframe->a3;
    800028c2:	6d3c                	ld	a5,88(a0)
    800028c4:	67c8                	ld	a0,136(a5)
    800028c6:	b7dd                	j	800028ac <argraw+0x2c>
    return p->trapframe->a4;
    800028c8:	6d3c                	ld	a5,88(a0)
    800028ca:	6bc8                	ld	a0,144(a5)
    800028cc:	b7c5                	j	800028ac <argraw+0x2c>
    return p->trapframe->a5;
    800028ce:	6d3c                	ld	a5,88(a0)
    800028d0:	6fc8                	ld	a0,152(a5)
    800028d2:	bfe9                	j	800028ac <argraw+0x2c>
  panic("argraw");
    800028d4:	00005517          	auipc	a0,0x5
    800028d8:	b0450513          	addi	a0,a0,-1276 # 800073d8 <states.0+0x170>
    800028dc:	eadfd0ef          	jal	ra,80000788 <panic>

00000000800028e0 <fetchaddr>:
{
    800028e0:	1101                	addi	sp,sp,-32
    800028e2:	ec06                	sd	ra,24(sp)
    800028e4:	e822                	sd	s0,16(sp)
    800028e6:	e426                	sd	s1,8(sp)
    800028e8:	e04a                	sd	s2,0(sp)
    800028ea:	1000                	addi	s0,sp,32
    800028ec:	84aa                	mv	s1,a0
    800028ee:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028f0:	944ff0ef          	jal	ra,80001a34 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028f4:	653c                	ld	a5,72(a0)
    800028f6:	02f4f663          	bgeu	s1,a5,80002922 <fetchaddr+0x42>
    800028fa:	00848713          	addi	a4,s1,8
    800028fe:	02e7e463          	bltu	a5,a4,80002926 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002902:	46a1                	li	a3,8
    80002904:	8626                	mv	a2,s1
    80002906:	85ca                	mv	a1,s2
    80002908:	6928                	ld	a0,80(a0)
    8000290a:	f3ffe0ef          	jal	ra,80001848 <copyin>
    8000290e:	00a03533          	snez	a0,a0
    80002912:	40a00533          	neg	a0,a0
}
    80002916:	60e2                	ld	ra,24(sp)
    80002918:	6442                	ld	s0,16(sp)
    8000291a:	64a2                	ld	s1,8(sp)
    8000291c:	6902                	ld	s2,0(sp)
    8000291e:	6105                	addi	sp,sp,32
    80002920:	8082                	ret
    return -1;
    80002922:	557d                	li	a0,-1
    80002924:	bfcd                	j	80002916 <fetchaddr+0x36>
    80002926:	557d                	li	a0,-1
    80002928:	b7fd                	j	80002916 <fetchaddr+0x36>

000000008000292a <fetchstr>:
{
    8000292a:	7179                	addi	sp,sp,-48
    8000292c:	f406                	sd	ra,40(sp)
    8000292e:	f022                	sd	s0,32(sp)
    80002930:	ec26                	sd	s1,24(sp)
    80002932:	e84a                	sd	s2,16(sp)
    80002934:	e44e                	sd	s3,8(sp)
    80002936:	1800                	addi	s0,sp,48
    80002938:	892a                	mv	s2,a0
    8000293a:	84ae                	mv	s1,a1
    8000293c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000293e:	8f6ff0ef          	jal	ra,80001a34 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002942:	86ce                	mv	a3,s3
    80002944:	864a                	mv	a2,s2
    80002946:	85a6                	mv	a1,s1
    80002948:	6928                	ld	a0,80(a0)
    8000294a:	cd7fe0ef          	jal	ra,80001620 <copyinstr>
    8000294e:	00054c63          	bltz	a0,80002966 <fetchstr+0x3c>
  return strlen(buf);
    80002952:	8526                	mv	a0,s1
    80002954:	d98fe0ef          	jal	ra,80000eec <strlen>
}
    80002958:	70a2                	ld	ra,40(sp)
    8000295a:	7402                	ld	s0,32(sp)
    8000295c:	64e2                	ld	s1,24(sp)
    8000295e:	6942                	ld	s2,16(sp)
    80002960:	69a2                	ld	s3,8(sp)
    80002962:	6145                	addi	sp,sp,48
    80002964:	8082                	ret
    return -1;
    80002966:	557d                	li	a0,-1
    80002968:	bfc5                	j	80002958 <fetchstr+0x2e>

000000008000296a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000296a:	1101                	addi	sp,sp,-32
    8000296c:	ec06                	sd	ra,24(sp)
    8000296e:	e822                	sd	s0,16(sp)
    80002970:	e426                	sd	s1,8(sp)
    80002972:	1000                	addi	s0,sp,32
    80002974:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002976:	f0bff0ef          	jal	ra,80002880 <argraw>
    8000297a:	c088                	sw	a0,0(s1)
}
    8000297c:	60e2                	ld	ra,24(sp)
    8000297e:	6442                	ld	s0,16(sp)
    80002980:	64a2                	ld	s1,8(sp)
    80002982:	6105                	addi	sp,sp,32
    80002984:	8082                	ret

0000000080002986 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002986:	1101                	addi	sp,sp,-32
    80002988:	ec06                	sd	ra,24(sp)
    8000298a:	e822                	sd	s0,16(sp)
    8000298c:	e426                	sd	s1,8(sp)
    8000298e:	1000                	addi	s0,sp,32
    80002990:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002992:	eefff0ef          	jal	ra,80002880 <argraw>
    80002996:	e088                	sd	a0,0(s1)
}
    80002998:	60e2                	ld	ra,24(sp)
    8000299a:	6442                	ld	s0,16(sp)
    8000299c:	64a2                	ld	s1,8(sp)
    8000299e:	6105                	addi	sp,sp,32
    800029a0:	8082                	ret

00000000800029a2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800029a2:	7179                	addi	sp,sp,-48
    800029a4:	f406                	sd	ra,40(sp)
    800029a6:	f022                	sd	s0,32(sp)
    800029a8:	ec26                	sd	s1,24(sp)
    800029aa:	e84a                	sd	s2,16(sp)
    800029ac:	1800                	addi	s0,sp,48
    800029ae:	84ae                	mv	s1,a1
    800029b0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800029b2:	fd840593          	addi	a1,s0,-40
    800029b6:	fd1ff0ef          	jal	ra,80002986 <argaddr>
  return fetchstr(addr, buf, max);
    800029ba:	864a                	mv	a2,s2
    800029bc:	85a6                	mv	a1,s1
    800029be:	fd843503          	ld	a0,-40(s0)
    800029c2:	f69ff0ef          	jal	ra,8000292a <fetchstr>
}
    800029c6:	70a2                	ld	ra,40(sp)
    800029c8:	7402                	ld	s0,32(sp)
    800029ca:	64e2                	ld	s1,24(sp)
    800029cc:	6942                	ld	s2,16(sp)
    800029ce:	6145                	addi	sp,sp,48
    800029d0:	8082                	ret

00000000800029d2 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800029d2:	1101                	addi	sp,sp,-32
    800029d4:	ec06                	sd	ra,24(sp)
    800029d6:	e822                	sd	s0,16(sp)
    800029d8:	e426                	sd	s1,8(sp)
    800029da:	e04a                	sd	s2,0(sp)
    800029dc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029de:	856ff0ef          	jal	ra,80001a34 <myproc>
    800029e2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029e4:	05853903          	ld	s2,88(a0)
    800029e8:	0a893783          	ld	a5,168(s2)
    800029ec:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029f0:	37fd                	addiw	a5,a5,-1
    800029f2:	4751                	li	a4,20
    800029f4:	00f76f63          	bltu	a4,a5,80002a12 <syscall+0x40>
    800029f8:	00369713          	slli	a4,a3,0x3
    800029fc:	00005797          	auipc	a5,0x5
    80002a00:	a1c78793          	addi	a5,a5,-1508 # 80007418 <syscalls>
    80002a04:	97ba                	add	a5,a5,a4
    80002a06:	639c                	ld	a5,0(a5)
    80002a08:	c789                	beqz	a5,80002a12 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a0a:	9782                	jalr	a5
    80002a0c:	06a93823          	sd	a0,112(s2)
    80002a10:	a829                	j	80002a2a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a12:	15848613          	addi	a2,s1,344
    80002a16:	588c                	lw	a1,48(s1)
    80002a18:	00005517          	auipc	a0,0x5
    80002a1c:	9c850513          	addi	a0,a0,-1592 # 800073e0 <states.0+0x178>
    80002a20:	aa3fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a24:	6cbc                	ld	a5,88(s1)
    80002a26:	577d                	li	a4,-1
    80002a28:	fbb8                	sd	a4,112(a5)
  }
}
    80002a2a:	60e2                	ld	ra,24(sp)
    80002a2c:	6442                	ld	s0,16(sp)
    80002a2e:	64a2                	ld	s1,8(sp)
    80002a30:	6902                	ld	s2,0(sp)
    80002a32:	6105                	addi	sp,sp,32
    80002a34:	8082                	ret

0000000080002a36 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a36:	1101                	addi	sp,sp,-32
    80002a38:	ec06                	sd	ra,24(sp)
    80002a3a:	e822                	sd	s0,16(sp)
    80002a3c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a3e:	fec40593          	addi	a1,s0,-20
    80002a42:	4501                	li	a0,0
    80002a44:	f27ff0ef          	jal	ra,8000296a <argint>
  kexit(n);
    80002a48:	fec42503          	lw	a0,-20(s0)
    80002a4c:	efcff0ef          	jal	ra,80002148 <kexit>
  return 0;  // not reached
}
    80002a50:	4501                	li	a0,0
    80002a52:	60e2                	ld	ra,24(sp)
    80002a54:	6442                	ld	s0,16(sp)
    80002a56:	6105                	addi	sp,sp,32
    80002a58:	8082                	ret

0000000080002a5a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a5a:	1141                	addi	sp,sp,-16
    80002a5c:	e406                	sd	ra,8(sp)
    80002a5e:	e022                	sd	s0,0(sp)
    80002a60:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a62:	fd3fe0ef          	jal	ra,80001a34 <myproc>
}
    80002a66:	5908                	lw	a0,48(a0)
    80002a68:	60a2                	ld	ra,8(sp)
    80002a6a:	6402                	ld	s0,0(sp)
    80002a6c:	0141                	addi	sp,sp,16
    80002a6e:	8082                	ret

0000000080002a70 <sys_fork>:

uint64
sys_fork(void)
{
    80002a70:	1141                	addi	sp,sp,-16
    80002a72:	e406                	sd	ra,8(sp)
    80002a74:	e022                	sd	s0,0(sp)
    80002a76:	0800                	addi	s0,sp,16
  return kfork();
    80002a78:	b20ff0ef          	jal	ra,80001d98 <kfork>
}
    80002a7c:	60a2                	ld	ra,8(sp)
    80002a7e:	6402                	ld	s0,0(sp)
    80002a80:	0141                	addi	sp,sp,16
    80002a82:	8082                	ret

0000000080002a84 <sys_wait>:

uint64
sys_wait(void)
{
    80002a84:	1101                	addi	sp,sp,-32
    80002a86:	ec06                	sd	ra,24(sp)
    80002a88:	e822                	sd	s0,16(sp)
    80002a8a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a8c:	fe840593          	addi	a1,s0,-24
    80002a90:	4501                	li	a0,0
    80002a92:	ef5ff0ef          	jal	ra,80002986 <argaddr>
  return kwait(p);
    80002a96:	fe843503          	ld	a0,-24(s0)
    80002a9a:	805ff0ef          	jal	ra,8000229e <kwait>
}
    80002a9e:	60e2                	ld	ra,24(sp)
    80002aa0:	6442                	ld	s0,16(sp)
    80002aa2:	6105                	addi	sp,sp,32
    80002aa4:	8082                	ret

0000000080002aa6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002aa6:	7179                	addi	sp,sp,-48
    80002aa8:	f406                	sd	ra,40(sp)
    80002aaa:	f022                	sd	s0,32(sp)
    80002aac:	ec26                	sd	s1,24(sp)
    80002aae:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ab0:	fd840593          	addi	a1,s0,-40
    80002ab4:	4501                	li	a0,0
    80002ab6:	eb5ff0ef          	jal	ra,8000296a <argint>
  argint(1, &t);
    80002aba:	fdc40593          	addi	a1,s0,-36
    80002abe:	4505                	li	a0,1
    80002ac0:	eabff0ef          	jal	ra,8000296a <argint>
  addr = myproc()->sz;
    80002ac4:	f71fe0ef          	jal	ra,80001a34 <myproc>
    80002ac8:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002aca:	fdc42703          	lw	a4,-36(s0)
    80002ace:	4785                	li	a5,1
    80002ad0:	02f70763          	beq	a4,a5,80002afe <sys_sbrk+0x58>
    80002ad4:	fd842783          	lw	a5,-40(s0)
    80002ad8:	0207c363          	bltz	a5,80002afe <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002adc:	97a6                	add	a5,a5,s1
    80002ade:	0297ee63          	bltu	a5,s1,80002b1a <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002ae2:	02000737          	lui	a4,0x2000
    80002ae6:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ae8:	0736                	slli	a4,a4,0xd
    80002aea:	02f76a63          	bltu	a4,a5,80002b1e <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002aee:	f47fe0ef          	jal	ra,80001a34 <myproc>
    80002af2:	fd842703          	lw	a4,-40(s0)
    80002af6:	653c                	ld	a5,72(a0)
    80002af8:	97ba                	add	a5,a5,a4
    80002afa:	e53c                	sd	a5,72(a0)
    80002afc:	a039                	j	80002b0a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002afe:	fd842503          	lw	a0,-40(s0)
    80002b02:	a34ff0ef          	jal	ra,80001d36 <growproc>
    80002b06:	00054863          	bltz	a0,80002b16 <sys_sbrk+0x70>
  }
  return addr;
}
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	70a2                	ld	ra,40(sp)
    80002b0e:	7402                	ld	s0,32(sp)
    80002b10:	64e2                	ld	s1,24(sp)
    80002b12:	6145                	addi	sp,sp,48
    80002b14:	8082                	ret
      return -1;
    80002b16:	54fd                	li	s1,-1
    80002b18:	bfcd                	j	80002b0a <sys_sbrk+0x64>
      return -1;
    80002b1a:	54fd                	li	s1,-1
    80002b1c:	b7fd                	j	80002b0a <sys_sbrk+0x64>
      return -1;
    80002b1e:	54fd                	li	s1,-1
    80002b20:	b7ed                	j	80002b0a <sys_sbrk+0x64>

0000000080002b22 <sys_pause>:

uint64
sys_pause(void)
{
    80002b22:	7139                	addi	sp,sp,-64
    80002b24:	fc06                	sd	ra,56(sp)
    80002b26:	f822                	sd	s0,48(sp)
    80002b28:	f426                	sd	s1,40(sp)
    80002b2a:	f04a                	sd	s2,32(sp)
    80002b2c:	ec4e                	sd	s3,24(sp)
    80002b2e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b30:	fcc40593          	addi	a1,s0,-52
    80002b34:	4501                	li	a0,0
    80002b36:	e35ff0ef          	jal	ra,8000296a <argint>
  if(n < 0)
    80002b3a:	fcc42783          	lw	a5,-52(s0)
    80002b3e:	0607c563          	bltz	a5,80002ba8 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b42:	00233517          	auipc	a0,0x233
    80002b46:	cae50513          	addi	a0,a0,-850 # 802357f0 <tickslock>
    80002b4a:	956fe0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002b4e:	00005917          	auipc	s2,0x5
    80002b52:	d5a92903          	lw	s2,-678(s2) # 800078a8 <ticks>
  while(ticks - ticks0 < n){
    80002b56:	fcc42783          	lw	a5,-52(s0)
    80002b5a:	cb8d                	beqz	a5,80002b8c <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b5c:	00233997          	auipc	s3,0x233
    80002b60:	c9498993          	addi	s3,s3,-876 # 802357f0 <tickslock>
    80002b64:	00005497          	auipc	s1,0x5
    80002b68:	d4448493          	addi	s1,s1,-700 # 800078a8 <ticks>
    if(killed(myproc())){
    80002b6c:	ec9fe0ef          	jal	ra,80001a34 <myproc>
    80002b70:	f04ff0ef          	jal	ra,80002274 <killed>
    80002b74:	ed0d                	bnez	a0,80002bae <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b76:	85ce                	mv	a1,s3
    80002b78:	8526                	mv	a0,s1
    80002b7a:	cc2ff0ef          	jal	ra,8000203c <sleep>
  while(ticks - ticks0 < n){
    80002b7e:	409c                	lw	a5,0(s1)
    80002b80:	412787bb          	subw	a5,a5,s2
    80002b84:	fcc42703          	lw	a4,-52(s0)
    80002b88:	fee7e2e3          	bltu	a5,a4,80002b6c <sys_pause+0x4a>
  }
  release(&tickslock);
    80002b8c:	00233517          	auipc	a0,0x233
    80002b90:	c6450513          	addi	a0,a0,-924 # 802357f0 <tickslock>
    80002b94:	9a4fe0ef          	jal	ra,80000d38 <release>
  return 0;
    80002b98:	4501                	li	a0,0
}
    80002b9a:	70e2                	ld	ra,56(sp)
    80002b9c:	7442                	ld	s0,48(sp)
    80002b9e:	74a2                	ld	s1,40(sp)
    80002ba0:	7902                	ld	s2,32(sp)
    80002ba2:	69e2                	ld	s3,24(sp)
    80002ba4:	6121                	addi	sp,sp,64
    80002ba6:	8082                	ret
    n = 0;
    80002ba8:	fc042623          	sw	zero,-52(s0)
    80002bac:	bf59                	j	80002b42 <sys_pause+0x20>
      release(&tickslock);
    80002bae:	00233517          	auipc	a0,0x233
    80002bb2:	c4250513          	addi	a0,a0,-958 # 802357f0 <tickslock>
    80002bb6:	982fe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002bba:	557d                	li	a0,-1
    80002bbc:	bff9                	j	80002b9a <sys_pause+0x78>

0000000080002bbe <sys_kill>:

uint64
sys_kill(void)
{
    80002bbe:	1101                	addi	sp,sp,-32
    80002bc0:	ec06                	sd	ra,24(sp)
    80002bc2:	e822                	sd	s0,16(sp)
    80002bc4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002bc6:	fec40593          	addi	a1,s0,-20
    80002bca:	4501                	li	a0,0
    80002bcc:	d9fff0ef          	jal	ra,8000296a <argint>
  return kkill(pid);
    80002bd0:	fec42503          	lw	a0,-20(s0)
    80002bd4:	e16ff0ef          	jal	ra,800021ea <kkill>
}
    80002bd8:	60e2                	ld	ra,24(sp)
    80002bda:	6442                	ld	s0,16(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	e426                	sd	s1,8(sp)
    80002be8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bea:	00233517          	auipc	a0,0x233
    80002bee:	c0650513          	addi	a0,a0,-1018 # 802357f0 <tickslock>
    80002bf2:	8aefe0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002bf6:	00005497          	auipc	s1,0x5
    80002bfa:	cb24a483          	lw	s1,-846(s1) # 800078a8 <ticks>
  release(&tickslock);
    80002bfe:	00233517          	auipc	a0,0x233
    80002c02:	bf250513          	addi	a0,a0,-1038 # 802357f0 <tickslock>
    80002c06:	932fe0ef          	jal	ra,80000d38 <release>
  return xticks;
}
    80002c0a:	02049513          	slli	a0,s1,0x20
    80002c0e:	9101                	srli	a0,a0,0x20
    80002c10:	60e2                	ld	ra,24(sp)
    80002c12:	6442                	ld	s0,16(sp)
    80002c14:	64a2                	ld	s1,8(sp)
    80002c16:	6105                	addi	sp,sp,32
    80002c18:	8082                	ret

0000000080002c1a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c1a:	7179                	addi	sp,sp,-48
    80002c1c:	f406                	sd	ra,40(sp)
    80002c1e:	f022                	sd	s0,32(sp)
    80002c20:	ec26                	sd	s1,24(sp)
    80002c22:	e84a                	sd	s2,16(sp)
    80002c24:	e44e                	sd	s3,8(sp)
    80002c26:	e052                	sd	s4,0(sp)
    80002c28:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c2a:	00005597          	auipc	a1,0x5
    80002c2e:	89e58593          	addi	a1,a1,-1890 # 800074c8 <syscalls+0xb0>
    80002c32:	00233517          	auipc	a0,0x233
    80002c36:	bd650513          	addi	a0,a0,-1066 # 80235808 <bcache>
    80002c3a:	fe7fd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c3e:	0023b797          	auipc	a5,0x23b
    80002c42:	bca78793          	addi	a5,a5,-1078 # 8023d808 <bcache+0x8000>
    80002c46:	0023b717          	auipc	a4,0x23b
    80002c4a:	e2a70713          	addi	a4,a4,-470 # 8023da70 <bcache+0x8268>
    80002c4e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c52:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c56:	00233497          	auipc	s1,0x233
    80002c5a:	bca48493          	addi	s1,s1,-1078 # 80235820 <bcache+0x18>
    b->next = bcache.head.next;
    80002c5e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c60:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c62:	00005a17          	auipc	s4,0x5
    80002c66:	86ea0a13          	addi	s4,s4,-1938 # 800074d0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002c6a:	2b893783          	ld	a5,696(s2)
    80002c6e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c70:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c74:	85d2                	mv	a1,s4
    80002c76:	01048513          	addi	a0,s1,16
    80002c7a:	302010ef          	jal	ra,80003f7c <initsleeplock>
    bcache.head.next->prev = b;
    80002c7e:	2b893783          	ld	a5,696(s2)
    80002c82:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c84:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c88:	45848493          	addi	s1,s1,1112
    80002c8c:	fd349fe3          	bne	s1,s3,80002c6a <binit+0x50>
  }
}
    80002c90:	70a2                	ld	ra,40(sp)
    80002c92:	7402                	ld	s0,32(sp)
    80002c94:	64e2                	ld	s1,24(sp)
    80002c96:	6942                	ld	s2,16(sp)
    80002c98:	69a2                	ld	s3,8(sp)
    80002c9a:	6a02                	ld	s4,0(sp)
    80002c9c:	6145                	addi	sp,sp,48
    80002c9e:	8082                	ret

0000000080002ca0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ca0:	7179                	addi	sp,sp,-48
    80002ca2:	f406                	sd	ra,40(sp)
    80002ca4:	f022                	sd	s0,32(sp)
    80002ca6:	ec26                	sd	s1,24(sp)
    80002ca8:	e84a                	sd	s2,16(sp)
    80002caa:	e44e                	sd	s3,8(sp)
    80002cac:	1800                	addi	s0,sp,48
    80002cae:	892a                	mv	s2,a0
    80002cb0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cb2:	00233517          	auipc	a0,0x233
    80002cb6:	b5650513          	addi	a0,a0,-1194 # 80235808 <bcache>
    80002cba:	fe7fd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cbe:	0023b497          	auipc	s1,0x23b
    80002cc2:	e024b483          	ld	s1,-510(s1) # 8023dac0 <bcache+0x82b8>
    80002cc6:	0023b797          	auipc	a5,0x23b
    80002cca:	daa78793          	addi	a5,a5,-598 # 8023da70 <bcache+0x8268>
    80002cce:	02f48b63          	beq	s1,a5,80002d04 <bread+0x64>
    80002cd2:	873e                	mv	a4,a5
    80002cd4:	a021                	j	80002cdc <bread+0x3c>
    80002cd6:	68a4                	ld	s1,80(s1)
    80002cd8:	02e48663          	beq	s1,a4,80002d04 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002cdc:	449c                	lw	a5,8(s1)
    80002cde:	ff279ce3          	bne	a5,s2,80002cd6 <bread+0x36>
    80002ce2:	44dc                	lw	a5,12(s1)
    80002ce4:	ff3799e3          	bne	a5,s3,80002cd6 <bread+0x36>
      b->refcnt++;
    80002ce8:	40bc                	lw	a5,64(s1)
    80002cea:	2785                	addiw	a5,a5,1
    80002cec:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cee:	00233517          	auipc	a0,0x233
    80002cf2:	b1a50513          	addi	a0,a0,-1254 # 80235808 <bcache>
    80002cf6:	842fe0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80002cfa:	01048513          	addi	a0,s1,16
    80002cfe:	2b4010ef          	jal	ra,80003fb2 <acquiresleep>
      return b;
    80002d02:	a889                	j	80002d54 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d04:	0023b497          	auipc	s1,0x23b
    80002d08:	db44b483          	ld	s1,-588(s1) # 8023dab8 <bcache+0x82b0>
    80002d0c:	0023b797          	auipc	a5,0x23b
    80002d10:	d6478793          	addi	a5,a5,-668 # 8023da70 <bcache+0x8268>
    80002d14:	00f48863          	beq	s1,a5,80002d24 <bread+0x84>
    80002d18:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d1a:	40bc                	lw	a5,64(s1)
    80002d1c:	cb91                	beqz	a5,80002d30 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d1e:	64a4                	ld	s1,72(s1)
    80002d20:	fee49de3          	bne	s1,a4,80002d1a <bread+0x7a>
  panic("bget: no buffers");
    80002d24:	00004517          	auipc	a0,0x4
    80002d28:	7b450513          	addi	a0,a0,1972 # 800074d8 <syscalls+0xc0>
    80002d2c:	a5dfd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80002d30:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d34:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d38:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d3c:	4785                	li	a5,1
    80002d3e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d40:	00233517          	auipc	a0,0x233
    80002d44:	ac850513          	addi	a0,a0,-1336 # 80235808 <bcache>
    80002d48:	ff1fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80002d4c:	01048513          	addi	a0,s1,16
    80002d50:	262010ef          	jal	ra,80003fb2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d54:	409c                	lw	a5,0(s1)
    80002d56:	cb89                	beqz	a5,80002d68 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d58:	8526                	mv	a0,s1
    80002d5a:	70a2                	ld	ra,40(sp)
    80002d5c:	7402                	ld	s0,32(sp)
    80002d5e:	64e2                	ld	s1,24(sp)
    80002d60:	6942                	ld	s2,16(sp)
    80002d62:	69a2                	ld	s3,8(sp)
    80002d64:	6145                	addi	sp,sp,48
    80002d66:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d68:	4581                	li	a1,0
    80002d6a:	8526                	mv	a0,s1
    80002d6c:	1bf020ef          	jal	ra,8000572a <virtio_disk_rw>
    b->valid = 1;
    80002d70:	4785                	li	a5,1
    80002d72:	c09c                	sw	a5,0(s1)
  return b;
    80002d74:	b7d5                	j	80002d58 <bread+0xb8>

0000000080002d76 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d76:	1101                	addi	sp,sp,-32
    80002d78:	ec06                	sd	ra,24(sp)
    80002d7a:	e822                	sd	s0,16(sp)
    80002d7c:	e426                	sd	s1,8(sp)
    80002d7e:	1000                	addi	s0,sp,32
    80002d80:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d82:	0541                	addi	a0,a0,16
    80002d84:	2ac010ef          	jal	ra,80004030 <holdingsleep>
    80002d88:	c911                	beqz	a0,80002d9c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d8a:	4585                	li	a1,1
    80002d8c:	8526                	mv	a0,s1
    80002d8e:	19d020ef          	jal	ra,8000572a <virtio_disk_rw>
}
    80002d92:	60e2                	ld	ra,24(sp)
    80002d94:	6442                	ld	s0,16(sp)
    80002d96:	64a2                	ld	s1,8(sp)
    80002d98:	6105                	addi	sp,sp,32
    80002d9a:	8082                	ret
    panic("bwrite");
    80002d9c:	00004517          	auipc	a0,0x4
    80002da0:	75450513          	addi	a0,a0,1876 # 800074f0 <syscalls+0xd8>
    80002da4:	9e5fd0ef          	jal	ra,80000788 <panic>

0000000080002da8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002da8:	1101                	addi	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	e426                	sd	s1,8(sp)
    80002db0:	e04a                	sd	s2,0(sp)
    80002db2:	1000                	addi	s0,sp,32
    80002db4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002db6:	01050913          	addi	s2,a0,16
    80002dba:	854a                	mv	a0,s2
    80002dbc:	274010ef          	jal	ra,80004030 <holdingsleep>
    80002dc0:	c13d                	beqz	a0,80002e26 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002dc2:	854a                	mv	a0,s2
    80002dc4:	234010ef          	jal	ra,80003ff8 <releasesleep>

  acquire(&bcache.lock);
    80002dc8:	00233517          	auipc	a0,0x233
    80002dcc:	a4050513          	addi	a0,a0,-1472 # 80235808 <bcache>
    80002dd0:	ed1fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80002dd4:	40bc                	lw	a5,64(s1)
    80002dd6:	37fd                	addiw	a5,a5,-1
    80002dd8:	0007871b          	sext.w	a4,a5
    80002ddc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dde:	eb05                	bnez	a4,80002e0e <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002de0:	68bc                	ld	a5,80(s1)
    80002de2:	64b8                	ld	a4,72(s1)
    80002de4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002de6:	64bc                	ld	a5,72(s1)
    80002de8:	68b8                	ld	a4,80(s1)
    80002dea:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dec:	0023b797          	auipc	a5,0x23b
    80002df0:	a1c78793          	addi	a5,a5,-1508 # 8023d808 <bcache+0x8000>
    80002df4:	2b87b703          	ld	a4,696(a5)
    80002df8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002dfa:	0023b717          	auipc	a4,0x23b
    80002dfe:	c7670713          	addi	a4,a4,-906 # 8023da70 <bcache+0x8268>
    80002e02:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e04:	2b87b703          	ld	a4,696(a5)
    80002e08:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e0a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e0e:	00233517          	auipc	a0,0x233
    80002e12:	9fa50513          	addi	a0,a0,-1542 # 80235808 <bcache>
    80002e16:	f23fd0ef          	jal	ra,80000d38 <release>
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	64a2                	ld	s1,8(sp)
    80002e20:	6902                	ld	s2,0(sp)
    80002e22:	6105                	addi	sp,sp,32
    80002e24:	8082                	ret
    panic("brelse");
    80002e26:	00004517          	auipc	a0,0x4
    80002e2a:	6d250513          	addi	a0,a0,1746 # 800074f8 <syscalls+0xe0>
    80002e2e:	95bfd0ef          	jal	ra,80000788 <panic>

0000000080002e32 <bpin>:

void
bpin(struct buf *b) {
    80002e32:	1101                	addi	sp,sp,-32
    80002e34:	ec06                	sd	ra,24(sp)
    80002e36:	e822                	sd	s0,16(sp)
    80002e38:	e426                	sd	s1,8(sp)
    80002e3a:	1000                	addi	s0,sp,32
    80002e3c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e3e:	00233517          	auipc	a0,0x233
    80002e42:	9ca50513          	addi	a0,a0,-1590 # 80235808 <bcache>
    80002e46:	e5bfd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    80002e4a:	40bc                	lw	a5,64(s1)
    80002e4c:	2785                	addiw	a5,a5,1
    80002e4e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e50:	00233517          	auipc	a0,0x233
    80002e54:	9b850513          	addi	a0,a0,-1608 # 80235808 <bcache>
    80002e58:	ee1fd0ef          	jal	ra,80000d38 <release>
}
    80002e5c:	60e2                	ld	ra,24(sp)
    80002e5e:	6442                	ld	s0,16(sp)
    80002e60:	64a2                	ld	s1,8(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret

0000000080002e66 <bunpin>:

void
bunpin(struct buf *b) {
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	e426                	sd	s1,8(sp)
    80002e6e:	1000                	addi	s0,sp,32
    80002e70:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e72:	00233517          	auipc	a0,0x233
    80002e76:	99650513          	addi	a0,a0,-1642 # 80235808 <bcache>
    80002e7a:	e27fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80002e7e:	40bc                	lw	a5,64(s1)
    80002e80:	37fd                	addiw	a5,a5,-1
    80002e82:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e84:	00233517          	auipc	a0,0x233
    80002e88:	98450513          	addi	a0,a0,-1660 # 80235808 <bcache>
    80002e8c:	eadfd0ef          	jal	ra,80000d38 <release>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6105                	addi	sp,sp,32
    80002e98:	8082                	ret

0000000080002e9a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e9a:	1101                	addi	sp,sp,-32
    80002e9c:	ec06                	sd	ra,24(sp)
    80002e9e:	e822                	sd	s0,16(sp)
    80002ea0:	e426                	sd	s1,8(sp)
    80002ea2:	e04a                	sd	s2,0(sp)
    80002ea4:	1000                	addi	s0,sp,32
    80002ea6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ea8:	00d5d59b          	srliw	a1,a1,0xd
    80002eac:	0023b797          	auipc	a5,0x23b
    80002eb0:	0387a783          	lw	a5,56(a5) # 8023dee4 <sb+0x1c>
    80002eb4:	9dbd                	addw	a1,a1,a5
    80002eb6:	debff0ef          	jal	ra,80002ca0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002eba:	0074f713          	andi	a4,s1,7
    80002ebe:	4785                	li	a5,1
    80002ec0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002ec4:	14ce                	slli	s1,s1,0x33
    80002ec6:	90d9                	srli	s1,s1,0x36
    80002ec8:	00950733          	add	a4,a0,s1
    80002ecc:	05874703          	lbu	a4,88(a4)
    80002ed0:	00e7f6b3          	and	a3,a5,a4
    80002ed4:	c29d                	beqz	a3,80002efa <bfree+0x60>
    80002ed6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002ed8:	94aa                	add	s1,s1,a0
    80002eda:	fff7c793          	not	a5,a5
    80002ede:	8f7d                	and	a4,a4,a5
    80002ee0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002ee4:	7d7000ef          	jal	ra,80003eba <log_write>
  brelse(bp);
    80002ee8:	854a                	mv	a0,s2
    80002eea:	ebfff0ef          	jal	ra,80002da8 <brelse>
}
    80002eee:	60e2                	ld	ra,24(sp)
    80002ef0:	6442                	ld	s0,16(sp)
    80002ef2:	64a2                	ld	s1,8(sp)
    80002ef4:	6902                	ld	s2,0(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret
    panic("freeing free block");
    80002efa:	00004517          	auipc	a0,0x4
    80002efe:	60650513          	addi	a0,a0,1542 # 80007500 <syscalls+0xe8>
    80002f02:	887fd0ef          	jal	ra,80000788 <panic>

0000000080002f06 <balloc>:
{
    80002f06:	711d                	addi	sp,sp,-96
    80002f08:	ec86                	sd	ra,88(sp)
    80002f0a:	e8a2                	sd	s0,80(sp)
    80002f0c:	e4a6                	sd	s1,72(sp)
    80002f0e:	e0ca                	sd	s2,64(sp)
    80002f10:	fc4e                	sd	s3,56(sp)
    80002f12:	f852                	sd	s4,48(sp)
    80002f14:	f456                	sd	s5,40(sp)
    80002f16:	f05a                	sd	s6,32(sp)
    80002f18:	ec5e                	sd	s7,24(sp)
    80002f1a:	e862                	sd	s8,16(sp)
    80002f1c:	e466                	sd	s9,8(sp)
    80002f1e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f20:	0023b797          	auipc	a5,0x23b
    80002f24:	fac7a783          	lw	a5,-84(a5) # 8023decc <sb+0x4>
    80002f28:	cff1                	beqz	a5,80003004 <balloc+0xfe>
    80002f2a:	8baa                	mv	s7,a0
    80002f2c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f2e:	0023bb17          	auipc	s6,0x23b
    80002f32:	f9ab0b13          	addi	s6,s6,-102 # 8023dec8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f36:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f38:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f3a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f3c:	6c89                	lui	s9,0x2
    80002f3e:	a0b5                	j	80002faa <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f40:	97ca                	add	a5,a5,s2
    80002f42:	8e55                	or	a2,a2,a3
    80002f44:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f48:	854a                	mv	a0,s2
    80002f4a:	771000ef          	jal	ra,80003eba <log_write>
        brelse(bp);
    80002f4e:	854a                	mv	a0,s2
    80002f50:	e59ff0ef          	jal	ra,80002da8 <brelse>
  bp = bread(dev, bno);
    80002f54:	85a6                	mv	a1,s1
    80002f56:	855e                	mv	a0,s7
    80002f58:	d49ff0ef          	jal	ra,80002ca0 <bread>
    80002f5c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f5e:	40000613          	li	a2,1024
    80002f62:	4581                	li	a1,0
    80002f64:	05850513          	addi	a0,a0,88
    80002f68:	e0dfd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    80002f6c:	854a                	mv	a0,s2
    80002f6e:	74d000ef          	jal	ra,80003eba <log_write>
  brelse(bp);
    80002f72:	854a                	mv	a0,s2
    80002f74:	e35ff0ef          	jal	ra,80002da8 <brelse>
}
    80002f78:	8526                	mv	a0,s1
    80002f7a:	60e6                	ld	ra,88(sp)
    80002f7c:	6446                	ld	s0,80(sp)
    80002f7e:	64a6                	ld	s1,72(sp)
    80002f80:	6906                	ld	s2,64(sp)
    80002f82:	79e2                	ld	s3,56(sp)
    80002f84:	7a42                	ld	s4,48(sp)
    80002f86:	7aa2                	ld	s5,40(sp)
    80002f88:	7b02                	ld	s6,32(sp)
    80002f8a:	6be2                	ld	s7,24(sp)
    80002f8c:	6c42                	ld	s8,16(sp)
    80002f8e:	6ca2                	ld	s9,8(sp)
    80002f90:	6125                	addi	sp,sp,96
    80002f92:	8082                	ret
    brelse(bp);
    80002f94:	854a                	mv	a0,s2
    80002f96:	e13ff0ef          	jal	ra,80002da8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f9a:	015c87bb          	addw	a5,s9,s5
    80002f9e:	00078a9b          	sext.w	s5,a5
    80002fa2:	004b2703          	lw	a4,4(s6)
    80002fa6:	04eaff63          	bgeu	s5,a4,80003004 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002faa:	41fad79b          	sraiw	a5,s5,0x1f
    80002fae:	0137d79b          	srliw	a5,a5,0x13
    80002fb2:	015787bb          	addw	a5,a5,s5
    80002fb6:	40d7d79b          	sraiw	a5,a5,0xd
    80002fba:	01cb2583          	lw	a1,28(s6)
    80002fbe:	9dbd                	addw	a1,a1,a5
    80002fc0:	855e                	mv	a0,s7
    80002fc2:	cdfff0ef          	jal	ra,80002ca0 <bread>
    80002fc6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fc8:	004b2503          	lw	a0,4(s6)
    80002fcc:	000a849b          	sext.w	s1,s5
    80002fd0:	8762                	mv	a4,s8
    80002fd2:	fca4f1e3          	bgeu	s1,a0,80002f94 <balloc+0x8e>
      m = 1 << (bi % 8);
    80002fd6:	00777693          	andi	a3,a4,7
    80002fda:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002fde:	41f7579b          	sraiw	a5,a4,0x1f
    80002fe2:	01d7d79b          	srliw	a5,a5,0x1d
    80002fe6:	9fb9                	addw	a5,a5,a4
    80002fe8:	4037d79b          	sraiw	a5,a5,0x3
    80002fec:	00f90633          	add	a2,s2,a5
    80002ff0:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002ff4:	00c6f5b3          	and	a1,a3,a2
    80002ff8:	d5a1                	beqz	a1,80002f40 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ffa:	2705                	addiw	a4,a4,1
    80002ffc:	2485                	addiw	s1,s1,1
    80002ffe:	fd471ae3          	bne	a4,s4,80002fd2 <balloc+0xcc>
    80003002:	bf49                	j	80002f94 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003004:	00004517          	auipc	a0,0x4
    80003008:	51450513          	addi	a0,a0,1300 # 80007518 <syscalls+0x100>
    8000300c:	cb6fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003010:	4481                	li	s1,0
    80003012:	b79d                	j	80002f78 <balloc+0x72>

0000000080003014 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003014:	7179                	addi	sp,sp,-48
    80003016:	f406                	sd	ra,40(sp)
    80003018:	f022                	sd	s0,32(sp)
    8000301a:	ec26                	sd	s1,24(sp)
    8000301c:	e84a                	sd	s2,16(sp)
    8000301e:	e44e                	sd	s3,8(sp)
    80003020:	e052                	sd	s4,0(sp)
    80003022:	1800                	addi	s0,sp,48
    80003024:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003026:	47ad                	li	a5,11
    80003028:	02b7e663          	bltu	a5,a1,80003054 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000302c:	02059793          	slli	a5,a1,0x20
    80003030:	01e7d593          	srli	a1,a5,0x1e
    80003034:	00b504b3          	add	s1,a0,a1
    80003038:	0504a903          	lw	s2,80(s1)
    8000303c:	06091663          	bnez	s2,800030a8 <bmap+0x94>
      addr = balloc(ip->dev);
    80003040:	4108                	lw	a0,0(a0)
    80003042:	ec5ff0ef          	jal	ra,80002f06 <balloc>
    80003046:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000304a:	04090f63          	beqz	s2,800030a8 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    8000304e:	0524a823          	sw	s2,80(s1)
    80003052:	a899                	j	800030a8 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003054:	ff45849b          	addiw	s1,a1,-12
    80003058:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000305c:	0ff00793          	li	a5,255
    80003060:	06e7eb63          	bltu	a5,a4,800030d6 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003064:	08052903          	lw	s2,128(a0)
    80003068:	00091b63          	bnez	s2,8000307e <bmap+0x6a>
      addr = balloc(ip->dev);
    8000306c:	4108                	lw	a0,0(a0)
    8000306e:	e99ff0ef          	jal	ra,80002f06 <balloc>
    80003072:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003076:	02090963          	beqz	s2,800030a8 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000307a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000307e:	85ca                	mv	a1,s2
    80003080:	0009a503          	lw	a0,0(s3)
    80003084:	c1dff0ef          	jal	ra,80002ca0 <bread>
    80003088:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000308a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000308e:	02049713          	slli	a4,s1,0x20
    80003092:	01e75593          	srli	a1,a4,0x1e
    80003096:	00b784b3          	add	s1,a5,a1
    8000309a:	0004a903          	lw	s2,0(s1)
    8000309e:	00090e63          	beqz	s2,800030ba <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030a2:	8552                	mv	a0,s4
    800030a4:	d05ff0ef          	jal	ra,80002da8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800030a8:	854a                	mv	a0,s2
    800030aa:	70a2                	ld	ra,40(sp)
    800030ac:	7402                	ld	s0,32(sp)
    800030ae:	64e2                	ld	s1,24(sp)
    800030b0:	6942                	ld	s2,16(sp)
    800030b2:	69a2                	ld	s3,8(sp)
    800030b4:	6a02                	ld	s4,0(sp)
    800030b6:	6145                	addi	sp,sp,48
    800030b8:	8082                	ret
      addr = balloc(ip->dev);
    800030ba:	0009a503          	lw	a0,0(s3)
    800030be:	e49ff0ef          	jal	ra,80002f06 <balloc>
    800030c2:	0005091b          	sext.w	s2,a0
      if(addr){
    800030c6:	fc090ee3          	beqz	s2,800030a2 <bmap+0x8e>
        a[bn] = addr;
    800030ca:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800030ce:	8552                	mv	a0,s4
    800030d0:	5eb000ef          	jal	ra,80003eba <log_write>
    800030d4:	b7f9                	j	800030a2 <bmap+0x8e>
  panic("bmap: out of range");
    800030d6:	00004517          	auipc	a0,0x4
    800030da:	45a50513          	addi	a0,a0,1114 # 80007530 <syscalls+0x118>
    800030de:	eaafd0ef          	jal	ra,80000788 <panic>

00000000800030e2 <iget>:
{
    800030e2:	7179                	addi	sp,sp,-48
    800030e4:	f406                	sd	ra,40(sp)
    800030e6:	f022                	sd	s0,32(sp)
    800030e8:	ec26                	sd	s1,24(sp)
    800030ea:	e84a                	sd	s2,16(sp)
    800030ec:	e44e                	sd	s3,8(sp)
    800030ee:	e052                	sd	s4,0(sp)
    800030f0:	1800                	addi	s0,sp,48
    800030f2:	89aa                	mv	s3,a0
    800030f4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800030f6:	0023b517          	auipc	a0,0x23b
    800030fa:	df250513          	addi	a0,a0,-526 # 8023dee8 <itable>
    800030fe:	ba3fd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003102:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003104:	0023b497          	auipc	s1,0x23b
    80003108:	dfc48493          	addi	s1,s1,-516 # 8023df00 <itable+0x18>
    8000310c:	0023d697          	auipc	a3,0x23d
    80003110:	88468693          	addi	a3,a3,-1916 # 8023f990 <log>
    80003114:	a039                	j	80003122 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003116:	02090963          	beqz	s2,80003148 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000311a:	08848493          	addi	s1,s1,136
    8000311e:	02d48863          	beq	s1,a3,8000314e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003122:	449c                	lw	a5,8(s1)
    80003124:	fef059e3          	blez	a5,80003116 <iget+0x34>
    80003128:	4098                	lw	a4,0(s1)
    8000312a:	ff3716e3          	bne	a4,s3,80003116 <iget+0x34>
    8000312e:	40d8                	lw	a4,4(s1)
    80003130:	ff4713e3          	bne	a4,s4,80003116 <iget+0x34>
      ip->ref++;
    80003134:	2785                	addiw	a5,a5,1
    80003136:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003138:	0023b517          	auipc	a0,0x23b
    8000313c:	db050513          	addi	a0,a0,-592 # 8023dee8 <itable>
    80003140:	bf9fd0ef          	jal	ra,80000d38 <release>
      return ip;
    80003144:	8926                	mv	s2,s1
    80003146:	a02d                	j	80003170 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003148:	fbe9                	bnez	a5,8000311a <iget+0x38>
    8000314a:	8926                	mv	s2,s1
    8000314c:	b7f9                	j	8000311a <iget+0x38>
  if(empty == 0)
    8000314e:	02090a63          	beqz	s2,80003182 <iget+0xa0>
  ip->dev = dev;
    80003152:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003156:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000315a:	4785                	li	a5,1
    8000315c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003160:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003164:	0023b517          	auipc	a0,0x23b
    80003168:	d8450513          	addi	a0,a0,-636 # 8023dee8 <itable>
    8000316c:	bcdfd0ef          	jal	ra,80000d38 <release>
}
    80003170:	854a                	mv	a0,s2
    80003172:	70a2                	ld	ra,40(sp)
    80003174:	7402                	ld	s0,32(sp)
    80003176:	64e2                	ld	s1,24(sp)
    80003178:	6942                	ld	s2,16(sp)
    8000317a:	69a2                	ld	s3,8(sp)
    8000317c:	6a02                	ld	s4,0(sp)
    8000317e:	6145                	addi	sp,sp,48
    80003180:	8082                	ret
    panic("iget: no inodes");
    80003182:	00004517          	auipc	a0,0x4
    80003186:	3c650513          	addi	a0,a0,966 # 80007548 <syscalls+0x130>
    8000318a:	dfefd0ef          	jal	ra,80000788 <panic>

000000008000318e <iinit>:
{
    8000318e:	7179                	addi	sp,sp,-48
    80003190:	f406                	sd	ra,40(sp)
    80003192:	f022                	sd	s0,32(sp)
    80003194:	ec26                	sd	s1,24(sp)
    80003196:	e84a                	sd	s2,16(sp)
    80003198:	e44e                	sd	s3,8(sp)
    8000319a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000319c:	00004597          	auipc	a1,0x4
    800031a0:	3bc58593          	addi	a1,a1,956 # 80007558 <syscalls+0x140>
    800031a4:	0023b517          	auipc	a0,0x23b
    800031a8:	d4450513          	addi	a0,a0,-700 # 8023dee8 <itable>
    800031ac:	a75fd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    800031b0:	0023b497          	auipc	s1,0x23b
    800031b4:	d6048493          	addi	s1,s1,-672 # 8023df10 <itable+0x28>
    800031b8:	0023c997          	auipc	s3,0x23c
    800031bc:	7e898993          	addi	s3,s3,2024 # 8023f9a0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031c0:	00004917          	auipc	s2,0x4
    800031c4:	3a090913          	addi	s2,s2,928 # 80007560 <syscalls+0x148>
    800031c8:	85ca                	mv	a1,s2
    800031ca:	8526                	mv	a0,s1
    800031cc:	5b1000ef          	jal	ra,80003f7c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800031d0:	08848493          	addi	s1,s1,136
    800031d4:	ff349ae3          	bne	s1,s3,800031c8 <iinit+0x3a>
}
    800031d8:	70a2                	ld	ra,40(sp)
    800031da:	7402                	ld	s0,32(sp)
    800031dc:	64e2                	ld	s1,24(sp)
    800031de:	6942                	ld	s2,16(sp)
    800031e0:	69a2                	ld	s3,8(sp)
    800031e2:	6145                	addi	sp,sp,48
    800031e4:	8082                	ret

00000000800031e6 <ialloc>:
{
    800031e6:	715d                	addi	sp,sp,-80
    800031e8:	e486                	sd	ra,72(sp)
    800031ea:	e0a2                	sd	s0,64(sp)
    800031ec:	fc26                	sd	s1,56(sp)
    800031ee:	f84a                	sd	s2,48(sp)
    800031f0:	f44e                	sd	s3,40(sp)
    800031f2:	f052                	sd	s4,32(sp)
    800031f4:	ec56                	sd	s5,24(sp)
    800031f6:	e85a                	sd	s6,16(sp)
    800031f8:	e45e                	sd	s7,8(sp)
    800031fa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800031fc:	0023b717          	auipc	a4,0x23b
    80003200:	cd872703          	lw	a4,-808(a4) # 8023ded4 <sb+0xc>
    80003204:	4785                	li	a5,1
    80003206:	04e7f663          	bgeu	a5,a4,80003252 <ialloc+0x6c>
    8000320a:	8aaa                	mv	s5,a0
    8000320c:	8bae                	mv	s7,a1
    8000320e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003210:	0023ba17          	auipc	s4,0x23b
    80003214:	cb8a0a13          	addi	s4,s4,-840 # 8023dec8 <sb>
    80003218:	00048b1b          	sext.w	s6,s1
    8000321c:	0044d593          	srli	a1,s1,0x4
    80003220:	018a2783          	lw	a5,24(s4)
    80003224:	9dbd                	addw	a1,a1,a5
    80003226:	8556                	mv	a0,s5
    80003228:	a79ff0ef          	jal	ra,80002ca0 <bread>
    8000322c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000322e:	05850993          	addi	s3,a0,88
    80003232:	00f4f793          	andi	a5,s1,15
    80003236:	079a                	slli	a5,a5,0x6
    80003238:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000323a:	00099783          	lh	a5,0(s3)
    8000323e:	cf85                	beqz	a5,80003276 <ialloc+0x90>
    brelse(bp);
    80003240:	b69ff0ef          	jal	ra,80002da8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003244:	0485                	addi	s1,s1,1
    80003246:	00ca2703          	lw	a4,12(s4)
    8000324a:	0004879b          	sext.w	a5,s1
    8000324e:	fce7e5e3          	bltu	a5,a4,80003218 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003252:	00004517          	auipc	a0,0x4
    80003256:	31650513          	addi	a0,a0,790 # 80007568 <syscalls+0x150>
    8000325a:	a68fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    8000325e:	4501                	li	a0,0
}
    80003260:	60a6                	ld	ra,72(sp)
    80003262:	6406                	ld	s0,64(sp)
    80003264:	74e2                	ld	s1,56(sp)
    80003266:	7942                	ld	s2,48(sp)
    80003268:	79a2                	ld	s3,40(sp)
    8000326a:	7a02                	ld	s4,32(sp)
    8000326c:	6ae2                	ld	s5,24(sp)
    8000326e:	6b42                	ld	s6,16(sp)
    80003270:	6ba2                	ld	s7,8(sp)
    80003272:	6161                	addi	sp,sp,80
    80003274:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003276:	04000613          	li	a2,64
    8000327a:	4581                	li	a1,0
    8000327c:	854e                	mv	a0,s3
    8000327e:	af7fd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    80003282:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003286:	854a                	mv	a0,s2
    80003288:	433000ef          	jal	ra,80003eba <log_write>
      brelse(bp);
    8000328c:	854a                	mv	a0,s2
    8000328e:	b1bff0ef          	jal	ra,80002da8 <brelse>
      return iget(dev, inum);
    80003292:	85da                	mv	a1,s6
    80003294:	8556                	mv	a0,s5
    80003296:	e4dff0ef          	jal	ra,800030e2 <iget>
    8000329a:	b7d9                	j	80003260 <ialloc+0x7a>

000000008000329c <iupdate>:
{
    8000329c:	1101                	addi	sp,sp,-32
    8000329e:	ec06                	sd	ra,24(sp)
    800032a0:	e822                	sd	s0,16(sp)
    800032a2:	e426                	sd	s1,8(sp)
    800032a4:	e04a                	sd	s2,0(sp)
    800032a6:	1000                	addi	s0,sp,32
    800032a8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032aa:	415c                	lw	a5,4(a0)
    800032ac:	0047d79b          	srliw	a5,a5,0x4
    800032b0:	0023b597          	auipc	a1,0x23b
    800032b4:	c305a583          	lw	a1,-976(a1) # 8023dee0 <sb+0x18>
    800032b8:	9dbd                	addw	a1,a1,a5
    800032ba:	4108                	lw	a0,0(a0)
    800032bc:	9e5ff0ef          	jal	ra,80002ca0 <bread>
    800032c0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032c2:	05850793          	addi	a5,a0,88
    800032c6:	40d8                	lw	a4,4(s1)
    800032c8:	8b3d                	andi	a4,a4,15
    800032ca:	071a                	slli	a4,a4,0x6
    800032cc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032ce:	04449703          	lh	a4,68(s1)
    800032d2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800032d6:	04649703          	lh	a4,70(s1)
    800032da:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800032de:	04849703          	lh	a4,72(s1)
    800032e2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800032e6:	04a49703          	lh	a4,74(s1)
    800032ea:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800032ee:	44f8                	lw	a4,76(s1)
    800032f0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032f2:	03400613          	li	a2,52
    800032f6:	05048593          	addi	a1,s1,80
    800032fa:	00c78513          	addi	a0,a5,12
    800032fe:	ad3fd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003302:	854a                	mv	a0,s2
    80003304:	3b7000ef          	jal	ra,80003eba <log_write>
  brelse(bp);
    80003308:	854a                	mv	a0,s2
    8000330a:	a9fff0ef          	jal	ra,80002da8 <brelse>
}
    8000330e:	60e2                	ld	ra,24(sp)
    80003310:	6442                	ld	s0,16(sp)
    80003312:	64a2                	ld	s1,8(sp)
    80003314:	6902                	ld	s2,0(sp)
    80003316:	6105                	addi	sp,sp,32
    80003318:	8082                	ret

000000008000331a <idup>:
{
    8000331a:	1101                	addi	sp,sp,-32
    8000331c:	ec06                	sd	ra,24(sp)
    8000331e:	e822                	sd	s0,16(sp)
    80003320:	e426                	sd	s1,8(sp)
    80003322:	1000                	addi	s0,sp,32
    80003324:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003326:	0023b517          	auipc	a0,0x23b
    8000332a:	bc250513          	addi	a0,a0,-1086 # 8023dee8 <itable>
    8000332e:	973fd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003332:	449c                	lw	a5,8(s1)
    80003334:	2785                	addiw	a5,a5,1
    80003336:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003338:	0023b517          	auipc	a0,0x23b
    8000333c:	bb050513          	addi	a0,a0,-1104 # 8023dee8 <itable>
    80003340:	9f9fd0ef          	jal	ra,80000d38 <release>
}
    80003344:	8526                	mv	a0,s1
    80003346:	60e2                	ld	ra,24(sp)
    80003348:	6442                	ld	s0,16(sp)
    8000334a:	64a2                	ld	s1,8(sp)
    8000334c:	6105                	addi	sp,sp,32
    8000334e:	8082                	ret

0000000080003350 <ilock>:
{
    80003350:	1101                	addi	sp,sp,-32
    80003352:	ec06                	sd	ra,24(sp)
    80003354:	e822                	sd	s0,16(sp)
    80003356:	e426                	sd	s1,8(sp)
    80003358:	e04a                	sd	s2,0(sp)
    8000335a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000335c:	c105                	beqz	a0,8000337c <ilock+0x2c>
    8000335e:	84aa                	mv	s1,a0
    80003360:	451c                	lw	a5,8(a0)
    80003362:	00f05d63          	blez	a5,8000337c <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003366:	0541                	addi	a0,a0,16
    80003368:	44b000ef          	jal	ra,80003fb2 <acquiresleep>
  if(ip->valid == 0){
    8000336c:	40bc                	lw	a5,64(s1)
    8000336e:	cf89                	beqz	a5,80003388 <ilock+0x38>
}
    80003370:	60e2                	ld	ra,24(sp)
    80003372:	6442                	ld	s0,16(sp)
    80003374:	64a2                	ld	s1,8(sp)
    80003376:	6902                	ld	s2,0(sp)
    80003378:	6105                	addi	sp,sp,32
    8000337a:	8082                	ret
    panic("ilock");
    8000337c:	00004517          	auipc	a0,0x4
    80003380:	20450513          	addi	a0,a0,516 # 80007580 <syscalls+0x168>
    80003384:	c04fd0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003388:	40dc                	lw	a5,4(s1)
    8000338a:	0047d79b          	srliw	a5,a5,0x4
    8000338e:	0023b597          	auipc	a1,0x23b
    80003392:	b525a583          	lw	a1,-1198(a1) # 8023dee0 <sb+0x18>
    80003396:	9dbd                	addw	a1,a1,a5
    80003398:	4088                	lw	a0,0(s1)
    8000339a:	907ff0ef          	jal	ra,80002ca0 <bread>
    8000339e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033a0:	05850593          	addi	a1,a0,88
    800033a4:	40dc                	lw	a5,4(s1)
    800033a6:	8bbd                	andi	a5,a5,15
    800033a8:	079a                	slli	a5,a5,0x6
    800033aa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033ac:	00059783          	lh	a5,0(a1)
    800033b0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033b4:	00259783          	lh	a5,2(a1)
    800033b8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033bc:	00459783          	lh	a5,4(a1)
    800033c0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033c4:	00659783          	lh	a5,6(a1)
    800033c8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033cc:	459c                	lw	a5,8(a1)
    800033ce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033d0:	03400613          	li	a2,52
    800033d4:	05b1                	addi	a1,a1,12
    800033d6:	05048513          	addi	a0,s1,80
    800033da:	9f7fd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    800033de:	854a                	mv	a0,s2
    800033e0:	9c9ff0ef          	jal	ra,80002da8 <brelse>
    ip->valid = 1;
    800033e4:	4785                	li	a5,1
    800033e6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800033e8:	04449783          	lh	a5,68(s1)
    800033ec:	f3d1                	bnez	a5,80003370 <ilock+0x20>
      panic("ilock: no type");
    800033ee:	00004517          	auipc	a0,0x4
    800033f2:	19a50513          	addi	a0,a0,410 # 80007588 <syscalls+0x170>
    800033f6:	b92fd0ef          	jal	ra,80000788 <panic>

00000000800033fa <iunlock>:
{
    800033fa:	1101                	addi	sp,sp,-32
    800033fc:	ec06                	sd	ra,24(sp)
    800033fe:	e822                	sd	s0,16(sp)
    80003400:	e426                	sd	s1,8(sp)
    80003402:	e04a                	sd	s2,0(sp)
    80003404:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003406:	c505                	beqz	a0,8000342e <iunlock+0x34>
    80003408:	84aa                	mv	s1,a0
    8000340a:	01050913          	addi	s2,a0,16
    8000340e:	854a                	mv	a0,s2
    80003410:	421000ef          	jal	ra,80004030 <holdingsleep>
    80003414:	cd09                	beqz	a0,8000342e <iunlock+0x34>
    80003416:	449c                	lw	a5,8(s1)
    80003418:	00f05b63          	blez	a5,8000342e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000341c:	854a                	mv	a0,s2
    8000341e:	3db000ef          	jal	ra,80003ff8 <releasesleep>
}
    80003422:	60e2                	ld	ra,24(sp)
    80003424:	6442                	ld	s0,16(sp)
    80003426:	64a2                	ld	s1,8(sp)
    80003428:	6902                	ld	s2,0(sp)
    8000342a:	6105                	addi	sp,sp,32
    8000342c:	8082                	ret
    panic("iunlock");
    8000342e:	00004517          	auipc	a0,0x4
    80003432:	16a50513          	addi	a0,a0,362 # 80007598 <syscalls+0x180>
    80003436:	b52fd0ef          	jal	ra,80000788 <panic>

000000008000343a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000343a:	7179                	addi	sp,sp,-48
    8000343c:	f406                	sd	ra,40(sp)
    8000343e:	f022                	sd	s0,32(sp)
    80003440:	ec26                	sd	s1,24(sp)
    80003442:	e84a                	sd	s2,16(sp)
    80003444:	e44e                	sd	s3,8(sp)
    80003446:	e052                	sd	s4,0(sp)
    80003448:	1800                	addi	s0,sp,48
    8000344a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000344c:	05050493          	addi	s1,a0,80
    80003450:	08050913          	addi	s2,a0,128
    80003454:	a021                	j	8000345c <itrunc+0x22>
    80003456:	0491                	addi	s1,s1,4
    80003458:	01248b63          	beq	s1,s2,8000346e <itrunc+0x34>
    if(ip->addrs[i]){
    8000345c:	408c                	lw	a1,0(s1)
    8000345e:	dde5                	beqz	a1,80003456 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003460:	0009a503          	lw	a0,0(s3)
    80003464:	a37ff0ef          	jal	ra,80002e9a <bfree>
      ip->addrs[i] = 0;
    80003468:	0004a023          	sw	zero,0(s1)
    8000346c:	b7ed                	j	80003456 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000346e:	0809a583          	lw	a1,128(s3)
    80003472:	ed91                	bnez	a1,8000348e <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003474:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003478:	854e                	mv	a0,s3
    8000347a:	e23ff0ef          	jal	ra,8000329c <iupdate>
}
    8000347e:	70a2                	ld	ra,40(sp)
    80003480:	7402                	ld	s0,32(sp)
    80003482:	64e2                	ld	s1,24(sp)
    80003484:	6942                	ld	s2,16(sp)
    80003486:	69a2                	ld	s3,8(sp)
    80003488:	6a02                	ld	s4,0(sp)
    8000348a:	6145                	addi	sp,sp,48
    8000348c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000348e:	0009a503          	lw	a0,0(s3)
    80003492:	80fff0ef          	jal	ra,80002ca0 <bread>
    80003496:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003498:	05850493          	addi	s1,a0,88
    8000349c:	45850913          	addi	s2,a0,1112
    800034a0:	a021                	j	800034a8 <itrunc+0x6e>
    800034a2:	0491                	addi	s1,s1,4
    800034a4:	01248963          	beq	s1,s2,800034b6 <itrunc+0x7c>
      if(a[j])
    800034a8:	408c                	lw	a1,0(s1)
    800034aa:	dde5                	beqz	a1,800034a2 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800034ac:	0009a503          	lw	a0,0(s3)
    800034b0:	9ebff0ef          	jal	ra,80002e9a <bfree>
    800034b4:	b7fd                	j	800034a2 <itrunc+0x68>
    brelse(bp);
    800034b6:	8552                	mv	a0,s4
    800034b8:	8f1ff0ef          	jal	ra,80002da8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034bc:	0809a583          	lw	a1,128(s3)
    800034c0:	0009a503          	lw	a0,0(s3)
    800034c4:	9d7ff0ef          	jal	ra,80002e9a <bfree>
    ip->addrs[NDIRECT] = 0;
    800034c8:	0809a023          	sw	zero,128(s3)
    800034cc:	b765                	j	80003474 <itrunc+0x3a>

00000000800034ce <iput>:
{
    800034ce:	1101                	addi	sp,sp,-32
    800034d0:	ec06                	sd	ra,24(sp)
    800034d2:	e822                	sd	s0,16(sp)
    800034d4:	e426                	sd	s1,8(sp)
    800034d6:	e04a                	sd	s2,0(sp)
    800034d8:	1000                	addi	s0,sp,32
    800034da:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034dc:	0023b517          	auipc	a0,0x23b
    800034e0:	a0c50513          	addi	a0,a0,-1524 # 8023dee8 <itable>
    800034e4:	fbcfd0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034e8:	4498                	lw	a4,8(s1)
    800034ea:	4785                	li	a5,1
    800034ec:	02f70163          	beq	a4,a5,8000350e <iput+0x40>
  ip->ref--;
    800034f0:	449c                	lw	a5,8(s1)
    800034f2:	37fd                	addiw	a5,a5,-1
    800034f4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034f6:	0023b517          	auipc	a0,0x23b
    800034fa:	9f250513          	addi	a0,a0,-1550 # 8023dee8 <itable>
    800034fe:	83bfd0ef          	jal	ra,80000d38 <release>
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6902                	ld	s2,0(sp)
    8000350a:	6105                	addi	sp,sp,32
    8000350c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000350e:	40bc                	lw	a5,64(s1)
    80003510:	d3e5                	beqz	a5,800034f0 <iput+0x22>
    80003512:	04a49783          	lh	a5,74(s1)
    80003516:	ffe9                	bnez	a5,800034f0 <iput+0x22>
    acquiresleep(&ip->lock);
    80003518:	01048913          	addi	s2,s1,16
    8000351c:	854a                	mv	a0,s2
    8000351e:	295000ef          	jal	ra,80003fb2 <acquiresleep>
    release(&itable.lock);
    80003522:	0023b517          	auipc	a0,0x23b
    80003526:	9c650513          	addi	a0,a0,-1594 # 8023dee8 <itable>
    8000352a:	80ffd0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    8000352e:	8526                	mv	a0,s1
    80003530:	f0bff0ef          	jal	ra,8000343a <itrunc>
    ip->type = 0;
    80003534:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003538:	8526                	mv	a0,s1
    8000353a:	d63ff0ef          	jal	ra,8000329c <iupdate>
    ip->valid = 0;
    8000353e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003542:	854a                	mv	a0,s2
    80003544:	2b5000ef          	jal	ra,80003ff8 <releasesleep>
    acquire(&itable.lock);
    80003548:	0023b517          	auipc	a0,0x23b
    8000354c:	9a050513          	addi	a0,a0,-1632 # 8023dee8 <itable>
    80003550:	f50fd0ef          	jal	ra,80000ca0 <acquire>
    80003554:	bf71                	j	800034f0 <iput+0x22>

0000000080003556 <iunlockput>:
{
    80003556:	1101                	addi	sp,sp,-32
    80003558:	ec06                	sd	ra,24(sp)
    8000355a:	e822                	sd	s0,16(sp)
    8000355c:	e426                	sd	s1,8(sp)
    8000355e:	1000                	addi	s0,sp,32
    80003560:	84aa                	mv	s1,a0
  iunlock(ip);
    80003562:	e99ff0ef          	jal	ra,800033fa <iunlock>
  iput(ip);
    80003566:	8526                	mv	a0,s1
    80003568:	f67ff0ef          	jal	ra,800034ce <iput>
}
    8000356c:	60e2                	ld	ra,24(sp)
    8000356e:	6442                	ld	s0,16(sp)
    80003570:	64a2                	ld	s1,8(sp)
    80003572:	6105                	addi	sp,sp,32
    80003574:	8082                	ret

0000000080003576 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003576:	0023b717          	auipc	a4,0x23b
    8000357a:	95e72703          	lw	a4,-1698(a4) # 8023ded4 <sb+0xc>
    8000357e:	4785                	li	a5,1
    80003580:	0ae7ff63          	bgeu	a5,a4,8000363e <ireclaim+0xc8>
{
    80003584:	7139                	addi	sp,sp,-64
    80003586:	fc06                	sd	ra,56(sp)
    80003588:	f822                	sd	s0,48(sp)
    8000358a:	f426                	sd	s1,40(sp)
    8000358c:	f04a                	sd	s2,32(sp)
    8000358e:	ec4e                	sd	s3,24(sp)
    80003590:	e852                	sd	s4,16(sp)
    80003592:	e456                	sd	s5,8(sp)
    80003594:	e05a                	sd	s6,0(sp)
    80003596:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003598:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000359a:	00050a1b          	sext.w	s4,a0
    8000359e:	0023ba97          	auipc	s5,0x23b
    800035a2:	92aa8a93          	addi	s5,s5,-1750 # 8023dec8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035a6:	00004b17          	auipc	s6,0x4
    800035aa:	ffab0b13          	addi	s6,s6,-6 # 800075a0 <syscalls+0x188>
    800035ae:	a099                	j	800035f4 <ireclaim+0x7e>
    800035b0:	85ce                	mv	a1,s3
    800035b2:	855a                	mv	a0,s6
    800035b4:	f0ffc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    800035b8:	85ce                	mv	a1,s3
    800035ba:	8552                	mv	a0,s4
    800035bc:	b27ff0ef          	jal	ra,800030e2 <iget>
    800035c0:	89aa                	mv	s3,a0
    brelse(bp);
    800035c2:	854a                	mv	a0,s2
    800035c4:	fe4ff0ef          	jal	ra,80002da8 <brelse>
    if (ip) {
    800035c8:	00098f63          	beqz	s3,800035e6 <ireclaim+0x70>
      begin_op();
    800035cc:	76c000ef          	jal	ra,80003d38 <begin_op>
      ilock(ip);
    800035d0:	854e                	mv	a0,s3
    800035d2:	d7fff0ef          	jal	ra,80003350 <ilock>
      iunlock(ip);
    800035d6:	854e                	mv	a0,s3
    800035d8:	e23ff0ef          	jal	ra,800033fa <iunlock>
      iput(ip);
    800035dc:	854e                	mv	a0,s3
    800035de:	ef1ff0ef          	jal	ra,800034ce <iput>
      end_op();
    800035e2:	7c4000ef          	jal	ra,80003da6 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035e6:	0485                	addi	s1,s1,1
    800035e8:	00caa703          	lw	a4,12(s5)
    800035ec:	0004879b          	sext.w	a5,s1
    800035f0:	02e7fd63          	bgeu	a5,a4,8000362a <ireclaim+0xb4>
    800035f4:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035f8:	0044d593          	srli	a1,s1,0x4
    800035fc:	018aa783          	lw	a5,24(s5)
    80003600:	9dbd                	addw	a1,a1,a5
    80003602:	8552                	mv	a0,s4
    80003604:	e9cff0ef          	jal	ra,80002ca0 <bread>
    80003608:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000360a:	05850793          	addi	a5,a0,88
    8000360e:	00f9f713          	andi	a4,s3,15
    80003612:	071a                	slli	a4,a4,0x6
    80003614:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003616:	00079703          	lh	a4,0(a5)
    8000361a:	c701                	beqz	a4,80003622 <ireclaim+0xac>
    8000361c:	00679783          	lh	a5,6(a5)
    80003620:	dbc1                	beqz	a5,800035b0 <ireclaim+0x3a>
    brelse(bp);
    80003622:	854a                	mv	a0,s2
    80003624:	f84ff0ef          	jal	ra,80002da8 <brelse>
    if (ip) {
    80003628:	bf7d                	j	800035e6 <ireclaim+0x70>
}
    8000362a:	70e2                	ld	ra,56(sp)
    8000362c:	7442                	ld	s0,48(sp)
    8000362e:	74a2                	ld	s1,40(sp)
    80003630:	7902                	ld	s2,32(sp)
    80003632:	69e2                	ld	s3,24(sp)
    80003634:	6a42                	ld	s4,16(sp)
    80003636:	6aa2                	ld	s5,8(sp)
    80003638:	6b02                	ld	s6,0(sp)
    8000363a:	6121                	addi	sp,sp,64
    8000363c:	8082                	ret
    8000363e:	8082                	ret

0000000080003640 <fsinit>:
fsinit(int dev) {
    80003640:	7179                	addi	sp,sp,-48
    80003642:	f406                	sd	ra,40(sp)
    80003644:	f022                	sd	s0,32(sp)
    80003646:	ec26                	sd	s1,24(sp)
    80003648:	e84a                	sd	s2,16(sp)
    8000364a:	e44e                	sd	s3,8(sp)
    8000364c:	1800                	addi	s0,sp,48
    8000364e:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003650:	4585                	li	a1,1
    80003652:	e4eff0ef          	jal	ra,80002ca0 <bread>
    80003656:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003658:	0023b997          	auipc	s3,0x23b
    8000365c:	87098993          	addi	s3,s3,-1936 # 8023dec8 <sb>
    80003660:	02000613          	li	a2,32
    80003664:	05850593          	addi	a1,a0,88
    80003668:	854e                	mv	a0,s3
    8000366a:	f66fd0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    8000366e:	854a                	mv	a0,s2
    80003670:	f38ff0ef          	jal	ra,80002da8 <brelse>
  if(sb.magic != FSMAGIC)
    80003674:	0009a703          	lw	a4,0(s3)
    80003678:	102037b7          	lui	a5,0x10203
    8000367c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003680:	02f71363          	bne	a4,a5,800036a6 <fsinit+0x66>
  initlog(dev, &sb);
    80003684:	0023b597          	auipc	a1,0x23b
    80003688:	84458593          	addi	a1,a1,-1980 # 8023dec8 <sb>
    8000368c:	8526                	mv	a0,s1
    8000368e:	61e000ef          	jal	ra,80003cac <initlog>
  ireclaim(dev);
    80003692:	8526                	mv	a0,s1
    80003694:	ee3ff0ef          	jal	ra,80003576 <ireclaim>
}
    80003698:	70a2                	ld	ra,40(sp)
    8000369a:	7402                	ld	s0,32(sp)
    8000369c:	64e2                	ld	s1,24(sp)
    8000369e:	6942                	ld	s2,16(sp)
    800036a0:	69a2                	ld	s3,8(sp)
    800036a2:	6145                	addi	sp,sp,48
    800036a4:	8082                	ret
    panic("invalid file system");
    800036a6:	00004517          	auipc	a0,0x4
    800036aa:	f1a50513          	addi	a0,a0,-230 # 800075c0 <syscalls+0x1a8>
    800036ae:	8dafd0ef          	jal	ra,80000788 <panic>

00000000800036b2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036b2:	1141                	addi	sp,sp,-16
    800036b4:	e422                	sd	s0,8(sp)
    800036b6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036b8:	411c                	lw	a5,0(a0)
    800036ba:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036bc:	415c                	lw	a5,4(a0)
    800036be:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036c0:	04451783          	lh	a5,68(a0)
    800036c4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036c8:	04a51783          	lh	a5,74(a0)
    800036cc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036d0:	04c56783          	lwu	a5,76(a0)
    800036d4:	e99c                	sd	a5,16(a1)
}
    800036d6:	6422                	ld	s0,8(sp)
    800036d8:	0141                	addi	sp,sp,16
    800036da:	8082                	ret

00000000800036dc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036dc:	457c                	lw	a5,76(a0)
    800036de:	0cd7ef63          	bltu	a5,a3,800037bc <readi+0xe0>
{
    800036e2:	7159                	addi	sp,sp,-112
    800036e4:	f486                	sd	ra,104(sp)
    800036e6:	f0a2                	sd	s0,96(sp)
    800036e8:	eca6                	sd	s1,88(sp)
    800036ea:	e8ca                	sd	s2,80(sp)
    800036ec:	e4ce                	sd	s3,72(sp)
    800036ee:	e0d2                	sd	s4,64(sp)
    800036f0:	fc56                	sd	s5,56(sp)
    800036f2:	f85a                	sd	s6,48(sp)
    800036f4:	f45e                	sd	s7,40(sp)
    800036f6:	f062                	sd	s8,32(sp)
    800036f8:	ec66                	sd	s9,24(sp)
    800036fa:	e86a                	sd	s10,16(sp)
    800036fc:	e46e                	sd	s11,8(sp)
    800036fe:	1880                	addi	s0,sp,112
    80003700:	8b2a                	mv	s6,a0
    80003702:	8bae                	mv	s7,a1
    80003704:	8a32                	mv	s4,a2
    80003706:	84b6                	mv	s1,a3
    80003708:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000370a:	9f35                	addw	a4,a4,a3
    return 0;
    8000370c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000370e:	08d76663          	bltu	a4,a3,8000379a <readi+0xbe>
  if(off + n > ip->size)
    80003712:	00e7f463          	bgeu	a5,a4,8000371a <readi+0x3e>
    n = ip->size - off;
    80003716:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000371a:	080a8f63          	beqz	s5,800037b8 <readi+0xdc>
    8000371e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003720:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003724:	5c7d                	li	s8,-1
    80003726:	a80d                	j	80003758 <readi+0x7c>
    80003728:	020d1d93          	slli	s11,s10,0x20
    8000372c:	020ddd93          	srli	s11,s11,0x20
    80003730:	05890613          	addi	a2,s2,88
    80003734:	86ee                	mv	a3,s11
    80003736:	963a                	add	a2,a2,a4
    80003738:	85d2                	mv	a1,s4
    8000373a:	855e                	mv	a0,s7
    8000373c:	c5dfe0ef          	jal	ra,80002398 <either_copyout>
    80003740:	05850763          	beq	a0,s8,8000378e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003744:	854a                	mv	a0,s2
    80003746:	e62ff0ef          	jal	ra,80002da8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000374a:	013d09bb          	addw	s3,s10,s3
    8000374e:	009d04bb          	addw	s1,s10,s1
    80003752:	9a6e                	add	s4,s4,s11
    80003754:	0559f163          	bgeu	s3,s5,80003796 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003758:	00a4d59b          	srliw	a1,s1,0xa
    8000375c:	855a                	mv	a0,s6
    8000375e:	8b7ff0ef          	jal	ra,80003014 <bmap>
    80003762:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003766:	c985                	beqz	a1,80003796 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003768:	000b2503          	lw	a0,0(s6)
    8000376c:	d34ff0ef          	jal	ra,80002ca0 <bread>
    80003770:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003772:	3ff4f713          	andi	a4,s1,1023
    80003776:	40ec87bb          	subw	a5,s9,a4
    8000377a:	413a86bb          	subw	a3,s5,s3
    8000377e:	8d3e                	mv	s10,a5
    80003780:	2781                	sext.w	a5,a5
    80003782:	0006861b          	sext.w	a2,a3
    80003786:	faf671e3          	bgeu	a2,a5,80003728 <readi+0x4c>
    8000378a:	8d36                	mv	s10,a3
    8000378c:	bf71                	j	80003728 <readi+0x4c>
      brelse(bp);
    8000378e:	854a                	mv	a0,s2
    80003790:	e18ff0ef          	jal	ra,80002da8 <brelse>
      tot = -1;
    80003794:	59fd                	li	s3,-1
  }
  return tot;
    80003796:	0009851b          	sext.w	a0,s3
}
    8000379a:	70a6                	ld	ra,104(sp)
    8000379c:	7406                	ld	s0,96(sp)
    8000379e:	64e6                	ld	s1,88(sp)
    800037a0:	6946                	ld	s2,80(sp)
    800037a2:	69a6                	ld	s3,72(sp)
    800037a4:	6a06                	ld	s4,64(sp)
    800037a6:	7ae2                	ld	s5,56(sp)
    800037a8:	7b42                	ld	s6,48(sp)
    800037aa:	7ba2                	ld	s7,40(sp)
    800037ac:	7c02                	ld	s8,32(sp)
    800037ae:	6ce2                	ld	s9,24(sp)
    800037b0:	6d42                	ld	s10,16(sp)
    800037b2:	6da2                	ld	s11,8(sp)
    800037b4:	6165                	addi	sp,sp,112
    800037b6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b8:	89d6                	mv	s3,s5
    800037ba:	bff1                	j	80003796 <readi+0xba>
    return 0;
    800037bc:	4501                	li	a0,0
}
    800037be:	8082                	ret

00000000800037c0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037c0:	457c                	lw	a5,76(a0)
    800037c2:	0ed7ea63          	bltu	a5,a3,800038b6 <writei+0xf6>
{
    800037c6:	7159                	addi	sp,sp,-112
    800037c8:	f486                	sd	ra,104(sp)
    800037ca:	f0a2                	sd	s0,96(sp)
    800037cc:	eca6                	sd	s1,88(sp)
    800037ce:	e8ca                	sd	s2,80(sp)
    800037d0:	e4ce                	sd	s3,72(sp)
    800037d2:	e0d2                	sd	s4,64(sp)
    800037d4:	fc56                	sd	s5,56(sp)
    800037d6:	f85a                	sd	s6,48(sp)
    800037d8:	f45e                	sd	s7,40(sp)
    800037da:	f062                	sd	s8,32(sp)
    800037dc:	ec66                	sd	s9,24(sp)
    800037de:	e86a                	sd	s10,16(sp)
    800037e0:	e46e                	sd	s11,8(sp)
    800037e2:	1880                	addi	s0,sp,112
    800037e4:	8aaa                	mv	s5,a0
    800037e6:	8bae                	mv	s7,a1
    800037e8:	8a32                	mv	s4,a2
    800037ea:	8936                	mv	s2,a3
    800037ec:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800037ee:	00e687bb          	addw	a5,a3,a4
    800037f2:	0cd7e463          	bltu	a5,a3,800038ba <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800037f6:	00043737          	lui	a4,0x43
    800037fa:	0cf76263          	bltu	a4,a5,800038be <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037fe:	0a0b0a63          	beqz	s6,800038b2 <writei+0xf2>
    80003802:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003804:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003808:	5c7d                	li	s8,-1
    8000380a:	a825                	j	80003842 <writei+0x82>
    8000380c:	020d1d93          	slli	s11,s10,0x20
    80003810:	020ddd93          	srli	s11,s11,0x20
    80003814:	05848513          	addi	a0,s1,88
    80003818:	86ee                	mv	a3,s11
    8000381a:	8652                	mv	a2,s4
    8000381c:	85de                	mv	a1,s7
    8000381e:	953a                	add	a0,a0,a4
    80003820:	bc3fe0ef          	jal	ra,800023e2 <either_copyin>
    80003824:	05850a63          	beq	a0,s8,80003878 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003828:	8526                	mv	a0,s1
    8000382a:	690000ef          	jal	ra,80003eba <log_write>
    brelse(bp);
    8000382e:	8526                	mv	a0,s1
    80003830:	d78ff0ef          	jal	ra,80002da8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003834:	013d09bb          	addw	s3,s10,s3
    80003838:	012d093b          	addw	s2,s10,s2
    8000383c:	9a6e                	add	s4,s4,s11
    8000383e:	0569f063          	bgeu	s3,s6,8000387e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003842:	00a9559b          	srliw	a1,s2,0xa
    80003846:	8556                	mv	a0,s5
    80003848:	fccff0ef          	jal	ra,80003014 <bmap>
    8000384c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003850:	c59d                	beqz	a1,8000387e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003852:	000aa503          	lw	a0,0(s5)
    80003856:	c4aff0ef          	jal	ra,80002ca0 <bread>
    8000385a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000385c:	3ff97713          	andi	a4,s2,1023
    80003860:	40ec87bb          	subw	a5,s9,a4
    80003864:	413b06bb          	subw	a3,s6,s3
    80003868:	8d3e                	mv	s10,a5
    8000386a:	2781                	sext.w	a5,a5
    8000386c:	0006861b          	sext.w	a2,a3
    80003870:	f8f67ee3          	bgeu	a2,a5,8000380c <writei+0x4c>
    80003874:	8d36                	mv	s10,a3
    80003876:	bf59                	j	8000380c <writei+0x4c>
      brelse(bp);
    80003878:	8526                	mv	a0,s1
    8000387a:	d2eff0ef          	jal	ra,80002da8 <brelse>
  }

  if(off > ip->size)
    8000387e:	04caa783          	lw	a5,76(s5)
    80003882:	0127f463          	bgeu	a5,s2,8000388a <writei+0xca>
    ip->size = off;
    80003886:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000388a:	8556                	mv	a0,s5
    8000388c:	a11ff0ef          	jal	ra,8000329c <iupdate>

  return tot;
    80003890:	0009851b          	sext.w	a0,s3
}
    80003894:	70a6                	ld	ra,104(sp)
    80003896:	7406                	ld	s0,96(sp)
    80003898:	64e6                	ld	s1,88(sp)
    8000389a:	6946                	ld	s2,80(sp)
    8000389c:	69a6                	ld	s3,72(sp)
    8000389e:	6a06                	ld	s4,64(sp)
    800038a0:	7ae2                	ld	s5,56(sp)
    800038a2:	7b42                	ld	s6,48(sp)
    800038a4:	7ba2                	ld	s7,40(sp)
    800038a6:	7c02                	ld	s8,32(sp)
    800038a8:	6ce2                	ld	s9,24(sp)
    800038aa:	6d42                	ld	s10,16(sp)
    800038ac:	6da2                	ld	s11,8(sp)
    800038ae:	6165                	addi	sp,sp,112
    800038b0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038b2:	89da                	mv	s3,s6
    800038b4:	bfd9                	j	8000388a <writei+0xca>
    return -1;
    800038b6:	557d                	li	a0,-1
}
    800038b8:	8082                	ret
    return -1;
    800038ba:	557d                	li	a0,-1
    800038bc:	bfe1                	j	80003894 <writei+0xd4>
    return -1;
    800038be:	557d                	li	a0,-1
    800038c0:	bfd1                	j	80003894 <writei+0xd4>

00000000800038c2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038c2:	1141                	addi	sp,sp,-16
    800038c4:	e406                	sd	ra,8(sp)
    800038c6:	e022                	sd	s0,0(sp)
    800038c8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038ca:	4639                	li	a2,14
    800038cc:	d74fd0ef          	jal	ra,80000e40 <strncmp>
}
    800038d0:	60a2                	ld	ra,8(sp)
    800038d2:	6402                	ld	s0,0(sp)
    800038d4:	0141                	addi	sp,sp,16
    800038d6:	8082                	ret

00000000800038d8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038d8:	7139                	addi	sp,sp,-64
    800038da:	fc06                	sd	ra,56(sp)
    800038dc:	f822                	sd	s0,48(sp)
    800038de:	f426                	sd	s1,40(sp)
    800038e0:	f04a                	sd	s2,32(sp)
    800038e2:	ec4e                	sd	s3,24(sp)
    800038e4:	e852                	sd	s4,16(sp)
    800038e6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800038e8:	04451703          	lh	a4,68(a0)
    800038ec:	4785                	li	a5,1
    800038ee:	00f71a63          	bne	a4,a5,80003902 <dirlookup+0x2a>
    800038f2:	892a                	mv	s2,a0
    800038f4:	89ae                	mv	s3,a1
    800038f6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800038f8:	457c                	lw	a5,76(a0)
    800038fa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038fc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038fe:	e39d                	bnez	a5,80003924 <dirlookup+0x4c>
    80003900:	a095                	j	80003964 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003902:	00004517          	auipc	a0,0x4
    80003906:	cd650513          	addi	a0,a0,-810 # 800075d8 <syscalls+0x1c0>
    8000390a:	e7ffc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    8000390e:	00004517          	auipc	a0,0x4
    80003912:	ce250513          	addi	a0,a0,-798 # 800075f0 <syscalls+0x1d8>
    80003916:	e73fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000391a:	24c1                	addiw	s1,s1,16
    8000391c:	04c92783          	lw	a5,76(s2)
    80003920:	04f4f163          	bgeu	s1,a5,80003962 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003924:	4741                	li	a4,16
    80003926:	86a6                	mv	a3,s1
    80003928:	fc040613          	addi	a2,s0,-64
    8000392c:	4581                	li	a1,0
    8000392e:	854a                	mv	a0,s2
    80003930:	dadff0ef          	jal	ra,800036dc <readi>
    80003934:	47c1                	li	a5,16
    80003936:	fcf51ce3          	bne	a0,a5,8000390e <dirlookup+0x36>
    if(de.inum == 0)
    8000393a:	fc045783          	lhu	a5,-64(s0)
    8000393e:	dff1                	beqz	a5,8000391a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003940:	fc240593          	addi	a1,s0,-62
    80003944:	854e                	mv	a0,s3
    80003946:	f7dff0ef          	jal	ra,800038c2 <namecmp>
    8000394a:	f961                	bnez	a0,8000391a <dirlookup+0x42>
      if(poff)
    8000394c:	000a0463          	beqz	s4,80003954 <dirlookup+0x7c>
        *poff = off;
    80003950:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003954:	fc045583          	lhu	a1,-64(s0)
    80003958:	00092503          	lw	a0,0(s2)
    8000395c:	f86ff0ef          	jal	ra,800030e2 <iget>
    80003960:	a011                	j	80003964 <dirlookup+0x8c>
  return 0;
    80003962:	4501                	li	a0,0
}
    80003964:	70e2                	ld	ra,56(sp)
    80003966:	7442                	ld	s0,48(sp)
    80003968:	74a2                	ld	s1,40(sp)
    8000396a:	7902                	ld	s2,32(sp)
    8000396c:	69e2                	ld	s3,24(sp)
    8000396e:	6a42                	ld	s4,16(sp)
    80003970:	6121                	addi	sp,sp,64
    80003972:	8082                	ret

0000000080003974 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003974:	711d                	addi	sp,sp,-96
    80003976:	ec86                	sd	ra,88(sp)
    80003978:	e8a2                	sd	s0,80(sp)
    8000397a:	e4a6                	sd	s1,72(sp)
    8000397c:	e0ca                	sd	s2,64(sp)
    8000397e:	fc4e                	sd	s3,56(sp)
    80003980:	f852                	sd	s4,48(sp)
    80003982:	f456                	sd	s5,40(sp)
    80003984:	f05a                	sd	s6,32(sp)
    80003986:	ec5e                	sd	s7,24(sp)
    80003988:	e862                	sd	s8,16(sp)
    8000398a:	e466                	sd	s9,8(sp)
    8000398c:	e06a                	sd	s10,0(sp)
    8000398e:	1080                	addi	s0,sp,96
    80003990:	84aa                	mv	s1,a0
    80003992:	8b2e                	mv	s6,a1
    80003994:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003996:	00054703          	lbu	a4,0(a0)
    8000399a:	02f00793          	li	a5,47
    8000399e:	00f70f63          	beq	a4,a5,800039bc <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039a2:	892fe0ef          	jal	ra,80001a34 <myproc>
    800039a6:	15053503          	ld	a0,336(a0)
    800039aa:	971ff0ef          	jal	ra,8000331a <idup>
    800039ae:	8a2a                	mv	s4,a0
  while(*path == '/')
    800039b0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800039b4:	4cb5                	li	s9,13
  len = path - s;
    800039b6:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800039b8:	4c05                	li	s8,1
    800039ba:	a879                	j	80003a58 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    800039bc:	4585                	li	a1,1
    800039be:	4505                	li	a0,1
    800039c0:	f22ff0ef          	jal	ra,800030e2 <iget>
    800039c4:	8a2a                	mv	s4,a0
    800039c6:	b7ed                	j	800039b0 <namex+0x3c>
      iunlockput(ip);
    800039c8:	8552                	mv	a0,s4
    800039ca:	b8dff0ef          	jal	ra,80003556 <iunlockput>
      return 0;
    800039ce:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039d0:	8552                	mv	a0,s4
    800039d2:	60e6                	ld	ra,88(sp)
    800039d4:	6446                	ld	s0,80(sp)
    800039d6:	64a6                	ld	s1,72(sp)
    800039d8:	6906                	ld	s2,64(sp)
    800039da:	79e2                	ld	s3,56(sp)
    800039dc:	7a42                	ld	s4,48(sp)
    800039de:	7aa2                	ld	s5,40(sp)
    800039e0:	7b02                	ld	s6,32(sp)
    800039e2:	6be2                	ld	s7,24(sp)
    800039e4:	6c42                	ld	s8,16(sp)
    800039e6:	6ca2                	ld	s9,8(sp)
    800039e8:	6d02                	ld	s10,0(sp)
    800039ea:	6125                	addi	sp,sp,96
    800039ec:	8082                	ret
      iunlock(ip);
    800039ee:	8552                	mv	a0,s4
    800039f0:	a0bff0ef          	jal	ra,800033fa <iunlock>
      return ip;
    800039f4:	bff1                	j	800039d0 <namex+0x5c>
      iunlockput(ip);
    800039f6:	8552                	mv	a0,s4
    800039f8:	b5fff0ef          	jal	ra,80003556 <iunlockput>
      return 0;
    800039fc:	8a4e                	mv	s4,s3
    800039fe:	bfc9                	j	800039d0 <namex+0x5c>
  len = path - s;
    80003a00:	40998633          	sub	a2,s3,s1
    80003a04:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003a08:	09acd063          	bge	s9,s10,80003a88 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003a0c:	4639                	li	a2,14
    80003a0e:	85a6                	mv	a1,s1
    80003a10:	8556                	mv	a0,s5
    80003a12:	bbefd0ef          	jal	ra,80000dd0 <memmove>
    80003a16:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a18:	0004c783          	lbu	a5,0(s1)
    80003a1c:	01279763          	bne	a5,s2,80003a2a <namex+0xb6>
    path++;
    80003a20:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a22:	0004c783          	lbu	a5,0(s1)
    80003a26:	ff278de3          	beq	a5,s2,80003a20 <namex+0xac>
    ilock(ip);
    80003a2a:	8552                	mv	a0,s4
    80003a2c:	925ff0ef          	jal	ra,80003350 <ilock>
    if(ip->type != T_DIR){
    80003a30:	044a1783          	lh	a5,68(s4)
    80003a34:	f9879ae3          	bne	a5,s8,800039c8 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003a38:	000b0563          	beqz	s6,80003a42 <namex+0xce>
    80003a3c:	0004c783          	lbu	a5,0(s1)
    80003a40:	d7dd                	beqz	a5,800039ee <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a42:	865e                	mv	a2,s7
    80003a44:	85d6                	mv	a1,s5
    80003a46:	8552                	mv	a0,s4
    80003a48:	e91ff0ef          	jal	ra,800038d8 <dirlookup>
    80003a4c:	89aa                	mv	s3,a0
    80003a4e:	d545                	beqz	a0,800039f6 <namex+0x82>
    iunlockput(ip);
    80003a50:	8552                	mv	a0,s4
    80003a52:	b05ff0ef          	jal	ra,80003556 <iunlockput>
    ip = next;
    80003a56:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003a58:	0004c783          	lbu	a5,0(s1)
    80003a5c:	01279763          	bne	a5,s2,80003a6a <namex+0xf6>
    path++;
    80003a60:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a62:	0004c783          	lbu	a5,0(s1)
    80003a66:	ff278de3          	beq	a5,s2,80003a60 <namex+0xec>
  if(*path == 0)
    80003a6a:	cb8d                	beqz	a5,80003a9c <namex+0x128>
  while(*path != '/' && *path != 0)
    80003a6c:	0004c783          	lbu	a5,0(s1)
    80003a70:	89a6                	mv	s3,s1
  len = path - s;
    80003a72:	8d5e                	mv	s10,s7
    80003a74:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003a76:	01278963          	beq	a5,s2,80003a88 <namex+0x114>
    80003a7a:	d3d9                	beqz	a5,80003a00 <namex+0x8c>
    path++;
    80003a7c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003a7e:	0009c783          	lbu	a5,0(s3)
    80003a82:	ff279ce3          	bne	a5,s2,80003a7a <namex+0x106>
    80003a86:	bfad                	j	80003a00 <namex+0x8c>
    memmove(name, s, len);
    80003a88:	2601                	sext.w	a2,a2
    80003a8a:	85a6                	mv	a1,s1
    80003a8c:	8556                	mv	a0,s5
    80003a8e:	b42fd0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    80003a92:	9d56                	add	s10,s10,s5
    80003a94:	000d0023          	sb	zero,0(s10)
    80003a98:	84ce                	mv	s1,s3
    80003a9a:	bfbd                	j	80003a18 <namex+0xa4>
  if(nameiparent){
    80003a9c:	f20b0ae3          	beqz	s6,800039d0 <namex+0x5c>
    iput(ip);
    80003aa0:	8552                	mv	a0,s4
    80003aa2:	a2dff0ef          	jal	ra,800034ce <iput>
    return 0;
    80003aa6:	4a01                	li	s4,0
    80003aa8:	b725                	j	800039d0 <namex+0x5c>

0000000080003aaa <dirlink>:
{
    80003aaa:	7139                	addi	sp,sp,-64
    80003aac:	fc06                	sd	ra,56(sp)
    80003aae:	f822                	sd	s0,48(sp)
    80003ab0:	f426                	sd	s1,40(sp)
    80003ab2:	f04a                	sd	s2,32(sp)
    80003ab4:	ec4e                	sd	s3,24(sp)
    80003ab6:	e852                	sd	s4,16(sp)
    80003ab8:	0080                	addi	s0,sp,64
    80003aba:	892a                	mv	s2,a0
    80003abc:	8a2e                	mv	s4,a1
    80003abe:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ac0:	4601                	li	a2,0
    80003ac2:	e17ff0ef          	jal	ra,800038d8 <dirlookup>
    80003ac6:	e52d                	bnez	a0,80003b30 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ac8:	04c92483          	lw	s1,76(s2)
    80003acc:	c48d                	beqz	s1,80003af6 <dirlink+0x4c>
    80003ace:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ad0:	4741                	li	a4,16
    80003ad2:	86a6                	mv	a3,s1
    80003ad4:	fc040613          	addi	a2,s0,-64
    80003ad8:	4581                	li	a1,0
    80003ada:	854a                	mv	a0,s2
    80003adc:	c01ff0ef          	jal	ra,800036dc <readi>
    80003ae0:	47c1                	li	a5,16
    80003ae2:	04f51b63          	bne	a0,a5,80003b38 <dirlink+0x8e>
    if(de.inum == 0)
    80003ae6:	fc045783          	lhu	a5,-64(s0)
    80003aea:	c791                	beqz	a5,80003af6 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aec:	24c1                	addiw	s1,s1,16
    80003aee:	04c92783          	lw	a5,76(s2)
    80003af2:	fcf4efe3          	bltu	s1,a5,80003ad0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003af6:	4639                	li	a2,14
    80003af8:	85d2                	mv	a1,s4
    80003afa:	fc240513          	addi	a0,s0,-62
    80003afe:	b7efd0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80003b02:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b06:	4741                	li	a4,16
    80003b08:	86a6                	mv	a3,s1
    80003b0a:	fc040613          	addi	a2,s0,-64
    80003b0e:	4581                	li	a1,0
    80003b10:	854a                	mv	a0,s2
    80003b12:	cafff0ef          	jal	ra,800037c0 <writei>
    80003b16:	1541                	addi	a0,a0,-16
    80003b18:	00a03533          	snez	a0,a0
    80003b1c:	40a00533          	neg	a0,a0
}
    80003b20:	70e2                	ld	ra,56(sp)
    80003b22:	7442                	ld	s0,48(sp)
    80003b24:	74a2                	ld	s1,40(sp)
    80003b26:	7902                	ld	s2,32(sp)
    80003b28:	69e2                	ld	s3,24(sp)
    80003b2a:	6a42                	ld	s4,16(sp)
    80003b2c:	6121                	addi	sp,sp,64
    80003b2e:	8082                	ret
    iput(ip);
    80003b30:	99fff0ef          	jal	ra,800034ce <iput>
    return -1;
    80003b34:	557d                	li	a0,-1
    80003b36:	b7ed                	j	80003b20 <dirlink+0x76>
      panic("dirlink read");
    80003b38:	00004517          	auipc	a0,0x4
    80003b3c:	ac850513          	addi	a0,a0,-1336 # 80007600 <syscalls+0x1e8>
    80003b40:	c49fc0ef          	jal	ra,80000788 <panic>

0000000080003b44 <namei>:

struct inode*
namei(char *path)
{
    80003b44:	1101                	addi	sp,sp,-32
    80003b46:	ec06                	sd	ra,24(sp)
    80003b48:	e822                	sd	s0,16(sp)
    80003b4a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b4c:	fe040613          	addi	a2,s0,-32
    80003b50:	4581                	li	a1,0
    80003b52:	e23ff0ef          	jal	ra,80003974 <namex>
}
    80003b56:	60e2                	ld	ra,24(sp)
    80003b58:	6442                	ld	s0,16(sp)
    80003b5a:	6105                	addi	sp,sp,32
    80003b5c:	8082                	ret

0000000080003b5e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b5e:	1141                	addi	sp,sp,-16
    80003b60:	e406                	sd	ra,8(sp)
    80003b62:	e022                	sd	s0,0(sp)
    80003b64:	0800                	addi	s0,sp,16
    80003b66:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b68:	4585                	li	a1,1
    80003b6a:	e0bff0ef          	jal	ra,80003974 <namex>
}
    80003b6e:	60a2                	ld	ra,8(sp)
    80003b70:	6402                	ld	s0,0(sp)
    80003b72:	0141                	addi	sp,sp,16
    80003b74:	8082                	ret

0000000080003b76 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b76:	1101                	addi	sp,sp,-32
    80003b78:	ec06                	sd	ra,24(sp)
    80003b7a:	e822                	sd	s0,16(sp)
    80003b7c:	e426                	sd	s1,8(sp)
    80003b7e:	e04a                	sd	s2,0(sp)
    80003b80:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b82:	0023c917          	auipc	s2,0x23c
    80003b86:	e0e90913          	addi	s2,s2,-498 # 8023f990 <log>
    80003b8a:	01892583          	lw	a1,24(s2)
    80003b8e:	02492503          	lw	a0,36(s2)
    80003b92:	90eff0ef          	jal	ra,80002ca0 <bread>
    80003b96:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b98:	02892683          	lw	a3,40(s2)
    80003b9c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b9e:	02d05863          	blez	a3,80003bce <write_head+0x58>
    80003ba2:	0023c797          	auipc	a5,0x23c
    80003ba6:	e1a78793          	addi	a5,a5,-486 # 8023f9bc <log+0x2c>
    80003baa:	05c50713          	addi	a4,a0,92
    80003bae:	36fd                	addiw	a3,a3,-1
    80003bb0:	02069613          	slli	a2,a3,0x20
    80003bb4:	01e65693          	srli	a3,a2,0x1e
    80003bb8:	0023c617          	auipc	a2,0x23c
    80003bbc:	e0860613          	addi	a2,a2,-504 # 8023f9c0 <log+0x30>
    80003bc0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003bc2:	4390                	lw	a2,0(a5)
    80003bc4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bc6:	0791                	addi	a5,a5,4
    80003bc8:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003bca:	fed79ce3          	bne	a5,a3,80003bc2 <write_head+0x4c>
  }
  bwrite(buf);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	9a6ff0ef          	jal	ra,80002d76 <bwrite>
  brelse(buf);
    80003bd4:	8526                	mv	a0,s1
    80003bd6:	9d2ff0ef          	jal	ra,80002da8 <brelse>
}
    80003bda:	60e2                	ld	ra,24(sp)
    80003bdc:	6442                	ld	s0,16(sp)
    80003bde:	64a2                	ld	s1,8(sp)
    80003be0:	6902                	ld	s2,0(sp)
    80003be2:	6105                	addi	sp,sp,32
    80003be4:	8082                	ret

0000000080003be6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003be6:	0023c797          	auipc	a5,0x23c
    80003bea:	dd27a783          	lw	a5,-558(a5) # 8023f9b8 <log+0x28>
    80003bee:	0af05e63          	blez	a5,80003caa <install_trans+0xc4>
{
    80003bf2:	715d                	addi	sp,sp,-80
    80003bf4:	e486                	sd	ra,72(sp)
    80003bf6:	e0a2                	sd	s0,64(sp)
    80003bf8:	fc26                	sd	s1,56(sp)
    80003bfa:	f84a                	sd	s2,48(sp)
    80003bfc:	f44e                	sd	s3,40(sp)
    80003bfe:	f052                	sd	s4,32(sp)
    80003c00:	ec56                	sd	s5,24(sp)
    80003c02:	e85a                	sd	s6,16(sp)
    80003c04:	e45e                	sd	s7,8(sp)
    80003c06:	0880                	addi	s0,sp,80
    80003c08:	8b2a                	mv	s6,a0
    80003c0a:	0023ca97          	auipc	s5,0x23c
    80003c0e:	db2a8a93          	addi	s5,s5,-590 # 8023f9bc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c12:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c14:	00004b97          	auipc	s7,0x4
    80003c18:	9fcb8b93          	addi	s7,s7,-1540 # 80007610 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c1c:	0023ca17          	auipc	s4,0x23c
    80003c20:	d74a0a13          	addi	s4,s4,-652 # 8023f990 <log>
    80003c24:	a025                	j	80003c4c <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c26:	000aa603          	lw	a2,0(s5)
    80003c2a:	85ce                	mv	a1,s3
    80003c2c:	855e                	mv	a0,s7
    80003c2e:	895fc0ef          	jal	ra,800004c2 <printf>
    80003c32:	a839                	j	80003c50 <install_trans+0x6a>
    brelse(lbuf);
    80003c34:	854a                	mv	a0,s2
    80003c36:	972ff0ef          	jal	ra,80002da8 <brelse>
    brelse(dbuf);
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	96cff0ef          	jal	ra,80002da8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c40:	2985                	addiw	s3,s3,1
    80003c42:	0a91                	addi	s5,s5,4
    80003c44:	028a2783          	lw	a5,40(s4)
    80003c48:	04f9d663          	bge	s3,a5,80003c94 <install_trans+0xae>
    if(recovering) {
    80003c4c:	fc0b1de3          	bnez	s6,80003c26 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c50:	018a2583          	lw	a1,24(s4)
    80003c54:	013585bb          	addw	a1,a1,s3
    80003c58:	2585                	addiw	a1,a1,1
    80003c5a:	024a2503          	lw	a0,36(s4)
    80003c5e:	842ff0ef          	jal	ra,80002ca0 <bread>
    80003c62:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c64:	000aa583          	lw	a1,0(s5)
    80003c68:	024a2503          	lw	a0,36(s4)
    80003c6c:	834ff0ef          	jal	ra,80002ca0 <bread>
    80003c70:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c72:	40000613          	li	a2,1024
    80003c76:	05890593          	addi	a1,s2,88
    80003c7a:	05850513          	addi	a0,a0,88
    80003c7e:	952fd0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c82:	8526                	mv	a0,s1
    80003c84:	8f2ff0ef          	jal	ra,80002d76 <bwrite>
    if(recovering == 0)
    80003c88:	fa0b16e3          	bnez	s6,80003c34 <install_trans+0x4e>
      bunpin(dbuf);
    80003c8c:	8526                	mv	a0,s1
    80003c8e:	9d8ff0ef          	jal	ra,80002e66 <bunpin>
    80003c92:	b74d                	j	80003c34 <install_trans+0x4e>
}
    80003c94:	60a6                	ld	ra,72(sp)
    80003c96:	6406                	ld	s0,64(sp)
    80003c98:	74e2                	ld	s1,56(sp)
    80003c9a:	7942                	ld	s2,48(sp)
    80003c9c:	79a2                	ld	s3,40(sp)
    80003c9e:	7a02                	ld	s4,32(sp)
    80003ca0:	6ae2                	ld	s5,24(sp)
    80003ca2:	6b42                	ld	s6,16(sp)
    80003ca4:	6ba2                	ld	s7,8(sp)
    80003ca6:	6161                	addi	sp,sp,80
    80003ca8:	8082                	ret
    80003caa:	8082                	ret

0000000080003cac <initlog>:
{
    80003cac:	7179                	addi	sp,sp,-48
    80003cae:	f406                	sd	ra,40(sp)
    80003cb0:	f022                	sd	s0,32(sp)
    80003cb2:	ec26                	sd	s1,24(sp)
    80003cb4:	e84a                	sd	s2,16(sp)
    80003cb6:	e44e                	sd	s3,8(sp)
    80003cb8:	1800                	addi	s0,sp,48
    80003cba:	892a                	mv	s2,a0
    80003cbc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003cbe:	0023c497          	auipc	s1,0x23c
    80003cc2:	cd248493          	addi	s1,s1,-814 # 8023f990 <log>
    80003cc6:	00004597          	auipc	a1,0x4
    80003cca:	96a58593          	addi	a1,a1,-1686 # 80007630 <syscalls+0x218>
    80003cce:	8526                	mv	a0,s1
    80003cd0:	f51fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80003cd4:	0149a583          	lw	a1,20(s3)
    80003cd8:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003cda:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003cde:	854a                	mv	a0,s2
    80003ce0:	fc1fe0ef          	jal	ra,80002ca0 <bread>
  log.lh.n = lh->n;
    80003ce4:	4d34                	lw	a3,88(a0)
    80003ce6:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ce8:	02d05663          	blez	a3,80003d14 <initlog+0x68>
    80003cec:	05c50793          	addi	a5,a0,92
    80003cf0:	0023c717          	auipc	a4,0x23c
    80003cf4:	ccc70713          	addi	a4,a4,-820 # 8023f9bc <log+0x2c>
    80003cf8:	36fd                	addiw	a3,a3,-1
    80003cfa:	02069613          	slli	a2,a3,0x20
    80003cfe:	01e65693          	srli	a3,a2,0x1e
    80003d02:	06050613          	addi	a2,a0,96
    80003d06:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003d08:	4390                	lw	a2,0(a5)
    80003d0a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d0c:	0791                	addi	a5,a5,4
    80003d0e:	0711                	addi	a4,a4,4
    80003d10:	fed79ce3          	bne	a5,a3,80003d08 <initlog+0x5c>
  brelse(buf);
    80003d14:	894ff0ef          	jal	ra,80002da8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d18:	4505                	li	a0,1
    80003d1a:	ecdff0ef          	jal	ra,80003be6 <install_trans>
  log.lh.n = 0;
    80003d1e:	0023c797          	auipc	a5,0x23c
    80003d22:	c807ad23          	sw	zero,-870(a5) # 8023f9b8 <log+0x28>
  write_head(); // clear the log
    80003d26:	e51ff0ef          	jal	ra,80003b76 <write_head>
}
    80003d2a:	70a2                	ld	ra,40(sp)
    80003d2c:	7402                	ld	s0,32(sp)
    80003d2e:	64e2                	ld	s1,24(sp)
    80003d30:	6942                	ld	s2,16(sp)
    80003d32:	69a2                	ld	s3,8(sp)
    80003d34:	6145                	addi	sp,sp,48
    80003d36:	8082                	ret

0000000080003d38 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d38:	1101                	addi	sp,sp,-32
    80003d3a:	ec06                	sd	ra,24(sp)
    80003d3c:	e822                	sd	s0,16(sp)
    80003d3e:	e426                	sd	s1,8(sp)
    80003d40:	e04a                	sd	s2,0(sp)
    80003d42:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d44:	0023c517          	auipc	a0,0x23c
    80003d48:	c4c50513          	addi	a0,a0,-948 # 8023f990 <log>
    80003d4c:	f55fc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    80003d50:	0023c497          	auipc	s1,0x23c
    80003d54:	c4048493          	addi	s1,s1,-960 # 8023f990 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d58:	4979                	li	s2,30
    80003d5a:	a029                	j	80003d64 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d5c:	85a6                	mv	a1,s1
    80003d5e:	8526                	mv	a0,s1
    80003d60:	adcfe0ef          	jal	ra,8000203c <sleep>
    if(log.committing){
    80003d64:	509c                	lw	a5,32(s1)
    80003d66:	fbfd                	bnez	a5,80003d5c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d68:	4cd8                	lw	a4,28(s1)
    80003d6a:	2705                	addiw	a4,a4,1
    80003d6c:	0007069b          	sext.w	a3,a4
    80003d70:	0027179b          	slliw	a5,a4,0x2
    80003d74:	9fb9                	addw	a5,a5,a4
    80003d76:	0017979b          	slliw	a5,a5,0x1
    80003d7a:	5498                	lw	a4,40(s1)
    80003d7c:	9fb9                	addw	a5,a5,a4
    80003d7e:	00f95763          	bge	s2,a5,80003d8c <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d82:	85a6                	mv	a1,s1
    80003d84:	8526                	mv	a0,s1
    80003d86:	ab6fe0ef          	jal	ra,8000203c <sleep>
    80003d8a:	bfe9                	j	80003d64 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d8c:	0023c517          	auipc	a0,0x23c
    80003d90:	c0450513          	addi	a0,a0,-1020 # 8023f990 <log>
    80003d94:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003d96:	fa3fc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    80003d9a:	60e2                	ld	ra,24(sp)
    80003d9c:	6442                	ld	s0,16(sp)
    80003d9e:	64a2                	ld	s1,8(sp)
    80003da0:	6902                	ld	s2,0(sp)
    80003da2:	6105                	addi	sp,sp,32
    80003da4:	8082                	ret

0000000080003da6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003da6:	7139                	addi	sp,sp,-64
    80003da8:	fc06                	sd	ra,56(sp)
    80003daa:	f822                	sd	s0,48(sp)
    80003dac:	f426                	sd	s1,40(sp)
    80003dae:	f04a                	sd	s2,32(sp)
    80003db0:	ec4e                	sd	s3,24(sp)
    80003db2:	e852                	sd	s4,16(sp)
    80003db4:	e456                	sd	s5,8(sp)
    80003db6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003db8:	0023c497          	auipc	s1,0x23c
    80003dbc:	bd848493          	addi	s1,s1,-1064 # 8023f990 <log>
    80003dc0:	8526                	mv	a0,s1
    80003dc2:	edffc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    80003dc6:	4cdc                	lw	a5,28(s1)
    80003dc8:	37fd                	addiw	a5,a5,-1
    80003dca:	0007891b          	sext.w	s2,a5
    80003dce:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003dd0:	509c                	lw	a5,32(s1)
    80003dd2:	ef9d                	bnez	a5,80003e10 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003dd4:	04091463          	bnez	s2,80003e1c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003dd8:	0023c497          	auipc	s1,0x23c
    80003ddc:	bb848493          	addi	s1,s1,-1096 # 8023f990 <log>
    80003de0:	4785                	li	a5,1
    80003de2:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003de4:	8526                	mv	a0,s1
    80003de6:	f53fc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003dea:	549c                	lw	a5,40(s1)
    80003dec:	04f04b63          	bgtz	a5,80003e42 <end_op+0x9c>
    acquire(&log.lock);
    80003df0:	0023c497          	auipc	s1,0x23c
    80003df4:	ba048493          	addi	s1,s1,-1120 # 8023f990 <log>
    80003df8:	8526                	mv	a0,s1
    80003dfa:	ea7fc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    80003dfe:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e02:	8526                	mv	a0,s1
    80003e04:	a84fe0ef          	jal	ra,80002088 <wakeup>
    release(&log.lock);
    80003e08:	8526                	mv	a0,s1
    80003e0a:	f2ffc0ef          	jal	ra,80000d38 <release>
}
    80003e0e:	a00d                	j	80003e30 <end_op+0x8a>
    panic("log.committing");
    80003e10:	00004517          	auipc	a0,0x4
    80003e14:	82850513          	addi	a0,a0,-2008 # 80007638 <syscalls+0x220>
    80003e18:	971fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    80003e1c:	0023c497          	auipc	s1,0x23c
    80003e20:	b7448493          	addi	s1,s1,-1164 # 8023f990 <log>
    80003e24:	8526                	mv	a0,s1
    80003e26:	a62fe0ef          	jal	ra,80002088 <wakeup>
  release(&log.lock);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	f0dfc0ef          	jal	ra,80000d38 <release>
}
    80003e30:	70e2                	ld	ra,56(sp)
    80003e32:	7442                	ld	s0,48(sp)
    80003e34:	74a2                	ld	s1,40(sp)
    80003e36:	7902                	ld	s2,32(sp)
    80003e38:	69e2                	ld	s3,24(sp)
    80003e3a:	6a42                	ld	s4,16(sp)
    80003e3c:	6aa2                	ld	s5,8(sp)
    80003e3e:	6121                	addi	sp,sp,64
    80003e40:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e42:	0023ca97          	auipc	s5,0x23c
    80003e46:	b7aa8a93          	addi	s5,s5,-1158 # 8023f9bc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e4a:	0023ca17          	auipc	s4,0x23c
    80003e4e:	b46a0a13          	addi	s4,s4,-1210 # 8023f990 <log>
    80003e52:	018a2583          	lw	a1,24(s4)
    80003e56:	012585bb          	addw	a1,a1,s2
    80003e5a:	2585                	addiw	a1,a1,1
    80003e5c:	024a2503          	lw	a0,36(s4)
    80003e60:	e41fe0ef          	jal	ra,80002ca0 <bread>
    80003e64:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e66:	000aa583          	lw	a1,0(s5)
    80003e6a:	024a2503          	lw	a0,36(s4)
    80003e6e:	e33fe0ef          	jal	ra,80002ca0 <bread>
    80003e72:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e74:	40000613          	li	a2,1024
    80003e78:	05850593          	addi	a1,a0,88
    80003e7c:	05848513          	addi	a0,s1,88
    80003e80:	f51fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    80003e84:	8526                	mv	a0,s1
    80003e86:	ef1fe0ef          	jal	ra,80002d76 <bwrite>
    brelse(from);
    80003e8a:	854e                	mv	a0,s3
    80003e8c:	f1dfe0ef          	jal	ra,80002da8 <brelse>
    brelse(to);
    80003e90:	8526                	mv	a0,s1
    80003e92:	f17fe0ef          	jal	ra,80002da8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e96:	2905                	addiw	s2,s2,1
    80003e98:	0a91                	addi	s5,s5,4
    80003e9a:	028a2783          	lw	a5,40(s4)
    80003e9e:	faf94ae3          	blt	s2,a5,80003e52 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ea2:	cd5ff0ef          	jal	ra,80003b76 <write_head>
    install_trans(0); // Now install writes to home locations
    80003ea6:	4501                	li	a0,0
    80003ea8:	d3fff0ef          	jal	ra,80003be6 <install_trans>
    log.lh.n = 0;
    80003eac:	0023c797          	auipc	a5,0x23c
    80003eb0:	b007a623          	sw	zero,-1268(a5) # 8023f9b8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003eb4:	cc3ff0ef          	jal	ra,80003b76 <write_head>
    80003eb8:	bf25                	j	80003df0 <end_op+0x4a>

0000000080003eba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003eba:	1101                	addi	sp,sp,-32
    80003ebc:	ec06                	sd	ra,24(sp)
    80003ebe:	e822                	sd	s0,16(sp)
    80003ec0:	e426                	sd	s1,8(sp)
    80003ec2:	e04a                	sd	s2,0(sp)
    80003ec4:	1000                	addi	s0,sp,32
    80003ec6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003ec8:	0023c917          	auipc	s2,0x23c
    80003ecc:	ac890913          	addi	s2,s2,-1336 # 8023f990 <log>
    80003ed0:	854a                	mv	a0,s2
    80003ed2:	dcffc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003ed6:	02892603          	lw	a2,40(s2)
    80003eda:	47f5                	li	a5,29
    80003edc:	04c7cc63          	blt	a5,a2,80003f34 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ee0:	0023c797          	auipc	a5,0x23c
    80003ee4:	acc7a783          	lw	a5,-1332(a5) # 8023f9ac <log+0x1c>
    80003ee8:	04f05c63          	blez	a5,80003f40 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003eec:	4781                	li	a5,0
    80003eee:	04c05f63          	blez	a2,80003f4c <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ef2:	44cc                	lw	a1,12(s1)
    80003ef4:	0023c717          	auipc	a4,0x23c
    80003ef8:	ac870713          	addi	a4,a4,-1336 # 8023f9bc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003efc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003efe:	4314                	lw	a3,0(a4)
    80003f00:	04b68663          	beq	a3,a1,80003f4c <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f04:	2785                	addiw	a5,a5,1
    80003f06:	0711                	addi	a4,a4,4
    80003f08:	fef61be3          	bne	a2,a5,80003efe <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f0c:	0621                	addi	a2,a2,8
    80003f0e:	060a                	slli	a2,a2,0x2
    80003f10:	0023c797          	auipc	a5,0x23c
    80003f14:	a8078793          	addi	a5,a5,-1408 # 8023f990 <log>
    80003f18:	97b2                	add	a5,a5,a2
    80003f1a:	44d8                	lw	a4,12(s1)
    80003f1c:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	f13fe0ef          	jal	ra,80002e32 <bpin>
    log.lh.n++;
    80003f24:	0023c717          	auipc	a4,0x23c
    80003f28:	a6c70713          	addi	a4,a4,-1428 # 8023f990 <log>
    80003f2c:	571c                	lw	a5,40(a4)
    80003f2e:	2785                	addiw	a5,a5,1
    80003f30:	d71c                	sw	a5,40(a4)
    80003f32:	a80d                	j	80003f64 <log_write+0xaa>
    panic("too big a transaction");
    80003f34:	00003517          	auipc	a0,0x3
    80003f38:	71450513          	addi	a0,a0,1812 # 80007648 <syscalls+0x230>
    80003f3c:	84dfc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    80003f40:	00003517          	auipc	a0,0x3
    80003f44:	72050513          	addi	a0,a0,1824 # 80007660 <syscalls+0x248>
    80003f48:	841fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    80003f4c:	00878693          	addi	a3,a5,8
    80003f50:	068a                	slli	a3,a3,0x2
    80003f52:	0023c717          	auipc	a4,0x23c
    80003f56:	a3e70713          	addi	a4,a4,-1474 # 8023f990 <log>
    80003f5a:	9736                	add	a4,a4,a3
    80003f5c:	44d4                	lw	a3,12(s1)
    80003f5e:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f60:	faf60fe3          	beq	a2,a5,80003f1e <log_write+0x64>
  }
  release(&log.lock);
    80003f64:	0023c517          	auipc	a0,0x23c
    80003f68:	a2c50513          	addi	a0,a0,-1492 # 8023f990 <log>
    80003f6c:	dcdfc0ef          	jal	ra,80000d38 <release>
}
    80003f70:	60e2                	ld	ra,24(sp)
    80003f72:	6442                	ld	s0,16(sp)
    80003f74:	64a2                	ld	s1,8(sp)
    80003f76:	6902                	ld	s2,0(sp)
    80003f78:	6105                	addi	sp,sp,32
    80003f7a:	8082                	ret

0000000080003f7c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f7c:	1101                	addi	sp,sp,-32
    80003f7e:	ec06                	sd	ra,24(sp)
    80003f80:	e822                	sd	s0,16(sp)
    80003f82:	e426                	sd	s1,8(sp)
    80003f84:	e04a                	sd	s2,0(sp)
    80003f86:	1000                	addi	s0,sp,32
    80003f88:	84aa                	mv	s1,a0
    80003f8a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f8c:	00003597          	auipc	a1,0x3
    80003f90:	6f458593          	addi	a1,a1,1780 # 80007680 <syscalls+0x268>
    80003f94:	0521                	addi	a0,a0,8
    80003f96:	c8bfc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    80003f9a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f9e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fa2:	0204a423          	sw	zero,40(s1)
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	64a2                	ld	s1,8(sp)
    80003fac:	6902                	ld	s2,0(sp)
    80003fae:	6105                	addi	sp,sp,32
    80003fb0:	8082                	ret

0000000080003fb2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fb2:	1101                	addi	sp,sp,-32
    80003fb4:	ec06                	sd	ra,24(sp)
    80003fb6:	e822                	sd	s0,16(sp)
    80003fb8:	e426                	sd	s1,8(sp)
    80003fba:	e04a                	sd	s2,0(sp)
    80003fbc:	1000                	addi	s0,sp,32
    80003fbe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fc0:	00850913          	addi	s2,a0,8
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	cdbfc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    80003fca:	409c                	lw	a5,0(s1)
    80003fcc:	c799                	beqz	a5,80003fda <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003fce:	85ca                	mv	a1,s2
    80003fd0:	8526                	mv	a0,s1
    80003fd2:	86afe0ef          	jal	ra,8000203c <sleep>
  while (lk->locked) {
    80003fd6:	409c                	lw	a5,0(s1)
    80003fd8:	fbfd                	bnez	a5,80003fce <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003fda:	4785                	li	a5,1
    80003fdc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fde:	a57fd0ef          	jal	ra,80001a34 <myproc>
    80003fe2:	591c                	lw	a5,48(a0)
    80003fe4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003fe6:	854a                	mv	a0,s2
    80003fe8:	d51fc0ef          	jal	ra,80000d38 <release>
}
    80003fec:	60e2                	ld	ra,24(sp)
    80003fee:	6442                	ld	s0,16(sp)
    80003ff0:	64a2                	ld	s1,8(sp)
    80003ff2:	6902                	ld	s2,0(sp)
    80003ff4:	6105                	addi	sp,sp,32
    80003ff6:	8082                	ret

0000000080003ff8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ff8:	1101                	addi	sp,sp,-32
    80003ffa:	ec06                	sd	ra,24(sp)
    80003ffc:	e822                	sd	s0,16(sp)
    80003ffe:	e426                	sd	s1,8(sp)
    80004000:	e04a                	sd	s2,0(sp)
    80004002:	1000                	addi	s0,sp,32
    80004004:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004006:	00850913          	addi	s2,a0,8
    8000400a:	854a                	mv	a0,s2
    8000400c:	c95fc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    80004010:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004014:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004018:	8526                	mv	a0,s1
    8000401a:	86efe0ef          	jal	ra,80002088 <wakeup>
  release(&lk->lk);
    8000401e:	854a                	mv	a0,s2
    80004020:	d19fc0ef          	jal	ra,80000d38 <release>
}
    80004024:	60e2                	ld	ra,24(sp)
    80004026:	6442                	ld	s0,16(sp)
    80004028:	64a2                	ld	s1,8(sp)
    8000402a:	6902                	ld	s2,0(sp)
    8000402c:	6105                	addi	sp,sp,32
    8000402e:	8082                	ret

0000000080004030 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004030:	7179                	addi	sp,sp,-48
    80004032:	f406                	sd	ra,40(sp)
    80004034:	f022                	sd	s0,32(sp)
    80004036:	ec26                	sd	s1,24(sp)
    80004038:	e84a                	sd	s2,16(sp)
    8000403a:	e44e                	sd	s3,8(sp)
    8000403c:	1800                	addi	s0,sp,48
    8000403e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004040:	00850913          	addi	s2,a0,8
    80004044:	854a                	mv	a0,s2
    80004046:	c5bfc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000404a:	409c                	lw	a5,0(s1)
    8000404c:	ef89                	bnez	a5,80004066 <holdingsleep+0x36>
    8000404e:	4481                	li	s1,0
  release(&lk->lk);
    80004050:	854a                	mv	a0,s2
    80004052:	ce7fc0ef          	jal	ra,80000d38 <release>
  return r;
}
    80004056:	8526                	mv	a0,s1
    80004058:	70a2                	ld	ra,40(sp)
    8000405a:	7402                	ld	s0,32(sp)
    8000405c:	64e2                	ld	s1,24(sp)
    8000405e:	6942                	ld	s2,16(sp)
    80004060:	69a2                	ld	s3,8(sp)
    80004062:	6145                	addi	sp,sp,48
    80004064:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004066:	0284a983          	lw	s3,40(s1)
    8000406a:	9cbfd0ef          	jal	ra,80001a34 <myproc>
    8000406e:	5904                	lw	s1,48(a0)
    80004070:	413484b3          	sub	s1,s1,s3
    80004074:	0014b493          	seqz	s1,s1
    80004078:	bfe1                	j	80004050 <holdingsleep+0x20>

000000008000407a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000407a:	1141                	addi	sp,sp,-16
    8000407c:	e406                	sd	ra,8(sp)
    8000407e:	e022                	sd	s0,0(sp)
    80004080:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004082:	00003597          	auipc	a1,0x3
    80004086:	60e58593          	addi	a1,a1,1550 # 80007690 <syscalls+0x278>
    8000408a:	0023c517          	auipc	a0,0x23c
    8000408e:	a4e50513          	addi	a0,a0,-1458 # 8023fad8 <ftable>
    80004092:	b8ffc0ef          	jal	ra,80000c20 <initlock>
}
    80004096:	60a2                	ld	ra,8(sp)
    80004098:	6402                	ld	s0,0(sp)
    8000409a:	0141                	addi	sp,sp,16
    8000409c:	8082                	ret

000000008000409e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000409e:	1101                	addi	sp,sp,-32
    800040a0:	ec06                	sd	ra,24(sp)
    800040a2:	e822                	sd	s0,16(sp)
    800040a4:	e426                	sd	s1,8(sp)
    800040a6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040a8:	0023c517          	auipc	a0,0x23c
    800040ac:	a3050513          	addi	a0,a0,-1488 # 8023fad8 <ftable>
    800040b0:	bf1fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040b4:	0023c497          	auipc	s1,0x23c
    800040b8:	a3c48493          	addi	s1,s1,-1476 # 8023faf0 <ftable+0x18>
    800040bc:	0023d717          	auipc	a4,0x23d
    800040c0:	9d470713          	addi	a4,a4,-1580 # 80240a90 <disk>
    if(f->ref == 0){
    800040c4:	40dc                	lw	a5,4(s1)
    800040c6:	cf89                	beqz	a5,800040e0 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040c8:	02848493          	addi	s1,s1,40
    800040cc:	fee49ce3          	bne	s1,a4,800040c4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040d0:	0023c517          	auipc	a0,0x23c
    800040d4:	a0850513          	addi	a0,a0,-1528 # 8023fad8 <ftable>
    800040d8:	c61fc0ef          	jal	ra,80000d38 <release>
  return 0;
    800040dc:	4481                	li	s1,0
    800040de:	a809                	j	800040f0 <filealloc+0x52>
      f->ref = 1;
    800040e0:	4785                	li	a5,1
    800040e2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040e4:	0023c517          	auipc	a0,0x23c
    800040e8:	9f450513          	addi	a0,a0,-1548 # 8023fad8 <ftable>
    800040ec:	c4dfc0ef          	jal	ra,80000d38 <release>
}
    800040f0:	8526                	mv	a0,s1
    800040f2:	60e2                	ld	ra,24(sp)
    800040f4:	6442                	ld	s0,16(sp)
    800040f6:	64a2                	ld	s1,8(sp)
    800040f8:	6105                	addi	sp,sp,32
    800040fa:	8082                	ret

00000000800040fc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800040fc:	1101                	addi	sp,sp,-32
    800040fe:	ec06                	sd	ra,24(sp)
    80004100:	e822                	sd	s0,16(sp)
    80004102:	e426                	sd	s1,8(sp)
    80004104:	1000                	addi	s0,sp,32
    80004106:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004108:	0023c517          	auipc	a0,0x23c
    8000410c:	9d050513          	addi	a0,a0,-1584 # 8023fad8 <ftable>
    80004110:	b91fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004114:	40dc                	lw	a5,4(s1)
    80004116:	02f05063          	blez	a5,80004136 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000411a:	2785                	addiw	a5,a5,1
    8000411c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000411e:	0023c517          	auipc	a0,0x23c
    80004122:	9ba50513          	addi	a0,a0,-1606 # 8023fad8 <ftable>
    80004126:	c13fc0ef          	jal	ra,80000d38 <release>
  return f;
}
    8000412a:	8526                	mv	a0,s1
    8000412c:	60e2                	ld	ra,24(sp)
    8000412e:	6442                	ld	s0,16(sp)
    80004130:	64a2                	ld	s1,8(sp)
    80004132:	6105                	addi	sp,sp,32
    80004134:	8082                	ret
    panic("filedup");
    80004136:	00003517          	auipc	a0,0x3
    8000413a:	56250513          	addi	a0,a0,1378 # 80007698 <syscalls+0x280>
    8000413e:	e4afc0ef          	jal	ra,80000788 <panic>

0000000080004142 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004142:	7139                	addi	sp,sp,-64
    80004144:	fc06                	sd	ra,56(sp)
    80004146:	f822                	sd	s0,48(sp)
    80004148:	f426                	sd	s1,40(sp)
    8000414a:	f04a                	sd	s2,32(sp)
    8000414c:	ec4e                	sd	s3,24(sp)
    8000414e:	e852                	sd	s4,16(sp)
    80004150:	e456                	sd	s5,8(sp)
    80004152:	0080                	addi	s0,sp,64
    80004154:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004156:	0023c517          	auipc	a0,0x23c
    8000415a:	98250513          	addi	a0,a0,-1662 # 8023fad8 <ftable>
    8000415e:	b43fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004162:	40dc                	lw	a5,4(s1)
    80004164:	04f05963          	blez	a5,800041b6 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004168:	37fd                	addiw	a5,a5,-1
    8000416a:	0007871b          	sext.w	a4,a5
    8000416e:	c0dc                	sw	a5,4(s1)
    80004170:	04e04963          	bgtz	a4,800041c2 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004174:	0004a903          	lw	s2,0(s1)
    80004178:	0094ca83          	lbu	s5,9(s1)
    8000417c:	0104ba03          	ld	s4,16(s1)
    80004180:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004184:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004188:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000418c:	0023c517          	auipc	a0,0x23c
    80004190:	94c50513          	addi	a0,a0,-1716 # 8023fad8 <ftable>
    80004194:	ba5fc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    80004198:	4785                	li	a5,1
    8000419a:	04f90363          	beq	s2,a5,800041e0 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000419e:	3979                	addiw	s2,s2,-2
    800041a0:	4785                	li	a5,1
    800041a2:	0327e663          	bltu	a5,s2,800041ce <fileclose+0x8c>
    begin_op();
    800041a6:	b93ff0ef          	jal	ra,80003d38 <begin_op>
    iput(ff.ip);
    800041aa:	854e                	mv	a0,s3
    800041ac:	b22ff0ef          	jal	ra,800034ce <iput>
    end_op();
    800041b0:	bf7ff0ef          	jal	ra,80003da6 <end_op>
    800041b4:	a829                	j	800041ce <fileclose+0x8c>
    panic("fileclose");
    800041b6:	00003517          	auipc	a0,0x3
    800041ba:	4ea50513          	addi	a0,a0,1258 # 800076a0 <syscalls+0x288>
    800041be:	dcafc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    800041c2:	0023c517          	auipc	a0,0x23c
    800041c6:	91650513          	addi	a0,a0,-1770 # 8023fad8 <ftable>
    800041ca:	b6ffc0ef          	jal	ra,80000d38 <release>
  }
}
    800041ce:	70e2                	ld	ra,56(sp)
    800041d0:	7442                	ld	s0,48(sp)
    800041d2:	74a2                	ld	s1,40(sp)
    800041d4:	7902                	ld	s2,32(sp)
    800041d6:	69e2                	ld	s3,24(sp)
    800041d8:	6a42                	ld	s4,16(sp)
    800041da:	6aa2                	ld	s5,8(sp)
    800041dc:	6121                	addi	sp,sp,64
    800041de:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041e0:	85d6                	mv	a1,s5
    800041e2:	8552                	mv	a0,s4
    800041e4:	2ec000ef          	jal	ra,800044d0 <pipeclose>
    800041e8:	b7dd                	j	800041ce <fileclose+0x8c>

00000000800041ea <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041ea:	715d                	addi	sp,sp,-80
    800041ec:	e486                	sd	ra,72(sp)
    800041ee:	e0a2                	sd	s0,64(sp)
    800041f0:	fc26                	sd	s1,56(sp)
    800041f2:	f84a                	sd	s2,48(sp)
    800041f4:	f44e                	sd	s3,40(sp)
    800041f6:	0880                	addi	s0,sp,80
    800041f8:	84aa                	mv	s1,a0
    800041fa:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800041fc:	839fd0ef          	jal	ra,80001a34 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004200:	409c                	lw	a5,0(s1)
    80004202:	37f9                	addiw	a5,a5,-2
    80004204:	4705                	li	a4,1
    80004206:	02f76f63          	bltu	a4,a5,80004244 <filestat+0x5a>
    8000420a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000420c:	6c88                	ld	a0,24(s1)
    8000420e:	942ff0ef          	jal	ra,80003350 <ilock>
    stati(f->ip, &st);
    80004212:	fb840593          	addi	a1,s0,-72
    80004216:	6c88                	ld	a0,24(s1)
    80004218:	c9aff0ef          	jal	ra,800036b2 <stati>
    iunlock(f->ip);
    8000421c:	6c88                	ld	a0,24(s1)
    8000421e:	9dcff0ef          	jal	ra,800033fa <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004222:	46e1                	li	a3,24
    80004224:	fb840613          	addi	a2,s0,-72
    80004228:	85ce                	mv	a1,s3
    8000422a:	05093503          	ld	a0,80(s2)
    8000422e:	d30fd0ef          	jal	ra,8000175e <copyout>
    80004232:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004236:	60a6                	ld	ra,72(sp)
    80004238:	6406                	ld	s0,64(sp)
    8000423a:	74e2                	ld	s1,56(sp)
    8000423c:	7942                	ld	s2,48(sp)
    8000423e:	79a2                	ld	s3,40(sp)
    80004240:	6161                	addi	sp,sp,80
    80004242:	8082                	ret
  return -1;
    80004244:	557d                	li	a0,-1
    80004246:	bfc5                	j	80004236 <filestat+0x4c>

0000000080004248 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004248:	7179                	addi	sp,sp,-48
    8000424a:	f406                	sd	ra,40(sp)
    8000424c:	f022                	sd	s0,32(sp)
    8000424e:	ec26                	sd	s1,24(sp)
    80004250:	e84a                	sd	s2,16(sp)
    80004252:	e44e                	sd	s3,8(sp)
    80004254:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004256:	00854783          	lbu	a5,8(a0)
    8000425a:	cbc1                	beqz	a5,800042ea <fileread+0xa2>
    8000425c:	84aa                	mv	s1,a0
    8000425e:	89ae                	mv	s3,a1
    80004260:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004262:	411c                	lw	a5,0(a0)
    80004264:	4705                	li	a4,1
    80004266:	04e78363          	beq	a5,a4,800042ac <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000426a:	470d                	li	a4,3
    8000426c:	04e78563          	beq	a5,a4,800042b6 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004270:	4709                	li	a4,2
    80004272:	06e79663          	bne	a5,a4,800042de <fileread+0x96>
    ilock(f->ip);
    80004276:	6d08                	ld	a0,24(a0)
    80004278:	8d8ff0ef          	jal	ra,80003350 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000427c:	874a                	mv	a4,s2
    8000427e:	5094                	lw	a3,32(s1)
    80004280:	864e                	mv	a2,s3
    80004282:	4585                	li	a1,1
    80004284:	6c88                	ld	a0,24(s1)
    80004286:	c56ff0ef          	jal	ra,800036dc <readi>
    8000428a:	892a                	mv	s2,a0
    8000428c:	00a05563          	blez	a0,80004296 <fileread+0x4e>
      f->off += r;
    80004290:	509c                	lw	a5,32(s1)
    80004292:	9fa9                	addw	a5,a5,a0
    80004294:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004296:	6c88                	ld	a0,24(s1)
    80004298:	962ff0ef          	jal	ra,800033fa <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000429c:	854a                	mv	a0,s2
    8000429e:	70a2                	ld	ra,40(sp)
    800042a0:	7402                	ld	s0,32(sp)
    800042a2:	64e2                	ld	s1,24(sp)
    800042a4:	6942                	ld	s2,16(sp)
    800042a6:	69a2                	ld	s3,8(sp)
    800042a8:	6145                	addi	sp,sp,48
    800042aa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042ac:	6908                	ld	a0,16(a0)
    800042ae:	34e000ef          	jal	ra,800045fc <piperead>
    800042b2:	892a                	mv	s2,a0
    800042b4:	b7e5                	j	8000429c <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042b6:	02451783          	lh	a5,36(a0)
    800042ba:	03079693          	slli	a3,a5,0x30
    800042be:	92c1                	srli	a3,a3,0x30
    800042c0:	4725                	li	a4,9
    800042c2:	02d76663          	bltu	a4,a3,800042ee <fileread+0xa6>
    800042c6:	0792                	slli	a5,a5,0x4
    800042c8:	0023b717          	auipc	a4,0x23b
    800042cc:	77070713          	addi	a4,a4,1904 # 8023fa38 <devsw>
    800042d0:	97ba                	add	a5,a5,a4
    800042d2:	639c                	ld	a5,0(a5)
    800042d4:	cf99                	beqz	a5,800042f2 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800042d6:	4505                	li	a0,1
    800042d8:	9782                	jalr	a5
    800042da:	892a                	mv	s2,a0
    800042dc:	b7c1                	j	8000429c <fileread+0x54>
    panic("fileread");
    800042de:	00003517          	auipc	a0,0x3
    800042e2:	3d250513          	addi	a0,a0,978 # 800076b0 <syscalls+0x298>
    800042e6:	ca2fc0ef          	jal	ra,80000788 <panic>
    return -1;
    800042ea:	597d                	li	s2,-1
    800042ec:	bf45                	j	8000429c <fileread+0x54>
      return -1;
    800042ee:	597d                	li	s2,-1
    800042f0:	b775                	j	8000429c <fileread+0x54>
    800042f2:	597d                	li	s2,-1
    800042f4:	b765                	j	8000429c <fileread+0x54>

00000000800042f6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800042f6:	715d                	addi	sp,sp,-80
    800042f8:	e486                	sd	ra,72(sp)
    800042fa:	e0a2                	sd	s0,64(sp)
    800042fc:	fc26                	sd	s1,56(sp)
    800042fe:	f84a                	sd	s2,48(sp)
    80004300:	f44e                	sd	s3,40(sp)
    80004302:	f052                	sd	s4,32(sp)
    80004304:	ec56                	sd	s5,24(sp)
    80004306:	e85a                	sd	s6,16(sp)
    80004308:	e45e                	sd	s7,8(sp)
    8000430a:	e062                	sd	s8,0(sp)
    8000430c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000430e:	00954783          	lbu	a5,9(a0)
    80004312:	0e078863          	beqz	a5,80004402 <filewrite+0x10c>
    80004316:	892a                	mv	s2,a0
    80004318:	8b2e                	mv	s6,a1
    8000431a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000431c:	411c                	lw	a5,0(a0)
    8000431e:	4705                	li	a4,1
    80004320:	02e78263          	beq	a5,a4,80004344 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004324:	470d                	li	a4,3
    80004326:	02e78463          	beq	a5,a4,8000434e <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000432a:	4709                	li	a4,2
    8000432c:	0ce79563          	bne	a5,a4,800043f6 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004330:	0ac05163          	blez	a2,800043d2 <filewrite+0xdc>
    int i = 0;
    80004334:	4981                	li	s3,0
    80004336:	6b85                	lui	s7,0x1
    80004338:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000433c:	6c05                	lui	s8,0x1
    8000433e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004342:	a041                	j	800043c2 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004344:	6908                	ld	a0,16(a0)
    80004346:	1e2000ef          	jal	ra,80004528 <pipewrite>
    8000434a:	8a2a                	mv	s4,a0
    8000434c:	a071                	j	800043d8 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000434e:	02451783          	lh	a5,36(a0)
    80004352:	03079693          	slli	a3,a5,0x30
    80004356:	92c1                	srli	a3,a3,0x30
    80004358:	4725                	li	a4,9
    8000435a:	0ad76663          	bltu	a4,a3,80004406 <filewrite+0x110>
    8000435e:	0792                	slli	a5,a5,0x4
    80004360:	0023b717          	auipc	a4,0x23b
    80004364:	6d870713          	addi	a4,a4,1752 # 8023fa38 <devsw>
    80004368:	97ba                	add	a5,a5,a4
    8000436a:	679c                	ld	a5,8(a5)
    8000436c:	cfd9                	beqz	a5,8000440a <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000436e:	4505                	li	a0,1
    80004370:	9782                	jalr	a5
    80004372:	8a2a                	mv	s4,a0
    80004374:	a095                	j	800043d8 <filewrite+0xe2>
    80004376:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000437a:	9bfff0ef          	jal	ra,80003d38 <begin_op>
      ilock(f->ip);
    8000437e:	01893503          	ld	a0,24(s2)
    80004382:	fcffe0ef          	jal	ra,80003350 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004386:	8756                	mv	a4,s5
    80004388:	02092683          	lw	a3,32(s2)
    8000438c:	01698633          	add	a2,s3,s6
    80004390:	4585                	li	a1,1
    80004392:	01893503          	ld	a0,24(s2)
    80004396:	c2aff0ef          	jal	ra,800037c0 <writei>
    8000439a:	84aa                	mv	s1,a0
    8000439c:	00a05763          	blez	a0,800043aa <filewrite+0xb4>
        f->off += r;
    800043a0:	02092783          	lw	a5,32(s2)
    800043a4:	9fa9                	addw	a5,a5,a0
    800043a6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800043aa:	01893503          	ld	a0,24(s2)
    800043ae:	84cff0ef          	jal	ra,800033fa <iunlock>
      end_op();
    800043b2:	9f5ff0ef          	jal	ra,80003da6 <end_op>

      if(r != n1){
    800043b6:	009a9f63          	bne	s5,s1,800043d4 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800043ba:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800043be:	0149db63          	bge	s3,s4,800043d4 <filewrite+0xde>
      int n1 = n - i;
    800043c2:	413a04bb          	subw	s1,s4,s3
    800043c6:	0004879b          	sext.w	a5,s1
    800043ca:	fafbd6e3          	bge	s7,a5,80004376 <filewrite+0x80>
    800043ce:	84e2                	mv	s1,s8
    800043d0:	b75d                	j	80004376 <filewrite+0x80>
    int i = 0;
    800043d2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800043d4:	013a1f63          	bne	s4,s3,800043f2 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043d8:	8552                	mv	a0,s4
    800043da:	60a6                	ld	ra,72(sp)
    800043dc:	6406                	ld	s0,64(sp)
    800043de:	74e2                	ld	s1,56(sp)
    800043e0:	7942                	ld	s2,48(sp)
    800043e2:	79a2                	ld	s3,40(sp)
    800043e4:	7a02                	ld	s4,32(sp)
    800043e6:	6ae2                	ld	s5,24(sp)
    800043e8:	6b42                	ld	s6,16(sp)
    800043ea:	6ba2                	ld	s7,8(sp)
    800043ec:	6c02                	ld	s8,0(sp)
    800043ee:	6161                	addi	sp,sp,80
    800043f0:	8082                	ret
    ret = (i == n ? n : -1);
    800043f2:	5a7d                	li	s4,-1
    800043f4:	b7d5                	j	800043d8 <filewrite+0xe2>
    panic("filewrite");
    800043f6:	00003517          	auipc	a0,0x3
    800043fa:	2ca50513          	addi	a0,a0,714 # 800076c0 <syscalls+0x2a8>
    800043fe:	b8afc0ef          	jal	ra,80000788 <panic>
    return -1;
    80004402:	5a7d                	li	s4,-1
    80004404:	bfd1                	j	800043d8 <filewrite+0xe2>
      return -1;
    80004406:	5a7d                	li	s4,-1
    80004408:	bfc1                	j	800043d8 <filewrite+0xe2>
    8000440a:	5a7d                	li	s4,-1
    8000440c:	b7f1                	j	800043d8 <filewrite+0xe2>

000000008000440e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000440e:	7179                	addi	sp,sp,-48
    80004410:	f406                	sd	ra,40(sp)
    80004412:	f022                	sd	s0,32(sp)
    80004414:	ec26                	sd	s1,24(sp)
    80004416:	e84a                	sd	s2,16(sp)
    80004418:	e44e                	sd	s3,8(sp)
    8000441a:	e052                	sd	s4,0(sp)
    8000441c:	1800                	addi	s0,sp,48
    8000441e:	84aa                	mv	s1,a0
    80004420:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004422:	0005b023          	sd	zero,0(a1)
    80004426:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000442a:	c75ff0ef          	jal	ra,8000409e <filealloc>
    8000442e:	e088                	sd	a0,0(s1)
    80004430:	cd35                	beqz	a0,800044ac <pipealloc+0x9e>
    80004432:	c6dff0ef          	jal	ra,8000409e <filealloc>
    80004436:	00aa3023          	sd	a0,0(s4)
    8000443a:	c52d                	beqz	a0,800044a4 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000443c:	f6efc0ef          	jal	ra,80000baa <kalloc>
    80004440:	892a                	mv	s2,a0
    80004442:	cd31                	beqz	a0,8000449e <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004444:	4985                	li	s3,1
    80004446:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000444a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000444e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004452:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004456:	00003597          	auipc	a1,0x3
    8000445a:	27a58593          	addi	a1,a1,634 # 800076d0 <syscalls+0x2b8>
    8000445e:	fc2fc0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004462:	609c                	ld	a5,0(s1)
    80004464:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004468:	609c                	ld	a5,0(s1)
    8000446a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000446e:	609c                	ld	a5,0(s1)
    80004470:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004474:	609c                	ld	a5,0(s1)
    80004476:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000447a:	000a3783          	ld	a5,0(s4)
    8000447e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004482:	000a3783          	ld	a5,0(s4)
    80004486:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000448a:	000a3783          	ld	a5,0(s4)
    8000448e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004492:	000a3783          	ld	a5,0(s4)
    80004496:	0127b823          	sd	s2,16(a5)
  return 0;
    8000449a:	4501                	li	a0,0
    8000449c:	a005                	j	800044bc <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000449e:	6088                	ld	a0,0(s1)
    800044a0:	e501                	bnez	a0,800044a8 <pipealloc+0x9a>
    800044a2:	a029                	j	800044ac <pipealloc+0x9e>
    800044a4:	6088                	ld	a0,0(s1)
    800044a6:	c11d                	beqz	a0,800044cc <pipealloc+0xbe>
    fileclose(*f0);
    800044a8:	c9bff0ef          	jal	ra,80004142 <fileclose>
  if(*f1)
    800044ac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800044b0:	557d                	li	a0,-1
  if(*f1)
    800044b2:	c789                	beqz	a5,800044bc <pipealloc+0xae>
    fileclose(*f1);
    800044b4:	853e                	mv	a0,a5
    800044b6:	c8dff0ef          	jal	ra,80004142 <fileclose>
  return -1;
    800044ba:	557d                	li	a0,-1
}
    800044bc:	70a2                	ld	ra,40(sp)
    800044be:	7402                	ld	s0,32(sp)
    800044c0:	64e2                	ld	s1,24(sp)
    800044c2:	6942                	ld	s2,16(sp)
    800044c4:	69a2                	ld	s3,8(sp)
    800044c6:	6a02                	ld	s4,0(sp)
    800044c8:	6145                	addi	sp,sp,48
    800044ca:	8082                	ret
  return -1;
    800044cc:	557d                	li	a0,-1
    800044ce:	b7fd                	j	800044bc <pipealloc+0xae>

00000000800044d0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044d0:	1101                	addi	sp,sp,-32
    800044d2:	ec06                	sd	ra,24(sp)
    800044d4:	e822                	sd	s0,16(sp)
    800044d6:	e426                	sd	s1,8(sp)
    800044d8:	e04a                	sd	s2,0(sp)
    800044da:	1000                	addi	s0,sp,32
    800044dc:	84aa                	mv	s1,a0
    800044de:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044e0:	fc0fc0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    800044e4:	02090763          	beqz	s2,80004512 <pipeclose+0x42>
    pi->writeopen = 0;
    800044e8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044ec:	21848513          	addi	a0,s1,536
    800044f0:	b99fd0ef          	jal	ra,80002088 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044f4:	2204b783          	ld	a5,544(s1)
    800044f8:	e785                	bnez	a5,80004520 <pipeclose+0x50>
    release(&pi->lock);
    800044fa:	8526                	mv	a0,s1
    800044fc:	83dfc0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004500:	8526                	mv	a0,s1
    80004502:	d78fc0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004506:	60e2                	ld	ra,24(sp)
    80004508:	6442                	ld	s0,16(sp)
    8000450a:	64a2                	ld	s1,8(sp)
    8000450c:	6902                	ld	s2,0(sp)
    8000450e:	6105                	addi	sp,sp,32
    80004510:	8082                	ret
    pi->readopen = 0;
    80004512:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004516:	21c48513          	addi	a0,s1,540
    8000451a:	b6ffd0ef          	jal	ra,80002088 <wakeup>
    8000451e:	bfd9                	j	800044f4 <pipeclose+0x24>
    release(&pi->lock);
    80004520:	8526                	mv	a0,s1
    80004522:	817fc0ef          	jal	ra,80000d38 <release>
}
    80004526:	b7c5                	j	80004506 <pipeclose+0x36>

0000000080004528 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004528:	711d                	addi	sp,sp,-96
    8000452a:	ec86                	sd	ra,88(sp)
    8000452c:	e8a2                	sd	s0,80(sp)
    8000452e:	e4a6                	sd	s1,72(sp)
    80004530:	e0ca                	sd	s2,64(sp)
    80004532:	fc4e                	sd	s3,56(sp)
    80004534:	f852                	sd	s4,48(sp)
    80004536:	f456                	sd	s5,40(sp)
    80004538:	f05a                	sd	s6,32(sp)
    8000453a:	ec5e                	sd	s7,24(sp)
    8000453c:	e862                	sd	s8,16(sp)
    8000453e:	1080                	addi	s0,sp,96
    80004540:	84aa                	mv	s1,a0
    80004542:	8aae                	mv	s5,a1
    80004544:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004546:	ceefd0ef          	jal	ra,80001a34 <myproc>
    8000454a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000454c:	8526                	mv	a0,s1
    8000454e:	f52fc0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004552:	09405c63          	blez	s4,800045ea <pipewrite+0xc2>
  int i = 0;
    80004556:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004558:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000455a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000455e:	21c48b93          	addi	s7,s1,540
    80004562:	a81d                	j	80004598 <pipewrite+0x70>
      release(&pi->lock);
    80004564:	8526                	mv	a0,s1
    80004566:	fd2fc0ef          	jal	ra,80000d38 <release>
      return -1;
    8000456a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000456c:	854a                	mv	a0,s2
    8000456e:	60e6                	ld	ra,88(sp)
    80004570:	6446                	ld	s0,80(sp)
    80004572:	64a6                	ld	s1,72(sp)
    80004574:	6906                	ld	s2,64(sp)
    80004576:	79e2                	ld	s3,56(sp)
    80004578:	7a42                	ld	s4,48(sp)
    8000457a:	7aa2                	ld	s5,40(sp)
    8000457c:	7b02                	ld	s6,32(sp)
    8000457e:	6be2                	ld	s7,24(sp)
    80004580:	6c42                	ld	s8,16(sp)
    80004582:	6125                	addi	sp,sp,96
    80004584:	8082                	ret
      wakeup(&pi->nread);
    80004586:	8562                	mv	a0,s8
    80004588:	b01fd0ef          	jal	ra,80002088 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000458c:	85a6                	mv	a1,s1
    8000458e:	855e                	mv	a0,s7
    80004590:	aadfd0ef          	jal	ra,8000203c <sleep>
  while(i < n){
    80004594:	05495c63          	bge	s2,s4,800045ec <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004598:	2204a783          	lw	a5,544(s1)
    8000459c:	d7e1                	beqz	a5,80004564 <pipewrite+0x3c>
    8000459e:	854e                	mv	a0,s3
    800045a0:	cd5fd0ef          	jal	ra,80002274 <killed>
    800045a4:	f161                	bnez	a0,80004564 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800045a6:	2184a783          	lw	a5,536(s1)
    800045aa:	21c4a703          	lw	a4,540(s1)
    800045ae:	2007879b          	addiw	a5,a5,512
    800045b2:	fcf70ae3          	beq	a4,a5,80004586 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045b6:	4685                	li	a3,1
    800045b8:	01590633          	add	a2,s2,s5
    800045bc:	faf40593          	addi	a1,s0,-81
    800045c0:	0509b503          	ld	a0,80(s3)
    800045c4:	a84fd0ef          	jal	ra,80001848 <copyin>
    800045c8:	03650263          	beq	a0,s6,800045ec <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045cc:	21c4a783          	lw	a5,540(s1)
    800045d0:	0017871b          	addiw	a4,a5,1
    800045d4:	20e4ae23          	sw	a4,540(s1)
    800045d8:	1ff7f793          	andi	a5,a5,511
    800045dc:	97a6                	add	a5,a5,s1
    800045de:	faf44703          	lbu	a4,-81(s0)
    800045e2:	00e78c23          	sb	a4,24(a5)
      i++;
    800045e6:	2905                	addiw	s2,s2,1
    800045e8:	b775                	j	80004594 <pipewrite+0x6c>
  int i = 0;
    800045ea:	4901                	li	s2,0
  wakeup(&pi->nread);
    800045ec:	21848513          	addi	a0,s1,536
    800045f0:	a99fd0ef          	jal	ra,80002088 <wakeup>
  release(&pi->lock);
    800045f4:	8526                	mv	a0,s1
    800045f6:	f42fc0ef          	jal	ra,80000d38 <release>
  return i;
    800045fa:	bf8d                	j	8000456c <pipewrite+0x44>

00000000800045fc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045fc:	715d                	addi	sp,sp,-80
    800045fe:	e486                	sd	ra,72(sp)
    80004600:	e0a2                	sd	s0,64(sp)
    80004602:	fc26                	sd	s1,56(sp)
    80004604:	f84a                	sd	s2,48(sp)
    80004606:	f44e                	sd	s3,40(sp)
    80004608:	f052                	sd	s4,32(sp)
    8000460a:	ec56                	sd	s5,24(sp)
    8000460c:	e85a                	sd	s6,16(sp)
    8000460e:	0880                	addi	s0,sp,80
    80004610:	84aa                	mv	s1,a0
    80004612:	892e                	mv	s2,a1
    80004614:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004616:	c1efd0ef          	jal	ra,80001a34 <myproc>
    8000461a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000461c:	8526                	mv	a0,s1
    8000461e:	e82fc0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004622:	2184a703          	lw	a4,536(s1)
    80004626:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000462a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000462e:	02f71363          	bne	a4,a5,80004654 <piperead+0x58>
    80004632:	2244a783          	lw	a5,548(s1)
    80004636:	cf99                	beqz	a5,80004654 <piperead+0x58>
    if(killed(pr)){
    80004638:	8552                	mv	a0,s4
    8000463a:	c3bfd0ef          	jal	ra,80002274 <killed>
    8000463e:	e151                	bnez	a0,800046c2 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004640:	85a6                	mv	a1,s1
    80004642:	854e                	mv	a0,s3
    80004644:	9f9fd0ef          	jal	ra,8000203c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004648:	2184a703          	lw	a4,536(s1)
    8000464c:	21c4a783          	lw	a5,540(s1)
    80004650:	fef701e3          	beq	a4,a5,80004632 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004654:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004656:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004658:	05505363          	blez	s5,8000469e <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    8000465c:	2184a783          	lw	a5,536(s1)
    80004660:	21c4a703          	lw	a4,540(s1)
    80004664:	02f70d63          	beq	a4,a5,8000469e <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004668:	1ff7f793          	andi	a5,a5,511
    8000466c:	97a6                	add	a5,a5,s1
    8000466e:	0187c783          	lbu	a5,24(a5)
    80004672:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004676:	4685                	li	a3,1
    80004678:	fbf40613          	addi	a2,s0,-65
    8000467c:	85ca                	mv	a1,s2
    8000467e:	050a3503          	ld	a0,80(s4)
    80004682:	8dcfd0ef          	jal	ra,8000175e <copyout>
    80004686:	05650363          	beq	a0,s6,800046cc <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000468a:	2184a783          	lw	a5,536(s1)
    8000468e:	2785                	addiw	a5,a5,1
    80004690:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004694:	2985                	addiw	s3,s3,1
    80004696:	0905                	addi	s2,s2,1
    80004698:	fd3a92e3          	bne	s5,s3,8000465c <piperead+0x60>
    8000469c:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000469e:	21c48513          	addi	a0,s1,540
    800046a2:	9e7fd0ef          	jal	ra,80002088 <wakeup>
  release(&pi->lock);
    800046a6:	8526                	mv	a0,s1
    800046a8:	e90fc0ef          	jal	ra,80000d38 <release>
  return i;
}
    800046ac:	854e                	mv	a0,s3
    800046ae:	60a6                	ld	ra,72(sp)
    800046b0:	6406                	ld	s0,64(sp)
    800046b2:	74e2                	ld	s1,56(sp)
    800046b4:	7942                	ld	s2,48(sp)
    800046b6:	79a2                	ld	s3,40(sp)
    800046b8:	7a02                	ld	s4,32(sp)
    800046ba:	6ae2                	ld	s5,24(sp)
    800046bc:	6b42                	ld	s6,16(sp)
    800046be:	6161                	addi	sp,sp,80
    800046c0:	8082                	ret
      release(&pi->lock);
    800046c2:	8526                	mv	a0,s1
    800046c4:	e74fc0ef          	jal	ra,80000d38 <release>
      return -1;
    800046c8:	59fd                	li	s3,-1
    800046ca:	b7cd                	j	800046ac <piperead+0xb0>
      if(i == 0)
    800046cc:	fc0999e3          	bnez	s3,8000469e <piperead+0xa2>
        i = -1;
    800046d0:	89aa                	mv	s3,a0
    800046d2:	b7f1                	j	8000469e <piperead+0xa2>

00000000800046d4 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046d4:	1141                	addi	sp,sp,-16
    800046d6:	e422                	sd	s0,8(sp)
    800046d8:	0800                	addi	s0,sp,16
    800046da:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046dc:	8905                	andi	a0,a0,1
    800046de:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800046e0:	8b89                	andi	a5,a5,2
    800046e2:	c399                	beqz	a5,800046e8 <flags2perm+0x14>
      perm |= PTE_W;
    800046e4:	00456513          	ori	a0,a0,4
    return perm;
}
    800046e8:	6422                	ld	s0,8(sp)
    800046ea:	0141                	addi	sp,sp,16
    800046ec:	8082                	ret

00000000800046ee <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046ee:	de010113          	addi	sp,sp,-544
    800046f2:	20113c23          	sd	ra,536(sp)
    800046f6:	20813823          	sd	s0,528(sp)
    800046fa:	20913423          	sd	s1,520(sp)
    800046fe:	21213023          	sd	s2,512(sp)
    80004702:	ffce                	sd	s3,504(sp)
    80004704:	fbd2                	sd	s4,496(sp)
    80004706:	f7d6                	sd	s5,488(sp)
    80004708:	f3da                	sd	s6,480(sp)
    8000470a:	efde                	sd	s7,472(sp)
    8000470c:	ebe2                	sd	s8,464(sp)
    8000470e:	e7e6                	sd	s9,456(sp)
    80004710:	e3ea                	sd	s10,448(sp)
    80004712:	ff6e                	sd	s11,440(sp)
    80004714:	1400                	addi	s0,sp,544
    80004716:	892a                	mv	s2,a0
    80004718:	dea43423          	sd	a0,-536(s0)
    8000471c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004720:	b14fd0ef          	jal	ra,80001a34 <myproc>
    80004724:	84aa                	mv	s1,a0

  begin_op();
    80004726:	e12ff0ef          	jal	ra,80003d38 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000472a:	854a                	mv	a0,s2
    8000472c:	c18ff0ef          	jal	ra,80003b44 <namei>
    80004730:	c13d                	beqz	a0,80004796 <kexec+0xa8>
    80004732:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004734:	c1dfe0ef          	jal	ra,80003350 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004738:	04000713          	li	a4,64
    8000473c:	4681                	li	a3,0
    8000473e:	e5040613          	addi	a2,s0,-432
    80004742:	4581                	li	a1,0
    80004744:	8556                	mv	a0,s5
    80004746:	f97fe0ef          	jal	ra,800036dc <readi>
    8000474a:	04000793          	li	a5,64
    8000474e:	00f51a63          	bne	a0,a5,80004762 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004752:	e5042703          	lw	a4,-432(s0)
    80004756:	464c47b7          	lui	a5,0x464c4
    8000475a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000475e:	04f70063          	beq	a4,a5,8000479e <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004762:	8556                	mv	a0,s5
    80004764:	df3fe0ef          	jal	ra,80003556 <iunlockput>
    end_op();
    80004768:	e3eff0ef          	jal	ra,80003da6 <end_op>
  }
  return -1;
    8000476c:	557d                	li	a0,-1
}
    8000476e:	21813083          	ld	ra,536(sp)
    80004772:	21013403          	ld	s0,528(sp)
    80004776:	20813483          	ld	s1,520(sp)
    8000477a:	20013903          	ld	s2,512(sp)
    8000477e:	79fe                	ld	s3,504(sp)
    80004780:	7a5e                	ld	s4,496(sp)
    80004782:	7abe                	ld	s5,488(sp)
    80004784:	7b1e                	ld	s6,480(sp)
    80004786:	6bfe                	ld	s7,472(sp)
    80004788:	6c5e                	ld	s8,464(sp)
    8000478a:	6cbe                	ld	s9,456(sp)
    8000478c:	6d1e                	ld	s10,448(sp)
    8000478e:	7dfa                	ld	s11,440(sp)
    80004790:	22010113          	addi	sp,sp,544
    80004794:	8082                	ret
    end_op();
    80004796:	e10ff0ef          	jal	ra,80003da6 <end_op>
    return -1;
    8000479a:	557d                	li	a0,-1
    8000479c:	bfc9                	j	8000476e <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    8000479e:	8526                	mv	a0,s1
    800047a0:	b9afd0ef          	jal	ra,80001b3a <proc_pagetable>
    800047a4:	8b2a                	mv	s6,a0
    800047a6:	dd55                	beqz	a0,80004762 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047a8:	e7042783          	lw	a5,-400(s0)
    800047ac:	e8845703          	lhu	a4,-376(s0)
    800047b0:	c325                	beqz	a4,80004810 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047b2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047b4:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800047b8:	6a05                	lui	s4,0x1
    800047ba:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800047be:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800047c2:	6d85                	lui	s11,0x1
    800047c4:	7d7d                	lui	s10,0xfffff
    800047c6:	a409                	j	800049c8 <kexec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800047c8:	00003517          	auipc	a0,0x3
    800047cc:	f1050513          	addi	a0,a0,-240 # 800076d8 <syscalls+0x2c0>
    800047d0:	fb9fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047d4:	874a                	mv	a4,s2
    800047d6:	009c86bb          	addw	a3,s9,s1
    800047da:	4581                	li	a1,0
    800047dc:	8556                	mv	a0,s5
    800047de:	efffe0ef          	jal	ra,800036dc <readi>
    800047e2:	2501                	sext.w	a0,a0
    800047e4:	18a91163          	bne	s2,a0,80004966 <kexec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    800047e8:	009d84bb          	addw	s1,s11,s1
    800047ec:	013d09bb          	addw	s3,s10,s3
    800047f0:	1b74fc63          	bgeu	s1,s7,800049a8 <kexec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    800047f4:	02049593          	slli	a1,s1,0x20
    800047f8:	9181                	srli	a1,a1,0x20
    800047fa:	95e2                	add	a1,a1,s8
    800047fc:	855a                	mv	a0,s6
    800047fe:	88dfc0ef          	jal	ra,8000108a <walkaddr>
    80004802:	862a                	mv	a2,a0
    if(pa == 0)
    80004804:	d171                	beqz	a0,800047c8 <kexec+0xda>
      n = PGSIZE;
    80004806:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004808:	fd49f6e3          	bgeu	s3,s4,800047d4 <kexec+0xe6>
      n = sz - i;
    8000480c:	894e                	mv	s2,s3
    8000480e:	b7d9                	j	800047d4 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004810:	4901                	li	s2,0
  iunlockput(ip);
    80004812:	8556                	mv	a0,s5
    80004814:	d43fe0ef          	jal	ra,80003556 <iunlockput>
  end_op();
    80004818:	d8eff0ef          	jal	ra,80003da6 <end_op>
  p = myproc();
    8000481c:	a18fd0ef          	jal	ra,80001a34 <myproc>
    80004820:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004822:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004826:	6785                	lui	a5,0x1
    80004828:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000482a:	97ca                	add	a5,a5,s2
    8000482c:	777d                	lui	a4,0xfffff
    8000482e:	8ff9                	and	a5,a5,a4
    80004830:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004834:	4691                	li	a3,4
    80004836:	6609                	lui	a2,0x2
    80004838:	963e                	add	a2,a2,a5
    8000483a:	85be                	mv	a1,a5
    8000483c:	855a                	mv	a0,s6
    8000483e:	b17fc0ef          	jal	ra,80001354 <uvmalloc>
    80004842:	8c2a                	mv	s8,a0
  ip = 0;
    80004844:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004846:	12050063          	beqz	a0,80004966 <kexec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000484a:	75f9                	lui	a1,0xffffe
    8000484c:	95aa                	add	a1,a1,a0
    8000484e:	855a                	mv	a0,s6
    80004850:	da7fc0ef          	jal	ra,800015f6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004854:	7afd                	lui	s5,0xfffff
    80004856:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004858:	df043783          	ld	a5,-528(s0)
    8000485c:	6388                	ld	a0,0(a5)
    8000485e:	c135                	beqz	a0,800048c2 <kexec+0x1d4>
    80004860:	e9040993          	addi	s3,s0,-368
    80004864:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004868:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000486a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000486c:	e80fc0ef          	jal	ra,80000eec <strlen>
    80004870:	0015079b          	addiw	a5,a0,1
    80004874:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004878:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000487c:	11596a63          	bltu	s2,s5,80004990 <kexec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004880:	df043d83          	ld	s11,-528(s0)
    80004884:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004888:	8552                	mv	a0,s4
    8000488a:	e62fc0ef          	jal	ra,80000eec <strlen>
    8000488e:	0015069b          	addiw	a3,a0,1
    80004892:	8652                	mv	a2,s4
    80004894:	85ca                	mv	a1,s2
    80004896:	855a                	mv	a0,s6
    80004898:	ec7fc0ef          	jal	ra,8000175e <copyout>
    8000489c:	0e054e63          	bltz	a0,80004998 <kexec+0x2aa>
    ustack[argc] = sp;
    800048a0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800048a4:	0485                	addi	s1,s1,1
    800048a6:	008d8793          	addi	a5,s11,8
    800048aa:	def43823          	sd	a5,-528(s0)
    800048ae:	008db503          	ld	a0,8(s11)
    800048b2:	c911                	beqz	a0,800048c6 <kexec+0x1d8>
    if(argc >= MAXARG)
    800048b4:	09a1                	addi	s3,s3,8
    800048b6:	fb3c9be3          	bne	s9,s3,8000486c <kexec+0x17e>
  sz = sz1;
    800048ba:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800048be:	4a81                	li	s5,0
    800048c0:	a05d                	j	80004966 <kexec+0x278>
  sp = sz;
    800048c2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800048c4:	4481                	li	s1,0
  ustack[argc] = 0;
    800048c6:	00349793          	slli	a5,s1,0x3
    800048ca:	f9078793          	addi	a5,a5,-112
    800048ce:	97a2                	add	a5,a5,s0
    800048d0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800048d4:	00148693          	addi	a3,s1,1
    800048d8:	068e                	slli	a3,a3,0x3
    800048da:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048de:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800048e2:	01597663          	bgeu	s2,s5,800048ee <kexec+0x200>
  sz = sz1;
    800048e6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800048ea:	4a81                	li	s5,0
    800048ec:	a8ad                	j	80004966 <kexec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800048ee:	e9040613          	addi	a2,s0,-368
    800048f2:	85ca                	mv	a1,s2
    800048f4:	855a                	mv	a0,s6
    800048f6:	e69fc0ef          	jal	ra,8000175e <copyout>
    800048fa:	0a054363          	bltz	a0,800049a0 <kexec+0x2b2>
  p->trapframe->a1 = sp;
    800048fe:	058bb783          	ld	a5,88(s7)
    80004902:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004906:	de843783          	ld	a5,-536(s0)
    8000490a:	0007c703          	lbu	a4,0(a5)
    8000490e:	cf11                	beqz	a4,8000492a <kexec+0x23c>
    80004910:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004912:	02f00693          	li	a3,47
    80004916:	a039                	j	80004924 <kexec+0x236>
      last = s+1;
    80004918:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000491c:	0785                	addi	a5,a5,1
    8000491e:	fff7c703          	lbu	a4,-1(a5)
    80004922:	c701                	beqz	a4,8000492a <kexec+0x23c>
    if(*s == '/')
    80004924:	fed71ce3          	bne	a4,a3,8000491c <kexec+0x22e>
    80004928:	bfc5                	j	80004918 <kexec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    8000492a:	4641                	li	a2,16
    8000492c:	de843583          	ld	a1,-536(s0)
    80004930:	158b8513          	addi	a0,s7,344
    80004934:	d86fc0ef          	jal	ra,80000eba <safestrcpy>
  oldpagetable = p->pagetable;
    80004938:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000493c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004940:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004944:	058bb783          	ld	a5,88(s7)
    80004948:	e6843703          	ld	a4,-408(s0)
    8000494c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000494e:	058bb783          	ld	a5,88(s7)
    80004952:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004956:	85ea                	mv	a1,s10
    80004958:	a66fd0ef          	jal	ra,80001bbe <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000495c:	0004851b          	sext.w	a0,s1
    80004960:	b539                	j	8000476e <kexec+0x80>
    80004962:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004966:	df843583          	ld	a1,-520(s0)
    8000496a:	855a                	mv	a0,s6
    8000496c:	a52fd0ef          	jal	ra,80001bbe <proc_freepagetable>
  if(ip){
    80004970:	de0a99e3          	bnez	s5,80004762 <kexec+0x74>
  return -1;
    80004974:	557d                	li	a0,-1
    80004976:	bbe5                	j	8000476e <kexec+0x80>
    80004978:	df243c23          	sd	s2,-520(s0)
    8000497c:	b7ed                	j	80004966 <kexec+0x278>
    8000497e:	df243c23          	sd	s2,-520(s0)
    80004982:	b7d5                	j	80004966 <kexec+0x278>
    80004984:	df243c23          	sd	s2,-520(s0)
    80004988:	bff9                	j	80004966 <kexec+0x278>
    8000498a:	df243c23          	sd	s2,-520(s0)
    8000498e:	bfe1                	j	80004966 <kexec+0x278>
  sz = sz1;
    80004990:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004994:	4a81                	li	s5,0
    80004996:	bfc1                	j	80004966 <kexec+0x278>
  sz = sz1;
    80004998:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000499c:	4a81                	li	s5,0
    8000499e:	b7e1                	j	80004966 <kexec+0x278>
  sz = sz1;
    800049a0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800049a4:	4a81                	li	s5,0
    800049a6:	b7c1                	j	80004966 <kexec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049a8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049ac:	e0843783          	ld	a5,-504(s0)
    800049b0:	0017869b          	addiw	a3,a5,1
    800049b4:	e0d43423          	sd	a3,-504(s0)
    800049b8:	e0043783          	ld	a5,-512(s0)
    800049bc:	0387879b          	addiw	a5,a5,56
    800049c0:	e8845703          	lhu	a4,-376(s0)
    800049c4:	e4e6d7e3          	bge	a3,a4,80004812 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049c8:	2781                	sext.w	a5,a5
    800049ca:	e0f43023          	sd	a5,-512(s0)
    800049ce:	03800713          	li	a4,56
    800049d2:	86be                	mv	a3,a5
    800049d4:	e1840613          	addi	a2,s0,-488
    800049d8:	4581                	li	a1,0
    800049da:	8556                	mv	a0,s5
    800049dc:	d01fe0ef          	jal	ra,800036dc <readi>
    800049e0:	03800793          	li	a5,56
    800049e4:	f6f51fe3          	bne	a0,a5,80004962 <kexec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    800049e8:	e1842783          	lw	a5,-488(s0)
    800049ec:	4705                	li	a4,1
    800049ee:	fae79fe3          	bne	a5,a4,800049ac <kexec+0x2be>
    if(ph.memsz < ph.filesz)
    800049f2:	e4043483          	ld	s1,-448(s0)
    800049f6:	e3843783          	ld	a5,-456(s0)
    800049fa:	f6f4efe3          	bltu	s1,a5,80004978 <kexec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049fe:	e2843783          	ld	a5,-472(s0)
    80004a02:	94be                	add	s1,s1,a5
    80004a04:	f6f4ede3          	bltu	s1,a5,8000497e <kexec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80004a08:	de043703          	ld	a4,-544(s0)
    80004a0c:	8ff9                	and	a5,a5,a4
    80004a0e:	fbbd                	bnez	a5,80004984 <kexec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a10:	e1c42503          	lw	a0,-484(s0)
    80004a14:	cc1ff0ef          	jal	ra,800046d4 <flags2perm>
    80004a18:	86aa                	mv	a3,a0
    80004a1a:	8626                	mv	a2,s1
    80004a1c:	85ca                	mv	a1,s2
    80004a1e:	855a                	mv	a0,s6
    80004a20:	935fc0ef          	jal	ra,80001354 <uvmalloc>
    80004a24:	dea43c23          	sd	a0,-520(s0)
    80004a28:	d12d                	beqz	a0,8000498a <kexec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a2a:	e2843c03          	ld	s8,-472(s0)
    80004a2e:	e2042c83          	lw	s9,-480(s0)
    80004a32:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a36:	f60b89e3          	beqz	s7,800049a8 <kexec+0x2ba>
    80004a3a:	89de                	mv	s3,s7
    80004a3c:	4481                	li	s1,0
    80004a3e:	bb5d                	j	800047f4 <kexec+0x106>

0000000080004a40 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a40:	7179                	addi	sp,sp,-48
    80004a42:	f406                	sd	ra,40(sp)
    80004a44:	f022                	sd	s0,32(sp)
    80004a46:	ec26                	sd	s1,24(sp)
    80004a48:	e84a                	sd	s2,16(sp)
    80004a4a:	1800                	addi	s0,sp,48
    80004a4c:	892e                	mv	s2,a1
    80004a4e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a50:	fdc40593          	addi	a1,s0,-36
    80004a54:	f17fd0ef          	jal	ra,8000296a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a58:	fdc42703          	lw	a4,-36(s0)
    80004a5c:	47bd                	li	a5,15
    80004a5e:	02e7e963          	bltu	a5,a4,80004a90 <argfd+0x50>
    80004a62:	fd3fc0ef          	jal	ra,80001a34 <myproc>
    80004a66:	fdc42703          	lw	a4,-36(s0)
    80004a6a:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdbe44a>
    80004a6e:	078e                	slli	a5,a5,0x3
    80004a70:	953e                	add	a0,a0,a5
    80004a72:	611c                	ld	a5,0(a0)
    80004a74:	c385                	beqz	a5,80004a94 <argfd+0x54>
    return -1;
  if(pfd)
    80004a76:	00090463          	beqz	s2,80004a7e <argfd+0x3e>
    *pfd = fd;
    80004a7a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a7e:	4501                	li	a0,0
  if(pf)
    80004a80:	c091                	beqz	s1,80004a84 <argfd+0x44>
    *pf = f;
    80004a82:	e09c                	sd	a5,0(s1)
}
    80004a84:	70a2                	ld	ra,40(sp)
    80004a86:	7402                	ld	s0,32(sp)
    80004a88:	64e2                	ld	s1,24(sp)
    80004a8a:	6942                	ld	s2,16(sp)
    80004a8c:	6145                	addi	sp,sp,48
    80004a8e:	8082                	ret
    return -1;
    80004a90:	557d                	li	a0,-1
    80004a92:	bfcd                	j	80004a84 <argfd+0x44>
    80004a94:	557d                	li	a0,-1
    80004a96:	b7fd                	j	80004a84 <argfd+0x44>

0000000080004a98 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a98:	1101                	addi	sp,sp,-32
    80004a9a:	ec06                	sd	ra,24(sp)
    80004a9c:	e822                	sd	s0,16(sp)
    80004a9e:	e426                	sd	s1,8(sp)
    80004aa0:	1000                	addi	s0,sp,32
    80004aa2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004aa4:	f91fc0ef          	jal	ra,80001a34 <myproc>
    80004aa8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004aaa:	0d050793          	addi	a5,a0,208
    80004aae:	4501                	li	a0,0
    80004ab0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ab2:	6398                	ld	a4,0(a5)
    80004ab4:	cb19                	beqz	a4,80004aca <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ab6:	2505                	addiw	a0,a0,1
    80004ab8:	07a1                	addi	a5,a5,8
    80004aba:	fed51ce3          	bne	a0,a3,80004ab2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004abe:	557d                	li	a0,-1
}
    80004ac0:	60e2                	ld	ra,24(sp)
    80004ac2:	6442                	ld	s0,16(sp)
    80004ac4:	64a2                	ld	s1,8(sp)
    80004ac6:	6105                	addi	sp,sp,32
    80004ac8:	8082                	ret
      p->ofile[fd] = f;
    80004aca:	01a50793          	addi	a5,a0,26
    80004ace:	078e                	slli	a5,a5,0x3
    80004ad0:	963e                	add	a2,a2,a5
    80004ad2:	e204                	sd	s1,0(a2)
      return fd;
    80004ad4:	b7f5                	j	80004ac0 <fdalloc+0x28>

0000000080004ad6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ad6:	715d                	addi	sp,sp,-80
    80004ad8:	e486                	sd	ra,72(sp)
    80004ada:	e0a2                	sd	s0,64(sp)
    80004adc:	fc26                	sd	s1,56(sp)
    80004ade:	f84a                	sd	s2,48(sp)
    80004ae0:	f44e                	sd	s3,40(sp)
    80004ae2:	f052                	sd	s4,32(sp)
    80004ae4:	ec56                	sd	s5,24(sp)
    80004ae6:	e85a                	sd	s6,16(sp)
    80004ae8:	0880                	addi	s0,sp,80
    80004aea:	8b2e                	mv	s6,a1
    80004aec:	89b2                	mv	s3,a2
    80004aee:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004af0:	fb040593          	addi	a1,s0,-80
    80004af4:	86aff0ef          	jal	ra,80003b5e <nameiparent>
    80004af8:	84aa                	mv	s1,a0
    80004afa:	10050b63          	beqz	a0,80004c10 <create+0x13a>
    return 0;

  ilock(dp);
    80004afe:	853fe0ef          	jal	ra,80003350 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b02:	4601                	li	a2,0
    80004b04:	fb040593          	addi	a1,s0,-80
    80004b08:	8526                	mv	a0,s1
    80004b0a:	dcffe0ef          	jal	ra,800038d8 <dirlookup>
    80004b0e:	8aaa                	mv	s5,a0
    80004b10:	c521                	beqz	a0,80004b58 <create+0x82>
    iunlockput(dp);
    80004b12:	8526                	mv	a0,s1
    80004b14:	a43fe0ef          	jal	ra,80003556 <iunlockput>
    ilock(ip);
    80004b18:	8556                	mv	a0,s5
    80004b1a:	837fe0ef          	jal	ra,80003350 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b1e:	000b059b          	sext.w	a1,s6
    80004b22:	4789                	li	a5,2
    80004b24:	02f59563          	bne	a1,a5,80004b4e <create+0x78>
    80004b28:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdbe474>
    80004b2c:	37f9                	addiw	a5,a5,-2
    80004b2e:	17c2                	slli	a5,a5,0x30
    80004b30:	93c1                	srli	a5,a5,0x30
    80004b32:	4705                	li	a4,1
    80004b34:	00f76d63          	bltu	a4,a5,80004b4e <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b38:	8556                	mv	a0,s5
    80004b3a:	60a6                	ld	ra,72(sp)
    80004b3c:	6406                	ld	s0,64(sp)
    80004b3e:	74e2                	ld	s1,56(sp)
    80004b40:	7942                	ld	s2,48(sp)
    80004b42:	79a2                	ld	s3,40(sp)
    80004b44:	7a02                	ld	s4,32(sp)
    80004b46:	6ae2                	ld	s5,24(sp)
    80004b48:	6b42                	ld	s6,16(sp)
    80004b4a:	6161                	addi	sp,sp,80
    80004b4c:	8082                	ret
    iunlockput(ip);
    80004b4e:	8556                	mv	a0,s5
    80004b50:	a07fe0ef          	jal	ra,80003556 <iunlockput>
    return 0;
    80004b54:	4a81                	li	s5,0
    80004b56:	b7cd                	j	80004b38 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b58:	85da                	mv	a1,s6
    80004b5a:	4088                	lw	a0,0(s1)
    80004b5c:	e8afe0ef          	jal	ra,800031e6 <ialloc>
    80004b60:	8a2a                	mv	s4,a0
    80004b62:	cd1d                	beqz	a0,80004ba0 <create+0xca>
  ilock(ip);
    80004b64:	fecfe0ef          	jal	ra,80003350 <ilock>
  ip->major = major;
    80004b68:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b6c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b70:	4905                	li	s2,1
    80004b72:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b76:	8552                	mv	a0,s4
    80004b78:	f24fe0ef          	jal	ra,8000329c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b7c:	000b059b          	sext.w	a1,s6
    80004b80:	03258563          	beq	a1,s2,80004baa <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b84:	004a2603          	lw	a2,4(s4)
    80004b88:	fb040593          	addi	a1,s0,-80
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	f1dfe0ef          	jal	ra,80003aaa <dirlink>
    80004b92:	06054363          	bltz	a0,80004bf8 <create+0x122>
  iunlockput(dp);
    80004b96:	8526                	mv	a0,s1
    80004b98:	9bffe0ef          	jal	ra,80003556 <iunlockput>
  return ip;
    80004b9c:	8ad2                	mv	s5,s4
    80004b9e:	bf69                	j	80004b38 <create+0x62>
    iunlockput(dp);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	9b5fe0ef          	jal	ra,80003556 <iunlockput>
    return 0;
    80004ba6:	8ad2                	mv	s5,s4
    80004ba8:	bf41                	j	80004b38 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004baa:	004a2603          	lw	a2,4(s4)
    80004bae:	00003597          	auipc	a1,0x3
    80004bb2:	b4a58593          	addi	a1,a1,-1206 # 800076f8 <syscalls+0x2e0>
    80004bb6:	8552                	mv	a0,s4
    80004bb8:	ef3fe0ef          	jal	ra,80003aaa <dirlink>
    80004bbc:	02054e63          	bltz	a0,80004bf8 <create+0x122>
    80004bc0:	40d0                	lw	a2,4(s1)
    80004bc2:	00003597          	auipc	a1,0x3
    80004bc6:	b3e58593          	addi	a1,a1,-1218 # 80007700 <syscalls+0x2e8>
    80004bca:	8552                	mv	a0,s4
    80004bcc:	edffe0ef          	jal	ra,80003aaa <dirlink>
    80004bd0:	02054463          	bltz	a0,80004bf8 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bd4:	004a2603          	lw	a2,4(s4)
    80004bd8:	fb040593          	addi	a1,s0,-80
    80004bdc:	8526                	mv	a0,s1
    80004bde:	ecdfe0ef          	jal	ra,80003aaa <dirlink>
    80004be2:	00054b63          	bltz	a0,80004bf8 <create+0x122>
    dp->nlink++;  // for ".."
    80004be6:	04a4d783          	lhu	a5,74(s1)
    80004bea:	2785                	addiw	a5,a5,1
    80004bec:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	eaafe0ef          	jal	ra,8000329c <iupdate>
    80004bf6:	b745                	j	80004b96 <create+0xc0>
  ip->nlink = 0;
    80004bf8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004bfc:	8552                	mv	a0,s4
    80004bfe:	e9efe0ef          	jal	ra,8000329c <iupdate>
  iunlockput(ip);
    80004c02:	8552                	mv	a0,s4
    80004c04:	953fe0ef          	jal	ra,80003556 <iunlockput>
  iunlockput(dp);
    80004c08:	8526                	mv	a0,s1
    80004c0a:	94dfe0ef          	jal	ra,80003556 <iunlockput>
  return 0;
    80004c0e:	b72d                	j	80004b38 <create+0x62>
    return 0;
    80004c10:	8aaa                	mv	s5,a0
    80004c12:	b71d                	j	80004b38 <create+0x62>

0000000080004c14 <sys_dup>:
{
    80004c14:	7179                	addi	sp,sp,-48
    80004c16:	f406                	sd	ra,40(sp)
    80004c18:	f022                	sd	s0,32(sp)
    80004c1a:	ec26                	sd	s1,24(sp)
    80004c1c:	e84a                	sd	s2,16(sp)
    80004c1e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c20:	fd840613          	addi	a2,s0,-40
    80004c24:	4581                	li	a1,0
    80004c26:	4501                	li	a0,0
    80004c28:	e19ff0ef          	jal	ra,80004a40 <argfd>
    return -1;
    80004c2c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c2e:	00054f63          	bltz	a0,80004c4c <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80004c32:	fd843903          	ld	s2,-40(s0)
    80004c36:	854a                	mv	a0,s2
    80004c38:	e61ff0ef          	jal	ra,80004a98 <fdalloc>
    80004c3c:	84aa                	mv	s1,a0
    return -1;
    80004c3e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c40:	00054663          	bltz	a0,80004c4c <sys_dup+0x38>
  filedup(f);
    80004c44:	854a                	mv	a0,s2
    80004c46:	cb6ff0ef          	jal	ra,800040fc <filedup>
  return fd;
    80004c4a:	87a6                	mv	a5,s1
}
    80004c4c:	853e                	mv	a0,a5
    80004c4e:	70a2                	ld	ra,40(sp)
    80004c50:	7402                	ld	s0,32(sp)
    80004c52:	64e2                	ld	s1,24(sp)
    80004c54:	6942                	ld	s2,16(sp)
    80004c56:	6145                	addi	sp,sp,48
    80004c58:	8082                	ret

0000000080004c5a <sys_read>:
{
    80004c5a:	7179                	addi	sp,sp,-48
    80004c5c:	f406                	sd	ra,40(sp)
    80004c5e:	f022                	sd	s0,32(sp)
    80004c60:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c62:	fd840593          	addi	a1,s0,-40
    80004c66:	4505                	li	a0,1
    80004c68:	d1ffd0ef          	jal	ra,80002986 <argaddr>
  argint(2, &n);
    80004c6c:	fe440593          	addi	a1,s0,-28
    80004c70:	4509                	li	a0,2
    80004c72:	cf9fd0ef          	jal	ra,8000296a <argint>
  if(argfd(0, 0, &f) < 0)
    80004c76:	fe840613          	addi	a2,s0,-24
    80004c7a:	4581                	li	a1,0
    80004c7c:	4501                	li	a0,0
    80004c7e:	dc3ff0ef          	jal	ra,80004a40 <argfd>
    80004c82:	87aa                	mv	a5,a0
    return -1;
    80004c84:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c86:	0007ca63          	bltz	a5,80004c9a <sys_read+0x40>
  return fileread(f, p, n);
    80004c8a:	fe442603          	lw	a2,-28(s0)
    80004c8e:	fd843583          	ld	a1,-40(s0)
    80004c92:	fe843503          	ld	a0,-24(s0)
    80004c96:	db2ff0ef          	jal	ra,80004248 <fileread>
}
    80004c9a:	70a2                	ld	ra,40(sp)
    80004c9c:	7402                	ld	s0,32(sp)
    80004c9e:	6145                	addi	sp,sp,48
    80004ca0:	8082                	ret

0000000080004ca2 <sys_write>:
{
    80004ca2:	7179                	addi	sp,sp,-48
    80004ca4:	f406                	sd	ra,40(sp)
    80004ca6:	f022                	sd	s0,32(sp)
    80004ca8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004caa:	fd840593          	addi	a1,s0,-40
    80004cae:	4505                	li	a0,1
    80004cb0:	cd7fd0ef          	jal	ra,80002986 <argaddr>
  argint(2, &n);
    80004cb4:	fe440593          	addi	a1,s0,-28
    80004cb8:	4509                	li	a0,2
    80004cba:	cb1fd0ef          	jal	ra,8000296a <argint>
  if(argfd(0, 0, &f) < 0)
    80004cbe:	fe840613          	addi	a2,s0,-24
    80004cc2:	4581                	li	a1,0
    80004cc4:	4501                	li	a0,0
    80004cc6:	d7bff0ef          	jal	ra,80004a40 <argfd>
    80004cca:	87aa                	mv	a5,a0
    return -1;
    80004ccc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cce:	0007ca63          	bltz	a5,80004ce2 <sys_write+0x40>
  return filewrite(f, p, n);
    80004cd2:	fe442603          	lw	a2,-28(s0)
    80004cd6:	fd843583          	ld	a1,-40(s0)
    80004cda:	fe843503          	ld	a0,-24(s0)
    80004cde:	e18ff0ef          	jal	ra,800042f6 <filewrite>
}
    80004ce2:	70a2                	ld	ra,40(sp)
    80004ce4:	7402                	ld	s0,32(sp)
    80004ce6:	6145                	addi	sp,sp,48
    80004ce8:	8082                	ret

0000000080004cea <sys_close>:
{
    80004cea:	1101                	addi	sp,sp,-32
    80004cec:	ec06                	sd	ra,24(sp)
    80004cee:	e822                	sd	s0,16(sp)
    80004cf0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004cf2:	fe040613          	addi	a2,s0,-32
    80004cf6:	fec40593          	addi	a1,s0,-20
    80004cfa:	4501                	li	a0,0
    80004cfc:	d45ff0ef          	jal	ra,80004a40 <argfd>
    return -1;
    80004d00:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d02:	02054063          	bltz	a0,80004d22 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d06:	d2ffc0ef          	jal	ra,80001a34 <myproc>
    80004d0a:	fec42783          	lw	a5,-20(s0)
    80004d0e:	07e9                	addi	a5,a5,26
    80004d10:	078e                	slli	a5,a5,0x3
    80004d12:	953e                	add	a0,a0,a5
    80004d14:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d18:	fe043503          	ld	a0,-32(s0)
    80004d1c:	c26ff0ef          	jal	ra,80004142 <fileclose>
  return 0;
    80004d20:	4781                	li	a5,0
}
    80004d22:	853e                	mv	a0,a5
    80004d24:	60e2                	ld	ra,24(sp)
    80004d26:	6442                	ld	s0,16(sp)
    80004d28:	6105                	addi	sp,sp,32
    80004d2a:	8082                	ret

0000000080004d2c <sys_fstat>:
{
    80004d2c:	1101                	addi	sp,sp,-32
    80004d2e:	ec06                	sd	ra,24(sp)
    80004d30:	e822                	sd	s0,16(sp)
    80004d32:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d34:	fe040593          	addi	a1,s0,-32
    80004d38:	4505                	li	a0,1
    80004d3a:	c4dfd0ef          	jal	ra,80002986 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d3e:	fe840613          	addi	a2,s0,-24
    80004d42:	4581                	li	a1,0
    80004d44:	4501                	li	a0,0
    80004d46:	cfbff0ef          	jal	ra,80004a40 <argfd>
    80004d4a:	87aa                	mv	a5,a0
    return -1;
    80004d4c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d4e:	0007c863          	bltz	a5,80004d5e <sys_fstat+0x32>
  return filestat(f, st);
    80004d52:	fe043583          	ld	a1,-32(s0)
    80004d56:	fe843503          	ld	a0,-24(s0)
    80004d5a:	c90ff0ef          	jal	ra,800041ea <filestat>
}
    80004d5e:	60e2                	ld	ra,24(sp)
    80004d60:	6442                	ld	s0,16(sp)
    80004d62:	6105                	addi	sp,sp,32
    80004d64:	8082                	ret

0000000080004d66 <sys_link>:
{
    80004d66:	7169                	addi	sp,sp,-304
    80004d68:	f606                	sd	ra,296(sp)
    80004d6a:	f222                	sd	s0,288(sp)
    80004d6c:	ee26                	sd	s1,280(sp)
    80004d6e:	ea4a                	sd	s2,272(sp)
    80004d70:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d72:	08000613          	li	a2,128
    80004d76:	ed040593          	addi	a1,s0,-304
    80004d7a:	4501                	li	a0,0
    80004d7c:	c27fd0ef          	jal	ra,800029a2 <argstr>
    return -1;
    80004d80:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d82:	0c054663          	bltz	a0,80004e4e <sys_link+0xe8>
    80004d86:	08000613          	li	a2,128
    80004d8a:	f5040593          	addi	a1,s0,-176
    80004d8e:	4505                	li	a0,1
    80004d90:	c13fd0ef          	jal	ra,800029a2 <argstr>
    return -1;
    80004d94:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d96:	0a054c63          	bltz	a0,80004e4e <sys_link+0xe8>
  begin_op();
    80004d9a:	f9ffe0ef          	jal	ra,80003d38 <begin_op>
  if((ip = namei(old)) == 0){
    80004d9e:	ed040513          	addi	a0,s0,-304
    80004da2:	da3fe0ef          	jal	ra,80003b44 <namei>
    80004da6:	84aa                	mv	s1,a0
    80004da8:	c525                	beqz	a0,80004e10 <sys_link+0xaa>
  ilock(ip);
    80004daa:	da6fe0ef          	jal	ra,80003350 <ilock>
  if(ip->type == T_DIR){
    80004dae:	04449703          	lh	a4,68(s1)
    80004db2:	4785                	li	a5,1
    80004db4:	06f70263          	beq	a4,a5,80004e18 <sys_link+0xb2>
  ip->nlink++;
    80004db8:	04a4d783          	lhu	a5,74(s1)
    80004dbc:	2785                	addiw	a5,a5,1
    80004dbe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	cd8fe0ef          	jal	ra,8000329c <iupdate>
  iunlock(ip);
    80004dc8:	8526                	mv	a0,s1
    80004dca:	e30fe0ef          	jal	ra,800033fa <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004dce:	fd040593          	addi	a1,s0,-48
    80004dd2:	f5040513          	addi	a0,s0,-176
    80004dd6:	d89fe0ef          	jal	ra,80003b5e <nameiparent>
    80004dda:	892a                	mv	s2,a0
    80004ddc:	c921                	beqz	a0,80004e2c <sys_link+0xc6>
  ilock(dp);
    80004dde:	d72fe0ef          	jal	ra,80003350 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004de2:	00092703          	lw	a4,0(s2)
    80004de6:	409c                	lw	a5,0(s1)
    80004de8:	02f71f63          	bne	a4,a5,80004e26 <sys_link+0xc0>
    80004dec:	40d0                	lw	a2,4(s1)
    80004dee:	fd040593          	addi	a1,s0,-48
    80004df2:	854a                	mv	a0,s2
    80004df4:	cb7fe0ef          	jal	ra,80003aaa <dirlink>
    80004df8:	02054763          	bltz	a0,80004e26 <sys_link+0xc0>
  iunlockput(dp);
    80004dfc:	854a                	mv	a0,s2
    80004dfe:	f58fe0ef          	jal	ra,80003556 <iunlockput>
  iput(ip);
    80004e02:	8526                	mv	a0,s1
    80004e04:	ecafe0ef          	jal	ra,800034ce <iput>
  end_op();
    80004e08:	f9ffe0ef          	jal	ra,80003da6 <end_op>
  return 0;
    80004e0c:	4781                	li	a5,0
    80004e0e:	a081                	j	80004e4e <sys_link+0xe8>
    end_op();
    80004e10:	f97fe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    80004e14:	57fd                	li	a5,-1
    80004e16:	a825                	j	80004e4e <sys_link+0xe8>
    iunlockput(ip);
    80004e18:	8526                	mv	a0,s1
    80004e1a:	f3cfe0ef          	jal	ra,80003556 <iunlockput>
    end_op();
    80004e1e:	f89fe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    80004e22:	57fd                	li	a5,-1
    80004e24:	a02d                	j	80004e4e <sys_link+0xe8>
    iunlockput(dp);
    80004e26:	854a                	mv	a0,s2
    80004e28:	f2efe0ef          	jal	ra,80003556 <iunlockput>
  ilock(ip);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	d22fe0ef          	jal	ra,80003350 <ilock>
  ip->nlink--;
    80004e32:	04a4d783          	lhu	a5,74(s1)
    80004e36:	37fd                	addiw	a5,a5,-1
    80004e38:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e3c:	8526                	mv	a0,s1
    80004e3e:	c5efe0ef          	jal	ra,8000329c <iupdate>
  iunlockput(ip);
    80004e42:	8526                	mv	a0,s1
    80004e44:	f12fe0ef          	jal	ra,80003556 <iunlockput>
  end_op();
    80004e48:	f5ffe0ef          	jal	ra,80003da6 <end_op>
  return -1;
    80004e4c:	57fd                	li	a5,-1
}
    80004e4e:	853e                	mv	a0,a5
    80004e50:	70b2                	ld	ra,296(sp)
    80004e52:	7412                	ld	s0,288(sp)
    80004e54:	64f2                	ld	s1,280(sp)
    80004e56:	6952                	ld	s2,272(sp)
    80004e58:	6155                	addi	sp,sp,304
    80004e5a:	8082                	ret

0000000080004e5c <sys_unlink>:
{
    80004e5c:	7151                	addi	sp,sp,-240
    80004e5e:	f586                	sd	ra,232(sp)
    80004e60:	f1a2                	sd	s0,224(sp)
    80004e62:	eda6                	sd	s1,216(sp)
    80004e64:	e9ca                	sd	s2,208(sp)
    80004e66:	e5ce                	sd	s3,200(sp)
    80004e68:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e6a:	08000613          	li	a2,128
    80004e6e:	f3040593          	addi	a1,s0,-208
    80004e72:	4501                	li	a0,0
    80004e74:	b2ffd0ef          	jal	ra,800029a2 <argstr>
    80004e78:	12054b63          	bltz	a0,80004fae <sys_unlink+0x152>
  begin_op();
    80004e7c:	ebdfe0ef          	jal	ra,80003d38 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e80:	fb040593          	addi	a1,s0,-80
    80004e84:	f3040513          	addi	a0,s0,-208
    80004e88:	cd7fe0ef          	jal	ra,80003b5e <nameiparent>
    80004e8c:	84aa                	mv	s1,a0
    80004e8e:	c54d                	beqz	a0,80004f38 <sys_unlink+0xdc>
  ilock(dp);
    80004e90:	cc0fe0ef          	jal	ra,80003350 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e94:	00003597          	auipc	a1,0x3
    80004e98:	86458593          	addi	a1,a1,-1948 # 800076f8 <syscalls+0x2e0>
    80004e9c:	fb040513          	addi	a0,s0,-80
    80004ea0:	a23fe0ef          	jal	ra,800038c2 <namecmp>
    80004ea4:	10050a63          	beqz	a0,80004fb8 <sys_unlink+0x15c>
    80004ea8:	00003597          	auipc	a1,0x3
    80004eac:	85858593          	addi	a1,a1,-1960 # 80007700 <syscalls+0x2e8>
    80004eb0:	fb040513          	addi	a0,s0,-80
    80004eb4:	a0ffe0ef          	jal	ra,800038c2 <namecmp>
    80004eb8:	10050063          	beqz	a0,80004fb8 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004ebc:	f2c40613          	addi	a2,s0,-212
    80004ec0:	fb040593          	addi	a1,s0,-80
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	a13fe0ef          	jal	ra,800038d8 <dirlookup>
    80004eca:	892a                	mv	s2,a0
    80004ecc:	0e050663          	beqz	a0,80004fb8 <sys_unlink+0x15c>
  ilock(ip);
    80004ed0:	c80fe0ef          	jal	ra,80003350 <ilock>
  if(ip->nlink < 1)
    80004ed4:	04a91783          	lh	a5,74(s2)
    80004ed8:	06f05463          	blez	a5,80004f40 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004edc:	04491703          	lh	a4,68(s2)
    80004ee0:	4785                	li	a5,1
    80004ee2:	06f70563          	beq	a4,a5,80004f4c <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004ee6:	4641                	li	a2,16
    80004ee8:	4581                	li	a1,0
    80004eea:	fc040513          	addi	a0,s0,-64
    80004eee:	e87fb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ef2:	4741                	li	a4,16
    80004ef4:	f2c42683          	lw	a3,-212(s0)
    80004ef8:	fc040613          	addi	a2,s0,-64
    80004efc:	4581                	li	a1,0
    80004efe:	8526                	mv	a0,s1
    80004f00:	8c1fe0ef          	jal	ra,800037c0 <writei>
    80004f04:	47c1                	li	a5,16
    80004f06:	08f51563          	bne	a0,a5,80004f90 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004f0a:	04491703          	lh	a4,68(s2)
    80004f0e:	4785                	li	a5,1
    80004f10:	08f70663          	beq	a4,a5,80004f9c <sys_unlink+0x140>
  iunlockput(dp);
    80004f14:	8526                	mv	a0,s1
    80004f16:	e40fe0ef          	jal	ra,80003556 <iunlockput>
  ip->nlink--;
    80004f1a:	04a95783          	lhu	a5,74(s2)
    80004f1e:	37fd                	addiw	a5,a5,-1
    80004f20:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f24:	854a                	mv	a0,s2
    80004f26:	b76fe0ef          	jal	ra,8000329c <iupdate>
  iunlockput(ip);
    80004f2a:	854a                	mv	a0,s2
    80004f2c:	e2afe0ef          	jal	ra,80003556 <iunlockput>
  end_op();
    80004f30:	e77fe0ef          	jal	ra,80003da6 <end_op>
  return 0;
    80004f34:	4501                	li	a0,0
    80004f36:	a079                	j	80004fc4 <sys_unlink+0x168>
    end_op();
    80004f38:	e6ffe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    80004f3c:	557d                	li	a0,-1
    80004f3e:	a059                	j	80004fc4 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f40:	00002517          	auipc	a0,0x2
    80004f44:	7c850513          	addi	a0,a0,1992 # 80007708 <syscalls+0x2f0>
    80004f48:	841fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f4c:	04c92703          	lw	a4,76(s2)
    80004f50:	02000793          	li	a5,32
    80004f54:	f8e7f9e3          	bgeu	a5,a4,80004ee6 <sys_unlink+0x8a>
    80004f58:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f5c:	4741                	li	a4,16
    80004f5e:	86ce                	mv	a3,s3
    80004f60:	f1840613          	addi	a2,s0,-232
    80004f64:	4581                	li	a1,0
    80004f66:	854a                	mv	a0,s2
    80004f68:	f74fe0ef          	jal	ra,800036dc <readi>
    80004f6c:	47c1                	li	a5,16
    80004f6e:	00f51b63          	bne	a0,a5,80004f84 <sys_unlink+0x128>
    if(de.inum != 0)
    80004f72:	f1845783          	lhu	a5,-232(s0)
    80004f76:	ef95                	bnez	a5,80004fb2 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f78:	29c1                	addiw	s3,s3,16
    80004f7a:	04c92783          	lw	a5,76(s2)
    80004f7e:	fcf9efe3          	bltu	s3,a5,80004f5c <sys_unlink+0x100>
    80004f82:	b795                	j	80004ee6 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004f84:	00002517          	auipc	a0,0x2
    80004f88:	79c50513          	addi	a0,a0,1948 # 80007720 <syscalls+0x308>
    80004f8c:	ffcfb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80004f90:	00002517          	auipc	a0,0x2
    80004f94:	7a850513          	addi	a0,a0,1960 # 80007738 <syscalls+0x320>
    80004f98:	ff0fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80004f9c:	04a4d783          	lhu	a5,74(s1)
    80004fa0:	37fd                	addiw	a5,a5,-1
    80004fa2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	af4fe0ef          	jal	ra,8000329c <iupdate>
    80004fac:	b7a5                	j	80004f14 <sys_unlink+0xb8>
    return -1;
    80004fae:	557d                	li	a0,-1
    80004fb0:	a811                	j	80004fc4 <sys_unlink+0x168>
    iunlockput(ip);
    80004fb2:	854a                	mv	a0,s2
    80004fb4:	da2fe0ef          	jal	ra,80003556 <iunlockput>
  iunlockput(dp);
    80004fb8:	8526                	mv	a0,s1
    80004fba:	d9cfe0ef          	jal	ra,80003556 <iunlockput>
  end_op();
    80004fbe:	de9fe0ef          	jal	ra,80003da6 <end_op>
  return -1;
    80004fc2:	557d                	li	a0,-1
}
    80004fc4:	70ae                	ld	ra,232(sp)
    80004fc6:	740e                	ld	s0,224(sp)
    80004fc8:	64ee                	ld	s1,216(sp)
    80004fca:	694e                	ld	s2,208(sp)
    80004fcc:	69ae                	ld	s3,200(sp)
    80004fce:	616d                	addi	sp,sp,240
    80004fd0:	8082                	ret

0000000080004fd2 <sys_open>:

uint64
sys_open(void)
{
    80004fd2:	7131                	addi	sp,sp,-192
    80004fd4:	fd06                	sd	ra,184(sp)
    80004fd6:	f922                	sd	s0,176(sp)
    80004fd8:	f526                	sd	s1,168(sp)
    80004fda:	f14a                	sd	s2,160(sp)
    80004fdc:	ed4e                	sd	s3,152(sp)
    80004fde:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004fe0:	f4c40593          	addi	a1,s0,-180
    80004fe4:	4505                	li	a0,1
    80004fe6:	985fd0ef          	jal	ra,8000296a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fea:	08000613          	li	a2,128
    80004fee:	f5040593          	addi	a1,s0,-176
    80004ff2:	4501                	li	a0,0
    80004ff4:	9affd0ef          	jal	ra,800029a2 <argstr>
    80004ff8:	87aa                	mv	a5,a0
    return -1;
    80004ffa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ffc:	0807cd63          	bltz	a5,80005096 <sys_open+0xc4>

  begin_op();
    80005000:	d39fe0ef          	jal	ra,80003d38 <begin_op>

  if(omode & O_CREATE){
    80005004:	f4c42783          	lw	a5,-180(s0)
    80005008:	2007f793          	andi	a5,a5,512
    8000500c:	c3c5                	beqz	a5,800050ac <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000500e:	4681                	li	a3,0
    80005010:	4601                	li	a2,0
    80005012:	4589                	li	a1,2
    80005014:	f5040513          	addi	a0,s0,-176
    80005018:	abfff0ef          	jal	ra,80004ad6 <create>
    8000501c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000501e:	c159                	beqz	a0,800050a4 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005020:	04449703          	lh	a4,68(s1)
    80005024:	478d                	li	a5,3
    80005026:	00f71763          	bne	a4,a5,80005034 <sys_open+0x62>
    8000502a:	0464d703          	lhu	a4,70(s1)
    8000502e:	47a5                	li	a5,9
    80005030:	0ae7e963          	bltu	a5,a4,800050e2 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005034:	86aff0ef          	jal	ra,8000409e <filealloc>
    80005038:	89aa                	mv	s3,a0
    8000503a:	0c050963          	beqz	a0,8000510c <sys_open+0x13a>
    8000503e:	a5bff0ef          	jal	ra,80004a98 <fdalloc>
    80005042:	892a                	mv	s2,a0
    80005044:	0c054163          	bltz	a0,80005106 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005048:	04449703          	lh	a4,68(s1)
    8000504c:	478d                	li	a5,3
    8000504e:	0af70163          	beq	a4,a5,800050f0 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005052:	4789                	li	a5,2
    80005054:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005058:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000505c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005060:	f4c42783          	lw	a5,-180(s0)
    80005064:	0017c713          	xori	a4,a5,1
    80005068:	8b05                	andi	a4,a4,1
    8000506a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000506e:	0037f713          	andi	a4,a5,3
    80005072:	00e03733          	snez	a4,a4
    80005076:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000507a:	4007f793          	andi	a5,a5,1024
    8000507e:	c791                	beqz	a5,8000508a <sys_open+0xb8>
    80005080:	04449703          	lh	a4,68(s1)
    80005084:	4789                	li	a5,2
    80005086:	06f70c63          	beq	a4,a5,800050fe <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000508a:	8526                	mv	a0,s1
    8000508c:	b6efe0ef          	jal	ra,800033fa <iunlock>
  end_op();
    80005090:	d17fe0ef          	jal	ra,80003da6 <end_op>

  return fd;
    80005094:	854a                	mv	a0,s2
}
    80005096:	70ea                	ld	ra,184(sp)
    80005098:	744a                	ld	s0,176(sp)
    8000509a:	74aa                	ld	s1,168(sp)
    8000509c:	790a                	ld	s2,160(sp)
    8000509e:	69ea                	ld	s3,152(sp)
    800050a0:	6129                	addi	sp,sp,192
    800050a2:	8082                	ret
      end_op();
    800050a4:	d03fe0ef          	jal	ra,80003da6 <end_op>
      return -1;
    800050a8:	557d                	li	a0,-1
    800050aa:	b7f5                	j	80005096 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800050ac:	f5040513          	addi	a0,s0,-176
    800050b0:	a95fe0ef          	jal	ra,80003b44 <namei>
    800050b4:	84aa                	mv	s1,a0
    800050b6:	c115                	beqz	a0,800050da <sys_open+0x108>
    ilock(ip);
    800050b8:	a98fe0ef          	jal	ra,80003350 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050bc:	04449703          	lh	a4,68(s1)
    800050c0:	4785                	li	a5,1
    800050c2:	f4f71fe3          	bne	a4,a5,80005020 <sys_open+0x4e>
    800050c6:	f4c42783          	lw	a5,-180(s0)
    800050ca:	d7ad                	beqz	a5,80005034 <sys_open+0x62>
      iunlockput(ip);
    800050cc:	8526                	mv	a0,s1
    800050ce:	c88fe0ef          	jal	ra,80003556 <iunlockput>
      end_op();
    800050d2:	cd5fe0ef          	jal	ra,80003da6 <end_op>
      return -1;
    800050d6:	557d                	li	a0,-1
    800050d8:	bf7d                	j	80005096 <sys_open+0xc4>
      end_op();
    800050da:	ccdfe0ef          	jal	ra,80003da6 <end_op>
      return -1;
    800050de:	557d                	li	a0,-1
    800050e0:	bf5d                	j	80005096 <sys_open+0xc4>
    iunlockput(ip);
    800050e2:	8526                	mv	a0,s1
    800050e4:	c72fe0ef          	jal	ra,80003556 <iunlockput>
    end_op();
    800050e8:	cbffe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    800050ec:	557d                	li	a0,-1
    800050ee:	b765                	j	80005096 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800050f0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800050f4:	04649783          	lh	a5,70(s1)
    800050f8:	02f99223          	sh	a5,36(s3)
    800050fc:	b785                	j	8000505c <sys_open+0x8a>
    itrunc(ip);
    800050fe:	8526                	mv	a0,s1
    80005100:	b3afe0ef          	jal	ra,8000343a <itrunc>
    80005104:	b759                	j	8000508a <sys_open+0xb8>
      fileclose(f);
    80005106:	854e                	mv	a0,s3
    80005108:	83aff0ef          	jal	ra,80004142 <fileclose>
    iunlockput(ip);
    8000510c:	8526                	mv	a0,s1
    8000510e:	c48fe0ef          	jal	ra,80003556 <iunlockput>
    end_op();
    80005112:	c95fe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    80005116:	557d                	li	a0,-1
    80005118:	bfbd                	j	80005096 <sys_open+0xc4>

000000008000511a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000511a:	7175                	addi	sp,sp,-144
    8000511c:	e506                	sd	ra,136(sp)
    8000511e:	e122                	sd	s0,128(sp)
    80005120:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005122:	c17fe0ef          	jal	ra,80003d38 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005126:	08000613          	li	a2,128
    8000512a:	f7040593          	addi	a1,s0,-144
    8000512e:	4501                	li	a0,0
    80005130:	873fd0ef          	jal	ra,800029a2 <argstr>
    80005134:	02054363          	bltz	a0,8000515a <sys_mkdir+0x40>
    80005138:	4681                	li	a3,0
    8000513a:	4601                	li	a2,0
    8000513c:	4585                	li	a1,1
    8000513e:	f7040513          	addi	a0,s0,-144
    80005142:	995ff0ef          	jal	ra,80004ad6 <create>
    80005146:	c911                	beqz	a0,8000515a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005148:	c0efe0ef          	jal	ra,80003556 <iunlockput>
  end_op();
    8000514c:	c5bfe0ef          	jal	ra,80003da6 <end_op>
  return 0;
    80005150:	4501                	li	a0,0
}
    80005152:	60aa                	ld	ra,136(sp)
    80005154:	640a                	ld	s0,128(sp)
    80005156:	6149                	addi	sp,sp,144
    80005158:	8082                	ret
    end_op();
    8000515a:	c4dfe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    8000515e:	557d                	li	a0,-1
    80005160:	bfcd                	j	80005152 <sys_mkdir+0x38>

0000000080005162 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005162:	7135                	addi	sp,sp,-160
    80005164:	ed06                	sd	ra,152(sp)
    80005166:	e922                	sd	s0,144(sp)
    80005168:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000516a:	bcffe0ef          	jal	ra,80003d38 <begin_op>
  argint(1, &major);
    8000516e:	f6c40593          	addi	a1,s0,-148
    80005172:	4505                	li	a0,1
    80005174:	ff6fd0ef          	jal	ra,8000296a <argint>
  argint(2, &minor);
    80005178:	f6840593          	addi	a1,s0,-152
    8000517c:	4509                	li	a0,2
    8000517e:	fecfd0ef          	jal	ra,8000296a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005182:	08000613          	li	a2,128
    80005186:	f7040593          	addi	a1,s0,-144
    8000518a:	4501                	li	a0,0
    8000518c:	817fd0ef          	jal	ra,800029a2 <argstr>
    80005190:	02054563          	bltz	a0,800051ba <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005194:	f6841683          	lh	a3,-152(s0)
    80005198:	f6c41603          	lh	a2,-148(s0)
    8000519c:	458d                	li	a1,3
    8000519e:	f7040513          	addi	a0,s0,-144
    800051a2:	935ff0ef          	jal	ra,80004ad6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051a6:	c911                	beqz	a0,800051ba <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051a8:	baefe0ef          	jal	ra,80003556 <iunlockput>
  end_op();
    800051ac:	bfbfe0ef          	jal	ra,80003da6 <end_op>
  return 0;
    800051b0:	4501                	li	a0,0
}
    800051b2:	60ea                	ld	ra,152(sp)
    800051b4:	644a                	ld	s0,144(sp)
    800051b6:	610d                	addi	sp,sp,160
    800051b8:	8082                	ret
    end_op();
    800051ba:	bedfe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    800051be:	557d                	li	a0,-1
    800051c0:	bfcd                	j	800051b2 <sys_mknod+0x50>

00000000800051c2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800051c2:	7135                	addi	sp,sp,-160
    800051c4:	ed06                	sd	ra,152(sp)
    800051c6:	e922                	sd	s0,144(sp)
    800051c8:	e526                	sd	s1,136(sp)
    800051ca:	e14a                	sd	s2,128(sp)
    800051cc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051ce:	867fc0ef          	jal	ra,80001a34 <myproc>
    800051d2:	892a                	mv	s2,a0
  
  begin_op();
    800051d4:	b65fe0ef          	jal	ra,80003d38 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800051d8:	08000613          	li	a2,128
    800051dc:	f6040593          	addi	a1,s0,-160
    800051e0:	4501                	li	a0,0
    800051e2:	fc0fd0ef          	jal	ra,800029a2 <argstr>
    800051e6:	04054163          	bltz	a0,80005228 <sys_chdir+0x66>
    800051ea:	f6040513          	addi	a0,s0,-160
    800051ee:	957fe0ef          	jal	ra,80003b44 <namei>
    800051f2:	84aa                	mv	s1,a0
    800051f4:	c915                	beqz	a0,80005228 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800051f6:	95afe0ef          	jal	ra,80003350 <ilock>
  if(ip->type != T_DIR){
    800051fa:	04449703          	lh	a4,68(s1)
    800051fe:	4785                	li	a5,1
    80005200:	02f71863          	bne	a4,a5,80005230 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005204:	8526                	mv	a0,s1
    80005206:	9f4fe0ef          	jal	ra,800033fa <iunlock>
  iput(p->cwd);
    8000520a:	15093503          	ld	a0,336(s2)
    8000520e:	ac0fe0ef          	jal	ra,800034ce <iput>
  end_op();
    80005212:	b95fe0ef          	jal	ra,80003da6 <end_op>
  p->cwd = ip;
    80005216:	14993823          	sd	s1,336(s2)
  return 0;
    8000521a:	4501                	li	a0,0
}
    8000521c:	60ea                	ld	ra,152(sp)
    8000521e:	644a                	ld	s0,144(sp)
    80005220:	64aa                	ld	s1,136(sp)
    80005222:	690a                	ld	s2,128(sp)
    80005224:	610d                	addi	sp,sp,160
    80005226:	8082                	ret
    end_op();
    80005228:	b7ffe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    8000522c:	557d                	li	a0,-1
    8000522e:	b7fd                	j	8000521c <sys_chdir+0x5a>
    iunlockput(ip);
    80005230:	8526                	mv	a0,s1
    80005232:	b24fe0ef          	jal	ra,80003556 <iunlockput>
    end_op();
    80005236:	b71fe0ef          	jal	ra,80003da6 <end_op>
    return -1;
    8000523a:	557d                	li	a0,-1
    8000523c:	b7c5                	j	8000521c <sys_chdir+0x5a>

000000008000523e <sys_exec>:

uint64
sys_exec(void)
{
    8000523e:	7145                	addi	sp,sp,-464
    80005240:	e786                	sd	ra,456(sp)
    80005242:	e3a2                	sd	s0,448(sp)
    80005244:	ff26                	sd	s1,440(sp)
    80005246:	fb4a                	sd	s2,432(sp)
    80005248:	f74e                	sd	s3,424(sp)
    8000524a:	f352                	sd	s4,416(sp)
    8000524c:	ef56                	sd	s5,408(sp)
    8000524e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005250:	e3840593          	addi	a1,s0,-456
    80005254:	4505                	li	a0,1
    80005256:	f30fd0ef          	jal	ra,80002986 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000525a:	08000613          	li	a2,128
    8000525e:	f4040593          	addi	a1,s0,-192
    80005262:	4501                	li	a0,0
    80005264:	f3efd0ef          	jal	ra,800029a2 <argstr>
    80005268:	87aa                	mv	a5,a0
    return -1;
    8000526a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000526c:	0a07c563          	bltz	a5,80005316 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005270:	10000613          	li	a2,256
    80005274:	4581                	li	a1,0
    80005276:	e4040513          	addi	a0,s0,-448
    8000527a:	afbfb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000527e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005282:	89a6                	mv	s3,s1
    80005284:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005286:	02000a13          	li	s4,32
    8000528a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000528e:	00391513          	slli	a0,s2,0x3
    80005292:	e3040593          	addi	a1,s0,-464
    80005296:	e3843783          	ld	a5,-456(s0)
    8000529a:	953e                	add	a0,a0,a5
    8000529c:	e44fd0ef          	jal	ra,800028e0 <fetchaddr>
    800052a0:	02054663          	bltz	a0,800052cc <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800052a4:	e3043783          	ld	a5,-464(s0)
    800052a8:	cf8d                	beqz	a5,800052e2 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800052aa:	901fb0ef          	jal	ra,80000baa <kalloc>
    800052ae:	85aa                	mv	a1,a0
    800052b0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052b4:	cd01                	beqz	a0,800052cc <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052b6:	6605                	lui	a2,0x1
    800052b8:	e3043503          	ld	a0,-464(s0)
    800052bc:	e6efd0ef          	jal	ra,8000292a <fetchstr>
    800052c0:	00054663          	bltz	a0,800052cc <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800052c4:	0905                	addi	s2,s2,1
    800052c6:	09a1                	addi	s3,s3,8
    800052c8:	fd4911e3          	bne	s2,s4,8000528a <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052cc:	f4040913          	addi	s2,s0,-192
    800052d0:	6088                	ld	a0,0(s1)
    800052d2:	c129                	beqz	a0,80005314 <sys_exec+0xd6>
    kfree(argv[i]);
    800052d4:	fa6fb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052d8:	04a1                	addi	s1,s1,8
    800052da:	ff249be3          	bne	s1,s2,800052d0 <sys_exec+0x92>
  return -1;
    800052de:	557d                	li	a0,-1
    800052e0:	a81d                	j	80005316 <sys_exec+0xd8>
      argv[i] = 0;
    800052e2:	0a8e                	slli	s5,s5,0x3
    800052e4:	fc0a8793          	addi	a5,s5,-64
    800052e8:	00878ab3          	add	s5,a5,s0
    800052ec:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    800052f0:	e4040593          	addi	a1,s0,-448
    800052f4:	f4040513          	addi	a0,s0,-192
    800052f8:	bf6ff0ef          	jal	ra,800046ee <kexec>
    800052fc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052fe:	f4040993          	addi	s3,s0,-192
    80005302:	6088                	ld	a0,0(s1)
    80005304:	c511                	beqz	a0,80005310 <sys_exec+0xd2>
    kfree(argv[i]);
    80005306:	f74fb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000530a:	04a1                	addi	s1,s1,8
    8000530c:	ff349be3          	bne	s1,s3,80005302 <sys_exec+0xc4>
  return ret;
    80005310:	854a                	mv	a0,s2
    80005312:	a011                	j	80005316 <sys_exec+0xd8>
  return -1;
    80005314:	557d                	li	a0,-1
}
    80005316:	60be                	ld	ra,456(sp)
    80005318:	641e                	ld	s0,448(sp)
    8000531a:	74fa                	ld	s1,440(sp)
    8000531c:	795a                	ld	s2,432(sp)
    8000531e:	79ba                	ld	s3,424(sp)
    80005320:	7a1a                	ld	s4,416(sp)
    80005322:	6afa                	ld	s5,408(sp)
    80005324:	6179                	addi	sp,sp,464
    80005326:	8082                	ret

0000000080005328 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005328:	7139                	addi	sp,sp,-64
    8000532a:	fc06                	sd	ra,56(sp)
    8000532c:	f822                	sd	s0,48(sp)
    8000532e:	f426                	sd	s1,40(sp)
    80005330:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005332:	f02fc0ef          	jal	ra,80001a34 <myproc>
    80005336:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005338:	fd840593          	addi	a1,s0,-40
    8000533c:	4501                	li	a0,0
    8000533e:	e48fd0ef          	jal	ra,80002986 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005342:	fc840593          	addi	a1,s0,-56
    80005346:	fd040513          	addi	a0,s0,-48
    8000534a:	8c4ff0ef          	jal	ra,8000440e <pipealloc>
    return -1;
    8000534e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005350:	0a054463          	bltz	a0,800053f8 <sys_pipe+0xd0>
  fd0 = -1;
    80005354:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005358:	fd043503          	ld	a0,-48(s0)
    8000535c:	f3cff0ef          	jal	ra,80004a98 <fdalloc>
    80005360:	fca42223          	sw	a0,-60(s0)
    80005364:	08054163          	bltz	a0,800053e6 <sys_pipe+0xbe>
    80005368:	fc843503          	ld	a0,-56(s0)
    8000536c:	f2cff0ef          	jal	ra,80004a98 <fdalloc>
    80005370:	fca42023          	sw	a0,-64(s0)
    80005374:	06054063          	bltz	a0,800053d4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005378:	4691                	li	a3,4
    8000537a:	fc440613          	addi	a2,s0,-60
    8000537e:	fd843583          	ld	a1,-40(s0)
    80005382:	68a8                	ld	a0,80(s1)
    80005384:	bdafc0ef          	jal	ra,8000175e <copyout>
    80005388:	00054e63          	bltz	a0,800053a4 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000538c:	4691                	li	a3,4
    8000538e:	fc040613          	addi	a2,s0,-64
    80005392:	fd843583          	ld	a1,-40(s0)
    80005396:	0591                	addi	a1,a1,4
    80005398:	68a8                	ld	a0,80(s1)
    8000539a:	bc4fc0ef          	jal	ra,8000175e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000539e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053a0:	04055c63          	bgez	a0,800053f8 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800053a4:	fc442783          	lw	a5,-60(s0)
    800053a8:	07e9                	addi	a5,a5,26
    800053aa:	078e                	slli	a5,a5,0x3
    800053ac:	97a6                	add	a5,a5,s1
    800053ae:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053b2:	fc042783          	lw	a5,-64(s0)
    800053b6:	07e9                	addi	a5,a5,26
    800053b8:	078e                	slli	a5,a5,0x3
    800053ba:	94be                	add	s1,s1,a5
    800053bc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053c0:	fd043503          	ld	a0,-48(s0)
    800053c4:	d7ffe0ef          	jal	ra,80004142 <fileclose>
    fileclose(wf);
    800053c8:	fc843503          	ld	a0,-56(s0)
    800053cc:	d77fe0ef          	jal	ra,80004142 <fileclose>
    return -1;
    800053d0:	57fd                	li	a5,-1
    800053d2:	a01d                	j	800053f8 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053d4:	fc442783          	lw	a5,-60(s0)
    800053d8:	0007c763          	bltz	a5,800053e6 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800053dc:	07e9                	addi	a5,a5,26
    800053de:	078e                	slli	a5,a5,0x3
    800053e0:	97a6                	add	a5,a5,s1
    800053e2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800053e6:	fd043503          	ld	a0,-48(s0)
    800053ea:	d59fe0ef          	jal	ra,80004142 <fileclose>
    fileclose(wf);
    800053ee:	fc843503          	ld	a0,-56(s0)
    800053f2:	d51fe0ef          	jal	ra,80004142 <fileclose>
    return -1;
    800053f6:	57fd                	li	a5,-1
}
    800053f8:	853e                	mv	a0,a5
    800053fa:	70e2                	ld	ra,56(sp)
    800053fc:	7442                	ld	s0,48(sp)
    800053fe:	74a2                	ld	s1,40(sp)
    80005400:	6121                	addi	sp,sp,64
    80005402:	8082                	ret
	...

0000000080005410 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005410:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005412:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005414:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005416:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005418:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000541a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000541c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000541e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005420:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005422:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005424:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005426:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005428:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000542a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000542c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000542e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005430:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005432:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005434:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005436:	bbafd0ef          	jal	ra,800027f0 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000543a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000543c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000543e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005440:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005442:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005444:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005446:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005448:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000544a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000544c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000544e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005450:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005452:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005454:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005456:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005458:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000545a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000545c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000545e:	10200073          	sret
	...

000000008000546e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000546e:	1141                	addi	sp,sp,-16
    80005470:	e422                	sd	s0,8(sp)
    80005472:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005474:	0c0007b7          	lui	a5,0xc000
    80005478:	4705                	li	a4,1
    8000547a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000547c:	c3d8                	sw	a4,4(a5)
}
    8000547e:	6422                	ld	s0,8(sp)
    80005480:	0141                	addi	sp,sp,16
    80005482:	8082                	ret

0000000080005484 <plicinithart>:

void
plicinithart(void)
{
    80005484:	1141                	addi	sp,sp,-16
    80005486:	e406                	sd	ra,8(sp)
    80005488:	e022                	sd	s0,0(sp)
    8000548a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000548c:	d7cfc0ef          	jal	ra,80001a08 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005490:	0085171b          	slliw	a4,a0,0x8
    80005494:	0c0027b7          	lui	a5,0xc002
    80005498:	97ba                	add	a5,a5,a4
    8000549a:	40200713          	li	a4,1026
    8000549e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800054a2:	00d5151b          	slliw	a0,a0,0xd
    800054a6:	0c2017b7          	lui	a5,0xc201
    800054aa:	97aa                	add	a5,a5,a0
    800054ac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800054b0:	60a2                	ld	ra,8(sp)
    800054b2:	6402                	ld	s0,0(sp)
    800054b4:	0141                	addi	sp,sp,16
    800054b6:	8082                	ret

00000000800054b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054b8:	1141                	addi	sp,sp,-16
    800054ba:	e406                	sd	ra,8(sp)
    800054bc:	e022                	sd	s0,0(sp)
    800054be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054c0:	d48fc0ef          	jal	ra,80001a08 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054c4:	00d5151b          	slliw	a0,a0,0xd
    800054c8:	0c2017b7          	lui	a5,0xc201
    800054cc:	97aa                	add	a5,a5,a0
  return irq;
}
    800054ce:	43c8                	lw	a0,4(a5)
    800054d0:	60a2                	ld	ra,8(sp)
    800054d2:	6402                	ld	s0,0(sp)
    800054d4:	0141                	addi	sp,sp,16
    800054d6:	8082                	ret

00000000800054d8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054d8:	1101                	addi	sp,sp,-32
    800054da:	ec06                	sd	ra,24(sp)
    800054dc:	e822                	sd	s0,16(sp)
    800054de:	e426                	sd	s1,8(sp)
    800054e0:	1000                	addi	s0,sp,32
    800054e2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800054e4:	d24fc0ef          	jal	ra,80001a08 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800054e8:	00d5151b          	slliw	a0,a0,0xd
    800054ec:	0c2017b7          	lui	a5,0xc201
    800054f0:	97aa                	add	a5,a5,a0
    800054f2:	c3c4                	sw	s1,4(a5)
}
    800054f4:	60e2                	ld	ra,24(sp)
    800054f6:	6442                	ld	s0,16(sp)
    800054f8:	64a2                	ld	s1,8(sp)
    800054fa:	6105                	addi	sp,sp,32
    800054fc:	8082                	ret

00000000800054fe <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054fe:	1141                	addi	sp,sp,-16
    80005500:	e406                	sd	ra,8(sp)
    80005502:	e022                	sd	s0,0(sp)
    80005504:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005506:	479d                	li	a5,7
    80005508:	04a7ca63          	blt	a5,a0,8000555c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000550c:	0023b797          	auipc	a5,0x23b
    80005510:	58478793          	addi	a5,a5,1412 # 80240a90 <disk>
    80005514:	97aa                	add	a5,a5,a0
    80005516:	0187c783          	lbu	a5,24(a5)
    8000551a:	e7b9                	bnez	a5,80005568 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000551c:	00451693          	slli	a3,a0,0x4
    80005520:	0023b797          	auipc	a5,0x23b
    80005524:	57078793          	addi	a5,a5,1392 # 80240a90 <disk>
    80005528:	6398                	ld	a4,0(a5)
    8000552a:	9736                	add	a4,a4,a3
    8000552c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005530:	6398                	ld	a4,0(a5)
    80005532:	9736                	add	a4,a4,a3
    80005534:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005538:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000553c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005540:	97aa                	add	a5,a5,a0
    80005542:	4705                	li	a4,1
    80005544:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005548:	0023b517          	auipc	a0,0x23b
    8000554c:	56050513          	addi	a0,a0,1376 # 80240aa8 <disk+0x18>
    80005550:	b39fc0ef          	jal	ra,80002088 <wakeup>
}
    80005554:	60a2                	ld	ra,8(sp)
    80005556:	6402                	ld	s0,0(sp)
    80005558:	0141                	addi	sp,sp,16
    8000555a:	8082                	ret
    panic("free_desc 1");
    8000555c:	00002517          	auipc	a0,0x2
    80005560:	1ec50513          	addi	a0,a0,492 # 80007748 <syscalls+0x330>
    80005564:	a24fb0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005568:	00002517          	auipc	a0,0x2
    8000556c:	1f050513          	addi	a0,a0,496 # 80007758 <syscalls+0x340>
    80005570:	a18fb0ef          	jal	ra,80000788 <panic>

0000000080005574 <virtio_disk_init>:
{
    80005574:	1101                	addi	sp,sp,-32
    80005576:	ec06                	sd	ra,24(sp)
    80005578:	e822                	sd	s0,16(sp)
    8000557a:	e426                	sd	s1,8(sp)
    8000557c:	e04a                	sd	s2,0(sp)
    8000557e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005580:	00002597          	auipc	a1,0x2
    80005584:	1e858593          	addi	a1,a1,488 # 80007768 <syscalls+0x350>
    80005588:	0023b517          	auipc	a0,0x23b
    8000558c:	63050513          	addi	a0,a0,1584 # 80240bb8 <disk+0x128>
    80005590:	e90fb0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005594:	100017b7          	lui	a5,0x10001
    80005598:	4398                	lw	a4,0(a5)
    8000559a:	2701                	sext.w	a4,a4
    8000559c:	747277b7          	lui	a5,0x74727
    800055a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055a4:	12f71f63          	bne	a4,a5,800056e2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055a8:	100017b7          	lui	a5,0x10001
    800055ac:	43dc                	lw	a5,4(a5)
    800055ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055b0:	4709                	li	a4,2
    800055b2:	12e79863          	bne	a5,a4,800056e2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055b6:	100017b7          	lui	a5,0x10001
    800055ba:	479c                	lw	a5,8(a5)
    800055bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055be:	12e79263          	bne	a5,a4,800056e2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055c2:	100017b7          	lui	a5,0x10001
    800055c6:	47d8                	lw	a4,12(a5)
    800055c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055ca:	554d47b7          	lui	a5,0x554d4
    800055ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055d2:	10f71863          	bne	a4,a5,800056e2 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055d6:	100017b7          	lui	a5,0x10001
    800055da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055de:	4705                	li	a4,1
    800055e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055e2:	470d                	li	a4,3
    800055e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800055e6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055e8:	c7ffe6b7          	lui	a3,0xc7ffe
    800055ec:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47dbdb8f>
    800055f0:	8f75                	and	a4,a4,a3
    800055f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055f4:	472d                	li	a4,11
    800055f6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800055f8:	5bbc                	lw	a5,112(a5)
    800055fa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800055fe:	8ba1                	andi	a5,a5,8
    80005600:	0e078763          	beqz	a5,800056ee <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005604:	100017b7          	lui	a5,0x10001
    80005608:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000560c:	43fc                	lw	a5,68(a5)
    8000560e:	2781                	sext.w	a5,a5
    80005610:	0e079563          	bnez	a5,800056fa <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005614:	100017b7          	lui	a5,0x10001
    80005618:	5bdc                	lw	a5,52(a5)
    8000561a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000561c:	0e078563          	beqz	a5,80005706 <virtio_disk_init+0x192>
  if(max < NUM)
    80005620:	471d                	li	a4,7
    80005622:	0ef77863          	bgeu	a4,a5,80005712 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80005626:	d84fb0ef          	jal	ra,80000baa <kalloc>
    8000562a:	0023b497          	auipc	s1,0x23b
    8000562e:	46648493          	addi	s1,s1,1126 # 80240a90 <disk>
    80005632:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005634:	d76fb0ef          	jal	ra,80000baa <kalloc>
    80005638:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000563a:	d70fb0ef          	jal	ra,80000baa <kalloc>
    8000563e:	87aa                	mv	a5,a0
    80005640:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005642:	6088                	ld	a0,0(s1)
    80005644:	cd69                	beqz	a0,8000571e <virtio_disk_init+0x1aa>
    80005646:	0023b717          	auipc	a4,0x23b
    8000564a:	45273703          	ld	a4,1106(a4) # 80240a98 <disk+0x8>
    8000564e:	cb61                	beqz	a4,8000571e <virtio_disk_init+0x1aa>
    80005650:	c7f9                	beqz	a5,8000571e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005652:	6605                	lui	a2,0x1
    80005654:	4581                	li	a1,0
    80005656:	f1efb0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000565a:	0023b497          	auipc	s1,0x23b
    8000565e:	43648493          	addi	s1,s1,1078 # 80240a90 <disk>
    80005662:	6605                	lui	a2,0x1
    80005664:	4581                	li	a1,0
    80005666:	6488                	ld	a0,8(s1)
    80005668:	f0cfb0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    8000566c:	6605                	lui	a2,0x1
    8000566e:	4581                	li	a1,0
    80005670:	6888                	ld	a0,16(s1)
    80005672:	f02fb0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005676:	100017b7          	lui	a5,0x10001
    8000567a:	4721                	li	a4,8
    8000567c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000567e:	4098                	lw	a4,0(s1)
    80005680:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005684:	40d8                	lw	a4,4(s1)
    80005686:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000568a:	6498                	ld	a4,8(s1)
    8000568c:	0007069b          	sext.w	a3,a4
    80005690:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005694:	9701                	srai	a4,a4,0x20
    80005696:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000569a:	6898                	ld	a4,16(s1)
    8000569c:	0007069b          	sext.w	a3,a4
    800056a0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800056a4:	9701                	srai	a4,a4,0x20
    800056a6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800056aa:	4705                	li	a4,1
    800056ac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800056ae:	00e48c23          	sb	a4,24(s1)
    800056b2:	00e48ca3          	sb	a4,25(s1)
    800056b6:	00e48d23          	sb	a4,26(s1)
    800056ba:	00e48da3          	sb	a4,27(s1)
    800056be:	00e48e23          	sb	a4,28(s1)
    800056c2:	00e48ea3          	sb	a4,29(s1)
    800056c6:	00e48f23          	sb	a4,30(s1)
    800056ca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056ce:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056d2:	0727a823          	sw	s2,112(a5)
}
    800056d6:	60e2                	ld	ra,24(sp)
    800056d8:	6442                	ld	s0,16(sp)
    800056da:	64a2                	ld	s1,8(sp)
    800056dc:	6902                	ld	s2,0(sp)
    800056de:	6105                	addi	sp,sp,32
    800056e0:	8082                	ret
    panic("could not find virtio disk");
    800056e2:	00002517          	auipc	a0,0x2
    800056e6:	09650513          	addi	a0,a0,150 # 80007778 <syscalls+0x360>
    800056ea:	89efb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056ee:	00002517          	auipc	a0,0x2
    800056f2:	0aa50513          	addi	a0,a0,170 # 80007798 <syscalls+0x380>
    800056f6:	892fb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    800056fa:	00002517          	auipc	a0,0x2
    800056fe:	0be50513          	addi	a0,a0,190 # 800077b8 <syscalls+0x3a0>
    80005702:	886fb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005706:	00002517          	auipc	a0,0x2
    8000570a:	0d250513          	addi	a0,a0,210 # 800077d8 <syscalls+0x3c0>
    8000570e:	87afb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005712:	00002517          	auipc	a0,0x2
    80005716:	0e650513          	addi	a0,a0,230 # 800077f8 <syscalls+0x3e0>
    8000571a:	86efb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    8000571e:	00002517          	auipc	a0,0x2
    80005722:	0fa50513          	addi	a0,a0,250 # 80007818 <syscalls+0x400>
    80005726:	862fb0ef          	jal	ra,80000788 <panic>

000000008000572a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000572a:	7119                	addi	sp,sp,-128
    8000572c:	fc86                	sd	ra,120(sp)
    8000572e:	f8a2                	sd	s0,112(sp)
    80005730:	f4a6                	sd	s1,104(sp)
    80005732:	f0ca                	sd	s2,96(sp)
    80005734:	ecce                	sd	s3,88(sp)
    80005736:	e8d2                	sd	s4,80(sp)
    80005738:	e4d6                	sd	s5,72(sp)
    8000573a:	e0da                	sd	s6,64(sp)
    8000573c:	fc5e                	sd	s7,56(sp)
    8000573e:	f862                	sd	s8,48(sp)
    80005740:	f466                	sd	s9,40(sp)
    80005742:	f06a                	sd	s10,32(sp)
    80005744:	ec6e                	sd	s11,24(sp)
    80005746:	0100                	addi	s0,sp,128
    80005748:	8aaa                	mv	s5,a0
    8000574a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000574c:	00c52d03          	lw	s10,12(a0)
    80005750:	001d1d1b          	slliw	s10,s10,0x1
    80005754:	1d02                	slli	s10,s10,0x20
    80005756:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000575a:	0023b517          	auipc	a0,0x23b
    8000575e:	45e50513          	addi	a0,a0,1118 # 80240bb8 <disk+0x128>
    80005762:	d3efb0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80005766:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005768:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000576a:	0023bb97          	auipc	s7,0x23b
    8000576e:	326b8b93          	addi	s7,s7,806 # 80240a90 <disk>
  for(int i = 0; i < 3; i++){
    80005772:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005774:	0023bc97          	auipc	s9,0x23b
    80005778:	444c8c93          	addi	s9,s9,1092 # 80240bb8 <disk+0x128>
    8000577c:	a8a9                	j	800057d6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000577e:	00fb8733          	add	a4,s7,a5
    80005782:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005786:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005788:	0207c563          	bltz	a5,800057b2 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000578c:	2905                	addiw	s2,s2,1
    8000578e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005790:	05690863          	beq	s2,s6,800057e0 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005794:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005796:	0023b717          	auipc	a4,0x23b
    8000579a:	2fa70713          	addi	a4,a4,762 # 80240a90 <disk>
    8000579e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800057a0:	01874683          	lbu	a3,24(a4)
    800057a4:	fee9                	bnez	a3,8000577e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800057a6:	2785                	addiw	a5,a5,1
    800057a8:	0705                	addi	a4,a4,1
    800057aa:	fe979be3          	bne	a5,s1,800057a0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800057ae:	57fd                	li	a5,-1
    800057b0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057b2:	01205b63          	blez	s2,800057c8 <virtio_disk_rw+0x9e>
    800057b6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800057b8:	000a2503          	lw	a0,0(s4)
    800057bc:	d43ff0ef          	jal	ra,800054fe <free_desc>
      for(int j = 0; j < i; j++)
    800057c0:	2d85                	addiw	s11,s11,1
    800057c2:	0a11                	addi	s4,s4,4
    800057c4:	ff2d9ae3          	bne	s11,s2,800057b8 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057c8:	85e6                	mv	a1,s9
    800057ca:	0023b517          	auipc	a0,0x23b
    800057ce:	2de50513          	addi	a0,a0,734 # 80240aa8 <disk+0x18>
    800057d2:	86bfc0ef          	jal	ra,8000203c <sleep>
  for(int i = 0; i < 3; i++){
    800057d6:	f8040a13          	addi	s4,s0,-128
{
    800057da:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800057dc:	894e                	mv	s2,s3
    800057de:	bf5d                	j	80005794 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057e0:	f8042503          	lw	a0,-128(s0)
    800057e4:	00a50713          	addi	a4,a0,10
    800057e8:	0712                	slli	a4,a4,0x4

  if(write)
    800057ea:	0023b797          	auipc	a5,0x23b
    800057ee:	2a678793          	addi	a5,a5,678 # 80240a90 <disk>
    800057f2:	00e786b3          	add	a3,a5,a4
    800057f6:	01803633          	snez	a2,s8
    800057fa:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057fc:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005800:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005804:	f6070613          	addi	a2,a4,-160
    80005808:	6394                	ld	a3,0(a5)
    8000580a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000580c:	00870593          	addi	a1,a4,8
    80005810:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005812:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005814:	0007b803          	ld	a6,0(a5)
    80005818:	9642                	add	a2,a2,a6
    8000581a:	46c1                	li	a3,16
    8000581c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000581e:	4585                	li	a1,1
    80005820:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005824:	f8442683          	lw	a3,-124(s0)
    80005828:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000582c:	0692                	slli	a3,a3,0x4
    8000582e:	9836                	add	a6,a6,a3
    80005830:	058a8613          	addi	a2,s5,88
    80005834:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005838:	0007b803          	ld	a6,0(a5)
    8000583c:	96c2                	add	a3,a3,a6
    8000583e:	40000613          	li	a2,1024
    80005842:	c690                	sw	a2,8(a3)
  if(write)
    80005844:	001c3613          	seqz	a2,s8
    80005848:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000584c:	00166613          	ori	a2,a2,1
    80005850:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005854:	f8842603          	lw	a2,-120(s0)
    80005858:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000585c:	00250693          	addi	a3,a0,2
    80005860:	0692                	slli	a3,a3,0x4
    80005862:	96be                	add	a3,a3,a5
    80005864:	58fd                	li	a7,-1
    80005866:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000586a:	0612                	slli	a2,a2,0x4
    8000586c:	9832                	add	a6,a6,a2
    8000586e:	f9070713          	addi	a4,a4,-112
    80005872:	973e                	add	a4,a4,a5
    80005874:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005878:	6398                	ld	a4,0(a5)
    8000587a:	9732                	add	a4,a4,a2
    8000587c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000587e:	4609                	li	a2,2
    80005880:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005884:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005888:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000588c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005890:	6794                	ld	a3,8(a5)
    80005892:	0026d703          	lhu	a4,2(a3)
    80005896:	8b1d                	andi	a4,a4,7
    80005898:	0706                	slli	a4,a4,0x1
    8000589a:	96ba                	add	a3,a3,a4
    8000589c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800058a0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058a4:	6798                	ld	a4,8(a5)
    800058a6:	00275783          	lhu	a5,2(a4)
    800058aa:	2785                	addiw	a5,a5,1
    800058ac:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058b0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058b4:	100017b7          	lui	a5,0x10001
    800058b8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058bc:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800058c0:	0023b917          	auipc	s2,0x23b
    800058c4:	2f890913          	addi	s2,s2,760 # 80240bb8 <disk+0x128>
  while(b->disk == 1) {
    800058c8:	4485                	li	s1,1
    800058ca:	00b79a63          	bne	a5,a1,800058de <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800058ce:	85ca                	mv	a1,s2
    800058d0:	8556                	mv	a0,s5
    800058d2:	f6afc0ef          	jal	ra,8000203c <sleep>
  while(b->disk == 1) {
    800058d6:	004aa783          	lw	a5,4(s5)
    800058da:	fe978ae3          	beq	a5,s1,800058ce <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800058de:	f8042903          	lw	s2,-128(s0)
    800058e2:	00290713          	addi	a4,s2,2
    800058e6:	0712                	slli	a4,a4,0x4
    800058e8:	0023b797          	auipc	a5,0x23b
    800058ec:	1a878793          	addi	a5,a5,424 # 80240a90 <disk>
    800058f0:	97ba                	add	a5,a5,a4
    800058f2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058f6:	0023b997          	auipc	s3,0x23b
    800058fa:	19a98993          	addi	s3,s3,410 # 80240a90 <disk>
    800058fe:	00491713          	slli	a4,s2,0x4
    80005902:	0009b783          	ld	a5,0(s3)
    80005906:	97ba                	add	a5,a5,a4
    80005908:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000590c:	854a                	mv	a0,s2
    8000590e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005912:	bedff0ef          	jal	ra,800054fe <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005916:	8885                	andi	s1,s1,1
    80005918:	f0fd                	bnez	s1,800058fe <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000591a:	0023b517          	auipc	a0,0x23b
    8000591e:	29e50513          	addi	a0,a0,670 # 80240bb8 <disk+0x128>
    80005922:	c16fb0ef          	jal	ra,80000d38 <release>
}
    80005926:	70e6                	ld	ra,120(sp)
    80005928:	7446                	ld	s0,112(sp)
    8000592a:	74a6                	ld	s1,104(sp)
    8000592c:	7906                	ld	s2,96(sp)
    8000592e:	69e6                	ld	s3,88(sp)
    80005930:	6a46                	ld	s4,80(sp)
    80005932:	6aa6                	ld	s5,72(sp)
    80005934:	6b06                	ld	s6,64(sp)
    80005936:	7be2                	ld	s7,56(sp)
    80005938:	7c42                	ld	s8,48(sp)
    8000593a:	7ca2                	ld	s9,40(sp)
    8000593c:	7d02                	ld	s10,32(sp)
    8000593e:	6de2                	ld	s11,24(sp)
    80005940:	6109                	addi	sp,sp,128
    80005942:	8082                	ret

0000000080005944 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005944:	1101                	addi	sp,sp,-32
    80005946:	ec06                	sd	ra,24(sp)
    80005948:	e822                	sd	s0,16(sp)
    8000594a:	e426                	sd	s1,8(sp)
    8000594c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000594e:	0023b497          	auipc	s1,0x23b
    80005952:	14248493          	addi	s1,s1,322 # 80240a90 <disk>
    80005956:	0023b517          	auipc	a0,0x23b
    8000595a:	26250513          	addi	a0,a0,610 # 80240bb8 <disk+0x128>
    8000595e:	b42fb0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005962:	10001737          	lui	a4,0x10001
    80005966:	533c                	lw	a5,96(a4)
    80005968:	8b8d                	andi	a5,a5,3
    8000596a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000596c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005970:	689c                	ld	a5,16(s1)
    80005972:	0204d703          	lhu	a4,32(s1)
    80005976:	0027d783          	lhu	a5,2(a5)
    8000597a:	04f70663          	beq	a4,a5,800059c6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000597e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005982:	6898                	ld	a4,16(s1)
    80005984:	0204d783          	lhu	a5,32(s1)
    80005988:	8b9d                	andi	a5,a5,7
    8000598a:	078e                	slli	a5,a5,0x3
    8000598c:	97ba                	add	a5,a5,a4
    8000598e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005990:	00278713          	addi	a4,a5,2
    80005994:	0712                	slli	a4,a4,0x4
    80005996:	9726                	add	a4,a4,s1
    80005998:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000599c:	e321                	bnez	a4,800059dc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000599e:	0789                	addi	a5,a5,2
    800059a0:	0792                	slli	a5,a5,0x4
    800059a2:	97a6                	add	a5,a5,s1
    800059a4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800059a6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800059aa:	edefc0ef          	jal	ra,80002088 <wakeup>

    disk.used_idx += 1;
    800059ae:	0204d783          	lhu	a5,32(s1)
    800059b2:	2785                	addiw	a5,a5,1
    800059b4:	17c2                	slli	a5,a5,0x30
    800059b6:	93c1                	srli	a5,a5,0x30
    800059b8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059bc:	6898                	ld	a4,16(s1)
    800059be:	00275703          	lhu	a4,2(a4)
    800059c2:	faf71ee3          	bne	a4,a5,8000597e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800059c6:	0023b517          	auipc	a0,0x23b
    800059ca:	1f250513          	addi	a0,a0,498 # 80240bb8 <disk+0x128>
    800059ce:	b6afb0ef          	jal	ra,80000d38 <release>
}
    800059d2:	60e2                	ld	ra,24(sp)
    800059d4:	6442                	ld	s0,16(sp)
    800059d6:	64a2                	ld	s1,8(sp)
    800059d8:	6105                	addi	sp,sp,32
    800059da:	8082                	ret
      panic("virtio_disk_intr status");
    800059dc:	00002517          	auipc	a0,0x2
    800059e0:	e5450513          	addi	a0,a0,-428 # 80007830 <syscalls+0x418>
    800059e4:	da5fa0ef          	jal	ra,80000788 <panic>
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
