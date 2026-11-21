;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CALL and RET test                      ;
; 0xF2 = 20  (10 doubled by subroutine) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LI RO 10
CALL DOUBLE

STR 0x00 0xF2 R0
HALT

DOUBLE:
    ADD R0 R0 R0
    RET