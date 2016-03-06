Extra half brite mode
=====================

[Extra half brite mode](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0098.html) allows us to use 32 colors as well as 32 "half brite" versions of those colors.

I basic supprt to [imagecon](../tools/imagecon) to output EHB mode data.  It doesn't really do a great job of taking advantage of the EHB mode.

The only changes I made to the asm code to allow EHB mode was to add the 6th bitplane and make sure the copper reset the extra bitplane pointer.

We can see from the output that it's not earth shatteringly different.  I think if you developed an image with EHB in mind, then imagecon would generate the correct data...  maybe ;-) I will test this at some stage.

64 extra half brite
-------------------
![6 bitplanes](screenshots/64-colors.png?raw=true)

32 colors
---------
![5 bitplanes](screenshots/32-colors.png?raw=true)

The differences
---------------
![image differences](screenshots/diff.png?raw=true)

[Download disk image](bin/ehb_mode.adf?raw=true)


