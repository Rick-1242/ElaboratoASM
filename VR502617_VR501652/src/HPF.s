.section .data
.section .text
    .globl HPF

.type HPF, @function
HPF:
    push %ebp 
    movl %esp, %ebp 

    # algo

    movl %ebp, %esp 
    pop %ebp 
    ret
