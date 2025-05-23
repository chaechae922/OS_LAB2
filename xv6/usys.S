#include "syscall.h"
#include "traps.h"

#define SYSCALL(name) \
  .globl name;         \
  name:                \
    movl $SYS_##name, %eax; \
    int $T_SYSCALL;    \
    ret

SYSCALL(fork)
SYSCALL(exit)
SYSCALL(wait)
SYSCALL(pipe)
SYSCALL(read)
SYSCALL(write)
SYSCALL(close)
SYSCALL(kill)
SYSCALL(dup)
SYSCALL(exec)
SYSCALL(open)
SYSCALL(mknod)
SYSCALL(unlink)
SYSCALL(fstat)
SYSCALL(link)
SYSCALL(mkdir)
SYSCALL(chdir)
SYSCALL(sbrk)
SYSCALL(sleep)
SYSCALL(getpid)
SYSCALL(uthread_init)
