.data #goal is teal border and light blue inside
lightBlue:    .word 0x7EC0EE
teal:    .word 0x003B3D
bodycol:    .word 0xFFFF66 #yellow
headcol:    .word 0x9200FF #purple 
fruit:     .word 0xFD0000 #red

#directional info:- up: $t0 - 128, down: +128, left: -4, right: +128
#w=119, a=97, s = 115 d= 100

.text
main:
	li $t5, 0 #TEST (TAKE OUT)

    lw $t1, teal($0)
    addi $t0, $gp, 0
    li $t3, 0
    j drawBoard
    start: #let's start the game
    li $v0, 12
    syscall  #waits for input to start the game
    beq $v0, 119,st
    beq $v0, 115,st
    beq $v0, 97,st   
    beq $v0, 100, st
    li $v0, 100		#if not 'w','a','s','d', then 'd'

    st:
    move $s3, $v0
    move $s4, $v0 	#this value will have more permanence than $s3
    jal generateFruit
    j movehead
    
    
#below here makes the inital board
drawBoard:
    
    beq $t3, 32, drawhead #Counter for height (do this until its done it 256 times (height)). drawBody at end
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
        blt $t2, 32, drawRow #if not at 32, keep drawing 
        j drawBoard # finally jump back to loop above when done with row

drawhead:
    #    $t2 - stores current head position
    #    $t8 - stores the memory location of the the first body segment (all 0's at this point
    
    addi $t8, $t0, 4      #store first spot after the end of the board so we can store data after this point.
    sw $0, 0($t8)          #store all 0's in the first spot so we know where the tail is
    
    subi $t0, $t0, 1984     #brings the color pointer back to the middle of the board to draw head
    lw $t1, headcol($0)
    sw $t1, 0($t0)

    move $t2, $t0  #save the current head position in $t2
    j start

getInput:
	li $s2 0xffff0000 #memory location of MMIO keyboard input
	lw $s3 4($s2) #stores current (most recent press in $s3)
	
	beq $s3, $s4, movehead 	#no input so no need to update
	beq $s3, 119, readVal
	beq $s3, 115, readVal
	beq $s3, 97,  readVal
	bne $s3, 100, movehead 	#not a valid input so don't update
	
	readVal: 	#value needs to be updated
		move $s4, $s3
		j movehead
	

movehead:
	addi $t3, $t2, 0 	# moves the head location to old head
	beq $s4, 119, headup
	beq $s4, 115, headdown
	beq $s4, 97, headleft
	beq $s4, 100, headright
	
	headright:
		addi $t2, $t2, 4 	#set head 1 spot to the right
		j colHead
	headleft:
		subi $t2, $t2, 4 	#set head 1 spot to the left
		j colHead
	headup:
		subi $t2, $t2, 128 	#set head 1 spot up
		j colHead
	headdown:
		addi $t2, $t2, 128 	#set head 1 spot down
		j colHead
	
    colHead:	#moves head color and need to do checks here for fruit or death
    lw $t1, headcol($0)
    addi $t0, $t2, 0
    sw $t1, 0($t0)
    j updateBody
	
	
	  
    
updateBody:
	# $s0- previous body location
	# $t0 - current body location
	#need register of head
	
	move $s0, $t0 # save the current body location to $s0
	move $t0, $t3 # move old head to be the first body spot
	move $t3, $t2 # the head will now be the old head
	
	lw $t1, bodycol($0) # change the head color to bodycol
	
	lw $t7, 0($t8) #go to the start of the body
	move $s0, $t2
	beq $t7, $0, tail  #if no body exists, just exit
	
	lw $t0, 0($t8) # else, go to the start of the body
	
	
	bodyLoop:
		lw $s1, 4($s0)
		beq $s1, $0, tail #if the next segment is null, handle the tail
		lw $t0, 4($s0) #go to the next body segment
		move $t0, $s0
		j bodyLoop
	tail:
		beq $t5, 1, adjustColor
		lw $t1, lightBlue($0) #only changes to lightblue if a fruit was not eaten
		adjustColor: #no matter the case, update the color (either still bodycol or lightblue)
		move $t0, $s0 
		sw $t1, 0($t0)
		j getInput

generateFruit:
	li $a0, 1
	li $a1, 1024
	li $v0, 42   #random
	syscall

	li $v0, 1  # Service 1, print int
	syscall    # Print previously generated random int
	
	li $a1, 4
	mult $a0, $a1
	mflo $a0
	add $t0, $gp, $a0 #add random number to $gp
	
	
	
	lw $t1, fruit($0) #only changes to lightblue if a fruit was not eaten
	lw $a1, lightBlue($0) # for comparison
	lw $a0, 0($t0) # get color stored currently in $t0
	bne $a0, $a1, generateFruit # if chosen square is not light blue, pick another 
	sw $t1, 0($t0)
	jr $ra 		#this is a side function so we will always need to 'jal' (jump and return to the calling function) 


exit:    
li $v0, 10
syscall        # syscall to exit program