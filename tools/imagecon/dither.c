#include "imagecon.h"

static void
_dither_createDither(imagecon_image_t* ic);

amiga_color_t
dither_getPalettedColor(dither_data_t data)
{
  return color_findClosestPalettePixel(data.ic, data.color);
}


float
_gamma(float x)
{
  //return x * 1.0;
  return x * 0.55;
}


static void
_propagateError(imagecon_image_t* ic, float factor, int x, int y, dither_color_t error)
{
  if (x >= 0 && y >= 0 && x < ic->width && y < ic->height) {
    dither_color_t color = color_getDitheredPixel(ic, x, y);
    color.r += _gamma(error.r * factor);
    color.g += _gamma(error.g * factor);
    color.b += _gamma(error.b * factor);    
    color_setDitheredPixel(ic, x, y, color);
  }
}


void
dither_image(imagecon_image_t* ic, amiga_color_t (*selector)(dither_data_t data))
{
  _dither_createDither(ic);

  dither_data_t data;
  for (int y = 0; y < ic->height; y++) {
    amiga_color_t last = {-1, -1, -1, -1};
    for (int x = 0; x < ic->width; x++) {

      dither_color_t old = color_getDitheredPixel(ic, x, y);
      data.color = color_ditheredToAmiga(old);
      data.last = last;
      data.x = x;
      data.y = y;
      data.ic = ic;
      amiga_color_t new = selector(data);

      dither_color_t error;
      float gamma = 1.0;
      error.r = CLAMP(old.r - (new.r*gamma));
      error.g = CLAMP(old.g - (new.g*gamma));
      error.b = CLAMP(old.b - (new.b*gamma));

      color_setDitheredPixel(ic, x, y, color_amigaToDithered(new));
      last = new;

      _propagateError(ic, 7.0/16.0, x+1, y,   error);
      _propagateError(ic, 3.0/16.0, x-1, y+1, error);
      _propagateError(ic, 5.0/16.0, x  , y+1, error);
      _propagateError(ic, 1.0/16.0, x+1, y+1, error);     
    }
  }
}


void
dither_transferToPaletted(imagecon_image_t* ic)
{
  for (int y = 0; y < ic->height; y++) {
    for (int x = 0; x < ic->width; x++) {
      color_setPalettedPixel(ic, x, y, color_ditheredToAmiga(color_getDitheredPixel(ic, x, y)));
    }
  }
}



static void
_dither_createDither(imagecon_image_t* ic)
{
  ic->dithered = malloc(sizeof(dither_color_t)*ic->width*ic->height);
  
  for (int y = 0; y < ic->height; y++) {
    for (int x = 0; x < ic->width; x++) {
      color_setDitheredPixel(ic, x, y, color_amigaToDithered(color_getOriginalPixel(ic, x, y)));
    }
  }
}
