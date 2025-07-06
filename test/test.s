.global _start
_start:
    j main 
.global main                        
# function func
func:
addi sp, sp, -4
sw ra, 0(sp)
li x4, 1
mv x5, x4
li x6, 1
mv x7, x6
li x8, 1
mv x9, x8
li x11, 1
mv x12, x11
li x13, 1
mv x14, x13
li x15, 1
mv x16, x15
li x17, 1
mv x18, x17
li x19, 1
mv x20, x19
li x21, 1
mv x22, x21
li x23, 1
mv x24, x23
li x25, 1
mv x26, x25
li x27, 1
mv x28, x27
li x29, 1
mv x30, x29
li x31, 1
mv x5, x31
addi sp, sp, -4
sw x5, 0(sp)
li x5, 1
mv x7, x5
addi sp, sp, -4
sw x7, 0(sp)
li x7, 1
mv x9, x7
addi sp, sp, -4
sw x9, 0(sp)
li x9, 1
mv x12, x9
addi sp, sp, -4
sw x12, 0(sp)
li x12, 1
mv x14, x12
addi sp, sp, -4
sw x14, 0(sp)
li x14, 1
mv x16, x14
addi sp, sp, -4
sw x16, 0(sp)
li x16, 1
mv x18, x16
addi sp, sp, -4
sw x18, 0(sp)
li x18, 1
mv x20, x18
addi sp, sp, -4
sw x20, 0(sp)
li x20, 1
mv x22, x20
addi sp, sp, -4
sw x22, 0(sp)
li x22, 1
mv x24, x22
addi sp, sp, -4
sw x24, 0(sp)
li x24, 1
mv x26, x24
addi sp, sp, -4
sw x26, 0(sp)
li x26, 1
mv x28, x26
addi sp, sp, -4
sw x28, 0(sp)
li x28, 1
mv x30, x28
addi sp, sp, -4
sw x30, 0(sp)
li x30, 1
mv x4, x30
addi sp, sp, -4
sw x4, 0(sp)
li x4, 1
mv x6, x4
addi sp, sp, -4
sw x6, 0(sp)
li x6, 1
mv x8, x6
addi sp, sp, -4
sw x8, 0(sp)
li x8, 1
mv x11, x8
addi sp, sp, -4
sw x11, 0(sp)
li x11, 1
mv x13, x11
addi sp, sp, -4
sw x13, 0(sp)
li x13, 1
mv x15, x13
addi sp, sp, -4
sw x15, 0(sp)
li x15, 1
mv x17, x15
addi sp, sp, -4
sw x17, 0(sp)
li x17, 1
mv x19, x17
addi sp, sp, -4
sw x19, 0(sp)
li x19, 1
mv x21, x19
addi sp, sp, -4
sw x21, 0(sp)
add x21, x23, x23
addi sp, sp, -4
sw x23, 0(sp)
lw x23, 0(sp)
addi sp, sp, 4
add x25, x21, x25
addi sp, sp, -4
sw x25, 0(sp)
lw x25, 0(sp)
addi sp, sp, 4
add x27, x25, x27
addi sp, sp, -4
sw x27, 0(sp)
lw x27, 0(sp)
addi sp, sp, 4
add x29, x27, x29
addi sp, sp, -4
sw x29, 0(sp)
lw x29, 0(sp)
addi sp, sp, 4
add x31, x29, x31
addi sp, sp, -4
sw x31, 0(sp)
lw x31, 0(sp)
addi sp, sp, 4
add x5, x31, x5
addi sp, sp, -4
sw x5, 0(sp)
lw x5, 0(sp)
addi sp, sp, 4
add x7, x5, x7
addi sp, sp, -4
sw x7, 0(sp)
lw x7, 0(sp)
addi sp, sp, 4
add x9, x7, x9
addi sp, sp, -4
sw x9, 0(sp)
lw x9, 0(sp)
addi sp, sp, 4
add x12, x9, x12
addi sp, sp, -4
sw x12, 0(sp)
lw x12, 0(sp)
addi sp, sp, 4
add x14, x12, x14
addi sp, sp, -4
sw x14, 0(sp)
lw x14, 0(sp)
addi sp, sp, 4
add x16, x14, x16
addi sp, sp, -4
sw x16, 0(sp)
lw x16, 0(sp)
addi sp, sp, 4
add x18, x16, x18
addi sp, sp, -4
sw x18, 0(sp)
lw x18, 0(sp)
addi sp, sp, 4
add x20, x18, x5
addi sp, sp, -4
sw x20, 0(sp)
add x20, x20, x7
add x22, x20, x9
addi sp, sp, -4
sw x22, 0(sp)
add x22, x22, x12
add x23, x22, x14
addi sp, sp, -4
sw x23, 0(sp)
add x23, x23, x16
add x24, x23, x18
addi sp, sp, -4
sw x24, 0(sp)
add x24, x24, x20
add x26, x24, x22
addi sp, sp, -4
sw x26, 0(sp)
add x26, x26, x24
add x28, x26, x26
addi sp, sp, -4
sw x28, 0(sp)
add x28, x28, x28
add x30, x28, x30
addi sp, sp, -4
sw x30, 0(sp)
add x30, x30, x4
add x6, x30, x6
addi sp, sp, -4
sw x6, 0(sp)
add x6, x6, x8
add x11, x6, x11
addi sp, sp, -4
sw x11, 0(sp)
add x11, x11, x13
add x15, x11, x15
addi sp, sp, -4
sw x15, 0(sp)
add x15, x15, x17
add x19, x15, x19
addi sp, sp, -4
sw x19, 0(sp)
add x19, x19, x21
mv a0, x19
lw ra, 0(sp)
addi sp, sp, 4
ret
# function main
main:
addi sp, sp, -4
sw ra, 0(sp)
call func
mv x25, a0
addi sp, sp, -4
sw x25, 0(sp)
mv x25, x25
mv a0, x25
lw ra, 0(sp)
addi sp, sp, 4

# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
