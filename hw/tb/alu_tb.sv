`include "constants.svh"
`include "utils_tb.svh"

typedef struct packed {
    logic [15:0] full_result;
    logic [7:0] result;
    logic [3:0] flags;
    logic valid;
} alu_results;

`define NUMBER_OF_TESTS 100

module alu_tb;

logic clk = 1'b0;
logic rstn = 1'b0;
logic cen = 1'b0;
opcode test_opcode = OP_HALT;
logic [7:0] operand_a = 8'h00;
logic [7:0] operand_b = 8'h00;
logic [7:0] result;
logic [3:0] flags;
logic valid;

alu_results expected, actual;

int test_no;
int no_errors;

alu alu_dut(
    .sys_clk_i(clk),
    .sys_rstn_i(rstn),
    .cen_i(cen),
    .opcode_i(test_opcode),
    .operand_a_i(operand_a),
    .operand_b_i(operand_b),
    .result_o(result),
    .alu_flags_o(flags),
    .valid_o(valid)); // output all alu flags

function automatic alu_results refAlu(
    input opcode sel,
    input logic [7:0] a,
    input logic [7:0] b );

    alu_results expected;
    integer is_add  = (sel == OP_ADD) || (sel == OP_ADDI);
    integer is_sub  = (sel == OP_SUB) || (sel == OP_SUBI);
    integer is_mul  = (sel == OP_MUL) || (sel == OP_MULI);
    integer is_div  = (sel == OP_DIV) || (sel == OP_DIVI);
    integer is_ari  = (is_add || is_sub || is_mul || is_div);

    case(sel)
        OP_ADD, OP_ADDI: begin expected.full_result = a + b;    expected.valid = 1'b1; end
        OP_SUB, OP_SUBI: begin expected.full_result = a - b;    expected.valid = 1'b1; end
        OP_MUL, OP_MULI: begin expected.full_result = a * b;    expected.valid = 1'b1; end
        OP_DIV, OP_DIVI: begin expected.full_result = a / b;    expected.valid = 1'b1; end

        OP_AND, OP_ANDI: begin expected.full_result = a & b;    expected.valid = 1'b1; end
        OP_OR, OP_ORI:   begin expected.full_result = a | b;    expected.valid = 1'b1; end
        OP_XOR, OP_XORI: begin expected.full_result = a ^ b;    expected.valid = 1'b1; end
        OP_EQU, OP_EQUI: begin expected.full_result = a == b;   expected.valid = 1'b1; end
        default:         begin expected.full_result = 16'h0000; expected.valid = 1'b0; end
    endcase

    expected.result     = expected.full_result[7:0];
    expected.flags[3]   = expected.result[7:0] == 8'h00;
    expected.flags[1]   = is_add || is_mul ? expected.full_result > 16'h00FF
                        : is_sub           ? b > a
                        : 1'b0; // no carry for division
    expected.flags[2]   = is_add  ? (a[7] == b[7] ) && (expected.full_result[7] != a[7]) 
                        : is_sub  ? (a[7] != b[7] ) && (expected.full_result[7] != a[7]) 
                        : is_mul  ? expected.full_result > 16'h00FF
                        : 1'b0; // no overflow for division    
    expected.flags[0]   = is_ari  ? expected.full_result[7] : 1'b0;
    return expected;
endfunction
function automatic string opcode2str(input opcode sel);
    case (sel)
        OP_ADD, OP_ADDI: return "ADD";
        OP_SUB, OP_SUBI: return "SUB";
        OP_MUL, OP_MULI: return "MUL";
        OP_DIV, OP_DIVI: return "DIV";

        OP_AND, OP_ANDI: return "AND";
        OP_OR, OP_ORI:   return "OR";
        OP_XOR, OP_XORI: return "XOR";
        OP_EQU, OP_EQUI: return "EQU";
        default:         return "'UNKNOWN'";
    endcase
    return "'UNKNOWN'";
endfunction

task init;
    $dumpfile("tb/wave/alu.vcd");
    $dumpvars(0,alu_tb);

    repeat (2) @(posedge clk); // wait 2 clk cycles
    rstn = 1;    
endtask

task driveAlu;
input opcode sel;
input logic [7:0] a;
input logic [7:0] b;
output alu_results results;

    @(negedge clk);
        cen = 1'b0;
        test_opcode=sel;
        operand_a=a;
        operand_b=b;

    repeat (2) @(posedge clk); // wait 2 clk cycles
    #(1);
    // takes one clk cycle to output result

    results.full_result = alu_dut.full_result;
    results.result = result;
    results.flags = {flags[3], flags[2], flags[1], flags[0]};
    results.valid = valid;
endtask

task testAlu;
ref int test_no;
ref int no_errors;

    logic [7:0] a, b;
    opcode sel;
    for (int i=0; i<`NUMBER_OF_TESTS+1; i++) begin 
        a=$urandom_range(MIN_OPERAND,MAX_OPERAND);
        b=$urandom_range(MIN_OPERAND,MAX_OPERAND);
        sel=opcode'($urandom_range(OP_ADD, OP_DIV));
        driveAlu(sel, a, b, actual);
        expected = refAlu(sel, a, b);
        if (expected != actual) begin 
            $display("\033[33m!!! [test: %0d] ALU OUTPUT MISMATCH: '%s' 0x%02h 0x%02h\033[0m at %0.1f", test_no, opcode2str(sel), a, b, $realtime);
            $display("         expected: 0x%04h 0x%02h z:%b o:%b c:%b n:%b valid:%b", expected.full_result, expected.result, expected.flags[3], expected.flags[2], expected.flags[1], expected.flags[0], expected.valid);
            $display("         actual  : 0x%04h 0x%02h z:%b o:%b c:%b n:%b valid:%b", actual.full_result,   actual.result,   actual.flags[3],   actual.flags[2],   actual.flags[1],   actual.flags[0],   actual.valid);
            no_errors++;
        end
        test_no++;
    end
endtask

always #1 clk = ~clk;
initial begin 
    init;
    testAlu(test_no,no_errors);

    if (no_errors) begin 
        $display("\033[31mFAILED: %0d/%0d\033[0m", no_errors,`NUMBER_OF_TESTS);
    end 

    passFail("ALU", no_errors);
    $finish;
end
endmodule
