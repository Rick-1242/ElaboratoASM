.section .data
	buffer: .asciz ""
	invalidFilenamemsg: .asciz "ERROE: assicurarsi che il filename specificato esista.\n"
	overFlowmsg: .asciz "ERRORE: overflow rilevato, assicurarsi che i valori e la formattazione del file in input rispetti le specifiche del progetto.\n"
	NANmsg: .asciz "ERROE: uno dei valori al interno del file non é un numero.\n"
	missingEOFmsg: .asciz "ERRORE: end of file non alla fine di una nuova lina. Inserire una nuova linea vuota alla fine del file\n Oppure una delle righe nel file contiene piu o meno di 3 spearatori(",").\n"
	outOfRange1: .asciz "ERROE: il valore '" 
	outOfRange2: .asciz "' non rientra nelle specifiche del progetto.\n"
.section .text
    .globl openFile
	.globl closeFile
    .globl readFile


#------------------openFile-------------------
.type openFile, @function
openFile:
	push %ebp
	movl %esp, %ebp

	# 8(%ebp) 		open mode 
	# 12(%ebp)		filename

    movl $5, %eax       	# Syscall open
	movl 12(%ebp), %ebx		# filename
    movl 8(%ebp), %ecx		# opening mode
	movl $0644, %edx        # Mode: rw-r--r--.  If a file is created.
    int $0x80

    cmpl $0, %eax 			# Opening file error check
    jl _invalidFilename

	movl %ebp, %esp 
  	pop %ebp
	ret

_invalidFilename:
	leal invalidFilenamemsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _exitERROR

_exitERROR:
	movl $1, %eax
	movl $1, %ebx
	int $0x80


#------------------closeFile-------------------
.type closeFile, @function
closeFile:
	push %ebp
	movl %esp, %ebp

	# 8(%ebp)	file descriptor

    movl $6, %eax
    movl 8(%ebp), %ecx
    int $0x80
	
	movl %ebp, %esp 
  	pop %ebp      
	ret

#------------------readFile-------------------
.type readFile, @function
readFile: 
	push %ebp
	movl %esp, %ebp

	# 8(%ebp)	&ordiniArr
	# 12(%ebp)  file descriptor

	movl 8(%ebp), %esi		# esi is the base addres for ordiniArr
 	xorl %edi, %edi 		# Clean edi(used as counter in _readLoop) and ecx(used as temporary result)
	xorl %eax, %eax

_readLoop:					# Gets and converts the data from the file to our array.
	pushl %eax

    movl $3, %eax        	# syscall read
    movl 12(%ebp), %ebx		# File descriptor
    movl $buffer, %ecx   	# same as leal buffer, %ecx
    movl $1, %edx			# Lenght
    int $0x80

    cmpl $0, %eax       	# ERROR or EOF check -> close and back to menu
	je _checkVals
    jl _closeFileExit

	movzbl buffer, %ebx
	popl %eax

    cmpb $10, %bl			# Check if buffer char is (separator or LF or CR)
    je _storeTemp	 
	cmpb $13, %bl
    je _readLoop	 
	cmpb $44, %bl		
    je _storeTemp			# If sep,  storeTemp and skip char

	cmpb $48, %bl
	jb _NAN
	cmpb $57, %bl
	ja _NAN

	subb $48, %bl			# ascii -> int
  	movl $10, %edx
  	mulb %dl
  	addb %bl, %al			
	jc _overFlow			# If the result is over 255 it detecrs the overflow 

    jmp _readLoop

_storeTemp:
	movb %al, (%esi,%edi,1)		# Move int to array position. Same as ordiniArr(%edi)
	movb $0, %al				# Default value of int is 0 so ";;" == ";0;" in the file
	inc %edi
	jmp _readLoop

#------------------Error managment--------------
_closeFileExit:
	movl $6, %eax
    movl 12(%ebp), %ecx
    int $0x80
	jmp _exitERROR

_overFlow:
	leal overFlowmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _closeFileExit

_NAN:
	leal NANmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _closeFileExit

_missingEOF:
	leal missingEOFmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _closeFileExit

_outOfRange:
	leal outOfRange1, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 

	# number is already in eax
	pushl $1
	call printINT
	addl $4, %esp

	leal outOfRange2, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 

	jmp _closeFileExit

_checkVals:	# Checks the values read from thehe file to determine if they are within their rages.
	# Order of operations not in logical order for better pipeline integration
	movl %edi, %eax
	movl %eax, %ebx
	andl $3, %eax
	jnz _missingEOF			# Jump if totalElements not divisible by 4 and therefore EOF is not on a new line. or something wrong.
	movl %ebx, %eax

	dec	%edi
	sar $2, %eax			# total Elements / 4 = totalObjects

	movl %edi, %ecx			# Decremeting count
	movl %eax, %edx	    	# For sorting algo [totalObjects]
	xorl %eax, %eax

_checkValsLoop:
	movb (%esi, %ecx,1), %al # 1 <= PRIORITA <= 5
	cmpb $1, %al
	jl _outOfRange
	cmpb $5, %al
	jg _outOfRange

	dec %ecx
	movb (%esi, %ecx,1), %al # 1 <= SCADENZA <= 100
	cmpb $1, %al
	jl _outOfRange
	cmpb $100, %al
	jg _outOfRange

	dec %ecx
	movb (%esi, %ecx,1), %al # 1 <= DURATA <= 10
	cmpb $1, %al
	jl _outOfRange
	cmpb $10, %al
	jg _outOfRange

	dec %ecx
	movb (%esi, %ecx,1), %al # 1 <= ID <= 127
	cmpb $1, %al
	jl _outOfRange
	cmpb $127, %al
	jg _outOfRange

	dec %ecx
	cmpl $0, %ecx			# if ecx > 0 : _checkValsLoop
	jg	_checkValsLoop
	
	movl %ebp, %esp 		# if we get here everything is in order and we can return.
    pop %ebp 
    ret
