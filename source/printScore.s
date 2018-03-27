//r0 = address of string of ascii chars
.globl printScore
printScore:
	string	.req	r4
	px		.req	r5
	py		.req	r6
	char 	.req	r7
	counter	.req	r8
	push	{r4-r8, lr} 

	mov		px, #1080			// Store x value
	mov		py, #845			// Store y value 
	mov		string, r0			// Store the address of the string
	
	mov		counter, #0
	ldrb	char, [string]		// Load the first char to be drawn
	
loopScore:
	mov		r0, char		// Move char to be draw into r0 
	mov		r1,	px			// Move x location to pass it in
	mov		r2, py			// Move y location to pass it in
	bl		drawChar		// branch to drawChar method
	add		counter, #1		// Increment to next char in string
	sub		px, #10			// Decrement location to be drawn
		
	ldrb	char, [string, counter]	// Load the next char in the string
	cmp		char, #0				// Check if end of string
	bne		loopScore				//if not equal to, branch to top of loopScore
	
	
	.unreq	string
	.unreq	px
	.unreq	py
	.unreq	char
	.unreq	counter
	pop		{r4-r8, pc}
