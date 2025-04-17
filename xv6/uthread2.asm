
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
  71:	e8 d4 06 00 00       	call   74a <printf>
  76:	83 c4 10             	add    $0x10,%esp
    exit();
  79:	e8 58 05 00 00       	call   5d6 <exit>
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
  f9:	e8 70 05 00 00       	call   66e <uthread_init>
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
 27a:	e8 cb 04 00 00       	call   74a <printf>
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
 29b:	e8 aa 04 00 00       	call   74a <printf>
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
 2b7:	e8 8e 04 00 00       	call   74a <printf>
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
 2e3:	e8 62 04 00 00       	call   74a <printf>
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
 31d:	e8 28 04 00 00       	call   74a <printf>
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
 364:	e8 6d 02 00 00       	call   5d6 <exit>

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
 37e:	c3                   	ret    

0000037f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	57                   	push   %edi
 383:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 384:	8b 4d 08             	mov    0x8(%ebp),%ecx
 387:	8b 55 10             	mov    0x10(%ebp),%edx
 38a:	8b 45 0c             	mov    0xc(%ebp),%eax
 38d:	89 cb                	mov    %ecx,%ebx
 38f:	89 df                	mov    %ebx,%edi
 391:	89 d1                	mov    %edx,%ecx
 393:	fc                   	cld    
 394:	f3 aa                	rep stos %al,%es:(%edi)
 396:	89 ca                	mov    %ecx,%edx
 398:	89 fb                	mov    %edi,%ebx
 39a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 39d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3a0:	90                   	nop
 3a1:	5b                   	pop    %ebx
 3a2:	5f                   	pop    %edi
 3a3:	5d                   	pop    %ebp
 3a4:	c3                   	ret    

000003a5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3b1:	90                   	nop
 3b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 3b5:	8d 42 01             	lea    0x1(%edx),%eax
 3b8:	89 45 0c             	mov    %eax,0xc(%ebp)
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	8d 48 01             	lea    0x1(%eax),%ecx
 3c1:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3c4:	0f b6 12             	movzbl (%edx),%edx
 3c7:	88 10                	mov    %dl,(%eax)
 3c9:	0f b6 00             	movzbl (%eax),%eax
 3cc:	84 c0                	test   %al,%al
 3ce:	75 e2                	jne    3b2 <strcpy+0xd>
    ;
  return os;
 3d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d3:	c9                   	leave  
 3d4:	c3                   	ret    

000003d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3d5:	55                   	push   %ebp
 3d6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3d8:	eb 08                	jmp    3e2 <strcmp+0xd>
    p++, q++;
 3da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3de:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
 3e5:	0f b6 00             	movzbl (%eax),%eax
 3e8:	84 c0                	test   %al,%al
 3ea:	74 10                	je     3fc <strcmp+0x27>
 3ec:	8b 45 08             	mov    0x8(%ebp),%eax
 3ef:	0f b6 10             	movzbl (%eax),%edx
 3f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f5:	0f b6 00             	movzbl (%eax),%eax
 3f8:	38 c2                	cmp    %al,%dl
 3fa:	74 de                	je     3da <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	0f b6 00             	movzbl (%eax),%eax
 402:	0f b6 d0             	movzbl %al,%edx
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	0f b6 00             	movzbl (%eax),%eax
 40b:	0f b6 c8             	movzbl %al,%ecx
 40e:	89 d0                	mov    %edx,%eax
 410:	29 c8                	sub    %ecx,%eax
}
 412:	5d                   	pop    %ebp
 413:	c3                   	ret    

00000414 <strlen>:

uint
strlen(char *s)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
 417:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 41a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 421:	eb 04                	jmp    427 <strlen+0x13>
 423:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 427:	8b 55 fc             	mov    -0x4(%ebp),%edx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	01 d0                	add    %edx,%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	84 c0                	test   %al,%al
 434:	75 ed                	jne    423 <strlen+0xf>
    ;
  return n;
 436:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <memset>:

void*
memset(void *dst, int c, uint n)
{
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 43e:	8b 45 10             	mov    0x10(%ebp),%eax
 441:	50                   	push   %eax
 442:	ff 75 0c             	push   0xc(%ebp)
 445:	ff 75 08             	push   0x8(%ebp)
 448:	e8 32 ff ff ff       	call   37f <stosb>
 44d:	83 c4 0c             	add    $0xc,%esp
  return dst;
 450:	8b 45 08             	mov    0x8(%ebp),%eax
}
 453:	c9                   	leave  
 454:	c3                   	ret    

00000455 <strchr>:

char*
strchr(const char *s, char c)
{
 455:	55                   	push   %ebp
 456:	89 e5                	mov    %esp,%ebp
 458:	83 ec 04             	sub    $0x4,%esp
 45b:	8b 45 0c             	mov    0xc(%ebp),%eax
 45e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 461:	eb 14                	jmp    477 <strchr+0x22>
    if(*s == c)
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	0f b6 00             	movzbl (%eax),%eax
 469:	38 45 fc             	cmp    %al,-0x4(%ebp)
 46c:	75 05                	jne    473 <strchr+0x1e>
      return (char*)s;
 46e:	8b 45 08             	mov    0x8(%ebp),%eax
 471:	eb 13                	jmp    486 <strchr+0x31>
  for(; *s; s++)
 473:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	0f b6 00             	movzbl (%eax),%eax
 47d:	84 c0                	test   %al,%al
 47f:	75 e2                	jne    463 <strchr+0xe>
  return 0;
 481:	b8 00 00 00 00       	mov    $0x0,%eax
}
 486:	c9                   	leave  
 487:	c3                   	ret    

00000488 <gets>:

char*
gets(char *buf, int max)
{
 488:	55                   	push   %ebp
 489:	89 e5                	mov    %esp,%ebp
 48b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 48e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 495:	eb 42                	jmp    4d9 <gets+0x51>
    cc = read(0, &c, 1);
 497:	83 ec 04             	sub    $0x4,%esp
 49a:	6a 01                	push   $0x1
 49c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 49f:	50                   	push   %eax
 4a0:	6a 00                	push   $0x0
 4a2:	e8 47 01 00 00       	call   5ee <read>
 4a7:	83 c4 10             	add    $0x10,%esp
 4aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b1:	7e 33                	jle    4e6 <gets+0x5e>
      break;
    buf[i++] = c;
 4b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b6:	8d 50 01             	lea    0x1(%eax),%edx
 4b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4bc:	89 c2                	mov    %eax,%edx
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
 4c1:	01 c2                	add    %eax,%edx
 4c3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4cd:	3c 0a                	cmp    $0xa,%al
 4cf:	74 16                	je     4e7 <gets+0x5f>
 4d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d5:	3c 0d                	cmp    $0xd,%al
 4d7:	74 0e                	je     4e7 <gets+0x5f>
  for(i=0; i+1 < max; ){
 4d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4dc:	83 c0 01             	add    $0x1,%eax
 4df:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4e2:	7f b3                	jg     497 <gets+0xf>
 4e4:	eb 01                	jmp    4e7 <gets+0x5f>
      break;
 4e6:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4ea:	8b 45 08             	mov    0x8(%ebp),%eax
 4ed:	01 d0                	add    %edx,%eax
 4ef:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f5:	c9                   	leave  
 4f6:	c3                   	ret    

000004f7 <stat>:

int
stat(char *n, struct stat *st)
{
 4f7:	55                   	push   %ebp
 4f8:	89 e5                	mov    %esp,%ebp
 4fa:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4fd:	83 ec 08             	sub    $0x8,%esp
 500:	6a 00                	push   $0x0
 502:	ff 75 08             	push   0x8(%ebp)
 505:	e8 14 01 00 00       	call   61e <open>
 50a:	83 c4 10             	add    $0x10,%esp
 50d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 514:	79 07                	jns    51d <stat+0x26>
    return -1;
 516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 51b:	eb 25                	jmp    542 <stat+0x4b>
  r = fstat(fd, st);
 51d:	83 ec 08             	sub    $0x8,%esp
 520:	ff 75 0c             	push   0xc(%ebp)
 523:	ff 75 f4             	push   -0xc(%ebp)
 526:	e8 0b 01 00 00       	call   636 <fstat>
 52b:	83 c4 10             	add    $0x10,%esp
 52e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 531:	83 ec 0c             	sub    $0xc,%esp
 534:	ff 75 f4             	push   -0xc(%ebp)
 537:	e8 c2 00 00 00       	call   5fe <close>
 53c:	83 c4 10             	add    $0x10,%esp
  return r;
 53f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 542:	c9                   	leave  
 543:	c3                   	ret    

00000544 <atoi>:

int
atoi(const char *s)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 54a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 551:	eb 25                	jmp    578 <atoi+0x34>
    n = n*10 + *s++ - '0';
 553:	8b 55 fc             	mov    -0x4(%ebp),%edx
 556:	89 d0                	mov    %edx,%eax
 558:	c1 e0 02             	shl    $0x2,%eax
 55b:	01 d0                	add    %edx,%eax
 55d:	01 c0                	add    %eax,%eax
 55f:	89 c1                	mov    %eax,%ecx
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	8d 50 01             	lea    0x1(%eax),%edx
 567:	89 55 08             	mov    %edx,0x8(%ebp)
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	0f be c0             	movsbl %al,%eax
 570:	01 c8                	add    %ecx,%eax
 572:	83 e8 30             	sub    $0x30,%eax
 575:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	0f b6 00             	movzbl (%eax),%eax
 57e:	3c 2f                	cmp    $0x2f,%al
 580:	7e 0a                	jle    58c <atoi+0x48>
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	0f b6 00             	movzbl (%eax),%eax
 588:	3c 39                	cmp    $0x39,%al
 58a:	7e c7                	jle    553 <atoi+0xf>
  return n;
 58c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 58f:	c9                   	leave  
 590:	c3                   	ret    

00000591 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 591:	55                   	push   %ebp
 592:	89 e5                	mov    %esp,%ebp
 594:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 59d:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5a3:	eb 17                	jmp    5bc <memmove+0x2b>
    *dst++ = *src++;
 5a5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5a8:	8d 42 01             	lea    0x1(%edx),%eax
 5ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b1:	8d 48 01             	lea    0x1(%eax),%ecx
 5b4:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5b7:	0f b6 12             	movzbl (%edx),%edx
 5ba:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5bc:	8b 45 10             	mov    0x10(%ebp),%eax
 5bf:	8d 50 ff             	lea    -0x1(%eax),%edx
 5c2:	89 55 10             	mov    %edx,0x10(%ebp)
 5c5:	85 c0                	test   %eax,%eax
 5c7:	7f dc                	jg     5a5 <memmove+0x14>
  return vdst;
 5c9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5cc:	c9                   	leave  
 5cd:	c3                   	ret    

000005ce <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 5ce:	b8 01 00 00 00       	mov    $0x1,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <exit>:
SYSCALL(exit)
 5d6:	b8 02 00 00 00       	mov    $0x2,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <wait>:
SYSCALL(wait)
 5de:	b8 03 00 00 00       	mov    $0x3,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <pipe>:
SYSCALL(pipe)
 5e6:	b8 04 00 00 00       	mov    $0x4,%eax
 5eb:	cd 40                	int    $0x40
 5ed:	c3                   	ret    

000005ee <read>:
SYSCALL(read)
 5ee:	b8 05 00 00 00       	mov    $0x5,%eax
 5f3:	cd 40                	int    $0x40
 5f5:	c3                   	ret    

000005f6 <write>:
SYSCALL(write)
 5f6:	b8 10 00 00 00       	mov    $0x10,%eax
 5fb:	cd 40                	int    $0x40
 5fd:	c3                   	ret    

000005fe <close>:
SYSCALL(close)
 5fe:	b8 15 00 00 00       	mov    $0x15,%eax
 603:	cd 40                	int    $0x40
 605:	c3                   	ret    

00000606 <kill>:
SYSCALL(kill)
 606:	b8 06 00 00 00       	mov    $0x6,%eax
 60b:	cd 40                	int    $0x40
 60d:	c3                   	ret    

0000060e <dup>:
SYSCALL(dup)
 60e:	b8 0a 00 00 00       	mov    $0xa,%eax
 613:	cd 40                	int    $0x40
 615:	c3                   	ret    

00000616 <exec>:
SYSCALL(exec)
 616:	b8 07 00 00 00       	mov    $0x7,%eax
 61b:	cd 40                	int    $0x40
 61d:	c3                   	ret    

0000061e <open>:
SYSCALL(open)
 61e:	b8 0f 00 00 00       	mov    $0xf,%eax
 623:	cd 40                	int    $0x40
 625:	c3                   	ret    

00000626 <mknod>:
SYSCALL(mknod)
 626:	b8 11 00 00 00       	mov    $0x11,%eax
 62b:	cd 40                	int    $0x40
 62d:	c3                   	ret    

0000062e <unlink>:
SYSCALL(unlink)
 62e:	b8 12 00 00 00       	mov    $0x12,%eax
 633:	cd 40                	int    $0x40
 635:	c3                   	ret    

00000636 <fstat>:
SYSCALL(fstat)
 636:	b8 08 00 00 00       	mov    $0x8,%eax
 63b:	cd 40                	int    $0x40
 63d:	c3                   	ret    

0000063e <link>:
SYSCALL(link)
 63e:	b8 13 00 00 00       	mov    $0x13,%eax
 643:	cd 40                	int    $0x40
 645:	c3                   	ret    

00000646 <mkdir>:
SYSCALL(mkdir)
 646:	b8 14 00 00 00       	mov    $0x14,%eax
 64b:	cd 40                	int    $0x40
 64d:	c3                   	ret    

0000064e <chdir>:
SYSCALL(chdir)
 64e:	b8 09 00 00 00       	mov    $0x9,%eax
 653:	cd 40                	int    $0x40
 655:	c3                   	ret    

00000656 <sbrk>:
SYSCALL(sbrk)
 656:	b8 0c 00 00 00       	mov    $0xc,%eax
 65b:	cd 40                	int    $0x40
 65d:	c3                   	ret    

0000065e <sleep>:
SYSCALL(sleep)
 65e:	b8 0d 00 00 00       	mov    $0xd,%eax
 663:	cd 40                	int    $0x40
 665:	c3                   	ret    

00000666 <getpid>:
SYSCALL(getpid)
 666:	b8 0b 00 00 00       	mov    $0xb,%eax
 66b:	cd 40                	int    $0x40
 66d:	c3                   	ret    

0000066e <uthread_init>:
SYSCALL(uthread_init)
 66e:	b8 18 00 00 00       	mov    $0x18,%eax
 673:	cd 40                	int    $0x40
 675:	c3                   	ret    

00000676 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 676:	55                   	push   %ebp
 677:	89 e5                	mov    %esp,%ebp
 679:	83 ec 18             	sub    $0x18,%esp
 67c:	8b 45 0c             	mov    0xc(%ebp),%eax
 67f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 682:	83 ec 04             	sub    $0x4,%esp
 685:	6a 01                	push   $0x1
 687:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68a:	50                   	push   %eax
 68b:	ff 75 08             	push   0x8(%ebp)
 68e:	e8 63 ff ff ff       	call   5f6 <write>
 693:	83 c4 10             	add    $0x10,%esp
}
 696:	90                   	nop
 697:	c9                   	leave  
 698:	c3                   	ret    

00000699 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 699:	55                   	push   %ebp
 69a:	89 e5                	mov    %esp,%ebp
 69c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 69f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6aa:	74 17                	je     6c3 <printint+0x2a>
 6ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b0:	79 11                	jns    6c3 <printint+0x2a>
    neg = 1;
 6b2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bc:	f7 d8                	neg    %eax
 6be:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c1:	eb 06                	jmp    6c9 <printint+0x30>
  } else {
    x = xx;
 6c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d6:	ba 00 00 00 00       	mov    $0x0,%edx
 6db:	f7 f1                	div    %ecx
 6dd:	89 d1                	mov    %edx,%ecx
 6df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e2:	8d 50 01             	lea    0x1(%eax),%edx
 6e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e8:	0f b6 91 b8 0e 00 00 	movzbl 0xeb8(%ecx),%edx
 6ef:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f9:	ba 00 00 00 00       	mov    $0x0,%edx
 6fe:	f7 f1                	div    %ecx
 700:	89 45 ec             	mov    %eax,-0x14(%ebp)
 703:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 707:	75 c7                	jne    6d0 <printint+0x37>
  if(neg)
 709:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70d:	74 2d                	je     73c <printint+0xa3>
    buf[i++] = '-';
 70f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 712:	8d 50 01             	lea    0x1(%eax),%edx
 715:	89 55 f4             	mov    %edx,-0xc(%ebp)
 718:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 71d:	eb 1d                	jmp    73c <printint+0xa3>
    putc(fd, buf[i]);
 71f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 722:	8b 45 f4             	mov    -0xc(%ebp),%eax
 725:	01 d0                	add    %edx,%eax
 727:	0f b6 00             	movzbl (%eax),%eax
 72a:	0f be c0             	movsbl %al,%eax
 72d:	83 ec 08             	sub    $0x8,%esp
 730:	50                   	push   %eax
 731:	ff 75 08             	push   0x8(%ebp)
 734:	e8 3d ff ff ff       	call   676 <putc>
 739:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 73c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 740:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 744:	79 d9                	jns    71f <printint+0x86>
}
 746:	90                   	nop
 747:	90                   	nop
 748:	c9                   	leave  
 749:	c3                   	ret    

0000074a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 74a:	55                   	push   %ebp
 74b:	89 e5                	mov    %esp,%ebp
 74d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 750:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 757:	8d 45 0c             	lea    0xc(%ebp),%eax
 75a:	83 c0 04             	add    $0x4,%eax
 75d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 760:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 767:	e9 59 01 00 00       	jmp    8c5 <printf+0x17b>
    c = fmt[i] & 0xff;
 76c:	8b 55 0c             	mov    0xc(%ebp),%edx
 76f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 772:	01 d0                	add    %edx,%eax
 774:	0f b6 00             	movzbl (%eax),%eax
 777:	0f be c0             	movsbl %al,%eax
 77a:	25 ff 00 00 00       	and    $0xff,%eax
 77f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 782:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 786:	75 2c                	jne    7b4 <printf+0x6a>
      if(c == '%'){
 788:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78c:	75 0c                	jne    79a <printf+0x50>
        state = '%';
 78e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 795:	e9 27 01 00 00       	jmp    8c1 <printf+0x177>
      } else {
        putc(fd, c);
 79a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79d:	0f be c0             	movsbl %al,%eax
 7a0:	83 ec 08             	sub    $0x8,%esp
 7a3:	50                   	push   %eax
 7a4:	ff 75 08             	push   0x8(%ebp)
 7a7:	e8 ca fe ff ff       	call   676 <putc>
 7ac:	83 c4 10             	add    $0x10,%esp
 7af:	e9 0d 01 00 00       	jmp    8c1 <printf+0x177>
      }
    } else if(state == '%'){
 7b4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b8:	0f 85 03 01 00 00    	jne    8c1 <printf+0x177>
      if(c == 'd'){
 7be:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c2:	75 1e                	jne    7e2 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c7:	8b 00                	mov    (%eax),%eax
 7c9:	6a 01                	push   $0x1
 7cb:	6a 0a                	push   $0xa
 7cd:	50                   	push   %eax
 7ce:	ff 75 08             	push   0x8(%ebp)
 7d1:	e8 c3 fe ff ff       	call   699 <printint>
 7d6:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7dd:	e9 d8 00 00 00       	jmp    8ba <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7e2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7e6:	74 06                	je     7ee <printf+0xa4>
 7e8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ec:	75 1e                	jne    80c <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f1:	8b 00                	mov    (%eax),%eax
 7f3:	6a 00                	push   $0x0
 7f5:	6a 10                	push   $0x10
 7f7:	50                   	push   %eax
 7f8:	ff 75 08             	push   0x8(%ebp)
 7fb:	e8 99 fe ff ff       	call   699 <printint>
 800:	83 c4 10             	add    $0x10,%esp
        ap++;
 803:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 807:	e9 ae 00 00 00       	jmp    8ba <printf+0x170>
      } else if(c == 's'){
 80c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 810:	75 43                	jne    855 <printf+0x10b>
        s = (char*)*ap;
 812:	8b 45 e8             	mov    -0x18(%ebp),%eax
 815:	8b 00                	mov    (%eax),%eax
 817:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 81a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 81e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 822:	75 25                	jne    849 <printf+0xff>
          s = "(null)";
 824:	c7 45 f4 8b 0b 00 00 	movl   $0xb8b,-0xc(%ebp)
        while(*s != 0){
 82b:	eb 1c                	jmp    849 <printf+0xff>
          putc(fd, *s);
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	0f b6 00             	movzbl (%eax),%eax
 833:	0f be c0             	movsbl %al,%eax
 836:	83 ec 08             	sub    $0x8,%esp
 839:	50                   	push   %eax
 83a:	ff 75 08             	push   0x8(%ebp)
 83d:	e8 34 fe ff ff       	call   676 <putc>
 842:	83 c4 10             	add    $0x10,%esp
          s++;
 845:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	0f b6 00             	movzbl (%eax),%eax
 84f:	84 c0                	test   %al,%al
 851:	75 da                	jne    82d <printf+0xe3>
 853:	eb 65                	jmp    8ba <printf+0x170>
        }
      } else if(c == 'c'){
 855:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 859:	75 1d                	jne    878 <printf+0x12e>
        putc(fd, *ap);
 85b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85e:	8b 00                	mov    (%eax),%eax
 860:	0f be c0             	movsbl %al,%eax
 863:	83 ec 08             	sub    $0x8,%esp
 866:	50                   	push   %eax
 867:	ff 75 08             	push   0x8(%ebp)
 86a:	e8 07 fe ff ff       	call   676 <putc>
 86f:	83 c4 10             	add    $0x10,%esp
        ap++;
 872:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 876:	eb 42                	jmp    8ba <printf+0x170>
      } else if(c == '%'){
 878:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 87c:	75 17                	jne    895 <printf+0x14b>
        putc(fd, c);
 87e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 881:	0f be c0             	movsbl %al,%eax
 884:	83 ec 08             	sub    $0x8,%esp
 887:	50                   	push   %eax
 888:	ff 75 08             	push   0x8(%ebp)
 88b:	e8 e6 fd ff ff       	call   676 <putc>
 890:	83 c4 10             	add    $0x10,%esp
 893:	eb 25                	jmp    8ba <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 895:	83 ec 08             	sub    $0x8,%esp
 898:	6a 25                	push   $0x25
 89a:	ff 75 08             	push   0x8(%ebp)
 89d:	e8 d4 fd ff ff       	call   676 <putc>
 8a2:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a8:	0f be c0             	movsbl %al,%eax
 8ab:	83 ec 08             	sub    $0x8,%esp
 8ae:	50                   	push   %eax
 8af:	ff 75 08             	push   0x8(%ebp)
 8b2:	e8 bf fd ff ff       	call   676 <putc>
 8b7:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8c5:	8b 55 0c             	mov    0xc(%ebp),%edx
 8c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cb:	01 d0                	add    %edx,%eax
 8cd:	0f b6 00             	movzbl (%eax),%eax
 8d0:	84 c0                	test   %al,%al
 8d2:	0f 85 94 fe ff ff    	jne    76c <printf+0x22>
    }
  }
}
 8d8:	90                   	nop
 8d9:	90                   	nop
 8da:	c9                   	leave  
 8db:	c3                   	ret    

000008dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8dc:	55                   	push   %ebp
 8dd:	89 e5                	mov    %esp,%ebp
 8df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e2:	8b 45 08             	mov    0x8(%ebp),%eax
 8e5:	83 e8 08             	sub    $0x8,%eax
 8e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8eb:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 8f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f3:	eb 24                	jmp    919 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f8:	8b 00                	mov    (%eax),%eax
 8fa:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8fd:	72 12                	jb     911 <free+0x35>
 8ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 902:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 905:	77 24                	ja     92b <free+0x4f>
 907:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90a:	8b 00                	mov    (%eax),%eax
 90c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 90f:	72 1a                	jb     92b <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	8b 00                	mov    (%eax),%eax
 916:	89 45 fc             	mov    %eax,-0x4(%ebp)
 919:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91f:	76 d4                	jbe    8f5 <free+0x19>
 921:	8b 45 fc             	mov    -0x4(%ebp),%eax
 924:	8b 00                	mov    (%eax),%eax
 926:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 929:	73 ca                	jae    8f5 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 92b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92e:	8b 40 04             	mov    0x4(%eax),%eax
 931:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 938:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93b:	01 c2                	add    %eax,%edx
 93d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 940:	8b 00                	mov    (%eax),%eax
 942:	39 c2                	cmp    %eax,%edx
 944:	75 24                	jne    96a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 946:	8b 45 f8             	mov    -0x8(%ebp),%eax
 949:	8b 50 04             	mov    0x4(%eax),%edx
 94c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94f:	8b 00                	mov    (%eax),%eax
 951:	8b 40 04             	mov    0x4(%eax),%eax
 954:	01 c2                	add    %eax,%edx
 956:	8b 45 f8             	mov    -0x8(%ebp),%eax
 959:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	8b 00                	mov    (%eax),%eax
 961:	8b 10                	mov    (%eax),%edx
 963:	8b 45 f8             	mov    -0x8(%ebp),%eax
 966:	89 10                	mov    %edx,(%eax)
 968:	eb 0a                	jmp    974 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 96a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96d:	8b 10                	mov    (%eax),%edx
 96f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 972:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	8b 40 04             	mov    0x4(%eax),%eax
 97a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	01 d0                	add    %edx,%eax
 986:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 989:	75 20                	jne    9ab <free+0xcf>
    p->s.size += bp->s.size;
 98b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98e:	8b 50 04             	mov    0x4(%eax),%edx
 991:	8b 45 f8             	mov    -0x8(%ebp),%eax
 994:	8b 40 04             	mov    0x4(%eax),%eax
 997:	01 c2                	add    %eax,%edx
 999:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 99f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a2:	8b 10                	mov    (%eax),%edx
 9a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a7:	89 10                	mov    %edx,(%eax)
 9a9:	eb 08                	jmp    9b3 <free+0xd7>
  } else
    p->s.ptr = bp;
 9ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9b1:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	a3 a8 4f 01 00       	mov    %eax,0x14fa8
}
 9bb:	90                   	nop
 9bc:	c9                   	leave  
 9bd:	c3                   	ret    

000009be <morecore>:

static Header*
morecore(uint nu)
{
 9be:	55                   	push   %ebp
 9bf:	89 e5                	mov    %esp,%ebp
 9c1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c4:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9cb:	77 07                	ja     9d4 <morecore+0x16>
    nu = 4096;
 9cd:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d4:	8b 45 08             	mov    0x8(%ebp),%eax
 9d7:	c1 e0 03             	shl    $0x3,%eax
 9da:	83 ec 0c             	sub    $0xc,%esp
 9dd:	50                   	push   %eax
 9de:	e8 73 fc ff ff       	call   656 <sbrk>
 9e3:	83 c4 10             	add    $0x10,%esp
 9e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9e9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ed:	75 07                	jne    9f6 <morecore+0x38>
    return 0;
 9ef:	b8 00 00 00 00       	mov    $0x0,%eax
 9f4:	eb 26                	jmp    a1c <morecore+0x5e>
  hp = (Header*)p;
 9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ff:	8b 55 08             	mov    0x8(%ebp),%edx
 a02:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	83 c0 08             	add    $0x8,%eax
 a0b:	83 ec 0c             	sub    $0xc,%esp
 a0e:	50                   	push   %eax
 a0f:	e8 c8 fe ff ff       	call   8dc <free>
 a14:	83 c4 10             	add    $0x10,%esp
  return freep;
 a17:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
}
 a1c:	c9                   	leave  
 a1d:	c3                   	ret    

00000a1e <malloc>:

void*
malloc(uint nbytes)
{
 a1e:	55                   	push   %ebp
 a1f:	89 e5                	mov    %esp,%ebp
 a21:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a24:	8b 45 08             	mov    0x8(%ebp),%eax
 a27:	83 c0 07             	add    $0x7,%eax
 a2a:	c1 e8 03             	shr    $0x3,%eax
 a2d:	83 c0 01             	add    $0x1,%eax
 a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a33:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a3f:	75 23                	jne    a64 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a41:	c7 45 f0 a0 4f 01 00 	movl   $0x14fa0,-0x10(%ebp)
 a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4b:	a3 a8 4f 01 00       	mov    %eax,0x14fa8
 a50:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 a55:	a3 a0 4f 01 00       	mov    %eax,0x14fa0
    base.s.size = 0;
 a5a:	c7 05 a4 4f 01 00 00 	movl   $0x0,0x14fa4
 a61:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6f:	8b 40 04             	mov    0x4(%eax),%eax
 a72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a75:	77 4d                	ja     ac4 <malloc+0xa6>
      if(p->s.size == nunits)
 a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7a:	8b 40 04             	mov    0x4(%eax),%eax
 a7d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a80:	75 0c                	jne    a8e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a85:	8b 10                	mov    (%eax),%edx
 a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8a:	89 10                	mov    %edx,(%eax)
 a8c:	eb 26                	jmp    ab4 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a91:	8b 40 04             	mov    0x4(%eax),%eax
 a94:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a97:	89 c2                	mov    %eax,%edx
 a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa2:	8b 40 04             	mov    0x4(%eax),%eax
 aa5:	c1 e0 03             	shl    $0x3,%eax
 aa8:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab1:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab7:	a3 a8 4f 01 00       	mov    %eax,0x14fa8
      return (void*)(p + 1);
 abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abf:	83 c0 08             	add    $0x8,%eax
 ac2:	eb 3b                	jmp    aff <malloc+0xe1>
    }
    if(p == freep)
 ac4:	a1 a8 4f 01 00       	mov    0x14fa8,%eax
 ac9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 acc:	75 1e                	jne    aec <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ace:	83 ec 0c             	sub    $0xc,%esp
 ad1:	ff 75 ec             	push   -0x14(%ebp)
 ad4:	e8 e5 fe ff ff       	call   9be <morecore>
 ad9:	83 c4 10             	add    $0x10,%esp
 adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 adf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae3:	75 07                	jne    aec <malloc+0xce>
        return 0;
 ae5:	b8 00 00 00 00       	mov    $0x0,%eax
 aea:	eb 13                	jmp    aff <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af5:	8b 00                	mov    (%eax),%eax
 af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 afa:	e9 6d ff ff ff       	jmp    a6c <malloc+0x4e>
  }
}
 aff:	c9                   	leave  
 b00:	c3                   	ret    
