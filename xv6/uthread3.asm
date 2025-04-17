
_uthread3:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p current_thread;
thread_p next_thread;

extern void thread_switch(void);

static void thread_schedule(void) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  next_thread = 0;
   6:	c7 05 c4 0f 00 00 00 	movl   $0x0,0xfc4
   d:	00 00 00 

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 e0 0f 00 00 	movl   $0xfe0,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 c4 0f 00 00       	mov    %eax,0xfc4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
  42:	b8 58 50 01 00       	mov    $0x15058,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (!next_thread && current_thread->state == RUNNABLE)
  4c:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  51:	85 c0                	test   %eax,%eax
  53:	75 1a                	jne    6f <thread_schedule+0x6f>
  55:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  5a:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  60:	83 f8 02             	cmp    $0x2,%eax
  63:	75 0a                	jne    6f <thread_schedule+0x6f>
    next_thread = current_thread;
  65:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  6a:	a3 c4 0f 00 00       	mov    %eax,0xfc4

  if (!next_thread) {
  6f:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  74:	85 c0                	test   %eax,%eax
  76:	75 17                	jne    8f <thread_schedule+0x8f>
    printf(2, "thread_schedule: no runnable threads\n");
  78:	83 ec 08             	sub    $0x8,%esp
  7b:	68 bc 0b 00 00       	push   $0xbbc
  80:	6a 02                	push   $0x2
  82:	e8 7e 07 00 00       	call   805 <printf>
  87:	83 c4 10             	add    $0x10,%esp
    exit();
  8a:	e8 02 06 00 00       	call   691 <exit>
  }

  if (next_thread != current_thread) {
  8f:	8b 15 c4 0f 00 00    	mov    0xfc4,%edx
  95:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  9a:	39 c2                	cmp    %eax,%edx
  9c:	74 2d                	je     cb <thread_schedule+0xcb>
    next_thread->state = RUNNING;
  9e:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  a3:	c7 80 08 20 00 00 01 	movl   $0x1,0x2008(%eax)
  aa:	00 00 00 
    current_thread->state = RUNNABLE;
  ad:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  b2:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
  b9:	00 00 00 
    thread_switch();
  bc:	e8 62 03 00 00       	call   423 <thread_switch>
    current_thread = next_thread;
  c1:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  c6:	a3 c0 0f 00 00       	mov    %eax,0xfc0
  }
}
  cb:	90                   	nop
  cc:	c9                   	leave  
  cd:	c3                   	ret    

000000ce <thread_init>:

void thread_init(void) {
  ce:	55                   	push   %ebp
  cf:	89 e5                	mov    %esp,%ebp
  d1:	83 ec 18             	sub    $0x18,%esp
  uthread_init(thread_schedule);
  d4:	83 ec 0c             	sub    $0xc,%esp
  d7:	68 00 00 00 00       	push   $0x0
  dc:	e8 48 06 00 00       	call   729 <uthread_init>
  e1:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < MAX_THREAD; i++)
  e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  eb:	eb 18                	jmp    105 <thread_init+0x37>
    all_thread[i].state = FREE;
  ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f0:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
  f6:	05 e8 2f 00 00       	add    $0x2fe8,%eax
  fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for (int i = 0; i < MAX_THREAD; i++)
 101:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 105:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 109:	7e e2                	jle    ed <thread_init+0x1f>

  current_thread = &all_thread[0];
 10b:	c7 05 c0 0f 00 00 e0 	movl   $0xfe0,0xfc0
 112:	0f 00 00 
  current_thread->tid = 0;
 115:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 11a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  current_thread->state = RUNNING;
 120:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 125:	c7 80 08 20 00 00 01 	movl   $0x1,0x2008(%eax)
 12c:	00 00 00 
}
 12f:	90                   	nop
 130:	c9                   	leave  
 131:	c3                   	ret    

00000132 <thread_create>:

int thread_create(void (*func)()) {
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	83 ec 10             	sub    $0x10,%esp
  thread_p t;
  int tid;
  for (tid = 1; tid < MAX_THREAD; tid++) {
 138:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
 13f:	e9 81 00 00 00       	jmp    1c5 <thread_create+0x93>
    if (all_thread[tid].state == FREE) {
 144:	8b 45 fc             	mov    -0x4(%ebp),%eax
 147:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
 14d:	05 e8 2f 00 00       	add    $0x2fe8,%eax
 152:	8b 00                	mov    (%eax),%eax
 154:	85 c0                	test   %eax,%eax
 156:	75 69                	jne    1c1 <thread_create+0x8f>
      t = &all_thread[tid];
 158:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15b:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
 161:	05 e0 0f 00 00       	add    $0xfe0,%eax
 166:	89 45 f8             	mov    %eax,-0x8(%ebp)
      t->tid = tid;
 169:	8b 45 f8             	mov    -0x8(%ebp),%eax
 16c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 16f:	89 10                	mov    %edx,(%eax)
      t->sp = (int)(t->stack + STACK_SIZE);
 171:	8b 45 f8             	mov    -0x8(%ebp),%eax
 174:	83 c0 08             	add    $0x8,%eax
 177:	05 00 20 00 00       	add    $0x2000,%eax
 17c:	89 c2                	mov    %eax,%edx
 17e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 181:	89 50 04             	mov    %edx,0x4(%eax)
      t->sp -= 4;
 184:	8b 45 f8             	mov    -0x8(%ebp),%eax
 187:	8b 40 04             	mov    0x4(%eax),%eax
 18a:	8d 50 fc             	lea    -0x4(%eax),%edx
 18d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 190:	89 50 04             	mov    %edx,0x4(%eax)
      *(int*)(t->sp) = (int)func;
 193:	8b 45 f8             	mov    -0x8(%ebp),%eax
 196:	8b 40 04             	mov    0x4(%eax),%eax
 199:	89 c2                	mov    %eax,%edx
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	89 02                	mov    %eax,(%edx)
      t->sp -= 32;
 1a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 1a3:	8b 40 04             	mov    0x4(%eax),%eax
 1a6:	8d 50 e0             	lea    -0x20(%eax),%edx
 1a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 1ac:	89 50 04             	mov    %edx,0x4(%eax)
      t->state = RUNNABLE;
 1af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 1b2:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
 1b9:	00 00 00 
      return tid;
 1bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1bf:	eb 13                	jmp    1d4 <thread_create+0xa2>
  for (tid = 1; tid < MAX_THREAD; tid++) {
 1c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c5:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
 1c9:	0f 8e 75 ff ff ff    	jle    144 <thread_create+0x12>
    }
  }
  return -1;
 1cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 1d4:	c9                   	leave  
 1d5:	c3                   	ret    

000001d6 <thread_suspend>:

void thread_suspend(int tid) {
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	83 ec 18             	sub    $0x18,%esp
  if (tid <= 0 || tid >= MAX_THREAD) return;
 1dc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1e0:	7e 66                	jle    248 <thread_suspend+0x72>
 1e2:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
 1e6:	7f 60                	jg     248 <thread_suspend+0x72>
  thread_p t = &all_thread[tid];
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
 1eb:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
 1f1:	05 e0 0f 00 00       	add    $0xfe0,%eax
 1f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (t->state != RUNNABLE && t->state != RUNNING) return;
 1f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fc:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 202:	83 f8 02             	cmp    $0x2,%eax
 205:	74 0e                	je     215 <thread_suspend+0x3f>
 207:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20a:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 210:	83 f8 01             	cmp    $0x1,%eax
 213:	75 36                	jne    24b <thread_suspend+0x75>

  printf(1, "[suspend] Suspending thread %d\n", tid);
 215:	83 ec 04             	sub    $0x4,%esp
 218:	ff 75 08             	push   0x8(%ebp)
 21b:	68 e4 0b 00 00       	push   $0xbe4
 220:	6a 01                	push   $0x1
 222:	e8 de 05 00 00       	call   805 <printf>
 227:	83 c4 10             	add    $0x10,%esp
  t->state = WAIT;
 22a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22d:	c7 80 08 20 00 00 03 	movl   $0x3,0x2008(%eax)
 234:	00 00 00 
  if (t == current_thread)
 237:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 23c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 23f:	75 0b                	jne    24c <thread_suspend+0x76>
    thread_schedule();
 241:	e8 ba fd ff ff       	call   0 <thread_schedule>
 246:	eb 04                	jmp    24c <thread_suspend+0x76>
  if (tid <= 0 || tid >= MAX_THREAD) return;
 248:	90                   	nop
 249:	eb 01                	jmp    24c <thread_suspend+0x76>
  if (t->state != RUNNABLE && t->state != RUNNING) return;
 24b:	90                   	nop
}
 24c:	c9                   	leave  
 24d:	c3                   	ret    

0000024e <thread_resume>:

void thread_resume(int tid) {
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	83 ec 18             	sub    $0x18,%esp
  if (tid <= 0 || tid >= MAX_THREAD) return;
 254:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 258:	7e 49                	jle    2a3 <thread_resume+0x55>
 25a:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
 25e:	7f 43                	jg     2a3 <thread_resume+0x55>
  thread_p t = &all_thread[tid];
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	69 c0 0c 20 00 00    	imul   $0x200c,%eax,%eax
 269:	05 e0 0f 00 00       	add    $0xfe0,%eax
 26e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (t->state == WAIT) {
 271:	8b 45 f4             	mov    -0xc(%ebp),%eax
 274:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 27a:	83 f8 03             	cmp    $0x3,%eax
 27d:	75 25                	jne    2a4 <thread_resume+0x56>
    t->state = RUNNABLE;
 27f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 282:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
 289:	00 00 00 
    printf(1, "[resume] Resuming thread %d\n", tid);
 28c:	83 ec 04             	sub    $0x4,%esp
 28f:	ff 75 08             	push   0x8(%ebp)
 292:	68 04 0c 00 00       	push   $0xc04
 297:	6a 01                	push   $0x1
 299:	e8 67 05 00 00       	call   805 <printf>
 29e:	83 c4 10             	add    $0x10,%esp
 2a1:	eb 01                	jmp    2a4 <thread_resume+0x56>
  if (tid <= 0 || tid >= MAX_THREAD) return;
 2a3:	90                   	nop
  }
}
 2a4:	c9                   	leave  
 2a5:	c3                   	ret    

000002a6 <mythread>:

static void mythread(void) {
 2a6:	55                   	push   %ebp
 2a7:	89 e5                	mov    %esp,%ebp
 2a9:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running (tid=%d)\n", current_thread->tid);
 2ac:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 2b1:	8b 00                	mov    (%eax),%eax
 2b3:	83 ec 04             	sub    $0x4,%esp
 2b6:	50                   	push   %eax
 2b7:	68 21 0c 00 00       	push   $0xc21
 2bc:	6a 01                	push   $0x1
 2be:	e8 42 05 00 00       	call   805 <printf>
 2c3:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 20; i++) {
 2c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2cd:	eb 23                	jmp    2f2 <mythread+0x4c>
    printf(1, "my thread %d\n", current_thread->tid);
 2cf:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 2d4:	8b 00                	mov    (%eax),%eax
 2d6:	83 ec 04             	sub    $0x4,%esp
 2d9:	50                   	push   %eax
 2da:	68 3d 0c 00 00       	push   $0xc3d
 2df:	6a 01                	push   $0x1
 2e1:	e8 1f 05 00 00       	call   805 <printf>
 2e6:	83 c4 10             	add    $0x10,%esp
    thread_schedule();
 2e9:	e8 12 fd ff ff       	call   0 <thread_schedule>
  for (i = 0; i < 20; i++) {
 2ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2f2:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 2f6:	7e d7                	jle    2cf <mythread+0x29>
  }
  printf(1, "my thread: exit (tid=%d)\n", current_thread->tid);
 2f8:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 2fd:	8b 00                	mov    (%eax),%eax
 2ff:	83 ec 04             	sub    $0x4,%esp
 302:	50                   	push   %eax
 303:	68 4b 0c 00 00       	push   $0xc4b
 308:	6a 01                	push   $0x1
 30a:	e8 f6 04 00 00       	call   805 <printf>
 30f:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 312:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 317:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 31e:	00 00 00 
  thread_schedule();
 321:	e8 da fc ff ff       	call   0 <thread_schedule>
}
 326:	90                   	nop
 327:	c9                   	leave  
 328:	c3                   	ret    

00000329 <main_thread>:

static void main_thread(void) {
 329:	55                   	push   %ebp
 32a:	89 e5                	mov    %esp,%ebp
 32c:	83 ec 18             	sub    $0x18,%esp
  int tid1, tid2;
  tid1 = thread_create(mythread);
 32f:	68 a6 02 00 00       	push   $0x2a6
 334:	e8 f9 fd ff ff       	call   132 <thread_create>
 339:	83 c4 04             	add    $0x4,%esp
 33c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  tid2 = thread_create(mythread);
 33f:	68 a6 02 00 00       	push   $0x2a6
 344:	e8 e9 fd ff ff       	call   132 <thread_create>
 349:	83 c4 04             	add    $0x4,%esp
 34c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sleep(3);
 34f:	83 ec 0c             	sub    $0xc,%esp
 352:	6a 03                	push   $0x3
 354:	e8 c0 03 00 00       	call   719 <sleep>
 359:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid1);
 35c:	83 ec 0c             	sub    $0xc,%esp
 35f:	ff 75 f4             	push   -0xc(%ebp)
 362:	e8 6f fe ff ff       	call   1d6 <thread_suspend>
 367:	83 c4 10             	add    $0x10,%esp
  sleep(3);
 36a:	83 ec 0c             	sub    $0xc,%esp
 36d:	6a 03                	push   $0x3
 36f:	e8 a5 03 00 00       	call   719 <sleep>
 374:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid2);
 377:	83 ec 0c             	sub    $0xc,%esp
 37a:	ff 75 f0             	push   -0x10(%ebp)
 37d:	e8 54 fe ff ff       	call   1d6 <thread_suspend>
 382:	83 c4 10             	add    $0x10,%esp
  sleep(3);
 385:	83 ec 0c             	sub    $0xc,%esp
 388:	6a 03                	push   $0x3
 38a:	e8 8a 03 00 00       	call   719 <sleep>
 38f:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid1);
 392:	83 ec 0c             	sub    $0xc,%esp
 395:	ff 75 f4             	push   -0xc(%ebp)
 398:	e8 b1 fe ff ff       	call   24e <thread_resume>
 39d:	83 c4 10             	add    $0x10,%esp
  sleep(3);
 3a0:	83 ec 0c             	sub    $0xc,%esp
 3a3:	6a 03                	push   $0x3
 3a5:	e8 6f 03 00 00       	call   719 <sleep>
 3aa:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid2);
 3ad:	83 ec 0c             	sub    $0xc,%esp
 3b0:	ff 75 f0             	push   -0x10(%ebp)
 3b3:	e8 96 fe ff ff       	call   24e <thread_resume>
 3b8:	83 c4 10             	add    $0x10,%esp
  sleep(50);
 3bb:	83 ec 0c             	sub    $0xc,%esp
 3be:	6a 32                	push   $0x32
 3c0:	e8 54 03 00 00       	call   719 <sleep>
 3c5:	83 c4 10             	add    $0x10,%esp

  printf(1, "main thread: exit\n");
 3c8:	83 ec 08             	sub    $0x8,%esp
 3cb:	68 65 0c 00 00       	push   $0xc65
 3d0:	6a 01                	push   $0x1
 3d2:	e8 2e 04 00 00       	call   805 <printf>
 3d7:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 3da:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 3df:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 3e6:	00 00 00 
  thread_schedule();
 3e9:	e8 12 fc ff ff       	call   0 <thread_schedule>

  exit();
 3ee:	e8 9e 02 00 00       	call   691 <exit>

000003f3 <main>:
}

int main(int argc, char *argv[]) {
 3f3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 3f7:	83 e4 f0             	and    $0xfffffff0,%esp
 3fa:	ff 71 fc             	push   -0x4(%ecx)
 3fd:	55                   	push   %ebp
 3fe:	89 e5                	mov    %esp,%ebp
 400:	51                   	push   %ecx
 401:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 404:	e8 c5 fc ff ff       	call   ce <thread_init>
  thread_create(main_thread);
 409:	83 ec 0c             	sub    $0xc,%esp
 40c:	68 29 03 00 00       	push   $0x329
 411:	e8 1c fd ff ff       	call   132 <thread_create>
 416:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 419:	e8 e2 fb ff ff       	call   0 <thread_schedule>
  exit();
 41e:	e8 6e 02 00 00       	call   691 <exit>

00000423 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 423:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 424:	a1 c0 0f 00 00       	mov    0xfc0,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 429:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 42b:	a1 c4 0f 00 00       	mov    0xfc4,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 430:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 432:	a3 c0 0f 00 00       	mov    %eax,0xfc0
    popal
 437:	61                   	popa   
    
    # return to next thread's stack context
 438:	ff e4                	jmp    *%esp

0000043a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	57                   	push   %edi
 43e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 43f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 442:	8b 55 10             	mov    0x10(%ebp),%edx
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	89 cb                	mov    %ecx,%ebx
 44a:	89 df                	mov    %ebx,%edi
 44c:	89 d1                	mov    %edx,%ecx
 44e:	fc                   	cld    
 44f:	f3 aa                	rep stos %al,%es:(%edi)
 451:	89 ca                	mov    %ecx,%edx
 453:	89 fb                	mov    %edi,%ebx
 455:	89 5d 08             	mov    %ebx,0x8(%ebp)
 458:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 45b:	90                   	nop
 45c:	5b                   	pop    %ebx
 45d:	5f                   	pop    %edi
 45e:	5d                   	pop    %ebp
 45f:	c3                   	ret    

00000460 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 466:	8b 45 08             	mov    0x8(%ebp),%eax
 469:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 46c:	90                   	nop
 46d:	8b 55 0c             	mov    0xc(%ebp),%edx
 470:	8d 42 01             	lea    0x1(%edx),%eax
 473:	89 45 0c             	mov    %eax,0xc(%ebp)
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	8d 48 01             	lea    0x1(%eax),%ecx
 47c:	89 4d 08             	mov    %ecx,0x8(%ebp)
 47f:	0f b6 12             	movzbl (%edx),%edx
 482:	88 10                	mov    %dl,(%eax)
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	84 c0                	test   %al,%al
 489:	75 e2                	jne    46d <strcpy+0xd>
    ;
  return os;
 48b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 48e:	c9                   	leave  
 48f:	c3                   	ret    

00000490 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 493:	eb 08                	jmp    49d <strcmp+0xd>
    p++, q++;
 495:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 499:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	0f b6 00             	movzbl (%eax),%eax
 4a3:	84 c0                	test   %al,%al
 4a5:	74 10                	je     4b7 <strcmp+0x27>
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	0f b6 10             	movzbl (%eax),%edx
 4ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b0:	0f b6 00             	movzbl (%eax),%eax
 4b3:	38 c2                	cmp    %al,%dl
 4b5:	74 de                	je     495 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 4b7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ba:	0f b6 00             	movzbl (%eax),%eax
 4bd:	0f b6 d0             	movzbl %al,%edx
 4c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c3:	0f b6 00             	movzbl (%eax),%eax
 4c6:	0f b6 c8             	movzbl %al,%ecx
 4c9:	89 d0                	mov    %edx,%eax
 4cb:	29 c8                	sub    %ecx,%eax
}
 4cd:	5d                   	pop    %ebp
 4ce:	c3                   	ret    

000004cf <strlen>:

uint
strlen(char *s)
{
 4cf:	55                   	push   %ebp
 4d0:	89 e5                	mov    %esp,%ebp
 4d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 4d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4dc:	eb 04                	jmp    4e2 <strlen+0x13>
 4de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e5:	8b 45 08             	mov    0x8(%ebp),%eax
 4e8:	01 d0                	add    %edx,%eax
 4ea:	0f b6 00             	movzbl (%eax),%eax
 4ed:	84 c0                	test   %al,%al
 4ef:	75 ed                	jne    4de <strlen+0xf>
    ;
  return n;
 4f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4f4:	c9                   	leave  
 4f5:	c3                   	ret    

000004f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4f6:	55                   	push   %ebp
 4f7:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4f9:	8b 45 10             	mov    0x10(%ebp),%eax
 4fc:	50                   	push   %eax
 4fd:	ff 75 0c             	push   0xc(%ebp)
 500:	ff 75 08             	push   0x8(%ebp)
 503:	e8 32 ff ff ff       	call   43a <stosb>
 508:	83 c4 0c             	add    $0xc,%esp
  return dst;
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 50e:	c9                   	leave  
 50f:	c3                   	ret    

00000510 <strchr>:

char*
strchr(const char *s, char c)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 04             	sub    $0x4,%esp
 516:	8b 45 0c             	mov    0xc(%ebp),%eax
 519:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 51c:	eb 14                	jmp    532 <strchr+0x22>
    if(*s == c)
 51e:	8b 45 08             	mov    0x8(%ebp),%eax
 521:	0f b6 00             	movzbl (%eax),%eax
 524:	38 45 fc             	cmp    %al,-0x4(%ebp)
 527:	75 05                	jne    52e <strchr+0x1e>
      return (char*)s;
 529:	8b 45 08             	mov    0x8(%ebp),%eax
 52c:	eb 13                	jmp    541 <strchr+0x31>
  for(; *s; s++)
 52e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 532:	8b 45 08             	mov    0x8(%ebp),%eax
 535:	0f b6 00             	movzbl (%eax),%eax
 538:	84 c0                	test   %al,%al
 53a:	75 e2                	jne    51e <strchr+0xe>
  return 0;
 53c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 541:	c9                   	leave  
 542:	c3                   	ret    

00000543 <gets>:

char*
gets(char *buf, int max)
{
 543:	55                   	push   %ebp
 544:	89 e5                	mov    %esp,%ebp
 546:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 549:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 550:	eb 42                	jmp    594 <gets+0x51>
    cc = read(0, &c, 1);
 552:	83 ec 04             	sub    $0x4,%esp
 555:	6a 01                	push   $0x1
 557:	8d 45 ef             	lea    -0x11(%ebp),%eax
 55a:	50                   	push   %eax
 55b:	6a 00                	push   $0x0
 55d:	e8 47 01 00 00       	call   6a9 <read>
 562:	83 c4 10             	add    $0x10,%esp
 565:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 568:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 56c:	7e 33                	jle    5a1 <gets+0x5e>
      break;
    buf[i++] = c;
 56e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 571:	8d 50 01             	lea    0x1(%eax),%edx
 574:	89 55 f4             	mov    %edx,-0xc(%ebp)
 577:	89 c2                	mov    %eax,%edx
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	01 c2                	add    %eax,%edx
 57e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 582:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 584:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 588:	3c 0a                	cmp    $0xa,%al
 58a:	74 16                	je     5a2 <gets+0x5f>
 58c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 590:	3c 0d                	cmp    $0xd,%al
 592:	74 0e                	je     5a2 <gets+0x5f>
  for(i=0; i+1 < max; ){
 594:	8b 45 f4             	mov    -0xc(%ebp),%eax
 597:	83 c0 01             	add    $0x1,%eax
 59a:	39 45 0c             	cmp    %eax,0xc(%ebp)
 59d:	7f b3                	jg     552 <gets+0xf>
 59f:	eb 01                	jmp    5a2 <gets+0x5f>
      break;
 5a1:	90                   	nop
      break;
  }
  buf[i] = '\0';
 5a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5a5:	8b 45 08             	mov    0x8(%ebp),%eax
 5a8:	01 d0                	add    %edx,%eax
 5aa:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5b0:	c9                   	leave  
 5b1:	c3                   	ret    

000005b2 <stat>:

int
stat(char *n, struct stat *st)
{
 5b2:	55                   	push   %ebp
 5b3:	89 e5                	mov    %esp,%ebp
 5b5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5b8:	83 ec 08             	sub    $0x8,%esp
 5bb:	6a 00                	push   $0x0
 5bd:	ff 75 08             	push   0x8(%ebp)
 5c0:	e8 14 01 00 00       	call   6d9 <open>
 5c5:	83 c4 10             	add    $0x10,%esp
 5c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5cf:	79 07                	jns    5d8 <stat+0x26>
    return -1;
 5d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5d6:	eb 25                	jmp    5fd <stat+0x4b>
  r = fstat(fd, st);
 5d8:	83 ec 08             	sub    $0x8,%esp
 5db:	ff 75 0c             	push   0xc(%ebp)
 5de:	ff 75 f4             	push   -0xc(%ebp)
 5e1:	e8 0b 01 00 00       	call   6f1 <fstat>
 5e6:	83 c4 10             	add    $0x10,%esp
 5e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5ec:	83 ec 0c             	sub    $0xc,%esp
 5ef:	ff 75 f4             	push   -0xc(%ebp)
 5f2:	e8 c2 00 00 00       	call   6b9 <close>
 5f7:	83 c4 10             	add    $0x10,%esp
  return r;
 5fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5fd:	c9                   	leave  
 5fe:	c3                   	ret    

000005ff <atoi>:

int
atoi(const char *s)
{
 5ff:	55                   	push   %ebp
 600:	89 e5                	mov    %esp,%ebp
 602:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 605:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 60c:	eb 25                	jmp    633 <atoi+0x34>
    n = n*10 + *s++ - '0';
 60e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 611:	89 d0                	mov    %edx,%eax
 613:	c1 e0 02             	shl    $0x2,%eax
 616:	01 d0                	add    %edx,%eax
 618:	01 c0                	add    %eax,%eax
 61a:	89 c1                	mov    %eax,%ecx
 61c:	8b 45 08             	mov    0x8(%ebp),%eax
 61f:	8d 50 01             	lea    0x1(%eax),%edx
 622:	89 55 08             	mov    %edx,0x8(%ebp)
 625:	0f b6 00             	movzbl (%eax),%eax
 628:	0f be c0             	movsbl %al,%eax
 62b:	01 c8                	add    %ecx,%eax
 62d:	83 e8 30             	sub    $0x30,%eax
 630:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 633:	8b 45 08             	mov    0x8(%ebp),%eax
 636:	0f b6 00             	movzbl (%eax),%eax
 639:	3c 2f                	cmp    $0x2f,%al
 63b:	7e 0a                	jle    647 <atoi+0x48>
 63d:	8b 45 08             	mov    0x8(%ebp),%eax
 640:	0f b6 00             	movzbl (%eax),%eax
 643:	3c 39                	cmp    $0x39,%al
 645:	7e c7                	jle    60e <atoi+0xf>
  return n;
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
 64f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 658:	8b 45 0c             	mov    0xc(%ebp),%eax
 65b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 65e:	eb 17                	jmp    677 <memmove+0x2b>
    *dst++ = *src++;
 660:	8b 55 f8             	mov    -0x8(%ebp),%edx
 663:	8d 42 01             	lea    0x1(%edx),%eax
 666:	89 45 f8             	mov    %eax,-0x8(%ebp)
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8d 48 01             	lea    0x1(%eax),%ecx
 66f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 672:	0f b6 12             	movzbl (%edx),%edx
 675:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 677:	8b 45 10             	mov    0x10(%ebp),%eax
 67a:	8d 50 ff             	lea    -0x1(%eax),%edx
 67d:	89 55 10             	mov    %edx,0x10(%ebp)
 680:	85 c0                	test   %eax,%eax
 682:	7f dc                	jg     660 <memmove+0x14>
  return vdst;
 684:	8b 45 08             	mov    0x8(%ebp),%eax
}
 687:	c9                   	leave  
 688:	c3                   	ret    

00000689 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 689:	b8 01 00 00 00       	mov    $0x1,%eax
 68e:	cd 40                	int    $0x40
 690:	c3                   	ret    

00000691 <exit>:
SYSCALL(exit)
 691:	b8 02 00 00 00       	mov    $0x2,%eax
 696:	cd 40                	int    $0x40
 698:	c3                   	ret    

00000699 <wait>:
SYSCALL(wait)
 699:	b8 03 00 00 00       	mov    $0x3,%eax
 69e:	cd 40                	int    $0x40
 6a0:	c3                   	ret    

000006a1 <pipe>:
SYSCALL(pipe)
 6a1:	b8 04 00 00 00       	mov    $0x4,%eax
 6a6:	cd 40                	int    $0x40
 6a8:	c3                   	ret    

000006a9 <read>:
SYSCALL(read)
 6a9:	b8 05 00 00 00       	mov    $0x5,%eax
 6ae:	cd 40                	int    $0x40
 6b0:	c3                   	ret    

000006b1 <write>:
SYSCALL(write)
 6b1:	b8 10 00 00 00       	mov    $0x10,%eax
 6b6:	cd 40                	int    $0x40
 6b8:	c3                   	ret    

000006b9 <close>:
SYSCALL(close)
 6b9:	b8 15 00 00 00       	mov    $0x15,%eax
 6be:	cd 40                	int    $0x40
 6c0:	c3                   	ret    

000006c1 <kill>:
SYSCALL(kill)
 6c1:	b8 06 00 00 00       	mov    $0x6,%eax
 6c6:	cd 40                	int    $0x40
 6c8:	c3                   	ret    

000006c9 <dup>:
SYSCALL(dup)
 6c9:	b8 0a 00 00 00       	mov    $0xa,%eax
 6ce:	cd 40                	int    $0x40
 6d0:	c3                   	ret    

000006d1 <exec>:
SYSCALL(exec)
 6d1:	b8 07 00 00 00       	mov    $0x7,%eax
 6d6:	cd 40                	int    $0x40
 6d8:	c3                   	ret    

000006d9 <open>:
SYSCALL(open)
 6d9:	b8 0f 00 00 00       	mov    $0xf,%eax
 6de:	cd 40                	int    $0x40
 6e0:	c3                   	ret    

000006e1 <mknod>:
SYSCALL(mknod)
 6e1:	b8 11 00 00 00       	mov    $0x11,%eax
 6e6:	cd 40                	int    $0x40
 6e8:	c3                   	ret    

000006e9 <unlink>:
SYSCALL(unlink)
 6e9:	b8 12 00 00 00       	mov    $0x12,%eax
 6ee:	cd 40                	int    $0x40
 6f0:	c3                   	ret    

000006f1 <fstat>:
SYSCALL(fstat)
 6f1:	b8 08 00 00 00       	mov    $0x8,%eax
 6f6:	cd 40                	int    $0x40
 6f8:	c3                   	ret    

000006f9 <link>:
SYSCALL(link)
 6f9:	b8 13 00 00 00       	mov    $0x13,%eax
 6fe:	cd 40                	int    $0x40
 700:	c3                   	ret    

00000701 <mkdir>:
SYSCALL(mkdir)
 701:	b8 14 00 00 00       	mov    $0x14,%eax
 706:	cd 40                	int    $0x40
 708:	c3                   	ret    

00000709 <chdir>:
SYSCALL(chdir)
 709:	b8 09 00 00 00       	mov    $0x9,%eax
 70e:	cd 40                	int    $0x40
 710:	c3                   	ret    

00000711 <sbrk>:
SYSCALL(sbrk)
 711:	b8 0c 00 00 00       	mov    $0xc,%eax
 716:	cd 40                	int    $0x40
 718:	c3                   	ret    

00000719 <sleep>:
SYSCALL(sleep)
 719:	b8 0d 00 00 00       	mov    $0xd,%eax
 71e:	cd 40                	int    $0x40
 720:	c3                   	ret    

00000721 <getpid>:
SYSCALL(getpid)
 721:	b8 0b 00 00 00       	mov    $0xb,%eax
 726:	cd 40                	int    $0x40
 728:	c3                   	ret    

00000729 <uthread_init>:
SYSCALL(uthread_init)
 729:	b8 18 00 00 00       	mov    $0x18,%eax
 72e:	cd 40                	int    $0x40
 730:	c3                   	ret    

00000731 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 731:	55                   	push   %ebp
 732:	89 e5                	mov    %esp,%ebp
 734:	83 ec 18             	sub    $0x18,%esp
 737:	8b 45 0c             	mov    0xc(%ebp),%eax
 73a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 73d:	83 ec 04             	sub    $0x4,%esp
 740:	6a 01                	push   $0x1
 742:	8d 45 f4             	lea    -0xc(%ebp),%eax
 745:	50                   	push   %eax
 746:	ff 75 08             	push   0x8(%ebp)
 749:	e8 63 ff ff ff       	call   6b1 <write>
 74e:	83 c4 10             	add    $0x10,%esp
}
 751:	90                   	nop
 752:	c9                   	leave  
 753:	c3                   	ret    

00000754 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 754:	55                   	push   %ebp
 755:	89 e5                	mov    %esp,%ebp
 757:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 75a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 761:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 765:	74 17                	je     77e <printint+0x2a>
 767:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 76b:	79 11                	jns    77e <printint+0x2a>
    neg = 1;
 76d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 774:	8b 45 0c             	mov    0xc(%ebp),%eax
 777:	f7 d8                	neg    %eax
 779:	89 45 ec             	mov    %eax,-0x14(%ebp)
 77c:	eb 06                	jmp    784 <printint+0x30>
  } else {
    x = xx;
 77e:	8b 45 0c             	mov    0xc(%ebp),%eax
 781:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 78b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 78e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 791:	ba 00 00 00 00       	mov    $0x0,%edx
 796:	f7 f1                	div    %ecx
 798:	89 d1                	mov    %edx,%ecx
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	8d 50 01             	lea    0x1(%eax),%edx
 7a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7a3:	0f b6 91 a0 0f 00 00 	movzbl 0xfa0(%ecx),%edx
 7aa:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 7ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7b4:	ba 00 00 00 00       	mov    $0x0,%edx
 7b9:	f7 f1                	div    %ecx
 7bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7c2:	75 c7                	jne    78b <printint+0x37>
  if(neg)
 7c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7c8:	74 2d                	je     7f7 <printint+0xa3>
    buf[i++] = '-';
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	8d 50 01             	lea    0x1(%eax),%edx
 7d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7d3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7d8:	eb 1d                	jmp    7f7 <printint+0xa3>
    putc(fd, buf[i]);
 7da:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	01 d0                	add    %edx,%eax
 7e2:	0f b6 00             	movzbl (%eax),%eax
 7e5:	0f be c0             	movsbl %al,%eax
 7e8:	83 ec 08             	sub    $0x8,%esp
 7eb:	50                   	push   %eax
 7ec:	ff 75 08             	push   0x8(%ebp)
 7ef:	e8 3d ff ff ff       	call   731 <putc>
 7f4:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7f7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ff:	79 d9                	jns    7da <printint+0x86>
}
 801:	90                   	nop
 802:	90                   	nop
 803:	c9                   	leave  
 804:	c3                   	ret    

00000805 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 805:	55                   	push   %ebp
 806:	89 e5                	mov    %esp,%ebp
 808:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 80b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 812:	8d 45 0c             	lea    0xc(%ebp),%eax
 815:	83 c0 04             	add    $0x4,%eax
 818:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 81b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 822:	e9 59 01 00 00       	jmp    980 <printf+0x17b>
    c = fmt[i] & 0xff;
 827:	8b 55 0c             	mov    0xc(%ebp),%edx
 82a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82d:	01 d0                	add    %edx,%eax
 82f:	0f b6 00             	movzbl (%eax),%eax
 832:	0f be c0             	movsbl %al,%eax
 835:	25 ff 00 00 00       	and    $0xff,%eax
 83a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 83d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 841:	75 2c                	jne    86f <printf+0x6a>
      if(c == '%'){
 843:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 847:	75 0c                	jne    855 <printf+0x50>
        state = '%';
 849:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 850:	e9 27 01 00 00       	jmp    97c <printf+0x177>
      } else {
        putc(fd, c);
 855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 858:	0f be c0             	movsbl %al,%eax
 85b:	83 ec 08             	sub    $0x8,%esp
 85e:	50                   	push   %eax
 85f:	ff 75 08             	push   0x8(%ebp)
 862:	e8 ca fe ff ff       	call   731 <putc>
 867:	83 c4 10             	add    $0x10,%esp
 86a:	e9 0d 01 00 00       	jmp    97c <printf+0x177>
      }
    } else if(state == '%'){
 86f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 873:	0f 85 03 01 00 00    	jne    97c <printf+0x177>
      if(c == 'd'){
 879:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 87d:	75 1e                	jne    89d <printf+0x98>
        printint(fd, *ap, 10, 1);
 87f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 882:	8b 00                	mov    (%eax),%eax
 884:	6a 01                	push   $0x1
 886:	6a 0a                	push   $0xa
 888:	50                   	push   %eax
 889:	ff 75 08             	push   0x8(%ebp)
 88c:	e8 c3 fe ff ff       	call   754 <printint>
 891:	83 c4 10             	add    $0x10,%esp
        ap++;
 894:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 898:	e9 d8 00 00 00       	jmp    975 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 89d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8a1:	74 06                	je     8a9 <printf+0xa4>
 8a3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8a7:	75 1e                	jne    8c7 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8ac:	8b 00                	mov    (%eax),%eax
 8ae:	6a 00                	push   $0x0
 8b0:	6a 10                	push   $0x10
 8b2:	50                   	push   %eax
 8b3:	ff 75 08             	push   0x8(%ebp)
 8b6:	e8 99 fe ff ff       	call   754 <printint>
 8bb:	83 c4 10             	add    $0x10,%esp
        ap++;
 8be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8c2:	e9 ae 00 00 00       	jmp    975 <printf+0x170>
      } else if(c == 's'){
 8c7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8cb:	75 43                	jne    910 <printf+0x10b>
        s = (char*)*ap;
 8cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8dd:	75 25                	jne    904 <printf+0xff>
          s = "(null)";
 8df:	c7 45 f4 78 0c 00 00 	movl   $0xc78,-0xc(%ebp)
        while(*s != 0){
 8e6:	eb 1c                	jmp    904 <printf+0xff>
          putc(fd, *s);
 8e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8eb:	0f b6 00             	movzbl (%eax),%eax
 8ee:	0f be c0             	movsbl %al,%eax
 8f1:	83 ec 08             	sub    $0x8,%esp
 8f4:	50                   	push   %eax
 8f5:	ff 75 08             	push   0x8(%ebp)
 8f8:	e8 34 fe ff ff       	call   731 <putc>
 8fd:	83 c4 10             	add    $0x10,%esp
          s++;
 900:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 904:	8b 45 f4             	mov    -0xc(%ebp),%eax
 907:	0f b6 00             	movzbl (%eax),%eax
 90a:	84 c0                	test   %al,%al
 90c:	75 da                	jne    8e8 <printf+0xe3>
 90e:	eb 65                	jmp    975 <printf+0x170>
        }
      } else if(c == 'c'){
 910:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 914:	75 1d                	jne    933 <printf+0x12e>
        putc(fd, *ap);
 916:	8b 45 e8             	mov    -0x18(%ebp),%eax
 919:	8b 00                	mov    (%eax),%eax
 91b:	0f be c0             	movsbl %al,%eax
 91e:	83 ec 08             	sub    $0x8,%esp
 921:	50                   	push   %eax
 922:	ff 75 08             	push   0x8(%ebp)
 925:	e8 07 fe ff ff       	call   731 <putc>
 92a:	83 c4 10             	add    $0x10,%esp
        ap++;
 92d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 931:	eb 42                	jmp    975 <printf+0x170>
      } else if(c == '%'){
 933:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 937:	75 17                	jne    950 <printf+0x14b>
        putc(fd, c);
 939:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 93c:	0f be c0             	movsbl %al,%eax
 93f:	83 ec 08             	sub    $0x8,%esp
 942:	50                   	push   %eax
 943:	ff 75 08             	push   0x8(%ebp)
 946:	e8 e6 fd ff ff       	call   731 <putc>
 94b:	83 c4 10             	add    $0x10,%esp
 94e:	eb 25                	jmp    975 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 950:	83 ec 08             	sub    $0x8,%esp
 953:	6a 25                	push   $0x25
 955:	ff 75 08             	push   0x8(%ebp)
 958:	e8 d4 fd ff ff       	call   731 <putc>
 95d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 960:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 963:	0f be c0             	movsbl %al,%eax
 966:	83 ec 08             	sub    $0x8,%esp
 969:	50                   	push   %eax
 96a:	ff 75 08             	push   0x8(%ebp)
 96d:	e8 bf fd ff ff       	call   731 <putc>
 972:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 975:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 97c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 980:	8b 55 0c             	mov    0xc(%ebp),%edx
 983:	8b 45 f0             	mov    -0x10(%ebp),%eax
 986:	01 d0                	add    %edx,%eax
 988:	0f b6 00             	movzbl (%eax),%eax
 98b:	84 c0                	test   %al,%al
 98d:	0f 85 94 fe ff ff    	jne    827 <printf+0x22>
    }
  }
}
 993:	90                   	nop
 994:	90                   	nop
 995:	c9                   	leave  
 996:	c3                   	ret    

00000997 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 997:	55                   	push   %ebp
 998:	89 e5                	mov    %esp,%ebp
 99a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 99d:	8b 45 08             	mov    0x8(%ebp),%eax
 9a0:	83 e8 08             	sub    $0x8,%eax
 9a3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a6:	a1 60 50 01 00       	mov    0x15060,%eax
 9ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9ae:	eb 24                	jmp    9d4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b3:	8b 00                	mov    (%eax),%eax
 9b5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9b8:	72 12                	jb     9cc <free+0x35>
 9ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c0:	77 24                	ja     9e6 <free+0x4f>
 9c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c5:	8b 00                	mov    (%eax),%eax
 9c7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9ca:	72 1a                	jb     9e6 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cf:	8b 00                	mov    (%eax),%eax
 9d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9da:	76 d4                	jbe    9b0 <free+0x19>
 9dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9df:	8b 00                	mov    (%eax),%eax
 9e1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9e4:	73 ca                	jae    9b0 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e9:	8b 40 04             	mov    0x4(%eax),%eax
 9ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f6:	01 c2                	add    %eax,%edx
 9f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fb:	8b 00                	mov    (%eax),%eax
 9fd:	39 c2                	cmp    %eax,%edx
 9ff:	75 24                	jne    a25 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a01:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a04:	8b 50 04             	mov    0x4(%eax),%edx
 a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0a:	8b 00                	mov    (%eax),%eax
 a0c:	8b 40 04             	mov    0x4(%eax),%eax
 a0f:	01 c2                	add    %eax,%edx
 a11:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a14:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1a:	8b 00                	mov    (%eax),%eax
 a1c:	8b 10                	mov    (%eax),%edx
 a1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a21:	89 10                	mov    %edx,(%eax)
 a23:	eb 0a                	jmp    a2f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a25:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a28:	8b 10                	mov    (%eax),%edx
 a2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a2d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a32:	8b 40 04             	mov    0x4(%eax),%eax
 a35:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3f:	01 d0                	add    %edx,%eax
 a41:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a44:	75 20                	jne    a66 <free+0xcf>
    p->s.size += bp->s.size;
 a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a49:	8b 50 04             	mov    0x4(%eax),%edx
 a4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a4f:	8b 40 04             	mov    0x4(%eax),%eax
 a52:	01 c2                	add    %eax,%edx
 a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a57:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5d:	8b 10                	mov    (%eax),%edx
 a5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a62:	89 10                	mov    %edx,(%eax)
 a64:	eb 08                	jmp    a6e <free+0xd7>
  } else
    p->s.ptr = bp;
 a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a69:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a6c:	89 10                	mov    %edx,(%eax)
  freep = p;
 a6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a71:	a3 60 50 01 00       	mov    %eax,0x15060
}
 a76:	90                   	nop
 a77:	c9                   	leave  
 a78:	c3                   	ret    

00000a79 <morecore>:

static Header*
morecore(uint nu)
{
 a79:	55                   	push   %ebp
 a7a:	89 e5                	mov    %esp,%ebp
 a7c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a7f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a86:	77 07                	ja     a8f <morecore+0x16>
    nu = 4096;
 a88:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a8f:	8b 45 08             	mov    0x8(%ebp),%eax
 a92:	c1 e0 03             	shl    $0x3,%eax
 a95:	83 ec 0c             	sub    $0xc,%esp
 a98:	50                   	push   %eax
 a99:	e8 73 fc ff ff       	call   711 <sbrk>
 a9e:	83 c4 10             	add    $0x10,%esp
 aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 aa4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 aa8:	75 07                	jne    ab1 <morecore+0x38>
    return 0;
 aaa:	b8 00 00 00 00       	mov    $0x0,%eax
 aaf:	eb 26                	jmp    ad7 <morecore+0x5e>
  hp = (Header*)p;
 ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aba:	8b 55 08             	mov    0x8(%ebp),%edx
 abd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac3:	83 c0 08             	add    $0x8,%eax
 ac6:	83 ec 0c             	sub    $0xc,%esp
 ac9:	50                   	push   %eax
 aca:	e8 c8 fe ff ff       	call   997 <free>
 acf:	83 c4 10             	add    $0x10,%esp
  return freep;
 ad2:	a1 60 50 01 00       	mov    0x15060,%eax
}
 ad7:	c9                   	leave  
 ad8:	c3                   	ret    

00000ad9 <malloc>:

void*
malloc(uint nbytes)
{
 ad9:	55                   	push   %ebp
 ada:	89 e5                	mov    %esp,%ebp
 adc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 adf:	8b 45 08             	mov    0x8(%ebp),%eax
 ae2:	83 c0 07             	add    $0x7,%eax
 ae5:	c1 e8 03             	shr    $0x3,%eax
 ae8:	83 c0 01             	add    $0x1,%eax
 aeb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 aee:	a1 60 50 01 00       	mov    0x15060,%eax
 af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 afa:	75 23                	jne    b1f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 afc:	c7 45 f0 58 50 01 00 	movl   $0x15058,-0x10(%ebp)
 b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b06:	a3 60 50 01 00       	mov    %eax,0x15060
 b0b:	a1 60 50 01 00       	mov    0x15060,%eax
 b10:	a3 58 50 01 00       	mov    %eax,0x15058
    base.s.size = 0;
 b15:	c7 05 5c 50 01 00 00 	movl   $0x0,0x1505c
 b1c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b22:	8b 00                	mov    (%eax),%eax
 b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2a:	8b 40 04             	mov    0x4(%eax),%eax
 b2d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b30:	77 4d                	ja     b7f <malloc+0xa6>
      if(p->s.size == nunits)
 b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b35:	8b 40 04             	mov    0x4(%eax),%eax
 b38:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b3b:	75 0c                	jne    b49 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b40:	8b 10                	mov    (%eax),%edx
 b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b45:	89 10                	mov    %edx,(%eax)
 b47:	eb 26                	jmp    b6f <malloc+0x96>
      else {
        p->s.size -= nunits;
 b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4c:	8b 40 04             	mov    0x4(%eax),%eax
 b4f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b52:	89 c2                	mov    %eax,%edx
 b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b57:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5d:	8b 40 04             	mov    0x4(%eax),%eax
 b60:	c1 e0 03             	shl    $0x3,%eax
 b63:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b69:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b6c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b72:	a3 60 50 01 00       	mov    %eax,0x15060
      return (void*)(p + 1);
 b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b7a:	83 c0 08             	add    $0x8,%eax
 b7d:	eb 3b                	jmp    bba <malloc+0xe1>
    }
    if(p == freep)
 b7f:	a1 60 50 01 00       	mov    0x15060,%eax
 b84:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b87:	75 1e                	jne    ba7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b89:	83 ec 0c             	sub    $0xc,%esp
 b8c:	ff 75 ec             	push   -0x14(%ebp)
 b8f:	e8 e5 fe ff ff       	call   a79 <morecore>
 b94:	83 c4 10             	add    $0x10,%esp
 b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b9e:	75 07                	jne    ba7 <malloc+0xce>
        return 0;
 ba0:	b8 00 00 00 00       	mov    $0x0,%eax
 ba5:	eb 13                	jmp    bba <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb0:	8b 00                	mov    (%eax),%eax
 bb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bb5:	e9 6d ff ff ff       	jmp    b27 <malloc+0x4e>
  }
}
 bba:	c9                   	leave  
 bbb:	c3                   	ret    
