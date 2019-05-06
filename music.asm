.data					
						PACE:		.word	600			# pace of playing the music
						PACE2:		.word	300			# pace of playing the music
						PACE3:		.word	450			# pace of playing the music
						PACE4:		.word	150			# pace of playing the music
						TONELENGTH:	.word	1000		# how long does one tone last
						LONGTONE:	.word	2000		# long tone
						ONEHALFTONE:	.word	1500		# half long tone
						HALFTONE:	.word	500		# half tone
						GUITAR:		.word	24			# choose guitar as instrument
						VOLUME:		.word	100			# sound volume:	100
						
						TMP1:		.space	4		# temporary data storeage
						TMP2:		.space	4		# temporary data storeage
						TMP3:		.space	4		# temporary data storeage
						TMP4:		.space	4		# temporary data storeage
						TMP5:		.space	4		# temporary data storeage
						TMP6:		.space	4		# temporary data storeage
						TMP7:		.space	4		# temporary data storeage
						TMP8:		.space	4		# temporary data storeage

						SOUNDTRACK1:	.word 61 61 68 68 70 70 68 128 66 66 65 65 63 63 61 128 0		# music tones.    128 - NULL tone; 0 - end of the music segment.
						SOUNDTRACK2:	.word 65 65 66 68 68 66 65 63 61 61 63 65 63 129 61 130 61 130 0 0	# music tones.    128 - NULL tone; 0 - end of the music segment.
.text
								j	end2
						
						
			# Play sound track 1:
						Sound1:		
								# store registers in TMP:
								sw	$a0,	TMP1
								sw	$a1,	TMP2
								sw	$a2,	TMP3
								sw	$a3,	TMP4
								sw	$s6,	TMP5
								sw	$s7,	TMP6
								sw	$v0,	TMP7
								
								# counter
								la	$s7,	SOUNDTRACK1			# initial address of music.
		
								j	rhythm
		
						SoundTrack:	lw	$s6,	4($s7)			# one tone further.
								beq	$s6,	128,	tone1		# play tone one
								beq	$s6,	$zero,	continue	# play again
	
						tone2:		# normal tone:
								li	$v0,	31
								lw	$a0,	($s7)
								lw	$a1,	TONELENGTH
								lw	$a2,	GUITAR
								lw	$a3,	VOLUME
								syscall	
		
								addi	$s7,	$s7,	4
		
								j	rhythm
		
						tone1:		# sound delay tone:
								li	$v0,	31
								lw	$a0,	($s7)
								lw	$a1,	LONGTONE
								lw	$a2,	GUITAR
								lw	$a3,	VOLUME
								syscall	
		
								addi	$s7,	$s7,	4	
		
								j	rhythm
		
		
						rhythm:		# one second pause:
								li	$v0,	32
								lw	$a0,	PACE
								syscall
		
								j	SoundTrack		
			
						continue:		
								# restore registers from TMP:
								lw	$a0,	TMP1
								lw	$a1,	TMP2
								lw	$a2,	TMP3
								lw	$a3,	TMP4
								lw	$s6,	TMP5
								lw	$s7,	TMP6
								lw	$v0,	TMP7
								
								jr	$ra	
						
						
			# Play sound track 2
						Sound2:		
								# store registers in TMP:
								sw	$a0,	TMP1
								sw	$a1,	TMP2
								sw	$a2,	TMP3
								sw	$a3,	TMP4
								sw	$s6,	TMP5
								sw	$s7,	TMP6
								sw	$v0,	TMP7
						
								# counter
								la	$s7,	SOUNDTRACK2			# initial address of music.
		
								j	rhythm2
		
						SoundTrack2:	lw	$s6,	4($s7)			# one tone further.
								beq	$s6,	128,	tone3		# play tone one
								beq	$s6,	129,	tone5		#
								beq	$s6,	130,	tone6		#
								beq	$s6,	$zero,	continue2		# play again
	
						tone4:		# normal tone:
								li	$v0,	31
								lw	$a0,	($s7)
								lw	$a1,	TONELENGTH
								lw	$a2,	GUITAR
								lw	$a3,	VOLUME
								syscall	
		
								addi	$s7,	$s7,	4
		
								j	rhythm2
		
						tone3:		# sound delay tone:
								li	$v0,	31
								lw	$a0,	($s7)
								lw	$a1,	LONGTONE
								lw	$a2,	GUITAR
								lw	$a3,	VOLUME
								syscall	
		
								addi	$s7,	$s7,	4	
		
								j	rhythm2
								
						tone5:		# sound delay tone:
								li	$v0,	31
								lw	$a0,	($s7)
								lw	$a1,	ONEHALFTONE
								lw	$a2,	GUITAR
								lw	$a3,	VOLUME
								syscall	
		
								addi	$s7,	$s7,	8	
		
								j	rhythm3
								
						tone6:		# sound delay tone:
								li	$v0,	31
								lw	$a0,	($s7)
								lw	$a1,	HALFTONE
								lw	$a2,	GUITAR
								lw	$a3,	VOLUME
								syscall	
		
								addi	$s7,	$s7,	8	
		
								j	rhythm4
		
						rhythm2:	# one second pause:
								li	$v0,	32
								lw	$a0,	PACE2
								syscall
		
								j	SoundTrack2	
								
						rhythm3:	# one and half second pause:
								li	$v0,	32
								lw	$a0,	PACE3
								syscall
		
								j	SoundTrack2
								
						rhythm4:	# one and half second pause:
								li	$v0,	32
								lw	$a0,	PACE4
								syscall
		
								j	SoundTrack2
			
						continue2:		
								# restore registers from TMP:
								lw	$a0,	TMP1
								lw	$a1,	TMP2
								lw	$a2,	TMP3
								lw	$a3,	TMP4
								lw	$s6,	TMP5
								lw	$s7,	TMP6
								lw	$v0,	TMP7	
								
								jr	$ra	

						
						end2:		
