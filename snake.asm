.data #goal is teal border and light blue inside
lightBlue:	.word 0x7EC0EE
teal:	.word 0x003B3D
bodycol:	.word 0xFFFF66 #yellow
headcol:	.word 0xFF66FF #purple fyi:ffff66 is yellow
fruit: 	.word 0xFF6666 #red

#directional info:- up: $t0 - 128, down: +128, left: -4, right: +128
#$t0 mo

.text
main:
	lw $t1, teal($0)
	addi $t0, $gp, 0
	li $t3, 0
	j loop
#below here makes the inital board
loop:
	
		beq $t3, 32, drawhead #Counter for height (do this until its done it 256 times (height)). Exit at end
		addi $t3, $t3, 1 #increment by 1
		li $t2, 0 #counter for length of row (loop of drawWorld)
		jal drawRow #draw the row. Julia, you use 'jal' here but the program never actually returns to this point...


drawRow:
	#conditionals to color edges
	beq $t3, 1, edge
	beq $t3, 32, edge
	beq $t2, 0, edge
	beq $t2, 31, edge
	lw $t1, lightBlue($0)
	j colorKnown
	edge:
		lw $t1, teal($0)
		j colorKnown
	
	colorKnown:
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $t2, $t2, 1 #add 1 to counter
		blt $t2, 32, drawRow #if not at 32, keep drawing -> I don't know how to get it to jump to the next 'line' in memory at the end ofthis loop
		j loop # finally jump back to loop above when done with room

drawhead:
	addi $t8, $t0, 0  #store the end of the board so we can store data after this point.
	subi $t0, $t0, 1984 #brings the color pointer back to the middle of the board to draw head
	lw $t1, headcol($0)
	sw $t1, 0($t0)
	j exit
		
exit:	
li $v0, 10
syscall		# syscall to exit program
