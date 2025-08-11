.global _start
_start:
    j main 
.global main
func:
addi sp, sp, -64
sw ra, 60(sp)
sw s0, 56(sp)
addi s0, sp, 64
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
li a0, 4
sw a0, -20(s0)
lw a0, -20(s0)
lw a1, -16(s0)
add a2, a1, a0
sw a2, -24(s0)
lw a0, -24(s0)
sw a0, -28(s0)
li a0, 4
sw a0, -32(s0)
lw a0, -32(s0)
lw a1, -28(s0)
add a2, a1, a0
sw a2, -36(s0)
lw a0, -36(s0)
sw a0, -28(s0)
lw a0, -28(s0)
sw a0, -40(s0)
li a0, 2
sw a0, -44(s0)
lw a0, -44(s0)
lw a1, -40(s0)
mul a2, a1, a0
sw a2, -48(s0)
lw a0, -48(s0)
sw a0, -52(s0)
li a0, 100
sw a0, -56(s0)
lw a0, -56(s0)
sw a0, -60(s0)
lw a0, -52(s0)
sw a0, -64(s0)
lw a0, -64(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
main:
addi sp, sp, -48
sw ra, 44(sp)
sw s0, 40(sp)
addi s0, sp, 48
li a0, 1
sw a0, -12(s0)
li a0, 2
sw a0, -16(s0)
lw a0, -16(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
lw a0, -24(s0)
call func
sw a0, -32(s0)
lw a0, -32(s0)
sw a0, -36(s0)
lw a0, -36(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
