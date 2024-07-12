.section .data
.section .text
    .globl EDF

.type EDF, @function
EDF:
    push %ebp 
    movl %esp, %ebp 

    # algo

    movl %ebp, %esp 
    pop %ebp 
    ret
