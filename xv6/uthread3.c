// uthread_suspend_resume_balanced.c
#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread */
#define FREE      0x0
#define RUNNING   0x1
#define RUNNABLE  0x2
#define WAIT      0x3

#define STACK_SIZE 8192
#define MAX_THREAD 10

typedef struct thread thread_t, *thread_p;

struct thread {
  int sp;                   // saved stack pointer
  char stack[STACK_SIZE];   // thread stack
  int state;                // FREE, RUNNING, RUNNABLE, WAIT
  int tid;                  // thread id
};

static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;
extern void thread_switch(void);

// Core scheduler: pick RUNNABLE != current, round-robin
static void
thread_schedule(void)
{
  thread_p prev = current_thread;
  int start = prev - all_thread;

  for (int i = 1; i < MAX_THREAD; i++) {
    int idx = (start + i) % MAX_THREAD;
    if (all_thread[idx].state == RUNNABLE) {
      next_thread = &all_thread[idx];
      if (prev->state == RUNNING)
        prev->state = RUNNABLE;
      next_thread->state = RUNNING;
      thread_switch();
      current_thread = next_thread;
      return;
    }
  }

  // 아무것도 없으면 종료
  for (int i = 0; i < MAX_THREAD; i++) {
    if (all_thread[i].state == RUNNABLE || all_thread[i].state == WAIT)
      return;
  }

  printf(2, "thread_schedule: no runnable threads\n");
  exit();
}

// Initialize main thread
void
thread_init(void)
{
  for (int i = 0; i < MAX_THREAD; i++)
    all_thread[i].state = FREE;
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid = 0;
}

// Create a new thread, return tid
int
thread_create(void (*func)())
{
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
    if (t->state == FREE)
      break;
  if (t == all_thread + MAX_THREAD)
    return -1;
  t->tid = t - all_thread;
  t->sp = (int)(t->stack + STACK_SIZE);
  t->sp -= 4;                  // return addr
  *((int*)(t->sp)) = (int)func;
  t->sp -= 32;                 // space for regs
  t->state = RUNNABLE;
  return t->tid;
}

// Yield CPU
void
thread_yield(void)
{
  thread_schedule();
}

// User-level sleep
void
thread_sleep(int ticks)
{
  for (int i = 0; i < ticks; i++)
    thread_yield();
}

// Suspend a thread and immediately reschedule
void
thread_suspend(int tid)
{
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if ((t->state == RUNNABLE || t->state == RUNNING) && t->tid == tid) {
      t->state = WAIT;
      printf(1, "[suspend] Suspending thread %d\n", tid);
      if (t == current_thread) {
        thread_schedule();
      }
      return;
    }
  }
}

// Resume a suspended thread (doesn't switch immediately)
void
thread_resume(int tid)
{
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == WAIT && t->tid == tid) {
      t->state = RUNNABLE;
      printf(1, "[resume] Resuming thread %d\n", tid);
      return;
    }
  }
}

// Thread function: print tid and count
static void
mythread(void)
{
  printf(1, "my thread running (tid=%d)\n", current_thread->tid);
  for (int i = 0; i < 100; i++) {
    printf(1, "my thread %d\n", current_thread->tid);
    thread_yield();
  }
  printf(1, "My thread: exit\n");
  current_thread->state = FREE;
  thread_schedule();
}

// Main: create threads, demo suspend/resume with interleaving
int
main(int argc, char *argv[])
{
  int tid1, tid2;
  thread_init();
  tid1 = thread_create(mythread);
  tid2 = thread_create(mythread);

  thread_sleep(3);

  thread_suspend(tid1);
  thread_sleep(3);

  thread_suspend(tid2);
  thread_sleep(3);

  thread_resume(tid1);
  thread_sleep(3);

  thread_resume(tid2);
  thread_sleep(100);

  thread_schedule();

  exit();
}