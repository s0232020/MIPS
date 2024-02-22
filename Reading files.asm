.data
fin: .asciiz "input_1.txt" # filename for input
buffer: .space 2048 # space used as buffer
.text
main:
	# Open (for reading) a file
	li $v0, 13 # system call for open file
	la $a0, fin # output file name
	li $a1, 0 # Open for writing (flags are 0: read, 1: write)
	li $a2, 0 # mode is ignored
	syscall # open a file (file descriptor returned in $v0)

	move $s6, $v0 # save the file descriptor


	# Read from file to buffer
	li $v0, 14 # system call for read from file
	move $a0, $s6 # file descriptor
	la $a1, buffer # address of buffer to which to load the contents
	li $a2, 2048 # hardcoded max number of characters (equal to size of buffer)
	syscall # read from file, $v0 contains number of characters read
	
	# Print the contents of the buffer
    	li $v0, 4         # system call for print_str
    	la $a0, buffer    # address of the buffer
    	syscall           # print string

	# Close the file
	li $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall # close file

exit:
    	# Terminate the program
    	li $v0, 10
    	syscall
