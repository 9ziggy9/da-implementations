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
  9. I am not opposed to this idea but again, we will wait.

  What follows is 
*/

#include "vector.h"
#include "test.h"
#include <stdio.h>

int main(void) {
  printf("Starting program...\n");
  _test_vec();
}
