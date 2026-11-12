`include "constants.svh"
`include "utils_tb.svh"

`define FETCH_TEST_NO 250

localparam MAX_SIM_TIME = 5_000_000;  

module top_tb;

logic clk = 0;
logic rstn = 0;
logic [5:0] led_array;
logic [`OUT_PORT_LEN-1:0] output_port;

logic [`DATA_LEN-1:0] inst [`MAX_INST_BYTES-1:0];

int fetch_errors=0;
int test_program_errors=0;

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
    #(10);
endtask

task runProgram;
    wait (rstn);
    while (top_dut.cpu_io.sr[RUN_BIT]) #1;
    #(10);
endtask
task loadTestProgram;
input string prog;
    $readmemh(`TEST_RAM_0_FILE_PATH(prog), top_dut.memory_io.ram_0);
    $readmemh(`TEST_RAM_1_FILE_PATH(prog), top_dut.memory_io.ram_1);
    $readmemh(`TEST_RAM_2_FILE_PATH(prog), top_dut.memory_io.ram_2);
    $readmemh(`TEST_RAM_3_FILE_PATH(prog), top_dut.memory_io.ram_3);
endtask
task runTestProgram;
    input string prog;
    rst;
    loadTestProgram(prog);
    runProgram;

    case(prog) // check memory and outputs for correct data
        "factorial": begin 
            /*
            * EXPECTED:
            * !5 = 0x78 in reg1 
            * led_arr_o = 0x07
            */
            if (top_dut.cpu_io.reg_file_io.register[1] != 8'h78 ||
                led_array != 6'h07 || 
                top_dut.memory_io.ram_0[8'hFE] != 8'h78) begin 

                $display("\033[33m PRGM [%s] OUTPUT MISMATCH \033[0m", prog);
                $display("\033[33m      EXPECTED reg[1] = 0x%02h, ACTUAL reg[1] = 0x%02h \033[0m",
                    8'h78, top_dut.cpu_io.reg_file_io.register[1]);
                $display("\033[33m      EXPECTED led_arr_o = 0x%02h, ACTUAL led_arr_o = 0x%02h \033[0m",
                    6'h07, led_array);
                $display("\033[33m      EXPECTED ram_0[0xFE] = 0x%02h, ACTUAL ram_0[0xFE] = 0x%02h \033[0m",
                    8'h78, top_dut.memory_io.ram_0[8'hFE]);
                test_program_errors++;

            end            
        end
        "fibbonacci": begin 
            /*
            * EXPECTED:
            * fib(8) = 0x15
            * reg[0] = 0x0D
            * reg[1] = 0x15
            * reg[2] = 0x00
            * reg[3] = 0x15
            * output_port_o = 0x1515
            * ram_1[0x0E] = 0x15
            */
            if (top_dut.cpu_io.reg_file_io.register[0] != 8'h0D ||
                top_dut.cpu_io.reg_file_io.register[1] != 8'h15 ||
                top_dut.cpu_io.reg_file_io.register[2] != 8'h00 ||
                top_dut.cpu_io.reg_file_io.register[3] != 8'h15 ||
                output_port != 16'h1515 ||
                top_dut.memory_io.ram_1[8'h0E] != 8'h15) begin 

                $display("\033[33m PRGM [%s] OUTPUT MISMATCH \033[0m", prog);
                $display("\033[33m      EXPECTED reg[0] = 0x%02h, ACTUAL reg[0] = 0x%02h \033[0m",
                    8'h0D, top_dut.cpu_io.reg_file_io.register[0]);
                $display("\033[33m      EXPECTED reg[1] = 0x%02h, ACTUAL reg[1] = 0x%02h \033[0m",
                    8'h15, top_dut.cpu_io.reg_file_io.register[0]);
                $display("\033[33m      EXPECTED reg[2] = 0x%02h, ACTUAL reg[2] = 0x%02h \033[0m",
                    8'h00, top_dut.cpu_io.reg_file_io.register[0]);
                $display("\033[33m      EXPECTED reg[3] = 0x%02h, ACTUAL reg[3] = 0x%02h \033[0m",
                    8'h15, top_dut.cpu_io.reg_file_io.register[0]);

                $display("\033[33m      EXPECTED output_port = 0x%04h, ACTUAL output_port = 0x%04h \033[0m",
                    16'h1515, output_port);

                $display("\033[33m      EXPECTED ram_1[0x0E] = 0x%02h, ACTUAL ram_1[0x0E] = 0x%02h \033[0m",
                    8'h15, top_dut.memory_io.ram_0[8'h0E]);

                test_program_errors++;

            end                   
        end
        default: $display("INVALID TEST PROGAM...");
    endcase
endtask

always #1 clk = ~clk;

initial begin 
    wait ($time == MAX_SIM_TIME);
    $display("\033[33m[TIMEOUT] SIM EXEEDED %0d TIME UNITS...\033[0m", MAX_SIM_TIME);
    $display ("\033[33mPC: 0x%X SR: %b RUN_BIT: %d\033[0m", 
        top_dut.cpu_io.pc,
        top_dut.cpu_io.sr,
        top_dut.cpu_io.sr[RUN_BIT]);
    test_program_errors++;
    passFail("TOP", fetch_errors+test_program_errors);
    $finish;
end

initial begin 
    init;
    `ifdef SYS_TEST // runs test programs and checks for errors
        testCpuFetch;
        runTestProgram("factorial");
        runTestProgram("fibbonacci");

        if (fetch_errors) begin 
            $display("\033[31mFAILED FETCH TESTS: %0d/%0d\033[0m", fetch_errors,`FETCH_TEST_NO);
        end 
        if (test_program_errors) begin 
            $display("\033[31mFAILED PROGRAM %0d TESTS\033[0m", test_program_errors);
        end
    `else
        runProgram; // runs program in rtl/hex
    `endif  
    passFail("TOP", fetch_errors+test_program_errors);
    $finish;
end
endmodule