# v1.mk
CFLAGS = -std=c99 -masm=intel
GCC_PROGRAM_O0 = spec_gcc_o0.out
GCC_PROGRAM_O1 = spec_gcc_o1.out
GCC_PROGRAM_O2 = spec_gcc_o2.out
GCC_PROGRAM_O3 = spec_gcc_o3.out
CLANG_PROGRAM_O0 = spec_cl_o0.out
CLANG_PROGRAM_O1 = spec_cl_o1.out
CLANG_PROGRAM_O2 = spec_cl_o2.out
CLANG_PROGRAM_O3 = spec_cl_o3.out
GCC_ASM_O0 = spec_gcc_o0.s
GCC_ASM_O1 = spec_gcc_o1.s
GCC_ASM_O2 = spec_gcc_o2.s
GCC_ASM_O3 = spec_gcc_o3.s
CLANG_ASM_O0 = spec_cl_o0.s
CLANG_ASM_O1 = spec_cl_o1.s
CLANG_ASM_O2 = spec_cl_o2.s
CLANG_ASM_O3 = spec_cl_o3.s

SOURCE  = spectre.c
     
all: $(GCC_PROGRAM_O0) $(GCC_PROGRAM_O1) $(GCC_PROGRAM_O2) $(GCC_PROGRAM_O3) \
 $(CLANG_PROGRAM_O0) $(CLANG_PROGRAM_O1) $(CLANG_PROGRAM_O2) $(CLANG_PROGRAM_O3)
     
$(GCC_PROGRAM_O0): $(GCC_ASM_O0) ;

$(GCC_PROGRAM_O1): $(GCC_ASM_O1) ;

$(GCC_PROGRAM_O2): $(GCC_ASM_O2) ;

$(GCC_PROGRAM_O3): $(GCC_ASM_O3) ;

$(CLANG_PROGRAM_O0): $(CLANG_ASM_O0) ;

$(CLANG_PROGRAM_O1): $(CLANG_ASM_O1) ;

$(CLANG_PROGRAM_O2): $(CLANG_ASM_O2) ;

$(CLANG_PROGRAM_O3): $(CLANG_ASM_O3) ;

$(GCC_ASM_O0): $(SOURCE) ; gcc $(CFLAGS) -S -o $(GCC_ASM_O0) $(SOURCE) -O0

$(GCC_ASM_O1): $(SOURCE) ; gcc $(CFLAGS) -S -o $(GCC_ASM_O1) $(SOURCE) -O1

$(GCC_ASM_O2): $(SOURCE) ; gcc $(CFLAGS) -S -o $(GCC_ASM_O2) $(SOURCE) -O2

$(GCC_ASM_O3): $(SOURCE) ; gcc $(CFLAGS) -S -o $(GCC_ASM_O3) $(SOURCE) -O3

$(CLANG_ASM_O0): $(SOURCE) ; clang $(CFLAGS) -S -o $(CLANG_ASM_O0) $(SOURCE) -O0

$(CLANG_ASM_O1): $(SOURCE) ; clang $(CFLAGS) -S -o $(CLANG_ASM_O1) $(SOURCE) -O1

$(CLANG_ASM_O2): $(SOURCE) ; clang $(CFLAGS) -S -o $(CLANG_ASM_O2) $(SOURCE) -O2

$(CLANG_ASM_O3): $(SOURCE) ; clang $(CFLAGS) -S -o $(CLANG_ASM_O3) $(SOURCE) -O3

     
clean:
	rm -f *.s *.out
