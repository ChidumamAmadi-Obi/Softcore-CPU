`include "constants.svh"
`include "utils_tb.svh"

module reg_file_tb;

logic clk = 1'b0;
logic rstn = 1'b0;
logic we = 1'b0;
logic cen = 1'b0;
logic reg_address = 4'b0;
logic [`DATA_LEN-1:0] data_inout = `DATA_LEN'b0;

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
endtask
task writeReg;
endtask

always #1 clk = ~clk;
initial begin 
    init;

    passFail("REGISTER FILE", errors);
    $finish;
end

endmodule