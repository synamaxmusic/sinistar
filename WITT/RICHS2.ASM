;       NCLIST                  * Do not display unsatisfied conditionals
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                                                            *
;*                                                                            *
;*      RRRR   IIIII   CCCC  H   H  ''   SSSS    P    V   V   11    77777     *
;*      R   R    I    C      H   H  ''  S        a    V   V    1       7      *
;*      RRRR     I    C      HHHHH   '   SSS     r    V   V    1      7       *
;*      R   R    I    C      H   H          S    t     V V     1     7        *
;*      R   R  IIIII   CCCC  H   H      SSSS     2      V    11111  7         *
;*                                                                            *
;*          S     I     N     I     S     T     A     R           17          *
;*                                                                            *
;*       A game by Sam Dicker, Noah Falstein, Bob Mical and Richard Witt      *
;*               Copyright (c) 1982 by Williams Electronics Inc.              *
;*                                                                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;       NLIST
;SINISTAR.EQU   SET     *
;       INCLUDE START
;       INCLVER RICH,RICHS2.SYM
;       INCLVER RICH,RICHS2.SET
;       INCLVER RICH,SYMCHK             ;* Symbol extraction macro

;       SYMCHK  BombsAway
;       SYMCHK  Empty
;       SYMCHK  NotEmpty

;       LIST                            ;* Part 2 source files:
        INCLUDE "../WITT/BUTTON.ASM"

;       ENDTEST
;       END