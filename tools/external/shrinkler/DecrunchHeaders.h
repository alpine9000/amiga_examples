// Copyright 1999-2015 Aske Simon Christensen. See LICENSE.txt for usage terms.

/*

Binary Amiga code for the decrunch headers.

The .dat files are generated from the .bin files by the Makefile.

*/

#pragma once

unsigned char Header1[] = {
#include "Header1.dat"
};

unsigned char Header1T[] = {
#include "Header1T.dat"
};

unsigned char Header2[] = {
#include "Header2.dat"
};

unsigned char OverlapHeader[] = {
#include "OverlapHeader.dat"
};

unsigned char OverlapHeaderT[] = {
#include "OverlapHeaderT.dat"
};

unsigned char MiniHeader[] = {
#include "MiniHeader.dat"
};
