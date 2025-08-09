.global _start
_start:
    j main 
.global main
control_structures:
addi sp, sp, -144
sw ra, 140(sp)
sw s0, 136(sp)
addi s0, sp, 144
sw a0, -12(s0)
li a0, 0
sw a0, -16(s0)
lw a1, -16(s0)
lw a0, -12(s0)
ble a0, a1, if_L0
li a0, 1
sw a0, -28(s0)
lw a0, -28(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -32(s0)
lw a0, -32(s0)
sw a0, -12(s0)
if_L0:
li a0, 10
sw a0, -36(s0)
lw a1, -36(s0)
lw a0, -12(s0)
bge a0, a1, if_L1
then_L0:
li a0, 2
sw a0, -48(s0)
lw a0, -48(s0)
lw a1, -12(s0)
mul a2, a1, a0
sw a2, -52(s0)
lw a0, -52(s0)
sw a0, -12(s0)
j if_L2
if_L1:
li a0, 2
sw a0, -56(s0)
lw a0, -56(s0)
lw a1, -12(s0)
div a2, a1, a0
sw a2, -60(s0)
lw a0, -60(s0)
sw a0, -12(s0)
if_L2:
li a0, 5
sw a0, -64(s0)
lw a1, -64(s0)
lw a0, -12(s0)
ble a0, a1, if_L3
li a0, 20
sw a0, -76(s0)
lw a1, -76(s0)
lw a0, -12(s0)
bge a0, a1, if_L4
then_L1:
li a0, 5
sw a0, -88(s0)
lw a0, -88(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -92(s0)
lw a0, -92(s0)
sw a0, -12(s0)
j if_L5
if_L4:
li a0, 5
sw a0, -96(s0)
lw a0, -96(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -100(s0)
lw a0, -100(s0)
sw a0, -12(s0)
if_L5:
if_L3:
j while_L0
while_L0:
li a0, 1
sw a0, -104(s0)
lw a1, -104(s0)
lw a0, -12(s0)
ble a0, a1, while_L2
while_L1:
li a0, 1
sw a0, -116(s0)
lw a0, -116(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -120(s0)
lw a0, -120(s0)
sw a0, -12(s0)
li a0, 3
sw a0, -124(s0)
lw a1, -124(s0)
lw a0, -12(s0)
bne a0, a1, if_L6
li a0, 0
sw a0, -136(s0)
lw a0, -136(s0)
sw a0, -12(s0)
j while_L3
if_L6:
j while_L0
while_L3:
j while_L0
while_L2:
lw a0, -12(s0)
lw ra, 140(sp)
lw s0, 136(sp)
addi sp, sp, 144
ret
main:
addi sp, sp, -32
sw ra, 28(sp)
sw s0, 24(sp)
addi s0, sp, 32
li a0, 5
sw a0, -12(s0)
lw a0, -12(s0)
call control_structures
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
li a0, 1
sw a0, -28(s0)
lw a0, -28(s0)
lw a1, -24(s0)
add a2, a1, a0
sw a2, -32(s0)
lw a0, -32(s0)
sw a0, -24(s0)
lw a0, -24(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
