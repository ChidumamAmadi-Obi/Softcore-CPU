`include "constants.vh"

module alu_tb;

logic clk = 1'b0;
logic rstn = 1'b0;
logic cen = 1'b0;
logic [7:0] opcode = 8'h00;
logic [7:0] operand_a = 8'h00;
logic [7:0] operand_b = 8'h00;
logic [7:0] result;
logic [2:0] flags;
logic valid;

alu alu_dut(
    .sys_clk_i(clk),
    .sys_rstn_i(rstn),
    .cen_i(cen),
    .opcode_i(opcode),
    .operand_a_i(operand_a),
    .operand_b_i(operand_b),
    .result_o(result),
    .alu_flags_o(flags),
    .valid_o(valid)); // output all alu flags

task init;
    $dumpfile("tb/wave/alu.vcd");
    $dumpvars(0,alu_tb);

    repeat (2) @(posedge clk); // wait 2 clk cycles
    rstn = 1;    
endtask

task testAlu;
input logic [7:0] sel;
input logic [7:0] a;
input logic [7:0] b;
// output logic [7:0] result;

    @(negedge clk);
        cen = 1'b0;
        opcode=sel;
        operand_a=a;
        operand_b=b;

    repeat (2) @(posedge clk); // wait 3 clk cycles
    #(1);
    // takes one clk cycle to output result

    $display("RESULTS 0x%04h, 0x%02h", alu_dut.full_result, result);
    $display("       z o c");
    $display("FLAGS: %b %b %b", flags[2], flags[1], flags[0]);
endtask

always #1 clk = ~clk;
initial begin 
    init;
    testAlu(OP_SUB, 8'hFE, 8'hFF);
    #(10);
    $finish;
end
endmodule

/*
0 1000 0000
0 0111 0000
0 1111 0000
*/