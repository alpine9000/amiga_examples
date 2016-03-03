#pragma once

#define MAX_PALETTE 32

typedef struct {

  int maxColors;
  int outputPalette;
  int outputPaletteAsm;
  int outputMask;
  int outputBitplanes;
  int outputCopperList;
  char* overridePalette;
  int quantize;
  int verbose;
  char** argv;
} imagecon_config_t;

typedef struct {
  unsigned char r;
  unsigned char g;
  unsigned char b;
  unsigned char a;
} amiga_color_t;


typedef struct {
  int numColors;
  int width;
  int height;
  png_bytep* rowPointers;
  unsigned char* amigaImage;
  amiga_color_t palette[MAX_PALETTE];
} imagecon_image_t;


extern imagecon_config_t config;
extern void abort_(const char * s, ...);
extern void png_read(char* file_name, imagecon_image_t* ic);
