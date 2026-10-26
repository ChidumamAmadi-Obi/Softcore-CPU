`include "constants.svh"
`include "utils_tb.svh"

module reg_file_tb;

logic clk = 0;
logic rstn = 0;
logic we = 0;
logic cen = 0;
logic [3:0] reg_address = 4'h0;
wire [`DATA_LEN-1:0] data_inout;

logic [`DATA_LEN-1:0] tb_data_inout = `DATA_LEN'h0;
logic [`DATA_LEN-1:0] read_data = `DATA_LEN'h0;
logic tb_data_oe = 1'b0;

assign data_inout = tb_data_oe ? tb_data_inout : `DATA_LEN'bz;

int errors = 0;

reg_file reg_file_dut(
    .sys_clk_i(clk),
    .sys_rstn_i(rstn),
    .we_i(we),
    .cen_i(cen),
    .reg_address_i(reg_address),
    .data_io(data_inout));

task init;
    $dumpfile("tb/wave/reg_file.vcd");
    $dumpvars(0,reg_file_tb);

    repeat (2) @(posedge clk);
    rstn = 1'b1;
endtask

task readReg;
input logic [3:0] address;
output logic [`DATA_LEN-1:0] data_o;

    @(negedge clk);
    cen = 1'b1;
    we = 1'b0;    
    tb_data_oe = 1'b0;    
    reg_address = address;

    @(posedge clk);
    #1;

    data_o = data_inout;
    cen = 1'b0;

    $display("READ FROM REG: %d: 0x%02H", address, data_o);
endtask

task writeReg;
input logic [3:0] address;
input logic [`DATA_LEN-1:0] data_i;

    @(negedge clk);
    cen = 1'b1;
    we = 1'b1;    
    tb_data_oe = 1'b1;    
    reg_address = address;
    tb_data_inout = data_i;    
    
    @(posedge clk);
    #1;
    
    cen = 1'b0;
    tb_data_oe = 1'b0;  

    $display("WRITE TO REG: %d: 0x%02H", address, data_i);
endtask

always #1 clk = ~clk;
initial begin 
    init;
    writeReg(4'h8, 8'h55);
    writeReg(4'hA, 8'h66);
    readReg(4'h8, read_data);
    readReg(4'hA, read_data);

    passFail("REGISTER FILE", errors);
    $finish;
end

endmodule