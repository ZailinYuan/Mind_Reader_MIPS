#	CLASS:			CS 3340 SECTION 503
#	TEAM NAME: 		Network Nhuts
#	GROUP MEMBERS:		Jason Brown, Skylar Cupit, Nathan Brown, Zailin (Bill) Youn

.include			"include_bitmap_char_display.asm"
.include			"music.asm"

.data

REPLAYP:	.asciiz		"\nWould you like to play again? (y or n): "

#	Messages and prompts to write to the bitmap
BMPROMPT:	.asciiz		"Does your number appear  here? (y or n): "
BMFINISH:	.asciiz		"Your number is: "
BMREPLAYP:	.asciiz		"Would you like to play   again? (y or n): "
BMENDMESSAGE:	.asciiz		"   Thanks for playing!"
BMREADYPROMPT:	.asciiz		"        Get ready"

#	Other variables
EMPTY_STRING:	.asciiz		"\0"
INDEX_LIMIT:	.word		6
INDEX_LIM_COPY:	.word		6		#	Same number as index limit. Used for stack deallocation of the index array
INDEX_0_POS:	.word		20		#	(4 * INDEX_LIMIT) - 4
RAND_SEED: 	.word		0		#	Placeholder for the ranodom int seed

#	Center line position for easy access
TEXT_LINE_X:	.word		0
TEXT_LINE_Y:	.word		6

#	Colors
BACKG_COLOR_0:	.word		0x0a0ad1 #0x158e86
BACKG_COLOR_1:	.word		0x005560 #0x00007a
BACKG_COLOR_2:	.word		0x000000

TEXT_COLOR_0:	.word		0xffffff
TEXT_COLOR_1:	.word		0xf7c931
TEXT_COLOR_2:	.word		0xfc5235

.text	
	
###		main method
main:
	
				jal		allocpixels				#	Allocate space on the heap for the BOARD
				move		$s2, $v0				#	$s0 = number of words allocated
				move		$s3, $v1				#	$s1 = width of BOARD in words
	
init:				addi		$t0, $zero, 6
				sw		$t0, INDEX_LIMIT

				lw		$s0, INDEX_LIMIT			#	$s0 = 0 (serves as the 'n' in 2 ^ n when using prntnums and adding to the result)
				move		$s1, $zero				#	#s1 = 0 (serves as the output "guess" number)
				
				move		$s4, $zero				#	x index = 0
				move		$s5, $zero				#	y index = 0
				lw		$s6, BACKG_COLOR_1		#	$s6 = board background color
				
				lw		$s7, TEXT_COLOR_0		#	$s7 = text color
				
				li		$v0, 30
				syscall

				sw		$a0, RAND_SEED				#	store the random num gen seed as the low order bits of the system time
				
				

whileninit:			beq		$zero, $s0, endwhileninit	
				addi		$sp, $sp, -4
				addi		$s0, $s0, -1
				sw		$s0, ($sp)
				j		whileninit
endwhileninit:			#	Array of indices is now initialized	

				li		$a0, 0				#	seed id
				lw		$a1, RAND_SEED			#	seed value
				li		$v0, 40
				syscall

				move		$a0, $s2
				lw		$a1, BACKG_COLOR_2
				jal 		clearboard

				addi		$sp, $sp, -8
				sw		$s3, 4($sp)
				lw		$t1, TEXT_COLOR_2
				sw		$t1, ($sp)
				
				la		$a0, BMREADYPROMPT
				lw		$a1, TEXT_LINE_X
				lw		$a2, TEXT_LINE_Y
				jal		prntstr
				
				addi		$sp, $sp, 8

				jal		Sound2

while1	:			move		$a0, $s2
				move		$a1, $s6
				jal 		clearboard
				
				li		$a0, 0				#	Use random number generato id 0
				li		$v0, 41				
				syscall
				
				lw		$t1, INDEX_LIMIT
				
				divu		$a0, $t1
				mfhi		$t0				#	$t0 = random index within bounds of remaining array

				sll		$t0, $t0, 2
				add		$t0, $t0, $sp			#	$t0 = $sp + word index offset
				lw		$s0, ($t0)			#	$s0 = next power of 2		

				sub		$t1, $t1, 1
				sw		$t1, INDEX_LIMIT		#	Decrement the index limit
				
				sll		$t1, $t1, 2
				add		$t1, $t1, $sp			#	$t1 = address of last element in the array
				
whilenshifted:			beq		$t0, $t1, donenshifted		#	Shift the array accordingly.
				lw		$t2, 4($t0)
				sw		$t2, ($t0)
				addi		$t0, $t0, 4
				
				j		whilenshifted
				
donenshifted:			move		$a0, $s0			#	Array is finished shifting

				and		$s4, $s4, $zero			#	x index = 0
				#and		$s5, $s5, $zero			#	y index = 0
				addi		$s5, $zero, 1

				move		$a1, $s4
				move		$a2, $s5
				
				addi		$sp, $sp, -8
				sw		$s3, 4($sp)
				sw		$s7, ($sp)

				jal		prntnums				#	call prntnums
				move		$s4, $v0
				move		$s5, $v1
				
				lw		$t1, TEXT_COLOR_1			#	Load text color
				sw		$t1, ($sp)				#	Set text color (in stack)
				
				la		$a0, BMPROMPT
				lw		$a1, TEXT_LINE_X
				lw		$a2, TEXT_LINE_Y
				addi		$a2, $a2, 2
				jal		prntstr					#	Print the prompt string
				
				or		$s4, $v0, $zero
				or		$s5, $v1, $zero
				
				addi		$sp, $sp, 8
				
				li			$v0, 11					#	Ready to print character
				li			$a0, 10					#	$a0 = newline
				syscall		
				
				la		$a0, BMPROMPT			#	$a0 = beginning address of prompt
				jal 		promptbool				#	call promptbool
				move		$t0, $v0				#	$t0 = $v0 (boolean)
				
if2:				beqz		$t0, check				#	if $t0 == false, branch to check
				sllv		$t1, $t0, $s0				#	$t1 = 2 ^ ($s0)
				add		$s1, $s1, $t1				#	result in $s0 += $t1
				
check:				lw		$t2, INDEX_LIMIT
				bne		$t2, 0, while1
				
				or		$a0, $s2, $zero
				or		$a1, $s6, $zero
				jal		clearboard
				
				#jal		twonewlines				#	Print two newlines
				
				addi		$sp, $sp, -8
				sw		$s3, 4($sp)
				sw		$s7, ($sp)
				
				la		$a0, BMFINISH
				lw		$a1, TEXT_LINE_X
				lw		$a2, TEXT_LINE_Y
				addi		$a2, $a2, -1
				jal		prntstr
				
				or		$s4, $v0, $zero
				or		$s5, $v1, $zero
							
				lw		$t1, TEXT_COLOR_2			#	Load text color
				sw		$t1, ($sp)				#	Set text color (in stack)
							
				or		$a0, $s1, $zero
				or		$a1, $s4, $zero
				or		$a2, $s5, $zero
				jal		prntnum
				
				or		$s4, $v0, $zero
				or		$s5, $v1, $zero
				
				lw		$t1, TEXT_COLOR_1			#	Load text color
				sw		$t1, ($sp)				#	Set text color (in stack)
				
				la		$a0, BMREPLAYP
				lw		$a1, TEXT_LINE_X
				lw		$a2, TEXT_LINE_Y
				addi		$a2, $a2, 2
				jal		prntstr
				
				addi		$sp, $sp, 8
				
				#li		$v0, 4					#	Ready to print String
				#la		$a0, GUESSP				#	$a0 = first address of GUESSP
				#syscall							#	print GUESSP
				
				#li		$v0, 1					#	Ready to print integer
				#move		$a0, $s1				#	$a0 = 'guess' result
				#syscall							#	Print the result
				
				#jal		twonewlines				#	Print two newlines
				
				la		$a0, REPLAYP				#	$a0 = beginning address of REPLAYP
				jal 		promptbool				#	call promptbool
				
				move		$t0, $v0				#	$t0 = the result in $v0 (boolean)
				
				jal		twonewlines				#	print two newlines
				
				bnez		$t0, init				#	If the user wants to play again, branch back to the init step before the while loop
				
				lw		$t0, INDEX_LIM_COPY
deallocarr:			beq		$t0, $zero, end
				addi		$sp, $sp, 4
				addi		$t0, $t0, -1
				j		deallocarr
				
end:				or		$a0, $s2, $zero				
				lw		$a1, BACKG_COLOR_0
				jal		clearboard

				addi		$sp, $sp, -8
				sw		$s3, 4($sp)
				sw		$s7, ($sp)
				
				la		$a0, BMENDMESSAGE
				lw		$a1, TEXT_LINE_X
				lw		$a2, TEXT_LINE_Y
				jal		prntstr
				
				addi		$sp, $sp, 8

				jal		Sound1

				li		$v0, 10					#	
				syscall							#	terminate the program

###	End of main method

		
##	prntstr: print a given string to the bitmap
#	Param: $a0: the beginning address of the string to print
#	Param: $a1: x index
#	Param: $a2: y index
#	Param: 4($sp): The width of the board in words
#	Param: ($sp): The color of the characters to be printed
#	Return: $v0: the next x-index
#	Return: $v1: the next y-index
prntstr:		addi			$sp, $sp, -4
			sw			$ra, ($sp)
			
while5:			addi			$sp, $sp, -4
			sw			$a0, ($sp)
			
			or			$a0, $a1, $zero
			or			$a1, $a2, $zero
			lw			$a2, 12($sp)
			
			jal			nextaddress
			
			or			$t1, $v0, $zero			#	$t1 = address to print the character to
			
			or			$a2, $a1, $zero
			or			$a1, $a0, $zero
			
			lw			$a0, ($sp)
			addi			$sp, $sp, 4

			lbu			$t0, ($a0)			#	Load the next character into $t0
			
			beq			$t0, '\0', endprntstr		
			
			
ifspc:			bne			$t0, ' ', elifqmark
			lw			$t0, DIGITS + 40
			j			endifinvalid

elifqmark:		bne			$t0, '?', elifexclamation	
			lw			$t0, QMARK
			j			endifinvalid
			
elifexclamation:	bne			$t0, '!', elifcolon	
			lw			$t0, EXCLAMATION
			j			endifinvalid

elifcolon:		bne			$t0, ':', eliflparen
			lw			$t0, COLON
			j			endifinvalid
			
eliflparen:		bne			$t0, '(', elifrparen
			lw			$t0, LPAREN
			j			endifinvalid

elifrparen:		bne			$t0, ')', elifnnul
			lw			$t0, RPAREN
			j			endifinvalid
			
elifnnul:		subi			$t4, $t0, 'a'			#	Calculate the index of the character in the predefined LETTERS array
			subi			$t5, $t0, 'A'			#	Calculate the index if the letter is capitalized
iflowercase:		blt			$t4, 0, ifuppercase
			bgt			$t4, 25, ifuppercase
			sll			$t0, $t4, 2
			j			endifcase
			
ifuppercase:		blt			$t5, 0, elseinvalid
			bgt			$t5, 25, elseinvalid
			sll			$t0, $t5, 2
			j			endifcase
		
endifcase:		lw			$t0, LETTERS($t0)		#	$t0 is the address of the character to print to the bitmap		
			j			endifinvalid
			
elseinvalid:		lw			$t0, INVALID_CHAR

endifinvalid:
			
			#li			$t0, 0xffffffff
			
			addi			$sp, $sp, -16		
			
			sw			$a0, 12($sp)
			sw			$a1, 8($sp)
			sw			$a2, 4($sp)
			
			lw			$t2, 20($sp)
			sw			$t2, ($sp)
			
			or			$a0, $t1, $zero
			lw			$a1, 24($sp)
			or			$a2, $t0, $zero
			
			jal			printchar
			
			lw			$a0, 12($sp)
			lw			$a1, 8($sp)
			lw			$a2, 4($sp)
			
			addi			$sp, $sp, 16

			addi			$a0, $a0, 1			#	increment the character to print
			j			while5
			
endwhile5:	
endprntstr:	
			or			$v0, $a1, $zero
			or			$v1, $a2, $zero
			
			lw			$ra, ($sp)
			addi			$sp, $sp, 4
			jr			$ra
###	End of prntstr method

	
##	prntnums: 	Print all 6-bit numbers that contain the bit 2^n where n is the argument passed in $a0
#	Param:	$a0: The power of 2 to be included in the printed numbers.
#	Param:	$a1: x index
#	Param:	$a2:	y index
#	Param:	4($sp):	The width of the board in words
#	Param	($sp):	The Color of the character to be printed
#	Return:	$v0:	next x-index
#	Return:	$v1: 	next y-index
prntnums:		addi			$sp, $sp, -4				#	Allocate space for the return address on the stack
			sw 			$ra, ($sp)				#	Store the return address on the stack
			
			li			$t0, 1					#	$t0 holds the value 1
			sllv			$t0, $t0, $a0				#	$t0 holds the value of the the power of two specified by $a0
			
			move			$t1, $t0				#	Sets number to print  = $t0
			and			$t2, $zero, $zero			#	counter = 0
			and			$t4, $zero, $zero			#	totalNums

	
prntn:			addi			$sp, $sp, -28

			sw			$t0, 24($sp)
			sw			$t1, 20($sp)
			sw			$t2, 16($sp)
			sw			$t3, 12($sp)
			sw			$t4, 8($sp)
				
				
			lw			$t5, 32($sp)
			sw			$t5, ($sp)
			lw			$t5, 36($sp)
			sw			$t5, 4($sp)
				
			blt			$a1, 24, pr
				
			and			$a1, $a1, $zero
			addi			$a2, $a2, 1
				
pr:			move		$a0, $t1
			jal			prntnum
				
			move		$t6, $v0
			move		$t7, $v1
								
			lw			$t0, 24($sp)
			lw			$t1, 20($sp)
			lw			$t2, 16($sp)
			lw			$t3, 12($sp)
			lw			$t4, 8($sp)
				
			addi			$sp, $sp, 28

			li			$v0, 1
			add			$a0, $t1, $zero				#	$a0 holds the value to be printed
			#syscall								#	print the value in $t0
			
			li			$v0, 11
			li			$a0, 32					#	Store the SPACE character in $a0
			#syscall								#	print a space between the numbers
				
			addi		$t6, $t6, 1
				
			bgeu		$t1, 10, addval					#	Do not print a second space if the number is two digits
				
			#syscall								#	Print the first extra space
			#syscall								#	Print the second extra space.
				
			addi		$t6, $t6, 1	
		
addval:			addiu		$t1, $t1, 1					#	increment $t1 (number to print)
			addiu		$t2, $t2, 1					#	increment $t2 (counter)
			addiu		$t4, $t4, 1					#	Increment $t4 (total number of numbers printed)
				
			addi		$t3, $zero, 8					#	loads the grid length limit into $t3
			divu		$t4, $t3					#	Divide the number to print by the grid length limit
			mfhi		$t3						#	Modulus output stored in $t3
				
			bnez		$t3, ifless					#	If not on the 8th number in a row, do not print a new line.
				
			li		$v0, 11
			li		$a0, 10						#	Load the LINE FEED character into #a0
			#syscall								#	Prints a newline when the limit is reached
			
ifless:			bltu		$t2, $t0, nxt					#	If counter <= the specified 2^n, branch to NXT
				
			add		$t1, $t1, $t0					#	Add the bit specified by $t0 to the number to print
			and		$t2, $zero, $zero				#	Set counter = 0
				
nxt:			addi		$t3, $t3, 63					#	$t3 holds the maximum number to be printed
			move		$a1, $t6
			move		$a2, $t7
			bleu		$t1, $t3, prntn					#	If the number to print is below or equal to the limit, branch to PRINTN
				
			move		$v0, $t6
			move		$v1, $t7
				
			addi		$sp, $sp, 4					#	Else pop from the stack
			lw		$ra, -4($sp)					#	$ra = return address
				
			jr		$ra						#	return
##	end or prntnums

##	prntnum:		Parses an integer and prints it to the board
#	Param:	$a0:		The number to be printed
#	Param:	$a1:		x index
#	Param:	$a2:		y index
#	Param:	4($sp):	The width of the board in words
#	Param:	($sp):	The color of the characters to be printed
#	Return:	$v0:		New x index
#	Return	$v1:		New y index
prntnum:		addi			$sp, $sp, -4				#	Allocate a word on the stack
			sw			$ra, ($sp)				#	Store the return address on the stack
				
			blt			$a0, 10, pdigit				#	if $a0 < 10, branch to pdigit
				
			addi			$t0, $zero, 10				#	$t0 = 0
			div			$a0, $t0				#	num / $t0
				
			mflo			$a0					#	$a0 = quotient
			mfhi			$t0					#	$t0 = remainder
				
			lw			$t1, 8($sp)				#	$t1 = width of board in words
			lw			$t2, 4($sp)				#	$t2 = color of chars to be printed
				
			addi			$sp, $sp, -12				#	Allocate 3 words on the stack
				
			sw			$t0, 8($sp)				#	8($sp) = integer to be printed
			sw			$t1, 4($sp)
			sw			$t2, ($sp)
			jal			prntnum
				
			move		$a1, $v0
			move		$a2, $v1
				
			lw			$a0, 8($sp)
			addi			$sp, $sp, 12
				
				
pdigit:			addi			$sp, $sp, -4
			sw			$a0, ($sp)
				
			move		$a0, $a1				
			move		$a1, $a2
			lw			$a2, 12($sp)
			jal			nextaddress
				
			move		$t0, $v0
				
			move		$t1, $a0
			move		$a2, $a1
			move		$a1, $t1
				
			lw			$a0, ($sp)
				
			addi			$sp, $sp, -4
			sw			$a1, 4($sp)
			sw			$a2, ($sp)
				
			sll			$a2, $a0, 2
				
			lw			$a2, DIGITS($a2)
				
			move		$a0, $t0
				
			lw			$a1, 16($sp)
				
			lw			$t4, 12($sp)
			addi			$sp, $sp, -4
			sw			$t4, ($sp)
				
			jal			printchar
				
				
			lw			$v0, 8($sp)
				
			lw			$v1, 4($sp)
			addi			$sp, $sp, 12
				
				
			addi			$sp, $sp, 4
			lw			$ra, -4($sp)
			jr			$ra
				

##	End of prntnum


##	promptbool:		queries the user using the prompt passed in $a0, then returns true or false when they answer either 'y' or 'n'
#	Param: 	$a0:		The starting string address of the prompt to be printed
#	Return:	$v0:		1 if answered "'y', 0 if answered 'n'
promptbool:		addi			$sp, $sp, -8				#	Allocate two words on the stack
			sw			$ra, 4($sp)				#	Store the return address on the stack
			sw			$a0, 0($sp)				#	Store the initial prompr address on the stack
				
nprompt:		li			$v0, 4					#	Ready to print a String
			lw			$a0, 0($sp)				#	$a0 = beginning address of the prompt (which is stored on the top of the stack)
			syscall								#	Print the prompr
				
			li			$v0, 12					#	Ready to read character
			syscall								#	Read character
				
if1:			bne			$v0, 121, elif1				#	if $v0 != 'y', branch to elif1
			addi			$v0, $zero, 1				#	$v0 = true
			j			answered				#	exit if statement
				
elif1:			bne			$v0, 110, else1				#	else if $v0 != 'n', branch to else
			move			$v0, $zero				#	$v0 = false
			j			answered				#	exit if statement
				
else1:			li			$v0, 11					#	Ready to print character
			li			$a0, 10					#	$a0 = newline
			syscall								#	Print a newline
			j			nprompt					#	Jump back to prompt since the input is invalid
				
answered:		addi			$sp, $sp, 8				#	Else pop two words from the stack
			lw			$ra, -4($sp)				#	$ra = return address form the stack
				
			jr			$ra					#	return
##	End of promptbool


##	twonewlines:		Print two newlines to the console for formatting purposes
twonewlines:		addi			$sp, $sp, -4				#	Allocate a word on the stack
			sw			$ra, 0($sp)				#	Store the return address on the stack
				
			li			$v0, 11					#	Ready to print character
			li			$a0, 10					#	$a0 = newline
			syscall								#	Print a newline
			syscall								#	Print a newline
				
			addi			$sp, $sp, 4				#	Pop a word from the stack
			lw			$ra, -4($sp)				#	$ra = return address
			jr			$ra						#	return
##	end of twonewlines
