#include <stdio.h>

typedef struct {
  unsigned char r, g, b, a;
} rgba_t;

#define NUM_COLORS 16

rgba_t original[NUM_COLORS];
rgba_t gray[NUM_COLORS];
rgba_t progress[NUM_COLORS];

int 
main(int argc, char** argv)
{
  FILE* fp = fopen(argv[1], "r");

  rgba_t* p = original;

  while (fscanf(fp, "%d %d %d %d", &p->r, &p->g, &p->b, &p->a) == 4) {
    p++;
  }

  rgba_t* g = gray;
  p = original;

  for (int i = 0; i < NUM_COLORS; i++) {
    g->r =  g->g = g->b = (p->r + p->g + p->b) / 3;
    //   printf("%d %d %d\n", g->r, g->g, g->b);
    g++;
    p++;
  }

  for (int s = 1; s <= 16; s++) {
    printf(".step%d\n", s);
    for (int i = 0; i < NUM_COLORS; i++) {
      int dr = ((((float)original[i].r)-(float)gray[i].r)/16.0)*s;
      int dg = ((((float)original[i].g)-(float)gray[i].g)/16.0)*s;
      int db = ((((float)original[i].b)-(float)gray[i].b)/16.0)*s;

      #if 0
      printf("r:%d %d %d -> %d\n"
	     "g:%d %d %d -> %d\n"
	     "b:%d %d %d -> %d\n",
	     original[i].r,gray[i].r, dr, gray[i].r+dr, 
	     original[i].g,gray[i].g, dg, gray[i].g+dg,
	     original[i].b,gray[i].b, db, gray[i].b+db);
      #endif

      printf("\tdc.w\t$%03x\n", 
	     ((gray[i].r+dr)>>4)<<8|
	     ((gray[i].g+dg)>>4)<<4|
	     ((gray[i].b+db)>>4));
    }
  }

  printf("fadeComplete:\n");

  fclose(fp);
}
