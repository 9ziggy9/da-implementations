#pragma once
#ifndef VECTOR_H
#define VECTOR_H
#include <stdlib.h>

#define VEC_MAX_SIZE    640
#define VEC_GROWTH_RATE 1.5 // golden ratio?

typedef enum {
  VEC_OK,
  VEC_GROW_FAIL,
  VEC_PUSH_FAIL,
} Vector_status;

typedef struct {
  size_t size;
  size_t capacity;
  int *data;
} Vector_int;

Vector_int Vector_int_init(const size_t);
Vector_status Vector_int_push(Vector_int*, int);
void Vector_int_destroy(Vector_int*);
void Vector_int_log(const Vector_int*);

#endif //VECTOR_H
