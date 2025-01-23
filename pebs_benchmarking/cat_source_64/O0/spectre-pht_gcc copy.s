	.file	"spectre-pht.c"
	.intel_syntax noprefix
	.text
	.globl	publicarray_size
	.data
	.align 4
	.type	publicarray_size, @object
	.size	publicarray_size, 4
publicarray_size:
	.long	16
	.globl	publicarray
	.align 16
	.type	publicarray, @object
	.size	publicarray, 16
publicarray:
	.string	""
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017"
	.globl	publicarray2
	.align 16
	.type	publicarray2, @object
	.size	publicarray2, 16
publicarray2:
	.string	"\024"
	.zero	14
	.globl	secretarray
	.align 16
	.type	secretarray, @object
	.size	secretarray, 16
secretarray:
	.ascii	"\n\025 +6ALWbmny\204\217\232\245"
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.text
	.globl	victim_function_v1
	.type	victim_function_v1, @function
victim_function_v1:
.LFB6:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L3
	mov	rax, QWORD PTR [rsp-8]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L3:
	nop
	ret
	.cfi_endproc
.LFE6:
	.size	victim_function_v1, .-victim_function_v1
	.globl	leakByteLocalFunction
	.type	leakByteLocalFunction, @function
leakByteLocalFunction:
.LFB7:
	.cfi_startproc
	endbr64
	mov	eax, edi
	mov	BYTE PTR [rsp-4], al
	movzx	eax, BYTE PTR [rsp-4]
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
	nop
	ret
	.cfi_endproc
.LFE7:
	.size	leakByteLocalFunction, .-leakByteLocalFunction
	.globl	victim_function_v2
	.type	victim_function_v2, @function
victim_function_v2:
.LFB8:
	.cfi_startproc
	endbr64
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	mov	QWORD PTR [rsp], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp], rax
	jnb	.L7
	mov	rax, QWORD PTR [rsp]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	mov	edi, eax
	call	leakByteLocalFunction
.L7:
	nop
	add	rsp, 8
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE8:
	.size	victim_function_v2, .-victim_function_v2
	.globl	leakByteNoinlineFunction
	.type	leakByteNoinlineFunction, @function
leakByteNoinlineFunction:
.LFB9:
	.cfi_startproc
	endbr64
	mov	eax, edi
	mov	BYTE PTR [rsp-4], al
	movzx	eax, BYTE PTR [rsp-4]
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
	nop
	ret
	.cfi_endproc
.LFE9:
	.size	leakByteNoinlineFunction, .-leakByteNoinlineFunction
	.globl	victim_function_v3
	.type	victim_function_v3, @function
victim_function_v3:
.LFB10:
	.cfi_startproc
	endbr64
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	mov	QWORD PTR [rsp], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp], rax
	jnb	.L11
	mov	rax, QWORD PTR [rsp]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	mov	edi, eax
	call	leakByteNoinlineFunction
.L11:
	nop
	add	rsp, 8
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE10:
	.size	victim_function_v3, .-victim_function_v3
	.globl	victim_function_v4
	.type	victim_function_v4, @function
victim_function_v4:
.LFB11:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L14
	mov	rax, QWORD PTR [rsp-8]
	add	rax, rax
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L14:
	nop
	ret
	.cfi_endproc
.LFE11:
	.size	victim_function_v4, .-victim_function_v4
	.globl	victim_function_v5
	.type	victim_function_v5, @function
victim_function_v5:
.LFB12:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-24], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-24], rax
	jnb	.L19
	mov	rax, QWORD PTR [rsp-24]
	sub	eax, 1
	mov	DWORD PTR [rsp-4], eax
	jmp	.L17
.L18:
	mov	eax, DWORD PTR [rsp-4]
	cdqe
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
	sub	DWORD PTR [rsp-4], 1
.L17:
	cmp	DWORD PTR [rsp-4], 0
	jns	.L18
.L19:
	nop
	ret
	.cfi_endproc
.LFE12:
	.size	victim_function_v5, .-victim_function_v5
	.globl	array_size_mask
	.data
	.align 4
	.type	array_size_mask, @object
	.size	array_size_mask, 4
array_size_mask:
	.long	15
	.text
	.globl	victim_function_v6
	.type	victim_function_v6, @function
victim_function_v6:
.LFB13:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR array_size_mask[rip]
	cdqe
	and	rax, QWORD PTR [rsp-8]
	cmp	QWORD PTR [rsp-8], rax
	jne	.L22
	mov	rax, QWORD PTR [rsp-8]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L22:
	nop
	ret
	.cfi_endproc
.LFE13:
	.size	victim_function_v6, .-victim_function_v6
	.globl	victim_function_v7
	.type	victim_function_v7, @function
victim_function_v7:
.LFB14:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	rax, QWORD PTR last_x.0[rip]
	cmp	QWORD PTR [rsp-8], rax
	jne	.L24
	mov	rax, QWORD PTR [rsp-8]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L24:
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L26
	mov	rax, QWORD PTR [rsp-8]
	mov	QWORD PTR last_x.0[rip], rax
.L26:
	nop
	ret
	.cfi_endproc
.LFE14:
	.size	victim_function_v7, .-victim_function_v7
	.globl	victim_function_v8
	.type	victim_function_v8, @function
victim_function_v8:
.LFB15:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L28
	mov	rax, QWORD PTR [rsp-8]
	add	rax, 1
	jmp	.L29
.L28:
	mov	eax, 0
.L29:
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
	nop
	ret
	.cfi_endproc
.LFE15:
	.size	victim_function_v8, .-victim_function_v8
	.globl	victim_function_v9
	.type	victim_function_v9, @function
victim_function_v9:
.LFB16:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	QWORD PTR [rsp-16], rsi
	mov	rax, QWORD PTR [rsp-16]
	mov	eax, DWORD PTR [rax]
	test	eax, eax
	je	.L32
	mov	rax, QWORD PTR [rsp-8]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L32:
	nop
	ret
	.cfi_endproc
.LFE16:
	.size	victim_function_v9, .-victim_function_v9
	.globl	victim_function_v10
	.type	victim_function_v10, @function
victim_function_v10:
.LFB17:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, esi
	mov	BYTE PTR [rsp-12], al
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L35
	mov	rax, QWORD PTR [rsp-8]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	cmp	BYTE PTR [rsp-12], al
	jne	.L35
	movzx	edx, BYTE PTR publicarray2[rip]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L35:
	nop
	ret
	.cfi_endproc
.LFE17:
	.size	victim_function_v10, .-victim_function_v10
	.globl	victim_function_v11
	.type	victim_function_v11, @function
victim_function_v11:
.LFB18:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L38
	mov	eax, OFFSET FLAT:temp
	movzx	eax, BYTE PTR [rax]
	mov	rdx, QWORD PTR [rsp-8]
	add	rdx, OFFSET FLAT:publicarray
	movzx	edx, BYTE PTR [rdx]
	movzx	edx, dl
	add	rdx, OFFSET FLAT:publicarray2
	movzx	edx, BYTE PTR [rdx]
	sub	eax, edx
	mov	BYTE PTR temp[rip], al
.L38:
	nop
	ret
	.cfi_endproc
.LFE18:
	.size	victim_function_v11, .-victim_function_v11
	.globl	victim_function_v12
	.type	victim_function_v12, @function
victim_function_v12:
.LFB19:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	QWORD PTR [rsp-16], rsi
	mov	rdx, QWORD PTR [rsp-8]
	mov	rax, QWORD PTR [rsp-16]
	add	rax, rdx
	mov	edx, DWORD PTR publicarray_size[rip]
	mov	edx, edx
	cmp	rax, rdx
	jnb	.L41
	mov	rdx, QWORD PTR [rsp-8]
	mov	rax, QWORD PTR [rsp-16]
	add	rax, rdx
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L41:
	nop
	ret
	.cfi_endproc
.LFE19:
	.size	victim_function_v12, .-victim_function_v12
	.globl	is_x_safe
	.type	is_x_safe, @function
is_x_safe:
.LFB20:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L43
	mov	eax, 1
	ret
.L43:
	mov	eax, 0
	ret
	.cfi_endproc
.LFE20:
	.size	is_x_safe, .-is_x_safe
	.globl	victim_function_v13
	.type	victim_function_v13, @function
victim_function_v13:
.LFB21:
	.cfi_startproc
	endbr64
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	mov	QWORD PTR [rsp], rdi
	mov	rax, QWORD PTR [rsp]
	mov	rdi, rax
	call	is_x_safe
	test	eax, eax
	je	.L47
	mov	rax, QWORD PTR [rsp]
	add	rax, OFFSET FLAT:publicarray
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L47:
	nop
	add	rsp, 8
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE21:
	.size	victim_function_v13, .-victim_function_v13
	.globl	victim_function_v14
	.type	victim_function_v14, @function
victim_function_v14:
.LFB22:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	eax, DWORD PTR publicarray_size[rip]
	mov	eax, eax
	cmp	QWORD PTR [rsp-8], rax
	jnb	.L50
	mov	rax, QWORD PTR [rsp-8]
	xor	al, -1
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L50:
	nop
	ret
	.cfi_endproc
.LFE22:
	.size	victim_function_v14, .-victim_function_v14
	.globl	victim_function_v15
	.type	victim_function_v15, @function
victim_function_v15:
.LFB23:
	.cfi_startproc
	endbr64
	mov	QWORD PTR [rsp-8], rdi
	mov	rax, QWORD PTR [rsp-8]
	mov	rax, QWORD PTR [rax]
	mov	edx, DWORD PTR publicarray_size[rip]
	mov	edx, edx
	cmp	rax, rdx
	jnb	.L53
	mov	rax, QWORD PTR [rsp-8]
	mov	rax, QWORD PTR [rax]
	movzx	eax, BYTE PTR publicarray[rax]
	movzx	eax, al
	cdqe
	movzx	edx, BYTE PTR publicarray2[rax]
	movzx	eax, BYTE PTR temp[rip]
	and	eax, edx
	mov	BYTE PTR temp[rip], al
.L53:
	nop
	ret
	.cfi_endproc
.LFE23:
	.size	victim_function_v15, .-victim_function_v15
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	endbr64
	mov	eax, 0
	ret
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.local	last_x.0
	.comm	last_x.0,8,8
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
