
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
	pushl	%eax
	calll	.L1pb
.L1pb:
	popl	%ecx
.Ltmp1:
	
	movl	%ecx, -4(%ebp)                  # 4-byte Spill
	movl	8(%ebp), %eax
	movl	8(%ebp), %eax
	movl	array1_size(%ecx), %ecx
	cmpl	%ecx, %eax
	jae	.LBB1_2
# %bb.1:
	movl	-4(%ebp), %eax                  # 4-byte Reload
	movl	8(%ebp), %ecx
	movzbl	array1(%eax,%ecx), %ecx
	shll	$9, %ecx
	movzbl	array2(%eax,%ecx), %edx
	movzbl	temp(%eax), %ecx
	andl	%edx, %ecx
                                        # kill: def $cl killed $cl killed $ecx
	movb	%cl, temp(%eax)
.LBB1_2:
	addl	$4, %esp
	popl	%ebp
	.cfi_def_cfa %esp, 4
	retl
.Lfunc_end1:
	.size	victim_function, .Lfunc_end1-victim_function
	.cfi_endproc
                                        # -- End function
