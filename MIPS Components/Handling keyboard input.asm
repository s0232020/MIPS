.data
z: .asciiz "\nup\n"
s: .asciiz "\ndown\n"
q: .asciiz "\nleft\n"
d: .asciiz "\nright\n"
delay: .word 2000  # 2 seconds delay
invalid: .asciiz "\nUnknown input! Valid inputs: w a s d x\n"

.text
main:
    	# Stack frame setup
    	sub $sp, $sp, 8  # Allocate space for two temporary registers on the stack
    	sw $ra, 4($sp)   # Save the return address on the stack
    	sw $t0, 0($sp)   # Save $t0 on the stack

    	# Init
    	li $t1, 'z'
    	li $t2, 's'
    	li $t3, 'q'
    	li $t4, 'd'
    	li $t5, 'x'

loop:
    	# Read character
    	li $v0, 12
    	syscall
    	move $t0, $v0  # Save input in temporary register

   	# Compare with ASCII values
    	beq $t0, $t1, up
    	beq $t0, $t2, down
    	beq $t0, $t3, left
    	beq $t0, $t4, right
    	beq $t0, $t5, exit

    	# Invalid input, print error message
    	la $a0, invalid
    	li $v0, 4
    	syscall
    	j loop

up:
    	# Print 'up'
    	la $a0, z
    	li $v0, 4
    	syscall
    	j delay_loop

down:
    	# Print 'down'
    	la $a0, s
    	li $v0, 4
    	syscall
    	j delay_loop

left:
    	# Print 'left'
    	la $a0, q
    	li $v0, 4
    	syscall
    	j delay_loop

right:
    	# Print 'right'
    	la $a0, d
    	li $v0, 4
    	syscall
    	j delay_loop

exit:
    	# Stack frame cleanup
    	lw $t0, 0($sp)   # Restore $t0 from the stack
    	lw $ra, 4($sp)   # Restore the return address from the stack
    	add $sp, $sp, 8  # Deallocate the stack space

    	# Terminate the program
    	li $v0, 10
    	syscall

delay_loop:
    	# Load delay duration
    	lw $a0, delay
    	# Invoke delay
    	li $v0, 32
    	syscall
    	j loop
