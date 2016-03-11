#pragma once

typedef struct {
  int w, h;
  unsigned char *pix;
} quant_image_t;

void 
quant_quantize(quant_image_t* im, int n_colors, int dither);

quant_image_t* 
quant_newImage(int w, int h);
