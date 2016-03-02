#pragma once

#define MAX_PALETTE 32

typedef struct {
  int width;
  int height;
  int maxColors;
  int outputPalette;
  char* overridePalette;
  int quantize;
  int verbose;
  char** argv;
} imagecon_config_t;

extern imagecon_config_t config;
extern void abort_(const char * s, ...);
extern png_bytep* png_read(char* file_name);
