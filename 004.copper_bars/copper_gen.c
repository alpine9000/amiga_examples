// http://krazydad.com/tutorials/makecolors.php

#include <stdio.h>
#include <math.h>

int 
main(int argc, char** argv)
{
  char* hpos = "07";
  int   firstVisibleScanLine = 0x2c; // hard coded value from AHRM
  float numLines = 312; // PAL only

  float frequencyr = 0.3, frequencyg = 0.3, frequencyb = 0.3;
  float phase1 = 0, phase2 = 2, phase3 = 4;
  float center = 0x7;
  float width = 0x7;

  for (int i = 0, line = firstVisibleScanLine; i < (numLines-firstVisibleScanLine); ++i, ++line) {
    unsigned char r = (sin(frequencyr*i + phase1) * width + center) + 0.5;
    unsigned char g = (sin(frequencyg*i + phase2) * width + center) + 0.5;
    unsigned char b = (sin(frequencyb*i + phase3) * width + center) + 0.5;
    if (line <= 255) {
      printf("\tdc.w $%x%s,$fffe\n\tdc.w COLOR00,$%x%x%x\n",line, hpos, r, g, b);
      if (0x2c+i == 255) {
	printf(".greaterThan255Hack:\n");
	printf("\tdc.w $%xdf,$fffe\n",line);
      }
    } else {
      printf("\tdc.w $%x%s,$fffe\n\tdc.w COLOR00,$%x%x%x\n", line-256, hpos,r, g, b);
    }
  }

  return 0;
}
