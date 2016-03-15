shrinking with shinkler
=======================

In this example I try to integrate the amazing and generally super awsome Shrinkler exe shrinker.

   * [Source repository](https://bitbucket.org/askeksa/shrinkler)
   * [Forum thread with discussion] (http://ada.untergrund.net/?p=boardthread&id=264&page=0)

This is a pretty cool bit of kit.  I think you can just point an exe at it and it will produce a compressed version of the exe that it runnable. Seeing as all my examples are based on a trackloaded setup, we use it slightly differently.

We shrink the "program" that our trackloaded loads as if it were data:

   ```
   Shrinkler -d out/main.bin out/shrunk.bin
```

Shrinker does a very impressive job of shrinking data:


```
Crunching...

Original  After 1st pass  After 2nd pass
   51752       27545.297       26682.832
```

For comparison:

```
# gzip out/main.bin
# ls -l out/main.bin.gz
-rwxr-xr-x  1 alpine  staff  29811 Mar 16 06:04 main.bin.gz
```

So now we have compressed data we need the bootloader to decompress it after it has loaded it.  See [../shared/shrinkler_bootblock.s](../shared/shrinkler_bootblock.s) for the modified bootblock. But in a nutshell it's as simple as:

```
 ; a0 = compressed data
 lea     DECOMPRESS_ADDRESS,a0             ; Where we asked the trackloaded to load the compressed data
 ; a1 = decompressed data destination
 lea     BASE_ADDRESS,a1                   ; The location of the decompressed code.
 ; a2 = progress callback, can be zero if no callback is desired.
 lea     Callback(pc),a2
 bsr     ShrinklerDecompress     ; -> decompress!
```

With our progress callback as simple as:

```
Callback:
	;; d0 = Number of bytes decompressed so far
	;; a0 = Callback argument
        move.l  a6,-(sp)
        lea     CUSTOM,a6
        move.w  d0,COLOR00(a6)  ; Set wild background colors as we decompress
        move.l  (sp)+,a6
        rts
```

And then we just include the Shrinkler [decompression code](../tools/external/shrinkler/ShrinklerDecompress.S):

```
    include  "../tools/external/shrinkler/ShrinklerDecompress.S"
```

In the [Makefile](Makefile) we can enable or disable Shrinkler:

```
SHRINKLER=1
```

In this example I have also started to refactor the structure of the code base ready for slightly more complex examples going forward.

try it
------
  * [Download disk image](bin/shrinker.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/shrinkler.adf" target="_blank">Run in SAE</a>
