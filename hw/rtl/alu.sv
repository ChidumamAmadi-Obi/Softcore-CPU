`include "constants.svh"

module alu(
    input wire sys_clk_i,
    input wire sys_rstn_i,
    input wire cen_i,
    input wire [7:0] opcode_i,
    input wire [7:0] operand_a_i,
    input wire [7:0] operand_b_i,

    output wire [7:0] result_o,
    output wire [3:0] alu_flags_o,
    output wire valid_o); // output all alu flags

reg [15:0] full_result;
reg [7:0] a, b;
reg valid;
wire z_flag, o_flag, c_flag, n_flag;

wire is_add  = (opcode_i == OP_ADD) || (opcode_i == OP_ADDI);
wire is_sub  = (opcode_i == OP_SUB) || (opcode_i == OP_SUBI);
wire is_mul  = (opcode_i == OP_MUL) || (opcode_i == OP_MULI);
wire is_div  = (opcode_i == OP_DIV) || (opcode_i == OP_DIVI);
wire is_ari  = (is_add || is_sub || is_mul || is_div);

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i || cen_i) begin 
        full_result     <= 16'h0000;
        a               <= 8'h00;
        b               <= 8'h00;
        valid           <= 1'b0;
    end else begin
        a <= operand_a_i;
        b <= operand_b_i;

        case(opcode_i)
            OP_ADD, OP_ADDI: begin full_result <= a + b;    valid <= 1'b1; end
            OP_SUB, OP_SUBI: begin full_result <= a - b;    valid <= 1'b1; end
            OP_MUL, OP_MULI: begin full_result <= a * b;    valid <= 1'b1; end
            OP_DIV, OP_DIVI: begin full_result <= a / b;    valid <= 1'b1; end
    
            OP_AND, OP_ANDI: begin full_result <= a & b;    valid <= 1'b1; end
            OP_OR, OP_ORI:   begin full_result <= a | b;    valid <= 1'b1; end
            OP_XOR, OP_XORI: begin full_result <= a ^ b;    valid <= 1'b1; end
            OP_EQU, OP_EQUI: begin full_result <= a == b;   valid <= 1'b1; end
            default:         begin full_result <= 16'h0000; valid <= 1'b0; end
        endcase
    end
end
assign z_flag   = full_result[7:0] == 8'h00;
assign c_flag   = is_add || is_mul ? full_result > 16'h00FF
                : is_sub           ? b > a
                : 1'b0; // no carry for division
assign o_flag   = is_add  ? (a[7] == b[7] ) && (full_result[7] != a) 
                : is_sub  ? (a[7] != b[7] ) && (full_result[7] != a) 
                : is_mul  ? full_result > 16'h00FF
                : 1'b0; // no overflow for division    
assign n_flag   = is_ari  ? full_result[7] : 1'b0;

assign valid_o  = valid;
assign result_o = full_result[7:0];
assign alu_flags_o = {z_flag, o_flag, c_flag, n_flag};
endmodule