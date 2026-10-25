`include "constants.svh"

module top (
    input logic sys_clk_i,
    input logic sys_rstn_i,

    output logic [5:0] led_arr_o,
    output logic [`OUT_PORT_LEN-1:0] output_port_o);

/*
* cpu internal bus
*/
wire [`ADDR_LEN-1:0] address_bus_io;
wire [`DATA_LEN-1:0] data_bus_io;

/*
* memory control 
*/
wire mem_we_io;
wire mem_valid;
wire mem_data_bus_wen = (!mem_we_io && mem_valid && (address_bus_io[`ADDR_LEN-1:10] == MEM_CEN));
logic [`DATA_LEN-1:0] mem_data_i, mem_data_o;

assign data_bus_io = mem_data_bus_wen ? mem_data_o : `DATA_LEN'bz;

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i || !mem_we_io) begin 
        mem_data_i <= `DATA_LEN'h0;
    end else begin 
        mem_data_i <= data_bus_io;
    end
end

/*
* module connections
*/
cpu cpu_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .data_bus_io(data_bus_io),
    .address_bus_o(address_bus_io),
    .mem_we_o(mem_we_io)
);

memory memory_io (
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .address_bus_i(address_bus_io),
    .we_i(mem_we_io),
    .data_i(mem_data_i),
    .data_o(mem_data_o),
    .valid_o(mem_valid));

periphs periphs_o (
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .address_bus_i(address_bus_io),
    .data_i(data_bus_io),
    .led_arr_o(led_arr_o),
    .port_0_o(output_port_o[7:0]),
    .port_1_o(output_port_o[15:8]));
endmodule