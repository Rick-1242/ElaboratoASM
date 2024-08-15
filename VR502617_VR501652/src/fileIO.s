.section .data 
    #---------File I/O--------------
    fd: .long 0
    buffer: .ascii ""       # Spazio per il buffer di input
    #---------Testo-------------
    invalidFilenameMSG: .asciz "specificare un filename come argomento e che questo esista\n"
    overFlowMSG: .asciz "Overflow rilevato, si assicuri che i valori e la formattazione del file in input rispetti le specifiche del progetto\n"
    NAN: .asciz "One of the values provided is Not A Number\n"


.section .text
    .globl openFile
    .type openFile, @function

openFile:
    push %ebp 
    movl %esp, %ebp 

    # 16(%ebp) == fileName
    # 12(%ebp) == writeFile
    # 8(%ebp) ==  &ordiniArr

    
    movl $5, %eax       	# Syscall open
	movl 16(%ebp), %ebx		# Filename
    movzbl 12(%ebp), %ecx	# read || write -> this will have to be read || append
    int $0x80

    cmpl $0, %eax 			# Se c'è un errore in apertura da errore
    jl _invalidFilename
	movl %eax, fd

 	xorl %esi, %esi 		# Clean esi(used as counter in _readLoop) and eax(used as tempRis)
	xorl %eax, %eax

	cmpl $1, 12(%ebp)		# JMP to _readLoop or to _writeLoop based on writeFile
    jl _readLoop
    jmp _writeLoop


_readLoop:					# Gets and converts the data from the file to our array.
	pushl %eax

    movl $3, %eax        	# syscall read
    movl fd, %ebx        	# File descriptor
    movl $buffer, %ecx   	# same as leal buffer, %ecx
    movl $1, %edx			# Lenght
    int $0x80

    cmpl $0, %eax       	# ERROR or EOF check -> close and back to menu
    jle _closeFileRET
	# je checkVals  TODO: if everyting good then rember to close the file.

	movzbl buffer, %ebx
	popl %eax

    cmpb $10, %bl			# Check if buffer char is (separator or LF or CR)
    je _storeTemp	 
	cmpb $44, %bl		
    je _storeTemp			# If sep,  storeTemp and skip char
	cmpb $13, %bl
    je _readLoop	 

	cmpb $48, %bl           # buffer < 0 ? NAN
	jb _NAN
	cmpb $57, %bl           # buffer > 9 ? NAN
	ja _NAN

	subb $48, %bl			# ascii -> int
  	movl $10, %edx
  	mulb %dl
  	addb %bl, %al			
	jc _overFlow	# If the result is over 255 it detecrs the overflow 

    jmp _readLoop

_storeTemp:
	movb %al, 8(%ebp, %esi)	    # Move int to array position. Same as ordiniArr(,%ecx,1)
	movb $0, %al				# Default value of int is 0 so ";;" == ";0;" in the file
	inc %esi
	jmp _readLoop


_writeLoop:					# Prints and converts the data form array to our file.
	jmp _closeFileRET


_closeFileRET:
    movl $6, %eax
    movl fd, %ecx
    int $0x80

    movl %ebp, %esp 
    pop %ebp 
    ret



#------------Error managment--------------
_closeFileERR:
    movl $6, %eax           # Close File
    movl fd, %ecx
    int $0x80

    movl $1, %eax           # Exit program   TODO: exit(-1)
	movl $0, %ebx
	int $0x80

_invalidFilename:
	leal invalidFilenameMSG, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 

    jmp _closeFileERR

_overFlow:
	leal overFlowMSG, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	
    jmp _closeFileERR

_NAN:
	leal NAN, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 

    jmp _closeFileERR


# TODO: At the end of the read, loop thorugh the estabished array and make sure each number is within its given rage.

# checkVals:
#   # Salva %ebp per poterlo cambiare liberamente
#   pushl %ebp
#   movl %esp, %ebp

#   movl values, %ecx
# checkLoop:
#   movl (%ebp, %ecx, 4), %eax # ID (1 <= ID <= 127)
#   decl %ecx

#   cmpl $1, %eax
#   jl endCheck

#   cmpl $127, %eax
#   jg endCheck

#   movl (%ebp, %ecx, 4), %eax # Durata (1 <= D <= 10)
#   decl %ecx

#   cmpl $1, %eax
#   jl endCheck

#   cmpl $10, %eax
#   jg endCheck

#   movl (%ebp, %ecx, 4), %eax # Scadenza (1 <= S <= 100)
#   decl %ecx

#   cmpl $1, %eax
#   jl endCheck

#   cmpl $100, %eax
#   jg endCheck

#   movl (%ebp, %ecx, 4), %eax # Priorità (1 <= P <= 5)

#   cmpl $1, %eax
#   jl endCheck

#   cmpl $5, %eax
#   jg endCheck

#   loop checkLoop
#   popl %ebp
#   jmp planAlgorithm

# endCheck:
#   popl %ebp
#   jmp errorInput
