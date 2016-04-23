#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "mapgen.h"

config_t config = {
  .verbose = 0,
  .bitDepth = 0,
  .inputFile = 0

};


static unsigned
get_tile_address(tmx_map *m, unsigned int gid)
{
  if (config.verbose) {
    printf("get_tile_address %d\n", gid);
  }

  int ts_count = 0;
  tmx_tileset** ta;

  {
    tmx_tileset* t = m->ts_head;
    while (t != 0) {
      t = t->next;
      ts_count++;
    }

    ta = malloc(sizeof(tmx_tileset)*ts_count);
    t = m->ts_head;
    int c = ts_count;
    while (t != 0) {
      ta[--c] = t;
      t = t->next;
    }
  }


  unsigned baseAddress = 0;
  for (int y = 0; y < ts_count; y++) {
    tmx_tileset* ts = ta[y];    
    for (unsigned int i = 0; i < ts->tilecount; i++) {
      tmx_tile* t = ts->tiles;
      if (t[i].id+ts->firstgid == gid) {
	unsigned address = baseAddress + (t[i].ul_y * ((ts->image->width/8) * config.bitDepth)) + (t[i].ul_x/8);
	if (config.verbose) {
	  printf("%s - baseAddress = %d address = %d\n", ts->name, baseAddress, address);
	}
	return address;
      }
    }
    baseAddress += ((ts->image->width/8) * config.bitDepth * ts->image->height);
  }

  return 0;
}


static unsigned
get_tile_index(tmx_map *m, unsigned int gid)
{
  if (config.verbose) {
    printf("get_tile_address %d\n", gid);
  }

  int ts_count = 0;
  tmx_tileset** ta;

  {
    tmx_tileset* t = m->ts_head;
    while (t != 0) {
      t = t->next;
      ts_count++;
    }

    ta = malloc(sizeof(tmx_tileset)*ts_count);
    t = m->ts_head;
    int c = ts_count;
    while (t != 0) {
      ta[--c] = t;
      t = t->next;
    }
  }


  for (int y = 0; y < ts_count; y++) {
    tmx_tileset* ts = ta[y];    
    for (unsigned int i = 0; i < ts->tilecount; i++) {
      tmx_tile* t = ts->tiles;
      if (t[i].id+ts->firstgid == gid) {
	if (config.verbose) {
	  printf("%s - index = %d\n", ts->name, t[i].id);
	}
	return t[i].id;
      }
    }
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
	fprintf(fp, "\tdc.w $%x\n", get_tile_address(m, l->content.gids[(y*m->width)+x] & TMX_FLIP_BITS_REMOVAL));
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
output_map_indexes(tmx_map *m, tmx_layer *l)
{
  if (!l) {
    abort_("output_map_indexes: empty layer");
  }

  FILE* fp = file_openWrite("%s-indexes.s", l->name);

  if (l->type == L_LAYER && l->content.gids) {
    for (unsigned int x = 0; x < m->width; x++) {
      for (unsigned int y = 0; y < m->height; y++) {
	fprintf(fp, "\tdc.w %d\n", get_tile_index(m, l->content.gids[(y*m->width)+x] & TMX_FLIP_BITS_REMOVAL));
      }
    }
  }
  fclose(fp);

  if (l) {
    if (l->next) {
      output_map_indexes(m, l->next);
    }
  }
}


static void 
process_map(tmx_map *m) 
{
    output_map_asm(m, m->ly_head);
    output_map_indexes(m, m->ly_head);
}


void
usage()
{
  fprintf(stderr, 
	  "%s:  --input <input.tmx> --depth <num bitplanes>\n"\
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
      {"depth",   required_argument, 0, 'd'},
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
    case 'd':
      sscanf(optarg, "%d", &config.bitDepth);
      break;	
    case '?':
      usage();
      break;	
    default:
      usage();
      break;
    }
  }
  

  if (config.inputFile == 0 || config.bitDepth == 0) {
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
