.global _start
_start:
    j main 
.global main                        
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x4, 0
mv x5, x4
li x6, 0
mv x7, x6
li x8, 8
mv x9, x8
j while_L0
while_L0:
li x11, 10
bge x5, x11, while_L2
while_L1:
li x12, 1
add x13, x5, x12
mv x5, x13
li x14, 3
bne x5, x14, if_L0
j while_L3
if_L0:
bne x5, x9, if_L1
j while_L2
if_L1:
add x15, x7, x5
mv x7, x15
j while_L0
while_L3:
j while_L0
while_L2:
mv a0, x7
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
