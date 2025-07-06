	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_c2p0"
	.file	"test20.c"
	.globl	func                            # -- Begin function func
	.p2align	1
	.type	func,@function
func:                                   # @func
# %bb.0:
	addi	sp, sp, -160
	sd	ra, 152(sp)                     # 8-byte Folded Spill
	sd	s0, 144(sp)                     # 8-byte Folded Spill
	addi	s0, sp, 160
	li	a0, 1
	sw	a0, -20(s0)
	sw	a0, -24(s0)
	sw	a0, -28(s0)
	sw	a0, -32(s0)
	sw	a0, -36(s0)
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	sw	a0, -68(s0)
	sw	a0, -72(s0)
	sw	a0, -76(s0)
	sw	a0, -80(s0)
	sw	a0, -84(s0)
	sw	a0, -88(s0)
	sw	a0, -92(s0)
	sw	a0, -96(s0)
	sw	a0, -100(s0)
	sw	a0, -104(s0)
	sw	a0, -108(s0)
	sw	a0, -112(s0)
	sw	a0, -116(s0)
	sw	a0, -120(s0)
	sw	a0, -124(s0)
	sw	a0, -128(s0)
	sw	a0, -132(s0)
	sw	a0, -136(s0)
	sw	a0, -140(s0)
	sw	a0, -144(s0)
	sw	a0, -148(s0)
	sw	a0, -152(s0)
	sw	a0, -156(s0)
	lw	a0, -20(s0)
	lw	a1, -24(s0)
	addw	a0, a0, a1
	lw	a1, -28(s0)
	addw	a0, a0, a1
	lw	a1, -32(s0)
	addw	a0, a0, a1
	lw	a1, -36(s0)
	addw	a0, a0, a1
	lw	a1, -40(s0)
	addw	a0, a0, a1
	lw	a1, -44(s0)
	addw	a0, a0, a1
	lw	a1, -48(s0)
	addw	a0, a0, a1
	lw	a1, -52(s0)
	addw	a0, a0, a1
	lw	a1, -56(s0)
	addw	a0, a0, a1
	lw	a1, -60(s0)
	addw	a0, a0, a1
	lw	a1, -64(s0)
	addw	a0, a0, a1
	lw	a1, -68(s0)
	addw	a0, a0, a1
	lw	a1, -72(s0)
	addw	a0, a0, a1
	lw	a1, -76(s0)
	addw	a0, a0, a1
	lw	a1, -80(s0)
	addw	a0, a0, a1
	lw	a1, -84(s0)
	addw	a0, a0, a1
	lw	a1, -88(s0)
	addw	a0, a0, a1
	lw	a1, -92(s0)
	addw	a0, a0, a1
	lw	a1, -96(s0)
	addw	a0, a0, a1
	lw	a1, -100(s0)
	addw	a0, a0, a1
	lw	a1, -104(s0)
	addw	a0, a0, a1
	lw	a1, -108(s0)
	addw	a0, a0, a1
	lw	a1, -112(s0)
	addw	a0, a0, a1
	lw	a1, -116(s0)
	addw	a0, a0, a1
	lw	a1, -120(s0)
	addw	a0, a0, a1
	lw	a1, -124(s0)
	addw	a0, a0, a1
	lw	a1, -128(s0)
	addw	a0, a0, a1
	lw	a1, -132(s0)
	addw	a0, a0, a1
	lw	a1, -136(s0)
	addw	a0, a0, a1
	lw	a1, -140(s0)
	addw	a0, a0, a1
	lw	a1, -144(s0)
	addw	a0, a0, a1
	lw	a1, -148(s0)
	addw	a0, a0, a1
	lw	a1, -152(s0)
	addw	a0, a0, a1
	lw	a1, -156(s0)
	addw	a0, a0, a1
	ld	ra, 152(sp)                     # 8-byte Folded Reload
	ld	s0, 144(sp)                     # 8-byte Folded Reload
	addi	sp, sp, 160
	ret
.Lfunc_end0:
	.size	func, .Lfunc_end0-func
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
	call	func
	sw	a0, -24(s0)
	lw	a0, -24(s0)
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
	.addrsig_sym func
