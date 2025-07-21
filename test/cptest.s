.global _start
_start:
    j main 
.global main                        
sum8:
addi sp, sp, -80
sw ra, 76(sp)
sw s0, 72(sp)
addi s0, sp, 80
sw a0, -12(s0)
sw a1, -16(s0)
sw a2, -20(s0)
sw a3, -24(s0)
sw a4, -28(s0)
sw a5, -32(s0)
sw a6, -36(s0)
sw a7, -40(s0)
lw a0, -16(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -44(s0)
lw a0, -20(s0)
lw a1, -44(s0)
add a2, a1, a0
sw a2, -48(s0)
lw a0, -24(s0)
lw a1, -48(s0)
add a2, a1, a0
sw a2, -52(s0)
lw a0, -28(s0)
lw a1, -52(s0)
add a2, a1, a0
sw a2, -56(s0)
lw a0, -32(s0)
lw a1, -56(s0)
add a2, a1, a0
sw a2, -60(s0)
lw a0, -36(s0)
lw a1, -60(s0)
add a2, a1, a0
sw a2, -64(s0)
lw a0, -40(s0)
lw a1, -64(s0)
add a2, a1, a0
sw a2, -68(s0)
lw a0, -68(s0)
lw ra, 76(sp)
lw s0, 72(sp)
addi sp, sp, 80
ret
sum16:
addi sp, sp, -144
sw ra, 140(sp)
sw s0, 136(sp)
addi s0, sp, 144
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
lw a0, 8(s0)
sw a0, -52(s0)
lw a0, 12(s0)
sw a0, -56(s0)
lw a0, 16(s0)
sw a0, -60(s0)
lw a0, 20(s0)
sw a0, -64(s0)
lw a0, 24(s0)
sw a0, -68(s0)
lw a0, 28(s0)
sw a0, -72(s0)
lw a0, -16(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -76(s0)
lw a0, -20(s0)
lw a1, -76(s0)
add a2, a1, a0
sw a2, -80(s0)
lw a0, -24(s0)
lw a1, -80(s0)
add a2, a1, a0
sw a2, -84(s0)
lw a0, -28(s0)
lw a1, -84(s0)
add a2, a1, a0
sw a2, -88(s0)
lw a0, -32(s0)
lw a1, -88(s0)
add a2, a1, a0
sw a2, -92(s0)
lw a0, -36(s0)
lw a1, -92(s0)
add a2, a1, a0
sw a2, -96(s0)
lw a0, -40(s0)
lw a1, -96(s0)
add a2, a1, a0
sw a2, -100(s0)
lw a0, -44(s0)
lw a1, -100(s0)
add a2, a1, a0
sw a2, -104(s0)
lw a0, -48(s0)
lw a1, -104(s0)
add a2, a1, a0
sw a2, -108(s0)
lw a0, -52(s0)
lw a1, -108(s0)
add a2, a1, a0
sw a2, -112(s0)
lw a0, -56(s0)
lw a1, -112(s0)
add a2, a1, a0
sw a2, -116(s0)
lw a0, -60(s0)
lw a1, -116(s0)
add a2, a1, a0
sw a2, -120(s0)
lw a0, -64(s0)
lw a1, -120(s0)
add a2, a1, a0
sw a2, -124(s0)
lw a0, -68(s0)
lw a1, -124(s0)
add a2, a1, a0
sw a2, -128(s0)
lw a0, -72(s0)
lw a1, -128(s0)
add a2, a1, a0
sw a2, -132(s0)
lw a0, -132(s0)
lw ra, 140(sp)
lw s0, 136(sp)
addi sp, sp, 144
ret
main:
addi sp, sp, -224
sw ra, 220(sp)
sw s0, 216(sp)
addi s0, sp, 224
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
lw a7, -152(s0)
lw a6, -64(s0)
lw a5, -148(s0)
lw a4, -48(s0)
lw a3, -144(s0)
lw a2, -32(s0)
lw a1, -140(s0)
lw a0, -16(s0)
call sum8
sw a0, -156(s0)
lw a0, -156(s0)
sw a0, -160(s0)
li a0, 26
sw a0, -164(s0)
lw a0, -164(s0)
sw a0, -168(s0)
li a0, 1
sw a0, -172(s0)
li a0, 2
sw a0, -176(s0)
li a0, 3
sw a0, -180(s0)
li a0, 4
sw a0, -184(s0)
lw a0, -112(s0)
lw a1, -168(s0)
add a2, a1, a0
sw a2, -188(s0)
lw a0, -120(s0)
lw a1, -168(s0)
add a2, a1, a0
sw a2, -192(s0)
lw a0, -128(s0)
lw a1, -168(s0)
add a2, a1, a0
sw a2, -196(s0)
lw a0, -136(s0)
lw a1, -168(s0)
add a2, a1, a0
sw a2, -200(s0)
lw a0, -200(s0)
sw a0, 28(sp)
lw a0, -196(s0)
sw a0, 24(sp)
lw a0, -192(s0)
sw a0, 20(sp)
lw a0, -188(s0)
sw a0, 16(sp)
lw a0, -184(s0)
sw a0, 12(sp)
lw a0, -180(s0)
sw a0, 8(sp)
lw a0, -176(s0)
sw a0, 4(sp)
lw a0, -172(s0)
sw a0, 0(sp)
lw a7, -72(s0)
lw a6, -64(s0)
lw a5, -56(s0)
lw a4, -48(s0)
lw a3, -40(s0)
lw a2, -32(s0)
lw a1, -24(s0)
lw a0, -16(s0)
call sum16
sw a0, -204(s0)
lw a0, -204(s0)
sw a0, -208(s0)
li a0, 256
sw a0, -212(s0)
lw a0, -212(s0)
lw a1, -208(s0)
rem a2, a1, a0
sw a2, -216(s0)
lw a0, -216(s0)
lw ra, 220(sp)
lw s0, 216(sp)
addi sp, sp, 224
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
