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
lw a1, -16(s0)
lw a0, -12(s0)
bgt a0, a1, if_L0
li a0, 1
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
if_L0:
li a0, 1
sw a0, -32(s0)
lw a0, -32(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -36(s0)
lw a0, -36(s0)
call factorial
sw a0, -40(s0)
lw a0, -40(s0)
lw a1, -12(s0)
mul a2, a1, a0
sw a2, -44(s0)
lw a0, -44(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
fibonacci:
addi sp, sp, -80
sw ra, 76(sp)
sw s0, 72(sp)
addi s0, sp, 80
sw a0, -12(s0)
li a0, 0
sw a0, -16(s0)
lw a1, -16(s0)
lw a0, -12(s0)
bgt a0, a1, if_L1
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 76(sp)
lw s0, 72(sp)
addi sp, sp, 80
ret
if_L1:
li a0, 1
sw a0, -32(s0)
lw a1, -32(s0)
lw a0, -12(s0)
bne a0, a1, if_L2
li a0, 1
sw a0, -44(s0)
lw a0, -44(s0)
lw ra, 76(sp)
lw s0, 72(sp)
addi sp, sp, 80
ret
if_L2:
li a0, 1
sw a0, -48(s0)
lw a0, -48(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -52(s0)
lw a0, -52(s0)
call fibonacci
sw a0, -56(s0)
li a0, 2
sw a0, -60(s0)
lw a0, -60(s0)
lw a1, -12(s0)
sub a2, a1, a0
sw a2, -64(s0)
lw a0, -64(s0)
call fibonacci
sw a0, -68(s0)
lw a0, -68(s0)
lw a1, -56(s0)
add a2, a1, a0
sw a2, -72(s0)
lw a0, -72(s0)
lw ra, 76(sp)
lw s0, 72(sp)
addi sp, sp, 80
ret
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
bne a0, a1, if_L3
lw a0, -12(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
if_L3:
lw a0, -16(s0)
lw a1, -12(s0)
rem a2, a1, a0
sw a2, -32(s0)
lw a1, -32(s0)
lw a0, -16(s0)
call gcd
sw a0, -36(s0)
lw a0, -36(s0)
lw ra, 44(sp)
lw s0, 40(sp)
addi sp, sp, 48
ret
is_prime:
addi sp, sp, -176
sw ra, 172(sp)
sw s0, 168(sp)
addi s0, sp, 176
sw a0, -12(s0)
li a0, 1
sw a0, -16(s0)
lw a1, -16(s0)
lw a0, -12(s0)
bgt a0, a1, if_L4
li a0, 0
sw a0, -28(s0)
lw a0, -28(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L4:
li a0, 3
sw a0, -32(s0)
lw a1, -32(s0)
lw a0, -12(s0)
bgt a0, a1, if_L5
li a0, 1
sw a0, -44(s0)
lw a0, -44(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L5:
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
seqz a2, a2
sub a2, a1, a0
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
seqz a2, a2
sub a2, a1, a0
sw a2, -76(s0)
lw a0, -76(s0)
lw a1, -60(s0)
or a2, a1, a0
sw a2, -80(s0)
lw a1, -80(s0)
seqz a0, a1
sw a0, -84(s0)
lw a0, -84(s0)
bnez a0, if_L6
li a0, 0
sw a0, -88(s0)
lw a0, -88(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L6:
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
seqz a2, a2
sub a2, a1, a0
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
seqz a2, a2
sub a2, a1, a0
sw a2, -140(s0)
lw a0, -140(s0)
lw a1, -120(s0)
or a2, a1, a0
sw a2, -144(s0)
lw a1, -144(s0)
seqz a0, a1
sw a0, -148(s0)
lw a0, -148(s0)
bnez a0, if_L7
li a0, 0
sw a0, -152(s0)
lw a0, -152(s0)
lw ra, 172(sp)
lw s0, 168(sp)
addi sp, sp, 176
ret
if_L7:
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
main:
addi sp, sp, -784
sw ra, 780(sp)
sw s0, 776(sp)
addi s0, sp, 784
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
lw a0, -24(s0)
lw a1, -16(s0)
add a2, a1, a0
sw a2, -44(s0)
lw a0, -32(s0)
lw a1, -44(s0)
mul a2, a1, a0
sw a2, -48(s0)
lw a0, -16(s0)
lw a1, -40(s0)
mul a2, a1, a0
sw a2, -52(s0)
lw a0, -52(s0)
lw a1, -48(s0)
add a2, a1, a0
sw a2, -56(s0)
lw a0, -32(s0)
lw a1, -24(s0)
add a2, a1, a0
sw a2, -60(s0)
lw a1, -40(s0)
neg a0, a1
sw a0, -64(s0)
lw a0, -64(s0)
lw a1, -16(s0)
add a2, a1, a0
sw a2, -68(s0)
li a0, 2048
sw a0, -72(s0)
lw a0, -72(s0)
lw a1, -68(s0)
add a2, a1, a0
sw a2, -76(s0)
lw a0, -76(s0)
lw a1, -60(s0)
rem a2, a1, a0
sw a2, -80(s0)
li a0, 1
sw a0, -84(s0)
lw a0, -84(s0)
lw a1, -80(s0)
add a2, a1, a0
sw a2, -88(s0)
lw a0, -88(s0)
lw a1, -56(s0)
div a2, a1, a0
sw a2, -92(s0)
lw a0, -24(s0)
lw a1, -16(s0)
mul a2, a1, a0
sw a2, -96(s0)
lw a0, -32(s0)
lw a1, -96(s0)
mul a2, a1, a0
sw a2, -100(s0)
li a0, 2
sw a0, -104(s0)
lw a0, -104(s0)
lw a1, -40(s0)
sub a2, a1, a0
sw a2, -108(s0)
lw a0, -32(s0)
lw a1, -108(s0)
sub a2, a1, a0
sw a2, -112(s0)
lw a0, -112(s0)
lw a1, -100(s0)
mul a2, a1, a0
sw a2, -116(s0)
lw a0, -116(s0)
lw a1, -92(s0)
add a2, a1, a0
sw a2, -120(s0)
lw a0, -120(s0)
sw a0, -124(s0)
li a0, 0
sw a0, -128(s0)
lw a0, -128(s0)
sw a0, -132(s0)
li a0, 1
sw a0, -136(s0)
lw a0, -136(s0)
sw a0, -140(s0)
li a0, 2
sw a0, -144(s0)
lw a0, -144(s0)
sw a0, -148(s0)
li a0, 0
sw a0, -152(s0)
lw a0, -152(s0)
sw a0, -156(s0)
lw a0, -140(s0)
lw a1, -132(s0)
sgt a2, a1, a0
sw a2, -160(s0)
li a0, 1
sw a0, -164(s0)
lw a0, -164(s0)
lw a1, -148(s0)
add a2, a1, a0
sw a2, -168(s0)
li a0, 1
sw a0, -172(s0)
lw a0, -172(s0)
lw a1, -168(s0)
seqz a2, a2
sub a2, a1, a0
sw a2, -176(s0)
lw a0, -176(s0)
lw a1, -160(s0)
and a2, a1, a0
sw a2, -180(s0)
lw a1, -180(s0)
seqz a0, a1
sw a0, -184(s0)
lw a0, -184(s0)
bnez a0, if_L8
li a0, 1
sw a0, -188(s0)
lw a0, -188(s0)
sw a0, -156(s0)
if_L8:
li a0, 0
sw a0, -192(s0)
lw a0, -192(s0)
sw a0, -196(s0)
lw a0, -140(s0)
lw a1, -132(s0)
slt a2, a1, a0
sw a2, -200(s0)
li a0, 2
sw a0, -204(s0)
lw a0, -204(s0)
lw a1, -148(s0)
add a2, a1, a0
sw a2, -208(s0)
li a0, 2
sw a0, -212(s0)
lw a0, -212(s0)
lw a1, -208(s0)
seqz a2, a2
sub a2, a1, a0
sw a2, -216(s0)
lw a0, -216(s0)
lw a1, -200(s0)
or a2, a1, a0
sw a2, -220(s0)
lw a1, -220(s0)
seqz a0, a1
sw a0, -224(s0)
lw a0, -224(s0)
bnez a0, if_L9
li a0, 1
sw a0, -228(s0)
lw a0, -228(s0)
sw a0, -196(s0)
if_L9:
li a0, 0
sw a0, -232(s0)
lw a0, -232(s0)
sw a0, -236(s0)
li a0, 0
sw a0, -240(s0)
lw a0, -240(s0)
lw a1, -132(s0)
sgt a2, a1, a0
sw a2, -244(s0)
li a0, 0
sw a0, -248(s0)
lw a0, -248(s0)
lw a1, -140(s0)
slt a2, a1, a0
sw a2, -252(s0)
lw a0, -252(s0)
lw a1, -244(s0)
and a2, a1, a0
sw a2, -256(s0)
li a0, 0
sw a0, -260(s0)
lw a0, -260(s0)
lw a1, -148(s0)
sgt a2, a1, a0
sw a2, -264(s0)
li a0, 0
sw a0, -268(s0)
lw a0, -268(s0)
lw a1, -132(s0)
slt a2, a1, a0
sw a2, -272(s0)
lw a0, -272(s0)
lw a1, -264(s0)
and a2, a1, a0
sw a2, -276(s0)
lw a0, -276(s0)
lw a1, -256(s0)
or a2, a1, a0
sw a2, -280(s0)
lw a1, -280(s0)
seqz a0, a1
sw a0, -284(s0)
li a0, 0
sw a0, -288(s0)
lw a0, -288(s0)
lw a1, -140(s0)
sgt a2, a1, a0
sw a2, -292(s0)
li a0, 0
sw a0, -296(s0)
lw a0, -296(s0)
lw a1, -132(s0)
slt a2, a1, a0
sw a2, -300(s0)
lw a0, -300(s0)
lw a1, -292(s0)
or a2, a1, a0
sw a2, -304(s0)
lw a0, -304(s0)
lw a1, -284(s0)
and a2, a1, a0
sw a2, -308(s0)
lw a1, -308(s0)
seqz a0, a1
sw a0, -312(s0)
lw a0, -312(s0)
bnez a0, if_L10
li a0, 1
sw a0, -316(s0)
lw a0, -316(s0)
sw a0, -236(s0)
if_L10:
li a0, 42
sw a0, -320(s0)
lw a0, -320(s0)
sw a0, -324(s0)
li a0, 56
sw a0, -328(s0)
lw a0, -328(s0)
sw a0, -332(s0)
li a0, 87
sw a0, -336(s0)
lw a0, -336(s0)
sw a0, -340(s0)
lw a1, -340(s0)
lw a0, -332(s0)
call gcd
sw a0, -344(s0)
lw a0, -344(s0)
call factorial
sw a0, -348(s0)
li a0, 5
sw a0, -352(s0)
lw a0, -352(s0)
lw a1, -324(s0)
div a2, a1, a0
sw a2, -356(s0)
lw a0, -356(s0)
call fibonacci
sw a0, -360(s0)
lw a0, -360(s0)
lw a1, -348(s0)
add a2, a1, a0
sw a2, -364(s0)
lw a0, -364(s0)
sw a0, -368(s0)
li a0, 0
sw a0, -372(s0)
lw a0, -372(s0)
sw a0, -376(s0)
lw a0, -332(s0)
lw a1, -324(s0)
sgt a2, a1, a0
sw a2, -380(s0)
lw a0, -340(s0)
lw a1, -324(s0)
sgt a2, a1, a0
sw a2, -384(s0)
lw a0, -384(s0)
lw a1, -380(s0)
and a2, a1, a0
sw a2, -388(s0)
lw a1, -388(s0)
seqz a0, a1
sw a0, -392(s0)
lw a0, -392(s0)
bnez a0, if_L11
then_L0:
lw a0, -324(s0)
sw a0, -376(s0)
j if_L12
if_L11:
lw a0, -324(s0)
lw a1, -332(s0)
sgt a2, a1, a0
sw a2, -396(s0)
lw a0, -340(s0)
lw a1, -332(s0)
sgt a2, a1, a0
sw a2, -400(s0)
lw a0, -400(s0)
lw a1, -396(s0)
and a2, a1, a0
sw a2, -404(s0)
lw a1, -404(s0)
seqz a0, a1
sw a0, -408(s0)
lw a0, -408(s0)
bnez a0, if_L13
then_L1:
lw a0, -332(s0)
sw a0, -376(s0)
j if_L14
if_L13:
lw a0, -340(s0)
sw a0, -376(s0)
if_L14:
if_L12:
li a0, 0
sw a0, -412(s0)
lw a0, -412(s0)
sw a0, -416(s0)
li a0, 1
sw a0, -420(s0)
lw a0, -420(s0)
sw a0, -424(s0)
j while_L3
while_L3:
li a0, 10
sw a0, -428(s0)
lw a1, -428(s0)
lw a0, -424(s0)
bgt a0, a1, while_L5
while_L4:
li a0, 2
sw a0, -440(s0)
lw a0, -440(s0)
lw a1, -424(s0)
rem a2, a1, a0
sw a2, -444(s0)
li a0, 0
sw a0, -448(s0)
lw a1, -448(s0)
lw a0, -444(s0)
bne a0, a1, if_L15
then_L2:
lw a0, -424(s0)
lw a1, -424(s0)
mul a2, a1, a0
sw a2, -460(s0)
lw a0, -460(s0)
lw a1, -416(s0)
add a2, a1, a0
sw a2, -464(s0)
lw a0, -464(s0)
sw a0, -416(s0)
j if_L16
if_L15:
li a0, 3
sw a0, -468(s0)
lw a0, -468(s0)
lw a1, -424(s0)
rem a2, a1, a0
sw a2, -472(s0)
li a0, 0
sw a0, -476(s0)
lw a1, -476(s0)
lw a0, -472(s0)
bne a0, a1, if_L17
then_L3:
lw a0, -424(s0)
lw a1, -424(s0)
mul a2, a1, a0
sw a2, -488(s0)
lw a0, -424(s0)
lw a1, -488(s0)
mul a2, a1, a0
sw a2, -492(s0)
lw a0, -492(s0)
lw a1, -416(s0)
add a2, a1, a0
sw a2, -496(s0)
lw a0, -496(s0)
sw a0, -416(s0)
j if_L18
if_L17:
lw a0, -424(s0)
lw a1, -416(s0)
add a2, a1, a0
sw a2, -500(s0)
lw a0, -500(s0)
sw a0, -416(s0)
if_L18:
if_L16:
li a0, 1
sw a0, -504(s0)
lw a0, -504(s0)
lw a1, -424(s0)
add a2, a1, a0
sw a2, -508(s0)
lw a0, -508(s0)
sw a0, -424(s0)
j while_L3
while_L5:
li a0, 0
sw a0, -512(s0)
lw a0, -512(s0)
sw a0, -516(s0)
li a0, 1
sw a0, -520(s0)
lw a0, -520(s0)
sw a0, -424(s0)
j while_L6
while_L6:
li a0, 5
sw a0, -524(s0)
lw a1, -524(s0)
lw a0, -424(s0)
bgt a0, a1, while_L8
while_L7:
li a0, 1
sw a0, -536(s0)
lw a0, -536(s0)
sw a0, -540(s0)
li a0, 1
sw a0, -544(s0)
lw a0, -544(s0)
sw a0, -548(s0)
j while_L9
while_L9:
lw a1, -424(s0)
lw a0, -540(s0)
bgt a0, a1, while_L11
while_L10:
lw a0, -540(s0)
lw a1, -548(s0)
mul a2, a1, a0
sw a2, -560(s0)
lw a0, -560(s0)
sw a0, -548(s0)
li a0, 1
sw a0, -564(s0)
lw a0, -564(s0)
lw a1, -540(s0)
add a2, a1, a0
sw a2, -568(s0)
lw a0, -568(s0)
sw a0, -540(s0)
j while_L9
while_L11:
lw a0, -548(s0)
lw a1, -516(s0)
add a2, a1, a0
sw a2, -572(s0)
lw a0, -572(s0)
sw a0, -516(s0)
li a0, 1
sw a0, -576(s0)
lw a0, -576(s0)
lw a1, -424(s0)
add a2, a1, a0
sw a2, -580(s0)
lw a0, -580(s0)
sw a0, -424(s0)
j while_L6
while_L8:
li a0, 0
sw a0, -584(s0)
lw a0, -584(s0)
sw a0, -588(s0)
lw a0, -324(s0)
call is_prime
sw a0, -592(s0)
lw a1, -592(s0)
seqz a0, a1
sw a0, -596(s0)
lw a0, -596(s0)
bnez a0, if_L19
then_L4:
lw a0, -332(s0)
call is_prime
sw a0, -600(s0)
lw a1, -600(s0)
seqz a0, a1
sw a0, -604(s0)
lw a0, -604(s0)
bnez a0, if_L21
then_L5:
lw a0, -332(s0)
lw a1, -324(s0)
mul a2, a1, a0
sw a2, -608(s0)
lw a0, -608(s0)
sw a0, -588(s0)
j if_L22
if_L21:
lw a0, -340(s0)
call is_prime
sw a0, -612(s0)
lw a1, -612(s0)
seqz a0, a1
sw a0, -616(s0)
lw a0, -616(s0)
bnez a0, if_L23
then_L6:
lw a0, -340(s0)
lw a1, -324(s0)
mul a2, a1, a0
sw a2, -620(s0)
lw a0, -620(s0)
sw a0, -588(s0)
j if_L24
if_L23:
lw a0, -324(s0)
sw a0, -588(s0)
if_L24:
if_L22:
j if_L20
if_L19:
lw a0, -332(s0)
call is_prime
sw a0, -624(s0)
lw a1, -624(s0)
seqz a0, a1
sw a0, -628(s0)
lw a0, -628(s0)
bnez a0, if_L25
then_L7:
lw a0, -340(s0)
call is_prime
sw a0, -632(s0)
lw a1, -632(s0)
seqz a0, a1
sw a0, -636(s0)
lw a0, -636(s0)
bnez a0, if_L27
then_L8:
lw a0, -340(s0)
lw a1, -332(s0)
mul a2, a1, a0
sw a2, -640(s0)
lw a0, -640(s0)
sw a0, -588(s0)
j if_L28
if_L27:
lw a0, -332(s0)
sw a0, -588(s0)
if_L28:
j if_L26
if_L25:
lw a0, -340(s0)
call is_prime
sw a0, -644(s0)
lw a1, -644(s0)
seqz a0, a1
sw a0, -648(s0)
lw a0, -648(s0)
bnez a0, if_L29
then_L9:
lw a0, -340(s0)
sw a0, -588(s0)
j if_L30
if_L29:
lw a0, -332(s0)
lw a1, -324(s0)
add a2, a1, a0
sw a2, -652(s0)
lw a0, -340(s0)
lw a1, -652(s0)
add a2, a1, a0
sw a2, -656(s0)
lw a0, -656(s0)
sw a0, -588(s0)
if_L30:
if_L26:
if_L20:
li a0, 0
sw a0, -660(s0)
lw a0, -660(s0)
sw a0, -664(s0)
li a0, 2345
sw a0, -668(s0)
lw a0, -668(s0)
sw a0, -672(s0)
li a0, 0
sw a0, -676(s0)
lw a0, -676(s0)
sw a0, -680(s0)
j while_L12
while_L12:
li a0, 0
sw a0, -684(s0)
lw a1, -684(s0)
lw a0, -672(s0)
ble a0, a1, while_L14
while_L13:
li a0, 2
sw a0, -696(s0)
lw a0, -696(s0)
lw a1, -672(s0)
rem a2, a1, a0
sw a2, -700(s0)
li a0, 1
sw a0, -704(s0)
lw a1, -704(s0)
lw a0, -700(s0)
bne a0, a1, if_L31
li a0, 1
sw a0, -716(s0)
lw a0, -716(s0)
lw a1, -680(s0)
add a2, a1, a0
sw a2, -720(s0)
lw a0, -720(s0)
sw a0, -680(s0)
if_L31:
li a0, 2
sw a0, -724(s0)
lw a0, -724(s0)
lw a1, -672(s0)
div a2, a1, a0
sw a2, -728(s0)
lw a0, -728(s0)
sw a0, -672(s0)
j while_L12
while_L14:
lw a0, -156(s0)
lw a1, -124(s0)
add a2, a1, a0
sw a2, -732(s0)
lw a0, -196(s0)
lw a1, -732(s0)
add a2, a1, a0
sw a2, -736(s0)
lw a0, -236(s0)
lw a1, -736(s0)
add a2, a1, a0
sw a2, -740(s0)
lw a0, -368(s0)
lw a1, -740(s0)
add a2, a1, a0
sw a2, -744(s0)
lw a0, -376(s0)
lw a1, -744(s0)
add a2, a1, a0
sw a2, -748(s0)
lw a0, -416(s0)
lw a1, -748(s0)
add a2, a1, a0
sw a2, -752(s0)
lw a0, -516(s0)
lw a1, -752(s0)
add a2, a1, a0
sw a2, -756(s0)
lw a0, -588(s0)
lw a1, -756(s0)
add a2, a1, a0
sw a2, -760(s0)
lw a0, -680(s0)
lw a1, -760(s0)
add a2, a1, a0
sw a2, -764(s0)
lw a0, -764(s0)
sw a0, -768(s0)
li a0, 256
sw a0, -772(s0)
lw a0, -772(s0)
lw a1, -768(s0)
rem a2, a1, a0
sw a2, -776(s0)
lw a0, -776(s0)
lw ra, 780(sp)
lw s0, 776(sp)
addi sp, sp, 784
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
