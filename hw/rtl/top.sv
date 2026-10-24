`include "constants.svh"

module top (
    input logic sys_clk_i,
    input logic sys_rstn_i,

    output logic [5:0] led_arr_o,
    output logic [15:0] output_port_o);

memory memory_i (
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .address_i(),
    .we_i(),
    .data_i(),
    .data_o(),
    .valid_o()
);

periphs periphs_o (
    .sys_clk_i(),
    .sys_rstn_i(),
    .address_bus_i(),
    .data_i(),
    .led_arr_o(led_arr_o),
    .port_0_o(output_port_o[7:0]),
    .port_1_o(output_port_o[15:8]));
endmodule