%ifndef STRLIB
%define STRLIB

%include "../lib/winlib.asm"

%ifndef endOfString
    endOfString         equ     0x00
%endif

%macro itoaFastConvertOfPowerOfTwo 2
    mov edx, eax
    and edx, %1 - 1
    mov dl, byte [charTable + edx]
    mov byte [edi], dl
    inc edi
    
    shr eax, %2
    test eax, eax
%endmacro

section .data
    charTable:      db  "0123456789abcdef"
    true            db  "true", 0
    false           db  "false", 0

section .bss
    numberOfBytesWritten:   resd    1

section .text

PrintString:
    ; Save context
    push ebp
    mov ebp, esp
    
    ; Save used registers
    push esi
    push eax
    
    ; Initialize
    mov esi, [ebp + 8]          ; [ebp + 8] - string address
.loop:
    cmp byte [esi], endOfString
    je .exit
    
    push esi                    ; character
    push numberOfBytesWritten   ; DWORD bytes 
    call PrintChar
    add esp, 8
    
    inc esi
    jmp .loop
 
.exit:   
    ; Restore saved used registers
    pop eax
    pop esi
    
    ; Restore context
    pop ebp
    ret
    

PrintChar:
    ; Save context
    push ebp
    mov ebp, esp
    
    ; Save used registers
    push eax
    
    ; WriteFile(hStdOut, message, len(message), &bytes, 0);
    WriteFile eax, [ebp + 12], 1, [ebp + 8], 0
  
    ; Restore saved used registers
    pop eax
        
    ; Restore context
    pop ebp
    ret


btoa:
    ; Save context
    push ebp
    mov ebp, esp
    
    ; Save used registers
    push eax
    
    ; Main body
    mov eax, [ebp + 8]          ; [ebp + 8] - value to represent as a bool
    test eax, eax
    jz .false
        
    .true:
        pop eax
        push true
        jmp .done
    .false:
        pop eax
        push false
    .done:
        call PrintString
        add esp, 4
    
    ; Restore context
    pop ebp
    ret


itoa:
    ; Save context
    push ebp
    mov ebp, esp   
    
    ; Save used registers
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Initialization
    mov eax, [ebp + 8]      ; [ebp + 8] - value to represent as ASCIIZ
    mov edi, [ebp + 12]     ; [ebp + 12] - buffer (where to store string representation)
    mov ebx, [ebp + 16]     ; [ebp + 16] - radix used to represent the value as a string

    mov esi, edi    ; save beginning of the buffer

    ; ---Check for faster conversion---
    cmp ebx, 16
    jz .hexLoop
    
    cmp ebx, 8
    jz .octLoop
    
    cmp ebx, 2
    jz .binLoop
    ; ---End of check for faster conversion---

    mov ecx, ebx
.notPowerOfTwo:
    xor edx, edx
    idiv ecx
    
    mov dl, byte [charTable + edx]
    mov byte [edi], dl
    inc edi
    
    test eax, eax
    jnz .notPowerOfTwo
    jmp .reverseBuffer
    
.hexLoop:
    itoaFastConvertOfPowerOfTwo 16, 4    
    jnz .hexLoop
    jmp .reverseBuffer

.octLoop:
    itoaFastConvertOfPowerOfTwo 8, 3  
    jnz .octLoop
    jmp .reverseBuffer

.binLoop:
    itoaFastConvertOfPowerOfTwo 2, 1 
    jnz .binLoop
    jmp .reverseBuffer

.reverseBuffer:
    mov edx, esi        ; save start address of the buffer
    
    mov ecx, edi
    sub ecx, esi        ; ecx - length of the string
    shr ecx, 1          ; duv string length by 2
    
    test cx, cx
    jz .done
    
    dec edi
.xchgCycle:
    ; Remove all leading zeros
    mov bl, byte [edi]
    cmp bl, '0'
    jnz .xchgValues
    
    dec edi
    jmp .xchgCycle

.xchgValues:
    ; Exchange values (4 moves are still cheeper than mov + xchg)
    mov bl, byte [edi]
    mov al, byte [esi]   
    mov byte [esi], bl
    mov byte [edi], al
  
    inc esi
    dec edi
    loop .xchgValues

    mov edi, edx        ; pointer to the char buffer (string)
.done:
    ; Restore saved registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; Restore context
    pop ebp
    ret
    

%endif