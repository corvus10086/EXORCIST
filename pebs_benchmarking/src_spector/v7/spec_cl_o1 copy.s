	.globl	victim_function                 # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:
	movslq	last_x(%rip), %rax
	cmpq	%rdi, %rax
	je	.LBB1_1
# %bb.2:
	cmpq	$15, %rdi
	jbe	.LBB1_3
.LBB1_4:
	retq
.LBB1_1:
	leaq	array1(%rip), %rax
	movzbl	(%rdi,%rax), %eax
	shlq	$9, %rax
	leaq	array2(%rip), %rcx
	movb	(%rax,%rcx), %al
	andb	%al, temp(%rip)
	cmpq	$15, %rdi
	ja	.LBB1_4
.LBB1_3:
	movl	%edi, last_x(%rip)
	retq
.Lfunc_end1:
	.size	victim_function, .Lfunc_end1-victim_function
	.cfi_endproc
                                        # -- End function