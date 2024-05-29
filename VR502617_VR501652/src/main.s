.section .data
# .align 4	# do i need this?
#---------File I/O--------------
fd: .int 0
buffer: .ascii ""       # Spazio per il buffer di input
newline: .byte 10       # Valore del simbolo di nuova linea
sep: .byte 44			# Ovvero ","
#---------Testo-------------
menu: .ascii "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\n"
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

#---------Offset------------
TOTAL_OBJECTS = 10
OBJECT_SIZE = 4		# Numero di interi(elemnti) per oggeto(ordine) 
					# 4 elementi x 1 byte = 4 byte a oggetto
IDENTIFICATIVO_OFFSET = 0
DURATA_OFFSET = 1
SCANDEZA_OFFSET = 2
PRIORITA_OFFSET = 3

ordiniArr: #.fill 40, 1, 0	# create 40 1 byte entries wiht 0 that will be modified by funcions
							# So 1 object is 4 Bytes = .long = 32bits.
	.rept TOTAL_OBJECTS
		.byte 0  # field1 (1 byte)
		.byte 1  # field2 (1 byte)
		.byte 2  # field3 (1 byte)
		.byte 3  # field4 (1 byte)
	.endr

.section .bss
	tempRis: .byte 0
	writeFile: .long 0
	row: .int 0			# legge solo 255 righe é una limitazione
	col: .int 0			# TODO: maybe remove and use a reg



.section .text
	.global _start

_start:
	# movl $0,%ebx
	# movb ordiniArr + SCANDEZA_OFFSET(,%ebx, OBJECT_SIZE), %al
	# call _itoa # for output
	# call getArgs

	## Get arguments
	popl %ebx # Non ci serve
	popl %ebx # argc[0]
	popl %ebx # argc[1]
	testl %ebx, %ebx
	je _noArgsExit

	jmp _openFile


	# Open filename  DONE
	# Read form file
	# Put file into arry and convert shit with new fancy funcion
	# Close file
_menu:

	# menu [1,2,3]
	# Run algo call  
	# Bonus print to file
	# popl %edx
	# testl %edx, %edx
	# je _noArgsExit
	# incl writeFile
	# jmp _open this time it opens as write
	# The the printing to file ... and close
	
_exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

_noArgsExit:		# Exit task for when Args is not provided or is wrong
	movl $4, %eax
	movl $2, %ebx
	leal noArgsExitmsg, %ecx
	movl noArgsExitmsg_len, %edx
	int $0x80
	jmp _exit



#------------File processing-------------------
_openFile:
	xorl %ecx, %ecx		# might not be nessecary TODO:
    movl $5, %eax       # syscall open
						# Nome del file gia in ebx
    movb writeFile, %cl	# Modalità di apertura (O_RDONLY)
    int $0x80

    # Se c'è un errore, esce
    cmpl $0, %eax
    jl _noArgsExit

    movl %eax, fd

 	# JMP to _readLoop or to _writeLoop based on writeFile
	cmpb $1, writeFile
    jl _readLoop
    jmp _writeLoop   

_closeFile: 
    movl $6, %eax        # syscall close
    movl fd, %ecx
    int $0x80
	jmp _exit   		# TODO: this is tempRisorary. HAS TO BE REMOVED  Will be jmp menu

_readLoop:		# Gets and converts the data from the file to our array.
    movl $3, %eax        # syscall read
    movl fd, %ebx        # File descriptor
    movl $buffer, %ecx
    movl $1, %edx        # Lenght
    int $0x80

    cmpl $0, %eax        # ERROR or EOF check
    jle _closeFile
    
    # New line check
	xorl %ebx, %ebx
    movb buffer, %bl
    cmpb newline, %bl
    jne _getLine
    incw row
	movw $0, col

	# Put data into array
	# jmp menu

_getLine: # this will put data into array ig
	pushl %edx
	pushl $buffer
	call _myPrint
	addl $8, %esp

	cmpb sep, %bl		# Check if the character is a separator
    je _sepDetected		# If comma, move to the next string

	subb $48, %bl
  	movl $10, %edx
  	mulb %dl			# EDX = EDX * 10
  	addb %bl, tempRis		# Risultato é in tempRis

    jmp _readLoop      # Torna alla lettura del file

_sepDetected:
	xorl %eax, %eax
	movl row, %eax #	non dovrebbe essere la riga?
	movb tempRis, %cl
	movb %cl, ordiniArr + col(,%eax, OBJECT_SIZE)		#NO GOOD It doesnt put it a the right place, we need to stop using tempRis and use %ecx cant move memory to memory
	movb $0, tempRis			# Azzero tempRis per il prossimo valore e anche if ";;" allora assumo 0 DOCS
	incw col
	jmp _readLoop

_writeLoop:	# Prints and converts the data form array to our file.
	# Riplusco le variabili per scrollare
	movw $0, row
	movw $0, col

	# ripulisci row e colonne(%ecx) first
	# jmp closeFile
	# jmp menu 

# TASK 1 rewrite all funcions to return eax as by GCC calling conventions.
