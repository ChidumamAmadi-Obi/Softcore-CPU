
module top (
    input wire sys_clk,
    input wire sys_rstn,    
);

memory memory_ (
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .address_i(),
    .we_i(),
    .data_i(),
    .data_o());
endmodule