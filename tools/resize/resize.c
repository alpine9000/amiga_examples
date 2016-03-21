#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <magick/api.h>
#include <getopt.h>

typedef struct {
  int verbose;
  int width;
  int height;
  int interlaced;
  float blur;
  char** argv;
} config_t;

typedef struct {
  Image *image;
  Image *resizeImage;
  Image *croppedImage;  
  ImageInfo *imageInfo;
} image_t;

image_t image = {0};
config_t config = {.blur = 0.75};

void
cleanup()
{
  if (image.image != (Image *) NULL) {
    DestroyImage(image.image);
  }

  if (image.resizeImage != (Image *)NULL) {
    DestroyImage(image.resizeImage);
  }

  if (image.croppedImage != (Image *)NULL) {
    DestroyImage(image.croppedImage);
  }

  if (image.imageInfo != (ImageInfo *) NULL) {
    DestroyImageInfo(image.imageInfo);
  }
  DestroyMagick();
}

void 
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

void
usage()
{
  fprintf(stderr, 
	  "%s:  --input <input.png> --output <output.png> --width <width> --height <height> \n"\
	  "options:\n"\
	  "  --blur <blur>\n"\
	  "  --interlaced\n"\
	  "  --verbose\n", config.argv[0]);
  exit(1);
}

int 
main(int argc, char **argv)
{
  int c;
  char* inputFile = 0;
  char* outputFile = 0;

  ExceptionInfo  exception;

  config.argv = argv;

  InitializeMagick(NULL);
  image.imageInfo=CloneImageInfo(0);
  GetExceptionInfo(&exception);
  
  while (1) {
    static struct option long_options[] = {
      {"verbose", no_argument, &config.verbose, 1},
      {"interlaced", no_argument, &config.interlaced, 1},
      {"width",  required_argument, 0, 'w'},
      {"height",  required_argument, 0, 'h'},
      {"blur",  required_argument, 0, 'b'},
      {"output",  required_argument, 0, 'o'},
      {"input",   required_argument, 0, 'i'},
      {0, 0, 0, 0}
    };
    
    int option_index = 0;

    
    c = getopt_long (argc, argv, "o:i:w:h:b:", long_options, &option_index);
    
    if (c == -1)
      break;
    
    switch (c) {
    case 0:
      break;
    case 'i':
      inputFile = optarg;
      break;	
    case 'o':
      outputFile = optarg;
      break;	
    case 'w':
      if (sscanf(optarg, "%d", &config.width) != 1) {
	abort_("invalid width");
      }
      break;	      
    case 'h':
      if (sscanf(optarg, "%d", &config.height) != 1) {
	abort_("invalid height");
      }
      break;
    case 'b':
      if (sscanf(optarg, "%f", &config.blur) != 1) {
	abort_("invalid height");
      }
      break;	      
    case '?':
      usage();
      break;	
    default:
      usage();
      break;
    }
  }

  
  if (inputFile == 0 || outputFile == 0 || config.width == 0 || config.height == 0) {
    usage();
    abort();
  }


  (void) strcpy(image.imageInfo->filename, inputFile);
  image.image = ReadImage(image.imageInfo, &exception);
  if (image.image == (Image *) NULL) {
    CatchException(&exception);
    abort_("Failed to read image %s\n", inputFile);
  }

  int width = image.image->columns;
  int height = image.image->rows;

  float wScale = 1.0;
  float hScale = 1.0;
  float configRatio = (float)config.width/(config.interlaced ? (float)config.height/2.0 : (float)config.height);
  int newWidth = config.width;
  int newHeight = config.height;
  
  if (config.verbose) {
    printf("width = %d, height = %d ratio = %f\n", width, height, (float)width/(float)height);
    printf("config.width = %d, config.height = %d configRatio = %f\n", config.width, config.height, configRatio);
  }

  float ratio = (float)width/(float)height;
  wScale = (float)height/(float)config.height;
  hScale = (float)width/(float)config.width;
  
  if (ratio >= configRatio) {
    newWidth = width/wScale;
  } else {

    newHeight = height/hScale;
    if (config.interlaced) {
      newHeight *= 2;
      newWidth *= 2;
    }
  }

  if (config.verbose) {
    printf("wScale = %f\n", wScale);
    printf("hScale = %f\n", hScale);
    printf("newWidth -> %d\n", newWidth);
    printf("newHeight -> %d\n", newHeight);
  }

  image.resizeImage=ResizeImage(image.image, newWidth/(config.interlaced?2:1), newHeight,
			   //GaussianFilter,
			   //BoxFilter,
			   //TriangleFilter,
			   //HermiteFilter,
			   //HanningFilter,
			   //HammingFilter,
			   //BlackmanFilter,
			   //GaussianFilter,
			   //QuadraticFilter,
			   //CubicFilter,
			   //CatromFilter,
			   //MitchellFilter,
			   //LanczosFilter,
			   BesselFilter,
			   //SincFilter,
			   config.blur, &exception);

  RectangleInfo rect = {
    .x = ((newWidth/(config.interlaced?2:1))-config.width)/2,
    .y = (newHeight-config.height)/2,
    .width = config.width,
    .height = config.height
  };

  if (config.verbose) {
    printf("%ld %ld %ld %ld\n", rect.x, rect.y, rect.width, rect.height);
  }

  image.croppedImage = CropImage(image.resizeImage, &rect, &exception);

  strcpy(image.croppedImage->filename, outputFile);

  if (!WriteImage(image.imageInfo, image.croppedImage)) {
    CatchException(&image.croppedImage->exception);
    abort_("Failed to write image %d\n", outputFile);
  }

  cleanup();

  return 0;
}
