%ifndef PRINTFLIB
%define PRINTFLIB

%include "../lib/winlib.asm"
%include "../lib/strlib.asm"

section .bss
    charToPrint:            resb    1
    printfProceedArgNumber: resd    1
    stringBuffer:           resb    STRING_BUFFER_LENGTH
    base:                   resd    1

section .text
global _myPrintf

_myPrintf:
    ; Save context
    push ebp
    mov ebp, esp
    
    ; Save used registers
    push esi
    push ebx
    
    ; Initialize
    GetStdHandle -11    ; eax = hStdOut = GetStdHandle( STD_OUTPUT_HANDLE );
    mov dword [printfProceedArgNumber], 0 
    mov esi, [ebp + 8]
    
.mainLoop:
    cmp byte [esi], endOfString
    je .exit
    
    cmp byte [esi], specifierPrefix
    je .proceedFoundPrefixSpecifier
    
    ; Save character that will be printed
    push eax  
    mov al, byte [esi]
    mov [charToPrint], al  
    pop eax
    
.printNextChar:
    push charToPrint            ; character
    push numberOfBytesWritten   ; DWORD bytes 
    call PrintChar
    add esp, 8  

.getNextCharacter:   
    inc esi                     ; take next character
    jmp .mainLoop    
 
.proceedFoundPrefixSpecifier:
    ; Save used registers
    push eax
   
    inc esi                 ; esi now points to specifier character 
.switch:
    movsx eax, byte [esi]
    cmp eax, specifierPercent
    je .casePercent
    jl .default
    
    cmp eax, specifierX
    jg .default
    
    cmp eax, specifierB
    jl .default
    
    sub eax, specifierB
    cmp eax, 22                     ; after sub indexing range is [0, 22]
    ja .default
    
    mov eax, [.jumpTable + 4 * eax]
    jmp eax
  
    .jumpTable:
        dd  .caseB
        dd  .caseC
        dd  .caseD
        times 10 dd .default
        dd  .caseO
        times 3 dd .default
        dd  .caseS
        times 4 dd .default
        dd  .caseX
 
    .caseB:
        mov dword [base], BASE_BIN
        jmp .body
    .caseO:
        mov dword [base], BASE_OCT
        jmp .body
    .caseD:
        mov dword [base], BASE_DEC
        jmp .body
    .caseX:
        mov dword [base], BASE_HEX
        
        .body:
            call GetNextPrintfArgument
            mov ebx, eax
            
            ; Restore eax value, i.e. descriptor number (stdout)
            pop eax
            
            ; Convert number to ASCIIZ string
            push dword [base]
            push stringBuffer
            push ebx
            call itoa
            add esp, 12
            
            ; Output converted number (ASCIIZ buffer-string)
            push stringBuffer
            call PrintString
            add esp, 4
            
            ; Reset string buffer
            push STRING_BUFFER_LENGTH
            push 0x00
            push stringBuffer
            call memset
            add esp, 12
            
            jmp .getNextCharacter
             
    .caseS:
        call GetNextPrintfArgument    
        mov ebx, eax
         
        ; Restore eax value, i.e. descriptor number (stdout)          
        pop eax
        
        push ebx    
        call PrintString
        add esp, 4
        
        jmp .getNextCharacter
               
    .caseC:
        call GetNextPrintfArgument      ; eax = nextPrinfArgument
        mov byte [charToPrint], al     ; save retrieved character  
        
        pop eax                         ; restore previous eax
        jmp .printNextChar
    
    .casePercent:
        mov byte [charToPrint], specifierPercent

        pop eax                         ; restore previous eax
        jmp .printNextChar 

    .default:
        ; TODO: print error message, no such specifier 
        pop eax
        jmp .exit

.exit:
    ; Restore saved used registers 
    pop ebx
    pop esi
    
    ; Restore context
    pop ebp
    ret

GetNextPrintfArgument:
    mov eax, [printfProceedArgNumber]
    mov eax, [ebp + 12 + 4 * eax]       ; at ebp + 12 displacement is the first printf arg is located (first from left to right in string format)
    inc dword [printfProceedArgNumber]  ; increment number of parsed parameters
    
    ret


specifierPrefix     equ     '%'

specifierPercent    equ     specifierPrefix
specifierC          equ     'c'
specifierS          equ     's'
specifierD          equ     'd'
specifierX          equ     'x'
specifierO          equ     'o'
specifierB          equ     'b'

STRING_BUFFER_LENGTH    equ     64

%endif