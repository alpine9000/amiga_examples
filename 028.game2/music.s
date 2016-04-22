	xdef 	StartMusic
	
StartMusic:
	lea     module,a0
        sub.l   a1,a1
        sub.l   a2,a2
        moveq   #0,d0
        jsr     P61_Init
	rts
	
module:
	incbin	"assets/P61.placeholder"