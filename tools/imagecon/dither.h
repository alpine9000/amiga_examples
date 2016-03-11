#pragma once

typedef struct {
  imagecon_image_t* ic;
  amiga_color_t color;
  amiga_color_t last;
  int x;
  int y;
} dither_data_t;


amiga_color_t
dither_getPalettedColor(dither_data_t data);

void
dither_image(imagecon_image_t* ic, amiga_color_t (*selector)(dither_data_t data));

void
dither_transferToPaletted(imagecon_image_t* ic);

ham_control_t* 
dither_createHams(imagecon_image_t* ic);
