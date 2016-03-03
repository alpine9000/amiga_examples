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
#include <png.h>
#include <pngquant/libimagequant.h>
#include "imagecon.h"

imagecon_config_t config = { 
  .maxColors = MAX_PALETTE, 
  .outputPalette = 0, 
  .outputMask = 0,
  .quantize = 0,
  .overridePalette = 0
};

typedef struct {
  unsigned char r;
  unsigned char g;
  unsigned char b;
  unsigned char a;
} amiga_color_t;


void
usage()
{
  fprintf(stderr, "%s: --input <input.png> [options]\nOptions:\n  --output <output prefix>\n  --colors <max colors>\n  --quantize\n  --output-mask\n  --output-palette\n  --override-palette <palette file>\n  --verbose\n", config.argv[0]);
  exit(1);
}


void 
abort_(const char * s, ...)
{
  fprintf(stderr, "%s: ", config.argv[0]);
  va_list args;
  va_start(args, s);
  vfprintf(stderr, s, args);
  fprintf(stderr, "\n");
  va_end(args);
  exit(1);
}


FILE * 
openFileWrite(const char * s, ...)
{
  char buffer[4096];
  va_list args;
  va_start(args, s);
  vsprintf(buffer, s, args);
  va_end(args);

  if (config.verbose) {
    printf("Opening %s for writing\n", buffer);
  }

  FILE* fp = fopen(buffer, "w+");
  if (!fp) {
    abort_("Failed to open %s for writing\n", buffer);
  }
  return fp;
}


FILE * 
openFileRead(const char * s, ...)
{
  char buffer[4096];
  va_list args;
  va_start(args, s);
  vsprintf(buffer, s, args);
  va_end(args);

  FILE* fp = fopen(buffer, "r");
  if (!fp) {
    abort_("Failed to open %s for reading\n", buffer);
  }
  return fp;
}


void 
outputPalette(char* outFilename, amiga_color_t* palette, int numColors)
{
  if (config.verbose) {
    printf("outputPalette...\n");
  }

  FILE* fp = openFileWrite("%s-copper-list.s", outFilename);
  FILE* paletteFP = 0;
  if (config.outputPalette) {
    paletteFP = openFileWrite("%s.pal", outFilename);
  }

  if (config.verbose) {
    printf("outputPalette:\n");
  }
  
  for (int i = 0; i < numColors; i++) {
    if (config.verbose) {
      printf("%02d: hex=%03x r=%03d g=%03d b=%03d a=%03d\n", i , palette[i].r << 8 | palette[i].g << 4 | palette[i].b, palette[i].r, palette[i].g, palette[i].b, palette[i].a);
    }
    if (paletteFP) {
      fprintf(paletteFP, "%03x\n",  palette[i].r << 8 | palette[i].g << 4 | palette[i].b);
    }
    fprintf(fp, "\tdc.w $%x,$%x\n", 0x180+(i*2), palette[i].r << 8 | palette[i].g << 4 | palette[i].b);
  }
  if (paletteFP) {
    fclose(paletteFP);
  }

  fclose(fp);

  if (config.verbose) {
    printf("done\n\n");
  }
}


int
generateQuantizedPalette(unsigned char* amigaImage, png_bytep* rowPointers, amiga_color_t* palette)
{
  if (config.verbose) {
    printf("generateQuantizedPalette...\n");
  }

  liq_attr *attr = liq_attr_create();
  liq_image *image = liq_image_create_rgba_rows(attr, (void**)rowPointers, config.width, config.height, 0);

  if (config.overridePalette) {
    FILE* fp = openFileRead(config.overridePalette);
    int paletteIndex;

    for (paletteIndex = 0; paletteIndex < MAX_PALETTE; paletteIndex++) {
      unsigned int c;
      char buffer[255];
      char* line = fgets(buffer, 255, fp);
      liq_color color;
      if (!line) {
	break;
      }
      sscanf(buffer, "%x\n", &c);
      
      color.r = (c >> 8 & 0xF) << 4;
      color.g = (c >> 4 & 0xF) << 4;
      color.b = (c >> 0 & 0xF) << 4;
      color.a = 255;
      if (config.verbose) {
	printf("adding fixed color %d %d %d %d\n", paletteIndex, color.r, color.g, color.b);
      }
      liq_image_add_fixed_color(image, color);
    }
    config.maxColors = paletteIndex;
  }

  liq_set_max_colors(attr, config.maxColors);
  liq_set_speed(attr, 1);
  liq_result *res = liq_quantize_image(attr, image);

  liq_write_remapped_image(res, image, amigaImage, config.width*config.height);
  
  const liq_palette *pal = liq_get_palette(res);
  
  if (config.verbose) {
    printf("pal->count = %d\n", pal->count);
    printf("generateQuantizedPalette: post liq_write_remapped_image\n");
  }
  
  for (unsigned i = 0; i < pal->count; i++) {
    if (config.verbose) {
      printf("%02d:  r=%03d g=%03d b=%03d a=%03d\n", i, pal->entries[i].r, pal->entries[i].g, pal->entries[i].b, pal->entries[i].a);
    }
    palette[i].r = pal->entries[i].r >> 4;
    palette[i].g = pal->entries[i].g >> 4;
    palette[i].b = pal->entries[i].b >> 4;
    palette[i].a = pal->entries[i].a >> 4;
  }

  if (config.verbose) {
    printf("done\n\n");
  }
  
  return pal->count;
}


int
generatePalette(unsigned char* amigaImage, png_bytep* rowPointers, amiga_color_t* palette)
{
  if (config.verbose) {
    printf("generatePalette...\n");
  }

  int paletteIndex = 0;
  for (int y=0; y<config.height; y++) {
    png_byte* row = rowPointers[y];
    for (int x=0; x < config.width; x++) {
      png_byte* ptr = &(row[x*4]);
      
      amiga_color_t color;
      color.r = ptr[0] >> 4;
      color.g = ptr[1] >> 4;
      color.b = ptr[2] >> 4;
      color.a = ptr[3] >> 4;
      
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
	abort_("Too many colors. Use --quantize.\n");
      }
      
      palette[index] = color ;
      amigaImage[(config.width*y)+x] = index;
    }
  }

  if (config.verbose) {
    printf("done\n\n");
  }  

  return paletteIndex;
}

void
outputBitplanes(char* outFilename, unsigned char* amigaImage, int numColors)
{


  if (config.verbose) {
    printf("outputBitplanes...\n");
  }
  int numBitPlanes = (int)(log(numColors-1) / log(2))+1;
  
  if (config.verbose) {
    printf("number of colors = %d\n", numColors);
    printf("number of bitplanes = %d\n", numBitPlanes);
  }

  
  int byteWidth = (config.width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)*numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*config.height, 1);
  }

  for (int y = 0, writeIndex = 0; y < config.height; y++) {
    for (int byte = 0;byte < byteWidth; byte++) {
      for (int bit = 0; bit < 8; bit++) {	
	int x = byte * 8 + 7 - bit;
	int palette_index = amigaImage[(config.width*y)+x];
	for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((palette_index >> plane_index) & 1) << bit;
	}
      }
      writeIndex++;
    }
  }


  FILE* fp = openFileWrite("%s.bin", outFilename);

  for (int y = 0; y < config.height; y++) {
    for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
      char* plane = bitplanes[plane_index];
      fwrite(&plane[y*byteWidth], byteWidth, 1, fp);      
    }
  }
  fclose(fp);
  if (config.verbose) {
    printf("done\n\n");
  }
}

void
outputMask(char* outFilename, unsigned char* amigaImage, amiga_color_t* palette, int numColors)
{
  if (config.verbose) {
    printf("outputMask...\n");
  }
  int numBitPlanes = (int)(log(numColors-1) / log(2))+1;
  
  int byteWidth = (config.width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)*numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*config.height, 1);
  }


  for (int y = 0, writeIndex = 0; y < config.height; y++) {
    for (int byte = 0;byte < byteWidth; byte++) {
      for (int bit = 0; bit < 8; bit++) {	
	int x = byte * 8 + 7 - bit;
	int paletteIndex = amigaImage[(config.width*y)+x];
	int bitmask = palette[paletteIndex].a > 0 ? 0xFF : 0;
	for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((bitmask >> plane_index) & 1) << bit;
	}
      }
      writeIndex++;
    }
  }

  FILE* fp = openFileWrite("%s-mask.bin", outFilename);

  for (int y = 0; y < config.height; y++) {
    for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
      char* plane = bitplanes[plane_index];
      fwrite(&plane[y*byteWidth], byteWidth, 1, fp);      
    }
  }
  fclose(fp);

  if (config.verbose) {
    printf("done\n\n");
  }
}

void
processFile(char* outFilename, png_bytep* rowPointers)
{
  if (config.verbose) {
    printf("processFile...\n");
  }

  int numColors;
  amiga_color_t palette[MAX_PALETTE];

  unsigned char* amigaImage = 0;
  
  amigaImage = calloc(config.width*config.height, 1);

  if (config.quantize || config.overridePalette) {
    numColors = generateQuantizedPalette(amigaImage, rowPointers,  palette);
  } else {
    numColors = generatePalette(amigaImage, rowPointers, palette);
  }

  outputBitplanes(outFilename, amigaImage, numColors);

  if (config.outputMask) {
    outputMask(outFilename, amigaImage, palette, numColors);
  }
  outputPalette(outFilename, palette, numColors);

  if (config.verbose) {
    printf("done\n\n");
  }
}
    


int 
main(int argc, char **argv)
{
  config.argv = argv;
  char* inputFile = 0, *outputFile = 0;
  int c;

  while (1) {
    static struct option long_options[] = {
      {"verbose", no_argument, &config.verbose, 1},
      {"quantize", no_argument, &config.quantize, 1},
      {"output-palette", no_argument, &config.outputPalette, 1},
      {"output-mask", no_argument, &config.outputMask, 1},
      {"override-palette", required_argument, 0, 'p'},
      {"output",  required_argument, 0, 'o'},
      {"colors",  required_argument, 0, 'c'},
      {"input",   required_argument, 0, 'i'},
      {0, 0, 0, 0}
    };
    
    int option_index = 0;
    
    c = getopt_long (argc, argv, "o:c:i:", long_options, &option_index);
    
    if (c == -1)
      break;
    
    switch (c) {
    case 0:
      break;
    case 'i':
      inputFile = optarg;
      break;	
    case 'o':
      outputFile = optarg;
      break;	
    case 'p':
      config.overridePalette = optarg;
      break;
    case 'c':
      if (sscanf(optarg, "%d", &config.maxColors) != 1) {
	abort_("invalid number of colors");
      }
      if (config.maxColors > MAX_PALETTE) {
	abort_("Number of colors exceeds limit (%d colors)", MAX_PALETTE);
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
  
  if (config.verbose) {
    printf("Options:\nverbose = %d\ninputFile = %s\noutputFile = %s\nmaxColors = %d\noutputPalette = %d\noutputMask = %d\n\n", config.verbose, inputFile, outputFile, config.maxColors, config.outputPalette, config.outputMask);
  }
  
  processFile(outputFile, png_read(inputFile));
 
  return 0;
}
