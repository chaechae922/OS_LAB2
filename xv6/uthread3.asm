
_uthread3:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
extern void thread_switch(void);

// Core scheduler: pick RUNNABLE != current, round-robin
static void
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  thread_p prev = current_thread;
   6:	a1 20 10 00 00       	mov    0x1020,%eax
   b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int start = prev - all_thread;
   e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  11:	2d 40 10 00 00       	sub    $0x1040,%eax
  16:	c1 f8 02             	sar    $0x2,%eax
  19:	69 c0 ab e2 f8 12    	imul   $0x12f8e2ab,%eax,%eax
  1f:	89 45 e8             	mov    %eax,-0x18(%ebp)

  for (int i = 1; i < MAX_THREAD; i++) {
  22:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  29:	e9 9b 00 00 00       	jmp    c9 <thread_schedule+0xc9>
    int idx = (start + i) % MAX_THREAD;
  2e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  37:	ba 67 66 66 66       	mov    $0x66666667,%edx
  3c:	89 c8                	mov    %ecx,%eax
  3e:	f7 ea                	imul   %edx
  40:	89 d0                	mov    %edx,%eax
  42:	c1 f8 02             	sar    $0x2,%eax
  45:	89 ca                	mov    %ecx,%edx
  47:	c1 fa 1f             	sar    $0x1f,%edx
  4a:	29 d0                	sub    %edx,%eax
  4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  52:	89 d0                	mov    %edx,%eax
  54:	c1 e0 02             	shl    $0x2,%eax
  57:	01 d0                	add    %edx,%eax
  59:	01 c0                	add    %eax,%eax
  5b:	29 c1                	sub    %eax,%ecx
  5d:	89 ca                	mov    %ecx,%edx
  5f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    if (all_thread[idx].state == RUNNABLE) {
  62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  65:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
  6b:	05 44 30 00 00       	add    $0x3044,%eax
  70:	8b 00                	mov    (%eax),%eax
  72:	83 f8 02             	cmp    $0x2,%eax
  75:	75 4e                	jne    c5 <thread_schedule+0xc5>
      next_thread = &all_thread[idx];
  77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  7a:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
  80:	05 40 10 00 00       	add    $0x1040,%eax
  85:	a3 24 10 00 00       	mov    %eax,0x1024
      if (prev->state == RUNNING)
  8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  93:	83 f8 01             	cmp    $0x1,%eax
  96:	75 0d                	jne    a5 <thread_schedule+0xa5>
        prev->state = RUNNABLE;
  98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  9b:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  a2:	00 00 00 
      next_thread->state = RUNNING;
  a5:	a1 24 10 00 00       	mov    0x1024,%eax
  aa:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  b1:	00 00 00 
      thread_switch();
  b4:	e8 c8 03 00 00       	call   481 <thread_switch>
      current_thread = next_thread;
  b9:	a1 24 10 00 00       	mov    0x1024,%eax
  be:	a3 20 10 00 00       	mov    %eax,0x1020
      return;
  c3:	eb 63                	jmp    128 <thread_schedule+0x128>
  for (int i = 1; i < MAX_THREAD; i++) {
  c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  c9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  cd:	0f 8e 5b ff ff ff    	jle    2e <thread_schedule+0x2e>
    }
  }

  // 아무것도 없으면 종료
  for (int i = 0; i < MAX_THREAD; i++) {
  d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  da:	eb 2e                	jmp    10a <thread_schedule+0x10a>
    if (all_thread[i].state == RUNNABLE || all_thread[i].state == WAIT)
  dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  df:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
  e5:	05 44 30 00 00       	add    $0x3044,%eax
  ea:	8b 00                	mov    (%eax),%eax
  ec:	83 f8 02             	cmp    $0x2,%eax
  ef:	74 36                	je     127 <thread_schedule+0x127>
  f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  f4:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
  fa:	05 44 30 00 00       	add    $0x3044,%eax
  ff:	8b 00                	mov    (%eax),%eax
 101:	83 f8 03             	cmp    $0x3,%eax
 104:	74 21                	je     127 <thread_schedule+0x127>
  for (int i = 0; i < MAX_THREAD; i++) {
 106:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 10a:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 10e:	7e cc                	jle    dc <thread_schedule+0xdc>
      return;
  }

  printf(2, "thread_schedule: no runnable threads\n");
 110:	83 ec 08             	sub    $0x8,%esp
 113:	68 1c 0c 00 00       	push   $0xc1c
 118:	6a 02                	push   $0x2
 11a:	e8 43 07 00 00       	call   862 <printf>
 11f:	83 c4 10             	add    $0x10,%esp
  exit();
 122:	e8 c7 05 00 00       	call   6ee <exit>
      return;
 127:	90                   	nop
}
 128:	c9                   	leave  
 129:	c3                   	ret    

0000012a <thread_init>:

// Initialize main thread
void
thread_init(void)
{
 12a:	55                   	push   %ebp
 12b:	89 e5                	mov    %esp,%ebp
 12d:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < MAX_THREAD; i++)
 130:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 137:	eb 18                	jmp    151 <thread_init+0x27>
    all_thread[i].state = FREE;
 139:	8b 45 fc             	mov    -0x4(%ebp),%eax
 13c:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
 142:	05 44 30 00 00       	add    $0x3044,%eax
 147:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for (int i = 0; i < MAX_THREAD; i++)
 14d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 151:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
 155:	7e e2                	jle    139 <thread_init+0xf>
  current_thread = &all_thread[0];
 157:	c7 05 20 10 00 00 40 	movl   $0x1040,0x1020
 15e:	10 00 00 
  current_thread->state = RUNNING;
 161:	a1 20 10 00 00       	mov    0x1020,%eax
 166:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 16d:	00 00 00 
  current_thread->tid = 0;
 170:	a1 20 10 00 00       	mov    0x1020,%eax
 175:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 17c:	00 00 00 
}
 17f:	90                   	nop
 180:	c9                   	leave  
 181:	c3                   	ret    

00000182 <thread_create>:

// Create a new thread, return tid
int
thread_create(void (*func)())
{
 182:	55                   	push   %ebp
 183:	89 e5                	mov    %esp,%ebp
 185:	83 ec 10             	sub    $0x10,%esp
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 188:	c7 45 fc 40 10 00 00 	movl   $0x1040,-0x4(%ebp)
 18f:	eb 14                	jmp    1a5 <thread_create+0x23>
    if (t->state == FREE)
 191:	8b 45 fc             	mov    -0x4(%ebp),%eax
 194:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 19a:	85 c0                	test   %eax,%eax
 19c:	74 13                	je     1b1 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 19e:	81 45 fc 0c 20 00 00 	addl   $0x200c,-0x4(%ebp)
 1a5:	b8 b8 50 01 00       	mov    $0x150b8,%eax
 1aa:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 1ad:	72 e2                	jb     191 <thread_create+0xf>
 1af:	eb 01                	jmp    1b2 <thread_create+0x30>
      break;
 1b1:	90                   	nop
  if (t == all_thread + MAX_THREAD)
 1b2:	b8 b8 50 01 00       	mov    $0x150b8,%eax
 1b7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 1ba:	75 07                	jne    1c3 <thread_create+0x41>
    return -1;
 1bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c1:	eb 6a                	jmp    22d <thread_create+0xab>
  t->tid = t - all_thread;
 1c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c6:	2d 40 10 00 00       	sub    $0x1040,%eax
 1cb:	c1 f8 02             	sar    $0x2,%eax
 1ce:	69 c0 ab e2 f8 12    	imul   $0x12f8e2ab,%eax,%eax
 1d4:	89 c2                	mov    %eax,%edx
 1d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1d9:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->sp = (int)(t->stack + STACK_SIZE);
 1df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1e2:	83 c0 04             	add    $0x4,%eax
 1e5:	05 00 20 00 00       	add    $0x2000,%eax
 1ea:	89 c2                	mov    %eax,%edx
 1ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1ef:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                  // return addr
 1f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1f4:	8b 00                	mov    (%eax),%eax
 1f6:	8d 50 fc             	lea    -0x4(%eax),%edx
 1f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1fc:	89 10                	mov    %edx,(%eax)
  *((int*)(t->sp)) = (int)func;
 1fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 201:	8b 00                	mov    (%eax),%eax
 203:	89 c2                	mov    %eax,%edx
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                 // space for regs
 20a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 20d:	8b 00                	mov    (%eax),%eax
 20f:	8d 50 e0             	lea    -0x20(%eax),%edx
 212:	8b 45 fc             	mov    -0x4(%ebp),%eax
 215:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 217:	8b 45 fc             	mov    -0x4(%ebp),%eax
 21a:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 221:	00 00 00 
  return t->tid;
 224:	8b 45 fc             	mov    -0x4(%ebp),%eax
 227:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <thread_yield>:

// Yield CPU
void
thread_yield(void)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 08             	sub    $0x8,%esp
  thread_schedule();
 235:	e8 c6 fd ff ff       	call   0 <thread_schedule>
}
 23a:	90                   	nop
 23b:	c9                   	leave  
 23c:	c3                   	ret    

0000023d <thread_sleep>:

// User-level sleep
void
thread_sleep(int ticks)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
 240:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < ticks; i++)
 243:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 24a:	eb 09                	jmp    255 <thread_sleep+0x18>
    thread_yield();
 24c:	e8 de ff ff ff       	call   22f <thread_yield>
  for (int i = 0; i < ticks; i++)
 251:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 255:	8b 45 f4             	mov    -0xc(%ebp),%eax
 258:	3b 45 08             	cmp    0x8(%ebp),%eax
 25b:	7c ef                	jl     24c <thread_sleep+0xf>
}
 25d:	90                   	nop
 25e:	90                   	nop
 25f:	c9                   	leave  
 260:	c3                   	ret    

00000261 <thread_suspend>:

// Suspend a thread and immediately reschedule
void
thread_suspend(int tid)
{
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	83 ec 18             	sub    $0x18,%esp
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
 267:	c7 45 f4 40 10 00 00 	movl   $0x1040,-0xc(%ebp)
 26e:	eb 64                	jmp    2d4 <thread_suspend+0x73>
    if ((t->state == RUNNABLE || t->state == RUNNING) && t->tid == tid) {
 270:	8b 45 f4             	mov    -0xc(%ebp),%eax
 273:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 279:	83 f8 02             	cmp    $0x2,%eax
 27c:	74 0e                	je     28c <thread_suspend+0x2b>
 27e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 281:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 287:	83 f8 01             	cmp    $0x1,%eax
 28a:	75 41                	jne    2cd <thread_suspend+0x6c>
 28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28f:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 295:	39 45 08             	cmp    %eax,0x8(%ebp)
 298:	75 33                	jne    2cd <thread_suspend+0x6c>
      t->state = WAIT;
 29a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29d:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 2a4:	00 00 00 
      printf(1, "[suspend] Suspending thread %d\n", tid);
 2a7:	83 ec 04             	sub    $0x4,%esp
 2aa:	ff 75 08             	push   0x8(%ebp)
 2ad:	68 44 0c 00 00       	push   $0xc44
 2b2:	6a 01                	push   $0x1
 2b4:	e8 a9 05 00 00       	call   862 <printf>
 2b9:	83 c4 10             	add    $0x10,%esp
      if (t == current_thread) {
 2bc:	a1 20 10 00 00       	mov    0x1020,%eax
 2c1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 2c4:	75 1a                	jne    2e0 <thread_suspend+0x7f>
        thread_schedule();
 2c6:	e8 35 fd ff ff       	call   0 <thread_schedule>
      }
      return;
 2cb:	eb 13                	jmp    2e0 <thread_suspend+0x7f>
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
 2cd:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
 2d4:	b8 b8 50 01 00       	mov    $0x150b8,%eax
 2d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 2dc:	72 92                	jb     270 <thread_suspend+0xf>
 2de:	eb 01                	jmp    2e1 <thread_suspend+0x80>
      return;
 2e0:	90                   	nop
    }
  }
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <thread_resume>:

// Resume a suspended thread (doesn't switch immediately)
void
thread_resume(int tid)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 18             	sub    $0x18,%esp
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
 2e9:	c7 45 f4 40 10 00 00 	movl   $0x1040,-0xc(%ebp)
 2f0:	eb 47                	jmp    339 <thread_resume+0x56>
    if (t->state == WAIT && t->tid == tid) {
 2f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f5:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 2fb:	83 f8 03             	cmp    $0x3,%eax
 2fe:	75 32                	jne    332 <thread_resume+0x4f>
 300:	8b 45 f4             	mov    -0xc(%ebp),%eax
 303:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 309:	39 45 08             	cmp    %eax,0x8(%ebp)
 30c:	75 24                	jne    332 <thread_resume+0x4f>
      t->state = RUNNABLE;
 30e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 311:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 318:	00 00 00 
      printf(1, "[resume] Resuming thread %d\n", tid);
 31b:	83 ec 04             	sub    $0x4,%esp
 31e:	ff 75 08             	push   0x8(%ebp)
 321:	68 64 0c 00 00       	push   $0xc64
 326:	6a 01                	push   $0x1
 328:	e8 35 05 00 00       	call   862 <printf>
 32d:	83 c4 10             	add    $0x10,%esp
      return;
 330:	eb 11                	jmp    343 <thread_resume+0x60>
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
 332:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
 339:	b8 b8 50 01 00       	mov    $0x150b8,%eax
 33e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 341:	72 af                	jb     2f2 <thread_resume+0xf>
    }
  }
}
 343:	c9                   	leave  
 344:	c3                   	ret    

00000345 <mythread>:

// Thread function: print tid and count
static void
mythread(void)
{
 345:	55                   	push   %ebp
 346:	89 e5                	mov    %esp,%ebp
 348:	83 ec 18             	sub    $0x18,%esp
  printf(1, "my thread running (tid=%d)\n", current_thread->tid);
 34b:	a1 20 10 00 00       	mov    0x1020,%eax
 350:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 356:	83 ec 04             	sub    $0x4,%esp
 359:	50                   	push   %eax
 35a:	68 81 0c 00 00       	push   $0xc81
 35f:	6a 01                	push   $0x1
 361:	e8 fc 04 00 00       	call   862 <printf>
 366:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++) {
 369:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 370:	eb 27                	jmp    399 <mythread+0x54>
    printf(1, "my thread %d\n", current_thread->tid);
 372:	a1 20 10 00 00       	mov    0x1020,%eax
 377:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 37d:	83 ec 04             	sub    $0x4,%esp
 380:	50                   	push   %eax
 381:	68 9d 0c 00 00       	push   $0xc9d
 386:	6a 01                	push   $0x1
 388:	e8 d5 04 00 00       	call   862 <printf>
 38d:	83 c4 10             	add    $0x10,%esp
    thread_yield();
 390:	e8 9a fe ff ff       	call   22f <thread_yield>
  for (int i = 0; i < 100; i++) {
 395:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 399:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 39d:	7e d3                	jle    372 <mythread+0x2d>
  }
  printf(1, "My thread: exit\n");
 39f:	83 ec 08             	sub    $0x8,%esp
 3a2:	68 ab 0c 00 00       	push   $0xcab
 3a7:	6a 01                	push   $0x1
 3a9:	e8 b4 04 00 00       	call   862 <printf>
 3ae:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 3b1:	a1 20 10 00 00       	mov    0x1020,%eax
 3b6:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 3bd:	00 00 00 
  thread_schedule();
 3c0:	e8 3b fc ff ff       	call   0 <thread_schedule>
}
 3c5:	90                   	nop
 3c6:	c9                   	leave  
 3c7:	c3                   	ret    

000003c8 <main>:

// Main: create threads, demo suspend/resume with interleaving
int
main(int argc, char *argv[])
{
 3c8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 3cc:	83 e4 f0             	and    $0xfffffff0,%esp
 3cf:	ff 71 fc             	push   -0x4(%ecx)
 3d2:	55                   	push   %ebp
 3d3:	89 e5                	mov    %esp,%ebp
 3d5:	51                   	push   %ecx
 3d6:	83 ec 14             	sub    $0x14,%esp
  int tid1, tid2;
  thread_init();
 3d9:	e8 4c fd ff ff       	call   12a <thread_init>
  tid1 = thread_create(mythread);
 3de:	68 45 03 00 00       	push   $0x345
 3e3:	e8 9a fd ff ff       	call   182 <thread_create>
 3e8:	83 c4 04             	add    $0x4,%esp
 3eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  tid2 = thread_create(mythread);
 3ee:	68 45 03 00 00       	push   $0x345
 3f3:	e8 8a fd ff ff       	call   182 <thread_create>
 3f8:	83 c4 04             	add    $0x4,%esp
 3fb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  thread_sleep(3);
 3fe:	83 ec 0c             	sub    $0xc,%esp
 401:	6a 03                	push   $0x3
 403:	e8 35 fe ff ff       	call   23d <thread_sleep>
 408:	83 c4 10             	add    $0x10,%esp

  thread_suspend(tid1);
 40b:	83 ec 0c             	sub    $0xc,%esp
 40e:	ff 75 f4             	push   -0xc(%ebp)
 411:	e8 4b fe ff ff       	call   261 <thread_suspend>
 416:	83 c4 10             	add    $0x10,%esp
  thread_sleep(3);
 419:	83 ec 0c             	sub    $0xc,%esp
 41c:	6a 03                	push   $0x3
 41e:	e8 1a fe ff ff       	call   23d <thread_sleep>
 423:	83 c4 10             	add    $0x10,%esp

  thread_suspend(tid2);
 426:	83 ec 0c             	sub    $0xc,%esp
 429:	ff 75 f0             	push   -0x10(%ebp)
 42c:	e8 30 fe ff ff       	call   261 <thread_suspend>
 431:	83 c4 10             	add    $0x10,%esp
  thread_sleep(3);
 434:	83 ec 0c             	sub    $0xc,%esp
 437:	6a 03                	push   $0x3
 439:	e8 ff fd ff ff       	call   23d <thread_sleep>
 43e:	83 c4 10             	add    $0x10,%esp

  thread_resume(tid1);
 441:	83 ec 0c             	sub    $0xc,%esp
 444:	ff 75 f4             	push   -0xc(%ebp)
 447:	e8 97 fe ff ff       	call   2e3 <thread_resume>
 44c:	83 c4 10             	add    $0x10,%esp
  thread_sleep(3);
 44f:	83 ec 0c             	sub    $0xc,%esp
 452:	6a 03                	push   $0x3
 454:	e8 e4 fd ff ff       	call   23d <thread_sleep>
 459:	83 c4 10             	add    $0x10,%esp

  thread_resume(tid2);
 45c:	83 ec 0c             	sub    $0xc,%esp
 45f:	ff 75 f0             	push   -0x10(%ebp)
 462:	e8 7c fe ff ff       	call   2e3 <thread_resume>
 467:	83 c4 10             	add    $0x10,%esp
  thread_sleep(100);
 46a:	83 ec 0c             	sub    $0xc,%esp
 46d:	6a 64                	push   $0x64
 46f:	e8 c9 fd ff ff       	call   23d <thread_sleep>
 474:	83 c4 10             	add    $0x10,%esp

  thread_schedule();
 477:	e8 84 fb ff ff       	call   0 <thread_schedule>

  exit();
 47c:	e8 6d 02 00 00       	call   6ee <exit>

00000481 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 481:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 482:	a1 20 10 00 00       	mov    0x1020,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 487:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 489:	a1 24 10 00 00       	mov    0x1024,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 48e:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 490:	a3 20 10 00 00       	mov    %eax,0x1020
    popal
 495:	61                   	popa   
    
    # return to next thread's stack context
 496:	c3                   	ret    

00000497 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	57                   	push   %edi
 49b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 49c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 49f:	8b 55 10             	mov    0x10(%ebp),%edx
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	89 cb                	mov    %ecx,%ebx
 4a7:	89 df                	mov    %ebx,%edi
 4a9:	89 d1                	mov    %edx,%ecx
 4ab:	fc                   	cld    
 4ac:	f3 aa                	rep stos %al,%es:(%edi)
 4ae:	89 ca                	mov    %ecx,%edx
 4b0:	89 fb                	mov    %edi,%ebx
 4b2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4b5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4b8:	90                   	nop
 4b9:	5b                   	pop    %ebx
 4ba:	5f                   	pop    %edi
 4bb:	5d                   	pop    %ebp
 4bc:	c3                   	ret    

000004bd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4bd:	55                   	push   %ebp
 4be:	89 e5                	mov    %esp,%ebp
 4c0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4c9:	90                   	nop
 4ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 4cd:	8d 42 01             	lea    0x1(%edx),%eax
 4d0:	89 45 0c             	mov    %eax,0xc(%ebp)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	8d 48 01             	lea    0x1(%eax),%ecx
 4d9:	89 4d 08             	mov    %ecx,0x8(%ebp)
 4dc:	0f b6 12             	movzbl (%edx),%edx
 4df:	88 10                	mov    %dl,(%eax)
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	84 c0                	test   %al,%al
 4e6:	75 e2                	jne    4ca <strcpy+0xd>
    ;
  return os;
 4e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4eb:	c9                   	leave  
 4ec:	c3                   	ret    

000004ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4ed:	55                   	push   %ebp
 4ee:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4f0:	eb 08                	jmp    4fa <strcmp+0xd>
    p++, q++;
 4f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	0f b6 00             	movzbl (%eax),%eax
 500:	84 c0                	test   %al,%al
 502:	74 10                	je     514 <strcmp+0x27>
 504:	8b 45 08             	mov    0x8(%ebp),%eax
 507:	0f b6 10             	movzbl (%eax),%edx
 50a:	8b 45 0c             	mov    0xc(%ebp),%eax
 50d:	0f b6 00             	movzbl (%eax),%eax
 510:	38 c2                	cmp    %al,%dl
 512:	74 de                	je     4f2 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	0f b6 d0             	movzbl %al,%edx
 51d:	8b 45 0c             	mov    0xc(%ebp),%eax
 520:	0f b6 00             	movzbl (%eax),%eax
 523:	0f b6 c8             	movzbl %al,%ecx
 526:	89 d0                	mov    %edx,%eax
 528:	29 c8                	sub    %ecx,%eax
}
 52a:	5d                   	pop    %ebp
 52b:	c3                   	ret    

0000052c <strlen>:

uint
strlen(char *s)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
 52f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 532:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 539:	eb 04                	jmp    53f <strlen+0x13>
 53b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 53f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 542:	8b 45 08             	mov    0x8(%ebp),%eax
 545:	01 d0                	add    %edx,%eax
 547:	0f b6 00             	movzbl (%eax),%eax
 54a:	84 c0                	test   %al,%al
 54c:	75 ed                	jne    53b <strlen+0xf>
    ;
  return n;
 54e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 551:	c9                   	leave  
 552:	c3                   	ret    

00000553 <memset>:

void*
memset(void *dst, int c, uint n)
{
 553:	55                   	push   %ebp
 554:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 556:	8b 45 10             	mov    0x10(%ebp),%eax
 559:	50                   	push   %eax
 55a:	ff 75 0c             	push   0xc(%ebp)
 55d:	ff 75 08             	push   0x8(%ebp)
 560:	e8 32 ff ff ff       	call   497 <stosb>
 565:	83 c4 0c             	add    $0xc,%esp
  return dst;
 568:	8b 45 08             	mov    0x8(%ebp),%eax
}
 56b:	c9                   	leave  
 56c:	c3                   	ret    

0000056d <strchr>:

char*
strchr(const char *s, char c)
{
 56d:	55                   	push   %ebp
 56e:	89 e5                	mov    %esp,%ebp
 570:	83 ec 04             	sub    $0x4,%esp
 573:	8b 45 0c             	mov    0xc(%ebp),%eax
 576:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 579:	eb 14                	jmp    58f <strchr+0x22>
    if(*s == c)
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	0f b6 00             	movzbl (%eax),%eax
 581:	38 45 fc             	cmp    %al,-0x4(%ebp)
 584:	75 05                	jne    58b <strchr+0x1e>
      return (char*)s;
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	eb 13                	jmp    59e <strchr+0x31>
  for(; *s; s++)
 58b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	0f b6 00             	movzbl (%eax),%eax
 595:	84 c0                	test   %al,%al
 597:	75 e2                	jne    57b <strchr+0xe>
  return 0;
 599:	b8 00 00 00 00       	mov    $0x0,%eax
}
 59e:	c9                   	leave  
 59f:	c3                   	ret    

000005a0 <gets>:

char*
gets(char *buf, int max)
{
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5ad:	eb 42                	jmp    5f1 <gets+0x51>
    cc = read(0, &c, 1);
 5af:	83 ec 04             	sub    $0x4,%esp
 5b2:	6a 01                	push   $0x1
 5b4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5b7:	50                   	push   %eax
 5b8:	6a 00                	push   $0x0
 5ba:	e8 47 01 00 00       	call   706 <read>
 5bf:	83 c4 10             	add    $0x10,%esp
 5c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c9:	7e 33                	jle    5fe <gets+0x5e>
      break;
    buf[i++] = c;
 5cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ce:	8d 50 01             	lea    0x1(%eax),%edx
 5d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5d4:	89 c2                	mov    %eax,%edx
 5d6:	8b 45 08             	mov    0x8(%ebp),%eax
 5d9:	01 c2                	add    %eax,%edx
 5db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5df:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5e1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5e5:	3c 0a                	cmp    $0xa,%al
 5e7:	74 16                	je     5ff <gets+0x5f>
 5e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5ed:	3c 0d                	cmp    $0xd,%al
 5ef:	74 0e                	je     5ff <gets+0x5f>
  for(i=0; i+1 < max; ){
 5f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f4:	83 c0 01             	add    $0x1,%eax
 5f7:	39 45 0c             	cmp    %eax,0xc(%ebp)
 5fa:	7f b3                	jg     5af <gets+0xf>
 5fc:	eb 01                	jmp    5ff <gets+0x5f>
      break;
 5fe:	90                   	nop
      break;
  }
  buf[i] = '\0';
 5ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
 602:	8b 45 08             	mov    0x8(%ebp),%eax
 605:	01 d0                	add    %edx,%eax
 607:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 60a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 60d:	c9                   	leave  
 60e:	c3                   	ret    

0000060f <stat>:

int
stat(char *n, struct stat *st)
{
 60f:	55                   	push   %ebp
 610:	89 e5                	mov    %esp,%ebp
 612:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 615:	83 ec 08             	sub    $0x8,%esp
 618:	6a 00                	push   $0x0
 61a:	ff 75 08             	push   0x8(%ebp)
 61d:	e8 14 01 00 00       	call   736 <open>
 622:	83 c4 10             	add    $0x10,%esp
 625:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62c:	79 07                	jns    635 <stat+0x26>
    return -1;
 62e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 633:	eb 25                	jmp    65a <stat+0x4b>
  r = fstat(fd, st);
 635:	83 ec 08             	sub    $0x8,%esp
 638:	ff 75 0c             	push   0xc(%ebp)
 63b:	ff 75 f4             	push   -0xc(%ebp)
 63e:	e8 0b 01 00 00       	call   74e <fstat>
 643:	83 c4 10             	add    $0x10,%esp
 646:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 649:	83 ec 0c             	sub    $0xc,%esp
 64c:	ff 75 f4             	push   -0xc(%ebp)
 64f:	e8 c2 00 00 00       	call   716 <close>
 654:	83 c4 10             	add    $0x10,%esp
  return r;
 657:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 65a:	c9                   	leave  
 65b:	c3                   	ret    

0000065c <atoi>:

int
atoi(const char *s)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 662:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 669:	eb 25                	jmp    690 <atoi+0x34>
    n = n*10 + *s++ - '0';
 66b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 66e:	89 d0                	mov    %edx,%eax
 670:	c1 e0 02             	shl    $0x2,%eax
 673:	01 d0                	add    %edx,%eax
 675:	01 c0                	add    %eax,%eax
 677:	89 c1                	mov    %eax,%ecx
 679:	8b 45 08             	mov    0x8(%ebp),%eax
 67c:	8d 50 01             	lea    0x1(%eax),%edx
 67f:	89 55 08             	mov    %edx,0x8(%ebp)
 682:	0f b6 00             	movzbl (%eax),%eax
 685:	0f be c0             	movsbl %al,%eax
 688:	01 c8                	add    %ecx,%eax
 68a:	83 e8 30             	sub    $0x30,%eax
 68d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	0f b6 00             	movzbl (%eax),%eax
 696:	3c 2f                	cmp    $0x2f,%al
 698:	7e 0a                	jle    6a4 <atoi+0x48>
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	0f b6 00             	movzbl (%eax),%eax
 6a0:	3c 39                	cmp    $0x39,%al
 6a2:	7e c7                	jle    66b <atoi+0xf>
  return n;
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6a7:	c9                   	leave  
 6a8:	c3                   	ret    

000006a9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6a9:	55                   	push   %ebp
 6aa:	89 e5                	mov    %esp,%ebp
 6ac:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6bb:	eb 17                	jmp    6d4 <memmove+0x2b>
    *dst++ = *src++;
 6bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c0:	8d 42 01             	lea    0x1(%edx),%eax
 6c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8d 48 01             	lea    0x1(%eax),%ecx
 6cc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 6cf:	0f b6 12             	movzbl (%edx),%edx
 6d2:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 6d4:	8b 45 10             	mov    0x10(%ebp),%eax
 6d7:	8d 50 ff             	lea    -0x1(%eax),%edx
 6da:	89 55 10             	mov    %edx,0x10(%ebp)
 6dd:	85 c0                	test   %eax,%eax
 6df:	7f dc                	jg     6bd <memmove+0x14>
  return vdst;
 6e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6e4:	c9                   	leave  
 6e5:	c3                   	ret    

000006e6 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 6e6:	b8 01 00 00 00       	mov    $0x1,%eax
 6eb:	cd 40                	int    $0x40
 6ed:	c3                   	ret    

000006ee <exit>:
SYSCALL(exit)
 6ee:	b8 02 00 00 00       	mov    $0x2,%eax
 6f3:	cd 40                	int    $0x40
 6f5:	c3                   	ret    

000006f6 <wait>:
SYSCALL(wait)
 6f6:	b8 03 00 00 00       	mov    $0x3,%eax
 6fb:	cd 40                	int    $0x40
 6fd:	c3                   	ret    

000006fe <pipe>:
SYSCALL(pipe)
 6fe:	b8 04 00 00 00       	mov    $0x4,%eax
 703:	cd 40                	int    $0x40
 705:	c3                   	ret    

00000706 <read>:
SYSCALL(read)
 706:	b8 05 00 00 00       	mov    $0x5,%eax
 70b:	cd 40                	int    $0x40
 70d:	c3                   	ret    

0000070e <write>:
SYSCALL(write)
 70e:	b8 10 00 00 00       	mov    $0x10,%eax
 713:	cd 40                	int    $0x40
 715:	c3                   	ret    

00000716 <close>:
SYSCALL(close)
 716:	b8 15 00 00 00       	mov    $0x15,%eax
 71b:	cd 40                	int    $0x40
 71d:	c3                   	ret    

0000071e <kill>:
SYSCALL(kill)
 71e:	b8 06 00 00 00       	mov    $0x6,%eax
 723:	cd 40                	int    $0x40
 725:	c3                   	ret    

00000726 <dup>:
SYSCALL(dup)
 726:	b8 0a 00 00 00       	mov    $0xa,%eax
 72b:	cd 40                	int    $0x40
 72d:	c3                   	ret    

0000072e <exec>:
SYSCALL(exec)
 72e:	b8 07 00 00 00       	mov    $0x7,%eax
 733:	cd 40                	int    $0x40
 735:	c3                   	ret    

00000736 <open>:
SYSCALL(open)
 736:	b8 0f 00 00 00       	mov    $0xf,%eax
 73b:	cd 40                	int    $0x40
 73d:	c3                   	ret    

0000073e <mknod>:
SYSCALL(mknod)
 73e:	b8 11 00 00 00       	mov    $0x11,%eax
 743:	cd 40                	int    $0x40
 745:	c3                   	ret    

00000746 <unlink>:
SYSCALL(unlink)
 746:	b8 12 00 00 00       	mov    $0x12,%eax
 74b:	cd 40                	int    $0x40
 74d:	c3                   	ret    

0000074e <fstat>:
SYSCALL(fstat)
 74e:	b8 08 00 00 00       	mov    $0x8,%eax
 753:	cd 40                	int    $0x40
 755:	c3                   	ret    

00000756 <link>:
SYSCALL(link)
 756:	b8 13 00 00 00       	mov    $0x13,%eax
 75b:	cd 40                	int    $0x40
 75d:	c3                   	ret    

0000075e <mkdir>:
SYSCALL(mkdir)
 75e:	b8 14 00 00 00       	mov    $0x14,%eax
 763:	cd 40                	int    $0x40
 765:	c3                   	ret    

00000766 <chdir>:
SYSCALL(chdir)
 766:	b8 09 00 00 00       	mov    $0x9,%eax
 76b:	cd 40                	int    $0x40
 76d:	c3                   	ret    

0000076e <sbrk>:
SYSCALL(sbrk)
 76e:	b8 0c 00 00 00       	mov    $0xc,%eax
 773:	cd 40                	int    $0x40
 775:	c3                   	ret    

00000776 <sleep>:
SYSCALL(sleep)
 776:	b8 0d 00 00 00       	mov    $0xd,%eax
 77b:	cd 40                	int    $0x40
 77d:	c3                   	ret    

0000077e <getpid>:
SYSCALL(getpid)
 77e:	b8 0b 00 00 00       	mov    $0xb,%eax
 783:	cd 40                	int    $0x40
 785:	c3                   	ret    

00000786 <uthread_init>:
SYSCALL(uthread_init)
 786:	b8 18 00 00 00       	mov    $0x18,%eax
 78b:	cd 40                	int    $0x40
 78d:	c3                   	ret    

0000078e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 78e:	55                   	push   %ebp
 78f:	89 e5                	mov    %esp,%ebp
 791:	83 ec 18             	sub    $0x18,%esp
 794:	8b 45 0c             	mov    0xc(%ebp),%eax
 797:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 79a:	83 ec 04             	sub    $0x4,%esp
 79d:	6a 01                	push   $0x1
 79f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7a2:	50                   	push   %eax
 7a3:	ff 75 08             	push   0x8(%ebp)
 7a6:	e8 63 ff ff ff       	call   70e <write>
 7ab:	83 c4 10             	add    $0x10,%esp
}
 7ae:	90                   	nop
 7af:	c9                   	leave  
 7b0:	c3                   	ret    

000007b1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7b1:	55                   	push   %ebp
 7b2:	89 e5                	mov    %esp,%ebp
 7b4:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7be:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7c2:	74 17                	je     7db <printint+0x2a>
 7c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7c8:	79 11                	jns    7db <printint+0x2a>
    neg = 1;
 7ca:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 7d4:	f7 d8                	neg    %eax
 7d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7d9:	eb 06                	jmp    7e1 <printint+0x30>
  } else {
    x = xx;
 7db:	8b 45 0c             	mov    0xc(%ebp),%eax
 7de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ee:	ba 00 00 00 00       	mov    $0x0,%edx
 7f3:	f7 f1                	div    %ecx
 7f5:	89 d1                	mov    %edx,%ecx
 7f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fa:	8d 50 01             	lea    0x1(%eax),%edx
 7fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 800:	0f b6 91 08 10 00 00 	movzbl 0x1008(%ecx),%edx
 807:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 80b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 80e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 811:	ba 00 00 00 00       	mov    $0x0,%edx
 816:	f7 f1                	div    %ecx
 818:	89 45 ec             	mov    %eax,-0x14(%ebp)
 81b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 81f:	75 c7                	jne    7e8 <printint+0x37>
  if(neg)
 821:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 825:	74 2d                	je     854 <printint+0xa3>
    buf[i++] = '-';
 827:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82a:	8d 50 01             	lea    0x1(%eax),%edx
 82d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 830:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 835:	eb 1d                	jmp    854 <printint+0xa3>
    putc(fd, buf[i]);
 837:	8d 55 dc             	lea    -0x24(%ebp),%edx
 83a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83d:	01 d0                	add    %edx,%eax
 83f:	0f b6 00             	movzbl (%eax),%eax
 842:	0f be c0             	movsbl %al,%eax
 845:	83 ec 08             	sub    $0x8,%esp
 848:	50                   	push   %eax
 849:	ff 75 08             	push   0x8(%ebp)
 84c:	e8 3d ff ff ff       	call   78e <putc>
 851:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 854:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 858:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 85c:	79 d9                	jns    837 <printint+0x86>
}
 85e:	90                   	nop
 85f:	90                   	nop
 860:	c9                   	leave  
 861:	c3                   	ret    

00000862 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 862:	55                   	push   %ebp
 863:	89 e5                	mov    %esp,%ebp
 865:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 868:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 86f:	8d 45 0c             	lea    0xc(%ebp),%eax
 872:	83 c0 04             	add    $0x4,%eax
 875:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 878:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 87f:	e9 59 01 00 00       	jmp    9dd <printf+0x17b>
    c = fmt[i] & 0xff;
 884:	8b 55 0c             	mov    0xc(%ebp),%edx
 887:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88a:	01 d0                	add    %edx,%eax
 88c:	0f b6 00             	movzbl (%eax),%eax
 88f:	0f be c0             	movsbl %al,%eax
 892:	25 ff 00 00 00       	and    $0xff,%eax
 897:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 89a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 89e:	75 2c                	jne    8cc <printf+0x6a>
      if(c == '%'){
 8a0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8a4:	75 0c                	jne    8b2 <printf+0x50>
        state = '%';
 8a6:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8ad:	e9 27 01 00 00       	jmp    9d9 <printf+0x177>
      } else {
        putc(fd, c);
 8b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b5:	0f be c0             	movsbl %al,%eax
 8b8:	83 ec 08             	sub    $0x8,%esp
 8bb:	50                   	push   %eax
 8bc:	ff 75 08             	push   0x8(%ebp)
 8bf:	e8 ca fe ff ff       	call   78e <putc>
 8c4:	83 c4 10             	add    $0x10,%esp
 8c7:	e9 0d 01 00 00       	jmp    9d9 <printf+0x177>
      }
    } else if(state == '%'){
 8cc:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8d0:	0f 85 03 01 00 00    	jne    9d9 <printf+0x177>
      if(c == 'd'){
 8d6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8da:	75 1e                	jne    8fa <printf+0x98>
        printint(fd, *ap, 10, 1);
 8dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8df:	8b 00                	mov    (%eax),%eax
 8e1:	6a 01                	push   $0x1
 8e3:	6a 0a                	push   $0xa
 8e5:	50                   	push   %eax
 8e6:	ff 75 08             	push   0x8(%ebp)
 8e9:	e8 c3 fe ff ff       	call   7b1 <printint>
 8ee:	83 c4 10             	add    $0x10,%esp
        ap++;
 8f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8f5:	e9 d8 00 00 00       	jmp    9d2 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 8fa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8fe:	74 06                	je     906 <printf+0xa4>
 900:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 904:	75 1e                	jne    924 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 906:	8b 45 e8             	mov    -0x18(%ebp),%eax
 909:	8b 00                	mov    (%eax),%eax
 90b:	6a 00                	push   $0x0
 90d:	6a 10                	push   $0x10
 90f:	50                   	push   %eax
 910:	ff 75 08             	push   0x8(%ebp)
 913:	e8 99 fe ff ff       	call   7b1 <printint>
 918:	83 c4 10             	add    $0x10,%esp
        ap++;
 91b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 91f:	e9 ae 00 00 00       	jmp    9d2 <printf+0x170>
      } else if(c == 's'){
 924:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 928:	75 43                	jne    96d <printf+0x10b>
        s = (char*)*ap;
 92a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 92d:	8b 00                	mov    (%eax),%eax
 92f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 932:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 936:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 93a:	75 25                	jne    961 <printf+0xff>
          s = "(null)";
 93c:	c7 45 f4 bc 0c 00 00 	movl   $0xcbc,-0xc(%ebp)
        while(*s != 0){
 943:	eb 1c                	jmp    961 <printf+0xff>
          putc(fd, *s);
 945:	8b 45 f4             	mov    -0xc(%ebp),%eax
 948:	0f b6 00             	movzbl (%eax),%eax
 94b:	0f be c0             	movsbl %al,%eax
 94e:	83 ec 08             	sub    $0x8,%esp
 951:	50                   	push   %eax
 952:	ff 75 08             	push   0x8(%ebp)
 955:	e8 34 fe ff ff       	call   78e <putc>
 95a:	83 c4 10             	add    $0x10,%esp
          s++;
 95d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	0f b6 00             	movzbl (%eax),%eax
 967:	84 c0                	test   %al,%al
 969:	75 da                	jne    945 <printf+0xe3>
 96b:	eb 65                	jmp    9d2 <printf+0x170>
        }
      } else if(c == 'c'){
 96d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 971:	75 1d                	jne    990 <printf+0x12e>
        putc(fd, *ap);
 973:	8b 45 e8             	mov    -0x18(%ebp),%eax
 976:	8b 00                	mov    (%eax),%eax
 978:	0f be c0             	movsbl %al,%eax
 97b:	83 ec 08             	sub    $0x8,%esp
 97e:	50                   	push   %eax
 97f:	ff 75 08             	push   0x8(%ebp)
 982:	e8 07 fe ff ff       	call   78e <putc>
 987:	83 c4 10             	add    $0x10,%esp
        ap++;
 98a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 98e:	eb 42                	jmp    9d2 <printf+0x170>
      } else if(c == '%'){
 990:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 994:	75 17                	jne    9ad <printf+0x14b>
        putc(fd, c);
 996:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 999:	0f be c0             	movsbl %al,%eax
 99c:	83 ec 08             	sub    $0x8,%esp
 99f:	50                   	push   %eax
 9a0:	ff 75 08             	push   0x8(%ebp)
 9a3:	e8 e6 fd ff ff       	call   78e <putc>
 9a8:	83 c4 10             	add    $0x10,%esp
 9ab:	eb 25                	jmp    9d2 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9ad:	83 ec 08             	sub    $0x8,%esp
 9b0:	6a 25                	push   $0x25
 9b2:	ff 75 08             	push   0x8(%ebp)
 9b5:	e8 d4 fd ff ff       	call   78e <putc>
 9ba:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9c0:	0f be c0             	movsbl %al,%eax
 9c3:	83 ec 08             	sub    $0x8,%esp
 9c6:	50                   	push   %eax
 9c7:	ff 75 08             	push   0x8(%ebp)
 9ca:	e8 bf fd ff ff       	call   78e <putc>
 9cf:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9d2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 9d9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9dd:	8b 55 0c             	mov    0xc(%ebp),%edx
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	01 d0                	add    %edx,%eax
 9e5:	0f b6 00             	movzbl (%eax),%eax
 9e8:	84 c0                	test   %al,%al
 9ea:	0f 85 94 fe ff ff    	jne    884 <printf+0x22>
    }
  }
}
 9f0:	90                   	nop
 9f1:	90                   	nop
 9f2:	c9                   	leave  
 9f3:	c3                   	ret    

000009f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9f4:	55                   	push   %ebp
 9f5:	89 e5                	mov    %esp,%ebp
 9f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9fa:	8b 45 08             	mov    0x8(%ebp),%eax
 9fd:	83 e8 08             	sub    $0x8,%eax
 a00:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a03:	a1 c0 50 01 00       	mov    0x150c0,%eax
 a08:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a0b:	eb 24                	jmp    a31 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a10:	8b 00                	mov    (%eax),%eax
 a12:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a15:	72 12                	jb     a29 <free+0x35>
 a17:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a1d:	77 24                	ja     a43 <free+0x4f>
 a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a22:	8b 00                	mov    (%eax),%eax
 a24:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a27:	72 1a                	jb     a43 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2c:	8b 00                	mov    (%eax),%eax
 a2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a31:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a34:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a37:	76 d4                	jbe    a0d <free+0x19>
 a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3c:	8b 00                	mov    (%eax),%eax
 a3e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a41:	73 ca                	jae    a0d <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a46:	8b 40 04             	mov    0x4(%eax),%eax
 a49:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a50:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a53:	01 c2                	add    %eax,%edx
 a55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a58:	8b 00                	mov    (%eax),%eax
 a5a:	39 c2                	cmp    %eax,%edx
 a5c:	75 24                	jne    a82 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a61:	8b 50 04             	mov    0x4(%eax),%edx
 a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	8b 40 04             	mov    0x4(%eax),%eax
 a6c:	01 c2                	add    %eax,%edx
 a6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a71:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a77:	8b 00                	mov    (%eax),%eax
 a79:	8b 10                	mov    (%eax),%edx
 a7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a7e:	89 10                	mov    %edx,(%eax)
 a80:	eb 0a                	jmp    a8c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a85:	8b 10                	mov    (%eax),%edx
 a87:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8f:	8b 40 04             	mov    0x4(%eax),%eax
 a92:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9c:	01 d0                	add    %edx,%eax
 a9e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 aa1:	75 20                	jne    ac3 <free+0xcf>
    p->s.size += bp->s.size;
 aa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa6:	8b 50 04             	mov    0x4(%eax),%edx
 aa9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aac:	8b 40 04             	mov    0x4(%eax),%eax
 aaf:	01 c2                	add    %eax,%edx
 ab1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ab7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aba:	8b 10                	mov    (%eax),%edx
 abc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abf:	89 10                	mov    %edx,(%eax)
 ac1:	eb 08                	jmp    acb <free+0xd7>
  } else
    p->s.ptr = bp;
 ac3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 ac9:	89 10                	mov    %edx,(%eax)
  freep = p;
 acb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ace:	a3 c0 50 01 00       	mov    %eax,0x150c0
}
 ad3:	90                   	nop
 ad4:	c9                   	leave  
 ad5:	c3                   	ret    

00000ad6 <morecore>:

static Header*
morecore(uint nu)
{
 ad6:	55                   	push   %ebp
 ad7:	89 e5                	mov    %esp,%ebp
 ad9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 adc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 ae3:	77 07                	ja     aec <morecore+0x16>
    nu = 4096;
 ae5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 aec:	8b 45 08             	mov    0x8(%ebp),%eax
 aef:	c1 e0 03             	shl    $0x3,%eax
 af2:	83 ec 0c             	sub    $0xc,%esp
 af5:	50                   	push   %eax
 af6:	e8 73 fc ff ff       	call   76e <sbrk>
 afb:	83 c4 10             	add    $0x10,%esp
 afe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b01:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b05:	75 07                	jne    b0e <morecore+0x38>
    return 0;
 b07:	b8 00 00 00 00       	mov    $0x0,%eax
 b0c:	eb 26                	jmp    b34 <morecore+0x5e>
  hp = (Header*)p;
 b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b17:	8b 55 08             	mov    0x8(%ebp),%edx
 b1a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b20:	83 c0 08             	add    $0x8,%eax
 b23:	83 ec 0c             	sub    $0xc,%esp
 b26:	50                   	push   %eax
 b27:	e8 c8 fe ff ff       	call   9f4 <free>
 b2c:	83 c4 10             	add    $0x10,%esp
  return freep;
 b2f:	a1 c0 50 01 00       	mov    0x150c0,%eax
}
 b34:	c9                   	leave  
 b35:	c3                   	ret    

00000b36 <malloc>:

void*
malloc(uint nbytes)
{
 b36:	55                   	push   %ebp
 b37:	89 e5                	mov    %esp,%ebp
 b39:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b3c:	8b 45 08             	mov    0x8(%ebp),%eax
 b3f:	83 c0 07             	add    $0x7,%eax
 b42:	c1 e8 03             	shr    $0x3,%eax
 b45:	83 c0 01             	add    $0x1,%eax
 b48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b4b:	a1 c0 50 01 00       	mov    0x150c0,%eax
 b50:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b57:	75 23                	jne    b7c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b59:	c7 45 f0 b8 50 01 00 	movl   $0x150b8,-0x10(%ebp)
 b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b63:	a3 c0 50 01 00       	mov    %eax,0x150c0
 b68:	a1 c0 50 01 00       	mov    0x150c0,%eax
 b6d:	a3 b8 50 01 00       	mov    %eax,0x150b8
    base.s.size = 0;
 b72:	c7 05 bc 50 01 00 00 	movl   $0x0,0x150bc
 b79:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b7f:	8b 00                	mov    (%eax),%eax
 b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b87:	8b 40 04             	mov    0x4(%eax),%eax
 b8a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b8d:	77 4d                	ja     bdc <malloc+0xa6>
      if(p->s.size == nunits)
 b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b92:	8b 40 04             	mov    0x4(%eax),%eax
 b95:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b98:	75 0c                	jne    ba6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9d:	8b 10                	mov    (%eax),%edx
 b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba2:	89 10                	mov    %edx,(%eax)
 ba4:	eb 26                	jmp    bcc <malloc+0x96>
      else {
        p->s.size -= nunits;
 ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba9:	8b 40 04             	mov    0x4(%eax),%eax
 bac:	2b 45 ec             	sub    -0x14(%ebp),%eax
 baf:	89 c2                	mov    %eax,%edx
 bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bba:	8b 40 04             	mov    0x4(%eax),%eax
 bbd:	c1 e0 03             	shl    $0x3,%eax
 bc0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bc9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bcf:	a3 c0 50 01 00       	mov    %eax,0x150c0
      return (void*)(p + 1);
 bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd7:	83 c0 08             	add    $0x8,%eax
 bda:	eb 3b                	jmp    c17 <malloc+0xe1>
    }
    if(p == freep)
 bdc:	a1 c0 50 01 00       	mov    0x150c0,%eax
 be1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 be4:	75 1e                	jne    c04 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 be6:	83 ec 0c             	sub    $0xc,%esp
 be9:	ff 75 ec             	push   -0x14(%ebp)
 bec:	e8 e5 fe ff ff       	call   ad6 <morecore>
 bf1:	83 c4 10             	add    $0x10,%esp
 bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bfb:	75 07                	jne    c04 <malloc+0xce>
        return 0;
 bfd:	b8 00 00 00 00       	mov    $0x0,%eax
 c02:	eb 13                	jmp    c17 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c07:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0d:	8b 00                	mov    (%eax),%eax
 c0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c12:	e9 6d ff ff ff       	jmp    b84 <malloc+0x4e>
  }
}
 c17:	c9                   	leave  
 c18:	c3                   	ret    
