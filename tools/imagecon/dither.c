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

void
dither_image(imagecon_image_t* ic, amiga_color_t (*selector)(imagecon_image_t*, amiga_color_t color, amiga_color_t last))
{
  _dither_createDither(ic);
  
  for (int y = 0; y < ic->height; y++) {
    amiga_color_t last = {-1, -1, -1, -1};
    for (int x = 0; x < ic->width; x++) {

      amiga_color_t old = color_getDitheredPixel(ic, x, y);
      amiga_color_t new = selector(ic, old, last);

      amiga_color_t error;
      error.r = old.r - new.r;
      error.g = old.g - new.g;
      error.b = old.b - new.b;

      color_setDitheredPixel(ic, x, y, new);
      last = new;

      amiga_color_t color;
      float factor;
      
      if (x+1 < ic->width) {
	color = color_getDitheredPixel(ic, x+1, y); 
	factor = 7.0/16.0;
	color.r = color.r + ((float)error.r * factor);
	color.g = color.g + ((float)error.g * factor);
	color.b = color.b + ((float)error.b * factor);
	color_setDitheredPixel(ic, x+1, y, color);
      }

      if (x > 0 && y+1 < ic->height) {
	color = color_getDitheredPixel(ic, x-1, y+1);
	factor = 3.0/16.0;
	color.r = color.r + ((float)error.r * factor);
	color.g = color.g + ((float)error.g * factor);
	color.b = color.b + ((float)error.b * factor);
	color_setDitheredPixel(ic, x-1, y+1, color);
      }

      if (y+1 < ic->height) {
	color = color_getDitheredPixel(ic, x, y+1); 
	factor = 5.0/16.0;
	color.r = color.r + ((float)error.r * factor);
	color.g = color.g + ((float)error.g * factor);
	color.b = color.b + ((float)error.b * factor);
	color_setDitheredPixel(ic, x, y+1, color);
	
	if (x+1 < ic->width) {
	  color = color_getDitheredPixel(ic, x+1, y+1); 
	  factor = 1.0/16.0;
	  color.r = color.r + ((float)error.r * factor);
	  color.g = color.g + ((float)error.g * factor);
	  color.b = color.b + ((float)error.b * factor);
	  color_setDitheredPixel(ic, x+1, y+1, color);
	}
      }
    }

  }

}


void
dither_transferToPaletted(imagecon_image_t* ic)
{
  for (int y = 0; y < ic->height; y++) {
    for (int x = 0; x < ic->width; x++) {
      color_setPalettedPixel(ic, x, y, color_getDitheredPixel(ic, x, y));
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
      amiga_color_t orig = color_getDitheredPixel(ic, x, y);
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
  ic->dithered = malloc(sizeof(amiga_color_t)*ic->width*ic->height);
  
  for (int y = 0; y < ic->height; y++) {
    for (int x = 0; x < ic->width; x++) {
      color_setDitheredPixel(ic, x, y, color_getOriginalPixel(ic, x, y));
    }
  }
}
