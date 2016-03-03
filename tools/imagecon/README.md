imagecon
========

Generate amiga data/files from a PNG image file.

usage
-----
```
    imagecon: --input <input1.png,input2.png...> [options]
    options:
      --output <output prefix>
      --colors <max colors>
      --quantize
      --output-palette
      --output-bitplanes
      --output-mask
      --output-copperlist
      --use-palette <palette file>
      --verbose
```

The following files can be generated:

1. **&lt;output prefix>.bin** binary interleave bitplane data
2. **&lt;output prefix>-copper-list.s**	m68k assembler syntax copper list with no symbols
3. **&lt;output prefix>.pal** palette file listing the palette colors as hex
3. **&lt;output prefix>-mask.bin** binary interleave bitplane mask

options
-------
**--input** i&ltnput1.png,input2.png...>

Specify the file(s) to be processed. Multiple files are coma separated. If bitplane output is directed, the bitplane data is stacked vertically. For images that need right padding, each line is right padded with the pixel in coloumn zero of that line.

**--output** &lt;output prefix>

Specify the prefix for the output file set. Extentions will be added to this. Default is the input file name minus the extension.

**--colors** &lt;max colors>

Specify the maximum number of colors allowed in the palette. Acceptable values are from 2 to 32.

**--quantize**

Convert the image to use less colors.

**--output-bitplanes**

Output the binary bitplane data in interleaved format

**--output-copperlist**

Output the copper is as a series of m68k instructions (No labels are generated)

**--output-mask**

Output the binary bitplane data for use as a blitter source mask

**--output-palette**

Generate a palette file of the final palette used. Output will be the output file with the ".pal" extension.

**--use-palette** &lt;palette file>

Specify a palette file to use that will override the image or quantized palette.  Overrides the --colors and --quantize options.

**--verbose**

Display debugging information

example
-------

Create a copper list and bitplane data file with an automatically generate 32 color palette.
```
    ./imagecon --input full_color.png --output image-data --quantize --colors 32 --output-bitplanes --output-copperlist
```

Create a shared palette based on two files, then use that palette to generate image and copper list data for each file.
```
    ./imagecon --input file1.png,file2.png --output shared --quantize --colors 32 --output-palette
    ./imagecon --input file1.png --output file1 --override-palette shared.pal --output-bitplanes --output-copperlist
    ./imagecon --input file2.png --output file2 --override-palette shared.pal --output-bitplanes --output-copperlist
```
