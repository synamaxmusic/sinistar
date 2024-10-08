;       INCLVER RICH,display            * Message display macros

        PUSHORG ROMSAVE

;       SUBTTL  SINIBOMB        Sinibomb intelligence routine.
;*****
;*
;* SINIBOMB
;*      This is the Sinibomb intelligence routine.  A Sinibomb will home
;*      in on the Sinistar to destroy it.  Fuel is limited on this intelligent
;*      missle and it will coast to a stop after a while.
;*
;* Bugs:
;*      This sinibomb is currently made to orbit the player ship.  It's not
;*      supposed to do that.  It's just for debugging.
;*
;* Needs:
;*      Y -> task workspace of Sinibomb
;*
;*****
;       LOCAL
        ROUTINE sinibomb
        pshs    A,B,X,Y,U       ;* Save work registers
        ldy     [OWSCON,Y]      ;* Y -> scanner workspace of sinibomb
        jsr     think           ;* Think when on screen or else as if
        lbcs    .3S             ;*   on the Task16 list.

        ldu     OSSCWSA,Y       ;* If the sinibomb is onscreen,
        bne     .1S             ;*   then skip all this offscreen code.

        ldu     [OCleLs,Y]      ;* Get scanner WS of first worker
        jsr     .10S            ;* Kill the slaves
        ldu     [OCleLs+2,Y]    ;* Get scanner WS of first warrior
        jsr     .10S            ;* Do it again

.1S     ldx     Finish          ;* If the Sinistar
        cmpx    #Alive          ;*  is alive now,
        beq     .2S             ;*  then the sinibomb tracks it down.

        ldd     PiecePtr        ;* If the sinistar is not yet
        cmpd    #PieceTbl       ;*   built up at all, then there is nothing
        beq     .3S             ;*   toward which the bomb can head.

.2S     ldx     [SinIndex]      ;* X -> scanner workspace of Sinistar
        jsr     ReTarget        ;* Set the Sinistar target position.
        jsr     getldist        ;* D = long orbital distance from the target
        pshs    D               ;* Save this for the death check.
        ldx     #stblsbomb      ;* X -> speed table
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        ldx     [SinIndex]      ;* X -> scanner workspace of Sinistar
        jsr     getsdist        ;* D = short orbital distance from the target
        pshs    D               ;* Save this for the death check.
        jsr     UnTarget        ;* Reset the Sinistar's true position.
        ldx     #stblsbomb      ;* X -> speed table
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity
;***
;* Check the range on the offscreen target.
;***
        ldu     OSSCWSA,Y       ;* If the sinibomb is onscreen, it should only
        bne     .4S             ;*   die via COLLIDE.
        tst     SiniSector      ;* If the Sinistar is out of sector,
        bne     .4S             ;*   it cannot be in range.
        ldx     [SinIndex]      ;* If the Sinistar is onscreen,
        ldu     OSSCWSA,X       ;*   the sinibomb can only
        bne     .4S             ;*   destroy it via COLLIDE.

        ldd     2,S             ;* Take
        ABSD                    ;*   the
        std     2,S             ;*   two
        puls    D               ;*   distances
        ABSD                    ;*   and if
        ora     ,S+             ;*   both
        orb     ,S+             ;*   are
        cmpd    #SinDis         ;*   less than SinDis,
        bgt     .3S             ;*   then the Sinibomb may be detonated ...
;*
        tfr     Y,X             ;* X -> sinibomb scanner workspace
        ldu     OSChar,X        ;* Kill the
        jsr     [OKiVec,U]      ;*   sinibomb.
        jsr     subpart         ;* Kill of a part of the Sinistar.

.3S     puls    A,B,X,Y,U       ;* Restore work registers
        SLEEP   LOOP
.4S     puls    D               ;* Clear
.5S     puls    D               ;*   the stack
        bra     .3S             ;*   and exit.
;*****
;*
;* BOOTH
;*
;* Needs:
;*      Y -> scanner workspace of sinibomb
;*      U -> scanner workspace of first callee
;*
;*****
.10S    pshs    A,B,X,Y,U       ;* Save work registers
        pshs    CC,A            ;* Save stack space and the LDU condition code
        clr     1,S             ;* Mark the stack to indicate the sinibomb
        inc     1,S             ;*   lives on, unless later marked for death.
        puls    CC              ;* Restore the LDU condition code
;***
;*      This routine is entered with U having been loaded as the scanner
;*      workspace of the first callee (worker or warrior).  If that was
;*      zero (grounded) then there is no callee.
;***
.11S    beq     .13S            ;* If workspace is grounded, return
        ldd     #(SinDis/4)     ;* Check to see if there is
        cmpa    OSCLDC,U        ;*   nearby in the LONG direction
        blo     .12S            ;* If too far, forget this.
        cmpb    OSCSDC,U        ;* Is it nearby in the SHORT direction?
        blo     .12S            ;* If too far, forget this.
;***
;*      Kill the callee that collided with the sinibomb.
;***
        ldd     OSSCWSA,U       ;* A callee which is on screen
        bne     .12S            ;*   cannot be off screen killed.

        pshs    U               ;* Save work registers
        tfr     U,X             ;* X -> scanner workspace of callee
        ldu     OSChar,X        ;* Kill the
        jsr     [OKiVec,U]      ;*   callee.
        puls    U               ;* Restore work registers
;*      NO TUNE for off screen deaths.
        clr     0,S             ;* Mark the sinibomb for death.
;***
;*      Now go on and check other members in the list.
;***
.12S    ldu     [OScSqI,U]      ;* U -> workspace of next member of squadron
        bra     .11S            ;* Keep checking the list
;***
;*      Kill the sinibomb since it has collided with a callee.
;***
.13S    tst     ,S+             ;* If the sinibomb was marked for death
        bne     SB14S           ;*   then kill it ...                           ;;Fixme was: bne  14$  (Local labels get messed up with PHRASE macro)

        tfr     Y,X             ;* X -> scanner workspace of callee
        ldu     OSChar,X        ;* Kill the
        jsr     [OKiVec,U]      ;*   sinibomb.
        DISPLAY YELLOW
        PHRASE  YELLOW,35,SINIBOMB
        PHRASE  YELLOW,35,INTERCEPTED
SB14S   puls    A,B,X,Y,U       ;* Restore work registers                       ;;Fixme was: 14$  puls  A,B,X,Y,U
        rts

        PULLORG ROMSAVE

;       INCLVER RICH,lssbomb            ;* Leaving sector routine
;       INCLVER RICH,stblsbomb          ;* Sinibomb speed table
;       INCLVER RICH,subpart            ;* Kill a part of the sinistar