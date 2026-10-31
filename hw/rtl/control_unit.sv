`include "constants.svh"

module control_unit(
    input logic                 sys_clk_i,
    input logic                 sys_rstn_i,
    input logic                 en_i,
    input logic [`INST_LEN-1:0] instruction_i );

    always @* begin 
        if (en_i) begin 
            case (instruction_i[`DATA_LEN-1:0])
                OP_HALT: begin end
                OP_STR: begin end
                OP_LD: begin end
                OP_JMP: begin end
                OP_MOV: begin end
                OP_JMP_OFW: begin end
                OP_JMP_ZRO: begin end
                OP_JMP_NEG: begin end
                OP_JMP_ABV: begin end
                OP_ADD: begin end
                OP_SUB: begin end
                OP_MUL: begin end
                OP_AND: begin end
                OP_OR: begin end
                OP_XOR: begin end
                OP_EQU: begin end
                OP_DIV: begin end
                OP_LDI: begin end
                OP_ADDI: begin end
                OP_SUBI: begin end
                OP_MULI: begin end
                OP_ANDI: begin end
                OP_ORI: begin end
                OP_XORI: begin end
                OP_EQUI: begin end
                OP_DIVI: begin end
                OP_CALL: begin end
                OP_RET: begin end
                OP_NOP: begin end
                default: begin end
            endcase             
        end
    end
endmodule
