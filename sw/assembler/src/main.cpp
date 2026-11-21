#include "debug.hpp"
#include "assembler.hpp"

int handleFilePaths(Assembler *assembler,int argc, char *argv[]);

int main(int argc, char *argv[]) { 
    Assembler assembler;
    int filePathErr = handleFilePaths(&assembler, argc, argv);

    if (filePathErr) return -1;

    assemble(&assembler);
    inspect(&assembler); // debug if needed
    printf("%d/%d BYTES\n",assembler.program.sizeOfProgam, (int)MAX_WORDS);
    return 0;
}

int handleFilePaths(Assembler *assembler,int argc, char *argv[]){
    if (argc > 1) {
        if (argc == 3) {
            printf("NOT ENOUGH ARGUMENTS\n");
            return -1;
        } else if (argc > 4) {
            printf("TOO MANY ARGUMENTS\n");
            return -1;
        } else {
            assembler->programHexDirectoryPath = argv[2];
            assembler->programInputFilePath = argv[3];
            assembler->programOutputFilePath = argv[1];
        }
        return 0;
    }   
    return 0;
}