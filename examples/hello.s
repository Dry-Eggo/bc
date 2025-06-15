	.text
	.file	"hello.bc"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	__unnamed_1@GOTPCREL(%rip), %rdi
	callq	puts@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
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

	.section	".note.GNU-stack","",@progbits
