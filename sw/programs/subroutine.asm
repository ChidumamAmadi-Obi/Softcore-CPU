;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CALL and RET test                      ;
; 0xF2 = 20  (10 doubled by subroutine)  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LI R0 10
CALL 0x00 0x0B

STR 0x00 0xF2 R0
HALT

;DOUBLE:
    ADD R0 R0 R0
    RET