;*****
;*
;* WORK UTILITIES
;*
;*****
        IFDEF   GRAPHTEST       ;*****************************************
;       IFE     VERSION-9                                               ;*
;       ENDIF   VERSION                                                 ;*
        INCLUDE "../WITT/RICH.EQU"                                              ;;We need Rich's work EQUs
GRAFORG SET     $F09F                                                           ;;Overwrite the ROM/RAM test
        INCLUDE "../SAM/bargraph.ASM"           ;* <<< Bar Graphs >>>    *
        PUSHORG Palette                                                 ;*
        fcb     @067,@377,@277,@256,@255,@244,@232,@067                 ;*
        fcb     @377,@311,@120,@113,@005,@007,@007,@067                 ;*
        PULLORG
;*                                                                      ;*
        PUSHORG RAMSAV                                                  ;*      ;;Fixme was: PUSHORG    RAMSAVE
JUNKTIME        rmb     2                                               ;*
        PULLORG RAMSAV                                                  ;*      ;;Fixme was: PULLORG    RAMSAVE
;*                                                                      ;*
;;;;;;  PUSHORG ROMSAVE
        pushorg GRAFORG
;       LOCAL                                                           ;*
        VECTOR  IniVect                                                 ;*
        clr     JUNKTIME                                                ;*
        clr     JUNKTIME+1                                              ;*
        New_Sleep       Task64,.JUNK1S                                  ;*      ;;Fixme was: New_Sleep  Task64,1$
        rts                                                             ;*
;**                                                                     ;*
;*      Time clock                                                      ;*
;**                                                                     ;*
.JUNK1S pshs    D,X,U                                                   ;*      ;;Fixme was: 1$ pshs    D,X,U
        ldd     JUNKTIME                                                ;*
        addd    #(1*4)          ;* Or (2*4) on the 128 list.            ;*
        std     JUNKTIME                                                ;*
        asla                                                            ;*
        asla                                                            ;*
        sta     Graph+GMinutes                                          ;*
        stb     Graph+GSeconds                                          ;*
        IF      1 = 1   ;***************** This is turned off! ***********      ;;Fixme was: IFE  1
;**                                                                     *
;*      Monitor Warrior Aggression                                      *
;**                                                                     *
        lda     WAgg                    ;* Monitor the high byte of     *
        asla                            ;*   (shifted to scale)         *
        sta     Graph+GAggression       ;*   the warrior aggression     *
;**
;*      Monitor Missions
;**
        ldx     #Temp
        clr     TGMWaDrift,X
        clr     TGMWaAttack,X
        clr     TGMWaMine,X
        clr     TGMWaTail,X
        clr     TGMWaInt,X

        ldu     #Ground
        cmpu    KeyClee+2
        beq     .4S
        ldu     [KeyClee+2]
.2S     lda     OSMIS,U
        cmpa    #OMWaSav
        bge     .3S
        asra
        ldb     A,X
        addb    #(4*4)                                                          ;;Fixme was: addb  #(4.*4.)  (Is decimal really needed here?)
        stb     A,X
.3S     ldu     [OSCTYPT,U]
        cmpu    #Ground
        bne     .2S

.4S     lda     TGMWaDrift,X
        sta     Graph+GMWaDrift
        lda     TGMWaAttack,X
        sta     Graph+GMWaAttack
        lda     TGMWaMine,X
        sta     Graph+GMWaMine
        lda     TGMWaTail,X
        sta     Graph+GMWaTail
        lda     TGMWaInt,X
        sta     Graph+GMWaInt
        ENDIF   ;1              ;******* Turned off for now. *************
        puls    D,X,U                                                   ;*
        SLEEP   LOOP                                                    ;*
;;;;;;; PULLORG ROMSAVE
        pullorg GRAFORG

        PUSHORG $FFF0
        FDB     RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
        PULLORG
                                ;*
        ENDIF   ;Diagnose       ;*****************************************