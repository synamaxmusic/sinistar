;;      INCLUDE START
;;      INCLVER SAM,SINISTAR

        PUSHORG ROMSAVE

;;===============================================================================
; EQUs to remove later
;NULL EQU       $E195   ;IRQ
;;
;;  Copyright message CR2 gets inserted here:
;;
;;CR2SAVE       SET     *
;;CR2   fcc     "COPYRIGHT 1983 WILLIAMS ELECTRONICS, INC."
;;
;;===============================================================================



;* control panel switch vector table (must assemble before switch routines)
PANEL   EQU     *               ;B side table
        FDB     NULL            ;bit 7 low  - unused
        FDB     NULL            ;bit 7 high - unused
        FDB     NULL            ;bit 6 low  - unused
        FDB     NULL            ;bit 6 high - unused
START2  FDB     NULL            ;bit 5 low  - unused
        FDB     NULL            ;bit 5 high - 2 player start
START1  FDB     NULL            ;bit 4 low  - unused
        FDB     NULL            ;bit 4 high - 1 player start
        FDB     NULL            ;bit 3 low  - unused
        FDB     NULL            ;bit 3 high - unused
        FDB     NULL            ;bit 2 low  - unused
        FDB     NULL            ;bit 2 high - unused
SBOMBB  FDB     NULL            ;bit 1 low  - unused
        FDB     NULL            ;bit 1 high - sinibomb
FIREB   FDB     NULL            ;bit 0 low  - unused
        FDB     NULL            ;bit 0 high - fire

        PULLORG ROMSAVE