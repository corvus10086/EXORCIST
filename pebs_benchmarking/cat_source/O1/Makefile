CC=gcc
CFLAGS=-m32 -masm=intel -fomit-frame-pointer  -fno-stack-protector -static -no-pie -fno-pic

# Compilation

all: spectre-pht_gcc.s spectre-pht_clang.s

.DEFAULT_GOAL := all


spectre-pht_gcc.s : spectre-pht.c
	$(CC) -S $(CFLAGS) $< -O1 -o $@

spectre-pht_clang.s: spectre-pht.c
	clang -S $(CFLAGS) $< -O1 -o $@

clean :
	rm *.s
