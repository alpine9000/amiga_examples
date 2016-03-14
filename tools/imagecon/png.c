/*
 * Orginal copyright from libpng example code
 *
 * Copyright 2002-2011 Guillaume Cottenceau and contributors.
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */


#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <png.h>

#include "imagecon.h"

static void
_wrapjmp(png_structp png_ptr)
{
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("Error during init_io");
}

static inline void 
setRGB(png_byte *ptr, amiga_color_t color)
{
  *ptr++ = color.r;
  *ptr++ = color.g;
  *ptr++ = color.b;
}

void
png_read(imagecon_image_t* ic, char* filename)
{
  png_structp png_ptr; 
  png_byte color_type;
  png_byte bit_depth; 
  png_infop info_ptr;
  int number_of_passes = 0, rowbytes;
  unsigned char header[8];    // 8 is the maximum size that can be checked
  
  /* open file and test for it being a png */
  FILE *fp = fopen(filename, "rb");
  if (!fp)
    abort_("Failed to open %s", filename);
  fread(header, 1, 8, fp);
  if (png_sig_cmp(header, 0, 8))
    abort_("File %s is not recognized as a PNG file", filename);

  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);  

  if (!png_ptr)
    abort_("png_create_read_struct failed");
  
  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr)
    abort_("png_create_info_struct failed");
  
 
  _wrapjmp(png_ptr);
  png_init_io(png_ptr, fp);
  png_set_sig_bytes(png_ptr, 8);
  
  png_read_info(png_ptr, info_ptr);
  
  ic->width = png_get_image_width(png_ptr, info_ptr);
  ic->height = png_get_image_height(png_ptr, info_ptr);
  color_type = png_get_color_type(png_ptr, info_ptr);
  bit_depth = png_get_bit_depth(png_ptr, info_ptr);

  if (config.verbose) {
    printf("width = %d\n", ic->width);
    printf("height = %d\n", ic->height);
    printf("color_type = %d (palette = %s)\n", color_type, color_type == PNG_COLOR_TYPE_PALETTE ? "yes" : "no");
    printf("bit_depth = %d\n", bit_depth);
    printf("number_of_passes = %d\n", number_of_passes);
  }
  
  if (color_type == PNG_COLOR_TYPE_PALETTE)
    png_set_palette_to_rgb(png_ptr);

  if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8) 
    png_set_expand_gray_1_2_4_to_8(png_ptr);

  if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS)) 
    png_set_tRNS_to_alpha(png_ptr);

  if (color_type == PNG_COLOR_TYPE_RGB ||
      color_type == PNG_COLOR_TYPE_GRAY || 
      color_type == PNG_COLOR_TYPE_PALETTE)
    png_set_add_alpha(png_ptr, 0xFF, PNG_FILLER_AFTER);
  
  if (bit_depth == 16)
    png_set_strip_16(png_ptr);  

  number_of_passes = png_set_interlace_handling(png_ptr);

  png_read_update_info(png_ptr, info_ptr);  
  ic->width = png_get_image_width(png_ptr, info_ptr);
  ic->height = png_get_image_height(png_ptr, info_ptr);
  color_type = png_get_color_type(png_ptr, info_ptr);
  bit_depth = png_get_bit_depth(png_ptr, info_ptr);

  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("Error during read_image");
  
  ic->rowPointers = (png_bytep*) malloc(sizeof(png_bytep) * ic->height);
  
  /*
  if (bit_depth == 16)
    rowbytes = ic->width*8;
    else */
    rowbytes = ic->width*4;
 

  for (int y=0; y< ic->height; y++)
    ic->rowPointers[y] = (png_byte*) malloc(rowbytes);
  
  png_read_image(png_ptr, ic->rowPointers);
  
  fclose(fp);

  if (config.verbose) {
    printf("width = %d\n", ic->width);
    printf("height = %d\n", ic->height);
    printf("color_type = %d (palette = %s)\n", color_type, color_type == PNG_COLOR_TYPE_PALETTE ? "yes" : "no");
    printf("bit_depth = %d\n", bit_depth);
    printf("number_of_passes = %d\n", number_of_passes);
  }

  ic->amigaImage = calloc(ic->width*ic->height, 1);
  ic->dithered = 0;
}


void
png_write(imagecon_image_t* ic, char* filename)
{
  FILE *fp = file_openWrite(filename);
  png_structp png_ptr = NULL;
  png_infop info_ptr = NULL;
  png_bytep row = NULL;

  png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

  if (png_ptr == NULL) {
    abort_("png_write: could not allocate write struct");
  }

  info_ptr = png_create_info_struct(png_ptr);
  if (info_ptr == NULL) {
    abort_("png_write: could not allocate info struct");
  }

  if (setjmp(png_jmpbuf(png_ptr))) {
    abort_("png_write: error during png creation");
  }

  png_init_io(png_ptr, fp);

  // Write header (8 bit colour depth)
  png_set_IHDR(png_ptr, info_ptr, ic->width, ic->height,
	       8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
	       PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);

  // Set title
  if (filename != NULL) {
    png_text title_text;
    title_text.compression = PNG_TEXT_COMPRESSION_NONE;
    title_text.key = "Title";
    title_text.text = filename;
    png_set_text(png_ptr, info_ptr, &title_text, 1);
  }

  png_write_info(png_ptr, info_ptr);

  // Allocate memory for one row (3 bytes per pixel - RGB)
  row = (png_bytep) malloc(3 * ic->width * sizeof(png_byte));

  // Write image data
  int x, y;
  for (y=0 ; y<ic->height ; y++) {
    for (x=0 ; x<ic->width ; x++) {
      setRGB(&(row[x*3]), color_getPalettedPixel(ic, x, y));
    }
    png_write_row(png_ptr, row);
  }

  // End write
  png_write_end(png_ptr, NULL);

  if (info_ptr != NULL) png_free_data(png_ptr, info_ptr, PNG_FREE_ALL, -1);
  if (png_ptr != NULL) png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
  if (row != NULL) free(row);
}
