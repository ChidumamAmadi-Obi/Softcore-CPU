module memory_tb;

`timescale 1ns/1ps

// i/o signals
logic        clk = 0;
logic        rstn = 0;
logic [15:0] address = 16'h0000;
logic        we = 0;
logic        cen = 0;
logic [7:0]  data_in = 8'h00;
logic [7:0]  data_out;
logic        valid;

// test signals
logic [15:0] start_address;
logic [7:0] expected_data, actual_data;

memory memory_dut (
    .sys_clk_i(clk),
    .sys_rstn_i(rstn),
    .address_i(address),
    .we_i(we),
    .cen_i(cen),
    .data_i(data_in),
    .data_o(data_out),
    .valid_o(valid));

task init;
    $dumpfile("tb/wave/memory.vcd");
    $dumpvars(0,memory_tb);

    repeat (2) @(posedge clk); // wait 2 clk cycles
    rstn = 1;    
endtask

task readRam;
input logic [7:0] bank;
input logic [7:0] addr;
//output logic [7:0] data;
    @(negedge clk);
    address = {bank,addr};
    we      = 1'b0;
    cen     = 1'b0;

    @(posedge clk);   // mem registers the read here
    #1;               

    $display("READ: 0x%02h, BANK: %d, ADDR: 0x%02h", data_out, bank, addr);
endtask

task writeRam;
input logic [7:0] bank;
input logic [7:0] addr;
input logic [7:0] data;

    @(negedge clk);
    address = {bank,addr};
    data_in = data;
    we      = 1'b1;
    cen     = 1'b0;

    @(posedge clk);
    #1;               

    $display("WROTE: 0x%02h, BANK: %d, ADDR: 0x%02h", data, bank, addr);
endtask

always #1 clk = ~clk;
initial begin 
    init;
    readRam(8'h00,8'h00); // read from bank 0 addr 0
    writeRam(8'h00,8'h00,8'hAB);
    readRam(8'h00,8'h00);
    $finish;
end
endmodule