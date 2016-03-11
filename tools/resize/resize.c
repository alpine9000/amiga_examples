#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <magick/api.h>

int 
main(int argc, char **argv)
{
  Image *image = 0, *resizeImage = 0, *croppedImage = 0;
  char infile[MaxTextExtent];
  char outfile[MaxTextExtent];
  int arg = 1, exit_status = 0;
  ImageInfo *imageInfo;
  ExceptionInfo  exception;

  InitializeMagick(NULL);
  imageInfo=CloneImageInfo(0);
  GetExceptionInfo(&exception);
  
#if 0
  const int targetWidth = 320;
  const int targetHeight = 256;
  const int interlaced = 0;
  const float blur = 0.75;
#else
  const int targetWidth = 320;
  const int targetHeight = 512;
  const int interlaced = 1;
  const float blur = 0.75;
#endif
  
  if (argc != 3) {
    (void) fprintf ( stderr, "Usage: %s infile outfile\n", argv[0] );
    (void) fflush(stderr);
    exit_status = 1;
    goto program_exit;
  }

  (void) strncpy(infile, argv[arg], MaxTextExtent-1 );
  arg++;
  (void) strncpy(outfile, argv[arg], MaxTextExtent-1 );

  (void) strcpy(imageInfo->filename, infile);
  image = ReadImage(imageInfo, &exception);
  if (image == (Image *) NULL) {
    CatchException(&exception);
    exit_status = 1;
    goto program_exit;
  }

  int width = image->columns;
  int height = image->rows;

  float scale = (float)height/(float)targetHeight;
  int newWidth = width/scale;

  resizeImage=ResizeImage(image, newWidth/(interlaced?2:1), targetHeight,
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
			   blur, &exception);

  RectangleInfo rect = {
    .x = ((newWidth/(interlaced?2:1))-targetWidth)/2,
    .y = 0,
    .width = targetWidth,
    .height = targetHeight
  };

  croppedImage = CropImage(resizeImage, &rect, &exception);

  (void) strcpy(croppedImage->filename, outfile);
  if (!WriteImage (imageInfo, croppedImage))
    {
      CatchException(&croppedImage->exception);
      exit_status = 1;
      goto program_exit;
    }

 program_exit:

  if (image != (Image *) NULL)
    DestroyImage(image);

  if (resizeImage != (Image *)NULL)
    DestroyImage(resizeImage);

  if (croppedImage != (Image *)NULL)
    DestroyImage(croppedImage);

  if (imageInfo != (ImageInfo *) NULL)
    DestroyImageInfo(imageInfo);
  DestroyMagick();

  return exit_status;
}
