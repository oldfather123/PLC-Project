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
lw a0, -16(s0)
sw a0, -20(s0)
j while_L0
while_L0:
li a0, 0
sw a0, -24(s0)
lw a1, -24(s0)
lw a0, -12(s0)
ble a0, a1, while_L2
while_L1:
lw a0, -12(s0)
lw a1, -20(s0)
mul a2, a1, a0
sw a2, -36(s0)
lw a0, -36(s0)
sw a0, -20(s0)
li a0, 1
sw a0, -40(s0)
lw a0, -40(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -44(s0)
lw a0, -44(s0)
sw a0, -12(s0)
j while_L0
while_L2:
lw a0, -20(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
combination:
addi sp, sp, -96
sw ra, 92(sp)
sw s0, 88(sp)
addi s0, sp, 96
sw a0, -12(s0)
sw a1, -16(s0)
lw a1, -12(s0)
lw a0, -16(s0)
ble a0, a1, if_L0
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 92(sp)
lw s0, 88(sp)
addi sp, sp, 96
ret
if_L0:
li a0, 0
sw a0, -32(s0)
lw a0, -32(s0)
lw a1, -16(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -36(s0)
lw a0, -12(s0)
lw a1, -16(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -40(s0)
lw a0, -40(s0)
lw a1, -36(s0)
or a2, a1, a0
sw a2, -44(s0)
lw a1, -44(s0)
seqz a0, a1
sw a0, -48(s0)
lw a0, -48(s0)
bnez a0, if_L1
li a0, 1
sw a0, -52(s0)
lw a0, -52(s0)
lw ra, 92(sp)
lw s0, 88(sp)
addi sp, sp, 96
ret
if_L1:
lw a0, -12(s0)
call factorial
sw a0, -60(s0)
lw a0, -16(s0)
call factorial
sw a0, -68(s0)
lw a0, -16(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -72(s0)
lw a0, -72(s0)
call factorial
sw a0, -80(s0)
lw a0, -80(s0)
lw a1, -68(s0)
mul a2, a1, a0
sw a2, -84(s0)
lw a0, -84(s0)
lw a1, -60(s0)
div a2, a1, a0
sw a2, -88(s0)
lw a0, -88(s0)
lw ra, 92(sp)
lw s0, 88(sp)
addi sp, sp, 96
ret
main:
addi sp, sp, -80
sw ra, 76(sp)
sw s0, 72(sp)
addi s0, sp, 80
li a0, 0
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
li a0, 8
sw a0, -20(s0)
lw a0, -20(s0)
call factorial
sw a0, -28(s0)
lw a0, -28(s0)
sw a0, -32(s0)
li a0, 7
sw a0, -36(s0)
li a0, 3
sw a0, -40(s0)
lw a1, -40(s0)
lw a0, -36(s0)
call combination
sw a0, -52(s0)
lw a0, -52(s0)
sw a0, -56(s0)
lw a0, -56(s0)
lw a1, -32(s0)
add a2, a1, a0
sw a2, -60(s0)
li a0, 256
sw a0, -64(s0)
lw a0, -64(s0)
lw a1, -60(s0)
rem a2, a1, a0
sw a2, -68(s0)
lw a0, -68(s0)
lw ra, 76(sp)
lw s0, 72(sp)
addi sp, sp, 80
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
