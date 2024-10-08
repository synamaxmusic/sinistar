        PUSHORG ROMSAVE
;       SUBTTL  NEXTTARGET
;*****
;*
;* NEXTTARGET
;*
;* Needs:
;*      X -> Sinistar scanner workspace
;*
;* Returns:
;*      Temp+TSinSPos   = LONG (1 byte) and SHORT (1 byte) Scanner Positions
;*                      of Sinistar before invoking this routine.
;*      Temp+TSinPos    = LONG (1 byte) and SHORT (1 byte) Screen Positions
;*                      of Sinistar before invoking this routine.
;*
;******
        ROUTINE NextTarget      ;* Retarget the Sinistar to its next piece.
        pshs    D,U             ;* Save work registers
;***
;*      Retarget the Sinistar scanner coordinates for the intercept position.
;***
        lda     OSLPOS,X        ;* Save the LONG and
        ldb     OSSPOS,X        ;*   SHORT scanner positions
        std     Temp+TSinSPos   ;*   in temporary storage for restoration later.
;*
        adda    SINILN          ;* Update the scanner position of the
        bvs     .1S             ;*   Sinistar to reflect the piece offset               ;;Fixme was: bvs  1$
        sta     OSLPOS,X        ;*   in it's position as a target.  But, the
.1S     addb    SINISN          ;*   position must not exceed the scanner               ;;Fixme was: 1$ addb    SINISN
        bvs     .2S             ;*   region or wrap around would occur in
        stb     OSSPOS,X        ;*   the computations.
;***
;*      Onscreen, the screen coordinates must be adjusted too!
;***
.2S     ldu     OSSCWSA,X       ;* If the Sinistar is not on screen
        beq     .99S            ;*   then the scanner coordinates are enough.
        lda     OLPOS,U         ;* Save the LONG and
        ldb     OSPOS,U         ;*   SHORT screen positions
        std     Temp+TSinPos    ;*   in temporary storage for restoration later.
;***
;*      Handle clipped objects
;***
        pshs    B
        adda    SinLN
        cmpa    #$C0            ;* This works for limited size objects.
        blo     .101S
        clra
.101S   sta     OLPOS,U
        ldb     OStatus,U
        sex
        puls    B               ;* B = SHORT screen position
        addb    SinSN
        adca    #0
        beq     .104S
        bmi     .103S
        ldb     #-1
        bra     .104S
.103S   clrb
.104S   stb     OSPOS,U
;*      The fractional portion of the screen coordinates have been ignored.
.99S    puls    D,U             ;* Restore work registers
        rts

;       SUBTTL  RETARGET
;*****
;*
;* RETARGET
;*
;* Needs:
;*      X -> Sinistar scanner workspace
;*
;* Returns:
;*      Temp+TSinSPos   = LONG (1 byte) and SHORT (1 byte) Scanner Positions
;*                      of Sinistar before invoking this routine.
;*      Temp+TSinPos    = LONG (1 byte) and SHORT (1 byte) Screen Positions
;*                      of Sinistar before invoking this routine.
;*
;******
        ROUTINE ReTarget        ;* Retarget the Sinistar to its next piece.
        pshs    D,U             ;* Save work registers
;***
;*      Retarget the Sinistar scanner coordinates for the intercept position.
;***
        lda     OSLPOS,X        ;* Save the LONG and
        ldb     OSSPOS,X        ;*   SHORT scanner positions
        std     Temp+TSinSPos   ;*   in temporary storage for restoration later.
;*
        adda    SINILP          ;* Update the scanner position of the
        bvs     .1S             ;*   Sinistar to reflect the piece offset
        sta     OSLPOS,X        ;*   in it's position as a target.  But, the
.1S     addb    SINISP          ;*   position must not exceed the scanner
        bvs     .2S             ;*   region or wrap around would occur in
        stb     OSSPOS,X        ;*   the computations.
;***
;*      Onscreen, the screen coordinates must be adjusted too!
;***
.2S     ldu     OSSCWSA,X       ;* If the Sinistar is not on screen
        beq     .99S            ;*   then the scanner coordinates are enough.
        lda     OLPOS,U         ;* Save the LONG and
        ldb     OSPOS,U         ;*   SHORT screen positions
        std     Temp+TSinPos    ;*   in temporary storage for restoration later.
;***
;*      Handle clipped objects.
;***
        pshs    B
        adda    SinLP
        cmpa    #$C0            ;* This works for limited size objects.
        blo     .201S
        clra
.201S   sta     OLPOS,U
        ldb     OStatus,U
        sex
        puls    B               ;* B = SHORT screen position
        addb    SinSP
        adca    #0
        beq     .204S
        bmi     .203S
        ldb     #-1
        bra     .204S
.203S   clrb
.204S   stb     OSPOS,U
;*      The fractional portion of the screen coordinates have been ignored.
.99S    puls    D,U             ;* Restore work registers
        rts

;       SUBTTL  UNTARGET
;*****
;*
;* UNTARGET
;*
;* Needs:
;*      X -> Sinistar scanner workspace
;*      Temp+TSinSPos   = LONG (1 byte) and SHORT (1 byte) Scanner Positions
;*                      of Sinistar.
;*      Temp+TSinPos    = LONG (1 byte) and SHORT (1 byte) Screen Positions
;*                      of Sinistar.
;*
;* Returns:
;*      Scanner and screen coordinates restored from the above.
;*
;******
        ROUTINE UnTarget
        pshs    D,U             ;* Save work registers
        ldd     Temp+TSinSPos   ;* Restore the Sinistar's
        sta     OSLPOS,X        ;* LONG and
        stb     OSSPOS,X        ;*   SHORT scanner positions.
;*
        ldu     OSSCWSA,X       ;* If the Sinsitar is on screen
        beq     .99S            ;*   it must have those positions restored too:
        ldd     Temp+TSinPos    ;* Restore the Sinistar's
        sta     OLPOS,U         ;* LONG and
        stb     OSPOS,U         ;*   SHORT screen positions.
.99S    puls    D,U             ;* Restore work registers
        rts

        PULLORG ROMSAVE