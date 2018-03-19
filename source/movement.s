@ 
@ Update the x & y coordinates of the ball based on its current direction
@
.global UpdateBall
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
