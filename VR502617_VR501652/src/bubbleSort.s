.section .data
.section .text
    .globl bubbleSort
    .type bubbleSort, @function # pushl sortIndex
                                # pushl totalObjects
                                # pushl base address of array
                                # call bubbleSort
                                # addl $12, %esp
bubbleSort:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %edi
    pushl %esi

    movl 8(%ebp), %esi       # Load base address of array (arr) into ESI
    movl 12(%ebp), %ecx      # Load number of objects (n) into ECX
    movl 16(%ebp), %edx      # Load sortIndex into EDX

    decl %ecx                # Decrement ECX for loop control

outer_loop:
    movl %ecx, %ebx          # Set EBX to ECX (loop control variable)
    jle end_outer_loop       # If the number of objects is <= 1, end the loop

inner_loop:
    movl %ebx, %eax          # Set EAX to EBX (inner loop counter)
    decl %eax                # Decrement EAX (next object index)
    cmpl $0, %eax            # Compare EAX with 0
    jl decrement_outer       # If EAX < 0, decrement the outer loop control variable

    movl %ebx, %edi          # Set EDI to EBX (inner loop index)
    decl %edi                # Decrement EDI (current object index)

    imull $4, %edi           # EDI = EDI * 4 (calculate offset for current object)
    addl %esi, %edi          # EDI = base address + offset (arr[current_index])

    movl %eax, %ebx          # Set EBX to EAX (next object index)
    imull $4, %ebx           # EBX = EAX * 4 (calculate offset for next object)
    addl %esi, %ebx          # EBX = base address + offset (arr[next_index])

    movb (%edi, %edx), %al   # Load byte at (arr[current_index] + sortIndex) into AL
    movb (%ebx, %edx), %bl   # Load byte at (arr[next_index] + sortIndex) into BL

    cmpb %al, %bl            # Compare AL with BL
    jbe continue_inner       # If AL <= BL, continue the inner loop

    # Swap objects if necessary
    movl %edi, %esi          # Set ESI to EDI (address of current object)
    movl %ebx, %edi          # Set EDI to EBX (address of next object)

    # Swap 4 bytes (one object)
    movb (%esi), %al
    movb (%edi), %bl
    movb %bl, (%esi)
    movb %al, (%edi)

    movb 1(%esi), %al
    movb 1(%edi), %bl
    movb %bl, 1(%esi)
    movb %al, 1(%edi)

    movb 2(%esi), %al
    movb 2(%edi), %bl
    movb %bl, 2(%esi)
    movb %al, 2(%edi)

    movb 3(%esi), %al
    movb 3(%edi), %bl
    movb %bl, 3(%esi)
    movb %al, 3(%edi)

continue_inner:
    decl %ebx                # Decrement inner loop index (EBX)
    jmp inner_loop           # Continue inner loop

decrement_outer:
    decl %ecx                # Decrement outer loop control variable
    jnz outer_loop           # If outer loop control variable != 0, repeat outer loop

end_outer_loop:
    popl %esi
    popl %edi
    popl %ebx
    popl %ebp
    ret
