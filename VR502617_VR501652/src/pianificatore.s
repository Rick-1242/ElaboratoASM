.section .data

maggiore:
	.ascii "Il numero caricato in EAX è maggiore di quello caricato in EBX\n"
maggiore_len:
	.long . - maggiore

minore:
	.ascii "Il numero caricato in EAX è minore di quello caricato in EBX\n"
minore_len:
	.long . - minore

uguali:
	.ascii "I numeri caricati in EAX ed in EBX sono uguali\n"
uguali_len:
	.long . - uguali


.section .text
	.global _start

_start:

	movl $100, %eax
	movl $1000, %ebx

	cmp %ebx, %eax

	je eax_ebx_uguali
	jg eax_maggiore

eax_minore:

	movl $4, %eax
	movl $0, %ebx
	leal minore, %ecx
	movl minore_len, %edx
	int $0x80

	jmp exit

eax_maggiore:

	movl $4, %eax
	movl $0, %ebx
	leal maggiore, %ecx
	movl maggiore_len, %edx
	int $0x80

	jmp exit

eax_ebx_uguali:

	movl $4, %eax
	movl $0, %ebx
	leal uguali, %ecx
	movl uguali_len, %edx
	int $0x80

	jmp exit

exit:

	movl $1, %eax
	movl $0, %ebx
	int $0x80
