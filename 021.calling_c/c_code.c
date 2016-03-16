typedef union {
  unsigned char* ptr;
  struct {
    unsigned short hi;
    unsigned short lo;
  } words;
} word_extract_t;

typedef struct {
  unsigned short pad1;
  unsigned short lo;
  unsigned short pad2;
  unsigned short hi;
} copper_layout_t


void 
PokeBitplanePointers(unsigned short* copper, unsigned char* bitplanes, unsigned short interlace, unsigned short numBitplanes, unsigned short screenWidthBytes)
{
  char i;
  word_extract_t extract;
  copper_layout_t *ptr = copper;

  bitplanes += interlace ? screenWidthBytes*numBitplanes : 0;

  for (i = 0; i < numBitplanes; i++) {
    extract.ptr = bitplanes;
    ptr->lo = extract.words.lo;
    ptr->hi = extract.words.hi;
    bitplanes += screenWidthBytes;
    ptr++;
  } 
}
