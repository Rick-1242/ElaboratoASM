.section .data
# .align 4	# do i need this?
#---------Temp--------------
fd: .int 0
filename: .ascii "Both.txt"
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
OBJECT_SIZE = 4		# Numero di interi(elemnti) per oggeto(ordine) 4 elementi x 1 byte = 4 byte a oggetto

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
	writeFile: .long 0

.section .text
	.global _start

_start:
	# movl $0,%ebx
	# movb ordiniArr + SCANDEZA_OFFSET(,%ebx, OBJECT_SIZE), %al
	# call _itoa # for output
	# call getArgs

	## Get arguments
	popl %edx # Non ci serve
	popl %edx
	popl %edx # argc[0]
	popl %edx # argc[1]
	testl %edx, %edx
	jl _noArgsExit

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
_openFile: 				# The file name has too be in %edx
    movl $5, %eax        # syscall open
    movl $filename, %ebx # Nome del file
    movl $0, %ecx		# Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmpl $0, %eax
    jl _noArgsExit

    movl %eax, fd      # Salva il file descriptor in ebx

	jmp _closeFile

	# JMP to _readLoop or to _writeLoop based on writeFile

_closeFile: 
    mov $6, %eax        # syscall close
    mov fd, %ecx      	# File descriptor
    int $0x80           # Interruzione del kernel
	jmp _exit

# _readLoop:	# Gets and converts the data from the file to our array.
	# jmp closeFile
	# jmp menu

# _writeLoop:	# Prints and converts the data form array to our file.
	# jmp closeFile
	# jmp menu 
	


# TASK 1 rewrite all funcions to return eax as by GCC calling conventions.
