#include "test.h"

int _test_vec(void) {
  // Test Vector_int_init()
  printf("\033[0;32mRunning test_vec()\n");
  printf("\033[0;37m");
  Vector_int v1 = Vector_int_init(5);
  if (v1.capacity != 5 || v1.size != 0) {
    printf("Vector_int_init() failed\n");
    return 1;
  }

  // Test Vector_int_push()
  Vector_int v2 = Vector_int_init(5);
  for (int i = 0; i < 10; i++) {
    if (Vector_int_push(&v2, i) != VEC_OK) {
      printf("Vector_int_push() failed\n");
      return 1;
    }
  }
  if (v2.size != 10) {
    printf("Vector_int_push() failed\n");
    return 1;
  }

  // Test Vector_int_grow()
  Vector_int v3 = Vector_int_init(5);
  for (int i = 0; i < 15; i++) {
    if (Vector_int_push(&v3, i) != VEC_OK) {
      printf("Vector_int_push() failed\n");
      return 1;
    }
  }
  if (v3.capacity < 15) {
    printf("Vector_int_grow() failed\n");
    return 1;
  }

  // Test Vector_int_log()
  Vector_int v4 = Vector_int_init(5);
  for (int i = 0; i < 5; i++) {
    if (Vector_int_push(&v4, i) != VEC_OK) {
      printf("Vector_int_push() failed\n");
      return 1;
    }
  }
  Vector_int_log(&v4);

  printf("\033[0;32mTesting complete.\n");
  printf("\033[0;37m");
  return 0;
}
