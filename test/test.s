.global _start
_start:
    j main 
.global main                        
factorial:
addi sp, sp, -64
sw ra, 60(sp)
sw s0, 56(sp)
addi s0, sp, 64
sw a0, -12(s0)
li a0, 1
sw a0, -16(s0)
lw a0, -16(s0)
sw a0, -20(s0)
li a0, 0
sw a0, -24(s0)
lw a1, -24(s0)
lw a0, -12(s0)
bgt a0, a1, if_L0
then_L0:
li a0, 1
sw a0, -36(s0)
lw a0, -36(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
j if_L1
if_L0:
j while_L0
while_L0:
li a0, 1
sw a0, -40(s0)
lw a1, -40(s0)
lw a0, -12(s0)
ble a0, a1, while_L2
while_L1:
lw a0, -12(s0)
lw a1, -20(s0)
mul a2, a1, a0
sw a2, -52(s0)
lw a0, -52(s0)
sw a0, -20(s0)
li a0, 1
sw a0, -56(s0)
lw a0, -56(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -60(s0)
lw a0, -60(s0)
sw a0, -12(s0)
j while_L0
while_L2:
lw a0, -20(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
if_L1:
main:
addi sp, sp, -192
sw ra, 188(sp)
sw s0, 184(sp)
addi s0, sp, 192
li a0, 3
sw a0, -12(s0)
lw a1, -12(s0)
neg a0, a1
sw a0, -16(s0)
lw a0, -16(s0)
sw a0, -20(s0)
li a0, 3
sw a0, -24(s0)
lw a1, -24(s0)
neg a0, a1
sw a0, -28(s0)
lw a0, -28(s0)
sw a0, -32(s0)
li a0, 0
sw a0, -36(s0)
lw a0, -36(s0)
sw a0, -40(s0)
lw a0, -32(s0)
lw a1, -20(s0)
sgt a2, a1, a0
sw a2, -44(s0)
lw a0, -32(s0)
lw a1, -20(s0)
sub a2, a1, a0
sw a2, -48(s0)
li a0, 1
sw a0, -52(s0)
lw a0, -52(s0)
lw a1, -48(s0)
sgt a2, a1, a0
sw a2, -56(s0)
lw a0, -56(s0)
lw a1, -44(s0)
and a2, a1, a0
sw a2, -60(s0)
lw a1, -60(s0)
seqz a0, a1
sw a0, -64(s0)
lw a0, -64(s0)
bnez a0, if_L2
then_L1:
lw a0, -20(s0)
call factorial
sw a0, -72(s0)
lw a0, -72(s0)
sw a0, -40(s0)
j if_L3
if_L2:
lw a0, -32(s0)
lw a1, -20(s0)
slt a2, a1, a0
sw a2, -76(s0)
lw a0, -32(s0)
lw a1, -20(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -80(s0)
lw a0, -80(s0)
lw a1, -76(s0)
or a2, a1, a0
sw a2, -84(s0)
lw a1, -84(s0)
seqz a0, a1
sw a0, -88(s0)
lw a0, -88(s0)
bnez a0, if_L4
then_L2:
lw a0, -32(s0)
lw a1, -20(s0)
add a2, a1, a0
sw a2, -92(s0)
lw a1, -92(s0)
neg a0, a1
sw a0, -96(s0)
lw a0, -96(s0)
call factorial
sw a0, -104(s0)
lw a0, -104(s0)
sw a0, -40(s0)
j if_L5
if_L4:
lw a0, -32(s0)
lw a1, -20(s0)
mul a2, a1, a0
sw a2, -108(s0)
lw a0, -108(s0)
call factorial
sw a0, -116(s0)
lw a0, -116(s0)
sw a0, -40(s0)
if_L5:
if_L3:
j while_L3
while_L3:
li a0, 100
sw a0, -120(s0)
lw a1, -120(s0)
lw a0, -40(s0)
ble a0, a1, while_L5
while_L4:
li a0, 2
sw a0, -132(s0)
lw a0, -132(s0)
lw a1, -40(s0)
rem a2, a1, a0
sw a2, -136(s0)
li a0, 1
sw a0, -140(s0)
lw a1, -140(s0)
lw a0, -136(s0)
bne a0, a1, if_L6
then_L3:
li a0, 2
sw a0, -152(s0)
lw a0, -152(s0)
lw a1, -40(s0)
div a2, a1, a0
sw a2, -156(s0)
lw a0, -156(s0)
sw a0, -40(s0)
j if_L7
if_L6:
li a0, 1
sw a0, -160(s0)
lw a0, -160(s0)
lw a1, -40(s0)
sub a2, a1, a0
sw a2, -164(s0)
lw a0, -164(s0)
sw a0, -40(s0)
if_L7:
j while_L3
while_L5:
li a0, 1
sw a0, -168(s0)
lw a0, -168(s0)
call factorial
sw a0, -176(s0)
lw a0, -176(s0)
lw a1, -40(s0)
div a2, a1, a0
sw a2, -180(s0)
lw a0, -180(s0)
lw ra, 188(sp)
lw s0, 184(sp)
addi sp, sp, 192
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
