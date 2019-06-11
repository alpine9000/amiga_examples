#include "mapgen.h"

/*
  Copyright (c) 2013, Bayle Jonathan <baylej@github>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

void
print_orient(enum tmx_map_orient orient)
{
  switch(orient) {
  case O_NONE: printf("none");  break;
  case O_ORT:  printf("ortho"); break;
  case O_ISO:  printf("isome"); break;
  case O_STA:  printf("stagg"); break;
  case O_HEX:  printf("hexag"); break;
  default: printf("unknown");
  }
}

void
print_stagger_index(enum tmx_stagger_index index)
{
  switch(index) {
  case SI_NONE: printf("none"); break;
  case SI_EVEN: printf("even"); break;
  case SI_ODD:  printf("odd");  break;
  default: printf("unknown");
  }
}

void
print_stagger_axis(enum tmx_stagger_axis axis)
{
  switch(axis) {
  case SA_NONE: printf("none"); break;
  case SA_X:    printf("x");    break;
  case SA_Y:    printf("y");    break;
  default: printf("unknown");
  }
}

void
print_renderorder(enum tmx_map_renderorder ro)
{
  switch(ro) {
  case R_NONE:      printf("none");      break;
  case R_RIGHTDOWN: printf("rightdown"); break;
  case R_RIGHTUP:   printf("rightup");   break;
  case R_LEFTDOWN:  printf("leftdown");  break;
  case R_LEFTUP:    printf("leftup");    break;
  default: printf("unknown");
  }
}

void
print_draworder(enum tmx_objgr_draworder dro)
{
  switch(dro) {
  case G_NONE:    printf("none");    break;
  case G_INDEX:   printf("index");   break;
  case G_TOPDOWN: printf("topdown"); break;
  default: printf("unknown");
  }
}

void
mk_padding(char pad[11], int depth) {
  if (depth>10) depth=10;
  if (depth>0) memset(pad, '\t', depth);
  pad[depth] = '\0';
}
