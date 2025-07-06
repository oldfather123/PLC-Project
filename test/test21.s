	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_c2p0"
	.file	"test21.c"
	.globl	factorial                       # -- Begin function factorial
	.p2align	1
	.type	factorial,@function
factorial:                              # @factorial
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x11 killed $x10
	sw	a0, -24(s0)
	lw	a1, -24(s0)
	li	a0, 1
	blt	a0, a1, .LBB0_2
	j	.LBB0_1
.LBB0_1:
	li	a0, 1
	sw	a0, -20(s0)
	j	.LBB0_3
.LBB0_2:
	lw	a0, -24(s0)
	sd	a0, -32(s0)                     # 8-byte Folded Spill
	addiw	a0, a0, -1
	call	factorial
	mv	a1, a0
	ld	a0, -32(s0)                     # 8-byte Folded Reload
	mulw	a0, a0, a1
	sw	a0, -20(s0)
	j	.LBB0_3
.LBB0_3:
	lw	a0, -20(s0)
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	factorial, .Lfunc_end0-factorial
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
	li	a0, 0
	sw	a0, -20(s0)
	li	a0, 5
	sw	a0, -24(s0)
	lw	a0, -24(s0)
	call	factorial
	sw	a0, -28(s0)
	lw	a0, -28(s0)
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
                                        # -- End function
	.ident	"Ubuntu clang version 18.1.3 (1ubuntu1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym factorial
