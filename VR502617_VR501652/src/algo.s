.section .data
	tempfd: .long 0
	colon: .asciz ":"
	newLine: .asciz "\n"
	conclusionemsg: .asciz "Conclusione: "
	penaltymsg: .asciz "Penalty: "

	MAX_TIME = 100
    OBJECT_SIZE = 4	
    ID_OFFSET = 0
	DURATION_OFFSET = 1
	DEADLINE_OFFSET = 2
	PRIORITY_OFFSET = 3
.section .text
    .globl ALGO
	.globl calcPenalty

.type ALGO, @function
ALGO:
    push %ebp 
    movl %esp, %ebp 

	# 20(%ebp)				# sortingID
	movl 16(%ebp), %ebx		# totalObjects
	movl 12(%ebp), %eax		# tempfd. if (tempfd != 0) then write to file
	movl %eax, tempfd
    movl 8(%ebp), %esi		# &ordiniArr

    pushl 20(%ebp)			# sortingID
    pushl %ebx				# totalObjects
    pushl %esi				# &ordiniArr
    call bubbleSort
    addl $12, %esp

	dec %ebx				# Set N-1 for array index, not size
	xor %ecx, %ecx			# currentTime index
	xor %eax, %eax			# Penalty

	cmpl $3, 20(%ebp)		# if not HPF then contiune normaly
	jne _newObject

	# else set esi to the last item in the array.
	shl $2, %ebx			# Multyply by 4
	addl %ebx, %esi 		# Set esi to the end of the array
	shr $2, %ebx			# Reset ebx
	jmp _newObject

#------------------ Loop start ------------------
_nextObject:
	# Keep track of what object we are working with, to not go out of bounds.
	cmpl $0, %ebx			# Check if we have cycled all the objects
    je _ALGODone
	dec %ebx

	cmpb %cl, DEADLINE_OFFSET(%esi)	# Compare current time to deadline
	jge _calcNextObject

	call calcPenalty		# if deadline is < currentTime then calcPenalty

_calcNextObject:
	addl $4, %esi			# Move to the next object
	cmpl $3, 20(%ebp)		# If not HPF we can continiue
	jne _newObject

	subl $8, %esi			# Else we need to do the opposite.

_newObject:
	movb DURATION_OFFSET(%esi), %dl	# store leftover duration
	pushl %eax

	# print("ID:currentTime\n")
    movzbl ID_OFFSET(%esi), %eax
	pushl tempfd
    call printWRITEINT
	addl $4, %esp
	pushl tempfd				# file to write
	pushl $colon
	call printWRITESTR
	addl $8, %esp
    movl %ecx, %eax
	pushl tempfd
    call printWRITEINT
	addl $4, %esp
	pushl tempfd				# file to write
	pushl $newLine
	call printWRITESTR
	addl $8, %esp

	popl %eax

_timeLoop:
	inc %ecx					# Advace time
	cmpl $MAX_TIME, %ecx		# if currentTime = MAX_TIME then we are done.
	je _ALGODone

	dec %dl						# else time slot has been used by the item pointed to by esi and we have to decrese it's duration.
	jle _nextObject				# if we now have duration = 0 then we advance to next object.

	jmp _timeLoop				# else we contiunue the loop
#------------------ Loop end ------------------

_ALGODone:
	cmpb %cl, DEADLINE_OFFSET(%esi)	# compare current time to deadline
	jge _ALGOret
	call calcPenalty

_ALGOret:
	pushl %eax

	pushl tempfd				# file to write
	pushl $conclusionemsg		# print("Conclusione: ")
	call printWRITESTR
	addl $8, %esp

   	movl %ecx, %eax				# print(currentTime)
	pushl tempfd
    call printWRITEINT
	addl $4, %esp

	pushl tempfd				# file to write
	pushl $newLine				# print("\n")
	call printWRITESTR
	addl $8, %esp

	pushl tempfd				# file to write
	pushl $penaltymsg			# print("Penalty: ")
	call printWRITESTR
	addl $8, %esp

	popl %eax					# print(penalty)
	pushl tempfd
    call printWRITEINT
	addl $4, %esp

	pushl tempfd				# file to write
	pushl $newLine				# print("\n")
	call printWRITESTR
	addl $8, %esp

    movl %ebp, %esp 
    pop %ebp 
    ret


.type calcPenalty, @function
calcPenalty: # Penalty = (current_time - deadline) * priority + Penalty. This is stored in eax
	push %ebp 
    movl %esp, %ebp 
	push %ebx
	push %ecx

	movzbl DEADLINE_OFFSET(%esi), %ebx	# Load deadline into %ebx
	subl %ebx, %ecx						# current_time - deadline (result in %cl)
	movzbl PRIORITY_OFFSET(%esi), %ebx  
	imull %ebx, %ecx					# (current_time - deadline) * priority (result in %cl)
	addl %ecx, %eax						# Penalty = (current_time - deadline) * priority + Penalty
                 
	pop %ecx
	pop %ebx
	movl %ebp, %esp 
    pop %ebp 
    ret
