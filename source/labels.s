.section .text
	
.global	drawLives
drawLives:
	push 	{lr}
	mov		r1, 	#700
	mov 	r2, 	#845
	mov 	r0, 	#'L'
	bl		drawChar

	mov 	r1, 	#710
	mov 	r2, 	#845
	mov 	r0, 	#'I'
	bl 		drawChar

	mov 	r1,		#720
	mov 	r2,		#845
	mov 	r0, 	#'V'
	bl 		drawChar

	mov		r1, 	#730
	mov 	r2, 	#845
	mov 	r0, 	#'E'
	bl 		drawChar

	mov 	r1, 	#740
	mov 	r2, 	#845
	mov 	r0, 	#'S'
	bl 		drawChar

	mov 	r1, 	#750
	mov 	r2, 	#845
	mov 	r0, 	#':'
	bl 		drawChar

	pop {pc}
	
.global drawScore	
drawScore:
	push	{lr}
	mov 	r1,		#1000
	mov 	r2, 	#845
	mov 	r0, 	#'S'
	bl 		drawChar

	mov 	r1, 	#1010
	mov		r2, 	#845
	mov 	r0, 	#'C'
	bl 		drawChar

	mov		r1, 	#1020
	mov 	r2,		#845
	mov 	r0, 	#'O'
	bl 		drawChar

	mov 	r1,		#1030
	mov 	r2, 	#845
	mov 	r0, 	#'R'
	bl 		drawChar

	mov		r1, 	#1040
	mov 	r2, 	#845
	mov 	r0, 	#'E'
	bl 		drawChar
	
	mov 	r1, 	#1050
	mov 	r2, 	#845
	mov 	r0, 	#':'
	bl 		drawChar

	pop {pc}


//r0 = char, r1 = x, r2 = y
drawChar:
	push		{r4-r9, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8
	orig_x	.req	r9

	ldr		chAdr, =font		@ load the address of the font map
	add		chAdr,	r0, lsl #4	@ char address = font base + (char * 16)

	mov		py, r2		@ init the Y coordinate (pixel coordinate)
	mov		orig_x,	r1

charLoop$:
	mov		px, orig_x		@ init the X coordinate

	mov		mask, #0x01		@ set the bitmask to 1 in the LSB
	
	ldrb		row, [chAdr], #1	@ load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		@ test row byte against the bitmask
	beq		noPixel$

	mov		r0, px
	mov		r1, py
	mov		r2, #0xFFFFFFFF		@ white
	bl		DrawPixel			@ draw red pixel at (px, py)

noPixel$:
	add		px, #1			@ increment x coordinate by 1
	lsl		mask, #1		@ shift bitmask left by 1

	tst		mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py, #1			@ increment y coordinate by 1

	tst		chAdr, #0xF
	bne		charLoop$		@ loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
	.unreq	orig_x

	pop		{r4-r9, pc}


DrawPixel:
	push		{r4, r5}

	offset		.req	r4

	ldr		r5, =frameBufferInfo	

	@ offset = (y * width) + x
	
	ldr		r3, [r5, #4]		@ r3 = width
	mul		r1, r3
	add		offset,	r0, r1
	
	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl		offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr		r0, [r5]		@ r0 = frame buffer pointer
	str		r2, [r0, offset]

	pop		{r4, r5}
	bx		lr
	
.section .data
.align	4
font:	.incbin	"font.bin"

