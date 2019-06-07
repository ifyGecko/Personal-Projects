#include <stdio.h>
#include <stdlib.h>

int c_return_file_size_in_bytes(char* filename){
	FILE *fp = fopen(filename, "r");
	fseek(fp, 0, SEEK_END); 
	int len = ftell(fp);
	fclose(fp);
	return len;
}

int8_t* c_read_file_bytes(char *filename){
	FILE *fp = fopen(filename, "r"); 
	int len = c_return_file_size_in_bytes(filename);
	int8_t* ret_array = malloc(len);
        fread(ret_array, 1, len, fp); 
	fclose(fp); 
	return ret_array; 
}
