@
@ Draw pause screen
@
.global	DrawPauseScreen
DrawPauseScreen:

	push	{r4, r5, lr}
	ldr		r0, =pauseMenu			// point to pauseMenu
	mov		r1, #686				// x coordinate
	mov		r2, #326				// y coordinate
	
	ldr		r4, =width				// set width of pause menu
	mov		r5, #450
	str		r5, [r4]
	
	ldr		r4, =height				// set height of pause menu
	mov		r5, #300
	str		r5, [r4]
	
	bl 		DrawImage			
	
	pop 	{r4, r5, pc}
	
	
@
@ Draw the border around "Restart" 
@
.global DrawPauseSelection1
DrawPauseSelection1:

	push	{r4, r5, lr}
	ldr		r0, =pauseMenuSelect1	// point to pauseMenuSelect1
	mov		r1, #728				// x coordinate
	mov		r2, #369				// y coordinate
	
	ldr		r4, =width				// set width of border
	mov		r5, #377
	str		r5, [r4]
	
	ldr		r4, =height				// set height of border
	mov		r5, #106
	str		r5, [r4]
	
	bl 		DrawImage
	
	pop 	{r4, r5, pc}
	
@	
@ Draw the border around "Quit"
@
.global DrawPauseSelection2
DrawPauseSelection2:

	push	{r4, r5, lr}
	ldr		r0, =pauseMenuSelect2	// point to pauseMenuSelect2
	mov		r1, #791				// x coordinate
	mov		r2, #480				// y coordinate
	
	ldr		r4, =width				// set width of the border
	mov		r5, #243
	str		r5, [r4]
	
	ldr		r4, =height				// set height of the border
	mov		r5, #104
	str		r5, [r4]
	
	bl 		DrawImage
	
	pop 	{r4, r5, pc}
	
	
