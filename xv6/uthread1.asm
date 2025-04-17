
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
thread_p  next_thread;
extern void thread_switch(void);

void 
thread_init(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   3:	c7 05 40 0d 00 00 60 	movl   $0xd60,0xd40
   a:	0d 00 00 
  current_thread->state = RUNNING;
   d:	a1 40 0d 00 00       	mov    0xd40,%eax
  12:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  19:	00 00 00 
}
  1c:	90                   	nop
  1d:	5d                   	pop    %ebp
  1e:	c3                   	ret    

0000001f <thread_schedule>:

static void 
thread_schedule(void)
{
  1f:	55                   	push   %ebp
  20:	89 e5                	mov    %esp,%ebp
  22:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  25:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
  2c:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  2f:	c7 45 f4 60 0d 00 00 	movl   $0xd60,-0xc(%ebp)
  36:	eb 29                	jmp    61 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  41:	83 f8 02             	cmp    $0x2,%eax
  44:	75 14                	jne    5a <thread_schedule+0x3b>
  46:	a1 40 0d 00 00       	mov    0xd40,%eax
  4b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4e:	74 0a                	je     5a <thread_schedule+0x3b>
      next_thread = t;
  50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  53:	a3 44 0d 00 00       	mov    %eax,0xd44
      break;
  58:	eb 11                	jmp    6b <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  5a:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  61:	b8 80 8d 00 00       	mov    $0x8d80,%eax
  66:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  69:	72 cd                	jb     38 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  6b:	b8 80 8d 00 00       	mov    $0x8d80,%eax
  70:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  73:	72 1a                	jb     8f <thread_schedule+0x70>
  75:	a1 40 0d 00 00       	mov    0xd40,%eax
  7a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  80:	83 f8 02             	cmp    $0x2,%eax
  83:	75 0a                	jne    8f <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  85:	a1 40 0d 00 00       	mov    0xd40,%eax
  8a:	a3 44 0d 00 00       	mov    %eax,0xd44
  }

  if (next_thread == 0) {
  8f:	a1 44 0d 00 00       	mov    0xd44,%eax
  94:	85 c0                	test   %eax,%eax
  96:	75 17                	jne    af <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  98:	83 ec 08             	sub    $0x8,%esp
  9b:	68 d0 09 00 00       	push   $0x9d0
  a0:	6a 02                	push   $0x2
  a2:	e8 72 05 00 00       	call   619 <printf>
  a7:	83 c4 10             	add    $0x10,%esp
    exit();
  aa:	e8 f6 03 00 00       	call   4a5 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  af:	8b 15 40 0d 00 00    	mov    0xd40,%edx
  b5:	a1 44 0d 00 00       	mov    0xd44,%eax
  ba:	39 c2                	cmp    %eax,%edx
  bc:	74 16                	je     d4 <thread_schedule+0xb5>
    next_thread->state = RUNNING;
  be:	a1 44 0d 00 00       	mov    0xd44,%eax
  c3:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ca:	00 00 00 
    thread_switch();
  cd:	e8 66 01 00 00       	call   238 <thread_switch>
  } else
    next_thread = 0;
}
  d2:	eb 0a                	jmp    de <thread_schedule+0xbf>
    next_thread = 0;
  d4:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
  db:	00 00 00 
}
  de:	90                   	nop
  df:	c9                   	leave  
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
 16e:	e8 ac fe ff ff       	call   1f <thread_schedule>
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
 17f:	68 f6 09 00 00       	push   $0x9f6
 184:	6a 01                	push   $0x1
 186:	e8 8e 04 00 00       	call   619 <printf>
 18b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 18e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 195:	eb 21                	jmp    1b8 <mythread+0x42>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 197:	a1 40 0d 00 00       	mov    0xd40,%eax
 19c:	83 ec 04             	sub    $0x4,%esp
 19f:	50                   	push   %eax
 1a0:	68 09 0a 00 00       	push   $0xa09
 1a5:	6a 01                	push   $0x1
 1a7:	e8 6d 04 00 00       	call   619 <printf>
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
 1c1:	68 19 0a 00 00       	push   $0xa19
 1c6:	6a 01                	push   $0x1
 1c8:	e8 4c 04 00 00       	call   619 <printf>
 1cd:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1d0:	a1 40 0d 00 00       	mov    0xd40,%eax
 1d5:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 1dc:	00 00 00 
  thread_schedule();
 1df:	e8 3b fe ff ff       	call   1f <thread_schedule>
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
 1f8:	e8 03 fe ff ff       	call   0 <thread_init>
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
 226:	e8 f4 fd ff ff       	call   1f <thread_schedule>
  return 0;
 22b:	b8 00 00 00 00       	mov    $0x0,%eax
 230:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 233:	c9                   	leave  
 234:	8d 61 fc             	lea    -0x4(%ecx),%esp
 237:	c3                   	ret    

00000238 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 238:	60                   	pusha  
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 239:	a1 40 0d 00 00       	mov    0xd40,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 23e:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 240:	a1 44 0d 00 00       	mov    0xd44,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 245:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 247:	a3 40 0d 00 00       	mov    %eax,0xd40
    popal
 24c:	61                   	popa   
    
    # return to next thread's stack context
 24d:	c3                   	ret    

0000024e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	57                   	push   %edi
 252:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 253:	8b 4d 08             	mov    0x8(%ebp),%ecx
 256:	8b 55 10             	mov    0x10(%ebp),%edx
 259:	8b 45 0c             	mov    0xc(%ebp),%eax
 25c:	89 cb                	mov    %ecx,%ebx
 25e:	89 df                	mov    %ebx,%edi
 260:	89 d1                	mov    %edx,%ecx
 262:	fc                   	cld    
 263:	f3 aa                	rep stos %al,%es:(%edi)
 265:	89 ca                	mov    %ecx,%edx
 267:	89 fb                	mov    %edi,%ebx
 269:	89 5d 08             	mov    %ebx,0x8(%ebp)
 26c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 26f:	90                   	nop
 270:	5b                   	pop    %ebx
 271:	5f                   	pop    %edi
 272:	5d                   	pop    %ebp
 273:	c3                   	ret    

00000274 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 280:	90                   	nop
 281:	8b 55 0c             	mov    0xc(%ebp),%edx
 284:	8d 42 01             	lea    0x1(%edx),%eax
 287:	89 45 0c             	mov    %eax,0xc(%ebp)
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	8d 48 01             	lea    0x1(%eax),%ecx
 290:	89 4d 08             	mov    %ecx,0x8(%ebp)
 293:	0f b6 12             	movzbl (%edx),%edx
 296:	88 10                	mov    %dl,(%eax)
 298:	0f b6 00             	movzbl (%eax),%eax
 29b:	84 c0                	test   %al,%al
 29d:	75 e2                	jne    281 <strcpy+0xd>
    ;
  return os;
 29f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a2:	c9                   	leave  
 2a3:	c3                   	ret    

000002a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a4:	55                   	push   %ebp
 2a5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2a7:	eb 08                	jmp    2b1 <strcmp+0xd>
    p++, q++;
 2a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	84 c0                	test   %al,%al
 2b9:	74 10                	je     2cb <strcmp+0x27>
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 10             	movzbl (%eax),%edx
 2c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c4:	0f b6 00             	movzbl (%eax),%eax
 2c7:	38 c2                	cmp    %al,%dl
 2c9:	74 de                	je     2a9 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	0f b6 00             	movzbl (%eax),%eax
 2d1:	0f b6 d0             	movzbl %al,%edx
 2d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d7:	0f b6 00             	movzbl (%eax),%eax
 2da:	0f b6 c8             	movzbl %al,%ecx
 2dd:	89 d0                	mov    %edx,%eax
 2df:	29 c8                	sub    %ecx,%eax
}
 2e1:	5d                   	pop    %ebp
 2e2:	c3                   	ret    

000002e3 <strlen>:

uint
strlen(char *s)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2f0:	eb 04                	jmp    2f6 <strlen+0x13>
 2f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	01 d0                	add    %edx,%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	84 c0                	test   %al,%al
 303:	75 ed                	jne    2f2 <strlen+0xf>
    ;
  return n;
 305:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 308:	c9                   	leave  
 309:	c3                   	ret    

0000030a <memset>:

void*
memset(void *dst, int c, uint n)
{
 30a:	55                   	push   %ebp
 30b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 30d:	8b 45 10             	mov    0x10(%ebp),%eax
 310:	50                   	push   %eax
 311:	ff 75 0c             	push   0xc(%ebp)
 314:	ff 75 08             	push   0x8(%ebp)
 317:	e8 32 ff ff ff       	call   24e <stosb>
 31c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 322:	c9                   	leave  
 323:	c3                   	ret    

00000324 <strchr>:

char*
strchr(const char *s, char c)
{
 324:	55                   	push   %ebp
 325:	89 e5                	mov    %esp,%ebp
 327:	83 ec 04             	sub    $0x4,%esp
 32a:	8b 45 0c             	mov    0xc(%ebp),%eax
 32d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 330:	eb 14                	jmp    346 <strchr+0x22>
    if(*s == c)
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	0f b6 00             	movzbl (%eax),%eax
 338:	38 45 fc             	cmp    %al,-0x4(%ebp)
 33b:	75 05                	jne    342 <strchr+0x1e>
      return (char*)s;
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	eb 13                	jmp    355 <strchr+0x31>
  for(; *s; s++)
 342:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	0f b6 00             	movzbl (%eax),%eax
 34c:	84 c0                	test   %al,%al
 34e:	75 e2                	jne    332 <strchr+0xe>
  return 0;
 350:	b8 00 00 00 00       	mov    $0x0,%eax
}
 355:	c9                   	leave  
 356:	c3                   	ret    

00000357 <gets>:

char*
gets(char *buf, int max)
{
 357:	55                   	push   %ebp
 358:	89 e5                	mov    %esp,%ebp
 35a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 35d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 364:	eb 42                	jmp    3a8 <gets+0x51>
    cc = read(0, &c, 1);
 366:	83 ec 04             	sub    $0x4,%esp
 369:	6a 01                	push   $0x1
 36b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 36e:	50                   	push   %eax
 36f:	6a 00                	push   $0x0
 371:	e8 47 01 00 00       	call   4bd <read>
 376:	83 c4 10             	add    $0x10,%esp
 379:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 37c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 380:	7e 33                	jle    3b5 <gets+0x5e>
      break;
    buf[i++] = c;
 382:	8b 45 f4             	mov    -0xc(%ebp),%eax
 385:	8d 50 01             	lea    0x1(%eax),%edx
 388:	89 55 f4             	mov    %edx,-0xc(%ebp)
 38b:	89 c2                	mov    %eax,%edx
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	01 c2                	add    %eax,%edx
 392:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 396:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 398:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39c:	3c 0a                	cmp    $0xa,%al
 39e:	74 16                	je     3b6 <gets+0x5f>
 3a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a4:	3c 0d                	cmp    $0xd,%al
 3a6:	74 0e                	je     3b6 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ab:	83 c0 01             	add    $0x1,%eax
 3ae:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3b1:	7f b3                	jg     366 <gets+0xf>
 3b3:	eb 01                	jmp    3b6 <gets+0x5f>
      break;
 3b5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	01 d0                	add    %edx,%eax
 3be:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c4:	c9                   	leave  
 3c5:	c3                   	ret    

000003c6 <stat>:

int
stat(char *n, struct stat *st)
{
 3c6:	55                   	push   %ebp
 3c7:	89 e5                	mov    %esp,%ebp
 3c9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3cc:	83 ec 08             	sub    $0x8,%esp
 3cf:	6a 00                	push   $0x0
 3d1:	ff 75 08             	push   0x8(%ebp)
 3d4:	e8 14 01 00 00       	call   4ed <open>
 3d9:	83 c4 10             	add    $0x10,%esp
 3dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3e3:	79 07                	jns    3ec <stat+0x26>
    return -1;
 3e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3ea:	eb 25                	jmp    411 <stat+0x4b>
  r = fstat(fd, st);
 3ec:	83 ec 08             	sub    $0x8,%esp
 3ef:	ff 75 0c             	push   0xc(%ebp)
 3f2:	ff 75 f4             	push   -0xc(%ebp)
 3f5:	e8 0b 01 00 00       	call   505 <fstat>
 3fa:	83 c4 10             	add    $0x10,%esp
 3fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 400:	83 ec 0c             	sub    $0xc,%esp
 403:	ff 75 f4             	push   -0xc(%ebp)
 406:	e8 c2 00 00 00       	call   4cd <close>
 40b:	83 c4 10             	add    $0x10,%esp
  return r;
 40e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <atoi>:

int
atoi(const char *s)
{
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 419:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 420:	eb 25                	jmp    447 <atoi+0x34>
    n = n*10 + *s++ - '0';
 422:	8b 55 fc             	mov    -0x4(%ebp),%edx
 425:	89 d0                	mov    %edx,%eax
 427:	c1 e0 02             	shl    $0x2,%eax
 42a:	01 d0                	add    %edx,%eax
 42c:	01 c0                	add    %eax,%eax
 42e:	89 c1                	mov    %eax,%ecx
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	8d 50 01             	lea    0x1(%eax),%edx
 436:	89 55 08             	mov    %edx,0x8(%ebp)
 439:	0f b6 00             	movzbl (%eax),%eax
 43c:	0f be c0             	movsbl %al,%eax
 43f:	01 c8                	add    %ecx,%eax
 441:	83 e8 30             	sub    $0x30,%eax
 444:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	0f b6 00             	movzbl (%eax),%eax
 44d:	3c 2f                	cmp    $0x2f,%al
 44f:	7e 0a                	jle    45b <atoi+0x48>
 451:	8b 45 08             	mov    0x8(%ebp),%eax
 454:	0f b6 00             	movzbl (%eax),%eax
 457:	3c 39                	cmp    $0x39,%al
 459:	7e c7                	jle    422 <atoi+0xf>
  return n;
 45b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 45e:	c9                   	leave  
 45f:	c3                   	ret    

00000460 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 466:	8b 45 08             	mov    0x8(%ebp),%eax
 469:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 46c:	8b 45 0c             	mov    0xc(%ebp),%eax
 46f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 472:	eb 17                	jmp    48b <memmove+0x2b>
    *dst++ = *src++;
 474:	8b 55 f8             	mov    -0x8(%ebp),%edx
 477:	8d 42 01             	lea    0x1(%edx),%eax
 47a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 47d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 480:	8d 48 01             	lea    0x1(%eax),%ecx
 483:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 486:	0f b6 12             	movzbl (%edx),%edx
 489:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 48b:	8b 45 10             	mov    0x10(%ebp),%eax
 48e:	8d 50 ff             	lea    -0x1(%eax),%edx
 491:	89 55 10             	mov    %edx,0x10(%ebp)
 494:	85 c0                	test   %eax,%eax
 496:	7f dc                	jg     474 <memmove+0x14>
  return vdst;
 498:	8b 45 08             	mov    0x8(%ebp),%eax
}
 49b:	c9                   	leave  
 49c:	c3                   	ret    

0000049d <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 49d:	b8 01 00 00 00       	mov    $0x1,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <exit>:
SYSCALL(exit)
 4a5:	b8 02 00 00 00       	mov    $0x2,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <wait>:
SYSCALL(wait)
 4ad:	b8 03 00 00 00       	mov    $0x3,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <pipe>:
SYSCALL(pipe)
 4b5:	b8 04 00 00 00       	mov    $0x4,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <read>:
SYSCALL(read)
 4bd:	b8 05 00 00 00       	mov    $0x5,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <write>:
SYSCALL(write)
 4c5:	b8 10 00 00 00       	mov    $0x10,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <close>:
SYSCALL(close)
 4cd:	b8 15 00 00 00       	mov    $0x15,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <kill>:
SYSCALL(kill)
 4d5:	b8 06 00 00 00       	mov    $0x6,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <dup>:
SYSCALL(dup)
 4dd:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <exec>:
SYSCALL(exec)
 4e5:	b8 07 00 00 00       	mov    $0x7,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <open>:
SYSCALL(open)
 4ed:	b8 0f 00 00 00       	mov    $0xf,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <mknod>:
SYSCALL(mknod)
 4f5:	b8 11 00 00 00       	mov    $0x11,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <unlink>:
SYSCALL(unlink)
 4fd:	b8 12 00 00 00       	mov    $0x12,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <fstat>:
SYSCALL(fstat)
 505:	b8 08 00 00 00       	mov    $0x8,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <link>:
SYSCALL(link)
 50d:	b8 13 00 00 00       	mov    $0x13,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <mkdir>:
SYSCALL(mkdir)
 515:	b8 14 00 00 00       	mov    $0x14,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret    

0000051d <chdir>:
SYSCALL(chdir)
 51d:	b8 09 00 00 00       	mov    $0x9,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret    

00000525 <sbrk>:
SYSCALL(sbrk)
 525:	b8 0c 00 00 00       	mov    $0xc,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret    

0000052d <sleep>:
SYSCALL(sleep)
 52d:	b8 0d 00 00 00       	mov    $0xd,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret    

00000535 <getpid>:
SYSCALL(getpid)
 535:	b8 0b 00 00 00       	mov    $0xb,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret    

0000053d <uthread_init>:
SYSCALL(uthread_init)
 53d:	b8 18 00 00 00       	mov    $0x18,%eax
 542:	cd 40                	int    $0x40
 544:	c3                   	ret    

00000545 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 545:	55                   	push   %ebp
 546:	89 e5                	mov    %esp,%ebp
 548:	83 ec 18             	sub    $0x18,%esp
 54b:	8b 45 0c             	mov    0xc(%ebp),%eax
 54e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 551:	83 ec 04             	sub    $0x4,%esp
 554:	6a 01                	push   $0x1
 556:	8d 45 f4             	lea    -0xc(%ebp),%eax
 559:	50                   	push   %eax
 55a:	ff 75 08             	push   0x8(%ebp)
 55d:	e8 63 ff ff ff       	call   4c5 <write>
 562:	83 c4 10             	add    $0x10,%esp
}
 565:	90                   	nop
 566:	c9                   	leave  
 567:	c3                   	ret    

00000568 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 568:	55                   	push   %ebp
 569:	89 e5                	mov    %esp,%ebp
 56b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 56e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 575:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 579:	74 17                	je     592 <printint+0x2a>
 57b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 57f:	79 11                	jns    592 <printint+0x2a>
    neg = 1;
 581:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 588:	8b 45 0c             	mov    0xc(%ebp),%eax
 58b:	f7 d8                	neg    %eax
 58d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 590:	eb 06                	jmp    598 <printint+0x30>
  } else {
    x = xx;
 592:	8b 45 0c             	mov    0xc(%ebp),%eax
 595:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 598:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 59f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a5:	ba 00 00 00 00       	mov    $0x0,%edx
 5aa:	f7 f1                	div    %ecx
 5ac:	89 d1                	mov    %edx,%ecx
 5ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b1:	8d 50 01             	lea    0x1(%eax),%edx
 5b4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b7:	0f b6 91 20 0d 00 00 	movzbl 0xd20(%ecx),%edx
 5be:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c8:	ba 00 00 00 00       	mov    $0x0,%edx
 5cd:	f7 f1                	div    %ecx
 5cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d6:	75 c7                	jne    59f <printint+0x37>
  if(neg)
 5d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5dc:	74 2d                	je     60b <printint+0xa3>
    buf[i++] = '-';
 5de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e1:	8d 50 01             	lea    0x1(%eax),%edx
 5e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5e7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5ec:	eb 1d                	jmp    60b <printint+0xa3>
    putc(fd, buf[i]);
 5ee:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f4:	01 d0                	add    %edx,%eax
 5f6:	0f b6 00             	movzbl (%eax),%eax
 5f9:	0f be c0             	movsbl %al,%eax
 5fc:	83 ec 08             	sub    $0x8,%esp
 5ff:	50                   	push   %eax
 600:	ff 75 08             	push   0x8(%ebp)
 603:	e8 3d ff ff ff       	call   545 <putc>
 608:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 60b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 60f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 613:	79 d9                	jns    5ee <printint+0x86>
}
 615:	90                   	nop
 616:	90                   	nop
 617:	c9                   	leave  
 618:	c3                   	ret    

00000619 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 619:	55                   	push   %ebp
 61a:	89 e5                	mov    %esp,%ebp
 61c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 61f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 626:	8d 45 0c             	lea    0xc(%ebp),%eax
 629:	83 c0 04             	add    $0x4,%eax
 62c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 62f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 636:	e9 59 01 00 00       	jmp    794 <printf+0x17b>
    c = fmt[i] & 0xff;
 63b:	8b 55 0c             	mov    0xc(%ebp),%edx
 63e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 641:	01 d0                	add    %edx,%eax
 643:	0f b6 00             	movzbl (%eax),%eax
 646:	0f be c0             	movsbl %al,%eax
 649:	25 ff 00 00 00       	and    $0xff,%eax
 64e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 651:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 655:	75 2c                	jne    683 <printf+0x6a>
      if(c == '%'){
 657:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65b:	75 0c                	jne    669 <printf+0x50>
        state = '%';
 65d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 664:	e9 27 01 00 00       	jmp    790 <printf+0x177>
      } else {
        putc(fd, c);
 669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66c:	0f be c0             	movsbl %al,%eax
 66f:	83 ec 08             	sub    $0x8,%esp
 672:	50                   	push   %eax
 673:	ff 75 08             	push   0x8(%ebp)
 676:	e8 ca fe ff ff       	call   545 <putc>
 67b:	83 c4 10             	add    $0x10,%esp
 67e:	e9 0d 01 00 00       	jmp    790 <printf+0x177>
      }
    } else if(state == '%'){
 683:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 687:	0f 85 03 01 00 00    	jne    790 <printf+0x177>
      if(c == 'd'){
 68d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 691:	75 1e                	jne    6b1 <printf+0x98>
        printint(fd, *ap, 10, 1);
 693:	8b 45 e8             	mov    -0x18(%ebp),%eax
 696:	8b 00                	mov    (%eax),%eax
 698:	6a 01                	push   $0x1
 69a:	6a 0a                	push   $0xa
 69c:	50                   	push   %eax
 69d:	ff 75 08             	push   0x8(%ebp)
 6a0:	e8 c3 fe ff ff       	call   568 <printint>
 6a5:	83 c4 10             	add    $0x10,%esp
        ap++;
 6a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ac:	e9 d8 00 00 00       	jmp    789 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6b1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b5:	74 06                	je     6bd <printf+0xa4>
 6b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6bb:	75 1e                	jne    6db <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	6a 00                	push   $0x0
 6c4:	6a 10                	push   $0x10
 6c6:	50                   	push   %eax
 6c7:	ff 75 08             	push   0x8(%ebp)
 6ca:	e8 99 fe ff ff       	call   568 <printint>
 6cf:	83 c4 10             	add    $0x10,%esp
        ap++;
 6d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d6:	e9 ae 00 00 00       	jmp    789 <printf+0x170>
      } else if(c == 's'){
 6db:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6df:	75 43                	jne    724 <printf+0x10b>
        s = (char*)*ap;
 6e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e4:	8b 00                	mov    (%eax),%eax
 6e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f1:	75 25                	jne    718 <printf+0xff>
          s = "(null)";
 6f3:	c7 45 f4 2a 0a 00 00 	movl   $0xa2a,-0xc(%ebp)
        while(*s != 0){
 6fa:	eb 1c                	jmp    718 <printf+0xff>
          putc(fd, *s);
 6fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ff:	0f b6 00             	movzbl (%eax),%eax
 702:	0f be c0             	movsbl %al,%eax
 705:	83 ec 08             	sub    $0x8,%esp
 708:	50                   	push   %eax
 709:	ff 75 08             	push   0x8(%ebp)
 70c:	e8 34 fe ff ff       	call   545 <putc>
 711:	83 c4 10             	add    $0x10,%esp
          s++;
 714:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 718:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71b:	0f b6 00             	movzbl (%eax),%eax
 71e:	84 c0                	test   %al,%al
 720:	75 da                	jne    6fc <printf+0xe3>
 722:	eb 65                	jmp    789 <printf+0x170>
        }
      } else if(c == 'c'){
 724:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 728:	75 1d                	jne    747 <printf+0x12e>
        putc(fd, *ap);
 72a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72d:	8b 00                	mov    (%eax),%eax
 72f:	0f be c0             	movsbl %al,%eax
 732:	83 ec 08             	sub    $0x8,%esp
 735:	50                   	push   %eax
 736:	ff 75 08             	push   0x8(%ebp)
 739:	e8 07 fe ff ff       	call   545 <putc>
 73e:	83 c4 10             	add    $0x10,%esp
        ap++;
 741:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 745:	eb 42                	jmp    789 <printf+0x170>
      } else if(c == '%'){
 747:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74b:	75 17                	jne    764 <printf+0x14b>
        putc(fd, c);
 74d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 750:	0f be c0             	movsbl %al,%eax
 753:	83 ec 08             	sub    $0x8,%esp
 756:	50                   	push   %eax
 757:	ff 75 08             	push   0x8(%ebp)
 75a:	e8 e6 fd ff ff       	call   545 <putc>
 75f:	83 c4 10             	add    $0x10,%esp
 762:	eb 25                	jmp    789 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 764:	83 ec 08             	sub    $0x8,%esp
 767:	6a 25                	push   $0x25
 769:	ff 75 08             	push   0x8(%ebp)
 76c:	e8 d4 fd ff ff       	call   545 <putc>
 771:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 777:	0f be c0             	movsbl %al,%eax
 77a:	83 ec 08             	sub    $0x8,%esp
 77d:	50                   	push   %eax
 77e:	ff 75 08             	push   0x8(%ebp)
 781:	e8 bf fd ff ff       	call   545 <putc>
 786:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 789:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 790:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 794:	8b 55 0c             	mov    0xc(%ebp),%edx
 797:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79a:	01 d0                	add    %edx,%eax
 79c:	0f b6 00             	movzbl (%eax),%eax
 79f:	84 c0                	test   %al,%al
 7a1:	0f 85 94 fe ff ff    	jne    63b <printf+0x22>
    }
  }
}
 7a7:	90                   	nop
 7a8:	90                   	nop
 7a9:	c9                   	leave  
 7aa:	c3                   	ret    

000007ab <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ab:	55                   	push   %ebp
 7ac:	89 e5                	mov    %esp,%ebp
 7ae:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b1:	8b 45 08             	mov    0x8(%ebp),%eax
 7b4:	83 e8 08             	sub    $0x8,%eax
 7b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	a1 88 8d 00 00       	mov    0x8d88,%eax
 7bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c2:	eb 24                	jmp    7e8 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c7:	8b 00                	mov    (%eax),%eax
 7c9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7cc:	72 12                	jb     7e0 <free+0x35>
 7ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d4:	77 24                	ja     7fa <free+0x4f>
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	8b 00                	mov    (%eax),%eax
 7db:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7de:	72 1a                	jb     7fa <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7eb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ee:	76 d4                	jbe    7c4 <free+0x19>
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7f8:	73 ca                	jae    7c4 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fd:	8b 40 04             	mov    0x4(%eax),%eax
 800:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	01 c2                	add    %eax,%edx
 80c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80f:	8b 00                	mov    (%eax),%eax
 811:	39 c2                	cmp    %eax,%edx
 813:	75 24                	jne    839 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	8b 50 04             	mov    0x4(%eax),%edx
 81b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81e:	8b 00                	mov    (%eax),%eax
 820:	8b 40 04             	mov    0x4(%eax),%eax
 823:	01 c2                	add    %eax,%edx
 825:	8b 45 f8             	mov    -0x8(%ebp),%eax
 828:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82e:	8b 00                	mov    (%eax),%eax
 830:	8b 10                	mov    (%eax),%edx
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	89 10                	mov    %edx,(%eax)
 837:	eb 0a                	jmp    843 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 10                	mov    (%eax),%edx
 83e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 841:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 40 04             	mov    0x4(%eax),%eax
 849:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	01 d0                	add    %edx,%eax
 855:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 858:	75 20                	jne    87a <free+0xcf>
    p->s.size += bp->s.size;
 85a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85d:	8b 50 04             	mov    0x4(%eax),%edx
 860:	8b 45 f8             	mov    -0x8(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	01 c2                	add    %eax,%edx
 868:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 86e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 871:	8b 10                	mov    (%eax),%edx
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	89 10                	mov    %edx,(%eax)
 878:	eb 08                	jmp    882 <free+0xd7>
  } else
    p->s.ptr = bp;
 87a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 880:	89 10                	mov    %edx,(%eax)
  freep = p;
 882:	8b 45 fc             	mov    -0x4(%ebp),%eax
 885:	a3 88 8d 00 00       	mov    %eax,0x8d88
}
 88a:	90                   	nop
 88b:	c9                   	leave  
 88c:	c3                   	ret    

0000088d <morecore>:

static Header*
morecore(uint nu)
{
 88d:	55                   	push   %ebp
 88e:	89 e5                	mov    %esp,%ebp
 890:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 893:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89a:	77 07                	ja     8a3 <morecore+0x16>
    nu = 4096;
 89c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a3:	8b 45 08             	mov    0x8(%ebp),%eax
 8a6:	c1 e0 03             	shl    $0x3,%eax
 8a9:	83 ec 0c             	sub    $0xc,%esp
 8ac:	50                   	push   %eax
 8ad:	e8 73 fc ff ff       	call   525 <sbrk>
 8b2:	83 c4 10             	add    $0x10,%esp
 8b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8bc:	75 07                	jne    8c5 <morecore+0x38>
    return 0;
 8be:	b8 00 00 00 00       	mov    $0x0,%eax
 8c3:	eb 26                	jmp    8eb <morecore+0x5e>
  hp = (Header*)p;
 8c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ce:	8b 55 08             	mov    0x8(%ebp),%edx
 8d1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d7:	83 c0 08             	add    $0x8,%eax
 8da:	83 ec 0c             	sub    $0xc,%esp
 8dd:	50                   	push   %eax
 8de:	e8 c8 fe ff ff       	call   7ab <free>
 8e3:	83 c4 10             	add    $0x10,%esp
  return freep;
 8e6:	a1 88 8d 00 00       	mov    0x8d88,%eax
}
 8eb:	c9                   	leave  
 8ec:	c3                   	ret    

000008ed <malloc>:

void*
malloc(uint nbytes)
{
 8ed:	55                   	push   %ebp
 8ee:	89 e5                	mov    %esp,%ebp
 8f0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f3:	8b 45 08             	mov    0x8(%ebp),%eax
 8f6:	83 c0 07             	add    $0x7,%eax
 8f9:	c1 e8 03             	shr    $0x3,%eax
 8fc:	83 c0 01             	add    $0x1,%eax
 8ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 902:	a1 88 8d 00 00       	mov    0x8d88,%eax
 907:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90e:	75 23                	jne    933 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 910:	c7 45 f0 80 8d 00 00 	movl   $0x8d80,-0x10(%ebp)
 917:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91a:	a3 88 8d 00 00       	mov    %eax,0x8d88
 91f:	a1 88 8d 00 00       	mov    0x8d88,%eax
 924:	a3 80 8d 00 00       	mov    %eax,0x8d80
    base.s.size = 0;
 929:	c7 05 84 8d 00 00 00 	movl   $0x0,0x8d84
 930:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 933:	8b 45 f0             	mov    -0x10(%ebp),%eax
 936:	8b 00                	mov    (%eax),%eax
 938:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93e:	8b 40 04             	mov    0x4(%eax),%eax
 941:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 944:	77 4d                	ja     993 <malloc+0xa6>
      if(p->s.size == nunits)
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	8b 40 04             	mov    0x4(%eax),%eax
 94c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 94f:	75 0c                	jne    95d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 951:	8b 45 f4             	mov    -0xc(%ebp),%eax
 954:	8b 10                	mov    (%eax),%edx
 956:	8b 45 f0             	mov    -0x10(%ebp),%eax
 959:	89 10                	mov    %edx,(%eax)
 95b:	eb 26                	jmp    983 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	8b 40 04             	mov    0x4(%eax),%eax
 963:	2b 45 ec             	sub    -0x14(%ebp),%eax
 966:	89 c2                	mov    %eax,%edx
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 96e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 971:	8b 40 04             	mov    0x4(%eax),%eax
 974:	c1 e0 03             	shl    $0x3,%eax
 977:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 980:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 983:	8b 45 f0             	mov    -0x10(%ebp),%eax
 986:	a3 88 8d 00 00       	mov    %eax,0x8d88
      return (void*)(p + 1);
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	83 c0 08             	add    $0x8,%eax
 991:	eb 3b                	jmp    9ce <malloc+0xe1>
    }
    if(p == freep)
 993:	a1 88 8d 00 00       	mov    0x8d88,%eax
 998:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99b:	75 1e                	jne    9bb <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 99d:	83 ec 0c             	sub    $0xc,%esp
 9a0:	ff 75 ec             	push   -0x14(%ebp)
 9a3:	e8 e5 fe ff ff       	call   88d <morecore>
 9a8:	83 c4 10             	add    $0x10,%esp
 9ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b2:	75 07                	jne    9bb <malloc+0xce>
        return 0;
 9b4:	b8 00 00 00 00       	mov    $0x0,%eax
 9b9:	eb 13                	jmp    9ce <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9be:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c4:	8b 00                	mov    (%eax),%eax
 9c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c9:	e9 6d ff ff ff       	jmp    93b <malloc+0x4e>
  }
}
 9ce:	c9                   	leave  
 9cf:	c3                   	ret    
