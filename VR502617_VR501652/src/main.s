.section .data
	#---------File I/O--------------
	fd: .long 0
	buffer: .asciz ""       # Spazio per il buffer di input  TODO: check wat teacher said about this.
	userInput: .asciz "" 
	#---------Testo-------------
	menu: .asciz "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\nInput:"
	msgHPF: .asciz "Pianificazione HPF:"
	msgEDF: .asciz "Pianificazione EDF:"
	noArgsExitmsg: .asciz "ERRORE: specificare un filename come argomento e si assicuri che questo esista.\n"
	overFlowmsg: .asciz "ERRORE: overflow rilevato, si assicuri che i valori e la formattazione del file in input rispetti le specifiche del progetto.\n"
	NAN: .asciz "ERROE: uno dei valori al interno del file non é un numero.\n"
	outOfRange1: .asciz "ERROE: il valore '"
	outOfRange2: .asciz "' non rientra nelle specifice del progetto.\n"
	#---------Offset------------
	MAX_TOTAL_OBJECTS = 10
	OBJECT_SIZE = 4			# Numero di interi(elemnti) per oggeto(ordine) 
							# 4 elementi x 1 byte = 4 byte a oggetto
	IDENTIFICATIVO_OFFSET = 0
	DURATA_OFFSET = 1
	SCANDEZA_OFFSET = 2
	PRIORITA_OFFSET = 3

.section .bss
	totalObjects: .long 0
	ordiniArr: .fill MAX_TOTAL_OBJECTS, 4, 0	# create 40 1 byte entries wiht 0 that will be modified by funcions
	writeFile: .long 0

.section .text
	.global _start

_start:
	# Get argument 1
	popl %ebx # Non ci serve
	popl %ebx # argc[0]
	popl %ebx # argc[1]
	testl %ebx, %ebx
	je _noArgsExit

	# TODO: here we have to check if there is a second paramter to wrtie to file if so then we need to remember it so that we can pass it to the algo call that will then write to file
	
	# If we do this _openFile needs to be a funcion that takes writeFile as a parameter
	# OLD stuff:
		# Bonus print to file
		# popl %edx
		# testl %edx, %edx Not like this bro.
		# je _noArgsExit
		# inc writeFile
		# jmp _open this time it opens as write
		# The the printing to file ... and close
	

	# push %edx
	# push (ordiniArr) / the address
	jmp _openFile			# TODO: call _openFile would be cool and so openfile wopuld be in another file

_mainMENU:
	leal menu, %eax
	pushl %eax
	call printSTR
	addl $4, %esp


	movl $3, %eax			# Read from stdin -> userInput
	movl $0, %ebx
	movl $userInput, %ecx
	movl $10, %edx
	int $0x80
	
	# Handle userInput and select task accordingly
	movb userInput, %al		# Only need the first byte
	cmpb $51, %al			# userInput = "3" ? exit
	je _exit
	cmpb $50, %al
	je _HPF
	cmpb $49, %al
	je _EDF


	jmp _mainMENU

_exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

_noArgsExit:				# Exit task for when Args is not provided or is wrong
	leal noArgsExitmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _exit

#------------Algo calls-------------------
_HPF:
	leal msgHPF, %eax
	pushl %eax
	call printSTR
	addl $4, %esp

	pushl totalObjects
	pushl writeFile
	leal ordiniArr, %eax
	pushl %eax
	call HPF
	addl $12, %esp

	jmp _mainMENU

_EDF:
	leal msgEDF, %eax
	pushl %eax
	call printSTR
	addl $4, %esp

	pushl totalObjects
	pushl writeFile
	leal ordiniArr, %eax
	pushl %eax	
	call EDF
	addl $12, %esp

	jmp _mainMENU


#------------File processing-------------------
_openFile:
    movl $5, %eax       	# Syscall open
							# Nome del file gia in ebx
    movzbl writeFile, %ecx	# Move zero-extended byte to long
    int $0x80

    cmpl $0, %eax 			# Se c'è un errore in apertura da errore
    jl _noArgsExit
	movl %eax, fd

 	xorl %esi, %esi 		# Clean esi(used as counter in _readLoop) and ecx(used as tempRis)
	xorl %eax, %eax

	cmpl $1, writeFile		# JMP to _readLoop or to _writeLoop based on writeFile
    jl _readLoop
    jmp _writeLoop

_closeFile:
    movl $6, %eax
    movl fd, %ecx
    int $0x80
	jmp _mainMENU			# TODO: Quando sara una funzione deve popare ebp e returnare.

_readLoop:					# Gets and converts the data from the file to our array.
	pushl %eax

    movl $3, %eax        	# syscall read
    movl fd, %ebx        	# File descriptor
    movl $buffer, %ecx   	# same as leal buffer, %ecx
    movl $1, %edx			# Lenght
    int $0x80

    cmpl $0, %eax       	# ERROR or EOF check -> close and back to menu
	je _checkVals  			# TODO: if everyting good then rember to close the file.
    jl _closeFile

	movzbl buffer, %ebx
	popl %eax

    cmpb $10, %bl			# Check if buffer char is (separator or LF or CR)
    je _storeTemp	 
	cmpb $44, %bl		
    je _storeTemp			# If sep,  storeTemp and skip char
	cmpb $13, %bl
    je _readLoop	 

	cmpb $48, %bl
	jb _NAN
	cmpb $57, %bl
	ja _NAN

	subb $48, %bl			# ascii -> int
  	movl $10, %edx
  	mulb %dl
  	addb %bl, %al			
	jc _overFlow	# If the result is over 255 it detecrs the overflow 

    jmp _readLoop

_storeTemp:
	movb %al, ordiniArr(%esi)	# Move int to array position. Same as ordiniArr(,%ecx,1)
	movb $0, %al				# Default value of int is 0 so ";;" == ";0;" in the file
	inc %esi
	jmp _readLoop

_writeLoop:					# Prints and converts the data form array to our file.
	jmp _closeFile

#------------Error managment--------------
_closeFileExit:
	movl $6, %eax
    movl fd, %ecx
    int $0x80
	jmp _exit

_overFlow:
	leal overFlowmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _closeFileExit

_NAN:
	leal NAN, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _closeFileExit

_checkVals:	# Order of operaations not in locial order for better pipeline integration
	movl %esi, %eax

	dec	%esi
	sar $2, %eax

	movl %esi, %ecx			# Decremeting count
	movl %eax, totalObjects	# For sorting algo
	xorl %eax, %eax

_checkValsLoop:
	movb ordiniArr(%ecx), %al # 1 <= P <= 5
	cmpb $1, %al
	jl _outOfRange
	cmpb $5, %al
	jg _outOfRange

	dec %ecx
	movb ordiniArr(%ecx), %al # 1 <= S <= 100
	cmpb $1, %al
	jl _outOfRange
	cmpb $100, %al
	jg _outOfRange

	dec %ecx
	movb ordiniArr(%ecx), %al # 1 <= D <= 10
	cmpb $1, %al
	jl _outOfRange
	cmpb $10, %al
	jg _outOfRange

	dec %ecx
	movb ordiniArr(%ecx), %al # ID (1 <= ID <= 127)
	cmpb $1, %al
	jl _outOfRange
	cmpb $127, %al
	jg _outOfRange

	dec %ecx
	cmpl $0, %ecx			# if ecx > 0: _checkValsLoop
	jg	_checkValsLoop
	jmp _closeFile			# else _closeFile

_outOfRange:
	leal outOfRange1, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 

	call printINT

	leal outOfRange2, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 

	jmp _closeFileExit
