// http://krazydad.com/tutorials/makecolors.php

#include <stdio.h>
#include <math.h>

typedef struct {
  float r;
  float g;
  float b;
} color;

#define numColors  50
color colors[numColors];

void
makeColorGradient()
{
  float frequencyr = 02;
  float frequencyg = 02;
  float frequencyb = 02;
  float phase1 = 0.1, phase2 = 0.1, phase3 = 0.1;
  float center = 0x7;
  float width = 0x7;
  float len = numColors;

  for (int i = 0; i < len; ++i) {
    color* c = &colors[i];
    c->r = sin(frequencyr*i + phase1) * width + center;
    c->g = sin(frequencyg*i + phase2) * width + center;
    c->b = sin(frequencyb*i + phase3) * width + center;
  }
}

int 
main()
{
  makeColorGradient();

  int lines = 312;
  color start = { 0x0, 0x0, 0x0};
  color end = { 0xF, 0xF, 0xF};
  color current = {0};
  int count = lines-0x2c;
  int from = 0, to = 1;
  int segment = count/((sizeof(colors)/sizeof(color))-1);
  
  for (int i = 0, y = 0; i < count; i++) {
    if (i != 0 && i % segment == 0) {
      from++;
      to++;
    }

    float distance = (float)((i)%segment)/segment;
    color* start = &colors[from];
    color* end = &colors[to];
    current.r = start->r + ((end->r-start->r)*distance);
    current.g = start->g + ((end->g-start->g)*distance);
    current.b = start->b + ((end->b-start->b)*distance);

    if (0x2c+i <= 255) {
      printf("\tdc.w $%xdf,$fffe\n\tdc.w COLOR00,$%x%x%x\n",0x2c+i, (int)(current.r+0.5), (int)(current.g+0.5), (int)(current.b+0.5));
    } else {
      printf("\tdc.w $%xdf,$fffe\n\tdc.w COLOR00,$%x%x%x\n",y++, (int)(current.r+0.5), (int)(current.g+0.5), (int)(current.b+0.5));
    }

  }

  return 0;
}
