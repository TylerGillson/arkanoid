@
@ Draw the ball & the paddle
@
.global DrawObjects
DrawObjects:
	push	{r4-r5, lr}
	
@ draw the paddle
	bl		InitDrawPaddle
	ldr		r0, =small_paddle2
	ldr		r4, =paddle_position
	ldr		r1, [r4]			// x coord
	ldr		r2, [r4, #4]		// y coord
	bl		DrawImage

@ draw the ball
	bl		InitDrawBall
	ldr		r0, =ball
	ldr		r4, =ball_position
	ldr		r1, [r4]			// x coord
	ldr		r2, [r4, #4]		// y coord	
	bl		DrawImage	

	pop		{r4-r5, pc}
// END DRAW OBJECTS

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour
@
DrawPixel:
	push	{r4-r8, lr}
	offset	.req	r4

	ldr		r5, =frameBufferInfo	
	ldr		r3, [r5, #4]				@ r3 = width
	mul		r1, r3						@ r1 = y * width
	add		offset,	r0, r1				@ offset = (y * width) + x
	lsl		offset, #2					@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	
	// Make 0xffff00ff (transparent pixel value)
	mov		r6, #0xff000000
	mov		r7, #0x000000ff
	orr		r8, r6, r7
	mov		r6, #0x00ff0000
	orr		r8, r8, r6

	teq		r2, r8
	beq		skipPixel
	
	ldr		r0, [r5]					@ r0 = frame buffer pointer
	str		r2, [r0, offset]			@ store the colour (word) at frame buffer pointer + offset

skipPixel:	
	.unreq	offset	
	pop		{r4-r8, pc}
// END DRAW PIXEL

@ Draw an image whose dimensions are stored in the width & height globals
@  r0 - address of image data
@  r1 - x
@  r2 - y
@
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

@
@ Initialize image width & height for drawing the ball 
@
.global InitDrawBall
InitDrawBall:
	ldr		r0, =width
	mov		r1, #32
	str		r1, [r0]
	
	ldr		r0,	=height
	mov		r1, #32
	str		r1, [r0]
	bx		lr

@
@ Initialize image width & height for drawing the paddle 
@
.global InitDrawPaddle
InitDrawPaddle:
	ldr		r0, =width
	mov		r1, #96
	str		r1, [r0]
	
	ldr		r0,	=height
	mov		r1, #21
	str		r1, [r0]
	bx		lr

@
@ Initialize image width & height for drawing a tile 
@
.global InitDrawTile
InitDrawTile:
	ldr		r0, =width
	mov		r1, #48
	str		r1, [r0]
	
	ldr		r0,	=height
	mov		r1, #32
	str		r1, [r0]
	bx		lr
