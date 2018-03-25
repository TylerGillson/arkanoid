@ Update the game state
@  r0 - SNES button register
@  r1 - SNES button code
@
.global Update
Update:
	push		{r4-r8, lr}
	
	mov		r4, r0
	mov		r5, r1

	ldr		r6, =ball_position
	ldr		r7, [r6, #16]	
	teq		r7, #1
	bne		skipPaddle		// don't move the paddle if the ball isn't active
	
	tst		r0, #(1<<4)		// mask for RIGHT
	moveq		r1, #1			// set moving RIGHT flag
	bleq		UpdatePaddle
	beq		postUser
	
	tst		r0, #(1<<5)		// mask for LEFT
	moveq		r1, #0			// clear moving RIGHT flag (b/c moving LEFT)
	bleq		UpdatePaddle

skipPaddle:
	teq		r1, #9
	beq		PauseScreen
	
postUser:
	bl		UpdateValuepacks
	bl		CheckPaddleValuepacks
	
// activate the game by pressing B:
	teq		r7, #1			// check ball active flag
	bne		bCheck
	bl		CheckCollision		// update position if 1
	b		done
	
bCheck:
	teq		r5, #12			// If B was pressed,
	moveq		r7, #1			
	streq		r7, [r6, #16]		// set ball active flag

done:	
	pop		{r4-r8, pc}

@
@ Check for collisions with walls & bricks
@
CheckCollision:
	push		{r4, r5, lr}

	ldr		r0, =ball_position
	ldr		r1, [r0]
	ldr		r2, [r0, #4]
	
	mov		r4, r1			// save x
	mov		r5, r2			// save y

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
	push		{r4-r8, lr}
	
	ldr		r4, =ball_position
	ldr		r5, [r4, #12]		// ball direction

// Test all four corners to determine whether the ball is entirely on the background:	
	ldr		r0, =top_left
	ldr		r1, [r0, #4]		// tile type
	ldr		r6, [r4]		// ball x
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
	mov		r0, r5			// pass direction as a param	
	bl		CheckPaddle		// check for paddle collisions
	teq		r1, #1			// is the ball hitting the paddle?
	bne		endCol			// if not, skip the rest
	mov		r5, r0			// if yes, get new direction
	b		store			// and update

checkBrickOrWall:	
	teq		r1, #1			// ball is colliding with a wall
	beq		hitWall		

// BEGIN BRICK HITTING CODE
hitBrick:
	ldr		r4, =game_map
	ldr		r8, [r0]		// tile index
	cmp		r1, #2			// is it a white block?
	moveq		r3, #0			// turn white blocks into background tiles
	subhi		r3, r1, #1		// demote non-white blocks
	strb		r3, [r4, r8]		// update block tile in memory

// Draw new tile:
	bl		InitDrawTile
	mov		r1, r6
	mov		r2, r7
	bl		CalcTile
	mov		r6, r0
	mov		r7, r1
	bl		DrawTile
	
// Check for valuepack:
	mov		r0, r6			// tile row idx
	mov		r1, r7			// tile col idx
	bl		CheckValuepack

// Update score:
	mov		r0, #10			// 10 points for breaking a brick
	bl		UpdateScore
	//**********************
	//bl		PrintScore
	//**********************

// END BRICK HITTING CODE
hitWall:
	teq		r5,	#4
	beq		southwest
	bne		SECheck
	
southwest:
	ldr		r0, =bottom_right
	ldr		r1, [r0, #4]		// BR tile type
	
	cmp		r1, #0			// Is the bottom right corner on the background?
	subeq		r5, #1			// SW --> SE (hitting the wall)
	subhi		r5, #3			// SW --> NW (hitting a brick)
	b		store
	
SECheck:
	teq		r5,	#3
	beq		southeast
	bne		northCheck
	
southeast:
	ldr		r0, =bottom_left
	ldr		r1, [r0, #4]		// BL tile type
	
	cmp		r1, #0			// Is the bottom left corner on the background?
	addeq		r5, #1			// SE --> SW (hitting the wall)
	subhi		r5, #1			// SE --> NE (hitting a brick)
	b		store
	
northCheck:	
	teq		r5, #2			// Check for NE vs. NW
	bne		northwest

northeast:					// If direction=2 (NE),
	ldr		r0, =top_right
	ldr		r1, =bottom_right
	ldr		r2, [r0, #4]		// TR tile type
	ldr		r3, [r1, #4]		// BR tile type
	
	cmp		r3, #1			// Is the bottom right corner on a wall?
	subeq		r5, #1			// NE --> NW (hitting the wall)
	addne		r5, #1			// NE --> SE (hitting a brick/ceiling)
	b		store
	
northwest:					// If direction=1 (NW),
	ldr		r0, =top_left
	ldr		r1, =bottom_left
	ldr		r2, [r0, #4]		// TL tile type
	ldr		r3, [r1, #4]		// BL tile type
	
	cmp		r3, #1			// Is the bottom left corner on a wall?
	addeq		r5, #1			// NW --> NE (hitting the wall)
	addne		r5, #3			// NW --> SW (hitting a brick/ceiling)

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
	push 		{r4, lr}

	mov		r4, r0
	bl		CalcTile
	bl		GetIndex		// r0 = tile idx

	str		r0, [r4]		// save tile idx
	ldr		r3, =game_map
	ldrb		r2, [r3, r0]		// get tile type
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
	push		{r4-r8, lr}
	
	ldr		r4, =ball_position
	ldr		r5, [r4]		// get ball x
	ldr		r6, [r4, #4]		// get ball y
	add		r6, #32			// adjust for bottom of the ball
	
	ldr		r4, =paddle_position
	ldr		r7, [r4]		// get paddle x
	ldr		r8, [r4, #4]		// get paddle y
	
	cmp		r8, r6			// check y axis
	movhi		r1, #0
	bhi		endCP			// no collision
	
	add		r7, #96
	cmp		r5, r7			// check ball right of paddle
	movhi		r1, #0
	bhi		endCP
	
	add		r5, #32
	sub		r7, #96
	cmp		r5, r7			// check ball left of paddle
	movls		r1, #0
	bls		endCP

// UPDATE ANGLE BASED ON CONTACT LOCATION:	
	mov		r6, r0			// save ball direction

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
	subeq		r6, #1			// If SE, set to NE
	subne		r6, #3			// If SW, set to NW
	
	bl		CheckStickyPaddle		// if valuepack2 is enabled, catch the ball
	
	mov		r0, r6
	mov		r1, #1			// set ball was hit flag
	
endCP:
	pop		{r4-r8, pc}

@
@ If valuepack2 is enabled, turn off the ball's active flag
@
CheckStickyPaddle:
	push	{r4-r8, lr}
	
	ldr		r0, =value_pack2
	ldr		r1, [r0, #12]
	teq		r1, #1
	bne		doneCSP
	
	ldr		r0, =ball_position
	mov		r1, #0
	str		r1, [r0, #16]		// disable the ball's active flag
	
doneCSP:
	pop		{r4-r8, pc} 

@ Update the ball's angle
@   r0 - angle flag
@
UpdateAngle:
	ldr		r1, =ball_position
	teq		r0, #1			// check angle flag
	moveq		r2, #1			// angle = 60 degrees
	movne		r2, #0			// angle = 45 degrees
	str		r2, [r1, #8]
	bx		lr

@ Shift the paddle's x coordinate
@  r0 - SNES button register 
@  r1 - moving RIGHT flag
@
UpdatePaddle:
	push		{r4-r7, lr}
	
	ldr		r4, =paddle_position
	ldr		r5, [r4]		// x coord
	
	mov		r6, #1			// default paddle shift amount
	
	tst		r0, #(1<<3)		// mask for A
	addeq		r6, #2			// accelerate paddle if A is pressed

// Don't let the paddle exit the play area!	
	cmp		r1, #1			// check moving RIGHT flag
	beq		moveRight
	
	sub		r0, r5, r6		// moving left (accounting for speed)
	cmp		r0, #672		// check left boundary
	bls		skipMove
	sub		r5, r6			// move left
	b		storeMove
	
moveRight:
	mov		r7, r5
	add		r7, #96
	add		r7, r6			// account for speed!
	cmp		r7, #1152		// check right boundary
	bhi		skipMove
	add		r5, r6			// move right

storeMove:
	str		r5, [r4]
skipMove:
	pop		{r4-r7, pc}
	
@ 
@ Update the x & y coordinates of the ball based on its current direction
@
UpdateBall:
	push		{r4-r7, lr}
	
	ldr		r0, =value_pack1
	ldr		r1, [r0, #12]
	teq		r1, #1
	moveq		r5, #2			// 60 y factor
	moveq		r6, #1			// 60 x factor
	moveq		r7, #1			// 45 x/y factor
	
	movne		r5, #3			// 60 y factor
	movne		r6, #1			// 60 x factor
	movne		r7, #2			// 45 x/y factor
	
	ldr		r3, =ball_position
	ldr		r0, [r3, #12]		// get the ball's direction
	ldr		r1, [r3]		// x coord
	ldr		r2, [r3, #4]		// y coord
	ldr		r4, [r3, #8]		// angle
	
	teq		r0, #1			// NW?
	bne		updateNE
	teq		r4, #1
	subeq		r2, r5		// y 60
	subeq		r1, r6		// x 60
	subne		r2, r7		// y 45
	subne		r1, r7		// x 45
	b		updated

updateNE:	
	teq		r0, #2			// NE?
	bne		updateSE
	teq		r4, #1
	subeq		r2, r5		// y 60
	addeq		r1, r6		// x 60
	subne		r2, r7		// y 45
	addne		r1, r7		// x 45
	b		updated

updateSE:	
	teq		r0, #3			// SE?
	bne		updateSW
	teq		r4, #1
	addeq		r2, r5		// y 60
	addeq		r1, r6		// x 60
	addne		r2, r7		// y 45
	addne		r1, r7		// x 45
	b		updated

updateSW:
	teq		r4, #1			// SW
	addeq		r2, r5		// y 60
	subeq		r1, r6		// x 60
	addne		r2, r7		// y 45
	subne		r1, r7		// x 45
	
updated:
	str		r1, [r3]		// update x
	str		r2, [r3, #4]		// update y
	
	bl		CheckBottomBoundary
		
	pop		{r4-r7, pc}
	
@ Check if the ball has reached the bottom of the screen. If it has,
@ remove a life and reset the ball.
@  
@ Inputs:
@  r2 - ball y
@
CheckBottomBoundary:
	push		{r4-r7, lr}
	
	mov		r0, #828
	add		r2, #32
	cmp		r0, r2
	bhi		endCheckBottomBoundary
	
	ldr		r0, =lives
	ldr		r1, [r0]
	sub		r1, #1
	str		r1, [r0]		// decrement lives count

	bl		overwrite_Lives
	bl		updateLives
	bl		InitDrawTile
	bl		ClearBallBottom
	bl		ClearPaddle
	bl		resetObjectsDefault
	
endCheckBottomBoundary:
	pop		{r4-r7, pc}

@
@ If a valuepack's falling attribute is enabled, update its y coordinate.
@
UpdateValuepacks:
	push		{r4, lr}
	
	ldr		r0, =value_pack1
	ldr		r1, [r0, #8]
	mov		r4, #1
	teq		r1, #1
	bne		updateVP2

updatePack:	
	ldr		r1, [r0, #20]
	add		r1, #1			// increment valuepack y
	str		r1, [r0, #20]
	
	mov		r0, #828
	add		r1, #21
	cmp		r1, r0
	bls		noReset
	bl		InitDrawTile
	mov		r2, r4
	bl		ClearVPS
	mov		r2, r4
	bl		ResetVPS
	
noReset:	
	teq		r4, #1
	bne		endUpdateVPs

updateVP2:
	ldr		r0, =value_pack2
	ldr		r1, [r0, #8]
	mov		r4, #2
	teq		r1, #1
	beq		updatePack

endUpdateVPs:
	pop		{r4, pc}

@	
@ Check if a valuepack is colliding with the paddle.
@ If one is, disable its falling attribute and enable its effect attribute.
@
CheckPaddleValuepacks:
	push		{r4-r8, lr}
	
	ldr		r4, =paddle_position
	ldr		r5, [r4]		// get paddle x
	ldr		r6, [r4, #4]		// get paddle y
	
	ldr		r0, =value_pack1
	ldr		r1, [r0, #20]		// valuepack y
	add		r1, #21			// bottom of the valuepack
	mov		r8, #1
	cmp		r6, r1			// paddle y vs. vp y
	bhi		checkPaddleVP2
	
	add		r6, #21			// bottom of the paddle
	ldr		r7, [r0, #20]
	cmp		r7, r6
	bhi		checkPaddleVP2

checkXAxis:
	add		r5, #96
	ldr		r4, [r0, #16]		// valuepack x
	
	cmp		r4, r5			// check vp right of paddle
	bhi		doneXAxis
	
	add		r4, #40
	sub		r5, #96
	cmp		r5, r4			// check vp left of paddle
	bhi		doneXAxis

// Valuepack collision:	
	mov		r4, r0			
	bl		InitDrawTile
	bl		ClearValuepacks		// clear the valuepack
	mov		r0, r4
	
	mov		r1, #0
	str		r1, [r0, #8]		// disable falling
	mov		r1, #1
	str		r1, [r0, #12]		// enable effect
	
	mov		r1, #0			// reset x & y
	str		r1, [r0, #16]
	str		r1, [r0, #20]
	
	mov		r0, #50			// 50 points for getting a value pack
	bl		UpdateScore
	//**********************
	//bl		PrintScore
	//**********************
	
doneXAxis:
	teq		r8, #1
	bne		doneCheckPaddle
	
checkPaddleVP2:
	ldr		r0, =value_pack2
	ldr		r1, [r0, #20]		// valuepack y
	add		r1, #21			// bottom of the valuepack
	mov		r8, #2
	cmp		r6, r1
	bhi		doneCheckPaddle
	
	add		r6, #21			// bottom of the paddle
	ldr		r7, [r0, #20]
	cmp		r7, r6
	bhi		doneCheckPaddle
	
	b		checkXAxis
	
doneCheckPaddle:
	pop		{r4-r8, pc}

