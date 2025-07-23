	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_a2p1_c2p0"
	.file	"test16.c"
	.globl	is_prime                        # -- Begin function is_prime
	.p2align	1
	.type	is_prime,@function
is_prime:                               # @is_prime
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -16(s0)
	lw	a1, -16(s0)
	li	a0, 1
	blt	a0, a1, .LBB0_2
	j	.LBB0_1
.LBB0_1:
	li	a0, 0
	sw	a0, -12(s0)
	j	.LBB0_14
.LBB0_2:
	lw	a1, -16(s0)
	li	a0, 3
	blt	a0, a1, .LBB0_4
	j	.LBB0_3
.LBB0_3:
	li	a0, 1
	sw	a0, -12(s0)
	j	.LBB0_14
.LBB0_4:
	lw	a0, -16(s0)
	srli	a1, a0, 31
	add	a1, a1, a0
	andi	a1, a1, -2
	sub	a0, a0, a1
	beqz	a0, .LBB0_6
	j	.LBB0_5
.LBB0_5:
	lw	a0, -16(s0)
	lui	a1, 699051
	addi	a1, a1, -1365
	mul	a0, a0, a1
	lui	a1, 174763
	addi	a1, a1, -1366
	add	a1, a1, a0
	lui	a0, 349525
	addi	a0, a0, 1364
	bltu	a0, a1, .LBB0_7
	j	.LBB0_6
.LBB0_6:
	li	a0, 0
	sw	a0, -12(s0)
	j	.LBB0_14
.LBB0_7:
	li	a0, 5
	sw	a0, -20(s0)
	j	.LBB0_8
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -20(s0)
	mul	a1, a0, a0
	lw	a0, -16(s0)
	blt	a0, a1, .LBB0_13
	j	.LBB0_9
.LBB0_9:                                #   in Loop: Header=BB0_8 Depth=1
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	rem	a0, a0, a1
	beqz	a0, .LBB0_11
	j	.LBB0_10
.LBB0_10:                               #   in Loop: Header=BB0_8 Depth=1
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	addi	a1, a1, 2
	rem	a0, a0, a1
	bnez	a0, .LBB0_12
	j	.LBB0_11
.LBB0_11:
	li	a0, 0
	sw	a0, -12(s0)
	j	.LBB0_14
.LBB0_12:                               #   in Loop: Header=BB0_8 Depth=1
	lw	a0, -20(s0)
	addi	a0, a0, 6
	sw	a0, -20(s0)
	j	.LBB0_8
.LBB0_13:
	li	a0, 1
	sw	a0, -12(s0)
	j	.LBB0_14
.LBB0_14:
	lw	a0, -12(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	is_prime, .Lfunc_end0-is_prime
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	li	a0, 0
	sw	a0, -12(s0)
	lui	a1, 3
	addi	a1, a1, 315
	sw	a1, -16(s0)
	lui	a1, 8
	addi	a2, a1, -199
	sw	a2, -20(s0)
	addi	a1, a1, -1885
	sw	a1, -24(s0)
	sw	a0, -28(s0)
	lw	a0, -16(s0)
	call	is_prime
	beqz	a0, .LBB1_8
	j	.LBB1_1
.LBB1_1:
	lw	a0, -20(s0)
	call	is_prime
	beqz	a0, .LBB1_3
	j	.LBB1_2
.LBB1_2:
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	mul	a0, a0, a1
	sw	a0, -28(s0)
	j	.LBB1_7
.LBB1_3:
	lw	a0, -24(s0)
	call	is_prime
	beqz	a0, .LBB1_5
	j	.LBB1_4
.LBB1_4:
	lw	a0, -16(s0)
	lw	a1, -24(s0)
	mul	a0, a0, a1
	sw	a0, -28(s0)
	j	.LBB1_6
.LBB1_5:
	lw	a0, -16(s0)
	sw	a0, -28(s0)
	j	.LBB1_6
.LBB1_6:
	j	.LBB1_7
.LBB1_7:
	j	.LBB1_18
.LBB1_8:
	lw	a0, -20(s0)
	call	is_prime
	beqz	a0, .LBB1_13
	j	.LBB1_9
.LBB1_9:
	lw	a0, -24(s0)
	call	is_prime
	beqz	a0, .LBB1_11
	j	.LBB1_10
.LBB1_10:
	lw	a0, -20(s0)
	lw	a1, -24(s0)
	mul	a0, a0, a1
	sw	a0, -28(s0)
	j	.LBB1_12
.LBB1_11:
	lw	a0, -20(s0)
	sw	a0, -28(s0)
	j	.LBB1_12
.LBB1_12:
	j	.LBB1_17
.LBB1_13:
	lw	a0, -24(s0)
	call	is_prime
	beqz	a0, .LBB1_15
	j	.LBB1_14
.LBB1_14:
	lw	a0, -24(s0)
	sw	a0, -28(s0)
	j	.LBB1_16
.LBB1_15:
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	add	a0, a0, a1
	lw	a1, -24(s0)
	add	a0, a0, a1
	sw	a0, -28(s0)
	j	.LBB1_16
.LBB1_16:
	j	.LBB1_17
.LBB1_17:
	j	.LBB1_18
.LBB1_18:
	lw	a0, -28(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
                                        # -- End function
	.ident	"Ubuntu clang version 18.1.3 (1ubuntu1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym is_prime
