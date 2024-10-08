        PUSHORG ROMSAVE
;*****
;*
;*       SSSS  TTTTT  U   U  BBBB    SSSS
;*      S        T    U   U  B   B  S
;*       SSS     T    U   U  BBBB    SSS
;*          S    T    U   U  B   B      S
;*      SSSS     T     UUU   BBBB   SSSS
;*
;*****
;       SUBTTL  Stubbed out subroutines for Noah and Bob.
;*****
;*
;* STUBS
;*      These routines are part of Noah's collection of Sinistar files.
;*      To facilitate assembling with an inadequate assembler, and since
;*      a linker is not available to us at this time, these routines are
;*      stubbed out.  Noah's assembly will replace these routines by over-
;*      laying a JMP to his assembled code.
;*
;*****
stubs
        ROUTINE addvib
        nop
        nop
        rts

        ROUTINE AMSini          ;* For Bob
        SLEEP   LOOP

        ROUTINE BombsAway       ;* For Richs2                   ;;(Patched over by Z_BOMBSAWAY = $6D30)
        nop
        nop
        rts

        ROUTINE expobj
        nop
        nop
        rts

        ROUTINE givcrys
        nop
        nop
        rts

        ROUTINE InCaller
        nop
        nop
        rts

        ROUTINE InWarrior
        nop
        nop
        rts

        ROUTINE KaBoom
        nop
        nop
        rts

        ROUTINE krcrys
        nop
        nop
        rts

        ROUTINE krworker
        nop
        nop
        rts

        ROUTINE posbounce
        nop
        nop
        rts

        ROUTINE prebounce
        nop
        nop
        rts

        ROUTINE rstpop
        nop
        nop
        nop
        rts

        ROUTINE taunt           ;* For Noah
        nop
        nop
        rts

        PULLORG ROMSAVE