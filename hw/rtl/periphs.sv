`include "constants.svh"

module periphs(
    input logic sys_clk_i,
    input logic sys_rstn_i,

    input logic [`ADDR_LEN-1:0] address_bus_i,
    input logic [`DATA_LEN-1:0] data_i,

    output logic [5:0] led_arr_o,
    output logic [`OUT_PORT_0_LEN-1:0] port_0_o,
    output logic [`OUT_PORT_1_LEN-1:0] port_1_o);
    
    logic [5:0] led_array;
    logic [`OUT_PORT_LEN-1:0] output_port;

    wire periph_cen = (address_bus_i[`ADDR_LEN-1:10] == PERIPH_CEN) ? 1'b1 : 1'b0; // 00000100 00000000
    logic [7:0] periph_address = address_bus_i[7:0];

    always @(posedge sys_clk_i) begin 
        if (!sys_rstn_i) begin 
            led_array <= 6'h00;
            output_port <= `OUT_PORT_LEN'h0000;      
        end else if (periph_cen) begin 
            case(periph_address)
                LED_ARRAY:  led_array <= ~data_i[5:0];
                OUT_PORT_0: output_port[`OUT_PORT_0_LEN-1:0] <= data_i;
                OUT_PORT_1: output_port[`OUT_PORT_LEN-1:`OUT_PORT_0_LEN] <= data_i;
                default: /* out of bounds memory access */ ;
            endcase
        end
    end
    
    assign port_0_o  = output_port[`OUT_PORT_0_LEN-1:0];
    assign port_1_o  = output_port[`OUT_PORT_LEN-1:`OUT_PORT_0_LEN];
    assign led_arr_o = led_array;
endmodule