@ Update the game state
@  r0 - SNES button register
@  r1 - SNES button code
@
.global Update
Update:
	push	{r4-r8, lr}
	
	mov		r4, r0
	mov		r5, r1
	
	teq		r5, #1			// RIGHT was pressed
	bleq	UpdatePaddle
	beq		postUser
	
	teq		r5, #2			// LEFT was pressed
	bleq	UpdatePaddle

// IMPLEMENT ME!	
//	teq		r5, #9			// Start was pressed
//	bleq	InitMenu
	
postUser:
	ldr		r6, =ball_position
	ldr		r7, [r6, #16]	
test:
	teq		r7, #1			// check ball active flag
	bleq	UpdateBall		// update position if 1
	beq		done
	
	teq		r5, #12			// If B was pressed,
	moveq	r7, #1			
	streq	r7, [r6, #16]	// set ball active flag
done:	
	pop		{r4-r8, pc}

@ Shift the paddle's x coordinate
@  r0 - SNES button register 
@  r1 - SNES button code
@
UpdatePaddle:
	push	{r4-r7, lr}
	
	ldr		r4, =paddle_position
	ldr		r5, [r4]		// x coord
	
	mov		r6, #1			// paddle shift amount
	tst		r0, #(1<<4)		// check 'A' bit
	addeq	r6, #5			// accelerate paddle if A is pressed
	
	cmp		r1, #1
	addeq	r5, r6			// move right
	subne	r5, r6			// move left
	str		r5, [r4]
	
	pop		{r4-r7, pc}
	
@ 
@ Update the x & y coordinates of the ball based on its current direction
@
UpdateBall:
	ldr		r3, =ball_position
	ldr		r0, [r3, #12]	// get the ball's direction
	ldr		r1, [r3]		// x coord
	ldr		r2, [r3, #4]	// y coord
	
	teq		r0, #1			// NW?
	subeq	r1, #1
	subeq	r2, #1
	beq		update
	
	teq		r0, #2			// NE?
	addeq	r1, #1
	subeq	r2, #1
	beq		update
	
	teq		r0, #3			// SE?
	addeq	r1, #1
	addeq	r2, #1
	beq		update
	
	sub	r1, #1				// SW			
	add	r2, #1

update:
	str		r1, [r3]		// update x
	str		r2, [r3, #4]	// update y
	
	bl		CheckCollision
	
	bx		lr

@
@ Check for collisions with walls & bricks
@  r1 - ball x
@  r2 - ball y
CheckCollision:
	push	{r4-r8, lr}
	
	mov		r4, #0			// col counter
col:	
	cmp		r1, #624		// compare w/ screen side
	subhi	r1, #48			// brick width
	addhi	r4, #1
	bhi		col	

	mov		r5, #0			// row counter
row:
	cmp		r2, #156		// compare w/ screen top
	subhi	r2, #32			// brick height
	addhi	r5, #1
	bhi		row

@ ball's top left corner is in game_map[r4][r5]	
	
	mov		r0, r4
	mov		r1, r5
	bl		GetIndex
	
	ldr		r4, =game_map
	ldrb	r5, [r4, r0]	// get tile at game_map[x][y]
	
	teq		r5, #0			// ball is on background
	beq		endCol
	
	teq		r5, #1			// ball is on the wall
	bne		endCol
	ldr		r4, =ball_position
	ldr		r5, [r4, #12]	// direction
	teq		r5,	#4
	subeq	r5, #1			// If 4, reset to 1
	addne	r5, #1			// Otherwise, increment
	str		r5, [r4, #12]	// save new direction
	
endCol:	
	pop		{r4-r8, pc}
