
Shrinkler executable file compressor for Amiga by Blueberry

Designed for maximum compression of Amiga 64k and 4k intros, and
everything in between.

Executables for different platforms are available in their respective
subdirectories. The output executables are compatible with all Amiga CPUs
and kickstarts.

Run with no arguments for a list of options. For the options controlling
compression efficiency, higher values generally result in better
compression, at the cost of higher time and/or memory requirements.


History:

2015-01-18:  Version 4.4. Optimizations galore:
             New match finder based on a suffix array.
             New reference edge map based on a cuckoo hash table.
             Pre-compute number encoding sizes for faster estimation.
             Recycle references edges to save alloc/dealloc overhead.
             Updated defaults to take advantage of speed increase.
             Data file compression mode with decompression source.
             Fixed broken progress output for big files.
             Do not crash if text file could not be opened.

2015-01-05:  Version 4.3. Minor fixes:
             Usage information adjusted to fit within 77 columns.
             References discarded metric computed properly.
             First progress step is at 0.1% rather than 1.0%.
             Option to omit progress output (for non-ANSI consoles).
             Source changes for easier compilation with MSVC.

2014-12-16:  Version 4.2. For memory-efficient decrunching:
             Option to overlap compressed and decompressed data.
             Print memory overhead during and after decrunching.
             Verifier accepts partially filled hunks.

2014-02-08:  Version 4.1. Bug fixes and new features:
             Fixed some bugs in the range coder.
             Fixed handling of very small first hunk.
             Added internal verifier to check correctness of output.
             Print helpful text when encountering an internal error.
             Better error message when running out of memory.
             Set output file to be executable.
             New options to print text from an argument or file.
             New option to flash a hardware register during decrunching.

2014-01-05:  Version 4.0. First public release with new name.

1999 - 2012: Various public and internal versions.


Source code available from https://bitbucket.org/askeksa/shrinkler


For questions and comments, visit the ADA forum at

http://ada.untergrund.net/?p=boardthread&id=264

or write to blueberry at loonies dot dk.
