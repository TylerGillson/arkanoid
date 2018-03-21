@ Clear necessary tiles
@
.global Clear
Clear:
	push	{r4-r10, lr}
	
	bl		InitDrawTile
	
	mov		r0, #0
	mov		r1, #0
	bl		DrawTile
	
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
	
	pop		{r4-r10, pc}

@ Get an index into the game map based on col & row indices
@  r0 - row index
@  r1 - col index
@
@ Returns:
@  r0 - offset to add to address of game_map
.global GetIndex
GetIndex:
	mov		r2, #12
	mul		r0, r2
	add		r0, r1
	bx		lr

@ Convert object's (x,y) coordinates into grid_map indices
@   r1 - x
@   r2 - y
@ 
@ Returns:
@   r0 - row index
@   r1 - col index
@
.global CalcTile
CalcTile:
	push	{r4, r5, lr}
	
	sub		r1, #624
	mov		r4, #48
	udiv	r1, r4				// r1 = col idx
	
	sub		r2, #156
	mov		r4, #32
	udiv	r2, r4
	mov		r0, r2				// r0 = row idx

	pop		{r4, r5, pc}

@ Draw a single tile
@   r0 - row idx
@   r1 - col idx
DrawTile:
	push	{r4-r10, lr}
	
	mov		r4, r0				// r4=row idx
	mov		r5, r1				// r5=col idx
	bl		GetIndex			// r0=tile offset

GOTINDEX:

	ldr		r6, =game_map		// pointer to game_map
	ldrb	r7, [r6, r0]		// Load the byte for the current tile
	
	teq		r7, #0
	ldreq	r0, =background
	
	teq		r7, #1
	ldreq	r0, =wall
	
	teq		r7, #2
	ldreq	r0, =white_block
	
	mov		r10, #48
	mul		r1, r5, r10			// r1 = col * 48
	mov		r2, r4, lsl #5		// r2 = row * 32
 
	add		r1, #624			// x origin offset 
	add		r2, #156			// y origin offset
	bl		DrawImage
	
	pop		{r4-r10, pc}

@
@ Initialize tile width & height for DrawImage
@
InitDrawTile:
	ldr		r0, =width
	mov		r1, #48
	str		r1, [r0]
	
	ldr		r0,	=height
	mov		r1, #32
	str		r1, [r0]
	bx		lr
	
@ 
@ Draw each tile in the game map according to its encoding
@
.global DrawMap
DrawMap:
	push	{r4-r10, lr}

	bl		InitDrawTile
	ldr		r6, =game_map		// pointer to game_map
	
@ Iterate over the grid, drawing each tile
	mov		r4, #0				// init row counter
draw_row:
	mov		r5, #0				// init/reset column counter
draw_col:	
	mov		r0, r4				// row counter
	mov		r1, r5				// col counter
	bl		DrawTile
	
	add		r5, #1
	cmp		r5, #11
	bls		draw_col
	
	add		r4, #1
	cmp		r4, #20
	bls		draw_row
	
	pop		{r4-r10, pc}
// END DRAW GAME MAP
