(re)Learning how to program an Amiga after a 20 year break
==========================================================

Documentation
-------------
* [68000 instructions](http://68k.hax.com/)
* [vasm documentation](http://sun.hasenbraten.de/vasm/release/vasm.html)
* [vlink documentation (PDF)](http://sun.hasenbraten.de/vlink/release/vlink.pdf)
* [Amiga registers](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0060.html)
* [Amiga Hardware Reference Manual](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0000.html)
* [Amiga RKM Devices Manual](http://amigadev.elowar.com/read/ADCD_2.1/Devices_Manual_guide/node0000.html)
* [coppershade.org downloads](http://coppershade.org/articles/More!/Downloads/)
* [Copper timing details](http://coppershade.org/articles/AMIGA/Agnus/Copper:_Exact_WAIT_Timing/)
* [Coding forum](http://ada.untergrund.net/?p=boardforums&forum=4)

Cross development environment
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
