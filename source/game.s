@ Wait for user input on the home screen
@
.global HomeLoop
HomeLoop:
	push		{r4, lr}
	menu_option	.req	r4	

	b		selectStart
	
waitLoop:
	mov		r1, #0
	bl		resetArgsAndDelay
	bl		ReadSNES				// See snes_driver.s

input:	
	cmp		r1, #4					// A was pressed
	bne		nav
	teq		menu_option, #1
	bleq	InitGame
	teq		menu_option, #1
	beq		GameLoop				// begin the main game loop (main.s)
	blne		QuitGame

nav:	
	cmp		r1, #7				// Joy-pad DOWN was pressed
	beq		selectQuit
	cmp		r1, #8				// Joy-pad UP was pressed
	beq		selectStart
	b		waitLoop			// Something else was pressed, so restart
	
.global selectStart
selectStart:
	bl		DrawHomeScreen
	mov		r1, #808
	mov		r2, #541			// location of play option
	bl		DrawMenuSelection
	mov		menu_option, #1
	b		waitLoop

.global selectQuit
selectQuit:
	bl		DrawHomeScreen
	mov		r1, #808
	mov		r2, #661			// location of quit option
	bl		DrawMenuSelection
	mov		menu_option, #0
	b		waitLoop
	
	.unreq		menu_option
	pop		{r4, pc}

@
@ Initialize the game map tiles and draw them to the screen.
@ Then draw the paddle and the ball.
@
.global InitGame
InitGame:
	push		{r4-r6, lr}
	
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
	strb		r6, [r4]			// Set the left side
	add		r4, #11				// Shift to the right side of the grid
	strb		r6, [r4], #1			// Set the right side & increment
	add		r5, #1
	cmp		r5, #20
	blt		sides
	
@ Put in a row of white blocks
	ldr		r4, =game_map
	add		r4, #73				// skip the first 12 blocks
	mov		r5, #0
	mov		r6, #2				// white block code
white_row:
	strb		r6, [r4], #1
	add		r5, #1
	cmp		r5, #10
	blt		white_row
	
@ Put in a row of gold blocks
	sub		r4, #58				
	mov		r5, #0
	mov		r6, #4				// gold block code
gold_row:
	strb		r6, [r4], #1
	add		r5, #1
	cmp		r5, #10
	blt		gold_row

@ Put in a row of red blocks
	add		r4, #14				
	mov		r5, #0
	mov		r6, #3				// red block code
red_row:
	strb		r6, [r4], #1
	add		r5, #1
	cmp		r5, #10
	blt		red_row
	
@ Draw the contents of the game map
	bl		DrawMap				// (game_map.s)	
	bl		DrawObjects			// (drawing.s)
	bl		DrawBottomBar		// (game_map.s)
	bl		drawLives			// (bottomLabels.s)
	bl		drawScore			// (bottomLabels.s)	
	bl		updateLives			// print original lives count
	//clear the asciz score string before printing
	ldr		r0,	=scoreString
	ldr		r1,	='0'
	strb		r1, [r0]	// clear the next char in the string
	strb		r1, [r0, #1]	// clear the next char in the string
	strb		r1, [r0, #2]	// clear the next char in the string
	ldr		r9,	=score
	ldr		r0,	[r9]
	ldr		r1,	=scoreString
	bl		scoreDemo
	ldr		r0,	=scoreString
	bl		printScore	
	
	pop		{r4-r6, pc}
// END INIT GAME

@
@ Draw a black rectangle over top of the game screen and loop forever
@
.global QuitGame
QuitGame:
	bl		DrawBlackScreen
	b		QuitGame

@
@ Pause menu logic
@
.global PauseScreen
PauseScreen:
	//draw the pause screen, then give user some time to select
	bl		DrawPauseScreen				
	mov		r0,	 #131072
	bl		delayMicroseconds
	b		pauseSelectRestart		

pauseWaitLoop:
	bl		ReadSNES
	
// if "start" button was pressed, continue game
continueGame:
	ldr		r2, =selection
	str		r0, [r2]
	str		r1, [r2, #4]
	mov		r0,	 #131072
	bl		delayMicroseconds
	ldr		r2, =selection
	ldr		r0, [r2]
	ldr		r1, [r2, #4]
			
	tst		r0, #(1<<8)
	bleq		InitGame				// draw game screen again
	beq		GameLoop				// then begin the main game loop (main.s)
	
// if "A" button was pressed(user selected a option on the pause menu), branch to aPressed
// if "A" button was not pressed, check if "Up" or "Down" was pressed
pauseInput:
	teq		r1, #4
	bne		pauseNav
	beq		aPressed
		
pauseNav:
	teq		r1, #7					// if "Down" was pressed
	beq		pauseSelectQuit				// then user selected quit option
	teq		r1, #8					// if "Up" was pressed 
	beq		pauseSelectRestart			// then user selected restart option
	b		pauseWaitLoop				// else wait for input again
	
// user move selection border to Restart, r6 = 1 indicates restart option is being selected
pauseSelectRestart:
	bl		DrawPauseScreen
	bl		DrawPauseSelection1
	ldr		r0, =selection
	mov		r1, #1
	str		r1, [r0, #8]
	b		pauseWaitLoop
	
// user move selection border to Quit, r6 = 0 indicates quit option is being selected
pauseSelectQuit:
	bl		DrawPauseScreen
	bl		DrawPauseSelection2
	ldr		r0, =selection
	mov		r1, #2
	str		r1, [r0, #8]
	b		pauseWaitLoop
	
// player selected an option, branch to restart the game or main menu accordingly 
aPressed:	
	bl		resetObjectsDefault		// reset ball and paddle
	bl		resetArgsAndDelay		// reset r0, r1, and delay the clock
	
	// restart selected:
	ldr		r0, =selection
	ldr		r1, [r0, #8]
	teq		r1, #2
	beq		quitSelected
	bl		InitGame
	b		GameLoop
	
	// quit selected: (need to go back to main menu first)
quitSelected:	
	bl		ResetLivesAndScore
	bl		resetArgsAndDelay		// reset r0, r1, and delay the clock
	b		main

@ Data section
.section .data

.align

selection:			// indicates what option is selected
.int	0			// SNES button register
.int	0			// SNES button code
.int	0			// selection flag
