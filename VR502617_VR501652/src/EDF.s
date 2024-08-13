.section .data
.section .text
    .globl EDF

.type EDF, @function

EDF:
    push %ebp 
    movl %esp, %ebp 

    pushl $0                 # Index = Scadenza
    pushl 16(%ebp)           # Total Objects
    pushl 8(%ebp)            # ordiniArr
    call bubbleSort
    addl $12, %esp

    
_EDF_done:
    movl %ebp, %esp 
    pop %ebp 
    ret
