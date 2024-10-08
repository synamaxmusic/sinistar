;===============================================================================
; EQUs to remove later
;PREBOY EQU     $5728   ;COLLISIO
;GIVCRYS        EQU     $6C64   ;STUBS
;KRCRYS EQU     $6C70   ;STUBS
;PREBOU EQU     $6C79   ;STUBS
;POSBOU EQU     $6C76   ;STUBS
;ADDVIB EQU     $6C56   ;STUBS
;SUBPART        EQU     $58B9   ;SUBPART
;===============================================================================

;       SUBTTL  COLLISIONS
;       PAGE
;*****
;*
;*       CCCC   OOO   L      L      IIIII   SSSS  IIIII   OOO   N   N   SSSS
;*      C      O   O  L      L        I    S        I    O   O  NN  N  S
;*      C      O   O  L      L        I     SSS     I    O   O  N N N   SSS
;*      C      O   O  L      L        I        S    I    O   O  N  NN      S
;*       CCCC   OOO   LLLLL  LLLLL  IIIII  SSSS   IIIII   OOO   N   N  SSSS
;*
;*****
        INCLUDE "../SAM/COLLIDE.ASM"    ;* Collide macro
;       INCLVER RICH,display            * Message display macros
;       INCLVER RICH,table              * Data table macros

        PUSHORG ROMSAVE
;*****
;*
;* SCORING
;*      15,000 Sinistar skull
;*         500 Sinistar skeleton piece
;*         500 Warriors
;*         200 Crystals
;*         150 Workers
;*         100 Warrior shot
;*           5 Planetoids (including Pluto) (handled by KRPlan?)
;*
;*****
        ROUTINE collision
;* collision types (must assemble before COLLIDE macros)
CLCOUNT SET     0
        MAKECOL PLAYER
        MAKECOL PLANET
        MAKECOL SBOMB
        MAKECOL CRYSTAL
        MAKECOL WORKER
        MAKECOL WORKCR
        MAKECOL WARRIOR
        MAKECOL SINI
        MAKECOL PLSHOT
        MAKECOL WASHOT
        MAKECOL FRAGMENT

;* bounce routine
        COLLIDE PLAYER,WORKER   ;* Bounce
        COLLIDE PLAYER,WORKCR   ;* Bounce
        COLLIDE PLAYER,WARRIOR  ;* Bounce
        tst     InWarp          ;* During the warp,
        lbne    rts             ;*   player collisions are off!
        COLLIDE CRYSTAL,CRYSTAL ;* Bounce
        COLLIDE CRYSTAL,WORKCR  ;* Bounce
        COLLIDE CRYSTAL,WARRIOR ;* Bounce
        COLLIDE WORKER,WORKER   ;* Bounce
        COLLIDE WORKER,WORKCR   ;* Bounce
        COLLIDE WORKER,WARRIOR  ;* Bounce
        COLLIDE WORKCR,WORKCR   ;* Bounce
        COLLIDE WORKCR,WARRIOR  ;* Bounce
        COLLIDE WARRIOR,WARRIOR ;* Bounce
        JMP     BOUNCE

        COLLIDE PLAYER,SINI     ;* Player bounces until Sinistar built
        tst     InWarp          ;* During the warp,
        lbne    rts             ;*   player collisions are off!
        ldd     Finish          ;* Until the sinistar is built, the player
        cmpd    #Alive          ;*   bounces off pieces, but when built, the
        lbne    PreBoY          ;*   Sinistar can move in and eat the player.
        tst     SinGrave        ;* If the Sinistar is not dying
        lbeq    SINIBITE1       ;*   it can bite the player.                    ;;Fixme was: lbeq 1$
        rts                     ;* Else, the player passes through.
;*      sorry                   ;* The ship cannot bounce off a dying Sinistar.
;***
;* Sinistars bites player
;***
SINIBITE1 CLRD
        STD     OLVEL,Y         ;zero the sinistar velocity
        STD     OSVEL,Y
        STD     OLVEL+WPLAYER   ;kill the players velocity
        STD     OSVEL+WPLAYER
        LDA     #8              ;disable player controls
        STA     PANMASK
        CLR     RAPTIME
        LDD     #CNULL          ;disable player collisions
        STD     OCHAR+WPLAYER
        CLR     ASCINT          ;interrupt any other speech
        SPEAK   9               ;roar and leave mouth open
        NEW_SLEEP TASK1,.2S,OMTLEN+1
        RADIX   10
        LDA     #146            ;close mouth after roar
        RADIX   16
        STA     OMTLEN,X
        RTS
;* spin player
.2S     LDA     SINGRAVE        ;it sinistar still alive?
        BNE     .4S
        FRANDOM OSEED1,BYTE     ;yes, give player a random angle
        STA     PLYRANG
        CLR     INSTUN          ;can't stun an eating sinistar
        LDX     [SININDEX]      ;tell sinistar to attack full speed
        LDA     OSPERS,X
        ANDA    #~PSINIINHIBIT                          ;;Fixme was: #!NPSINIINHIBIT
        STA     OSPERS,X
        DEC     OMTLEN,Y        ;done roaring?
        BEQ     .3S
        SLEEP   LOOP
.3S     CLR     ASCINT          ;yes, close mouth no matter what
        RADIX   10
        SPEAK   10
        RADIX   16
        LDD     #CPLAYER        ;make player again for explosion
        STD     OCHAR+WPLAYER
        JSR     DEATH           ;kill player
        BRA     .5S
.4S     LDA     #0F             ;re-enable player controls
        STA     PANMASK
.5S     JMP     DIE

;*****
;*
;* COLLISION    PLAYER,CRYSTAL
;*
;*      When a player bumps a crystal, the crystal is normally taken
;*      into the ship and turned into a sinibomb.  The new sinibomb
;*      is marked near the player's score.  However, there is a maximum
;*      number (MAXBOMBS) of sinibombs which can be held and the player
;*      will merely bounce off crystals when the ship is full.  A tune
;*      is played to reinforce the fact when a player does manage to pick
;*      up a crystal.
;*
;*****
        COLLIDE PLAYER,CRYSTAL  ;* Player picks up crystal.
        jsr     AddBomb         ;* Add a bomb to the bombbay display, if ok.
        ldx     [OScan,Y]       ;* Kill off the
        ldu     OSChar,X        ;*   cyrstal as if
        jsr     [OKiVec,U]      ;*   bringing it inside the ship.
        ldd     #$200           ;* Score a few points
        jsr     addscore        ;*   for collecting the crystal.
        rts
;*****
;*
;* ADDBOMB
;*
;* Needs:
;*      Bombs = the number of sinibombs in the bombbay before this call.
;*
;* Returns:
;*      Bombs = Bombs + 1
;*
;*****
        ROUTINE AddBomb
        pshs    A,B,X,Y         ;* Save work registers.
        LDA     BOMBS           ;* If the Sinibomb count was zero,
        bne     .1S             ;*   the "EMPTY" message in the bomb
        jsr     NotEmpty        ;*   display area must be erased.
.1S     INCA                    ;* Add a bomb to the bomb bay.
        cmpa    #MAXBOMBS       ;* If the bomb bay is not yet full,
        ble     ADDB2S  ;*   then another bomb is manufactured.                 ;;Fixme was: ble .2S
;*
        TUNE    QFulCr          ;* Else, signal crystal pick up for warp engines
        DISPLAY GREY
        PHRASE  GREY,35,CRYSTAL,SAVED
        PHRASE  GREY,35,FOR,WARP,ENGINES
        bra     ADDB3S                                                          ;;Fixme was: bra .3S
;*
ADDB2S TUNE     QPlayCr         ;* Signal another crystal picked up for bomb-bay
        sta     Bombs           ;* Save new sinibomb count
        ldb     #DWBL           ;* Get DMA constant to write to sinibomb display
        jsr     UpBombs         ;* Update sinibomb display, save Y, uses A
ADDB3S  puls    A,B,X,Y         ;* Restore work registers.
        rts

;       TABLE   QFulCr
QFulCr  _IPrio  21              ;* Tune for picking up last and latter crystals
        _Sound  17              ;*   to fill the bomb-bay.
        _Prio   1A
        _Time   0C
        _Stop
;       ENDTBL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _CRYSTAL
        FDB     _SAVED
        FDB     _FOR
        FDB     _WARP
        FDB     _ENGINES

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*****
;*
;* COLLISION    PLAYER,SBOMB
;*
;*      Currently sinibombs just pass through the player's ship.  This should
;*      be changed to a bounce, but that means modifying the sinibomb launch
;*      routine.
;*
;*****
;       LOCAL
;*      COLLIDE PLAYER,PLAYER           * Pass through <<< Hmmmm >>>>
;*      COLLIDE PLAYER,SBOMB            * Pass through
;*      COLLIDE PLAYER,PLSHOT           * Pass through
;*      COLLIDE PLAYER,FRAGMENT         * Pass through
;*      COLLIDE SBOMB,PLSHOT            * Pass through
;*      COLLIDE SBOMB,SBOMB             * Pass through
;*      COLLIDE SBOMB,CRYSTAL           * Pass through
;*      COLLIDE SBOMB,FRAGMENT          * Pass through
;*      COLLIDE WORKCR,SINI             * Pass through
;*      COLLIDE WARRIOR,WASHOT          * Pass through
;*      COLLIDE WASHOT,WASHOT           * Pass through
;*      COLLIDE PLANET,FRAGMENT         * Pass through
;*      COLLIDE CRYSTAL,PLSHOT          * Pass through
;*      COLLIDE CRYSTAL,WASHOT          * Pass through
;*      COLLIDE CRYSTAL,FRAGMENT        * Pass through
;*      COLLIDE SINI,WASHOT             * Pass through
;*      COLLIDE SINI,PLSHOT             * Pass through
;*      COLLIDE SINI,FRAGMENT           * Pass through
;*      COLLIDE PLSHOT,FRAGMENT         * Pass through
;*      COLLIDE FRAGMENT,FRAGMENT       * Pass through
;*      rts

;* shoot worker
        COLLIDE WORKER,PLSHOT           ;* Explosion
        COLLIDE WORKCR,PLSHOT           ;* Explosion, crystal left
        COLLIDE WORKER,WASHOT           ;* Explosion
        COLLIDE WORKCR,WASHOT           ;* Explosion, cyrstal left
;*
        TUNE    QBang                   ;* Explosion sound.
        ldx     [OScan,X]               ;* Get scanner WS
        ldu     OSChar,X                ;* Get charac. Descr.
        jsr     [OKiVec,U]              ;* Do appropriate kill subroutine
        leax    ,Y                      ;* Point to shot
        jsr     KillObj                 ;* Kill it off too
        ldd     #$150                   ;* Score points
        jsr     addscore                ;*   for killing the worker.
        rts

;* shoot player
        COLLIDE PLAYER,WASHOT   ;* Player death
        tst     InWarp          ;* During the warp,
        lbne    rts             ;*   player collisions are off!
        leax    Y               ;* Kill off
        jsr     killobj         ;*   warrior shot.
        jsr     DEATH           ;* Kill player ship.
        rts

;       LOCAL
;*****
;*
;* COLLIDE CRYSTAL,WORKER
;*        WORKER,CRYSTAL
;*
;*      The worker should pick up any crystal it touches, but the killing
;*      routines aren't capable of handling the complexities of informing
;*      called workers that the caller, the crystal, has died (been picked
;*      up) by some other worker.  This bug is stepped around by allowing
;*      workers to pass over crystals that did not call them.  No bounce
;*      occurs since the bounce would defeat the play of both the other
;*      workers as well as the player.
;*
;*****
        COLLIDE CRYSTAL,WORKER  ;* Worker picks up crystal
        ldu     [OScan,Y]       ;* Point at scanner WS of worker
        ldd     OScan,X         ;* Get index to this crystal
        cmpd    OScWCr,U        ;* Did this crystal call this worker?
        beq     CRYWO1S         ;* If so give the crystal to it                 ;;Fixme was: 1$ (had to change local label)
        rts                     ;* Otherwise, PASS THROUGH
;*
CRYWO1S TUNE    QWorkCr         ;* Play a tune when worker picks up a crystal
        ldx     [OScan,X]       ;* Get scanner WS of crystal
        jsr     KRCrys          ;* Kill it
        ldx     [OScan,Y]       ;* Get scanner WS of worker
        jmp     GivCrys         ;* Gives crystal to worker, on or off screen
;*
;       LOCAL
        COLLIDE PLAYER,PLANET   ;* Vib. Bounce
        tst     InWarp          ;* During the warp,
        lbne    rts             ;*   player collisions are off!
        lda     #1              ;* Zap the court check
        sta     WECheck         ;*   variable to help prevent detection.
        COLLIDE CRYSTAL,SINI    ;* Vib. Bounce
        COLLIDE WORKER,SINI     ;* Vib. Bounce
        COLLIDE WARRIOR,SINI    ;* Vib. Bounce
;*
PreBoY  exg     X,Y             ;* Swap objects
;*
        COLLIDE PLANET,CRYSTAL  ;* Vib. Bounce
        COLLIDE PLANET,WORKER   ;* Vib. Bounce
        COLLIDE PLANET,WORKCR   ;* Vib. Bounce
        COLLIDE PLANET,WARRIOR  ;* Vib. Bounce
;*
        jsr     PreBou          ;* Do pre-bounce for planet
        jsr     Bounce
        jmp     PosBou          ;* Restore vibration
;*

        COLLIDE PLANET,PLANET   ;* Vib. Bounce
        COLLIDE SINI,SINI       ;* Vib. Bounce <<< Hmmm >>>
;*
BOUNCER pshs    X               ;* Save first object WS                         ;;Fixme was: 1$ (can't use local labels because of PreBoY)
        leax    ,Y              ;* Get planet object WS
        jsr     Prebou          ;* Pre-bounce prep for planet
        puls    X               ;* Restore first WS
        jsr     Prebou          ;* Pre-bounce prep for other object
        jsr     Bounce          ;* Do the bounce
        jsr     PosBou          ;* Restore vibration to X object
;*      pshs    X               ;* Save first object WS
        leax    ,Y              ;* Get Y object
        jsr     PosBou          ;* Restore vibration
;*      puls    X               ;* Restore first WS
        rts
        COLLIDE PLANET,SINI     ;* Vib. Bounce <<< can shatter planet >>>
        jsr     AddVib
        bra     BOUNCER                                                         ;;Fixme was: bra 1$

        COLLIDE Planet,PlShot
        COLLIDE Planet,WaShot
        jsr     AddVib          ;* Add some vibration to the planet.
        jmp     YDies           ;* Kill off the shot.

;       LOCAL
;       SECTION SBOMBCOLLIDE
;* Bomb planets
        COLLIDE PLANET,SBOMB    ;* Explosion
        TUNE    QBang           ;* The sound of an exploding sinibomb.
        ldx     [OSCAN,X]       ;* X -> sinibomb scanner workspace
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Kill it.
        ldx     [OSCAN,Y]       ;* Get scanner workspace
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Do appropriate kill subroutine
        jsr     SBOMB1S                                                         ;;Fixme was: jsr 1$ (Local labels and
                                                                                ;;SECTION/ENDSECTION don't work with
                                                                                ;;the PHRASE macro.)
        rts

;* Bomb worker
        COLLIDE SBOMB,WORKER    ;* Explosion
        COLLIDE SBOMB,WORKCR    ;* Explosion
        TUNE    QBang           ;* The sound of an exploding sinibomb.
        ldx     [OSCAN,X]       ;* X -> sinibomb scanner workspace
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Kill it.
        ldx     [OSCAN,Y]       ;* X -> worker scanner workspace
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Kill it.
        ldd     #$150           ;* Score points
        jsr     addscore        ;*   for killing the worker.
        jsr     SBOMB1S
        rts

;* Bomb warrior
        COLLIDE SBOMB,WARRIOR   ;* Explosion
        TUNE    QBang           ;* The sound of an exploding sinibomb.
        ldx     [OSCAN,X]       ;* X -> sinibomb scanner workspace
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Kill it.
        ldx     [OSCAN,Y]       ;* Get scanner workspace
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Do appropriate kill subroutine
        ldd     #$500           ;* Score points
        jsr     addscore        ;*   for killing the warrior.
SBOMB1S DISPLAY YELLOW
        PHRASE  YELLOW,35,SINIBOMB
        PHRASE  YELLOW,35,INTERCEPTED
        rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _SINIBOMB
        FDB     _INTERCEPTED

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ENDSECTION SBOMBCOLLIDE

;       LOCAL
;* Bomb Sinistar
        COLLIDE SBOMB,SINI      ;* Explosion <<< Part of Sinistar dies >>>
        TUNE    QBang           ;* The shound of an exploding sinibomb.
        pshs    X
        leax    Y               ;* Get sini WS
        jsr     AddVib          ;* make it vibrate (more)
        puls    X               ;* Restore object WS pointer
        ldx     [OSCAN,X]       ;* X -> sinibomb scanner workspace
        ldu     OSChar,X        ;* Get sinibomb characteristics descriptor
        jsr     [OKiVec,U]      ;* Kill sinibomb
        jsr     Subpart         ;* Kill off a part of the sinistar
        lda     InStun          ;* Accumulate
        adda    #2              ;*   more time that
        sta     InStun          ;*   the Sinistar is stunned.
        rts

;* warrior shoots sinibomb
        COLLIDE SBOMB,WASHOT    ;* Bomb destroyed by warrior.
;*
        TUNE    QBang           ;* Explosion sound.
        ldx     [OScan,X]       ;* Get scanner WS
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Do appropriate kill subroutine
        leax    ,Y              ;* Point to shot
        jsr     KillObj         ;* Kill it off too
        rts

;* shoot warrior
        COLLIDE WARRIOR,PLSHOT  ;* Explosion
;*
        TUNE    QBang           ;* Explosion sound.
        ldx     [OScan,X]       ;* Get scanner WS
        ldu     OSChar,X        ;* Get charac. Descr.
        jsr     [OKiVec,U]      ;* Do appropriate kill subroutine
        leax    ,Y              ;* Point to shot
        jsr     KillObj         ;* Kill it off too
        ldd     #$500           ;* Score points
        jsr     addscore        ;*   for killing the warrior.
        rts

;       LOCAL
;***
;*      Object X dies ... and then Y dies.
;***
        COLLIDE WASHOT,FRAGMENT         ;* Shot and Fragment die.
        jsr     KillObj                 ;* Kill shot
;***
;*      Object Y dies.
;***
        COLLIDE WORKER,FRAGMENT         ;* Fragment dies.
        COLLIDE WORKCR,FRAGMENT         ;* Fragment dies.
        COLLIDE WARRIOR,FRAGMENT        ;* Fragment dies.
YDies   leax    Y
        jsr     KillObj                 ;* uses A,B
        rts

;       LOCAL
        COLLIDE PLSHOT,WASHOT   ;* Explosion
        TUNE    QBang           ;* The sound of missles exploding.
        jsr     killobj         ;* Kill the player's shot
        leax    Y               ;*   and then
        jsr     killobj         ;*   kill the warrior's shot.
        ldd     #$100           ;* Score points for
        jsr     addscore        ;*   destroying the warrior shots.
        rts

        PULLORG ROMSAVE

        INCLUDE "../WITT/DEATH.ASM"     ;* Player death routine
;       INCLVER RICH,empty
        INCLUDE "../WITT/SUBPART.ASM"   ;* Kill a part of the sinistar