`include "constants.svh"

module no_bytes(
    input opcode        opcode_i,
    input  logic        cen_i,
    output logic [3:0]  no_bytes_o,
    output logic        rdy_o);
always @* begin 
    if (cen_i) begin 
        case(opcode_i)
            OP_ADD,  OP_SUB,  OP_MUL,  OP_AND,  
            OP_ADDI, OP_SUBI, OP_MULI, OP_ANDI, 
            OP_OR,  OP_XOR,  OP_EQU,  OP_DIV, 
            OP_ORI, OP_XORI, OP_EQUI, OP_DIVI,
            OP_STR, OP_LD: begin 
                no_bytes_o = 4'h4; 
                rdy_o = 1'b1;
            end

            OP_LDI, OP_MOV, OP_JMP, OP_JMP_ABV, 
            OP_JMP_NEG, OP_JMP_OFW, OP_JMP_ZRO, 
            OP_CALL: begin 
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
    input logic                  sys_clk_i,
    input logic                  sys_rstn_i,
    input logic                  mem_ack_i,
    inout logic  [`DATA_LEN-1:0] data_bus_io,
    output logic [`ADDR_LEN-1:0] address_bus_o,
    output logic                 mem_we_o,
    output logic                 mem_req_o);

logic [`DATA_LEN-1:0] ir [`MAX_INST_BYTES-1:0];
logic [`ADDR_LEN-1:0] pc, ninst;
logic [7:0]           sr; // status register
logic [`ADDR_LEN-1:0] address_bus_reg;
logic [`DATA_LEN-1:0] data_i, data_o;

// fetch signals
logic       inst_byte_en,  inst_byte_rdy;
logic [3:0] inst_byte_cnt, inst_byte_no;

// regfile signals
logic [3:0]           reg_file_address;
logic                 reg_file_cen, reg_file_we;
logic [`DATA_LEN-1:0] reg_file_data_buffer;
wire  [`DATA_LEN-1:0] reg_file_data;

// alu signals
logic [`DATA_LEN-1:0] alu_operand_a, alu_operand_b, alu_result;
logic [3:0]           alu_flags;
logic                 alu_cen, alu_valid;
logic [1:0]           alu_rdy;

fetch_states          fetch_state;
cpu_states            cpu_state;
alu_execute_states    alu_execute_state;

assign address_bus_o = address_bus_reg; 
assign data_i        = !mem_we_o ? data_bus_io : `DATA_LEN'bz;
assign data_bus_io   =  mem_we_o ? data_o      : `DATA_LEN'bz;

// cpu state machine 3 stages
always @(posedge sys_clk_i) begin 
    if (!sys_rstn_i) begin 
        for (int i=0; i<`MAX_INST_BYTES; i++) begin 
            ir[i]        <= `DATA_LEN'h00;
        end

        pc               <= `ADDR_LEN'h0;
        ninst            <= `ADDR_LEN'h0;
        address_bus_reg  <= `ADDR_LEN'h0;
        data_o           <= `DATA_LEN'h00;
        sr               <= 8'h80; // start with RUN_BIT set
        mem_we_o         <= 1'b0;
        mem_req_o        <= 1'b0;       

        inst_byte_cnt    <= 3'h0;
        inst_byte_en     <= 1'b0;

        reg_file_cen     <= 1'b0;
        reg_file_we      <= 1'b0;
        reg_file_address <= 4'H0;
        reg_file_data_buffer  <= `DATA_LEN'h00;

        alu_operand_a    <= `DATA_LEN'h00;
        alu_operand_b    <= `DATA_LEN'h00;
        alu_rdy          <= 2'h0;
        alu_cen          <= 1'b0;

        cpu_state         <= CPU_FETCH;
        fetch_state       <= F_IDLE;
        alu_execute_state <= ALU_EXEC_IDLE;
    end else begin 
        case(cpu_state)
            CPU_IDLE: begin 
            end
            CPU_FETCH: begin 
                case(fetch_state)
                    F_IDLE: begin 
                        reg_file_cen     <= 1'b0;
                        reg_file_we      <= 1'b0;
                        reg_file_address <= 4'H0;
                        reg_file_data_buffer  <= `DATA_LEN'h00;
                        data_o           <= `DATA_LEN'h00;

                        inst_byte_cnt    <= 4'h0;
                        inst_byte_en     <= 1'b0;
                        mem_we_o         <= 1'b0;
                        mem_req_o        <= 1'b0;

                        alu_execute_state <= ALU_EXEC_IDLE;
                        alu_operand_a    <= `DATA_LEN'h00;
                        alu_operand_b    <= `DATA_LEN'h00;
                        alu_rdy <= 2'h0;
                        alu_cen          <= 1'b0;
                        if (sr[RUN_BIT]) begin
                            fetch_state  <= F_SEND_ADDR;
                        end else begin
                            cpu_state    <= CPU_IDLE;
                            fetch_state  <= F_IDLE;
                        end               
                    end

                    F_SEND_ADDR: begin 
                        if (!inst_byte_en) begin 
                            address_bus_reg  <= pc;
                            mem_req_o        <= 1'b1;
                            fetch_state      <= F_GET_OPCODE;
                        end else if (!inst_byte_rdy) begin // invalid opcode
                            sr[RUN_BIT]      <= 1'b0;
                            inst_byte_en     <= 1'b0;
                            inst_byte_cnt    <= 4'h0;
                            mem_req_o        <= 1'b0;
                            fetch_state      <= F_IDLE;                        
                        end else if (inst_byte_cnt == inst_byte_no) begin // got last inst byte
                            mem_req_o        <= 1'b0;
                            fetch_state      <= F_DONE;
                        end else begin // get next inst byte
                            address_bus_reg  <= pc;
                            mem_req_o        <= 1'b1;
                            fetch_state      <= F_GET_OPERANDS;
                        end
                    end

                    F_GET_OPCODE: begin 
                        mem_req_o <= 1'b0;
                        if (mem_ack_i) begin 
                            inst_byte_en  <= 1'b1;
                            ir[OPCODE]         <= data_i;
                            inst_byte_cnt <= 4'h1;
                            pc            <= pc + 1;   
                            fetch_state   <= F_SEND_ADDR;                            
                        end else begin 
                            fetch_state   <= F_GET_OPCODE;
                        end

                    end

                    F_GET_OPERANDS: begin 
                        mem_req_o <= 1'b0;
                        if (mem_ack_i) begin 
                            ir[inst_byte_cnt] <= data_i;
                            inst_byte_cnt     <= inst_byte_cnt + 1;
                            pc                <= pc + 1;  
                            fetch_state       <= F_SEND_ADDR;                            
                        end else begin 
                            fetch_state   <= F_GET_OPERANDS;
                        end
                    end

                    F_DONE: begin 
                        inst_byte_cnt <= 4'h0;
                        inst_byte_en  <= 1'b0;
                        fetch_state   <= F_IDLE;
                        cpu_state     <= CPU_DECODE;
                    end

                    default: begin 
                        sr[RUN_BIT] <= 1'b0;
                        fetch_state <= F_IDLE; 
                    end
                endcase
            end

            CPU_DECODE: begin 
                case(ir[0])
                    OP_JMP,  OP_JMP_ABV, OP_JMP_NEG, 
                    OP_JMP_OFW, OP_JMP_ZRO, OP_CALL,  
                    OP_RET,  OP_NOP, OP_HALT: begin 
                        cpu_state <= CPU_EXECUTE; // skip to execute stage
                    end  

                    OP_ADDI, OP_SUBI, OP_MULI, OP_ANDI, 
                    OP_ADD,  OP_SUB,  OP_MUL,  OP_AND,  
                    OP_ORI, OP_XORI, OP_EQUI, OP_DIVI,
                    OP_OR,  OP_XOR,  OP_EQU,  OP_DIV: begin // get val from first src reg
                        reg_file_address <= ir[OPERAND_B];
                        reg_file_cen <= 1'b1;
                        reg_file_we <= 1'b0;
                        alu_execute_state <= ALU_EXEC_LOAD_FST_VAL;
                        cpu_state <= CPU_EXECUTE;
                    end

                    OP_LDI: begin 
                        reg_file_address <= ir[OPERAND_A];
                        reg_file_data_buffer <= ir[OPERAND_B];
                        reg_file_cen <= 1'b1;
                        reg_file_we <= 1'b1;
                        cpu_state <= CPU_EXECUTE; 
                    end
                    OP_LD: begin 
                        address_bus_reg <= {ir[OPERAND_B], ir[OPERAND_C]};
                        mem_req_o <= 1'b1;
                        mem_we_o <= 1'b0; // read
                        cpu_state <= CPU_EXECUTE; 
                    end
                    OP_MOV: begin 
                        reg_file_address <= ir[OPERAND_B];
                        reg_file_cen <= 1'b1;
                        reg_file_we <= 1'b0;
                        cpu_state <= CPU_EXECUTE;                         
                    end
                    OP_STR: begin 
                        reg_file_address <= ir[OPERAND_C];
                        reg_file_cen <= 1'b1;
                        reg_file_we <= 1'b0;
                        cpu_state <= CPU_EXECUTE; 
                    end

                    default: begin 
                        sr[RUN_BIT] <= 1'b0;
                        cpu_state   <= CPU_EXECUTE; // skip to next state for now
                    end
                endcase
            end
                
            CPU_EXECUTE: begin 
                case(ir[OPCODE])
                    OP_NOP: cpu_state <= CPU_FETCH; 
                    OP_HALT: begin 
                        for (int i=0; i<`MAX_INST_BYTES; i++) begin
                            ir[i]   <= `DATA_LEN'h00;
                        end    
                        sr[RUN_BIT] <= 1'b0;
                        cpu_state   <= CPU_IDLE; 
                    end
                    OP_JMP: begin 
                        pc <= {ir[OPERAND_A], ir[OPERAND_B]}; 
                        cpu_state <= CPU_FETCH;
                    end
                    OP_RET: begin 
                        pc <= ninst; 
                        cpu_state <= CPU_FETCH;
                    end
                    OP_JMP_ABV: begin 
                        pc <= (!sr[ZRO_BIT] && !sr[NEG_BIT]) ? {ir[OPERAND_B], ir[OPERAND_C]} : pc; 
                        cpu_state <= CPU_FETCH;
                    end
                    OP_JMP_NEG: begin 
                        pc <=   sr[NEG_BIT]                  ? {ir[OPERAND_B], ir[OPERAND_C]} : pc; 
                        cpu_state <= CPU_FETCH;
                    end
                    OP_JMP_OFW: begin 
                        pc <=   sr[OVF_BIT]                  ? {ir[OPERAND_B], ir[OPERAND_C]} : pc; 
                        cpu_state <= CPU_FETCH;
                    end
                    OP_JMP_ZRO: begin 
                        pc <=   sr[ZRO_BIT]                  ? {ir[OPERAND_B], ir[OPERAND_C]} : pc; 
                        cpu_state <= CPU_FETCH;
                    end
                    OP_CALL: begin 
                        ninst <= pc + 1; // save location of next inst after call
                        pc    <= {ir[OPERAND_B], ir[OPERAND_C]};
                        cpu_state <= CPU_FETCH;
                    end

                    OP_LDI: begin 
                        reg_file_cen <= 1'b0;
                        reg_file_we  <= 1'b0;
                        cpu_state    <= CPU_FETCH;
                    end
                    OP_LD: begin 
                        if (!mem_ack_i) begin 
                            cpu_state <= CPU_EXECUTE;
                        end else begin 
                            mem_req_o <= 1'b0;
                            reg_file_address <= ir[OPERAND_A];
                            reg_file_data_buffer <= data_i;
                            reg_file_cen <= 1'b1;
                            reg_file_we <= 1'b1;
                            cpu_state <= CPU_FETCH;
                        end
                    end
                    OP_MOV: begin 
                        reg_file_we          <= 1'b1;
                        reg_file_address     <= ir[OPERAND_A];
                        reg_file_data_buffer <= reg_file_data;
                        cpu_state            <= CPU_FETCH;   
                    end
                    OP_STR: begin 
                        if (reg_file_cen) begin // store reg data into mem
                            reg_file_cen    <= 1'b0;
                            data_o          <= reg_file_data;
                            mem_req_o       <= 1'b1;
                            mem_we_o        <= 1'b1;
                            address_bus_reg <= {ir[OPERAND_A], ir[OPERAND_B]};
                            cpu_state       <= CPU_EXECUTE;
                        end else if (!mem_ack_i) begin // wait for ack
                            cpu_state       <= CPU_EXECUTE;
                        end else begin 
                            mem_req_o       <= 1'b0;
                            mem_we_o        <= 1'b0;
                            cpu_state       <= CPU_FETCH;
                        end
                    end

                    OP_ADDI, OP_SUBI, OP_MULI, OP_ANDI,
                    OP_ORI, OP_XORI, OP_EQUI, OP_DIVI: begin 
                        case(alu_execute_state)
                            ALU_EXEC_IDLE: begin end
                            ALU_EXEC_LOAD_FST_VAL: begin
                                // here load src reg val and imm val into alu, then enable
                                alu_cen              <= 1'b1;
                                alu_operand_a        <= reg_file_data;
                                alu_operand_b        <= ir[OPERAND_C]; // operand b is last byte if inst
                                alu_execute_state    <= ALU_EXEC_WAIT;

                                reg_file_cen         <= 1'b0;
                                reg_file_we          <= 1'b0;
                                reg_file_address     <= 4'H0;
                                cpu_state            <= CPU_EXECUTE;
                            end
                            ALU_EXEC_WAIT: begin
                                if (alu_rdy != `ALU_LATENCY) begin 
                                    alu_execute_state <= ALU_EXEC_WAIT;
                                    cpu_state         <= CPU_EXECUTE;
                                    alu_rdy           <= alu_rdy + 1'b1;
                                end else begin 
                                    alu_execute_state <= ALU_EXEC_STORE;
                                    cpu_state         <= CPU_EXECUTE;
                                end
                            end
                            ALU_EXEC_STORE: begin 
                                reg_file_cen         <= 1'b1;
                                reg_file_address     <= ir[OPERAND_A];
                                reg_file_we          <= 1'b1;
                                reg_file_data_buffer <= alu_result;
                                sr[3:0]              <= alu_flags;
                                alu_execute_state    <= ALU_EXEC_IDLE;
                                cpu_state            <= CPU_FETCH;
                            end 
                            default: begin 
                                sr[RUN_BIT]          <= 1'b0;
                                alu_execute_state    <= ALU_EXEC_IDLE;
                                cpu_state            <= CPU_IDLE;
                            end
                        endcase
                    end

                    OP_ADD, OP_SUB, OP_MUL, OP_AND,
                    OP_OR, OP_XOR, OP_EQU, OP_DIV: begin 
                        case(alu_execute_state)
                            ALU_EXEC_IDLE: begin end
                            ALU_EXEC_LOAD_FST_VAL: begin
                                // here load first reg val...
                                alu_operand_a        <= reg_file_data;

                                reg_file_address     <= ir[OPERAND_C]; // load addr of next reg to get next operand
                                alu_execute_state    <= ALU_EXEC_LOAD_SEC_VAL;
                                cpu_state            <= CPU_EXECUTE;
                            end
                            ALU_EXEC_LOAD_SEC_VAL: begin
                                // here load second reg val and enable alu
                                alu_cen              <= 1'b1;
                                alu_operand_b        <= reg_file_data;

                                reg_file_cen         <= 1'b0;
                                reg_file_we          <= 1'b0;
                                reg_file_address     <= 4'H0;
                                alu_execute_state    <= ALU_EXEC_WAIT;
                                cpu_state            <= CPU_EXECUTE;
                            end                            
                            ALU_EXEC_WAIT: begin
                                if (alu_rdy != `ALU_LATENCY) begin 
                                    alu_execute_state <= ALU_EXEC_WAIT;
                                    cpu_state         <= CPU_EXECUTE;
                                    alu_rdy           <= alu_rdy + 1'b1;
                                end else begin 
                                    alu_execute_state <= ALU_EXEC_STORE;
                                    cpu_state         <= CPU_EXECUTE;
                                end
                            end
                            ALU_EXEC_STORE: begin 
                                reg_file_cen         <= 1'b1;
                                reg_file_address     <= ir[OPERAND_A];
                                reg_file_we          <= 1'b1;
                                reg_file_data_buffer <= alu_result;
                                sr[3:0]              <= alu_flags;
                                alu_execute_state    <= ALU_EXEC_IDLE;
                                cpu_state            <= CPU_FETCH;
                            end 
                            default: begin 
                                sr[RUN_BIT]          <= 1'b0;
                                alu_execute_state    <= ALU_EXEC_IDLE;
                                cpu_state            <= CPU_IDLE;
                            end
                        endcase
                    end

                    default: begin 
                        sr[RUN_BIT] <= 1'b0;
                        cpu_state   <= CPU_FETCH; 
                    end 
                endcase 
            end
            default:     begin 
                sr[RUN_BIT] <= 1'b0;
                cpu_state   <= CPU_IDLE; 
            end
        endcase
    end
end

no_bytes no_bytes_c(
    .opcode_i(opcode'(ir[OPCODE])),
    .cen_i(inst_byte_en),
    .no_bytes_o(inst_byte_no),
    .rdy_o(inst_byte_rdy));


assign reg_file_data = reg_file_we ? reg_file_data_buffer : `DATA_LEN'bz;
reg_file reg_file_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .we_i(reg_file_we),
    .cen_i(reg_file_cen),
    .reg_address_i(reg_file_address),
    .data_io(reg_file_data));
alu alu_io(
    .sys_clk_i(sys_clk_i),
    .sys_rstn_i(sys_rstn_i),
    .cen_i(alu_cen),
    .opcode_i(ir[OPCODE]),
    .operand_a_i(alu_operand_a),
    .operand_b_i(alu_operand_b),
    .result_o(alu_result),
    .alu_flags_o(alu_flags), // output all alu flags
    .valid_o(alu_valid));
endmodule
