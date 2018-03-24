@ Check for valuepacks beneath a brick that has just been broken.
@ If one is there, enable its falling attribute. 
@  r0 - row idx
@  r1 - col idx
@
.global CheckValuepack
CheckValuepack:
	push	{r4-r7, lr}
	
	ldr		r2, =value_pack1
	ldr		r4, [r2]		// valuepack1 row idx
	ldr		r5, [r2, #4]	// valuepack1 col idx
	
	teq		r0, r4
	bne		CheckVP2
	teq		r1, r5
	bne		CheckVP2
	mov		r7, #1			// set valuepack # flag

enablePack:
	mov		r6, #1
	str		r6, [r2, #8]	// turn falling on

// Init pack coordinates:
	mov		r3, #48
	mul		r1, r5, r3			// r1 = col * 48
	mov		r2, r4, lsl #5		// r2 = row * 32
	add		r1, #628			// x origin offset + 4 
	add		r2, #156			// y origin offset
	
	teq		r7, #1
	ldreq	r0, =value_pack1
	ldrne	r0, =value_pack2
	str		r1, [r0, #16]
	str		r2, [r0, #20] 
	
	b		endCVP
	
CheckVP2:
	ldr		r2, =value_pack2
	ldr		r4, [r2]		// valuepack2 row idx
	ldr		r5, [r2, #4]	// valuepack2 col idx
		
	teq		r0, r4
	bne		endCVP
	teq		r1, r5
	bne		endCVP
	
	mov		r7, #2			// set valuepack # flag
	b		enablePack

endCVP:
	pop		{r4-r7, pc}



	
