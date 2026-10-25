`include "constants.svh"

// insperation: https://github.com/devansh-lodha/verilog-tiny-processor/blob/main/register_file.v

module reg_file(
    input logic sys_clk_i,
    input logic sys_rstn_i,
    input logic we_i,
    input logic cen_i,
    input logic [3:0] reg_address,

    inout logic [7:0] data_io);

logic [7:0] register [`GP_REGS-1:0];
wire [7:0] register_out;

initial begin 
    for (integer i=0; i<`GP_REGS; i++) begin 
        register[i] = 8'h00;
    end
end

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i || !cen_i) begin 
        for (int i=0; i<`GP_REGS; i++) begin 
            register[i] <= 8'h00;
        end        
    end else if (we_i) begin 
        register[reg_address] <= data_io;
    end
end

assign register_out = !we_i ? register[reg_address] : 8'bz;
assign data_io = register_out;

endmodule
