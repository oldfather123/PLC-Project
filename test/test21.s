	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_c2p0"
	.file	"test21.c"
	.p2align	1
	.type	factorial,@function
	.globl _start
_start:
    j main       # 调用 main 函数
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
	# 添加系统调用退出
	li a7, 93         # exit 系统调用号
	ecall             # 执行系统调用
	ret               # 这行实际上不会执行到
