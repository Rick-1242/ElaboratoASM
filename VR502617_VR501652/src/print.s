.section .data
	char: .byte 0

.section .text
	.globl strlen			# Calculates the lenght of a string given in %ecx
	.globl printWRITEINT
	.globl printWRITESTR	# Checks if the File Descriport is active and therefore the code has been lounched in write mode.
							# if so then it writes to the file and prints to std-out. Else it only prints to std-out.
    .globl printSTR			# Prints a string to std-out
    .globl printERR			# Prints a string to std-err
	.globl printINT			# Converts an integer into a string and prints it to std-out

	.type strlen, @function	# movl $msg, %ecx 		# movl $msg, %ecx == leal msg, %ecx
							# call strlen
	
	.type printWRITEINT, @function	# movl num, %eax
									# pushl fd2
									# call printWRITEINT
									# addl $4, %esp

	.type printWRITESTR, @function	# pushl fd2	
									# pushl $msg
									# call printWRITESTR
									# addl $8, %esp

	.type printSTR, @function	# pushl $msg
								# call printSTR
								# addl $4, %esp

	.type printERR, @function 	# pushl $msg
	                        	# call printERR
	                        	# addl $4, %esp

	.type printINT, @function	# movl num, %eax
								# call printINT

strlen:
    xorl    %edx, %edx       	# Clear the edx register (length counter set to 0)
_loop:
    movb    (%ecx,%edx,1), %al  # Load the byte at edi+edx into al
    cmpb    $0, %al          	# (null terminator)
    je      _done            	# If 0 then we are done
    inc    %edx             	
    jmp     _loop            	# Repeat the loop
_done:
    ret


#----------------------------------------------------------------------------------------------

printWRITEINT:
	push %ebp 
    movl %esp, %ebp
	push %ebx
	push %eax
	push %ecx
	push %edx
	
	# %eax		== number
	# 8(%ebp)	== file descriptor

	cmpl $0, 8(%ebp)
	je _printINT

	pushl %eax

	pushl 8(%ebp)		# file
	call printINT
	addl $4, %esp

	popl %eax

	_printINT:
		pushl $1		# std-out
		call printINT
		addl $4, %esp


	pop %edx
	pop %ecx
	pop %eax
	pop %ebx
    movl %ebp, %esp 
    pop %ebp 
    ret

#----------------------------------------------------------------------------------------------

printWRITESTR:
	push %ebp 
    movl %esp, %ebp
	push %ebx
	push %eax
	push %ecx
	push %edx
	

	# 8(%ebp) == &msg
	# 12(%ebp) == file descriptor

	cmpl $0, 12(%ebp)
	je _printSTR

	pushl 12(%ebp) 				# file
	pushl 8(%ebp)
	call printSTR
	addl $8, %esp

	_printSTR:
		pushl $1 				# stdout
		pushl 8(%ebp)
		call printSTR
		addl $8, %esp

	pop %edx
	pop %ecx
	pop %eax
	pop %ebx
    movl %ebp, %esp 
    pop %ebp 
    ret

#----------------------------------------------------------------------------------------------

printSTR:
	push %ebp 
    movl %esp, %ebp
	push %ebx
	push %eax
	push %ecx
	push %edx

	movl 8(%ebp), %ecx 	# address of string to write
	call strlen			# strlen is in edx

    movl $4, %eax 		# syscall number for write()
    movl 12(%ebp), %ebx 		# file descriptor for stdout
	# msg address in already in ecx
	# len  in already in edx
    int $0x80

	pop %edx
	pop %ecx
	pop %eax
	pop %ebx
    movl %ebp, %esp 
    pop %ebp 
    ret

#----------------------------------------------------------------------------------------------

printERR:
    push %ebp 
    movl %esp, %ebp 
	push %ebx
	push %eax
	push %ecx
	push %edx
	
	movl 8(%ebp), %ecx 	# address of string to write
	call strlen			# strlen is in edx

    movl $4, %eax 		# syscall number for write()
    movl $2, %ebx 		# file descriptor for stderr
	# msg address in already in ecx
	# len  in already in edx
    int $0x80

    pop %edx
	pop %ecx
	pop %eax
	pop %ebx
    movl %ebp, %esp 
    pop %ebp 
    ret

#----------------------------------------------------------------------------------------------

printINT: 
	push %ebp
	movl %esp, %ebp
	push %ebx
	push %eax
	push %ecx
	push %edx

	# 8(%ebp)	== where to output so file or std-out

	movl   $0, %ecx		# carica il numero 0 in %ecx

_continua_a_dividere:

	cmpl   $10, %eax	# if eax >= 10: _dividi
	jge _dividi

	pushl %eax			# salva nello stack il contenuto di %eax che sara un elemento da stampare
	inc   %ecx			# incrementa di 1 il valore di %ecx per
						# contare quante push eseguo;
						# ad ogni push salvo nello stack una cifra 
						# del numero (a partire da quella meno
						# significativa)
	movl  %ecx, %ebx	
	jmp _stampa			# salta all'etichetta _stampa

_dividi:

	movl  $0, %edx
	movl $10, %ebx
	divl  %ebx			# divide per %ebx (10) il numero ottenuto 
						# concatenando il contenuto di %edx e %eax 
						# (notare che in questo caso %edx=0)
						# il quoziente viene messo in %eax,
						# il resto in %edx

	pushl  %edx			# salva il resto della divisione nello stack
	inc   %ecx			# incrementa il contatore delle cifre 
						# salvate nello stack

	jmp	_continua_a_dividere 
	
_stampa:
	cmpl   $0, %ebx		# controlla se ci sono ancora caratteri da stampare
	je _fine__printINT

	popl  %eax			# preleva l'elemento da _stampare dallo stack

	movb  %al, char	
	addb  $48, char		# $5 + $48 = "5"
	dec   %ebx
  
	pushw %bx			# char count

	movl   $4, %eax
	movl   8(%ebp), %ebx
	leal  char, %ecx		
	movl    $1, %edx
	int $0x80

	popw   %bx
	jmp   _stampa

_fine__printINT:
	pop %edx
	pop %ecx
	pop %eax
	pop %ebx
  	movl %ebp, %esp 
  	pop %ebp      
	ret
