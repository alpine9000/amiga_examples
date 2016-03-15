makeadf
=======

The simplest form of ADF creation.

Disk layout must be handled by the assembler/linker.  This tool only calculates the checksum and pads the disk image to the correct size.

This code is taken from [this forum post](http://eab.abime.net/showpost.php?p=895070&postcount=6)

Slightly modified to bork if the input file exceeds the standard amiga disk size.
