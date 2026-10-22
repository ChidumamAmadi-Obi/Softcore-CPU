`include "constants.vh"

module memory_tb;

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
logic [15:0] test_address;
logic [7:0] written_data, read_data;
int rw_errors, loading_errors;

logic [7:0] test_ram_0 [255:0];
logic [7:0] test_ram_1 [255:0];
logic [7:0] test_ram_2 [255:0];
logic [7:0] test_ram_3 [255:0];

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
output logic [7:0] data;
    @(negedge clk);
    address = {bank,addr};
    we      = 1'b0;
    cen     = 1'b0;

    @(posedge clk);   // mem registers the read here
    #1;          

    data = data_out;     

    //$display("READ: 0x%02h, BANK: %d, ADDR: 0x%02h", data_out, bank, addr);
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

    //$display("WROTE: 0x%02h, BANK: %d, ADDR: 0x%02h", data, bank, addr);
endtask

always #1 clk = ~clk;
initial begin 
    init;

    written_data = 8'h00;
    read_data = 8'h00;
    rw_errors = 0;

    // verify program loading into BRAM works
    $readmemh(`RAM_0_FILE_PATH, test_ram_0);
    $readmemh(`RAM_1_FILE_PATH, test_ram_1);
    $readmemh(`RAM_2_FILE_PATH, test_ram_2);
    $readmemh(`RAM_3_FILE_PATH, test_ram_3);

    // test reading and writing to each bank
    for (test_address = 16'h0000; test_address < 16'h03FF; test_address++) begin 
        written_data = test_address[7:0];
        writeRam(
            test_address[15:8],
            test_address[7:0],
            test_address[7:0]);
        readRam(
            test_address[15:8],
            test_address[7:0],
            read_data);
        
        if (written_data != read_data) begin 
            $display("!!! READBACK ERROR, EXPECTED: 0x%02h READ: 0x%02h ADDR: 0x%04h at %f",
                written_data,
                read_data,
                test_address,
                $realtime);
            rw_errors++;
        end 
    end

    if (rw_errors) begin 
        $display("EXITED WITH %d READ/WRITE ERROR(S)", rw_errors);
    end else begin 
        $display("EXITED WITH NO READ/WRITE ERRORS");
    end
    $finish;
end
endmodule