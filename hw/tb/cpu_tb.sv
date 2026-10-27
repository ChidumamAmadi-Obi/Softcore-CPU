`include "constants.svh"
`include "utils_tb.svh"

`define PRINT 0

module cpu_tb;

cpu cpu_dut(

);

task init;
    $dumpfile("tb/wave/cpu.vcd");
    $dumpvars(0,cpu_tb);

    repeat (2) @(posedge clk); // wait 2 clk cycles
    rstn = 1;    
endtask

initial begin 

    $finish;
end

endmodule