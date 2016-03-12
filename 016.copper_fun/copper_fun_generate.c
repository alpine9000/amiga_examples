#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <magick/api.h>

#define TOP          16
#define HEIGHT       256+TOP
#define COPPER_WIDTH 52

typedef struct {
  char** argv;
  float blur;
  int debug;
} config_t;

typedef struct {
  Image *image;
  Image *resizeImage;
  ImageInfo *imageInfo;
} image_t;

image_t image = {0};
config_t config = {.blur = 1.0, .debug=0};

static void
cleanup()
{
  if (image.image != (Image *) NULL) {
    DestroyImage(image.image);
  }

  if (image.resizeImage != (Image *)NULL) {
    DestroyImage(image.resizeImage);
  }


  if (image.imageInfo != (ImageInfo *) NULL) {
    DestroyImageInfo(image.imageInfo);
  }
  DestroyMagick();
}


static void 
abort_(const char * s, ...)
{
  fprintf(stderr, "%s: ", config.argv[0]);
  va_list args;
  va_start(args, s);
  vfprintf(stderr, s, args);
  fprintf(stderr, "\n");
  va_end(args);
  cleanup();
  exit(1);
}


static void
getframedata(char* inputFile)
{
  ExceptionInfo  exception;
  InitializeMagick(NULL);
  image.imageInfo=CloneImageInfo(0);
  GetExceptionInfo(&exception);
  char* outputFile = "resized.png";

  (void) strcpy(image.imageInfo->filename, inputFile);
  image.image = ReadImage(image.imageInfo, &exception);
  if (image.image == (Image *) NULL) {
    CatchException(&exception);
    abort_("Failed to read image %s\n", inputFile);
  }

  int width = COPPER_WIDTH-8;
  int height = HEIGHT;

  image.resizeImage=ResizeImage(image.image, width, height, BesselFilter, config.blur, &exception);

  strcpy(image.resizeImage->filename, outputFile);

  if (config.debug) {
    if (!WriteImage(image.imageInfo, image.resizeImage)) {
      CatchException(&image.resizeImage->exception);
      abort_("Failed to write image %d\n", outputFile);
    }
  }
}


int 
main(int argc, char** argv)
{
  config.argv = argv;
  getframedata(argv[1]);

  int startLine = 0x2c-TOP;
  int endLine = startLine+HEIGHT;
  int startHpos = 6+8;
  int i, line;

  for (line = startLine; line < endLine; ++line) {
    if (line <= 255) {
      printf("\tdc.w $%x,$fffe\n",line<<8|startHpos|1);
    } else {
       printf("\tdc.w $%x,$fffe\n", (line-256)<<8|startHpos|1);
    }

    int endw = COPPER_WIDTH;
    if (line == 255) {
      endw = 50;
    }

    for (i = 0; i < endw; i++) {
      PixelPacket pixel = GetOnePixel(image.resizeImage, i-10, line-startLine);
      printf("\tdc.w COLOR00,$%x%x%x\n", pixel.red>>4, pixel.green>>4, pixel.blue>>4);
    }

    if (line == 255) {
      printf("\tdc.w $%x,$fffe\n",line<<8|0xe1|1);
    }
  }

  cleanup();

  return 0;
}
