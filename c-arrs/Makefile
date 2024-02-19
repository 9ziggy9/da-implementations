CC=gcc
CFLAGS=-Wall -std=c11 -pedantic -Wconversion -Wunused
OBJ=./build/vector.o ./build/test.o
INC=-I ./include

all: test main.c
	$(CC) $(INC) $(CFLAGS) main.c $(OBJ) -o ./test

test: vector test.c
	$(CC) $(INC) -g ./test.c -c -o ./build/test.o

vector: vector.c
	$(CC) $(INC) -g ./vector.c -c -o ./build/vector.o

clean:
	rm -rf ./test ./test_vec ./build/*
