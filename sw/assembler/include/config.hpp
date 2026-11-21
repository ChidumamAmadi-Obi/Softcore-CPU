#pragma once 

#include <fstream>
#include <sstream>
#include <unordered_map> 
#include <vector>
#include <iostream>
#include <cstdint>

#include <stdio.h>
#include <stdlib.h>

#include <ISA.h>

#define INVALID -1
#define UNDEFINED_LABEL -1
#define INVALID_LITERAL -999

#define DEFAULT_INPUT_FILE_PATH "program.asm"
#define DEFAULT_OUTPUT_FILE_PATH "program.bin"
#define DEFAULT_HEX_DIR_PATH "hex"

constexpr size_t BANK_SIZE = 256;
constexpr size_t NUM_BANKS = 4;
constexpr size_t MAX_WORDS = BANK_SIZE * NUM_BANKS;

using namespace std;

typedef enum{ // if error program should stop immediatly
    NONE,
    SYNTAX_ERROR,
    LOADING_PROGRAM_ERROR,
    NO_ASM_ERROR,
    EXPORTING_BINARY_ERROR,
    SYMBOL_ERROR,
    BIN_GEN_ERROR,
    PRGM_SIZE_ERROR
}ProgramErrors;

typedef struct{
    string rawAsm = "";
    string invalidToken="";
    string invalidLabel="";
    uint32_t sizeOfProgam=0; // size of program in bytes
    vector <string> tokens;
    vector <uint8_t> machineCode; // each token will take up 8 bytes
    unordered_map<string,int16_t> symbolTable; 
}Program;
typedef struct{
    Program program;
    ProgramErrors errorCode = NONE;
    string programInputFilePath = DEFAULT_INPUT_FILE_PATH;
    string programOutputFilePath = DEFAULT_OUTPUT_FILE_PATH;
    string programHexDirectoryPath = DEFAULT_HEX_DIR_PATH;
}Assembler;
typedef struct{
    unordered_map<string,Mnemonics> mnemonicMap = {
        {"STR", STR},
        {"LD", LD},
        {"JMP", JMP},
        {"MOV", MOV},
        {"HALT", HALT},
        {"JMP_OFW", JMP_OFW},
        {"JMP_ZRO", JMP_ZRO},
        {"JMP_NEG", JMP_NEG},
        {"JMP_ABV", JMP_ABV},
        {"ADD", ADD},
        {"SUB", SUB},
        {"MUL", MUL},
        {"AND", AND},
        {"OR", OR},
        {"XOR", XOR},
        {"EQU", EQU},
        {"DIV", DIV},
        {"LI",LI},
        {"ADDI",ADDI},
        {"SUBI",SUBI},
        {"MULI",MULI},
        {"ANDI",ANDI},
        {"ORI",ORI},
        {"XORI",XORI},
        {"EQUI",EQUI},
        {"DIVI",DIVI},
        {"CALL", CALL},
        {"RET", RET},
        {"NOP", NOP}};

    unordered_map<string,Registers> regMap = {
        {"r0", R0},
        {"r1",R1},
        {"r2",R2},
        {"r3",R3},
        {"r4",R4},
        {"r5",R5},
        {"r6",R6},
        {"r7",R7},
        {"r8",R8},
        {"r9",R9},
        {"r10",R10},
        {"r11",R11},
        {"r12",R12},
        {"r13",R13},
        {"r14",R14},
        {"r15",R15},
        {"*r0",PTR_R0},
        {"*r1",PTR_R1},
        {"*r2",PTR_R2},
        {"*r3",PTR_R3},
        {"*r4",PTR_R4},
        {"*r5",PTR_R5},
        {"*r6",PTR_R6},
        {"*r7",PTR_R7},
        {"*r8",PTR_R8},
        {"*r9",PTR_R9},
        {"*r10",PTR_R10},
        {"*r11",PTR_R11},
        {"*r12",PTR_R12},
        {"*r13",PTR_R13},
        {"*r14",PTR_R14},
        {"*r15",PTR_R15},
        {"R0", R0},
        {"R1",R1},
        {"R2",R2},
        {"R3",R3},
        {"R4",R4},
        {"R5",R5},
        {"R6",R6},
        {"R7",R7},
        {"R8",R8},
        {"R9",R9},
        {"R10",R10},
        {"R11",R11},
        {"R12",R12},
        {"R13",R13},
        {"R14",R14},
        {"R15",R15},
        {"*R0",PTR_R0},
        {"*R1",PTR_R1},
        {"*R2",PTR_R2},
        {"*R3",PTR_R3},
        {"*R4",PTR_R4},
        {"*R5",PTR_R5},
        {"*R6",PTR_R6},
        {"*R7",PTR_R7},
        {"*R8",PTR_R8},
        {"*R9",PTR_R9},
        {"*R10",PTR_R10},
        {"*R11",PTR_R11},
        {"*R12",PTR_R12},
        {"*R13",PTR_R13},
        {"*R14",PTR_R14},
        {"*R15",PTR_R15}
    };
}Maps;
