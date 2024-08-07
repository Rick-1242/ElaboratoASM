.section .data

car: .byte 0			# la variabile car e' dichiarata di tipo byte

.section .text
	.global itoa

.type itoa, @function		# dichiarazione della funzione itoa che
							# converte un intero in una stringa
							# il numero da convertire deve essere
							# stato caricato nel registro %eax

itoa: 
	# Prologo GCC calling conventions and then some(/I need my registers thx)
	push %ebp
	movl %esp, %ebp
	# push %esi
	# push %edi
	push %ebx
	push %eax
	push %ecx

	# xorl %eax, %eax 
	# movb 8(%ebp), %al	# carico il parametro passato in al TODO: this is a big limitation. HAS BEEN REMOVED RN
	movl   $0, %ecx		# carica il numero 0 in %ecx


_continua_a_dividere:

	cmpl   $10, %eax	# confronta 10 con il contenuto di %eax

	jge _dividi			# salta all'etichetta _dividi se %eax e'
						# maggiore o uguale a 10

	pushl %eax			# salva nello stack il contenuto di %eax
	incl   %ecx			# incrementa di 1 il valore di %ecx per
						# contare quante push eseguo;
						# ad ogni push salvo nello stack una cifra 
						# del numero (a partire da quella meno
						# significativa)

	movl  %ecx, %ebx	# copia in %ebx il valore di %ecx
						# il numero di cifre che sono state 
						# caricate nello stack

	jmp _stampa			# salta all'etichetta _stampa


_dividi:

	movl  $0, %edx		# carica il numero 0 in %edx

	movl $10, %ebx		# carica il numero 10 in %ebx

	divl  %ebx			# divide per %ebx (10) il numero ottenuto 
						# concatenando il contenuto di %edx e %eax 
						# (notare che in questo caso %edx=0)
						# il quoziente viene messo in %eax,
						# il resto in %edx

	pushl  %edx			# salva il resto della divisione nello stack

	incl   %ecx			# incrementa il contatore delle cifre 
						# salvate nello stack

	jmp	_continua_a_dividere 

	
_stampa:

	cmpl   $0, %ebx		# controlla se ci sono ancora caratteri da 
						# _stampare

	je _fine__itoa		# se %ebx=0 ho _stampato tutto salto alla 
						# fine della funzione

	popl  %eax			# preleva l'elemento da _stampare dallo stack

	movb  %al, car		# memorizza nella variabile car il valore 
						# contenuto negli 8 bit meno significativi 
						# del registro %eax; gli altri bit del 
						# registro non ci interessano visto che una 
						# cifra decimale e' contenuta in un solo 
						# byte

	addb  $48, car		# somma al valore car il codice ascii del 
						# carattere 0 (zero)
  
	decl   %ebx			# decrementa di 1 il numero di cifre da 
						# _stampare
  
	pushw %bx			# salviamo il valore di %bx nello stack 
						# poiche' per effettuare la _stampa dobbiamo 
						# modificare i valori dei registri come 
						# richiesto dalla funzione del sistema 
						# operativo write

	movl   $4, %eax
	movl   $1, %ebx
	leal  car, %ecx		
	movl    $1, %edx
	int $0x80

	popw   %bx			# recupera il contatore dei caratteri da 
						# _stampare salvato nello stack prima della 
						# chiamata alla funzione write
  
	jmp   _stampa		# ritorna all'etichetta _stampa per _stampare 
						# il prossimo carattere. Notare che il 
						# blocco diistruzioni compreso tra 
						# l'etichetta _stampa e l'istruzione jmp 
						# _stampa e' un classico esempio di come 
						# creare un ciclo while in assembly


_fine__itoa:

	movb  $10, car		# copia nella variabile car il codice ascii 
						# del carattere line feed (per andare a 
						# capo riga)

	movl   $4, %eax
	movl   $1, %ebx
	leal  car, %ecx
	mov    $1, %edx
	int $0x80

	# GCC calling convetions
	pop %ecx
	pop %eax
	pop %ebx
	# pop %edi
	# pop %esi
  	movl %ebp, %esp 
  	pop %ebp      

	ret
