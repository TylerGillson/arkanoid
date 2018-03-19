@
@ Initialize the game map and draw it to the screen.
@ Then draw the paddle and the ball.
@
.global InitGame
InitGame:
// DRAW START SCREEN:

@ Set the top of the game map to walls
	ldr		r4, =game_map
	mov		r5, #0
	mov		r6, #1				// wall code
top_wall:
	strb	r6, [r4], #1
	add		r5, #1
	cmp		r5, #12
	blt		top_wall

@ Set the sides of the game map to walls
	mov		r5, #0
sides:
	strb	r6, [r4]			// Set the left side
	add		r4, #11				// Shift to the right side of the grid
	strb	r6, [r4], #1		// Set the right side & increment
	add		r5, #1
	cmp		r5, #20
	blt		sides
	
@ Put in a row of white blocks
	ldr		r4, =game_map
	add		r4, #13				// skip the first 12 blocks
	mov		r5, #0
	mov		r6, #2				// white block code
white_row:
	strb	r6, [r4], #1
	add		r5, #1
	cmp		r5, #10
	blt		white_row

@ Draw the contents of the game map
	bl		DrawMap
	
@ draw the paddle
	ldr		r0, =small_paddle
	mov		r1, #864
	mov		r2, #700
	
	ldr		r4, =width
	mov		r5, #90
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #21
	str		r5, [r4]
	bl		DrawImage
	
@ draw the ball
	ldr		r0, =ball
	mov		r1, #880
	mov		r2, #668
	
	ldr		r4, =width
	mov		r5, #32
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #32
	str		r5, [r4]
	bl		DrawImage
	
	bl		GameLoop			// begin the main game loop
// END INIT GAME

@ TODO: DRAW BLACK over everything?
@
.global QuitGame
QuitGame:
	b		QuitGame

@ Wait for user input on the home screen
@
.global HomeLoop
HomeLoop:
	menu_option		.req	r4	
	b		selectStart
	
waitLoop:
	bl		GetInput				// See snes_driver.s

input:	
	cmp		r1, #4					// A was pressed
	bne		nav
	teq		menu_option, #1
	bleq	InitGame
	blne	QuitGame

nav:	
	cmp		r1, #7					// Joy-pad DOWN was pressed
	beq		selectQuit
	
	cmp		r1, #8					// Joy-pad UP was pressed
	beq		selectStart
	
	b		waitLoop				// Something else was pressed, so restart

selectStart:
	bl		DrawHomeScreen
	mov		r1, #811
	mov		r2, #361
	bl		DrawMenuSelection
		
	mov		menu_option, #1
	b		waitLoop

selectQuit:
	bl		DrawHomeScreen
	mov		r1, #811
	mov		r2, #481
	bl		DrawMenuSelection
	mov		menu_option, #0

	b		waitLoop
