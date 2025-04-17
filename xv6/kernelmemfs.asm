
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 82 19 80       	mov    $0x80198280,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 00 a0 10 80       	push   $0x8010a000
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 73 46 00 00       	call   801046f1 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 07 a0 10 80       	push   $0x8010a007
801000c2:	50                   	push   %eax
801000c3:	e8 cc 44 00 00       	call   80104594 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 0d 46 00 00       	call   80104713 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 3c 46 00 00       	call   80104781 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 79 44 00 00       	call   801045d0 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 bb 45 00 00       	call   80104781 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 f8 43 00 00       	call   801045d0 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 0e a0 10 80       	push   $0x8010a00e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 d1 9c 00 00       	call   80109f03 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 33 44 00 00       	call   80104682 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a0 10 80       	push   $0x8010a01f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 86 9c 00 00       	call   80109f03 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 ea 43 00 00       	call   80104682 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a0 10 80       	push   $0x8010a026
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 79 43 00 00       	call   80104634 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 48 44 00 00       	call   80104713 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 46 44 00 00       	call   80104781 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 fe 42 00 00       	call   80104713 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d a0 10 80       	push   $0x8010a02d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 36 a0 10 80 	movl   $0x8010a036,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 de 41 00 00       	call   80104781 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 3d a0 10 80       	push   $0x8010a03d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 51 a0 10 80       	push   $0x8010a051
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 d0 41 00 00       	call   801047d3 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 a0 10 80       	push   $0x8010a053
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 b5 77 00 00       	call   80107e5a <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 62 77 00 00       	call   80107e5a <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 69 77 00 00       	call   80107ec5 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 39 5b 00 00       	call   801062d1 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 2c 5b 00 00       	call   801062d1 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 1f 5b 00 00       	call   801062d1 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 0f 5b 00 00       	call   801062d1 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 23 3f 00 00       	call   80104713 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 95 3a 00 00       	call   801043d9 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 1a 3e 00 00       	call   80104781 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 22 3b 00 00       	call   80104497 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 74 3d 00 00       	call   80104713 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 c1 3d 00 00       	call   80104781 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 02 39 00 00       	call   801042ef <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 16 3d 00 00       	call   80104781 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 6c 3c 00 00       	call   80104713 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 98 3c 00 00       	call   80104781 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 57 a0 10 80       	push   $0x8010a057
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 d0 3b 00 00       	call   801046f1 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 5f a0 10 80 	movl   $0x8010a05f,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 75 a0 10 80       	push   $0x8010a075
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 b7 66 00 00       	call   801072cd <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 0a 6a 00 00       	call   801076c6 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 f7 68 00 00       	call   801075f9 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 55 69 00 00       	call   801076c6 <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 93 6b 00 00       	call   80107928 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 09 3e 00 00       	call   80104bd7 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 dc 3d 00 00       	call   80104bd7 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 a6 6c 00 00       	call   80107ac7 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 0a 6c 00 00       	call   80107ac7 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 70             	add    $0x70,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 81 3c 00 00       	call   80104b8c <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 9c 64 00 00       	call   801073ea <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 33 69 00 00       	call   8010788f <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 f3 68 00 00       	call   8010788f <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 81 a0 10 80       	push   $0x8010a081
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 1a 37 00 00       	call   801046f1 <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 23 37 00 00       	call   80104713 <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 64 37 00 00       	call   80104781 <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 41 37 00 00       	call   80104781 <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 b6 36 00 00       	call   80104713 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 88 a0 10 80       	push   $0x8010a088
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 ee 36 00 00       	call   80104781 <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 65 36 00 00       	call   80104713 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 90 a0 10 80       	push   $0x8010a090
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 93 36 00 00       	call   80104781 <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 45 36 00 00       	call   80104781 <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 9a a0 10 80       	push   $0x8010a09a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 a3 a0 10 80       	push   $0x8010a0a3
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 b3 a0 10 80       	push   $0x8010a0b3
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 4c 36 00 00       	call   80104a48 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 47 35 00 00       	call   80104989 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 c0 a0 10 80       	push   $0x8010a0c0
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 d6 a0 10 80       	push   $0x8010a0d6
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 e9 a0 10 80       	push   $0x8010a0e9
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 57 30 00 00       	call   801046f1 <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 f0 a0 10 80       	push   $0x8010a0f0
801016c6:	50                   	push   %eax
801016c7:	e8 c8 2e 00 00       	call   80104594 <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 f8 a0 10 80       	push   $0x8010a0f8
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 eb 31 00 00       	call   80104989 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 4b a1 10 80       	push   $0x8010a14b
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 9c 31 00 00       	call   80104a48 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 32 2e 00 00       	call   80104713 <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 52 2e 00 00       	call   80104781 <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 5d a1 10 80       	push   $0x8010a15d
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 d9 2d 00 00       	call   80104781 <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 50 2d 00 00       	call   80104713 <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 9f 2d 00 00       	call   80104781 <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 6d a1 10 80       	push   $0x8010a16d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 b4 2b 00 00       	call   801045d0 <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 82 2f 00 00       	call   80104a48 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 73 a1 10 80       	push   $0x8010a173
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 6a 2b 00 00       	call   80104682 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 82 a1 10 80       	push   $0x8010a182
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 ef 2a 00 00       	call   80104634 <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 70 2a 00 00       	call   801045d0 <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 8d 2b 00 00       	call   80104713 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 e2 2b 00 00       	call   80104781 <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 4e 2a 00 00       	call   80104634 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 1d 2b 00 00       	call   80104713 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 6c 2b 00 00       	call   80104781 <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 8a a1 10 80       	push   $0x8010a18a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 51 2a 00 00       	call   80104a48 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 01 29 00 00       	call   80104a48 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 17 29 00 00       	call   80104ade <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 9d a1 10 80       	push   $0x8010a19d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 af a1 10 80       	push   $0x8010a1af
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 be a1 10 80       	push   $0x8010a1be
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 0e 28 00 00       	call   80104b34 <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 cb a1 10 80       	push   $0x8010a1cb
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 84 26 00 00       	call   80104a48 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 6d 26 00 00       	call   80104a48 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
8010242a:	8b 40 6c             	mov    0x6c(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 44 6f 19 80 	movzbl 0x80196f44,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 d4 a1 10 80       	push   $0x8010a1d4
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 06 a2 10 80       	push   $0x8010a206
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 6e 20 00 00       	call   801046f1 <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 0b a2 10 80       	push   $0x8010a20b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 3a 22 00 00       	call   80104989 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 ab 1f 00 00       	call   80104713 <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 e7 1f 00 00       	call   80104781 <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 57 1f 00 00       	call   80104713 <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 94 1f 00 00       	call   80104781 <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 d9 1c 00 00       	call   801049f0 <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 11 a2 10 80       	push   $0x8010a211
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 bc 18 00 00       	call   801046f1 <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 68 1b 00 00       	call   80104a48 <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 c4 16 00 00       	call   80104713 <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 82 12 00 00       	call   801042ef <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 4d 12 00 00       	call   801042ef <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 c0 16 00 00       	call   80104781 <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 31 16 00 00       	call   80104713 <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 15 a2 10 80       	push   $0x8010a215
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 a8 12 00 00       	call   801043d9 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 40 16 00 00       	call   80104781 <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 b7 15 00 00       	call   80104713 <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 63 12 00 00       	call   801043d9 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 fb 15 00 00       	call   80104781 <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 46 18 00 00       	call   80104a48 <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 24 a2 10 80       	push   $0x8010a224
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 3a a2 10 80       	push   $0x8010a23a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 4c 14 00 00       	call   80104713 <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 3c 14 00 00       	call   80104781 <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 24 4a 00 00       	call   80107d9f <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 24 40 00 00       	call   801073b9 <kvmalloc>
  mpinit_uefi();
80103395:	e8 cb 47 00 00       	call   80107b65 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 ad 3a 00 00       	call   80106e51 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 32 2e 00 00       	call   801061ea <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 d3 29 00 00       	call   80105d95 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 0f 6b 00 00       	call   80109ee0 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 08 4c 00 00       	call   80107ff8 <pci_init>
  arp_scan();
801033f0:	e8 3f 59 00 00       	call   80108d34 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 66 07 00 00       	call   80103b60 <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 c7 3f 00 00       	call   801073d1 <switchkvm>
  seginit();
8010340a:	e8 42 3a 00 00       	call   80106e51 <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 55 a2 10 80       	push   $0x8010a255
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 c8 2a 00 00       	call   80105f0b <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 9b 0c 00 00       	call   801040fb <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 38 f5 10 80       	push   $0x8010f538
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 c5 15 00 00       	call   80104a48 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 6c 19 80 	movl   $0x80196c80,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103508:	a1 40 6f 19 80       	mov    0x80196f40,%eax
8010350d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103513:	05 80 6c 19 80       	add    $0x80196c80,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 69 a2 10 80       	push   $0x8010a269
8010360c:	50                   	push   %eax
8010360d:	e8 df 10 00 00       	call   801046f1 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 42 10 00 00       	call   80104713 <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 e1 0c 00 00       	call   801043d9 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 be 0c 00 00       	call   801043d9 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 3d 10 00 00       	call   80104781 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 1e 10 00 00       	call   80104781 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 96 0f 00 00       	call   80104713 <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 d0 0f 00 00       	call   80104781 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 0a 0c 00 00       	call   801043d9 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 07 0b 00 00       	call   801042ef <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 87 0b 00 00       	call   801043d9 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 20 0f 00 00       	call   80104781 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 95 0e 00 00       	call   80104713 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 e6 0e 00 00       	call   80104781 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 31 0a 00 00       	call   801042ef <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 88 0a 00 00       	call   801043d9 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 21 0e 00 00       	call   80104781 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 70 a2 10 80       	push   $0x8010a270
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 5a 0d 00 00       	call   801046f1 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6c 19 80       	sub    $0x80196c80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 78 a2 10 80       	push   $0x8010a278
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6c 19 80       	add    $0x80196c80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6c 19 80       	add    $0x80196c80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6f 19 80       	mov    0x80196f40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 9e a2 10 80       	push   $0x8010a29e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 43 0e 00 00       	call   8010487e <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 77 0e 00 00       	call   801048cb <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 a7 0c 00 00       	call   80104713 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80103a89:	81 7d f4 34 64 19 80 	cmpl   $0x80196434,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 42 19 80       	push   $0x80194200
80103a9a:	e8 e2 0c 00 00       	call   80104781 <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 b2 00 00 00       	jmp    80103b5e <allocproc+0x105>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 42 19 80       	push   $0x80194200
80103ad3:	e8 a9 0c 00 00       	call   80104781 <release>
80103ad8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103adb:	e8 c0 ec ff ff       	call   801027a0 <kalloc>
80103ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae3:	89 42 08             	mov    %eax,0x8(%edx)
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	8b 40 08             	mov    0x8(%eax),%eax
80103aec:	85 c0                	test   %eax,%eax
80103aee:	75 11                	jne    80103b01 <allocproc+0xa8>
    p->state = UNUSED;
80103af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103afa:	b8 00 00 00 00       	mov    $0x0,%eax
80103aff:	eb 5d                	jmp    80103b5e <allocproc+0x105>
  }
  sp = p->kstack + KSTACKSIZE;
80103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b04:	8b 40 08             	mov    0x8(%eax),%eax
80103b07:	05 00 10 00 00       	add    $0x1000,%eax
80103b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b19:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b1c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b20:	ba 4f 5d 10 80       	mov    $0x80105d4f,%edx
80103b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b28:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b2a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b34:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3d:	83 ec 04             	sub    $0x4,%esp
80103b40:	6a 14                	push   $0x14
80103b42:	6a 00                	push   $0x0
80103b44:	50                   	push   %eax
80103b45:	e8 3f 0e 00 00       	call   80104989 <memset>
80103b4a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b53:	ba a9 42 10 80       	mov    $0x801042a9,%edx
80103b58:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5e:	c9                   	leave  
80103b5f:	c3                   	ret    

80103b60 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b60:	55                   	push   %ebp
80103b61:	89 e5                	mov    %esp,%ebp
80103b63:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b66:	e8 ee fe ff ff       	call   80103a59 <allocproc>
80103b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	a3 34 64 19 80       	mov    %eax,0x80196434
  p->using_uthread = 1;
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)

  if((p->pgdir = setupkvm()) == 0){
80103b80:	e8 48 37 00 00       	call   801072cd <setupkvm>
80103b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b88:	89 42 04             	mov    %eax,0x4(%edx)
80103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8e:	8b 40 04             	mov    0x4(%eax),%eax
80103b91:	85 c0                	test   %eax,%eax
80103b93:	75 0d                	jne    80103ba2 <userinit+0x42>
    panic("userinit: out of memory?");
80103b95:	83 ec 0c             	sub    $0xc,%esp
80103b98:	68 ae a2 10 80       	push   $0x8010a2ae
80103b9d:	e8 07 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103ba2:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baa:	8b 40 04             	mov    0x4(%eax),%eax
80103bad:	83 ec 04             	sub    $0x4,%esp
80103bb0:	52                   	push   %edx
80103bb1:	68 0c f5 10 80       	push   $0x8010f50c
80103bb6:	50                   	push   %eax
80103bb7:	e8 cd 39 00 00       	call   80107589 <inituvm>
80103bbc:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcb:	8b 40 18             	mov    0x18(%eax),%eax
80103bce:	83 ec 04             	sub    $0x4,%esp
80103bd1:	6a 4c                	push   $0x4c
80103bd3:	6a 00                	push   $0x0
80103bd5:	50                   	push   %eax
80103bd6:	e8 ae 0d 00 00       	call   80104989 <memset>
80103bdb:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be1:	8b 40 18             	mov    0x18(%eax),%eax
80103be4:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	8b 40 18             	mov    0x18(%eax),%eax
80103bf0:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 50 18             	mov    0x18(%eax),%edx
80103bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bff:	8b 40 18             	mov    0x18(%eax),%eax
80103c02:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c06:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0d:	8b 50 18             	mov    0x18(%eax),%edx
80103c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c13:	8b 40 18             	mov    0x18(%eax),%eax
80103c16:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c1a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8b 40 18             	mov    0x18(%eax),%eax
80103c31:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	8b 40 18             	mov    0x18(%eax),%eax
80103c3e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c48:	83 c0 70             	add    $0x70,%eax
80103c4b:	83 ec 04             	sub    $0x4,%esp
80103c4e:	6a 10                	push   $0x10
80103c50:	68 c7 a2 10 80       	push   $0x8010a2c7
80103c55:	50                   	push   %eax
80103c56:	e8 31 0f 00 00       	call   80104b8c <safestrcpy>
80103c5b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c5e:	83 ec 0c             	sub    $0xc,%esp
80103c61:	68 d0 a2 10 80       	push   $0x8010a2d0
80103c66:	e8 b2 e8 ff ff       	call   8010251d <namei>
80103c6b:	83 c4 10             	add    $0x10,%esp
80103c6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c71:	89 42 6c             	mov    %eax,0x6c(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c74:	83 ec 0c             	sub    $0xc,%esp
80103c77:	68 00 42 19 80       	push   $0x80194200
80103c7c:	e8 92 0a 00 00       	call   80104713 <acquire>
80103c81:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c87:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c8e:	83 ec 0c             	sub    $0xc,%esp
80103c91:	68 00 42 19 80       	push   $0x80194200
80103c96:	e8 e6 0a 00 00       	call   80104781 <release>
80103c9b:	83 c4 10             	add    $0x10,%esp
}
80103c9e:	90                   	nop
80103c9f:	c9                   	leave  
80103ca0:	c3                   	ret    

80103ca1 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ca1:	55                   	push   %ebp
80103ca2:	89 e5                	mov    %esp,%ebp
80103ca4:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ca7:	e8 84 fd ff ff       	call   80103a30 <myproc>
80103cac:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb2:	8b 00                	mov    (%eax),%eax
80103cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cb7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cbb:	7e 2e                	jle    80103ceb <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cbd:	8b 55 08             	mov    0x8(%ebp),%edx
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	01 c2                	add    %eax,%edx
80103cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc8:	8b 40 04             	mov    0x4(%eax),%eax
80103ccb:	83 ec 04             	sub    $0x4,%esp
80103cce:	52                   	push   %edx
80103ccf:	ff 75 f4             	push   -0xc(%ebp)
80103cd2:	50                   	push   %eax
80103cd3:	e8 ee 39 00 00       	call   801076c6 <allocuvm>
80103cd8:	83 c4 10             	add    $0x10,%esp
80103cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ce2:	75 3b                	jne    80103d1f <growproc+0x7e>
      return -1;
80103ce4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ce9:	eb 4f                	jmp    80103d3a <growproc+0x99>
  } else if(n < 0){
80103ceb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cef:	79 2e                	jns    80103d1f <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cf1:	8b 55 08             	mov    0x8(%ebp),%edx
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	01 c2                	add    %eax,%edx
80103cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cfc:	8b 40 04             	mov    0x4(%eax),%eax
80103cff:	83 ec 04             	sub    $0x4,%esp
80103d02:	52                   	push   %edx
80103d03:	ff 75 f4             	push   -0xc(%ebp)
80103d06:	50                   	push   %eax
80103d07:	e8 bf 3a 00 00       	call   801077cb <deallocuvm>
80103d0c:	83 c4 10             	add    $0x10,%esp
80103d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d16:	75 07                	jne    80103d1f <growproc+0x7e>
      return -1;
80103d18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d1d:	eb 1b                	jmp    80103d3a <growproc+0x99>
  }
  curproc->sz = sz;
80103d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d25:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d27:	83 ec 0c             	sub    $0xc,%esp
80103d2a:	ff 75 f0             	push   -0x10(%ebp)
80103d2d:	e8 b8 36 00 00       	call   801073ea <switchuvm>
80103d32:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d3a:	c9                   	leave  
80103d3b:	c3                   	ret    

80103d3c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d3c:	55                   	push   %ebp
80103d3d:	89 e5                	mov    %esp,%ebp
80103d3f:	57                   	push   %edi
80103d40:	56                   	push   %esi
80103d41:	53                   	push   %ebx
80103d42:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d45:	e8 e6 fc ff ff       	call   80103a30 <myproc>
80103d4a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d4d:	e8 07 fd ff ff       	call   80103a59 <allocproc>
80103d52:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d59:	75 0a                	jne    80103d65 <fork+0x29>
    return -1;
80103d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d60:	e9 48 01 00 00       	jmp    80103ead <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d68:	8b 10                	mov    (%eax),%edx
80103d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d6d:	8b 40 04             	mov    0x4(%eax),%eax
80103d70:	83 ec 08             	sub    $0x8,%esp
80103d73:	52                   	push   %edx
80103d74:	50                   	push   %eax
80103d75:	e8 ef 3b 00 00       	call   80107969 <copyuvm>
80103d7a:	83 c4 10             	add    $0x10,%esp
80103d7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d80:	89 42 04             	mov    %eax,0x4(%edx)
80103d83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d86:	8b 40 04             	mov    0x4(%eax),%eax
80103d89:	85 c0                	test   %eax,%eax
80103d8b:	75 30                	jne    80103dbd <fork+0x81>
    kfree(np->kstack);
80103d8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d90:	8b 40 08             	mov    0x8(%eax),%eax
80103d93:	83 ec 0c             	sub    $0xc,%esp
80103d96:	50                   	push   %eax
80103d97:	e8 6a e9 ff ff       	call   80102706 <kfree>
80103d9c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103da9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103db3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103db8:	e9 f0 00 00 00       	jmp    80103ead <fork+0x171>
  }
  np->sz = curproc->sz;
80103dbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc0:	8b 10                	mov    (%eax),%edx
80103dc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc5:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dc7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dca:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dcd:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dd3:	8b 48 18             	mov    0x18(%eax),%ecx
80103dd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd9:	8b 40 18             	mov    0x18(%eax),%eax
80103ddc:	89 c2                	mov    %eax,%edx
80103dde:	89 cb                	mov    %ecx,%ebx
80103de0:	b8 13 00 00 00       	mov    $0x13,%eax
80103de5:	89 d7                	mov    %edx,%edi
80103de7:	89 de                	mov    %ebx,%esi
80103de9:	89 c1                	mov    %eax,%ecx
80103deb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103ded:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df0:	8b 40 18             	mov    0x18(%eax),%eax
80103df3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103dfa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e01:	eb 3b                	jmp    80103e3e <fork+0x102>
    if(curproc->ofile[i])
80103e03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e09:	83 c2 08             	add    $0x8,%edx
80103e0c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103e10:	85 c0                	test   %eax,%eax
80103e12:	74 26                	je     80103e3a <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e1a:	83 c2 08             	add    $0x8,%edx
80103e1d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103e21:	83 ec 0c             	sub    $0xc,%esp
80103e24:	50                   	push   %eax
80103e25:	e8 20 d2 ff ff       	call   8010104a <filedup>
80103e2a:	83 c4 10             	add    $0x10,%esp
80103e2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e30:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e33:	83 c1 08             	add    $0x8,%ecx
80103e36:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e3a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e3e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e42:	7e bf                	jle    80103e03 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e47:	8b 40 6c             	mov    0x6c(%eax),%eax
80103e4a:	83 ec 0c             	sub    $0xc,%esp
80103e4d:	50                   	push   %eax
80103e4e:	e8 5d db ff ff       	call   801019b0 <idup>
80103e53:	83 c4 10             	add    $0x10,%esp
80103e56:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e59:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e5f:	8d 50 70             	lea    0x70(%eax),%edx
80103e62:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e65:	83 c0 70             	add    $0x70,%eax
80103e68:	83 ec 04             	sub    $0x4,%esp
80103e6b:	6a 10                	push   $0x10
80103e6d:	52                   	push   %edx
80103e6e:	50                   	push   %eax
80103e6f:	e8 18 0d 00 00       	call   80104b8c <safestrcpy>
80103e74:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7a:	8b 40 10             	mov    0x10(%eax),%eax
80103e7d:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e80:	83 ec 0c             	sub    $0xc,%esp
80103e83:	68 00 42 19 80       	push   $0x80194200
80103e88:	e8 86 08 00 00       	call   80104713 <acquire>
80103e8d:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e93:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e9a:	83 ec 0c             	sub    $0xc,%esp
80103e9d:	68 00 42 19 80       	push   $0x80194200
80103ea2:	e8 da 08 00 00       	call   80104781 <release>
80103ea7:	83 c4 10             	add    $0x10,%esp

  return pid;
80103eaa:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103eb0:	5b                   	pop    %ebx
80103eb1:	5e                   	pop    %esi
80103eb2:	5f                   	pop    %edi
80103eb3:	5d                   	pop    %ebp
80103eb4:	c3                   	ret    

80103eb5 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103eb5:	55                   	push   %ebp
80103eb6:	89 e5                	mov    %esp,%ebp
80103eb8:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ebb:	e8 70 fb ff ff       	call   80103a30 <myproc>
80103ec0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ec3:	a1 34 64 19 80       	mov    0x80196434,%eax
80103ec8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ecb:	75 0d                	jne    80103eda <exit+0x25>
    panic("init exiting");
80103ecd:	83 ec 0c             	sub    $0xc,%esp
80103ed0:	68 d2 a2 10 80       	push   $0x8010a2d2
80103ed5:	e8 cf c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103eda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ee1:	eb 3f                	jmp    80103f22 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ee3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ee9:	83 c2 08             	add    $0x8,%edx
80103eec:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103ef0:	85 c0                	test   %eax,%eax
80103ef2:	74 2a                	je     80103f1e <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103efa:	83 c2 08             	add    $0x8,%edx
80103efd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103f01:	83 ec 0c             	sub    $0xc,%esp
80103f04:	50                   	push   %eax
80103f05:	e8 91 d1 ff ff       	call   8010109b <fileclose>
80103f0a:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f13:	83 c2 08             	add    $0x8,%edx
80103f16:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103f1d:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f1e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f22:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f26:	7e bb                	jle    80103ee3 <exit+0x2e>
    }
  }

  begin_op();
80103f28:	e8 0f f1 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f30:	8b 40 6c             	mov    0x6c(%eax),%eax
80103f33:	83 ec 0c             	sub    $0xc,%esp
80103f36:	50                   	push   %eax
80103f37:	e8 0f dc ff ff       	call   80101b4b <iput>
80103f3c:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f3f:	e8 84 f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f47:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
80103f4e:	83 ec 0c             	sub    $0xc,%esp
80103f51:	68 00 42 19 80       	push   $0x80194200
80103f56:	e8 b8 07 00 00       	call   80104713 <acquire>
80103f5b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f61:	8b 40 14             	mov    0x14(%eax),%eax
80103f64:	83 ec 0c             	sub    $0xc,%esp
80103f67:	50                   	push   %eax
80103f68:	e8 29 04 00 00       	call   80104396 <wakeup1>
80103f6d:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f70:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f77:	eb 3a                	jmp    80103fb3 <exit+0xfe>
    if(p->parent == curproc){
80103f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7c:	8b 40 14             	mov    0x14(%eax),%eax
80103f7f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f82:	75 28                	jne    80103fac <exit+0xf7>
      p->parent = initproc;
80103f84:	8b 15 34 64 19 80    	mov    0x80196434,%edx
80103f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8d:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f93:	8b 40 0c             	mov    0xc(%eax),%eax
80103f96:	83 f8 05             	cmp    $0x5,%eax
80103f99:	75 11                	jne    80103fac <exit+0xf7>
        wakeup1(initproc);
80103f9b:	a1 34 64 19 80       	mov    0x80196434,%eax
80103fa0:	83 ec 0c             	sub    $0xc,%esp
80103fa3:	50                   	push   %eax
80103fa4:	e8 ed 03 00 00       	call   80104396 <wakeup1>
80103fa9:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fac:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80103fb3:	81 7d f4 34 64 19 80 	cmpl   $0x80196434,-0xc(%ebp)
80103fba:	72 bd                	jb     80103f79 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fbf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fc6:	e8 eb 01 00 00       	call   801041b6 <sched>
  panic("zombie exit");
80103fcb:	83 ec 0c             	sub    $0xc,%esp
80103fce:	68 df a2 10 80       	push   $0x8010a2df
80103fd3:	e8 d1 c5 ff ff       	call   801005a9 <panic>

80103fd8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fd8:	55                   	push   %ebp
80103fd9:	89 e5                	mov    %esp,%ebp
80103fdb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fde:	e8 4d fa ff ff       	call   80103a30 <myproc>
80103fe3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fe6:	83 ec 0c             	sub    $0xc,%esp
80103fe9:	68 00 42 19 80       	push   $0x80194200
80103fee:	e8 20 07 00 00       	call   80104713 <acquire>
80103ff3:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103ff6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ffd:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104004:	e9 a4 00 00 00       	jmp    801040ad <wait+0xd5>
      if(p->parent != curproc)
80104009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400c:	8b 40 14             	mov    0x14(%eax),%eax
8010400f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104012:	0f 85 8d 00 00 00    	jne    801040a5 <wait+0xcd>
        continue;
      havekids = 1;
80104018:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010401f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104022:	8b 40 0c             	mov    0xc(%eax),%eax
80104025:	83 f8 05             	cmp    $0x5,%eax
80104028:	75 7c                	jne    801040a6 <wait+0xce>
        // Found one.
        pid = p->pid;
8010402a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402d:	8b 40 10             	mov    0x10(%eax),%eax
80104030:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104036:	8b 40 08             	mov    0x8(%eax),%eax
80104039:	83 ec 0c             	sub    $0xc,%esp
8010403c:	50                   	push   %eax
8010403d:	e8 c4 e6 ff ff       	call   80102706 <kfree>
80104042:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010404f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104052:	8b 40 04             	mov    0x4(%eax),%eax
80104055:	83 ec 0c             	sub    $0xc,%esp
80104058:	50                   	push   %eax
80104059:	e8 31 38 00 00       	call   8010788f <freevm>
8010405e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104064:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010406b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104078:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104089:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104090:	83 ec 0c             	sub    $0xc,%esp
80104093:	68 00 42 19 80       	push   $0x80194200
80104098:	e8 e4 06 00 00       	call   80104781 <release>
8010409d:	83 c4 10             	add    $0x10,%esp
        return pid;
801040a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040a3:	eb 54                	jmp    801040f9 <wait+0x121>
        continue;
801040a5:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040a6:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801040ad:	81 7d f4 34 64 19 80 	cmpl   $0x80196434,-0xc(%ebp)
801040b4:	0f 82 4f ff ff ff    	jb     80104009 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040be:	74 0a                	je     801040ca <wait+0xf2>
801040c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040c3:	8b 40 24             	mov    0x24(%eax),%eax
801040c6:	85 c0                	test   %eax,%eax
801040c8:	74 17                	je     801040e1 <wait+0x109>
      release(&ptable.lock);
801040ca:	83 ec 0c             	sub    $0xc,%esp
801040cd:	68 00 42 19 80       	push   $0x80194200
801040d2:	e8 aa 06 00 00       	call   80104781 <release>
801040d7:	83 c4 10             	add    $0x10,%esp
      return -1;
801040da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040df:	eb 18                	jmp    801040f9 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040e1:	83 ec 08             	sub    $0x8,%esp
801040e4:	68 00 42 19 80       	push   $0x80194200
801040e9:	ff 75 ec             	push   -0x14(%ebp)
801040ec:	e8 fe 01 00 00       	call   801042ef <sleep>
801040f1:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040f4:	e9 fd fe ff ff       	jmp    80103ff6 <wait+0x1e>
  }
}
801040f9:	c9                   	leave  
801040fa:	c3                   	ret    

801040fb <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040fb:	55                   	push   %ebp
801040fc:	89 e5                	mov    %esp,%ebp
801040fe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104101:	e8 b2 f8 ff ff       	call   801039b8 <mycpu>
80104106:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104109:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010410c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104113:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104116:	e8 5d f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010411b:	83 ec 0c             	sub    $0xc,%esp
8010411e:	68 00 42 19 80       	push   $0x80194200
80104123:	e8 eb 05 00 00       	call   80104713 <acquire>
80104128:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010412b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104132:	eb 64                	jmp    80104198 <scheduler+0x9d>
      if(p->state != RUNNABLE)
80104134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104137:	8b 40 0c             	mov    0xc(%eax),%eax
8010413a:	83 f8 03             	cmp    $0x3,%eax
8010413d:	75 51                	jne    80104190 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010413f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104142:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104145:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	ff 75 f4             	push   -0xc(%ebp)
80104151:	e8 94 32 00 00       	call   801073ea <switchuvm>
80104156:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104166:	8b 40 1c             	mov    0x1c(%eax),%eax
80104169:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010416c:	83 c2 04             	add    $0x4,%edx
8010416f:	83 ec 08             	sub    $0x8,%esp
80104172:	50                   	push   %eax
80104173:	52                   	push   %edx
80104174:	e8 85 0a 00 00       	call   80104bfe <swtch>
80104179:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010417c:	e8 50 32 00 00       	call   801073d1 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104184:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010418b:	00 00 00 
8010418e:	eb 01                	jmp    80104191 <scheduler+0x96>
        continue;
80104190:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104191:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104198:	81 7d f4 34 64 19 80 	cmpl   $0x80196434,-0xc(%ebp)
8010419f:	72 93                	jb     80104134 <scheduler+0x39>
    }
    release(&ptable.lock);
801041a1:	83 ec 0c             	sub    $0xc,%esp
801041a4:	68 00 42 19 80       	push   $0x80194200
801041a9:	e8 d3 05 00 00       	call   80104781 <release>
801041ae:	83 c4 10             	add    $0x10,%esp
    sti();
801041b1:	e9 60 ff ff ff       	jmp    80104116 <scheduler+0x1b>

801041b6 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041b6:	55                   	push   %ebp
801041b7:	89 e5                	mov    %esp,%ebp
801041b9:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041bc:	e8 6f f8 ff ff       	call   80103a30 <myproc>
801041c1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041c4:	83 ec 0c             	sub    $0xc,%esp
801041c7:	68 00 42 19 80       	push   $0x80194200
801041cc:	e8 7d 06 00 00       	call   8010484e <holding>
801041d1:	83 c4 10             	add    $0x10,%esp
801041d4:	85 c0                	test   %eax,%eax
801041d6:	75 0d                	jne    801041e5 <sched+0x2f>
    panic("sched ptable.lock");
801041d8:	83 ec 0c             	sub    $0xc,%esp
801041db:	68 eb a2 10 80       	push   $0x8010a2eb
801041e0:	e8 c4 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041e5:	e8 ce f7 ff ff       	call   801039b8 <mycpu>
801041ea:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041f0:	83 f8 01             	cmp    $0x1,%eax
801041f3:	74 0d                	je     80104202 <sched+0x4c>
    panic("sched locks");
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	68 fd a2 10 80       	push   $0x8010a2fd
801041fd:	e8 a7 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	8b 40 0c             	mov    0xc(%eax),%eax
80104208:	83 f8 04             	cmp    $0x4,%eax
8010420b:	75 0d                	jne    8010421a <sched+0x64>
    panic("sched running");
8010420d:	83 ec 0c             	sub    $0xc,%esp
80104210:	68 09 a3 10 80       	push   $0x8010a309
80104215:	e8 8f c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010421a:	e8 49 f7 ff ff       	call   80103968 <readeflags>
8010421f:	25 00 02 00 00       	and    $0x200,%eax
80104224:	85 c0                	test   %eax,%eax
80104226:	74 0d                	je     80104235 <sched+0x7f>
    panic("sched interruptible");
80104228:	83 ec 0c             	sub    $0xc,%esp
8010422b:	68 17 a3 10 80       	push   $0x8010a317
80104230:	e8 74 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104235:	e8 7e f7 ff ff       	call   801039b8 <mycpu>
8010423a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104243:	e8 70 f7 ff ff       	call   801039b8 <mycpu>
80104248:	8b 40 04             	mov    0x4(%eax),%eax
8010424b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424e:	83 c2 1c             	add    $0x1c,%edx
80104251:	83 ec 08             	sub    $0x8,%esp
80104254:	50                   	push   %eax
80104255:	52                   	push   %edx
80104256:	e8 a3 09 00 00       	call   80104bfe <swtch>
8010425b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010425e:	e8 55 f7 ff ff       	call   801039b8 <mycpu>
80104263:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104266:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010426c:	90                   	nop
8010426d:	c9                   	leave  
8010426e:	c3                   	ret    

8010426f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010426f:	55                   	push   %ebp
80104270:	89 e5                	mov    %esp,%ebp
80104272:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104275:	83 ec 0c             	sub    $0xc,%esp
80104278:	68 00 42 19 80       	push   $0x80194200
8010427d:	e8 91 04 00 00       	call   80104713 <acquire>
80104282:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104285:	e8 a6 f7 ff ff       	call   80103a30 <myproc>
8010428a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104291:	e8 20 ff ff ff       	call   801041b6 <sched>
  release(&ptable.lock);
80104296:	83 ec 0c             	sub    $0xc,%esp
80104299:	68 00 42 19 80       	push   $0x80194200
8010429e:	e8 de 04 00 00       	call   80104781 <release>
801042a3:	83 c4 10             	add    $0x10,%esp
}
801042a6:	90                   	nop
801042a7:	c9                   	leave  
801042a8:	c3                   	ret    

801042a9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801042a9:	55                   	push   %ebp
801042aa:	89 e5                	mov    %esp,%ebp
801042ac:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042af:	83 ec 0c             	sub    $0xc,%esp
801042b2:	68 00 42 19 80       	push   $0x80194200
801042b7:	e8 c5 04 00 00       	call   80104781 <release>
801042bc:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042bf:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042c4:	85 c0                	test   %eax,%eax
801042c6:	74 24                	je     801042ec <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042c8:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042cf:	00 00 00 
    iinit(ROOTDEV);
801042d2:	83 ec 0c             	sub    $0xc,%esp
801042d5:	6a 01                	push   $0x1
801042d7:	e8 9c d3 ff ff       	call   80101678 <iinit>
801042dc:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042df:	83 ec 0c             	sub    $0xc,%esp
801042e2:	6a 01                	push   $0x1
801042e4:	e8 34 eb ff ff       	call   80102e1d <initlog>
801042e9:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042ec:	90                   	nop
801042ed:	c9                   	leave  
801042ee:	c3                   	ret    

801042ef <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042ef:	55                   	push   %ebp
801042f0:	89 e5                	mov    %esp,%ebp
801042f2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042f5:	e8 36 f7 ff ff       	call   80103a30 <myproc>
801042fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104301:	75 0d                	jne    80104310 <sleep+0x21>
    panic("sleep");
80104303:	83 ec 0c             	sub    $0xc,%esp
80104306:	68 2b a3 10 80       	push   $0x8010a32b
8010430b:	e8 99 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104310:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104314:	75 0d                	jne    80104323 <sleep+0x34>
    panic("sleep without lk");
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	68 31 a3 10 80       	push   $0x8010a331
8010431e:	e8 86 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104323:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010432a:	74 1e                	je     8010434a <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010432c:	83 ec 0c             	sub    $0xc,%esp
8010432f:	68 00 42 19 80       	push   $0x80194200
80104334:	e8 da 03 00 00       	call   80104713 <acquire>
80104339:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010433c:	83 ec 0c             	sub    $0xc,%esp
8010433f:	ff 75 0c             	push   0xc(%ebp)
80104342:	e8 3a 04 00 00       	call   80104781 <release>
80104347:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010434a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434d:	8b 55 08             	mov    0x8(%ebp),%edx
80104350:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104356:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010435d:	e8 54 fe ff ff       	call   801041b6 <sched>

  // Tidy up.
  p->chan = 0;
80104362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104365:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010436c:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104373:	74 1e                	je     80104393 <sleep+0xa4>
    release(&ptable.lock);
80104375:	83 ec 0c             	sub    $0xc,%esp
80104378:	68 00 42 19 80       	push   $0x80194200
8010437d:	e8 ff 03 00 00       	call   80104781 <release>
80104382:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104385:	83 ec 0c             	sub    $0xc,%esp
80104388:	ff 75 0c             	push   0xc(%ebp)
8010438b:	e8 83 03 00 00       	call   80104713 <acquire>
80104390:	83 c4 10             	add    $0x10,%esp
  }
}
80104393:	90                   	nop
80104394:	c9                   	leave  
80104395:	c3                   	ret    

80104396 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104396:	55                   	push   %ebp
80104397:	89 e5                	mov    %esp,%ebp
80104399:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010439c:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801043a3:	eb 27                	jmp    801043cc <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801043a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a8:	8b 40 0c             	mov    0xc(%eax),%eax
801043ab:	83 f8 02             	cmp    $0x2,%eax
801043ae:	75 15                	jne    801043c5 <wakeup1+0x2f>
801043b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b3:	8b 40 20             	mov    0x20(%eax),%eax
801043b6:	39 45 08             	cmp    %eax,0x8(%ebp)
801043b9:	75 0a                	jne    801043c5 <wakeup1+0x2f>
      p->state = RUNNABLE;
801043bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043be:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c5:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
801043cc:	81 7d fc 34 64 19 80 	cmpl   $0x80196434,-0x4(%ebp)
801043d3:	72 d0                	jb     801043a5 <wakeup1+0xf>
}
801043d5:	90                   	nop
801043d6:	90                   	nop
801043d7:	c9                   	leave  
801043d8:	c3                   	ret    

801043d9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043d9:	55                   	push   %ebp
801043da:	89 e5                	mov    %esp,%ebp
801043dc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043df:	83 ec 0c             	sub    $0xc,%esp
801043e2:	68 00 42 19 80       	push   $0x80194200
801043e7:	e8 27 03 00 00       	call   80104713 <acquire>
801043ec:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043ef:	83 ec 0c             	sub    $0xc,%esp
801043f2:	ff 75 08             	push   0x8(%ebp)
801043f5:	e8 9c ff ff ff       	call   80104396 <wakeup1>
801043fa:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043fd:	83 ec 0c             	sub    $0xc,%esp
80104400:	68 00 42 19 80       	push   $0x80194200
80104405:	e8 77 03 00 00       	call   80104781 <release>
8010440a:	83 c4 10             	add    $0x10,%esp
}
8010440d:	90                   	nop
8010440e:	c9                   	leave  
8010440f:	c3                   	ret    

80104410 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104410:	55                   	push   %ebp
80104411:	89 e5                	mov    %esp,%ebp
80104413:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104416:	83 ec 0c             	sub    $0xc,%esp
80104419:	68 00 42 19 80       	push   $0x80194200
8010441e:	e8 f0 02 00 00       	call   80104713 <acquire>
80104423:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104426:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010442d:	eb 48                	jmp    80104477 <kill+0x67>
    if(p->pid == pid){
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	8b 40 10             	mov    0x10(%eax),%eax
80104435:	39 45 08             	cmp    %eax,0x8(%ebp)
80104438:	75 36                	jne    80104470 <kill+0x60>
      p->killed = 1;
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	8b 40 0c             	mov    0xc(%eax),%eax
8010444a:	83 f8 02             	cmp    $0x2,%eax
8010444d:	75 0a                	jne    80104459 <kill+0x49>
        p->state = RUNNABLE;
8010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104452:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104459:	83 ec 0c             	sub    $0xc,%esp
8010445c:	68 00 42 19 80       	push   $0x80194200
80104461:	e8 1b 03 00 00       	call   80104781 <release>
80104466:	83 c4 10             	add    $0x10,%esp
      return 0;
80104469:	b8 00 00 00 00       	mov    $0x0,%eax
8010446e:	eb 25                	jmp    80104495 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104470:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104477:	81 7d f4 34 64 19 80 	cmpl   $0x80196434,-0xc(%ebp)
8010447e:	72 af                	jb     8010442f <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104480:	83 ec 0c             	sub    $0xc,%esp
80104483:	68 00 42 19 80       	push   $0x80194200
80104488:	e8 f4 02 00 00       	call   80104781 <release>
8010448d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104495:	c9                   	leave  
80104496:	c3                   	ret    

80104497 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104497:	55                   	push   %ebp
80104498:	89 e5                	mov    %esp,%ebp
8010449a:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010449d:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
801044a4:	e9 da 00 00 00       	jmp    80104583 <procdump+0xec>
    if(p->state == UNUSED)
801044a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ac:	8b 40 0c             	mov    0xc(%eax),%eax
801044af:	85 c0                	test   %eax,%eax
801044b1:	0f 84 c4 00 00 00    	je     8010457b <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ba:	8b 40 0c             	mov    0xc(%eax),%eax
801044bd:	83 f8 05             	cmp    $0x5,%eax
801044c0:	77 23                	ja     801044e5 <procdump+0x4e>
801044c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c5:	8b 40 0c             	mov    0xc(%eax),%eax
801044c8:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044cf:	85 c0                	test   %eax,%eax
801044d1:	74 12                	je     801044e5 <procdump+0x4e>
      state = states[p->state];
801044d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d6:	8b 40 0c             	mov    0xc(%eax),%eax
801044d9:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044e3:	eb 07                	jmp    801044ec <procdump+0x55>
    else
      state = "???";
801044e5:	c7 45 ec 42 a3 10 80 	movl   $0x8010a342,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ef:	8d 50 70             	lea    0x70(%eax),%edx
801044f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f5:	8b 40 10             	mov    0x10(%eax),%eax
801044f8:	52                   	push   %edx
801044f9:	ff 75 ec             	push   -0x14(%ebp)
801044fc:	50                   	push   %eax
801044fd:	68 46 a3 10 80       	push   $0x8010a346
80104502:	e8 ed be ff ff       	call   801003f4 <cprintf>
80104507:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010450a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450d:	8b 40 0c             	mov    0xc(%eax),%eax
80104510:	83 f8 02             	cmp    $0x2,%eax
80104513:	75 54                	jne    80104569 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104518:	8b 40 1c             	mov    0x1c(%eax),%eax
8010451b:	8b 40 0c             	mov    0xc(%eax),%eax
8010451e:	83 c0 08             	add    $0x8,%eax
80104521:	89 c2                	mov    %eax,%edx
80104523:	83 ec 08             	sub    $0x8,%esp
80104526:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104529:	50                   	push   %eax
8010452a:	52                   	push   %edx
8010452b:	e8 a3 02 00 00       	call   801047d3 <getcallerpcs>
80104530:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104533:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010453a:	eb 1c                	jmp    80104558 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010453c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104543:	83 ec 08             	sub    $0x8,%esp
80104546:	50                   	push   %eax
80104547:	68 4f a3 10 80       	push   $0x8010a34f
8010454c:	e8 a3 be ff ff       	call   801003f4 <cprintf>
80104551:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104554:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104558:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010455c:	7f 0b                	jg     80104569 <procdump+0xd2>
8010455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104561:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104565:	85 c0                	test   %eax,%eax
80104567:	75 d3                	jne    8010453c <procdump+0xa5>
    }
    cprintf("\n");
80104569:	83 ec 0c             	sub    $0xc,%esp
8010456c:	68 53 a3 10 80       	push   $0x8010a353
80104571:	e8 7e be ff ff       	call   801003f4 <cprintf>
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	eb 01                	jmp    8010457c <procdump+0xe5>
      continue;
8010457b:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010457c:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104583:	81 7d f0 34 64 19 80 	cmpl   $0x80196434,-0x10(%ebp)
8010458a:	0f 82 19 ff ff ff    	jb     801044a9 <procdump+0x12>
  }
}
80104590:	90                   	nop
80104591:	90                   	nop
80104592:	c9                   	leave  
80104593:	c3                   	ret    

80104594 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104594:	55                   	push   %ebp
80104595:	89 e5                	mov    %esp,%ebp
80104597:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010459a:	8b 45 08             	mov    0x8(%ebp),%eax
8010459d:	83 c0 04             	add    $0x4,%eax
801045a0:	83 ec 08             	sub    $0x8,%esp
801045a3:	68 7f a3 10 80       	push   $0x8010a37f
801045a8:	50                   	push   %eax
801045a9:	e8 43 01 00 00       	call   801046f1 <initlock>
801045ae:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045b1:	8b 45 08             	mov    0x8(%ebp),%eax
801045b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801045b7:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045ba:	8b 45 08             	mov    0x8(%ebp),%eax
801045bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045c3:	8b 45 08             	mov    0x8(%ebp),%eax
801045c6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045cd:	90                   	nop
801045ce:	c9                   	leave  
801045cf:	c3                   	ret    

801045d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045d0:	55                   	push   %ebp
801045d1:	89 e5                	mov    %esp,%ebp
801045d3:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045d6:	8b 45 08             	mov    0x8(%ebp),%eax
801045d9:	83 c0 04             	add    $0x4,%eax
801045dc:	83 ec 0c             	sub    $0xc,%esp
801045df:	50                   	push   %eax
801045e0:	e8 2e 01 00 00       	call   80104713 <acquire>
801045e5:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045e8:	eb 15                	jmp    801045ff <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045ea:	8b 45 08             	mov    0x8(%ebp),%eax
801045ed:	83 c0 04             	add    $0x4,%eax
801045f0:	83 ec 08             	sub    $0x8,%esp
801045f3:	50                   	push   %eax
801045f4:	ff 75 08             	push   0x8(%ebp)
801045f7:	e8 f3 fc ff ff       	call   801042ef <sleep>
801045fc:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104602:	8b 00                	mov    (%eax),%eax
80104604:	85 c0                	test   %eax,%eax
80104606:	75 e2                	jne    801045ea <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104608:	8b 45 08             	mov    0x8(%ebp),%eax
8010460b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104611:	e8 1a f4 ff ff       	call   80103a30 <myproc>
80104616:	8b 50 10             	mov    0x10(%eax),%edx
80104619:	8b 45 08             	mov    0x8(%ebp),%eax
8010461c:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010461f:	8b 45 08             	mov    0x8(%ebp),%eax
80104622:	83 c0 04             	add    $0x4,%eax
80104625:	83 ec 0c             	sub    $0xc,%esp
80104628:	50                   	push   %eax
80104629:	e8 53 01 00 00       	call   80104781 <release>
8010462e:	83 c4 10             	add    $0x10,%esp
}
80104631:	90                   	nop
80104632:	c9                   	leave  
80104633:	c3                   	ret    

80104634 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104634:	55                   	push   %ebp
80104635:	89 e5                	mov    %esp,%ebp
80104637:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010463a:	8b 45 08             	mov    0x8(%ebp),%eax
8010463d:	83 c0 04             	add    $0x4,%eax
80104640:	83 ec 0c             	sub    $0xc,%esp
80104643:	50                   	push   %eax
80104644:	e8 ca 00 00 00       	call   80104713 <acquire>
80104649:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010464c:	8b 45 08             	mov    0x8(%ebp),%eax
8010464f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104655:	8b 45 08             	mov    0x8(%ebp),%eax
80104658:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010465f:	83 ec 0c             	sub    $0xc,%esp
80104662:	ff 75 08             	push   0x8(%ebp)
80104665:	e8 6f fd ff ff       	call   801043d9 <wakeup>
8010466a:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010466d:	8b 45 08             	mov    0x8(%ebp),%eax
80104670:	83 c0 04             	add    $0x4,%eax
80104673:	83 ec 0c             	sub    $0xc,%esp
80104676:	50                   	push   %eax
80104677:	e8 05 01 00 00       	call   80104781 <release>
8010467c:	83 c4 10             	add    $0x10,%esp
}
8010467f:	90                   	nop
80104680:	c9                   	leave  
80104681:	c3                   	ret    

80104682 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104682:	55                   	push   %ebp
80104683:	89 e5                	mov    %esp,%ebp
80104685:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104688:	8b 45 08             	mov    0x8(%ebp),%eax
8010468b:	83 c0 04             	add    $0x4,%eax
8010468e:	83 ec 0c             	sub    $0xc,%esp
80104691:	50                   	push   %eax
80104692:	e8 7c 00 00 00       	call   80104713 <acquire>
80104697:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
8010469a:	8b 45 08             	mov    0x8(%ebp),%eax
8010469d:	8b 00                	mov    (%eax),%eax
8010469f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801046a2:	8b 45 08             	mov    0x8(%ebp),%eax
801046a5:	83 c0 04             	add    $0x4,%eax
801046a8:	83 ec 0c             	sub    $0xc,%esp
801046ab:	50                   	push   %eax
801046ac:	e8 d0 00 00 00       	call   80104781 <release>
801046b1:	83 c4 10             	add    $0x10,%esp
  return r;
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046b7:	c9                   	leave  
801046b8:	c3                   	ret    

801046b9 <readeflags>:
{
801046b9:	55                   	push   %ebp
801046ba:	89 e5                	mov    %esp,%ebp
801046bc:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046bf:	9c                   	pushf  
801046c0:	58                   	pop    %eax
801046c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046c7:	c9                   	leave  
801046c8:	c3                   	ret    

801046c9 <cli>:
{
801046c9:	55                   	push   %ebp
801046ca:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046cc:	fa                   	cli    
}
801046cd:	90                   	nop
801046ce:	5d                   	pop    %ebp
801046cf:	c3                   	ret    

801046d0 <sti>:
{
801046d0:	55                   	push   %ebp
801046d1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046d3:	fb                   	sti    
}
801046d4:	90                   	nop
801046d5:	5d                   	pop    %ebp
801046d6:	c3                   	ret    

801046d7 <xchg>:
{
801046d7:	55                   	push   %ebp
801046d8:	89 e5                	mov    %esp,%ebp
801046da:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046dd:	8b 55 08             	mov    0x8(%ebp),%edx
801046e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801046e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046e6:	f0 87 02             	lock xchg %eax,(%edx)
801046e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046ef:	c9                   	leave  
801046f0:	c3                   	ret    

801046f1 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046f1:	55                   	push   %ebp
801046f2:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801046f4:	8b 45 08             	mov    0x8(%ebp),%eax
801046f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801046fa:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801046fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104700:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104706:	8b 45 08             	mov    0x8(%ebp),%eax
80104709:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104710:	90                   	nop
80104711:	5d                   	pop    %ebp
80104712:	c3                   	ret    

80104713 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104713:	55                   	push   %ebp
80104714:	89 e5                	mov    %esp,%ebp
80104716:	53                   	push   %ebx
80104717:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010471a:	e8 5f 01 00 00       	call   8010487e <pushcli>
  if(holding(lk)){
8010471f:	8b 45 08             	mov    0x8(%ebp),%eax
80104722:	83 ec 0c             	sub    $0xc,%esp
80104725:	50                   	push   %eax
80104726:	e8 23 01 00 00       	call   8010484e <holding>
8010472b:	83 c4 10             	add    $0x10,%esp
8010472e:	85 c0                	test   %eax,%eax
80104730:	74 0d                	je     8010473f <acquire+0x2c>
    panic("acquire");
80104732:	83 ec 0c             	sub    $0xc,%esp
80104735:	68 8a a3 10 80       	push   $0x8010a38a
8010473a:	e8 6a be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010473f:	90                   	nop
80104740:	8b 45 08             	mov    0x8(%ebp),%eax
80104743:	83 ec 08             	sub    $0x8,%esp
80104746:	6a 01                	push   $0x1
80104748:	50                   	push   %eax
80104749:	e8 89 ff ff ff       	call   801046d7 <xchg>
8010474e:	83 c4 10             	add    $0x10,%esp
80104751:	85 c0                	test   %eax,%eax
80104753:	75 eb                	jne    80104740 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104755:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010475a:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010475d:	e8 56 f2 ff ff       	call   801039b8 <mycpu>
80104762:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104765:	8b 45 08             	mov    0x8(%ebp),%eax
80104768:	83 c0 0c             	add    $0xc,%eax
8010476b:	83 ec 08             	sub    $0x8,%esp
8010476e:	50                   	push   %eax
8010476f:	8d 45 08             	lea    0x8(%ebp),%eax
80104772:	50                   	push   %eax
80104773:	e8 5b 00 00 00       	call   801047d3 <getcallerpcs>
80104778:	83 c4 10             	add    $0x10,%esp
}
8010477b:	90                   	nop
8010477c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010477f:	c9                   	leave  
80104780:	c3                   	ret    

80104781 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104781:	55                   	push   %ebp
80104782:	89 e5                	mov    %esp,%ebp
80104784:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104787:	83 ec 0c             	sub    $0xc,%esp
8010478a:	ff 75 08             	push   0x8(%ebp)
8010478d:	e8 bc 00 00 00       	call   8010484e <holding>
80104792:	83 c4 10             	add    $0x10,%esp
80104795:	85 c0                	test   %eax,%eax
80104797:	75 0d                	jne    801047a6 <release+0x25>
    panic("release");
80104799:	83 ec 0c             	sub    $0xc,%esp
8010479c:	68 92 a3 10 80       	push   $0x8010a392
801047a1:	e8 03 be ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801047a6:	8b 45 08             	mov    0x8(%ebp),%eax
801047a9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047b0:	8b 45 08             	mov    0x8(%ebp),%eax
801047b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047ba:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047bf:	8b 45 08             	mov    0x8(%ebp),%eax
801047c2:	8b 55 08             	mov    0x8(%ebp),%edx
801047c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047cb:	e8 fb 00 00 00       	call   801048cb <popcli>
}
801047d0:	90                   	nop
801047d1:	c9                   	leave  
801047d2:	c3                   	ret    

801047d3 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047d3:	55                   	push   %ebp
801047d4:	89 e5                	mov    %esp,%ebp
801047d6:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047d9:	8b 45 08             	mov    0x8(%ebp),%eax
801047dc:	83 e8 08             	sub    $0x8,%eax
801047df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047e2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047e9:	eb 38                	jmp    80104823 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047eb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801047ef:	74 53                	je     80104844 <getcallerpcs+0x71>
801047f1:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801047f8:	76 4a                	jbe    80104844 <getcallerpcs+0x71>
801047fa:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801047fe:	74 44                	je     80104844 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104800:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104803:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010480a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010480d:	01 c2                	add    %eax,%edx
8010480f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104812:	8b 40 04             	mov    0x4(%eax),%eax
80104815:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104817:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010481a:	8b 00                	mov    (%eax),%eax
8010481c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010481f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104823:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104827:	7e c2                	jle    801047eb <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104829:	eb 19                	jmp    80104844 <getcallerpcs+0x71>
    pcs[i] = 0;
8010482b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010482e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104835:	8b 45 0c             	mov    0xc(%ebp),%eax
80104838:	01 d0                	add    %edx,%eax
8010483a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104840:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104844:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104848:	7e e1                	jle    8010482b <getcallerpcs+0x58>
}
8010484a:	90                   	nop
8010484b:	90                   	nop
8010484c:	c9                   	leave  
8010484d:	c3                   	ret    

8010484e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010484e:	55                   	push   %ebp
8010484f:	89 e5                	mov    %esp,%ebp
80104851:	53                   	push   %ebx
80104852:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104855:	8b 45 08             	mov    0x8(%ebp),%eax
80104858:	8b 00                	mov    (%eax),%eax
8010485a:	85 c0                	test   %eax,%eax
8010485c:	74 16                	je     80104874 <holding+0x26>
8010485e:	8b 45 08             	mov    0x8(%ebp),%eax
80104861:	8b 58 08             	mov    0x8(%eax),%ebx
80104864:	e8 4f f1 ff ff       	call   801039b8 <mycpu>
80104869:	39 c3                	cmp    %eax,%ebx
8010486b:	75 07                	jne    80104874 <holding+0x26>
8010486d:	b8 01 00 00 00       	mov    $0x1,%eax
80104872:	eb 05                	jmp    80104879 <holding+0x2b>
80104874:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010487c:	c9                   	leave  
8010487d:	c3                   	ret    

8010487e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010487e:	55                   	push   %ebp
8010487f:	89 e5                	mov    %esp,%ebp
80104881:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104884:	e8 30 fe ff ff       	call   801046b9 <readeflags>
80104889:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010488c:	e8 38 fe ff ff       	call   801046c9 <cli>
  if(mycpu()->ncli == 0)
80104891:	e8 22 f1 ff ff       	call   801039b8 <mycpu>
80104896:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010489c:	85 c0                	test   %eax,%eax
8010489e:	75 14                	jne    801048b4 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801048a0:	e8 13 f1 ff ff       	call   801039b8 <mycpu>
801048a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048a8:	81 e2 00 02 00 00    	and    $0x200,%edx
801048ae:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048b4:	e8 ff f0 ff ff       	call   801039b8 <mycpu>
801048b9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048bf:	83 c2 01             	add    $0x1,%edx
801048c2:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048c8:	90                   	nop
801048c9:	c9                   	leave  
801048ca:	c3                   	ret    

801048cb <popcli>:

void
popcli(void)
{
801048cb:	55                   	push   %ebp
801048cc:	89 e5                	mov    %esp,%ebp
801048ce:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048d1:	e8 e3 fd ff ff       	call   801046b9 <readeflags>
801048d6:	25 00 02 00 00       	and    $0x200,%eax
801048db:	85 c0                	test   %eax,%eax
801048dd:	74 0d                	je     801048ec <popcli+0x21>
    panic("popcli - interruptible");
801048df:	83 ec 0c             	sub    $0xc,%esp
801048e2:	68 9a a3 10 80       	push   $0x8010a39a
801048e7:	e8 bd bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048ec:	e8 c7 f0 ff ff       	call   801039b8 <mycpu>
801048f1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048f7:	83 ea 01             	sub    $0x1,%edx
801048fa:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104900:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104906:	85 c0                	test   %eax,%eax
80104908:	79 0d                	jns    80104917 <popcli+0x4c>
    panic("popcli");
8010490a:	83 ec 0c             	sub    $0xc,%esp
8010490d:	68 b1 a3 10 80       	push   $0x8010a3b1
80104912:	e8 92 bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104917:	e8 9c f0 ff ff       	call   801039b8 <mycpu>
8010491c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104922:	85 c0                	test   %eax,%eax
80104924:	75 14                	jne    8010493a <popcli+0x6f>
80104926:	e8 8d f0 ff ff       	call   801039b8 <mycpu>
8010492b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104931:	85 c0                	test   %eax,%eax
80104933:	74 05                	je     8010493a <popcli+0x6f>
    sti();
80104935:	e8 96 fd ff ff       	call   801046d0 <sti>
}
8010493a:	90                   	nop
8010493b:	c9                   	leave  
8010493c:	c3                   	ret    

8010493d <stosb>:
{
8010493d:	55                   	push   %ebp
8010493e:	89 e5                	mov    %esp,%ebp
80104940:	57                   	push   %edi
80104941:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104942:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104945:	8b 55 10             	mov    0x10(%ebp),%edx
80104948:	8b 45 0c             	mov    0xc(%ebp),%eax
8010494b:	89 cb                	mov    %ecx,%ebx
8010494d:	89 df                	mov    %ebx,%edi
8010494f:	89 d1                	mov    %edx,%ecx
80104951:	fc                   	cld    
80104952:	f3 aa                	rep stos %al,%es:(%edi)
80104954:	89 ca                	mov    %ecx,%edx
80104956:	89 fb                	mov    %edi,%ebx
80104958:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010495b:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010495e:	90                   	nop
8010495f:	5b                   	pop    %ebx
80104960:	5f                   	pop    %edi
80104961:	5d                   	pop    %ebp
80104962:	c3                   	ret    

80104963 <stosl>:
{
80104963:	55                   	push   %ebp
80104964:	89 e5                	mov    %esp,%ebp
80104966:	57                   	push   %edi
80104967:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104968:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010496b:	8b 55 10             	mov    0x10(%ebp),%edx
8010496e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104971:	89 cb                	mov    %ecx,%ebx
80104973:	89 df                	mov    %ebx,%edi
80104975:	89 d1                	mov    %edx,%ecx
80104977:	fc                   	cld    
80104978:	f3 ab                	rep stos %eax,%es:(%edi)
8010497a:	89 ca                	mov    %ecx,%edx
8010497c:	89 fb                	mov    %edi,%ebx
8010497e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104981:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104984:	90                   	nop
80104985:	5b                   	pop    %ebx
80104986:	5f                   	pop    %edi
80104987:	5d                   	pop    %ebp
80104988:	c3                   	ret    

80104989 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104989:	55                   	push   %ebp
8010498a:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010498c:	8b 45 08             	mov    0x8(%ebp),%eax
8010498f:	83 e0 03             	and    $0x3,%eax
80104992:	85 c0                	test   %eax,%eax
80104994:	75 43                	jne    801049d9 <memset+0x50>
80104996:	8b 45 10             	mov    0x10(%ebp),%eax
80104999:	83 e0 03             	and    $0x3,%eax
8010499c:	85 c0                	test   %eax,%eax
8010499e:	75 39                	jne    801049d9 <memset+0x50>
    c &= 0xFF;
801049a0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049a7:	8b 45 10             	mov    0x10(%ebp),%eax
801049aa:	c1 e8 02             	shr    $0x2,%eax
801049ad:	89 c2                	mov    %eax,%edx
801049af:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b2:	c1 e0 18             	shl    $0x18,%eax
801049b5:	89 c1                	mov    %eax,%ecx
801049b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801049ba:	c1 e0 10             	shl    $0x10,%eax
801049bd:	09 c1                	or     %eax,%ecx
801049bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801049c2:	c1 e0 08             	shl    $0x8,%eax
801049c5:	09 c8                	or     %ecx,%eax
801049c7:	0b 45 0c             	or     0xc(%ebp),%eax
801049ca:	52                   	push   %edx
801049cb:	50                   	push   %eax
801049cc:	ff 75 08             	push   0x8(%ebp)
801049cf:	e8 8f ff ff ff       	call   80104963 <stosl>
801049d4:	83 c4 0c             	add    $0xc,%esp
801049d7:	eb 12                	jmp    801049eb <memset+0x62>
  } else
    stosb(dst, c, n);
801049d9:	8b 45 10             	mov    0x10(%ebp),%eax
801049dc:	50                   	push   %eax
801049dd:	ff 75 0c             	push   0xc(%ebp)
801049e0:	ff 75 08             	push   0x8(%ebp)
801049e3:	e8 55 ff ff ff       	call   8010493d <stosb>
801049e8:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801049ee:	c9                   	leave  
801049ef:	c3                   	ret    

801049f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801049f0:	55                   	push   %ebp
801049f1:	89 e5                	mov    %esp,%ebp
801049f3:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801049f6:	8b 45 08             	mov    0x8(%ebp),%eax
801049f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801049fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801049ff:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104a02:	eb 30                	jmp    80104a34 <memcmp+0x44>
    if(*s1 != *s2)
80104a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a07:	0f b6 10             	movzbl (%eax),%edx
80104a0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a0d:	0f b6 00             	movzbl (%eax),%eax
80104a10:	38 c2                	cmp    %al,%dl
80104a12:	74 18                	je     80104a2c <memcmp+0x3c>
      return *s1 - *s2;
80104a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a17:	0f b6 00             	movzbl (%eax),%eax
80104a1a:	0f b6 d0             	movzbl %al,%edx
80104a1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a20:	0f b6 00             	movzbl (%eax),%eax
80104a23:	0f b6 c8             	movzbl %al,%ecx
80104a26:	89 d0                	mov    %edx,%eax
80104a28:	29 c8                	sub    %ecx,%eax
80104a2a:	eb 1a                	jmp    80104a46 <memcmp+0x56>
    s1++, s2++;
80104a2c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a30:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a34:	8b 45 10             	mov    0x10(%ebp),%eax
80104a37:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a3a:	89 55 10             	mov    %edx,0x10(%ebp)
80104a3d:	85 c0                	test   %eax,%eax
80104a3f:	75 c3                	jne    80104a04 <memcmp+0x14>
  }

  return 0;
80104a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a46:	c9                   	leave  
80104a47:	c3                   	ret    

80104a48 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a48:	55                   	push   %ebp
80104a49:	89 e5                	mov    %esp,%ebp
80104a4b:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a51:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a54:	8b 45 08             	mov    0x8(%ebp),%eax
80104a57:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a60:	73 54                	jae    80104ab6 <memmove+0x6e>
80104a62:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a65:	8b 45 10             	mov    0x10(%ebp),%eax
80104a68:	01 d0                	add    %edx,%eax
80104a6a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a6d:	73 47                	jae    80104ab6 <memmove+0x6e>
    s += n;
80104a6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104a72:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a75:	8b 45 10             	mov    0x10(%ebp),%eax
80104a78:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a7b:	eb 13                	jmp    80104a90 <memmove+0x48>
      *--d = *--s;
80104a7d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a81:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a88:	0f b6 10             	movzbl (%eax),%edx
80104a8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a8e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104a90:	8b 45 10             	mov    0x10(%ebp),%eax
80104a93:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a96:	89 55 10             	mov    %edx,0x10(%ebp)
80104a99:	85 c0                	test   %eax,%eax
80104a9b:	75 e0                	jne    80104a7d <memmove+0x35>
  if(s < d && s + n > d){
80104a9d:	eb 24                	jmp    80104ac3 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104a9f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104aa2:	8d 42 01             	lea    0x1(%edx),%eax
80104aa5:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104aa8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aab:	8d 48 01             	lea    0x1(%eax),%ecx
80104aae:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ab1:	0f b6 12             	movzbl (%edx),%edx
80104ab4:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ab6:	8b 45 10             	mov    0x10(%ebp),%eax
80104ab9:	8d 50 ff             	lea    -0x1(%eax),%edx
80104abc:	89 55 10             	mov    %edx,0x10(%ebp)
80104abf:	85 c0                	test   %eax,%eax
80104ac1:	75 dc                	jne    80104a9f <memmove+0x57>

  return dst;
80104ac3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ac6:	c9                   	leave  
80104ac7:	c3                   	ret    

80104ac8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ac8:	55                   	push   %ebp
80104ac9:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104acb:	ff 75 10             	push   0x10(%ebp)
80104ace:	ff 75 0c             	push   0xc(%ebp)
80104ad1:	ff 75 08             	push   0x8(%ebp)
80104ad4:	e8 6f ff ff ff       	call   80104a48 <memmove>
80104ad9:	83 c4 0c             	add    $0xc,%esp
}
80104adc:	c9                   	leave  
80104add:	c3                   	ret    

80104ade <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ade:	55                   	push   %ebp
80104adf:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ae1:	eb 0c                	jmp    80104aef <strncmp+0x11>
    n--, p++, q++;
80104ae3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ae7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104aeb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104aef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104af3:	74 1a                	je     80104b0f <strncmp+0x31>
80104af5:	8b 45 08             	mov    0x8(%ebp),%eax
80104af8:	0f b6 00             	movzbl (%eax),%eax
80104afb:	84 c0                	test   %al,%al
80104afd:	74 10                	je     80104b0f <strncmp+0x31>
80104aff:	8b 45 08             	mov    0x8(%ebp),%eax
80104b02:	0f b6 10             	movzbl (%eax),%edx
80104b05:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b08:	0f b6 00             	movzbl (%eax),%eax
80104b0b:	38 c2                	cmp    %al,%dl
80104b0d:	74 d4                	je     80104ae3 <strncmp+0x5>
  if(n == 0)
80104b0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b13:	75 07                	jne    80104b1c <strncmp+0x3e>
    return 0;
80104b15:	b8 00 00 00 00       	mov    $0x0,%eax
80104b1a:	eb 16                	jmp    80104b32 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1f:	0f b6 00             	movzbl (%eax),%eax
80104b22:	0f b6 d0             	movzbl %al,%edx
80104b25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b28:	0f b6 00             	movzbl (%eax),%eax
80104b2b:	0f b6 c8             	movzbl %al,%ecx
80104b2e:	89 d0                	mov    %edx,%eax
80104b30:	29 c8                	sub    %ecx,%eax
}
80104b32:	5d                   	pop    %ebp
80104b33:	c3                   	ret    

80104b34 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b34:	55                   	push   %ebp
80104b35:	89 e5                	mov    %esp,%ebp
80104b37:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b40:	90                   	nop
80104b41:	8b 45 10             	mov    0x10(%ebp),%eax
80104b44:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b47:	89 55 10             	mov    %edx,0x10(%ebp)
80104b4a:	85 c0                	test   %eax,%eax
80104b4c:	7e 2c                	jle    80104b7a <strncpy+0x46>
80104b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b51:	8d 42 01             	lea    0x1(%edx),%eax
80104b54:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b57:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5a:	8d 48 01             	lea    0x1(%eax),%ecx
80104b5d:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b60:	0f b6 12             	movzbl (%edx),%edx
80104b63:	88 10                	mov    %dl,(%eax)
80104b65:	0f b6 00             	movzbl (%eax),%eax
80104b68:	84 c0                	test   %al,%al
80104b6a:	75 d5                	jne    80104b41 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b6c:	eb 0c                	jmp    80104b7a <strncpy+0x46>
    *s++ = 0;
80104b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b71:	8d 50 01             	lea    0x1(%eax),%edx
80104b74:	89 55 08             	mov    %edx,0x8(%ebp)
80104b77:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b7a:	8b 45 10             	mov    0x10(%ebp),%eax
80104b7d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b80:	89 55 10             	mov    %edx,0x10(%ebp)
80104b83:	85 c0                	test   %eax,%eax
80104b85:	7f e7                	jg     80104b6e <strncpy+0x3a>
  return os;
80104b87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b8a:	c9                   	leave  
80104b8b:	c3                   	ret    

80104b8c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b8c:	55                   	push   %ebp
80104b8d:	89 e5                	mov    %esp,%ebp
80104b8f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b92:	8b 45 08             	mov    0x8(%ebp),%eax
80104b95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104b98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b9c:	7f 05                	jg     80104ba3 <safestrcpy+0x17>
    return os;
80104b9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba1:	eb 32                	jmp    80104bd5 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ba3:	90                   	nop
80104ba4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ba8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bac:	7e 1e                	jle    80104bcc <safestrcpy+0x40>
80104bae:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bb1:	8d 42 01             	lea    0x1(%edx),%eax
80104bb4:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bba:	8d 48 01             	lea    0x1(%eax),%ecx
80104bbd:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bc0:	0f b6 12             	movzbl (%edx),%edx
80104bc3:	88 10                	mov    %dl,(%eax)
80104bc5:	0f b6 00             	movzbl (%eax),%eax
80104bc8:	84 c0                	test   %al,%al
80104bca:	75 d8                	jne    80104ba4 <safestrcpy+0x18>
    ;
  *s = 0;
80104bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcf:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104bd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bd5:	c9                   	leave  
80104bd6:	c3                   	ret    

80104bd7 <strlen>:

int
strlen(const char *s)
{
80104bd7:	55                   	push   %ebp
80104bd8:	89 e5                	mov    %esp,%ebp
80104bda:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bdd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104be4:	eb 04                	jmp    80104bea <strlen+0x13>
80104be6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bea:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bed:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf0:	01 d0                	add    %edx,%eax
80104bf2:	0f b6 00             	movzbl (%eax),%eax
80104bf5:	84 c0                	test   %al,%al
80104bf7:	75 ed                	jne    80104be6 <strlen+0xf>
    ;
  return n;
80104bf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bfc:	c9                   	leave  
80104bfd:	c3                   	ret    

80104bfe <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104bfe:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104c02:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104c06:	55                   	push   %ebp
  pushl %ebx
80104c07:	53                   	push   %ebx
  pushl %esi
80104c08:	56                   	push   %esi
  pushl %edi
80104c09:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c0a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c0c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c0e:	5f                   	pop    %edi
  popl %esi
80104c0f:	5e                   	pop    %esi
  popl %ebx
80104c10:	5b                   	pop    %ebx
  popl %ebp
80104c11:	5d                   	pop    %ebp
  ret
80104c12:	c3                   	ret    

80104c13 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c13:	55                   	push   %ebp
80104c14:	89 e5                	mov    %esp,%ebp
80104c16:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c19:	e8 12 ee ff ff       	call   80103a30 <myproc>
80104c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c24:	8b 00                	mov    (%eax),%eax
80104c26:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c29:	73 0f                	jae    80104c3a <fetchint+0x27>
80104c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2e:	8d 50 04             	lea    0x4(%eax),%edx
80104c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c34:	8b 00                	mov    (%eax),%eax
80104c36:	39 c2                	cmp    %eax,%edx
80104c38:	76 07                	jbe    80104c41 <fetchint+0x2e>
    return -1;
80104c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c3f:	eb 0f                	jmp    80104c50 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c41:	8b 45 08             	mov    0x8(%ebp),%eax
80104c44:	8b 10                	mov    (%eax),%edx
80104c46:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c49:	89 10                	mov    %edx,(%eax)
  return 0;
80104c4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c50:	c9                   	leave  
80104c51:	c3                   	ret    

80104c52 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c52:	55                   	push   %ebp
80104c53:	89 e5                	mov    %esp,%ebp
80104c55:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c58:	e8 d3 ed ff ff       	call   80103a30 <myproc>
80104c5d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c63:	8b 00                	mov    (%eax),%eax
80104c65:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c68:	72 07                	jb     80104c71 <fetchstr+0x1f>
    return -1;
80104c6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6f:	eb 41                	jmp    80104cb2 <fetchstr+0x60>
  *pp = (char*)addr;
80104c71:	8b 55 08             	mov    0x8(%ebp),%edx
80104c74:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c77:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7c:	8b 00                	mov    (%eax),%eax
80104c7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c84:	8b 00                	mov    (%eax),%eax
80104c86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c89:	eb 1a                	jmp    80104ca5 <fetchstr+0x53>
    if(*s == 0)
80104c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8e:	0f b6 00             	movzbl (%eax),%eax
80104c91:	84 c0                	test   %al,%al
80104c93:	75 0c                	jne    80104ca1 <fetchstr+0x4f>
      return s - *pp;
80104c95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c98:	8b 10                	mov    (%eax),%edx
80104c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9d:	29 d0                	sub    %edx,%eax
80104c9f:	eb 11                	jmp    80104cb2 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104ca1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104cab:	72 de                	jb     80104c8b <fetchstr+0x39>
  }
  return -1;
80104cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb2:	c9                   	leave  
80104cb3:	c3                   	ret    

80104cb4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104cb4:	55                   	push   %ebp
80104cb5:	89 e5                	mov    %esp,%ebp
80104cb7:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cba:	e8 71 ed ff ff       	call   80103a30 <myproc>
80104cbf:	8b 40 18             	mov    0x18(%eax),%eax
80104cc2:	8b 50 44             	mov    0x44(%eax),%edx
80104cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc8:	c1 e0 02             	shl    $0x2,%eax
80104ccb:	01 d0                	add    %edx,%eax
80104ccd:	83 c0 04             	add    $0x4,%eax
80104cd0:	83 ec 08             	sub    $0x8,%esp
80104cd3:	ff 75 0c             	push   0xc(%ebp)
80104cd6:	50                   	push   %eax
80104cd7:	e8 37 ff ff ff       	call   80104c13 <fetchint>
80104cdc:	83 c4 10             	add    $0x10,%esp
}
80104cdf:	c9                   	leave  
80104ce0:	c3                   	ret    

80104ce1 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ce1:	55                   	push   %ebp
80104ce2:	89 e5                	mov    %esp,%ebp
80104ce4:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104ce7:	e8 44 ed ff ff       	call   80103a30 <myproc>
80104cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104cef:	83 ec 08             	sub    $0x8,%esp
80104cf2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cf5:	50                   	push   %eax
80104cf6:	ff 75 08             	push   0x8(%ebp)
80104cf9:	e8 b6 ff ff ff       	call   80104cb4 <argint>
80104cfe:	83 c4 10             	add    $0x10,%esp
80104d01:	85 c0                	test   %eax,%eax
80104d03:	79 07                	jns    80104d0c <argptr+0x2b>
    return -1;
80104d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d0a:	eb 3b                	jmp    80104d47 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d10:	78 1f                	js     80104d31 <argptr+0x50>
80104d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d15:	8b 00                	mov    (%eax),%eax
80104d17:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d1a:	39 d0                	cmp    %edx,%eax
80104d1c:	76 13                	jbe    80104d31 <argptr+0x50>
80104d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d21:	89 c2                	mov    %eax,%edx
80104d23:	8b 45 10             	mov    0x10(%ebp),%eax
80104d26:	01 c2                	add    %eax,%edx
80104d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2b:	8b 00                	mov    (%eax),%eax
80104d2d:	39 c2                	cmp    %eax,%edx
80104d2f:	76 07                	jbe    80104d38 <argptr+0x57>
    return -1;
80104d31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d36:	eb 0f                	jmp    80104d47 <argptr+0x66>
  *pp = (char*)i;
80104d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3b:	89 c2                	mov    %eax,%edx
80104d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d40:	89 10                	mov    %edx,(%eax)
  return 0;
80104d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d47:	c9                   	leave  
80104d48:	c3                   	ret    

80104d49 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d49:	55                   	push   %ebp
80104d4a:	89 e5                	mov    %esp,%ebp
80104d4c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d4f:	83 ec 08             	sub    $0x8,%esp
80104d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d55:	50                   	push   %eax
80104d56:	ff 75 08             	push   0x8(%ebp)
80104d59:	e8 56 ff ff ff       	call   80104cb4 <argint>
80104d5e:	83 c4 10             	add    $0x10,%esp
80104d61:	85 c0                	test   %eax,%eax
80104d63:	79 07                	jns    80104d6c <argstr+0x23>
    return -1;
80104d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6a:	eb 12                	jmp    80104d7e <argstr+0x35>
  return fetchstr(addr, pp);
80104d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6f:	83 ec 08             	sub    $0x8,%esp
80104d72:	ff 75 0c             	push   0xc(%ebp)
80104d75:	50                   	push   %eax
80104d76:	e8 d7 fe ff ff       	call   80104c52 <fetchstr>
80104d7b:	83 c4 10             	add    $0x10,%esp
}
80104d7e:	c9                   	leave  
80104d7f:	c3                   	ret    

80104d80 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104d80:	55                   	push   %ebp
80104d81:	89 e5                	mov    %esp,%ebp
80104d83:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d86:	e8 a5 ec ff ff       	call   80103a30 <myproc>
80104d8b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d91:	8b 40 18             	mov    0x18(%eax),%eax
80104d94:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d9e:	7e 2f                	jle    80104dcf <syscall+0x4f>
80104da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da3:	83 f8 18             	cmp    $0x18,%eax
80104da6:	77 27                	ja     80104dcf <syscall+0x4f>
80104da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dab:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104db2:	85 c0                	test   %eax,%eax
80104db4:	74 19                	je     80104dcf <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db9:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dc0:	ff d0                	call   *%eax
80104dc2:	89 c2                	mov    %eax,%edx
80104dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc7:	8b 40 18             	mov    0x18(%eax),%eax
80104dca:	89 50 1c             	mov    %edx,0x1c(%eax)
80104dcd:	eb 2c                	jmp    80104dfb <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd2:	8d 50 70             	lea    0x70(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd8:	8b 40 10             	mov    0x10(%eax),%eax
80104ddb:	ff 75 f0             	push   -0x10(%ebp)
80104dde:	52                   	push   %edx
80104ddf:	50                   	push   %eax
80104de0:	68 b8 a3 10 80       	push   $0x8010a3b8
80104de5:	e8 0a b6 ff ff       	call   801003f4 <cprintf>
80104dea:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df0:	8b 40 18             	mov    0x18(%eax),%eax
80104df3:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104dfa:	90                   	nop
80104dfb:	90                   	nop
80104dfc:	c9                   	leave  
80104dfd:	c3                   	ret    

80104dfe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104dfe:	55                   	push   %ebp
80104dff:	89 e5                	mov    %esp,%ebp
80104e01:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104e04:	83 ec 08             	sub    $0x8,%esp
80104e07:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e0a:	50                   	push   %eax
80104e0b:	ff 75 08             	push   0x8(%ebp)
80104e0e:	e8 a1 fe ff ff       	call   80104cb4 <argint>
80104e13:	83 c4 10             	add    $0x10,%esp
80104e16:	85 c0                	test   %eax,%eax
80104e18:	79 07                	jns    80104e21 <argfd+0x23>
    return -1;
80104e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e1f:	eb 4f                	jmp    80104e70 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e24:	85 c0                	test   %eax,%eax
80104e26:	78 20                	js     80104e48 <argfd+0x4a>
80104e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2b:	83 f8 0f             	cmp    $0xf,%eax
80104e2e:	7f 18                	jg     80104e48 <argfd+0x4a>
80104e30:	e8 fb eb ff ff       	call   80103a30 <myproc>
80104e35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e38:	83 c2 08             	add    $0x8,%edx
80104e3b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e46:	75 07                	jne    80104e4f <argfd+0x51>
    return -1;
80104e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4d:	eb 21                	jmp    80104e70 <argfd+0x72>
  if(pfd)
80104e4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e53:	74 08                	je     80104e5d <argfd+0x5f>
    *pfd = fd;
80104e55:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5b:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e61:	74 08                	je     80104e6b <argfd+0x6d>
    *pf = f;
80104e63:	8b 45 10             	mov    0x10(%ebp),%eax
80104e66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e69:	89 10                	mov    %edx,(%eax)
  return 0;
80104e6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e70:	c9                   	leave  
80104e71:	c3                   	ret    

80104e72 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e72:	55                   	push   %ebp
80104e73:	89 e5                	mov    %esp,%ebp
80104e75:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e78:	e8 b3 eb ff ff       	call   80103a30 <myproc>
80104e7d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e87:	eb 2a                	jmp    80104eb3 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e8f:	83 c2 08             	add    $0x8,%edx
80104e92:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104e96:	85 c0                	test   %eax,%eax
80104e98:	75 15                	jne    80104eaf <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea0:	8d 4a 08             	lea    0x8(%edx),%ecx
80104ea3:	8b 55 08             	mov    0x8(%ebp),%edx
80104ea6:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
80104eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ead:	eb 0f                	jmp    80104ebe <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104eaf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eb3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104eb7:	7e d0                	jle    80104e89 <fdalloc+0x17>
    }
  }
  return -1;
80104eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ebe:	c9                   	leave  
80104ebf:	c3                   	ret    

80104ec0 <sys_dup>:

int
sys_dup(void)
{
80104ec0:	55                   	push   %ebp
80104ec1:	89 e5                	mov    %esp,%ebp
80104ec3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ec6:	83 ec 04             	sub    $0x4,%esp
80104ec9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ecc:	50                   	push   %eax
80104ecd:	6a 00                	push   $0x0
80104ecf:	6a 00                	push   $0x0
80104ed1:	e8 28 ff ff ff       	call   80104dfe <argfd>
80104ed6:	83 c4 10             	add    $0x10,%esp
80104ed9:	85 c0                	test   %eax,%eax
80104edb:	79 07                	jns    80104ee4 <sys_dup+0x24>
    return -1;
80104edd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee2:	eb 31                	jmp    80104f15 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	50                   	push   %eax
80104eeb:	e8 82 ff ff ff       	call   80104e72 <fdalloc>
80104ef0:	83 c4 10             	add    $0x10,%esp
80104ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ef6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104efa:	79 07                	jns    80104f03 <sys_dup+0x43>
    return -1;
80104efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f01:	eb 12                	jmp    80104f15 <sys_dup+0x55>
  filedup(f);
80104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f06:	83 ec 0c             	sub    $0xc,%esp
80104f09:	50                   	push   %eax
80104f0a:	e8 3b c1 ff ff       	call   8010104a <filedup>
80104f0f:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f15:	c9                   	leave  
80104f16:	c3                   	ret    

80104f17 <sys_read>:

int
sys_read(void)
{
80104f17:	55                   	push   %ebp
80104f18:	89 e5                	mov    %esp,%ebp
80104f1a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f1d:	83 ec 04             	sub    $0x4,%esp
80104f20:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f23:	50                   	push   %eax
80104f24:	6a 00                	push   $0x0
80104f26:	6a 00                	push   $0x0
80104f28:	e8 d1 fe ff ff       	call   80104dfe <argfd>
80104f2d:	83 c4 10             	add    $0x10,%esp
80104f30:	85 c0                	test   %eax,%eax
80104f32:	78 2e                	js     80104f62 <sys_read+0x4b>
80104f34:	83 ec 08             	sub    $0x8,%esp
80104f37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f3a:	50                   	push   %eax
80104f3b:	6a 02                	push   $0x2
80104f3d:	e8 72 fd ff ff       	call   80104cb4 <argint>
80104f42:	83 c4 10             	add    $0x10,%esp
80104f45:	85 c0                	test   %eax,%eax
80104f47:	78 19                	js     80104f62 <sys_read+0x4b>
80104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4c:	83 ec 04             	sub    $0x4,%esp
80104f4f:	50                   	push   %eax
80104f50:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f53:	50                   	push   %eax
80104f54:	6a 01                	push   $0x1
80104f56:	e8 86 fd ff ff       	call   80104ce1 <argptr>
80104f5b:	83 c4 10             	add    $0x10,%esp
80104f5e:	85 c0                	test   %eax,%eax
80104f60:	79 07                	jns    80104f69 <sys_read+0x52>
    return -1;
80104f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f67:	eb 17                	jmp    80104f80 <sys_read+0x69>
  return fileread(f, p, n);
80104f69:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f72:	83 ec 04             	sub    $0x4,%esp
80104f75:	51                   	push   %ecx
80104f76:	52                   	push   %edx
80104f77:	50                   	push   %eax
80104f78:	e8 5d c2 ff ff       	call   801011da <fileread>
80104f7d:	83 c4 10             	add    $0x10,%esp
}
80104f80:	c9                   	leave  
80104f81:	c3                   	ret    

80104f82 <sys_write>:

int
sys_write(void)
{
80104f82:	55                   	push   %ebp
80104f83:	89 e5                	mov    %esp,%ebp
80104f85:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f88:	83 ec 04             	sub    $0x4,%esp
80104f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f8e:	50                   	push   %eax
80104f8f:	6a 00                	push   $0x0
80104f91:	6a 00                	push   $0x0
80104f93:	e8 66 fe ff ff       	call   80104dfe <argfd>
80104f98:	83 c4 10             	add    $0x10,%esp
80104f9b:	85 c0                	test   %eax,%eax
80104f9d:	78 2e                	js     80104fcd <sys_write+0x4b>
80104f9f:	83 ec 08             	sub    $0x8,%esp
80104fa2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fa5:	50                   	push   %eax
80104fa6:	6a 02                	push   $0x2
80104fa8:	e8 07 fd ff ff       	call   80104cb4 <argint>
80104fad:	83 c4 10             	add    $0x10,%esp
80104fb0:	85 c0                	test   %eax,%eax
80104fb2:	78 19                	js     80104fcd <sys_write+0x4b>
80104fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb7:	83 ec 04             	sub    $0x4,%esp
80104fba:	50                   	push   %eax
80104fbb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fbe:	50                   	push   %eax
80104fbf:	6a 01                	push   $0x1
80104fc1:	e8 1b fd ff ff       	call   80104ce1 <argptr>
80104fc6:	83 c4 10             	add    $0x10,%esp
80104fc9:	85 c0                	test   %eax,%eax
80104fcb:	79 07                	jns    80104fd4 <sys_write+0x52>
    return -1;
80104fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd2:	eb 17                	jmp    80104feb <sys_write+0x69>
  return filewrite(f, p, n);
80104fd4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fd7:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdd:	83 ec 04             	sub    $0x4,%esp
80104fe0:	51                   	push   %ecx
80104fe1:	52                   	push   %edx
80104fe2:	50                   	push   %eax
80104fe3:	e8 aa c2 ff ff       	call   80101292 <filewrite>
80104fe8:	83 c4 10             	add    $0x10,%esp
}
80104feb:	c9                   	leave  
80104fec:	c3                   	ret    

80104fed <sys_close>:

int
sys_close(void)
{
80104fed:	55                   	push   %ebp
80104fee:	89 e5                	mov    %esp,%ebp
80104ff0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104ff3:	83 ec 04             	sub    $0x4,%esp
80104ff6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ff9:	50                   	push   %eax
80104ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ffd:	50                   	push   %eax
80104ffe:	6a 00                	push   $0x0
80105000:	e8 f9 fd ff ff       	call   80104dfe <argfd>
80105005:	83 c4 10             	add    $0x10,%esp
80105008:	85 c0                	test   %eax,%eax
8010500a:	79 07                	jns    80105013 <sys_close+0x26>
    return -1;
8010500c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105011:	eb 27                	jmp    8010503a <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105013:	e8 18 ea ff ff       	call   80103a30 <myproc>
80105018:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010501b:	83 c2 08             	add    $0x8,%edx
8010501e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105025:	00 
  fileclose(f);
80105026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105029:	83 ec 0c             	sub    $0xc,%esp
8010502c:	50                   	push   %eax
8010502d:	e8 69 c0 ff ff       	call   8010109b <fileclose>
80105032:	83 c4 10             	add    $0x10,%esp
  return 0;
80105035:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010503a:	c9                   	leave  
8010503b:	c3                   	ret    

8010503c <sys_fstat>:

int
sys_fstat(void)
{
8010503c:	55                   	push   %ebp
8010503d:	89 e5                	mov    %esp,%ebp
8010503f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105042:	83 ec 04             	sub    $0x4,%esp
80105045:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105048:	50                   	push   %eax
80105049:	6a 00                	push   $0x0
8010504b:	6a 00                	push   $0x0
8010504d:	e8 ac fd ff ff       	call   80104dfe <argfd>
80105052:	83 c4 10             	add    $0x10,%esp
80105055:	85 c0                	test   %eax,%eax
80105057:	78 17                	js     80105070 <sys_fstat+0x34>
80105059:	83 ec 04             	sub    $0x4,%esp
8010505c:	6a 14                	push   $0x14
8010505e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105061:	50                   	push   %eax
80105062:	6a 01                	push   $0x1
80105064:	e8 78 fc ff ff       	call   80104ce1 <argptr>
80105069:	83 c4 10             	add    $0x10,%esp
8010506c:	85 c0                	test   %eax,%eax
8010506e:	79 07                	jns    80105077 <sys_fstat+0x3b>
    return -1;
80105070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105075:	eb 13                	jmp    8010508a <sys_fstat+0x4e>
  return filestat(f, st);
80105077:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010507a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507d:	83 ec 08             	sub    $0x8,%esp
80105080:	52                   	push   %edx
80105081:	50                   	push   %eax
80105082:	e8 fc c0 ff ff       	call   80101183 <filestat>
80105087:	83 c4 10             	add    $0x10,%esp
}
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105092:	83 ec 08             	sub    $0x8,%esp
80105095:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105098:	50                   	push   %eax
80105099:	6a 00                	push   $0x0
8010509b:	e8 a9 fc ff ff       	call   80104d49 <argstr>
801050a0:	83 c4 10             	add    $0x10,%esp
801050a3:	85 c0                	test   %eax,%eax
801050a5:	78 15                	js     801050bc <sys_link+0x30>
801050a7:	83 ec 08             	sub    $0x8,%esp
801050aa:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050ad:	50                   	push   %eax
801050ae:	6a 01                	push   $0x1
801050b0:	e8 94 fc ff ff       	call   80104d49 <argstr>
801050b5:	83 c4 10             	add    $0x10,%esp
801050b8:	85 c0                	test   %eax,%eax
801050ba:	79 0a                	jns    801050c6 <sys_link+0x3a>
    return -1;
801050bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c1:	e9 68 01 00 00       	jmp    8010522e <sys_link+0x1a2>

  begin_op();
801050c6:	e8 71 df ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801050cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050ce:	83 ec 0c             	sub    $0xc,%esp
801050d1:	50                   	push   %eax
801050d2:	e8 46 d4 ff ff       	call   8010251d <namei>
801050d7:	83 c4 10             	add    $0x10,%esp
801050da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050e1:	75 0f                	jne    801050f2 <sys_link+0x66>
    end_op();
801050e3:	e8 e0 df ff ff       	call   801030c8 <end_op>
    return -1;
801050e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ed:	e9 3c 01 00 00       	jmp    8010522e <sys_link+0x1a2>
  }

  ilock(ip);
801050f2:	83 ec 0c             	sub    $0xc,%esp
801050f5:	ff 75 f4             	push   -0xc(%ebp)
801050f8:	e8 ed c8 ff ff       	call   801019ea <ilock>
801050fd:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105103:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105107:	66 83 f8 01          	cmp    $0x1,%ax
8010510b:	75 1d                	jne    8010512a <sys_link+0x9e>
    iunlockput(ip);
8010510d:	83 ec 0c             	sub    $0xc,%esp
80105110:	ff 75 f4             	push   -0xc(%ebp)
80105113:	e8 03 cb ff ff       	call   80101c1b <iunlockput>
80105118:	83 c4 10             	add    $0x10,%esp
    end_op();
8010511b:	e8 a8 df ff ff       	call   801030c8 <end_op>
    return -1;
80105120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105125:	e9 04 01 00 00       	jmp    8010522e <sys_link+0x1a2>
  }

  ip->nlink++;
8010512a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105131:	83 c0 01             	add    $0x1,%eax
80105134:	89 c2                	mov    %eax,%edx
80105136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105139:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010513d:	83 ec 0c             	sub    $0xc,%esp
80105140:	ff 75 f4             	push   -0xc(%ebp)
80105143:	e8 c5 c6 ff ff       	call   8010180d <iupdate>
80105148:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010514b:	83 ec 0c             	sub    $0xc,%esp
8010514e:	ff 75 f4             	push   -0xc(%ebp)
80105151:	e8 a7 c9 ff ff       	call   80101afd <iunlock>
80105156:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105159:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010515c:	83 ec 08             	sub    $0x8,%esp
8010515f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105162:	52                   	push   %edx
80105163:	50                   	push   %eax
80105164:	e8 d0 d3 ff ff       	call   80102539 <nameiparent>
80105169:	83 c4 10             	add    $0x10,%esp
8010516c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010516f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105173:	74 71                	je     801051e6 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105175:	83 ec 0c             	sub    $0xc,%esp
80105178:	ff 75 f0             	push   -0x10(%ebp)
8010517b:	e8 6a c8 ff ff       	call   801019ea <ilock>
80105180:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105186:	8b 10                	mov    (%eax),%edx
80105188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518b:	8b 00                	mov    (%eax),%eax
8010518d:	39 c2                	cmp    %eax,%edx
8010518f:	75 1d                	jne    801051ae <sys_link+0x122>
80105191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105194:	8b 40 04             	mov    0x4(%eax),%eax
80105197:	83 ec 04             	sub    $0x4,%esp
8010519a:	50                   	push   %eax
8010519b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010519e:	50                   	push   %eax
8010519f:	ff 75 f0             	push   -0x10(%ebp)
801051a2:	e8 df d0 ff ff       	call   80102286 <dirlink>
801051a7:	83 c4 10             	add    $0x10,%esp
801051aa:	85 c0                	test   %eax,%eax
801051ac:	79 10                	jns    801051be <sys_link+0x132>
    iunlockput(dp);
801051ae:	83 ec 0c             	sub    $0xc,%esp
801051b1:	ff 75 f0             	push   -0x10(%ebp)
801051b4:	e8 62 ca ff ff       	call   80101c1b <iunlockput>
801051b9:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051bc:	eb 29                	jmp    801051e7 <sys_link+0x15b>
  }
  iunlockput(dp);
801051be:	83 ec 0c             	sub    $0xc,%esp
801051c1:	ff 75 f0             	push   -0x10(%ebp)
801051c4:	e8 52 ca ff ff       	call   80101c1b <iunlockput>
801051c9:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051cc:	83 ec 0c             	sub    $0xc,%esp
801051cf:	ff 75 f4             	push   -0xc(%ebp)
801051d2:	e8 74 c9 ff ff       	call   80101b4b <iput>
801051d7:	83 c4 10             	add    $0x10,%esp

  end_op();
801051da:	e8 e9 de ff ff       	call   801030c8 <end_op>

  return 0;
801051df:	b8 00 00 00 00       	mov    $0x0,%eax
801051e4:	eb 48                	jmp    8010522e <sys_link+0x1a2>
    goto bad;
801051e6:	90                   	nop

bad:
  ilock(ip);
801051e7:	83 ec 0c             	sub    $0xc,%esp
801051ea:	ff 75 f4             	push   -0xc(%ebp)
801051ed:	e8 f8 c7 ff ff       	call   801019ea <ilock>
801051f2:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801051f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051fc:	83 e8 01             	sub    $0x1,%eax
801051ff:	89 c2                	mov    %eax,%edx
80105201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105204:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105208:	83 ec 0c             	sub    $0xc,%esp
8010520b:	ff 75 f4             	push   -0xc(%ebp)
8010520e:	e8 fa c5 ff ff       	call   8010180d <iupdate>
80105213:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105216:	83 ec 0c             	sub    $0xc,%esp
80105219:	ff 75 f4             	push   -0xc(%ebp)
8010521c:	e8 fa c9 ff ff       	call   80101c1b <iunlockput>
80105221:	83 c4 10             	add    $0x10,%esp
  end_op();
80105224:	e8 9f de ff ff       	call   801030c8 <end_op>
  return -1;
80105229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010522e:	c9                   	leave  
8010522f:	c3                   	ret    

80105230 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105230:	55                   	push   %ebp
80105231:	89 e5                	mov    %esp,%ebp
80105233:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105236:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010523d:	eb 40                	jmp    8010527f <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010523f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105242:	6a 10                	push   $0x10
80105244:	50                   	push   %eax
80105245:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105248:	50                   	push   %eax
80105249:	ff 75 08             	push   0x8(%ebp)
8010524c:	e8 85 cc ff ff       	call   80101ed6 <readi>
80105251:	83 c4 10             	add    $0x10,%esp
80105254:	83 f8 10             	cmp    $0x10,%eax
80105257:	74 0d                	je     80105266 <isdirempty+0x36>
      panic("isdirempty: readi");
80105259:	83 ec 0c             	sub    $0xc,%esp
8010525c:	68 d4 a3 10 80       	push   $0x8010a3d4
80105261:	e8 43 b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105266:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010526a:	66 85 c0             	test   %ax,%ax
8010526d:	74 07                	je     80105276 <isdirempty+0x46>
      return 0;
8010526f:	b8 00 00 00 00       	mov    $0x0,%eax
80105274:	eb 1b                	jmp    80105291 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105279:	83 c0 10             	add    $0x10,%eax
8010527c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010527f:	8b 45 08             	mov    0x8(%ebp),%eax
80105282:	8b 50 58             	mov    0x58(%eax),%edx
80105285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105288:	39 c2                	cmp    %eax,%edx
8010528a:	77 b3                	ja     8010523f <isdirempty+0xf>
  }
  return 1;
8010528c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105291:	c9                   	leave  
80105292:	c3                   	ret    

80105293 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105293:	55                   	push   %ebp
80105294:	89 e5                	mov    %esp,%ebp
80105296:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105299:	83 ec 08             	sub    $0x8,%esp
8010529c:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010529f:	50                   	push   %eax
801052a0:	6a 00                	push   $0x0
801052a2:	e8 a2 fa ff ff       	call   80104d49 <argstr>
801052a7:	83 c4 10             	add    $0x10,%esp
801052aa:	85 c0                	test   %eax,%eax
801052ac:	79 0a                	jns    801052b8 <sys_unlink+0x25>
    return -1;
801052ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b3:	e9 bf 01 00 00       	jmp    80105477 <sys_unlink+0x1e4>

  begin_op();
801052b8:	e8 7f dd ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052c0:	83 ec 08             	sub    $0x8,%esp
801052c3:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052c6:	52                   	push   %edx
801052c7:	50                   	push   %eax
801052c8:	e8 6c d2 ff ff       	call   80102539 <nameiparent>
801052cd:	83 c4 10             	add    $0x10,%esp
801052d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d7:	75 0f                	jne    801052e8 <sys_unlink+0x55>
    end_op();
801052d9:	e8 ea dd ff ff       	call   801030c8 <end_op>
    return -1;
801052de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e3:	e9 8f 01 00 00       	jmp    80105477 <sys_unlink+0x1e4>
  }

  ilock(dp);
801052e8:	83 ec 0c             	sub    $0xc,%esp
801052eb:	ff 75 f4             	push   -0xc(%ebp)
801052ee:	e8 f7 c6 ff ff       	call   801019ea <ilock>
801052f3:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801052f6:	83 ec 08             	sub    $0x8,%esp
801052f9:	68 e6 a3 10 80       	push   $0x8010a3e6
801052fe:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105301:	50                   	push   %eax
80105302:	e8 aa ce ff ff       	call   801021b1 <namecmp>
80105307:	83 c4 10             	add    $0x10,%esp
8010530a:	85 c0                	test   %eax,%eax
8010530c:	0f 84 49 01 00 00    	je     8010545b <sys_unlink+0x1c8>
80105312:	83 ec 08             	sub    $0x8,%esp
80105315:	68 e8 a3 10 80       	push   $0x8010a3e8
8010531a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010531d:	50                   	push   %eax
8010531e:	e8 8e ce ff ff       	call   801021b1 <namecmp>
80105323:	83 c4 10             	add    $0x10,%esp
80105326:	85 c0                	test   %eax,%eax
80105328:	0f 84 2d 01 00 00    	je     8010545b <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010532e:	83 ec 04             	sub    $0x4,%esp
80105331:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105334:	50                   	push   %eax
80105335:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105338:	50                   	push   %eax
80105339:	ff 75 f4             	push   -0xc(%ebp)
8010533c:	e8 8b ce ff ff       	call   801021cc <dirlookup>
80105341:	83 c4 10             	add    $0x10,%esp
80105344:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105347:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010534b:	0f 84 0d 01 00 00    	je     8010545e <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105351:	83 ec 0c             	sub    $0xc,%esp
80105354:	ff 75 f0             	push   -0x10(%ebp)
80105357:	e8 8e c6 ff ff       	call   801019ea <ilock>
8010535c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010535f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105362:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105366:	66 85 c0             	test   %ax,%ax
80105369:	7f 0d                	jg     80105378 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010536b:	83 ec 0c             	sub    $0xc,%esp
8010536e:	68 eb a3 10 80       	push   $0x8010a3eb
80105373:	e8 31 b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010537f:	66 83 f8 01          	cmp    $0x1,%ax
80105383:	75 25                	jne    801053aa <sys_unlink+0x117>
80105385:	83 ec 0c             	sub    $0xc,%esp
80105388:	ff 75 f0             	push   -0x10(%ebp)
8010538b:	e8 a0 fe ff ff       	call   80105230 <isdirempty>
80105390:	83 c4 10             	add    $0x10,%esp
80105393:	85 c0                	test   %eax,%eax
80105395:	75 13                	jne    801053aa <sys_unlink+0x117>
    iunlockput(ip);
80105397:	83 ec 0c             	sub    $0xc,%esp
8010539a:	ff 75 f0             	push   -0x10(%ebp)
8010539d:	e8 79 c8 ff ff       	call   80101c1b <iunlockput>
801053a2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053a5:	e9 b5 00 00 00       	jmp    8010545f <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053aa:	83 ec 04             	sub    $0x4,%esp
801053ad:	6a 10                	push   $0x10
801053af:	6a 00                	push   $0x0
801053b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053b4:	50                   	push   %eax
801053b5:	e8 cf f5 ff ff       	call   80104989 <memset>
801053ba:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053c0:	6a 10                	push   $0x10
801053c2:	50                   	push   %eax
801053c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053c6:	50                   	push   %eax
801053c7:	ff 75 f4             	push   -0xc(%ebp)
801053ca:	e8 5c cc ff ff       	call   8010202b <writei>
801053cf:	83 c4 10             	add    $0x10,%esp
801053d2:	83 f8 10             	cmp    $0x10,%eax
801053d5:	74 0d                	je     801053e4 <sys_unlink+0x151>
    panic("unlink: writei");
801053d7:	83 ec 0c             	sub    $0xc,%esp
801053da:	68 fd a3 10 80       	push   $0x8010a3fd
801053df:	e8 c5 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053eb:	66 83 f8 01          	cmp    $0x1,%ax
801053ef:	75 21                	jne    80105412 <sys_unlink+0x17f>
    dp->nlink--;
801053f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053f8:	83 e8 01             	sub    $0x1,%eax
801053fb:	89 c2                	mov    %eax,%edx
801053fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105400:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105404:	83 ec 0c             	sub    $0xc,%esp
80105407:	ff 75 f4             	push   -0xc(%ebp)
8010540a:	e8 fe c3 ff ff       	call   8010180d <iupdate>
8010540f:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105412:	83 ec 0c             	sub    $0xc,%esp
80105415:	ff 75 f4             	push   -0xc(%ebp)
80105418:	e8 fe c7 ff ff       	call   80101c1b <iunlockput>
8010541d:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105420:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105423:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105427:	83 e8 01             	sub    $0x1,%eax
8010542a:	89 c2                	mov    %eax,%edx
8010542c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105433:	83 ec 0c             	sub    $0xc,%esp
80105436:	ff 75 f0             	push   -0x10(%ebp)
80105439:	e8 cf c3 ff ff       	call   8010180d <iupdate>
8010543e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105441:	83 ec 0c             	sub    $0xc,%esp
80105444:	ff 75 f0             	push   -0x10(%ebp)
80105447:	e8 cf c7 ff ff       	call   80101c1b <iunlockput>
8010544c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010544f:	e8 74 dc ff ff       	call   801030c8 <end_op>

  return 0;
80105454:	b8 00 00 00 00       	mov    $0x0,%eax
80105459:	eb 1c                	jmp    80105477 <sys_unlink+0x1e4>
    goto bad;
8010545b:	90                   	nop
8010545c:	eb 01                	jmp    8010545f <sys_unlink+0x1cc>
    goto bad;
8010545e:	90                   	nop

bad:
  iunlockput(dp);
8010545f:	83 ec 0c             	sub    $0xc,%esp
80105462:	ff 75 f4             	push   -0xc(%ebp)
80105465:	e8 b1 c7 ff ff       	call   80101c1b <iunlockput>
8010546a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010546d:	e8 56 dc ff ff       	call   801030c8 <end_op>
  return -1;
80105472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105477:	c9                   	leave  
80105478:	c3                   	ret    

80105479 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105479:	55                   	push   %ebp
8010547a:	89 e5                	mov    %esp,%ebp
8010547c:	83 ec 38             	sub    $0x38,%esp
8010547f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105482:	8b 55 10             	mov    0x10(%ebp),%edx
80105485:	8b 45 14             	mov    0x14(%ebp),%eax
80105488:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010548c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105490:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105494:	83 ec 08             	sub    $0x8,%esp
80105497:	8d 45 de             	lea    -0x22(%ebp),%eax
8010549a:	50                   	push   %eax
8010549b:	ff 75 08             	push   0x8(%ebp)
8010549e:	e8 96 d0 ff ff       	call   80102539 <nameiparent>
801054a3:	83 c4 10             	add    $0x10,%esp
801054a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ad:	75 0a                	jne    801054b9 <create+0x40>
    return 0;
801054af:	b8 00 00 00 00       	mov    $0x0,%eax
801054b4:	e9 90 01 00 00       	jmp    80105649 <create+0x1d0>
  ilock(dp);
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	ff 75 f4             	push   -0xc(%ebp)
801054bf:	e8 26 c5 ff ff       	call   801019ea <ilock>
801054c4:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054c7:	83 ec 04             	sub    $0x4,%esp
801054ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054cd:	50                   	push   %eax
801054ce:	8d 45 de             	lea    -0x22(%ebp),%eax
801054d1:	50                   	push   %eax
801054d2:	ff 75 f4             	push   -0xc(%ebp)
801054d5:	e8 f2 cc ff ff       	call   801021cc <dirlookup>
801054da:	83 c4 10             	add    $0x10,%esp
801054dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054e4:	74 50                	je     80105536 <create+0xbd>
    iunlockput(dp);
801054e6:	83 ec 0c             	sub    $0xc,%esp
801054e9:	ff 75 f4             	push   -0xc(%ebp)
801054ec:	e8 2a c7 ff ff       	call   80101c1b <iunlockput>
801054f1:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801054f4:	83 ec 0c             	sub    $0xc,%esp
801054f7:	ff 75 f0             	push   -0x10(%ebp)
801054fa:	e8 eb c4 ff ff       	call   801019ea <ilock>
801054ff:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105502:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105507:	75 15                	jne    8010551e <create+0xa5>
80105509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105510:	66 83 f8 02          	cmp    $0x2,%ax
80105514:	75 08                	jne    8010551e <create+0xa5>
      return ip;
80105516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105519:	e9 2b 01 00 00       	jmp    80105649 <create+0x1d0>
    iunlockput(ip);
8010551e:	83 ec 0c             	sub    $0xc,%esp
80105521:	ff 75 f0             	push   -0x10(%ebp)
80105524:	e8 f2 c6 ff ff       	call   80101c1b <iunlockput>
80105529:	83 c4 10             	add    $0x10,%esp
    return 0;
8010552c:	b8 00 00 00 00       	mov    $0x0,%eax
80105531:	e9 13 01 00 00       	jmp    80105649 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105536:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010553a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553d:	8b 00                	mov    (%eax),%eax
8010553f:	83 ec 08             	sub    $0x8,%esp
80105542:	52                   	push   %edx
80105543:	50                   	push   %eax
80105544:	e8 ed c1 ff ff       	call   80101736 <ialloc>
80105549:	83 c4 10             	add    $0x10,%esp
8010554c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010554f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105553:	75 0d                	jne    80105562 <create+0xe9>
    panic("create: ialloc");
80105555:	83 ec 0c             	sub    $0xc,%esp
80105558:	68 0c a4 10 80       	push   $0x8010a40c
8010555d:	e8 47 b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105562:	83 ec 0c             	sub    $0xc,%esp
80105565:	ff 75 f0             	push   -0x10(%ebp)
80105568:	e8 7d c4 ff ff       	call   801019ea <ilock>
8010556d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105573:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105577:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010557b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105582:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105589:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010558f:	83 ec 0c             	sub    $0xc,%esp
80105592:	ff 75 f0             	push   -0x10(%ebp)
80105595:	e8 73 c2 ff ff       	call   8010180d <iupdate>
8010559a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010559d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801055a2:	75 6a                	jne    8010560e <create+0x195>
    dp->nlink++;  // for ".."
801055a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055ab:	83 c0 01             	add    $0x1,%eax
801055ae:	89 c2                	mov    %eax,%edx
801055b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055b7:	83 ec 0c             	sub    $0xc,%esp
801055ba:	ff 75 f4             	push   -0xc(%ebp)
801055bd:	e8 4b c2 ff ff       	call   8010180d <iupdate>
801055c2:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c8:	8b 40 04             	mov    0x4(%eax),%eax
801055cb:	83 ec 04             	sub    $0x4,%esp
801055ce:	50                   	push   %eax
801055cf:	68 e6 a3 10 80       	push   $0x8010a3e6
801055d4:	ff 75 f0             	push   -0x10(%ebp)
801055d7:	e8 aa cc ff ff       	call   80102286 <dirlink>
801055dc:	83 c4 10             	add    $0x10,%esp
801055df:	85 c0                	test   %eax,%eax
801055e1:	78 1e                	js     80105601 <create+0x188>
801055e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e6:	8b 40 04             	mov    0x4(%eax),%eax
801055e9:	83 ec 04             	sub    $0x4,%esp
801055ec:	50                   	push   %eax
801055ed:	68 e8 a3 10 80       	push   $0x8010a3e8
801055f2:	ff 75 f0             	push   -0x10(%ebp)
801055f5:	e8 8c cc ff ff       	call   80102286 <dirlink>
801055fa:	83 c4 10             	add    $0x10,%esp
801055fd:	85 c0                	test   %eax,%eax
801055ff:	79 0d                	jns    8010560e <create+0x195>
      panic("create dots");
80105601:	83 ec 0c             	sub    $0xc,%esp
80105604:	68 1b a4 10 80       	push   $0x8010a41b
80105609:	e8 9b af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010560e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105611:	8b 40 04             	mov    0x4(%eax),%eax
80105614:	83 ec 04             	sub    $0x4,%esp
80105617:	50                   	push   %eax
80105618:	8d 45 de             	lea    -0x22(%ebp),%eax
8010561b:	50                   	push   %eax
8010561c:	ff 75 f4             	push   -0xc(%ebp)
8010561f:	e8 62 cc ff ff       	call   80102286 <dirlink>
80105624:	83 c4 10             	add    $0x10,%esp
80105627:	85 c0                	test   %eax,%eax
80105629:	79 0d                	jns    80105638 <create+0x1bf>
    panic("create: dirlink");
8010562b:	83 ec 0c             	sub    $0xc,%esp
8010562e:	68 27 a4 10 80       	push   $0x8010a427
80105633:	e8 71 af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105638:	83 ec 0c             	sub    $0xc,%esp
8010563b:	ff 75 f4             	push   -0xc(%ebp)
8010563e:	e8 d8 c5 ff ff       	call   80101c1b <iunlockput>
80105643:	83 c4 10             	add    $0x10,%esp

  return ip;
80105646:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105649:	c9                   	leave  
8010564a:	c3                   	ret    

8010564b <sys_open>:

int
sys_open(void)
{
8010564b:	55                   	push   %ebp
8010564c:	89 e5                	mov    %esp,%ebp
8010564e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105651:	83 ec 08             	sub    $0x8,%esp
80105654:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105657:	50                   	push   %eax
80105658:	6a 00                	push   $0x0
8010565a:	e8 ea f6 ff ff       	call   80104d49 <argstr>
8010565f:	83 c4 10             	add    $0x10,%esp
80105662:	85 c0                	test   %eax,%eax
80105664:	78 15                	js     8010567b <sys_open+0x30>
80105666:	83 ec 08             	sub    $0x8,%esp
80105669:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010566c:	50                   	push   %eax
8010566d:	6a 01                	push   $0x1
8010566f:	e8 40 f6 ff ff       	call   80104cb4 <argint>
80105674:	83 c4 10             	add    $0x10,%esp
80105677:	85 c0                	test   %eax,%eax
80105679:	79 0a                	jns    80105685 <sys_open+0x3a>
    return -1;
8010567b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105680:	e9 61 01 00 00       	jmp    801057e6 <sys_open+0x19b>

  begin_op();
80105685:	e8 b2 d9 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
8010568a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010568d:	25 00 02 00 00       	and    $0x200,%eax
80105692:	85 c0                	test   %eax,%eax
80105694:	74 2a                	je     801056c0 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105696:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105699:	6a 00                	push   $0x0
8010569b:	6a 00                	push   $0x0
8010569d:	6a 02                	push   $0x2
8010569f:	50                   	push   %eax
801056a0:	e8 d4 fd ff ff       	call   80105479 <create>
801056a5:	83 c4 10             	add    $0x10,%esp
801056a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056af:	75 75                	jne    80105726 <sys_open+0xdb>
      end_op();
801056b1:	e8 12 da ff ff       	call   801030c8 <end_op>
      return -1;
801056b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056bb:	e9 26 01 00 00       	jmp    801057e6 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056c3:	83 ec 0c             	sub    $0xc,%esp
801056c6:	50                   	push   %eax
801056c7:	e8 51 ce ff ff       	call   8010251d <namei>
801056cc:	83 c4 10             	add    $0x10,%esp
801056cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d6:	75 0f                	jne    801056e7 <sys_open+0x9c>
      end_op();
801056d8:	e8 eb d9 ff ff       	call   801030c8 <end_op>
      return -1;
801056dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e2:	e9 ff 00 00 00       	jmp    801057e6 <sys_open+0x19b>
    }
    ilock(ip);
801056e7:	83 ec 0c             	sub    $0xc,%esp
801056ea:	ff 75 f4             	push   -0xc(%ebp)
801056ed:	e8 f8 c2 ff ff       	call   801019ea <ilock>
801056f2:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801056f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056fc:	66 83 f8 01          	cmp    $0x1,%ax
80105700:	75 24                	jne    80105726 <sys_open+0xdb>
80105702:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105705:	85 c0                	test   %eax,%eax
80105707:	74 1d                	je     80105726 <sys_open+0xdb>
      iunlockput(ip);
80105709:	83 ec 0c             	sub    $0xc,%esp
8010570c:	ff 75 f4             	push   -0xc(%ebp)
8010570f:	e8 07 c5 ff ff       	call   80101c1b <iunlockput>
80105714:	83 c4 10             	add    $0x10,%esp
      end_op();
80105717:	e8 ac d9 ff ff       	call   801030c8 <end_op>
      return -1;
8010571c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105721:	e9 c0 00 00 00       	jmp    801057e6 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105726:	e8 b2 b8 ff ff       	call   80100fdd <filealloc>
8010572b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010572e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105732:	74 17                	je     8010574b <sys_open+0x100>
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	ff 75 f0             	push   -0x10(%ebp)
8010573a:	e8 33 f7 ff ff       	call   80104e72 <fdalloc>
8010573f:	83 c4 10             	add    $0x10,%esp
80105742:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105745:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105749:	79 2e                	jns    80105779 <sys_open+0x12e>
    if(f)
8010574b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010574f:	74 0e                	je     8010575f <sys_open+0x114>
      fileclose(f);
80105751:	83 ec 0c             	sub    $0xc,%esp
80105754:	ff 75 f0             	push   -0x10(%ebp)
80105757:	e8 3f b9 ff ff       	call   8010109b <fileclose>
8010575c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010575f:	83 ec 0c             	sub    $0xc,%esp
80105762:	ff 75 f4             	push   -0xc(%ebp)
80105765:	e8 b1 c4 ff ff       	call   80101c1b <iunlockput>
8010576a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010576d:	e8 56 d9 ff ff       	call   801030c8 <end_op>
    return -1;
80105772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105777:	eb 6d                	jmp    801057e6 <sys_open+0x19b>
  }
  iunlock(ip);
80105779:	83 ec 0c             	sub    $0xc,%esp
8010577c:	ff 75 f4             	push   -0xc(%ebp)
8010577f:	e8 79 c3 ff ff       	call   80101afd <iunlock>
80105784:	83 c4 10             	add    $0x10,%esp
  end_op();
80105787:	e8 3c d9 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
8010578c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010579e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801057a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057ab:	83 e0 01             	and    $0x1,%eax
801057ae:	85 c0                	test   %eax,%eax
801057b0:	0f 94 c0             	sete   %al
801057b3:	89 c2                	mov    %eax,%edx
801057b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b8:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057be:	83 e0 01             	and    $0x1,%eax
801057c1:	85 c0                	test   %eax,%eax
801057c3:	75 0a                	jne    801057cf <sys_open+0x184>
801057c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057c8:	83 e0 02             	and    $0x2,%eax
801057cb:	85 c0                	test   %eax,%eax
801057cd:	74 07                	je     801057d6 <sys_open+0x18b>
801057cf:	b8 01 00 00 00       	mov    $0x1,%eax
801057d4:	eb 05                	jmp    801057db <sys_open+0x190>
801057d6:	b8 00 00 00 00       	mov    $0x0,%eax
801057db:	89 c2                	mov    %eax,%edx
801057dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e0:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057e6:	c9                   	leave  
801057e7:	c3                   	ret    

801057e8 <sys_mkdir>:

int
sys_mkdir(void)
{
801057e8:	55                   	push   %ebp
801057e9:	89 e5                	mov    %esp,%ebp
801057eb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801057ee:	e8 49 d8 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801057f3:	83 ec 08             	sub    $0x8,%esp
801057f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f9:	50                   	push   %eax
801057fa:	6a 00                	push   $0x0
801057fc:	e8 48 f5 ff ff       	call   80104d49 <argstr>
80105801:	83 c4 10             	add    $0x10,%esp
80105804:	85 c0                	test   %eax,%eax
80105806:	78 1b                	js     80105823 <sys_mkdir+0x3b>
80105808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580b:	6a 00                	push   $0x0
8010580d:	6a 00                	push   $0x0
8010580f:	6a 01                	push   $0x1
80105811:	50                   	push   %eax
80105812:	e8 62 fc ff ff       	call   80105479 <create>
80105817:	83 c4 10             	add    $0x10,%esp
8010581a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105821:	75 0c                	jne    8010582f <sys_mkdir+0x47>
    end_op();
80105823:	e8 a0 d8 ff ff       	call   801030c8 <end_op>
    return -1;
80105828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582d:	eb 18                	jmp    80105847 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	ff 75 f4             	push   -0xc(%ebp)
80105835:	e8 e1 c3 ff ff       	call   80101c1b <iunlockput>
8010583a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010583d:	e8 86 d8 ff ff       	call   801030c8 <end_op>
  return 0;
80105842:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105847:	c9                   	leave  
80105848:	c3                   	ret    

80105849 <sys_mknod>:

int
sys_mknod(void)
{
80105849:	55                   	push   %ebp
8010584a:	89 e5                	mov    %esp,%ebp
8010584c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010584f:	e8 e8 d7 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105854:	83 ec 08             	sub    $0x8,%esp
80105857:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010585a:	50                   	push   %eax
8010585b:	6a 00                	push   $0x0
8010585d:	e8 e7 f4 ff ff       	call   80104d49 <argstr>
80105862:	83 c4 10             	add    $0x10,%esp
80105865:	85 c0                	test   %eax,%eax
80105867:	78 4f                	js     801058b8 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105869:	83 ec 08             	sub    $0x8,%esp
8010586c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010586f:	50                   	push   %eax
80105870:	6a 01                	push   $0x1
80105872:	e8 3d f4 ff ff       	call   80104cb4 <argint>
80105877:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010587a:	85 c0                	test   %eax,%eax
8010587c:	78 3a                	js     801058b8 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010587e:	83 ec 08             	sub    $0x8,%esp
80105881:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105884:	50                   	push   %eax
80105885:	6a 02                	push   $0x2
80105887:	e8 28 f4 ff ff       	call   80104cb4 <argint>
8010588c:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010588f:	85 c0                	test   %eax,%eax
80105891:	78 25                	js     801058b8 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105893:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105896:	0f bf c8             	movswl %ax,%ecx
80105899:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010589c:	0f bf d0             	movswl %ax,%edx
8010589f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a2:	51                   	push   %ecx
801058a3:	52                   	push   %edx
801058a4:	6a 03                	push   $0x3
801058a6:	50                   	push   %eax
801058a7:	e8 cd fb ff ff       	call   80105479 <create>
801058ac:	83 c4 10             	add    $0x10,%esp
801058af:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b6:	75 0c                	jne    801058c4 <sys_mknod+0x7b>
    end_op();
801058b8:	e8 0b d8 ff ff       	call   801030c8 <end_op>
    return -1;
801058bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c2:	eb 18                	jmp    801058dc <sys_mknod+0x93>
  }
  iunlockput(ip);
801058c4:	83 ec 0c             	sub    $0xc,%esp
801058c7:	ff 75 f4             	push   -0xc(%ebp)
801058ca:	e8 4c c3 ff ff       	call   80101c1b <iunlockput>
801058cf:	83 c4 10             	add    $0x10,%esp
  end_op();
801058d2:	e8 f1 d7 ff ff       	call   801030c8 <end_op>
  return 0;
801058d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058dc:	c9                   	leave  
801058dd:	c3                   	ret    

801058de <sys_chdir>:

int
sys_chdir(void)
{
801058de:	55                   	push   %ebp
801058df:	89 e5                	mov    %esp,%ebp
801058e1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058e4:	e8 47 e1 ff ff       	call   80103a30 <myproc>
801058e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801058ec:	e8 4b d7 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801058f1:	83 ec 08             	sub    $0x8,%esp
801058f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058f7:	50                   	push   %eax
801058f8:	6a 00                	push   $0x0
801058fa:	e8 4a f4 ff ff       	call   80104d49 <argstr>
801058ff:	83 c4 10             	add    $0x10,%esp
80105902:	85 c0                	test   %eax,%eax
80105904:	78 18                	js     8010591e <sys_chdir+0x40>
80105906:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105909:	83 ec 0c             	sub    $0xc,%esp
8010590c:	50                   	push   %eax
8010590d:	e8 0b cc ff ff       	call   8010251d <namei>
80105912:	83 c4 10             	add    $0x10,%esp
80105915:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105918:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010591c:	75 0c                	jne    8010592a <sys_chdir+0x4c>
    end_op();
8010591e:	e8 a5 d7 ff ff       	call   801030c8 <end_op>
    return -1;
80105923:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105928:	eb 68                	jmp    80105992 <sys_chdir+0xb4>
  }
  ilock(ip);
8010592a:	83 ec 0c             	sub    $0xc,%esp
8010592d:	ff 75 f0             	push   -0x10(%ebp)
80105930:	e8 b5 c0 ff ff       	call   801019ea <ilock>
80105935:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010593f:	66 83 f8 01          	cmp    $0x1,%ax
80105943:	74 1a                	je     8010595f <sys_chdir+0x81>
    iunlockput(ip);
80105945:	83 ec 0c             	sub    $0xc,%esp
80105948:	ff 75 f0             	push   -0x10(%ebp)
8010594b:	e8 cb c2 ff ff       	call   80101c1b <iunlockput>
80105950:	83 c4 10             	add    $0x10,%esp
    end_op();
80105953:	e8 70 d7 ff ff       	call   801030c8 <end_op>
    return -1;
80105958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595d:	eb 33                	jmp    80105992 <sys_chdir+0xb4>
  }
  iunlock(ip);
8010595f:	83 ec 0c             	sub    $0xc,%esp
80105962:	ff 75 f0             	push   -0x10(%ebp)
80105965:	e8 93 c1 ff ff       	call   80101afd <iunlock>
8010596a:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010596d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105970:	8b 40 6c             	mov    0x6c(%eax),%eax
80105973:	83 ec 0c             	sub    $0xc,%esp
80105976:	50                   	push   %eax
80105977:	e8 cf c1 ff ff       	call   80101b4b <iput>
8010597c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010597f:	e8 44 d7 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010598a:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
8010598d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105992:	c9                   	leave  
80105993:	c3                   	ret    

80105994 <sys_exec>:

int
sys_exec(void)
{
80105994:	55                   	push   %ebp
80105995:	89 e5                	mov    %esp,%ebp
80105997:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010599d:	83 ec 08             	sub    $0x8,%esp
801059a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a3:	50                   	push   %eax
801059a4:	6a 00                	push   $0x0
801059a6:	e8 9e f3 ff ff       	call   80104d49 <argstr>
801059ab:	83 c4 10             	add    $0x10,%esp
801059ae:	85 c0                	test   %eax,%eax
801059b0:	78 18                	js     801059ca <sys_exec+0x36>
801059b2:	83 ec 08             	sub    $0x8,%esp
801059b5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059bb:	50                   	push   %eax
801059bc:	6a 01                	push   $0x1
801059be:	e8 f1 f2 ff ff       	call   80104cb4 <argint>
801059c3:	83 c4 10             	add    $0x10,%esp
801059c6:	85 c0                	test   %eax,%eax
801059c8:	79 0a                	jns    801059d4 <sys_exec+0x40>
    return -1;
801059ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cf:	e9 c6 00 00 00       	jmp    80105a9a <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059d4:	83 ec 04             	sub    $0x4,%esp
801059d7:	68 80 00 00 00       	push   $0x80
801059dc:	6a 00                	push   $0x0
801059de:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059e4:	50                   	push   %eax
801059e5:	e8 9f ef ff ff       	call   80104989 <memset>
801059ea:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801059ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801059f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f7:	83 f8 1f             	cmp    $0x1f,%eax
801059fa:	76 0a                	jbe    80105a06 <sys_exec+0x72>
      return -1;
801059fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a01:	e9 94 00 00 00       	jmp    80105a9a <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a09:	c1 e0 02             	shl    $0x2,%eax
80105a0c:	89 c2                	mov    %eax,%edx
80105a0e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a14:	01 c2                	add    %eax,%edx
80105a16:	83 ec 08             	sub    $0x8,%esp
80105a19:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a1f:	50                   	push   %eax
80105a20:	52                   	push   %edx
80105a21:	e8 ed f1 ff ff       	call   80104c13 <fetchint>
80105a26:	83 c4 10             	add    $0x10,%esp
80105a29:	85 c0                	test   %eax,%eax
80105a2b:	79 07                	jns    80105a34 <sys_exec+0xa0>
      return -1;
80105a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a32:	eb 66                	jmp    80105a9a <sys_exec+0x106>
    if(uarg == 0){
80105a34:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a3a:	85 c0                	test   %eax,%eax
80105a3c:	75 27                	jne    80105a65 <sys_exec+0xd1>
      argv[i] = 0;
80105a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a41:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a48:	00 00 00 00 
      break;
80105a4c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a50:	83 ec 08             	sub    $0x8,%esp
80105a53:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a59:	52                   	push   %edx
80105a5a:	50                   	push   %eax
80105a5b:	e8 20 b1 ff ff       	call   80100b80 <exec>
80105a60:	83 c4 10             	add    $0x10,%esp
80105a63:	eb 35                	jmp    80105a9a <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a65:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6e:	c1 e0 02             	shl    $0x2,%eax
80105a71:	01 c2                	add    %eax,%edx
80105a73:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a79:	83 ec 08             	sub    $0x8,%esp
80105a7c:	52                   	push   %edx
80105a7d:	50                   	push   %eax
80105a7e:	e8 cf f1 ff ff       	call   80104c52 <fetchstr>
80105a83:	83 c4 10             	add    $0x10,%esp
80105a86:	85 c0                	test   %eax,%eax
80105a88:	79 07                	jns    80105a91 <sys_exec+0xfd>
      return -1;
80105a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8f:	eb 09                	jmp    80105a9a <sys_exec+0x106>
  for(i=0;; i++){
80105a91:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a95:	e9 5a ff ff ff       	jmp    801059f4 <sys_exec+0x60>
}
80105a9a:	c9                   	leave  
80105a9b:	c3                   	ret    

80105a9c <sys_pipe>:

int
sys_pipe(void)
{
80105a9c:	55                   	push   %ebp
80105a9d:	89 e5                	mov    %esp,%ebp
80105a9f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105aa2:	83 ec 04             	sub    $0x4,%esp
80105aa5:	6a 08                	push   $0x8
80105aa7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aaa:	50                   	push   %eax
80105aab:	6a 00                	push   $0x0
80105aad:	e8 2f f2 ff ff       	call   80104ce1 <argptr>
80105ab2:	83 c4 10             	add    $0x10,%esp
80105ab5:	85 c0                	test   %eax,%eax
80105ab7:	79 0a                	jns    80105ac3 <sys_pipe+0x27>
    return -1;
80105ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abe:	e9 ae 00 00 00       	jmp    80105b71 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ac3:	83 ec 08             	sub    $0x8,%esp
80105ac6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ac9:	50                   	push   %eax
80105aca:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105acd:	50                   	push   %eax
80105ace:	e8 9a da ff ff       	call   8010356d <pipealloc>
80105ad3:	83 c4 10             	add    $0x10,%esp
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	79 0a                	jns    80105ae4 <sys_pipe+0x48>
    return -1;
80105ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adf:	e9 8d 00 00 00       	jmp    80105b71 <sys_pipe+0xd5>
  fd0 = -1;
80105ae4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aee:	83 ec 0c             	sub    $0xc,%esp
80105af1:	50                   	push   %eax
80105af2:	e8 7b f3 ff ff       	call   80104e72 <fdalloc>
80105af7:	83 c4 10             	add    $0x10,%esp
80105afa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b01:	78 18                	js     80105b1b <sys_pipe+0x7f>
80105b03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b06:	83 ec 0c             	sub    $0xc,%esp
80105b09:	50                   	push   %eax
80105b0a:	e8 63 f3 ff ff       	call   80104e72 <fdalloc>
80105b0f:	83 c4 10             	add    $0x10,%esp
80105b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b19:	79 3e                	jns    80105b59 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b1f:	78 13                	js     80105b34 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b21:	e8 0a df ff ff       	call   80103a30 <myproc>
80105b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b29:	83 c2 08             	add    $0x8,%edx
80105b2c:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105b33:	00 
    fileclose(rf);
80105b34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b37:	83 ec 0c             	sub    $0xc,%esp
80105b3a:	50                   	push   %eax
80105b3b:	e8 5b b5 ff ff       	call   8010109b <fileclose>
80105b40:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b46:	83 ec 0c             	sub    $0xc,%esp
80105b49:	50                   	push   %eax
80105b4a:	e8 4c b5 ff ff       	call   8010109b <fileclose>
80105b4f:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b57:	eb 18                	jmp    80105b71 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b5f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b64:	8d 50 04             	lea    0x4(%eax),%edx
80105b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6a:	89 02                	mov    %eax,(%edx)
  return 0;
80105b6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b71:	c9                   	leave  
80105b72:	c3                   	ret    

80105b73 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b73:	55                   	push   %ebp
80105b74:	89 e5                	mov    %esp,%ebp
80105b76:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b79:	e8 be e1 ff ff       	call   80103d3c <fork>
}
80105b7e:	c9                   	leave  
80105b7f:	c3                   	ret    

80105b80 <sys_exit>:

int
sys_exit(void)
{
80105b80:	55                   	push   %ebp
80105b81:	89 e5                	mov    %esp,%ebp
80105b83:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b86:	e8 2a e3 ff ff       	call   80103eb5 <exit>
  return 0;  // not reached
80105b8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b90:	c9                   	leave  
80105b91:	c3                   	ret    

80105b92 <sys_wait>:

int
sys_wait(void)
{
80105b92:	55                   	push   %ebp
80105b93:	89 e5                	mov    %esp,%ebp
80105b95:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105b98:	e8 3b e4 ff ff       	call   80103fd8 <wait>
}
80105b9d:	c9                   	leave  
80105b9e:	c3                   	ret    

80105b9f <sys_kill>:

int
sys_kill(void)
{
80105b9f:	55                   	push   %ebp
80105ba0:	89 e5                	mov    %esp,%ebp
80105ba2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105ba5:	83 ec 08             	sub    $0x8,%esp
80105ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bab:	50                   	push   %eax
80105bac:	6a 00                	push   $0x0
80105bae:	e8 01 f1 ff ff       	call   80104cb4 <argint>
80105bb3:	83 c4 10             	add    $0x10,%esp
80105bb6:	85 c0                	test   %eax,%eax
80105bb8:	79 07                	jns    80105bc1 <sys_kill+0x22>
    return -1;
80105bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbf:	eb 0f                	jmp    80105bd0 <sys_kill+0x31>
  return kill(pid);
80105bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc4:	83 ec 0c             	sub    $0xc,%esp
80105bc7:	50                   	push   %eax
80105bc8:	e8 43 e8 ff ff       	call   80104410 <kill>
80105bcd:	83 c4 10             	add    $0x10,%esp
}
80105bd0:	c9                   	leave  
80105bd1:	c3                   	ret    

80105bd2 <sys_getpid>:

int
sys_getpid(void)
{
80105bd2:	55                   	push   %ebp
80105bd3:	89 e5                	mov    %esp,%ebp
80105bd5:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105bd8:	e8 53 de ff ff       	call   80103a30 <myproc>
80105bdd:	8b 40 10             	mov    0x10(%eax),%eax
}
80105be0:	c9                   	leave  
80105be1:	c3                   	ret    

80105be2 <sys_sbrk>:

int
sys_sbrk(void)
{
80105be2:	55                   	push   %ebp
80105be3:	89 e5                	mov    %esp,%ebp
80105be5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105be8:	83 ec 08             	sub    $0x8,%esp
80105beb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bee:	50                   	push   %eax
80105bef:	6a 00                	push   $0x0
80105bf1:	e8 be f0 ff ff       	call   80104cb4 <argint>
80105bf6:	83 c4 10             	add    $0x10,%esp
80105bf9:	85 c0                	test   %eax,%eax
80105bfb:	79 07                	jns    80105c04 <sys_sbrk+0x22>
    return -1;
80105bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c02:	eb 27                	jmp    80105c2b <sys_sbrk+0x49>
  addr = myproc()->sz;
80105c04:	e8 27 de ff ff       	call   80103a30 <myproc>
80105c09:	8b 00                	mov    (%eax),%eax
80105c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c11:	83 ec 0c             	sub    $0xc,%esp
80105c14:	50                   	push   %eax
80105c15:	e8 87 e0 ff ff       	call   80103ca1 <growproc>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	85 c0                	test   %eax,%eax
80105c1f:	79 07                	jns    80105c28 <sys_sbrk+0x46>
    return -1;
80105c21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c26:	eb 03                	jmp    80105c2b <sys_sbrk+0x49>
  return addr;
80105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c2b:	c9                   	leave  
80105c2c:	c3                   	ret    

80105c2d <sys_sleep>:

int
sys_sleep(void)
{
80105c2d:	55                   	push   %ebp
80105c2e:	89 e5                	mov    %esp,%ebp
80105c30:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c33:	83 ec 08             	sub    $0x8,%esp
80105c36:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c39:	50                   	push   %eax
80105c3a:	6a 00                	push   $0x0
80105c3c:	e8 73 f0 ff ff       	call   80104cb4 <argint>
80105c41:	83 c4 10             	add    $0x10,%esp
80105c44:	85 c0                	test   %eax,%eax
80105c46:	79 07                	jns    80105c4f <sys_sleep+0x22>
    return -1;
80105c48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4d:	eb 76                	jmp    80105cc5 <sys_sleep+0x98>
  acquire(&tickslock);
80105c4f:	83 ec 0c             	sub    $0xc,%esp
80105c52:	68 40 6c 19 80       	push   $0x80196c40
80105c57:	e8 b7 ea ff ff       	call   80104713 <acquire>
80105c5c:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c5f:	a1 74 6c 19 80       	mov    0x80196c74,%eax
80105c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c67:	eb 38                	jmp    80105ca1 <sys_sleep+0x74>
    if(myproc()->killed){
80105c69:	e8 c2 dd ff ff       	call   80103a30 <myproc>
80105c6e:	8b 40 24             	mov    0x24(%eax),%eax
80105c71:	85 c0                	test   %eax,%eax
80105c73:	74 17                	je     80105c8c <sys_sleep+0x5f>
      release(&tickslock);
80105c75:	83 ec 0c             	sub    $0xc,%esp
80105c78:	68 40 6c 19 80       	push   $0x80196c40
80105c7d:	e8 ff ea ff ff       	call   80104781 <release>
80105c82:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8a:	eb 39                	jmp    80105cc5 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105c8c:	83 ec 08             	sub    $0x8,%esp
80105c8f:	68 40 6c 19 80       	push   $0x80196c40
80105c94:	68 74 6c 19 80       	push   $0x80196c74
80105c99:	e8 51 e6 ff ff       	call   801042ef <sleep>
80105c9e:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105ca1:	a1 74 6c 19 80       	mov    0x80196c74,%eax
80105ca6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105ca9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cac:	39 d0                	cmp    %edx,%eax
80105cae:	72 b9                	jb     80105c69 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105cb0:	83 ec 0c             	sub    $0xc,%esp
80105cb3:	68 40 6c 19 80       	push   $0x80196c40
80105cb8:	e8 c4 ea ff ff       	call   80104781 <release>
80105cbd:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cc5:	c9                   	leave  
80105cc6:	c3                   	ret    

80105cc7 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cc7:	55                   	push   %ebp
80105cc8:	89 e5                	mov    %esp,%ebp
80105cca:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105ccd:	83 ec 0c             	sub    $0xc,%esp
80105cd0:	68 40 6c 19 80       	push   $0x80196c40
80105cd5:	e8 39 ea ff ff       	call   80104713 <acquire>
80105cda:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105cdd:	a1 74 6c 19 80       	mov    0x80196c74,%eax
80105ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105ce5:	83 ec 0c             	sub    $0xc,%esp
80105ce8:	68 40 6c 19 80       	push   $0x80196c40
80105ced:	e8 8f ea ff ff       	call   80104781 <release>
80105cf2:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cf8:	c9                   	leave  
80105cf9:	c3                   	ret    

80105cfa <sys_uthread_init>:

int
sys_uthread_init(void)
{
80105cfa:	55                   	push   %ebp
80105cfb:	89 e5                	mov    %esp,%ebp
80105cfd:	53                   	push   %ebx
80105cfe:	83 ec 14             	sub    $0x14,%esp
int ptr;
if (argint(0, &ptr) < 0)
80105d01:	83 ec 08             	sub    $0x8,%esp
80105d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d07:	50                   	push   %eax
80105d08:	6a 00                	push   $0x0
80105d0a:	e8 a5 ef ff ff       	call   80104cb4 <argint>
80105d0f:	83 c4 10             	add    $0x10,%esp
80105d12:	85 c0                	test   %eax,%eax
80105d14:	79 07                	jns    80105d1d <sys_uthread_init+0x23>
  return -1;
80105d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1b:	eb 15                	jmp    80105d32 <sys_uthread_init+0x38>

myproc()->scheduler = (void (*)(void)) ptr;
80105d1d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80105d20:	e8 0b dd ff ff       	call   80103a30 <myproc>
80105d25:	89 da                	mov    %ebx,%edx
80105d27:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

return 0;
80105d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d35:	c9                   	leave  
80105d36:	c3                   	ret    

80105d37 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d37:	1e                   	push   %ds
  pushl %es
80105d38:	06                   	push   %es
  pushl %fs
80105d39:	0f a0                	push   %fs
  pushl %gs
80105d3b:	0f a8                	push   %gs
  pushal
80105d3d:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d3e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d42:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d44:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d46:	54                   	push   %esp
  call trap
80105d47:	e8 d7 01 00 00       	call   80105f23 <trap>
  addl $4, %esp
80105d4c:	83 c4 04             	add    $0x4,%esp

80105d4f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d4f:	61                   	popa   
  popl %gs
80105d50:	0f a9                	pop    %gs
  popl %fs
80105d52:	0f a1                	pop    %fs
  popl %es
80105d54:	07                   	pop    %es
  popl %ds
80105d55:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d56:	83 c4 08             	add    $0x8,%esp
  iret
80105d59:	cf                   	iret   

80105d5a <lidt>:
{
80105d5a:	55                   	push   %ebp
80105d5b:	89 e5                	mov    %esp,%ebp
80105d5d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d63:	83 e8 01             	sub    $0x1,%eax
80105d66:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d6d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d71:	8b 45 08             	mov    0x8(%ebp),%eax
80105d74:	c1 e8 10             	shr    $0x10,%eax
80105d77:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d7b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d7e:	0f 01 18             	lidtl  (%eax)
}
80105d81:	90                   	nop
80105d82:	c9                   	leave  
80105d83:	c3                   	ret    

80105d84 <rcr2>:

static inline uint
rcr2(void)
{
80105d84:	55                   	push   %ebp
80105d85:	89 e5                	mov    %esp,%ebp
80105d87:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d8a:	0f 20 d0             	mov    %cr2,%eax
80105d8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105d90:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d93:	c9                   	leave  
80105d94:	c3                   	ret    

80105d95 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105d95:	55                   	push   %ebp
80105d96:	89 e5                	mov    %esp,%ebp
80105d98:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105d9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105da2:	e9 c3 00 00 00       	jmp    80105e6a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80105db1:	89 c2                	mov    %eax,%edx
80105db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db6:	66 89 14 c5 40 64 19 	mov    %dx,-0x7fe69bc0(,%eax,8)
80105dbd:	80 
80105dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc1:	66 c7 04 c5 42 64 19 	movw   $0x8,-0x7fe69bbe(,%eax,8)
80105dc8:	80 08 00 
80105dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dce:	0f b6 14 c5 44 64 19 	movzbl -0x7fe69bbc(,%eax,8),%edx
80105dd5:	80 
80105dd6:	83 e2 e0             	and    $0xffffffe0,%edx
80105dd9:	88 14 c5 44 64 19 80 	mov    %dl,-0x7fe69bbc(,%eax,8)
80105de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de3:	0f b6 14 c5 44 64 19 	movzbl -0x7fe69bbc(,%eax,8),%edx
80105dea:	80 
80105deb:	83 e2 1f             	and    $0x1f,%edx
80105dee:	88 14 c5 44 64 19 80 	mov    %dl,-0x7fe69bbc(,%eax,8)
80105df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df8:	0f b6 14 c5 45 64 19 	movzbl -0x7fe69bbb(,%eax,8),%edx
80105dff:	80 
80105e00:	83 e2 f0             	and    $0xfffffff0,%edx
80105e03:	83 ca 0e             	or     $0xe,%edx
80105e06:	88 14 c5 45 64 19 80 	mov    %dl,-0x7fe69bbb(,%eax,8)
80105e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e10:	0f b6 14 c5 45 64 19 	movzbl -0x7fe69bbb(,%eax,8),%edx
80105e17:	80 
80105e18:	83 e2 ef             	and    $0xffffffef,%edx
80105e1b:	88 14 c5 45 64 19 80 	mov    %dl,-0x7fe69bbb(,%eax,8)
80105e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e25:	0f b6 14 c5 45 64 19 	movzbl -0x7fe69bbb(,%eax,8),%edx
80105e2c:	80 
80105e2d:	83 e2 9f             	and    $0xffffff9f,%edx
80105e30:	88 14 c5 45 64 19 80 	mov    %dl,-0x7fe69bbb(,%eax,8)
80105e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3a:	0f b6 14 c5 45 64 19 	movzbl -0x7fe69bbb(,%eax,8),%edx
80105e41:	80 
80105e42:	83 ca 80             	or     $0xffffff80,%edx
80105e45:	88 14 c5 45 64 19 80 	mov    %dl,-0x7fe69bbb(,%eax,8)
80105e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4f:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80105e56:	c1 e8 10             	shr    $0x10,%eax
80105e59:	89 c2                	mov    %eax,%edx
80105e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5e:	66 89 14 c5 46 64 19 	mov    %dx,-0x7fe69bba(,%eax,8)
80105e65:	80 
  for(i = 0; i < 256; i++)
80105e66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105e6a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105e71:	0f 8e 30 ff ff ff    	jle    80105da7 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e77:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80105e7c:	66 a3 40 66 19 80    	mov    %ax,0x80196640
80105e82:	66 c7 05 42 66 19 80 	movw   $0x8,0x80196642
80105e89:	08 00 
80105e8b:	0f b6 05 44 66 19 80 	movzbl 0x80196644,%eax
80105e92:	83 e0 e0             	and    $0xffffffe0,%eax
80105e95:	a2 44 66 19 80       	mov    %al,0x80196644
80105e9a:	0f b6 05 44 66 19 80 	movzbl 0x80196644,%eax
80105ea1:	83 e0 1f             	and    $0x1f,%eax
80105ea4:	a2 44 66 19 80       	mov    %al,0x80196644
80105ea9:	0f b6 05 45 66 19 80 	movzbl 0x80196645,%eax
80105eb0:	83 c8 0f             	or     $0xf,%eax
80105eb3:	a2 45 66 19 80       	mov    %al,0x80196645
80105eb8:	0f b6 05 45 66 19 80 	movzbl 0x80196645,%eax
80105ebf:	83 e0 ef             	and    $0xffffffef,%eax
80105ec2:	a2 45 66 19 80       	mov    %al,0x80196645
80105ec7:	0f b6 05 45 66 19 80 	movzbl 0x80196645,%eax
80105ece:	83 c8 60             	or     $0x60,%eax
80105ed1:	a2 45 66 19 80       	mov    %al,0x80196645
80105ed6:	0f b6 05 45 66 19 80 	movzbl 0x80196645,%eax
80105edd:	83 c8 80             	or     $0xffffff80,%eax
80105ee0:	a2 45 66 19 80       	mov    %al,0x80196645
80105ee5:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80105eea:	c1 e8 10             	shr    $0x10,%eax
80105eed:	66 a3 46 66 19 80    	mov    %ax,0x80196646

  initlock(&tickslock, "time");
80105ef3:	83 ec 08             	sub    $0x8,%esp
80105ef6:	68 38 a4 10 80       	push   $0x8010a438
80105efb:	68 40 6c 19 80       	push   $0x80196c40
80105f00:	e8 ec e7 ff ff       	call   801046f1 <initlock>
80105f05:	83 c4 10             	add    $0x10,%esp
}
80105f08:	90                   	nop
80105f09:	c9                   	leave  
80105f0a:	c3                   	ret    

80105f0b <idtinit>:

void
idtinit(void)
{
80105f0b:	55                   	push   %ebp
80105f0c:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f0e:	68 00 08 00 00       	push   $0x800
80105f13:	68 40 64 19 80       	push   $0x80196440
80105f18:	e8 3d fe ff ff       	call   80105d5a <lidt>
80105f1d:	83 c4 08             	add    $0x8,%esp
}
80105f20:	90                   	nop
80105f21:	c9                   	leave  
80105f22:	c3                   	ret    

80105f23 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f23:	55                   	push   %ebp
80105f24:	89 e5                	mov    %esp,%ebp
80105f26:	57                   	push   %edi
80105f27:	56                   	push   %esi
80105f28:	53                   	push   %ebx
80105f29:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80105f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105f2f:	8b 40 30             	mov    0x30(%eax),%eax
80105f32:	83 f8 40             	cmp    $0x40,%eax
80105f35:	75 3b                	jne    80105f72 <trap+0x4f>
    if(myproc()->killed)
80105f37:	e8 f4 da ff ff       	call   80103a30 <myproc>
80105f3c:	8b 40 24             	mov    0x24(%eax),%eax
80105f3f:	85 c0                	test   %eax,%eax
80105f41:	74 05                	je     80105f48 <trap+0x25>
      exit();
80105f43:	e8 6d df ff ff       	call   80103eb5 <exit>
    myproc()->tf = tf;
80105f48:	e8 e3 da ff ff       	call   80103a30 <myproc>
80105f4d:	8b 55 08             	mov    0x8(%ebp),%edx
80105f50:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f53:	e8 28 ee ff ff       	call   80104d80 <syscall>
    if(myproc()->killed)
80105f58:	e8 d3 da ff ff       	call   80103a30 <myproc>
80105f5d:	8b 40 24             	mov    0x24(%eax),%eax
80105f60:	85 c0                	test   %eax,%eax
80105f62:	0f 84 3b 02 00 00    	je     801061a3 <trap+0x280>
      exit();
80105f68:	e8 48 df ff ff       	call   80103eb5 <exit>
    return;
80105f6d:	e9 31 02 00 00       	jmp    801061a3 <trap+0x280>
  }

  switch(tf->trapno){
80105f72:	8b 45 08             	mov    0x8(%ebp),%eax
80105f75:	8b 40 30             	mov    0x30(%eax),%eax
80105f78:	83 e8 20             	sub    $0x20,%eax
80105f7b:	83 f8 1f             	cmp    $0x1f,%eax
80105f7e:	0f 87 ea 00 00 00    	ja     8010606e <trap+0x14b>
80105f84:	8b 04 85 e0 a4 10 80 	mov    -0x7fef5b20(,%eax,4),%eax
80105f8b:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105f8d:	e8 0b da ff ff       	call   8010399d <cpuid>
80105f92:	85 c0                	test   %eax,%eax
80105f94:	75 3d                	jne    80105fd3 <trap+0xb0>
      acquire(&tickslock);
80105f96:	83 ec 0c             	sub    $0xc,%esp
80105f99:	68 40 6c 19 80       	push   $0x80196c40
80105f9e:	e8 70 e7 ff ff       	call   80104713 <acquire>
80105fa3:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105fa6:	a1 74 6c 19 80       	mov    0x80196c74,%eax
80105fab:	83 c0 01             	add    $0x1,%eax
80105fae:	a3 74 6c 19 80       	mov    %eax,0x80196c74
      wakeup(&ticks);
80105fb3:	83 ec 0c             	sub    $0xc,%esp
80105fb6:	68 74 6c 19 80       	push   $0x80196c74
80105fbb:	e8 19 e4 ff ff       	call   801043d9 <wakeup>
80105fc0:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fc3:	83 ec 0c             	sub    $0xc,%esp
80105fc6:	68 40 6c 19 80       	push   $0x80196c40
80105fcb:	e8 b1 e7 ff ff       	call   80104781 <release>
80105fd0:	83 c4 10             	add    $0x10,%esp
    }
    if(myproc() && myproc()->state == RUNNING &&
80105fd3:	e8 58 da ff ff       	call   80103a30 <myproc>
80105fd8:	85 c0                	test   %eax,%eax
80105fda:	74 2c                	je     80106008 <trap+0xe5>
80105fdc:	e8 4f da ff ff       	call   80103a30 <myproc>
80105fe1:	8b 40 0c             	mov    0xc(%eax),%eax
80105fe4:	83 f8 04             	cmp    $0x4,%eax
80105fe7:	75 1f                	jne    80106008 <trap+0xe5>
     tf->trapno == T_IRQ0+IRQ_TIMER) {
80105fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80105fec:	8b 40 30             	mov    0x30(%eax),%eax
    if(myproc() && myproc()->state == RUNNING &&
80105fef:	83 f8 20             	cmp    $0x20,%eax
80105ff2:	75 14                	jne    80106008 <trap+0xe5>
    if(!myproc()->using_threads) {
80105ff4:	e8 37 da ff ff       	call   80103a30 <myproc>
80105ff9:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105fff:	85 c0                	test   %eax,%eax
80106001:	75 05                	jne    80106008 <trap+0xe5>
       yield();
80106003:	e8 67 e2 ff ff       	call   8010426f <yield>
    }
  }
   lapiceoi();
80106008:	e8 0f cb ff ff       	call   80102b1c <lapiceoi>
  break;
8010600d:	e9 11 01 00 00       	jmp    80106123 <trap+0x200>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106012:	e8 e6 3e 00 00       	call   80109efd <ideintr>
    lapiceoi();
80106017:	e8 00 cb ff ff       	call   80102b1c <lapiceoi>
    break;
8010601c:	e9 02 01 00 00       	jmp    80106123 <trap+0x200>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106021:	e8 3b c9 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
80106026:	e8 f1 ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010602b:	e9 f3 00 00 00       	jmp    80106123 <trap+0x200>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106030:	e8 44 03 00 00       	call   80106379 <uartintr>
    lapiceoi();
80106035:	e8 e2 ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010603a:	e9 e4 00 00 00       	jmp    80106123 <trap+0x200>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010603f:	8b 45 08             	mov    0x8(%ebp),%eax
80106042:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106045:	8b 45 08             	mov    0x8(%ebp),%eax
80106048:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010604c:	0f b7 d8             	movzwl %ax,%ebx
8010604f:	e8 49 d9 ff ff       	call   8010399d <cpuid>
80106054:	56                   	push   %esi
80106055:	53                   	push   %ebx
80106056:	50                   	push   %eax
80106057:	68 40 a4 10 80       	push   $0x8010a440
8010605c:	e8 93 a3 ff ff       	call   801003f4 <cprintf>
80106061:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106064:	e8 b3 ca ff ff       	call   80102b1c <lapiceoi>
    break;
80106069:	e9 b5 00 00 00       	jmp    80106123 <trap+0x200>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010606e:	e8 bd d9 ff ff       	call   80103a30 <myproc>
80106073:	85 c0                	test   %eax,%eax
80106075:	74 11                	je     80106088 <trap+0x165>
80106077:	8b 45 08             	mov    0x8(%ebp),%eax
8010607a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010607e:	0f b7 c0             	movzwl %ax,%eax
80106081:	83 e0 03             	and    $0x3,%eax
80106084:	85 c0                	test   %eax,%eax
80106086:	75 39                	jne    801060c1 <trap+0x19e>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106088:	e8 f7 fc ff ff       	call   80105d84 <rcr2>
8010608d:	89 c3                	mov    %eax,%ebx
8010608f:	8b 45 08             	mov    0x8(%ebp),%eax
80106092:	8b 70 38             	mov    0x38(%eax),%esi
80106095:	e8 03 d9 ff ff       	call   8010399d <cpuid>
8010609a:	8b 55 08             	mov    0x8(%ebp),%edx
8010609d:	8b 52 30             	mov    0x30(%edx),%edx
801060a0:	83 ec 0c             	sub    $0xc,%esp
801060a3:	53                   	push   %ebx
801060a4:	56                   	push   %esi
801060a5:	50                   	push   %eax
801060a6:	52                   	push   %edx
801060a7:	68 64 a4 10 80       	push   $0x8010a464
801060ac:	e8 43 a3 ff ff       	call   801003f4 <cprintf>
801060b1:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801060b4:	83 ec 0c             	sub    $0xc,%esp
801060b7:	68 96 a4 10 80       	push   $0x8010a496
801060bc:	e8 e8 a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801060c1:	e8 be fc ff ff       	call   80105d84 <rcr2>
801060c6:	89 c6                	mov    %eax,%esi
801060c8:	8b 45 08             	mov    0x8(%ebp),%eax
801060cb:	8b 40 38             	mov    0x38(%eax),%eax
801060ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060d1:	e8 c7 d8 ff ff       	call   8010399d <cpuid>
801060d6:	89 c3                	mov    %eax,%ebx
801060d8:	8b 45 08             	mov    0x8(%ebp),%eax
801060db:	8b 48 34             	mov    0x34(%eax),%ecx
801060de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801060e1:	8b 45 08             	mov    0x8(%ebp),%eax
801060e4:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801060e7:	e8 44 d9 ff ff       	call   80103a30 <myproc>
801060ec:	8d 50 70             	lea    0x70(%eax),%edx
801060ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
801060f2:	e8 39 d9 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801060f7:	8b 40 10             	mov    0x10(%eax),%eax
801060fa:	56                   	push   %esi
801060fb:	ff 75 e4             	push   -0x1c(%ebp)
801060fe:	53                   	push   %ebx
801060ff:	ff 75 e0             	push   -0x20(%ebp)
80106102:	57                   	push   %edi
80106103:	ff 75 dc             	push   -0x24(%ebp)
80106106:	50                   	push   %eax
80106107:	68 9c a4 10 80       	push   $0x8010a49c
8010610c:	e8 e3 a2 ff ff       	call   801003f4 <cprintf>
80106111:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106114:	e8 17 d9 ff ff       	call   80103a30 <myproc>
80106119:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106120:	eb 01                	jmp    80106123 <trap+0x200>
    break;
80106122:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106123:	e8 08 d9 ff ff       	call   80103a30 <myproc>
80106128:	85 c0                	test   %eax,%eax
8010612a:	74 23                	je     8010614f <trap+0x22c>
8010612c:	e8 ff d8 ff ff       	call   80103a30 <myproc>
80106131:	8b 40 24             	mov    0x24(%eax),%eax
80106134:	85 c0                	test   %eax,%eax
80106136:	74 17                	je     8010614f <trap+0x22c>
80106138:	8b 45 08             	mov    0x8(%ebp),%eax
8010613b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010613f:	0f b7 c0             	movzwl %ax,%eax
80106142:	83 e0 03             	and    $0x3,%eax
80106145:	83 f8 03             	cmp    $0x3,%eax
80106148:	75 05                	jne    8010614f <trap+0x22c>
    exit();
8010614a:	e8 66 dd ff ff       	call   80103eb5 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010614f:	e8 dc d8 ff ff       	call   80103a30 <myproc>
80106154:	85 c0                	test   %eax,%eax
80106156:	74 1d                	je     80106175 <trap+0x252>
80106158:	e8 d3 d8 ff ff       	call   80103a30 <myproc>
8010615d:	8b 40 0c             	mov    0xc(%eax),%eax
80106160:	83 f8 04             	cmp    $0x4,%eax
80106163:	75 10                	jne    80106175 <trap+0x252>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106165:	8b 45 08             	mov    0x8(%ebp),%eax
80106168:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010616b:	83 f8 20             	cmp    $0x20,%eax
8010616e:	75 05                	jne    80106175 <trap+0x252>
    yield();
80106170:	e8 fa e0 ff ff       	call   8010426f <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106175:	e8 b6 d8 ff ff       	call   80103a30 <myproc>
8010617a:	85 c0                	test   %eax,%eax
8010617c:	74 26                	je     801061a4 <trap+0x281>
8010617e:	e8 ad d8 ff ff       	call   80103a30 <myproc>
80106183:	8b 40 24             	mov    0x24(%eax),%eax
80106186:	85 c0                	test   %eax,%eax
80106188:	74 1a                	je     801061a4 <trap+0x281>
8010618a:	8b 45 08             	mov    0x8(%ebp),%eax
8010618d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106191:	0f b7 c0             	movzwl %ax,%eax
80106194:	83 e0 03             	and    $0x3,%eax
80106197:	83 f8 03             	cmp    $0x3,%eax
8010619a:	75 08                	jne    801061a4 <trap+0x281>
    exit();
8010619c:	e8 14 dd ff ff       	call   80103eb5 <exit>
801061a1:	eb 01                	jmp    801061a4 <trap+0x281>
    return;
801061a3:	90                   	nop
801061a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061a7:	5b                   	pop    %ebx
801061a8:	5e                   	pop    %esi
801061a9:	5f                   	pop    %edi
801061aa:	5d                   	pop    %ebp
801061ab:	c3                   	ret    

801061ac <inb>:
{
801061ac:	55                   	push   %ebp
801061ad:	89 e5                	mov    %esp,%ebp
801061af:	83 ec 14             	sub    $0x14,%esp
801061b2:	8b 45 08             	mov    0x8(%ebp),%eax
801061b5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801061b9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801061bd:	89 c2                	mov    %eax,%edx
801061bf:	ec                   	in     (%dx),%al
801061c0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801061c3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801061c7:	c9                   	leave  
801061c8:	c3                   	ret    

801061c9 <outb>:
{
801061c9:	55                   	push   %ebp
801061ca:	89 e5                	mov    %esp,%ebp
801061cc:	83 ec 08             	sub    $0x8,%esp
801061cf:	8b 45 08             	mov    0x8(%ebp),%eax
801061d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801061d5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801061d9:	89 d0                	mov    %edx,%eax
801061db:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061de:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801061e2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801061e6:	ee                   	out    %al,(%dx)
}
801061e7:	90                   	nop
801061e8:	c9                   	leave  
801061e9:	c3                   	ret    

801061ea <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801061ea:	55                   	push   %ebp
801061eb:	89 e5                	mov    %esp,%ebp
801061ed:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801061f0:	6a 00                	push   $0x0
801061f2:	68 fa 03 00 00       	push   $0x3fa
801061f7:	e8 cd ff ff ff       	call   801061c9 <outb>
801061fc:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801061ff:	68 80 00 00 00       	push   $0x80
80106204:	68 fb 03 00 00       	push   $0x3fb
80106209:	e8 bb ff ff ff       	call   801061c9 <outb>
8010620e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106211:	6a 0c                	push   $0xc
80106213:	68 f8 03 00 00       	push   $0x3f8
80106218:	e8 ac ff ff ff       	call   801061c9 <outb>
8010621d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106220:	6a 00                	push   $0x0
80106222:	68 f9 03 00 00       	push   $0x3f9
80106227:	e8 9d ff ff ff       	call   801061c9 <outb>
8010622c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010622f:	6a 03                	push   $0x3
80106231:	68 fb 03 00 00       	push   $0x3fb
80106236:	e8 8e ff ff ff       	call   801061c9 <outb>
8010623b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010623e:	6a 00                	push   $0x0
80106240:	68 fc 03 00 00       	push   $0x3fc
80106245:	e8 7f ff ff ff       	call   801061c9 <outb>
8010624a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010624d:	6a 01                	push   $0x1
8010624f:	68 f9 03 00 00       	push   $0x3f9
80106254:	e8 70 ff ff ff       	call   801061c9 <outb>
80106259:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010625c:	68 fd 03 00 00       	push   $0x3fd
80106261:	e8 46 ff ff ff       	call   801061ac <inb>
80106266:	83 c4 04             	add    $0x4,%esp
80106269:	3c ff                	cmp    $0xff,%al
8010626b:	74 61                	je     801062ce <uartinit+0xe4>
    return;
  uart = 1;
8010626d:	c7 05 78 6c 19 80 01 	movl   $0x1,0x80196c78
80106274:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106277:	68 fa 03 00 00       	push   $0x3fa
8010627c:	e8 2b ff ff ff       	call   801061ac <inb>
80106281:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106284:	68 f8 03 00 00       	push   $0x3f8
80106289:	e8 1e ff ff ff       	call   801061ac <inb>
8010628e:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106291:	83 ec 08             	sub    $0x8,%esp
80106294:	6a 00                	push   $0x0
80106296:	6a 04                	push   $0x4
80106298:	e8 91 c3 ff ff       	call   8010262e <ioapicenable>
8010629d:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801062a0:	c7 45 f4 60 a5 10 80 	movl   $0x8010a560,-0xc(%ebp)
801062a7:	eb 19                	jmp    801062c2 <uartinit+0xd8>
    uartputc(*p);
801062a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ac:	0f b6 00             	movzbl (%eax),%eax
801062af:	0f be c0             	movsbl %al,%eax
801062b2:	83 ec 0c             	sub    $0xc,%esp
801062b5:	50                   	push   %eax
801062b6:	e8 16 00 00 00       	call   801062d1 <uartputc>
801062bb:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801062be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c5:	0f b6 00             	movzbl (%eax),%eax
801062c8:	84 c0                	test   %al,%al
801062ca:	75 dd                	jne    801062a9 <uartinit+0xbf>
801062cc:	eb 01                	jmp    801062cf <uartinit+0xe5>
    return;
801062ce:	90                   	nop
}
801062cf:	c9                   	leave  
801062d0:	c3                   	ret    

801062d1 <uartputc>:

void
uartputc(int c)
{
801062d1:	55                   	push   %ebp
801062d2:	89 e5                	mov    %esp,%ebp
801062d4:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801062d7:	a1 78 6c 19 80       	mov    0x80196c78,%eax
801062dc:	85 c0                	test   %eax,%eax
801062de:	74 53                	je     80106333 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062e7:	eb 11                	jmp    801062fa <uartputc+0x29>
    microdelay(10);
801062e9:	83 ec 0c             	sub    $0xc,%esp
801062ec:	6a 0a                	push   $0xa
801062ee:	e8 44 c8 ff ff       	call   80102b37 <microdelay>
801062f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062fa:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801062fe:	7f 1a                	jg     8010631a <uartputc+0x49>
80106300:	83 ec 0c             	sub    $0xc,%esp
80106303:	68 fd 03 00 00       	push   $0x3fd
80106308:	e8 9f fe ff ff       	call   801061ac <inb>
8010630d:	83 c4 10             	add    $0x10,%esp
80106310:	0f b6 c0             	movzbl %al,%eax
80106313:	83 e0 20             	and    $0x20,%eax
80106316:	85 c0                	test   %eax,%eax
80106318:	74 cf                	je     801062e9 <uartputc+0x18>
  outb(COM1+0, c);
8010631a:	8b 45 08             	mov    0x8(%ebp),%eax
8010631d:	0f b6 c0             	movzbl %al,%eax
80106320:	83 ec 08             	sub    $0x8,%esp
80106323:	50                   	push   %eax
80106324:	68 f8 03 00 00       	push   $0x3f8
80106329:	e8 9b fe ff ff       	call   801061c9 <outb>
8010632e:	83 c4 10             	add    $0x10,%esp
80106331:	eb 01                	jmp    80106334 <uartputc+0x63>
    return;
80106333:	90                   	nop
}
80106334:	c9                   	leave  
80106335:	c3                   	ret    

80106336 <uartgetc>:

static int
uartgetc(void)
{
80106336:	55                   	push   %ebp
80106337:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106339:	a1 78 6c 19 80       	mov    0x80196c78,%eax
8010633e:	85 c0                	test   %eax,%eax
80106340:	75 07                	jne    80106349 <uartgetc+0x13>
    return -1;
80106342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106347:	eb 2e                	jmp    80106377 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106349:	68 fd 03 00 00       	push   $0x3fd
8010634e:	e8 59 fe ff ff       	call   801061ac <inb>
80106353:	83 c4 04             	add    $0x4,%esp
80106356:	0f b6 c0             	movzbl %al,%eax
80106359:	83 e0 01             	and    $0x1,%eax
8010635c:	85 c0                	test   %eax,%eax
8010635e:	75 07                	jne    80106367 <uartgetc+0x31>
    return -1;
80106360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106365:	eb 10                	jmp    80106377 <uartgetc+0x41>
  return inb(COM1+0);
80106367:	68 f8 03 00 00       	push   $0x3f8
8010636c:	e8 3b fe ff ff       	call   801061ac <inb>
80106371:	83 c4 04             	add    $0x4,%esp
80106374:	0f b6 c0             	movzbl %al,%eax
}
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <uartintr>:

void
uartintr(void)
{
80106379:	55                   	push   %ebp
8010637a:	89 e5                	mov    %esp,%ebp
8010637c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010637f:	83 ec 0c             	sub    $0xc,%esp
80106382:	68 36 63 10 80       	push   $0x80106336
80106387:	e8 4a a4 ff ff       	call   801007d6 <consoleintr>
8010638c:	83 c4 10             	add    $0x10,%esp
}
8010638f:	90                   	nop
80106390:	c9                   	leave  
80106391:	c3                   	ret    

80106392 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106392:	6a 00                	push   $0x0
  pushl $0
80106394:	6a 00                	push   $0x0
  jmp alltraps
80106396:	e9 9c f9 ff ff       	jmp    80105d37 <alltraps>

8010639b <vector1>:
.globl vector1
vector1:
  pushl $0
8010639b:	6a 00                	push   $0x0
  pushl $1
8010639d:	6a 01                	push   $0x1
  jmp alltraps
8010639f:	e9 93 f9 ff ff       	jmp    80105d37 <alltraps>

801063a4 <vector2>:
.globl vector2
vector2:
  pushl $0
801063a4:	6a 00                	push   $0x0
  pushl $2
801063a6:	6a 02                	push   $0x2
  jmp alltraps
801063a8:	e9 8a f9 ff ff       	jmp    80105d37 <alltraps>

801063ad <vector3>:
.globl vector3
vector3:
  pushl $0
801063ad:	6a 00                	push   $0x0
  pushl $3
801063af:	6a 03                	push   $0x3
  jmp alltraps
801063b1:	e9 81 f9 ff ff       	jmp    80105d37 <alltraps>

801063b6 <vector4>:
.globl vector4
vector4:
  pushl $0
801063b6:	6a 00                	push   $0x0
  pushl $4
801063b8:	6a 04                	push   $0x4
  jmp alltraps
801063ba:	e9 78 f9 ff ff       	jmp    80105d37 <alltraps>

801063bf <vector5>:
.globl vector5
vector5:
  pushl $0
801063bf:	6a 00                	push   $0x0
  pushl $5
801063c1:	6a 05                	push   $0x5
  jmp alltraps
801063c3:	e9 6f f9 ff ff       	jmp    80105d37 <alltraps>

801063c8 <vector6>:
.globl vector6
vector6:
  pushl $0
801063c8:	6a 00                	push   $0x0
  pushl $6
801063ca:	6a 06                	push   $0x6
  jmp alltraps
801063cc:	e9 66 f9 ff ff       	jmp    80105d37 <alltraps>

801063d1 <vector7>:
.globl vector7
vector7:
  pushl $0
801063d1:	6a 00                	push   $0x0
  pushl $7
801063d3:	6a 07                	push   $0x7
  jmp alltraps
801063d5:	e9 5d f9 ff ff       	jmp    80105d37 <alltraps>

801063da <vector8>:
.globl vector8
vector8:
  pushl $8
801063da:	6a 08                	push   $0x8
  jmp alltraps
801063dc:	e9 56 f9 ff ff       	jmp    80105d37 <alltraps>

801063e1 <vector9>:
.globl vector9
vector9:
  pushl $0
801063e1:	6a 00                	push   $0x0
  pushl $9
801063e3:	6a 09                	push   $0x9
  jmp alltraps
801063e5:	e9 4d f9 ff ff       	jmp    80105d37 <alltraps>

801063ea <vector10>:
.globl vector10
vector10:
  pushl $10
801063ea:	6a 0a                	push   $0xa
  jmp alltraps
801063ec:	e9 46 f9 ff ff       	jmp    80105d37 <alltraps>

801063f1 <vector11>:
.globl vector11
vector11:
  pushl $11
801063f1:	6a 0b                	push   $0xb
  jmp alltraps
801063f3:	e9 3f f9 ff ff       	jmp    80105d37 <alltraps>

801063f8 <vector12>:
.globl vector12
vector12:
  pushl $12
801063f8:	6a 0c                	push   $0xc
  jmp alltraps
801063fa:	e9 38 f9 ff ff       	jmp    80105d37 <alltraps>

801063ff <vector13>:
.globl vector13
vector13:
  pushl $13
801063ff:	6a 0d                	push   $0xd
  jmp alltraps
80106401:	e9 31 f9 ff ff       	jmp    80105d37 <alltraps>

80106406 <vector14>:
.globl vector14
vector14:
  pushl $14
80106406:	6a 0e                	push   $0xe
  jmp alltraps
80106408:	e9 2a f9 ff ff       	jmp    80105d37 <alltraps>

8010640d <vector15>:
.globl vector15
vector15:
  pushl $0
8010640d:	6a 00                	push   $0x0
  pushl $15
8010640f:	6a 0f                	push   $0xf
  jmp alltraps
80106411:	e9 21 f9 ff ff       	jmp    80105d37 <alltraps>

80106416 <vector16>:
.globl vector16
vector16:
  pushl $0
80106416:	6a 00                	push   $0x0
  pushl $16
80106418:	6a 10                	push   $0x10
  jmp alltraps
8010641a:	e9 18 f9 ff ff       	jmp    80105d37 <alltraps>

8010641f <vector17>:
.globl vector17
vector17:
  pushl $17
8010641f:	6a 11                	push   $0x11
  jmp alltraps
80106421:	e9 11 f9 ff ff       	jmp    80105d37 <alltraps>

80106426 <vector18>:
.globl vector18
vector18:
  pushl $0
80106426:	6a 00                	push   $0x0
  pushl $18
80106428:	6a 12                	push   $0x12
  jmp alltraps
8010642a:	e9 08 f9 ff ff       	jmp    80105d37 <alltraps>

8010642f <vector19>:
.globl vector19
vector19:
  pushl $0
8010642f:	6a 00                	push   $0x0
  pushl $19
80106431:	6a 13                	push   $0x13
  jmp alltraps
80106433:	e9 ff f8 ff ff       	jmp    80105d37 <alltraps>

80106438 <vector20>:
.globl vector20
vector20:
  pushl $0
80106438:	6a 00                	push   $0x0
  pushl $20
8010643a:	6a 14                	push   $0x14
  jmp alltraps
8010643c:	e9 f6 f8 ff ff       	jmp    80105d37 <alltraps>

80106441 <vector21>:
.globl vector21
vector21:
  pushl $0
80106441:	6a 00                	push   $0x0
  pushl $21
80106443:	6a 15                	push   $0x15
  jmp alltraps
80106445:	e9 ed f8 ff ff       	jmp    80105d37 <alltraps>

8010644a <vector22>:
.globl vector22
vector22:
  pushl $0
8010644a:	6a 00                	push   $0x0
  pushl $22
8010644c:	6a 16                	push   $0x16
  jmp alltraps
8010644e:	e9 e4 f8 ff ff       	jmp    80105d37 <alltraps>

80106453 <vector23>:
.globl vector23
vector23:
  pushl $0
80106453:	6a 00                	push   $0x0
  pushl $23
80106455:	6a 17                	push   $0x17
  jmp alltraps
80106457:	e9 db f8 ff ff       	jmp    80105d37 <alltraps>

8010645c <vector24>:
.globl vector24
vector24:
  pushl $0
8010645c:	6a 00                	push   $0x0
  pushl $24
8010645e:	6a 18                	push   $0x18
  jmp alltraps
80106460:	e9 d2 f8 ff ff       	jmp    80105d37 <alltraps>

80106465 <vector25>:
.globl vector25
vector25:
  pushl $0
80106465:	6a 00                	push   $0x0
  pushl $25
80106467:	6a 19                	push   $0x19
  jmp alltraps
80106469:	e9 c9 f8 ff ff       	jmp    80105d37 <alltraps>

8010646e <vector26>:
.globl vector26
vector26:
  pushl $0
8010646e:	6a 00                	push   $0x0
  pushl $26
80106470:	6a 1a                	push   $0x1a
  jmp alltraps
80106472:	e9 c0 f8 ff ff       	jmp    80105d37 <alltraps>

80106477 <vector27>:
.globl vector27
vector27:
  pushl $0
80106477:	6a 00                	push   $0x0
  pushl $27
80106479:	6a 1b                	push   $0x1b
  jmp alltraps
8010647b:	e9 b7 f8 ff ff       	jmp    80105d37 <alltraps>

80106480 <vector28>:
.globl vector28
vector28:
  pushl $0
80106480:	6a 00                	push   $0x0
  pushl $28
80106482:	6a 1c                	push   $0x1c
  jmp alltraps
80106484:	e9 ae f8 ff ff       	jmp    80105d37 <alltraps>

80106489 <vector29>:
.globl vector29
vector29:
  pushl $0
80106489:	6a 00                	push   $0x0
  pushl $29
8010648b:	6a 1d                	push   $0x1d
  jmp alltraps
8010648d:	e9 a5 f8 ff ff       	jmp    80105d37 <alltraps>

80106492 <vector30>:
.globl vector30
vector30:
  pushl $0
80106492:	6a 00                	push   $0x0
  pushl $30
80106494:	6a 1e                	push   $0x1e
  jmp alltraps
80106496:	e9 9c f8 ff ff       	jmp    80105d37 <alltraps>

8010649b <vector31>:
.globl vector31
vector31:
  pushl $0
8010649b:	6a 00                	push   $0x0
  pushl $31
8010649d:	6a 1f                	push   $0x1f
  jmp alltraps
8010649f:	e9 93 f8 ff ff       	jmp    80105d37 <alltraps>

801064a4 <vector32>:
.globl vector32
vector32:
  pushl $0
801064a4:	6a 00                	push   $0x0
  pushl $32
801064a6:	6a 20                	push   $0x20
  jmp alltraps
801064a8:	e9 8a f8 ff ff       	jmp    80105d37 <alltraps>

801064ad <vector33>:
.globl vector33
vector33:
  pushl $0
801064ad:	6a 00                	push   $0x0
  pushl $33
801064af:	6a 21                	push   $0x21
  jmp alltraps
801064b1:	e9 81 f8 ff ff       	jmp    80105d37 <alltraps>

801064b6 <vector34>:
.globl vector34
vector34:
  pushl $0
801064b6:	6a 00                	push   $0x0
  pushl $34
801064b8:	6a 22                	push   $0x22
  jmp alltraps
801064ba:	e9 78 f8 ff ff       	jmp    80105d37 <alltraps>

801064bf <vector35>:
.globl vector35
vector35:
  pushl $0
801064bf:	6a 00                	push   $0x0
  pushl $35
801064c1:	6a 23                	push   $0x23
  jmp alltraps
801064c3:	e9 6f f8 ff ff       	jmp    80105d37 <alltraps>

801064c8 <vector36>:
.globl vector36
vector36:
  pushl $0
801064c8:	6a 00                	push   $0x0
  pushl $36
801064ca:	6a 24                	push   $0x24
  jmp alltraps
801064cc:	e9 66 f8 ff ff       	jmp    80105d37 <alltraps>

801064d1 <vector37>:
.globl vector37
vector37:
  pushl $0
801064d1:	6a 00                	push   $0x0
  pushl $37
801064d3:	6a 25                	push   $0x25
  jmp alltraps
801064d5:	e9 5d f8 ff ff       	jmp    80105d37 <alltraps>

801064da <vector38>:
.globl vector38
vector38:
  pushl $0
801064da:	6a 00                	push   $0x0
  pushl $38
801064dc:	6a 26                	push   $0x26
  jmp alltraps
801064de:	e9 54 f8 ff ff       	jmp    80105d37 <alltraps>

801064e3 <vector39>:
.globl vector39
vector39:
  pushl $0
801064e3:	6a 00                	push   $0x0
  pushl $39
801064e5:	6a 27                	push   $0x27
  jmp alltraps
801064e7:	e9 4b f8 ff ff       	jmp    80105d37 <alltraps>

801064ec <vector40>:
.globl vector40
vector40:
  pushl $0
801064ec:	6a 00                	push   $0x0
  pushl $40
801064ee:	6a 28                	push   $0x28
  jmp alltraps
801064f0:	e9 42 f8 ff ff       	jmp    80105d37 <alltraps>

801064f5 <vector41>:
.globl vector41
vector41:
  pushl $0
801064f5:	6a 00                	push   $0x0
  pushl $41
801064f7:	6a 29                	push   $0x29
  jmp alltraps
801064f9:	e9 39 f8 ff ff       	jmp    80105d37 <alltraps>

801064fe <vector42>:
.globl vector42
vector42:
  pushl $0
801064fe:	6a 00                	push   $0x0
  pushl $42
80106500:	6a 2a                	push   $0x2a
  jmp alltraps
80106502:	e9 30 f8 ff ff       	jmp    80105d37 <alltraps>

80106507 <vector43>:
.globl vector43
vector43:
  pushl $0
80106507:	6a 00                	push   $0x0
  pushl $43
80106509:	6a 2b                	push   $0x2b
  jmp alltraps
8010650b:	e9 27 f8 ff ff       	jmp    80105d37 <alltraps>

80106510 <vector44>:
.globl vector44
vector44:
  pushl $0
80106510:	6a 00                	push   $0x0
  pushl $44
80106512:	6a 2c                	push   $0x2c
  jmp alltraps
80106514:	e9 1e f8 ff ff       	jmp    80105d37 <alltraps>

80106519 <vector45>:
.globl vector45
vector45:
  pushl $0
80106519:	6a 00                	push   $0x0
  pushl $45
8010651b:	6a 2d                	push   $0x2d
  jmp alltraps
8010651d:	e9 15 f8 ff ff       	jmp    80105d37 <alltraps>

80106522 <vector46>:
.globl vector46
vector46:
  pushl $0
80106522:	6a 00                	push   $0x0
  pushl $46
80106524:	6a 2e                	push   $0x2e
  jmp alltraps
80106526:	e9 0c f8 ff ff       	jmp    80105d37 <alltraps>

8010652b <vector47>:
.globl vector47
vector47:
  pushl $0
8010652b:	6a 00                	push   $0x0
  pushl $47
8010652d:	6a 2f                	push   $0x2f
  jmp alltraps
8010652f:	e9 03 f8 ff ff       	jmp    80105d37 <alltraps>

80106534 <vector48>:
.globl vector48
vector48:
  pushl $0
80106534:	6a 00                	push   $0x0
  pushl $48
80106536:	6a 30                	push   $0x30
  jmp alltraps
80106538:	e9 fa f7 ff ff       	jmp    80105d37 <alltraps>

8010653d <vector49>:
.globl vector49
vector49:
  pushl $0
8010653d:	6a 00                	push   $0x0
  pushl $49
8010653f:	6a 31                	push   $0x31
  jmp alltraps
80106541:	e9 f1 f7 ff ff       	jmp    80105d37 <alltraps>

80106546 <vector50>:
.globl vector50
vector50:
  pushl $0
80106546:	6a 00                	push   $0x0
  pushl $50
80106548:	6a 32                	push   $0x32
  jmp alltraps
8010654a:	e9 e8 f7 ff ff       	jmp    80105d37 <alltraps>

8010654f <vector51>:
.globl vector51
vector51:
  pushl $0
8010654f:	6a 00                	push   $0x0
  pushl $51
80106551:	6a 33                	push   $0x33
  jmp alltraps
80106553:	e9 df f7 ff ff       	jmp    80105d37 <alltraps>

80106558 <vector52>:
.globl vector52
vector52:
  pushl $0
80106558:	6a 00                	push   $0x0
  pushl $52
8010655a:	6a 34                	push   $0x34
  jmp alltraps
8010655c:	e9 d6 f7 ff ff       	jmp    80105d37 <alltraps>

80106561 <vector53>:
.globl vector53
vector53:
  pushl $0
80106561:	6a 00                	push   $0x0
  pushl $53
80106563:	6a 35                	push   $0x35
  jmp alltraps
80106565:	e9 cd f7 ff ff       	jmp    80105d37 <alltraps>

8010656a <vector54>:
.globl vector54
vector54:
  pushl $0
8010656a:	6a 00                	push   $0x0
  pushl $54
8010656c:	6a 36                	push   $0x36
  jmp alltraps
8010656e:	e9 c4 f7 ff ff       	jmp    80105d37 <alltraps>

80106573 <vector55>:
.globl vector55
vector55:
  pushl $0
80106573:	6a 00                	push   $0x0
  pushl $55
80106575:	6a 37                	push   $0x37
  jmp alltraps
80106577:	e9 bb f7 ff ff       	jmp    80105d37 <alltraps>

8010657c <vector56>:
.globl vector56
vector56:
  pushl $0
8010657c:	6a 00                	push   $0x0
  pushl $56
8010657e:	6a 38                	push   $0x38
  jmp alltraps
80106580:	e9 b2 f7 ff ff       	jmp    80105d37 <alltraps>

80106585 <vector57>:
.globl vector57
vector57:
  pushl $0
80106585:	6a 00                	push   $0x0
  pushl $57
80106587:	6a 39                	push   $0x39
  jmp alltraps
80106589:	e9 a9 f7 ff ff       	jmp    80105d37 <alltraps>

8010658e <vector58>:
.globl vector58
vector58:
  pushl $0
8010658e:	6a 00                	push   $0x0
  pushl $58
80106590:	6a 3a                	push   $0x3a
  jmp alltraps
80106592:	e9 a0 f7 ff ff       	jmp    80105d37 <alltraps>

80106597 <vector59>:
.globl vector59
vector59:
  pushl $0
80106597:	6a 00                	push   $0x0
  pushl $59
80106599:	6a 3b                	push   $0x3b
  jmp alltraps
8010659b:	e9 97 f7 ff ff       	jmp    80105d37 <alltraps>

801065a0 <vector60>:
.globl vector60
vector60:
  pushl $0
801065a0:	6a 00                	push   $0x0
  pushl $60
801065a2:	6a 3c                	push   $0x3c
  jmp alltraps
801065a4:	e9 8e f7 ff ff       	jmp    80105d37 <alltraps>

801065a9 <vector61>:
.globl vector61
vector61:
  pushl $0
801065a9:	6a 00                	push   $0x0
  pushl $61
801065ab:	6a 3d                	push   $0x3d
  jmp alltraps
801065ad:	e9 85 f7 ff ff       	jmp    80105d37 <alltraps>

801065b2 <vector62>:
.globl vector62
vector62:
  pushl $0
801065b2:	6a 00                	push   $0x0
  pushl $62
801065b4:	6a 3e                	push   $0x3e
  jmp alltraps
801065b6:	e9 7c f7 ff ff       	jmp    80105d37 <alltraps>

801065bb <vector63>:
.globl vector63
vector63:
  pushl $0
801065bb:	6a 00                	push   $0x0
  pushl $63
801065bd:	6a 3f                	push   $0x3f
  jmp alltraps
801065bf:	e9 73 f7 ff ff       	jmp    80105d37 <alltraps>

801065c4 <vector64>:
.globl vector64
vector64:
  pushl $0
801065c4:	6a 00                	push   $0x0
  pushl $64
801065c6:	6a 40                	push   $0x40
  jmp alltraps
801065c8:	e9 6a f7 ff ff       	jmp    80105d37 <alltraps>

801065cd <vector65>:
.globl vector65
vector65:
  pushl $0
801065cd:	6a 00                	push   $0x0
  pushl $65
801065cf:	6a 41                	push   $0x41
  jmp alltraps
801065d1:	e9 61 f7 ff ff       	jmp    80105d37 <alltraps>

801065d6 <vector66>:
.globl vector66
vector66:
  pushl $0
801065d6:	6a 00                	push   $0x0
  pushl $66
801065d8:	6a 42                	push   $0x42
  jmp alltraps
801065da:	e9 58 f7 ff ff       	jmp    80105d37 <alltraps>

801065df <vector67>:
.globl vector67
vector67:
  pushl $0
801065df:	6a 00                	push   $0x0
  pushl $67
801065e1:	6a 43                	push   $0x43
  jmp alltraps
801065e3:	e9 4f f7 ff ff       	jmp    80105d37 <alltraps>

801065e8 <vector68>:
.globl vector68
vector68:
  pushl $0
801065e8:	6a 00                	push   $0x0
  pushl $68
801065ea:	6a 44                	push   $0x44
  jmp alltraps
801065ec:	e9 46 f7 ff ff       	jmp    80105d37 <alltraps>

801065f1 <vector69>:
.globl vector69
vector69:
  pushl $0
801065f1:	6a 00                	push   $0x0
  pushl $69
801065f3:	6a 45                	push   $0x45
  jmp alltraps
801065f5:	e9 3d f7 ff ff       	jmp    80105d37 <alltraps>

801065fa <vector70>:
.globl vector70
vector70:
  pushl $0
801065fa:	6a 00                	push   $0x0
  pushl $70
801065fc:	6a 46                	push   $0x46
  jmp alltraps
801065fe:	e9 34 f7 ff ff       	jmp    80105d37 <alltraps>

80106603 <vector71>:
.globl vector71
vector71:
  pushl $0
80106603:	6a 00                	push   $0x0
  pushl $71
80106605:	6a 47                	push   $0x47
  jmp alltraps
80106607:	e9 2b f7 ff ff       	jmp    80105d37 <alltraps>

8010660c <vector72>:
.globl vector72
vector72:
  pushl $0
8010660c:	6a 00                	push   $0x0
  pushl $72
8010660e:	6a 48                	push   $0x48
  jmp alltraps
80106610:	e9 22 f7 ff ff       	jmp    80105d37 <alltraps>

80106615 <vector73>:
.globl vector73
vector73:
  pushl $0
80106615:	6a 00                	push   $0x0
  pushl $73
80106617:	6a 49                	push   $0x49
  jmp alltraps
80106619:	e9 19 f7 ff ff       	jmp    80105d37 <alltraps>

8010661e <vector74>:
.globl vector74
vector74:
  pushl $0
8010661e:	6a 00                	push   $0x0
  pushl $74
80106620:	6a 4a                	push   $0x4a
  jmp alltraps
80106622:	e9 10 f7 ff ff       	jmp    80105d37 <alltraps>

80106627 <vector75>:
.globl vector75
vector75:
  pushl $0
80106627:	6a 00                	push   $0x0
  pushl $75
80106629:	6a 4b                	push   $0x4b
  jmp alltraps
8010662b:	e9 07 f7 ff ff       	jmp    80105d37 <alltraps>

80106630 <vector76>:
.globl vector76
vector76:
  pushl $0
80106630:	6a 00                	push   $0x0
  pushl $76
80106632:	6a 4c                	push   $0x4c
  jmp alltraps
80106634:	e9 fe f6 ff ff       	jmp    80105d37 <alltraps>

80106639 <vector77>:
.globl vector77
vector77:
  pushl $0
80106639:	6a 00                	push   $0x0
  pushl $77
8010663b:	6a 4d                	push   $0x4d
  jmp alltraps
8010663d:	e9 f5 f6 ff ff       	jmp    80105d37 <alltraps>

80106642 <vector78>:
.globl vector78
vector78:
  pushl $0
80106642:	6a 00                	push   $0x0
  pushl $78
80106644:	6a 4e                	push   $0x4e
  jmp alltraps
80106646:	e9 ec f6 ff ff       	jmp    80105d37 <alltraps>

8010664b <vector79>:
.globl vector79
vector79:
  pushl $0
8010664b:	6a 00                	push   $0x0
  pushl $79
8010664d:	6a 4f                	push   $0x4f
  jmp alltraps
8010664f:	e9 e3 f6 ff ff       	jmp    80105d37 <alltraps>

80106654 <vector80>:
.globl vector80
vector80:
  pushl $0
80106654:	6a 00                	push   $0x0
  pushl $80
80106656:	6a 50                	push   $0x50
  jmp alltraps
80106658:	e9 da f6 ff ff       	jmp    80105d37 <alltraps>

8010665d <vector81>:
.globl vector81
vector81:
  pushl $0
8010665d:	6a 00                	push   $0x0
  pushl $81
8010665f:	6a 51                	push   $0x51
  jmp alltraps
80106661:	e9 d1 f6 ff ff       	jmp    80105d37 <alltraps>

80106666 <vector82>:
.globl vector82
vector82:
  pushl $0
80106666:	6a 00                	push   $0x0
  pushl $82
80106668:	6a 52                	push   $0x52
  jmp alltraps
8010666a:	e9 c8 f6 ff ff       	jmp    80105d37 <alltraps>

8010666f <vector83>:
.globl vector83
vector83:
  pushl $0
8010666f:	6a 00                	push   $0x0
  pushl $83
80106671:	6a 53                	push   $0x53
  jmp alltraps
80106673:	e9 bf f6 ff ff       	jmp    80105d37 <alltraps>

80106678 <vector84>:
.globl vector84
vector84:
  pushl $0
80106678:	6a 00                	push   $0x0
  pushl $84
8010667a:	6a 54                	push   $0x54
  jmp alltraps
8010667c:	e9 b6 f6 ff ff       	jmp    80105d37 <alltraps>

80106681 <vector85>:
.globl vector85
vector85:
  pushl $0
80106681:	6a 00                	push   $0x0
  pushl $85
80106683:	6a 55                	push   $0x55
  jmp alltraps
80106685:	e9 ad f6 ff ff       	jmp    80105d37 <alltraps>

8010668a <vector86>:
.globl vector86
vector86:
  pushl $0
8010668a:	6a 00                	push   $0x0
  pushl $86
8010668c:	6a 56                	push   $0x56
  jmp alltraps
8010668e:	e9 a4 f6 ff ff       	jmp    80105d37 <alltraps>

80106693 <vector87>:
.globl vector87
vector87:
  pushl $0
80106693:	6a 00                	push   $0x0
  pushl $87
80106695:	6a 57                	push   $0x57
  jmp alltraps
80106697:	e9 9b f6 ff ff       	jmp    80105d37 <alltraps>

8010669c <vector88>:
.globl vector88
vector88:
  pushl $0
8010669c:	6a 00                	push   $0x0
  pushl $88
8010669e:	6a 58                	push   $0x58
  jmp alltraps
801066a0:	e9 92 f6 ff ff       	jmp    80105d37 <alltraps>

801066a5 <vector89>:
.globl vector89
vector89:
  pushl $0
801066a5:	6a 00                	push   $0x0
  pushl $89
801066a7:	6a 59                	push   $0x59
  jmp alltraps
801066a9:	e9 89 f6 ff ff       	jmp    80105d37 <alltraps>

801066ae <vector90>:
.globl vector90
vector90:
  pushl $0
801066ae:	6a 00                	push   $0x0
  pushl $90
801066b0:	6a 5a                	push   $0x5a
  jmp alltraps
801066b2:	e9 80 f6 ff ff       	jmp    80105d37 <alltraps>

801066b7 <vector91>:
.globl vector91
vector91:
  pushl $0
801066b7:	6a 00                	push   $0x0
  pushl $91
801066b9:	6a 5b                	push   $0x5b
  jmp alltraps
801066bb:	e9 77 f6 ff ff       	jmp    80105d37 <alltraps>

801066c0 <vector92>:
.globl vector92
vector92:
  pushl $0
801066c0:	6a 00                	push   $0x0
  pushl $92
801066c2:	6a 5c                	push   $0x5c
  jmp alltraps
801066c4:	e9 6e f6 ff ff       	jmp    80105d37 <alltraps>

801066c9 <vector93>:
.globl vector93
vector93:
  pushl $0
801066c9:	6a 00                	push   $0x0
  pushl $93
801066cb:	6a 5d                	push   $0x5d
  jmp alltraps
801066cd:	e9 65 f6 ff ff       	jmp    80105d37 <alltraps>

801066d2 <vector94>:
.globl vector94
vector94:
  pushl $0
801066d2:	6a 00                	push   $0x0
  pushl $94
801066d4:	6a 5e                	push   $0x5e
  jmp alltraps
801066d6:	e9 5c f6 ff ff       	jmp    80105d37 <alltraps>

801066db <vector95>:
.globl vector95
vector95:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $95
801066dd:	6a 5f                	push   $0x5f
  jmp alltraps
801066df:	e9 53 f6 ff ff       	jmp    80105d37 <alltraps>

801066e4 <vector96>:
.globl vector96
vector96:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $96
801066e6:	6a 60                	push   $0x60
  jmp alltraps
801066e8:	e9 4a f6 ff ff       	jmp    80105d37 <alltraps>

801066ed <vector97>:
.globl vector97
vector97:
  pushl $0
801066ed:	6a 00                	push   $0x0
  pushl $97
801066ef:	6a 61                	push   $0x61
  jmp alltraps
801066f1:	e9 41 f6 ff ff       	jmp    80105d37 <alltraps>

801066f6 <vector98>:
.globl vector98
vector98:
  pushl $0
801066f6:	6a 00                	push   $0x0
  pushl $98
801066f8:	6a 62                	push   $0x62
  jmp alltraps
801066fa:	e9 38 f6 ff ff       	jmp    80105d37 <alltraps>

801066ff <vector99>:
.globl vector99
vector99:
  pushl $0
801066ff:	6a 00                	push   $0x0
  pushl $99
80106701:	6a 63                	push   $0x63
  jmp alltraps
80106703:	e9 2f f6 ff ff       	jmp    80105d37 <alltraps>

80106708 <vector100>:
.globl vector100
vector100:
  pushl $0
80106708:	6a 00                	push   $0x0
  pushl $100
8010670a:	6a 64                	push   $0x64
  jmp alltraps
8010670c:	e9 26 f6 ff ff       	jmp    80105d37 <alltraps>

80106711 <vector101>:
.globl vector101
vector101:
  pushl $0
80106711:	6a 00                	push   $0x0
  pushl $101
80106713:	6a 65                	push   $0x65
  jmp alltraps
80106715:	e9 1d f6 ff ff       	jmp    80105d37 <alltraps>

8010671a <vector102>:
.globl vector102
vector102:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $102
8010671c:	6a 66                	push   $0x66
  jmp alltraps
8010671e:	e9 14 f6 ff ff       	jmp    80105d37 <alltraps>

80106723 <vector103>:
.globl vector103
vector103:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $103
80106725:	6a 67                	push   $0x67
  jmp alltraps
80106727:	e9 0b f6 ff ff       	jmp    80105d37 <alltraps>

8010672c <vector104>:
.globl vector104
vector104:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $104
8010672e:	6a 68                	push   $0x68
  jmp alltraps
80106730:	e9 02 f6 ff ff       	jmp    80105d37 <alltraps>

80106735 <vector105>:
.globl vector105
vector105:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $105
80106737:	6a 69                	push   $0x69
  jmp alltraps
80106739:	e9 f9 f5 ff ff       	jmp    80105d37 <alltraps>

8010673e <vector106>:
.globl vector106
vector106:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $106
80106740:	6a 6a                	push   $0x6a
  jmp alltraps
80106742:	e9 f0 f5 ff ff       	jmp    80105d37 <alltraps>

80106747 <vector107>:
.globl vector107
vector107:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $107
80106749:	6a 6b                	push   $0x6b
  jmp alltraps
8010674b:	e9 e7 f5 ff ff       	jmp    80105d37 <alltraps>

80106750 <vector108>:
.globl vector108
vector108:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $108
80106752:	6a 6c                	push   $0x6c
  jmp alltraps
80106754:	e9 de f5 ff ff       	jmp    80105d37 <alltraps>

80106759 <vector109>:
.globl vector109
vector109:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $109
8010675b:	6a 6d                	push   $0x6d
  jmp alltraps
8010675d:	e9 d5 f5 ff ff       	jmp    80105d37 <alltraps>

80106762 <vector110>:
.globl vector110
vector110:
  pushl $0
80106762:	6a 00                	push   $0x0
  pushl $110
80106764:	6a 6e                	push   $0x6e
  jmp alltraps
80106766:	e9 cc f5 ff ff       	jmp    80105d37 <alltraps>

8010676b <vector111>:
.globl vector111
vector111:
  pushl $0
8010676b:	6a 00                	push   $0x0
  pushl $111
8010676d:	6a 6f                	push   $0x6f
  jmp alltraps
8010676f:	e9 c3 f5 ff ff       	jmp    80105d37 <alltraps>

80106774 <vector112>:
.globl vector112
vector112:
  pushl $0
80106774:	6a 00                	push   $0x0
  pushl $112
80106776:	6a 70                	push   $0x70
  jmp alltraps
80106778:	e9 ba f5 ff ff       	jmp    80105d37 <alltraps>

8010677d <vector113>:
.globl vector113
vector113:
  pushl $0
8010677d:	6a 00                	push   $0x0
  pushl $113
8010677f:	6a 71                	push   $0x71
  jmp alltraps
80106781:	e9 b1 f5 ff ff       	jmp    80105d37 <alltraps>

80106786 <vector114>:
.globl vector114
vector114:
  pushl $0
80106786:	6a 00                	push   $0x0
  pushl $114
80106788:	6a 72                	push   $0x72
  jmp alltraps
8010678a:	e9 a8 f5 ff ff       	jmp    80105d37 <alltraps>

8010678f <vector115>:
.globl vector115
vector115:
  pushl $0
8010678f:	6a 00                	push   $0x0
  pushl $115
80106791:	6a 73                	push   $0x73
  jmp alltraps
80106793:	e9 9f f5 ff ff       	jmp    80105d37 <alltraps>

80106798 <vector116>:
.globl vector116
vector116:
  pushl $0
80106798:	6a 00                	push   $0x0
  pushl $116
8010679a:	6a 74                	push   $0x74
  jmp alltraps
8010679c:	e9 96 f5 ff ff       	jmp    80105d37 <alltraps>

801067a1 <vector117>:
.globl vector117
vector117:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $117
801067a3:	6a 75                	push   $0x75
  jmp alltraps
801067a5:	e9 8d f5 ff ff       	jmp    80105d37 <alltraps>

801067aa <vector118>:
.globl vector118
vector118:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $118
801067ac:	6a 76                	push   $0x76
  jmp alltraps
801067ae:	e9 84 f5 ff ff       	jmp    80105d37 <alltraps>

801067b3 <vector119>:
.globl vector119
vector119:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $119
801067b5:	6a 77                	push   $0x77
  jmp alltraps
801067b7:	e9 7b f5 ff ff       	jmp    80105d37 <alltraps>

801067bc <vector120>:
.globl vector120
vector120:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $120
801067be:	6a 78                	push   $0x78
  jmp alltraps
801067c0:	e9 72 f5 ff ff       	jmp    80105d37 <alltraps>

801067c5 <vector121>:
.globl vector121
vector121:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $121
801067c7:	6a 79                	push   $0x79
  jmp alltraps
801067c9:	e9 69 f5 ff ff       	jmp    80105d37 <alltraps>

801067ce <vector122>:
.globl vector122
vector122:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $122
801067d0:	6a 7a                	push   $0x7a
  jmp alltraps
801067d2:	e9 60 f5 ff ff       	jmp    80105d37 <alltraps>

801067d7 <vector123>:
.globl vector123
vector123:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $123
801067d9:	6a 7b                	push   $0x7b
  jmp alltraps
801067db:	e9 57 f5 ff ff       	jmp    80105d37 <alltraps>

801067e0 <vector124>:
.globl vector124
vector124:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $124
801067e2:	6a 7c                	push   $0x7c
  jmp alltraps
801067e4:	e9 4e f5 ff ff       	jmp    80105d37 <alltraps>

801067e9 <vector125>:
.globl vector125
vector125:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $125
801067eb:	6a 7d                	push   $0x7d
  jmp alltraps
801067ed:	e9 45 f5 ff ff       	jmp    80105d37 <alltraps>

801067f2 <vector126>:
.globl vector126
vector126:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $126
801067f4:	6a 7e                	push   $0x7e
  jmp alltraps
801067f6:	e9 3c f5 ff ff       	jmp    80105d37 <alltraps>

801067fb <vector127>:
.globl vector127
vector127:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $127
801067fd:	6a 7f                	push   $0x7f
  jmp alltraps
801067ff:	e9 33 f5 ff ff       	jmp    80105d37 <alltraps>

80106804 <vector128>:
.globl vector128
vector128:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $128
80106806:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010680b:	e9 27 f5 ff ff       	jmp    80105d37 <alltraps>

80106810 <vector129>:
.globl vector129
vector129:
  pushl $0
80106810:	6a 00                	push   $0x0
  pushl $129
80106812:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106817:	e9 1b f5 ff ff       	jmp    80105d37 <alltraps>

8010681c <vector130>:
.globl vector130
vector130:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $130
8010681e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106823:	e9 0f f5 ff ff       	jmp    80105d37 <alltraps>

80106828 <vector131>:
.globl vector131
vector131:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $131
8010682a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010682f:	e9 03 f5 ff ff       	jmp    80105d37 <alltraps>

80106834 <vector132>:
.globl vector132
vector132:
  pushl $0
80106834:	6a 00                	push   $0x0
  pushl $132
80106836:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010683b:	e9 f7 f4 ff ff       	jmp    80105d37 <alltraps>

80106840 <vector133>:
.globl vector133
vector133:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $133
80106842:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106847:	e9 eb f4 ff ff       	jmp    80105d37 <alltraps>

8010684c <vector134>:
.globl vector134
vector134:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $134
8010684e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106853:	e9 df f4 ff ff       	jmp    80105d37 <alltraps>

80106858 <vector135>:
.globl vector135
vector135:
  pushl $0
80106858:	6a 00                	push   $0x0
  pushl $135
8010685a:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010685f:	e9 d3 f4 ff ff       	jmp    80105d37 <alltraps>

80106864 <vector136>:
.globl vector136
vector136:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $136
80106866:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010686b:	e9 c7 f4 ff ff       	jmp    80105d37 <alltraps>

80106870 <vector137>:
.globl vector137
vector137:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $137
80106872:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106877:	e9 bb f4 ff ff       	jmp    80105d37 <alltraps>

8010687c <vector138>:
.globl vector138
vector138:
  pushl $0
8010687c:	6a 00                	push   $0x0
  pushl $138
8010687e:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106883:	e9 af f4 ff ff       	jmp    80105d37 <alltraps>

80106888 <vector139>:
.globl vector139
vector139:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $139
8010688a:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010688f:	e9 a3 f4 ff ff       	jmp    80105d37 <alltraps>

80106894 <vector140>:
.globl vector140
vector140:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $140
80106896:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010689b:	e9 97 f4 ff ff       	jmp    80105d37 <alltraps>

801068a0 <vector141>:
.globl vector141
vector141:
  pushl $0
801068a0:	6a 00                	push   $0x0
  pushl $141
801068a2:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801068a7:	e9 8b f4 ff ff       	jmp    80105d37 <alltraps>

801068ac <vector142>:
.globl vector142
vector142:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $142
801068ae:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801068b3:	e9 7f f4 ff ff       	jmp    80105d37 <alltraps>

801068b8 <vector143>:
.globl vector143
vector143:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $143
801068ba:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801068bf:	e9 73 f4 ff ff       	jmp    80105d37 <alltraps>

801068c4 <vector144>:
.globl vector144
vector144:
  pushl $0
801068c4:	6a 00                	push   $0x0
  pushl $144
801068c6:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801068cb:	e9 67 f4 ff ff       	jmp    80105d37 <alltraps>

801068d0 <vector145>:
.globl vector145
vector145:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $145
801068d2:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801068d7:	e9 5b f4 ff ff       	jmp    80105d37 <alltraps>

801068dc <vector146>:
.globl vector146
vector146:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $146
801068de:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801068e3:	e9 4f f4 ff ff       	jmp    80105d37 <alltraps>

801068e8 <vector147>:
.globl vector147
vector147:
  pushl $0
801068e8:	6a 00                	push   $0x0
  pushl $147
801068ea:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801068ef:	e9 43 f4 ff ff       	jmp    80105d37 <alltraps>

801068f4 <vector148>:
.globl vector148
vector148:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $148
801068f6:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801068fb:	e9 37 f4 ff ff       	jmp    80105d37 <alltraps>

80106900 <vector149>:
.globl vector149
vector149:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $149
80106902:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106907:	e9 2b f4 ff ff       	jmp    80105d37 <alltraps>

8010690c <vector150>:
.globl vector150
vector150:
  pushl $0
8010690c:	6a 00                	push   $0x0
  pushl $150
8010690e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106913:	e9 1f f4 ff ff       	jmp    80105d37 <alltraps>

80106918 <vector151>:
.globl vector151
vector151:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $151
8010691a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010691f:	e9 13 f4 ff ff       	jmp    80105d37 <alltraps>

80106924 <vector152>:
.globl vector152
vector152:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $152
80106926:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010692b:	e9 07 f4 ff ff       	jmp    80105d37 <alltraps>

80106930 <vector153>:
.globl vector153
vector153:
  pushl $0
80106930:	6a 00                	push   $0x0
  pushl $153
80106932:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106937:	e9 fb f3 ff ff       	jmp    80105d37 <alltraps>

8010693c <vector154>:
.globl vector154
vector154:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $154
8010693e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106943:	e9 ef f3 ff ff       	jmp    80105d37 <alltraps>

80106948 <vector155>:
.globl vector155
vector155:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $155
8010694a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010694f:	e9 e3 f3 ff ff       	jmp    80105d37 <alltraps>

80106954 <vector156>:
.globl vector156
vector156:
  pushl $0
80106954:	6a 00                	push   $0x0
  pushl $156
80106956:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010695b:	e9 d7 f3 ff ff       	jmp    80105d37 <alltraps>

80106960 <vector157>:
.globl vector157
vector157:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $157
80106962:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106967:	e9 cb f3 ff ff       	jmp    80105d37 <alltraps>

8010696c <vector158>:
.globl vector158
vector158:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $158
8010696e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106973:	e9 bf f3 ff ff       	jmp    80105d37 <alltraps>

80106978 <vector159>:
.globl vector159
vector159:
  pushl $0
80106978:	6a 00                	push   $0x0
  pushl $159
8010697a:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010697f:	e9 b3 f3 ff ff       	jmp    80105d37 <alltraps>

80106984 <vector160>:
.globl vector160
vector160:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $160
80106986:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010698b:	e9 a7 f3 ff ff       	jmp    80105d37 <alltraps>

80106990 <vector161>:
.globl vector161
vector161:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $161
80106992:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106997:	e9 9b f3 ff ff       	jmp    80105d37 <alltraps>

8010699c <vector162>:
.globl vector162
vector162:
  pushl $0
8010699c:	6a 00                	push   $0x0
  pushl $162
8010699e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801069a3:	e9 8f f3 ff ff       	jmp    80105d37 <alltraps>

801069a8 <vector163>:
.globl vector163
vector163:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $163
801069aa:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801069af:	e9 83 f3 ff ff       	jmp    80105d37 <alltraps>

801069b4 <vector164>:
.globl vector164
vector164:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $164
801069b6:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801069bb:	e9 77 f3 ff ff       	jmp    80105d37 <alltraps>

801069c0 <vector165>:
.globl vector165
vector165:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $165
801069c2:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801069c7:	e9 6b f3 ff ff       	jmp    80105d37 <alltraps>

801069cc <vector166>:
.globl vector166
vector166:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $166
801069ce:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801069d3:	e9 5f f3 ff ff       	jmp    80105d37 <alltraps>

801069d8 <vector167>:
.globl vector167
vector167:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $167
801069da:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801069df:	e9 53 f3 ff ff       	jmp    80105d37 <alltraps>

801069e4 <vector168>:
.globl vector168
vector168:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $168
801069e6:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801069eb:	e9 47 f3 ff ff       	jmp    80105d37 <alltraps>

801069f0 <vector169>:
.globl vector169
vector169:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $169
801069f2:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801069f7:	e9 3b f3 ff ff       	jmp    80105d37 <alltraps>

801069fc <vector170>:
.globl vector170
vector170:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $170
801069fe:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a03:	e9 2f f3 ff ff       	jmp    80105d37 <alltraps>

80106a08 <vector171>:
.globl vector171
vector171:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $171
80106a0a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106a0f:	e9 23 f3 ff ff       	jmp    80105d37 <alltraps>

80106a14 <vector172>:
.globl vector172
vector172:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $172
80106a16:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a1b:	e9 17 f3 ff ff       	jmp    80105d37 <alltraps>

80106a20 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $173
80106a22:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a27:	e9 0b f3 ff ff       	jmp    80105d37 <alltraps>

80106a2c <vector174>:
.globl vector174
vector174:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $174
80106a2e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a33:	e9 ff f2 ff ff       	jmp    80105d37 <alltraps>

80106a38 <vector175>:
.globl vector175
vector175:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $175
80106a3a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106a3f:	e9 f3 f2 ff ff       	jmp    80105d37 <alltraps>

80106a44 <vector176>:
.globl vector176
vector176:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $176
80106a46:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106a4b:	e9 e7 f2 ff ff       	jmp    80105d37 <alltraps>

80106a50 <vector177>:
.globl vector177
vector177:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $177
80106a52:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106a57:	e9 db f2 ff ff       	jmp    80105d37 <alltraps>

80106a5c <vector178>:
.globl vector178
vector178:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $178
80106a5e:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106a63:	e9 cf f2 ff ff       	jmp    80105d37 <alltraps>

80106a68 <vector179>:
.globl vector179
vector179:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $179
80106a6a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106a6f:	e9 c3 f2 ff ff       	jmp    80105d37 <alltraps>

80106a74 <vector180>:
.globl vector180
vector180:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $180
80106a76:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106a7b:	e9 b7 f2 ff ff       	jmp    80105d37 <alltraps>

80106a80 <vector181>:
.globl vector181
vector181:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $181
80106a82:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106a87:	e9 ab f2 ff ff       	jmp    80105d37 <alltraps>

80106a8c <vector182>:
.globl vector182
vector182:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $182
80106a8e:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106a93:	e9 9f f2 ff ff       	jmp    80105d37 <alltraps>

80106a98 <vector183>:
.globl vector183
vector183:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $183
80106a9a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106a9f:	e9 93 f2 ff ff       	jmp    80105d37 <alltraps>

80106aa4 <vector184>:
.globl vector184
vector184:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $184
80106aa6:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106aab:	e9 87 f2 ff ff       	jmp    80105d37 <alltraps>

80106ab0 <vector185>:
.globl vector185
vector185:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $185
80106ab2:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106ab7:	e9 7b f2 ff ff       	jmp    80105d37 <alltraps>

80106abc <vector186>:
.globl vector186
vector186:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $186
80106abe:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ac3:	e9 6f f2 ff ff       	jmp    80105d37 <alltraps>

80106ac8 <vector187>:
.globl vector187
vector187:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $187
80106aca:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106acf:	e9 63 f2 ff ff       	jmp    80105d37 <alltraps>

80106ad4 <vector188>:
.globl vector188
vector188:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $188
80106ad6:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106adb:	e9 57 f2 ff ff       	jmp    80105d37 <alltraps>

80106ae0 <vector189>:
.globl vector189
vector189:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $189
80106ae2:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106ae7:	e9 4b f2 ff ff       	jmp    80105d37 <alltraps>

80106aec <vector190>:
.globl vector190
vector190:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $190
80106aee:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106af3:	e9 3f f2 ff ff       	jmp    80105d37 <alltraps>

80106af8 <vector191>:
.globl vector191
vector191:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $191
80106afa:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106aff:	e9 33 f2 ff ff       	jmp    80105d37 <alltraps>

80106b04 <vector192>:
.globl vector192
vector192:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $192
80106b06:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b0b:	e9 27 f2 ff ff       	jmp    80105d37 <alltraps>

80106b10 <vector193>:
.globl vector193
vector193:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $193
80106b12:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106b17:	e9 1b f2 ff ff       	jmp    80105d37 <alltraps>

80106b1c <vector194>:
.globl vector194
vector194:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $194
80106b1e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b23:	e9 0f f2 ff ff       	jmp    80105d37 <alltraps>

80106b28 <vector195>:
.globl vector195
vector195:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $195
80106b2a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106b2f:	e9 03 f2 ff ff       	jmp    80105d37 <alltraps>

80106b34 <vector196>:
.globl vector196
vector196:
  pushl $0
80106b34:	6a 00                	push   $0x0
  pushl $196
80106b36:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b3b:	e9 f7 f1 ff ff       	jmp    80105d37 <alltraps>

80106b40 <vector197>:
.globl vector197
vector197:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $197
80106b42:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106b47:	e9 eb f1 ff ff       	jmp    80105d37 <alltraps>

80106b4c <vector198>:
.globl vector198
vector198:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $198
80106b4e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106b53:	e9 df f1 ff ff       	jmp    80105d37 <alltraps>

80106b58 <vector199>:
.globl vector199
vector199:
  pushl $0
80106b58:	6a 00                	push   $0x0
  pushl $199
80106b5a:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106b5f:	e9 d3 f1 ff ff       	jmp    80105d37 <alltraps>

80106b64 <vector200>:
.globl vector200
vector200:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $200
80106b66:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106b6b:	e9 c7 f1 ff ff       	jmp    80105d37 <alltraps>

80106b70 <vector201>:
.globl vector201
vector201:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $201
80106b72:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106b77:	e9 bb f1 ff ff       	jmp    80105d37 <alltraps>

80106b7c <vector202>:
.globl vector202
vector202:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $202
80106b7e:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106b83:	e9 af f1 ff ff       	jmp    80105d37 <alltraps>

80106b88 <vector203>:
.globl vector203
vector203:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $203
80106b8a:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106b8f:	e9 a3 f1 ff ff       	jmp    80105d37 <alltraps>

80106b94 <vector204>:
.globl vector204
vector204:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $204
80106b96:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106b9b:	e9 97 f1 ff ff       	jmp    80105d37 <alltraps>

80106ba0 <vector205>:
.globl vector205
vector205:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $205
80106ba2:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106ba7:	e9 8b f1 ff ff       	jmp    80105d37 <alltraps>

80106bac <vector206>:
.globl vector206
vector206:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $206
80106bae:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106bb3:	e9 7f f1 ff ff       	jmp    80105d37 <alltraps>

80106bb8 <vector207>:
.globl vector207
vector207:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $207
80106bba:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106bbf:	e9 73 f1 ff ff       	jmp    80105d37 <alltraps>

80106bc4 <vector208>:
.globl vector208
vector208:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $208
80106bc6:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106bcb:	e9 67 f1 ff ff       	jmp    80105d37 <alltraps>

80106bd0 <vector209>:
.globl vector209
vector209:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $209
80106bd2:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106bd7:	e9 5b f1 ff ff       	jmp    80105d37 <alltraps>

80106bdc <vector210>:
.globl vector210
vector210:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $210
80106bde:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106be3:	e9 4f f1 ff ff       	jmp    80105d37 <alltraps>

80106be8 <vector211>:
.globl vector211
vector211:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $211
80106bea:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106bef:	e9 43 f1 ff ff       	jmp    80105d37 <alltraps>

80106bf4 <vector212>:
.globl vector212
vector212:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $212
80106bf6:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106bfb:	e9 37 f1 ff ff       	jmp    80105d37 <alltraps>

80106c00 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $213
80106c02:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c07:	e9 2b f1 ff ff       	jmp    80105d37 <alltraps>

80106c0c <vector214>:
.globl vector214
vector214:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $214
80106c0e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106c13:	e9 1f f1 ff ff       	jmp    80105d37 <alltraps>

80106c18 <vector215>:
.globl vector215
vector215:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $215
80106c1a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c1f:	e9 13 f1 ff ff       	jmp    80105d37 <alltraps>

80106c24 <vector216>:
.globl vector216
vector216:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $216
80106c26:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106c2b:	e9 07 f1 ff ff       	jmp    80105d37 <alltraps>

80106c30 <vector217>:
.globl vector217
vector217:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $217
80106c32:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c37:	e9 fb f0 ff ff       	jmp    80105d37 <alltraps>

80106c3c <vector218>:
.globl vector218
vector218:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $218
80106c3e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106c43:	e9 ef f0 ff ff       	jmp    80105d37 <alltraps>

80106c48 <vector219>:
.globl vector219
vector219:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $219
80106c4a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106c4f:	e9 e3 f0 ff ff       	jmp    80105d37 <alltraps>

80106c54 <vector220>:
.globl vector220
vector220:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $220
80106c56:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106c5b:	e9 d7 f0 ff ff       	jmp    80105d37 <alltraps>

80106c60 <vector221>:
.globl vector221
vector221:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $221
80106c62:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106c67:	e9 cb f0 ff ff       	jmp    80105d37 <alltraps>

80106c6c <vector222>:
.globl vector222
vector222:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $222
80106c6e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106c73:	e9 bf f0 ff ff       	jmp    80105d37 <alltraps>

80106c78 <vector223>:
.globl vector223
vector223:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $223
80106c7a:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106c7f:	e9 b3 f0 ff ff       	jmp    80105d37 <alltraps>

80106c84 <vector224>:
.globl vector224
vector224:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $224
80106c86:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106c8b:	e9 a7 f0 ff ff       	jmp    80105d37 <alltraps>

80106c90 <vector225>:
.globl vector225
vector225:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $225
80106c92:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106c97:	e9 9b f0 ff ff       	jmp    80105d37 <alltraps>

80106c9c <vector226>:
.globl vector226
vector226:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $226
80106c9e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106ca3:	e9 8f f0 ff ff       	jmp    80105d37 <alltraps>

80106ca8 <vector227>:
.globl vector227
vector227:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $227
80106caa:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106caf:	e9 83 f0 ff ff       	jmp    80105d37 <alltraps>

80106cb4 <vector228>:
.globl vector228
vector228:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $228
80106cb6:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106cbb:	e9 77 f0 ff ff       	jmp    80105d37 <alltraps>

80106cc0 <vector229>:
.globl vector229
vector229:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $229
80106cc2:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106cc7:	e9 6b f0 ff ff       	jmp    80105d37 <alltraps>

80106ccc <vector230>:
.globl vector230
vector230:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $230
80106cce:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106cd3:	e9 5f f0 ff ff       	jmp    80105d37 <alltraps>

80106cd8 <vector231>:
.globl vector231
vector231:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $231
80106cda:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106cdf:	e9 53 f0 ff ff       	jmp    80105d37 <alltraps>

80106ce4 <vector232>:
.globl vector232
vector232:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $232
80106ce6:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106ceb:	e9 47 f0 ff ff       	jmp    80105d37 <alltraps>

80106cf0 <vector233>:
.globl vector233
vector233:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $233
80106cf2:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106cf7:	e9 3b f0 ff ff       	jmp    80105d37 <alltraps>

80106cfc <vector234>:
.globl vector234
vector234:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $234
80106cfe:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d03:	e9 2f f0 ff ff       	jmp    80105d37 <alltraps>

80106d08 <vector235>:
.globl vector235
vector235:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $235
80106d0a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106d0f:	e9 23 f0 ff ff       	jmp    80105d37 <alltraps>

80106d14 <vector236>:
.globl vector236
vector236:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $236
80106d16:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d1b:	e9 17 f0 ff ff       	jmp    80105d37 <alltraps>

80106d20 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $237
80106d22:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d27:	e9 0b f0 ff ff       	jmp    80105d37 <alltraps>

80106d2c <vector238>:
.globl vector238
vector238:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $238
80106d2e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d33:	e9 ff ef ff ff       	jmp    80105d37 <alltraps>

80106d38 <vector239>:
.globl vector239
vector239:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $239
80106d3a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106d3f:	e9 f3 ef ff ff       	jmp    80105d37 <alltraps>

80106d44 <vector240>:
.globl vector240
vector240:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $240
80106d46:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106d4b:	e9 e7 ef ff ff       	jmp    80105d37 <alltraps>

80106d50 <vector241>:
.globl vector241
vector241:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $241
80106d52:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106d57:	e9 db ef ff ff       	jmp    80105d37 <alltraps>

80106d5c <vector242>:
.globl vector242
vector242:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $242
80106d5e:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106d63:	e9 cf ef ff ff       	jmp    80105d37 <alltraps>

80106d68 <vector243>:
.globl vector243
vector243:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $243
80106d6a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106d6f:	e9 c3 ef ff ff       	jmp    80105d37 <alltraps>

80106d74 <vector244>:
.globl vector244
vector244:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $244
80106d76:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106d7b:	e9 b7 ef ff ff       	jmp    80105d37 <alltraps>

80106d80 <vector245>:
.globl vector245
vector245:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $245
80106d82:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106d87:	e9 ab ef ff ff       	jmp    80105d37 <alltraps>

80106d8c <vector246>:
.globl vector246
vector246:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $246
80106d8e:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106d93:	e9 9f ef ff ff       	jmp    80105d37 <alltraps>

80106d98 <vector247>:
.globl vector247
vector247:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $247
80106d9a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106d9f:	e9 93 ef ff ff       	jmp    80105d37 <alltraps>

80106da4 <vector248>:
.globl vector248
vector248:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $248
80106da6:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106dab:	e9 87 ef ff ff       	jmp    80105d37 <alltraps>

80106db0 <vector249>:
.globl vector249
vector249:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $249
80106db2:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106db7:	e9 7b ef ff ff       	jmp    80105d37 <alltraps>

80106dbc <vector250>:
.globl vector250
vector250:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $250
80106dbe:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106dc3:	e9 6f ef ff ff       	jmp    80105d37 <alltraps>

80106dc8 <vector251>:
.globl vector251
vector251:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $251
80106dca:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106dcf:	e9 63 ef ff ff       	jmp    80105d37 <alltraps>

80106dd4 <vector252>:
.globl vector252
vector252:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $252
80106dd6:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106ddb:	e9 57 ef ff ff       	jmp    80105d37 <alltraps>

80106de0 <vector253>:
.globl vector253
vector253:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $253
80106de2:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106de7:	e9 4b ef ff ff       	jmp    80105d37 <alltraps>

80106dec <vector254>:
.globl vector254
vector254:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $254
80106dee:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106df3:	e9 3f ef ff ff       	jmp    80105d37 <alltraps>

80106df8 <vector255>:
.globl vector255
vector255:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $255
80106dfa:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106dff:	e9 33 ef ff ff       	jmp    80105d37 <alltraps>

80106e04 <lgdt>:
{
80106e04:	55                   	push   %ebp
80106e05:	89 e5                	mov    %esp,%ebp
80106e07:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e0d:	83 e8 01             	sub    $0x1,%eax
80106e10:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e14:	8b 45 08             	mov    0x8(%ebp),%eax
80106e17:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1e:	c1 e8 10             	shr    $0x10,%eax
80106e21:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106e25:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e28:	0f 01 10             	lgdtl  (%eax)
}
80106e2b:	90                   	nop
80106e2c:	c9                   	leave  
80106e2d:	c3                   	ret    

80106e2e <ltr>:
{
80106e2e:	55                   	push   %ebp
80106e2f:	89 e5                	mov    %esp,%ebp
80106e31:	83 ec 04             	sub    $0x4,%esp
80106e34:	8b 45 08             	mov    0x8(%ebp),%eax
80106e37:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106e3b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106e3f:	0f 00 d8             	ltr    %ax
}
80106e42:	90                   	nop
80106e43:	c9                   	leave  
80106e44:	c3                   	ret    

80106e45 <lcr3>:

static inline void
lcr3(uint val)
{
80106e45:	55                   	push   %ebp
80106e46:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e48:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4b:	0f 22 d8             	mov    %eax,%cr3
}
80106e4e:	90                   	nop
80106e4f:	5d                   	pop    %ebp
80106e50:	c3                   	ret    

80106e51 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106e51:	55                   	push   %ebp
80106e52:	89 e5                	mov    %esp,%ebp
80106e54:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106e57:	e8 41 cb ff ff       	call   8010399d <cpuid>
80106e5c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106e62:	05 80 6c 19 80       	add    $0x80196c80,%eax
80106e67:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e76:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e86:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e8a:	83 e2 f0             	and    $0xfffffff0,%edx
80106e8d:	83 ca 0a             	or     $0xa,%edx
80106e90:	88 50 7d             	mov    %dl,0x7d(%eax)
80106e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e96:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e9a:	83 ca 10             	or     $0x10,%edx
80106e9d:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ea7:	83 e2 9f             	and    $0xffffff9f,%edx
80106eaa:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106eb4:	83 ca 80             	or     $0xffffff80,%edx
80106eb7:	88 50 7d             	mov    %dl,0x7d(%eax)
80106eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ec1:	83 ca 0f             	or     $0xf,%edx
80106ec4:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ece:	83 e2 ef             	and    $0xffffffef,%edx
80106ed1:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106edb:	83 e2 df             	and    $0xffffffdf,%edx
80106ede:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ee8:	83 ca 40             	or     $0x40,%edx
80106eeb:	88 50 7e             	mov    %dl,0x7e(%eax)
80106eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ef5:	83 ca 80             	or     $0xffffff80,%edx
80106ef8:	88 50 7e             	mov    %dl,0x7e(%eax)
80106efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106efe:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f05:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106f0c:	ff ff 
80106f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f11:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106f18:	00 00 
80106f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1d:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f27:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f2e:	83 e2 f0             	and    $0xfffffff0,%edx
80106f31:	83 ca 02             	or     $0x2,%edx
80106f34:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f3d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f44:	83 ca 10             	or     $0x10,%edx
80106f47:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f50:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f57:	83 e2 9f             	and    $0xffffff9f,%edx
80106f5a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f63:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f6a:	83 ca 80             	or     $0xffffff80,%edx
80106f6d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f76:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f7d:	83 ca 0f             	or     $0xf,%edx
80106f80:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f89:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f90:	83 e2 ef             	and    $0xffffffef,%edx
80106f93:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fa3:	83 e2 df             	and    $0xffffffdf,%edx
80106fa6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106faf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fb6:	83 ca 40             	or     $0x40,%edx
80106fb9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fc9:	83 ca 80             	or     $0xffffff80,%edx
80106fcc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd5:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fdf:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80106fe6:	ff ff 
80106fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106feb:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80106ff2:	00 00 
80106ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff7:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80106ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107001:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107008:	83 e2 f0             	and    $0xfffffff0,%edx
8010700b:	83 ca 0a             	or     $0xa,%edx
8010700e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107017:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010701e:	83 ca 10             	or     $0x10,%edx
80107021:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107031:	83 ca 60             	or     $0x60,%edx
80107034:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010703a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107044:	83 ca 80             	or     $0xffffff80,%edx
80107047:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010704d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107050:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107057:	83 ca 0f             	or     $0xf,%edx
8010705a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107063:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010706a:	83 e2 ef             	and    $0xffffffef,%edx
8010706d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107076:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010707d:	83 e2 df             	and    $0xffffffdf,%edx
80107080:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107089:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107090:	83 ca 40             	or     $0x40,%edx
80107093:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070a3:	83 ca 80             	or     $0xffffff80,%edx
801070a6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070af:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801070b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b9:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801070c0:	ff ff 
801070c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c5:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801070cc:	00 00 
801070ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d1:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801070d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070db:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070e2:	83 e2 f0             	and    $0xfffffff0,%edx
801070e5:	83 ca 02             	or     $0x2,%edx
801070e8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801070ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070f8:	83 ca 10             	or     $0x10,%edx
801070fb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107104:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010710b:	83 ca 60             	or     $0x60,%edx
8010710e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107117:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010711e:	83 ca 80             	or     $0xffffff80,%edx
80107121:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107131:	83 ca 0f             	or     $0xf,%edx
80107134:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010713a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107144:	83 e2 ef             	and    $0xffffffef,%edx
80107147:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010714d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107150:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107157:	83 e2 df             	and    $0xffffffdf,%edx
8010715a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107163:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010716a:	83 ca 40             	or     $0x40,%edx
8010716d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107176:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010717d:	83 ca 80             	or     $0xffffff80,%edx
80107180:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107189:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107193:	83 c0 70             	add    $0x70,%eax
80107196:	83 ec 08             	sub    $0x8,%esp
80107199:	6a 30                	push   $0x30
8010719b:	50                   	push   %eax
8010719c:	e8 63 fc ff ff       	call   80106e04 <lgdt>
801071a1:	83 c4 10             	add    $0x10,%esp
}
801071a4:	90                   	nop
801071a5:	c9                   	leave  
801071a6:	c3                   	ret    

801071a7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801071a7:	55                   	push   %ebp
801071a8:	89 e5                	mov    %esp,%ebp
801071aa:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801071ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801071b0:	c1 e8 16             	shr    $0x16,%eax
801071b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801071ba:	8b 45 08             	mov    0x8(%ebp),%eax
801071bd:	01 d0                	add    %edx,%eax
801071bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801071c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071c5:	8b 00                	mov    (%eax),%eax
801071c7:	83 e0 01             	and    $0x1,%eax
801071ca:	85 c0                	test   %eax,%eax
801071cc:	74 14                	je     801071e2 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801071ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071d1:	8b 00                	mov    (%eax),%eax
801071d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071d8:	05 00 00 00 80       	add    $0x80000000,%eax
801071dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071e0:	eb 42                	jmp    80107224 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801071e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071e6:	74 0e                	je     801071f6 <walkpgdir+0x4f>
801071e8:	e8 b3 b5 ff ff       	call   801027a0 <kalloc>
801071ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071f4:	75 07                	jne    801071fd <walkpgdir+0x56>
      return 0;
801071f6:	b8 00 00 00 00       	mov    $0x0,%eax
801071fb:	eb 3e                	jmp    8010723b <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801071fd:	83 ec 04             	sub    $0x4,%esp
80107200:	68 00 10 00 00       	push   $0x1000
80107205:	6a 00                	push   $0x0
80107207:	ff 75 f4             	push   -0xc(%ebp)
8010720a:	e8 7a d7 ff ff       	call   80104989 <memset>
8010720f:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107215:	05 00 00 00 80       	add    $0x80000000,%eax
8010721a:	83 c8 07             	or     $0x7,%eax
8010721d:	89 c2                	mov    %eax,%edx
8010721f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107222:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107224:	8b 45 0c             	mov    0xc(%ebp),%eax
80107227:	c1 e8 0c             	shr    $0xc,%eax
8010722a:	25 ff 03 00 00       	and    $0x3ff,%eax
8010722f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107239:	01 d0                	add    %edx,%eax
}
8010723b:	c9                   	leave  
8010723c:	c3                   	ret    

8010723d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010723d:	55                   	push   %ebp
8010723e:	89 e5                	mov    %esp,%ebp
80107240:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107243:	8b 45 0c             	mov    0xc(%ebp),%eax
80107246:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010724b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010724e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107251:	8b 45 10             	mov    0x10(%ebp),%eax
80107254:	01 d0                	add    %edx,%eax
80107256:	83 e8 01             	sub    $0x1,%eax
80107259:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010725e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107261:	83 ec 04             	sub    $0x4,%esp
80107264:	6a 01                	push   $0x1
80107266:	ff 75 f4             	push   -0xc(%ebp)
80107269:	ff 75 08             	push   0x8(%ebp)
8010726c:	e8 36 ff ff ff       	call   801071a7 <walkpgdir>
80107271:	83 c4 10             	add    $0x10,%esp
80107274:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107277:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010727b:	75 07                	jne    80107284 <mappages+0x47>
      return -1;
8010727d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107282:	eb 47                	jmp    801072cb <mappages+0x8e>
    if(*pte & PTE_P)
80107284:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107287:	8b 00                	mov    (%eax),%eax
80107289:	83 e0 01             	and    $0x1,%eax
8010728c:	85 c0                	test   %eax,%eax
8010728e:	74 0d                	je     8010729d <mappages+0x60>
      panic("remap");
80107290:	83 ec 0c             	sub    $0xc,%esp
80107293:	68 68 a5 10 80       	push   $0x8010a568
80107298:	e8 0c 93 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010729d:	8b 45 18             	mov    0x18(%ebp),%eax
801072a0:	0b 45 14             	or     0x14(%ebp),%eax
801072a3:	83 c8 01             	or     $0x1,%eax
801072a6:	89 c2                	mov    %eax,%edx
801072a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072ab:	89 10                	mov    %edx,(%eax)
    if(a == last)
801072ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801072b3:	74 10                	je     801072c5 <mappages+0x88>
      break;
    a += PGSIZE;
801072b5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801072bc:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801072c3:	eb 9c                	jmp    80107261 <mappages+0x24>
      break;
801072c5:	90                   	nop
  }
  return 0;
801072c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072cb:	c9                   	leave  
801072cc:	c3                   	ret    

801072cd <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801072cd:	55                   	push   %ebp
801072ce:	89 e5                	mov    %esp,%ebp
801072d0:	53                   	push   %ebx
801072d1:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801072d4:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801072db:	8b 15 50 6f 19 80    	mov    0x80196f50,%edx
801072e1:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801072e6:	29 d0                	sub    %edx,%eax
801072e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801072eb:	a1 48 6f 19 80       	mov    0x80196f48,%eax
801072f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801072f3:	8b 15 48 6f 19 80    	mov    0x80196f48,%edx
801072f9:	a1 50 6f 19 80       	mov    0x80196f50,%eax
801072fe:	01 d0                	add    %edx,%eax
80107300:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107303:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010730a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730d:	83 c0 30             	add    $0x30,%eax
80107310:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107313:	89 10                	mov    %edx,(%eax)
80107315:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107318:	89 50 04             	mov    %edx,0x4(%eax)
8010731b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010731e:	89 50 08             	mov    %edx,0x8(%eax)
80107321:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107324:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107327:	e8 74 b4 ff ff       	call   801027a0 <kalloc>
8010732c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010732f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107333:	75 07                	jne    8010733c <setupkvm+0x6f>
    return 0;
80107335:	b8 00 00 00 00       	mov    $0x0,%eax
8010733a:	eb 78                	jmp    801073b4 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010733c:	83 ec 04             	sub    $0x4,%esp
8010733f:	68 00 10 00 00       	push   $0x1000
80107344:	6a 00                	push   $0x0
80107346:	ff 75 f0             	push   -0x10(%ebp)
80107349:	e8 3b d6 ff ff       	call   80104989 <memset>
8010734e:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107351:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107358:	eb 4e                	jmp    801073a8 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010735a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735d:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107363:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107369:	8b 58 08             	mov    0x8(%eax),%ebx
8010736c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736f:	8b 40 04             	mov    0x4(%eax),%eax
80107372:	29 c3                	sub    %eax,%ebx
80107374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107377:	8b 00                	mov    (%eax),%eax
80107379:	83 ec 0c             	sub    $0xc,%esp
8010737c:	51                   	push   %ecx
8010737d:	52                   	push   %edx
8010737e:	53                   	push   %ebx
8010737f:	50                   	push   %eax
80107380:	ff 75 f0             	push   -0x10(%ebp)
80107383:	e8 b5 fe ff ff       	call   8010723d <mappages>
80107388:	83 c4 20             	add    $0x20,%esp
8010738b:	85 c0                	test   %eax,%eax
8010738d:	79 15                	jns    801073a4 <setupkvm+0xd7>
      freevm(pgdir);
8010738f:	83 ec 0c             	sub    $0xc,%esp
80107392:	ff 75 f0             	push   -0x10(%ebp)
80107395:	e8 f5 04 00 00       	call   8010788f <freevm>
8010739a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010739d:	b8 00 00 00 00       	mov    $0x0,%eax
801073a2:	eb 10                	jmp    801073b4 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073a4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801073a8:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
801073af:	72 a9                	jb     8010735a <setupkvm+0x8d>
    }
  return pgdir;
801073b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801073b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801073b7:	c9                   	leave  
801073b8:	c3                   	ret    

801073b9 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801073b9:	55                   	push   %ebp
801073ba:	89 e5                	mov    %esp,%ebp
801073bc:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801073bf:	e8 09 ff ff ff       	call   801072cd <setupkvm>
801073c4:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  switchkvm();
801073c9:	e8 03 00 00 00       	call   801073d1 <switchkvm>
}
801073ce:	90                   	nop
801073cf:	c9                   	leave  
801073d0:	c3                   	ret    

801073d1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801073d1:	55                   	push   %ebp
801073d2:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801073d4:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801073d9:	05 00 00 00 80       	add    $0x80000000,%eax
801073de:	50                   	push   %eax
801073df:	e8 61 fa ff ff       	call   80106e45 <lcr3>
801073e4:	83 c4 04             	add    $0x4,%esp
}
801073e7:	90                   	nop
801073e8:	c9                   	leave  
801073e9:	c3                   	ret    

801073ea <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801073ea:	55                   	push   %ebp
801073eb:	89 e5                	mov    %esp,%ebp
801073ed:	56                   	push   %esi
801073ee:	53                   	push   %ebx
801073ef:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801073f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801073f6:	75 0d                	jne    80107405 <switchuvm+0x1b>
    panic("switchuvm: no process");
801073f8:	83 ec 0c             	sub    $0xc,%esp
801073fb:	68 6e a5 10 80       	push   $0x8010a56e
80107400:	e8 a4 91 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107405:	8b 45 08             	mov    0x8(%ebp),%eax
80107408:	8b 40 08             	mov    0x8(%eax),%eax
8010740b:	85 c0                	test   %eax,%eax
8010740d:	75 0d                	jne    8010741c <switchuvm+0x32>
    panic("switchuvm: no kstack");
8010740f:	83 ec 0c             	sub    $0xc,%esp
80107412:	68 84 a5 10 80       	push   $0x8010a584
80107417:	e8 8d 91 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
8010741c:	8b 45 08             	mov    0x8(%ebp),%eax
8010741f:	8b 40 04             	mov    0x4(%eax),%eax
80107422:	85 c0                	test   %eax,%eax
80107424:	75 0d                	jne    80107433 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107426:	83 ec 0c             	sub    $0xc,%esp
80107429:	68 99 a5 10 80       	push   $0x8010a599
8010742e:	e8 76 91 ff ff       	call   801005a9 <panic>

  pushcli();
80107433:	e8 46 d4 ff ff       	call   8010487e <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107438:	e8 7b c5 ff ff       	call   801039b8 <mycpu>
8010743d:	89 c3                	mov    %eax,%ebx
8010743f:	e8 74 c5 ff ff       	call   801039b8 <mycpu>
80107444:	83 c0 08             	add    $0x8,%eax
80107447:	89 c6                	mov    %eax,%esi
80107449:	e8 6a c5 ff ff       	call   801039b8 <mycpu>
8010744e:	83 c0 08             	add    $0x8,%eax
80107451:	c1 e8 10             	shr    $0x10,%eax
80107454:	88 45 f7             	mov    %al,-0x9(%ebp)
80107457:	e8 5c c5 ff ff       	call   801039b8 <mycpu>
8010745c:	83 c0 08             	add    $0x8,%eax
8010745f:	c1 e8 18             	shr    $0x18,%eax
80107462:	89 c2                	mov    %eax,%edx
80107464:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010746b:	67 00 
8010746d:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107474:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107478:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010747e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107485:	83 e0 f0             	and    $0xfffffff0,%eax
80107488:	83 c8 09             	or     $0x9,%eax
8010748b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107491:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107498:	83 c8 10             	or     $0x10,%eax
8010749b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074a1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074a8:	83 e0 9f             	and    $0xffffff9f,%eax
801074ab:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074b1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074b8:	83 c8 80             	or     $0xffffff80,%eax
801074bb:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074c1:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074c8:	83 e0 f0             	and    $0xfffffff0,%eax
801074cb:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074d1:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074d8:	83 e0 ef             	and    $0xffffffef,%eax
801074db:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074e1:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074e8:	83 e0 df             	and    $0xffffffdf,%eax
801074eb:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074f1:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074f8:	83 c8 40             	or     $0x40,%eax
801074fb:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107501:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107508:	83 e0 7f             	and    $0x7f,%eax
8010750b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107511:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107517:	e8 9c c4 ff ff       	call   801039b8 <mycpu>
8010751c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107523:	83 e2 ef             	and    $0xffffffef,%edx
80107526:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010752c:	e8 87 c4 ff ff       	call   801039b8 <mycpu>
80107531:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107537:	8b 45 08             	mov    0x8(%ebp),%eax
8010753a:	8b 40 08             	mov    0x8(%eax),%eax
8010753d:	89 c3                	mov    %eax,%ebx
8010753f:	e8 74 c4 ff ff       	call   801039b8 <mycpu>
80107544:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010754a:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010754d:	e8 66 c4 ff ff       	call   801039b8 <mycpu>
80107552:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107558:	83 ec 0c             	sub    $0xc,%esp
8010755b:	6a 28                	push   $0x28
8010755d:	e8 cc f8 ff ff       	call   80106e2e <ltr>
80107562:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107565:	8b 45 08             	mov    0x8(%ebp),%eax
80107568:	8b 40 04             	mov    0x4(%eax),%eax
8010756b:	05 00 00 00 80       	add    $0x80000000,%eax
80107570:	83 ec 0c             	sub    $0xc,%esp
80107573:	50                   	push   %eax
80107574:	e8 cc f8 ff ff       	call   80106e45 <lcr3>
80107579:	83 c4 10             	add    $0x10,%esp
  popcli();
8010757c:	e8 4a d3 ff ff       	call   801048cb <popcli>
}
80107581:	90                   	nop
80107582:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107585:	5b                   	pop    %ebx
80107586:	5e                   	pop    %esi
80107587:	5d                   	pop    %ebp
80107588:	c3                   	ret    

80107589 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107589:	55                   	push   %ebp
8010758a:	89 e5                	mov    %esp,%ebp
8010758c:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010758f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107596:	76 0d                	jbe    801075a5 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107598:	83 ec 0c             	sub    $0xc,%esp
8010759b:	68 ad a5 10 80       	push   $0x8010a5ad
801075a0:	e8 04 90 ff ff       	call   801005a9 <panic>
  mem = kalloc();
801075a5:	e8 f6 b1 ff ff       	call   801027a0 <kalloc>
801075aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801075ad:	83 ec 04             	sub    $0x4,%esp
801075b0:	68 00 10 00 00       	push   $0x1000
801075b5:	6a 00                	push   $0x0
801075b7:	ff 75 f4             	push   -0xc(%ebp)
801075ba:	e8 ca d3 ff ff       	call   80104989 <memset>
801075bf:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801075c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c5:	05 00 00 00 80       	add    $0x80000000,%eax
801075ca:	83 ec 0c             	sub    $0xc,%esp
801075cd:	6a 06                	push   $0x6
801075cf:	50                   	push   %eax
801075d0:	68 00 10 00 00       	push   $0x1000
801075d5:	6a 00                	push   $0x0
801075d7:	ff 75 08             	push   0x8(%ebp)
801075da:	e8 5e fc ff ff       	call   8010723d <mappages>
801075df:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801075e2:	83 ec 04             	sub    $0x4,%esp
801075e5:	ff 75 10             	push   0x10(%ebp)
801075e8:	ff 75 0c             	push   0xc(%ebp)
801075eb:	ff 75 f4             	push   -0xc(%ebp)
801075ee:	e8 55 d4 ff ff       	call   80104a48 <memmove>
801075f3:	83 c4 10             	add    $0x10,%esp
}
801075f6:	90                   	nop
801075f7:	c9                   	leave  
801075f8:	c3                   	ret    

801075f9 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801075f9:	55                   	push   %ebp
801075fa:	89 e5                	mov    %esp,%ebp
801075fc:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801075ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107602:	25 ff 0f 00 00       	and    $0xfff,%eax
80107607:	85 c0                	test   %eax,%eax
80107609:	74 0d                	je     80107618 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010760b:	83 ec 0c             	sub    $0xc,%esp
8010760e:	68 c8 a5 10 80       	push   $0x8010a5c8
80107613:	e8 91 8f ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107618:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010761f:	e9 8f 00 00 00       	jmp    801076b3 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107624:	8b 55 0c             	mov    0xc(%ebp),%edx
80107627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762a:	01 d0                	add    %edx,%eax
8010762c:	83 ec 04             	sub    $0x4,%esp
8010762f:	6a 00                	push   $0x0
80107631:	50                   	push   %eax
80107632:	ff 75 08             	push   0x8(%ebp)
80107635:	e8 6d fb ff ff       	call   801071a7 <walkpgdir>
8010763a:	83 c4 10             	add    $0x10,%esp
8010763d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107640:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107644:	75 0d                	jne    80107653 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107646:	83 ec 0c             	sub    $0xc,%esp
80107649:	68 eb a5 10 80       	push   $0x8010a5eb
8010764e:	e8 56 8f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107653:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107656:	8b 00                	mov    (%eax),%eax
80107658:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010765d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107660:	8b 45 18             	mov    0x18(%ebp),%eax
80107663:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107666:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010766b:	77 0b                	ja     80107678 <loaduvm+0x7f>
      n = sz - i;
8010766d:	8b 45 18             	mov    0x18(%ebp),%eax
80107670:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107673:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107676:	eb 07                	jmp    8010767f <loaduvm+0x86>
    else
      n = PGSIZE;
80107678:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010767f:	8b 55 14             	mov    0x14(%ebp),%edx
80107682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107685:	01 d0                	add    %edx,%eax
80107687:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010768a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107690:	ff 75 f0             	push   -0x10(%ebp)
80107693:	50                   	push   %eax
80107694:	52                   	push   %edx
80107695:	ff 75 10             	push   0x10(%ebp)
80107698:	e8 39 a8 ff ff       	call   80101ed6 <readi>
8010769d:	83 c4 10             	add    $0x10,%esp
801076a0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801076a3:	74 07                	je     801076ac <loaduvm+0xb3>
      return -1;
801076a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076aa:	eb 18                	jmp    801076c4 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801076ac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b6:	3b 45 18             	cmp    0x18(%ebp),%eax
801076b9:	0f 82 65 ff ff ff    	jb     80107624 <loaduvm+0x2b>
  }
  return 0;
801076bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801076c4:	c9                   	leave  
801076c5:	c3                   	ret    

801076c6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801076c6:	55                   	push   %ebp
801076c7:	89 e5                	mov    %esp,%ebp
801076c9:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801076cc:	8b 45 10             	mov    0x10(%ebp),%eax
801076cf:	85 c0                	test   %eax,%eax
801076d1:	79 0a                	jns    801076dd <allocuvm+0x17>
    return 0;
801076d3:	b8 00 00 00 00       	mov    $0x0,%eax
801076d8:	e9 ec 00 00 00       	jmp    801077c9 <allocuvm+0x103>
  if(newsz < oldsz)
801076dd:	8b 45 10             	mov    0x10(%ebp),%eax
801076e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801076e3:	73 08                	jae    801076ed <allocuvm+0x27>
    return oldsz;
801076e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801076e8:	e9 dc 00 00 00       	jmp    801077c9 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801076ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801076f0:	05 ff 0f 00 00       	add    $0xfff,%eax
801076f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801076fd:	e9 b8 00 00 00       	jmp    801077ba <allocuvm+0xf4>
    mem = kalloc();
80107702:	e8 99 b0 ff ff       	call   801027a0 <kalloc>
80107707:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010770a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010770e:	75 2e                	jne    8010773e <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107710:	83 ec 0c             	sub    $0xc,%esp
80107713:	68 09 a6 10 80       	push   $0x8010a609
80107718:	e8 d7 8c ff ff       	call   801003f4 <cprintf>
8010771d:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107720:	83 ec 04             	sub    $0x4,%esp
80107723:	ff 75 0c             	push   0xc(%ebp)
80107726:	ff 75 10             	push   0x10(%ebp)
80107729:	ff 75 08             	push   0x8(%ebp)
8010772c:	e8 9a 00 00 00       	call   801077cb <deallocuvm>
80107731:	83 c4 10             	add    $0x10,%esp
      return 0;
80107734:	b8 00 00 00 00       	mov    $0x0,%eax
80107739:	e9 8b 00 00 00       	jmp    801077c9 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010773e:	83 ec 04             	sub    $0x4,%esp
80107741:	68 00 10 00 00       	push   $0x1000
80107746:	6a 00                	push   $0x0
80107748:	ff 75 f0             	push   -0x10(%ebp)
8010774b:	e8 39 d2 ff ff       	call   80104989 <memset>
80107750:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107756:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010775c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775f:	83 ec 0c             	sub    $0xc,%esp
80107762:	6a 06                	push   $0x6
80107764:	52                   	push   %edx
80107765:	68 00 10 00 00       	push   $0x1000
8010776a:	50                   	push   %eax
8010776b:	ff 75 08             	push   0x8(%ebp)
8010776e:	e8 ca fa ff ff       	call   8010723d <mappages>
80107773:	83 c4 20             	add    $0x20,%esp
80107776:	85 c0                	test   %eax,%eax
80107778:	79 39                	jns    801077b3 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010777a:	83 ec 0c             	sub    $0xc,%esp
8010777d:	68 21 a6 10 80       	push   $0x8010a621
80107782:	e8 6d 8c ff ff       	call   801003f4 <cprintf>
80107787:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010778a:	83 ec 04             	sub    $0x4,%esp
8010778d:	ff 75 0c             	push   0xc(%ebp)
80107790:	ff 75 10             	push   0x10(%ebp)
80107793:	ff 75 08             	push   0x8(%ebp)
80107796:	e8 30 00 00 00       	call   801077cb <deallocuvm>
8010779b:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010779e:	83 ec 0c             	sub    $0xc,%esp
801077a1:	ff 75 f0             	push   -0x10(%ebp)
801077a4:	e8 5d af ff ff       	call   80102706 <kfree>
801077a9:	83 c4 10             	add    $0x10,%esp
      return 0;
801077ac:	b8 00 00 00 00       	mov    $0x0,%eax
801077b1:	eb 16                	jmp    801077c9 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801077b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bd:	3b 45 10             	cmp    0x10(%ebp),%eax
801077c0:	0f 82 3c ff ff ff    	jb     80107702 <allocuvm+0x3c>
    }
  }
  return newsz;
801077c6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801077c9:	c9                   	leave  
801077ca:	c3                   	ret    

801077cb <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077cb:	55                   	push   %ebp
801077cc:	89 e5                	mov    %esp,%ebp
801077ce:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801077d1:	8b 45 10             	mov    0x10(%ebp),%eax
801077d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077d7:	72 08                	jb     801077e1 <deallocuvm+0x16>
    return oldsz;
801077d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801077dc:	e9 ac 00 00 00       	jmp    8010788d <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801077e1:	8b 45 10             	mov    0x10(%ebp),%eax
801077e4:	05 ff 0f 00 00       	add    $0xfff,%eax
801077e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801077f1:	e9 88 00 00 00       	jmp    8010787e <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	83 ec 04             	sub    $0x4,%esp
801077fc:	6a 00                	push   $0x0
801077fe:	50                   	push   %eax
801077ff:	ff 75 08             	push   0x8(%ebp)
80107802:	e8 a0 f9 ff ff       	call   801071a7 <walkpgdir>
80107807:	83 c4 10             	add    $0x10,%esp
8010780a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010780d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107811:	75 16                	jne    80107829 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107816:	c1 e8 16             	shr    $0x16,%eax
80107819:	83 c0 01             	add    $0x1,%eax
8010781c:	c1 e0 16             	shl    $0x16,%eax
8010781f:	2d 00 10 00 00       	sub    $0x1000,%eax
80107824:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107827:	eb 4e                	jmp    80107877 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010782c:	8b 00                	mov    (%eax),%eax
8010782e:	83 e0 01             	and    $0x1,%eax
80107831:	85 c0                	test   %eax,%eax
80107833:	74 42                	je     80107877 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107838:	8b 00                	mov    (%eax),%eax
8010783a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010783f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107842:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107846:	75 0d                	jne    80107855 <deallocuvm+0x8a>
        panic("kfree");
80107848:	83 ec 0c             	sub    $0xc,%esp
8010784b:	68 3d a6 10 80       	push   $0x8010a63d
80107850:	e8 54 8d ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107855:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107858:	05 00 00 00 80       	add    $0x80000000,%eax
8010785d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107860:	83 ec 0c             	sub    $0xc,%esp
80107863:	ff 75 e8             	push   -0x18(%ebp)
80107866:	e8 9b ae ff ff       	call   80102706 <kfree>
8010786b:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010786e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107871:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107877:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010787e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107881:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107884:	0f 82 6c ff ff ff    	jb     801077f6 <deallocuvm+0x2b>
    }
  }
  return newsz;
8010788a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010788d:	c9                   	leave  
8010788e:	c3                   	ret    

8010788f <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010788f:	55                   	push   %ebp
80107890:	89 e5                	mov    %esp,%ebp
80107892:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107895:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107899:	75 0d                	jne    801078a8 <freevm+0x19>
    panic("freevm: no pgdir");
8010789b:	83 ec 0c             	sub    $0xc,%esp
8010789e:	68 43 a6 10 80       	push   $0x8010a643
801078a3:	e8 01 8d ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801078a8:	83 ec 04             	sub    $0x4,%esp
801078ab:	6a 00                	push   $0x0
801078ad:	68 00 00 00 80       	push   $0x80000000
801078b2:	ff 75 08             	push   0x8(%ebp)
801078b5:	e8 11 ff ff ff       	call   801077cb <deallocuvm>
801078ba:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801078bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078c4:	eb 48                	jmp    8010790e <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801078c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078d0:	8b 45 08             	mov    0x8(%ebp),%eax
801078d3:	01 d0                	add    %edx,%eax
801078d5:	8b 00                	mov    (%eax),%eax
801078d7:	83 e0 01             	and    $0x1,%eax
801078da:	85 c0                	test   %eax,%eax
801078dc:	74 2c                	je     8010790a <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801078de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078e8:	8b 45 08             	mov    0x8(%ebp),%eax
801078eb:	01 d0                	add    %edx,%eax
801078ed:	8b 00                	mov    (%eax),%eax
801078ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078f4:	05 00 00 00 80       	add    $0x80000000,%eax
801078f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801078fc:	83 ec 0c             	sub    $0xc,%esp
801078ff:	ff 75 f0             	push   -0x10(%ebp)
80107902:	e8 ff ad ff ff       	call   80102706 <kfree>
80107907:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010790a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010790e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107915:	76 af                	jbe    801078c6 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107917:	83 ec 0c             	sub    $0xc,%esp
8010791a:	ff 75 08             	push   0x8(%ebp)
8010791d:	e8 e4 ad ff ff       	call   80102706 <kfree>
80107922:	83 c4 10             	add    $0x10,%esp
}
80107925:	90                   	nop
80107926:	c9                   	leave  
80107927:	c3                   	ret    

80107928 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107928:	55                   	push   %ebp
80107929:	89 e5                	mov    %esp,%ebp
8010792b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010792e:	83 ec 04             	sub    $0x4,%esp
80107931:	6a 00                	push   $0x0
80107933:	ff 75 0c             	push   0xc(%ebp)
80107936:	ff 75 08             	push   0x8(%ebp)
80107939:	e8 69 f8 ff ff       	call   801071a7 <walkpgdir>
8010793e:	83 c4 10             	add    $0x10,%esp
80107941:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107944:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107948:	75 0d                	jne    80107957 <clearpteu+0x2f>
    panic("clearpteu");
8010794a:	83 ec 0c             	sub    $0xc,%esp
8010794d:	68 54 a6 10 80       	push   $0x8010a654
80107952:	e8 52 8c ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795a:	8b 00                	mov    (%eax),%eax
8010795c:	83 e0 fb             	and    $0xfffffffb,%eax
8010795f:	89 c2                	mov    %eax,%edx
80107961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107964:	89 10                	mov    %edx,(%eax)
}
80107966:	90                   	nop
80107967:	c9                   	leave  
80107968:	c3                   	ret    

80107969 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107969:	55                   	push   %ebp
8010796a:	89 e5                	mov    %esp,%ebp
8010796c:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010796f:	e8 59 f9 ff ff       	call   801072cd <setupkvm>
80107974:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107977:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010797b:	75 0a                	jne    80107987 <copyuvm+0x1e>
    return 0;
8010797d:	b8 00 00 00 00       	mov    $0x0,%eax
80107982:	e9 eb 00 00 00       	jmp    80107a72 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107987:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010798e:	e9 b7 00 00 00       	jmp    80107a4a <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107996:	83 ec 04             	sub    $0x4,%esp
80107999:	6a 00                	push   $0x0
8010799b:	50                   	push   %eax
8010799c:	ff 75 08             	push   0x8(%ebp)
8010799f:	e8 03 f8 ff ff       	call   801071a7 <walkpgdir>
801079a4:	83 c4 10             	add    $0x10,%esp
801079a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079ae:	75 0d                	jne    801079bd <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801079b0:	83 ec 0c             	sub    $0xc,%esp
801079b3:	68 5e a6 10 80       	push   $0x8010a65e
801079b8:	e8 ec 8b ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801079bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079c0:	8b 00                	mov    (%eax),%eax
801079c2:	83 e0 01             	and    $0x1,%eax
801079c5:	85 c0                	test   %eax,%eax
801079c7:	75 0d                	jne    801079d6 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801079c9:	83 ec 0c             	sub    $0xc,%esp
801079cc:	68 78 a6 10 80       	push   $0x8010a678
801079d1:	e8 d3 8b ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801079d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079d9:	8b 00                	mov    (%eax),%eax
801079db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801079e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079e6:	8b 00                	mov    (%eax),%eax
801079e8:	25 ff 0f 00 00       	and    $0xfff,%eax
801079ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801079f0:	e8 ab ad ff ff       	call   801027a0 <kalloc>
801079f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801079f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801079fc:	74 5d                	je     80107a5b <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801079fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a01:	05 00 00 00 80       	add    $0x80000000,%eax
80107a06:	83 ec 04             	sub    $0x4,%esp
80107a09:	68 00 10 00 00       	push   $0x1000
80107a0e:	50                   	push   %eax
80107a0f:	ff 75 e0             	push   -0x20(%ebp)
80107a12:	e8 31 d0 ff ff       	call   80104a48 <memmove>
80107a17:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107a1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a20:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a29:	83 ec 0c             	sub    $0xc,%esp
80107a2c:	52                   	push   %edx
80107a2d:	51                   	push   %ecx
80107a2e:	68 00 10 00 00       	push   $0x1000
80107a33:	50                   	push   %eax
80107a34:	ff 75 f0             	push   -0x10(%ebp)
80107a37:	e8 01 f8 ff ff       	call   8010723d <mappages>
80107a3c:	83 c4 20             	add    $0x20,%esp
80107a3f:	85 c0                	test   %eax,%eax
80107a41:	78 1b                	js     80107a5e <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107a43:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a50:	0f 82 3d ff ff ff    	jb     80107993 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a59:	eb 17                	jmp    80107a72 <copyuvm+0x109>
      goto bad;
80107a5b:	90                   	nop
80107a5c:	eb 01                	jmp    80107a5f <copyuvm+0xf6>
      goto bad;
80107a5e:	90                   	nop

bad:
  freevm(d);
80107a5f:	83 ec 0c             	sub    $0xc,%esp
80107a62:	ff 75 f0             	push   -0x10(%ebp)
80107a65:	e8 25 fe ff ff       	call   8010788f <freevm>
80107a6a:	83 c4 10             	add    $0x10,%esp
  return 0;
80107a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a72:	c9                   	leave  
80107a73:	c3                   	ret    

80107a74 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a74:	55                   	push   %ebp
80107a75:	89 e5                	mov    %esp,%ebp
80107a77:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a7a:	83 ec 04             	sub    $0x4,%esp
80107a7d:	6a 00                	push   $0x0
80107a7f:	ff 75 0c             	push   0xc(%ebp)
80107a82:	ff 75 08             	push   0x8(%ebp)
80107a85:	e8 1d f7 ff ff       	call   801071a7 <walkpgdir>
80107a8a:	83 c4 10             	add    $0x10,%esp
80107a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	8b 00                	mov    (%eax),%eax
80107a95:	83 e0 01             	and    $0x1,%eax
80107a98:	85 c0                	test   %eax,%eax
80107a9a:	75 07                	jne    80107aa3 <uva2ka+0x2f>
    return 0;
80107a9c:	b8 00 00 00 00       	mov    $0x0,%eax
80107aa1:	eb 22                	jmp    80107ac5 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa6:	8b 00                	mov    (%eax),%eax
80107aa8:	83 e0 04             	and    $0x4,%eax
80107aab:	85 c0                	test   %eax,%eax
80107aad:	75 07                	jne    80107ab6 <uva2ka+0x42>
    return 0;
80107aaf:	b8 00 00 00 00       	mov    $0x0,%eax
80107ab4:	eb 0f                	jmp    80107ac5 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab9:	8b 00                	mov    (%eax),%eax
80107abb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ac0:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107ac5:	c9                   	leave  
80107ac6:	c3                   	ret    

80107ac7 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107ac7:	55                   	push   %ebp
80107ac8:	89 e5                	mov    %esp,%ebp
80107aca:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107acd:	8b 45 10             	mov    0x10(%ebp),%eax
80107ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107ad3:	eb 7f                	jmp    80107b54 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ad8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107add:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ae3:	83 ec 08             	sub    $0x8,%esp
80107ae6:	50                   	push   %eax
80107ae7:	ff 75 08             	push   0x8(%ebp)
80107aea:	e8 85 ff ff ff       	call   80107a74 <uva2ka>
80107aef:	83 c4 10             	add    $0x10,%esp
80107af2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107af5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107af9:	75 07                	jne    80107b02 <copyout+0x3b>
      return -1;
80107afb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b00:	eb 61                	jmp    80107b63 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b05:	2b 45 0c             	sub    0xc(%ebp),%eax
80107b08:	05 00 10 00 00       	add    $0x1000,%eax
80107b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b13:	3b 45 14             	cmp    0x14(%ebp),%eax
80107b16:	76 06                	jbe    80107b1e <copyout+0x57>
      n = len;
80107b18:	8b 45 14             	mov    0x14(%ebp),%eax
80107b1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b21:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107b24:	89 c2                	mov    %eax,%edx
80107b26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b29:	01 d0                	add    %edx,%eax
80107b2b:	83 ec 04             	sub    $0x4,%esp
80107b2e:	ff 75 f0             	push   -0x10(%ebp)
80107b31:	ff 75 f4             	push   -0xc(%ebp)
80107b34:	50                   	push   %eax
80107b35:	e8 0e cf ff ff       	call   80104a48 <memmove>
80107b3a:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b40:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b46:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107b49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b4c:	05 00 10 00 00       	add    $0x1000,%eax
80107b51:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107b54:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107b58:	0f 85 77 ff ff ff    	jne    80107ad5 <copyout+0xe>
  }
  return 0;
80107b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b63:	c9                   	leave  
80107b64:	c3                   	ret    

80107b65 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107b65:	55                   	push   %ebp
80107b66:	89 e5                	mov    %esp,%ebp
80107b68:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107b6b:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107b72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107b75:	8b 40 08             	mov    0x8(%eax),%eax
80107b78:	05 00 00 00 80       	add    $0x80000000,%eax
80107b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107b80:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8a:	8b 40 24             	mov    0x24(%eax),%eax
80107b8d:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107b92:	c7 05 40 6f 19 80 00 	movl   $0x0,0x80196f40
80107b99:	00 00 00 

  while(i<madt->len){
80107b9c:	90                   	nop
80107b9d:	e9 bd 00 00 00       	jmp    80107c5f <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107ba2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ba8:	01 d0                	add    %edx,%eax
80107baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bb0:	0f b6 00             	movzbl (%eax),%eax
80107bb3:	0f b6 c0             	movzbl %al,%eax
80107bb6:	83 f8 05             	cmp    $0x5,%eax
80107bb9:	0f 87 a0 00 00 00    	ja     80107c5f <mpinit_uefi+0xfa>
80107bbf:	8b 04 85 94 a6 10 80 	mov    -0x7fef596c(,%eax,4),%eax
80107bc6:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107bce:	a1 40 6f 19 80       	mov    0x80196f40,%eax
80107bd3:	83 f8 03             	cmp    $0x3,%eax
80107bd6:	7f 28                	jg     80107c00 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107bd8:	8b 15 40 6f 19 80    	mov    0x80196f40,%edx
80107bde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107be1:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107be5:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107beb:	81 c2 80 6c 19 80    	add    $0x80196c80,%edx
80107bf1:	88 02                	mov    %al,(%edx)
          ncpu++;
80107bf3:	a1 40 6f 19 80       	mov    0x80196f40,%eax
80107bf8:	83 c0 01             	add    $0x1,%eax
80107bfb:	a3 40 6f 19 80       	mov    %eax,0x80196f40
        }
        i += lapic_entry->record_len;
80107c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c03:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c07:	0f b6 c0             	movzbl %al,%eax
80107c0a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c0d:	eb 50                	jmp    80107c5f <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107c15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c18:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107c1c:	a2 44 6f 19 80       	mov    %al,0x80196f44
        i += ioapic->record_len;
80107c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c24:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c28:	0f b6 c0             	movzbl %al,%eax
80107c2b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c2e:	eb 2f                	jmp    80107c5f <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c33:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c39:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c3d:	0f b6 c0             	movzbl %al,%eax
80107c40:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c43:	eb 1a                	jmp    80107c5f <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c48:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107c4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c4e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c52:	0f b6 c0             	movzbl %al,%eax
80107c55:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c58:	eb 05                	jmp    80107c5f <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107c5a:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107c5e:	90                   	nop
  while(i<madt->len){
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	8b 40 04             	mov    0x4(%eax),%eax
80107c65:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107c68:	0f 82 34 ff ff ff    	jb     80107ba2 <mpinit_uefi+0x3d>
    }
  }

}
80107c6e:	90                   	nop
80107c6f:	90                   	nop
80107c70:	c9                   	leave  
80107c71:	c3                   	ret    

80107c72 <inb>:
{
80107c72:	55                   	push   %ebp
80107c73:	89 e5                	mov    %esp,%ebp
80107c75:	83 ec 14             	sub    $0x14,%esp
80107c78:	8b 45 08             	mov    0x8(%ebp),%eax
80107c7b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107c7f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107c83:	89 c2                	mov    %eax,%edx
80107c85:	ec                   	in     (%dx),%al
80107c86:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107c89:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107c8d:	c9                   	leave  
80107c8e:	c3                   	ret    

80107c8f <outb>:
{
80107c8f:	55                   	push   %ebp
80107c90:	89 e5                	mov    %esp,%ebp
80107c92:	83 ec 08             	sub    $0x8,%esp
80107c95:	8b 45 08             	mov    0x8(%ebp),%eax
80107c98:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c9b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107c9f:	89 d0                	mov    %edx,%eax
80107ca1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107ca4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107ca8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107cac:	ee                   	out    %al,(%dx)
}
80107cad:	90                   	nop
80107cae:	c9                   	leave  
80107caf:	c3                   	ret    

80107cb0 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107cb0:	55                   	push   %ebp
80107cb1:	89 e5                	mov    %esp,%ebp
80107cb3:	83 ec 28             	sub    $0x28,%esp
80107cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb9:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107cbc:	6a 00                	push   $0x0
80107cbe:	68 fa 03 00 00       	push   $0x3fa
80107cc3:	e8 c7 ff ff ff       	call   80107c8f <outb>
80107cc8:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107ccb:	68 80 00 00 00       	push   $0x80
80107cd0:	68 fb 03 00 00       	push   $0x3fb
80107cd5:	e8 b5 ff ff ff       	call   80107c8f <outb>
80107cda:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107cdd:	6a 0c                	push   $0xc
80107cdf:	68 f8 03 00 00       	push   $0x3f8
80107ce4:	e8 a6 ff ff ff       	call   80107c8f <outb>
80107ce9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107cec:	6a 00                	push   $0x0
80107cee:	68 f9 03 00 00       	push   $0x3f9
80107cf3:	e8 97 ff ff ff       	call   80107c8f <outb>
80107cf8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107cfb:	6a 03                	push   $0x3
80107cfd:	68 fb 03 00 00       	push   $0x3fb
80107d02:	e8 88 ff ff ff       	call   80107c8f <outb>
80107d07:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107d0a:	6a 00                	push   $0x0
80107d0c:	68 fc 03 00 00       	push   $0x3fc
80107d11:	e8 79 ff ff ff       	call   80107c8f <outb>
80107d16:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107d19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d20:	eb 11                	jmp    80107d33 <uart_debug+0x83>
80107d22:	83 ec 0c             	sub    $0xc,%esp
80107d25:	6a 0a                	push   $0xa
80107d27:	e8 0b ae ff ff       	call   80102b37 <microdelay>
80107d2c:	83 c4 10             	add    $0x10,%esp
80107d2f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d33:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d37:	7f 1a                	jg     80107d53 <uart_debug+0xa3>
80107d39:	83 ec 0c             	sub    $0xc,%esp
80107d3c:	68 fd 03 00 00       	push   $0x3fd
80107d41:	e8 2c ff ff ff       	call   80107c72 <inb>
80107d46:	83 c4 10             	add    $0x10,%esp
80107d49:	0f b6 c0             	movzbl %al,%eax
80107d4c:	83 e0 20             	and    $0x20,%eax
80107d4f:	85 c0                	test   %eax,%eax
80107d51:	74 cf                	je     80107d22 <uart_debug+0x72>
  outb(COM1+0, p);
80107d53:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107d57:	0f b6 c0             	movzbl %al,%eax
80107d5a:	83 ec 08             	sub    $0x8,%esp
80107d5d:	50                   	push   %eax
80107d5e:	68 f8 03 00 00       	push   $0x3f8
80107d63:	e8 27 ff ff ff       	call   80107c8f <outb>
80107d68:	83 c4 10             	add    $0x10,%esp
}
80107d6b:	90                   	nop
80107d6c:	c9                   	leave  
80107d6d:	c3                   	ret    

80107d6e <uart_debugs>:

void uart_debugs(char *p){
80107d6e:	55                   	push   %ebp
80107d6f:	89 e5                	mov    %esp,%ebp
80107d71:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107d74:	eb 1b                	jmp    80107d91 <uart_debugs+0x23>
    uart_debug(*p++);
80107d76:	8b 45 08             	mov    0x8(%ebp),%eax
80107d79:	8d 50 01             	lea    0x1(%eax),%edx
80107d7c:	89 55 08             	mov    %edx,0x8(%ebp)
80107d7f:	0f b6 00             	movzbl (%eax),%eax
80107d82:	0f be c0             	movsbl %al,%eax
80107d85:	83 ec 0c             	sub    $0xc,%esp
80107d88:	50                   	push   %eax
80107d89:	e8 22 ff ff ff       	call   80107cb0 <uart_debug>
80107d8e:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107d91:	8b 45 08             	mov    0x8(%ebp),%eax
80107d94:	0f b6 00             	movzbl (%eax),%eax
80107d97:	84 c0                	test   %al,%al
80107d99:	75 db                	jne    80107d76 <uart_debugs+0x8>
  }
}
80107d9b:	90                   	nop
80107d9c:	90                   	nop
80107d9d:	c9                   	leave  
80107d9e:	c3                   	ret    

80107d9f <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107d9f:	55                   	push   %ebp
80107da0:	89 e5                	mov    %esp,%ebp
80107da2:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107da5:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107dac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107daf:	8b 50 14             	mov    0x14(%eax),%edx
80107db2:	8b 40 10             	mov    0x10(%eax),%eax
80107db5:	a3 48 6f 19 80       	mov    %eax,0x80196f48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107dba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dbd:	8b 50 1c             	mov    0x1c(%eax),%edx
80107dc0:	8b 40 18             	mov    0x18(%eax),%eax
80107dc3:	a3 50 6f 19 80       	mov    %eax,0x80196f50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107dc8:	8b 15 50 6f 19 80    	mov    0x80196f50,%edx
80107dce:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107dd3:	29 d0                	sub    %edx,%eax
80107dd5:	a3 4c 6f 19 80       	mov    %eax,0x80196f4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ddd:	8b 50 24             	mov    0x24(%eax),%edx
80107de0:	8b 40 20             	mov    0x20(%eax),%eax
80107de3:	a3 54 6f 19 80       	mov    %eax,0x80196f54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107de8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107deb:	8b 50 2c             	mov    0x2c(%eax),%edx
80107dee:	8b 40 28             	mov    0x28(%eax),%eax
80107df1:	a3 58 6f 19 80       	mov    %eax,0x80196f58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107df6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107df9:	8b 50 34             	mov    0x34(%eax),%edx
80107dfc:	8b 40 30             	mov    0x30(%eax),%eax
80107dff:	a3 5c 6f 19 80       	mov    %eax,0x80196f5c
}
80107e04:	90                   	nop
80107e05:	c9                   	leave  
80107e06:	c3                   	ret    

80107e07 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107e07:	55                   	push   %ebp
80107e08:	89 e5                	mov    %esp,%ebp
80107e0a:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107e0d:	8b 15 5c 6f 19 80    	mov    0x80196f5c,%edx
80107e13:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e16:	0f af d0             	imul   %eax,%edx
80107e19:	8b 45 08             	mov    0x8(%ebp),%eax
80107e1c:	01 d0                	add    %edx,%eax
80107e1e:	c1 e0 02             	shl    $0x2,%eax
80107e21:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107e24:	8b 15 4c 6f 19 80    	mov    0x80196f4c,%edx
80107e2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e2d:	01 d0                	add    %edx,%eax
80107e2f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107e32:	8b 45 10             	mov    0x10(%ebp),%eax
80107e35:	0f b6 10             	movzbl (%eax),%edx
80107e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e3b:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107e3d:	8b 45 10             	mov    0x10(%ebp),%eax
80107e40:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107e44:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e47:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107e4a:	8b 45 10             	mov    0x10(%ebp),%eax
80107e4d:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107e51:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e54:	88 50 02             	mov    %dl,0x2(%eax)
}
80107e57:	90                   	nop
80107e58:	c9                   	leave  
80107e59:	c3                   	ret    

80107e5a <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107e5a:	55                   	push   %ebp
80107e5b:	89 e5                	mov    %esp,%ebp
80107e5d:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107e60:	8b 15 5c 6f 19 80    	mov    0x80196f5c,%edx
80107e66:	8b 45 08             	mov    0x8(%ebp),%eax
80107e69:	0f af c2             	imul   %edx,%eax
80107e6c:	c1 e0 02             	shl    $0x2,%eax
80107e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107e72:	a1 50 6f 19 80       	mov    0x80196f50,%eax
80107e77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e7a:	29 d0                	sub    %edx,%eax
80107e7c:	8b 0d 4c 6f 19 80    	mov    0x80196f4c,%ecx
80107e82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e85:	01 ca                	add    %ecx,%edx
80107e87:	89 d1                	mov    %edx,%ecx
80107e89:	8b 15 4c 6f 19 80    	mov    0x80196f4c,%edx
80107e8f:	83 ec 04             	sub    $0x4,%esp
80107e92:	50                   	push   %eax
80107e93:	51                   	push   %ecx
80107e94:	52                   	push   %edx
80107e95:	e8 ae cb ff ff       	call   80104a48 <memmove>
80107e9a:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	8b 0d 4c 6f 19 80    	mov    0x80196f4c,%ecx
80107ea6:	8b 15 50 6f 19 80    	mov    0x80196f50,%edx
80107eac:	01 ca                	add    %ecx,%edx
80107eae:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107eb1:	29 ca                	sub    %ecx,%edx
80107eb3:	83 ec 04             	sub    $0x4,%esp
80107eb6:	50                   	push   %eax
80107eb7:	6a 00                	push   $0x0
80107eb9:	52                   	push   %edx
80107eba:	e8 ca ca ff ff       	call   80104989 <memset>
80107ebf:	83 c4 10             	add    $0x10,%esp
}
80107ec2:	90                   	nop
80107ec3:	c9                   	leave  
80107ec4:	c3                   	ret    

80107ec5 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107ec5:	55                   	push   %ebp
80107ec6:	89 e5                	mov    %esp,%ebp
80107ec8:	53                   	push   %ebx
80107ec9:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107ecc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ed3:	e9 b1 00 00 00       	jmp    80107f89 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107ed8:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107edf:	e9 97 00 00 00       	jmp    80107f7b <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107ee4:	8b 45 10             	mov    0x10(%ebp),%eax
80107ee7:	83 e8 20             	sub    $0x20,%eax
80107eea:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef0:	01 d0                	add    %edx,%eax
80107ef2:	0f b7 84 00 c0 a6 10 	movzwl -0x7fef5940(%eax,%eax,1),%eax
80107ef9:	80 
80107efa:	0f b7 d0             	movzwl %ax,%edx
80107efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f00:	bb 01 00 00 00       	mov    $0x1,%ebx
80107f05:	89 c1                	mov    %eax,%ecx
80107f07:	d3 e3                	shl    %cl,%ebx
80107f09:	89 d8                	mov    %ebx,%eax
80107f0b:	21 d0                	and    %edx,%eax
80107f0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f13:	ba 01 00 00 00       	mov    $0x1,%edx
80107f18:	89 c1                	mov    %eax,%ecx
80107f1a:	d3 e2                	shl    %cl,%edx
80107f1c:	89 d0                	mov    %edx,%eax
80107f1e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107f21:	75 2b                	jne    80107f4e <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107f23:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f29:	01 c2                	add    %eax,%edx
80107f2b:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f30:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f33:	89 c1                	mov    %eax,%ecx
80107f35:	8b 45 08             	mov    0x8(%ebp),%eax
80107f38:	01 c8                	add    %ecx,%eax
80107f3a:	83 ec 04             	sub    $0x4,%esp
80107f3d:	68 00 f5 10 80       	push   $0x8010f500
80107f42:	52                   	push   %edx
80107f43:	50                   	push   %eax
80107f44:	e8 be fe ff ff       	call   80107e07 <graphic_draw_pixel>
80107f49:	83 c4 10             	add    $0x10,%esp
80107f4c:	eb 29                	jmp    80107f77 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f54:	01 c2                	add    %eax,%edx
80107f56:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f5b:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f5e:	89 c1                	mov    %eax,%ecx
80107f60:	8b 45 08             	mov    0x8(%ebp),%eax
80107f63:	01 c8                	add    %ecx,%eax
80107f65:	83 ec 04             	sub    $0x4,%esp
80107f68:	68 60 6f 19 80       	push   $0x80196f60
80107f6d:	52                   	push   %edx
80107f6e:	50                   	push   %eax
80107f6f:	e8 93 fe ff ff       	call   80107e07 <graphic_draw_pixel>
80107f74:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107f77:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107f7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f7f:	0f 89 5f ff ff ff    	jns    80107ee4 <font_render+0x1f>
  for(int i=0;i<30;i++){
80107f85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f89:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107f8d:	0f 8e 45 ff ff ff    	jle    80107ed8 <font_render+0x13>
      }
    }
  }
}
80107f93:	90                   	nop
80107f94:	90                   	nop
80107f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f98:	c9                   	leave  
80107f99:	c3                   	ret    

80107f9a <font_render_string>:

void font_render_string(char *string,int row){
80107f9a:	55                   	push   %ebp
80107f9b:	89 e5                	mov    %esp,%ebp
80107f9d:	53                   	push   %ebx
80107f9e:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80107fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80107fa8:	eb 33                	jmp    80107fdd <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80107faa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fad:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb0:	01 d0                	add    %edx,%eax
80107fb2:	0f b6 00             	movzbl (%eax),%eax
80107fb5:	0f be c8             	movsbl %al,%ecx
80107fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fbb:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107fbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107fc1:	89 d8                	mov    %ebx,%eax
80107fc3:	c1 e0 04             	shl    $0x4,%eax
80107fc6:	29 d8                	sub    %ebx,%eax
80107fc8:	83 c0 02             	add    $0x2,%eax
80107fcb:	83 ec 04             	sub    $0x4,%esp
80107fce:	51                   	push   %ecx
80107fcf:	52                   	push   %edx
80107fd0:	50                   	push   %eax
80107fd1:	e8 ef fe ff ff       	call   80107ec5 <font_render>
80107fd6:	83 c4 10             	add    $0x10,%esp
    i++;
80107fd9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80107fdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe3:	01 d0                	add    %edx,%eax
80107fe5:	0f b6 00             	movzbl (%eax),%eax
80107fe8:	84 c0                	test   %al,%al
80107fea:	74 06                	je     80107ff2 <font_render_string+0x58>
80107fec:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80107ff0:	7e b8                	jle    80107faa <font_render_string+0x10>
  }
}
80107ff2:	90                   	nop
80107ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ff6:	c9                   	leave  
80107ff7:	c3                   	ret    

80107ff8 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80107ff8:	55                   	push   %ebp
80107ff9:	89 e5                	mov    %esp,%ebp
80107ffb:	53                   	push   %ebx
80107ffc:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80107fff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108006:	eb 6b                	jmp    80108073 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108008:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010800f:	eb 58                	jmp    80108069 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108011:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108018:	eb 45                	jmp    8010805f <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010801a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010801d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108023:	83 ec 0c             	sub    $0xc,%esp
80108026:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108029:	53                   	push   %ebx
8010802a:	6a 00                	push   $0x0
8010802c:	51                   	push   %ecx
8010802d:	52                   	push   %edx
8010802e:	50                   	push   %eax
8010802f:	e8 b0 00 00 00       	call   801080e4 <pci_access_config>
80108034:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108037:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010803a:	0f b7 c0             	movzwl %ax,%eax
8010803d:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108042:	74 17                	je     8010805b <pci_init+0x63>
        pci_init_device(i,j,k);
80108044:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108047:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	83 ec 04             	sub    $0x4,%esp
80108050:	51                   	push   %ecx
80108051:	52                   	push   %edx
80108052:	50                   	push   %eax
80108053:	e8 37 01 00 00       	call   8010818f <pci_init_device>
80108058:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010805b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010805f:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108063:	7e b5                	jle    8010801a <pci_init+0x22>
    for(int j=0;j<32;j++){
80108065:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108069:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010806d:	7e a2                	jle    80108011 <pci_init+0x19>
  for(int i=0;i<256;i++){
8010806f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108073:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010807a:	7e 8c                	jle    80108008 <pci_init+0x10>
      }
      }
    }
  }
}
8010807c:	90                   	nop
8010807d:	90                   	nop
8010807e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108081:	c9                   	leave  
80108082:	c3                   	ret    

80108083 <pci_write_config>:

void pci_write_config(uint config){
80108083:	55                   	push   %ebp
80108084:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108086:	8b 45 08             	mov    0x8(%ebp),%eax
80108089:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010808e:	89 c0                	mov    %eax,%eax
80108090:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108091:	90                   	nop
80108092:	5d                   	pop    %ebp
80108093:	c3                   	ret    

80108094 <pci_write_data>:

void pci_write_data(uint config){
80108094:	55                   	push   %ebp
80108095:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108097:	8b 45 08             	mov    0x8(%ebp),%eax
8010809a:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010809f:	89 c0                	mov    %eax,%eax
801080a1:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080a2:	90                   	nop
801080a3:	5d                   	pop    %ebp
801080a4:	c3                   	ret    

801080a5 <pci_read_config>:
uint pci_read_config(){
801080a5:	55                   	push   %ebp
801080a6:	89 e5                	mov    %esp,%ebp
801080a8:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801080ab:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080b0:	ed                   	in     (%dx),%eax
801080b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801080b4:	83 ec 0c             	sub    $0xc,%esp
801080b7:	68 c8 00 00 00       	push   $0xc8
801080bc:	e8 76 aa ff ff       	call   80102b37 <microdelay>
801080c1:	83 c4 10             	add    $0x10,%esp
  return data;
801080c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801080c7:	c9                   	leave  
801080c8:	c3                   	ret    

801080c9 <pci_test>:


void pci_test(){
801080c9:	55                   	push   %ebp
801080ca:	89 e5                	mov    %esp,%ebp
801080cc:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801080cf:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801080d6:	ff 75 fc             	push   -0x4(%ebp)
801080d9:	e8 a5 ff ff ff       	call   80108083 <pci_write_config>
801080de:	83 c4 04             	add    $0x4,%esp
}
801080e1:	90                   	nop
801080e2:	c9                   	leave  
801080e3:	c3                   	ret    

801080e4 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801080e4:	55                   	push   %ebp
801080e5:	89 e5                	mov    %esp,%ebp
801080e7:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801080ea:	8b 45 08             	mov    0x8(%ebp),%eax
801080ed:	c1 e0 10             	shl    $0x10,%eax
801080f0:	25 00 00 ff 00       	and    $0xff0000,%eax
801080f5:	89 c2                	mov    %eax,%edx
801080f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801080fa:	c1 e0 0b             	shl    $0xb,%eax
801080fd:	0f b7 c0             	movzwl %ax,%eax
80108100:	09 c2                	or     %eax,%edx
80108102:	8b 45 10             	mov    0x10(%ebp),%eax
80108105:	c1 e0 08             	shl    $0x8,%eax
80108108:	25 00 07 00 00       	and    $0x700,%eax
8010810d:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010810f:	8b 45 14             	mov    0x14(%ebp),%eax
80108112:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108117:	09 d0                	or     %edx,%eax
80108119:	0d 00 00 00 80       	or     $0x80000000,%eax
8010811e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108121:	ff 75 f4             	push   -0xc(%ebp)
80108124:	e8 5a ff ff ff       	call   80108083 <pci_write_config>
80108129:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010812c:	e8 74 ff ff ff       	call   801080a5 <pci_read_config>
80108131:	8b 55 18             	mov    0x18(%ebp),%edx
80108134:	89 02                	mov    %eax,(%edx)
}
80108136:	90                   	nop
80108137:	c9                   	leave  
80108138:	c3                   	ret    

80108139 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108139:	55                   	push   %ebp
8010813a:	89 e5                	mov    %esp,%ebp
8010813c:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010813f:	8b 45 08             	mov    0x8(%ebp),%eax
80108142:	c1 e0 10             	shl    $0x10,%eax
80108145:	25 00 00 ff 00       	and    $0xff0000,%eax
8010814a:	89 c2                	mov    %eax,%edx
8010814c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010814f:	c1 e0 0b             	shl    $0xb,%eax
80108152:	0f b7 c0             	movzwl %ax,%eax
80108155:	09 c2                	or     %eax,%edx
80108157:	8b 45 10             	mov    0x10(%ebp),%eax
8010815a:	c1 e0 08             	shl    $0x8,%eax
8010815d:	25 00 07 00 00       	and    $0x700,%eax
80108162:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108164:	8b 45 14             	mov    0x14(%ebp),%eax
80108167:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010816c:	09 d0                	or     %edx,%eax
8010816e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108173:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108176:	ff 75 fc             	push   -0x4(%ebp)
80108179:	e8 05 ff ff ff       	call   80108083 <pci_write_config>
8010817e:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108181:	ff 75 18             	push   0x18(%ebp)
80108184:	e8 0b ff ff ff       	call   80108094 <pci_write_data>
80108189:	83 c4 04             	add    $0x4,%esp
}
8010818c:	90                   	nop
8010818d:	c9                   	leave  
8010818e:	c3                   	ret    

8010818f <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010818f:	55                   	push   %ebp
80108190:	89 e5                	mov    %esp,%ebp
80108192:	53                   	push   %ebx
80108193:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108196:	8b 45 08             	mov    0x8(%ebp),%eax
80108199:	a2 64 6f 19 80       	mov    %al,0x80196f64
  dev.device_num = device_num;
8010819e:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a1:	a2 65 6f 19 80       	mov    %al,0x80196f65
  dev.function_num = function_num;
801081a6:	8b 45 10             	mov    0x10(%ebp),%eax
801081a9:	a2 66 6f 19 80       	mov    %al,0x80196f66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801081ae:	ff 75 10             	push   0x10(%ebp)
801081b1:	ff 75 0c             	push   0xc(%ebp)
801081b4:	ff 75 08             	push   0x8(%ebp)
801081b7:	68 04 bd 10 80       	push   $0x8010bd04
801081bc:	e8 33 82 ff ff       	call   801003f4 <cprintf>
801081c1:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801081c4:	83 ec 0c             	sub    $0xc,%esp
801081c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801081ca:	50                   	push   %eax
801081cb:	6a 00                	push   $0x0
801081cd:	ff 75 10             	push   0x10(%ebp)
801081d0:	ff 75 0c             	push   0xc(%ebp)
801081d3:	ff 75 08             	push   0x8(%ebp)
801081d6:	e8 09 ff ff ff       	call   801080e4 <pci_access_config>
801081db:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801081de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081e1:	c1 e8 10             	shr    $0x10,%eax
801081e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801081e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ea:	25 ff ff 00 00       	and    $0xffff,%eax
801081ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f5:	a3 68 6f 19 80       	mov    %eax,0x80196f68
  dev.vendor_id = vendor_id;
801081fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fd:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108202:	83 ec 04             	sub    $0x4,%esp
80108205:	ff 75 f0             	push   -0x10(%ebp)
80108208:	ff 75 f4             	push   -0xc(%ebp)
8010820b:	68 38 bd 10 80       	push   $0x8010bd38
80108210:	e8 df 81 ff ff       	call   801003f4 <cprintf>
80108215:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108218:	83 ec 0c             	sub    $0xc,%esp
8010821b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010821e:	50                   	push   %eax
8010821f:	6a 08                	push   $0x8
80108221:	ff 75 10             	push   0x10(%ebp)
80108224:	ff 75 0c             	push   0xc(%ebp)
80108227:	ff 75 08             	push   0x8(%ebp)
8010822a:	e8 b5 fe ff ff       	call   801080e4 <pci_access_config>
8010822f:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108232:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108235:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108238:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010823b:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010823e:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108241:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108244:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108247:	0f b6 c0             	movzbl %al,%eax
8010824a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010824d:	c1 eb 18             	shr    $0x18,%ebx
80108250:	83 ec 0c             	sub    $0xc,%esp
80108253:	51                   	push   %ecx
80108254:	52                   	push   %edx
80108255:	50                   	push   %eax
80108256:	53                   	push   %ebx
80108257:	68 5c bd 10 80       	push   $0x8010bd5c
8010825c:	e8 93 81 ff ff       	call   801003f4 <cprintf>
80108261:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108264:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108267:	c1 e8 18             	shr    $0x18,%eax
8010826a:	a2 70 6f 19 80       	mov    %al,0x80196f70
  dev.sub_class = (data>>16)&0xFF;
8010826f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108272:	c1 e8 10             	shr    $0x10,%eax
80108275:	a2 71 6f 19 80       	mov    %al,0x80196f71
  dev.interface = (data>>8)&0xFF;
8010827a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010827d:	c1 e8 08             	shr    $0x8,%eax
80108280:	a2 72 6f 19 80       	mov    %al,0x80196f72
  dev.revision_id = data&0xFF;
80108285:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108288:	a2 73 6f 19 80       	mov    %al,0x80196f73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010828d:	83 ec 0c             	sub    $0xc,%esp
80108290:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108293:	50                   	push   %eax
80108294:	6a 10                	push   $0x10
80108296:	ff 75 10             	push   0x10(%ebp)
80108299:	ff 75 0c             	push   0xc(%ebp)
8010829c:	ff 75 08             	push   0x8(%ebp)
8010829f:	e8 40 fe ff ff       	call   801080e4 <pci_access_config>
801082a4:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801082a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082aa:	a3 74 6f 19 80       	mov    %eax,0x80196f74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801082af:	83 ec 0c             	sub    $0xc,%esp
801082b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082b5:	50                   	push   %eax
801082b6:	6a 14                	push   $0x14
801082b8:	ff 75 10             	push   0x10(%ebp)
801082bb:	ff 75 0c             	push   0xc(%ebp)
801082be:	ff 75 08             	push   0x8(%ebp)
801082c1:	e8 1e fe ff ff       	call   801080e4 <pci_access_config>
801082c6:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801082c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082cc:	a3 78 6f 19 80       	mov    %eax,0x80196f78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801082d1:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801082d8:	75 5a                	jne    80108334 <pci_init_device+0x1a5>
801082da:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801082e1:	75 51                	jne    80108334 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801082e3:	83 ec 0c             	sub    $0xc,%esp
801082e6:	68 a1 bd 10 80       	push   $0x8010bda1
801082eb:	e8 04 81 ff ff       	call   801003f4 <cprintf>
801082f0:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801082f3:	83 ec 0c             	sub    $0xc,%esp
801082f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082f9:	50                   	push   %eax
801082fa:	68 f0 00 00 00       	push   $0xf0
801082ff:	ff 75 10             	push   0x10(%ebp)
80108302:	ff 75 0c             	push   0xc(%ebp)
80108305:	ff 75 08             	push   0x8(%ebp)
80108308:	e8 d7 fd ff ff       	call   801080e4 <pci_access_config>
8010830d:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108310:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108313:	83 ec 08             	sub    $0x8,%esp
80108316:	50                   	push   %eax
80108317:	68 bb bd 10 80       	push   $0x8010bdbb
8010831c:	e8 d3 80 ff ff       	call   801003f4 <cprintf>
80108321:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108324:	83 ec 0c             	sub    $0xc,%esp
80108327:	68 64 6f 19 80       	push   $0x80196f64
8010832c:	e8 09 00 00 00       	call   8010833a <i8254_init>
80108331:	83 c4 10             	add    $0x10,%esp
  }
}
80108334:	90                   	nop
80108335:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108338:	c9                   	leave  
80108339:	c3                   	ret    

8010833a <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010833a:	55                   	push   %ebp
8010833b:	89 e5                	mov    %esp,%ebp
8010833d:	53                   	push   %ebx
8010833e:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108341:	8b 45 08             	mov    0x8(%ebp),%eax
80108344:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108348:	0f b6 c8             	movzbl %al,%ecx
8010834b:	8b 45 08             	mov    0x8(%ebp),%eax
8010834e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108352:	0f b6 d0             	movzbl %al,%edx
80108355:	8b 45 08             	mov    0x8(%ebp),%eax
80108358:	0f b6 00             	movzbl (%eax),%eax
8010835b:	0f b6 c0             	movzbl %al,%eax
8010835e:	83 ec 0c             	sub    $0xc,%esp
80108361:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108364:	53                   	push   %ebx
80108365:	6a 04                	push   $0x4
80108367:	51                   	push   %ecx
80108368:	52                   	push   %edx
80108369:	50                   	push   %eax
8010836a:	e8 75 fd ff ff       	call   801080e4 <pci_access_config>
8010836f:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108372:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108375:	83 c8 04             	or     $0x4,%eax
80108378:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010837b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010837e:	8b 45 08             	mov    0x8(%ebp),%eax
80108381:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108385:	0f b6 c8             	movzbl %al,%ecx
80108388:	8b 45 08             	mov    0x8(%ebp),%eax
8010838b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010838f:	0f b6 d0             	movzbl %al,%edx
80108392:	8b 45 08             	mov    0x8(%ebp),%eax
80108395:	0f b6 00             	movzbl (%eax),%eax
80108398:	0f b6 c0             	movzbl %al,%eax
8010839b:	83 ec 0c             	sub    $0xc,%esp
8010839e:	53                   	push   %ebx
8010839f:	6a 04                	push   $0x4
801083a1:	51                   	push   %ecx
801083a2:	52                   	push   %edx
801083a3:	50                   	push   %eax
801083a4:	e8 90 fd ff ff       	call   80108139 <pci_write_config_register>
801083a9:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801083ac:	8b 45 08             	mov    0x8(%ebp),%eax
801083af:	8b 40 10             	mov    0x10(%eax),%eax
801083b2:	05 00 00 00 40       	add    $0x40000000,%eax
801083b7:	a3 7c 6f 19 80       	mov    %eax,0x80196f7c
  uint *ctrl = (uint *)base_addr;
801083bc:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801083c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801083c4:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801083c9:	05 d8 00 00 00       	add    $0xd8,%eax
801083ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801083d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d4:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801083da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dd:	8b 00                	mov    (%eax),%eax
801083df:	0d 00 00 00 04       	or     $0x4000000,%eax
801083e4:	89 c2                	mov    %eax,%edx
801083e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e9:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801083eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ee:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801083f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f7:	8b 00                	mov    (%eax),%eax
801083f9:	83 c8 40             	or     $0x40,%eax
801083fc:	89 c2                	mov    %eax,%edx
801083fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108401:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108406:	8b 10                	mov    (%eax),%edx
80108408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840b:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
8010840d:	83 ec 0c             	sub    $0xc,%esp
80108410:	68 d0 bd 10 80       	push   $0x8010bdd0
80108415:	e8 da 7f ff ff       	call   801003f4 <cprintf>
8010841a:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010841d:	e8 7e a3 ff ff       	call   801027a0 <kalloc>
80108422:	a3 88 6f 19 80       	mov    %eax,0x80196f88
  *intr_addr = 0;
80108427:	a1 88 6f 19 80       	mov    0x80196f88,%eax
8010842c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108432:	a1 88 6f 19 80       	mov    0x80196f88,%eax
80108437:	83 ec 08             	sub    $0x8,%esp
8010843a:	50                   	push   %eax
8010843b:	68 f2 bd 10 80       	push   $0x8010bdf2
80108440:	e8 af 7f ff ff       	call   801003f4 <cprintf>
80108445:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108448:	e8 50 00 00 00       	call   8010849d <i8254_init_recv>
  i8254_init_send();
8010844d:	e8 69 03 00 00       	call   801087bb <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108452:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108459:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010845c:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108463:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108466:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010846d:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108470:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108477:	0f b6 c0             	movzbl %al,%eax
8010847a:	83 ec 0c             	sub    $0xc,%esp
8010847d:	53                   	push   %ebx
8010847e:	51                   	push   %ecx
8010847f:	52                   	push   %edx
80108480:	50                   	push   %eax
80108481:	68 00 be 10 80       	push   $0x8010be00
80108486:	e8 69 7f ff ff       	call   801003f4 <cprintf>
8010848b:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010848e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108491:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108497:	90                   	nop
80108498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010849b:	c9                   	leave  
8010849c:	c3                   	ret    

8010849d <i8254_init_recv>:

void i8254_init_recv(){
8010849d:	55                   	push   %ebp
8010849e:	89 e5                	mov    %esp,%ebp
801084a0:	57                   	push   %edi
801084a1:	56                   	push   %esi
801084a2:	53                   	push   %ebx
801084a3:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801084a6:	83 ec 0c             	sub    $0xc,%esp
801084a9:	6a 00                	push   $0x0
801084ab:	e8 e8 04 00 00       	call   80108998 <i8254_read_eeprom>
801084b0:	83 c4 10             	add    $0x10,%esp
801084b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801084b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084b9:	a2 80 6f 19 80       	mov    %al,0x80196f80
  mac_addr[1] = data_l>>8;
801084be:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084c1:	c1 e8 08             	shr    $0x8,%eax
801084c4:	a2 81 6f 19 80       	mov    %al,0x80196f81
  uint data_m = i8254_read_eeprom(0x1);
801084c9:	83 ec 0c             	sub    $0xc,%esp
801084cc:	6a 01                	push   $0x1
801084ce:	e8 c5 04 00 00       	call   80108998 <i8254_read_eeprom>
801084d3:	83 c4 10             	add    $0x10,%esp
801084d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801084d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084dc:	a2 82 6f 19 80       	mov    %al,0x80196f82
  mac_addr[3] = data_m>>8;
801084e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084e4:	c1 e8 08             	shr    $0x8,%eax
801084e7:	a2 83 6f 19 80       	mov    %al,0x80196f83
  uint data_h = i8254_read_eeprom(0x2);
801084ec:	83 ec 0c             	sub    $0xc,%esp
801084ef:	6a 02                	push   $0x2
801084f1:	e8 a2 04 00 00       	call   80108998 <i8254_read_eeprom>
801084f6:	83 c4 10             	add    $0x10,%esp
801084f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801084fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801084ff:	a2 84 6f 19 80       	mov    %al,0x80196f84
  mac_addr[5] = data_h>>8;
80108504:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108507:	c1 e8 08             	shr    $0x8,%eax
8010850a:	a2 85 6f 19 80       	mov    %al,0x80196f85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010850f:	0f b6 05 85 6f 19 80 	movzbl 0x80196f85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108516:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108519:	0f b6 05 84 6f 19 80 	movzbl 0x80196f84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108520:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108523:	0f b6 05 83 6f 19 80 	movzbl 0x80196f83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010852a:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010852d:	0f b6 05 82 6f 19 80 	movzbl 0x80196f82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108534:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108537:	0f b6 05 81 6f 19 80 	movzbl 0x80196f81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010853e:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108541:	0f b6 05 80 6f 19 80 	movzbl 0x80196f80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108548:	0f b6 c0             	movzbl %al,%eax
8010854b:	83 ec 04             	sub    $0x4,%esp
8010854e:	57                   	push   %edi
8010854f:	56                   	push   %esi
80108550:	53                   	push   %ebx
80108551:	51                   	push   %ecx
80108552:	52                   	push   %edx
80108553:	50                   	push   %eax
80108554:	68 18 be 10 80       	push   $0x8010be18
80108559:	e8 96 7e ff ff       	call   801003f4 <cprintf>
8010855e:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108561:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108566:	05 00 54 00 00       	add    $0x5400,%eax
8010856b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010856e:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108573:	05 04 54 00 00       	add    $0x5404,%eax
80108578:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010857b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010857e:	c1 e0 10             	shl    $0x10,%eax
80108581:	0b 45 d8             	or     -0x28(%ebp),%eax
80108584:	89 c2                	mov    %eax,%edx
80108586:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108589:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010858b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010858e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108593:	89 c2                	mov    %eax,%edx
80108595:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108598:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010859a:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
8010859f:	05 00 52 00 00       	add    $0x5200,%eax
801085a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801085a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801085ae:	eb 19                	jmp    801085c9 <i8254_init_recv+0x12c>
    mta[i] = 0;
801085b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085ba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801085bd:	01 d0                	add    %edx,%eax
801085bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801085c5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801085c9:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801085cd:	7e e1                	jle    801085b0 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801085cf:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801085d4:	05 d0 00 00 00       	add    $0xd0,%eax
801085d9:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801085dc:	8b 45 c0             	mov    -0x40(%ebp),%eax
801085df:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801085e5:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801085ea:	05 c8 00 00 00       	add    $0xc8,%eax
801085ef:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801085f2:	8b 45 bc             	mov    -0x44(%ebp),%eax
801085f5:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801085fb:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108600:	05 28 28 00 00       	add    $0x2828,%eax
80108605:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108608:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010860b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108611:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108616:	05 00 01 00 00       	add    $0x100,%eax
8010861b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010861e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108621:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108627:	e8 74 a1 ff ff       	call   801027a0 <kalloc>
8010862c:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010862f:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108634:	05 00 28 00 00       	add    $0x2800,%eax
80108639:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010863c:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108641:	05 04 28 00 00       	add    $0x2804,%eax
80108646:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108649:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
8010864e:	05 08 28 00 00       	add    $0x2808,%eax
80108653:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108656:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
8010865b:	05 10 28 00 00       	add    $0x2810,%eax
80108660:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108663:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108668:	05 18 28 00 00       	add    $0x2818,%eax
8010866d:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108670:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108673:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108679:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010867c:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010867e:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108681:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108687:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010868a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108690:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108693:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108699:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010869c:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801086a2:	8b 45 b0             	mov    -0x50(%ebp),%eax
801086a5:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801086a8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801086af:	eb 73                	jmp    80108724 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801086b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086b4:	c1 e0 04             	shl    $0x4,%eax
801086b7:	89 c2                	mov    %eax,%edx
801086b9:	8b 45 98             	mov    -0x68(%ebp),%eax
801086bc:	01 d0                	add    %edx,%eax
801086be:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801086c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086c8:	c1 e0 04             	shl    $0x4,%eax
801086cb:	89 c2                	mov    %eax,%edx
801086cd:	8b 45 98             	mov    -0x68(%ebp),%eax
801086d0:	01 d0                	add    %edx,%eax
801086d2:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801086d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086db:	c1 e0 04             	shl    $0x4,%eax
801086de:	89 c2                	mov    %eax,%edx
801086e0:	8b 45 98             	mov    -0x68(%ebp),%eax
801086e3:	01 d0                	add    %edx,%eax
801086e5:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801086eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086ee:	c1 e0 04             	shl    $0x4,%eax
801086f1:	89 c2                	mov    %eax,%edx
801086f3:	8b 45 98             	mov    -0x68(%ebp),%eax
801086f6:	01 d0                	add    %edx,%eax
801086f8:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801086fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086ff:	c1 e0 04             	shl    $0x4,%eax
80108702:	89 c2                	mov    %eax,%edx
80108704:	8b 45 98             	mov    -0x68(%ebp),%eax
80108707:	01 d0                	add    %edx,%eax
80108709:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010870d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108710:	c1 e0 04             	shl    $0x4,%eax
80108713:	89 c2                	mov    %eax,%edx
80108715:	8b 45 98             	mov    -0x68(%ebp),%eax
80108718:	01 d0                	add    %edx,%eax
8010871a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108720:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108724:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010872b:	7e 84                	jle    801086b1 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010872d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108734:	eb 57                	jmp    8010878d <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108736:	e8 65 a0 ff ff       	call   801027a0 <kalloc>
8010873b:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010873e:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108742:	75 12                	jne    80108756 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108744:	83 ec 0c             	sub    $0xc,%esp
80108747:	68 38 be 10 80       	push   $0x8010be38
8010874c:	e8 a3 7c ff ff       	call   801003f4 <cprintf>
80108751:	83 c4 10             	add    $0x10,%esp
      break;
80108754:	eb 3d                	jmp    80108793 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108756:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108759:	c1 e0 04             	shl    $0x4,%eax
8010875c:	89 c2                	mov    %eax,%edx
8010875e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108761:	01 d0                	add    %edx,%eax
80108763:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108766:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010876c:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010876e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108771:	83 c0 01             	add    $0x1,%eax
80108774:	c1 e0 04             	shl    $0x4,%eax
80108777:	89 c2                	mov    %eax,%edx
80108779:	8b 45 98             	mov    -0x68(%ebp),%eax
8010877c:	01 d0                	add    %edx,%eax
8010877e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108781:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108787:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108789:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010878d:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108791:	7e a3                	jle    80108736 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108793:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108796:	8b 00                	mov    (%eax),%eax
80108798:	83 c8 02             	or     $0x2,%eax
8010879b:	89 c2                	mov    %eax,%edx
8010879d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087a0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801087a2:	83 ec 0c             	sub    $0xc,%esp
801087a5:	68 58 be 10 80       	push   $0x8010be58
801087aa:	e8 45 7c ff ff       	call   801003f4 <cprintf>
801087af:	83 c4 10             	add    $0x10,%esp
}
801087b2:	90                   	nop
801087b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801087b6:	5b                   	pop    %ebx
801087b7:	5e                   	pop    %esi
801087b8:	5f                   	pop    %edi
801087b9:	5d                   	pop    %ebp
801087ba:	c3                   	ret    

801087bb <i8254_init_send>:

void i8254_init_send(){
801087bb:	55                   	push   %ebp
801087bc:	89 e5                	mov    %esp,%ebp
801087be:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801087c1:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801087c6:	05 28 38 00 00       	add    $0x3828,%eax
801087cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801087ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087d1:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801087d7:	e8 c4 9f ff ff       	call   801027a0 <kalloc>
801087dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801087df:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801087e4:	05 00 38 00 00       	add    $0x3800,%eax
801087e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801087ec:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801087f1:	05 04 38 00 00       	add    $0x3804,%eax
801087f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801087f9:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801087fe:	05 08 38 00 00       	add    $0x3808,%eax
80108803:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108806:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108809:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010880f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108812:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108814:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108817:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010881d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108820:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108826:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
8010882b:	05 10 38 00 00       	add    $0x3810,%eax
80108830:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108833:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108838:	05 18 38 00 00       	add    $0x3818,%eax
8010883d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108840:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108843:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108849:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010884c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108852:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108855:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010885f:	e9 82 00 00 00       	jmp    801088e6 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108867:	c1 e0 04             	shl    $0x4,%eax
8010886a:	89 c2                	mov    %eax,%edx
8010886c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010886f:	01 d0                	add    %edx,%eax
80108871:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887b:	c1 e0 04             	shl    $0x4,%eax
8010887e:	89 c2                	mov    %eax,%edx
80108880:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108883:	01 d0                	add    %edx,%eax
80108885:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010888b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888e:	c1 e0 04             	shl    $0x4,%eax
80108891:	89 c2                	mov    %eax,%edx
80108893:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108896:	01 d0                	add    %edx,%eax
80108898:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010889c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889f:	c1 e0 04             	shl    $0x4,%eax
801088a2:	89 c2                	mov    %eax,%edx
801088a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088a7:	01 d0                	add    %edx,%eax
801088a9:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801088ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b0:	c1 e0 04             	shl    $0x4,%eax
801088b3:	89 c2                	mov    %eax,%edx
801088b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088b8:	01 d0                	add    %edx,%eax
801088ba:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801088be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c1:	c1 e0 04             	shl    $0x4,%eax
801088c4:	89 c2                	mov    %eax,%edx
801088c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088c9:	01 d0                	add    %edx,%eax
801088cb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801088cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d2:	c1 e0 04             	shl    $0x4,%eax
801088d5:	89 c2                	mov    %eax,%edx
801088d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088da:	01 d0                	add    %edx,%eax
801088dc:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801088e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088e6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801088ed:	0f 8e 71 ff ff ff    	jle    80108864 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801088f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801088fa:	eb 57                	jmp    80108953 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801088fc:	e8 9f 9e ff ff       	call   801027a0 <kalloc>
80108901:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108904:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108908:	75 12                	jne    8010891c <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010890a:	83 ec 0c             	sub    $0xc,%esp
8010890d:	68 38 be 10 80       	push   $0x8010be38
80108912:	e8 dd 7a ff ff       	call   801003f4 <cprintf>
80108917:	83 c4 10             	add    $0x10,%esp
      break;
8010891a:	eb 3d                	jmp    80108959 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010891c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891f:	c1 e0 04             	shl    $0x4,%eax
80108922:	89 c2                	mov    %eax,%edx
80108924:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108927:	01 d0                	add    %edx,%eax
80108929:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010892c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108932:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108937:	83 c0 01             	add    $0x1,%eax
8010893a:	c1 e0 04             	shl    $0x4,%eax
8010893d:	89 c2                	mov    %eax,%edx
8010893f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108942:	01 d0                	add    %edx,%eax
80108944:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108947:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010894d:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010894f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108953:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108957:	7e a3                	jle    801088fc <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108959:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
8010895e:	05 00 04 00 00       	add    $0x400,%eax
80108963:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108966:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108969:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010896f:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108974:	05 10 04 00 00       	add    $0x410,%eax
80108979:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010897c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010897f:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108985:	83 ec 0c             	sub    $0xc,%esp
80108988:	68 78 be 10 80       	push   $0x8010be78
8010898d:	e8 62 7a ff ff       	call   801003f4 <cprintf>
80108992:	83 c4 10             	add    $0x10,%esp

}
80108995:	90                   	nop
80108996:	c9                   	leave  
80108997:	c3                   	ret    

80108998 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108998:	55                   	push   %ebp
80108999:	89 e5                	mov    %esp,%ebp
8010899b:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010899e:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801089a3:	83 c0 14             	add    $0x14,%eax
801089a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801089a9:	8b 45 08             	mov    0x8(%ebp),%eax
801089ac:	c1 e0 08             	shl    $0x8,%eax
801089af:	0f b7 c0             	movzwl %ax,%eax
801089b2:	83 c8 01             	or     $0x1,%eax
801089b5:	89 c2                	mov    %eax,%edx
801089b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ba:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801089bc:	83 ec 0c             	sub    $0xc,%esp
801089bf:	68 98 be 10 80       	push   $0x8010be98
801089c4:	e8 2b 7a ff ff       	call   801003f4 <cprintf>
801089c9:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801089cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cf:	8b 00                	mov    (%eax),%eax
801089d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801089d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089d7:	83 e0 10             	and    $0x10,%eax
801089da:	85 c0                	test   %eax,%eax
801089dc:	75 02                	jne    801089e0 <i8254_read_eeprom+0x48>
  while(1){
801089de:	eb dc                	jmp    801089bc <i8254_read_eeprom+0x24>
      break;
801089e0:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801089e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e4:	8b 00                	mov    (%eax),%eax
801089e6:	c1 e8 10             	shr    $0x10,%eax
}
801089e9:	c9                   	leave  
801089ea:	c3                   	ret    

801089eb <i8254_recv>:
void i8254_recv(){
801089eb:	55                   	push   %ebp
801089ec:	89 e5                	mov    %esp,%ebp
801089ee:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801089f1:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
801089f6:	05 10 28 00 00       	add    $0x2810,%eax
801089fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801089fe:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108a03:	05 18 28 00 00       	add    $0x2818,%eax
80108a08:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a0b:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108a10:	05 00 28 00 00       	add    $0x2800,%eax
80108a15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a1b:	8b 00                	mov    (%eax),%eax
80108a1d:	05 00 00 00 80       	add    $0x80000000,%eax
80108a22:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a28:	8b 10                	mov    (%eax),%edx
80108a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2d:	8b 08                	mov    (%eax),%ecx
80108a2f:	89 d0                	mov    %edx,%eax
80108a31:	29 c8                	sub    %ecx,%eax
80108a33:	25 ff 00 00 00       	and    $0xff,%eax
80108a38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108a3b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108a3f:	7e 37                	jle    80108a78 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a44:	8b 00                	mov    (%eax),%eax
80108a46:	c1 e0 04             	shl    $0x4,%eax
80108a49:	89 c2                	mov    %eax,%edx
80108a4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a4e:	01 d0                	add    %edx,%eax
80108a50:	8b 00                	mov    (%eax),%eax
80108a52:	05 00 00 00 80       	add    $0x80000000,%eax
80108a57:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5d:	8b 00                	mov    (%eax),%eax
80108a5f:	83 c0 01             	add    $0x1,%eax
80108a62:	0f b6 d0             	movzbl %al,%edx
80108a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a68:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108a6a:	83 ec 0c             	sub    $0xc,%esp
80108a6d:	ff 75 e0             	push   -0x20(%ebp)
80108a70:	e8 15 09 00 00       	call   8010938a <eth_proc>
80108a75:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a7b:	8b 10                	mov    (%eax),%edx
80108a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a80:	8b 00                	mov    (%eax),%eax
80108a82:	39 c2                	cmp    %eax,%edx
80108a84:	75 9f                	jne    80108a25 <i8254_recv+0x3a>
      (*rdt)--;
80108a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a89:	8b 00                	mov    (%eax),%eax
80108a8b:	8d 50 ff             	lea    -0x1(%eax),%edx
80108a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a91:	89 10                	mov    %edx,(%eax)
  while(1){
80108a93:	eb 90                	jmp    80108a25 <i8254_recv+0x3a>

80108a95 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108a95:	55                   	push   %ebp
80108a96:	89 e5                	mov    %esp,%ebp
80108a98:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108a9b:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108aa0:	05 10 38 00 00       	add    $0x3810,%eax
80108aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108aa8:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108aad:	05 18 38 00 00       	add    $0x3818,%eax
80108ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ab5:	a1 7c 6f 19 80       	mov    0x80196f7c,%eax
80108aba:	05 00 38 00 00       	add    $0x3800,%eax
80108abf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac5:	8b 00                	mov    (%eax),%eax
80108ac7:	05 00 00 00 80       	add    $0x80000000,%eax
80108acc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad2:	8b 10                	mov    (%eax),%edx
80108ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad7:	8b 08                	mov    (%eax),%ecx
80108ad9:	89 d0                	mov    %edx,%eax
80108adb:	29 c8                	sub    %ecx,%eax
80108add:	0f b6 d0             	movzbl %al,%edx
80108ae0:	b8 00 01 00 00       	mov    $0x100,%eax
80108ae5:	29 d0                	sub    %edx,%eax
80108ae7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aed:	8b 00                	mov    (%eax),%eax
80108aef:	25 ff 00 00 00       	and    $0xff,%eax
80108af4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108af7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108afb:	0f 8e a8 00 00 00    	jle    80108ba9 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108b01:	8b 45 08             	mov    0x8(%ebp),%eax
80108b04:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b07:	89 d1                	mov    %edx,%ecx
80108b09:	c1 e1 04             	shl    $0x4,%ecx
80108b0c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108b0f:	01 ca                	add    %ecx,%edx
80108b11:	8b 12                	mov    (%edx),%edx
80108b13:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b19:	83 ec 04             	sub    $0x4,%esp
80108b1c:	ff 75 0c             	push   0xc(%ebp)
80108b1f:	50                   	push   %eax
80108b20:	52                   	push   %edx
80108b21:	e8 22 bf ff ff       	call   80104a48 <memmove>
80108b26:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108b29:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b2c:	c1 e0 04             	shl    $0x4,%eax
80108b2f:	89 c2                	mov    %eax,%edx
80108b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b34:	01 d0                	add    %edx,%eax
80108b36:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b39:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108b3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b40:	c1 e0 04             	shl    $0x4,%eax
80108b43:	89 c2                	mov    %eax,%edx
80108b45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b48:	01 d0                	add    %edx,%eax
80108b4a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108b4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b51:	c1 e0 04             	shl    $0x4,%eax
80108b54:	89 c2                	mov    %eax,%edx
80108b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b59:	01 d0                	add    %edx,%eax
80108b5b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108b5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b62:	c1 e0 04             	shl    $0x4,%eax
80108b65:	89 c2                	mov    %eax,%edx
80108b67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b6a:	01 d0                	add    %edx,%eax
80108b6c:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108b70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b73:	c1 e0 04             	shl    $0x4,%eax
80108b76:	89 c2                	mov    %eax,%edx
80108b78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b7b:	01 d0                	add    %edx,%eax
80108b7d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b86:	c1 e0 04             	shl    $0x4,%eax
80108b89:	89 c2                	mov    %eax,%edx
80108b8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b8e:	01 d0                	add    %edx,%eax
80108b90:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b97:	8b 00                	mov    (%eax),%eax
80108b99:	83 c0 01             	add    $0x1,%eax
80108b9c:	0f b6 d0             	movzbl %al,%edx
80108b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba2:	89 10                	mov    %edx,(%eax)
    return len;
80108ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba7:	eb 05                	jmp    80108bae <i8254_send+0x119>
  }else{
    return -1;
80108ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108bae:	c9                   	leave  
80108baf:	c3                   	ret    

80108bb0 <i8254_intr>:

void i8254_intr(){
80108bb0:	55                   	push   %ebp
80108bb1:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108bb3:	a1 88 6f 19 80       	mov    0x80196f88,%eax
80108bb8:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108bbe:	90                   	nop
80108bbf:	5d                   	pop    %ebp
80108bc0:	c3                   	ret    

80108bc1 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108bc1:	55                   	push   %ebp
80108bc2:	89 e5                	mov    %esp,%ebp
80108bc4:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80108bca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd0:	0f b7 00             	movzwl (%eax),%eax
80108bd3:	66 3d 00 01          	cmp    $0x100,%ax
80108bd7:	74 0a                	je     80108be3 <arp_proc+0x22>
80108bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bde:	e9 4f 01 00 00       	jmp    80108d32 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be6:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108bea:	66 83 f8 08          	cmp    $0x8,%ax
80108bee:	74 0a                	je     80108bfa <arp_proc+0x39>
80108bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bf5:	e9 38 01 00 00       	jmp    80108d32 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108c01:	3c 06                	cmp    $0x6,%al
80108c03:	74 0a                	je     80108c0f <arp_proc+0x4e>
80108c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c0a:	e9 23 01 00 00       	jmp    80108d32 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c12:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108c16:	3c 04                	cmp    $0x4,%al
80108c18:	74 0a                	je     80108c24 <arp_proc+0x63>
80108c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c1f:	e9 0e 01 00 00       	jmp    80108d32 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c27:	83 c0 18             	add    $0x18,%eax
80108c2a:	83 ec 04             	sub    $0x4,%esp
80108c2d:	6a 04                	push   $0x4
80108c2f:	50                   	push   %eax
80108c30:	68 04 f5 10 80       	push   $0x8010f504
80108c35:	e8 b6 bd ff ff       	call   801049f0 <memcmp>
80108c3a:	83 c4 10             	add    $0x10,%esp
80108c3d:	85 c0                	test   %eax,%eax
80108c3f:	74 27                	je     80108c68 <arp_proc+0xa7>
80108c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c44:	83 c0 0e             	add    $0xe,%eax
80108c47:	83 ec 04             	sub    $0x4,%esp
80108c4a:	6a 04                	push   $0x4
80108c4c:	50                   	push   %eax
80108c4d:	68 04 f5 10 80       	push   $0x8010f504
80108c52:	e8 99 bd ff ff       	call   801049f0 <memcmp>
80108c57:	83 c4 10             	add    $0x10,%esp
80108c5a:	85 c0                	test   %eax,%eax
80108c5c:	74 0a                	je     80108c68 <arp_proc+0xa7>
80108c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c63:	e9 ca 00 00 00       	jmp    80108d32 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108c6f:	66 3d 00 01          	cmp    $0x100,%ax
80108c73:	75 69                	jne    80108cde <arp_proc+0x11d>
80108c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c78:	83 c0 18             	add    $0x18,%eax
80108c7b:	83 ec 04             	sub    $0x4,%esp
80108c7e:	6a 04                	push   $0x4
80108c80:	50                   	push   %eax
80108c81:	68 04 f5 10 80       	push   $0x8010f504
80108c86:	e8 65 bd ff ff       	call   801049f0 <memcmp>
80108c8b:	83 c4 10             	add    $0x10,%esp
80108c8e:	85 c0                	test   %eax,%eax
80108c90:	75 4c                	jne    80108cde <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108c92:	e8 09 9b ff ff       	call   801027a0 <kalloc>
80108c97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108c9a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108ca1:	83 ec 04             	sub    $0x4,%esp
80108ca4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ca7:	50                   	push   %eax
80108ca8:	ff 75 f0             	push   -0x10(%ebp)
80108cab:	ff 75 f4             	push   -0xc(%ebp)
80108cae:	e8 1f 04 00 00       	call   801090d2 <arp_reply_pkt_create>
80108cb3:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb9:	83 ec 08             	sub    $0x8,%esp
80108cbc:	50                   	push   %eax
80108cbd:	ff 75 f0             	push   -0x10(%ebp)
80108cc0:	e8 d0 fd ff ff       	call   80108a95 <i8254_send>
80108cc5:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccb:	83 ec 0c             	sub    $0xc,%esp
80108cce:	50                   	push   %eax
80108ccf:	e8 32 9a ff ff       	call   80102706 <kfree>
80108cd4:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108cd7:	b8 02 00 00 00       	mov    $0x2,%eax
80108cdc:	eb 54                	jmp    80108d32 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce1:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108ce5:	66 3d 00 02          	cmp    $0x200,%ax
80108ce9:	75 42                	jne    80108d2d <arp_proc+0x16c>
80108ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cee:	83 c0 18             	add    $0x18,%eax
80108cf1:	83 ec 04             	sub    $0x4,%esp
80108cf4:	6a 04                	push   $0x4
80108cf6:	50                   	push   %eax
80108cf7:	68 04 f5 10 80       	push   $0x8010f504
80108cfc:	e8 ef bc ff ff       	call   801049f0 <memcmp>
80108d01:	83 c4 10             	add    $0x10,%esp
80108d04:	85 c0                	test   %eax,%eax
80108d06:	75 25                	jne    80108d2d <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108d08:	83 ec 0c             	sub    $0xc,%esp
80108d0b:	68 9c be 10 80       	push   $0x8010be9c
80108d10:	e8 df 76 ff ff       	call   801003f4 <cprintf>
80108d15:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108d18:	83 ec 0c             	sub    $0xc,%esp
80108d1b:	ff 75 f4             	push   -0xc(%ebp)
80108d1e:	e8 af 01 00 00       	call   80108ed2 <arp_table_update>
80108d23:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108d26:	b8 01 00 00 00       	mov    $0x1,%eax
80108d2b:	eb 05                	jmp    80108d32 <arp_proc+0x171>
  }else{
    return -1;
80108d2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108d32:	c9                   	leave  
80108d33:	c3                   	ret    

80108d34 <arp_scan>:

void arp_scan(){
80108d34:	55                   	push   %ebp
80108d35:	89 e5                	mov    %esp,%ebp
80108d37:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108d3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d41:	eb 6f                	jmp    80108db2 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108d43:	e8 58 9a ff ff       	call   801027a0 <kalloc>
80108d48:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108d4b:	83 ec 04             	sub    $0x4,%esp
80108d4e:	ff 75 f4             	push   -0xc(%ebp)
80108d51:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108d54:	50                   	push   %eax
80108d55:	ff 75 ec             	push   -0x14(%ebp)
80108d58:	e8 62 00 00 00       	call   80108dbf <arp_broadcast>
80108d5d:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108d60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d63:	83 ec 08             	sub    $0x8,%esp
80108d66:	50                   	push   %eax
80108d67:	ff 75 ec             	push   -0x14(%ebp)
80108d6a:	e8 26 fd ff ff       	call   80108a95 <i8254_send>
80108d6f:	83 c4 10             	add    $0x10,%esp
80108d72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d75:	eb 22                	jmp    80108d99 <arp_scan+0x65>
      microdelay(1);
80108d77:	83 ec 0c             	sub    $0xc,%esp
80108d7a:	6a 01                	push   $0x1
80108d7c:	e8 b6 9d ff ff       	call   80102b37 <microdelay>
80108d81:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108d84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d87:	83 ec 08             	sub    $0x8,%esp
80108d8a:	50                   	push   %eax
80108d8b:	ff 75 ec             	push   -0x14(%ebp)
80108d8e:	e8 02 fd ff ff       	call   80108a95 <i8254_send>
80108d93:	83 c4 10             	add    $0x10,%esp
80108d96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d99:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108d9d:	74 d8                	je     80108d77 <arp_scan+0x43>
    }
    kfree((char *)send);
80108d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da2:	83 ec 0c             	sub    $0xc,%esp
80108da5:	50                   	push   %eax
80108da6:	e8 5b 99 ff ff       	call   80102706 <kfree>
80108dab:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108dae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108db2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108db9:	7e 88                	jle    80108d43 <arp_scan+0xf>
  }
}
80108dbb:	90                   	nop
80108dbc:	90                   	nop
80108dbd:	c9                   	leave  
80108dbe:	c3                   	ret    

80108dbf <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108dbf:	55                   	push   %ebp
80108dc0:	89 e5                	mov    %esp,%ebp
80108dc2:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108dc5:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108dc9:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108dcd:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108dd1:	8b 45 10             	mov    0x10(%ebp),%eax
80108dd4:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108dd7:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108dde:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108de4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108deb:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108df4:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80108dfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108e00:	8b 45 08             	mov    0x8(%ebp),%eax
80108e03:	83 c0 0e             	add    $0xe,%eax
80108e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e13:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1a:	83 ec 04             	sub    $0x4,%esp
80108e1d:	6a 06                	push   $0x6
80108e1f:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108e22:	52                   	push   %edx
80108e23:	50                   	push   %eax
80108e24:	e8 1f bc ff ff       	call   80104a48 <memmove>
80108e29:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2f:	83 c0 06             	add    $0x6,%eax
80108e32:	83 ec 04             	sub    $0x4,%esp
80108e35:	6a 06                	push   $0x6
80108e37:	68 80 6f 19 80       	push   $0x80196f80
80108e3c:	50                   	push   %eax
80108e3d:	e8 06 bc ff ff       	call   80104a48 <memmove>
80108e42:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e48:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e50:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e59:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e60:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e67:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e70:	8d 50 12             	lea    0x12(%eax),%edx
80108e73:	83 ec 04             	sub    $0x4,%esp
80108e76:	6a 06                	push   $0x6
80108e78:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108e7b:	50                   	push   %eax
80108e7c:	52                   	push   %edx
80108e7d:	e8 c6 bb ff ff       	call   80104a48 <memmove>
80108e82:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e88:	8d 50 18             	lea    0x18(%eax),%edx
80108e8b:	83 ec 04             	sub    $0x4,%esp
80108e8e:	6a 04                	push   $0x4
80108e90:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e93:	50                   	push   %eax
80108e94:	52                   	push   %edx
80108e95:	e8 ae bb ff ff       	call   80104a48 <memmove>
80108e9a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea0:	83 c0 08             	add    $0x8,%eax
80108ea3:	83 ec 04             	sub    $0x4,%esp
80108ea6:	6a 06                	push   $0x6
80108ea8:	68 80 6f 19 80       	push   $0x80196f80
80108ead:	50                   	push   %eax
80108eae:	e8 95 bb ff ff       	call   80104a48 <memmove>
80108eb3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb9:	83 c0 0e             	add    $0xe,%eax
80108ebc:	83 ec 04             	sub    $0x4,%esp
80108ebf:	6a 04                	push   $0x4
80108ec1:	68 04 f5 10 80       	push   $0x8010f504
80108ec6:	50                   	push   %eax
80108ec7:	e8 7c bb ff ff       	call   80104a48 <memmove>
80108ecc:	83 c4 10             	add    $0x10,%esp
}
80108ecf:	90                   	nop
80108ed0:	c9                   	leave  
80108ed1:	c3                   	ret    

80108ed2 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108ed2:	55                   	push   %ebp
80108ed3:	89 e5                	mov    %esp,%ebp
80108ed5:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80108edb:	83 c0 0e             	add    $0xe,%eax
80108ede:	83 ec 0c             	sub    $0xc,%esp
80108ee1:	50                   	push   %eax
80108ee2:	e8 bc 00 00 00       	call   80108fa3 <arp_table_search>
80108ee7:	83 c4 10             	add    $0x10,%esp
80108eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108eed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108ef1:	78 2d                	js     80108f20 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef6:	8d 48 08             	lea    0x8(%eax),%ecx
80108ef9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108efc:	89 d0                	mov    %edx,%eax
80108efe:	c1 e0 02             	shl    $0x2,%eax
80108f01:	01 d0                	add    %edx,%eax
80108f03:	01 c0                	add    %eax,%eax
80108f05:	01 d0                	add    %edx,%eax
80108f07:	05 a0 6f 19 80       	add    $0x80196fa0,%eax
80108f0c:	83 c0 04             	add    $0x4,%eax
80108f0f:	83 ec 04             	sub    $0x4,%esp
80108f12:	6a 06                	push   $0x6
80108f14:	51                   	push   %ecx
80108f15:	50                   	push   %eax
80108f16:	e8 2d bb ff ff       	call   80104a48 <memmove>
80108f1b:	83 c4 10             	add    $0x10,%esp
80108f1e:	eb 70                	jmp    80108f90 <arp_table_update+0xbe>
  }else{
    index += 1;
80108f20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108f24:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f27:	8b 45 08             	mov    0x8(%ebp),%eax
80108f2a:	8d 48 08             	lea    0x8(%eax),%ecx
80108f2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f30:	89 d0                	mov    %edx,%eax
80108f32:	c1 e0 02             	shl    $0x2,%eax
80108f35:	01 d0                	add    %edx,%eax
80108f37:	01 c0                	add    %eax,%eax
80108f39:	01 d0                	add    %edx,%eax
80108f3b:	05 a0 6f 19 80       	add    $0x80196fa0,%eax
80108f40:	83 c0 04             	add    $0x4,%eax
80108f43:	83 ec 04             	sub    $0x4,%esp
80108f46:	6a 06                	push   $0x6
80108f48:	51                   	push   %ecx
80108f49:	50                   	push   %eax
80108f4a:	e8 f9 ba ff ff       	call   80104a48 <memmove>
80108f4f:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108f52:	8b 45 08             	mov    0x8(%ebp),%eax
80108f55:	8d 48 0e             	lea    0xe(%eax),%ecx
80108f58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f5b:	89 d0                	mov    %edx,%eax
80108f5d:	c1 e0 02             	shl    $0x2,%eax
80108f60:	01 d0                	add    %edx,%eax
80108f62:	01 c0                	add    %eax,%eax
80108f64:	01 d0                	add    %edx,%eax
80108f66:	05 a0 6f 19 80       	add    $0x80196fa0,%eax
80108f6b:	83 ec 04             	sub    $0x4,%esp
80108f6e:	6a 04                	push   $0x4
80108f70:	51                   	push   %ecx
80108f71:	50                   	push   %eax
80108f72:	e8 d1 ba ff ff       	call   80104a48 <memmove>
80108f77:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108f7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f7d:	89 d0                	mov    %edx,%eax
80108f7f:	c1 e0 02             	shl    $0x2,%eax
80108f82:	01 d0                	add    %edx,%eax
80108f84:	01 c0                	add    %eax,%eax
80108f86:	01 d0                	add    %edx,%eax
80108f88:	05 aa 6f 19 80       	add    $0x80196faa,%eax
80108f8d:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108f90:	83 ec 0c             	sub    $0xc,%esp
80108f93:	68 a0 6f 19 80       	push   $0x80196fa0
80108f98:	e8 83 00 00 00       	call   80109020 <print_arp_table>
80108f9d:	83 c4 10             	add    $0x10,%esp
}
80108fa0:	90                   	nop
80108fa1:	c9                   	leave  
80108fa2:	c3                   	ret    

80108fa3 <arp_table_search>:

int arp_table_search(uchar *ip){
80108fa3:	55                   	push   %ebp
80108fa4:	89 e5                	mov    %esp,%ebp
80108fa6:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80108fa9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80108fb0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fb7:	eb 59                	jmp    80109012 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80108fb9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fbc:	89 d0                	mov    %edx,%eax
80108fbe:	c1 e0 02             	shl    $0x2,%eax
80108fc1:	01 d0                	add    %edx,%eax
80108fc3:	01 c0                	add    %eax,%eax
80108fc5:	01 d0                	add    %edx,%eax
80108fc7:	05 a0 6f 19 80       	add    $0x80196fa0,%eax
80108fcc:	83 ec 04             	sub    $0x4,%esp
80108fcf:	6a 04                	push   $0x4
80108fd1:	ff 75 08             	push   0x8(%ebp)
80108fd4:	50                   	push   %eax
80108fd5:	e8 16 ba ff ff       	call   801049f0 <memcmp>
80108fda:	83 c4 10             	add    $0x10,%esp
80108fdd:	85 c0                	test   %eax,%eax
80108fdf:	75 05                	jne    80108fe6 <arp_table_search+0x43>
      return i;
80108fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe4:	eb 38                	jmp    8010901e <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80108fe6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fe9:	89 d0                	mov    %edx,%eax
80108feb:	c1 e0 02             	shl    $0x2,%eax
80108fee:	01 d0                	add    %edx,%eax
80108ff0:	01 c0                	add    %eax,%eax
80108ff2:	01 d0                	add    %edx,%eax
80108ff4:	05 aa 6f 19 80       	add    $0x80196faa,%eax
80108ff9:	0f b6 00             	movzbl (%eax),%eax
80108ffc:	84 c0                	test   %al,%al
80108ffe:	75 0e                	jne    8010900e <arp_table_search+0x6b>
80109000:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109004:	75 08                	jne    8010900e <arp_table_search+0x6b>
      empty = -i;
80109006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109009:	f7 d8                	neg    %eax
8010900b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010900e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109012:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109016:	7e a1                	jle    80108fb9 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901b:	83 e8 01             	sub    $0x1,%eax
}
8010901e:	c9                   	leave  
8010901f:	c3                   	ret    

80109020 <print_arp_table>:

void print_arp_table(){
80109020:	55                   	push   %ebp
80109021:	89 e5                	mov    %esp,%ebp
80109023:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109026:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010902d:	e9 92 00 00 00       	jmp    801090c4 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109032:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109035:	89 d0                	mov    %edx,%eax
80109037:	c1 e0 02             	shl    $0x2,%eax
8010903a:	01 d0                	add    %edx,%eax
8010903c:	01 c0                	add    %eax,%eax
8010903e:	01 d0                	add    %edx,%eax
80109040:	05 aa 6f 19 80       	add    $0x80196faa,%eax
80109045:	0f b6 00             	movzbl (%eax),%eax
80109048:	84 c0                	test   %al,%al
8010904a:	74 74                	je     801090c0 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010904c:	83 ec 08             	sub    $0x8,%esp
8010904f:	ff 75 f4             	push   -0xc(%ebp)
80109052:	68 af be 10 80       	push   $0x8010beaf
80109057:	e8 98 73 ff ff       	call   801003f4 <cprintf>
8010905c:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010905f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109062:	89 d0                	mov    %edx,%eax
80109064:	c1 e0 02             	shl    $0x2,%eax
80109067:	01 d0                	add    %edx,%eax
80109069:	01 c0                	add    %eax,%eax
8010906b:	01 d0                	add    %edx,%eax
8010906d:	05 a0 6f 19 80       	add    $0x80196fa0,%eax
80109072:	83 ec 0c             	sub    $0xc,%esp
80109075:	50                   	push   %eax
80109076:	e8 54 02 00 00       	call   801092cf <print_ipv4>
8010907b:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010907e:	83 ec 0c             	sub    $0xc,%esp
80109081:	68 be be 10 80       	push   $0x8010bebe
80109086:	e8 69 73 ff ff       	call   801003f4 <cprintf>
8010908b:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010908e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109091:	89 d0                	mov    %edx,%eax
80109093:	c1 e0 02             	shl    $0x2,%eax
80109096:	01 d0                	add    %edx,%eax
80109098:	01 c0                	add    %eax,%eax
8010909a:	01 d0                	add    %edx,%eax
8010909c:	05 a0 6f 19 80       	add    $0x80196fa0,%eax
801090a1:	83 c0 04             	add    $0x4,%eax
801090a4:	83 ec 0c             	sub    $0xc,%esp
801090a7:	50                   	push   %eax
801090a8:	e8 70 02 00 00       	call   8010931d <print_mac>
801090ad:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801090b0:	83 ec 0c             	sub    $0xc,%esp
801090b3:	68 c0 be 10 80       	push   $0x8010bec0
801090b8:	e8 37 73 ff ff       	call   801003f4 <cprintf>
801090bd:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801090c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801090c4:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801090c8:	0f 8e 64 ff ff ff    	jle    80109032 <print_arp_table+0x12>
    }
  }
}
801090ce:	90                   	nop
801090cf:	90                   	nop
801090d0:	c9                   	leave  
801090d1:	c3                   	ret    

801090d2 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801090d2:	55                   	push   %ebp
801090d3:	89 e5                	mov    %esp,%ebp
801090d5:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090d8:	8b 45 10             	mov    0x10(%ebp),%eax
801090db:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801090e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801090e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801090e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801090ea:	83 c0 0e             	add    $0xe,%eax
801090ed:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801090f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f3:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801090f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090fa:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801090fe:	8b 45 08             	mov    0x8(%ebp),%eax
80109101:	8d 50 08             	lea    0x8(%eax),%edx
80109104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109107:	83 ec 04             	sub    $0x4,%esp
8010910a:	6a 06                	push   $0x6
8010910c:	52                   	push   %edx
8010910d:	50                   	push   %eax
8010910e:	e8 35 b9 ff ff       	call   80104a48 <memmove>
80109113:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109119:	83 c0 06             	add    $0x6,%eax
8010911c:	83 ec 04             	sub    $0x4,%esp
8010911f:	6a 06                	push   $0x6
80109121:	68 80 6f 19 80       	push   $0x80196f80
80109126:	50                   	push   %eax
80109127:	e8 1c b9 ff ff       	call   80104a48 <memmove>
8010912c:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010912f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109132:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109137:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913a:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109143:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109147:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010914a:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010914e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109151:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109157:	8b 45 08             	mov    0x8(%ebp),%eax
8010915a:	8d 50 08             	lea    0x8(%eax),%edx
8010915d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109160:	83 c0 12             	add    $0x12,%eax
80109163:	83 ec 04             	sub    $0x4,%esp
80109166:	6a 06                	push   $0x6
80109168:	52                   	push   %edx
80109169:	50                   	push   %eax
8010916a:	e8 d9 b8 ff ff       	call   80104a48 <memmove>
8010916f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109172:	8b 45 08             	mov    0x8(%ebp),%eax
80109175:	8d 50 0e             	lea    0xe(%eax),%edx
80109178:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010917b:	83 c0 18             	add    $0x18,%eax
8010917e:	83 ec 04             	sub    $0x4,%esp
80109181:	6a 04                	push   $0x4
80109183:	52                   	push   %edx
80109184:	50                   	push   %eax
80109185:	e8 be b8 ff ff       	call   80104a48 <memmove>
8010918a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010918d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109190:	83 c0 08             	add    $0x8,%eax
80109193:	83 ec 04             	sub    $0x4,%esp
80109196:	6a 06                	push   $0x6
80109198:	68 80 6f 19 80       	push   $0x80196f80
8010919d:	50                   	push   %eax
8010919e:	e8 a5 b8 ff ff       	call   80104a48 <memmove>
801091a3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801091a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a9:	83 c0 0e             	add    $0xe,%eax
801091ac:	83 ec 04             	sub    $0x4,%esp
801091af:	6a 04                	push   $0x4
801091b1:	68 04 f5 10 80       	push   $0x8010f504
801091b6:	50                   	push   %eax
801091b7:	e8 8c b8 ff ff       	call   80104a48 <memmove>
801091bc:	83 c4 10             	add    $0x10,%esp
}
801091bf:	90                   	nop
801091c0:	c9                   	leave  
801091c1:	c3                   	ret    

801091c2 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801091c2:	55                   	push   %ebp
801091c3:	89 e5                	mov    %esp,%ebp
801091c5:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801091c8:	83 ec 0c             	sub    $0xc,%esp
801091cb:	68 c2 be 10 80       	push   $0x8010bec2
801091d0:	e8 1f 72 ff ff       	call   801003f4 <cprintf>
801091d5:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801091d8:	8b 45 08             	mov    0x8(%ebp),%eax
801091db:	83 c0 0e             	add    $0xe,%eax
801091de:	83 ec 0c             	sub    $0xc,%esp
801091e1:	50                   	push   %eax
801091e2:	e8 e8 00 00 00       	call   801092cf <print_ipv4>
801091e7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801091ea:	83 ec 0c             	sub    $0xc,%esp
801091ed:	68 c0 be 10 80       	push   $0x8010bec0
801091f2:	e8 fd 71 ff ff       	call   801003f4 <cprintf>
801091f7:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801091fa:	8b 45 08             	mov    0x8(%ebp),%eax
801091fd:	83 c0 08             	add    $0x8,%eax
80109200:	83 ec 0c             	sub    $0xc,%esp
80109203:	50                   	push   %eax
80109204:	e8 14 01 00 00       	call   8010931d <print_mac>
80109209:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010920c:	83 ec 0c             	sub    $0xc,%esp
8010920f:	68 c0 be 10 80       	push   $0x8010bec0
80109214:	e8 db 71 ff ff       	call   801003f4 <cprintf>
80109219:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010921c:	83 ec 0c             	sub    $0xc,%esp
8010921f:	68 d9 be 10 80       	push   $0x8010bed9
80109224:	e8 cb 71 ff ff       	call   801003f4 <cprintf>
80109229:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010922c:	8b 45 08             	mov    0x8(%ebp),%eax
8010922f:	83 c0 18             	add    $0x18,%eax
80109232:	83 ec 0c             	sub    $0xc,%esp
80109235:	50                   	push   %eax
80109236:	e8 94 00 00 00       	call   801092cf <print_ipv4>
8010923b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010923e:	83 ec 0c             	sub    $0xc,%esp
80109241:	68 c0 be 10 80       	push   $0x8010bec0
80109246:	e8 a9 71 ff ff       	call   801003f4 <cprintf>
8010924b:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010924e:	8b 45 08             	mov    0x8(%ebp),%eax
80109251:	83 c0 12             	add    $0x12,%eax
80109254:	83 ec 0c             	sub    $0xc,%esp
80109257:	50                   	push   %eax
80109258:	e8 c0 00 00 00       	call   8010931d <print_mac>
8010925d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109260:	83 ec 0c             	sub    $0xc,%esp
80109263:	68 c0 be 10 80       	push   $0x8010bec0
80109268:	e8 87 71 ff ff       	call   801003f4 <cprintf>
8010926d:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109270:	83 ec 0c             	sub    $0xc,%esp
80109273:	68 f0 be 10 80       	push   $0x8010bef0
80109278:	e8 77 71 ff ff       	call   801003f4 <cprintf>
8010927d:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109280:	8b 45 08             	mov    0x8(%ebp),%eax
80109283:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109287:	66 3d 00 01          	cmp    $0x100,%ax
8010928b:	75 12                	jne    8010929f <print_arp_info+0xdd>
8010928d:	83 ec 0c             	sub    $0xc,%esp
80109290:	68 fc be 10 80       	push   $0x8010befc
80109295:	e8 5a 71 ff ff       	call   801003f4 <cprintf>
8010929a:	83 c4 10             	add    $0x10,%esp
8010929d:	eb 1d                	jmp    801092bc <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010929f:	8b 45 08             	mov    0x8(%ebp),%eax
801092a2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092a6:	66 3d 00 02          	cmp    $0x200,%ax
801092aa:	75 10                	jne    801092bc <print_arp_info+0xfa>
    cprintf("Reply\n");
801092ac:	83 ec 0c             	sub    $0xc,%esp
801092af:	68 05 bf 10 80       	push   $0x8010bf05
801092b4:	e8 3b 71 ff ff       	call   801003f4 <cprintf>
801092b9:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801092bc:	83 ec 0c             	sub    $0xc,%esp
801092bf:	68 c0 be 10 80       	push   $0x8010bec0
801092c4:	e8 2b 71 ff ff       	call   801003f4 <cprintf>
801092c9:	83 c4 10             	add    $0x10,%esp
}
801092cc:	90                   	nop
801092cd:	c9                   	leave  
801092ce:	c3                   	ret    

801092cf <print_ipv4>:

void print_ipv4(uchar *ip){
801092cf:	55                   	push   %ebp
801092d0:	89 e5                	mov    %esp,%ebp
801092d2:	53                   	push   %ebx
801092d3:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801092d6:	8b 45 08             	mov    0x8(%ebp),%eax
801092d9:	83 c0 03             	add    $0x3,%eax
801092dc:	0f b6 00             	movzbl (%eax),%eax
801092df:	0f b6 d8             	movzbl %al,%ebx
801092e2:	8b 45 08             	mov    0x8(%ebp),%eax
801092e5:	83 c0 02             	add    $0x2,%eax
801092e8:	0f b6 00             	movzbl (%eax),%eax
801092eb:	0f b6 c8             	movzbl %al,%ecx
801092ee:	8b 45 08             	mov    0x8(%ebp),%eax
801092f1:	83 c0 01             	add    $0x1,%eax
801092f4:	0f b6 00             	movzbl (%eax),%eax
801092f7:	0f b6 d0             	movzbl %al,%edx
801092fa:	8b 45 08             	mov    0x8(%ebp),%eax
801092fd:	0f b6 00             	movzbl (%eax),%eax
80109300:	0f b6 c0             	movzbl %al,%eax
80109303:	83 ec 0c             	sub    $0xc,%esp
80109306:	53                   	push   %ebx
80109307:	51                   	push   %ecx
80109308:	52                   	push   %edx
80109309:	50                   	push   %eax
8010930a:	68 0c bf 10 80       	push   $0x8010bf0c
8010930f:	e8 e0 70 ff ff       	call   801003f4 <cprintf>
80109314:	83 c4 20             	add    $0x20,%esp
}
80109317:	90                   	nop
80109318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010931b:	c9                   	leave  
8010931c:	c3                   	ret    

8010931d <print_mac>:

void print_mac(uchar *mac){
8010931d:	55                   	push   %ebp
8010931e:	89 e5                	mov    %esp,%ebp
80109320:	57                   	push   %edi
80109321:	56                   	push   %esi
80109322:	53                   	push   %ebx
80109323:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109326:	8b 45 08             	mov    0x8(%ebp),%eax
80109329:	83 c0 05             	add    $0x5,%eax
8010932c:	0f b6 00             	movzbl (%eax),%eax
8010932f:	0f b6 f8             	movzbl %al,%edi
80109332:	8b 45 08             	mov    0x8(%ebp),%eax
80109335:	83 c0 04             	add    $0x4,%eax
80109338:	0f b6 00             	movzbl (%eax),%eax
8010933b:	0f b6 f0             	movzbl %al,%esi
8010933e:	8b 45 08             	mov    0x8(%ebp),%eax
80109341:	83 c0 03             	add    $0x3,%eax
80109344:	0f b6 00             	movzbl (%eax),%eax
80109347:	0f b6 d8             	movzbl %al,%ebx
8010934a:	8b 45 08             	mov    0x8(%ebp),%eax
8010934d:	83 c0 02             	add    $0x2,%eax
80109350:	0f b6 00             	movzbl (%eax),%eax
80109353:	0f b6 c8             	movzbl %al,%ecx
80109356:	8b 45 08             	mov    0x8(%ebp),%eax
80109359:	83 c0 01             	add    $0x1,%eax
8010935c:	0f b6 00             	movzbl (%eax),%eax
8010935f:	0f b6 d0             	movzbl %al,%edx
80109362:	8b 45 08             	mov    0x8(%ebp),%eax
80109365:	0f b6 00             	movzbl (%eax),%eax
80109368:	0f b6 c0             	movzbl %al,%eax
8010936b:	83 ec 04             	sub    $0x4,%esp
8010936e:	57                   	push   %edi
8010936f:	56                   	push   %esi
80109370:	53                   	push   %ebx
80109371:	51                   	push   %ecx
80109372:	52                   	push   %edx
80109373:	50                   	push   %eax
80109374:	68 24 bf 10 80       	push   $0x8010bf24
80109379:	e8 76 70 ff ff       	call   801003f4 <cprintf>
8010937e:	83 c4 20             	add    $0x20,%esp
}
80109381:	90                   	nop
80109382:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109385:	5b                   	pop    %ebx
80109386:	5e                   	pop    %esi
80109387:	5f                   	pop    %edi
80109388:	5d                   	pop    %ebp
80109389:	c3                   	ret    

8010938a <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010938a:	55                   	push   %ebp
8010938b:	89 e5                	mov    %esp,%ebp
8010938d:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109390:	8b 45 08             	mov    0x8(%ebp),%eax
80109393:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109396:	8b 45 08             	mov    0x8(%ebp),%eax
80109399:	83 c0 0e             	add    $0xe,%eax
8010939c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010939f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093a6:	3c 08                	cmp    $0x8,%al
801093a8:	75 1b                	jne    801093c5 <eth_proc+0x3b>
801093aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ad:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093b1:	3c 06                	cmp    $0x6,%al
801093b3:	75 10                	jne    801093c5 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801093b5:	83 ec 0c             	sub    $0xc,%esp
801093b8:	ff 75 f0             	push   -0x10(%ebp)
801093bb:	e8 01 f8 ff ff       	call   80108bc1 <arp_proc>
801093c0:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801093c3:	eb 24                	jmp    801093e9 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801093c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093cc:	3c 08                	cmp    $0x8,%al
801093ce:	75 19                	jne    801093e9 <eth_proc+0x5f>
801093d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093d7:	84 c0                	test   %al,%al
801093d9:	75 0e                	jne    801093e9 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801093db:	83 ec 0c             	sub    $0xc,%esp
801093de:	ff 75 08             	push   0x8(%ebp)
801093e1:	e8 a3 00 00 00       	call   80109489 <ipv4_proc>
801093e6:	83 c4 10             	add    $0x10,%esp
}
801093e9:	90                   	nop
801093ea:	c9                   	leave  
801093eb:	c3                   	ret    

801093ec <N2H_ushort>:

ushort N2H_ushort(ushort value){
801093ec:	55                   	push   %ebp
801093ed:	89 e5                	mov    %esp,%ebp
801093ef:	83 ec 04             	sub    $0x4,%esp
801093f2:	8b 45 08             	mov    0x8(%ebp),%eax
801093f5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801093f9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801093fd:	c1 e0 08             	shl    $0x8,%eax
80109400:	89 c2                	mov    %eax,%edx
80109402:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109406:	66 c1 e8 08          	shr    $0x8,%ax
8010940a:	01 d0                	add    %edx,%eax
}
8010940c:	c9                   	leave  
8010940d:	c3                   	ret    

8010940e <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010940e:	55                   	push   %ebp
8010940f:	89 e5                	mov    %esp,%ebp
80109411:	83 ec 04             	sub    $0x4,%esp
80109414:	8b 45 08             	mov    0x8(%ebp),%eax
80109417:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010941b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010941f:	c1 e0 08             	shl    $0x8,%eax
80109422:	89 c2                	mov    %eax,%edx
80109424:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109428:	66 c1 e8 08          	shr    $0x8,%ax
8010942c:	01 d0                	add    %edx,%eax
}
8010942e:	c9                   	leave  
8010942f:	c3                   	ret    

80109430 <H2N_uint>:

uint H2N_uint(uint value){
80109430:	55                   	push   %ebp
80109431:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109433:	8b 45 08             	mov    0x8(%ebp),%eax
80109436:	c1 e0 18             	shl    $0x18,%eax
80109439:	25 00 00 00 0f       	and    $0xf000000,%eax
8010943e:	89 c2                	mov    %eax,%edx
80109440:	8b 45 08             	mov    0x8(%ebp),%eax
80109443:	c1 e0 08             	shl    $0x8,%eax
80109446:	25 00 f0 00 00       	and    $0xf000,%eax
8010944b:	09 c2                	or     %eax,%edx
8010944d:	8b 45 08             	mov    0x8(%ebp),%eax
80109450:	c1 e8 08             	shr    $0x8,%eax
80109453:	83 e0 0f             	and    $0xf,%eax
80109456:	01 d0                	add    %edx,%eax
}
80109458:	5d                   	pop    %ebp
80109459:	c3                   	ret    

8010945a <N2H_uint>:

uint N2H_uint(uint value){
8010945a:	55                   	push   %ebp
8010945b:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010945d:	8b 45 08             	mov    0x8(%ebp),%eax
80109460:	c1 e0 18             	shl    $0x18,%eax
80109463:	89 c2                	mov    %eax,%edx
80109465:	8b 45 08             	mov    0x8(%ebp),%eax
80109468:	c1 e0 08             	shl    $0x8,%eax
8010946b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109470:	01 c2                	add    %eax,%edx
80109472:	8b 45 08             	mov    0x8(%ebp),%eax
80109475:	c1 e8 08             	shr    $0x8,%eax
80109478:	25 00 ff 00 00       	and    $0xff00,%eax
8010947d:	01 c2                	add    %eax,%edx
8010947f:	8b 45 08             	mov    0x8(%ebp),%eax
80109482:	c1 e8 18             	shr    $0x18,%eax
80109485:	01 d0                	add    %edx,%eax
}
80109487:	5d                   	pop    %ebp
80109488:	c3                   	ret    

80109489 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109489:	55                   	push   %ebp
8010948a:	89 e5                	mov    %esp,%ebp
8010948c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010948f:	8b 45 08             	mov    0x8(%ebp),%eax
80109492:	83 c0 0e             	add    $0xe,%eax
80109495:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010949f:	0f b7 d0             	movzwl %ax,%edx
801094a2:	a1 08 f5 10 80       	mov    0x8010f508,%eax
801094a7:	39 c2                	cmp    %eax,%edx
801094a9:	74 60                	je     8010950b <ipv4_proc+0x82>
801094ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ae:	83 c0 0c             	add    $0xc,%eax
801094b1:	83 ec 04             	sub    $0x4,%esp
801094b4:	6a 04                	push   $0x4
801094b6:	50                   	push   %eax
801094b7:	68 04 f5 10 80       	push   $0x8010f504
801094bc:	e8 2f b5 ff ff       	call   801049f0 <memcmp>
801094c1:	83 c4 10             	add    $0x10,%esp
801094c4:	85 c0                	test   %eax,%eax
801094c6:	74 43                	je     8010950b <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801094c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094cb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094cf:	0f b7 c0             	movzwl %ax,%eax
801094d2:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801094d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094da:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094de:	3c 01                	cmp    $0x1,%al
801094e0:	75 10                	jne    801094f2 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801094e2:	83 ec 0c             	sub    $0xc,%esp
801094e5:	ff 75 08             	push   0x8(%ebp)
801094e8:	e8 a3 00 00 00       	call   80109590 <icmp_proc>
801094ed:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801094f0:	eb 19                	jmp    8010950b <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801094f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094f9:	3c 06                	cmp    $0x6,%al
801094fb:	75 0e                	jne    8010950b <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801094fd:	83 ec 0c             	sub    $0xc,%esp
80109500:	ff 75 08             	push   0x8(%ebp)
80109503:	e8 b3 03 00 00       	call   801098bb <tcp_proc>
80109508:	83 c4 10             	add    $0x10,%esp
}
8010950b:	90                   	nop
8010950c:	c9                   	leave  
8010950d:	c3                   	ret    

8010950e <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010950e:	55                   	push   %ebp
8010950f:	89 e5                	mov    %esp,%ebp
80109511:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109514:	8b 45 08             	mov    0x8(%ebp),%eax
80109517:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010951a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010951d:	0f b6 00             	movzbl (%eax),%eax
80109520:	83 e0 0f             	and    $0xf,%eax
80109523:	01 c0                	add    %eax,%eax
80109525:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109528:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010952f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109536:	eb 48                	jmp    80109580 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109538:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010953b:	01 c0                	add    %eax,%eax
8010953d:	89 c2                	mov    %eax,%edx
8010953f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109542:	01 d0                	add    %edx,%eax
80109544:	0f b6 00             	movzbl (%eax),%eax
80109547:	0f b6 c0             	movzbl %al,%eax
8010954a:	c1 e0 08             	shl    $0x8,%eax
8010954d:	89 c2                	mov    %eax,%edx
8010954f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109552:	01 c0                	add    %eax,%eax
80109554:	8d 48 01             	lea    0x1(%eax),%ecx
80109557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955a:	01 c8                	add    %ecx,%eax
8010955c:	0f b6 00             	movzbl (%eax),%eax
8010955f:	0f b6 c0             	movzbl %al,%eax
80109562:	01 d0                	add    %edx,%eax
80109564:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109567:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010956e:	76 0c                	jbe    8010957c <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109570:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109573:	0f b7 c0             	movzwl %ax,%eax
80109576:	83 c0 01             	add    $0x1,%eax
80109579:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010957c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109580:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109584:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109587:	7c af                	jl     80109538 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109589:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010958c:	f7 d0                	not    %eax
}
8010958e:	c9                   	leave  
8010958f:	c3                   	ret    

80109590 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109590:	55                   	push   %ebp
80109591:	89 e5                	mov    %esp,%ebp
80109593:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109596:	8b 45 08             	mov    0x8(%ebp),%eax
80109599:	83 c0 0e             	add    $0xe,%eax
8010959c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010959f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a2:	0f b6 00             	movzbl (%eax),%eax
801095a5:	0f b6 c0             	movzbl %al,%eax
801095a8:	83 e0 0f             	and    $0xf,%eax
801095ab:	c1 e0 02             	shl    $0x2,%eax
801095ae:	89 c2                	mov    %eax,%edx
801095b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b3:	01 d0                	add    %edx,%eax
801095b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801095b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095bb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801095bf:	84 c0                	test   %al,%al
801095c1:	75 4f                	jne    80109612 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801095c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c6:	0f b6 00             	movzbl (%eax),%eax
801095c9:	3c 08                	cmp    $0x8,%al
801095cb:	75 45                	jne    80109612 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801095cd:	e8 ce 91 ff ff       	call   801027a0 <kalloc>
801095d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801095d5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801095dc:	83 ec 04             	sub    $0x4,%esp
801095df:	8d 45 e8             	lea    -0x18(%ebp),%eax
801095e2:	50                   	push   %eax
801095e3:	ff 75 ec             	push   -0x14(%ebp)
801095e6:	ff 75 08             	push   0x8(%ebp)
801095e9:	e8 78 00 00 00       	call   80109666 <icmp_reply_pkt_create>
801095ee:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801095f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095f4:	83 ec 08             	sub    $0x8,%esp
801095f7:	50                   	push   %eax
801095f8:	ff 75 ec             	push   -0x14(%ebp)
801095fb:	e8 95 f4 ff ff       	call   80108a95 <i8254_send>
80109600:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109603:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109606:	83 ec 0c             	sub    $0xc,%esp
80109609:	50                   	push   %eax
8010960a:	e8 f7 90 ff ff       	call   80102706 <kfree>
8010960f:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109612:	90                   	nop
80109613:	c9                   	leave  
80109614:	c3                   	ret    

80109615 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109615:	55                   	push   %ebp
80109616:	89 e5                	mov    %esp,%ebp
80109618:	53                   	push   %ebx
80109619:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010961c:	8b 45 08             	mov    0x8(%ebp),%eax
8010961f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109623:	0f b7 c0             	movzwl %ax,%eax
80109626:	83 ec 0c             	sub    $0xc,%esp
80109629:	50                   	push   %eax
8010962a:	e8 bd fd ff ff       	call   801093ec <N2H_ushort>
8010962f:	83 c4 10             	add    $0x10,%esp
80109632:	0f b7 d8             	movzwl %ax,%ebx
80109635:	8b 45 08             	mov    0x8(%ebp),%eax
80109638:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010963c:	0f b7 c0             	movzwl %ax,%eax
8010963f:	83 ec 0c             	sub    $0xc,%esp
80109642:	50                   	push   %eax
80109643:	e8 a4 fd ff ff       	call   801093ec <N2H_ushort>
80109648:	83 c4 10             	add    $0x10,%esp
8010964b:	0f b7 c0             	movzwl %ax,%eax
8010964e:	83 ec 04             	sub    $0x4,%esp
80109651:	53                   	push   %ebx
80109652:	50                   	push   %eax
80109653:	68 43 bf 10 80       	push   $0x8010bf43
80109658:	e8 97 6d ff ff       	call   801003f4 <cprintf>
8010965d:	83 c4 10             	add    $0x10,%esp
}
80109660:	90                   	nop
80109661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109664:	c9                   	leave  
80109665:	c3                   	ret    

80109666 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109666:	55                   	push   %ebp
80109667:	89 e5                	mov    %esp,%ebp
80109669:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010966c:	8b 45 08             	mov    0x8(%ebp),%eax
8010966f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109672:	8b 45 08             	mov    0x8(%ebp),%eax
80109675:	83 c0 0e             	add    $0xe,%eax
80109678:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010967b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010967e:	0f b6 00             	movzbl (%eax),%eax
80109681:	0f b6 c0             	movzbl %al,%eax
80109684:	83 e0 0f             	and    $0xf,%eax
80109687:	c1 e0 02             	shl    $0x2,%eax
8010968a:	89 c2                	mov    %eax,%edx
8010968c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010968f:	01 d0                	add    %edx,%eax
80109691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109694:	8b 45 0c             	mov    0xc(%ebp),%eax
80109697:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010969a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010969d:	83 c0 0e             	add    $0xe,%eax
801096a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801096a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096a6:	83 c0 14             	add    $0x14,%eax
801096a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801096ac:	8b 45 10             	mov    0x10(%ebp),%eax
801096af:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801096b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b8:	8d 50 06             	lea    0x6(%eax),%edx
801096bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096be:	83 ec 04             	sub    $0x4,%esp
801096c1:	6a 06                	push   $0x6
801096c3:	52                   	push   %edx
801096c4:	50                   	push   %eax
801096c5:	e8 7e b3 ff ff       	call   80104a48 <memmove>
801096ca:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801096cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096d0:	83 c0 06             	add    $0x6,%eax
801096d3:	83 ec 04             	sub    $0x4,%esp
801096d6:	6a 06                	push   $0x6
801096d8:	68 80 6f 19 80       	push   $0x80196f80
801096dd:	50                   	push   %eax
801096de:	e8 65 b3 ff ff       	call   80104a48 <memmove>
801096e3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801096e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096e9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801096ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096f0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801096f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096f7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801096fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096fd:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109701:	83 ec 0c             	sub    $0xc,%esp
80109704:	6a 54                	push   $0x54
80109706:	e8 03 fd ff ff       	call   8010940e <H2N_ushort>
8010970b:	83 c4 10             	add    $0x10,%esp
8010970e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109711:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109715:	0f b7 15 60 72 19 80 	movzwl 0x80197260,%edx
8010971c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010971f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109723:	0f b7 05 60 72 19 80 	movzwl 0x80197260,%eax
8010972a:	83 c0 01             	add    $0x1,%eax
8010972d:	66 a3 60 72 19 80    	mov    %ax,0x80197260
  ipv4_send->fragment = H2N_ushort(0x4000);
80109733:	83 ec 0c             	sub    $0xc,%esp
80109736:	68 00 40 00 00       	push   $0x4000
8010973b:	e8 ce fc ff ff       	call   8010940e <H2N_ushort>
80109740:	83 c4 10             	add    $0x10,%esp
80109743:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109746:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010974a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010974d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109754:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010975b:	83 c0 0c             	add    $0xc,%eax
8010975e:	83 ec 04             	sub    $0x4,%esp
80109761:	6a 04                	push   $0x4
80109763:	68 04 f5 10 80       	push   $0x8010f504
80109768:	50                   	push   %eax
80109769:	e8 da b2 ff ff       	call   80104a48 <memmove>
8010976e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109774:	8d 50 0c             	lea    0xc(%eax),%edx
80109777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010977a:	83 c0 10             	add    $0x10,%eax
8010977d:	83 ec 04             	sub    $0x4,%esp
80109780:	6a 04                	push   $0x4
80109782:	52                   	push   %edx
80109783:	50                   	push   %eax
80109784:	e8 bf b2 ff ff       	call   80104a48 <memmove>
80109789:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010978c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010978f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109798:	83 ec 0c             	sub    $0xc,%esp
8010979b:	50                   	push   %eax
8010979c:	e8 6d fd ff ff       	call   8010950e <ipv4_chksum>
801097a1:	83 c4 10             	add    $0x10,%esp
801097a4:	0f b7 c0             	movzwl %ax,%eax
801097a7:	83 ec 0c             	sub    $0xc,%esp
801097aa:	50                   	push   %eax
801097ab:	e8 5e fc ff ff       	call   8010940e <H2N_ushort>
801097b0:	83 c4 10             	add    $0x10,%esp
801097b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801097b6:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801097ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097bd:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801097c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097c3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801097c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097ca:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801097ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097d1:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801097d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097d8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801097dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097df:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801097e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097e6:	8d 50 08             	lea    0x8(%eax),%edx
801097e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097ec:	83 c0 08             	add    $0x8,%eax
801097ef:	83 ec 04             	sub    $0x4,%esp
801097f2:	6a 08                	push   $0x8
801097f4:	52                   	push   %edx
801097f5:	50                   	push   %eax
801097f6:	e8 4d b2 ff ff       	call   80104a48 <memmove>
801097fb:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
801097fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109801:	8d 50 10             	lea    0x10(%eax),%edx
80109804:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109807:	83 c0 10             	add    $0x10,%eax
8010980a:	83 ec 04             	sub    $0x4,%esp
8010980d:	6a 30                	push   $0x30
8010980f:	52                   	push   %edx
80109810:	50                   	push   %eax
80109811:	e8 32 b2 ff ff       	call   80104a48 <memmove>
80109816:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010981c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109822:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109825:	83 ec 0c             	sub    $0xc,%esp
80109828:	50                   	push   %eax
80109829:	e8 1c 00 00 00       	call   8010984a <icmp_chksum>
8010982e:	83 c4 10             	add    $0x10,%esp
80109831:	0f b7 c0             	movzwl %ax,%eax
80109834:	83 ec 0c             	sub    $0xc,%esp
80109837:	50                   	push   %eax
80109838:	e8 d1 fb ff ff       	call   8010940e <H2N_ushort>
8010983d:	83 c4 10             	add    $0x10,%esp
80109840:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109843:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109847:	90                   	nop
80109848:	c9                   	leave  
80109849:	c3                   	ret    

8010984a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010984a:	55                   	push   %ebp
8010984b:	89 e5                	mov    %esp,%ebp
8010984d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109850:	8b 45 08             	mov    0x8(%ebp),%eax
80109853:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109856:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010985d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109864:	eb 48                	jmp    801098ae <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109866:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109869:	01 c0                	add    %eax,%eax
8010986b:	89 c2                	mov    %eax,%edx
8010986d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109870:	01 d0                	add    %edx,%eax
80109872:	0f b6 00             	movzbl (%eax),%eax
80109875:	0f b6 c0             	movzbl %al,%eax
80109878:	c1 e0 08             	shl    $0x8,%eax
8010987b:	89 c2                	mov    %eax,%edx
8010987d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109880:	01 c0                	add    %eax,%eax
80109882:	8d 48 01             	lea    0x1(%eax),%ecx
80109885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109888:	01 c8                	add    %ecx,%eax
8010988a:	0f b6 00             	movzbl (%eax),%eax
8010988d:	0f b6 c0             	movzbl %al,%eax
80109890:	01 d0                	add    %edx,%eax
80109892:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109895:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010989c:	76 0c                	jbe    801098aa <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010989e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098a1:	0f b7 c0             	movzwl %ax,%eax
801098a4:	83 c0 01             	add    $0x1,%eax
801098a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801098aa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098ae:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801098b2:	7e b2                	jle    80109866 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801098b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098b7:	f7 d0                	not    %eax
}
801098b9:	c9                   	leave  
801098ba:	c3                   	ret    

801098bb <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801098bb:	55                   	push   %ebp
801098bc:	89 e5                	mov    %esp,%ebp
801098be:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801098c1:	8b 45 08             	mov    0x8(%ebp),%eax
801098c4:	83 c0 0e             	add    $0xe,%eax
801098c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801098ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098cd:	0f b6 00             	movzbl (%eax),%eax
801098d0:	0f b6 c0             	movzbl %al,%eax
801098d3:	83 e0 0f             	and    $0xf,%eax
801098d6:	c1 e0 02             	shl    $0x2,%eax
801098d9:	89 c2                	mov    %eax,%edx
801098db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098de:	01 d0                	add    %edx,%eax
801098e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801098e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e6:	83 c0 14             	add    $0x14,%eax
801098e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801098ec:	e8 af 8e ff ff       	call   801027a0 <kalloc>
801098f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
801098f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
801098fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098fe:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109902:	0f b6 c0             	movzbl %al,%eax
80109905:	83 e0 02             	and    $0x2,%eax
80109908:	85 c0                	test   %eax,%eax
8010990a:	74 3d                	je     80109949 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010990c:	83 ec 0c             	sub    $0xc,%esp
8010990f:	6a 00                	push   $0x0
80109911:	6a 12                	push   $0x12
80109913:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109916:	50                   	push   %eax
80109917:	ff 75 e8             	push   -0x18(%ebp)
8010991a:	ff 75 08             	push   0x8(%ebp)
8010991d:	e8 a2 01 00 00       	call   80109ac4 <tcp_pkt_create>
80109922:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109925:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109928:	83 ec 08             	sub    $0x8,%esp
8010992b:	50                   	push   %eax
8010992c:	ff 75 e8             	push   -0x18(%ebp)
8010992f:	e8 61 f1 ff ff       	call   80108a95 <i8254_send>
80109934:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109937:	a1 64 72 19 80       	mov    0x80197264,%eax
8010993c:	83 c0 01             	add    $0x1,%eax
8010993f:	a3 64 72 19 80       	mov    %eax,0x80197264
80109944:	e9 69 01 00 00       	jmp    80109ab2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109950:	3c 18                	cmp    $0x18,%al
80109952:	0f 85 10 01 00 00    	jne    80109a68 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109958:	83 ec 04             	sub    $0x4,%esp
8010995b:	6a 03                	push   $0x3
8010995d:	68 5e bf 10 80       	push   $0x8010bf5e
80109962:	ff 75 ec             	push   -0x14(%ebp)
80109965:	e8 86 b0 ff ff       	call   801049f0 <memcmp>
8010996a:	83 c4 10             	add    $0x10,%esp
8010996d:	85 c0                	test   %eax,%eax
8010996f:	74 74                	je     801099e5 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109971:	83 ec 0c             	sub    $0xc,%esp
80109974:	68 62 bf 10 80       	push   $0x8010bf62
80109979:	e8 76 6a ff ff       	call   801003f4 <cprintf>
8010997e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109981:	83 ec 0c             	sub    $0xc,%esp
80109984:	6a 00                	push   $0x0
80109986:	6a 10                	push   $0x10
80109988:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010998b:	50                   	push   %eax
8010998c:	ff 75 e8             	push   -0x18(%ebp)
8010998f:	ff 75 08             	push   0x8(%ebp)
80109992:	e8 2d 01 00 00       	call   80109ac4 <tcp_pkt_create>
80109997:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010999a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010999d:	83 ec 08             	sub    $0x8,%esp
801099a0:	50                   	push   %eax
801099a1:	ff 75 e8             	push   -0x18(%ebp)
801099a4:	e8 ec f0 ff ff       	call   80108a95 <i8254_send>
801099a9:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
801099ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099af:	83 c0 36             	add    $0x36,%eax
801099b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
801099b5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801099b8:	50                   	push   %eax
801099b9:	ff 75 e0             	push   -0x20(%ebp)
801099bc:	6a 00                	push   $0x0
801099be:	6a 00                	push   $0x0
801099c0:	e8 5a 04 00 00       	call   80109e1f <http_proc>
801099c5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
801099c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801099cb:	83 ec 0c             	sub    $0xc,%esp
801099ce:	50                   	push   %eax
801099cf:	6a 18                	push   $0x18
801099d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099d4:	50                   	push   %eax
801099d5:	ff 75 e8             	push   -0x18(%ebp)
801099d8:	ff 75 08             	push   0x8(%ebp)
801099db:	e8 e4 00 00 00       	call   80109ac4 <tcp_pkt_create>
801099e0:	83 c4 20             	add    $0x20,%esp
801099e3:	eb 62                	jmp    80109a47 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
801099e5:	83 ec 0c             	sub    $0xc,%esp
801099e8:	6a 00                	push   $0x0
801099ea:	6a 10                	push   $0x10
801099ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099ef:	50                   	push   %eax
801099f0:	ff 75 e8             	push   -0x18(%ebp)
801099f3:	ff 75 08             	push   0x8(%ebp)
801099f6:	e8 c9 00 00 00       	call   80109ac4 <tcp_pkt_create>
801099fb:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
801099fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a01:	83 ec 08             	sub    $0x8,%esp
80109a04:	50                   	push   %eax
80109a05:	ff 75 e8             	push   -0x18(%ebp)
80109a08:	e8 88 f0 ff ff       	call   80108a95 <i8254_send>
80109a0d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a13:	83 c0 36             	add    $0x36,%eax
80109a16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a19:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109a1c:	50                   	push   %eax
80109a1d:	ff 75 e4             	push   -0x1c(%ebp)
80109a20:	6a 00                	push   $0x0
80109a22:	6a 00                	push   $0x0
80109a24:	e8 f6 03 00 00       	call   80109e1f <http_proc>
80109a29:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109a2f:	83 ec 0c             	sub    $0xc,%esp
80109a32:	50                   	push   %eax
80109a33:	6a 18                	push   $0x18
80109a35:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a38:	50                   	push   %eax
80109a39:	ff 75 e8             	push   -0x18(%ebp)
80109a3c:	ff 75 08             	push   0x8(%ebp)
80109a3f:	e8 80 00 00 00       	call   80109ac4 <tcp_pkt_create>
80109a44:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109a47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a4a:	83 ec 08             	sub    $0x8,%esp
80109a4d:	50                   	push   %eax
80109a4e:	ff 75 e8             	push   -0x18(%ebp)
80109a51:	e8 3f f0 ff ff       	call   80108a95 <i8254_send>
80109a56:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a59:	a1 64 72 19 80       	mov    0x80197264,%eax
80109a5e:	83 c0 01             	add    $0x1,%eax
80109a61:	a3 64 72 19 80       	mov    %eax,0x80197264
80109a66:	eb 4a                	jmp    80109ab2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a6b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a6f:	3c 10                	cmp    $0x10,%al
80109a71:	75 3f                	jne    80109ab2 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109a73:	a1 68 72 19 80       	mov    0x80197268,%eax
80109a78:	83 f8 01             	cmp    $0x1,%eax
80109a7b:	75 35                	jne    80109ab2 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109a7d:	83 ec 0c             	sub    $0xc,%esp
80109a80:	6a 00                	push   $0x0
80109a82:	6a 01                	push   $0x1
80109a84:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a87:	50                   	push   %eax
80109a88:	ff 75 e8             	push   -0x18(%ebp)
80109a8b:	ff 75 08             	push   0x8(%ebp)
80109a8e:	e8 31 00 00 00       	call   80109ac4 <tcp_pkt_create>
80109a93:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109a96:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a99:	83 ec 08             	sub    $0x8,%esp
80109a9c:	50                   	push   %eax
80109a9d:	ff 75 e8             	push   -0x18(%ebp)
80109aa0:	e8 f0 ef ff ff       	call   80108a95 <i8254_send>
80109aa5:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109aa8:	c7 05 68 72 19 80 00 	movl   $0x0,0x80197268
80109aaf:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ab5:	83 ec 0c             	sub    $0xc,%esp
80109ab8:	50                   	push   %eax
80109ab9:	e8 48 8c ff ff       	call   80102706 <kfree>
80109abe:	83 c4 10             	add    $0x10,%esp
}
80109ac1:	90                   	nop
80109ac2:	c9                   	leave  
80109ac3:	c3                   	ret    

80109ac4 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ac4:	55                   	push   %ebp
80109ac5:	89 e5                	mov    %esp,%ebp
80109ac7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109aca:	8b 45 08             	mov    0x8(%ebp),%eax
80109acd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad3:	83 c0 0e             	add    $0xe,%eax
80109ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109adc:	0f b6 00             	movzbl (%eax),%eax
80109adf:	0f b6 c0             	movzbl %al,%eax
80109ae2:	83 e0 0f             	and    $0xf,%eax
80109ae5:	c1 e0 02             	shl    $0x2,%eax
80109ae8:	89 c2                	mov    %eax,%edx
80109aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aed:	01 d0                	add    %edx,%eax
80109aef:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109af2:	8b 45 0c             	mov    0xc(%ebp),%eax
80109af5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109af8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109afb:	83 c0 0e             	add    $0xe,%eax
80109afe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109b01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b04:	83 c0 14             	add    $0x14,%eax
80109b07:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109b0a:	8b 45 18             	mov    0x18(%ebp),%eax
80109b0d:	8d 50 36             	lea    0x36(%eax),%edx
80109b10:	8b 45 10             	mov    0x10(%ebp),%eax
80109b13:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b18:	8d 50 06             	lea    0x6(%eax),%edx
80109b1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b1e:	83 ec 04             	sub    $0x4,%esp
80109b21:	6a 06                	push   $0x6
80109b23:	52                   	push   %edx
80109b24:	50                   	push   %eax
80109b25:	e8 1e af ff ff       	call   80104a48 <memmove>
80109b2a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b30:	83 c0 06             	add    $0x6,%eax
80109b33:	83 ec 04             	sub    $0x4,%esp
80109b36:	6a 06                	push   $0x6
80109b38:	68 80 6f 19 80       	push   $0x80196f80
80109b3d:	50                   	push   %eax
80109b3e:	e8 05 af ff ff       	call   80104a48 <memmove>
80109b43:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b49:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b50:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b57:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b5d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109b61:	8b 45 18             	mov    0x18(%ebp),%eax
80109b64:	83 c0 28             	add    $0x28,%eax
80109b67:	0f b7 c0             	movzwl %ax,%eax
80109b6a:	83 ec 0c             	sub    $0xc,%esp
80109b6d:	50                   	push   %eax
80109b6e:	e8 9b f8 ff ff       	call   8010940e <H2N_ushort>
80109b73:	83 c4 10             	add    $0x10,%esp
80109b76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b79:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b7d:	0f b7 15 60 72 19 80 	movzwl 0x80197260,%edx
80109b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b87:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b8b:	0f b7 05 60 72 19 80 	movzwl 0x80197260,%eax
80109b92:	83 c0 01             	add    $0x1,%eax
80109b95:	66 a3 60 72 19 80    	mov    %ax,0x80197260
  ipv4_send->fragment = H2N_ushort(0x0000);
80109b9b:	83 ec 0c             	sub    $0xc,%esp
80109b9e:	6a 00                	push   $0x0
80109ba0:	e8 69 f8 ff ff       	call   8010940e <H2N_ushort>
80109ba5:	83 c4 10             	add    $0x10,%esp
80109ba8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bab:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bb2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109bb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bb9:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc0:	83 c0 0c             	add    $0xc,%eax
80109bc3:	83 ec 04             	sub    $0x4,%esp
80109bc6:	6a 04                	push   $0x4
80109bc8:	68 04 f5 10 80       	push   $0x8010f504
80109bcd:	50                   	push   %eax
80109bce:	e8 75 ae ff ff       	call   80104a48 <memmove>
80109bd3:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd9:	8d 50 0c             	lea    0xc(%eax),%edx
80109bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bdf:	83 c0 10             	add    $0x10,%eax
80109be2:	83 ec 04             	sub    $0x4,%esp
80109be5:	6a 04                	push   $0x4
80109be7:	52                   	push   %edx
80109be8:	50                   	push   %eax
80109be9:	e8 5a ae ff ff       	call   80104a48 <memmove>
80109bee:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109bfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfd:	83 ec 0c             	sub    $0xc,%esp
80109c00:	50                   	push   %eax
80109c01:	e8 08 f9 ff ff       	call   8010950e <ipv4_chksum>
80109c06:	83 c4 10             	add    $0x10,%esp
80109c09:	0f b7 c0             	movzwl %ax,%eax
80109c0c:	83 ec 0c             	sub    $0xc,%esp
80109c0f:	50                   	push   %eax
80109c10:	e8 f9 f7 ff ff       	call   8010940e <H2N_ushort>
80109c15:	83 c4 10             	add    $0x10,%esp
80109c18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c1b:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109c1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c22:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109c26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c29:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c2f:	0f b7 10             	movzwl (%eax),%edx
80109c32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c35:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109c39:	a1 64 72 19 80       	mov    0x80197264,%eax
80109c3e:	83 ec 0c             	sub    $0xc,%esp
80109c41:	50                   	push   %eax
80109c42:	e8 e9 f7 ff ff       	call   80109430 <H2N_uint>
80109c47:	83 c4 10             	add    $0x10,%esp
80109c4a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c4d:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109c50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c53:	8b 40 04             	mov    0x4(%eax),%eax
80109c56:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109c5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c5f:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c65:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109c69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c6c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109c70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c73:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109c77:	8b 45 14             	mov    0x14(%ebp),%eax
80109c7a:	89 c2                	mov    %eax,%edx
80109c7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c7f:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109c82:	83 ec 0c             	sub    $0xc,%esp
80109c85:	68 90 38 00 00       	push   $0x3890
80109c8a:	e8 7f f7 ff ff       	call   8010940e <H2N_ushort>
80109c8f:	83 c4 10             	add    $0x10,%esp
80109c92:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c95:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9c:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ca5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cae:	83 ec 0c             	sub    $0xc,%esp
80109cb1:	50                   	push   %eax
80109cb2:	e8 1f 00 00 00       	call   80109cd6 <tcp_chksum>
80109cb7:	83 c4 10             	add    $0x10,%esp
80109cba:	83 c0 08             	add    $0x8,%eax
80109cbd:	0f b7 c0             	movzwl %ax,%eax
80109cc0:	83 ec 0c             	sub    $0xc,%esp
80109cc3:	50                   	push   %eax
80109cc4:	e8 45 f7 ff ff       	call   8010940e <H2N_ushort>
80109cc9:	83 c4 10             	add    $0x10,%esp
80109ccc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ccf:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109cd3:	90                   	nop
80109cd4:	c9                   	leave  
80109cd5:	c3                   	ret    

80109cd6 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109cd6:	55                   	push   %ebp
80109cd7:	89 e5                	mov    %esp,%ebp
80109cd9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80109cdf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ce5:	83 c0 14             	add    $0x14,%eax
80109ce8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109ceb:	83 ec 04             	sub    $0x4,%esp
80109cee:	6a 04                	push   $0x4
80109cf0:	68 04 f5 10 80       	push   $0x8010f504
80109cf5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109cf8:	50                   	push   %eax
80109cf9:	e8 4a ad ff ff       	call   80104a48 <memmove>
80109cfe:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d04:	83 c0 0c             	add    $0xc,%eax
80109d07:	83 ec 04             	sub    $0x4,%esp
80109d0a:	6a 04                	push   $0x4
80109d0c:	50                   	push   %eax
80109d0d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d10:	83 c0 04             	add    $0x4,%eax
80109d13:	50                   	push   %eax
80109d14:	e8 2f ad ff ff       	call   80104a48 <memmove>
80109d19:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109d1c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109d20:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109d24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d27:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109d2b:	0f b7 c0             	movzwl %ax,%eax
80109d2e:	83 ec 0c             	sub    $0xc,%esp
80109d31:	50                   	push   %eax
80109d32:	e8 b5 f6 ff ff       	call   801093ec <N2H_ushort>
80109d37:	83 c4 10             	add    $0x10,%esp
80109d3a:	83 e8 14             	sub    $0x14,%eax
80109d3d:	0f b7 c0             	movzwl %ax,%eax
80109d40:	83 ec 0c             	sub    $0xc,%esp
80109d43:	50                   	push   %eax
80109d44:	e8 c5 f6 ff ff       	call   8010940e <H2N_ushort>
80109d49:	83 c4 10             	add    $0x10,%esp
80109d4c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109d50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109d57:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109d5d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109d64:	eb 33                	jmp    80109d99 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d69:	01 c0                	add    %eax,%eax
80109d6b:	89 c2                	mov    %eax,%edx
80109d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d70:	01 d0                	add    %edx,%eax
80109d72:	0f b6 00             	movzbl (%eax),%eax
80109d75:	0f b6 c0             	movzbl %al,%eax
80109d78:	c1 e0 08             	shl    $0x8,%eax
80109d7b:	89 c2                	mov    %eax,%edx
80109d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d80:	01 c0                	add    %eax,%eax
80109d82:	8d 48 01             	lea    0x1(%eax),%ecx
80109d85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d88:	01 c8                	add    %ecx,%eax
80109d8a:	0f b6 00             	movzbl (%eax),%eax
80109d8d:	0f b6 c0             	movzbl %al,%eax
80109d90:	01 d0                	add    %edx,%eax
80109d92:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109d95:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109d99:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109d9d:	7e c7                	jle    80109d66 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109da2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109da5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109dac:	eb 33                	jmp    80109de1 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109db1:	01 c0                	add    %eax,%eax
80109db3:	89 c2                	mov    %eax,%edx
80109db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db8:	01 d0                	add    %edx,%eax
80109dba:	0f b6 00             	movzbl (%eax),%eax
80109dbd:	0f b6 c0             	movzbl %al,%eax
80109dc0:	c1 e0 08             	shl    $0x8,%eax
80109dc3:	89 c2                	mov    %eax,%edx
80109dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dc8:	01 c0                	add    %eax,%eax
80109dca:	8d 48 01             	lea    0x1(%eax),%ecx
80109dcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd0:	01 c8                	add    %ecx,%eax
80109dd2:	0f b6 00             	movzbl (%eax),%eax
80109dd5:	0f b6 c0             	movzbl %al,%eax
80109dd8:	01 d0                	add    %edx,%eax
80109dda:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ddd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109de1:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109de5:	0f b7 c0             	movzwl %ax,%eax
80109de8:	83 ec 0c             	sub    $0xc,%esp
80109deb:	50                   	push   %eax
80109dec:	e8 fb f5 ff ff       	call   801093ec <N2H_ushort>
80109df1:	83 c4 10             	add    $0x10,%esp
80109df4:	66 d1 e8             	shr    %ax
80109df7:	0f b7 c0             	movzwl %ax,%eax
80109dfa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109dfd:	7c af                	jl     80109dae <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e02:	c1 e8 10             	shr    $0x10,%eax
80109e05:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0b:	f7 d0                	not    %eax
}
80109e0d:	c9                   	leave  
80109e0e:	c3                   	ret    

80109e0f <tcp_fin>:

void tcp_fin(){
80109e0f:	55                   	push   %ebp
80109e10:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109e12:	c7 05 68 72 19 80 01 	movl   $0x1,0x80197268
80109e19:	00 00 00 
}
80109e1c:	90                   	nop
80109e1d:	5d                   	pop    %ebp
80109e1e:	c3                   	ret    

80109e1f <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109e1f:	55                   	push   %ebp
80109e20:	89 e5                	mov    %esp,%ebp
80109e22:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109e25:	8b 45 10             	mov    0x10(%ebp),%eax
80109e28:	83 ec 04             	sub    $0x4,%esp
80109e2b:	6a 00                	push   $0x0
80109e2d:	68 6b bf 10 80       	push   $0x8010bf6b
80109e32:	50                   	push   %eax
80109e33:	e8 65 00 00 00       	call   80109e9d <http_strcpy>
80109e38:	83 c4 10             	add    $0x10,%esp
80109e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109e3e:	8b 45 10             	mov    0x10(%ebp),%eax
80109e41:	83 ec 04             	sub    $0x4,%esp
80109e44:	ff 75 f4             	push   -0xc(%ebp)
80109e47:	68 7e bf 10 80       	push   $0x8010bf7e
80109e4c:	50                   	push   %eax
80109e4d:	e8 4b 00 00 00       	call   80109e9d <http_strcpy>
80109e52:	83 c4 10             	add    $0x10,%esp
80109e55:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109e58:	8b 45 10             	mov    0x10(%ebp),%eax
80109e5b:	83 ec 04             	sub    $0x4,%esp
80109e5e:	ff 75 f4             	push   -0xc(%ebp)
80109e61:	68 99 bf 10 80       	push   $0x8010bf99
80109e66:	50                   	push   %eax
80109e67:	e8 31 00 00 00       	call   80109e9d <http_strcpy>
80109e6c:	83 c4 10             	add    $0x10,%esp
80109e6f:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e75:	83 e0 01             	and    $0x1,%eax
80109e78:	85 c0                	test   %eax,%eax
80109e7a:	74 11                	je     80109e8d <http_proc+0x6e>
    char *payload = (char *)send;
80109e7c:	8b 45 10             	mov    0x10(%ebp),%eax
80109e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109e82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e88:	01 d0                	add    %edx,%eax
80109e8a:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109e8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e90:	8b 45 14             	mov    0x14(%ebp),%eax
80109e93:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109e95:	e8 75 ff ff ff       	call   80109e0f <tcp_fin>
}
80109e9a:	90                   	nop
80109e9b:	c9                   	leave  
80109e9c:	c3                   	ret    

80109e9d <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109e9d:	55                   	push   %ebp
80109e9e:	89 e5                	mov    %esp,%ebp
80109ea0:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109ea3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109eaa:	eb 20                	jmp    80109ecc <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109eac:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109eb2:	01 d0                	add    %edx,%eax
80109eb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109eb7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109eba:	01 ca                	add    %ecx,%edx
80109ebc:	89 d1                	mov    %edx,%ecx
80109ebe:	8b 55 08             	mov    0x8(%ebp),%edx
80109ec1:	01 ca                	add    %ecx,%edx
80109ec3:	0f b6 00             	movzbl (%eax),%eax
80109ec6:	88 02                	mov    %al,(%edx)
    i++;
80109ec8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109ecc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ed2:	01 d0                	add    %edx,%eax
80109ed4:	0f b6 00             	movzbl (%eax),%eax
80109ed7:	84 c0                	test   %al,%al
80109ed9:	75 d1                	jne    80109eac <http_strcpy+0xf>
  }
  return i;
80109edb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109ede:	c9                   	leave  
80109edf:	c3                   	ret    

80109ee0 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109ee0:	55                   	push   %ebp
80109ee1:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109ee3:	c7 05 70 72 19 80 c2 	movl   $0x8010f5c2,0x80197270
80109eea:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109eed:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109ef2:	c1 e8 09             	shr    $0x9,%eax
80109ef5:	a3 6c 72 19 80       	mov    %eax,0x8019726c
}
80109efa:	90                   	nop
80109efb:	5d                   	pop    %ebp
80109efc:	c3                   	ret    

80109efd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109efd:	55                   	push   %ebp
80109efe:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109f00:	90                   	nop
80109f01:	5d                   	pop    %ebp
80109f02:	c3                   	ret    

80109f03 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109f03:	55                   	push   %ebp
80109f04:	89 e5                	mov    %esp,%ebp
80109f06:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109f09:	8b 45 08             	mov    0x8(%ebp),%eax
80109f0c:	83 c0 0c             	add    $0xc,%eax
80109f0f:	83 ec 0c             	sub    $0xc,%esp
80109f12:	50                   	push   %eax
80109f13:	e8 6a a7 ff ff       	call   80104682 <holdingsleep>
80109f18:	83 c4 10             	add    $0x10,%esp
80109f1b:	85 c0                	test   %eax,%eax
80109f1d:	75 0d                	jne    80109f2c <iderw+0x29>
    panic("iderw: buf not locked");
80109f1f:	83 ec 0c             	sub    $0xc,%esp
80109f22:	68 aa bf 10 80       	push   $0x8010bfaa
80109f27:	e8 7d 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f2f:	8b 00                	mov    (%eax),%eax
80109f31:	83 e0 06             	and    $0x6,%eax
80109f34:	83 f8 02             	cmp    $0x2,%eax
80109f37:	75 0d                	jne    80109f46 <iderw+0x43>
    panic("iderw: nothing to do");
80109f39:	83 ec 0c             	sub    $0xc,%esp
80109f3c:	68 c0 bf 10 80       	push   $0x8010bfc0
80109f41:	e8 63 66 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109f46:	8b 45 08             	mov    0x8(%ebp),%eax
80109f49:	8b 40 04             	mov    0x4(%eax),%eax
80109f4c:	83 f8 01             	cmp    $0x1,%eax
80109f4f:	74 0d                	je     80109f5e <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109f51:	83 ec 0c             	sub    $0xc,%esp
80109f54:	68 d5 bf 10 80       	push   $0x8010bfd5
80109f59:	e8 4b 66 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109f61:	8b 40 08             	mov    0x8(%eax),%eax
80109f64:	8b 15 6c 72 19 80    	mov    0x8019726c,%edx
80109f6a:	39 d0                	cmp    %edx,%eax
80109f6c:	72 0d                	jb     80109f7b <iderw+0x78>
    panic("iderw: block out of range");
80109f6e:	83 ec 0c             	sub    $0xc,%esp
80109f71:	68 f3 bf 10 80       	push   $0x8010bff3
80109f76:	e8 2e 66 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109f7b:	8b 15 70 72 19 80    	mov    0x80197270,%edx
80109f81:	8b 45 08             	mov    0x8(%ebp),%eax
80109f84:	8b 40 08             	mov    0x8(%eax),%eax
80109f87:	c1 e0 09             	shl    $0x9,%eax
80109f8a:	01 d0                	add    %edx,%eax
80109f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f92:	8b 00                	mov    (%eax),%eax
80109f94:	83 e0 04             	and    $0x4,%eax
80109f97:	85 c0                	test   %eax,%eax
80109f99:	74 2b                	je     80109fc6 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
80109f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9e:	8b 00                	mov    (%eax),%eax
80109fa0:	83 e0 fb             	and    $0xfffffffb,%eax
80109fa3:	89 c2                	mov    %eax,%edx
80109fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa8:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
80109faa:	8b 45 08             	mov    0x8(%ebp),%eax
80109fad:	83 c0 5c             	add    $0x5c,%eax
80109fb0:	83 ec 04             	sub    $0x4,%esp
80109fb3:	68 00 02 00 00       	push   $0x200
80109fb8:	50                   	push   %eax
80109fb9:	ff 75 f4             	push   -0xc(%ebp)
80109fbc:	e8 87 aa ff ff       	call   80104a48 <memmove>
80109fc1:	83 c4 10             	add    $0x10,%esp
80109fc4:	eb 1a                	jmp    80109fe0 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
80109fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80109fc9:	83 c0 5c             	add    $0x5c,%eax
80109fcc:	83 ec 04             	sub    $0x4,%esp
80109fcf:	68 00 02 00 00       	push   $0x200
80109fd4:	ff 75 f4             	push   -0xc(%ebp)
80109fd7:	50                   	push   %eax
80109fd8:	e8 6b aa ff ff       	call   80104a48 <memmove>
80109fdd:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
80109fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe3:	8b 00                	mov    (%eax),%eax
80109fe5:	83 c8 02             	or     $0x2,%eax
80109fe8:	89 c2                	mov    %eax,%edx
80109fea:	8b 45 08             	mov    0x8(%ebp),%eax
80109fed:	89 10                	mov    %edx,(%eax)
}
80109fef:	90                   	nop
80109ff0:	c9                   	leave  
80109ff1:	c3                   	ret    
