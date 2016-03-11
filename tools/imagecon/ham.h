#pragma once

ham_control_t
ham_findClosestPixel(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last);

void
ham_process(imagecon_image_t* ic, char* outFilename);


void
sham_process(imagecon_image_t* ic, char* outFilename);
