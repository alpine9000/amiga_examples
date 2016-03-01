/*
 * Orginal copyright from libpng example code
 *
 * Copyright 2002-2011 Guillaume Cottenceau and contributors.
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */

/*
 * Amiga bitplane creation inspired (copied) from https://github.com/vilcans/amiga-startup
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>
#include <getopt.h>
#include <libgen.h>

#define PNG_DEBUG 3
#include <png.h>

#include <pngquant/libimagequant.h>

char** _argv;
int verbose = 0;

void
usage()
{
  fprintf(stderr, "%s: --input <input.png> [options]\nOptions:\n  --colors <max colors>\n  --output <output prefix>\n", _argv[0]);
  exit(1);
}

void 
abort_(const char * s, ...)
{
  fprintf(stderr, "%s: ", _argv[0]);
  va_list args;
  va_start(args, s);
  vfprintf(stderr, s, args);
  fprintf(stderr, "\n");
  va_end(args);
  exit(1);
}

#define MAX_PALETTE 32
int width, height, maxColors = MAX_PALETTE;
png_bytep* rowPointers;

typedef struct {
    unsigned char r;
    unsigned char g;
    unsigned char b;
} amiga_color_t;

amiga_color_t palette[MAX_PALETTE];
int paletteIndex = 0;
unsigned char* amigaImage = 0;

void readFile(char* file_name)
{
  png_structp png_ptr; 
  png_byte color_type;
  png_byte bit_depth; 
  png_infop info_ptr;
  int number_of_passes, rowbytes;
  unsigned char header[8];    // 8 is the maximum size that can be checked
  
  /* open file and test for it being a png */
  FILE *fp = fopen(file_name, "rb");
  if (!fp)
    abort_("Failed to open %s", file_name);
  fread(header, 1, 8, fp);
  if (png_sig_cmp(header, 0, 8))
    abort_("File %s is not recognized as a PNG file", file_name);

  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);  

  if (!png_ptr)
    abort_("png_create_read_struct failed");
  
  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr)
    abort_("png_create_info_struct failed");
  
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("Error during init_io");
  
  png_init_io(png_ptr, fp);
  png_set_sig_bytes(png_ptr, 8);
  
  png_read_info(png_ptr, info_ptr);
  
  width = png_get_image_width(png_ptr, info_ptr);
  height = png_get_image_height(png_ptr, info_ptr);
  color_type = png_get_color_type(png_ptr, info_ptr);
  bit_depth = png_get_bit_depth(png_ptr, info_ptr);

  if (verbose) {
    printf("width = %d\n", width);
    printf("height = %d\n", height);
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
  width = png_get_image_width(png_ptr, info_ptr);
  height = png_get_image_height(png_ptr, info_ptr);
  color_type = png_get_color_type(png_ptr, info_ptr);
  bit_depth = png_get_bit_depth(png_ptr, info_ptr);

  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("Error during read_image");
  
  rowPointers = (png_bytep*) malloc(sizeof(png_bytep) * height);
  
  if (bit_depth == 16)
    rowbytes = width*8;
  else
    rowbytes = width*4;
  
  for (int y=0; y<height; y++)
    rowPointers[y] = (png_byte*) malloc(rowbytes);
  
  png_read_image(png_ptr, rowPointers);
  
  fclose(fp);

  if (verbose) {
    printf("width = %d\n", width);
    printf("height = %d\n", height);
    printf("color_type = %d (palette = %s)\n", color_type, color_type == PNG_COLOR_TYPE_PALETTE ? "yes" : "no");
    printf("bit_depth = %d\n", bit_depth);
    printf("number_of_passes = %d\n", number_of_passes);
  }
}



void
processFile(char* outFilename)
{
  int numColors;
  amigaImage = calloc(width*height, 1);

  if (1) {
    liq_attr *attr = liq_attr_create();
    //    liq_image *image = liq_image_create_rgba(attr, rowPointers, width, height, 0);
    liq_image *image = liq_image_create_rgba_rows(attr, (void**)rowPointers, width, height, 0);
    liq_set_max_colors(attr, maxColors);
    liq_set_speed(attr, 1);
    liq_result *res = liq_quantize_image(attr, image);
    liq_write_remapped_image(res, image, amigaImage, width*height);
    
    const liq_palette *pal = liq_get_palette(res);
    
    if (verbose) {
      printf("pal->count = %d\n", pal->count);
    }


    for (unsigned i = 0; i < pal->count; i++) {
      if (verbose) {
	printf("%d %d %d %d\n", i, pal->entries[i].r, pal->entries[i].g, pal->entries[i].b);
      }
      palette[i].r = pal->entries[i].r >> 4;
      palette[i].g = pal->entries[i].g >> 4;
      palette[i].b = pal->entries[i].b >> 4;
    }
    
    numColors =  pal->count;
  } else {
    for (int y=0; y<height; y++) {
      png_byte* row = rowPointers[y];
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
      }
    }
   
    numColors = paletteIndex;
  }
  
  int numBitPlanes = (int)(log(numColors-1) / log(2))+1;
  
  if (verbose) {
    printf("number of colors = %d\n", numColors);
    printf("number of bitplanes = %d\n", numBitPlanes);
  }
  
  char filenameBuffer[2048];
  snprintf(filenameBuffer, 2048, "%s-copper-list.s", outFilename);
  FILE* fp = fopen(filenameBuffer, "w+");
  if (!fp) {
    abort_("failed to open %s for writing", filenameBuffer);
  }
  
  for (int i = 0; i < numColors; i++) {
    if (verbose) {
      printf("%d: %x %d %d %d\n", i , palette[i].r << 8 | palette[i].g << 4 | palette[i].b, palette[i].r, palette[i].g, palette[i].b);
    }
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

  snprintf(filenameBuffer, 2048, "%s.bin", outFilename);
  fp = fopen(filenameBuffer, "w+");
  if (!fp) {
    abort_("failed to open %s for writing", filenameBuffer);
  }

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
  _argv = argv;
  char* inputFile = 0, *outputFile = 0;
  int c;

  while (1)
    {
      static struct option long_options[] =
        {
          /* These options set a flag. */
          {"verbose", no_argument,       &verbose, 1},
          {"output",  required_argument, 0, 'o'},
          {"colors",  required_argument, 0, 'c'},
          {"input",   required_argument, 0, 'i'},
          {0, 0, 0, 0}
        };
      /* getopt_long stores the option index here. */
      int option_index = 0;

      c = getopt_long (argc, argv, "o:c:i:",
                       long_options, &option_index);

      /* Detect the end of the options. */
      if (c == -1)
        break;

      switch (c)
        {
	case 0:
          break;
        case 'i':
	  inputFile = optarg;
          break;

        case 'o':
	  outputFile = optarg;
          break;

        case 'c':
	  if (sscanf(optarg, "%d", &maxColors) != 1) {
	    abort_("invalid number of colors");
	  }
          break;

        case '?':
	  usage();
          break;

        default:
	  usage();
	  break;
        }
    }

  if (outputFile == 0 && inputFile != 0) {
    outputFile = basename(inputFile);
    char* ptr  = malloc(strlen(outputFile)+1);
    strcpy(ptr, outputFile);
    outputFile = ptr;
    ptr = rindex(outputFile, '.');
    if (ptr) {
      *ptr = 0;
    }
  }
  
  if (inputFile == 0 || optind < argc) {
    usage();
  }
  
  if (verbose) {
    printf("Options:\nverbose = %d\ninputFile = %s\noutputFile = %s\nmaxColors = %d\n\n", verbose, inputFile, outputFile, maxColors);
  }
  
  readFile(inputFile);
  processFile(outputFile);
 
  return 0;
}
