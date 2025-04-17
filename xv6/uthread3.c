#include "types.h"
#include "stat.h"
#include "user.h"

#define FREE    0x0
#define RUNNING 0x1
#define RUNNABLE 0x2
#define WAIT    0x3

#define STACK_SIZE 8192
#define MAX_THREAD 10

typedef struct thread thread_t, *thread_p;

struct thread {
  int tid;
  int sp;
  char stack[STACK_SIZE];
  int state;
};

static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;

extern void thread_switch(void);

static void thread_schedule(void) {
  thread_p t;
  next_thread = 0;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (!next_thread && current_thread->state == RUNNABLE)
    next_thread = current_thread;

  if (!next_thread) {
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }

  if (next_thread != current_thread) {
    next_thread->state = RUNNING;
    current_thread->state = RUNNABLE;
    thread_switch();
    current_thread = next_thread;
  }
}

void thread_init(void) {
  uthread_init(thread_schedule);
  for (int i = 0; i < MAX_THREAD; i++)
    all_thread[i].state = FREE;

  current_thread = &all_thread[0];
  current_thread->tid = 0;
  current_thread->state = RUNNING;
}

int thread_create(void (*func)()) {
  thread_p t;
  int tid;
  for (tid = 1; tid < MAX_THREAD; tid++) {
    if (all_thread[tid].state == FREE) {
      t = &all_thread[tid];
      t->tid = tid;
      t->sp = (int)(t->stack + STACK_SIZE);
      t->sp -= 4;
      *(int*)(t->sp) = (int)func;
      t->sp -= 32;
      t->state = RUNNABLE;
      return tid;
    }
  }
  return -1;
}

void thread_suspend(int tid) {
  if (tid <= 0 || tid >= MAX_THREAD) return;
  thread_p t = &all_thread[tid];
  if (t->state != RUNNABLE && t->state != RUNNING) return;

  printf(1, "[suspend] Suspending thread %d\n", tid);
  t->state = WAIT;
  if (t == current_thread)
    thread_schedule();
}

void thread_resume(int tid) {
  if (tid <= 0 || tid >= MAX_THREAD) return;
  thread_p t = &all_thread[tid];
  if (t->state == WAIT) {
    t->state = RUNNABLE;
    printf(1, "[resume] Resuming thread %d\n", tid);
  }
}

static void mythread(void) {
  int i;
  printf(1, "my thread running (tid=%d)\n", current_thread->tid);
  for (i = 0; i < 20; i++) {
    printf(1, "my thread %d\n", current_thread->tid);
    thread_schedule();
  }
  printf(1, "my thread: exit (tid=%d)\n", current_thread->tid);
  current_thread->state = FREE;
  thread_schedule();
}

static void main_thread(void) {
  int tid1, tid2;
  tid1 = thread_create(mythread);
  tid2 = thread_create(mythread);

  sleep(3);
  thread_suspend(tid1);
  sleep(3);
  thread_suspend(tid2);
  sleep(3);
  thread_resume(tid1);
  sleep(3);
  thread_resume(tid2);
  sleep(50);

  printf(1, "main thread: exit\n");
  current_thread->state = FREE;
  thread_schedule();

  exit();
}

int main(int argc, char *argv[]) {
  thread_init();
  thread_create(main_thread);
  thread_schedule();
  exit();
}