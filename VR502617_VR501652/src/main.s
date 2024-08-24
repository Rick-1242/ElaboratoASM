.section .data
	#---------File I/O--------------
	fd1: .long 0
	userInput: .space 64
	buffer: .asciz ""
	#---------Testo-------------
	menu: .asciz "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\nInput:"
	msgHPF: .asciz "Pianificazione HPF:\n"
	msgEDF: .asciz "Pianificazione EDF:\n"
	noArgsExitmsg: .asciz "ERRORE: specificare un filename come argomento.\n"
	invalidFilenamemsg: .asciz "ERROE: si assicuri che il filename specificato esista.\n"
	overFlowmsg: .asciz "ERRORE: overflow rilevato, si assicuri che i valori e la formattazione del file in input rispetti le specifiche del progetto.\n"
	NANmsg: .asciz "ERROE: uno dei valori al interno del file non é un numero.\n"
	missingEOFmsg: .asciz "ERRORE: end of file non alla fine di una nuova lina. Perfavore inserica una nuova linea vuota alla fine del file\n Oppure non 3 virgole per linea\n"
	outOfRange1: .asciz "ERROE: il valore '" 
	outOfRange2: .asciz "' non rientra nelle specifice del progetto.\n"
	#---------Offset------------
	MAX_TOTAL_OBJECTS = 10	# 10 oggetti da 4 elemnti l'uno =  4 byte/oggeto
	# TODO: test se funziona con piu di 10 cambaindo la costante. Dovrebbe.
.section .bss
	totalObjects: .long 0
	ordiniArr: .fill MAX_TOTAL_OBJECTS, 4, 0
	writeFile: .long 0

.section .text
	.global _start

_start:
	# Get argument 1
	popl %ebx
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

_readFileIO:
	jmp _openFile
	# pushl fd1
	# pushl filename 
	# pushl writeFile
	# call openFile
	# call readFile
	# call closeFile

_mainMENU:
	# Print menu
	leal menu, %eax			
	pushl %eax
	call printSTR
	addl $4, %esp

	# Read from stdin -> userInput
	movl $3, %eax			
	movl $0, %ebx
	movl $userInput, %ecx
	movl $64, %edx
	int $0x80
	
	# Handle userInput
	movb userInput, %al		# Only need the first byte
	cmpb $51, %al			# userInput = "3" ? exit
	je _exit
	cmpb $50, %al
	je _HPF
	cmpb $49, %al
	je _EDF

	jmp _mainMENU

#------------------ Option 3 -> _exit ------------------
_exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

#------------------ Option 2 -> _HPF ------------------
_HPF:
	leal msgHPF, %eax
	pushl %eax
	call printSTR
	addl $4, %esp

	leal ordiniArr, %eax
	pushl $3	# sortingID = Priority
	pushl totalObjects
	pushl writeFile
	pushl %eax
	call ALGO
	addl $12, %esp

	jmp _mainMENU

#------------------ Option 1 -> _EDF ------------------
_EDF:
	leal msgEDF, %eax
	pushl %eax
	call printSTR
	addl $4, %esp

	leal ordiniArr, %eax
	pushl $2	# sortingID = Deadline
	pushl totalObjects
	pushl writeFile
	pushl %eax	
	call ALGO
	addl $16, %esp

	jmp _mainMENU


#------------------ Error managment ------------------
_noArgsExit:
	leal noArgsExitmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _exit

#------------------File processing------------------- TODO: Move to fileIO.s
_openFile:
    movl $5, %eax       	# Syscall open
							# Nome del file gia in ebx
    movzbl writeFile, %ecx	# Move zero-extended byte to long
    int $0x80

    cmpl $0, %eax 			# Se c'è un errore in apertura da errore
    jl _invalidFilename
	movl %eax, fd1

 	xorl %esi, %esi 		# Clean esi(used as counter in _readLoop) and ecx(used as tempRis)
	xorl %eax, %eax

	cmpl $1, writeFile		# JMP to _readLoop or to _writeLoop based on writeFile
    jl _readLoop
    jmp _writeLoop

_closeFile:
    movl $6, %eax
    movl fd1, %ecx
    int $0x80
	jmp _mainMENU			# TODO: Quando sara una funzione deve popare ebp e returnare.

_readLoop:					# Gets and converts the data from the file to our array.
	pushl %eax

    movl $3, %eax        	# syscall read
    movl fd1, %ebx        	# File descriptor
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
	jc _overFlow	# If the result is over 255 it detecrs the overflow 

    jmp _readLoop

_storeTemp:
	movb %al, ordiniArr(%esi)	# Move int to array position. Same as ordiniArr(,%ecx,1)
	movb $0, %al				# Default value of int is 0 so ";;" == ";0;" in the file
	inc %esi
	jmp _readLoop

_writeLoop:					# Prints and converts the data form array to our file.
	jmp _closeFile

#------------------Error managment--------------

_exitERROR:
	movl $1, %eax
	movl $1, %ebx
	int $0x80

_invalidFilename:
	leal invalidFilenamemsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _exitERROR

_closeFileExit:
	movl $6, %eax
    movl fd1, %ecx
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


_checkVals:	# Order of operaations not in locial order for better pipeline integration
	movl %esi, %eax
	movl %eax, %ebx
	andl $3, %eax
	jnz _missingEOF			# Jump if totalElements not divisible by 4 and therefor EOF is not on a new line. or smething wrong.
	movl %ebx, %eax

	dec	%esi
	sar $2, %eax			# total Elements / 4 = totalObjects

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
