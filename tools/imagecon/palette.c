#include "imagecon.h"

void palette_loadFile(imagecon_image_t* ic)
{
  FILE* fp = file_openRead(config.overridePalette);
  int paletteIndex;
  
  for (paletteIndex = 0; paletteIndex < MAX_PALETTE; paletteIndex++) {
    unsigned int c;
    char buffer[255];
    char* line = fgets(buffer, 255, fp);
    if (!line) {
      break;
    }
    sscanf(buffer, "%x\n", &c);
    
    ic->palette[paletteIndex].r = (c >> 8 & 0xF) << 4;
    ic->palette[paletteIndex].g = (c >> 4 & 0xF) << 4;
    ic->palette[paletteIndex].b = (c >> 0 & 0xF) << 4;
    ic->palette[paletteIndex].a = 255;
  }

  ic->numColors = paletteIndex;
}


void 
palette_output(char* outFilename, imagecon_image_t* ic)
{
  if (config.verbose) {
    printf("outputPalette...%d colors\n", ic->numColors);
  }

  FILE* fp = 0;
  FILE* paletteFP = 0;
  FILE* paletteAsmFP = 0;
  FILE* paletteGreyFP = 0;

  if (config.outputCopperList) {
    fp = file_openWrite("%s-copper-list.s", outFilename);
  }

  if (config.outputPalette) {
    paletteFP = file_openWrite("%s.pal", outFilename);
  }

  if (config.outputPaletteGrey) {
    paletteGreyFP = file_openWrite("%s-grey.s", outFilename);
    fprintf(paletteGreyFP, "\tmovem.l d0-a6,-(sp)\n\tlea CUSTOM,a6\n");
  }

  if (config.outputPaletteAsm) {
    paletteAsmFP = file_openWrite("%s-palette.s", outFilename);
    fprintf(paletteAsmFP, "\tmovem.l d0-a6,-(sp)\n\tlea CUSTOM,a6\n");
  }

  if (config.verbose) {
    printf("outputPalette:\n");
  }
  
  for (int i = 0; i < (config.ehbMode ? ic->numColors/2 : ic->numColors); i++) {
    if (config.verbose) {
      printf("%02d: hex=%03x r=%03d g=%03d b=%03d a=%03d\n", i , ic->palette[i].r << 8 | ic->palette[i].g << 4 | ic->palette[i].b, ic->palette[i].r, ic->palette[i].g, ic->palette[i].b, ic->palette[i].a);
    }
    if (paletteFP) {
      fprintf(paletteFP, "%03x\n",  (ic->palette[i].r >> 4) << 8 | (ic->palette[i].g >>4) << 4 | (ic->palette[i].b >>4));
    }
    if (paletteAsmFP) {
      fprintf(paletteAsmFP, "\tlea COLOR%02d(a6),a0\n\tmove.w #$%03x,(a0)\n", i, (ic->palette[i].r >> 4) << 8 | (ic->palette[i].g >>4) << 4 | (ic->palette[i].b >>4));
    }
    if (paletteGreyFP) {
      // TODO: this is for compat, can be better
      unsigned grey = (((ic->palette[i].r>>4) + (ic->palette[i].g>>4) + (ic->palette[i].b>>4))/3);
      fprintf(paletteGreyFP, "\tlea COLOR%02d(a6),a0\n\tmove.w #$%03x,(a0)\n", i, grey << 8 | grey << 4 | grey);
    }

    if (fp) {
      fprintf(fp, "\tdc.w $%x,$%x\n", 0x180+(i*2), (ic->palette[i].r >> 4) << 8 | (ic->palette[i].g >>4) << 4 | (ic->palette[i].b >>4));
    }
  }

  if (paletteFP) {
    fclose(paletteFP);
  }

  if (paletteGreyFP) {
    fprintf(paletteGreyFP, "\tmovem.l (sp)+,d0-a6\n");
    fclose(paletteGreyFP);
  }

  if (paletteAsmFP) {
    fprintf(paletteAsmFP, "\tmovem.l (sp)+,d0-a6\n");
    fclose(paletteFP);
  }

  if (fp) {
    fclose(fp);
  }

  if (config.verbose) {
    printf("done\n\n");
  }
}
