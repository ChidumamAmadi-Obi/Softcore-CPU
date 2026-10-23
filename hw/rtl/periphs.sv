`include "constants.svh"

module periphs(
    input wire sys_clk_i,
    input wire sys_rstn_i,

    input wire [15:0] address_bus_i,
    input wire [7:0] data_i,

    output wire [5:0] led_arr_o,
    output wire [7:0] port_0_o,
    output wire [7:0] port_1_o);
    
    reg [5:0] led_array;
    reg [15:0] output_port;

    wire periph_wen = address_bus_i[10]; // 00000100 00000000
    wire [7:0] periph_address = address_bus_i[7:0];

    always @(posedge sys_clk_i) begin 
        if (!sys_rstn_i) begin 
            led_array <= 6'h00;
            output_port <= 16'h0000;      
        end else if (periph_wen) begin 
            case(periph_address)
                `LED_ARRAY:  led_array <= ~data_i[5:0];
                `OUT_PORT_0: output_port[7:0] <= data_i;
                `OUT_PORT_1: output_port[15:8] <= data_i;
                default: /* out of bounds memory access */ ;
            endcase
        end
    end
    
    assign port_0_o  = output_port[7:0];
    assign port_1_o  = output_port[15:8];
    assign led_arr_o = led_array;
endmodule