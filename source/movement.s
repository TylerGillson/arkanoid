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
	bleq	UpdateBall			// update position if 1
	beq		done
	
	teq		r5, #12				// If B was pressed,
	moveq	r7, #1			
	streq	r7, [r6, #16]		// set ball active flag
done:	
	pop		{r4-r8, pc}

@ Check for collisions with walls & bricks
@  r1 - ball x
@  r2 - ball y
CheckCollision:
	push	{r4-r8, lr}

// determine if the ball is going NE or SE
	ldr		r4, =ball_position
	ldr		r5, [r4, #12]	// direction
	
	cmp		r5, #4
	beq		getTile
	cmp		r5, #1
	beq		getTile
	add		r1, #32			// If NE/SE, add 32 to ball x

getTile:
	bl		CalcTile
CHECKTILE:
	bl		GetIndex		// r0 = tile idx
	ldr		r4, =game_map
	ldrb	r6, [r4, r0]	// get tile at game_map[x][y]
	
	teq		r6, #0			// is ball on the background?
	bne		checkBrickOrWall
	
	mov		r0, r5			// pass direction as a param	
	bl		CheckPaddle		// if on background, check for paddle collisions

	teq		r1, #1			// is the ball hitting the paddle?
	bne		endCol			// if not, skip the rest
	
	mov		r5, r0			// if yes, get new direction
	b		store			// and update

checkBrickOrWall:	
	teq		r6, #1			// ball is on the wall
	moveq	r8, #0			// clear "hitting brick" flag
	beq		hitWall

	cmp		r6, #1
	bhi		hitBrick

	b		endCol			

hitBrick:
	mov		r1, #0
	str		r1, [r4, r0]
	mov		r8, #1			// set "hitting brick" flag
	
hitWall:
	ldr		r4, =ball_position
	ldr		r5, [r4, #12]	// Get ball direction	
	ldr		r7, [r4, #4]	// Get ball y
	
	teq		r5,	#4
	subeq	r5, #1			// If direction=4 (SW), set to 3 (SE) 
	beq		store
	
	teq		r5,	#3
	addeq	r5, #1			// If direction=3 (SE), set to 3 (SW) 
	beq		store
	
	teq		r5, #2			// If direction=2 (NE),
	bne		northwest
northeast:
	teq		r8, #1			// HITTING BRICK OVERRIDE
	addeq	r5, #1
	beq		store 
	
	cmp		r7, #188		// Hitting the ceiling?
	subhi	r5, #1			// NE --> NW (hitting the wall)
	addls	r5, #1			// NE --> SE (hitting the ceiling)
	b		store
	
northwest:	
	teq		r8, #1			// HITTING BRICK OVERRIDE
	addeq	r5, #3
	beq		store 
	
	cmp		r7, #188		// Hitting the ceiling?
	addhi	r5, #1			// NW --> NE (hitting the wall)
	addls	r5, #3			// NW --> SW (hitting the ceiling)

store:
	ldr		r4, =ball_position
	str		r5, [r4, #12]	// save new direction
	bl		UpdateBall
endCol:	
	pop		{r4-r8, pc}
	
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
	bl		CheckCollision
		
	bx		lr

