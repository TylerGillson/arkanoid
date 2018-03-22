@ Clear necessary tiles
@
.global ClearObjects
ClearObjects:
	push	{r4-r10, lr}
	
	bl		InitDrawTile
	ldr		r4, =ball_position
	ldr		r1, [r4]			// ball x
	ldr		r2, [r4, #4]		// ball y
	
	mov		r6, r1				// save ball x
	mov		r7, r2				// save ball y
	
	bl		CalcTile
TOPLEFT:
	bl		DrawTile

	mov		r1, r6
	sub		r1, #16
	mov		r2, r7
	add		r2, #8
	bl		CalcTile
LL1:
	bl		DrawTile

	mov		r1, r6
	sub		r1, #16
	mov		r2, r7
	add		r2, #24
	bl		CalcTile
LL2:
	bl		DrawTile
	
	mov		r1, r6
	add		r1, #8
	mov		r2, r7
	sub		r2, #16
	bl		CalcTile
UU1:
	bl		DrawTile

	mov		r1, r6
	add		r1, #24
	mov		r2, r7
	sub		r2, #16
	bl		CalcTile
UU2:
	bl		DrawTile

	mov		r1, r6
	add		r1, #32
	mov		r2, r7
	bl		CalcTile
TOPRIGHT:
	bl		DrawTile

	mov		r1, r6
	add		r1, #32
	mov		r2, r7
	add		r2, #32
	bl		CalcTile
BOTTOMRIGHT:
	bl		DrawTile

	mov		r1, r6
	mov		r2, r7
	add		r2, #32
	bl		CalcTile
BOTTOMLEFT:
	bl		DrawTile

// CLEAR THE PADDLE
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
	add		r1, #96
	mov		r2, r7
	bl		CalcTile
	bl		DrawTile			// TOP RIGHT

	pop		{r4-r10, pc}
