Copper bars
===========

Now I discover how vertical copper waiting works.

Some notes:
1. The first line is copper address $2c
2. The last last is copper address $2c + 256 (screen height) = $12c

At copper line 255 ($FF), we run out of bits in the copper wait instruction, so if we want to wait for lines after this, we need to wait for a wrapped value. [See here](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node004D.html)

[copper_gen.c](copper_gen.c) will generate a copper list with horizontal bars. See http://krazydad.com/tutorials/makecolors.php for details on the algorithm used to generate the bars.  You can generate all sorts of different kinds of patterns by changing the algorithm parameters.