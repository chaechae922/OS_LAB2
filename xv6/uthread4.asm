
_uthread4:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p  next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 60 0e 00 00 	movl   $0xe60,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 40 0e 00 00       	mov    0xe40,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 44 0e 00 00       	mov    %eax,0xe44
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 00 4f 01 00       	mov    $0x14f00,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 00 4f 01 00       	mov    $0x14f00,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 40 0e 00 00       	mov    0xe40,%eax
  5b:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 40 0e 00 00       	mov    0xe40,%eax
  6b:	a3 44 0e 00 00       	mov    %eax,0xe44
  }

  if (next_thread == 0) {
  70:	a1 44 0e 00 00       	mov    0xe44,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 74 0a 00 00       	push   $0xa74
  81:	6a 02                	push   $0x2
  83:	e8 32 06 00 00       	call   6ba <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 b6 04 00 00       	call   546 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 40 0e 00 00    	mov    0xe40,%edx
  96:	a1 44 0e 00 00       	mov    0xe44,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 44 0e 00 00       	mov    0xe44,%eax
  a4:	c7 80 0c 20 00 00 01 	movl   $0x1,0x200c(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 40 0e 00 00       	mov    0xe40,%eax
  b3:	c7 80 0c 20 00 00 02 	movl   $0x2,0x200c(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 17 02 00 00       	call   2d9 <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
  cb:	00 00 00 
}
  ce:	90                   	nop
  cf:	c9                   	leave  
  d0:	c3                   	ret    

000000d1 <thread_init>:

void 
thread_init(void)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 08             	sub    $0x8,%esp
  uthread_init(thread_schedule);
  d7:	83 ec 0c             	sub    $0xc,%esp
  da:	68 00 00 00 00       	push   $0x0
  df:	e8 fa 04 00 00       	call   5de <uthread_init>
  e4:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  e7:	c7 05 40 0e 00 00 60 	movl   $0xe60,0xe40
  ee:	0e 00 00 
  current_thread->state = RUNNING;
  f1:	a1 40 0e 00 00       	mov    0xe40,%eax
  f6:	c7 80 0c 20 00 00 01 	movl   $0x1,0x200c(%eax)
  fd:	00 00 00 
  current_thread->tid=0;
 100:	a1 40 0e 00 00       	mov    0xe40,%eax
 105:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  current_thread->ptid=0;
 10b:	a1 40 0e 00 00       	mov    0xe40,%eax
 110:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
}
 117:	90                   	nop
 118:	c9                   	leave  
 119:	c3                   	ret    

0000011a <thread_create>:

int 
thread_create(void (*func)())
{
 11a:	55                   	push   %ebp
 11b:	89 e5                	mov    %esp,%ebp
 11d:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 120:	c7 45 fc 60 0e 00 00 	movl   $0xe60,-0x4(%ebp)
 127:	eb 14                	jmp    13d <thread_create+0x23>
    if (t->state == FREE) break;
 129:	8b 45 fc             	mov    -0x4(%ebp),%eax
 12c:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 132:	85 c0                	test   %eax,%eax
 134:	74 13                	je     149 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 136:	81 45 fc 10 20 00 00 	addl   $0x2010,-0x4(%ebp)
 13d:	b8 00 4f 01 00       	mov    $0x14f00,%eax
 142:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 145:	72 e2                	jb     129 <thread_create+0xf>
 147:	eb 01                	jmp    14a <thread_create+0x30>
    if (t->state == FREE) break;
 149:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 14a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 14d:	83 c0 0c             	add    $0xc,%eax
 150:	05 00 20 00 00       	add    $0x2000,%eax
 155:	89 c2                	mov    %eax,%edx
 157:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15a:	89 50 08             	mov    %edx,0x8(%eax)
  t->sp -= 4;                              // space for return address
 15d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 160:	8b 40 08             	mov    0x8(%eax),%eax
 163:	8d 50 fc             	lea    -0x4(%eax),%edx
 166:	8b 45 fc             	mov    -0x4(%ebp),%eax
 169:	89 50 08             	mov    %edx,0x8(%eax)
  /* 
    set tid and ptid
  */
  * (int *) (t->sp) = (int)func;           // push return address on stack
 16c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16f:	8b 40 08             	mov    0x8(%eax),%eax
 172:	89 c2                	mov    %eax,%edx
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 179:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17c:	8b 40 08             	mov    0x8(%eax),%eax
 17f:	8d 50 e0             	lea    -0x20(%eax),%edx
 182:	8b 45 fc             	mov    -0x4(%ebp),%eax
 185:	89 50 08             	mov    %edx,0x8(%eax)
  t->state = RUNNABLE;
 188:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18b:	c7 80 0c 20 00 00 02 	movl   $0x2,0x200c(%eax)
 192:	00 00 00 
  
  return t->tid;
 195:	8b 45 fc             	mov    -0x4(%ebp),%eax
 198:	8b 00                	mov    (%eax),%eax
}
 19a:	c9                   	leave  
 19b:	c3                   	ret    

0000019c <thread_join>:

static void 
thread_join(int tid)
{
 19c:	55                   	push   %ebp
 19d:	89 e5                	mov    %esp,%ebp
  /*
    returns when the child thread tid has exited.
  */
}
 19f:	90                   	nop
 1a0:	5d                   	pop    %ebp
 1a1:	c3                   	ret    

000001a2 <child_thread>:

static void 
child_thread(void)
{
 1a2:	55                   	push   %ebp
 1a3:	89 e5                	mov    %esp,%ebp
 1a5:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 1a8:	83 ec 08             	sub    $0x8,%esp
 1ab:	68 9a 0a 00 00       	push   $0xa9a
 1b0:	6a 01                	push   $0x1
 1b2:	e8 03 05 00 00       	call   6ba <printf>
 1b7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1c1:	eb 1c                	jmp    1df <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int) current_thread);
 1c3:	a1 40 0e 00 00       	mov    0xe40,%eax
 1c8:	83 ec 04             	sub    $0x4,%esp
 1cb:	50                   	push   %eax
 1cc:	68 b0 0a 00 00       	push   $0xab0
 1d1:	6a 01                	push   $0x1
 1d3:	e8 e2 04 00 00       	call   6ba <printf>
 1d8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1df:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1e3:	7e de                	jle    1c3 <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 1e5:	83 ec 08             	sub    $0x8,%esp
 1e8:	68 c3 0a 00 00       	push   $0xac3
 1ed:	6a 01                	push   $0x1
 1ef:	e8 c6 04 00 00       	call   6ba <printf>
 1f4:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1f7:	a1 40 0e 00 00       	mov    0xe40,%eax
 1fc:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 203:	00 00 00 
}
 206:	90                   	nop
 207:	c9                   	leave  
 208:	c3                   	ret    

00000209 <mythread>:

static void 
mythread(void)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	83 ec 28             	sub    $0x28,%esp
  int i;
  int tid[5];

  printf(1, "my thread running\n");
 20f:	83 ec 08             	sub    $0x8,%esp
 212:	68 d7 0a 00 00       	push   $0xad7
 217:	6a 01                	push   $0x1
 219:	e8 9c 04 00 00       	call   6ba <printf>
 21e:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < 5; i++) {
 221:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 228:	eb 1b                	jmp    245 <mythread+0x3c>
    tid[i]=thread_create(child_thread);
 22a:	83 ec 0c             	sub    $0xc,%esp
 22d:	68 a2 01 00 00       	push   $0x1a2
 232:	e8 e3 fe ff ff       	call   11a <thread_create>
 237:	83 c4 10             	add    $0x10,%esp
 23a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 23d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
  for (i = 0; i < 5; i++) {
 241:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 245:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 249:	7e df                	jle    22a <mythread+0x21>
  }
  
  for (i = 0; i < 5; i++) {
 24b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 252:	eb 17                	jmp    26b <mythread+0x62>
    thread_join(tid[i]);
 254:	8b 45 f4             	mov    -0xc(%ebp),%eax
 257:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 25b:	83 ec 0c             	sub    $0xc,%esp
 25e:	50                   	push   %eax
 25f:	e8 38 ff ff ff       	call   19c <thread_join>
 264:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 267:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 26b:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 26f:	7e e3                	jle    254 <mythread+0x4b>
  }
  
  printf(1, "my thread: exit\n");
 271:	83 ec 08             	sub    $0x8,%esp
 274:	68 ea 0a 00 00       	push   $0xaea
 279:	6a 01                	push   $0x1
 27b:	e8 3a 04 00 00       	call   6ba <printf>
 280:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 283:	a1 40 0e 00 00       	mov    0xe40,%eax
 288:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 28f:	00 00 00 
}
 292:	90                   	nop
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <main>:

int 
main(int argc, char *argv[]) 
{
 295:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 299:	83 e4 f0             	and    $0xfffffff0,%esp
 29c:	ff 71 fc             	push   -0x4(%ecx)
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	51                   	push   %ecx
 2a3:	83 ec 14             	sub    $0x14,%esp
  int tid;
  thread_init();
 2a6:	e8 26 fe ff ff       	call   d1 <thread_init>
  tid=thread_create(mythread);
 2ab:	83 ec 0c             	sub    $0xc,%esp
 2ae:	68 09 02 00 00       	push   $0x209
 2b3:	e8 62 fe ff ff       	call   11a <thread_create>
 2b8:	83 c4 10             	add    $0x10,%esp
 2bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  thread_join(tid);
 2be:	83 ec 0c             	sub    $0xc,%esp
 2c1:	ff 75 f4             	push   -0xc(%ebp)
 2c4:	e8 d3 fe ff ff       	call   19c <thread_join>
 2c9:	83 c4 10             	add    $0x10,%esp
  return 0;
 2cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d1:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2d4:	c9                   	leave  
 2d5:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2d8:	c3                   	ret    

000002d9 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 2d9:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 2da:	a1 40 0e 00 00       	mov    0xe40,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 2df:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 2e1:	a1 44 0e 00 00       	mov    0xe44,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 2e6:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 2e8:	a3 40 0e 00 00       	mov    %eax,0xe40
    popal
 2ed:	61                   	popa   
    
    # return to next thread's stack context
 2ee:	c3                   	ret    

000002ef <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2ef:	55                   	push   %ebp
 2f0:	89 e5                	mov    %esp,%ebp
 2f2:	57                   	push   %edi
 2f3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2f7:	8b 55 10             	mov    0x10(%ebp),%edx
 2fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fd:	89 cb                	mov    %ecx,%ebx
 2ff:	89 df                	mov    %ebx,%edi
 301:	89 d1                	mov    %edx,%ecx
 303:	fc                   	cld    
 304:	f3 aa                	rep stos %al,%es:(%edi)
 306:	89 ca                	mov    %ecx,%edx
 308:	89 fb                	mov    %edi,%ebx
 30a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 30d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 310:	90                   	nop
 311:	5b                   	pop    %ebx
 312:	5f                   	pop    %edi
 313:	5d                   	pop    %ebp
 314:	c3                   	ret    

00000315 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 315:	55                   	push   %ebp
 316:	89 e5                	mov    %esp,%ebp
 318:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 321:	90                   	nop
 322:	8b 55 0c             	mov    0xc(%ebp),%edx
 325:	8d 42 01             	lea    0x1(%edx),%eax
 328:	89 45 0c             	mov    %eax,0xc(%ebp)
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	8d 48 01             	lea    0x1(%eax),%ecx
 331:	89 4d 08             	mov    %ecx,0x8(%ebp)
 334:	0f b6 12             	movzbl (%edx),%edx
 337:	88 10                	mov    %dl,(%eax)
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	84 c0                	test   %al,%al
 33e:	75 e2                	jne    322 <strcpy+0xd>
    ;
  return os;
 340:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 343:	c9                   	leave  
 344:	c3                   	ret    

00000345 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 345:	55                   	push   %ebp
 346:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 348:	eb 08                	jmp    352 <strcmp+0xd>
    p++, q++;
 34a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 352:	8b 45 08             	mov    0x8(%ebp),%eax
 355:	0f b6 00             	movzbl (%eax),%eax
 358:	84 c0                	test   %al,%al
 35a:	74 10                	je     36c <strcmp+0x27>
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	0f b6 10             	movzbl (%eax),%edx
 362:	8b 45 0c             	mov    0xc(%ebp),%eax
 365:	0f b6 00             	movzbl (%eax),%eax
 368:	38 c2                	cmp    %al,%dl
 36a:	74 de                	je     34a <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	0f b6 00             	movzbl (%eax),%eax
 372:	0f b6 d0             	movzbl %al,%edx
 375:	8b 45 0c             	mov    0xc(%ebp),%eax
 378:	0f b6 00             	movzbl (%eax),%eax
 37b:	0f b6 c8             	movzbl %al,%ecx
 37e:	89 d0                	mov    %edx,%eax
 380:	29 c8                	sub    %ecx,%eax
}
 382:	5d                   	pop    %ebp
 383:	c3                   	ret    

00000384 <strlen>:

uint
strlen(char *s)
{
 384:	55                   	push   %ebp
 385:	89 e5                	mov    %esp,%ebp
 387:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 38a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 391:	eb 04                	jmp    397 <strlen+0x13>
 393:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 397:	8b 55 fc             	mov    -0x4(%ebp),%edx
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	01 d0                	add    %edx,%eax
 39f:	0f b6 00             	movzbl (%eax),%eax
 3a2:	84 c0                	test   %al,%al
 3a4:	75 ed                	jne    393 <strlen+0xf>
    ;
  return n;
 3a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a9:	c9                   	leave  
 3aa:	c3                   	ret    

000003ab <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ab:	55                   	push   %ebp
 3ac:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ae:	8b 45 10             	mov    0x10(%ebp),%eax
 3b1:	50                   	push   %eax
 3b2:	ff 75 0c             	push   0xc(%ebp)
 3b5:	ff 75 08             	push   0x8(%ebp)
 3b8:	e8 32 ff ff ff       	call   2ef <stosb>
 3bd:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c3:	c9                   	leave  
 3c4:	c3                   	ret    

000003c5 <strchr>:

char*
strchr(const char *s, char c)
{
 3c5:	55                   	push   %ebp
 3c6:	89 e5                	mov    %esp,%ebp
 3c8:	83 ec 04             	sub    $0x4,%esp
 3cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ce:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3d1:	eb 14                	jmp    3e7 <strchr+0x22>
    if(*s == c)
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3dc:	75 05                	jne    3e3 <strchr+0x1e>
      return (char*)s;
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
 3e1:	eb 13                	jmp    3f6 <strchr+0x31>
  for(; *s; s++)
 3e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	0f b6 00             	movzbl (%eax),%eax
 3ed:	84 c0                	test   %al,%al
 3ef:	75 e2                	jne    3d3 <strchr+0xe>
  return 0;
 3f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3f6:	c9                   	leave  
 3f7:	c3                   	ret    

000003f8 <gets>:

char*
gets(char *buf, int max)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 405:	eb 42                	jmp    449 <gets+0x51>
    cc = read(0, &c, 1);
 407:	83 ec 04             	sub    $0x4,%esp
 40a:	6a 01                	push   $0x1
 40c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 40f:	50                   	push   %eax
 410:	6a 00                	push   $0x0
 412:	e8 47 01 00 00       	call   55e <read>
 417:	83 c4 10             	add    $0x10,%esp
 41a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 41d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 421:	7e 33                	jle    456 <gets+0x5e>
      break;
    buf[i++] = c;
 423:	8b 45 f4             	mov    -0xc(%ebp),%eax
 426:	8d 50 01             	lea    0x1(%eax),%edx
 429:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42c:	89 c2                	mov    %eax,%edx
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
 431:	01 c2                	add    %eax,%edx
 433:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 437:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 439:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 43d:	3c 0a                	cmp    $0xa,%al
 43f:	74 16                	je     457 <gets+0x5f>
 441:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 445:	3c 0d                	cmp    $0xd,%al
 447:	74 0e                	je     457 <gets+0x5f>
  for(i=0; i+1 < max; ){
 449:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44c:	83 c0 01             	add    $0x1,%eax
 44f:	39 45 0c             	cmp    %eax,0xc(%ebp)
 452:	7f b3                	jg     407 <gets+0xf>
 454:	eb 01                	jmp    457 <gets+0x5f>
      break;
 456:	90                   	nop
      break;
  }
  buf[i] = '\0';
 457:	8b 55 f4             	mov    -0xc(%ebp),%edx
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	01 d0                	add    %edx,%eax
 45f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 462:	8b 45 08             	mov    0x8(%ebp),%eax
}
 465:	c9                   	leave  
 466:	c3                   	ret    

00000467 <stat>:

int
stat(char *n, struct stat *st)
{
 467:	55                   	push   %ebp
 468:	89 e5                	mov    %esp,%ebp
 46a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 46d:	83 ec 08             	sub    $0x8,%esp
 470:	6a 00                	push   $0x0
 472:	ff 75 08             	push   0x8(%ebp)
 475:	e8 14 01 00 00       	call   58e <open>
 47a:	83 c4 10             	add    $0x10,%esp
 47d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 480:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 484:	79 07                	jns    48d <stat+0x26>
    return -1;
 486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 48b:	eb 25                	jmp    4b2 <stat+0x4b>
  r = fstat(fd, st);
 48d:	83 ec 08             	sub    $0x8,%esp
 490:	ff 75 0c             	push   0xc(%ebp)
 493:	ff 75 f4             	push   -0xc(%ebp)
 496:	e8 0b 01 00 00       	call   5a6 <fstat>
 49b:	83 c4 10             	add    $0x10,%esp
 49e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4a1:	83 ec 0c             	sub    $0xc,%esp
 4a4:	ff 75 f4             	push   -0xc(%ebp)
 4a7:	e8 c2 00 00 00       	call   56e <close>
 4ac:	83 c4 10             	add    $0x10,%esp
  return r;
 4af:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4b2:	c9                   	leave  
 4b3:	c3                   	ret    

000004b4 <atoi>:

int
atoi(const char *s)
{
 4b4:	55                   	push   %ebp
 4b5:	89 e5                	mov    %esp,%ebp
 4b7:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4c1:	eb 25                	jmp    4e8 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4c6:	89 d0                	mov    %edx,%eax
 4c8:	c1 e0 02             	shl    $0x2,%eax
 4cb:	01 d0                	add    %edx,%eax
 4cd:	01 c0                	add    %eax,%eax
 4cf:	89 c1                	mov    %eax,%ecx
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	8d 50 01             	lea    0x1(%eax),%edx
 4d7:	89 55 08             	mov    %edx,0x8(%ebp)
 4da:	0f b6 00             	movzbl (%eax),%eax
 4dd:	0f be c0             	movsbl %al,%eax
 4e0:	01 c8                	add    %ecx,%eax
 4e2:	83 e8 30             	sub    $0x30,%eax
 4e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	0f b6 00             	movzbl (%eax),%eax
 4ee:	3c 2f                	cmp    $0x2f,%al
 4f0:	7e 0a                	jle    4fc <atoi+0x48>
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
 4f5:	0f b6 00             	movzbl (%eax),%eax
 4f8:	3c 39                	cmp    $0x39,%al
 4fa:	7e c7                	jle    4c3 <atoi+0xf>
  return n;
 4fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4ff:	c9                   	leave  
 500:	c3                   	ret    

00000501 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 501:	55                   	push   %ebp
 502:	89 e5                	mov    %esp,%ebp
 504:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 507:	8b 45 08             	mov    0x8(%ebp),%eax
 50a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 50d:	8b 45 0c             	mov    0xc(%ebp),%eax
 510:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 513:	eb 17                	jmp    52c <memmove+0x2b>
    *dst++ = *src++;
 515:	8b 55 f8             	mov    -0x8(%ebp),%edx
 518:	8d 42 01             	lea    0x1(%edx),%eax
 51b:	89 45 f8             	mov    %eax,-0x8(%ebp)
 51e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 521:	8d 48 01             	lea    0x1(%eax),%ecx
 524:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 527:	0f b6 12             	movzbl (%edx),%edx
 52a:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 52c:	8b 45 10             	mov    0x10(%ebp),%eax
 52f:	8d 50 ff             	lea    -0x1(%eax),%edx
 532:	89 55 10             	mov    %edx,0x10(%ebp)
 535:	85 c0                	test   %eax,%eax
 537:	7f dc                	jg     515 <memmove+0x14>
  return vdst;
 539:	8b 45 08             	mov    0x8(%ebp),%eax
}
 53c:	c9                   	leave  
 53d:	c3                   	ret    

0000053e <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 53e:	b8 01 00 00 00       	mov    $0x1,%eax
 543:	cd 40                	int    $0x40
 545:	c3                   	ret    

00000546 <exit>:
SYSCALL(exit)
 546:	b8 02 00 00 00       	mov    $0x2,%eax
 54b:	cd 40                	int    $0x40
 54d:	c3                   	ret    

0000054e <wait>:
SYSCALL(wait)
 54e:	b8 03 00 00 00       	mov    $0x3,%eax
 553:	cd 40                	int    $0x40
 555:	c3                   	ret    

00000556 <pipe>:
SYSCALL(pipe)
 556:	b8 04 00 00 00       	mov    $0x4,%eax
 55b:	cd 40                	int    $0x40
 55d:	c3                   	ret    

0000055e <read>:
SYSCALL(read)
 55e:	b8 05 00 00 00       	mov    $0x5,%eax
 563:	cd 40                	int    $0x40
 565:	c3                   	ret    

00000566 <write>:
SYSCALL(write)
 566:	b8 10 00 00 00       	mov    $0x10,%eax
 56b:	cd 40                	int    $0x40
 56d:	c3                   	ret    

0000056e <close>:
SYSCALL(close)
 56e:	b8 15 00 00 00       	mov    $0x15,%eax
 573:	cd 40                	int    $0x40
 575:	c3                   	ret    

00000576 <kill>:
SYSCALL(kill)
 576:	b8 06 00 00 00       	mov    $0x6,%eax
 57b:	cd 40                	int    $0x40
 57d:	c3                   	ret    

0000057e <dup>:
SYSCALL(dup)
 57e:	b8 0a 00 00 00       	mov    $0xa,%eax
 583:	cd 40                	int    $0x40
 585:	c3                   	ret    

00000586 <exec>:
SYSCALL(exec)
 586:	b8 07 00 00 00       	mov    $0x7,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret    

0000058e <open>:
SYSCALL(open)
 58e:	b8 0f 00 00 00       	mov    $0xf,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret    

00000596 <mknod>:
SYSCALL(mknod)
 596:	b8 11 00 00 00       	mov    $0x11,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret    

0000059e <unlink>:
SYSCALL(unlink)
 59e:	b8 12 00 00 00       	mov    $0x12,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret    

000005a6 <fstat>:
SYSCALL(fstat)
 5a6:	b8 08 00 00 00       	mov    $0x8,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret    

000005ae <link>:
SYSCALL(link)
 5ae:	b8 13 00 00 00       	mov    $0x13,%eax
 5b3:	cd 40                	int    $0x40
 5b5:	c3                   	ret    

000005b6 <mkdir>:
SYSCALL(mkdir)
 5b6:	b8 14 00 00 00       	mov    $0x14,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret    

000005be <chdir>:
SYSCALL(chdir)
 5be:	b8 09 00 00 00       	mov    $0x9,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret    

000005c6 <sbrk>:
SYSCALL(sbrk)
 5c6:	b8 0c 00 00 00       	mov    $0xc,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret    

000005ce <sleep>:
SYSCALL(sleep)
 5ce:	b8 0d 00 00 00       	mov    $0xd,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <getpid>:
SYSCALL(getpid)
 5d6:	b8 0b 00 00 00       	mov    $0xb,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <uthread_init>:
SYSCALL(uthread_init)
 5de:	b8 18 00 00 00       	mov    $0x18,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e6:	55                   	push   %ebp
 5e7:	89 e5                	mov    %esp,%ebp
 5e9:	83 ec 18             	sub    $0x18,%esp
 5ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ef:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5f2:	83 ec 04             	sub    $0x4,%esp
 5f5:	6a 01                	push   $0x1
 5f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5fa:	50                   	push   %eax
 5fb:	ff 75 08             	push   0x8(%ebp)
 5fe:	e8 63 ff ff ff       	call   566 <write>
 603:	83 c4 10             	add    $0x10,%esp
}
 606:	90                   	nop
 607:	c9                   	leave  
 608:	c3                   	ret    

00000609 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 60f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 616:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 61a:	74 17                	je     633 <printint+0x2a>
 61c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 620:	79 11                	jns    633 <printint+0x2a>
    neg = 1;
 622:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 629:	8b 45 0c             	mov    0xc(%ebp),%eax
 62c:	f7 d8                	neg    %eax
 62e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 631:	eb 06                	jmp    639 <printint+0x30>
  } else {
    x = xx;
 633:	8b 45 0c             	mov    0xc(%ebp),%eax
 636:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 639:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 640:	8b 4d 10             	mov    0x10(%ebp),%ecx
 643:	8b 45 ec             	mov    -0x14(%ebp),%eax
 646:	ba 00 00 00 00       	mov    $0x0,%edx
 64b:	f7 f1                	div    %ecx
 64d:	89 d1                	mov    %edx,%ecx
 64f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 652:	8d 50 01             	lea    0x1(%eax),%edx
 655:	89 55 f4             	mov    %edx,-0xc(%ebp)
 658:	0f b6 91 10 0e 00 00 	movzbl 0xe10(%ecx),%edx
 65f:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 663:	8b 4d 10             	mov    0x10(%ebp),%ecx
 666:	8b 45 ec             	mov    -0x14(%ebp),%eax
 669:	ba 00 00 00 00       	mov    $0x0,%edx
 66e:	f7 f1                	div    %ecx
 670:	89 45 ec             	mov    %eax,-0x14(%ebp)
 673:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 677:	75 c7                	jne    640 <printint+0x37>
  if(neg)
 679:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 67d:	74 2d                	je     6ac <printint+0xa3>
    buf[i++] = '-';
 67f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 682:	8d 50 01             	lea    0x1(%eax),%edx
 685:	89 55 f4             	mov    %edx,-0xc(%ebp)
 688:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 68d:	eb 1d                	jmp    6ac <printint+0xa3>
    putc(fd, buf[i]);
 68f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 692:	8b 45 f4             	mov    -0xc(%ebp),%eax
 695:	01 d0                	add    %edx,%eax
 697:	0f b6 00             	movzbl (%eax),%eax
 69a:	0f be c0             	movsbl %al,%eax
 69d:	83 ec 08             	sub    $0x8,%esp
 6a0:	50                   	push   %eax
 6a1:	ff 75 08             	push   0x8(%ebp)
 6a4:	e8 3d ff ff ff       	call   5e6 <putc>
 6a9:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6ac:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b4:	79 d9                	jns    68f <printint+0x86>
}
 6b6:	90                   	nop
 6b7:	90                   	nop
 6b8:	c9                   	leave  
 6b9:	c3                   	ret    

000006ba <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6ba:	55                   	push   %ebp
 6bb:	89 e5                	mov    %esp,%ebp
 6bd:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6c7:	8d 45 0c             	lea    0xc(%ebp),%eax
 6ca:	83 c0 04             	add    $0x4,%eax
 6cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6d7:	e9 59 01 00 00       	jmp    835 <printf+0x17b>
    c = fmt[i] & 0xff;
 6dc:	8b 55 0c             	mov    0xc(%ebp),%edx
 6df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e2:	01 d0                	add    %edx,%eax
 6e4:	0f b6 00             	movzbl (%eax),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	25 ff 00 00 00       	and    $0xff,%eax
 6ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f6:	75 2c                	jne    724 <printf+0x6a>
      if(c == '%'){
 6f8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fc:	75 0c                	jne    70a <printf+0x50>
        state = '%';
 6fe:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 705:	e9 27 01 00 00       	jmp    831 <printf+0x177>
      } else {
        putc(fd, c);
 70a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70d:	0f be c0             	movsbl %al,%eax
 710:	83 ec 08             	sub    $0x8,%esp
 713:	50                   	push   %eax
 714:	ff 75 08             	push   0x8(%ebp)
 717:	e8 ca fe ff ff       	call   5e6 <putc>
 71c:	83 c4 10             	add    $0x10,%esp
 71f:	e9 0d 01 00 00       	jmp    831 <printf+0x177>
      }
    } else if(state == '%'){
 724:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 728:	0f 85 03 01 00 00    	jne    831 <printf+0x177>
      if(c == 'd'){
 72e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 732:	75 1e                	jne    752 <printf+0x98>
        printint(fd, *ap, 10, 1);
 734:	8b 45 e8             	mov    -0x18(%ebp),%eax
 737:	8b 00                	mov    (%eax),%eax
 739:	6a 01                	push   $0x1
 73b:	6a 0a                	push   $0xa
 73d:	50                   	push   %eax
 73e:	ff 75 08             	push   0x8(%ebp)
 741:	e8 c3 fe ff ff       	call   609 <printint>
 746:	83 c4 10             	add    $0x10,%esp
        ap++;
 749:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74d:	e9 d8 00 00 00       	jmp    82a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 752:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 756:	74 06                	je     75e <printf+0xa4>
 758:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 75c:	75 1e                	jne    77c <printf+0xc2>
        printint(fd, *ap, 16, 0);
 75e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 761:	8b 00                	mov    (%eax),%eax
 763:	6a 00                	push   $0x0
 765:	6a 10                	push   $0x10
 767:	50                   	push   %eax
 768:	ff 75 08             	push   0x8(%ebp)
 76b:	e8 99 fe ff ff       	call   609 <printint>
 770:	83 c4 10             	add    $0x10,%esp
        ap++;
 773:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 777:	e9 ae 00 00 00       	jmp    82a <printf+0x170>
      } else if(c == 's'){
 77c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 780:	75 43                	jne    7c5 <printf+0x10b>
        s = (char*)*ap;
 782:	8b 45 e8             	mov    -0x18(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 78a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 78e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 792:	75 25                	jne    7b9 <printf+0xff>
          s = "(null)";
 794:	c7 45 f4 fb 0a 00 00 	movl   $0xafb,-0xc(%ebp)
        while(*s != 0){
 79b:	eb 1c                	jmp    7b9 <printf+0xff>
          putc(fd, *s);
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	0f b6 00             	movzbl (%eax),%eax
 7a3:	0f be c0             	movsbl %al,%eax
 7a6:	83 ec 08             	sub    $0x8,%esp
 7a9:	50                   	push   %eax
 7aa:	ff 75 08             	push   0x8(%ebp)
 7ad:	e8 34 fe ff ff       	call   5e6 <putc>
 7b2:	83 c4 10             	add    $0x10,%esp
          s++;
 7b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	0f b6 00             	movzbl (%eax),%eax
 7bf:	84 c0                	test   %al,%al
 7c1:	75 da                	jne    79d <printf+0xe3>
 7c3:	eb 65                	jmp    82a <printf+0x170>
        }
      } else if(c == 'c'){
 7c5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c9:	75 1d                	jne    7e8 <printf+0x12e>
        putc(fd, *ap);
 7cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ce:	8b 00                	mov    (%eax),%eax
 7d0:	0f be c0             	movsbl %al,%eax
 7d3:	83 ec 08             	sub    $0x8,%esp
 7d6:	50                   	push   %eax
 7d7:	ff 75 08             	push   0x8(%ebp)
 7da:	e8 07 fe ff ff       	call   5e6 <putc>
 7df:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e6:	eb 42                	jmp    82a <printf+0x170>
      } else if(c == '%'){
 7e8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ec:	75 17                	jne    805 <printf+0x14b>
        putc(fd, c);
 7ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f1:	0f be c0             	movsbl %al,%eax
 7f4:	83 ec 08             	sub    $0x8,%esp
 7f7:	50                   	push   %eax
 7f8:	ff 75 08             	push   0x8(%ebp)
 7fb:	e8 e6 fd ff ff       	call   5e6 <putc>
 800:	83 c4 10             	add    $0x10,%esp
 803:	eb 25                	jmp    82a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 805:	83 ec 08             	sub    $0x8,%esp
 808:	6a 25                	push   $0x25
 80a:	ff 75 08             	push   0x8(%ebp)
 80d:	e8 d4 fd ff ff       	call   5e6 <putc>
 812:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 815:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 818:	0f be c0             	movsbl %al,%eax
 81b:	83 ec 08             	sub    $0x8,%esp
 81e:	50                   	push   %eax
 81f:	ff 75 08             	push   0x8(%ebp)
 822:	e8 bf fd ff ff       	call   5e6 <putc>
 827:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 82a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 831:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 835:	8b 55 0c             	mov    0xc(%ebp),%edx
 838:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83b:	01 d0                	add    %edx,%eax
 83d:	0f b6 00             	movzbl (%eax),%eax
 840:	84 c0                	test   %al,%al
 842:	0f 85 94 fe ff ff    	jne    6dc <printf+0x22>
    }
  }
}
 848:	90                   	nop
 849:	90                   	nop
 84a:	c9                   	leave  
 84b:	c3                   	ret    

0000084c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84c:	55                   	push   %ebp
 84d:	89 e5                	mov    %esp,%ebp
 84f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 852:	8b 45 08             	mov    0x8(%ebp),%eax
 855:	83 e8 08             	sub    $0x8,%eax
 858:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85b:	a1 08 4f 01 00       	mov    0x14f08,%eax
 860:	89 45 fc             	mov    %eax,-0x4(%ebp)
 863:	eb 24                	jmp    889 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 86d:	72 12                	jb     881 <free+0x35>
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 875:	77 24                	ja     89b <free+0x4f>
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	8b 00                	mov    (%eax),%eax
 87c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 87f:	72 1a                	jb     89b <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	89 45 fc             	mov    %eax,-0x4(%ebp)
 889:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88f:	76 d4                	jbe    865 <free+0x19>
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 00                	mov    (%eax),%eax
 896:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 899:	73 ca                	jae    865 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	8b 40 04             	mov    0x4(%eax),%eax
 8a1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ab:	01 c2                	add    %eax,%edx
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	8b 00                	mov    (%eax),%eax
 8b2:	39 c2                	cmp    %eax,%edx
 8b4:	75 24                	jne    8da <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b9:	8b 50 04             	mov    0x4(%eax),%edx
 8bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bf:	8b 00                	mov    (%eax),%eax
 8c1:	8b 40 04             	mov    0x4(%eax),%eax
 8c4:	01 c2                	add    %eax,%edx
 8c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cf:	8b 00                	mov    (%eax),%eax
 8d1:	8b 10                	mov    (%eax),%edx
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	89 10                	mov    %edx,(%eax)
 8d8:	eb 0a                	jmp    8e4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dd:	8b 10                	mov    (%eax),%edx
 8df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	8b 40 04             	mov    0x4(%eax),%eax
 8ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	01 d0                	add    %edx,%eax
 8f6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8f9:	75 20                	jne    91b <free+0xcf>
    p->s.size += bp->s.size;
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	8b 50 04             	mov    0x4(%eax),%edx
 901:	8b 45 f8             	mov    -0x8(%ebp),%eax
 904:	8b 40 04             	mov    0x4(%eax),%eax
 907:	01 c2                	add    %eax,%edx
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	8b 10                	mov    (%eax),%edx
 914:	8b 45 fc             	mov    -0x4(%ebp),%eax
 917:	89 10                	mov    %edx,(%eax)
 919:	eb 08                	jmp    923 <free+0xd7>
  } else
    p->s.ptr = bp;
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 921:	89 10                	mov    %edx,(%eax)
  freep = p;
 923:	8b 45 fc             	mov    -0x4(%ebp),%eax
 926:	a3 08 4f 01 00       	mov    %eax,0x14f08
}
 92b:	90                   	nop
 92c:	c9                   	leave  
 92d:	c3                   	ret    

0000092e <morecore>:

static Header*
morecore(uint nu)
{
 92e:	55                   	push   %ebp
 92f:	89 e5                	mov    %esp,%ebp
 931:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 934:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 93b:	77 07                	ja     944 <morecore+0x16>
    nu = 4096;
 93d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 944:	8b 45 08             	mov    0x8(%ebp),%eax
 947:	c1 e0 03             	shl    $0x3,%eax
 94a:	83 ec 0c             	sub    $0xc,%esp
 94d:	50                   	push   %eax
 94e:	e8 73 fc ff ff       	call   5c6 <sbrk>
 953:	83 c4 10             	add    $0x10,%esp
 956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 959:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 95d:	75 07                	jne    966 <morecore+0x38>
    return 0;
 95f:	b8 00 00 00 00       	mov    $0x0,%eax
 964:	eb 26                	jmp    98c <morecore+0x5e>
  hp = (Header*)p;
 966:	8b 45 f4             	mov    -0xc(%ebp),%eax
 969:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 96c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96f:	8b 55 08             	mov    0x8(%ebp),%edx
 972:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	83 c0 08             	add    $0x8,%eax
 97b:	83 ec 0c             	sub    $0xc,%esp
 97e:	50                   	push   %eax
 97f:	e8 c8 fe ff ff       	call   84c <free>
 984:	83 c4 10             	add    $0x10,%esp
  return freep;
 987:	a1 08 4f 01 00       	mov    0x14f08,%eax
}
 98c:	c9                   	leave  
 98d:	c3                   	ret    

0000098e <malloc>:

void*
malloc(uint nbytes)
{
 98e:	55                   	push   %ebp
 98f:	89 e5                	mov    %esp,%ebp
 991:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 994:	8b 45 08             	mov    0x8(%ebp),%eax
 997:	83 c0 07             	add    $0x7,%eax
 99a:	c1 e8 03             	shr    $0x3,%eax
 99d:	83 c0 01             	add    $0x1,%eax
 9a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9a3:	a1 08 4f 01 00       	mov    0x14f08,%eax
 9a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9af:	75 23                	jne    9d4 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9b1:	c7 45 f0 00 4f 01 00 	movl   $0x14f00,-0x10(%ebp)
 9b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bb:	a3 08 4f 01 00       	mov    %eax,0x14f08
 9c0:	a1 08 4f 01 00       	mov    0x14f08,%eax
 9c5:	a3 00 4f 01 00       	mov    %eax,0x14f00
    base.s.size = 0;
 9ca:	c7 05 04 4f 01 00 00 	movl   $0x0,0x14f04
 9d1:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d7:	8b 00                	mov    (%eax),%eax
 9d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	8b 40 04             	mov    0x4(%eax),%eax
 9e2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9e5:	77 4d                	ja     a34 <malloc+0xa6>
      if(p->s.size == nunits)
 9e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ea:	8b 40 04             	mov    0x4(%eax),%eax
 9ed:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9f0:	75 0c                	jne    9fe <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	8b 10                	mov    (%eax),%edx
 9f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fa:	89 10                	mov    %edx,(%eax)
 9fc:	eb 26                	jmp    a24 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a01:	8b 40 04             	mov    0x4(%eax),%eax
 a04:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a07:	89 c2                	mov    %eax,%edx
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a12:	8b 40 04             	mov    0x4(%eax),%eax
 a15:	c1 e0 03             	shl    $0x3,%eax
 a18:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a21:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a27:	a3 08 4f 01 00       	mov    %eax,0x14f08
      return (void*)(p + 1);
 a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2f:	83 c0 08             	add    $0x8,%eax
 a32:	eb 3b                	jmp    a6f <malloc+0xe1>
    }
    if(p == freep)
 a34:	a1 08 4f 01 00       	mov    0x14f08,%eax
 a39:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a3c:	75 1e                	jne    a5c <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a3e:	83 ec 0c             	sub    $0xc,%esp
 a41:	ff 75 ec             	push   -0x14(%ebp)
 a44:	e8 e5 fe ff ff       	call   92e <morecore>
 a49:	83 c4 10             	add    $0x10,%esp
 a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a53:	75 07                	jne    a5c <malloc+0xce>
        return 0;
 a55:	b8 00 00 00 00       	mov    $0x0,%eax
 a5a:	eb 13                	jmp    a6f <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	8b 00                	mov    (%eax),%eax
 a67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a6a:	e9 6d ff ff ff       	jmp    9dc <malloc+0x4e>
  }
}
 a6f:	c9                   	leave  
 a70:	c3                   	ret    
