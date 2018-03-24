@
@
@
.global setWinFlag
setWinFlag:
	push 	{r4-r7, lr}
	
	counter 		.req 	r6
	brickCounter	.req	r7
	
	mov		counter, #0
	mov		brickCounter, #0

setWinFlagLoop:	
	cmp		counter, #252
	bhs		setWinTo1
	
	ldr		r4, =game_map
	ldr		r5, [r4, counter]
	cmp		r5, #1
	addhi	brickCounter, #1
	
	cmp		brickCounter, #1
	bhs		setWinFlagEnd
	
	add 	counter, #1
	b		setWinFlagLoop
		
setWinTo1:
	ldr		r4, =win
	mov		r5, #1
	str		r5, [r4]
	
setWinFlagEnd:	
	pop		{r4-r7, pc}



@
@
@
.global setLossFlag
setLossFlag:
	push	{r4, r5, r6, lr}

	ldr		r4, =lives
	ldr		r5, [r4]
	
	cmp 	r5, #0
	moveq	r6, #1
	ldreq	r4, =lose
	streq	r6, [r4]
	
	pop		{r4, r5, r6, pc}





@
@ Draw win or lose screen accordingly, if both = 0, continue game loop
@
.global drawWinOrLose
drawWinOrLose:
	push	{r4-r6, lr}
		
	ldr		r4, =win			// load win flag
	ldr		r5, [r4]
	
	ldr		r4, =lose			// load lose flag
	ldr		r6, [r4]
	
	
	cmp		r5, #1				// if win flag = 1
	//reset win flag		
	ldreq	r4, =win			// then set win flag to default 0
	move1 	r5, #0
	streq	r5, [r4]
	bleq	drawWinScreen		// draw screen with winning message
	beq		winOrLoseBackToMain	// if player press any button, return to the main menu
	
	
	
	cmp		r6, #1				// if lose flag = 1
	//reset lose flag
	ldreq		r4, =lose			// then set lose flag to default 0
	moveq		r5, #0
	streq		r5, [r4]
	bleq		drawLoseScreen		// draw screen with losing message
	beq		winOrLoseBackToMain	// if player press any button, return to the main menu
	
	//if win and lose flags are both 0 then continue game.
	
	pop		{r4-r6, pc}


@
@ Draw winning screen
@	
drawWinScreen:
	push 	{r4, r5, lr}
	
	ldr		r0, =gameWonScreen		
	mov		r1, #686
	mov		r2, #326
	
	ldr		r4, =width				// set width of pause menu
	mov		r5, #450
	str		r5, [r4]
	
	ldr		r4, =height				// set height of pause menu
	mov		r5, #300
	str		r5, [r4]
	
	bl 		DrawImage			
	
	
	pop		{r4, r5, pc}
	



@
@ Draw losing screen
@
drawLoseScreen:
	push 	{r4, r5, lr}
	
	ldr		r0, =gameLostScreen		
	mov		r1, #686
	mov		r2, #326
	
	ldr		r4, =width				// set width of pause menu
	mov		r5, #450
	str		r5, [r4]
	
	ldr		r4, =height				// set height of pause menu
	mov		r5, #300
	str		r5, [r4]
	
	bl 		DrawImage			
	
	pop		{r4, r5, pc}


@
@ If player press any button, return to the main menu
@
winOrLoseBackToMain:
	
	mov		r0, #5000				// delay 
	bl		delayMicroseconds
	mov		r1, #0					// clear r1 and r0 
	mov		r0, #0
		
waitToGBMain:						// loop to continue reading input
	bl		ReadSNES				// until player press any button 
									// to go back to main menu screen
	teq		r1, #0					// if r1 != 0 (which indicates at least one button was pressed)
	bne		main					// then branch to main
	b		waitToGBMain							

	


	
	
	


