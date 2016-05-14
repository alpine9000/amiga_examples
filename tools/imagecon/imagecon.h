#pragma once

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

#define MAX_PALETTE 32

#define RGB24TORGB12(x) (x >> 4)
#define CLAMP(x) (x > 255.0 ? 255.0 : (x < -255.0 ? -255.0 : x))
#define COLOR8(x) (x > 255.0 ? 255.0 : (x < 0.0 ? 0.0 : x))

typedef struct {
  int r;
  int g;
  int b;
  int a;
} amiga_color_t;

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
  int hamBruteForce;
  int slicedHam;
  int dither;
  char* overridePalette;
  amiga_color_t* maskTransparentColor;
  int paletteOffset;
  int fullColorPaletteFile;
  int quantize;
  int outputPng;
  int verbose;
  float darken;
  char** argv;  
} imagecon_config_t;


typedef struct {
  float r;
  float g;
  float b;
  float a;
} dither_color_t;

typedef struct {
  int control;
  int data;
  amiga_color_t pixel;
} ham_control_t;


typedef struct {
  int numColors;
  int width;
  int height;
  png_bytep* rowPointers;
  unsigned char* amigaImage;
  amiga_color_t palette[MAX_PALETTE*2]; // extra half brite mode
  dither_color_t* dithered;
} imagecon_image_t;


#include "color.h"
#include "dither.h"
#include "ham.h"
#include "file.h"
#include "palette.h"
#include "quant.h"
#include "utils.h"
#include "png.h"

extern imagecon_config_t config;

extern void 
abort_(const char * s, ...);

void
generateQuantizedImage(imagecon_image_t* ic, int usePalette);
