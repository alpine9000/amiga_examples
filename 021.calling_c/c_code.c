void 
PokeBitplanePointers(unsigned short* copper, unsigned char* bitplanes, unsigned offset, unsigned numBitplanes, unsigned screenWidthBytes)
{
  int i;
  copper += offset;

  for (i = 0; i < numBitplanes; i++) {
    *(copper+1) = (unsigned)bitplanes;
    *(copper+3) = ((unsigned)bitplanes >> 16);
    bitplanes += screenWidthBytes;
    copper += 4;
  } 
}

static unsigned short _copperData;
static unsigned char _bitplaneData;

void
TestCall()
{
  PokeBitplanePointers(&_copperData, &_bitplaneData, 3, 4, 5);
}
