
`ifndef _UTILS_TB_
`define _UTILS_TB_

`define TEST_RAM_0_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)
`define TEST_RAM_1_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)
`define TEST_RAM_2_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)
`define TEST_RAM_3_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)

`define HEX_DUMP_RAM_0_FILE_PATH "tb/hex_dump/ram_0.hex"
`define HEX_DUMP_RAM_1_FILE_PATH "tb/hex_dump/ram_1.hex"
`define HEX_DUMP_RAM_2_FILE_PATH "tb/hex_dump/ram_2.hex"
`define HEX_DUMP_RAM_3_FILE_PATH "tb/hex_dump/ram_3.hex"
`define HEX_DUMP_REG_FILE_PATH "tb/hex_dump/registers.hex"

`define SYS_CLK_FREQ_MHZ 27.0
`define FETCH_TEST_NO 250

function automatic void passFail(string module_name, int errors);
    if (errors) begin 
        $display("\033[31m  %s TEST FAILED\033[0m", module_name);
    end else begin 
        $display("\033[32m  %s TEST PASSED\033[0m", module_name);
    end
endfunction

`endif