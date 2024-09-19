.section .data
  # Costanti
	Tempo_Massimo = 100
  Identificativo = 0
	Durata = 1
	Scadenza = 2
	Priorita = 3
  # Testo
	colon: .ascii ":"
  colon_len: .long . - colon
	newLine: .ascii "\n"
  newLine_len: .long . - newLine
	conclusionemsg: .ascii "Conclusione: "
  conclusionemsg_len: .long . - conclusionemsg
	penaltymsg: .ascii "Penalty: "
  penaltymsg_len: .long . - penaltymsg
.section .text
  .globl ALGORITMO
	.globl PENALITA

.type ALGORITMO, @function
ALGORITMO:
  push %ebp 
  movl %esp, %ebp 
	movl 16(%ebp), %ebx		# valori_tot
	# 12(%ebp)				    # indice sort
  movl 8(%ebp), %esi		# array

  pushl %ebx				# valori_tot
  pushl 12(%ebp)		# indice sort
  pushl %esi				# array
  call SORT
  addl $12, %esp
	dec %ebx				    # A noi serve l'indice dei valori, non la dimensione totale quindi -1
	xor %ecx, %ecx			# tempo index
	xor %eax, %eax			# Penalita

	cmpl $3, 12(%ebp)
	jne _newObject
	# Se stiamo eseguendo in HPF, quindi l'indice sort non é 3 dobbiamo scorrere 
  # l'array ordianto al contrario quindi parire da infondo
	shl $2, %ebx    # Moltiplicamo in numero di oggeti totali per 4 per ottenre i valori.
	addl %ebx, %esi # Poi lo sommiamo al indirzzo base del array per arrivare infondo
	shr $2, %ebx    # Reinpostiamo il contantore al numero di oggenti totali.
	jmp _newObject

_nextObject:
	# # Keep track of what object we are working with, to not go out of bounds.
	cmpl $0, %ebx   # controllo se siamo arrivanti infondo al array
  je ALGORITMO_FINITO
	dec %ebx
	cmpb %cl, Scadenza(%esi)	# compara scadenza e tempo
	jge _calcNextObject
	call PENALITA  # se la scadenza < tempo allora devo calcoare la penalita

_calcNextObject:
	addl $4, %esi     # Prossimo oggetto
	cmpl $3, 12(%ebp)
	jne _newObject
	subl $8, %esi     # Se HPF allora dobbiamo andare al contraio +4-8 = -4 

_newObject:
	movb Durata(%esi), %dl	# Salva la durata per poterla decrementare
	pushl %eax

	# Identificativo:tempo
  movzbl Identificativo(%esi), %eax
  call STAMPA_NUM
  pushl colon_len
	pushl $colon
	call STAMPA_STR
	addl $8, %esp
  movl %ecx, %eax
  call STAMPA_NUM
  pushl newLine_len
	pushl $newLine
	call STAMPA_STR
	addl $8, %esp

	popl %eax
_timeLoop:
	inc %ecx                   # Avanza il tempo
	cmpl $Tempo_Massimo, %ecx  # Se il tempo == al tempo massimo allora abbimo finito
	je ALGORITMO_FINITO

	dec %dl						# Altrimenti l' unita di tempo é stata usato dal oggeto e dobbiamo decrementare la durata
	jle _nextObject		# Se la nuvoa durata é 0 allora abbiamo finito con quel oggeto.
	jmp _timeLoop			# In caso contratio contiuiamo

ALGORITMO_FINITO:
	cmpb %cl, Scadenza(%esi)	# ultimo check per la penalita
	jge ALGORITMO_STAMPA
	call PENALITA

ALGORITMO_STAMPA:
	pushl %eax

  # Conclusione: n
  # Penalty: n
  pushl conclusionemsg_len
	pushl $conclusionemsg
	call STAMPA_STR
	addl $8, %esp
  movl %ecx, %eax				
  call STAMPA_NUM
  pushl newLine_len
	pushl $newLine
	call STAMPA_STR
	addl $8, %esp
  pushl penaltymsg_len
	pushl $penaltymsg
	call STAMPA_STR
	addl $8, %esp
	popl %eax
  call STAMPA_NUM
  pushl newLine_len
	pushl $newLine
	call STAMPA_STR
	addl $8, %esp

  movl %ebp, %esp 
  pop %ebp 
  ret

.type PENALITA, @function
PENALITA:   # Calcola la penalita incrementale del oggetto a cui punta esi.
	push %ebp 
  movl %esp, %ebp 
	push %ebx
	push %ecx

  xorl %ebx, %ebx
	movb Scadenza(%esi), %bl    # Scadenza in bl
	subl %ebx, %ecx             # tempo - scadenza. Risultato in ecx.
	movb Priorita(%esi), %bl  
	imull %ebx, %ecx            # (tempo - scadenza) * priorita. Risulato in ecx.
	addl %ecx, %eax             # Penalita = Penalita vecchia + ecx
                 
	pop %ecx
	pop %ebx
	movl %ebp, %esp 
  pop %ebp 
  ret
