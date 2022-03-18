%include "../lib/winlib.asm"
%include "../lib/strlib.asm"
%include "../lib/printflib.asm"

section .data
    str:                    db  "Hello, %%world!%%%%KEKL%%", 10, 0
    str2:                   db  "H%c M%c Fr%%%c%%end!", 10, 0
    i:                      db  'i'
    y:                      db  'y'
    str3:                   db  "Hi, my name is '%s'", 10, 0
    name:                   db  "Vladko!!", 0
    str4:                   db  "Hello, bool %b <=> 0", 10, 0
    str5:                   db  "Hi, lets %% %s %% %d to HEX: %x and to OCT: %o - %b (%c)", 10, 0
    convert:                db  "convert", 0

section .text
global _main

_main:
    ; %d, %o, %x, %s, %c, %%, %b test
    push 'Y'
    push 0xFF00
    push 0xFF00
    push 0xFF00
    push 0xFF00
    push convert
    push str5
    call _myPrintf
    add esp, 12
    ; end of %d, %o, %x, %s, %c, %%, %b test

    ; %b test
    ;push 0
    ;push str4
    ;call myPrintf
    ;add esp, 8
    ; end of %b test

    ; %s test
    ;push name
    ;push str3
    ;call myPrintf 
    ;add esp, 8
    ; end of %s test
    
    ; %% and %c test 
    ;push i 
    ;push y 
    ;push i
    ;push str2
    ;call myPrintf
    ;add esp, 8
    ; end of %% and %c test  
    
    
    ; -------------PrintString test example-------------------
    ;GetStdHandle -11    ; eax = hStdOut = GetStdHandle( STD_OUTPUT_HANDLE );
    ;push str2
    ;call PrintString
    ;add esp, 4
    ; --------------------------------------------------------
  
    ; -------------------itoa test example--------------------
    ;push 16
    ;push buffer
    ;push 0xFC839E
    ;call itoa
    ;add esp, 12
    
    ;GetStdHandle -11
    ;push buffer
    ;call PrintString
    ;add esp, 4
    ; --------------------------------------------------------
        
.exit:
    ExitProcess 0