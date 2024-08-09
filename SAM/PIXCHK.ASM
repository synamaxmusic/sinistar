;;      INCLUDE "../SAM/START.ASM"

;===============================================================================
; EQUs to remove later
;CLTABLE        EQU     $5047   ;SAMTABLE
;===============================================================================

        PUSHORG ROMSAVE

;;      SUBTTL  PIXEL COLLISION CHECK

;* pixel collision check routine
        ROUTINE PIXCHK
        LDD     OBOTTOM,X       ;> uses A,B,U
        ORB     #$7F            ;find difference between bottoms (in pixels)
        SUBD    OBOTTOM,Y
        ASLB
        ROLA
        STA     TEMP
        LDB     RIGHT           ;find # pixels to check
        SUBB    OLEFT,X
        CMPB    ODWIDTH,X
        BLO     .1S
        LDB     ODWIDTH,X
.1S     STB     TEMP+1
        LDA     OLEFT,X         ;find difference between lefts
        SUBA    OLEFT,Y
        STX     SAVEXOB         ;find bottom collision table pointers
        LDU     OIDESC,X
        LDB     OSTATUS,X       ;left clipped?
        BPL     .2S
        LDB     OWIDTH,U
        SUBB    ODWIDTH,X
        LDX     OCOLTBL,U
        ABX
        BRA     .3S
.2S     LDX     OCOLTBL,U
.3S     STY     SAVEYOB
        LDU     OIDESC,Y
        LDB     OSTATUS,Y       ;left clipped?
        BPL     .4S
        LDB     OWIDTH,U
        SUBB    ODWIDTH,Y
        LDY     OCOLTBL,U
        LEAY    B,Y
        BRA     .5S
.4S     LDY     OCOLTBL,U
.5S     LEAY    A,Y             ;skip down Y object to be even with X obj's left
        LDA     Y               ;compare bottoms
        CMPY    #SINICLI        ;is Y object sinistar
        BLO     .11S
        EXG     X,Y             ;yes, compare with sinistar bottommost edge
        BSR     SINBOTT
        EXG     X,Y
        LDA     TEMP+2
.11S    SUBA    TEMP
        CMPX    #SINICLI        ;is X object sinistar
        BLO     .12S
        BSR     SINBOTT         ;yes, compare with sinistar bottommost edge
        CMPA    TEMP+2
        BRA     .13S
.12S    CMPA    X
.13S    BGT     .6S
        LDU     SAVEYOB         ;skip to Y object's top to check with X's bottom
        BRA     .7S
.6S     LDU     SAVEXOB         ;skip to X object's top to check with Y's bottom
        EXG     X,Y
        NEG     TEMP
.7S     LDD     [OIDESC,U]
        LEAY    B,Y
        LDB     TEMP+1
.8S     LDA     Y+              ;test loop
        SUBA    TEMP
        CMPA    X+
        BGT     .9S
        DECB
        BNE     .8S
        LDX     SAVEXOB         ;no collision
        LDY     SAVEYOB
        RTS
;* collision handling
.9S     LDX     SAVEXOB         ;compute collision matrix address
        LDU     OCHAR,X
        LDA     OCLTYPE,U
        STA     TEMP
        LDY     SAVEYOB
        LDU     OCHAR,Y
        LDA     OCLTYPE,U
        CMPA    TEMP
        BHS     .10S
        EXG     X,Y
        STA     TEMP
        LDU     OCHAR,Y
        LDA     OCLTYPE,U
.10S    LDB     OCLTYPE,U
        INCB
        MUL
        ADDD    #CLTABLE        ;offset into table
        TFR     D,U
        LDA     TEMP
        ASLA
        JSR     [A,U]           ;collision handling , save none, uses A,B,X,Y,U
        LDX     SAVEXOB         ;restore collision detect
        LDY     SAVEYOB
        RTS

;* find sinistar special bottommost edge
;*      pass collision table start in X, # pix in TEMP+1, returns in TEMP+2
SINBOTT PSHS    X               ;save collision table start > uses B
        LDB     TEMP+1          ;get number of lines
        ABX                     ;start at right
        LDB     #-1             ;use lowest value
.1S     CMPB    -X              ;test loop
        BLS     .2S
        LDB     X
.2S     CMPX    S               ;done?
        BHI     .1S
        STB     TEMP+2          ;save bottommost
        PULS    X,PC

        PULLORG ROMSAVE