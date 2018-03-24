@ Draw the home screen image
.global DrawHomeScreen
DrawHomeScreen:
	push	{r4, r5, lr}
	ldr		r0, =home_screen
	mov		r1, #624
	mov		r2, #156
	
	ldr		r4, =width
	mov		r5, #576
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #672
	str		r5, [r4]
	bl		DrawImage
	pop		{r4, r5, pc}

@ Draw the box indicating the current menu selection
.global DrawMenuSelection
DrawMenuSelection:
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
	
@ Draw the black screen image
.global DrawBlackScreen
DrawBlackScreen:
	push	{r4, r5, lr}
	ldr		r0, =black_screen
	mov		r1, #624
	mov		r2, #156
	
	ldr		r4, =width
	mov		r5, #576
	str		r5, [r4]
	
	ldr		r4,	=height
	mov		r5, #672
	str		r5, [r4]
	bl		DrawImage
	pop		{r4, r5, pc}
	

	
