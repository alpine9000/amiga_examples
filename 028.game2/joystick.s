	;; http://eab.abime.net/showpost.php?p=986196&postcount=2

	xdef ReadJoystick
	
ciaa_pra  = $bfe001
joy1dat   = $dff00c
potgor    = $dff016
bit_joyb1 = 7
bit_joyb2 = 14

ReadJoystick:
	;; d0 - returns the state of the buttons in bits 8 and 9, and the lower byte holds the direction of the stick:
	btst    #bit_joyb2&7,potgor
        seq     d0
	add.w   d0,d0
	btst    #bit_joyb1,ciaa_pra
        seq     d0
	add.w   d0,d0
	move.w  joy1dat,d1
	ror.b   #2,d1
	lsr.w   #6,d1
	and.w   #%1111,d1
	move.b	(.conv,pc,d1.w),d0
	move.w	d0,joystick
        rts
.conv:
        dc.b      0,5,4,3,1,0,3,2,8,7,0,1,7,6,5,0