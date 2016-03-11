installing the cross development environment
============================================

Built on OSX 10.11.3
Notes: 
   * My /usr/local is writable by me. You will probable need to add "sudo" to any "make install" lines
   * You can probably install most of this stuff using a package system rather than building from sources

0. gcc-5.3.0 for OSX
    ```
# svn checkout svn://gcc.gnu.org/svn/gcc/tags/gcc_5_3_0_release gcc-5.3.0-src
# cd gcc-5.3.0-src
# ./contrib/download_prerequisites
# cd ..
# mkdir gcc-5.3.0-build
# cd gcc-5.3.0-build
#  ../gcc-5.3.0-src/configure --prefix=/usr/local --enable-languages=c,c++
# make -j4
# make install
```

1. The fantastic AmigaOS cross compiler for Linux / MacOSX / Windows 

   https://github.com/cahirwpz/amigaos-cross-toolchain

    ```
# git clone git://github.com/cahirwpz/amigaos-cross-toolchain.git
# cd amigaos-cross-toolchain
# ./toolchain-m68k --prefix=/usr/local/amiga build
```
   
2. autoconf
    ```
    # curl -OL http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz
    # tar xzf autoconf-2.69.tar.gz
    # cd autoconf-2.69
    # ./configure --prefix=/usr/local
    # make
    # make install
```

3. automake
    ```
    # curl -OL http://ftpmirror.gnu.org/automake/automake-1.15.tar.gz
    # tar xzf automake-1.15.tar.gz
    # cd automake-1.15
    # ./configure --prefix=/usr/local
    # make
    # make install
```

4. pkg-config
    ```
    # curl -OL https://pkg-config.freedesktop.org/releases/pkg-config-0.29.tar.gz
    # tar zxf pkg-config-0.29.tar.gz
    # cd pkg-config-0.29
    # ./configure --with-internal-glib --prefix=/usr/local LDFLAGS="-framework CoreFoundation -framework Carbon"
    # make
    # make install
```

5. lha
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

6. libtool
    ```
   # wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
   # tar zxfv libtool-2.4.6.tar.gz
   # cd libtool-2.4.6
   # ./configure --prefix=/usr/local
   # make
   # make install
```

7. libpng
    ```
   # wget ftp://ftp.simplesystems.org/pub/png/src/libpng16/libpng-1.6.21.tar.gz
   # tar zxfv libpng-1.6.21.tar.gz
   # cd libpng-1.6.21
   # ./configure --prefix=/usr/local
   # make
   # make install
```

8. pngquant
    ```
    # git clone git://github.com/pornel/pngquant.git
    # cd pngquant/lib
    # ./configure --prefix=/usr/local
    # make
    # mkdir /usr/local/include/pngquant
    # cp *.h /usr/local/include/pngquant/
    # cp *.a /usr/local/lib
```

9. GraphicsMagick
    ```
    # wget http://78.108.103.11/MIRROR/ftp/GraphicsMagick/1.3/GraphicsMagick-1.3.23.tar.gz
    # tar zxfv GraphicsMagick-1.3.23.tar.gz
    # cd GraphicsMagick-1.3.23
    # ./configure --prefix=/usr/local
    # make
    # make install
```
