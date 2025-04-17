
_uthread4:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
static void thread_schedule(void);

// Scheduler implementation
static void
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p prev = current_thread;
   6:	a1 c0 0e 00 00       	mov    0xec0,%eax
   b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  thread_p nxt = 0;
   e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  // Find another runnable thread
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
  15:	c7 45 f0 e0 0e 00 00 	movl   $0xee0,-0x10(%ebp)
  1c:	eb 22                	jmp    40 <thread_schedule+0x40>
    if (t->state == RUNNABLE && t != prev) {
  1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  21:	8b 40 0c             	mov    0xc(%eax),%eax
  24:	83 f8 02             	cmp    $0x2,%eax
  27:	75 10                	jne    39 <thread_schedule+0x39>
  29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  2f:	74 08                	je     39 <thread_schedule+0x39>
      nxt = t;
  31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  34:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
  37:	eb 11                	jmp    4a <thread_schedule+0x4a>
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
  39:	81 45 f0 10 20 00 00 	addl   $0x2010,-0x10(%ebp)
  40:	b8 80 4f 01 00       	mov    $0x14f80,%eax
  45:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  48:	72 d4                	jb     1e <thread_schedule+0x1e>
    }
  }
  // If none found, maybe run self
  if (!nxt && prev->state == RUNNABLE)
  4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4e:	75 11                	jne    61 <thread_schedule+0x61>
  50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  53:	8b 40 0c             	mov    0xc(%eax),%eax
  56:	83 f8 02             	cmp    $0x2,%eax
  59:	75 06                	jne    61 <thread_schedule+0x61>
    nxt = prev;
  5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  5e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (!nxt) {
  61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  65:	75 05                	jne    6c <thread_schedule+0x6c>
    // No work left
    exit();
  67:	e8 6e 05 00 00       	call   5da <exit>
  }

  if (nxt != prev) {
  6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  72:	74 34                	je     a8 <thread_schedule+0xa8>
    // Context switch
    if (prev->state == RUNNING)
  74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  77:	8b 40 0c             	mov    0xc(%eax),%eax
  7a:	83 f8 01             	cmp    $0x1,%eax
  7d:	75 0a                	jne    89 <thread_schedule+0x89>
      prev->state = RUNNABLE;
  7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  82:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    nxt->state = RUNNING;
  89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
    next_thread = nxt;
  93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  96:	a3 c4 0e 00 00       	mov    %eax,0xec4
    thread_switch();
  9b:	e8 cd 02 00 00       	call   36d <thread_switch>
    current_thread = nxt;
  a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a3:	a3 c0 0e 00 00       	mov    %eax,0xec0
  }
}
  a8:	90                   	nop
  a9:	c9                   	leave  
  aa:	c3                   	ret    

000000ab <thread_init>:

void
thread_init(void)
{
  ab:	55                   	push   %ebp
  ac:	89 e5                	mov    %esp,%ebp
  ae:	83 ec 08             	sub    $0x8,%esp
  // main thread as tid 0
  current_thread = &all_thread[0];
  b1:	c7 05 c0 0e 00 00 e0 	movl   $0xee0,0xec0
  b8:	0e 00 00 
  current_thread->tid   = 0;
  bb:	a1 c0 0e 00 00       	mov    0xec0,%eax
  c0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  current_thread->ptid  = 0;
  c7:	a1 c0 0e 00 00       	mov    0xec0,%eax
  cc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  current_thread->state = RUNNING;
  d3:	a1 c0 0e 00 00       	mov    0xec0,%eax
  d8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)

  uthread_init(thread_schedule);
  df:	83 ec 0c             	sub    $0xc,%esp
  e2:	68 00 00 00 00       	push   $0x0
  e7:	e8 86 05 00 00       	call   672 <uthread_init>
  ec:	83 c4 10             	add    $0x10,%esp
}
  ef:	90                   	nop
  f0:	c9                   	leave  
  f1:	c3                   	ret    

000000f2 <thread_create>:

int
thread_create(void (*func)())
{
  f2:	55                   	push   %ebp
  f3:	89 e5                	mov    %esp,%ebp
  f5:	83 ec 10             	sub    $0x10,%esp
  // Find free slot
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  f8:	c7 45 fc e0 0e 00 00 	movl   $0xee0,-0x4(%ebp)
  ff:	eb 11                	jmp    112 <thread_create+0x20>
    if (t->state == FREE) break;
 101:	8b 45 fc             	mov    -0x4(%ebp),%eax
 104:	8b 40 0c             	mov    0xc(%eax),%eax
 107:	85 c0                	test   %eax,%eax
 109:	74 13                	je     11e <thread_create+0x2c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 10b:	81 45 fc 10 20 00 00 	addl   $0x2010,-0x4(%ebp)
 112:	b8 80 4f 01 00       	mov    $0x14f80,%eax
 117:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 11a:	72 e5                	jb     101 <thread_create+0xf>
 11c:	eb 01                	jmp    11f <thread_create+0x2d>
    if (t->state == FREE) break;
 11e:	90                   	nop
  }
  if (t == all_thread + MAX_THREAD)
 11f:	b8 80 4f 01 00       	mov    $0x14f80,%eax
 124:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 127:	75 07                	jne    130 <thread_create+0x3e>
    return -1;
 129:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 12e:	eb 70                	jmp    1a0 <thread_create+0xae>

  int new_tid = t - all_thread;
 130:	8b 45 fc             	mov    -0x4(%ebp),%eax
 133:	2d e0 0e 00 00       	sub    $0xee0,%eax
 138:	c1 f8 04             	sar    $0x4,%eax
 13b:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 141:	89 45 f8             	mov    %eax,-0x8(%ebp)
  t->tid  = new_tid;
 144:	8b 45 fc             	mov    -0x4(%ebp),%eax
 147:	8b 55 f8             	mov    -0x8(%ebp),%edx
 14a:	89 50 04             	mov    %edx,0x4(%eax)
  t->ptid = current_thread->tid;
 14d:	a1 c0 0e 00 00       	mov    0xec0,%eax
 152:	8b 50 04             	mov    0x4(%eax),%edx
 155:	8b 45 fc             	mov    -0x4(%ebp),%eax
 158:	89 50 08             	mov    %edx,0x8(%eax)
  t->sp = (int)(t->stack + STACK_SIZE);
 15b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15e:	83 c0 10             	add    $0x10,%eax
 161:	05 00 20 00 00       	add    $0x2000,%eax
 166:	89 c2                	mov    %eax,%edx
 168:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16b:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 170:	8b 00                	mov    (%eax),%eax
 172:	8d 50 fc             	lea    -0x4(%eax),%edx
 175:	8b 45 fc             	mov    -0x4(%ebp),%eax
 178:	89 10                	mov    %edx,(%eax)
  *(int*)(t->sp) = (int)func;
 17a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17d:	8b 00                	mov    (%eax),%eax
 17f:	89 c2                	mov    %eax,%edx
 181:	8b 45 08             	mov    0x8(%ebp),%eax
 184:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;
 186:	8b 45 fc             	mov    -0x4(%ebp),%eax
 189:	8b 00                	mov    (%eax),%eax
 18b:	8d 50 e0             	lea    -0x20(%eax),%edx
 18e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 191:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 193:	8b 45 fc             	mov    -0x4(%ebp),%eax
 196:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  return new_tid;
 19d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
 1a0:	c9                   	leave  
 1a1:	c3                   	ret    

000001a2 <thread_yield>:

void
thread_yield(void)
{
 1a2:	55                   	push   %ebp
 1a3:	89 e5                	mov    %esp,%ebp
 1a5:	83 ec 08             	sub    $0x8,%esp
  if (current_thread->state == RUNNING)
 1a8:	a1 c0 0e 00 00       	mov    0xec0,%eax
 1ad:	8b 40 0c             	mov    0xc(%eax),%eax
 1b0:	83 f8 01             	cmp    $0x1,%eax
 1b3:	75 0c                	jne    1c1 <thread_yield+0x1f>
    current_thread->state = RUNNABLE;
 1b5:	a1 c0 0e 00 00       	mov    0xec0,%eax
 1ba:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  thread_schedule();
 1c1:	e8 3a fe ff ff       	call   0 <thread_schedule>
}
 1c6:	90                   	nop
 1c7:	c9                   	leave  
 1c8:	c3                   	ret    

000001c9 <thread_join>:

// Wait for a specific child thread to finish
int
thread_join(int tid)
{
 1c9:	55                   	push   %ebp
 1ca:	89 e5                	mov    %esp,%ebp
 1cc:	83 ec 18             	sub    $0x18,%esp
  // Validate tid
  if (tid < 0 || tid >= MAX_THREAD)
 1cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1d3:	78 06                	js     1db <thread_join+0x12>
 1d5:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
 1d9:	7e 07                	jle    1e2 <thread_join+0x19>
    return -1;
 1db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1e0:	eb 56                	jmp    238 <thread_join+0x6f>
  thread_p child = &all_thread[tid];
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 1eb:	05 e0 0e 00 00       	add    $0xee0,%eax
 1f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (child->ptid != current_thread->tid)
 1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f6:	8b 50 08             	mov    0x8(%eax),%edx
 1f9:	a1 c0 0e 00 00       	mov    0xec0,%eax
 1fe:	8b 40 04             	mov    0x4(%eax),%eax
 201:	39 c2                	cmp    %eax,%edx
 203:	74 24                	je     229 <thread_join+0x60>
    return -1;
 205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 20a:	eb 2c                	jmp    238 <thread_join+0x6f>

  // Block until child->state becomes FREE
  while (child->state != FREE) {
    current_thread->state = WAIT;
 20c:	a1 c0 0e 00 00       	mov    0xec0,%eax
 211:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    thread_schedule();
 218:	e8 e3 fd ff ff       	call   0 <thread_schedule>
    current_thread->state = RUNNING;
 21d:	a1 c0 0e 00 00       	mov    0xec0,%eax
 222:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  while (child->state != FREE) {
 229:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22c:	8b 40 0c             	mov    0xc(%eax),%eax
 22f:	85 c0                	test   %eax,%eax
 231:	75 d9                	jne    20c <thread_join+0x43>
  }
  return 0;
 233:	b8 00 00 00 00       	mov    $0x0,%eax
}
 238:	c9                   	leave  
 239:	c3                   	ret    

0000023a <child_thread>:

// Example child function
static void
child_thread(void)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	83 ec 18             	sub    $0x18,%esp
  printf(1, "child thread running\n");
 240:	83 ec 08             	sub    $0x8,%esp
 243:	68 05 0b 00 00       	push   $0xb05
 248:	6a 01                	push   $0x1
 24a:	e8 ff 04 00 00       	call   74e <printf>
 24f:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++)
 252:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 259:	eb 1c                	jmp    277 <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int)current_thread);
 25b:	a1 c0 0e 00 00       	mov    0xec0,%eax
 260:	83 ec 04             	sub    $0x4,%esp
 263:	50                   	push   %eax
 264:	68 1b 0b 00 00       	push   $0xb1b
 269:	6a 01                	push   $0x1
 26b:	e8 de 04 00 00       	call   74e <printf>
 270:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++)
 273:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 277:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 27b:	7e de                	jle    25b <child_thread+0x21>
  printf(1, "child thread: exit\n");
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	68 2e 0b 00 00       	push   $0xb2e
 285:	6a 01                	push   $0x1
 287:	e8 c2 04 00 00       	call   74e <printf>
 28c:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 28f:	a1 c0 0e 00 00       	mov    0xec0,%eax
 294:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  thread_schedule();
 29b:	e8 60 fd ff ff       	call   0 <thread_schedule>
}
 2a0:	90                   	nop
 2a1:	c9                   	leave  
 2a2:	c3                   	ret    

000002a3 <mythread>:

// Example parent function
static void
mythread(void)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	83 ec 28             	sub    $0x28,%esp
  printf(1, "my thread running\n");
 2a9:	83 ec 08             	sub    $0x8,%esp
 2ac:	68 42 0b 00 00       	push   $0xb42
 2b1:	6a 01                	push   $0x1
 2b3:	e8 96 04 00 00       	call   74e <printf>
 2b8:	83 c4 10             	add    $0x10,%esp
  int tids[5];
  for (int i = 0; i < 5; i++) {
 2bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2c2:	eb 1b                	jmp    2df <mythread+0x3c>
    tids[i] = thread_create(child_thread);
 2c4:	83 ec 0c             	sub    $0xc,%esp
 2c7:	68 3a 02 00 00       	push   $0x23a
 2cc:	e8 21 fe ff ff       	call   f2 <thread_create>
 2d1:	83 c4 10             	add    $0x10,%esp
 2d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2d7:	89 44 95 dc          	mov    %eax,-0x24(%ebp,%edx,4)
  for (int i = 0; i < 5; i++) {
 2db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2df:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 2e3:	7e df                	jle    2c4 <mythread+0x21>
  }
  for (int i = 0; i < 5; i++) {
 2e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 2ec:	eb 17                	jmp    305 <mythread+0x62>
    thread_join(tids[i]);
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2f1:	8b 44 85 dc          	mov    -0x24(%ebp,%eax,4),%eax
 2f5:	83 ec 0c             	sub    $0xc,%esp
 2f8:	50                   	push   %eax
 2f9:	e8 cb fe ff ff       	call   1c9 <thread_join>
 2fe:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 5; i++) {
 301:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 305:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
 309:	7e e3                	jle    2ee <mythread+0x4b>
  }
  printf(1, "my thread: exit\n");
 30b:	83 ec 08             	sub    $0x8,%esp
 30e:	68 55 0b 00 00       	push   $0xb55
 313:	6a 01                	push   $0x1
 315:	e8 34 04 00 00       	call   74e <printf>
 31a:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 31d:	a1 c0 0e 00 00       	mov    0xec0,%eax
 322:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  thread_schedule();
 329:	e8 d2 fc ff ff       	call   0 <thread_schedule>
}
 32e:	90                   	nop
 32f:	c9                   	leave  
 330:	c3                   	ret    

00000331 <main>:

int
main(int argc, char *argv[])
{
 331:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 335:	83 e4 f0             	and    $0xfffffff0,%esp
 338:	ff 71 fc             	push   -0x4(%ecx)
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	51                   	push   %ecx
 33f:	83 ec 14             	sub    $0x14,%esp
  thread_init();
 342:	e8 64 fd ff ff       	call   ab <thread_init>
  int tid = thread_create(mythread);
 347:	83 ec 0c             	sub    $0xc,%esp
 34a:	68 a3 02 00 00       	push   $0x2a3
 34f:	e8 9e fd ff ff       	call   f2 <thread_create>
 354:	83 c4 10             	add    $0x10,%esp
 357:	89 45 f4             	mov    %eax,-0xc(%ebp)
  thread_join(tid);
 35a:	83 ec 0c             	sub    $0xc,%esp
 35d:	ff 75 f4             	push   -0xc(%ebp)
 360:	e8 64 fe ff ff       	call   1c9 <thread_join>
 365:	83 c4 10             	add    $0x10,%esp
  exit();
 368:	e8 6d 02 00 00       	call   5da <exit>

0000036d <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 36d:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 36e:	a1 c0 0e 00 00       	mov    0xec0,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 373:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 375:	a1 c4 0e 00 00       	mov    0xec4,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 37a:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 37c:	a3 c0 0e 00 00       	mov    %eax,0xec0
    popal
 381:	61                   	popa   
    
    # return to next thread's stack context
 382:	c3                   	ret    

00000383 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	57                   	push   %edi
 387:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 388:	8b 4d 08             	mov    0x8(%ebp),%ecx
 38b:	8b 55 10             	mov    0x10(%ebp),%edx
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	89 cb                	mov    %ecx,%ebx
 393:	89 df                	mov    %ebx,%edi
 395:	89 d1                	mov    %edx,%ecx
 397:	fc                   	cld    
 398:	f3 aa                	rep stos %al,%es:(%edi)
 39a:	89 ca                	mov    %ecx,%edx
 39c:	89 fb                	mov    %edi,%ebx
 39e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3a1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3a4:	90                   	nop
 3a5:	5b                   	pop    %ebx
 3a6:	5f                   	pop    %edi
 3a7:	5d                   	pop    %ebp
 3a8:	c3                   	ret    

000003a9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
 3ac:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3b5:	90                   	nop
 3b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 3b9:	8d 42 01             	lea    0x1(%edx),%eax
 3bc:	89 45 0c             	mov    %eax,0xc(%ebp)
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	8d 48 01             	lea    0x1(%eax),%ecx
 3c5:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3c8:	0f b6 12             	movzbl (%edx),%edx
 3cb:	88 10                	mov    %dl,(%eax)
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	84 c0                	test   %al,%al
 3d2:	75 e2                	jne    3b6 <strcpy+0xd>
    ;
  return os;
 3d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d7:	c9                   	leave  
 3d8:	c3                   	ret    

000003d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3d9:	55                   	push   %ebp
 3da:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3dc:	eb 08                	jmp    3e6 <strcmp+0xd>
    p++, q++;
 3de:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	84 c0                	test   %al,%al
 3ee:	74 10                	je     400 <strcmp+0x27>
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	0f b6 10             	movzbl (%eax),%edx
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	0f b6 00             	movzbl (%eax),%eax
 3fc:	38 c2                	cmp    %al,%dl
 3fe:	74 de                	je     3de <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	0f b6 00             	movzbl (%eax),%eax
 406:	0f b6 d0             	movzbl %al,%edx
 409:	8b 45 0c             	mov    0xc(%ebp),%eax
 40c:	0f b6 00             	movzbl (%eax),%eax
 40f:	0f b6 c8             	movzbl %al,%ecx
 412:	89 d0                	mov    %edx,%eax
 414:	29 c8                	sub    %ecx,%eax
}
 416:	5d                   	pop    %ebp
 417:	c3                   	ret    

00000418 <strlen>:

uint
strlen(char *s)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 41e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 425:	eb 04                	jmp    42b <strlen+0x13>
 427:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 42b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
 431:	01 d0                	add    %edx,%eax
 433:	0f b6 00             	movzbl (%eax),%eax
 436:	84 c0                	test   %al,%al
 438:	75 ed                	jne    427 <strlen+0xf>
    ;
  return n;
 43a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 43d:	c9                   	leave  
 43e:	c3                   	ret    

0000043f <memset>:

void*
memset(void *dst, int c, uint n)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 442:	8b 45 10             	mov    0x10(%ebp),%eax
 445:	50                   	push   %eax
 446:	ff 75 0c             	push   0xc(%ebp)
 449:	ff 75 08             	push   0x8(%ebp)
 44c:	e8 32 ff ff ff       	call   383 <stosb>
 451:	83 c4 0c             	add    $0xc,%esp
  return dst;
 454:	8b 45 08             	mov    0x8(%ebp),%eax
}
 457:	c9                   	leave  
 458:	c3                   	ret    

00000459 <strchr>:

char*
strchr(const char *s, char c)
{
 459:	55                   	push   %ebp
 45a:	89 e5                	mov    %esp,%ebp
 45c:	83 ec 04             	sub    $0x4,%esp
 45f:	8b 45 0c             	mov    0xc(%ebp),%eax
 462:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 465:	eb 14                	jmp    47b <strchr+0x22>
    if(*s == c)
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	38 45 fc             	cmp    %al,-0x4(%ebp)
 470:	75 05                	jne    477 <strchr+0x1e>
      return (char*)s;
 472:	8b 45 08             	mov    0x8(%ebp),%eax
 475:	eb 13                	jmp    48a <strchr+0x31>
  for(; *s; s++)
 477:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	0f b6 00             	movzbl (%eax),%eax
 481:	84 c0                	test   %al,%al
 483:	75 e2                	jne    467 <strchr+0xe>
  return 0;
 485:	b8 00 00 00 00       	mov    $0x0,%eax
}
 48a:	c9                   	leave  
 48b:	c3                   	ret    

0000048c <gets>:

char*
gets(char *buf, int max)
{
 48c:	55                   	push   %ebp
 48d:	89 e5                	mov    %esp,%ebp
 48f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 492:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 499:	eb 42                	jmp    4dd <gets+0x51>
    cc = read(0, &c, 1);
 49b:	83 ec 04             	sub    $0x4,%esp
 49e:	6a 01                	push   $0x1
 4a0:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a3:	50                   	push   %eax
 4a4:	6a 00                	push   $0x0
 4a6:	e8 47 01 00 00       	call   5f2 <read>
 4ab:	83 c4 10             	add    $0x10,%esp
 4ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b5:	7e 33                	jle    4ea <gets+0x5e>
      break;
    buf[i++] = c;
 4b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ba:	8d 50 01             	lea    0x1(%eax),%edx
 4bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c0:	89 c2                	mov    %eax,%edx
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	01 c2                	add    %eax,%edx
 4c7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4cb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d1:	3c 0a                	cmp    $0xa,%al
 4d3:	74 16                	je     4eb <gets+0x5f>
 4d5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d9:	3c 0d                	cmp    $0xd,%al
 4db:	74 0e                	je     4eb <gets+0x5f>
  for(i=0; i+1 < max; ){
 4dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e0:	83 c0 01             	add    $0x1,%eax
 4e3:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4e6:	7f b3                	jg     49b <gets+0xf>
 4e8:	eb 01                	jmp    4eb <gets+0x5f>
      break;
 4ea:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	01 d0                	add    %edx,%eax
 4f3:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f9:	c9                   	leave  
 4fa:	c3                   	ret    

000004fb <stat>:

int
stat(char *n, struct stat *st)
{
 4fb:	55                   	push   %ebp
 4fc:	89 e5                	mov    %esp,%ebp
 4fe:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 501:	83 ec 08             	sub    $0x8,%esp
 504:	6a 00                	push   $0x0
 506:	ff 75 08             	push   0x8(%ebp)
 509:	e8 14 01 00 00       	call   622 <open>
 50e:	83 c4 10             	add    $0x10,%esp
 511:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 514:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 518:	79 07                	jns    521 <stat+0x26>
    return -1;
 51a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 51f:	eb 25                	jmp    546 <stat+0x4b>
  r = fstat(fd, st);
 521:	83 ec 08             	sub    $0x8,%esp
 524:	ff 75 0c             	push   0xc(%ebp)
 527:	ff 75 f4             	push   -0xc(%ebp)
 52a:	e8 0b 01 00 00       	call   63a <fstat>
 52f:	83 c4 10             	add    $0x10,%esp
 532:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 535:	83 ec 0c             	sub    $0xc,%esp
 538:	ff 75 f4             	push   -0xc(%ebp)
 53b:	e8 c2 00 00 00       	call   602 <close>
 540:	83 c4 10             	add    $0x10,%esp
  return r;
 543:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 546:	c9                   	leave  
 547:	c3                   	ret    

00000548 <atoi>:

int
atoi(const char *s)
{
 548:	55                   	push   %ebp
 549:	89 e5                	mov    %esp,%ebp
 54b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 54e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 555:	eb 25                	jmp    57c <atoi+0x34>
    n = n*10 + *s++ - '0';
 557:	8b 55 fc             	mov    -0x4(%ebp),%edx
 55a:	89 d0                	mov    %edx,%eax
 55c:	c1 e0 02             	shl    $0x2,%eax
 55f:	01 d0                	add    %edx,%eax
 561:	01 c0                	add    %eax,%eax
 563:	89 c1                	mov    %eax,%ecx
 565:	8b 45 08             	mov    0x8(%ebp),%eax
 568:	8d 50 01             	lea    0x1(%eax),%edx
 56b:	89 55 08             	mov    %edx,0x8(%ebp)
 56e:	0f b6 00             	movzbl (%eax),%eax
 571:	0f be c0             	movsbl %al,%eax
 574:	01 c8                	add    %ecx,%eax
 576:	83 e8 30             	sub    $0x30,%eax
 579:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
 57f:	0f b6 00             	movzbl (%eax),%eax
 582:	3c 2f                	cmp    $0x2f,%al
 584:	7e 0a                	jle    590 <atoi+0x48>
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	0f b6 00             	movzbl (%eax),%eax
 58c:	3c 39                	cmp    $0x39,%al
 58e:	7e c7                	jle    557 <atoi+0xf>
  return n;
 590:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 593:	c9                   	leave  
 594:	c3                   	ret    

00000595 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 595:	55                   	push   %ebp
 596:	89 e5                	mov    %esp,%ebp
 598:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5a7:	eb 17                	jmp    5c0 <memmove+0x2b>
    *dst++ = *src++;
 5a9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5ac:	8d 42 01             	lea    0x1(%edx),%eax
 5af:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b5:	8d 48 01             	lea    0x1(%eax),%ecx
 5b8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5bb:	0f b6 12             	movzbl (%edx),%edx
 5be:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5c0:	8b 45 10             	mov    0x10(%ebp),%eax
 5c3:	8d 50 ff             	lea    -0x1(%eax),%edx
 5c6:	89 55 10             	mov    %edx,0x10(%ebp)
 5c9:	85 c0                	test   %eax,%eax
 5cb:	7f dc                	jg     5a9 <memmove+0x14>
  return vdst;
 5cd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d0:	c9                   	leave  
 5d1:	c3                   	ret    

000005d2 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 5d2:	b8 01 00 00 00       	mov    $0x1,%eax
 5d7:	cd 40                	int    $0x40
 5d9:	c3                   	ret    

000005da <exit>:
SYSCALL(exit)
 5da:	b8 02 00 00 00       	mov    $0x2,%eax
 5df:	cd 40                	int    $0x40
 5e1:	c3                   	ret    

000005e2 <wait>:
SYSCALL(wait)
 5e2:	b8 03 00 00 00       	mov    $0x3,%eax
 5e7:	cd 40                	int    $0x40
 5e9:	c3                   	ret    

000005ea <pipe>:
SYSCALL(pipe)
 5ea:	b8 04 00 00 00       	mov    $0x4,%eax
 5ef:	cd 40                	int    $0x40
 5f1:	c3                   	ret    

000005f2 <read>:
SYSCALL(read)
 5f2:	b8 05 00 00 00       	mov    $0x5,%eax
 5f7:	cd 40                	int    $0x40
 5f9:	c3                   	ret    

000005fa <write>:
SYSCALL(write)
 5fa:	b8 10 00 00 00       	mov    $0x10,%eax
 5ff:	cd 40                	int    $0x40
 601:	c3                   	ret    

00000602 <close>:
SYSCALL(close)
 602:	b8 15 00 00 00       	mov    $0x15,%eax
 607:	cd 40                	int    $0x40
 609:	c3                   	ret    

0000060a <kill>:
SYSCALL(kill)
 60a:	b8 06 00 00 00       	mov    $0x6,%eax
 60f:	cd 40                	int    $0x40
 611:	c3                   	ret    

00000612 <dup>:
SYSCALL(dup)
 612:	b8 0a 00 00 00       	mov    $0xa,%eax
 617:	cd 40                	int    $0x40
 619:	c3                   	ret    

0000061a <exec>:
SYSCALL(exec)
 61a:	b8 07 00 00 00       	mov    $0x7,%eax
 61f:	cd 40                	int    $0x40
 621:	c3                   	ret    

00000622 <open>:
SYSCALL(open)
 622:	b8 0f 00 00 00       	mov    $0xf,%eax
 627:	cd 40                	int    $0x40
 629:	c3                   	ret    

0000062a <mknod>:
SYSCALL(mknod)
 62a:	b8 11 00 00 00       	mov    $0x11,%eax
 62f:	cd 40                	int    $0x40
 631:	c3                   	ret    

00000632 <unlink>:
SYSCALL(unlink)
 632:	b8 12 00 00 00       	mov    $0x12,%eax
 637:	cd 40                	int    $0x40
 639:	c3                   	ret    

0000063a <fstat>:
SYSCALL(fstat)
 63a:	b8 08 00 00 00       	mov    $0x8,%eax
 63f:	cd 40                	int    $0x40
 641:	c3                   	ret    

00000642 <link>:
SYSCALL(link)
 642:	b8 13 00 00 00       	mov    $0x13,%eax
 647:	cd 40                	int    $0x40
 649:	c3                   	ret    

0000064a <mkdir>:
SYSCALL(mkdir)
 64a:	b8 14 00 00 00       	mov    $0x14,%eax
 64f:	cd 40                	int    $0x40
 651:	c3                   	ret    

00000652 <chdir>:
SYSCALL(chdir)
 652:	b8 09 00 00 00       	mov    $0x9,%eax
 657:	cd 40                	int    $0x40
 659:	c3                   	ret    

0000065a <sbrk>:
SYSCALL(sbrk)
 65a:	b8 0c 00 00 00       	mov    $0xc,%eax
 65f:	cd 40                	int    $0x40
 661:	c3                   	ret    

00000662 <sleep>:
SYSCALL(sleep)
 662:	b8 0d 00 00 00       	mov    $0xd,%eax
 667:	cd 40                	int    $0x40
 669:	c3                   	ret    

0000066a <getpid>:
SYSCALL(getpid)
 66a:	b8 0b 00 00 00       	mov    $0xb,%eax
 66f:	cd 40                	int    $0x40
 671:	c3                   	ret    

00000672 <uthread_init>:
SYSCALL(uthread_init)
 672:	b8 18 00 00 00       	mov    $0x18,%eax
 677:	cd 40                	int    $0x40
 679:	c3                   	ret    

0000067a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 67a:	55                   	push   %ebp
 67b:	89 e5                	mov    %esp,%ebp
 67d:	83 ec 18             	sub    $0x18,%esp
 680:	8b 45 0c             	mov    0xc(%ebp),%eax
 683:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 686:	83 ec 04             	sub    $0x4,%esp
 689:	6a 01                	push   $0x1
 68b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68e:	50                   	push   %eax
 68f:	ff 75 08             	push   0x8(%ebp)
 692:	e8 63 ff ff ff       	call   5fa <write>
 697:	83 c4 10             	add    $0x10,%esp
}
 69a:	90                   	nop
 69b:	c9                   	leave  
 69c:	c3                   	ret    

0000069d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69d:	55                   	push   %ebp
 69e:	89 e5                	mov    %esp,%ebp
 6a0:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6aa:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6ae:	74 17                	je     6c7 <printint+0x2a>
 6b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b4:	79 11                	jns    6c7 <printint+0x2a>
    neg = 1;
 6b6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c0:	f7 d8                	neg    %eax
 6c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c5:	eb 06                	jmp    6cd <printint+0x30>
  } else {
    x = xx;
 6c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6da:	ba 00 00 00 00       	mov    $0x0,%edx
 6df:	f7 f1                	div    %ecx
 6e1:	89 d1                	mov    %edx,%ecx
 6e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e6:	8d 50 01             	lea    0x1(%eax),%edx
 6e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6ec:	0f b6 91 94 0e 00 00 	movzbl 0xe94(%ecx),%edx
 6f3:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fd:	ba 00 00 00 00       	mov    $0x0,%edx
 702:	f7 f1                	div    %ecx
 704:	89 45 ec             	mov    %eax,-0x14(%ebp)
 707:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70b:	75 c7                	jne    6d4 <printint+0x37>
  if(neg)
 70d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 711:	74 2d                	je     740 <printint+0xa3>
    buf[i++] = '-';
 713:	8b 45 f4             	mov    -0xc(%ebp),%eax
 716:	8d 50 01             	lea    0x1(%eax),%edx
 719:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 721:	eb 1d                	jmp    740 <printint+0xa3>
    putc(fd, buf[i]);
 723:	8d 55 dc             	lea    -0x24(%ebp),%edx
 726:	8b 45 f4             	mov    -0xc(%ebp),%eax
 729:	01 d0                	add    %edx,%eax
 72b:	0f b6 00             	movzbl (%eax),%eax
 72e:	0f be c0             	movsbl %al,%eax
 731:	83 ec 08             	sub    $0x8,%esp
 734:	50                   	push   %eax
 735:	ff 75 08             	push   0x8(%ebp)
 738:	e8 3d ff ff ff       	call   67a <putc>
 73d:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 740:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 748:	79 d9                	jns    723 <printint+0x86>
}
 74a:	90                   	nop
 74b:	90                   	nop
 74c:	c9                   	leave  
 74d:	c3                   	ret    

0000074e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 74e:	55                   	push   %ebp
 74f:	89 e5                	mov    %esp,%ebp
 751:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 754:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 75b:	8d 45 0c             	lea    0xc(%ebp),%eax
 75e:	83 c0 04             	add    $0x4,%eax
 761:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 764:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 76b:	e9 59 01 00 00       	jmp    8c9 <printf+0x17b>
    c = fmt[i] & 0xff;
 770:	8b 55 0c             	mov    0xc(%ebp),%edx
 773:	8b 45 f0             	mov    -0x10(%ebp),%eax
 776:	01 d0                	add    %edx,%eax
 778:	0f b6 00             	movzbl (%eax),%eax
 77b:	0f be c0             	movsbl %al,%eax
 77e:	25 ff 00 00 00       	and    $0xff,%eax
 783:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 786:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 78a:	75 2c                	jne    7b8 <printf+0x6a>
      if(c == '%'){
 78c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 790:	75 0c                	jne    79e <printf+0x50>
        state = '%';
 792:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 799:	e9 27 01 00 00       	jmp    8c5 <printf+0x177>
      } else {
        putc(fd, c);
 79e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a1:	0f be c0             	movsbl %al,%eax
 7a4:	83 ec 08             	sub    $0x8,%esp
 7a7:	50                   	push   %eax
 7a8:	ff 75 08             	push   0x8(%ebp)
 7ab:	e8 ca fe ff ff       	call   67a <putc>
 7b0:	83 c4 10             	add    $0x10,%esp
 7b3:	e9 0d 01 00 00       	jmp    8c5 <printf+0x177>
      }
    } else if(state == '%'){
 7b8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7bc:	0f 85 03 01 00 00    	jne    8c5 <printf+0x177>
      if(c == 'd'){
 7c2:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c6:	75 1e                	jne    7e6 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	6a 01                	push   $0x1
 7cf:	6a 0a                	push   $0xa
 7d1:	50                   	push   %eax
 7d2:	ff 75 08             	push   0x8(%ebp)
 7d5:	e8 c3 fe ff ff       	call   69d <printint>
 7da:	83 c4 10             	add    $0x10,%esp
        ap++;
 7dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e1:	e9 d8 00 00 00       	jmp    8be <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7e6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ea:	74 06                	je     7f2 <printf+0xa4>
 7ec:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f0:	75 1e                	jne    810 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f5:	8b 00                	mov    (%eax),%eax
 7f7:	6a 00                	push   $0x0
 7f9:	6a 10                	push   $0x10
 7fb:	50                   	push   %eax
 7fc:	ff 75 08             	push   0x8(%ebp)
 7ff:	e8 99 fe ff ff       	call   69d <printint>
 804:	83 c4 10             	add    $0x10,%esp
        ap++;
 807:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80b:	e9 ae 00 00 00       	jmp    8be <printf+0x170>
      } else if(c == 's'){
 810:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 814:	75 43                	jne    859 <printf+0x10b>
        s = (char*)*ap;
 816:	8b 45 e8             	mov    -0x18(%ebp),%eax
 819:	8b 00                	mov    (%eax),%eax
 81b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 81e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 822:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 826:	75 25                	jne    84d <printf+0xff>
          s = "(null)";
 828:	c7 45 f4 66 0b 00 00 	movl   $0xb66,-0xc(%ebp)
        while(*s != 0){
 82f:	eb 1c                	jmp    84d <printf+0xff>
          putc(fd, *s);
 831:	8b 45 f4             	mov    -0xc(%ebp),%eax
 834:	0f b6 00             	movzbl (%eax),%eax
 837:	0f be c0             	movsbl %al,%eax
 83a:	83 ec 08             	sub    $0x8,%esp
 83d:	50                   	push   %eax
 83e:	ff 75 08             	push   0x8(%ebp)
 841:	e8 34 fe ff ff       	call   67a <putc>
 846:	83 c4 10             	add    $0x10,%esp
          s++;
 849:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	0f b6 00             	movzbl (%eax),%eax
 853:	84 c0                	test   %al,%al
 855:	75 da                	jne    831 <printf+0xe3>
 857:	eb 65                	jmp    8be <printf+0x170>
        }
      } else if(c == 'c'){
 859:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 85d:	75 1d                	jne    87c <printf+0x12e>
        putc(fd, *ap);
 85f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 862:	8b 00                	mov    (%eax),%eax
 864:	0f be c0             	movsbl %al,%eax
 867:	83 ec 08             	sub    $0x8,%esp
 86a:	50                   	push   %eax
 86b:	ff 75 08             	push   0x8(%ebp)
 86e:	e8 07 fe ff ff       	call   67a <putc>
 873:	83 c4 10             	add    $0x10,%esp
        ap++;
 876:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 87a:	eb 42                	jmp    8be <printf+0x170>
      } else if(c == '%'){
 87c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 880:	75 17                	jne    899 <printf+0x14b>
        putc(fd, c);
 882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 885:	0f be c0             	movsbl %al,%eax
 888:	83 ec 08             	sub    $0x8,%esp
 88b:	50                   	push   %eax
 88c:	ff 75 08             	push   0x8(%ebp)
 88f:	e8 e6 fd ff ff       	call   67a <putc>
 894:	83 c4 10             	add    $0x10,%esp
 897:	eb 25                	jmp    8be <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 899:	83 ec 08             	sub    $0x8,%esp
 89c:	6a 25                	push   $0x25
 89e:	ff 75 08             	push   0x8(%ebp)
 8a1:	e8 d4 fd ff ff       	call   67a <putc>
 8a6:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ac:	0f be c0             	movsbl %al,%eax
 8af:	83 ec 08             	sub    $0x8,%esp
 8b2:	50                   	push   %eax
 8b3:	ff 75 08             	push   0x8(%ebp)
 8b6:	e8 bf fd ff ff       	call   67a <putc>
 8bb:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8be:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8c5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8c9:	8b 55 0c             	mov    0xc(%ebp),%edx
 8cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cf:	01 d0                	add    %edx,%eax
 8d1:	0f b6 00             	movzbl (%eax),%eax
 8d4:	84 c0                	test   %al,%al
 8d6:	0f 85 94 fe ff ff    	jne    770 <printf+0x22>
    }
  }
}
 8dc:	90                   	nop
 8dd:	90                   	nop
 8de:	c9                   	leave  
 8df:	c3                   	ret    

000008e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e0:	55                   	push   %ebp
 8e1:	89 e5                	mov    %esp,%ebp
 8e3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e6:	8b 45 08             	mov    0x8(%ebp),%eax
 8e9:	83 e8 08             	sub    $0x8,%eax
 8ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ef:	a1 88 4f 01 00       	mov    0x14f88,%eax
 8f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f7:	eb 24                	jmp    91d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 00                	mov    (%eax),%eax
 8fe:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 901:	72 12                	jb     915 <free+0x35>
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 909:	77 24                	ja     92f <free+0x4f>
 90b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90e:	8b 00                	mov    (%eax),%eax
 910:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 913:	72 1a                	jb     92f <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 920:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 923:	76 d4                	jbe    8f9 <free+0x19>
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 92d:	73 ca                	jae    8f9 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	8b 40 04             	mov    0x4(%eax),%eax
 935:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 93c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93f:	01 c2                	add    %eax,%edx
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	8b 00                	mov    (%eax),%eax
 946:	39 c2                	cmp    %eax,%edx
 948:	75 24                	jne    96e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	8b 50 04             	mov    0x4(%eax),%edx
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 00                	mov    (%eax),%eax
 955:	8b 40 04             	mov    0x4(%eax),%eax
 958:	01 c2                	add    %eax,%edx
 95a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 960:	8b 45 fc             	mov    -0x4(%ebp),%eax
 963:	8b 00                	mov    (%eax),%eax
 965:	8b 10                	mov    (%eax),%edx
 967:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96a:	89 10                	mov    %edx,(%eax)
 96c:	eb 0a                	jmp    978 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 96e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 971:	8b 10                	mov    (%eax),%edx
 973:	8b 45 f8             	mov    -0x8(%ebp),%eax
 976:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 978:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97b:	8b 40 04             	mov    0x4(%eax),%eax
 97e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 985:	8b 45 fc             	mov    -0x4(%ebp),%eax
 988:	01 d0                	add    %edx,%eax
 98a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 98d:	75 20                	jne    9af <free+0xcf>
    p->s.size += bp->s.size;
 98f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 992:	8b 50 04             	mov    0x4(%eax),%edx
 995:	8b 45 f8             	mov    -0x8(%ebp),%eax
 998:	8b 40 04             	mov    0x4(%eax),%eax
 99b:	01 c2                	add    %eax,%edx
 99d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a6:	8b 10                	mov    (%eax),%edx
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	89 10                	mov    %edx,(%eax)
 9ad:	eb 08                	jmp    9b7 <free+0xd7>
  } else
    p->s.ptr = bp;
 9af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9b5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	a3 88 4f 01 00       	mov    %eax,0x14f88
}
 9bf:	90                   	nop
 9c0:	c9                   	leave  
 9c1:	c3                   	ret    

000009c2 <morecore>:

static Header*
morecore(uint nu)
{
 9c2:	55                   	push   %ebp
 9c3:	89 e5                	mov    %esp,%ebp
 9c5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9cf:	77 07                	ja     9d8 <morecore+0x16>
    nu = 4096;
 9d1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d8:	8b 45 08             	mov    0x8(%ebp),%eax
 9db:	c1 e0 03             	shl    $0x3,%eax
 9de:	83 ec 0c             	sub    $0xc,%esp
 9e1:	50                   	push   %eax
 9e2:	e8 73 fc ff ff       	call   65a <sbrk>
 9e7:	83 c4 10             	add    $0x10,%esp
 9ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ed:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f1:	75 07                	jne    9fa <morecore+0x38>
    return 0;
 9f3:	b8 00 00 00 00       	mov    $0x0,%eax
 9f8:	eb 26                	jmp    a20 <morecore+0x5e>
  hp = (Header*)p;
 9fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a03:	8b 55 08             	mov    0x8(%ebp),%edx
 a06:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0c:	83 c0 08             	add    $0x8,%eax
 a0f:	83 ec 0c             	sub    $0xc,%esp
 a12:	50                   	push   %eax
 a13:	e8 c8 fe ff ff       	call   8e0 <free>
 a18:	83 c4 10             	add    $0x10,%esp
  return freep;
 a1b:	a1 88 4f 01 00       	mov    0x14f88,%eax
}
 a20:	c9                   	leave  
 a21:	c3                   	ret    

00000a22 <malloc>:

void*
malloc(uint nbytes)
{
 a22:	55                   	push   %ebp
 a23:	89 e5                	mov    %esp,%ebp
 a25:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a28:	8b 45 08             	mov    0x8(%ebp),%eax
 a2b:	83 c0 07             	add    $0x7,%eax
 a2e:	c1 e8 03             	shr    $0x3,%eax
 a31:	83 c0 01             	add    $0x1,%eax
 a34:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a37:	a1 88 4f 01 00       	mov    0x14f88,%eax
 a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a43:	75 23                	jne    a68 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a45:	c7 45 f0 80 4f 01 00 	movl   $0x14f80,-0x10(%ebp)
 a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4f:	a3 88 4f 01 00       	mov    %eax,0x14f88
 a54:	a1 88 4f 01 00       	mov    0x14f88,%eax
 a59:	a3 80 4f 01 00       	mov    %eax,0x14f80
    base.s.size = 0;
 a5e:	c7 05 84 4f 01 00 00 	movl   $0x0,0x14f84
 a65:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6b:	8b 00                	mov    (%eax),%eax
 a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a73:	8b 40 04             	mov    0x4(%eax),%eax
 a76:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a79:	77 4d                	ja     ac8 <malloc+0xa6>
      if(p->s.size == nunits)
 a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7e:	8b 40 04             	mov    0x4(%eax),%eax
 a81:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a84:	75 0c                	jne    a92 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a89:	8b 10                	mov    (%eax),%edx
 a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8e:	89 10                	mov    %edx,(%eax)
 a90:	eb 26                	jmp    ab8 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a95:	8b 40 04             	mov    0x4(%eax),%eax
 a98:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a9b:	89 c2                	mov    %eax,%edx
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa6:	8b 40 04             	mov    0x4(%eax),%eax
 aa9:	c1 e0 03             	shl    $0x3,%eax
 aac:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab2:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab5:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abb:	a3 88 4f 01 00       	mov    %eax,0x14f88
      return (void*)(p + 1);
 ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac3:	83 c0 08             	add    $0x8,%eax
 ac6:	eb 3b                	jmp    b03 <malloc+0xe1>
    }
    if(p == freep)
 ac8:	a1 88 4f 01 00       	mov    0x14f88,%eax
 acd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad0:	75 1e                	jne    af0 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ad2:	83 ec 0c             	sub    $0xc,%esp
 ad5:	ff 75 ec             	push   -0x14(%ebp)
 ad8:	e8 e5 fe ff ff       	call   9c2 <morecore>
 add:	83 c4 10             	add    $0x10,%esp
 ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae7:	75 07                	jne    af0 <malloc+0xce>
        return 0;
 ae9:	b8 00 00 00 00       	mov    $0x0,%eax
 aee:	eb 13                	jmp    b03 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af9:	8b 00                	mov    (%eax),%eax
 afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 afe:	e9 6d ff ff ff       	jmp    a70 <malloc+0x4e>
  }
}
 b03:	c9                   	leave  
 b04:	c3                   	ret    
