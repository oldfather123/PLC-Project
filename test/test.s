.global _start
_start:
    j main 
.global main                        
# function func
func:
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
addi sp, sp, -4
sw ra, 0(sp)
li x6, 8
mv x7, x6
j while_L0
while_L0:
li x8, 10
bge x9, x8, while_L2
while_L1:
li x11, 1
add x12, x9, x11
mv x13, x12
li x14, 3
bne x9, x14, if_L0
j while_L3
if_L0:
bne x9, x7, if_L1
j while_L2
if_L1:
add x15, x16, x9
mv x17, x15
j while_L0
while_L3:
j while_L0
while_L2:
mv a0, x16
lw ra, 0(sp)
addi sp, sp, 4
ret
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x18, 0
mv x9, x18
li x19, 0
mv x16, x19
addi sp, sp, -4
sw x16, 0(sp)
addi sp, sp, -4
sw x9, 0(sp)
call func
mv x20, a0
mv x21, x20
mv a0, x21
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
