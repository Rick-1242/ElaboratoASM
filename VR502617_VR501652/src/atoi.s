.section .data

NAN: .ascii "The value provided is Not A Number"
NAN_len: .long . - NAN

.section .text
	.global atoi

.type atoi, @function	# Converte un valore .ascii da max 10 caratteri da
						# striga a intero. La stringa viene caricata sulla stack

atoi:   
	# Prologo GCC calling conventions and then some(I didnt want to chage the funcion but I need my registers thx)
	push %ebp
	movl %esp, %ebp
	push %esi
	push %edi
	push %ebx
	push %eax
	push %ecx
	push %edx

	# TODO have to find a way to pass the number in .ascii and thats complex. involeves loops fuck me sideways thx

	jmp fine_atoi

NANerr:						# Stampa NAN stderr e termina la funzione
	movl $4, %eax
	movl $2, %ebx
	leal NAN, %ecx
	movl NAN_len, %edx
	int $0x80
	jmp fine_atoi

fine_atoi:

	# GCC calling convetions
	pop %edx
	pop %ecx
	pop %eax
	pop %edx
	pop %edi
	pop %esi
  	movl %ebp, %esp 
  	pop %ebp       

	ret
