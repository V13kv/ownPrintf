%ifndef STRLIB
%define STRLIB

%include "../lib/winlib.asm"

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
    charTable:  db  "0123456789abcdef"
    true:       db  "true", 0
    false:      db  "false", 0

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
    mov ecx, ebx    ; save radix

    ; ---Check for faster conversion---
    cmp ebx, BASE_DEC
    jz .signCheck
    
    cmp ebx, BASE_BIN
    jz .binLoop
     
    cmp ebx, BASE_OCT
    jz .octLoop
    
    cmp ebx, BASE_HEX
    jz .hexLoop
  
    ; ---End of check for faster conversion---
.signCheck:
    mov edx, eax
    and edx, fourByteSignCheck
    jz .notPowerOfTwo
    
    mov byte [edi], minusSign
    inc edi
    inc esi 
    
    ; Get modulo of the given negative number
    not eax
    inc eax    
   
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
    ;mov edx, esi        ; save start address of the buffer
    
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

memset:
    ; Save context
    push ebp
    mov ebp, esp
    
    ; Save used registers
    push ax
    push ecx
    push edi
    
    ; Initialization
    mov edi, [ebp + 8]      ; [ebp + 8] - address of the object to fill
    mov al, [ebp + 12]      ; [ebp + 12] - fill byte
    mov ecx, [ebp + 16]     ; [ebp + 16] - number of bytes to fill
    
    ; Filling
    cld
    rep stosb
    
    ; Restore saved used registers
    pop edi
    pop ecx
    pop ax
    
    ; Restore context
    pop ebp
    ret

 
%ifndef endOfString
    endOfString         equ     0x00
%endif

fourByteSignCheck   equ     0x80000000
minusSign           equ     '-'

BASE_HEX    equ     16
BASE_DEC    equ     10
BASE_OCT    equ     8
BASE_BIN    equ     2   

%endif