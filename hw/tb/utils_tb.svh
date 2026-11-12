
`ifndef _UTILS_TB_
`define _UTILS_TB_

`define TEST_RAM_0_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)
`define TEST_RAM_1_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)
`define TEST_RAM_2_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)
`define TEST_RAM_3_FILE_PATH(prog) $sformatf("tb/test_programs/%s/ram_0.hex", prog)


function automatic void passFail(string module_name, int errors);
    if (errors) begin 
        $display("\033[31m  %s TEST FAILED\033[0m", module_name);
    end else begin 
        $display("\033[32m  %s TEST PASSED\033[0m", module_name);
    end
endfunction

`endif