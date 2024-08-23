.section .data
    colon: .asciz ":"
    newLine: .asciz "\n"

	TEMPO_MASSIMO = 100
    OBJECT_SIZE = 4	
    IDENTIFICATIVO_OFFSET = 0
    DURATA_OFFSET = 1
    SCANDEZA_OFFSET = 2
    PRIORITA_OFFSET = 3
.section .bss
    TEMP_OBJECTS: .long 0
.section .text
    .globl HPF

.type HPF, @function
HPF:
    push %ebp 
    movl %esp, %ebp 
    # 16(%ebp) == TOTAL_OBJECTS
    # 12(%ebp) == writeFile

    movl 16(%ebp), %ebx
    movl 8(%ebp), %esi      # esi points to the address of the first element in the array
    xorl %ecx, %ecx

 _printVals:        # TODO: test print everything
    cmpl $0, %ebx
    je _HPFret

    

    xorl %eax, %eax
    movb IDENTIFICATIVO_OFFSET(%esi,%ecx,OBJECT_SIZE), %al  # loads the value at address esi + offset(ebx) into al. In C: A = *(ptr_arr + ptr_offset)
    call printINT

    leal colon, %eax
	pushl %eax
	call printSTR
	addl $4, %esp


    inc %ecx
    dec %ebx

    jmp _printVals

    
    



_HPFret:
    leal newLine, %eax
	pushl %eax
	call printSTR
	addl $4, %esp

    movl %ebp, %esp 
    pop %ebp 
    ret
