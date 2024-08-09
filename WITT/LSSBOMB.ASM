;       INCLUDE "../WITT/DISPLAY.ASM"           ;* Message display macros

        PUSHORG ROMSAVE
;*****
;*
;* LSSBOMB
;*      Leaving Sector routine for a Sinibomb.
;*      This automatically intercepts the sinistar and destroys a
;*      piece of it when the Sinistar is out of the sector too.
;*      Otherwise, leaving the sector causes interception by a worker
;*      or warrior or something else (when the sinistar hasn't left the sector)
;*
;* Needs:
;*      Y -> scanner workspace of sinibomb leaving the sector
;*      U -> characteristics descriptor of sinibomb leaving the sector
;*      SiniSector - NON-ZERO when the sinistar is out of sector.
;*                   ZERO when the sinistar is within the sector.
;*
;* Returns:
;*      Nothing
;*
;*****
        PUSHORG CSbomb+OLSVec
        fdb     LSSBomb
        PULLORG

        ROUTINE LSSBomb
        pshs    A,B,X,Y         ;* Save work registers
        tst     SiniSector      ;* If the Sinistar is not in sector
        bne     LSSB1S          ;*   then intercept the bomb.
        ldx     PiecePtr        ;* If the Sinistar has
        cmpx    #PieceTbl       ;*   at least one piece
        bne     LSSB99S         ;*   then it can be tracked.  Else, die ...
;**
;*      Too bad for the Sinibomb!  It got intercepted by the psuedo-wall
;*      of workers and warriors around the edge of the sector.
;**
LSSB1S  leax    Y               ;* X -> sinibomb scanner workspace              ;;Fixme was: 1$ (Had to convert local labels to global because of TEXT/PHRASE macros)
        jsr     [OKiVec,U]      ;* Kill sinibomb
        RANDOM  OSEED1,BYTE     ;* Randomly report
        tsta                    ;*   the status of
        bmi     LSSB99S         ;*   sinibombs that leave sector.
        DISPLAY YELLOW
        PHRASE  YELLOW,35,SINIBOMB
        PHRASE  YELLOW,35,INTERCEPTED

LSSB99S puls    A,B,X,Y         ;* Restore work registers                       ;;Fixme was: 99$
        rts

        PULLORG ROMSAVE

;       INCLVER RICH,subpart            ;* Kill a part of the sinistar