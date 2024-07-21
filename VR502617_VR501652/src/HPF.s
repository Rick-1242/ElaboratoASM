.section .data
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

    movl 16(%ebp), TEMP_OBJECTS
    movl 8(%ebp), %esi      # esi points to the address of the first element in the array

 _printVals:        # TODO: test print everything
    cmpl $0, TEMP_OBJECTS

    xorl %eax, %eax
    movb (%esi), %al  # loads the value at address esi + offset(ebx) into al. In C: A = *(ptr_arr + ptr_offset)
    call itoa
    inc
    dec TEMP_OBJECTS
    jmp _printVals

    
    



_HPFret:
    movl %ebp, %esp 
    pop %ebp 
    ret
