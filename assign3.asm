// Name: Nam Nguyen Vu
// UCID: 30154892
// Tutorial 1
// TA: Akram
// CPSC 355 Assignment 3

fmt:	.string "v[%d] = %d\n"				// Format the strong for printing array indexes and its value
	.balign 4					// Line for alignment
	.global main					// Line to branch the print to main

fmt1:	.string	"\nSorted array:\n"			// The line to print the line "Sorted array:"
	.balign 4					// Line for alignment
	.global main					// Line to branch the print to main

size = 40						// Size of the array = 40
array_size = size * 4					// Array size = 40 * size of each element is 4
i_s = 16						// i_start = 16 bytes after frame pointer start 
j_s = 20						// j_start = 20 bytes after frame pointer start
array_s = 24

allocation_size = array_size + array_s			// allocation size = array_s (where the array start) + size of the array

allocation = -(16 + allocation_size) & -16		// size of memory allocation
deallocation = -allocation				// size of memory deallocation after the program finished

	define(i1, w19)					// Define name for registers to make reading easier
	define(i2, w22)
	define(i3, w28)
	define(v_i1, w20)
	define(j, w23)
	define(j_minus1, w24)	

fp	.req	x29					// Register equates for x29 is fp
lr	.req	x30					// Register equates for x30 is lr

main:	stp	fp, lr, [sp, allocation]!		// allocate memory for the program
	mov 	fp, sp					// Move stack pointer to frame pointer

	mov	i1, 0					// Initialize i = 0 (For the initializing array loop)
	str	i1, [fp, i_s]				// Store value of i to i_start ( frame pointer + 16)
	b	test1					// Branch to initializing array loop test

loop1:	bl	rand					// Call rand() function, value store to w0
	and	v_i1, w0, 0xFF				// v[i] = rand() & 0xFF, store to w20
	add 	x21, fp, array_s			// Calculate Base Address
	ldr	i1, [fp, i_s]				// Load value of i 
	str	v_i1, [x21, i1, SXTW 2]			// Store v[i] to the array

	ldr 	x0, =fmt				// Format the print
	mov	w1, i1					// Format the first print variable to the value of i
	add 	x21, fp, array_s			// Calculate Base Address
	ldr	w2, [x21, i1, SXTW 2]			// Format the second print variable to the value of v[i]
	bl 	printf					// Call the print function

	add	i1, i1, 1				// i++
	str	i1, [fp, i_s]				// Store the value of i
	
test1:	cmp	i1, size				// Initializing array loop test 
	b.lt	loop1					// Branch back to the loop when i < size

debug1:	ldr	x0, =fmt1				// Print the "Sorted array:" line
	bl 	printf					// Call the print function

	mov	i2, size - 1				// i = size - 1 (different with the first loop i)
	str	i2, [fp, i_s]				// Store value of i to fp + i_start
	b	outerlooptest				// Branch to outerloop test

outerloop:
	mov	j, 1					// Initialize j = 1
	str	j, [fp, j_s]				// Store the value of j to fp + j_start
	b	innerlooptest				// Branch to innerloop test

innerloop:
	ldr	j, [fp, j_s]				// Load the value of j 
	add	x21, fp, array_s			// Calculate Base Address
	ldr	w25, [x21, j, SXTW 2]			// Load the value of v[j] to w25
	add	j_minus1, j, -1				// Load the value of j-1 to w24
	ldr	w26, [x21, j_minus1, SXTW 2]		// Load the value of v[j-1] to w26
	cmp	w26, w25				// Compare v[j-1] to v[j]
	b.le	add_j					// Skip the loop if v[j-1] <= v[j]

	mov     w27, w26				// temp = v[j-1]
        mov     w26, w25				// v[j-1] = v[j]
        mov     w25, w27				// v[j] = temp
	
	str	w25, [x21, j, SXTW 2]			// Store the value of v[j] to the stack
	str	w26, [x21, j_minus1, SXTW 2]		// Store the value of v[j-1] to the stack

add_j:	add	j, j, 1					// j--
	str	j, [fp, j_s]				// Store the value of j to fp + j_start

innerlooptest:
	cmp	j, i2					// Innerloop test
	b.le	innerloop				// Branch to innerloop if j <= i
	
	add	i2, i2, -1				// i++
	str	i2, [fp, i_s]				// Store the value of i to fp + i_start

outerlooptest:	
	cmp	i2, 0					// Outerloop test
	b.ge	outerloop				// Branch to outerloop if i >= 0

debug2:	mov	i3, 0					// Initialize i = 0 (third i - i of the last loop)
	str	i3, [fp, i_s]				// Store the value of i to i_start
	b	test2					// Branch to pre-test loop

print:	ldr     x0, =fmt				// Call the format of the print
        ldr	w1, [fp, i_s]				// Load the value of i to the first variable of the print
        add     x21, fp, array_s			// Calculate Base Address
	ldr	i3, [fp, i_s]				// Load the value of i to w28
        ldr     w2, [x21, i3, SXTW 2]			// Load the value of v[i] to the second variable of the print
        bl      printf					// Call print function

	add	i3, i3, 1				// i++
	str	i3, [fp, i_s]				// Store the value of i to fp + i_start

test2:	cmp	i3, size				// Compare i and 40
	b.lt	print					// If i < 40, continue the loop, otherwise done with the print

exit:	mov	w0, 0					// The last three line to end the program
	ldp	fp, lr, [sp], deallocation
	ret
