.section .data
	car: .byte 0
.section .text
  .globl STAMPA_STR
	.global STAMPA_NUM
	.globl SORT 

.type STAMPA_STR, @function	
STAMPA_STR:
	pushl %ebp 
  movl %esp, %ebp
	pushl %ebx
	pushl %eax
	pushl %ecx
	pushl %edx

  movl $4, %eax 		# syscall write
  movl $1, %ebx
  movl 8(%ebp), %ecx  # msg
  movl 12(%ebp), %edx # len
  int $0x80

	popl %edx
	popl %ecx
	popl %eax
	popl %ebx
  movl %ebp, %esp 
  popl %ebp 
  ret


.type STAMPA_NUM, @function	
STAMPA_NUM: 
	pushl %ebp
	movl %esp, %ebp
	pushl %ebx
	pushl %eax
	pushl %ecx
	pushl %edx
	movl   $0, %ecx		# carica il numero 0 in %ecx

_continua_a_dividere:
	cmpl   $10, %eax	# if eax >= 10: _dividi
	jge _dividi

	pushl %eax			# salvo uno degli elemnti da stampare nello stack
	inc   %ecx			# incremento il counter di elemnti da stampare nello stack(cosi so quanti stamprne)
	movl  %ecx, %ebx	
	jmp _stampa

_dividi:
	movl  $0, %edx
	movl $10, %ebx
	divl  %ebx			# divide per %ebx (10) il numero ottenuto 
						# concatenando il contenuto di %edx e %eax 
						# (notare che in questo caso %edx=0)
						# il quoziente viene messo in %eax,
						# il resto in %edx

	pushl  %edx			# salva il resto della divisione nello stack
	inc   %ecx      # incremnta stack count
	jmp	_continua_a_dividere 
	
_stampa:
	cmpl   $0, %ebx		# controlla se ci sono ancora caratteri da stampare
	je FINE_STAMPA_NUM

	popl  %eax			  # prende il numero da stampare
	movb  %al, car	
	addb  $48, car		# $5 + $48 = "5"
	dec   %ebx
  pushw %bx			    # salva il numbero di elemtnni da stampare

  # stampa
	movl   $4, %eax
	movl   $1, %ebx
	leal  car, %ecx		
	movl    $1, %edx
	int $0x80

	popw   %bx
	jmp   _stampa     # cicla fino a quando non stampa tutto.

FINE_STAMPA_NUM:
	popl %edx
	popl %ecx
	popl %eax
	popl %ebx
  movl %ebp, %esp 
  popl %ebp      
	ret



.type SORT, @function 
SORT:
  pushl %ebp
  movl %esp, %ebp
  pushl %eax
  pushl %ebx
  pushl %ecx
  pushl %edx
  pushl %esi
  pushl %edi
  movl 16(%ebp), %ecx		# valorix_tot
  movl 12(%ebp), %edx		# indice sort
  movl 8(%ebp), %esi		# array

  decl %ecx
  jle FINE_SORT				      # Se l'array é vuoto o solo 1 valore abbiamo finito
CICLO_ESTERNO:
  movl %ecx, %edi			      # ecx = CICLO_ESTERNO conta; edi = CICLO_INTERNO conta

CICLO_INTERNO: 
  movb (%esi,%edx,1), %al   # primo valore
  movb 4(%esi,%edx,1), %bl  # secondo valore
  cmpb %bl, %al
  jbe no_swap         # se il primo valore <= del secondo valore non serve scambiarli. L' ordine é corretto
  # Scambio
  movl (%esi), %eax		
  movl 4(%esi), %ebx
  movl %ebx, (%esi)
  movl %eax, 4(%esi)

no_swap:
  addl $4, %esi			    # Si sposta al prossimo oggeto
  decl %edi             # Decrementa il conto 
  jnz CICLO_INTERNO			# Se il conto del loop interno non é 0 allora contiuno quello
  movl 8(%ebp), %esi		# Se sono arrivando infondo al primo ciclo interno resetto array al inzio
  decl %ecx             # e decremnto il conto esterno.
  jnz CICLO_ESTERNO			# Se il conto esterno non é zero allora continuo il conto esterno

FINE_SORT:
  popl %edi
  popl %esi
  popl %edx
  popl %ecx
  popl %ebx
  popl %eax
  movl %ebp, %esp 
  popl %ebp
  ret
