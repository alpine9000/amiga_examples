typedef union {
  unsigned char* ptr;
  struct {
    unsigned short hi;
    unsigned short lo;
  } words;
} word_extract_t;

void 
PokeBitplanePointers(unsigned short* copper, unsigned char* bitplanes, unsigned offset, unsigned numBitplanes, unsigned screenWidthBytes)
{
  int i;
  copper += offset;

  for (i = 0; i < numBitplanes; i++) {
    word_extract_t extract;
    extract.ptr = bitplanes;
    *(copper+1) = extract.words.lo;
    *(copper+3) = extract.words.hi;
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
