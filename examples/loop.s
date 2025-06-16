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
	.cfi_offset %rbx, -16
	movq	__unnamed_1@GOTPCREL(%rip), %rbx
	.p2align	4, 0x90
.LBB0_1:                                # %.loop0
                                        # =>This Inner Loop Header: Depth=1
	movq	%rbx, %rdi
	callq	puts@PLT
	jmp	.LBB0_1
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	__unnamed_1,@object             # @0
	.data
	.globl	__unnamed_1
__unnamed_1:
	.asciz	"Hello World"
	.size	__unnamed_1, 12

	.type	__unnamed_2,@object             # @1
	.globl	__unnamed_2
__unnamed_2:
	.asciz	"hello"
	.size	__unnamed_2, 6

	.section	".note.GNU-stack","",@progbits
