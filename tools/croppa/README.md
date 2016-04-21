croppa
======

Crop images

usage
-----
```
    croppa:  --input <input.png> --output <output.png> --x <x> --y <y> --width <width> --height <height>
    options:
      --dx <dx> (default: width)
      --dy <dy> (default: height)
      --rows <num rows> (default: 1)
      --cols <num columns> (default: 1)
      --verbose
```

Crop will extract one or more images from a master image.

mandatory arguments
-------------------
**--input** &lt;input.png>

Specify the filename of the image to be resized.

**--output** &lt;output.png>

Specify the filename of the resized image file.

**--width** &lt;width>

Specify the width of the crop area in pixels.

**--height** &lt;height>

Specify the height of the crop area in pixels.

**--x** &lt;x>

Specify the x coordinate for the start of the crop in pixels.

**--y** &lt;x>

Specify the y coordinate for the start of the crop in pixels.


options
-------

**--dx** &lt;dx>

Specify the number of pixels added to x after each crop

**--dy** &lt;dy>

Specify the number of pixels added to y after each crop

**--rows** &lt;rows>

Specify the number rows of images that will be cropped (total number of images will be rows*cols)

**--cols** &lt;cols>

Specify the number columns of images that will be cropped (total number of images will be rows*cols)

**--verbose**

Display debugging information
