#include "imagecon.h"

void
free_vector(char** vector, int size)
{
  for (int i = 0; i < size; i++) {
    free(vector[i]);
  }
  free(vector);
}
