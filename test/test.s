.global _start
_start:
    j main 
.global main                        
# function add
add:
lw x4, 0(sp)
addi sp, sp, 4
lw x5, 0(sp)
addi sp, sp, 4
addi sp, sp, -4
sw ra, 0(sp)
add x6, x4, x5
mv a0, x6
lw ra, 0(sp)
addi sp, sp, 4
ret
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
li x4, 1
mv x5, x4
li x6, 2
mv x7, x6
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
sw x5, 0(sp)
addi sp, sp, -4
sw x7, 0(sp)
call add
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
mv x9, x8
mv a0, x9
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
