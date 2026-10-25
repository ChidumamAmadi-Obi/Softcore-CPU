`include "constants.svh"

module cpu(
    input logic sys_clk_i,
    input logic sys_rstn_i);

reg_file reg_file_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .we_i(),
    .cen_i(),
    .reg_address(),
    .data_io());

alu alu_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .cen_i(),
    .opcode_i(),
    .operand_a_i(),
    .operand_b_i(),
    .result_o(),
    .alu_flags_o(), // output all alu flags
    .valid_o());
endmodule