;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                                                            *
;*                                                                            *
;*      BBBB    OOO   BBBB   ''   SSSS                V   V   11    77777     *
;*      B   B  O   O  B   B  ''  S                    V   V  1 1        7     *
;*      BBBB   O   O  BBBB    '   SSS                 V   V    1       7      *
;*      B   B  O   O  B   B          S                 V V     1      7       *
;*      BBBB    OOO   BBBB       SSSS                   V    11111    7       *
;*                                                                            *
;*          S     I     N     I     S     T     A     R           17          *
;*                                                                            *
;*       A game by Sam Dicker, Noah Falstein, Richard Witt and Bob Mical      *
;*               Copyright (c) 1983 by Williams Electronics Inc.              *
;*                                                                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;SINISTA        SET     *
;       INCLUDE [SAM]tSTART
;       INCLUDE "../SAM/START.ASM"

;*      NLIST

;LEVEL  SET     0

;       INCLVER BOB,BOBS.SYM
;       INCLVER BOB,BOBS.SET
;*      LIST

;       INCLVER BOB,B0
        INCLUDE "../MICA/B1.ASM"                ;<< TAKEN OUT ON SAM'S REQUEST 27 FEB 83 >>
        INCLUDE "../MICA/B2.ASM"

        ;ENDTEST
        ;END