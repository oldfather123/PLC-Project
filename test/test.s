.global _start
_start:
    j main 
.global main                        
main:
addi sp, sp, -48
sw ra, 44(sp)
sw s0, 40(sp)
addi s0, sp, 48
li a0, 0
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
li a0, 1
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
lw a0, -16(s0)
lw a1, -24(s0)
div a2, a1, a0
sw a2, -28(s0)
lw a0, -28(s0)
lw a1, -16(s0)
and a2, a1, a0
sw a2, -32(s0)
lw a1, -32(s0)
seqz a0, a1
sw a0, -36(s0)
lw a0, -36(s0)
bnez a0, if_L0
then_L0:
li a0, 1
sw a0, -40(s0)
lw a0, -40(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
if_L0:
li a0, 0
sw a0, -44(s0)
lw a0, -44(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
