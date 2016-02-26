from array import array


class BitplaneImage(object):
    def __init__(self, byte_width, height, bitplanes):
        self.byte_width = byte_width
        self.height = height
        self.bitplanes = bitplanes


def image_to_bitplanes(image, bit_depth):
    """
    Convert a PIL image into bitplanes.

    Returns a bitmap image.
    """
    bitplanes = [array('c') for _ in xrange(bit_depth)]
    width, height = image.size
    byte_width = (width + 7) // 8

    for row in xrange(height):
        for byte in xrange(byte_width):
            planes = [0] * bit_depth
            for bit in xrange(8):
                palette_index = image.getpixel((byte * 8 + 7 - bit, row))
                for plane_index in range(bit_depth):
                    planes[plane_index] |= ((palette_index >> plane_index) & 1) << bit
            for plane_index in range(bit_depth):
                bitplanes[plane_index].append(chr(planes[plane_index]))

    return BitplaneImage(byte_width, height, bitplanes)


def write_interleaved(file, image):
    """Write all bitplanes in interleaved mode to a file."""
    for row in xrange(image.height):
        offset = row * image.byte_width
        for plane in image.bitplanes:
            plane[offset:offset + image.byte_width].write(file)


def write_bitplane(file, image, bitplane_index):
    """Write a single bitplane to a file."""
    image.bitplanes[bitplane_index].write(file)


def to_amiga_colors(palette):
    """
    Convert 24 bit colors to Amiga 12 bit colors.
    palette is a sequence of integers: [r, g, b, ...]
    """
    number_of_colors = len(palette) // 3
    amiga_colors = []
    for color_index in xrange(number_of_colors):
        r, g, b = [c for c in palette[color_index * 3:(color_index + 1) * 3]]
        rgb = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4)
        amiga_colors.append(rgb)

    return amiga_colors
