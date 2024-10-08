        PUSHORG CWarrior+OOffScr
        fdb     WarrOff         ;* Warrior off screen routine
        PULLORG

        PUSHORG ROMSAVE
;*****
;*
;* WARROFF
;*      Warrior Off-Screen routine.  This routine is invoked when the warrior
;*      first goes off screen and is used to inhibit its ability to shoot at
;*      the player.
;*
;* Needs:
;*      Y -> warrior screen workspace
;*
;* Returns:
;*      OSPERS - The shooting heuristic bits marked for inhibition of
;*               shooting for 8 wakeups on-screen in the scanner workspace.
;*
;*****
        ROUTINE WarrOff
        pshs    Y               ;* Save work registers
        ldy     [OScan,Y]       ;* Y -> Scanner workspace of warrior
        jsr     inhibit         ;* Inhibit warriors from shooting for a while.
        puls    Y               ;* Restore work registers
        jmp     ScrOff          ;* Resume normal screen off routine.

;*****
;*
;* INHIBIT
;*      This routine (re)initializes the warrior shooting inhibitor.
;*      The warriors are most inhibited when they are the least agressive
;*      and, conversely, the least inhibited when they are the most agressive.
;*
;* Needs:
;*      Y -> scanner workspace of warrior
;*      WAgg = Warrior agression (from easy $00 to hard $7F)
;*
;* Returns:
;*      OSPERS,Y - Contains a new shooting inhibitor scaled inversely
;*                 proportional to the warrior agrression.
;*
;*****
        ROUTINE Inhibit
        pshs    A               ;* Save work registers.
        lda     #4              ;* Initialize the shot delay minimum.
        pshs    A               ;* Translate the warrior agrression
        lda     WAgg            ;*   (which ranges from $00 to MAXWAGG)
        coma                    ;*   into a corresponding shot delay
.1S     inc     0,S             ;*   (which ranges from MIN+4 to MIN+1)
        adda    #$28            ;*   to be used as the inhibitor personality
        bvc     .1S             ;*   which is saved on the stack just now.
        lda     OSPERS,Y        ;* The personality byte of the warrior get
        anda    #~(PWashIn)     ;*   the old inhibitor trashed and the new              ;;Fixme was: anda  #!N(PWashInhib)
        ora     ,S+             ;*   value from the stack added to the other
        sta     OSPERS,Y        ;*   traits of this warrior.
        puls    A               ;* Restore work registers.
        rts

        PULLORG ROMSAVE