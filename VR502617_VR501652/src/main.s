.section .data
# .align 4	# do i need this?
#---------Testo-------------
menu: .ascii "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\n"
menu_len: .long . - menu
msgHPF: .ascii "Pianificazione HPF:\n"
msgEDF: .ascii "Pianificazione EDF:\n"
msgEDFHPF_len: .long . - msgEDFHPF
conclusione: .ascii "Conclusione:"
conclusione_len: .long . - conclusione
penalty: .ascii "Penalty:"
penalty_len: .long . - penalty
noArgsExitmsg: .ascii "Si assicuri di specificare un filename, come argomento, e che questo esista"
noArgsExitmsg_len: .long . - noArgsExitmsg

#---------Offset------------
OBJECT_SIZE = 4   # Numero di interi(elemnti) per oggeto(ordine) 4 elementi x 1 byte = 4 byte a oggetto

IDENTIFICATIVO_OFFSET = 0
DURATA_OFFSET = 1
SCANDEZA_OFFSET = 2
PRIORITA_OFFSET = 3

	ordiniArr: #.fill 40, 1, 0	# create 40 1 byte entries wiht 0 that will be modified by funcions
								# So 1 object is 4 Bytes = .long = 32bits.
		.rept 10
			.byte 0  # field1 (1 byte)
			.byte 1  # field2 (1 byte)
			.byte 2  # field3 (1 byte)
			.byte 3  # field4 (1 byte)
    	.endr
.section .bss
	writeFile: .byte 0
	count: .byte 0

.section .text
	.global _start

_start:
	# movl $0,%ebx
	# movb ordiniArr + SCANDEZA_OFFSET(,%ebx, OBJECT_SIZE), %al
	# call itoa # for output
	call getArgs

	## Get arguments
	popl %ecx # Non ci serve
	popl %ecx
	popl %ecx # argc[0]
	popl %ecx # argc[1]
	testl %ecx, %ecx
	je noArgsExit

	# Open filename
	# Put file into arry and convert shit with new fancy funcion
	# menu [1,2,3]
	# Run algo 

	# Bonus print to file
	# popl %ecx
	# testl %ecx, %ecx
	# je exit
exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

noArgsExit:		# Exit task if Args is not provided or is wrong
	movl $4, %eax
	movl $2, %ebx
	leal noArgsExitmsg %ecx
	movl noArgsExitmsg_len, %edx
	int $0x80
	jmp exit
# TASK 1 rewrite all funcions to return eax as by GCC calling conventions.
