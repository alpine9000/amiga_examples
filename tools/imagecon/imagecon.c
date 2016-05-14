/*
 * Amiga bitplane creation inspired (copied) from https://github.com/vilcans/amiga-startup
 */

#include "imagecon.h"

imagecon_config_t config = { 
  .maxColors = MAX_PALETTE, 
  .outputPalette = 0, 
  .outputMask = 0,
  .outputPaletteAsm = 0,
  .outputPaletteGrey = 0,
  .outputBitplanes = 0,
  .outputCopperList = 0,
  .outputPng = 0,
  .ehbMode = 0,
  .hamMode = 0,
  .hamBruteForce = 0,
  .slicedHam = 0,
  .quantize = 0,
  .dither = 0,
  .overridePalette = 0,
  .paletteOffset = 0,
  .maskTransparentColor = 0,
  .fullColorPaletteFile = 0,
  .darken = 0
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
	  "  --output-png\n"\
	  "  --extra-half-brite\n"\
	  "  --ham\n"\
	  "  --ham-brute-force\n"\
	  "  --sliced-ham\n"\
          "  --dither\n"\
	  "  --transparent-color <r,g,b>\n"\
	  "  --use-palette <palette file>\n"\
	  "  --full-color-palette-file\n"\
	  "  --palette-offset <index>\n"\
	  "  --darken <percentage>\n"\
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


void
generateQuantizedImage(imagecon_image_t* ic, int usePalette)
{
  if (config.verbose) {
    printf("generateQuantizedImage...\n");
  }

  liq_attr *attr = liq_attr_create();
  // TODO: What to do with gamma here ?
  liq_image *image = liq_image_create_rgba_rows(attr, (void**)ic->rowPointers, ic->width, ic->height, /* gamma */0.0);

  if (usePalette) {
    for (int i = 0; i < ic->numColors; i++) {
      liq_color color;
      color.a = ic->palette[i].a;
      color.r = ic->palette[i].r;
      color.g = ic->palette[i].g;
      color.b = ic->palette[i].b;
      liq_image_add_fixed_color(image, color);
    }
  }


  liq_set_max_colors(attr, config.maxColors);
  // no liq_set_quality(attr, 0, 100);
  //liq_set_min_posterization(attr, 4);
  liq_set_speed(attr, 1);
  liq_result *res = liq_quantize_image(attr, image);

  //liq_set_output_gamma(res, 0.1);
  //liq_set_dithering_level(res, 0);
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

  liq_attr_destroy(attr);
  liq_image_destroy(image);
  liq_result_destroy(res);
}


void
generateQuant2(imagecon_image_t* ic)
{
  quant_image_t* image = quant_newImage(ic->width, ic->height);

  for (int c = 0, y=0; y< ic->height; y++) {
    png_byte* row = ic->rowPointers[y];
    for (int x=0; x < ic->width; x++) {
      png_byte* ptr = &(row[x*4]);
      image->pix[c++] = ptr[0];
      image->pix[c++] = ptr[1];
      image->pix[c++] = ptr[2];
    }
  }
  
  quant_quantize(image, config.maxColors, config.dither);

  for (int c = 0,y=0; y< ic->height; y++) {
    png_byte* row = ic->rowPointers[y];
    for (int x=0; x < ic->width; x++) {
      png_byte* ptr = &(row[x*4]);
      ptr[0] = image->pix[c++];
      ptr[1] = image->pix[c++];
      ptr[2] = image->pix[c++];
      ptr[3] = 255;

    }
  }
}

static void
generatePalettedImage(imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("generatePalettedImage...\n");
  }

  int paletteIndex = 0;
  for (int y=0; y< ic->height; y++) {
    png_byte* row = ic->rowPointers[y];
    for (int x=0; x < ic->width; x++) {
      png_byte* ptr = &(row[x*4]);
      
      amiga_color_t color;
      color.r = ptr[0];
      color.g = ptr[1];
      color.b = ptr[2];
      color.a = ptr[3];
      
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


static void
outputBitplanes(imagecon_image_t* ic, char* outFilename)
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

  FILE* fp = file_openWrite("%s.bin", outFilename);

  for (int y = 0; y < ic->height; y++) {
    for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
      char* plane = bitplanes[plane_index];
      fwrite(&plane[y*byteWidth], byteWidth, 1, fp);      
    }
  }

  fclose(fp);
  free_vector(bitplanes, numBitPlanes);
  if (config.verbose) {
    printf("done\n\n");
  }
}


static void
outputMask(imagecon_image_t* ic, char* outFilename)
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
	amiga_color_t c = color_getOriginalPixel(ic, x, y);
	int bitmask;
	if (config.maskTransparentColor == 0) {
	  bitmask = c.a > 0 ? 0xFF : 0;
	} else {
	  bitmask = 
	    (c.r == config.maskTransparentColor->r &&
	     c.g == config.maskTransparentColor->g &&
	     c.b == config.maskTransparentColor->b) ? 0 : 0xff;
	}
	for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((bitmask >> plane_index) & 1) << bit;
	}
      }
      writeIndex++;
    }
  }

  FILE* fp = file_openWrite("%s-mask.bin", outFilename);

  for (int y = 0; y < ic->height; y++) {
    for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
      char* plane = bitplanes[plane_index];
      fwrite(&plane[y*byteWidth], byteWidth, 1, fp);      
    }
  }
  fclose(fp);
  free_vector(bitplanes, numBitPlanes);
  if (config.verbose) {
    printf("done\n\n");
  }
}

static void
generateEHBImage(imagecon_image_t* ic)
{
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
  //now generate the half brite version*/
  generateQuantizedImage(ic, 1);
}



static void
processFile(imagecon_image_t* ic, char* outFilename)
{
  if (config.verbose) {
    printf("processFile...\n");
  }

  if (config.slicedHam) {
    sham_process(ic, outFilename);
  } else if (config.hamMode) {
    ham_process(ic, outFilename);
  } else { 
    if (config.quantize || config.overridePalette) {
      if (config.ehbMode) {
	generateEHBImage(ic);
      } else {
	if (config.overridePalette) {
	  palette_loadFile(ic);
	}
	generateQuantizedImage(ic, config.overridePalette != 0);
      }
    } else {
      generatePalettedImage(ic);
    }

    if (config.dither) {
      dither_image(ic, dither_getPalettedColor);
      dither_transferToPaletted(ic);    
    }

    if (config.outputBitplanes) {
      outputBitplanes(ic, outFilename);
    }
    
    if (config.outputMask) {
      outputMask(ic, outFilename);
    }
    
    palette_output(ic, outFilename);
  }

  if (config.outputPng) {
    char pngFilename[255];
    sprintf(pngFilename, "%s-converted.png", outFilename);
    png_write(ic, pngFilename);
  }

  if (config.verbose) {
    printf("done\n\n");
  }
}

    
static void
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

static void
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
      {"output-png", no_argument, &config.outputPng, 1},
      {"extra-half-brite", no_argument, &config.ehbMode, 1},
      {"ham", no_argument, &config.hamMode, 1},
      {"ham-brute-force", no_argument, &config.hamBruteForce, 1},
      {"sliced-ham", no_argument, &config.slicedHam, 1},
      {"dither", no_argument, &config.dither, 1},
      {"full-color-palette-file", no_argument, &config.fullColorPaletteFile, 1},
      {"use-palette", required_argument, 0, 'p'},
      {"palette-offset", required_argument, 0, 'l'},
      {"output",  required_argument, 0, 'o'},
      {"colors",  required_argument, 0, 'c'},
      {"input",   required_argument, 0, 'i'},
      {"darken",   required_argument, 0, 'd'},
      {"transparent-color",   required_argument, 0, 't'},
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
    case 'd':
      if (sscanf(optarg, "%f", &config.darken) != 1) {
	abort_("invalid darken argument");
      }
      break;
    case 'l':
      if (sscanf(optarg, "%d", &config.paletteOffset) != 1) {
	abort_("invalid palette offset");
      }
      break;
    case 'c':
      if (sscanf(optarg, "%d", &config.maxColors) != 1) {
	abort_("invalid number of colors");
      }
      if (config.maxColors > MAX_PALETTE) {
	abort_("Number of colors exceeds limit (%d colors)", MAX_PALETTE);
      }
      break;	      
    case 't':
      {
	static amiga_color_t color;
	if (sscanf(optarg, "%d,%d,%d",&color.r, &color.g, &color.b) != 3) {
	  abort_("invalid transparent color");
	}
	config.maskTransparentColor = &color;
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
    png_read(&ic, inputFile);
    processFile(&ic, outputFile); 
  } else {
    char** files;
    int numFiles;
    splitFiles(inputFile, &numFiles, &files);

    imagecon_image_t** images = malloc(sizeof(imagecon_image_t*)*numFiles);

    for (int i = 0; i < numFiles; i++) {
      images[i] = calloc(sizeof(imagecon_image_t), 1);
      png_read(images[i], files[i]);
    }
    
    imagecon_image_t combined;
    combineImages(images, numFiles, &combined);
    processFile(&combined, outputFile);       
  }
 
  return 0;
}


