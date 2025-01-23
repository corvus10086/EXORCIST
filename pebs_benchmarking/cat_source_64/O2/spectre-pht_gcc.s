	.file	"spectre-pht.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	victim_function_v1
	.type	victim_function_v1, @function
victim_function_v1:
.LFB51:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L1
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	movzx	edi, dil
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdi]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rdi, rax
	jnb	.L5
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	movzx	edi, dil
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdi]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	ja	.L10
	ret
	.p2align 4,,10
	.p2align 3
.L10:
	movzx	edi, BYTE PTR publicarray[rdi]
	jmp	leakByteNoinlineFunction
	.cfi_endproc
.LFE55:
	.size	victim_function_v3, .-victim_function_v3
	.p2align 4
	.globl	victim_function_v4
	.type	victim_function_v4, @function
victim_function_v4:
.LFB56:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L11
	movzx	edx, BYTE PTR publicarray[rdi+rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L13
	sub	edi, 1
	js	.L13
	movsx	rax, edi
	.p2align 4,,10
	.p2align 3
.L15:
	movzx	ecx, BYTE PTR publicarray[rax]
	movzx	edx, BYTE PTR temp[rip]
	sub	rax, 1
	and	dl, BYTE PTR publicarray2[rcx]
	mov	BYTE PTR temp[rip], dl
	test	eax, eax
	jns	.L15
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
	endbr64
	movsx	rax, DWORD PTR array_size_mask[rip]
	and	rax, rdi
	cmp	rax, rdi
	je	.L19
	ret
	.p2align 4,,10
	.p2align 3
.L19:
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	edx, BYTE PTR temp[rip]
	and	dl, BYTE PTR publicarray2[rax]
	mov	BYTE PTR temp[rip], dl
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
	endbr64
	cmp	QWORD PTR last_x.0[rip], rdi
	jne	.L21
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
.L21:
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L20
	mov	QWORD PTR last_x.0[rip], rdi
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	lea	rdx, [rdi+1]
	cmp	rax, rdi
	mov	eax, 0
	cmovbe	rdx, rax
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdx]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR [rsi]
	test	eax, eax
	je	.L26
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L28
	cmp	BYTE PTR publicarray[rdi], sil
	je	.L30
.L28:
	ret
	.p2align 4,,10
	.p2align 3
.L30:
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rip]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L31
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	sub	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	add	rdi, rsi
	cmp	rdi, rax
	jnb	.L33
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rdi, rax
	jb	.L38
	ret
	.p2align 4,,10
	.p2align 3
.L38:
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L39
	xor	dil, -1
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	rax, QWORD PTR [rdi]
	mov	edx, DWORD PTR publicarray_size[rip]
	cmp	rax, rdx
	jnb	.L41
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	edx, BYTE PTR temp[rip]
	and	dl, BYTE PTR publicarray2[rax]
	mov	BYTE PTR temp[rip], dl
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
	endbr64
	xor	eax, eax
	ret
	.cfi_endproc
.LFE69:
	.size	main, .-main
	.local	last_x.0
	.comm	last_x.0,8,8
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
	.align 16
	.type	secretarray, @object
	.size	secretarray, 16
secretarray:
	.ascii	"\n\025 +6ALWbmny\204\217\232\245"
	.globl	publicarray2
	.align 16
	.type	publicarray2, @object
	.size	publicarray2, 16
publicarray2:
	.string	"\024"
	.zero	14
	.globl	publicarray
	.align 16
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
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
