.section .data
.section .text
    .globl bubbleSort
    .type bubbleSort, @function # push sortIndex
                                # push totalObjects
                                # push base address of array
                                # call bubbleSort
                                # addl $12, %esp
bubbleSort:
    push %ebp
    movl %esp, %ebp
    push %eax				# Save registers
    push %ebx
    push %ecx
    push %edx
    push %esi
    push %edi

    movl 16(%ebp), %edx		# Load sortIndex into EDX
    movl 12(%ebp), %ecx		# Load number of objects (n) into ECX
    movl 8(%ebp), %esi		# Load base address of array (arr) into ESI

    decl %ecx
    jle done				# If no objects or only one, we're done

outer_loop:
    movl %ecx, %edi			# ecx = outer_loop_count; edi = inner_loop_count

inner_loop: 
    movb (%esi,%edx,1), %al   # First element
    movb 4(%esi,%edx,1), %bl  # Second element

    cmpb %bl, %al
    jbe no_swap				# If the first is less than or equal to the second, no swap needed

    movl (%esi), %eax		# Swap
    movl 4(%esi), %ebx
    movl %ebx, (%esi)
    movl %eax, 4(%esi)

no_swap:
    addl $4, %esi			# Move to the next object
    decl %edi
    jnz inner_loop			# If the inner loop counter is not zero, continue inner loop

    movl 8(%ebp), %esi		# Reset %esi to the start of the array
    decl %ecx
    jnz outer_loop			# If the outer loop counter is not zero, continue outer loop

done:
    pop %edi				# Restore registers
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    movl %ebp, %esp 
    pop %ebp

    ret
