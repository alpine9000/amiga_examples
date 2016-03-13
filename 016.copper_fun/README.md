copper fun
==========

In this example I extract a series of PNG files from an animated gif using ImageMagik convert (You will need to install ImageMagik to try this one).

Next a shell script [convert.sh](convert.sh) calls a C program [copper_fun_generate.c](copper_fun_generate.c) that resizes the PNG to 52x276 pixels, then converts this into a copper list that changes the color at the corresponding beam position to try and re-create the image.

Finally in the asm code [copper_fun.s] we cycle through the copper lists to make an animation.

Obviously this is the lease efficent way to generate a super low res animation, however it's way fun :-)

There are two configurations:

      1.  A pattern that will run an 512mb chip ram
   
       ```
 # make
```

      2. A video that needs 1bm chip ram
	
       ```
 # make video
```

screenshots
-----------
![Screenshot](screenshots/screenshot.png?raw=true)

![Screenshot](screenshots/video.png?raw=true)

try it
------
  * [Download disk image](bin/copper_fun.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/copper_fun.adf" target="_blank">Run in SAE</a>
