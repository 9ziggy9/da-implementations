/*
  Greetings! Today we are going to be implementing vector-like dynamic arrays in the C programming language. We will begin at a low level of abstraction and generalize as the implementation becomes more fleshed out. For now, we will only be creating dynamic arrays of integers and implementing very basic operations upon them.

  We will be using gcc 13.2.1 with the following compiler flags:
  -Wall -std=c11 -pedantic -Wconversion
*/

/*
  1. This is an excellent suggestion and after refactoring we will address this but for now let's not worry.
  2. I am open to this change but I believe it should be noted that we are going to generalize the data contained in Vectors in the future, in which case I believe usage of malloc will still be necessary. You may advise further here.
  3. Noted, I will panick in this event for the time being.
  4. By convention I would like to explicitly cast malloc() calls, I know this is not necessary but I prefer this style.
  5. Vector_int's mutability will be addressed in the future. I have not yet decided.
  6. No thank you.
  7. Maybe in the future.
  8. Table this for the time being, we will come back to that.
  9. Excellent idea, will implement.

  What follows is 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

const char *ERR_VEC_ALLOC  = "Allocation in Vector_int_init() failure.";
const char *ERR_VEC_PUSH   = "Push failure in vector occurred.";
const char *ERR_VEC_OVFLW  = "Grow failure in vector: size overflow.";

void panic(const char *msg) {
  fprintf(stderr, "PANIC: %s\n", msg);
  exit(1);
}

Vector_int Vector_int_init(const size_t initial_capacity) {
  Vector_int vec;
  vec.size = 0;
  vec.capacity = initial_capacity;
  vec.data = (int *) malloc(sizeof(int) * initial_capacity);
  if (vec.data == NULL) panic(ERR_VEC_ALLOC);
  return vec;
}

Vector_status Vector_int_grow(Vector_int *vec) {
  size_t new_capacity = vec->capacity * 2;
  if (new_capacity > SIZE_MAX / 2) panic(ERR_VEC_OVFLW);
  if (vec->capacity == vec->size) {
    vec->capacity = new_capacity;
    vec->data = realloc(vec->data, vec->capacity * sizeof(int));
    if (vec->data == NULL) return VEC_GROW_FAIL;
    return VEC_OK;
  }
  return VEC_GROW_FAIL;
}

Vector_status Vector_int_push(Vector_int *vec, int elem) {
  if (vec->size >= vec->capacity) {
    Vector_status status = Vector_int_grow(vec);
    if (status == VEC_GROW_FAIL) return VEC_PUSH_FAIL;
  }
  if (vec->data == NULL) return VEC_PUSH_FAIL;
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

int _test_vec(void);
int main(void) {
  _test_vec();
}

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
