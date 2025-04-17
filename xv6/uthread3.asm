
_uthread3:     file format elf32-i386


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
   6:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 00 0e 00 00 	movl   $0xe00,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 e0 0d 00 00       	mov    0xde0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 e4 0d 00 00       	mov    %eax,0xde4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
  42:	b8 78 4e 01 00       	mov    $0x14e78,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 78 4e 01 00       	mov    $0x14e78,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 e0 0d 00 00       	mov    0xde0,%eax
  5b:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 e0 0d 00 00       	mov    0xde0,%eax
  6b:	a3 e4 0d 00 00       	mov    %eax,0xde4
  }

  if (next_thread == 0) {
  70:	a1 e4 0d 00 00       	mov    0xde4,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 48 0a 00 00       	push   $0xa48
  81:	6a 02                	push   $0x2
  83:	e8 06 06 00 00       	call   68e <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 8a 04 00 00       	call   51a <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 e0 0d 00 00    	mov    0xde0,%edx
  96:	a1 e4 0d 00 00       	mov    0xde4,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 e4 0d 00 00       	mov    0xde4,%eax
  a4:	c7 80 08 20 00 00 01 	movl   $0x1,0x2008(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 e0 0d 00 00       	mov    0xde0,%eax
  b3:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 eb 01 00 00       	call   2ad <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
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
  df:	e8 ce 04 00 00       	call   5b2 <uthread_init>
  e4:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  e7:	c7 05 e0 0d 00 00 00 	movl   $0xe00,0xde0
  ee:	0e 00 00 
  current_thread->state = RUNNING;
  f1:	a1 e0 0d 00 00       	mov    0xde0,%eax
  f6:	c7 80 08 20 00 00 01 	movl   $0x1,0x2008(%eax)
  fd:	00 00 00 
  current_thread->tid=0;
 100:	a1 e0 0d 00 00       	mov    0xde0,%eax
 105:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 10b:	90                   	nop
 10c:	c9                   	leave  
 10d:	c3                   	ret    

0000010e <thread_create>:

int
thread_create(void (*func)())
{
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
 111:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 114:	c7 45 fc 00 0e 00 00 	movl   $0xe00,-0x4(%ebp)
 11b:	eb 14                	jmp    131 <thread_create+0x23>
    if (t->state == FREE) break;
 11d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 120:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 126:	85 c0                	test   %eax,%eax
 128:	74 13                	je     13d <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 12a:	81 45 fc 0c 20 00 00 	addl   $0x200c,-0x4(%ebp)
 131:	b8 78 4e 01 00       	mov    $0x14e78,%eax
 136:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 139:	72 e2                	jb     11d <thread_create+0xf>
 13b:	eb 01                	jmp    13e <thread_create+0x30>
    if (t->state == FREE) break;
 13d:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 13e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 141:	83 c0 08             	add    $0x8,%eax
 144:	05 00 20 00 00       	add    $0x2000,%eax
 149:	89 c2                	mov    %eax,%edx
 14b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 14e:	89 50 04             	mov    %edx,0x4(%eax)
  t->sp -= 4;                              // space for return address
 151:	8b 45 fc             	mov    -0x4(%ebp),%eax
 154:	8b 40 04             	mov    0x4(%eax),%eax
 157:	8d 50 fc             	lea    -0x4(%eax),%edx
 15a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15d:	89 50 04             	mov    %edx,0x4(%eax)
  /* 
    set tid 
  */
  * (int *) (t->sp) = (int)func;           // push return address on stack
 160:	8b 45 fc             	mov    -0x4(%ebp),%eax
 163:	8b 40 04             	mov    0x4(%eax),%eax
 166:	89 c2                	mov    %eax,%edx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 170:	8b 40 04             	mov    0x4(%eax),%eax
 173:	8d 50 e0             	lea    -0x20(%eax),%edx
 176:	8b 45 fc             	mov    -0x4(%ebp),%eax
 179:	89 50 04             	mov    %edx,0x4(%eax)
  t->state = RUNNABLE;
 17c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17f:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
 186:	00 00 00 

  return t->tid;
 189:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18c:	8b 00                	mov    (%eax),%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <thread_suspend>:

static void 
thread_suspend(int tid)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
  /*
    suspend the thread with tid
  */
}
 193:	90                   	nop
 194:	5d                   	pop    %ebp
 195:	c3                   	ret    

00000196 <thread_resume>:

static void 
thread_resume(int tid)
{
 196:	55                   	push   %ebp
 197:	89 e5                	mov    %esp,%ebp
  /*
    resume execution of the thread with tid
  */
}
 199:	90                   	nop
 19a:	5d                   	pop    %ebp
 19b:	c3                   	ret    

0000019c <mythread>:

static void 
mythread(void)
{
 19c:	55                   	push   %ebp
 19d:	89 e5                	mov    %esp,%ebp
 19f:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1a2:	83 ec 08             	sub    $0x8,%esp
 1a5:	68 6e 0a 00 00       	push   $0xa6e
 1aa:	6a 01                	push   $0x1
 1ac:	e8 dd 04 00 00       	call   68e <printf>
 1b1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bb:	eb 1e                	jmp    1db <mythread+0x3f>
    printf(1, "my thread %d\n", current_thread->tid);
 1bd:	a1 e0 0d 00 00       	mov    0xde0,%eax
 1c2:	8b 00                	mov    (%eax),%eax
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	50                   	push   %eax
 1c8:	68 81 0a 00 00       	push   $0xa81
 1cd:	6a 01                	push   $0x1
 1cf:	e8 ba 04 00 00       	call   68e <printf>
 1d4:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1db:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1df:	7e dc                	jle    1bd <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1e1:	83 ec 08             	sub    $0x8,%esp
 1e4:	68 8f 0a 00 00       	push   $0xa8f
 1e9:	6a 01                	push   $0x1
 1eb:	e8 9e 04 00 00       	call   68e <printf>
 1f0:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1f3:	a1 e0 0d 00 00       	mov    0xde0,%eax
 1f8:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 1ff:	00 00 00 
}
 202:	90                   	nop
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <main>:


int 
main(int argc, char *argv[]) 
{
 205:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 209:	83 e4 f0             	and    $0xfffffff0,%esp
 20c:	ff 71 fc             	push   -0x4(%ecx)
 20f:	55                   	push   %ebp
 210:	89 e5                	mov    %esp,%ebp
 212:	51                   	push   %ecx
 213:	83 ec 14             	sub    $0x14,%esp
  int tid1, tid2;
  thread_init();
 216:	e8 b6 fe ff ff       	call   d1 <thread_init>
  tid1=thread_create(mythread);
 21b:	83 ec 0c             	sub    $0xc,%esp
 21e:	68 9c 01 00 00       	push   $0x19c
 223:	e8 e6 fe ff ff       	call   10e <thread_create>
 228:	83 c4 10             	add    $0x10,%esp
 22b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  tid2=thread_create(mythread);
 22e:	83 ec 0c             	sub    $0xc,%esp
 231:	68 9c 01 00 00       	push   $0x19c
 236:	e8 d3 fe ff ff       	call   10e <thread_create>
 23b:	83 c4 10             	add    $0x10,%esp
 23e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sleep(3); /* you can adjust the sleep time */
 241:	83 ec 0c             	sub    $0xc,%esp
 244:	6a 03                	push   $0x3
 246:	e8 57 03 00 00       	call   5a2 <sleep>
 24b:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid1);
 24e:	83 ec 0c             	sub    $0xc,%esp
 251:	ff 75 f4             	push   -0xc(%ebp)
 254:	e8 37 ff ff ff       	call   190 <thread_suspend>
 259:	83 c4 10             	add    $0x10,%esp
  sleep(3);
 25c:	83 ec 0c             	sub    $0xc,%esp
 25f:	6a 03                	push   $0x3
 261:	e8 3c 03 00 00       	call   5a2 <sleep>
 266:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid2);
 269:	83 ec 0c             	sub    $0xc,%esp
 26c:	ff 75 f0             	push   -0x10(%ebp)
 26f:	e8 1c ff ff ff       	call   190 <thread_suspend>
 274:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid1);
 277:	83 ec 0c             	sub    $0xc,%esp
 27a:	ff 75 f4             	push   -0xc(%ebp)
 27d:	e8 14 ff ff ff       	call   196 <thread_resume>
 282:	83 c4 10             	add    $0x10,%esp
  sleep(3);
 285:	83 ec 0c             	sub    $0xc,%esp
 288:	6a 03                	push   $0x3
 28a:	e8 13 03 00 00       	call   5a2 <sleep>
 28f:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid2);
 292:	83 ec 0c             	sub    $0xc,%esp
 295:	ff 75 f0             	push   -0x10(%ebp)
 298:	e8 f9 fe ff ff       	call   196 <thread_resume>
 29d:	83 c4 10             	add    $0x10,%esp
  return 0;
 2a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2a5:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2a8:	c9                   	leave  
 2a9:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2ac:	c3                   	ret    

000002ad <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 2ad:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 2ae:	a1 e0 0d 00 00       	mov    0xde0,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 2b3:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 2b5:	a1 e4 0d 00 00       	mov    0xde4,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 2ba:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 2bc:	a3 e0 0d 00 00       	mov    %eax,0xde0
    popal
 2c1:	61                   	popa   
    
    # return to next thread's stack context
 2c2:	c3                   	ret    

000002c3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2c3:	55                   	push   %ebp
 2c4:	89 e5                	mov    %esp,%ebp
 2c6:	57                   	push   %edi
 2c7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2cb:	8b 55 10             	mov    0x10(%ebp),%edx
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	89 cb                	mov    %ecx,%ebx
 2d3:	89 df                	mov    %ebx,%edi
 2d5:	89 d1                	mov    %edx,%ecx
 2d7:	fc                   	cld    
 2d8:	f3 aa                	rep stos %al,%es:(%edi)
 2da:	89 ca                	mov    %ecx,%edx
 2dc:	89 fb                	mov    %edi,%ebx
 2de:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2e1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2e4:	90                   	nop
 2e5:	5b                   	pop    %ebx
 2e6:	5f                   	pop    %edi
 2e7:	5d                   	pop    %ebp
 2e8:	c3                   	ret    

000002e9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2f5:	90                   	nop
 2f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 2f9:	8d 42 01             	lea    0x1(%edx),%eax
 2fc:	89 45 0c             	mov    %eax,0xc(%ebp)
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	8d 48 01             	lea    0x1(%eax),%ecx
 305:	89 4d 08             	mov    %ecx,0x8(%ebp)
 308:	0f b6 12             	movzbl (%edx),%edx
 30b:	88 10                	mov    %dl,(%eax)
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	84 c0                	test   %al,%al
 312:	75 e2                	jne    2f6 <strcpy+0xd>
    ;
  return os;
 314:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 317:	c9                   	leave  
 318:	c3                   	ret    

00000319 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 31c:	eb 08                	jmp    326 <strcmp+0xd>
    p++, q++;
 31e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 322:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	0f b6 00             	movzbl (%eax),%eax
 32c:	84 c0                	test   %al,%al
 32e:	74 10                	je     340 <strcmp+0x27>
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	0f b6 10             	movzbl (%eax),%edx
 336:	8b 45 0c             	mov    0xc(%ebp),%eax
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	38 c2                	cmp    %al,%dl
 33e:	74 de                	je     31e <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	0f b6 d0             	movzbl %al,%edx
 349:	8b 45 0c             	mov    0xc(%ebp),%eax
 34c:	0f b6 00             	movzbl (%eax),%eax
 34f:	0f b6 c8             	movzbl %al,%ecx
 352:	89 d0                	mov    %edx,%eax
 354:	29 c8                	sub    %ecx,%eax
}
 356:	5d                   	pop    %ebp
 357:	c3                   	ret    

00000358 <strlen>:

uint
strlen(char *s)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 35e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 365:	eb 04                	jmp    36b <strlen+0x13>
 367:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 36b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	01 d0                	add    %edx,%eax
 373:	0f b6 00             	movzbl (%eax),%eax
 376:	84 c0                	test   %al,%al
 378:	75 ed                	jne    367 <strlen+0xf>
    ;
  return n;
 37a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <memset>:

void*
memset(void *dst, int c, uint n)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 382:	8b 45 10             	mov    0x10(%ebp),%eax
 385:	50                   	push   %eax
 386:	ff 75 0c             	push   0xc(%ebp)
 389:	ff 75 08             	push   0x8(%ebp)
 38c:	e8 32 ff ff ff       	call   2c3 <stosb>
 391:	83 c4 0c             	add    $0xc,%esp
  return dst;
 394:	8b 45 08             	mov    0x8(%ebp),%eax
}
 397:	c9                   	leave  
 398:	c3                   	ret    

00000399 <strchr>:

char*
strchr(const char *s, char c)
{
 399:	55                   	push   %ebp
 39a:	89 e5                	mov    %esp,%ebp
 39c:	83 ec 04             	sub    $0x4,%esp
 39f:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a2:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3a5:	eb 14                	jmp    3bb <strchr+0x22>
    if(*s == c)
 3a7:	8b 45 08             	mov    0x8(%ebp),%eax
 3aa:	0f b6 00             	movzbl (%eax),%eax
 3ad:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3b0:	75 05                	jne    3b7 <strchr+0x1e>
      return (char*)s;
 3b2:	8b 45 08             	mov    0x8(%ebp),%eax
 3b5:	eb 13                	jmp    3ca <strchr+0x31>
  for(; *s; s++)
 3b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	0f b6 00             	movzbl (%eax),%eax
 3c1:	84 c0                	test   %al,%al
 3c3:	75 e2                	jne    3a7 <strchr+0xe>
  return 0;
 3c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3ca:	c9                   	leave  
 3cb:	c3                   	ret    

000003cc <gets>:

char*
gets(char *buf, int max)
{
 3cc:	55                   	push   %ebp
 3cd:	89 e5                	mov    %esp,%ebp
 3cf:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3d9:	eb 42                	jmp    41d <gets+0x51>
    cc = read(0, &c, 1);
 3db:	83 ec 04             	sub    $0x4,%esp
 3de:	6a 01                	push   $0x1
 3e0:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3e3:	50                   	push   %eax
 3e4:	6a 00                	push   $0x0
 3e6:	e8 47 01 00 00       	call   532 <read>
 3eb:	83 c4 10             	add    $0x10,%esp
 3ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f5:	7e 33                	jle    42a <gets+0x5e>
      break;
    buf[i++] = c;
 3f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fa:	8d 50 01             	lea    0x1(%eax),%edx
 3fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 400:	89 c2                	mov    %eax,%edx
 402:	8b 45 08             	mov    0x8(%ebp),%eax
 405:	01 c2                	add    %eax,%edx
 407:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 40b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 40d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 411:	3c 0a                	cmp    $0xa,%al
 413:	74 16                	je     42b <gets+0x5f>
 415:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 419:	3c 0d                	cmp    $0xd,%al
 41b:	74 0e                	je     42b <gets+0x5f>
  for(i=0; i+1 < max; ){
 41d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 420:	83 c0 01             	add    $0x1,%eax
 423:	39 45 0c             	cmp    %eax,0xc(%ebp)
 426:	7f b3                	jg     3db <gets+0xf>
 428:	eb 01                	jmp    42b <gets+0x5f>
      break;
 42a:	90                   	nop
      break;
  }
  buf[i] = '\0';
 42b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
 431:	01 d0                	add    %edx,%eax
 433:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 436:	8b 45 08             	mov    0x8(%ebp),%eax
}
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <stat>:

int
stat(char *n, struct stat *st)
{
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
 43e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 441:	83 ec 08             	sub    $0x8,%esp
 444:	6a 00                	push   $0x0
 446:	ff 75 08             	push   0x8(%ebp)
 449:	e8 14 01 00 00       	call   562 <open>
 44e:	83 c4 10             	add    $0x10,%esp
 451:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 454:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 458:	79 07                	jns    461 <stat+0x26>
    return -1;
 45a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 45f:	eb 25                	jmp    486 <stat+0x4b>
  r = fstat(fd, st);
 461:	83 ec 08             	sub    $0x8,%esp
 464:	ff 75 0c             	push   0xc(%ebp)
 467:	ff 75 f4             	push   -0xc(%ebp)
 46a:	e8 0b 01 00 00       	call   57a <fstat>
 46f:	83 c4 10             	add    $0x10,%esp
 472:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 475:	83 ec 0c             	sub    $0xc,%esp
 478:	ff 75 f4             	push   -0xc(%ebp)
 47b:	e8 c2 00 00 00       	call   542 <close>
 480:	83 c4 10             	add    $0x10,%esp
  return r;
 483:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 486:	c9                   	leave  
 487:	c3                   	ret    

00000488 <atoi>:

int
atoi(const char *s)
{
 488:	55                   	push   %ebp
 489:	89 e5                	mov    %esp,%ebp
 48b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 48e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 495:	eb 25                	jmp    4bc <atoi+0x34>
    n = n*10 + *s++ - '0';
 497:	8b 55 fc             	mov    -0x4(%ebp),%edx
 49a:	89 d0                	mov    %edx,%eax
 49c:	c1 e0 02             	shl    $0x2,%eax
 49f:	01 d0                	add    %edx,%eax
 4a1:	01 c0                	add    %eax,%eax
 4a3:	89 c1                	mov    %eax,%ecx
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	8d 50 01             	lea    0x1(%eax),%edx
 4ab:	89 55 08             	mov    %edx,0x8(%ebp)
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	0f be c0             	movsbl %al,%eax
 4b4:	01 c8                	add    %ecx,%eax
 4b6:	83 e8 30             	sub    $0x30,%eax
 4b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	0f b6 00             	movzbl (%eax),%eax
 4c2:	3c 2f                	cmp    $0x2f,%al
 4c4:	7e 0a                	jle    4d0 <atoi+0x48>
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	0f b6 00             	movzbl (%eax),%eax
 4cc:	3c 39                	cmp    $0x39,%al
 4ce:	7e c7                	jle    497 <atoi+0xf>
  return n;
 4d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4d3:	c9                   	leave  
 4d4:	c3                   	ret    

000004d5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4d5:	55                   	push   %ebp
 4d6:	89 e5                	mov    %esp,%ebp
 4d8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4e7:	eb 17                	jmp    500 <memmove+0x2b>
    *dst++ = *src++;
 4e9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ec:	8d 42 01             	lea    0x1(%edx),%eax
 4ef:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4f5:	8d 48 01             	lea    0x1(%eax),%ecx
 4f8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4fb:	0f b6 12             	movzbl (%edx),%edx
 4fe:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 500:	8b 45 10             	mov    0x10(%ebp),%eax
 503:	8d 50 ff             	lea    -0x1(%eax),%edx
 506:	89 55 10             	mov    %edx,0x10(%ebp)
 509:	85 c0                	test   %eax,%eax
 50b:	7f dc                	jg     4e9 <memmove+0x14>
  return vdst;
 50d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 510:	c9                   	leave  
 511:	c3                   	ret    

00000512 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 512:	b8 01 00 00 00       	mov    $0x1,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <exit>:
SYSCALL(exit)
 51a:	b8 02 00 00 00       	mov    $0x2,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret    

00000522 <wait>:
SYSCALL(wait)
 522:	b8 03 00 00 00       	mov    $0x3,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret    

0000052a <pipe>:
SYSCALL(pipe)
 52a:	b8 04 00 00 00       	mov    $0x4,%eax
 52f:	cd 40                	int    $0x40
 531:	c3                   	ret    

00000532 <read>:
SYSCALL(read)
 532:	b8 05 00 00 00       	mov    $0x5,%eax
 537:	cd 40                	int    $0x40
 539:	c3                   	ret    

0000053a <write>:
SYSCALL(write)
 53a:	b8 10 00 00 00       	mov    $0x10,%eax
 53f:	cd 40                	int    $0x40
 541:	c3                   	ret    

00000542 <close>:
SYSCALL(close)
 542:	b8 15 00 00 00       	mov    $0x15,%eax
 547:	cd 40                	int    $0x40
 549:	c3                   	ret    

0000054a <kill>:
SYSCALL(kill)
 54a:	b8 06 00 00 00       	mov    $0x6,%eax
 54f:	cd 40                	int    $0x40
 551:	c3                   	ret    

00000552 <dup>:
SYSCALL(dup)
 552:	b8 0a 00 00 00       	mov    $0xa,%eax
 557:	cd 40                	int    $0x40
 559:	c3                   	ret    

0000055a <exec>:
SYSCALL(exec)
 55a:	b8 07 00 00 00       	mov    $0x7,%eax
 55f:	cd 40                	int    $0x40
 561:	c3                   	ret    

00000562 <open>:
SYSCALL(open)
 562:	b8 0f 00 00 00       	mov    $0xf,%eax
 567:	cd 40                	int    $0x40
 569:	c3                   	ret    

0000056a <mknod>:
SYSCALL(mknod)
 56a:	b8 11 00 00 00       	mov    $0x11,%eax
 56f:	cd 40                	int    $0x40
 571:	c3                   	ret    

00000572 <unlink>:
SYSCALL(unlink)
 572:	b8 12 00 00 00       	mov    $0x12,%eax
 577:	cd 40                	int    $0x40
 579:	c3                   	ret    

0000057a <fstat>:
SYSCALL(fstat)
 57a:	b8 08 00 00 00       	mov    $0x8,%eax
 57f:	cd 40                	int    $0x40
 581:	c3                   	ret    

00000582 <link>:
SYSCALL(link)
 582:	b8 13 00 00 00       	mov    $0x13,%eax
 587:	cd 40                	int    $0x40
 589:	c3                   	ret    

0000058a <mkdir>:
SYSCALL(mkdir)
 58a:	b8 14 00 00 00       	mov    $0x14,%eax
 58f:	cd 40                	int    $0x40
 591:	c3                   	ret    

00000592 <chdir>:
SYSCALL(chdir)
 592:	b8 09 00 00 00       	mov    $0x9,%eax
 597:	cd 40                	int    $0x40
 599:	c3                   	ret    

0000059a <sbrk>:
SYSCALL(sbrk)
 59a:	b8 0c 00 00 00       	mov    $0xc,%eax
 59f:	cd 40                	int    $0x40
 5a1:	c3                   	ret    

000005a2 <sleep>:
SYSCALL(sleep)
 5a2:	b8 0d 00 00 00       	mov    $0xd,%eax
 5a7:	cd 40                	int    $0x40
 5a9:	c3                   	ret    

000005aa <getpid>:
SYSCALL(getpid)
 5aa:	b8 0b 00 00 00       	mov    $0xb,%eax
 5af:	cd 40                	int    $0x40
 5b1:	c3                   	ret    

000005b2 <uthread_init>:
SYSCALL(uthread_init)
 5b2:	b8 18 00 00 00       	mov    $0x18,%eax
 5b7:	cd 40                	int    $0x40
 5b9:	c3                   	ret    

000005ba <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ba:	55                   	push   %ebp
 5bb:	89 e5                	mov    %esp,%ebp
 5bd:	83 ec 18             	sub    $0x18,%esp
 5c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c6:	83 ec 04             	sub    $0x4,%esp
 5c9:	6a 01                	push   $0x1
 5cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5ce:	50                   	push   %eax
 5cf:	ff 75 08             	push   0x8(%ebp)
 5d2:	e8 63 ff ff ff       	call   53a <write>
 5d7:	83 c4 10             	add    $0x10,%esp
}
 5da:	90                   	nop
 5db:	c9                   	leave  
 5dc:	c3                   	ret    

000005dd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5dd:	55                   	push   %ebp
 5de:	89 e5                	mov    %esp,%ebp
 5e0:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5ea:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ee:	74 17                	je     607 <printint+0x2a>
 5f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f4:	79 11                	jns    607 <printint+0x2a>
    neg = 1;
 5f6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 600:	f7 d8                	neg    %eax
 602:	89 45 ec             	mov    %eax,-0x14(%ebp)
 605:	eb 06                	jmp    60d <printint+0x30>
  } else {
    x = xx;
 607:	8b 45 0c             	mov    0xc(%ebp),%eax
 60a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 60d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 614:	8b 4d 10             	mov    0x10(%ebp),%ecx
 617:	8b 45 ec             	mov    -0x14(%ebp),%eax
 61a:	ba 00 00 00 00       	mov    $0x0,%edx
 61f:	f7 f1                	div    %ecx
 621:	89 d1                	mov    %edx,%ecx
 623:	8b 45 f4             	mov    -0xc(%ebp),%eax
 626:	8d 50 01             	lea    0x1(%eax),%edx
 629:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62c:	0f b6 91 b4 0d 00 00 	movzbl 0xdb4(%ecx),%edx
 633:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 637:	8b 4d 10             	mov    0x10(%ebp),%ecx
 63a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63d:	ba 00 00 00 00       	mov    $0x0,%edx
 642:	f7 f1                	div    %ecx
 644:	89 45 ec             	mov    %eax,-0x14(%ebp)
 647:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64b:	75 c7                	jne    614 <printint+0x37>
  if(neg)
 64d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 651:	74 2d                	je     680 <printint+0xa3>
    buf[i++] = '-';
 653:	8b 45 f4             	mov    -0xc(%ebp),%eax
 656:	8d 50 01             	lea    0x1(%eax),%edx
 659:	89 55 f4             	mov    %edx,-0xc(%ebp)
 65c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 661:	eb 1d                	jmp    680 <printint+0xa3>
    putc(fd, buf[i]);
 663:	8d 55 dc             	lea    -0x24(%ebp),%edx
 666:	8b 45 f4             	mov    -0xc(%ebp),%eax
 669:	01 d0                	add    %edx,%eax
 66b:	0f b6 00             	movzbl (%eax),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	83 ec 08             	sub    $0x8,%esp
 674:	50                   	push   %eax
 675:	ff 75 08             	push   0x8(%ebp)
 678:	e8 3d ff ff ff       	call   5ba <putc>
 67d:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 680:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 688:	79 d9                	jns    663 <printint+0x86>
}
 68a:	90                   	nop
 68b:	90                   	nop
 68c:	c9                   	leave  
 68d:	c3                   	ret    

0000068e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 68e:	55                   	push   %ebp
 68f:	89 e5                	mov    %esp,%ebp
 691:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 694:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 69b:	8d 45 0c             	lea    0xc(%ebp),%eax
 69e:	83 c0 04             	add    $0x4,%eax
 6a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ab:	e9 59 01 00 00       	jmp    809 <printf+0x17b>
    c = fmt[i] & 0xff;
 6b0:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b6:	01 d0                	add    %edx,%eax
 6b8:	0f b6 00             	movzbl (%eax),%eax
 6bb:	0f be c0             	movsbl %al,%eax
 6be:	25 ff 00 00 00       	and    $0xff,%eax
 6c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ca:	75 2c                	jne    6f8 <printf+0x6a>
      if(c == '%'){
 6cc:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d0:	75 0c                	jne    6de <printf+0x50>
        state = '%';
 6d2:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6d9:	e9 27 01 00 00       	jmp    805 <printf+0x177>
      } else {
        putc(fd, c);
 6de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e1:	0f be c0             	movsbl %al,%eax
 6e4:	83 ec 08             	sub    $0x8,%esp
 6e7:	50                   	push   %eax
 6e8:	ff 75 08             	push   0x8(%ebp)
 6eb:	e8 ca fe ff ff       	call   5ba <putc>
 6f0:	83 c4 10             	add    $0x10,%esp
 6f3:	e9 0d 01 00 00       	jmp    805 <printf+0x177>
      }
    } else if(state == '%'){
 6f8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6fc:	0f 85 03 01 00 00    	jne    805 <printf+0x177>
      if(c == 'd'){
 702:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 706:	75 1e                	jne    726 <printf+0x98>
        printint(fd, *ap, 10, 1);
 708:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	6a 01                	push   $0x1
 70f:	6a 0a                	push   $0xa
 711:	50                   	push   %eax
 712:	ff 75 08             	push   0x8(%ebp)
 715:	e8 c3 fe ff ff       	call   5dd <printint>
 71a:	83 c4 10             	add    $0x10,%esp
        ap++;
 71d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 721:	e9 d8 00 00 00       	jmp    7fe <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 726:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 72a:	74 06                	je     732 <printf+0xa4>
 72c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 730:	75 1e                	jne    750 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 732:	8b 45 e8             	mov    -0x18(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	6a 00                	push   $0x0
 739:	6a 10                	push   $0x10
 73b:	50                   	push   %eax
 73c:	ff 75 08             	push   0x8(%ebp)
 73f:	e8 99 fe ff ff       	call   5dd <printint>
 744:	83 c4 10             	add    $0x10,%esp
        ap++;
 747:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74b:	e9 ae 00 00 00       	jmp    7fe <printf+0x170>
      } else if(c == 's'){
 750:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 754:	75 43                	jne    799 <printf+0x10b>
        s = (char*)*ap;
 756:	8b 45 e8             	mov    -0x18(%ebp),%eax
 759:	8b 00                	mov    (%eax),%eax
 75b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 75e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 762:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 766:	75 25                	jne    78d <printf+0xff>
          s = "(null)";
 768:	c7 45 f4 a0 0a 00 00 	movl   $0xaa0,-0xc(%ebp)
        while(*s != 0){
 76f:	eb 1c                	jmp    78d <printf+0xff>
          putc(fd, *s);
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	0f b6 00             	movzbl (%eax),%eax
 777:	0f be c0             	movsbl %al,%eax
 77a:	83 ec 08             	sub    $0x8,%esp
 77d:	50                   	push   %eax
 77e:	ff 75 08             	push   0x8(%ebp)
 781:	e8 34 fe ff ff       	call   5ba <putc>
 786:	83 c4 10             	add    $0x10,%esp
          s++;
 789:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	0f b6 00             	movzbl (%eax),%eax
 793:	84 c0                	test   %al,%al
 795:	75 da                	jne    771 <printf+0xe3>
 797:	eb 65                	jmp    7fe <printf+0x170>
        }
      } else if(c == 'c'){
 799:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 79d:	75 1d                	jne    7bc <printf+0x12e>
        putc(fd, *ap);
 79f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a2:	8b 00                	mov    (%eax),%eax
 7a4:	0f be c0             	movsbl %al,%eax
 7a7:	83 ec 08             	sub    $0x8,%esp
 7aa:	50                   	push   %eax
 7ab:	ff 75 08             	push   0x8(%ebp)
 7ae:	e8 07 fe ff ff       	call   5ba <putc>
 7b3:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ba:	eb 42                	jmp    7fe <printf+0x170>
      } else if(c == '%'){
 7bc:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7c0:	75 17                	jne    7d9 <printf+0x14b>
        putc(fd, c);
 7c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c5:	0f be c0             	movsbl %al,%eax
 7c8:	83 ec 08             	sub    $0x8,%esp
 7cb:	50                   	push   %eax
 7cc:	ff 75 08             	push   0x8(%ebp)
 7cf:	e8 e6 fd ff ff       	call   5ba <putc>
 7d4:	83 c4 10             	add    $0x10,%esp
 7d7:	eb 25                	jmp    7fe <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d9:	83 ec 08             	sub    $0x8,%esp
 7dc:	6a 25                	push   $0x25
 7de:	ff 75 08             	push   0x8(%ebp)
 7e1:	e8 d4 fd ff ff       	call   5ba <putc>
 7e6:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ec:	0f be c0             	movsbl %al,%eax
 7ef:	83 ec 08             	sub    $0x8,%esp
 7f2:	50                   	push   %eax
 7f3:	ff 75 08             	push   0x8(%ebp)
 7f6:	e8 bf fd ff ff       	call   5ba <putc>
 7fb:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7fe:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 805:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 809:	8b 55 0c             	mov    0xc(%ebp),%edx
 80c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80f:	01 d0                	add    %edx,%eax
 811:	0f b6 00             	movzbl (%eax),%eax
 814:	84 c0                	test   %al,%al
 816:	0f 85 94 fe ff ff    	jne    6b0 <printf+0x22>
    }
  }
}
 81c:	90                   	nop
 81d:	90                   	nop
 81e:	c9                   	leave  
 81f:	c3                   	ret    

00000820 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 820:	55                   	push   %ebp
 821:	89 e5                	mov    %esp,%ebp
 823:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 826:	8b 45 08             	mov    0x8(%ebp),%eax
 829:	83 e8 08             	sub    $0x8,%eax
 82c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82f:	a1 80 4e 01 00       	mov    0x14e80,%eax
 834:	89 45 fc             	mov    %eax,-0x4(%ebp)
 837:	eb 24                	jmp    85d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 841:	72 12                	jb     855 <free+0x35>
 843:	8b 45 f8             	mov    -0x8(%ebp),%eax
 846:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 849:	77 24                	ja     86f <free+0x4f>
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	8b 00                	mov    (%eax),%eax
 850:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 853:	72 1a                	jb     86f <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 855:	8b 45 fc             	mov    -0x4(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 860:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 863:	76 d4                	jbe    839 <free+0x19>
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 86d:	73 ca                	jae    839 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 87c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87f:	01 c2                	add    %eax,%edx
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	39 c2                	cmp    %eax,%edx
 888:	75 24                	jne    8ae <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 88a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88d:	8b 50 04             	mov    0x4(%eax),%edx
 890:	8b 45 fc             	mov    -0x4(%ebp),%eax
 893:	8b 00                	mov    (%eax),%eax
 895:	8b 40 04             	mov    0x4(%eax),%eax
 898:	01 c2                	add    %eax,%edx
 89a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 00                	mov    (%eax),%eax
 8a5:	8b 10                	mov    (%eax),%edx
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	89 10                	mov    %edx,(%eax)
 8ac:	eb 0a                	jmp    8b8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b1:	8b 10                	mov    (%eax),%edx
 8b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 40 04             	mov    0x4(%eax),%eax
 8be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	01 d0                	add    %edx,%eax
 8ca:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8cd:	75 20                	jne    8ef <free+0xcf>
    p->s.size += bp->s.size;
 8cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d2:	8b 50 04             	mov    0x4(%eax),%edx
 8d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d8:	8b 40 04             	mov    0x4(%eax),%eax
 8db:	01 c2                	add    %eax,%edx
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e6:	8b 10                	mov    (%eax),%edx
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8eb:	89 10                	mov    %edx,(%eax)
 8ed:	eb 08                	jmp    8f7 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f5:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	a3 80 4e 01 00       	mov    %eax,0x14e80
}
 8ff:	90                   	nop
 900:	c9                   	leave  
 901:	c3                   	ret    

00000902 <morecore>:

static Header*
morecore(uint nu)
{
 902:	55                   	push   %ebp
 903:	89 e5                	mov    %esp,%ebp
 905:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 908:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 90f:	77 07                	ja     918 <morecore+0x16>
    nu = 4096;
 911:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 918:	8b 45 08             	mov    0x8(%ebp),%eax
 91b:	c1 e0 03             	shl    $0x3,%eax
 91e:	83 ec 0c             	sub    $0xc,%esp
 921:	50                   	push   %eax
 922:	e8 73 fc ff ff       	call   59a <sbrk>
 927:	83 c4 10             	add    $0x10,%esp
 92a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 92d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 931:	75 07                	jne    93a <morecore+0x38>
    return 0;
 933:	b8 00 00 00 00       	mov    $0x0,%eax
 938:	eb 26                	jmp    960 <morecore+0x5e>
  hp = (Header*)p;
 93a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 940:	8b 45 f0             	mov    -0x10(%ebp),%eax
 943:	8b 55 08             	mov    0x8(%ebp),%edx
 946:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 949:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94c:	83 c0 08             	add    $0x8,%eax
 94f:	83 ec 0c             	sub    $0xc,%esp
 952:	50                   	push   %eax
 953:	e8 c8 fe ff ff       	call   820 <free>
 958:	83 c4 10             	add    $0x10,%esp
  return freep;
 95b:	a1 80 4e 01 00       	mov    0x14e80,%eax
}
 960:	c9                   	leave  
 961:	c3                   	ret    

00000962 <malloc>:

void*
malloc(uint nbytes)
{
 962:	55                   	push   %ebp
 963:	89 e5                	mov    %esp,%ebp
 965:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 968:	8b 45 08             	mov    0x8(%ebp),%eax
 96b:	83 c0 07             	add    $0x7,%eax
 96e:	c1 e8 03             	shr    $0x3,%eax
 971:	83 c0 01             	add    $0x1,%eax
 974:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 977:	a1 80 4e 01 00       	mov    0x14e80,%eax
 97c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 983:	75 23                	jne    9a8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 985:	c7 45 f0 78 4e 01 00 	movl   $0x14e78,-0x10(%ebp)
 98c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98f:	a3 80 4e 01 00       	mov    %eax,0x14e80
 994:	a1 80 4e 01 00       	mov    0x14e80,%eax
 999:	a3 78 4e 01 00       	mov    %eax,0x14e78
    base.s.size = 0;
 99e:	c7 05 7c 4e 01 00 00 	movl   $0x0,0x14e7c
 9a5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ab:	8b 00                	mov    (%eax),%eax
 9ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b3:	8b 40 04             	mov    0x4(%eax),%eax
 9b6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b9:	77 4d                	ja     a08 <malloc+0xa6>
      if(p->s.size == nunits)
 9bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9be:	8b 40 04             	mov    0x4(%eax),%eax
 9c1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9c4:	75 0c                	jne    9d2 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	8b 10                	mov    (%eax),%edx
 9cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ce:	89 10                	mov    %edx,(%eax)
 9d0:	eb 26                	jmp    9f8 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d5:	8b 40 04             	mov    0x4(%eax),%eax
 9d8:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9db:	89 c2                	mov    %eax,%edx
 9dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e0:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e6:	8b 40 04             	mov    0x4(%eax),%eax
 9e9:	c1 e0 03             	shl    $0x3,%eax
 9ec:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9f5:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fb:	a3 80 4e 01 00       	mov    %eax,0x14e80
      return (void*)(p + 1);
 a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a03:	83 c0 08             	add    $0x8,%eax
 a06:	eb 3b                	jmp    a43 <malloc+0xe1>
    }
    if(p == freep)
 a08:	a1 80 4e 01 00       	mov    0x14e80,%eax
 a0d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a10:	75 1e                	jne    a30 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a12:	83 ec 0c             	sub    $0xc,%esp
 a15:	ff 75 ec             	push   -0x14(%ebp)
 a18:	e8 e5 fe ff ff       	call   902 <morecore>
 a1d:	83 c4 10             	add    $0x10,%esp
 a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a27:	75 07                	jne    a30 <malloc+0xce>
        return 0;
 a29:	b8 00 00 00 00       	mov    $0x0,%eax
 a2e:	eb 13                	jmp    a43 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a39:	8b 00                	mov    (%eax),%eax
 a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a3e:	e9 6d ff ff ff       	jmp    9b0 <malloc+0x4e>
  }
}
 a43:	c9                   	leave  
 a44:	c3                   	ret    
