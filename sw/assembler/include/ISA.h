#pragma once

// both emulator and assembler share these enums

typedef enum{
    HALT,       // 0x00    
    STR,        // 0x01    
    LD,         // 0x02    
    JMP,        // 0x03    
    MOV,        // 0x04    
    JMP_OFW,    // 0x05    
    JMP_ZRO,    // 0x06    
    JMP_NEG,    // 0x07    
    JMP_ABV,    // 0x08    
    ADD,        // 0x09    
    SUB,        // 0x0A    
    MUL,        // 0x0B    
    AND,        // 0x0C    
    OR,         // 0x0D    
    XOR,        // 0x0E    
    EQU,        // 0x0F    
    DIV,        // 0x10    
    LI,         // 0x11    
    ADDI,       // 0x12    
    SUBI,       // 0x13    
    MULI,       // 0x14    
    ANDI,       // 0x15    
    ORI,        // 0x16    
    XORI,       // 0x17    
    EQUI,       // 0x18    
    DIVI,       // 0x19    
    CALL,       // 0x1A    
    RET,        // 0x1B    
    NOP         // 0x1C

}Mnemonics;
typedef enum{
    R0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
    PTR_R0,
    PTR_R1,
    PTR_R2,
    PTR_R3,
    PTR_R4,
    PTR_R5,
    PTR_R6,
    PTR_R7,
    PTR_R8,
    PTR_R9,
    PTR_R10,
    PTR_R11,
    PTR_R12,
    PTR_R13,
    PTR_R14,
    PTR_R15
}Registers;