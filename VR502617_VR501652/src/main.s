.section .data
  # Costanti
	Oggetti_Totali_MAX = 10
  # Testo
	menu: .ascii "Scelga l'algoritmo di pianificazione: 1. EDF; 2. HPF; 3. Exit.\nAlgoritmo:"
  menu_len: .long . - menu
	HPF_msg: .ascii "Pianificazione HPF:\n"
  HPF_msg_len: .long . - HPF_msg
	EDF_msg: .ascii "Pianificazione EDF:\n"
  EDF_msg_len: .long . - EDF_msg
	no_arg_msg: .ascii "Specifichi un file da analizzare\n"
  no_arg_msg_len: .long . - no_arg_msg
	nome_sbagliato_msg: .ascii "Controlli che il file esista\n"
  nome_sbagliato_msg_len: .long . - nome_sbagliato_msg
	nan_msg: .ascii "Uno dei valori nel file non é un numero(NAN)\n"
  nan_msg_len: .long . - nan_msg
	manca_EOF_msg: .ascii "Questo errore viene lanciato se il numero di valori non é divisibile per 4.\nQuesto é di solito dovuto alla mancaza di una nuova linea alla fine del ultima righa. Oppre a piu o meno di 3 "," per riga.\nPerfavore inserica una nuova linea vuota infodo al file\n"
  manca_EOF_msg_len: .long . - manca_EOF_msg
  fuori_intervallo_msg: .ascii "Uno dei valori al interno del file non rientra nelle specifiche del progetto: " 
  fuori_intervallo_msg_len: .long . - fuori_intervallo_msg
  nuova_linea: .asciz "\n"
  nuova_linea_len: .long . - nuova_linea
  # I/O
	fd: .long 0
	buffer: .asciz ""
	input: .space 8
.section .bss
	valori_tot: .long 0
	array: .fill Oggetti_Totali_MAX, 4, 0
	scrivi: .long 0
.section .text
	.global _start

_start:
	# ottieni il nome del file da leggere
	popl %ebx
	popl %ebx 
	popl %ebx 
	testl %ebx, %ebx
	je NO_ARG
	jmp OPEN
MENU:
	# menu
	leal menu, %eax	
  pushl menu_len
	pushl %eax
	call STAMPA_STR
	addl $8, %esp

	# leggi da stdin
	movl $3, %eax			
	movl $0, %ebx
	movl $input, %ecx
	movl $8, %edx   # uguale a spazio per input
	int $0x80

	movb input, %al
	cmpb $51, %al			# "3"
	je _exit
	cmpb $50, %al     # "2"
	je HPF
	cmpb $49, %al     # "1"
	je EDF
	jmp MENU

EDF:	# Opzione 1
	leal EDF_msg, %eax
  pushl EDF_msg_len
	pushl %eax
	call STAMPA_STR
	addl $8, %esp

	leal array, %eax
	pushl valori_tot
	pushl $2	# Scadenza
	pushl %eax	
	call ALGORITMO
	addl $12, %esp
	jmp MENU

HPF:   # Opzione 2
	leal HPF_msg, %eax
  pushl HPF_msg_len
	pushl %eax
	call STAMPA_STR
	addl $8, %esp

	leal array, %eax
	pushl valori_tot
	pushl $3	# Priorita
	pushl %eax
	call ALGORITMO
	addl $12, %esp
	jmp MENU

_exit:  # Opzione 3
	movl $1, %eax
	movl $0, %ebx
	int $0x80

NO_ARG:
	leal no_arg_msg, %ecx
  pushl no_arg_msg_len
	pushl %ecx
	call STAMPA_STR
	addl $8, %esp 
	jmp _exit


# Lettura file
OPEN: # Apre
  xorl %ecx, %ecx
  movl $5, %eax       # Syscall open
  # Nome del file ebx
  movb scrivi, %cl
  int $0x80
  cmpl $0, %eax 			# Se c'è un errore in apertura da errore
  jl NOME_SBAGLIATO
	movl %eax, fd

preLEGGI: # Prepara registiri per LEGGI
 	xorl %esi, %esi 		# Usato come contatore per valori_tot
	xorl %eax, %eax     # usato come valore temporaneo per itoa

LEGGI:  # Legge un dato alla volta e converte da argument ad integer poi, 
        # alla fine del numero salva il valore nel array
	pushl %eax
  movl $3, %eax   # syscall read
  movl fd, %ebx
  leal buffer, %ecx
  movl $1, %edx   # 1 carattere alla volta
  int $0x80

  cmpl $0, %eax   # controllo fine file
	jle CHECK_VALORI
  # jl CHIUDI_FILE FIXME:
  # xorl %ebx, %ebx FIXME:
	movb buffer, %bl
	popl %eax
  cmpb $10, %bl   # LF
  je SALVA_VAL
	cmpb $13, %bl   # CR
  je LEGGI
	cmpb $44, %bl   # ","
  je SALVA_VAL

	cmpb $48, %bl
	jb NAN         # controllo NAN
	cmpb $57, %bl
	ja NAN

	subb $48, %bl			# itoa
  movl $10, %edx
  mulb %dl
  addb %bl, %al			
  jmp LEGGI

SALVA_VAL:
	movb %al, array(%esi)
	movb $0, %al				  # azzera al per il prossimo numero
	inc %esi              # vai al prossimo posto nel array
	jmp LEGGI

CHECK_VALORI: # Controlla valori nel array e chiude il file
	movl %esi, %eax
	movl %eax, %ebx     # Salva eax

  sarl $2, %ebx       # / 4
  sall $2, %ebx       # x 4
  cmpl %ebx, %eax     # Confronta il risultato con l'originale %eax
  jne MANCA_EOF       # Salta se valori_tot non é divisibile per 4. 
                      # Quindi gli oggeti non sono stati letti corretamente.
                      # Questo é di solito dovuto alla mancaza di una nuova linea alla fine del ultima righa.
                      # Oppre a piu o meno di 3 "," per riga.
	dec	%esi
	sar $2, %eax			  # elementi_tot / 4 = valori_tot

	movl %esi, %ebx     # conto per scrollare l'array
	movl %eax, valori_tot	# Salvo per piu tardi.
	xorl %eax, %eax

CICLO_CHECK_VALORI:
	movb array(%ebx), %al # 1 <= P <= 5
	cmpb $1, %al
	jl FUORI_INTEVALLO
	cmpb $5, %al
	jg FUORI_INTEVALLO
	dec %ebx
	movb array(%ebx), %al # 1 <= S <= 100
	cmpb $1, %al
	jl FUORI_INTEVALLO
	cmpb $100, %al
	jg FUORI_INTEVALLO
	dec %ebx
	movb array(%ebx), %al # 1 <= D <= 10
	cmpb $1, %al
	jl FUORI_INTEVALLO
	cmpb $10, %al
	jg FUORI_INTEVALLO
	dec %ebx
	movb array(%ebx), %al # ID (1 <= ID <= 127)
	cmpb $1, %al
	jl FUORI_INTEVALLO
	cmpb $127, %al
	jg FUORI_INTEVALLO
	dec %ebx
	cmpl $0, %ebx
	jg	CICLO_CHECK_VALORI
  # quando ebx(il conto che diminuisce) arriva a 0 abbiamo controllato tutti i valori

FINE_LETTURA: # se tutto si é correto si arriva qua.
  movl $6, %eax
  movl fd, %ecx
  int $0x80
	jmp MENU


# Errori nel appertura
ERRORE: # exit(1)
	movl $1, %eax
	movl $1, %ebx
	int $0x80

NOME_SBAGLIATO:
	leal nome_sbagliato_msg, %eax
  pushl nome_sbagliato_msg_len
	pushl %eax
	call STAMPA_STR
	addl $8, %esp 
	jmp ERRORE

# Errori nella lettura
CHIUDI_FILE:
	movl $6, %eax
  movl fd, %ecx
  int $0x80

  # exit(1)
	movl $1, %eax
	movl $1, %ebx   
	int $0x80

FUORI_INTEVALLO:
	leal fuori_intervallo_msg, %ecx
  pushl fuori_intervallo_msg_len
	pushl %ecx
	call STAMPA_STR
	addl $8, %esp 
  # numero in eax
	call STAMPA_NUM
	leal nuova_linea, %ecx
  pushl nuova_linea_len
	pushl %ecx
	call STAMPA_STR
	addl $8, %esp 

	jmp CHIUDI_FILE

NAN:
	leal nan_msg, %eax
  pushl nan_msg_len
	pushl %eax
	call STAMPA_STR
	addl $8, %esp
	jmp CHIUDI_FILE

MANCA_EOF:
	leal manca_EOF_msg, %eax
  pushl manca_EOF_msg_len
	pushl %eax
	call STAMPA_STR
	addl $8, %esp
	jmp CHIUDI_FILE
