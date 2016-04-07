#pragma once

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>
#include <getopt.h>
#include <libgen.h>

#include <tmx.h>
#include "utils.h"
#include "file.h"

#define str_bool(b) (b==0? "false": "true")

typedef struct {
  int verbose;
  char* inputFile;
  char** argv;
  int bitDepth;
} config_t;

extern config_t config;
