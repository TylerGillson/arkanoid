@ Code section
.section    .text

.global InitSNES
InitSNES:
		push	{r4, lr}
		gBase	.req	r4

// Initialize & store virtual base address:
		bl		getGpioPtr					
		ldr		r1, =gpioBaseAddress		
		str		r0, [r1]			@ Save GPIO base address in global memory
		ldr		gBase, [r1]			@ Save GPIO base address to a local variable

// Set pins 9 & 11 to output, and pin 10 to input:
		mov		r0, #9				
		mov		r1, #0b001			@ Set function to output
		mov		r2, gBase			
		bl		Init_GPIO
		
		mov		r0, #11
		mov		r1, #0b001			@ Set function to output
		mov		r2, gBase
		bl		Init_GPIO
		
		mov		r0, #10				
		mov		r1, #0b000			@ Set function to input
		mov		r2, gBase
		bl		Init_GPIO
		
		.unreq	gBase
		pop		{r4, pc}
		
/*
 * Write a bit to the SNES latch line.
 * 
 * Params:
 * r0 = 1: Set   (latch line high)
 * r0 = 0: Clear (latch line low)
 * 
 * Returns: nothing
 */
Write_Latch:
		ldr		r2, =gpioBaseAddress		
		ldr		r3, [r2]				@ Get GPIO base address
		
		mov		r1, #(1<<9)				@ Latch line = GPIO Pin 9
		teq		r0,	#0					@ Check set / clear param to set flags
		streq	r1, [r3, #0x28]			@ Write 1 << 9 to Clear Register 0
		strne	r1, [r3, #0x1C]			@ Write 1 << 9 to Set Register 0
		bx		lr
		
/*
 * Write a bit to the SNES clock line.
 * 
 * Params:
 * r0 = 1: Set   (clock line high)
 * r0 = 0: Clear (clock line low)
 *
 * Returns: nothing
 */
Write_Clock:
		ldr		r2, =gpioBaseAddress		
		ldr		r3, [r2]				@ Get GPIO base address
		
		mov		r1, #(1<<11)			@ Clock line = GPIO Pin 11
		teq		r0, #0					@ Check set / clear param to set flags
		streq	r1, [r3, #0x28]			@ Write 1 << 11 to Clear Register 0
		strne	r1, [r3, #0x1C]			@ Write 1 << 11 to Set Register 0
		bx		lr

/*
 * Read and return a bit from the SNES data line.
 * 
 * Returns:
 * r0 = 1 if data bit high
 * r0 = 0 if data bit low
 */
Read_Data:
		ldr		r2, =gpioBaseAddress		
		ldr		r3, [r2]				@ Get GPIO base address
		
		ldr		r0, [r3, #0x34]			@ Read the value of Level Register 0
		mov		r1, #(1<<10)			@ Data line = GPIO Pin 10
		and		r0, r1					@ Set flags: Z = 0 = Low, Z = 1 = High 
		bx		lr

// B     = 12
// Y     = 11
// Sel   = 10
// Sta   = 9
// UP    = 8
// DOWN  = 7
// LEFT  = 6
// RIGHT = 5
// A     = 4
// X     = 3
// L     = 2
// R	 = 1

/*
 * Read the current state of each of the SNES controller's buttons.
 *
 * Returns:
 * r0 = result register (12 least signigicant bits = map of which buttons are pressed)
 * r1 = code indicating which button was pressed (index of first 0 in result register)
 *		code = 0 means nothing was pressed
 */
.global ReadSNES
ReadSNES:
		push	{r5, r6, r7, r8, r9, lr}
		mov		r0, #1					
 		bl		Write_Latch				@ Set latch line to high
 		mov		r0, #1					
 		bl		Write_Clock				@ Set clock line to high
 		mov		r0, #12					
		bl		delayMicroseconds		@ 12 microsecond delay
		mov		r0, #0					
		bl		Write_Latch				@ Set latch line to low
		mov		r7, #0					@ Clear result register
		mov		r8, #0					@ Clear "stored counter" flag
		mov		r9,	#0					@ Set counter of first 0 to 0 (default)
		mov		r5, #12					@ Loop counter = 12
clockLoop:								@ Clock line is high...
		mov		r0, #6
		bl		delayMicroseconds		@ 6 microsecond delay
		mov		r0, #0
		bl		Write_Clock				@ Set clock line to low
		mov		r0, #6
		bl		delayMicroseconds		@ 6 microsecond delay
		lsl		r7, #1					@ Shift result register by 1
		bl		Read_Data				@ Check data line on rising edge of clock line		
		teq		r0, #0
		bne		one
		teq		r8, #1					@ Check "stored counter" flag
		beq		bot						@ If set, branch to bot	
		mov		r9, r5					@ Store counter of first 0
		mov		r8,	#1					@ Set "stored counter" flag
		b		bot
one:		
		orr		r7,	r7, #1				@ Button is not pressed, write a 1 to result register
bot:		
		mov		r0, #1		
		bl		Write_Clock				@ Set clock line to high
		subs	r5, #1					
		bne		clockLoop	
		mov		r0, r7					@ Return contents of result register
		mov		r1, r9					@ Return counter of first 0
		pop		{r5, r6, r7, r8, r9, pc}

/*	
 * Init_GPIO sets a GPIO pin function
 *
 * Params:
 * r0 = GPIO pin number
 * r1 = Function code	
 * r2 = GPIO virtual base address
 * 
 * Postcondition:
 * The specified GPIO pin has been assigned a new function
 * 
 * Returns: nothing
 */
Init_GPIO:
loop:
		cmp		r0, #9
		subhi	r0, #10
		addhi	r2, #4
		bhi		loop
		
		add		r0, r0, lsl #1
		lsl		r1, r0
		
		mov		r3, #7
		lsl		r3, r0
		
		ldr		r0, [r2]
		bic		r0, r3
		orr		r0, r1
		str		r0, [r2]
		bx		lr

@ Data section
.section    .data

.align 2

.global gpioBaseAddress
gpioBaseAddress:
.int	0
