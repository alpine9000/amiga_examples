// http://krazydad.com/tutorials/makecolors.php

#include <stdio.h>
#include <math.h>

int 
main(int argc, char** argv)
{
  int startLine = 0x2c;   // hard coded value from AHRM
  int screenHeight = 256;
  int endLine = startLine+screenHeight;
  int startHpos = 6+8;
  int i, c, line;

  // These values are set up to be in sync with the vertical bars
  float frequencyr = 0.3, frequencyg = 0.3, frequencyb = 0.3;
  float phase1 = 0, phase2 = 2, phase3 = 4;
  float offset = 0;
  float center = 0x7;
  float width = 0x7;
  int hstep = 16;

  for (line = startLine; line < endLine; ++line) {
    for (i = 0, c = startHpos; c < 0xdf; c+= hstep, i++) {
      unsigned char r = (sin(frequencyr*i + phase1 + offset) * width + center) + 0.5;
      unsigned char g = (sin(frequencyg*i + phase2 + offset) * width + center) + 0.5;
      unsigned char b = (sin(frequencyb*i + phase3 + offset) * width + center) + 0.5;
      if (line == 0 && i == 0) {

      } else {
	if (line <= 255) {
	  printf("\tdc.w $%x,$fffe\n\tdc.w COLOR00,$%x%x%x\n",line<<8|c|1, r, g, b);
	  if (line == 255 && c+hstep >= 0xdf) {
	    printf(".verticalPositionWrapped:\n");
	  }
	} else {
	  printf("\tdc.w $%x,$fffe\n\tdc.w COLOR00,$%x%x%x\n", (line-256)<<8|c|1, r, g, b);
	}
      }
    }
  }

  return 0;
}
