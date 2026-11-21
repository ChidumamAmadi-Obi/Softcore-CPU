;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; COMPUTE !5 = 120 or 0x78 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LI r0 5; calculate 5!
LI r1 1; temp

LOOP:
    MUL r1 r1 r0;       multiply contents of r1 by r0
    SUBI r0 r0 1;       decriment contents of r0
    JMP_ZRO END;        if result is zero, end program
    JMP LOOP;           jump to LOOP

END:
    STR 0x00 0xFE r1;      store result in RAM location 0x00FE
    STR 0x04 0x00 r1;      store result in location 0x0400 (onboard LED peripheral)
    HALT



