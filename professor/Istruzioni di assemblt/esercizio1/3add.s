.section .data

somma:
	.ascii "000\n"				# viene dichiarata ed inizializzata la variabile somma di tipo ascii


.section .text
	.global _start

_start:

	movl $100, %eax			# il registro EAX contiene il numero 100

	addl  $33, %eax			# sommo 33 al registro EAX che ora contiene il numero 133

	addl  $68, %eax			# sommo 68 al registro EAX che ora contiene il numero 201

	# in realtà il risultato è tutto contenuto in AL perchè è esprimibile in 8 bit,
	# quindi tutto il resto del registro EAX è posto  0.
	# Per questo motivo posso lavorare con divisioni tra byte.

	leal somma, %esi		# assegno al registro ESI l'indirizzo di memoria di "somma"

	movl $10, %ebx
	div %bl							# divido per 10 in byte, il risultato sarà in AL (quoziente) e AH (resto)
	addb $48, %ah				# sommo 48 al resto della divisione
	movb %ah, 2(%esi)	# sposto AH nel terzo byte della stringa somma
	xorb %ah, %ah				# azzero il registro AH

	# ripeto la procedura precedente per altre due volte.

	div %bl							# divido per 10 in byte, il risultato sarà in AL (quoziente) e AH (resto)
	addb $48, %ah				# sommo 48 al resto della divisione
	movb %ah, 1(%esi)	# sposto AH nel secondo byte della stringa somma
	xorb %ah, %ah				# azzero il registro AH (non sarebbe necessario)

	div %bl							# divido per 10 in byte, il risultato sarà in AL (quoziente) e AH (resto)
	addb $48, %ah				# sommo 48 al resto della divisione
	movb %ah, (%esi)		# sposto AH nel secondo byte della stringa somma
#	xorb %ah, %ah				# azzero il registro AH (non sarebbe necessario)

	movl $4, %eax				# syscall WRITE
	movl $1, %ebx				# terminale
	leal somma, %ecx  	# stringa contenuta in "somma"
	movl $4, %edx				# stringa di 3 caratteri
	int $0x80						# eseguo la syscall

	movl $1, %eax				# syscall EXIT
	movl $0, %ebx				# codice di uscita 0
	int $0x80						# eseguo la syscall
