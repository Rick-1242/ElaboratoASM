.section .data
    OBJECT_SIZE = 4	
    IDENTIFICATIVO_OFFSET = 0
	DURATA_OFFSET = 1
	SCANDEZA_OFFSET = 2
	PRIORITA_OFFSET = 3
.section .text
    .globl EDF

.type EDF, @function

EDF:
    push %ebp 
    movl %esp, %ebp 

    movl 8(%ebp), %esi		# ordiniArr
	movl 16(%ebp), %ecx		# totalObjects

    pushl $2				# Scadenza
    pushl %ecx
    pushl %esi
    call bubbleSort
    addl $12, %esp

    
_EDF_done:
    movl %ebp, %esp 
    pop %ebp 
    ret
