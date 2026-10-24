`include "constants.svh"

module reg_file(
    input logic sys_clk_i,
    input logic sys_rstn_i,
    input logic [1:0] we_i,
    input logic cen_i,
    input logic [3:0] reg_address,

    inout logic [15:0] data_io);

logic [7:0] register [`GP_REGS-1:0];

initial begin 
    for (int i=0; i<`GP_REGS; i++) begin 
        register[i] = 8'h00;
    end
end

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i || cen_i) begin 
        for (int i=0; i<`GP_REGS; i++) begin 
            register[i] <= 8'h00;
        end        
    end else begin 
        if (!we_i[1]) begin 
            register[reg_address] = we_i[0] ? data_io[7:0] : register[reg_address];
        end else if (reg_address+1 != 4'hE) begin 
            register[reg_address] = we_i[0] ? data_io[7:0] : register[reg_address];
            register[reg_address+1] = we_i[0] ? data_io[15:8] : register[reg_address];
        end
    end
end

wire [15:0] register_output = we_i == 2'b00 ? register[reg_address]
                            : we_i == 2'b01 ? {register[reg_address], register[reg_address+1]} 
                            : 16'h00;
assign data_io = register_output;

/*
when we_1[1] = 1, writing writes a 16 bit word to two registers at a time
when we_1[0] = 0, only one register is written to 8 bit word

therefore

when we[0] = 0, register[reg_address] == data_io[7:0] and register[reg_address] != (new)data[15:8]
and 
when we[0] = 1, register[reg_address] == data_io[7:0] and register[reg_address] == (new)data[15:8]
*/
endmodule
