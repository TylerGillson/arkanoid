@
@ Re-draw all necessary tiles
@
.global ClearObjects
ClearObjects:
	push		{r4-r10, lr}
	
	bl		InitDrawTile
	bl		ClearBall
	bl		ClearPaddle		
	bl		ClearValuepacks
	
	pop		{r4-r10, pc}

@
@ Clear the ball sprite
@
ClearBall:
	push		{r4-r10, lr}
	
	ldr		r4, =ball_position
	ldr		r1, [r4]		// ball x
	ldr		r2, [r4, #4]		// ball y
	
	mov		r6, r1			// save ball x
	mov		r7, r2			// save ball y
	
	bl		CalcTile
	bl		DrawTile
TOPLEFT:

	mov		r1, r6
	sub		r1, #16
	mov		r2, r7
	add		r2, #8
	bl		CalcTile
	bl		DrawTile
LL1:
	
	mov		r1, r6
	sub		r1, #16
	mov		r2, r7
	add		r2, #24
	bl		CalcTile
	bl		DrawTile
LL2:

	mov		r1, r6
	add		r1, #8
	mov		r2, r7
	sub		r2, #16
	bl		CalcTile
	bl		DrawTile
UU1:
	
	mov		r1, r6
	add		r1, #24
	mov		r2, r7
	sub		r2, #16
	bl		CalcTile
	bl		DrawTile
UU2:
	
	mov		r1, r6
	add		r1, #48
	mov		r2, r7
	add		r2, #16
	bl		CalcTile
	bl		DrawTile
RIGHT:

	mov		r1, r6
	add		r1, #32
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile
TOPRIGHT:

	mov		r1, r6
	add		r1, #32
	mov		r2, r7
	add		r2, #32
	bl		CalcTile
	bl		DrawTile
BOTTOMRIGHT:

	mov		r1, r6
	mov		r2, r7
	add		r2, #32
	bl		CalcTile
	bl		DrawTile
BOTTOMLEFT:

// ACCOUNT FOR BALL SPEED:
	ldr		r0, =value_pack1
	ldr		r3, [r0, #12]
	teq		r3, #1
	beq		doneClearBall
	
	mov		r0, #800
	mov		r2, r7
	add		r2, #32
	cmp		r2, r0
	bhi		doneClearBall		
	 
	mov		r1, r6
	add		r1, #8
	mov		r2, r7
	add		r2, #40
	bl		CalcTile
	bl		DrawTile
DD1:

	mov		r1, r6
	add		r1, #24
	mov		r2, r7
	add		r2, #40
	bl		CalcTile
	bl		DrawTile
DD2:
	
doneClearBall:
	pop		{r4-r10, pc}

@
@ Clear the paddle sprite
@
.global ClearPaddle
ClearPaddle:
	push		{r4-r9, lr}
	
	ldr		r4, =paddle_position
	ldr		r1, [r4]		// paddle x
	ldr		r2, [r4, #4]		// paddle y
	mov		r6, r1			// save paddle x
	mov		r7, r2			// save paddle y
	
	bl		CalcTile
	bl		DrawTile
PTOPLEFT:
	
	mov		r1, r6
	sub		r1, #10
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile
PLEFT:
	
	mov		r1, r6
	add		r1, #48
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile
PCENTRE:
	
	mov		r1, r6
	add		r1, #100
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile
PTOPRIGHT:

	pop		{r4-r9, pc}

@
@ Clear any valuepacks that are currently falling down the screen.
@
.global ClearValuepacks
ClearValuepacks:
	push		{r4-r7, lr}
	
	ldr		r5, =value_pack1
	mov		r4, #1			// valuepack flag
	ldr		r1, [r5, #8]
	teq		r1, #1
	bne		clearVP2
	
clearPack:
	ldr		r1, [r5, #16]		// x
	ldr		r2, [r5, #20]		// y
	sub		r2, #2
	bl		CalcTile
	bl		DrawTile
	
	ldr		r1, [r5, #16]
	ldr		r2, [r5, #20]
	
	mov		r3, r2
	add		r3, #22
	mov		r6, #828
	cmp		r6, r3
	addhi		r2, #22
	bl		CalcTile
	bl		DrawTile
	
	teq		r4, #1
	bne		doneClearing
	
clearVP2:
	ldr		r5,	=value_pack2
	mov		r4, #2
	ldr		r1, [r5, #8]
	teq		r1, #1
	beq		clearPack
	

doneClearing:
	pop		{r4-r7, pc}
	
@
@ Clear the ball sprite when it is at the bottom of the screen
@
.global ClearBallBottom
ClearBallBottom:
	push		{r4-r7, lr}
	
	ldr		r4, =ball_position
	ldr		r1, [r4]		// ball x
	ldr		r2, [r4, #4]		// ball y
	
	mov		r6, r1			// save ball x
	mov		r7, r2			// save ball y
	
	bl		CalcTile
//TOPLEFT:
	bl		DrawTile

	mov		r1, r6
	add		r1, #8
	mov		r2, r7
	sub		r2, #16
	bl		CalcTile
//UU1:
	bl		DrawTile

	mov		r1, r6
	add		r1, #24
	mov		r2, r7
	sub		r2, #16
	bl		CalcTile
//UU2:
	bl		DrawTile

	mov		r1, r6
	add		r1, #32
	mov		r2, r7
	bl		CalcTile
//TOPRIGHT:
	bl		DrawTile

	pop		{r4-r7, pc}
	
@
@ Clear valuepacks
@
.global ClearVPS
ClearVPS:
	push	{r4-r7, lr}

	teq		r2, #2
	ldreq	r0, =value_pack2
	ldrne	r0, =value_pack1
	ldr		r1, [r0, #16]		// x
	ldr		r2, [r0, #20]		// y
	bl		CalcTile
TEST:	
	bl		DrawTile
	
	pop		{r4-r7, pc}
