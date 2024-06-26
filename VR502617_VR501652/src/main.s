.section .data
# .align 4	# do i need this?
#---------File I/O--------------
fd: .long 0
buffer: .ascii ""       # Spazio per il buffer di input
newline: .byte 10       # Valore del simbolo di nuova linea
sep: .byte 44			# Ovvero ","
asciiNine: .byte 57
asciiZero: .byte 48
#---------Testo-------------
menu: .ascii "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\nInput:"
menu_len: .long . - menu
msgHPF: .ascii "Pianificazione HPF:\n"
msgEDF: .ascii "Pianificazione EDF:\n"
msgEDFHPF_len: .long . - msgEDF
conclusione: .ascii "Conclusione:"
conclusione_len: .long . - conclusione
penalty: .ascii "Penalty:"
penalty_len: .long . - penalty
noArgsExitmsg: .ascii "Si assicuri di specificare un filename, come argomento, e che questo esista\n"
noArgsExitmsg_len: .long . - noArgsExitmsg
overFlowDetectedmsg: .ascii "Overflow rilevato, si assicuri che i valori e la formattazione del file in input rispetti le specifiche del progetto\n"
overFlowDetectedmsg_len: .long . - overFlowDetectedmsg
NAN: .ascii "One of the values provided is Not A Number"
NAN_len: .long . - NAN
#---------Offset------------
TOTAL_OBJECTS = 10
OBJECT_SIZE = 4		# Numero di interi(elemnti) per oggeto(ordine) 
					# 4 elementi x 1 byte = 4 byte a oggetto
IDENTIFICATIVO_OFFSET = 0
DURATA_OFFSET = 1
SCANDEZA_OFFSET = 2
PRIORITA_OFFSET = 3

.section .bss
	ordiniArr: #.fill 40, 1, 0	# create 40 1 byte entries wiht 0 that will be modified by funcions
		# 1 object is 4 Bytes = .long = 32bits.
		.rept TOTAL_OBJECTS
			.byte 0  # IDENTIFICATIVO
			.byte 0  # DURATA
			.byte 0  # SCANDEZA
			.byte 0  # PRIORITA
		.endr
	tempRis: .byte 0	# I valori in ordiniArr sono byte quindi anche questo.
	writeFile: .long 0
	#---------User I/O--------------
	userInput: .ascii "" 

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
	jmp _openFile		# call _openFile would be cool and so openfile wopuld be in another file

_mainMENU:
	pushl menu_len
	leal menu, %eax
	pushl %eax
	call _myPrint
	addl $8, %esp

	# Read from stdin -> userInput
	movl $3, %eax
	movl $0, %ebx
	movl $userInput, %ecx
	movl $10, %edx
	int $0x80
	
	movb userInput, %al		# Only need the first byte
	cmpb $51, %al			# userInput = "3" : exit
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

_noArgsExit:		# Exit task for when Args is not provided or is wrong
	leal noArgsExitmsg, %ecx
	pushl noArgsExitmsg_len
	pushl %ecx
	call _mySTDERR
	addl $8, %esp 
	jmp _exit

#------------Algo calls-------------------
_HPF:
	pushl msgEDFHPF_len
	leal msgHPF, %eax
	pushl %eax
	call _myPrint
	addl $8, %esp

	# Pass Parms and call funcion

	jmp _mainMENU

_EDF:
	pushl msgEDFHPF_len
	leal msgEDF, %eax
	pushl %eax
	call _myPrint
	addl $8, %esp

	# Pass Parms and call funcion

	jmp _mainMENU


#------------File processing------------------- This might become all a big funcion that returns in _closeFile
_openFile:
	xorl %ecx, %ecx
    movl $5, %eax       # syscall open
						# Nome del file gia in ebx
    movl writeFile, %ecx
    int $0x80

    # Se c'è un errore, esce
    cmpl $0, %eax 
    jl _noArgsExit

    movl %eax, fd

 	xorl %ecx, %ecx 	# Clean ecx, used as counter in _readLoop
	# JMP to _readLoop or to _writeLoop based on writeFile
	cmpl $1, writeFile
    jl _readLoop
    jmp _writeLoop   

_closeFile:
    movl $6, %eax        # syscall close
    movl fd, %ecx
    int $0x80
	jmp _mainMENU

_readLoop:		# Gets and converts the data from the file to our array.
				# ebx buffer , ebx = 48
				# edx buffer_len, edx = 10
				# ecx count
				# eax 
	pushl %ecx
    movl $3, %eax        # syscall read
    movl fd, %ebx        # File descriptor
    movl $buffer, %ecx   # TODO: this can be leal too fuck this this.
    movl $1, %edx        # Lenght
    int $0x80
	popl %ecx

    cmpl $0, %eax        # ERROR or EOF check -> close and back to menu
    jle _closeFile

	pushl %edx			# print(buffer)
	pushl $buffer
	call _myPrint
	addl $8, %esp

	# Check if char is (separator or \n)
	xorl %ebx, %ebx		# FIXME: might remove, may not be necesary
	movb buffer, %bl	
    cmpb newline, %bl   # New line has to be treated like sep
    je _storeTemp	 
	cmpb sep, %bl		
    je _storeTemp		# If sep,storeTemp and skip char

	# NAN check TODO: not working for some reason
	cmpb asciiNine, %bl 	
	ja _NANerr
	cmpb asciiZero, %bl
	jb _NANerr

	# ascii -> int
	subb $48, %bl
  	movl $10, %edx
  	mulb %dl				# DL = DL * 10
  	addb %bl, tempRis		# tempRis = tempRis + DL  FIXME: Somethign wrong with tempRis it doent work maybe we need to use registers
	jc _overFlowDetected	# Se il valore in tempRis supera 255 va in overflow

    jmp _readLoop

_storeTemp:		# TODO: Sarebbe figo conrollare i range al posto di conrollare solo l'overflow
	movb tempRis, %al
	movb %al, ordiniArr(%ecx)		# Same as ordiniArr(,%ecx,1)
	movb $0, tempRis				# Default value of tempRis is 0 so ";;" == ";0;" in the file
	inc %ecx
	jmp _readLoop

_writeLoop:	# Prints and converts the data form array to our file.
	jmp _closeFile

#------------Error managment--------------
_overFlowDetected:		# FIXME: not working
	leal overFlowDetectedmsg, %ecx
	pushl overFlowDetectedmsg_len
	pushl %ecx
	call _mySTDERR
	addl $8, %esp 
	jmp _closeFile

_NANerr:
	pushl NAN_len
	leal NAN, %ecx
	pushl %ecx
	call _mySTDERR
	addl $8, %esp 
	jmp _closeFile

# _outofRangeDetected: 




# TASK 1 rewrite all funcions to return eax as by GCC calling conventions.
