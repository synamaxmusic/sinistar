;;      INCLUDE "../SAM/START.ASM"

;===============================================================================
; EQUs to remove later
;INVTBL EQU     $4E28   ;SAMTABLE
;QBOUNCE        EQU     $4DA9
;===============================================================================

        PUSHORG ROMSAVE

;;      SUBTTL  BOUNCE ROUTINE

;* bounce routine               ;pass ship wsa addresses in X and Y
        ROUTINE BOUNCE
        LDA     OSTATUS,X       ;if both object bounced then exit > uses A,B,U
        BITA    #3
        BEQ     .1S
        LDA     OSTATUS,Y
        BITA    #3
        LBNE    .8S
.1S     LDU     OCHAR,X         ;find masses
        LDA     OMASS,U
        STA     TEMP+2
        LDU     OCHAR,Y
        LDA     OMASS,U
        STA     TEMP+3
        ADDA    TEMP+2          ;find inverse of total mass
        BCC     .2S             ;scale down masses till sum is on inverse table
        RORA
        BRA     .3S
.2S     CMPA    #$20
        BLO     .4S
        LSRA
.3S     LSR     TEMP+2
        LSR     TEMP+3
        BRA     .2S
.4S     LDU     #INVTBL
        LEAU    A,U
        LDA     U               ;find portion of mass for both objects:
        LDB     TEMP+2
        BNE     .5S             ;is X object massless?
        LDD     OLVEL,Y         ;yes, make Y object center of momentum
        STD     TEMP+4
        LDD     OSVEL,Y
        BRA     .7S
.5S     MUL
        STB     TEMP+8
        LDA     U
        LDB     TEMP+3
        BNE     .6S             ;is Y object massless?
        LDD     OLVEL,X         ;yes, make X object center of momentum
        STD     TEMP+4
        LDD     OSVEL,X
        BRA     .7S
.6S     MUL
        STB     TEMP+9
        LDU     #TEMP+8         ;reverse velocitys rel to cen of momentum vel:
        LDD     OLVEL,X         ;compute x object, l axis momentum
        BSR     .9S
        STD     TEMP+4
        LDD     OSVEL,X         ;compute x object, s axis momentum
        BSR     .9S
        STD     TEMP+6
        LDU     #TEMP+9
        LDD     OLVEL,Y         ;compute y object, l axis momentum
        BSR     .9S
        ADDD    TEMP+4          ;add x object, l axis momentum
        STD     TEMP+4          ;save l axis center of momentum
        LDD     OSVEL,Y         ;compute y object, s axis momentum
        BSR     .9S
        ADDD    TEMP+6          ;add y object, s axis momentum
.7S     ASLB                    ;multiply s axis center of momentum * 2
        ROLA
        ADCB    #0
        ADCA    #0
        STD     TEMP+6
        SUBD    OSVEL,X         ;reverse x object, s axis velocity
        STD     OSVEL,X
        LDD     TEMP+6
        SUBD    OSVEL,Y         ;reverse y object, s axis velocity
        STD     OSVEL,Y
        LDD     TEMP+4          ;multiply l axis center of momentum * 2
        ASLB
        ROLA
        ADCB    #0
        ADCA    #0
        STD     TEMP+4
        SUBD    OLVEL,X         ;reverse x object, l axis velocity
        STD     OLVEL,X
        LDD     TEMP+4          ;reverse y object, l axis velocity
        SUBD    OLVEL,Y
        STD     OLVEL,Y
        TUNE    QBOUNCE         ;play bounce tune
.8S     LDA     OSTATUS,X       ;flag both object as bounced
        ORA     #2
        STA     OSTATUS,X
        LDA     OSTATUS,Y
        ORA     #2
        STA     OSTATUS,Y
        RTS
;* multiply subroutine  D <= (D*[U])/$100  (D signed word ,[U] unsigned byte)
.9S     STA     TEMP
        LDA     U
        MUL
        STA     TEMP+1
        LDA     U
        LDB     TEMP
        MUL
        BPL     .10S
        SUBA    U
.10S    ADDB    TEMP+1
        ADCA    #0
        RTS

        PULLORG ROMSAVE