`include "constants.svh"

module top_tb;

logic clk = 0;
logic rstn = 0;
logic [5:0] led_array;
logic [`OUT_PORT_LEN-1:0] output_port;

top top_dut(
    .sys_clk_i(clk),
    .sys_rstn_i(rstn),
    .led_arr_o(led_array),
    .output_port_o(output_port));

task init;
    $dumpfile("tb/wave/top.vcd");
    $dumpvars(0,top_tb);

    repeat (2) @(posedge clk); // wait 2 clk cycles
    rstn = 1;    
endtask

always #1 clk = ~clk;
initial begin 
    init;
    #(50); // let clock tick away and look at regs through waveforms first
    /* NOTES
    first byte of program is read immediately but it stops there
    */
    $finish;
end
endmodule