#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread */
#define FREE     0x0
#define RUNNING  0x1
#define RUNNABLE 0x2
#define WAIT     0x3

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread {
  int sp;        /* saved stack pointer */
  int tid;       /* thread id */
  int ptid;      /* parent thread id */
  int state;     /* FREE, RUNNING, RUNNABLE, WAIT */
  char stack[STACK_SIZE];
};

static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;

extern void thread_switch(void);

static void thread_schedule(void);

// Scheduler implementation
static void
thread_schedule(void)
{
  thread_p prev = current_thread;
  thread_p nxt = 0;

  // Find another runnable thread
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != prev) {
      nxt = t;
      break;
    }
  }
  // If none found, maybe run self
  if (!nxt && prev->state == RUNNABLE)
    nxt = prev;

  if (!nxt) {
    // No work left
    exit();
  }

  if (nxt != prev) {
    // Context switch
    if (prev->state == RUNNING)
      prev->state = RUNNABLE;
    nxt->state = RUNNING;
    next_thread = nxt;
    thread_switch();
    current_thread = nxt;
  }
}

void
thread_init(void)
{
  // main thread as tid 0
  current_thread = &all_thread[0];
  current_thread->tid   = 0;
  current_thread->ptid  = 0;
  current_thread->state = RUNNING;

  uthread_init(thread_schedule);
}

int
thread_create(void (*func)())
{
  // Find free slot
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }
  if (t == all_thread + MAX_THREAD)
    return -1;

  int new_tid = t - all_thread;
  t->tid  = new_tid;
  t->ptid = current_thread->tid;
  t->sp = (int)(t->stack + STACK_SIZE);
  t->sp -= 4;
  *(int*)(t->sp) = (int)func;
  t->sp -= 32;
  t->state = RUNNABLE;
  return new_tid;
}

void
thread_yield(void)
{
  if (current_thread->state == RUNNING)
    current_thread->state = RUNNABLE;
  thread_schedule();
}

// Wait for a specific child thread to finish
int
thread_join(int tid)
{
  // Validate tid
  if (tid < 0 || tid >= MAX_THREAD)
    return -1;
  thread_p child = &all_thread[tid];
  if (child->ptid != current_thread->tid)
    return -1;

  // Block until child->state becomes FREE
  while (child->state != FREE) {
    current_thread->state = WAIT;
    thread_schedule();
    current_thread->state = RUNNING;
  }
  return 0;
}

// Example child function
static void
child_thread(void)
{
  printf(1, "child thread running\n");
  for (int i = 0; i < 100; i++)
    printf(1, "child thread 0x%x\n", (int)current_thread);
  printf(1, "child thread: exit\n");
  current_thread->state = FREE;
  thread_schedule();
}

// Example parent function
static void
mythread(void)
{
  printf(1, "my thread running\n");
  int tids[5];
  for (int i = 0; i < 5; i++) {
    tids[i] = thread_create(child_thread);
  }
  for (int i = 0; i < 5; i++) {
    thread_join(tids[i]);
  }
  printf(1, "my thread: exit\n");
  current_thread->state = FREE;
  thread_schedule();
}

int
main(int argc, char *argv[])
{
  thread_init();
  int tid = thread_create(mythread);
  thread_join(tid);
  exit();
}