#include "imagecon.h"

static void
_sham_generateLinePalette(imagecon_image_t* ic, int line);
static void
_sham_outputCopperLine(imagecon_image_t* ic, FILE* fp, int line);

static FILE* _copperFP;
static amiga_color_t *combos;
static int totalCombinations = 16*16*16;

static amiga_color_t
_sham_getHamColor(dither_data_t data)
{
  static int row = -1;
  
  if (row != data.y) {
    row = data.y;
    _sham_generateLinePalette(data.ic, row);
    _sham_outputCopperLine(data.ic, _copperFP, row);    
  }


  ham_control_t ham = ham_findClosestPixel(data.ic, data.color, data.last);
  return ham.pixel;
}


static ham_control_t* 
_sham_createHams(imagecon_image_t* ic)
{
  ham_control_t* hams = malloc(sizeof(ham_control_t)*ic->width*ic->height);

  for (int y = 0; y < ic->height; y++) {
    amiga_color_t lastPixel = { -1, -1, -1, -1};
    _sham_generateLinePalette(ic, y);
    for (int x = 0; x < ic->width; x++) {
      amiga_color_t orig = color_ditheredToAmiga(color_getDitheredPixel(ic, x, y));
      ham_control_t ham = ham_findClosestPixel(ic, orig, lastPixel);
      lastPixel = ham.pixel;
      hams[(y*ic->width)+x] = ham;
    }
  }

  return hams;
}

static int 
_score(imagecon_image_t* ic, int y)
{
  long error = 0;
  amiga_color_t lastPixel = { -1, -1, -1, -1};
  for (int x = 0; x < ic->width; x++) {
    amiga_color_t color = color_getOriginalPixel(ic, x, y);
    ham_control_t ham = ham_findClosestPixel(ic, color, lastPixel);
    error += color_delta(color, color_findClosestPalettePixel(ic, ham.pixel));
    lastPixel = ham.pixel;
  }

  return error;
}

static void
_sham_bruteForceInit(imagecon_image_t* ic)
{
  combos = malloc(sizeof(amiga_color_t)*totalCombinations);
  int index = 0;
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
}
static void
_sham_bruteForceLinePalette(imagecon_image_t* ic, int row)
{
  int length = 16;

  bzero(ic->palette, sizeof(ic->palette));
  ic->numColors = 16;

  int step = 1;
  long big = totalCombinations*length;
  long b = 0;

  for (int x = 0; x < length; x++) {
    long benchmark = LONG_MAX;
    int bmIndex = 0;
    for (int i = 0; i < totalCombinations; i+=step, b+=step) {
      ic->palette[x] = combos[i];      
      fflush(stdout);
      printf("%c7", 27);
      fflush(stdout);
      printf(" %03d %05ld/%05ld (%ld%%)", row, b, big, (b*100L)/big);
      fflush(stdout);
      printf("%c8", 27);
      fflush(stdout);
      long score = _score(ic, row);
      if (score < benchmark) {
	benchmark = score;
	bmIndex = i;
      }
    }
    ic->palette[x] = combos[bmIndex];

    
  }
}


static void
_sham_generateQuantizedLinePalette(imagecon_image_t* ic, int line)
{
  liq_attr *attr = liq_attr_create();

  void* ptr[1] = { &ic->rowPointers[line] };
  liq_image *image = liq_image_create_rgba_rows(attr, ptr, ic->width, 1, /* gamma */0.0);

  liq_set_max_colors(attr, config.maxColors);

  liq_color color = {.a = 255, .r = 0, .b = 0, .g = 0};
  liq_image_add_fixed_color(image, color);
  liq_result *res = liq_quantize_image(attr, image);
  
  const liq_palette *pal = liq_get_palette(res);

  if (config.verbose) {
    printf("_sham_generateQuantizedLinePalette: pal->count = %d\n", pal->count);
  }

  for (unsigned i = 0; i < pal->count; i++) {
    ic->palette[i].r = pal->entries[i].r;
    ic->palette[i].g = pal->entries[i].g;
    ic->palette[i].b = pal->entries[i].b;
    ic->palette[i].a = pal->entries[i].a;
  }

  for (unsigned i = 0; i < pal->count; i++) {
    if (ic->palette[i].r == 0 &&
	ic->palette[i].g == 0 &&
	ic->palette[i].b == 0 &&
	ic->palette[i].a == 255) {    

      if (i != 0) {
	amiga_color_t black = ic->palette[i];
	amiga_color_t other = ic->palette[0];
	ic->palette[0] = black;
	ic->palette[i] = other;
      }
      break;
    }
  }
  

  ic->numColors = pal->count;

  for (int i = 0; i < ic->numColors; i++) {
    if (config.verbose) {
      printf("%02d:  r=%03d g=%03d b=%03d a=%03d\n", i, ic->palette[i].r, ic->palette[i].g, ic->palette[i].b, ic->palette[i].a);
    }
  }

  liq_attr_destroy(attr);
  liq_image_destroy(image);
  liq_result_destroy(res);
}

static void
_sham_generateLinePalette(imagecon_image_t* ic, int line)
{
  if (config.hamBruteForce) {
    _sham_bruteForceLinePalette(ic, line);
  } else {
    _sham_generateQuantizedLinePalette(ic, line);
  }

}

static void
_sham_outputCopperLine(imagecon_image_t* ic, FILE* fp, int line)
{
  int endPos = 0xe1;

  line = line+0x2c-1;
  if (line <= 255) {
    fprintf(fp, "\tdc.w $%x,$fffe\n",(line)<<8|endPos|1);
  } else {
    fprintf(fp, "\tdc.w $%x,$fffe\n", ((line)-256)<<8|endPos|1);
  }

  for (int i = 1; i < ic->numColors; i++) {
    fprintf(fp, "\tdc.w $%x,$%x\n", 0x180+(i*2), RGB24TORGB12(ic->palette[i].r) << 8 | RGB24TORGB12(ic->palette[i].g) << 4 | RGB24TORGB12(ic->palette[i].b));
  }


}

static void
_sham_outputBitplanes(imagecon_image_t* ic, FILE* copperFP, FILE* bitplaneFP) 
{
 
  int numBitPlanes = 6;
  int byteWidth = (ic->width + 7) / 8;

  char** bitplanes = malloc(sizeof(void*)*numBitPlanes);
  for (int i = 0; i < numBitPlanes; i++) {
    bitplanes[i] = calloc(byteWidth*ic->height, 1);
  }

  ham_control_t* hams;

  if (config.dither) {
    dither_image(ic, _sham_getHamColor);
    hams = _sham_createHams(ic);
  } else {
    hams = malloc(sizeof(ham_control_t)*ic->width*ic->height);
    
    for (int y = 0; y < ic->height; y++) {
      _sham_generateLinePalette(ic, y);
      _sham_outputCopperLine(ic, copperFP, y);
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


  for (int y = 0; y < ic->height; y++) {
    for (int plane_index = 0; plane_index < numBitPlanes; plane_index++) {
      char* plane = bitplanes[plane_index];
      fwrite(&plane[y*byteWidth], byteWidth, 1, bitplaneFP);      
    }
  }
  

  if (config.verbose) {
    printf("done\n\n");
  }
}




void
sham_process(imagecon_image_t* ic, char* outFilename)
{
  config.maxColors = 16;

  _copperFP = file_openWrite("%s-sham-copper.s", outFilename);
  FILE* bitplaneFP = file_openWrite("%s-sham.bin", outFilename);

  if (config.hamBruteForce) {
    _sham_bruteForceInit(ic);
  } 

  if (config.outputBitplanes) {
    _sham_outputBitplanes(ic, _copperFP, bitplaneFP);
  }

  fclose(_copperFP);
  fclose(bitplaneFP);
}

