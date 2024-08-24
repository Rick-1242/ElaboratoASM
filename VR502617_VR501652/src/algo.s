.section .data
	colon: .asciz ":"
	newLine: .asciz "\n"
	conclusionemsg: .asciz "Conclusione: "
	penaltymsg: .asciz "Penalty: "

	MAX_TIME = 100
    OBJECT_SIZE = 4	
    IDENTIFICATIVO_OFFSET = 0
	DURATA_OFFSET = 1
	SCANDEZA_OFFSET = 2
	PRIORITA_OFFSET = 3
.section .text
    .globl ALGO

.type ALGO, @function

ALGO:
    push %ebp 
    movl %esp, %ebp 

	# 20(%ebp)				# sortingID
	movl 16(%ebp), %ebx		# totalObjects
	#  12(%ebp)  			# writeFile
    movl 8(%ebp), %esi		# ordiniArr

	dec %ebx				# set N-1 for array values not size

    pushl 20(%ebp)			# sortingID
    pushl %ebx				# totalObjects
    pushl %esi				# ordiniArr
    call bubbleSort
    addl $12, %esp

	xor %ecx, %ecx			# currentTime index

	cmpl $3, 20(%ebp)		# if not HPF then contiune normaly
	jne _newObject

	# else set esi to the last item in the array.
	shl $2, %ebx	# Multyply by 4
	addl %ebx, %esi # Set esi to the end of the array
	shr $2, %ebx	# Reset ebx
	jmp _newObject

_nextObject:
	# Keep track of what object we are working with, to not go out of the array.
	cmpl $0, %ebx			# Check if we have cycled all the objects
    je _ALGODone
	dec %ebx

	addl $4, %esi			# Move to the next object
	cmpl $3, 20(%ebp)		# If not HPF we can continiue
	jne _newObject

	subl $8, %esi			# Else we need to do the opposite.

_newObject:
	movb DURATA_OFFSET(%esi), %dl	# store leftover duration in temporary variable

	# print ID:currentTime\n
    movzbl IDENTIFICATIVO_OFFSET(%esi), %eax
    call printINT
	pushl $colon
	call printSTR
	addl $4, %esp
    movl %ecx, %eax
    call printINT
	pushl $newLine
	call printSTR
	addl $4, %esp

_timeLoop:
	inc %ecx					# Advace time
	cmpl $MAX_TIME, %ecx
	je _ALGODone					# if currentTime = MAX_TIME then we are done.

	dec %dl						# else time slot has been used by the item pointed to by esi 
								# and we have to decrese it's duration.
	jle _nextObject				# if we now have duration = 0 then we advance to next object.

	jmp _timeLoop				# else we contiunue the loop


# TODO: writing to file option HERE. always if check no more call printSTR. JMP printALGOSTR
# in print algo str IF writeFile.


_ALGODone:
	# TODO: calculate penalty of last object

	pushl $conclusionemsg	# print("Conclusione: ")
	call printSTR
	addl $4, %esp

   	movl %ecx, %eax			# print(currentTime)
    call printINT
	
	pushl $newLine			# print("\n")
	call printSTR
	addl $4, %esp
	
	pushl $penaltymsg		# print("Penalty: ")
	call printSTR
	addl $4, %esp

	movl %ecx, %eax			# print(penalty)
    call printINT
	
	pushl $newLine			# print("\n")
	call printSTR
	addl $4, %esp

    movl %ebp, %esp 
    pop %ebp 
    ret
