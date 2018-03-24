@
@ Re-draw all necessary tiles
@
.global ClearObjects
ClearObjects:
	push	{r4-r10, lr}
	
	bl		InitDrawTile
	bl		ClearBall			
	bl		ClearPaddle		
	bl		ClearValuepacks
	
	pop		{r4-r10, pc}

@
@ Clear the ball sprite
@
ClearBall:
	push	{r4-r10, lr}
	
	ldr		r4, =ball_position
	ldr		r1, [r4]			// ball x
	ldr		r2, [r4, #4]		// ball y
	
	mov		r6, r1				// save ball x
	mov		r7, r2				// save ball y
	
	bl		CalcTile
//TOPLEFT:
	bl		DrawTile

	mov		r1, r6
	sub		r1, #16
	mov		r2, r7
	add		r2, #8
	bl		CalcTile
//LL1:
	bl		DrawTile
	
	mov		r1, r6
	sub		r1, #16
	mov		r2, r7
	add		r2, #24
	bl		CalcTile
//LL2:
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

	mov		r1, r6
	add		r1, #32
	mov		r2, r7
	add		r2, #32
	bl		CalcTile
//BOTTOMRIGHT:
	bl		DrawTile

	mov		r1, r6
	mov		r2, r7
	add		r2, #32
	bl		CalcTile
//BOTTOMLEFT:
	bl		DrawTile

	pop		{r4-r10, pc}

@
@ Clear the paddle sprite
@
ClearPaddle:
	push	{r4-r7, lr}
	
	ldr		r4, =paddle_position
	ldr		r1, [r4]			// paddle x
	ldr		r2, [r4, #4]		// paddle y
	mov		r6, r1				// save paddle x
	mov		r7, r2				// save paddle y
	
	bl		CalcTile
	bl		DrawTile			// TOP LEFT
	
	mov		r1, r6
	sub		r1, #10
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile			// LEFT
	
	mov		r1, r6
	add		r1, #100
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile			// TOP RIGHT

	pop		{r4-r7, pc}

@
@ Clear any valuepacks that are currently falling down the screen.
@
.global ClearValuepacks
ClearValuepacks:
	push	{r4-r7, lr}
	
	ldr		r5,	=value_pack1
	mov		r4, #1				// valuepack flag
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
	add		r2, #22
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
	push	{r4-r7, lr}
	
	ldr		r4, =ball_position
	ldr		r1, [r4]			// ball x
	ldr		r2, [r4, #4]		// ball y
	
	mov		r6, r1				// save ball x
	mov		r7, r2				// save ball y
	
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
