%ifndef WINLIB
%define WINLIB

extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4


%macro GetStdHandle 1
    push %1
    call _GetStdHandle@4        ; eax = stdHandleNumber
%endmacro


%macro WriteFile 5
    push dword %5
    push dword %4
    push dword %3
    push dword %2
    push dword %1
    call _WriteFile@20
%endmacro


%macro ExitProcess 1
    call _ExitProcess@4
%endmacro

%endif