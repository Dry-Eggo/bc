	.text
	.file	"loop.bcs"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	movl	$0, 12(%rsp)
	movq	__unnamed_1@GOTPCREL(%rip), %rbx
	.p2align	4, 0x90
.LBB0_1:                                # %.loop0
                                        # =>This Inner Loop Header: Depth=1
	movl	12(%rsp), %edi
	callq	putint@PLT
	movq	%rbx, %rdi
	callq	puts@PLT
	incl	12(%rsp)
	jmp	.LBB0_1
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	__unnamed_1,@object             # @0
	.data
	.globl	__unnamed_1
__unnamed_1:
	.asciz	"\n"
	.size	__unnamed_1, 2

	.section	".note.GNU-stack","",@progbits
