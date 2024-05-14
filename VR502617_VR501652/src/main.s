.section .data

ordiniArr:
	.long 1, 2, 3, 4  
	.long 5, 6, 7, 8   
	.long 9, 10, 11, 12  

OBJECT_SIZE = 4   # Numero di interi(elemnti) per oggeto(ordine) 4 elementi x 4 byte = 16 byte a oggetto

IDENTIFICATIVO_OFFSET = 0
DURATA_OFFSET = 4
SCANDEZA_OFFSET = 8
PRIORITA_OFFSET = 12

.section .bss
#ordiniArr: 
    #.fill 40, 4, 0 # crete 40 4 bytre entries wiht 0 that will be modified by funcions in IO.s


.section .text
	.global _start

_start:
	movl $1, %eax  # eax serve da indice per l' array ordini arr, poi andara in .bss ma mi sto disperando quindi sto provando anche questa
	leal ordiniArr(,%eax, 4), %ecx # Access first element of array eatch elemnt is 4 bytes

	movl $4, %eax              # syscall number for sys_write
    movl $1, %ebx              # file descriptor 1 (stdout)
    movl $4, %edx              # number of bytes to print
    int $0x80                  # call kernel

	jmp exit

exit:

	movl $1, %eax
	movl $0, %ebx
	int $0x80
