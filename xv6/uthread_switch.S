    .text

    /*
      * save the old thread's registers,
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
    movl %esp, (%eax)              # current_thread->sp = %esp

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
    movl (%eax), %esp              # %esp = next_thread->sp

    movl %eax, current_thread
    popal
    
    # return to next thread's stack context
    ret