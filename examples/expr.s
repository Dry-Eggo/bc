	.text
	.file	"expr.bc"
	.globl	printint                        # -- Begin function printint
	.p2align	4, 0x90
	.type	printint,@function
printint:                               # @printint
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%edi, 4(%rsp)
	callq	putint@PLT
	movq	__unnamed_1@GOTPCREL(%rip), %rdi
	callq	puts@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	printint, .Lfunc_end0-printint
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	xorl	%edi, %edi
	callq	printint@PLT
	xorl	%edi, %edi
	callq	printint@PLT
	movl	$1, %edi
	callq	printint@PLT
	movl	$1, %edi
	callq	printint@PLT
	xorl	%edi, %edi
	callq	printint@PLT
	movl	$1, %edi
	callq	printint@PLT
	xorl	%edi, %edi
	callq	printint@PLT
	movl	$1, %edi
	callq	printint@PLT
	movl	$1, %edi
	callq	printint@PLT
	movl	$1, %edi
	callq	printint@PLT
	xorl	%edi, %edi
	callq	printint@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	__unnamed_1,@object             # @0
	.data
	.globl	__unnamed_1
__unnamed_1:
	.asciz	"\n"
	.size	__unnamed_1, 2

	.section	".note.GNU-stack","",@progbits
