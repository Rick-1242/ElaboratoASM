.section .data # TODO: Rember to cean up all the push and pop before turnin in the project
.section .text
    .globl _myPrint
    # .globl _closeFile
    
.type _myPrint, @function
_myPrint:
    push %ebp 
    movl %esp, %ebp 
	push %ebx
	push %eax
	push %ecx
	push %edx

    # Write syscall
    movl $4, %eax # syscall number for write()
    movl $1, %ebx # file descriptor for stdout
    movl 8(%ebp), %ecx # Address of string to write
    movl 12(%ebp), %edx # number of bytes to write
    int $0x80

    pop %edx
	pop %ecx
	pop %eax
	pop %ebx
    movl %ebp, %esp 
    pop %ebp 
    ret 

# .type _closeFile, @function
# _closeFile:
#     push %ebp 
#     movl %esp, %ebp 
#     push %eax
#     push %ecx

#     movl $6, %eax        # syscall close
#     movl 8(%ebp), %ecx
#     int $0x80

#     pop %ecx
#     pop %eax
#     movl %ebp, %esp 
#     pop %ebp
#     ret

