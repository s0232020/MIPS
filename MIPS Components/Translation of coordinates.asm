.data
width:  .word 32    # Width of 32 pixels (assuming each pixel is 32 bits)
height: .word 16    # Height of 16 pixels

.text
main:
    	# Read x and move input to $a0
    	li $v0, 5
    	syscall
    	move $a0, $v0

    	# Read y and move input to $a1
    	li $v0, 5
    	syscall
    	move $a1, $v0

    	# Jump to translate_coordinates and save return address in $ra
    	jal translate_coordinates

    	# Print the result (memory address)
    	li $v0, 1
    	move $a0, $t0
    	syscall

    	# Exit program
    	li $v0, 10
    	syscall

translate_coordinates:
    	# Stack frame setup
    	sub $sp, $sp, 8      # Allocate space for two local variables on the stack
    	sw $ra, 4($sp)       # Save the return address on the stack
    	sw $t1, 0($sp)       # Save $t1 on the stack

    	# x = a0
    	# y = a1

    	# Load pixel width and store it in $t1
    	lw $t1, width

    	# Calculate memory address
    	mul $t0, $a1, $t1    # Multiply width by column (y)
    	add $t0, $t0, $a0    # Add row (x) to calculate offset
    	sll $t0, $t0, 2      # Convert offset to bytes (each pixel is 4 bytes)

    	# Add offset to base address (assumed to be in $gp)
    	add $t0, $t0, $gp

    	# Stack frame cleanup
    	lw $t1, 0($sp)       # Restore $t1 from the stack
    	lw $ra, 4($sp)       # Restore the return address from the stack
    	add $sp, $sp, 8      # Deallocate the stack space

    	jr $ra               # Return from function
