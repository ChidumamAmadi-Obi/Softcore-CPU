`include "constants.svh"

module no_bytes(
    input opcode opcode_i,
    input logic cen_i,
    output logic [3:0] no_bytes_o,
    output logic rdy_o);
always @* begin 
    if (cen_i) begin 
        case(opcode_i)
            OP_ADD,  OP_SUB,  OP_MUL,  OP_AND,  OP_OR,  OP_XOR,  OP_EQU,  OP_DIV,
            OP_ADDI, OP_SUBI, OP_MULI, OP_ANDI, OP_ORI, OP_XORI, OP_EQUI, OP_DIVI,
            OP_STR, OP_LD: begin 
                no_bytes_o = 4'h4; 
                rdy_o = 1'b1;
            end

            OP_LDI, OP_MOV, OP_JMP, OP_JMP_ABV, OP_JMP_NEG, OP_JMP_OFW, OP_JMP_ZRO, OP_CALL: begin 
                no_bytes_o = 4'h3;
                rdy_o = 1'b1;
            end

            OP_HALT, OP_RET, OP_NOP: begin 
                no_bytes_o = 4'h1;
                rdy_o = 1'b1;
            end

            default: begin 
                no_bytes_o = 4'h0; 
                rdy_o = 1'b0;
                end
        endcase            
    end else begin 
        no_bytes_o = 4'h0; 
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

logic [`DATA_LEN-1:0] ir [`MAX_INST_BYTES-1:0];
logic [`ADDR_LEN-1:0] pc;
logic [7:0] sr; // status register

logic [`ADDR_LEN-1:0] address_bus_reg;
logic [`DATA_LEN-1:0] data_i, data_o;

assign address_bus_o = address_bus_reg; 
assign data_i        = !mem_we_o ? data_bus_io : `DATA_LEN'bz;
assign data_o        =  mem_we_o ? data_bus_io : `DATA_LEN'bz;

// fetch signals
logic       inst_byte_en,  inst_byte_rdy;
logic [3:0] inst_byte_cnt, inst_byte_no;

fetch_states fetch_state;
cpu_states cpu_state;

// cpu state machine 3 stage
always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i) begin 
        for (int i=0; i<`MAX_INST_BYTES; i++) begin 
            ir[i] <= `DATA_LEN'h00;
        end
        pc               <= `ADDR_LEN'h0;
        address_bus_reg  <= `ADDR_LEN'h0;
        sr               <= 8'h80;
        inst_byte_cnt    <= 3'h0;
        inst_byte_en     <= 1'b0;
        mem_we_o         <= 1'b0;

        cpu_state        <= CPU_FETCH;
        fetch_state      <= F_IDLE;

    end else begin 
        case(cpu_state)
            CPU_NONE: begin end
            CPU_FETCH: begin 
                case(fetch_state)
                F_IDLE: begin 
                    inst_byte_cnt    <= 4'h0;
                    inst_byte_en     <= 1'b0;
                    mem_we_o         <= 1'b0;
                    if (sr[RUN_BIT]) begin
                        fetch_state <= F_SEND_ADDR;
                    end else begin
                        fetch_state <= F_IDLE;
                    end               
                end

                F_SEND_ADDR: begin 
                    if (!inst_byte_en) begin 
                        address_bus_reg <= pc;
                        fetch_state <= F_GET_OPCODE;
                    end else if (!inst_byte_rdy) begin // invalid opcode
                        sr[RUN_BIT]      <= 1'b0;
                        inst_byte_en     <= 1'b0;
                        inst_byte_cnt    <= 4'h0;
                        fetch_state <= F_IDLE;                        
                    end else if (inst_byte_cnt == inst_byte_no) begin // got last inst byte
                        fetch_state <= F_DONE;
                    end else begin // get next inst byte
                        address_bus_reg <= pc;
                        fetch_state <= F_GET_OPERANDS;
                    end
                end

                F_GET_OPCODE: begin 
                    inst_byte_en  <= 1'b1;
                    ir[0]         <= data_i;
                    inst_byte_cnt <= 4'h1;
                    pc            <= pc + 1;    
                    fetch_state <= F_SEND_ADDR;
                end

                F_GET_OPERANDS: begin 
                    ir[inst_byte_cnt] <= data_i;
                    inst_byte_cnt     <= inst_byte_cnt + 1;
                    pc                <= pc + 1;  
                    fetch_state <= F_SEND_ADDR;
                end

                F_DONE: begin 
                    inst_byte_cnt <= 4'h0;
                    inst_byte_en <= 1'b0;
                    fetch_state <= F_IDLE;
                    cpu_state <= CPU_DECODE;
                end

                default: begin 
                    fetch_state <= F_IDLE; 
                end
                endcase
            end
            CPU_DECODE:  begin cpu_state <= CPU_NONE; end
            CPU_EXECUTE: begin cpu_state <= CPU_NONE; end
            default: begin cpu_state <= CPU_NONE; end
        endcase
    end
end

no_bytes no_bytes_c(
    .opcode_i(opcode'(ir[0])),
    .cen_i(inst_byte_en),
    .no_bytes_o(inst_byte_no),
    .rdy_o(inst_byte_rdy));

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