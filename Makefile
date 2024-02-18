CFLAGS=-Wall -std=c11 -pedantic -Wconversion -Wunused

all: main.c
	cc $(CFLAGS) main.c -o test

clean:
	rm -rf ./test ./build/*
