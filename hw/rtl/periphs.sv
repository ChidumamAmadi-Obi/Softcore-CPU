`include "constants.svh"

typedef enum logic [2:0] { 
    PERIPH_IDLE,
    PERIPH_WRITE,
    PERIPH_WAIT_REQ_LOW
} periph_states;

module periphs(
    input logic                        sys_clk_i,
    input logic                        sys_rstn_i,
    input logic                        req_i,
    input logic [`ADDR_LEN-1:0]        address_bus_i,
    input logic [`DATA_LEN-1:0]        data_i,

    output logic [5:0]                 led_arr_o,
    output logic [`OUT_PORT_0_LEN-1:0] port_0_o,
    output logic [`OUT_PORT_1_LEN-1:0] port_1_o,
    output logic ack_o,
    output logic err_ack_o);
    
    logic [`OUT_PORT_LEN-1:0] output_port;
    logic [7:0]               periph_address;
    logic [5:0]               led_array;
    wire                      periph_wen;

    periph_states periph_state;
    
    always @(posedge sys_clk_i) begin 
        if (!sys_rstn_i) begin 
            led_array   <= 6'h00;
            output_port <= `OUT_PORT_LEN'h0000;   
            ack_o <= 1'b0;
            err_ack_o <= 1'b0;   
        end else begin 
            case (periph_state)
                PERIPH_IDLE: begin 
                    ack_o <= 1'b0;
                    err_ack_o <= 1'b0;
                    if (req_i && periph_wen) periph_state <= PERIPH_WRITE;
                    else       periph_state <= PERIPH_IDLE;                  
                end

                PERIPH_WRITE: begin 
                    case(periph_address)
                        LED_ARRAY:  begin led_array                                    <= data_i[5:0]; ack_o <= 1'b1; end
                        OUT_PORT_0: begin output_port[`OUT_PORT_0_LEN-1:0]             <= data_i; ack_o <= 1'b1;  end
                        OUT_PORT_1: begin output_port[`OUT_PORT_LEN-1:`OUT_PORT_0_LEN] <= data_i; ack_o <= 1'b1;  end 
                        default: /* out of bounds memory access */  err_ack_o <= 1'b1; 
                    endcase    
                    periph_state <= req_i ? PERIPH_WAIT_REQ_LOW : PERIPH_IDLE;            
                end

                PERIPH_WAIT_REQ_LOW: begin 
                    periph_state <= req_i ? PERIPH_WAIT_REQ_LOW : PERIPH_IDLE; 
                end
                default: begin periph_state <= PERIPH_IDLE; end
            endcase 
        end
    end
    assign periph_wen     = (address_bus_i[`ADDR_LEN-1:10] == PERIPH_WEN) ? 1'b1 : 1'b0;
    assign periph_address = address_bus_i[7:0];
    assign port_0_o       = output_port[`OUT_PORT_0_LEN-1:0];
    assign port_1_o       = output_port[`OUT_PORT_LEN-1:`OUT_PORT_0_LEN];
    assign led_arr_o      = ~led_array; // invert because onboard leds are common anode
endmodule