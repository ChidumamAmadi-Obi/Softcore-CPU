`include "constants.vh"

module control_unit(
    input wire sys_clk_i,
    input wire sys_rstn_i,    
);

/*
* inst_reg[0] -> current instruction
* inst_reg[1] -> next instruction
*/
reg [31:0] inst_reg [1:0]; 
reg [7:0] gp_reg [15:0];
reg [15:0] pc; // tracks byte position in program 




endmodule