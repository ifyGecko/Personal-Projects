#include <stdlib.h>
#include <stdio.h>

char* head;									// ptr to current pos in interpreter mem

void ebfin_init(unsigned int tape_size){
	head = (char*)calloc(tape_size, sizeof(char));				// allocate tape memory set to 0
}

void ebfin_halt(){
	free(head);								// free tape memory
}

void ebfin_eval(char* c){
	for(int i = 0 ; c[i] != '\0' ; ++i){					// loop until end of code
		if(c[i] == '>') ++head;						// move head forward along tape
		else if(c[i] == '<') --head;					// move head backwards along tape
		else if(c[i] == '+') ++*head;					// increment data at the head
		else if(c[i] == '-') --*head;					// decrement data at the head
		else if(c[i] == '.') putchar(*head);				// print data at the head
		else if(c[i] == ',') *head = getchar();				// get data from user and place at the head
		else if(c[i] == '['){						// while(*head != 0), loop until data at head == 0
			if(*head == 0){						// if *head == 0 skip loop
				int j = 1;					// count of current loop nesting
				while(j > 0){					// until at the end of loop
					i++;					// move forward in code
					if(c[i] == '[') j++;			// increment the count of nested loops
					if(c[i] == ']') j--;			// decrement the count of nested loops
				}
			}
		}
		else if(c[i] == ']'){
			if(*head != 0){						// if *head != 0 skip back to opening [ to restart the loop
				int j = 1;					// count of loop nesting
				while(j > 0){					// until at the beginning of loop
					i--;					// move backward in code to beginning of loop
					if(c[i] == '[') j--;			// decrement count of nested loops
					if(c[i] == ']') j++;			// increment count of nested loops 
				}
			}
		}
	}
}
