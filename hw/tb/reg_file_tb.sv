`include "constants.svh"
`include "utils_tb.svh"

`define PRINT 0
`define NUMBER_OF_TESTS 80 // read/write test to every reg N number of times

module reg_file_tb;

logic clk = 0;
logic rstn = 0;
logic we = 0;
logic cen = 0;
logic [3:0] reg_address = 4'h0;
wire [`DATA_LEN-1:0] data_inout;

int init_errors = 0;
int rw_errors = 0;

logic [`DATA_LEN-1:0] read_data  = `DATA_LEN'h0;
logic [`DATA_LEN-1:0] write_data = `DATA_LEN'h0;

logic [`DATA_LEN-1:0] tb_data_inout = `DATA_LEN'h0;
logic tb_data_oe = 1'b0;
assign data_inout = tb_data_oe ? tb_data_inout : `DATA_LEN'bz;

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

    if (`PRINT) $display("READ FROM REG: %d: 0x%02H", address, data_o);
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

    if (`PRINT) $display("WRITE TO REG: %d: 0x%02H", address, data_i);
endtask

always #1 clk = ~clk;
initial begin 
    init;

    // check that regs start out clear
    for (int reg_addr=4'h0; reg_addr<`GP_REGS; reg_addr++) begin 
        readReg(reg_addr, read_data);
        if (read_data) begin 
            $display("\033[33m!!! [reg: %0d] GP REG UNINITIALIZED, READ: 0x%02H at %f\033[0m",
            reg_addr, read_data, $realtime);
            init_errors++;            
        end
    end

    // rw tests
    for (int reg_addr=4'h0; reg_addr<`GP_REGS; reg_addr++) begin   
        for (int i=0; i<`NUMBER_OF_TESTS; i++) begin // read write tests
            write_data = $urandom_range(MIN_OPERAND,MAX_OPERAND);
            writeReg(reg_addr,write_data);
            readReg(reg_addr,read_data);
            if (write_data != read_data) begin 
                $display("\033[33m!!! [reg: %0d] GP REG READBACK ERROR, EXPECTED 0x%02H READ: 0x%02H at %f\033[0m",
                reg_addr, write_data, read_data, $realtime);
                rw_errors++;
            end
        end
    end
    if (rw_errors || init_errors) begin 
        $display("\033[31m  %0d RW ERRORS, %0d INIT ERRORS\033[0m", rw_errors, init_errors);
    end
    
    passFail("REGISTER FILE", (rw_errors || init_errors));
    $finish;
end

endmodule