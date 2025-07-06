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
bgt x4, x5, if_L0
li x6, 1
mv a0, x6
lw ra, 0(sp)
addi sp, sp, 4
ret
if_L0:
li x7, 1
sub x8, x4, x7
addi sp, sp, -4
sw x8, 0(sp)
call factorial
mv x9, a0
mul x11, x4, x9
mv a0, x11
lw ra, 0(sp)
addi sp, sp, 4
ret
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x4, 5
mv x5, x4
addi sp, sp, -4
sw x5, 0(sp)
call factorial
mv x6, a0
mv x7, x6
mv a0, x7
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
