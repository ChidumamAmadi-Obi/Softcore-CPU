; compute fib(8)


LI r0 0;
LI r1 1; 
LI r2 7; loop count (0-7 is 8 loops)
LI r3 0; result

LOOP: ; 
    ADD r3 r0 r1
    MOV r0 r1
    MOV r1 r3
    SUBI r2 r2 1;      decriment counter
    JMP_ZRO END;       if result is zero, jump to FINISH
    JMP LOOP;          jump to LOOP

END:
    STR 0x01 0x0E r3;       store result in RAM location 0x010E
    STR 0x04 0x01 r3;       store result in location 0x0401 (output_port[15:8])
    STR 0x04 0x02 r3;       store result in location 0x0402 (output_port[7:0])
    NOP
    HALT
