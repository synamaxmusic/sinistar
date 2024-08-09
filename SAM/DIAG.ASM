;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                                                             *
;*                                                                             *
;*          DDDD    IIIII    AAA     GGGG         V   V    11   77777          *
;*          D   D     I     A   A   G             V   V     1       7          *
;*          D   D     I     AAAAA   G GGG         V   V     1      7           *
;*          D   D     I     A   A   G   G          V V      1     7            *
;*          DDDD    IIIII   A   A    GGG            V     11111   7            *
;*                                                                             *
;*          S     I     N     I     S     T     A     R           17           *
;*                                                                             *
;*              A game by Sam Dicker, Noah Falstein and Rich Witt              *
;*               Copyright (c) 1983 by Williams Electronics Inc.               *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;       INCLUDE START

;       NLIST

;       INCLVER SAM,DIAG.SYM

;       LIST

CR_F    SET     0               ;no extra copyright             ;;Fixme was: CRF
ROM     SET     0               ;assemble at $F000
ROMSAVE SET     TSTORG

        INCLUDE "../SAM/T13.ASM"

;       END