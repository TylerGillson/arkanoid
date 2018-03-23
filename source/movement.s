@ Update the game state
@  r0 - SNES button register
@  r1 - SNES button code
@
.global Update
Update:
	push	{r4-r8, lr}
	
	mov		r4, r0
	mov		r5, r1
	
	tst		r0, #1				// mask for RIGHT
	moveq	r1, #1				// set moving RIGHT flag
	bleq	UpdatePaddle
	beq		postUser
	
	tst		r0, #(1<<1)			// mask for LEFT
	moveq	r1, #0				// clear moving RIGHT flag (b/c moving LEFT)
	bleq	UpdatePaddle

// IMPLEMENT ME!
//	teq		r5, #9				// Start was pressed
//	bleq	InitPauseMenu
	
postUser:
	ldr		r6, =ball_position
	ldr		r7, [r6, #16]	

// activate the game by pressing B:
	teq		r7, #1				// check ball active flag
	bne		BCHECK
	bl		CheckCollision		// update position if 1
	b		done

BCHECK:	
	teq		r5, #12				// If B was pressed,
	moveq	r7, #1			
	streq	r7, [r6, #16]		// set ball active flag
done:	
	pop		{r4-r8, pc}

@
@ Check for collisions with walls & bricks
@
CheckCollision:
	push	{r4, r5, lr}

	ldr		r0, =ball_position
	ldr		r1, [r0]
	ldr		r2, [r0, #4]
	
	mov		r4, r1				// save x
	mov		r5, r2				// save y

// TOP LEFT
	ldr		r0, =top_left
	bl		CalcCorner

// TOP RIGHT
	add		r4, #32
	mov		r1, r4
	mov		r2, r5
	ldr		r0, =top_right
	bl		CalcCorner

// BOTTOM RIGHT
	mov		r1, r4
	add		r5, #32
	mov		r2, r5
	ldr		r0, =bottom_right
	bl		CalcCorner

// BOTTOM LEFT
	sub		r4, #32
	mov		r1, r4
	mov		r2, r5
	ldr		r0, =bottom_left
	bl		CalcCorner
	
	bl		ProcessCollision
	
	pop		{r4, r5, pc}


@ Process collisions according corner tile type
@   - Corner data has been initialized
@
ProcessCollision:
	push	{r4-r8, lr}
	
	ldr		r4, =ball_position
	ldr		r5, [r4, #12]		// ball direction

// Test all four corners to determine whether the ball is entirely on the background:	
	ldr		r0, =top_left
	ldr		r1, [r0, #4]		// tile type
	ldr		r6, [r4]			// ball x
	ldr		r7, [r4, #4]		// ball y
	teq		r1, #0
	bhi		checkBrickOrWall
	
	ldr		r0, =top_right
	ldr		r1, [r0, #4]		// tile type
	add		r6, #32
	teq		r1, #0
	bhi		checkBrickOrWall
	
	ldr		r0, =bottom_right
	ldr		r1, [r0, #4]		// tile type
	add		r7, #32
	teq		r1, #0
	bhi		checkBrickOrWall
	
	ldr		r0, =bottom_left
	ldr		r1, [r0, #4]		// tile type
	sub		r6, #32
	teq		r1, #0
	bhi		checkBrickOrWall

// Ball is entirely on the background:	
	mov		r0, r5				// pass direction as a param	
	bl		CheckPaddle			// check for paddle collisions
	teq		r1, #1				// is the ball hitting the paddle?
	bne		endCol				// if not, skip the rest
	mov		r5, r0				// if yes, get new direction
	b		store				// and update

checkBrickOrWall:	
	teq		r1, #1				// ball is colliding with a wall
	beq		hitWall		

hitBrick:
	ldr		r4, =game_map
	ldr		r1, [r0]			// tile index
	mov		r3, #0				
	strb	r3, [r4, r1]		// make current tile a background tile
	
	bl		InitDrawTile
	mov		r1, r6
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile
	
hitWall:

	teq		r5,	#4
	beq		southwest
	bne		SECheck
	
southwest:
	ldr		r0, =bottom_right
	ldr		r1, [r0, #4]		// BR tile type
	
	cmp		r1, #0				// Is the bottom right corner on the background?
	subeq	r5, #1				// SW --> SE (hitting the wall)
	subhi	r5, #3				// SW --> NW (hitting a brick)
	b		store
	
SECheck:
	teq		r5,	#3
	beq		southeast
	bne		northCheck
	
southeast:
	ldr		r0, =bottom_left
	ldr		r1, [r0, #4]		// BL tile type
	
	cmp		r1, #0				// Is the bottom left corner on the background?
	addeq	r5, #1				// SE --> SW (hitting the wall)
	subhi	r5, #1				// SE --> NE (hitting a brick)
	b		store
	
northCheck:	
	teq		r5, #2				// Check for NE vs. NW
	bne		northwest

northeast:						// If direction=2 (NE),
	ldr		r0, =top_right
	ldr		r1, =bottom_right
	ldr		r2, [r0, #4]		// TR tile type
	ldr		r3, [r1, #4]		// BR tile type
	
	cmp		r3, #1				// Is the bottom right corner on a wall?
	subeq	r5, #1				// NE --> NW (hitting the wall)
	addne	r5, #1				// NE --> SE (hitting a brick/ceiling)
	b		store
	
northwest:						// If direction=1 (NW),
	ldr		r0, =top_left
	ldr		r1, =bottom_left
	ldr		r2, [r0, #4]		// TL tile type
	ldr		r3, [r1, #4]		// BL tile type
	
	cmp		r3, #1				// Is the bottom left corner on a wall?
	addeq	r5, #1				// NW --> NE (hitting the wall)
	addne	r5, #3				// NW --> SW (hitting a brick/ceiling)

store:
	ldr		r4, =ball_position
	str		r5, [r4, #12]		// save new direction
endCol:
	bl		UpdateBall
	pop		{r4-r8, pc}
	
@ Calculate & store the tile type & index for a corner of the ball
@  r0 - corner data location
@  r1 - ball x
@  r2 - ball y
@
CalcCorner:
	push 	{r4, lr}

	mov		r4, r0
	bl		CalcTile
	bl		GetIndex			// r0 = tile idx

	str		r0, [r4]			// save tile idx
	ldr		r3, =game_map
	ldrb	r2, [r3, r0]		// get tile type
	str		r2, [r4, #4]		// save tile type
	
	pop		{r4, pc}
		
@ Test if the ball is colliding with the paddle + update its direction
@  r0 - direction  
@
@ Returns: a new direction if there was a collision
@  r0 - direction (possibly updated)
@  r1 - paddle was hit flag
@
CheckPaddle:
	push	{r4-r8, lr}
	
	ldr		r4, =ball_position
	ldr		r5, [r4]		// get ball x
	ldr		r6, [r4, #4]	// get ball y
	add		r6, #32			// adjust for bottom of the ball
	
	ldr		r4, =paddle_position
	ldr		r7, [r4]		// get paddle x
	ldr		r8, [r4, #4]	// get paddle y
	
	cmp		r6, r8			// check y axis
	movne	r1, #0
	bne		endCP			// no collision
	
	add		r7, #96
	cmp		r5, r7			// check ball right of paddle
	movhi	r1, #0
	bhi		endCP
	
	add		r5, #32
	sub		r7, #96
	cmp		r5, r7			// check ball left of paddle
	movls	r1, #0
	bls		endCP

// UPDATE ANGLE BASED ON CONTACT LOCATION:	
	mov		r6, r0			// save ball direction

PCHECK:	
	sub		r5, #16
	add		r7, #72
	cmp		r5, r7
	bls		notFarRight
	
	mov		r0, #1			// 60 degrees
	bl		UpdateAngle
	b		changeDirection

notFarRight:
	sub		r7, #48
	cmp		r5, r7			// is the ball hitting the far left side? 
	bhi		inside
	
	mov		r0, #1			// 60 degrees
	bl		UpdateAngle
	b		changeDirection

inside:	
	mov		r0, #0			// 45 degrees
	bl		UpdateAngle

changeDirection:
	teq		r6, #3			// 3=SE, 4=SW
	subeq	r6, #1			// If SE, set to NE
	subne	r6, #3			// If SW, set to NW
	mov		r0, r6
	mov		r1, #1			// set ball was hit flag
	
endCP:
	pop		{r4-r8, pc}

@ Update the ball's angle
@   r0 - angle flag
@
UpdateAngle:
	ldr		r1, =ball_position
	teq		r0, #1			// check angle flag
	moveq	r2, #1			// angle = 60 degrees
	movne	r2, #0			// angle = 45 degrees
	str		r2, [r1, #8]
	bx		lr

@ Shift the paddle's x coordinate
@  r0 - SNES button register 
@  r1 - moving RIGHT flag
@
UpdatePaddle:
	push	{r4-r7, lr}
	
	ldr		r4, =paddle_position
	ldr		r5, [r4]			// x coord
	
	mov		r6, #1				// default paddle shift amount
	
	tst		r0, #(1<<3)			// mask for A
	addeq	r6, #2				// accelerate paddle if A is pressed

// Don't let the paddle exit the play area!	
	cmp		r1, #1				// check moving RIGHT flag
	beq		moveRight
	
	sub		r0, r5, r6			// moving left (accounting for speed)
	cmp		r0, #672			// check left boundary
	bls		skipMove
	sub		r5, r6				// move left
	b		storeMove
	
moveRight:
	mov		r7, r5
	add		r7, #96
	add		r7, r6				// account for speed!
	cmp		r7, #1152			// check right boundary
	bhi		skipMove
	add		r5, r6				// move right

storeMove:
	str		r5, [r4]
skipMove:
	pop		{r4-r7, pc}
	
@ 
@ Update the x & y coordinates of the ball based on its current direction
@
UpdateBall:
	push	{r4, lr}
	
	ldr		r3, =ball_position
	ldr		r0, [r3, #12]	// get the ball's direction
	ldr		r1, [r3]		// x coord
	ldr		r2, [r3, #4]	// y coord
	ldr		r4, [r3, #8]	// angle

	teq		r0, #1			// NW?
	bne		updateNE
	sub		r1, #1
	teq		r4, #1
	subeq	r2, #2
	subne	r2, #1
	b		updated

updateNE:	
	teq		r0, #2			// NE?
	bne		updateSE
	add		r1, #1
	teq		r4, #1
	subeq	r2, #2
	subne	r2, #1
	b		updated

updateSE:	
	teq		r0, #3			// SE?
	bne		updateSW
	add		r1, #1
	teq		r4, #1
	addeq	r2, #2
	addne	r2, #1
	b		updated

updateSW:
	sub		r1, #1			// SW			
	teq		r4, #1
	addeq	r2, #2
	addne	r2, #1

updated:
	str		r1, [r3]		// update x
	str		r2, [r3, #4]	// update y
		
	pop		{r4, pc}
