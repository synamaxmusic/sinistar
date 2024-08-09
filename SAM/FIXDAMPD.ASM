;       INCLUDE START
;       INCLVER SAM,SINISTAR.EQU
FIXDAMPDM
        PUSHORG ROMSAVE                                                 ;;($8E31)

;* romove old task initialization
        PUSHORG $5156
        JMP     FIXDAM1
        PULLORG
FIXDAM1 jsr     StartDemo       ;* Fake the Player 1 button hit.        ;;Fixme was: 100$ (Needed to convert to global labels...decided to go with easier-to-understand labels this time)
        jmp     Starts          ;* Sieze control of the system.

;* make old task initialization a subroutine to save rom in patch
        PUSHORG $5167
        RTS
        PULLORG

;* patch task initialization into correct place
        PUSHORG $527E
        JSR     FIXDAM2                                                 ;;($8E37)
        PULLORG
FIXDAM2 CLRB                                                            ;;Fixme was: 101$
        std     OMTLen+2,X
        JMP     $5159

;* fix garbage velocity save
        PUSHORG $517C
        ADDD    OMTLEN+2,Y      ;*   add it to previous s velocity
        PULLORG

        PULLORG ROMSAVE