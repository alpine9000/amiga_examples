resize
======

Nicely resize images

usage
-----
```
    rezize:  --input <input.png> --output <output.png> --width <width> --height <height>
    options:
      --blur <blur>
      --interlaced
      --verbose
```

resize will resize images using filtering to try and make the resampled output still look good. It currently is hard coded to use a BesselFilter. Although by hacking the source you could use any of these filters:

       * BoxFilter
       * TriangleFilter
       * HermiteFilter
       * HanningFilter
       * HammingFilter
       * BlackmanFilter
       * GaussianFilter
       * QuadraticFilter
       * CubicFilter
       * CatromFilter
       * MitchellFilter
       * LanczosFilter
       * BesselFilter
       * SincFilter

resize will maintain the correct aspect ratio for the selected output dimensions.  It does this by cutting the largest section of the resized image from the centre that maintains this ratio.

mandatory arguments
-------------------
**--input** &lt;input.png>

Specify the filename of the image to be resized.

**--output** &lt;output.png>

Specify the filename of the resized image file.

**--width** &lt;width>

Specify the new width in pixels.

**--height** &lt;height>

Specify the new height in pixels.

options
-------

**--interlaced**

Generated output suitable for an interlaced display. The aspect ratio will be adjusted for double the vertical resolution. Specify the dimensions of the bitplane data (eg --width=320 --height=512).

**--blur** &lt;blur>

Specify the blur factor to be applied. 0 is no blur. 0.75 looks good for most reductions.

**--verbose**

Display debugging information
