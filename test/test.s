.global _start
_start:
    j main 
.global main                        
factorial:
addi sp, sp, -48
sw ra, 44(sp)
sw s0, 40(sp)
addi s0, sp, 48
sw a0, -12(s0)
li a0, 1
sw a0, -16(s0)
lw a1, -16(s0)
lw a0, -12(s0)
bgt a0, a1, if_L0
li a0, 1
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
if_L0:
li a0, 1
sw a0, -32(s0)
lw a0, -32(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -36(s0)
lw a0, -36(s0)
call factorial
sw a0, -40(s0)
lw a0, -40(s0)
lw a1, -12(s0)
mul a2, a1, a0
sw a2, -44(s0)
lw a0, -44(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
main:
addi sp, sp, -32
sw ra, 28(sp)
sw s0, 24(sp)
addi s0, sp, 32
li a0, 5
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
lw a0, -16(s0)
call factorial
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
lw a0, -24(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
