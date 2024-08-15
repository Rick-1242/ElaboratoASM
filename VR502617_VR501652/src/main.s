.section .data
    userInput: .ascii "" 
	#---------Testo-------------
	menu: .asciz "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\nInput:"
	msgHPF: .asciz "Pianificazione HPF:\n"
	msgEDF: .asciz "Pianificazione EDF:\n"
	conclusione: .asciz "Conclusione:"
	penalty: .asciz "Penalty:"
	noArgsExitmsg: .asciz "ERRORE: non é stato fornito nessun argomento\n"
	#---------Offset------------
	TOTAL_OBJECTS = 10
	OBJECT_SIZE = 4				# Numero di byte(elementi) per oggeto(ordine)
	IDENTIFICATIVO_OFFSET = 0
	DURATA_OFFSET = 1
	SCANDEZA_OFFSET = 2
	PRIORITA_OFFSET = 3

.section .bss
	ordiniArr: .fill 40, 1, 	# 4 elementi(byte) x 10 oggeti = 10 oggeti con 4 elemeti da 1 byte l'uno
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


	leal ordiniArr, %eax
	pushl %ebx			# Argument
	pushl writeFile		# read || write
	pushl %eax			# &ordiniArr
	call openFile
	addl $12, %esp

_mainMENU:
	leal menu, %eax			# print(menu)
	pushl %eax
	call printSTR
	addl $4, %esp


	movl $3, %eax			# Read from stdin -> userInput
	movl $0, %ebx
	movl $userInput, %ecx
	movl $10, %edx
	int $0x80


	movb userInput, %al		# Only need the first byte
	cmpb $51, %al			# userInput = "3" ? exit
	je _exit
	cmpb $50, %al			# userInput = "2" ? HPF
	je _HPF
	cmpb $49, %al			# userInput = "1" ? EDF
	je _EDF


	jmp _mainMENU

#------------Option 3 -> EXIT-------------------
_exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

_noArgsExit:	# Exit task for when Args is not provided
	leal noArgsExitmsg, %ecx
	pushl %ecx
	call printERR
	addl $4, %esp 
	jmp _exit

#------------Option 2 -> HPF-------------------
_HPF:
	leal msgHPF, %eax
	pushl %eax
	call printSTR
	addl $4, %esp


	leal ordiniArr, %eax
	# Extra paremter for Filename in case writeFile is true
	pushl $TOTAL_OBJECTS
	pushl writeFile
	pushl %eax
	call HPF
	addl $12, %esp

	jmp _mainMENU

#------------Option 1 -> EDF-------------------
_EDF:
	leal msgEDF, %eax
	pushl %eax
	call printSTR
	addl $4, %esp

	leal ordiniArr, %eax
	# Extra paremter for Filename in case writeFile is true
	pushl $TOTAL_OBJECTS
	pushl writeFile
	pushl %eax	
	call EDF
	addl $12, %esp

	jmp _mainMENU
