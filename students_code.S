.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
	
	# counter = 0
	movl $0, %ecx

	# iteration_num = 16
	movl $16, %edx

	
KM_HW2:
	#input value
	movb (%rdi), %r8b
	
	#key value
	movb (%rsi), %r9b
	
	#xor between keyVal & inputVal
	xorb %r9b, %r8b
	movb %r8b, (%rdi)

	inc %ecx
	
	# update input & key address
	lea 1(%rdi), %rdi
	lea 1(%rsi), %rsi

	# check if iteration_num == 16
	cmp %ecx, %edx
	jne KM_HW2
	
	ret


byteSubstitution:

	# counter = 0
	movl $0, %ecx

	#iteration_num = 16
	movl $16, %edx

	# move the adress of sbox to register
	leaq sbox(%rip), %r11

BS_HW2:

	# save input current value
	movzbq (%rdi), %r8

	# get value from sbox
	movb (%r11, %r8), %r10b

	# update value in input table
	movb %r10b, (%rdi)

	# inc counter
	inc %ecx

	# update input adress for next iteration
	lea 1(%rdi), %rdi

	# check if counter == 16
	cmp %ecx, %edx
	jne BS_HW2

	ret


shiftRows:


#rotate 8 bits left in line #1 (second row) in the input
	rorl $8, 4(%rdi)

	#rotate 16 bits left in line #2 (third row) in the input
	rorl $16, 8(%rdi)

	#rotate 24 bits left in line #3 (forth row) in the input
	rorl $24, 12(%rdi)
	
	ret


cipher:
	# rdi -> input
	# rsi -> key
	# rdx -> len

	# push %rbp
	# mov %rsp, %rbp

main_loop_cipher_HW2:

	push %rdx
	
	push %rsi
	push %rdi
	call keyMixing
	pop %rdi
	pop %rsi

	# counter to inner loop
 	movq $9, %rcx
	
inner_loop_cipher_HW2:
	push %rcx

	push %rdi
 	call byteSubstitution
	pop %rdi

 	call shiftRows

	push %rsi
	push %rdi
 	call mixColumns
	pop %rdi
	pop %rsi

	push %rsi
	push %rdi
 	call keyMixing
	pop %rdi
	pop %rsi

 	# check if inner counter == 0
	pop %rcx
 	decq %rcx
 	testq %rcx, %rcx
 	jnz inner_loop_cipher_HW2

	# after inner loop:
	push %rdi
 	call byteSubstitution
	pop %rdi

	call shiftRows

	push %rsi
	push %rdi
 	call keyMixing
	pop %rdi
	pop %rsi


	# check if main loop counter == 0
	pop %rdx
	decq %rdx
	cmpq $0, %rdx
	je end_cipher_HW2

	# update input to next block
	lea 16(%rdi), %rdi
	jmp main_loop_cipher_HW2
	
 end_cipher_HW2:
	# pop %rbp
	ret
