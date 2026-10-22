`include "constants.vh"

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

reg error_flag, zero_flag, ovf_flag, crry_flag;
reg [15:0] full_result;
reg [7:0] a, b;

always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i) begin 
        full_result     <= 16'h0000;
        a               <= 8'h00;
        b               <= 8'h00;
        error_flag      <= 1'b0;
        zero_flag       <= 1'b0;
        ovf_flag        <= 1'b0;
        crry_flag       <= 1'b0;
    end else if (cen_i) begin 
        full_result     <= 16'h0000;
        a               <= 8'h00;
        b               <= 8'h00;
        error_flag      <= 1'b0;
        zero_flag       <= 1'b0;
        ovf_flag        <= 1'b0;
        crry_flag       <= 1'b0;        
    end else begin
        a <= operand_a_i;
        b <= operand_b_i;

        case(opcode_i)
            // arithmetic operations
            OP_ADD, OP_ADDI: begin 
                full_result <= a + b;
                error_flag  <= 1'b0;
            end
            OP_SUB, OP_SUBI: begin 
                full_result <= a - b;
                error_flag  <= 1'b0;
            end
            OP_MUL, OP_MULI: begin 
                full_result <= a * b;
                error_flag  <= 1'b0;
            end
            OP_DIV, OP_DIVI: begin 
                full_result <= a / b;
                error_flag  <= 1'b0;
            end       

            // logica operations     
            OP_AND, OP_ANDI: begin 
                full_result <= a & b;
                error_flag  <= 1'b0;
            end
            OP_OR, OP_ORI:  begin      
                full_result <= a | b;
                error_flag  <= 1'b0;
            end
            OP_XOR, OP_XORI: begin 
                full_result <= a ^ b;  
                error_flag  <= 1'b0;    
            end
            OP_EQU, OP_EQUI: begin 
                full_result <= a == b;   
                error_flag  <= 1'b0;         
            end
            default: begin 
                full_result <= 16'h0000; 
                error_flag <= 1'b1;
            end 
        endcase

        zero_flag <= (full_result == 16'h0000);
        crry_flag <=  full_result[8];
        ovf_flag  <= (a[7] == b[7]) && (full_result[7] != a[7]) && 
                     (opcode_i == OP_ADD || opcode_i == OP_ADDI ||
                      opcode_i == OP_SUB || opcode_i == OP_SUBI);
    end
end

assign alu_flags_o = {error_flag, zero_flag, ovf_flag, crry_flag};
assign result_o    = full_result[7:0];
endmodule

/*
 10
 10
100
*/