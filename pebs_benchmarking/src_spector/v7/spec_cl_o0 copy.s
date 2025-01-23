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
	movl	last_x(%rip), %ecx
	movslq	%ecx, %rcx
	cmpq	%rcx, %rax
	jne	.LBB1_2
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
	movq	-8(%rbp), %rax
	movslq	array1_size(%rip), %rcx
	cmpq	%rcx, %rax
	jae	.LBB1_4
# %bb.3:
	movq	-8(%rbp), %rax
                                        # kill: def $eax killed $eax killed $rax
	movl	%eax, last_x(%rip)
.LBB1_4:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	victim_function, .Lfunc_end1-victim_function
	.cfi_endproc
                                        # -- End function