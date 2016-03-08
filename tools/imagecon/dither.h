#pragma once

amiga_color_t
dither_getPalettedColor(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last);

amiga_color_t
dither_getHamColor(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last);

void
dither_image(imagecon_image_t* ic, amiga_color_t (*selector)(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last));

void
dither_transferToPaletted(imagecon_image_t* ic);

ham_control_t* 
dither_createHams(imagecon_image_t* ic);
