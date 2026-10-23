`include "constants.vh"

module control_unit(
    input wire sys_clk_i,
    input wire sys_rstn_i,    

    output wire [15:0] address_bus_o);

/*
* ireg[0] -> current instruction
* ireg[1] -> next instruction
*/
reg [31:0] ireg [1:0]; 
reg [7:0] greg [15:0]; // gen purpose regs
reg [7:0] sreg; // status register
reg [15:0] pc; // tracks byte position in program 




endmodule