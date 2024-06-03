.section .data # TODO: Rember to cean up all the push and pop before turnin in the project
.section .text
    .globl _myPrint
    .globl _mySTDERR
    # .globl _openFile
    
.type _myPrint, @function   # pushl msg_len     msg_len<int>
	                        # pushl $msg        msg<char *>
	                        # call _myPrint
	                        # addl $8, %esp     reset esp
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

.type _myPrint, @function   # pushl msg_len     msg_len<int>
	                        # pushl $msg        msg<char *>
	                        # call _myPrint
	                        # addl $8, %esp     reset esp
_mySTDERR:
    push %ebp 
    movl %esp, %ebp 
	push %ebx
	push %eax
	push %ecx
	push %edx

    # Write syscall
    movl $4, %eax # syscall number for write()
    movl $2, %ebx # file descriptor for stdout
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
