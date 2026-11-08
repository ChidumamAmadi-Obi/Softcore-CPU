`include "constants.svh"
`include "utils_tb.svh"

`define FETCH_TEST_NO 250

module top_tb;

logic clk = 0;
logic rstn = 0;
logic [5:0] led_array;
logic [`OUT_PORT_LEN-1:0] output_port;

logic [`DATA_LEN-1:0] inst [`MAX_INST_BYTES-1:0];

int fetch_errors=0;

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

task rst;
    rstn = 0;
    repeat (2) @(posedge clk); // wait 2 clk cycles
    rstn = 1;   
endtask 

task writeInst; // write one instruction at start of ram_0 
input logic [`DATA_LEN-1:0] inst [`MAX_INST_BYTES-1:0];
    top_dut.memory_io.ram_0[0] = inst[0];
    top_dut.memory_io.ram_0[1] = inst[1];
    top_dut.memory_io.ram_0[2] = inst[2];
    top_dut.memory_io.ram_0[3] = inst[3];
endtask
task genRndmInst; // output random instruction
output logic [`DATA_LEN-1:0] inst [`MAX_INST_BYTES-1:0];
    inst[0] = $urandom_range(OP_HALT, OP_NOP);
    case(inst[0])
        OP_ADD,  OP_SUB,  OP_MUL,  OP_AND,  
        OP_OR,  OP_XOR,  OP_EQU,  OP_DIV: begin
            inst[1] = $urandom_range(0,15);
            inst[2] = $urandom_range(0,15);
            inst[3] = $urandom_range(0,15);
        end

        OP_ADDI, OP_SUBI, OP_MULI, OP_ANDI, 
        OP_ORI, OP_XORI, OP_EQUI, OP_DIVI: begin
            inst[1] = $urandom_range(0,15);
            inst[2] = $urandom_range(0,15);
            inst[3] = $urandom_range(0,255);
        end

        OP_JMP, OP_JMP_ABV, OP_JMP_NEG,
        OP_JMP_OFW, OP_JMP_ZRO, OP_CALL: begin
            inst[1] = $urandom_range(0,3);
            inst[2] = $urandom_range(0,255);
            inst[3] = 8'h00;
        end

        OP_HALT, OP_RET, OP_NOP: begin
            inst[1] = 8'h00;
            inst[2] = 8'h00;
            inst[3] = 8'h00;
        end

        OP_LDI: begin
            inst[1] = $urandom_range(0,15);
            inst[2] = $urandom_range(0,255);
            inst[3] = 8'h00;
        end

        OP_STR: begin
            inst[1] = $urandom_range(0,3);
            inst[2] = $urandom_range(0,255);
            inst[3] = $urandom_range(0,15);
        end

        OP_LD: begin
            inst[1] = $urandom_range(0,15);
            inst[2] = $urandom_range(0,3);
            inst[3] = $urandom_range(0,255);
        end

        default: begin
            inst[1] = 8'h00;
            inst[2] = 8'h00;
            inst[3] = 8'h00;
        end
    endcase 
endtask 
task testCpuFetch; // fetch first instruction and compare with expected instruction
    logic [`DATA_LEN-1:0] expected_inst [`MAX_INST_BYTES-1:0];

    for (int i=0; i<`FETCH_TEST_NO; i++) begin 
        rst;
        genRndmInst(expected_inst);
        writeInst(expected_inst);

        @(top_dut.cpu_io.cpu_state == CPU_DECODE);

        if (top_dut.cpu_io.ir != expected_inst) begin 
            $display("\033[33m!!! [CPU FETCH ERROR] mismatch of expected vs fetched instruction: READ 0x%x%x%x%x, EXP 0x%x%x%x%x at %fns\033[0m", 
                top_dut.cpu_io.ir[0], 
                top_dut.cpu_io.ir[1], 
                top_dut.cpu_io.ir[2], 
                top_dut.cpu_io.ir[3], 
                
                expected_inst[0],
                expected_inst[1],
                expected_inst[2],
                expected_inst[3],
                $realtime );        
                fetch_errors++;    
        end        
    end
endtask

always #1 clk = ~clk;
initial begin 
    init;
    //testCpuFetch;

    #(250);

    if (fetch_errors) begin 
        $display("\033[31mFAILED FETCH TESTS: %0d/%0d\033[0m", fetch_errors,`FETCH_TEST_NO);
    end 

    passFail("TOP", fetch_errors);
    $finish;
end
endmodule