	.text
	.intel_syntax noprefix
	.file	"spectre-pht.c"
	.globl	victim_function_v1              # -- Begin function victim_function_v1
	.p2align	4, 0x90
	.type	victim_function_v1,@function
victim_function_v1:                     # @victim_function_v1
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB0_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB0_2:
	ret
.Lfunc_end0:
	.size	victim_function_v1, .Lfunc_end0-victim_function_v1
	.cfi_endproc
                                        # -- End function
	.globl	leakByteLocalFunction           # -- Begin function leakByteLocalFunction
	.p2align	4, 0x90
	.type	leakByteLocalFunction,@function
leakByteLocalFunction:                  # @leakByteLocalFunction
	.cfi_startproc
# %bb.0:
	mov	eax, edi
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
	ret
.Lfunc_end1:
	.size	leakByteLocalFunction, .Lfunc_end1-leakByteLocalFunction
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v2              # -- Begin function victim_function_v2
	.p2align	4, 0x90
	.type	victim_function_v2,@function
victim_function_v2:                     # @victim_function_v2
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB2_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB2_2:
	ret
.Lfunc_end2:
	.size	victim_function_v2, .Lfunc_end2-victim_function_v2
	.cfi_endproc
                                        # -- End function
	.globl	leakByteNoinlineFunction        # -- Begin function leakByteNoinlineFunction
	.p2align	4, 0x90
	.type	leakByteNoinlineFunction,@function
leakByteNoinlineFunction:               # @leakByteNoinlineFunction
	.cfi_startproc
# %bb.0:
	mov	eax, edi
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
	ret
.Lfunc_end3:
	.size	leakByteNoinlineFunction, .Lfunc_end3-leakByteNoinlineFunction
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v3              # -- Begin function victim_function_v3
	.p2align	4, 0x90
	.type	victim_function_v3,@function
victim_function_v3:                     # @victim_function_v3
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB4_1
# %bb.2:
	movzx	edi, byte ptr [rdi + publicarray]
	jmp	leakByteNoinlineFunction        # TAILCALL
.LBB4_1:
	ret
.Lfunc_end4:
	.size	victim_function_v3, .Lfunc_end4-victim_function_v3
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v4              # -- Begin function victim_function_v4
	.p2align	4, 0x90
	.type	victim_function_v4,@function
victim_function_v4:                     # @victim_function_v4
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB5_2
# %bb.1:
	movzx	eax, byte ptr [rdi + rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB5_2:
	ret
.Lfunc_end5:
	.size	victim_function_v4, .Lfunc_end5-victim_function_v4
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v5              # -- Begin function victim_function_v5
	.p2align	4, 0x90
	.type	victim_function_v5,@function
victim_function_v5:                     # @victim_function_v5
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB6_7
# %bb.1:
	mov	ecx, edi
	add	ecx, -1
	js	.LBB6_7
# %bb.2:
	mov	eax, ecx
	and	edi, 3
	je	.LBB6_5
# %bb.3:
	mov	eax, ecx
	.p2align	4, 0x90
.LBB6_4:                                # =>This Inner Loop Header: Depth=1
	mov	edx, eax
	movzx	edx, byte ptr [rdx + publicarray]
	movzx	edx, byte ptr [rdx + publicarray2]
	and	byte ptr [rip + temp], dl
	add	eax, -1
	add	edi, -1
	jne	.LBB6_4
.LBB6_5:
	cmp	ecx, 3
	jb	.LBB6_7
	.p2align	4, 0x90
.LBB6_6:                                # =>This Inner Loop Header: Depth=1
	mov	ecx, eax
	movzx	ecx, byte ptr [rcx + publicarray]
	movzx	ecx, byte ptr [rcx + publicarray2]
	and	byte ptr [rip + temp], cl
	lea	ecx, [rax - 1]
	movzx	ecx, byte ptr [rcx + publicarray]
	movzx	ecx, byte ptr [rcx + publicarray2]
	and	byte ptr [rip + temp], cl
	lea	ecx, [rax - 2]
	movzx	ecx, byte ptr [rcx + publicarray]
	movzx	ecx, byte ptr [rcx + publicarray2]
	and	byte ptr [rip + temp], cl
	lea	ecx, [rax - 3]
	movzx	ecx, byte ptr [rcx + publicarray]
	movzx	ecx, byte ptr [rcx + publicarray2]
	and	byte ptr [rip + temp], cl
	lea	ecx, [rax - 4]
	cmp	eax, 3
	mov	eax, ecx
	jg	.LBB6_6
.LBB6_7:
	ret
.Lfunc_end6:
	.size	victim_function_v5, .Lfunc_end6-victim_function_v5
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v6              # -- Begin function victim_function_v6
	.p2align	4, 0x90
	.type	victim_function_v6,@function
victim_function_v6:                     # @victim_function_v6
	.cfi_startproc
# %bb.0:
	movsxd	rax, dword ptr [rip + array_size_mask]
	not	rax
	test	rdi, rax
	jne	.LBB7_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB7_2:
	ret
.Lfunc_end7:
	.size	victim_function_v6, .Lfunc_end7-victim_function_v6
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v7              # -- Begin function victim_function_v7
	.p2align	4, 0x90
	.type	victim_function_v7,@function
victim_function_v7:                     # @victim_function_v7
	.cfi_startproc
# %bb.0:
	cmp	qword ptr [rip + victim_function_v7.last_x], rdi
	jne	.LBB8_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB8_2:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB8_4
# %bb.3:
	mov	qword ptr [rip + victim_function_v7.last_x], rdi
.LBB8_4:
	ret
.Lfunc_end8:
	.size	victim_function_v7, .Lfunc_end8-victim_function_v7
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v8              # -- Begin function victim_function_v8
	.p2align	4, 0x90
	.type	victim_function_v8,@function
victim_function_v8:                     # @victim_function_v8
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	lea	rcx, [rdi + 1]
	xor	edx, edx
	cmp	rax, rdi
	cmova	rdx, rcx
	movzx	eax, byte ptr [rdx + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
	ret
.Lfunc_end9:
	.size	victim_function_v8, .Lfunc_end9-victim_function_v8
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v9              # -- Begin function victim_function_v9
	.p2align	4, 0x90
	.type	victim_function_v9,@function
victim_function_v9:                     # @victim_function_v9
	.cfi_startproc
# %bb.0:
	cmp	dword ptr [rsi], 0
	je	.LBB10_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB10_2:
	ret
.Lfunc_end10:
	.size	victim_function_v9, .Lfunc_end10-victim_function_v9
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v10             # -- Begin function victim_function_v10
	.p2align	4, 0x90
	.type	victim_function_v10,@function
victim_function_v10:                    # @victim_function_v10
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB11_3
# %bb.1:
	cmp	byte ptr [rdi + publicarray], sil
	jne	.LBB11_3
# %bb.2:
	mov	al, byte ptr [rip + publicarray2]
	and	byte ptr [rip + temp], al
.LBB11_3:
	ret
.Lfunc_end11:
	.size	victim_function_v10, .Lfunc_end11-victim_function_v10
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v11             # -- Begin function victim_function_v11
	.p2align	4, 0x90
	.type	victim_function_v11,@function
victim_function_v11:                    # @victim_function_v11
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB12_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	sub	byte ptr [rip + temp], al
.LBB12_2:
	ret
.Lfunc_end12:
	.size	victim_function_v11, .Lfunc_end12-victim_function_v11
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v12             # -- Begin function victim_function_v12
	.p2align	4, 0x90
	.type	victim_function_v12,@function
victim_function_v12:                    # @victim_function_v12
	.cfi_startproc
# %bb.0:
	add	rdi, rsi
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rdi, rax
	jae	.LBB13_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB13_2:
	ret
.Lfunc_end13:
	.size	victim_function_v12, .Lfunc_end13-victim_function_v12
	.cfi_endproc
                                        # -- End function
	.globl	is_x_safe                       # -- Begin function is_x_safe
	.p2align	4, 0x90
	.type	is_x_safe,@function
is_x_safe:                              # @is_x_safe
	.cfi_startproc
# %bb.0:
	mov	ecx, dword ptr [rip + publicarray_size]
	xor	eax, eax
	cmp	rcx, rdi
	seta	al
	ret
.Lfunc_end14:
	.size	is_x_safe, .Lfunc_end14-is_x_safe
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v13             # -- Begin function victim_function_v13
	.p2align	4, 0x90
	.type	victim_function_v13,@function
victim_function_v13:                    # @victim_function_v13
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB15_2
# %bb.1:
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB15_2:
	ret
.Lfunc_end15:
	.size	victim_function_v13, .Lfunc_end15-victim_function_v13
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v14             # -- Begin function victim_function_v14
	.p2align	4, 0x90
	.type	victim_function_v14,@function
victim_function_v14:                    # @victim_function_v14
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [rip + publicarray_size]
	cmp	rax, rdi
	jbe	.LBB16_2
# %bb.1:
	xor	rdi, 255
	movzx	eax, byte ptr [rdi + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB16_2:
	ret
.Lfunc_end16:
	.size	victim_function_v14, .Lfunc_end16-victim_function_v14
	.cfi_endproc
                                        # -- End function
	.globl	victim_function_v15             # -- Begin function victim_function_v15
	.p2align	4, 0x90
	.type	victim_function_v15,@function
victim_function_v15:                    # @victim_function_v15
	.cfi_startproc
# %bb.0:
	mov	rax, qword ptr [rdi]
	mov	ecx, dword ptr [rip + publicarray_size]
	cmp	rax, rcx
	jae	.LBB17_2
# %bb.1:
	movzx	eax, byte ptr [rax + publicarray]
	mov	al, byte ptr [rax + publicarray2]
	and	byte ptr [rip + temp], al
.LBB17_2:
	ret
.Lfunc_end17:
	.size	victim_function_v15, .Lfunc_end17-victim_function_v15
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	xor	eax, eax
	ret
.Lfunc_end18:
	.size	main, .Lfunc_end18-main
	.cfi_endproc
                                        # -- End function
	.type	publicarray_size,@object        # @publicarray_size
	.data
	.globl	publicarray_size
	.p2align	2
publicarray_size:
	.long	16                              # 0x10
	.size	publicarray_size, 4

	.type	publicarray,@object             # @publicarray
	.globl	publicarray
	.p2align	4
publicarray:
	.ascii	"\000\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017"
	.size	publicarray, 16

	.type	publicarray2,@object            # @publicarray2
	.globl	publicarray2
	.p2align	4
publicarray2:
	.byte	20                              # 0x14
	.zero	15
	.size	publicarray2, 16

	.type	secretarray,@object             # @secretarray
	.globl	secretarray
	.p2align	4
secretarray:
	.ascii	"\n\025 +6ALWbmny\204\217\232\245"
	.size	secretarray, 16

	.type	temp,@object                    # @temp
	.bss
	.globl	temp
temp:
	.byte	0                               # 0x0
	.size	temp, 1

	.type	array_size_mask,@object         # @array_size_mask
	.data
	.globl	array_size_mask
	.p2align	2
array_size_mask:
	.long	15                              # 0xf
	.size	array_size_mask, 4

	.type	victim_function_v7.last_x,@object # @victim_function_v7.last_x
	.local	victim_function_v7.last_x
	.comm	victim_function_v7.last_x,8,8
	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym secretarray
	.addrsig_sym temp
