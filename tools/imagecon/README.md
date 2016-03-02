imagecon
========

Generate amiga data/files from a PNG image file.

usage
-----
```
    imagecon: --input <input.png> [options]
    Options:
      --output <output prefix>
      --colors <max colors>
      --quantize
      --output-palette
      --override-palette <palette file>
      --verbose
```

The following files will be generated:
1. <output prefix>.bin		binary interleave bitplane data
2. <output prefix>-copper-list.s 	m68k assembler syntax copper list with no symbols
3. <output prefix>.pal		(optional) palette file listing the palette colors as hex

options
-------
**--output** &lt;output prefix>
Specify the prefix for the output file set. Extentions will be added to this. Default is the input file name minus the extension.

**--colors** <max colors>>
Specify the maximum number of colors allowed in the palette. Acceptable values are from 2 to 32.

**--quantize**
Convert the image to use less colors.

**--output-palette**
Generate a palette file of the final palette used. Output will be the output file with the ".pal" extension.

**--override-palette** <palette file>>
Specify a palette file to use that will override the image or quantized palette. Also overrides the --colors option.

**--verbose**
Display debugging information

example
-------
```
    ./imagecon --input full_color.png --output image-data --quantize --colors 32 --palette
```
