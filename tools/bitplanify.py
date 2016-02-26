#!/usr/bin/env python

import sys
import math
from PIL import Image
from bitmap import (
    image_to_bitplanes,
    write_bitplane,
    write_interleaved,
    to_amiga_colors,
)


def main(args):
    source_file = args.source
    bit_depth = args.depth
    verbose = args.verbose

    img = Image.open(source_file)
    if img.mode != 'P':
        print 'Image is not palette-based'
        sys.exit(1)

    palette = img.getpalette()  # always 256*3 values
    if not bit_depth:
        max_index = img.getextrema()[1]
        bit_depth = int(math.log(max_index) / math.log(2)) + 1
        if verbose:
            print 'Maximum palette index used: %d: assuming bit depth %d' % (max_index, bit_depth)

    amiga_palette = to_amiga_colors(
        palette[:(1 << bit_depth) * 3]
    )

    width, height = img.size
    if (width & 7) != 0:
        print 'Width is not divisable by 8:', width
        sys.exit(1)

    bitmap_image = image_to_bitplanes(img, bit_depth)
    if verbose:
        print 'Image width: %d pixels = %d bytes. Height: %d pixels' % (
            width, bitmap_image.byte_width, height)

    if args.separate:
        for plane_index in range(bit_depth):
            with open(args.out % (plane_index + 1), 'wb') as out:
                write_bitplane(out, bitmap_image, plane_index)
    else:
        with open(args.out, 'wb') as out:
            write_interleaved(out, bitmap_image)

    if args.copper:
        with open(args.copper, 'w') as out:
            for index, rgb in enumerate(amiga_palette):
                out.write('\tdc.w\t$%x,$%03x\n' % (0x180 + index * 2, rgb))

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Convert an image to Amiga bitplanes')
    parser.add_argument(
        '--depth', metavar='N', type=int, default=None,
        help='Set number of bitplanes in output')
    parser.add_argument(
        '--copper',
        help='Write palette as copper source code (default is to auto-detect)')
    parser.add_argument(
        '--separate', action='store_true',
        help='Write one bitplane per file. Use %%s in filename as replacement for bitplane number.')
    parser.add_argument(
        '--verbose', '-v', action='store_true',
        help='Write more information to stdout')
    parser.add_argument('source', metavar='IMAGE_FILE',
        help='Image file to convert to bitplanes')
    parser.add_argument('out', metavar='BITPLANES_FILE',
        help='File to write bitmaps to')

    args = parser.parse_args()
    main(args)
