animate a blitter object
========================

Now we can finally do something slightly more interesting.

In this example we refactor the code a bit as now we have more going on.

In [blit.s](blit.s) we adapt the blit code from [008.shift_blit](../008.shift_blit) to be a slightly more general blit routine that can blit any 64x64 pixel object to any location as long as it's completely on the screen. If we try and blit off the screen the blitter will happily overwrite the adjacent ram with our blitter object's data.

The initialisation code is moved to [init.s](init.s). Other shared stuff is moved into [utils.s](utils.s). With only the main loop and glue left in the main file [anim_blit.s](anim_blit.s). Constants have been moved to [constants.i](constants.i).

The main loop moves the object around the screen.

We don't yet clear the background before each blit, so we get a nice trail. Also there is no double buffering.

[Download disk image](bin/anim_blit.adf?raw=true)

Screenshot:

![Screenshot](screenshot.png?raw=true)
