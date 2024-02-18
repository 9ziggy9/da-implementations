#include "vector.h"
#include <stdio.h>
#include <stdlib.h>

static inline void panic(const char *msg) {
  fprintf(stderr, "PANIC: %s\n", msg);
  exit(1);
}

static const char *ERR_VEC_ALLOC  = "Allocation in Vector_int_init() failure.";
static const char *ERR_VEC_PUSH   = "Push failure in vector occurred.";
static const char *ERR_VEC_OVFLW  = "Grow failure in vector: size overflow.";

Vector_int Vector_int_init(const size_t initial_capacity) {
  Vector_int vec;
  vec.size = 0;
  vec.capacity = initial_capacity;
  vec.data = (int *) malloc(sizeof(int) * initial_capacity);
  if (vec.data == NULL) panic(ERR_VEC_ALLOC);
  return vec;
}

static Vector_status Vector_int_grow(Vector_int *vec) {
  size_t d_vec_capacity = vec->capacity * VEC_GROWTH_RATE;
  if ((d_vec_capacity + vec->capacity) > VEC_MAX_SIZE) return VEC_GROW_FAIL;
  vec->capacity += d_vec_capacity;
  vec->data = realloc(vec->data, vec->capacity * sizeof(int));
  return vec->data == NULL
    ? VEC_GROW_FAIL
    : VEC_OK;
}

Vector_status Vector_int_push(Vector_int *vec, int elem) {
  if (vec->size >= vec->capacity) {
    if (Vector_int_grow(vec) == VEC_GROW_FAIL) return VEC_PUSH_FAIL;
  }
  vec->data[vec->size++] = elem;
  return VEC_OK;
}

void Vector_int_destroy(Vector_int *vec) {
  if (vec->data != NULL) {
    free(vec->data);
    vec->data = NULL;
  }
  vec->size = vec->capacity = 0;
}

void Vector_int_log(const Vector_int *vec) {
  printf("{");
  for (size_t i = 0; i < vec->size; i++) {
    printf("%d%s",
           vec->data[i],
           i < vec->size - 1 ? "," : "}");
  }
  printf("\n");
}
