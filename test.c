#include "test.h"
#include "vector.h"
#include <stdio.h>

int _test_vec(void) {
  // Test Vector_int_init()
  printf("\033[32mRunning test_vec()\n");
  printf("\033[37m");

  // SHOULD NOT FAIL
  Vector_int v = Vector_int_init(1);
  for (int i = 0; i < 10; i++) {
    if (Vector_int_push(&v, i) != VEC_OK) {
      printf("Vector_int_push() failed\n");
      return 1;
    }
  }
  Vector_int_log(&v);

  // SHOULD FAIL
  Vector_int bad_vec = Vector_int_init(1);
  for (int i = 0; i < 11; i++) {
    if (Vector_int_push(&bad_vec, i) != VEC_OK) {
      printf("Vector_int_push() failed\n");
      return 1;
    }
  }
  Vector_int_log(&bad_vec);

  printf("\033[32mTesting complete.\n");
  printf("\033[37m");
  return 0;
}
