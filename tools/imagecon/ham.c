#include "imagecon.h"

ham_control_t
ham_findClosestPixel(imagecon_image_t* ic, amiga_color_t color, amiga_color_t last)
{
  int delta = INT_MAX;

  ham_control_t ham = {0};

  for (int i = 0; i < ic->numColors; i++) {
    int dc = color_delta(color, ic->palette[i]);
    if (dc < delta) {
      delta = dc;
      ham.data = i;
      ham.pixel = ic->palette[i];
    }
  }

  delta =  color_delta(color, ham.pixel);
  if (last.r != -1) {
    for (int c = 0; c <= 0xF; c++) {
      amiga_color_t copy = last;
      copy.r = c<<4;
      int dc = color_delta(color, copy);
      if (dc < delta) {
	ham.control = 2;
	ham.data = c;
	ham.pixel = copy;
	delta = dc;
      }
    }
    for (int c = 0; c <= 0xF; c++) {
      amiga_color_t copy = last;
      copy.g = c<<4;
      int dc = color_delta(color, copy);
      if (dc < delta) {
	ham.control = 3;
	ham.data = c;
	ham.pixel = copy;
	delta = dc;
      }
    }
    for (int c = 0; c <= 0xF; c++) {
      amiga_color_t copy = last;
      copy.b = c<<4;
      int dc = color_delta(color, copy);
      if (dc < delta) {
	ham.control = 1;
	ham.data = c;
	ham.pixel = copy;
	delta = dc;
      }
    }
  }	

  return ham;
}


static amiga_color_t
_ham_getHamColor(dither_data_t data)
{
  ham_control_t ham = ham_findClosestPixel(data.ic, data.color, data.last);
  return ham.pixel;
}


static ham_control_t* 
_ham_createHams(imagecon_image_t* ic)
{
  ham_control_t* hams = malloc(sizeof(ham_control_t)*ic->width*ic->height);

  for (int y = 0; y < ic->height; y++) {
    amiga_color_t lastPixel = { -1, -1, -1, -1};
    for (int x = 0; x < ic->width; x++) {
      amiga_color_t orig = color_ditheredToAmiga(color_getDitheredPixel(ic, x, y));
      ham_control_t ham = ham_findClosestPixel(ic, orig, lastPixel);
      lastPixel = ham.pixel;
      hams[(y*ic->width)+x] = ham;
    }
  }

  return hams;
}


static void
_ham_outputBitplanes(imagecon_image_t* ic, char* outFilename)
{
  if (config.verbose) {
    printf("outputHamBitplanes\n");
  }
 
  int numBitPlanes = 6;
  int byteWidth = (ic->width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)*numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*ic->height, 1);
  }

  ham_control_t* hams;

  if (config.dither) {
    dither_image(ic, _ham_getHamColor);
    hams = _ham_createHams(ic);
  } else {
    hams = malloc(sizeof(ham_control_t)*ic->width*ic->height);
    
    for (int y = 0; y < ic->height; y++) {
      amiga_color_t lastPixel = { -1, -1, -1, -1};
      for (int x = 0; x < ic->width; x++) {
	amiga_color_t orig = color_getOriginalPixel(ic, x, y);
	ham_control_t ham = ham_findClosestPixel(ic, orig, lastPixel);
	lastPixel = ham.pixel;      
	hams[(y*ic->width)+x] = ham;
      }
    }
  }

  for (int y = 0, writeIndex = 0; y < ic->height; y++) {
    for (int byte = 0;byte < byteWidth; byte++) {
      for (int bit = 0; bit < 8; bit++) {	
	int x = byte * 8 + 7 - bit;    
	ham_control_t ham = hams[(y*ic->width)+x];
	int _numBitPlanes = 4;
	for (int plane_index = 0; plane_index < _numBitPlanes; plane_index++) {
	  char* plane = bitplanes[plane_index];
	  plane[writeIndex] |= ((ham.data >> plane_index) & 1) << bit;
	}       

	for (int plane_index = 0; plane_index < 2; plane_index++) {
	  char* plane = bitplanes[4+plane_index];
	  plane[writeIndex] |= ((ham.control >> plane_index) & 1) << bit;
	}       

	
      }
      writeIndex++;
    }
  }


  FILE* fp = file_openWrite("%s-ham.bin", outFilename);

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


static int 
_score(imagecon_image_t* ic)
{
  long error = 0;
  for (int y = 0; y < ic->height; y++) {
    amiga_color_t lastPixel = { -1, -1, -1, -1};
    for (int x = 0; x < ic->width; x++) {
      amiga_color_t color = color_getOriginalPixel(ic, x, y);
      ham_control_t ham = ham_findClosestPixel(ic, color, lastPixel);
      error += color_delta(color, color_findClosestPalettePixel(ic, ham.pixel));
      lastPixel = ham.pixel;
    }
  }

  return error;
}


static void
_ham_bruteForcePalette(imagecon_image_t* ic)
{
  int totalCombinations = 16*16*16;
  amiga_color_t *combos = malloc(sizeof(amiga_color_t)*totalCombinations);
  int index = 0;
  int length = 16;

  bzero(ic->palette, sizeof(ic->palette));
  ic->numColors = 16;

  for (unsigned char r = 0; r <= 0xF; r++) {
    for (unsigned char g = 0; g <= 0xF; g++) {
      for (unsigned char b = 0; b <= 0xF; b++) {
	combos[index].a = 255;
	combos[index].r = r<<4;
	combos[index].g = g<<4;
	combos[index++].b = b<<4;
      }
    }
  }

  long big = totalCombinations*length;
  long b = 0;

  for (int x = 0; x < length; x++) {
    long benchmark = LONG_MAX;
    int bmIndex = 0;
    for (int i = 0; i < totalCombinations; i++, b++) {
      ic->palette[x] = combos[i];      
      fflush(stdout);
      printf("%c7", 27);
      fflush(stdout);
      printf(" %ld/%ld (%ld%%)", b, big, (b*100L)/big);
      fflush(stdout);
      printf("%c8", 27);
      fflush(stdout);
      long score = _score(ic);
      if (score < benchmark) {
	benchmark = score;
	bmIndex = i;
      }
    }
    ic->palette[x] = combos[bmIndex];

    
  }

  for (int i = 0; i < ic->numColors; i++) {
    printf("%d: ", i);
    color_print(ic->palette[i]);
    printf("\n");
  }
}


void
ham_process(imagecon_image_t* ic, char* outFilename)
{
  config.maxColors = 16;

  if (config.hamBruteForce) {

    _ham_bruteForcePalette(ic);
        
  } else {
   
    if (config.overridePalette) {
      palette_loadFile(ic);    
    }
    
    generateQuantizedImage(ic, config.overridePalette != 0);   
  }

  if (config.outputBitplanes) {
    _ham_outputBitplanes(ic, outFilename);
  }
 
  palette_output(ic, outFilename);  
}

