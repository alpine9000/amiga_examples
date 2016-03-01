/*
 * Copyright 2002-2011 Guillaume Cottenceau and contributors.
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>

#define PNG_DEBUG 3
#include <png.h>

void 
abort_(const char * s, ...)
{
  va_list args;
  va_start(args, s);
  vfprintf(stderr, s, args);
  fprintf(stderr, "\n");
  va_end(args);
  abort();
}

//int x, y;
int width, height, rowbytes;
png_byte color_type;
png_byte bit_depth;
png_structp png_ptr;
png_infop info_ptr;
int number_of_passes;
png_bytep * row_pointers;



typedef struct {
    unsigned char r;
    unsigned char g;
    unsigned char b;
} amiga_color_t;

#define MAX_PALETTE 16
int blah[MAX_PALETTE] = {0xfff, 0xd12, 0x744, 0xe20, 0x362, 0x06a, 0x0b0, 0x1ae, 0x2b5, 0xf92, 0xe9a, 0xfa7, 0x9dc, 0xddd , 0xfe0 , 0xee9};
amiga_color_t palette[MAX_PALETTE];
int paletteIndex = 0;
unsigned* amigaImage = 0;

void read_png_file(char* file_name)
{

  /*  for (int i = 0; i < MAX_PALETTE; i++) {
    palette[i].r = blah[i] >> 8 & 0xf;
    palette[i].g = blah[i] >> 4 & 0xf;
    palette[i].b = blah[i] & 0xf;
  }
  paletteIndex = 16;
  */
  unsigned char header[8];    // 8 is the maximum size that can be checked
  
  /* open file and test for it being a png */
  FILE *fp = fopen(file_name, "rb");
  if (!fp)
    abort_("[read_png_file] File %s could not be opened for reading", file_name);
  fread(header, 1, 8, fp);
  if (png_sig_cmp(header, 0, 8))
    abort_("[read_png_file] File %s is not recognized as a PNG file", file_name);
  
  
  /* initialize stuff */
  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  

  if (!png_ptr)
    abort_("[read_png_file] png_create_read_struct failed");
  
  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr)
    abort_("[read_png_file] png_create_info_struct failed");
  
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[read_png_file] Error during init_io");
  
  png_init_io(png_ptr, fp);
  png_set_sig_bytes(png_ptr, 8);
  
  png_read_info(png_ptr, info_ptr);


  
  width = png_get_image_width(png_ptr, info_ptr);
  height = png_get_image_height(png_ptr, info_ptr);
  color_type = png_get_color_type(png_ptr, info_ptr);
  bit_depth = png_get_bit_depth(png_ptr, info_ptr);


  printf("width = %d\n", width);
  printf("height = %d\n", height);
  printf("color_type = %d (palette = %s)\n", color_type, color_type == PNG_COLOR_TYPE_PALETTE ? "yes" : "no");
  printf("bit_depth = %d\n", bit_depth);
  printf("number_of_passes = %d\n", number_of_passes);

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
  width = png_get_image_width(png_ptr, info_ptr);
  height = png_get_image_height(png_ptr, info_ptr);
  color_type = png_get_color_type(png_ptr, info_ptr);
  bit_depth = png_get_bit_depth(png_ptr, info_ptr);


  /* read file */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[read_png_file] Error during read_image");
  
  row_pointers = (png_bytep*) malloc(sizeof(png_bytep) * height);
  
  if (bit_depth == 16)
    rowbytes = width*8;
  else
    rowbytes = width*4;
  
  for (int y=0; y<height; y++)
    row_pointers[y] = (png_byte*) malloc(rowbytes);
  
  png_read_image(png_ptr, row_pointers);
  
  fclose(fp);

  printf("width = %d\n", width);
  printf("height = %d\n", height);
  printf("color_type = %d (palette = %s)\n", color_type, color_type == PNG_COLOR_TYPE_PALETTE ? "yes" : "no");
  printf("bit_depth = %d\n", bit_depth);
  printf("number_of_passes = %d\n", number_of_passes);
}


void 
write_png_file(char* file_name)
{
  /* create file */
  FILE *fp = fopen(file_name, "wb");
  if (!fp)
    abort_("[write_png_file] File %s could not be opened for writing", file_name);
  
  
  /* initialize stuff */
  png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  
  if (!png_ptr)
    abort_("[write_png_file] png_create_write_struct failed");
  
  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr)
    abort_("[write_png_file] png_create_info_struct failed");
  
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during init_io");
  
  png_init_io(png_ptr, fp);
  
  
  /* write header */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during writing header");
  
  png_set_IHDR(png_ptr, info_ptr, width, height,
	       8, 6, PNG_INTERLACE_NONE,
	       PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);
  
  png_write_info(png_ptr, info_ptr);
  
  
  /* write bytes */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during writing bytes");
  
  png_write_image(png_ptr, row_pointers);
  
  
  /* end write */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during end of write");
  
  png_write_end(png_ptr, NULL);
  
  /* cleanup heap allocation */
  for (int y=0; y<height; y++)
    free(row_pointers[y]);
  free(row_pointers);
  
  fclose(fp);
}


void
process_file(void)
{
  amigaImage = calloc(width*height, 4);

  for (int y=0; y<height; y++) {
    png_byte* row = row_pointers[y];
    for (int x=0; x<width; x++) {
      png_byte* ptr = &(row[x*4]);
  
      amiga_color_t color;
      color.r = ptr[0] >> 4;
      color.g = ptr[1] >> 4;
      color.b = ptr[2] >> 4;

      int index = -1;
      for (int i = 0; i < paletteIndex; i++) {
	if (memcmp(&palette[i], &color, sizeof(amiga_color_t)) == 0) {
	  index = i;
	  break;
	}
      }

      if (index == -1 && paletteIndex < MAX_PALETTE) {
	index = paletteIndex;
	paletteIndex++;

      } else if (index == -1 && paletteIndex == MAX_PALETTE) {
	abort_("Too many colors\n");
      }

      palette[index] = color ;
      amigaImage[(width*y)+x] = index;

      //      printf("Pixel at position [ %d - %d ] has  pindex = %d\n", x, y, index);

      
      /* perform whatever modifications needed, for example to set red value to 0 and green value to the blue one:
	 ptr[0] = 0;
	 ptr[1] = ptr[2]; */
    }
  }


  int numColors = paletteIndex-1;
  int numBitPlanes = (int)(log(numColors) / log(2))+1;
  
  printf("number of colors = %d\n", numColors);
  printf("number of bitplanes = %d\n", numBitPlanes);

  FILE* fp = fopen("copper-list.s", "w+");
  
  for (int i = 0; i < paletteIndex; i++) {
    printf("%d: %x %d %d %d\n", i , palette[i].r << 8 | palette[i].g << 4 | palette[i].b, palette[i].r, palette[i].g, palette[i].b);
    fprintf(fp, "\tdc.w $%x,$%x\n", 0x180+(i*2), palette[i].r << 8 | palette[i].g << 4 | palette[i].b);
  }

  fclose(fp);

  int byteWidth = (width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)+numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*height, 1);
  }


  for (int y = 0, writeIndex = 0; y < height; y++) {
    for (int byte = 0;byte < byteWidth; byte++) {
      for (int bit = 0; bit < 8; bit++) {	
	int x = byte * 8 + 7 - bit;
	int palette_index = amigaImage[(width*y)+x];
	for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((palette_index >> plane_index) & 1) << bit;
	}
      }
      writeIndex++;
    }
  }


#if 0
  for (int i = 0; i < numBitPlanes; i++) {
    char filename[255];
    sprintf(filename, "bitplane%d.bin", i);
    fp = fopen(filename, "w+");
    fwrite(bitplanes[i], byteWidth*height, 1, fp);
    fclose(fp);
  }

#endif

  fp = fopen("bitplane.bin", "w+");
  for (int y = 0; y < height; y++) {
    for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
      char* plane = bitplanes[plane_index];
      fwrite(&plane[y*byteWidth], byteWidth, 1, fp);      
    }
  }
  fclose(fp);
}
    


int 
main(int argc, char **argv)
{
  if (argc != 2)
    abort_("Usage: program_name <file_in> <file_out>");
  
  read_png_file(argv[1]);
     process_file();
  // write_png_file(argv[2]);
  
  return 0;
}
