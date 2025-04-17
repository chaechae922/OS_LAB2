
_uthread2:     file format elf32-i386


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
   6:	c7 05 04 0e 00 00 00 	movl   $0x0,0xe04
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 20 0e 00 00 	movl   $0xe20,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 00 0e 00 00       	mov    0xe00,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 04 0e 00 00       	mov    %eax,0xe04
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 c0 4e 01 00       	mov    $0x14ec0,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 c0 4e 01 00       	mov    $0x14ec0,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 00 0e 00 00       	mov    0xe00,%eax
  5b:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 00 0e 00 00       	mov    0xe00,%eax
  6b:	a3 04 0e 00 00       	mov    %eax,0xe04
  }

  if (next_thread == 0) {
  70:	a1 04 0e 00 00       	mov    0xe04,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 3c 0a 00 00       	push   $0xa3c
  81:	6a 02                	push   $0x2
  83:	e8 fa 05 00 00       	call   682 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 7e 04 00 00       	call   50e <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 00 0e 00 00    	mov    0xe00,%edx
  96:	a1 04 0e 00 00       	mov    0xe04,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 04 0e 00 00       	mov    0xe04,%eax
  a4:	c7 80 0c 20 00 00 01 	movl   $0x1,0x200c(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 00 0e 00 00       	mov    0xe00,%eax
  b3:	c7 80 0c 20 00 00 02 	movl   $0x2,0x200c(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 df 01 00 00       	call   2a1 <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 04 0e 00 00 00 	movl   $0x0,0xe04
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
  df:	e8 c2 04 00 00       	call   5a6 <uthread_init>
  e4:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  e7:	c7 05 00 0e 00 00 20 	movl   $0xe20,0xe00
  ee:	0e 00 00 
  current_thread->state = RUNNING;
  f1:	a1 00 0e 00 00       	mov    0xe00,%eax
  f6:	c7 80 0c 20 00 00 01 	movl   $0x1,0x200c(%eax)
  fd:	00 00 00 
  current_thread->tid=0;
 100:	a1 00 0e 00 00       	mov    0xe00,%eax
 105:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  current_thread->ptid=0;
 10b:	a1 00 0e 00 00       	mov    0xe00,%eax
 110:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
}
 117:	90                   	nop
 118:	c9                   	leave  
 119:	c3                   	ret    

0000011a <thread_create>:

void 
thread_create(void (*func)())
{
 11a:	55                   	push   %ebp
 11b:	89 e5                	mov    %esp,%ebp
 11d:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 120:	c7 45 fc 20 0e 00 00 	movl   $0xe20,-0x4(%ebp)
 127:	eb 14                	jmp    13d <thread_create+0x23>
    if (t->state == FREE) break;
 129:	8b 45 fc             	mov    -0x4(%ebp),%eax
 12c:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 132:	85 c0                	test   %eax,%eax
 134:	74 13                	je     149 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 136:	81 45 fc 10 20 00 00 	addl   $0x2010,-0x4(%ebp)
 13d:	b8 c0 4e 01 00       	mov    $0x14ec0,%eax
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
}
 195:	90                   	nop
 196:	c9                   	leave  
 197:	c3                   	ret    

00000198 <thread_join_all>:

static void 
thread_join_all(void)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
  /*
    it returns when all child threads have exited.
  */
}
 19b:	90                   	nop
 19c:	5d                   	pop    %ebp
 19d:	c3                   	ret    

0000019e <child_thread>:

static void 
child_thread(void)
{
 19e:	55                   	push   %ebp
 19f:	89 e5                	mov    %esp,%ebp
 1a1:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 1a4:	83 ec 08             	sub    $0x8,%esp
 1a7:	68 62 0a 00 00       	push   $0xa62
 1ac:	6a 01                	push   $0x1
 1ae:	e8 cf 04 00 00       	call   682 <printf>
 1b3:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bd:	eb 1c                	jmp    1db <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int) current_thread);
 1bf:	a1 00 0e 00 00       	mov    0xe00,%eax
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	50                   	push   %eax
 1c8:	68 78 0a 00 00       	push   $0xa78
 1cd:	6a 01                	push   $0x1
 1cf:	e8 ae 04 00 00       	call   682 <printf>
 1d4:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1db:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1df:	7e de                	jle    1bf <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 1e1:	83 ec 08             	sub    $0x8,%esp
 1e4:	68 8b 0a 00 00       	push   $0xa8b
 1e9:	6a 01                	push   $0x1
 1eb:	e8 92 04 00 00       	call   682 <printf>
 1f0:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1f3:	a1 00 0e 00 00       	mov    0xe00,%eax
 1f8:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 1ff:	00 00 00 
}
 202:	90                   	nop
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <mythread>:

static void 
mythread(void)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 20b:	83 ec 08             	sub    $0x8,%esp
 20e:	68 9f 0a 00 00       	push   $0xa9f
 213:	6a 01                	push   $0x1
 215:	e8 68 04 00 00       	call   682 <printf>
 21a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 21d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 224:	eb 14                	jmp    23a <mythread+0x35>
    thread_create(child_thread);
 226:	83 ec 0c             	sub    $0xc,%esp
 229:	68 9e 01 00 00       	push   $0x19e
 22e:	e8 e7 fe ff ff       	call   11a <thread_create>
 233:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 236:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 23a:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 23e:	7e e6                	jle    226 <mythread+0x21>
  }
  thread_join_all();
 240:	e8 53 ff ff ff       	call   198 <thread_join_all>
  printf(1, "my thread: exit\n");
 245:	83 ec 08             	sub    $0x8,%esp
 248:	68 b2 0a 00 00       	push   $0xab2
 24d:	6a 01                	push   $0x1
 24f:	e8 2e 04 00 00       	call   682 <printf>
 254:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 257:	a1 00 0e 00 00       	mov    0xe00,%eax
 25c:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 263:	00 00 00 
}
 266:	90                   	nop
 267:	c9                   	leave  
 268:	c3                   	ret    

00000269 <main>:


int 
main(int argc, char *argv[]) 
{
 269:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 26d:	83 e4 f0             	and    $0xfffffff0,%esp
 270:	ff 71 fc             	push   -0x4(%ecx)
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	51                   	push   %ecx
 277:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 27a:	e8 52 fe ff ff       	call   d1 <thread_init>
  thread_create(mythread);
 27f:	83 ec 0c             	sub    $0xc,%esp
 282:	68 05 02 00 00       	push   $0x205
 287:	e8 8e fe ff ff       	call   11a <thread_create>
 28c:	83 c4 10             	add    $0x10,%esp
  thread_join_all();
 28f:	e8 04 ff ff ff       	call   198 <thread_join_all>
  return 0;
 294:	b8 00 00 00 00       	mov    $0x0,%eax
}
 299:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 29c:	c9                   	leave  
 29d:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2a0:	c3                   	ret    

000002a1 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 2a1:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 2a2:	a1 00 0e 00 00       	mov    0xe00,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 2a7:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 2a9:	a1 04 0e 00 00       	mov    0xe04,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 2ae:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 2b0:	a3 00 0e 00 00       	mov    %eax,0xe00
    popal
 2b5:	61                   	popa   
    
    # return to next thread's stack context
 2b6:	c3                   	ret    

000002b7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2b7:	55                   	push   %ebp
 2b8:	89 e5                	mov    %esp,%ebp
 2ba:	57                   	push   %edi
 2bb:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2bf:	8b 55 10             	mov    0x10(%ebp),%edx
 2c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c5:	89 cb                	mov    %ecx,%ebx
 2c7:	89 df                	mov    %ebx,%edi
 2c9:	89 d1                	mov    %edx,%ecx
 2cb:	fc                   	cld    
 2cc:	f3 aa                	rep stos %al,%es:(%edi)
 2ce:	89 ca                	mov    %ecx,%edx
 2d0:	89 fb                	mov    %edi,%ebx
 2d2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2d5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2d8:	90                   	nop
 2d9:	5b                   	pop    %ebx
 2da:	5f                   	pop    %edi
 2db:	5d                   	pop    %ebp
 2dc:	c3                   	ret    

000002dd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2e9:	90                   	nop
 2ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 2ed:	8d 42 01             	lea    0x1(%edx),%eax
 2f0:	89 45 0c             	mov    %eax,0xc(%ebp)
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	8d 48 01             	lea    0x1(%eax),%ecx
 2f9:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2fc:	0f b6 12             	movzbl (%edx),%edx
 2ff:	88 10                	mov    %dl,(%eax)
 301:	0f b6 00             	movzbl (%eax),%eax
 304:	84 c0                	test   %al,%al
 306:	75 e2                	jne    2ea <strcpy+0xd>
    ;
  return os;
 308:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30b:	c9                   	leave  
 30c:	c3                   	ret    

0000030d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 30d:	55                   	push   %ebp
 30e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 310:	eb 08                	jmp    31a <strcmp+0xd>
    p++, q++;
 312:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 316:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	0f b6 00             	movzbl (%eax),%eax
 320:	84 c0                	test   %al,%al
 322:	74 10                	je     334 <strcmp+0x27>
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	0f b6 10             	movzbl (%eax),%edx
 32a:	8b 45 0c             	mov    0xc(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	38 c2                	cmp    %al,%dl
 332:	74 de                	je     312 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	0f b6 00             	movzbl (%eax),%eax
 33a:	0f b6 d0             	movzbl %al,%edx
 33d:	8b 45 0c             	mov    0xc(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	0f b6 c8             	movzbl %al,%ecx
 346:	89 d0                	mov    %edx,%eax
 348:	29 c8                	sub    %ecx,%eax
}
 34a:	5d                   	pop    %ebp
 34b:	c3                   	ret    

0000034c <strlen>:

uint
strlen(char *s)
{
 34c:	55                   	push   %ebp
 34d:	89 e5                	mov    %esp,%ebp
 34f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 352:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 359:	eb 04                	jmp    35f <strlen+0x13>
 35b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 35f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	01 d0                	add    %edx,%eax
 367:	0f b6 00             	movzbl (%eax),%eax
 36a:	84 c0                	test   %al,%al
 36c:	75 ed                	jne    35b <strlen+0xf>
    ;
  return n;
 36e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 371:	c9                   	leave  
 372:	c3                   	ret    

00000373 <memset>:

void*
memset(void *dst, int c, uint n)
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 376:	8b 45 10             	mov    0x10(%ebp),%eax
 379:	50                   	push   %eax
 37a:	ff 75 0c             	push   0xc(%ebp)
 37d:	ff 75 08             	push   0x8(%ebp)
 380:	e8 32 ff ff ff       	call   2b7 <stosb>
 385:	83 c4 0c             	add    $0xc,%esp
  return dst;
 388:	8b 45 08             	mov    0x8(%ebp),%eax
}
 38b:	c9                   	leave  
 38c:	c3                   	ret    

0000038d <strchr>:

char*
strchr(const char *s, char c)
{
 38d:	55                   	push   %ebp
 38e:	89 e5                	mov    %esp,%ebp
 390:	83 ec 04             	sub    $0x4,%esp
 393:	8b 45 0c             	mov    0xc(%ebp),%eax
 396:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 399:	eb 14                	jmp    3af <strchr+0x22>
    if(*s == c)
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	0f b6 00             	movzbl (%eax),%eax
 3a1:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3a4:	75 05                	jne    3ab <strchr+0x1e>
      return (char*)s;
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	eb 13                	jmp    3be <strchr+0x31>
  for(; *s; s++)
 3ab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	0f b6 00             	movzbl (%eax),%eax
 3b5:	84 c0                	test   %al,%al
 3b7:	75 e2                	jne    39b <strchr+0xe>
  return 0;
 3b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3be:	c9                   	leave  
 3bf:	c3                   	ret    

000003c0 <gets>:

char*
gets(char *buf, int max)
{
 3c0:	55                   	push   %ebp
 3c1:	89 e5                	mov    %esp,%ebp
 3c3:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3cd:	eb 42                	jmp    411 <gets+0x51>
    cc = read(0, &c, 1);
 3cf:	83 ec 04             	sub    $0x4,%esp
 3d2:	6a 01                	push   $0x1
 3d4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3d7:	50                   	push   %eax
 3d8:	6a 00                	push   $0x0
 3da:	e8 47 01 00 00       	call   526 <read>
 3df:	83 c4 10             	add    $0x10,%esp
 3e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3e9:	7e 33                	jle    41e <gets+0x5e>
      break;
    buf[i++] = c;
 3eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ee:	8d 50 01             	lea    0x1(%eax),%edx
 3f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3f4:	89 c2                	mov    %eax,%edx
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	01 c2                	add    %eax,%edx
 3fb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3ff:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 401:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 405:	3c 0a                	cmp    $0xa,%al
 407:	74 16                	je     41f <gets+0x5f>
 409:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 40d:	3c 0d                	cmp    $0xd,%al
 40f:	74 0e                	je     41f <gets+0x5f>
  for(i=0; i+1 < max; ){
 411:	8b 45 f4             	mov    -0xc(%ebp),%eax
 414:	83 c0 01             	add    $0x1,%eax
 417:	39 45 0c             	cmp    %eax,0xc(%ebp)
 41a:	7f b3                	jg     3cf <gets+0xf>
 41c:	eb 01                	jmp    41f <gets+0x5f>
      break;
 41e:	90                   	nop
      break;
  }
  buf[i] = '\0';
 41f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 422:	8b 45 08             	mov    0x8(%ebp),%eax
 425:	01 d0                	add    %edx,%eax
 427:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42d:	c9                   	leave  
 42e:	c3                   	ret    

0000042f <stat>:

int
stat(char *n, struct stat *st)
{
 42f:	55                   	push   %ebp
 430:	89 e5                	mov    %esp,%ebp
 432:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 435:	83 ec 08             	sub    $0x8,%esp
 438:	6a 00                	push   $0x0
 43a:	ff 75 08             	push   0x8(%ebp)
 43d:	e8 14 01 00 00       	call   556 <open>
 442:	83 c4 10             	add    $0x10,%esp
 445:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 448:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 44c:	79 07                	jns    455 <stat+0x26>
    return -1;
 44e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 453:	eb 25                	jmp    47a <stat+0x4b>
  r = fstat(fd, st);
 455:	83 ec 08             	sub    $0x8,%esp
 458:	ff 75 0c             	push   0xc(%ebp)
 45b:	ff 75 f4             	push   -0xc(%ebp)
 45e:	e8 0b 01 00 00       	call   56e <fstat>
 463:	83 c4 10             	add    $0x10,%esp
 466:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 469:	83 ec 0c             	sub    $0xc,%esp
 46c:	ff 75 f4             	push   -0xc(%ebp)
 46f:	e8 c2 00 00 00       	call   536 <close>
 474:	83 c4 10             	add    $0x10,%esp
  return r;
 477:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 47a:	c9                   	leave  
 47b:	c3                   	ret    

0000047c <atoi>:

int
atoi(const char *s)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 482:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 489:	eb 25                	jmp    4b0 <atoi+0x34>
    n = n*10 + *s++ - '0';
 48b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 48e:	89 d0                	mov    %edx,%eax
 490:	c1 e0 02             	shl    $0x2,%eax
 493:	01 d0                	add    %edx,%eax
 495:	01 c0                	add    %eax,%eax
 497:	89 c1                	mov    %eax,%ecx
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	8d 50 01             	lea    0x1(%eax),%edx
 49f:	89 55 08             	mov    %edx,0x8(%ebp)
 4a2:	0f b6 00             	movzbl (%eax),%eax
 4a5:	0f be c0             	movsbl %al,%eax
 4a8:	01 c8                	add    %ecx,%eax
 4aa:	83 e8 30             	sub    $0x30,%eax
 4ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4b0:	8b 45 08             	mov    0x8(%ebp),%eax
 4b3:	0f b6 00             	movzbl (%eax),%eax
 4b6:	3c 2f                	cmp    $0x2f,%al
 4b8:	7e 0a                	jle    4c4 <atoi+0x48>
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
 4bd:	0f b6 00             	movzbl (%eax),%eax
 4c0:	3c 39                	cmp    $0x39,%al
 4c2:	7e c7                	jle    48b <atoi+0xf>
  return n;
 4c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c7:	c9                   	leave  
 4c8:	c3                   	ret    

000004c9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4c9:	55                   	push   %ebp
 4ca:	89 e5                	mov    %esp,%ebp
 4cc:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4cf:	8b 45 08             	mov    0x8(%ebp),%eax
 4d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4db:	eb 17                	jmp    4f4 <memmove+0x2b>
    *dst++ = *src++;
 4dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4e0:	8d 42 01             	lea    0x1(%edx),%eax
 4e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4e9:	8d 48 01             	lea    0x1(%eax),%ecx
 4ec:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4ef:	0f b6 12             	movzbl (%edx),%edx
 4f2:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4f4:	8b 45 10             	mov    0x10(%ebp),%eax
 4f7:	8d 50 ff             	lea    -0x1(%eax),%edx
 4fa:	89 55 10             	mov    %edx,0x10(%ebp)
 4fd:	85 c0                	test   %eax,%eax
 4ff:	7f dc                	jg     4dd <memmove+0x14>
  return vdst;
 501:	8b 45 08             	mov    0x8(%ebp),%eax
}
 504:	c9                   	leave  
 505:	c3                   	ret    

00000506 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 506:	b8 01 00 00 00       	mov    $0x1,%eax
 50b:	cd 40                	int    $0x40
 50d:	c3                   	ret    

0000050e <exit>:
SYSCALL(exit)
 50e:	b8 02 00 00 00       	mov    $0x2,%eax
 513:	cd 40                	int    $0x40
 515:	c3                   	ret    

00000516 <wait>:
SYSCALL(wait)
 516:	b8 03 00 00 00       	mov    $0x3,%eax
 51b:	cd 40                	int    $0x40
 51d:	c3                   	ret    

0000051e <pipe>:
SYSCALL(pipe)
 51e:	b8 04 00 00 00       	mov    $0x4,%eax
 523:	cd 40                	int    $0x40
 525:	c3                   	ret    

00000526 <read>:
SYSCALL(read)
 526:	b8 05 00 00 00       	mov    $0x5,%eax
 52b:	cd 40                	int    $0x40
 52d:	c3                   	ret    

0000052e <write>:
SYSCALL(write)
 52e:	b8 10 00 00 00       	mov    $0x10,%eax
 533:	cd 40                	int    $0x40
 535:	c3                   	ret    

00000536 <close>:
SYSCALL(close)
 536:	b8 15 00 00 00       	mov    $0x15,%eax
 53b:	cd 40                	int    $0x40
 53d:	c3                   	ret    

0000053e <kill>:
SYSCALL(kill)
 53e:	b8 06 00 00 00       	mov    $0x6,%eax
 543:	cd 40                	int    $0x40
 545:	c3                   	ret    

00000546 <dup>:
SYSCALL(dup)
 546:	b8 0a 00 00 00       	mov    $0xa,%eax
 54b:	cd 40                	int    $0x40
 54d:	c3                   	ret    

0000054e <exec>:
SYSCALL(exec)
 54e:	b8 07 00 00 00       	mov    $0x7,%eax
 553:	cd 40                	int    $0x40
 555:	c3                   	ret    

00000556 <open>:
SYSCALL(open)
 556:	b8 0f 00 00 00       	mov    $0xf,%eax
 55b:	cd 40                	int    $0x40
 55d:	c3                   	ret    

0000055e <mknod>:
SYSCALL(mknod)
 55e:	b8 11 00 00 00       	mov    $0x11,%eax
 563:	cd 40                	int    $0x40
 565:	c3                   	ret    

00000566 <unlink>:
SYSCALL(unlink)
 566:	b8 12 00 00 00       	mov    $0x12,%eax
 56b:	cd 40                	int    $0x40
 56d:	c3                   	ret    

0000056e <fstat>:
SYSCALL(fstat)
 56e:	b8 08 00 00 00       	mov    $0x8,%eax
 573:	cd 40                	int    $0x40
 575:	c3                   	ret    

00000576 <link>:
SYSCALL(link)
 576:	b8 13 00 00 00       	mov    $0x13,%eax
 57b:	cd 40                	int    $0x40
 57d:	c3                   	ret    

0000057e <mkdir>:
SYSCALL(mkdir)
 57e:	b8 14 00 00 00       	mov    $0x14,%eax
 583:	cd 40                	int    $0x40
 585:	c3                   	ret    

00000586 <chdir>:
SYSCALL(chdir)
 586:	b8 09 00 00 00       	mov    $0x9,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret    

0000058e <sbrk>:
SYSCALL(sbrk)
 58e:	b8 0c 00 00 00       	mov    $0xc,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret    

00000596 <sleep>:
SYSCALL(sleep)
 596:	b8 0d 00 00 00       	mov    $0xd,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret    

0000059e <getpid>:
SYSCALL(getpid)
 59e:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret    

000005a6 <uthread_init>:
SYSCALL(uthread_init)
 5a6:	b8 18 00 00 00       	mov    $0x18,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret    

000005ae <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ae:	55                   	push   %ebp
 5af:	89 e5                	mov    %esp,%ebp
 5b1:	83 ec 18             	sub    $0x18,%esp
 5b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b7:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ba:	83 ec 04             	sub    $0x4,%esp
 5bd:	6a 01                	push   $0x1
 5bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5c2:	50                   	push   %eax
 5c3:	ff 75 08             	push   0x8(%ebp)
 5c6:	e8 63 ff ff ff       	call   52e <write>
 5cb:	83 c4 10             	add    $0x10,%esp
}
 5ce:	90                   	nop
 5cf:	c9                   	leave  
 5d0:	c3                   	ret    

000005d1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d1:	55                   	push   %ebp
 5d2:	89 e5                	mov    %esp,%ebp
 5d4:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5de:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5e2:	74 17                	je     5fb <printint+0x2a>
 5e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e8:	79 11                	jns    5fb <printint+0x2a>
    neg = 1;
 5ea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f4:	f7 d8                	neg    %eax
 5f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f9:	eb 06                	jmp    601 <printint+0x30>
  } else {
    x = xx;
 5fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 601:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 608:	8b 4d 10             	mov    0x10(%ebp),%ecx
 60b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 60e:	ba 00 00 00 00       	mov    $0x0,%edx
 613:	f7 f1                	div    %ecx
 615:	89 d1                	mov    %edx,%ecx
 617:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61a:	8d 50 01             	lea    0x1(%eax),%edx
 61d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 620:	0f b6 91 d8 0d 00 00 	movzbl 0xdd8(%ecx),%edx
 627:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 62b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 62e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 631:	ba 00 00 00 00       	mov    $0x0,%edx
 636:	f7 f1                	div    %ecx
 638:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63f:	75 c7                	jne    608 <printint+0x37>
  if(neg)
 641:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 645:	74 2d                	je     674 <printint+0xa3>
    buf[i++] = '-';
 647:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64a:	8d 50 01             	lea    0x1(%eax),%edx
 64d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 650:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 655:	eb 1d                	jmp    674 <printint+0xa3>
    putc(fd, buf[i]);
 657:	8d 55 dc             	lea    -0x24(%ebp),%edx
 65a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65d:	01 d0                	add    %edx,%eax
 65f:	0f b6 00             	movzbl (%eax),%eax
 662:	0f be c0             	movsbl %al,%eax
 665:	83 ec 08             	sub    $0x8,%esp
 668:	50                   	push   %eax
 669:	ff 75 08             	push   0x8(%ebp)
 66c:	e8 3d ff ff ff       	call   5ae <putc>
 671:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 674:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 678:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 67c:	79 d9                	jns    657 <printint+0x86>
}
 67e:	90                   	nop
 67f:	90                   	nop
 680:	c9                   	leave  
 681:	c3                   	ret    

00000682 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 682:	55                   	push   %ebp
 683:	89 e5                	mov    %esp,%ebp
 685:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 688:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 68f:	8d 45 0c             	lea    0xc(%ebp),%eax
 692:	83 c0 04             	add    $0x4,%eax
 695:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 698:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 69f:	e9 59 01 00 00       	jmp    7fd <printf+0x17b>
    c = fmt[i] & 0xff;
 6a4:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6aa:	01 d0                	add    %edx,%eax
 6ac:	0f b6 00             	movzbl (%eax),%eax
 6af:	0f be c0             	movsbl %al,%eax
 6b2:	25 ff 00 00 00       	and    $0xff,%eax
 6b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6be:	75 2c                	jne    6ec <printf+0x6a>
      if(c == '%'){
 6c0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6c4:	75 0c                	jne    6d2 <printf+0x50>
        state = '%';
 6c6:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6cd:	e9 27 01 00 00       	jmp    7f9 <printf+0x177>
      } else {
        putc(fd, c);
 6d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d5:	0f be c0             	movsbl %al,%eax
 6d8:	83 ec 08             	sub    $0x8,%esp
 6db:	50                   	push   %eax
 6dc:	ff 75 08             	push   0x8(%ebp)
 6df:	e8 ca fe ff ff       	call   5ae <putc>
 6e4:	83 c4 10             	add    $0x10,%esp
 6e7:	e9 0d 01 00 00       	jmp    7f9 <printf+0x177>
      }
    } else if(state == '%'){
 6ec:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6f0:	0f 85 03 01 00 00    	jne    7f9 <printf+0x177>
      if(c == 'd'){
 6f6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6fa:	75 1e                	jne    71a <printf+0x98>
        printint(fd, *ap, 10, 1);
 6fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ff:	8b 00                	mov    (%eax),%eax
 701:	6a 01                	push   $0x1
 703:	6a 0a                	push   $0xa
 705:	50                   	push   %eax
 706:	ff 75 08             	push   0x8(%ebp)
 709:	e8 c3 fe ff ff       	call   5d1 <printint>
 70e:	83 c4 10             	add    $0x10,%esp
        ap++;
 711:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 715:	e9 d8 00 00 00       	jmp    7f2 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 71a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 71e:	74 06                	je     726 <printf+0xa4>
 720:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 724:	75 1e                	jne    744 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 726:	8b 45 e8             	mov    -0x18(%ebp),%eax
 729:	8b 00                	mov    (%eax),%eax
 72b:	6a 00                	push   $0x0
 72d:	6a 10                	push   $0x10
 72f:	50                   	push   %eax
 730:	ff 75 08             	push   0x8(%ebp)
 733:	e8 99 fe ff ff       	call   5d1 <printint>
 738:	83 c4 10             	add    $0x10,%esp
        ap++;
 73b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73f:	e9 ae 00 00 00       	jmp    7f2 <printf+0x170>
      } else if(c == 's'){
 744:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 748:	75 43                	jne    78d <printf+0x10b>
        s = (char*)*ap;
 74a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 752:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 756:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75a:	75 25                	jne    781 <printf+0xff>
          s = "(null)";
 75c:	c7 45 f4 c3 0a 00 00 	movl   $0xac3,-0xc(%ebp)
        while(*s != 0){
 763:	eb 1c                	jmp    781 <printf+0xff>
          putc(fd, *s);
 765:	8b 45 f4             	mov    -0xc(%ebp),%eax
 768:	0f b6 00             	movzbl (%eax),%eax
 76b:	0f be c0             	movsbl %al,%eax
 76e:	83 ec 08             	sub    $0x8,%esp
 771:	50                   	push   %eax
 772:	ff 75 08             	push   0x8(%ebp)
 775:	e8 34 fe ff ff       	call   5ae <putc>
 77a:	83 c4 10             	add    $0x10,%esp
          s++;
 77d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	0f b6 00             	movzbl (%eax),%eax
 787:	84 c0                	test   %al,%al
 789:	75 da                	jne    765 <printf+0xe3>
 78b:	eb 65                	jmp    7f2 <printf+0x170>
        }
      } else if(c == 'c'){
 78d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 791:	75 1d                	jne    7b0 <printf+0x12e>
        putc(fd, *ap);
 793:	8b 45 e8             	mov    -0x18(%ebp),%eax
 796:	8b 00                	mov    (%eax),%eax
 798:	0f be c0             	movsbl %al,%eax
 79b:	83 ec 08             	sub    $0x8,%esp
 79e:	50                   	push   %eax
 79f:	ff 75 08             	push   0x8(%ebp)
 7a2:	e8 07 fe ff ff       	call   5ae <putc>
 7a7:	83 c4 10             	add    $0x10,%esp
        ap++;
 7aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ae:	eb 42                	jmp    7f2 <printf+0x170>
      } else if(c == '%'){
 7b0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b4:	75 17                	jne    7cd <printf+0x14b>
        putc(fd, c);
 7b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b9:	0f be c0             	movsbl %al,%eax
 7bc:	83 ec 08             	sub    $0x8,%esp
 7bf:	50                   	push   %eax
 7c0:	ff 75 08             	push   0x8(%ebp)
 7c3:	e8 e6 fd ff ff       	call   5ae <putc>
 7c8:	83 c4 10             	add    $0x10,%esp
 7cb:	eb 25                	jmp    7f2 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7cd:	83 ec 08             	sub    $0x8,%esp
 7d0:	6a 25                	push   $0x25
 7d2:	ff 75 08             	push   0x8(%ebp)
 7d5:	e8 d4 fd ff ff       	call   5ae <putc>
 7da:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e0:	0f be c0             	movsbl %al,%eax
 7e3:	83 ec 08             	sub    $0x8,%esp
 7e6:	50                   	push   %eax
 7e7:	ff 75 08             	push   0x8(%ebp)
 7ea:	e8 bf fd ff ff       	call   5ae <putc>
 7ef:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7f9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7fd:	8b 55 0c             	mov    0xc(%ebp),%edx
 800:	8b 45 f0             	mov    -0x10(%ebp),%eax
 803:	01 d0                	add    %edx,%eax
 805:	0f b6 00             	movzbl (%eax),%eax
 808:	84 c0                	test   %al,%al
 80a:	0f 85 94 fe ff ff    	jne    6a4 <printf+0x22>
    }
  }
}
 810:	90                   	nop
 811:	90                   	nop
 812:	c9                   	leave  
 813:	c3                   	ret    

00000814 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 814:	55                   	push   %ebp
 815:	89 e5                	mov    %esp,%ebp
 817:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81a:	8b 45 08             	mov    0x8(%ebp),%eax
 81d:	83 e8 08             	sub    $0x8,%eax
 820:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 823:	a1 c8 4e 01 00       	mov    0x14ec8,%eax
 828:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82b:	eb 24                	jmp    851 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 835:	72 12                	jb     849 <free+0x35>
 837:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83d:	77 24                	ja     863 <free+0x4f>
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	8b 00                	mov    (%eax),%eax
 844:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 847:	72 1a                	jb     863 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 851:	8b 45 f8             	mov    -0x8(%ebp),%eax
 854:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 857:	76 d4                	jbe    82d <free+0x19>
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 861:	73 ca                	jae    82d <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 870:	8b 45 f8             	mov    -0x8(%ebp),%eax
 873:	01 c2                	add    %eax,%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	8b 00                	mov    (%eax),%eax
 87a:	39 c2                	cmp    %eax,%edx
 87c:	75 24                	jne    8a2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 87e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 881:	8b 50 04             	mov    0x4(%eax),%edx
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	8b 00                	mov    (%eax),%eax
 889:	8b 40 04             	mov    0x4(%eax),%eax
 88c:	01 c2                	add    %eax,%edx
 88e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 891:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	8b 45 fc             	mov    -0x4(%ebp),%eax
 897:	8b 00                	mov    (%eax),%eax
 899:	8b 10                	mov    (%eax),%edx
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	89 10                	mov    %edx,(%eax)
 8a0:	eb 0a                	jmp    8ac <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a5:	8b 10                	mov    (%eax),%edx
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8af:	8b 40 04             	mov    0x4(%eax),%eax
 8b2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	01 d0                	add    %edx,%eax
 8be:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c1:	75 20                	jne    8e3 <free+0xcf>
    p->s.size += bp->s.size;
 8c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c6:	8b 50 04             	mov    0x4(%eax),%edx
 8c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cc:	8b 40 04             	mov    0x4(%eax),%eax
 8cf:	01 c2                	add    %eax,%edx
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	8b 10                	mov    (%eax),%edx
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	89 10                	mov    %edx,(%eax)
 8e1:	eb 08                	jmp    8eb <free+0xd7>
  } else
    p->s.ptr = bp;
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e9:	89 10                	mov    %edx,(%eax)
  freep = p;
 8eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ee:	a3 c8 4e 01 00       	mov    %eax,0x14ec8
}
 8f3:	90                   	nop
 8f4:	c9                   	leave  
 8f5:	c3                   	ret    

000008f6 <morecore>:

static Header*
morecore(uint nu)
{
 8f6:	55                   	push   %ebp
 8f7:	89 e5                	mov    %esp,%ebp
 8f9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8fc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 903:	77 07                	ja     90c <morecore+0x16>
    nu = 4096;
 905:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 90c:	8b 45 08             	mov    0x8(%ebp),%eax
 90f:	c1 e0 03             	shl    $0x3,%eax
 912:	83 ec 0c             	sub    $0xc,%esp
 915:	50                   	push   %eax
 916:	e8 73 fc ff ff       	call   58e <sbrk>
 91b:	83 c4 10             	add    $0x10,%esp
 91e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 921:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 925:	75 07                	jne    92e <morecore+0x38>
    return 0;
 927:	b8 00 00 00 00       	mov    $0x0,%eax
 92c:	eb 26                	jmp    954 <morecore+0x5e>
  hp = (Header*)p;
 92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 931:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 934:	8b 45 f0             	mov    -0x10(%ebp),%eax
 937:	8b 55 08             	mov    0x8(%ebp),%edx
 93a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 93d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 940:	83 c0 08             	add    $0x8,%eax
 943:	83 ec 0c             	sub    $0xc,%esp
 946:	50                   	push   %eax
 947:	e8 c8 fe ff ff       	call   814 <free>
 94c:	83 c4 10             	add    $0x10,%esp
  return freep;
 94f:	a1 c8 4e 01 00       	mov    0x14ec8,%eax
}
 954:	c9                   	leave  
 955:	c3                   	ret    

00000956 <malloc>:

void*
malloc(uint nbytes)
{
 956:	55                   	push   %ebp
 957:	89 e5                	mov    %esp,%ebp
 959:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95c:	8b 45 08             	mov    0x8(%ebp),%eax
 95f:	83 c0 07             	add    $0x7,%eax
 962:	c1 e8 03             	shr    $0x3,%eax
 965:	83 c0 01             	add    $0x1,%eax
 968:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 96b:	a1 c8 4e 01 00       	mov    0x14ec8,%eax
 970:	89 45 f0             	mov    %eax,-0x10(%ebp)
 973:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 977:	75 23                	jne    99c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 979:	c7 45 f0 c0 4e 01 00 	movl   $0x14ec0,-0x10(%ebp)
 980:	8b 45 f0             	mov    -0x10(%ebp),%eax
 983:	a3 c8 4e 01 00       	mov    %eax,0x14ec8
 988:	a1 c8 4e 01 00       	mov    0x14ec8,%eax
 98d:	a3 c0 4e 01 00       	mov    %eax,0x14ec0
    base.s.size = 0;
 992:	c7 05 c4 4e 01 00 00 	movl   $0x0,0x14ec4
 999:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99f:	8b 00                	mov    (%eax),%eax
 9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a7:	8b 40 04             	mov    0x4(%eax),%eax
 9aa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ad:	77 4d                	ja     9fc <malloc+0xa6>
      if(p->s.size == nunits)
 9af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b2:	8b 40 04             	mov    0x4(%eax),%eax
 9b5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b8:	75 0c                	jne    9c6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	8b 10                	mov    (%eax),%edx
 9bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c2:	89 10                	mov    %edx,(%eax)
 9c4:	eb 26                	jmp    9ec <malloc+0x96>
      else {
        p->s.size -= nunits;
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	8b 40 04             	mov    0x4(%eax),%eax
 9cc:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9cf:	89 c2                	mov    %eax,%edx
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9da:	8b 40 04             	mov    0x4(%eax),%eax
 9dd:	c1 e0 03             	shl    $0x3,%eax
 9e0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ef:	a3 c8 4e 01 00       	mov    %eax,0x14ec8
      return (void*)(p + 1);
 9f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f7:	83 c0 08             	add    $0x8,%eax
 9fa:	eb 3b                	jmp    a37 <malloc+0xe1>
    }
    if(p == freep)
 9fc:	a1 c8 4e 01 00       	mov    0x14ec8,%eax
 a01:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a04:	75 1e                	jne    a24 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a06:	83 ec 0c             	sub    $0xc,%esp
 a09:	ff 75 ec             	push   -0x14(%ebp)
 a0c:	e8 e5 fe ff ff       	call   8f6 <morecore>
 a11:	83 c4 10             	add    $0x10,%esp
 a14:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a1b:	75 07                	jne    a24 <malloc+0xce>
        return 0;
 a1d:	b8 00 00 00 00       	mov    $0x0,%eax
 a22:	eb 13                	jmp    a37 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2d:	8b 00                	mov    (%eax),%eax
 a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a32:	e9 6d ff ff ff       	jmp    9a4 <malloc+0x4e>
  }
}
 a37:	c9                   	leave  
 a38:	c3                   	ret    
