## INSTRUCTION REFERENCE

| Instruction | Opcode |    Format   | Description |
|-------------|--------|-------------|-------------|
| HALT        | 0x00   | `HALT` | Ends Program |
| STR | 0x01 | `STR addr rs` | Store contents of register to memory |
| LD | 0x02 |`LD rd addr` | Load value from memory into register |
| JMP | 0x03 | `JMP addr` | Unconditional jump |
| MOV | 0x04 | `MOV rs1 rs2` | Copy contents of register rs2 into rs1 |
| JMP_OFW | 0x05 | `JMP_OFW addr` | Jump if overflow flag set |
| JMP_ZRO | 0x06 | `JMP_ZRO addr` | Jump if zero flag set |
| JMP_NEG | 0x07 | `JMP_NEG addr` | Jump if negative flag set |
| JMP_ABV | 0x08 | `JMP_ABV addr` | Jump if both negative and zero flags are NOT set |
| ADD | 0x09 | `ADD rd rs1 rs2` | Add two registers |
| SUB | 0x0A | `SUB rd rs1 rs2` | Subtract register 2 from 1 |
| MUL | 0x0B | `MUL rd rs1 rs2` | Multiply two registers |
| AND | 0x0C | `AND rd rs1 rs2` | Logically AND two registers |
| OR | 0x0D | `OR rd rs1 rs2` | Logically OR two registers |
| XOR | 0x0E | `XOR rd rs1 rs2` | Logically XOR two registers |
| EQU | 0x0F | `EQU rd rs1 rs2` | Compare two registers |
| DIV | 0x10 | `DIV rd rs1 rs2` | Divide rs1 by rs2 |
| LI | 0x11 |`LD rd val` | Load immediate value |
| ADDI | 0x12 | `ADDI rd rs1 val` | Add register with immediate value |
| SUBI | 0x13 | `SUBI rd rs1 val` | Subtract immediate value from register |
| MULI | 0x14 | `MULI rd rs1 val` | Multiply register with immediate value |
| ANDI | 0x15 | `ANDI rd rs1 val` | AND register with immediate value |
| ORI | 0x16 | `ORI rd rs1 val` | OR register with immediate value |
| XORI | 0x17 | `XORI rd rs1 val` | XOR register with immediate value |
| EQUI | 0x18 | `EQUI rd rs1 val` | Compare register with immediate value |
| DIVI | 0x19 | `DIVI rd rs1 val` | Divide register by immediate value |
| CALL | 0x1A | `CALL addr` | Record current value of PC and jump to start of subroutine |
| RET | 0x1B | `RET` | Return to address of CALL function |
| NOP | 0x1C | `NOP` | Do nothing for one cycle |
