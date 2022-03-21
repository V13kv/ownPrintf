extern _printf

section .data
    str1    db  "Hello, world!", 10, 0
    str2    db  "str3 is '%s', isn't that cool? %d in hex is 0x%x", 10, 0
    str3    db  "woot woot", 0
    str4    db  "%c is a char, but so is %%, %s again!", 10, 0

section .text
global _main

_main:
    push 0xDEADBEEF
    push 0xDEADBEEF
    push str3
    push str2
    call _printf
    add esp, 8
    
    xor eax, eax
    ret