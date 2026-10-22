`include "constants.vh"

module top_tb;

logic clk, rstn;

top top_dut(
    .sys_clk_i(clk),
    .sys_rstn_i(sys_rstn_i));

always #1 clk = ~clk;
initial begin 
    $finish;
end
endmodule