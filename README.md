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

tools
=====
* [imagecon](tools/imagecon)
* [makeadf](tools/makeadf)

The tools have tests:

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

or test all by running make at the top level

cross development environment
-----------------------------
Built on OSX 10.11.3
Notes: 
   * My /usr/local is writable by me. You will probable need to add "sudo" to any "make install" lines
   * I have gcc-5.3.0 installed in /usr/local

0. The fantastic AmigaOS cross compiler for Linux / MacOSX / Windows 

   https://github.com/cahirwpz/amigaos-cross-toolchain

    ```
# git clone git://github.com/cahirwpz/amigaos-cross-toolchain.git
# cd amigaos-cross-toolchain
# ./toolchain-m68k --prefix=/usr/local/amiga build
```
   
1. autoconf
    ```
    # curl -OL http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz
    # tar xzf autoconf-2.69.tar.gz
    # cd autoconf-2.69
    # ./configure --prefix=/usr/local
    # make
    # make install
```

2. automake
    ```
    # curl -OL http://ftpmirror.gnu.org/automake/automake-1.15.tar.gz
    # tar xzf automake-1.15.tar.gz
    # cd automake-1.15
    # ./configure --prefix=/usr/local
    # make
    # make install
```

3. pkg-config
    ```
    # curl -OL https://pkg-config.freedesktop.org/releases/pkg-config-0.29.tar.gz
    # tar zxf pkg-config-0.29.tar.gz
    # cd pkg-config-0.29
    # ./configure --with-internal-glib --prefix=/usr/local LDFLAGS="-framework CoreFoundation -framework Carbon"
    # make
    # make install
```

4. lha
    ```
    # git clone https://github.com/jca02266/lha.git
    # aclocal
    # autoheader
    # automake -a
    # autoconf
    # ./configure --prefix=/usr/local
    # make
    # make install
```

5. libtool
    ```
   # wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
   # tar zxfv libtool-2.4.6.tar.gz
   # cd libtool-2.4.6
   # ./configure --prefix=/usr/local
   # make
   # make install
```

6. libpng
    ```
   # wget ftp://ftp.simplesystems.org/pub/png/src/libpng16/libpng-1.6.21.tar.gz
   # tar zxfv libpng-1.6.21.tar.gz
   # cd libpng-1.6.21
   # ./configure --prefix=/usr/local
   # make
   # make install
```

7. pngquant
    ```
    # git clone git://github.com/pornel/pngquant.git
    # cd pngquant/lib
    # ./configure --prefix=/usr/local
    # make
    # mkdir /usr/local/include/pngquant
    # cp *.h /usr/local/include/pngquant/
    # cp *.a /usr/local/lib
```

license
=======
Some of the code I have included in this repository is copyright by various authors and provided under various licenses. Copyright notices are preseved where possible.

Some of the tools use GPL licensed libraries which would mean they could only be distributed under the conditions of the respective version of the GPL.

All code without a copyright notice is probably in the public domain.
