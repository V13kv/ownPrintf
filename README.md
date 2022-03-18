# Printf implementation
Shortened Assembly [`printf`](https://en.cppreference.com/w/c/io/fprintf) library implementation for Windows.

## What is the idea?
The idea is to understand how `printf` works from the inside and understand the intricacies of writing applications for the Windows system in [NASM](https://www.nasm.us/) assembler using the [Windows API](https://docs.microsoft.com/en-us/previous-versions//cc433218(v=vs.85)?redirectedfrom=MSDN).

## What `printf` specifiers are available?
There are `%%, %c, %s, %d, %x, %o, %b` (`%b` stands for "convert a boolean argument to the string `true` or `false`, named `btoa` in the code) specifiers.

## Program architecture
![Program architecture](https://github.com/V13kv/ownPrintf/blob/main/printf.png)

## Description of libraries
1. Strlib contains `btoa`, `printString`, `PrintChar`, [`itoa`](https://www.cplusplus.com/reference/cstdlib/itoa/), [`memset`](https://en.cppreference.com/w/c/string/byte/memset).
2. Winlib contains macroses-wrappers for Windows API: [`GetStdHandle`](https://docs.microsoft.com/en-us/windows/console/getstdhandle), [`WriteFile`](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-writefile), [`ExitProcess`](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess).
3. Printflib contains only `_myPrintf` implementation.

## Implementation details
1. [`switch`](https://en.cppreference.com/w/cpp/language/switch) is implemented via [`jump table`](https://en.wikipedia.org/wiki/Branch_table).
2. `itoa` is implemented with the faster division if the given base (radix) is a power of two.
3. `GetNextPrintfArgument` function gets each new unproceed printf argument using global variable (it is assumed that the number of arguments passed after `format string` is not less than the number of specifiers in it).

## Compiling && Running
**Compile, link and run examples:**
```
cd examples
nasm.exe -f win32 ownPrintf.asm -o ownPrintf.obj
gcc.exe -m32 -o ownPrintf
.\ownPrintf.exe
```

**Compile** `printflib.asm` **, link and run** with another program (e.g. with C program)
```
cd examples
& '<path_to_nasm_assembler>\nasm.exe' -f win32 ..\lib\printflib.asm
<mingw32_gcc>.exe -c test.c -o test.o
<mingw32_gcc>.exe test.o ..\lib\printflib.obj -o test.exe
.\test.exe
```
