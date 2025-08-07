.global _start
_start:
    j main 
.global main
fibonacci:
addi sp, sp, -64
sw ra, 60(sp)
sw s0, 56(sp)
addi s0, sp, 64
sw a0, -12(s0)
li a0, 1
sw a0, -16(s0)
lw a1, -16(s0)
lw a0, -12(s0)
bgt a0, a1, if_L0
then_L0:
lw a0, -12(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
j if_L1
if_L0:
li a0, 1
sw a0, -28(s0)
lw a0, -28(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -32(s0)
lw a0, -32(s0)
call fibonacci
sw a0, -40(s0)
li a0, 2
sw a0, -44(s0)
lw a0, -44(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -48(s0)
lw a0, -48(s0)
call fibonacci
sw a0, -56(s0)
lw a0, -56(s0)
lw a1, -40(s0)
add a2, a1, a0
sw a2, -60(s0)
lw a0, -60(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
if_L1:
gcd:
addi sp, sp, -48
sw ra, 44(sp)
sw s0, 40(sp)
addi s0, sp, 48
sw a0, -12(s0)
sw a1, -16(s0)
li a0, 0
sw a0, -20(s0)
lw a1, -20(s0)
lw a0, -16(s0)
bne a0, a1, if_L2
lw a0, -12(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
if_L2:
lw a0, -16(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -32(s0)
lw a1, -32(s0)
lw a0, -16(s0)
call gcd
sw a0, -44(s0)
lw a0, -44(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
isPrime:
addi sp, sp, -176
sw ra, 172(sp)
sw s0, 168(sp)
addi s0, sp, 176
sw a0, -12(s0)
li a0, 1
sw a0, -16(s0)
lw a1, -16(s0)
lw a0, -12(s0)
bgt a0, a1, if_L3
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L3:
li a0, 3
sw a0, -32(s0)
lw a1, -32(s0)
lw a0, -12(s0)
bgt a0, a1, if_L4
li a0, 1
sw a0, -44(s0)
lw a0, -44(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L4:
li a0, 2
sw a0, -48(s0)
lw a0, -48(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -52(s0)
li a0, 0
sw a0, -56(s0)
lw a0, -56(s0)
lw a1, -52(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -60(s0)
li a0, 3
sw a0, -64(s0)
lw a0, -64(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -68(s0)
li a0, 0
sw a0, -72(s0)
lw a0, -72(s0)
lw a1, -68(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -76(s0)
lw a0, -76(s0)
lw a1, -60(s0)
or a2, a1, a0
sw a2, -80(s0)
lw a1, -80(s0)
seqz a0, a1
sw a0, -84(s0)
lw a0, -84(s0)
bnez a0, if_L5
li a0, 0
sw a0, -88(s0)
lw a0, -88(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L5:
li a0, 5
sw a0, -92(s0)
lw a0, -92(s0)
sw a0, -96(s0)
j while_L0
while_L0:
lw a0, -96(s0)
lw a1, -96(s0)
mul a2, a1, a0
sw a2, -100(s0)
lw a1, -12(s0)
lw a0, -100(s0)
bgt a0, a1, while_L2
while_L1:
lw a0, -96(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -112(s0)
li a0, 0
sw a0, -116(s0)
lw a0, -116(s0)
lw a1, -112(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -120(s0)
li a0, 2
sw a0, -124(s0)
lw a0, -124(s0)
lw a1, -96(s0)
add a2, a1, a0
sw a2, -128(s0)
lw a0, -128(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -132(s0)
li a0, 0
sw a0, -136(s0)
lw a0, -136(s0)
lw a1, -132(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -140(s0)
lw a0, -140(s0)
lw a1, -120(s0)
or a2, a1, a0
sw a2, -144(s0)
lw a1, -144(s0)
seqz a0, a1
sw a0, -148(s0)
lw a0, -148(s0)
bnez a0, if_L6
li a0, 0
sw a0, -152(s0)
lw a0, -152(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L6:
li a0, 6
sw a0, -156(s0)
lw a0, -156(s0)
lw a1, -96(s0)
add a2, a1, a0
sw a2, -160(s0)
lw a0, -160(s0)
sw a0, -96(s0)
j while_L0
while_L2:
li a0, 1
sw a0, -164(s0)
lw a0, -164(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
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
j while_L3
while_L3:
li a0, 0
sw a0, -24(s0)
lw a1, -24(s0)
lw a0, -12(s0)
ble a0, a1, while_L5
while_L4:
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
j while_L3
while_L5:
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
ble a0, a1, if_L7
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 92(sp)
lw s0, 88(sp)
addi sp, sp, 96
ret
if_L7:
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
bnez a0, if_L8
li a0, 1
sw a0, -52(s0)
lw a0, -52(s0)
lw ra, 92(sp)
lw s0, 88(sp)
addi sp, sp, 96
ret
if_L8:
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
power:
addi sp, sp, -80
sw ra, 76(sp)
sw s0, 72(sp)
addi s0, sp, 80
sw a0, -12(s0)
sw a1, -16(s0)
li a0, 1
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
j while_L6
while_L6:
li a0, 0
sw a0, -28(s0)
lw a1, -28(s0)
lw a0, -16(s0)
ble a0, a1, while_L8
while_L7:
li a0, 2
sw a0, -40(s0)
lw a0, -40(s0)
lw a1, -16(s0)
rem a2, a1, a0
sw a2, -44(s0)
li a0, 1
sw a0, -48(s0)
lw a1, -48(s0)
lw a0, -44(s0)
bne a0, a1, if_L9
lw a0, -12(s0)
lw a1, -24(s0)
mul a2, a1, a0
sw a2, -60(s0)
lw a0, -60(s0)
sw a0, -24(s0)
if_L9:
lw a0, -12(s0)
lw a1, -12(s0)
mul a2, a1, a0
sw a2, -64(s0)
lw a0, -64(s0)
sw a0, -12(s0)
li a0, 2
sw a0, -68(s0)
lw a0, -68(s0)
lw a1, -16(s0)
div a2, a1, a0
sw a2, -72(s0)
lw a0, -72(s0)
sw a0, -16(s0)
j while_L6
while_L8:
lw a0, -24(s0)
lw ra, 76(sp)
lw s0, 72(sp)
addi sp, sp, 80
ret
complexFunction:
addi sp, sp, -416
sw ra, 412(sp)
sw s0, 408(sp)
addi s0, sp, 416
sw a0, -12(s0)
sw a1, -16(s0)
sw a2, -20(s0)
li a0, 0
sw a0, -24(s0)
lw a0, -24(s0)
sw a0, -28(s0)
lw a0, -16(s0)
lw a1, -12(s0)
sgt a2, a1, a0
sw a2, -32(s0)
lw a0, -20(s0)
lw a1, -16(s0)
sgt a2, a1, a0
sw a2, -36(s0)
lw a0, -36(s0)
lw a1, -32(s0)
and a2, a1, a0
sw a2, -40(s0)
lw a1, -40(s0)
seqz a0, a1
sw a0, -44(s0)
lw a1, -44(s0)
seqz a0, a1
sw a0, -48(s0)
lw a0, -48(s0)
bnez a0, if_L10
then_L1:
lw a0, -16(s0)
lw a1, -12(s0)
mul a2, a1, a0
sw a2, -52(s0)
li a0, 1
sw a0, -56(s0)
lw a1, -56(s0)
neg a0, a1
sw a0, -60(s0)
lw a0, -60(s0)
lw a1, -20(s0)
add a2, a1, a0
sw a2, -64(s0)
lw a1, -64(s0)
neg a0, a1
sw a0, -68(s0)
lw a0, -68(s0)
lw a1, -52(s0)
sub a2, a1, a0
sw a2, -72(s0)
lw a0, -72(s0)
sw a0, -28(s0)
j if_L11
if_L10:
lw a0, -20(s0)
lw a1, -12(s0)
slt a2, a1, a0
sw a2, -76(s0)
lw a1, -76(s0)
seqz a0, a1
sw a0, -80(s0)
lw a0, -16(s0)
lw a1, -20(s0)
slt a2, a1, a0
sw a2, -84(s0)
lw a0, -84(s0)
lw a1, -80(s0)
or a2, a1, a0
sw a2, -88(s0)
lw a1, -88(s0)
seqz a0, a1
sw a0, -92(s0)
lw a0, -92(s0)
bnez a0, if_L12
then_L2:
lw a1, -16(s0)
mv a0, a1
sw a0, -96(s0)
lw a0, -96(s0)
lw a1, -20(s0)
sub a2, a1, a0
sw a2, -100(s0)
li a0, 2
sw a0, -104(s0)
lw a1, -104(s0)
neg a0, a1
sw a0, -108(s0)
lw a0, -108(s0)
lw a1, -100(s0)
sub a2, a1, a0
sw a2, -112(s0)
lw a0, -112(s0)
lw a1, -12(s0)
mul a2, a1, a0
sw a2, -116(s0)
lw a0, -116(s0)
sw a0, -28(s0)
j if_L13
if_L12:
lw a0, -12(s0)
lw a1, -16(s0)
sgt a2, a1, a0
xori a2, a2, 1
sw a2, -120(s0)
lw a0, -20(s0)
lw a1, -12(s0)
sgt a2, a1, a0
xori a2, a2, 1
sw a2, -124(s0)
lw a0, -124(s0)
lw a1, -120(s0)
and a2, a1, a0
sw a2, -128(s0)
lw a0, -20(s0)
lw a1, -16(s0)
slt a2, a1, a0
xori a2, a2, 1
sw a2, -132(s0)
lw a0, -132(s0)
lw a1, -128(s0)
or a2, a1, a0
sw a2, -136(s0)
lw a1, -136(s0)
seqz a0, a1
sw a0, -140(s0)
lw a0, -140(s0)
bnez a0, if_L14
then_L3:
lw a0, -12(s0)
lw a1, -16(s0)
mul a2, a1, a0
sw a2, -144(s0)
li a0, 3
sw a0, -148(s0)
lw a1, -148(s0)
neg a0, a1
sw a0, -152(s0)
lw a0, -152(s0)
lw a1, -20(s0)
add a2, a1, a0
sw a2, -156(s0)
lw a1, -156(s0)
neg a0, a1
sw a0, -160(s0)
lw a0, -160(s0)
lw a1, -144(s0)
sub a2, a1, a0
sw a2, -164(s0)
lw a0, -164(s0)
sw a0, -28(s0)
j if_L15
if_L14:
lw a0, -20(s0)
lw a1, -16(s0)
sgt a2, a1, a0
sw a2, -168(s0)
lw a0, -12(s0)
lw a1, -20(s0)
sgt a2, a1, a0
sw a2, -172(s0)
lw a0, -16(s0)
lw a1, -12(s0)
slt a2, a1, a0
xori a2, a2, 1
sw a2, -176(s0)
lw a0, -176(s0)
lw a1, -172(s0)
and a2, a1, a0
sw a2, -180(s0)
lw a0, -180(s0)
lw a1, -168(s0)
or a2, a1, a0
sw a2, -184(s0)
lw a1, -184(s0)
seqz a0, a1
sw a0, -188(s0)
lw a0, -188(s0)
bnez a0, if_L16
then_L4:
lw a1, -12(s0)
mv a0, a1
sw a0, -192(s0)
lw a0, -192(s0)
lw a1, -20(s0)
sub a2, a1, a0
sw a2, -196(s0)
li a0, 4
sw a0, -200(s0)
lw a1, -200(s0)
neg a0, a1
sw a0, -204(s0)
lw a0, -204(s0)
lw a1, -196(s0)
sub a2, a1, a0
sw a2, -208(s0)
lw a0, -208(s0)
lw a1, -16(s0)
mul a2, a1, a0
sw a2, -212(s0)
lw a0, -212(s0)
sw a0, -28(s0)
j if_L17
if_L16:
lw a0, -12(s0)
lw a1, -20(s0)
sgt a2, a1, a0
sw a2, -216(s0)
lw a0, -12(s0)
lw a1, -16(s0)
sub a2, a1, a0
seqz a2, a2
xori a2, a2, 1
sw a2, -220(s0)
lw a0, -220(s0)
lw a1, -216(s0)
or a2, a1, a0
sw a2, -224(s0)
lw a1, -224(s0)
seqz a0, a1
sw a0, -228(s0)
lw a0, -16(s0)
lw a1, -12(s0)
sub a2, a1, a0
seqz a2, a2
sw a2, -232(s0)
lw a0, -232(s0)
lw a1, -228(s0)
and a2, a1, a0
sw a2, -236(s0)
lw a1, -236(s0)
seqz a0, a1
sw a0, -240(s0)
lw a0, -240(s0)
bnez a0, if_L18
then_L5:
lw a0, -12(s0)
lw a1, -20(s0)
mul a2, a1, a0
sw a2, -244(s0)
li a0, 5
sw a0, -248(s0)
lw a1, -248(s0)
neg a0, a1
sw a0, -252(s0)
lw a0, -252(s0)
lw a1, -16(s0)
add a2, a1, a0
sw a2, -256(s0)
lw a1, -256(s0)
mv a0, a1
sw a0, -260(s0)
lw a0, -260(s0)
lw a1, -244(s0)
sub a2, a1, a0
sw a2, -264(s0)
lw a0, -264(s0)
sw a0, -28(s0)
j if_L19
if_L18:
lw a1, -12(s0)
neg a0, a1
sw a0, -268(s0)
lw a0, -268(s0)
lw a1, -16(s0)
sub a2, a1, a0
sw a2, -272(s0)
li a0, 6
sw a0, -276(s0)
lw a1, -276(s0)
neg a0, a1
sw a0, -280(s0)
lw a0, -280(s0)
lw a1, -272(s0)
sub a2, a1, a0
sw a2, -284(s0)
lw a0, -284(s0)
lw a1, -20(s0)
mul a2, a1, a0
sw a2, -288(s0)
lw a0, -288(s0)
sw a0, -28(s0)
if_L19:
if_L17:
if_L15:
if_L13:
if_L11:
li a0, 0
sw a0, -292(s0)
lw a0, -292(s0)
sw a0, -296(s0)
j while_L9
while_L9:
li a0, 10
sw a0, -300(s0)
lw a1, -300(s0)
lw a0, -296(s0)
bge a0, a1, while_L11
while_L10:
li a0, 1
sw a0, -312(s0)
lw a0, -312(s0)
lw a1, -296(s0)
add a2, a1, a0
sw a2, -316(s0)
lw a0, -316(s0)
sw a0, -296(s0)
li a0, 3
sw a0, -320(s0)
lw a0, -320(s0)
lw a1, -296(s0)
rem a2, a1, a0
sw a2, -324(s0)
li a0, 0
sw a0, -328(s0)
lw a1, -328(s0)
lw a0, -324(s0)
bne a0, a1, if_L20
then_L6:
lw a0, -296(s0)
lw a1, -28(s0)
add a2, a1, a0
sw a2, -340(s0)
lw a0, -340(s0)
sw a0, -28(s0)
j if_L21
if_L20:
li a0, 3
sw a0, -344(s0)
lw a0, -344(s0)
lw a1, -296(s0)
rem a2, a1, a0
sw a2, -348(s0)
li a0, 1
sw a0, -352(s0)
lw a1, -352(s0)
lw a0, -348(s0)
bne a0, a1, if_L22
then_L7:
lw a0, -296(s0)
lw a1, -28(s0)
sub a2, a1, a0
sw a2, -364(s0)
lw a0, -364(s0)
sw a0, -28(s0)
j if_L23
if_L22:
li a0, 2
sw a0, -368(s0)
lw a0, -368(s0)
lw a1, -28(s0)
mul a2, a1, a0
sw a2, -372(s0)
lw a0, -372(s0)
sw a0, -28(s0)
li a0, 50
sw a0, -376(s0)
lw a1, -376(s0)
lw a0, -28(s0)
bge a0, a1, if_L24
j while_L12
if_L24:
li a0, 1
sw a0, -388(s0)
lw a0, -388(s0)
lw a1, -28(s0)
add a2, a1, a0
sw a2, -392(s0)
lw a0, -392(s0)
sw a0, -28(s0)
li a0, 100
sw a0, -396(s0)
lw a1, -396(s0)
lw a0, -28(s0)
ble a0, a1, if_L25
j while_L11
if_L25:
if_L23:
if_L21:
j while_L9
while_L12:
j while_L9
while_L11:
lw a0, -28(s0)
lw ra, 412(sp)
lw s0, 408(sp)
addi sp, sp, 416
ret
shortCircuit:
addi sp, sp, -112
sw ra, 108(sp)
sw s0, 104(sp)
addi s0, sp, 112
sw a0, -12(s0)
sw a1, -16(s0)
li a0, 0
sw a0, -20(s0)
lw a0, -20(s0)
sw a0, -24(s0)
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw a1, -12(s0)
sgt a2, a1, a0
sw a2, -32(s0)
lw a0, -12(s0)
lw a1, -16(s0)
div a2, a1, a0
sw a2, -36(s0)
li a0, 2
sw a0, -40(s0)
lw a0, -40(s0)
lw a1, -36(s0)
sgt a2, a1, a0
sw a2, -44(s0)
lw a0, -44(s0)
lw a1, -32(s0)
and a2, a1, a0
sw a2, -48(s0)
lw a1, -48(s0)
seqz a0, a1
sw a0, -52(s0)
lw a0, -52(s0)
bnez a0, if_L26
li a0, 12
sw a0, -56(s0)
lw a0, -56(s0)
lw a1, -24(s0)
add a2, a1, a0
sw a2, -60(s0)
lw a0, -60(s0)
sw a0, -24(s0)
if_L26:
li a0, 0
sw a0, -64(s0)
lw a0, -64(s0)
lw a1, -12(s0)
slt a2, a1, a0
sw a2, -68(s0)
lw a0, -12(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -72(s0)
li a0, 1
sw a0, -76(s0)
lw a0, -76(s0)
lw a1, -72(s0)
add a2, a1, a0
sw a2, -80(s0)
lw a0, -80(s0)
lw a1, -16(s0)
div a2, a1, a0
sw a2, -84(s0)
li a0, 0
sw a0, -88(s0)
lw a0, -88(s0)
lw a1, -84(s0)
slt a2, a1, a0
sw a2, -92(s0)
lw a0, -92(s0)
lw a1, -68(s0)
or a2, a1, a0
sw a2, -96(s0)
lw a1, -96(s0)
seqz a0, a1
sw a0, -100(s0)
lw a0, -100(s0)
bnez a0, if_L27
li a0, 30
sw a0, -104(s0)
lw a0, -104(s0)
lw a1, -24(s0)
add a2, a1, a0
sw a2, -108(s0)
lw a0, -108(s0)
sw a0, -24(s0)
if_L27:
lw a0, -24(s0)
lw ra, 108(sp)
lw s0, 104(sp)
addi sp, sp, 112
ret
nestedLoopsAndConditions:
addi sp, sp, -160
sw ra, 156(sp)
sw s0, 152(sp)
addi s0, sp, 160
sw a0, -12(s0)
li a0, 0
sw a0, -16(s0)
lw a0, -16(s0)
sw a0, -20(s0)
li a0, 0
sw a0, -24(s0)
lw a0, -24(s0)
sw a0, -28(s0)
j while_L13
while_L13:
lw a1, -12(s0)
lw a0, -28(s0)
bge a0, a1, while_L15
while_L14:
li a0, 0
sw a0, -40(s0)
lw a0, -40(s0)
sw a0, -44(s0)
j while_L17
while_L17:
lw a1, -28(s0)
lw a0, -44(s0)
bge a0, a1, while_L19
while_L18:
lw a0, -44(s0)
lw a1, -28(s0)
add a2, a1, a0
sw a2, -56(s0)
li a0, 2
sw a0, -60(s0)
lw a0, -60(s0)
lw a1, -56(s0)
rem a2, a1, a0
sw a2, -64(s0)
li a0, 0
sw a0, -68(s0)
lw a1, -68(s0)
lw a0, -64(s0)
bne a0, a1, if_L28
then_L8:
lw a0, -44(s0)
lw a1, -28(s0)
mul a2, a1, a0
sw a2, -80(s0)
lw a0, -80(s0)
lw a1, -20(s0)
sub a2, a1, a0
sw a2, -84(s0)
lw a0, -84(s0)
sw a0, -20(s0)
j if_L29
if_L28:
lw a0, -44(s0)
lw a1, -28(s0)
mul a2, a1, a0
sw a2, -88(s0)
lw a0, -88(s0)
lw a1, -20(s0)
add a2, a1, a0
sw a2, -92(s0)
lw a0, -92(s0)
sw a0, -20(s0)
li a0, 0
sw a0, -96(s0)
lw a1, -96(s0)
lw a0, -20(s0)
bge a0, a1, if_L30
li a0, 0
sw a0, -108(s0)
lw a0, -108(s0)
sw a0, -20(s0)
j while_L20
if_L30:
if_L29:
li a0, 1053
sw a0, -112(s0)
lw a1, -112(s0)
lw a0, -20(s0)
ble a0, a1, if_L31
j while_L19
if_L31:
li a0, 1
sw a0, -124(s0)
lw a0, -124(s0)
lw a1, -44(s0)
add a2, a1, a0
sw a2, -128(s0)
lw a0, -128(s0)
sw a0, -44(s0)
j while_L17
while_L20:
j while_L17
while_L19:
li a0, 913
sw a0, -132(s0)
lw a1, -132(s0)
lw a0, -20(s0)
ble a0, a1, if_L32
j while_L15
if_L32:
li a0, 1
sw a0, -144(s0)
lw a0, -144(s0)
lw a1, -28(s0)
add a2, a1, a0
sw a2, -148(s0)
lw a0, -148(s0)
sw a0, -28(s0)
j while_L13
while_L16:
j while_L13
while_L15:
lw a0, -20(s0)
lw ra, 156(sp)
lw s0, 152(sp)
addi sp, sp, 160
ret
func1:
addi sp, sp, -64
sw ra, 60(sp)
sw s0, 56(sp)
addi s0, sp, 64
sw a0, -12(s0)
sw a1, -16(s0)
sw a2, -20(s0)
li a0, 0
sw a0, -24(s0)
lw a1, -24(s0)
lw a0, -20(s0)
bne a0, a1, if_L33
then_L9:
lw a1, -12(s0)
mv a0, a1
sw a0, -36(s0)
lw a0, -16(s0)
lw a1, -36(s0)
mul a2, a1, a0
sw a2, -40(s0)
lw a0, -40(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
j if_L34
if_L33:
lw a0, -20(s0)
lw a1, -16(s0)
sub a2, a1, a0
sw a2, -44(s0)
li a0, 0
sw a0, -48(s0)
lw a2, -48(s0)
lw a1, -44(s0)
lw a0, -12(s0)
call func1
sw a0, -64(s0)
lw a0, -64(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
if_L34:
func2:
addi sp, sp, -48
sw ra, 44(sp)
sw s0, 40(sp)
addi s0, sp, 48
sw a0, -12(s0)
sw a1, -16(s0)
lw a1, -16(s0)
seqz a0, a1
sw a0, -20(s0)
lw a0, -20(s0)
bnez a0, if_L35
then_L10:
lw a1, -16(s0)
mv a0, a1
sw a0, -24(s0)
lw a0, -24(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -28(s0)
li a0, 0
sw a0, -32(s0)
lw a1, -32(s0)
lw a0, -28(s0)
call func2
sw a0, -44(s0)
lw a0, -44(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
j if_L36
if_L35:
lw a0, -12(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
if_L36:
func3:
addi sp, sp, -64
sw ra, 60(sp)
sw s0, 56(sp)
addi s0, sp, 64
sw a0, -12(s0)
sw a1, -16(s0)
li a0, 0
sw a0, -20(s0)
lw a1, -20(s0)
lw a0, -16(s0)
bne a0, a1, if_L37
then_L11:
li a0, 1
sw a0, -32(s0)
lw a0, -32(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -36(s0)
lw a0, -36(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
j if_L38
if_L37:
lw a0, -16(s0)
lw a1, -12(s0)
add a2, a1, a0
sw a2, -40(s0)
li a0, 0
sw a0, -44(s0)
lw a1, -44(s0)
lw a0, -40(s0)
call func3
sw a0, -56(s0)
lw a0, -56(s0)
lw ra, 60(sp)
lw s0, 56(sp)
addi sp, sp, 64
ret
if_L38:
func4:
addi sp, sp, -32
sw ra, 28(sp)
sw s0, 24(sp)
addi s0, sp, 32
sw a0, -12(s0)
sw a1, -16(s0)
sw a2, -20(s0)
lw a1, -12(s0)
seqz a0, a1
sw a0, -24(s0)
lw a0, -24(s0)
bnez a0, if_L39
then_L12:
lw a0, -16(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
ret
j if_L40
if_L39:
lw a0, -20(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
ret
if_L40:
func5:
addi sp, sp, -16
sw ra, 12(sp)
sw s0, 8(sp)
addi s0, sp, 16
sw a0, -12(s0)
lw a1, -12(s0)
neg a0, a1
sw a0, -16(s0)
lw a0, -16(s0)
lw ra, 12(sp)
lw s0, 8(sp)
addi sp, sp, 16
ret
func6:
addi sp, sp, -32
sw ra, 28(sp)
sw s0, 24(sp)
addi s0, sp, 32
sw a0, -12(s0)
sw a1, -16(s0)
lw a0, -16(s0)
lw a1, -12(s0)
and a2, a1, a0
sw a2, -20(s0)
lw a1, -20(s0)
seqz a0, a1
sw a0, -24(s0)
lw a0, -24(s0)
bnez a0, if_L41
then_L13:
li a0, 1
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
ret
j if_L42
if_L41:
li a0, 0
sw a0, -32(s0)
lw a0, -32(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
ret
if_L42:
func7:
addi sp, sp, -32
sw ra, 28(sp)
sw s0, 24(sp)
addi s0, sp, 32
sw a0, -12(s0)
lw a1, -12(s0)
seqz a0, a1
sw a0, -16(s0)
lw a1, -16(s0)
seqz a0, a1
sw a0, -20(s0)
lw a0, -20(s0)
bnez a0, if_L43
then_L14:
li a0, 1
sw a0, -24(s0)
lw a0, -24(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
ret
j if_L44
if_L43:
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 28(sp)
lw s0, 24(sp)
addi sp, sp, 32
ret
if_L44:
nestedCalls:
addi sp, sp, -480
sw ra, 476(sp)
sw s0, 472(sp)
addi s0, sp, 480
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
li a0, 2
sw a0, -52(s0)
lw a0, -52(s0)
sw a0, -56(s0)
li a0, 8
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
lw a0, -56(s0)
call func7
sw a0, -88(s0)
lw a0, -64(s0)
call func5
sw a0, -96(s0)
lw a1, -96(s0)
lw a0, -88(s0)
call func6
sw a0, -108(s0)
lw a1, -72(s0)
lw a0, -108(s0)
call func2
sw a0, -120(s0)
lw a1, -80(s0)
lw a0, -120(s0)
call func3
sw a0, -132(s0)
lw a0, -132(s0)
call func5
sw a0, -140(s0)
lw a0, -16(s0)
call func5
sw a0, -148(s0)
lw a0, -24(s0)
call func7
sw a0, -156(s0)
lw a1, -156(s0)
lw a0, -20(s0)
call func6
sw a0, -168(s0)
lw a0, -32(s0)
call func7
sw a0, -176(s0)
lw a1, -176(s0)
lw a0, -28(s0)
call func2
sw a0, -188(s0)
lw a2, -188(s0)
lw a1, -168(s0)
lw a0, -148(s0)
call func4
sw a0, -204(s0)
lw a1, -36(s0)
lw a0, -204(s0)
call func3
sw a0, -216(s0)
lw a1, -40(s0)
lw a0, -216(s0)
call func2
sw a0, -228(s0)
lw a0, -48(s0)
call func7
sw a0, -236(s0)
lw a1, -236(s0)
lw a0, -44(s0)
call func3
sw a0, -248(s0)
lw a2, -56(s0)
lw a1, -248(s0)
lw a0, -228(s0)
call func1
sw a0, -264(s0)
lw a2, -264(s0)
lw a1, -12(s0)
lw a0, -140(s0)
call func4
sw a0, -280(s0)
lw a0, -72(s0)
call func7
sw a0, -288(s0)
lw a1, -80(s0)
lw a0, -288(s0)
call func3
sw a0, -300(s0)
lw a1, -300(s0)
lw a0, -64(s0)
call func2
sw a0, -312(s0)
lw a1, -312(s0)
lw a0, -280(s0)
call func3
sw a0, -324(s0)
lw a2, -16(s0)
lw a1, -12(s0)
lw a0, -324(s0)
call func1
sw a0, -340(s0)
lw a1, -20(s0)
lw a0, -340(s0)
call func2
sw a0, -352(s0)
lw a0, -32(s0)
call func5
sw a0, -360(s0)
lw a1, -360(s0)
lw a0, -28(s0)
call func3
sw a0, -372(s0)
lw a0, -36(s0)
call func5
sw a0, -380(s0)
lw a1, -380(s0)
lw a0, -372(s0)
call func2
sw a0, -392(s0)
lw a0, -44(s0)
call func7
sw a0, -400(s0)
lw a2, -400(s0)
lw a1, -40(s0)
lw a0, -392(s0)
call func1
sw a0, -416(s0)
lw a0, -48(s0)
call func5
sw a0, -424(s0)
lw a1, -424(s0)
lw a0, -416(s0)
call func2
sw a0, -436(s0)
lw a1, -56(s0)
lw a0, -436(s0)
call func3
sw a0, -448(s0)
lw a2, -448(s0)
lw a1, -24(s0)
lw a0, -352(s0)
call func1
sw a0, -464(s0)
lw a0, -464(s0)
sw a0, -468(s0)
lw a0, -468(s0)
lw ra, 476(sp)
lw s0, 472(sp)
addi sp, sp, 480
ret
main:
addi sp, sp, -336
sw ra, 332(sp)
sw s0, 328(sp)
addi s0, sp, 336
li a0, 0
sw a0, -12(s0)
lw a0, -12(s0)
sw a0, -16(s0)
li a0, 12
sw a0, -20(s0)
lw a0, -20(s0)
call fibonacci
sw a0, -28(s0)
lw a0, -28(s0)
sw a0, -32(s0)
li a0, 22
sw a0, -36(s0)
li a0, 15
sw a0, -40(s0)
lw a1, -40(s0)
lw a0, -36(s0)
call gcd
sw a0, -52(s0)
lw a0, -52(s0)
sw a0, -56(s0)
li a0, 17
sw a0, -60(s0)
lw a0, -60(s0)
call isPrime
sw a0, -68(s0)
lw a0, -68(s0)
sw a0, -72(s0)
li a0, 8
sw a0, -76(s0)
lw a0, -76(s0)
call factorial
sw a0, -84(s0)
lw a0, -84(s0)
sw a0, -88(s0)
li a0, 7
sw a0, -92(s0)
li a0, 3
sw a0, -96(s0)
lw a1, -96(s0)
lw a0, -92(s0)
call combination
sw a0, -108(s0)
lw a0, -108(s0)
sw a0, -112(s0)
li a0, 3
sw a0, -116(s0)
li a0, 11
sw a0, -120(s0)
lw a1, -120(s0)
lw a0, -116(s0)
call power
sw a0, -132(s0)
lw a0, -132(s0)
sw a0, -136(s0)
li a0, 3
sw a0, -140(s0)
li a0, 5
sw a0, -144(s0)
li a0, 1
sw a0, -148(s0)
lw a2, -148(s0)
lw a1, -144(s0)
lw a0, -140(s0)
call complexFunction
sw a0, -164(s0)
lw a0, -164(s0)
sw a0, -168(s0)
li a0, 5
sw a0, -172(s0)
lw a1, -172(s0)
neg a0, a1
sw a0, -176(s0)
li a0, 10
sw a0, -180(s0)
lw a1, -180(s0)
lw a0, -176(s0)
call shortCircuit
sw a0, -192(s0)
lw a0, -192(s0)
sw a0, -196(s0)
li a0, 10
sw a0, -200(s0)
lw a0, -200(s0)
call nestedLoopsAndConditions
sw a0, -208(s0)
lw a0, -208(s0)
sw a0, -212(s0)
li a0, 1
sw a0, -216(s0)
li a0, 2
sw a0, -220(s0)
li a0, 3
sw a0, -224(s0)
li a0, 4
sw a0, -228(s0)
li a0, 5
sw a0, -232(s0)
li a0, 6
sw a0, -236(s0)
li a0, 7
sw a0, -240(s0)
li a0, 8
sw a0, -244(s0)
li a0, 9
sw a0, -248(s0)
li a0, 10
sw a0, -252(s0)
lw a0, -252(s0)
sw a0, 4(sp)
lw a0, -248(s0)
sw a0, 0(sp)
lw a7, -244(s0)
lw a6, -240(s0)
lw a5, -236(s0)
lw a4, -232(s0)
lw a3, -228(s0)
lw a2, -224(s0)
lw a1, -220(s0)
lw a0, -216(s0)
call nestedCalls
sw a0, -296(s0)
lw a0, -296(s0)
sw a0, -300(s0)
lw a0, -56(s0)
lw a1, -32(s0)
add a2, a1, a0
sw a2, -304(s0)
lw a0, -72(s0)
lw a1, -304(s0)
add a2, a1, a0
sw a2, -308(s0)
lw a0, -88(s0)
lw a1, -308(s0)
add a2, a1, a0
sw a2, -312(s0)
lw a0, -112(s0)
lw a1, -312(s0)
sub a2, a1, a0
sw a2, -316(s0)
lw a0, -136(s0)
lw a1, -316(s0)
add a2, a1, a0
sw a2, -320(s0)
lw a0, -212(s0)
lw a1, -320(s0)
sub a2, a1, a0
sw a2, -324(s0)
li a0, 256
sw a0, -328(s0)
lw a0, -328(s0)
lw a1, -324(s0)
rem a2, a1, a0
sw a2, -332(s0)
lw a0, -332(s0)
sw a0, -16(s0)
lw a0, -16(s0)
lw ra, 332(sp)
lw s0, 328(sp)
addi sp, sp, 336
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
