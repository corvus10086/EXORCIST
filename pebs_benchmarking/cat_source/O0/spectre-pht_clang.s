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
	mov	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB0_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	mov	al, byte ptr [esp + 4]
	movzx	eax, byte ptr [esp + 4]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	sub	esp, 12
	.cfi_def_cfa_offset 16
	mov	eax, dword ptr [esp + 16]
	mov	eax, dword ptr [esp + 16]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB2_2
# %bb.1:
	mov	eax, dword ptr [esp + 16]
	movzx	eax, byte ptr [eax + publicarray]
	mov	dword ptr [esp], eax
	call	leakByteLocalFunction
.LBB2_2:
	add	esp, 12
	.cfi_def_cfa_offset 4
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
	mov	al, byte ptr [esp + 4]
	movzx	eax, byte ptr [esp + 4]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 16]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB4_2
# %bb.1:
	mov	eax, dword ptr [esp + 16]
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
	mov	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB5_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	shl	eax, 1
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	push	eax
	.cfi_def_cfa_offset 8
	mov	eax, dword ptr [esp + 8]
	mov	eax, dword ptr [esp + 8]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB6_6
# %bb.1:
	mov	eax, dword ptr [esp + 8]
	sub	eax, 1
	mov	dword ptr [esp], eax
.LBB6_2:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [esp], 0
	jl	.LBB6_5
# %bb.3:                                #   in Loop: Header=BB6_2 Depth=1
	mov	eax, dword ptr [esp]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
# %bb.4:                                #   in Loop: Header=BB6_2 Depth=1
	mov	eax, dword ptr [esp]
	add	eax, -1
	mov	dword ptr [esp], eax
	jmp	.LBB6_2
.LBB6_5:
	jmp	.LBB6_6
.LBB6_6:
	pop	eax
	.cfi_def_cfa_offset 4
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
	mov	eax, dword ptr [esp + 4]
	and	eax, dword ptr [array_size_mask]
	cmp	eax, dword ptr [esp + 4]
	jne	.LBB7_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [victim_function_v7.last_x]
	jne	.LBB8_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB8_2:
	mov	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB8_4
# %bb.3:
	mov	eax, dword ptr [esp + 4]
	mov	dword ptr [victim_function_v7.last_x], eax
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
	push	eax
	.cfi_def_cfa_offset 8
	mov	eax, dword ptr [esp + 8]
	mov	eax, dword ptr [esp + 8]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB9_2
# %bb.1:
	mov	eax, dword ptr [esp + 8]
	add	eax, 1
	mov	dword ptr [esp], eax            # 4-byte Spill
	jmp	.LBB9_3
.LBB9_2:
	xor	eax, eax
	mov	dword ptr [esp], eax            # 4-byte Spill
	jmp	.LBB9_3
.LBB9_3:
	mov	eax, dword ptr [esp]            # 4-byte Reload
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
	pop	eax
	.cfi_def_cfa_offset 4
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
	mov	eax, dword ptr [esp + 4]
	mov	eax, dword ptr [esp + 8]
	cmp	dword ptr [eax], 0
	je	.LBB10_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	mov	al, byte ptr [esp + 8]
	mov	eax, dword ptr [esp + 4]
	mov	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB11_4
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [esp + 8]
	cmp	eax, ecx
	jne	.LBB11_3
# %bb.2:
	movzx	ecx, byte ptr [publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB11_3:
	jmp	.LBB11_4
.LBB11_4:
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
	sub	esp, 12
	.cfi_def_cfa_offset 16
	mov	eax, dword ptr [esp + 16]
	mov	eax, dword ptr [esp + 16]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB12_2
# %bb.1:
	mov	eax, dword ptr [esp + 16]
	movzx	eax, byte ptr [eax + publicarray]
	lea	ecx, [publicarray2]
	add	ecx, eax
	mov	eax, esp
	mov	dword ptr [eax + 4], ecx
	mov	dword ptr [eax + 8], 1
	mov	dword ptr [eax], offset temp
	call	memcmp
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB12_2:
	add	esp, 12
	.cfi_def_cfa_offset 4
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
	mov	eax, dword ptr [esp + 4]
	mov	eax, dword ptr [esp + 4]
	add	eax, dword ptr [esp + 8]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB13_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	add	eax, dword ptr [esp + 8]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	push	eax
	.cfi_def_cfa_offset 8
	mov	eax, dword ptr [esp + 8]
	mov	eax, dword ptr [esp + 8]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB14_2
# %bb.1:
	mov	dword ptr [esp], 1
	jmp	.LBB14_3
.LBB14_2:
	mov	dword ptr [esp], 0
.LBB14_3:
	mov	eax, dword ptr [esp]
	pop	ecx
	.cfi_def_cfa_offset 4
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
	sub	esp, 12
	.cfi_def_cfa_offset 16
	mov	eax, dword ptr [esp + 16]
	mov	eax, dword ptr [esp + 16]
	mov	dword ptr [esp], eax
	call	is_x_safe
	cmp	eax, 0
	je	.LBB15_2
# %bb.1:
	mov	eax, dword ptr [esp + 16]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB15_2:
	add	esp, 12
	.cfi_def_cfa_offset 4
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
	mov	eax, dword ptr [esp + 4]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB16_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	xor	eax, 255
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	mov	eax, dword ptr [esp + 4]
	mov	eax, dword ptr [eax]
	cmp	eax, dword ptr [publicarray_size]
	jae	.LBB17_2
# %bb.1:
	mov	eax, dword ptr [esp + 4]
	mov	eax, dword ptr [eax]
	movzx	eax, byte ptr [eax + publicarray]
	movzx	ecx, byte ptr [eax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	push	eax
	.cfi_def_cfa_offset 8
	mov	dword ptr [esp], 0
	xor	eax, eax
	pop	ecx
	.cfi_def_cfa_offset 4
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
	.addrsig_sym leakByteLocalFunction
	.addrsig_sym leakByteNoinlineFunction
	.addrsig_sym memcmp
	.addrsig_sym is_x_safe
	.addrsig_sym publicarray_size
	.addrsig_sym publicarray
	.addrsig_sym publicarray2
	.addrsig_sym secretarray
	.addrsig_sym temp
	.addrsig_sym array_size_mask
	.addrsig_sym victim_function_v7.last_x
