`include "constants.svh"

module alu(
    input logic sys_clk_i,
    input logic sys_rstn_i,
    input logic cen_i,
    input opcode opcode_i,
    input logic [`DATA_LEN-1:0] operand_a_i,
    input logic [`DATA_LEN-1:0] operand_b_i,

    output logic [`DATA_LEN-1:0] result_o,
    output logic [3:0] alu_flags_o, // output all alu flags
    output logic valid_o);

logic [`FULL_RESULT_LEN-1:0] full_result;
logic [`DATA_LEN-1:0] a, b;
logic valid;
logic z_flag, o_flag, c_flag, n_flag;

wire is_add  = (opcode_i == OP_ADD) || (opcode_i == OP_ADDI);
wire is_sub  = (opcode_i == OP_SUB) || (opcode_i == OP_SUBI);
wire is_mul  = (opcode_i == OP_MUL) || (opcode_i == OP_MULI);
wire is_div  = (opcode_i == OP_DIV) || (opcode_i == OP_DIVI);
wire is_ari  = (is_add || is_sub || is_mul || is_div);

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i) begin 
        full_result     <= `FULL_RESULT_LEN'h0000;
        a               <= `DATA_LEN'h00;
        b               <= `DATA_LEN'h00;
        valid           <= 1'b0;
    end else if (cen_i) begin
        a <= operand_a_i;
        b <= operand_b_i;

        case(opcode_i)
            OP_ADD, OP_ADDI: begin full_result <= a + b;    valid <= 1'b1; end
            OP_SUB, OP_SUBI: begin full_result <= a - b;    valid <= 1'b1; end
            OP_MUL, OP_MULI: begin full_result <= a * b;    valid <= 1'b1; end
            OP_DIV, OP_DIVI: begin full_result <= a / b;    valid <= 1'b1; end // note: need to handle division by zero
    
            OP_AND, OP_ANDI: begin full_result <= a & b;    valid <= 1'b1; end
            OP_OR, OP_ORI:   begin full_result <= a | b;    valid <= 1'b1; end
            OP_XOR, OP_XORI: begin full_result <= a ^ b;    valid <= 1'b1; end
            OP_EQU, OP_EQUI: begin full_result <= a == b;   valid <= 1'b1; end
            default:         begin full_result <= `FULL_RESULT_LEN'h0000; valid <= 1'b0; end
        endcase
    end
end
assign z_flag   = full_result[`DATA_LEN-1:0] == `DATA_LEN'h00;
assign c_flag   = is_add || is_mul ? full_result > MAX_FULL_RES
                : is_sub           ? b > a
                : 1'b0; // no carry for division or logical ops
assign o_flag   = is_add  ? (a[`DATA_LEN-1] == b[`DATA_LEN-1] ) && (full_result[`DATA_LEN-1] != a[`DATA_LEN-1]) 
                : is_sub  ? (a[`DATA_LEN-1] != b[`DATA_LEN-1] ) && (full_result[`DATA_LEN-1] != a[`DATA_LEN-1]) 
                : is_mul  ? full_result > MAX_FULL_RES
                : 1'b0; // no overflow for division or logical ops
assign n_flag   = is_ari  ? full_result[`DATA_LEN-1] : 1'b0;

assign valid_o  = valid;
assign result_o = full_result[`DATA_LEN-1:0];
assign alu_flags_o = {z_flag, o_flag, c_flag, n_flag};

`ifndef SYNTHESIS
always_comb begin
    alu_flag_assert:
        assert (is_ari || (alu_flags_o[2:0] == 3'h0))
        else 
            $error("\033[33mARITHMETIC FLAGS NON-ZERO DURRING LOGICAL OPERATION\033[0m");    
end
`endif

endmodule