
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

parameter logic [15:0] MAX_ADDR = 16'h0400;

parameter logic [7:0] OP_ADD    = 8'h09;
parameter logic [7:0] OP_SUB    = 8'h0A;
parameter logic [7:0] OP_MUL    = 8'h0B;
parameter logic [7:0] OP_AND    = 8'h0C;
parameter logic [7:0] OP_OR     = 8'h0D;
parameter logic [7:0] OP_XOR    = 8'h0E;
parameter logic [7:0] OP_EQU    = 8'h0F;
parameter logic [7:0] OP_DIV    = 8'h10;

parameter logic [7:0] OP_ADDI   = 8'h12;
parameter logic [7:0] OP_SUBI   = 8'h13;
parameter logic [7:0] OP_MULI   = 8'h14;
parameter logic [7:0] OP_ANDI   = 8'h15;
parameter logic [7:0] OP_ORI    = 8'h16;
parameter logic [7:0] OP_XORI   = 8'h17;
parameter logic [7:0] OP_EQUI   = 8'h18;
parameter logic [7:0] OP_DIVI   = 8'h19;

`endif