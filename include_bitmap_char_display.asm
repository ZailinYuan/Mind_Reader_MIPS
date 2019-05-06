
.data

#	Botmap board data
BWIDTH:			.word		512						#	Width of the canvas in pixels
BHEIGHT:		.word		512						#	Height of the canvas in pixels

WIDTHP:			.word		4						#	Width in pixels of memory word
HEIGHTP:		.word		4						#	Height in pixels of memory word

BOARD:			.word		0						#	Placeholder variable for the 2d bitmap canvas address

#	Bitmap character representations
DIGITS:			.word		0x69999996, 0xf6666676, 0xff1ff8ff, 0xff8ff8ff, 0x888ff999, 0xff8ff1ff, 0xff9ff177, 0x13264c8f, 0xff9ff9ff, 0x888ff9ff, 0x00000000 #bitmap digits
LETTERS:		.word		0x9ff99ff6, 0xf99f7f9f, 0x6f9119f6, 0x7f9999f7, 0xff1ff1ff, 0x1111f11f, 0xf999d11f, 0x999ff999, 0xff6666ff, 0x7554444f, 0x99533599, 0xf1111111, 0x99999ff9, 0x999999bd, 0x69999996, 0x11117997, 0x1eb9999f, 0x99537997, 0xf88ff11f, 0x6666666f, 0xf9999999, 0x66999999, 0x9ff99999, 0x99966999, 0x66666999, 0xf1136ccf #bitmap letters
QMARK:			.word		0x6606c89f
EXCLAMATION:		.word		0x66066666
COLON:			.word		0x06600660
LPAREN:			.word		0x63111136
RPAREN:			.word		0x6c8888c6
INVALID_CHAR:		.word		0xffffffff

.text

				j			end1

##	allocpixels:	Allocates space on the heap for the bitmap array based on the predefined macro values
#	Return:	$v0:		The total number of words allocated for the bitmap board
#	Return:	$v1:		The width in words
allocpixels:			addi			$sp, $sp, -4				#	Allocate a word on the stack
				sw			$ra, 0($sp)				#	Store return address on the stack
				
				lw			$t0, BWIDTH				#	$t0 = BWIDTH
				lw			$t2, WIDTHP				#	$t2 = WIDTHP
				div			$t0, $t0, $t2				#	$t0 = number of words wide
				
				lw			$t1, BHEIGHT				#	$t1 = BHEIGHT
				lw			$t2, WIDTHP				#	$t2 = WIDTHP
				div			$t1, $t1, $t2				#	$t1 = number of words high
				
				mult			$t0, $t1				#	Multiple the width and height of the board
				
				mflo 			$t2					#	$t2 = the product. (In mars, for the bitmap display sizes, the product will always be low enough to fit into a signle register)
				
				sll			$a0, $t2, 2				#	$a0 = number of bytes to be allocated
				li			$v0, 9					#	Ready to allocate bytes on the heap
				syscall								#	Allocate ($a0) bytes on the heap
				
				sw			$v0, BOARD				#	BOARD = beginning address of the allocated memory
				
				move			$v0, $t2				#	$v0 = $t2 (the number of words allocated)
				move			$v1, $t0				#	$v1 = $t0 (the number of words wide)
				
				addi			$sp, $sp, 4				#	Pop a word from the stack
				lw			$ra, -4($sp)				#	$ra = return address
				jr			$ra					#	return
##	End of allocpixels


##	clearboard:	Clear the board and set its background color to the color passed in $a1
#	Param:	$a0:		Number of allocated words in the board
#	Param	$a1:		The color to be cleared to (24 bit RGB)
clearboard:			addi			$sp, $sp, -4				#	Allocate a word on the stack
				sw			$ra, 0($sp)				#	Store return address on the stack
				
				lw			$t0, BOARD				#	$t0 = first address of board
				sll			$t1, $a0, 2				#	$t1 = the difference between the first and last address of 'board'
				add			$t1, $t1, $t0				#	$t1 = last address of board
				
while4:				bge			$t0, $t1, finish4			#	If the index is out of bounds, branch to finish1
				
				sw			$a1, ($t0)				#	Set the pixel at $t0 to black
				addi			$t0, $t0, 4				#	Increment $t0 to next word
				j			while4					#	Jump to beginning of while loop				
				
finish4:			addi			$sp, $sp, 4				#	Pop a word from the stack
				lw			$ra, -4($sp)				#	$ra = return address
				jr			$ra					#	return
##	End of clearboard			
						
##	nextaddress:		Using an x index and y index given the board width, calculate the next address and chang the given indices accordingly
#	Param:	$a0:		The x index
#	Param: 	$a1:		The y index
#	Param	$a2:		width of the board in words
#	Return:	$v0:		Top left corner address of next rectangle to write to
nextaddress:			lw			$t5, BOARD
				addi			$sp, $sp, -4				#	Allocate a word on the stack
				sw			$ra, ($sp)				#	Store the return address on the stack
				
				sll			$t0, $a2, 2				#	$v0 = width of board in bytes
								
				sll			$t1, $a1, 5				#	$t1 = number of y grid spaces to shift
				multu			$a2, $t1				#	y index * width of board
				mflo			$t1					#	$t1 = number of addresses to shift for the vertical shift to appear

				add			$t5, $t5, $t1				#	$t5 = board0][0] index + number of y axis byte shifts
				
				addi			$t1, $zero, 20				#	$t1 = 20
				multu			$a0, $t1				#	$a0 * t1
				mflo			$t2					#	$t2 = number of x axis byte shifts
				
				add			$t5, $t5, $t2				#	$t5 = $t5 + number of x axis byte shifts
				
				mult			$t0, $a1				#	Width of board in bytes * y index
				mflo			$t2					#	$t2 = extra y axis shifts for formatting
				
				add			$t5, $t5, $t2				#	$t5 = $t5 + number of addresses to shift for the extra certical formatting shifts to be correct
				add			$t5, $t5, $t0				#	Shifts the antire board down 1 pixel
				addi			$t5, $t5, 8				#	Shifts the entire board right 2 pixels (to center)
				
				move			$v0, $t5				#	Return value = address of next rectangle top left corner

if6:				blt			$a0, 24, else6				#	if $a0 < 7, branch to else3
				move			$a0, $zero				#	x index = 0
				addi			$a1, $a1, 1				#	++ y index
				j			ifin6					#	Jump to the subroutine finish
				
else6:				addi			$a0, $a0, 1				#	++ x inde

ifin6:				move			$v0, $t5
				addi			$sp, $sp, 4				#	Pop a word from the stack
				lw			$ra, -4($sp)				#	$ra = return address
				jr			$ra					#	return
																											
##	printchar:		"Prints" a character to the board based on its 32 bit representation in pixels
#	Param:	$a0:		The address of the top left corner to write colors to
#	Param:	$a1:		The width BOARD in words
#	Param	$a2:		numerical representation of the character (32 bits)
#	Param 	$sp:		The color of the pixels to be printed
printchar:			lw			$t2, ($sp)				#	$t2 = color
				addi			$sp, $sp, -4				#	Allocate a word on the stack
				sw			$ra, ($sp)				#	Store return address on the stack 
								
				sll			$a1, $a1, 2				#	$a1 = number of addresses wide
				move			$t0, $zero				#	$t0 = 0 (will function as a counter)

while3:				beqz			$a2, finish2				#	if $a2 == 0, branch to finish2
				andi			$t1, $a2, 1				#	$t1 = 1 if $a0 has a 1 bit, otherwise = 0
				
				beqz			$t1, inc1				#	Skip writing the color if one should not be here
				
				sw			$t2, ($a0)				#	Set the pixel at $a0 = $t2 color
				
inc1:				addi			$a0, $a0, 4				#	Increment the address of the next color
				addi			$t0, $t0, 1				#	$t0++
				blt			$t0, 4, backto1				#	if $t0 < 4, branch to backto1
				
				add			$a0, $a0, $a1				#	$a0 = next column down
				addi			$a0, $a0, -16				#	$a0 = first in the same box on next column
				move			$t0, $zero				#	$t0 = 0
				
backto1:			srl			$a2, $a2, 1				#	$a2 /= 2
				j			while3					#	Repeat the while loop		
				
finish2:			addi			$sp, $sp, 4				#	Pop a word from the stack
				lw			$ra, -4($sp)				#	$ra = return address
				jr			$ra					#	return
##	End of printchar				


end1:
