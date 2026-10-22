
module top (
    input wire sys_clk_i,
    input wire sys_rstn_i
);

memory memory_i (
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .address_i(),
    .we_i(),
    .data_i(),
    .data_o(),
    .valid_o()
);
endmodule