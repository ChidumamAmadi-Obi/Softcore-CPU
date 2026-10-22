
`timescale 1ns/1ps

`ifndef _CONSTANTS_
`define _CONSTANTS_

`ifndef SYNTHESIS
    `define RAM_0_FILE_PATH "rtl/bin/ram_0.hex" // Verilator 
    `define RAM_1_FILE_PATH "rtl/bin/ram_1.hex"
    `define RAM_2_FILE_PATH "rtl/bin/ram_2.hex"
    `define RAM_3_FILE_PATH "rtl/bin/ram_3.hex"
`else
    `define RAM_0_FILE_PATH "bin/ram_0.hex"  // Yosys
    `define RAM_1_FILE_PATH "bin/ram_1.hex"
    `define RAM_2_FILE_PATH "bin/ram_2.hex"
    `define RAM_3_FILE_PATH "bin/ram_3.hex"
`endif 

`endif