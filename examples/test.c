#include <stdio.h>
#include <stddef.h>

extern void __cdecl myPrintf(char const *const _Format, ...);

#define RED     "\033[0;31m"
#define GREEN   "\033[0;32m"
#define YELLOW  "\033[0;33m"
#define RESET   "\033[0m"

int main()
{
    char convert[] = "convert";
    int toConvert = 0xDEADBEEF;

    printf(RED "printfFunction:\n" RESET);
    printf("Hi, lets %% %s %% %d to HEX: 0x%x and to OCT: 0o%o - (%c)\n\n", convert, toConvert, toConvert, toConvert, 'Y');

    myPrintf(GREEN "My printf function:\n" RESET);
    myPrintf("Hello, %%world!%%%%KEKL%%\n");
    myPrintf("H%c M%c Fr%%%c%%end!\n", 'i', 'y', 'i');
    myPrintf("Hi, my name is '%s'\n", "mate!!!");
    myPrintf("%d in binary is %b\n", toConvert, toConvert);
    myPrintf("Hi, lets %%%s%% " GREEN "%d" RESET " to HEX: " YELLOW "0x%x" RESET " and to OCT: " RED "0o%o" RESET " - %b (%c)\n"
            "%d %s %x %d%%%c%b", 
            convert, toConvert, toConvert, toConvert, toConvert, 'Y',
            -1, "love", 3802, 100, 33, 15);

    return 0;
}
