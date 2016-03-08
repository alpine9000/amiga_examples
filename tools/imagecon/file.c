#include "imagecon.h"

FILE * 
file_openWrite(const char * s, ...)
{
  char buffer[4096];
  va_list args;
  va_start(args, s);
  vsprintf(buffer, s, args);
  va_end(args);

  if (config.verbose) {
    printf("Opening %s for writing\n", buffer);
  }

  FILE* fp = fopen(buffer, "w+");
  if (!fp) {
    abort_("Failed to open %s for writing\n", buffer);
  }
  return fp;
}


FILE * 
file_openRead(const char * s, ...)
{
  char buffer[4096];
  va_list args;
  va_start(args, s);
  vsprintf(buffer, s, args);
  va_end(args);

  FILE* fp = fopen(buffer, "r");
  if (!fp) {
    abort_("Failed to open %s for reading\n", buffer);
  }
  return fp;
}

