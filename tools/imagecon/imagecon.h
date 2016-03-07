#pragma once

#define MAX_PALETTE 32

typedef struct {

  int maxColors;
  int outputPalette;
  int outputPaletteAsm;
  int outputPaletteGrey;
  int outputMask;
  int outputBitplanes;
  int outputCopperList;
  int ehbMode;
  int hamMode;
  char* overridePalette;
  int quantize;
  int verbose;
  char** argv;
} imagecon_config_t;

#if 0
typedef struct {
  unsigned char r;
  unsigned char g;
  unsigned char b;
  unsigned char a;
} amiga_color_t;
#else
typedef struct {
  int r;
  int g;
  int b;
  int a;
} amiga_color_t;

#endif


typedef struct {
  int numColors;
  int width;
  int height;
  png_bytep* rowPointers;
  unsigned char* amigaImage;
  amiga_color_t palette[MAX_PALETTE*2]; // extra half brite mode
} imagecon_image_t;


extern imagecon_config_t config;
extern void abort_(const char * s, ...);
extern void png_read(char* file_name, imagecon_image_t* ic);
