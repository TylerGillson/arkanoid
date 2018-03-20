@
@ Draw the ball & the paddle
@
.global DrawObjects
DrawObjects:
	push	{r4-r5, lr}
	
@ draw the paddle
	ldr		r0, =small_paddle
	ldr		r4, =paddle_position
	ldr		r1, [r4]			// x coord
	ldr		r2, [r4, #4]		// y coord

	ldr		r4, =width
	mov		r5, #90
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #21
	str		r5, [r4]
	bl		DrawImage

@ draw the ball
	ldr		r0, =ball
	ldr		r4, =ball_position
	ldr		r1, [r4]			// x coord
	ldr		r2, [r4, #4]		// y coord
		
	ldr		r4, =width
	mov		r5, #32
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #32
	str		r5, [r4]
	bl		DrawImage	

	pop		{r4-r5, pc}
// END DRAW OBJECTS

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour

DrawPixel:
	push	{r4, r5}
	offset	.req	r4

	ldr		r5, =frameBufferInfo	
	ldr		r3, [r5, #4]				@ r3 = width
	mul		r1, r3						@ r1 = y * width
	add		offset,	r0, r1				@ offset = (y * width) + x
	lsl		offset, #2					@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	
	ldr		r0, [r5]					@ r0 = frame buffer pointer
	str		r2, [r0, offset]			@ store the colour (word) at frame buffer pointer + offset
	
	.unreq	offset	
	pop		{r4, r5}
	bx		lr
// END DRAW PIXEL

@ Draw Image
@  r0 - address of image data
@  r1 - x
@  r2 - y
.global DrawImage
DrawImage:
	push	{r4, r5, r6, r7, r8, r9, lr}
	
	img		.req	r4
	x		.req	r5
	y		.req	r6
	
	mov		img, r0			
	mov		x,   r1
	mov		y,   r2
	
	ldr		r9, =height
	ldr		r7, [r9]					@ init row counter

drawCol:
	ldr		r9, =width
	ldr		r8, [r9]					@ init/reset column counter
	
drawRow:	
	mov		r0, x
	mov		r1, y

	ldr		r2, [img], #4				@ load a word from img
	bl		DrawPixel
	
	add		x,  #1						@ increment column
	subs	r8, #1						@ decrement column counter
	bne		drawRow
	
	add		y,  #1						@ increment row
	ldr		r8, [r9]					@ reload width
	sub		x,  r8						@ reset x
	
	subs	r7, #1						@ decrement row counter
	bne		drawCol						@ draw next column
	
	.unreq	img
	.unreq	x
	.unreq	y
	pop		{r4, r5, r6, r7, r8, r9, pc}
// END DRAW IMAGE
