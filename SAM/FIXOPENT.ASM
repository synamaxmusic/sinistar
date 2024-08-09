;       INCLUDE START
;       INCLVER SAM,SINISTAR.EQU
FIXOPENT
        PUSHORG ROMSAVE

;* fixes operator entry
        PUSHORG $8995
        JSR     FIXOT100S                                       ;;($8E3D)
        PULLORG
FIXOT100S                                                       ;;Fixme was: 100$ (Needed to convert to global labels)
;* * *
        LDA     #98             ;set direct page
        TFR     A,DP
        CLR     NPLAYER         ;zeros number of players        ;;Fixme was: CLR  NPLAYERS
        JSR     INIPIAS         ;initialize pias
;* * *
        JMP     SYSTINI         ;Wipe clean thy slate, oh master

;* make pia initialization a subroutine
        PUSHORG $2E6E
        JMP     FXOT1S                                          ;;($8E49)
        PULLORG
FXOT1S  STB     BUNITS                                          ;;Fixme was: 1$
;* * *
        JSR     INIPIAS
;* * *
        LDA     PIA+6           ;initialize control panel state
        JMP     $2E90
INIPIAS EQU     $2E71
        PUSHORG $2E8D
        RTS
        PULLORG

        PULLORG ROMSAVE