Soft-Core CPU

A 8-bit soft-core CPU implemented in SystemVerilog with a custom ISA, complete with assembler, automated testing, and synthesis toolchain.

Features

    - Full RTL: ALU, register file (16 GP regs), control unit, 4×256-byte memory banks
    - Memory-mapped I/O: Onboard LEDs and output pins
    - Custom ISA: Shared with CPU emulator and assembler
    - Self-checking testbenches with automated regression testing
    - Makefile automation for assembling, simulating, synthesizing, and verifying

Example: Compute 5! = 120
```hex
11 00 05     // LI r0 5
11 01 01     // LI r1 1

// LOOP: (0x0006)
0B 01 01 00  // MUL r1 r1 r0
13 00 00 01  // SUBI r0 r0 1
06 00 14     // JMP_ZRO END
03 00 06     // JMP LOOP

// END: (0x0014)
01 00 FE 01  // STR 0x00FE r1  ; store result in RAM
01 04 00 01  // STR 0x0400 r1  ; store to LED peripheral
00           // HALT
```

Run it like this:
```bash
cd hw && make run-sim # runs default program
```

Simulates program running on CPU and outputs metrics
```log
SYS CLK FREQ:  27MHz
CPU CYCLES:    588
INST COUNT:    24
CPI:           24.500
CPU TIME:      21.778us
SIMULATION SUCCESSFUL
```

Quick Start
```make
# Root dir
make synth      # Synthesize with Yosys
make assemble   # Assemble ASM to hex (still wowrking on this)
make simulate   # Run simulation
make regression # Run all tests + error report in hw/logs
make run        # Assemble + simulate
```

Requirements

    - Verilator (simulation)
    - Yosys + slang plugin (synthesis)
    - G++ (assembler)