.data
width:  .word 32      # Width of 32 pixels (assuming each pixel is 32 bits)
height: .word 16      # Height of 16 pixels
red:    .word 0xFF0000   # Red color (hex)
yellow: .word 0xFFFF00   # Yellow color (hex)
blue:	.word 0x0000FF


.text
main:
    	lw $s0, width
    	lw $s1, height
    	lw $s2, red
    	lw $s3, yellow
    	lw $s4, blue
    	li $t0, 0
	
	
    	mul $s4, $s0, $s1
    	

    	# Loop through each pixel and color it
    	li $t0, 0


draw_pixels:
    	bge $t0, $s4, exit    # If all pixels are colored, exit the program

    	# Calculate current row and column
 	divu $t1, $t0, $s0  # Calculate row (t1)
    	mfhi $t2            # Remainder is the column (t2)

	# Calculate $s1-1 and $s0-1 separately
    	subi $t7, $s1, 1   # Calculate $s1-1 and store it in $t6
    	subi $t8, $s0, 1 

    	# Check if it's the last row or last column respectivly, select yellow
    	beq $t1, $t7, select_yellow
    	beq $t2, $t8, select_yellow
	
    	# Select color based on conditions
    	beq $t1, 0, select_yellow  # If it's the first row, select yellow
    	# beq $t1, $s1-1, select_yellow  # If it's the last row, select yellow
    	beq $t2, 0, select_yellow  # If it's the first column, select yellow
    	# beq $t2, $s0-1, select_yellow  # If it's the last column, select yellow

    	# If not on the border, select red
    	move $t3, $s2
    	j fill_pixel

select_yellow:
    move $t3, $s3

fill_pixel:
    	# Multiply i with 4 to get the address
	sll 	$t2, $t0, 2
	# Add the relative address to gp address
	add 	$t4, $gp, $t2
	# Write the color red to the bitmap memory
	sw 	$t3, ($t4)
	# i++
	addi 	$t0, $t0, 1
	j draw_pixels

exit:
    	# Terminate the program
    	li $v0, 10
    	syscall
