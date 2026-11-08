`include "constants.svh"

module memory (
    input logic                  sys_clk_i,
    input logic                  sys_rstn_i,
    input logic                  req_i,
    input logic  [`ADDR_LEN-1:0] address_bus_i,
    input logic                  we_i, // write enable 
    input logic  [`DATA_LEN-1:0] data_i,
    output logic [`DATA_LEN-1:0] data_o,
    output logic                 ack_o,
    output logic                 err_ack_o,
    output logic                 valid_o
    );

logic [`DATA_LEN-1:0] ram_0 [`MEM_BANK_LEN-1:0];
logic [`DATA_LEN-1:0] ram_1 [`MEM_BANK_LEN-1:0];
logic [`DATA_LEN-1:0] ram_2 [`MEM_BANK_LEN-1:0];
logic [`DATA_LEN-1:0] ram_3 [`MEM_BANK_LEN-1:0];

logic [`DATA_LEN-1:0] data_out;
logic                 valid;
wire                  mem_cen;

mem_states            mem_state;

initial begin 
    for (int i=0; i<`MEM_BANK_LEN; i++) begin 
        ram_0[i] = `DATA_LEN'h00;
        ram_1[i] = `DATA_LEN'h00;
        ram_2[i] = `DATA_LEN'h00;
        ram_3[i] = `DATA_LEN'h00;
    end
    
    $readmemh(`RAM_0_FILE_PATH,ram_0);
    $readmemh(`RAM_1_FILE_PATH,ram_1);
    $readmemh(`RAM_2_FILE_PATH,ram_2);
    $readmemh(`RAM_3_FILE_PATH,ram_3);
end

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i || !mem_cen) begin 
        valid       <= 1'h0;
        data_out    <= `DATA_LEN'h00;
        ack_o       <= 1'b0;
        err_ack_o   <= 1'b0;
        mem_state   <= MEM_IDLE;
    end else if (mem_cen) begin 
        case (mem_state)
            MEM_IDLE: begin 
                ack_o     <= 1'b0;
                valid     <= 1'b0;
                err_ack_o <= 1'b0;
                if      (req_i &&  we_i) mem_state <= MEM_WRITE;
                else if (req_i && !we_i) mem_state <= MEM_READ;
                else                     mem_state <= MEM_IDLE;
                /** req ignored if not in IDLE **/
            end
            
            MEM_READ: begin 
                case (address_bus_i[`ADDR_LEN-1:8])
                    `DATA_LEN'h00: begin data_out <= ram_0[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; mem_state <= MEM_ACK; end
                    `DATA_LEN'h01: begin data_out <= ram_1[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; mem_state <= MEM_ACK; end
                    `DATA_LEN'h02: begin data_out <= ram_2[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; mem_state <= MEM_ACK; end
                    `DATA_LEN'h03: begin data_out <= ram_3[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; mem_state <= MEM_ACK; end
                    default:       begin data_out <= `DATA_LEN'h00; valid <= 1'b0; mem_state <= MEM_ERR_ACK; end
                endcase  
            end

            MEM_WRITE: begin 
                case (address_bus_i[`ADDR_LEN-1:8])
                    `DATA_LEN'h00: begin ram_0[address_bus_i[`DATA_LEN-1:0]] <= data_i; mem_state <= MEM_ACK; end 
                    `DATA_LEN'h01: begin ram_1[address_bus_i[`DATA_LEN-1:0]] <= data_i; mem_state <= MEM_ACK; end 
                    `DATA_LEN'h02: begin ram_2[address_bus_i[`DATA_LEN-1:0]] <= data_i; mem_state <= MEM_ACK; end 
                    `DATA_LEN'h03: begin ram_3[address_bus_i[`DATA_LEN-1:0]] <= data_i; mem_state <= MEM_ACK; end 
                    default: mem_state <= MEM_ERR_ACK;
                endcase
                data_out <= `DATA_LEN'h00;  
                valid <= 1'b0;
            end

            MEM_ACK: begin 
                ack_o <= 1'b1;
                mem_state <= req_i ? MEM_WAIT_REQ_LOW : MEM_IDLE;
            end

            MEM_ERR_ACK: begin 
                err_ack_o <= 1'b1;
                mem_state <= req_i ? MEM_WAIT_REQ_LOW : MEM_IDLE;
            end

            MEM_WAIT_REQ_LOW: begin 
                ack_o     <= 1'b0;
                err_ack_o <= 1'b0;
                valid     <= 1'b0;
                mem_state <= req_i ? MEM_WAIT_REQ_LOW : MEM_IDLE;
            end

            default: begin 
                valid     <= 1'h0;
                data_out  <= `DATA_LEN'h00;
                ack_o     <= 1'b0;   
                err_ack_o <= 1'b0;             
                mem_state <= MEM_IDLE; 
            end
        endcase
    end 
end
assign mem_cen = (address_bus_i[`ADDR_LEN-1:10] == MEM_CEN) ? 1'b1 : 1'b0;
assign data_o  = data_out;
assign valid_o = valid;
endmodule
