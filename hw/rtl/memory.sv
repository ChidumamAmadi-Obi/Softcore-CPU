`include "constants.svh"

module memory (
    input wire sys_clk_i,
    input wire sys_rstn_i,
    input wire [15:0] address_i,
    input wire we_i, // write enable 
    input wire cen_i, // chip en (active low)
    input wire [7:0] data_i,
    output wire [7:0] data_o,
    output wire valid_o
    );

reg [7:0] ram_0 [255:0];
reg [7:0] ram_1 [255:0];
reg [7:0] ram_2 [255:0];
reg [7:0] ram_3 [255:0];

reg [7:0] data_out;
reg valid;

initial begin 
    $readmemh(`RAM_0_FILE_PATH,ram_0);
    $readmemh(`RAM_1_FILE_PATH,ram_1);
    $readmemh(`RAM_2_FILE_PATH,ram_2);
    $readmemh(`RAM_3_FILE_PATH,ram_3);
end

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i || cen_i) begin 
        valid       <= 1'h0;
        data_out    <= 8'h00;
    end else begin 
        if (we_i) begin // write
            case (address_i[15:8])
                8'h00: ram_0[address_i[7:0]] <= data_i;
                8'h01: ram_1[address_i[7:0]] <= data_i;
                8'h02: ram_2[address_i[7:0]] <= data_i;
                8'h03: ram_3[address_i[7:0]] <= data_i;
                default: ;
            endcase
            valid <= 1'b0;
        end else begin // read
            case (address_i[15:8])
                8'h00: begin data_out <= ram_0[address_i[7:0]]; valid <= 1'b1; end
                8'h01: begin data_out <= ram_1[address_i[7:0]]; valid <= 1'b1; end
                8'h02: begin data_out <= ram_2[address_i[7:0]]; valid <= 1'b1; end
                8'h03: begin data_out <= ram_3[address_i[7:0]]; valid <= 1'b1; end
                default: begin data_out <= 8'h00; valid <= 1'b0; end
            endcase
        end        
    end
end
assign data_o = data_out;
assign valid_o = valid;
endmodule