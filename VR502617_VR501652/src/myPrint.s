.section .data
.secion .text
    .globl myPrint
    
.type myPrint, @function
myPrint:
    pushl %ebp # store the current value of EBP on the stack
    movl %esp, %ebp # Make EBP point to top of stack

    # Write syscall
    movl $4, %eax # syscall number for write()
    movl $1, %ebx # file descriptor for stdout
    movl 8(%ebp), %ecx # Address of string to write
    movl 12(%ebp), %edx # number of bytes to write
    int $0x80

    movl %ebp, %esp # Restore the old value of ESP
    popl %ebp # Restore the old value of EBP
    ret # return