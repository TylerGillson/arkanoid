
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 	r0, =frameBufferInfo 		@ frame buffer information structure
	bl		initFbInfo

	@ draw the image stored at image_loc
	ldr		r0, =background1
	mov		r1, #608
	mov		r2, #133
	bl		DrawImage

	ldr		r0, =small_paddle
	mov		r1, #886
	mov		r2, #743
	bl		DrawPaddle

	mov		r5,	#10
	mov		r6, #632
block:
	ldr		r0, =white_block
	mov		r1, r6
	mov		r2, #230
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block
/////

	mov		r5,	#10
	mov		r6, #632
block1:
	ldr		r0, =yellow_block
	mov		r1, r6
	mov		r2, #258
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block1
/////
	mov		r5,	#10
	mov		r6, #632
block2:
	ldr		r0, =pink_block
	mov		r1, r6
	mov		r2, #286
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block2

	mov		r5,	#10
	mov		r6, #632
block3:
	ldr		r0, =blue_block
	mov		r1, r6
	mov		r2, #314
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block3

	mov		r5,	#10
	mov		r6, #632
block4:
	ldr		r0, =red_block
	mov		r1, r6
	mov		r2, #342
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block4

	mov		r5,	#10
	mov		r6, #632
block5:
	ldr		r0, =green_block
	mov		r1, r6
	mov		r2, #370
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block5

	mov		r5,	#10
	mov		r6, #632
block6:
	ldr		r0, =turquoise_block
	mov		r1, r6
	mov		r2, #398
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block6

	mov		r5,	#10
	mov		r6, #632
block7:
	ldr		r0, =orange_block
	mov		r1, r6
	mov		r2, #426
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block7

	mov		r5,	#10
	mov		r6, #632
block8:
	ldr		r0, =silver_block
	mov		r1, r6
	mov		r2, #454
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block8

	mov		r5,	#10
	mov		r6, #632
block9:
	ldr		r0, =gold_block
	mov		r1, r6
	mov		r2, #482
	bl		DrawBlock
	add		r6, #56
	subs	r5, #1
	bne		block9


haltLoop$:
	b		haltLoop$


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

DrawImage:
	push	{r4, r5, r6, r7, r8, lr}
	
	img		.req	r4
	x		.req	r5
	y		.req	r6
	
	mov		img, r0			
	mov		x,   r1
	mov		y,   r2
	
	mov		r7, #718					@ init row counter

drawCol:
	mov		r8, #608					@ init/reset column counter
	
drawRow:	
	mov		r0, x
	mov		r1, y

	ldr		r2, [img], #4				@ load a word from img
	bl		DrawPixel
	
	add		x,  #1						@ increment column
	subs	r8, #1						@ decrement column counter
	bne		drawRow
	
	add		y,  #1						@ increment row
	sub		x,  #608					@ reset x
	
	subs	r7, #1						@ decrement row counter
	bne		drawCol						@ draw next column
	
	.unreq	img
	.unreq	x
	.unreq	y
	pop		{r4, r5, r6, r7, r8, pc}
////////////////

DrawPaddle:
	push	{r4, r5, r6, r7, r8, lr}
	
	img		.req	r4
	x		.req	r5
	y		.req	r6
	
	mov		img, r0			
	mov		x,   r1
	mov		y,   r2
	
	mov		r7, #15					@ init row counter

drawpCol:
	mov		r8, #70					@ init/reset column counter
	
drawpRow:	
	mov		r0, x
	mov		r1, y

	ldr		r2, [img], #4				@ load a word from img
	bl		DrawPixel
	
	add		x,  #1						@ increment column
	subs	r8, #1						@ decrement column counter
	bne		drawpRow
	
	add		y,  #1						@ increment row
	sub		x,  #70					@ reset x
	
	subs	r7, #1						@ decrement row counter
	bne		drawpCol						@ draw next column
	
	.unreq	img
	.unreq	x
	.unreq	y
	pop		{r4, r5, r6, r7, r8, pc}

DrawBlock:
	push	{r4, r5, r6, r7, r8, lr}
	
	img		.req	r4
	x		.req	r5
	y		.req	r6
	
	mov		img, r0			
	mov		x,   r1
	mov		y,   r2
	
	mov		r7, #28					@ init row counter

drawbCol:
	mov		r8, #56					@ init/reset column counter
	
drawbRow:	
	mov		r0, x
	mov		r1, y

	ldr		r2, [img], #4				@ load a word from img
	bl		DrawPixel
	
	add		x,  #1						@ increment column
	subs	r8, #1						@ decrement column counter
	bne		drawbRow
	
	add		y,  #1						@ increment row
	sub		x,  #56					@ reset x
	
	subs	r7, #1						@ decrement row counter
	bne		drawbCol						@ draw next column
	
	.unreq	img
	.unreq	x
	.unreq	y
	pop		{r4, r5, r6, r7, r8, pc}


@ Data section
.section .data

.align
.global frameBufferInfo
frameBufferInfo:
	.int	0							@ frame buffer pointer
	.int	0							@ screen width (1824px)
	.int	0							@ screen height (984px)


// Sizes:
//					X	  Y
// ball: 			8   x 8
// background:		608 x 718
// small_paddle:	70  x 15
// block:			56  x 28
