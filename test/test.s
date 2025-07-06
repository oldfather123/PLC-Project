.global _start
_start:
    j main 
.global main                        
# function process
process:
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
addi sp, sp, -4
sw ra, 0(sp)
li x6, 0
mv x7, x6
li x8, 0
mv x9, x8
j while_L0
while_L0:
li x11, 100
bge x9, x11, while_L2
while_L1:
li x12, 1
add x13, x9, x12
mv x9, x13
bge x9, x14, if_L0
j while_L3
if_L0:
ble x9, x15, if_L1
j while_L2
if_L1:
li x16, 3
rem x17, x9, x16
li x18, 0
bne x17, x18, if_L2
then_L0:
li x19, 2
rem x20, x9, x19
li x21, 0
bne x20, x21, if_L4
then_L1:
li x22, 2
mul x23, x9, x22
add x24, x7, x23
mv x7, x24
j if_L5
if_L4:
add x25, x7, x9
mv x7, x25
if_L5:
j if_L3
if_L2:
li x26, 5
rem x27, x9, x26
li x28, 0
bne x27, x28, if_L6
then_L2:
li x29, 3
mul x30, x9, x29
add x31, x7, x30
mv x7, x31
j if_L7
if_L6:
li x4, 0
addi sp, sp, -4
sw x4, 0(sp)
mv x4, x4
j while_L4
while_L4:
bge x4, x9, while_L6
while_L5:
li x5, 2
addi sp, sp, -4
sw x5, 0(sp)
rem x5, x4, x5
li x14, 0
addi sp, sp, -4
sw x14, 0(sp)
bne x5, x14, if_L8
li x14, 1
add x15, x7, x14
addi sp, sp, -4
sw x15, 0(sp)
mv x7, x15
if_L8:
li x15, 10
ble x4, x15, if_L9
j while_L6
if_L9:
li x6, 1
addi sp, sp, -4
sw x6, 0(sp)
add x6, x4, x6
mv x4, x6
j while_L4
while_L6:
if_L7:
if_L3:
j while_L0
while_L3:
j while_L0
while_L2:
mv a0, x7
lw ra, 0(sp)
addi sp, sp, 4
ret
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x8, 5
addi sp, sp, -4
sw x8, 0(sp)
li x8, 20
addi sp, sp, -4
sw x8, 0(sp)
addi sp, sp, -4
sw x8, 0(sp)
call process
mv x11, a0
mv x11, x11
addi sp, sp, -4
sw x11, 0(sp)
li x12, 10
addi sp, sp, -4
sw x12, 0(sp)
li x12, 30
addi sp, sp, -4
sw x12, 0(sp)
addi sp, sp, -4
sw x12, 0(sp)
call process
mv x13, a0
mv x13, x13
addi sp, sp, -4
sw x13, 0(sp)
add x16, x11, x13
addi sp, sp, -4
sw x16, 0(sp)
mv a0, x16
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
