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

// User-level scheduler entry point registration
// Signature matches user.h: int uthread_init(void (*func)());
static void thread_schedule(void);


static void
thread_schedule(void)
{
  thread_p prev = current_thread;
  thread_p next = 0;

  // 1) RUNNABLE 상태인 다른 스레드 찾기
  for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != prev) {
      next = t;
      break;
    }
  }
  // 2) 없다면 자기 자신이라도 다시 돌리고
  if (!next && prev->state == RUNNABLE)
    next = prev;

  // 3) 진짜 없으면 종료
  if (!next) {
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }

  // 4) 전환할 게 있으면
  if (next != prev) {

    // 상태 갱신
    if(prev->state == RUNNING) prev->state = RUNNABLE;
    next->state = RUNNING;

    // 어셈블리로 스택 포인터 저장/로드할 때 쓸 대상 지정
    next_thread = next;

    // 실제 컨텍스트 스위치 (스택 포인터 교체)
    thread_switch();

    // --- 여기부터는 “새 스레드” 문맥에서 실행됩니다 ---
    current_thread = next;
    return;
  }
}
// Initialize threading library
void thread_init(void) {
  // Set up main thread as thread 0
  current_thread = &all_thread[0];
  current_thread->tid   = 0;
  current_thread->ptid  = 0;
  current_thread->state = RUNNING;

  // Register scheduler callback (function pointer)
  uthread_init(thread_schedule);
}

// Create a new thread to run func()
int thread_create(void (*func)()) {
  thread_p t;
  // Find a free slot
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }
  if (t == all_thread + MAX_THREAD)
    return -1; // no space

  int new_tid = t - all_thread;
  t->tid  = new_tid;
  t->ptid = current_thread->tid;

  // Prepare stack for initial context
  t->sp = (int)(t->stack + STACK_SIZE);
  t->sp -= 4;
  *(int*)(t->sp) = (int)func;   // return address -> func
  t->sp -= 32;                  // space for registers

  t->state = RUNNABLE;
  return new_tid;
}

// Yield execution to scheduler
void thread_yield(void) {
  if (current_thread->state == RUNNING)
    current_thread->state = RUNNABLE;
  thread_schedule();
}

// Wait for all child threads (ptid == current_thread->tid) to finish
void thread_join_all(void) {
  int found;
  do {
    found = 0;
    for (thread_p t = all_thread; t < all_thread + MAX_THREAD; t++) {
        if (t->ptid == current_thread->tid
                      && t->tid != current_thread->tid   // 자기 자신 건너뛰기
                      && t->state != FREE) {
        found = 1;
        break;
      }
    }
    if (found) {
      current_thread->state = WAIT; 
      thread_schedule();
      current_thread->state = RUNNING;
    }
  } while (found);
}

static void child_thread(void) {
  printf(1, "child thread running\n");
  for (int i = 0; i < 100; i++) {
    printf(1, "child thread 0x%x\n", (int)current_thread);
  }
  printf(1, "child thread: exit\n");
  current_thread->state = FREE;
  thread_schedule();
}

static void mythread(void) {
  printf(1, "my thread running\n");
  for (int i = 0; i < 5; i++) {
    thread_create(child_thread);
  }
  thread_join_all();
  printf(1, "my thread: exit\n");
  current_thread->state = FREE;
  thread_schedule();
}

int main(int argc, char *argv[]) {
  thread_init();
  thread_create(mythread);
  thread_join_all();
  exit();
}