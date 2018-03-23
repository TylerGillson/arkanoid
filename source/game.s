@ Wait for user input on the home screen
@
.global HomeLoop
HomeLoop:
	push	{r4, lr}
	
	menu_option		.req	r4	
	//bl		InitGame	//TESTING ONLY
	//b		GameLoop	//TESTING ONLY

	b		selectStart
	
waitLoop:
	bl		ReadSNES				// See snes_driver.s

input:	
	cmp		r1, #4					// A was pressed
	bne		nav
	teq		menu_option, #1
	bleq	InitGame
	beq		GameLoop				// begin the main game loop (main.s)
	blne	QuitGame

nav:	
	cmp		r1, #7					// Joy-pad DOWN was pressed
	beq		selectQuit
	cmp		r1, #8					// Joy-pad UP was pressed
	beq		selectStart
	b		waitLoop				// Something else was pressed, so restart

selectStart:
	bl		DrawHomeScreen
	mov		r1, #808
	mov		r2, #541				// location of play option
	bl		DrawMenuSelection
	mov		menu_option, #1
	b		waitLoop

selectQuit:
	bl		DrawHomeScreen
	mov		r1, #808
	mov		r2, #661				// location of quit option
	bl		DrawMenuSelection
	mov		menu_option, #0
	b		waitLoop
	
	.unreq	menu_option
	pop		{r4, pc}

@
@ Initialize the game map tiles and draw them to the screen.
@ Then draw the paddle and the ball.
@
InitGame:
	push	{r4-r6, lr}
	
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
	add		r4, #73				// skip the first 12 blocks
	mov		r5, #0
	mov		r6, #2				// white block code
white_row:
	strb	r6, [r4], #1
	add		r5, #1
	cmp		r5, #10
	blt		white_row
	
@ Put in a row of white blocks
	sub		r4, #58				// skip the first 12 blocks
	mov		r5, #0
	mov		r6, #2				// white block code
white_row2:
	strb	r6, [r4], #1
	add		r5, #1
	cmp		r5, #10
	blt		white_row2

@ Draw the contents of the game map
	bl		DrawMap				// (game_map.s)	
	bl		DrawObjects			// (drawing.s)
	
	pop		{r4-r6, pc}
// END INIT GAME

@
@ Draw a black rectangle overtop of the game screen and loop forever
@
QuitGame:
	bl		DrawBlackScreen
	b		QuitGame
