.globl main
# De initiele beweging doet raar, als je naar links beweegt win je automatisch, als je naar rechts beweegt dan slaagt die een pixel over en als je naar boven of onder beweegt dan gaat die schuin. Geen idee waarom. Na deze eerste beweging werkt het wel zoals het zou moeten
.data
mazeFilename:    .asciiz "input_2.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "\nYou have won the game!"
delay:		.word 60
invalid: 	.asciiz "Invalid user input."
error:		.asciiz "That's a wall."
initialMessage:	.asciiz "Welcome to PAC-MAN.\n"
moveMessage:	.asciiz "To move, use WASD. To exit press x\n"
input:		.asciiz "Input: "

amountOfRows:    .word 16  # The amount of rows of pixels
amountOfColumns: .word 32  # The amount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

.text

# Memory addresses:
# - File-related data
# $s0 - File descriptor
# $t0 - Counter for pixel drawing loop
# $t1 - Current player position (memory address)
# $t3 - Current color to be drawn
# $t4 - Calculated memory address for drawing a pixel
# $t5 - Current character read from the buffer
# $t6 - Calculated memory address for storing colors
# $s7 - Buffer pointer

# - Display-related data
# $s1 - amountOfColumns

# - Color definitions
# $s2 - wallColor
# $s3 - passageColor
# $s4 - playerColor
# $s5 - exitColor
# $s6 - Total number of pixels to draw

main:
	la $a0, initialMessage
	li $v0, 4
	syscall
	la $a0, moveMessage
	li $v0, 4
	syscall
	la $a0, input
	li $v0, 4
	syscall
loadMaze:
	# Allocate stack
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $t0, 4($sp)
	sw $s6, 0($sp)
	# Read file, $v0 is stored in $s0
	li $v0, 13 	# Read file
	la $a0, mazeFilename
	li $a1, 0 	# 0 for reading
	syscall
	move $s0, $v0
	# Load file, put $s0 into $a0
	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	la $a2, 4096
	syscall
loadBitmap:
	# Initialize
	lw $s0, amountOfColumns
	lw $s1, amountOfRows
	lw $s2, wallColor
	lw $s3, passageColor
	lw $s4, playerColor
	lw $s5, exitColor
	mul $s6, $s0, $s1	# Total number of pixels
	li $t0, 0		# Counter
	la $s7, buffer
drawPixel:
	bge $t0, $s6, closeFile	# When all the pixels are filled, jump to closeFile
	lb $t5, 0($s7)		# Load a byte from the buffer
	beq $t5, 119, setWallColor
	beq $t5, 117, setExitColor
	beq $t5, 112, setPassageColor
	beq $t5, 115, setPlayerColor
	beq $t5, 10, newLine
newLine:
	addi $s7, $s7, 1
	j drawPixel
setWallColor:
	move $t3, $s2
	j loadNextCharacter
setExitColor:
	move $t3, $s5
	j loadNextCharacter
setPassageColor:
	move $t3, $s3
	j loadNextCharacter
setPlayerColor:
	move $t3, $s4
	sll $t4, $t0, 2
    	add $t6, $gp, $t4
    	sw $t3, ($t6)
    	addi $t0, $t0, 1
    	addi $s7, $s7, 1
    	# Save current position of player (usefull later)
    	la $t1, ($t6)	# Memory address
    	divu $t2, $t0, $s0	# Calculate current row
	mfhi $t7		# Remainder is current column
    	j drawPixel
loadNextCharacter:
    	# Calculate memory address
    	sll $t4, $t0, 2
    	add $t6, $gp, $t4
    	sw $t3, ($t6)
    	addi $t0, $t0, 1
    	addi $s7, $s7, 1
    	j drawPixel
closeFile:
	li $v0, 16 	# Close file
	move $a0, $s0
	syscall
	# Deallocate stack
	lw $ra, 8($sp)
    	lw $t0, 4($sp)
    	lw $s6, 0($sp)
    	addi $sp, $sp, 12
##########################################################################################################################################################################################
# $a0 - Current row
# $a1 - Current column
# $a2 - New row
# $a3 - New column
# $t1 - Current player position (memory address)
# $t2 - Player input
# $t3 - Current color to be drawn
# $t8 - New player position
initializePlayerMovement:
	move $a0, $t2
	move $a1, $t7
playerMovement:
	# Read player input and store it in $t2
	li $v0, 12
	syscall
	move $t2, $v0
	beq $t2, 122, playerUp
	beq $t2, 113, playerLeft
	beq $t2, 115, playerDown
	beq $t2, 100, playerRight
	beq $t2, 120, exit
	# Invalid input
	move $t2, $a0
	la $a0, invalid
	li $v0, 4
	syscall
	move $a0, $t2
	j delayLoop
drawPlayerPixel:
	move $t3, $s3
	sw $t3, ($t1)
	move $t3, $s4
	sw $t3, ($t8)
	move $t1, $t8
	move $a0, $a2
	move $a1, $a3
	j delayLoop
playerUp:
	subi $a2, $a0, 1	# Calculate the new row
	move $a3, $a1		# Keep same column
    	mul $t8, $a2, $s0
    	add $t8, $t8, $a3
    	sll $t8, $t8, 2
    	add $t8, $t8, $gp
	j movementCheck
playerLeft:
	subi $a3, $a1, 1	# Calculate the new column
	move $a2, $a0		# Keep same row
	mul $t8, $a2, $s0
    	add $t8, $t8, $a3
    	sll $t8, $t8, 2
    	add $t8, $t8, $gp
	j movementCheck
playerDown:
	addi $a2, $a0, 1	# Calculate the new row
	move $a3, $a1		# Keep same column
	mul $t8, $a2, $s0
    	add $t8, $t8, $a3
    	sll $t8, $t8, 2
    	add $t8, $t8, $gp
	j movementCheck
playerRight:
	addi $a3, $a1, 1	# Calculate the new column
	move $a2, $a0		# Keep same row
	mul $t8, $a2, $s0
    	add $t8, $t8, $a3
    	sll $t8, $t8, 2
    	add $t8, $t8, $gp
	j movementCheck
delayLoop:
	lw $t9, delay
	li $v0, 32
	syscall
	j playerMovement
movementCheck:
    	# Load the color value from the memory address in $t8
    	lw $t9, ($t8)
    	# Compare with wallColor
    	beq $t9, $s2, playerMovement
    	# Compare with passageColor
    	beq $t9, $s3, drawPlayerPixel
    	# Compare with exitColor
    	beq $t9, $s5, playerVictory
playerVictory:
	move $t3, $s3
	sw $t3, ($t1)
	move $t2, $a0
	la $a0, victoryMessage
	li $v0, 4
	syscall
	move $a0, $t2 
exit:
    	# syscall to end the program
    	li $v0, 10    
    	syscall
