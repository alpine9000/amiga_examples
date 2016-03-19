Photon's bootloader
===================

In this example we take [020.shrinkler](../020.shrinkler) and convert it to use [Photon's bootloader](http://coppershade.org/asmskool/SOURCES/Photon-snippets/DDE5-BootLoader.S).

I hacked the [boot loader code](../shared/hardware_bootloader.s) just a little bit. Firstly I think some of the vasm optimisations messed with some of the code offsets that are assumed by Photon's code.  Secondly I modified it to be compatible with my previous bootloader.

The bootblock code is in [../shared/hardware_bootblock.s](../shared/hardware_bootblock.s), and will be the default bootblock I use going forward.

A new [Makefile](Makefile) config option has been added:

```
USERSTACK_ADDRESS=7fffc
```

Luckily the bootloader and shrinkler code still fit in the bootblock :-)

try it
------
  * [Download disk image](bin/photons_bootloader.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/photons_bootloader.adf" target="_blank">Run in SAE</a>
