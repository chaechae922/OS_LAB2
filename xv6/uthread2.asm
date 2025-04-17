
_uthread2:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
static void thread_schedule(void);


static void
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p prev = current_thread;
   6:	a1 e0 0e 00 00       	mov    0xee0,%eax
   b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  thread_p next = 0;
   e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  // 1) RUNNABLE 상태인 다른 스레드 찾기
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
  15:	c7 45 f0 00 0f 00 00 	movl   $0xf00,-0x10(%ebp)
  1c:	eb 22                	jmp    40 <thread_schedule+0x40>
    if (t->state == RUNNABLE && t != prev) {
  1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  21:	8b 40 0c             	mov    0xc(%eax),%eax
  24:	83 f8 02             	cmp    $0x2,%eax
  27:	75 10                	jne    39 <thread_schedule+0x39>
  29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  2f:	74 08                	je     39 <thread_schedule+0x39>
      next = t;
  31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  34:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
  37:	eb 11                	jmp    4a <thread_schedule+0x4a>
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
  39:	81 45 f0 10 20 00 00 	addl   $0x2010,-0x10(%ebp)
  40:	b8 a0 4f 01 00       	mov    $0x14fa0,%eax
  45:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  48:	72 d4                	jb     1e <thread_schedule+0x1e>
    }
  }
  // 2) 없다면 자기 자신이라도 다시 돌리고
  if (!next && prev->state == RUNNABLE)
  4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4e:	75 11                	jne    61 <thread_schedule+0x61>
  50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  53:	8b 40 0c             	mov    0xc(%eax),%eax
  56:	83 f8 02             	cmp    $0x2,%eax
  59:	75 06                	jne    61 <thread_schedule+0x61>
    next = prev;
  5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  5e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  // 3) 진짜 없으면 종료
  if (!next) {
  61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  65:	75 17                	jne    7e <thread_schedule+0x7e>
    printf(2, "thread_schedule: no runnable threads\n");
  67:	83 ec 08             	sub    $0x8,%esp
  6a:	68 04 0b 00 00       	push   $0xb04
  6f:	6a 02                	push   $0x2
  71:	e8 d5 06 00 00       	call   74b <printf>
  76:	83 c4 10             	add    $0x10,%esp
    exit();
  79:	e8 59 05 00 00       	call   5d7 <exit>
  }

  // 4) 전환할 게 있으면
  if (next != prev) {
  7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  81:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  84:	74 35                	je     bb <thread_schedule+0xbb>

    // 상태 갱신
    if(prev->state == RUNNING) prev->state = RUNNABLE;
  86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  89:	8b 40 0c             	mov    0xc(%eax),%eax
  8c:	83 f8 01             	cmp    $0x1,%eax
  8f:	75 0a                	jne    9b <thread_schedule+0x9b>
  91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  94:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    next->state = RUNNING;
  9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)

    // 어셈블리로 스택 포인터 저장/로드할 때 쓸 대상 지정
    next_thread = next;
  a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a8:	a3 e4 0e 00 00       	mov    %eax,0xee4

    // 실제 컨텍스트 스위치 (스택 포인터 교체)
    thread_switch();
  ad:	e8 b7 02 00 00       	call   369 <thread_switch>

    // --- 여기부터는 “새 스레드” 문맥에서 실행됩니다 ---
    current_thread = next;
  b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b5:	a3 e0 0e 00 00       	mov    %eax,0xee0
    return;
  ba:	90                   	nop
  }
}
  bb:	c9                   	leave  
  bc:	c3                   	ret    

000000bd <thread_init>:
// Initialize threading library
void thread_init(void) {
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  c0:	83 ec 08             	sub    $0x8,%esp
  // Set up main thread as thread 0
  current_thread = &all_thread[0];
  c3:	c7 05 e0 0e 00 00 00 	movl   $0xf00,0xee0
  ca:	0f 00 00 
  current_thread->tid   = 0;
  cd:	a1 e0 0e 00 00       	mov    0xee0,%eax
  d2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  current_thread->ptid  = 0;
  d9:	a1 e0 0e 00 00       	mov    0xee0,%eax
  de:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  current_thread->state = RUNNING;
  e5:	a1 e0 0e 00 00       	mov    0xee0,%eax
  ea:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)

  // Register scheduler callback (function pointer)
  uthread_init(thread_schedule);
  f1:	83 ec 0c             	sub    $0xc,%esp
  f4:	68 00 00 00 00       	push   $0x0
  f9:	e8 71 05 00 00       	call   66f <uthread_init>
  fe:	83 c4 10             	add    $0x10,%esp
}
 101:	90                   	nop
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <thread_create>:

// Create a new thread to run func()
int thread_create(void (*func)()) {
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 ec 10             	sub    $0x10,%esp
  thread_p t;
  // Find a free slot
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 10a:	c7 45 fc 00 0f 00 00 	movl   $0xf00,-0x4(%ebp)
 111:	eb 11                	jmp    124 <thread_create+0x20>
    if (t->state == FREE) break;
 113:	8b 45 fc             	mov    -0x4(%ebp),%eax
 116:	8b 40 0c             	mov    0xc(%eax),%eax
 119:	85 c0                	test   %eax,%eax
 11b:	74 13                	je     130 <thread_create+0x2c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 11d:	81 45 fc 10 20 00 00 	addl   $0x2010,-0x4(%ebp)
 124:	b8 a0 4f 01 00       	mov    $0x14fa0,%eax
 129:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 12c:	72 e5                	jb     113 <thread_create+0xf>
 12e:	eb 01                	jmp    131 <thread_create+0x2d>
    if (t->state == FREE) break;
 130:	90                   	nop
  }
  if (t == all_thread + MAX_THREAD)
 131:	b8 a0 4f 01 00       	mov    $0x14fa0,%eax
 136:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 139:	75 07                	jne    142 <thread_create+0x3e>
    return -1; // no space
 13b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 140:	eb 70                	jmp    1b2 <thread_create+0xae>

  int new_tid = t - all_thread;
 142:	8b 45 fc             	mov    -0x4(%ebp),%eax
 145:	2d 00 0f 00 00       	sub    $0xf00,%eax
 14a:	c1 f8 04             	sar    $0x4,%eax
 14d:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 153:	89 45 f8             	mov    %eax,-0x8(%ebp)
  t->tid  = new_tid;
 156:	8b 45 fc             	mov    -0x4(%ebp),%eax
 159:	8b 55 f8             	mov    -0x8(%ebp),%edx
 15c:	89 50 04             	mov    %edx,0x4(%eax)
  t->ptid = current_thread->tid;
 15f:	a1 e0 0e 00 00       	mov    0xee0,%eax
 164:	8b 50 04             	mov    0x4(%eax),%edx
 167:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16a:	89 50 08             	mov    %edx,0x8(%eax)

  // Prepare stack for initial context
  t->sp = (int)(t->stack + STACK_SIZE);
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 170:	83 c0 10             	add    $0x10,%eax
 173:	05 00 20 00 00       	add    $0x2000,%eax
 178:	89 c2                	mov    %eax,%edx
 17a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17d:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;
 17f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 182:	8b 00                	mov    (%eax),%eax
 184:	8d 50 fc             	lea    -0x4(%eax),%edx
 187:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18a:	89 10                	mov    %edx,(%eax)
  *(int*)(t->sp) = (int)func;   // return address -> func
 18c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18f:	8b 00                	mov    (%eax),%eax
 191:	89 c2                	mov    %eax,%edx
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                  // space for registers
 198:	8b 45 fc             	mov    -0x4(%ebp),%eax
 19b:	8b 00                	mov    (%eax),%eax
 19d:	8d 50 e0             	lea    -0x20(%eax),%edx
 1a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1a3:	89 10                	mov    %edx,(%eax)

  t->state = RUNNABLE;
 1a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1a8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  return new_tid;
 1af:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
 1b2:	c9                   	leave  
 1b3:	c3                   	ret    

000001b4 <thread_yield>:

// Yield execution to scheduler
void thread_yield(void) {
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	83 ec 08             	sub    $0x8,%esp
  if (current_thread->state == RUNNING)
 1ba:	a1 e0 0e 00 00       	mov    0xee0,%eax
 1bf:	8b 40 0c             	mov    0xc(%eax),%eax
 1c2:	83 f8 01             	cmp    $0x1,%eax
 1c5:	75 0c                	jne    1d3 <thread_yield+0x1f>
    current_thread->state = RUNNABLE;
 1c7:	a1 e0 0e 00 00       	mov    0xee0,%eax
 1cc:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  thread_schedule();
 1d3:	e8 28 fe ff ff       	call   0 <thread_schedule>
}
 1d8:	90                   	nop
 1d9:	c9                   	leave  
 1da:	c3                   	ret    

000001db <thread_join_all>:

// Wait for all child threads (ptid == current_thread->tid) to finish
void thread_join_all(void) {
 1db:	55                   	push   %ebp
 1dc:	89 e5                	mov    %esp,%ebp
 1de:	83 ec 18             	sub    $0x18,%esp
  int found;
  do {
    found = 0;
 1e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1e8:	c7 45 f0 00 0f 00 00 	movl   $0xf00,-0x10(%ebp)
 1ef:	eb 3e                	jmp    22f <thread_join_all+0x54>
        if (t->ptid == current_thread->tid
 1f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1f4:	8b 50 08             	mov    0x8(%eax),%edx
 1f7:	a1 e0 0e 00 00       	mov    0xee0,%eax
 1fc:	8b 40 04             	mov    0x4(%eax),%eax
 1ff:	39 c2                	cmp    %eax,%edx
 201:	75 25                	jne    228 <thread_join_all+0x4d>
                      && t->tid != current_thread->tid   // 자기 자신 건너뛰기
 203:	8b 45 f0             	mov    -0x10(%ebp),%eax
 206:	8b 50 04             	mov    0x4(%eax),%edx
 209:	a1 e0 0e 00 00       	mov    0xee0,%eax
 20e:	8b 40 04             	mov    0x4(%eax),%eax
 211:	39 c2                	cmp    %eax,%edx
 213:	74 13                	je     228 <thread_join_all+0x4d>
                      && t->state != FREE) {
 215:	8b 45 f0             	mov    -0x10(%ebp),%eax
 218:	8b 40 0c             	mov    0xc(%eax),%eax
 21b:	85 c0                	test   %eax,%eax
 21d:	74 09                	je     228 <thread_join_all+0x4d>
        found = 1;
 21f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 226:	eb 11                	jmp    239 <thread_join_all+0x5e>
    for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
 228:	81 45 f0 10 20 00 00 	addl   $0x2010,-0x10(%ebp)
 22f:	b8 a0 4f 01 00       	mov    $0x14fa0,%eax
 234:	39 45 f0             	cmp    %eax,-0x10(%ebp)
 237:	72 b8                	jb     1f1 <thread_join_all+0x16>
      }
    }
    if (found) {
 239:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 23d:	74 1d                	je     25c <thread_join_all+0x81>
      current_thread->state = WAIT; 
 23f:	a1 e0 0e 00 00       	mov    0xee0,%eax
 244:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      thread_schedule();
 24b:	e8 b0 fd ff ff       	call   0 <thread_schedule>
      current_thread->state = RUNNING;
 250:	a1 e0 0e 00 00       	mov    0xee0,%eax
 255:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
    }
  } while (found);
 25c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 260:	0f 85 7b ff ff ff    	jne    1e1 <thread_join_all+0x6>
}
 266:	90                   	nop
 267:	90                   	nop
 268:	c9                   	leave  
 269:	c3                   	ret    

0000026a <child_thread>:

static void child_thread(void) {
 26a:	55                   	push   %ebp
 26b:	89 e5                	mov    %esp,%ebp
 26d:	83 ec 18             	sub    $0x18,%esp
  printf(1, "child thread running\n");
 270:	83 ec 08             	sub    $0x8,%esp
 273:	68 2a 0b 00 00       	push   $0xb2a
 278:	6a 01                	push   $0x1
 27a:	e8 cc 04 00 00       	call   74b <printf>
 27f:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++) {
 282:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 289:	eb 1c                	jmp    2a7 <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int)current_thread);
 28b:	a1 e0 0e 00 00       	mov    0xee0,%eax
 290:	83 ec 04             	sub    $0x4,%esp
 293:	50                   	push   %eax
 294:	68 40 0b 00 00       	push   $0xb40
 299:	6a 01                	push   $0x1
 29b:	e8 ab 04 00 00       	call   74b <printf>
 2a0:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 100; i++) {
 2a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2a7:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 2ab:	7e de                	jle    28b <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 2ad:	83 ec 08             	sub    $0x8,%esp
 2b0:	68 53 0b 00 00       	push   $0xb53
 2b5:	6a 01                	push   $0x1
 2b7:	e8 8f 04 00 00       	call   74b <printf>
 2bc:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 2bf:	a1 e0 0e 00 00       	mov    0xee0,%eax
 2c4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  thread_schedule();
 2cb:	e8 30 fd ff ff       	call   0 <thread_schedule>
}
 2d0:	90                   	nop
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <mythread>:

static void mythread(void) {
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 18             	sub    $0x18,%esp
  printf(1, "my thread running\n");
 2d9:	83 ec 08             	sub    $0x8,%esp
 2dc:	68 67 0b 00 00       	push   $0xb67
 2e1:	6a 01                	push   $0x1
 2e3:	e8 63 04 00 00       	call   74b <printf>
 2e8:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 5; i++) {
 2eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2f2:	eb 14                	jmp    308 <mythread+0x35>
    thread_create(child_thread);
 2f4:	83 ec 0c             	sub    $0xc,%esp
 2f7:	68 6a 02 00 00       	push   $0x26a
 2fc:	e8 03 fe ff ff       	call   104 <thread_create>
 301:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 5; i++) {
 304:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 308:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 30c:	7e e6                	jle    2f4 <mythread+0x21>
  }
  thread_join_all();
 30e:	e8 c8 fe ff ff       	call   1db <thread_join_all>
  printf(1, "my thread: exit\n");
 313:	83 ec 08             	sub    $0x8,%esp
 316:	68 7a 0b 00 00       	push   $0xb7a
 31b:	6a 01                	push   $0x1
 31d:	e8 29 04 00 00       	call   74b <printf>
 322:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 325:	a1 e0 0e 00 00       	mov    0xee0,%eax
 32a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  thread_schedule();
 331:	e8 ca fc ff ff       	call   0 <thread_schedule>
}
 336:	90                   	nop
 337:	c9                   	leave  
 338:	c3                   	ret    

00000339 <main>:

int main(int argc, char *argv[]) {
 339:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 33d:	83 e4 f0             	and    $0xfffffff0,%esp
 340:	ff 71 fc             	push   -0x4(%ecx)
 343:	55                   	push   %ebp
 344:	89 e5                	mov    %esp,%ebp
 346:	51                   	push   %ecx
 347:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 34a:	e8 6e fd ff ff       	call   bd <thread_init>
  thread_create(mythread);
 34f:	83 ec 0c             	sub    $0xc,%esp
 352:	68 d3 02 00 00       	push   $0x2d3
 357:	e8 a8 fd ff ff       	call   104 <thread_create>
 35c:	83 c4 10             	add    $0x10,%esp
  thread_join_all();
 35f:	e8 77 fe ff ff       	call   1db <thread_join_all>
  exit();
 364:	e8 6e 02 00 00       	call   5d7 <exit>

00000369 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 369:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 36a:	a1 e0 0e 00 00       	mov    0xee0,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 36f:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 371:	a1 e4 0e 00 00       	mov    0xee4,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 376:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 378:	a3 e0 0e 00 00       	mov    %eax,0xee0
    popal
 37d:	61                   	popa   
    
    # return to next thread's stack context
 37e:	ff e4                	jmp    *%esp

00000380 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	57                   	push   %edi
 384:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 385:	8b 4d 08             	mov    0x8(%ebp),%ecx
 388:	8b 55 10             	mov    0x10(%ebp),%edx
 38b:	8b 45 0c             	mov    0xc(%ebp),%eax
 38e:	89 cb                	mov    %ecx,%ebx
 390:	89 df                	mov    %ebx,%edi
 392:	89 d1                	mov    %edx,%ecx
 394:	fc                   	cld    
 395:	f3 aa                	rep stos %al,%es:(%edi)
 397:	89 ca                	mov    %ecx,%edx
 399:	89 fb                	mov    %edi,%ebx
 39b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 39e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3a1:	90                   	nop
 3a2:	5b                   	pop    %ebx
 3a3:	5f                   	pop    %edi
 3a4:	5d                   	pop    %ebp
 3a5:	c3                   	ret    

000003a6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3a6:	55                   	push   %ebp
 3a7:	89 e5                	mov    %esp,%ebp
 3a9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3b2:	90                   	nop
 3b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 3b6:	8d 42 01             	lea    0x1(%edx),%eax
 3b9:	89 45 0c             	mov    %eax,0xc(%ebp)
 3bc:	8b 45 08             	mov    0x8(%ebp),%eax
 3bf:	8d 48 01             	lea    0x1(%eax),%ecx
 3c2:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3c5:	0f b6 12             	movzbl (%edx),%edx
 3c8:	88 10                	mov    %dl,(%eax)
 3ca:	0f b6 00             	movzbl (%eax),%eax
 3cd:	84 c0                	test   %al,%al
 3cf:	75 e2                	jne    3b3 <strcpy+0xd>
    ;
  return os;
 3d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d4:	c9                   	leave  
 3d5:	c3                   	ret    

000003d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3d6:	55                   	push   %ebp
 3d7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3d9:	eb 08                	jmp    3e3 <strcmp+0xd>
    p++, q++;
 3db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	84 c0                	test   %al,%al
 3eb:	74 10                	je     3fd <strcmp+0x27>
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	0f b6 10             	movzbl (%eax),%edx
 3f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f6:	0f b6 00             	movzbl (%eax),%eax
 3f9:	38 c2                	cmp    %al,%dl
 3fb:	74 de                	je     3db <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3fd:	8b 45 08             	mov    0x8(%ebp),%eax
 400:	0f b6 00             	movzbl (%eax),%eax
 403:	0f b6 d0             	movzbl %al,%edx
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	0f b6 00             	movzbl (%eax),%eax
 40c:	0f b6 c8             	movzbl %al,%ecx
 40f:	89 d0                	mov    %edx,%eax
 411:	29 c8                	sub    %ecx,%eax
}
 413:	5d                   	pop    %ebp
 414:	c3                   	ret    

00000415 <strlen>:

uint
strlen(char *s)
{
 415:	55                   	push   %ebp
 416:	89 e5                	mov    %esp,%ebp
 418:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 41b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 422:	eb 04                	jmp    428 <strlen+0x13>
 424:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 428:	8b 55 fc             	mov    -0x4(%ebp),%edx
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	01 d0                	add    %edx,%eax
 430:	0f b6 00             	movzbl (%eax),%eax
 433:	84 c0                	test   %al,%al
 435:	75 ed                	jne    424 <strlen+0xf>
    ;
  return n;
 437:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 43a:	c9                   	leave  
 43b:	c3                   	ret    

0000043c <memset>:

void*
memset(void *dst, int c, uint n)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 43f:	8b 45 10             	mov    0x10(%ebp),%eax
 442:	50                   	push   %eax
 443:	ff 75 0c             	push   0xc(%ebp)
 446:	ff 75 08             	push   0x8(%ebp)
 449:	e8 32 ff ff ff       	call   380 <stosb>
 44e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 451:	8b 45 08             	mov    0x8(%ebp),%eax
}
 454:	c9                   	leave  
 455:	c3                   	ret    

00000456 <strchr>:

char*
strchr(const char *s, char c)
{
 456:	55                   	push   %ebp
 457:	89 e5                	mov    %esp,%ebp
 459:	83 ec 04             	sub    $0x4,%esp
 45c:	8b 45 0c             	mov    0xc(%ebp),%eax
 45f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 462:	eb 14                	jmp    478 <strchr+0x22>
    if(*s == c)
 464:	8b 45 08             	mov    0x8(%ebp),%eax
 467:	0f b6 00             	movzbl (%eax),%eax
 46a:	38 45 fc             	cmp    %al,-0x4(%ebp)
 46d:	75 05                	jne    474 <strchr+0x1e>
      return (char*)s;
 46f:	8b 45 08             	mov    0x8(%ebp),%eax
 472:	eb 13                	jmp    487 <strchr+0x31>
  for(; *s; s++)
 474:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	0f b6 00             	movzbl (%eax),%eax
 47e:	84 c0                	test   %al,%al
 480:	75 e2                	jne    464 <strchr+0xe>
  return 0;
 482:	b8 00 00 00 00       	mov    $0x0,%eax
}
 487:	c9                   	leave  
 488:	c3                   	ret    

00000489 <gets>:

char*
gets(char *buf, int max)
{
 489:	55                   	push   %ebp
 48a:	89 e5                	mov    %esp,%ebp
 48c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 48f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 496:	eb 42                	jmp    4da <gets+0x51>
    cc = read(0, &c, 1);
 498:	83 ec 04             	sub    $0x4,%esp
 49b:	6a 01                	push   $0x1
 49d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a0:	50                   	push   %eax
 4a1:	6a 00                	push   $0x0
 4a3:	e8 47 01 00 00       	call   5ef <read>
 4a8:	83 c4 10             	add    $0x10,%esp
 4ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b2:	7e 33                	jle    4e7 <gets+0x5e>
      break;
    buf[i++] = c;
 4b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b7:	8d 50 01             	lea    0x1(%eax),%edx
 4ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4bd:	89 c2                	mov    %eax,%edx
 4bf:	8b 45 08             	mov    0x8(%ebp),%eax
 4c2:	01 c2                	add    %eax,%edx
 4c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4ca:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ce:	3c 0a                	cmp    $0xa,%al
 4d0:	74 16                	je     4e8 <gets+0x5f>
 4d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d6:	3c 0d                	cmp    $0xd,%al
 4d8:	74 0e                	je     4e8 <gets+0x5f>
  for(i=0; i+1 < max; ){
 4da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4dd:	83 c0 01             	add    $0x1,%eax
 4e0:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4e3:	7f b3                	jg     498 <gets+0xf>
 4e5:	eb 01                	jmp    4e8 <gets+0x5f>
      break;
 4e7:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	01 d0                	add    %edx,%eax
 4f0:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f6:	c9                   	leave  
 4f7:	c3                   	ret    

000004f8 <stat>:

int
stat(char *n, struct stat *st)
{
 4f8:	55                   	push   %ebp
 4f9:	89 e5                	mov    %esp,%ebp
 4fb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4fe:	83 ec 08             	sub    $0x8,%esp
 501:	6a 00                	push   $0x0
 503:	ff 75 08             	push   0x8(%ebp)
 506:	e8 14 01 00 00       	call   61f <open>
 50b:	83 c4 10             	add    $0x10,%esp
 50e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 511:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 515:	79 07                	jns    51e <stat+0x26>
    return -1;
 517:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 51c:	eb 25                	jmp    543 <stat+0x4b>
  r = fstat(fd, st);
 51e:	83 ec 08             	sub    $0x8,%esp
 521:	ff 75 0c             	push   0xc(%ebp)
 524:	ff 75 f4             	push   -0xc(%ebp)
 527:	e8 0b 01 00 00       	call   637 <fstat>
 52c:	83 c4 10             	add    $0x10,%esp
 52f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 532:	83 ec 0c             	sub    $0xc,%esp
 535:	ff 75 f4             	push   -0xc(%ebp)
 538:	e8 c2 00 00 00       	call   5ff <close>
 53d:	83 c4 10             	add    $0x10,%esp
  return r;
 540:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 543:	c9                   	leave  
 544:	c3                   	ret    

00000545 <atoi>:

int
atoi(const char *s)
{
 545:	55                   	push   %ebp
 546:	89 e5                	mov    %esp,%ebp
 548:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 54b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 552:	eb 25                	jmp    579 <atoi+0x34>
    n = n*10 + *s++ - '0';
 554:	8b 55 fc             	mov    -0x4(%ebp),%edx
 557:	89 d0                	mov    %edx,%eax
 559:	c1 e0 02             	shl    $0x2,%eax
 55c:	01 d0                	add    %edx,%eax
 55e:	01 c0                	add    %eax,%eax
 560:	89 c1                	mov    %eax,%ecx
 562:	8b 45 08             	mov    0x8(%ebp),%eax
 565:	8d 50 01             	lea    0x1(%eax),%edx
 568:	89 55 08             	mov    %edx,0x8(%ebp)
 56b:	0f b6 00             	movzbl (%eax),%eax
 56e:	0f be c0             	movsbl %al,%eax
 571:	01 c8                	add    %ecx,%eax
 573:	83 e8 30             	sub    $0x30,%eax
 576:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	0f b6 00             	movzbl (%eax),%eax
 57f:	3c 2f                	cmp    $0x2f,%al
 581:	7e 0a                	jle    58d <atoi+0x48>
 583:	8b 45 08             	mov    0x8(%ebp),%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	3c 39                	cmp    $0x39,%al
 58b:	7e c7                	jle    554 <atoi+0xf>
  return n;
 58d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 590:	c9                   	leave  
 591:	c3                   	ret    

00000592 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 592:	55                   	push   %ebp
 593:	89 e5                	mov    %esp,%ebp
 595:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 59e:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5a4:	eb 17                	jmp    5bd <memmove+0x2b>
    *dst++ = *src++;
 5a6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5a9:	8d 42 01             	lea    0x1(%edx),%eax
 5ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b2:	8d 48 01             	lea    0x1(%eax),%ecx
 5b5:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5b8:	0f b6 12             	movzbl (%edx),%edx
 5bb:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5bd:	8b 45 10             	mov    0x10(%ebp),%eax
 5c0:	8d 50 ff             	lea    -0x1(%eax),%edx
 5c3:	89 55 10             	mov    %edx,0x10(%ebp)
 5c6:	85 c0                	test   %eax,%eax
 5c8:	7f dc                	jg     5a6 <memmove+0x14>
  return vdst;
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    

000005cf <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 5cf:	b8 01 00 00 00       	mov    $0x1,%eax
 5d4:	cd 40                	int    $0x40
 5d6:	c3                   	ret    

000005d7 <exit>:
SYSCALL(exit)
 5d7:	b8 02 00 00 00       	mov    $0x2,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret    

000005df <wait>:
SYSCALL(wait)
 5df:	b8 03 00 00 00       	mov    $0x3,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret    

000005e7 <pipe>:
SYSCALL(pipe)
 5e7:	b8 04 00 00 00       	mov    $0x4,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret    

000005ef <read>:
SYSCALL(read)
 5ef:	b8 05 00 00 00       	mov    $0x5,%eax
 5f4:	cd 40                	int    $0x40
 5f6:	c3                   	ret    

000005f7 <write>:
SYSCALL(write)
 5f7:	b8 10 00 00 00       	mov    $0x10,%eax
 5fc:	cd 40                	int    $0x40
 5fe:	c3                   	ret    

000005ff <close>:
SYSCALL(close)
 5ff:	b8 15 00 00 00       	mov    $0x15,%eax
 604:	cd 40                	int    $0x40
 606:	c3                   	ret    

00000607 <kill>:
SYSCALL(kill)
 607:	b8 06 00 00 00       	mov    $0x6,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret    

0000060f <dup>:
SYSCALL(dup)
 60f:	b8 0a 00 00 00       	mov    $0xa,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret    

00000617 <exec>:
SYSCALL(exec)
 617:	b8 07 00 00 00       	mov    $0x7,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret    

0000061f <open>:
SYSCALL(open)
 61f:	b8 0f 00 00 00       	mov    $0xf,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret    

00000627 <mknod>:
SYSCALL(mknod)
 627:	b8 11 00 00 00       	mov    $0x11,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret    

0000062f <unlink>:
SYSCALL(unlink)
 62f:	b8 12 00 00 00       	mov    $0x12,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret    

00000637 <fstat>:
SYSCALL(fstat)
 637:	b8 08 00 00 00       	mov    $0x8,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret    

0000063f <link>:
SYSCALL(link)
 63f:	b8 13 00 00 00       	mov    $0x13,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret    

00000647 <mkdir>:
SYSCALL(mkdir)
 647:	b8 14 00 00 00       	mov    $0x14,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret    

0000064f <chdir>:
SYSCALL(chdir)
 64f:	b8 09 00 00 00       	mov    $0x9,%eax
 654:	cd 40                	int    $0x40
 656:	c3                   	ret    

00000657 <sbrk>:
SYSCALL(sbrk)
 657:	b8 0c 00 00 00       	mov    $0xc,%eax
 65c:	cd 40                	int    $0x40
 65e:	c3                   	ret    

0000065f <sleep>:
SYSCALL(sleep)
 65f:	b8 0d 00 00 00       	mov    $0xd,%eax
 664:	cd 40                	int    $0x40
 666:	c3                   	ret    

00000667 <getpid>:
SYSCALL(getpid)
 667:	b8 0b 00 00 00       	mov    $0xb,%eax
 66c:	cd 40                	int    $0x40
 66e:	c3                   	ret    

0000066f <uthread_init>:
SYSCALL(uthread_init)
 66f:	b8 18 00 00 00       	mov    $0x18,%eax
 674:	cd 40                	int    $0x40
 676:	c3                   	ret    

00000677 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 677:	55                   	push   %ebp
 678:	89 e5                	mov    %esp,%ebp
 67a:	83 ec 18             	sub    $0x18,%esp
 67d:	8b 45 0c             	mov    0xc(%ebp),%eax
 680:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 683:	83 ec 04             	sub    $0x4,%esp
 686:	6a 01                	push   $0x1
 688:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68b:	50                   	push   %eax
 68c:	ff 75 08             	push   0x8(%ebp)
 68f:	e8 63 ff ff ff       	call   5f7 <write>
 694:	83 c4 10             	add    $0x10,%esp
}
 697:	90                   	nop
 698:	c9                   	leave  
 699:	c3                   	ret    

0000069a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69a:	55                   	push   %ebp
 69b:	89 e5                	mov    %esp,%ebp
 69d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6ab:	74 17                	je     6c4 <printint+0x2a>
 6ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b1:	79 11                	jns    6c4 <printint+0x2a>
    neg = 1;
 6b3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bd:	f7 d8                	neg    %eax
 6bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c2:	eb 06                	jmp    6ca <printint+0x30>
  } else {
    x = xx;
 6c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d7:	ba 00 00 00 00       	mov    $0x0,%edx
 6dc:	f7 f1                	div    %ecx
 6de:	89 d1                	mov    %edx,%ecx
 6e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e3:	8d 50 01             	lea    0x1(%eax),%edx
 6e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e9:	0f b6 91 b8 0e 00 00 	movzbl 0xeb8(%ecx),%edx
 6f0:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fa:	ba 00 00 00 00       	mov    $0x0,%edx
 6ff:	f7 f1                	div    %ecx
 701:	89 45 ec             	mov    %eax,-0x14(%ebp)
 704:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 708:	75 c7                	jne    6d1 <printint+0x37>
  if(neg)
 70a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70e:	74 2d                	je     73d <printint+0xa3>
    buf[i++] = '-';
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	8d 50 01             	lea    0x1(%eax),%edx
 716:	89 55 f4             	mov    %edx,-0xc(%ebp)
 719:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 71e:	eb 1d                	jmp    73d <printint+0xa3>
    putc(fd, buf[i]);
 720:	8d 55 dc             	lea    -0x24(%ebp),%edx
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	01 d0                	add    %edx,%eax
 728:	0f b6 00             	movzbl (%eax),%eax
 72b:	0f be c0             	movsbl %al,%eax
 72e:	83 ec 08             	sub    $0x8,%esp
 731:	50                   	push   %eax
 732:	ff 75 08             	push   0x8(%ebp)
 735:	e8 3d ff ff ff       	call   677 <putc>
 73a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 73d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 741:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 745:	79 d9                	jns    720 <printint+0x86>
}
 747:	90                   	nop
 748:	90                   	nop
 749:	c9                   	leave  
 74a:	c3                   	ret    

0000074b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 74b:	55                   	push   %ebp
 74c:	89 e5                	mov    %esp,%ebp
 74e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 751:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 758:	8d 45 0c             	lea    0xc(%ebp),%eax
 75b:	83 c0 04             	add    $0x4,%eax
 75e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 761:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 768:	e9 59 01 00 00       	jmp    8c6 <printf+0x17b>
    c = fmt[i] & 0xff;
 76d:	8b 55 0c             	mov    0xc(%ebp),%edx
 770:	8b 45 f0             	mov    -0x10(%ebp),%eax
 773:	01 d0                	add    %edx,%eax
 775:	0f b6 00             	movzbl (%eax),%eax
 778:	0f be c0             	movsbl %al,%eax
 77b:	25 ff 00 00 00       	and    $0xff,%eax
 780:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 783:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 787:	75 2c                	jne    7b5 <printf+0x6a>
      if(c == '%'){
 789:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78d:	75 0c                	jne    79b <printf+0x50>
        state = '%';
 78f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 796:	e9 27 01 00 00       	jmp    8c2 <printf+0x177>
      } else {
        putc(fd, c);
 79b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79e:	0f be c0             	movsbl %al,%eax
 7a1:	83 ec 08             	sub    $0x8,%esp
 7a4:	50                   	push   %eax
 7a5:	ff 75 08             	push   0x8(%ebp)
 7a8:	e8 ca fe ff ff       	call   677 <putc>
 7ad:	83 c4 10             	add    $0x10,%esp
 7b0:	e9 0d 01 00 00       	jmp    8c2 <printf+0x177>
      }
    } else if(state == '%'){
 7b5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b9:	0f 85 03 01 00 00    	jne    8c2 <printf+0x177>
      if(c == 'd'){
 7bf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c3:	75 1e                	jne    7e3 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	6a 01                	push   $0x1
 7cc:	6a 0a                	push   $0xa
 7ce:	50                   	push   %eax
 7cf:	ff 75 08             	push   0x8(%ebp)
 7d2:	e8 c3 fe ff ff       	call   69a <printint>
 7d7:	83 c4 10             	add    $0x10,%esp
        ap++;
 7da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7de:	e9 d8 00 00 00       	jmp    8bb <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7e3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7e7:	74 06                	je     7ef <printf+0xa4>
 7e9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ed:	75 1e                	jne    80d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f2:	8b 00                	mov    (%eax),%eax
 7f4:	6a 00                	push   $0x0
 7f6:	6a 10                	push   $0x10
 7f8:	50                   	push   %eax
 7f9:	ff 75 08             	push   0x8(%ebp)
 7fc:	e8 99 fe ff ff       	call   69a <printint>
 801:	83 c4 10             	add    $0x10,%esp
        ap++;
 804:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 808:	e9 ae 00 00 00       	jmp    8bb <printf+0x170>
      } else if(c == 's'){
 80d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 811:	75 43                	jne    856 <printf+0x10b>
        s = (char*)*ap;
 813:	8b 45 e8             	mov    -0x18(%ebp),%eax
 816:	8b 00                	mov    (%eax),%eax
 818:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 81b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 81f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 823:	75 25                	jne    84a <printf+0xff>
          s = "(null)";
 825:	c7 45 f4 8b 0b 00 00 	movl   $0xb8b,-0xc(%ebp)
        while(*s != 0){
 82c:	eb 1c                	jmp    84a <printf+0xff>
          putc(fd, *s);
 82e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 831:	0f b6 00             	movzbl (%eax),%eax
 834:	0f be c0             	movsbl %al,%eax
 837:	83 ec 08             	sub    $0x8,%esp
 83a:	50                   	push   %eax
 83b:	ff 75 08             	push   0x8(%ebp)
 83e:	e8 34 fe ff ff       	call   677 <putc>
 843:	83 c4 10             	add    $0x10,%esp
          s++;
 846:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 84a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84d:	0f b6 00             	movzbl (%eax),%eax
 850:	84 c0                	test   %al,%al
 852:	75 da                	jne    82e <printf+0xe3>
 854:	eb 65                	jmp    8bb <printf+0x170>
        }
      } else if(c == 'c'){
 856:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 85a:	75 1d                	jne    879 <printf+0x12e>
        putc(fd, *ap);
 85c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85f:	8b 00                	mov    (%eax),%eax
 861:	0f be c0             	movsbl %al,%eax
 864:	83 ec 08             	sub    $0x8,%esp
 867:	50                   	push   %eax
 868:	ff 75 08             	push   0x8(%ebp)
 86b:	e8 07 fe ff ff       	call   677 <putc>
 870:	83 c4 10             	add    $0x10,%esp
        ap++;
 873:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 877:	eb 42                	jmp    8bb <printf+0x170>
      } else if(c == '%'){
 879:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 87d:	75 17                	jne    896 <printf+0x14b>
        putc(fd, c);
 87f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 882:	0f be c0             	movsbl %al,%eax
 885:	83 ec 08             	sub    $0x8,%esp
 888:	50                   	push   %eax
 889:	ff 75 08             	push   0x8(%ebp)
 88c:	e8 e6 fd ff ff       	call   677 <putc>
 891:	83 c4 10             	add    $0x10,%esp
 894:	eb 25                	jmp    8bb <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 896:	83 ec 08             	sub    $0x8,%esp
 899:	6a 25                	push   $0x25
 89b:	ff 75 08             	push   0x8(%ebp)
 89e:	e8 d4 fd ff ff       	call   677 <putc>
 8a3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a9:	0f be c0             	movsbl %al,%eax
 8ac:	83 ec 08             	sub    $0x8,%esp
 8af:	50                   	push   %eax
 8b0:	ff 75 08             	push   0x8(%ebp)
 8b3:	e8 bf fd ff ff       	call   677 <putc>
 8b8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 8c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cc:	01 d0                	add    %edx,%eax
 8ce:	0f b6 00             	movzbl (%eax),%eax
 8d1:	84 c0                	test   %al,%al
 8d3:	0f 85 94 fe ff ff    	jne    76d <printf+0x22>
    }
  }
}
 8d9:	90                   	nop
 8da:	90                   	nop
 8db:	c9                   	leave  
 8dc:	c3                   	ret    

000008dd <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8dd:	55                   	push   %ebp
 8de:	89 e5                	mov    %esp,%ebp
 8e0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e3:	8b 45 08             	mov    0x8(%ebp),%eax
 8e6:	83 e8 08             	sub    $0x8,%eax
 8e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ec:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 8f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f4:	eb 24                	jmp    91a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f9:	8b 00                	mov    (%eax),%eax
 8fb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8fe:	72 12                	jb     912 <free+0x35>
 900:	8b 45 f8             	mov    -0x8(%ebp),%eax
 903:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 906:	77 24                	ja     92c <free+0x4f>
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 910:	72 1a                	jb     92c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 912:	8b 45 fc             	mov    -0x4(%ebp),%eax
 915:	8b 00                	mov    (%eax),%eax
 917:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 920:	76 d4                	jbe    8f6 <free+0x19>
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	8b 00                	mov    (%eax),%eax
 927:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 92a:	73 ca                	jae    8f6 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 92c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 939:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93c:	01 c2                	add    %eax,%edx
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	8b 00                	mov    (%eax),%eax
 943:	39 c2                	cmp    %eax,%edx
 945:	75 24                	jne    96b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 947:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94a:	8b 50 04             	mov    0x4(%eax),%edx
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	8b 00                	mov    (%eax),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	01 c2                	add    %eax,%edx
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	8b 10                	mov    (%eax),%edx
 964:	8b 45 f8             	mov    -0x8(%ebp),%eax
 967:	89 10                	mov    %edx,(%eax)
 969:	eb 0a                	jmp    975 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	8b 10                	mov    (%eax),%edx
 970:	8b 45 f8             	mov    -0x8(%ebp),%eax
 973:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	8b 40 04             	mov    0x4(%eax),%eax
 97b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 982:	8b 45 fc             	mov    -0x4(%ebp),%eax
 985:	01 d0                	add    %edx,%eax
 987:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 98a:	75 20                	jne    9ac <free+0xcf>
    p->s.size += bp->s.size;
 98c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98f:	8b 50 04             	mov    0x4(%eax),%edx
 992:	8b 45 f8             	mov    -0x8(%ebp),%eax
 995:	8b 40 04             	mov    0x4(%eax),%eax
 998:	01 c2                	add    %eax,%edx
 99a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a3:	8b 10                	mov    (%eax),%edx
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	89 10                	mov    %edx,(%eax)
 9aa:	eb 08                	jmp    9b4 <free+0xd7>
  } else
    p->s.ptr = bp;
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9b2:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b7:	a3 a8 4f 01 00       	mov    %eax,0x14fa8
}
 9bc:	90                   	nop
 9bd:	c9                   	leave  
 9be:	c3                   	ret    

000009bf <morecore>:

static Header*
morecore(uint nu)
{
 9bf:	55                   	push   %ebp
 9c0:	89 e5                	mov    %esp,%ebp
 9c2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9cc:	77 07                	ja     9d5 <morecore+0x16>
    nu = 4096;
 9ce:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d5:	8b 45 08             	mov    0x8(%ebp),%eax
 9d8:	c1 e0 03             	shl    $0x3,%eax
 9db:	83 ec 0c             	sub    $0xc,%esp
 9de:	50                   	push   %eax
 9df:	e8 73 fc ff ff       	call   657 <sbrk>
 9e4:	83 c4 10             	add    $0x10,%esp
 9e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ea:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ee:	75 07                	jne    9f7 <morecore+0x38>
    return 0;
 9f0:	b8 00 00 00 00       	mov    $0x0,%eax
 9f5:	eb 26                	jmp    a1d <morecore+0x5e>
  hp = (Header*)p;
 9f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a00:	8b 55 08             	mov    0x8(%ebp),%edx
 a03:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a09:	83 c0 08             	add    $0x8,%eax
 a0c:	83 ec 0c             	sub    $0xc,%esp
 a0f:	50                   	push   %eax
 a10:	e8 c8 fe ff ff       	call   8dd <free>
 a15:	83 c4 10             	add    $0x10,%esp
  return freep;
 a18:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
}
 a1d:	c9                   	leave  
 a1e:	c3                   	ret    

00000a1f <malloc>:

void*
malloc(uint nbytes)
{
 a1f:	55                   	push   %ebp
 a20:	89 e5                	mov    %esp,%ebp
 a22:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a25:	8b 45 08             	mov    0x8(%ebp),%eax
 a28:	83 c0 07             	add    $0x7,%eax
 a2b:	c1 e8 03             	shr    $0x3,%eax
 a2e:	83 c0 01             	add    $0x1,%eax
 a31:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a34:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a40:	75 23                	jne    a65 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a42:	c7 45 f0 a0 4f 01 00 	movl   $0x14fa0,-0x10(%ebp)
 a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4c:	a3 a8 4f 01 00       	mov    %eax,0x14fa8
 a51:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 a56:	a3 a0 4f 01 00       	mov    %eax,0x14fa0
    base.s.size = 0;
 a5b:	c7 05 a4 4f 01 00 00 	movl   $0x0,0x14fa4
 a62:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a68:	8b 00                	mov    (%eax),%eax
 a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a70:	8b 40 04             	mov    0x4(%eax),%eax
 a73:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a76:	77 4d                	ja     ac5 <malloc+0xa6>
      if(p->s.size == nunits)
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	8b 40 04             	mov    0x4(%eax),%eax
 a7e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a81:	75 0c                	jne    a8f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a86:	8b 10                	mov    (%eax),%edx
 a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8b:	89 10                	mov    %edx,(%eax)
 a8d:	eb 26                	jmp    ab5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a92:	8b 40 04             	mov    0x4(%eax),%eax
 a95:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a98:	89 c2                	mov    %eax,%edx
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	8b 40 04             	mov    0x4(%eax),%eax
 aa6:	c1 e0 03             	shl    $0x3,%eax
 aa9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab8:	a3 a8 4f 01 00       	mov    %eax,0x14fa8
      return (void*)(p + 1);
 abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac0:	83 c0 08             	add    $0x8,%eax
 ac3:	eb 3b                	jmp    b00 <malloc+0xe1>
    }
    if(p == freep)
 ac5:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 aca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 acd:	75 1e                	jne    aed <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 acf:	83 ec 0c             	sub    $0xc,%esp
 ad2:	ff 75 ec             	push   -0x14(%ebp)
 ad5:	e8 e5 fe ff ff       	call   9bf <morecore>
 ada:	83 c4 10             	add    $0x10,%esp
 add:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae4:	75 07                	jne    aed <malloc+0xce>
        return 0;
 ae6:	b8 00 00 00 00       	mov    $0x0,%eax
 aeb:	eb 13                	jmp    b00 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af6:	8b 00                	mov    (%eax),%eax
 af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 afb:	e9 6d ff ff ff       	jmp    a6d <malloc+0x4e>
  }
}
 b00:	c9                   	leave  
 b01:	c3                   	ret    
