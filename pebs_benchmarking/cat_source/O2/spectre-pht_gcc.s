	.file	"spectre-pht.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	victim_function_v1
	.type	victim_function_v1, @function
victim_function_v1:
.LFB51:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L1
	movzx	eax, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L1:
	ret
	.cfi_endproc
.LFE51:
	.size	victim_function_v1, .-victim_function_v1
	.p2align 4
	.globl	leakByteLocalFunction
	.type	leakByteLocalFunction, @function
leakByteLocalFunction:
.LFB52:
	.cfi_startproc
	movzx	edx, BYTE PTR [esp+4]
	movzx	eax, BYTE PTR temp
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE52:
	.size	leakByteLocalFunction, .-leakByteLocalFunction
	.p2align 4
	.globl	victim_function_v2
	.type	victim_function_v2, @function
victim_function_v2:
.LFB71:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	eax, DWORD PTR publicarray_size
	jnb	.L5
	movzx	eax, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L5:
	ret
	.cfi_endproc
.LFE71:
	.size	victim_function_v2, .-victim_function_v2
	.p2align 4
	.globl	leakByteNoinlineFunction
	.type	leakByteNoinlineFunction, @function
leakByteNoinlineFunction:
.LFB54:
	.cfi_startproc
	movzx	edx, BYTE PTR [esp+4]
	movzx	eax, BYTE PTR temp
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE54:
	.size	leakByteNoinlineFunction, .-leakByteNoinlineFunction
	.p2align 4
	.globl	victim_function_v3
	.type	victim_function_v3, @function
victim_function_v3:
.LFB55:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	ja	.L10
	ret
	.p2align 3
.L10:
	movzx	eax, BYTE PTR publicarray[eax]
	mov	DWORD PTR [esp+4], eax
	call	leakByteNoinlineFunction
	.cfi_endproc
.LFE55:
	.size	victim_function_v3, .-victim_function_v3
	.p2align 4
	.globl	victim_function_v4
	.type	victim_function_v4, @function
victim_function_v4:
.LFB56:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L11
	movzx	eax, BYTE PTR publicarray[eax+eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L11:
	ret
	.cfi_endproc
.LFE56:
	.size	victim_function_v4, .-victim_function_v4
	.p2align 4
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
	.p2align 3
.L15:
	movzx	ecx, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[ecx]
	mov	BYTE PTR temp, dl
	sub	eax, 1
	jnb	.L15
.L13:
	ret
	.cfi_endproc
.LFE57:
	.size	victim_function_v5, .-victim_function_v5
	.p2align 4
	.globl	victim_function_v6
	.type	victim_function_v6, @function
victim_function_v6:
.LFB58:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	mov	edx, DWORD PTR array_size_mask
	and	edx, eax
	cmp	edx, eax
	je	.L19
	ret
	.p2align 3
.L19:
	movzx	edx, BYTE PTR publicarray[edx]
	movzx	eax, BYTE PTR temp
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE58:
	.size	victim_function_v6, .-victim_function_v6
	.p2align 4
	.globl	victim_function_v7
	.type	victim_function_v7, @function
victim_function_v7:
.LFB59:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR last_x.0, eax
	jne	.L21
	movzx	ecx, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[ecx]
	mov	BYTE PTR temp, dl
.L21:
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L20
	mov	DWORD PTR last_x.0, eax
.L20:
	ret
	.cfi_endproc
.LFE59:
	.size	victim_function_v7, .-victim_function_v7
	.p2align 4
	.globl	victim_function_v8
	.type	victim_function_v8, @function
victim_function_v8:
.LFB60:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	lea	edx, [eax+1]
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
	.p2align 4
	.globl	victim_function_v9
	.type	victim_function_v9, @function
victim_function_v9:
.LFB61:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+8]
	mov	eax, DWORD PTR [eax]
	test	eax, eax
	je	.L26
	mov	edx, DWORD PTR [esp+4]
	movzx	eax, BYTE PTR temp
	movzx	edx, BYTE PTR publicarray[edx]
	and	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
.L26:
	ret
	.cfi_endproc
.LFE61:
	.size	victim_function_v9, .-victim_function_v9
	.p2align 4
	.globl	victim_function_v10
	.type	victim_function_v10, @function
victim_function_v10:
.LFB62:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	mov	edx, DWORD PTR [esp+8]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L28
	cmp	BYTE PTR publicarray[eax], dl
	je	.L30
.L28:
	ret
	.p2align 3
.L30:
	movzx	eax, BYTE PTR temp
	and	al, BYTE PTR publicarray2
	mov	BYTE PTR temp, al
	ret
	.cfi_endproc
.LFE62:
	.size	victim_function_v10, .-victim_function_v10
	.p2align 4
	.globl	victim_function_v11
	.type	victim_function_v11, @function
victim_function_v11:
.LFB63:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L31
	movzx	edx, BYTE PTR publicarray[eax]
	movzx	eax, BYTE PTR temp
	sub	al, BYTE PTR publicarray2[edx]
	mov	BYTE PTR temp, al
.L31:
	ret
	.cfi_endproc
.LFE63:
	.size	victim_function_v11, .-victim_function_v11
	.p2align 4
	.globl	victim_function_v12
	.type	victim_function_v12, @function
victim_function_v12:
.LFB64:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+8]
	add	eax, DWORD PTR [esp+4]
	cmp	eax, DWORD PTR publicarray_size
	jnb	.L33
	movzx	eax, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L33:
	ret
	.cfi_endproc
.LFE64:
	.size	victim_function_v12, .-victim_function_v12
	.p2align 4
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
	.p2align 4
	.globl	victim_function_v13
	.type	victim_function_v13, @function
victim_function_v13:
.LFB66:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	eax, DWORD PTR publicarray_size
	jb	.L38
	ret
	.p2align 3
.L38:
	movzx	eax, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
	ret
	.cfi_endproc
.LFE66:
	.size	victim_function_v13, .-victim_function_v13
	.p2align 4
	.globl	victim_function_v14
	.type	victim_function_v14, @function
victim_function_v14:
.LFB67:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	cmp	DWORD PTR publicarray_size, eax
	jbe	.L39
	xor	al, -1
	movzx	edx, BYTE PTR temp
	movzx	eax, BYTE PTR publicarray[eax]
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L39:
	ret
	.cfi_endproc
.LFE67:
	.size	victim_function_v14, .-victim_function_v14
	.p2align 4
	.globl	victim_function_v15
	.type	victim_function_v15, @function
victim_function_v15:
.LFB68:
	.cfi_startproc
	mov	eax, DWORD PTR [esp+4]
	mov	eax, DWORD PTR [eax]
	cmp	eax, DWORD PTR publicarray_size
	jnb	.L41
	movzx	eax, BYTE PTR publicarray[eax]
	movzx	edx, BYTE PTR temp
	and	dl, BYTE PTR publicarray2[eax]
	mov	BYTE PTR temp, dl
.L41:
	ret
	.cfi_endproc
.LFE68:
	.size	victim_function_v15, .-victim_function_v15
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB69:
	.cfi_startproc
	xor	eax, eax
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
