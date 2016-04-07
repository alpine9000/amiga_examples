#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "mapgen.h"

config_t config = {
  .verbose = 0,
  .bitDepth = 4,
  .inputFile = 0

};


static unsigned
get_tile_address(tmx_map *m, unsigned int gid)
{
  printf("get_tile_address %d\n", gid);
  
  tmx_tileset* ts = m->ts_head;
  unsigned baseAddress = 0;
  while (ts != 0) {
    for (unsigned int i = 0; i < ts->tilecount; i++) {
      tmx_tile* t = ts->tiles;
      if (t[i].id+ts->firstgid == gid) {
	unsigned address = baseAddress + (t[i].ul_y * ((ts->image->width/8) * config.bitDepth)) + (t[i].ul_x/8);
	printf("%s - baseAddress = %d address = %d\n", ts->name, baseAddress, address);
	return address;
      }
    }
    baseAddress += ((ts->image->width/8) * config.bitDepth * ts->image->height);
    ts = ts->next;
  }

  return 0;
}


static void 
output_map_asm(tmx_map *m, tmx_layer *l)
{
  if (!l) {
    abort_("output_map_asm: empty layer");
  }

  FILE* fp = file_openWrite("%s-map.s", l->name);

  if (l->type == L_LAYER && l->content.gids) {
    for (unsigned int x = 0; x < m->width; x++) {
      for (unsigned int y = 0; y < m->height; y++) {
	fprintf(fp, "\tdc.w %d\n", get_tile_address(m, l->content.gids[(y*m->width)+x] & TMX_FLIP_BITS_REMOVAL));
      }
    }
  }
  fclose(fp);

  if (l) {
    if (l->next) {
      output_map_asm(m, l->next);
    }
  }
}


static void 
process_map(tmx_map *m) 
{
    output_map_asm(m, m->ly_head);
}


void
usage()
{
  fprintf(stderr, 
	  "%s:  --input <input.tmx>\n"\
	  "options:\n"\
	  "  --help\n"\
	  "  --verbose\n", config.argv[0]);
  exit(1);
}


int 
main(int argc, char *argv[]) 
{
  int c;
  tmx_map *m;

  config.argv = argv;

  while (1) {
    static struct option long_options[] = {
      {"verbose", no_argument, &config.verbose, 1},
      {"help", no_argument, 0, '?'},
      {"input",   required_argument, 0, 'i'},
      {0, 0, 0, 0}
    };
    
    int option_index = 0;
   
    c = getopt_long (argc, argv, "i:?", long_options, &option_index);
    
    if (c == -1)
      break;
    
    switch (c) {
    case 0:
      break;
    case 'i':
      config.inputFile = optarg;
      break;	
    case '?':
      usage();
      break;	
    default:
      usage();
      break;
    }
  }
  

  if (config.inputFile == 0) {
    usage();
    abort();
  }  

  m = tmx_load(config.inputFile);

  if (!m) {
    tmx_perror("error");
  }
  
  process_map(m);
  tmx_map_free(m);
  
  return EXIT_SUCCESS;
}
