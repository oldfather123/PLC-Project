#!/bin/bash
clang --target=riscv64-unknown-elf -nostdlib -static test/test.s -o test/test.out
qemu-riscv64 test/test.out
echo $?
