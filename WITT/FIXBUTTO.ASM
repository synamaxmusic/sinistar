;*****
;*
;* SWITCH       FIREB,OPEN
;*      This routine turns off the machine gun fire.
;*
;* Needs:
;*      NPlayer - to determine if attact mode demo is running
;*      AMDemo  - to determine if in attract mode or game
;*      HSTDMRQ - to determine if in HSTD/MARQUEE page display
;*
;* Returns:
;*      RapTime = 0 (zero) to turn off rapid fire.
;*
;*****
;       LOCAL
;       IFE     Version-17.
        PUSHORG $6CCA
;       ENDIF   Version-17.
;*
        BSWITCH FIREB,OPEN                                                      ;;Fixme was: SWITCH  FIREB,OPEN  (This should patch over $2E40 as well)
        CLR     RAPTIME         ;turn off rapid fire
        TST     HSTDMRQ         ;If we're in the middle of the HSTD page
        lbne    rts             ;  then just return
        TST     NPLAYER         ;If there is no player
        BEQ     FIXBUT1         ;  then restart attract mode
        TST     AMDEMO          ;If there is a player but this is not demo mode
        lbeq    rts             ;  then return
        CLR     NPLAYER
FIXBUT1 CLR     AMDEMO          ;  else clear demo flags                        ;;Fixme was: 1$
        JMP     IAMODE          ;  and go restart demo
;*
;       IFE     Version-17.
        PULLORG
;       ENDIF   Version-17.