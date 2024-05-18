.section .data

new_line_char:
	.byte 10

.section .text
	.global getParms
	.global count_char
	.global print_par

.type getParms, @function		# Dicardo la funzione getParms
                                # al momento stmapa i parametri ottenuti in esecuzione 
                                # takes ecx  and prints it

                                # TODO in futuro li da indietro


getParms:               # elimino i primi due valori nello stack
	popl %ecx			# Contiene il numero dei parametri totali
	popl %ecx

handle_par:
	popl %ecx			# Recupera l'indirizzo della stringa relativa al  parametro
	testl %ecx, %ecx	# controlla se EAX =  0 (NULL)
	jz fine
	call print_par		# stampa il parametro
	jmp handle_par 		# ciclo nuovamente 

fine:
	movl $1, %eax
	movl $0, %ebx
	int $0x80


# --------------------------------------
.type print_par, @function			# Stampa la stringa del parametro e va a capo
print_par:
	call count_char 												
	movl $4, %eax
	movl $1, %ebx					
									# Non serve settare ecx ed edx in quanto
									# l'indirizzo è già contenuto in ecx
									# la lunghezza della stringa è già contenuta in edx
	int $0x80

	movl $4, %eax
	movl $1, %ebx
	leal new_line_char, %ecx
	movl $1, %edx
	int $0x80
	
	ret


# --------------------------------------
.type count_char, @function			# conta da quanti caratteri è composta la stringa in ecx
									# il valore risultato è contenuto in edx
count_char:
	xorl %edx, %edx

iterate:
	movb (%ecx,%edx), %al 			# mette il carattere della stringa in al  HOWWWWWW
	testb %al, %al 					# se il carattere è 0 (\0) la stringa è finita
	jz end_count				
	incl %edx
	jmp iterate

end_count:
	ret
	


