	.text
	.intel_syntax noprefix
	.file	"spectre-pht.c"
	.globl	victim_function_v1              # -- Begin function victim_function_v1
	.p2align	4, 0x90
	.type	victim_function_v1,@function
victim_function_v1:                     # @victim_function_v1
	.cfi_startproc
# %bb.0:
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB0_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	al, dil
	mov	byte ptr [rsp - 1], al
	movzx	eax, byte ptr [rsp - 1]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	push	rax
	.cfi_def_cfa_offset 16
	mov	qword ptr [rsp], rdi
	mov	rax, qword ptr [rsp]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB2_2
# %bb.1:
	mov	rax, qword ptr [rsp]
	movzx	edi, byte ptr [rax + publicarray]
	call	leakByteLocalFunction
.LBB2_2:
	pop	rax
	.cfi_def_cfa_offset 8
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
	mov	al, dil
	mov	byte ptr [rsp - 1], al
	movzx	eax, byte ptr [rsp - 1]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	push	rax
	.cfi_def_cfa_offset 16
	mov	qword ptr [rsp], rdi
	mov	rax, qword ptr [rsp]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB4_2
# %bb.1:
	mov	rax, qword ptr [rsp]
	movzx	edi, byte ptr [rax + publicarray]
	call	leakByteNoinlineFunction
.LBB4_2:
	pop	rax
	.cfi_def_cfa_offset 8
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB5_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	shl	rax, 1
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB6_6
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	sub	rax, 1
                                        # kill: def $eax killed $eax killed $rax
	mov	dword ptr [rsp - 12], eax
.LBB6_2:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [rsp - 12], 0
	jl	.LBB6_5
# %bb.3:                                #   in Loop: Header=BB6_2 Depth=1
	movsxd	rax, dword ptr [rsp - 12]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
# %bb.4:                                #   in Loop: Header=BB6_2 Depth=1
	mov	eax, dword ptr [rsp - 12]
	add	eax, -1
	mov	dword ptr [rsp - 12], eax
	jmp	.LBB6_2
.LBB6_5:
	jmp	.LBB6_6
.LBB6_6:
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	movsxd	rcx, dword ptr [array_size_mask]
	and	rax, rcx
	cmp	rax, qword ptr [rsp - 8]
	jne	.LBB7_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	cmp	rax, qword ptr [victim_function_v7.last_x]
	jne	.LBB8_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB8_2:
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB8_4
# %bb.3:
	mov	rax, qword ptr [rsp - 8]
	mov	qword ptr [victim_function_v7.last_x], rax
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB9_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	add	rax, 1
	mov	qword ptr [rsp - 16], rax       # 8-byte Spill
	jmp	.LBB9_3
.LBB9_2:
	xor	eax, eax
                                        # kill: def $rax killed $eax
	mov	qword ptr [rsp - 16], rax       # 8-byte Spill
	jmp	.LBB9_3
.LBB9_3:
	mov	rax, qword ptr [rsp - 16]       # 8-byte Reload
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
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
	mov	qword ptr [rsp - 8], rdi
	mov	qword ptr [rsp - 16], rsi
	mov	rax, qword ptr [rsp - 16]
	cmp	dword ptr [rax], 0
	je	.LBB10_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	al, sil
	mov	qword ptr [rsp - 8], rdi
	mov	byte ptr [rsp - 9], al
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB11_4
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	movzx	eax, byte ptr [rax + publicarray]
	movzx	ecx, byte ptr [rsp - 9]
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
	push	rax
	.cfi_def_cfa_offset 16
	mov	qword ptr [rsp], rdi
	mov	rax, qword ptr [rsp]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB12_2
# %bb.1:
	mov	rax, qword ptr [rsp]
	movzx	eax, byte ptr [rax + publicarray]
	cdqe
	movabs	rsi, offset publicarray2
	add	rsi, rax
	mov	edi, offset temp
	mov	edx, 1
	call	memcmp
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB12_2:
	pop	rax
	.cfi_def_cfa_offset 8
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
	mov	qword ptr [rsp - 8], rdi
	mov	qword ptr [rsp - 16], rsi
	mov	rax, qword ptr [rsp - 8]
	add	rax, qword ptr [rsp - 16]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB13_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	add	rax, qword ptr [rsp - 16]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	qword ptr [rsp - 16], rdi
	mov	rax, qword ptr [rsp - 16]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB14_2
# %bb.1:
	mov	dword ptr [rsp - 4], 1
	jmp	.LBB14_3
.LBB14_2:
	mov	dword ptr [rsp - 4], 0
.LBB14_3:
	mov	eax, dword ptr [rsp - 4]
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
	push	rax
	.cfi_def_cfa_offset 16
	mov	qword ptr [rsp], rdi
	mov	rdi, qword ptr [rsp]
	call	is_x_safe
	cmp	eax, 0
	je	.LBB15_2
# %bb.1:
	mov	rax, qword ptr [rsp]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
	mov	al, byte ptr [temp]
	movzx	eax, al
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [temp], al
.LBB15_2:
	pop	rax
	.cfi_def_cfa_offset 8
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB16_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	xor	rax, 255
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	qword ptr [rsp - 8], rdi
	mov	rax, qword ptr [rsp - 8]
	mov	rax, qword ptr [rax]
	mov	ecx, dword ptr [publicarray_size]
                                        # kill: def $rcx killed $ecx
	cmp	rax, rcx
	jae	.LBB17_2
# %bb.1:
	mov	rax, qword ptr [rsp - 8]
	mov	rax, qword ptr [rax]
	movzx	eax, byte ptr [rax + publicarray]
                                        # kill: def $rax killed $eax
	movzx	ecx, byte ptr [rax + publicarray2]
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
	mov	dword ptr [rsp - 4], 0
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
