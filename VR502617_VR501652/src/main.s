.section .data
.align 4	# TODO do i need this?
#---------Testo-------------
menu: .ascii "Scelga l'algoritmo o exit:\n1. Earliest Deadline First (EDF)\n2. Highest Priority First (HPF)\n3. Exit\n"
msgHPF: .ascii "Pianificazione HPF:\n"
msgEDF: .ascii "Pianificazione EDF:\n"
conclusione: .ascii "Conclusione:"
penalty: .ascii "Penalty:"

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

.section .text
	.global _start

_start:
	movl $0,%ebx
	movb ordiniArr + SCANDEZA_OFFSET(,%ebx, OBJECT_SIZE), %al
	call itoa # for output


	# call getParms



	jmp exit

exit:

	movl $1, %eax
	movl $0, %ebx
	int $0x80
