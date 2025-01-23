	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.L3
	leaq	array1(%rip), %rax
	leaq	array2(%rip), %rdx
	movzbl	(%rax,%rdi), %eax
	sall	$9, %eax
	cltq
	movzbl	(%rdx,%rax), %eax
	andb	%al, temp(%rip)
.L3:
	ret
	.cfi_endproc
.LFE5690:
	.size	victim_function, .-victim_function
	.p2align 4