@ Clear necessary tiles
@
.global Clear
Clear:
	bx		lr
@ 
@ Draw each tile in the game map according to its encoding
@
.global DrawMap
DrawMap:
	push	{r4-r10, lr}

@ Initialize width & height for DrawImage
	ldr		r8, =width
	mov		r9, #48
	str		r9, [r8]
	
	ldr		r8,	=height
	mov		r9, #32
	str		r9, [r8]
	
	ldr		r6, =game_map		// pointer to game_map
	
@ Iterate over the grid, drawing each tile
	mov		r4, #0				// init row counter
draw_row:
	mov		r5, #0				// init/reset column counter
draw_col:	
	mov		r0, r4				// row counter
	mov		r1, r5				// col counter
	bl		getIndex			// Get offset into game_map
	ldrb	r7, [r6, r0]		// Load the byte for the current tile
	
	teq		r7, #0
	ldreq	r0, =background
	
	teq		r7, #1
	ldreq	r0, =wall
	
	teq		r7, #2
	ldreq	r0, =white_block
	
	mov		r10, #48
	mul		r1, r5, r10				// r1 = col * 48
	mov		r2, r4, lsl #5			// r2 = row * 32

	add		r1, #624			// x origin offset
	add		r2, #126			// y origin offset
	bl		DrawImage
	
	add		r5, #1
	cmp		r5, #12
	blt		draw_col
	
	add		r4, #1
	cmp		r4, #21
	blt		draw_row
	
	pop		{r4-r10, pc}
// END DRAW GAME MAP

@ Get an index into the game map based on x,y coordinates
@  r0 - x
@  r1 - y
@
@ Returns:
@  r0 - offset to add to address of game_map
getIndex:
	mov		r2, #12
	mul		r0, r0, r2
	add		r0, r0, r1
	bx		lr
