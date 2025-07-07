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
mv x6, x5
li x7, 0
bgt x4, x7, if_L0
then_L0:
li x8, 1
mv a0, x8
lw ra, 0(sp)
addi sp, sp, 4
ret
j if_L1
if_L0:
j while_L0
while_L0:
li x9, 1
ble x4, x9, while_L2
while_L1:
mul x11, x6, x4
mv x6, x11
li x12, 1
sub x13, x4, x12
mv x4, x13
j while_L0
while_L2:
mv a0, x6
lw ra, 0(sp)
addi sp, sp, 4
ret
if_L1:
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x4, 1
neg x5, x4
mv x6, x5
li x7, 3
neg x8, x7
mv x9, x8
li x11, 0
mv x12, x11
sgt x13, x6, x9
sub x14, x6, x9
li x15, 1
sgt x16, x14, x15
and x17, x13, x16
seqz x18, x17
bnez x18, if_L2
then_L1:
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
addi sp, sp, -4
sw x6, 0(sp)
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
mv x19, a0
mv x12, x19
j if_L3
if_L2:
slt x20, x6, x9
sub x21, x6, x9
or x22, x20, x21
seqz x23, x22
bnez x23, if_L4
then_L2:
add x24, x6, x9
neg x25, x24
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
addi sp, sp, -4
sw x25, 0(sp)
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
mv x26, a0
mv x12, x26
j if_L5
if_L4:
mul x27, x6, x9
addi sp, sp, -4
sw x28, 0(sp)
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
addi sp, sp, -4
sw x27, 0(sp)
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
mv x28, a0
mv x12, x28
if_L5:
if_L3:
j while_L3
while_L3:
li x29, 100
ble x12, x29, while_L5
while_L4:
li x30, 2
rem x31, x12, x30
li x31, 0
bne x31, x31, if_L6
then_L3:
li x4, 2
div x4, x12, x4
mv x12, x4
j if_L7
if_L6:
li x5, 1
sub x5, x12, x5
mv x12, x5
if_L7:
j while_L3
while_L5:
li x7, 8
rem x7, x12, x7
li x8, 3
addi sp, sp, -4
sw x31, 0(sp)
addi sp, sp, -4
sw x30, 0(sp)
addi sp, sp, -4
sw x29, 0(sp)
addi sp, sp, -4
sw x28, 0(sp)
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
addi sp, sp, -4
sw x8, 0(sp)
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
lw x29, 0(sp)
addi sp, sp, 4
lw x30, 0(sp)
addi sp, sp, 4
lw x31, 0(sp)
addi sp, sp, 4
mv x8, a0
div x11, x7, x8
mv a0, x11
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
