
;       INCLUDE [SAM]START
;       INCLVER SAM,SINISTAR.EQU


        PUSHORG ROMSAVE



;* Here's the linker for the attract mode messages
        VECTOR  INIVECT         ;Hook into game start
        TST     AMDEMO          ;Test if this is game demo
        BEQ     .ATTM1S         ;  and skip if not              ;;Fixme was: BEQ  1$ (had to make global labels)

        NEW_SLEEP       TASK4,ATTMSG,OMTLEN+1   ;* Make attract message task
        NEW_SLEEP       TASK4,NATMSG,OMTLEN+1   ;* Make attract message task

.ATTM1S RTS                                                     ;;Fixme was: 1$   RTS

;* These are the messages displayed at the top of the screen
ATTMSG  JSR     PCLR2
        RADIX   10                                              ;;(decimal values ahead)
        LDA     #(60*10)/4                                      ;;Fixme was: LDA  #(60.*10.)/4
        RADIX   16                                              ;;(back to hex)
        STA     OMTLEN,Y
        SLEEP   HERE

        DEC     OMTLEN,Y        ;* Count off a frame
        BEQ     ATTM2S          ;*   of life for this task.
        PSHS    A,B,X,Y         ;* Save message registers
        TEXT    $6D,$4C
        PHRASE  YELLOW,35,BLAST,CRYSTALS,OFF,PLANETOIDS
        TEXT    $69,$20
        PHRASE  YELLOW,35,PICK,UP,CRYSTALS,TO,FILL,BOMBBAY,WITH,SINIBOMBS
        PULS    A,B,X,Y         ;* Restore message registers
        SLEEP   LOOP

ATTM2S  JSR     PCLR2                                           ;;Fixme was: 2$  JSR    PCLR2
        RADIX   10
        LDA     #(60*10)/4                                      ;;Fixme was: LDA  #(60.*10.)/4
        RADIX   16
        STA     OMTLEN,Y
        SLEEP   HERE

        DEC     OMTLEN,Y        ;* Count off a frame
        BEQ     ATTM3S          ;*   of life for this task.
        PSHS    A,B,X,Y         ;* Save message registers
        TEXT    $6D,$2A
        PHRASE  YELLOW,35,FIRING,DOES,NOT,AFFECT,THE,MIGHTY
        WORD    RED,35,SINISTAR
        TEXT    $69,$32
        PHRASE  YELLOW,35,ONLY,SINIBOMBS,CAN,AFFECT,THIS,NEMESIS
        PULS    A,B,X,Y         ;* Restore message registers
        SLEEP   LOOP

ATTM3S  JSR     PCLR2                                           ;;Fixme was: 3$  JSR    PCLR2
        RADIX   10
        LDA     #(60*13)/4                                      ;;Fixme was: LDA  #(60.*13.)/4
        RADIX   16
        STA     OMTLEN,Y
        SLEEP   HERE

        DEC     OMTLEN,Y        ;* Count off a frame
        BEQ     ATTM4S          ;*   of life for this task.
        PSHS    A,B,X,Y         ;* Save message registers
        TEXT    $6D,$27
        PHRASE  YELLOW,35,ONCE,THE
        WORD    RED,35,SINISTAR
        TEXT    $6D,$70
        PHRASE  YELLOW,35,IS,BUILT,YOU,MUST,DESTROY,IT
        TEXT    $69,$7C
        PHRASE  YELLOW,35,OR
        TEXT    $65,$5C
        PHRASE  YELLOW,35,YOU,HAD,BETTER
        WORD    RED,35,RUN
        PULS    A,B,X,Y         ;* Restore message registers
        SLEEP   LOOP

ATTM4S  JSR     PCLR2                                           ;;Fixme was: 4$  JSR    PCLR2
        JMP     DIE

;******************************************************************************
;* PCLR2
;*   A faster partial-screen clearer

PCLR2   PSHS    D
        LDD     #$0BFF!$404                                     ;;Fixme was: LDD  #$0BFF!X$404
        STD     DHIGH
        LDD     #$6500
        STD     DDEST
        CLR     DCONS
        LDA     #$11
        STA     DCTRL

        PULS    D,PC


;******************************************************************************
;* These are the messages displayed at the bottom of the screen
;*

NATMSG  CLR     OMTLEN,Y

        SLEEP   HERE

        PSHS    Y

        LDA     CREDIT
        CMPA    OMTLEN,Y
        BEQ     .NA100S
        STA     OMTLEN,Y

;*   A faster partial-screen clearer
        LDD     #$04FF!$404                                     ;;Fixme was: LDD  #$04FF!X$404
        STD     DHIGH
        LDD     #$1700
        STD     DDEST
        CLR     DCONS
        LDA     #$11
        STA     DCTRL

.NA100S LDX     #ALHSTD                                         ;;Fixme was: 100$  LDX  #ALHSTD
        JSR     RCMOSA
        BEQ     NA110S

        TEXT    $1C,$3E
        PHRASE  CREAM,35,PRESS,FIRE,BUTTON,TO,SEE,HIGH,SCORE

NA110S  LDA     CREDIT                                          ;;Fixme was: 110$  LDA  CREDIT
        BEQ     NA2S
        DECA
        BEQ     NA1S

        TEXT    $18,$52
        PHRASE  CREAM,35,PRESS,1,OR,2,PLAYER,START
        BRA     NA3S

NA1S    TEXT    $18,$5C                                         ;;Fixme was: 1$  TEXT   $18,$5C
        PHRASE  CREAM,35,PRESS,1,PLAYER,START
        BRA     NA3S

NA2S    TEXT    $18,$5E                                         ;;Fixme was: 2$  TEXT   $18,$5E
        PHRASE  CREAM,35,INSERT,COIN,TO,PLAY

NA3S    PULS    Y                                               ;;Fixme was: 3$  PULS   Y
        SLEEP   LOOP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers

        FDB     _BLAST
        FDB     _CRYSTALS
        FDB     _OFF
;       FDB     _PLANETOIDS

        FDB     _PICK
        FDB     _UP
;       FDB     _CRYSTALS
;       FDB     _TO
        FDB     _FILL
        FDB     _BOMBBAY
        FDB     _WITH
        FDB     _SINIBOMBS

        FDB     _FIRING
        FDB     _DOES
        FDB     _NOT
        FDB     _AFFECT
;       FDB     _THE
        FDB     _MIGHTY

        FDB     _ONLY
;       FDB     _SINIBOMBS
        FDB     _CAN
;       FDB     _AFFECT
        FDB     _THIS
        FDB     _NEMESIS

        FDB     _ONCE
;       FDB     _THE
;       FDB     _SINISTAR
;       FDB     _IS
        FDB     _BUILT
;       FDB     _YOU
        FDB     _MUST
        FDB     _DESTROY
        FDB     _IT

        FDB     _OR
;       FDB     _YOU
        FDB     _HAD
        FDB     _BETTER
        FDB     _RUN

        FDB     _PRESS
        FDB     _FIRE
        FDB     _BUTTON
;       FDB     _TO
        FDB     _SEE
        FDB     _HIGH
        FDB     _SCORE

;       FDB     _PRESS
;       FDB     _1
;       FDB     _OR
;       FDB     _2
;       FDB     _PLAYER
        FDB     _START

        FDB     _INSERT
        FDB     _COIN
;       FDB     _TO
        FDB     _PLAY

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        PULLORG ROMSAVE