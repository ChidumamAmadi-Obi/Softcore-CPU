`include "constants.svh"

module no_bytes(
    input opcode opcode_i,
    input logic cen_i,
    output logic [2:0] no_bytes_o,
    output logic rdy_o);
always @* begin 
    if (cen_i) begin 
        case(opcode_i)
            OP_ADD,  OP_SUB,  OP_MUL,  OP_AND,  OP_OR,  OP_XOR,  OP_EQU,  OP_DIV,
            OP_ADDI, OP_SUBI, OP_MULI, OP_ANDI, OP_ORI, OP_XORI, OP_EQUI, OP_DIVI,
            OP_STR, OP_LD: begin 
                no_bytes_o = 3'h3; 
                rdy_o = 1'b1;
            end

            OP_JMP, OP_JMP_ABV, OP_JMP_NEG, OP_JMP_OFW, OP_JMP_ZRO: begin 
                no_bytes_o = 3'h1;
                rdy_o = 1'b1;
            end

            OP_LI, OP_MOV: begin 
                no_bytes_o = 3'h2;
                rdy_o = 1'b1;
            end

            OP_HALT, OP_RET, OP_NOP: begin 
                no_bytes_o = 3'h0;
                rdy_o = 1'b1;
            end

            default: begin 
                no_bytes_o = 3'h0; 
                rdy_o = 1'b0;
                end
        endcase            
    end else begin 
        no_bytes_o = 3'h0; 
        rdy_o = 1'b0;            
    end
end
endmodule

module cpu(
    input logic sys_clk_i,
    input logic sys_rstn_i,
    
    inout logic [`DATA_LEN-1:0] data_bus_io,
    output logic [`ADDR_LEN-1:0] address_bus_o,
    output logic mem_we_o);

logic [`INST_LEN-1:0] ir;
logic [`ADDR_LEN-1:0] pc;
logic [7:0] sr; // status register


cpu_states cpu_state, prev_cpu_state;

// cpu state machine 3 stage
always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i) begin 
        ir <= `INST_LEN'h0;
        pc <= `ADDR_LEN'h0;
        sr <= 8'h00;

        cpu_state <= FETCH;
        prev_cpu_state <= NONE;
    end else begin 
        case(cpu_state)
            NONE: begin end
            FETCH: begin end
            DECODE: begin end
            EXECUTE: begin end
            default: begin cpu_state <= NONE; end
        endcase
        prev_cpu_state <= cpu_state;
    end
end

reg_file reg_file_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .we_i(),
    .cen_i(),
    .reg_address_i(),
    .data_io());

alu alu_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .cen_i(),
    .opcode_i(),
    .operand_a_i(),
    .operand_b_i(),
    .result_o(),
    .alu_flags_o(), // output all alu flags
    .valid_o());
endmodule