
@ Code section
.section .text

.global main
main:
	@ Initialize the SNES driver
	bl		InitSNES
	
	@ Get frame buffer information
	ldr 	r0, =frameBufferInfo 		@ frame buffer information structure
	bl		initFbInfo

	@ Execute home loop logic
	bl		HomeLoop		// (game.s)
	
.global GameLoop
GameLoop:
	bl		ReadSNES		// read from the SNES controller (snes_driver.s)
	bl		Update			// update game state variables (movement.s)
	bl		ClearObjects	// erase necessary game grid tiles (clearing.s)
	bl		DrawObjects		// re-draw the paddle & ball (drawing.s)

	mov		r0, #5000
	bl		delayMicroseconds
	b		GameLoop

@ Data section
.section .data

.align
.global frameBufferInfo
frameBufferInfo:
	.int	0							@ frame buffer pointer
	.int	0							@ screen width (1824px)
	.int	0							@ screen height (984px)

// Sizes:
//					X	  Y
// ball: 			32  x 32
// grid:			576 x 672	(origin at 624 x 156)
// small_paddle:	96  x 21
// block:			48  x 32
// wall:			48  x 32
// background:		48  x 32
// value pack:		40  x 15
// game lost/won:	450 x 300

// game play area:	480 x 640
// n = 12, m = 21, making a 252 cell grid

.global width
width:
.int	0

.global height
height:
.int	0

.global game_map
game_map:
.rept	252			// Game play area grid
.byte	0			// 0=background, 1=wall, 2=white_block
.endr

.global paddle_position
paddle_position:
.int	864			// grid x origin + 240 (5 blocks across)
.int	700			// grid y origin + 554 (17 blocks down)

.global ball_position
ball_position:
.int	880			// grid x origin + 256
.int	667			// grid x origin + 512
.int	0			// angle (0=45 degrees, 1=60 degrees)
.int	1			// direction (1-4: 1=NW, 2=NE, 3=SE, 4=SW)
.int	0			// ball is active flag

.global score
score:
.int	0			// player score

.global lives
lives:
.int	5			// number of lives (default=5)

.global win
win:
.int	0			// win flag

.global lose
lose:
.int	0			// lose flag

.global value_pack1
value_pack1:
.int	6			// row index
.int	9			// column index
.int	0			// falling? (0=no, 1=yes)
.int	0			// effect enabled? (0=no, 1=yes)
.int	0			// x
.int	0			// y

.global value_pack2
value_pack2:
.int	6			// row index
.int	5			// column index
.int	0			// falling? (0=no, 1=yes)
.int	0			// effect enabled? (0=no, 1=yes)
.int	0			// x
.int	0			// y

// USED FOR COLLISION CALCULATIONS
.global top_left
top_left:
.int	0			// tile index
.int	0			// tile type

.global top_right
top_right:
.int	0
.int	0

.global bottom_left
bottom_left:
.int	0
.int	0

.global bottom_right
bottom_right:
.int	0
.int	0
