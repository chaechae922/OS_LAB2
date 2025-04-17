
_uthread1:     file format elf32-i386


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
   6:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 60 0d 00 00 	movl   $0xd60,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 40 0d 00 00       	mov    0xd40,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 44 0d 00 00       	mov    %eax,0xd44
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  42:	b8 80 8d 00 00       	mov    $0x8d80,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 80 8d 00 00       	mov    $0x8d80,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 40 0d 00 00       	mov    0xd40,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 40 0d 00 00       	mov    0xd40,%eax
  6b:	a3 44 0d 00 00       	mov    %eax,0xd44
  }

  if (next_thread == 0) {
  70:	a1 44 0d 00 00       	mov    0xd44,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 c8 09 00 00       	push   $0x9c8
  81:	6a 02                	push   $0x2
  83:	e8 89 05 00 00       	call   611 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 0d 04 00 00       	call   49d <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 40 0d 00 00    	mov    0xd40,%edx
  96:	a1 44 0d 00 00       	mov    0xd44,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 16                	je     b5 <thread_schedule+0xb5>
    next_thread->state = RUNNING;
  9f:	a1 44 0d 00 00       	mov    0xd44,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    thread_switch();
  ae:	e8 7d 01 00 00       	call   230 <thread_switch>
  } else
    next_thread = 0;
}
  b3:	eb 0a                	jmp    bf <thread_schedule+0xbf>
    next_thread = 0;
  b5:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
  bc:	00 00 00 
}
  bf:	90                   	nop
  c0:	c9                   	leave  
  c1:	c3                   	ret    

000000c2 <thread_init>:

void 
thread_init(void)
{
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  c5:	c7 05 40 0d 00 00 60 	movl   $0xd60,0xd40
  cc:	0d 00 00 
  current_thread->state = RUNNING;
  cf:	a1 40 0d 00 00       	mov    0xd40,%eax
  d4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  db:	00 00 00 
}
  de:	90                   	nop
  df:	5d                   	pop    %ebp
  e0:	c3                   	ret    

000000e1 <thread_create>:

void 
thread_create(void (*func)())
{
  e1:	55                   	push   %ebp
  e2:	89 e5                	mov    %esp,%ebp
  e4:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  e7:	c7 45 fc 60 0d 00 00 	movl   $0xd60,-0x4(%ebp)
  ee:	eb 14                	jmp    104 <thread_create+0x23>
    if (t->state == FREE) break;
  f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  f3:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f9:	85 c0                	test   %eax,%eax
  fb:	74 13                	je     110 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  fd:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 104:	b8 80 8d 00 00       	mov    $0x8d80,%eax
 109:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 10c:	72 e2                	jb     f0 <thread_create+0xf>
 10e:	eb 01                	jmp    111 <thread_create+0x30>
    if (t->state == FREE) break;
 110:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 111:	8b 45 fc             	mov    -0x4(%ebp),%eax
 114:	83 c0 04             	add    $0x4,%eax
 117:	05 00 20 00 00       	add    $0x2000,%eax
 11c:	89 c2                	mov    %eax,%edx
 11e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 121:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 123:	8b 45 fc             	mov    -0x4(%ebp),%eax
 126:	8b 00                	mov    (%eax),%eax
 128:	8d 50 fc             	lea    -0x4(%eax),%edx
 12b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 12e:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 130:	8b 45 fc             	mov    -0x4(%ebp),%eax
 133:	8b 00                	mov    (%eax),%eax
 135:	89 c2                	mov    %eax,%edx
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 13c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 13f:	8b 00                	mov    (%eax),%eax
 141:	8d 50 e0             	lea    -0x20(%eax),%edx
 144:	8b 45 fc             	mov    -0x4(%ebp),%eax
 147:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 149:	8b 45 fc             	mov    -0x4(%ebp),%eax
 14c:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 153:	00 00 00 
}
 156:	90                   	nop
 157:	c9                   	leave  
 158:	c3                   	ret    

00000159 <thread_yield>:

void 
thread_yield(void)
{
 159:	55                   	push   %ebp
 15a:	89 e5                	mov    %esp,%ebp
 15c:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
 15f:	a1 40 0d 00 00       	mov    0xd40,%eax
 164:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 16b:	00 00 00 
  thread_schedule();
 16e:	e8 8d fe ff ff       	call   0 <thread_schedule>
}
 173:	90                   	nop
 174:	c9                   	leave  
 175:	c3                   	ret    

00000176 <mythread>:

static void 
mythread(void)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 17c:	83 ec 08             	sub    $0x8,%esp
 17f:	68 ee 09 00 00       	push   $0x9ee
 184:	6a 01                	push   $0x1
 186:	e8 86 04 00 00       	call   611 <printf>
 18b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 18e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 195:	eb 21                	jmp    1b8 <mythread+0x42>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 197:	a1 40 0d 00 00       	mov    0xd40,%eax
 19c:	83 ec 04             	sub    $0x4,%esp
 19f:	50                   	push   %eax
 1a0:	68 01 0a 00 00       	push   $0xa01
 1a5:	6a 01                	push   $0x1
 1a7:	e8 65 04 00 00       	call   611 <printf>
 1ac:	83 c4 10             	add    $0x10,%esp
    thread_yield();
 1af:	e8 a5 ff ff ff       	call   159 <thread_yield>
  for (i = 0; i < 100; i++) {
 1b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1b8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1bc:	7e d9                	jle    197 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1be:	83 ec 08             	sub    $0x8,%esp
 1c1:	68 11 0a 00 00       	push   $0xa11
 1c6:	6a 01                	push   $0x1
 1c8:	e8 44 04 00 00       	call   611 <printf>
 1cd:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1d0:	a1 40 0d 00 00       	mov    0xd40,%eax
 1d5:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 1dc:	00 00 00 
  thread_schedule();
 1df:	e8 1c fe ff ff       	call   0 <thread_schedule>
}
 1e4:	90                   	nop
 1e5:	c9                   	leave  
 1e6:	c3                   	ret    

000001e7 <main>:


int 
main(int argc, char *argv[]) 
{
 1e7:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1eb:	83 e4 f0             	and    $0xfffffff0,%esp
 1ee:	ff 71 fc             	push   -0x4(%ecx)
 1f1:	55                   	push   %ebp
 1f2:	89 e5                	mov    %esp,%ebp
 1f4:	51                   	push   %ecx
 1f5:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 1f8:	e8 c5 fe ff ff       	call   c2 <thread_init>
  thread_create(mythread);
 1fd:	68 76 01 00 00       	push   $0x176
 202:	e8 da fe ff ff       	call   e1 <thread_create>
 207:	83 c4 04             	add    $0x4,%esp
  thread_create(mythread);
 20a:	68 76 01 00 00       	push   $0x176
 20f:	e8 cd fe ff ff       	call   e1 <thread_create>
 214:	83 c4 04             	add    $0x4,%esp

current_thread->state = FREE;
 217:	a1 40 0d 00 00       	mov    0xd40,%eax
 21c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 223:	00 00 00 

  thread_schedule();
 226:	e8 d5 fd ff ff       	call   0 <thread_schedule>

  exit();
 22b:	e8 6d 02 00 00       	call   49d <exit>

00000230 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 230:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 231:	a1 40 0d 00 00       	mov    0xd40,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 236:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 238:	a1 44 0d 00 00       	mov    0xd44,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 23d:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 23f:	a3 40 0d 00 00       	mov    %eax,0xd40
    popal
 244:	61                   	popa   
    
    # return to next thread's stack context
 245:	c3                   	ret    

00000246 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 246:	55                   	push   %ebp
 247:	89 e5                	mov    %esp,%ebp
 249:	57                   	push   %edi
 24a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 24b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 24e:	8b 55 10             	mov    0x10(%ebp),%edx
 251:	8b 45 0c             	mov    0xc(%ebp),%eax
 254:	89 cb                	mov    %ecx,%ebx
 256:	89 df                	mov    %ebx,%edi
 258:	89 d1                	mov    %edx,%ecx
 25a:	fc                   	cld    
 25b:	f3 aa                	rep stos %al,%es:(%edi)
 25d:	89 ca                	mov    %ecx,%edx
 25f:	89 fb                	mov    %edi,%ebx
 261:	89 5d 08             	mov    %ebx,0x8(%ebp)
 264:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 267:	90                   	nop
 268:	5b                   	pop    %ebx
 269:	5f                   	pop    %edi
 26a:	5d                   	pop    %ebp
 26b:	c3                   	ret    

0000026c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 26c:	55                   	push   %ebp
 26d:	89 e5                	mov    %esp,%ebp
 26f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 278:	90                   	nop
 279:	8b 55 0c             	mov    0xc(%ebp),%edx
 27c:	8d 42 01             	lea    0x1(%edx),%eax
 27f:	89 45 0c             	mov    %eax,0xc(%ebp)
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	8d 48 01             	lea    0x1(%eax),%ecx
 288:	89 4d 08             	mov    %ecx,0x8(%ebp)
 28b:	0f b6 12             	movzbl (%edx),%edx
 28e:	88 10                	mov    %dl,(%eax)
 290:	0f b6 00             	movzbl (%eax),%eax
 293:	84 c0                	test   %al,%al
 295:	75 e2                	jne    279 <strcpy+0xd>
    ;
  return os;
 297:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 29f:	eb 08                	jmp    2a9 <strcmp+0xd>
    p++, q++;
 2a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2a5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ac:	0f b6 00             	movzbl (%eax),%eax
 2af:	84 c0                	test   %al,%al
 2b1:	74 10                	je     2c3 <strcmp+0x27>
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	0f b6 10             	movzbl (%eax),%edx
 2b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bc:	0f b6 00             	movzbl (%eax),%eax
 2bf:	38 c2                	cmp    %al,%dl
 2c1:	74 de                	je     2a1 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
 2c6:	0f b6 00             	movzbl (%eax),%eax
 2c9:	0f b6 d0             	movzbl %al,%edx
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	0f b6 c8             	movzbl %al,%ecx
 2d5:	89 d0                	mov    %edx,%eax
 2d7:	29 c8                	sub    %ecx,%eax
}
 2d9:	5d                   	pop    %ebp
 2da:	c3                   	ret    

000002db <strlen>:

uint
strlen(char *s)
{
 2db:	55                   	push   %ebp
 2dc:	89 e5                	mov    %esp,%ebp
 2de:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2e8:	eb 04                	jmp    2ee <strlen+0x13>
 2ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	01 d0                	add    %edx,%eax
 2f6:	0f b6 00             	movzbl (%eax),%eax
 2f9:	84 c0                	test   %al,%al
 2fb:	75 ed                	jne    2ea <strlen+0xf>
    ;
  return n;
 2fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 300:	c9                   	leave  
 301:	c3                   	ret    

00000302 <memset>:

void*
memset(void *dst, int c, uint n)
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 305:	8b 45 10             	mov    0x10(%ebp),%eax
 308:	50                   	push   %eax
 309:	ff 75 0c             	push   0xc(%ebp)
 30c:	ff 75 08             	push   0x8(%ebp)
 30f:	e8 32 ff ff ff       	call   246 <stosb>
 314:	83 c4 0c             	add    $0xc,%esp
  return dst;
 317:	8b 45 08             	mov    0x8(%ebp),%eax
}
 31a:	c9                   	leave  
 31b:	c3                   	ret    

0000031c <strchr>:

char*
strchr(const char *s, char c)
{
 31c:	55                   	push   %ebp
 31d:	89 e5                	mov    %esp,%ebp
 31f:	83 ec 04             	sub    $0x4,%esp
 322:	8b 45 0c             	mov    0xc(%ebp),%eax
 325:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 328:	eb 14                	jmp    33e <strchr+0x22>
    if(*s == c)
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	38 45 fc             	cmp    %al,-0x4(%ebp)
 333:	75 05                	jne    33a <strchr+0x1e>
      return (char*)s;
 335:	8b 45 08             	mov    0x8(%ebp),%eax
 338:	eb 13                	jmp    34d <strchr+0x31>
  for(; *s; s++)
 33a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	0f b6 00             	movzbl (%eax),%eax
 344:	84 c0                	test   %al,%al
 346:	75 e2                	jne    32a <strchr+0xe>
  return 0;
 348:	b8 00 00 00 00       	mov    $0x0,%eax
}
 34d:	c9                   	leave  
 34e:	c3                   	ret    

0000034f <gets>:

char*
gets(char *buf, int max)
{
 34f:	55                   	push   %ebp
 350:	89 e5                	mov    %esp,%ebp
 352:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 355:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 35c:	eb 42                	jmp    3a0 <gets+0x51>
    cc = read(0, &c, 1);
 35e:	83 ec 04             	sub    $0x4,%esp
 361:	6a 01                	push   $0x1
 363:	8d 45 ef             	lea    -0x11(%ebp),%eax
 366:	50                   	push   %eax
 367:	6a 00                	push   $0x0
 369:	e8 47 01 00 00       	call   4b5 <read>
 36e:	83 c4 10             	add    $0x10,%esp
 371:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 374:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 378:	7e 33                	jle    3ad <gets+0x5e>
      break;
    buf[i++] = c;
 37a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37d:	8d 50 01             	lea    0x1(%eax),%edx
 380:	89 55 f4             	mov    %edx,-0xc(%ebp)
 383:	89 c2                	mov    %eax,%edx
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	01 c2                	add    %eax,%edx
 38a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 38e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 390:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 394:	3c 0a                	cmp    $0xa,%al
 396:	74 16                	je     3ae <gets+0x5f>
 398:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39c:	3c 0d                	cmp    $0xd,%al
 39e:	74 0e                	je     3ae <gets+0x5f>
  for(i=0; i+1 < max; ){
 3a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a3:	83 c0 01             	add    $0x1,%eax
 3a6:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3a9:	7f b3                	jg     35e <gets+0xf>
 3ab:	eb 01                	jmp    3ae <gets+0x5f>
      break;
 3ad:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	01 d0                	add    %edx,%eax
 3b6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <stat>:

int
stat(char *n, struct stat *st)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c4:	83 ec 08             	sub    $0x8,%esp
 3c7:	6a 00                	push   $0x0
 3c9:	ff 75 08             	push   0x8(%ebp)
 3cc:	e8 14 01 00 00       	call   4e5 <open>
 3d1:	83 c4 10             	add    $0x10,%esp
 3d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3db:	79 07                	jns    3e4 <stat+0x26>
    return -1;
 3dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3e2:	eb 25                	jmp    409 <stat+0x4b>
  r = fstat(fd, st);
 3e4:	83 ec 08             	sub    $0x8,%esp
 3e7:	ff 75 0c             	push   0xc(%ebp)
 3ea:	ff 75 f4             	push   -0xc(%ebp)
 3ed:	e8 0b 01 00 00       	call   4fd <fstat>
 3f2:	83 c4 10             	add    $0x10,%esp
 3f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3f8:	83 ec 0c             	sub    $0xc,%esp
 3fb:	ff 75 f4             	push   -0xc(%ebp)
 3fe:	e8 c2 00 00 00       	call   4c5 <close>
 403:	83 c4 10             	add    $0x10,%esp
  return r;
 406:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 409:	c9                   	leave  
 40a:	c3                   	ret    

0000040b <atoi>:

int
atoi(const char *s)
{
 40b:	55                   	push   %ebp
 40c:	89 e5                	mov    %esp,%ebp
 40e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 411:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 418:	eb 25                	jmp    43f <atoi+0x34>
    n = n*10 + *s++ - '0';
 41a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 41d:	89 d0                	mov    %edx,%eax
 41f:	c1 e0 02             	shl    $0x2,%eax
 422:	01 d0                	add    %edx,%eax
 424:	01 c0                	add    %eax,%eax
 426:	89 c1                	mov    %eax,%ecx
 428:	8b 45 08             	mov    0x8(%ebp),%eax
 42b:	8d 50 01             	lea    0x1(%eax),%edx
 42e:	89 55 08             	mov    %edx,0x8(%ebp)
 431:	0f b6 00             	movzbl (%eax),%eax
 434:	0f be c0             	movsbl %al,%eax
 437:	01 c8                	add    %ecx,%eax
 439:	83 e8 30             	sub    $0x30,%eax
 43c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	0f b6 00             	movzbl (%eax),%eax
 445:	3c 2f                	cmp    $0x2f,%al
 447:	7e 0a                	jle    453 <atoi+0x48>
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	3c 39                	cmp    $0x39,%al
 451:	7e c7                	jle    41a <atoi+0xf>
  return n;
 453:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 456:	c9                   	leave  
 457:	c3                   	ret    

00000458 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 46a:	eb 17                	jmp    483 <memmove+0x2b>
    *dst++ = *src++;
 46c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 46f:	8d 42 01             	lea    0x1(%edx),%eax
 472:	89 45 f8             	mov    %eax,-0x8(%ebp)
 475:	8b 45 fc             	mov    -0x4(%ebp),%eax
 478:	8d 48 01             	lea    0x1(%eax),%ecx
 47b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 47e:	0f b6 12             	movzbl (%edx),%edx
 481:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 483:	8b 45 10             	mov    0x10(%ebp),%eax
 486:	8d 50 ff             	lea    -0x1(%eax),%edx
 489:	89 55 10             	mov    %edx,0x10(%ebp)
 48c:	85 c0                	test   %eax,%eax
 48e:	7f dc                	jg     46c <memmove+0x14>
  return vdst;
 490:	8b 45 08             	mov    0x8(%ebp),%eax
}
 493:	c9                   	leave  
 494:	c3                   	ret    

00000495 <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 495:	b8 01 00 00 00       	mov    $0x1,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <exit>:
SYSCALL(exit)
 49d:	b8 02 00 00 00       	mov    $0x2,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <wait>:
SYSCALL(wait)
 4a5:	b8 03 00 00 00       	mov    $0x3,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <pipe>:
SYSCALL(pipe)
 4ad:	b8 04 00 00 00       	mov    $0x4,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <read>:
SYSCALL(read)
 4b5:	b8 05 00 00 00       	mov    $0x5,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <write>:
SYSCALL(write)
 4bd:	b8 10 00 00 00       	mov    $0x10,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <close>:
SYSCALL(close)
 4c5:	b8 15 00 00 00       	mov    $0x15,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <kill>:
SYSCALL(kill)
 4cd:	b8 06 00 00 00       	mov    $0x6,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <dup>:
SYSCALL(dup)
 4d5:	b8 0a 00 00 00       	mov    $0xa,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <exec>:
SYSCALL(exec)
 4dd:	b8 07 00 00 00       	mov    $0x7,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <open>:
SYSCALL(open)
 4e5:	b8 0f 00 00 00       	mov    $0xf,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <mknod>:
SYSCALL(mknod)
 4ed:	b8 11 00 00 00       	mov    $0x11,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <unlink>:
SYSCALL(unlink)
 4f5:	b8 12 00 00 00       	mov    $0x12,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <fstat>:
SYSCALL(fstat)
 4fd:	b8 08 00 00 00       	mov    $0x8,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <link>:
SYSCALL(link)
 505:	b8 13 00 00 00       	mov    $0x13,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <mkdir>:
SYSCALL(mkdir)
 50d:	b8 14 00 00 00       	mov    $0x14,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <chdir>:
SYSCALL(chdir)
 515:	b8 09 00 00 00       	mov    $0x9,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret    

0000051d <sbrk>:
SYSCALL(sbrk)
 51d:	b8 0c 00 00 00       	mov    $0xc,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret    

00000525 <sleep>:
SYSCALL(sleep)
 525:	b8 0d 00 00 00       	mov    $0xd,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret    

0000052d <getpid>:
SYSCALL(getpid)
 52d:	b8 0b 00 00 00       	mov    $0xb,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret    

00000535 <uthread_init>:
SYSCALL(uthread_init)
 535:	b8 18 00 00 00       	mov    $0x18,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret    

0000053d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 53d:	55                   	push   %ebp
 53e:	89 e5                	mov    %esp,%ebp
 540:	83 ec 18             	sub    $0x18,%esp
 543:	8b 45 0c             	mov    0xc(%ebp),%eax
 546:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 549:	83 ec 04             	sub    $0x4,%esp
 54c:	6a 01                	push   $0x1
 54e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 551:	50                   	push   %eax
 552:	ff 75 08             	push   0x8(%ebp)
 555:	e8 63 ff ff ff       	call   4bd <write>
 55a:	83 c4 10             	add    $0x10,%esp
}
 55d:	90                   	nop
 55e:	c9                   	leave  
 55f:	c3                   	ret    

00000560 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 566:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 56d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 571:	74 17                	je     58a <printint+0x2a>
 573:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 577:	79 11                	jns    58a <printint+0x2a>
    neg = 1;
 579:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 580:	8b 45 0c             	mov    0xc(%ebp),%eax
 583:	f7 d8                	neg    %eax
 585:	89 45 ec             	mov    %eax,-0x14(%ebp)
 588:	eb 06                	jmp    590 <printint+0x30>
  } else {
    x = xx;
 58a:	8b 45 0c             	mov    0xc(%ebp),%eax
 58d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 597:	8b 4d 10             	mov    0x10(%ebp),%ecx
 59a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 59d:	ba 00 00 00 00       	mov    $0x0,%edx
 5a2:	f7 f1                	div    %ecx
 5a4:	89 d1                	mov    %edx,%ecx
 5a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a9:	8d 50 01             	lea    0x1(%eax),%edx
 5ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5af:	0f b6 91 10 0d 00 00 	movzbl 0xd10(%ecx),%edx
 5b6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c0:	ba 00 00 00 00       	mov    $0x0,%edx
 5c5:	f7 f1                	div    %ecx
 5c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ce:	75 c7                	jne    597 <printint+0x37>
  if(neg)
 5d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d4:	74 2d                	je     603 <printint+0xa3>
    buf[i++] = '-';
 5d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d9:	8d 50 01             	lea    0x1(%eax),%edx
 5dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5df:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5e4:	eb 1d                	jmp    603 <printint+0xa3>
    putc(fd, buf[i]);
 5e6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ec:	01 d0                	add    %edx,%eax
 5ee:	0f b6 00             	movzbl (%eax),%eax
 5f1:	0f be c0             	movsbl %al,%eax
 5f4:	83 ec 08             	sub    $0x8,%esp
 5f7:	50                   	push   %eax
 5f8:	ff 75 08             	push   0x8(%ebp)
 5fb:	e8 3d ff ff ff       	call   53d <putc>
 600:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 603:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 607:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 60b:	79 d9                	jns    5e6 <printint+0x86>
}
 60d:	90                   	nop
 60e:	90                   	nop
 60f:	c9                   	leave  
 610:	c3                   	ret    

00000611 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 611:	55                   	push   %ebp
 612:	89 e5                	mov    %esp,%ebp
 614:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 617:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 61e:	8d 45 0c             	lea    0xc(%ebp),%eax
 621:	83 c0 04             	add    $0x4,%eax
 624:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 627:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 62e:	e9 59 01 00 00       	jmp    78c <printf+0x17b>
    c = fmt[i] & 0xff;
 633:	8b 55 0c             	mov    0xc(%ebp),%edx
 636:	8b 45 f0             	mov    -0x10(%ebp),%eax
 639:	01 d0                	add    %edx,%eax
 63b:	0f b6 00             	movzbl (%eax),%eax
 63e:	0f be c0             	movsbl %al,%eax
 641:	25 ff 00 00 00       	and    $0xff,%eax
 646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 649:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64d:	75 2c                	jne    67b <printf+0x6a>
      if(c == '%'){
 64f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 653:	75 0c                	jne    661 <printf+0x50>
        state = '%';
 655:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 65c:	e9 27 01 00 00       	jmp    788 <printf+0x177>
      } else {
        putc(fd, c);
 661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	83 ec 08             	sub    $0x8,%esp
 66a:	50                   	push   %eax
 66b:	ff 75 08             	push   0x8(%ebp)
 66e:	e8 ca fe ff ff       	call   53d <putc>
 673:	83 c4 10             	add    $0x10,%esp
 676:	e9 0d 01 00 00       	jmp    788 <printf+0x177>
      }
    } else if(state == '%'){
 67b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 67f:	0f 85 03 01 00 00    	jne    788 <printf+0x177>
      if(c == 'd'){
 685:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 689:	75 1e                	jne    6a9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 68b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68e:	8b 00                	mov    (%eax),%eax
 690:	6a 01                	push   $0x1
 692:	6a 0a                	push   $0xa
 694:	50                   	push   %eax
 695:	ff 75 08             	push   0x8(%ebp)
 698:	e8 c3 fe ff ff       	call   560 <printint>
 69d:	83 c4 10             	add    $0x10,%esp
        ap++;
 6a0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a4:	e9 d8 00 00 00       	jmp    781 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6a9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ad:	74 06                	je     6b5 <printf+0xa4>
 6af:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b3:	75 1e                	jne    6d3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	6a 00                	push   $0x0
 6bc:	6a 10                	push   $0x10
 6be:	50                   	push   %eax
 6bf:	ff 75 08             	push   0x8(%ebp)
 6c2:	e8 99 fe ff ff       	call   560 <printint>
 6c7:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ce:	e9 ae 00 00 00       	jmp    781 <printf+0x170>
      } else if(c == 's'){
 6d3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6d7:	75 43                	jne    71c <printf+0x10b>
        s = (char*)*ap;
 6d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e9:	75 25                	jne    710 <printf+0xff>
          s = "(null)";
 6eb:	c7 45 f4 22 0a 00 00 	movl   $0xa22,-0xc(%ebp)
        while(*s != 0){
 6f2:	eb 1c                	jmp    710 <printf+0xff>
          putc(fd, *s);
 6f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f7:	0f b6 00             	movzbl (%eax),%eax
 6fa:	0f be c0             	movsbl %al,%eax
 6fd:	83 ec 08             	sub    $0x8,%esp
 700:	50                   	push   %eax
 701:	ff 75 08             	push   0x8(%ebp)
 704:	e8 34 fe ff ff       	call   53d <putc>
 709:	83 c4 10             	add    $0x10,%esp
          s++;
 70c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	0f b6 00             	movzbl (%eax),%eax
 716:	84 c0                	test   %al,%al
 718:	75 da                	jne    6f4 <printf+0xe3>
 71a:	eb 65                	jmp    781 <printf+0x170>
        }
      } else if(c == 'c'){
 71c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 720:	75 1d                	jne    73f <printf+0x12e>
        putc(fd, *ap);
 722:	8b 45 e8             	mov    -0x18(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	0f be c0             	movsbl %al,%eax
 72a:	83 ec 08             	sub    $0x8,%esp
 72d:	50                   	push   %eax
 72e:	ff 75 08             	push   0x8(%ebp)
 731:	e8 07 fe ff ff       	call   53d <putc>
 736:	83 c4 10             	add    $0x10,%esp
        ap++;
 739:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73d:	eb 42                	jmp    781 <printf+0x170>
      } else if(c == '%'){
 73f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 743:	75 17                	jne    75c <printf+0x14b>
        putc(fd, c);
 745:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 748:	0f be c0             	movsbl %al,%eax
 74b:	83 ec 08             	sub    $0x8,%esp
 74e:	50                   	push   %eax
 74f:	ff 75 08             	push   0x8(%ebp)
 752:	e8 e6 fd ff ff       	call   53d <putc>
 757:	83 c4 10             	add    $0x10,%esp
 75a:	eb 25                	jmp    781 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 75c:	83 ec 08             	sub    $0x8,%esp
 75f:	6a 25                	push   $0x25
 761:	ff 75 08             	push   0x8(%ebp)
 764:	e8 d4 fd ff ff       	call   53d <putc>
 769:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 76c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76f:	0f be c0             	movsbl %al,%eax
 772:	83 ec 08             	sub    $0x8,%esp
 775:	50                   	push   %eax
 776:	ff 75 08             	push   0x8(%ebp)
 779:	e8 bf fd ff ff       	call   53d <putc>
 77e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 781:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 788:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 78c:	8b 55 0c             	mov    0xc(%ebp),%edx
 78f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 792:	01 d0                	add    %edx,%eax
 794:	0f b6 00             	movzbl (%eax),%eax
 797:	84 c0                	test   %al,%al
 799:	0f 85 94 fe ff ff    	jne    633 <printf+0x22>
    }
  }
}
 79f:	90                   	nop
 7a0:	90                   	nop
 7a1:	c9                   	leave  
 7a2:	c3                   	ret    

000007a3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a3:	55                   	push   %ebp
 7a4:	89 e5                	mov    %esp,%ebp
 7a6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ac:	83 e8 08             	sub    $0x8,%eax
 7af:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b2:	a1 88 8d 00 00       	mov    0x8d88,%eax
 7b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ba:	eb 24                	jmp    7e0 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bf:	8b 00                	mov    (%eax),%eax
 7c1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7c4:	72 12                	jb     7d8 <free+0x35>
 7c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cc:	77 24                	ja     7f2 <free+0x4f>
 7ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7d6:	72 1a                	jb     7f2 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e6:	76 d4                	jbe    7bc <free+0x19>
 7e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7eb:	8b 00                	mov    (%eax),%eax
 7ed:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7f0:	73 ca                	jae    7bc <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	8b 40 04             	mov    0x4(%eax),%eax
 7f8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 802:	01 c2                	add    %eax,%edx
 804:	8b 45 fc             	mov    -0x4(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	39 c2                	cmp    %eax,%edx
 80b:	75 24                	jne    831 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 80d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 810:	8b 50 04             	mov    0x4(%eax),%edx
 813:	8b 45 fc             	mov    -0x4(%ebp),%eax
 816:	8b 00                	mov    (%eax),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	01 c2                	add    %eax,%edx
 81d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 820:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 823:	8b 45 fc             	mov    -0x4(%ebp),%eax
 826:	8b 00                	mov    (%eax),%eax
 828:	8b 10                	mov    (%eax),%edx
 82a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82d:	89 10                	mov    %edx,(%eax)
 82f:	eb 0a                	jmp    83b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	8b 10                	mov    (%eax),%edx
 836:	8b 45 f8             	mov    -0x8(%ebp),%eax
 839:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 83b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83e:	8b 40 04             	mov    0x4(%eax),%eax
 841:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	01 d0                	add    %edx,%eax
 84d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 850:	75 20                	jne    872 <free+0xcf>
    p->s.size += bp->s.size;
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	8b 50 04             	mov    0x4(%eax),%edx
 858:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85b:	8b 40 04             	mov    0x4(%eax),%eax
 85e:	01 c2                	add    %eax,%edx
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 866:	8b 45 f8             	mov    -0x8(%ebp),%eax
 869:	8b 10                	mov    (%eax),%edx
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	89 10                	mov    %edx,(%eax)
 870:	eb 08                	jmp    87a <free+0xd7>
  } else
    p->s.ptr = bp;
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	8b 55 f8             	mov    -0x8(%ebp),%edx
 878:	89 10                	mov    %edx,(%eax)
  freep = p;
 87a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87d:	a3 88 8d 00 00       	mov    %eax,0x8d88
}
 882:	90                   	nop
 883:	c9                   	leave  
 884:	c3                   	ret    

00000885 <morecore>:

static Header*
morecore(uint nu)
{
 885:	55                   	push   %ebp
 886:	89 e5                	mov    %esp,%ebp
 888:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 88b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 892:	77 07                	ja     89b <morecore+0x16>
    nu = 4096;
 894:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 89b:	8b 45 08             	mov    0x8(%ebp),%eax
 89e:	c1 e0 03             	shl    $0x3,%eax
 8a1:	83 ec 0c             	sub    $0xc,%esp
 8a4:	50                   	push   %eax
 8a5:	e8 73 fc ff ff       	call   51d <sbrk>
 8aa:	83 c4 10             	add    $0x10,%esp
 8ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8b4:	75 07                	jne    8bd <morecore+0x38>
    return 0;
 8b6:	b8 00 00 00 00       	mov    $0x0,%eax
 8bb:	eb 26                	jmp    8e3 <morecore+0x5e>
  hp = (Header*)p;
 8bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c6:	8b 55 08             	mov    0x8(%ebp),%edx
 8c9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cf:	83 c0 08             	add    $0x8,%eax
 8d2:	83 ec 0c             	sub    $0xc,%esp
 8d5:	50                   	push   %eax
 8d6:	e8 c8 fe ff ff       	call   7a3 <free>
 8db:	83 c4 10             	add    $0x10,%esp
  return freep;
 8de:	a1 88 8d 00 00       	mov    0x8d88,%eax
}
 8e3:	c9                   	leave  
 8e4:	c3                   	ret    

000008e5 <malloc>:

void*
malloc(uint nbytes)
{
 8e5:	55                   	push   %ebp
 8e6:	89 e5                	mov    %esp,%ebp
 8e8:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8eb:	8b 45 08             	mov    0x8(%ebp),%eax
 8ee:	83 c0 07             	add    $0x7,%eax
 8f1:	c1 e8 03             	shr    $0x3,%eax
 8f4:	83 c0 01             	add    $0x1,%eax
 8f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8fa:	a1 88 8d 00 00       	mov    0x8d88,%eax
 8ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
 902:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 906:	75 23                	jne    92b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 908:	c7 45 f0 80 8d 00 00 	movl   $0x8d80,-0x10(%ebp)
 90f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 912:	a3 88 8d 00 00       	mov    %eax,0x8d88
 917:	a1 88 8d 00 00       	mov    0x8d88,%eax
 91c:	a3 80 8d 00 00       	mov    %eax,0x8d80
    base.s.size = 0;
 921:	c7 05 84 8d 00 00 00 	movl   $0x0,0x8d84
 928:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92e:	8b 00                	mov    (%eax),%eax
 930:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	8b 40 04             	mov    0x4(%eax),%eax
 939:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 93c:	77 4d                	ja     98b <malloc+0xa6>
      if(p->s.size == nunits)
 93e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 941:	8b 40 04             	mov    0x4(%eax),%eax
 944:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 947:	75 0c                	jne    955 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 949:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94c:	8b 10                	mov    (%eax),%edx
 94e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 951:	89 10                	mov    %edx,(%eax)
 953:	eb 26                	jmp    97b <malloc+0x96>
      else {
        p->s.size -= nunits;
 955:	8b 45 f4             	mov    -0xc(%ebp),%eax
 958:	8b 40 04             	mov    0x4(%eax),%eax
 95b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 95e:	89 c2                	mov    %eax,%edx
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 966:	8b 45 f4             	mov    -0xc(%ebp),%eax
 969:	8b 40 04             	mov    0x4(%eax),%eax
 96c:	c1 e0 03             	shl    $0x3,%eax
 96f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 972:	8b 45 f4             	mov    -0xc(%ebp),%eax
 975:	8b 55 ec             	mov    -0x14(%ebp),%edx
 978:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 97b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97e:	a3 88 8d 00 00       	mov    %eax,0x8d88
      return (void*)(p + 1);
 983:	8b 45 f4             	mov    -0xc(%ebp),%eax
 986:	83 c0 08             	add    $0x8,%eax
 989:	eb 3b                	jmp    9c6 <malloc+0xe1>
    }
    if(p == freep)
 98b:	a1 88 8d 00 00       	mov    0x8d88,%eax
 990:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 993:	75 1e                	jne    9b3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 995:	83 ec 0c             	sub    $0xc,%esp
 998:	ff 75 ec             	push   -0x14(%ebp)
 99b:	e8 e5 fe ff ff       	call   885 <morecore>
 9a0:	83 c4 10             	add    $0x10,%esp
 9a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9aa:	75 07                	jne    9b3 <malloc+0xce>
        return 0;
 9ac:	b8 00 00 00 00       	mov    $0x0,%eax
 9b1:	eb 13                	jmp    9c6 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	8b 00                	mov    (%eax),%eax
 9be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c1:	e9 6d ff ff ff       	jmp    933 <malloc+0x4e>
  }
}
 9c6:	c9                   	leave  
 9c7:	c3                   	ret    
