;       SUBTTL  BUTTON ROUTINES
;       PAGE
;*****
;*
;*      BBBB   U   U  TTTTT  TTTTT   OOO   N   N   SSSS
;*      B   B  U   U    T      T    O   O  NN  N  S
;*      BBBB   U   U    T      T    O   O  N N N   SSS
;*      B   B  U   U    T      T    O   O  N  NN      S
;*      BBBB    UUU     T      T     OOO   N   N  SSSS
;*
;*****
;       INCLVER RICH,display            * Message display macros

        PUSHORG ROMSAVE
BUTTON  EQU     *

;* ignored switch routines
;*****
;*
;*       SSSS  TTTTT   AAA   RRRR   TTTTT
;*      S        T    A   A  R   R    T
;*       SSS     T    AAAAA  RRRR     T
;*          S    T    A   A  R  R     T
;*      SSSS     T    A   A  R   R    T
;*
;*****
;       LOCAL
        BSWITCH START2,OPEN                                             ;;Fixme was: SWITCH  START2,OPEN
        inc     WECheck         ;* Add 2 to the "Williams Electronics"
        inc     WECheck         ;*   court check.
        rts

;       LOCAL
        BSWITCH START1,OPEN                                             ;;Fixme was: SWITCH  START1,OPEN
WECO    SET     $45                                                     ;;Fixme was: .$WECO  SET  $45
        lda     #$C3
        cmpa    WECheck
        lbne    rts
;       NLIST
        ROUTINE WE
        pshs    A,B,X,Y         ;* Save work registers
        TEXT    WECO,($50+1)                                            ;;Fixme was: TEXT .$WECO,($50+1)
        PHRASE  YELLOW,68,W
        leax    -6,X
        WORD    YELLOW,35,illiams
        RADIX   10
        leax    11,X                                                    ;;Fixme was: leax  11.,X
        RADIX   16
        WORD    YELLOW,68,E
        leax    -6,X
        WORD    YELLOW,35,lectronics
        puls    A,B,X,Y         ;* Restore work registers
        rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _W
        FDB     _illiams
        FDB     _E
        FDB     _lectronics

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       LIST

;       SUBTTL  FIRE BUTTON
;*****
;*
;*      FFFFF  IIIII  RRRR   EEEEE
;*      F        I    R   R  E
;*      FFFF     I    RRRR   EEEE
;*      F        I    R  R   E
;*      F      IIIII  R   R  EEEEE
;*
;*****
;       SUBTTL  SWITCH  FIREB,CLOSE
;*****
;*
;* SWITCH       FIREB,CLOSE
;*      When CLOSED, the player FIREB button will shoot a missle.
;*
;* Needs:
;*      Nothing
;*
;* Returns:
;*      Nothing
;*
;*****
;       LOCAL
        BSWITCH FIREB,CLOSE                                             ;;Fixme was: SWITCH  FIREB,CLOSE
        tst     AMDemo          ;* In attract mode,
        bne     .99S            ;*   player cannot fire.                ;;Fixme was:      bne  99$
        LDA     #1              ;set rapid fire timer to fire a shot
        STA     RAPTIME
        LDA     #08             ;initialize rapid fire rate
        STA     RAPRATE
.99S    asl     WECheck         ;* Williams Electronics court check.    ;;Fixme was: 99$  asl  WECheck
        RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  FIREB got patched over in WITT/FIXBUTTO.ASM ($6CCA)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        BSWITCH FIREB,OPEN                                              ;;Fixme was: SWITCH  FIREB,OPEN
        CLR     RAPTIME         ;turn off rapid fire
        TST     NPLAYER         ;If there is no player
        BEQ     .FIRE1S         ;  then restart attract mode            ;;Fixme was: BEQ  1$
        TST     AMDEMO          ;If there is a player but this is not demo mode
        lbeq    rts             ;  then return
        TST     HSTDMRQ         ;If we're in the middle of the HSTD page
        lbne    rts             ;  then just return
        CLR     NPLAYER
.FIRE1S CLR     AMDEMO          ;  else clear demo flags                ;;Fixme was: 1$ CLR     AMDEMO
        JMP     IAMODE          ;  and go restart demo
;
;       IFE     Version-17.
;*  <<< This stuff was included by mistake >>>                          ;;(Yup, this was included in the final build)
;*****
;*
;* SWITCH       FIREB,OPEN
;*      This routine turns off the machine gun fire.
;*
;* Needs:
;*      NPlayer - to determine if attact mode demo is running
;*      AMDemo  - to determine if in attract mode or game
;*
;* Returns:
;*      RapTime = 0 (zero) to turn off rapid fire.
;*
;*****
;       LOCAL
        BSWITCH FIREB,OPEN                                              ;;Fixme was: SWITCH  FIREB,OPEN
        CLR     RAPTIME         ;turn off rapid fire
        TST     NPLAYER         ;  If there is no player
        BNE     .FIRE2S
        CLR     AMDEMO
        JMP     IAMODE
.FIRE2S TST     AMDEMO          ;  If this is demo mode
        LBNE    DEATH           ;    then go kill this routine
        RTS                     ;  Else go back and do fire buttons really do
;       ENDIF   Version-17.

;       SUBTTL  SINIBOMB BUTTON
;*****
;*
;*       SSSS  IIIII  N   N  IIIII  BBBB    OOO   M   M  BBBB
;*      S        I    NN  N    I    B   B  O   O  MM MM  B   B
;*       SSS     I    N N N    I    BBBB   O   O  M M M  BBBB
;*          S    I    N  NN    I    B   B  O   O  M   M  B   B
;*      SSSS   IIIII  N   N  IIIII  BBBB    OOO   M   M  BBBB
;*
;*****
;       LOCAL
;*****
;*
;* FIRE SINIBOMB
;*      SWITCH  SBOMBB,CLOSED
;*
;*****
        BSWITCH SBOMBB,CLOSE                                            ;;Fixme was: SWITCH  SBOMBB,CLOSED (needs to be "CLOSE" not "CLOSED"!)
        tst     AMDemo          ;* If sinibomb button is hit while
        lbne    rts             ;*   in attract mode, do nothing.
        lda     Bombs           ;* If there are any bombs available for launch,
        lbne    BombsAway       ;*   and fire one.
;***
;* Out of bombs!
;***
        DISPLAY GREY                                                    ;;$6CE9
        PHRASE  GREY,35,mine,crystal,to                                 ;;Fixme was: PHRASE  GREY,35,mine,crystals,to
;       IFE     Version-17.                                             ;;(will have to reimplement this)
        PHRASE  GREY,35,make,sinibomb                                   ;;Fixme was: PHRASE  GREY,35,make,sinibombs
;       ELSE
;       PHRASE  GREY,35,make,a,sinibomb
;       ENDIF   Version-17.
        rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _MINE
;       FDB     _CRYSTALS       ;;(No plurals)
        FDB     _TO
        FDB     _MAKE
;       FDB     _SINIBOMBS      ;;(No plurals)

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*****
;*
;* BOMBSAWAY
;*
;* Needs:
;*      Bombs = the current number of sinibombs in the bombbay before this call
;*
;* Returns:
;*      Bombs = Bombs - 1 (or 0)
;*      InBombs = InBombs + 1 (to indicate another bomb is live)
;*
;*****
        ROUTINE BombsAway
        pshs    A,B,X,Y         ;* Save work registers
        LDB     #DCNS+DWBL      ;get dma constant to erase sinibomb display
        JSR     UPBOMBS         ;update sinibomb display. uses A
        inc     InBombs         ;* Mark another bomb launched.
        dec     Bombs           ;* Decrement remaining sinibombs counter.
        bne     .11S            ;* When there are no bombs left,
        jsr     Empty           ;*   display "EMPTY" bomb message.
.11S    TUNE    QSFire          ;* Make the sound of a released sinibomb.
        ldd     #0000           ;* D = Scanner position for object.
        ldx     #CSbomb         ;* X -> Char. Desc. for sinibomb
        jsr     [OInVec,X]      ;* Create sinibomb, X -> scanner workspace
;*
        leay    X               ;* Y -> Sinibomb scanner workspace.
        ldx     [SinIndex]      ;* X -> Sinistar scanner workspace.
        jsr     ReTarget        ;* Aim at the built part of the Sinistar.
        jsr     AimFlAng        ;* Compute the direction toward the
        adda    #(CIRCLE/2)     ;*   Sinistar.
        jsr     UnTarget        ;* Restore the Sinistar coordinates.
        jsr     sincos          ;* A = the sine, B = the cosine of the angle.
        pshs    A,B             ;* Save them.
;*
        puls    B               ;* The SHORT velocity of
        sex                     ;*   the bomb is proportional
        RPT     0+1,aslb,rola   ;*   to the sine of the shot angle
        addd    OSVEL+WPlayer   ;*   and the player velocity.
        ldx     OSSCWSA,Y       ;* X -> sinibomb object workspace
        std     OSVEL,X         ;* Set the velocity.

        puls    B               ;* The LONG velocity of
        sex                     ;*   the bomb is proportional
        RPT     0,aslb,rola     ;*   to the cosine of the shot angle
        addd    OLVEL+WPlayer   ;*   and the player velocity.
        std     OLVEL,X         ;* Set the velocity.
        puls    A,B,X,Y         ;* Restore work registers
        rts
;****
;*
;* FIRE SINIBOMB
;*      SWITCH  SBOMBB,OPEN
;*
;*****
;       LOCAL
        BSWITCH SBOMBB,OPEN                                                     ;;Fixme was: SWITCH  SBOMBB,OPEN
        ldx     #Credits        ;* The trojan court check requires that
        jsr     rcmosa          ;*   there be no credits in the machine
        tsta                    ;*   at the time the check is being made
        bne     .SBOM1S         ;*   to keep this from being found.             ;;Fixme was: bne   1$
        asr     WECheck         ;* Arithmetic shift right the court check.
;       NLIST
.SBOM1S lda     #$C3            ;* If the magic C3 is still there, then         ;;Fixme was: 1$ lda     #$C3
        cmpa    WECheck         ;*   three credits are the price to open
        bne     .2S             ;*   the secret door within the secret door.
        ldx     #Credits        ;* If there are not
        jsr     rcmosa          ;*   exactly 3 credits placed
        cmpa    #(3<<4)         ;*   in the machine then the                    ;;Fixme was: cmpa  #(3!<4)
        bne     .2S             ;*   test fails.  Else, ...
        New_Sleep       Task4,.100S,OMTLen+1
        RADIX   10
        lda     #(15*16)        ;* Run the secondary display                    ;;Fixme was: lda   #(15.*16.)
        RADIX   16
        sta     OMTLen,X        ;*   for 15 seconds.
        clr     WECheck         ;* Lock the check from triggering this again.
.2S     rts
;*
.100S   dec     OMTLen,Y        ;* Count down the life clock of this task
        bne     .101S           ;*   until it hits zero and should die.
        jsr     PClrScr         ;* Then clear the screen
        jmp     Die             ;*   before dying.

.101S   jsr     WE              ;* Hi Williams!
        pshs    A,B,X,Y         ;* Save work registers

        RADIX   10

        TEXT    (WECO+18),$5A+12        ;* Hi Sam!                              ;;Fixme was: TEXT  (.$WECO+18.),$5A+12.
        PHRASE  YELLOW,35,SAM

        TEXT    (WECO+18),$5A+45                                                ;;Fixme was: TEXT  (.$WECO+18.),$5A+45.
        PHRASE  YELLOW,35,DICKER

        TEXT    (WECO+26),($5A+16)      ;* Hi Noah!                             ;;Fixme was: TEXT  (.$WECO+26.),($5A+16.)
        PHRASE  YELLOW,35,N
        PHRASE  YELLOW,35,O
        PHRASE  YELLOW,35,A
        PHRASE  YELLOW,35,H

        TEXT    (WECO+2),($5A+16)                                               ;;Fixme was: TEXT  (.$WECO+2),($5A+16.)
        PHRASE  YELLOW,35,F
        PHRASE  YELLOW,35,A
        PHRASE  YELLOW,35,L
        PHRASE  YELLOW,35,S
        PHRASE  YELLOW,35,T
        PHRASE  YELLOW,35,E
        PHRASE  YELLOW,35,I
        PHRASE  YELLOW,35,N

        TEXT    (WECO-22),($5A+12)      ;* Hi Rich!                             ;;Fixme was: TEXT  (.$WECO-22.),($5A+12.)
        PHRASE  YELLOW,35,RICHARD

        TEXT    (WECO-22),($5A+49)                                              ;;Fixme was: TEXT  (.$WECO-22.),($5A+49.)
        PHRASE  YELLOW,35,A

        TEXT    (WECO-22),($5A+59)                                              ;;Fixme was: TEXT  (.$WECO-22.),($5A+59.)
        PHRASE  YELLOW,35,WITT

        TEXT    (WECO+18),($5A+65)      ;* Hi Bob!                              ;;Fixme was: TEXT  (.$WECO+18.),($5A+65.)
        PHRASE  YELLOW,35,R
        PHRASE  YELLOW,35,O
        PHRASE  YELLOW,35,B
        PHRASE  YELLOW,35,E
        PHRASE  YELLOW,35,R
        PHRASE  YELLOW,35,T

        TEXT    (WECO-10),($5A+65)                                              ;;Fixme was: TEXT  (.$WECO-10.),($5A+65.)
        PHRASE  YELLOW,35,J

        TEXT    (WECO-18),($5A+65)      ;* Hi Bob!                              ;;Fixme was: TEXT  (.$WECO-18.),($5A+65.)
        PHRASE  YELLOW,35,M
        PHRASE  YELLOW,35,I
        PHRASE  YELLOW,35,C
        PHRASE  YELLOW,35,A
        PHRASE  YELLOW,35,L

        RADIX   16

        puls    A,B,X,Y         ;* Restore work registers
        Sleep   LOOP
;       LOCAL
;       LIST
.1S     rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _SAM
        FDB     _DICKER

        FDB     _N
        FDB     _O
        FDB     _A
        FDB     _H
        FDB     _F
;       FDB     _A
        FDB     _L
        FDB     _S
        FDB     _T
;       FDB     _E              ;;(Already defined)
        FDB     _I
;       FDB     _N

        FDB     _RICHARD
        FDB     _WITT

        FDB     _R
;       FDB     _O
        FDB     _B
;       FDB     _E
;       FDB     _R
;       FDB     _T

        FDB     _J

        FDB     _M
;       FDB     _I
        FDB     _C
;       FDB     _A
;       FDB     _L

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        PULLORG ROMSAVE

;       INCLVER RICH,empty