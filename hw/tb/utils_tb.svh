
`ifndef _UTILS_TB_
`define _UTILS_TB_

function automatic void passFail(int errors);
    if (errors) begin 
        $display("\033[31mTEST FAILED\033[0m");
    end else begin 
        $display("\033[32mTEST PASSED\033[0m");
    end
endfunction

`endif