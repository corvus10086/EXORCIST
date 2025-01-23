	.file	"spectre-pht.c"
	.intel_syntax noprefix
	.text
	.globl	victim_function_v1
	.type	victim_function_v1, @function
victim_function_v1:
.LFB51:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L1
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	movzx	eax, BYTE PTR temp[rip]
	movzx	edi, dil
	and	al, BYTE PTR publicarray2[rdi]
	mov	BYTE PTR temp[rip], al
	ret
	.cfi_endproc
.LFE52:
	.size	leakByteLocalFunction, .-leakByteLocalFunction
	.globl	victim_function_v2
	.type	victim_function_v2, @function
victim_function_v2:
.LFB53:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	ja	.L6
.L4:
	ret
.L6:
	movzx	edi, BYTE PTR publicarray[rdi]
	call	leakByteLocalFunction
	jmp	.L4
	.cfi_endproc
.LFE53:
	.size	victim_function_v2, .-victim_function_v2
	.globl	leakByteNoinlineFunction
	.type	leakByteNoinlineFunction, @function
leakByteNoinlineFunction:
.LFB54:
	.cfi_startproc
	endbr64
	movzx	eax, BYTE PTR temp[rip]
	movzx	edi, dil
	and	al, BYTE PTR publicarray2[rdi]
	mov	BYTE PTR temp[rip], al
	ret
	.cfi_endproc
.LFE54:
	.size	leakByteNoinlineFunction, .-leakByteNoinlineFunction
	.globl	victim_function_v3
	.type	victim_function_v3, @function
victim_function_v3:
.LFB55:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	ja	.L10
.L8:
	ret
.L10:
	movzx	edi, BYTE PTR publicarray[rdi]
	call	leakByteNoinlineFunction
	jmp	.L8
	.cfi_endproc
.LFE55:
	.size	victim_function_v3, .-victim_function_v3
	.globl	victim_function_v4
	.type	victim_function_v4, @function
victim_function_v4:
.LFB56:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L11
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi+rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L13
	sub	edi, 1
	js	.L13
	movsx	rax, edi
.L15:
	movzx	edx, BYTE PTR temp[rip]
	movzx	ecx, BYTE PTR publicarray[rax]
	and	dl, BYTE PTR publicarray2[rcx]
	mov	BYTE PTR temp[rip], dl
	sub	rax, 1
	test	eax, eax
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
	endbr64
	movsx	rax, DWORD PTR array_size_mask[rip]
	and	rax, rdi
	cmp	rax, rdi
	je	.L19
.L17:
	ret
.L19:
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
	jmp	.L17
	.cfi_endproc
.LFE58:
	.size	victim_function_v6, .-victim_function_v6
	.globl	victim_function_v7
	.type	victim_function_v7, @function
victim_function_v7:
.LFB59:
	.cfi_startproc
	endbr64
	cmp	QWORD PTR last_x.0[rip], rdi
	je	.L23
.L21:
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L20
	mov	QWORD PTR last_x.0[rip], rdi
.L20:
	ret
.L23:
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
	jmp	.L21
	.cfi_endproc
.LFE59:
	.size	victim_function_v7, .-victim_function_v7
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
	.globl	victim_function_v9
	.type	victim_function_v9, @function
victim_function_v9:
.LFB61:
	.cfi_startproc
	endbr64
	cmp	DWORD PTR [rsi], 0
	je	.L27
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L29
	cmp	BYTE PTR publicarray[rdi], sil
	je	.L31
.L29:
	ret
.L31:
	movzx	eax, BYTE PTR temp[rip]
	and	al, BYTE PTR publicarray2[rip]
	mov	BYTE PTR temp[rip], al
	jmp	.L29
	.cfi_endproc
.LFE62:
	.size	victim_function_v10, .-victim_function_v10
	.globl	victim_function_v11
	.type	victim_function_v11, @function
victim_function_v11:
.LFB63:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L32
	movzx	edx, BYTE PTR publicarray[rdi]
	movzx	eax, BYTE PTR temp[rip]
	sub	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	add	rdi, rsi
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rdi, rax
	jnb	.L34
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rdi, rax
	jnb	.L37
	movzx	eax, BYTE PTR temp[rip]
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	eax, DWORD PTR publicarray_size[rip]
	cmp	rax, rdi
	jbe	.L39
	movzx	eax, BYTE PTR temp[rip]
	xor	dil, -1
	movzx	edx, BYTE PTR publicarray[rdi]
	and	al, BYTE PTR publicarray2[rdx]
	mov	BYTE PTR temp[rip], al
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
	endbr64
	mov	rax, QWORD PTR [rdi]
	mov	edx, DWORD PTR publicarray_size[rip]
	cmp	rax, rdx
	jnb	.L41
	movzx	edx, BYTE PTR temp[rip]
	movzx	eax, BYTE PTR publicarray[rax]
	and	dl, BYTE PTR publicarray2[rax]
	mov	BYTE PTR temp[rip], dl
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
	endbr64
	mov	eax, 0
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
