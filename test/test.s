.global _start
_start:
    j main 
.global main                        
sum10:
addi sp, sp, -96
sw ra, 92(sp)
sw s0, 88(sp)
addi s0, sp, 96
sw a0, -12(s0)
sw a1, -16(s0)
sw a2, -20(s0)
sw a3, -24(s0)
sw a4, -28(s0)
sw a5, -32(s0)
sw a6, -36(s0)
sw a7, -40(s0)
lw a0, 0(s0)
sw a0, -44(s0)
lw a0, 4(s0)
sw a0, -48(s0)
lw a0, -16(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -52(s0)
lw a0, -20(s0)
lw a1, -52(s0)
add a2, a1, a0
sw a2, -56(s0)
lw a0, -24(s0)
lw a1, -56(s0)
add a2, a1, a0
sw a2, -60(s0)
lw a0, -28(s0)
lw a1, -60(s0)
add a2, a1, a0
sw a2, -64(s0)
lw a0, -32(s0)
lw a1, -64(s0)
add a2, a1, a0
sw a2, -68(s0)
lw a0, -36(s0)
lw a1, -68(s0)
add a2, a1, a0
sw a2, -72(s0)
lw a0, -40(s0)
lw a1, -72(s0)
add a2, a1, a0
sw a2, -76(s0)
lw a0, -44(s0)
lw a1, -76(s0)
add a2, a1, a0
sw a2, -80(s0)
lw a0, -48(s0)
lw a1, -80(s0)
add a2, a1, a0
sw a2, -84(s0)
lw a0, -84(s0)
lw ra, 92(sp)
lw s0, 88(sp)
addi sp, sp, 96
ret
main:
addi sp, sp, -192
sw ra, 188(sp)
sw s0, 184(sp)
addi s0, sp, 192
li a0, 1
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
li a0, 2
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
li a0, 3
sw a0, -28(s0)
lw a0, -28(s0)
sw a0, -32(s0)
li a0, 4
sw a0, -36(s0)
lw a0, -36(s0)
sw a0, -40(s0)
li a0, 5
sw a0, -44(s0)
lw a0, -44(s0)
sw a0, -48(s0)
li a0, 6
sw a0, -52(s0)
lw a0, -52(s0)
sw a0, -56(s0)
li a0, 7
sw a0, -60(s0)
lw a0, -60(s0)
sw a0, -64(s0)
li a0, 8
sw a0, -68(s0)
lw a0, -68(s0)
sw a0, -72(s0)
li a0, 9
sw a0, -76(s0)
lw a0, -76(s0)
sw a0, -80(s0)
li a0, 10
sw a0, -84(s0)
lw a0, -84(s0)
sw a0, -88(s0)
li a0, 11
sw a0, -92(s0)
lw a0, -92(s0)
sw a0, -96(s0)
li a0, 12
sw a0, -100(s0)
lw a0, -100(s0)
sw a0, -104(s0)
li a0, 13
sw a0, -108(s0)
lw a0, -108(s0)
sw a0, -112(s0)
li a0, 14
sw a0, -116(s0)
lw a0, -116(s0)
sw a0, -120(s0)
li a0, 15
sw a0, -124(s0)
lw a0, -124(s0)
sw a0, -128(s0)
li a0, 16
sw a0, -132(s0)
lw a0, -132(s0)
sw a0, -136(s0)
li a0, 1
sw a0, -140(s0)
li a0, 2
sw a0, -144(s0)
li a0, 3
sw a0, -148(s0)
li a0, 4
sw a0, -152(s0)
li a0, 5
sw a0, -156(s0)
lw a0, -156(s0)
sw a0, 4(sp)
lw a0, -80(s0)
sw a0, 0(sp)
lw a7, -152(s0)
lw a6, -64(s0)
lw a5, -148(s0)
lw a4, -48(s0)
lw a3, -144(s0)
lw a2, -32(s0)
lw a1, -140(s0)
lw a0, -16(s0)
call sum10
sw a0, -160(s0)
lw a0, -160(s0)
sw a0, -164(s0)
lw a0, -88(s0)
sw a0, 4(sp)
lw a0, -80(s0)
sw a0, 0(sp)
lw a7, -72(s0)
lw a6, -64(s0)
lw a5, -56(s0)
lw a4, -48(s0)
lw a3, -40(s0)
lw a2, -32(s0)
lw a1, -24(s0)
lw a0, -16(s0)
call sum10
sw a0, -168(s0)
lw a0, -168(s0)
sw a0, -172(s0)
li a0, 256
sw a0, -176(s0)
lw a0, -176(s0)
lw a1, -172(s0)
rem a2, a1, a0
sw a2, -180(s0)
lw a0, -180(s0)
lw ra, 188(sp)
lw s0, 184(sp)
addi sp, sp, 192
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
