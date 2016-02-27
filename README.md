(re)Learning how to program an Amiga after a 20 year break
==========================================================

Cross development environment
-----------------------------
Built on OSX 10.11.3
Notes: 
   * My /usr/local is writable by me. You will probable need to add "sudo" to any "make install" lines
   * I have gcc-5.3.0 installed in /usr/local

1. autoconf
    curl -OL http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz
    tar xzf autoconf-2.69.tar.gz
    cd autoconf-2.69
    ./configure --prefix=/usr/local
    make
    make install

2. automake
    curl -OL http://ftpmirror.gnu.org/automake/automake-1.15.tar.gz
    tar xzf automake-1.15.tar.gz
    cd automake-1.15
    ./configure --prefix=/usr/local
    make
    make install

3. pkg-config
    curl -OL https://pkg-config.freedesktop.org/releases/pkg-config-0.29.tar.gz
    tar zxf pkg-config-0.29.tar.gz
    cd pkg-config-0.29
    ./configure --with-internal-glib --prefix=/usr/local LDFLAGS="-framework CoreFoundation -framework Carbon"
    make
    make install

4. lha
    git clone https://github.com/jca02266/lha.git
    aclocal
    autoheader
    automake -a
    autoconf
    ./configure --prefix=/usr/local
    make
    make install