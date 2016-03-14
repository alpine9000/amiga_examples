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
      --output-palette-asm
      --output-grey-palette-asm
      --output-bitplanes
      --output-mask
      --output-copperlist
      --output-png
      --extra-half-brite
      --ham
      --ham-brute-force
      --dither
      --use-palette <palette file>
      --verbose
```

The following files can be generated:

1. **&lt;output prefix>.bin** binary interleaved bitplane data
2. **&lt;output prefix>-ham.bin** binary interleaved bitplane data for --ham mode
3. **&lt;output prefix>-copper-list.s**	m68k assembler syntax copper list with no symbols
4. **&lt;output prefix>-palette.s**	m68k assembler syntax code to install the color palette (preserves all registers)
5. **&lt;output prefix>.pal** palette file listing the palette colors as hex
6. **&lt;output prefix>-mask.bin** binary interleaved bitplane mask
7. **&lt;output prefix>-converted.png** paletted PNG version of converted file

options
-------
**--input** &lt;input1.png,input2.png...>

Specify the file(s) to be processed. Multiple files are comma separated. If bitplane output is directed, the bitplane data is stacked vertically. For images that need right padding, each line is right padded with the pixel in coloumn zero of that line.

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

Output the binary bitplane data for use as a blitter source mask. Note: Be careful using this feature combined with color quantization. It's possible the transparent color might get quantized resulting in an bad mask.

**--output-palette**

Generate a palette file of the final palette used. Output will be the output file with the ".pal" extension.

**--output-palette-asm**

Generate m68k assembler instructions to install the palette. No symbols are generated. Registers are preserved.

**--output-grey-palette-asm**

Generate m68k assembler instructions to install a greyscale version of the palette. No symbols are generated. Registers are preserved.

**--output-png**

Generate a paletted PNG file based on the final converted data.


**--extra-half-brite**

Generate an extra half brite image. This only works in combination with --colors 32. A 32 color palette will be output, however there will be a sixth bitplane that includes the half brite control bits for any pixels that can use it.

**--ham**

Generate bitplane and palette data for the OCS HAM mode.

**--ham-brute-force**

Use a primitive brute force method to calculate the HAM base palette (Otherwise --quantize --colors 16 will be used).

**--dither**

Apply additional dithering to the image.

**--use-palette** &lt;palette file>

Specify a palette file to use that will override the image or quantized palette.  Overrides the --colors and --quantize options.

**--verbose**

Display debugging information

example
-------

Create a copper list and bitplane data file with an automatically generated 32 color palette.
```
    ./imagecon --input full_color.png --output image-data --quantize --colors 32 --output-bitplanes --output-copperlist
```

Create a shared palette based on two files, then use that palette to generate image and copper list data for each file.
```
    ./imagecon --input file1.png,file2.png --output shared --quantize --colors 32 --output-palette
    ./imagecon --input file1.png --output file1 --use-palette shared.pal --output-bitplanes --output-copperlist
    ./imagecon --input file2.png --output file2 --use-palette shared.pal --output-bitplanes --output-copperlist
```


Create dithered HAM data
```
    ./imagecon --input full_color.png --output ham --ham --dither
```
