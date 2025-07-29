.global _start
_start:
    j main 
.global main
main:
addi sp, sp, -32
sw ra, 28(sp)
sw s0, 24(sp)
addi s0, sp, 32
li a0, 630
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
li a0, 706
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
lw a0, -24(s0)
lw a1, -16(s0)
add a2, a1, a0
sw a2, -28(s0)
lw a0, -28(s0)
sw a0, -16(s0)
lw a0, -16(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
