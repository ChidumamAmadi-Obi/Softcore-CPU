`include "constants.svh"

module memory (
    input logic sys_clk_i,
    input logic sys_rstn_i,
    input logic [`ADDR_LEN-1:0] address_bus_i,
    input logic we_i, // write enable 
    input logic [`DATA_LEN-1:0] data_i,
    output logic [`DATA_LEN-1:0] data_o,
    output logic valid_o
    );

logic [`DATA_LEN-1:0] ram_0 [`MEM_BANK_LEN-1:0];
logic [`DATA_LEN-1:0] ram_1 [`MEM_BANK_LEN-1:0];
logic [`DATA_LEN-1:0] ram_2 [`MEM_BANK_LEN-1:0];
logic [`DATA_LEN-1:0] ram_3 [`MEM_BANK_LEN-1:0];

wire cen = (address_bus_i[`ADDR_LEN-1:10] == MEM_CEN) ? 1'b1 : 1'b0;
logic [`DATA_LEN-1:0] data_out;
logic valid;

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
    if (!sys_rstn_i || !cen) begin 
        valid       <= 1'h0;
        data_out    <= `DATA_LEN'h00;
    end else begin 
        if (we_i) begin // write
            case (address_bus_i[`ADDR_LEN-1:8])
                `DATA_LEN'h00: ram_0[address_bus_i[`DATA_LEN-1:0]] <= data_i;
                `DATA_LEN'h01: ram_1[address_bus_i[`DATA_LEN-1:0]] <= data_i;
                `DATA_LEN'h02: ram_2[address_bus_i[`DATA_LEN-1:0]] <= data_i;
                `DATA_LEN'h03: ram_3[address_bus_i[`DATA_LEN-1:0]] <= data_i;
                default: ;
            endcase
            valid <= 1'b0;
            data_out <= `DATA_LEN'h00;
        end else begin // read
            case (address_bus_i[`ADDR_LEN-1:8])
                8'h00: begin data_out <= ram_0[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; end
                8'h01: begin data_out <= ram_1[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; end
                8'h02: begin data_out <= ram_2[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; end
                8'h03: begin data_out <= ram_3[address_bus_i[`DATA_LEN-1:0]]; valid <= 1'b1; end
                default: begin data_out <= `DATA_LEN'h00; valid <= 1'b0; end
            endcase
        end        
    end
end
assign data_o = data_out;
assign valid_o = valid;
endmodule