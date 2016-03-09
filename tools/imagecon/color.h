#pragma once

int
color_delta(amiga_color_t c1, amiga_color_t c2);

void
color_print(amiga_color_t color);

amiga_color_t
color_findClosestPalettePixel(imagecon_image_t* ic, amiga_color_t color);

int
color_findClosestPaletteIndex(imagecon_image_t* ic, amiga_color_t color);

amiga_color_t
color_getPalettedPixel(imagecon_image_t* ic, int x, int y);

void
color_setPalettedPixel(imagecon_image_t* ic, int x, int y, amiga_color_t color);

void
color_setDitheredPixel(imagecon_image_t* ic, int x, int y, dither_color_t color);

dither_color_t
color_getDitheredPixel(imagecon_image_t* ic, int x, int y);

amiga_color_t
color_getOriginalPixel(imagecon_image_t* ic, int x, int y);

void
color_setOriginalPixel(imagecon_image_t* ic, int x, int y, amiga_color_t color);

void
color_transferPalettedToOriginal(imagecon_image_t* ic);

amiga_color_t
color_ditheredToAmiga(dither_color_t color);

dither_color_t
color_amigaToDithered(amiga_color_t color);
