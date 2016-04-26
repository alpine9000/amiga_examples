#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <getopt.h>
#include <stdarg.h>

#include "fade.h"
#include "file.h"

typedef struct {
  int r, g, b, a;
} rgba_t;


config_t config = {
  .numColors = 16,
  .steps = 16
};

#define MAX_COLORS 32

rgba_t original[MAX_COLORS];
rgba_t from[MAX_COLORS];
rgba_t progress[MAX_COLORS];

void 
abort_(const char * s, ...)
{
  fprintf(stderr, "%s: ", config.argv[0]);
  va_list args;
  va_start(args, s);
  vfprintf(stderr, s, args);
  fprintf(stderr, "\n");
  va_end(args);
  exit(1);
}

void
usage()
{
  fprintf(stderr, 
	  "%s:  --output <output>\n"\
	  "options:\n"\
	  "  --to <file.pal>\n"\
	  "  --from <file.pal>\n"\
	  "  --from-grey\n"\
	  "  --from-black\n"\
	  "  --steps <num steps> (default: 16)\n"\
	  "  --colors <num colors> (default: 16)\n"\
	  "  --verbose\n\n"\
	  "Exactly one 'to' and 'from' option must be specified\n", config.argv[0]);
  exit(1);
}


int 
main(int argc, char** argv)
{
  int c;
  config.argv = argv;
  
  while (1) {
    static struct option long_options[] = {
      {"verbose", no_argument, &config.verbose, 1},
      {"from-grey", no_argument, &config.fromGrey, 1},
      {"from-black", no_argument, &config.fromBlack, 1},
      {"to",   required_argument, 0, 't'},
      {"from",   required_argument, 0, 'f'},
      {"output",   required_argument, 0, 'o'},
      {"steps",   required_argument, 0, 's'},
      {"colors",  required_argument, 0, 'c'},
      {0, 0, 0, 0}
    };
    
    int option_index = 0;
    
    c = getopt_long (argc, argv, "s:t:c:o:", long_options, &option_index);
    
    if (c == -1)
      break;
    
    switch (c) {
    case 0:
      break;
    case 't':
      config.toFile = optarg;
      break;
    case 'f':
      config.fromFile = optarg;
      break;
    case 'o':
      config.output = optarg;
      break;
    case 'c':
      if (sscanf(optarg, "%d", &config.numColors) != 1) {
	abort_("invalid number of colors");
      }
      break;	      
    case 's':
      if (sscanf(optarg, "%d", &config.steps) != 1) {
	abort_("invalid number of steps");
      }
      break;
    case '?':
      usage();
      break;	
    default:
      usage();
      break;
    }
  }


  if (config.toFile == 0 || config.output == 0) {
    usage();
    abort();
  }

  if (config.fromFile == 0 && (config.fromGrey == 0 && config.fromBlack == 0 && config.fromFile == 0)) {
    usage();
    abort();
  }


  if (config.toFile) {
    FILE* fp = file_openRead(config.toFile);
    rgba_t* p = original;    
    while (fscanf(fp, "%d %d %d %d", &p->r, &p->g, &p->b, &p->a) == 4) {
      p++;
    }
    fclose(fp);
  }


  if (config.fromFile) {
    FILE* fp = file_openRead(config.fromFile);   
    rgba_t* p = from;    
    while (fscanf(fp, "%d %d %d %d", &p->r, &p->g, &p->b, &p->a) == 4) {
      p++;
    }
    fclose(fp);
  }


  if (config.fromGrey) {
    rgba_t* g = from;
    rgba_t* p = original;    

    for (int i = 0; i < config.numColors; i++) {
      g->r =  g->g = g->b = (p->r + p->g + p->b) / 3;
      g++;
      p++;
    }
  }

  if (config.fromBlack) {
    rgba_t* g = from;
    for (int i = 0; i < config.numColors; i++) {
      g->r =  g->g = g->b = 0;
      g++;
    }
  }

  for (int s = 0; s < config.steps+1; s++) {
    printf(".step%d\n", s);
    for (int i = 0; i < config.numColors; i++) {
      int dr = ((((float)original[i].r)-(float)from[i].r)/(float)config.steps)*s;
      int dg = ((((float)original[i].g)-(float)from[i].g)/(float)config.steps)*s;
      int db = ((((float)original[i].b)-(float)from[i].b)/(float)config.steps)*s;

      if (config.verbose) {
	printf("r:%d %d %d -> %d\n"
	       "g:%d %d %d -> %d\n"
	       "b:%d %d %d -> %d\n",
	       original[i].r,from[i].r, dr, from[i].r+dr, 
	       original[i].g,from[i].g, dg, from[i].g+dg,
	       original[i].b,from[i].b, db, from[i].b+db);
      }

      printf("\tdc.w\t$%03x\n", 
	     ((from[i].r+dr)>>4)<<8|
	     ((from[i].g+dg)>>4)<<4|
	     ((from[i].b+db)>>4));
    }
  }

  printf("%sFadeComplete:\n", config.output);
}
