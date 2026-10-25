
`timescale 1ns/1ps

`ifndef _CONSTANTS_
`define _CONSTANTS_

`ifndef SYNTHESIS
    `define RAM_0_FILE_PATH "rtl/hex/ram_0.hex" // Verilator 
    `define RAM_1_FILE_PATH "rtl/hex/ram_1.hex"
    `define RAM_2_FILE_PATH "rtl/hex/ram_2.hex"
    `define RAM_3_FILE_PATH "rtl/hex/ram_3.hex"
`else
    `define RAM_0_FILE_PATH "hex/ram_0.hex"  // Yosys
    `define RAM_1_FILE_PATH "hex/ram_1.hex"
    `define RAM_2_FILE_PATH "hex/ram_2.hex"
    `define RAM_3_FILE_PATH "hex/ram_3.hex"
`endif 

`define MEM_BANK_LEN 256

// bit lengths
`define ADDR_LEN 16 // bit length of address
`define DATA_LEN 8  
`define FULL_RESULT_LEN 16
`define GP_REGS  16 // no of general purpose registers
`define INST_LEN 32
`define OUT_PORT_0_LEN 8
`define OUT_PORT_1_LEN 8
`define OUT_PORT_LEN 16

parameter MAX_OPERAND = 8'hFF;
parameter MIN_OPERAND = 8'h00;
parameter MAX_ADDR_MEM = 16'h0400;

parameter MEM_CEN = 6'h00;
parameter PERIPH_CEN = 6'h01;

// addresses for memory mapped peripherals
typedef enum logic [15:0] { 
    LED_ARRAY  = 16'h0400,
    OUT_PORT_0 = 16'h0401,
    OUT_PORT_1 = 16'h0402
} peripheral_address;


// control unit states
typedef enum logic [2:0] { 
    NONE,
    FETCH,
    DECODE,
    EXECUTE
} cpu_states;

// ISA
typedef enum logic [7:0] { 
    OP_HALT,
    OP_STR,
    OP_LD,
    OP_JMP,
    OP_MOV,
    OP_JMP_OFW,
    OP_JMP_ZRO,
    OP_JMP_NEG,
    OP_JMP_ABV,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_AND,
    OP_OR,
    OP_XOR,
    OP_EQU,
    OP_DIV,
    OP_LDI,
    OP_ADDI,
    OP_SUBI,
    OP_MULI,
    OP_ANDI,
    OP_ORI,
    OP_XORI,
    OP_EQUI,
    OP_DIVI,
    OP_CALL,
    OP_RET,
    OP_NOP
} opcode;

`endif