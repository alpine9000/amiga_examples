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
  .outputPaletteAsm = 0,
  .outputPaletteGrey = 0,
  .outputBitplanes = 0,
  .outputCopperList = 0,
  .ehbMode = 0,
  .quantize = 0,
  .overridePalette = 0
};


void
usage()
{
  fprintf(stderr, 
	  "%s:  --input <input1.png,input2.png...> [options]\n"\
	  "options:\n"\
	  "  --output <output prefix>\n"\
	  "  --colors <max colors>\n"\
	  "  --quantize\n  --output-mask\n"\
	  "  --output-bitplanes\n"\
	  "  --output-copperlist\n"\
	  "  --output-mask\n"\
	  "  --output-palette-asm\n"\
	  "  --output-grey-palette-asm\n"\
	  "  --output-palette\n"\
	  "  --extra-half-brite\n"\
	  "  --use-palette <palette file>\n"	\
	  "  --verbose\n", config.argv[0]);
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
outputPalette(char* outFilename, imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("outputPalette...%d colors\n", ic->numColors);
  }

  FILE* fp = 0;
  FILE* paletteFP = 0;
  FILE* paletteAsmFP = 0;
  FILE* paletteGreyFP = 0;

  if (config.outputCopperList) {
    fp = openFileWrite("%s-copper-list.s", outFilename);
  }

  if (config.outputPalette) {
    paletteFP = openFileWrite("%s.pal", outFilename);
  }

  if (config.outputPaletteGrey) {
    paletteGreyFP = openFileWrite("%s-grey.s", outFilename);
    fprintf(paletteGreyFP, "\tmovem.l d0-a6,-(sp)\n\tlea CUSTOM,a6\n");
  }

  if (config.outputPaletteAsm) {
    paletteAsmFP = openFileWrite("%s-palette.s", outFilename);
    fprintf(paletteAsmFP, "\tmovem.l d0-a6,-(sp)\n\tlea CUSTOM,a6\n");
  }

  if (config.verbose) {
    printf("outputPalette:\n");
  }
  
  for (int i = 0; i < (config.ehbMode ? ic->numColors/2 : ic->numColors); i++) {
    if (config.verbose) {
      printf("%02d: hex=%03x r=%03d g=%03d b=%03d a=%03d\n", i , ic->palette[i].r << 8 | ic->palette[i].g << 4 | ic->palette[i].b, ic->palette[i].r, ic->palette[i].g, ic->palette[i].b, ic->palette[i].a);
    }
    if (paletteFP) {
      fprintf(paletteFP, "%03x\n",  (ic->palette[i].r >> 4) << 8 | (ic->palette[i].g >>4) << 4 | (ic->palette[i].b >>4));
    }
    if (paletteAsmFP) {
      fprintf(paletteAsmFP, "\tlea COLOR%02d(a6),a0\n\tmove.w #$%03x,(a0)\n", i, (ic->palette[i].r >> 4) << 8 | (ic->palette[i].g >>4) << 4 | (ic->palette[i].b >>4));
    }
    if (paletteGreyFP) {
      // TODO: this is for compat, can be better
      unsigned grey = (((ic->palette[i].r>>4) + (ic->palette[i].g>>4) + (ic->palette[i].b>>4))/3);
      fprintf(paletteGreyFP, "\tlea COLOR%02d(a6),a0\n\tmove.w #$%03x,(a0)\n", i, grey << 8 | grey << 4 | grey);
    }

    if (fp) {
      fprintf(fp, "\tdc.w $%x,$%x\n", 0x180+(i*2), (ic->palette[i].r >> 4) << 8 | (ic->palette[i].g >>4) << 4 | (ic->palette[i].b >>4));
    }
  }

  if (paletteFP) {
    fclose(paletteFP);
  }

  if (paletteGreyFP) {
    fprintf(paletteGreyFP, "\tmovem.l (sp)+,d0-a6\n");
    fclose(paletteGreyFP);
  }

  if (paletteAsmFP) {
    fprintf(paletteAsmFP, "\tmovem.l (sp)+,d0-a6\n");
    fclose(paletteFP);
  }

  if (fp) {
    fclose(fp);
  }

  if (config.verbose) {
    printf("done\n\n");
  }
}

void loadPaletteFile(imagecon_image_t* ic)
{
  FILE* fp = openFileRead(config.overridePalette);
  int paletteIndex;
  
  for (paletteIndex = 0; paletteIndex < MAX_PALETTE; paletteIndex++) {
    unsigned int c;
    char buffer[255];
    char* line = fgets(buffer, 255, fp);
    if (!line) {
      break;
    }
    sscanf(buffer, "%x\n", &c);
    
    ic->palette[paletteIndex].r = (c >> 8 & 0xF) << 4;
    ic->palette[paletteIndex].g = (c >> 4 & 0xF) << 4;
    ic->palette[paletteIndex].b = (c >> 0 & 0xF) << 4;
    ic->palette[paletteIndex].a = 255;
  }

  ic->numColors = paletteIndex;
}

void
generateQuantizedImage(imagecon_image_t* ic, int usePalette)
{
  if (config.verbose) {
    printf("generateQuantizedImage...\n");
  }

  liq_attr *attr = liq_attr_create();
  liq_image *image = liq_image_create_rgba_rows(attr, (void**)ic->rowPointers, ic->width, ic->height, 0);

  if (usePalette) {
    for (int i = 0; i < ic->numColors; i++) {
      liq_color color;
      color.a = ic->palette[i].a;
      color.r = ic->palette[i].r;
      color.g = ic->palette[i].g;
      color.b = ic->palette[i].b;
      liq_image_add_fixed_color(image, color);
    }
    config.maxColors = ic->numColors;
  }

  liq_set_max_colors(attr, config.maxColors);
  liq_set_speed(attr, 1);
  liq_result *res = liq_quantize_image(attr, image);

  liq_write_remapped_image(res, image, ic->amigaImage, ic->width*ic->height);

  const liq_palette *pal = liq_get_palette(res);
  
  if (config.verbose) {
    printf("pal->count = %d\n", pal->count);
    printf("generateQuantizedImage: post liq_write_remapped_image\n");
  }

  for (unsigned i = 0; i < pal->count; i++) {
    if (config.verbose) {
      printf("%02d:  r=%03d g=%03d b=%03d a=%03d\n", i, pal->entries[i].r, pal->entries[i].g, pal->entries[i].b, pal->entries[i].a);
    }
    ic->palette[i].r = pal->entries[i].r;
    ic->palette[i].g = pal->entries[i].g;
    ic->palette[i].b = pal->entries[i].b;
    ic->palette[i].a = pal->entries[i].a;
  }

  if (config.verbose) {
    printf("done\n\n");
  }
  
  ic->numColors = pal->count;
}


void
generatePalette(imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("generatePalette...\n");
  }

  int paletteIndex = 0;
  for (int y=0; y< ic->height; y++) {
    png_byte* row = ic->rowPointers[y];
    for (int x=0; x < ic->width; x++) {
      png_byte* ptr = &(row[x*4]);
      
      amiga_color_t color;
      color.r = ptr[0] >> 4;
      color.g = ptr[1] >> 4;
      color.b = ptr[2] >> 4;
      color.a = ptr[3] >> 4;
      
      int index = -1;
      for (int i = 0; i < paletteIndex; i++) {
	if (memcmp(&ic->palette[i], &color, sizeof(amiga_color_t)) == 0) {
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
      
      ic->palette[index] = color ;
      ic->amigaImage[(ic->width*y)+x] = index;
    }
  }

  if (config.verbose) {
    printf("done\n\n");
  }  

  ic->numColors = paletteIndex;
}


void
outputBitplanes(char* outFilename, imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("outputBitplanes...\n");
  }
 
  int numBitPlanes = (int)(log(ic->numColors-1) / log(2))+1;
  int numColors;

  if (config.ehbMode) {
    numColors = ic->numColors / 2;
    if (config.verbose) {    
      printf("extra half brite mode\n");
    }
  } else {
    numColors = ic->numColors;
  }
 
  if (config.verbose) {    
    printf("number of colors = %d\n", numColors);
    printf("number of bitplanes = %d\n", numBitPlanes);
  }
 
  int byteWidth = (ic->width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)*numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*ic->height, 1);
  }

  for (int y = 0, writeIndex = 0; y < ic->height; y++) {
    for (int byte = 0;byte < byteWidth; byte++) {
      for (int bit = 0; bit < 8; bit++) {	
	int x = byte * 8 + 7 - bit;
	int palette_index = ic->amigaImage[(ic->width*y)+x];
	int ehb = 0;
	if (palette_index >= numColors) {
	  if (config.verbose) {
	    printf("EHB Detected e%d -> ", palette_index);
	  }
	  palette_index -= numColors;
	  if (config.verbose) {
	    printf("%d\n", palette_index);
	  }
	  ehb = 1;
	}
	int _numBitPlanes = config.ehbMode ? numBitPlanes-1 : numBitPlanes;

	for (int plane_index = 0; plane_index < _numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((palette_index >> plane_index) & 1) << bit;
	}
	
	if (ehb) {
	  bitplanes[numBitPlanes-1][writeIndex] |= (1 << bit);
	}
      }
      writeIndex++;
    }
  }

  FILE* fp = openFileWrite("%s.bin", outFilename);

  for (int y = 0; y < ic->height; y++) {
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
outputMask(char* outFilename, imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("outputMask...\n");
  }
  int numBitPlanes = (int)(log(ic->numColors-1) / log(2))+1;
  
  int byteWidth = (ic->width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)*numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*ic->height, 1);
  }

  for (int y = 0, writeIndex = 0; y < ic->height; y++) {
    for (int byte = 0;byte < byteWidth; byte++) {
      for (int bit = 0; bit < 8; bit++) {	
	int x = byte * 8 + 7 - bit;
	int paletteIndex = ic->amigaImage[(ic->width*y)+x];
	int bitmask = ic->palette[paletteIndex].a > 0 ? 0xFF : 0;
	for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((bitmask >> plane_index) & 1) << bit;
	}
      }
      writeIndex++;
    }
  }

  FILE* fp = openFileWrite("%s-mask.bin", outFilename);

  for (int y = 0; y < ic->height; y++) {
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
processFile(char* outFilename, imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("processFile...\n");
  }

  if (config.quantize || config.overridePalette) {
    if (config.ehbMode) {
      if (config.maxColors > 32) {
	abort_("Can't do EHB emode with > 32 colors\n");
      }
      // First find best N color palette
      generateQuantizedImage(ic, 0);
      // now add the EHB colors
      
      for (int i = 0; i < ic->numColors; i++) {
	ic->palette[i+ic->numColors].r = ic->palette[i].r/2;
	ic->palette[i+ic->numColors].g = ic->palette[i].g/2;
	ic->palette[i+ic->numColors].b = ic->palette[i].b/2;
	ic->palette[i+ic->numColors].a = ic->palette[i].a;
      }
      config.maxColors = ic->numColors = config.maxColors * 2;
      printf("config.maxColors = %d\n", config.maxColors);
      //now generate the half brite version*/
      generateQuantizedImage(ic, 1);
    } else {
      if (config.overridePalette) {
	loadPaletteFile(ic);
      }
      generateQuantizedImage(ic, config.overridePalette != 0);
    }
  } else {
    generatePalette(ic);
  }

  if (config.outputBitplanes) {
    outputBitplanes(outFilename, ic);
  }

  if (config.outputMask) {
    outputMask(outFilename, ic);
  }

  outputPalette(outFilename, ic);

  if (config.verbose) {
    printf("done\n\n");
  }
}

    
void
splitFiles(char* inputFile, int* count, char*** vector)
{
  char* ptr = inputFile;
  char* end;
  char** files = calloc(sizeof(void*), 1);
  int index = 0;			  
  do {
    end = strchr(ptr, ',');
    char* file;
    if (end) {
      file = calloc(end-ptr+1, 1);
      strncpy(file, ptr, end-ptr);
      ptr = end+1;
    } else {
      file = calloc(strlen(ptr)+1, 1);
      strcpy(file, ptr);
    }
    
    files[index++] = file;
    files = realloc(files, index*sizeof(void*));
    
  } while (end != 0);
  
  
  *vector = files;
  *count = index;
}

#define max(x,y) (x > y ? x : y)

void
combineImages(imagecon_image_t** images, int numImages, imagecon_image_t* ic)
{
  ic->width = 0;
  ic->height = 0;
  
 for (int i = 0; i < numImages; i++) {
   ic->width = max(images[i]->width, ic->width);
   ic->height += images[i]->height;
 }

 ic->rowPointers = (png_bytep*) malloc(sizeof(png_bytep) * ic->height);
 ic->amigaImage = calloc(ic->width*ic->height, 1);

 for (int y = 0; y < ic->height; y++) {
   ic->rowPointers[y] = (png_byte*) calloc(ic->width*4, 1);
 }

 for (int i = 0, ny = 0; i < numImages; i++) {
   for (int y = 0; y < images[i]->height; y++, ny++) {
     for (int r = 0; r <  ic->width*4; r+=4) {
       memcpy(&ic->rowPointers[ny][0]+r, &images[i]->rowPointers[y][0], 4);
     }
     memcpy(ic->rowPointers[ny], images[i]->rowPointers[y], images[i]->width*4);
   }
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
      {"output-copperlist", no_argument, &config.outputCopperList, 1},
      {"output-bitplanes", no_argument, &config.outputBitplanes, 1},
      {"output-palette", no_argument, &config.outputPalette, 1},
      {"output-palette-asm", no_argument, &config.outputPaletteAsm, 1},
      {"output-grey-palette-asm", no_argument, &config.outputPaletteGrey, 1},
      {"output-mask", no_argument, &config.outputMask, 1},
      {"extra-half-brite", no_argument, &config.ehbMode, 1},
      {"use-palette", required_argument, 0, 'p'},
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
  
  if (strchr(inputFile, ',') == 0) {
    imagecon_image_t ic = {0};
    png_read(inputFile, &ic);
    processFile(outputFile, &ic); 
  } else {
    char** files;
    int numFiles;
    splitFiles(inputFile, &numFiles, &files);

    imagecon_image_t** images = malloc(sizeof(imagecon_image_t*)*numFiles);

    for (int i = 0; i < numFiles; i++) {
      images[i] = calloc(sizeof(imagecon_image_t), 1);
      png_read(files[i], images[i]);
    }
    
    imagecon_image_t combined;
    combineImages(images, numFiles, &combined);
    processFile(outputFile, &combined);       
  }
 
  return 0;
}
