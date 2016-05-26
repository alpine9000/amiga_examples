	include "includes.i"
	xdef DrawText8
	xdef font
	
BLIT_LF_MINTERM		equ $ca		; cookie cut
BLIT_WIDTH_WORDS	equ 2		; blit 2 words to allow shifting
BLIT_WIDTH_BYTES	equ 4
FONT_HEIGHT		equ 8
FONT_WIDTH		equ 8
FONTMAP_WIDTH_BYTES	equ 32
_SCREEN_BIT_DEPTH	equ 4
_BITPLANE_WIDTH_BYTES	equ 320/8
	
DrawText8:
	;; a0 - bitplane
	;; a1 - text
	;; d0 - xpos
	;; d1 - ypos	
	movem.l	d0-d3/a1-a2,-(sp)
	WaitBlitter

	;; blitter config that is shared for every character
	move.w	#BC0F_SRCB|BC0F_SRCC|BC0F_DEST|BLIT_LF_MINTERM,d3 	; BLTCON0 value
	move.w 	#FONTMAP_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTBMOD(a6)	; B modulo
	move.w 	#_BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w 	#_BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
	move.w	#$0000,BLTALWM(a6) 					; mask out extra word used for shifting
	move.w	#$ffff,BLTADAT(a6) 					; preload source mask so only BLTA?WM mask is used

	move.l	#font,a5						; font pointer
	move.l	a0,a2							; bitplane pointer
        mulu.w	#_BITPLANE_WIDTH_BYTES*_SCREEN_BIT_DEPTH,d1		; d1 = ypos bytes	
	adda.w	d1,a2							; dest += YPOS_BYTES	
 	move.w	d0,d1							; xpos
	lsr.w	#3,d1							; d2 = xpos bytes
	adda.w 	d1,a2							; dest += XPOS_BYTES
	
.loop:
	moveq	#0,d1
	move.b	(a1)+,d1				; get next character
	cmp.b	#0,d1					; 0 terminates the string
	beq	.done					; finished!
	lsl.w	#2,d1					; font atlas index = char * 4		
 	move.l	d0,d2					; xpos
	
	WaitBlitter
	
	btst	#2,d1					; check if odd or even char
	beq	.evenChar				;
.oddChar
	subq	#8,d2					; offset the x position for the odd character
	move.w	#$00FF,BLTAFWM(a6)			; select the second (odd) character in the word
	subq	#1,a2					; move the destination pointer left by one byte
	move.l 	a2,BLTCPTH(a6) 				; background top left corner
	move.l 	a2,BLTDPTH(a6) 				; destination top left corner
	addq	#1,a2
	bra	.continue
.evenChar:
	move.w	#$FF00,BLTAFWM(a6)			; select the first character in the word
	move.l 	a2,BLTCPTH(a6) 				; background top left corner
	move.l 	a2,BLTDPTH(a6) 				; destination top left corner	
.continue:

	;; this shift will give us the bits to shift (bits 0-3) in bits (12-15) of d2
	swap	d2					; d2 << 12
	lsr.l	#4,d2					;

	move.w	d2,BLTCON1(A6)				; set the shift bits 12-15, bits 00-11 cleared
	move.l 	fontAtlas(pc,d1.w),BLTBPTH(a6)		; source bitplane		
	or.w	d3,d2					; d2 = BLTCON0 value
	move.w	d2,BLTCON0(a6)				; set minterm, dma channel and shift
	move.w 	#(FONT_HEIGHT*_SCREEN_BIT_DEPTH)<<6|(BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit	

	add.l	#FONT_WIDTH,d0	; increment the x position
	addq	#1,a2		; increment the dest buffer pointer
	bra	.loop
.done:
	movem.l	(sp)+,d0-d3/a1-a2
	rts


CharAddress:	macro
	dc.l	font+(((\1)/FONTMAP_WIDTH_BYTES)*(FONT_HEIGHT*FONTMAP_WIDTH_BYTES*_SCREEN_BIT_DEPTH))+((\1)-(((\1)/FONTMAP_WIDTH_BYTES)*FONTMAP_WIDTH_BYTES))
	endm


fontAtlas:
	CharAddress    0
	CharAddress    1
	CharAddress    2
	CharAddress    3
	CharAddress    4
	CharAddress    5
	CharAddress    6
	CharAddress    7
	CharAddress    8
	CharAddress    9
	CharAddress    10
	CharAddress    11
	CharAddress    12
	CharAddress    13
	CharAddress    14
	CharAddress    15
	CharAddress    16
	CharAddress    17
	CharAddress    18
	CharAddress    19
	CharAddress    20
	CharAddress    21
	CharAddress    22
	CharAddress    23
	CharAddress    24
	CharAddress    25
	CharAddress    26
	CharAddress    27
	CharAddress    28
	CharAddress    29
	CharAddress    30
	CharAddress    31
	CharAddress    32
	CharAddress    33
	CharAddress    34
	CharAddress    35
	CharAddress    36
	CharAddress    37
	CharAddress    38
	CharAddress    39
	CharAddress    40
	CharAddress    41
	CharAddress    42
	CharAddress    43
	CharAddress    44
	CharAddress    45
	CharAddress    46
	CharAddress    47
	CharAddress    48
	CharAddress    49
	CharAddress    50
	CharAddress    51
	CharAddress    52
	CharAddress    53
	CharAddress    54
	CharAddress    55
	CharAddress    56
	CharAddress    57
	CharAddress    58
	CharAddress    59
	CharAddress    60
	CharAddress    61
	CharAddress    62
	CharAddress    63
	CharAddress    64
	CharAddress    65
	CharAddress    66
	CharAddress    67
	CharAddress    68
	CharAddress    69
	CharAddress    70
	CharAddress    71
	CharAddress    72
	CharAddress    73
	CharAddress    74
	CharAddress    75
	CharAddress    76
	CharAddress    77
	CharAddress    78
	CharAddress    79
	CharAddress    80
	CharAddress    81
	CharAddress    82
	CharAddress    83
	CharAddress    84
	CharAddress    85
	CharAddress    86
	CharAddress    87
	CharAddress    88
	CharAddress    89
	CharAddress    90
	CharAddress    91
	CharAddress    92
	CharAddress    93
	CharAddress    94
	CharAddress    95
	CharAddress    96
	CharAddress    97
	CharAddress    98
	CharAddress    99
	CharAddress    100
	CharAddress    101
	CharAddress    102
	CharAddress    103
	CharAddress    104
	CharAddress    105
	CharAddress    106
	CharAddress    107
	CharAddress    108
	CharAddress    109
	CharAddress    110
	CharAddress    111
	CharAddress    112
	CharAddress    113
	CharAddress    114
	CharAddress    115
	CharAddress    116
	CharAddress    117
	CharAddress    118
	CharAddress    119
	CharAddress    120
	CharAddress    121
	CharAddress    122
	CharAddress    123
	CharAddress    124
	CharAddress    125
	CharAddress    126
	CharAddress    127

font:	
	incbin	"out/font8x8.bin"
	

