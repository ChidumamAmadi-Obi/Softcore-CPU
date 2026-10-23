`include "constants.svh"

module top (
    input logic sys_clk_i,
    input logic sys_rstn_i
);

memory memory_i (
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .address_i(),
    .we_i(),
    .cen_i(),
    .data_i(),
    .data_o(),
    .valid_o()
);
endmodule