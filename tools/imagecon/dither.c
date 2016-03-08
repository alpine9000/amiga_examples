#include "imagecon.h"

static void
_dither_createDither(imagecon_image_t* ic);

amiga_color_t
dither_getPalettedColor(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last)
{
  return color_findClosestPalettePixel(ic, color);
}


amiga_color_t
dither_getHamColor(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last)
{
  ham_control_t ham = color_findClosestHamPixel(ic, color, last);
  return ham.pixel;
}

float
_gamma(float x)
{
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
dither_image(imagecon_image_t* ic, amiga_color_t (*selector)(imagecon_image_t*, amiga_color_t color, amiga_color_t last))
{
  _dither_createDither(ic);
  
  for (int y = 0; y < ic->height; y++) {
    amiga_color_t last = {-1, -1, -1, -1};
    for (int x = 0; x < ic->width; x++) {

      dither_color_t old = color_getDitheredPixel(ic, x, y);
      amiga_color_t new = selector(ic, color_ditheredToAmiga(old), last);

      dither_color_t error;
      error.r = old.r - new.r;
      error.g = old.g - new.g;
      error.b = old.b - new.b;

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


ham_control_t* 
dither_createHams(imagecon_image_t* ic)
{
  ham_control_t* hams = malloc(sizeof(ham_control_t)*ic->width*ic->height);

  for (int y = 0; y < ic->height; y++) {
    amiga_color_t lastPixel = { -1, -1, -1, -1};
    for (int x = 0; x < ic->width; x++) {
      amiga_color_t orig = color_ditheredToAmiga(color_getDitheredPixel(ic, x, y));
      ham_control_t ham = color_findClosestHamPixel(ic, orig, lastPixel);
      lastPixel = ham.pixel;
      hams[(y*ic->width)+x] = ham;
    }
  }

  return hams;
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
