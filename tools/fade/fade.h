#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <getopt.h>
#include <stdarg.h>

typedef struct {
  int verbose;
  int numColors;
  int fromGrey;
  int fromBlack;
  int steps;
  char* toFile;
  char* fromFile;
  char* output;
  char** argv;
} config_t;


extern config_t config;

extern void 
abort_(const char * s, ...);
