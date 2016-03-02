#include "hardware/custom.h"
#include "hardware/dmabits.h"

/*
Scrollit:
;;    ---  scroll!  ---
bltoffs =plotY*ScrBpl*3

blth    =20
bltw    =w/16
	bltskip =0                              ;modulo
brcorner=blth*ScrBpl*3-2

						   movem.l d0-a6,-(sp)
						   lea $dff000,a6
        bsr BlitWait

						   move.l #$49f00002,BLTCON0(a6)
						   move.l #$ffffffff,BLTAFWM(a6)
						   move.l #Screen+bltoffs+brcorner,BLTAPTH(a6)
						   move.l #Screen+bltoffs+brcorner,BLTDPTH(a6)
						   move.w #bltskip,BLTAMOD(a6)
						   move.w #bltskip,BLTDMOD(a6)

						   move.w #blth*3*64+bltw,BLTSIZE(a6)
						   movem.l (sp)+,d0-a6
        rts
*/



extern void blitwait(void);

void bitblit(unsigned* src, unsigned* dest, unsigned sw, unsigned dw, unsigned dx, unsigned dy)
{
  static struct Custom *custom = (struct Custom *)0xDFF000;

  custom->dmacon = (DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER);
	  /*
  blitwait();
  custom->bltcon0 = 0x49f00002;
  custom->bltafwm = 0xffffffff;*/
}
