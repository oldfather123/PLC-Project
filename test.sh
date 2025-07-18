#!/bin/bash
clang --target=riscv32-unknown-elf -nostdlib -static test/test.s -o test/test.out
qemu-riscv32 test/test.out
echo $?
