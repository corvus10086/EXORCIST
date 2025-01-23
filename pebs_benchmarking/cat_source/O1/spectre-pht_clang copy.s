	.text
	.intel_syntax noprefix
	.file	"spectre-pht.c"
	.globl	victim_function_v1              # -- Begin function victim_function_v1
	.p2align	4, 0x90
	.type	victim_function_v1,@function
victim_function_v1:                     # @victim_function_v1
	.cfi_startproc
# %bb.0:
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB0_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	movzx	eax, byte ptr [esp + 4]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB2_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	movzx	eax, byte ptr [esp + 4]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	sub	esp, 12
	.cfi_def_cfa_offset 16
	mov	eax, dword ptr [esp + 16]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB4_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	dword ptr [esp], eax
	call	leakByteNoinlineFunction
.LBB4_2:
	add	esp, 12
	.cfi_def_cfa_offset 4
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB5_2
# %bb.1:
	movzx	eax, byte ptr [eax + eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB6_3
	.p2align	4, 0x90
# %bb.2:
	add	eax, -1
	js	.LBB6_3
.LBB6_1:                                # =>This Inner Loop Header: Depth=1
	movzx	ecx, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [ecx + publicarray2]
	and	byte ptr [temp], cl
	add	eax, -1
	jns	.LBB6_1
.LBB6_3:
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
	mov	eax, dword ptr [esp + 4]
	mov	ecx, dword ptr [array_size_mask]
	not	ecx
	test	eax, ecx
	jne	.LBB7_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [victim_function_v7.last_x], eax
	je	.LBB8_1
# %bb.2:
	cmp	dword ptr [publicarray_size], eax
	ja	.LBB8_3
.LBB8_4:
	ret
.LBB8_1:
	movzx	ecx, byte ptr [eax + publicarray]
	mov	cl, byte ptr [ecx + publicarray2]
	and	byte ptr [temp], cl
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB8_4
.LBB8_3:
	mov	dword ptr [victim_function_v7.last_x], eax
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
	mov	eax, dword ptr [esp + 4]
	lea	ecx, [eax + 1]
	xor	edx, edx
	cmp	dword ptr [publicarray_size], eax
	cmova	edx, ecx
	movzx	eax, byte ptr [edx + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 8]
	cmp	dword ptr [eax], 0
	je	.LBB10_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB11_3
# %bb.1:
	mov	cl, byte ptr [esp + 8]
	cmp	byte ptr [eax + publicarray], cl
	jne	.LBB11_3
# %bb.2:
	mov	al, byte ptr [publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB12_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	sub	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 8]
	add	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB13_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	ecx, dword ptr [publicarray_size]
	xor	eax, eax
	cmp	ecx, dword ptr [esp + 4]
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB15_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	dword ptr [publicarray_size], eax
	jbe	.LBB16_2
# %bb.1:
	xor	eax, 255
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	mov	eax, dword ptr [eax]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB17_2
# %bb.1:
	movzx	eax, byte ptr [eax + publicarray]
	mov	al, byte ptr [eax + publicarray2]
	and	byte ptr [temp], al
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
publicarray:
	.ascii	"\000\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017"
	.size	publicarray, 16

	.type	publicarray2,@object            # @publicarray2
	.globl	publicarray2
publicarray2:
	.byte	20                              # 0x14
	.zero	15
	.size	publicarray2, 16

	.type	secretarray,@object             # @secretarray
	.globl	secretarray
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
	.comm	victim_function_v7.last_x,4,4
	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym secretarray
	.addrsig_sym temp
