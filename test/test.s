.global _start
_start:
    j main 
.global main    
main:
li a0, 193
# 添加系统调用退出
li a7, 93         # exit 系统调用号
ecall             # 执行系统调用
ret               # 这行实际上不会执行到
