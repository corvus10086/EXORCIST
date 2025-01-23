	.file	"spectre-pht.c"
	.intel_syntax noprefix
	.text
	.globl	victim_function_v1
	.type	victim_function_v1, @function
victim_function_v1:
.LFB51:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L1
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L1:
	ret
	.cfi_endproc
.LFE51:
	.size	victim_function_v1, .-victim_function_v1
	.globl	leakByteLocalFunction
	.type	leakByteLocalFunction, @function
leakByteLocalFunction:
.LFB52:
	.cfi_startproc
	movzx	eax, BYTE PTR temp
	movzx	edx, BYTE PTR [esp+4]
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE52:
	.size	leakByteLocalFunction, .-leakByteLocalFunction
	.globl	victim_function_v2
	.type	victim_function_v2, @function
victim_function_v2:
.LFB53:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	ja	.L6
.L4:
	ret
.L6:
	movzx	eax, BYTE PTR publicarray[eax]
	push	eax
	.cfi_def_cfa_offset 8
	call	leakByteLocalFunction
	add	esp, 4
	.cfi_def_cfa_offset 4
	jmp	.L4
	.cfi_endproc
.LFE53:
	.size	victim_function_v2, .-victim_function_v2
	.globl	leakByteNoinlineFunction
	.type	leakByteNoinlineFunction, @function
leakByteNoinlineFunction:
.LFB54:
	.cfi_startproc
	movzx	eax, BYTE PTR temp
	movzx	edx, BYTE PTR [esp+4]
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE54:
	.size	leakByteNoinlineFunction, .-leakByteNoinlineFunction
	.globl	victim_function_v3
	.type	victim_function_v3, @function
victim_function_v3:
.LFB55:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	ja	.L10
.L8:
	ret
.L10:
	movzx	eax, BYTE PTR publicarray[eax]
	push	eax
	.cfi_def_cfa_offset 8
	call	leakByteNoinlineFunction
	add	esp, 4
	.cfi_def_cfa_offset 4
	jmp	.L8
	.cfi_endproc
.LFE55:
	.size	victim_function_v3, .-victim_function_v3
	.globl	victim_function_v4
	.type	victim_function_v4, @function
victim_function_v4:
.LFB56:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L11
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax+eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L11:
	ret
	.cfi_endproc
.LFE56:
	.size	victim_function_v4, .-victim_function_v4
	.globl	victim_function_v5
	.type	victim_function_v5, @function
victim_function_v5:
.LFB57:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L13
	sub	eax, 1
	js	.L13
.L15:
	movzx	edx, BYTE PTR temp
	movzx	ecx, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[ecx]
	mov	BYTE PTR temp, dl
	sub	eax, 1
	jns	.L15
.L13:
	ret
	.cfi_endproc
.LFE57:
	.size	victim_function_v5, .-victim_function_v5
	.globl	victim_function_v6
	.type	victim_function_v6, @function
victim_function_v6:
.LFB58:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	mov	edx, eax
	and	edx, DWORD PTR array_size_mask
	cmp	edx, eax
	je	.L19
.L17:
	ret
.L19:
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
	jmp	.L17
	.cfi_endproc
.LFE58:
	.size	victim_function_v6, .-victim_function_v6
	.globl	victim_function_v7
	.type	victim_function_v7, @function
victim_function_v7:
.LFB59:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR last_x.0, eax
	je	.L23
.L21:
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L20
	mov	DWORD PTR last_x.0, eax
.L20:
	ret
.L23:
	movzx	edx, BYTE PTR temp
	movzx	ecx, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[ecx]
	mov	BYTE PTR temp, dl
	jmp	.L21
	.cfi_endproc
.LFE59:
	.size	victim_function_v7, .-victim_function_v7
	.globl	victim_function_v8
	.type	victim_function_v8, @function
victim_function_v8:
.LFB60:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	lea	edx, [eax+1]
	cmp	DWORD PTR publicarray_size, eax
	mov	eax, 0
	cmovbe	edx, eax
	movzx	eax, BYTE PTR temp
	movzx	edx, BYTE PTR publicarray[edx]
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE60:
	.size	victim_function_v8, .-victim_function_v8
	.globl	victim_function_v9
	.type	victim_function_v9, @function
victim_function_v9:
.LFB61:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+8]
	cmp	DWORD PTR [eax], 0
	je	.L27
	movzx	eax, BYTE PTR temp
	mov	edx, DWORD PTR [esp+4]
	movzx	edx, BYTE PTR publicarray[edx]
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
.L27:
	ret
	.cfi_endproc
.LFE61:
	.size	victim_function_v9, .-victim_function_v9
	.globl	victim_function_v10
	.type	victim_function_v10, @function
victim_function_v10:
.LFB62:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	mov	edx, DWORD PTR [esp+8]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L29
	cmp	BYTE PTR publicarray[eax], dl
	je	.L31
.L29:
	ret
.L31:
	movzx	eax, BYTE PTR temp
	and	al, BYTE PTR publicarray2
	mov	BYTE PTR temp, al
	jmp	.L29
	.cfi_endproc
.LFE62:
	.size	victim_function_v10, .-victim_function_v10
	.globl	victim_function_v11
	.type	victim_function_v11, @function
victim_function_v11:
.LFB63:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L32
	movzx	edx, BYTE PTR publicarray[eax]
	movzx	eax, BYTE PTR temp
	sub	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
.L32:
	ret
	.cfi_endproc
.LFE63:
	.size	victim_function_v11, .-victim_function_v11
	.globl	victim_function_v12
	.type	victim_function_v12, @function
victim_function_v12:
.LFB64:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+8]
	add	eax, DWORD PTR [esp+4]
	cmp	eax, DWORD PTR publicarray_size
	jnb	.L34
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L34:
	ret
	.cfi_endproc
.LFE64:
	.size	victim_function_v12, .-victim_function_v12
	.globl	is_x_safe
	.type	is_x_safe, @function
is_x_safe:
.LFB65:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	seta	al
	movzx	eax, al
	ret
	.cfi_endproc
.LFE65:
	.size	is_x_safe, .-is_x_safe
	.globl	victim_function_v13
	.type	victim_function_v13, @function
victim_function_v13:
.LFB66:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	eax, DWORD PTR publicarray_size
	jnb	.L37
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L37:
	ret
	.cfi_endproc
.LFE66:
	.size	victim_function_v13, .-victim_function_v13
	.globl	victim_function_v14
	.type	victim_function_v14, @function
victim_function_v14:
.LFB67:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L39
	movzx	edx, BYTE PTR temp
	xor	al, -1
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L39:
	ret
	.cfi_endproc
.LFE67:
	.size	victim_function_v14, .-victim_function_v14
	.globl	victim_function_v15
	.type	victim_function_v15, @function
victim_function_v15:
.LFB68:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	mov	eax, DWORD PTR [eax]
	cmp	eax, DWORD PTR publicarray_size
	jnb	.L41
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L41:
	ret
	.cfi_endproc
.LFE68:
	.size	victim_function_v15, .-victim_function_v15
	.globl	main
	.type	main, @function
main:
.LFB69:
	.cfi_startproc
	mov	eax, 0
	ret
	.cfi_endproc
.LFE69:
	.size	main, .-main
	.local	last_x.0
	.comm	last_x.0,4,4
	.globl	array_size_mask
	.data
	.align 4
	.type	array_size_mask, @object
	.size	array_size_mask, 4
array_size_mask:
	.long	15
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	secretarray
	.data
	.align 4
	.type	secretarray, @object
	.size	secretarray, 16
secretarray:
	.ascii	"\n\025 +6ALWbmny\204\217\232\245"
	.globl	publicarray2
	.align 4
	.type	publicarray2, @object
	.size	publicarray2, 16
publicarray2:
	.string	"\024"
	.zero	14
	.globl	publicarray
	.align 4
	.type	publicarray, @object
	.size	publicarray, 16
publicarray:
	.string	""
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017"
	.globl	publicarray_size
	.align 4
	.type	publicarray_size, @object
	.size	publicarray_size, 4
publicarray_size:
	.long	16
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
