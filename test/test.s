.global _start
_start:
    j main 
.global main                        
# function print
print:
addi sp, sp, -4
sw ra, 0(sp)
li x4, 1
mv x5, x4
li x6, 1
add x7, x5, x6
mv x5, x7
lw ra, 0(sp)
addi sp, sp, 4
ret
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
addi sp, sp, -4
sw x4, 0(sp)
call print
lw x4, 0(sp)
addi sp, sp, 4
mv x4, a0
li x5, 0
mv a0, x5
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
