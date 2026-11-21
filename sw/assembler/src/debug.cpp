
#include "debug.hpp"

void inspectErrors(Assembler *assembler){ // list errors if any
    if (assembler->errorCode == NONE) {
        COLOR_BOLD_GREEN; printf("\n\nPROGRAM EXITED WITH ZERO ERRORS :]\n"); COLOR_RESET;
        return;
    }
    COLOR_BOLD_RED; printf("\n\nPROGRAM EXITED WITH ERROR CODE: %d\n", assembler->errorCode); COLOR_RED;
    switch(assembler->errorCode) {
        case NO_ASM_ERROR: printf("ERROR NO ASM IN FILE"); break;
        case LOADING_PROGRAM_ERROR: printf("ERROR LOADING PROGRAM FILE\n"); break;
        case EXPORTING_BINARY_ERROR: printf("ERROR EXPORTING BINARY FILE\n"); break;
        case SYNTAX_ERROR: printf("SYNTAX ERROR, '%s' IS AN INVALID TOKEN\n",assembler->program.invalidToken.c_str()); break;
        case SYMBOL_ERROR: printf("SYMBOL TABLE ERROR, LABEL '%s' IS UNDEFINED\n",assembler->program.invalidLabel.c_str()); break;
        case BIN_GEN_ERROR: printf("ERROR GENERATING BINARY FILE\n"); break;
        case PRGM_SIZE_ERROR: printf("PROGRAM SIZE TOO LARGE, %d/%d\n", assembler->program.sizeOfProgam, (int)(MAX_WORDS)); break;
        default: break;
    }
    COLOR_RESET; 
}
void inspectSymbolTable(Assembler *assembler){ // list all labels
    if (assembler->program.symbolTable.empty()) {
       COLOR_YELLOW; printf("\n===========SYMBOL TABLE EMPTY============"); COLOR_RESET;
    } else {
        COLOR_YELLOW; printf("\n==============SYMBOL TABLE==============\n"); COLOR_RESET;
        for (auto i : assembler->program.symbolTable){
            COLOR_BOLD_WHITE; printf(" LABEL:"); COLOR_RESET;
            printf(" '%s' -> ",i.first.c_str());
            COLOR_BOLD_WHITE; printf("LOCATION:"); COLOR_RESET;
            printf(" %d\n", i.second);
        } 
        COLOR_YELLOW; printf("========================================"); COLOR_RESET;
    } 
}
void inspectBinary(Assembler *assembler){ // print binary output in hex
    if (assembler->program.machineCode.empty()){
        COLOR_RED; printf("\n===========NO BINARY GENERATED==========="); COLOR_RESET;
    } else {
        COLOR_YELLOW; printf("\n==============BINARY OUTPUT=============\n"); COLOR_RESET;
        for (int i=0; i<assembler->program.machineCode.size(); i++){
            printf(" 0x%02X",assembler->program.machineCode[i]);
            if ((i+1)%8 == 0) printf("\n");
        }
        COLOR_YELLOW;
        printf("\n========================================");
        COLOR_RESET;
    } 
}

void inspect(Assembler *assembler) {
    #ifdef SHOW_SYMBOL_TABLE
        inspectSymbolTable(assembler);
    #endif

    #ifdef SHOW_GENERATED_BINARY
        inspectBinary(assembler); 
    #endif
    
    #ifdef SHOW_ERRORS
        inspectErrors(assembler); 
    #endif
}
