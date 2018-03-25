@
@ Reset ball and paddle to the default value
@
.global resetObjectsDefault
resetObjectsDefault:
	push	{r4-r5, lr}
	
	ldr		r4, =paddle_position
	mov		r5, #864
	str		r5, [r4]
	mov		r5, #700
	str		r5, [r4, #4]
	
	ldr		r4, =ball_position
	mov		r5, #880
	str		r5, [r4]
	mov		r5, #667
	str		r5, [r4, #4]
	mov		r5, #0
	str		r5, [r4, #8]
	mov		r5, #2
	str		r5, [r4, #12]
	mov		r5, #0
	str		r5, [r4, #16]
	
	pop		{r4-r5, pc}


.global resetR0R1AndDelay
resetR0R1AndDelay:
	push	{lr}
	
	mov		r0, #0
	mov		r1, #0
	
	mov		r0, #50000
	bl		delayMicroseconds
	
	mov		r0, #50000
	bl		delayMicroseconds

	
	
	pop		{pc}
