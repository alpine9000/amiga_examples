#include <stdio.h>

int 
main(int argc, char** argv)
{
  int line = 0x41;

  for (int row = 0; row < 15; row++) {
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$3ae\n", line++);
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$5ce\n", line++);    
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$7dd\n", line++);    
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$9ec\n", line++);    
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$bea\n", line++);    
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$de8\n", line++);    
    printf("\tdc.w $%02x07,$fffe\n\tdc.w COLOR06,$ec6\n", line++);    
    line += 3;
  }

  return 0;
}
