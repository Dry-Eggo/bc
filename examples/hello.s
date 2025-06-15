	.text
	.file	"hello.bc"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$42, 12(%rsp)
	movl	$42, 8(%rsp)
	movq	__unnamed_1@GOTPCREL(%rip), %rax
	movq	%rax, 16(%rsp)
	movl	$42, %edi
	callq	putint@PLT
	movq	__unnamed_2@GOTPCREL(%rip), %rdi
	callq	puts@PLT
	addq	$24, %rsp
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
	.asciz	"Foo"
	.size	__unnamed_1, 4

	.type	__unnamed_2,@object             # @1
	.globl	__unnamed_2
__unnamed_2:
	.asciz	"Hello World"
	.size	__unnamed_2, 12

	.section	".note.GNU-stack","",@progbits
