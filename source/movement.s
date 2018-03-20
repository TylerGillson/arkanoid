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
	bl		UpdateBall
//	ldr		r6, =ball_position
//	ldr		r7, [r4, #16]	

//	teq		r7, #1			// check ball active flag
//	bleq	UpdateBall		// update position if 1
//	beq		done
	
//	teq		r5, #12			// If B was pressed,
//	moveq	r7, #1			
//	streq	r7, [r4, #16]	// set ball active flag
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
	
	teq		r0, #3			// SW?
	subeq	r1, #1			
	addeq	r2, #1
	beq		update
	
	add		r1, #1			//SE
	add		r2, #1

update:
	str		r1, [r3]		// update x
	str		r2, [r3, #4]	// update y
	bx		lr
