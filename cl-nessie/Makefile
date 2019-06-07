CC=gcc

reader.so: reader.o
	$(CC) -shared reader.o -o reader.so
reader.o: reader.c
	$(CC) -c -fpic reader.c -o reader.o
