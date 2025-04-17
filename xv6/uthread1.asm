
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
  9b:	68 d4 09 00 00       	push   $0x9d4
  a0:	6a 02                	push   $0x2
  a2:	e8 73 05 00 00       	call   61a <printf>
  a7:	83 c4 10             	add    $0x10,%esp
    exit();
  aa:	e8 f7 03 00 00       	call   4a6 <exit>
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
 17f:	68 fa 09 00 00       	push   $0x9fa
 184:	6a 01                	push   $0x1
 186:	e8 8f 04 00 00       	call   61a <printf>
 18b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 18e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 195:	eb 21                	jmp    1b8 <mythread+0x42>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 197:	a1 40 0d 00 00       	mov    0xd40,%eax
 19c:	83 ec 04             	sub    $0x4,%esp
 19f:	50                   	push   %eax
 1a0:	68 0d 0a 00 00       	push   $0xa0d
 1a5:	6a 01                	push   $0x1
 1a7:	e8 6e 04 00 00       	call   61a <printf>
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
 1c1:	68 1d 0a 00 00       	push   $0xa1d
 1c6:	6a 01                	push   $0x1
 1c8:	e8 4d 04 00 00       	call   61a <printf>
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
 24d:	ff e4                	jmp    *%esp

0000024f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	57                   	push   %edi
 253:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 254:	8b 4d 08             	mov    0x8(%ebp),%ecx
 257:	8b 55 10             	mov    0x10(%ebp),%edx
 25a:	8b 45 0c             	mov    0xc(%ebp),%eax
 25d:	89 cb                	mov    %ecx,%ebx
 25f:	89 df                	mov    %ebx,%edi
 261:	89 d1                	mov    %edx,%ecx
 263:	fc                   	cld    
 264:	f3 aa                	rep stos %al,%es:(%edi)
 266:	89 ca                	mov    %ecx,%edx
 268:	89 fb                	mov    %edi,%ebx
 26a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 26d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 270:	90                   	nop
 271:	5b                   	pop    %ebx
 272:	5f                   	pop    %edi
 273:	5d                   	pop    %ebp
 274:	c3                   	ret    

00000275 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 281:	90                   	nop
 282:	8b 55 0c             	mov    0xc(%ebp),%edx
 285:	8d 42 01             	lea    0x1(%edx),%eax
 288:	89 45 0c             	mov    %eax,0xc(%ebp)
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	8d 48 01             	lea    0x1(%eax),%ecx
 291:	89 4d 08             	mov    %ecx,0x8(%ebp)
 294:	0f b6 12             	movzbl (%edx),%edx
 297:	88 10                	mov    %dl,(%eax)
 299:	0f b6 00             	movzbl (%eax),%eax
 29c:	84 c0                	test   %al,%al
 29e:	75 e2                	jne    282 <strcpy+0xd>
    ;
  return os;
 2a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2a8:	eb 08                	jmp    2b2 <strcmp+0xd>
    p++, q++;
 2aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ae:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2b2:	8b 45 08             	mov    0x8(%ebp),%eax
 2b5:	0f b6 00             	movzbl (%eax),%eax
 2b8:	84 c0                	test   %al,%al
 2ba:	74 10                	je     2cc <strcmp+0x27>
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	0f b6 10             	movzbl (%eax),%edx
 2c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	38 c2                	cmp    %al,%dl
 2ca:	74 de                	je     2aa <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	0f b6 d0             	movzbl %al,%edx
 2d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d8:	0f b6 00             	movzbl (%eax),%eax
 2db:	0f b6 c8             	movzbl %al,%ecx
 2de:	89 d0                	mov    %edx,%eax
 2e0:	29 c8                	sub    %ecx,%eax
}
 2e2:	5d                   	pop    %ebp
 2e3:	c3                   	ret    

000002e4 <strlen>:

uint
strlen(char *s)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2f1:	eb 04                	jmp    2f7 <strlen+0x13>
 2f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	01 d0                	add    %edx,%eax
 2ff:	0f b6 00             	movzbl (%eax),%eax
 302:	84 c0                	test   %al,%al
 304:	75 ed                	jne    2f3 <strlen+0xf>
    ;
  return n;
 306:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 309:	c9                   	leave  
 30a:	c3                   	ret    

0000030b <memset>:

void*
memset(void *dst, int c, uint n)
{
 30b:	55                   	push   %ebp
 30c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 30e:	8b 45 10             	mov    0x10(%ebp),%eax
 311:	50                   	push   %eax
 312:	ff 75 0c             	push   0xc(%ebp)
 315:	ff 75 08             	push   0x8(%ebp)
 318:	e8 32 ff ff ff       	call   24f <stosb>
 31d:	83 c4 0c             	add    $0xc,%esp
  return dst;
 320:	8b 45 08             	mov    0x8(%ebp),%eax
}
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <strchr>:

char*
strchr(const char *s, char c)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	83 ec 04             	sub    $0x4,%esp
 32b:	8b 45 0c             	mov    0xc(%ebp),%eax
 32e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 331:	eb 14                	jmp    347 <strchr+0x22>
    if(*s == c)
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	0f b6 00             	movzbl (%eax),%eax
 339:	38 45 fc             	cmp    %al,-0x4(%ebp)
 33c:	75 05                	jne    343 <strchr+0x1e>
      return (char*)s;
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	eb 13                	jmp    356 <strchr+0x31>
  for(; *s; s++)
 343:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	0f b6 00             	movzbl (%eax),%eax
 34d:	84 c0                	test   %al,%al
 34f:	75 e2                	jne    333 <strchr+0xe>
  return 0;
 351:	b8 00 00 00 00       	mov    $0x0,%eax
}
 356:	c9                   	leave  
 357:	c3                   	ret    

00000358 <gets>:

char*
gets(char *buf, int max)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 35e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 365:	eb 42                	jmp    3a9 <gets+0x51>
    cc = read(0, &c, 1);
 367:	83 ec 04             	sub    $0x4,%esp
 36a:	6a 01                	push   $0x1
 36c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 36f:	50                   	push   %eax
 370:	6a 00                	push   $0x0
 372:	e8 47 01 00 00       	call   4be <read>
 377:	83 c4 10             	add    $0x10,%esp
 37a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 37d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 381:	7e 33                	jle    3b6 <gets+0x5e>
      break;
    buf[i++] = c;
 383:	8b 45 f4             	mov    -0xc(%ebp),%eax
 386:	8d 50 01             	lea    0x1(%eax),%edx
 389:	89 55 f4             	mov    %edx,-0xc(%ebp)
 38c:	89 c2                	mov    %eax,%edx
 38e:	8b 45 08             	mov    0x8(%ebp),%eax
 391:	01 c2                	add    %eax,%edx
 393:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 397:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 399:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39d:	3c 0a                	cmp    $0xa,%al
 39f:	74 16                	je     3b7 <gets+0x5f>
 3a1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a5:	3c 0d                	cmp    $0xd,%al
 3a7:	74 0e                	je     3b7 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ac:	83 c0 01             	add    $0x1,%eax
 3af:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3b2:	7f b3                	jg     367 <gets+0xf>
 3b4:	eb 01                	jmp    3b7 <gets+0x5f>
      break;
 3b6:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	01 d0                	add    %edx,%eax
 3bf:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c5:	c9                   	leave  
 3c6:	c3                   	ret    

000003c7 <stat>:

int
stat(char *n, struct stat *st)
{
 3c7:	55                   	push   %ebp
 3c8:	89 e5                	mov    %esp,%ebp
 3ca:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3cd:	83 ec 08             	sub    $0x8,%esp
 3d0:	6a 00                	push   $0x0
 3d2:	ff 75 08             	push   0x8(%ebp)
 3d5:	e8 14 01 00 00       	call   4ee <open>
 3da:	83 c4 10             	add    $0x10,%esp
 3dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3e4:	79 07                	jns    3ed <stat+0x26>
    return -1;
 3e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3eb:	eb 25                	jmp    412 <stat+0x4b>
  r = fstat(fd, st);
 3ed:	83 ec 08             	sub    $0x8,%esp
 3f0:	ff 75 0c             	push   0xc(%ebp)
 3f3:	ff 75 f4             	push   -0xc(%ebp)
 3f6:	e8 0b 01 00 00       	call   506 <fstat>
 3fb:	83 c4 10             	add    $0x10,%esp
 3fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 401:	83 ec 0c             	sub    $0xc,%esp
 404:	ff 75 f4             	push   -0xc(%ebp)
 407:	e8 c2 00 00 00       	call   4ce <close>
 40c:	83 c4 10             	add    $0x10,%esp
  return r;
 40f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 412:	c9                   	leave  
 413:	c3                   	ret    

00000414 <atoi>:

int
atoi(const char *s)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
 417:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 41a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 421:	eb 25                	jmp    448 <atoi+0x34>
    n = n*10 + *s++ - '0';
 423:	8b 55 fc             	mov    -0x4(%ebp),%edx
 426:	89 d0                	mov    %edx,%eax
 428:	c1 e0 02             	shl    $0x2,%eax
 42b:	01 d0                	add    %edx,%eax
 42d:	01 c0                	add    %eax,%eax
 42f:	89 c1                	mov    %eax,%ecx
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	8d 50 01             	lea    0x1(%eax),%edx
 437:	89 55 08             	mov    %edx,0x8(%ebp)
 43a:	0f b6 00             	movzbl (%eax),%eax
 43d:	0f be c0             	movsbl %al,%eax
 440:	01 c8                	add    %ecx,%eax
 442:	83 e8 30             	sub    $0x30,%eax
 445:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	0f b6 00             	movzbl (%eax),%eax
 44e:	3c 2f                	cmp    $0x2f,%al
 450:	7e 0a                	jle    45c <atoi+0x48>
 452:	8b 45 08             	mov    0x8(%ebp),%eax
 455:	0f b6 00             	movzbl (%eax),%eax
 458:	3c 39                	cmp    $0x39,%al
 45a:	7e c7                	jle    423 <atoi+0xf>
  return n;
 45c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 45f:	c9                   	leave  
 460:	c3                   	ret    

00000461 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
 464:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 46d:	8b 45 0c             	mov    0xc(%ebp),%eax
 470:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 473:	eb 17                	jmp    48c <memmove+0x2b>
    *dst++ = *src++;
 475:	8b 55 f8             	mov    -0x8(%ebp),%edx
 478:	8d 42 01             	lea    0x1(%edx),%eax
 47b:	89 45 f8             	mov    %eax,-0x8(%ebp)
 47e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 481:	8d 48 01             	lea    0x1(%eax),%ecx
 484:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 487:	0f b6 12             	movzbl (%edx),%edx
 48a:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 48c:	8b 45 10             	mov    0x10(%ebp),%eax
 48f:	8d 50 ff             	lea    -0x1(%eax),%edx
 492:	89 55 10             	mov    %edx,0x10(%ebp)
 495:	85 c0                	test   %eax,%eax
 497:	7f dc                	jg     475 <memmove+0x14>
  return vdst;
 499:	8b 45 08             	mov    0x8(%ebp),%eax
}
 49c:	c9                   	leave  
 49d:	c3                   	ret    

0000049e <fork>:
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
 49e:	b8 01 00 00 00       	mov    $0x1,%eax
 4a3:	cd 40                	int    $0x40
 4a5:	c3                   	ret    

000004a6 <exit>:
SYSCALL(exit)
 4a6:	b8 02 00 00 00       	mov    $0x2,%eax
 4ab:	cd 40                	int    $0x40
 4ad:	c3                   	ret    

000004ae <wait>:
SYSCALL(wait)
 4ae:	b8 03 00 00 00       	mov    $0x3,%eax
 4b3:	cd 40                	int    $0x40
 4b5:	c3                   	ret    

000004b6 <pipe>:
SYSCALL(pipe)
 4b6:	b8 04 00 00 00       	mov    $0x4,%eax
 4bb:	cd 40                	int    $0x40
 4bd:	c3                   	ret    

000004be <read>:
SYSCALL(read)
 4be:	b8 05 00 00 00       	mov    $0x5,%eax
 4c3:	cd 40                	int    $0x40
 4c5:	c3                   	ret    

000004c6 <write>:
SYSCALL(write)
 4c6:	b8 10 00 00 00       	mov    $0x10,%eax
 4cb:	cd 40                	int    $0x40
 4cd:	c3                   	ret    

000004ce <close>:
SYSCALL(close)
 4ce:	b8 15 00 00 00       	mov    $0x15,%eax
 4d3:	cd 40                	int    $0x40
 4d5:	c3                   	ret    

000004d6 <kill>:
SYSCALL(kill)
 4d6:	b8 06 00 00 00       	mov    $0x6,%eax
 4db:	cd 40                	int    $0x40
 4dd:	c3                   	ret    

000004de <dup>:
SYSCALL(dup)
 4de:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e3:	cd 40                	int    $0x40
 4e5:	c3                   	ret    

000004e6 <exec>:
SYSCALL(exec)
 4e6:	b8 07 00 00 00       	mov    $0x7,%eax
 4eb:	cd 40                	int    $0x40
 4ed:	c3                   	ret    

000004ee <open>:
SYSCALL(open)
 4ee:	b8 0f 00 00 00       	mov    $0xf,%eax
 4f3:	cd 40                	int    $0x40
 4f5:	c3                   	ret    

000004f6 <mknod>:
SYSCALL(mknod)
 4f6:	b8 11 00 00 00       	mov    $0x11,%eax
 4fb:	cd 40                	int    $0x40
 4fd:	c3                   	ret    

000004fe <unlink>:
SYSCALL(unlink)
 4fe:	b8 12 00 00 00       	mov    $0x12,%eax
 503:	cd 40                	int    $0x40
 505:	c3                   	ret    

00000506 <fstat>:
SYSCALL(fstat)
 506:	b8 08 00 00 00       	mov    $0x8,%eax
 50b:	cd 40                	int    $0x40
 50d:	c3                   	ret    

0000050e <link>:
SYSCALL(link)
 50e:	b8 13 00 00 00       	mov    $0x13,%eax
 513:	cd 40                	int    $0x40
 515:	c3                   	ret    

00000516 <mkdir>:
SYSCALL(mkdir)
 516:	b8 14 00 00 00       	mov    $0x14,%eax
 51b:	cd 40                	int    $0x40
 51d:	c3                   	ret    

0000051e <chdir>:
SYSCALL(chdir)
 51e:	b8 09 00 00 00       	mov    $0x9,%eax
 523:	cd 40                	int    $0x40
 525:	c3                   	ret    

00000526 <sbrk>:
SYSCALL(sbrk)
 526:	b8 0c 00 00 00       	mov    $0xc,%eax
 52b:	cd 40                	int    $0x40
 52d:	c3                   	ret    

0000052e <sleep>:
SYSCALL(sleep)
 52e:	b8 0d 00 00 00       	mov    $0xd,%eax
 533:	cd 40                	int    $0x40
 535:	c3                   	ret    

00000536 <getpid>:
SYSCALL(getpid)
 536:	b8 0b 00 00 00       	mov    $0xb,%eax
 53b:	cd 40                	int    $0x40
 53d:	c3                   	ret    

0000053e <uthread_init>:
SYSCALL(uthread_init)
 53e:	b8 18 00 00 00       	mov    $0x18,%eax
 543:	cd 40                	int    $0x40
 545:	c3                   	ret    

00000546 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 546:	55                   	push   %ebp
 547:	89 e5                	mov    %esp,%ebp
 549:	83 ec 18             	sub    $0x18,%esp
 54c:	8b 45 0c             	mov    0xc(%ebp),%eax
 54f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 552:	83 ec 04             	sub    $0x4,%esp
 555:	6a 01                	push   $0x1
 557:	8d 45 f4             	lea    -0xc(%ebp),%eax
 55a:	50                   	push   %eax
 55b:	ff 75 08             	push   0x8(%ebp)
 55e:	e8 63 ff ff ff       	call   4c6 <write>
 563:	83 c4 10             	add    $0x10,%esp
}
 566:	90                   	nop
 567:	c9                   	leave  
 568:	c3                   	ret    

00000569 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 569:	55                   	push   %ebp
 56a:	89 e5                	mov    %esp,%ebp
 56c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 56f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 576:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 57a:	74 17                	je     593 <printint+0x2a>
 57c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 580:	79 11                	jns    593 <printint+0x2a>
    neg = 1;
 582:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 589:	8b 45 0c             	mov    0xc(%ebp),%eax
 58c:	f7 d8                	neg    %eax
 58e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 591:	eb 06                	jmp    599 <printint+0x30>
  } else {
    x = xx;
 593:	8b 45 0c             	mov    0xc(%ebp),%eax
 596:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a6:	ba 00 00 00 00       	mov    $0x0,%edx
 5ab:	f7 f1                	div    %ecx
 5ad:	89 d1                	mov    %edx,%ecx
 5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b2:	8d 50 01             	lea    0x1(%eax),%edx
 5b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b8:	0f b6 91 24 0d 00 00 	movzbl 0xd24(%ecx),%edx
 5bf:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c9:	ba 00 00 00 00       	mov    $0x0,%edx
 5ce:	f7 f1                	div    %ecx
 5d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d7:	75 c7                	jne    5a0 <printint+0x37>
  if(neg)
 5d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5dd:	74 2d                	je     60c <printint+0xa3>
    buf[i++] = '-';
 5df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e2:	8d 50 01             	lea    0x1(%eax),%edx
 5e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5e8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5ed:	eb 1d                	jmp    60c <printint+0xa3>
    putc(fd, buf[i]);
 5ef:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f5:	01 d0                	add    %edx,%eax
 5f7:	0f b6 00             	movzbl (%eax),%eax
 5fa:	0f be c0             	movsbl %al,%eax
 5fd:	83 ec 08             	sub    $0x8,%esp
 600:	50                   	push   %eax
 601:	ff 75 08             	push   0x8(%ebp)
 604:	e8 3d ff ff ff       	call   546 <putc>
 609:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 60c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 610:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 614:	79 d9                	jns    5ef <printint+0x86>
}
 616:	90                   	nop
 617:	90                   	nop
 618:	c9                   	leave  
 619:	c3                   	ret    

0000061a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 61a:	55                   	push   %ebp
 61b:	89 e5                	mov    %esp,%ebp
 61d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 620:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 627:	8d 45 0c             	lea    0xc(%ebp),%eax
 62a:	83 c0 04             	add    $0x4,%eax
 62d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 630:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 637:	e9 59 01 00 00       	jmp    795 <printf+0x17b>
    c = fmt[i] & 0xff;
 63c:	8b 55 0c             	mov    0xc(%ebp),%edx
 63f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 642:	01 d0                	add    %edx,%eax
 644:	0f b6 00             	movzbl (%eax),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	25 ff 00 00 00       	and    $0xff,%eax
 64f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 652:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 656:	75 2c                	jne    684 <printf+0x6a>
      if(c == '%'){
 658:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65c:	75 0c                	jne    66a <printf+0x50>
        state = '%';
 65e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 665:	e9 27 01 00 00       	jmp    791 <printf+0x177>
      } else {
        putc(fd, c);
 66a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66d:	0f be c0             	movsbl %al,%eax
 670:	83 ec 08             	sub    $0x8,%esp
 673:	50                   	push   %eax
 674:	ff 75 08             	push   0x8(%ebp)
 677:	e8 ca fe ff ff       	call   546 <putc>
 67c:	83 c4 10             	add    $0x10,%esp
 67f:	e9 0d 01 00 00       	jmp    791 <printf+0x177>
      }
    } else if(state == '%'){
 684:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 688:	0f 85 03 01 00 00    	jne    791 <printf+0x177>
      if(c == 'd'){
 68e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 692:	75 1e                	jne    6b2 <printf+0x98>
        printint(fd, *ap, 10, 1);
 694:	8b 45 e8             	mov    -0x18(%ebp),%eax
 697:	8b 00                	mov    (%eax),%eax
 699:	6a 01                	push   $0x1
 69b:	6a 0a                	push   $0xa
 69d:	50                   	push   %eax
 69e:	ff 75 08             	push   0x8(%ebp)
 6a1:	e8 c3 fe ff ff       	call   569 <printint>
 6a6:	83 c4 10             	add    $0x10,%esp
        ap++;
 6a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ad:	e9 d8 00 00 00       	jmp    78a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6b2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b6:	74 06                	je     6be <printf+0xa4>
 6b8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6bc:	75 1e                	jne    6dc <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c1:	8b 00                	mov    (%eax),%eax
 6c3:	6a 00                	push   $0x0
 6c5:	6a 10                	push   $0x10
 6c7:	50                   	push   %eax
 6c8:	ff 75 08             	push   0x8(%ebp)
 6cb:	e8 99 fe ff ff       	call   569 <printint>
 6d0:	83 c4 10             	add    $0x10,%esp
        ap++;
 6d3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d7:	e9 ae 00 00 00       	jmp    78a <printf+0x170>
      } else if(c == 's'){
 6dc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e0:	75 43                	jne    725 <printf+0x10b>
        s = (char*)*ap;
 6e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e5:	8b 00                	mov    (%eax),%eax
 6e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f2:	75 25                	jne    719 <printf+0xff>
          s = "(null)";
 6f4:	c7 45 f4 2e 0a 00 00 	movl   $0xa2e,-0xc(%ebp)
        while(*s != 0){
 6fb:	eb 1c                	jmp    719 <printf+0xff>
          putc(fd, *s);
 6fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 700:	0f b6 00             	movzbl (%eax),%eax
 703:	0f be c0             	movsbl %al,%eax
 706:	83 ec 08             	sub    $0x8,%esp
 709:	50                   	push   %eax
 70a:	ff 75 08             	push   0x8(%ebp)
 70d:	e8 34 fe ff ff       	call   546 <putc>
 712:	83 c4 10             	add    $0x10,%esp
          s++;
 715:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 719:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71c:	0f b6 00             	movzbl (%eax),%eax
 71f:	84 c0                	test   %al,%al
 721:	75 da                	jne    6fd <printf+0xe3>
 723:	eb 65                	jmp    78a <printf+0x170>
        }
      } else if(c == 'c'){
 725:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 729:	75 1d                	jne    748 <printf+0x12e>
        putc(fd, *ap);
 72b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72e:	8b 00                	mov    (%eax),%eax
 730:	0f be c0             	movsbl %al,%eax
 733:	83 ec 08             	sub    $0x8,%esp
 736:	50                   	push   %eax
 737:	ff 75 08             	push   0x8(%ebp)
 73a:	e8 07 fe ff ff       	call   546 <putc>
 73f:	83 c4 10             	add    $0x10,%esp
        ap++;
 742:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 746:	eb 42                	jmp    78a <printf+0x170>
      } else if(c == '%'){
 748:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74c:	75 17                	jne    765 <printf+0x14b>
        putc(fd, c);
 74e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 751:	0f be c0             	movsbl %al,%eax
 754:	83 ec 08             	sub    $0x8,%esp
 757:	50                   	push   %eax
 758:	ff 75 08             	push   0x8(%ebp)
 75b:	e8 e6 fd ff ff       	call   546 <putc>
 760:	83 c4 10             	add    $0x10,%esp
 763:	eb 25                	jmp    78a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 765:	83 ec 08             	sub    $0x8,%esp
 768:	6a 25                	push   $0x25
 76a:	ff 75 08             	push   0x8(%ebp)
 76d:	e8 d4 fd ff ff       	call   546 <putc>
 772:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 775:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 778:	0f be c0             	movsbl %al,%eax
 77b:	83 ec 08             	sub    $0x8,%esp
 77e:	50                   	push   %eax
 77f:	ff 75 08             	push   0x8(%ebp)
 782:	e8 bf fd ff ff       	call   546 <putc>
 787:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 78a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 791:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 795:	8b 55 0c             	mov    0xc(%ebp),%edx
 798:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79b:	01 d0                	add    %edx,%eax
 79d:	0f b6 00             	movzbl (%eax),%eax
 7a0:	84 c0                	test   %al,%al
 7a2:	0f 85 94 fe ff ff    	jne    63c <printf+0x22>
    }
  }
}
 7a8:	90                   	nop
 7a9:	90                   	nop
 7aa:	c9                   	leave  
 7ab:	c3                   	ret    

000007ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ac:	55                   	push   %ebp
 7ad:	89 e5                	mov    %esp,%ebp
 7af:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	8b 45 08             	mov    0x8(%ebp),%eax
 7b5:	83 e8 08             	sub    $0x8,%eax
 7b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bb:	a1 88 8d 00 00       	mov    0x8d88,%eax
 7c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c3:	eb 24                	jmp    7e9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7cd:	72 12                	jb     7e1 <free+0x35>
 7cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d5:	77 24                	ja     7fb <free+0x4f>
 7d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7da:	8b 00                	mov    (%eax),%eax
 7dc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7df:	72 1a                	jb     7fb <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ef:	76 d4                	jbe    7c5 <free+0x19>
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7f9:	73 ca                	jae    7c5 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fe:	8b 40 04             	mov    0x4(%eax),%eax
 801:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 808:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80b:	01 c2                	add    %eax,%edx
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	39 c2                	cmp    %eax,%edx
 814:	75 24                	jne    83a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 816:	8b 45 f8             	mov    -0x8(%ebp),%eax
 819:	8b 50 04             	mov    0x4(%eax),%edx
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	8b 40 04             	mov    0x4(%eax),%eax
 824:	01 c2                	add    %eax,%edx
 826:	8b 45 f8             	mov    -0x8(%ebp),%eax
 829:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 00                	mov    (%eax),%eax
 831:	8b 10                	mov    (%eax),%edx
 833:	8b 45 f8             	mov    -0x8(%ebp),%eax
 836:	89 10                	mov    %edx,(%eax)
 838:	eb 0a                	jmp    844 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 83a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83d:	8b 10                	mov    (%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 844:	8b 45 fc             	mov    -0x4(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	01 d0                	add    %edx,%eax
 856:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 859:	75 20                	jne    87b <free+0xcf>
    p->s.size += bp->s.size;
 85b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85e:	8b 50 04             	mov    0x4(%eax),%edx
 861:	8b 45 f8             	mov    -0x8(%ebp),%eax
 864:	8b 40 04             	mov    0x4(%eax),%eax
 867:	01 c2                	add    %eax,%edx
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	8b 10                	mov    (%eax),%edx
 874:	8b 45 fc             	mov    -0x4(%ebp),%eax
 877:	89 10                	mov    %edx,(%eax)
 879:	eb 08                	jmp    883 <free+0xd7>
  } else
    p->s.ptr = bp;
 87b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 881:	89 10                	mov    %edx,(%eax)
  freep = p;
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	a3 88 8d 00 00       	mov    %eax,0x8d88
}
 88b:	90                   	nop
 88c:	c9                   	leave  
 88d:	c3                   	ret    

0000088e <morecore>:

static Header*
morecore(uint nu)
{
 88e:	55                   	push   %ebp
 88f:	89 e5                	mov    %esp,%ebp
 891:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 894:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89b:	77 07                	ja     8a4 <morecore+0x16>
    nu = 4096;
 89d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a4:	8b 45 08             	mov    0x8(%ebp),%eax
 8a7:	c1 e0 03             	shl    $0x3,%eax
 8aa:	83 ec 0c             	sub    $0xc,%esp
 8ad:	50                   	push   %eax
 8ae:	e8 73 fc ff ff       	call   526 <sbrk>
 8b3:	83 c4 10             	add    $0x10,%esp
 8b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8bd:	75 07                	jne    8c6 <morecore+0x38>
    return 0;
 8bf:	b8 00 00 00 00       	mov    $0x0,%eax
 8c4:	eb 26                	jmp    8ec <morecore+0x5e>
  hp = (Header*)p;
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cf:	8b 55 08             	mov    0x8(%ebp),%edx
 8d2:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	83 c0 08             	add    $0x8,%eax
 8db:	83 ec 0c             	sub    $0xc,%esp
 8de:	50                   	push   %eax
 8df:	e8 c8 fe ff ff       	call   7ac <free>
 8e4:	83 c4 10             	add    $0x10,%esp
  return freep;
 8e7:	a1 88 8d 00 00       	mov    0x8d88,%eax
}
 8ec:	c9                   	leave  
 8ed:	c3                   	ret    

000008ee <malloc>:

void*
malloc(uint nbytes)
{
 8ee:	55                   	push   %ebp
 8ef:	89 e5                	mov    %esp,%ebp
 8f1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f4:	8b 45 08             	mov    0x8(%ebp),%eax
 8f7:	83 c0 07             	add    $0x7,%eax
 8fa:	c1 e8 03             	shr    $0x3,%eax
 8fd:	83 c0 01             	add    $0x1,%eax
 900:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 903:	a1 88 8d 00 00       	mov    0x8d88,%eax
 908:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90f:	75 23                	jne    934 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 911:	c7 45 f0 80 8d 00 00 	movl   $0x8d80,-0x10(%ebp)
 918:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91b:	a3 88 8d 00 00       	mov    %eax,0x8d88
 920:	a1 88 8d 00 00       	mov    0x8d88,%eax
 925:	a3 80 8d 00 00       	mov    %eax,0x8d80
    base.s.size = 0;
 92a:	c7 05 84 8d 00 00 00 	movl   $0x0,0x8d84
 931:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	8b 45 f0             	mov    -0x10(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 945:	77 4d                	ja     994 <malloc+0xa6>
      if(p->s.size == nunits)
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	8b 40 04             	mov    0x4(%eax),%eax
 94d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 950:	75 0c                	jne    95e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 952:	8b 45 f4             	mov    -0xc(%ebp),%eax
 955:	8b 10                	mov    (%eax),%edx
 957:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95a:	89 10                	mov    %edx,(%eax)
 95c:	eb 26                	jmp    984 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	8b 40 04             	mov    0x4(%eax),%eax
 964:	2b 45 ec             	sub    -0x14(%ebp),%eax
 967:	89 c2                	mov    %eax,%edx
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	8b 40 04             	mov    0x4(%eax),%eax
 975:	c1 e0 03             	shl    $0x3,%eax
 978:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 981:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	a3 88 8d 00 00       	mov    %eax,0x8d88
      return (void*)(p + 1);
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	83 c0 08             	add    $0x8,%eax
 992:	eb 3b                	jmp    9cf <malloc+0xe1>
    }
    if(p == freep)
 994:	a1 88 8d 00 00       	mov    0x8d88,%eax
 999:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99c:	75 1e                	jne    9bc <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 99e:	83 ec 0c             	sub    $0xc,%esp
 9a1:	ff 75 ec             	push   -0x14(%ebp)
 9a4:	e8 e5 fe ff ff       	call   88e <morecore>
 9a9:	83 c4 10             	add    $0x10,%esp
 9ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b3:	75 07                	jne    9bc <malloc+0xce>
        return 0;
 9b5:	b8 00 00 00 00       	mov    $0x0,%eax
 9ba:	eb 13                	jmp    9cf <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c5:	8b 00                	mov    (%eax),%eax
 9c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9ca:	e9 6d ff ff ff       	jmp    93c <malloc+0x4e>
  }
}
 9cf:	c9                   	leave  
 9d0:	c3                   	ret    
