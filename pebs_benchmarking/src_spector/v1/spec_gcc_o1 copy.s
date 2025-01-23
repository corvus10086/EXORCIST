
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rdi, %rax
	jbe	.L2
	leaq	array1(%rip), %rax
	movzbl	(%rax,%rdi), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	movzbl	(%rdx,%rax), %eax
	andb	%al, temp(%rip)
.L2:
	ret
	.cfi_endproc
.LFE5690:
	.size	victim_function, .-victim_function
