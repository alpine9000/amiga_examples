perform a shifted blit
======================

Extending [007.masked_blit](../007.masked_blit), we now add the capability to blit to non word aligned columns.

The blitter can only address word aligned screen positions. This makes drawing something on a non word aligned boundary slightly more complex.

So the algorithm for drawing to non word aligned boundaries is as follows:
   1. The destination address is the word aligned address to the left of the desired position.
   2. Command the blitter to blit an extra word to the right of our blitter object.
   3. We mask the trailing word of each line to prevent the extra word from being blit.
   4. We shift the data by the difference in bits between the desired column and the word aligned column from (1).
   5. We make the line modulos #-2 so blitter object data is correctly fetched.
   


[Download disk image](bin/shift_blit.adf?raw=true)

Screenshot:

![Screenshot](screenshot.png?raw=true)

Masked blit screenshot for reference:

![Screenshot](../007.masked_blit/screenshot.png?raw=true)

