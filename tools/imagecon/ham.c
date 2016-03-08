#include "imagecon.h"

static void
_ham_outputBitplanes(char* outFilename, imagecon_image_t* ic)
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
    dither_image(ic, dither_getHamColor);
    hams = dither_createHams(ic);
  } else {
    hams = malloc(sizeof(ham_control_t)*ic->width*ic->height);
    
    for (int y = 0; y < ic->height; y++) {
      amiga_color_t lastPixel = { -1, -1, -1, -1};
      for (int x = 0; x < ic->width; x++) {
	amiga_color_t orig = color_getOriginalPixel(ic, x, y);
	ham_control_t ham = color_findClosestHamPixel(ic, orig, lastPixel);
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

#if 0
void
ham_process(char* outFilename, imagecon_image_t* ic)
{
  config.maxColors = 256;
  generateQuantizedImage(ic, 0);
  dither_image(ic, dither_getPalettedColor);
  dither_transferToPaletted(ic);    
  color_transferPalettedToOriginal(ic);

  config.maxColors = 16;
  generateQuantizedImage(ic, 0);
 

  if (config.outputBitplanes) {
    _ham_outputBitplanes(outFilename, ic);
  }
  
  palette_output(outFilename, ic);  
}

#else
void
ham_process(char* outFilename, imagecon_image_t* ic)
{
  config.maxColors = 16;
  generateQuantizedImage(ic, 0);

  if (config.outputBitplanes) {
    _ham_outputBitplanes(outFilename, ic);
  }
  
  palette_output(outFilename, ic);  
}
#endif
