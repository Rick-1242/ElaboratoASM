.section .data
.section .text
    .globl myPrint
    .globl mySTDERR
	.type myPrint, @function	# pushl $msg		# TODO: Should autocompute the lenght.
								# call myPrint
								# addl $4, %esp

	.type mySTDERR, @function   # pushl msg_len		# TODO: Should autocompute the lenght.
	                        	# pushl $msg
	                        	# call myPrint
	                        	# addl $8, %esp
    # .globl _openFile


	# movl $0,%ebx
	# movb ordiniArr + SCANDEZA_OFFSET(,%ebx, OBJECT_SIZE), %al
	# call _itoa # for output
	# call getArgs


	# leal ordiniArr(%ecx), %ebx
	# pushl %edx			# print(buffer)
	# pushl %ebx
	# call myPrint
	# addl $8, %esp	


myPrint:
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

mySTDERR:
    push %ebp 
    movl %esp, %ebp 
	push %ebx
	push %eax
	push %ecx
	push %edx

    # Write syscall
    movl $4, %eax # syscall number for write()
    movl $2, %ebx # file descriptor for stderr
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
