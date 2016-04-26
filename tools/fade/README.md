fade
====

Generate data for fading between color palettes

usage
-----
```
    fade:  --output <output>
    options:
      --to <file.pal>
      --from <file.pal>
      --from-grey
      --from-black
      --steps <num steps> (default: 16)
      --colors <num colors> (default: 16)
      --verbose
```

fade will generate 68000 assembler data for fading between two amiga color palettes. The output it written to stdout.

mandatory arguments
-------------------
**--output** &lt;output>

Specify the name used for creating symbols used in the data. In addition exactly on "to" and one "from" option must be specified.

options
-------

**--to** &lt;to.pal>

The palette file used for the destination palette (will fade to this palette)

**--from** &lt;from.pal>

The palette file used for the source palette (will fade from this palette)

**--from-grey**

Fade from a grey version of the "to" palette

**--from-black**

Fade from a black version of the "to" palette

**--steps** &lt;num steps>

The number of steps in the fade

**--colors** &lt;num colors>

The number of colors in the palette

**--verbose**

Display debugging information
