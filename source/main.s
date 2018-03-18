
@ Code section
.section .text

.global main
main:
	@ initialize the SNES driver
	bl		initSNES
	
	@ ask for frame buffer information
	ldr 	r0, =frameBufferInfo 		@ frame buffer information structure
	bl		initFbInfo

	menu_option		.req	r4	
	b		selectStart
	
homeLoop:
	bl		getInput

// B     = 12
// Y     = 11
// Sel   = 10
// Sta   = 9
// UP    = 8
// DOWN  = 7
// LEFT  = 6
// RIGHT = 5
// A     = 4
// X     = 3
// L     = 2
// R	 = 1
input:	
	cmp		r1, #4					@ A was pressed
	bne		nav
	teq		menu_option, #1
	beq		startGame
	bne		quitGame

nav:	
	cmp		r1, #7					@ Joy-pad DOWN was pressed
	beq		selectQuit
	
	cmp		r1, #8					@ Joy-pad UP was pressed
	beq		selectStart
	
	b		homeLoop

selectStart:
	bl		drawHomeScreen
	mov		r1, #811
	mov		r2, #361
	bl		drawMenuSelection
		
	mov		menu_option, #1
	b		homeLoop

selectQuit:
	bl		drawHomeScreen
	mov		r1, #811
	mov		r2, #481
	bl		drawMenuSelection
	mov		menu_option, #0
test:
	b		homeLoop

quitGame:
	b		quitGame
	
startGame:
// DRAW START SCREEN:
	@ draw the background
	ldr		r0, =background1
	mov		r1, #608
	mov		r2, #133
	
	ldr		r4, =width
	mov		r5, #608
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #718
	str		r5, [r4]
	bl		DrawImage
	
	@ draw the paddle
	ldr		r0, =small_paddle
	mov		r1, #886
	mov		r2, #743
	
	ldr		r4, =width
	mov		r5, #70
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #15
	str		r5, [r4]
	bl		DrawImage
	
	@ draw the ball
	ldr		r0, =ball
	mov		r1, #917
	mov		r2, #735
	
	ldr		r4, =width
	mov		r5, #8
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #8
	str		r5, [r4]
	bl		DrawImage
	
	@ draw a row of gold blocks
	ldr		r0, =gold_block
	mov		r1, #632
	mov		r2, #230
	
	ldr		r4, =width
	mov		r5, #56
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #28
	str		r5, [r4]
	bl		DrawBlockRow
	
	@ draw a row of silver blocks
	ldr		r0, =silver_block
	mov		r1, #632
	mov		r2, #258
	bl		DrawBlockRow
	
	@ draw a row of white blocks
	ldr		r0, =white_block
	mov		r1, #632
	mov		r2, #286
	bl		DrawBlockRow
	
drawn:
	b drawn
// END DRAW START SCREEN

// DRAW HOME SCREEN
drawHomeScreen:
	push	{r4, r5, lr}
	ldr		r0, =home_screen
	mov		r1, #608
	mov		r2, #133
	
	ldr		r4, =width
	mov		r5, #608
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #500
	str		r5, [r4]
	bl		DrawImage
	pop		{r4, r5, pc}

// DRAW THE MENU SELECTION
drawMenuSelection:
	push	{r4, r5, lr}
	
	ldr		r0, =menu_select
	ldr		r4, =width
	mov		r5, #214
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #114
	str		r5, [r4]
	bl		DrawImage
	
	pop		{r4, r5, pc}

//gameLoop:
//	bl		getInput		// read from the SNES controller
//	bl		updateState		// update game state variables
//	bl		clear			// erase the game grid
//	bl		draw			// re-draw the game grid
//	b		gameLoop

@ Draw Block Row
@  r0 - address of block data
@  r1 - x
@  r2 - y
DrawBlockRow:
	push	{r4, r5, r6, r7, lr}
	
	img		.req	r4
	x		.req	r5
	y		.req	r6
	
	mov		img, r0
	mov		x, 	 r1
	mov		y,   r2
	
	mov		r7,	#10
block:
	mov		r0, img
	mov		r1, x
	mov		r2, y
	bl		DrawImage
	add		x, #56
	subs	r7, #1
	bne		block

	.unreq	img
	.unreq	x
	.unreq	y
	pop	{r4, r5, r6, r7, pc}
// END DRAW BLOCK ROW

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

// game play area:	560 x 700 (origin at 632x151)
// n = 10, m = 28, making a 280 cell grid

width:
.int	0

height:
.int	0

gamemap:
.rept	280			// Game play area grid
.int	0
.endr

paddle_position:
.int	886			// x coordinate
.int	743			// y coordinate

ball_position:
.int	917			// x coordinate
.int	735			// y coordinate
.int	45			// angle
.int	2			// direction (1-8: 1=N, 2=NE, 3=E, 4=SE, 5=S, 6=SW, 7=W, 8=NW)
.int	10			// speed (default=10)

score:
.int	0			// player score

lives:
.int	5			// number of lives (default=5)

win:
.int	0			// win flag

lose:
.int	0			// lose flag
