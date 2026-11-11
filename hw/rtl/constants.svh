
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

// bit lengths andn widths
`define MEM_BANK_LEN 256
`define ADDR_LEN 16 // bit length of address
`define DATA_LEN 8  
`define FULL_RESULT_LEN 16
`define GP_REGS  16 // no of general purpose registers
`define INST_LEN 32
`define OUT_PORT_0_LEN 8
`define OUT_PORT_1_LEN 8
`define OUT_PORT_LEN 16

// other constants
`define MAX_INST_BYTES 4
`define MAX_NO_OPERANDS 3
`define ALU_LATENCY 2 // alu takes 2 clk cycles to execute

parameter MAX_FULL_RES = `FULL_RESULT_LEN'h00FF;
parameter MAX_OPERAND = `DATA_LEN'hFF;
parameter MIN_OPERAND = `DATA_LEN'h00;
parameter MAX_ADDR_MEM = `ADDR_LEN'h0400;

parameter MEM_CEN = 6'h00;
parameter PERIPH_CEN = 6'h01;

// status register bits
parameter RUN_BIT = 7;
parameter ERR_BIT = 6; // fatal error
parameter ZRO_BIT = 3;
parameter OVF_BIT = 2;
parameter CRY_BIT = 1;
parameter NEG_BIT = 0;

// instruction byte index
parameter OPECODE   = 0;
parameter OPERAND_A = 1;
parameter OPERAND_B = 2;
parameter OPERAND_C = 3;

// addresses for memory mapped peripherals
typedef enum logic [15:0] { 
    LED_ARRAY  = 16'h0400,
    OUT_PORT_0 = 16'h0401,
    OUT_PORT_1 = 16'h0402
} peripheral_address;

// control unit states
typedef enum logic [2:0] { 
    CPU_IDLE,
    CPU_FETCH,
    CPU_DECODE,
    CPU_EXECUTE
} cpu_states;

typedef enum logic [2:0] {
    F_IDLE,
    F_SEND_ADDR,
    F_GET_OPCODE,
    F_GET_OPERANDS,
    F_DONE
} fetch_states;

typedef enum logic [2:0] { 
    MEM_IDLE,
    MEM_READ,
    MEM_WRITE,
    MEM_ACK,
    MEM_ERR_ACK,
    MEM_WAIT_REQ_LOW
} mem_states;

typedef enum logic [2:0] {
    ALU_EXEC_IDLE,
    ALU_EXEC_LOAD_FST_VAL,
    ALU_EXEC_LOAD_SEC_VAL,
    ALU_EXEC_WAIT,
    ALU_EXEC_STORE,
    ALU_EXEC_END
} alu_execute_states;

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

typedef enum logic [3:0] {
    M_OP_STR
} micro_ops;
`endif