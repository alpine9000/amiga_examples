#include "imagecon.h"


int
color_delta(amiga_color_t c1, amiga_color_t c2)
{
  int dr = abs((c1.r)-(c2.r));
  int dg = abs((c1.g)-(c2.g));
  int db = abs((c1.b)-(c2.b));
  
  enum  {
    DISTANCE,
    WEIGHTED,
    SIMPLE
  } errorFunc = WEIGHTED;
  
  switch (errorFunc) {
  case SIMPLE:
    return dr+dg+db;
  case DISTANCE:
    return sqrt((dr*dr)+(dg*dg)+(db*db));
  case WEIGHTED:
  default:
    return dr*3+dg*4+db*2;
  }
}


void
color_print(amiga_color_t color)
{
  printf("R = %03d  G = %03d  B = %03d A = %03d", color.r, color.g, color.b, color.a);
}


int
color_findClosestPaletteIndex(imagecon_image_t* ic, amiga_color_t color)
{
  int delta = INT_MAX;
  int index = 0;

  for (int i = 0; i < ic->numColors; i++) {
    int dc = color_delta(color, ic->palette[i]);
    if (dc < delta) {
      delta = dc;
      index = i;
    }
  }
  return index;
}

amiga_color_t
color_findClosestPalettePixel(imagecon_image_t* ic, amiga_color_t color)
{
  return ic->palette[color_findClosestPaletteIndex(ic, color)];
}



amiga_color_t
color_getOriginalPixel(imagecon_image_t* ic, int x, int y)
{
  png_byte* ptr = ic->rowPointers[y] + (x*4);
  amiga_color_t color;
  color.r = ptr[0];
  color.g = ptr[1];
  color.b = ptr[2];
  color.a = ptr[3];
  return color;
}


void
color_setOriginalPixel(imagecon_image_t* ic, int x, int y, amiga_color_t color)
{
  png_byte* ptr = ic->rowPointers[y] + (x*4);
  ptr[0] = color.r;
  ptr[1] = color.g;
  ptr[2] = color.b;
  ptr[3] = color.a;
}


dither_color_t
color_getDitheredPixel(imagecon_image_t* ic, int x, int y)
{
  return ic->dithered[(y*ic->width)+x];
}

void
color_setDitheredPixel(imagecon_image_t* ic, int x, int y, dither_color_t color)
{
  dither_color_t *d = &ic->dithered[(y*ic->width)+x];

  d->r = COLOR8(color.r);
  d->g = COLOR8(color.g);
  d->b = COLOR8(color.b);
  d->a = COLOR8(color.a);
}

amiga_color_t
color_getPalettedPixel(imagecon_image_t* ic, int x, int y)
{
  int paletteIndex = ic->amigaImage[(ic->width*y)+x];
  amiga_color_t color;
  color.r = ic->palette[paletteIndex].r;
  color.g = ic->palette[paletteIndex].g;
  color.b = ic->palette[paletteIndex].b;
  color.a = ic->palette[paletteIndex].a;
  return color;
}

void
color_setPalettedPixel(imagecon_image_t* ic, int x, int y, amiga_color_t color)
{
  int paletteIndex = color_findClosestPaletteIndex(ic, color);
  ic->amigaImage[(ic->width*y)+x] = paletteIndex;
}


void
color_transferPalettedToOriginal(imagecon_image_t* ic)
{
  for (int y = 0; y < ic->height; y++) {
    for (int x = 0; x < ic->width; x++) {
      color_setOriginalPixel(ic, x, y, color_getPalettedPixel(ic, x, y));
    }
  }
}


amiga_color_t
color_ditheredToAmiga(dither_color_t color)
{
  amiga_color_t c;
  c.r = color.r;
  c.g = color.g;
  c.b = color.b;
  c.a = color.a;

  return c;
}


dither_color_t
color_amigaToDithered(amiga_color_t color)
{
  dither_color_t c;
  c.r = color.r;
  c.g = color.g;
  c.b = color.b;
  c.a = color.a;
  return c;
}
