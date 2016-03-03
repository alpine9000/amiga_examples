(re)Learning how to program an Amiga after a 20 year break
==========================================================
introduction
------------
This repo is not meant to be an amiga programming guide. If you're looking for the correct way to program an amiga, there are lots of other guides out there. These examples start where I left off around 1990. We had very bad programming habbits in those days.

I do however try to show exactly what is going on in each example. Wherever possible I try and use constants from the OS includes instead of magic custom addresses etc.

Where possible I will try and write development system programs that show how data is created/converted.

documentation
-------------
* [68000 instructions](http://68k.hax.com/)
* [vasm documentation](http://sun.hasenbraten.de/vasm/release/vasm.html)
* [vlink documentation (PDF)](http://sun.hasenbraten.de/vlink/release/vlink.pdf)
* [amiga registers](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0060.html)
* [amiga hardware reference manual](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0000.html)
* [amiga rkm devices manual](http://amigadev.elowar.com/read/ADCD_2.1/Devices_Manual_guide/node0000.html)
* [coppershade.org downloads](http://coppershade.org/articles/More!/Downloads/)
* [copper timing details](http://coppershade.org/articles/AMIGA/Agnus/Copper:_Exact_WAIT_Timing/)
* [coding forum](http://ada.untergrund.net/?p=boardforums&forum=4)
* [coding forum](http://eab.abime.net/forumdisplay.php?f=112)

cross development environment
-----------------------------

These examples are developed on a mac using the fantastic AmigaOS cross compiler for Linux / MacOSX / Windows.

   https://github.com/cahirwpz/amigaos-cross-toolchain

The support tools I have developed have additional requirements which you may not have on your system.

For a dump of what I did to install them see [installing the cross development environment](BuildingCrossDev.md)

building
--------

Build all examples by running ``make`` at the top level directory.

Each example will have an ADF file in it's ``bin`` directory.  These files can be loaded directly as DF0: on [FS-UAE](http://fs-uae.net/) or [Scripted Amiga Emulator](http://scriptedamigaemulator.net/) using the AROS ROM.

Invdivual examples can be built by entering the directory and running make:

  ```
# cd 001.simple_image
# make
```

tools
-----
The following tools have been developed to support the examples:

* [imagecon](tools/imagecon)
* [makeadf](tools/makeadf)

Each tool has a test to check if any changes you have made have broken basic functionality:

  ```
# cd tools/imagecon
# make test
______  ___   _____ _____ ___________
| ___ \/ _ \ /  ___/  ___|  ___|  _  \
| |_/ / /_\ \\ `--.\ `--.| |__ | | | |
|  __/|  _  | `--. \`--. \  __|| | | |
| |   | | | |/\__/ /\__/ / |___| |/ /
\_|   \_| |_/\____/\____/\____/|___/
#
```

or test all by running  ``make test`` at the top level

license
=======
Some of the code I have included in this repository is copyright by various authors and provided under various licenses. Copyright notices are preseved where possible.

Some of the tools use GPL licensed libraries which would mean they could only be distributed under the conditions of the respective version of the GPL.

All code without a copyright notice is probably in the public domain.
