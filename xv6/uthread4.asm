
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
  67:	e8 6f 05 00 00       	call   5db <exit>
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
  e7:	e8 87 05 00 00       	call   673 <uthread_init>
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
 243:	68 06 0b 00 00       	push   $0xb06
 248:	6a 01                	push   $0x1
 24a:	e8 00 05 00 00       	call   74f <printf>
 24f:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++)
 252:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 259:	eb 1c                	jmp    277 <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int)current_thread);
 25b:	a1 c0 0e 00 00       	mov    0xec0,%eax
 260:	83 ec 04             	sub    $0x4,%esp
 263:	50                   	push   %eax
 264:	68 1c 0b 00 00       	push   $0xb1c
 269:	6a 01                	push   $0x1
 26b:	e8 df 04 00 00       	call   74f <printf>
 270:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++)
 273:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 277:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 27b:	7e de                	jle    25b <child_thread+0x21>
  printf(1, "child thread: exit\n");
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	68 2f 0b 00 00       	push   $0xb2f
 285:	6a 01                	push   $0x1
 287:	e8 c3 04 00 00       	call   74f <printf>
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
 2ac:	68 43 0b 00 00       	push   $0xb43
 2b1:	6a 01                	push   $0x1
 2b3:	e8 97 04 00 00       	call   74f <printf>
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
 30e:	68 56 0b 00 00       	push   $0xb56
 313:	6a 01                	push   $0x1
 315:	e8 35 04 00 00       	call   74f <printf>
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
 368:	e8 6e 02 00 00       	call   5db <exit>

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
 382:	ff e4                	jmp    *%esp

00000384 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 384:	55                   	push   %ebp
 385:	89 e5                	mov    %esp,%ebp
 387:	57                   	push   %edi
 388:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 389:	8b 4d 08             	mov    0x8(%ebp),%ecx
 38c:	8b 55 10             	mov    0x10(%ebp),%edx
 38f:	8b 45 0c             	mov    0xc(%ebp),%eax
 392:	89 cb                	mov    %ecx,%ebx
 394:	89 df                	mov    %ebx,%edi
 396:	89 d1                	mov    %edx,%ecx
 398:	fc                   	cld    
 399:	f3 aa                	rep stos %al,%es:(%edi)
 39b:	89 ca                	mov    %ecx,%edx
 39d:	89 fb                	mov    %edi,%ebx
 39f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3a2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3a5:	90                   	nop
 3a6:	5b                   	pop    %ebx
 3a7:	5f                   	pop    %edi
 3a8:	5d                   	pop    %ebp
 3a9:	c3                   	ret    

000003aa <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3aa:	55                   	push   %ebp
 3ab:	89 e5                	mov    %esp,%ebp
 3ad:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3b6:	90                   	nop
 3b7:	8b 55 0c             	mov    0xc(%ebp),%edx
 3ba:	8d 42 01             	lea    0x1(%edx),%eax
 3bd:	89 45 0c             	mov    %eax,0xc(%ebp)
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	8d 48 01             	lea    0x1(%eax),%ecx
 3c6:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3c9:	0f b6 12             	movzbl (%edx),%edx
 3cc:	88 10                	mov    %dl,(%eax)
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	84 c0                	test   %al,%al
 3d3:	75 e2                	jne    3b7 <strcpy+0xd>
    ;
  return os;
 3d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d8:	c9                   	leave  
 3d9:	c3                   	ret    

000003da <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3dd:	eb 08                	jmp    3e7 <strcmp+0xd>
    p++, q++;
 3df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	0f b6 00             	movzbl (%eax),%eax
 3ed:	84 c0                	test   %al,%al
 3ef:	74 10                	je     401 <strcmp+0x27>
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	0f b6 10             	movzbl (%eax),%edx
 3f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fa:	0f b6 00             	movzbl (%eax),%eax
 3fd:	38 c2                	cmp    %al,%dl
 3ff:	74 de                	je     3df <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 401:	8b 45 08             	mov    0x8(%ebp),%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	0f b6 d0             	movzbl %al,%edx
 40a:	8b 45 0c             	mov    0xc(%ebp),%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	0f b6 c8             	movzbl %al,%ecx
 413:	89 d0                	mov    %edx,%eax
 415:	29 c8                	sub    %ecx,%eax
}
 417:	5d                   	pop    %ebp
 418:	c3                   	ret    

00000419 <strlen>:

uint
strlen(char *s)
{
 419:	55                   	push   %ebp
 41a:	89 e5                	mov    %esp,%ebp
 41c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 41f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 426:	eb 04                	jmp    42c <strlen+0x13>
 428:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 42c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	01 d0                	add    %edx,%eax
 434:	0f b6 00             	movzbl (%eax),%eax
 437:	84 c0                	test   %al,%al
 439:	75 ed                	jne    428 <strlen+0xf>
    ;
  return n;
 43b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 43e:	c9                   	leave  
 43f:	c3                   	ret    

00000440 <memset>:

void*
memset(void *dst, int c, uint n)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 443:	8b 45 10             	mov    0x10(%ebp),%eax
 446:	50                   	push   %eax
 447:	ff 75 0c             	push   0xc(%ebp)
 44a:	ff 75 08             	push   0x8(%ebp)
 44d:	e8 32 ff ff ff       	call   384 <stosb>
 452:	83 c4 0c             	add    $0xc,%esp
  return dst;
 455:	8b 45 08             	mov    0x8(%ebp),%eax
}
 458:	c9                   	leave  
 459:	c3                   	ret    

0000045a <strchr>:

char*
strchr(const char *s, char c)
{
 45a:	55                   	push   %ebp
 45b:	89 e5                	mov    %esp,%ebp
 45d:	83 ec 04             	sub    $0x4,%esp
 460:	8b 45 0c             	mov    0xc(%ebp),%eax
 463:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 466:	eb 14                	jmp    47c <strchr+0x22>
    if(*s == c)
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	0f b6 00             	movzbl (%eax),%eax
 46e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 471:	75 05                	jne    478 <strchr+0x1e>
      return (char*)s;
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	eb 13                	jmp    48b <strchr+0x31>
  for(; *s; s++)
 478:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
 47f:	0f b6 00             	movzbl (%eax),%eax
 482:	84 c0                	test   %al,%al
 484:	75 e2                	jne    468 <strchr+0xe>
  return 0;
 486:	b8 00 00 00 00       	mov    $0x0,%eax
}
 48b:	c9                   	leave  
 48c:	c3                   	ret    

0000048d <gets>:

char*
gets(char *buf, int max)
{
 48d:	55                   	push   %ebp
 48e:	89 e5                	mov    %esp,%ebp
 490:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 493:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 49a:	eb 42                	jmp    4de <gets+0x51>
    cc = read(0, &c, 1);
 49c:	83 ec 04             	sub    $0x4,%esp
 49f:	6a 01                	push   $0x1
 4a1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a4:	50                   	push   %eax
 4a5:	6a 00                	push   $0x0
 4a7:	e8 47 01 00 00       	call   5f3 <read>
 4ac:	83 c4 10             	add    $0x10,%esp
 4af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b6:	7e 33                	jle    4eb <gets+0x5e>
      break;
    buf[i++] = c;
 4b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bb:	8d 50 01             	lea    0x1(%eax),%edx
 4be:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c1:	89 c2                	mov    %eax,%edx
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	01 c2                	add    %eax,%edx
 4c8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4cc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4ce:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d2:	3c 0a                	cmp    $0xa,%al
 4d4:	74 16                	je     4ec <gets+0x5f>
 4d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4da:	3c 0d                	cmp    $0xd,%al
 4dc:	74 0e                	je     4ec <gets+0x5f>
  for(i=0; i+1 < max; ){
 4de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e1:	83 c0 01             	add    $0x1,%eax
 4e4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4e7:	7f b3                	jg     49c <gets+0xf>
 4e9:	eb 01                	jmp    4ec <gets+0x5f>
      break;
 4eb:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4ef:	8b 45 08             	mov    0x8(%ebp),%eax
 4f2:	01 d0                	add    %edx,%eax
 4f4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4fa:	c9                   	leave  
 4fb:	c3                   	ret    

000004fc <stat>:

int
stat(char *n, struct stat *st)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 502:	83 ec 08             	sub    $0x8,%esp
 505:	6a 00                	push   $0x0
 507:	ff 75 08             	push   0x8(%ebp)
 50a:	e8 14 01 00 00       	call   623 <open>
 50f:	83 c4 10             	add    $0x10,%esp
 512:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 515:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 519:	79 07                	jns    522 <stat+0x26>
    return -1;
 51b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 520:	eb 25                	jmp    547 <stat+0x4b>
  r = fstat(fd, st);
 522:	83 ec 08             	sub    $0x8,%esp
 525:	ff 75 0c             	push   0xc(%ebp)
 528:	ff 75 f4             	push   -0xc(%ebp)
 52b:	e8 0b 01 00 00       	call   63b <fstat>
 530:	83 c4 10             	add    $0x10,%esp
 533:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 536:	83 ec 0c             	sub    $0xc,%esp
 539:	ff 75 f4             	push   -0xc(%ebp)
 53c:	e8 c2 00 00 00       	call   603 <close>
 541:	83 c4 10             	add    $0x10,%esp
  return r;
 544:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 547:	c9                   	leave  
 548:	c3                   	ret    

00000549 <atoi>:

int
atoi(const char *s)
{
 549:	55                   	push   %ebp
 54a:	89 e5                	mov    %esp,%ebp
 54c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 54f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 556:	eb 25                	jmp    57d <atoi+0x34>
    n = n*10 + *s++ - '0';
 558:	8b 55 fc             	mov    -0x4(%ebp),%edx
 55b:	89 d0                	mov    %edx,%eax
 55d:	c1 e0 02             	shl    $0x2,%eax
 560:	01 d0                	add    %edx,%eax
 562:	01 c0                	add    %eax,%eax
 564:	89 c1                	mov    %eax,%ecx
 566:	8b 45 08             	mov    0x8(%ebp),%eax
 569:	8d 50 01             	lea    0x1(%eax),%edx
 56c:	89 55 08             	mov    %edx,0x8(%ebp)
 56f:	0f b6 00             	movzbl (%eax),%eax
 572:	0f be c0             	movsbl %al,%eax
 575:	01 c8                	add    %ecx,%eax
 577:	83 e8 30             	sub    $0x30,%eax
 57a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	0f b6 00             	movzbl (%eax),%eax
 583:	3c 2f                	cmp    $0x2f,%al
 585:	7e 0a                	jle    591 <atoi+0x48>
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	0f b6 00             	movzbl (%eax),%eax
 58d:	3c 39                	cmp    $0x39,%al
 58f:	7e c7                	jle    558 <atoi+0xf>
  return n;
 591:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 594:	c9                   	leave  
 595:	c3                   	ret    

00000596 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 596:	55                   	push   %ebp
 597:	89 e5                	mov    %esp,%ebp
 599:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 59c:	8b 45 08             	mov    0x8(%ebp),%eax
 59f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5a8:	eb 17                	jmp    5c1 <memmove+0x2b>
    *dst++ = *src++;
 5aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5ad:	8d 42 01             	lea    0x1(%edx),%eax
 5b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b6:	8d 48 01             	lea    0x1(%eax),%ecx
 5b9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5bc:	0f b6 12             	movzbl (%edx),%edx
 5bf:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5c1:	8b 45 10             	mov    0x10(%ebp),%eax
 5c4:	8d 50 ff             	lea    -0x1(%eax),%edx
 5c7:	89 55 10             	mov    %edx,0x10(%ebp)
 5ca:	85 c0                	test   %eax,%eax
 5cc:	7f dc                	jg     5aa <memmove+0x14>
  return vdst;
 5ce:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d1:	c9                   	leave  
 5d2:	c3                   	ret    

000005d3 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 5d3:	b8 01 00 00 00       	mov    $0x1,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret    

000005db <exit>:
SYSCALL(exit)
 5db:	b8 02 00 00 00       	mov    $0x2,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret    

000005e3 <wait>:
SYSCALL(wait)
 5e3:	b8 03 00 00 00       	mov    $0x3,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret    

000005eb <pipe>:
SYSCALL(pipe)
 5eb:	b8 04 00 00 00       	mov    $0x4,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret    

000005f3 <read>:
SYSCALL(read)
 5f3:	b8 05 00 00 00       	mov    $0x5,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret    

000005fb <write>:
SYSCALL(write)
 5fb:	b8 10 00 00 00       	mov    $0x10,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <close>:
SYSCALL(close)
 603:	b8 15 00 00 00       	mov    $0x15,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <kill>:
SYSCALL(kill)
 60b:	b8 06 00 00 00       	mov    $0x6,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <dup>:
SYSCALL(dup)
 613:	b8 0a 00 00 00       	mov    $0xa,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <exec>:
SYSCALL(exec)
 61b:	b8 07 00 00 00       	mov    $0x7,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <open>:
SYSCALL(open)
 623:	b8 0f 00 00 00       	mov    $0xf,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <mknod>:
SYSCALL(mknod)
 62b:	b8 11 00 00 00       	mov    $0x11,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    

00000633 <unlink>:
SYSCALL(unlink)
 633:	b8 12 00 00 00       	mov    $0x12,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret    

0000063b <fstat>:
SYSCALL(fstat)
 63b:	b8 08 00 00 00       	mov    $0x8,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret    

00000643 <link>:
SYSCALL(link)
 643:	b8 13 00 00 00       	mov    $0x13,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret    

0000064b <mkdir>:
SYSCALL(mkdir)
 64b:	b8 14 00 00 00       	mov    $0x14,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret    

00000653 <chdir>:
SYSCALL(chdir)
 653:	b8 09 00 00 00       	mov    $0x9,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret    

0000065b <sbrk>:
SYSCALL(sbrk)
 65b:	b8 0c 00 00 00       	mov    $0xc,%eax
 660:	cd 40                	int    $0x40
 662:	c3                   	ret    

00000663 <sleep>:
SYSCALL(sleep)
 663:	b8 0d 00 00 00       	mov    $0xd,%eax
 668:	cd 40                	int    $0x40
 66a:	c3                   	ret    

0000066b <getpid>:
SYSCALL(getpid)
 66b:	b8 0b 00 00 00       	mov    $0xb,%eax
 670:	cd 40                	int    $0x40
 672:	c3                   	ret    

00000673 <uthread_init>:
SYSCALL(uthread_init)
 673:	b8 18 00 00 00       	mov    $0x18,%eax
 678:	cd 40                	int    $0x40
 67a:	c3                   	ret    

0000067b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 67b:	55                   	push   %ebp
 67c:	89 e5                	mov    %esp,%ebp
 67e:	83 ec 18             	sub    $0x18,%esp
 681:	8b 45 0c             	mov    0xc(%ebp),%eax
 684:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 687:	83 ec 04             	sub    $0x4,%esp
 68a:	6a 01                	push   $0x1
 68c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68f:	50                   	push   %eax
 690:	ff 75 08             	push   0x8(%ebp)
 693:	e8 63 ff ff ff       	call   5fb <write>
 698:	83 c4 10             	add    $0x10,%esp
}
 69b:	90                   	nop
 69c:	c9                   	leave  
 69d:	c3                   	ret    

0000069e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69e:	55                   	push   %ebp
 69f:	89 e5                	mov    %esp,%ebp
 6a1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ab:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6af:	74 17                	je     6c8 <printint+0x2a>
 6b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b5:	79 11                	jns    6c8 <printint+0x2a>
    neg = 1;
 6b7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6be:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c1:	f7 d8                	neg    %eax
 6c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c6:	eb 06                	jmp    6ce <printint+0x30>
  } else {
    x = xx;
 6c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6db:	ba 00 00 00 00       	mov    $0x0,%edx
 6e0:	f7 f1                	div    %ecx
 6e2:	89 d1                	mov    %edx,%ecx
 6e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e7:	8d 50 01             	lea    0x1(%eax),%edx
 6ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6ed:	0f b6 91 94 0e 00 00 	movzbl 0xe94(%ecx),%edx
 6f4:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fe:	ba 00 00 00 00       	mov    $0x0,%edx
 703:	f7 f1                	div    %ecx
 705:	89 45 ec             	mov    %eax,-0x14(%ebp)
 708:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70c:	75 c7                	jne    6d5 <printint+0x37>
  if(neg)
 70e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 712:	74 2d                	je     741 <printint+0xa3>
    buf[i++] = '-';
 714:	8b 45 f4             	mov    -0xc(%ebp),%eax
 717:	8d 50 01             	lea    0x1(%eax),%edx
 71a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 722:	eb 1d                	jmp    741 <printint+0xa3>
    putc(fd, buf[i]);
 724:	8d 55 dc             	lea    -0x24(%ebp),%edx
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	01 d0                	add    %edx,%eax
 72c:	0f b6 00             	movzbl (%eax),%eax
 72f:	0f be c0             	movsbl %al,%eax
 732:	83 ec 08             	sub    $0x8,%esp
 735:	50                   	push   %eax
 736:	ff 75 08             	push   0x8(%ebp)
 739:	e8 3d ff ff ff       	call   67b <putc>
 73e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 741:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 745:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 749:	79 d9                	jns    724 <printint+0x86>
}
 74b:	90                   	nop
 74c:	90                   	nop
 74d:	c9                   	leave  
 74e:	c3                   	ret    

0000074f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 74f:	55                   	push   %ebp
 750:	89 e5                	mov    %esp,%ebp
 752:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 755:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 75c:	8d 45 0c             	lea    0xc(%ebp),%eax
 75f:	83 c0 04             	add    $0x4,%eax
 762:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 765:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 76c:	e9 59 01 00 00       	jmp    8ca <printf+0x17b>
    c = fmt[i] & 0xff;
 771:	8b 55 0c             	mov    0xc(%ebp),%edx
 774:	8b 45 f0             	mov    -0x10(%ebp),%eax
 777:	01 d0                	add    %edx,%eax
 779:	0f b6 00             	movzbl (%eax),%eax
 77c:	0f be c0             	movsbl %al,%eax
 77f:	25 ff 00 00 00       	and    $0xff,%eax
 784:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 787:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 78b:	75 2c                	jne    7b9 <printf+0x6a>
      if(c == '%'){
 78d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 791:	75 0c                	jne    79f <printf+0x50>
        state = '%';
 793:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 79a:	e9 27 01 00 00       	jmp    8c6 <printf+0x177>
      } else {
        putc(fd, c);
 79f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a2:	0f be c0             	movsbl %al,%eax
 7a5:	83 ec 08             	sub    $0x8,%esp
 7a8:	50                   	push   %eax
 7a9:	ff 75 08             	push   0x8(%ebp)
 7ac:	e8 ca fe ff ff       	call   67b <putc>
 7b1:	83 c4 10             	add    $0x10,%esp
 7b4:	e9 0d 01 00 00       	jmp    8c6 <printf+0x177>
      }
    } else if(state == '%'){
 7b9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7bd:	0f 85 03 01 00 00    	jne    8c6 <printf+0x177>
      if(c == 'd'){
 7c3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c7:	75 1e                	jne    7e7 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	6a 01                	push   $0x1
 7d0:	6a 0a                	push   $0xa
 7d2:	50                   	push   %eax
 7d3:	ff 75 08             	push   0x8(%ebp)
 7d6:	e8 c3 fe ff ff       	call   69e <printint>
 7db:	83 c4 10             	add    $0x10,%esp
        ap++;
 7de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e2:	e9 d8 00 00 00       	jmp    8bf <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7e7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7eb:	74 06                	je     7f3 <printf+0xa4>
 7ed:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f1:	75 1e                	jne    811 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	6a 00                	push   $0x0
 7fa:	6a 10                	push   $0x10
 7fc:	50                   	push   %eax
 7fd:	ff 75 08             	push   0x8(%ebp)
 800:	e8 99 fe ff ff       	call   69e <printint>
 805:	83 c4 10             	add    $0x10,%esp
        ap++;
 808:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80c:	e9 ae 00 00 00       	jmp    8bf <printf+0x170>
      } else if(c == 's'){
 811:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 815:	75 43                	jne    85a <printf+0x10b>
        s = (char*)*ap;
 817:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 81f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 823:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 827:	75 25                	jne    84e <printf+0xff>
          s = "(null)";
 829:	c7 45 f4 67 0b 00 00 	movl   $0xb67,-0xc(%ebp)
        while(*s != 0){
 830:	eb 1c                	jmp    84e <printf+0xff>
          putc(fd, *s);
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	0f b6 00             	movzbl (%eax),%eax
 838:	0f be c0             	movsbl %al,%eax
 83b:	83 ec 08             	sub    $0x8,%esp
 83e:	50                   	push   %eax
 83f:	ff 75 08             	push   0x8(%ebp)
 842:	e8 34 fe ff ff       	call   67b <putc>
 847:	83 c4 10             	add    $0x10,%esp
          s++;
 84a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 84e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 851:	0f b6 00             	movzbl (%eax),%eax
 854:	84 c0                	test   %al,%al
 856:	75 da                	jne    832 <printf+0xe3>
 858:	eb 65                	jmp    8bf <printf+0x170>
        }
      } else if(c == 'c'){
 85a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 85e:	75 1d                	jne    87d <printf+0x12e>
        putc(fd, *ap);
 860:	8b 45 e8             	mov    -0x18(%ebp),%eax
 863:	8b 00                	mov    (%eax),%eax
 865:	0f be c0             	movsbl %al,%eax
 868:	83 ec 08             	sub    $0x8,%esp
 86b:	50                   	push   %eax
 86c:	ff 75 08             	push   0x8(%ebp)
 86f:	e8 07 fe ff ff       	call   67b <putc>
 874:	83 c4 10             	add    $0x10,%esp
        ap++;
 877:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 87b:	eb 42                	jmp    8bf <printf+0x170>
      } else if(c == '%'){
 87d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 881:	75 17                	jne    89a <printf+0x14b>
        putc(fd, c);
 883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 886:	0f be c0             	movsbl %al,%eax
 889:	83 ec 08             	sub    $0x8,%esp
 88c:	50                   	push   %eax
 88d:	ff 75 08             	push   0x8(%ebp)
 890:	e8 e6 fd ff ff       	call   67b <putc>
 895:	83 c4 10             	add    $0x10,%esp
 898:	eb 25                	jmp    8bf <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 89a:	83 ec 08             	sub    $0x8,%esp
 89d:	6a 25                	push   $0x25
 89f:	ff 75 08             	push   0x8(%ebp)
 8a2:	e8 d4 fd ff ff       	call   67b <putc>
 8a7:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ad:	0f be c0             	movsbl %al,%eax
 8b0:	83 ec 08             	sub    $0x8,%esp
 8b3:	50                   	push   %eax
 8b4:	ff 75 08             	push   0x8(%ebp)
 8b7:	e8 bf fd ff ff       	call   67b <putc>
 8bc:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8c6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 8cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d0:	01 d0                	add    %edx,%eax
 8d2:	0f b6 00             	movzbl (%eax),%eax
 8d5:	84 c0                	test   %al,%al
 8d7:	0f 85 94 fe ff ff    	jne    771 <printf+0x22>
    }
  }
}
 8dd:	90                   	nop
 8de:	90                   	nop
 8df:	c9                   	leave  
 8e0:	c3                   	ret    

000008e1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e1:	55                   	push   %ebp
 8e2:	89 e5                	mov    %esp,%ebp
 8e4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ea:	83 e8 08             	sub    $0x8,%eax
 8ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f0:	a1 88 4f 01 00       	mov    0x14f88,%eax
 8f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f8:	eb 24                	jmp    91e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fd:	8b 00                	mov    (%eax),%eax
 8ff:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 902:	72 12                	jb     916 <free+0x35>
 904:	8b 45 f8             	mov    -0x8(%ebp),%eax
 907:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 90a:	77 24                	ja     930 <free+0x4f>
 90c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90f:	8b 00                	mov    (%eax),%eax
 911:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 914:	72 1a                	jb     930 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	8b 00                	mov    (%eax),%eax
 91b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 921:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 924:	76 d4                	jbe    8fa <free+0x19>
 926:	8b 45 fc             	mov    -0x4(%ebp),%eax
 929:	8b 00                	mov    (%eax),%eax
 92b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 92e:	73 ca                	jae    8fa <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 930:	8b 45 f8             	mov    -0x8(%ebp),%eax
 933:	8b 40 04             	mov    0x4(%eax),%eax
 936:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	01 c2                	add    %eax,%edx
 942:	8b 45 fc             	mov    -0x4(%ebp),%eax
 945:	8b 00                	mov    (%eax),%eax
 947:	39 c2                	cmp    %eax,%edx
 949:	75 24                	jne    96f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	8b 50 04             	mov    0x4(%eax),%edx
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	01 c2                	add    %eax,%edx
 95b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	8b 10                	mov    (%eax),%edx
 968:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96b:	89 10                	mov    %edx,(%eax)
 96d:	eb 0a                	jmp    979 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 96f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 972:	8b 10                	mov    (%eax),%edx
 974:	8b 45 f8             	mov    -0x8(%ebp),%eax
 977:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	8b 40 04             	mov    0x4(%eax),%eax
 97f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 986:	8b 45 fc             	mov    -0x4(%ebp),%eax
 989:	01 d0                	add    %edx,%eax
 98b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 98e:	75 20                	jne    9b0 <free+0xcf>
    p->s.size += bp->s.size;
 990:	8b 45 fc             	mov    -0x4(%ebp),%eax
 993:	8b 50 04             	mov    0x4(%eax),%edx
 996:	8b 45 f8             	mov    -0x8(%ebp),%eax
 999:	8b 40 04             	mov    0x4(%eax),%eax
 99c:	01 c2                	add    %eax,%edx
 99e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a7:	8b 10                	mov    (%eax),%edx
 9a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ac:	89 10                	mov    %edx,(%eax)
 9ae:	eb 08                	jmp    9b8 <free+0xd7>
  } else
    p->s.ptr = bp;
 9b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9b6:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	a3 88 4f 01 00       	mov    %eax,0x14f88
}
 9c0:	90                   	nop
 9c1:	c9                   	leave  
 9c2:	c3                   	ret    

000009c3 <morecore>:

static Header*
morecore(uint nu)
{
 9c3:	55                   	push   %ebp
 9c4:	89 e5                	mov    %esp,%ebp
 9c6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9d0:	77 07                	ja     9d9 <morecore+0x16>
    nu = 4096;
 9d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d9:	8b 45 08             	mov    0x8(%ebp),%eax
 9dc:	c1 e0 03             	shl    $0x3,%eax
 9df:	83 ec 0c             	sub    $0xc,%esp
 9e2:	50                   	push   %eax
 9e3:	e8 73 fc ff ff       	call   65b <sbrk>
 9e8:	83 c4 10             	add    $0x10,%esp
 9eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f2:	75 07                	jne    9fb <morecore+0x38>
    return 0;
 9f4:	b8 00 00 00 00       	mov    $0x0,%eax
 9f9:	eb 26                	jmp    a21 <morecore+0x5e>
  hp = (Header*)p;
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a04:	8b 55 08             	mov    0x8(%ebp),%edx
 a07:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0d:	83 c0 08             	add    $0x8,%eax
 a10:	83 ec 0c             	sub    $0xc,%esp
 a13:	50                   	push   %eax
 a14:	e8 c8 fe ff ff       	call   8e1 <free>
 a19:	83 c4 10             	add    $0x10,%esp
  return freep;
 a1c:	a1 88 4f 01 00       	mov    0x14f88,%eax
}
 a21:	c9                   	leave  
 a22:	c3                   	ret    

00000a23 <malloc>:

void*
malloc(uint nbytes)
{
 a23:	55                   	push   %ebp
 a24:	89 e5                	mov    %esp,%ebp
 a26:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a29:	8b 45 08             	mov    0x8(%ebp),%eax
 a2c:	83 c0 07             	add    $0x7,%eax
 a2f:	c1 e8 03             	shr    $0x3,%eax
 a32:	83 c0 01             	add    $0x1,%eax
 a35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a38:	a1 88 4f 01 00       	mov    0x14f88,%eax
 a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a44:	75 23                	jne    a69 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a46:	c7 45 f0 80 4f 01 00 	movl   $0x14f80,-0x10(%ebp)
 a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a50:	a3 88 4f 01 00       	mov    %eax,0x14f88
 a55:	a1 88 4f 01 00       	mov    0x14f88,%eax
 a5a:	a3 80 4f 01 00       	mov    %eax,0x14f80
    base.s.size = 0;
 a5f:	c7 05 84 4f 01 00 00 	movl   $0x0,0x14f84
 a66:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6c:	8b 00                	mov    (%eax),%eax
 a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	8b 40 04             	mov    0x4(%eax),%eax
 a77:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a7a:	77 4d                	ja     ac9 <malloc+0xa6>
      if(p->s.size == nunits)
 a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7f:	8b 40 04             	mov    0x4(%eax),%eax
 a82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a85:	75 0c                	jne    a93 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 10                	mov    (%eax),%edx
 a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8f:	89 10                	mov    %edx,(%eax)
 a91:	eb 26                	jmp    ab9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a96:	8b 40 04             	mov    0x4(%eax),%eax
 a99:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a9c:	89 c2                	mov    %eax,%edx
 a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa7:	8b 40 04             	mov    0x4(%eax),%eax
 aaa:	c1 e0 03             	shl    $0x3,%eax
 aad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abc:	a3 88 4f 01 00       	mov    %eax,0x14f88
      return (void*)(p + 1);
 ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac4:	83 c0 08             	add    $0x8,%eax
 ac7:	eb 3b                	jmp    b04 <malloc+0xe1>
    }
    if(p == freep)
 ac9:	a1 88 4f 01 00       	mov    0x14f88,%eax
 ace:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad1:	75 1e                	jne    af1 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ad3:	83 ec 0c             	sub    $0xc,%esp
 ad6:	ff 75 ec             	push   -0x14(%ebp)
 ad9:	e8 e5 fe ff ff       	call   9c3 <morecore>
 ade:	83 c4 10             	add    $0x10,%esp
 ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae8:	75 07                	jne    af1 <malloc+0xce>
        return 0;
 aea:	b8 00 00 00 00       	mov    $0x0,%eax
 aef:	eb 13                	jmp    b04 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afa:	8b 00                	mov    (%eax),%eax
 afc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aff:	e9 6d ff ff ff       	jmp    a71 <malloc+0x4e>
  }
}
 b04:	c9                   	leave  
 b05:	c3                   	ret    
