	.text
	.file	"if_else.bc"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$0, 4(%rsp)
	movl	$7, (%rsp)
	movb	$1, %al
	testb	%al, %al
	jne	.LBB0_2
# %bb.1:                                # %.if0
	movq	__unnamed_1@GOTPCREL(%rip), %rdi
	jmp	.LBB0_7
.LBB0_2:                                # %.if0.else
	movl	4(%rsp), %eax
	addl	(%rsp), %eax
	cmpl	$5, %eax
	jne	.LBB0_4
# %bb.3:                                # %.if9
	movq	__unnamed_2@GOTPCREL(%rip), %rdi
	jmp	.LBB0_7
.LBB0_4:                                # %.if9.else
	xorl	%eax, %eax
	testb	%al, %al
	jne	.LBB0_6
# %bb.5:                                # %.if18
	movq	__unnamed_3@GOTPCREL(%rip), %rdi
	jmp	.LBB0_7
.LBB0_6:                                # %.if18.else
	movq	__unnamed_4@GOTPCREL(%rip), %rdi
.LBB0_7:                                # %.if0.done
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
	.asciz	"true\n"
	.size	__unnamed_1, 6

	.type	__unnamed_2,@object             # @1
	.globl	__unnamed_2
__unnamed_2:
	.asciz	"Close\n"
	.size	__unnamed_2, 7

	.type	__unnamed_3,@object             # @2
	.globl	__unnamed_3
	.p2align	4, 0x0
__unnamed_3:
	.asciz	"Man u got God on ur side\n"
	.size	__unnamed_3, 26

	.type	__unnamed_4,@object             # @3
	.globl	__unnamed_4
__unnamed_4:
	.asciz	"GodDamnit\n"
	.size	__unnamed_4, 11

	.section	".note.GNU-stack","",@progbits
