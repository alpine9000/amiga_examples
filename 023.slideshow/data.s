	include "includes.i"

	xdef	imageLookupTable
	xdef 	compressedModule
	xdef 	endCompressedModule

InstallColorPalette:
	include "out/image1-palette.s"
	rts	
InstallColorPalette2:
	include "out/image2-palette.s"
	rts
InstallColorPalette3:
	include "out/image3-palette.s"
	rts
InstallColorPalette4:
	include "out/image4-palette.s"
	rts
InstallColorPalette5:
	include "out/image5-palette.s"
	rts
InstallColorPalette6:
	include "out/image6-palette.s"
	rts
InstallColorPalette7:
	include "out/image7-palette.s"
	rts
	if INTERLACE==0
InstallColorPalette8:
	include "out/image8-palette.s"
	rts
	endif; INTERLACE==0
	
	
	
imageLookupTable:				; configure slideshow here
	dc.l	InstallColorPalette 		; palette installation routine
	dc.l	imageData1			; compressed image data
	dc.l	endImageData1-imageData1	; compressed image data size
	
	dc.l	InstallColorPalette2
	dc.l	imageData2
	dc.l	endImageData2-imageData2

	dc.l	InstallColorPalette3
	dc.l	imageData3
	dc.l	endImageData3-imageData3	

	dc.l	InstallColorPalette4
	dc.l	imageData4
	dc.l	endImageData4-imageData4		

	dc.l	InstallColorPalette5
	dc.l	imageData5
	dc.l	endImageData5-imageData5			

	dc.l	InstallColorPalette6
	dc.l	imageData6
	dc.l	endImageData6-imageData6				


	dc.l	InstallColorPalette7
	dc.l	imageData7
	dc.l	endImageData7-imageData7

	if	INTERLACE==0
	dc.l	InstallColorPalette8
	dc.l	imageData8
	dc.l	endImageData8-imageData8
	endif; INTERLACE==0
	dc.l	0		; terminate list
	
	
	section .noload		; data in this section will not be loaded by the bootloader
	cnop	0,512		; each image must be aligned to a sector boundary
imageData1:			; because I am too lazy to read non aligned data
	if HAM_MODE==1
	incbin	"out/image1-ham.lz"
	else
	incbin	"out/image1.lz"
	endif
endImageData1:	
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData2:			; because I am too lazy to read non aligned data
	if HAM_MODE==1
	incbin	"out/image2-ham.lz"
	else
	incbin	"out/image2.lz"
	endif
endImageData2:		

	cnop	0,512		; each image must be aligned to a sector boundary
imageData3:
	if HAM_MODE==1
	incbin	"out/image3-ham.lz"
	else
	incbin	"out/image3.lz"
	endif
endImageData3:
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData4:	
	if HAM_MODE==1
	incbin	"out/image4-ham.lz"
	else
	incbin	"out/image4.lz"
	endif
endImageData4:	
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData5:
	if HAM_MODE==1
	incbin	"out/image5-ham.lz"
	else
	incbin	"out/image5.lz"
	endif
endImageData5:	
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData6:	
	if HAM_MODE==1
	incbin	"out/image6-ham.lz"
	else
	incbin	"out/image6.lz"
	endif
endImageData6:

	cnop	0,512		; each image must be aligned to a sector boundary
imageData7:	
	if HAM_MODE==1
	incbin	"out/image7-ham.lz"
	else
	incbin	"out/image7.lz"
	endif
endImageData7:

	if INTERLACE==0
	cnop	0,512		; each image must be aligned to a sector boundary
imageData8:	
	if HAM_MODE==1
	incbin	"out/image8-ham.lz"
	else
	incbin	"out/image8.lz"
	endif
endImageData8:
	endif; INTERLACE==0

	cnop	0,512
compressedModule:
	incbin "out/P61.breath_of_life.lz"
endCompressedModule:
