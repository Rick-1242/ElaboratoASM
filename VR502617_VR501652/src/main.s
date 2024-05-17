.section .data

OBJECT_SIZE = 4   # Numero di interi(elemnti) per oggeto(ordine) 4 elementi x 4 byte = 16 byte a oggetto

IDENTIFICATIVO_OFFSET = 0
DURATA_OFFSET = 4
SCANDEZA_OFFSET = 8
PRIORITA_OFFSET = 12

.section .bss
ordiniArr: 
    .fill 40, 4, 0 # crete 40 4 byte entries wiht 0 that will be modified by funcions in IO.s


.section .text
	.global _start

_start:
	movl $1,%ecx
	# movl ordiniArr(,%ecx,4), %eax
	# call itoa

	call getParms


	jmp exit

exit:

	movl $1, %eax
	movl $0, %ebx
	int $0x80
