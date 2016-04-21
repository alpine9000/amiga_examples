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
  int x;
  int y;
  int dx;
  int dy;
  int rows;
  int cols;
  char** argv;
} config_t;

typedef struct {
  Image *image;
  Image *croppedImage;  
  ImageInfo *imageInfo;
} image_t;

image_t image = {0};
config_t config = { 
  .rows = 1,
  .cols = 1,
  .verbose = 0
};

void
cleanup()
{
  if (image.image != (Image *) NULL) {
    DestroyImage(image.image);
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
	  "%s:  --input <input.png> --output <output.png> --x <x> --y <y> --width <width> --height <height> \n"\
	  "options:\n"\
	  "  --dx <dx> (default: width)\n"\
	  "  --dy <dy> (default: height)\n"\
	  "  --rows <num rows> (default: 1)\n"\
	  "  --cols <num columns> (default: 1)\n"\
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
      {"width",  required_argument, 0, 'w'},
      {"height",  required_argument, 0, 'h'},
      {"output",  required_argument, 0, 'o'},
      {"input",   required_argument, 0, 'i'},
      {"x",   required_argument, 0, 'x'},
      {"y",   required_argument, 0, 'y'},
      {"dx",   required_argument, 0, 'd'},
      {"dy",   required_argument, 0, 'f'},
      {"rows",   required_argument, 0, 'r'},
      {"cols",   required_argument, 0, 'c'},
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
    case 'x':
      if (sscanf(optarg, "%d", &config.x) != 1) {
	abort_("invalid x");
      }
      break;	      
    case 'y':
      if (sscanf(optarg, "%d", &config.y) != 1) {
	abort_("invalid x");
      }
      break;	      
    case 'd':
      if (sscanf(optarg, "%d", &config.dx) != 1) {
	abort_("invalid dx");
      }
      break;	      
    case 'f':
      if (sscanf(optarg, "%d", &config.dy) != 1) {
	abort_("invalid dy");
      }
      break;	      
    case 'r':
      if (sscanf(optarg, "%d", &config.rows) != 1) {
	abort_("invalid rows");
      }
      break;	      
    case 'c':
      if (sscanf(optarg, "%d", &config.cols) != 1) {
	abort_("invalid cols");
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

  if (config.dx == 0 ) {
    config.dx = config.width;
  }

  if (config.dy == 0 ) {
    config.dy = config.height;
  }

  if (config.verbose) {
    printf("x: %d, y: %d\n", config.x, config.y);
    printf("dx: %d, dy: %d\n", config.dx, config.dy);
    printf("width: %d, height: %d\n", config.width, config.height);
    printf("rows: %d, cols: %d\n", config.rows, config.cols);
  }

  (void) strcpy(image.imageInfo->filename, inputFile);
  image.image = ReadImage(image.imageInfo, &exception);
  if (image.image == (Image *) NULL) {
    CatchException(&exception);
    abort_("Failed to read image %s\n", inputFile);
  }


  for (int x = config.x, count = 0; x < config.x+(config.cols*config.dx); x += config.dx) {
    for (int y = config.y; y < config.y+(config.rows*config.dy); y += config.dy, count++) {
      RectangleInfo rect = {
	.x = x,
	.y =  y,
	.width = config.width,
	.height = config.height
      };
      
      if (config.verbose) {
	printf("row %d cols %d %ld %ld %ld %ld\n", (y-config.y)/config.dy, (x-config.x)/config.dx, rect.x, rect.y, rect.width, rect.height);
      }
      
      image.croppedImage = CropImage(image.image, &rect, &exception);

      if (config.rows > 1 || config.cols > 1) {
	sprintf(image.croppedImage->filename, "%s-%d.png", outputFile, count);
      } else {
	strcpy(image.croppedImage->filename, outputFile);
      }

      if (!WriteImage(image.imageInfo, image.croppedImage)) {
	CatchException(&image.croppedImage->exception);
	abort_("Failed to write image %d\n", outputFile);
      }

      if (image.croppedImage != (Image *)NULL) {
	DestroyImage(image.croppedImage);
      }      
    }
  }

  cleanup();

  return 0;
}
