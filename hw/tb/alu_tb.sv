`include "constants.vh"

module alu_tb;

logic clk = 1'b0;
logic rstn = 1'b0;
logic [7:0] opcode = 8'h00;
logic [7:0] operand_a = 8'h00;
logic [7:0] operand_b = 8'h00;
logic [7:0] result;
logic [3:0] flags;
logic valid;

alu alu_dut(
    .sys_clk_i(clk),
    .sys_rstn_i(rstn),
    .opcode_i(opcode),
    .operand_a_i(operand_a),
    .operand_b_i(operand_b),
    .result_o(result),
    .alu_flags_o(flags),
    .valid_o(valid)); // output all alu flags

always #1 clk = ~clk;
initial begin 
    $finish;
end
endmodule