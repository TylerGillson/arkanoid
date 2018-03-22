.section .text
	
.global	drawLives
drawLives:
	push 	{lr}
	mov	r1, 	#644
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#76
	bl	drawChar

	mov 	r1, 	#654
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#105
	bl 	drawChar

	mov 	r1,	#664
	mov 	r2,	#624
	ldr 	r3,	=0x0000
	mov 	r0, 	#118
	bl 	drawChar

	mov	r1, 	#674
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#101
	bl 	drawChar

	mov 	r1, 	#684
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#115
	bl 	drawChar

	mov 	r1, 	#694
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#58
	bl 	drawChar

	pop {pc}
	
.global drawScore	
drawScore:
	push	{lr}
	mov 	r1,	#744
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#83
	bl 	drawChar

	mov 	r1, 	#754
	mov	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#99
	bl 	drawChar

	mov	r1, 	#764
	mov 	r2,	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#111
	bl 	drawChar

	mov 	r1,	#774
	mov 	r2, 	#624
	ldr 	r3,	=0x0000
	mov 	r0, 	#114
	bl 	drawChar

	mov	r1, 	#784
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#101
	bl 	drawChar
	
	mov 	r1, 	#794
	mov 	r2, 	#624
	ldr 	r3, 	=0x0000
	mov 	r0, 	#58
	bl drawChar

	pop {pc}

	
/*Draw the character in r0 to (r1, r2) with colour r3
 */
.globl drawChar
drawChar:
	push 	{r4-r10, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	colour  .req    r7
	row	.req	r8
	mask	.req	r9
	orig_x	.req	r10

	mov     px, 	r1
	mov     orig_x, r1
	mov     py, 	r2
	mov     colour, r3

	ldr	chAdr,	=font		// load the address of the font map
	add	chAdr,	r0, 	lsl #4	// char address = font base + (char * 16)

charLoop:

	mov     px, 	orig_x
	mov	mask,	#0x01		// set the bitmask to 1 in the LSB
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop:
	tst	row,	mask		// test row byte against the bitmask
	beq	noPixel

	mov 	r0, 	px
	mov     r1, 	py
	mov     r2, 	colour
	bl	drawPixel		// draw  pixel at (px, py)

noPixel:
	add	px,	#1		// increment x coordinate by 1
	lsl	mask,	#1		// shift bitmask left by 1

	tst	mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop

	add	py,	#1		// increment y coordinate by 1

	tst	chAdr,	#0xF
	bne	charLoop		// loop back to charLoop, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
	pop	{r4-r10, pc}

.global drawPixel	
drawPixel: //r0 is assumed to be the x location, r1 is assumed to be the y location, r2 is assumed to be the colour data
	
	push	{r3-r6}
	mov	r4, 	r0
	mov	r5, 	r1
	mov	r6, 	r2
	
	cmp    r4,    #1024		//check max x
	bge    endDrawPixel		// if x >= 1024, don't draw
	cmp    r4,    #0                //check min x
	blt    endDrawPixel             // if x < 0, don't draw
	cmp    r5,    #768              //check max y
	bge    endDrawPix               // if y >= 768, don't draw
	cmp    r5,    #0                //check min y
	blt    endDrawPixel             // if y < 0, don't draw
	
	mov    r3,    #1024
	mul    r5,    r3                 	//row-major r1 <- (y*1024)
	add    r4,    r5               	 	//r0 <- (y*1024) + x
	lsl    r4,    #1                     	//16-bit colour assumed
	ldr    r5,    =FrameBufferPointer    	// should get frameBuffer location from file that contains frameBuffer information
	ldr    r5,    [r5]
	add    r5,    r4		// add offset
	strh   r6,    [r5]              // stores the colour into the FrameBuffer location
endDrawPixel:				// end of drawPixel
	pop	{r3-r6}
	bx     	lr                      // branch to calling code

	
.section .data
.align	4
font:	.incbin	"font.bin"

