
module memory (
    input wire sys_clk_i,
    input wire sys_rstn_i,
    input wire [15:0] address_i,
    input wire we_i, // write enable 
    input wire [7:0] data_i,
    output wire [7:0] data_o,
    output wire valid_o
    );

reg [7:0] ram_0 [255:0];
reg [7:0] ram_1 [255:0];
reg [7:0] ram_2 [255:0];
reg [7:0] ram_3 [255:0];

reg [7:0] ram_sel, ram_address, data_in, data_out;
reg valid;

initial begin 
    $readmemh("bin/ram_0",ram_0);
    $readmemh("bin/ram_1",ram_1);
    $readmemh("bin/ram_2",ram_2);
    $readmemh("bin/ram_3",ram_3);
end

always @(posedge sys_clk_i or negedge sys_rstn_i) begin 
    if (!sys_rstn_i) begin 
        ram_address <= 8'h00;
        ram_sel <= 8'h00;
        data_in <= 8'h00;
        data_out <= 8'h00;
        valid <= 1'b0;
    end else begin 
        ram_address <= address_i[7:0];
        ram_sel <= address_i[15:8];
        data_in <= data_i;

        if (we_i) begin 
            case (ram_sel)
                8'h01: begin 
                    ram_0[ram_address] <= data_in; 
                    valid <= 1'b1; 
                    end
                8'h02: begin 
                    ram_1[ram_address] <= data_in; 
                    valid <= 1'b1;
                    end
                8'h03: begin 
                    ram_2[ram_address] <= data_in; 
                    valid <= 1'b1; 
                    end
                8'h04: begin 
                    ram_3[ram_address] <= data_in; 
                    valid <= 1'b1; 
                    end
                default:  valid <= 1'b0;
            endcase
        end else begin 
            case (ram_sel)
                8'h01: begin 
                    data_out <= ram_0[ram_address]; 
                    valid <= 1'b1; 
                    end
                8'h02: begin 
                    data_out <= ram_1[ram_address]; 
                    valid <= 1'b1; 
                    end
                8'h03: begin 
                    data_out <= ram_2[ram_address]; 
                    valid <= 1'b1; 
                    end
                8'h04: begin 
                    data_out <= ram_3[ram_address]; 
                    valid <= 1'b1; 
                    end
                default:  valid <= 1'b0;
            endcase   
        end
    end
end
assign data_o = data_out;
endmodule