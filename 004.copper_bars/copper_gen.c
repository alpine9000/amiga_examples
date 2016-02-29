#include <stdio.h>
#include <math.h>

int 
main(int argc, char** argv)
{
  // Change these values to generate different patterns in the copper list
  // http://krazydad.com/tutorials/makecolors.php
  float frequencyr = 0.3, frequencyg = 0.3, frequencyb = 0.3;
  float basePhase = 0;
  float phase1 = basePhase + 0, phase2 = basePhase + 1, phase3 = basePhase + 2;
  float center = 0x7;
  float width = 0x7;

  // These values are set up for a standard low-res PAL 320x256 playfield
  int startLine = 0x2c;   // hard coded value from AHRM
  int screenHeight = 256;
  int endLine = startLine+screenHeight;
  int startHpos = 6;
  int i, line;

  for (i = 0, line = startLine; line < endLine; ++i, ++line) {
    unsigned char r = (sin(frequencyr*i + phase1) * width + center) + 0.5;
    unsigned char g = (sin(frequencyg*i + phase2) * width + center) + 0.5;
    unsigned char b = (sin(frequencyb*i + phase3) * width + center) + 0.5;
    if (line <= 255) {
      printf("\tdc.w $%x,$fffe\n\tdc.w COLOR00,$%x%x%x\n",line<<8|startHpos|1, r, g, b);
      if (line == 255) {
	printf(".verticalPositionWrapped:\n");
	printf("\tdc.w $%xdf,$fffe\n",line);
      }
    } else {
      printf("\tdc.w $%x,$fffe\n\tdc.w COLOR00,$%x%x%x\n", (line-256)<<8|startHpos|1, r, g, b);
    }
  }

  printf("\tdc.w $%x,$fffe\n\tdc.w COLOR00,$%x%x%x\n", (line-256)<<8|startHpos|1, 0, 0, 0);

  return 0;
}
