.global _start
_start:
    j main 
.global main                        
# function fact
fact:
lw x4, 0(sp)
addi sp, sp, 4
addi sp, sp, -4
sw ra, 0(sp)
li x5, 1
bgt x4, x5, if_L0
then_L0:
li x5, 1
mv a0, x5
lw ra, 0(sp)
addi sp, sp, 4
ret
j if_L1
if_L0:
li x5, 1
sub x6, x4, x5
addi sp, sp, -4
sw x7, 0(sp)
addi sp, sp, -4
sw x6, 0(sp)
addi sp, sp, -4
sw x5, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
addi sp, sp, -4
sw x6, 0(sp)
call fact
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
lw x6, 0(sp)
addi sp, sp, 4
lw x7, 0(sp)
addi sp, sp, 4
mv x7, a0
mul x8, x4, x7
mv a0, x8
lw ra, 0(sp)
addi sp, sp, 4
ret
if_L1:
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
li x5, 5
addi sp, sp, -4
sw x5, 0(sp)
call fact
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
mv x4, a0
mv a0, x4
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
