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
	bleq	CheckCollision		// update position if 1
	beq		done
	
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
	subeq	r5, #1				// If direction=4 (SW), set to 3 (SE) 
	beq		store
	
	teq		r5,	#3
	addeq	r5, #1				// If direction=3 (SE), set to 3 (SW) 
	beq		store
	
	teq		r5, #2				// Check for NE vs. NW
	bne		northwest

northeast:						// If direction=2 (NE),
	ldr		r0, =top_right
	ldr		r1, =bottom_right
	ldr		r2, [r0, #4]		// TR tile type
	ldr		r3, [r1, #4]		// BR tile type
	
	cmp		r3, #1				// Is the bottom right corner on a wall?
	subeq	r5, #1				// NE --> NW (hitting the wall)
	addne	r5, #1				// NE --> SE (hitting the ceiling)
	b		store
	
northwest:						// If direction=1 (NW),
	ldr		r0, =top_left
	ldr		r1, =bottom_left
	ldr		r2, [r0, #4]		// TL tile type
	ldr		r3, [r1, #4]		// BL tile type
	
	cmp		r3, #1				// Is the bottom left corner on a wall?
	addeq	r5, #1				// NW --> NE (hitting the wall)
	addne	r5, #3				// NW --> SW (hitting the ceiling)

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
	
	teq		r0, #3			// 3=SE, 4=SW
	subeq	r0, #1			// If SE, set to NE
	subne	r0, #3			// If SW, set to NW
	mov		r1, #1
	
endCP:
	pop		{r4-r8, pc}

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

	ldr		r3, =ball_position
	ldr		r0, [r3, #12]	// get the ball's direction
	ldr		r1, [r3]		// x coord
	ldr		r2, [r3, #4]	// y coord

	teq		r0, #1			// NW?
	subeq	r1, #1
	subeq	r2, #1
	beq		updated
	
	teq		r0, #2			// NE?
	addeq	r1, #1
	subeq	r2, #1
	beq		updated
	
	teq		r0, #3			// SE?
	addeq	r1, #1
	addeq	r2, #1
	beq		updated
	
	sub	r1, #1				// SW			
	add	r2, #1

updated:
	str		r1, [r3]		// update x
	str		r2, [r3, #4]	// update y
		
	bx		lr

