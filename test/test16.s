	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_a2p1_c2p0"
	.file	"test16.c"
	.globl	sum16                           # -- Begin function sum16
	.p2align	1
	.type	sum16,@function
sum16:                                  # @sum16
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	lw	t0, 28(s0)
	lw	t0, 24(s0)
	lw	t0, 20(s0)
	lw	t0, 16(s0)
	lw	t0, 12(s0)
	lw	t0, 8(s0)
	lw	t0, 4(s0)
	lw	t0, 0(s0)
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	sw	a7, -40(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	add	a0, a0, a1
	lw	a1, -20(s0)
	add	a0, a0, a1
	lw	a1, -24(s0)
	add	a0, a0, a1
	lw	a1, -28(s0)
	add	a0, a0, a1
	lw	a1, -32(s0)
	add	a0, a0, a1
	lw	a1, -36(s0)
	add	a0, a0, a1
	lw	a1, -40(s0)
	add	a0, a0, a1
	lw	a1, 0(s0)
	add	a0, a0, a1
	lw	a1, 4(s0)
	add	a0, a0, a1
	lw	a1, 8(s0)
	add	a0, a0, a1
	lw	a1, 12(s0)
	add	a0, a0, a1
	lw	a1, 16(s0)
	add	a0, a0, a1
	lw	a1, 20(s0)
	add	a0, a0, a1
	lw	a1, 24(s0)
	add	a0, a0, a1
	lw	a1, 28(s0)
	add	a0, a0, a1
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end0:
	.size	sum16, .Lfunc_end0-sum16
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -144
	sw	ra, 140(sp)                     # 4-byte Folded Spill
	sw	s0, 136(sp)                     # 4-byte Folded Spill
	sw	s1, 132(sp)                     # 4-byte Folded Spill
	sw	s2, 128(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 144
	li	a0, 0
	sw	a0, -20(s0)
	li	a0, 1
	sw	a0, -96(s0)                     # 4-byte Folded Spill
	sw	a0, -24(s0)
	li	a0, 2
	sw	a0, -100(s0)                    # 4-byte Folded Spill
	sw	a0, -28(s0)
	li	a0, 3
	sw	a0, -104(s0)                    # 4-byte Folded Spill
	sw	a0, -32(s0)
	li	a0, 4
	sw	a0, -108(s0)                    # 4-byte Folded Spill
	sw	a0, -36(s0)
	li	a0, 5
	sw	a0, -40(s0)
	li	a0, 6
	sw	a0, -44(s0)
	li	a0, 7
	sw	a0, -48(s0)
	li	a0, 8
	sw	a0, -52(s0)
	li	a0, 9
	sw	a0, -56(s0)
	li	a0, 10
	sw	a0, -60(s0)
	li	a0, 11
	sw	a0, -64(s0)
	li	a0, 12
	sw	a0, -68(s0)
	li	a0, 13
	sw	a0, -72(s0)
	li	a0, 14
	sw	a0, -76(s0)
	li	a0, 15
	sw	a0, -80(s0)
	li	a0, 16
	sw	a0, -84(s0)
	lw	a0, -24(s0)
	lw	a1, -28(s0)
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	lw	a5, -44(s0)
	lw	a6, -48(s0)
	lw	a7, -52(s0)
	lw	t0, -56(s0)
	lw	t2, -60(s0)
	lw	t3, -64(s0)
	lw	t4, -68(s0)
	lw	t5, -72(s0)
	lw	t6, -76(s0)
	lw	s1, -80(s0)
	lw	s2, -84(s0)
	mv	t1, sp
	sw	s2, 28(t1)
	sw	s1, 24(t1)
	sw	t6, 20(t1)
	sw	t5, 16(t1)
	sw	t4, 12(t1)
	sw	t3, 8(t1)
	sw	t2, 4(t1)
	sw	t0, 0(t1)
	call	sum16
	lw	t4, -108(s0)                    # 4-byte Folded Reload
	lw	t3, -104(s0)                    # 4-byte Folded Reload
	lw	t2, -100(s0)                    # 4-byte Folded Reload
	lw	t0, -96(s0)                     # 4-byte Folded Reload
	sw	a0, -88(s0)
	lw	a0, -24(s0)
	lw	a1, -28(s0)
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	lw	a5, -44(s0)
	lw	a6, -48(s0)
	lw	a7, -52(s0)
	lw	t1, -88(s0)
	lw	t5, -72(s0)
	add	t5, t5, t1
	lw	t6, -76(s0)
	add	t6, t6, t1
	lw	s1, -80(s0)
	add	s1, s1, t1
	lw	s2, -84(s0)
	add	s2, s2, t1
	mv	t1, sp
	sw	s2, 28(t1)
	sw	s1, 24(t1)
	sw	t6, 20(t1)
	sw	t5, 16(t1)
	sw	t4, 12(t1)
	sw	t3, 8(t1)
	sw	t2, 4(t1)
	sw	t0, 0(t1)
	call	sum16
	sw	a0, -92(s0)
	lw	a0, -92(s0)
	srai	a1, a0, 31
	srli	a1, a1, 24
	add	a1, a1, a0
	andi	a1, a1, -256
	sub	a0, a0, a1
	lw	ra, 140(sp)                     # 4-byte Folded Reload
	lw	s0, 136(sp)                     # 4-byte Folded Reload
	lw	s1, 132(sp)                     # 4-byte Folded Reload
	lw	s2, 128(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 144
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
                                        # -- End function
	.ident	"Ubuntu clang version 18.1.3 (1ubuntu1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym sum16
