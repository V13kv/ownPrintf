%include "winlib.asm"

section .data
    message         db  "Hello, World!", 10
    message_length  equ $ - message

section .text
global _main

_main:
    ; eax = hStdOut = GetStdHandle( STD_OUTPUT_HANDLE );
    GetStdHandle -11
    
    ; DWORD bytes;
    mov ebp, esp
    sub esp, 4
    
    ; WriteFile(hStdOut, message, len(message), &bytes, 0);
    lea ebx, [ebp - 4]  ;address where total number of written bytes will be located
    WriteFile eax, message, message_length, ebx, 0
    
    ; ExitProcess(0)
    ExitProcess 0
    
    ; Error check
    hlt