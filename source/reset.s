@
@ Reset ball and paddle to the default value
@
.global resetObjectsDefault
resetObjectsDefault:
	push	{r4-r5, lr}
	
	// reset the paddle:
	ldr		r4, =paddle_position
	mov		r5, #864
	str		r5, [r4]
	mov		r5, #700
	str		r5, [r4, #4]
	
	// reset the ball:
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
	
	bl		ResetValuepacks
	
	pop		{r4-r5, pc}

@
@ Reset the valuepacks
@
ResetValuepacks:
	push		{r4-r5, lr}

	ldr		r4, =value_pack1
	mov		r5, #6
	str		r5, [r4]
	mov		r5, #9
	str		r5, [r4, #4]
	b		zeroes	

resetVP2:
	ldr		r4, =value_pack2
	mov		r5, #6
	str		r5, [r4]
	mov		r5, #5
	str		r5, [r4, #4]
	b		doneResetVPS
	
zeroes:	
	mov		r5, #0
	str		r5, [r4, #8]
	str		r5, [r4, #12]
	str		r5, [r4, #16]
	str		r5, [r4, #20]
	b		resetVP2

doneResetVPS:	
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
	
@
@ Reset Valuepacks
@
.global ResetVPS
ResetVPS:
	teq		r2, #2
	ldreq	r0, =value_pack2
	ldrne	r0, =value_pack1
	mov		r1, #6
	str		r1, [r0]
	moveq		r1, #5
	movne		r1, #9
	str		r1, [r0, #4]
	mov		r1, #0
	str		r1, [r0, #8]
	str		r1, [r0, #12]
	str		r1, [r0, #16]
	str		r1, [r0, #20]
	bx		lr
	
