.section .data
	#---------File I/O--------------
	fd1: .long 0
	userInput: .space 64
	fd2: .long 0
	#---------Testo-------------
	menu: .asciz "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\nInput:"
	msgHPF: .asciz "Pianificazione HPF:\n"
	msgEDF: .asciz "Pianificazione EDF:\n"
	noArgsExitmsg: .asciz "ERRORE: specificare un filename come argomento.\n"
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
	testl %ebx, %ebx		# filename to read from.
	jz _noArgsExit 

	# Get argument 2
	popl %edx
	testl %edx, %edx		# filename to write to
	jz _readFileIO
	pushl %ebx
	movl $0101,	writeFile	# [O_WRONLY | O_CREAT | O_TRUNC]

	# openFile in write create trunc mode
	pushl %edx
	pushl writeFile
	call openFile
	addl $8, %esp

	movl %eax, fd2			# file descritopr is returned in eax
	popl %ebx

_readFileIO:
	pushl %ebx
	pushl $0				# read mode
	call openFile
	addl $8, %esp
	movl %eax, fd1			# file descritopr is returned in eax

	leal ordiniArr, %eax
	pushl fd1
	pushl %eax
	call readFile
	addl $8, %esp
	movl %edx, totalObjects

	pushl fd1
	call closeFile
	addl $4, %esp

_mainMENU:
	# Print menu
	leal menu, %eax	
	pushl $1 				# stdout
	pushl %eax
	call printSTR
	addl $8, %esp

	# Read from stdin -> userInput
	movl $3, %eax			
	xorl %ebx, %ebx
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
	cmpl $0, writeFile		# filename to write to
	je _keepExiting

	pushl fd2
	call closeFile
	addl $4, %esp

_keepExiting:
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80

#------------------ Option 2 -> _HPF ------------------
_HPF:
	leal msgHPF, %eax
	pushl fd2				# file to write
	pushl %eax
	call printWRITESTR
	addl $8, %esp
	
	leal ordiniArr, %eax
	pushl $3				# sortingID = Priority
	pushl totalObjects
	pushl fd2
	pushl %eax
	call ALGO
	addl $16, %esp

	jmp _mainMENU

#------------------ Option 1 -> _EDF ------------------
_EDF:
	leal msgEDF, %eax
	pushl fd2				# file to write
	pushl %eax
	call printWRITESTR
	addl $8, %esp

	leal ordiniArr, %eax
	pushl $2				# sortingID = Deadline
	pushl totalObjects
	pushl fd2
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
