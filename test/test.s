.global _start
_start:
    j main 
.global main                        
# function factorial
factorial:
lw x4, 0(sp)
addi sp, sp, 4
addi sp, sp, -4
sw ra, 0(sp)
li x5, 1
li x6, 0
bgt x4, x6, if_L0
then_L0:
li x7, 1
mv a0, x7
lw ra, 0(sp)
addi sp, sp, 4
ret
j if_L1
if_L0:
j while_L0
while_L0:
li x7, 1
ble x4, x7, while_L2
while_L1:
mul x8, x5, x4
mv x5, x8
li x7, 1
sub x9, x4, x7
mv x4, x9
j while_L0
while_L2:
mv a0, x5
lw ra, 0(sp)
addi sp, sp, 4
ret
if_L1:
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x4, -1
li x5, -3
li x6, 0
li x7, 0
bnez x7, if_L2
then_L1:
addi sp, sp, -4
sw x8, 0(sp)
addi sp, sp, -4
sw x7, 0(sp)
addi sp, sp, -4
sw x6, 0(sp)
addi sp, sp, -4
sw x5, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
call factorial
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
lw x6, 0(sp)
addi sp, sp, 4
lw x7, 0(sp)
addi sp, sp, 4
lw x8, 0(sp)
addi sp, sp, 4
mv x8, a0
mv x6, x8
j if_L3
if_L2:
slt x9, x4, x5
sub x11, x4, x5
or x12, x9, x11
seqz x13, x12
bnez x13, if_L4
then_L2:
add x14, x4, x5
neg x15, x14
addi sp, sp, -4
sw x16, 0(sp)
addi sp, sp, -4
sw x15, 0(sp)
addi sp, sp, -4
sw x14, 0(sp)
addi sp, sp, -4
sw x13, 0(sp)
addi sp, sp, -4
sw x12, 0(sp)
addi sp, sp, -4
sw x11, 0(sp)
addi sp, sp, -4
sw x9, 0(sp)
addi sp, sp, -4
sw x8, 0(sp)
addi sp, sp, -4
sw x7, 0(sp)
addi sp, sp, -4
sw x6, 0(sp)
addi sp, sp, -4
sw x5, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
addi sp, sp, -4
sw x15, 0(sp)
call factorial
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
lw x6, 0(sp)
addi sp, sp, 4
lw x7, 0(sp)
addi sp, sp, 4
lw x8, 0(sp)
addi sp, sp, 4
lw x9, 0(sp)
addi sp, sp, 4
lw x11, 0(sp)
addi sp, sp, 4
lw x12, 0(sp)
addi sp, sp, 4
lw x13, 0(sp)
addi sp, sp, 4
lw x14, 0(sp)
addi sp, sp, 4
lw x15, 0(sp)
addi sp, sp, 4
lw x16, 0(sp)
addi sp, sp, 4
mv x16, a0
mv x6, x16
j if_L5
if_L4:
mul x17, x4, x5
addi sp, sp, -4
sw x18, 0(sp)
addi sp, sp, -4
sw x17, 0(sp)
addi sp, sp, -4
sw x16, 0(sp)
addi sp, sp, -4
sw x15, 0(sp)
addi sp, sp, -4
sw x14, 0(sp)
addi sp, sp, -4
sw x13, 0(sp)
addi sp, sp, -4
sw x12, 0(sp)
addi sp, sp, -4
sw x11, 0(sp)
addi sp, sp, -4
sw x9, 0(sp)
addi sp, sp, -4
sw x8, 0(sp)
addi sp, sp, -4
sw x7, 0(sp)
addi sp, sp, -4
sw x6, 0(sp)
addi sp, sp, -4
sw x5, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
addi sp, sp, -4
sw x17, 0(sp)
call factorial
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
lw x6, 0(sp)
addi sp, sp, 4
lw x7, 0(sp)
addi sp, sp, 4
lw x8, 0(sp)
addi sp, sp, 4
lw x9, 0(sp)
addi sp, sp, 4
lw x11, 0(sp)
addi sp, sp, 4
lw x12, 0(sp)
addi sp, sp, 4
lw x13, 0(sp)
addi sp, sp, 4
lw x14, 0(sp)
addi sp, sp, 4
lw x15, 0(sp)
addi sp, sp, 4
lw x16, 0(sp)
addi sp, sp, 4
lw x17, 0(sp)
addi sp, sp, 4
lw x18, 0(sp)
addi sp, sp, 4
mv x18, a0
mv x6, x18
if_L5:
if_L3:
j while_L3
while_L3:
li x19, 100
ble x6, x19, while_L5
while_L4:
li x21, 2
rem x20, x6, x21
li x7, 0
bne x20, x7, if_L6
then_L3:
li x21, 2
div x22, x6, x21
mv x6, x22
j if_L7
if_L6:
li x24, 1
sub x23, x6, x24
mv x6, x23
if_L7:
j while_L3
while_L5:
li x26, 8
rem x25, x6, x26
addi sp, sp, -4
sw x27, 0(sp)
addi sp, sp, -4
sw x26, 0(sp)
addi sp, sp, -4
sw x25, 0(sp)
addi sp, sp, -4
sw x24, 0(sp)
addi sp, sp, -4
sw x23, 0(sp)
addi sp, sp, -4
sw x22, 0(sp)
addi sp, sp, -4
sw x21, 0(sp)
addi sp, sp, -4
sw x20, 0(sp)
addi sp, sp, -4
sw x19, 0(sp)
addi sp, sp, -4
sw x18, 0(sp)
addi sp, sp, -4
sw x17, 0(sp)
addi sp, sp, -4
sw x16, 0(sp)
addi sp, sp, -4
sw x15, 0(sp)
addi sp, sp, -4
sw x14, 0(sp)
addi sp, sp, -4
sw x13, 0(sp)
addi sp, sp, -4
sw x12, 0(sp)
addi sp, sp, -4
sw x11, 0(sp)
addi sp, sp, -4
sw x9, 0(sp)
addi sp, sp, -4
sw x8, 0(sp)
addi sp, sp, -4
sw x7, 0(sp)
addi sp, sp, -4
sw x6, 0(sp)
addi sp, sp, -4
sw x5, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
li x28, 4
addi sp, sp, -4
sw x28, 0(sp)
call factorial
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
lw x6, 0(sp)
addi sp, sp, 4
lw x7, 0(sp)
addi sp, sp, 4
lw x8, 0(sp)
addi sp, sp, 4
lw x9, 0(sp)
addi sp, sp, 4
lw x11, 0(sp)
addi sp, sp, 4
lw x12, 0(sp)
addi sp, sp, 4
lw x13, 0(sp)
addi sp, sp, 4
lw x14, 0(sp)
addi sp, sp, 4
lw x15, 0(sp)
addi sp, sp, 4
lw x16, 0(sp)
addi sp, sp, 4
lw x17, 0(sp)
addi sp, sp, 4
lw x18, 0(sp)
addi sp, sp, 4
lw x19, 0(sp)
addi sp, sp, 4
lw x20, 0(sp)
addi sp, sp, 4
lw x21, 0(sp)
addi sp, sp, 4
lw x22, 0(sp)
addi sp, sp, 4
lw x23, 0(sp)
addi sp, sp, 4
lw x24, 0(sp)
addi sp, sp, 4
lw x25, 0(sp)
addi sp, sp, 4
lw x26, 0(sp)
addi sp, sp, 4
lw x27, 0(sp)
addi sp, sp, 4
lw x28, 0(sp)
addi sp, sp, 4
mv x27, a0
div x29, x25, x27
mv a0, x29
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
